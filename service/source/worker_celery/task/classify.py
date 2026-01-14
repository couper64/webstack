# In general, the best practice is to import only what you need (option 1) for clarity and performance, unless you expect to use several items from the module (option 2).
import os
import tempfile # Celery Dockerfile doesn't have permissions to write to local folders.

from pathlib import Path

from codecarbon import EmissionsTracker

from main            import worker
from .classifier import train
from .classifier import infer
from .util       import append_json_codecarbon
from .util       import upload_output_to_minio


@worker.task(name="train_task")
def train_task(epochs : int, output_filename : str):

    # Preparing a safe place to store output data.
    temp_dir = tempfile.mkdtemp(dir="/tmp")
    # For instance, model would be saved there too.
    output_model_path = os.path.join(temp_dir, output_filename)
    output_json_codecarbon_path = os.path.join(temp_dir, "emissions.json")

    with EmissionsTracker(measure_power_secs=1, output_dir=temp_dir, log_level="critical", tracking_mode="process", allow_multiple_runs=True) as tracker:
        # Do the task
        train(epochs, output_model_path)

    # Handle results: the grand goal is to return results back to user, i.e. give link to the results.
    append_json_codecarbon(tracker, output_json_codecarbon_path)

    # Remove unnecessary files before uploading.
    csv_path = Path(os.path.join(temp_dir, "emissions.csv"))
    if csv_path.exists:
        csv_path.unlink()

    download_url : str = upload_output_to_minio(temp_dir)

    # Needed to identify individual outputs.
    folder_path = Path(temp_dir)
    zip_path = folder_path.with_suffix(".zip") 

    return {
        "epochs": epochs,
        "emitted": {
            "co2": tracker.final_emissions,
            "unit": "g"
        },
        "download_url": download_url,
        "message": f"Trained for {epochs} epochs, emitted {tracker.final_emissions * 1000:.4f} g CO2eq.",
        "model_name": output_filename,
        "zip_name": zip_path.name
    }


@worker.task(name="infer_task")
def infer_task(zip_name : str, model_name : str):

    # Preparing a safe place to store output data.
    temp_dir = tempfile.mkdtemp(dir="/tmp")
    output_json_codecarbon_path = os.path.join(temp_dir, "emissions.json")

    # Need to download the model.

    # Load from environment variables.
    MINIO_ENDPOINT        : str  = os.getenv("MINIO_ENDPOINT"   , "minio:9000"        )
    MINIO_ACCESS_KEY      : str  = os.getenv("MINIO_ACCESS_KEY" , "ROOTNAME"          )
    MINIO_SECRET_KEY      : str  = os.getenv("MINIO_SECRET_KEY" , "CHANGEME123"       )
    MINIO_SECURE          : bool = os.getenv("MINIO_SECURE"     , "false"             ).lower() == "true"
    MINIO_BUCKET_NAME     : str  = os.getenv("MINIO_BUCKET"     , "webservice"        )
    
    from minio import Minio

    # MinIO client.
    minio_client = Minio(
        endpoint=MINIO_ENDPOINT, # MinIO endpoint
        access_key=MINIO_ACCESS_KEY,
        secret_key=MINIO_SECRET_KEY,
        secure=MINIO_SECURE # set True if using https
    )

    minio_client.fget_object(MINIO_BUCKET_NAME, zip_name, os.path.join(temp_dir, zip_name))

    # Now, we need to unzip the file.

    import zipfile

    local_path = os.path.join(temp_dir, zip_name)
    extract_to = temp_dir # folder where files will be extracted.

    # Make sure the extraction directory exists
    os.makedirs(extract_to, exist_ok=True)

    # Open the ZIP file and extract all contents
    with zipfile.ZipFile(local_path, 'r') as zip_ref:
        zip_ref.extractall(extract_to)

    # Now, we can updated input path.
    input_path = os.path.join(temp_dir, model_name)

    with EmissionsTracker(measure_power_secs=1, output_dir=temp_dir, log_level="critical", tracking_mode="process", allow_multiple_runs=True) as tracker:
        # Do the task
        infer(input_path)

    # Remove unnecessary files.
    downloaded_zip_path = Path(os.path.join(temp_dir, zip_name))
    if downloaded_zip_path.exists:
        downloaded_zip_path.unlink()
    csv_path = Path(os.path.join(temp_dir, "emissions.csv"))
    if csv_path.exists:
        csv_path.unlink()

    # Handle results: the grand goal is to return results back to user, i.e. give link to the results.
    append_json_codecarbon(tracker, output_json_codecarbon_path)
    download_url : str = upload_output_to_minio(temp_dir)

    # Needed to identify individual outputs.
    folder_path = Path(temp_dir)
    zip_path = folder_path.with_suffix(".zip") 

    return {
        "emitted": {
            "co2": tracker.final_emissions,
            "unit": "g"
        },
        "download_url": download_url,
        "message": f"Inferred using {input_path}, emitted {tracker.final_emissions * 1000:.4f} g CO2eq.",
        "zip_name": zip_path.name
    }
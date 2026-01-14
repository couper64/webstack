import os
import json
import zipfile
import requests

from urllib.parse import urljoin
from pathlib      import Path

from codecarbon import EmissionsTracker


# Load credentials from environment variables
MINIO_HOST_PREFIX : str  = os.getenv("MINIO_HOST_PREFIX", "https://localhost/minio/api/")


def append_json_codecarbon(tracker : EmissionsTracker, output_path : str = "/tmp/emissions.json"):

    # Anonymisation
    d = tracker.final_emissions_data.__dict__
    d["gpu_count"] = 4
    d["gpu_model"] = "4 x NVIDIA A6000 Ada Lovelace"

    with open(output_path, "w") as f:
        json.dump(d, f, indent=2)


def upload_output_to_minio(output_path : str):

    # Also, we will zip up all of the content.
    folder_path = Path(output_path)
    zip_path = folder_path.with_suffix(".zip") 

    # +---------ZIP---------+
    with zipfile.ZipFile(zip_path, "w", zipfile.ZIP_DEFLATED) as zipf:
        for root, dirs, files in os.walk(folder_path):
            for file in files:
                file_path = os.path.join(root, file)
                # Add file to zip, keep relative path.
                arcname = os.path.relpath(file_path, folder_path)
                zipf.write(file_path, arcname)

    print(f"Created zip: {zip_path}")
    # +---------ZIP---------+

    # +-------UPLOAD--------+
    upload_api_url = "http://fastapi:8000/file/get/url/upload/"
    params = {"filename": zip_path.name}
    headers = {"accept": "application/json"}

    response = requests.get(upload_api_url, headers=headers, params=params)
    upload_url = urljoin("http://minio:9000/", response.json()['url']) # response.json()['url'].replace("/minio/api/", "http://minio:9000/")

    print("Status code:", response.status_code)
    print("Response JSON:", response.json())
    print("Upload URL:", upload_url)

    with open(zip_path, "rb") as f:
        upload_resp = requests.put(upload_url, data=f, verify=False)

    print("Upload status:", upload_resp.status_code)
    # +-------UPLOAD--------+

    # +------DOWNLOAD-------+
    download_api_url = "http://fastapi:8000/file/get/url/download/"
    response = requests.get(download_api_url, params=params)
    download_url = urljoin(MINIO_HOST_PREFIX, response.json()['url'])
    # +------DOWNLOAD-------+

    return download_url

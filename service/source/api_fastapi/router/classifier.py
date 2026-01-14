from fastapi import APIRouter
from celery.result import AsyncResult

from worker import worker

router = APIRouter(
    prefix="/classifier",
    tags=["classifier"],
)

@router.post("/train")
async def run_train_task(epochs : int, output_filename : str):
    result: AsyncResult = worker.send_task("train_task", kwargs={"epochs": epochs, "output_filename" : output_filename})
    return {"task_id": result.id}


@router.post("/infer")
async def run_infer_task(zip_name : str, model_name : str):
    result: AsyncResult = worker.send_task("infer_task", kwargs={"zip_name" : zip_name, "model_name" : model_name})
    return {"task_id": result.id}

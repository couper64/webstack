import os

from datetime import timedelta
from urllib.parse import urlparse

from fastapi import APIRouter
from pydantic import BaseModel
from minio import Minio


# Load from environment variables.
MINIO_HOST_PREFIX     : str  = os.getenv("MINIO_HOST_PREFIX", "https://localhost/")
MINIO_ENDPOINT        : str  = os.getenv("MINIO_ENDPOINT"   , "minio:9000"        )
MINIO_ACCESS_KEY      : str  = os.getenv("MINIO_ACCESS_KEY" , "ROOTNAME"          )
MINIO_SECRET_KEY      : str  = os.getenv("MINIO_SECRET_KEY" , "CHANGEME123"       )
MINIO_SECURE          : bool = os.getenv("MINIO_SECURE"     , "false"             ).lower() == "true"
MINIO_BUCKET_NAME     : str  = os.getenv("MINIO_BUCKET"     , "webservice"        )


class UrlResponse(BaseModel):
    url: str
    expires: float # `timedelta` - an ISO 8601 duration ("PT1H") is dicouraged due to many industry guidelines and API design standards recommend representing durations simply as seconds—preferably as integers or floats.


router = APIRouter(
    prefix="/file",
    tags=["file"],
)


# MinIO client.
minio_client = Minio(
    endpoint=MINIO_ENDPOINT, # MinIO endpoint
    access_key=MINIO_ACCESS_KEY,
    secret_key=MINIO_SECRET_KEY,
    secure=MINIO_SECURE # set True if using https
)

# Ensure bucket exists
if not minio_client.bucket_exists(MINIO_BUCKET_NAME):
    minio_client.make_bucket(MINIO_BUCKET_NAME)


def rewrite_presigned_url(url: str, public_prefix: str) -> str:

    """Replace internal host/port in a MinIO presigned URL with a public prefix."""

    parsed = urlparse(url)
    internal_host = f"{parsed.scheme}://{parsed.hostname}" + (f":{parsed.port}" if parsed.port else "")

    # Ensure prefix ends with '/'.
    public_prefix = public_prefix.rstrip('/') + '/'

    # Replace only the leading internal host.
    return url.replace(internal_host + '/', public_prefix, 1)


@router.get("/get/url/upload/", response_model=UrlResponse)
def generate_upload_url(filename: str):
    # Expire in 1 hour.
    url = minio_client.presigned_put_object(
        MINIO_BUCKET_NAME,
        filename,
        expires=timedelta(hours=1),
    )

    # Because behind a proxy replace container with actual calling URL.
    url = rewrite_presigned_url(url, MINIO_HOST_PREFIX)

    return UrlResponse(
        url       = url
        , expires = timedelta(hours=1).total_seconds()
    )

@router.get("/get/url/download/", response_model=UrlResponse)
def generate_download_url(filename: str):
    url = minio_client.presigned_get_object(
        MINIO_BUCKET_NAME,
        filename,
        expires=timedelta(hours=1)
    )

    # Because behind a proxy.
    url = rewrite_presigned_url(url, MINIO_HOST_PREFIX)

    return UrlResponse(
        url       = url
        , expires = timedelta(hours=1).total_seconds()
    )
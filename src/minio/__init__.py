"""
MinIO Integration Module
Provides S3-compatible object storage for DarkChannel services
"""

from .client import MinIOClient
from .jobs import JobManager
from .utils import generate_job_id, get_s3_url, parse_s3_url

__all__ = [
    'MinIOClient',
    'JobManager',
    'generate_job_id',
    'get_s3_url',
    'parse_s3_url'
]

__version__ = '1.0.0'

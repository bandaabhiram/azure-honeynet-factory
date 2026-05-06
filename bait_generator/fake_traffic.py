"""
Fake Traffic Generator — Creates realistic access patterns on honeypots
to make them appear active and attractive to attackers.
"""
import random
import time
from datetime import datetime, timezone

from azure.identity import DefaultAzureCredential
from azure.storage.blob import BlobServiceClient


def generate_fake_blob_access(storage_account_name: str):
    """Generate fake blob read operations to make honeypot storage look active."""
    conn_str = f"DefaultEndpointsProtocol=https;AccountName={storage_account_name};EndpointSuffix=core.windows.net"
    blob_client = BlobServiceClient.from_connection_string(conn_str, credential=DefaultAzureCredential())
    container = blob_client.get_container_client("customer-data")

    # List blobs (creates audit log)
    blobs = list(container.list_blobs())
    print(f"[{datetime.now(timezone.utc).isoformat()}] Listed {len(blobs)} blobs in honeypot")


def schedule_bait(storage_accounts: list, interval_minutes: int = 30):
    """Continuously generate fake traffic on a schedule."""
    while True:
        for sa in storage_accounts:
            try:
                generate_fake_blob_access(sa)
            except Exception as e:
                print(f"Bait error for {sa}: {e}")
        time.sleep(interval_minutes * 60)


if __name__ == "__main__":
    # Example: target honeypot storage accounts
    schedule_bait(["honeynetsa12345678"])

import asyncio
from datetime import datetime, timedelta, timezone
import logging
import os

from azure.eventhub.aio import EventHubConsumerClient
from azure.eventhub.extensions.checkpointstoreblobaio import BlobCheckpointStore
from azure.identity.aio import DefaultAzureCredential

BLOB_STORAGE_ACCOUNT_URL = os.getenv("BLOB_STORAGE_ACCOUNT_URL")
BLOB_CONTAINER_NAME = os.getenv("BLOB_CONTAINER_NAME")
EVENT_HUB_FULLY_QUALIFIED_NAMESPACE = os.getenv("EVENT_HUB_FULLY_QUALIFIED_NAMESPACE")
EVENT_HUB_NAME = os.getenv("EVENT_HUB_NAME")
EVENT_HUB_CONSUMER_GROUP = os.getenv("EVENT_HUB_CONSUMER_GROUP")

logger = logging.getLogger("azure.eventhub")
logging.basicConfig(level=logging.INFO)

credential = DefaultAzureCredential()

# Global variable to track the last event time
last_event_time = None
WAIT_DURATION = timedelta(seconds=30)


async def on_event(partition_context, event):
    global last_event_time

    if event is not None:
        logger.info(
            'Received the event: "{}" from the partition with ID: "{}"'.format(
                event.body_as_str(encoding="UTF-8"), partition_context.partition_id
            )
        )
    else:
        logger.info(f"Received a None event from partition ID: {partition_context.partition_id}")

    # Update the last event time
    last_event_time = datetime.now(timezone.utc)

    await partition_context.update_checkpoint(event)


async def receive():
    global last_event_time

    checkpoint_store = BlobCheckpointStore(
        blob_account_url=BLOB_STORAGE_ACCOUNT_URL,
        container_name=BLOB_CONTAINER_NAME,
        credential=credential,
    )

    client = EventHubConsumerClient(
        fully_qualified_namespace=EVENT_HUB_FULLY_QUALIFIED_NAMESPACE,
        eventhub_name=EVENT_HUB_NAME,
        consumer_group=EVENT_HUB_CONSUMER_GROUP,
        checkpoint_store=checkpoint_store,
        credential=credential,
    )

    # Initialize the last event time
    last_event_time = datetime.now(timezone.utc)

    async with client:
        # client.receive method is a blocking call, so we run it in a separate thread.
        receive_task = asyncio.create_task(
            client.receive(
                on_event=on_event,
                starting_position="-1",
            )
        )

        # Wait until no events are received for the specified duration
        while True:
            await asyncio.sleep(1)
            if datetime.now(timezone.utc) - last_event_time > WAIT_DURATION:
                break

        # Close the client and the receive task
        await client.close()
        receive_task.cancel()
        try:
            await receive_task
        except asyncio.CancelledError:
            pass

        # Close credential when no longer needed.
        await credential.close()


def run():
    loop = asyncio.get_event_loop()
    loop.run_until_complete(receive())

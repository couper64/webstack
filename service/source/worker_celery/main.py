from celery import Celery

worker = Celery(
    __name__,
    broker="redis://redis:6379/0", # Change to localhost when running natively.
    backend="redis://redis:6379/0", # Change to redis when running inside a container.
)

# Manually load tasks instead of `worker.autodiscover_tasks(["task"])`. Often preferred in production outside frameworks like Django.
import task
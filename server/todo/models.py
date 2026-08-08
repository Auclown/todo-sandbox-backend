import uuid
from django.db import models


class Todo(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    text = models.CharField(max_length=255)
    completed = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    def to_dict(self):
        return {
            'id': str(self.id),
            'text': self.text,
            'completed': self.completed,
            'createdAt': self.created_at.isoformat() if self.created_at else None,
        }

    def __str__(self):
        return f"{self.text} ({'Done' if self.completed else 'Pending'})"

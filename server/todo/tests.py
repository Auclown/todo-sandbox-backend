import json
from django.test import TestCase, Client
from .models import Todo


class TodoApiTests(TestCase):
    def setUp(self):
        self.client = Client()
        self.todo1 = Todo.objects.create(text="First task", completed=False)
        self.todo2 = Todo.objects.create(text="Second task", completed=True)

    def test_get_todos(self):
        response = self.client.get('/api/todos/')
        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertEqual(len(data), 2)

    def test_create_todo(self):
        response = self.client.post(
            '/api/todos/',
            data=json.dumps({'text': 'New backend todo'}),
            content_type='application/json'
        )
        self.assertEqual(response.status_code, 201)
        data = response.json()
        self.assertEqual(data['text'], 'New backend todo')
        self.assertFalse(data['completed'])
        self.assertTrue('id' in data)

    def test_update_todo(self):
        response = self.client.patch(
            f'/api/todos/{self.todo1.id}',
            data=json.dumps({'completed': True, 'text': 'Updated first task'}),
            content_type='application/json'
        )
        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertTrue(data['completed'])
        self.assertEqual(data['text'], 'Updated first task')

    def test_delete_todo(self):
        response = self.client.delete(f'/api/todos/{self.todo2.id}')
        self.assertEqual(response.status_code, 204)
        self.assertFalse(Todo.objects.filter(id=self.todo2.id).exists())

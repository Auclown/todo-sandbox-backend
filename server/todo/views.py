import json
from django.http import JsonResponse, HttpResponse
from django.views.decorators.csrf import csrf_exempt
from django.shortcuts import get_object_or_404
from .models import Todo


@csrf_exempt
def todo_list_create(request):
    if request.method == 'GET':
        todos = Todo.objects.all().order_by('-created_at')
        return JsonResponse([t.to_dict() for t in todos], safe=False)

    elif request.method == 'POST':
        try:
            data = json.loads(request.body.decode('utf-8'))
        except (json.JSONDecodeError, UnicodeDecodeError):
            return JsonResponse({'error': 'Invalid JSON body'}, status=400)

        text = data.get('text', '').strip()
        if not text:
            return JsonResponse({'error': 'Text field is required'}, status=400)

        if Todo.objects.count() >= 20:
            return JsonResponse({'error': 'Maximum 20 items allowed'}, status=400)

        completed = bool(data.get('completed', False))
        todo = Todo.objects.create(text=text, completed=completed)
        return JsonResponse(todo.to_dict(), status=201)

    return JsonResponse({'error': 'Method not allowed'}, status=405)


@csrf_exempt
def todo_detail(request, todo_id):
    todo = get_object_or_404(Todo, pk=todo_id)

    if request.method == 'GET':
        return JsonResponse(todo.to_dict())

    elif request.method in ('PATCH', 'PUT'):
        try:
            data = json.loads(request.body.decode('utf-8'))
        except (json.JSONDecodeError, UnicodeDecodeError):
            return JsonResponse({'error': 'Invalid JSON body'}, status=400)

        if 'text' in data:
            new_text = str(data['text']).strip()
            if new_text:
                todo.text = new_text

        if 'completed' in data:
            todo.completed = bool(data['completed'])

        todo.save()
        return JsonResponse(todo.to_dict())

    elif request.method == 'DELETE':
        todo.delete()
        return HttpResponse(status=204)

    return JsonResponse({'error': 'Method not allowed'}, status=405)

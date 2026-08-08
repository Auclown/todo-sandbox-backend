from django.urls import path
from . import views

urlpatterns = [
    path('', views.todo_list_create, name='todo_list_create'),
    path('<str:todo_id>', views.todo_detail, name='todo_detail'),
    path('<str:todo_id>/', views.todo_detail, name='todo_detail_slash'),
]

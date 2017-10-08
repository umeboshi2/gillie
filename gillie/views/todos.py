import os

import transaction

from rest_toolkit import resource
from rest_toolkit.ext.sql import SQLResource
from rest_toolkit.abc import (
    ViewableResource,
    EditableResource,
    DeletableResource
)

from ..models.uzig import Resource, Entry
from ..models.mymodel import Todo

APIROOT = '/api/dev/bapi'
TODOS_ROUTE = os.path.join(APIROOT, 'todos')

RESOURCE_TYPE = 'todo'

def make_resource_name(request, name):
    return '%s:%s:%s' % (request.user.user_name, RESOURCE_TYPE, name)

@resource(TODOS_ROUTE)
class TodoCollection(object):
    def __init__(self, request):
        self.user_name = request.user.user_name

    
@TodoCollection.GET()
def list_todos(collection, request):
    user = request.user
    todos = user.resources.filter_by(resource_type='todo')
    return dict(items=list(t.get_dict() for t in todos))

@TodoCollection.POST()
def add_todo(collection, request):
    with transaction.manager:
        body = request.json_body
        todo = Todo()
        todo.name = body['name']
        todo.description = body['description']
        todo.resource_name = make_resource_name(request, body['name'])
        request.dbsession.add(todo)
        request.user.resources.append(todo)
    return todo.get_dict()



@resource('%s/{id}' % TODOS_ROUTE)
class TodoResource(EditableResource, ViewableResource, DeletableResource):
    def __init__(self, request):
        todo_id = request.matchdict['id']
        self.todo = request.dbsession.query(Todo).get(todo_id)
        if self.todo is None:
            raise KeyError('Unknown todo id')

    def to_dict(self):
        return self.todo.get_dict()

    def update_from_dict(self, data, replace=True):
        with transaction.manager:
            for f in ['name', 'description']:
                setattr(self.todo, f, data[f])
            self.todo.completed = bool(data['completed'])
        return {}
    
    def validate(self, data, partial):
        pass

    def delete(self):
        with transaction.manager:
            self.todo.delete()
    



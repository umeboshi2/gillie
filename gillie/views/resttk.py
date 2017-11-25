import os
from datetime import datetime

import transaction
from rest_toolkit.abc import (
    ViewableResource,
    EditableResource,
    DeletableResource
)


def make_resource_name(request, resource_type):
    return ':'.join([request.user.user_name, resource_type])


class BaseResourceCollection(object):
    def __init__(self, request):
        self.user_name = request.user.user_name

@BaseResourceCollection.GET()
def list_items(collection, request):
    user = request.user
    items = user.resources.filter_by(resource_type=collection.resource_type)
    return dict(items=(i.get_dict() for i in items))

@BaseResourceCollection.POST()
def add_item(collection, request):
    body = request.json_body
    # get posting fields
    # make new db model
    
class BasicResource(EditableResource, ViewableResource, DeletableResource):
    def to_dict(self):
        return self.model.get_dict()

    def update_from_dict(self, data, replace=True):
        with transaction.manager:
            for k,v in list(data.items()):
                if hasattr(self.model, k):
                    setattr(self.model, k, v)
        return {}

    def validate(self, data, partial):
        pass

    def delete(self):
        with transaction.manager:
            self.model.delete()
            


import os
from configparser import ConfigParser
from datetime import datetime
from urllib.error import HTTPError

from cornice.resource import resource, view
from pyramid.httpexceptions import HTTPNotFound
from pyramid.httpexceptions import HTTPFound
from pyramid.httpexceptions import HTTPForbidden
from sqlalchemy.orm.exc import NoResultFound
import transaction

from trumpet.views.resourceviews import SimpleModelResource

from chert.alchemy import TimeStampMixin


APIROOT = '/api/dev/bapi'

rscroot = os.path.join(APIROOT, 'main')

from pyramid.view import view_config
from pyramid.response import Response
import requests

from alchemyjsonschema import SchemaFactory
from alchemyjsonschema import NoForeignKeyWalker

from ..models.mymodel import Todo

    

modelpath = os.path.join(APIROOT, '{model}')
@resource(collection_path=modelpath,
          path=os.path.join(modelpath, '{id}'))
class ModelView(SimpleModelResource):
    def __init__(self, request, context=None):
        super(ModelView, self).__init__(request, context=context)
        self.factory = SchemaFactory(NoForeignKeyWalker)

    @property
    def model_map(self):
        return dict(todos=Todo)
    



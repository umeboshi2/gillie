import os
from configparser import ConfigParser
from datetime import datetime
from urllib.error import HTTPError

from cornice.resource import resource, view
from pyramid.httpexceptions import HTTPNotFound
from pyramid.httpexceptions import HTTPFound
from pyramid.httpexceptions import HTTPForbidden
from bs4 import BeautifulSoup
from sqlalchemy.orm.exc import NoResultFound
import transaction

from .restviews import BaseResource
from .restviews import SimpleModelResource

from chert.alchemy import TimeStampMixin


APIROOT = '/api/dev/bapi'

rscroot = os.path.join(APIROOT, 'main')

from pyramid.view import view_config
from pyramid.response import Response
import requests

from alchemyjsonschema import SchemaFactory
from alchemyjsonschema import NoForeignKeyWalker

from ..models.mymodel import EBMODELS

def get_clzpage(request):
    path = os.path.join(*request.matchdict['path'])
    url = os.path.join('http://core.collecterz.com', path)
    r = requests.get(url)
    return Response(r.content)
    
    

modelpath = os.path.join(APIROOT, 'sofi', '{model}')
@resource(collection_path=modelpath,
          path=os.path.join(modelpath, '{id}'))
class EbClzView(SimpleModelResource):
    def __init__(self, request, context=None):
        super(EbClzView, self).__init__(request, context=context)
        self.limit = 25
        self._use_pagination = True
        self.model = EBMODELS.get(self.request.matchdict['model'])
        self.factory = SchemaFactory(NoForeignKeyWalker)

    @property
    def model_map(self):
        return EBMODELS

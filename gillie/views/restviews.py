import os
from datetime import datetime

import transaction
from cornice.resource import resource, view


def apiroot(prefix='/api', version='dev'):
    return os.path.join(prefix, version)


class BaseResource(object):
    def __init__(self, request, context=None):
        super(BaseResource, self).__init__(request, context=context)
        self.request = request
        self.db = self.request.dbsession
        self.limit = None
        self.max_limit = 100
        
    def serialize_object(self, dbobj):
        return dbobj.serialize()

    # use this when you do only need  certain model attributes
    # in a collection, rather than return the complete models
    def serialize_object_for_collection_query(self, dbobj):
        return self.serialize_object(dbobj)

    def collection_query(self):
        raise RuntimeError("Implement me in subclass")

    def _apply_pagination(self, query):
        offset = 0
        limit = self.limit
        GET = self.request.GET
        if 'offset' in GET:
            offset = int(GET['offset'])
        if 'limit' in GET:
            limit = int(GET['limit'])
            if limit > self.max_limit:
                limit = self.max_limit
        return query.offset(offset).limit(limit)
    
    def collection_get(self):
        q = self.collection_query()
        total_count = q.count()
        if self._use_pagination:
            q = self._apply_pagination(q)
        objects = q.all()
        data = [self.serialize_object_for_collection_query(o) for o in objects]
        return dict(total_count=total_count, items=data)
    


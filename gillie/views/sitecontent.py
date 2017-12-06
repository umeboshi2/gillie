import os

from cornice.resource import resource, view
import transaction
from trumpet.views.resourceviews import BaseResource, apiroot
from trumpet.views.resourceviews import BaseModelResource

from ..models.mymodel import SiteDocument

#@resource(**make_resource(path, ident='name'))
def make_resource(rpath, ident='id', cross_site=True):
    path = os.path.join(rpath, '{%s}' % ident)
    data = dict(collection_path=rpath, path=path)
    if cross_site:
        data['cors_origins'] = ('*',)
    return data

site_documents_api_path = os.path.join(apiroot(), 'sitedocuments')
#@resource(**make_resource(site_documents_api_path, ident='name'))
@resource(**make_resource(site_documents_api_path))
class SiteDocumentResource(BaseModelResource):
    model = SiteDocument
    
class SiteDocumentResourceOrig(BaseResource):
    def __init__(self, request, context=None):
        super(SiteDocumentResource, self).__init__(request, context=context)

    def query(self):
        return self.db.query(SiteDocument)
        
    def collection_query(self):
        return self.db.query(SiteDocument)

    def _get(self, name):
        return self.query().filter_by(name=name).first()
    
    def get(self):
        name = self.request.matchdict['name']
        result = self._get(name)
        return self.serialize_object(result)
    
    def _insert_or_update(self, name):
        fields = ['title', 'description', 'content']
        data = dict(((f, self.request.json[f]) for f in fields))
        data['name'] = name
        # FIXME, don't hardcode markdown
        data['doctype'] = 'markdown'

        with transaction.manager:
            doc = self._get(name)
            for k in data:
                setattr(doc, k, data[k])
        return dict(data=doc.serialize(), result='success')

    def put(self):
        name = self.request.matchdict['name']
        return self._insert_or_update(name)
    
    def delete(self):
        with transaction.manager:
            name = self.request.matchdict['name']
            m = self._get(name)
            m.delete()
        return dict(result='success')
            
    

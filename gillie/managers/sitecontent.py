import transaction

from sqlalchemy.orm.exc import NoResultFound

from .base import BaseManager

from ..models.mymodel import SiteDocument


class SiteDocumentManager(BaseManager):
    @property
    def query(self):
        return self.session.query(SiteDocument)
    
    def getbyname(self, name):
        q = self.query
        q = q.filter_by(name=name)
        try:
            return q.one()
        except NoResultFound:
            return None

    def add_document(self, name, title, description, content,
                     doctype='markdown'):
        with transaction.manager:
            d = SiteDocument()
            d.name = name
            d.title = title
            d.description = description
            d.content = content
            d.doctype = doctype
            self.session.add(d)
        return self.session.merge(d)

    
    def update_document(self, doc, name, title, description, content,
                     doctype='markdown'):
        with transaction.manager:
            doc.name = name
            doc.title = title
            doc.description = description
            doc.content = content
            doc.doctype = doctype
            self.session.add(doc)
        return self.session.merge(doc)
    
    
    def delete_document(self, name):
        with transaction.manager:
            d = self.getbyname(name)
            if d is not None:
                self.session.delete(d)
                
    

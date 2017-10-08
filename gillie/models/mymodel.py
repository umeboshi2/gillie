from sqlalchemy import (
    Column,
    Index,
    Integer,
    Text,
    Unicode,
    UnicodeText,
    DateTime,
    PickleType,
    Boolean,
    Enum,
    func,
    ForeignKey,
)

from .meta import Base
from .util import SerialBase
from .uzig import Resource

class Todo(Resource, SerialBase):
    __tablename__ = 'todos'
    __mapper_args__ = {'polymorphic_identity': 'todo'}
    __possible_permissions__ = ['view', 'edit']

    plural_type = 'todos'


    id = Column(Integer,
                ForeignKey('resources.resource_id',
                           onupdate='CASCADE',
                           ondelete='CASCADE', ),
                primary_key=True, )
    # ... your own properties....
    name = Column(Text, unique=True)
    description = Column(Text)
    completed = Column(Boolean, default=False)


DocType = Enum('markdown', 'html',
               name='site_document_type_enum')

class MyModel(Base, SerialBase):
    __tablename__ = 'models'
    id = Column(Integer, primary_key=True)
    name = Column(Text)
    value = Column(Integer)


Index('my_index', MyModel.name, unique=True, mysql_length=255)

class SiteImage(Base, SerialBase):
    __tablename__ = 'site_images'
    id = Column(Integer, primary_key=True)
    name = Column(Unicode(100), unique=True)
    content = Column(PickleType)
    thumbnail = Column(PickleType)
    
    def __init__(self, name=None, content=None):
        self.name = name
        self.content = content
        
    def __repr__(self):
        return self.name


class SiteDocument(Base, SerialBase):
    __tablename__ = 'site_documents'
    id = Column(Integer, primary_key=True)
    name = Column(Unicode(100), unique=True)
    title = Column(Unicode(500))
    description = Column(Unicode(500))
    doctype = Column(DocType, default='markdown')
    #content = Column(PickleType)
    content = Column(UnicodeText)
    created = Column(DateTime, default=func.now())
    modified = Column(DateTime, default=func.now())


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

permission_names = """
view
edit
root_administration
admin_panel
admin_entries
admin_users
admin_groups
owner
authenticated

ANY_PERMISSION
NO_PERMISSION_REQUIRED

"""

class Todo(Base, SerialBase):
    __tablename__ = 'todos'
    id = Column(Integer,
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

class WikiPage(Base, SerialBase):
    __tablename__ = 'wikipages'
    id = Column(Integer, primary_key=True)
    name = Column(Unicode, unique=True)
    title = Column(Unicode(500))
    description = Column(Unicode(500))
    content = Column(UnicodeText)
    created = Column(DateTime, default=func.now())
    modified = Column(DateTime, default=func.now())    

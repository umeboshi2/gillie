from configparser import ConfigParser
from io import StringIO

from sqlalchemy import (
    Column,
    Index,
    Integer,
    BigInteger,
    Float,
    Text,
    Unicode,
    UnicodeText,
    Date,
    DateTime,
    PickleType,
    Boolean,
    Enum,
    func,
    ForeignKey,
)
from sqlalchemy.orm import relationship
from chert.alchemy import SerialBase, TimeStampMixin

from .meta import Base

from .usergroup import User

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

class WikiPage(Base, TimeStampMixin):
    __tablename__ = 'wikipages'
    id = Column(Integer, primary_key=True)
    name = Column(Unicode, unique=True)
    title = Column(Unicode(500))
    description = Column(Unicode(500))
    content = Column(UnicodeText)
    original = Column(UnicodeText)

class Todo(Base, TimeStampMixin):
    __tablename__ = 'todos'
    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    name = Column(Text, unique=True)
    description = Column(Text)
    completed = Column(Boolean(name='todo_complete'), default=func.false())

    
Todo.user = relationship(User, uselist=False, lazy='subquery')

DocType = Enum('markdown', 'html',
               name='site_document_type_enum')

class SiteDocument(Base, TimeStampMixin):
    __tablename__ = 'site_documents'
    id = Column(Integer, primary_key=True)
    name = Column(Unicode(100), unique=True)
    title = Column(Unicode(500))
    description = Column(Unicode(500))
    doctype = Column(DocType, default='markdown')
    content = Column(UnicodeText)

class MyModel(Base, SerialBase):
    __tablename__ = 'models'
    id = Column(Integer, primary_key=True)
    name = Column(Text)
    value = Column(Integer)


Index('my_index', MyModel.name, unique=True, mysql_length=255)


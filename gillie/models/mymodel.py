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
    func,
    ForeignKey,
)
from sqlalchemy.orm import relationship
from hornstone.alchemy import SerialBase, TimeStampMixin
from hornstone.models.documents import SiteDocumentMixin

from hornstone.models.blog import (
    PersonMixin,
    BlogMixin,
    PostMixin,
    CommentMixin,
)

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
    headers = Column(PickleType)
    updated_upstream = Column(DateTime)
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


class SiteDocument(Base, SiteDocumentMixin):
    pass


class MyModel(Base, SerialBase):
    __tablename__ = 'models'
    id = Column(Integer, primary_key=True)
    name = Column(Text)
    value = Column(Integer)


Index('my_index', MyModel.name, unique=True, mysql_length=255)


class Person(Base, PersonMixin):
    pass


class Blog(Base, BlogMixin):
    pass


class Post(Base, PostMixin):
    pass


class Comment(Base, CommentMixin):
    pass

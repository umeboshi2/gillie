from configparser import ConfigParser
from io import StringIO

from sqlalchemy import Column
from sqlalchemy import Integer, Boolean
from sqlalchemy import Unicode, UnicodeText
from sqlalchemy import ForeignKey

from sqlalchemy.orm import relationship
from chert.alchemy import TimeStampMixin

from .meta import Base

# imports for populate()
import transaction
from sqlalchemy.exc import IntegrityError


class User(Base, TimeStampMixin):
    __tablename__ = 'users'
    id = Column(Integer, primary_key=True)
    username = Column(Unicode(50), unique=True)
    fullname = Column(Unicode(150), unique=True)
    email = Column(Unicode(150), unique=True)
    # https://bitbucket.org/zzzeek/sqlalchemy/issues/3067/naming-convention-exception-for-boolean
    active = Column(Boolean(name='user_active'), default=True)
    password = Column(Unicode(150))
    
    def __init__(self, username=None):
        self.username = username

    def __repr__(self):
        return self.username

    def get_groups(self):
        return [g.name for g in self.groups]

    @property
    def name(self):
        return super(Base, self).username

    # working to eventually rename username to name
    def serialize(self):
        data = TimeStampMixin.serialize(self)
        data['name'] = data['username']
        return data
    
    
class UserConfig(Base, TimeStampMixin):
    __tablename__ = 'user_config'
    user_id = Column(Integer, ForeignKey('users.id'), primary_key=True)
    text = Column(UnicodeText)

    def __init__(self, user_id=None, text=None):
        self.user_id = user_id
        self.text = text

    def get_config(self):
        c = ConfigParser()
        c.readfp(StringIO(self.text))
        return c

    def set_config(self, config):
        cfile = StringIO()
        config.write(cfile)
        cfile.seek(0)
        text = cfile.read()
        self.text = text
    
class Group(Base, TimeStampMixin):
    __tablename__ = 'groups'
    id = Column(Integer, primary_key=True)
    name = Column(Unicode(50), unique=True)

    def __init__(self, name=None):
        self.name = name

class UserGroup(Base, TimeStampMixin):
    __tablename__ = 'group_user'
    group_id = Column(Integer, ForeignKey('groups.id'), primary_key=True)
    user_id = Column(Integer, ForeignKey('users.id'), primary_key=True)

    def __init__(self, gid=None, uid=None):
        self.group_id = gid
        self.user_id = uid


User.groups = relationship(Group, secondary='group_user')
User.config = relationship(UserConfig, uselist=False, lazy='subquery')
Group.users = relationship(User, secondary='group_user')



def populate_groups(session):
    groups = ['admin', 'editor', 'manager']
    for gname in groups:
        try:
            with transaction.manager:
                group = Group(gname)
                session.add(group)
        except IntegrityError:
            pass


def populate_users(session, admin_username='admin'):
    from ..util import encrypt_password
    with transaction.manager:
        users = [admin_username]
        # Using id_count to presume
        # the user's id, which should work
        # when filling an empty database.
        for uname in users:
            user = User(uname)
            user.password = encrypt_password(uname)
            session.add(user)
            
def populate_usergroups(session):
    with transaction.manager:
        admins = [(1, 1)]  # admin user should be 1
        ulist = admins
        for gid, uid in ulist:
            row = UserGroup(gid, uid)
            session.add(row)


def populate(session, admin_username='admin'):
    # populate groups
    try:
        populate_groups(session)
    except IntegrityError:
        transaction.abort()
    # populate users
    try:
        populate_users(session, admin_username=admin_username)
    except IntegrityError:
        transaction.abort()
    # add users to groups
    try:
        populate_usergroups(session)
    except IntegrityError:
        transaction.abort()

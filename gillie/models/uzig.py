# ... your DBSession and base gets created in your favourite framework ...

import ziggurat_foundations.models
from ziggurat_foundations.models.base import BaseModel
from ziggurat_foundations.models.external_identity import ExternalIdentityMixin
from ziggurat_foundations.models.group import GroupMixin
from ziggurat_foundations.models.group_permission import GroupPermissionMixin
from ziggurat_foundations.models.group_resource_permission import GroupResourcePermissionMixin
from ziggurat_foundations.models.resource import ResourceMixin
from ziggurat_foundations.models.user import UserMixin
from ziggurat_foundations.models.user_group import UserGroupMixin
from ziggurat_foundations.models.user_permission import UserPermissionMixin
from ziggurat_foundations.models.user_resource_permission import UserResourcePermissionMixin
from ziggurat_foundations import ziggurat_model_init
import sqlalchemy as sa

from .meta import Base


# this is needed for pylons 1.0 / akhet approach to db session
#ziggurat_foundations.models.DBSession = DBSession
# optional for folks who pass request.db to model methods

# Base is sqlalchemy's Base = declarative_base() from your project
class Group(GroupMixin, Base):
    pass

class GroupPermission(GroupPermissionMixin, Base):
    pass

class UserGroup(UserGroupMixin, Base):
    pass

class GroupResourcePermission(GroupResourcePermissionMixin, Base):
    pass

class Resource(ResourceMixin, Base):
    # ... your own properties....

    # example implementation of ACLS for pyramid application
    @property
    def __acl__(self):
        acls = []

        if self.owner_user_id:
            acls.extend([(Allow, self.owner_user_id, ALL_PERMISSIONS,), ])

        if self.owner_group_id:
            acls.extend([(Allow, "group:%s" % self.owner_group_id,
                          ALL_PERMISSIONS,), ])
        return acls

class UserPermission(UserPermissionMixin, Base):
    pass

class UserResourcePermission(UserResourcePermissionMixin, Base):
    pass

class User(UserMixin, Base):
    # ... your own properties....
    name = sa.Column(sa.UnicodeText())

class ExternalIdentity(ExternalIdentityMixin, Base):
    pass

# you can define multiple resource derived models to build a complex
# application like CMS, forum or other permission based solution

class Entry(Resource):
    """
    Resource of `entry` type
    """

    __tablename__ = 'entries'
    __mapper_args__ = {'polymorphic_identity': 'entry'}

    resource_id = sa.Column(sa.Integer(),
                            sa.ForeignKey('resources.resource_id',
                                          onupdate='CASCADE',
                                          ondelete='CASCADE', ),
                            primary_key=True, )
    # ... your own properties....
    some_property = sa.Column(sa.UnicodeText())


ziggurat_model_init(User, Group, UserGroup, GroupPermission, UserPermission,
               UserResourcePermission, GroupResourcePermission, Resource,
               ExternalIdentity, passwordmanager=None)
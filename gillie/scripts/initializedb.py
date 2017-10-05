import os
import sys
import transaction

from pyramid.paster import (
    get_appsettings,
    setup_logging,
    )

from pyramid.scripts.common import parse_vars

from ..models.meta import Base
from ..models import (
    get_engine,
    get_session_factory,
    get_tm_session,
    )
from ..models import MyModel
from ..models.uzig import User, Group, UserGroup



def usage(argv):
    cmd = os.path.basename(argv[0])
    print('usage: %s <config_uri> [var=value]\n'
          '(example: "%s development.ini")' % (cmd, cmd))
    sys.exit(1)


def main(argv=sys.argv):
    if len(argv) < 2:
        usage(argv)
    config_uri = argv[1]
    options = parse_vars(argv[2:])
    setup_logging(config_uri)
    settings = get_appsettings(config_uri, options=options)

    engine = get_engine(settings)
    Base.metadata.create_all(engine)

    session_factory = get_session_factory(engine)

    with transaction.manager:
        dbsession = get_tm_session(session_factory, transaction.manager)

        model = MyModel(name='one', value=1)
        dbsession.add(model)


        admins = Group(group_name="admins")
        dbsession.add(admins)
        print 'ADMINS', admins
        #admins = dbsession.merge(admins)
        dbsession.flush()
        
        user = User(user_name='admin', name='Admin User',
                    email='admin@localhost')
        dbsession.add(user)
        dbsession.flush()
        user.set_password('admin')
        user.regenerate_security_code()
        dbsession.flush()
        
        print user, admins
        group_entry = UserGroup(group_id=admins.id, user_id=user.id)
        dbsession.add(group_entry)
        

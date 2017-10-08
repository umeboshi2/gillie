from pyramid.response import Response
from pyramid.view import view_config
import pyramid.httpexceptions as exc

from sqlalchemy.exc import DBAPIError
from ziggurat_foundations.models.services.user import UserService

from ..models.uzig import User

#{uid: 1, username: "admin", name: "Admin User", iat: 1507158526, exp: 1507162126}

def authenticate(request, login, password):
    users = UserService()
    user = users.by_user_name(login, db_session=request.dbsession)
    return user

def make_token(request, user):
    groups = [g.group_name for g in user.groups]
    claims = dict(name=user.name, user_name=user.user_name,
                  email=user.email, uid=user.id, groups=groups)
    return request.create_jwt_token(user.id, **claims)

def login(request):
    login = request.POST['username']
    password = request.POST['password']
    user = authenticate(request, login, password)
    if user:
        return {
            'result': 'ok',
            'token': make_token(request, user)
        }
    else:
        raise exc.HTTPUnauthorized()


def refresh(request):
    if request.authenticated_userid:
        user = request.user
        return dict(result='ok',
                    token=make_token(request, user),
        )
    else:
        raise exc.HTTPUnauthorized()
    

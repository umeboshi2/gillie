from pyramid.response import Response
from pyramid.view import view_config

from sqlalchemy.exc import DBAPIError
from ziggurat_foundations.models.services.user import UserService

from ..models.uzig import User

def authenticate(request, login, password):
    return 'user_id'

def make_token(request, user_id):
    return request.create_jwt_token(user_id, 100, name='user_id')

def login(request):
    login = request.POST['username']
    password = request.POST['password']
    user_id = authenticate(request, login, password)
    if user_id:
        return {
            'result': 'ok',
            'token': make_token(request, user_id)
        }
    else:
        return {
            'result': 'error'
        }


def refresh(request):
    user = request.user
    print "USER", user
    return dict(result='ok',
                token=make_token(request, user),
                )

    

# basic view classes

class BaseView(object):
    def __init__(self, request):
        self.request = request
    
    def get_app_settings(self):
        return self.request.registry.settings

class BaseUserView(BaseView):
    def get_current_user_id(self):
        "Get the user id quickly without db query"
        if 'user' not in self.request.session:
            return None
        return self.request.session['user'].id

    def get_current_user(self):
        "Get user db object"
        if 'user' not in self.request.session:
            return None
        db = self.request.dbsession
        user_id = self.request.session['user'].id
        return db.query(self.usermodel).get(user_id)

class BaseViewCallable(BaseView):
    def __init__(self, request):
        super(BaseViewCallable, self).__init__(request)
        self.response = None
        self.data = {}
    
    def __call__(self):
        if self.response is not None:
            return self.response
        else:
            return self.data

class BaseUserViewCallable(BaseViewCallable, BaseUserView):
    pass



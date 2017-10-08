# basic view classes

class BaseView(object):
    def __init__(self, request):
        self.request = request
    
    def get_app_settings(self):
        return self.request.registry.settings

class BaseUserView(BaseView):
    def get_current_user(self):
        "Get user db object"
        return self.request.user
    
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



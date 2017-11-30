import robobrowser
from bs4 import BeautifulSoup

class BaseCollector(object):
    def __init__(self):
        self.browser = robobrowser.RoboBrowser()
        self.url = None
        self.response = None
        self.pageinfo = None
        self.content = ''
        self.soup = None

    def _make_soup(self, content):
        return BeautifulSoup(content, 'lxml')
    
    def retrieve_page(self, url=None):
        if url is None:
            if self.url is None:
                raise RuntimeError("No url set.")
            url = self.url
        else:
            self.url = url
        self.response = self.browser.open(url)
        self.info = self.browser.response.headers
        self.content = self.browser.response.content
        self.soup = self.browser.parsed

    def set_url(self, url):
        self.url = url
        self.response = None
        self.pageinfo = None
        self.content = ''
        self.soup = None

    def collect(self):
        pass



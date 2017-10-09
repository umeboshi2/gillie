import os
import urlparse

import mechanize
from bs4 import BeautifulSoup

from .basecollector import BaseCollector
from .cachecollector import BaseCacheCollector

url_prefix = 'http://en.wikipedia.org/wiki/'


def clear_elements(soup, selector):
    elements = soup.select(selector)
    while len(elements):
        element = elements.pop()
        element.clear()
        

def cleanup_wiki_page(content):
    soup = BeautifulSoup(content, 'lxml')
    for cid in ['siteSub', 'contentSub', 'jump-to-nav', 'firstHeading',
                'mw-navigation', 'mw-hidden-catlinks', 'footer-places',
                'footer-icons']:
        selector = '#%s' % cid
        clear_elements(soup, selector)
    for classid in ['mw-editsection',]:
        selector = '.%s' % classid
        clear_elements(soup, selector)
    anchors = soup.select('a')
    for anchor in anchors:
        if anchor.has_attr('href'):
            href = anchor['href']
            if href.startswith('/wiki'):
                name = os.path.split(href)[1]
                if '.' in name:
                    ext = name.split('.')[-1]
                    if ext in ['jpg', 'gif', 'png', 'jpeg']:
                        continue
                # FIXME - do something with this!
                anchor['href'] = '#wikipages/view/%s' % name
    return soup
    
class WikiCollector(BaseCollector):
    def __init__(self, cachedir='data'):
        super(WikiCollector, self).__init__()
        self.cache = BaseCacheCollector(cachedir=cachedir)
        self.pagecollector = BaseCollector()

    def _tree_url(self, genus, species):
        page = '%s_%s' % (genus.capitalize(), species)
        return os.path.join(url_prefix, page)
        
    def _get_url(self, url):
        data = self.cache.get(url)
        if data is None:
            print "Retrieving %s" % url
            self.pagecollector.retrieve_page(url)
            self.cache.save(url, self.pagecollector)
            data = self.cache.get(url)
        return data

    def get_page(self, genus, species):
        url = self._tree_url(genus, species)
        return self._get_url(url)
        
    def get_genus_page(self, genus):
        url = os.path.join(url_prefix, genus.capitalize())
        return self._get_url(url)

    def get_wiki_page(self, name):
        url = os.path.join(url_prefix, name)
        return self._get_url(url)
        
        
        



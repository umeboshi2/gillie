import os

from bs4 import BeautifulSoup
from hornstone.scrapers.base import CacheCollector


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
    for classid in ['mw-editsection']:
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
                anchor['data-orig-href'] = anchor['href']
                anchor['href'] = '#wikipages/view/%s' % name
    return soup


class WikiCollector(CacheCollector):
    def get_wiki_page(self, name):
        url = os.path.join(url_prefix, name)
        data = self.get_from_cache(url)
        if data is None:
            self.save_to_cache(url)
        return self.get_from_cache(url)

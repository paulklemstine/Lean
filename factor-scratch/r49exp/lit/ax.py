#!/usr/bin/env python3
"""arXiv API search harness. Handles the 301-on-http and the empty-body-after-N-calls."""
import sys, time, urllib.request, urllib.parse, xml.etree.ElementTree as ET, json, os

NS = {'a': 'http://www.w3.org/2005/Atom'}
CACHE = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'cache')
os.makedirs(CACHE, exist_ok=True)
DELAY = 4.0

def fetch(url, tries=4):
    key = CACHE + '/' + str(abs(hash(url))) + '.xml'
    if os.path.exists(key) and os.path.getsize(key) > 200:
        return open(key, 'rb').read()
    last = None
    for t in range(tries):
        try:
            req = urllib.request.Request(url, headers={'User-Agent': 'lit-scout/1.0 (research)'})
            with urllib.request.urlopen(req, timeout=45) as r:
                b = r.read()
            if len(b) < 200:
                raise ValueError('empty body %d bytes (throttled?)' % len(b))
            open(key, 'wb').write(b)
            return b
        except Exception as e:
            last = e
            time.sleep(20 * (t + 1))
    raise RuntimeError('fetch failed: %s -- %s' % (url, last))

def search(q, max_results=40, sort='relevance'):
    url = ('https://export.arxiv.org/api/query?search_query=' + urllib.parse.quote(q)
           + '&start=0&max_results=%d&sortBy=%s&sortOrder=descending' % (max_results, sort))
    b = fetch(url)
    root = ET.fromstring(b)
    total = root.find('{http://a9.com/-/spec/opensearch/1.1/}totalResults')
    tot = total.text if total is not None else '?'
    out = []
    for e in root.findall('a:entry', NS):
        idu = e.find('a:id', NS).text
        aid = idu.rsplit('/', 1)[-1]
        t = ' '.join(e.find('a:title', NS).text.split())
        pub = e.find('a:published', NS).text[:10]
        summ = ' '.join(e.find('a:summary', NS).text.split())
        out.append({'id': aid, 'date': pub, 'title': t, 'abs': summ})
    return tot, out

if __name__ == '__main__':
    for q in sys.argv[1:]:
        tot, res = search(q)
        print('=' * 100)
        print('QUERY: %s' % q)
        print('TOTAL: %s' % tot)
        for r in res:
            print('  %-14s %s  %s' % (r['id'], r['date'], r['title'][:110]))
        time.sleep(DELAY)

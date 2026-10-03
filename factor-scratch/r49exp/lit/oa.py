#!/usr/bin/env python3
"""OpenAlex search. Returns title, year, DOI, and inverted abstract if available."""
import sys, json, urllib.request, urllib.parse, os, time

HERE = os.path.dirname(os.path.abspath(__file__))
CACHE = os.path.join(HERE, 'oacache')
os.makedirs(CACHE, exist_ok=True)

def fetch(url, tries=3):
    key = CACHE + '/' + str(abs(hash(url))) + '.json'
    if os.path.exists(key) and os.path.getsize(key) > 20:
        return json.load(open(key))
    last = None
    for t in range(tries):
        try:
            req = urllib.request.Request(url, headers={'User-Agent': 'mailto:research@example.org'})
            with urllib.request.urlopen(req, timeout=50) as r:
                d = json.loads(r.read())
            json.dump(d, open(key, 'w'))
            return d
        except Exception as e:
            last = e; time.sleep(8 * (t + 1))
    print('  FETCHFAIL %s -- %s' % (url[:110], last))
    return None

def inv(a):
    if not a: return ''
    slots = {}
    for w, idxs in a.items():
        for ix in idxs:
            slots[ix] = w
    return ' '.join(slots[k] for k in sorted(slots))

def search(q, extra='', per=25):
    url = ('https://api.openalex.org/works?search=' + urllib.parse.quote(q)
           + '&per-page=%d&mailto=research@example.org' % per + extra)
    d = fetch(url)
    if not d: return None, []
    res = []
    for w in d.get('results', []):
        res.append({
            'title': w.get('title') or '',
            'year': w.get('publication_year'),
            'doi': (w.get('doi') or ''),
            'venue': ((w.get('primary_location') or {}).get('source') or {}).get('display_name') or '',
            'abs': inv(w.get('abstract_inverted_index'))[:1200],
        })
    return d.get('meta', {}).get('count'), res

if __name__ == '__main__':
    for q in sys.argv[1:]:
        c, res = search(q)
        print('=' * 100)
        print('OA QUERY: %s' % q)
        print('COUNT: %s' % c)
        for r in res:
            print('  [%s] %s | %s' % (r['year'], r['doi'], r['title'][:100]))
            if r['abs']:
                print('        %s' % r['abs'][:260])
        time.sleep(1.5)

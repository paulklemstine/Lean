import json, urllib.request

UA = {'User-Agent': 'Mozilla/5.0 (research; mailto:r48@example.com)'}

def get(url):
    req = urllib.request.Request(url, headers=UA)
    return urllib.request.urlopen(req, timeout=45).read().decode('utf8', 'replace')

for doi in ["10.1109/SFCS.2000.892128", "10.1016/S0020-0190(01)00041-2",
            "10.1109/SFCS.2000.892129", "10.1016/S0020-0190(01)00040-4"]:
    try:
        m = json.loads(get("https://api.crossref.org/works/" + doi))["message"]
        print(doi, "->", m.get("title"), "|",
              [a.get("family") for a in m.get("author", [])], "|",
              m.get("container-title"), "|", m.get("issued", {}).get("date-parts"),
              "| vol", m.get("volume"), "p", m.get("page"))
    except Exception as e:
        print(doi, "-> NOT RESOLVED", type(e).__name__)

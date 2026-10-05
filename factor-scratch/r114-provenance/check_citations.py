#!/usr/bin/env python3
"""
check_citations.py -- reusable provenance checker for the factoring campaign.

Takes (claim, identifier) pairs and re-verifies each against live bibliographic
APIs, printing a machine-readable pass/fail table.

RATIONALE (do not delete this paragraph):
  This campaign has produced fabricated citations more than once, and in every
  recorded incident the cause was a citation typed from memory rather than
  resolved against a registry.  A citation that was never fetched is not a
  citation.  This script exists so that "was it fetched?" has an answer that
  costs one command instead of an afternoon.

DESIGN RULES (learned the hard way; preserve them):
  1. NEVER type an arXiv ID / DOI from memory.  Resolve it here.
  2. Every network call has an explicit timeout.  A hanging registry must
     produce UNVERIFIED, never a silent pass and never a hang.
  3. A timeout / 404 / parse failure is UNVERIFIED, which is NOT the same as
     PASS.  Only a registry that affirmatively returns the record counts.
  4. Title comparison is fuzzy (normalised token overlap) because the campaign
     paraphrases titles; but a fuzzy match still requires the registry to have
     returned *some* record, so fuzzy can never manufacture a phantom.
  5. arXiv asks for >=3s between requests.  We batch id_list (up to 100 ids
     per call) to stay inside that while still checking hundreds of sources.

USAGE
  # check a list of identifiers, one per line, "type<TAB>identifier<TAB>claimed_title"
  python3 check_citations.py --input sources.tsv

  # check inline
  python3 check_citations.py --arxiv 2211.06821 --doi 10.1112/S1461157016000164

  # read the campaign's own PROVENANCE.md table back in
  python3 check_citations.py --from-provenance PROVENANCE.md

OUTPUT
  A table with one row per input line:
    STATUS  TYPE  IDENTIFIER  MATCH  YEAR  VENUE/TITLE-FROM-REGISTRY
  plus a trailing summary.  Exit code 0 if every row is PASS, else 1, so it can
  be dropped into CI or a pre-commit hook.

STATUS MEANINGS
  PASS        registry returned the record AND claimed title overlaps the
              registry title above --threshold
  METADATA    record exists but the claimed title does not match -- expected for
              a deliberately paraphrased claim; inspect by hand
  PHANTOM     registry affirmatively reports NO such record (arXiv empty feed /
              Crossref 404 / OpenAlex not-found)
  UNVERIFIED  network error, timeout, or unparseable response.  NOT a pass.
"""

from __future__ import annotations

import argparse
import json
import os
import re
import sys
import time
import urllib.error
import urllib.parse
import urllib.request

# ---------------------------------------------------------------- config

DEFAULT_TIMEOUT = 30          # seconds, every single call
ARXIV_BATCH = 60              # arXiv id_list batch size (< 100 hard limit)
ARXIV_SLEEP = 3.1              # arXiv API terms-of-use politeness delay
CROSSREF_SLEEP = 0.35         # Crossref polite-pool delay
OPENALEX_SLEEP = 0.15
UA = "factor-campaign-provenance-audit/1.0 (citation re-verification)"

STOP = {
    "a", "an", "the", "of", "for", "and", "on", "in", "to", "with", "via", "using",
    "from", "at", "by", "is", "are", "as", "its", "their", "our", "new", "note",
    "notes", "short", "survey", "part", "ii", "iii", "appendix", "theorem",
    "lemma", "proof", "section", "page", "pp", "vol", "no", "eds", "ed",
}


# ---------------------------------------------------------------- helpers

def fetch(url: str, timeout: int = DEFAULT_TIMEOUT):
    """GET with a hard timeout.  Returns (status, body).  Never raises."""
    req = urllib.request.Request(url, headers={"User-Agent": UA,
                                               "Accept": "application/json"})
    try:
        with urllib.request.urlopen(req, timeout=timeout) as r:
            return r.status, r.read()
    except urllib.error.HTTPError as e:
        try:
            return e.code, e.read()
        except Exception:
            return e.code, b""
    except Exception as e:                       # timeout, DNS, TLS, ...
        return None, repr(e).encode()


def norm(s: str) -> str:
    """Lowercase, strip accents/punctuation, drop stopwords, collapse space."""
    s = (s or "").lower()
    s = s.replace("&", " and ")
    s = re.sub(r"[^a-z0-9 ]+", " ", s)
    toks = [t for t in s.split() if t and t not in STOP]
    return " ".join(toks)


def title_overlap(a: str, b: str) -> float:
    """Fraction of A's content tokens present in B (and vice versa averaged).

    Symmetric containment is deliberately forgiving: the campaign paraphrases
    titles ("Rigorous Analysis of a Randomised Number Field Sieve" vs the real
    "...A Randomized Variant").  Containment, not exact match, is what
    distinguishes a real-but-paraphrased record from a wrong one.
    """
    ta, tb = set(norm(a).split()), set(norm(b).split())
    if not ta or not tb:
        return 0.0
    inter = len(ta & tb)
    return inter / min(len(ta), len(tb))


# ---------------------------------------------------------------- resolvers

def resolve_arxiv_batch(ids):
    """ids: list of bare arXiv ids (version suffix optional).

    Returns dict id -> {'ok':bool, 'title':str, 'year':int, 'venue':str,
                        'url':str, 'err':str}
    A totally empty feed is the registry saying "no such paper", i.e. PHANTOM.
    A network error is UNVERIFIED and says so.
    """
    out = {i: {"ok": False, "err": "not-queried"} for i in ids}
    url = ("https://export.arxiv.org/api/query?max_results=%d&id_list=%s"
           % (len(ids), urllib.parse.quote(",".join(ids))))
    status, body = fetch(url)
    if status != 200:
        for i in ids:
            out[i]["err"] = "http=%s %s" % (status, body[:120].decode("utf-8", "replace"))
        return out
    xml = body.decode("utf-8", "replace")
    # arXiv answers a well-formed feed with totalResults==0 when it knows of no
    # such paper.  That is an AFFIRMATIVE "no such record" -> PHANTOM.  But a
    # chunk of >1 ids returning zero entries with totalResults>0 would mean we
    # mis-parsed, so we refuse to call anything phantom in that case.
    tr = re.search(r"<opensearch:totalResults[^>]*>(\d+)</opensearch:totalResults>", xml)
    total = int(tr.group(1)) if tr else None
    entries = re.findall(r"<entry>(.*?)</entry>", xml, re.S)
    definitive_none = (total == 0) or (len(ids) == 1 and total == 0)
    got = {}
    for e in entries:
        aid = re.search(r"<id>http://arxiv\.org/abs/([^<]+)</id>", e)
        if not aid:
            continue
        base = re.sub(r"v\d+$", "", aid.group(1).strip())
        t = re.search(r"<title>(.*?)</title>", e, re.S)
        p = re.search(r"<published>(\d{4})", e)
        jr = re.search(r'<arxiv:journal_ref[^>]*>(.*?)</arxiv:journal_ref>', e, re.S)
        doi = re.search(r'<arxiv:doi[^>]*>(.*?)</arxiv:doi>', e, re.S)
        got[base] = {
            "title": re.sub(r"\s+", " ", t.group(1)).strip() if t else "",
            "authors": re.findall(r"<name>(.*?)</name>", e, re.S),
            "year": int(p.group(1)) if p else 0,
            "venue": ("journal-ref: " + re.sub(r"\s+", " ", jr.group(1)).strip())
                     if jr else ("doi: " + doi.group(1).strip() if doi
                                else "arXiv preprint (no journal-ref)"),
            "url": "https://arxiv.org/abs/" + base,
        }
    for i in ids:
        base = re.sub(r"v\d+$", "", i)
        if base in got:
            out[i] = {"ok": True, "err": "", **got[base]}
        elif definitive_none:
            out[i] = {"ok": False, "phantom": True,
                      "err": "arXiv feed reports totalResults=0 for this id"}
        else:
            out[i]["err"] = ("arXiv feed returned %s entries (totalResults=%s) and "
                             "none matched this id -- retrying singly"
                             % (len(entries), total))
    # Retry individually anything the batch failed to resolve.  arXiv's id_list
    # returns HTTP 400 for some old-style ids (quant-ph/YYMMNNNN) when they are
    # mixed with modern ones in the same request, yet serves them fine alone --
    # so a batch 400 must never be reported as a verdict.
    need = [i for i in ids if not out[i].get("ok") and not out[i].get("phantom")]
    for i in need:
        time.sleep(ARXIV_SLEEP)
        one = resolve_arxiv_batch([i])
        if one[i].get("ok") or one[i].get("phantom"):
            out[i] = one[i]
    return out


def resolve_doi(doi):
    """Crossref first, OpenAlex as a fallback.  Affirmative-not-found => PHANTOM."""
    d = doi.strip()
    url = "https://api.crossref.org/works/" + urllib.parse.quote(d, safe="")
    status, body = fetch(url)
    if status == 200:
        try:
            m = json.loads(body)["message"]
            return {"ok": True, "err": "", "registry": "crossref",
                    "title": (m.get("title") or [""])[0],
                    "year": (m.get("issued", {}).get("date-parts") or [[0]])[0][0],
                    "venue": (m.get("container-title") or
                               (m.get("event", {}) or {}).get("name") or [""])[0],
                    "url": "https://doi.org/" + d}
        except Exception as e:
            cr_err = "crossref-parse:%r" % (e,)
    else:
        cr_err = "crossref http=%s" % status
    time.sleep(OPENALEX_SLEEP)
    url = "https://api.openalex.org/works/doi:" + urllib.parse.quote(d, safe="")
    status, body = fetch(url)
    if status == 200:
        try:
            w = json.loads(body)
            loc = (w.get("primary_location") or {}).get("source") or {}
            return {"ok": True, "err": "", "registry": "openalex",
                    "title": w.get("title") or "",
                    "year": w.get("publication_year") or 0,
                    "venue": loc.get("display_name") or "",
                    "url": w.get("doi") and ("https://doi.org/" + d) or w.get("id", "")}
        except Exception as e:
            return {"ok": False, "err": "%s; openalex-parse:%r" % (cr_err, e)}
    # 404 on both registries is an affirmative "no such DOI"
    if cr_err.endswith("http=404") and status == 404:
        return {"ok": False, "phantom": True,
                "err": "crossref 404 AND openalex 404"}
    return {"ok": False, "err": "%s; openalex http=%s" % (cr_err, status)}


# ---------------------------------------------------------------- driver

def classify(kind, ident, claimed, rec, threshold):
    """-> (STATUS, MATCH, REC)"""
    if not rec.get("ok"):
        return ("PHANTOM" if rec.get("phantom") else "UNVERIFIED", 0.0, rec)
    if not claimed:
        return ("PASS", 1.0, rec)
    ov = title_overlap(claimed, rec.get("title", ""))
    st = "PASS" if ov >= threshold else "METADATA"
    return (st, ov, rec)


def run(rows, threshold, timeout, verbose):
    """rows: list of (kind, ident, claimed).  Returns list of result dicts."""
    arxiv_rows = [r for r in rows if r[0] == "arxiv"]
    others = [r for r in rows if r[0] != "arxiv"]
    results = {}

    # --- arXiv, batched
    seen, order = set(), []
    for _, i, _c in arxiv_rows:
        b = re.sub(r"^ar[xX]iv:", "", i).strip()
        b = re.sub(r"v\d+$", "", b)
        if b not in seen:
            seen.add(b)
            order.append(b)
    for n in range(0, len(order), ARXIV_BATCH):
        chunk = order[n:n + ARXIV_BATCH]
        got = resolve_arxiv_batch(chunk)
        for b in chunk:
            results[("arxiv", b)] = got[b]
        sys.stderr.write("  arxiv: %d/%d queried\n"
                         % (min(n + ARXIV_BATCH, len(order)), len(order)))
        if n + ARXIV_BATCH < len(order):
            time.sleep(ARXIV_SLEEP)

    for kind, ident, claimed in arxiv_rows:
        b = re.sub(r"^ar[xX]iv:", "", ident).strip()
        rec = results[("arxiv", re.sub(r"v\d+$", "", b))]
        st, ov, r = classify("arxiv", b, claimed, rec, threshold)
        results.setdefault(("row", ident, claimed), (st, ov, r))

    for kind, ident, claimed in others:
        time.sleep(CROSSREF_SLEEP if kind == "doi" else OPENALEX_SLEEP)
        rec = resolve_doi(ident) if kind == "doi" else {"ok": False,
                                                        "err": "unknown kind " + kind}
        st, ov, r = classify(kind, ident, claimed, rec, threshold)
        results.setdefault(("row", ident, claimed), (st, ov, r))

    out = []
    for kind, ident, claimed in rows:
        st, ov, r = results[("row", ident, claimed)]
        out.append({"status": st, "kind": kind, "identifier": ident,
                    "claimed_title": claimed, "match": round(ov, 3),
                    "registry_title": r.get("title", ""),
                    "year": r.get("year", ""), "venue": r.get("venue", ""),
                    "url": r.get("url", ""), "note": r.get("err", "")})
    return out


def read_provenance_table(path):
    """Pull the machine-checkable rows back out of PROVENANCE.md.

    Expected row shape (pipe table):
      | <n> | <claim> | <verdict> | <kind> | <identifier> | <url> | <quote> |
    """
    rows = []
    for ln in open(path, encoding="utf-8"):
        if not ln.startswith("|"):
            continue
        cells = [c.strip() for c in ln.strip().strip("|").split("|")]
        if len(cells) < 5:
            continue
        # find a bare arXiv id or DOI in any cell
        blob = " ".join(cells)
        m = re.search(r"(?:arxiv\.org/abs/|arXiv:?\s*)((?:\d{4}\.\d{4,5})|[a-z\-]+(?:\.[A-Z]{2})?/\d{7})(?:v\d+)?", blob, re.I)
        if m:
            rows.append(("arxiv", m.group(1), cells[1] if len(cells) > 1 else ""))
            continue
        m = re.search(r"\b(10\.\d{4,9}/[-._;()/:A-Za-z0-9]+)", blob)
        if m:
            rows.append(("doi", m.group(1).rstrip(").,;]"), cells[1] if len(cells) > 1 else ""))
    return rows


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--input", help="TSV: type<TAB>identifier<TAB>claimed_title")
    ap.add_argument("--from-provenance", metavar="MD",
                    help="read identifiers out of a PROVENANCE.md pipe table")
    ap.add_argument("--arxiv", action="append", default=[],
                    help="bare arXiv id (repeatable)")
    ap.add_argument("--doi", action="append", default=[],
                    help="DOI (repeatable)")
    ap.add_argument("--threshold", type=float, default=0.60,
                    help="min normalised title containment for PASS (0.60)")
    ap.add_argument("--timeout", type=int, default=DEFAULT_TIMEOUT)
    ap.add_argument("--json", metavar="PATH", help="write full JSON results here")
    ap.add_argument("--quiet", action="store_true")
    a = ap.parse_args()

    rows = []
    if a.input:
        for ln in open(a.input, encoding="utf-8"):
            ln = ln.rstrip("\n")
            if not ln.strip() or ln.lstrip().startswith("#"):
                continue
            p = ln.split("\t")
            rows.append((p[0].strip(), p[1].strip(),
                         p[2].strip() if len(p) > 2 else ""))
    if a.from_provenance:
        rows += read_provenance_table(a.from_provenance)
    for x in a.arxiv:
        rows.append(("arxiv", x, ""))
    for x in a.doi:
        rows.append(("doi", x, ""))

    if not rows:
        ap.error("nothing to check: pass --input, --from-provenance, --arxiv or --doi")

    # de-dup identical (kind, ident, claimed) while preserving order
    seen, uniq = set(), []
    for r in rows:
        k = (r[0], r[1], r[2])
        if k not in seen:
            seen.add(k)
            uniq.append(r)

    sys.stderr.write("check_citations: %d rows (%d distinct)\n" % (len(rows), len(uniq)))
    res = run(uniq, a.threshold, a.timeout, not a.quiet)

    tally = {}
    for r in res:
        tally[r["status"]] = tally.get(r["status"], 0) + 1

    if not a.quiet:
        w = max(len(r["identifier"]) for r in res) + 2
        print("STATUS      %-*s %-6s %-4s %-5s %s" % (w, "IDENTIFIER", "KIND",
                                                     "MATCH", "YEAR", "REGISTRY TITLE / VENUE"))
        print("-" * (w + 78))
        for r in sorted(res, key=lambda x: (x["status"] != "PHANTOM",
                                           x["status"] != "UNVERIFIED",
                                           x["status"] != "METADATA", x["identifier"])):
            line = "%-11s %-*s %-6s %-4s %-5s %s" % (
                r["status"], w, r["identifier"], r["kind"],
                (("%.2f" % r["match"]) if r["match"] else "-"),
                r["year"] or "-",
                (r["registry_title"] or r["note"])[:88])
            print(line)
            if r["venue"] and r["status"] in ("PASS", "METADATA"):
                print("%-11s %s   venue: %s" % ("", " " * w, r["venue"][:80]))
        print("-" * (w + 78))
        print("SUMMARY: " + "  ".join("%s=%d" % (k, tally[k])
                                      for k in sorted(tally)))
        bad = sum(v for k, v in tally.items() if k != "PASS")
        print("VERDICT: %s" % ("CLEAN" if bad == 0
                                else "%d row(s) need human eyes" % bad))

    if a.json:
        with open(a.json, "w", encoding="utf-8") as f:
            json.dump({"threshold": a.threshold, "tally": tally,
                       "results": res}, f, indent=2, ensure_ascii=False)
        sys.stderr.write("wrote %s\n" % a.json)

    return 0 if all(r["status"] == "PASS" for r in res) else 1


if __name__ == "__main__":
    sys.exit(main())

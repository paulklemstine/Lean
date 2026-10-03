#!/usr/bin/env python3
"""arXiv search-UI + abstract fetcher (the API is 429-throttled from this host).
Usage: python3 axs.py <query> [max_results]
Writes raw HTML into the cwd and prints parsed titles/ids/abstracts."""
import re, html, subprocess, sys, time, os

UA = "Mozilla/5.0 (X11; Linux x86_64)"


def fetch(url, out):
    subprocess.run(["curl", "-sSL", "--max-time", "100", "-A", UA, url, "-o", out],
                   timeout=120)
    try:
        return open(out, encoding="utf-8", errors="replace").read()
    except FileNotFoundError:
        return ""


def strip(h):
    return html.unescape(re.sub("<[^>]+>", " ", h)).strip()


def abstract(t):
    m = re.search(r'<blockquote class="abstract mathjax">(.*?)</blockquote>', t, re.S)
    return strip(m.group(1)) if m else ""


def meta(t, key):
    return [m.group(1) for m in re.finditer(key + r'" content="([^"]*)"', t)]


def search(q, n=25):
    t = fetch(f"https://arxiv.org/search/?searchtype=all&query={q}", "_s.html")
    ids = []
    for m in re.finditer(
            r'<a href="https://arxiv.org/abs/([0-9.v]+)"', t):
        if m.group(1) not in ids:
            ids.append(m.group(1))
    blocks = re.findall(r'<li class="arxiv-result">(.*?)</li>', t, re.S)
    out = []
    for b in blocks:
        i = re.search(r'arxiv.org/abs/([0-9.v]+)', b)
        ti = re.search(r'<p class="title is-5 mathjax">(.*?)</p>', b, re.S)
        ab = re.search(r'<span class="abstract-full[^"]*"[^>]*>(.*?)</span>', b, re.S)
        au = re.findall(r'<a href="https://arxiv.org/search/?searchtype=author[^"]*">([^<]*)</a>', b)
        out.append(dict(id=i.group(1) if i else None,
                        title=strip(ti.group(1)) if ti else None,
                        abstract=strip(ab.group(1))[:1400] if ab else None,
                        authors=[a.strip() for a in au],
                        url="https://arxiv.org/abs/" + (i.group(1) if i else "")))
    return out


if __name__ == "__main__":
    q = sys.argv[1].replace(" ", "+")
    n = sys.argv[2] if len(sys.argv) > 2 else "25"
    for r in search(q, n):
        print(r["id"], "|", r["title"])
        if r["authors"]:
            print("   AUTHORS:", "; ".join(r["authors"][:8]))
        if r["abstract"]:
            print("   ABS:", r["abstract"])
        print("   URL:", r["url"])
        print()
        time.sleep(0.5)
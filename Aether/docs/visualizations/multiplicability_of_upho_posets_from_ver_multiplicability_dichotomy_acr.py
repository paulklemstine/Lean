"""Bar chart of the multiplicability dichotomy across four graphs.

Computes, for the 5-cycle, pentagonal prism, Petersen graph and Petersen line
graph, the automorphism-group order and whether a regular subgroup exists, then
plots the verdict (Cayley/multiplicable vs non-Cayley/non-multiplicable).
"""
from __future__ import annotations
from itertools import product
from typing import Dict, List, Optional, Set, Tuple
import matplotlib.pyplot as plt

Graph = Dict[int, Set[int]]
Perm = Tuple[int, ...]

def cycle_graph(n: int) -> Graph:
    return {i: {(i-1) % n, (i+1) % n} for i in range(n)}

def pentagonal_prism() -> Graph:
    g: Graph = {i: set() for i in range(10)}
    def add(u, v): g[u].add(v); g[v].add(u)
    for i in range(5):
        add(i, (i+1) % 5); add(5+i, 5+(i+1) % 5); add(i, i+5)
    return g

def petersen() -> Graph:
    g: Graph = {i: set() for i in range(10)}
    def add(u, v): g[u].add(v); g[v].add(u)
    for i in range(5):
        add(i, (i+1) % 5); add(i, i+5); add(5+i, 5+(i+2) % 5)
    return g

def line_graph(g: Graph) -> Graph:
    edges = sorted({frozenset((u, v)) for u in g for v in g[u]}, key=lambda e: sorted(e))
    idx = {e: i for i, e in enumerate(edges)}
    lg: Graph = {i: set() for i in range(len(edges))}
    for e in edges:
        for f in edges:
            if e != f and (e & f):
                lg[idx[e]].add(idx[f])
    return lg

def automorphisms(g: Graph) -> List[Perm]:
    n = len(g); deg = {v: len(g[v]) for v in g}
    image = [-1]*n; used = [False]*n; res: List[Perm] = []
    def ok(v, w):
        if deg[v] != deg[w]: return False
        return all((u in g[v]) == (image[u] in g[w]) for u in range(v))
    def bt(v):
        if v == n: res.append(tuple(image)); return
        for w in range(n):
            if not used[w] and ok(v, w):
                image[v] = w; used[w] = True; bt(v+1); used[w] = False; image[v] = -1
    bt(0); return res

def compose(p, q): return tuple(p[q[x]] for x in range(len(p)))
def fpf(p): return all(p[x] != x for x in range(len(p)))

def closure(gens, n, cap):
    elems = {tuple(range(n))}; elems.update(gens); fr = list(gens)
    while fr:
        a = fr.pop()
        for b in list(elems):
            for c in (compose(a, b), compose(b, a)):
                if c not in elems:
                    if len(elems) >= cap: return None
                    elems.add(c); fr.append(c)
    return elems

def regular(H, n):
    ident = tuple(range(n))
    return (len(H) == n and all(p == ident or fpf(p) for p in H)
            and {p[0] for p in H} == set(range(n)))

def has_regular(g: Graph) -> bool:
    n = len(g); auts = automorphisms(g); F = [p for p in auts if fpf(p)]
    for a in F:
        H = closure([a], n, n+1)
        if H and regular(H, n): return True
    for a, b in product(F, repeat=2):
        H = closure([a, b], n, n+1)
        if H and regular(H, n): return True
    return False

def main() -> None:
    graphs = [("C5", cycle_graph(5)), ("Pentagonal\nprism", pentagonal_prism()),
              ("Petersen", petersen()), ("L(Petersen)", line_graph(petersen()))]
    names, orders, cayley = [], [], []
    for nm, g in graphs:
        names.append(nm); orders.append(len(automorphisms(g))); cayley.append(has_regular(g))
    colors = ["#2a9d8f" if c else "#e76f51" for c in cayley]
    fig, ax = plt.subplots(figsize=(8, 5))
    bars = ax.bar(names, orders, color=colors)
    for bar, c in zip(bars, cayley):
        ax.text(bar.get_x() + bar.get_width()/2, bar.get_height(),
                "Cayley\n(multiplicable)" if c else "non-Cayley\n(not multiplicable)",
                ha="center", va="bottom", fontsize=9)
    ax.set_ylabel("|Aut(G)|")
    ax.set_title("Multiplicability dichotomy: regular subgroup  <=>  Cayley")
    ax.set_ylim(0, max(orders)*1.25)
    plt.tight_layout(); plt.savefig("multiplicability_dichotomy.png", dpi=150)
    print("wrote multiplicability_dichotomy.png")

if __name__ == "__main__":
    main()

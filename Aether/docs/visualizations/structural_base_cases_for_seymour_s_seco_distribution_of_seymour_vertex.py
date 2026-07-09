# Visualization: distribution of the number of Seymour vertices
# across all oriented graphs on n vertices.
import matplotlib.pyplot as plt
from itertools import product
from collections import Counter

def seymour_count(adj):
    n = len(adj); c = 0
    for v in range(n):
        first = {w for w in range(n) if adj[v][w]}
        two = set()
        for x in first:
            for w in range(n):
                if adj[x][w]: two.add(w)
        second = {w for w in two if w != v and w not in first}
        if len(first) <= len(second): c += 1
    return c

def all_oriented(n):
    pairs = [(i, j) for i in range(n) for j in range(i+1, n)]
    for ch in product((0,1,2), repeat=len(pairs)):
        arcs = set()
        for (i,j),c in zip(pairs, ch):
            if c==1: arcs.add((i,j))
            elif c==2: arcs.add((j,i))
        yield [[(u,v) in arcs for v in range(n)] for u in range(n)]

n = 4
counts = Counter(seymour_count(g) for g in all_oriented(n))
ks = sorted(counts)
plt.bar(ks, [counts[k] for k in ks])
plt.xlabel("number of Seymour vertices")
plt.ylabel("number of oriented graphs")
plt.title(f"Seymour-vertex counts over all oriented graphs on {n} vertices")
plt.tight_layout()
plt.savefig("seymour_counts.png", dpi=150)
print("saved seymour_counts.png; min count observed =", min(ks))

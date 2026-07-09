import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from itertools import combinations

def make(vertices, edges):
    adj = {v: set() for v in vertices}
    for a, b in edges:
        adj[a].add(b); adj[b].add(a)
    return set(vertices), adj

def degree(g, i): return len(g[1][i])
def deg_in(g, S, i): return sum(1 for j in g[1][i] if j in S)
def dominant(g, D): return all(degree(g, i) + deg_in(g, D, i) >= 2 for i in D)

def count_adm(g):
    V = sorted(g[0]); c = 0
    for k in range(len(V) + 1):
        for combo in combinations(V, k):
            if dominant(g, set(combo)): c += 1
    return c, 2 ** len(V)

graphs = {
    "P3": make([1,2,3], [(1,2),(2,3)]),
    "C4": make([1,2,3,4], [(1,2),(2,3),(3,4),(4,1)]),
    "K1,3": make([0,1,2,3], [(0,1),(0,2),(0,3)]),
    "P4": make([1,2,3,4], [(1,2),(2,3),(3,4)]),
    "C5": make([1,2,3,4,5], [(1,2),(2,3),(3,4),(4,5),(5,1)]),
}
names = list(graphs); adm = []; tot = []
for n in names:
    a, t = count_adm(graphs[n]); adm.append(a); tot.append(t)

x = range(len(names))
plt.figure(figsize=(8,5))
plt.bar([i-0.2 for i in x], tot, width=0.4, label="all subsets 2^|V|", color="#bbbbbb".replace(" ",""))
plt.bar([i+0.2 for i in x], adm, width=0.4, label="admissible markings", color="#2a7fff")
plt.xticks(list(x), names)
plt.ylabel("count"); plt.title("Admissible markings vs. all subsets")
plt.legend(); plt.tight_layout(); plt.savefig("admissible_landscape.png", dpi=150)
print("saved admissible_landscape.png")

import matplotlib.pyplot as plt
import numpy as np
from itertools import combinations, permutations

def make(vs, es):
    return (frozenset(vs), frozenset(frozenset(e) for e in es))

def nbrs(G, v):
    V, E = G
    return {w for w in V if w != v and frozenset((v, w)) in E}

def maxdeg(G):
    V, _ = G
    return max((len(nbrs(G, v)) for v in V), default=0)

def alpha_on(G, B):
    _, E = G
    Bl = list(B)
    for k in range(len(Bl), -1, -1):
        for s in combinations(Bl, k):
            if all(frozenset((u, w)) not in E for u, w in combinations(s, 2)):
                return k
    return 0

def elim_bags(G, order):
    V, _ = G
    adj = {v: set(nbrs(G, v)) for v in V}
    alive = set(V); bags = []
    for v in order:
        later = {w for w in adj[v] if w in alive}
        bags.append(frozenset({v} | later))
        for a, b in combinations(later, 2):
            adj[a].add(b); adj[b].add(a)
        alive.discard(v)
    return bags

def tw(G):
    Vl = list(G[0])
    return 0 if not Vl else min(max(len(b) for b in elim_bags(G, o)) - 1 for o in permutations(Vl))

def atw(G):
    Vl = list(G[0])
    return 0 if not Vl else min(max(alpha_on(G, b) for b in elim_bags(G, o)) for o in permutations(Vl))

def path(n): return make(range(n), [(i, i+1) for i in range(n-1)])
def cycle(n): return make(range(n), [(i, (i+1) % n) for i in range(n)])
def clique(n): return make(range(n), list(combinations(range(n), 2)))
def kbip(a, b): return make(range(a+b), [(i, a+j) for i in range(a) for j in range(b)])
def matching(k): return make(range(2*k), [(2*i, 2*i+1) for i in range(k)])

graphs = {'P6': path(6), 'C6': cycle(6), 'K4': clique(4), 'K5': clique(5),
          'K_{2,3}': kbip(2, 3), '3K2': matching(3)}
names = list(graphs)
tws = [tw(g) for g in graphs.values()]
atws = [atw(g) for g in graphs.values()]
x = np.arange(len(names)); w = 0.38
fig, ax = plt.subplots(figsize=(9, 5))
ax.bar(x - w/2, tws, w, label='treewidth  tw(G)', color='#3b6fb5')
ax.bar(x + w/2, atws, w, label='tree-independence  alpha-tw(G)', color='#e1812c')
ax.set_xticks(x); ax.set_xticklabels(names)
ax.set_ylabel('parameter value')
ax.set_title('Treewidth vs Tree-Independence Number (clique-blindness)')
ax.legend()
for i, (t, a) in enumerate(zip(tws, atws)):
    ax.text(i - w/2, t + 0.05, str(t), ha='center', va='bottom', fontsize=9)
    ax.text(i + w/2, a + 0.05, str(a), ha='center', va='bottom', fontsize=9)
plt.tight_layout()
plt.savefig('tw_vs_atw.png', dpi=150)
print('wrote tw_vs_atw.png')

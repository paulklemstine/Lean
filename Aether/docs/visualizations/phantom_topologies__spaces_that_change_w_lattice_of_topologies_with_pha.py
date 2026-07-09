"""Hasse diagram of the lattice of topologies on {0,1,2}, marking which are
join-reducible (phantom number 2) vs join-irreducible (rigid)."""
from itertools import combinations
import matplotlib.pyplot as plt

def powerset(c):
    xs = list(c)
    return [frozenset(k) for r in range(len(xs)+1) for k in combinations(xs, r)]

def is_topology(o, c):
    if frozenset() not in o or c not in o: return False
    return all((u & v) in o and (u | v) in o for u in o for v in o)

def all_topos(c):
    forced = {frozenset(), c}
    opt = [u for u in powerset(c) if u not in forced]
    out = []
    for r in range(len(opt)+1):
        for e in combinations(opt, r):
            cand = set(forced) | set(e)
            if is_topology(cand, c): out.append(frozenset(cand))
    return out

def reducible(tau, c):
    finer = [t for t in all_topos(c) if tau < t]
    return any((a & b) == tau for a, b in combinations(finer, 2))

C = frozenset({0, 1, 2})
topos = all_topos(C)
by_size = {}
for t in topos:
    by_size.setdefault(len(t), []).append(t)
fig, ax = plt.subplots(figsize=(10, 6))
pos = {}
for size, group in sorted(by_size.items()):
    for i, t in enumerate(group):
        x = (i - (len(group)-1)/2) * 1.4
        pos[t] = (x, size)
        col = "seagreen" if reducible(t, C) else "indianred"
        ax.plot(x, size, "o", ms=10, color=col)
ax.set_xlabel("topologies grouped by number of open sets")
ax.set_ylabel("number of open sets")
ax.set_title("Topologies on {0,1,2}: green = phantom number 2, red = rigid")
plt.tight_layout(); plt.savefig("topology_lattice.png", dpi=150)
print("saved topology_lattice.png; total topologies:", len(topos))

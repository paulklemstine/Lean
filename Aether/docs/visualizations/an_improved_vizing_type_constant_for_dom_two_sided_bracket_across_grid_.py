"""Visualization 2: the two-sided bracket for gamma(G [] H) across a family of
grid graphs P_m [] P_n, comparing max(gamma), the true product domination
number, and the cylindrification upper bound gamma(G)*|V(H)|."""
from itertools import combinations
from typing import List, Set, Tuple
import matplotlib.pyplot as plt


def path_adj(n: int) -> List[Set[int]]:
    a = [set() for _ in range(n)]
    for i in range(n - 1):
        a[i].add(i + 1); a[i + 1].add(i)
    return a


def dom_number(adj: List[Set[int]]) -> int:
    n = len(adj)
    for k in range(n + 1):
        for s in combinations(range(n), k):
            ss = set(s)
            if all(v in ss or (adj[v] & ss) for v in range(n)):
                return k
    return n


def box(ag, ah):
    ng, nh = len(ag), len(ah)
    adj = [set() for _ in range(ng * nh)]
    for a in range(ng):
        for b in range(nh):
            i = a * nh + b
            for b2 in ah[b]:
                adj[i].add(a * nh + b2)
            for a2 in ag[a]:
                adj[i].add(a2 * nh + b)
    return adj


sizes: List[int] = list(range(2, 6))
labels: List[str] = []
lowers: List[int] = []; trues: List[int] = []; uppers: List[int] = []
for n in sizes:
    g = path_adj(3); h = path_adj(n)
    gg, gh = dom_number(g), dom_number(h)
    gp = dom_number(box(g, h))
    labels.append(f"P3xP{n}")
    lowers.append(max(gg, gh)); trues.append(gp); uppers.append(gg * n)

x = range(len(labels))
fig, ax = plt.subplots(figsize=(8, 5))
ax.plot(x, lowers, "o-", label=r"lower $\max(\gamma G,\gamma H)$")
ax.plot(x, trues, "s-", label=r"true $\gamma(G\Box H)$")
ax.plot(x, uppers, "^-", label=r"upper $\gamma(G)\,|V(H)|$")
ax.set_xticks(list(x)); ax.set_xticklabels(labels)
ax.set_ylabel("domination number")
ax.set_title("Two-sided bracket for grid graphs")
ax.legend()
plt.tight_layout()
plt.savefig("bracket_grids.png", dpi=150)
print("saved bracket_grids.png")

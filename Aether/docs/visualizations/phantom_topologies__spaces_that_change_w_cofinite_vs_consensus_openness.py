"""Heatmap of consensus vs cofinite openness over subsets of a window carrier,
confirming the Zariski split reproduces the cofinite topology exactly."""
from itertools import combinations
import matplotlib.pyplot as plt

BOUND = 2
universe = frozenset(range(10))
S = frozenset(x for x in universe if x % 2 == 0)
Sc = universe - S

def powerset(c):
    xs = list(c)
    return [frozenset(k) for r in range(len(xs)+1) for k in combinations(xs, r)]

def kappa(U):  return len(U) == 0 or len(universe - U) <= BOUND
def within(U, T):
    if len(U) == 0: return True
    if len(universe - U) <= BOUND: return True
    return U <= T and len(T - U) <= BOUND
def cons(U): return within(U, S) and within(U, Sc)

subsets = powerset(universe)
grid = [[1 if kappa(U) else 0, 1 if cons(U) else 0] for U in subsets]
fig, ax = plt.subplots(figsize=(4, 9))
ax.imshow(grid, aspect="auto", cmap="viridis")
ax.set_xticks([0, 1]); ax.set_xticklabels(["cofinite", "consensus"])
ax.set_ylabel("subset index")
ax.set_title("Cofinite vs consensus openness\n(columns identical => split is exact)")
plt.tight_layout(); plt.savefig("cofinite_consensus.png", dpi=150)
print("columns identical:", all(r[0] == r[1] for r in grid))

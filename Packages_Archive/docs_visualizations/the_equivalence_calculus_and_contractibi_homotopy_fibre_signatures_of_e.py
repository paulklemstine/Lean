"""Visualization: the homotopy-fibre signature of a map.

Renders, for several maps f : {0,1,2,3} -> {a,b,c,d}, the size of each
homotopy fibre f^{-1}(y).  An all-ones profile (every bar = 1) is exactly
the contractible-fibre signature of an equivalence (bijection); any taller
or empty bar certifies a failure of injectivity or surjectivity.
"""
from typing import Callable, Dict, List
import matplotlib.pyplot as plt

DOMAIN = [0, 1, 2, 3]
CODOMAIN = ["a", "b", "c", "d"]

def fibre_sizes(f: Callable[[int], str]) -> Dict[str, int]:
    sizes = {y: 0 for y in CODOMAIN}
    for x in DOMAIN:
        sizes[f(x)] += 1
    return sizes

maps: Dict[str, Callable[[int], str]] = {
    "equivalence (all fibres = 1)": lambda x: CODOMAIN[x],
    "collision (not injective)":    lambda x: CODOMAIN[min(x, 1)],
    "constant (not surjective)":    lambda x: "a",
}

fig, axes = plt.subplots(1, len(maps), figsize=(13, 4), sharey=True)
for ax, (title, f) in zip(axes, maps.items()):
    sizes = fibre_sizes(f)
    colors = ["#2a9d8f" if v == 1 else "#e76f51" for v in sizes.values()]
    ax.bar(list(sizes.keys()), list(sizes.values()), color=colors)
    ax.axhline(1.0, ls="--", lw=1, color="gray")
    ax.set_title(title, fontsize=10)
    ax.set_xlabel("target point y")
    ax.set_ylim(0, 4)
axes[0].set_ylabel("|fibre f^{-1}(y)|")
fig.suptitle("Homotopy-fibre signatures: equivalence <=> every fibre contractible",
             fontsize=12)
plt.tight_layout()
plt.savefig("fibre_signatures.png", dpi=150)
print("wrote fibre_signatures.png")

#!/usr/bin/env python3
"""Visualize the chain structure of closed sets for a valuation closure."""
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np

def valuation_closure_sets(v, universe):
    from itertools import combinations
    subsets = [frozenset()]
    for r in range(1, len(universe)+1):
        for c in combinations(universe, r):
            subsets.append(frozenset(c))
    def cl(s):
        if not s:
            return frozenset(x for x in universe if v[x] <= 0)
        threshold = max(v[x] for x in s)
        return frozenset(x for x in universe if v[x] <= threshold)
    closed = [s for s in subsets if cl(s) == s]
    return closed, cl

universe = [0, 1, 2, 3, 4]
v = {0: 2, 1: 5, 2: 1, 3: 3, 4: 5}
closed_sets, cl = valuation_closure_sets(v, universe)
closed_sets.sort(key=len)

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Left: valuation bar chart
elements = sorted(universe)
values = [v[e] for e in elements]
colors = plt.cm.viridis(np.array(values) / max(values))
ax1.bar([str(e) for e in elements], values, color=colors, edgecolor="black")
ax1.set_xlabel("Element", fontsize=12)
ax1.set_ylabel("Gauge Value v(x)", fontsize=12)
ax1.set_title("Gauge Valuation", fontsize=14)
for i, (e, val) in enumerate(zip(elements, values)):
    ax1.text(i, val + 0.1, str(val), ha="center", va="bottom", fontsize=11)

# Right: chain of closed sets
y_positions = list(range(len(closed_sets)))
for i, s in enumerate(closed_sets):
    label = str(set(s)) if s else "{}"
    sup = max((v[x] for x in s), default=0)
    rect = mpatches.FancyBboxPatch((0.1, i - 0.3), 0.8, 0.6,
                                    boxstyle="round,pad=0.05",
                                    facecolor=plt.cm.Blues(0.2 + 0.6 * i / len(closed_sets)),
                                    edgecolor="black", linewidth=1.5)
    ax2.add_patch(rect)
    ax2.text(0.5, i, f"{label}\nlevel ≤ {sup}", ha="center", va="center", fontsize=9)
    if i > 0:
        ax2.annotate("", xy=(0.5, i - 0.35), xytext=(0.5, i - 0.65),
                     arrowprops=dict(arrowstyle="->", lw=1.5, color="gray"))

ax2.set_xlim(-0.1, 1.1)
ax2.set_ylim(-0.5, len(closed_sets) - 0.5)
ax2.set_title("Chain of Closed Sets (nested)", fontsize=14)
ax2.axis("off")

plt.suptitle("Closure–Gauge Realization Duality", fontsize=16, fontweight="bold")
plt.tight_layout()
plt.savefig("closure_gauge_chain.png", dpi=150, bbox_inches="tight")
print("Saved closure_gauge_chain.png")

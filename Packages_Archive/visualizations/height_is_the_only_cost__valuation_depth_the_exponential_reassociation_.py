"""Visualize the exponential reassociation gap: balanced vs caterpillar depth."""
import matplotlib.pyplot as plt
from math import log2

ns = list(range(1, 11))
leaves = [2 ** n for n in ns]
balanced_depth = [n for n in ns]                 # log2(2^n)
caterpillar_depth = [2 ** n - 1 for n in ns]     # numLeaves - 1

fig, ax = plt.subplots(figsize=(8, 5))
ax.plot(leaves, balanced_depth, "o-", label="balanced (height = ceil log2 m)")
ax.plot(leaves, caterpillar_depth, "s-", label="caterpillar (height = m - 1)")
ax.set_xscale("log", base=2)
ax.set_yscale("log", base=2)
ax.set_xlabel("number of leaves m (log scale)")
ax.set_ylabel("evaluated depth (log scale)")
ax.set_title("Height is the only cost: log2(m) <= height <= m - 1")
ax.legend()
ax.grid(True, which="both", alpha=0.3)
fig.tight_layout()
fig.savefig("reassociation_gap.png", dpi=150)
print("wrote reassociation_gap.png")

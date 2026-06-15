"""Plot the search dimension and the subcritical decay of success ratios."""
from __future__ import annotations
import math
import matplotlib.pyplot as plt

def search_dimension(b: int, k: int) -> float:
    return math.log(k) / math.log(b)

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

# Left: dimension vs survival count for several branching factors.
for b in (4, 8, 16, 32):
    ks = list(range(1, b + 1))
    ds = [search_dimension(b, k) for k in ks]
    ax1.plot([k / b for k in ks], ds, marker="o", label=f"b={b}")
ax1.axhline(1.0, color="grey", ls="--", lw=0.8)
ax1.set_xlabel("survival fraction k / b")
ax1.set_ylabel("search dimension D = log k / log b")
ax1.set_title("Difficulty scale: D in [0, 1], D=1 only at k=b")
ax1.legend()

# Right: subcritical decay of the success ratio (k/b)^d.
for (b, k) in [(5, 3), (5, 4), (8, 3), (8, 7)]:
    ds = list(range(1, 11))
    ratios = [(k ** d) / (b ** d) for d in ds]
    ax2.semilogy(ds, ratios, marker="s",
                 label=f"b={b}, k={k} (D={search_dimension(b,k):.2f})")
ax2.set_xlabel("search depth d")
ax2.set_ylabel("success ratio (k/b)^d  (log scale)")
ax2.set_title("Subcritical decay: needle vs haystack")
ax2.legend()

fig.tight_layout()
fig.savefig("fractal_proof_search.png", dpi=150)
print("saved fractal_proof_search.png")

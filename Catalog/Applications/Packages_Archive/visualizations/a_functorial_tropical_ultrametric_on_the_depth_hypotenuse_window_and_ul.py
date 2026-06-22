"""Matplotlib visualization of the depth-hypotenuse window and the boundary
ultrametric tiering. Saves berggren_visualization.png."""
from typing import List, Tuple
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

Triple = Tuple[int, int, int]


def child_b(t: Triple) -> Triple:
    a, b, c = t
    return (a + 2 * b + 2 * c, 2 * a + b + 2 * c, 2 * a + 2 * b + 3 * c)


depths: List[int] = list(range(8))
c_vals: List[int] = []
t: Triple = (3, 4, 5)
for _ in depths:
    c_vals.append(t[2])
    t = child_b(t)

lo = [5 * 3 ** n for n in depths]
hi = [5 * 7 ** n for n in depths]

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5))

ax1.fill_between(depths, lo, hi, alpha=0.2, color="tab:blue",
                 label=r"window $[5\cdot 3^n,\,5\cdot 7^n]$")
ax1.plot(depths, c_vals, "o-", color="tab:red", label="hypotenuse along all-B ray")
ax1.set_yscale("log")
ax1.set_xlabel("tree depth n")
ax1.set_ylabel("hypotenuse c (log scale)")
ax1.set_title("Two-sided depth-hypotenuse law")
ax1.legend()
ax1.grid(True, which="both", alpha=0.3)

# ultrametric distance tiers: d = (1/2)^k
ks = list(range(8))
ds = [0.5 ** k for k in ks]
ax2.stem(ks, ds)
ax2.set_xlabel("first-disagreement index k")
ax2.set_ylabel(r"distance $d = (1/2)^k$")
ax2.set_title("Discrete distance tiers of the tree ultrametric")
ax2.grid(True, alpha=0.3)

fig.tight_layout()
fig.savefig("berggren_visualization.png", dpi=130)
print("saved berggren_visualization.png")

"""Visualization: the c=1 phase transition of Rademacher complexity with depth,
and the resulting generalization bound. Saves rademacher_depth.png."""
from itertools import product
from math import sqrt, log
from typing import List, Sequence, Tuple
import matplotlib.pyplot as plt

Vector = Tuple[float, ...]

def emp_rad(klass: Sequence[Vector]) -> float:
    n = len(klass[0])
    if n == 0:
        return 0.0
    total = 0.0
    for signs in product((-1.0, 1.0), repeat=n):
        total += max(sum(s * x for s, x in zip(signs, a)) / n for a in klass)
    return total / (2 ** n)

def scale(klass: Sequence[Vector], c: float) -> List[Vector]:
    return [tuple(c * x for x in a) for a in klass]

def deep(klass: Sequence[Vector], c: float, L: int) -> List[Vector]:
    out = [tuple(a) for a in klass]
    for _ in range(L):
        out = scale(out, c)
    return out

def gen_gap(R: float, n: int, delta: float) -> float:
    return 2.0 * R + 3.0 * sqrt(log(2.0 / delta) / (2.0 * n))

A = [(1.0, 0.0, 0.0, 0.0), (0.0, 1.0, 0.0, 0.0), (1.0, -1.0, 0.5, 0.0)]
depths = list(range(0, 9))
factors = [0.6, 0.8, 1.0, 1.2]

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))
for c in factors:
    rad = [emp_rad(deep(A, c, L)) for L in depths]
    style = "--" if c > 1 else "-"
    ax1.plot(depths, rad, style, marker="o", label=f"c = {c}")
    ax2.plot(depths, [gen_gap(r, 1000, 0.05) for r in rad], style, marker="o",
             label=f"c = {c}")

ax1.axhline(emp_rad(A), color="gray", ls=":", lw=1)
ax1.set_title("Rademacher complexity vs depth  (exact c^L law)")
ax1.set_xlabel("depth L"); ax1.set_ylabel("empRad"); ax1.legend(); ax1.grid(alpha=0.3)
ax2.set_title("Generalization bound vs depth  (n=1000, delta=0.05)")
ax2.set_xlabel("depth L"); ax2.set_ylabel("genGap"); ax2.legend(); ax2.grid(alpha=0.3)
fig.suptitle("c < 1 contracts (normalized: safer with depth);  c > 1 explodes")
fig.tight_layout()
fig.savefig("rademacher_depth.png", dpi=150)
print("saved rademacher_depth.png")

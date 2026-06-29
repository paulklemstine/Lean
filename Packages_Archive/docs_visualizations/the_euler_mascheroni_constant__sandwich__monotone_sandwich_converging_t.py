"""Visualization: the monotone sandwich closing on gamma, and the
positive-term series partial sums. Saves euler_mascheroni_sandwich.png."""
from __future__ import annotations
import math
import matplotlib.pyplot as plt

GAMMA: float = 0.5772156649015329

def harmonic(n: int) -> float:
    return sum(1.0 / k for k in range(1, n + 1))

ns: list[int] = list(range(1, 41))
a = [harmonic(n) - math.log(n + 1) for n in ns]   # lower fence a_n
b = [harmonic(n) - math.log(n) for n in ns]       # upper fence b_n

fig, ax = plt.subplots(figsize=(9, 5.5))
ax.plot(ns, b, "o-", color="#c0392b", label=r"$b_n=H_n-\ln n$ (upper, decreasing)")
ax.plot(ns, a, "s-", color="#2980b9", label=r"$a_n=H_n-\ln(n+1)$ (lower, increasing)")
ax.fill_between(ns, a, b, color="#f1c40f", alpha=0.25, label="bracket containing $\\gamma$")
ax.axhline(GAMMA, color="black", ls="--", lw=1, label=rf"$\gamma={GAMMA:.10f}$")
ax.set_xlabel("n")
ax.set_ylabel("value")
ax.set_title("Monotone sandwich converging to the Euler--Mascheroni constant")
ax.legend(loc="upper right", fontsize=9)
ax.grid(alpha=0.3)
fig.tight_layout()
fig.savefig("euler_mascheroni_sandwich.png", dpi=150)
print("saved euler_mascheroni_sandwich.png")

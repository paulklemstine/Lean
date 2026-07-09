"""Visualization: the sparse-threshold sandwich for the fractional independence number.

Generates a figure showing, as a function of the number of vertices n:
  * the universal ceiling  alpha* <= n            (Theorem alphaStar_le_card),
  * the universal floor     n/2 <= alpha*          (Theorem half_card_le_alphaStar),
  * the single-edge ceiling alpha* <= n-1          (alphaStar_le_card_sub_one_of_edge),
  * the exact complete-graph value alpha*(K_n)=n/2 (alphaStar_completeGraph),
sitting exactly on the floor.

Run:  python _pkg_viz.py   (writes sandwich.png if matplotlib is available)
"""

from __future__ import annotations

import matplotlib.pyplot as plt

ns: list[int] = list(range(2, 13))
ceiling: list[float] = [float(n) for n in ns]
edge_ceiling: list[float] = [n - 1.0 for n in ns]
floor: list[float] = [n / 2.0 for n in ns]
complete: list[float] = [n / 2.0 for n in ns]  # alpha*(K_n) = n/2

fig, ax = plt.subplots(figsize=(8, 5))
ax.fill_between(ns, floor, ceiling, alpha=0.12, color="tab:blue",
                label=r"feasible band $n/2 \leq \alpha^* \leq n$")
ax.plot(ns, ceiling, "--", color="gray", label=r"ceiling $\alpha^* \leq n$")
ax.plot(ns, edge_ceiling, "-.", color="tab:orange",
        label=r"single-edge ceiling $\alpha^* \leq n-1$")
ax.plot(ns, floor, "-", color="tab:blue", label=r"floor $n/2 \leq \alpha^*$")
ax.plot(ns, complete, "o", color="tab:red", markersize=8,
        label=r"$\alpha^*(K_n) = n/2$ (on the floor)")

ax.set_xlabel("number of vertices  n")
ax.set_ylabel(r"$\alpha^*$")
ax.set_title("The sparse-threshold sandwich for the fractional independence number")
ax.legend(loc="upper left", fontsize=9)
ax.grid(True, alpha=0.3)
fig.tight_layout()
fig.savefig("sandwich.png", dpi=150)
print("wrote sandwich.png")

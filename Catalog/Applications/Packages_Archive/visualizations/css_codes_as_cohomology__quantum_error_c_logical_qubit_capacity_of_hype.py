"""Visualize beta_1(Q_n), the logical-qubit count of hypercube codes."""
from __future__ import annotations
from typing import List
import matplotlib.pyplot as plt

def hypercube_betti1(n: int) -> int:
    return n * (1 << (n - 1)) - (1 << n) + 1

ns: List[int] = list(range(1, 9))
betti: List[int] = [hypercube_betti1(n) for n in ns]

fig, ax = plt.subplots(figsize=(8, 5))
ax.plot(ns, betti, "o-", color="#5b2a86", linewidth=2, markersize=8,
        label=r"$\beta_1(Q_n)=n\,2^{n-1}-2^n+1$")
ax.axhline(1, color="gray", linestyle="--", linewidth=1)
ax.annotate("Q_2: 1 logical qubit", xy=(2, 1), xytext=(2.4, 12),
            arrowprops=dict(arrowstyle="->"))
for n, b in zip(ns, betti):
    ax.annotate(str(b), (n, b), textcoords="offset points", xytext=(0, 8),
                ha="center", fontsize=9)
ax.set_yscale("log")
ax.set_xlabel("hypercube dimension n")
ax.set_ylabel(r"logical qubits  $\beta_1(Q_n)$  (log scale)")
ax.set_title("Logical-qubit capacity of hypercube codes grows like $n\,2^{n-1}$")
ax.legend()
ax.grid(True, which="both", alpha=0.3)
plt.tight_layout()
plt.savefig("hypercube_betti.png", dpi=150)
print("saved hypercube_betti.png")

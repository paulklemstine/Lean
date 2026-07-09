"""Standalone visualization: the degree-parity ledger for v' + v^2 = f.

Plots, for f = x^k, the degree of the right-hand side f*q^2 (always
deg f + 2 deg q) against the maximal degree of the cleared left-hand side
p'q - pq' + p^2, coloring odd-degree f (obstructed) vs even-degree f.
Requires matplotlib.
"""
from __future__ import annotations
import matplotlib.pyplot as plt

def rhs_degree(deg_f: int, deg_q: int) -> int:
    return deg_f + 2 * deg_q

def lhs_max_degree(deg_p: int, deg_q: int) -> int:
    # max(2 deg p, deg p + deg q - 1); the even cap is 2 deg p
    return max(2 * deg_p, deg_p + deg_q - 1)

def main() -> None:
    deg_q = 3
    ks = list(range(1, 8))
    fig, ax = plt.subplots(figsize=(8, 5))
    for k in ks:
        rd = rhs_degree(k, deg_q)
        color = "crimson" if k % 2 == 1 else "seagreen"
        ax.bar(k, rd, color=color,
               label=("odd deg f (obstructed)" if k == 1 else
                      ("even deg f (may solve)" if k == 2 else None)))
    # the even ceiling reachable by the LHS when deg p = deg q
    ceiling = 2 * deg_q
    ax.axhline(ceiling, ls="--", color="navy",
               label=f"max even LHS degree = 2*deg q = {ceiling}")
    ax.set_xlabel("k  (coefficient f = x^k)")
    ax.set_ylabel("degree of RHS  f*q^2  (deg q = %d)" % deg_q)
    ax.set_title("Degree-parity ledger: odd RHS cannot meet even LHS")
    ax.legend()
    fig.tight_layout()
    fig.savefig("parity_ledger.png", dpi=150)
    print("wrote parity_ledger.png")

if __name__ == "__main__":
    main()

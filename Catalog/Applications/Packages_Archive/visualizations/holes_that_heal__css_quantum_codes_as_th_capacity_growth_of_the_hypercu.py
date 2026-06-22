"""Visualization: capacity of the hypercube code family Q_n.

Plots the logical dimension beta_1(Q_n) = n*2^(n-1) - 2^n + 1 against n,
illustrating the strict multi-qubit growth proven for n >= 3.
Requires matplotlib.
"""
from typing import List
import matplotlib.pyplot as plt

def hypercube_betti1(n: int) -> int:
    return n * 2 ** (n - 1) - 2 ** n + 1

def main() -> None:
    ns: List[int] = list(range(1, 9))
    betti: List[int] = [hypercube_betti1(n) for n in ns]
    fig, ax = plt.subplots(figsize=(8, 5))
    ax.plot(ns, betti, "o-", lw=2, color="#5b2a86", label=r"$\beta_1(Q_n)$")
    ax.axhline(1, ls="--", color="gray", label="naive 1-qubit guess")
    for n, b in zip(ns, betti):
        ax.annotate(str(b), (n, b), textcoords="offset points", xytext=(0, 8),
                    ha="center", fontsize=9)
    ax.set_xlabel("hypercube dimension n")
    ax.set_ylabel(r"logical qubits $k = \beta_1(Q_n)$")
    ax.set_title("Capacity of homological hypercube codes grows with dimension")
    ax.set_yscale("log")
    ax.legend()
    ax.grid(True, which="both", alpha=0.3)
    fig.tight_layout()
    fig.savefig("hypercube_capacity.png", dpi=150)
    print("saved hypercube_capacity.png")

if __name__ == "__main__":
    main()

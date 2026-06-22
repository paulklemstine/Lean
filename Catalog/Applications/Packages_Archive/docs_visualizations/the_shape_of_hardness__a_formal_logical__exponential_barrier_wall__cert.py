"""Visualization: the algebraic natural-proofs barrier wall.

Plots the certified minimum separator weight 2^(c*n) (Theorem 11) against the
problem size n for several hard-class exponents c, on a logarithmic axis,
illustrating that bounded-weight proof systems are pushed to exponential cost.
Requires matplotlib.
"""
import matplotlib.pyplot as plt

def main() -> None:
    ns = list(range(1, 13))
    fig, ax = plt.subplots(figsize=(8, 5))
    for c in (1, 2, 3):
        weights = [2 ** (c * n) for n in ns]
        ax.plot(ns, weights, marker="o", label=f"c = {c}")
    ax.set_yscale("log", base=2)
    ax.set_xlabel("problem level n")
    ax.set_ylabel("certified minimum separator maxWeight  (2^(c·n))")
    ax.set_title("Algebraic Natural-Proofs Barrier (Theorem 11)")
    ax.legend()
    ax.grid(True, which="both", ls=":")
    fig.tight_layout()
    fig.savefig("barrier_wall.png", dpi=150)
    print("wrote barrier_wall.png")

if __name__ == "__main__":
    main()

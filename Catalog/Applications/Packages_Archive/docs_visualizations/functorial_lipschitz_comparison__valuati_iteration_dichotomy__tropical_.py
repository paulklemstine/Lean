"""Visualization: iteration dichotomy -- C**n blow-up vs. invariant ultrametric exponent."""
from __future__ import annotations
import matplotlib.pyplot as plt

def main() -> None:
    ns = list(range(0, 11))
    fig, ax = plt.subplots(figsize=(9, 5))
    for C in (2, 3, 4):
        ax.semilogy(ns, [C ** n for n in ns], marker="o", label=f"tropical rate C={C} -> C**n")
    ax.axhline(1.0, color="black", linestyle="--", label="ultrametric exponent C=1 (invariant)")
    ax.set_title("Iteration: multiplicative blow-up vs. ultrametric stability")
    ax.set_xlabel("iteration count n"); ax.set_ylabel("Lipschitz rate (log scale)")
    ax.legend(); ax.grid(True, alpha=0.3, which="both")
    fig.tight_layout(); fig.savefig("iteration_dichotomy.png", dpi=140)
    print("saved iteration_dichotomy.png")

if __name__ == "__main__":
    main()

"""Visualization: antichain bound vs. counting bound as functions of n."""
import matplotlib.pyplot as plt
from math import comb


def main() -> None:
    ns = list(range(1, 31))
    anti = [comb(n, n // 2) for n in ns]
    cnt = [2 ** n / (n + 1) for n in ns]
    fig, ax = plt.subplots(figsize=(9, 5))
    ax.semilogy(ns, anti, marker="o", label="antichain bound  C(n, n/2)")
    ax.semilogy(ns, cnt, marker="s", label="counting bound  2^n/(n+1)")
    ax.set_xlabel("n")
    ax.set_ylabel("lower bound (log scale)")
    ax.set_title("Two lower bounds on the chain-cover number of B_n")
    ax.legend()
    ax.grid(alpha=0.3, which="both")
    fig.tight_layout()
    fig.savefig("bounds.png", dpi=150)
    print("wrote bounds.png")


if __name__ == "__main__":
    main()

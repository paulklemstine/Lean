"""Visualization: layer profile of B_n and the peak at the middle layer."""
import matplotlib.pyplot as plt
from math import comb


def main() -> None:
    fig, ax = plt.subplots(figsize=(9, 5))
    for n in (10, 16, 24):
        ks = list(range(n + 1))
        ax.plot(ks, [comb(n, k) for k in ks], marker="o", label=f"n = {n}")
        ax.axvline(n // 2, color="gray", ls=":", alpha=0.4)
    ax.set_xlabel("layer size k = |subset|")
    ax.set_ylabel("number of subsets  C(n, k)")
    ax.set_title("Layer profile of the Boolean lattice: the bulge is the middle layer")
    ax.legend()
    ax.grid(alpha=0.3)
    fig.tight_layout()
    fig.savefig("layers.png", dpi=150)
    print("wrote layers.png")


if __name__ == "__main__":
    main()

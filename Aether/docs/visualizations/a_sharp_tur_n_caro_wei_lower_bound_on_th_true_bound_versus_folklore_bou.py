"""Visualization: true bound n^2/(2m+n) vs folklore n^2/(4m) vs n cap."""
import numpy as np
import matplotlib.pyplot as plt


def make_plot(n: int = 100) -> None:
    m = np.arange(1, n * (n - 1) // 2 + 1)
    true_bound = n ** 2 / (2 * m + n)
    folklore = n ** 2 / (4 * m)
    fig, ax = plt.subplots(figsize=(9, 5))
    ax.plot(m, true_bound, label=r"true bound $n^2/(2m+n)$", lw=2)
    ax.plot(m, folklore, label=r"folklore $n^2/(4m)$", lw=2, ls="--")
    ax.axhline(n, color="gray", ls=":", label=r"vertex cap $n$")
    ax.axvline(n / 2, color="red", ls=":", label=r"threshold $m=n/2$")
    ax.set_xlabel("number of edges m")
    ax.set_ylabel("guaranteed independent-set size")
    ax.set_title(f"Independence-number bounds, n={n}")
    ax.set_ylim(0, n * 1.3)
    ax.set_xlim(1, 3 * n)
    ax.legend()
    fig.tight_layout()
    fig.savefig("bounds_comparison.png", dpi=150)
    print("saved bounds_comparison.png")


if __name__ == "__main__":
    make_plot()

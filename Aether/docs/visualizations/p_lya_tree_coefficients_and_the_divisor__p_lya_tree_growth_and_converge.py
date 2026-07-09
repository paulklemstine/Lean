"""Visualization: Pólya-tree growth and convergence to Otter's constant.

Generates a two-panel figure:
  (left)  log-scale plot of a(n) showing near-geometric growth,
  (right) the ratio a(n+1)/a(n) approaching Otter's constant ~ 2.9557652856.

Requires matplotlib. Run: python _viz.py
"""

from typing import List

import matplotlib.pyplot as plt


def divisors(k: int) -> List[int]:
    if k <= 0:
        return []
    out: List[int] = []
    d = 1
    while d * d <= k:
        if k % d == 0:
            out.append(d)
            if d != k // d:
                out.append(k // d)
        d += 1
    return sorted(out)


def polya_tree_counts(n_max: int) -> List[int]:
    a: List[int] = [0] * (n_max + 1)
    if n_max >= 1:
        a[1] = 1
    for n in range(1, n_max):
        c = {k: sum(d * a[d] for d in divisors(k)) for k in range(1, n + 1)}
        s = sum(c[k] * a[n + 1 - k] for k in range(1, n + 1))
        a[n + 1] = s // n
    return a


def main() -> None:
    n_max = 40
    a = polya_tree_counts(n_max)
    ns = list(range(1, n_max + 1))
    counts = [a[n] for n in ns]
    ratios = [a[n + 1] / a[n] for n in range(1, n_max)]
    otter = 2.9557652856

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    ax1.semilogy(ns, counts, "o-", color="#2c7fb8")
    ax1.set_title("Pólya tree counts a(n) (A000081)")
    ax1.set_xlabel("n (number of nodes)")
    ax1.set_ylabel("a(n)  (log scale)")
    ax1.grid(True, which="both", alpha=0.3)

    ax2.plot(range(1, n_max), ratios, "s-", color="#de2d26", label="a(n+1)/a(n)")
    ax2.axhline(otter, color="black", ls="--", label=f"Otter's constant ≈ {otter}")
    ax2.set_title("Convergence to Otter's constant")
    ax2.set_xlabel("n")
    ax2.set_ylabel("a(n+1)/a(n)")
    ax2.legend()
    ax2.grid(True, alpha=0.3)

    fig.tight_layout()
    fig.savefig("polya_growth.png", dpi=150)
    print("saved polya_growth.png")


if __name__ == "__main__":
    main()

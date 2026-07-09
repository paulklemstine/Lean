"""
Visualization: bad lines on the finite torus F_p x F_p and the surviving
good multipliers.

For a prime p and a set D of nonzero displacement vectors, each vector d kills a
"bad line" { a : d1*a1 + d2*a2 = 0 (mod p) }. This script plots the union of the
bad lines (red) and the good multipliers that escape them all (green), making the
counting proof of the multiplier-avoidance theorem visible: with |D| < p the
green points are guaranteed to be non-empty.
"""

from __future__ import annotations

from itertools import product

import matplotlib.pyplot as plt


def dot_mod(d: tuple[int, int], a: tuple[int, int], p: int) -> int:
    return (d[0] * a[0] + d[1] * a[1]) % p


def main() -> None:
    p = 13
    # A set of nonzero displacement vectors with |D| = p - 1 < p.
    D: list[tuple[int, int]] = [(1, k) for k in range(1, p)]  # 12 vectors

    good_x, good_y, bad_x, bad_y = [], [], [], []
    for a1, a2 in product(range(p), range(p)):
        if all(dot_mod(d, (a1, a2), p) != 0 for d in D):
            good_x.append(a1)
            good_y.append(a2)
        else:
            bad_x.append(a1)
            bad_y.append(a2)

    fig, ax = plt.subplots(figsize=(7, 7))
    ax.scatter(bad_x, bad_y, c="#d62728", s=120, marker="x",
               label=f"bad multipliers (union of {len(D)} lines)")
    ax.scatter(good_x, good_y, c="#2ca02c", s=160, marker="o",
               edgecolors="black", label="good multipliers (escape all lines)")

    ax.set_title(f"Multiplier avoidance on $\\mathbb{{F}}_{{{p}}} \\times "
                 f"\\mathbb{{F}}_{{{p}}}$  ($|D| = {len(D)} < p = {p}$)")
    ax.set_xlabel(r"$\alpha_1$")
    ax.set_ylabel(r"$\alpha_2$")
    ax.set_xticks(range(p))
    ax.set_yticks(range(p))
    ax.set_aspect("equal")
    ax.grid(True, alpha=0.3)
    ax.legend(loc="upper center", bbox_to_anchor=(0.5, -0.08), ncol=1)
    fig.tight_layout()
    fig.savefig("multiplier_avoidance.png", dpi=150, bbox_inches="tight")
    print(f"Saved multiplier_avoidance.png ; {len(good_x)} good multipliers found.")


if __name__ == "__main__":
    main()

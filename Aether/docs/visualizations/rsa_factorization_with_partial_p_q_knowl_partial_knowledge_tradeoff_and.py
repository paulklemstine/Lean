"""Visualization: the partial-knowledge tradeoff and the perfect-square discriminant.

Generates two panels:
  (left)  largest admissible private exponent d as a function of the number of
          known most-significant bits of p+q (smaller residual Delta => larger d);
  (right) the discriminant (p+q)^2 - 4n plotted against its exact square root p-q,
          confirming it is always a perfect square.
"""

from __future__ import annotations

from math import isqrt, log2
from typing import List

import matplotlib.pyplot as plt


def largest_admissible_d(n_tilde: int, k: int, delta: int) -> int:
    """Largest d satisfying 2*d*(k*delta + 1) < n_tilde."""
    return (n_tilde - 1) // (2 * (k * delta + 1))


def main() -> None:
    # --- Panel 1: known bits vs admissible d --------------------------------
    p, q = 1009, 997
    n = p * q
    n_tilde = n + 1 - (p + q)          # perfect-estimate baseline (= phi(n))
    full_bits = (p + q).bit_length()    # total bits of p+q
    k = 1

    known_bits: List[int] = list(range(0, full_bits + 1))
    admissible: List[float] = []
    for b in known_bits:
        # knowing b MSBs of (p+q) leaves residual Delta ~ (p+q) / 2^b
        delta = max((p + q) >> b, 0)
        admissible.append(log2(max(largest_admissible_d(n_tilde, k, delta), 1)))

    # --- Panel 2: perfect-square discriminant -------------------------------
    pairs = [(13, 7), (29, 11), (61, 53), (101, 89), (1009, 997)]
    diffs = [pp - qq for pp, qq in pairs]
    roots = [isqrt((pp + qq) ** 2 - 4 * pp * qq) for pp, qq in pairs]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    ax1.plot(known_bits, admissible, marker="o", color="#2c7fb8")
    ax1.set_xlabel("known most-significant bits of $p+q$")
    ax1.set_ylabel(r"$\log_2$ of largest admissible $d$")
    ax1.set_title("Partial knowledge relaxes the Wiener bound")
    ax1.grid(True, alpha=0.3)

    ax2.scatter(diffs, roots, color="#d95f0e", zorder=3)
    ax2.plot([0, max(diffs)], [0, max(diffs)], "--", color="gray",
             label=r"$\sqrt{(p+q)^2-4n}=p-q$")
    ax2.set_xlabel("$p - q$")
    ax2.set_ylabel(r"$\sqrt{(p+q)^2 - 4n}$")
    ax2.set_title("Discriminant is always a perfect square")
    ax2.legend()
    ax2.grid(True, alpha=0.3)

    fig.tight_layout()
    fig.savefig("wiener_tradeoff.png", dpi=150)
    print("saved wiener_tradeoff.png")


if __name__ == "__main__":
    main()

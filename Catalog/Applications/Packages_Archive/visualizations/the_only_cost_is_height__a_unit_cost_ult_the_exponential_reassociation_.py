"""
visualization.py -- Visual evidence that "the only cost is height".

Generates two panels:
  (left)  balanced vs. caterpillar evaluated depth as a function of leaf count,
          showing the exponential reassociation gap (C1, Theorem 5.5);
  (right) the Hensel/Newton doubling curve: precision 2^k against round count k,
          with the logarithmic round-count for a target precision (C5).

Requires matplotlib. Run:  python3 visualization.py
"""

from __future__ import annotations

from typing import List

import matplotlib.pyplot as plt


def clog2(m: int) -> int:
    return 0 if m <= 1 else (m - 1).bit_length()


def balanced_depth(num_leaves: int) -> int:
    # balanced tree on a power of two: depth = log2(leaves)
    return clog2(num_leaves)


def caterpillar_depth(num_leaves: int) -> int:
    # left-spine tree: depth = leaves - 1
    return num_leaves - 1


def main() -> None:
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5))

    # --- Panel 1: balanced vs caterpillar ---
    ns: List[int] = list(range(1, 8))
    leaves = [2 ** n for n in ns]
    bal = [balanced_depth(m) for m in leaves]
    cat = [caterpillar_depth(m) for m in leaves]

    ax1.plot(leaves, cat, "o-", color="#d6336c", label="caterpillar  (depth = leaves - 1)")
    ax1.plot(leaves, bal, "s-", color="#1c7ed6", label="balanced  (depth = log2 leaves)")
    ax1.set_xscale("log", base=2)
    ax1.set_xlabel("number of leaves (same multiset)")
    ax1.set_ylabel("evaluated depth (unit-cost operation)")
    ax1.set_title("C1: the exponential reassociation gap")
    ax1.legend()
    ax1.grid(True, alpha=0.3)

    # --- Panel 2: Hensel doubling ---
    ks = list(range(0, 9))
    precision = [2 ** k for k in ks]
    ax2.plot(ks, precision, "^-", color="#2f9e44", label="precision = 2^k")
    ax2.set_yscale("log", base=2)
    ax2.set_xlabel("round count k  (=  tree height  =  evaluated depth)")
    ax2.set_ylabel("p-adic precision (digits, log scale)")
    ax2.set_title("C5: exponential precision in logarithmic rounds")
    ax2.axhline(2 ** 6, ls="--", color="gray", alpha=0.6)
    ax2.annotate("target T => rounds = ceil(log2 T)", xy=(6, 2 ** 6),
                 xytext=(1.5, 2 ** 7),
                 arrowprops=dict(arrowstyle="->", color="gray"))
    ax2.legend()
    ax2.grid(True, alpha=0.3)

    fig.suptitle("The Only Cost Is Height", fontsize=15, fontweight="bold")
    fig.tight_layout(rect=(0, 0, 1, 0.96))
    fig.savefig("only_cost_is_height.png", dpi=150)
    print("Saved only_cost_is_height.png")


if __name__ == "__main__":
    main()

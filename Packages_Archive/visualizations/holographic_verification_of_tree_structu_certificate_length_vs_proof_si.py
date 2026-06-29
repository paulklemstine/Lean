"""Visualization: holographic certificate length vs proof size.

Generates a figure with two panels:
  (left)  certificate length = log2(numLeaves) for perfectly balanced proofs,
          plotted against the (exponentially growing) number of leaves;
  (right) composition overhead: certificate length of a k-fold chain stays at
          most sum(depths)+k, far below the linear total proof size.

Requires matplotlib. Run: python visualization.py
"""

import math
from typing import List

import matplotlib.pyplot as plt


def balanced_cert_length(num_leaves: int) -> int:
    return int(math.log2(num_leaves))


def main() -> None:
    heights: List[int] = list(range(1, 21))
    leaves: List[int] = [2 ** k for k in heights]
    cert_len: List[int] = [balanced_cert_length(n) for n in leaves]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5))

    ax1.plot(leaves, cert_len, "o-", color="#2c7fb8", lw=2, label="certificate length")
    ax1.plot(leaves, leaves, "--", color="#d95f0e", lw=1.5, label="full proof size (n)")
    ax1.set_xscale("log", base=2)
    ax1.set_yscale("log", base=2)
    ax1.set_xlabel("number of leaves n (log scale)")
    ax1.set_ylabel("size (log scale)")
    ax1.set_title("Holographic bound: certificate = log2(n)")
    ax1.legend()
    ax1.grid(True, which="both", alpha=0.3)

    ks: List[int] = list(range(1, 21))
    comp_depth = 4
    chain_bound = [k * comp_depth + k for k in ks]
    total_size = [k * (2 ** comp_depth) for k in ks]
    ax2.plot(ks, chain_bound, "s-", color="#31a354", lw=2,
             label="certificate bound  sum(depths)+k")
    ax2.plot(ks, total_size, "--", color="#d95f0e", lw=1.5,
             label="total composed proof size")
    ax2.set_xlabel("number of composed proofs k")
    ax2.set_ylabel("size")
    ax2.set_title("Composition subadditivity (components of depth 4)")
    ax2.legend()
    ax2.grid(True, alpha=0.3)

    fig.suptitle("Depth-Information Duality: certificates track depth, not volume",
                 fontsize=13)
    fig.tight_layout()
    fig.savefig("holographic_certificates.png", dpi=150)
    print("Saved holographic_certificates.png")


if __name__ == "__main__":
    main()

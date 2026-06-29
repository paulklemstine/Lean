"""Visualization: normal-form size growth vs. the 2^size bound.

Generates a chart comparing, for a family of trace expressions of growing size,
the actual normal-form length |normalize(e)| against the verified ceiling
2^size(e), separately for multiplication-heavy and multiplication-free families.

Run:  python _viz.py   (writes chronometric_bounds.png)
"""

from __future__ import annotations

from typing import List, Tuple

import matplotlib.pyplot as plt


def mul_chain_sizes(k: int) -> Tuple[int, int]:
    """Expression ((a+b) * (a+b) * ... )  with k factors of (a+b).

    size = 2k, |normalize| = 2^k (each binary choice doubles the word count).
    """
    size = 2 * k
    nf_len = 2 ** k
    return size, nf_len


def add_chain_sizes(k: int) -> Tuple[int, int]:
    """Multiplication-free expression  a1 + a2 + ... + ak.

    size = k, |normalize| = k (linear).
    """
    return k, k


def main() -> None:
    ks: List[int] = list(range(1, 9))
    mul = [mul_chain_sizes(k) for k in ks]
    add = [add_chain_sizes(k) for k in ks]

    sizes_mul = [s for s, _ in mul]
    nf_mul = [n for _, n in mul]
    bound_mul = [2 ** s for s in sizes_mul]

    sizes_add = [s for s, _ in add]
    nf_add = [n for _, n in add]
    bound_add = [2 ** s for s in sizes_add]

    fig, axes = plt.subplots(1, 2, figsize=(12, 5))

    ax = axes[0]
    ax.semilogy(sizes_mul, bound_mul, "r--", label="ceiling 2^size")
    ax.semilogy(sizes_mul, nf_mul, "bo-", label="|normalize(e)|")
    ax.set_title("Multiplication-heavy family")
    ax.set_xlabel("size(e)")
    ax.set_ylabel("normal-form word count (log scale)")
    ax.legend()
    ax.grid(True, which="both", alpha=0.3)

    ax = axes[1]
    ax.plot(sizes_add, bound_add, "r--", label="ceiling 2^size")
    ax.plot(sizes_add, nf_add, "gs-", label="|normalize(e)| (linear!)")
    ax.set_title("Multiplication-free family")
    ax.set_xlabel("size(e)")
    ax.set_ylabel("normal-form word count")
    ax.legend()
    ax.grid(True, alpha=0.3)

    fig.suptitle("Chronometric trace canonicalization: |normalize| vs 2^size")
    fig.tight_layout()
    fig.savefig("chronometric_bounds.png", dpi=120)
    print("wrote chronometric_bounds.png")


if __name__ == "__main__":
    main()

"""
Visualization: sum distributions of the standard pair (S_36, S_4) versus the
cyclotomic-transfer pair (P36, Q4), shown side by side to make their identity
visually obvious. Also renders the block structure of P36.

Requires matplotlib. Run:  python3 visualization.py
"""

from __future__ import annotations

from typing import List

import matplotlib.pyplot as plt


def trim(p: List[int]) -> List[int]:
    q = list(p)
    while len(q) > 1 and q[-1] == 0:
        q.pop()
    return q


def poly_mul(a: List[int], b: List[int]) -> List[int]:
    r = [0] * (len(a) + len(b) - 1)
    for i, ai in enumerate(a):
        for j, bj in enumerate(b):
            r[i + j] += ai * bj
    return trim(r)


def S(N: int) -> List[int]:
    return [0] + [1] * N


PHI6: List[int] = [1, -1, 1]


def P36() -> List[int]:
    p = [0] * 37
    for j in range(6):
        b = 6 * j
        p[b + 1] += 1
        p[b + 2] += 2
        p[b + 3] += 2
        p[b + 4] += 1
    return p


def main() -> None:
    p36, q4, s36, s4 = P36(), poly_mul(PHI6, S(4)), S(36), S(4)
    dist_std = poly_mul(s36, s4)
    dist_trf = poly_mul(p36, q4)
    sums = list(range(2, 41))
    std = [dist_std[s] for s in sums]
    trf = [dist_trf[s] for s in sums]

    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    ax = axes[0]
    w = 0.4
    ax.bar([s - w / 2 for s in sums], std, width=w, label="standard (S36, S4)")
    ax.bar([s + w / 2 for s in sums], trf, width=w, label="transfer (P36, Q4)")
    ax.set_xlabel("sum of the two dice")
    ax.set_ylabel("number of equally-likely outcomes")
    ax.set_title("Identical sum distributions")
    ax.legend()

    ax = axes[1]
    coeffs = p36[1:37]
    colors = ["#d62728" if c == 2 else ("#1f77b4" if c == 1 else "#cccccc")
              for c in coeffs]
    ax.bar(range(1, 37), coeffs, color=colors)
    ax.set_xlabel("face value")
    ax.set_ylabel("multiplicity")
    ax.set_title("Block structure of P36 = S36 / $\\Phi_6$  (pattern 1,2,2,1,0,0)")

    fig.suptitle("Cyclotomic transfer of $\\Phi_6 = x^2 - x + 1$", fontsize=14)
    fig.tight_layout()
    fig.savefig("phi6_square_dice.png", dpi=150)
    print("saved phi6_square_dice.png")


if __name__ == "__main__":
    main()

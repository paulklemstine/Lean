"""Visualization: covering grid for k = 78557 over one period (mod 36).

Renders a colored strip showing which prime covers each exponent residue,
making the seven patrol beats and the absence of gaps visually obvious.
Requires matplotlib.
"""
from __future__ import annotations
from typing import List, Tuple
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches

K: int = 78557
CERT: List[Tuple[int, int, int]] = [
    (0, 2, 3), (1, 4, 5), (1, 3, 7), (11, 12, 13),
    (15, 18, 19), (27, 36, 37), (3, 9, 73),
]
PRIME_COLORS = {3: "#4e79a7", 5: "#f28e2b", 7: "#59a14f", 13: "#e15759",
                19: "#76b7b2", 37: "#edc948", 73: "#b07aa1"}


def covering_prime(n: int) -> int:
    for (a, m, p) in CERT:
        if n % m == a and (K * pow(2, n, p) + 1) % p == 0:
            return p
    return 0


def main() -> None:
    L = 36
    fig, ax = plt.subplots(figsize=(12, 2.2))
    for n in range(L):
        p = covering_prime(n)
        ax.add_patch(plt.Rectangle((n, 0), 1, 1, color=PRIME_COLORS.get(p, "white"),
                                   ec="black", lw=0.5))
        ax.text(n + 0.5, 0.5, str(p), ha="center", va="center", fontsize=8)
    ax.set_xlim(0, L)
    ax.set_ylim(0, 1)
    ax.set_yticks([])
    ax.set_xticks(range(0, L + 1, 3))
    ax.set_title("Covering of exponents n mod 36 for k = 78557 (cell = smallest covering prime)")
    handles = [mpatches.Patch(color=c, label=f"p={p}") for p, c in PRIME_COLORS.items()]
    ax.legend(handles=handles, ncol=7, loc="upper center", bbox_to_anchor=(0.5, -0.25))
    plt.tight_layout()
    plt.savefig("covering_grid_78557.png", dpi=150, bbox_inches="tight")
    print("saved covering_grid_78557.png")


if __name__ == "__main__":
    main()

"""Visualisation: the greedy packing-cover bound |X| <= c*(s-1) vs. actual cover size.

Generates a figure showing, for c = 4 (nail wall-degree), how the separator bound
F(s) = 4s - 4 grows linearly in s, alongside the linear wall-height threshold
T(s, r) = (8s + 4) r as a function of r.
"""
from __future__ import annotations

import matplotlib.pyplot as plt


def F(s: int) -> int:
    return 4 * s - 4


def T(s: int, r: int) -> int:
    return (8 * s + 4) * r


def main() -> None:
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(11, 4.5))

    # Left: separator bound F(s) = 4s - 4 (c = 4 specialisation of c*(s-1)).
    svals = list(range(1, 11))
    ax1.plot(svals, [F(s) for s in svals], "o-", color="#c0392b", label="F(s) = 4s - 4")
    ax1.plot(svals, [2 * (s - 1) for s in svals], "s--", color="#2980b9",
             label="c=2 bound: 2(s-1)")
    ax1.set_xlabel("s (target packing size)")
    ax1.set_ylabel("separator size bound |X|")
    ax1.set_title("Greedy packing-cover bound c*(s-1)")
    ax1.legend()
    ax1.grid(True, alpha=0.3)

    # Right: wall-height threshold T(s, r) linear in r, for several s.
    rvals = list(range(1, 9))
    for s in (1, 2, 3):
        ax2.plot(rvals, [T(s, r) for r in rvals], "o-", label=f"s = {s}")
    ax2.set_xlabel("r (subwall size)")
    ax2.set_ylabel("required wall height T(s, r)")
    ax2.set_title("Wall height (8s+4)r is linear in r")
    ax2.legend()
    ax2.grid(True, alpha=0.3)

    fig.suptitle("Linear one-set wall-Menger bound: explicit constants")
    fig.tight_layout()
    fig.savefig("wall_menger_bounds.png", dpi=150)
    print("wrote wall_menger_bounds.png")


if __name__ == "__main__":
    main()

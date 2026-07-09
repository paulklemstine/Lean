"""Visualization: the panmagic landscape over Z_n.

Produces a figure with two panels:
  (left)  a number line marking which moduli n admit a panmagic affine
          permutation (exactly those coprime to 6);
  (right) the counting function N(n) = n * P(n) of panmagic affine maps,
          where P(n) = #{a : a, a-1, a+1 all units mod n}.

Run:  python _viz.py   ->  saves panmagic_landscape.png
"""

from __future__ import annotations

from math import gcd
from typing import List

import matplotlib.pyplot as plt


def is_unit(a: int, n: int) -> bool:
    return gcd(a % n, n) == 1


def count_good_multipliers(n: int) -> int:
    return sum(
        1 for a in range(n)
        if is_unit(a, n) and is_unit(a - 1, n) and is_unit(a + 1, n)
    )


def count_panmagic(n: int) -> int:
    return n * count_good_multipliers(n)


def main() -> None:
    n_max = 48
    ns: List[int] = list(range(1, n_max + 1))
    admissible = [gcd(n, 6) == 1 for n in ns]
    counts = [count_panmagic(n) for n in ns]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5))

    # Left: admissibility strip.
    colors = ["#2a9d8f" if ok else "#e76f51" for ok in admissible]
    ax1.bar(ns, [1] * len(ns), color=colors, width=0.9)
    ax1.set_title("Which n admit a panmagic affine permutation?\n"
                  "green = gcd(n,6)=1 (exists),  red = forbidden")
    ax1.set_xlabel("modulus n")
    ax1.set_yticks([])
    for n, ok in zip(ns, admissible):
        if ok:
            ax1.text(n, 1.02, str(n), ha="center", va="bottom",
                     fontsize=7, rotation=90, color="#264653")

    # Right: counting function.
    ax2.stem(ns, counts, basefmt=" ")
    ax2.set_title("Number of panmagic affine maps  N(n) = n·P(n)")
    ax2.set_xlabel("modulus n")
    ax2.set_ylabel("N(n)")
    ax2.grid(alpha=0.3)

    fig.tight_layout()
    fig.savefig("panmagic_landscape.png", dpi=150)
    print("Saved panmagic_landscape.png")


if __name__ == "__main__":
    main()

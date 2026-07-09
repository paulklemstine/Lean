"""Visualization: remainder-orbit symmetry and digit-sum accumulation.

Plots, for a chosen prime p and base b, the remainder orbit r_k = b^k mod p
around a circle (revealing negation symmetry x <-> p-x in the symmetric
regimes) and the running cumulative digit sum against the theoretical line.
Requires matplotlib.
"""
from __future__ import annotations
import math
from typing import List
import matplotlib.pyplot as plt


def multiplicative_order(p: int, b: int) -> int:
    r, k = b % p, 1
    while r != 1:
        r, k = (r * b) % p, k + 1
    return k


def orbit_and_digits(p: int, b: int):
    L = multiplicative_order(p, b)
    r = 1 % p
    rems: List[int] = []
    digs: List[int] = []
    for _ in range(L):
        rems.append(r)
        digs.append((b * r) // p)
        r = (b * r) % p
    return rems, digs


def make_plot(p: int = 13, b: int = 10) -> None:
    rems, digs = orbit_and_digits(p, b)
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    # Left: remainders on a circle of residues.
    angles = [2 * math.pi * x / p for x in rems]
    ax1.scatter([math.cos(a) for a in angles], [math.sin(a) for a in angles],
                s=80, zorder=3)
    for x, a in zip(rems, angles):
        ax1.annotate(str(x), (math.cos(a), math.sin(a)))
    ax1.set_title(f"Remainder orbit of 1/{p} in base {b}\n(negation symmetry x <-> {p}-x)")
    ax1.set_aspect("equal")

    # Right: cumulative digit sum vs. theoretical total.
    cum = []
    s = 0
    for d in digs:
        s += d
        cum.append(s)
    ax2.plot(range(1, len(cum) + 1), cum, marker="o", label="cumulative digit sum")
    ax2.axhline(sum(digs), linestyle="--", label=f"total = {sum(digs)}")
    ax2.set_xlabel("digit index")
    ax2.set_ylabel("running digit sum")
    ax2.set_title("Digit sum accumulation")
    ax2.legend()

    fig.tight_layout()
    fig.savefig("digit_sum_visualization.png", dpi=140)
    print("saved digit_sum_visualization.png")


if __name__ == "__main__":
    make_plot()

"""
Visualization: the exponential race that kills the narcissistic numbers.

Plots log10(d * 9^d) (the combinatorial ceiling on the digit-power sum) against
log10(10^(d-1)) = d-1 (the structural floor on a d-digit number's magnitude).
The curves cross at d = 61: beyond that, the floor outruns the ceiling forever,
so no narcissistic number can exist. A second panel shows the histogram of
narcissistic numbers by digit length.

Requires matplotlib. Run: python3 visualize.py
"""

from __future__ import annotations

from math import log10
from typing import List

import matplotlib.pyplot as plt


def digits(n: int) -> List[int]:
    out: List[int] = []
    while n > 0:
        out.append(n % 10)
        n //= 10
    return out


def is_narcissistic(n: int) -> bool:
    ds = digits(n)
    d = len(ds)
    return n == sum(a ** d for a in ds)


def main() -> None:
    ds = list(range(1, 80))
    ceiling = [log10(d) + d * log10(9) for d in ds]   # log10(d * 9^d)
    floor = [d - 1 for d in ds]                        # log10(10^(d-1))

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5))

    ax1.plot(ds, ceiling, label=r"$\log_{10}(d\cdot 9^d)$  (digit-power ceiling)",
             color="crimson", lw=2)
    ax1.plot(ds, floor, label=r"$\log_{10}(10^{d-1})$  ($d$-digit floor)",
             color="navy", lw=2)
    ax1.axvline(61, color="gray", ls="--", alpha=0.7)
    ax1.annotate("crossover at d = 61\n(species extinct beyond)",
                 xy=(61, 60), xytext=(63, 35),
                 arrowprops=dict(arrowstyle="->", color="black"))
    ax1.set_xlabel("number of digits  d")
    ax1.set_ylabel("base-10 logarithm")
    ax1.set_title("The race that bounds the narcissists")
    ax1.legend()
    ax1.grid(alpha=0.3)

    # histogram of narcissistic numbers up to 10^7 by digit length
    counts = {}
    for n in range(1, 10_000_000):
        if is_narcissistic(n):
            d = len(digits(n))
            counts[d] = counts.get(d, 0) + 1
    lens = sorted(counts)
    ax2.bar(lens, [counts[k] for k in lens], color="seagreen")
    ax2.set_xlabel("number of digits")
    ax2.set_ylabel("count of narcissistic numbers")
    ax2.set_title("Narcissistic numbers by length (n < 10^7)")
    ax2.grid(alpha=0.3, axis="y")

    fig.tight_layout()
    fig.savefig("narcissistic_race.png", dpi=150)
    print("saved narcissistic_race.png")


if __name__ == "__main__":
    main()

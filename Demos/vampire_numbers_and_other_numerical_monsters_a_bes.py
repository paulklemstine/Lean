"""
Narcissistic (Armstrong) numbers: numerical demonstrations.

A natural number n is *narcissistic* if it equals the sum of its base-ten
digits, each raised to the power equal to the number of digits:

    n = sum( a ** d  for a in digits(n) ),   where d = len(digits(n)).

This script demonstrates, with concrete numbers, the results that have been
formally proved:

  * the digit-power ceiling      S(n) <= d * 9 ** d            (Theorem 3.2)
  * the exponential crossover    d * 9 ** d < 10 ** (d - 1)    for d >= 61
                                                               (Theorem 3.3)
  * the finiteness theorem       narcissistic(n)  =>  n < 10 ** 60
                                                               (Theorem 3.5)
  * the verified specimens       1, 153, 370, 371, 407

Pure standard library; run with `python3 demo.py`.
"""

from __future__ import annotations

from math import log10
from typing import List


# --------------------------------------------------------------------------- #
#  Core definitions
# --------------------------------------------------------------------------- #
def digits(n: int) -> List[int]:
    """Base-ten digits of n, least-significant first. digits(0) == []."""
    if n == 0:
        return []
    out: List[int] = []
    while n > 0:
        out.append(n % 10)
        n //= 10
    return out


def digit_power_sum(n: int) -> int:
    """S(n): sum of each digit raised to the power = number of digits."""
    ds = digits(n)
    d = len(ds)
    return sum(a ** d for a in ds)


def is_narcissistic(n: int) -> bool:
    """Decision procedure (Theorem 3.6): n is narcissistic iff n == S(n)."""
    return n == digit_power_sum(n)


# --------------------------------------------------------------------------- #
#  Demonstration 1: the verified specimens
# --------------------------------------------------------------------------- #
def demo_specimens() -> None:
    print("=" * 64)
    print("Verified specimens (formally certified narcissistic numbers)")
    print("=" * 64)
    for n in (1, 153, 370, 371, 407):
        ds = digits(n)
        d = len(ds)
        terms = " + ".join(f"{a}^{d}" for a in ds)
        print(f"  {n:>5} : {terms} = {digit_power_sum(n)}  ->  narcissistic"
              f" = {is_narcissistic(n)}")
    print()


# --------------------------------------------------------------------------- #
#  Demonstration 2: the digit-power ceiling  S(n) <= d * 9^d
# --------------------------------------------------------------------------- #
def demo_ceiling() -> None:
    print("=" * 64)
    print("Theorem 3.2: S(n) <= d * 9^d   (combinatorial ceiling)")
    print("=" * 64)
    samples = [7, 153, 9999, 8208, 24678051, 9474]
    for n in samples:
        d = len(digits(n))
        ceiling = d * 9 ** d
        print(f"  n={n:>10}  d={d}  S(n)={digit_power_sum(n):>12}"
              f"  ceiling d*9^d={ceiling:>14}  ok={digit_power_sum(n) <= ceiling}")
    print()


# --------------------------------------------------------------------------- #
#  Demonstration 3: the exponential crossover  d*9^d < 10^(d-1)  for d >= 61
# --------------------------------------------------------------------------- #
def demo_crossover() -> None:
    print("=" * 64)
    print("Theorem 3.3: d * 9^d < 10^(d-1) for all d >= 61")
    print("=" * 64)
    print("  Showing the race near the proved threshold d = 61:")
    for d in range(57, 64):
        lhs = d * 9 ** d
        rhs = 10 ** (d - 1)
        verdict = "lhs < rhs" if lhs < rhs else "lhs >= rhs"
        print(f"  d={d:>3}  log10(d*9^d)={log10(lhs):8.4f}"
              f"  log10(10^(d-1))={float(d - 1):8.4f}   {verdict}")
    # confirm it holds for every d >= 61 up to a large cap
    holds = all(d * 9 ** d < 10 ** (d - 1) for d in range(61, 400))
    print(f"\n  Inequality verified for all d in [61, 400): {holds}")
    print()


# --------------------------------------------------------------------------- #
#  Demonstration 4: exhaustive enumeration up to a bound (finiteness in action)
# --------------------------------------------------------------------------- #
def demo_enumeration(limit: int = 1_000_000) -> None:
    print("=" * 64)
    print(f"Finiteness in action: all narcissistic numbers below {limit:,}")
    print("=" * 64)
    found = [n for n in range(1, limit) if is_narcissistic(n)]
    print(f"  count = {len(found)}")
    print(f"  {found}")
    print()


# --------------------------------------------------------------------------- #
#  Demonstration 5: length-stratified enumeration (the efficient algorithm)
# --------------------------------------------------------------------------- #
def demo_multiset_search(max_len: int = 7) -> None:
    """Find narcissistic numbers by enumerating digit-multisets, not integers."""
    from itertools import combinations_with_replacement

    print("=" * 64)
    print(f"Efficient multiset search for digit-lengths 1..{max_len}")
    print("=" * 64)
    results: List[int] = []
    for d in range(1, max_len + 1):
        for combo in combinations_with_replacement(range(10), d):
            total = sum(a ** d for a in combo)
            if len(digits(total)) == d and sorted(digits(total)) == sorted(combo):
                results.append(total)
    results = sorted(set(results))
    print(f"  narcissistic numbers with up to {max_len} digits:")
    print(f"  {results}")
    print()


def main() -> None:
    demo_specimens()
    demo_ceiling()
    demo_crossover()
    demo_enumeration()
    demo_multiset_search()
    print("All demonstrations complete.")


if __name__ == "__main__":
    main()


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

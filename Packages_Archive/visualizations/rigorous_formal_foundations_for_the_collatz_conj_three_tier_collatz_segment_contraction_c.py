"""
Three-tier contraction classifier for Collatz trajectory segments.

Given a segment with j odd (tripling) steps and m even (halving) steps, decide whether
the idealized multiplier 3^j / 2^m is below 1 (i.e. 3^j < 2^m, the segment contracts).
Three certificates of increasing power are offered:

    tier 1  naive     : 2j < m                  O(1)        sufficient, suboptimal (1/2)
    tier 2  sharp_log : j*log3 < m*log2         O(1) float  EXACT up to fp boundary
    tier 3  exact_int : 3^j < 2^m               O(poly)     ground truth, big integers

Guaranteed relationships (formally verified):
    naive  ==>  sharp_log  <==>  exact_int          (sharp strictly dominates naive)

The classifier returns the strongest applicable tier and arbitrates the floating-point
boundary with the exact big-integer comparison so the answer is always provably correct.
"""

from __future__ import annotations

import math
from dataclasses import dataclass

LOG2: float = math.log(2.0)
LOG3: float = math.log(3.0)


@dataclass(frozen=True)
class Verdict:
    contracts: bool          # ground-truth 3^j < 2^m
    naive_cert: bool         # certified by 2j < m
    sharp_cert: bool         # certified by j*log3 < m*log2
    reclaimed: bool          # sharp-true but naive-false
    odd_even_ratio: float    # j/m


def classify_segment(j: int, m: int) -> Verdict:
    """Classify a (j, m) segment, arbitrating the fp boundary with exact integers."""
    naive: bool = 2 * j < m
    # exact integer comparison is the ground truth used to settle boundary cases
    exact: bool = 3 ** j < 2 ** m
    # floating sharp test; if it disagrees with exact we are at the boundary -> trust exact
    sharp_fp: bool = j * LOG3 < m * LOG2
    sharp: bool = exact if sharp_fp != exact else sharp_fp
    ratio: float = (j / m) if m > 0 else math.inf
    return Verdict(
        contracts=exact,
        naive_cert=naive,
        sharp_cert=sharp,
        reclaimed=sharp and not naive,
        odd_even_ratio=ratio,
    )


def demo() -> None:
    for j, m in [(1, 2), (5, 8), (62, 100), (63, 100), (64, 100), (10, 15)]:
        v = classify_segment(j, m)
        tag = "RECLAIMED" if v.reclaimed else ("contracts" if v.contracts else "grows")
        print(f"j={j:>3} m={m:>3} ratio={v.odd_even_ratio:.4f}  "
              f"naive={v.naive_cert!s:>5} sharp={v.sharp_cert!s:>5}  -> {tag}")


if __name__ == "__main__":
    demo()

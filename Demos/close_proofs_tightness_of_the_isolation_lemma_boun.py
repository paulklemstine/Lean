"""Numerical demonstrations for:

    Tightness of the Isolation Lemma Bound Under Arbitrary Edge Offsets

We study the *singleton hypergraph* on n vertices with weight palette
[d] = {0, 1, ..., d-1}.  Under an integer edge offset f, vertex i has cost
    g(i) = f[i] + w[i].
A weight assignment w in [d]^n is ISOLATING if a unique vertex attains the
minimum cost g.

This script demonstrates:
  1. the exact product-sum master identity for the isolating count I(n,d,f),
     verified against brute-force enumeration;
  2. the offset-free / constant-offset floor  n * sum_{j<d} j^(n-1)
     (the Faber-Harris extremal value);
  3. the separated-offset ceiling  d^n;
  4. an explicit witness that offsets strictly move the count: f=(0,1,5) on
     (n,d)=(3,3) gives 21 > 15.

Run:  python3 demo.py
"""

from __future__ import annotations

from itertools import product
from typing import Sequence


def isolating_count_bruteforce(n: int, d: int, f: Sequence[int]) -> int:
    """Count isolating assignments by enumerating all d^n weightings.

    An assignment w is isolating iff a unique vertex attains min_i (f[i] + w[i]).
    Cost O(n * d^n); ground truth for small (n, d).
    """
    count = 0
    for w in product(range(d), repeat=n):
        costs = [f[i] + w[i] for i in range(n)]
        m = min(costs)
        if sum(1 for c in costs if c == m) == 1:
            count += 1
    return count


def above_threshold(d: int, fi: int, m: int, fj: int) -> int:
    """A_f(i, j, m) = #{ k in [d] : fi + m < fj + k }.

    Closed form: clip(d - 1 - (fi + m - fj), 0, d).
    """
    return min(d, max(0, d - 1 - (fi + m - fj)))


def isolating_count_formula(n: int, d: int, f: Sequence[int]) -> int:
    """Exact isolating count via the master identity (Theorem 3.5):

        I(n,d,f) = sum_i sum_m prod_{j != i} #{k : f[i] + m < f[j] + k}.

    Cost O(n^2 * d) -- exponentially faster than brute force.
    """
    total = 0
    for i in range(n):
        for m in range(d):
            prod = 1
            for j in range(n):
                if j == i:
                    continue
                prod *= above_threshold(d, f[i], m, f[j])
            total += prod
    return total


def faber_harris_floor(n: int, d: int) -> int:
    """The offset-free extremal value  n * sum_{j=0}^{d-1} j^(n-1)."""
    return n * sum(j ** (n - 1) for j in range(d))


def separated_offset(n: int, d: int) -> list[int]:
    """Widely separated offsets f[i] = i * d, forcing every assignment to isolate."""
    return [i * d for i in range(n)]


def _banner(title: str) -> None:
    print("\n" + "=" * 68)
    print(title)
    print("=" * 68)


def demo_master_identity() -> None:
    _banner("1. Master identity vs. brute force (many offsets)")
    print(f"{'(n,d)':>7} {'offset f':>16} {'formula':>9} {'brute':>7} {'match':>6}")
    trials = [
        (3, 3, (0, 0, 0)),
        (3, 3, (0, 1, 5)),
        (3, 4, (2, 2, 2)),
        (3, 4, (0, 4, 8)),
        (4, 3, (0, 0, 1, 2)),
        (2, 5, (0, 3)),
        (4, 4, (1, 0, 2, 7)),
        (5, 3, (0, 1, 0, 2, 1)),
    ]
    all_ok = True
    for n, d, f in trials:
        a = isolating_count_formula(n, d, f)
        b = isolating_count_bruteforce(n, d, f)
        ok = a == b
        all_ok &= ok
        print(f"{f'({n},{d})':>7} {str(tuple(f)):>16} {a:>9} {b:>7} {'OK' if ok else 'FAIL':>6}")
    print(f"\nAll formula==brute : {all_ok}")


def demo_constant_floor() -> None:
    _banner("2. Constant offsets recover the Faber-Harris floor  n*sum j^(n-1)")
    for n, d in [(3, 3), (3, 4), (4, 3), (2, 5)]:
        floor = faber_harris_floor(n, d)
        vals = {isolating_count_formula(n, d, [c] * n) for c in (-3, 0, 7, 100)}
        print(f"(n,d)=({n},{d}): floor={floor:>4}   "
              f"constant-offset counts={sorted(vals)}   "
              f"{'MATCH' if vals == {floor} else 'MISMATCH'}")


def demo_separated_ceiling() -> None:
    _banner("3. Separated offsets isolate every assignment  ->  ceiling d^n")
    for n, d in [(3, 3), (3, 4), (4, 3), (2, 5)]:
        f = separated_offset(n, d)
        got = isolating_count_formula(n, d, f)
        print(f"(n,d)=({n},{d}): f={f}   I={got}   d^n={d**n}   "
              f"{'MATCH' if got == d ** n else 'MISMATCH'}")


def demo_witness_and_band() -> None:
    _banner("4. Offsets strictly move the count; the (floor, ceiling) band")
    n, d = 3, 3
    floor, ceil = faber_harris_floor(n, d), d ** n
    print(f"(n,d)=({n},{d}):  floor={floor}, ceiling={ceil}")
    print(f"  constant  (0,0,0): I={isolating_count_formula(n, d, [0,0,0])}")
    print(f"  witness   (0,1,5): I={isolating_count_formula(n, d, [0,1,5])}  "
          f"(strictly above the floor {floor})")
    print(f"  separated (0,3,6): I={isolating_count_formula(n, d, [0,3,6])}")
    # Sweep a small offset lattice to see which values in [floor, ceiling] appear.
    seen = set()
    R = range(0, 7)
    for f in product(R, repeat=n):
        seen.add(isolating_count_formula(n, d, f))
    inside = sorted(v for v in seen if floor <= v <= ceil)
    print(f"  distinct counts over offsets in {list(R)}^{n}: {sorted(seen)}")
    print(f"  all within [floor, ceiling]: {all(floor <= v <= ceil for v in seen)}")
    print(f"  values attained inside the band: {inside}")


if __name__ == "__main__":
    demo_master_identity()
    demo_constant_floor()
    demo_separated_ceiling()
    demo_witness_and_band()
    print("\nDone.")

"""Projective Plane Coupon Collection Slowness — numerical demonstrations.

This self-contained script reproduces the exact rational cover-time values that
underpin the main results, and provides computational evidence for the
general-order conjecture.

The model
---------
We are given a ground set of ``n`` points and a family ``B`` of *blocks*
(subsets of the points).  At each step we draw one block uniformly at random.
A point is *covered* the first time a drawn block contains it.  The *cover time*
is the first step at which every point has been covered.

Writing ``tau_p`` for the first step a block containing ``p`` is drawn, the cover
time equals ``max_p tau_p``.  Inclusion-exclusion over the points gives the exact
expectation

    E[cover time] = sum over nonempty S of  (-1)^(|S|+1) * |B| / coverCount(B, S),

where ``coverCount(B, S)`` is the number of blocks meeting ``S`` (i.e. blocks with
nonempty intersection with ``S``).  Each inner term is the mean of a geometric
random variable: the first draw of a block meeting ``S`` has success probability
``coverCount(B, S) / |B|``.

We compare, on the same ground set, the *line family* of a projective plane of
order ``q`` (n = q^2 + q + 1 points, each line a (q+1)-subset) against the
*uniform family* of ALL (q+1)-subsets.
"""

from __future__ import annotations

from fractions import Fraction
from itertools import combinations
from typing import List, Set, Tuple


# --------------------------------------------------------------------------- #
#  Core cover-time machinery                                                   #
# --------------------------------------------------------------------------- #
def cover_count(blocks: List[Set[int]], subset: Set[int]) -> int:
    """Number of blocks that meet ``subset`` (have nonempty intersection)."""
    return sum(1 for b in blocks if b & subset)


def expected_cover_time(blocks: List[Set[int]], n: int) -> Fraction:
    """Exact expected cover time via inclusion-exclusion over all nonempty S."""
    num_blocks = len(blocks)
    total = Fraction(0)
    points = list(range(n))
    for size in range(1, n + 1):
        sign = 1 if size % 2 == 1 else -1
        for combo in combinations(points, size):
            subset = set(combo)
            cc = cover_count(blocks, subset)
            total += Fraction(sign * num_blocks, cc)
    return total


# --------------------------------------------------------------------------- #
#  Projective plane of order q (q prime): points and lines                     #
# --------------------------------------------------------------------------- #
def projective_points(q: int) -> List[Tuple[int, int, int]]:
    """Normalized representatives of the 1-dimensional subspaces of GF(q)^3."""
    pts: List[Tuple[int, int, int]] = []
    for x in range(q):
        for y in range(q):
            for z in range(q):
                if (x, y, z) == (0, 0, 0):
                    continue
                v = (x, y, z)
                inv = 1
                for c in v:
                    if c % q != 0:
                        inv = pow(c, q - 2, q) if q > 2 else 1
                        break
                nv = tuple((inv * a) % q for a in v)
                if nv not in pts:
                    pts.append(nv)  # type: ignore[arg-type]
    return pts


def projective_lines(q: int) -> Tuple[List[Set[int]], int]:
    """Return (lines, n) for the projective plane of order q (q prime).

    A line is the set of points (x, y, z) satisfying a*x + b*y + c*z = 0 for a
    fixed dual point (a, b, c).  There are q^2 + q + 1 such lines.
    """
    pts = projective_points(q)
    index = {p: i for i, p in enumerate(pts)}
    lines: Set[frozenset] = set()
    for (a, b, c) in pts:
        line = frozenset(
            i for p, i in index.items()
            if (a * p[0] + b * p[1] + c * p[2]) % q == 0
        )
        lines.add(line)
    return [set(l) for l in lines], len(pts)


def uniform_k_subsets(n: int, k: int) -> List[Set[int]]:
    """All k-element subsets of an n-point ground set."""
    return [set(c) for c in combinations(range(n), k)]


# --------------------------------------------------------------------------- #
#  Demonstrations                                                              #
# --------------------------------------------------------------------------- #
def fano_lines() -> List[Set[int]]:
    """The seven lines of the Fano plane in the cyclic form {i, i+1, i+3} mod 7."""
    base = [0, 1, 3]
    return [set((b + s) % 7 for b in base) for s in range(7)]


def demo_fano() -> None:
    print("=" * 68)
    print("Fano plane (order q = 2):  n = 7 points")
    print("=" * 68)
    lines = fano_lines()
    uniform = uniform_k_subsets(7, 3)
    print(f"  #lines          = {len(lines)}   (expected 7)")
    print(f"  #uniform 3-sets = {len(uniform)}  (expected 35 = C(7,3))")

    e_lines = expected_cover_time(lines, 7)
    e_uniform = expected_cover_time(uniform, 7)
    print(f"  E[cover time], Fano lines   = {e_lines} = {float(e_lines):.6f}")
    print(f"  E[cover time], uniform sets = {e_uniform} = {float(e_uniform):.6f}")
    assert e_lines == Fraction(163, 30)
    assert e_uniform == Fraction(85691, 15810)
    assert e_uniform < e_lines
    print(f"  Lines are STRICTLY SLOWER: {float(e_uniform):.6f} < {float(e_lines):.6f}")
    print(f"  Slowdown gap  = {float(e_lines - e_uniform):.6f}")


def demo_general(q_values: List[int]) -> None:
    print()
    print("=" * 68)
    print("General projective planes of order q (prime): lines vs uniform")
    print("=" * 68)
    for q in q_values:
        lines, n = projective_lines(q)
        k = q + 1
        uniform = uniform_k_subsets(n, k)
        e_lines = expected_cover_time(lines, n)
        e_uniform = expected_cover_time(uniform, n)
        slower = e_uniform < e_lines
        print(f"  q = {q}:  n = {n},  #lines = {len(lines)},  #uniform = {len(uniform)}")
        print(f"        lines   = {float(e_lines):.6f}")
        print(f"        uniform = {float(e_uniform):.6f}")
        print(f"        lines strictly slower?  {slower}")


if __name__ == "__main__":
    demo_fano()
    # q = 2 and q = 3 run quickly; q = 4 (n = 21) is heavier but feasible.
    demo_general([2, 3])

"""
demo.py — Numerical demonstrations for

    "Rips Graph Monotonicity as a Functor into Tropical Valuation Objects"

This self-contained script reproduces, numerically, the main formal results:

  * edge_count_profile        — the edge-count profile of a finite metric space
  * Theorem (monotonicity)    — profile(r) <= profile(s) whenever r <= s
  * Theorem (zero threshold)  — profile(0) == 0 in a metric space
  * Theorem (upper bound)     — profile(r) <= |Sym2(alpha)| = n(n-1)/2
  * Functorial domination     — injective non-expanding maps dominate profiles
  * Discrete-derivative view  — profile jumps recover the pairwise-distance histogram
  * Dynamical bridge          — continuous orbit vectors of an iterated map

Run:  python3 demo.py
No third-party dependencies.
"""

from __future__ import annotations

import math
from collections import Counter
from itertools import combinations
from typing import Callable, Dict, List, Sequence, Tuple

Point = Tuple[float, ...]


# ---------------------------------------------------------------------------
# Core: the Rips edge-count profile
# ---------------------------------------------------------------------------

def euclidean(a: Point, b: Point) -> float:
    """Euclidean distance between two equal-length tuples of reals."""
    return math.sqrt(sum((x - y) ** 2 for x, y in zip(a, b)))


def edge_count(points: Sequence[Point], r: float,
               dist: Callable[[Point, Point], float] = euclidean) -> int:
    """Number of edges of the Rips graph at scale r:
    the count of unordered pairs {x, y} with x != y and dist(x, y) <= r.
    Complexity: O(n^2)."""
    n = len(points)
    return sum(1 for i, j in combinations(range(n), 2)
               if dist(points[i], points[j]) <= r)


def edge_count_profile(points: Sequence[Point], thresholds: Sequence[int],
                       dist: Callable[[Point, Point], float] = euclidean) -> List[int]:
    """The edge-count profile evaluated at the given integer thresholds.
    Mirrors `edgeCountProfile alpha r` for r in `thresholds`."""
    return [edge_count(points, float(r), dist) for r in thresholds]


def sym2_card(n: int) -> int:
    """|Sym2(alpha)| for |alpha| = n, i.e. the number of unordered pairs n(n-1)/2."""
    return n * (n - 1) // 2


# ---------------------------------------------------------------------------
# Verifications of the main theorems
# ---------------------------------------------------------------------------

def verify_monotone(points: Sequence[Point], thresholds: Sequence[int]) -> bool:
    """Theorem 4.1 / Corollary 4.2: the profile is non-decreasing."""
    prof = edge_count_profile(points, thresholds)
    return all(prof[i] <= prof[i + 1] for i in range(len(prof) - 1))


def verify_zero(points: Sequence[Point]) -> bool:
    """Theorem 4.3: profile(0) == 0 in a metric space (distinct points => positive dist)."""
    return edge_count(points, 0.0) == 0


def verify_upper_bound(points: Sequence[Point], thresholds: Sequence[int]) -> bool:
    """Theorem 4.4: profile(r) <= n(n-1)/2 for all r."""
    cap = sym2_card(len(points))
    return all(c <= cap for c in edge_count_profile(points, thresholds))


# ---------------------------------------------------------------------------
# Functorial bridge: injective non-expanding maps dominate profiles
# ---------------------------------------------------------------------------

def is_non_expanding(f: Callable[[Point], Point], points: Sequence[Point],
                     dist: Callable[[Point, Point], float] = euclidean) -> bool:
    """Check dist(f x, f y) <= dist(x, y) for all pairs (1-Lipschitz)."""
    return all(dist(f(a), f(b)) <= dist(a, b) + 1e-12
               for a, b in combinations(points, 2))


def verify_domination(points: Sequence[Point], f: Callable[[Point], Point],
                      thresholds: Sequence[int]) -> bool:
    """Section 5: an injective non-expanding map f : alpha -> beta yields
    profile_alpha(r) <= profile_beta(r) for all r (RipsProfileDomination)."""
    image = [f(p) for p in points]
    assert is_non_expanding(f, points), "f must be non-expanding"
    assert len(set(image)) == len(image), "f must be injective on the sample"
    pa = edge_count_profile(points, thresholds)
    pb = edge_count_profile(image, thresholds)
    return all(a <= b for a, b in zip(pa, pb))


# ---------------------------------------------------------------------------
# Discrete-derivative view: profile jumps recover the distance histogram
# ---------------------------------------------------------------------------

def distance_histogram(points: Sequence[Point],
                       dist: Callable[[Point, Point], float] = euclidean
                       ) -> Counter[int]:
    """Binned histogram of pairwise distances: count of pairs with
    ceil(dist) == r, for each r (Section 5.4)."""
    h: Counter[int] = Counter()
    for a, b in combinations(points, 2):
        h[math.ceil(dist(a, b))] += 1
    return h


def profile_increments(points: Sequence[Point], thresholds: Sequence[int]
                       ) -> Dict[int, int]:
    """Discrete derivative of the profile: profile(r) - profile(r-1)."""
    prof = edge_count_profile(points, thresholds)
    inc: Dict[int, int] = {}
    prev = 0
    for r, c in zip(thresholds, prof):
        inc[r] = c - prev
        prev = c
    return inc


# ---------------------------------------------------------------------------
# Dynamical bridge: continuous orbit vectors of an iterated map
# ---------------------------------------------------------------------------

def orbit(f: Callable[[float], float], x: float, n: int) -> List[float]:
    """The orbit vector (x, f(x), ..., f^[n-1](x)) (Theorem 6.2)."""
    out: List[float] = []
    cur = x
    for _ in range(n):
        out.append(cur)
        cur = f(cur)
    return out


def verify_semiconj(f: Callable[[float], float], g: Callable[[float], float],
                    h: Callable[[float], float], samples: Sequence[float],
                    n: int) -> bool:
    """Theorem 6.5: if h o f = g o h then h o f^[n] = g^[n] o h."""
    def iterate(fn: Callable[[float], float], x: float, k: int) -> float:
        for _ in range(k):
            x = fn(x)
        return x
    return all(abs(h(iterate(f, x, n)) - iterate(g, h(x), n)) < 1e-9
               for x in samples)


# ---------------------------------------------------------------------------
# Driver
# ---------------------------------------------------------------------------

def main() -> None:
    # A point cloud roughly sampled from a circle of radius 5 in the plane.
    k = 8
    circle: List[Point] = [
        (5.0 * math.cos(2 * math.pi * i / k), 5.0 * math.sin(2 * math.pi * i / k))
        for i in range(k)
    ]
    thresholds = list(range(0, 12))

    print("=" * 70)
    print("Rips edge-count profile of an 8-point circle sample (radius 5)")
    print("=" * 70)
    prof = edge_count_profile(circle, thresholds)
    print(f"thresholds r : {thresholds}")
    print(f"profile(r)   : {prof}")
    print(f"|Sym2(alpha)| = n(n-1)/2 = {sym2_card(k)}")
    print()
    print(f"[Thm 4.1] monotone non-decreasing : {verify_monotone(circle, thresholds)}")
    print(f"[Thm 4.3] profile(0) == 0         : {verify_zero(circle)}")
    print(f"[Thm 4.4] profile(r) <= n(n-1)/2  : {verify_upper_bound(circle, thresholds)}")
    print()

    print("-" * 70)
    print("Functorial domination under an injective non-expanding map")
    print("-" * 70)
    # A 0.5-contraction toward the origin: non-expanding and injective.
    def shrink(p: Point) -> Point:
        return tuple(0.5 * c for c in p)
    print(f"f = 0.5*x is non-expanding         : {is_non_expanding(shrink, circle)}")
    print(f"[Sec 5] profile(alpha) <= profile(f(alpha)) ... ", end="")
    # Domination as stated requires f : alpha -> beta with alpha dominated by beta;
    # a contraction *shrinks* distances so the *image* gains edges earlier:
    img = [shrink(p) for p in circle]
    pa, pb = edge_count_profile(circle, thresholds), edge_count_profile(img, thresholds)
    print(all(a <= b for a, b in zip(pa, pb)))
    print(f"   profile(original) : {pa}")
    print(f"   profile(image)    : {pb}")
    print()

    print("-" * 70)
    print("Discrete-derivative view: profile jumps == distance histogram")
    print("-" * 70)
    inc = profile_increments(circle, thresholds)
    hist = distance_histogram(circle)
    print(f"profile increments : {dict(inc)}")
    print(f"distance histogram : {dict(sorted(hist.items()))}")
    match = all(inc.get(r, 0) == hist.get(r, 0) for r in set(inc) | set(hist))
    print(f"increments match histogram (Sec 5.4): {match}")
    print()

    print("-" * 70)
    print("Dynamical bridge: continuous orbit vector & semiconjugacy")
    print("-" * 70)
    # f(x) = x/2 (a contraction). Orbit of x = 16 over horizon 5.
    f = lambda x: x / 2.0
    print(f"orbit(f, 16, 5) = {orbit(f, 16.0, 5)}")
    # Semiconjugacy: h(x) = 3x intertwines f(x)=x/2 with g(y)=y/2  (h o f = g o h).
    g = lambda y: y / 2.0
    h = lambda x: 3.0 * x
    ok = verify_semiconj(f, g, h, samples=[1.0, 2.0, 7.0, -3.0], n=4)
    print(f"[Thm 6.5] h o f^[n] == g^[n] o h    : {ok}")
    print()
    print("All checks complete.")


if __name__ == "__main__":
    main()

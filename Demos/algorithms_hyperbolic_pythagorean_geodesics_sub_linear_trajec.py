#!/usr/bin/env python3
"""
The four algorithms of the Hyperbolic-Pythagorean Geodesics package,
each self-contained and type-hinted.

  A. berggren_descent          -- address word and depth of a Euclid seed
  B. localise_node             -- exact hyperbolic geometry of a node,
                                  with a certified interval for the gap
  C. branch_direction_oracle   -- which way each branch moves the residual
  D. collision_factor          -- Euler splitting from a Berggren collision

Running this file exercises all four.
"""

from __future__ import annotations

from math import acosh, gcd, isqrt, log, sqrt
from typing import Dict, List, Optional, Tuple

Seed = Tuple[int, int]

ROOT: Seed = (2, 1)
SQRT2_MINUS_1: float = sqrt(2.0) - 1.0


# ===========================================================================
# A. Berggren descent
# ===========================================================================

def is_euclid_seed(m: int, n: int) -> bool:
    """0 < n < m, gcd(m,n) = 1, m + n odd."""
    return 0 < n < m and gcd(m, n) == 1 and (m + n) % 2 == 1


def berggren_children(p: Seed) -> Dict[str, Seed]:
    """The three Berggren moves in Euclid-seed coordinates."""
    m, n = p
    return {"B1": (2 * m - n, m), "B2": (2 * m + n, m), "B3": (m + 2 * n, n)}


def berggren_parent(p: Seed) -> Seed:
    """The inverse move, selected by the slope trichotomy.

    n/m in (0, 1/3)   -> the last move was B3, parent (m-2n, n)
    n/m in (1/3, 1/2) -> the last move was B2, parent (n, m-2n)
    n/m in (1/2, 1)   -> the last move was B1, parent (n, 2n-m)
    """
    m, n = p
    if m > 3 * n:
        return (m - 2 * n, n)
    if m > 2 * n:
        return (n, m - 2 * n)
    return (n, 2 * n - m)


def berggren_descent(p: Seed) -> List[str]:
    """The unique word in {B1,B2,B3}* leading from the root (2,1) to p.

    Correctness: the parent map inverts the correct move on each of the three
    slope regions, sends every seed other than the root to a seed, and
    strictly decreases the first coordinate, so the loop terminates at (2,1).
    The length of the returned word is the depth of p, which is well defined
    because the Berggren graph is a tree.

    Complexity: O(1) arithmetic per iteration.  The number of iterations is
    the depth, which is O(log m) on the middle spine and as large as
    Theta(m) on the left spine (2,1) -> (3,2) -> (4,3) -> ...
    """
    if not is_euclid_seed(*p):
        raise ValueError(f"{p} is not a Euclid seed")
    word: List[str] = []
    while p != ROOT:
        m, n = p
        word.append("B3" if m > 3 * n else ("B2" if m > 2 * n else "B1"))
        p = berggren_parent(p)
    word.reverse()
    return word


def berggren_ascend(word: List[str]) -> Seed:
    """Follow an address word down from the root."""
    p = ROOT
    for w in word:
        p = berggren_children(p)[w]
    return p


# ===========================================================================
# B. Exact hyperbolic localisation
# ===========================================================================

class NodeGeometry:
    """The complete hyperbolic data of one Berggren node."""

    __slots__ = ("seed", "triple", "hypotenuse", "slope", "cosh_dist",
                 "distance", "ideal_radius", "residual", "slope_model",
                 "gap", "gap_lower", "gap_upper")

    def __init__(self, m: int, n: int) -> None:
        c = m * m + n * n
        self.seed: Seed = (m, n)
        self.triple: Tuple[int, int, int] = (m * m - n * n, 2 * m * n, c)
        self.hypotenuse: int = c
        self.slope: float = n / m
        self.cosh_dist: float = (c + 1) / (2 * m)
        self.distance: float = acosh(self.cosh_dist)
        self.ideal_radius: float = 0.5 * log(c)
        self.residual: float = self.distance - self.ideal_radius
        self.slope_model: float = 0.5 * log(1 + (n / m) ** 2)
        self.gap: float = self.residual - self.slope_model
        self.gap_lower: float = n * n / (c * c + n * n)
        self.gap_upper: float = n * n / (c * (c - 1))

    def __repr__(self) -> str:
        return (f"NodeGeometry(seed={self.seed}, c={self.hypotenuse}, "
                f"d={self.distance:.6f}, rho={self.residual:.6f}, "
                f"gap={self.gap:.3e} in [{self.gap_lower:.3e}, "
                f"{self.gap_upper:.3e}])")


def localise_node(m: int, n: int) -> NodeGeometry:
    """Exact hyperbolic position of the node z(m,n) = (n+i)/m.

    Mathematical basis.  The half-plane metric gives
        cosh d(i, z) = 1 + |z-i|^2 / (2 Im z)  =  (m^2 + n^2 + 1) / (2m),
    an identity in which the hypotenuse c = m^2+n^2 of the Pythagorean triple
    appears directly.  Consequently
        (1/2) log c  <=  d  <=  (1/2) log(2(c+1)),
    so the residual rho = d - (1/2) log c lies in [0, (1/2) log 2).  Writing
    S = sqrt((c+1)^2 - 4m^2) = 2m sinh d, the residual exceeds its slope model
    (1/2) log(1 + (n/m)^2) by exactly log(((c+1)+S)/(2c)), and the
    factorisation (S-(c-1))(S+(c-1)) = 4n^2 pins that gap between
    n^2/(c^2+n^2) and n^2/(c(c-1)) -- a two-sided bound with ratio
    (c+1)/(c-1).

    Complexity: O(1).
    """
    if not is_euclid_seed(m, n):
        raise ValueError(f"({m},{n}) is not a Euclid seed")
    return NodeGeometry(m, n)


# ===========================================================================
# C. Branch direction oracle
# ===========================================================================

def on_pell_boundary(p: Seed) -> bool:
    """(m-n)^2 = 2n^2 + 1: the boundary layer (5,2), (29,12), (169,70), ..."""
    m, n = p
    return (m - n) ** 2 == 2 * n * n + 1


def branch_direction_oracle(p: Seed) -> Dict[str, str]:
    """Predict, without computing any transcendental function, which way each
    Berggren branch moves the exact hyperbolic residual.

    The theorems behind the three answers:

      * B1 raises the residual for every Euclid seed, unconditionally.
      * B3 lowers it for every Euclid seed, unconditionally.
      * B2 lowers it exactly when m^2 < 2mn + n^2, i.e. when the slope n/m
        exceeds sqrt(2) - 1, and raises it exactly when m^2 > 2mn + n^2.
        Equality is impossible for a seed: it would force n = 1 and then
        m^2 - 2m - 1 = 0, which has no integer root.  The seeds with
        m^2 = 2mn + n^2 + 1, i.e. (m-n)^2 = 2n^2 + 1, form a Pell family on
        which the inequality holds only because m and n are integers.

    Complexity: O(1), exact integer arithmetic only.
    """
    m, n = p
    if not is_euclid_seed(m, n):
        raise ValueError(f"{p} is not a Euclid seed")
    lhs, rhs = m * m, 2 * m * n + n * n
    if lhs == rhs:                                   # provably unreachable
        raise AssertionError("no Euclid seed sits on the threshold")
    b2 = "decreases" if lhs < rhs else "increases"
    note = "Pell boundary layer" if on_pell_boundary(p) else \
           ("above the threshold" if lhs < rhs else "below the threshold")
    return {"B1": "increases", "B2": b2, "B3": "decreases", "regime": note}


# ===========================================================================
# D. Collision-based Euler factorisation
# ===========================================================================

def primitive_representations(N: int) -> List[Seed]:
    """All Euclid seeds (m,n) with m^2 + n^2 = N.

    Complexity: O(sqrt(N)) integer square-root tests.
    """
    out: List[Seed] = []
    for m in range(1, isqrt(N) + 1):
        r = N - m * m
        n = isqrt(r)
        if n * n == r and is_euclid_seed(m, n):
            out.append((m, n))
    return out


def collision_factor(N: int) -> Optional[Tuple[int, int, Seed, Seed]]:
    """Factor N from a collision of two Berggren nodes.

    If two distinct Euclid seeds (a,b) and (c,d) satisfy
    a^2+b^2 = c^2+d^2 = N with N odd, then Euler's identity
        (ac+bd)(ad+bc) = (a^2+b^2) cd + (c^2+d^2) ab = N (ab+cd)
    shows N | (ac+bd)(ad+bc).  Writing g = gcd(N, ac+bd) and
    h = gcd(N, ad+bc), primitivity and oddness force gcd(g,h) = 1, hence
    g h = N with 1 < g, h < N.  If N = pq is a semiprime the two factors are
    exactly p and q, so one collision is a complete factorisation.

    Returns (g, h, seed1, seed2), or None when N carries fewer than two
    primitive representations.

    Complexity: O(sqrt(N)) to find the representations, O(log N) for the two
    gcds.  The geometry does not improve on this: the hyperbolic ball that is
    guaranteed to contain a collision for N already contains Theta(N) nodes.
    """
    if N % 2 == 0:
        return None
    R = primitive_representations(N)
    if len(R) < 2:
        return None
    (a, b), (c, d) = R[0], R[1]
    g, h = gcd(N, a * c + b * d), gcd(N, a * d + b * c)
    assert g * h == N and 1 < g < N and 1 < h < N
    return (g, h, (a, b), (c, d))


# ===========================================================================
# Self-test
# ===========================================================================

def _main() -> None:
    print("A. Berggren descent")
    for p in [(2, 1), (12, 5), (8, 1), (7, 4), (169, 70)]:
        w = berggren_descent(p)
        assert berggren_ascend(w) == p
        print(f"   {str(p):>10}  depth {len(w):>3}  {' '.join(w) or '(root)'}")

    print("\nB. Exact localisation")
    for p in [(2, 1), (4, 1), (5, 2), (169, 70)]:
        print("  ", localise_node(*p))

    print("\nC. Branch direction oracle (checked against the true residuals)")
    for p in [(2, 1), (4, 1), (5, 2), (7, 4), (29, 12)]:
        o = branch_direction_oracle(p)
        r = localise_node(*p).residual
        real = {k: ("increases" if localise_node(*v).residual > r
                    else "decreases")
                for k, v in berggren_children(p).items()}
        assert all(o[k] == real[k] for k in ("B1", "B2", "B3")), (p, o, real)
        print(f"   {str(p):>10}  B1 {o['B1']}, B2 {o['B2']}, B3 {o['B3']}"
              f"   [{o['regime']}]")

    print("\nD. Collision factoring")
    for N in [65, 85, 221, 1105, 32045, 1000009]:
        res = collision_factor(N)
        assert res is not None
        g, h, p1, p2 = res
        print(f"   N = {N:>9}  = {g} x {h}   from {p1} and {p2}")

    print("\nall self-tests passed")


if __name__ == "__main__":
    _main()

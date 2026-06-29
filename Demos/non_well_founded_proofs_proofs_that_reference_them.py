"""
Non-Well-Founded Proofs as Self-Similarity
==========================================

Numerical demonstrations of the central thesis: a self-referential definition
x = f(x) names a *unique* object exactly when its defining loop is a contraction,
and that unique object is a self-similar fixed point.

Everything is self-contained: pure Python standard library, type-hinted, with all
helper functions inlined. Run with:  python3 demo.py
"""

from __future__ import annotations

import math
from typing import Callable, List, Tuple


# ---------------------------------------------------------------------------
# 1. The geometric series as a self-referential value:  S = a + r * S
# ---------------------------------------------------------------------------

def geom_value(a: float, r: float) -> float:
    """Closed form of the self-referential equation S = a + r*S, valid for r != 1."""
    if r == 1.0:
        raise ValueError("r = 1: the self-referential loop does not contract (no unique value).")
    return a / (1.0 - r)


def geom_partial_sum(a: float, r: float, n: int) -> float:
    """Direct partial sum a + a r + ... + a r^(n-1)."""
    total: float = 0.0
    term: float = a
    for _ in range(n):
        total += term
        term *= r
    return total


def demo_geometric_series() -> None:
    print("=" * 70)
    print("1. GEOMETRIC SERIES  S = a + r*S   (self-consistency & uniqueness)")
    print("=" * 70)
    a, r = 3.0, 0.5
    S = geom_value(a, r)
    print(f"  a = {a}, r = {r}")
    print(f"  closed form  S = a/(1-r)            = {S:.10f}")
    print(f"  check self-referential eq a + r*S   = {a + r * S:.10f}")
    print(f"  partial sum (200 terms)             = {geom_partial_sum(a, r, 200):.10f}")
    # boundary case r = 1: contraction is lost, uniqueness collapses
    print("  boundary r = 1: equation x = a + x forces a = 0  -> no unique solution")
    print()


# ---------------------------------------------------------------------------
# 2. The geometric stream:  tail(s) = scale_r(s),  head(s) = a
#    Self-similar infinite object, unique by bisimulation.
# ---------------------------------------------------------------------------

def geom_stream(a: float, r: float, n: int) -> List[float]:
    """First n entries of the stream G_{a,r}(k) = a * r^k."""
    return [a * (r ** k) for k in range(n)]


def scale(seq: List[float], r: float) -> List[float]:
    """Multiply every entry by r (the 'scale_r' observation)."""
    return [r * x for x in seq]


def tail(seq: List[float]) -> List[float]:
    """Drop the head."""
    return seq[1:]


def demo_geometric_stream() -> None:
    print("=" * 70)
    print("2. GEOMETRIC STREAM   tail(s) = scale_r(s)   (self-similarity law)")
    print("=" * 70)
    a, r, n = 1.0, 0.5, 8
    s = geom_stream(a, r, n)
    lhs = scale(s, r)[: n - 1]   # scale the whole stream, then look at first n-1 entries
    rhs = tail(s)                # the tail
    print(f"  stream G_(a={a}, r={r}) : {[round(x, 4) for x in s]}")
    print(f"  scale_r(stream)         : {[round(x, 4) for x in lhs]}")
    print(f"  tail(stream)            : {[round(x, 4) for x in rhs]}")
    print(f"  self-similarity holds   : {all(abs(x - y) < 1e-12 for x, y in zip(lhs, rhs))}")
    print()


# ---------------------------------------------------------------------------
# 3. The affine attractor:  f(x) = c*x + b,  fixed point x* = b/(1-c)
#    with geometric error bound |f^k(x0) - x*| <= |c|^k |x0 - x*|.
# ---------------------------------------------------------------------------

def affine_fixed_point(c: float, b: float) -> float:
    """Unique fixed point of f(x) = c*x + b for |c| < 1."""
    if abs(c) >= 1.0:
        raise ValueError("|c| >= 1: f is not a contraction; no unique attractor.")
    return b / (1.0 - c)


def banach_iterate(c: float, b: float, x0: float, k: int) -> List[float]:
    """Return the orbit x0, f(x0), ..., f^k(x0)."""
    orbit: List[float] = [x0]
    x = x0
    for _ in range(k):
        x = c * x + b
        orbit.append(x)
    return orbit


def demo_affine_attractor() -> None:
    print("=" * 70)
    print("3. AFFINE ATTRACTOR  f(x) = c*x + b   (convergence + error bound)")
    print("=" * 70)
    c, b, x0 = 0.6, 2.0, 50.0
    xstar = affine_fixed_point(c, b)
    orbit = banach_iterate(c, b, x0, 20)
    print(f"  c = {c}, b = {b}, start x0 = {x0}")
    print(f"  fixed point x* = b/(1-c) = {xstar:.10f}")
    print(f"  {'k':>3} | {'f^k(x0)':>16} | {'actual err':>14} | {'bound |c|^k*e0':>16}")
    e0 = abs(x0 - xstar)
    for k in [0, 2, 5, 10, 20]:
        err = abs(orbit[k] - xstar)
        bound = (abs(c) ** k) * e0
        print(f"  {k:>3} | {orbit[k]:>16.10f} | {err:>14.3e} | {bound:>16.3e}")
    print()


# ---------------------------------------------------------------------------
# 4. Metallic ratios:  phi_m = m + 1/phi_m,  phi_m^2 = m*phi_m + 1.
# ---------------------------------------------------------------------------

def metallic_ratio(m: int) -> float:
    """The m-th metallic ratio (m=1 golden, m=2 silver, m=3 bronze)."""
    return (m + math.sqrt(m * m + 4)) / 2.0


def metallic_continued_fraction(m: int, depth: int) -> float:
    """Evaluate [m; m, m, ...] truncated at given depth (contraction g(x)=m+1/x)."""
    x: float = float(m)
    for _ in range(depth):
        x = m + 1.0 / x
    return x


def demo_metallic_ratios() -> None:
    print("=" * 70)
    print("4. METALLIC RATIOS   phi_m = m + 1/phi_m,   phi_m^2 = m*phi_m + 1")
    print("=" * 70)
    names = {1: "golden", 2: "silver", 3: "bronze"}
    for m in (1, 2, 3):
        phi = metallic_ratio(m)
        cf = metallic_continued_fraction(m, 40)
        quad = phi * phi - (m * phi + 1.0)            # should be ~0
        gnomon = 1.0 / (phi - m)                      # ratio after removing m squares
        print(f"  m={m} ({names[m]:>6}): phi = {phi:.10f}")
        print(f"            continued fraction [m;m,...]      = {cf:.10f}")
        print(f"            quadratic residual phi^2-m*phi-1  = {quad:.2e}")
        print(f"            gnomon ratio 1/(phi-m)            = {gnomon:.10f}  (= phi)")
    print()


# ---------------------------------------------------------------------------
# 5. Similarity dimension:  k * r^D = 1,  D = log k / log(1/r).
# ---------------------------------------------------------------------------

def similarity_dimension(k: int, r: float) -> float:
    """Solution D of the balance equation k * r^D = 1 for k >= 1, 0 < r < 1."""
    if not (0.0 < r < 1.0):
        raise ValueError("require 0 < r < 1")
    return math.log(k) / math.log(1.0 / r)


def demo_similarity_dimension() -> None:
    print("=" * 70)
    print("5. SIMILARITY DIMENSION   k * r^D = 1,   D = log k / log(1/r)")
    print("=" * 70)
    examples: List[Tuple[str, int, float]] = [
        ("segment (halves)", 2, 0.5),
        ("Cantor set", 2, 1.0 / 3.0),
        ("Koch curve", 4, 1.0 / 3.0),
        ("Sierpinski triangle", 3, 0.5),
    ]
    for name, k, r in examples:
        D = similarity_dimension(k, r)
        balance = k * (r ** D)   # should be ~1
        print(f"  {name:>20}: k={k}, r={r:.4f}  ->  D = {D:.6f}   (k*r^D = {balance:.6f})")
    print()


# ---------------------------------------------------------------------------
# 6. Proof-theoretic transport: which self-referential loops have a fixed point?
# ---------------------------------------------------------------------------

def height_fixed_point(unfold: Callable[[int], int], max_iter: int = 1000) -> Tuple[bool, int]:
    """
    Search for a finite fixed point h = unfold(h) of a height functional,
    starting from h = 0.  Returns (found, value).

    - For 'P => P' the functional is constant h -> 1: fixed point 1 (valid, height 1).
    - For the liar the functional is h -> h + 1: no fixed point (invalid, undefined height).
    """
    h = 0
    for _ in range(max_iter):
        nxt = unfold(h)
        if nxt == h:
            return True, h
        h = nxt
    return False, h


def demo_proof_theory() -> None:
    print("=" * 70)
    print("6. NON-WELL-FOUNDED PROOFS   (contraction = guardedness)")
    print("=" * 70)
    # P => P : assume P, conclude P. Loop closes in one step: functional h -> 1.
    ok_pp, h_pp = height_fixed_point(lambda h: 1)
    print(f"  proof of 'P => P'  (functional h -> 1): "
          f"fixed point found = {ok_pp}, height = {h_pp}   -> VALID")
    # liar: 'this is unprovable' -> functional h -> h + 1, equation h = h+1 unsolvable.
    ok_liar, _ = height_fixed_point(lambda h: h + 1, max_iter=200)
    print(f"  liar 'this is unprovable' (functional h -> h+1): "
          f"fixed point found = {ok_liar}             -> INVALID (no fixed point)")
    print()


def main() -> None:
    demo_geometric_series()
    demo_geometric_stream()
    demo_affine_attractor()
    demo_metallic_ratios()
    demo_similarity_dimension()
    demo_proof_theory()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()

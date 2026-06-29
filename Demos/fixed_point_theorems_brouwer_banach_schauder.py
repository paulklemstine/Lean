"""
Numerical demonstrations for:

    Fixed Point Theorems via Discrete Parity:
    Sperner, Brouwer, Banach, and the Shadow of Schauder

Each demo exercises one of the formalized main results:

  * sperner_parity / sperner_exists_change  -> 1D Sperner lemma (parity engine)
  * brouwer_one_dim                          -> 1D Brouwer fixed point theorem
  * affine_iterate_tendsto                   -> affine Banach / Picard iteration
  * affine_fixedPoint_mem_Icc                -> Schauder localization (n = 1)

Self-contained: standard library only.
"""

from __future__ import annotations

import math
from typing import Callable, List, Optional, Tuple


# ---------------------------------------------------------------------------
# 1. One-dimensional Sperner lemma: parity of colour changes
# ---------------------------------------------------------------------------

def changes_count(coloring: List[bool], n: int) -> int:
    """Number of bichromatic edges among the first ``n`` edges of the path.

    Mirrors the Lean definition ``changes``:
        #{ i < n : coloring[i] != coloring[i+1] }.
    """
    return sum(1 for i in range(n) if coloring[i] != coloring[i + 1])


def sperner_parity_holds(coloring: List[bool], n: int) -> bool:
    """Theorem `sperner_parity`: changes(n) is odd  <=>  coloring[0] != coloring[n]."""
    is_odd = changes_count(coloring, n) % 2 == 1
    endpoints_differ = coloring[0] != coloring[n]
    return is_odd == endpoints_differ


def sperner_first_change(coloring: List[bool], n: int) -> Optional[int]:
    """Corollary `sperner_exists_change`: if endpoints differ, return a witness
    index ``i < n`` with coloring[i] != coloring[i+1]; otherwise None when no
    change exists."""
    for i in range(n):
        if coloring[i] != coloring[i + 1]:
            return i
    return None


def demo_sperner() -> None:
    print("=" * 70)
    print("DEMO 1  --  One-dimensional Sperner lemma (parity engine)")
    print("=" * 70)
    colorings = [
        [True, True, False, True, False],   # endpoints differ -> odd changes
        [True, False, False, False, True],  # endpoints agree  -> even changes
        [False, True, True, True, True],    # endpoints differ -> odd changes
    ]
    for c in colorings:
        n = len(c) - 1
        cnt = changes_count(c, n)
        parity_ok = sperner_parity_holds(c, n)
        witness = sperner_first_change(c, n)
        ends = "differ" if c[0] != c[n] else "agree"
        print(f"  coloring={[int(x) for x in c]}  changes={cnt} "
              f"(endpoints {ends})  parity-theorem holds: {parity_ok}")
        if c[0] != c[n]:
            assert witness is not None
            print(f"      -> guaranteed change at edge ({witness},{witness+1}); "
                  f"odd count {cnt} is never zero")
        assert parity_ok
    print()


# ---------------------------------------------------------------------------
# 2. One-dimensional Brouwer fixed point theorem
# ---------------------------------------------------------------------------

def brouwer_fixed_point(
    f: Callable[[float], float],
    lo: float = 0.0,
    hi: float = 1.0,
    tol: float = 1e-12,
    max_iter: int = 200,
) -> float:
    """Locate a fixed point of a continuous self-map of [lo, hi] by bisecting
    g(x) = f(x) - x.  Existence is guaranteed by `brouwer_one_dim`: g(lo) >= 0
    and g(hi) <= 0, so the discrete sign change (Sperner, Corollary 3.3) brackets
    a root that bisection refines."""
    g = lambda x: f(x) - x
    a, b = lo, hi
    ga, gb = g(a), g(b)
    assert ga >= -1e-15 and gb <= 1e-15, "f must map [lo,hi] into itself"
    for _ in range(max_iter):
        m = 0.5 * (a + b)
        gm = g(m)
        if abs(gm) < tol or (b - a) < tol:
            return m
        # keep the sub-interval where the sign changes
        if (ga <= 0) != (gm <= 0):
            b, gb = m, gm
        else:
            a, ga = m, gm
    return 0.5 * (a + b)


def demo_brouwer() -> None:
    print("=" * 70)
    print("DEMO 2  --  One-dimensional Brouwer fixed point theorem")
    print("=" * 70)
    maps: List[Tuple[str, Callable[[float], float]]] = [
        ("f(x) = cos(x) * x + 0.3", lambda x: math.cos(x) * x + 0.3),
        ("f(x) = (x + 0.7) / 2",    lambda x: (x + 0.7) / 2.0),
        ("f(x) = x**2 * 0.5 + 0.25", lambda x: 0.5 * x * x + 0.25),
    ]
    for name, f in maps:
        xstar = brouwer_fixed_point(f, 0.0, 1.0)
        residual = abs(f(xstar) - xstar)
        print(f"  {name:28s}  x* = {xstar:.10f}  |f(x*)-x*| = {residual:.2e}")
        assert 0.0 <= xstar <= 1.0
        assert residual < 1e-6
    print()


# ---------------------------------------------------------------------------
# 3. Affine Banach contraction: Picard iteration -> b/(1-a)
# ---------------------------------------------------------------------------

def affine_fixed_point(a: float, b: float) -> float:
    """Closed-form fixed point x* = b / (1 - a) of f(x) = a x + b (a != 1)."""
    return b / (1.0 - a)


def affine_iterate(a: float, b: float, x0: float, n: int) -> float:
    """n-fold iterate of f(x) = a x + b starting at x0."""
    x = x0
    for _ in range(n):
        x = a * x + b
    return x


def affine_error_bound(a: float, b: float, x0: float, n: int) -> float:
    """Exact a-posteriori error |f^[n](x0) - x*| = |a|^n * |x0 - x*|
    (Remark 6.2), equivalently |a|^n / |1-a| * |x0 - f(x0)|."""
    xstar = affine_fixed_point(a, b)
    return abs(a) ** n * abs(x0 - xstar)


def demo_banach() -> None:
    print("=" * 70)
    print("DEMO 3  --  Affine Banach contraction (Picard convergence)")
    print("=" * 70)
    cases: List[Tuple[float, float, float]] = [
        (0.5, 3.0, 0.0),    # x* = 6
        (-0.8, 1.0, 10.0),  # oscillating contraction, x* = 1/1.8
        (0.9, -2.0, 5.0),   # slow contraction, x* = -20
    ]
    for a, b, x0 in cases:
        xstar = affine_fixed_point(a, b)
        print(f"  f(x) = {a}*x + {b}   x* = b/(1-a) = {xstar:.6f}   x0 = {x0}")
        for n in (1, 5, 10, 25, 50):
            xn = affine_iterate(a, b, x0, n)
            actual = abs(xn - xstar)
            predicted = affine_error_bound(a, b, x0, n)
            print(f"      n={n:>3}  x_n={xn:>14.9f}  |x_n-x*|={actual:.3e}  "
                  f"bound={predicted:.3e}  exact={math.isclose(actual, predicted, rel_tol=1e-9, abs_tol=1e-12)}")
            assert actual <= predicted + 1e-9
        assert abs(affine_iterate(a, b, x0, 200) - xstar) < 1e-6
    print()


# ---------------------------------------------------------------------------
# 4. Schauder shadow: affine fixed-point localization in an interval
# ---------------------------------------------------------------------------

def maps_interval_into_itself(a: float, b: float, lo: float, hi: float) -> bool:
    """For 0 <= a < 1 (monotone increasing), f([lo,hi]) subset [lo,hi]
    iff f(lo) >= lo and f(hi) <= hi."""
    assert 0.0 <= a < 1.0
    return (a * lo + b >= lo - 1e-15) and (a * hi + b <= hi + 1e-15)


def demo_schauder() -> None:
    print("=" * 70)
    print("DEMO 4  --  Schauder shadow: affine fixed point trapped in interval")
    print("=" * 70)
    # Theorem affine_fixedPoint_mem_Icc: if f maps [lo,hi] into itself then
    # x* = b/(1-a) lies in [lo,hi].
    cases: List[Tuple[float, float, float, float]] = [
        (0.5, 2.0, 0.0, 10.0),   # x* = 4 in [0,10]
        (0.25, 3.0, 1.0, 5.0),   # x* = 4 in [1,5]
        (0.9, 0.5, 0.0, 6.0),    # x* = 5 in [0,6]
    ]
    for a, b, lo, hi in cases:
        xstar = affine_fixed_point(a, b)
        traps = maps_interval_into_itself(a, b, lo, hi)
        inside = lo <= xstar <= hi
        print(f"  f(x)={a}*x+{b}  interval=[{lo},{hi}]  maps-into-itself={traps}"
              f"  x*={xstar:.4f}  in interval: {inside}")
        if traps:
            assert inside, "Schauder localization must hold"
    print()


# ---------------------------------------------------------------------------

def main() -> None:
    demo_sperner()
    demo_brouwer()
    demo_banach()
    demo_schauder()
    print("All demos completed: every formalized result verified numerically.")


if __name__ == "__main__":
    main()

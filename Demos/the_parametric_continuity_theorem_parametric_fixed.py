"""
Parametric Fixed-Point Theory --- Numerical Demonstrations
==========================================================

This script gives concrete, runnable numerical illustrations of the five core
results of parametric fixed-point theory.  Everything is self-contained: only
the Python standard library is used.

The mathematical objects are:

  * A *K-contraction* on a metric space (X, d) is a map f : X -> X with
        d(f(x), f(y)) <= K * d(x, y)   for all x, y,   with 0 <= K < 1.
    By Banach's theorem it has a unique fixed point x* = f(x*), reachable by
    iterating f from any starting point.

The results demonstrated below are:

  1. Fixed-point stability:
        d(x_f, x_g) <= d(f(x_g), g(x_g)) / (1 - K)
     where f is a K-contraction with fixed point x_f and g is ANY map with
     fixed point x_g.

  2. Lipschitz parametric Banach theorem (explicit constant):
     for a family F_t of K-contractions that is L-Lipschitz in the parameter,
        d(x*(s), x*(t)) <= (L / (1 - K)) * d(s, t).

  3. Equivariance of fixed points: an intertwining symmetry phi with
        phi(f(x)) = f'(phi(x))
     sends the fixed point of f to the fixed point of f'.

  4. Non-autonomous composition rate: composing n contractions with constants
     K_0, ..., K_{n-1} yields a contraction with constant prod_i K_i.

  5. Sharpness at K = 1: the translation x -> x + 1 is a 1-Lipschitz isometry
     of the real line with NO fixed point, so the hypothesis K < 1 is essential.
"""

from __future__ import annotations

from math import isclose
from typing import Callable, List, Sequence


# ---------------------------------------------------------------------------
# Basic utilities
# ---------------------------------------------------------------------------

def fixed_point(
    f: Callable[[float], float],
    x0: float = 0.0,
    iters: int = 200,
) -> float:
    """Compute the fixed point of a contraction f by Picard iteration.

    Iterating any contraction from any starting point converges geometrically
    to the unique fixed point (Banach's theorem).
    """
    x = x0
    for _ in range(iters):
        x = f(x)
    return x


def iterated_comp(
    gs: Sequence[Callable[[float], float]],
) -> Callable[[float], float]:
    """Return the composition g_{n-1} . ... . g_0 of a list of maps.

    This mirrors the Lean definition `iteratedComp`, applied left-to-right:
    the input is first passed through gs[0], then gs[1], and so on.
    """
    def composed(x: float) -> float:
        for g in gs:
            x = g(x)
        return x
    return composed


# ---------------------------------------------------------------------------
# 1. Fixed-point stability bound
# ---------------------------------------------------------------------------

def demo_stability() -> None:
    """Verify d(x_f, x_g) <= d(f(x_g), g(x_g)) / (1 - K)."""
    print("=" * 70)
    print("1. FIXED-POINT STABILITY BOUND")
    print("=" * 70)

    K = 0.6
    # f is a genuine K-contraction with fixed point 2.0  (f(x) = 0.6 x + 0.8).
    f: Callable[[float], float] = lambda x: K * x + 0.8
    # g is an ARBITRARY map (here affine with a DIFFERENT fixed point, 4.0).
    g: Callable[[float], float] = lambda x: 0.25 * x + 3.0

    x_f = fixed_point(f)
    x_g = fixed_point(g)

    actual = abs(x_f - x_g)
    bound = abs(f(x_g) - g(x_g)) / (1 - K)

    print(f"  K               = {K}")
    print(f"  fixed point x_f = {x_f:.6f}")
    print(f"  fixed point x_g = {x_g:.6f}")
    print(f"  actual  d(x_f, x_g)                 = {actual:.6f}")
    print(f"  bound   d(f(x_g), g(x_g)) / (1 - K) = {bound:.6f}")
    print(f"  bound holds: {actual <= bound + 1e-9}")
    print()


# ---------------------------------------------------------------------------
# 2. Lipschitz parametric Banach theorem
# ---------------------------------------------------------------------------

def demo_lipschitz_parametric() -> None:
    """Verify d(x*(s), x*(t)) <= (L / (1 - K)) * d(s, t)."""
    print("=" * 70)
    print("2. LIPSCHITZ PARAMETRIC BANACH THEOREM (explicit constant)")
    print("=" * 70)

    K = 0.5  # each F_t is a 0.5-contraction
    L = 1.0  # the family is 1-Lipschitz in the parameter t

    # F_t(x) = K x + t.  Fixed point: x*(t) = t / (1 - K).
    def F(t: float) -> Callable[[float], float]:
        return lambda x: K * x + t

    def x_star(t: float) -> float:
        return fixed_point(F(t))

    lipschitz_const = L / (1 - K)
    print(f"  K = {K},  L = {L},  predicted Lipschitz constant L/(1-K) = {lipschitz_const}")

    worst_ratio = 0.0
    for s, t in [(0.0, 1.0), (1.0, 3.0), (-2.0, 2.0), (0.5, 0.7)]:
        d_param = abs(s - t)
        d_fix = abs(x_star(s) - x_star(t))
        bound = lipschitz_const * d_param
        ratio = d_fix / d_param if d_param else 0.0
        worst_ratio = max(worst_ratio, ratio)
        print(f"  s={s:+.1f}, t={t:+.1f}: d(x*(s),x*(t))={d_fix:.4f} <= {bound:.4f} ? "
              f"{d_fix <= bound + 1e-9}")
    print(f"  worst observed ratio = {worst_ratio:.4f}  (<= {lipschitz_const})")
    print()


# ---------------------------------------------------------------------------
# 3. Equivariance of fixed points
# ---------------------------------------------------------------------------

def demo_equivariance() -> None:
    """Verify phi(x*) = x*' when phi intertwines f and f'."""
    print("=" * 70)
    print("3. EQUIVARIANCE OF FIXED POINTS")
    print("=" * 70)

    K = 0.4
    # f' is a K-contraction with fixed point.
    f_prime: Callable[[float], float] = lambda y: K * y + 3.0
    # phi is the affine symmetry phi(x) = 2 x + 5.
    phi: Callable[[float], float] = lambda x: 2.0 * x + 5.0
    # Choose f so that phi(f(x)) = f'(phi(x)) holds identically:
    #   f(x) = phi^{-1}(f'(phi(x))).  With these affine maps this gives a
    #   genuine contraction conjugate to f'.
    phi_inv: Callable[[float], float] = lambda z: (z - 5.0) / 2.0
    f: Callable[[float], float] = lambda x: phi_inv(f_prime(phi(x)))

    x = fixed_point(f)
    x_prime = fixed_point(f_prime)

    # Sanity check: the intertwining relation holds.
    test_pt = 1.234
    intertwine_ok = isclose(phi(f(test_pt)), f_prime(phi(test_pt)), abs_tol=1e-9)

    print(f"  intertwining phi(f(x)) = f'(phi(x)) holds: {intertwine_ok}")
    print(f"  fixed point of f       x  = {x:.6f}")
    print(f"  fixed point of f'      x' = {x_prime:.6f}")
    print(f"  phi(x)                    = {phi(x):.6f}")
    print(f"  phi(x) == x' :  {isclose(phi(x), x_prime, abs_tol=1e-6)}")
    print()


# ---------------------------------------------------------------------------
# 4. Non-autonomous composition rate
# ---------------------------------------------------------------------------

def demo_composition_rate() -> None:
    """Verify d(C(x), C(y)) <= (prod K_i) d(x, y) for C = g_{n-1}...g_0."""
    print("=" * 70)
    print("4. NON-AUTONOMOUS COMPOSITION RATE")
    print("=" * 70)

    Ks: List[float] = [0.5, 0.8, 0.3, 0.9]
    # g_i(x) = K_i x + b_i ; the additive parts are irrelevant to the rate.
    bs: List[float] = [0.1, -0.2, 0.4, 0.05]
    gs: List[Callable[[float], float]] = [
        (lambda x, k=k, b=b: k * x + b) for k, b in zip(Ks, bs)
    ]

    C = iterated_comp(gs)

    product = 1.0
    for k in Ks:
        product *= k

    x, y = 3.0, -2.0
    actual = abs(C(x) - C(y))
    bound = product * abs(x - y)

    print(f"  individual constants K_i = {Ks}")
    print(f"  product prod_i K_i       = {product:.4f}")
    print(f"  d(C(x), C(y))            = {actual:.6f}")
    print(f"  (prod K_i) * d(x, y)     = {bound:.6f}")
    print(f"  bound holds (in fact equality for affine maps): "
          f"{isclose(actual, bound, abs_tol=1e-9)}")
    print()


# ---------------------------------------------------------------------------
# 5. Sharpness at K = 1
# ---------------------------------------------------------------------------

def demo_sharpness() -> None:
    """The translation x -> x + 1 is 1-Lipschitz with no fixed point."""
    print("=" * 70)
    print("5. SHARPNESS AT K = 1  (no fixed point)")
    print("=" * 70)

    shift: Callable[[float], float] = lambda x: x + 1.0

    # 1-Lipschitz (in fact an isometry): |shift(x) - shift(y)| = |x - y|.
    pairs = [(0.0, 5.0), (-3.0, 2.0), (1.5, 1.5)]
    is_isometry = all(
        isclose(abs(shift(a) - shift(b)), abs(a - b), abs_tol=1e-12)
        for a, b in pairs
    )
    print(f"  x -> x + 1 is an isometry (K = 1 exactly): {is_isometry}")

    # Iterating drifts to infinity --- there is no fixed point.
    x = 0.0
    for _ in range(10):
        x = shift(x)
    print(f"  after 10 iterations from 0: x = {x}  (drifts away, no convergence)")
    print(f"  fixed-point equation x + 1 = x has NO solution: confirmed")
    print("  => the hypothesis K < 1 in Banach's theorem is sharp.")
    print()


def main() -> None:
    demo_stability()
    demo_lipschitz_parametric()
    demo_equivariance()
    demo_composition_rate()
    demo_sharpness()


if __name__ == "__main__":
    main()

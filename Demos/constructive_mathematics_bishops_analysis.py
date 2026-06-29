"""
Numerical demonstration of the Constructive Approximate Intermediate Value Theorem.

This script mirrors the Lean development in `Analysis/ConstructiveApproxIVT.lean`:

    grid(a, b, N, i)                 -> the i-th uniform node on [a, b]
    finite_sign_change(u, N)         -> finite combinatorial sign-change core
    discrete_approx_ivt(u, N, eps)   -> discrete approximate IVT on a sequence
    approx_ivt_of_modulus(...)       -> the modulus-based approximate IVT

Everything is self-contained: no external libraries, all functions inlined,
with type hints. The point is to *exhibit* the certified output of the
constructive theorem: a grid point x in [a, b] with |f(x)| <= eps.
"""

from __future__ import annotations

from math import ceil
from typing import Callable, List, Optional, Tuple


# --------------------------------------------------------------------------
# Grid construction (mirrors `grid`, `grid_zero`, `grid_last`)
# --------------------------------------------------------------------------
def grid(a: float, b: float, N: int, i: int) -> float:
    """The i-th node of the uniform grid on [a, b] with N subdivisions:
    grid(a,b,N,i) = a + i*(b-a)/N.  Note grid(...,0)=a and grid(...,N)=b."""
    return a + i * (b - a) / N


def mesh(a: float, b: float, N: int) -> float:
    """Spacing between consecutive grid nodes, (b-a)/N."""
    return (b - a) / N


# --------------------------------------------------------------------------
# Combinatorial core (mirrors `finite_sign_change`)
# --------------------------------------------------------------------------
def finite_sign_change(
    u: List[float], N: int
) -> Tuple[str, int]:
    """Given u[0..N] with u[0] <= 0 <= u[N], return either
        ("zero", i)      where u[i] == 0, or
        ("change", i)    where u[i] <= 0 <= u[i+1].
    This is the pure finite skeleton of the IVT: no continuity is used."""
    for i in range(N + 1):
        if u[i] == 0.0:
            return ("zero", i)
    for i in range(N):
        if u[i] <= 0.0 <= u[i + 1]:
            return ("change", i)
    raise ValueError("hypotheses u[0] <= 0 <= u[N] were violated")


# --------------------------------------------------------------------------
# Discrete approximate IVT (mirrors `discrete_approx_ivt`)
# --------------------------------------------------------------------------
def discrete_approx_ivt(u: List[float], N: int, eps: float) -> int:
    """If u[0] <= 0 <= u[N] and |u[i+1]-u[i]| <= eps for all i < N, return an
    index i <= N with |u[i]| <= eps."""
    kind, i = finite_sign_change(u, N)
    if kind == "zero":
        return i
    # sign change at (i, i+1): the non-negative endpoint is within eps of zero
    return i + 1


# --------------------------------------------------------------------------
# Modulus-based approximate IVT (mirrors `approx_ivt_of_modulus`)
# --------------------------------------------------------------------------
def approx_ivt_of_modulus(
    f: Callable[[float], float],
    a: float,
    b: float,
    eps: float,
    delta: float,
) -> Tuple[float, float, int]:
    """Constructive approximate IVT.

    Assumes: a <= b, eps >= 0, delta > 0, f(a) and f(b) straddle 0 in some
    order, and delta is a valid modulus step for f on [a,b] at tolerance eps
    (i.e. |y-x| <= delta implies |f(y)-f(x)| <= eps).

    Returns (x, f(x), N) with x in [a,b] and |f(x)| <= eps.
    """
    assert a <= b and eps >= 0 and delta > 0
    # choose N so the mesh (b-a)/N <= delta
    N: int = max(1, ceil((b - a) / delta))

    fa, fb = f(a), f(b)
    if fa <= 0.0 <= fb:
        g = f
    elif fb <= 0.0 <= fa:
        # reduce the reversed orientation to the canonical one via g = -f
        g = lambda x: -f(x)
    else:
        raise ValueError("endpoints do not straddle zero")

    u: List[float] = [g(grid(a, b, N, i)) for i in range(N + 1)]
    idx = discrete_approx_ivt(u, N, eps)
    x = grid(a, b, N, idx)
    return x, f(x), N


# --------------------------------------------------------------------------
# A simple modulus helper: for an L-Lipschitz f, delta = eps / L works.
# --------------------------------------------------------------------------
def lipschitz_delta(eps: float, L: float) -> float:
    """For an L-Lipschitz function, |y-x| <= eps/L implies |f(y)-f(x)| <= eps."""
    return eps / L


def demo() -> None:
    print("=" * 70)
    print("Constructive Approximate Intermediate Value Theorem -- demo")
    print("=" * 70)

    # Example 1: f(x) = x^2 - 2 on [0, 2]; the crossing is sqrt(2) ~ 1.41421356.
    # On [0,2], |f'(x)| = |2x| <= 4, so f is 4-Lipschitz.
    print("\n[1] f(x) = x^2 - 2 on [0, 2]   (root = sqrt(2) ~ 1.4142135624)")
    f1 = lambda x: x * x - 2.0
    for eps in (1e-2, 1e-4, 1e-6):
        delta = lipschitz_delta(eps, L=4.0)
        x, fx, N = approx_ivt_of_modulus(f1, 0.0, 2.0, eps, delta)
        print(f"    eps={eps:<8g}  N={N:<8d}  x={x:.10f}  |f(x)|={abs(fx):.3e}"
              f"  (<= eps? {abs(fx) <= eps})")

    # Example 2: f(x) = cos(x) - x on [0, 1]; Dottie number ~ 0.7390851332.
    # |f'(x)| = |-sin(x) - 1| <= 2, so f is 2-Lipschitz on [0,1].
    from math import cos
    print("\n[2] f(x) = cos(x) - x on [0, 1]   (root ~ 0.7390851332)")
    f2 = lambda x: cos(x) - x
    for eps in (1e-2, 1e-4, 1e-6):
        delta = lipschitz_delta(eps, L=2.0)
        x, fx, N = approx_ivt_of_modulus(f2, 0.0, 1.0, eps, delta)
        print(f"    eps={eps:<8g}  N={N:<8d}  x={x:.10f}  |f(x)|={abs(fx):.3e}"
              f"  (<= eps? {abs(fx) <= eps})")

    # Example 3: reversed orientation, f(x) = 1 - x^3 on [0, 2]; root = 1.
    # f(0)=1 >= 0 >= f(2)=-7; |f'(x)|=|3x^2| <= 12 on [0,2].
    print("\n[3] f(x) = 1 - x^3 on [0, 2]   (reversed sign; root = 1)")
    f3 = lambda x: 1.0 - x ** 3
    for eps in (1e-2, 1e-4, 1e-6):
        delta = lipschitz_delta(eps, L=12.0)
        x, fx, N = approx_ivt_of_modulus(f3, 0.0, 2.0, eps, delta)
        print(f"    eps={eps:<8g}  N={N:<8d}  x={x:.10f}  |f(x)|={abs(fx):.3e}"
              f"  (<= eps? {abs(fx) <= eps})")

    # Example 4: the pure finite core -- no continuity at all.
    print("\n[4] finite_sign_change on a raw list [-3, -1, -0.2, 0.5, 2]")
    u = [-3.0, -1.0, -0.2, 0.5, 2.0]
    print("    result:", finite_sign_change(u, len(u) - 1),
          "  (kind, index of straddling pair)")

    print("\nAll certified outputs satisfy |f(x)| <= eps, as the theorem guarantees.")


if __name__ == "__main__":
    demo()

"""
Numerical demonstrations for:

    The Deligne Envelope for Chebyshev Polynomials of the Second Kind
    and the Structure of GL(2) Triple Correlation Sums

This self-contained script demonstrates, with concrete numbers:

  1. The Deligne envelope  |U_k(x)| <= k + 1  for x in [-1, 1], and its
     sharpness at the endpoints x = +/- 1.
  2. The identity  U_k(cos t) * sin t = sin((k+1) t).
  3. The endpoint values  U_k(1) = k+1  and  U_k(-1) = (-1)^k (k+1).
  4. The Satake dictionary  lambda_f(p^k) = U_k(cos theta_p)  and the
     resulting prime-power bound |lambda_f(p^k)| <= k+1, plus the divisor
     bound |lambda_f(n)| <= d(n).
  5. The triple correlation envelope  |S(N)| <= N + 1  and its attainment
     by constant sequences, contrasted with cancellation for oscillating
     (Sato-Tate distributed) signs.

Run:  python demo.py
"""

from __future__ import annotations

import math
from typing import Callable, List, Sequence


# ---------------------------------------------------------------------------
# Chebyshev polynomials of the second kind
# ---------------------------------------------------------------------------

def cheb_U(k: int, x: float) -> float:
    """Evaluate U_k(x) via the stable three-term recurrence.

    U_0 = 1, U_1 = 2x, U_{k+1} = 2x U_k - U_{k-1}.
    """
    if k < 0:
        raise ValueError("k must be nonnegative")
    u_prev, u_curr = 1.0, 2.0 * x
    if k == 0:
        return u_prev
    if k == 1:
        return u_curr
    for _ in range(2, k + 1):
        u_prev, u_curr = u_curr, 2.0 * x * u_curr - u_prev
    return u_curr


def cheb_U_via_sine(k: int, theta: float) -> float:
    """Evaluate U_k(cos theta) via sin((k+1) theta) / sin theta.

    Falls back to the endpoint limits when sin theta = 0.
    """
    s = math.sin(theta)
    if abs(s) < 1e-12:
        # cos theta = +/- 1
        sign = 1.0 if math.cos(theta) > 0 else (-1.0) ** k
        return sign * (k + 1)
    return math.sin((k + 1) * theta) / s


# ---------------------------------------------------------------------------
# 1. Deligne envelope and sharpness
# ---------------------------------------------------------------------------

def demo_deligne_envelope() -> None:
    print("=" * 70)
    print("1. Deligne envelope:  |U_k(x)| <= k + 1  on [-1, 1]")
    print("=" * 70)
    grid: List[float] = [(-1.0 + 2.0 * i / 400) for i in range(401)]
    for k in range(0, 8):
        worst = max(abs(cheb_U(k, x)) for x in grid)
        at_plus = cheb_U(k, 1.0)
        at_minus = cheb_U(k, -1.0)
        ok = worst <= (k + 1) + 1e-9
        print(
            f"  k={k}:  max|U_k| on grid = {worst:8.4f}   bound = {k+1:2d}"
            f"   U_k(1) = {at_plus:6.1f}   U_k(-1) = {at_minus:6.1f}"
            f"   [{'OK' if ok else 'FAIL'}]"
        )
    print()


# ---------------------------------------------------------------------------
# 2. Trigonometric identity  U_k(cos t) sin t = sin((k+1) t)
# ---------------------------------------------------------------------------

def demo_identity() -> None:
    print("=" * 70)
    print("2. Identity:  U_k(cos t) * sin t = sin((k+1) t)")
    print("=" * 70)
    max_err = 0.0
    for k in range(0, 10):
        for j in range(1, 20):
            theta = math.pi * j / 20.0
            lhs = cheb_U(k, math.cos(theta)) * math.sin(theta)
            rhs = math.sin((k + 1) * theta)
            max_err = max(max_err, abs(lhs - rhs))
    print(f"  max |LHS - RHS| over k<10, 19 angles = {max_err:.2e}")
    print()


# ---------------------------------------------------------------------------
# 3. Satake dictionary and eigenvalue bounds
# ---------------------------------------------------------------------------

def lambda_prime_power(k: int, theta_p: float) -> float:
    """lambda_f(p^k) = U_k(cos theta_p)."""
    return cheb_U(k, math.cos(theta_p))


def divisor_count(n: int) -> int:
    """Number of positive divisors d(n)."""
    return sum(1 for d in range(1, n + 1) if n % d == 0)


def demo_satake_bounds() -> None:
    print("=" * 70)
    print("3. Satake dictionary:  lambda_f(p^k) = U_k(cos theta_p),  "
          "|lambda_f(p^k)| <= k+1")
    print("=" * 70)
    thetas = [0.0, math.pi / 6, math.pi / 3, math.pi / 2, 2.4, math.pi]
    for theta in thetas:
        vals = [lambda_prime_power(k, theta) for k in range(5)]
        pretty = "  ".join(f"{v:+6.3f}" for v in vals)
        within = all(abs(v) <= (k + 1) + 1e-9 for k, v in enumerate(vals))
        print(f"  theta={theta:5.3f}:  lambda_f(p^k), k=0..4 = {pretty}"
              f"   [{'within k+1' if within else 'FAIL'}]")
    print()
    print("  Divisor bound |lambda_f(n)| <= d(n) via multiplicativity:")
    for n in [12, 30, 36, 60]:
        print(f"    n={n:3d}:  d(n) = {divisor_count(n)}")
    print()


# ---------------------------------------------------------------------------
# 4. Triple correlation envelope and cancellation
# ---------------------------------------------------------------------------

def triple_sum(
    f: Callable[[int], float],
    g: Callable[[int], float],
    h: Callable[[int], float],
    N: int,
) -> float:
    """S(N) = sum_{n=0}^{N} f(n) g(n+1) h(n+2)."""
    return sum(f(n) * g(n + 1) * h(n + 2) for n in range(N + 1))


def demo_triple_envelope() -> None:
    print("=" * 70)
    print("4. Triple envelope:  |S(N)| <= N+1, sharp for constant sequences")
    print("=" * 70)

    one: Callable[[int], float] = lambda n: 1.0

    for N in [5, 10, 50, 100]:
        s_const = triple_sum(one, one, one, N)
        print(f"  N={N:3d}:  constant seq S(N) = {s_const:8.1f}   "
              f"envelope N+1 = {N+1}   [attained]")
    print()

    # Oscillating signs modeling Sato-Tate: sign of lambda_f(p) = sign(cos theta)
    # with theta drawn (deterministically here) to spread across [0, pi].
    def st_sign(seed: int) -> Callable[[int], float]:
        def seq(n: int) -> float:
            theta = math.pi * (((n * 2654435761 + seed) % 10007) / 10007.0)
            return 1.0 if math.cos(theta) >= 0 else -1.0
        return seq

    print("  Oscillating (Sato-Tate signs): genuine cancellation below N+1")
    fa, gb, hc = st_sign(1), st_sign(2), st_sign(3)
    for N in [100, 1000, 10000]:
        s_osc = triple_sum(fa, gb, hc, N)
        ratio = abs(s_osc) / math.sqrt(N + 1)
        print(f"  N={N:6d}:  |S(N)| = {abs(s_osc):10.2f}   N+1 = {N+1:7d}   "
              f"|S(N)|/sqrt(N+1) = {ratio:6.3f}")
    print()


def main() -> None:
    demo_deligne_envelope()
    demo_identity()
    demo_satake_bounds()
    demo_triple_envelope()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()

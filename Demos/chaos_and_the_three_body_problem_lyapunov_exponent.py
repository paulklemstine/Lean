"""
demo.py — Numerical demonstrations for
"Chaos and the Three-Body Problem: Lyapunov Exponent Bounds"

This standalone script illustrates, with concrete numbers, the main theorems:

  1. deriv_iterate_eq_prod        — derivative of an iterate is the orbit product
  2. log_abs_deriv_iterate_eq_sum — its logarithm is a Birkhoff sum
  3. abs_deriv_iterate_ge         — uniform expansion forces growth c^n
  4. ftle_ge_log / ftle_pos       — finite-time Lyapunov exponent >= log c > 0  (CHAOS)
  5. ftle_eq_log_of_uniform       — exact exponent log c for constant-stretch maps
  6. entropy_periodic_growth      — periodic-orbit growth rate of E_d is log d
  7. pesin_identity_uniform_model — entropy = Lyapunov exponent = log d

No third-party dependencies; only the standard library is used.
"""

from __future__ import annotations

import math
from typing import Callable, List, Tuple


# ----------------------------------------------------------------------------
# Core dynamical-systems utilities (all inlined, fully type-hinted)
# ----------------------------------------------------------------------------

def iterate(f: Callable[[float], float], n: int, x: float) -> float:
    """Return f^[n](x), the n-fold composition of f applied to x."""
    y: float = x
    for _ in range(n):
        y = f(y)
    return y


def orbit(f: Callable[[float], float], n: int, x: float) -> List[float]:
    """Return the forward orbit [x, f(x), ..., f^[n-1](x)] (length n)."""
    pts: List[float] = []
    y: float = x
    for _ in range(n):
        pts.append(y)
        y = f(y)
    return pts


def deriv_iterate_product(df: Callable[[float], float],
                          f: Callable[[float], float],
                          n: int, x: float) -> float:
    """(f^[n])'(x) via the chain rule: product of df along the orbit.

    This is `deriv_iterate_eq_prod`:  (f^[n])'(x) = prod_{i<n} f'(f^[i] x).
    """
    prod: float = 1.0
    for y in orbit(f, n, x):
        prod *= df(y)
    return prod


def log_abs_deriv_iterate_sum(df: Callable[[float], float],
                              f: Callable[[float], float],
                              n: int, x: float) -> float:
    """log|(f^[n])'(x)| via the Birkhoff sum of log|f'| along the orbit.

    This is `log_abs_deriv_iterate_eq_sum`:
        log|(f^[n])'(x)| = sum_{i<n} log|f'(f^[i] x)|.
    """
    total: float = 0.0
    for y in orbit(f, n, x):
        total += math.log(abs(df(y)))
    return total


def ftle(df: Callable[[float], float],
         f: Callable[[float], float],
         x: float, n: int) -> float:
    """Finite-time Lyapunov exponent: log|(f^[n])'(x)| / n   (Definition: ftle)."""
    if n < 1:
        raise ValueError("ftle requires n >= 1")
    return log_abs_deriv_iterate_sum(df, f, n, x) / n


def periodic_point_count(d: int, n: int) -> int:
    """Number of period-n points of E_d(x) = d*x mod 1, namely d^n - 1."""
    return d ** n - 1


# ----------------------------------------------------------------------------
# Example maps
# ----------------------------------------------------------------------------

def doubling_map(x: float) -> float:
    """E_2(x) = 2x mod 1, the canonical chaotic map (constant stretch 2)."""
    return (2.0 * x) % 1.0


def doubling_deriv(_x: float) -> float:
    """Derivative of E_2: constant 2 everywhere."""
    return 2.0


def expanding_map(d: int) -> Tuple[Callable[[float], float], Callable[[float], float]]:
    """Return (E_d, E_d') for E_d(x) = d*x mod 1; E_d' = d everywhere."""
    return (lambda x: (d * x) % 1.0, lambda _x: float(d))


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------

def demo_chain_rule() -> None:
    """Theorem 3.1/3.2: product = exp(Birkhoff sum), and they agree."""
    print("=" * 70)
    print("1-2. Chain rule + Birkhoff sum  (deriv_iterate_eq_prod, _eq_sum)")
    print("=" * 70)
    # A non-constant-stretch differentiable map to make the point non-trivial:
    #   f(x) = 1.5*x + 0.3*sin(x),  f'(x) = 1.5 + 0.3*cos(x)  (>= 1.2 > 1)
    f = lambda x: 1.5 * x + 0.3 * math.sin(x)
    df = lambda x: 1.5 + 0.3 * math.cos(x)
    x0, n = 0.4, 8
    prod = deriv_iterate_product(df, f, n, x0)
    s = log_abs_deriv_iterate_sum(df, f, n, x0)
    print(f"  (f^[{n}])'(x0)              = {prod:.10f}")
    print(f"  exp(sum log|f'| on orbit) = {math.exp(s):.10f}")
    print(f"  identity holds?           {math.isclose(prod, math.exp(s))}")
    print()


def demo_exponential_divergence() -> None:
    """Theorem 3.3: |(f^[n])'(x)| >= c^n for uniformly expanding f."""
    print("=" * 70)
    print("3. Exponential divergence  (abs_deriv_iterate_ge):  |(f^[n])'| >= c^n")
    print("=" * 70)
    f = lambda x: 1.5 * x + 0.3 * math.sin(x)
    df = lambda x: 1.5 + 0.3 * math.cos(x)
    c = 1.2  # since f'(x) = 1.5 + 0.3 cos x >= 1.2
    x0 = 0.4
    print(f"  uniform lower bound c = {c}")
    header_col = "|(f^[n])'(x)|"
    print(f"  {'n':>3} {header_col:>18} {'c^n':>14}  bound holds?")
    for n in range(1, 9):
        val = abs(deriv_iterate_product(df, f, n, x0))
        cn = c ** n
        print(f"  {n:>3} {val:>18.6f} {cn:>14.6f}  {val >= cn - 1e-9}")
    print()


def demo_positive_lyapunov() -> None:
    """Theorem 4.2/4.3: ftle >= log c > 0, and = log c for constant stretch."""
    print("=" * 70)
    print("4-5. Positive Lyapunov exponent  (ftle_ge_log, ftle_eq_log_of_uniform)")
    print("=" * 70)
    # Constant-stretch map E_2: ftle should equal log 2 exactly, for every n, x.
    log2 = math.log(2.0)
    print(f"  Doubling map E_2 (constant stretch c = 2),  log c = {log2:.6f}")
    for x0 in (0.1, 0.37, 0.823):
        vals = [ftle(doubling_deriv, doubling_map, x0, n) for n in (1, 5, 20)]
        print(f"   x0={x0:<6}  ftle(n=1)={vals[0]:.6f}  "
              f"ftle(n=5)={vals[1]:.6f}  ftle(n=20)={vals[2]:.6f}")
    print(f"   --> every value equals log 2 = {log2:.6f}  (exact, n-independent)")
    print()
    # Uniform lower bound case: f'(x) >= 1.2 => ftle >= log 1.2 > 0.
    f = lambda x: 1.5 * x + 0.3 * math.sin(x)
    df = lambda x: 1.5 + 0.3 * math.cos(x)
    c = 1.2
    print(f"  Variable-stretch map, c = {c}, log c = {math.log(c):.6f} > 0:")
    for n in (1, 5, 20, 100):
        val = ftle(df, f, 0.4, n)
        print(f"   ftle(n={n:<4}) = {val:.6f}  >= log c = {math.log(c):.6f}? "
              f"{val >= math.log(c) - 1e-9}")
    print()


def demo_entropy_and_pesin() -> None:
    """Theorem 5.2/5.3: periodic-orbit growth rate -> log d = Lyapunov exponent."""
    print("=" * 70)
    print("6-7. Entropy bridge  (entropy_periodic_growth, pesin_identity)")
    print("=" * 70)
    for d in (2, 3, 5):
        logd = math.log(d)
        f, df = expanding_map(d)
        lyap = ftle(df, f, 0.31, 30)  # constant stretch => exact log d
        print(f"  degree d = {d}:  log d = {logd:.6f}")
        print(f"   {'n':>3} {'P(d,n)=d^n-1':>14} {'log P / n':>12}  "
              f"lower bound log d - log2/n")
        for n in (1, 2, 5, 10, 20, 40):
            p = periodic_point_count(d, n)
            rate = math.log(p) / n
            lo = logd - math.log(2) / n
            print(f"   {n:>3} {p:>14} {rate:>12.6f}  {lo:>12.6f}")
        print(f"   entropy  -> log d = {logd:.6f}")
        print(f"   Lyapunov exponent  = {lyap:.6f}  (Pesin: equal to entropy)")
        print()


def main() -> None:
    print()
    print("Chaos and the Three-Body Problem: Lyapunov Exponent Bounds")
    print("Numerical demonstrations of the main theorems")
    print()
    demo_chain_rule()
    demo_exponential_divergence()
    demo_positive_lyapunov()
    demo_entropy_and_pesin()
    print("All demonstrations complete.")


if __name__ == "__main__":
    main()

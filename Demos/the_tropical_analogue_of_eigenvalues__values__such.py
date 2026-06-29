#!/usr/bin/env python3
"""
Numerical demonstrations of the theorems in Catalog/Algebra/DeepConnections.lean.

Demonstrates:
  1. Chebyshev polynomial evaluation and the composition theorem T_m(T_n(x)) = T_{mn}(x)
  2. Chebyshev degree verification
  3. Pell equation solutions and Brahmagupta composition
  4. Square roots of -1 modulo primes p ≡ 1 (mod 4)
  5. p-adic valuation ultrametric inequality
"""

from __future__ import annotations
import math
from typing import Callable


# ── Chebyshev Polynomials ──────────────────────────────────────────────────

def chebyshev_T(n: int, x: float) -> float:
    """Evaluate T_n(x) using the three-term recurrence."""
    if n == 0:
        return 1.0
    if n == 1:
        return x
    t_prev, t_curr = 1.0, x
    for _ in range(2, n + 1):
        t_prev, t_curr = t_curr, 2.0 * x * t_curr - t_prev
    return t_curr


def chebyshev_coefficients(n: int) -> list[int]:
    """Return the integer coefficients of T_n as a list [a_0, a_1, ..., a_n]."""
    if n == 0:
        return [1]
    if n == 1:
        return [0, 1]
    prev = [1]  # T_0
    curr = [0, 1]  # T_1
    for _ in range(2, n + 1):
        # T_{k+1} = 2*X*T_k - T_{k-1}
        # 2*X*T_k: shift curr right by 1 and multiply by 2
        shifted = [0] + [2 * c for c in curr]
        # Subtract prev (padded)
        new = shifted[:]
        for j in range(len(prev)):
            new[j] -= prev[j]
        prev, curr = curr, new
    return curr


def demo_chebyshev_composition() -> None:
    """Demonstrate T_m(T_n(x)) = T_{m*n}(x) for various m, n, x."""
    print("=" * 70)
    print("DEMO 1: Chebyshev Composition Theorem  T_m(T_n(x)) = T_{m·n}(x)")
    print("=" * 70)
    test_cases: list[tuple[int, int, float]] = [
        (2, 3, 0.5),
        (3, 4, -0.7),
        (5, 7, 0.0),
        (4, 6, 0.99),
        (10, 3, -0.33),
    ]
    for m, n, x in test_cases:
        lhs = chebyshev_T(m, chebyshev_T(n, x))
        rhs = chebyshev_T(m * n, x)
        print(f"  T_{m}(T_{n}({x})) = {lhs:.12f}")
        print(f"  T_{m * n}({x})      = {rhs:.12f}")
        print(f"  Difference:       = {abs(lhs - rhs):.2e}")
        print()


def demo_chebyshev_degree() -> None:
    """Verify that deg(T_n) = n for small n."""
    print("=" * 70)
    print("DEMO 2: Chebyshev Degree Theorem  deg(T_n) = n")
    print("=" * 70)
    for n in range(1, 11):
        coeffs = chebyshev_coefficients(n)
        degree = len(coeffs) - 1
        leading = coeffs[-1]
        print(f"  T_{n:2d}: degree = {degree:2d}, leading coeff = {leading:6d}, "
              f"coeffs = {coeffs}")
    print()


def demo_chebyshev_trig() -> None:
    """Show T_n(cos θ) = cos(nθ) — the trigonometric identity."""
    print("=" * 70)
    print("DEMO 3: Trigonometric Identity  T_n(cos θ) = cos(nθ)")
    print("=" * 70)
    theta = math.pi / 7.0
    for n in range(0, 9):
        lhs = chebyshev_T(n, math.cos(theta))
        rhs = math.cos(n * theta)
        print(f"  n={n}: T_{n}(cos(π/7)) = {lhs:+.12f},  "
              f"cos({n}·π/7) = {rhs:+.12f},  err = {abs(lhs - rhs):.2e}")
    print()


# ── Pell Equations ─────────────────────────────────────────────────────────

def pell_compose(D: int, s1: tuple[int, int], s2: tuple[int, int]) -> tuple[int, int]:
    """Brahmagupta composition of two Pell solutions (x² - D·y² = 1)."""
    x1, y1 = s1
    x2, y2 = s2
    return (x1 * x2 + D * y1 * y2, x1 * y2 + y1 * x2)


def pell_verify(D: int, sol: tuple[int, int]) -> bool:
    """Verify that (x, y) satisfies x² - D·y² = 1."""
    x, y = sol
    return x * x - D * y * y == 1


def demo_pell_composition() -> None:
    """Demonstrate Brahmagupta composition and its algebraic properties."""
    print("=" * 70)
    print("DEMO 4: Pell Equation & Brahmagupta Composition")
    print("=" * 70)

    # D = 2: fundamental solution is (3, 2) since 9 - 2·4 = 1
    D = 2
    fund = (3, 2)
    print(f"  D = {D}, fundamental solution: {fund}")
    print(f"  Verify: {fund[0]}² - {D}·{fund[1]}² = "
          f"{fund[0]**2} - {D * fund[1]**2} = {fund[0]**2 - D * fund[1]**2}")
    print()

    # Generate solutions by repeated composition
    print("  Generating solutions by iterated composition:")
    sol = (1, 0)  # trivial
    for i in range(6):
        sol = pell_compose(D, sol, fund)
        x, y = sol
        check = x * x - D * y * y
        print(f"    Solution {i + 1}: ({x}, {y})  |  "
              f"{x}² - {D}·{y}² = {check}  {'✓' if check == 1 else '✗'}")
    print()

    # Verify associativity: (s1 ∘ s2) ∘ s3 = s1 ∘ (s2 ∘ s3)
    D = 5
    s1, s2, s3 = (9, 4), (9, 4), (161, 72)
    lhs = pell_compose(D, pell_compose(D, s1, s2), s3)
    rhs = pell_compose(D, s1, pell_compose(D, s2, s3))
    print(f"  Associativity test (D={D}):")
    print(f"    (s1 ∘ s2) ∘ s3 = {lhs}")
    print(f"    s1 ∘ (s2 ∘ s3) = {rhs}")
    print(f"    Equal: {lhs == rhs} ✓")
    print()

    # Verify identity: trivial ∘ s = s
    trivial = (1, 0)
    s = (9, 4)
    result = pell_compose(D, trivial, s)
    print(f"  Identity test: (1,0) ∘ {s} = {result}  |  Equal to s: {result == s} ✓")
    print()


# ── Square Roots of -1 mod p ──────────────────────────────────────────────

def find_sqrt_neg1(p: int) -> int | None:
    """Find a ∈ {0, ..., p-1} such that a² ≡ -1 (mod p), or return None."""
    for a in range(p):
        if (a * a) % p == (p - 1):
            return a
    return None


def is_prime(n: int) -> bool:
    """Simple primality test."""
    if n < 2:
        return False
    if n < 4:
        return True
    if n % 2 == 0 or n % 3 == 0:
        return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0:
            return False
        i += 6
    return True


def demo_sqrt_neg1() -> None:
    """Find square roots of -1 for primes p ≡ 1 (mod 4)."""
    print("=" * 70)
    print("DEMO 5: Square Roots of −1 modulo primes p ≡ 1 (mod 4)")
    print("=" * 70)
    primes_1mod4 = [p for p in range(2, 200) if is_prime(p) and p % 4 == 1]
    print(f"  Primes p ≡ 1 (mod 4) up to 200: {primes_1mod4}")
    print()
    for p in primes_1mod4:
        a = find_sqrt_neg1(p)
        if a is not None:
            print(f"    p = {p:3d}:  a = {a:3d},  a² mod p = {(a*a) % p:3d} "
                  f"= p-1 = {p-1:3d}  ✓")
        else:
            print(f"    p = {p:3d}:  NO SOLUTION FOUND  ✗")
    print()

    # Show the connection to sums of two squares
    print("  Connection to sums of two squares:")
    for p in primes_1mod4[:10]:
        for a in range(1, p):
            for b in range(a, p):
                if a * a + b * b == p:
                    print(f"    {p} = {a}² + {b}² = {a*a} + {b*b}")
                    break
            else:
                continue
            break
    print()


# ── p-adic Valuations ─────────────────────────────────────────────────────

def padic_val(p: int, n: int) -> int:
    """Compute v_p(n) = largest k such that p^k divides n. v_p(0) = ∞ (returns -1)."""
    if n == 0:
        return -1  # convention: infinity
    if p < 2:
        return 0
    k = 0
    while n % p == 0:
        k += 1
        n //= p
    return k


def demo_padic_ultrametric() -> None:
    """Demonstrate the ultrametric inequality v_p(a+b) >= min(v_p(a), v_p(b))."""
    print("=" * 70)
    print("DEMO 6: Ultrametric Inequality  v_p(a+b) ≥ min(v_p(a), v_p(b))")
    print("=" * 70)

    p = 3
    print(f"  Prime p = {p}")
    print(f"  {'a':>6s} {'b':>6s} {'a+b':>6s} {'v(a)':>5s} {'v(b)':>5s} "
          f"{'v(a+b)':>6s} {'min':>4s} {'holds':>6s}")
    print("  " + "-" * 48)

    test_pairs: list[tuple[int, int]] = [
        (9, 18),       # v=2, v=2 → v(27)=3 ≥ 2 (strict!)
        (3, 6),        # v=1, v=1 → v(9)=2 ≥ 1 (strict!)
        (1, 2),        # v=0, v=0 → v(3)=1 ≥ 0 (strict!)
        (27, 54),      # v=3, v=3 → v(81)=4 ≥ 3
        (12, 15),      # v=1, v=1 → v(27)=3 ≥ 1
        (81, 162),     # v=4, v=4 → v(243)=5 ≥ 4
        (4, 5),        # v=0, v=0 → v(9)=2 ≥ 0
        (100, 125),    # v=0, v=0 → v(225)=2 ≥ 0
    ]
    for a, b in test_pairs:
        va = padic_val(p, a)
        vb = padic_val(p, b)
        vab = padic_val(p, a + b)
        m = min(va, vb)
        holds = vab >= m
        print(f"  {a:6d} {b:6d} {a+b:6d} {va:5d} {vb:5d} {vab:6d} {m:4d} "
              f"{'  ✓' if holds else '  ✗':>6s}")
    print()

    # Show the "every triangle is isosceles" consequence
    print("  'Every triangle is isosceles' in 3-adic distance:")
    print("  (d(a,b) = 3^{-v_3(a-b)})")
    triples: list[tuple[int, int, int]] = [
        (1, 4, 10),
        (0, 9, 18),
        (5, 14, 23),
    ]
    for a, b, c in triples:
        dab = 3.0 ** (-padic_val(3, abs(a - b))) if a != b else 0.0
        dbc = 3.0 ** (-padic_val(3, abs(b - c))) if b != c else 0.0
        dac = 3.0 ** (-padic_val(3, abs(a - c))) if a != c else 0.0
        sides = sorted([dab, dbc, dac])
        print(f"    Points ({a}, {b}, {c}): d(a,b)={dab:.4f}, "
              f"d(b,c)={dbc:.4f}, d(a,c)={dac:.4f}")
        print(f"      Sorted sides: {[f'{s:.4f}' for s in sides]}  "
              f"→ isosceles: {sides[1] == sides[2] or sides[0] == sides[1]}")
    print()


# ── Main ───────────────────────────────────────────────────────────────────

def main() -> None:
    """Run all demonstrations."""
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  Deep Connections: Chebyshev, Pell, Quadratic Residues, p-adics    ║")
    print("║  Numerical Demonstrations                                          ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    demo_chebyshev_composition()
    demo_chebyshev_degree()
    demo_chebyshev_trig()
    demo_pell_composition()
    demo_sqrt_neg1()
    demo_padic_ultrametric()

    print("All demonstrations complete.")


if __name__ == "__main__":
    main()

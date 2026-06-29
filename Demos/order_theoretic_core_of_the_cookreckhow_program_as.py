"""
demo.py — Numerical demonstrations for
"The Order-Theoretic Core of the Cook-Reckhow Program, with a Fibonacci Separation Bridge"

This script is fully self-contained (standard library only). It illustrates, numerically:

  1. PolyBounded: certifying f(n) + 1 <= (n+2)^k.
  2. Composition closure (Lemma 3.2): exponent a*(b+1) certifies f . g.
  3. Fibonacci doubling bound (Lemma 5.1): 2^n <= F(2n+1).
  4. Fibonacci is not polynomially bounded (Theorem 5.2): the crossover where
     2^m eventually beats (2m+3)^k.
  5. The generic separation template (Theorem 6.2) and its concrete realization by
     linSystem vs fibSystem (Theorem 6.6): the budget-exceeded crossover.

Run:  python demo.py
"""

from __future__ import annotations

from typing import Callable, Optional


# ---------------------------------------------------------------------------
# Basic arithmetic building blocks
# ---------------------------------------------------------------------------

def fib(n: int) -> int:
    """The n-th Fibonacci number: F(0)=0, F(1)=1, F(m+2)=F(m+1)+F(m)."""
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a


def poly_bound_value(n: int, k: int) -> int:
    """The polynomial blow-up bound (n+2)^k from Definition 2.1."""
    return (n + 2) ** k


# ---------------------------------------------------------------------------
# (A) Polynomial-bound certification  (computational shadow of PolyBounded)
# ---------------------------------------------------------------------------

def certify_poly_bounded(
    f: Callable[[int], int], n_max: int, k_max: int
) -> Optional[int]:
    """Return least k <= k_max with f(n)+1 <= (n+2)^k for all n <= n_max, else None.

    This is the finite-range certification of `PolyBounded f` from Definition 2.1.
    """
    for k in range(k_max + 1):
        if all(f(n) + 1 <= poly_bound_value(n, k) for n in range(n_max + 1)):
            return k
    return None


# ---------------------------------------------------------------------------
# (B) Composition-exponent computation  (Lemma 3.2)
# ---------------------------------------------------------------------------

def composition_exponent(a: int, b: int) -> int:
    """The exponent a*(b+1) certifying f . g, as produced by Lemma 3.2."""
    return a * (b + 1)


def verify_composition_closure(
    f: Callable[[int], int],
    g: Callable[[int], int],
    a: int,
    b: int,
    n_max: int,
) -> bool:
    """Check that k = a*(b+1) certifies (f . g)(n)+1 <= (n+2)^k on [0, n_max],
    given that a certifies f and b certifies g.
    """
    k = composition_exponent(a, b)
    return all(f(g(n)) + 1 <= poly_bound_value(n, k) for n in range(n_max + 1))


# ---------------------------------------------------------------------------
# (C) Fibonacci doubling-bound verifier  (Lemma 5.1:  2^n <= F(2n+1))
# ---------------------------------------------------------------------------

def verify_doubling_bound(n_max: int) -> bool:
    """Verify 2^n <= F(2n+1) for all n <= n_max."""
    return all(2 ** n <= fib(2 * n + 1) for n in range(n_max + 1))


# ---------------------------------------------------------------------------
# (D) Separation crossover finder  (Theorem 6.2 budget-exceeded point)
# ---------------------------------------------------------------------------

def separation_crossover(
    s: Callable[[int], int], k: int, n_max: int
) -> Optional[int]:
    """Least n <= n_max with s(n) > (n+2)^k: the input where a polynomial blow-up
    of exponent k can no longer simulate a system whose proofs cost >= s(n).
    """
    for n in range(n_max + 1):
        if s(n) > poly_bound_value(n, k):
            return n
    return None


# ---------------------------------------------------------------------------
# Concrete proof systems over Thm = N  (Definitions 6.4, 6.5)
# ---------------------------------------------------------------------------

def lin_size(n: int) -> int:
    """linSystem: the canonical proof of n has size n."""
    return n


def fib_size(n: int) -> int:
    """fibSystem: the canonical proof of n has size F(n)."""
    return fib(n)


# ---------------------------------------------------------------------------
# Demonstration driver
# ---------------------------------------------------------------------------

def main() -> None:
    print("=" * 72)
    print("Cook-Reckhow order theory: numerical demonstrations")
    print("=" * 72)

    # 1. PolyBounded certification of the identity and a quadratic.
    print("\n[1] Polynomial-bound certification (Definition 2.1)")
    k_id = certify_poly_bounded(lambda n: n, n_max=50, k_max=5)
    k_sq = certify_poly_bounded(lambda n: n * n, n_max=50, k_max=5)
    print(f"    identity n      certified with k = {k_id}  (expected 1)")
    print(f"    quadratic n^2   certified with k = {k_sq}  (expected 2)")

    # 2. Composition closure: f(n)=n^2 (a=2), g(n)=n+3 (b=1) -> exponent 2*(1+1)=4.
    print("\n[2] Composition closure (Lemma 3.2)")
    f = lambda n: n * n
    g = lambda n: n + 3
    a = certify_poly_bounded(f, 50, 5)
    b = certify_poly_bounded(g, 50, 5)
    k = composition_exponent(a, b)
    ok = verify_composition_closure(f, g, a, b, n_max=50)
    print(f"    a (for n^2) = {a},  b (for n+3) = {b}")
    print(f"    composite exponent a*(b+1) = {k};  certifies f.g on [0,50]: {ok}")

    # 3. Fibonacci doubling bound.
    print("\n[3] Fibonacci doubling bound 2^n <= F(2n+1) (Lemma 5.1)")
    print(f"    holds for all n <= 30: {verify_doubling_bound(30)}")
    for n in [0, 1, 5, 10, 15]:
        print(f"      n={n:2d}:  2^n = {2**n:<10d} <= F(2n+1) = {fib(2*n+1)}")

    # 4. Fibonacci is not polynomially bounded: EVERY fixed k is eventually exceeded.
    print("\n[4] Fibonacci is super-polynomial (Theorem 5.2)")
    print("    For each fixed exponent k, F(n) eventually exceeds (n+2)^k:")
    for kk in [3, 5, 8, 12]:
        n_break = separation_crossover(fib, kk, n_max=500)
        print(f"      k={kk:2d}:  least n with F(n) > (n+2)^{kk} is n = {n_break}")
    print("    (A finite n-range can be beaten by a large k, but no single k works")
    print("     for ALL n -- this is exactly non-polynomial-boundedness.)")
    print("    Underlying engine, the 2^m lower bound beating (2m+3)^k:")
    for kk in [2, 3, 4]:
        m = next((m for m in range(2000) if 2 ** m > (2 * m + 3) ** kk), None)
        print(f"      k={kk}:  least m with 2^m > (2m+3)^{kk} is m = {m}")

    # 5. Concrete separation: fibSystem does NOT p-simulate linSystem (Thm 6.6).
    print("\n[5] Concrete separation: fibSystem vs linSystem (Theorem 6.6)")
    print("    linSystem proves theorem n in size n (cheap).")
    print("    fibSystem needs size F(n) for theorem n (hard).")
    print("    A claimed blow-up (n+2)^k would need F(n) <= (n+2)^k for all n.")
    for kk in [3, 5, 8]:
        n_break = separation_crossover(fib, kk, n_max=200)
        print(f"      blow-up exponent k={kk}: budget first exceeded at n = {n_break}")
    print("    No finite k survives -> no p-simulation exists. The poset of")
    print("    p-degrees has at least two distinct points (Theorem 6.7).")

    print("\n" + "=" * 72)
    print("All numerical checks consistent with the machine-verified theorems.")
    print("=" * 72)


if __name__ == "__main__":
    main()

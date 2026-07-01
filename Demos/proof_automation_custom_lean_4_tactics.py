"""Numerical demonstrations of three verified proof-automation patterns.

This self-contained script mirrors, in ordinary Python, the mathematical
content of three sound reduction procedures:

  1. Min-plus (tropical) simplification: idempotency, distributivity, and the
     tropical "freshman's dream"  (a (+) b)^n = a^n (+) b^n.
  2. Reflective small-case primality via explicit trial division, proved
     equivalent to genuine primality.
  3. Row-sum spectral bounds: every real eigenvalue is bounded in absolute
     value by the maximum absolute row sum (the elementary half of the
     Gershgorin circle theorem).

A fourth section demonstrates the Fibonacci two-term basis principle and the
classical identities (Cassini, d'Ocagne, Catalan, doubling, partial sums).

Run with:  python demo.py
Only the standard library is required.
"""

from __future__ import annotations

from math import gcd, isqrt
from typing import List, Tuple


# ---------------------------------------------------------------------------
# 1. Min-plus (tropical) arithmetic
# ---------------------------------------------------------------------------

def trop_add(a: float, b: float) -> float:
    """Tropical addition: a (+) b = min(a, b)."""
    return min(a, b)


def trop_mul(a: float, b: float) -> float:
    """Tropical multiplication: a (*) b = a + b."""
    return a + b


def trop_pow(a: float, n: int) -> float:
    """Tropical n-th power: repeated tropical multiplication = n * a."""
    result = 0.0  # tropical multiplicative unit is 0
    for _ in range(n):
        result = trop_mul(result, a)
    return result


def demo_tropical() -> None:
    print("=" * 68)
    print("1. MIN-PLUS (TROPICAL) SIMPLIFICATION")
    print("=" * 68)
    samples = [(-3.0, 5.0), (2.0, 2.0), (7.0, -1.0), (0.0, 4.0)]

    print("\nIdempotency   a (+) a = a  [min(a,a) = a]")
    for a, _ in samples:
        assert trop_add(a, a) == a
        print(f"   a={a:>4}:  min({a},{a}) = {trop_add(a,a)}")

    print("\nDistributivity   a (*) (b (+) c) = (a (*) b) (+) (a (*) c)")
    for a, b in samples:
        c = b + 3
        lhs = trop_mul(a, trop_add(b, c))
        rhs = trop_add(trop_mul(a, b), trop_mul(a, c))
        assert lhs == rhs
        print(f"   a={a:>4}, b={b:>4}, c={c:>4}:  {lhs} = {rhs}")

    print("\nFreshman's dream   (a (+) b)^n = a^n (+) b^n   [needs n >= 0]")
    for a, b in samples:
        for n in range(0, 5):
            lhs = trop_pow(trop_add(a, b), n)
            rhs = trop_add(trop_pow(a, n), trop_pow(b, n))
            assert lhs == rhs
        print(f"   a={a:>4}, b={b:>4}: verified for n = 0..4")

    # The dream fails for negative scaling, illustrating the n >= 0 caveat.
    a, b = -3.0, 5.0
    n = -1
    lhs = n * min(a, b)
    rhs = min(n * a, n * b)
    print(f"\n   Caveat: with n={n}, n*min(a,b)={lhs} but min(n*a,n*b)={rhs}"
          f"  ->  {'EQUAL' if lhs == rhs else 'NOT EQUAL (dream fails)'}")


# ---------------------------------------------------------------------------
# 2. Reflective small-case primality (explicit trial division)
# ---------------------------------------------------------------------------

def has_proper_divisor(n: int) -> bool:
    """True iff some d with 2 <= d < n divides n (explicit scan)."""
    for d in range(2, n):
        if n % d == 0:
            return True
    return False


def trial_prime(n: int) -> bool:
    """Boolean trial-division primality test: 2 <= n and no proper divisor."""
    return n >= 2 and not has_proper_divisor(n)


def trial_prime_fast(n: int) -> bool:
    """Optimized scan truncated at floor(sqrt(n)); agrees with trial_prime."""
    if n < 2:
        return False
    for d in range(2, isqrt(n) + 1):
        if n % d == 0:
            return False
    return True


def demo_primality() -> None:
    print("\n" + "=" * 68)
    print("2. REFLECTIVE SMALL-CASE PRIMALITY (trial division)")
    print("=" * 68)
    tests = [2, 3, 4, 91, 97, 101, 100, 149, 150]
    print("\n   n     trialPrime   truncated-sqrt   agree?")
    for n in tests:
        a, b = trial_prime(n), trial_prime_fast(n)
        assert a == b, "the two scans must agree (soundness of truncation)"
        print(f"   {n:<5}  {str(a):<11}  {str(b):<15}  {a == b}")

    # Explicitly certify the headline examples from the development.
    assert trial_prime(97) and trial_prime(101)
    assert not trial_prime(91)  # 91 = 7 * 13
    print("\n   Certified: 97 prime, 101 prime, 91 = 7 x 13 NOT prime.")


# ---------------------------------------------------------------------------
# 3. Row-sum spectral bounds (elementary half of Gershgorin)
# ---------------------------------------------------------------------------

Matrix = List[List[float]]
Vector = List[float]


def abs_row_sums(A: Matrix) -> List[float]:
    """Absolute row sums sum_j |A[i][j]| for each row i."""
    return [sum(abs(x) for x in row) for row in A]


def row_sum_bound(A: Matrix) -> float:
    """The Gershgorin infinity-norm bound: max_i sum_j |A[i][j]|."""
    return max(abs_row_sums(A))


def mul_vec(A: Matrix, v: Vector) -> Vector:
    """Matrix-vector product A v."""
    return [sum(A[i][j] * v[j] for j in range(len(v))) for i in range(len(A))]


def power_iteration(A: Matrix, iters: int = 2000) -> Tuple[float, Vector]:
    """Estimate a dominant real eigenpair via power iteration."""
    n = len(A)
    v = [1.0] * n
    lam = 0.0
    for _ in range(iters):
        w = mul_vec(A, v)
        norm = max(abs(x) for x in w) or 1.0
        v = [x / norm for x in w]
        # Rayleigh-quotient eigenvalue estimate.
        num = sum(mul_vec(A, v)[i] * v[i] for i in range(n))
        den = sum(vi * vi for vi in v)
        lam = num / den
    return lam, v


def demo_spectral() -> None:
    print("\n" + "=" * 68)
    print("3. ROW-SUM SPECTRAL BOUNDS  |lambda| <= max_i sum_j |A_ij|")
    print("=" * 68)
    matrices: List[Matrix] = [
        [[2.0, 1.0], [1.0, 2.0]],
        [[0.0, 1.0], [-2.0, -3.0]],
        [[4.0, -1.0, 0.0], [-1.0, 3.0, -1.0], [0.0, -1.0, 2.0]],
    ]
    for A in matrices:
        B = row_sum_bound(A)
        lam, _ = power_iteration(A)
        ok = abs(lam) <= B + 1e-9
        print(f"\n   A = {A}")
        print(f"   absolute row sums = {abs_row_sums(A)}")
        print(f"   bound B = {B};  dominant |lambda| ~= {abs(lam):.4f}")
        print(f"   |lambda| <= B ?  {ok}")
        assert ok


# ---------------------------------------------------------------------------
# 4. Fibonacci identities via the two-term basis principle
# ---------------------------------------------------------------------------

def fib(n: int) -> int:
    """Fibonacci numbers with fib(0)=0, fib(1)=1."""
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a


def demo_fibonacci() -> None:
    print("\n" + "=" * 68)
    print("4. FIBONACCI IDENTITIES (two-term basis principle)")
    print("=" * 68)

    print("\n   Two-term basis: F(n+(k+1)) = F(k)F(n) + F(k+1)F(n+1)")
    for n in range(0, 6):
        for k in range(0, 6):
            lhs = fib(n + (k + 1))
            rhs = fib(k) * fib(n) + fib(k + 1) * fib(n + 1)
            assert lhs == rhs
    print("   verified for n,k in 0..5")

    print("\n   Cassini: F(n+2)F(n) - F(n+1)^2 = (-1)^(n+1)")
    for n in range(0, 12):
        assert fib(n + 2) * fib(n) - fib(n + 1) ** 2 == (-1) ** (n + 1)
    print("   verified for n in 0..11")

    print("\n   d'Ocagne: F(n+k)F(n+1) - F(n+k+1)F(n) = (-1)^n F(k)")
    for n in range(0, 8):
        for k in range(0, 8):
            lhs = fib(n + k) * fib(n + 1) - fib(n + k + 1) * fib(n)
            assert lhs == (-1) ** n * fib(k)
    print("   verified for n,k in 0..7")

    print("\n   Catalan: F(n+r)^2 - F(n)F(n+2r) = (-1)^n F(r)^2")
    for n in range(0, 8):
        for r in range(0, 8):
            lhs = fib(n + r) ** 2 - fib(n) * fib(n + 2 * r)
            assert lhs == (-1) ** n * fib(r) ** 2
    print("   verified for n,r in 0..7")

    print("\n   Doubling: F(2n+1)=F(n+1)^2+F(n)^2,  F(2n)=F(n)(2F(n+1)-F(n))")
    for n in range(0, 12):
        assert fib(2 * n + 1) == fib(n + 1) ** 2 + fib(n) ** 2
        assert fib(2 * n) == fib(n) * (2 * fib(n + 1) - fib(n))
    print("   verified for n in 0..11")

    print("\n   Partial sums: sum_{i<n} F(i)=F(n+1)-1,  sum_{i<=n} F(i)^2=F(n)F(n+1)")
    for n in range(0, 12):
        assert sum(fib(i) for i in range(n)) == fib(n + 1) - 1
        assert sum(fib(i) ** 2 for i in range(n + 1)) == fib(n) * fib(n + 1)
    print("   verified for n in 0..11")

    print("\n   Strong divisibility: gcd(F(m),F(n)) = F(gcd(m,n))")
    for m in range(1, 13):
        for n in range(1, 13):
            assert gcd(fib(m), fib(n)) == fib(gcd(m, n))
    print("   verified for m,n in 1..12")


def main() -> None:
    demo_tropical()
    demo_primality()
    demo_spectral()
    demo_fibonacci()
    print("\n" + "=" * 68)
    print("All demonstrations completed successfully.")
    print("=" * 68)


if __name__ == "__main__":
    main()

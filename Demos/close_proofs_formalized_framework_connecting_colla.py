"""demo.py — Numerical companion to the "Certified Additive & Combinatorial
Designs" package.

This script demonstrates, with concrete numbers, the two formalized frameworks:

  1. Additive prime decomposition (Goldbach):
       - a fuel-bounded verified search for prime pairs `p + q = n`,
       - certificate verification,
       - the prime-pair "covering graph" reformulation,
       - the three-prime (weak Goldbach) representation.

  2. The Paley I correspondence:
       - building a *skew conference matrix* C of order n = q + 1 from the
         quadratic-residue (Jacobsthal) character over GF(q), q ≡ 3 (mod 4),
       - verifying the algebraic core identity  C * C = (1 - n) I,
       - verifying that  I + C  is a (skew-)Hadamard matrix of order n,
       - verifying the converse  H - I  recovers a skew conference matrix.

Everything is self-contained: no third-party imports beyond the standard
library. Run with:  python demo.py
"""

from __future__ import annotations

from typing import List, Optional, Tuple


# ---------------------------------------------------------------------------
# Part 1 — Additive prime decomposition (Goldbach)
# ---------------------------------------------------------------------------


def is_prime(n: int) -> bool:
    """Deterministic primality test for small integers (mirrors `Nat.Prime`)."""
    if n < 2:
        return False
    if n < 4:
        return True
    if n % 2 == 0:
        return False
    d = 3
    while d * d <= n:
        if n % d == 0:
            return False
        d += 2
    return True


def find_goldbach_pair(n: int) -> Optional[Tuple[int, int]]:
    """Search for primes (p, q) with p + q = n, scanning p upward from 2.

    Mirrors the Lean `findGoldbachPair`: a fuel-bounded linear scan that
    returns the lexicographically smallest valid prime pair, or None.
    """
    fuel = n
    k = 2
    while fuel > 0:
        fuel -= 1
        if k > n:
            return None
        if is_prime(k) and is_prime(n - k) and k + (n - k) == n:
            return (k, n - k)
        k += 1
    return None


def least_goldbach_prime(n: int) -> Optional[int]:
    """The least prime p such that n - p is also prime (mirrors Lean)."""
    pair = find_goldbach_pair(n)
    return None if pair is None else pair[0]


def verify_certificate(n: int, p: int, q: int) -> bool:
    """Independently verify an AdditiveBasisCertificate witness (p, q) for n."""
    return is_prime(p) and is_prime(q) and (p + q == n)


def goldbach_up_to(bound: int) -> Tuple[bool, Optional[int]]:
    """Check binary Goldbach for every even n with 4 <= n <= bound.

    Returns (holds, first_failure). `first_failure` is None when it holds.
    """
    n = 4
    while n <= bound:
        if find_goldbach_pair(n) is None:
            return (False, n)
        n += 2
    return (True, None)


def primes_below(bound: int) -> List[int]:
    """All primes p with p <= bound (mirrors `primesBelow`)."""
    return [p for p in range(bound + 1) if is_prime(p)]


def covered_evens(bound: int) -> set[int]:
    """Even numbers expressible as a sum of two primes both <= bound.

    This is the vertex set covered by the Goldbach "pair graph" up to `bound`
    (mirrors `CoveredEvens` / `goldbachPairsUpTo`).
    """
    ps = primes_below(bound)
    covered: set[int] = set()
    for p in ps:
        for q in ps:
            s = p + q
            if s <= bound and s % 2 == 0:
                covered.add(s)
    return covered


def three_prime_representation(n: int) -> Optional[Tuple[int, int, int]]:
    """Find primes (p, q, r) with p + q + r = n (weak Goldbach), if any."""
    ps = primes_below(n)
    for p in ps:
        pair = find_goldbach_pair(n - p)
        if pair is not None:
            return (p, pair[0], pair[1])
    return None


# ---------------------------------------------------------------------------
# Part 2 — Paley I: skew conference matrices and Hadamard matrices
# ---------------------------------------------------------------------------

Matrix = List[List[int]]


def quadratic_character(a: int, q: int) -> int:
    """Legendre/quadratic character chi over GF(q) (q an odd prime).

    Returns 0 if a == 0 (mod q), +1 if a is a nonzero quadratic residue,
    -1 otherwise.
    """
    a %= q
    if a == 0:
        return 0
    residues = {(x * x) % q for x in range(1, q)}
    return 1 if a in residues else -1


def skew_conference_matrix(q: int) -> Matrix:
    """Build a skew conference matrix C of order n = q + 1 (Paley I).

    Requires q prime with q ≡ 3 (mod 4), so that chi(-1) = -1 and the
    resulting C satisfies C^T = -C. Index 0 is the bordering "point at
    infinity"; indices 1..q correspond to field elements 0..q-1.
    """
    assert is_prime(q) and q % 4 == 3, "need a prime q ≡ 3 (mod 4)"
    n = q + 1
    C: Matrix = [[0] * n for _ in range(n)]
    for j in range(1, n):
        C[0][j] = 1
        C[j][0] = -1
    for a in range(q):
        for b in range(q):
            C[a + 1][b + 1] = quadratic_character(a - b, q)
    return C


def identity(n: int) -> Matrix:
    return [[1 if i == j else 0 for j in range(n)] for i in range(n)]


def transpose(M: Matrix) -> Matrix:
    n = len(M)
    return [[M[j][i] for j in range(n)] for i in range(n)]


def matmul(A: Matrix, B: Matrix) -> Matrix:
    n = len(A)
    C: Matrix = [[0] * n for _ in range(n)]
    for i in range(n):
        for k in range(n):
            aik = A[i][k]
            if aik == 0:
                continue
            for j in range(n):
                C[i][j] += aik * B[k][j]
    return C


def matadd(A: Matrix, B: Matrix) -> Matrix:
    n = len(A)
    return [[A[i][j] + B[i][j] for j in range(n)] for i in range(n)]


def matsub(A: Matrix, B: Matrix) -> Matrix:
    n = len(A)
    return [[A[i][j] - B[i][j] for j in range(n)] for i in range(n)]


def scalar_identity(c: int, n: int) -> Matrix:
    return [[c if i == j else 0 for j in range(n)] for i in range(n)]


def is_hadamard(H: Matrix) -> bool:
    """Check H has ±1 entries and H H^T = n I."""
    n = len(H)
    if any(H[i][j] not in (1, -1) for i in range(n) for j in range(n)):
        return False
    return matmul(H, transpose(H)) == scalar_identity(n, n)


def is_skew_hadamard(H: Matrix) -> bool:
    """Check H is Hadamard and H + H^T = 2 I."""
    n = len(H)
    return is_hadamard(H) and matadd(H, transpose(H)) == scalar_identity(2, n)


def is_skew_conference(C: Matrix) -> bool:
    """Check zero diagonal, ±1 off-diagonal, C^T = -C, C C^T = (n-1) I."""
    n = len(C)
    if any(C[i][i] != 0 for i in range(n)):
        return False
    if any(C[i][j] not in (1, -1) for i in range(n) for j in range(n) if i != j):
        return False
    if transpose(C) != [[-C[i][j] for j in range(n)] for i in range(n)]:
        return False
    return matmul(C, transpose(C)) == scalar_identity(n - 1, n)


def core_identity_holds(C: Matrix) -> bool:
    """Verify the algebraic core  C * C = (1 - n) I."""
    n = len(C)
    return matmul(C, C) == scalar_identity(1 - n, n)


# ---------------------------------------------------------------------------
# Driver
# ---------------------------------------------------------------------------


def main() -> None:
    print("=" * 70)
    print("PART 1 — Certified additive prime decomposition (Goldbach)")
    print("=" * 70)

    for n in [4, 10, 28, 100, 1000]:
        pair = find_goldbach_pair(n)
        assert pair is not None and verify_certificate(n, *pair)
        print(f"  {n:5d} = {pair[0]} + {pair[1]}   (certificate verified)")

    holds, fail = goldbach_up_to(10000)
    print(f"\n  Binary Goldbach verified for all even 4..10000 : {holds}")
    assert holds and fail is None

    print(f"\n  least Goldbach prime of 100 = {least_goldbach_prime(100)}")
    print(f"  three-prime (weak) decomposition of 27 = "
          f"{three_prime_representation(27)}")

    cov = covered_evens(50)
    expected = set(range(4, 51, 2))
    print(f"\n  Even numbers 4..50 covered by prime-pair graph: "
          f"{sorted(cov & expected) == sorted(expected)}")

    print()
    print("=" * 70)
    print("PART 2 — Paley I: skew conference  <->  Hadamard")
    print("=" * 70)

    for q in [3, 7, 11, 19, 23]:
        n = q + 1
        C = skew_conference_matrix(q)
        H = matadd(identity(n), C)               # H = I + C
        assert is_skew_conference(C)
        assert core_identity_holds(C)            # C*C = (1-n) I
        assert is_skew_hadamard(H)               # I + C is skew-Hadamard
        assert is_hadamard(H)
        Cback = matsub(H, identity(n))           # converse: H - I
        assert is_skew_conference(Cback) and Cback == C
        print(f"  q={q:2d}  ->  order n={n:2d}: "
              f"skew-conference ✓  C*C=(1-n)I ✓  I+C Hadamard ✓  "
              f"H-I=C ✓")

    print("\n  Note: orders 4, 8, 12, 20, 24 include 12 and 20 — NOT powers")
    print("  of two — which the Sylvester doubling construction can never reach.")

    print("\nAll assertions passed.")


if __name__ == "__main__":
    main()

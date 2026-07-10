"""
Stochastic Galois Theory over Finite Fields:
An exact first-moment dictionary between random polynomials and random
permutations.

This self-contained script numerically verifies, by brute-force enumeration,
the exact identities of the paper:

  1. Total root incidences:   sum over all q^n monic degree-n polynomials of
     the number of roots equals q^n  (expected number of roots = 1).
  2. Total fixed points:      sum over all n! permutations of the number of
     fixed points equals n!          (expected number of fixed points = 1).
  3. Exact n-cycle count:     the number of n-cycles in S_n equals (n-1)!,
     so the probability of being an n-cycle is exactly 1/n.
  4. The bridge:              (total roots) * n! == (total fixed points) * q^n,
     both equal to q^n * n!.

Only primes q are used so that Z/qZ is a field; the root identity itself holds
over any finite commutative ring.
"""

from __future__ import annotations

from itertools import permutations, product
from math import factorial
from typing import List, Tuple


# --------------------------------------------------------------------------- #
# Arithmetic side: monic polynomials over F_q = Z/qZ (q prime)
# --------------------------------------------------------------------------- #
def monic_eval(coeffs: Tuple[int, ...], r: int, q: int, n: int) -> int:
    """Evaluate f_v(r) mod q, where f_v(x) = x^n + sum_i coeffs[i] * x^i.

    ``coeffs`` is the lower coefficient vector (v_0, ..., v_{n-1}).
    """
    value = pow(r, n, q)  # leading monic term x^n
    for i, c in enumerate(coeffs):
        value = (value + c * pow(r, i, q)) % q
    return value % q


def count_roots(coeffs: Tuple[int, ...], q: int, n: int) -> int:
    """Number of r in F_q with f_v(r) = 0."""
    return sum(1 for r in range(q) if monic_eval(coeffs, r, q, n) == 0)


def total_root_incidences(q: int, n: int) -> int:
    """Sum of the number of roots over all q^n monic degree-n polynomials."""
    return sum(
        count_roots(coeffs, q, n)
        for coeffs in product(range(q), repeat=n)
    )


# --------------------------------------------------------------------------- #
# Combinatorial side: permutations of {0, ..., n-1}
# --------------------------------------------------------------------------- #
def count_fixed_points(sigma: Tuple[int, ...]) -> int:
    """Number of i with sigma(i) = i."""
    return sum(1 for i, s in enumerate(sigma) if s == i)


def total_fixed_points(n: int) -> int:
    """Sum of the number of fixed points over all n! permutations."""
    return sum(count_fixed_points(sigma) for sigma in permutations(range(n)))


def is_n_cycle(sigma: Tuple[int, ...]) -> bool:
    """True iff sigma is a single n-cycle (its orbit through 0 has length n)."""
    n = len(sigma)
    if n == 0:
        return False
    seen, j = 0, 0
    while True:
        j = sigma[j]
        seen += 1
        if j == 0:
            break
    return seen == n


def count_n_cycles(n: int) -> int:
    """Number of n-cycles in S_n."""
    return sum(1 for sigma in permutations(range(n)) if is_n_cycle(sigma))


# --------------------------------------------------------------------------- #
# Verification driver
# --------------------------------------------------------------------------- #
def verify(q: int, n: int) -> None:
    """Print and assert all four identities for a given prime q and degree n."""
    tri = total_root_incidences(q, n)
    tfp = total_fixed_points(n)
    ncyc = count_n_cycles(n)

    print(f"  q = {q}, n = {n}")
    print(f"    total root incidences = {tri:>8}   (expected q^n = {q ** n})")
    print(f"      -> expected #roots  = {tri / q ** n:.6f}   (target 1)")
    print(f"    total fixed points    = {tfp:>8}   (expected n! = {factorial(n)})")
    print(f"      -> expected #fixed  = {tfp / factorial(n):.6f}   (target 1)")
    if n >= 2:
        print(f"    #n-cycles             = {ncyc:>8}   (expected (n-1)! = {factorial(n - 1)})")
        print(f"      -> P(n-cycle)       = {ncyc / factorial(n):.6f}   (target 1/n = {1 / n:.6f})")
    lhs = tri * factorial(n)
    rhs = tfp * q ** n
    print(f"    bridge: (roots)*n! = {lhs} == (fixed)*q^n = {rhs}  -> {lhs == rhs}")

    assert tri == q ** n, "total root incidences identity failed"
    assert tfp == factorial(n), "total fixed points identity failed"
    if n >= 2:
        assert ncyc == factorial(n - 1), "n-cycle count identity failed"
        assert ncyc * n == factorial(n), "1/n law failed"
    assert lhs == rhs == q ** n * factorial(n), "bridge identity failed"


def irreducible_proportion(q: int, n: int) -> float:
    """Empirical proportion of irreducible monic degree-n polynomials over F_q.

    Uses the Frobenius correspondence: a monic polynomial is irreducible iff its
    Frobenius permutation on the roots is a single n-cycle.  We test
    irreducibility directly by checking it has no root in any proper subfield's
    worth of low-degree factors; for a clean elementary check we test that f has
    no nontrivial monic factor of degree < n by trial division over F_q[x].
    """
    def poly_mul(a: List[int], b: List[int]) -> List[int]:
        res = [0] * (len(a) + len(b) - 1)
        for i, ai in enumerate(a):
            for j, bj in enumerate(b):
                res[i + j] = (res[i + j] + ai * bj) % q
        return res

    def divides(divisor: List[int], dividend: List[int]) -> bool:
        # polynomial remainder of dividend by (monic) divisor over F_q
        rem = dividend[:]
        dd = len(divisor) - 1
        while len(rem) - 1 >= dd and any(rem):
            # strip leading zeros
            while rem and rem[-1] % q == 0:
                rem.pop()
            if len(rem) - 1 < dd:
                break
            lead = rem[-1]
            shift = len(rem) - 1 - dd
            for i, c in enumerate(divisor):
                rem[i + shift] = (rem[i + shift] - lead * c) % q
            while rem and rem[-1] % q == 0:
                rem.pop()
        return len(rem) == 0 or all(c % q == 0 for c in rem)

    # enumerate monic irreducibles of low degree by brute force
    def monic_irreducibles(deg: int) -> List[List[int]]:
        out = []
        for coeffs in product(range(q), repeat=deg):
            poly = list(coeffs) + [1]
            if deg == 1:
                out.append(poly)
                continue
            reducible = False
            for d in range(1, deg):
                for lower in monic_irreducibles(d):
                    if divides(lower, poly):
                        reducible = True
                        break
                if reducible:
                    break
            if not reducible:
                out.append(poly)
        return out

    count = len(monic_irreducibles(n))
    return count / q ** n


def main() -> None:
    print("=" * 70)
    print("Exact first-moment identities (brute-force enumeration)")
    print("=" * 70)
    for q, n in [(2, 1), (2, 2), (2, 3), (3, 2), (3, 3), (5, 2), (5, 3)]:
        verify(q, n)
        print()

    print("=" * 70)
    print("Arithmetic shadow: proportion of irreducibles -> 1/n as q grows")
    print("=" * 70)
    n = 2
    print(f"  degree n = {n}, target 1/n = {1 / n:.4f}")
    for q in [2, 3, 5, 7, 11, 13]:
        prop = irreducible_proportion(q, n)
        print(f"    q = {q:>2}:  proportion irreducible = {prop:.4f}")
    n = 3
    print(f"  degree n = {n}, target 1/n = {1 / n:.4f}")
    for q in [2, 3, 5, 7]:
        prop = irreducible_proportion(q, n)
        print(f"    q = {q:>2}:  proportion irreducible = {prop:.4f}")

    print()
    print("All identities verified.")


if __name__ == "__main__":
    main()

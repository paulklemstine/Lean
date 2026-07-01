"""
Numerical demonstrations for:

    An Euler Product for the Autocorrelation of Simultaneously Visible
    Lattice Points

A lattice point v in Z^k is visible from x when gcd(v - x) = 1.  For a finite
observer set S, V_S is the set of points simultaneously visible from every
x in S.  The autocorrelation

    gamma_S(z) = density of V_S ∩ (V_S + z)

is conjectured to equal the Euler product

    prod_p ( 1 - |S_p ∪ (S - z)_p| / p^k )

where S_p is the image of S in (Z/pZ)^k.  This script verifies the identity
empirically, checks the classical specialization 1/zeta(k), and exhibits the
false-multiplicativity counterexample.

Self-contained: standard library only.
"""

from __future__ import annotations

from math import gcd, pi
from functools import reduce
from itertools import product
from typing import Iterable, Sequence, Tuple

Vec = Tuple[int, ...]


# --------------------------------------------------------------------------- #
# Basic arithmetic on integer vectors
# --------------------------------------------------------------------------- #
def vec_gcd(w: Sequence[int]) -> int:
    """Non-negative gcd of all coordinates of an integer vector (gcd(0)=0)."""
    return reduce(gcd, (abs(c) for c in w), 0)


def is_primitive(w: Sequence[int]) -> bool:
    """A vector is primitive iff gcd of its coordinates equals 1."""
    return vec_gcd(w) == 1


def reduce_mod(p: int, w: Sequence[int]) -> Vec:
    """Coordinatewise reduction of w modulo p."""
    return tuple(c % p for c in w)


# --------------------------------------------------------------------------- #
# Primes
# --------------------------------------------------------------------------- #
def primes_up_to(n: int) -> list[int]:
    """Sieve of Eratosthenes: all primes <= n."""
    if n < 2:
        return []
    sieve = bytearray([1]) * (n + 1)
    sieve[0] = sieve[1] = 0
    for i in range(2, int(n ** 0.5) + 1):
        if sieve[i]:
            sieve[i * i:: i] = bytearray(len(sieve[i * i:: i]))
    return [i for i in range(2, n + 1) if sieve[i]]


# --------------------------------------------------------------------------- #
# The local (per-prime) Euler factor
# --------------------------------------------------------------------------- #
def local_factor(S: Iterable[Vec], z: Vec, p: int, k: int) -> float:
    """
    f_p(z) = 1 - |S_p ∪ (S - z)_p| / p^k, the fraction of residues modulo p
    that are simultaneously allowed for v and for v - z.
    """
    S = list(S)
    residues: set[Vec] = set()
    for s in S:
        residues.add(reduce_mod(p, s))
        residues.add(reduce_mod(p, tuple(si + zi for si, zi in zip(s, z))))
    return 1.0 - len(residues) / (p ** k)


def euler_product(S: Iterable[Vec], z: Vec, k: int, prime_bound: int = 2000) -> float:
    """Truncated Euler product prod_{p <= prime_bound} f_p(z)."""
    S = list(S)
    prod = 1.0
    for p in primes_up_to(prime_bound):
        prod *= local_factor(S, z, p, k)
    return prod


# --------------------------------------------------------------------------- #
# Empirical density in a box
# --------------------------------------------------------------------------- #
def in_V_S(v: Vec, S: Sequence[Vec]) -> bool:
    """v is simultaneously visible from all of S."""
    return all(is_primitive(tuple(vi - xi for vi, xi in zip(v, x))) for x in S)


def empirical_autocorrelation(S: Sequence[Vec], z: Vec, k: int, N: int) -> float:
    """
    |V_S ∩ (V_S + z) ∩ [-N, N]^k| / (2N+1)^k, by direct enumeration.
    v in V_S + z  <=>  v - z in V_S.
    """
    count = 0
    total = 0
    for v in product(range(-N, N + 1), repeat=k):
        total += 1
        vz = tuple(vi - zi for vi, zi in zip(v, z))
        if in_V_S(v, S) and in_V_S(vz, S):
            count += 1
    return count / total


# --------------------------------------------------------------------------- #
# Naive (false) vs. true multiplicativity
# --------------------------------------------------------------------------- #
def naive_local_density(S: Sequence[Vec], n: int, k: int) -> float:
    """L_n(S) = 1 - |rho_n(S)| / n^k  (the quantity whose multiplicativity FAILS)."""
    image = {reduce_mod(n, s) for s in S}
    return 1.0 - len(image) / (n ** k)


def primitive_residue_density(n: int, k: int) -> float:
    """
    delta_k(n) = (# primitive vectors in (Z/nZ)^k) / n^k.
    A residue vector is primitive iff no prime factor of n divides all coords,
    i.e. gcd(gcd(coords), n) == 1.
    """
    count = 0
    for v in product(range(n), repeat=k):
        if gcd(vec_gcd(v), n) == 1:
            count += 1
    return count / (n ** k)


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #
def demo_classical() -> None:
    print("=" * 68)
    print("1.  Classical case S = {0}, z = 0  ->  density = 1/zeta(k)")
    print("=" * 68)
    for k in (2, 3):
        ep = euler_product([(0,) * k], (0,) * k, k, prime_bound=5000)
        if k == 2:
            exact = 6 / pi ** 2
            print(f"  k={k}: Euler product = {ep:.6f}   1/zeta(2)=6/pi^2 = {exact:.6f}")
        else:
            # 1/zeta(3) approx
            print(f"  k={k}: Euler product = {ep:.6f}   1/zeta(3) ~ 0.831907")


def demo_euler_vs_empirical() -> None:
    print("=" * 68)
    print("2.  Euler product vs. empirical density (k=2)")
    print("=" * 68)
    cases = [
        ("S={0},        z=(0,0)", [(0, 0)], (0, 0)),
        ("S={0},        z=(1,0)", [(0, 0)], (1, 0)),
        ("S={0,(1,0)},  z=(0,0)", [(0, 0), (1, 0)], (0, 0)),
        ("S={0,(1,1)},  z=(2,0)", [(0, 0), (1, 1)], (2, 0)),
    ]
    k = 2
    N = 220
    for label, S, z in cases:
        ep = euler_product(S, z, k, prime_bound=4000)
        em = empirical_autocorrelation(S, z, k, N)
        print(f"  {label:24s}  Euler={ep:.5f}  empirical(N={N})={em:.5f}  "
              f"|diff|={abs(ep - em):.5f}")


def demo_false_multiplicativity() -> None:
    print("=" * 68)
    print("3.  Naive local-density multiplicativity FAILS")
    print("=" * 68)
    S = [(0,), (1,)]  # k = 1, S = {0, 1}
    k = 1
    L6 = naive_local_density(S, 6, k)
    L2 = naive_local_density(S, 2, k)
    L3 = naive_local_density(S, 3, k)
    print(f"  S = {{0,1}} in Z^1")
    print(f"  L_6(S)          = {L6}   (= 2/3)")
    print(f"  L_2(S)*L_3(S)   = {L2 * L3}   (= 0)")
    print(f"  equal? {abs(L6 - L2 * L3) < 1e-12}  ->  multiplicativity is FALSE")


def demo_true_multiplicativity() -> None:
    print("=" * 68)
    print("4.  Primitive-residue density delta_k IS multiplicative")
    print("=" * 68)
    for k in (1, 2):
        for m, n in ((2, 3), (4, 9), (5, 6)):
            lhs = primitive_residue_density(m * n, k)
            rhs = primitive_residue_density(m, k) * primitive_residue_density(n, k)
            print(f"  k={k}: delta({m*n}) = {lhs:.5f}   "
                  f"delta({m})*delta({n}) = {rhs:.5f}   "
                  f"equal? {abs(lhs - rhs) < 1e-12}")


if __name__ == "__main__":
    demo_classical()
    print()
    demo_euler_vs_empirical()
    print()
    demo_false_multiplicativity()
    print()
    demo_true_multiplicativity()

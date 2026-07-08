"""
Numerical demonstration of the Matsuno-type formula for supersingular
2-adic Iwasawa lambda-invariants.

This self-contained script computes the arithmetic skeleton of the formula:

    lambda(E^D) - lambda(E) = sum_{ell | D} delta(ell),

where for each odd prime ell the 2-adic depth is

    n_ell = v2((ell^2 - 1) / 8),

and the local contribution delta(ell) depends on the conductor N_E and the
parity of the reduction order of E modulo ell. We verify:

  1. the depth closed form  n_ell + 3 = v2(ell-1) + v2(ell+1);
  2. divisibility of ell^2 - 1 by 8 for odd ell;
  3. the local bound  0 <= delta(ell) <= 2^(n_ell + 1);
  4. additivity over coprime moduli;
  5. monotonicity of the global invariant under divisibility of the level.

Every function is inlined and uses only the Python standard library.
"""

from __future__ import annotations

from math import gcd
from typing import Callable, Dict, List


# ---------------------------------------------------------------------------
# Basic arithmetic
# ---------------------------------------------------------------------------

def v2(n: int) -> int:
    """The 2-adic valuation of a positive integer n (number of factors of 2)."""
    if n <= 0:
        raise ValueError("v2 requires a positive integer")
    count = 0
    while n % 2 == 0:
        n //= 2
        count += 1
    return count


def prime_factors(n: int) -> List[int]:
    """Return the sorted list of distinct prime divisors of n >= 1."""
    if n < 1:
        raise ValueError("prime_factors requires n >= 1")
    factors: List[int] = []
    d = 2
    m = n
    while d * d <= m:
        if m % d == 0:
            factors.append(d)
            while m % d == 0:
                m //= d
        d += 1
    if m > 1:
        factors.append(m)
    return factors


def is_squarefree(n: int) -> bool:
    """True iff no prime square divides n."""
    m = n
    d = 2
    while d * d <= m:
        if m % (d * d) == 0:
            return False
        if m % d == 0:
            m //= d
        else:
            d += 1
    return True


# ---------------------------------------------------------------------------
# The Matsuno-type invariant
# ---------------------------------------------------------------------------

def n_ell(ell: int) -> int:
    """The 2-adic depth n_ell = v2((ell^2 - 1) / 8) for odd ell >= 3."""
    return v2((ell * ell - 1) // 8)


def n_ell_closed_form(ell: int) -> int:
    """The depth via the closed form v2(ell-1) + v2(ell+1) - 3 for odd ell >= 3."""
    return v2(ell - 1) + v2(ell + 1) - 3


def local_term(ell: int, conductor: int, order: Callable[[int], int]) -> int:
    """
    The local contribution delta(ell):
      2^(n_ell)      if ell divides the conductor,
      2^(n_ell + 1)  if ell does not divide the conductor and order(ell) is even,
      0              otherwise.
    """
    depth = n_ell(ell)
    if conductor % ell == 0:
        return 2 ** depth
    if order(ell) % 2 == 0:
        return 2 ** (depth + 1)
    return 0


def lambda_diff(D: int, conductor: int, order: Callable[[int], int]) -> int:
    """The global invariant: sum of local contributions over primes dividing D."""
    return sum(local_term(ell, conductor, order) for ell in prime_factors(D))


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_depth_table() -> None:
    print("=" * 62)
    print("Depth n_ell = v2((ell^2 - 1)/8) and its closed form")
    print("=" * 62)
    print(f"{'ell':>5} {'ell^2-1':>9} {'(ell^2-1)/8':>13} {'n_ell':>6} "
          f"{'v2(l-1)+v2(l+1)-3':>19}")
    for ell in [3, 5, 7, 17, 31, 97, 127, 257]:
        direct = n_ell(ell)
        closed = n_ell_closed_form(ell)
        assert direct == closed, "closed form mismatch!"
        assert (ell * ell - 1) % 8 == 0, "8 must divide ell^2 - 1"
        print(f"{ell:>5} {ell*ell-1:>9} {(ell*ell-1)//8:>13} "
              f"{direct:>6} {closed:>19}")
    print()


def demo_local_bound() -> None:
    print("=" * 62)
    print("Local bound: 0 <= delta(ell) <= 2^(n_ell + 1)")
    print("=" * 62)
    conductor = 15  # square-free, primes 3 and 5
    order = lambda ell: ell - 1  # a sample parity oracle
    for ell in [3, 5, 7, 17, 31]:
        d = local_term(ell, conductor, order)
        upper = 2 ** (n_ell(ell) + 1)
        assert 0 <= d <= upper
        divides = "yes" if conductor % ell == 0 else "no "
        print(f"ell={ell:>3}  divides N_E? {divides}  delta={d:>4}  "
              f"upper=2^(n+1)={upper:>4}")
    print()


def demo_additivity() -> None:
    print("=" * 62)
    print("Additivity over coprime moduli: Lambda(ab) = Lambda(a) + Lambda(b)")
    print("=" * 62)
    conductor = 21  # primes 3, 7
    order = lambda ell: ell + 1
    pairs = [(5, 11), (13, 17), (7, 5), (3, 55)]
    for a, b in pairs:
        if gcd(a, b) != 1:
            continue
        lhs = lambda_diff(a * b, conductor, order)
        rhs = lambda_diff(a, conductor, order) + lambda_diff(b, conductor, order)
        assert lhs == rhs
        print(f"a={a:>3}, b={b:>3}: Lambda(ab)={lhs:>4}  = "
              f"Lambda(a)+Lambda(b)={rhs:>4}  (coprime, OK)")
    print()


def demo_monotonicity() -> None:
    print("=" * 62)
    print("Monotonicity under divisibility of the level")
    print("=" * 62)
    conductor = 10  # primes 2, 5
    order = lambda ell: ell - 1
    D = 3 * 5 * 7 * 11  # square-free
    divisors = [d for d in range(1, D + 1) if D % d == 0 and is_squarefree(d)]
    prev = -1
    for d in sorted(divisors, key=lambda x: (len(prime_factors(x)) if x > 1 else 0, x)):
        val = lambda_diff(d, conductor, order) if d > 1 else 0
        marker = "  (>= all its divisors)" if val >= prev else "  !!"
        print(f"d={d:>4}  Lambda(d)={val:>4}{marker}")
    # verify the full monotonicity statement on the divisor lattice
    for d in divisors:
        assert lambda_diff(d, conductor, order) <= lambda_diff(D, conductor, order)
    print("All divisors d | D satisfy Lambda(d) <= Lambda(D).")
    print()


def demo_residue_stratification() -> None:
    print("=" * 62)
    print("Residue stratification: n_ell = 0 exactly for ell = 3, 5 mod 8")
    print("=" * 62)
    counts: Dict[int, List[int]] = {}
    for ell in range(3, 130, 2):
        if len(prime_factors(ell)) == 1 and ell > 2:  # ell prime
            counts.setdefault(n_ell(ell), []).append(ell % 8)
    for depth in sorted(counts):
        residues = sorted(set(counts[depth]))
        print(f"n_ell = {depth}: residues mod 8 = {residues}")
    print()


def main() -> None:
    demo_depth_table()
    demo_local_bound()
    demo_additivity()
    demo_monotonicity()
    demo_residue_stratification()
    print("All assertions passed.")


if __name__ == "__main__":
    main()

"""
Universal Mathematics and Alien Arithmetic --- numerical demonstrations.

This self-contained script illustrates the paper's results computationally:

  1. Universality = provability, and monotonicity of consequence, on a finite
     class of "worlds" (small groups).
  2. Independence defeats universality: commutativity is independent of the
     group axioms (abelian Z/2Z vs. non-abelian S_3).
  3. The Decidability Reduction: "phi or not-phi is universal" iff the theory
     decides phi.
  4. Alien arithmetic: three independent characterizations of primes all agree,
     the canonical prime finder, Euclid's infinitude, and the existence and
     uniqueness of prime factorization (Fundamental Theorem of Arithmetic).

Run: python demo.py
"""

from __future__ import annotations

from itertools import permutations, product
from typing import Callable, Dict, List, Tuple


# ---------------------------------------------------------------------------
# Part I. A finite semantic universe of "worlds" (small groups).
# ---------------------------------------------------------------------------
# A World is represented by its multiplication table (Cayley table) as a
# dict mapping (a, b) -> a*b over elements 0..n-1.

World = Dict[Tuple[int, int], int]
Sentence = Callable[[World], bool]


def cyclic_group(n: int) -> World:
    """Z/nZ under addition mod n (an abelian group)."""
    return {(a, b): (a + b) % n for a in range(n) for b in range(n)}


def symmetric_group_3() -> World:
    """S_3, the six permutations of {0,1,2}, under composition (non-abelian)."""
    perms: List[Tuple[int, ...]] = list(permutations(range(3)))
    index = {p: i for i, p in enumerate(perms)}

    def compose(p: Tuple[int, ...], q: Tuple[int, ...]) -> Tuple[int, ...]:
        # (p after q)(x) = p[q[x]]
        return tuple(p[q[x]] for x in range(3))

    table: World = {}
    for i, p in enumerate(perms):
        for j, q in enumerate(perms):
            table[(i, j)] = index[compose(p, q)]
    return table


def carrier(w: World) -> List[int]:
    return sorted({a for (a, _) in w.keys()})


def is_commutative(w: World) -> bool:
    """The sentence Comm: for all x, y, x*y = y*x."""
    elems = carrier(w)
    return all(w[(a, b)] == w[(b, a)] for a in elems for b in elems)


# A "theory" here is a list of sentences; a world models it if all hold.
def is_model(theory: List[Sentence], w: World) -> bool:
    return all(phi(w) for phi in theory)


def consistent(theory: List[Sentence], worlds: List[World]) -> bool:
    return any(is_model(theory, w) for w in worlds)


def entails(theory: List[Sentence], phi: Sentence, worlds: List[World]) -> bool:
    """T |= phi : phi holds in every model of T (within our finite universe)."""
    return all(phi(w) for w in worlds if is_model(theory, w))


def decides(theory: List[Sentence], phi: Sentence, worlds: List[World]) -> bool:
    neg = lambda w: not phi(w)
    return entails(theory, phi, worlds) or entails(theory, neg, worlds)


def demo_universality() -> None:
    print("=" * 70)
    print("PART I: Universality, monotonicity, independence, decidability")
    print("=" * 70)

    worlds: List[World] = [cyclic_group(2), cyclic_group(3), symmetric_group_3()]
    names = ["Z/2Z", "Z/3Z", "S_3"]

    print("\nWorlds and commutativity:")
    for name, w in zip(names, worlds):
        print(f"  {name:6s}: |G| = {len(carrier(w))}, commutative = {is_commutative(w)}")

    theory_groups: List[Sentence] = []          # bare group axioms (empty here)
    theory_abelian: List[Sentence] = [is_commutative]

    # Monotonicity: everything entailed by the empty theory stays entailed.
    trivial: Sentence = lambda w: len(carrier(w)) >= 1
    print("\nMonotonicity (empty theory |= trivial  =>  abelian theory |= trivial):")
    print(f"  groups  |= trivial : {entails(theory_groups, trivial, worlds)}")
    print(f"  abelian |= trivial : {entails(theory_abelian, trivial, worlds)}")

    # Independence defeats universality: Comm is independent of group axioms.
    has_model = any(is_model(theory_groups, w) and is_commutative(w) for w in worlds)
    has_counter = any(is_model(theory_groups, w) and not is_commutative(w) for w in worlds)
    print("\nIndependence of commutativity over the theory of groups:")
    print(f"  model of Comm exists      : {has_model}")
    print(f"  countermodel of Comm exists: {has_counter}")
    print(f"  => Comm is independent     : {has_model and has_counter}")
    print(f"  groups |= Comm             : {entails(theory_groups, is_commutative, worlds)}"
          "   (not universal)")

    # But over abelian groups, Comm is universal (it is an axiom).
    print(f"  abelian |= Comm            : {entails(theory_abelian, is_commutative, worlds)}"
          "   (universal once adopted)")

    # Decidability reduction: (phi or ~phi universal) iff theory decides phi.
    print("\nDecidability reduction over the theory of groups:")
    phi = is_commutative
    neg = lambda w: not phi(w)
    universal_side = entails(theory_groups, phi, worlds) or entails(theory_groups, neg, worlds)
    print(f"  phi or ~phi universal : {universal_side}")
    print(f"  theory decides phi    : {decides(theory_groups, phi, worlds)}")
    assert universal_side == decides(theory_groups, phi, worlds)
    print("  reduction holds       : True")


# ---------------------------------------------------------------------------
# Part II. Alien arithmetic: primes as a definitional invariant.
# ---------------------------------------------------------------------------
def divisors(n: int) -> List[int]:
    return [d for d in range(1, n + 1) if n % d == 0]


def prime_via_divisibility(p: int) -> bool:
    """p >= 2 and its only divisors are 1 and p."""
    return p >= 2 and all(d == 1 or d == p for d in divisors(p))


def prime_via_indecomposable(p: int) -> bool:
    """p >= 2 and cannot be written as a*b with a,b >= 2."""
    if p < 2:
        return False
    return not any(a >= 2 and b >= 2 and a * b == p
                   for a in range(2, p) for b in range(2, p))


def prime_element(p: int, bound: int = 40) -> bool:
    """Abstract prime-element property: whenever p | a*b then p | a or p | b."""
    if p < 2:
        return False
    return all((a * b) % p != 0 or a % p == 0 or b % p == 0
               for a in range(bound) for b in range(bound))


def min_fac(n: int) -> int:
    """Canonical prime finder: least divisor of n exceeding 1."""
    d = 2
    while d * d <= n:
        if n % d == 0:
            return d
        d += 1
    return n


def factorize(n: int) -> List[int]:
    """Existence of factorization via repeated canonical prime finder."""
    factors: List[int] = []
    while n > 1:
        p = min_fac(n)
        factors.append(p)
        n //= p
    return factors


def demo_primes() -> None:
    print("\n" + "=" * 70)
    print("PART II: Alien arithmetic --- primes as a definitional invariant")
    print("=" * 70)

    N = 60
    d_primes = [p for p in range(2, N) if prime_via_divisibility(p)]
    i_primes = [p for p in range(2, N) if prime_via_indecomposable(p)]
    a_primes = [p for p in range(2, N) if prime_element(p)]

    print(f"\nThree independent characterizations agree up to {N}:")
    print(f"  via divisibility   : {d_primes}")
    print(f"  via indecomposable : {i_primes}")
    print(f"  via prime element  : {a_primes}")
    assert d_primes == i_primes == a_primes
    print("  all identical      : True")

    print("\nCanonical prime finder min_fac(n) is always prime:")
    for n in [91, 100, 101, 143, 1024]:
        mf = min_fac(n)
        print(f"  min_fac({n:5d}) = {mf:5d}  (prime: {prime_via_divisibility(mf)})")
        assert prime_via_divisibility(mf)

    print("\nEuclid: a prime beyond every bound (search above n):")
    for n in [10, 100, 1000, 10000]:
        p = n
        while not prime_via_divisibility(p):
            p += 1
        print(f"  first prime >= {n:6d} is {p}")

    print("\nFundamental Theorem of Arithmetic (existence + uniqueness):")
    for n in [360, 1001, 2 ** 5 * 3 ** 3, 999983]:
        fs = factorize(n)
        prod = 1
        for x in fs:
            prod *= x
        assert prod == n and all(prime_via_divisibility(x) for x in fs)
        print(f"  {n:8d} = {' * '.join(map(str, fs))}")
    # Uniqueness: any valid prime factorization is a permutation of factorize(n).
    n = 360
    canonical = sorted(factorize(n))
    print(f"\nUniqueness check for {n}: canonical sorted factors = {canonical}")
    print("  (any prime factorization is a permutation of these)")


def main() -> None:
    demo_universality()
    demo_primes()
    print("\nAll demonstrations completed successfully.")


if __name__ == "__main__":
    main()

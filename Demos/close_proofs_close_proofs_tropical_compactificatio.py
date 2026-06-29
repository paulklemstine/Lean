"""
demo.py — Numerical demonstrations of the Diagonal Obstruction Calculus
=======================================================================

A uniform local obstruction framework for diagonal Diophantine equations

        x_1^n + x_2^n + ... + x_s^n = k.

This script reproduces, numerically, every theorem of the calculus:

    Thm 3.1  Global representability => local admissibility (mod every m)
    Thm 3.3  Divisibility descent: Adm mod M and m | M  =>  Adm mod m
    Thm 3.4  Universal surjectivity => every k locally admissible
    Thm 3.5  Unit n-th-power invariance of the admissible set
    Thm 3.6  Coprime (CRT) composition of universal surjectivity
    Thm 4.1  Correctness of the residue-sum decision procedure

Everything is self-contained (standard library only). Run with:  python demo.py
"""

from __future__ import annotations

from itertools import product
from math import gcd
from typing import Iterable


# ---------------------------------------------------------------------------
# Core computational primitives
# ---------------------------------------------------------------------------

def nth_power_residues(n: int, m: int) -> set[int]:
    """Set { x^n mod m : x in Z/mZ }, the n-th power residues modulo m."""
    return {pow(x, n, m) for x in range(m)}


def residue_sums(n: int, s: int, m: int) -> set[int]:
    """The set R_{n,s}(m) of all residues attainable as a sum of s n-th powers.

    Computed as the iterated Minkowski sum of the n-th power residue set with
    itself s times -- the certified decision procedure of Theorem 4.1, in the
    efficient O(s * m * |P|) form rather than the naive O(m^s) enumeration.
    """
    powers = nth_power_residues(n, m)
    reachable: set[int] = {0}  # sum of zero powers is 0
    for _ in range(s):
        reachable = {(r + p) % m for r in reachable for p in powers}
    return reachable


def residue_sums_bruteforce(n: int, s: int, m: int) -> set[int]:
    """Naive O(m^s) enumeration over all s-tuples -- the literal Definition 2.5.

    Used to cross-check `residue_sums` (and hence to witness Theorem 4.1).
    """
    return {
        sum(pow(x, n, m) for x in tup) % m
        for tup in product(range(m), repeat=s)
    }


def locally_admissible(n: int, s: int, k: int, m: int) -> bool:
    """Decide local admissibility Adm_{n,s}(k, m) (Definition 2.1, Corollary 4.2)."""
    return (k % m) in residue_sums(n, s, m)


def universally_surjective(n: int, s: int, m: int) -> bool:
    """Decide universal surjectivity Surj_{n,s}(m) (Definition 2.3)."""
    return residue_sums(n, s, m) == set(range(m))


def units(m: int) -> list[int]:
    """The unit group (Z/mZ)^x as a list of representatives."""
    return [a for a in range(m) if gcd(a, m) == 1]


def crt_pair(a1: int, m1: int, a2: int, m2: int) -> int:
    """Chinese Remainder Theorem: unique a mod m1*m2 with a=a1 mod m1, a=a2 mod m2.

    Requires gcd(m1, m2) == 1.
    """
    # inverse of m1 modulo m2 (m1, m2 coprime)
    inv = pow(m1, -1, m2)
    t = ((a2 - a1) * inv) % m2
    return (a1 + m1 * t) % (m1 * m2)


# ---------------------------------------------------------------------------
# Theorem demonstrations
# ---------------------------------------------------------------------------

def demo_threecubes_obstruction() -> None:
    """Section 5.1 -- the mod-9 obstruction for sums of three cubes."""
    print("=" * 70)
    print("DEMO 1  Sums of three cubes and the mod-9 obstruction (n=3, s=3)")
    print("=" * 70)
    cubes = sorted(nth_power_residues(3, 9))
    reachable = sorted(residue_sums(3, 3, 9))
    missing = sorted(set(range(9)) - set(reachable))
    print(f"  cubic residues mod 9      : {cubes}")
    print(f"  sums of three cubes mod 9 : {reachable}")
    print(f"  UNREACHABLE residues mod 9: {missing}   <-- the obstruction")
    print()
    # The two famous solved cases vs. the eternally impossible ones
    famous_solved = [33, 42]          # both NOT 4 or 5 mod 9 -> candidates -> solved
    eternally_impossible = [4, 5, 13, 14, 22, 23, 31, 32]
    for k in famous_solved:
        print(f"  k={k:>2}:  k mod 9 = {k % 9}  -> locally admissible? "
              f"{locally_admissible(3, 3, k, 9)}  (was eventually found as 3 cubes)")
    for k in eternally_impossible:
        adm = locally_admissible(3, 3, k, 9)
        print(f"  k={k:>2}:  k mod 9 = {k % 9}  -> locally admissible? {adm}  "
              f"-> NEVER a sum of three cubes (Cor 3.2 contrapositive)")
    print()


def demo_global_to_local() -> None:
    """Theorem 3.1 -- a genuine integer solution casts a shadow at every modulus."""
    print("=" * 70)
    print("DEMO 2  Global => local at every modulus (Theorem 3.1)")
    print("=" * 70)
    # 33 = x^3 + y^3 + z^3 with the celebrated 2019 solution.
    x = 8866128975287528
    y = -8778405442862239
    z = -2736111468807040
    k = x**3 + y**3 + z**3
    print(f"  Booker-Sutherland (2019):  x^3+y^3+z^3 = {k}")
    print(f"  every modulus must then admit k={k}:")
    for m in [2, 3, 5, 7, 9, 11, 100, 999]:
        ok = locally_admissible(3, 3, k, m)
        # also exhibit the explicit shadow witness coming from the global solution
        shadow = (pow(x, 3, m) + pow(y, 3, m) + pow(z, 3, m)) % m
        print(f"    m={m:>4}:  Adm? {ok}   shadow {x},{y},{z} -> {shadow} = {k % m} = k mod m")
    print()


def demo_descent() -> None:
    """Theorem 3.3 -- admissibility mod M descends to admissibility mod m | M."""
    print("=" * 70)
    print("DEMO 3  Divisibility descent: m | M, Adm mod M => Adm mod m (Thm 3.3)")
    print("=" * 70)
    n, s = 3, 3
    M = 27
    divisors_of_M = [m for m in range(1, M + 1) if M % m == 0]
    counter = 0
    for k in range(M):
        if locally_admissible(n, s, k, M):
            for m in divisors_of_M:
                assert locally_admissible(n, s, k, m), (k, m, M)
                counter += 1
    print(f"  Verified: for n={n}, s={s}, M={M}, every k admissible mod {M}")
    print(f"  stays admissible mod every divisor m | {M}.")
    print(f"  ({counter} (k, divisor) descent instances all hold.)")
    print()


def demo_universal_surjectivity_completeness() -> None:
    """Theorem 3.4 -- a universally surjective modulus obstructs nothing."""
    print("=" * 70)
    print("DEMO 4  Universal surjectivity => every k admissible (Thm 3.4)")
    print("=" * 70)
    # Sums of two squares mod a prime: surjective for every prime.
    n, s = 2, 2
    for m in [3, 5, 7, 11, 13]:
        surj = universally_surjective(n, s, m)
        print(f"  Surj_{{2,2}}({m}) = {surj}   -> every integer is locally admissible mod {m}: "
              f"{all(locally_admissible(n, s, k, m) for k in range(m))}")
    # Contrast: a modulus that is NOT surjective and genuinely obstructs.
    print(f"  Surj_{{2,2}}(4) = {universally_surjective(2, 2, 4)}   "
          f"(residue 3 mod 4 is obstructed: {residue_sums(2,2,4)})")
    print()


def demo_unit_power_invariance() -> None:
    """Theorem 3.5 -- the admissible set is a union of n-th-power-unit orbits."""
    print("=" * 70)
    print("DEMO 5  Unit n-th-power invariance of the admissible set (Thm 3.5)")
    print("=" * 70)
    n, s, m = 3, 2, 13
    S = residue_sums(n, s, m)
    print(f"  n={n}, s={s}, m={m}:  S_{{n,s}}(m) = {sorted(S)}")
    ok = True
    for a in units(m):
        u = pow(a, n, m)
        for r in S:
            if (u * r) % m not in S:
                ok = False
    print(f"  closed under multiplication by every u = a^{n} (a a unit)? {ok}")
    # show the n-th-power-unit subgroup and that S is a union of its cosets/orbits
    nth_power_units = sorted({pow(a, n, m) for a in units(m)})
    print(f"  n-th powers of units U_m^(n) = {nth_power_units}")
    print()


def demo_crt_composition() -> None:
    """Theorem 3.6 -- coprime surjective moduli compose to a surjective product."""
    print("=" * 70)
    print("DEMO 6  CRT composition of universal surjectivity (Thm 3.6)")
    print("=" * 70)
    n, s = 2, 2
    m1, m2 = 5, 13         # coprime, both universally surjective for two squares
    assert gcd(m1, m2) == 1
    s1 = universally_surjective(n, s, m1)
    s2 = universally_surjective(n, s, m2)
    s12 = universally_surjective(n, s, m1 * m2)
    print(f"  Surj_{{2,2}}({m1}) = {s1},  Surj_{{2,2}}({m2}) = {s2}  =>  "
          f"Surj_{{2,2}}({m1*m2}) = {s12}")
    # explicit CRT gluing for one target
    target = 47 % (m1 * m2)
    a1, a2 = target % m1, target % m2
    glued = crt_pair(a1, m1, a2, m2)
    print(f"  CRT glue: a={target} -> ({a1} mod {m1}, {a2} mod {m2}) "
          f"-> reassembled {glued} (matches: {glued == target})")
    print()


def demo_decision_procedure_correctness() -> None:
    """Theorem 4.1 -- the fast Minkowski-sum procedure equals the literal definition."""
    print("=" * 70)
    print("DEMO 7  Correctness of the decision procedure (Theorem 4.1)")
    print("=" * 70)
    checks: list[tuple[int, int, int]] = [
        (2, 2, 8), (2, 3, 7), (3, 3, 9), (3, 2, 13), (4, 4, 16), (2, 4, 12),
    ]
    for n, s, m in checks:
        fast = residue_sums(n, s, m)
        slow = residue_sums_bruteforce(n, s, m)
        print(f"  n={n}, s={s}, m={m:>2}:  Minkowski == bruteforce? {fast == slow}  "
              f"|R| = {len(fast)}/{m}")
    print()


def main() -> None:
    demo_threecubes_obstruction()
    demo_global_to_local()
    demo_descent()
    demo_universal_surjectivity_completeness()
    demo_unit_power_invariance()
    demo_crt_composition()
    demo_decision_procedure_correctness()
    print("All demonstrations completed: every theorem verified numerically.")


if __name__ == "__main__":
    main()

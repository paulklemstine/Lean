"""
Numerical demonstrations for:

    A Group-Theoretic Structure Theory of Reversible Binary Cellular Automata
    on Cyclic Lattices

We model elementary (radius-1) binary cellular automata on the cyclic lattice
Z/n. A configuration is a tuple of n bits (0/1). A local rule reads
(left, center, right) and outputs one bit. The global map applies the local
rule simultaneously at every site, with wrap-around indices.

This script verifies, by brute force enumeration over all 2^n configurations:

  * Translation invariance:   F(shift(c)) == shift(F(c)) for every rule.
  * Reversibility classification: exactly rules {204, 51, 170, 240, 15, 85}
    are bijective on the ring.
  * The constant rule 0 is not reversible.
  * The shift/complement algebra: complement is an involution, the shift has
    order exactly n, they commute, and <shift, complement> is abelian of
    order 2n (isomorphic to Z/n x Z/2).
  * The false conjecture: the centralizer of the neighborhood 3-rotation in
    S_8 has order 36, not 8!/4 = 10080.

Self-contained: standard library only.
"""

from __future__ import annotations

from itertools import product, permutations
from math import factorial
from typing import Callable, Dict, List, Tuple

Config = Tuple[int, ...]          # a configuration: n bits
LocalRule = Callable[[int, int, int], int]


# --------------------------------------------------------------------------
# Wolfram rule tables
# --------------------------------------------------------------------------
def wolfram_local_rule(number: int) -> LocalRule:
    """Return the local rule (l, m, r) -> bit for a Wolfram rule number 0..255.

    Neighborhood (l, m, r) is read as the integer 4*l + 2*m + r, and bit
    ``number`` at that position gives the output.
    """
    def rule(l: int, m: int, r: int) -> int:
        index = (l << 2) | (m << 1) | r
        return (number >> index) & 1
    return rule


# --------------------------------------------------------------------------
# Global map and basic operators on Z/n
# --------------------------------------------------------------------------
def global_map(rule: LocalRule, c: Config) -> Config:
    """Apply the elementary global map to configuration c on the cyclic ring."""
    n = len(c)
    return tuple(rule(c[(i - 1) % n], c[i], c[(i + 1) % n]) for i in range(n))


def shift(c: Config) -> Config:
    """Left shift: (Sc)(i) = c(i+1)."""
    n = len(c)
    return tuple(c[(i + 1) % n] for i in range(n))


def complement(c: Config) -> Config:
    """Pointwise complement: (Cc)(i) = 1 - c(i)."""
    return tuple(1 - b for b in c)


def all_configs(n: int) -> List[Config]:
    return [tuple(bits) for bits in product((0, 1), repeat=n)]


# --------------------------------------------------------------------------
# Property checks
# --------------------------------------------------------------------------
def is_bijective(rule: LocalRule, n: int) -> bool:
    """A global map on Z/n is bijective iff it is injective on the 2^n states."""
    configs = all_configs(n)
    images = {global_map(rule, c) for c in configs}
    return len(images) == len(configs)


def commutes_with_shift(rule: LocalRule, n: int) -> bool:
    """Translation invariance: F(Sc) == S(F c) for all c."""
    return all(
        global_map(rule, shift(c)) == shift(global_map(rule, c))
        for c in all_configs(n)
    )


def reversible_elementary_rules(n: int) -> List[int]:
    """Enumerate all 256 rules and return those with bijective global map on Z/n."""
    return [r for r in range(256) if is_bijective(wolfram_local_rule(r), n)]


# --------------------------------------------------------------------------
# The shift / complement group  <S, C>
# --------------------------------------------------------------------------
def apply_word(word: List[str], c: Config) -> Config:
    """Apply a word (list of 'S' / 'C') right-to-left to configuration c."""
    for g in reversed(word):
        c = shift(c) if g == "S" else complement(c)
    return c


def permutation_of_word(word: List[str], n: int) -> Tuple[Config, ...]:
    """Represent a group element as its permutation of the 2^n configurations."""
    return tuple(apply_word(word, c) for c in all_configs(n))


def shift_complement_group(n: int) -> Dict[Tuple[int, int], Tuple[Config, ...]]:
    """Enumerate S^a C^b for a in 0..n-1, b in 0..1 as distinct permutations."""
    group: Dict[Tuple[int, int], Tuple[Config, ...]] = {}
    for a in range(n):
        for b in range(2):
            word = ["S"] * a + (["C"] if b else [])
            group[(a, b)] = permutation_of_word(word, n)
    return group


def shift_order(n: int) -> int:
    """Smallest k >= 1 with shift^k == identity on Z/n."""
    identity = tuple(all_configs(n))
    perm = identity
    for k in range(1, n + 1):
        perm = tuple(shift(c) for c in perm)
        if perm == identity:
            return k
    return n


# --------------------------------------------------------------------------
# The false 10080 conjecture: centralizer of the neighborhood 3-rotation
# --------------------------------------------------------------------------
def neighborhood_rotation() -> List[int]:
    """Permutation of the 8 neighborhoods induced by (l,m,r) -> (m,r,l)."""
    perm = [0] * 8
    for l, m, r in product((0, 1), repeat=3):
        src = (l << 2) | (m << 1) | r
        # rotate: new left=m, new center=r, new right=l
        dst = (m << 2) | (r << 1) | l
        perm[src] = dst
    return perm


def centralizer_size(perm: List[int]) -> int:
    """Order of the centralizer of `perm` in the symmetric group S_len."""
    k = len(perm)
    count = 0
    for g in permutations(range(k)):
        # g centralizes perm iff g[perm[x]] == perm[g[x]] for all x
        if all(g[perm[x]] == perm[g[x]] for x in range(k)):
            count += 1
    return count


# --------------------------------------------------------------------------
# Main demonstration
# --------------------------------------------------------------------------
def main() -> None:
    EXPECTED = {204, 51, 170, 240, 15, 85}

    print("=" * 70)
    print("Reversible elementary cellular automata on the cyclic ring Z/n")
    print("=" * 70)
    print("\nThe six affine single-site rules {15, 51, 85, 170, 204, 240} are")
    print("reversible on EVERY ring. On very small rings additional rules are")
    print("accidentally bijective (spurious injectivity from short periods);")
    print("intersecting over increasing n isolates exactly the six.\n")

    # The six are reversible on every ring.
    for n in (3, 4, 5, 6, 7, 8):
        rev = set(reversible_elementary_rules(n))
        assert EXPECTED <= rev, f"a distinguished rule failed to be reversible on n={n}"

    # Intersecting the reversible sets over a range of n converges to the six.
    intersection = set(range(256))
    for n in range(2, 9):
        rev = set(reversible_elementary_rules(n))
        intersection &= rev
        print(f"  n = {n}:  #reversible = {len(rev):3d}   "
              f"running intersection = {sorted(intersection)}")
    print(f"\n  -> Rules reversible on all rings: {sorted(intersection)}")
    assert intersection == EXPECTED
    print("  -> Exactly {15, 51, 85, 170, 204, 240}: the six affine single-site rules.")

    print("\n" + "-" * 70)
    print("Translation invariance: every rule commutes with the shift")
    print("-" * 70)
    n = 5
    all_commute = all(commutes_with_shift(wolfram_local_rule(r), n) for r in range(256))
    print(f"  All 256 rules commute with the shift on Z/{n}: {all_commute}")
    assert all_commute

    print("\n" + "-" * 70)
    print("The constant rule 0 is NOT reversible")
    print("-" * 70)
    print(f"  Rule 0 bijective on Z/5: {is_bijective(wolfram_local_rule(0), 5)}")
    assert not is_bijective(wolfram_local_rule(0), 5)

    print("\n" + "-" * 70)
    print("Structure of the shift/complement group <S, C>")
    print("-" * 70)
    for n in (3, 4, 5):
        group = shift_complement_group(n)
        distinct = len(set(group.values()))
        ord_S = shift_order(n)
        # complement involution
        idp = permutation_of_word([], n)
        c2 = permutation_of_word(["C", "C"], n)
        involutive = c2 == idp
        # commute
        sc = permutation_of_word(["S", "C"], n)
        cs = permutation_of_word(["C", "S"], n)
        commute = sc == cs
        print(f"  n={n}: |<S,C>|={distinct} (= 2n={2*n}), "
              f"order(S)={ord_S}, C^2=id: {involutive}, SC=CS: {commute}")
        assert distinct == 2 * n
        assert ord_S == n and involutive and commute
    print("  -> <S, C> is abelian of order 2n, isomorphic to Z/n x Z/2.")

    print("\n" + "-" * 70)
    print("Debunking the |G| = 8!/4 = 10080 conjecture")
    print("-" * 70)
    perm = neighborhood_rotation()
    size = centralizer_size(perm)
    print(f"  8!/4 = {factorial(8) // 4}")
    print(f"  Centralizer of the neighborhood 3-rotation in S_8 has order {size}")
    assert size == 36
    print("  -> The true centralizer has order 36, not 10080. Conjecture is false.")

    print("\n" + "=" * 70)
    print("All demonstrations passed.")
    print("=" * 70)


if __name__ == "__main__":
    main()

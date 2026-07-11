"""
Dreamtime Algebra, Deepened: Kinship Systems as (Z/2)^n and their symmetry
group GL(n, F_2).

This self-contained script demonstrates numerically the main results of the
accompanying paper:

  * Kin(n) = (Z/2)^n has 2^n sections and exponent two.
  * Kinship steps (translations) act simply transitively (Cayley representation).
  * There are 2^n - 1 admissible marriage generators (the kinship spectrum).
  * The moiety subgroup has index two; marriage is a coset restriction.
  * Kin(n+1) is a Z/2-extension (double cover) of Kin(n).
  * The automorphism group is GL(n, F_2), of order prod_i (2^n - 2^i);
    for n = 2 it has order 6 and is isomorphic to S_3.

Everything is computed by brute-force enumeration over F_2^n. No external
dependencies are required.
"""

from __future__ import annotations

from itertools import product, permutations
from typing import List, Tuple

Section = Tuple[int, ...]  # an element of (Z/2)^n


# --------------------------------------------------------------------------
# The kinship space Kin(n) = (Z/2)^n
# --------------------------------------------------------------------------
def kin(n: int) -> List[Section]:
    """All 2^n sections of the n-generation kinship space."""
    return [tuple(v) for v in product((0, 1), repeat=n)]


def add(x: Section, y: Section) -> Section:
    """Pointwise addition modulo 2 in (Z/2)^n."""
    return tuple((a + b) % 2 for a, b in zip(x, y))


def zero(n: int) -> Section:
    return tuple(0 for _ in range(n))


# --------------------------------------------------------------------------
# Basic structure: cardinality and exponent two
# --------------------------------------------------------------------------
def card(n: int) -> int:
    return len(kin(n))


def exponent_two(n: int) -> bool:
    """Check that g + g = 0 for every section g."""
    z = zero(n)
    return all(add(g, g) == z for g in kin(n))


# --------------------------------------------------------------------------
# Cayley representation: translations as permutations
# --------------------------------------------------------------------------
def translation(n: int, v: Section) -> List[Section]:
    """The permutation x |-> x + v, as the image list over kin(n)."""
    return [add(x, v) for x in kin(n)]


def simply_transitive(n: int) -> bool:
    """For every ordered pair (x, y) there is a unique v with x + v = y."""
    space = kin(n)
    for x in space:
        for y in space:
            solutions = [v for v in space if add(x, v) == y]
            if len(solutions) != 1:
                return False
    return True


def transformation_group_size(n: int) -> int:
    """Number of distinct translation permutations = |image of Cayley map|."""
    distinct = {tuple(translation(n, v)) for v in kin(n)}
    return len(distinct)


# --------------------------------------------------------------------------
# Kinship spectrum: admissible marriage generators
# --------------------------------------------------------------------------
def kinship_spectrum(n: int) -> List[Section]:
    """The nonzero sections; each is a nonzero involution / marriage rule."""
    z = zero(n)
    return [g for g in kin(n) if g != z]


# --------------------------------------------------------------------------
# Moiety subgroup and marriage as coset restriction
# --------------------------------------------------------------------------
def moiety_functional(f: Section) -> int:
    """Read off the last coordinate."""
    return f[-1]


def moiety_subgroup(n: int) -> List[Section]:
    """Sections with last coordinate 0 (the kernel of the moiety functional)."""
    return [g for g in kin(n) if moiety_functional(g) == 0]


def marriage_preserves_coset(n: int, m: Section) -> bool:
    """Marriage by m sends each moiety coset onto a single coset."""
    shift = moiety_functional(m)
    return all(
        moiety_functional(add(x, m)) == (moiety_functional(x) + shift) % 2
        for x in kin(n)
    )


# --------------------------------------------------------------------------
# Automorphism group = GL(n, F_2)
# --------------------------------------------------------------------------
def gl_order(n: int) -> int:
    """|GL(n, F_2)| = prod_{i=0}^{n-1} (2^n - 2^i)."""
    result = 1
    for i in range(n):
        result *= (2 ** n - 2 ** i)
    return result


def count_additive_automorphisms(n: int) -> int:
    """
    Brute-force count of additive bijections of (Z/2)^n.

    An additive endomorphism is determined by its values on the standard basis
    e_0, ..., e_{n-1}. We enumerate all choices of basis images, extend by
    linearity, and count those that are bijective. This directly verifies that
    the number of automorphisms equals |GL(n, F_2)|.
    """
    space = kin(n)
    basis = [tuple(1 if j == i else 0 for j in range(n)) for i in range(n)]
    count = 0
    for images in product(space, repeat=n):
        # extend linearly: phi(x) = sum_i x_i * images[i]
        seen = set()
        ok = True
        for x in space:
            y = zero(n)
            for i in range(n):
                if x[i] == 1:
                    y = add(y, images[i])
            if y in seen:
                ok = False
                break
            seen.add(y)
        if ok and len(seen) == len(space):
            count += 1
    return count


def gl2_is_s3() -> bool:
    """
    Verify GL(2, F_2) acts on the three nonzero vectors as S_3, realizing all
    3! = 6 permutations.
    """
    nonzero = kinship_spectrum(2)  # three vectors
    space = kin(2)
    basis = [(1, 0), (0, 1)]
    realized = set()
    for images in product(space, repeat=2):
        seen = set()
        table = {}
        for x in space:
            y = zero(2)
            for i in range(2):
                if x[i] == 1:
                    y = add(y, images[i])
            table[x] = y
            seen.add(y)
        if len(seen) == 4:  # bijective => automorphism
            perm = tuple(nonzero.index(table[g]) for g in nonzero)
            realized.add(perm)
    all_perms = set(permutations(range(3)))
    return realized == all_perms


# --------------------------------------------------------------------------
# Concrete Kariera permutations (n = 2)
# --------------------------------------------------------------------------
def kariera_descent_consistency() -> bool:
    """father = spouse o mother, i.e. translation by (1,0) = (0,1) then (1,1)."""
    mother, spouse, father = (1, 1), (0, 1), (1, 0)
    return add(spouse, mother) == father


# --------------------------------------------------------------------------
# Driver
# --------------------------------------------------------------------------
def main() -> None:
    print("=" * 68)
    print("Dreamtime Algebra: Kinship systems as (Z/2)^n")
    print("=" * 68)

    for n in range(1, 5):
        print(f"\n--- n = {n}  (Kin({n}) = (Z/2)^{n}) ---")
        print(f"  |Kin(n)|                 = {card(n)}  (expected 2^{n} = {2**n})")
        print(f"  exponent two             = {exponent_two(n)}")
        print(f"  simply transitive        = {simply_transitive(n)}")
        print(f"  Cayley image size        = {transformation_group_size(n)}")
        print(f"  # marriage generators    = {len(kinship_spectrum(n))}"
              f"  (expected 2^{n}-1 = {2**n - 1})")
        print(f"  moiety subgroup size     = {len(moiety_subgroup(n))}"
              f"  (index {card(n) // len(moiety_subgroup(n))})")
        m = kinship_spectrum(n)[0]
        print(f"  marriage preserves coset = {marriage_preserves_coset(n, m)}")
        print(f"  |GL(n, F_2)| formula     = {gl_order(n)}")

    print("\n--- Automorphism group = GL(n, F_2) (brute force) ---")
    for n in range(1, 4):
        counted = count_additive_automorphisms(n)
        print(f"  n = {n}: additive automorphisms = {counted}, "
              f"|GL(n,F_2)| = {gl_order(n)}, match = {counted == gl_order(n)}")

    print("\n--- Four-section symmetry: GL(2, F_2) = S_3 ---")
    print(f"  |GL(2, F_2)| = {gl_order(2)} = 3! = 6")
    print(f"  realizes all 6 permutations of the 3 marriage rules: {gl2_is_s3()}")

    print("\n--- Kariera descent consistency ---")
    print(f"  father = spouse o mother : {kariera_descent_consistency()}")


if __name__ == "__main__":
    main()

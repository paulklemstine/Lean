"""
Numerical demonstrations for:

    Finiteness of Semisimple Geometric Representations of Ramified Fundamental Groups

The mathematical engine reduces the finiteness conjecture to two facts:
  (FG) the source group is finitely generated;
  (FI) the admissible images lie in finitely many finite subgroups.

Given (FG) and (FI), the representation space -- and its conjugacy classes -- is
finite. This file demonstrates each step of the argument computationally, using
small concrete finite groups as targets so that everything can be enumerated
exactly.

Everything is self-contained: no external dependencies beyond the standard
library.
"""

from __future__ import annotations

from itertools import product
from typing import Callable, Dict, FrozenSet, List, Sequence, Tuple


# ---------------------------------------------------------------------------
# Finite group scaffolding
# ---------------------------------------------------------------------------

class FiniteGroup:
    """A finite group given by its element list, a multiplication, and identity.

    `mul(a, b)` returns the product a*b; `identity` is the neutral element;
    `inv(a)` returns the inverse of a.
    """

    def __init__(
        self,
        elements: Sequence[object],
        mul: Callable[[object, object], object],
        identity: object,
    ) -> None:
        self.elements: List[object] = list(elements)
        self.mul = mul
        self.identity = identity
        # Precompute inverses.
        self._inv: Dict[object, object] = {}
        for a in self.elements:
            for b in self.elements:
                if mul(a, b) == identity:
                    self._inv[a] = b
                    break

    def inv(self, a: object) -> object:
        return self._inv[a]

    @property
    def order(self) -> int:
        return len(self.elements)


def cyclic_group(m: int) -> FiniteGroup:
    """The cyclic group Z/mZ, written additively (elements 0..m-1)."""
    return FiniteGroup(range(m), lambda a, b: (a + b) % m, 0)


def units_mod(m: int) -> FiniteGroup:
    """The multiplicative group (Z/mZ)^x -- a model of GL_1 over Z/mZ."""
    from math import gcd
    elts = [a for a in range(1, m) if gcd(a, m) == 1]
    return FiniteGroup(elts, lambda a, b: (a * b) % m, 1)


def symmetric_group_3() -> FiniteGroup:
    """S_3 as permutations of (0,1,2), a small non-abelian target."""
    from itertools import permutations
    elts = list(permutations(range(3)))

    def compose(p: Tuple[int, ...], q: Tuple[int, ...]) -> Tuple[int, ...]:
        # (p*q)(i) = p(q(i))
        return tuple(p[q[i]] for i in range(3))

    return FiniteGroup(elts, compose, (0, 1, 2))


# ---------------------------------------------------------------------------
# ALGORITHM 1: enumerate Hom(G, H) for G = <generators | relations>
# ---------------------------------------------------------------------------

def word_value(word: Sequence[Tuple[int, int]], images: Sequence[object],
               H: FiniteGroup) -> object:
    """Evaluate a group word in H.

    `word` is a list of (generator_index, exponent) pairs; `images[i]` is the
    image of generator i in H. Exponents may be negative (inverses).
    """
    acc = H.identity
    for gi, exp in word:
        g = images[gi]
        if exp < 0:
            g = H.inv(g)
            exp = -exp
        for _ in range(exp):
            acc = H.mul(acc, g)
    return acc


def enumerate_homs(
    num_generators: int,
    relations: Sequence[Sequence[Tuple[int, int]]],
    H: FiniteGroup,
) -> List[Tuple[object, ...]]:
    """Return every homomorphism G -> H, as tuples of generator images.

    G is presented by `num_generators` generators subject to `relations`
    (each relation is a word that must map to the identity).

    Correctness: a hom is determined by images of the generators, and an
    assignment extends to a hom iff it kills all relations. This realizes
    Theorem 3.1: the count is at most |H|^num_generators.
    """
    homs: List[Tuple[object, ...]] = []
    for images in product(H.elements, repeat=num_generators):
        if all(word_value(rel, images, H) == H.identity for rel in relations):
            homs.append(images)
    return homs


# ---------------------------------------------------------------------------
# ALGORITHM 2: count admissible representations over a family of subgroups
# ---------------------------------------------------------------------------

def enumerate_admissible(
    num_generators: int,
    relations: Sequence[Sequence[Tuple[int, int]]],
    family: Sequence[FiniteGroup],
) -> List[Tuple[int, Tuple[object, ...]]]:
    """Enumerate representations whose image lies in some member of `family`.

    Returns a deduplicated list; realizes Theorem 3.3 (finite union of finite
    sets). Each entry is (family_index, generator_images).
    """
    seen = set()
    result: List[Tuple[int, Tuple[object, ...]]] = []
    for idx, K in enumerate(family):
        for images in enumerate_homs(num_generators, relations, K):
            key = images
            if key not in seen:
                seen.add(key)
                result.append((idx, images))
    return result


# ---------------------------------------------------------------------------
# ALGORITHM 3: count conjugacy (isomorphism) classes of representations
# ---------------------------------------------------------------------------

def conjugacy_classes(
    homs: Sequence[Tuple[object, ...]],
    H: FiniteGroup,
) -> List[FrozenSet[Tuple[object, ...]]]:
    """Group homomorphisms G -> H into H-conjugacy classes.

    Two homs f, g are conjugate if there is m in H with g(s) = m f(s) m^{-1}
    for every generator s. Realizes Theorem 3.4: a finite set has finitely many
    classes.
    """
    def conjugate(images: Tuple[object, ...], m: object) -> Tuple[object, ...]:
        return tuple(H.mul(H.mul(m, x), H.inv(m)) for x in images)

    remaining = set(homs)
    classes: List[FrozenSet[Tuple[object, ...]]] = []
    while remaining:
        rep = next(iter(remaining))
        orbit = {conjugate(rep, m) for m in H.elements}
        orbit &= set(homs)
        classes.append(frozenset(orbit))
        remaining -= orbit
    return classes


# ---------------------------------------------------------------------------
# DEMONSTRATIONS
# ---------------------------------------------------------------------------

def demo_base_engine() -> None:
    print("=" * 70)
    print("DEMO 1 (Theorem 3.1): Hom(G, H) is finite for f.g. G, finite H")
    print("=" * 70)
    # G = Z (one generator, no relations); H = Z/6Z.
    H = cyclic_group(6)
    homs = enumerate_homs(1, [], H)
    print(f"G = Z, H = Z/6Z: |Hom(G,H)| = {len(homs)} (bound |H|^1 = {H.order})")
    # G = Z^2 (two generators, one commuting relation); H = Z/4Z.
    H2 = cyclic_group(4)
    commutator = [(0, 1), (1, 1), (0, -1), (1, -1)]
    homs2 = enumerate_homs(2, [commutator], H2)
    print(f"G = Z^2, H = Z/4Z: |Hom(G,H)| = {len(homs2)} "
          f"(bound |H|^2 = {H2.order ** 2})")
    print()


def demo_characters() -> None:
    print("=" * 70)
    print("DEMO 2 (Theorem 5.2): finitely many characters G -> F^x")
    print("=" * 70)
    for m in (5, 7, 8, 12):
        F_units = units_mod(m)
        # G = Z (one generator): characters correspond to elements of F^x.
        chars = enumerate_homs(1, [], F_units)
        print(f"F = Z/{m}Z: |F^x| = {F_units.order}, "
              f"#characters of Z = {len(chars)}")
    print()


def demo_admissible_family() -> None:
    print("=" * 70)
    print("DEMO 3 (Theorem 3.3): finite family of finite images -> finiteness")
    print("=" * 70)
    # Admissible family K = {Z/2Z, Z/3Z} as targets; G = Z.
    family = [cyclic_group(2), cyclic_group(3)]
    adm = enumerate_admissible(1, [], family)
    print("Admissible family K = {Z/2Z, Z/3Z}, source G = Z")
    print(f"  #admissible representations (deduplicated union) = {len(adm)}")
    print("  (identity rep counted once even though it lands in both)")
    print()


def demo_conjugacy_nonabelian() -> None:
    print("=" * 70)
    print("DEMO 4 (Theorem 3.4): conjugacy classes of a non-abelian target")
    print("=" * 70)
    H = symmetric_group_3()
    # G = Z, so Hom(G, H) = H (each element gives a rep of the generator).
    homs = enumerate_homs(1, [], H)
    classes = conjugacy_classes(homs, H)
    print(f"G = Z, H = S_3: |Hom| = {len(homs)}, "
          f"#conjugacy classes = {len(classes)}")
    print("  (matches the 3 conjugacy classes of S_3: id, transpositions, "
          "3-cycles)")
    print()


def demo_boundary() -> None:
    print("=" * 70)
    print("DEMO 5 (Theorem 4.1): the boundary -- infinite target breaks it")
    print("=" * 70)
    print("Hom(Z, M) is in bijection with M (image of the generator).")
    for m in (10, 100, 1000):
        # Model an 'infinite' target by taking larger and larger cyclic groups.
        H = cyclic_group(m)
        homs = enumerate_homs(1, [], H)
        print(f"  target of order {m:>4}: #Hom(Z, target) = {len(homs)}")
    print("  As |M| -> infinity, #Hom(Z, M) -> infinity: finiteness fails")
    print("  without bounding the image (hypothesis (FI)).")
    print()


def main() -> None:
    demo_base_engine()
    demo_characters()
    demo_admissible_family()
    demo_conjugacy_nonabelian()
    demo_boundary()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()

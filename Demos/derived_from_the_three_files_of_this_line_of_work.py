"""
Pointed versus unpointed homotopy classes of maps of 1-types.
=============================================================

A homotopy 1-type is modelled by a groupoid; a connected one with fundamental
group G is modelled by the one-object groupoid K(G,1) whose only endomorphisms
are the elements of G.  The two classification theorems demonstrated here are:

    UNPOINTED :  [K(G,1), K(H,1)]    ~  Hom(G, H) / conjugation by H
    POINTED   :  [K(G,1), K(H,1)]_*  ~  Hom(G, H)              (no quotient)

Consequently the forgetful map "forget the basepoint"

    [X, Y]_*  --->  [X, Y]

is surjective and its fibre over the class of a map inducing phi : G -> H has
exactly

    [ H : C_H(phi(G)) ]

elements, the index of the centraliser of the image.  Over the class of the
identity map of K(G,1) this is [G : Z(G)] = |Inn G|, so that

    pointed self-equivalence classes  =  Aut G,
    unpointed self-equivalence classes =  Out G = Aut G / Inn G.

This script verifies all of these statements by brute-force enumeration for a
number of small groups, and in particular carries out the decisive test with
G = H = S_3, where the three fibres have sizes 1, 3 and 6.

Everything is elementary and self-contained: groups are represented as finite
lists of elements with a multiplication table, and homomorphisms as dictionaries.
"""

from __future__ import annotations

from itertools import product
from typing import Callable, Dict, Hashable, List, Sequence, Tuple

Elem = Hashable
Hom = Tuple[Tuple[Elem, Elem], ...]  # a homomorphism, as a sorted tuple of pairs


# --------------------------------------------------------------------------- #
#  A minimal finite group class
# --------------------------------------------------------------------------- #


class FiniteGroup:
    """A finite group given by its element list and multiplication function."""

    def __init__(self, name: str, elements: Sequence[Elem],
                 mul: Callable[[Elem, Elem], Elem], one: Elem) -> None:
        self.name: str = name
        self.elements: List[Elem] = list(elements)
        self.mul: Callable[[Elem, Elem], Elem] = mul
        self.one: Elem = one

    @property
    def order(self) -> int:
        return len(self.elements)

    def inv(self, g: Elem) -> Elem:
        for h in self.elements:
            if self.mul(g, h) == self.one:
                return h
        raise ValueError(f"no inverse for {g!r} in {self.name}")

    def conjugate(self, u: Elem, g: Elem) -> Elem:
        """Return u * g * u^{-1}."""
        return self.mul(self.mul(u, g), self.inv(u))

    def centralizer(self, subset: Sequence[Elem]) -> List[Elem]:
        """C_G(S) = { x : x s = s x for all s in S }."""
        return [x for x in self.elements
                if all(self.mul(x, s) == self.mul(s, x) for s in subset)]

    def centre(self) -> List[Elem]:
        return self.centralizer(self.elements)

    def generators(self) -> List[Elem]:
        """A small generating set found greedily (used to speed up hom search)."""
        gens: List[Elem] = []
        span = {self.one}
        for g in self.elements:
            if g in span:
                continue
            gens.append(g)
            span = self._closure(gens)
            if len(span) == self.order:
                break
        return gens

    def _closure(self, gens: Sequence[Elem]) -> set:
        span = {self.one}
        frontier = [self.one]
        while frontier:
            x = frontier.pop()
            for g in gens:
                y = self.mul(x, g)
                if y not in span:
                    span.add(y)
                    frontier.append(y)
        return span


# --------------------------------------------------------------------------- #
#  Concrete groups
# --------------------------------------------------------------------------- #


def cyclic(n: int) -> FiniteGroup:
    """The cyclic group Z/n, written additively but multiplied as a group."""
    return FiniteGroup(f"Z/{n}", list(range(n)), lambda a, b: (a + b) % n, 0)


def klein_four() -> FiniteGroup:
    """The Klein four group (Z/2)^2."""
    els = [(a, b) for a in (0, 1) for b in (0, 1)]
    return FiniteGroup("(Z/2)^2", els,
                       lambda x, y: ((x[0] + y[0]) % 2, (x[1] + y[1]) % 2), (0, 0))


def symmetric(n: int) -> FiniteGroup:
    """The symmetric group S_n, elements are tuples encoding permutations."""
    els = list(permutations_of(n))
    one = tuple(range(n))

    def mul(p: Elem, q: Elem) -> Elem:
        # (p*q)(i) = p(q(i))
        return tuple(p[q[i]] for i in range(n))  # type: ignore[index]

    return FiniteGroup(f"S_{n}", els, mul, one)


def permutations_of(n: int) -> List[Tuple[int, ...]]:
    if n == 0:
        return [()]
    out: List[Tuple[int, ...]] = []
    for smaller in permutations_of(n - 1):
        for pos in range(n):
            out.append(smaller[:pos] + (n - 1,) + smaller[pos:])
    return out


def dihedral(n: int) -> FiniteGroup:
    """The dihedral group of order 2n, elements (r, s) with r in Z/n, s in {0,1}."""
    els = [(r, s) for s in (0, 1) for r in range(n)]

    def mul(x: Elem, y: Elem) -> Elem:
        r1, s1 = x  # type: ignore[misc]
        r2, s2 = y  # type: ignore[misc]
        if s1 == 0:
            return ((r1 + r2) % n, s2)
        return ((r1 - r2) % n, (s1 + s2) % 2)

    return FiniteGroup(f"D_{n}", els, mul, (0, 0))


# --------------------------------------------------------------------------- #
#  Homomorphisms, conjugation orbits, and the two classifications
# --------------------------------------------------------------------------- #


def all_homomorphisms(G: FiniteGroup, H: FiniteGroup) -> List[Dict[Elem, Elem]]:
    """Enumerate Hom(G, H) by assigning images to a generating set of G."""
    gens = G.generators()
    homs: List[Dict[Elem, Elem]] = []
    for images in product(H.elements, repeat=len(gens)):
        phi = extend_to_hom(G, H, gens, images)
        if phi is not None:
            homs.append(phi)
    return homs


def extend_to_hom(G: FiniteGroup, H: FiniteGroup, gens: Sequence[Elem],
                  images: Sequence[Elem]) -> Dict[Elem, Elem] | None:
    """Try to extend gens -> images to a homomorphism; return None if impossible."""
    phi: Dict[Elem, Elem] = {G.one: H.one}
    frontier = [G.one]
    while frontier:
        x = frontier.pop()
        for g, hg in zip(gens, images):
            y = G.mul(x, g)
            hy = H.mul(phi[x], hg)
            if y in phi:
                if phi[y] != hy:
                    return None
            else:
                phi[y] = hy
                frontier.append(y)
    if len(phi) != G.order:
        return None
    # final check of multiplicativity on all pairs
    for a in G.elements:
        for b in G.elements:
            if phi[G.mul(a, b)] != H.mul(phi[a], phi[b]):
                return None
    return phi


def freeze(phi: Dict[Elem, Elem], G: FiniteGroup) -> Hom:
    return tuple((g, phi[g]) for g in G.elements)


def conjugate_hom(H: FiniteGroup, u: Elem, phi: Dict[Elem, Elem]) -> Dict[Elem, Elem]:
    return {g: H.conjugate(u, h) for g, h in phi.items()}


def conjugation_orbits(G: FiniteGroup, H: FiniteGroup) -> List[List[Hom]]:
    """Partition Hom(G,H) into orbits of the conjugation action of H."""
    homs = all_homomorphisms(G, H)
    seen: set = set()
    orbits: List[List[Hom]] = []
    for phi in homs:
        key = freeze(phi, G)
        if key in seen:
            continue
        orbit = set()
        for u in H.elements:
            orbit.add(freeze(conjugate_hom(H, u, phi), G))
        seen |= orbit
        orbits.append(sorted(orbit))
    return orbits


def centralizer_index_of_image(G: FiniteGroup, H: FiniteGroup,
                               phi: Dict[Elem, Elem]) -> int:
    """[H : C_H(phi(G))]."""
    image = sorted(set(phi.values()), key=repr)
    return H.order // len(H.centralizer(image))


# --------------------------------------------------------------------------- #
#  Automorphisms, inner automorphisms, and Out
# --------------------------------------------------------------------------- #


def automorphisms(G: FiniteGroup) -> List[Dict[Elem, Elem]]:
    return [phi for phi in all_homomorphisms(G, G)
            if len(set(phi.values())) == G.order]


def inner_automorphisms(G: FiniteGroup) -> List[Hom]:
    return sorted({freeze({g: G.conjugate(u, g) for g in G.elements}, G)
                   for u in G.elements})


def out_order(G: FiniteGroup) -> int:
    return len(automorphisms(G)) // len(inner_automorphisms(G))


# --------------------------------------------------------------------------- #
#  The demonstrations
# --------------------------------------------------------------------------- #


def demo_fibre_theorem(G: FiniteGroup, H: FiniteGroup) -> None:
    """Check: every conjugation orbit has size [H : C_H(image)]."""
    print(f"\n--- Fibres of  [K({G.name},1), K({H.name},1)]_*  ->  "
          f"[K({G.name},1), K({H.name},1)] ---")
    orbits = conjugation_orbits(G, H)
    total = sum(len(o) for o in orbits)
    print(f"|Hom({G.name},{H.name})| = {total}   "
          f"(= number of POINTED homotopy classes)")
    print(f"number of conjugation orbits = {len(orbits)}   "
          f"(= number of UNPOINTED homotopy classes)")
    print(f"{'orbit size':>12} {'[H:C_H(im)]':>13} {'|image|':>8}  agree?")
    for orbit in sorted(orbits, key=len):
        rep = dict(orbit[0])
        predicted = centralizer_index_of_image(G, H, rep)
        image_size = len(set(rep.values()))
        ok = "yes" if predicted == len(orbit) else "NO!"
        print(f"{len(orbit):>12} {predicted:>13} {image_size:>8}  {ok}")
        assert predicted == len(orbit), "fibre theorem violated"


def demo_s3_test() -> None:
    """The decisive finite test: G = H = S_3, fibre sizes 1, 3, 6."""
    S3 = symmetric(3)
    print("\n=== The S_3 test =======================================")
    orbits = sorted(conjugation_orbits(S3, S3), key=len)
    sizes = [len(o) for o in orbits]
    print(f"orbit sizes of the conjugation action of S_3 on Hom(S_3,S_3): {sizes}")
    assert sizes == [1, 3, 6], sizes
    assert sum(sizes) == 10
    print("Interpretation:")
    print("  * over the class of the CONSTANT map          : 1 pointed class")
    print("  * over the class of the sign-and-swap map     : 3 pointed classes")
    print("  * over the class of the IDENTITY map          : 6 pointed classes")
    print("So the identity map of K(S_3,1) has six pairwise non-pointed-homotopic")
    print("pointed representatives, all homotopic once basepoints are forgotten.")
    centre = S3.centre()
    print(f"  [S_3 : Z(S_3)] = {S3.order // len(centre)} = 6, "
          f"and |Z(S_3)| = {len(centre)}")


def demo_abelian_case() -> None:
    """For abelian target, forgetting the basepoint is injective."""
    print("\n=== The abelian extreme ================================")
    for H in [cyclic(2), cyclic(6), klein_four(), cyclic(12)]:
        for G in [cyclic(4), symmetric(3), dihedral(4)]:
            orbits = conjugation_orbits(G, H)
            total = sum(len(o) for o in orbits)
            assert all(len(o) == 1 for o in orbits)
            print(f"  Hom({G.name:>4}, {H.name:>7}): "
                  f"{total:>3} pointed classes = {len(orbits):>3} unpointed "
                  f"classes  (all fibres of size 1)")


def demo_self_equivalences() -> None:
    """Pointed self-equivalences = Aut G;  unpointed = Out G."""
    print("\n=== Self-equivalences of K(G,1):  Aut G  versus  Out G ==")
    print(f"{'G':>8} {'|G|':>4} {'|Aut G|':>8} {'|Inn G|':>8} "
          f"{'|Out G|':>8} {'[G:Z(G)]':>9}")
    for G in [cyclic(1), cyclic(2), cyclic(4), cyclic(6), klein_four(),
              symmetric(3), dihedral(4), cyclic(8), symmetric(4)]:
        aut = len(automorphisms(G))
        inn = len(inner_automorphisms(G))
        idx = G.order // len(G.centre())
        assert inn == idx, "Inn G is not G/Z(G)"
        print(f"{G.name:>8} {G.order:>4} {aut:>8} {inn:>8} "
              f"{aut // inn:>8} {idx:>9}")
    print("The fibre of  Aut G  ->  Out G  over the identity class has "
          "[G:Z(G)] elements,")
    print("exactly the general fibre count applied to phi = id.")


def demo_strict_functoriality() -> None:
    """Composition of pointed classes is composition of homomorphisms, on the nose."""
    print("\n=== Strict functoriality of the pointed classification ==")
    S3 = symmetric(3)
    homs = all_homomorphisms(S3, S3)
    bad = 0
    for phi in homs:
        for psi in homs:
            comp = {g: psi[phi[g]] for g in S3.elements}
            # composition of pointed classes = composition of homomorphisms
            if any(comp[S3.mul(a, b)] != S3.mul(comp[a], comp[b])
                   for a in S3.elements for b in S3.elements):
                bad += 1
    print(f"checked {len(homs)**2} composites of pointed classes; "
          f"failures: {bad}")
    assert bad == 0
    print("By contrast, unpointed composition is only well defined on")
    print("conjugacy classes: the induced homomorphism of a composite is")
    print("merely CONJUGATE to the composite of the induced homomorphisms.")
    # exhibit the unpointed ambiguity concretely
    orbits = conjugation_orbits(S3, S3)
    reps = [dict(o[0]) for o in orbits]
    print("Composition table of the three unpointed classes "
          "(monoid of conjugacy classes of endomorphisms):")
    labels = {freeze(r, S3): i for i, o in enumerate(orbits) for r in [dict(x) for x in o]}
    for i, a in enumerate(reps):
        row = []
        for j, b in enumerate(reps):
            comp = {g: b[a[g]] for g in S3.elements}
            row.append(labels[freeze(comp, S3)])
        print(f"   class {i} composed with each class -> {row}")


def main() -> None:
    print("=" * 60)
    print("Pointed and unpointed classification of maps of 1-types")
    print("=" * 60)
    demo_s3_test()
    demo_fibre_theorem(symmetric(3), symmetric(3))
    demo_fibre_theorem(cyclic(6), symmetric(3))
    demo_fibre_theorem(symmetric(3), dihedral(4))
    demo_fibre_theorem(klein_four(), symmetric(4))
    demo_abelian_case()
    demo_self_equivalences()
    demo_strict_functoriality()
    print("\nAll assertions passed.")


if __name__ == "__main__":
    main()

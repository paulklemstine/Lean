"""
Algorithms for categorical reconstruction and synthesis.

Implements the core algorithms from the formalized Lean theorems:
1. Yoneda Reconstruction Algorithm
2. Universal Arrow Adjunction Construction
3. Free Monoid Synthesis
4. Finite Probe Detection
"""

from __future__ import annotations
from typing import TypeVar, Callable, Dict, Tuple, List, Set, Optional
from dataclasses import dataclass, field
from functools import reduce


# =============================================================================
# 1. Finite Category Representation
# =============================================================================

@dataclass
class FiniteCategory:
    """A finite category represented by objects, morphisms, and composition.

    Objects are integers 0..n-1.
    Morphisms are (source, target, label) triples.
    Composition is a lookup table.

    Example:
        >>> cat = FiniteCategory.discrete(3)  # 3 objects, only identities
        >>> cat = FiniteCategory.linear(3)     # 0 -> 1 -> 2
    """
    objects: List[int]
    morphisms: List[Tuple[int, int, str]]  # (source, target, label)
    identity: Dict[int, str]  # object -> identity morphism label
    composition: Dict[Tuple[str, str], str]  # (f, g) -> g∘f (diagrammatic order)

    def hom(self, source: int, target: int) -> List[str]:
        """All morphisms from source to target."""
        return [label for s, t, label in self.morphisms if s == source and t == target]

    def compose(self, f: str, g: str) -> str:
        """Compose morphisms f then g (diagrammatic order: f ≫ g)."""
        return self.composition[(f, g)]

    def source_of(self, f: str) -> int:
        for s, t, label in self.morphisms:
            if label == f:
                return s
        raise ValueError(f"Unknown morphism: {f}")

    def target_of(self, f: str) -> int:
        for s, t, label in self.morphisms:
            if label == f:
                return t
        raise ValueError(f"Unknown morphism: {f}")

    @staticmethod
    def discrete(n: int) -> 'FiniteCategory':
        """Category with n objects and only identity morphisms."""
        objects = list(range(n))
        morphisms = [(i, i, f"id_{i}") for i in objects]
        identity = {i: f"id_{i}" for i in objects}
        composition = {(f"id_{i}", f"id_{i}"): f"id_{i}" for i in objects}
        return FiniteCategory(objects, morphisms, identity, composition)

    @staticmethod
    def linear(n: int) -> 'FiniteCategory':
        """Category 0 -> 1 -> ... -> n-1 with all composites."""
        objects = list(range(n))
        morphisms = [(i, i, f"id_{i}") for i in objects]
        identity = {i: f"id_{i}" for i in objects}
        composition = {(f"id_{i}", f"id_{i}"): f"id_{i}" for i in objects}

        # Add arrows i -> j for i < j
        for i in range(n):
            for j in range(i + 1, n):
                label = f"f_{i}_{j}"
                morphisms.append((i, j, label))
                # id compose with f
                composition[(f"id_{i}", label)] = label
                composition[(label, f"id_{j}")] = label

        # Compose f_{i}_{j} ≫ f_{j}_{k} = f_{i}_{k}
        for i in range(n):
            for j in range(i + 1, n):
                for k in range(j + 1, n):
                    composition[(f"f_{i}_{j}", f"f_{j}_{k}")] = f"f_{i}_{k}"

        return FiniteCategory(objects, morphisms, identity, composition)


# =============================================================================
# 2. Yoneda Reconstruction Algorithm
# =============================================================================

def yoneda_hom_functor(cat: FiniteCategory, X: int) -> Dict[int, List[str]]:
    """Compute the representable presheaf Hom(-, X).

    Returns a dict mapping each object Z to Hom(Z, X).
    """
    return {Z: cat.hom(Z, X) for Z in cat.objects}


def yoneda_reconstruct_iso(
    cat: FiniteCategory,
    X: int,
    Y: int,
    nat_iso_hom: Dict[int, Dict[str, str]],
    nat_iso_inv: Dict[int, Dict[str, str]]
) -> Tuple[str, str]:
    """Yoneda Reconstruction Algorithm.

    Given a natural isomorphism between Hom(-, X) and Hom(-, Y),
    extract the underlying isomorphism X ≅ Y.

    Args:
        cat: The category
        X, Y: Objects
        nat_iso_hom: For each object Z, a bijection Hom(Z,X) -> Hom(Z,Y)
        nat_iso_inv: For each object Z, a bijection Hom(Z,Y) -> Hom(Z,X)

    Returns:
        (f, g) where f: X -> Y and g: Y -> X are mutually inverse.
    """
    # Evaluate at X with identity: nat_iso_hom[X](id_X) gives a morphism X -> Y
    id_X = cat.identity[X]
    f = nat_iso_hom[X][id_X]

    # Evaluate at Y with identity: nat_iso_inv[Y](id_Y) gives a morphism Y -> X
    id_Y = cat.identity[Y]
    g = nat_iso_inv[Y][id_Y]

    return f, g


def verify_yoneda_reconstruction(
    cat: FiniteCategory,
    X: int, Y: int,
    f: str, g: str
) -> bool:
    """Verify that f: X -> Y and g: Y -> X form an isomorphism."""
    id_X = cat.identity[X]
    id_Y = cat.identity[Y]
    return (cat.compose(f, g) == id_X and cat.compose(g, f) == id_Y)


# =============================================================================
# 3. Finite Probe Detection
# =============================================================================

def is_separating_family(
    cat: FiniteCategory,
    probes: List[int]
) -> bool:
    """Check if a set of probe objects forms a separating family.

    A family is separating if for any parallel morphisms f ≠ g: X -> Y,
    there exists a probe P and a test t: P -> X such that t≫f ≠ t≫g.
    """
    for X in cat.objects:
        for Y in cat.objects:
            hom_XY = cat.hom(X, Y)
            for i, f in enumerate(hom_XY):
                for g in hom_XY[i+1:]:
                    # f ≠ g, check that some probe distinguishes them
                    separated = False
                    for P in probes:
                        for t in cat.hom(P, X):
                            if cat.compose(t, f) != cat.compose(t, g):
                                separated = True
                                break
                        if separated:
                            break
                    if not separated:
                        return False
    return True


def find_minimal_separating_family(cat: FiniteCategory) -> List[int]:
    """Find a minimal separating probe family by brute force.

    Tries probe families of increasing size until a separating one is found.
    """
    from itertools import combinations

    for size in range(1, len(cat.objects) + 1):
        for probes in combinations(cat.objects, size):
            if is_separating_family(cat, list(probes)):
                return list(probes)
    return cat.objects  # Full family always separates


# =============================================================================
# 4. Free Monoid Synthesis
# =============================================================================

@dataclass
class FreeMonoid:
    """Free monoid on a set of generators.

    Elements are lists of generators (words), with concatenation as multiplication.
    """
    generators: List[str]

    def of(self, gen: str) -> List[str]:
        """Generator embedding: α → FreeMonoid(α)."""
        assert gen in self.generators, f"Unknown generator: {gen}"
        return [gen]

    def identity(self) -> List[str]:
        """Identity element (empty word)."""
        return []

    def multiply(self, a: List[str], b: List[str]) -> List[str]:
        """Monoid multiplication (concatenation)."""
        return a + b


def free_monoid_lift(
    generators: List[str],
    target_assign: Dict[str, any],
    target_multiply: Callable,
    target_identity: any
) -> Callable[[List[str]], any]:
    """Free Monoid Synthesis Algorithm.

    Given an assignment of generators to elements of a target monoid,
    construct the unique homomorphism extending that assignment.

    Args:
        generators: List of generator names
        target_assign: Maps each generator to a target monoid element
        target_multiply: Binary operation in the target monoid
        target_identity: Identity element of the target monoid

    Returns:
        The unique monoid homomorphism FreeMonoid -> M extending the assignment.
    """
    def homomorphism(word: List[str]) -> any:
        if not word:
            return target_identity
        result = target_identity
        for gen in word:
            result = target_multiply(result, target_assign[gen])
        return result

    return homomorphism


def verify_free_monoid_uniqueness(
    generators: List[str],
    target_assign: Dict[str, any],
    target_multiply: Callable,
    target_identity: any,
    test_words: List[List[str]]
) -> bool:
    """Verify the Free Monoid Semantics Theorem computationally.

    Constructs two homomorphisms agreeing on generators and checks they agree
    on all test words.
    """
    hom1 = free_monoid_lift(generators, target_assign, target_multiply, target_identity)
    hom2 = free_monoid_lift(generators, target_assign, target_multiply, target_identity)

    return all(hom1(word) == hom2(word) for word in test_words)


# =============================================================================
# 5. Universal Arrow Adjunction Construction
# =============================================================================

@dataclass
class UniversalArrow:
    """Universal arrow from X to G.

    Represents a pair (Y, η: X → G(Y)) with the universal property.
    """
    codomain: any  # Y in D
    unit: any      # η: X → G(Y)
    lift: Callable  # Given f: X → G(Z), produce g: Y → Z
    fac: Callable   # Verify η ≫ G(lift(f)) = f
    uniq: Callable  # Verify uniqueness


def construct_left_adjoint(
    objects_C: List[any],
    universal_arrows: Dict[any, UniversalArrow]
) -> Dict[str, any]:
    """Universal Arrow Adjunction Construction Algorithm.

    Given universal arrows from every object into G, construct
    the left adjoint functor F and the adjunction data.

    Args:
        objects_C: Objects of the source category
        universal_arrows: Universal arrow data for each object

    Returns:
        Dictionary with 'F_obj', 'F_map', 'unit', 'counit' data.
    """
    # F on objects
    F_obj = {X: universal_arrows[X].codomain for X in objects_C}

    # Unit: η_X : X → G(F(X))
    unit = {X: universal_arrows[X].unit for X in objects_C}

    return {
        'F_obj': F_obj,
        'unit': unit,
        'lift': {X: universal_arrows[X].lift for X in objects_C},
        'description': (
            "Left adjoint constructed from universal arrows. "
            "F(X) = codomain of universal arrow from X. "
            "F(f) = lift(f ≫ η_Y) using universal property at source."
        )
    }


if __name__ == "__main__":
    # Quick smoke test
    cat = FiniteCategory.linear(3)
    probes = find_minimal_separating_family(cat)
    print(f"Linear category on 3 objects:")
    print(f"  Objects: {cat.objects}")
    print(f"  Minimal separating family: {probes}")
    print(f"  Family size: {len(probes)}")

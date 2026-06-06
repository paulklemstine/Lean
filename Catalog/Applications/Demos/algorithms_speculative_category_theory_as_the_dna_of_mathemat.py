"""
Algorithms for the Adjunction Genome: Computational Models of Mathematical Mutations

This module implements the core algorithms for classifying and composing
adjunctions, computing Galois closures, and analyzing mutation spectra.
"""

from enum import Enum
from dataclasses import dataclass
from typing import Callable, TypeVar, Generic, Optional, Set, Tuple, List, Dict
import itertools

# ============================================================
# Mutation Type Classification
# ============================================================

class MutationType(Enum):
    """Classification of adjunctions by mutation severity."""
    EQUIVALENCE = "equivalence"      # Both unit and counit are iso
    REFLECTIVE = "reflective"        # Only counit is iso (gene deletion)
    COREFLECTIVE = "coreflective"    # Only unit is iso (gene insertion)
    GENERAL = "general"              # Neither is iso (full mutation)

    def __repr__(self) -> str:
        return f"MutationType.{self.name}"


def classify_mutation(unit_is_iso: bool, counit_is_iso: bool) -> MutationType:
    """Classify an adjunction by its mutation type.

    Args:
        unit_is_iso: Whether the unit natural transformation is an isomorphism.
        counit_is_iso: Whether the counit natural transformation is an isomorphism.

    Returns:
        The mutation type classification.
    """
    if unit_is_iso and counit_is_iso:
        return MutationType.EQUIVALENCE
    elif counit_is_iso:
        return MutationType.REFLECTIVE
    elif unit_is_iso:
        return MutationType.COREFLECTIVE
    else:
        return MutationType.GENERAL


# ============================================================
# Finite Category (for concrete computation)
# ============================================================

@dataclass
class FiniteCategory:
    """A finite category represented by objects and morphism sets.

    Objects are integers 0..n-1.
    Morphisms are represented as (source, target, label) triples.
    """
    n_objects: int
    morphisms: Dict[Tuple[int, int], List[str]]
    composition: Dict[Tuple[str, str], str]  # (f, g) -> g ∘ f
    identities: Dict[int, str]

    def hom(self, a: int, b: int) -> List[str]:
        """Get the set of morphisms from a to b."""
        return self.morphisms.get((a, b), [])


# ============================================================
# Galois Connection
# ============================================================

T = TypeVar('T')
S = TypeVar('S')


@dataclass
class GaloisConnection(Generic[T, S]):
    """A Galois connection between two partially ordered sets.

    l: T -> S (left adjoint / lower adjoint)
    u: S -> T (right adjoint / upper adjoint)

    Satisfying: l(a) <= b iff a <= u(b)
    """
    l: Callable[[T], S]
    u: Callable[[S], T]
    le_domain: Callable[[T, T], bool]
    le_codomain: Callable[[S, S], bool]

    def closure(self, a: T) -> T:
        """Compute the Galois closure u(l(a))."""
        return self.u(self.l(a))

    def kernel(self, b: S) -> S:
        """Compute the Galois kernel l(u(b))."""
        return self.l(self.u(b))

    def is_closed(self, a: T) -> bool:
        """Check if a is a fixed point of the closure."""
        return self.closure(a) == a

    def verify_unit(self, a: T) -> bool:
        """Verify a <= u(l(a))."""
        return self.le_domain(a, self.closure(a))

    def verify_counit(self, b: S) -> bool:
        """Verify l(u(b)) <= b."""
        return self.le_codomain(self.kernel(b), b)

    def verify_idempotent(self, a: T) -> bool:
        """Verify u(l(u(l(a)))) = u(l(a))."""
        cl_a = self.closure(a)
        cl_cl_a = self.closure(cl_a)
        return cl_a == cl_cl_a


# ============================================================
# Adjunction Chain Composition
# ============================================================

@dataclass
class AdjunctionData:
    """Data representing a finite adjunction between finite categories.

    The hom-set bijection Hom(F(X), Y) ≅ Hom(X, G(Y)) is stored explicitly.
    """
    source: FiniteCategory
    target: FiniteCategory
    F_obj: Dict[int, int]  # Object map of F
    G_obj: Dict[int, int]  # Object map of G
    unit: Dict[int, str]   # η_X : X -> GF(X)
    counit: Dict[int, str] # ε_Y : FG(Y) -> Y
    unit_is_iso: Dict[int, bool]   # Whether η_X is iso
    counit_is_iso: Dict[int, bool] # Whether ε_Y is iso

    def mutation_type(self) -> MutationType:
        """Classify this adjunction's mutation type."""
        all_unit_iso = all(self.unit_is_iso.values())
        all_counit_iso = all(self.counit_is_iso.values())
        return classify_mutation(all_unit_iso, all_counit_iso)


def compose_adjunctions(adj1: AdjunctionData, adj2: AdjunctionData) -> Dict:
    """Compose two adjunctions: (F₁⋙F₂) ⊣ (G₂⋙G₁).

    Returns:
        Dictionary with composite adjunction data.
    """
    # Compose object maps
    F_comp = {x: adj2.F_obj[adj1.F_obj[x]] for x in adj1.F_obj}
    G_comp = {y: adj1.G_obj[adj2.G_obj[y]] for y in adj2.G_obj}

    return {
        "F_composite": F_comp,
        "G_composite": G_comp,
        "source_mutation": adj1.mutation_type(),
        "target_mutation": adj2.mutation_type(),
    }


# ============================================================
# Mutation Spectrum Analysis
# ============================================================

def mutation_spectrum_stats(adjunctions: List[AdjunctionData]) -> Dict[MutationType, int]:
    """Compute the distribution of mutation types in a collection of adjunctions.

    Args:
        adjunctions: List of adjunction data.

    Returns:
        Dictionary mapping mutation types to counts.
    """
    counts: Dict[MutationType, int] = {mt: 0 for mt in MutationType}
    for adj in adjunctions:
        counts[adj.mutation_type()] += 1
    return counts


# ============================================================
# Galois Connection Examples
# ============================================================

def subgroup_closure_galois(group_size: int) -> GaloisConnection[frozenset, frozenset]:
    """Create the Galois connection for subgroup lattice of Z_n.

    l: subsets -> subgroups (closure to generated subgroup)
    u: subgroups -> subsets (forgetful inclusion)
    """
    def generate_subgroup(s: frozenset) -> frozenset:
        """Generate the subgroup of Z_n containing s."""
        if not s:
            return frozenset({0})
        # Find gcd of all elements
        from math import gcd
        from functools import reduce
        g = reduce(gcd, s)
        if g == 0:
            return frozenset({0})
        return frozenset(i for i in range(group_size) if i % g == 0)

    def include(s: frozenset) -> frozenset:
        """Include subgroup as a subset."""
        return s

    return GaloisConnection(
        l=generate_subgroup,
        u=include,
        le_domain=lambda a, b: a.issubset(b),
        le_codomain=lambda a, b: a.issubset(b),
    )


def divisibility_galois() -> GaloisConnection[int, int]:
    """Create the Galois connection for divisibility on positive integers.

    l(a) = a (identity on objects)
    u(b) = b (identity on objects)
    a | b iff a | b

    More interesting: l = (*k), u = gcd(-, k) for fixed k.
    """
    k = 6  # Fixed multiplier

    def multiply_k(a: int) -> int:
        return a * k

    def div_by_gcd(b: int) -> int:
        from math import gcd
        g = gcd(b, k)
        return b // g

    return GaloisConnection(
        l=multiply_k,
        u=div_by_gcd,
        le_domain=lambda a, b: a <= b,
        le_codomain=lambda a, b: a <= b,
    )


# ============================================================
# Evolutionary Path Analysis
# ============================================================

@dataclass
class EvolutionaryPath:
    """A sequence of adjunctions forming an evolutionary path between theories."""
    steps: List[MutationType]

    @property
    def length(self) -> int:
        return len(self.steps)

    @property
    def has_equivalence(self) -> bool:
        return MutationType.EQUIVALENCE in self.steps

    @property
    def mutation_complexity(self) -> int:
        """Count non-trivial mutations (not equivalences)."""
        return sum(1 for s in self.steps if s != MutationType.EQUIVALENCE)

    def simplify(self) -> 'EvolutionaryPath':
        """Remove trivial (equivalence) steps."""
        return EvolutionaryPath([s for s in self.steps if s != MutationType.EQUIVALENCE])

    def factorize(self) -> Dict[MutationType, int]:
        """Factor the path into mutation type counts."""
        counts: Dict[MutationType, int] = {}
        for s in self.steps:
            counts[s] = counts.get(s, 0) + 1
        return counts


def all_paths(n_steps: int) -> List[EvolutionaryPath]:
    """Generate all possible evolutionary paths of given length."""
    types = list(MutationType)
    paths = []
    for combo in itertools.product(types, repeat=n_steps):
        paths.append(EvolutionaryPath(list(combo)))
    return paths


def path_statistics(n_steps: int) -> Dict:
    """Compute statistics over all evolutionary paths of given length."""
    paths = all_paths(n_steps)
    complexities = [p.mutation_complexity for p in paths]
    return {
        "n_paths": len(paths),
        "avg_complexity": sum(complexities) / len(complexities) if complexities else 0,
        "max_complexity": max(complexities) if complexities else 0,
        "trivial_paths": sum(1 for p in paths if p.mutation_complexity == 0),
        "type_distribution": {
            mt.name: sum(1 for p in paths if mt in p.steps)
            for mt in MutationType
        },
    }

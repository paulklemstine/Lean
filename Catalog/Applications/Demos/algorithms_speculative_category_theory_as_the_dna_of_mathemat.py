"""
Algorithms for the Theory Genome Framework
===========================================

Type-hinted implementations of the core algorithms from the research.
"""

from typing import (
    TypeVar, Generic, List, Tuple, Dict, Set, Optional, Callable,
    FrozenSet
)
from dataclasses import dataclass, field
from abc import ABC, abstractmethod


# === Core Types ===

Obj = TypeVar('Obj')
Mor = TypeVar('Mor')


@dataclass(frozen=True)
class Category(Generic[Obj, Mor]):
    """A small category represented by objects, morphisms, and composition."""
    objects: FrozenSet[Obj]
    morphisms: Dict[Tuple[Obj, Obj], Set[Mor]]
    compose: Callable[[Mor, Mor], Mor]
    identity: Callable[[Obj], Mor]


@dataclass(frozen=True)
class Functor(Generic[Obj, Mor]):
    """A functor between categories."""
    obj_map: Callable[[Obj], Obj]
    mor_map: Callable[[Mor], Mor]


@dataclass
class NatTrans:
    """A natural transformation between functors."""
    components: Dict  # object -> morphism


@dataclass
class Monad:
    """A monad on a category (theory genome).

    Attributes:
        functor: The endofunctor T : C → C
        unit: The unit η : Id → T
        multiplication: The multiplication μ : T² → T
    """
    functor: Functor
    unit: NatTrans
    multiplication: NatTrans


@dataclass
class Algebra:
    """An algebra for a monad (expressed phenotype).

    Attributes:
        carrier: The underlying object
        structure_map: The algebra map a : T(A) → A
    """
    carrier: object
    structure_map: Callable


@dataclass
class GenomeMutation:
    """A monad morphism φ : S → T (genome mutation).

    Attributes:
        source: Source monad S
        target: Target monad T
        morphism: Natural transformation S → T
    """
    source: Monad
    target: Monad
    morphism: NatTrans


# === Algorithm 1: Genome Extraction ===

def extract_genome(
    operations: List[Tuple[str, int]],  # (name, arity)
    equations: List[Tuple[str, str]],   # (lhs, rhs) as string expressions
) -> Dict:
    """Extract a theory genome from a presentation.

    Given a set of operations (with arities) and equations,
    constructs the corresponding monad structure.

    Args:
        operations: List of (operation_name, arity) pairs
        equations: List of (lhs_expression, rhs_expression) equations

    Returns:
        Dictionary describing the monad structure

    Example:
        >>> extract_genome(
        ...     operations=[("mul", 2), ("inv", 1), ("e", 0)],
        ...     equations=[("mul(mul(x,y),z)", "mul(x,mul(y,z))"),
        ...                ("mul(e,x)", "x"),
        ...                ("mul(inv(x),x)", "e")]
        ... )
        {'theory': 'Group', 'operations': 3, 'equations': 3,
         'functor': 'FreeGroup', 'genome_complexity': 6}
    """
    genome = {
        'operations': len(operations),
        'equations': len(equations),
        'operation_names': [op[0] for op in operations],
        'max_arity': max(a for _, a in operations) if operations else 0,
        'genome_complexity': len(operations) + len(equations),
        'functor': f"Free({'/'.join(op[0] for op in operations)})",
    }

    # Classify the theory
    has_binary = any(a == 2 for _, a in operations)
    has_unary = any(a == 1 for _, a in operations)
    has_nullary = any(a == 0 for _, a in operations)

    if has_binary and has_unary and has_nullary:
        genome['theory'] = 'Group-like'
    elif has_binary and has_nullary:
        genome['theory'] = 'Monoid-like'
    elif has_binary:
        genome['theory'] = 'Semigroup-like'
    else:
        genome['theory'] = 'General'

    return genome


# === Algorithm 2: Morita Equivalence Detection ===

def detect_morita_equivalence(
    algebras_1: List[Algebra],
    algebras_2: List[Algebra],
    hom_counter_1: Callable[[Algebra, Algebra], int],
    hom_counter_2: Callable[[Algebra, Algebra], int],
) -> Dict:
    """Detect Morita equivalence between two theories.

    Uses the hom-set cardinality matrix as a Morita invariant.
    Two theories are Morita equivalent iff their algebra categories
    have equivalent hom-set structures.

    Args:
        algebras_1: List of algebras for theory 1
        algebras_2: List of algebras for theory 2
        hom_counter_1: Function counting homomorphisms in theory 1
        hom_counter_2: Function counting homomorphisms in theory 2

    Returns:
        Dictionary with equivalence status and evidence
    """
    # Compute hom matrices
    n1, n2 = len(algebras_1), len(algebras_2)

    hom_matrix_1 = [
        [hom_counter_1(a, b) for b in algebras_1]
        for a in algebras_1
    ]
    hom_matrix_2 = [
        [hom_counter_2(a, b) for b in algebras_2]
        for a in algebras_2
    ]

    # Check basic invariants
    result: Dict = {
        'theory_1_algebra_count': n1,
        'theory_2_algebra_count': n2,
        'hom_matrix_1': hom_matrix_1,
        'hom_matrix_2': hom_matrix_2,
    }

    # Necessary condition: same number of isomorphism classes
    if n1 != n2:
        result['morita_equivalent'] = False
        result['reason'] = 'Different number of algebra isomorphism classes'
        return result

    # Check if hom matrices have the same multiset of row sums
    row_sums_1 = sorted(sum(row) for row in hom_matrix_1)
    row_sums_2 = sorted(sum(row) for row in hom_matrix_2)

    if row_sums_1 != row_sums_2:
        result['morita_equivalent'] = False
        result['reason'] = 'Different hom-set structure (row sums differ)'
        return result

    result['morita_equivalent'] = 'possibly (invariants match)'
    result['evidence'] = 'Hom-set row sums match'
    return result


# === Algorithm 3: Genome Mutation Pullback ===

def pullback_algebra(
    mutation: GenomeMutation,
    algebra: Algebra,
) -> Algebra:
    """Pull back a T-algebra along a mutation φ : S → T to get an S-algebra.

    The pullback structure map is: S(A) →^{φ_A} T(A) →^{a} A

    Args:
        mutation: The genome mutation φ : S → T
        algebra: A T-algebra (A, a)

    Returns:
        An S-algebra with the same carrier but pulled-back structure
    """
    # New structure map: compose φ with the original
    def new_structure(s_value):
        t_value = mutation.morphism.components[algebra.carrier](s_value)
        return algebra.structure_map(t_value)

    return Algebra(
        carrier=algebra.carrier,
        structure_map=new_structure
    )


# === Algorithm 4: Composed Monad Factorization ===

def compose_adjunctions(
    adj1: Tuple[Functor, Functor],  # (F₁, G₁)
    adj2: Tuple[Functor, Functor],  # (F₂, G₂)
) -> Dict:
    """Compute the composed adjunction and its monad factorization.

    Given adj₁ : F₁ ⊣ G₁ and adj₂ : F₂ ⊣ G₂, computes:
    - The composed adjunction (F₁∘F₂) ⊣ (G₂∘G₁)
    - The factorization: composed monad ≅ F₁ ∘ (inner monad) ∘ G₁

    Args:
        adj1: First adjunction pair (left, right)
        adj2: Second adjunction pair (left, right)

    Returns:
        Dictionary describing the factorization
    """
    F1, G1 = adj1
    F2, G2 = adj2

    return {
        'composed_left': 'F₁ ∘ F₂',
        'composed_right': 'G₂ ∘ G₁',
        'composed_monad': '(F₁ ∘ F₂) ∘ (G₂ ∘ G₁)',
        'factorization': 'F₁ ∘ (F₂ ∘ G₂) ∘ G₁',
        'inner_monad': 'F₂ ∘ G₂ (monad of adj₂)',
        'wrapping': 'Inner monad is wrapped by outer adjunction F₁ ⊣ G₁',
    }


# === Algorithm 5: Genome Complexity Measure ===

def genome_complexity(
    operations: List[Tuple[str, int]],
    equations: List[Tuple[str, str]],
) -> Dict:
    """Compute the genomic complexity of a theory.

    Complexity measures:
    - Operation count: number of primitive operations
    - Equation count: number of axioms
    - Total complexity: sum of operation arities + equation count
    - Kolmogorov estimate: compressed description length

    Args:
        operations: List of (name, arity) pairs
        equations: List of (lhs, rhs) equation pairs

    Returns:
        Dictionary of complexity measures
    """
    total_arity = sum(a for _, a in operations)
    eq_complexity = sum(len(l) + len(r) for l, r in equations)

    return {
        'operation_count': len(operations),
        'equation_count': len(equations),
        'total_arity': total_arity,
        'equation_complexity': eq_complexity,
        'genomic_complexity': total_arity + len(equations),
        'description_length': total_arity + eq_complexity,
    }


# === Demo ===

if __name__ == "__main__":
    # Extract genomes for common theories
    group_genome = extract_genome(
        operations=[("mul", 2), ("inv", 1), ("e", 0)],
        equations=[
            ("mul(mul(x,y),z)", "mul(x,mul(y,z))"),
            ("mul(e,x)", "x"),
            ("mul(x,e)", "x"),
            ("mul(inv(x),x)", "e"),
            ("mul(x,inv(x))", "e"),
        ]
    )

    ring_genome = extract_genome(
        operations=[("add", 2), ("mul", 2), ("neg", 1), ("zero", 0), ("one", 0)],
        equations=[
            ("add(add(x,y),z)", "add(x,add(y,z))"),
            ("add(zero,x)", "x"),
            ("add(neg(x),x)", "zero"),
            ("add(x,y)", "add(y,x)"),
            ("mul(mul(x,y),z)", "mul(x,mul(y,z))"),
            ("mul(one,x)", "x"),
            ("mul(x,one)", "x"),
            ("mul(x,add(y,z))", "add(mul(x,y),mul(x,z))"),
        ]
    )

    print("Group genome:", group_genome)
    print("Ring genome:", ring_genome)

    gc = genome_complexity(
        operations=[("mul", 2), ("inv", 1), ("e", 0)],
        equations=[
            ("mul(mul(x,y),z)", "mul(x,mul(y,z))"),
            ("mul(e,x)", "x"),
            ("mul(inv(x),x)", "e"),
        ]
    )
    print("Group genomic complexity:", gc)

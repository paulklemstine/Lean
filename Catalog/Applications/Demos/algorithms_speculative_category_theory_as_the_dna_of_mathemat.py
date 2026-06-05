#!/usr/bin/env python3
"""
Algorithms for the Theory Genome Framework
===========================================

Type-hinted implementations of the core algorithms from
"Category Theory as the DNA of Mathematics."
"""

from typing import Callable, TypeVar, Generic, Set, Dict, List, Tuple, Optional
from dataclasses import dataclass, field
from itertools import combinations
import math

T = TypeVar('T')


@dataclass
class TheoryGenome(Generic[T]):
    """A mathematical theory defined by axioms over a universe type T.

    Attributes:
        universe: The set of all possible models.
        axioms: Map from axiom names to predicates.
    """
    universe: frozenset
    axioms: Dict[str, Callable[[T], bool]] = field(default_factory=dict)

    def models(self) -> frozenset:
        """Compute the phenotype: all elements satisfying every axiom.

        Time complexity: O(|universe| * |axioms|)
        """
        return frozenset(
            x for x in self.universe
            if all(p(x) for p in self.axioms.values())
        )

    def axiom_names(self) -> frozenset:
        return frozenset(self.axioms.keys())


def mutation_distance(t1: TheoryGenome, t2: TheoryGenome) -> int:
    """Compute the mutation distance: |axioms(T₁) Δ axioms(T₂)|.

    This is a pseudometric satisfying:
    - d(T, T) = 0
    - d(T₁, T₂) = d(T₂, T₁)
    - d(T₁, T₃) ≤ d(T₁, T₂) + d(T₂, T₃)

    Time complexity: O(|axioms₁| + |axioms₂|)
    """
    s1 = t1.axiom_names()
    s2 = t2.axiom_names()
    return len(s1.symmetric_difference(s2))


def is_morita_equivalent(t1: TheoryGenome, t2: TheoryGenome) -> bool:
    """Check phenotypic identity (same models, possibly different axioms).

    Two theories are Morita equivalent when they have the same models.
    Genotypic identity (same axioms) implies Morita equivalence,
    but not vice versa.

    Time complexity: O(|universe| * max(|axioms₁|, |axioms₂|))
    """
    return t1.models() == t2.models()


@dataclass
class MutationStep(Generic[T]):
    """A single mutation: adding or removing one axiom."""
    action: str  # "add" or "remove"
    name: str
    predicate: Optional[Callable[[T], bool]] = None


def apply_mutation(theory: TheoryGenome[T], step: MutationStep[T]) -> TheoryGenome[T]:
    """Apply a single mutation step to a theory.

    - add: T.axioms ∪ {step.predicate}
    - remove: T.axioms \ {step.name}

    Time complexity: O(|axioms|)
    """
    new_axioms = dict(theory.axioms)
    if step.action == "add" and step.predicate is not None:
        new_axioms[step.name] = step.predicate
    elif step.action == "remove":
        new_axioms.pop(step.name, None)
    return TheoryGenome(theory.universe, new_axioms)


def apply_path(theory: TheoryGenome[T], path: List[MutationStep[T]]) -> TheoryGenome[T]:
    """Apply a sequence of mutations (an evolutionary path).

    Satisfies the composition law:
        apply_path(T, p₁ ++ p₂) = apply_path(apply_path(T, p₁), p₂)

    Time complexity: O(|path| * |axioms|)
    """
    result = theory
    for step in path:
        result = apply_mutation(result, step)
    return result


def theories_of(universe: frozenset, model_set: frozenset) -> Dict[str, Callable]:
    """Compute the theory of a set of models: all predicates satisfied by every model.

    For a finite universe, we use "exclusion predicates" as a basis:
    for each element not in the model set, we add the axiom "x ≠ element."

    This is part of the Galois connection:
        Ax ⊆ theoriesOf(S) ↔ S ⊆ modelsOf(Ax)
    """
    excluded = universe - model_set
    return {f"≠{x}": (lambda y, x=x: y != x) for x in excluded}


def models_of(universe: frozenset, axioms: Dict[str, Callable]) -> frozenset:
    """Compute the models of a set of axioms.

    Part of the Galois connection dual to theories_of.
    """
    return frozenset(x for x in universe if all(p(x) for p in axioms.values()))


def closure_operator(universe: frozenset, model_set: frozenset) -> frozenset:
    """Apply the Galois closure: Mod(Th(S)).

    This is idempotent: closure(closure(S)) = closure(S).
    S ⊆ closure(S) always holds.

    Time complexity: O(|universe|²)
    """
    th = theories_of(universe, model_set)
    return models_of(universe, th)


def weighted_mutation_distance(
    t1: TheoryGenome, t2: TheoryGenome,
    weights: Optional[Dict[str, float]] = None
) -> float:
    """Weighted mutation distance using information-theoretic weights.

    Default weight for axiom p is -log₂(|Mod({p})|/|universe|),
    i.e., the information content of the axiom.

    Still satisfies the triangle inequality when all weights ≥ 0.
    """
    s1 = t1.axiom_names()
    s2 = t2.axiom_names()
    diff = s1.symmetric_difference(s2)

    if weights is None:
        # Compute information-theoretic weights
        all_axioms = {**t1.axioms, **t2.axioms}
        n = len(t1.universe)
        weights = {}
        for name in diff:
            if name in all_axioms:
                p = all_axioms[name]
                mod_count = sum(1 for x in t1.universe if p(x))
                ratio = mod_count / n if n > 0 else 1
                weights[name] = -math.log2(ratio) if ratio > 0 else float('inf')
            else:
                weights[name] = 1.0

    return sum(weights.get(name, 1.0) for name in diff)


def find_shortest_path(
    t1: TheoryGenome, t2: TheoryGenome
) -> List[MutationStep]:
    """Find a shortest mutation path from t1 to t2.

    Uses the symmetric difference: first remove axioms in t1 but not t2,
    then add axioms in t2 but not t1.

    Time complexity: O(|axioms₁| + |axioms₂|)
    """
    s1 = t1.axiom_names()
    s2 = t2.axiom_names()

    path: List[MutationStep] = []

    # Remove axioms in T₁ but not T₂
    for name in s1 - s2:
        path.append(MutationStep("remove", name))

    # Add axioms in T₂ but not T₁
    for name in s2 - s1:
        path.append(MutationStep("add", name, t2.axioms[name]))

    return path


def adjunction_defect(
    left: Callable, right: Callable,
    universe_c: frozenset, universe_d: frozenset
) -> float:
    """Measure how far a pair of functions is from being an equivalence.

    The defect is: |{x | right(left(x)) ≠ x}| / |universe_c|
                 + |{y | left(right(y)) ≠ y}| / |universe_d|

    Defect = 0 iff the pair is an equivalence (bijection).
    """
    nc = len(universe_c)
    nd = len(universe_d)

    unit_defect = sum(1 for x in universe_c if right(left(x)) != x)
    counit_defect = sum(1 for y in universe_d if left(right(y)) != y)

    return (unit_defect / nc if nc > 0 else 0) + (counit_defect / nd if nd > 0 else 0)


# --- Example usage ---

if __name__ == "__main__":
    U = frozenset(range(20))

    # Create some theories
    T_empty = TheoryGenome(U, {})
    T_pos = TheoryGenome(U, {"positive": lambda n: n > 0})
    T_even = TheoryGenome(U, {"even": lambda n: n % 2 == 0})
    T_pos_even = TheoryGenome(U, {
        "positive": lambda n: n > 0,
        "even": lambda n: n % 2 == 0
    })

    # Mutation distances
    print("Mutation distances:")
    print(f"  d(∅, {{pos}}) = {mutation_distance(T_empty, T_pos)}")
    print(f"  d({{pos}}, {{pos,even}}) = {mutation_distance(T_pos, T_pos_even)}")
    print(f"  d(∅, {{pos,even}}) = {mutation_distance(T_empty, T_pos_even)}")

    # Weighted distances
    print(f"\nWeighted mutation distances:")
    print(f"  d_w(∅, {{pos}}) = {weighted_mutation_distance(T_empty, T_pos):.2f}")
    print(f"  d_w(∅, {{even}}) = {weighted_mutation_distance(T_empty, T_even):.2f}")

    # Shortest path
    path = find_shortest_path(T_pos, T_pos_even)
    print(f"\nShortest path from {{pos}} to {{pos,even}}:")
    for step in path:
        print(f"  {step.action} '{step.name}'")

    # Closure operator
    S = frozenset({2, 4, 6})
    closed = closure_operator(U, S)
    double_closed = closure_operator(U, closed)
    print(f"\nClosure: S={sorted(S)} → closed={sorted(closed)} → double={sorted(double_closed)}")
    print(f"Idempotent: {closed == double_closed}")

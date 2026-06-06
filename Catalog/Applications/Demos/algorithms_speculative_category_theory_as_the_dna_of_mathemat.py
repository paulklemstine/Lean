"""
Theory Genome: Algorithms for Computing with Axiom Systems

Type-hinted implementations of the core Theory Genome operations.
"""

from typing import FrozenSet, Set, Callable, Tuple
import itertools


class AxiomSystem:
    """An axiom system with finite axioms, structures, and a satisfaction relation."""

    def __init__(
        self,
        axioms: Set[int],
        structures: Set[int],
        sat: Callable[[int, int], bool],
    ):
        self.axioms = frozenset(axioms)
        self.structures = frozenset(structures)
        self.sat = sat  # sat(structure, axiom) -> bool

    def model_class(self, theory: FrozenSet[int]) -> FrozenSet[int]:
        """Compute the model class of a theory: all structures satisfying every axiom."""
        return frozenset(
            m for m in self.structures
            if all(self.sat(m, a) for a in theory)
        )

    def theory_of(self, models: FrozenSet[int]) -> FrozenSet[int]:
        """Compute the theory of a model class: all axioms satisfied by every model."""
        return frozenset(
            a for a in self.axioms
            if all(self.sat(m, a) for m in models)
        )

    def theory_closure(self, theory: FrozenSet[int]) -> FrozenSet[int]:
        """Compute the closure of a theory: Th(Mod(T))."""
        return self.theory_of(self.model_class(theory))

    def model_closure(self, models: FrozenSet[int]) -> FrozenSet[int]:
        """Compute the closure of a model class: Mod(Th(C))."""
        return self.model_class(self.theory_of(models))

    def genomic_distance(self, t1: FrozenSet[int], t2: FrozenSet[int]) -> int:
        """Compute the genomic distance: |T1 △ T2|."""
        return len(t1.symmetric_difference(t2))

    def is_closed(self, theory: FrozenSet[int]) -> bool:
        """Check if a theory is closed (equals its closure)."""
        return theory == self.theory_closure(theory)

    def is_definable(self, models: FrozenSet[int]) -> bool:
        """Check if a model class is definable (equals its closure)."""
        return models == self.model_closure(models)

    def all_closed_theories(self) -> Set[FrozenSet[int]]:
        """Enumerate all closed theories."""
        closed = set()
        for r in range(len(self.axioms) + 1):
            for subset in itertools.combinations(self.axioms, r):
                theory = frozenset(subset)
                if self.is_closed(theory):
                    closed.add(theory)
        return closed

    def all_definable_classes(self) -> Set[FrozenSet[int]]:
        """Enumerate all definable model classes."""
        definable = set()
        for r in range(len(self.structures) + 1):
            for subset in itertools.combinations(self.structures, r):
                models = frozenset(subset)
                if self.is_definable(models):
                    definable.add(models)
        return definable

    def mutation_effect(self, theory: FrozenSet[int], axiom: int) -> Tuple[FrozenSet[int], FrozenSet[int]]:
        """Compute the effect of adding an axiom: returns (new_models, lost_models)."""
        old_models = self.model_class(theory)
        new_theory = theory | {axiom}
        new_models = self.model_class(new_theory)
        lost = old_models - new_models
        return new_models, lost


def satisfaction_matrix_to_system(matrix: list[list[bool]]) -> AxiomSystem:
    """Create an axiom system from a satisfaction matrix.

    matrix[m][a] = True means structure m satisfies axiom a.
    """
    n_structures = len(matrix)
    n_axioms = len(matrix[0]) if matrix else 0

    def sat(m: int, a: int) -> bool:
        return matrix[m][a]

    return AxiomSystem(
        axioms=set(range(n_axioms)),
        structures=set(range(n_structures)),
        sat=sat,
    )


def random_axiom_system(n_axioms: int, n_structures: int, p: float = 0.5) -> AxiomSystem:
    """Generate a random axiom system with Bernoulli(p) satisfaction."""
    import random
    matrix = [
        [random.random() < p for _ in range(n_axioms)]
        for _ in range(n_structures)
    ]
    return satisfaction_matrix_to_system(matrix)


if __name__ == "__main__":
    # Example: Group theory axiom system (simplified)
    # Axioms: 0=closure, 1=associativity, 2=identity, 3=inverses, 4=commutativity
    # Structures: 0=trivial, 1=Z2, 2=Z3, 3=S3, 4=Z4, 5=semigroup{0,1}
    matrix = [
        # clos  assoc ident inv  comm
        [True,  True,  True,  True,  True],   # trivial group
        [True,  True,  True,  True,  True],   # Z2
        [True,  True,  True,  True,  True],   # Z3
        [True,  True,  True,  True,  False],  # S3 (non-abelian)
        [True,  True,  True,  True,  True],   # Z4
        [True,  True,  False, False, True],   # commutative semigroup
    ]

    S = satisfaction_matrix_to_system(matrix)

    # Demonstrate key operations
    group_axioms = frozenset({0, 1, 2, 3})      # group theory
    abelian_axioms = frozenset({0, 1, 2, 3, 4})  # abelian group theory

    print("=== Theory Genome Framework Demo ===\n")

    print(f"Group axioms: {set(group_axioms)}")
    print(f"Models of group theory: {set(S.model_class(group_axioms))}")

    print(f"\nAbelian group axioms: {set(abelian_axioms)}")
    print(f"Models of abelian group theory: {set(S.model_class(abelian_axioms))}")

    print(f"\nGenomic distance (group → abelian): {S.genomic_distance(group_axioms, abelian_axioms)}")

    print(f"\nClosure of group axioms: {set(S.theory_closure(group_axioms))}")
    print(f"Is group theory closed? {S.is_closed(group_axioms)}")

    # Mutation effect
    new_models, lost = S.mutation_effect(group_axioms, 4)
    print(f"\nMutation: adding commutativity to group theory")
    print(f"  New model class: {set(new_models)}")
    print(f"  Lost models: {set(lost)}")

    # Count closed theories
    closed = S.all_closed_theories()
    print(f"\nNumber of closed theories: {len(closed)}")
    for t in sorted(closed, key=lambda x: (len(x), sorted(x))):
        print(f"  {set(t)} → models: {set(S.model_class(t))}")

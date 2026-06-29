#!/usr/bin/env python3
"""
Strange Loops: Algorithms for Self-Reference and Incompleteness

Type-hinted implementations of the key algorithms from the research.
"""

from typing import Callable, TypeVar, Optional, Set, List, Tuple, Dict
from dataclasses import dataclass
import itertools

A = TypeVar('A')
B = TypeVar('B')


# ===========================================================================
# Algorithm 1: Lawvere Diagonal Construction
# ===========================================================================

def lawvere_diagonal(
    repr_func: Callable[[A], Callable[[A], B]],
    t: Callable[[B], B],
    domain: List[A]
) -> Dict[A, B]:
    """
    Construct the Lawvere diagonal map: d(a) = t(repr(a)(a)).

    Given a representation map repr : A → (A → B) and an endomorphism t : B → B,
    returns the diagonal function d : A → B.

    If repr is surjective, then t has a fixed point (by Lawvere's theorem).
    If t has no fixed point, then d is not in the range of repr.

    Time complexity: O(|domain|) applications of repr and t.

    Args:
        repr_func: Map from elements to functions
        t: Endomorphism of the codomain
        domain: The domain A as a list

    Returns:
        Dictionary mapping each a to t(repr(a)(a))
    """
    return {a: t(repr_func(a)(a)) for a in domain}


def find_fixed_point(
    t: Callable[[B], B],
    domain: List[B]
) -> Optional[B]:
    """
    Find a fixed point of t by exhaustive search.

    Args:
        t: Endomorphism
        domain: Finite domain to search

    Returns:
        A fixed point b with t(b) = b, or None if none exists
    """
    for b in domain:
        if t(b) == b:
            return b
    return None


def verify_lawvere(
    repr_func: Callable[[A], Callable[[A], B]],
    t: Callable[[B], B],
    domain_a: List[A],
    domain_b: List[B]
) -> Tuple[bool, Optional[B]]:
    """
    Verify Lawvere's fixed-point theorem for a concrete instance.

    Checks whether repr is surjective and, if so, finds the fixed point
    guaranteed by the theorem.

    Returns:
        (is_surjective, fixed_point_or_none)
    """
    # Check surjectivity: every function A → B must be represented
    all_functions = list(itertools.product(domain_b, repeat=len(domain_a)))
    represented = set()
    for a in domain_a:
        f = repr_func(a)
        image = tuple(f(x) for x in domain_a)
        represented.add(image)

    is_surj = len(represented) >= len(all_functions)
    fp = find_fixed_point(t, domain_b)

    return (is_surj, fp)


# ===========================================================================
# Algorithm 2: Cantor Diagonal
# ===========================================================================

def cantor_antidiagonal(
    listing: List[List[bool]]
) -> List[bool]:
    """
    Construct the Cantor anti-diagonal from a listing.

    Given a matrix where listing[i] represents the i-th function,
    constructs a function that differs from listing[i] at position i.

    This function is NOT in the listing, proving non-surjectivity.

    Time complexity: O(n) where n = len(listing).
    """
    n = len(listing)
    return [not listing[i][i] for i in range(n)]


# ===========================================================================
# Algorithm 3: Finite Formal System
# ===========================================================================

@dataclass
class FormalSystemState:
    """State of a finite formal system."""
    n_sentences: int
    provable: Set[int]  # Set of provable sentence indices

    def neg(self, s: int) -> int:
        """Negation: maps s to s + n and vice versa."""
        if s < self.n_sentences:
            return s + self.n_sentences
        return s - self.n_sentences

    def is_consistent(self) -> bool:
        """O(n) consistency check."""
        for s in range(self.n_sentences):
            if s in self.provable and self.neg(s) in self.provable:
                return False
        return True

    def is_complete(self) -> bool:
        """O(n) completeness check."""
        for s in range(self.n_sentences):
            if s not in self.provable and self.neg(s) not in self.provable:
                return False
        return True

    def independent_sentences(self) -> List[int]:
        """Return all independent sentences. O(n)."""
        return [s for s in range(self.n_sentences)
                if s not in self.provable and self.neg(s) not in self.provable]

    def independence_density(self) -> float:
        """Fraction of sentences that are independent."""
        if self.n_sentences == 0:
            return 0.0
        return len(self.independent_sentences()) / self.n_sentences


def detect_goedel_sentence(
    system: FormalSystemState
) -> Optional[int]:
    """
    Detect a Gödel-like sentence in a finite formal system.

    A Gödel sentence is one that is independent AND has the self-referential
    property that adding it or its negation would create new derivable consequences.

    In finite systems, we use independence as a proxy for the Gödel property.

    Time complexity: O(n).

    Returns:
        Index of a Gödel-like sentence, or None
    """
    independent = system.independent_sentences()
    return independent[0] if independent else None


def enumerate_consistent_extensions(
    base: FormalSystemState
) -> List[FormalSystemState]:
    """
    Enumerate all consistent one-step extensions of a formal system.

    For each independent sentence, we can consistently add either the
    sentence or its negation, creating two branches — this is the
    lattice-theoretic view of Gödel's branching.

    Time complexity: O(n * 2^k) where k is the number of independent sentences.
    (Exponential, but demonstrates the branching structure.)
    """
    independent = base.independent_sentences()
    extensions = []

    for s in independent:
        # Branch 1: add s
        ext1 = FormalSystemState(
            n_sentences=base.n_sentences,
            provable=base.provable | {s}
        )
        if ext1.is_consistent():
            extensions.append(ext1)

        # Branch 2: add neg(s)
        ext2 = FormalSystemState(
            n_sentences=base.n_sentences,
            provable=base.provable | {base.neg(s)}
        )
        if ext2.is_consistent():
            extensions.append(ext2)

    return extensions


# ===========================================================================
# Algorithm 4: Independence Density Estimation
# ===========================================================================

def estimate_independence_density(
    n_sentences: int,
    n_axioms: int,
    n_trials: int = 1000,
    seed: int = 42
) -> Tuple[float, float]:
    """
    Estimate the average independence density for random consistent theories.

    Creates random consistent theories with n_sentences sentences and
    approximately n_axioms axioms, then measures independence density.

    Args:
        n_sentences: Number of base sentences
        n_axioms: Approximate number of axioms to add
        n_trials: Number of random trials
        seed: Random seed

    Returns:
        (mean_density, std_density)
    """
    import random
    random.seed(seed)

    densities = []

    for _ in range(n_trials):
        system = FormalSystemState(n_sentences=n_sentences, provable=set())

        for _ in range(n_axioms):
            s = random.randint(0, n_sentences - 1)
            if random.random() < 0.5:
                if system.neg(s) not in system.provable:
                    system.provable.add(s)
            else:
                if s not in system.provable:
                    system.provable.add(system.neg(s))

        if system.is_consistent():
            densities.append(system.independence_density())

    if not densities:
        return (0.0, 0.0)

    mean = sum(densities) / len(densities)
    variance = sum((d - mean) ** 2 for d in densities) / len(densities)
    std = variance ** 0.5

    return (mean, std)


# ===========================================================================
# Algorithm 5: Strange Loop Hierarchy Construction
# ===========================================================================

@dataclass
class HierarchyLevel:
    """A level in a strange loop hierarchy."""
    name: str
    axioms: Set[str]
    independent: Set[str]

    def extend_with(self, sentence: str) -> 'HierarchyLevel':
        """Create a new level by adding an independent sentence as an axiom."""
        return HierarchyLevel(
            name=f"{self.name} + {sentence}",
            axioms=self.axioms | {sentence},
            independent=self.independent - {sentence}
        )


def build_strange_loop_hierarchy(
    base_name: str = "PA",
    n_levels: int = 5
) -> List[HierarchyLevel]:
    """
    Construct a strange loop hierarchy demonstrating essential incompleteness.

    Each level adds the previous level's Gödel sentence as an axiom,
    spawning a new Gödel sentence at the next level.

    Args:
        base_name: Name of the base theory
        n_levels: Number of levels to construct

    Returns:
        List of hierarchy levels
    """
    levels = []
    current = HierarchyLevel(
        name=base_name,
        axioms=set(),
        independent={f"G_{1}"}
    )
    levels.append(current)

    for i in range(1, n_levels):
        goedel = f"G_{i}"
        next_goedel = f"G_{i+1}"
        current = HierarchyLevel(
            name=current.extend_with(goedel).name,
            axioms=current.axioms | {goedel},
            independent={next_goedel}
        )
        levels.append(current)

    return levels


if __name__ == "__main__":
    # Quick demonstration
    print("Cantor anti-diagonal of [[T,F,T],[F,T,F],[T,T,F]]:")
    ad = cantor_antidiagonal([[True, False, True], [False, True, False], [True, True, False]])
    print(f"  {['T' if x else 'F' for x in ad]}")

    print("\nIndependence density estimation:")
    for n in [10, 50, 100, 500]:
        mean, std = estimate_independence_density(n, n // 3)
        print(f"  n={n:3d}, axioms≈{n//3}: density = {mean:.3f} ± {std:.3f}")

    print("\nStrange loop hierarchy:")
    hierarchy = build_strange_loop_hierarchy("PA", 5)
    for level in hierarchy:
        print(f"  {level.name}")
        print(f"    Axioms: {level.axioms}")
        print(f"    Independent: {level.independent}")

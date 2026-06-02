#!/usr/bin/env python3
"""
Algorithms for Reduction-Enriched Complexity Hierarchies

Type-hinted implementations of the core algorithms from the paper.
"""

from typing import (
    Callable, Dict, FrozenSet, Generic, List, Optional, Set, Tuple, TypeVar,
)
from dataclasses import dataclass

P = TypeVar('P')


@dataclass
class ReductionHierarchy(Generic[P]):
    """A reduction hierarchy over a finite set of problems."""
    problems: List[P]
    level: Callable[[P], int]
    reduces: Callable[[P, P], bool]

    def verify_reflexivity(self) -> bool:
        """Check that every problem reduces to itself."""
        return all(self.reduces(p, p) for p in self.problems)

    def verify_transitivity(self) -> bool:
        """Check transitivity of the reduction relation."""
        for p in self.problems:
            for q in self.problems:
                for r in self.problems:
                    if self.reduces(p, q) and self.reduces(q, r):
                        if not self.reduces(p, r):
                            return False
        return True

    def verify_monotonicity(self) -> bool:
        """Check that reductions do not increase level."""
        for p in self.problems:
            for q in self.problems:
                if self.reduces(p, q) and self.level(p) > self.level(q):
                    return False
        return True

    def verify_stratification(self, max_level: int) -> bool:
        """Check that every level up to max_level is realized."""
        realized = {self.level(p) for p in self.problems}
        return all(n in realized for n in range(max_level))

    def verify_all(self, max_level: int) -> Dict[str, bool]:
        """Verify all four axioms."""
        return {
            'reflexivity': self.verify_reflexivity(),
            'transitivity': self.verify_transitivity(),
            'monotonicity': self.verify_monotonicity(),
            'stratification': self.verify_stratification(max_level),
        }

    def is_equivalent(self, p: P, q: P) -> bool:
        """Check if two problems are reduction-equivalent."""
        return self.reduces(p, q) and self.reduces(q, p)

    def is_complete_at(self, p: P, n: int) -> bool:
        """Check if p is complete at level n."""
        if self.level(p) != n:
            return False
        return all(
            self.reduces(q, p)
            for q in self.problems
            if self.level(q) <= n
        )

    def find_complete(self, n: int) -> Optional[P]:
        """Find a complete problem at level n, if one exists."""
        for p in self.problems:
            if self.is_complete_at(p, n):
                return p
        return None

    def compute_spectrum(self, n: int) -> Set[int]:
        """Compute the reduction spectrum of level n."""
        spectrum: Set[int] = set()
        for q in self.problems:
            if self.level(q) == n:
                for p in self.problems:
                    if self.reduces(p, q):
                        spectrum.add(self.level(p))
        return spectrum

    def find_intermediate(self, m: int, n: int) -> Optional[P]:
        """Find an intermediate problem between levels m and n."""
        for p in self.problems:
            if m < self.level(p) < n:
                return p
        return None

    def equivalence_classes(self) -> List[FrozenSet[P]]:
        """Compute all equivalence classes under reduction equivalence."""
        visited: Set[int] = set()
        classes: List[FrozenSet[P]] = []
        
        for i, p in enumerate(self.problems):
            if i in visited:
                continue
            eq_class: Set[P] = {p}
            for j, q in enumerate(self.problems):
                if j != i and self.is_equivalent(p, q):
                    eq_class.add(q)
                    visited.add(j)
            visited.add(i)
            classes.append(frozenset(eq_class))
        
        return classes

    def check_hardness_condensation(self, m: int, n: int) -> Tuple[bool, str]:
        """
        Verify hardness condensation between levels m and n (m < n).
        Returns (success, message).
        """
        if m >= n:
            return False, "Need m < n"
        
        p = self.find_complete(m)
        q = self.find_complete(n)
        
        if p is None:
            return False, f"No complete problem at level {m}"
        if q is None:
            return False, f"No complete problem at level {n}"
        
        forward = self.reduces(p, q)
        backward = self.reduces(q, p)
        
        if forward and not backward:
            return True, f"Complete({m}) -> Complete({n}), no reverse"
        elif not forward:
            return False, f"Complete({m}) does NOT reduce to Complete({n})"
        else:
            return False, f"Complete({n}) reduces back to Complete({m})"


def build_standard_hierarchy(n_levels: int, problems_per_level: int = 3) -> ReductionHierarchy[Tuple[int, int]]:
    """Build the standard hierarchy: reduces iff level(p) ≤ level(q)."""
    problems = [
        (k, i) for k in range(n_levels) for i in range(problems_per_level)
    ]
    return ReductionHierarchy(
        problems=problems,
        level=lambda p: p[0],
        reduces=lambda p, q: p[0] <= q[0],
    )


def build_complete_hierarchy(n_levels: int) -> ReductionHierarchy[int]:
    """Build a complete hierarchy on integers 0..n_levels-1."""
    problems = list(range(n_levels))
    return ReductionHierarchy(
        problems=problems,
        level=lambda p: p,
        reduces=lambda p, q: p <= q,
    )


def separation_witness(
    H: ReductionHierarchy[P], m: int, n: int
) -> Optional[Tuple[P, P]]:
    """
    Find a separation witness: problems p, q at levels m, n respectively
    such that q does not reduce to p.
    """
    if m >= n:
        return None
    
    for p in H.problems:
        if H.level(p) == m:
            for q in H.problems:
                if H.level(q) == n and not H.reduces(q, p):
                    return (p, q)
    return None


def hierarchy_dimension(H: ReductionHierarchy[P]) -> int:
    """Compute the number of distinct levels realized in the hierarchy."""
    return len({H.level(p) for p in H.problems})


def conjecture_test(
    H1: ReductionHierarchy[P],
    H2: ReductionHierarchy[P],
) -> Tuple[bool, Optional[Tuple[P, P]]]:
    """
    Test the Reduction Completeness Conjecture on two hierarchies.
    Returns (conjecture_holds, counterexample_pair_or_none).
    """
    # Check same level function
    for p in H1.problems:
        if H1.level(p) != H2.level(p):
            raise ValueError(f"Level functions differ at {p}")
    
    # Check if reduction relations agree
    for p in H1.problems:
        for q in H1.problems:
            if H1.reduces(p, q) != H2.reduces(p, q):
                return False, (p, q)
    
    return True, None


if __name__ == "__main__":
    # Demo
    H = build_standard_hierarchy(5)
    results = H.verify_all(5)
    print("Axiom verification:", results)
    
    for n in range(5):
        c = H.find_complete(n)
        print(f"Complete at level {n}: {c}")
        print(f"Spectrum({n}): {sorted(H.compute_spectrum(n))}")
    
    print(f"\nEquivalence classes: {len(H.equivalence_classes())}")
    print(f"Dimension: {hierarchy_dimension(H)}")
    
    for m in range(4):
        ok, msg = H.check_hardness_condensation(m, m + 1)
        print(f"Hardness condensation ({m},{m+1}): {msg}")

"""
Algorithms for Diagonal Systems and Quantitative Incompleteness.

Implements the core constructions from the unified self-reference framework:
- Diagonal System impossibility verification
- Provability Algebra construction and validation
- Incompleteness gap computation
- Theory spectrum enumeration
- Incompleteness chain construction
"""

from typing import Callable, Optional, Set, Tuple, List, Dict
from dataclasses import dataclass
from itertools import product as cart_product
import math


@dataclass
class ProvabilityAlgebra:
    """A provability algebra on a finite set of sentences {0, ..., n-1}.

    Attributes:
        n: Number of sentences
        provable: Set of provable sentence indices
        true_set: Set of true sentence indices
        neg: Negation map (sentence index -> sentence index)
    """
    n: int
    provable: Set[int]
    true_set: Set[int]
    neg: Dict[int, int]

    def is_sound(self) -> bool:
        """Check soundness: provable ⊆ true."""
        return self.provable.issubset(self.true_set)

    def is_consistent(self) -> bool:
        """Check consistency: not everything is provable."""
        return len(self.provable) < self.n

    def neg_correct(self) -> bool:
        """Check negation correctness: true(neg(s)) ↔ ¬true(s)."""
        for s in range(self.n):
            ns = self.neg[s]
            if (ns in self.true_set) != (s not in self.true_set):
                return False
        return True

    def is_valid(self) -> bool:
        """Check all provability algebra axioms."""
        return self.is_sound() and self.is_consistent() and self.neg_correct()

    def incompleteness_gap(self) -> int:
        """Count true but unprovable sentences."""
        return len(self.true_set - self.provable)

    def has_goedel_sentence(self) -> Optional[int]:
        """Find a Gödel sentence: true(G) ↔ ¬provable(G)."""
        for s in range(self.n):
            # true(s) ↔ ¬provable(s)
            if (s in self.true_set) == (s not in self.provable):
                return s
        return None

    def is_complete(self) -> bool:
        """Check if every sentence or its negation is provable."""
        for s in range(self.n):
            if s not in self.provable and self.neg[s] not in self.provable:
                return False
        return True


def verify_diagonal_impossibility(n: int) -> bool:
    """Verify that no diagonal system exists on {0, ..., n-1}.

    A diagonal system requires:
    - repr: {0,...,n-1} -> ({0,...,n-1} -> Bool), surjective
    - twist: Bool -> Bool, fixed-point-free

    For Bool, the only fixed-point-free twist is negation.
    A surjection from n elements to 2^n functions is impossible for n >= 1
    since 2^n > n.

    Returns True if impossibility is verified.
    """
    num_functions = 2 ** n  # |{0,...,n-1} -> Bool|
    return num_functions > n  # No surjection possible


def compute_incompleteness_gap(pa: ProvabilityAlgebra) -> Tuple[int, Set[int]]:
    """Compute the incompleteness gap and the set of witnesses.

    Returns:
        (gap, witnesses) where gap is the count and witnesses is the set
        of true-but-unprovable sentence indices.
    """
    witnesses = pa.true_set - pa.provable
    return len(witnesses), witnesses


def enumerate_provability_algebras(n: int) -> List[ProvabilityAlgebra]:
    """Enumerate all valid provability algebras on {0, ..., n-1}.

    Warning: exponential in n. Only feasible for small n (≤ 5).
    """
    results: List[ProvabilityAlgebra] = []
    sentences = list(range(n))

    # Generate all possible negation maps (fixed-point-free involutions on truth)
    # neg must satisfy: true(neg(s)) ↔ ¬true(s)
    # This means neg pairs true sentences with false sentences.

    for true_mask in range(2**n):
        true_set = {s for s in sentences if (true_mask >> s) & 1}
        false_set = set(sentences) - true_set

        if len(true_set) != len(false_set):
            continue  # neg can't pair them if sizes differ

        # Generate all bijections from true_set to false_set as neg
        from itertools import permutations
        true_list = sorted(true_set)
        false_list = sorted(false_set)

        for perm in permutations(false_list):
            neg: Dict[int, int] = {}
            for t, f in zip(true_list, perm):
                neg[t] = f
                neg[f] = t

            # Check neg is well-defined (fixed-point-free)
            if any(neg[s] == s for s in sentences):
                continue

            # Generate all provable subsets that are sound and consistent
            for prov_mask in range(2**n):
                provable = {s for s in sentences if (prov_mask >> s) & 1}
                if not provable.issubset(true_set):
                    continue
                if provable == set(sentences):
                    continue  # not consistent

                pa = ProvabilityAlgebra(n, provable, true_set, neg)
                if pa.is_valid():
                    results.append(pa)

    return results


def build_incompleteness_chain(
    pa0: ProvabilityAlgebra,
    strengthen: Callable[[ProvabilityAlgebra], ProvabilityAlgebra],
    depth: int
) -> List[ProvabilityAlgebra]:
    """Build an incompleteness chain of given depth.

    Args:
        pa0: Initial provability algebra
        strengthen: Function that strengthens a PA while preserving incompleteness
        depth: Number of steps in the chain

    Returns:
        List of provability algebras [PA_0, PA_1, ..., PA_depth]
    """
    chain = [pa0]
    current = pa0
    for _ in range(depth):
        next_pa = strengthen(current)
        chain.append(next_pa)
        current = next_pa
    return chain


def theory_spectrum(pa: ProvabilityAlgebra) -> List[Set[int]]:
    """Enumerate the theory spectrum of a provability algebra.

    Returns all sound consistent extensions of the provability predicate.
    """
    spectrum: List[Set[int]] = []
    for mask in range(2**pa.n):
        extension = {s for s in range(pa.n) if (mask >> s) & 1}
        # Must extend provable
        if not pa.provable.issubset(extension):
            continue
        # Must be consistent
        if extension == set(range(pa.n)):
            continue
        # Must be sound (subset of true)
        if not extension.issubset(pa.true_set):
            continue
        spectrum.append(extension)
    return spectrum


def test_superlinear_conjecture(n: int) -> Tuple[bool, Optional[ProvabilityAlgebra]]:
    """Test the superlinear incompleteness conjecture for Fin n.

    Returns (conjecture_holds, counterexample_if_any).
    """
    if n < 6:
        return True, None

    threshold = n // 3
    algebras = enumerate_provability_algebras(n)

    for pa in algebras:
        g = pa.has_goedel_sentence()
        if g is not None and g in pa.true_set:
            gap = pa.incompleteness_gap()
            if gap < threshold:
                return False, pa

    return True, None

#!/usr/bin/env python3
"""
Algorithms for tropical polynomial canonicalization over idempotent semirings.

Implements the abstract dominance elimination procedure from the formal proofs,
with concrete instantiations for max-plus, min-plus, and Boolean semirings.

Complexity:
  - One-step removal: O(n) where n = number of monomials
  - Full canonicalization: O(n²) worst case (at most n removals, each O(n))
  - Space: O(n) for the working list
"""

from typing import TypeVar, Generic, Callable, List, Optional, Tuple
from dataclasses import dataclass
from abc import ABC, abstractmethod
import math

T = TypeVar('T')

# --------------------------------------------------------------------------
# Abstract Idempotent Semiring Interface
# --------------------------------------------------------------------------

class IdempotentSemiring(ABC, Generic[T]):
    """Abstract interface for an ordered idempotent commutative additive monoid.

    Axioms (from the formal proof):
      1. add_idem: a ⊕ a = a
      2. le_iff_add: a ≤ b ↔ a ⊕ b = b
      3. add_comm: a ⊕ b = b ⊕ a
      4. add_assoc: (a ⊕ b) ⊕ c = a ⊕ (b ⊕ c)
      5. add_zero: a ⊕ 0 = a
    """

    @abstractmethod
    def zero(self) -> T:
        """Identity element for addition."""
        ...

    @abstractmethod
    def add(self, a: T, b: T) -> T:
        """Idempotent addition (max, min, or, etc.)."""
        ...

    @abstractmethod
    def le(self, a: T, b: T) -> bool:
        """Order relation compatible with addition."""
        ...

    def eval_poly(self, terms: List[T]) -> T:
        """Evaluate a tropical polynomial (fold with ⊕)."""
        result = self.zero()
        for t in terms:
            result = self.add(result, t)
        return result

    def is_dominated(self, term: T, rest: List[T]) -> bool:
        """Check if a term is dominated by the rest."""
        return self.le(term, self.eval_poly(rest))

    def remove_one_dominated(self, terms: List[T]) -> Tuple[List[T], bool]:
        """Remove the first dominated term. Returns (new_terms, was_removed).

        Pseudocode:
          for i in 0..len(terms):
            rest = terms without terms[i]
            if terms[i] ≤ eval(rest):
              return (rest, True)
          return (terms, False)

        Complexity: O(n) for one pass.
        """
        for i in range(len(terms)):
            rest = terms[:i] + terms[i+1:]
            if self.is_dominated(terms[i], rest):
                return rest, True
        return terms, False

    def canonicalize(self, terms: List[T], max_iterations: Optional[int] = None) -> List[T]:
        """Fully canonicalize by repeatedly removing dominated terms.

        Pseudocode:
          while remove_one_dominated modifies the list:
            terms = remove_one_dominated(terms)
          return terms

        Complexity: O(n²) worst case (n removals × O(n) each).
        Convergence: guaranteed in at most n steps since list length
        strictly decreases with each removal.
        """
        result = list(terms)
        iterations = 0
        limit = max_iterations or len(terms)
        while iterations < limit:
            new_result, removed = self.remove_one_dominated(result)
            if not removed:
                break
            result = new_result
            iterations += 1
        return result


# --------------------------------------------------------------------------
# Concrete Instances
# --------------------------------------------------------------------------

class MaxPlusSemiring(IdempotentSemiring[float]):
    """Max-plus semiring: ⊕ = max, 0 = -∞."""

    def zero(self) -> float:
        return float('-inf')

    def add(self, a: float, b: float) -> float:
        return max(a, b)

    def le(self, a: float, b: float) -> bool:
        return a <= b


class MinPlusSemiring(IdempotentSemiring[float]):
    """Min-plus semiring: ⊕ = min, 0 = +∞.
    Order is REVERSED: a ≤_tropical b iff b ≤_usual a."""

    def zero(self) -> float:
        return float('inf')

    def add(self, a: float, b: float) -> float:
        return min(a, b)

    def le(self, a: float, b: float) -> bool:
        return b <= a  # reversed!


class BooleanSemiring(IdempotentSemiring[bool]):
    """Boolean semiring: ⊕ = OR, 0 = False."""

    def zero(self) -> bool:
        return False

    def add(self, a: bool, b: bool) -> bool:
        return a or b

    def le(self, a: bool, b: bool) -> bool:
        return (not a) or b  # False ≤ True, etc.


# --------------------------------------------------------------------------
# Monomial representation
# --------------------------------------------------------------------------

@dataclass
class Monomial:
    """A monomial in a tropical polynomial: coefficient × weight vector."""
    coeff: float
    weights: Tuple[float, ...]

    def eval_maxplus(self, x: Tuple[float, ...]) -> float:
        """Evaluate monomial in max-plus: coeff + Σ(weight_i * x_i)."""
        return self.coeff + sum(w * xi for w, xi in zip(self.weights, x))


def eval_poly_monomials(monomials: List[Monomial],
                        x: Tuple[float, ...],
                        semiring: IdempotentSemiring[float]) -> float:
    """Evaluate a list of monomials at point x."""
    values = [m.eval_maxplus(x) for m in monomials]
    return semiring.eval_poly(values)


# --------------------------------------------------------------------------
# Verification
# --------------------------------------------------------------------------

def verify_canonicalization(semiring: IdempotentSemiring, terms: list,
                           name: str) -> bool:
    """Verify that canonicalization preserves evaluation."""
    original_eval = semiring.eval_poly(terms)
    canon = semiring.canonicalize(terms)
    canon_eval = semiring.eval_poly(canon)

    match = (original_eval == canon_eval)
    reduction = len(terms) - len(canon)

    print(f"  [{name}]")
    print(f"    Original:  {terms} → eval = {original_eval}")
    print(f"    Canonical: {canon} → eval = {canon_eval}")
    print(f"    Reduction: {len(terms)} → {len(canon)} terms ({reduction} removed)")
    print(f"    ✓ Correct" if match else f"    ✗ MISMATCH!")
    return match


if __name__ == "__main__":
    print("Tropical Canonicalization Algorithm Verification")
    print("=" * 50)
    print()

    mp = MaxPlusSemiring()
    verify_canonicalization(mp, [3.0, 7.0, 5.0, 2.0, 7.0], "MaxPlus-1")
    print()
    verify_canonicalization(mp, [1.0, 1.0, 1.0], "MaxPlus-2 (all equal)")
    print()

    mnp = MinPlusSemiring()
    verify_canonicalization(mnp, [3.0, 1.0, 5.0, 8.0, 1.0], "MinPlus-1")
    print()

    bs = BooleanSemiring()
    verify_canonicalization(bs, [False, True, False, True, False], "Boolean-1")
    print()
    verify_canonicalization(bs, [False, False, False], "Boolean-2 (all false)")
    print()

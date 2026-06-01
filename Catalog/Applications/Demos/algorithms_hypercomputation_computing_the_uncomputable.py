#!/usr/bin/env python3
"""
Hypercomputation: Algorithms and Data Structures

Type-hinted implementations of the core algorithms from the hypercomputation
formalization. These provide computational models for the abstract mathematical
structures defined in the Lean proofs.
"""

from __future__ import annotations
from dataclasses import dataclass, field
from typing import Set, Callable, Optional, List, Dict, Tuple
import math


@dataclass
class DecisionProblem:
    """A decision problem represented as a finite subset of ℕ."""
    members: Set[int] = field(default_factory=set)
    
    def contains(self, n: int) -> bool:
        return n in self.members
    
    def is_subset_of(self, other: DecisionProblem) -> bool:
        return self.members.issubset(other.members)
    
    def __eq__(self, other: object) -> bool:
        if not isinstance(other, DecisionProblem):
            return NotImplemented
        return self.members == other.members
    
    def __hash__(self) -> int:
        return hash(frozenset(self.members))


@dataclass
class HypercomputationModel:
    """
    A hypercomputation model consisting of a base set and a jump operator.
    
    The jump operator must satisfy:
    - Extensiveness: S ⊆ jump(S)
    - Strictness: ∃n ∈ jump(S) \ S
    - Monotonicity: S ⊆ T ⟹ jump(S) ⊆ jump(T)
    """
    base: DecisionProblem
    jump: Callable[[DecisionProblem], DecisionProblem]
    
    def level(self, n: int) -> DecisionProblem:
        """Compute the n-th level of the oracle hierarchy."""
        if n == 0:
            return self.base
        return self.jump(self.level(n - 1))
    
    def omega_level(self, max_n: int = 100) -> DecisionProblem:
        """Approximate the ω-level as the union of levels 0..max_n."""
        result: Set[int] = set()
        for n in range(max_n):
            result |= self.level(n).members
        return DecisionProblem(result)
    
    def verify_extensiveness(self, S: DecisionProblem) -> bool:
        """Check that S ⊆ jump(S)."""
        return S.is_subset_of(self.jump(S))
    
    def verify_strictness(self, S: DecisionProblem) -> Optional[int]:
        """Find a witness n ∈ jump(S) \ S, or None if none exists."""
        jumped = self.jump(S)
        diff = jumped.members - S.members
        return min(diff) if diff else None
    
    def verify_hierarchy(self, num_levels: int) -> List[Tuple[int, bool, Optional[int]]]:
        """Verify the strict hierarchy for levels 0..num_levels."""
        results = []
        for n in range(num_levels - 1):
            ln = self.level(n)
            ln1 = self.level(n + 1)
            is_strict = ln.members != ln1.members
            witness = None
            diff = ln1.members - ln.members
            if diff:
                witness = min(diff)
            results.append((n, is_strict, witness))
        return results


@dataclass
class ResourceBoundedOracle:
    """
    An oracle machine with resource costs.
    
    The cost function must be positive and strictly monotone.
    """
    model: HypercomputationModel
    cost: Callable[[int], float]
    
    def cumulative_cost(self, n: int) -> float:
        """Compute the cumulative cost to reach level n."""
        return sum(self.cost(i) for i in range(n))
    
    def find_level_for_budget(self, budget: float) -> int:
        """Find the maximum oracle level achievable within a given budget."""
        level = 0
        total = 0.0
        while total + self.cost(level) <= budget:
            total += self.cost(level)
            level += 1
        return level
    
    def verify_divergence(self, target: float, max_n: int = 10000) -> Optional[int]:
        """Find n such that cumulative_cost(n) > target, or None."""
        total = 0.0
        for n in range(max_n):
            total += self.cost(n)
            if total > target:
                return n
        return None


def diagonal_set(family: Dict[int, Set[int]], universe: int) -> Set[int]:
    """
    Compute the diagonal set: {n | n ∉ family[n]}.
    
    This is the key construction in all undecidability proofs.
    The diagonal set is guaranteed to differ from every member of the family.
    
    Algorithm:
    1. For each n in [0, universe):
    2.   Check if n ∈ family[n]
    3.   If not, include n in the diagonal set
    
    Time complexity: O(universe)
    Space complexity: O(universe)
    """
    return {n for n in range(universe) if n not in family.get(n, set())}


def oracle_strength(model: HypercomputationModel, problem: DecisionProblem, 
                    max_level: int = 100) -> int:
    """
    Compute the oracle strength of a problem: the minimum level k
    such that problem ⊆ level(k).
    
    Algorithm:
    1. For k = 0, 1, 2, ..., max_level:
    2.   Compute level(k)
    3.   If problem ⊆ level(k), return k
    4. Return -1 if no such k found
    
    Time complexity: O(max_level * |problem| * jump_cost)
    """
    for k in range(max_level + 1):
        if problem.is_subset_of(model.level(k)):
            return k
    return -1


def classify_problem(model: HypercomputationModel, problem: DecisionProblem,
                     max_level: int = 100) -> str:
    """
    Classify a problem as essentially computable, accidentally computable,
    or undecidable (at all checked levels).
    
    Algorithm:
    1. Check if problem ⊆ base (essentially computable)
    2. If not, find minimum level k > 0 with problem ⊆ level(k)
    3. If found, classify as accidentally computable with strength k
    4. If not found up to max_level, classify as undecidable
    """
    if problem.is_subset_of(model.base):
        return "essentially_computable"
    
    strength = oracle_strength(model, problem, max_level)
    if strength > 0:
        return f"accidentally_computable(strength={strength})"
    elif strength == 0:
        return "essentially_computable"
    else:
        return "undecidable_at_checked_levels"


def build_concrete_model(universe: int = 100) -> HypercomputationModel:
    """
    Build a concrete hypercomputation model.
    
    Base: multiples of 2 in [0, universe)
    Jump: adds the next prime number not in the current set
    """
    def is_prime(n: int) -> bool:
        if n < 2:
            return False
        for i in range(2, int(math.sqrt(n)) + 1):
            if n % i == 0:
                return False
        return True
    
    base = DecisionProblem({n for n in range(universe) if n % 2 == 0})
    
    def jump(S: DecisionProblem) -> DecisionProblem:
        # Add the smallest number not in S
        new_members = set(S.members)
        for n in range(universe):
            if n not in new_members:
                new_members.add(n)
                break
        return DecisionProblem(new_members)
    
    return HypercomputationModel(base=base, jump=jump)


def oracle_reducibility_check(model: HypercomputationModel,
                               P: DecisionProblem, Q: DecisionProblem,
                               max_level: int = 50) -> bool:
    """
    Check if P is oracle-reducible to Q: for all k, Q ⊆ level(k) ⟹ P ⊆ level(k).
    
    Algorithm: Check all levels up to max_level.
    """
    for k in range(max_level + 1):
        lvl = model.level(k)
        if Q.is_subset_of(lvl) and not P.is_subset_of(lvl):
            return False
    return True


if __name__ == "__main__":
    # Build a concrete model and demonstrate
    model = build_concrete_model(20)
    
    print("Concrete Hypercomputation Model")
    print(f"Base: {sorted(model.base.members)}")
    
    for n in range(6):
        lvl = model.level(n)
        print(f"Level {n}: {sorted(lvl.members)}")
    
    print("\nHierarchy verification:")
    results = model.verify_hierarchy(6)
    for n, is_strict, witness in results:
        print(f"  Level {n} ⊊ Level {n+1}: strict={is_strict}, witness={witness}")
    
    # Resource model
    rbo = ResourceBoundedOracle(model=model, cost=lambda n: 2.0 ** n)
    print("\nResource costs (exponential):")
    for n in range(10):
        print(f"  Level {n}: cost={rbo.cost(n):.0f}, "
              f"cumulative={rbo.cumulative_cost(n + 1):.0f}")
    
    print(f"\nMax level for budget 1000: {rbo.find_level_for_budget(1000)}")
    print(f"Level needed to exceed cost 10000: {rbo.verify_divergence(10000)}")

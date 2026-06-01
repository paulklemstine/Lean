#!/usr/bin/env python3
"""
Type-hinted implementations of algorithms from the Transfinite Oracle Hierarchy framework.
"""

from typing import Set, Callable, List, Tuple, Optional, FrozenSet
from dataclasses import dataclass
from functools import lru_cache


# ============================================================
# Core Data Structures
# ============================================================

@dataclass(frozen=True)
class JumpOperator:
    """
    An abstract jump operator on finite subsets of ℕ.
    
    A jump operator J satisfies:
    - Expansion: S ⊆ J(S)  
    - Nontriviality: ∃x ∈ J(S) \ S
    """
    name: str
    _jump_fn: Callable[[FrozenSet[int]], FrozenSet[int]]
    
    def jump(self, S: FrozenSet[int]) -> FrozenSet[int]:
        """Apply the jump operator."""
        result = self._jump_fn(S)
        assert S.issubset(result), f"Expansion violated: {S} ⊄ {result}"
        assert result - S, f"Nontriviality violated: J(S) = S for S = {S}"
        return result
    
    def verify_axioms(self, S: FrozenSet[int]) -> Tuple[bool, bool]:
        """Verify the expansion and nontriviality axioms on a specific set."""
        result = self._jump_fn(S)
        expanding = S.issubset(result)
        nontrivial = bool(result - S)
        return expanding, nontrivial


@dataclass
class OracleChain:
    """An oracle chain built by iterating a jump operator."""
    jump: JumpOperator
    base: FrozenSet[int]
    levels: List[FrozenSet[int]]
    
    @classmethod
    def build(cls, jump: JumpOperator, base: FrozenSet[int], 
              num_levels: int) -> 'OracleChain':
        """Build an oracle chain with the specified number of levels."""
        levels = [base]
        for _ in range(num_levels):
            levels.append(jump.jump(levels[-1]))
        return cls(jump=jump, base=base, levels=levels)
    
    def is_strictly_increasing(self) -> bool:
        """Verify the strict hierarchy property."""
        for i in range(len(self.levels) - 1):
            if not (self.levels[i] < self.levels[i + 1]):  # strict subset
                return False
        return True
    
    def information_gap(self, n: int) -> FrozenSet[int]:
        """Compute the information gap at level n."""
        assert 0 <= n < len(self.levels) - 1
        return self.levels[n + 1] - self.levels[n]
    
    def gap_sizes(self) -> List[int]:
        """Compute the size of each information gap."""
        return [len(self.information_gap(n)) for n in range(len(self.levels) - 1)]


@dataclass
class PhysicalHypercomputer:
    """
    A physical hypercomputer modeled as a sequence of finite approximations.
    """
    stages: List[Callable[[int], bool]]
    target: Callable[[int], bool]
    
    def converges_at(self, x: int, max_stage: int = 1000) -> Optional[int]:
        """Find the convergence stage for input x, or None if not found."""
        for n in range(min(len(self.stages), max_stage)):
            if all(self.stages[m](x) == self.target(x) for m in range(n, min(n + 10, len(self.stages)))):
                return n
        return None
    
    def first_error(self, stage_idx: int, max_input: int = 1000) -> Optional[int]:
        """Find the first input where the given stage errs."""
        if stage_idx >= len(self.stages):
            return None
        for x in range(max_input):
            if self.stages[stage_idx](x) != self.target(x):
                return x
        return None


# ============================================================
# Concrete Jump Operators
# ============================================================

def make_diagonal_jump(universe: int = 10000) -> JumpOperator:
    """The simplest jump: add the smallest non-member."""
    def jump_fn(S: FrozenSet[int]) -> FrozenSet[int]:
        for i in range(universe):
            if i not in S:
                return S | frozenset({i})
        return S | frozenset({universe})
    
    return JumpOperator(name="diagonal", _jump_fn=jump_fn)


def make_enriched_jump(universe: int = 10000) -> JumpOperator:
    """Enriched jump: add |S|+1 new elements."""
    def jump_fn(S: FrozenSet[int]) -> FrozenSet[int]:
        to_add = len(S) + 1
        new_elements: Set[int] = set()
        for i in range(universe):
            if i not in S:
                new_elements.add(i)
                if len(new_elements) >= to_add:
                    break
        return S | frozenset(new_elements)
    
    return JumpOperator(name="enriched", _jump_fn=jump_fn)


def make_doubling_jump(universe: int = 10000) -> JumpOperator:
    """Doubling jump: add enough elements to at least double the set size."""
    def jump_fn(S: FrozenSet[int]) -> FrozenSet[int]:
        target_size = max(len(S) * 2, len(S) + 1)
        result = set(S)
        for i in range(universe):
            if i not in result:
                result.add(i)
                if len(result) >= target_size:
                    break
        return frozenset(result)
    
    return JumpOperator(name="doubling", _jump_fn=jump_fn)


# ============================================================
# Algorithms
# ============================================================

def cantor_diagonal(enum: Callable[[int, int], bool], size: int) -> Callable[[int], bool]:
    """
    Cantor's diagonal argument: construct a function that differs
    from enum(n) at position n for every n.
    
    Proves that ℕ → Bool is uncountable.
    """
    def diagonal(x: int) -> bool:
        return not enum(x, x)
    
    # Verify: diagonal ≠ enum(n) for all n < size
    for n in range(size):
        assert diagonal(n) != enum(n, n), f"Diagonal failed at n={n}"
    
    return diagonal


def verify_essential_accidental_gap(
    family: Callable[[int, int], bool],
    f: Callable[[int], bool],
    max_n: int = 100,
    max_x: int = 100,
) -> Tuple[bool, bool]:
    """
    Verify the essential-accidental gap for a specific function f:
    1. Is f accidentally correct at every point? (pointwise match)
    2. Is f essentially computable? (global match)
    
    Returns (accidentally_correct, essentially_computable).
    """
    # Check accidentally correct
    accidentally_correct = True
    for x in range(max_x):
        found = False
        for n in range(max_n):
            if family(n, x) == f(x):
                found = True
                break
        if not found:
            accidentally_correct = False
            break
    
    # Check essentially computable
    essentially_computable = False
    for n in range(max_n):
        if all(family(n, x) == f(x) for x in range(max_x)):
            essentially_computable = True
            break
    
    return accidentally_correct, essentially_computable


def simulate_ordinal_chain(
    jump: JumpOperator,
    finite_levels: int,
    limit_levels: int = 3,
) -> List[Tuple[str, FrozenSet[int]]]:
    """
    Simulate an ordinal oracle chain:
    - Levels 0..finite_levels: successor steps
    - Level ω: union of all finite levels
    - Levels ω+1..ω+limit_levels: successor steps from ω
    
    Returns list of (label, set) pairs.
    """
    # Finite levels
    chain: List[Tuple[str, FrozenSet[int]]] = []
    current = frozenset[int]()
    chain.append(("0", current))
    
    for i in range(1, finite_levels + 1):
        current = jump.jump(current)
        chain.append((str(i), current))
    
    # Level ω: union of all finite levels
    omega_level = frozenset[int]().union(*[s for _, s in chain])
    chain.append(("ω", omega_level))
    
    # Successor levels from ω
    current = omega_level
    for i in range(1, limit_levels + 1):
        current = jump.jump(current)
        chain.append((f"ω+{i}", current))
    
    return chain


def measure_gap_growth(jump: JumpOperator, levels: int) -> List[Tuple[int, int]]:
    """
    Measure the information gap size at each level.
    Returns list of (level, gap_size) pairs.
    """
    chain = OracleChain.build(jump, frozenset(), levels)
    return [(n, len(chain.information_gap(n))) for n in range(levels)]


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("Oracle Chain Analysis")
    print("=" * 50)
    
    for jump in [make_diagonal_jump(), make_enriched_jump(), make_doubling_jump()]:
        print(f"\nJump operator: {jump.name}")
        chain = OracleChain.build(jump, frozenset(), 10)
        print(f"  Strictly increasing: {chain.is_strictly_increasing()}")
        print(f"  Gap sizes: {chain.gap_sizes()}")
    
    print("\n\nOrdinal Chain Simulation")
    print("=" * 50)
    jump = make_enriched_jump()
    ordinal_chain = simulate_ordinal_chain(jump, finite_levels=5, limit_levels=3)
    for label, level in ordinal_chain:
        print(f"  Level {label:5s}: |S| = {len(level):4d}")
    
    print("\n\nGap Growth Analysis")
    print("=" * 50)
    for jump in [make_diagonal_jump(), make_enriched_jump(), make_doubling_jump()]:
        gaps = measure_gap_growth(jump, 15)
        print(f"\n  {jump.name}: {[g for _, g in gaps]}")

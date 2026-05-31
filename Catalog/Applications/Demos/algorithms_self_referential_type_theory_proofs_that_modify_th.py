"""
Algorithms for Stratified Self-Reference

Implements the core data structures and algorithms for the stratified
self-referential type system, including specification iteration,
diagonal barrier detection, and consistency tower construction.
"""

from __future__ import annotations
from dataclasses import dataclass, field
from typing import Callable, Optional, List, Tuple, Dict, Any
import math


@dataclass
class StratifiedSpec:
    """A specification at a given universe level."""
    level: int
    pred: Callable[[int], bool]

    def __repr__(self) -> str:
        return f"StratifiedSpec(level={self.level})"


@dataclass
class SelfModifier:
    """A level-bounded self-modifier on specifications.
    
    Invariant: modify(s).level <= s.level for all s.
    """
    modify: Callable[[StratifiedSpec], StratifiedSpec]

    def iterate(self, n: int, spec: StratifiedSpec) -> StratifiedSpec:
        """Apply the modifier n times."""
        current = spec
        for _ in range(n):
            current = self.modify(current)
        return current


def self_ref_depth(modifier: SelfModifier, spec: StratifiedSpec) -> int:
    """Compute the self-reference depth: how many levels the spec
    drops through iterated modification up to spec.level steps."""
    iterated = modifier.iterate(spec.level, spec)
    return spec.level - iterated.level


def iterate_until_stable(
    modifier: SelfModifier,
    spec: StratifiedSpec,
    max_steps: int = 1000
) -> Tuple[StratifiedSpec, int, List[int]]:
    """Iterate modification until the level stabilizes.
    
    Returns:
        - The stabilized specification
        - Number of steps to stabilize
        - The full level trace
    """
    current = spec
    levels: List[int] = [current.level]
    for i in range(1, max_steps + 1):
        next_spec = modifier.modify(current)
        levels.append(next_spec.level)
        if next_spec.level == current.level:
            return next_spec, i, levels
        current = next_spec
    return current, max_steps, levels


def check_diagonal_barrier(
    family: List[StratifiedSpec],
    diag_level: int,
    test_points: List[int]
) -> Dict[str, Any]:
    """Check whether the diagonal argument is blocked at a given level.
    
    For a family of predicates indexed by level, constructs the diagonal
    predicate and checks if it matches any family member at the target level.
    
    Args:
        family: List of specifications indexed by their position
        diag_level: The level at which to attempt diagonalization
        test_points: Points at which to evaluate predicates
    
    Returns:
        Dictionary with diagonal analysis results
    """
    if diag_level >= len(family):
        return {"blocked": True, "reason": "diag_level out of range"}

    target_pred = family[diag_level].pred

    # Construct diagonal: negate the target at each test point
    diagonal_values = {x: not target_pred(x) for x in test_points}

    # Check if any family member at the same level matches the diagonal
    matches = []
    for i, spec in enumerate(family):
        if spec.level == diag_level:
            match = all(
                spec.pred(x) == diagonal_values[x]
                for x in test_points
            )
            if match:
                matches.append(i)

    return {
        "blocked": len(matches) == 0,
        "diagonal_values": diagonal_values,
        "matching_indices": matches,
        "target_level": diag_level,
        "reason": "no match found" if not matches else "PARADOX: match found"
    }


@dataclass
class LevelTheory:
    """A formal theory at a given level."""
    level: int
    sentences: List[str]
    provable: Callable[[str], bool]
    con_statement: str


@dataclass
class ConsistencyTower:
    """A tower of theories where each level proves the consistency
    of the level below."""
    theories: List[LevelTheory]

    def verify_tower(self) -> List[Dict[str, Any]]:
        """Verify that each level proves the consistency of the level below."""
        results = []
        for i in range(1, len(self.theories)):
            lower = self.theories[i - 1]
            upper = self.theories[i]
            # Check that the upper theory can prove the lower's consistency
            con_provable = upper.provable(f"Con({lower.con_statement})")
            results.append({
                "lower_level": lower.level,
                "upper_level": upper.level,
                "consistency_proved": con_provable,
                "lower_con": lower.con_statement,
            })
        return results


def build_demo_tower(n_levels: int) -> ConsistencyTower:
    """Build a demonstration consistency tower with n levels.
    
    Each level's theory is a simple model where:
    - Level 0 proves basic arithmetic statements
    - Level k+1 proves everything level k proves plus Con(T_k)
    """
    theories = []
    for level in range(n_levels):
        provable_set = set()
        # Each level proves its own basic sentences
        provable_set.add(f"0 = 0 at level {level}")
        provable_set.add(f"∀n, n = n at level {level}")
        # Each level proves consistency of all lower levels
        for j in range(level):
            provable_set.add(f"Con(T_{j})")

        theory = LevelTheory(
            level=level,
            sentences=list(provable_set),
            provable=lambda s, ps=provable_set: s in ps,
            con_statement=f"T_{level}",
        )
        theories.append(theory)

    return ConsistencyTower(theories=theories)


@dataclass
class SelfModifyingProof:
    """A self-modifying proof system."""
    spec_modifier: SelfModifier
    witness_modifier: Callable[[int], int]

    def iterate_proof(
        self,
        spec: StratifiedSpec,
        witness: int,
        n_steps: int
    ) -> List[Tuple[StratifiedSpec, int, bool]]:
        """Iterate the proof system and track satisfaction at each step."""
        results = []
        current_spec = spec
        current_witness = witness
        for _ in range(n_steps):
            satisfied = current_spec.pred(current_witness)
            results.append((current_spec, current_witness, satisfied))
            current_spec = self.spec_modifier.modify(current_spec)
            current_witness = self.witness_modifier(current_witness)
        return results


def compute_stratification_gap(
    n: int,
    sample_size: int = 100
) -> Dict[str, Any]:
    """Computationally test the exponential stratification gap conjecture.
    
    For Fin(2^n), sample random self-modifiers and compute the
    self-reference depth, checking if it's bounded by n.
    
    Args:
        n: The level parameter (type size is 2^n)
        sample_size: Number of random modifiers to test
    
    Returns:
        Results of the computational test
    """
    import random
    type_size = 2 ** n
    max_depth = 0
    depths: List[int] = []

    for _ in range(sample_size):
        # Random level for the specification (up to 2n to test beyond n)
        spec_level = random.randint(0, 2 * n)

        # Random self-modifier: decrease level by 0 or 1
        decrease = random.choice([0, 0, 0, 1])  # Usually stays same

        def make_modifier(dec: int) -> SelfModifier:
            def mod_fn(s: StratifiedSpec) -> StratifiedSpec:
                new_level = max(0, s.level - dec)
                return StratifiedSpec(level=new_level, pred=s.pred)
            return SelfModifier(modify=mod_fn)

        modifier = make_modifier(decrease)
        spec = StratifiedSpec(
            level=spec_level,
            pred=lambda x, ts=type_size: x < ts
        )
        depth = self_ref_depth(modifier, spec)
        depths.append(depth)
        max_depth = max(max_depth, depth)

    conjecture_holds = max_depth <= n
    return {
        "n": n,
        "type_size": type_size,
        "sample_size": sample_size,
        "max_depth": max_depth,
        "bound": n,
        "conjecture_holds": conjecture_holds,
        "mean_depth": sum(depths) / len(depths) if depths else 0,
        "depths": depths,
    }

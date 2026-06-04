#!/usr/bin/env python3
"""
Algorithms for Ordinal Cellular Automata
=========================================

Type-hinted implementations of the core algorithms from the formalization.
"""

from typing import Callable, TypeVar, Generic
from dataclasses import dataclass
from enum import Enum

S = TypeVar('S')


@dataclass
class OrdinalCA(Generic[S]):
    """
    An Ordinal Cellular Automaton.
    
    - local_rule: (left, center, right) -> new_state
    - quiescent: default/boundary state
    - limit_agg: aggregation function for limit ordinal stages
    """
    local_rule: Callable[[S, S, S], S]
    quiescent: S
    limit_agg: Callable[[list[S]], S]

    def succ_step(self, config: list[S]) -> list[S]:
        """Apply local rule to produce successor configuration."""
        n = len(config)
        result = []
        for i in range(n):
            left = config[i - 1] if i > 0 else self.quiescent
            center = config[i]
            right = config[i + 1] if i < n - 1 else self.quiescent
            result.append(self.local_rule(left, center, right))
        return result

    def evolve_finite(self, init: list[S], steps: int) -> list[list[S]]:
        """Evolve for finitely many successor steps."""
        trajectory = [init]
        current = init
        for _ in range(steps):
            current = self.succ_step(current)
            trajectory.append(current)
        return trajectory

    def evolve_omega(self, init: list[S], steps_per_layer: int,
                     layers: int) -> list[list[S]]:
        """
        Simulate transfinite evolution up to ω·layers.
        
        Each layer runs steps_per_layer successor steps, then applies
        limit aggregation to produce the initial config for the next layer.
        This models evolution up to ordinal ω·layers.
        """
        trajectory = []
        current = init

        for layer in range(layers):
            # Successor steps within this layer
            layer_history = self.evolve_finite(current, steps_per_layer)
            trajectory.extend(layer_history)

            # Limit aggregation at ω·(layer+1)
            # Aggregate the history at each cell position
            n = len(current)
            aggregated = []
            for pos in range(n):
                cell_history = [cfg[pos] for cfg in layer_history]
                aggregated.append(self.limit_agg(cell_history))
            current = aggregated

        return trajectory


def rule110(left: bool, center: bool, right: bool) -> bool:
    """
    Rule 110 (Wolfram numbering).
    
    Binary encoding: 01101110 = 110
    Known to be Turing-complete for standard CAs.
    """
    idx = (int(left) << 2) | (int(center) << 1) | int(right)
    return bool((110 >> idx) & 1)


def identity_rule(left: bool, center: bool, right: bool) -> bool:
    """Identity rule: ignores neighbors."""
    return center


def majority_limit_agg(history: list[bool]) -> bool:
    """Majority vote: True if more than half the history is True."""
    if not history:
        return False
    return sum(history) > len(history) // 2


def cofinal_truth_agg(history: list[bool]) -> bool:
    """Cofinal truth: True if the last element in history is True."""
    return history[-1] if history else False


def always_true_agg(history: list[bool]) -> bool:
    """Always returns True (the witness for strict transfinite extension)."""
    return True


def or_agg(history: list[bool]) -> bool:
    """OR aggregation: True if any element in history is True."""
    return any(history)


# Pre-built automata

def make_rule110_oca(agg: Callable[[list[bool]], bool] = majority_limit_agg) -> OrdinalCA[bool]:
    """Create a Rule 110 OCA with specified limit aggregation."""
    return OrdinalCA(local_rule=rule110, quiescent=False, limit_agg=agg)


def make_identity_oca(agg: Callable[[list[bool]], bool] = always_true_agg) -> OrdinalCA[bool]:
    """Create an identity OCA (witness for transfinite extension)."""
    return OrdinalCA(local_rule=identity_rule, quiescent=False, limit_agg=agg)


def analyze_convergence(oca: OrdinalCA[bool], init: list[bool],
                        max_steps: int = 1000) -> dict:
    """
    Analyze convergence behavior of an OCA's finite evolution.
    
    Returns:
        dict with keys: converged, convergence_step, period, fixed_point
    """
    current = init
    seen: dict[tuple, int] = {tuple(init): 0}

    for t in range(1, max_steps + 1):
        current = oca.succ_step(current)
        key = tuple(current)
        if key in seen:
            period_start = seen[key]
            return {
                'converged': True,
                'convergence_step': t,
                'period_start': period_start,
                'period': t - period_start,
                'fixed_point': t - period_start == 1 and period_start == t - 1
            }
        seen[key] = t

    return {
        'converged': False,
        'convergence_step': None,
        'period_start': None,
        'period': None,
        'fixed_point': False
    }


def compute_novelty_set(oca: OrdinalCA[bool], init: list[bool],
                        max_steps: int = 100) -> list[int]:
    """
    Compute the novelty set: time steps where genuinely new configs appear.
    Corresponds to OrdinalCA.noveltySet in the formalization.
    """
    seen: set[tuple] = set()
    novel_steps = []
    current = init

    for t in range(max_steps + 1):
        key = tuple(current)
        if key not in seen:
            novel_steps.append(t)
            seen.add(key)
        if t < max_steps:
            current = oca.succ_step(current)

    return novel_steps


if __name__ == "__main__":
    # Demo: Rule 110 convergence analysis
    width = 15
    init = [False] * width
    init[width // 2] = True

    oca = make_rule110_oca()
    result = analyze_convergence(oca, init)
    print(f"Rule 110 convergence: {result}")

    novelty = compute_novelty_set(oca, init, 50)
    print(f"Novelty set (first 50 steps): {novelty}")
    print(f"Number of distinct configs: {len(novelty)}")

    # Demo: Identity OCA transfinite extension
    oca_id = make_identity_oca()
    init_false = [False] * 10
    result_id = analyze_convergence(oca_id, init_false, 20)
    print(f"\nIdentity OCA convergence: {result_id}")
    print(f"Identity OCA finite orbit = {{all-False}} (size 1)")
    print(f"At time ω, limit aggregation produces all-True → orbit strictly larger")

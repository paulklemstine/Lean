#!/usr/bin/env python3
"""
Algorithms for Transfinite Cellular Automata
=============================================
Type-hinted implementations of the core algorithms from the paper.
"""
from typing import Callable, Optional
from dataclasses import dataclass


# Type aliases
CellState = bool
Config = list[CellState]
CARule = Callable[[CellState, CellState, CellState], CellState]


@dataclass
class TransfiniteCAResult:
    """Result of a transfinite CA computation."""
    history: list[Config]
    limit_config: Config
    stabilization_step: Optional[int]
    epochs_run: int


def apply_rule(rule: CARule, config: Config) -> Config:
    """Apply a 1D CA rule to a configuration with periodic boundary."""
    n = len(config)
    return [rule(config[(i-1) % n], config[i], config[(i+1) % n])
            for i in range(n)]


def rule110(left: CellState, center: CellState, right: CellState) -> CellState:
    """Elementary CA Rule 110 (Turing-complete)."""
    idx = (int(left) << 2) | (int(center) << 1) | int(right)
    return bool((110 >> idx) & 1)


def rule90(left: CellState, center: CellState, right: CellState) -> CellState:
    """Elementary CA Rule 90 (XOR rule, generates Sierpinski triangle)."""
    return left ^ right


def eventual_value_limit(history: list[Config]) -> Config:
    """
    Eventual-value limit rule for Boolean configurations.

    A cell is True at the limit if it is eventually always True.
    This corresponds to the ITTM (Infinite Time Turing Machine) limit rule.

    Algorithm:
        For each cell i:
            Find the latest time t where cell i is False.
            If such t exists and t < len(history) - 1, cell is True.
            Otherwise, cell takes the value at the last step.
    """
    if not history:
        return []
    n = len(history[0])
    result: Config = []
    for i in range(n):
        # Find if the cell is eventually always True
        last_false = -1
        for t in range(len(history)):
            if not history[t][i]:
                last_false = t
        # Eventually True if there's a point after which it's always True
        result.append(last_false < len(history) - 1 and
                      all(history[t][i] for t in range(last_false + 1, len(history))))
    return result


def limsup_limit(history: list[Config]) -> Config:
    """
    Limsup limit rule for Boolean configurations.

    A cell is True at the limit if it is True cofinally
    (appears True arbitrarily late in the sequence).

    Algorithm:
        For each cell i, check if True appears in the final portion.
    """
    if not history:
        return []
    n = len(history[0])
    tail_start = max(0, len(history) - len(history) // 3)
    return [any(history[t][i] for t in range(tail_start, len(history)))
            for i in range(n)]


def transfinite_ca(
    rule: CARule,
    init: Config,
    steps_per_epoch: int,
    num_epochs: int,
    limit_rule: Callable[[list[Config]], Config] = eventual_value_limit
) -> TransfiniteCAResult:
    """
    Simulate transfinite CA evolution.

    Runs the CA for `steps_per_epoch` steps (simulating ω steps),
    applies the limit rule, and repeats for `num_epochs` (simulating ω·n).

    This is a finite approximation to the ordinal computation:
    - Each epoch corresponds to an interval [ω·k, ω·(k+1))
    - The limit rule is applied at each ω·k

    Parameters:
        rule: The CA rule function
        init: Initial configuration
        steps_per_epoch: Number of steps per epoch (approximating ω)
        num_epochs: Number of epochs to run
        limit_rule: Function to compute the limit at each ω·k

    Returns:
        TransfiniteCAResult with full history and analysis
    """
    current = init
    full_history: list[Config] = [init]
    stabilization_step: Optional[int] = None

    for epoch in range(num_epochs):
        epoch_history = [current]
        for _ in range(steps_per_epoch):
            current = apply_rule(rule, current)
            epoch_history.append(current)

        # Apply limit rule at the limit ordinal
        current = limit_rule(epoch_history)
        full_history.extend(epoch_history[1:])
        full_history.append(current)

        # Check stabilization
        if stabilization_step is None and len(full_history) >= 2:
            if full_history[-1] == full_history[-2]:
                stabilization_step = len(full_history) - 2

    return TransfiniteCAResult(
        history=full_history,
        limit_config=current,
        stabilization_step=stabilization_step,
        epochs_run=num_epochs
    )


def find_stabilization(configs: list[Config]) -> Optional[int]:
    """Find the first step at which the configuration stabilizes."""
    for t in range(len(configs) - 1):
        if configs[t] == configs[t + 1]:
            return t
    return None


def ca_monotonicity_check(rule: CARule) -> bool:
    """
    Check if a CA rule is monotone.

    A rule is monotone if: whenever (a ≤ a', b ≤ b', c ≤ c'),
    we have rule(a,b,c) ≤ rule(a',b',c').

    For Boolean: False ≤ True. So monotonicity means
    setting inputs to True can only keep the output True.
    """
    for a in [False, True]:
        for b in [False, True]:
            for c in [False, True]:
                if rule(a, b, c):
                    # Check all (a', b', c') ≥ (a, b, c)
                    for a2 in ([a, True] if not a else [True]):
                        for b2 in ([b, True] if not b else [True]):
                            for c2 in ([c, True] if not c else [True]):
                                if not rule(a2, b2, c2):
                                    return False
    return True


def successor_count_sequence(bound: int, length: int) -> list[int]:
    """
    Generate the successor counting sequence.
    succCountBelow(bound, n) = min(n, bound)

    This sequence stabilizes at exactly step `bound`.
    """
    return [min(n, bound) for n in range(length)]


if __name__ == "__main__":
    # Example usage
    size = 20
    init = [False] * size
    init[size // 2] = True

    result = transfinite_ca(rule110, init, steps_per_epoch=30, num_epochs=5)
    print(f"Transfinite CA simulation:")
    print(f"  Epochs: {result.epochs_run}")
    print(f"  Total steps: {len(result.history)}")
    print(f"  Stabilization: {result.stabilization_step}")
    print(f"  Rule 110 is monotone: {ca_monotonicity_check(rule110)}")

    print(f"\nSuccessor counting (bound=5):")
    print(f"  {successor_count_sequence(5, 10)}")

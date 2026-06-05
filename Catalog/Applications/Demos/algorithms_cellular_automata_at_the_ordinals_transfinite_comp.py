#!/usr/bin/env python3
"""
Algorithms for Transfinite Cellular Automata

Type-hinted implementations of the key algorithms from the paper:
1. Rule 110 evolution
2. Transfinite evolution simulation
3. Kleene chain iteration
4. Orbit cycle detection
5. Energy stabilization detection
"""

from typing import Callable, TypeVar, Optional
from dataclasses import dataclass

T = TypeVar('T')


# ============================================================
# Algorithm 1: Elementary CA Evolution
# ============================================================

def rule110(left: bool, center: bool, right: bool) -> bool:
    """Rule 110 elementary cellular automaton.

    The rule number 110 in binary is 01101110, meaning:
      111→0, 110→1, 101→1, 100→0, 011→1, 010→1, 001→1, 000→0

    This is the simplest known Turing-complete CA rule.
    """
    index = (int(left) << 2) | (int(center) << 1) | int(right)
    return bool((110 >> index) & 1)


def step_config(
    rule: Callable[[bool, bool, bool], bool],
    config: list[bool]
) -> list[bool]:
    """Apply a local rule to evolve a configuration one step.

    Uses periodic boundary conditions.

    Pseudocode:
        FOR i = 0 TO len(config)-1:
            new[i] = rule(config[i-1], config[i], config[i+1])
        RETURN new
    """
    n = len(config)
    return [rule(config[(i - 1) % n], config[i], config[(i + 1) % n])
            for i in range(n)]


def standard_evolution(
    rule: Callable[[bool, bool, bool], bool],
    init: list[bool],
    steps: int
) -> list[list[bool]]:
    """Standard (ℕ-time) evolution of a cellular automaton.

    Returns the full spacetime history.

    Pseudocode:
        history[0] = init
        FOR t = 1 TO steps:
            history[t] = step_config(rule, history[t-1])
        RETURN history
    """
    history = [init]
    config = init
    for _ in range(steps):
        config = step_config(rule, config)
        history.append(config)
    return history


# ============================================================
# Algorithm 2: Transfinite Evolution Simulation
# ============================================================

@dataclass
class TransfiniteCA:
    """A transfinite cellular automaton.

    Attributes:
        rule: Local transition rule (left, center, right) → new_state
        limit_rule: Aggregation rule at limit ordinals
    """
    rule: Callable[[bool, bool, bool], bool]
    limit_rule: Callable[[list[list[bool]]], list[bool]]


def simulate_omega_evolution(
    ca: TransfiniteCA,
    init: list[bool],
    finite_steps: int,
) -> tuple[list[list[bool]], list[bool]]:
    """Simulate evolution up to ordinal ω.

    Runs finite_steps successor stages, then applies the limit rule
    to produce the configuration at stage ω.

    Pseudocode:
        history = standard_evolution(ca.rule, init, finite_steps)
        omega_config = ca.limit_rule(history)
        RETURN (history, omega_config)
    """
    history = standard_evolution(ca.rule, init, finite_steps)
    omega_config = ca.limit_rule(history)
    return history, omega_config


def simulate_omega_squared_evolution(
    ca: TransfiniteCA,
    init: list[bool],
    outer_steps: int,
    inner_steps: int,
) -> list[list[bool]]:
    """Simulate evolution up to ordinal ω².

    Performs outer_steps rounds of ω-evolution, each consisting of
    inner_steps successor stages followed by a limit aggregation.

    This gives two levels of transfinite computation.

    Pseudocode:
        config = init
        limit_configs = []
        FOR i = 0 TO outer_steps-1:
            history, omega_config = simulate_omega_evolution(ca, config, inner_steps)
            limit_configs.append(omega_config)
            config = omega_config
        RETURN limit_configs
    """
    config = init
    limit_configs = [init]
    for _ in range(outer_steps):
        _, omega_config = simulate_omega_evolution(ca, config, inner_steps)
        limit_configs.append(omega_config)
        config = omega_config
    return limit_configs


# ============================================================
# Algorithm 3: Kleene Chain Iteration
# ============================================================

def kleene_chain(
    f: Callable[[T], T],
    bottom: T,
    le: Callable[[T, T], bool],
    max_steps: int = 1000,
) -> tuple[T, int]:
    """Compute the least fixed point via Kleene chain iteration.

    Starting from ⊥, repeatedly applies f until a fixed point is reached.
    For monotone f on a complete lattice, this always terminates.

    Pseudocode:
        x = ⊥
        FOR step = 0 TO max_steps:
            fx = f(x)
            IF fx == x:
                RETURN (x, step)  // Fixed point found
            x = fx
        RETURN (x, max_steps)  // Should not happen for finite lattices

    Returns:
        (fixed_point, steps_to_converge)
    """
    x = bottom
    for step in range(max_steps):
        fx = f(x)
        if fx == x:
            return x, step
        x = fx
    return x, max_steps


# ============================================================
# Algorithm 4: Orbit Cycle Detection
# ============================================================

def detect_orbit_cycle(
    f: Callable[[T], T],
    start: T,
    max_steps: int = 10000,
) -> Optional[tuple[int, int]]:
    """Detect the eventual cycle in the orbit of start under f.

    Uses Floyd's tortoise-and-hare algorithm.
    By the orbit_eventually_cycles theorem, for finite state spaces
    this always finds a cycle with μ + λ ≤ |state_space|.

    Pseudocode:
        // Phase 1: Find meeting point
        slow = f(start); fast = f(f(start))
        WHILE slow ≠ fast:
            slow = f(slow); fast = f(f(fast))

        // Phase 2: Find cycle start (tail length μ)
        slow = start; μ = 0
        WHILE slow ≠ fast:
            slow = f(slow); fast = f(fast); μ++

        // Phase 3: Find cycle length λ
        fast = f(slow); λ = 1
        WHILE slow ≠ fast:
            fast = f(fast); λ++

        RETURN (μ, λ)

    Returns:
        (tail_length, cycle_length) or None if max_steps exceeded
    """
    slow = f(start)
    fast = f(f(start))
    steps = 0
    while slow != fast:
        slow = f(slow)
        fast = f(f(fast))
        steps += 1
        if steps > max_steps:
            return None

    # Find cycle start
    mu = 0
    slow = start
    while slow != fast:
        slow = f(slow)
        fast = f(fast)
        mu += 1

    # Find cycle length
    lam = 1
    fast = f(slow)
    while slow != fast:
        fast = f(fast)
        lam += 1

    return mu, lam


# ============================================================
# Algorithm 5: Energy Stabilization Detection
# ============================================================

def detect_energy_stabilization(
    energy: Callable[[int], int],
    max_steps: int = 1000,
    window: int = 10,
) -> tuple[bool, int]:
    """Detect when an antitone energy function stabilizes.

    By the energy_stabilization theorem, any antitone function
    E: Ordinal → Ordinal must eventually become constant.

    Pseudocode:
        FOR step = window TO max_steps:
            IF E(step) == E(step-1) == ... == E(step-window):
                RETURN (True, step - window)
        RETURN (False, max_steps)

    Returns:
        (stabilized, stabilization_step)
    """
    values = [energy(i) for i in range(min(window, max_steps))]

    for step in range(window, max_steps):
        values.append(energy(step))
        if all(v == values[-1] for v in values[-window:]):
            return True, step - window + 1
    return False, max_steps


# ============================================================
# Halting Detection (Limit Stage Capability)
# ============================================================

def halting_limit_rule(history: list[list[bool]]) -> list[bool]:
    """The halting-detection limit rule for ordinal CAs.

    At a limit ordinal stage, determines whether each cell has stabilized.
    Returns the stabilized value if it exists, False otherwise.

    This is the key capability that ordinal CAs gain over standard CAs:
    they can detect convergence of infinite computation histories.
    """
    if not history:
        return []

    width = len(history[0])
    result = []

    for cell in range(width):
        # Check if this cell has stabilized
        values = [h[cell] for h in history]
        # Look for eventual constancy
        stabilized = False
        stable_value = values[-1]
        for i in range(len(values) - 1, -1, -1):
            if values[i] != stable_value:
                stabilized = True
                break
        if not stabilized:
            # All values are the same
            result.append(stable_value)
        else:
            # Use the final value (eventual value)
            result.append(values[-1])

    return result


if __name__ == "__main__":
    print("=== Transfinite CA Algorithms ===")
    print()

    # Demo: Rule 110
    init = [False] * 40
    init[20] = True
    history = standard_evolution(rule110, init, 20)
    print("Rule 110 evolution (20 steps):")
    for row in history:
        print(''.join('█' if c else ' ' for c in row))
    print()

    # Demo: Kleene chain
    def f_lattice(x: int) -> int:
        return min(x + 1, 5)

    fp, steps = kleene_chain(f_lattice, 0, lambda a, b: a <= b)
    print(f"Kleene chain: f(x) = min(x+1, 5)")
    print(f"  Fixed point: {fp} (reached in {steps} steps)")
    print()

    # Demo: Orbit detection
    def f_orbit(x: int) -> int:
        return (x * 3 + 1) % 7

    result = detect_orbit_cycle(f_orbit, 1)
    if result:
        mu, lam = result
        print(f"Orbit of 1 under f(x) = 3x+1 mod 7:")
        print(f"  Tail length: {mu}, Cycle length: {lam}")
    print()

    # Demo: ω²-evolution
    ca = TransfiniteCA(rule=rule110, limit_rule=halting_limit_rule)
    limit_configs = simulate_omega_squared_evolution(ca, init, 5, 50)
    print(f"ω² simulation: {len(limit_configs)} limit stages computed")
    for i, cfg in enumerate(limit_configs):
        active = sum(cfg)
        print(f"  Stage ω·{i}: {active} active cells")

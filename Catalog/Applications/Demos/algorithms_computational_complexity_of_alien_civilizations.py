#!/usr/bin/env python3
"""
Algorithms for Universal Computational Complexity Barriers.

Type-hinted implementations of the core mathematical constructions:
oracle tower, diagonal construction, barrier generation, and
substrate equivalence checking.
"""

from typing import Callable, Dict, List, Optional, Tuple
from dataclasses import dataclass


# =============================================================================
# Core Types
# =============================================================================

Lang = Callable[[int], bool]
Enumeration = Callable[[int], Lang]


@dataclass
class ComputationalBarrier:
    """A computational barrier: an enumerable class with a provably hard problem."""
    easy_enum: Enumeration
    hard_problem: Lang
    # The separation proof is implicit in the construction


@dataclass
class Simulation:
    """A simulation from one computation model to another."""
    translate: Callable[[int], int]
    # Correctness: target(translate(k)) == source(k) for all k


@dataclass
class SubstrateEquivalence:
    """Two models that can mutually simulate each other."""
    forward: Simulation
    backward: Simulation


# =============================================================================
# Algorithm 1: Diagonal Construction
# =============================================================================

def diagonal(enum: Enumeration) -> Lang:
    """
    Construct the diagonal language of an enumeration.

    Given an enumeration f, returns diag(f) where diag(f)(n) = not f(n)(n).
    This is the universal barrier generator.

    Time: O(1) per query (plus cost of evaluating f)
    Space: O(1)
    """
    def diag_lang(n: int) -> bool:
        return not enum(n)(n)
    return diag_lang


# =============================================================================
# Algorithm 2: Oracle Tower Construction
# =============================================================================

def build_oracle_tower_lazy(level: int) -> Enumeration:
    """
    Build an oracle tower level lazily (without precomputation).

    Level 0: all programs return False
    Level n+1: program 0 = diag(level n), program k+1 = level n program k

    Time per query: O(level) recursive calls
    Space: O(level) stack frames
    """
    if level == 0:
        def level_0(k: int) -> Lang:
            return lambda n: False
        return level_0
    else:
        prev = build_oracle_tower_lazy(level - 1)
        diag_prev = diagonal(prev)

        def next_level(k: int) -> Lang:
            if k == 0:
                return diag_prev
            else:
                return prev(k - 1)
        return next_level


def build_oracle_tower_table(max_level: int, max_programs: int,
                              max_inputs: int) -> Dict[int, Dict[int, List[bool]]]:
    """
    Build an oracle tower as an explicit table.

    Returns tower[level][program] = [values for inputs 0..max_inputs-1]

    Time: O(max_level * max_programs * max_inputs)
    Space: O(max_level * max_programs * max_inputs)
    """
    tower: Dict[int, Dict[int, List[bool]]] = {}

    # Level 0
    tower[0] = {k: [False] * max_inputs for k in range(max_programs)}

    # Higher levels
    for lev in range(1, max_level + 1):
        tower[lev] = {}
        prev = tower[lev - 1]

        # Program 0: diagonal of previous level
        diag_vals = []
        for n in range(max_inputs):
            if n < max_programs and n in prev:
                diag_vals.append(not prev[n][n])
            else:
                diag_vals.append(True)
        tower[lev][0] = diag_vals

        # Programs 1..max_programs-1: shifted from previous level
        for k in range(1, max_programs):
            if k - 1 in prev:
                tower[lev][k] = prev[k - 1][:]
            else:
                tower[lev][k] = [False] * max_inputs

    return tower


# =============================================================================
# Algorithm 3: Canonical Barrier Generation
# =============================================================================

def canonical_barrier(enum: Enumeration) -> ComputationalBarrier:
    """
    Generate the canonical computational barrier for an enumeration.

    The hard problem is the diagonal of the enumeration.
    By the diagonal separation theorem, it is provably outside
    the enumerated class.

    Time: O(1) construction
    """
    return ComputationalBarrier(
        easy_enum=enum,
        hard_problem=diagonal(enum)
    )


def oracle_tower_barrier(level: int) -> ComputationalBarrier:
    """Generate the canonical barrier at a given oracle tower level."""
    enum = build_oracle_tower_lazy(level)
    return canonical_barrier(enum)


# =============================================================================
# Algorithm 4: Interleaving
# =============================================================================

def interleave(f: Enumeration, g: Enumeration) -> Enumeration:
    """
    Interleave two enumerations into a single combined enumeration.

    Even indices map to f, odd indices map to g.

    Time: O(1) per query (plus cost of f or g)
    """
    def combined(k: int) -> Lang:
        if k % 2 == 0:
            return f(k // 2)
        else:
            return g(k // 2)
    return combined


# =============================================================================
# Algorithm 5: Simulation Composition
# =============================================================================

def compose_simulations(sim12: Simulation, sim23: Simulation) -> Simulation:
    """
    Compose two simulations: if S2 simulates S1 and S3 simulates S2,
    then S3 simulates S1.

    Time: O(1) per translation (plus costs of individual translations)
    """
    return Simulation(
        translate=lambda k: sim23.translate(sim12.translate(k))
    )


# =============================================================================
# Algorithm 6: Barrier Verification
# =============================================================================

def verify_separation(enum: Enumeration, candidate: Lang,
                       max_programs: int, max_inputs: int) -> bool:
    """
    Verify that a candidate language differs from every enumerated language
    on at least one input in the test range.

    Time: O(max_programs * max_inputs)
    """
    for k in range(max_programs):
        prog_k = enum(k)
        found_diff = False
        for n in range(max_inputs):
            if prog_k(n) != candidate(n):
                found_diff = True
                break
        if not found_diff:
            return False  # prog_k agrees with candidate on all tested inputs
    return True


def verify_hierarchy_strict(tower_table: Dict[int, Dict[int, List[bool]]],
                             level: int, max_inputs: int) -> Tuple[bool, str]:
    """
    Verify that level n+1 strictly extends level n.

    Returns (success, message).
    """
    if level + 1 not in tower_table:
        return (False, "Level n+1 not built")

    # Compute diagonal of level n
    diag_n = []
    for n in range(max_inputs):
        if n in tower_table[level]:
            diag_n.append(not tower_table[level][n][n])
        else:
            diag_n.append(True)

    # Check program 0 at level n+1 equals diag of level n
    if tower_table[level + 1][0][:max_inputs] != diag_n[:max_inputs]:
        return (False, "Program 0 at level n+1 ≠ diag(level n)")

    # Check no program at level n equals diag of level n
    for k in tower_table[level]:
        if tower_table[level][k][:max_inputs] == diag_n[:max_inputs]:
            return (False, f"Program {k} at level n matches diagonal")

    return (True, "Hierarchy is strict")


# =============================================================================
# Main: Run all algorithms as a demonstration
# =============================================================================

def main() -> None:
    MAX_LEVEL = 6
    MAX_PROGS = 10
    MAX_INPUT = 10

    print("Building oracle tower (table form)...")
    tower = build_oracle_tower_table(MAX_LEVEL, MAX_PROGS, MAX_INPUT)

    print("\nOracle Tower Barriers:")
    for level in range(MAX_LEVEL + 1):
        barrier = oracle_tower_barrier(level)
        # Test barrier on small inputs
        hard_vals = [barrier.hard_problem(n) for n in range(8)]
        print(f"  Level {level} barrier: {['1' if v else '0' for v in hard_vals]}")

    print("\nHierarchy strictness verification:")
    for level in range(MAX_LEVEL):
        success, msg = verify_hierarchy_strict(tower, level, MAX_INPUT)
        print(f"  Level {level} → {level+1}: {'✓' if success else '✗'} ({msg})")

    print("\nInterleaving test:")
    enum_a = build_oracle_tower_lazy(0)
    enum_b = build_oracle_tower_lazy(1)
    combined = interleave(enum_a, enum_b)
    combined_barrier = canonical_barrier(combined)
    hard_vals = [combined_barrier.hard_problem(n) for n in range(8)]
    print(f"  Combined barrier: {['1' if v else '0' for v in hard_vals]}")

    # Verify the combined barrier escapes both original enumerations
    escapes_a = verify_separation(enum_a, combined_barrier.hard_problem, MAX_PROGS, MAX_INPUT)
    escapes_b = verify_separation(enum_b, combined_barrier.hard_problem, MAX_PROGS, MAX_INPUT)
    print(f"  Escapes enumeration A: {'✓' if escapes_a else '✗'}")
    print(f"  Escapes enumeration B: {'✓' if escapes_b else '✗'}")

    print("\nSimulation composition:")
    # Identity simulations compose to identity
    sim1 = Simulation(translate=lambda k: k)
    sim2 = Simulation(translate=lambda k: k + 1)
    composed = compose_simulations(sim1, sim2)
    print(f"  translate(0) = {composed.translate(0)}")
    print(f"  translate(5) = {composed.translate(5)}")

    print("\nAll algorithms executed successfully.")


if __name__ == "__main__":
    main()

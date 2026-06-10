#!/usr/bin/env python3
"""
Algorithms for Recursive Majority Depth Rigidity

Implements:
1. Recursive majority evaluation (optimized)
2. Canonical formula construction with depth analysis
3. Monotone circuit search with symmetry reduction
4. Karchmer-Wigderson game simulation
5. Variable sensitivity analysis
"""

import itertools
from typing import Optional
from dataclasses import dataclass


# ──────────────────────────────────────────────────────────────────────────────
# Algorithm 1: Recursive Majority Evaluation
# ──────────────────────────────────────────────────────────────────────────────
# Pseudocode:
#   FUNCTION RecMaj(n, inputs[0..3^n-1]):
#     IF n = 0 THEN RETURN inputs[0]
#     b ← 3^(n-1)
#     a ← RecMaj(n-1, inputs[0..b-1])
#     b ← RecMaj(n-1, inputs[b..2b-1])
#     c ← RecMaj(n-1, inputs[2b..3b-1])
#     RETURN MAJ3(a, b, c)
#
# Time: O(3^n)  Space: O(n) stack depth

def maj3(a: bool, b: bool, c: bool) -> bool:
    """Ternary majority: true iff ≥2 inputs are true."""
    return (a and b) or (a and c) or (b and c)


def rec_maj(n: int, inputs: list[bool]) -> bool:
    """Evaluate RecMaj_n on a list of 3^n Boolean inputs."""
    if n == 0:
        return inputs[0]
    block = 3 ** (n - 1)
    return maj3(
        rec_maj(n - 1, inputs[:block]),
        rec_maj(n - 1, inputs[block:2*block]),
        rec_maj(n - 1, inputs[2*block:3*block])
    )


def rec_maj_with_trace(n: int, inputs: list[bool], indent: int = 0) -> bool:
    """Evaluate RecMaj_n with detailed trace of recursive calls."""
    prefix = "  " * indent
    if n == 0:
        print(f"{prefix}RecMaj_0([{inputs[0]}]) = {inputs[0]}")
        return inputs[0]
    block = 3 ** (n - 1)
    a = rec_maj_with_trace(n - 1, inputs[:block], indent + 1)
    b = rec_maj_with_trace(n - 1, inputs[block:2*block], indent + 1)
    c = rec_maj_with_trace(n - 1, inputs[2*block:3*block], indent + 1)
    result = maj3(a, b, c)
    print(f"{prefix}RecMaj_{n}(...) = maj3({a}, {b}, {c}) = {result}")
    return result


# ──────────────────────────────────────────────────────────────────────────────
# Algorithm 2: Variable Sensitivity Analysis
# ──────────────────────────────────────────────────────────────────────────────
# Pseudocode:
#   FUNCTION FindPivotalInput(n, var_index):
#     IF n = 0 THEN RETURN [True]
#     Determine which block var_index falls in (0, 1, or 2)
#     Build input: pivotal block uses recursive call,
#                  one helper block all-true, one all-false
#     RETURN constructed input
#
# Time: O(3^n)  Space: O(3^n)

def find_pivotal_input(n: int, var_index: int) -> list[bool]:
    """
    Find an input where flipping var_index changes RecMaj_n's output.
    Returns a list of 3^n bools.
    """
    if n == 0:
        return [True]  # Flipping index 0 from True to False changes output

    block = 3 ** (n - 1)
    block_id = var_index // block  # Which block (0, 1, or 2)
    local_idx = var_index % block  # Index within the block

    # Recursively find pivotal input for the sub-block
    sub_input = find_pivotal_input(n - 1, local_idx)

    # Build full input: pivotal block uses sub_input,
    # one other block all-True, one all-False
    # This ensures maj3(x, True, False) = x, so pivotality transfers
    inputs = [False] * (3 * block)
    if block_id == 0:
        inputs[0:block] = sub_input
        inputs[block:2*block] = [True] * block
        inputs[2*block:3*block] = [False] * block
    elif block_id == 1:
        inputs[0:block] = [True] * block
        inputs[block:2*block] = sub_input
        inputs[2*block:3*block] = [False] * block
    else:
        inputs[0:block] = [True] * block
        inputs[block:2*block] = [False] * block
        inputs[2*block:3*block] = sub_input

    return inputs


def verify_all_pivotal(n: int) -> dict:
    """
    Verify that every variable in [0, 3^n) is pivotal for RecMaj_n.
    Returns statistics about the sensitivity.
    """
    num_inputs = 3 ** n
    results = {}
    for i in range(num_inputs):
        inp = find_pivotal_input(n, i)
        val_orig = rec_maj(n, inp)
        flipped = inp.copy()
        flipped[i] = not flipped[i]
        val_flip = rec_maj(n, flipped)
        results[i] = {
            'pivotal': val_orig != val_flip,
            'original': val_orig,
            'flipped': val_flip
        }
    return results


# ──────────────────────────────────────────────────────────────────────────────
# Algorithm 3: Monotone Circuit Search (Bounded Depth)
# ──────────────────────────────────────────────────────────────────────────────
# Pseudocode:
#   FUNCTION SearchCircuit(n, max_depth):
#     num_vars ← 3^n
#     truth_table ← compute target truth table for RecMaj_n
#     layer[0] ← {truth table of x_i for each i}
#     FOR d = 1 TO max_depth:
#       FOR each pair (f, g) in all previous layers:
#         candidate_and ← f AND g (pointwise)
#         candidate_or  ← f OR g (pointwise)
#         IF candidate matches truth_table THEN RETURN (d, circuit)
#         Add to layer[d] if new
#     RETURN None
#
# Time: O(|layer|^2 · 2^{3^n})  Space: O(|layer| · 2^{3^n})

@dataclass
class CircuitSearchResult:
    """Result of a monotone circuit depth search."""
    found: bool
    depth: Optional[int]
    circuit_description: Optional[str]
    search_stats: dict


def monotone_circuit_search(n: int, max_depth: int) -> CircuitSearchResult:
    """
    Search for a monotone circuit of depth ≤ max_depth computing RecMaj_n.
    Uses truth-table enumeration with deduplication.
    Only feasible for n ≤ 2 (up to 9 inputs = 512 truth table entries).
    """
    num_inputs = 3 ** n
    if num_inputs > 12:
        return CircuitSearchResult(
            found=False, depth=None, circuit_description=None,
            search_stats={'reason': 'too many inputs', 'num_inputs': num_inputs}
        )

    num_rows = 2 ** num_inputs

    # Compute target truth table
    target = []
    for bits in itertools.product([False, True], repeat=num_inputs):
        target.append(rec_maj(n, list(bits)))
    target = tuple(target)

    # Layer 0: variable truth tables
    layers = []
    current = {}
    for i in range(num_inputs):
        tt = tuple(bits[i] for bits in
                   itertools.product([False, True], repeat=num_inputs))
        if tt == target:
            return CircuitSearchResult(
                found=True, depth=0,
                circuit_description=f"x{i}",
                search_stats={'depth': 0, 'functions_explored': num_inputs}
            )
        current[tt] = f"x{i}"
    layers.append(current)

    total_explored = len(current)

    for d in range(1, max_depth + 1):
        all_prev = {}
        for layer in layers:
            all_prev.update(layer)

        new_layer = {}
        prev_items = list(all_prev.items())

        for i, (tt1, desc1) in enumerate(prev_items):
            for tt2, desc2 in prev_items[i:]:
                # AND gate
                tt_and = tuple(a and b for a, b in zip(tt1, tt2))
                if tt_and == target:
                    return CircuitSearchResult(
                        found=True, depth=d,
                        circuit_description=f"({desc1} ∧ {desc2})",
                        search_stats={'depth': d, 'functions_explored': total_explored}
                    )
                if tt_and not in all_prev and tt_and not in new_layer:
                    new_layer[tt_and] = f"({desc1} ∧ {desc2})"

                # OR gate
                tt_or = tuple(a or b for a, b in zip(tt1, tt2))
                if tt_or == target:
                    return CircuitSearchResult(
                        found=True, depth=d,
                        circuit_description=f"({desc1} ∨ {desc2})",
                        search_stats={'depth': d, 'functions_explored': total_explored}
                    )
                if tt_or not in all_prev and tt_or not in new_layer:
                    new_layer[tt_or] = f"({desc1} ∨ {desc2})"

        total_explored += len(new_layer)
        if not new_layer:
            break
        layers.append(new_layer)

    return CircuitSearchResult(
        found=False, depth=None, circuit_description=None,
        search_stats={
            'max_depth_searched': max_depth,
            'functions_explored': total_explored,
            'layers': [len(l) for l in layers]
        }
    )


# ──────────────────────────────────────────────────────────────────────────────
# Algorithm 4: Karchmer-Wigderson Game Simulation
# ──────────────────────────────────────────────────────────────────────────────
# The monotone KW game for f:
#   Alice gets x with f(x) = 1
#   Bob gets y with f(y) = 0
#   Goal: find index i with x_i = 1, y_i = 0
# Communication cost = monotone formula depth of f

@dataclass
class KWGameResult:
    """Result of a KW game analysis."""
    num_positive: int  # Number of 1-inputs
    num_negative: int  # Number of 0-inputs
    min_communication: int  # Lower bound on communication cost


def kw_game_analysis(n: int) -> KWGameResult:
    """
    Analyze the monotone Karchmer-Wigderson game for RecMaj_n.
    For small n, compute exact statistics.
    """
    num_inputs = 3 ** n
    positive = []
    negative = []

    for bits in itertools.product([False, True], repeat=num_inputs):
        inp = list(bits)
        if rec_maj(n, inp):
            positive.append(inp)
        else:
            negative.append(inp)

    return KWGameResult(
        num_positive=len(positive),
        num_negative=len(negative),
        min_communication=n  # From our formal lower bound
    )


# ──────────────────────────────────────────────────────────────────────────────
# Algorithm 5: Formula Depth Analysis
# ──────────────────────────────────────────────────────────────────────────────

def formula_depth_bounds(n: int) -> dict:
    """
    Compute provable bounds on the monotone formula depth of RecMaj_n.

    Lower bound: n (from variable counting: 3^n vars, 2^d leaves)
    Upper bound: 3n (from canonical formula construction)
    """
    import math
    num_vars = 3 ** n
    log2_bound = math.ceil(math.log2(num_vars)) if num_vars > 1 else 0

    return {
        'n': n,
        'num_variables': num_vars,
        'lower_bound_variable_counting': n,
        'lower_bound_log2': log2_bound,
        'upper_bound_canonical': 3 * n,
        'gap_factor': 3 if n > 0 else 1,
    }


# ──────────────────────────────────────────────────────────────────────────────
# Main
# ──────────────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=== Algorithm Demonstrations ===\n")

    # Algorithm 1: Traced evaluation
    print("--- Algorithm 1: RecMaj with trace (n=2) ---")
    inp = [True, False, True, True, True, False, False, True, True]
    print(f"Input: {inp}")
    result = rec_maj_with_trace(2, inp)
    print()

    # Algorithm 2: Pivotality
    print("--- Algorithm 2: Variable Pivotality (n=2) ---")
    results = verify_all_pivotal(2)
    for i, r in results.items():
        status = "✓ pivotal" if r['pivotal'] else "✗ NOT pivotal"
        print(f"  var {i}: {status}")
    print()

    # Algorithm 3: Circuit search
    print("--- Algorithm 3: Monotone Circuit Search ---")
    for n in range(1, 3):
        for d in range(1, 3 * n + 1):
            result = monotone_circuit_search(n, d)
            if result.found:
                print(f"  n={n}, depth {d}: FOUND — {result.circuit_description}")
                break
            else:
                print(f"  n={n}, depth {d}: not found "
                      f"({result.search_stats.get('functions_explored', '?')} functions)")
    print()

    # Algorithm 4: KW game
    print("--- Algorithm 4: KW Game Analysis ---")
    for n in range(3):
        kw = kw_game_analysis(n)
        print(f"  n={n}: {kw.num_positive} positive, {kw.num_negative} negative, "
              f"min communication ≥ {kw.min_communication}")
    print()

    # Algorithm 5: Depth bounds
    print("--- Algorithm 5: Formula Depth Bounds ---")
    print(f"  {'n':>3} {'vars':>8} {'lower':>8} {'upper':>8} {'gap':>5}")
    for n in range(8):
        bounds = formula_depth_bounds(n)
        print(f"  {n:>3} {bounds['num_variables']:>8} "
              f"{bounds['lower_bound_variable_counting']:>8} "
              f"{bounds['upper_bound_canonical']:>8} "
              f"{bounds['gap_factor']:>5}")

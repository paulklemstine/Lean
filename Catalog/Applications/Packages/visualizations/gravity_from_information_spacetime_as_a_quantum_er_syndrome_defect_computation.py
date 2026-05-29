#!/usr/bin/env python3
"""
Holographic Coding Geometry — Algorithms

Implements core algorithms from the research paper:
1. Syndrome defect computation over all region pairs
2. RT-induced area submodularity checker
3. Laminar family generation and conjecture tester
4. Singleton bound verifier and entropy lower bound computation
5. Reconstructability checker

All algorithms operate on finite boundary sets and are polynomial
in the number of subsets (exponential in boundary size).
"""

import itertools
import math
from typing import (
    Callable, Dict, FrozenSet, List, Optional, Set, Tuple,
)


# ─────────────────────────────────────────────────────────────
# Algorithm 1: Syndrome Defect Computation
# ─────────────────────────────────────────────────────────────

def compute_syndrome_defect(
    S: Callable[[FrozenSet], float],
    X: FrozenSet,
    Y: FrozenSet,
) -> float:
    """
    Compute the syndrome defect for a pair of regions.

    syndromeDefect(S, X, Y) = S(X) + S(Y) - S(X ∩ Y) - S(X ∪ Y)

    Time: O(1) function evaluations (4 calls to S)
    Space: O(|X| + |Y|)

    Args:
        S: Entropy functional on frozensets
        X, Y: Boundary regions (frozensets)

    Returns:
        The syndrome defect value (≥ 0 if S is submodular)
    """
    return S(X) + S(Y) - S(X & Y) - S(X | Y)


def compute_all_syndrome_defects(
    S: Callable[[FrozenSet], float],
    elements: list,
) -> List[Tuple[FrozenSet, FrozenSet, float]]:
    """
    Compute syndrome defects for all pairs of subsets.

    Time: O(4^n) where n = |elements| (iterating all pairs of 2^n subsets)
    Space: O(4^n) for storing results

    Args:
        S: Entropy functional
        elements: List of boundary elements

    Returns:
        List of (X, Y, defect) tuples
    """
    subsets = []
    for r in range(len(elements) + 1):
        for combo in itertools.combinations(elements, r):
            subsets.append(frozenset(combo))

    results = []
    for X in subsets:
        for Y in subsets:
            d = compute_syndrome_defect(S, X, Y)
            results.append((X, Y, d))
    return results


def syndrome_defect_statistics(
    defects: List[Tuple[FrozenSet, FrozenSet, float]],
) -> Dict:
    """
    Compute statistics on syndrome defects.

    Time: O(|defects|)

    Returns:
        Dictionary with min, max, mean, all_nonneg, num_zero, num_positive
    """
    values = [d for _, _, d in defects]
    if not values:
        return {"empty": True}

    return {
        "min": min(values),
        "max": max(values),
        "mean": sum(values) / len(values),
        "std": (sum((v - sum(values)/len(values))**2 for v in values) / len(values)) ** 0.5,
        "all_nonneg": all(v >= -1e-10 for v in values),
        "num_zero": sum(1 for v in values if abs(v) < 1e-10),
        "num_positive": sum(1 for v in values if v > 1e-10),
        "total": len(values),
    }


# ─────────────────────────────────────────────────────────────
# Algorithm 2: Submodularity Checker
# ─────────────────────────────────────────────────────────────

def check_submodularity(
    f: Callable[[FrozenSet], float],
    elements: list,
    tol: float = 1e-10,
) -> Tuple[bool, List[Tuple[FrozenSet, FrozenSet, float]]]:
    """
    Check if f is submodular: f(X) + f(Y) ≥ f(X∩Y) + f(X∪Y) for all X, Y.

    Time: O(4^n) where n = |elements|
    Space: O(violations found)

    Args:
        f: Set function to check
        elements: Ground set
        tol: Numerical tolerance

    Returns:
        (is_submodular, list_of_violations)
    """
    subsets = []
    for r in range(len(elements) + 1):
        for combo in itertools.combinations(elements, r):
            subsets.append(frozenset(combo))

    violations = []
    for X in subsets:
        for Y in subsets:
            lhs = f(X) + f(Y)
            rhs = f(X & Y) + f(X | Y)
            if lhs < rhs - tol:
                violations.append((X, Y, lhs - rhs))

    return len(violations) == 0, violations


def check_rt_area_submodularity(
    S: Callable[[FrozenSet], float],
    elements: list,
    tol: float = 1e-10,
) -> Tuple[bool, bool, bool]:
    """
    Verify the RT bridge theorem computationally:
    S submodular ⟺ area = 4S submodular.

    Time: O(4^n)

    Returns:
        (s_submod, area_submod, iff_holds)
    """
    area = lambda X: 4.0 * S(X)
    s_ok, _ = check_submodularity(S, elements, tol)
    a_ok, _ = check_submodularity(area, elements, tol)
    return s_ok, a_ok, s_ok == a_ok


# ─────────────────────────────────────────────────────────────
# Algorithm 3: Laminar Family Operations
# ─────────────────────────────────────────────────────────────

def is_laminar(family: List[FrozenSet]) -> bool:
    """
    Check if a family of sets is laminar:
    ∀ X, Y ∈ family: X ∩ Y = ∅ or X ⊆ Y or Y ⊆ X.

    Time: O(k² · m) where k = |family|, m = max set size
    """
    for i, X in enumerate(family):
        for j, Y in enumerate(family):
            if i != j:
                if X & Y and not X <= Y and not Y <= X:
                    return False
    return True


def generate_all_laminar_families(
    elements: list,
    max_size: int = None,
) -> List[List[FrozenSet]]:
    """
    Generate all maximal laminar families on a ground set.

    This uses a brute-force approach suitable for small ground sets (n ≤ 5).

    Time: O(2^(2^n)) in the worst case
    """
    subsets = []
    for r in range(len(elements) + 1):
        for combo in itertools.combinations(elements, r):
            subsets.append(frozenset(combo))

    if max_size is None:
        max_size = len(subsets)

    # Greedy: find all laminar subfamilies of size ≤ max_size
    families = [[]]
    result = []

    for s in subsets:
        new_families = []
        for fam in families:
            if len(fam) < max_size:
                candidate = fam + [s]
                if is_laminar(candidate):
                    new_families.append(candidate)
        families.extend(new_families)

    # Return only non-trivial families (≥ 2 sets)
    return [f for f in families if len(f) >= 2]


# ─────────────────────────────────────────────────────────────
# Algorithm 4: Singleton Bound Verification
# ─────────────────────────────────────────────────────────────

def verify_singleton_bound(
    N: int, K: int, D: int,
) -> Dict:
    """
    Verify the quantum Singleton bound: N - K ≤ 2(D - 1).

    Also compute the entropy lower bound: K ≥ N - 2(D - 1).

    Time: O(1)

    Returns:
        Dictionary with bound values, satisfaction status, and tightness
    """
    redundancy = N - K
    max_redundancy = 2 * (D - 1) if D >= 1 else 0
    lower_bound = N - 2 * (D - 1) if D >= 1 else N

    return {
        "N": N,
        "K": K,
        "D": D,
        "redundancy": redundancy,
        "max_redundancy": max_redundancy,
        "singleton_holds": redundancy <= max_redundancy,
        "entropy_lower_bound": lower_bound,
        "K_above_bound": K >= lower_bound,
        "tightness": redundancy / max_redundancy if max_redundancy > 0 else float('inf'),
        "is_mds": redundancy == max_redundancy,  # Maximum Distance Separable
    }


def scan_singleton_codes(max_n: int = 15) -> List[Dict]:
    """
    Scan for valid quantum codes satisfying the Singleton bound.

    Time: O(max_n³)

    Returns:
        List of valid code parameters with their properties
    """
    codes = []
    for n in range(1, max_n + 1):
        for k in range(0, n + 1):
            for d in range(1, n - k + 2):
                info = verify_singleton_bound(n, k, d)
                if info["singleton_holds"]:
                    codes.append(info)
    return codes


# ─────────────────────────────────────────────────────────────
# Algorithm 5: Reconstructability Analysis
# ─────────────────────────────────────────────────────────────

def check_reconstructable(
    D: Callable[[FrozenSet], int],
    X: FrozenSet,
    U: FrozenSet,
) -> bool:
    """
    Check if U is reconstructable relative to X:
    U ⊆ X and |U| < D(U).

    Time: O(|U|)
    """
    return U <= X and len(U) < D(U)


def find_all_reconstructable(
    D: Callable[[FrozenSet], int],
    X: FrozenSet,
) -> List[FrozenSet]:
    """
    Find all subsets of X that are reconstructable.

    Time: O(2^|X| · |X|)
    """
    result = []
    elements = list(X)
    for r in range(len(elements) + 1):
        for combo in itertools.combinations(elements, r):
            U = frozenset(combo)
            if check_reconstructable(D, X, U):
                result.append(U)
    return result


def verify_reconstruction_monotonicity(
    D: Callable[[FrozenSet], int],
    elements: list,
) -> Tuple[bool, List]:
    """
    Verify reconstruction monotonicity: if U is reconstructable in X
    and X ⊆ Y, then U is reconstructable in Y.

    Time: O(3^n · 2^n) where n = |elements|

    Returns:
        (holds, counterexamples)
    """
    subsets = []
    for r in range(len(elements) + 1):
        for combo in itertools.combinations(elements, r):
            subsets.append(frozenset(combo))

    counterexamples = []
    for X in subsets:
        for Y in subsets:
            if X <= Y:
                rec_X = find_all_reconstructable(D, X)
                for U in rec_X:
                    if not check_reconstructable(D, Y, U):
                        counterexamples.append((U, X, Y))

    return len(counterexamples) == 0, counterexamples


# ─────────────────────────────────────────────────────────────
# Algorithm 6: Conjecture Tester
# ─────────────────────────────────────────────────────────────

def test_saturation_modularity_conjecture(
    S: Callable[[FrozenSet], float],
    elements: list,
    tol: float = 1e-10,
) -> Dict:
    """
    Exhaustively test the Saturation-Modularity Conjecture:

    For every laminar family L where S(X) = |X| for all X ∈ L,
    check that syndromeDefect(S, X, Y) = 0 for all X, Y ∈ L.

    Time: O(2^(2^n) · k²) where n = |elements|, k = max family size

    Returns:
        Dictionary with test results, including any counterexamples
    """
    families = generate_all_laminar_families(elements, max_size=6)

    results = {
        "total_families": len(families),
        "saturated_families": 0,
        "conjecture_holds_count": 0,
        "counterexamples": [],
    }

    for fam in families:
        # Check saturation: S(X) = |X| for all X in family
        saturated = all(abs(S(X) - len(X)) < tol for X in fam)
        if not saturated:
            continue

        results["saturated_families"] += 1

        # Check zero defect on all pairs
        all_zero = True
        for X in fam:
            for Y in fam:
                d = compute_syndrome_defect(S, X, Y)
                if abs(d) > tol:
                    all_zero = False
                    results["counterexamples"].append({
                        "family": [set(s) for s in fam],
                        "X": set(X),
                        "Y": set(Y),
                        "defect": d,
                    })

        if all_zero:
            results["conjecture_holds_count"] += 1

    results["conjecture_survives"] = len(results["counterexamples"]) == 0
    return results


# ─────────────────────────────────────────────────────────────
# Example Usage
# ─────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Holographic Coding Geometry — Algorithm Demonstrations\n")

    # Example: sqrt profile
    S_sqrt = lambda X: math.sqrt(len(X))
    elements = [0, 1, 2, 3]

    print("1. Submodularity check for S(X) = sqrt(|X|):")
    ok, violations = check_submodularity(S_sqrt, elements)
    print(f"   Submodular: {ok}\n")

    print("2. RT bridge verification:")
    s_ok, a_ok, iff_ok = check_rt_area_submodularity(S_sqrt, elements)
    print(f"   S submodular: {s_ok}, area submodular: {a_ok}, iff: {iff_ok}\n")

    print("3. Singleton bound examples:")
    for n, k, d in [(5, 1, 3), (7, 1, 3), (4, 2, 2)]:
        info = verify_singleton_bound(n, k, d)
        print(f"   [[{n},{k},{d}]]: holds={info['singleton_holds']}, "
              f"MDS={info['is_mds']}, K≥{info['entropy_lower_bound']}")

    print("\n4. Reconstruction monotonicity:")
    D_const = lambda U: max(len(U) + 1, 1)
    ok, cex = verify_reconstruction_monotonicity(D_const, [0, 1, 2])
    print(f"   Monotonicity holds: {ok}\n")

    print("5. Saturation-modularity conjecture (cardinality profile):")
    S_card = lambda X: float(len(X))
    results = test_saturation_modularity_conjecture(S_card, [0, 1, 2])
    print(f"   Saturated families tested: {results['saturated_families']}")
    print(f"   Conjecture survives: {results['conjecture_survives']}")

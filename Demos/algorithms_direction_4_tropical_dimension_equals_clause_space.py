#!/usr/bin/env python3
"""
Algorithms for Tropical Clause Space
======================================

Implements the core algorithms for computing tropical dimension,
clause load, and related invariants of clause configuration systems.

All algorithms operate on finite monotone clause families and
finite configuration sets.
"""

from itertools import combinations
from typing import FrozenSet, Set, List, Tuple, Optional, Dict
from dataclasses import dataclass


# ============================================================================
# Data Structures
# ============================================================================

Literal = int  # Positive integer for positive literal
Clause = FrozenSet[Literal]
Configuration = FrozenSet[Clause]


@dataclass
class TropicalProfile:
    """The tropical profile of a configuration relative to a formula."""
    config: Configuration
    embedding: Tuple[int, ...]
    clause_load: int
    support_size: int


@dataclass
class DimensionReport:
    """Report on tropical dimension computation."""
    tropical_dim: int
    max_clause_load: int
    support_separated: bool
    load_saturated: bool
    equality_holds: bool
    varying_clauses: Set[Clause]
    ever_active: Set[Clause]
    always_active: Set[Clause]


# ============================================================================
# Algorithm 1: Tropical Embedding
# ============================================================================

def tropical_embed(formula: List[Clause], config: Configuration) -> Tuple[int, ...]:
    """
    Embed a configuration into tropical space.

    Maps config C to the vector (t₁, ..., tₙ) where tᵢ = 1 if the
    i-th clause of the formula is present in C, and 0 otherwise.

    Time complexity: O(|F| · |C|) where |F| is formula size, |C| is config size.
    Space complexity: O(|F|)

    Args:
        formula: List of clauses defining the coordinate axes.
        config: A configuration (set of clauses).

    Returns:
        Tuple of 0s and 1s representing the tropical point.
    """
    return tuple(1 if clause in config else 0 for clause in formula)


def tropical_support_size(formula: List[Clause], config: Configuration) -> int:
    """
    Compute the tropical support size (number of nonzero coordinates).

    By Theorem 1, this equals the clause load.

    Time complexity: O(|F|)
    Space complexity: O(1)
    """
    return sum(1 for clause in formula if clause in config)


# ============================================================================
# Algorithm 2: Clause Load Computation
# ============================================================================

def clause_load(formula_set: Set[Clause], config: Configuration) -> int:
    """
    Compute the clause load: number of formula clauses active in config.

    Time complexity: O(min(|F|, |C|))
    Space complexity: O(1)

    Args:
        formula_set: Set of clauses in the formula.
        config: A configuration.

    Returns:
        Number of formula clauses present in the configuration.
    """
    return len(formula_set & config)


def max_clause_load(formula_set: Set[Clause], configs: List[Configuration]) -> int:
    """
    Compute the maximum clause load across all configurations.

    Time complexity: O(|Configs| · min(|F|, max|C|))
    Space complexity: O(1)

    Args:
        formula_set: Set of clauses in the formula.
        configs: List of configurations.

    Returns:
        Maximum clause load, or 0 if configs is empty.
    """
    if not configs:
        return 0
    return max(clause_load(formula_set, c) for c in configs)


# ============================================================================
# Algorithm 3: Tropical Dimension Computation
# ============================================================================

def compute_varying_clauses(
    formula: List[Clause], configs: List[Configuration]
) -> Set[Clause]:
    """
    Compute the set of varying clauses: those active in some but not all configs.

    Time complexity: O(|F| · |Configs|)
    Space complexity: O(|F|)

    Args:
        formula: List of clauses.
        configs: List of configurations.

    Returns:
        Set of clauses that exhibit variation across configs.
    """
    varying = set()
    for clause in formula:
        has_active = False
        has_inactive = False
        for config in configs:
            if clause in config:
                has_active = True
            else:
                has_inactive = True
            if has_active and has_inactive:
                varying.add(clause)
                break
    return varying


def tropical_dim(formula: List[Clause], configs: List[Configuration]) -> int:
    """
    Compute the tropical dimension of the configuration image.

    The tropical dimension is the number of coordinates (clauses)
    that exhibit variation across the configuration set.

    Time complexity: O(|F| · |Configs|)
    Space complexity: O(|F|)

    Args:
        formula: List of clauses.
        configs: List of configurations.

    Returns:
        The tropical dimension.
    """
    return len(compute_varying_clauses(formula, configs))


# ============================================================================
# Algorithm 4: Condition Checking
# ============================================================================

def check_support_separated(
    formula: List[Clause], configs: List[Configuration]
) -> Tuple[bool, Optional[Clause]]:
    """
    Check the SupportSeparated condition.

    A formula-config pair is support-separated if every ever-active clause
    has a witness of absence.

    Time complexity: O(|F| · |Configs|)
    Space complexity: O(1)

    Returns:
        (is_separated, violating_clause_or_None)
    """
    for clause in formula:
        is_ever_active = any(clause in c for c in configs)
        if is_ever_active:
            has_absent_witness = any(clause not in c for c in configs)
            if not has_absent_witness:
                return False, clause
    return True, None


def check_load_saturated(
    formula: List[Clause], configs: List[Configuration]
) -> Tuple[bool, Optional[Configuration]]:
    """
    Check the LoadSaturated condition.

    A formula-config pair is load-saturated if some config contains
    all ever-active clauses.

    Time complexity: O(|F| · |Configs|²)
    Space complexity: O(|F|)

    Returns:
        (is_saturated, saturating_config_or_None)
    """
    ever_active = set()
    for clause in formula:
        if any(clause in c for c in configs):
            ever_active.add(clause)

    for config in configs:
        if ever_active <= config:
            return True, config
    return False, None


# ============================================================================
# Algorithm 5: Full Analysis
# ============================================================================

def compute_dimension_report(
    formula: List[Clause], configs: List[Configuration]
) -> DimensionReport:
    """
    Compute a full dimension report for a formula-configuration pair.

    This is the main analysis function that checks all conditions and
    computes all invariants.

    Time complexity: O(|F| · |Configs|²)
    Space complexity: O(|F| + |Configs|)

    Args:
        formula: List of clauses.
        configs: List of configurations.

    Returns:
        A DimensionReport with all computed invariants.
    """
    formula_set = set(formula)

    varying = compute_varying_clauses(formula, configs)
    ever_active = {c for c in formula if any(c in cfg for cfg in configs)}
    always_active = {c for c in formula
                     if configs and all(c in cfg for cfg in configs)}

    t_dim = len(varying)
    m_load = max_clause_load(formula_set, configs)
    sep, _ = check_support_separated(formula, configs)
    sat, _ = check_load_saturated(formula, configs)

    return DimensionReport(
        tropical_dim=t_dim,
        max_clause_load=m_load,
        support_separated=sep,
        load_saturated=sat,
        equality_holds=(t_dim == m_load),
        varying_clauses=varying,
        ever_active=ever_active,
        always_active=always_active,
    )


# ============================================================================
# Algorithm 6: Tropical Dimension Upper Bound
# ============================================================================

def compute_tropical_dim_bound(
    formula: List[Clause], configs: List[Configuration]
) -> int:
    """
    Compute a verified upper bound on tropical dimension.

    Returns |everActiveClauses|, which is always ≥ tropicalDim.
    Under separation, this is exact.

    Time complexity: O(|F| · |Configs|)
    Space complexity: O(|F|)
    """
    count = 0
    for clause in formula:
        if any(clause in c for c in configs):
            count += 1
    return count


# ============================================================================
# Algorithm 7: Configuration Generation
# ============================================================================

def generate_all_configs(
    formula: List[Clause], max_size: Optional[int] = None
) -> List[Configuration]:
    """
    Generate all possible configurations from a clause formula.

    If max_size is given, only generate configs with at most max_size clauses.

    Time complexity: O(2^|F|) (exponential — use only for small formulas)
    Space complexity: O(2^|F|)
    """
    configs = []
    for r in range(len(formula) + 1):
        if max_size is not None and r > max_size:
            break
        for subset in combinations(formula, r):
            configs.append(frozenset(subset))
    return configs


def find_optimal_config_set(
    formula: List[Clause]
) -> Tuple[List[Configuration], DimensionReport]:
    """
    Find a minimal configuration set achieving equality.

    Strategy: include empty config (for separation) and full config
    (for saturation).

    Time complexity: O(|F|)
    Space complexity: O(|F|)
    """
    empty = frozenset()
    full = frozenset(formula)
    configs = [empty, full]

    report = compute_dimension_report(formula, configs)
    return configs, report


# ============================================================================
# Demo / Self-test
# ============================================================================

if __name__ == "__main__":
    # Create a simple formula
    c1 = frozenset({1, 2})
    c2 = frozenset({2, 3})
    c3 = frozenset({3, 4})
    formula = [c1, c2, c3]

    print("Tropical Clause Space — Algorithm Suite")
    print("=" * 50)
    print(f"Formula: {[set(c) for c in formula]}")

    # Find optimal config set
    configs, report = find_optimal_config_set(formula)
    print(f"\nOptimal config set: [empty, full]")
    print(f"  Tropical dimension:  {report.tropical_dim}")
    print(f"  Max clause load:     {report.max_clause_load}")
    print(f"  Support separated:   {report.support_separated}")
    print(f"  Load saturated:      {report.load_saturated}")
    print(f"  Equality holds:      {report.equality_holds}")

    # Test with all configs
    all_configs = generate_all_configs(formula)
    report_all = compute_dimension_report(formula, all_configs)
    print(f"\nWith all {len(all_configs)} configs:")
    print(f"  Tropical dimension:  {report_all.tropical_dim}")
    print(f"  Max clause load:     {report_all.max_clause_load}")
    print(f"  Equality holds:      {report_all.equality_holds}")

    # Profiles
    print(f"\nTropical profiles:")
    formula_set = set(formula)
    for cfg in all_configs[:6]:  # Show first 6
        emb = tropical_embed(formula, cfg)
        load = clause_load(formula_set, cfg)
        print(f"  {set(set(c) for c in cfg) or '∅'} → {emb}, load={load}")

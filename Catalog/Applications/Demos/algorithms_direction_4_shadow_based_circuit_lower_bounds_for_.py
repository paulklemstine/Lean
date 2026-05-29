#!/usr/bin/env python3
"""
algorithms.py — Algorithms for Permanent Support Shadow Analysis

Implements efficient algorithms for:
1. Generating permanent support families
2. Computing k-shadows
3. Counting partial permutation supports
4. Computing completion multiplicities
5. Verifying the exact counting formula

Complexity analysis included in docstrings.

Application keywords: permanent polynomial, shadow method, permutation matrices,
bipartite matchings, rook placements, exact enumeration
"""

from itertools import permutations, combinations
from math import factorial, comb
from typing import FrozenSet, Set, Dict, List, Tuple
from collections import defaultdict


# Type aliases
Cell = Tuple[int, int]
Support = FrozenSet[Cell]


def generate_perm_support_family(n: int) -> Set[Support]:
    """Generate the permanent support family for n × n matrices.

    Each permutation σ ∈ S_n gives a support {(i, σ(i)) : i ∈ [n]}.

    Time: O(n! · n)
    Space: O(n! · n)

    Args:
        n: Matrix dimension

    Returns:
        Set of all permutation graphs as frozensets of (row, col) pairs

    Example:
        >>> family = generate_perm_support_family(3)
        >>> len(family)
        6
    """
    return {frozenset((i, sigma[i]) for i in range(n))
            for sigma in permutations(range(n))}


def compute_k_shadow(family: Set[Support], k: int) -> Set[Support]:
    """Compute the k-shadow of a family of sets.

    The k-shadow consists of all subsets obtained by removing exactly k
    elements from some member of the family.

    Time: O(|family| · C(n, k)) where n is the size of each member
    Space: O(|shadow|)

    Args:
        family: Input family of sets
        k: Number of elements to remove

    Returns:
        The k-shadow as a set of frozensets

    Example:
        >>> family = generate_perm_support_family(4)
        >>> shadow = compute_k_shadow(family, 2)
        >>> len(shadow)
        72
    """
    shadow = set()
    for s in family:
        s_list = sorted(s)
        target_size = len(s_list) - k
        if target_size < 0:
            continue
        for subset in combinations(s_list, target_size):
            shadow.add(frozenset(subset))
    return shadow


def is_partial_perm_support(s: Support, n: int) -> bool:
    """Check if a set of cells forms a partial permutation support.

    A partial permutation support has no two cells sharing a row or column.
    Equivalently, it's a nonattacking rook placement.

    Time: O(|s|)
    Space: O(|s|)

    Args:
        s: Set of (row, col) pairs
        n: Board dimension

    Returns:
        True if s is a partial permutation support

    Example:
        >>> is_partial_perm_support(frozenset([(0,0), (1,1)]), 3)
        True
        >>> is_partial_perm_support(frozenset([(0,0), (0,1)]), 3)
        False
    """
    rows = [p[0] for p in s]
    cols = [p[1] for p in s]
    return len(rows) == len(set(rows)) and len(cols) == len(set(cols))


def count_partial_perm_supports(n: int, size: int) -> int:
    """Count partial permutation supports of given size on [n]×[n].

    Formula: C(n, size)² · size!
    This equals choosing which rows and columns are covered,
    then a bijection between them.

    Time: O(1) using the formula
    Space: O(1)

    Args:
        n: Board dimension
        size: Number of cells in the support

    Returns:
        Number of partial permutation supports of the given size

    Example:
        >>> count_partial_perm_supports(4, 2)
        72
    """
    return comb(n, size) ** 2 * factorial(size)


def count_partial_perm_supports_brute(n: int, size: int) -> int:
    """Count partial permutation supports by brute force enumeration.

    Time: O(C(n², size))
    Space: O(1)
    """
    count = 0
    all_cells = [(i, j) for i in range(n) for j in range(n)]
    for subset in combinations(all_cells, size):
        if is_partial_perm_support(frozenset(subset), n):
            count += 1
    return count


def compute_completion_count(s: Support, family: Set[Support]) -> int:
    """Count how many members of a family contain s.

    Time: O(|family| · |s|)
    Space: O(1)

    Args:
        s: A subset to check containment of
        family: The family to search in

    Returns:
        Number of members of family that contain s
    """
    s_set = set(s)
    return sum(1 for t in family if s_set <= set(t))


def compute_defect_analysis(s: Support, n: int) -> Dict:
    """Analyze the defect structure of a partial permutation support.

    Returns the missing rows, missing columns, and possible completions.

    Time: O(|s| + n)
    Space: O(n)

    Args:
        s: A partial permutation support
        n: Board dimension

    Returns:
        Dictionary with defect rows, defect cols, and completions
    """
    covered_rows = {p[0] for p in s}
    covered_cols = {p[1] for p in s}
    missing_rows = sorted(set(range(n)) - covered_rows)
    missing_cols = sorted(set(range(n)) - covered_cols)

    # Generate all completions (bijections from missing rows to missing cols)
    completions = []
    for perm in permutations(missing_cols):
        completion = frozenset(s | frozenset(zip(missing_rows, perm)))
        completions.append(completion)

    return {
        'missing_rows': missing_rows,
        'missing_cols': missing_cols,
        'num_completions': len(completions),
        'completions': completions,
    }


def exact_shadow_formula(n: int, k: int) -> int:
    """Compute C(n,k)² · (n-k)! — the conjectured k-shadow size.

    Time: O(1)
    Space: O(1)
    """
    if k > n:
        return 0
    return comb(n, k) ** 2 * factorial(n - k)


def verify_shadow_formula(n_max: int = 7) -> bool:
    """Verify the shadow formula for all n ≤ n_max and all k ≤ n.

    Returns True if all checks pass.

    Example:
        >>> verify_shadow_formula(6)
        True
    """
    all_pass = True
    for n in range(2, n_max + 1):
        family = generate_perm_support_family(n)
        for k in range(n + 1):
            shadow = compute_k_shadow(family, k)
            expected = exact_shadow_formula(n, k)
            if len(shadow) != expected:
                print(f"FAIL: n={n}, k={k}: |Sh_k|={len(shadow)} != {expected}")
                all_pass = False
    return all_pass


def shadow_growth_analysis(n_max: int = 10) -> List[Dict]:
    """Analyze the growth rate of |Sh₂| vs 2^(n/2).

    Uses the exact formula rather than brute force for large n.

    Time: O(n_max)
    Space: O(n_max)
    """
    results = []
    for n in range(2, n_max + 1):
        shadow_size = exact_shadow_formula(n, 2)
        exp_bound = 2 ** (n // 2)
        results.append({
            'n': n,
            'shadow_size': shadow_size,
            'exp_bound': exp_bound,
            'ratio': shadow_size / exp_bound if exp_bound > 0 else float('inf'),
            'satisfies_bound': shadow_size >= exp_bound,
        })
    return results


if __name__ == "__main__":
    print("=== Algorithm Verification ===\n")

    # Verify formula vs brute force
    print("1. Formula vs brute force for partial perm supports:")
    for n in range(2, 6):
        for size in range(n + 1):
            formula = count_partial_perm_supports(n, size)
            brute = count_partial_perm_supports_brute(n, size)
            status = "✓" if formula == brute else "✗"
            print(f"   n={n}, size={size}: formula={formula}, brute={brute} {status}")

    # Verify shadow formula
    print("\n2. Shadow formula verification:")
    result = verify_shadow_formula(7)
    print(f"   All checks passed: {result}")

    # Growth analysis
    print("\n3. Shadow growth analysis:")
    for row in shadow_growth_analysis(15):
        print(f"   n={row['n']:>2}: |Sh₂| = {row['shadow_size']:>15,} ≥ "
              f"2^({row['n']//2}) = {row['exp_bound']:>8,}  "
              f"ratio = {row['ratio']:>10.1f}")

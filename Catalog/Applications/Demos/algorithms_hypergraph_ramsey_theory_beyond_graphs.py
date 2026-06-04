#!/usr/bin/env python3
"""
Hypergraph Ramsey Theory: Algorithms

Type-hinted implementations of the key algorithms from the formalization.
"""

from math import comb, log2
from typing import List, Set, FrozenSet, Callable, Optional, Tuple
from itertools import combinations
import random


def tower(base: int, height: int) -> int:
    """
    Tower function: iterated exponentiation.
    tower(b, 0) = 1
    tower(b, k+1) = b^tower(b, k)

    Examples:
        tower(2, 0) = 1
        tower(2, 1) = 2
        tower(2, 2) = 4
        tower(2, 3) = 16
        tower(2, 4) = 65536
    """
    if height == 0:
        return 1
    prev = tower(base, height - 1)
    if prev > 100000:
        return float('inf')
    return base ** prev


def stepping_up_bound(graph_ramsey: int) -> int:
    """
    Erdős-Rado stepping-up bound.
    Given R_r(k,l), provides upper bound for R_{r+1}(k+1, l+1).

    stepping_up_bound(R) = 2^(R-1) + 1

    This encodes the key structural insight: each increase in uniformity
    adds one exponential layer to the Ramsey number.
    """
    return 2 ** (graph_ramsey - 1) + 1


def probabilistic_lower_bound(k: int, r: int = 3) -> int:
    """
    Compute the probabilistic lower bound for R_r(k,k).

    For r-uniform hypergraphs, the probabilistic method gives:
    R_r(k,k) > max{n : 2 * C(n,k) < 2^C(k,r)}

    Args:
        k: Clique size
        r: Uniformity (default 3 for 3-uniform hypergraphs)

    Returns:
        Lower bound n such that R_r(k,k) > n
    """
    target = 2 ** comb(k, r)
    n = k
    while 2 * comb(n, k) < target:
        n += 1
    return n - 1


def check_monochromatic_clique(
    coloring: Callable[[FrozenSet[int]], bool],
    vertices: Set[int],
    k: int,
    r: int = 3
) -> Optional[Tuple[FrozenSet[int], bool]]:
    """
    Check if a coloring contains a monochromatic k-clique.

    Args:
        coloring: Function from r-element subsets to bool (True=red, False=blue)
        vertices: Set of vertices
        k: Required clique size
        r: Uniformity

    Returns:
        (clique, color) if found, None otherwise
    """
    for clique_tuple in combinations(sorted(vertices), k):
        clique = frozenset(clique_tuple)
        r_subsets = [frozenset(s) for s in combinations(clique_tuple, r)]
        if not r_subsets:
            return (clique, True)  # vacuously monochromatic

        first_color = coloring(r_subsets[0])
        if all(coloring(s) == first_color for s in r_subsets[1:]):
            return (clique, first_color)

    return None


def random_coloring_search(
    n: int, k: int, r: int = 3, trials: int = 1000
) -> Optional[Callable[[FrozenSet[int]], bool]]:
    """
    Search for a coloring of r-subsets of [n] with no monochromatic k-clique
    using random colorings.

    This implements the probabilistic method computationally:
    if R_r(k,k) > n, random colorings should frequently avoid monochromatic cliques.

    Args:
        n: Number of vertices
        k: Clique size to avoid
        r: Uniformity
        trials: Number of random colorings to try

    Returns:
        A coloring with no monochromatic k-clique, or None
    """
    vertices = set(range(n))
    r_subsets = [frozenset(s) for s in combinations(range(n), r)]

    for _ in range(trials):
        # Random coloring
        colors = {s: random.choice([True, False]) for s in r_subsets}
        coloring = lambda s, c=colors: c[s]

        result = check_monochromatic_clique(coloring, vertices, k, r)
        if result is None:
            return coloring

    return None


def erdos_szekeres_bound(k: int) -> int:
    """
    Erdős-Szekeres upper bound for graph Ramsey numbers: R_2(k,k) ≤ C(2k-2, k-1).
    """
    return comb(2 * k - 2, k - 1)


def growth_rate_analysis(k_max: int = 10) -> List[dict]:
    """
    Analyze the growth rate of R_3(k,k) bounds.

    Returns a list of dicts with:
    - k: clique size
    - prob_lower: probabilistic lower bound
    - graph_ramsey_bound: Erdős-Szekeres bound for R_2(k,k)
    - stepping_up: stepping-up bound from R_2(k-1,k-1)
    - tower_value: tower(2, k)
    """
    results = []
    for k in range(3, k_max + 1):
        prob = probabilistic_lower_bound(k)
        graph = erdos_szekeres_bound(k)
        step = stepping_up_bound(erdos_szekeres_bound(k - 1)) if k > 3 else None
        tw_val = tower(2, k)
        tw = tw_val if tw_val != float('inf') and tw_val < 10**100 else None

        results.append({
            'k': k,
            'prob_lower': prob,
            'graph_ramsey_bound': graph,
            'stepping_up': step,
            'tower_value': tw,
        })

    return results


if __name__ == "__main__":
    print("Growth Rate Analysis:")
    print("-" * 80)
    for r in growth_rate_analysis(8):
        tw_str = str(r['tower_value']) if r['tower_value'] is not None else ">10^10000"
        step_str = str(r['stepping_up']) if r['stepping_up'] is not None else "N/A"
        print(f"k={r['k']}: prob_lower={r['prob_lower']}, "
              f"graph_R2={r['graph_ramsey_bound']}, "
              f"step_up={step_str}, tower={tw_str}")

    print("\nRandom coloring search for small cases:")
    for n in [4, 8, 11, 12]:
        result = random_coloring_search(n, 5, 3, trials=100)
        status = "FOUND" if result else "NOT FOUND"
        print(f"  n={n}, k=5: good coloring {status}")

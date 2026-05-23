#!/usr/bin/env python3
"""
Categorical Shannon Theory — Algorithms

Implements the core algorithms from the research paper:
1. Greedy minimum cover computation
2. Generator graph construction and analysis
3. Shannon lower bound computation
4. Compression ratio analysis
"""

from itertools import combinations, product
from typing import Dict, List, Set, Tuple, Optional
import math


# =============================================================================
# Algorithm 1: Minimum Cover Size (Exact)
# =============================================================================

def exact_min_cover(n_objects: int, fibers: Dict[int, List],
                     restrictions: Dict[Tuple[int, int], Dict]) -> Tuple[int, Set]:
    """Compute exact minimum cover size via exhaustive search.

    Time complexity: O(2^N * N * E) where N = total generators, E = total elements.
    Space complexity: O(N).

    Args:
        n_objects: Number of objects in the category.
        fibers: fibers[i] = list of elements at object i.
        restrictions: restrictions[(target, source)] = {elem_src: elem_tgt}.

    Returns:
        (min_size, min_cover): The minimum cover size and a witnessing cover.

    Example:
        >>> fibers = {0: [0, 1], 1: [0, 1]}
        >>> restrictions = {(0, 0): {0: 0, 1: 1}, (1, 1): {0: 0, 1: 1}}
        >>> exact_min_cover(2, fibers, restrictions)
        (4, {(0, 0), (0, 1), (1, 0), (1, 1)})
    """
    # Build generator list
    generators = []
    for obj in range(n_objects):
        for elem in fibers[obj]:
            generators.append((obj, elem))

    # Build element list
    elements = []
    for obj in range(n_objects):
        for elem in fibers[obj]:
            elements.append((obj, elem))

    # Precompute coverage: for each generator, which elements does it cover?
    coverage = {}
    for gen in generators:
        src_obj, src_elem = gen
        covered = set()
        for tgt_obj in range(n_objects):
            if (tgt_obj, src_obj) in restrictions:
                tgt_elem = restrictions[(tgt_obj, src_obj)][src_elem]
                covered.add((tgt_obj, tgt_elem))
        coverage[gen] = covered

    # Exhaustive search by increasing subset size
    all_elements = set(elements)
    n = len(generators)

    for size in range(n + 1):
        for subset_idx in combinations(range(n), size):
            gen_set = {generators[i] for i in subset_idx}
            total_covered = set()
            for g in gen_set:
                total_covered |= coverage[g]
            if total_covered >= all_elements:
                return size, gen_set

    return n, set(generators)


# =============================================================================
# Algorithm 2: Greedy Minimum Cover (Approximation)
# =============================================================================

def greedy_min_cover(n_objects: int, fibers: Dict[int, List],
                      restrictions: Dict[Tuple[int, int], Dict]) -> Tuple[int, Set]:
    """Greedy approximation for minimum cover.

    Uses the standard greedy set cover heuristic: repeatedly pick the generator
    that covers the most uncovered elements.

    Time complexity: O(N² * E) where N = total generators, E = total elements.
    Approximation ratio: O(ln(E)) — standard set cover guarantee.

    Args:
        n_objects: Number of objects.
        fibers: Fiber data.
        restrictions: Restriction maps.

    Returns:
        (cover_size, cover_set): Greedy cover and its size.

    Example:
        >>> fibers = {0: [0, 1], 1: [0, 1]}
        >>> restrictions = {(i, j): {0: 0, 1: 1} for i in range(2) for j in range(2)}
        >>> size, cover = greedy_min_cover(2, fibers, restrictions)
        >>> size <= 2  # Connected model: 2 generators suffice
        True
    """
    generators = [(obj, elem) for obj in range(n_objects) for elem in fibers[obj]]

    coverage = {}
    for gen in generators:
        src_obj, src_elem = gen
        covered = set()
        for tgt_obj in range(n_objects):
            if (tgt_obj, src_obj) in restrictions:
                tgt_elem = restrictions[(tgt_obj, src_obj)][src_elem]
                covered.add((tgt_obj, tgt_elem))
        coverage[gen] = covered

    all_elements = set()
    for obj in range(n_objects):
        for elem in fibers[obj]:
            all_elements.add((obj, elem))

    uncovered = all_elements.copy()
    selected = set()

    while uncovered:
        # Pick generator covering most uncovered elements
        best_gen = max(generators, key=lambda g: len(coverage[g] & uncovered))
        selected.add(best_gen)
        uncovered -= coverage[best_gen]

    return len(selected), selected


# =============================================================================
# Algorithm 3: Generator Graph Construction
# =============================================================================

def build_generator_graph(n_objects: int, fibers: Dict[int, List],
                           restrictions: Dict[Tuple[int, int], Dict]) -> Dict:
    """Build the generator graph.

    Time complexity: O(N² * n_objects) where N = total generators.
    Space complexity: O(N²).

    Returns:
        Dictionary with 'vertices', 'adj_list', 'in_degree', 'out_degree'.
    """
    vertices = [(obj, elem) for obj in range(n_objects) for elem in fibers[obj]]
    adj_list = {v: set() for v in vertices}
    in_degree = {v: 0 for v in vertices}
    out_degree = {v: 0 for v in vertices}

    for src in vertices:
        src_obj, src_elem = src
        for tgt_obj in range(n_objects):
            if (tgt_obj, src_obj) in restrictions:
                tgt_elem = restrictions[(tgt_obj, src_obj)][src_elem]
                tgt = (tgt_obj, tgt_elem)
                if tgt != src:
                    adj_list[src].add(tgt)
                    out_degree[src] += 1
                    in_degree[tgt] += 1

    return {
        'vertices': vertices,
        'adj_list': adj_list,
        'in_degree': in_degree,
        'out_degree': out_degree,
        'n_vertices': len(vertices),
        'n_edges': sum(out_degree.values()),
    }


# =============================================================================
# Algorithm 4: Shannon Lower Bound
# =============================================================================

def shannon_lower_bound(n_objects: int, fibers: Dict[int, List],
                         restrictions: Dict[Tuple[int, int], Dict]) -> int:
    """Compute the categorical Shannon lower bound.

    For each object X, the number of generators needed is at least
    ceil(|F(X)| / number_of_objects_with_restriction_to_X).

    Time complexity: O(n² + sum |F(X)|).

    Returns:
        Lower bound on minimum cover size.

    Example:
        >>> fibers = {0: [0, 1, 2], 1: [0, 1, 2]}
        >>> restrictions = {(0, 0): {0: 0, 1: 1, 2: 2}, (1, 1): {0: 0, 1: 1, 2: 2}}
        >>> shannon_lower_bound(2, fibers, restrictions)
        3
    """
    bound = 0
    for x in range(n_objects):
        fx_size = len(fibers[x])
        sources = sum(1 for y in range(n_objects) if (x, y) in restrictions)
        if sources > 0:
            bound = max(bound, math.ceil(fx_size / sources))
    return bound


# =============================================================================
# Algorithm 5: Compression Ratio Analysis
# =============================================================================

def analyze_compression(n_objects: int, fibers: Dict[int, List],
                         restrictions: Dict[Tuple[int, int], Dict]) -> Dict:
    """Comprehensive compression analysis.

    Returns dictionary with:
    - total_elements: Sum of fiber sizes
    - min_cover_exact: Exact minimum cover size
    - min_cover_greedy: Greedy approximation
    - shannon_lb: Shannon lower bound
    - compression_ratio: total_elements / min_cover_exact
    - graph_stats: Generator graph statistics

    Example:
        >>> fibers = {0: [0, 1], 1: [0, 1]}
        >>> restrictions = {(i, j): {0: 0, 1: 1} for i in range(2) for j in range(2)}
        >>> result = analyze_compression(2, fibers, restrictions)
        >>> result['compression_ratio']
        2.0
    """
    total = sum(len(fibers[obj]) for obj in range(n_objects))

    exact_size, exact_cover = exact_min_cover(n_objects, fibers, restrictions)
    greedy_size, greedy_cover = greedy_min_cover(n_objects, fibers, restrictions)
    lb = shannon_lower_bound(n_objects, fibers, restrictions)
    graph = build_generator_graph(n_objects, fibers, restrictions)

    return {
        'total_elements': total,
        'min_cover_exact': exact_size,
        'min_cover_greedy': greedy_size,
        'shannon_lb': lb,
        'compression_ratio': total / exact_size if exact_size > 0 else float('inf'),
        'greedy_ratio': greedy_size / exact_size if exact_size > 0 else 1.0,
        'graph_stats': {
            'n_vertices': graph['n_vertices'],
            'n_edges': graph['n_edges'],
            'max_out_degree': max(graph['out_degree'].values()) if graph['out_degree'] else 0,
            'max_in_degree': max(graph['in_degree'].values()) if graph['in_degree'] else 0,
        }
    }


# =============================================================================
# Example Usage
# =============================================================================

if __name__ == "__main__":
    print("Algorithm demonstrations:")
    print()

    # Discrete model
    print("--- Discrete model (3 objects, fiber size 2) ---")
    fibers = {i: [0, 1] for i in range(3)}
    restrictions = {(i, i): {0: 0, 1: 1} for i in range(3)}
    result = analyze_compression(3, fibers, restrictions)
    for k, v in result.items():
        print(f"  {k}: {v}")
    print()

    # Connected model
    print("--- Connected model (3 objects, fiber size 2) ---")
    restrictions = {(i, j): {0: 0, 1: 1} for i in range(3) for j in range(3)}
    result = analyze_compression(3, fibers, restrictions)
    for k, v in result.items():
        print(f"  {k}: {v}")
    print()

    # Partial model
    print("--- Partial model (3 objects, fiber size 2, star from 0) ---")
    restrictions = {(i, i): {0: 0, 1: 1} for i in range(3)}
    restrictions[(1, 0)] = {0: 0, 1: 1}
    restrictions[(2, 0)] = {0: 0, 1: 1}
    result = analyze_compression(3, fibers, restrictions)
    for k, v in result.items():
        print(f"  {k}: {v}")

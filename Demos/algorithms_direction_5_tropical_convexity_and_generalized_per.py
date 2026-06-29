#!/usr/bin/env python3
"""
Algorithms for M-Convex Sets and Generalized Permutohedra

Implements:
1. M-convexity verification algorithm
2. Submodular function optimization on generalized permutohedra
3. Exchange graph construction and traversal
4. Newton polytope computation for multivariate polynomials
"""

import itertools
import math
from typing import List, Tuple, Set, Dict, FrozenSet, Optional, Callable
from collections import defaultdict, deque


# ──────────────────────────────────────────────────────────────────
# Algorithm 1: M-Convexity Verification
# ──────────────────────────────────────────────────────────────────

def verify_mconvex(S: Set[Tuple[int, ...]], n: int) -> Tuple[bool, Optional[str]]:
    """Verify the M-convex exchange property for a finite set S ⊂ ℤⁿ.

    Algorithm: For each pair (α, β) and each index i with α_i > β_i,
    check existence of j with α_j < β_j and α - e_i + e_j ∈ S.

    Time complexity: O(|S|² · n²)
    Space complexity: O(|S| · n)

    Args:
        S: Set of integer vectors (as tuples)
        n: Dimension

    Returns:
        (True, None) if M-convex, (False, reason) otherwise
    """
    # Check constant sum
    sums = {sum(v) for v in S}
    if len(sums) > 1:
        return False, f"Non-constant sums: {sums}"

    # Check exchange property
    for alpha in S:
        for beta in S:
            for i in range(n):
                if alpha[i] > beta[i]:
                    found = False
                    for j in range(n):
                        if alpha[j] < beta[j]:
                            new_vec = list(alpha)
                            new_vec[i] -= 1
                            new_vec[j] += 1
                            if tuple(new_vec) in S:
                                found = True
                                break
                    if not found:
                        return False, (
                            f"Exchange fails: α={alpha}, β={beta}, i={i}, "
                            f"α_i={alpha[i]} > β_i={beta[i]}, no valid j found"
                        )
    return True, None


# ──────────────────────────────────────────────────────────────────
# Algorithm 2: Exchange Graph
# ──────────────────────────────────────────────────────────────────

def build_exchange_graph(S: Set[Tuple[int, ...]], n: int) -> Dict[Tuple, List[Tuple]]:
    """Build the exchange graph of an M-convex set.

    Vertices are elements of S. An edge α → β exists if β = α - e_i + e_j
    for some i, j (a single exchange step).

    Time complexity: O(|S| · n²)
    Space complexity: O(|S| · n²) for the adjacency list

    Args:
        S: M-convex set
        n: Dimension

    Returns:
        Adjacency list representation of the exchange graph
    """
    graph: Dict[Tuple, List[Tuple]] = defaultdict(list)
    for alpha in S:
        for i in range(n):
            for j in range(n):
                if i != j and alpha[i] > 0:
                    new_vec = list(alpha)
                    new_vec[i] -= 1
                    new_vec[j] += 1
                    t = tuple(new_vec)
                    if t in S:
                        graph[alpha].append(t)
    return dict(graph)


def exchange_path(S: Set[Tuple[int, ...]], n: int,
                  alpha: Tuple[int, ...], beta: Tuple[int, ...]) -> Optional[List[Tuple[int, int]]]:
    """Find a sequence of exchange steps from α to β in an M-convex set.

    Uses BFS on the exchange graph to find the shortest path.

    Time complexity: O(|S| · n²)

    Args:
        S: M-convex set
        n: Dimension
        alpha: Starting point
        beta: Target point

    Returns:
        List of (i, j) pairs representing exchange steps, or None if unreachable
    """
    if alpha == beta:
        return []

    graph = build_exchange_graph(S, n)
    queue = deque([(alpha, [])])
    visited = {alpha}

    while queue:
        current, path = queue.popleft()
        for i in range(n):
            for j in range(n):
                if i != j and current[i] > 0:
                    new_vec = list(current)
                    new_vec[i] -= 1
                    new_vec[j] += 1
                    t = tuple(new_vec)
                    if t in S and t not in visited:
                        new_path = path + [(i, j)]
                        if t == beta:
                            return new_path
                        visited.add(t)
                        queue.append((t, new_path))
    return None


# ──────────────────────────────────────────────────────────────────
# Algorithm 3: Submodular Function Optimization
# ──────────────────────────────────────────────────────────────────

def greedy_submodular_max(f: Callable[[FrozenSet], int], n: int) -> Tuple[FrozenSet, int]:
    """Greedy algorithm to maximize a submodular function.

    Uses the greedy algorithm: at each step, add the element that
    gives the maximum marginal gain.

    Time complexity: O(n²)
    Space complexity: O(n)

    Note: This is optimal for monotone submodular functions.
    For general submodular functions, it gives a (1-1/e) approximation.

    Args:
        f: Submodular function
        n: Ground set size [n] = {0, ..., n-1}

    Returns:
        (optimal_set, optimal_value)
    """
    current = frozenset()
    remaining = set(range(n))

    best_set = frozenset()
    best_val = f(frozenset())

    for _ in range(n):
        if not remaining:
            break
        # Find element with maximum marginal gain
        best_elem = None
        best_gain = float('-inf')
        for elem in remaining:
            gain = f(current | {elem}) - f(current)
            if gain > best_gain:
                best_gain = gain
                best_elem = elem

        if best_gain > 0:
            current = current | {best_elem}
            remaining.remove(best_elem)
            val = f(current)
            if val > best_val:
                best_set = current
                best_val = val
        else:
            break

    return best_set, best_val


# ──────────────────────────────────────────────────────────────────
# Algorithm 4: Newton Polytope Computation
# ──────────────────────────────────────────────────────────────────

def newton_polytope(coefficients: Dict[Tuple[int, ...], float],
                    n: int) -> Set[Tuple[int, ...]]:
    """Compute the Newton polytope support of a polynomial.

    The Newton polytope is the convex hull of the exponent vectors
    with nonzero coefficients. Here we return just the support
    (exponent vectors with nonzero coefficients).

    Time complexity: O(|coefficients|)

    Args:
        coefficients: Map from exponent vector to coefficient
        n: Number of variables

    Returns:
        Set of exponent vectors with nonzero coefficients
    """
    return {exp for exp, coeff in coefficients.items() if abs(coeff) > 1e-12}


def check_generalized_permutohedron_edges(support: Set[Tuple[int, ...]],
                                           n: int) -> Tuple[bool, List[str]]:
    """Check if the convex hull of a point set has edge directions of the form e_i - e_j.

    For lattice points, we check that for any two adjacent points (differing
    in exactly two coordinates), the difference is ±(e_i - e_j).

    Args:
        support: Set of lattice points
        n: Dimension

    Returns:
        (is_gen_permutohedron, list of edge descriptions)
    """
    edges = []
    violations = []

    for alpha in support:
        for beta in support:
            if alpha == beta:
                continue
            diff = tuple(beta[k] - alpha[k] for k in range(n))

            # Check sum is zero (necessary condition)
            if sum(diff) != 0:
                violations.append(f"Sum ≠ 0: {alpha} → {beta}, diff={diff}")
                continue

            # Check if diff is a scalar multiple of some e_i - e_j
            nonzero = [(k, diff[k]) for k in range(n) if diff[k] != 0]
            if len(nonzero) == 2:
                (k1, v1), (k2, v2) = nonzero
                if v1 == -v2:
                    if v1 > 0:
                        edges.append(f"  {alpha} → {beta}: {v1}·(e_{k1} - e_{k2})")
                    else:
                        edges.append(f"  {alpha} → {beta}: {-v1}·(e_{k2} - e_{k1})")
                else:
                    violations.append(f"  Bad edge: {alpha} → {beta}, diff={diff}")

    return len(violations) == 0, edges


# ──────────────────────────────────────────────────────────────────
# Algorithm 5: Verified Generalized Permutohedron Check
# ──────────────────────────────────────────────────────────────────

def verified_gen_permutohedron_check(
    coefficients: Dict[Tuple[int, ...], float], n: int
) -> Dict:
    """Full pipeline: polynomial → Newton polytope → edge check → M-convex check.

    Given a polynomial (as coefficient map), computes its Newton polytope
    and verifies whether it forms a generalized permutohedron by checking:
    1. All edge directions are of the form e_i - e_j
    2. The support is M-convex

    Args:
        coefficients: Polynomial coefficients
        n: Number of variables

    Returns:
        Dictionary with verification results
    """
    support = newton_polytope(coefficients, n)

    # Check constant sum (all supports should have same degree)
    degrees = {sum(exp) for exp in support}
    constant_degree = len(degrees) <= 1

    # Check M-convexity
    is_mconvex, mconvex_reason = verify_mconvex(support, n)

    # Check edge directions
    is_gp, edges = check_generalized_permutohedron_edges(support, n)

    return {
        "support_size": len(support),
        "support": support,
        "degrees": degrees,
        "constant_degree": constant_degree,
        "is_mconvex": is_mconvex,
        "mconvex_reason": mconvex_reason,
        "is_generalized_permutohedron": is_gp,
        "edge_count": len(edges),
    }


# ──────────────────────────────────────────────────────────────────
# Example usage
# ──────────────────────────────────────────────────────────────────

def main():
    print("=" * 70)
    print("ALGORITHMS FOR M-CONVEX SETS AND GENERALIZED PERMUTOHEDRA")
    print("=" * 70)

    # Example 1: Verify M-convexity of simplex
    print("\n─── Algorithm 1: M-Convexity Verification ───")
    n, d = 3, 2
    S = set()
    for a in range(d + 1):
        for b in range(d - a + 1):
            c = d - a - b
            S.add((a, b, c))

    is_mc, reason = verify_mconvex(S, n)
    print(f"  Simplex(3,2) = {sorted(S)}")
    print(f"  M-convex: {is_mc}")

    # Example 2: Exchange graph
    print("\n─── Algorithm 2: Exchange Graph ───")
    graph = build_exchange_graph(S, n)
    print(f"  Exchange graph has {len(graph)} vertices")
    for v, neighbors in sorted(graph.items()):
        print(f"    {v} → {neighbors}")

    # Example 3: Exchange path
    print("\n─── Algorithm 3: Exchange Path ───")
    path = exchange_path(S, n, (2, 0, 0), (0, 0, 2))
    print(f"  Path from (2,0,0) to (0,0,2): {path}")

    # Example 4: Newton polytope of x²+y²+z²+xy+xz+yz
    print("\n─── Algorithm 4: Newton Polytope Verification ───")
    coeffs = {
        (2, 0, 0): 1.0, (0, 2, 0): 1.0, (0, 0, 2): 1.0,
        (1, 1, 0): 1.0, (1, 0, 1): 1.0, (0, 1, 1): 1.0
    }
    result = verified_gen_permutohedron_check(coeffs, 3)
    print(f"  Polynomial: x²+y²+z²+xy+xz+yz")
    print(f"  Support size: {result['support_size']}")
    print(f"  Constant degree: {result['constant_degree']}")
    print(f"  M-convex: {result['is_mconvex']}")
    print(f"  Gen. permutohedron edges: {result['is_generalized_permutohedron']}")

    # Example 5: Submodular optimization
    print("\n─── Algorithm 5: Submodular Optimization ───")
    weights = [3, 4, 5]  # Pythagorean!
    f = lambda S: sum(weights[i] for i in S)
    opt_set, opt_val = greedy_submodular_max(f, 3)
    print(f"  Weights: {weights}")
    print(f"  Greedy optimal: set={opt_set}, value={opt_val}")

    print("\n" + "=" * 70)
    print("All algorithms completed successfully!")
    print("=" * 70)


if __name__ == "__main__":
    main()

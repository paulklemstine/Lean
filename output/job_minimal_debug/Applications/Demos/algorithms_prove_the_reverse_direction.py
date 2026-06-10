#!/usr/bin/env python3
"""
Algorithms for Tropical Plücker Relations and Tree Metrics

Implements:
1. Four-point condition verification
2. Tropical Plücker relation verification
3. Tree metric reconstruction (cherry-picking / neighbor-joining)
4. Projection onto four-point metrics (nearest tree metric)
"""

import itertools
import numpy as np
from typing import List, Tuple, Optional, Dict


def verify_four_point(d: np.ndarray, tol: float = 1e-10) -> dict:
    """Verify the four-point condition for a distance matrix.

    The four-point condition states that for every quadruple (i,j,k,l),
    the three pair-sums s1=d(i,j)+d(k,l), s2=d(i,k)+d(j,l), s3=d(i,l)+d(j,k)
    satisfy: the two largest are equal.

    Args:
        d: symmetric distance matrix (n x n)
        tol: numerical tolerance

    Returns:
        dict with keys 'satisfied', 'violations', 'max_gap'
    """
    n = d.shape[0]
    violations = []
    max_gap = 0.0

    for i, j, k, l in itertools.combinations(range(n), 4):
        s1 = d[i, j] + d[k, l]
        s2 = d[i, k] + d[j, l]
        s3 = d[i, l] + d[j, k]
        sums = sorted([s1, s2, s3])
        gap = abs(sums[2] - sums[1])
        max_gap = max(max_gap, gap)
        if gap > tol:
            violations.append({
                'quadruple': (i, j, k, l),
                'sums': (s1, s2, s3),
                'gap': gap
            })

    return {
        'satisfied': len(violations) == 0,
        'violations': violations,
        'max_gap': max_gap,
        'n_quadruples': len(list(itertools.combinations(range(n), 4)))
    }


def verify_tropical_plucker(d: np.ndarray, tol: float = 1e-10) -> dict:
    """Verify the tropical Plücker relation for a distance matrix.

    For every quadruple (a,b,c,e):
      d(a,b) + d(c,e) ≤ max(d(a,c) + d(b,e), d(a,e) + d(b,c))

    Args:
        d: symmetric distance matrix
        tol: numerical tolerance

    Returns:
        dict with 'satisfied', 'violations', 'max_excess'
    """
    n = d.shape[0]
    violations = []
    max_excess = 0.0

    for a, b, c, e in itertools.combinations(range(n), 4):
        s1 = d[a, b] + d[c, e]
        s2 = d[a, c] + d[b, e]
        s3 = d[a, e] + d[b, c]
        # Check all three orientations
        for si, sj, sk in [(s1, s2, s3), (s2, s1, s3), (s3, s1, s2)]:
            excess = si - max(sj, sk)
            if excess > tol:
                max_excess = max(max_excess, excess)
                violations.append({
                    'quadruple': (a, b, c, e),
                    'excess': excess
                })

    return {
        'satisfied': len(violations) == 0,
        'violations': violations,
        'max_excess': max_excess
    }


def find_cherries(d: np.ndarray) -> Tuple[int, int]:
    """Find a cherry pair in a four-point metric.

    A cherry is a pair (i,j) such that d(i,j) is minimized and the
    four-point condition groups them together in every quadruple.

    For a tree metric, a cherry is a pair of leaves adjacent to the same
    internal node. We find the pair (i,j) minimizing d(i,j).

    Args:
        d: four-point distance matrix

    Returns:
        (i, j): indices of a cherry pair
    """
    n = d.shape[0]
    if n <= 2:
        return (0, 1) if n == 2 else (0, 0)

    # Use the Gromov product criterion
    best_pair = (0, 1)
    best_score = float('inf')

    for i in range(n):
        for j in range(i + 1, n):
            # Gromov product (i|j)_k = (d(i,k) + d(j,k) - d(i,j)) / 2
            # Maximize over k to find how "deep" the cherry is
            score = d[i, j]
            if score < best_score:
                best_score = score
                best_pair = (i, j)

    return best_pair


def reconstruct_tree(d: np.ndarray) -> List[Tuple[int, int, float]]:
    """Reconstruct a weighted tree from a four-point distance matrix.

    Uses the cherry-picking algorithm:
    1. Find a cherry (closest pair)
    2. Compute pendant edge lengths
    3. Contract the cherry
    4. Recurse

    Args:
        d: n x n four-point distance matrix

    Returns:
        List of (node1, node2, weight) edges
    """
    n = d.shape[0]
    if n <= 1:
        return []

    # Map from current indices to original labels
    labels = list(range(n))
    edges = []
    next_internal = n
    current_d = d.copy()

    while len(labels) > 2:
        m = len(labels)
        # Find cherry
        best_i, best_j = 0, 1
        best_dist = current_d[0, 1]
        for i in range(m):
            for j in range(i + 1, m):
                if current_d[i, j] < best_dist:
                    best_dist = current_d[i, j]
                    best_i, best_j = i, j

        # Find a third point for pendant length calculation
        k = 0
        while k == best_i or k == best_j:
            k += 1

        # Pendant edge lengths
        wi = (current_d[best_i, k] + current_d[best_i, best_j] -
              current_d[best_j, k]) / 2
        wj = (current_d[best_j, k] + current_d[best_i, best_j] -
              current_d[best_i, k]) / 2

        # Create internal node
        internal = next_internal
        next_internal += 1

        edges.append((labels[best_i], internal, wi))
        edges.append((labels[best_j], internal, wj))

        # Compute distances from internal node to all other points
        new_dists = np.zeros(m - 1)
        new_labels = []
        idx = 0
        for l in range(m):
            if l != best_i and l != best_j:
                # d(internal, l) = d(i, l) - wi = d(j, l) - wj
                new_dists[idx] = current_d[best_i, l] - wi
                new_labels.append(labels[l])
                idx += 1

        new_labels.append(internal)

        # Build new distance matrix
        new_m = len(new_labels)
        new_d = np.zeros((new_m, new_m))
        old_indices = [l for l in range(m) if l != best_i and l != best_j]

        for a in range(len(old_indices)):
            for b in range(len(old_indices)):
                new_d[a, b] = current_d[old_indices[a], old_indices[b]]

        # Fill in distances to the new internal node
        for a in range(len(old_indices)):
            dist_to_internal = current_d[old_indices[a], best_i] - wi
            new_d[a, new_m - 1] = dist_to_internal
            new_d[new_m - 1, a] = dist_to_internal

        current_d = new_d
        labels = new_labels

    # Connect the last two nodes
    if len(labels) == 2:
        edges.append((labels[0], labels[1], current_d[0, 1]))

    return edges


def project_to_four_point(d: np.ndarray, max_iter: int = 100) -> np.ndarray:
    """Project a distance matrix onto the nearest four-point metric (L∞ sense).

    Uses iterative correction: for each violating quadruple, adjust the
    pair-sums to satisfy the four-point condition.

    Args:
        d: symmetric distance matrix
        max_iter: maximum iterations

    Returns:
        Projected distance matrix satisfying the four-point condition
    """
    n = d.shape[0]
    p = d.copy()

    for iteration in range(max_iter):
        changed = False
        for i, j, k, l in itertools.combinations(range(n), 4):
            s1 = p[i, j] + p[k, l]
            s2 = p[i, k] + p[j, l]
            s3 = p[i, l] + p[j, k]
            sums = sorted([(s1, 1), (s2, 2), (s3, 3)])

            # If the two largest aren't equal, adjust
            if abs(sums[2][0] - sums[1][0]) > 1e-12:
                target = (sums[2][0] + sums[1][0]) / 2
                gap = sums[2][0] - sums[1][0]

                # Adjust the pairs corresponding to the two largest sums
                for idx in [1, 2]:
                    s_idx = sums[idx][1]
                    diff = target - [s1, s2, s3][s_idx - 1]
                    half_diff = diff / 2

                    if s_idx == 1:
                        p[i, j] += half_diff; p[j, i] += half_diff
                        p[k, l] += half_diff; p[l, k] += half_diff
                    elif s_idx == 2:
                        p[i, k] += half_diff; p[k, i] += half_diff
                        p[j, l] += half_diff; p[l, j] += half_diff
                    else:
                        p[i, l] += half_diff; p[l, i] += half_diff
                        p[j, k] += half_diff; p[k, j] += half_diff

                changed = True

        if not changed:
            break

    return p


def tropical_plucker_coordinates(d: np.ndarray) -> Dict[Tuple[int, int], float]:
    """Compute tropical Plücker coordinates from a distance matrix.

    For a symmetric distance function d, the tropical Plücker coordinate on
    the pair {i,j} is p(i,j) = -d(i,j).

    Args:
        d: symmetric distance matrix

    Returns:
        Dictionary mapping (i,j) pairs to Plücker coordinates
    """
    n = d.shape[0]
    coords = {}
    for i in range(n):
        for j in range(i + 1, n):
            coords[(i, j)] = -d[i, j]
    return coords


if __name__ == "__main__":
    print("=== Tree Reconstruction Demo ===\n")

    # Create a known tree
    #    0
    #    |  (w=2)
    #   [4]
    #   / \  (w=1 each internal)
    # [5]  [6]
    # /\    /\
    # 1 2  3  (w=1.5 each pendant)
    from demo import tree_distance_matrix

    edges_true = [
        (0, 4, 2.0),
        (4, 5, 1.0),
        (4, 6, 1.0),
        (1, 5, 1.5),
        (2, 5, 1.5),
        (3, 6, 1.5),
    ]
    d = tree_distance_matrix(edges_true, 4)

    print("Original distance matrix:")
    print(d)
    print()

    result = verify_four_point(d)
    print(f"Four-point condition: {result['satisfied']}")
    print(f"Max gap: {result['max_gap']:.6f}")
    print()

    # Reconstruct
    edges_recon = reconstruct_tree(d)
    print("Reconstructed tree edges:")
    for u, v, w in edges_recon:
        print(f"  {u} -- {v} (weight {w:.4f})")
    print()

    # Tropical Plücker coordinates
    coords = tropical_plucker_coordinates(d)
    print("Tropical Plücker coordinates p(i,j) = -d(i,j):")
    for (i, j), val in sorted(coords.items()):
        print(f"  p({i},{j}) = {val:.4f}")

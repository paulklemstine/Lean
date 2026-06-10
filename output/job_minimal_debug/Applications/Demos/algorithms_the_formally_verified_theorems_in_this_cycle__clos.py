#!/usr/bin/env python3
"""
Berggren Dynamics: Core Algorithms

Implements algorithms for:
1. Berggren tree traversal and word evaluation
2. Extremal path computation at arbitrary depth
3. Modular orbit graph construction
4. Spectral analysis of finite quotient dynamics
"""

import numpy as np
from typing import Tuple, List, Dict, Set, Optional
from collections import deque
from math import gcd

Triple = Tuple[int, int, int]

# === Core Berggren Matrices ===

MAT_A = np.array([[1, -2, 2], [2, -1, 2], [2, -2, 3]], dtype=np.int64)
MAT_B = np.array([[1, 2, 2], [2, 1, 2], [2, 2, 3]], dtype=np.int64)
MAT_C = np.array([[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]], dtype=np.int64)

GENERATORS = {'A': MAT_A, 'B': MAT_B, 'C': MAT_C}
ROOT = np.array([3, 4, 5], dtype=np.int64)

def apply_word_matrix(word: str) -> np.ndarray:
    """Compute the product matrix for a Berggren word.

    Time: O(n) where n = len(word)
    Space: O(1)
    """
    M = np.eye(3, dtype=np.int64)
    for letter in word:
        M = GENERATORS[letter] @ M
    return M

def apply_word(word: str) -> Triple:
    """Evaluate a word on the root triple (3,4,5).

    Time: O(n)
    Space: O(1)
    """
    v = ROOT.copy()
    for letter in word:
        v = GENERATORS[letter] @ v
    return tuple(v)

# === Algorithm 1: Extremal Path Finder ===

def find_extremal_paths(depth: int, k: int = 3) -> List[Tuple[str, int]]:
    """Find the k words of given depth with smallest hypotenuse.

    Uses branch-and-bound pruning: any subtree rooted at a node
    with hypotenuse > current k-th best can be pruned.

    Time: O(3^n) worst case, but pruning is very effective.
    Space: O(n * k)

    Args:
        depth: Word length
        k: Number of extremal paths to find

    Returns:
        List of (word, hypotenuse) pairs sorted by hypotenuse
    """
    import heapq

    # Min-heap of (hypotenuse, word)
    best = []  # Will store (-hyp, word) as max-heap of size k

    def search(prefix: str, triple: Triple, remaining: int):
        if remaining == 0:
            h = triple[2]
            if len(best) < k:
                heapq.heappush(best, (-h, prefix))
            elif h < -best[0][0]:
                heapq.heapreplace(best, (-h, prefix))
            return

        # Pruning: if current hypotenuse already exceeds k-th best, skip
        if len(best) >= k and triple[2] >= -best[0][0]:
            return

        for letter in 'ACB':  # Try A first (likely smallest), then C, then B
            a, b, c = triple
            if letter == 'A':
                child = (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)
            elif letter == 'B':
                child = (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)
            else:
                child = (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)
            search(prefix + letter, child, remaining - 1)

    search('', (3, 4, 5), depth)
    result = [(-h, w) for h, w in best]
    result.sort()
    return [(w, h) for h, w in result]


# === Algorithm 2: Modular Orbit Graph ===

def berggren_step_mod(gen: str, triple: Triple, m: int) -> Triple:
    """Apply a Berggren generator modulo m.

    Time: O(1)
    """
    a, b, c = triple
    if gen == 'A':
        return ((a - 2*b + 2*c) % m, (2*a - b + 2*c) % m, (2*a - 2*b + 3*c) % m)
    elif gen == 'B':
        return ((a + 2*b + 2*c) % m, (2*a + b + 2*c) % m, (2*a + 2*b + 3*c) % m)
    else:
        return ((-a + 2*b + 2*c) % m, (-2*a + b + 2*c) % m, (-2*a + 2*b + 3*c) % m)

def compute_modular_orbit(m: int) -> Set[Triple]:
    """Compute the reachable orbit of (3,4,5) mod m under Berggren generators.

    Uses BFS. Time: O(|orbit| * 3). Space: O(|orbit|).

    Args:
        m: The modulus

    Returns:
        Set of reachable triples mod m
    """
    root = (3 % m, 4 % m, 5 % m)
    orbit = {root}
    queue = deque([root])

    while queue:
        t = queue.popleft()
        for gen in 'ABC':
            nt = berggren_step_mod(gen, t, m)
            if nt not in orbit:
                orbit.add(nt)
                queue.append(nt)

    return orbit

def build_modular_graph(m: int) -> Dict[Triple, Dict[str, Triple]]:
    """Build the directed multigraph of the Berggren action mod m.

    Time: O(|orbit| * 3). Space: O(|orbit|).

    Returns:
        Dict mapping each vertex to its {gen: neighbor} dict
    """
    orbit = compute_modular_orbit(m)
    graph = {}
    for t in orbit:
        graph[t] = {}
        for gen in 'ABC':
            graph[t][gen] = berggren_step_mod(gen, t, m)
    return graph


def check_strong_connectivity(m: int) -> bool:
    """Check if the modular Berggren graph is strongly connected.

    Uses two BFS passes (forward and backward reachability).
    Time: O(|orbit|). Space: O(|orbit|).
    """
    graph = build_modular_graph(m)
    vertices = set(graph.keys())
    if len(vertices) <= 1:
        return True

    # Forward BFS from root
    root = (3 % m, 4 % m, 5 % m)
    forward_reached = {root}
    queue = deque([root])
    while queue:
        t = queue.popleft()
        for gen in 'ABC':
            nt = graph[t][gen]
            if nt not in forward_reached:
                forward_reached.add(nt)
                queue.append(nt)

    if forward_reached != vertices:
        return False

    # Build reverse graph
    rev_graph: Dict[Triple, Set[Triple]] = {v: set() for v in vertices}
    for v in vertices:
        for gen in 'ABC':
            rev_graph[graph[v][gen]].add(v)

    # Backward BFS from root
    backward_reached = {root}
    queue = deque([root])
    while queue:
        t = queue.popleft()
        for pred in rev_graph[t]:
            if pred not in backward_reached:
                backward_reached.add(pred)
                queue.append(pred)

    return backward_reached == vertices


# === Algorithm 3: Spectral Analysis ===

def transition_matrix(m: int) -> np.ndarray:
    """Build the transition matrix P of the random walk on the
    modular Berggren graph.

    P[i,j] = (number of generators sending vertex i to vertex j) / 3.

    Time: O(|orbit|²). Space: O(|orbit|²).

    Returns:
        (P, vertex_list) where P is the transition matrix
    """
    graph = build_modular_graph(m)
    vertices = sorted(graph.keys())
    n = len(vertices)
    idx = {v: i for i, v in enumerate(vertices)}

    P = np.zeros((n, n), dtype=np.float64)
    for v in vertices:
        i = idx[v]
        for gen in 'ABC':
            j = idx[graph[v][gen]]
            P[i, j] += 1.0 / 3.0

    return P, vertices

def spectral_gap(m: int) -> float:
    """Compute the spectral gap of the transition operator on the
    modular Berggren graph.

    The spectral gap is 1 - λ₂ where λ₂ is the second-largest
    eigenvalue magnitude.

    Time: O(|orbit|³) for eigenvalue computation.

    Returns:
        The spectral gap δ = 1 - |λ₂|
    """
    P, _ = transition_matrix(m)
    eigenvalues = np.linalg.eigvals(P)
    mags = sorted(np.abs(eigenvalues), reverse=True)

    # The largest should be ~1 (for stochastic matrix)
    return 1.0 - mags[1] if len(mags) > 1 else 1.0


if __name__ == '__main__':
    print("=== Extremal Paths (depth 8) ===")
    paths = find_extremal_paths(8, k=5)
    for word, h in paths:
        print(f"  {word:>10} → hyp = {h}")

    print("\n=== Modular Orbits and Connectivity ===")
    for p in [7, 11, 13, 17, 19, 23, 29, 31]:
        orbit = compute_modular_orbit(p)
        sc = check_strong_connectivity(p)
        gap = spectral_gap(p)
        print(f"  p={p:>2}: |orbit|={len(orbit):>4}, "
              f"strongly connected: {'✓' if sc else '✗'}, "
              f"spectral gap: {gap:.4f}")

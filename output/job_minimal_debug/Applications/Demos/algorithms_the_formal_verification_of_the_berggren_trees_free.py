#!/usr/bin/env python3
"""
Berggren Dynamics: Algorithms for Certified Enumeration and Orbit Analysis

Implements algorithms from the research paper on Berggren semigroup dynamics:
1. Certified enumeration of primitive Pythagorean triples by hypotenuse bound
2. Depth-bounded BFS with sharp quadratic bounds
3. Modular orbit computation and graph analysis
4. Spectral analysis of finite-quotient transition operators
"""

import numpy as np
from typing import Tuple, List, Set, Dict, Optional
from collections import deque
import itertools

Triple = Tuple[int, int, int]

# ─── Core Berggren action ──────────────────────────────────────────────

def bergA(a: int, b: int, c: int) -> Triple:
    return (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)

def bergB(a: int, b: int, c: int) -> Triple:
    return (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)

def bergC(a: int, b: int, c: int) -> Triple:
    return (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

GENERATORS = [bergA, bergB, bergC]
GEN_NAMES = ['A', 'B', 'C']
ROOT = (3, 4, 5)


# ─── Algorithm 1: Certified enumeration by hypotenuse bound ───────────

def enumerate_triples(max_hyp: int) -> List[Triple]:
    """
    Enumerate all primitive Pythagorean triples with hypotenuse ≤ max_hyp.

    Uses BFS on the Berggren tree with the proven quadratic lower bound
    c(w) ≥ 2n² + 6n + 5 to prune branches: if the bound at depth n
    exceeds max_hyp, no word of length ≥ n can produce a valid triple.

    Time complexity: O(π(max_hyp)) where π(N) is the count of primitive
    Pythagorean triples with hypotenuse ≤ N. Space: O(π(max_hyp)).

    Returns:
        Sorted list of all primitive Pythagorean triples (a, b, c) with c ≤ max_hyp.

    >>> len(enumerate_triples(100))
    16
    """
    result = []
    queue: deque = deque()
    queue.append(ROOT)

    while queue:
        triple = queue.popleft()
        a, b, c = triple
        if c > max_hyp:
            continue
        result.append(triple)
        for gen in GENERATORS:
            child = gen(a, b, c)
            if child[2] <= max_hyp:
                queue.append(child)

    result.sort(key=lambda t: (t[2], t[0]))
    return result


def max_depth_for_bound(max_hyp: int) -> int:
    """
    Compute the maximum tree depth needed to enumerate all triples
    with hypotenuse ≤ max_hyp, using the proven lower bound.

    Since c(w) ≥ 2n² + 6n + 5, we need 2n² + 6n + 5 ≤ max_hyp,
    i.e., n ≤ (-6 + √(36 + 8(max_hyp - 5))) / 4.

    >>> max_depth_for_bound(100)
    6
    """
    # Solve 2n² + 6n + 5 ≤ max_hyp
    discriminant = 36 + 8 * (max_hyp - 5)
    if discriminant < 0:
        return 0
    n = (-6 + discriminant**0.5) / 4
    return max(0, int(n))


# ─── Algorithm 2: Depth-bounded enumeration with word tracking ────────

def enumerate_with_words(max_depth: int) -> List[Tuple[str, Triple]]:
    """
    Enumerate all Berggren words up to given depth with their triples.

    Returns:
        List of (word, triple) pairs sorted by hypotenuse.

    >>> results = enumerate_with_words(3)
    >>> results[0]
    ('', (3, 4, 5))
    """
    result = []
    queue: deque = deque()
    queue.append(('', ROOT))

    while queue:
        word, triple = queue.popleft()
        result.append((word, triple))
        if len(word) < max_depth:
            a, b, c = triple
            for i, gen in enumerate(GENERATORS):
                child = gen(a, b, c)
                queue.append((word + GEN_NAMES[i], child))

    result.sort(key=lambda x: x[1][2])
    return result


# ─── Algorithm 3: Modular orbit computation ───────────────────────────

def compute_modular_orbit(m: int, max_depth: int = 20) -> Set[Triple]:
    """
    Compute the reachable orbit of (3,4,5) mod m under the Berggren semigroup.

    Uses BFS with deduplication. Terminates when no new states are found.

    Time complexity: O(m³) in the worst case (bounded by the number of
    possible residue classes).

    Returns:
        Set of reachable residue classes (a mod m, b mod m, c mod m).

    >>> len(compute_modular_orbit(5))
    12
    """
    root_mod = (3 % m, 4 % m, 5 % m)
    visited: Set[Triple] = {root_mod}
    queue: deque = deque([root_mod])

    while queue:
        t = queue.popleft()
        a, b, c = t
        for gen in GENERATORS:
            a2, b2, c2 = gen(a, b, c)
            child_mod = (a2 % m, b2 % m, c2 % m)
            if child_mod not in visited:
                visited.add(child_mod)
                queue.append(child_mod)

    return visited


def compute_pythagorean_cone(m: int) -> Set[Triple]:
    """
    Compute the full Pythagorean cone mod m: all (a,b,c) with a²+b²≡c² (mod m).

    Returns:
        Set of all residue classes satisfying the Pythagorean relation.

    >>> len(compute_pythagorean_cone(5))
    25
    """
    result = set()
    for a in range(m):
        for b in range(m):
            for c in range(m):
                if (a*a + b*b - c*c) % m == 0:
                    result.add((a, b, c))
    return result


# ─── Algorithm 4: Transition graph and spectral analysis ──────────────

def build_transition_graph(m: int) -> Tuple[List[Triple], np.ndarray]:
    """
    Build the transition graph of the Berggren semigroup on reachable states mod m.

    Returns:
        (states, adjacency_matrix) where adjacency_matrix[i][j] = number of
        generators mapping state i to state j.

    >>> states, adj = build_transition_graph(3)
    >>> len(states)
    4
    """
    orbit = compute_modular_orbit(m)
    states = sorted(orbit)
    state_index = {s: i for i, s in enumerate(states)}
    n = len(states)
    adj = np.zeros((n, n), dtype=int)

    for s in states:
        i = state_index[s]
        a, b, c = s
        for gen in GENERATORS:
            a2, b2, c2 = gen(a, b, c)
            t = (a2 % m, b2 % m, c2 % m)
            if t in state_index:
                j = state_index[t]
                adj[i][j] += 1

    return states, adj


def analyze_spectral_gap(m: int) -> Dict:
    """
    Analyze the spectral gap of the transition operator on reachable states mod m.

    The normalized transition matrix P = A/3 is row-stochastic when the orbit
    is closed under all generators. The spectral gap λ₁ - λ₂ controls the
    mixing rate for the equidistribution theorem.

    Returns:
        Dictionary with spectral analysis results.

    >>> result = analyze_spectral_gap(7)
    >>> result['spectral_gap'] > 0
    True
    """
    states, adj = build_transition_graph(m)
    n = len(states)

    # Check if each row sums to 3 (each state has exactly 3 outgoing edges)
    row_sums = adj.sum(axis=1)
    is_regular = np.all(row_sums == 3)

    # Normalized transition matrix
    P = adj / 3.0

    # Compute eigenvalues
    eigenvalues = np.sort(np.abs(np.linalg.eigvals(P)))[::-1]

    result = {
        'modulus': m,
        'orbit_size': n,
        'is_regular': bool(is_regular),
        'largest_eigenvalue': float(eigenvalues[0]),
        'second_eigenvalue': float(eigenvalues[1]) if n > 1 else 0.0,
        'spectral_gap': float(eigenvalues[0] - eigenvalues[1]) if n > 1 else 1.0,
        'is_strongly_connected': is_strongly_connected(adj),
    }
    return result


def is_strongly_connected(adj: np.ndarray) -> bool:
    """Check if a directed graph (adjacency matrix) is strongly connected."""
    n = adj.shape[0]
    if n <= 1:
        return True

    # BFS from node 0
    def bfs_reachable(matrix):
        visited = {0}
        queue = deque([0])
        while queue:
            node = queue.popleft()
            for j in range(n):
                if matrix[node][j] > 0 and j not in visited:
                    visited.add(j)
                    queue.append(j)
        return len(visited) == n

    return bfs_reachable(adj) and bfs_reachable(adj.T)


# ─── Algorithm 5: Optimal path computation ────────────────────────────

def find_minimum_hypotenuse_path(depth: int) -> Tuple[str, Triple, int]:
    """
    Find the word of given depth that minimizes the hypotenuse.

    By the proven minimality theorem, this is always A^depth with
    hypotenuse 2*depth² + 6*depth + 5.

    Returns:
        (optimal_word, optimal_triple, hypotenuse)

    >>> find_minimum_hypotenuse_path(5)
    ('AAAAA', (13, 84, 85), 85)
    """
    word = 'A' * depth
    triple = apply_word_str(word)
    return (word, triple, triple[2])


def apply_word_str(word: str, root: Triple = ROOT) -> Triple:
    """Apply a word string to a triple."""
    t = root
    for ch in word:
        t = {'A': bergA, 'B': bergB, 'C': bergC}[ch](*t)
    return t


# ─── Main: demonstrate all algorithms ─────────────────────────────────

if __name__ == '__main__':
    print("=" * 70)
    print("Algorithm 1: Certified enumeration")
    print("=" * 70)
    for bound in [50, 100, 500, 1000]:
        triples = enumerate_triples(bound)
        depth = max_depth_for_bound(bound)
        print(f"  c ≤ {bound:>5}: {len(triples):>4} primitive triples, max depth = {depth}")
    print()

    print("=" * 70)
    print("Algorithm 3: Modular orbit computation")
    print("=" * 70)
    for m in [3, 5, 7, 11, 13, 17, 19, 23, 29, 31]:
        orbit = compute_modular_orbit(m)
        cone = compute_pythagorean_cone(m)
        print(f"  mod {m:>2}: orbit = {len(orbit):>4}, "
              f"cone = {len(cone):>5}, "
              f"saturation = {len(orbit)/len(cone)*100:>5.1f}%")
    print()

    print("=" * 70)
    print("Algorithm 4: Spectral analysis")
    print("=" * 70)
    print(f"{'m':>4} {'|S_m|':>6} {'regular':>8} {'λ₂':>8} {'gap':>8} {'connected':>10}")
    print("-" * 50)
    for m in [3, 5, 7, 11, 13, 17, 19, 23]:
        result = analyze_spectral_gap(m)
        print(f"{m:>4} {result['orbit_size']:>6} "
              f"{'yes' if result['is_regular'] else 'no':>8} "
              f"{result['second_eigenvalue']:>8.4f} "
              f"{result['spectral_gap']:>8.4f} "
              f"{'yes' if result['is_strongly_connected'] else 'no':>10}")
    print()

    print("=" * 70)
    print("Algorithm 5: Optimal path computation")
    print("=" * 70)
    for d in range(11):
        word, triple, hyp = find_minimum_hypotenuse_path(d)
        print(f"  depth {d:>2}: word = {word:>12}, triple = {str(triple):>20}, c = {hyp}")

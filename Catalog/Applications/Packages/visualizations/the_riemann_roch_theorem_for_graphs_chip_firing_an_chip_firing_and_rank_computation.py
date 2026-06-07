#!/usr/bin/env python3
"""
Algorithms for Chip-Firing and Graph Divisor Theory

Type-hinted implementations of the key algorithms from Baker-Norine theory.
"""

from typing import Dict, List, Tuple, Set, Optional
from collections import deque
import itertools


# === Core Data Structures ===

Divisor = Dict[int, int]
Graph = Dict[int, Set[int]]  # adjacency list


def complete_graph(n: int) -> Graph:
    """Construct the complete graph K_n."""
    return {v: set(range(n)) - {v} for v in range(n)}


def divisor_degree(D: Divisor) -> int:
    """Total chip count: deg(D) = Σ_v D(v)."""
    return sum(D.values())


def is_effective(D: Divisor) -> bool:
    """Check if D(v) ≥ 0 for all v."""
    return all(val >= 0 for val in D.values())


# === Chip-Firing ===

def chip_fire(G: Graph, D: Divisor, v: int) -> Divisor:
    """Fire vertex v: sends 1 chip along each edge to neighbors.
    
    Algorithm: O(deg(v))
      D'(v) = D(v) - deg(v)
      D'(w) = D(w) + 1 for w ~ v
      D'(u) = D(u) otherwise
    """
    D_new = D.copy()
    neighbors = G[v]
    D_new[v] -= len(neighbors)
    for w in neighbors:
        D_new[w] = D_new.get(w, 0) + 1
    return D_new


def set_fire(G: Graph, D: Divisor, S: Set[int]) -> Divisor:
    """Fire an entire subset S simultaneously.
    
    For each v in S, v loses |{w ∈ S^c : w ~ v}| chips (outgoing edges)
    and gains |{w ∈ S : w ~ v, w ≠ v}| chips (incoming from S-neighbors).
    Net: D'(v) = D(v) - outdeg_S(v) for v ∈ S, D'(w) = D(w) + indeg_S(w) for w ∉ S.
    """
    D_new = D.copy()
    Sc = set(G.keys()) - S
    for v in S:
        out_edges = len(G[v] & Sc)
        D_new[v] -= out_edges
    for w in Sc:
        in_edges = len(G[w] & S)
        D_new[w] += in_edges
    return D_new


# === Canonical Divisor and Genus ===

def canonical_divisor(G: Graph) -> Divisor:
    """K_G(v) = deg(v) - 2."""
    return {v: len(neighbors) - 2 for v, neighbors in G.items()}


def graph_genus(G: Graph) -> int:
    """g = |E| - |V| + 1.
    |E| = (1/2) Σ_v deg(v) for simple graphs.
    """
    n_vertices = len(G)
    n_edges = sum(len(neighbors) for neighbors in G.values()) // 2
    return n_edges - n_vertices + 1


# === Dhar's Burning Algorithm ===

def dhars_burning(G: Graph, q: int, D: Divisor) -> Tuple[bool, Set[int]]:
    """Dhar's burning algorithm for q-reduced divisors.
    
    Starting from vertex q, "burn" outward: a vertex v ≠ q burns if
    the number of burned neighbors exceeds D(v). Continue until no
    more vertices burn.
    
    Returns (is_q_reduced, unburned_set):
      - If all vertices burn, D is q-reduced
      - Otherwise, the unburned set S can be fired to reduce D
    
    Time complexity: O(|V| + |E|)
    """
    n = len(G)
    vertices = set(G.keys())
    burned: Set[int] = {q}
    changed = True
    
    while changed:
        changed = False
        for v in vertices - burned:
            burned_neighbors = len(G[v] & burned)
            if burned_neighbors > D.get(v, 0):
                burned.add(v)
                changed = True
    
    unburned = vertices - burned
    is_reduced = len(unburned) == 0
    return is_reduced, unburned


def q_reduce(G: Graph, q: int, D: Divisor, max_iter: int = 1000) -> Divisor:
    """Compute the q-reduced divisor equivalent to D.
    
    Algorithm (Dhar's algorithm iterated):
    1. Run Dhar's burning from q
    2. If unburned set S is nonempty, fire S (moves chips toward q)
    3. Repeat until q-reduced
    
    The q-reduced representative is unique in each linear equivalence class.
    """
    D_curr = D.copy()
    for _ in range(max_iter):
        is_reduced, S = dhars_burning(G, q, D_curr)
        if is_reduced:
            return D_curr
        D_curr = set_fire(G, D_curr, S)
    return D_curr  # may not be fully reduced if max_iter exceeded


# === Divisor Rank Computation ===

def compute_rank_via_qreduction(G: Graph, D: Divisor, q: int = 0) -> int:
    """Compute r(D) using q-reduced divisors.
    
    Algorithm:
    1. q-reduce D to get D_q
    2. If D_q(q) < 0, then r(D) = -1
    3. Otherwise, r(D) = max k such that for all effective E with deg(E)=k,
       (D-E)_q has non-negative value at q.
    
    For the efficient version, we use the equivalent characterization:
    r(D) = -1 if D_q is not effective at q;
    otherwise r(D) = max k such that removing k chips from D still has
    an effective q-reduced representative.
    """
    n = len(G)
    D_red = q_reduce(G, q, D)
    
    if D_red.get(q, 0) < 0:
        return -1
    
    # Brute force: test all effective divisors of increasing degree
    rank = 0
    for k in range(1, divisor_degree(D) + 1):
        all_ok = True
        for E_vals in _weak_compositions(k, n):
            E = {v: E_vals[v] for v in range(n)}
            D_minus_E = {v: D.get(v, 0) - E.get(v, 0) for v in range(n)}
            D_red_k = q_reduce(G, q, D_minus_E)
            if D_red_k.get(q, 0) < 0:
                all_ok = False
                break
        if all_ok:
            rank = k
        else:
            break
    return rank


def _weak_compositions(k: int, n: int):
    """Generate all weak compositions of k into n non-negative parts."""
    if n == 1:
        yield [k]
        return
    for i in range(k + 1):
        for rest in _weak_compositions(k - i, n - 1):
            yield [i] + rest


# === Riemann-Roch Verification ===

def verify_riemann_roch(G: Graph, D: Divisor, q: int = 0) -> dict:
    """Verify Baker-Norine Riemann-Roch for a specific divisor.
    
    Checks: r(D) - r(K_G - D) = deg(D) + 1 - g(G)
    """
    g = graph_genus(G)
    K = canonical_divisor(G)
    KD = {v: K.get(v, 0) - D.get(v, 0) for v in G}
    
    r_D = compute_rank_via_qreduction(G, D, q)
    r_KD = compute_rank_via_qreduction(G, KD, q)
    deg_D = divisor_degree(D)
    
    lhs = r_D - r_KD
    rhs = deg_D + 1 - g
    
    return {
        'r(D)': r_D,
        'r(K-D)': r_KD,
        'deg(D)': deg_D,
        'genus': g,
        'LHS': lhs,
        'RHS': rhs,
        'verified': lhs == rhs,
    }


# === Gonality Computation ===

def compute_gonality(G: Graph, max_degree: int = 10, q: int = 0) -> int:
    """Compute the gonality: min deg(D) such that r(D) ≥ 1.
    
    Brute-force search over divisors of increasing degree.
    """
    n = len(G)
    for d in range(1, max_degree + 1):
        for D_vals in _weak_compositions(d, n):
            D = {v: D_vals[v] for v in range(n)}
            if compute_rank_via_qreduction(G, D, q) >= 1:
                return d
    return -1  # not found within budget


if __name__ == '__main__':
    # Quick test
    G = complete_graph(4)
    print(f"K_4: genus = {graph_genus(G)}")
    K = canonical_divisor(G)
    print(f"Canonical: {K}")
    print(f"r(K) = {compute_rank_via_qreduction(G, K)}")
    
    D = {0: 2, 1: 1, 2: 0, 3: 0}
    result = verify_riemann_roch(G, D)
    print(f"\nD = {D}")
    print(f"Riemann-Roch: {result}")

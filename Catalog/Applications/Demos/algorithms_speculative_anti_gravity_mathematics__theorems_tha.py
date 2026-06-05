#!/usr/bin/env python3
"""
Anti-Gravity Mathematics: Core Algorithms

Type-hinted implementations of the key algorithms for analyzing
anti-gravity structure in theorem dependency graphs.
"""

from collections import defaultdict, deque
from typing import Dict, Set, List, Tuple, Optional


def compute_reachable_set(
    adj: Dict[int, Set[int]], v: int
) -> Set[int]:
    """
    Compute the transitive closure (reachable set) from vertex v.
    
    This is the graph-theoretic analog of the 'gravitational field'
    of a theorem: all theorems that transitively depend on v.
    
    Time: O(V + E)
    """
    visited: Set[int] = {v}
    queue: deque = deque([v])
    while queue:
        u = queue.popleft()
        for w in adj.get(u, set()):
            if w not in visited:
                visited.add(w)
                queue.append(w)
    return visited


def compute_gravitational_weight(
    adj: Dict[int, Set[int]], v: int
) -> int:
    """
    Gravitational weight: |ReachableSet(v)|.
    
    High weight = foundational theorem (many results depend on it).
    Bounded above by |V| (total number of theorems).
    """
    return len(compute_reachable_set(adj, v))


def compute_proof_depth(
    adj: Dict[int, Set[int]], n: int, axioms: Set[int], target: int
) -> int:
    """
    Minimum derivation steps from axiom set to target.
    
    Returns n + 1 if target is unreachable from axioms.
    Axioms have depth 0 (they resist proof — they ARE the proof).
    
    Time: O(V + E)
    """
    if target in axioms:
        return 0
    dist: Dict[int, int] = {a: 0 for a in axioms}
    queue: deque = deque(axioms)
    while queue:
        u = queue.popleft()
        for w in adj.get(u, set()):
            if w not in dist:
                dist[w] = dist[u] + 1
                if w == target:
                    return dist[w]
                queue.append(w)
    return n + 1


def compute_anti_gravity_ratio(
    weight: int, depth: int
) -> float:
    """
    Anti-gravity ratio: weight / depth.
    
    For axioms (depth = 0), returns weight itself (maximum anti-gravity).
    High ratio = easy to prove but enormously influential.
    """
    if depth == 0:
        return float(weight)
    return weight / depth


def compute_proof_ball(
    adj: Dict[int, Set[int]], sources: Set[int], radius: int
) -> Set[int]:
    """
    Proof ball of radius k: all nodes reachable in at most k steps.
    
    ProofBall(S, 0) = S
    ProofBall(S, k+1) = ProofBall(S, k) ∪ OutNeighbors(ProofBall(S, k))
    
    Time: O(k * (V + E))
    """
    current: Set[int] = set(sources)
    for _ in range(radius):
        expansion: Set[int] = set(current)
        for v in current:
            expansion.update(adj.get(v, set()))
        current = expansion
    return current


def classify_antigravity(
    adj: Dict[int, Set[int]], n: int, axioms: Set[int],
    threshold_high: float = 5.0, threshold_moderate: float = 2.0
) -> Dict[str, List[Tuple[int, float]]]:
    """
    Classify all nodes by anti-gravity ratio.
    
    Returns dict with keys 'axiom', 'high', 'moderate', 'low',
    each mapping to list of (node, ratio) pairs.
    """
    result: Dict[str, List[Tuple[int, float]]] = {
        'axiom': [], 'high': [], 'moderate': [], 'low': []
    }
    
    for v in range(n):
        w = compute_gravitational_weight(adj, v)
        d = compute_proof_depth(adj, n, axioms, v)
        r = compute_anti_gravity_ratio(w, d)
        
        if d == 0:
            result['axiom'].append((v, r))
        elif r > threshold_high:
            result['high'].append((v, r))
        elif r > threshold_moderate:
            result['moderate'].append((v, r))
        else:
            result['low'].append((v, r))
    
    for key in result:
        result[key].sort(key=lambda x: -x[1])
    
    return result


def compute_vertex_expansion(
    adj: Dict[int, Set[int]], n: int, subset: Set[int]
) -> float:
    """
    Vertex expansion ratio: |∂S| / |S| where ∂S = OutNeighbors(S) \\ S.
    
    High expansion → rapid ball growth → anti-gravity amplification.
    Connected to spectral gap via Cheeger inequality.
    """
    if not subset:
        return 0.0
    
    boundary: Set[int] = set()
    for v in subset:
        for w in adj.get(v, set()):
            if w not in subset:
                boundary.add(w)
    
    return len(boundary) / len(subset)


def find_stabilization_time(
    adj: Dict[int, Set[int]], n: int, sources: Set[int]
) -> int:
    """
    Find the smallest k such that ProofBall(S, k) = ProofBall(S, k+1).
    
    By the finite stabilization theorem, this is at most n.
    In practice, it's often much smaller (logarithmic in expanding graphs).
    """
    current = set(sources)
    for k in range(n + 1):
        expansion = set(current)
        for v in current:
            expansion.update(adj.get(v, set()))
        if expansion == current:
            return k
        current = expansion
    return n


def compute_total_weight(
    adj: Dict[int, Set[int]], n: int
) -> int:
    """
    Total weight: sum of all node weights.
    
    Bounded above by n² (each pair (v, u) contributes at most 1).
    Bounded below by number of edges (each edge is a direct dependency).
    """
    return sum(compute_gravitational_weight(adj, v) for v in range(n))


def find_highest_antigravity_node(
    adj: Dict[int, Set[int]], n: int, axioms: Set[int]
) -> Tuple[int, float, int, int]:
    """
    Find the node with highest anti-gravity ratio.
    
    Returns (node, ratio, weight, depth).
    By the pigeonhole theorem, at least one node has weight ≥ totalWeight/n.
    """
    best: Tuple[int, float, int, int] = (0, 0.0, 0, 0)
    
    for v in range(n):
        w = compute_gravitational_weight(adj, v)
        d = compute_proof_depth(adj, n, axioms, v)
        r = compute_anti_gravity_ratio(w, d)
        if r > best[1]:
            best = (v, r, w, d)
    
    return best


if __name__ == "__main__":
    import random
    random.seed(42)
    
    # Build example DAG
    n = 30
    adj: Dict[int, Set[int]] = defaultdict(set)
    for i in range(n):
        for j in range(i + 1, n):
            if random.random() < 0.15:
                adj[i].add(j)
    
    axioms = {0, 1, 2}
    
    print("Anti-Gravity Analysis of Random DAG")
    print(f"  n = {n}, axioms = {axioms}")
    print(f"  Total weight: {compute_total_weight(adj, n)}")
    print(f"  Weight bound (n²): {n**2}")
    
    best = find_highest_antigravity_node(adj, n, axioms)
    print(f"  Highest AG node: {best[0]} (ratio={best[1]:.2f}, w={best[2]}, d={best[3]})")
    
    classes = classify_antigravity(adj, n, axioms)
    for cls, nodes in classes.items():
        print(f"  {cls}: {len(nodes)} nodes")
    
    stab = find_stabilization_time(adj, n, axioms)
    print(f"  Stabilization time: {stab}")

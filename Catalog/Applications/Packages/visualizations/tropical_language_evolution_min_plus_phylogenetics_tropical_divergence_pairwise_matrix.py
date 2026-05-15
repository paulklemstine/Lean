"""
Tropical Phylogenetics: Algorithms
====================================

Optimized implementations of the core algorithms from the research paper,
with docstrings, type hints, and example usage.
"""

import numpy as np
from typing import List, Tuple, Optional, Dict
from dataclasses import dataclass
import itertools


# ============================================================
# Core Distance Functions
# ============================================================

def tropical_divergence(L1: np.ndarray, L2: np.ndarray) -> float:
    """Compute the L¹ tropical divergence between two language profiles.
    
    Args:
        L1: Language profile, shape (n_items,)
        L2: Language profile, shape (n_items,)
    
    Returns:
        The L¹ distance sum_i |L1[i] - L2[i]|
    
    Complexity: O(n_items) time, O(1) space.
    
    Example:
        >>> L1 = np.array([1.0, 2.0, 3.0])
        >>> L2 = np.array([1.5, 1.0, 4.0])
        >>> tropical_divergence(L1, L2)
        2.5
    """
    return float(np.sum(np.abs(L1 - L2)))


def pairwise_divergence_matrix(languages: np.ndarray) -> np.ndarray:
    """Compute all pairwise tropical divergences.
    
    Args:
        languages: Array of shape (n_languages, n_items)
    
    Returns:
        Symmetric matrix of shape (n_languages, n_languages)
    
    Complexity: O(n_languages² × n_items)
    
    Example:
        >>> langs = np.array([[1, 2, 3], [2, 1, 4], [1.5, 1.5, 3.5]])
        >>> pairwise_divergence_matrix(langs)
    """
    n = len(languages)
    D = np.zeros((n, n))
    for i in range(n):
        for j in range(i + 1, n):
            d = tropical_divergence(languages[i], languages[j])
            D[i, j] = d
            D[j, i] = d
    return D


# ============================================================
# Ancestral Reconstruction
# ============================================================

def coord_median(profiles: np.ndarray) -> np.ndarray:
    """Compute the coordinatewise median of multiple language profiles.
    
    For an odd number of profiles, this is the unique minimizer
    of total L¹ divergence. For an even number, any point in the
    median interval suffices.
    
    Args:
        profiles: Array of shape (n_profiles, n_items)
    
    Returns:
        Median profile of shape (n_items,)
    
    Complexity: O(n_profiles × n_items × log(n_profiles))
    
    Example:
        >>> profiles = np.array([[1, 5, 2], [3, 2, 6], [2, 4, 3]])
        >>> coord_median(profiles)
        array([2., 4., 3.])
    """
    return np.median(profiles, axis=0)


def optimal_ancestor_3(A: np.ndarray, B: np.ndarray, C: np.ndarray) -> np.ndarray:
    """Reconstruct the optimal common ancestor of three languages.
    
    The coordinatewise median minimizes total tropical divergence
    to all three descendants (Theorem 7 in the paper).
    
    Args:
        A, B, C: Language profiles, shape (n_items,)
    
    Returns:
        Optimal ancestor profile
    
    Complexity: O(n_items)
    """
    return np.median(np.stack([A, B, C]), axis=0)


def total_divergence_to_point(profiles: np.ndarray, point: np.ndarray) -> float:
    """Total tropical divergence from a point to all given profiles.
    
    Args:
        profiles: Array of shape (n_profiles, n_items)
        point: Single profile of shape (n_items,)
    
    Returns:
        Sum of divergences from point to each profile
    """
    return sum(tropical_divergence(p, point) for p in profiles)


# ============================================================
# Glottochronological Dating
# ============================================================

def glotto_date(L1: np.ndarray, L2: np.ndarray, rho: float) -> float:
    """Estimate divergence time using glottochronological formula.
    
    Under uniform drift rate rho, the divergence time is
    d_trop(L1, L2) / rho.
    
    Args:
        L1, L2: Language profiles
        rho: Lexical drift rate (> 0)
    
    Returns:
        Estimated divergence time
    
    Complexity: O(n_items)
    
    Example:
        >>> L1 = np.array([2.0, 1.5, 0.5])
        >>> L2 = np.array([1.0, 0.5, 1.5])
        >>> glotto_date(L1, L2, rho=0.5)
        6.0
    """
    assert rho > 0, "Drift rate must be positive"
    return tropical_divergence(L1, L2) / rho


def date_all_pairs(languages: np.ndarray, rho: float) -> np.ndarray:
    """Compute pairwise divergence times for all language pairs.
    
    Args:
        languages: Array of shape (n_languages, n_items)
        rho: Drift rate
    
    Returns:
        Matrix of divergence times, shape (n_languages, n_languages)
    """
    D = pairwise_divergence_matrix(languages)
    return D / rho


# ============================================================
# Four-Point Condition Testing
# ============================================================

@dataclass
class QuartetResult:
    """Result of a quartet four-point test."""
    holds: bool
    sums: Tuple[float, float, float]
    topology: str  # "ab|cd", "ac|bd", "ad|bc", or "star"
    
    def __repr__(self):
        return (f"QuartetResult(holds={self.holds}, "
                f"sums={tuple(round(s, 4) for s in self.sums)}, "
                f"topology='{self.topology}')")


def quartet_test(a: np.ndarray, b: np.ndarray,
                 c: np.ndarray, d: np.ndarray,
                 tol: float = 1e-10) -> QuartetResult:
    """Test the four-point condition and determine quartet topology.
    
    For four languages, determines:
    1. Whether the four-point condition holds
    2. The inferred tree topology (which pair is separated)
    
    The topology ab|cd means a,b are on one side and c,d on the other.
    
    Args:
        a, b, c, d: Language profiles
        tol: Numerical tolerance
    
    Returns:
        QuartetResult with test outcome and inferred topology
    
    Complexity: O(n_items)
    """
    s1 = tropical_divergence(a, b) + tropical_divergence(c, d)  # ab|cd
    s2 = tropical_divergence(a, c) + tropical_divergence(b, d)  # ac|bd
    s3 = tropical_divergence(a, d) + tropical_divergence(b, c)  # ad|bc
    
    sums = (s1, s2, s3)
    holds = (s1 <= max(s2, s3) + tol and 
             s2 <= max(s1, s3) + tol and 
             s3 <= max(s1, s2) + tol)
    
    # Determine topology: the minimum sum indicates the split
    min_sum = min(sums)
    if abs(s1 - min_sum) < tol:
        topology = "ab|cd"
    elif abs(s2 - min_sum) < tol:
        topology = "ac|bd"
    else:
        topology = "ad|bc"
    
    # Check for star topology (all sums approximately equal)
    if abs(s1 - s2) < tol and abs(s2 - s3) < tol:
        topology = "star"
    
    return QuartetResult(holds=holds, sums=sums, topology=topology)


def test_four_point_matrix(languages: np.ndarray, 
                           tol: float = 1e-10) -> Dict[str, int]:
    """Test four-point condition for all quartets in a language family.
    
    Args:
        languages: Array of shape (n_languages, n_items)
        tol: Numerical tolerance
    
    Returns:
        Dictionary with counts of passing/failing quartets
    """
    n = len(languages)
    results = {"pass": 0, "fail": 0, "total": 0}
    
    for combo in itertools.combinations(range(n), 4):
        i, j, k, l = combo
        result = quartet_test(languages[i], languages[j], 
                             languages[k], languages[l], tol)
        results["total"] += 1
        if result.holds:
            results["pass"] += 1
        else:
            results["fail"] += 1
    
    return results


# ============================================================
# Tree Reconstruction
# ============================================================

@dataclass
class PhyloTree:
    """A simple phylogenetic tree."""
    n_leaves: int
    edges: List[Tuple[int, int]]  # (parent, child) pairs
    edge_weights: List[float]
    leaf_labels: Optional[List[str]] = None
    
    def path_distance(self, i: int, j: int) -> float:
        """Compute path distance between leaves i and j."""
        # Build adjacency with weights
        adj: Dict[int, List[Tuple[int, float]]] = {}
        for (u, v), w in zip(self.edges, self.edge_weights):
            adj.setdefault(u, []).append((v, w))
            adj.setdefault(v, []).append((u, w))
        
        # BFS from i to j
        from collections import deque
        visited = {i: 0.0}
        queue = deque([i])
        while queue:
            u = queue.popleft()
            if u == j:
                return visited[j]
            for v, w in adj.get(u, []):
                if v not in visited:
                    visited[v] = visited[u] + w
                    queue.append(v)
        return float('inf')


def neighbor_joining(D: np.ndarray, labels: Optional[List[str]] = None) -> PhyloTree:
    """Neighbor-joining algorithm for tree reconstruction from distance matrix.
    
    Given a distance matrix satisfying the four-point condition,
    reconstructs the unique additive tree.
    
    Args:
        D: Distance matrix of shape (n, n)
        labels: Optional leaf labels
    
    Returns:
        PhyloTree object
    
    Complexity: O(n³) time
    """
    n = len(D)
    if labels is None:
        labels = [str(i) for i in range(n)]
    
    # Working copies
    D_work = D.copy()
    active = list(range(n))
    edges = []
    weights = []
    next_node = n
    
    while len(active) > 2:
        m = len(active)
        # Compute Q matrix
        row_sums = np.array([sum(D_work[active[i], active[j]] 
                                for j in range(m)) for i in range(m)])
        
        Q = np.full((m, m), float('inf'))
        best_val = float('inf')
        best_i, best_j = 0, 1
        
        for i in range(m):
            for j in range(i + 1, m):
                q = (m - 2) * D_work[active[i], active[j]] - row_sums[i] - row_sums[j]
                Q[i, j] = q
                if q < best_val:
                    best_val = q
                    best_i, best_j = i, j
        
        # Join best_i and best_j
        u, v = active[best_i], active[best_j]
        new_node = next_node
        next_node += 1
        
        # Edge weights
        d_uv = D_work[u, v]
        if m > 2:
            w_u = d_uv / 2 + (row_sums[best_i] - row_sums[best_j]) / (2 * (m - 2))
        else:
            w_u = d_uv / 2
        w_v = d_uv - w_u
        
        edges.append((new_node, u))
        weights.append(max(0, w_u))
        edges.append((new_node, v))
        weights.append(max(0, w_v))
        
        # Update distance matrix
        new_D = np.zeros((next_node, next_node))
        new_D[:D_work.shape[0], :D_work.shape[1]] = D_work
        
        for k_idx in range(m):
            k = active[k_idx]
            if k != u and k != v:
                d_new = (D_work[u, k] + D_work[v, k] - d_uv) / 2
                new_D[new_node, k] = d_new
                new_D[k, new_node] = d_new
        
        D_work = new_D
        active = [a for a in active if a != u and a != v] + [new_node]
    
    # Final edge
    if len(active) == 2:
        u, v = active
        edges.append((u, v))
        weights.append(D_work[u, v])
    
    return PhyloTree(n_leaves=n, edges=edges, edge_weights=weights, 
                     leaf_labels=labels)


# ============================================================
# Tree Evolution Simulation
# ============================================================

def simulate_tree_evolution(tree: PhyloTree, 
                           root_lang: np.ndarray,
                           rng: np.random.RandomState = None) -> np.ndarray:
    """Simulate lexical evolution along a phylogenetic tree.
    
    Each edge contributes a nonneg additive drift vector
    with magnitude proportional to edge weight.
    
    Args:
        tree: The tree topology with edge weights
        root_lang: Language profile at the root
        rng: Random state for reproducibility
    
    Returns:
        Array of leaf language profiles, shape (n_leaves, n_items)
    """
    if rng is None:
        rng = np.random.RandomState(42)
    
    n_items = len(root_lang)
    
    # Build adjacency
    adj: Dict[int, List[Tuple[int, float]]] = {}
    for (u, v), w in zip(tree.edges, tree.edge_weights):
        adj.setdefault(u, []).append((v, w))
        adj.setdefault(v, []).append((u, w))
    
    # Find root (highest-numbered internal node)
    all_nodes = set()
    for u, v in tree.edges:
        all_nodes.add(u)
        all_nodes.add(v)
    root = max(all_nodes)
    
    # BFS from root
    from collections import deque
    profiles: Dict[int, np.ndarray] = {root: root_lang.copy()}
    visited = {root}
    queue = deque([root])
    
    while queue:
        u = queue.popleft()
        for v, w in adj.get(u, []):
            if v not in visited:
                visited.add(v)
                # Add nonneg drift proportional to edge weight
                drift = rng.exponential(scale=w / n_items, size=n_items)
                profiles[v] = profiles[u] + drift
                queue.append(v)
    
    # Collect leaf profiles
    leaf_profiles = np.array([profiles[i] for i in range(tree.n_leaves)])
    return leaf_profiles


# ============================================================
# Betweenness Verification
# ============================================================

def verify_betweenness_on_tree(tree: PhyloTree, 
                                profiles: Dict[int, np.ndarray]) -> bool:
    """Verify that all internal nodes satisfy the betweenness condition
    with respect to their subtree leaves.
    
    Args:
        tree: The tree topology
        profiles: Language profiles for all nodes
    
    Returns:
        True if betweenness holds everywhere
    """
    for (u, v), w in zip(tree.edges, tree.edge_weights):
        if u in profiles and v in profiles:
            parent_prof = profiles[u]
            child_prof = profiles[v]
            # Check that each coordinate of child is >= parent
            # (for nonneg drift model)
            diff = child_prof - parent_prof
            if np.any(diff < -1e-10):
                return False
    return True


# ============================================================
# Example Usage
# ============================================================

if __name__ == "__main__":
    print("Tropical Phylogenetics: Algorithm Examples")
    print("=" * 50)
    
    # Example 1: Pairwise divergences
    print("\n--- Pairwise Divergence Matrix ---")
    languages = np.array([
        [2.1, 1.8, 0.5, 2.3, 1.4],  # French
        [1.3, 1.2, 0.3, 1.5, 0.8],  # Spanish
        [1.5, 1.0, 0.4, 1.8, 1.1],  # Italian
        [2.5, 2.0, 0.6, 2.8, 1.6],  # Romanian
    ])
    labels = ["French", "Spanish", "Italian", "Romanian"]
    
    D = pairwise_divergence_matrix(languages)
    print(f"  {'':>10}", end="")
    for l in labels:
        print(f" {l:>10}", end="")
    print()
    for i, l in enumerate(labels):
        print(f"  {l:>10}", end="")
        for j in range(len(labels)):
            print(f" {D[i,j]:>10.2f}", end="")
        print()
    
    # Example 2: Quartet test
    print("\n--- Quartet Tests ---")
    for combo in itertools.combinations(range(4), 4):
        i, j, k, l = combo
        result = quartet_test(languages[i], languages[j],
                             languages[k], languages[l])
        print(f"  {labels[i]}-{labels[j]}-{labels[k]}-{labels[l]}: "
              f"holds={result.holds}, topology={result.topology}")
    
    # Example 3: Ancestral reconstruction
    print("\n--- Ancestral Reconstruction ---")
    ancestor = optimal_ancestor_3(languages[0], languages[1], languages[2])
    print(f"  Median of French, Spanish, Italian: {np.round(ancestor, 2)}")
    
    # Example 4: Neighbor-joining
    print("\n--- Neighbor-Joining Tree ---")
    tree = neighbor_joining(D, labels)
    print(f"  Edges: {tree.edges}")
    print(f"  Weights: {[round(w, 3) for w in tree.edge_weights]}")
    
    # Example 5: Dating
    print("\n--- Glottochronological Dating ---")
    rho = 0.5
    dates = date_all_pairs(languages, rho)
    for i in range(len(labels)):
        for j in range(i + 1, len(labels)):
            print(f"  {labels[i]}-{labels[j]}: {dates[i,j]:.1f} millennia")

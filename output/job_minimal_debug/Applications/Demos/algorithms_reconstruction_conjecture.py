"""
Reconstruction Conjecture — Core Algorithms

Type-hinted implementations of key algorithms for graph reconstruction
from vertex-deleted subgraphs (the "deck").
"""

from typing import List, Dict, Set, Tuple, FrozenSet
from collections import Counter
from itertools import combinations
import math


# --- Graph representation ---

class Graph:
    """Simple undirected graph on vertices {0, 1, ..., n-1}."""

    def __init__(self, n: int, edges: List[Tuple[int, int]]):
        self.n = n
        self.adj: Dict[int, Set[int]] = {v: set() for v in range(n)}
        self.edges: Set[FrozenSet[int]] = set()
        for u, v in edges:
            if u != v:
                self.adj[u].add(v)
                self.adj[v].add(u)
                self.edges.add(frozenset({u, v}))

    def degree(self, v: int) -> int:
        return len(self.adj[v])

    def degree_sequence(self) -> List[int]:
        return sorted([self.degree(v) for v in range(self.n)], reverse=True)

    def edge_count(self) -> int:
        return len(self.edges)

    def __repr__(self) -> str:
        return f"Graph(n={self.n}, edges={len(self.edges)})"


# --- Deck Construction ---

def vertex_deleted_subgraph(G: Graph, v: int) -> Graph:
    """
    Construct G - v: the graph obtained by deleting vertex v
    and all its incident edges.

    Returns a Graph on n-1 vertices with relabeled vertices.
    """
    # Map old vertices to new labels (skip v)
    label_map: Dict[int, int] = {}
    new_label = 0
    for u in range(G.n):
        if u != v:
            label_map[u] = new_label
            new_label += 1

    new_edges: List[Tuple[int, int]] = []
    for e in G.edges:
        endpoints = list(e)
        if v not in endpoints:
            new_edges.append((label_map[endpoints[0]], label_map[endpoints[1]]))

    return Graph(G.n - 1, new_edges)


def compute_deck(G: Graph) -> List[Graph]:
    """Compute the full deck of G: all vertex-deleted subgraphs."""
    return [vertex_deleted_subgraph(G, v) for v in range(G.n)]


# --- Edge Count Reconstruction ---

def reconstruct_edge_count(deck: List[Graph], n: int) -> int:
    """
    Reconstruct the number of edges from the deck.

    Formula: |E(G)| = (∑ |E(G_v)|) / (n - 2)

    Each edge {a,b} appears in exactly n-2 cards (all except G_a and G_b).
    """
    if n < 3:
        raise ValueError("Need at least 3 vertices for reconstruction")
    total_deck_edges = sum(card.edge_count() for card in deck)
    assert total_deck_edges % (n - 2) == 0, "Edge sum must be divisible by n-2"
    return total_deck_edges // (n - 2)


# --- Degree Sequence Reconstruction ---

def reconstruct_degree_sequence(deck: List[Graph], n: int) -> List[int]:
    """
    Reconstruct the degree sequence from the deck.

    For each vertex v (card index i):
      deg(v) = |E(G)| - |E(G_v)|

    This recovers the full degree sequence.
    """
    total_edges = reconstruct_edge_count(deck, n)
    degrees = [total_edges - card.edge_count() for card in deck]
    return sorted(degrees, reverse=True)


# --- Kelly's Lemma (Edge Version) ---

def verify_kelly_edge_identity(G: Graph) -> bool:
    """
    Verify Kelly's lemma for edges:
      (n - 2) * |E(G)| = ∑_v |E(G_v)|
    """
    deck = compute_deck(G)
    lhs = (G.n - 2) * G.edge_count()
    rhs = sum(card.edge_count() for card in deck)
    return lhs == rhs


# --- DeckFingerprint ---

def compute_deck_fingerprint(G: Graph) -> Dict:
    """
    Compute the DeckFingerprint of a graph — a compact invariant
    capturing the sorted edge-count profile of the deck.

    Two graphs with different fingerprints cannot be isomorphic.
    """
    deck = compute_deck(G)
    edge_counts = sorted([card.edge_count() for card in deck])
    total_edges = G.edge_count()

    return {
        "vertex_count": G.n,
        "edge_count": total_edges,
        "deck_edge_counts": edge_counts,
        "consistency_check": sum(edge_counts) == (G.n - 2) * total_edges,
        "degree_sequence": reconstruct_degree_sequence(deck, G.n),
        "is_regular": len(set(edge_counts)) == 1,
    }


# --- Regularity Detection ---

def detect_regularity_from_deck(deck: List[Graph], n: int) -> Tuple[bool, int]:
    """
    Detect if a graph is regular from its deck.

    Theorem: G is regular ⟺ all deck cards have the same edge count.

    Returns (is_regular, k) where k is the regularity parameter.
    """
    edge_counts = [card.edge_count() for card in deck]
    is_regular = len(set(edge_counts)) == 1
    if is_regular:
        total_edges = reconstruct_edge_count(deck, n)
        k = total_edges - edge_counts[0]
        return True, k
    return False, -1


# --- Complement Reconstruction ---

def reconstruct_complement_edges(deck: List[Graph], n: int) -> int:
    """
    Reconstruct the edge count of the complement graph.

    |E(Gᶜ)| = n*(n-1)/2 - |E(G)|
    """
    total_edges = reconstruct_edge_count(deck, n)
    max_edges = n * (n - 1) // 2
    return max_edges - total_edges


# --- Naive Graph Isomorphism Check ---

def are_isomorphic(G1: Graph, G2: Graph) -> bool:
    """
    Check if two small graphs are isomorphic by brute force.
    Only feasible for small graphs (n ≤ 10).
    """
    if G1.n != G2.n or G1.edge_count() != G2.edge_count():
        return False
    if sorted(G1.degree_sequence()) != sorted(G2.degree_sequence()):
        return False

    from itertools import permutations
    for perm in permutations(range(G1.n)):
        match = True
        for e in G1.edges:
            u, v = list(e)
            if frozenset({perm[u], perm[v]}) not in G2.edges:
                match = False
                break
        if match:
            # Check that no extra edges in G2
            for e in G2.edges:
                u, v = list(e)
                inv_perm = [0] * G2.n
                for i, p in enumerate(perm):
                    inv_perm[p] = i
                if frozenset({inv_perm[u], inv_perm[v]}) not in G1.edges:
                    match = False
                    break
            if match:
                return True
    return False


# --- Reconstruction Verification ---

def verify_reconstruction(G: Graph) -> Dict:
    """
    Verify that reconstruction works correctly for a given graph:
    1. Compute the deck
    2. Reconstruct edge count and degree sequence
    3. Compare with ground truth
    """
    if G.n < 3:
        return {"error": "Need at least 3 vertices"}

    deck = compute_deck(G)
    reconstructed_edges = reconstruct_edge_count(deck, G.n)
    reconstructed_degrees = reconstruct_degree_sequence(deck, G.n)
    kelly_holds = verify_kelly_edge_identity(G)

    return {
        "graph": repr(G),
        "true_edge_count": G.edge_count(),
        "reconstructed_edge_count": reconstructed_edges,
        "edge_count_correct": reconstructed_edges == G.edge_count(),
        "true_degree_sequence": G.degree_sequence(),
        "reconstructed_degree_sequence": reconstructed_degrees,
        "degree_sequence_correct": reconstructed_degrees == G.degree_sequence(),
        "kelly_identity_holds": kelly_holds,
        "fingerprint": compute_deck_fingerprint(G),
    }

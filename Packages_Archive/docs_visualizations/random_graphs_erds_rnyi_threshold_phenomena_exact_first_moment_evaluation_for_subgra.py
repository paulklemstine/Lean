from __future__ import annotations
import math

def expected_subgraph_count(num_copies: int, p: float, edges_per_copy: int) -> float:
    """First moment for uniform subgraph counts (expectation_subgraphCount_uniform):
    E[#copies] = num_copies * p ** edges_per_copy."""
    return num_copies * p ** edges_per_copy

def expected_edges(n: int, p: float) -> float:
    """E[#edges] = C(n,2) * p  (expected_edges)."""
    return expected_subgraph_count(math.comb(n, 2), p, 1)

def expected_triangles(n: int, p: float) -> float:
    """E[#triangles] = C(n,3) * p^3  (expected_triangles)."""
    return expected_subgraph_count(math.comb(n, 3), p, 3)

def expected_isolated(n: int, p: float) -> float:
    """E[#isolated vertices] = n * (1-p)^(n-1)  (expected_isolated).
    Uses the all-ABSENT independence identity (1-p)^|S| with |S| = n-1."""
    return n * (1.0 - p) ** (n - 1)

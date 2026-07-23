from __future__ import annotations
from typing import List, Tuple

def edge_count_from_spectrum(spectrum: List[float]) -> int:
    """|E(G)| = (1/2) sum lambda^2 (trace of A^2 = 2|E|)."""
    return round(sum(x * x for x in spectrum) / 2)

def spanning_tree_lower_bound(n_vertices: int, connected: bool) -> int:
    """Minimum possible edge count of a connected graph on n vertices."""
    if not connected:
        raise ValueError("bound applies to connected graphs")
    return n_vertices - 1  # attained by any spanning tree, e.g. the path

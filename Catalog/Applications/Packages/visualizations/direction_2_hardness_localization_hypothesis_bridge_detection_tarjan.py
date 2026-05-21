import networkx as nx
from typing import Set, Tuple

def compute_bridges(G: nx.Graph) -> Set[Tuple[int, int]]:
    """Compute all bridge edges in O(|V|+|E|) using Tarjan's algorithm."""
    return set(nx.bridges(G))

# Example
G = nx.cycle_graph(5)
print(f"Bridges in C5: {compute_bridges(G)}")
G.add_edge(0, 5)  # Add pendant edge
print(f"Bridges after adding pendant: {compute_bridges(G)}")

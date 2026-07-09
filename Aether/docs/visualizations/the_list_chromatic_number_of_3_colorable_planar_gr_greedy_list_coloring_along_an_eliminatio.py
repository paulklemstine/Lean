from typing import Dict, List, Sequence, Set, Tuple

Vertex = Tuple[str, int]

def greedy_list_coloring(
    order: Sequence[Vertex],
    neighbors: Dict[Vertex, Sequence[Vertex]],
    lists: Dict[Vertex, Set[int]],
) -> Dict[Vertex, int]:
    """Greedily color along `order`; guaranteed to succeed when every vertex has
    fewer back-neighbors than its list size (the (d+1)-choosability bound)."""
    color: Dict[Vertex, int] = {}
    for v in order:
        forbidden = {color[u] for u in neighbors[v] if u in color}
        color[v] = min(c for c in sorted(lists[v]) if c not in forbidden)
    return color

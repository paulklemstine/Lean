from __future__ import annotations

def greedy_coloring_bound(adjacency: dict[int, set[int]], subset: set[int]) -> int:
    order = sorted(subset, key=lambda v: (-len(adjacency[v] & subset), v))
    colors: dict[int, int] = {}
    for v in order:
        forbidden = {colors[w] for w in adjacency[v] if w in colors}
        color = 0
        while color in forbidden:
            color += 1
        colors[v] = color
    return 0 if not colors else 1 + max(colors.values())

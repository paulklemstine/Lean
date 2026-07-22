from __future__ import annotations

def seed_reducible(adjacency: dict[int, set[int]], seed: set[int], current: set[int], incumbent: int) -> bool:
    common = {x for x in current if all(d in adjacency[x] for d in seed)}
    order = sorted(common, key=lambda v: -len(adjacency[v] & common))
    colors: dict[int, int] = {}
    for v in order:
        used = {colors[w] for w in adjacency[v] if w in colors}
        colors[v] = next(c for c in range(len(common) + 1) if c not in used)
    bound = 0 if not colors else max(colors.values()) + 1
    return len(seed) + bound <= incumbent

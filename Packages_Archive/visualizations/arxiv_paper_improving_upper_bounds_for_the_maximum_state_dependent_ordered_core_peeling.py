from __future__ import annotations

def peel(adjacency: dict[int, set[int]], incumbent: int) -> tuple[set[int], list[int]]:
    current, removed = set(adjacency), []
    while True:
        chosen = None
        for v in sorted(current):
            local = adjacency[v] & current
            colors: dict[int, int] = {}
            for x in sorted(local, key=lambda y: -len(adjacency[y] & local)):
                used = {colors[y] for y in adjacency[x] if y in colors}
                colors[x] = next(c for c in range(len(local) + 1) if c not in used)
            bound = 0 if not colors else max(colors.values()) + 1
            if 1 + bound <= incumbent:
                chosen = v
                break
        if chosen is None:
            return current, removed
        current.remove(chosen)
        removed.append(chosen)

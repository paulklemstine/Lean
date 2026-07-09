from collections import deque
from typing import Callable

Mat = tuple[int, int, int, int]
Vec = tuple[int, int]

def _act(m: Mat, v: Vec) -> Vec:
    a, b, c, d = m
    x, y = v
    return (a * x + b * y, c * x + d * y)

def orbit_bfs(seed: Vec, generators: list[Mat],
              in_region: Callable[[Vec], bool]) -> set[Vec]:
    seen: set[Vec] = {seed}
    queue: deque[Vec] = deque([seed])
    while queue:
        v = queue.popleft()
        for g in generators:
            w = _act(g, v)
            if in_region(w) and w not in seen:
                seen.add(w)
                queue.append(w)
    return seen

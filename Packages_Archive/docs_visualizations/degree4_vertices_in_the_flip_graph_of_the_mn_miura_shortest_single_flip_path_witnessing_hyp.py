from typing import List, Tuple

Cfg = Tuple[bool, ...]

def shortest_flip_path(a: Cfg, b: Cfg) -> List[Cfg]:
    path, cur = [a], a
    for i in range(len(a)):
        if cur[i] != b[i]:
            cur = tuple(not x if j == i else x for j, x in enumerate(cur))
            path.append(cur)
    assert path[-1] == b  # flipGraph_connected
    return path

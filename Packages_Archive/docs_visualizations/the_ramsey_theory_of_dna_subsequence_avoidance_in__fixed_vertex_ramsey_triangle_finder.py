from typing import Dict, List, Optional, Tuple

def monochromatic_triangle(color: List[List[bool]]) -> Optional[Tuple[int, int, int, bool]]:
    """Fixed-vertex pigeonhole triangle finder for R(3,3) <= 6.
    Buckets vertex 0's neighbors by edge color; a color class of size >= 3
    (guaranteed among five edges over two colors) yields a monochromatic
    triangle either through vertex 0 or among the three neighbors."""
    n = len(color)
    buckets: Dict[bool, List[int]] = {True: [], False: []}
    for k in range(1, n):
        buckets[color[0][k]].append(k)
    for x, nbrs in buckets.items():
        if len(nbrs) >= 3:
            a, b, d = nbrs[0], nbrs[1], nbrs[2]
            if color[a][b] == x: return (0, a, b, x)
            if color[a][d] == x: return (0, a, d, x)
            if color[b][d] == x: return (0, b, d, x)
            return (a, b, d, not x)
    return None

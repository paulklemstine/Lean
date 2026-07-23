from typing import Dict, Optional, Set

Graph = Dict[int, Set[int]]


def certified_collapse(g: Graph) -> Optional[int]:
    """
    Linear-time certificate.  Returns:
      0    if some vertex is isolated (no STRDF exists),
      1    if some vertex has degree exactly 1 (leaf collapse: d_stR = 1),
      None if neither certificate applies (value not decided by this test).
    """
    degs = {v: len(g[v]) for v in g}
    if any(d == 0 for d in degs.values()):
        return 0
    if any(d == 1 for d in degs.values()):
        return 1
    return None

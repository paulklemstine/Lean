from typing import List, Optional

def changes_count(coloring: List[bool], n: int) -> int:
    """Number of bichromatic edges among the first n edges (Lean `changes`)."""
    return sum(1 for i in range(n) if coloring[i] != coloring[i + 1])

def sperner_locate_change(coloring: List[bool]) -> Optional[int]:
    """Sperner change-locator. By `sperner_parity` the change count is odd
    whenever the endpoints differ, so by `sperner_exists_change` a witness
    edge must exist; this O(n) scan returns the first such edge index."""
    n = len(coloring) - 1
    if coloring[0] == coloring[n]:
        # even number of changes (possibly zero) — parity does not force one
        return next((i for i in range(n) if coloring[i] != coloring[i + 1]), None)
    # endpoints differ -> odd count -> guaranteed witness
    for i in range(n):
        if coloring[i] != coloring[i + 1]:
            return i
    raise AssertionError("unreachable: parity guarantees a change")

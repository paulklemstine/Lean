from typing import Callable, List

def level_labels(succ: Callable[[int], List[int]], root: int, depth: int) -> List[int]:
    """Return the ordered label list at a given depth by iterated flat-map."""
    labels: List[int] = [root]
    for _ in range(depth):
        nxt: List[int] = []
        for lab in labels:
            nxt.extend(succ(lab))
        labels = nxt
    return labels

def level_count(succ: Callable[[int], List[int]], root: int, depth: int) -> int:
    """Number of nodes at a given depth (length of the level label list)."""
    return len(level_labels(succ, root, depth))

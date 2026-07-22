from typing import Callable, TypeVar

L = TypeVar("L")


def level_labels(succ: Callable[[L], list[L]], root: L, k: int) -> list[L]:
    """Unfold a generating tree to depth k, returning the ordered label list.

    Realizes  level(0) = [root],  level(j+1) = flatMap(succ, level(j)).
    """
    level: list[L] = [root]
    for _ in range(k):
        nxt: list[L] = []
        for a in level:
            nxt.extend(succ(a))
        level = nxt
    return level


def counting_sequence(succ: Callable[[L], list[L]], root: L, kmax: int) -> list[int]:
    """Return [c_0, c_1, ..., c_kmax] where c_k is the number of depth-k nodes."""
    return [len(level_labels(succ, root, k)) for k in range(kmax + 1)]

from typing import Callable, List

Compress = Callable[[int, int], int]

def merkle_damgard(f: Compress, iv: int, msg: List[int]) -> int:
    """Iterated hash: left fold of blocks into iv using f."""
    state: int = iv
    for block in msg:
        state = f(state, block)
    return state

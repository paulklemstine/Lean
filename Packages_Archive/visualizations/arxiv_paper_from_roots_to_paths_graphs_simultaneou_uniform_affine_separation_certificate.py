from typing import Sequence, Tuple

def certify(intercepts: Sequence[Sequence[int]], slopes: Sequence[Sequence[int]]) -> Tuple[int,bool]:
    bound=max(max(row) for row in intercepts)
    injective=all(len(row)==len(set(row)) for row in slopes)
    return bound+1,injective

from typing import Iterable

def transfer_lower_bound(W: Iterable[int], x: int) -> int:
    W = list(W)
    for w in W:
        if not (1 <= w <= x):
            raise ValueError(f'witness {w} out of range [1, {x}]')
        if totient(w) != totient(w + 1):
            raise ValueError(f'{w} is not a collision')
    return len(set(W))

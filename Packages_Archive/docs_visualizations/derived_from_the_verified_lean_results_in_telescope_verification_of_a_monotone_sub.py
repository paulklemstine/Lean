from math import prod
from typing import FrozenSet, Sequence, Tuple, List

Perm = Tuple[int, ...]

def relative_index(h_small: FrozenSet[Perm], h_big: FrozenSet[Perm]) -> int:
    assert h_small <= h_big and len(h_big) % len(h_small) == 0
    return len(h_big) // len(h_small)

def telescope_holds(chain: Sequence[FrozenSet[Perm]]) -> bool:
    for a, b in zip(chain, chain[1:]):
        assert a <= b, 'chain must be monotone'
    rel: List[int] = [relative_index(chain[i], chain[i + 1])
                      for i in range(len(chain) - 1)]
    return prod(rel) == relative_index(chain[0], chain[-1])

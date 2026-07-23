from itertools import product
from typing import Sequence

def exhaustive_count(A: int, L: int, q: Sequence[int]) -> int:
    target=tuple(q); m=len(target); hits=0
    for word in product(range(A), repeat=L):
        if any(word[i:i+m] == target for i in range(L-m+1)):
            hits += 1
    return hits

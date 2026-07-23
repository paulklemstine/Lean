from itertools import combinations
from math import comb
from typing import Callable

def card_prod_species(card_A: Callable[[int], int], card_B: Callable[[int], int], n: int) -> int:
    total = 0
    for k in range(n + 1):
        for S in combinations(range(n), k):
            total += card_A(len(S)) * card_B(n - len(S))
    return total

def binconv_int(card_A: Callable[[int], int], card_B: Callable[[int], int], n: int) -> int:
    return sum(comb(n, i) * card_A(i) * card_B(n - i) for i in range(n + 1))

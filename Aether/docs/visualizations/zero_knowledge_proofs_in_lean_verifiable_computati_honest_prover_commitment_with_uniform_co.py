import random
from itertools import permutations
from typing import Dict, Tuple

Colouring = Dict[int, int]
Permutation = Tuple[int, int, int]

def honest_prover_round(c: Colouring, e: Tuple[int, int]) -> Tuple[int, int]:
    pi: Permutation = random.choice(list(permutations((0, 1, 2))))
    u, v = e
    return (pi[c[u]], pi[c[v]])

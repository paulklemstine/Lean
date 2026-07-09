import random
from typing import List

def sample_seed(k: int, n: int) -> List[List[int]]:
    return [[random.randint(0, 1) for _ in range(n)] for _ in range(k)]

def parity_hash(A: List[List[int]], x: List[int]) -> List[int]:
    return [sum(A[r][i] * x[i] for i in range(len(x))) % 2 for r in range(len(A))]

def privacy_amplify(x: List[int], k: int) -> List[int]:
    A = sample_seed(k, len(x))   # public seed, fresh per session
    return parity_hash(A, x)     # collision prob exactly 2^-k (two_universal_k)

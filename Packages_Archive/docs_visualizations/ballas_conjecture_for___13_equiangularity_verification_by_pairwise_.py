from typing import List, Sequence
import math

Vector = List[float]

def dot(u: Sequence[float], v: Sequence[float]) -> float:
    return sum(a * b for a, b in zip(u, v))

def norm(v: Sequence[float]) -> float:
    return math.sqrt(dot(v, v))

def is_equiangular(vectors: Sequence[Sequence[float]], alpha: float,
                   tol: float = 1e-9) -> bool:
    """Return True iff the vectors are unit and |<v_i,v_j>| = alpha for i != j.

    Complexity: O(N^2 d) inner-product operations.
    """
    for v in vectors:
        if abs(norm(v) - 1.0) > tol:
            return False
    n = len(vectors)
    for i in range(n):
        for j in range(i + 1, n):
            if abs(abs(dot(vectors[i], vectors[j])) - alpha) > tol:
                return False
    return True

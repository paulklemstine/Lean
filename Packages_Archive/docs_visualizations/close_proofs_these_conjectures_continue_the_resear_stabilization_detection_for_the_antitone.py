from __future__ import annotations
from typing import Callable, List, Tuple
import numpy as np

Matrix = np.ndarray
Stream = Callable[[int], Matrix]

def detect_stabilization(f: Stream, n: int, tol: float = 1e-9
                         ) -> Tuple[int, int, List[int]]:
    """
    Incrementally compute r_m = rank(trans(f, 0, m)) for m = 0..n and
    return (stabilization_index, stable_value, sequence). The sequence is
    antitone and bounded by n, so it strictly drops at most n times.
    """
    acc: Matrix = np.eye(n)
    seq: List[int] = [int(np.linalg.matrix_rank(acc, tol=tol))]
    for t in range(0, n):           # by Conjecture 2 it stabilizes by index n
        acc = f(t) @ acc
        seq.append(int(np.linalg.matrix_rank(acc, tol=tol)))
    final = seq[-1]
    stab = next(m for m in range(len(seq)) if all(v == final for v in seq[m:]))
    return stab, final, seq

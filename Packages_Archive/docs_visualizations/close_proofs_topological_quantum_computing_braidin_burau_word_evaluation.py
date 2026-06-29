from __future__ import annotations
from typing import List, Tuple

Complex = complex
Matrix2 = Tuple[Tuple[Complex, Complex], Tuple[Complex, Complex]]


def mat_mul(M: Matrix2, N: Matrix2) -> Matrix2:
    """Multiply two 2x2 matrices."""
    return (
        (M[0][0] * N[0][0] + M[0][1] * N[1][0], M[0][0] * N[0][1] + M[0][1] * N[1][1]),
        (M[1][0] * N[0][0] + M[1][1] * N[1][0], M[1][0] * N[0][1] + M[1][1] * N[1][1]),
    )


def burau_gen(i: int, inverse: bool, t: Complex) -> Matrix2:
    """Reduced Burau matrix for sigma_i (i in {1,2}); inverse=True for sigma_i^-1."""
    if i == 1:
        M = ((-t, 1.0 + 0j), (0j, 1.0 + 0j)) if not inverse else ((-1 / t, 1 / t), (0j, 1.0 + 0j))
    elif i == 2:
        if not inverse:
            M = ((1.0 + 0j, 0j), (t, -t))
        else:
            # inverse of [[1,0],[t,-t]] is [[1,0],[1,-1/t]]
            M = ((1.0 + 0j, 0j), (1.0 + 0j, -1 / t))
    else:
        raise ValueError("only sigma_1, sigma_2 on three strands")
    return M


def burau_eval(word: List[Tuple[int, bool]], t: Complex) -> Matrix2:
    """Evaluate a braid word (list of (i, inverse)) in reduced Burau at parameter t.

    Complexity: O(len(word)) 2x2 matrix multiplications.
    """
    acc: Matrix2 = ((1.0 + 0j, 0j), (0j, 1.0 + 0j))
    for (i, inv) in word:
        acc = mat_mul(acc, burau_gen(i, inv, t))
    return acc

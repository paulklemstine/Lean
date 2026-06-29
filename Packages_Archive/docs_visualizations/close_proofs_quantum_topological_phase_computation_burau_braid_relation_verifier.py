"""Burau braid-relation verifier for the 3-strand braid group B3."""
from __future__ import annotations
from typing import List, Tuple

Mat = Tuple[Tuple[complex, complex], Tuple[complex, complex]]
I2: Mat = ((1 + 0j, 0j), (0j, 1 + 0j))


def mul(X: Mat, Y: Mat) -> Mat:
    """Product of two 2x2 complex matrices."""
    return (
        (X[0][0]*Y[0][0] + X[0][1]*Y[1][0], X[0][0]*Y[0][1] + X[0][1]*Y[1][1]),
        (X[1][0]*Y[0][0] + X[1][1]*Y[1][0], X[1][0]*Y[0][1] + X[1][1]*Y[1][1]),
    )


def burau_sigma1(t: complex) -> Mat:
    """Reduced Burau matrix of sigma_1."""
    return ((-t, 1 + 0j), (0j, 1 + 0j))


def burau_sigma2(t: complex) -> Mat:
    """Reduced Burau matrix of sigma_2."""
    return ((1 + 0j, 0j), (t, -t))


def eval_word(word: List[int], t: complex) -> Mat:
    """Evaluate a braid word (list of +-1 / +-2 generators) under Burau."""
    acc: Mat = I2
    for g in word:
        if g == 1:
            acc = mul(acc, burau_sigma1(t))
        elif g == 2:
            acc = mul(acc, burau_sigma2(t))
        else:
            raise ValueError(f"unsupported generator {g}")
    return acc


def braid_relation_holds(t: complex, tol: float = 1e-9) -> bool:
    """Check s1 s2 s1 == s2 s1 s2 at the parameter t."""
    lhs = eval_word([1, 2, 1], t)
    rhs = eval_word([2, 1, 2], t)
    return all(abs(lhs[i][j] - rhs[i][j]) < tol for i in range(2) for j in range(2))


if __name__ == "__main__":
    for t in (1 + 0j, 2 + 1j, -0.5 + 0.3j):
        print(f"t={t}: braid relation holds = {braid_relation_holds(t)}")

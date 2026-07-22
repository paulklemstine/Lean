from __future__ import annotations
from typing import List, Dict
import numpy as np


def burau(i: int, t: complex) -> np.ndarray:
    mats = {
        1: [[-t, 0, 0], [1, 1, 0], [0, 0, 1]],
        2: [[1, t, 0], [0, -t, 0], [0, 1, 1]],
        3: [[1, 0, 0], [0, 1, t], [0, 0, -t]],
    }
    return np.array(mats[i], dtype=complex)


def compile_braid(word: List[int], t: complex) -> np.ndarray:
    """Compile a braid word to its 3x3 reduced Burau matrix at parameter t.

    `word` is a list of nonzero integers in {-3,-2,-1,1,2,3}: a positive entry i
    denotes sigma_i and a negative entry -i denotes sigma_i^{-1}.
    """
    gens: Dict[int, np.ndarray] = {i: burau(i, t) for i in (1, 2, 3)}
    inv: Dict[int, np.ndarray] = {i: np.linalg.inv(gens[i]) for i in (1, 2, 3)}
    acc = np.eye(3, dtype=complex)
    for letter in word:
        if letter == 0 or abs(letter) > 3:
            raise ValueError(f"invalid braid letter: {letter}")
        acc = acc @ (gens[letter] if letter > 0 else inv[-letter])
    return acc

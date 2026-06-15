from __future__ import annotations
import numpy as np


def burau_eval(word: list[tuple[int, int]], t: complex) -> np.ndarray:
    """Evaluate a B_3 braid word in the reduced Burau representation.

    `word` is a list of (index, sign) pairs, index in {1, 2}, sign in {+1, -1}.
    Generators:
        sigma_1 = [[-t, 1], [0, 1]],   sigma_2 = [[1, 0], [t, -t]].
    The map is a homomorphism: burau_eval(w1 + w2) == burau_eval(w1) @
    burau_eval(w2), and the generators satisfy s1 s2 s1 = s2 s1 s2 for every t
    (the Yang-Baxter / braid relation). The Jones polynomial is recovered as a
    normalized Markov trace of such a matrix.

    Complexity: O(len(word)) 2x2 matrix multiplications.
    """
    gens = {
        1: np.array([[-t, 1.0], [0.0, 1.0]], dtype=complex),
        2: np.array([[1.0, 0.0], [t, -t]], dtype=complex),
    }
    m = np.eye(2, dtype=complex)
    for index, sign in word:
        base = gens[index]
        m = m @ (base if sign > 0 else np.linalg.inv(base))
    return m

from __future__ import annotations
from typing import List
import numpy as np

def temperley_lieb_generators(A: complex, n_sites: int = 4) -> List[np.ndarray]:
    """
    Spin-chain Temperley-Lieb generators E_1,...,E_{n-1} on n qubits at loop
    value delta = -(A^2 + A^-2).  With q = -A^2 the two-site block is
    [[q,-1],[-1,1/q]], giving E_i^2 = delta*E_i and the absorption relations.
    """
    q = -(A ** 2)
    U = np.zeros((4, 4), dtype=complex)        # basis |00>,|01>,|10>,|11>
    U[1, 1] = q; U[1, 2] = -1.0
    U[2, 1] = -1.0; U[2, 2] = 1.0 / q
    gens: List[np.ndarray] = []
    for i in range(n_sites - 1):
        left = np.eye(2 ** i, dtype=complex)
        right = np.eye(2 ** (n_sites - i - 2), dtype=complex)
        gens.append(np.kron(np.kron(left, U), right))
    return gens

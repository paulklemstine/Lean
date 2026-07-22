from itertools import product, combinations
import numpy as np


def phi_mip(psi, n: int, d: int) -> int:
    """Multipartite integrated information: minimum over nontrivial cuts S of
    (Schmidt rank across S) - 1, where psi: (Fin n -> Fin d) -> C is an
    amplitude tensor reshaped across each cut."""
    best = None
    for k in range(1, n):
        for s in combinations(range(n), k):
            s_set = set(s)
            in_s = [i for i in range(n) if i in s_set]
            out_s = [i for i in range(n) if i not in s_set]
            rows = list(product(range(d), repeat=len(in_s)))
            cols = list(product(range(d), repeat=len(out_s)))
            M = np.zeros((len(rows), len(cols)), dtype=complex)
            for ri, rc in enumerate(rows):
                for ci, cc in enumerate(cols):
                    x = [0] * n
                    for t, i in enumerate(in_s):
                        x[i] = rc[t]
                    for t, i in enumerate(out_s):
                        x[i] = cc[t]
                    M[ri, ci] = psi(tuple(x))
            val = max(int(np.linalg.matrix_rank(M)) - 1, 0)
            best = val if best is None else min(best, val)
    return best

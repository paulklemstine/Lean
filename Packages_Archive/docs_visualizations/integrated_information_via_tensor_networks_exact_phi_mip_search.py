from itertools import product
from typing import Callable, List, Sequence, Tuple
import numpy as np

Config = Tuple[int, ...]

def exact_phi(psi: Callable[[Config], complex], n: int, d: int) -> int:
    """Exact integrated information Phi over the minimum-information partition.

    Iterates over all 2^n - 2 nontrivial bipartitions, computes the Schmidt
    rank across each via SVD, and returns the minimum of (rank - 1).
    """
    def subsets() -> List[Tuple[int, ...]]:
        out, seen = [], set()
        for S in product([0, 1], repeat=n):
            s = tuple(i for i in range(n) if S[i])
            if 1 <= len(s) <= n - 1 and s not in seen:
                seen.add(s); out.append(s)
        return out

    def rank_at(S: Sequence[int]) -> int:
        Sl = sorted(S); Sc = sorted(set(range(n)) - set(Sl))
        rows = list(product(range(d), repeat=len(Sl)))
        cols = list(product(range(d), repeat=len(Sc)))
        M = np.zeros((len(rows), len(cols)), dtype=complex)
        for i, a in enumerate(rows):
            for j, b in enumerate(cols):
                full = [0]*n
                for s, v in zip(Sl, a): full[s] = v
                for s, v in zip(Sc, b): full[s] = v
                M[i, j] = psi(tuple(full))
        sv = np.linalg.svd(M, compute_uv=False)
        return int(np.sum(sv > 1e-9 * max(1.0, sv[0]))) if sv.size else 0

    return min(max(rank_at(S) - 1, 0) for S in subsets())

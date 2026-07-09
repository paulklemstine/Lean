from typing import List, Sequence

Matrix = List[List[float]]
Vec = List[float]


def trop_diff_max(K: Matrix, u: Sequence[float]) -> Vec:
    """One max-plus diffusion step: (tropDiffMax K u)_i = max_j (u_j - K_ij)."""
    n = len(u)
    return [max(u[j] - K[i][j] for j in range(n)) for i in range(n)]


def iterate_trop(K: Matrix, n: int, u: Sequence[float]) -> Vec:
    """Apply tropDiffMax n times; tropEnergy = max is antitone along iterates."""
    v: Vec = list(u)
    for _ in range(n):
        v = trop_diff_max(K, v)
    return v


def trop_energy(u: Sequence[float]) -> float:
    return max(u)

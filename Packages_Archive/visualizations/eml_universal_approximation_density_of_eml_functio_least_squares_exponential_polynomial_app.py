from math import exp
from typing import Callable, List, Sequence

def fit_exp_polynomial(
    target: Callable[[float], float],
    degree: int,
    n_grid: int = 400,
) -> List[float]:
    """Least-squares fit of c_0 + c_1 e^x + ... + c_k e^{kx} to `target` on [0,1].

    Density (exp_subalgebra_dense_on_Icc) guarantees the sup error -> 0 as the
    degree k grows. Solves the (k+1)x(k+1) normal equations by Gaussian
    elimination. Complexity: O(n_grid * k^2) to assemble + O(k^3) to solve.
    """
    k = degree
    grid: List[float] = [i / (n_grid - 1) for i in range(n_grid)]

    def basis(x: float) -> List[float]:
        return [exp(j * x) for j in range(k + 1)]

    m = k + 1
    ata: List[List[float]] = [[0.0] * m for _ in range(m)]
    aty: List[float] = [0.0] * m
    for x in grid:
        bvec = basis(x)
        y = target(x)
        for r in range(m):
            aty[r] += bvec[r] * y
            for c in range(m):
                ata[r][c] += bvec[r] * bvec[c]

    # Gaussian elimination with partial pivoting.
    aug: List[List[float]] = [ata[i][:] + [aty[i]] for i in range(m)]
    for col in range(m):
        piv = max(range(col, m), key=lambda r: abs(aug[r][col]))
        aug[col], aug[piv] = aug[piv], aug[col]
        p = aug[col][col]
        for c in range(col, m + 1):
            aug[col][c] /= p
        for r in range(m):
            if r != col:
                f = aug[r][col]
                for c in range(col, m + 1):
                    aug[r][c] -= f * aug[col][c]
    return [aug[r][m] for r in range(m)]

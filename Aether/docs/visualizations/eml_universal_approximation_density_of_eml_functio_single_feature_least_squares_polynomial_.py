from __future__ import annotations

import math
from typing import Callable, List, Tuple


def single_feature_approximant(
    activation: Callable[[float], float],
    target: Callable[[float], float],
    a: float,
    b: float,
    degree: int,
    n_samples: int = 400,
) -> Tuple[List[float], Callable[[float], float]]:
    """Construct the least-squares polynomial read-out in the single feature
    u = activation(x) approximating `target` on [a, b].

    Returns coefficients (c_0, ..., c_degree) and the model
        model(x) = sum_k c_k * activation(x)^k.

    The mathematical guarantee (activation_feature_dense): if `activation` is
    strictly monotone (hence injective) and continuous, the achievable uniform
    error tends to 0 as `degree` -> infinity.
    """
    xs = [a + (b - a) * i / (n_samples - 1) for i in range(n_samples)]
    powers = [[activation(x) ** k for k in range(degree + 1)] for x in xs]
    ys = [target(x) for x in xs]

    dim = degree + 1
    ata = [[0.0] * dim for _ in range(dim)]
    aty = [0.0] * dim
    for row, y in zip(powers, ys):
        for i in range(dim):
            aty[i] += row[i] * y
            for j in range(dim):
                ata[i][j] += row[i] * row[j]

    # Gaussian elimination with partial pivoting.
    aug = [ata[i][:] + [aty[i]] for i in range(dim)]
    for col in range(dim):
        pivot = max(range(col, dim), key=lambda r: abs(aug[r][col]))
        aug[col], aug[pivot] = aug[pivot], aug[col]
        pv = aug[col][col] or 1e-12
        for r in range(dim):
            if r == col:
                continue
            f = aug[r][col] / pv
            for c in range(col, dim + 1):
                aug[r][c] -= f * aug[col][c]
    coeffs = [aug[i][dim] / (aug[i][i] or 1e-12) for i in range(dim)]

    def model(x: float) -> float:
        u = activation(x)
        return sum(c * u ** k for k, c in enumerate(coeffs))

    return coeffs, model

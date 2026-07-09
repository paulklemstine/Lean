from __future__ import annotations

import itertools
from typing import Callable, List, Sequence, Tuple

import numpy as np


def exp_poly_features(X: np.ndarray, multi_indices: Sequence[Tuple[int, ...]]) -> np.ndarray:
    """Design matrix Phi[x, k] = exp(<k, x>) of exponential-monomial features."""
    K = np.asarray(multi_indices, dtype=float)
    return np.exp(X @ K.T)


def fit_exp_poly(
    f: Callable[[np.ndarray], np.ndarray],
    n: int,
    max_degree: int,
    grid_per_axis: int = 11,
) -> Tuple[np.ndarray, List[Tuple[int, ...]], float]:
    """Least-squares exponential-polynomial fit of f on a grid over [0,1]^n.

    Builds all multi-indices k in N^n with sum(k) <= max_degree, assembles the
    feature matrix exp(<k, x>), and solves min_c ||Phi c - f||_2. By the density
    theorem the sup-norm error tends to 0 as max_degree grows.
    """
    axis = np.linspace(0.0, 1.0, grid_per_axis)
    X = np.array(list(itertools.product(axis, repeat=n)), dtype=float)
    y = f(X)
    multi_indices = [
        k for k in itertools.product(range(max_degree + 1), repeat=n) if sum(k) <= max_degree
    ]
    Phi = exp_poly_features(X, multi_indices)
    coeffs, *_ = np.linalg.lstsq(Phi, y, rcond=None)
    residual = Phi @ coeffs - y
    return coeffs, multi_indices, float(np.max(np.abs(residual)))

from __future__ import annotations
from typing import Callable, Tuple
import numpy as np


def fit_exponential_polynomial(
    f: Callable[[np.ndarray], np.ndarray],
    a: float,
    b: float,
    degree: int,
    feature: Callable[[np.ndarray], np.ndarray] | None = None,
    n_samples: int = 2000,
) -> Tuple[np.ndarray, float]:
    """Best-fit exponential polynomial sum_k c_k (e^{g(x)})^k to f on [a, b].

    Implements the constructive content of the single-exponential-feature
    universal approximation theorem: for an injective feature g, the powers of
    u = exp(g(x)) span a dense subalgebra, so a least-squares projection onto
    {u^0, ..., u^degree} drives the uniform error to 0 as degree grows.

    Returns the coefficient vector c and the achieved sup-norm error on a grid.
    """
    if feature is None:
        feature = lambda t: t  # identity is injective -> exponential polynomials
    xs = np.linspace(a, b, n_samples)
    u = np.exp(feature(xs))                       # single exponential feature
    design = np.vander(u, N=degree + 1, increasing=True)
    targets = f(xs)
    coeffs, *_ = np.linalg.lstsq(design, targets, rcond=None)
    sup_err = float(np.max(np.abs(design @ coeffs - targets)))
    return coeffs, sup_err

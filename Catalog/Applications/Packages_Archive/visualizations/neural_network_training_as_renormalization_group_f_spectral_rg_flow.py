from typing import List, Tuple
import numpy as np

def spectral_rg_flow(A: np.ndarray, x0: np.ndarray, t: float) -> np.ndarray:
    """
    Multi-mode RG flow with a self-adjoint coarse-graining beta-operator A:

        theta(t) = exp(-t A) x0 = sum_i exp(-lambda_i t) <x0, v_i> v_i,

    where (lambda_i, v_i) are the eigenpairs of A. Relevant/marginal couplings
    are the lambda_i <= 0 eigenspaces (kept); irrelevant couplings (lambda_i > 0)
    decay at their own critical rate exp(-lambda_i t). As t -> infinity the flow
    converges to the orthogonal projection of x0 onto ker A.

    The single-projection model is the special case A = I - P with spectrum {0,1}.
    """
    evals, evecs = np.linalg.eigh(A)              # A symmetric -> real spectrum
    coords = evecs.T @ x0                         # <x0, v_i>
    decayed = np.exp(-t * evals) * coords
    return evecs @ decayed

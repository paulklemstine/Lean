from __future__ import annotations
import numpy as np

def hodge_energy(d: np.ndarray, e: np.ndarray, x: np.ndarray) -> tuple[float, bool]:
    """Rayleigh energy of x and a harmonicity certificate.

    Uses the sum-of-squares identity  <Delta x, x> = ||d x||^2 + ||e* x||^2,
    so no Laplacian matrix need be formed. Returns (energy, is_harmonic).
    x is harmonic iff energy == 0 (Theorem: vanishing locus = ker Delta).
    """
    energy = float(np.dot(d @ x, d @ x) + np.dot(e.T @ x, e.T @ x))
    return energy, energy < 1e-9

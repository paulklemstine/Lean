import numpy as np

def complex_laplace_quadrature(t: np.ndarray, f: np.ndarray, points: np.ndarray) -> np.ndarray:
    """Evaluate trapezoidal Laplace quadrature at complex points in batches."""
    if t.shape != f.shape:
        raise ValueError("t and f must have equal shapes")
    trap = getattr(np, "trapezoid", np.trapz)
    out = np.empty(points.size, dtype=np.complex128)
    for j, s in enumerate(points):
        out[j] = trap(f * np.exp(-s*t), t)
    return out

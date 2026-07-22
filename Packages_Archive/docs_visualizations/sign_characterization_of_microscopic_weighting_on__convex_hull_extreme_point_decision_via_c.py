import itertools
import numpy as np

def is_extreme_point(points: np.ndarray, i: int, tol: float = 1e-9) -> bool:
    """Decide whether points[i] is a vertex of conv(points).

    points[i] is NOT extreme iff it is a convex combination of the other points.
    We search affinely-independent subsets of size up to d+1 (Caratheodory) and
    solve the small affine system for convex coefficients, checking
    nonnegativity. Complexity: combinatorial in n but exact for low dimension d.
    """
    n = len(points)
    others = [j for j in range(n) if j != i]
    d = points.shape[1]
    target = points[i]
    for k in range(1, min(d + 1, len(others)) + 1):
        for combo in itertools.combinations(others, k):
            M = np.array([points[j] for j in combo]).T
            A = np.vstack([M, np.ones(k)])
            b = np.concatenate([target, [1.0]])
            c, *_ = np.linalg.lstsq(A, b, rcond=None)
            if np.allclose(A @ c, b, atol=tol) and np.all(c >= -tol):
                return False
    return True

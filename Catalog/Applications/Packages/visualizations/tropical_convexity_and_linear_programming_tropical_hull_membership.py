import numpy as np

def tropical_hull_membership(generators, x, tol=1e-9):
    """Decide membership in tropical convex hull. O(mn) time."""
    m, n = generators.shape
    if m == 0: return False, None
    c = np.min(x[np.newaxis, :] - generators, axis=1)
    hull_point = np.max(c[:, np.newaxis] + generators, axis=0)
    if np.allclose(hull_point, x, atol=tol):
        return True, c
    return False, None

# Example
gens = np.array([[0, 0], [3, 1], [1, 4]], dtype=float)
for j in range(3):
    ok, c = tropical_hull_membership(gens, gens[j])
    print(f"v_{j} in hull: {ok}, coefficients: {c}")
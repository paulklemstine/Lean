import numpy as np

def distance_matrix(points: np.ndarray) -> np.ndarray:
    diff = points[:, None, :] - points[None, :, :]
    return np.sqrt((diff ** 2).sum(axis=-1))

def sign_extremality_audit(points: np.ndarray,
                           is_extreme) -> list[tuple[int, float, bool, bool]]:
    """For each point return (index, weight, is_extreme, prediction_holds).

    The sign characterization predicts weight > 0 exactly at extreme points of
    the convex hull. Complexity: O(n^3) for the weighting plus the cost of the
    extremality test per point.
    """
    D = distance_matrix(points)
    u = np.linalg.solve(D, np.ones(len(points)))
    mu = u / u.sum()
    out = []
    for i in range(len(points)):
        ext = is_extreme(points, i)
        w = float(mu[i])
        holds = (w > 1e-9) == ext
        out.append((i, w, ext, holds))
    return out

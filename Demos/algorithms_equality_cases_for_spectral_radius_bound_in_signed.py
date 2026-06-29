"""Peak-Vertex Equality Certificate for the Signed-Graph Delta-Bound.

Given a signed adjacency matrix A and a candidate eigenpair (mu, v), this
algorithm certifies the Delta-bound |mu| <= Delta and, when equality holds,
verifies the two local equality theorems: degree saturation (the peak vertex has
degree Delta) and magnitude propagation (every neighbour of a peak vertex also
attains the peak magnitude).
"""

from __future__ import annotations

import numpy as np


def equality_certificate(A: np.ndarray, mu: float, v: np.ndarray,
                         tol: float = 1e-7) -> dict:
    """Return an auditable certificate for the Delta-bound and its equality cases.

    Complexity: O(n^2), dominated by the absolute row sums.

    Parameters
    ----------
    A   : (n, n) signed adjacency matrix (symmetric, entries in {-1,0,1}, zero diag)
    mu  : claimed eigenvalue of A with eigenvector v
    v   : the eigenvector (need not be normalised)

    Returns
    -------
    dict with keys: 'delta', 'bound_holds', 'equality', 'peak_vertices',
    'degree_saturation', 'magnitude_propagation'.
    """
    n = A.shape[0]
    abs_row_sums = np.abs(A).sum(axis=1)         # degree of each vertex
    delta = float(abs_row_sums.max())

    # Step 1: the Delta-bound.
    bound_holds = abs(mu) <= delta + tol

    # Step 2: locate the peak set P = argmax_i |v_i|.
    M = float(np.abs(v).max())
    peaks = [i for i in range(n) if abs(abs(v[i]) - M) <= tol]

    cert = {
        "delta": delta,
        "bound_holds": bound_holds,
        "equality": abs(abs(mu) - delta) <= tol,
        "peak_vertices": peaks,
        "degree_saturation": None,
        "magnitude_propagation": None,
    }

    # Steps 3-4: equality structure (only meaningful at equality).
    if cert["equality"]:
        cert["degree_saturation"] = all(
            abs(abs_row_sums[i] - delta) <= tol for i in peaks
        )
        prop_ok = True
        for i in peaks:
            for j in range(n):
                if abs(A[i, j]) > tol and abs(abs(v[j]) - M) > tol:
                    prop_ok = False
        cert["magnitude_propagation"] = prop_ok
    return cert


if __name__ == "__main__":
    n = 5
    A = np.ones((n, n)) - np.eye(n)              # K_5^+
    w, U = np.linalg.eigh(A)
    k = int(np.argmax(np.abs(w)))
    print(equality_certificate(A, float(w[k]), U[:, k]))

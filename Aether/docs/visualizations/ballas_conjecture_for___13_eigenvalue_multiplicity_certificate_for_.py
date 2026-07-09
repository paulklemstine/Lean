import numpy as np
from typing import Tuple

def multiplicity_certificate(S: np.ndarray, d: int,
                             tol: float = 1e-6) -> Tuple[int, bool]:
    """Return (mu, bridge_holds) where mu = mult_{-3}(S) and
    bridge_holds asserts m <= d + mu."""
    m = S.shape[0]
    eigs = np.linalg.eigvalsh(S)
    mu = int(np.sum(np.abs(eigs + 3.0) < tol))
    return mu, (m <= d + mu)

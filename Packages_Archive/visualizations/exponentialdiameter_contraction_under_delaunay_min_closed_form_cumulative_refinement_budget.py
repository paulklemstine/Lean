from typing import Tuple

def budget(D: float, lam: float, K: int) -> Tuple[float, float]:
    """Closed-form budget D*lam/(lam-1) and partial sum over K rounds."""
    assert lam > 1.0
    closed_form = D * lam / (lam - 1.0)
    partial, term = 0.0, D
    for _ in range(K):
        partial += term
        term /= lam
    return closed_form, partial

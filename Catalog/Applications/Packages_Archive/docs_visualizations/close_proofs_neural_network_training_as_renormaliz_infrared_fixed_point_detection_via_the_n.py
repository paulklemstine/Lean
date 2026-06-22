from typing import Sequence

def is_ir_fixed_point(eta: float, lam: Sequence[float], v: Sequence[float],
                      tol: float = 1e-12) -> bool:
    """True iff v rests under training, i.e. lies in ker(NTK) (Theorem 3.4)."""
    assert eta != 0.0, 'learning rate must be nonzero'
    return all(abs(lam_i * v_i) <= tol for lam_i, v_i in zip(lam, v))

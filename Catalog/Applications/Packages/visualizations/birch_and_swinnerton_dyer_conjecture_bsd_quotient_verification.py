def verify_bsd(omega: float, reg: float, sha: int, tam: int,
               tors: int, leading: float, tol: float = 1e-10) -> tuple:
    """Verify BSD formula. Returns (holds, ratio)."""
    alg = omega * reg * sha * tam / tors**2
    ratio = leading / alg if abs(alg) > 1e-300 else float('inf')
    from math import isclose
    return (isclose(ratio, 1.0, rel_tol=tol), ratio)
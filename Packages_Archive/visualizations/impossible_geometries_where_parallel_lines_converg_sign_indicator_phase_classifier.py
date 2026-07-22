import math

def sech2(t: float) -> float:
    return 1.0 / math.cosh(t) ** 2

def classify_phase(x: float, y: float, tol: float = 1e-12) -> str:
    """Classify a point of Split Geometry by the sign of the sign-indicator
    curvature K(x,y) = sech^2(x) - sech^2(y). By the monotonicity of sech^2 in
    |t|, this is equivalent to comparing |x| and |y|:
        |x| < |y|  ->  K > 0  (elliptic)
        |x| = |y|  ->  K = 0  (flat boundary, the diagonals y = +/- x)
        |x| > |y|  ->  K < 0  (hyperbolic)."""
    k = sech2(x) - sech2(y)
    if abs(k) <= tol:
        return "boundary"
    return "elliptic" if k > 0.0 else "hyperbolic"

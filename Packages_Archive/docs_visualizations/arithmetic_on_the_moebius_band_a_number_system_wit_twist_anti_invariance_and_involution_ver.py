from typing import List, Tuple

def twist(x: float, y: float) -> Tuple[float, float]:
    """The twist involution (x, y) -> (1 - x, y)."""
    return (1.0 - x, y)

def value(x: float, y: float) -> float:
    return y * (2.0 * x - 1.0)

def verify_twist(samples: List[Tuple[float, float]]) -> bool:
    """Verify phi(twist(z)) = -phi(z) and twist^2 = id on all samples."""
    for (x, y) in samples:
        tx, ty = twist(x, y)
        if abs(value(tx, ty) + value(x, y)) > 1e-12:
            return False
        ttx, tty = twist(tx, ty)
        if abs(ttx - x) > 1e-12 or abs(tty - y) > 1e-12:
            return False
    return True

def fixed_locus(x: float, y: float) -> bool:
    """A representative is twist-fixed iff x = 1/2 (the central circle)."""
    return abs(x - 0.5) < 1e-12

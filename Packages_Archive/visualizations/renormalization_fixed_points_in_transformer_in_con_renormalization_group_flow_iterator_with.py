from typing import List


def rg_step(g: float, b: float, x: float) -> float:
    """Affine renormalization step rgStep(g, b, x) = g*x + b."""
    return g * x + b


def rg_fixed_point(g: float, b: float) -> float:
    """Unique fixed point b/(1-g)."""
    return b / (1.0 - g)


def rg_flow(g: float, b: float, x0: float, n: int) -> List[float]:
    """Return the RG trajectory and verify the exact flow law gⁿ(x-x*)."""
    xstar = rg_fixed_point(g, b)
    traj: List[float] = [x0]
    x = x0
    for k in range(1, n + 1):
        x = rg_step(g, b, x)
        traj.append(x)
        predicted = xstar + (g ** k) * (x0 - xstar)   # Theorem 4.4
        assert abs(x - predicted) < 1e-9
    return traj

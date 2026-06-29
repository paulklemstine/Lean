import math

def perturbed_occam_bound(
    R: float, C: float, L: float, rho: float, n: int, delta: float
) -> float:
    """Perturbation-stable Occam generalization bound."""
    robust_emp_risk: float = R + L * rho
    arg: float = (C + math.log(1.0 / delta)) / (2.0 * n)
    penalty: float = math.sqrt(arg) if arg > 0 else 0.0
    return robust_emp_risk + penalty

import math
from typing import Sequence

def clean_data_certificate(
    clean_losses: Sequence[float], L: float, rho: float,
    C: float, n: int, delta: float,
) -> float:
    """Certified true-risk bound under any rho-perturbation,
    computed from clean data only."""
    R: float = sum(clean_losses) / len(clean_losses)
    robust_emp_risk: float = R + L * rho
    arg: float = (C + math.log(1.0 / delta)) / (2.0 * n)
    penalty: float = math.sqrt(arg) if arg > 0 else 0.0
    return robust_emp_risk + penalty

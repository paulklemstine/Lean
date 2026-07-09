from __future__ import annotations
import math
from typing import List

def path_spectrum(n: int) -> List[float]:
    """Closed-form adjacency spectrum of the path P_n."""
    return [2.0 * math.cos((k + 1) * math.pi / (n + 1)) for k in range(n)]

def path_positive_2_energy(n: int) -> float:
    """E_2^+(P_n); by the main theorem this equals n - 1 exactly."""
    return sum(lam ** 2 for lam in path_spectrum(n) if lam > 0.0)

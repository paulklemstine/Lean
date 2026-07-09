from __future__ import annotations
import math, random
from typing import List, Tuple

def ou_moments(theta: float, sigma2: float, m0: float, v0: float, t: float) -> Tuple[float, float]:
    decay = math.exp(-2.0 * theta * t)
    v_inf = sigma2 / (2.0 * theta)
    return m0 * math.exp(-theta * t), v0 * decay + v_inf * (1.0 - decay)

def reverse_time_sampler(theta: float, sigma2: float, m0: float, v0: float,
                         T: float, n_steps: int, n_samples: int,
                         seed: int = 0) -> Tuple[float, float]:
    """Euler-Maruyama for the reverse SDE dY = b(Y,t) dt + sigma dW_bar,
    reverse drift b = theta x + sigma2 * (-(x-m)/v) (Gaussian score),
    started from the stationary law N(0, sigma2/2theta).

    Returns the empirical (mean, variance) of terminal samples, which match
    the data moments (m0, v0) by ou_reverse_fokker_planck (exact recovery)."""
    rng = random.Random(seed)
    sigma = math.sqrt(sigma2)
    dt = T / n_steps
    v_inf = sigma2 / (2.0 * theta)
    ys: List[float] = [rng.gauss(0.0, math.sqrt(v_inf)) for _ in range(n_samples)]
    for k in range(n_steps):
        t = T - k * dt
        m, v = ou_moments(theta, sigma2, m0, v0, t)
        ys = [y + (theta * y + sigma2 * (-(y - m) / v)) * dt
                + sigma * math.sqrt(dt) * rng.gauss(0.0, 1.0) for y in ys]
    n = len(ys)
    mean = sum(ys) / n
    var = sum((y - mean) ** 2 for y in ys) / (n - 1)
    return mean, var

from __future__ import annotations
import math
from typing import Callable, Tuple

def gaussian_density(m: float, v: float, x: float) -> float:
    return math.exp(-math.log(2.0 * math.pi * v) / 2.0 - (x - m) ** 2 / (2.0 * v))

def gaussian_dxx(m: float, v: float, x: float) -> float:
    return gaussian_density(m, v, x) * ((x - m) ** 2 - v) / v ** 2

def ou_moments(theta: float, sigma2: float, m0: float, v0: float, t: float) -> Tuple[float, float]:
    decay = math.exp(-2.0 * theta * t)
    v_inf = sigma2 / (2.0 * theta)
    return m0 * math.exp(-theta * t), v0 * decay + v_inf * (1.0 - decay)

def fokker_planck_residual(theta: float, sigma2: float, m0: float, v0: float,
                           x: float, t: float, h: float = 1e-6) -> float:
    """Residual of  d_t p = theta d_x(x p) + (sigma2/2) d_xx p  at (x, t).

    By ou_fokker_planck this is identically zero; the function verifies it
    numerically (central differences for d_t and d_x(x p); closed form for d_xx)."""
    def dens(xx: float, tt: float) -> float:
        m, v = ou_moments(theta, sigma2, m0, v0, tt)
        return gaussian_density(m, v, xx)
    p_t = (dens(x, t + h) - dens(x, t - h)) / (2.0 * h)
    drift = theta * ((  (x + h) * dens(x + h, t)
                      - (x - h) * dens(x - h, t)) / (2.0 * h))
    m, v = ou_moments(theta, sigma2, m0, v0, t)
    diffusion = (sigma2 / 2.0) * gaussian_dxx(m, v, x)
    return p_t - drift - diffusion

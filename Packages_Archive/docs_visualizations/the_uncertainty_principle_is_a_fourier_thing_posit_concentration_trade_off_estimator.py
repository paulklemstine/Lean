from __future__ import annotations
import numpy as np


def concentration_tradeoff(signal: np.ndarray, dt: float) -> dict[str, float]:
    """Estimate time/frequency spreads and the uncertainty product for a sampled signal.

    Returns Delta_x, Delta_k, their product, and the theoretical bound 1/(4*pi).
    """
    n = signal.size
    t = (np.arange(n) - n / 2) * dt
    p = np.abs(signal) ** 2
    p = p / (p.sum() * dt)
    mu_t = float(np.sum(t * p) * dt)
    var_x = float(np.sum((t - mu_t) ** 2 * p) * dt)
    fhat = np.fft.fftshift(np.fft.fft(np.fft.ifftshift(signal))) * dt
    k = np.fft.fftshift(np.fft.fftfreq(n, d=dt))
    dk = float(k[1] - k[0])
    pk = np.abs(fhat) ** 2
    pk = pk / (pk.sum() * dk)
    mu_k = float(np.sum(k * pk) * dk)
    var_k = float(np.sum((k - mu_k) ** 2 * pk) * dk)
    dx, dkk = var_x ** 0.5, var_k ** 0.5
    return {"Delta_x": dx, "Delta_k": dkk, "product": dx * dkk,
            "bound": 1.0 / (4.0 * np.pi)}

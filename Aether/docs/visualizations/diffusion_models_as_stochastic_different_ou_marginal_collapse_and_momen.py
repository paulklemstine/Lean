"""Visualization for the OU diffusion / Fokker-Planck package.

Produces a two-panel figure:
  (left)  the OU marginal density p(x, t) = N(m(t), v(t)) at several times,
          collapsing from the data Gaussian toward the stationary N(0, sigma2/2theta);
  (right) the moments m(t), v(t) with the stationary variance v_inf marked,
          illustrating ouMean_tendsto / ouVar_tendsto.

Run: python visualize.py   (saves ou_diffusion.png)
"""

from __future__ import annotations

import math
from typing import List

import numpy as np
import matplotlib.pyplot as plt


def ou_mean(theta: float, m0: float, t: float) -> float:
    return m0 * math.exp(-theta * t)


def ou_var(theta: float, sigma2: float, v0: float, t: float) -> float:
    decay = math.exp(-2.0 * theta * t)
    v_inf = sigma2 / (2.0 * theta)
    return v0 * decay + v_inf * (1.0 - decay)


def gaussian_density(m: float, v: float, x: np.ndarray) -> np.ndarray:
    return np.exp(-np.log(2.0 * np.pi * v) / 2.0 - (x - m) ** 2 / (2.0 * v))


def main() -> None:
    theta, sigma2, m0, v0 = 1.0, 2.0, 4.0, 0.2
    v_inf = sigma2 / (2.0 * theta)
    xs = np.linspace(-6.0, 8.0, 600)
    times: List[float] = [0.0, 0.25, 0.6, 1.2, 3.0]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    cmap = plt.get_cmap("viridis")
    for i, t in enumerate(times):
        m = ou_mean(theta, m0, t)
        v = ou_var(theta, sigma2, v0, t)
        ax1.plot(xs, gaussian_density(m, v, xs), color=cmap(i / max(1, len(times) - 1)),
                 label=f"t = {t:.2f}")
    ax1.plot(xs, gaussian_density(0.0, v_inf, xs), "k--", lw=2,
             label=r"stationary $N(0,\sigma^2/2\theta)$")
    ax1.set_title("OU marginal density collapsing to the stationary law")
    ax1.set_xlabel("x")
    ax1.set_ylabel("p(x, t)")
    ax1.legend()

    ts = np.linspace(0.0, 5.0, 300)
    ms = [ou_mean(theta, m0, t) for t in ts]
    vs = [ou_var(theta, sigma2, v0, t) for t in ts]
    ax2.plot(ts, ms, label=r"$m(t) = m_0 e^{-\theta t}$")
    ax2.plot(ts, vs, label=r"$v(t)$")
    ax2.axhline(v_inf, color="k", ls="--", label=r"$v_\infty = \sigma^2/2\theta$")
    ax2.axhline(0.0, color="gray", ls=":")
    ax2.set_title("Moments relax exponentially to the fixed point")
    ax2.set_xlabel("t")
    ax2.legend()

    fig.tight_layout()
    fig.savefig("ou_diffusion.png", dpi=150)
    print("Saved ou_diffusion.png")


if __name__ == "__main__":
    main()

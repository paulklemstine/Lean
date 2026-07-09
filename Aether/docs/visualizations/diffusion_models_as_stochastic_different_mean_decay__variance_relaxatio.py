"""Visualization of the VP-OU marginals: mean decay, variance relaxation,
and the Gaussian marginal densities sliding toward the standard normal."""
from typing import List
import math
import numpy as np
import matplotlib.pyplot as plt


def vp_mean(m0: float, t: float) -> float:
    return m0 * math.exp(-t / 2.0)


def vp_var(v0: float, t: float) -> float:
    return 1.0 + (v0 - 1.0) * math.exp(-t)


def gaussian_pdf(m: float, var: float, x: np.ndarray) -> np.ndarray:
    return np.exp(-(x - m) ** 2 / (2 * var)) / math.sqrt(2 * math.pi * var)


def main() -> None:
    m0, v0 = 4.0, 6.0
    ts = np.linspace(0, 8, 400)
    means = [vp_mean(m0, t) for t in ts]
    varis = [vp_var(v0, t) for t in ts]

    fig, axes = plt.subplots(1, 3, figsize=(16, 4.5))

    axes[0].plot(ts, means, color="crimson", lw=2)
    axes[0].axhline(0, color="gray", ls="--", lw=1)
    axes[0].set_title(r"Mean decay  $m(t)=m_0 e^{-t/2}\to 0$")
    axes[0].set_xlabel("diffusion time t"); axes[0].set_ylabel("m(t)")

    axes[1].plot(ts, varis, color="royalblue", lw=2)
    axes[1].axhline(1, color="gray", ls="--", lw=1, label="stationary v=1")
    axes[1].set_title(r"Variance relaxation  $v(t)=1+(v_0-1)e^{-t}\to 1$")
    axes[1].set_xlabel("diffusion time t"); axes[1].set_ylabel("v(t)"); axes[1].legend()

    x = np.linspace(-8, 8, 600)
    for t, color in zip([0.0, 0.5, 1.5, 4.0, 8.0], plt.cm.viridis(np.linspace(0, 1, 5))):
        axes[2].plot(x, gaussian_pdf(vp_mean(m0, t), vp_var(v0, t), x),
                     color=color, label=f"t={t}")
    axes[2].set_title("Marginal densities sliding to N(0,1)")
    axes[2].set_xlabel("x"); axes[2].set_ylabel("p_t(x)"); axes[2].legend()

    fig.suptitle("Variance-Preserving Ornstein-Uhlenbeck Diffusion: Moment Backbone")
    fig.tight_layout()
    fig.savefig("vpou_backbone.png", dpi=150)
    print("saved vpou_backbone.png")


if __name__ == "__main__":
    main()

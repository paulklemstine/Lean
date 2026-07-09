"""
Dispersion relation and spectral radius versus the diffusion coefficient `a`.

Left panel: the Fourier-band eigenvalues lambda(a, e^{i theta}) = 1 - 2a(1 - cos
theta) for several `a`, showing the band [1 - 4a, 1] and how its lower edge
crosses -1 at a = 1/2. Right panel: the spectral radius
max_theta |lambda(a, e^{i theta})| as a function of `a`, flat at 1 on [0, 1/2]
and rising as |1 - 4a| outside.

Requires: numpy, matplotlib.
"""

from __future__ import annotations

import numpy as np
import matplotlib.pyplot as plt


def band_eigenvalues(a: float, theta: np.ndarray) -> np.ndarray:
    """lambda(a, e^{i theta}) = 1 - 2a(1 - cos theta)."""
    return 1.0 - 2.0 * a * (1.0 - np.cos(theta))


def spectral_radius(a: float) -> float:
    """max over the Fourier band; equals max(1, |1 - 4a|)."""
    return max(1.0, abs(1.0 - 4.0 * a))


def main() -> None:
    theta = np.linspace(0.0, np.pi, 400)
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    for a in [0.1, 0.25, 0.5, 0.65]:
        lam = band_eigenvalues(a, theta)
        ax1.plot(theta, lam, label=f"a = {a}")
    ax1.axhline(1.0, color="gray", ls=":", lw=1)
    ax1.axhline(-1.0, color="gray", ls=":", lw=1)
    ax1.set_xlabel(r"$\theta$ (Fourier mode)")
    ax1.set_ylabel(r"$\lambda(a, e^{i\theta}) = 1 - 2a(1-\cos\theta)$")
    ax1.set_title("Dispersion relation: eigenvalue band")
    ax1.legend()

    a_vals = np.linspace(-0.3, 0.9, 400)
    sr = np.array([spectral_radius(a) for a in a_vals])
    ax2.plot(a_vals, sr, color="crimson", lw=2)
    ax2.axhline(1.0, color="gray", ls=":", lw=1)
    ax2.axvline(0.0, color="green", ls="--", lw=1, label="a = 0")
    ax2.axvline(0.5, color="blue", ls="--", lw=1, label="a = 1/2 (threshold)")
    ax2.fill_betweenx([0.9, sr.max()], 0.0, 0.5, color="green", alpha=0.08)
    ax2.set_xlabel("diffusion coefficient a")
    ax2.set_ylabel("spectral radius")
    ax2.set_title("Spectral radius and the stability dichotomy")
    ax2.legend()

    fig.tight_layout()
    fig.savefig("dispersion.png", dpi=130)
    print("wrote dispersion.png")


if __name__ == "__main__":
    main()

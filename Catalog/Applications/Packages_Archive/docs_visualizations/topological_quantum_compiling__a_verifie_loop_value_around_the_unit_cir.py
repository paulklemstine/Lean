"""
Visualization: the loop value delta(A) = -(A^2 + A^-2) as the phase A runs
around the unit circle, highlighting the golden-ratio Fibonacci point
A = exp(3*pi*i/5) where delta = (1+sqrt 5)/2, and the eigenphases of the
Jones braid generator s = A*I + A^-1*E on the unit circle.
"""

from __future__ import annotations

import cmath
import math

import numpy as np
import matplotlib.pyplot as plt


def loop_value(A: complex) -> complex:
    return -(A**2 + A**-2)


def main() -> None:
    thetas = np.linspace(0.0, 2.0 * math.pi, 800)
    A_vals = [cmath.exp(1j * t) for t in thetas]
    deltas = [loop_value(A).real for A in A_vals]  # real on the unit circle

    A_star = cmath.exp(3j * math.pi / 5)
    delta_star = loop_value(A_star).real
    phi = (1.0 + math.sqrt(5.0)) / 2.0

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    ax1.plot(thetas, deltas, color="#2b6cb0", lw=2,
             label=r"$\delta(A)=-(A^2+A^{-2})$")
    ax1.axhline(phi, color="#dd6b20", ls="--", lw=1.5,
                label=r"golden ratio $\varphi$")
    ax1.plot(3 * math.pi / 5, delta_star, "o", color="#c53030", ms=9,
             label=r"$A=e^{3\pi i/5}$ (Fibonacci)")
    ax1.set_xlabel(r"phase angle $\theta$  ($A=e^{i\theta}$)")
    ax1.set_ylabel(r"loop value $\delta$")
    ax1.set_title("Loop value around the unit circle")
    ax1.legend(loc="upper right", fontsize=9)
    ax1.grid(alpha=0.3)

    # eigenphases of the braid generator s = A + A^-1 * x for the two
    # nonzero TL-eigenvalues x in {0, delta}: eigenvalues are A and A + A^-1*delta.
    ev = [A_star, A_star + (A_star**-1) * delta_star]
    circle = np.exp(1j * np.linspace(0, 2 * math.pi, 400))
    ax2.plot(circle.real, circle.imag, color="#a0aec0", lw=1)
    for e in ev:
        ax2.plot(e.real, e.imag, "o", ms=10)
        ax2.annotate(f"{e:.2f}", (e.real, e.imag), fontsize=8)
    ax2.set_aspect("equal")
    ax2.set_title(r"Eigenvalues of $s=A\,\mathbf{1}+A^{-1}E$")
    ax2.grid(alpha=0.3)

    fig.tight_layout()
    fig.savefig("loop_value_and_spectrum.png", dpi=150)
    print("wrote loop_value_and_spectrum.png")


if __name__ == "__main__":
    main()

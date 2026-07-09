"""Visualize how the plethysm phi_t deforms the coefficients of q_3.

q_3 = (4/3) p1^3 + (2/3) p3.  Under phi_t the p1^3 coefficient is scaled by
(1 - t)^3 and the p3 coefficient by (1 - t^3).  This plots the two deformed
coefficients as functions of t on [-1, 1], showing both vanish at t = 1 (the
Schur-Q fixed point) and recover the undeformed values at t = 0.
"""
from typing import List
import numpy as np
import matplotlib.pyplot as plt


def coeff_p1cubed(t: np.ndarray) -> np.ndarray:
    return (4.0 / 3.0) * (1.0 - t) ** 3


def coeff_p3(t: np.ndarray) -> np.ndarray:
    return (2.0 / 3.0) * (1.0 - t ** 3)


def main() -> None:
    t = np.linspace(-1.0, 1.0, 400)
    fig, ax = plt.subplots(figsize=(8, 5))
    ax.plot(t, coeff_p1cubed(t), label=r"coeff of $p_1^3$: $(4/3)(1-t)^3$")
    ax.plot(t, coeff_p3(t), label=r"coeff of $p_3$: $(2/3)(1-t^3)$")
    ax.axvline(0.0, color="gray", ls=":", lw=1)
    ax.axvline(1.0, color="red", ls="--", lw=1, label="t = 1 (fixed point)")
    ax.axhline(0.0, color="black", lw=0.6)
    ax.set_xlabel("t")
    ax.set_ylabel("deformed coefficient")
    ax.set_title(r"Plethystic deformation of $q_3$ coefficients under $\varphi_t$")
    ax.legend()
    fig.tight_layout()
    fig.savefig("phi_t_q3_coefficients.png", dpi=150)
    print("saved phi_t_q3_coefficients.png")


if __name__ == "__main__":
    main()

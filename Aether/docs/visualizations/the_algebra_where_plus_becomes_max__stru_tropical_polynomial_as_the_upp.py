"""Plot a tropical polynomial as the upper envelope of its monomial lines.

Renders each affine monomial c[i] + i*x as a faint line and overlays the
tropical polynomial (their pointwise maximum) as a bold convex piecewise-linear
curve, with the active-segment corners marked. Requires matplotlib + numpy.
"""
from __future__ import annotations
from typing import List
import numpy as np
import matplotlib.pyplot as plt


def trop_poly(c: List[float], x: np.ndarray) -> np.ndarray:
    return np.max(np.stack([c[i] + i * x for i in range(len(c))]), axis=0)


def main() -> None:
    c: List[float] = [0.0, 0.5, -2.0, 1.0]
    x = np.linspace(-5.0, 5.0, 1000)
    plt.figure(figsize=(9, 6))
    for i in range(len(c)):
        plt.plot(x, c[i] + i * x, lw=1, alpha=0.4,
                 label=f"monomial slope {i} (c={c[i]})")
    plt.plot(x, trop_poly(c, x), lw=3, color="black",
             label="tropPoly = max of lines")
    plt.title("Tropical polynomial as upper envelope of affine monomials")
    plt.xlabel("x"); plt.ylabel("value")
    plt.legend(); plt.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig("tropical_envelope.png", dpi=150)
    print("wrote tropical_envelope.png")


if __name__ == "__main__":
    main()

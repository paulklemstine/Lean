"""Visualization of the Christoffel-Darboux Airy kernel.

Produces three panels:
  (1) the two Airy solutions Ai, Bi (oscillation for x<0, edge near x=0);
  (2) a heatmap of the symmetric kernel K(x,y) = (Ai(x)Bi(y)-Bi(x)Ai(y))/(x-y);
  (3) the diagonal value K(x,x+h) overlaid on the constant -1/pi.

Requires numpy and matplotlib.
"""

from __future__ import annotations

import math
from typing import Callable, List, Tuple

import numpy as np
import matplotlib.pyplot as plt

AI0, AIP0 = 0.3550280538878172, -0.2588194037928068
BI0, BIP0 = 0.6149266274460007, 0.4482883573538264
PI = math.pi


def integrate_table(y0: float, yp0: float, lo: float, hi: float, h: float
                    ) -> Tuple[np.ndarray, np.ndarray, np.ndarray]:
    def rhs(t: float, u: float, v: float) -> Tuple[float, float]:
        return v, t * u

    def march(end: float, step: float) -> List[Tuple[float, float, float]]:
        n = max(1, int(abs(end) / abs(step)))
        s = end / n
        t, u, v = 0.0, y0, yp0
        out = [(t, u, v)]
        for _ in range(n):
            k1u, k1v = rhs(t, u, v)
            k2u, k2v = rhs(t + s / 2, u + s / 2 * k1u, v + s / 2 * k1v)
            k3u, k3v = rhs(t + s / 2, u + s / 2 * k2u, v + s / 2 * k2v)
            k4u, k4v = rhs(t + s, u + s * k3u, v + s * k3v)
            u += s / 6 * (k1u + 2 * k2u + 2 * k3u + k4u)
            v += s / 6 * (k1v + 2 * k2v + 2 * k3v + k4v)
            t += s
            out.append((t, u, v))
        return out

    data = sorted(set(march(lo, -h)) | set(march(hi, h)))
    xs = np.array([d[0] for d in data])
    return xs, np.array([d[1] for d in data]), np.array([d[2] for d in data])


AX, AY, AYP = integrate_table(AI0, AIP0, -6.0, 6.0, 1e-3)
BX, BY, BYP = integrate_table(BI0, BIP0, -6.0, 6.0, 1e-3)
Ai = lambda x: np.interp(x, AX, AY)
Bi = lambda x: np.interp(x, BX, BY)
Aip = lambda x: np.interp(x, AX, AYP)
Bip = lambda x: np.interp(x, BX, BYP)


def kernel(x: float, y: float) -> float:
    if abs(x - y) < 1e-9:
        return float(Aip(x) * Bi(x) - Bip(x) * Ai(x))  # -W diagonal value
    return float((Ai(x) * Bi(y) - Bi(x) * Ai(y)) / (x - y))


def main() -> None:
    fig, axes = plt.subplots(1, 3, figsize=(16, 4.5))

    xs = np.linspace(-5, 3, 400)
    axes[0].plot(xs, Ai(xs), label="Ai(x)")
    axes[0].plot(xs, Bi(xs), label="Bi(x)")
    axes[0].axvline(0, color="k", ls=":", lw=0.8)
    axes[0].set_ylim(-1.2, 1.5)
    axes[0].set_title("Airy solutions of y'' = x y")
    axes[0].legend()

    grid = np.linspace(-3, 3, 120)
    Z = np.array([[kernel(x, y) for y in grid] for x in grid])
    im = axes[1].imshow(Z, extent=[-3, 3, -3, 3], origin="lower", cmap="RdBu",
                        vmin=-0.5, vmax=0.5)
    axes[1].set_title("Symmetric kernel K(x,y)")
    fig.colorbar(im, ax=axes[1], fraction=0.046)

    xv = np.linspace(-3, 3, 200)
    diag = np.array([kernel(x, x + 1e-3) for x in xv])
    axes[2].plot(xv, diag, label="K(x, x+h)")
    axes[2].axhline(-1 / PI, color="r", ls="--", label="-1/pi (constant)")
    axes[2].set_title("Flat diagonal = -W = -1/pi")
    axes[2].legend()

    fig.tight_layout()
    fig.savefig("airy_kernel_visualization.png", dpi=130)
    print("saved airy_kernel_visualization.png")


if __name__ == "__main__":
    main()

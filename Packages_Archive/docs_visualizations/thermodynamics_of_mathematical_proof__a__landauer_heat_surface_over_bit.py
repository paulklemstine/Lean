"""Visualization: Landauer heat surface as a function of erased bits and temperature.

Renders cost(bits, T) = bits * kB * T * ln 2 as a heatmap over erased bits and
absolute temperature, showing the linear scaling in both variables.
"""

from __future__ import annotations

from math import log

import numpy as np
import matplotlib.pyplot as plt

BOLTZMANN_K: float = 1.380649e-23
LN2: float = log(2.0)


def main() -> None:
    bits = np.linspace(0, 64, 200)
    temps = np.linspace(1, 400, 200)
    BB, TT = np.meshgrid(bits, temps)
    heat = BB * BOLTZMANN_K * TT * LN2  # joules

    fig, ax = plt.subplots(figsize=(8, 5))
    im = ax.pcolormesh(BB, TT, heat, shading="auto", cmap="inferno")
    fig.colorbar(im, ax=ax, label="dissipated heat (J)")
    ax.set_xlabel("bits erased")
    ax.set_ylabel("temperature T (K)")
    ax.set_title("Landauer heat: cost = bits * kB * T * ln 2")
    fig.tight_layout()
    fig.savefig("landauer_heat_surface.png", dpi=150)
    print("wrote landauer_heat_surface.png")


if __name__ == "__main__":
    main()

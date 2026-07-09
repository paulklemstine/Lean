"""3D rendering of the Moebius band with points colored by their value phi."""
from __future__ import annotations
import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D  # noqa: F401

def main() -> None:
    u = np.linspace(0, 2 * np.pi, 200)     # around the band (maps to x)
    v = np.linspace(-1, 1, 40)             # across the width (maps to y)
    U, V = np.meshgrid(u, v)
    # Standard smooth parametrization of the Moebius band.
    X = (1 + 0.5 * V * np.cos(U / 2)) * np.cos(U)
    Y = (1 + 0.5 * V * np.cos(U / 2)) * np.sin(U)
    Z = 0.5 * V * np.sin(U / 2)
    # Value-like invariant on the smooth model: V * cos(U/2) (twist-anti-invariant).
    C = V * np.cos(U / 2)
    fig = plt.figure(figsize=(9, 6))
    ax = fig.add_subplot(111, projection="3d")
    surf = ax.plot_surface(X, Y, Z, facecolors=plt.cm.RdBu_r((C - C.min()) / (C.ptp() + 1e-9)),
                           rstride=1, cstride=2, linewidth=0, antialiased=True)
    ax.set_title("Moebius band colored by an orientation-odd invariant")
    ax.set_axis_off(); fig.tight_layout()
    fig.savefig("moebius3d.png", dpi=140); print("wrote moebius3d.png")

if __name__ == "__main__":
    main()

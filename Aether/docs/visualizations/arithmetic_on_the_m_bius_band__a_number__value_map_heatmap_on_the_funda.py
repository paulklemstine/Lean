"""Heatmap of the value map phi(x, y) = y(2x - 1) over the fundamental strip."""
from __future__ import annotations
import numpy as np
import matplotlib.pyplot as plt

def value(x: np.ndarray, y: np.ndarray) -> np.ndarray:
    return y * (2.0 * x - 1.0)

def main() -> None:
    H = 3.0
    xs, ys = np.linspace(0, 1, 400), np.linspace(-H, H, 400)
    X, Y = np.meshgrid(xs, ys)
    fig, ax = plt.subplots(figsize=(8, 6))
    im = ax.pcolormesh(X, Y, value(X, Y), cmap="RdBu_r", shading="auto")
    fig.colorbar(im, ax=ax, label=r"$\varphi(x,y)=y(2x-1)$")
    ax.axvline(0.5, color="k", ls="--", lw=2, label=r"central circle $x=1/2$")
    ax.axhline(0.0, color="green", ls="--", lw=2, label="zero section $y=0$")
    ax.set_xlabel("x (width)"); ax.set_ylabel("y (height)")
    ax.set_title("Value map on the Moebius strip")
    ax.legend(loc="upper right"); fig.tight_layout()
    fig.savefig("value_heatmap.png", dpi=140); print("wrote value_heatmap.png")

if __name__ == "__main__":
    main()

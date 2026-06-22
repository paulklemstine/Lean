"""Visualize the (1+i)-tower in the complex plane: the 45-degree spiral
whose period-8 return to the positive real axis is the source of Gleason's 8."""
from __future__ import annotations
import math
import matplotlib.pyplot as plt

I = complex(0, 1)

def main() -> None:
    N = 16
    pts = [(1 + I) ** n for n in range(N + 1)]
    xs = [z.real for z in pts]
    ys = [z.imag for z in pts]

    fig, ax = plt.subplots(figsize=(8, 8))
    ax.plot(xs, ys, "-o", color="#3066BE", lw=1.5, ms=5, label="(1+i)^n")
    for n, z in enumerate(pts):
        if n % 8 == 0 and z.real > 0 and abs(z.imag) < 1e-6:
            ax.scatter([z.real], [z.imag], color="#C1121F", s=120, zorder=5)
            ax.annotate(f"n={n}\\n(positive real)", (z.real, z.imag),
                        textcoords="offset points", xytext=(8, 8),
                        color="#C1121F", fontweight="bold")
    ax.axhline(0, color="gray", lw=0.6)
    ax.axvline(0, color="gray", lw=0.6)
    ax.set_aspect("equal", "box")
    ax.set_title("The (1+i)-tower: positive-real return has period 8")
    ax.set_xlabel("Re");  ax.set_ylabel("Im")
    ax.legend()
    plt.tight_layout()
    plt.savefig("tower.png", dpi=150)
    print("wrote tower.png")

if __name__ == "__main__":
    main()

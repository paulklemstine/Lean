"""Visualization: Kovacic parity landscape and Airy vs. solvable solutions.

Generates two panels:
  (left)  the degree-parity decision over the monomial family y'' = x^k y:
          odd k -> obstructed (red), even k -> solvable (green);
  (right) the genuine closed-form solution y = exp(x^2/2) of the solvable
          equation y'' = (x^2+1) y, contrasted with a numerically integrated
          Airy solution of y'' = x y (which has no closed form).

Requires numpy and matplotlib.
"""
from __future__ import annotations
import numpy as np
import matplotlib.pyplot as plt

def airy_numeric(x_max: float = 4.0, n: int = 4000):
    """Integrate y'' = x y from x0 = -8 with a decaying initial condition."""
    x0, x1 = -8.0, x_max
    xs = np.linspace(x0, x1, n)
    h = xs[1] - xs[0]
    y = np.zeros(n); yp = np.zeros(n)
    y[0], yp[0] = 1e-4, 1e-4  # small decaying tail on the left
    for i in range(n - 1):
        x = xs[i]
        y[i + 1] = y[i] + h * yp[i]
        yp[i + 1] = yp[i] + h * (x * y[i])
    return xs, y

def main() -> None:
    fig, (ax0, ax1) = plt.subplots(1, 2, figsize=(12, 5))

    ks = list(range(1, 9))
    colors = ["#2ca02c" if k % 2 == 0 else "#d62728" for k in ks]
    labels = ["solvable" if k % 2 == 0 else "obstructed" for k in ks]
    ax0.bar(ks, [1] * len(ks), color=colors)
    for k, lab in zip(ks, labels):
        ax0.text(k, 0.5, lab, ha="center", va="center", rotation=90,
                 color="white", fontweight="bold")
    ax0.set_title("Kovacic parity decision: y'' = x^k y")
    ax0.set_xlabel("degree k of the coefficient x^k")
    ax0.set_yticks([])

    xs = np.linspace(-2.5, 2.0, 400)
    ax1.plot(xs, np.exp(xs ** 2 / 2.0), label="y = exp(x^2/2): solvable y''=(x^2+1)y",
             color="#2ca02c", lw=2)
    ax, ay = airy_numeric(2.0)
    ay = ay / np.max(np.abs(ay))
    ax1.plot(ax, ay, label="Airy y''=x y (no closed form)", color="#d62728", lw=2)
    ax1.set_title("Closed-form vs. non-closed-form solutions")
    ax1.set_xlabel("x"); ax1.legend(); ax1.grid(alpha=0.3)

    fig.tight_layout()
    fig.savefig("eml_kovacic_parity.png", dpi=150)
    print("wrote eml_kovacic_parity.png")

if __name__ == "__main__":
    main()

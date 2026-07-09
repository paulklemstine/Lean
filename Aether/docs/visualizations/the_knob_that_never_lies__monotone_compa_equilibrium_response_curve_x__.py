"""Plot the strictly increasing equilibrium response curve x*(a)."""
from __future__ import annotations
import math
from typing import List
import numpy as np
import matplotlib.pyplot as plt


def fixed_point(a: float, b: float, c: float, x0: float = 1.0,
                tol: float = 1e-14, max_iter: int = 100000) -> float:
    x = x0
    for _ in range(max_iter):
        nx = math.exp(a) * math.log(b * x + c)
        if abs(nx - x) < tol:
            return nx
        x = nx
    return x


def main() -> None:
    b, c = 1.0, 2.0
    a_vals: List[float] = list(np.linspace(0.0, 0.49, 200))
    x_stars = [fixed_point(a, b, c) for a in a_vals]
    plt.figure(figsize=(8, 5))
    plt.plot(a_vals, x_stars, lw=2.5, color="#3056d3")
    plt.title(r"Equilibrium response $x^*(a)$ of $f_a(x)=e^{a}\log(x+2)$")
    plt.xlabel(r"scaling parameter $a$")
    plt.ylabel(r"fixed point $x^*(a)$")
    plt.grid(True, alpha=0.3)
    plt.annotate("strictly increasing\n(injective control)",
                 xy=(0.35, fixed_point(0.35, b, c)), xytext=(0.05, 2.1),
                 arrowprops=dict(arrowstyle="->"))
    plt.tight_layout()
    plt.savefig("eml_response_curve.png", dpi=150)
    print("saved eml_response_curve.png")


if __name__ == "__main__":
    main()

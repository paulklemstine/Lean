"""Cobweb diagram of the exp-log contraction iteration converging to x*."""
from __future__ import annotations
import math
import numpy as np
import matplotlib.pyplot as plt


def f(a: float, b: float, c: float, x: float) -> float:
    return math.exp(a) * math.log(b * x + c)


def main() -> None:
    a, b, c = 0.30, 1.0, 2.0
    lo, hi = 0.5, 3.0
    xs = np.linspace(lo, hi, 400)
    ys = [f(a, b, c, x) for x in xs]
    plt.figure(figsize=(7, 7))
    plt.plot(xs, ys, lw=2, color="#3056d3", label=r"$f_a(x)=e^{a}\log(bx+c)$")
    plt.plot(xs, xs, "--", color="gray", label=r"$y=x$")
    # cobweb
    x = 0.7
    for _ in range(12):
        y = f(a, b, c, x)
        plt.plot([x, x], [x, y], color="#d33", lw=0.9)
        plt.plot([x, y], [y, y], color="#d33", lw=0.9)
        x = y
    plt.title("Cobweb: exp-log contraction converges to the unique fixed point")
    plt.xlabel("x"); plt.ylabel("f(x)")
    plt.legend(); plt.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig("eml_cobweb.png", dpi=150)
    print("saved eml_cobweb.png")


if __name__ == "__main__":
    main()

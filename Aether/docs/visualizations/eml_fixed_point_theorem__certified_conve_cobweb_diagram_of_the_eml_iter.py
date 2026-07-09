"""Cobweb plot of the EML iteration x_{n+1} = exp(a)*log(x+2).

Renders the graph of f, the diagonal y = x, and the staircase/cobweb path of the
Picard iteration converging to the fixed point. Requires matplotlib + numpy.
"""
from __future__ import annotations
import math
import numpy as np
import matplotlib.pyplot as plt


def f(a: float, x: float) -> float:
    return math.exp(a) * math.log(x + 2.0)


def cobweb(a: float = 0.5, x0: float = 1.2, steps: int = 12) -> None:
    xs = np.linspace(0.5, 3.0, 400)
    ys = [f(a, x) for x in xs]

    fig, ax = plt.subplots(figsize=(7, 7))
    ax.plot(xs, ys, "b-", lw=2, label=r"$f(x)=e^{a}\log(x+2)$")
    ax.plot(xs, xs, "k--", lw=1, label=r"$y=x$")

    x = x0
    for _ in range(steps):
        y = f(a, x)
        ax.plot([x, x], [x, y], "r-", lw=0.8)   # vertical to the curve
        ax.plot([x, y], [y, y], "r-", lw=0.8)   # horizontal to the diagonal
        x = y

    ax.scatter([x], [x], color="green", zorder=5, label="fixed point $x^*$")
    ax.set_title(f"EML cobweb diagram  (a={a})")
    ax.set_xlabel("x"); ax.set_ylabel("f(x)")
    ax.legend(); ax.grid(alpha=0.3)
    plt.tight_layout()
    plt.savefig("eml_cobweb.png", dpi=150)
    print("saved eml_cobweb.png")


if __name__ == "__main__":
    cobweb()

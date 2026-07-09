"""Visualize an EML function and its syntactically-computed derivative."""
from __future__ import annotations
import math
import matplotlib.pyplot as plt
import numpy as np


def f(x: float) -> float:        # eval of  x * exp(x) + 7
    return x * math.exp(x) + 7.0


def df_symbolic(x: float) -> float:  # eval(D t):  exp(x) + x*exp(x)
    return math.exp(x) + x * math.exp(x)


def main() -> None:
    xs = np.linspace(-3.0, 2.0, 400)
    ys = [f(x) for x in xs]
    dys = [df_symbolic(x) for x in xs]
    fig, ax = plt.subplots(figsize=(8, 5))
    ax.plot(xs, ys, label="f(x) = x·e^x + 7  (EML)", lw=2)
    ax.plot(xs, dys, label="D f (syntactic derivative, also EML)", lw=2, ls="--")
    ax.axhline(0, color="gray", lw=0.5)
    ax.set_title("An EML function and its EML derivative")
    ax.set_xlabel("x"); ax.set_ylabel("value")
    ax.legend(); ax.grid(alpha=0.3)
    fig.tight_layout()
    fig.savefig("eml_derivative.png", dpi=150)
    print("wrote eml_derivative.png")


if __name__ == "__main__":
    main()

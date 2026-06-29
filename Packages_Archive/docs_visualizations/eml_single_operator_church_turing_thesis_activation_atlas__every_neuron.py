"""Visualization: every standard activation, rebuilt from the single eml operator,
plotted against its textbook reference. Saves eml_activations.png."""
from __future__ import annotations
import math
from typing import Callable, List
import numpy as np
import matplotlib.pyplot as plt


def safe_log(y: float) -> float:
    return math.log(y) if y > 0.0 else 0.0


def eml(x: float, y: float) -> float:
    return math.exp(x) - safe_log(y)


def exp_via_eml(x: float) -> float:
    return eml(x, 1.0)


def log_via_eml(y: float) -> float:
    return 1.0 - eml(0.0, y)


def sigmoid(x: float) -> float:
    return 1.0 / (1.0 + exp_via_eml(-x)) if (1.0 + exp_via_eml(-x)) != 0 else 0.0


def softplus(x: float) -> float:
    return log_via_eml(1.0 + exp_via_eml(x))


def tanh_eml(x: float) -> float:
    s = (exp_via_eml(x) - exp_via_eml(-x)) * 0.5
    c = (exp_via_eml(x) + exp_via_eml(-x)) * 0.5
    return s / c if c != 0 else 0.0


def silu(x: float) -> float:
    return x * sigmoid(x)


def main() -> None:
    xs = np.linspace(-6.0, 6.0, 600)
    panels: List[tuple] = [
        ("Logistic sigmoid", sigmoid, lambda t: 1 / (1 + math.exp(-t))),
        ("Softplus", softplus, lambda t: math.log1p(math.exp(t))),
        ("tanh", tanh_eml, math.tanh),
        ("SiLU / swish", silu, lambda t: t / (1 + math.exp(-t))),
    ]
    fig, axes = plt.subplots(2, 2, figsize=(11, 8))
    for ax, (name, f_eml, f_ref) in zip(axes.ravel(), panels):
        y_eml = [f_eml(float(x)) for x in xs]
        y_ref = [f_ref(float(x)) for x in xs]
        ax.plot(xs, y_ref, lw=4, alpha=0.3, label="reference")
        ax.plot(xs, y_eml, lw=1.5, color="crimson", label="built from eml")
        ax.set_title(name)
        ax.grid(alpha=0.3)
        ax.legend(loc="best", fontsize=8)
    fig.suptitle("Neural activations rebuilt from the single primitive "
                 "eml(x, y) = exp(x) - log(y)", fontsize=13)
    fig.tight_layout(rect=(0, 0, 1, 0.96))
    fig.savefig("eml_activations.png", dpi=140)
    print("wrote eml_activations.png")


if __name__ == "__main__":
    main()

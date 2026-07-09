"""
Visualization: the tower of growth rates and the dominance order.

Renders, in the log-log-safe domain, the iterated levels
    log x  <  x  <  exp x  <  exp(exp x)
and overlays large powers x^a to make exp_dominates_pow visible: every power,
no matter how steep, is eventually overtaken by exp x.

Saves 'transseries_tower.png'.
"""
from __future__ import annotations
import math
from typing import List
import matplotlib.pyplot as plt
import numpy as np

def main() -> None:
    x = np.linspace(2.0, 18.0, 400)
    fig, ax = plt.subplots(figsize=(9, 6))
    # Plot ln of each level so the doubly-exponential curve stays on-screen.
    ax.plot(x, np.log(np.log(x)), label=r"$\log\log x$ (height -2)")
    ax.plot(x, np.log(x),         label=r"$\log x$ (height -1)")
    ax.plot(x, x,                 label=r"$x$ (height 0)")          # ln(exp x) = x
    ax.plot(x, np.exp(x) / 1.0,   label=r"$\ln(e^{e^x}) = e^x$ (height 2)")
    for a in (3.0, 8.0, 20.0):
        ax.plot(x, a * np.log(x), "--", alpha=0.6, label=rf"$\ln(x^{{{a:g}}})$")
    ax.set_yscale("symlog")
    ax.set_xlabel("x")
    ax.set_ylabel("natural log of value (symlog scale)")
    ax.set_title("The transseries tower: every power x^a is overtaken by exp x")
    ax.legend(fontsize=8, loc="upper left")
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig("transseries_tower.png", dpi=150)
    print("wrote transseries_tower.png")

if __name__ == "__main__":
    main()

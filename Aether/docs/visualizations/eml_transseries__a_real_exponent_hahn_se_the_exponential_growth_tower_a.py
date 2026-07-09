"""Visualization: the transmonomial growth tower and exp-dominance.

Generates two panels:
  (left)  a log-log-style ladder showing log x, x, e^x, e^(e^x) on a sample range,
          making vivid that each tower height eventually crushes the one below;
  (right) the ratio x^a / e^x -> 0 for several exponents a, illustrating that
          e^x dominates x^a for every real a (theorem `exp_dominates_pow`).

Requires matplotlib. Saves 'transseries_tower.png'.
"""

from __future__ import annotations

import math
from typing import List

import matplotlib.pyplot as plt
import numpy as np


def main() -> None:
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5))

    # Panel 1: the tower of growth scales (plotted as log of each value).
    x = np.linspace(1.5, 4.0, 400)
    scales = {
        "log x  (h=-1)": np.log(np.log(x + 1.0) + 1.0),
        "x  (h=0)": np.log(x),
        "e^x  (h=1)": x,                       # log(e^x) = x
        "e^(e^x)  (h=2)": np.exp(x),           # log(e^(e^x)) = e^x
    }
    for name, y in scales.items():
        ax1.plot(x, y, linewidth=2.2, label=name)
    ax1.set_yscale("log")
    ax1.set_title("The tower of growth scales (log of each transmonomial)")
    ax1.set_xlabel("x")
    ax1.set_ylabel("log(value)  [log scale]")
    ax1.legend()
    ax1.grid(True, which="both", alpha=0.25)

    # Panel 2: e^x dominates x^a for every a -> ratios decay to 0.
    xr = np.linspace(2.0, 60.0, 600)
    for a in (2, 5, 10, 20):
        ratio = np.exp(a * np.log(xr) - xr)  # x^a / e^x, computed stably
        ax2.plot(xr, ratio, linewidth=2.0, label=f"x^{a} / e^x")
    ax2.set_yscale("log")
    ax2.set_title("e^x dominates x^a for every a  (ratios -> 0)")
    ax2.set_xlabel("x")
    ax2.set_ylabel("x^a / e^x  [log scale]")
    ax2.legend()
    ax2.grid(True, which="both", alpha=0.25)

    fig.suptitle("EML Transseries: asymptotic dominance of the exponential tower",
                 fontsize=13)
    fig.tight_layout(rect=(0, 0, 1, 0.96))
    fig.savefig("transseries_tower.png", dpi=150)
    print("Saved transseries_tower.png")


if __name__ == "__main__":
    main()

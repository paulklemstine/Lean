"""Visualization: the Jarzynski fluctuation surcharge grows as erasure speeds up.

Plots the mean dissipated work E[W] (in units of kT ln2) versus a fluctuation-strength
parameter for a family of erasure protocols, showing the second-law floor dF = kT ln2
and that the surcharge E[W] - dF is strictly positive away from the reversible limit.
Requires matplotlib; saves landauer_surcharge.png.
"""
from __future__ import annotations
import math
from typing import List
import matplotlib.pyplot as plt

def expect(p: List[float], f: List[float]) -> float:
    return sum(px * fx for px, fx in zip(p, f))

def mean_work_units(spread: float) -> float:
    # 4-state protocol whose work spreads around dF=1 by +/- 'spread' (units of kT ln2)
    p = [0.25, 0.25, 0.25, 0.25]
    work = [1.0 - spread, 1.0 - spread/3, 1.0 + spread/3, 1.0 + spread]
    alpha = 1.0  # work measured in units of kT, dF = ln2 here folded into 'work' scale
    mean_w = expect(p, work)
    z = sum(px * math.exp(-(wx - mean_w)) for px, wx in zip(p, work))
    corr = math.log(z)
    return mean_w + corr  # E[W] including the surcharge, in units of dF

def main() -> None:
    spreads = [i / 50.0 for i in range(0, 50)]
    means = [mean_work_units(s) for s in spreads]
    plt.figure(figsize=(8, 5))
    plt.plot(spreads, means, lw=2, label=r"$E[W]/\Delta F$ (with surcharge)")
    plt.axhline(1.0, color="crimson", ls="--", label=r"reversible floor $\Delta F=kT\ln2$")
    plt.fill_between(spreads, 1.0, means, alpha=0.2, color="steelblue",
                     label="strictly positive surcharge")
    plt.xlabel("work fluctuation strength (units of $kT\\ln2$)")
    plt.ylabel("mean dissipated work / $\\Delta F$")
    plt.title("Landauer saturation: surcharge vanishes only in the reversible limit")
    plt.legend()
    plt.tight_layout()
    plt.savefig("landauer_surcharge.png", dpi=150)
    print("saved landauer_surcharge.png")

if __name__ == "__main__":
    main()

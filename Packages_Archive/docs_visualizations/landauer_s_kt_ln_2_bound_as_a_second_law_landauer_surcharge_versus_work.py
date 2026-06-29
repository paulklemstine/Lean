"""Visualize the Landauer surcharge E[W] - kT ln 2 versus work-fluctuation size.

Saves 'landauer_surcharge.png'. Requires matplotlib + numpy.
"""
from __future__ import annotations
import math
import numpy as np
import matplotlib.pyplot as plt

def expect(p, f):
    return float(np.sum(np.asarray(p) * np.asarray(f)))

def main() -> None:
    k, T = 1.380649e-23, 300.0
    alpha = 1.0 / (k * T)
    dF = k * T * math.log(2)
    spreads = np.linspace(0.0, 4.0, 200)        # fluctuation amplitude (in units of dF)
    surcharges = []
    for s in spreads:
        p = [0.5, 0.5]
        w_raw = [(1.0 - s) * dF, (1.0 + s) * dF]
        Z = expect(p, [math.exp(-alpha * wi) for wi in w_raw])
        c = dF + math.log(Z) / alpha
        w = [wi + c for wi in w_raw]
        surcharges.append(expect(p, w) - dF)
    plt.figure(figsize=(8, 5))
    plt.plot(spreads, np.array(surcharges) / dF, lw=2, color="crimson")
    plt.axhline(0.0, color="k", lw=0.8)
    plt.xlabel("work-fluctuation amplitude  s  (W = (1 ± s) ΔF)")
    plt.ylabel("surcharge (E[W] - kT ln 2) / (kT ln 2)")
    plt.title("Landauer surcharge grows with work fluctuations (≥ 0 always)")
    plt.grid(alpha=0.3)
    plt.tight_layout()
    plt.savefig("landauer_surcharge.png", dpi=150)
    print("wrote landauer_surcharge.png")

if __name__ == "__main__":
    main()

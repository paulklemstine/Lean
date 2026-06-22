"""
Visualization: the E = 1 phase boundary of cosmic loneliness.

Plots the expected number of communicating civilizations
    E = N * p^n
as a function of the per-hurdle probability p, for several hurdle counts n,
with N = 1e10 habitable worlds. The horizontal line E = 1 separates the
"empty cosmos" regime (below) from the "crowded cosmos" regime (above).

Requires: matplotlib, numpy.  Run:  python visualization.py
"""
import numpy as np
import matplotlib.pyplot as plt

N = 1e10
p = np.linspace(0.01, 0.6, 400)

plt.figure(figsize=(9, 6))
for n in [7, 9, 11, 13]:
    E = N * p ** n
    plt.plot(p, E, label=f"{n} hurdles")

plt.axhline(1.0, color="black", linestyle="--", linewidth=1.5,
            label="E = 1 (loneliness threshold)")
plt.axvline(0.1, color="grey", linestyle=":", linewidth=1.2,
            label="conservative cap p = 0.1")
plt.yscale("log")
plt.xlabel("per-hurdle success probability  p")
plt.ylabel("expected civilizations  E = N · pⁿ   (log scale)")
plt.title("The Fermi Paradox as a Pigeonhole Principle\n"
          "Expected civilizations vs. per-hurdle probability (N = 1e10)")
plt.legend()
plt.grid(True, which="both", alpha=0.3)
plt.tight_layout()
plt.savefig("fermi_phase_boundary.png", dpi=150)
print("Saved fermi_phase_boundary.png")

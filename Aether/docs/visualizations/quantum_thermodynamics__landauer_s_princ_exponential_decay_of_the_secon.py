"""Visualisation: exponential decay of the second-law violation bound."""
import math
import matplotlib.pyplot as plt

K_B = 1.380649e-23
T = 300.0
alpha = 1.0 / (K_B * T)

xis = [i * 0.1 for i in range(0, 61)]          # margin in units of kT
ceiling = [math.exp(-x) for x in xis]          # exp(-xi/(kT)) with xi = x*kT

fig, ax = plt.subplots(figsize=(8, 5))
ax.plot(xis, ceiling, color="#C44E52", lw=2.5,
        label=r"Chernoff ceiling $e^{-\xi/(kT)}$")
ax.fill_between(xis, ceiling, color="#C44E52", alpha=0.15)
ax.set_xlabel(r"violation margin $\xi$  (units of $kT$)")
ax.set_ylabel(r"max probability  $P[W < \Delta F - \xi]$")
ax.set_title("Second-law violations are exponentially rare")
ax.set_yscale("log")
ax.grid(True, which="both", ls=":", alpha=0.5)
ax.legend()
plt.tight_layout()
plt.savefig("landauer_violation_bound.png", dpi=150)
print("saved landauer_violation_bound.png")

"""Visualize geometric energy decay and the logarithmic depth law for
Hodge message passing on a path graph. Requires matplotlib + numpy."""
from __future__ import annotations
import math
import numpy as np
import matplotlib.pyplot as plt

# Path graph on 4 vertices -> incidence B (edges x vertices)
B = np.array([[1.0, -1.0, 0.0, 0.0],
              [0.0, 1.0, -1.0, 0.0],
              [0.0, 0.0, 1.0, -1.0]])
L = B.T @ B
lam = 2.0 - 2.0 * math.cos(3 * math.pi / 4)
mu = 2.0 - 2.0 * math.cos(1 * math.pi / 4)
alpha = 1.0 / lam
rho = 1.0 - alpha * mu * (2.0 - alpha * lam)

x = np.array([1.0, -1.0, 1.0, -1.0])
e0 = float(x @ x)
ks = list(range(0, 25))
energies, bounds = [], []
xk = x.copy()
for k in ks:
    energies.append(float(xk @ xk))
    bounds.append(rho ** k * e0)
    xk = xk - alpha * (L @ xk)

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))
ax1.semilogy(ks, energies, "o-", label="actual residual energy ||T^k x||^2")
ax1.semilogy(ks, bounds, "--", label=f"geometric bound rho^k ||x||^2 (rho={rho:.3f})")
ax1.set_xlabel("depth k"); ax1.set_ylabel("Dirichlet energy (log scale)")
ax1.set_title("Geometric energy decay"); ax1.legend(); ax1.grid(True, which="both", alpha=0.3)

epss = np.logspace(0, -9, 40)
depths = [max(0, math.ceil(math.log(eps / e0) / math.log(rho))) for eps in epss]
ax2.plot(-np.log10(epss), depths, "s-")
ax2.set_xlabel("accuracy digits  log10(1/eps)"); ax2.set_ylabel("required depth N(eps)")
ax2.set_title("Logarithmic depth law: depth ~ log(1/eps)")
ax2.grid(True, alpha=0.3)
plt.tight_layout(); plt.savefig("hodge_depth.png", dpi=140)
print("saved hodge_depth.png")

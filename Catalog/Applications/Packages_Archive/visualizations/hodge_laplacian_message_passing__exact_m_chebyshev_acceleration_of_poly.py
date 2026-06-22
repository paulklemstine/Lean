"""Compare the worst-case band contraction of a plain repeated step against
the Chebyshev-optimal polynomial filter. Saves 'chebyshev_speedup.png'."""
from __future__ import annotations
import math
import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

mu, lam = 0.1, 4.0
band = np.linspace(mu, lam, 4001)
kappa = mu / lam
r = (1 - math.sqrt(kappa)) / (1 + math.sqrt(kappa))
x = (lam + mu) / (lam - mu)

ms = np.arange(1, 25)
plain = np.array([np.max(np.abs((1 - band / lam) ** m)) for m in ms])
cheb = np.array([r ** m / math.cosh(m * math.acosh(x)) for m in ms])

fig, ax = plt.subplots(figsize=(8, 5))
ax.semilogy(ms, plain, "o-", label="plain repeated step (1 - nu/lambda)^m")
ax.semilogy(ms, cheb, "s-", label="Chebyshev optimum rho_m")
ax.set_title("Worst-case contraction max_{nu in [mu,lambda]} |p(nu)|")
ax.set_xlabel("filter degree m"); ax.set_ylabel("worst-case |p(nu)|")
ax.legend(); ax.grid(True, which="both", alpha=0.3)
fig.tight_layout()
fig.savefig("chebyshev_speedup.png", dpi=130)
print("saved chebyshev_speedup.png")

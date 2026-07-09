"""Visualize EML approximation of x^2 by t |-> p(log(1+t)) and the error decay.
Requires matplotlib and numpy."""
from __future__ import annotations
import math
import numpy as np
import matplotlib.pyplot as plt


def fit_polynomial_in_log(target, degree: int, num_nodes: int = 300):
    log2 = math.log(2.0)
    us, vals = [], []
    for k in range(num_nodes):
        cheb = math.cos(math.pi * (k + 0.5) / num_nodes)
        u = 0.5 * log2 * (cheb + 1.0)
        us.append(u)
        vals.append(target(math.exp(u) - 1.0))
    A = np.vander(np.array(us), degree + 1, increasing=True)
    coeffs, *_ = np.linalg.lstsq(A, np.array(vals), rcond=None)
    return coeffs


def eml(coeffs, t):
    u = np.log(1.0 + t)
    return np.polyval(coeffs[::-1], u)


target = lambda t: t ** 2
ts = np.linspace(0.0, 1.0, 400)

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

for deg in (1, 2, 4):
    c = fit_polynomial_in_log(target, deg)
    ax1.plot(ts, eml(c, ts), label=f"deg {deg}")
ax1.plot(ts, target(ts), "k--", lw=2, label="t^2")
ax1.set_title("EML approximants p(log(1+t)) vs t^2")
ax1.set_xlabel("t"); ax1.set_ylabel("value"); ax1.legend()

degs = list(range(1, 11))
errs = []
for deg in degs:
    c = fit_polynomial_in_log(target, deg)
    errs.append(float(np.max(np.abs(eml(c, ts) - target(ts)))))
ax2.semilogy(degs, errs, "o-")
ax2.set_title("Supremum error vs polynomial degree")
ax2.set_xlabel("degree"); ax2.set_ylabel("sup |t^2 - p(log(1+t))|")
ax2.grid(True, which="both", ls=":")

plt.tight_layout()
plt.savefig("eml_approximation.png", dpi=150)
print("Saved eml_approximation.png")

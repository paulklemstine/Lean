"""Visualization: the three EML solution shapes on a log-scaled y-axis.

Plots the canonical solutions of the logarithmic, exponential, and power EML
coefficient ODEs, illustrating their wildly different growth rates. Requires
matplotlib and numpy.
"""
import numpy as np
import matplotlib.pyplot as plt

x = np.linspace(0.05, 3.0, 400)
y_log = np.exp(x * np.log(x) - x)        # y' = (log x) y    (Stirling exponent)
y_exp = np.exp(np.exp(x))                 # y' = (exp x) y    (double exponential)
y_pow = np.exp(2.5 * np.log(x))           # y' = (a/x) y, a=2.5  (power x^2.5)

fig, ax = plt.subplots(figsize=(8, 5))
ax.semilogy(x, y_log, label=r"$e^{x\log x - x}$  (log coeff)")
ax.semilogy(x, y_exp, label=r"$e^{e^x}$  (exp coeff)")
ax.semilogy(x, y_pow, label=r"$x^{2.5}$  (power coeff)")
ax.set_xlabel("x")
ax.set_ylabel("y(x)  (log scale)")
ax.set_title("Closed-form solutions of first-order EML ODEs")
ax.legend()
ax.grid(True, which="both", alpha=0.3)
plt.tight_layout()
plt.savefig("eml_solutions.png", dpi=150)
print("wrote eml_solutions.png")

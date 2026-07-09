"""Visualization: the EML growth tower and the collapse of ratios to zero.
Generates two panels:
  (left)  log-log race of x^5, e^x, e^{e^x} showing the height hierarchy;
  (right) the ratios x^n/e^x and (e^x)^n/e^{e^x} tending to 0 (little-o facts).
"""
import numpy as np
import matplotlib.pyplot as plt

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5))

x = np.linspace(0.5, 4.0, 400)
ax1.plot(x, x**5, label=r"$x^5$ (height 0)")
ax1.plot(x, np.exp(x), label=r"$e^x$ (height 1)")
ax1.plot(x, np.exp(np.exp(x)), label=r"$e^{e^x}$ (height 2)")
ax1.set_yscale("log")
ax1.set_title("The EML growth tower: taller towers dominate")
ax1.set_xlabel("x"); ax1.set_ylabel("value (log scale)")
ax1.legend(); ax1.grid(True, which="both", alpha=0.3)

xr = np.linspace(1.0, 6.0, 400)
ax2.plot(xr, xr**5 / np.exp(xr), label=r"$x^5 / e^x 	o 0$")
ax2.plot(xr, np.exp(3*xr - np.exp(xr)), label=r"$(e^x)^3 / e^{e^x} 	o 0$")
ax2.set_yscale("log")
ax2.set_title("Little-o dominance: ratios collapse to 0")
ax2.set_xlabel("x"); ax2.set_ylabel("ratio (log scale)")
ax2.legend(); ax2.grid(True, which="both", alpha=0.3)

plt.tight_layout()
plt.savefig("transseries_growth.png", dpi=150)
print("Saved transseries_growth.png")

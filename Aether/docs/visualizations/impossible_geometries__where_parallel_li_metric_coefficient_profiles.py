"""Compare the metric coefficients E(y)=sech^2(y) (expanding, <=1) and
G(x)=cosh^2(x) (contracting, >=1) as functions of a single coordinate."""
import numpy as np
import matplotlib.pyplot as plt

t = np.linspace(-3, 3, 400)
E = 1.0 / np.cosh(t) ** 2
G = np.cosh(t) ** 2

fig, ax = plt.subplots(1, 2, figsize=(10, 4))
ax[0].plot(t, E, "b-"); ax[0].axhline(1, color="gray", ls=":")
ax[0].set_title("E(y)=sech^2(y): expanding (<=1)"); ax[0].set_xlabel("y")
ax[1].plot(t, G, "r-"); ax[1].axhline(1, color="gray", ls=":")
ax[1].set_title("G(x)=cosh^2(x): contracting (>=1)"); ax[1].set_xlabel("x")
ax[1].set_yscale("log")
plt.tight_layout()
plt.savefig("split_coefficients.png", dpi=150)
print("wrote split_coefficients.png")

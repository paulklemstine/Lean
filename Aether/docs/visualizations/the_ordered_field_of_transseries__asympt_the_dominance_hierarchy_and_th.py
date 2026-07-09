"""Visualize the transseries dominance hierarchy: x^a vs e^x vs e^(e^x).
Generates 'transseries_dominance.png'.  Requires matplotlib + numpy."""
import numpy as np
import matplotlib.pyplot as plt

x = np.linspace(1.0, 6.0, 400)
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5))

# Left: every power of x is eventually crushed by e^x, which is crushed by e^(e^x).
for a in [2, 5, 10, 20]:
    ax1.plot(x, x ** a, label=f"$x^{{{a}}}$", lw=1.5)
ax1.plot(x, np.exp(x), "k--", lw=2.5, label=r"$e^x$")
ax1.plot(x, np.exp(np.exp(x)), "r-", lw=2.5, label=r"$e^{e^x}$")
ax1.set_yscale("log")
ax1.set_title("Transmonomial dominance: the exp tower beats every power")
ax1.set_xlabel("x"); ax1.set_ylabel("value (log scale)")
ax1.legend(loc="upper left", fontsize=9); ax1.grid(True, alpha=0.3)

# Right: the field order is the germ at x -> 0+, where x is infinitesimal.
xs = np.linspace(1e-3, 1.0, 400)
ax2.plot(xs, xs, label=r"$x$ (infinitesimal)", lw=2)
ax2.plot(xs, 1.0 / xs, label=r"$1/x$ (infinite)", lw=2)
ax2.axhline(1.0, color="gray", ls=":", label=r"$1$")
ax2.set_yscale("log")
ax2.set_title(r"Field order (germ at $x\to 0^+$): $x\cdot(1/x)=1$")
ax2.set_xlabel("x"); ax2.set_ylabel("value (log scale)")
ax2.legend(loc="upper right", fontsize=9); ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig("transseries_dominance.png", dpi=150)
print("wrote transseries_dominance.png")

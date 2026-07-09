"""Plot the single-card expected payoff E(p) = 2p - 1."""
import numpy as np
import matplotlib.pyplot as plt

p = np.linspace(0.0, 1.0, 400)
payoff = 2.0 * p - 1.0

fig, ax = plt.subplots(figsize=(7, 4.5))
ax.plot(p, payoff, lw=2.5, color="#2b6cb0", label=r"$E(p)=2p-1$")
ax.axhline(0, color="gray", lw=1)
ax.axvline(0.5, color="crimson", ls="--", lw=1.5, label="hedge $p=1/2$")
ax.fill_between(p, 0, payoff, where=(p > 0.5), alpha=0.2, color="green",
                label="profit region")
ax.scatter([0.5, 1.0], [0.0, 1.0], color="black", zorder=5)
ax.set_xlabel("win-probability $p$")
ax.set_ylabel("expected payoff")
ax.set_title("Gödel's Casino: single-card expected payoff")
ax.legend()
fig.tight_layout()
plt.savefig("payoff_curve.png", dpi=150)
print("saved payoff_curve.png")

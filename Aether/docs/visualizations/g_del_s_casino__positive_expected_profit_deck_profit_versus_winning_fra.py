"""Total expected payoff versus fraction of winning cards."""
import numpy as np
import matplotlib.pyplot as plt

n = 300
fractions = np.linspace(0.0, 1.0, 101)
for margin in (0.1, 0.25, 0.5):
    totals = []
    for f in fractions:
        winners = int(round(f * n))
        deck = [0.5 + margin] * winners + [0.5] * (n - winners)
        totals.append(sum(2 * p - 1 for p in deck))
    plt.plot(fractions, totals, lw=2, label=f"margin $\\varepsilon={margin}$")

plt.axhline(0, color="gray", lw=1)
plt.axvline(1/3, color="crimson", ls="--", lw=1.5, label="one-third threshold")
plt.xlabel("fraction of cards with a winning edge")
plt.ylabel("total expected payoff")
plt.title(f"Total expected payoff of a {n}-card deck")
plt.legend()
plt.tight_layout()
plt.savefig("deck_payoff.png", dpi=150)
print("saved deck_payoff.png")

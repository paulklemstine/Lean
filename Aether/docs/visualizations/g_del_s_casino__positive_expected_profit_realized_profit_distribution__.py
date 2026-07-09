"""Histogram of realized deck profit over many trials."""
import random
import numpy as np
import matplotlib.pyplot as plt

rng = random.Random(20260709)
n, trials = 1000, 5000
deck = [1.0 if rng.random() < 1/3 else 0.5 for _ in range(n)]

realized = []
for _ in range(trials):
    realized.append(sum(1 if rng.random() < p else -1 for p in deck))

realized = np.array(realized)
plt.hist(realized, bins=40, color="#38a169", alpha=0.8, edgecolor="black")
plt.axvline(0, color="crimson", ls="--", lw=2, label="break-even")
plt.axvline(realized.mean(), color="navy", lw=2,
            label=f"mean = {realized.mean():.0f}")
plt.xlabel("realized total profit")
plt.ylabel("number of trials")
plt.title(f"Realized profit over {trials} trials ({n} cards)")
plt.legend()
plt.tight_layout()
plt.savefig("profit_histogram.png", dpi=150)
print(f"saved profit_histogram.png; P(profit>0) = {(realized>0).mean():.3f}")

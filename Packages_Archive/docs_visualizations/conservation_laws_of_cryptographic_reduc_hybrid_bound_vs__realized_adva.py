"""Visualize the hybrid telescoping bound: end-to-end advantage vs. the sum of
per-step advantages, as the number of hybrid steps grows."""
import matplotlib.pyplot as plt
import numpy as np

rng = np.random.default_rng(0)
max_n = 40
eps = 0.05
end_to_end, bounds = [], []
d = [0.5]
for k in range(1, max_n + 1):
    d.append(d[-1] + rng.uniform(-eps, eps))
    steps = [abs(d[i] - d[i + 1]) for i in range(len(d) - 1)]
    end_to_end.append(abs(d[0] - d[-1]))
    bounds.append(sum(steps))

xs = range(1, max_n + 1)
plt.figure(figsize=(8, 5))
plt.plot(xs, bounds, label="telescoping bound  Σ|d_i - d_{i+1}|", lw=2)
plt.plot(xs, end_to_end, label="end-to-end advantage  |d_0 - d_n|", lw=2)
plt.fill_between(xs, end_to_end, bounds, alpha=0.15, label="conserved slack")
plt.xlabel("number of hybrid steps n")
plt.ylabel("advantage")
plt.title("Hybrid argument: sub-additivity of advantage along a path")
plt.legend()
plt.tight_layout()
plt.savefig("hybrid_bound.png", dpi=150)
print("wrote hybrid_bound.png")

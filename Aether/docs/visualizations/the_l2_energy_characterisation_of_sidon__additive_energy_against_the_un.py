"""Scatter additive energy vs the floor 2n^2-n over random sets of each size."""
import random
from collections import Counter
import matplotlib.pyplot as plt


def energy(s):
    c = Counter()
    for a in s:
        for b in s:
            c[a + b] += 1
    return sum(v * v for v in c.values())


random.seed(0)
xs, ys, floor_x, floor_y = [], [], [], []
for n in range(2, 9):
    floor_x.append(n)
    floor_y.append(2 * n * n - n)
    for _ in range(40):
        s = random.sample(range(0, 50), n)
        xs.append(n + random.uniform(-0.15, 0.15))
        ys.append(energy(s))
plt.figure(figsize=(8, 5))
plt.scatter(xs, ys, s=12, alpha=0.5, label="random sets")
plt.plot(floor_x, floor_y, "r-o", label="floor 2n^2 - n")
plt.xlabel("set size n")
plt.ylabel("additive energy E[s]")
plt.title("Additive energy sits on or above the universal floor")
plt.legend()
plt.tight_layout()
plt.savefig("energy_floor.png", dpi=150)
print("wrote energy_floor.png")

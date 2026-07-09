"""Visualise the self-convolution kernel r_s(x) for Sidon vs non-Sidon sets."""
from collections import Counter
import matplotlib.pyplot as plt


def kernel(s):
    c = Counter()
    for a in s:
        for b in s:
            c[a + b] += 1
    return c


sets = {"Sidon {0,1,3,7}": [0, 1, 3, 7], "AP {0,1,2,3}": [0, 1, 2, 3]}
fig, axes = plt.subplots(1, 2, figsize=(11, 4), sharey=True)
for ax, (name, s) in zip(axes, sets.items()):
    k = kernel(s)
    xs = sorted(k)
    ax.bar(xs, [k[x] for x in xs], color="#4477aa", edgecolor="black")
    e = sum(v * v for v in k.values())
    ax.set_title(f"{name}\nE[s] = {e}")
    ax.set_xlabel("sum x = a+b")
    ax.set_ylabel("r_s(x)")
fig.suptitle("Self-convolution kernel: flat (Sidon) vs spiky (non-Sidon)")
fig.tight_layout()
fig.savefig("kernel_profiles.png", dpi=150)
print("wrote kernel_profiles.png")

import numpy as np
import matplotlib.pyplot as plt

def tent(x):
    return 1.0 - np.abs(2.0 * x - 1.0)

def tent_iterate(k, x):
    for _ in range(k):
        x = tent(x)
    return x

x = np.linspace(0.0, 1.0, 4001)
fig, axes = plt.subplots(2, 2, figsize=(11, 7))
for ax, k in zip(axes.ravel(), (1, 2, 3, 4)):
    ax.plot(x, tent_iterate(k, x), lw=1.2, color="navy")
    ax.axhline(0.5, color="crimson", ls="--", lw=0.8, label="level 1/2")
    ax.set_title(f"tent^[{k}]  ({2**k} crossings of 1/2)")
    ax.set_ylim(-0.05, 1.05)
    ax.legend(loc="upper right", fontsize=8)
fig.suptitle("Depth doubles the teeth: the iterated tent map", fontsize=14)
fig.tight_layout()
plt.savefig("tent_sawtooth.png", dpi=150)
print("wrote tent_sawtooth.png")

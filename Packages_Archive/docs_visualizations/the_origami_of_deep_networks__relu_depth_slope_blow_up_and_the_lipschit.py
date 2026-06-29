import numpy as np
import matplotlib.pyplot as plt

def tent(x):
    return 1.0 - np.abs(2.0 * x - 1.0)

def tent_iterate(k, x):
    for _ in range(k):
        x = tent(x)
    return x

k = 4
x = np.linspace(0.0, 1.0, 4001)
deep = tent_iterate(k, x)

fig, ax = plt.subplots(figsize=(10, 5))
ax.plot(x, deep, color="navy", lw=1.0, label=f"tent^[{k}] (depth-{k} network)")
# best a K-Lipschitz line can do crossing the first ramp from (0,0):
for K in (4, 8, 16):
    ax.plot(x, np.minimum(K * x, 1.0), lw=1.4, ls="--",
            label=f"K={K}-Lipschitz envelope")
ax.axvline(0.5**k, color="green", ls=":", label=f"ramp width 2^-{k}")
ax.set_title("Slope blow-up: matching the first ramp forces K >= 2^k")
ax.set_ylim(-0.05, 1.1)
ax.legend(fontsize=8)
fig.tight_layout()
plt.savefig("tent_separation.png", dpi=150)
print("wrote tent_separation.png")

"""
Visualization: target vs. width-2n ReLU interpolation network.
Generates `relu_interp.png` showing f(x)=sin(3x) and its certified network
approximant for several resolutions n, plus the ramp-difference basis.
Requires matplotlib.
"""
import math
import matplotlib.pyplot as plt

def relu(x: float) -> float:
    return max(0.0, x)

def cell_slope(f, n: int, k: int) -> float:
    return n * (f((k + 1) / n) - f(k / n))

def ramp(x: float, n: int, k: int) -> float:
    return relu(x - k / n) - relu(x - (k + 1) / n)

def net(f, n: int, x: float) -> float:
    return f(0.0) + sum(cell_slope(f, n, k) * ramp(x, n, k) for k in range(n))

f = lambda x: math.sin(3.0 * x)
xs = [i / 800 for i in range(801)]

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5))
ax1.plot(xs, [f(x) for x in xs], "k-", lw=2.5, label="target f(x)=sin(3x)")
for n, c in [(4, "tab:red"), (8, "tab:orange"), (16, "tab:blue")]:
    ax1.plot(xs, [net(f, n, x) for x in xs], c, lw=1.4,
             label=f"network N, n={n} (width {2*n})")
    ax1.scatter([k / n for k in range(n + 1)], [f(k / n) for k in range(n + 1)],
                color=c, s=14, zorder=5)
ax1.set_title("Certified ReLU interpolation network")
ax1.set_xlabel("x"); ax1.set_ylabel("value"); ax1.legend(); ax1.grid(alpha=0.3)

n = 6
for k in range(n):
    ax2.plot(xs, [cell_slope(f, n, k) * ramp(x, n, k) for x in xs], lw=1.2,
             label=f"weighted φ_{k}")
ax2.plot(xs, [net(f, n, x) for x in xs], "k-", lw=2.2, label="sum = N")
ax2.set_title("Ramp-difference basis (n=6)")
ax2.set_xlabel("x"); ax2.legend(fontsize=8); ax2.grid(alpha=0.3)

plt.tight_layout()
plt.savefig("relu_interp.png", dpi=140)
print("wrote relu_interp.png")

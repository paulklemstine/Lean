"""Visualization: strong chromatic index of K_{A(a),A(b)} as a Fibonacci
product surface, plus the golden-ratio growth of the diagonal."""
import matplotlib.pyplot as plt
import numpy as np
from math import comb


def fib(n: int) -> int:
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a


def riordan_A(n: int) -> int:
    return sum(comb(n + k, 2 * k) for k in range(n + 1))


amax = bmax = 6
grid = np.zeros((amax + 1, bmax + 1))
for a in range(amax + 1):
    for b in range(bmax + 1):
        grid[a, b] = fib(2 * a + 1) * fib(2 * b + 1)

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5))

im = ax1.imshow(np.log10(grid + 1), origin="lower", cmap="viridis")
ax1.set_title(r"$\log_{10}\,\chi'_s(K_{A(a),A(b)}) = "
              r"\log_{10}(F_{2a+1}F_{2b+1})$")
ax1.set_xlabel("b")
ax1.set_ylabel("a")
fig.colorbar(im, ax=ax1)
for a in range(amax + 1):
    for b in range(bmax + 1):
        ax1.text(b, a, str(int(grid[a, b])), ha="center", va="center",
                 color="white", fontsize=6)

ratios = [fib(2 * (a + 1) + 1) / fib(2 * a + 1) for a in range(1, 9)]
ax2.plot(range(1, 9), ratios, "o-", label="A(a+1)/A(a)")
phi2 = ((1 + 5 ** 0.5) / 2) ** 2
ax2.axhline(phi2, color="red", ls="--", label=r"$\varphi^2 \approx 2.618$")
ax2.set_title("Golden-ratio growth of the diagonal")
ax2.set_xlabel("a")
ax2.set_ylabel("ratio")
ax2.legend()

plt.tight_layout()
plt.savefig("bqm_fibonacci_bridge.png", dpi=150)
print("Saved bqm_fibonacci_bridge.png")

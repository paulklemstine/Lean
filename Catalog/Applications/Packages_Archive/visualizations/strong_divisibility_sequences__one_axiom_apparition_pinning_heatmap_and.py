"""Visualize apparition patterns and densities for strong divisibility sequences.

Generates a figure with (a) a divisibility heatmap showing which Fibonacci terms
each small prime divides (revealing the periodic pinning law) and (b) the running
apparition density converging to 1/rank.
"""
import matplotlib.pyplot as plt
import numpy as np

def fib(n: int) -> int:
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a

def rank(p: int, search: int = 200) -> int:
    for n in range(1, search + 1):
        if fib(n) % p == 0:
            return n
    raise ValueError

primes = [2, 3, 5, 7, 11, 13, 17, 19, 23]
M = 60
grid = np.array([[1 if fib(m) % p == 0 else 0 for m in range(1, M + 1)]
                 for p in primes])

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
ax1.imshow(grid, aspect="auto", cmap="Blues", interpolation="nearest")
ax1.set_yticks(range(len(primes)))
ax1.set_yticklabels([f"p={p} (rank {rank(p)})" for p in primes])
ax1.set_xlabel("Fibonacci index m")
ax1.set_title("Pinning law: p | F_m exactly at multiples of rank(p)")

N = 500
for p in [7, 11, 13]:
    r = rank(p)
    dens = np.cumsum([1 if fib(m) % p == 0 else 0 for m in range(1, N + 1)]) / np.arange(1, N + 1)
    ax2.plot(range(1, N + 1), dens, label=f"p={p}, 1/rank={1/r:.3f}")
    ax2.axhline(1 / r, ls="--", color="gray", alpha=0.5)
ax2.set_xlabel("N")
ax2.set_ylabel("apparition density up to N")
ax2.set_title("Density of apparition indices -> 1/rank")
ax2.legend()
plt.tight_layout()
plt.savefig("apparition_patterns.png", dpi=150)
print("Saved apparition_patterns.png")

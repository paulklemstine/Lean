import numpy as np
import matplotlib.pyplot as plt

def fib(n: int) -> int:
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a

# Entry-point comb: for each small prime p (rows) and index n (cols),
# mark 1 where p | F_n. The result is a set of perfectly periodic combs
# with period z(p), visualizing p | F_n <=> z(p) | n.
primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29]
N = 40
grid = np.zeros((len(primes), N))
for i, p in enumerate(primes):
    for n in range(1, N + 1):
        grid[i, n - 1] = 1.0 if fib(n) % p == 0 else 0.0

fig, ax = plt.subplots(figsize=(12, 5))
ax.imshow(grid, aspect="auto", cmap="YlGnBu", origin="lower",
          extent=[1, N, -0.5, len(primes) - 0.5])
ax.set_yticks(range(len(primes)))
ax.set_yticklabels([f"p={p}" for p in primes])
ax.set_xlabel("Fibonacci index n")
ax.set_title("Divisibility combs: where each prime divides F_n  (period = entry point z(p))")
plt.tight_layout()
plt.savefig("fib_divisibility_combs.png", dpi=150)
print("saved fib_divisibility_combs.png")

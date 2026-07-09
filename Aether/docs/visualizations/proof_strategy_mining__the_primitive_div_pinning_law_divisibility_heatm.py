import numpy as np
import matplotlib.pyplot as plt

def fib(n: int) -> int:
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a

# Divisibility lattice: rows = small primes p, cols = indices n.
# A cell is lit when p | F_n; the lit cells in each row are exactly the
# multiples of rank(p), visualizing the pinning law as evenly spaced stripes.
primes = [2, 3, 5, 7, 11, 13, 17]
N = 60
M = np.zeros((len(primes), N), dtype=int)
for i, p in enumerate(primes):
    for n in range(1, N + 1):
        M[i, n - 1] = 1 if fib(n) % p == 0 else 0

fig, ax = plt.subplots(figsize=(12, 4))
ax.imshow(M, aspect='auto', cmap='Greens', interpolation='nearest')
ax.set_yticks(range(len(primes)))
ax.set_yticklabels([f'p={p}' for p in primes])
ax.set_xticks(range(0, N, 5))
ax.set_xticklabels(range(1, N + 1, 5))
ax.set_xlabel('Fibonacci index n')
ax.set_title('Pinning law: p | F_n exactly at multiples of rank(p)')
plt.tight_layout()
plt.savefig('pinning_law_heatmap.png', dpi=150)
print('saved pinning_law_heatmap.png')

import matplotlib.pyplot as plt
import numpy as np

def lucas(n):
    a, b = 2, 1
    for _ in range(n):
        a, b = b, a + b
    return a

def is_prime(m):
    return m > 1 and all(m % d for d in range(2, int(m**0.5) + 1))

primes = [p for p in range(3, 60) if is_prime(p)]
max_n = 60
grid = np.zeros((len(primes), max_n))
for i, p in enumerate(primes):
    for n in range(1, max_n + 1):
        grid[i, n - 1] = 1 if lucas(n) % p == 0 else 0

fig, ax = plt.subplots(figsize=(12, 6))
ax.imshow(grid, aspect='auto', cmap='magma', interpolation='nearest')
ax.set_yticks(range(len(primes)))
ax.set_yticklabels(primes)
ax.set_xlabel('index n')
ax.set_ylabel('odd prime p')
ax.set_title('p divides L(n): regular striping governed by the Fibonacci rank alpha(p)')
plt.tight_layout()
plt.savefig('lucas_apparition_heatmap.png', dpi=150)
print('saved lucas_apparition_heatmap.png')

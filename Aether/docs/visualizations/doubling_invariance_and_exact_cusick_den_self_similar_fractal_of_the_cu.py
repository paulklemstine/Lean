import numpy as np
import matplotlib.pyplot as plt

def s2(n: int) -> int:
    return bin(n).count('1')

T, Nmax = 64, 256
grid = np.zeros((T, Nmax))
for t in range(1, T + 1):
    for n in range(Nmax):
        grid[t - 1, n] = 1.0 if s2(n) <= s2(n + t) else 0.0
plt.figure(figsize=(10, 6))
plt.imshow(grid, aspect='auto', cmap='binary', origin='lower',
           extent=[0, Nmax, 1, T])
plt.xlabel('n')
plt.ylabel('shift t')
plt.title('Cusick predicate s2(n) <= s2(n+t): self-similar structure')
plt.tight_layout()
plt.savefig('cusick_predicate_fractal.png', dpi=150)
print('saved cusick_predicate_fractal.png')

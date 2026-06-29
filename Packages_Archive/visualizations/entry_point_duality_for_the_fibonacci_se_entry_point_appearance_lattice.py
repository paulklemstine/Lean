import numpy as np
import matplotlib.pyplot as plt

def fib_mod(n: int, m: int) -> int:
    if m == 1:
        return 0
    a, b = 0, 1
    for _ in range(n):
        a, b = b, (a + b) % m
    return a % m

P_MAX, N_MAX = 30, 40
grid = np.array([[1 if fib_mod(n, p) == 0 else 0
                  for n in range(1, N_MAX + 1)]
                 for p in range(2, P_MAX + 1)])
plt.figure(figsize=(11, 7))
plt.imshow(grid, aspect='auto', cmap='viridis',
           extent=[1, N_MAX, P_MAX, 2])
plt.xlabel('index n'); plt.ylabel('modulus p')
plt.title('p | F(n): periodic stripes of period z(p)')
plt.colorbar(label='p divides F(n)')
plt.tight_layout(); plt.savefig('appearance_lattice.png', dpi=150)
print('saved appearance_lattice.png')

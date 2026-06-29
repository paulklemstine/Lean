import numpy as np
import matplotlib.pyplot as plt
from math import gcd

def fib(n):
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a

N = 14
lhs = np.zeros((N, N), dtype=float)
rhs = np.zeros((N, N), dtype=float)
for m in range(1, N + 1):
    for n in range(1, N + 1):
        lhs[m - 1, n - 1] = np.log1p(gcd(fib(m), fib(n)))
        rhs[m - 1, n - 1] = np.log1p(fib(gcd(m, n)))

fig, axes = plt.subplots(1, 2, figsize=(11, 5))
for ax, data, title in zip(axes, (lhs, rhs),
                           ('log(1 + gcd(F m, F n))', 'log(1 + F(gcd m n))')):
    im = ax.imshow(data, origin='lower', cmap='viridis',
                   extent=[1, N, 1, N])
    ax.set_title(title); ax.set_xlabel('n'); ax.set_ylabel('m')
    fig.colorbar(im, ax=ax, shrink=0.8)
fig.suptitle('Fibonacci gcd conservation: the two panels are identical')
plt.tight_layout(); plt.savefig('fib_gcd_conservation.png', dpi=150)
print('saved fib_gcd_conservation.png')
import numpy as np
import matplotlib.pyplot as plt
from math import gcd

def fib(k):
    a, b = 0, 1
    for _ in range(k):
        a, b = b, a + b
    return a

def lcm(x, y):
    return 0 if x == 0 or y == 0 else x // gcd(x, y) * y

def rank(m, limit=20000):
    for k in range(1, limit + 1):
        if fib(k) % m == 0:
            return k
    return 0

N = 12
R = {m: rank(m) for m in range(1, N * N + 1)}
A = np.zeros((N, N)); B = np.zeros((N, N))
for i, a in enumerate(range(1, N + 1)):
    for j, b in enumerate(range(1, N + 1)):
        A[i, j] = rank(lcm(a, b))
        B[i, j] = lcm(R[a], R[b])
fig, ax = plt.subplots(1, 3, figsize=(15, 5))
for axi, (M, t) in zip(ax, [(A, 'rank(lcm(a,b))'),
                            (B, 'lcm(rank a, rank b)'),
                            (A - B, 'difference (all zero)')]):
    im = axi.imshow(M, origin='lower', cmap='viridis',
                    extent=[1, N, 1, N])
    axi.set_title(t); axi.set_xlabel('b'); axi.set_ylabel('a')
    fig.colorbar(im, ax=axi, fraction=0.046)
plt.tight_layout(); plt.savefig('join_law_heatmap.png', dpi=150)
print('wrote join_law_heatmap.png')
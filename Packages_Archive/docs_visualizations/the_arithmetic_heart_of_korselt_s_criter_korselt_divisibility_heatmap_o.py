import numpy as np
import matplotlib.pyplot as plt
from math import gcd

def factors(n):
    f, m, d = [], n, 2
    while d*d <= m:
        if m % d == 0:
            f.append(d)
            while m % d == 0: m //= d
        d += 1
    if m > 1: f.append(m)
    return f

primes = [2,3,5,7,11,13,17,19,23,29]
ns = list(range(500, 600))
grid = np.full((len(primes), len(ns)), np.nan)
for j, n in enumerate(ns):
    for p in factors(n):
        if p in primes:
            i = primes.index(p)
            grid[i, j] = 1.0 if (n-1) % (p-1) == 0 else 0.0
plt.figure(figsize=(12,4))
plt.imshow(grid, aspect='auto', origin='lower', cmap='RdYlGn',
           extent=[ns[0], ns[-1], 0, len(primes)])
plt.yticks([i+0.5 for i in range(len(primes))], primes)
plt.xlabel('modulus n'); plt.ylabel('prime factor p')
plt.title('Korselt clause (p-1)|(n-1):  green=holds, red=fails')
plt.colorbar(label='clause holds')
plt.tight_layout(); plt.savefig('korselt_heatmap.png', dpi=150)
print('wrote korselt_heatmap.png')

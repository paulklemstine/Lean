import matplotlib.pyplot as plt
import numpy as np
from typing import Dict, List

NAMES: List[str] = ['M20','F384','A4,4','T192','H192','N72','M9','T48','L2(7)','A6','S5']
ORDERS: List[int] = [960,384,288,192,192,72,72,48,168,360,120]
PRIMES: List[int] = [2,3,5,7,11,13]

def exponent(n: int, p: int) -> int:
    e = 0
    while n % p == 0:
        n //= p
        e += 1
    return e

mat = np.array([[exponent(N, p) for p in PRIMES] for N in ORDERS])
fig, ax = plt.subplots(figsize=(7, 6))
im = ax.imshow(mat, cmap='viridis')
ax.set_xticks(range(len(PRIMES)), [str(p) for p in PRIMES])
ax.set_yticks(range(len(NAMES)), NAMES)
ax.set_xlabel('prime'); ax.set_ylabel('Mukai group')
ax.set_title('Prime-power exponents of Mukai orders (lcm = 40320 = 2^7*3^2*5*7)')
for i in range(len(NAMES)):
    for j in range(len(PRIMES)):
        ax.text(j, i, mat[i, j], ha='center', va='center', color='w')
fig.colorbar(im, label='exponent')
plt.tight_layout()
plt.savefig('mukai_heatmap.png', dpi=150)
print('wrote mukai_heatmap.png')

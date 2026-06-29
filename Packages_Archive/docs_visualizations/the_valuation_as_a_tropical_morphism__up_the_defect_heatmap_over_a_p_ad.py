import numpy as np
import matplotlib.pyplot as plt
from fractions import Fraction
from math import inf

def iv(n, p):
    if n == 0: return 50
    c = 0; n = abs(n)
    while n % p == 0: n //= p; c += 1
    return c

def v(x, p):
    if x == 0: return 50
    return iv(x.numerator, p) - iv(x.denominator, p)

p = 3
N = 40
defect = np.zeros((N, N)); tie = np.zeros((N, N))
for i in range(1, N+1):
    for j in range(1, N+1):
        x, y = Fraction(i), Fraction(j)
        vx, vy, vs = v(x, p), v(y, p), v(x+y, p)
        defect[i-1, j-1] = 1 if vs != min(vx, vy) else 0
        tie[i-1, j-1]    = 1 if vx == vy else 0
fig, ax = plt.subplots(1, 2, figsize=(11, 5))
ax[0].imshow(defect, origin='lower', cmap='Reds'); ax[0].set_title('Additive defect (p=3)')
ax[1].imshow(tie, origin='lower', cmap='Blues'); ax[1].set_title('Tie set {v x = v y}')
for a in ax: a.set_xlabel('y'); a.set_ylabel('x')
plt.suptitle('Defect locus is contained in the tie set')
plt.tight_layout(); plt.savefig('defect_heatmap.png', dpi=130)
print('wrote defect_heatmap.png')

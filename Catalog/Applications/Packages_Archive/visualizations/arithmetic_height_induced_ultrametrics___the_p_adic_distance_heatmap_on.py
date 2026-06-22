import numpy as np
import matplotlib.pyplot as plt

def padic_val_int(p, n):
    if n == 0: return 30
    n, k = abs(n), 0
    while n % p == 0: n //= p; k += 1
    return k

def hdist(p, x, y):
    if x == y: return 0.0
    return p ** (-padic_val_int(p, x - y))

p, N = 3, 27
M = np.array([[hdist(p, x, y) for y in range(N)] for x in range(N)])
plt.figure(figsize=(6, 5))
plt.imshow(M, cmap='viridis_r')
plt.colorbar(label=f'{p}-adic distance')
plt.title(f'{p}-adic depth distance on 0..{N-1}')
plt.xlabel('y'); plt.ylabel('x')
plt.tight_layout(); plt.savefig('padic_heatmap.png', dpi=150)
print('wrote padic_heatmap.png')

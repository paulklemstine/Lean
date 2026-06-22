import numpy as np
import matplotlib.pyplot as plt

def H3(p1, p2):
    p3 = 1 - p1 - p2
    out = np.zeros_like(p1)
    for arr in (p1, p2, p3):
        m = arr > 0
        out[m] += -arr[m] * np.log(arr[m])
    return out

N = 300
a = np.linspace(0, 1, N)
P1, P2 = np.meshgrid(a, a)
valid = (P1 + P2 <= 1) & (P1 >= 0) & (P2 >= 0)
Hv = np.where(valid, H3(P1, P2), np.nan)

plt.figure(figsize=(6, 5))
plt.imshow(Hv, origin='lower', extent=[0, 1, 0, 1],
           cmap='viridis')
plt.colorbar(label='H(p) [nats]')
plt.scatter([1/3], [1/3], color='red', marker='*', s=140,
            label='uniform: H = log 3')
plt.title('Entropy over the 3-outcome simplex')
plt.xlabel('p1'); plt.ylabel('p2'); plt.legend()
plt.tight_layout()
plt.savefig('entropy_simplex.png', dpi=150)
print('wrote entropy_simplex.png')

import math
import matplotlib.pyplot as plt

def fusion_dims(n_max: int):
    dims = [1, 1]
    while len(dims) < n_max:
        dims.append(dims[-1] + dims[-2])
    return dims

n_max = 12
dims = fusion_dims(n_max)
phi = (1 + math.sqrt(5)) / 2
ratios = [dims[i+1]/dims[i] for i in range(len(dims)-1)]

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(11, 4))
ax1.bar(range(1, n_max+1), dims, color='goldenrod')
ax1.set_title('Fusion-space dimension vs number of tau anyons')
ax1.set_xlabel('number of anyons'); ax1.set_ylabel('dimension')
ax2.plot(range(2, n_max+1), ratios, 'o-', color='darkred', label='consecutive ratio')
ax2.axhline(phi, ls='--', color='black', label=f'phi = {phi:.4f}')
ax2.set_title('Growth ratio -> golden ratio'); ax2.set_xlabel('n'); ax2.legend()
plt.tight_layout(); plt.savefig('fibonacci_fusion_growth.png', dpi=150)
print('saved fibonacci_fusion_growth.png')

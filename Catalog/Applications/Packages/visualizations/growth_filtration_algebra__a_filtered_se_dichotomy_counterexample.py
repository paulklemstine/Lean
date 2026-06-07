import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import math

n = np.arange(2, 50)
f_vals = np.array([i ** int(math.log2(i)) for i in n])
fig, ax = plt.subplots(figsize=(10, 6))
for k in range(1, 6):
    ax.semilogy(n, n**k, '--', alpha=0.5, label=f'n^{k}')
ax.semilogy(n, 2.0**n, '--', color='red', alpha=0.5, label='2^n')
ax.semilogy(n, f_vals, 'ko-', linewidth=2, markersize=4, label='n^floor(log n)')
ax.set_xlabel('n')
ax.set_ylabel('Value (log scale)')
ax.set_title('Growth Level Dichotomy Counterexample')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)
plt.tight_layout()
plt.savefig('dichotomy.png', dpi=150)
print('Saved dichotomy.png')
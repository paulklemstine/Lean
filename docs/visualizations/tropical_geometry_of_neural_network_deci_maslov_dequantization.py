import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

fig, ax = plt.subplots(figsize=(10, 6))
x = np.linspace(-3, 3, 1000)
true_max = np.maximum(x, 0)
ax.plot(x, true_max, 'k-', lw=2.5, label='ReLU = max(x,0) [tropical]')
for eps in [2.0, 1.0, 0.5, 0.1]:
    smooth = eps * np.log(np.exp(x/eps) + 1)
    ax.plot(x, smooth, '--', lw=1.5, label=f'Smooth (ε={eps})', alpha=0.7)
ax.set_xlabel('x', fontsize=13)
ax.set_ylabel('f(x)', fontsize=13)
ax.set_title('Maslov Dequantization: Smooth → Tropical', fontsize=14)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)
plt.tight_layout()
plt.savefig('maslov_dequantization.png', dpi=150)
plt.close()
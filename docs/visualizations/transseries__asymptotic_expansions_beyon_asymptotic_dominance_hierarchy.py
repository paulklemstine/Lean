import numpy as np
import matplotlib.pyplot as plt

fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Panel 1: exp vs poly
ax = axes[0]
x = np.linspace(0, 20, 500)
ax.plot(x, np.exp(x), 'r-', lw=2, label='exp(x)')
for n in [2, 4, 6, 8]:
    ax.plot(x, x**n, '--', lw=1, label=f'x^{n}')
ax.set_yscale('log'); ax.set_ylim(1, 1e15)
ax.set_xlabel('x'); ax.set_ylabel('f(x)')
ax.set_title('Exp vs Polynomial'); ax.legend(fontsize=8); ax.grid(True, alpha=0.3)

# Panel 2: ratios
ax = axes[1]
x = np.linspace(1, 30, 500)
for n in [1, 3, 5, 10]:
    ax.plot(x, np.exp(x)/x**(n+1), lw=1.5, label=f'exp(x)/x^{n+1}')
ax.set_yscale('log'); ax.set_xlabel('x'); ax.set_ylabel('Ratio')
ax.set_title('Dominance Ratios'); ax.legend(fontsize=8); ax.grid(True, alpha=0.3)

# Panel 3: diagonal gap
ax = axes[2]
x = np.linspace(0.01, 5, 1000)
ax.plot(x, np.exp(x)-np.log(x), 'b-', lw=2, label='exp(x)-log(x)')
ax.axhline(y=2, color='r', ls='--', label='Lower bound=2')
ax.set_xlabel('x'); ax.set_ylabel('exp(x)-log(x)')
ax.set_title('Diagonal Gap >= 2'); ax.legend(); ax.set_ylim(0, 15); ax.grid(True, alpha=0.3)

plt.tight_layout(); plt.savefig('dominance_hierarchy.png', dpi=150); plt.close()
import matplotlib.pyplot as plt
import numpy as np

def iter_exp(n, x):
    result = x
    for _ in range(n):
        result = np.exp(result)
    return result

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

# Left: iterExp(n, x) for small x values
x = np.linspace(0, 1.5, 200)
for n in range(5):
    y = np.array([iter_exp(n, xi) for xi in x])
    y = np.clip(y, None, 50)
    ax1.plot(x, y, label=f'iterExp({n}, x)', linewidth=2)
ax1.set_xlabel('x')
ax1.set_ylabel('iterExp(n, x)')
ax1.set_title('Iterated Exponentials (Depth Hierarchy)')
ax1.set_ylim(0, 50)
ax1.legend()
ax1.grid(True, alpha=0.3)

# Right: Growth gap
ns = range(5)
vals = [iter_exp(n, 2.0) for n in ns]
gaps = [iter_exp(n+1, 2.0) - iter_exp(n, 2.0) - 1 for n in range(4)]
ax2.semilogy(range(4), gaps, 'ro-', markersize=8, linewidth=2)
ax2.set_xlabel('n')
ax2.set_ylabel('Growth gap (log scale)')
ax2.set_title('Super-exponential Growth Gap\niterExp(n+1, 2) - iterExp(n, 2) - 1')
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('depth_hierarchy.png', dpi=150, bbox_inches='tight')
plt.show()
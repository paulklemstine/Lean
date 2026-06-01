import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

def consciousness_distance(f, x):
    return np.abs(x - f(x))

fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle('Consciousness Distance Landscapes', fontsize=16)
x = np.linspace(-3, 3, 1000)

# f(x) = x^2 - 1
ax = axes[0, 0]
f1 = lambda x: x**2 - 1
d1 = consciousness_distance(f1, x)
ax.plot(x, d1, 'b-', linewidth=2)
phi = (1 + np.sqrt(5)) / 2
psi = (1 - np.sqrt(5)) / 2
ax.scatter([phi, psi], [0, 0], color='red', s=100, zorder=5)
ax.set_title('f(x) = x² − 1')
ax.set_xlabel('x')
ax.set_ylabel('δ(x)')
ax.grid(True, alpha=0.3)

# f(x) = cos(x)
ax = axes[0, 1]
f2 = lambda x: np.cos(x)
d2 = consciousness_distance(f2, x)
ax.plot(x, d2, 'purple', linewidth=2)
ax.scatter([0.739], [0], color='red', s=100, zorder=5)
ax.set_title('f(x) = cos(x)')
ax.set_xlabel('x')
ax.set_ylabel('δ(x)')
ax.grid(True, alpha=0.3)

# Contraction
ax = axes[1, 0]
x3 = np.linspace(-2, 8, 1000)
f3 = lambda x: 0.5 * x + 1
d3 = consciousness_distance(f3, x3)
ax.plot(x3, d3, 'darkgreen', linewidth=2)
ax.scatter([2.0], [0], color='red', s=100, zorder=5)
ax.set_title('f(x) = 0.5x + 1')
ax.set_xlabel('x')
ax.set_ylabel('δ(x)')
ax.grid(True, alpha=0.3)

# Overhead
ax = axes[1, 1]
ns = np.arange(1, 11)
ax.semilogy(ns, ns, 'bs-', label='|States|')
ax.semilogy(ns, ns**ns, 'r^-', label='|Endomorphisms|')
ax.set_title('Finite Non-Reflectivity Gap')
ax.set_xlabel('n')
ax.set_ylabel('Count (log)')
ax.legend()
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('consciousness_landscape.png', dpi=150)
plt.close()
import numpy as np
import matplotlib.pyplot as plt

def alexander_coeffs(n):
    return [(-1)**i for i in range(n)]

fig, axes = plt.subplots(1, 3, figsize=(15, 5))
primes = [3, 5, 7]
knot_names = ['Trefoil T(2,3)', 'Cinquefoil T(2,5)', 'T(2,7)']

for ax, p, name in zip(axes, primes, knot_names):
    coeffs = alexander_coeffs(p)
    roots = np.roots(coeffs[::-1])
    theta = np.linspace(0, 2*np.pi, 100)
    ax.plot(np.cos(theta), np.sin(theta), 'b-', alpha=0.3, linewidth=1)
    ax.scatter(roots.real, roots.imag, c='red', s=100, zorder=5)
    for i, r in enumerate(roots):
        ax.annotate(f'ζ_{{{2*p}}}^{{{i+1}}}', (r.real+0.05, r.imag+0.05), fontsize=8)
    ax.set_xlim(-1.5, 1.5)
    ax.set_ylim(-1.5, 1.5)
    ax.set_aspect('equal')
    ax.set_title(f'{name}\nΦ_{{{2*p}}} roots')
    ax.grid(True, alpha=0.3)
    ax.axhline(y=0, color='k', linewidth=0.5)
    ax.axvline(x=0, color='k', linewidth=0.5)

plt.suptitle('Roots of Alexander Polynomials = Primitive 2p-th Roots of Unity', fontsize=14)
plt.tight_layout()
plt.savefig('alexander_roots.png', dpi=150, bbox_inches='tight')
plt.show()
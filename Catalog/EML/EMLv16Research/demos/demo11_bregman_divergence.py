"""
Demo 11: Bregman Divergence Connection
d(p) = p - ln(p) = D_{-ln}(p || 1) + 1, where D_{-ln} is the Bregman divergence of -ln.
"""
import numpy as np
import matplotlib.pyplot as plt

def bregman_neglog(p, q):
    """Bregman divergence of f(x) = -ln(x) at p from q."""
    return p/q - 1 - np.log(p/q)

def eml_diagonal(p):
    """d(p) = p - ln(p)"""
    return p - np.log(p)

p = np.linspace(0.1, 5, 500)

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: Diagonal and Bregman
ax = axes[0]
ax.plot(p, eml_diagonal(p), 'b-', linewidth=2.5, label='d(p) = p - ln(p)')
ax.plot(p, bregman_neglog(p, 1) + 1, 'r--', linewidth=2, label='D_{-ln}(p||1) + 1')
ax.plot(p, bregman_neglog(p, 1), 'g-.', linewidth=1.5, label='D_{-ln}(p||1) = p - 1 - ln(p)')
ax.axhline(y=1, color='purple', linestyle=':', alpha=0.7, label='d = 1 (Bregman = 0)')
ax.plot(1, 1, 'ko', markersize=10, zorder=5, label='Minimum at p = 1')
ax.set_xlabel('p')
ax.set_ylabel('Value')
ax.set_title('EML Diagonal = Bregman Divergence + 1')
ax.legend(fontsize=9)
ax.set_ylim(0, 6)
ax.grid(True, alpha=0.3)

# Right: Bregman divergence for various reference points
ax = axes[1]
for q in [0.5, 1.0, 2.0, 3.0]:
    ax.plot(p, bregman_neglog(p, q), linewidth=2, label=f'D(p||{q})')
ax.axhline(y=0, color='k', linewidth=0.5)
ax.set_xlabel('p')
ax.set_ylabel('D_{-ln}(p || q)')
ax.set_title('Bregman Divergence D_{-ln}(p||q) for Various q')
ax.legend()
ax.set_ylim(-0.5, 5)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('bregman_divergence.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved bregman_divergence.png")

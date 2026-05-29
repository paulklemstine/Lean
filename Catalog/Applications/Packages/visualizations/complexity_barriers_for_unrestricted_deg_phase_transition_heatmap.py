"""
Visualization: Complexity Phase Transition in Lorentzian Recognition

Shows how certificate size transitions from polynomial (fixed degree)
to exponential (unbounded degree) as degree grows with the number
of variables. This is the central discovery of the formal development.

Produces a heatmap of log₂(certificate size) over (n, d) space,
with the polynomial/exponential boundary clearly visible.
"""
import math
import matplotlib.pyplot as plt
import numpy as np


def multiindex_count(n: int, d: int) -> int:
    """Number of multiindices of weight d in n variables = C(d+n-1, n-1)."""
    if n <= 0:
        return 1 if d == 0 else 0
    return math.comb(d + n - 1, n - 1)


def log2_cert_size(n: int, d: int) -> float:
    """Log₂ of the quadratic leaf count = multiindex_count(n, d-2)."""
    if d < 2:
        return 0
    count = multiindex_count(n, d - 2)
    return math.log2(max(1, count))


# Create the heatmap data
n_max = 30
d_max = 30
n_vals = list(range(2, n_max + 1))
d_vals = list(range(2, d_max + 1))

data = np.zeros((len(d_vals), len(n_vals)))
for i, d in enumerate(d_vals):
    for j, n in enumerate(n_vals):
        data[i, j] = log2_cert_size(n, d)

fig, axes = plt.subplots(1, 2, figsize=(16, 7))

# Left: Heatmap
ax1 = axes[0]
im = ax1.imshow(data, aspect='auto', origin='lower',
                extent=[n_vals[0], n_vals[-1], d_vals[0], d_vals[-1]],
                cmap='inferno')
ax1.set_xlabel('Number of variables (n)', fontsize=13)
ax1.set_ylabel('Degree (d)', fontsize=13)
ax1.set_title('log₂(Certificate Size) for\nLorentzian Recognition', fontsize=14)

# Draw the d = n line (phase transition boundary)
ax1.plot([2, min(n_max, d_max)], [2, min(n_max, d_max)],
         'w--', linewidth=2, alpha=0.8, label='d = n (phase transition)')
ax1.legend(loc='upper left', fontsize=11, facecolor='black', edgecolor='white',
           labelcolor='white')

cbar = plt.colorbar(im, ax=ax1)
cbar.set_label('log₂(certificate size)', fontsize=12)

# Right: Growth curves for fixed n and growing d
ax2 = axes[1]
d_range = list(range(2, 25))

for n in [3, 5, 8, 12, 20]:
    sizes = [log2_cert_size(n, d) for d in d_range]
    ax2.plot(d_range, sizes, 'o-', markersize=3, label=f'n = {n}')

# Also plot 2^(d-2) reference line
ref = [d - 2 for d in d_range]
ax2.plot(d_range, ref, 'k--', linewidth=2, alpha=0.5, label='2^(d-2) lower bound')

ax2.set_xlabel('Degree (d)', fontsize=13)
ax2.set_ylabel('log₂(certificate size)', fontsize=13)
ax2.set_title('Certificate Size Growth\n(Fixed n, Growing d)', fontsize=14)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('phase_transition.png', dpi=150, bbox_inches='tight')
print("Saved: phase_transition.png")

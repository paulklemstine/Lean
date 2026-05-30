"""
Visualization 1: Log-Concavity Ratio Heatmap

Visualizes the log-concavity ratio C(d,m)^2 / (C(d,m-1)*C(d,m+1))
across all degrees d and positions m. The surplus above 1 measures
how strongly log-concavity holds. Brighter = more surplus = stronger
log-concavity.

This heatmap reveals the geometric structure: the ratio equals
(d-m+1)(m+1) / (m(d-m)) = 1 + (d+1)/(m(d-m)), which is maximized
at the endpoints (m=1, m=d-1) and minimized at the center (m=d/2).
"""
import numpy as np
import matplotlib.pyplot as plt

# Parameters
max_d = 30

# Compute ratios
ratios = np.zeros((max_d + 1, max_d + 1))
ratios[:] = np.nan

for d in range(2, max_d + 1):
    for m in range(1, d):
        # C(d,m)^2 / (C(d,m-1)*C(d,m+1)) = (d-m+1)(m+1) / (m*(d-m))
        ratio = (d - m + 1) * (m + 1) / (m * (d - m))
        ratios[d, m] = ratio

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: Heatmap of ratios
ax1 = axes[0]
im = ax1.imshow(ratios[2:, :max_d], aspect='auto', cmap='YlOrRd',
                origin='lower', vmin=1.0, vmax=3.0,
                extent=[0, max_d, 2, max_d + 1])
ax1.set_xlabel('Position m', fontsize=12)
ax1.set_ylabel('Degree d', fontsize=12)
ax1.set_title('Log-Concavity Ratio\nC(d,m)² / (C(d,m-1)·C(d,m+1))', fontsize=13)
plt.colorbar(im, ax=ax1, label='Ratio (≥ 1 means log-concave)')

# Right: Surplus (d+1)/(m*(d-m)) for selected degrees
ax2 = axes[1]
for d in [5, 10, 15, 20, 30]:
    ms = np.arange(1, d)
    surplus = (d + 1) / (ms * (d - ms))
    ax2.plot(ms / d, surplus, 'o-', markersize=3, label=f'd = {d}', alpha=0.8)

ax2.set_xlabel('Normalized position m/d', fontsize=12)
ax2.set_ylabel('Surplus above 1', fontsize=12)
ax2.set_title('Log-Concavity Surplus\n(d+1) / (m·(d-m))', fontsize=13)
ax2.legend(fontsize=10)
ax2.set_ylim(0, 5)
ax2.axhline(y=0, color='gray', linestyle='--', alpha=0.3)
ax2.grid(alpha=0.3)

plt.tight_layout()
plt.savefig('viz_log_concavity_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved viz_log_concavity_heatmap.png")

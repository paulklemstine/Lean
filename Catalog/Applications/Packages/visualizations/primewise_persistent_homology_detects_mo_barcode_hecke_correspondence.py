"""
Visualization 1: Barcode-Hecke Correspondence

Visualizes the relationship between persistence barcodes and Hecke eigenvalues
for the Fermat quintic Calabi-Yau threefold. Shows how the barcode structure
at different primes encodes arithmetic information.

This script produces:
- Top: Persistence barcode diagrams at different primes
- Middle: Point count deviations vs Hasse-Weil bound
- Bottom: Barcode entropy growth as a function of prime
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np

# Simulated barcode data for the Fermat quintic at small primes
# Each entry: (birth, death, degree)
barcode_data = {
    3: [(0, 3, 0), (0, 2, 1), (1, 3, 1), (0, 1, 2), (2, 3, 2), (0, 3, 3), (1, 3, 3)],
    5: [(0, 4, 0), (0, 3, 1), (1, 4, 1), (0, 2, 2), (2, 4, 2), (0, 4, 3), (1, 4, 3)],
    7: [(0, 4, 0), (0, 3, 1), (1, 4, 1), (2, 4, 1), (0, 2, 2), (1, 3, 2),
        (0, 4, 3), (1, 4, 3)],
    11: [(0, 4, 0), (0, 3, 1), (1, 4, 1), (2, 4, 1), (0, 2, 2), (1, 3, 2),
         (2, 4, 2), (0, 4, 3), (1, 4, 3)],
    13: [(0, 4, 0), (0, 3, 1), (1, 4, 1), (2, 4, 1), (3, 4, 1),
         (0, 2, 2), (1, 3, 2), (2, 4, 2), (0, 4, 3), (1, 4, 3)],
}

# Point counts (simulated)
primes = [3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43]
point_counts = {}
for p in primes:
    base = p**3 + p**2 + p + 1
    # Simulate small deviation
    np.random.seed(p)
    a_p = int(np.random.normal(0, p**0.8))
    point_counts[p] = base - a_p

# Entropy data (simulated with realistic growth)
entropy_data = {p: 0.8 * np.log2(p) + 0.3 * np.random.randn() for p in primes}

# Create figure
fig, axes = plt.subplots(3, 1, figsize=(12, 14))
fig.suptitle('Barcode-Hecke Correspondence for the Fermat Quintic CY3',
             fontsize=16, fontweight='bold', y=0.98)

# ─── Top panel: Persistence barcodes at different primes ───
ax1 = axes[0]
colors = {0: '#2196F3', 1: '#4CAF50', 2: '#FF9800', 3: '#F44336'}
degree_names = {0: 'H₀', 1: 'H₁', 2: 'H₂', 3: 'H₃'}

display_primes = [3, 7, 13]
y_offset = 0
y_labels = []
y_positions = []

for p_idx, p in enumerate(display_primes):
    if p not in barcode_data:
        continue
    bars = barcode_data[p]
    label_y = y_offset + len(bars) / 2
    y_labels.append(f'p = {p}')
    y_positions.append(label_y)

    for i, (birth, death, deg) in enumerate(bars):
        ax1.barh(y_offset + i, death - birth, left=birth,
                height=0.7, color=colors.get(deg, 'gray'),
                alpha=0.8, edgecolor='black', linewidth=0.5)

    y_offset += len(bars) + 2

ax1.set_yticks(y_positions)
ax1.set_yticklabels(y_labels, fontsize=12)
ax1.set_xlabel('Filtration Value (Codimension)', fontsize=12)
ax1.set_title('Persistence Barcodes of ASC(X, p)', fontsize=14)
ax1.invert_yaxis()

# Legend for degrees
handles = [mpatches.Patch(color=colors[d], label=degree_names[d]) for d in range(4)]
ax1.legend(handles=handles, loc='lower right', fontsize=10, title='Degree')
ax1.grid(axis='x', alpha=0.3)

# Highlight the two long H₃ bars
ax1.annotate('← Two long H₃ bars\n   (reflects h³ = 2)',
            xy=(3.5, 2), fontsize=10, color='#F44336',
            fontweight='bold')

# ─── Middle panel: Point count deviations ───
ax2 = axes[1]
deviations = []
hasse_bounds = []
for p in primes:
    base = p**3 + p**2 + p + 1
    dev = point_counts[p] - base
    deviations.append(dev)
    hasse_bounds.append(2 * p**2)

ax2.bar(range(len(primes)), deviations, color='#3F51B5', alpha=0.7,
        label='a_p = deviation', edgecolor='black', linewidth=0.5)
ax2.plot(range(len(primes)), hasse_bounds, 'r--', linewidth=2,
         label='Hasse bound (2p²)', marker='^', markersize=6)
ax2.plot(range(len(primes)), [-h for h in hasse_bounds], 'r--', linewidth=2,
         marker='v', markersize=6)
ax2.set_xticks(range(len(primes)))
ax2.set_xticklabels([str(p) for p in primes], fontsize=10)
ax2.set_xlabel('Prime p', fontsize=12)
ax2.set_ylabel('Point Count Deviation (a_p)', fontsize=12)
ax2.set_title('Hecke Eigenvalues vs Hasse-Weil Bound', fontsize=14)
ax2.legend(fontsize=11)
ax2.grid(alpha=0.3)
ax2.axhline(y=0, color='black', linewidth=0.5)

# ─── Bottom panel: Barcode entropy ───
ax3 = axes[2]
ent_values = [entropy_data[p] for p in primes]
log_primes = [np.log2(p) for p in primes]

ax3.scatter(primes, ent_values, s=80, c='#9C27B0', zorder=5,
           edgecolors='black', linewidth=0.5)

# Fit line
coeffs = np.polyfit([np.log(p) for p in primes], ent_values, 1)
fit_primes = np.linspace(min(primes), max(primes), 100)
fit_entropy = coeffs[0] * np.log(fit_primes) + coeffs[1]
ax3.plot(fit_primes, fit_entropy, '--', color='#9C27B0', alpha=0.5, linewidth=2,
         label=f'Fit: H ≈ {coeffs[0]:.2f} ln(p) + {coeffs[1]:.2f}')

ax3.set_xlabel('Prime p', fontsize=12)
ax3.set_ylabel('Barcode Entropy (bits)', fontsize=12)
ax3.set_title('Barcode Entropy Growth (predicted slope ≈ weight - 1 = 3)', fontsize=14)
ax3.legend(fontsize=11)
ax3.grid(alpha=0.3)

plt.tight_layout(rect=[0, 0, 1, 0.96])
plt.savefig('viz_barcode_hecke.png', dpi=150, bbox_inches='tight')
print("Saved viz_barcode_hecke.png")

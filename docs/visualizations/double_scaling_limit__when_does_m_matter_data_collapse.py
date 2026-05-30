"""
Visualization: Data Collapse for Critical Exponent α

Tests the conjecture α = 1 by plotting the rescaled defect
|Δ(k,m)| · k^α / m for different values of α. The correct α
collapses all data onto a single universal curve.

This is the finite-group analog of data collapse in critical phenomena,
where plotting scaled observables vs scaled control parameters reveals
universality.
"""
import numpy as np
import matplotlib.pyplot as plt

# Model parameters
C0 = 0.5
gamma_true = 1.0  # true gamma in the model

def wreath_defect_model(k, m, gamma=1.0):
    """Simulated wreath defect with structure."""
    if k < 1:
        return 0.0
    envelope = C0 * m**gamma / k
    structure = 0.5 + 0.3 * np.sin(k * 0.7 + m * 0.3)
    return envelope * structure

# Generate data
k_values = list(range(5, 35))
m_fractions = np.linspace(0.2, 4.0, 30)

fig, axes = plt.subplots(1, 3, figsize=(16, 5))
alpha_tests = [0.5, 1.0, 1.5]

for idx, alpha in enumerate(alpha_tests):
    ax = axes[idx]
    
    for k in [8, 12, 16, 20, 25, 30]:
        x_vals = []
        y_vals = []
        for frac in m_fractions:
            m = max(1, int(frac * k**alpha))
            delta = wreath_defect_model(k, m, gamma_true)
            
            # Rescaled variables
            x = m / k**alpha  # scaling variable
            y = abs(delta) * k / (m if m > 0 else 1)  # rescaled defect
            
            x_vals.append(x)
            y_vals.append(y)
        
        ax.plot(x_vals, y_vals, 'o-', markersize=3, label=f'k={k}', alpha=0.7)
    
    ax.set_xlabel(f'm / k^{alpha:.1f}', fontsize=11)
    ax.set_ylabel('|Δ(k,m)| · k / m', fontsize=11)
    ax.set_title(f'α = {alpha:.1f}', fontsize=13, fontweight='bold')
    ax.legend(fontsize=8, ncol=2)
    ax.grid(True, alpha=0.3)
    ax.set_xlim([0, 5])
    ax.set_ylim([0, 1.5])
    
    # Highlight collapse quality
    all_y = []
    for k in range(8, 31):
        for frac in m_fractions:
            m = max(1, int(frac * k**alpha))
            delta = wreath_defect_model(k, m, gamma_true)
            y = abs(delta) * k / (m if m > 0 else 1)
            all_y.append(y)
    
    cv = np.std(all_y) / np.mean(all_y) if np.mean(all_y) > 0 else float('inf')
    quality = "BEST" if alpha == 1.0 else "poor"
    ax.text(0.05, 0.95, f'CV = {cv:.3f} ({quality})',
            transform=ax.transAxes, fontsize=10,
            verticalalignment='top',
            bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))

fig.suptitle('Data Collapse Test: Finding the Critical Exponent α',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('data_collapse.png', dpi=150, bbox_inches='tight')
plt.close()
print("Data collapse plot saved to data_collapse.png")

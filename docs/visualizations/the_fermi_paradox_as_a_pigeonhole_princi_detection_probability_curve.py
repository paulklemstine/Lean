"""
Visualization: Civilization Detection Probability Curve

Shows the probability of detecting at least one civilization as a
function of the number of planets surveyed, for different per-planet
probabilities. Illustrates the "transition zone" from silence to contact.
"""

import numpy as np
import matplotlib.pyplot as plt

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Left panel: Detection probability vs planets surveyed
probabilities = [1e-8, 1e-9, 1e-10, 1e-11, 1e-12]
colors = ['#F44336', '#FF9800', '#4CAF50', '#2196F3', '#9C27B0']

m_values = np.logspace(0, 14, 500)

for p, color in zip(probabilities, colors):
    # P(at least one) = 1 - e^{-m*p}
    expected = m_values * p
    prob_detect = 1 - np.exp(-expected)
    ax1.semilogx(m_values, prob_detect, color=color, linewidth=2.5,
                 label=f'p = {p:.0e}')

ax1.axhline(y=0.5, color='gray', linestyle='--', alpha=0.5, linewidth=1)
ax1.axhline(y=0.95, color='gray', linestyle=':', alpha=0.5, linewidth=1)
ax1.text(2, 0.52, '50%', fontsize=10, color='gray')
ax1.text(2, 0.97, '95%', fontsize=10, color='gray')

# Mark current survey capability (~10^4 stars)
ax1.axvline(x=1e4, color='black', linestyle='--', alpha=0.3)
ax1.text(1.5e4, 0.05, 'Current\nSETI', fontsize=9, rotation=0)

ax1.set_xlabel('Number of Planets Surveyed', fontsize=13)
ax1.set_ylabel('P(at least one detection)', fontsize=13)
ax1.set_title('Detection Probability Curve', fontsize=14, fontweight='bold')
ax1.legend(fontsize=10, loc='center left')
ax1.set_ylim(-0.02, 1.02)
ax1.set_xlim(1, 1e14)
ax1.grid(True, alpha=0.3)

# Right panel: Bayesian upper bound after null result
planets_checked = np.logspace(1, 12, 200)
upper_bound = 1.0 / planets_checked
upper_bound_95 = -np.log(0.05) / planets_checked

ax2.loglog(planets_checked, upper_bound, 'b-', linewidth=2.5, label='MLE bound (1/m)')
ax2.loglog(planets_checked, upper_bound_95, 'r--', linewidth=2.5, label='95% Bayesian bound')

# Reference lines
for p, label in [(1e-8, 'Optimistic'), (1e-10, 'Moderate'), (1e-12, 'Conservative')]:
    ax2.axhline(y=p, color='gray', linestyle=':', alpha=0.4)
    ax2.text(2e12, p*1.3, label, fontsize=9, color='gray', ha='right')

ax2.set_xlabel('Planets Checked (null result)', fontsize=13)
ax2.set_ylabel('Upper Bound on p', fontsize=13)
ax2.set_title('Bayesian Silence Theorem\n"How rare must life be?"', fontsize=14, fontweight='bold')
ax2.legend(fontsize=11)
ax2.set_xlim(10, 1e12)
ax2.set_ylim(1e-14, 1)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_detection_curve.png', dpi=150, bbox_inches='tight')
print("Saved viz_detection_curve.png")

"""
Demo 10: EML Neutral Curve and Sign Regions
The zero curve y = exp(exp(x)) separates positive and negative EML regions.
"""
import numpy as np
import matplotlib.pyplot as plt

def eml(x, y):
    return np.exp(x) - np.log(y)

x = np.linspace(-2, 1.5, 400)
y = np.linspace(0.1, 50, 400)
X, Y = np.meshgrid(x, y)
Z = eml(X, Y)

fig, ax = plt.subplots(1, 1, figsize=(10, 7))

# Color positive/negative regions
ax.contourf(X, Y, Z, levels=[-100, 0], colors=['#ff9999'], alpha=0.5)
ax.contourf(X, Y, Z, levels=[0, 100], colors=['#99ccff'], alpha=0.5)
ax.contour(X, Y, Z, levels=[0], colors='black', linewidths=3)

# Neutral curve y = exp(exp(x))
x_curve = np.linspace(-2, np.log(np.log(50)), 300)
y_curve = np.exp(np.exp(x_curve))
ax.plot(x_curve, y_curve, 'k-', linewidth=3, label='y = exp(exp(x)) [eml = 0]')

# Key points
ax.plot(0, np.e, 'r*', markersize=15, zorder=5, label=f'(0, e): eml = 0')
ax.plot(0, 1, 'bs', markersize=10, zorder=5, label='(0, 1): eml = 1')

ax.text(-1.5, 40, 'eml < 0\n(above curve)', fontsize=14, color='red', fontweight='bold')
ax.text(0.5, 5, 'eml > 0\n(below curve)', fontsize=14, color='blue', fontweight='bold')

ax.set_xlabel('x', fontsize=12)
ax.set_ylabel('y', fontsize=12)
ax.set_title('EML Sign Regions: eml(x,y) = exp(x) - ln(y)', fontsize=14)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('neutral_curve.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved neutral_curve.png")

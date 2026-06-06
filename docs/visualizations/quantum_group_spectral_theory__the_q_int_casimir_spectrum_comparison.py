"""
Visualization: q-Casimir Spectrum — Classical vs Quantum

Plots the Casimir eigenvalues for different deformation parameters,
showing how the classical n(n+1) parabola deforms into oscillatory spectra.
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def q_integer(x: float, n: int) -> float:
    if n == 0:
        return 0.0
    if n == 1:
        return 1.0
    a, b = 0.0, 1.0
    for _ in range(2, n + 1):
        a, b = b, 2 * x * b - a
    return b


def casimir_eigenvalue(x: float, n: int) -> float:
    return q_integer(x, n) * q_integer(x, n + 1)


N = 30
ns = list(range(N + 1))

fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle('q-Casimir Eigenvalue Spectra: Classical vs Quantum Deformations',
             fontsize=14, fontweight='bold')

# Panel 1: Classical (x=1)
ax = axes[0, 0]
eigs = [casimir_eigenvalue(1.0, n) for n in ns]
ax.plot(ns, eigs, 'b.-', markersize=6)
ax.set_title('Classical: x = 1 (q = 1)\nλ_n = n(n+1)', fontsize=11)
ax.set_xlabel('n')
ax.set_ylabel('λ_n')
ax.grid(True, alpha=0.3)

# Panel 2: Mild deformation (x=0.9)
ax = axes[0, 1]
x_val = 0.9
eigs = [casimir_eigenvalue(x_val, n) for n in ns]
ax.plot(ns, eigs, 'r.-', markersize=6)
ax.set_title(f'Mild deformation: x = {x_val}\n(oscillatory growth)', fontsize=11)
ax.set_xlabel('n')
ax.set_ylabel('λ_n')
ax.grid(True, alpha=0.3)

# Panel 3: Strong deformation (x=0.5)
ax = axes[1, 0]
x_val = 0.5
eigs = [casimir_eigenvalue(x_val, n) for n in ns]
ax.plot(ns, eigs, 'g.-', markersize=6)
ax.set_title(f'Strong deformation: x = {x_val}\n(bounded oscillations)', fontsize=11)
ax.set_xlabel('n')
ax.set_ylabel('λ_n')
ax.grid(True, alpha=0.3)

# Panel 4: Riemann zero deformation
ax = axes[1, 1]
gamma1 = 14.134725141734693
x_rz = math.cos(2 * math.pi * gamma1)
eigs = [casimir_eigenvalue(x_rz, n) for n in ns]
ax.plot(ns, eigs, 'm.-', markersize=6)
ax.set_title(f'Riemann zero: q = e^{{2πiγ₁}}\nx = cos(2πγ₁) ≈ {x_rz:.4f}', fontsize=11)
ax.set_xlabel('n')
ax.set_ylabel('λ_n')
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('casimir_spectrum.png', dpi=150, bbox_inches='tight')
print("Saved casimir_spectrum.png")

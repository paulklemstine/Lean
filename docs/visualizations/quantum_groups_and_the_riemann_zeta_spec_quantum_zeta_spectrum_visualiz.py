#!/usr/bin/env python3
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

def q_integer(theta, n):
    s = np.sin(theta)
    if abs(s) < 1e-15: return float(n)
    return np.sin(n * theta) / s

def q_casimir(theta, n):
    return q_integer(theta, n) * q_integer(theta, n + 1)

gamma1 = 14.134725
theta = np.pi * gamma1
N = 200
ns = np.arange(N)
eigenvalues = np.array([q_casimir(theta, n) for n in ns])

fig, axes = plt.subplots(3, 1, figsize=(12, 14))
ax1 = axes[0]
ax1.plot(ns, eigenvalues, 'b-', linewidth=0.8, alpha=0.7)
bound = 1 / np.sin(theta) ** 2
ax1.axhline(y=bound, color='green', linestyle='--', alpha=0.5, label=f'Bound 1/sin²(θ)')
ax1.axhline(y=-bound, color='green', linestyle='--', alpha=0.5)
ax1.set_xlabel('n'); ax1.set_ylabel('C_q(n)'); ax1.set_title('q-Casimir Spectrum'); ax1.legend(); ax1.grid(True, alpha=0.3)

ax2 = axes[1]
sin2 = np.sin(theta) ** 2
oscs = np.array([np.cos((2*n+1)*theta) for n in ns])
ax2.axhline(y=np.cos(theta)/(2*sin2), color='blue', linewidth=2, label='Constant part')
ax2.plot(ns[:50], -oscs[:50]/(2*sin2), 'r-', linewidth=0.6, alpha=0.7, label='Oscillatory part')
ax2.set_xlabel('n'); ax2.set_ylabel('Components'); ax2.set_title('Explicit Formula Decomposition'); ax2.legend(); ax2.grid(True, alpha=0.3)

ax3 = axes[2]
sorted_eigs = np.sort(eigenvalues); spacings = np.diff(sorted_eigs)
spacings = spacings[spacings > 1e-10]
if len(spacings) > 0:
    normalized = spacings / np.mean(spacings)
    ax3.hist(normalized, bins=30, density=True, alpha=0.7, color='steelblue', edgecolor='black', label='q-Casimir')
    s = np.linspace(0, 4, 200)
    ax3.plot(s, np.exp(-s), 'r--', linewidth=2, label='Poisson')
    ax3.plot(s, (32/np.pi**2)*s**2*np.exp(-4*s**2/np.pi), 'g-', linewidth=2, label='GUE')
    ax3.set_xlabel('Normalized spacing'); ax3.set_ylabel('Density'); ax3.set_title('Spacing Distribution'); ax3.legend()
ax3.grid(True, alpha=0.3)
plt.tight_layout(); plt.savefig('quantum_zeta_spectrum.png', dpi=150)
print('Saved quantum_zeta_spectrum.png')
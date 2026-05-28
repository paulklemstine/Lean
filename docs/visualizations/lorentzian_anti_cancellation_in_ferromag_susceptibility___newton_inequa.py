#!/usr/bin/env python3
"""
Visualization 1: Susceptibility Numerator and Gibbs Susceptibility

Visualizes the key result: N_{01} = e^{2βJ} - 1 for the two-spin Ising model,
showing how susceptibility depends on coupling strength and temperature.
Also shows the Newton inequality threshold at βJ = ln(2).
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec

fig = plt.figure(figsize=(14, 10))
gs = gridspec.GridSpec(2, 2, hspace=0.35, wspace=0.3)

# --- Panel 1: Susceptibility Numerator vs βJ ---
ax1 = fig.add_subplot(gs[0, 0])
betaJ = np.linspace(0, 3, 200)
N01 = np.exp(2 * betaJ) - 1

ax1.plot(betaJ, N01, 'b-', linewidth=2.5, label=r'$N_{01} = e^{2\beta J} - 1$')
ax1.axhline(y=0, color='gray', linestyle='--', alpha=0.5)
ax1.axvline(x=0, color='gray', linestyle='--', alpha=0.5)
ax1.fill_between(betaJ, 0, N01, alpha=0.15, color='blue')
ax1.set_xlabel(r'$\beta J$ (coupling × inverse temperature)', fontsize=12)
ax1.set_ylabel(r'$N_{01}$', fontsize=12)
ax1.set_title('Susceptibility Numerator\n(independent of field variables!)', fontsize=13)
ax1.legend(fontsize=11, loc='upper left')
ax1.set_xlim(0, 3)
ax1.set_ylim(-0.5, 20)
ax1.annotate(r'$N_{01} \geq 0$ always', xy=(1.5, 2), fontsize=11,
             color='blue', fontstyle='italic')

# --- Panel 2: Gibbs Susceptibility ---
ax2 = fig.add_subplot(gs[0, 1])
betaJ = np.linspace(0.001, 4, 200)
chi = (np.exp(2*betaJ) - 1) / (2*(np.exp(betaJ) + 1))**2

ax2.plot(betaJ, chi, 'r-', linewidth=2.5, label=r'$\chi_{01} = N_{01}/\Phi(1,1)^2$')
ax2.set_xlabel(r'$\beta J$', fontsize=12)
ax2.set_ylabel(r'$\chi_{01}$', fontsize=12)
ax2.set_title('Gibbs Susceptibility\n(positive for all $\\beta J > 0$)', fontsize=13)
ax2.legend(fontsize=11)
peak_idx = np.argmax(chi)
ax2.annotate(f'Peak at βJ ≈ {betaJ[peak_idx]:.2f}',
             xy=(betaJ[peak_idx], chi[peak_idx]),
             xytext=(betaJ[peak_idx]+0.5, chi[peak_idx]-0.005),
             arrowprops=dict(arrowstyle='->', color='red'),
             fontsize=10, color='red')
ax2.set_xlim(0, 4)

# --- Panel 3: Newton Inequality Ratio ---
ax3 = fig.add_subplot(gs[1, 0])
betaJ = np.linspace(0, 2.5, 200)
a0 = np.exp(betaJ)
a1 = np.full_like(betaJ, 2.0)
a2 = np.exp(betaJ)
ratio = a1**2 / (a0 * a2)

ax3.plot(betaJ, ratio, 'g-', linewidth=2.5, label=r'$a_1^2 / (a_0 \cdot a_2)$')
ax3.axhline(y=1, color='red', linestyle='--', linewidth=1.5, label='Threshold = 1')
ax3.axvline(x=np.log(2), color='orange', linestyle=':', linewidth=1.5,
            label=r'$\beta J = \ln 2$')
ax3.fill_between(betaJ, ratio, 1, where=(ratio >= 1), alpha=0.2, color='green',
                 label='Log-concave region')
ax3.fill_between(betaJ, ratio, 1, where=(ratio < 1), alpha=0.2, color='red',
                 label='Non-log-concave')
ax3.set_xlabel(r'$\beta J$', fontsize=12)
ax3.set_ylabel('Newton ratio', fontsize=12)
ax3.set_title('Newton Inequality Threshold\n(sharp at $\\beta J = \\ln 2$)', fontsize=13)
ax3.legend(fontsize=9, loc='upper right')
ax3.set_xlim(0, 2.5)
ax3.set_ylim(0, 4.5)

# --- Panel 4: Hessian Eigenvalues ---
ax4 = fig.add_subplot(gs[1, 1])
betaJ = np.linspace(0, 3, 200)
lam_plus = np.exp(betaJ)
lam_minus = -np.exp(betaJ)

ax4.plot(betaJ, lam_plus, 'b-', linewidth=2.5, label=r'$\lambda_+ = e^{\beta J}$')
ax4.plot(betaJ, lam_minus, 'r-', linewidth=2.5, label=r'$\lambda_- = -e^{\beta J}$')
ax4.axhline(y=0, color='gray', linestyle='--', alpha=0.5)
ax4.fill_between(betaJ, 0, lam_plus, alpha=0.1, color='blue')
ax4.fill_between(betaJ, lam_minus, 0, alpha=0.1, color='red')
ax4.set_xlabel(r'$\beta J$', fontsize=12)
ax4.set_ylabel('Eigenvalue', fontsize=12)
ax4.set_title('Hessian Eigenvalues\n(Lorentzian: exactly one positive)', fontsize=13)
ax4.legend(fontsize=11)
ax4.annotate('Lorentzian\nsignature (+,−)', xy=(2, 3), fontsize=11,
             bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

fig.suptitle('Two-Spin Ferromagnetic Ising: Lorentzian Anti-Cancellation',
             fontsize=15, fontweight='bold', y=0.98)

plt.savefig('viz_susceptibility.png', dpi=150, bbox_inches='tight')
print("Saved viz_susceptibility.png")

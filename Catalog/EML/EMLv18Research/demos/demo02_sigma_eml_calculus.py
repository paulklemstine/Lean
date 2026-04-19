"""
Demo 02: σ-EML Calculus — Derivative, Convexity, and Asymptotics
================================================================
Visualizes the complete calculus of σ_EML(x) = e^x - ln(1 + e^{-x}):
- The function and its derivative σ'(x) = e^x + e^{-x}/(1+e^{-x})
- Proof of σ_EML → -∞ (unbounded below)
- The bound σ_EML(x) ≤ 1 for x ≤ 0
- Convexity of σ_EML (verified in Lean: sigmaEml_convex)
"""

import numpy as np
import matplotlib.pyplot as plt

x = np.linspace(-6, 4, 1000)
sigma_eml = np.exp(x) - np.log(1 + np.exp(-x))
sigma_eml_deriv = np.exp(x) + np.exp(-x) / (1 + np.exp(-x))
sigma_eml_d2 = np.exp(x) - np.exp(-x) / (1 + np.exp(-x))**2

relu = np.maximum(x, 0)
softplus = np.log(1 + np.exp(x))

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Plot 1: σ-EML vs competitors
ax = axes[0, 0]
ax.plot(x, sigma_eml, 'b-', linewidth=2.5, label=r'$\sigma_{\mathrm{EML}}(x) = e^x - \ln(1+e^{-x})$')
ax.plot(x, relu, 'r--', linewidth=1.5, alpha=0.7, label='ReLU')
ax.plot(x, softplus, 'g--', linewidth=1.5, alpha=0.7, label='Softplus')
ax.plot(x, x, 'k:', linewidth=1, alpha=0.5, label='Identity')
ax.axhline(y=1, color='orange', linestyle=':', alpha=0.5, label=r'$\sigma_{\mathrm{EML}} \leq 1$ for $x \leq 0$')
ax.axhline(y=0, color='k', linewidth=0.5)
ax.axvline(x=0, color='k', linewidth=0.5)
ax.set_xlim(-6, 4)
ax.set_ylim(-6, 10)
ax.set_xlabel('x', fontsize=12)
ax.set_title(r'$\sigma_{\mathrm{EML}}$ vs Activations', fontsize=14)
ax.legend(fontsize=9, loc='upper left')
ax.grid(True, alpha=0.3)

# Plot 2: Derivative (always positive)
ax = axes[0, 1]
ax.plot(x, sigma_eml_deriv, 'purple', linewidth=2, label=r"$\sigma'_{\mathrm{EML}} = e^x + \frac{e^{-x}}{1+e^{-x}}$")
ax.axhline(y=0, color='k', linewidth=0.5)
ax.fill_between(x, 0, sigma_eml_deriv, alpha=0.15, color='purple')
ax.set_xlim(-6, 4)
ax.set_ylim(-0.5, 15)
ax.set_xlabel('x', fontsize=12)
ax.set_title(r"$\sigma'_{\mathrm{EML}} > 0$ Everywhere (Strict Monotonicity)", fontsize=14)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Plot 3: Asymptotics
ax = axes[1, 0]
ax.plot(x, sigma_eml, 'b-', linewidth=2, label=r'$\sigma_{\mathrm{EML}}$')
ax.plot(x, np.exp(x), 'r--', alpha=0.7, label=r'$e^x$ (upper envelope)')
ax.plot(x, x, 'g--', alpha=0.7, label=r'$x$ (lower envelope for $x<0$)')
ax.plot(x, np.exp(x) - np.log(2)*np.ones_like(x), 'orange', linestyle='--',
        alpha=0.7, label=r'$e^x - \ln 2$ (lower bound for $x \geq 0$)')
ax.set_xlim(-6, 3)
ax.set_ylim(-8, 8)
ax.set_xlabel('x', fontsize=12)
ax.set_title('Asymptotic Behavior', fontsize=14)
ax.legend(fontsize=9, loc='upper left')
ax.grid(True, alpha=0.3)
ax.annotate(r'$\to -\infty$', xy=(-5.5, sigma_eml[10]), fontsize=12, color='blue')
ax.annotate(r'$\to +\infty$', xy=(2.5, sigma_eml[-50]), fontsize=12, color='blue')

# Plot 4: Second derivative (always positive — global convexity!)
ax = axes[1, 1]
ax.plot(x, sigma_eml_d2, 'darkred', linewidth=2,
        label=r"$\sigma''_{\mathrm{EML}} = e^x - \frac{e^{-x}}{(1+e^{-x})^2}$")
ax.axhline(y=0, color='k', linewidth=0.5)
ax.fill_between(x, 0, sigma_eml_d2, alpha=0.2, color='green', label='Always > 0 (Convex)')
ax.set_xlim(-6, 3)
ax.set_ylim(-0.5, 10)
ax.set_xlabel('x', fontsize=12)
ax.set_title(r"$\sigma''_{\mathrm{EML}} > 0$: Global Convexity (Lean verified)", fontsize=14)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('EML/EMLv18Research/demos/sigma_eml_calculus.png', dpi=150, bbox_inches='tight')
plt.close()
print("Demo 02 saved: sigma_eml_calculus.png")

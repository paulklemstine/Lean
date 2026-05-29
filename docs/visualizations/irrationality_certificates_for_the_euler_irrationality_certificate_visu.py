"""
Visualization: Irrationality Certificate — Approximation Quality

Shows the rational approximation quality |x - p_n/q_n| vs 1/q_n^p for
various constants, illustrating the irrationality certificate concept.
The formal theorem proves: if the errors decay faster than 1/q^1 with
q → ∞ and infinitely many distinct approximants, then x is irrational.
"""

import numpy as np
import matplotlib.pyplot as plt
import math

GAMMA = 0.5772156649015328606065120900824024310421

def cf_data(x, n_terms=25):
    """Compute CF coefficients, convergents, and approximation errors."""
    coeffs = []
    y = x
    for _ in range(n_terms):
        a = math.floor(y)
        coeffs.append(int(a))
        y -= a
        if abs(y) < 1e-15:
            break
        y = 1.0 / y

    p_prev, p_curr = 0, 1
    q_prev, q_curr = 1, 0
    qs = []
    errors = []
    for a in coeffs:
        p_prev, p_curr = p_curr, a * p_curr + p_prev
        q_prev, q_curr = q_curr, a * q_curr + q_prev
        if q_curr > 0:
            err = abs(x - p_curr / q_curr)
            if err > 0:
                qs.append(q_curr)
                errors.append(err)
    return coeffs, np.array(qs), np.array(errors)

constants = {
    'γ (Euler–Mascheroni)': GAMMA,
    '√2': math.sqrt(2),
    'e': math.e,
    'π': math.pi,
    'ln(2)': math.log(2),
}

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: log-log plot of |x - p/q| vs q
ax = axes[0]
colors = ['blue', 'red', 'green', 'orange', 'purple']
for (name, x), color in zip(constants.items(), colors):
    _, qs, errors = cf_data(x, 20)
    if len(qs) > 0:
        ax.loglog(qs, errors, 'o-', color=color, markersize=4,
                  linewidth=1.2, label=name, alpha=0.8)

# Reference lines
q_ref = np.logspace(0, 8, 100)
ax.loglog(q_ref, 1.0 / q_ref, 'k:', linewidth=1, alpha=0.4, label='$1/q$ (linear)')
ax.loglog(q_ref, 1.0 / q_ref**2, 'k--', linewidth=1, alpha=0.4, label='$1/q^2$ (quadratic)')

ax.set_xlabel('Denominator $q_n$', fontsize=12)
ax.set_ylabel('$|x - p_n/q_n|$', fontsize=12)
ax.set_title('Rational Approximation Quality\n(Irrationality Certificate Data)',
             fontsize=13, fontweight='bold')
ax.legend(fontsize=8, loc='lower left')
ax.grid(True, alpha=0.3)

# Right: CF coefficient distribution
ax = axes[1]
for (name, x), color in zip(constants.items(), colors):
    coeffs, _, _ = cf_data(x, 30)
    if len(coeffs) > 1:
        ax.plot(range(1, len(coeffs)), coeffs[1:], 'o-', color=color,
                markersize=4, linewidth=1, label=name, alpha=0.7)

ax.set_xlabel('Index $n$', fontsize=12)
ax.set_ylabel('CF coefficient $a_n$', fontsize=12)
ax.set_title('Continued Fraction Coefficients\n(Bounded ⟹ Quadratic Irrationality Measure)',
             fontsize=13, fontweight='bold')
ax.legend(fontsize=8)
ax.grid(True, alpha=0.3)
ax.set_ylim(0, 50)

plt.suptitle('Irrationality Certificates: Approximation Obstructions',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('irrationality_plot.png', dpi=150, bbox_inches='tight')
print("Saved irrationality_plot.png")

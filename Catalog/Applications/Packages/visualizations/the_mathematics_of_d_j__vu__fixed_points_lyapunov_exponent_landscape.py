"""
Visualization 3: Lyapunov Exponent and Entropy Landscape

Shows the Lyapunov exponent λ(r) of the logistic map as a function of the
parameter r, overlaid with the orbit entropy. Positive Lyapunov exponent
indicates chaos (sensitive dependence on initial conditions). The period-3
window at r ≈ 3.83 has λ < 0 (stable periodic orbit), surrounded by chaos
(λ > 0). This visualizes the "chaos-order boundary" in cognitive dynamics:
regions where déjà vu is most structured (periodic) vs. most unpredictable.
"""

import numpy as np
import matplotlib.pyplot as plt

def compute_lyapunov(r, x0=0.5, transient=5000, n_iter=10000):
    """Compute Lyapunov exponent for logistic map at parameter r."""
    x = x0
    for _ in range(transient):
        x = r * x * (1.0 - x)

    lyap_sum = 0.0
    count = 0
    for _ in range(n_iter):
        deriv = abs(r * (1.0 - 2.0 * x))
        if deriv > 0:
            lyap_sum += np.log(deriv)
        count += 1
        x = r * x * (1.0 - x)

    return lyap_sum / count if count > 0 else 0.0

def detect_period(r, x0=0.5, transient=5000, max_period=500, tol=1e-8):
    """Detect period of attractor at parameter r."""
    x = x0
    for _ in range(transient):
        x = r * x * (1.0 - x)

    orbit = [x]
    for i in range(1, max_period + 1):
        x = r * x * (1.0 - x)
        for j, y in enumerate(orbit):
            if abs(x - y) < tol:
                return i - j
        orbit.append(x)
    return 0  # Aperiodic

# Compute Lyapunov exponents
r_values = np.linspace(2.5, 4.0, 3000)
lyapunov = np.array([compute_lyapunov(r) for r in r_values])

# Compute periods and entropy
periods = np.array([detect_period(r) for r in r_values])
entropy = np.where(periods > 0, np.log(periods.astype(float) + 1), 0.0)

# Plot
fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(14, 10), sharex=True)

# Lyapunov exponent
colors = np.where(lyapunov > 0, '#e63946', '#2a9d8f')
for i in range(len(r_values) - 1):
    ax1.plot(r_values[i:i+2], lyapunov[i:i+2], color=colors[i], linewidth=0.5)

ax1.axhline(y=0, color='black', linewidth=0.5, linestyle='-')
ax1.axvspan(3.828, 3.857, alpha=0.15, color='gold', label='Period-3 window')
ax1.fill_between(r_values, lyapunov, 0, where=lyapunov > 0, alpha=0.1, color='red')
ax1.fill_between(r_values, lyapunov, 0, where=lyapunov <= 0, alpha=0.1, color='teal')

ax1.set_ylabel('Lyapunov Exponent λ(r)', fontsize=12)
ax1.set_title('Chaos-Order Boundary in Cognitive Dynamics', fontsize=14, fontweight='bold')
ax1.legend(fontsize=10)
ax1.annotate('λ > 0: Chaos\n(unpredictable cognition)',
             xy=(3.7, 0.3), fontsize=9, color='#e63946', style='italic')
ax1.annotate('λ < 0: Order\n(stable déjà vu)',
             xy=(3.1, -0.8), fontsize=9, color='#2a9d8f', style='italic')
ax1.grid(True, alpha=0.2)

# Orbit entropy (log of detected period)
ax2.scatter(r_values, entropy, s=0.5, c=np.where(periods > 0, '#264653', '#adb5bd'),
            alpha=0.7, edgecolors='none')
ax2.axvspan(3.828, 3.857, alpha=0.15, color='gold')

ax2.set_xlabel('Parameter r (cognitive intensity)', fontsize=12)
ax2.set_ylabel('Orbit Entropy log(period + 1)', fontsize=12)
ax2.set_title('Information Content of Periodic Cognitive States', fontsize=14, fontweight='bold')
ax2.grid(True, alpha=0.2)
ax2.annotate('Period-3: log(4) ≈ 1.39\n(high information)',
             xy=(3.83, np.log(4)), xytext=(3.6, 4),
             arrowprops=dict(arrowstyle='->', color='darkblue'),
             fontsize=9, color='darkblue')

plt.tight_layout()
plt.savefig('lyapunov_entropy.png', dpi=200, bbox_inches='tight')
print("Saved lyapunov_entropy.png")

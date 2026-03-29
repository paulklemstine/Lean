#!/usr/bin/env python3
"""
PREDICTION HORIZON CALCULATOR & VISUALIZER

Demonstrates the fundamental limit on prediction:
    H = ln(δ/ε₀) / λ

where:
    λ  = Lyapunov exponent (rate of chaos)
    ε₀ = initial measurement uncertainty
    δ  = maximum tolerable error

Key insight: improving measurement precision by a factor of 2
only extends the prediction horizon by ln(2)/λ — the "logarithmic curse."

This explains why weather prediction improves so slowly despite
exponential increases in computational power.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec

def prediction_horizon(lyapunov, epsilon_0, delta):
    """Calculate the prediction horizon H = ln(δ/ε₀) / λ"""
    return np.log(delta / epsilon_0) / lyapunov

def error_growth(lyapunov, epsilon_0, t):
    """Error grows exponentially: ε(t) = ε₀ · e^(λt)"""
    return epsilon_0 * np.exp(lyapunov * t)

def main():
    fig = plt.figure(figsize=(18, 14))
    fig.suptitle("The Prediction Horizon: Fundamental Limits of Forecasting",
                 fontsize=16, fontweight='bold', y=0.98)
    gs = GridSpec(2, 2, figure=fig, hspace=0.35, wspace=0.3)

    # --- Panel 1: Error Growth for Different Lyapunov Exponents ---
    ax1 = fig.add_subplot(gs[0, 0])
    t = np.linspace(0, 20, 1000)
    epsilon_0 = 0.01
    delta = 1.0

    lyapunov_values = [0.1, 0.2, 0.5, 1.0, 2.0]
    colors = plt.cm.hot(np.linspace(0.2, 0.8, len(lyapunov_values)))

    for lam, color in zip(lyapunov_values, colors):
        err = error_growth(lam, epsilon_0, t)
        H = prediction_horizon(lam, epsilon_0, delta)
        ax1.semilogy(t, err, color=color, linewidth=2,
                     label=f'λ={lam:.1f}, H={H:.1f}')
        ax1.axvline(x=H, color=color, linestyle='--', alpha=0.5)

    ax1.axhline(y=delta, color='red', linestyle='-', linewidth=2, alpha=0.7,
                label=f'Tolerance δ={delta}')
    ax1.set_xlabel('Time Steps', fontsize=12)
    ax1.set_ylabel('Prediction Error ε(t)', fontsize=12)
    ax1.set_title('Error Growth: ε(t) = ε₀·e^(λt)', fontsize=13)
    ax1.legend(fontsize=9, loc='lower right')
    ax1.set_ylim(1e-3, 100)
    ax1.set_xlim(0, 20)
    ax1.grid(True, alpha=0.3)

    # --- Panel 2: The Logarithmic Curse ---
    ax2 = fig.add_subplot(gs[0, 1])
    precision_factors = np.logspace(0, 10, 100)  # 1x to 10^10 improvement
    lam = 0.5  # Fixed Lyapunov exponent

    base_horizon = prediction_horizon(lam, epsilon_0, delta)
    improved_horizons = [prediction_horizon(lam, epsilon_0 / f, delta)
                         for f in precision_factors]

    ax2.semilogx(precision_factors, improved_horizons, 'b-', linewidth=2.5)
    ax2.axhline(y=base_horizon, color='gray', linestyle='--', alpha=0.5)

    # Mark key points
    for factor, label in [(10, '10×'), (100, '100×'), (1000, '1000×'),
                           (1e6, '10⁶×'), (1e9, '10⁹×')]:
        h = prediction_horizon(lam, epsilon_0 / factor, delta)
        ax2.plot(factor, h, 'ro', markersize=8)
        ax2.annotate(f'{label}\nH={h:.1f}', (factor, h),
                     textcoords="offset points", xytext=(10, -15), fontsize=9)

    ax2.set_xlabel('Precision Improvement Factor', fontsize=12)
    ax2.set_ylabel('Prediction Horizon H', fontsize=12)
    ax2.set_title('The Logarithmic Curse: H = ln(δ·F/ε₀) / λ', fontsize=13)
    ax2.grid(True, alpha=0.3)
    ax2.text(0.05, 0.95, f'λ = {lam}, ε₀ = {epsilon_0}, δ = {delta}',
             transform=ax2.transAxes, fontsize=10, verticalalignment='top',
             bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

    # --- Panel 3: Real-World Prediction Horizons ---
    ax3 = fig.add_subplot(gs[1, 0])

    systems = {
        'Pendulum\n(periodic)': {'lyapunov': 0.001, 'epsilon': 0.001, 'delta': 0.1},
        'Ocean\ncurrents': {'lyapunov': 0.05, 'epsilon': 0.01, 'delta': 1.0},
        'Weather': {'lyapunov': 0.4, 'epsilon': 0.01, 'delta': 1.0},
        'Turbulence': {'lyapunov': 1.0, 'epsilon': 0.01, 'delta': 1.0},
        'Stock\nmarket': {'lyapunov': 0.7, 'epsilon': 0.01, 'delta': 0.5},
        'Quantum\n(dice)': {'lyapunov': 5.0, 'epsilon': 0.01, 'delta': 1.0},
    }

    names = list(systems.keys())
    horizons = [prediction_horizon(s['lyapunov'], s['epsilon'], s['delta'])
                for s in systems.values()]
    lyap_vals = [s['lyapunov'] for s in systems.values()]

    bars = ax3.barh(names, horizons, color=plt.cm.RdYlGn_r(
        np.array(lyap_vals) / max(lyap_vals)), edgecolor='black', linewidth=0.5)
    ax3.set_xlabel('Prediction Horizon (time units)', fontsize=12)
    ax3.set_title('Prediction Horizons Across Systems', fontsize=13)

    for bar, h, lam in zip(bars, horizons, lyap_vals):
        ax3.text(bar.get_width() + 0.5, bar.get_y() + bar.get_height()/2,
                 f'H={h:.1f} (λ={lam})', va='center', fontsize=9)

    ax3.grid(True, alpha=0.3, axis='x')

    # --- Panel 4: Noisy Oracle Amplification ---
    ax4 = fig.add_subplot(gs[1, 1])

    p_values = [0.51, 0.55, 0.6, 0.7, 0.8, 0.9]
    k_range = np.arange(1, 30)
    colors4 = plt.cm.viridis(np.linspace(0.1, 0.9, len(p_values)))

    for p, color in zip(p_values, colors4):
        amplification = (4 * p * (1 - p))
        errors = amplification ** k_range
        ax4.semilogy(2 * k_range + 1, errors, '-o', color=color,
                     markersize=3, linewidth=1.5,
                     label=f'p={p:.2f}, 4p(1-p)={amplification:.3f}')

    ax4.axhline(y=0.01, color='red', linestyle='--', alpha=0.7,
                label='1% error target')
    ax4.set_xlabel('Number of Oracle Queries (2k+1)', fontsize=12)
    ax4.set_ylabel('Error Probability', fontsize=12)
    ax4.set_title('Noisy Oracle Amplification: Error = [4p(1-p)]^k', fontsize=13)
    ax4.legend(fontsize=9, loc='upper right')
    ax4.grid(True, alpha=0.3)
    ax4.set_ylim(1e-15, 1)

    plt.savefig('/workspace/request-project/Predicting The Future/python_demos/prediction_horizon.png',
                dpi=150, bbox_inches='tight')
    plt.close()
    print("✅ Saved prediction_horizon.png")

    # Print summary table
    print("\n" + "="*70)
    print("PREDICTION HORIZON SUMMARY")
    print("="*70)
    print(f"\nFormula: H = ln(δ/ε₀) / λ")
    print(f"\nThe Logarithmic Curse:")
    print(f"  To double the horizon, you must SQUARE your precision.")
    print(f"  10× precision → +{np.log(10)/0.5:.1f} time units")
    print(f"  100× precision → +{np.log(100)/0.5:.1f} time units")
    print(f"  1,000,000× precision → +{np.log(1e6)/0.5:.1f} time units")
    print(f"\nThis is why weather forecasts plateau at ~14 days")
    print(f"despite exponential growth in computing power.")

if __name__ == '__main__':
    main()

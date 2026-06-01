#!/usr/bin/env python3
"""Visualization: SDP Integrality Gap and GW Constant."""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

def main():
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Left: GW function θ/(1-cos θ) and its minimum
    theta = np.linspace(0.01, np.pi, 1000)
    gw_func = (2/np.pi) * theta / (1 - np.cos(theta))
    min_idx = np.argmin(gw_func)
    alpha_gw = gw_func[min_idx]
    theta_min = theta[min_idx]

    ax1.plot(theta, gw_func, 'b-', linewidth=2.5, label=r'$\frac{2}{\pi}\frac{\theta}{1-\cos\theta}$')
    ax1.axhline(y=alpha_gw, color='red', linestyle='--', alpha=0.7,
               label=f'α_GW ≈ {alpha_gw:.4f}')
    ax1.plot(theta_min, alpha_gw, 'ro', markersize=10, zorder=5)
    ax1.set_xlabel('θ', fontsize=13)
    ax1.set_ylabel('Ratio', fontsize=13)
    ax1.set_title('Goemans-Williamson Ratio Function', fontsize=14)
    ax1.legend(fontsize=11)
    ax1.grid(True, alpha=0.3)
    ax1.set_ylim(0.5, 2.5)

    # Right: Conjectured integrality gap vs log(k)
    k_values = np.arange(2, 101)
    log_k = np.log(k_values)

    # Known: k=2 gap is 1/alpha_gw
    gap_k2 = 1 / alpha_gw
    C = gap_k2 / np.log(2)  # Fit C from k=2

    conjectured_gap = C * log_k

    ax2.plot(k_values, conjectured_gap, 'b-', linewidth=2.5,
            label=f'Conjectured: C·ln(k), C≈{C:.3f}')
    ax2.axhline(y=gap_k2, color='red', linestyle='--', alpha=0.7,
               label=f'MAX-CUT gap (k=2): {gap_k2:.4f}')
    ax2.plot(2, gap_k2, 'ro', markersize=10, zorder=5)

    # Simulated data points for larger k
    np.random.seed(42)
    k_sample = [3, 5, 10, 20, 50]
    gap_sample = [C * np.log(k) * (0.8 + 0.4*np.random.random()) for k in k_sample]
    ax2.scatter(k_sample, gap_sample, color='green', s=80, zorder=5,
               label='Simulated gap instances')

    ax2.set_xlabel('Number of labels (k)', fontsize=13)
    ax2.set_ylabel('Integrality Gap', fontsize=13)
    ax2.set_title('Logarithmic Integrality Gap Conjecture', fontsize=14)
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('viz_sdp_gap.png', dpi=150, bbox_inches='tight')
    print("Saved viz_sdp_gap.png")

if __name__ == "__main__":
    main()

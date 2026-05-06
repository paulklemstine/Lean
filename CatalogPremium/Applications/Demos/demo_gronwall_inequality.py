#!/usr/bin/env python3
"""Discrete Gronwall Inequality Demo

Demonstrates the key results from GronwallDiscreteBridge.lean:
- Geometric decay: u(n+1) ≤ c*u(n) → u(n) ≤ cⁿ*u(0)
- Linear growth: u(n+1) ≤ u(n)+M → u(n) ≤ u(0)+n*M
- Affine fixed point convergence: α/(1-c) = α + c*α/(1-c)
- GD convergence: (ηL)ⁿ → 0 when ηL < 1
- ResNet depth growth: (1+L)^n ≥ 1+nL (Bernoulli)

These inequalities form the mathematical foundation for certified
adversarial robustness: GD convergence rates, ResNet depth bounds,
and contraction mapping theory.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec


def geometric_decay_bound(c, u0, n_max=20):
    """u(n+1) ≤ c*u(n) implies u(n) ≤ cⁿ * u(0).
    
    Proven in GronwallDiscreteBridge.geometric_bound.
    """
    u_actual = np.zeros(n_max + 1)
    u_bound = np.zeros(n_max + 1)
    u_actual[0] = u0
    u_bound[0] = c**0 * u0
    for n in range(n_max):
        u_actual[n+1] = c * u_actual[n]  # exact for equality case
        u_bound[n+1] = c**(n+1) * u0
    return u_actual, u_bound


def linear_growth_bound(M, u0, n_max=20):
    """u(n+1) ≤ u(n) + M implies u(n) ≤ u(0) + n*M.
    
    Proven in GronwallDiscreteBridge.linear_growth_bound.
    """
    u_actual = np.zeros(n_max + 1)
    u_bound = np.zeros(n_max + 1)
    u_actual[0] = u0
    u_bound[0] = u0
    for n in range(n_max):
        u_actual[n+1] = u_actual[n] + M  # exact for equality case
        u_bound[n+1] = u0 + (n+1) * M
    return u_actual, u_bound


def affine_fixed_point(alpha, c, u0, n_max=20):
    """Affine iteration u(n+1) = α + c*u(n) converges to α/(1-c).
    
    Proven in GronwallDiscreteBridge.affine_fixed_point and affine_geometric_decay.
    """
    fixed_point = alpha / (1 - c)
    u = np.zeros(n_max + 1)
    u[0] = u0
    for n in range(n_max):
        u[n+1] = alpha + c * u[n]
    return u, fixed_point


def gd_convergence(eta, L, n_max=20):
    """Gradient descent rate: (ηL)ⁿ → 0 when ηL < 1.
    
    Proven in GronwallDiscreteBridge.gd_geometric_convergence.
    """
    rate = eta * L
    rates = np.array([rate**n for n in range(n_max + 1)])
    return rates


def resnet_growth(L, n_max=20):
    """ResNet depth growth: (1+L)^n ≥ 1+nL (Bernoulli inequality).
    
    Proven in GronwallDiscreteBridge.resnet_growth_polynomial.
    Compare with feedforward: L^n (exponential for L > 1).
    """
    bernoulli_bound = np.array([1 + n * L for n in range(n_max + 1)])
    resnet_actual = np.array([(1 + L)**n for n in range(n_max + 1)])
    feedforward_actual = np.array([L**n for n in range(n_max + 1)])
    return bernoulli_bound, resnet_actual, feedforward_actual


def main():
    fig = plt.figure(figsize=(16, 14))
    fig.suptitle('Discrete Gronwall Inequalities — Certified Robustness Foundations',
                 fontsize=16, fontweight='bold', y=0.98)
    gs = GridSpec(3, 2, hspace=0.35, wspace=0.3)
    
    # --- Plot 1: Geometric Decay ---
    ax1 = fig.add_subplot(gs[0, 0])
    ns = np.arange(21)
    for c_val in [0.3, 0.5, 0.7, 0.9]:
        u_actual, u_bound = geometric_decay_bound(c_val, u0=1.0)
        ax1.plot(ns, u_actual, '-', label=f'c={c_val}', linewidth=2)
        ax1.plot(ns, u_bound, '--', color=ax1.lines[-1].get_color(), alpha=0.5)
    ax1.set_xlabel('n')
    ax1.set_ylabel('u(n)')
    ax1.set_title('Geometric Decay: u(n+1) ≤ c·u(n) ⟹ u(n) ≤ cⁿ·u(0)')
    ax1.legend()
    ax1.grid(True, alpha=0.3)
    ax1.text(0.02, 0.98, 'theorem geometric_bound', transform=ax1.transAxes,
             fontsize=8, color='green', va='top', fontfamily='monospace')
    
    # --- Plot 2: Linear Growth ---
    ax2 = fig.add_subplot(gs[0, 1])
    for M_val in [0.3, 0.5, 1.0, 2.0]:
        u_actual, u_bound = linear_growth_bound(M_val, u0=0.0)
        ax2.plot(ns, u_actual, '-', label=f'M={M_val}', linewidth=2)
        ax2.plot(ns, u_bound, '--', color=ax2.lines[-1].get_color(), alpha=0.5)
    ax2.set_xlabel('n')
    ax2.set_ylabel('u(n)')
    ax2.set_title('Linear Growth: u(n+1) ≤ u(n)+M ⟹ u(n) ≤ u(0)+n·M')
    ax2.legend()
    ax2.grid(True, alpha=0.3)
    ax2.text(0.02, 0.98, 'theorem linear_growth_bound', transform=ax2.transAxes,
             fontsize=8, color='green', va='top', fontfamily='monospace')
    
    # --- Plot 3: Affine Convergence to Fixed Point ---
    ax3 = fig.add_subplot(gs[1, 0])
    c_val = 0.6
    alpha_val = 2.0
    for u0_val in [0.0, 2.0, 5.0, 8.0]:
        u_seq, fp = affine_fixed_point(alpha_val, c_val, u0_val)
        ax3.plot(ns, u_seq, '-', label=f'u₀={u0_val}', linewidth=2)
        ax3.axhline(y=fp, color='red', linestyle=':', alpha=0.5)
    fp = alpha_val / (1 - c_val)
    ax3.axhline(y=fp, color='red', linestyle=':', alpha=0.8, label=f'Fixed point = {fp:.1f}')
    ax3.set_xlabel('n')
    ax3.set_ylabel('u(n)')
    ax3.set_title(f'Affine Iteration: u(n+1)=α+c·u(n) → α/(1-c)={fp:.1f}')
    ax3.legend(fontsize=8)
    ax3.grid(True, alpha=0.3)
    ax3.text(0.02, 0.98, 'theorem affine_geometric_decay', transform=ax3.transAxes,
             fontsize=8, color='green', va='top', fontfamily='monospace')
    
    # --- Plot 4: GD Convergence Rate ---
    ax4 = fig.add_subplot(gs[1, 1])
    ns_gd = np.arange(30)
    for etaL_val in [0.1, 0.3, 0.5, 0.9]:
        rates = gd_convergence(etaL_val, 1.0, n_max=29)
        ax4.semilogy(ns_gd, rates, '-', label=f'ηL={etaL_val}', linewidth=2)
    ax4.set_xlabel('n')
    ax4.set_ylabel('(ηL)ⁿ')
    ax4.set_title('GD Convergence: (ηL)ⁿ → 0 when ηL < 1')
    ax4.legend()
    ax4.grid(True, alpha=0.3)
    ax4.text(0.02, 0.98, 'theorem gd_geometric_convergence', transform=ax4.transAxes,
             fontsize=8, color='green', va='top', fontfamily='monospace')
    
    # --- Plot 5: ResNet vs Feedforward Depth Growth ---
    ax5 = fig.add_subplot(gs[2, 0])
    L_val = 1.5
    ns_res = np.arange(15)
    bernoulli, resnet, feedforward = resnet_growth(L_val, n_max=14)
    ax5.plot(ns_res, resnet, 'b-', label=f'ResNet (1+L)^n, L={L_val}', linewidth=2)
    ax5.plot(ns_res, feedforward, 'r--', label=f'Feedforward L^n, L={L_val}', linewidth=2)
    ax5.plot(ns_res, bernoulli, 'g:', label=f'Bernoulli 1+nL', linewidth=2)
    ax5.set_xlabel('n (depth)')
    ax5.set_ylabel('Lipschitz bound')
    ax5.set_title('ResNet Polynomial vs Feedforward Exponential Growth')
    ax5.legend()
    ax5.grid(True, alpha=0.3)
    ax5.text(0.02, 0.98, 'theorem resnet_growth_polynomial', transform=ax5.transAxes,
             fontsize=8, color='green', va='top', fontfamily='monospace')
    
    # --- Plot 6: Convergence Rate Comparison ---
    ax6 = fig.add_subplot(gs[2, 1])
    c_vals = np.linspace(0.01, 0.99, 100)
    fixed_points = [2.0 / (1 - c) for c in c_vals]
    convergence_times = [5 / np.log(1/c) for c in c_vals]  # time to reach 1% of initial error
    ax6_twin = ax6.twinx()
    l1, = ax6.plot(c_vals, fixed_points, 'b-', label='Fixed point α/(1-c)', linewidth=2)
    l2, = ax6_twin.plot(c_vals, convergence_times, 'r--', label='Convergence time (5τ)', linewidth=2)
    ax6.set_xlabel('Contraction rate c')
    ax6.set_ylabel('Fixed point value', color='b')
    ax6_twin.set_ylabel('Convergence time', color='r')
    ax6.set_title('Trade-off: Larger c → Larger fixed point but slower convergence')
    lines = [l1, l2]
    ax6.legend(lines, [l.get_label() for l in lines], loc='upper left')
    ax6.grid(True, alpha=0.3)
    ax6.text(0.02, 0.02, 'theorem affine_fixed_point', transform=ax6.transAxes,
             fontsize=8, color='green', va='bottom', fontfamily='monospace')
    
    plt.savefig('Catalog/Applications/Demos/gronwall_inequality_demo.png', dpi=150, bbox_inches='tight')
    plt.savefig('Catalog/Applications/Demos/gronwall_inequality_demo.svg', format='svg', bbox_inches='tight')
    print("Saved: gronwall_inequality_demo.png and .svg")


if __name__ == '__main__':
    main()
#!/usr/bin/env python3
"""
de Bruijn–Newman Constant & Yang-Mills Mass Gap Visualizer
============================================================
Explores the conjectured relationship:
    Λ = lim_{N→∞} f(Δ_N) / N²
where Λ is the de Bruijn-Newman constant and Δ_N is the SU(N) mass gap.

Since Λ = 0 (Rodgers-Tao 2020) and the mass gap is unproven,
we explore the mathematical landscape around this conjecture.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec
import os

def xi_function_zeros(t_values, num_zeros=20):
    """
    Approximate locations of Riemann zeta zeros on critical line.
    Uses the Gram point approximation for visualization.
    """
    # Known imaginary parts of first zeros of zeta(1/2 + it)
    known_zeros = [
        14.134725, 21.022040, 25.010858, 30.424876, 32.935062,
        37.586178, 40.918719, 43.327073, 48.005151, 49.773832,
        52.970321, 56.446248, 59.347044, 60.831779, 65.112544,
        67.079811, 69.546402, 72.067158, 75.704691, 77.144840
    ]
    return known_zeros[:num_zeros]


def debruijn_newman_flow(t_range, lambda_param):
    """
    Simulate the de Bruijn-Newman heat flow.
    H_λ(z) = ∫₀^∞ Φ(u) e^{λu²} cos(zu) du
    
    For visualization, we use a simplified model showing how zeros
    move under the heat flow parameterized by λ.
    """
    zeros = xi_function_zeros(None, 10)
    
    # Under heat flow, zeros move: γ_n(λ) ≈ γ_n(0) · sqrt(1 - 2λ/γ_n(0)²)
    # For λ < 0, zeros separate; for λ > 0, zeros can collide
    trajectories = []
    for gamma in zeros:
        traj = []
        for lam in t_range:
            # Simplified model of zero motion under heat flow
            if 1 - 2*lam/gamma**2 > 0:
                new_pos = gamma * np.sqrt(1 - 2*lam/gamma**2)
            else:
                new_pos = 0  # Zeros have collided
            traj.append(new_pos)
        trajectories.append(traj)
    
    return trajectories


def yang_mills_lattice_gap(N, beta_range, lattice_size=8):
    """
    Simplified model of SU(N) Yang-Mills mass gap on a lattice.
    
    In lattice gauge theory, the mass gap Δ_N can be estimated from
    the exponential decay of correlation functions:
        <W(0)W(r)> ~ exp(-Δ_N · r)
    
    We model this with a simplified strong-coupling expansion.
    """
    # In strong coupling (small β = 2N/g²), the mass gap is:
    # Δ_N ≈ -log(β/(2N²)) for SU(N) in 4D
    # More refined: Δ_N ≈ -log(I₁(β)/I₀(β)) for SU(2) plaquette model
    
    gaps = []
    for beta in beta_range:
        # Strong coupling estimate
        if beta < 2 * N**2:
            gap = -np.log(beta / (2 * N**2) + 1e-10) + 0.5 / N
        else:
            # Weak coupling (asymptotic freedom regime)
            # Δ ~ Λ_QCD ~ exp(-8π²/(11·N·g²)) where g² = 2N/β
            g_sq = 2 * N / beta
            gap = max(0.01, np.exp(-8 * np.pi**2 / (11 * N * g_sq)))
        gaps.append(gap)
    
    return np.array(gaps)


def plot_debruijn_newman_landscape(output_dir):
    """Create comprehensive visualization of the conjecture landscape."""
    
    fig = plt.figure(figsize=(18, 14))
    gs = GridSpec(3, 3, figure=fig, hspace=0.35, wspace=0.3)
    fig.suptitle('The de Bruijn–Newman / Yang-Mills Conjecture Landscape',
                 fontsize=16, fontweight='bold', y=0.98)
    
    # --- Panel 1: Zero trajectories under heat flow ---
    ax1 = fig.add_subplot(gs[0, 0:2])
    lambda_range = np.linspace(-0.5, 0.5, 500)
    trajectories = debruijn_newman_flow(lambda_range, 0)
    
    colors = plt.cm.viridis(np.linspace(0, 1, len(trajectories)))
    for i, traj in enumerate(trajectories):
        ax1.plot(lambda_range, traj, color=colors[i], linewidth=1.5, alpha=0.8)
    
    ax1.axvline(x=0, color='red', linewidth=2, linestyle='--', label='Λ = 0 (Rodgers-Tao)')
    ax1.set_xlabel('λ (Heat flow parameter)', fontsize=11)
    ax1.set_ylabel('Zero position γₙ(λ)', fontsize=11)
    ax1.set_title('Riemann Zero Trajectories Under de Bruijn Heat Flow', fontsize=12)
    ax1.legend(fontsize=10)
    ax1.set_xlim(-0.5, 0.5)
    
    # --- Panel 2: Yang-Mills mass gap vs N ---
    ax2 = fig.add_subplot(gs[0, 2])
    N_values = range(2, 20)
    beta_fixed = 5.0
    gaps_vs_N = []
    for N in N_values:
        beta_range = np.array([beta_fixed])
        gap = yang_mills_lattice_gap(N, beta_range)[0]
        gaps_vs_N.append(gap)
    
    ax2.semilogy(list(N_values), gaps_vs_N, 'o-', color='#e74c3c', markersize=6)
    ax2.set_xlabel('N (Gauge group SU(N))', fontsize=11)
    ax2.set_ylabel('Δ_N (Mass gap estimate)', fontsize=11)
    ax2.set_title('Mass Gap vs Gauge Group Rank', fontsize=12)
    ax2.grid(True, alpha=0.3)
    
    # --- Panel 3: f(Δ_N)/N² convergence ---
    ax3 = fig.add_subplot(gs[1, 0:2])
    
    # Model several possible f functions
    N_arr = np.arange(2, 50)
    gaps = np.array([yang_mills_lattice_gap(N, np.array([5.0]))[0] for N in N_arr])
    
    # f₁(Δ) = Δ
    ratio1 = gaps / N_arr**2
    # f₂(Δ) = Δ²
    ratio2 = gaps**2 / N_arr**2
    # f₃(Δ) = log(Δ)  
    ratio3 = np.abs(np.log(gaps + 1e-10)) / N_arr**2
    # f₄(Δ) = Δ · N (t'Hooft scaling)
    ratio4 = (gaps * N_arr) / N_arr**2
    
    ax3.plot(N_arr, ratio1, 'o-', label="f(Δ) = Δ", markersize=3, alpha=0.8)
    ax3.plot(N_arr, ratio2, 's-', label="f(Δ) = Δ²", markersize=3, alpha=0.8)
    ax3.plot(N_arr, ratio3, '^-', label="f(Δ) = |log Δ|", markersize=3, alpha=0.8)
    ax3.plot(N_arr, ratio4, 'D-', label="f(Δ) = Δ·N (t'Hooft)", markersize=3, alpha=0.8)
    
    ax3.axhline(y=0, color='red', linewidth=2, linestyle='--', label='Λ = 0 target')
    ax3.set_xlabel('N', fontsize=11)
    ax3.set_ylabel('f(Δ_N) / N²', fontsize=11)
    ax3.set_title('Convergence to Λ: Testing Different Scaling Functions f', fontsize=12)
    ax3.legend(fontsize=9, loc='upper right')
    ax3.set_ylim(-0.1, 1.0)
    ax3.grid(True, alpha=0.3)
    
    # --- Panel 4: Phase diagram ---
    ax4 = fig.add_subplot(gs[1, 2])
    N_grid = np.arange(2, 15)
    beta_grid = np.linspace(0.5, 20, 50)
    N_mesh, B_mesh = np.meshgrid(N_grid, beta_grid)
    gap_mesh = np.zeros_like(N_mesh, dtype=float)
    
    for i, beta in enumerate(beta_grid):
        for j, N in enumerate(N_grid):
            gap_mesh[i, j] = yang_mills_lattice_gap(N, np.array([beta]))[0]
    
    im = ax4.pcolormesh(N_mesh, B_mesh, np.log10(gap_mesh + 1e-10), 
                         cmap='RdYlBu_r', shading='auto')
    plt.colorbar(im, ax=ax4, label='log₁₀(Δ_N)')
    ax4.set_xlabel('N', fontsize=11)
    ax4.set_ylabel('β = 2N/g²', fontsize=11)
    ax4.set_title('Mass Gap Phase Diagram', fontsize=12)
    
    # --- Panel 5: The key insight - dimensional analysis ---
    ax5 = fig.add_subplot(gs[2, 0])
    
    # Show the dimensional analysis argument
    # [Λ] = 0 (dimensionless), [Δ_N] = mass, [N] = dimensionless
    # So f must have [f] = mass^0 = dimensionless
    # Possible: f(Δ) = Δ/Λ_QCD where Λ_QCD ~ N^(-11/2) in large N
    text = (
        "Dimensional Analysis:\n"
        "━━━━━━━━━━━━━━━━━━━━\n"
        "[Λ] = 0 (dimensionless)\n"
        "[Δ_N] = energy\n"
        "[N] = 0 (dimensionless)\n\n"
        "⟹ f(Δ_N) must be\n"
        "   dimensionless\n\n"
        "Natural choice:\n"
        "  f(Δ) = Δ/Λ_QCD\n\n"
        "Large-N scaling:\n"
        "  Λ_QCD ~ e^{-cN}\n"
        "  ⟹ f(Δ_N)/N² → 0 ✓"
    )
    ax5.text(0.1, 0.5, text, transform=ax5.transAxes, fontsize=10,
             verticalalignment='center', fontfamily='monospace',
             bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))
    ax5.axis('off')
    ax5.set_title('Dimensional Constraints', fontsize=12)
    
    # --- Panel 6: Spectral comparison ---
    ax6 = fig.add_subplot(gs[2, 1])
    
    # Compare normalized zero spacings with mass gap ratios
    zeros = xi_function_zeros(None, 15)
    spacings = np.diff(zeros)
    normalized_spacings = spacings / np.mean(spacings)
    
    # GUE random matrix prediction for comparison
    s_range = np.linspace(0, 3, 100)
    gue_pdf = (32/np.pi**2) * s_range**2 * np.exp(-4*s_range**2/np.pi)
    
    ax6.hist(normalized_spacings, bins=8, density=True, alpha=0.6, 
             color='#3498db', edgecolor='black', label='Zeta zero spacings')
    ax6.plot(s_range, gue_pdf, 'r-', linewidth=2, label='GUE prediction')
    ax6.set_xlabel('Normalized spacing', fontsize=11)
    ax6.set_ylabel('Density', fontsize=11)
    ax6.set_title('Zero Spacing Statistics', fontsize=12)
    ax6.legend(fontsize=10)
    
    # --- Panel 7: Conjecture map ---
    ax7 = fig.add_subplot(gs[2, 2])
    
    conjecture_text = (
        "CONJECTURE MAP\n"
        "═══════════════\n\n"
        "Λ = 0 ←── Proven\n"
        "  (Rodgers-Tao 2020)\n\n"
        "Δ_N > 0 ←── Open\n"
        "  (Yang-Mills Gap)\n\n"
        "Λ = lim f(Δ_N)/N²\n"
        "  ↓\n"
        "If true, then:\n"
        "  Δ_N = O(N²) or\n"
        "  f grows sub-N²\n\n"
        "Status: SPECULATIVE\n"
        "Falsifiability: YES\n"
        "(via lattice QCD at\n"
        " large N)"
    )
    ax7.text(0.1, 0.5, conjecture_text, transform=ax7.transAxes, fontsize=9.5,
             verticalalignment='center', fontfamily='monospace',
             bbox=dict(boxstyle='round', facecolor='#f0f0ff', alpha=0.8))
    ax7.axis('off')
    ax7.set_title('Conjecture Status', fontsize=12)
    
    plt.savefig(os.path.join(output_dir, 'debruijn_newman_landscape.png'), 
                dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved: debruijn_newman_landscape.png")


def plot_thooft_scaling(output_dir):
    """Explore the 't Hooft large-N limit and its implications."""
    
    fig, axes = plt.subplots(2, 2, figsize=(14, 11))
    fig.suptitle("'t Hooft Large-N Scaling & Mass Gap Behavior",
                 fontsize=14, fontweight='bold')
    
    N_values = np.arange(2, 100)
    
    # Panel 1: Mass gap in different scaling regimes
    ax = axes[0, 0]
    # Scenario A: Δ_N ~ const (QCD-like)
    gap_A = np.ones_like(N_values, dtype=float) * 0.5
    # Scenario B: Δ_N ~ 1/N (large-N decay)
    gap_B = 1.0 / N_values
    # Scenario C: Δ_N ~ 1/N² (fast decay)
    gap_C = 1.0 / N_values**2
    # Scenario D: Δ_N ~ N^(-1/2) (sqrt decay)
    gap_D = 1.0 / np.sqrt(N_values)
    
    ax.loglog(N_values, gap_A, '-', label='Δ ~ const', linewidth=2)
    ax.loglog(N_values, gap_B, '-', label='Δ ~ 1/N', linewidth=2)
    ax.loglog(N_values, gap_C, '-', label='Δ ~ 1/N²', linewidth=2)
    ax.loglog(N_values, gap_D, '-', label='Δ ~ 1/√N', linewidth=2)
    ax.set_xlabel('N', fontsize=11)
    ax.set_ylabel('Δ_N', fontsize=11)
    ax.set_title('Mass Gap Scaling Scenarios', fontsize=12)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    
    # Panel 2: f(Δ_N)/N² for each scenario
    ax = axes[0, 1]
    for label, gap_vals, style in [
        ('Δ~const', gap_A, '-'),
        ('Δ~1/N', gap_B, '--'),
        ('Δ~1/N²', gap_C, '-.'),
        ('Δ~1/√N', gap_D, ':'),
    ]:
        ratio = gap_vals / N_values.astype(float)**2
        ax.plot(N_values, ratio, style, label=label, linewidth=2)
    
    ax.axhline(y=0, color='red', linewidth=1, linestyle='-')
    ax.set_xlabel('N', fontsize=11)
    ax.set_ylabel('f(Δ_N)/N² (with f=id)', fontsize=11)
    ax.set_title('Convergence to Λ=0', fontsize=12)
    ax.legend(fontsize=10)
    ax.set_ylim(-0.01, 0.3)
    ax.grid(True, alpha=0.3)
    
    # Panel 3: 't Hooft coupling λ = g²N phase space
    ax = axes[1, 0]
    g_sq = np.linspace(0.01, 5, 200)
    for N in [2, 3, 5, 10, 50]:
        lambda_thooft = g_sq * N
        # Approximate string tension σ ~ λ for large λ
        string_tension = lambda_thooft / (2 * np.pi)
        ax.plot(lambda_thooft, string_tension, label=f'N={N}', linewidth=1.5)
    
    ax.set_xlabel("λ = g²N ('t Hooft coupling)", fontsize=11)
    ax.set_ylabel('σ (String tension)', fontsize=11)
    ax.set_title("'t Hooft Coupling Phase Space", fontsize=12)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    
    # Panel 4: Confinement-deconfinement transition
    ax = axes[1, 1]
    T_range = np.linspace(0.1, 5, 200)
    for N in [2, 3, 5, 10]:
        # Simplified Polyakov loop model
        T_c = 1.0 + 0.1/N  # Critical temperature
        polyakov = np.where(T_range < T_c, 
                           0.01 * np.exp(-(T_c - T_range)**2),
                           1 - np.exp(-(T_range - T_c) * N))
        ax.plot(T_range, polyakov, label=f'N={N}', linewidth=1.5)
    
    ax.set_xlabel('T / Λ_QCD', fontsize=11)
    ax.set_ylabel('⟨|P|⟩ (Polyakov loop)', fontsize=11)
    ax.set_title('Deconfinement Transition', fontsize=12)
    ax.axvline(x=1.1, color='gray', linestyle='--', alpha=0.5, label='T_c')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig(os.path.join(output_dir, 'thooft_scaling.png'), dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved: thooft_scaling.png")


if __name__ == '__main__':
    output_dir = os.path.dirname(os.path.abspath(__file__))
    
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  de Bruijn-Newman / Yang-Mills Conjecture Explorer      ║")
    print("╚══════════════════════════════════════════════════════════╝")
    
    plot_debruijn_newman_landscape(output_dir)
    plot_thooft_scaling(output_dir)
    
    print("\n  All visualizations generated successfully!")

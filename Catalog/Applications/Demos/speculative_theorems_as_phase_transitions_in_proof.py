#!/usr/bin/env python3
"""
Phase Transitions in Proof Space — Demonstration Script

Demonstrates the key results from the formalized theory:
1. Phase transition characterization at n_c = k + 1
2. Exponential decay of coverage ratio
3. Entropy gap computation
4. Boltzmann distribution analogy
5. Compositional proof acceleration
"""

import math


def proof_bound(b: int, k: int) -> int:
    """Upper bound on number of proofs of length ≤ k with alphabet size b."""
    return b ** (k + 1)


def stmt_space(b: int, n: int) -> int:
    """Number of statements of length exactly n."""
    return b ** n


def critical_threshold(k: int) -> int:
    """The critical complexity threshold n_c = k + 1."""
    return k + 1


def coverage_ratio(b: int, k: int, n: int) -> float:
    """Ratio of proof space to statement space: b^(k+1) / b^n."""
    if n == 0:
        return float(proof_bound(b, k))
    return proof_bound(b, k) / stmt_space(b, n)


def entropy_gap(b: int, k: int, n: int) -> float:
    """Information-theoretic entropy gap: (n - k - 1) * log(b) nats."""
    return (n - k - 1) * math.log(b)


def boltzmann_density(beta: float, delta_e: float) -> float:
    """Boltzmann weight: exp(-β · ΔE)."""
    return math.exp(-beta * delta_e)


def hausdorff_dimension(k: int, n: int) -> float:
    """Proof space dimension: (k+1)/n."""
    if n == 0:
        return float('inf')
    return (k + 1) / n


def composite_threshold(k: int, m: int) -> int:
    """Critical threshold with m levels of composition."""
    return (k + 1) * m


# ─── Demonstration ──────────────────────────────────────────────────────

def demo_phase_transition():
    """Demonstrate the sharp phase transition."""
    print("=" * 70)
    print("DEMO 1: Sharp Phase Transition at n_c = k + 1")
    print("=" * 70)

    b, k = 2, 5
    n_c = critical_threshold(k)
    print(f"\nProof system: alphabet b={b}, max proof length k={k}")
    print(f"Critical threshold: n_c = {n_c}")
    print(f"Proof space bound: b^(k+1) = {proof_bound(b, k)}")
    print()

    print(f"{'n':>4} | {'Stmt Space':>12} | {'Proof Bound':>12} | {'Ratio':>10} | {'Phase':>10}")
    print("-" * 60)
    for n in range(1, 12):
        ss = stmt_space(b, n)
        pb = proof_bound(b, k)
        ratio = coverage_ratio(b, k, n)
        phase = "COMPLETE" if n <= n_c else "INCOMPLETE"
        print(f"{n:4d} | {ss:12d} | {pb:12d} | {ratio:10.4f} | {phase:>10}")

    print(f"\n✓ Sharp transition at n = {n_c}: ratio drops from "
          f"{coverage_ratio(b, k, n_c):.2f} to {coverage_ratio(b, k, n_c + 1):.4f}")


def demo_exponential_decay():
    """Demonstrate exponential decay of coverage."""
    print("\n" + "=" * 70)
    print("DEMO 2: Exponential Decay Beyond Critical Point")
    print("=" * 70)

    b, k = 10, 3
    n_c = critical_threshold(k)
    print(f"\nProof system: b={b}, k={k}, n_c={n_c}")
    print(f"Each step past n_c multiplies the gap by b={b}")
    print()

    print(f"{'m (steps past n_c)':>20} | {'n':>4} | {'Gap Factor b^m':>15} | {'Coverage Ratio':>15}")
    print("-" * 60)
    for m in range(0, 8):
        n = n_c + m
        ratio = coverage_ratio(b, k, n)
        gap = b ** m
        print(f"{m:20d} | {n:4d} | {gap:15d} | {ratio:15.2e}")

    print(f"\n✓ Coverage ratio decays by factor {b} per unit complexity")


def demo_entropy_gap():
    """Demonstrate the entropy gap."""
    print("\n" + "=" * 70)
    print("DEMO 3: Information-Theoretic Entropy Gap")
    print("=" * 70)

    b, k = 2, 10
    n_c = critical_threshold(k)
    print(f"\nProof system: b={b}, k={k}, n_c={n_c}")
    print()

    print(f"{'n':>4} | {'Entropy Gap (nats)':>20} | {'Entropy Gap (bits)':>20} | {'Phase'}")
    print("-" * 70)
    for n in range(8, 25):
        gap = entropy_gap(b, k, n)
        gap_bits = gap / math.log(2)
        phase = "COMPLETE" if n <= n_c else "INCOMPLETE"
        print(f"{n:4d} | {gap:20.3f} | {gap_bits:20.3f} | {phase}")

    print(f"\n✓ Entropy gap = 0 at n_c={n_c}, grows linearly with slope log({b})≈{math.log(b):.3f}")


def demo_boltzmann_bridge():
    """Demonstrate the Boltzmann distribution analogy."""
    print("\n" + "=" * 70)
    print("DEMO 4: Boltzmann Distribution Bridge")
    print("=" * 70)

    b, k = 2, 5
    n_c = critical_threshold(k)
    beta = math.log(b)

    print(f"\nProof system: b={b}, k={k}")
    print(f"Inverse temperature: β = log(b) = {beta:.4f}")
    print(f"Critical threshold (= critical temperature): n_c = {n_c}")
    print()

    print(f"{'ΔE = n - n_c':>12} | {'Proof Density':>14} | {'Boltzmann e^(-βΔE)':>18} | {'Match?'}")
    print("-" * 65)
    for delta_e in range(0, 10):
        n = n_c + delta_e
        proof_dens = coverage_ratio(b, k, n)
        boltz = boltzmann_density(beta, delta_e)
        match = "✓" if abs(proof_dens - boltz) < 1e-10 else "✗"
        print(f"{delta_e:12d} | {proof_dens:14.6f} | {boltz:18.6f} | {match:>6}")

    print(f"\n✓ Proof density = Boltzmann weight: EXACT MATCH for all ΔE")


def demo_composition():
    """Demonstrate compositional proof acceleration."""
    print("\n" + "=" * 70)
    print("DEMO 5: Compositional Proof Acceleration")
    print("=" * 70)

    b, k = 2, 3
    print(f"\nProof system: b={b}, k={k}")
    print(f"Base threshold: n_c = {critical_threshold(k)}")
    print()

    print(f"{'Composition Levels m':>22} | {'Effective Threshold':>20} | {'Acceleration Factor':>20}")
    print("-" * 65)
    for m in range(1, 8):
        thresh = composite_threshold(k, m)
        accel = proof_bound(b, k) ** m
        print(f"{m:22d} | {thresh:20d} | {accel:20d}")

    print(f"\n✓ Composition shifts threshold linearly but cannot eliminate transition")


def demo_dimension():
    """Demonstrate dimensional scaling."""
    print("\n" + "=" * 70)
    print("DEMO 6: Hausdorff Dimension of Provable Space")
    print("=" * 70)

    b, k = 2, 10
    n_c = critical_threshold(k)
    print(f"\nProof system: b={b}, k={k}, n_c={n_c}")
    print()

    print(f"{'n':>4} | {'Dimension d=(k+1)/n':>22} | {'d < 1?':>8} | {'Interpretation'}")
    print("-" * 65)
    for n in [5, 10, 11, 12, 15, 20, 50, 100, 1000]:
        d = hausdorff_dimension(k, n)
        subcrit = "Yes" if d < 1 else "No"
        if d >= 1:
            interp = "Full-dimensional (complete)"
        elif d >= 0.5:
            interp = "Dense fractal subset"
        elif d >= 0.1:
            interp = "Sparse fractal subset"
        else:
            interp = "Extremely sparse"
        print(f"{n:4d} | {d:22.4f} | {subcrit:>8} | {interp}")


if __name__ == "__main__":
    demo_phase_transition()
    demo_exponential_decay()
    demo_entropy_gap()
    demo_boltzmann_bridge()
    demo_composition()
    demo_dimension()

    print("\n" + "=" * 70)
    print("All demonstrations complete.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Visualization: Compositional Proof Acceleration

Shows how proof composition shifts the phase transition threshold
but cannot eliminate it.
"""

import math


def generate_composition_plot():
    """Generate plot of compositional acceleration."""
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    import numpy as np

    fig, axes = plt.subplots(1, 2, figsize=(14, 5))
    fig.suptitle('Compositional Proof Acceleration', fontsize=14, fontweight='bold')

    # Plot 1: Threshold shift with composition levels
    ax1 = axes[0]
    k_values = [2, 5, 10]
    m_values = np.arange(1, 11)
    for k in k_values:
        thresholds = [(k + 1) * m for m in m_values]
        ax1.plot(m_values, thresholds, 'o-', label=f'k={k}', linewidth=2, markersize=6)
    ax1.set_xlabel('Composition Levels m')
    ax1.set_ylabel('Critical Threshold n_c = (k+1)·m')
    ax1.set_title('Threshold Shifts Linearly')
    ax1.legend()
    ax1.grid(True, alpha=0.3)

    # Plot 2: Coverage ratio with composition
    ax2 = axes[1]
    b, k = 2, 3
    n_values = np.arange(1, 40)
    for m in [1, 2, 3, 5]:
        effective_bound = b ** ((k + 1) * m)
        ratios = [min(1.0, effective_bound / b**n) for n in n_values]
        n_c = (k + 1) * m
        ax2.plot(n_values, ratios, '-', label=f'm={m} (n_c={n_c})', linewidth=2)
        ax2.axvline(x=n_c, linestyle=':', alpha=0.3)
    ax2.set_xlabel('Statement Complexity n')
    ax2.set_ylabel('Coverage Ratio')
    ax2.set_title(f'Coverage with Composition (b={b}, k={k})')
    ax2.set_yscale('log')
    ax2.legend()
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('composition_plots.png', dpi=150, bbox_inches='tight')
    print("Saved: composition_plots.png")


if __name__ == "__main__":
    generate_composition_plot()


#!/usr/bin/env python3
"""
Visualization: Phase Transition in Proof Space

Generates a plot showing the sharp phase transition in proof density
as statement complexity crosses the critical threshold.
"""

import math


def generate_phase_transition_plot():
    """Generate SVG plot of the phase transition."""
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    import numpy as np

    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle('Phase Transitions in Proof Space', fontsize=16, fontweight='bold')

    # Plot 1: Coverage ratio vs complexity for different b
    ax1 = axes[0, 0]
    k = 5
    n_values = np.arange(1, 15)
    for b in [2, 3, 5, 10]:
        ratios = [min(1.0, b**(k+1) / b**n) for n in n_values]
        ax1.plot(n_values, ratios, 'o-', label=f'b={b}', markersize=4)
    ax1.axvline(x=k+1, color='red', linestyle='--', alpha=0.7, label=f'n_c = {k+1}')
    ax1.set_xlabel('Statement Complexity n')
    ax1.set_ylabel('Coverage Ratio ρ(n)')
    ax1.set_title(f'Sharp Phase Transition (k={k})')
    ax1.set_yscale('log')
    ax1.legend()
    ax1.grid(True, alpha=0.3)

    # Plot 2: Entropy gap
    ax2 = axes[0, 1]
    b = 2
    for k in [3, 5, 8, 12]:
        n_c = k + 1
        n_vals = np.arange(1, 25)
        gaps = [max(0, (n - k - 1) * math.log(b)) for n in n_vals]
        ax2.plot(n_vals, gaps, '-', label=f'k={k} (n_c={n_c})', linewidth=2)
    ax2.set_xlabel('Statement Complexity n')
    ax2.set_ylabel('Entropy Gap (nats)')
    ax2.set_title(f'Information-Theoretic Entropy Gap (b={b})')
    ax2.legend()
    ax2.grid(True, alpha=0.3)

    # Plot 3: Hausdorff dimension
    ax3 = axes[1, 0]
    for k in [3, 5, 10, 20]:
        n_vals = np.arange(1, 50)
        dims = [(k+1)/n for n in n_vals]
        ax3.plot(n_vals, dims, '-', label=f'k={k}', linewidth=2)
    ax3.axhline(y=1, color='red', linestyle='--', alpha=0.7, label='d=1 (full dimension)')
    ax3.set_xlabel('Statement Complexity n')
    ax3.set_ylabel('Proof Space Dimension d')
    ax3.set_title('Dimensional Scaling: d = (k+1)/n')
    ax3.set_ylim(0, 3)
    ax3.legend()
    ax3.grid(True, alpha=0.3)

    # Plot 4: Boltzmann comparison
    ax4 = axes[1, 1]
    k = 5
    b = 2
    beta = math.log(b)
    delta_e_vals = np.linspace(0, 10, 100)
    boltzmann_vals = [math.exp(-beta * de) for de in delta_e_vals]
    ax4.plot(delta_e_vals, boltzmann_vals, 'b-', linewidth=2, label='Boltzmann e^{-βΔE}')

    # Discrete proof density points
    for m in range(11):
        proof_dens = b**(k+1) / b**(k+1+m)
        ax4.plot(m, proof_dens, 'ro', markersize=8)
    ax4.plot([], [], 'ro', markersize=8, label='Proof density (discrete)')

    ax4.set_xlabel('Energy Gap ΔE = n - n_c')
    ax4.set_ylabel('Density / Weight')
    ax4.set_title(f'Boltzmann Bridge (b={b}, β={beta:.3f})')
    ax4.set_yscale('log')
    ax4.legend()
    ax4.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('phase_transition_plots.png', dpi=150, bbox_inches='tight')
    plt.savefig('phase_transition_plots.svg', bbox_inches='tight')
    print("Saved: phase_transition_plots.png, phase_transition_plots.svg")


if __name__ == "__main__":
    generate_phase_transition_plot()

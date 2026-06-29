"""
Proof Density Phase Transitions — Numerical Demonstrations

This script demonstrates the key results from the ProofDensitySpace theory:
1. Provability density phase transition
2. Gap amplification cascade
3. Proof dimension vs incompleteness
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def provability_density(b: int, proof_bound_fn, n: int) -> float:
    """Compute provability density ρ(n) = b^proofBound(n) / b^n."""
    pb = proof_bound_fn(n)
    if n == 0:
        return 1.0
    return b ** pb / b ** n


def unprovability_gap(b: int, proof_bound_fn, n: int) -> int:
    """Compute the gap: b^n - b^proofBound(n)."""
    pb = proof_bound_fn(n)
    return max(0, b ** n - b ** pb)


def demo_phase_transition():
    """Demonstrate the phase transition in provability density."""
    print("=" * 60)
    print("DEMO 1: Provability Density Phase Transition")
    print("=" * 60)

    b = 2  # binary alphabet

    # Scenario: proofBound(n) = n for n ≤ 5, then proofBound(n) = 5 + log(n-5)
    # This models a system where short proofs cover short statements
    # but can't keep up with longer ones.
    nc = 5  # completeness threshold

    def proof_bound(n):
        if n <= nc:
            return n  # complete regime
        return nc + int(np.log2(max(1, n - nc)))  # sublinear growth

    print(f"\nAlphabet size b = {b}, Completeness threshold n_c = {nc}")
    print(f"\n{'n':>4} {'stmtCount':>12} {'provBound':>10} {'maxProvable':>12} {'density':>10} {'gap':>12}")
    print("-" * 65)

    for n in range(1, 21):
        stmt_count = b ** n
        pb = proof_bound(n)
        max_provable = b ** pb
        density = provability_density(b, proof_bound, n)
        gap = unprovability_gap(b, proof_bound, n)
        marker = " <-- TRANSITION" if n == nc + 1 else ""
        print(f"{n:>4} {stmt_count:>12} {pb:>10} {max_provable:>12} {density:>10.6f} {gap:>12}{marker}")


def demo_gap_amplification():
    """Demonstrate exponential gap amplification."""
    print("\n" + "=" * 60)
    print("DEMO 2: Gap Amplification Cascade")
    print("=" * 60)

    b = 2
    n_start = 6  # first incomplete level
    initial_gap = 1  # one unprovable statement

    print(f"\nStarting with gap = {initial_gap} at n = {n_start}")
    print(f"Under gap amplification (factor b = {b} per level):\n")

    gap = initial_gap
    for k in range(15):
        n = n_start + k
        print(f"  n = {n:>3}: gap ≥ {b}^{k} = {b**k:>10} unprovable statements")
        gap *= b

    print(f"\n  After {15} levels: at least {b**14:,} unprovable statements!")
    print("  → Incompleteness cascades exponentially")


def demo_proof_dimension():
    """Demonstrate proof dimension and its connection to incompleteness."""
    print("\n" + "=" * 60)
    print("DEMO 3: Proof Dimension Theory")
    print("=" * 60)

    b = 2

    scenarios = [
        ("Complete system", lambda n: n, "d = 1.0"),
        ("Linear proofs (slope 0.9)", lambda n: int(0.9 * n), "d = 0.9"),
        ("Linear proofs (slope 0.5)", lambda n: n // 2, "d = 0.5"),
        ("Logarithmic proofs", lambda n: max(1, int(3 * np.log2(max(1, n)))), "d → 0"),
        ("Constant proofs", lambda n: 10, "d → 0"),
    ]

    for name, pbound, expected_dim in scenarios:
        print(f"\n  {name} (proofBound(n) ≈ ..., expected {expected_dim}):")
        dims = []
        for n in [10, 50, 100, 500, 1000]:
            pb = pbound(n)
            dim = pb / n if n > 0 else 1.0
            dims.append(dim)
            incomplete = "INCOMPLETE" if pb < n else "complete"
            print(f"    n={n:>4}: proofBound={pb:>4}, dim={dim:.4f} [{incomplete}]")


def demo_critical_density_plot():
    """Generate a plot showing the phase transition."""
    b = 2
    nc = 8

    def proof_bound(n):
        if n <= nc:
            return n
        return nc + int(np.sqrt(max(0, n - nc)))

    ns = list(range(1, 31))
    densities = [provability_density(b, proof_bound, n) for n in ns]
    dimensions = [proof_bound(n) / n if n > 0 else 1.0 for n in ns]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Plot 1: Provability density
    ax1.plot(ns, densities, 'b-o', markersize=4, linewidth=2)
    ax1.axvline(x=nc, color='r', linestyle='--', alpha=0.7, label=f'n_c = {nc}')
    ax1.set_xlabel('Statement Length n', fontsize=12)
    ax1.set_ylabel('Provability Density ρ(n)', fontsize=12)
    ax1.set_title('Phase Transition in Provability Density', fontsize=14)
    ax1.set_yscale('log')
    ax1.legend(fontsize=11)
    ax1.grid(True, alpha=0.3)
    ax1.set_ylim(bottom=1e-8)

    # Plot 2: Proof dimension
    ax2.plot(ns, dimensions, 'g-s', markersize=4, linewidth=2)
    ax2.axhline(y=1, color='gray', linestyle=':', alpha=0.5, label='d = 1 (complete)')
    ax2.axvline(x=nc, color='r', linestyle='--', alpha=0.7, label=f'n_c = {nc}')
    ax2.set_xlabel('Statement Length n', fontsize=12)
    ax2.set_ylabel('Proof Dimension d(n)', fontsize=12)
    ax2.set_title('Proof Dimension vs Statement Length', fontsize=14)
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('phase_transition_plot.png', dpi=150, bbox_inches='tight')
    print("\nPlot saved to phase_transition_plot.png")


if __name__ == "__main__":
    demo_phase_transition()
    demo_gap_amplification()
    demo_proof_dimension()
    demo_critical_density_plot()

    print("\n" + "=" * 60)
    print("KEY INSIGHTS FROM FORMAL PROOFS")
    print("=" * 60)
    print("""
1. COUNTING INCOMPLETENESS: In any formal system with alphabet b,
   if b^(proofBound(n)) < stmtCount(n), then unprovable statements
   MUST exist at length n. This is a purely combinatorial fact.

2. PHASE TRANSITION: At the completeness threshold n_c, the
   provability density ρ(n) drops from 1 to strictly below 1.
   This is a sharp, discontinuous transition — not gradual.

3. GAP AMPLIFICATION: A single unprovable statement at length n
   forces b^k unprovable statements at length n+k (under natural
   growth conditions). Incompleteness is self-amplifying.

4. PROOF DIMENSION: The "proof dimension" d = lim proofBound(n)/n
   characterizes the system. d < 1 ⟹ incomplete at all large scales.
""")


"""
Visualization: Phase Transition in Provability Density

Generates a comprehensive plot showing the sharp phase transition
in provability density at the Gödel threshold, along with the
exponential gap amplification.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec


def compute_density(b, proof_bound_fn, n):
    if n == 0:
        return 1.0
    pb = proof_bound_fn(n)
    return min(1.0, b ** pb / b ** n)


def compute_gap(b, proof_bound_fn, n):
    pb = proof_bound_fn(n)
    return max(0, b ** n - b ** pb)


def compute_dimension(proof_bound_fn, n):
    if n == 0:
        return 1.0
    return proof_bound_fn(n) / n


def main():
    b = 2
    nc = 8

    def proof_bound_linear(n):
        if n <= nc:
            return n
        return nc + (n - nc) // 3

    def proof_bound_sqrt(n):
        if n <= nc:
            return n
        return nc + int(np.sqrt(max(0, n - nc)))

    def proof_bound_log(n):
        if n <= nc:
            return n
        return nc + int(2 * np.log2(max(1, n - nc)))

    ns = np.arange(1, 35)

    fig = plt.figure(figsize=(16, 12))
    gs = GridSpec(2, 2, figure=fig, hspace=0.3, wspace=0.3)

    # Plot 1: Phase transition in density
    ax1 = fig.add_subplot(gs[0, 0])
    for pf, label, color in [(proof_bound_linear, 'Linear (slope 1/3)', 'blue'),
                              (proof_bound_sqrt, 'Square root', 'green'),
                              (proof_bound_log, 'Logarithmic', 'red')]:
        densities = [compute_density(b, pf, int(n)) for n in ns]
        ax1.semilogy(ns, densities, '-o', color=color, label=label, markersize=3, linewidth=1.5)

    ax1.axvline(x=nc, color='gray', linestyle='--', alpha=0.7, label=f'n_c = {nc}')
    ax1.set_xlabel('Statement Length n', fontsize=11)
    ax1.set_ylabel('Provability Density ρ(n)', fontsize=11)
    ax1.set_title('Phase Transition in Provability Density', fontsize=13, fontweight='bold')
    ax1.legend(fontsize=9)
    ax1.grid(True, alpha=0.3)
    ax1.set_ylim(bottom=1e-10)

    # Plot 2: Gap amplification
    ax2 = fig.add_subplot(gs[0, 1])
    for pf, label, color in [(proof_bound_linear, 'Linear', 'blue'),
                              (proof_bound_sqrt, 'Sqrt', 'green'),
                              (proof_bound_log, 'Log', 'red')]:
        gaps = [compute_gap(b, pf, int(n)) for n in ns]
        gaps_positive = [max(g, 0.5) for g in gaps]
        ax2.semilogy(ns, gaps_positive, '-s', color=color, label=label, markersize=3, linewidth=1.5)

    ax2.axvline(x=nc, color='gray', linestyle='--', alpha=0.7)
    ax2.set_xlabel('Statement Length n', fontsize=11)
    ax2.set_ylabel('Unprovability Gap G(n)', fontsize=11)
    ax2.set_title('Gap Amplification Cascade', fontsize=13, fontweight='bold')
    ax2.legend(fontsize=9)
    ax2.grid(True, alpha=0.3)

    # Plot 3: Proof dimension
    ax3 = fig.add_subplot(gs[1, 0])
    for pf, label, color in [(proof_bound_linear, 'Linear', 'blue'),
                              (proof_bound_sqrt, 'Sqrt', 'green'),
                              (proof_bound_log, 'Log', 'red')]:
        dims = [compute_dimension(pf, int(n)) for n in ns]
        ax3.plot(ns, dims, '-^', color=color, label=label, markersize=3, linewidth=1.5)

    ax3.axhline(y=1, color='gray', linestyle=':', alpha=0.5, label='d = 1 (complete)')
    ax3.axvline(x=nc, color='gray', linestyle='--', alpha=0.7)
    ax3.fill_between(ns, 0, 1, alpha=0.05, color='red', label='Incomplete region (d < 1)')
    ax3.set_xlabel('Statement Length n', fontsize=11)
    ax3.set_ylabel('Proof Dimension d(n)', fontsize=11)
    ax3.set_title('Proof Dimension vs Length', fontsize=13, fontweight='bold')
    ax3.legend(fontsize=9, loc='upper right')
    ax3.grid(True, alpha=0.3)
    ax3.set_ylim(-0.05, 1.15)

    # Plot 4: Provability ratio comparison
    ax4 = fig.add_subplot(gs[1, 1])
    for pf, label, color in [(proof_bound_linear, 'Linear', 'blue'),
                              (proof_bound_sqrt, 'Sqrt', 'green'),
                              (proof_bound_log, 'Log', 'red')]:
        ratios = [min(1.0, b ** pf(int(n)) / b ** int(n)) for n in ns]
        ax4.semilogy(ns, ratios, '-d', color=color, label=label, markersize=3, linewidth=1.5)

    ax4.axvline(x=nc, color='gray', linestyle='--', alpha=0.7)
    ax4.set_xlabel('Statement Length n', fontsize=11)
    ax4.set_ylabel('Provability Ratio r(n) = P(n)/b^n', fontsize=11)
    ax4.set_title('Provability Ratio Decay', fontsize=13, fontweight='bold')
    ax4.legend(fontsize=9)
    ax4.grid(True, alpha=0.3)
    ax4.set_ylim(bottom=1e-10)

    fig.suptitle('Proof Density Space: Phase Transitions in Provability',
                 fontsize=15, fontweight='bold', y=0.98)

    plt.savefig('phase_transition_comprehensive.png', dpi=150, bbox_inches='tight')
    print("Saved: phase_transition_comprehensive.png")


if __name__ == "__main__":
    main()

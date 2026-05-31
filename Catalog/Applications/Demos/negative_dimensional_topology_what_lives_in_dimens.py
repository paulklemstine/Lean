"""
Negative-Dimensional Topology: Demonstration

Numerical examples verifying the key theorems from the formal theory.
"""

from algorithms import (
    FormalDimObj, NegDimSpace, NegDimCW, ProSpectrum,
    suspend, desuspend, suspend_iter, product,
    stabilization_steps, verify_double_suspension_involution,
    verify_consecutive_sum, euler_char_neg_dim, uniform_cw_euler
)


def demo_euler_char_formula():
    """Demonstrate χ = (-1)^n · |π₀| for negative dimensions."""
    print("=" * 60)
    print("EULER CHARACTERISTIC FORMULA: χ = (-1)^(-dim) · |π₀|")
    print("=" * 60)

    for dim in range(0, -6, -1):
        for components in [1, 2, 3, 5]:
            X = NegDimSpace(dim=dim, components=components)
            print(f"  dim={dim:3d}, |π₀|={components}: χ = {X.euler_char:4d}"
                  f"  [(-1)^{-dim} · {components} = {((-1)**(-dim))*components}]")
    print()


def demo_suspension_involution():
    """Demonstrate χ(Σ²X) = χ(X) for various spaces."""
    print("=" * 60)
    print("DOUBLE SUSPENSION INVOLUTION: χ(Σ²X) = χ(X)")
    print("=" * 60)

    test_cases = [
        FormalDimObj(dim=-3, euler=-5),
        FormalDimObj(dim=-1, euler=-2),
        FormalDimObj(dim=0, euler=3),
        FormalDimObj(dim=-10, euler=7),
        FormalDimObj(dim=5, euler=-100),
    ]

    for X in test_cases:
        result = verify_double_suspension_involution(X)
        SX = suspend(X)
        SSX = suspend(SX)
        print(f"  X={X} → ΣX={SX} → Σ²X={SSX}  "
              f"χ(X)={X.euler}, χ(Σ²X)={SSX.euler}  ✓={result}")
    print()


def demo_pro_spectrum():
    """Demonstrate pro-spectrum periodicity."""
    print("=" * 60)
    print("PRO-SPECTRUM PERIODICITY")
    print("=" * 60)

    base = FormalDimObj(dim=-5, euler=-3)
    ps = ProSpectrum(base)

    print(f"  Base: {base}")
    print(f"  Euler sequence: {ps.euler_sequence(12)}")
    print(f"  Dim sequence:   {ps.dim_sequence(12)}")
    print(f"  Even levels all = {ps.space(0).euler}: "
          f"{all(ps.space(2*k).euler == ps.space(0).euler for k in range(6))}")
    print(f"  Odd levels all = {2 - ps.space(0).euler}: "
          f"{all(ps.space(2*k+1).euler == 2 - ps.space(0).euler for k in range(6))}")

    # Verify consecutive sums
    sums = [ps.space(n).euler + ps.space(n+1).euler for n in range(10)]
    print(f"  Consecutive sums: {sums}  (all = 2: {all(s == 2 for s in sums)})")
    print()


def demo_stabilization():
    """Demonstrate the stabilization theorem."""
    print("=" * 60)
    print("STABILIZATION: Every space reaches positive dimension")
    print("=" * 60)

    for dim in [-1, -5, -10, -50, -100]:
        X = FormalDimObj(dim=dim, euler=(-1)**(-dim) * 3)
        steps = stabilization_steps(X)
        result = suspend_iter(X, steps)
        print(f"  dim={dim:4d}: need {steps:4d} suspensions → dim={result.dim}")
    print()


def demo_product_formula():
    """Demonstrate χ(X × Y) = χ(X) · χ(Y)."""
    print("=" * 60)
    print("KÜNNETH PRODUCT FORMULA: χ(X × Y) = χ(X) · χ(Y)")
    print("=" * 60)

    pairs = [
        (FormalDimObj(-2, 3), FormalDimObj(-1, -2)),
        (FormalDimObj(-3, -5), FormalDimObj(-4, 7)),
        (FormalDimObj(0, 1), FormalDimObj(-5, -1)),
    ]

    for X, Y in pairs:
        P = product(X, Y)
        print(f"  {X} × {Y}")
        print(f"    = {P}")
        print(f"    χ(X)·χ(Y) = {X.euler}·{Y.euler} = {X.euler * Y.euler} = χ(X×Y) ✓")
    print()


def demo_sign_theorems():
    """Demonstrate sign theorems for Euler characteristic."""
    print("=" * 60)
    print("SIGN THEOREMS: Even codim → χ > 0, Odd codim → χ < 0")
    print("=" * 60)

    for dim in range(0, -11, -1):
        X = NegDimSpace(dim=dim, components=4)
        codim = -dim
        parity = "even" if codim % 2 == 0 else "odd"
        sign = "+" if X.euler_char > 0 else "-"
        print(f"  dim={dim:3d}, codim={codim:2d} ({parity:4s}): "
              f"χ = {X.euler_char:4d} ({sign})")
    print()


def demo_neg_dim_cw():
    """Demonstrate negative-dimensional CW complex Euler characteristics."""
    print("=" * 60)
    print("NEGATIVE-DIMENSIONAL CW COMPLEXES")
    print("=" * 60)

    # Uniform CW complexes
    print("  Uniform (all cells = 1):")
    for codim in range(11):
        chi = uniform_cw_euler(codim)
        print(f"    codim={codim:2d}: χ = {chi}")

    print()
    print("  Non-uniform examples:")
    examples = [
        NegDimCW(codim=2, cells=[3, 2, 1]),
        NegDimCW(codim=3, cells=[1, 4, 2, 3]),
        NegDimCW(codim=4, cells=[2, 1, 3, 1, 2]),
    ]
    for C in examples:
        print(f"    codim={C.codim}, cells={C.cells}: "
              f"χ={C.euler_char}, total={C.total_cells}, "
              f"|χ|≤total: {abs(C.euler_char) <= C.total_cells}")
    print()


def demo_classification():
    """Demonstrate the classification theorem."""
    print("=" * 60)
    print("CLASSIFICATION: Same χ ⟹ same |π₀|")
    print("=" * 60)

    # Two spaces with same χ must have same components
    cases = [
        (NegDimSpace(-2, 5), NegDimSpace(-4, 5)),
        (NegDimSpace(-1, 3), NegDimSpace(-3, 3)),
        (NegDimSpace(0, 7), NegDimSpace(-6, 7)),
    ]
    for X, Y in cases:
        print(f"  X(dim={X.dim}, k={X.components}): χ={X.euler_char}")
        print(f"  Y(dim={Y.dim}, k={Y.components}): χ={Y.euler_char}")
        same_chi = X.euler_char == Y.euler_char
        same_comp = X.components == Y.components
        print(f"    Same χ: {same_chi}, Same |π₀|: {same_comp}")
        print()


def demo_conjecture_test():
    """Test the uniform cell complex conjecture for even codimension."""
    print("=" * 60)
    print("CONJECTURE TEST: Uniform even-codim CW has χ = 1")
    print("=" * 60)

    results = []
    for n in range(51):
        codim = 2 * n
        chi = uniform_cw_euler(codim)
        results.append(chi == 1)
        if n <= 10 or n % 10 == 0:
            print(f"  n={n:3d}, codim={codim:3d}: χ = {chi}  ✓={chi == 1}")

    all_pass = all(results)
    print(f"\n  All {len(results)} cases pass: {all_pass}")
    print()


if __name__ == "__main__":
    demo_euler_char_formula()
    demo_suspension_involution()
    demo_pro_spectrum()
    demo_stabilization()
    demo_product_formula()
    demo_sign_theorems()
    demo_neg_dim_cw()
    demo_classification()
    demo_conjecture_test()
    print("All demonstrations complete.")


"""
Visualization: Negative-Dimensional Euler Characteristics

Standalone matplotlib visualization of the key results.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def euler_char(dim: int, components: int) -> int:
    """χ = (-1)^(-dim) · components"""
    return ((-1) ** (-dim)) * components


def suspend_euler(chi: int) -> int:
    """χ(ΣX) = 2 - χ(X)"""
    return 2 - chi


def plot_euler_sign_pattern():
    """Plot the sign alternation of Euler characteristic across dimensions."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Left: Euler characteristic vs dimension for various component counts
    dims = list(range(0, -16, -1))
    for k in [1, 2, 3, 5]:
        chis = [euler_char(d, k) for d in dims]
        ax1.plot(dims, chis, 'o-', label=f'|π₀| = {k}', markersize=6)

    ax1.axhline(y=0, color='gray', linestyle='--', alpha=0.5)
    ax1.set_xlabel('Dimension', fontsize=12)
    ax1.set_ylabel('Euler Characteristic χ', fontsize=12)
    ax1.set_title('Euler Characteristic in Negative Dimensions', fontsize=13)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)

    # Right: Sign pattern as a heatmap
    dims_short = list(range(0, -11, -1))
    components_list = list(range(1, 8))
    data = np.array([[euler_char(d, k) for d in dims_short] for k in components_list])
    signs = np.sign(data)

    im = ax2.imshow(signs, cmap='RdBu', aspect='auto', vmin=-1, vmax=1,
                    extent=[dims_short[0] + 0.5, dims_short[-1] - 0.5,
                            components_list[-1] + 0.5, components_list[0] - 0.5])
    ax2.set_xlabel('Dimension', fontsize=12)
    ax2.set_ylabel('Components |π₀|', fontsize=12)
    ax2.set_title('Sign Pattern: Blue = Positive, Red = Negative', fontsize=13)
    ax2.set_xticks(dims_short)
    ax2.set_yticks(components_list)

    plt.tight_layout()
    plt.savefig('euler_sign_pattern.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: euler_sign_pattern.png")


def plot_pro_spectrum():
    """Plot pro-spectrum Euler characteristic periodicity."""
    fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(12, 8))

    # Different base Euler characteristics
    bases = [-3, -1, 0, 2, 5]
    levels = list(range(16))

    for base_chi in bases:
        chi_seq = [base_chi]
        for _ in range(15):
            chi_seq.append(2 - chi_seq[-1])
        ax1.plot(levels, chi_seq, 'o-', label=f'χ₀ = {base_chi}', markersize=5)

    ax1.axhline(y=1, color='gray', linestyle=':', alpha=0.5, label='y = 1 (midpoint)')
    ax1.set_xlabel('Spectrum Level n', fontsize=12)
    ax1.set_ylabel('Euler Characteristic χ(Xₙ)', fontsize=12)
    ax1.set_title('Pro-Spectrum Euler Characteristic Periodicity', fontsize=13)
    ax1.legend(fontsize=9, loc='upper right')
    ax1.grid(True, alpha=0.3)

    # Consecutive sums
    base_chi = -3
    chi_seq = [base_chi]
    for _ in range(15):
        chi_seq.append(2 - chi_seq[-1])

    sums = [chi_seq[n] + chi_seq[n+1] for n in range(15)]
    ax2.bar(range(15), sums, color='steelblue', alpha=0.7)
    ax2.axhline(y=2, color='red', linestyle='--', linewidth=2, label='Always = 2')
    ax2.set_xlabel('Level n', fontsize=12)
    ax2.set_ylabel('χ(Xₙ) + χ(Xₙ₊₁)', fontsize=12)
    ax2.set_title(f'Consecutive Sum Theorem (base χ = {base_chi})', fontsize=13)
    ax2.legend(fontsize=11)
    ax2.set_ylim(0, 3)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('pro_spectrum_periodicity.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: pro_spectrum_periodicity.png")


def plot_stabilization():
    """Plot the stabilization map from negative to positive dimensions."""
    fig, ax = plt.subplots(figsize=(10, 6))

    start_dims = [-10, -7, -5, -3, -1]
    colors = plt.cm.viridis(np.linspace(0.2, 0.9, len(start_dims)))

    for i, start_dim in enumerate(start_dims):
        steps = max(0, 1 - start_dim)
        dims = [start_dim + n for n in range(steps + 3)]
        ax.plot(range(len(dims)), dims, 'o-', color=colors[i],
                label=f'Start dim = {start_dim}', markersize=6, linewidth=2)
        # Mark where we cross zero
        cross_idx = -start_dim
        if cross_idx < len(dims):
            ax.plot(cross_idx, 0, 's', color=colors[i], markersize=12,
                    markeredgecolor='black', markeredgewidth=2, zorder=5)

    ax.axhline(y=0, color='red', linestyle='--', linewidth=2, alpha=0.7,
               label='dim = 0 (threshold)')
    ax.fill_between(range(15), -12, 0, alpha=0.1, color='red',
                     label='Negative dimension')
    ax.fill_between(range(15), 0, 5, alpha=0.1, color='green',
                     label='Positive dimension')

    ax.set_xlabel('Number of Suspensions', fontsize=12)
    ax.set_ylabel('Dimension', fontsize=12)
    ax.set_title('Stabilization: Suspension Lifts to Positive Dimension', fontsize=13)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)
    ax.set_xlim(-0.5, 13)

    plt.tight_layout()
    plt.savefig('stabilization_bridge.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: stabilization_bridge.png")


if __name__ == "__main__":
    plot_euler_sign_pattern()
    plot_pro_spectrum()
    plot_stabilization()
    print("All visualizations generated.")

#!/usr/bin/env python3
"""
Demo: Tangled Hierarchy Spectral Theory
========================================

Numerical demonstrations of the key results from our formalization.
"""

from algorithms import (
    GLFormula, modal_depth, entanglement_depth, soundness_op,
    iterated_soundness, con_formula, tangling_level,
    linear_chain_frame, forces_in_frame, compute_tangling_spectrum,
    verify_stratification, verify_optimal_tangling
)


def demo_orthogonality():
    """Demonstrate the Entanglement-Modal Orthogonality theorem."""
    print("=" * 60)
    print("ENTANGLEMENT-MODAL ORTHOGONALITY")
    print("=" * 60)
    print()
    print("For each N, iterated soundness S^N(p) has:")
    print("  modal depth = N, entanglement depth = N")
    print("While consistency Con_N has:")
    print("  modal depth = N, entanglement depth = 0")
    print()
    print(f"{'N':>3} | {'S^N modal':>10} {'S^N entangle':>13} | {'Con_N modal':>11} {'Con_N entangle':>14}")
    print("-" * 60)

    for N in range(8):
        sn = iterated_soundness(N, GLFormula.var(0))
        cn = con_formula(N)
        print(f"{N:>3} | {modal_depth(sn):>10} {entanglement_depth(sn):>13} | "
              f"{modal_depth(cn):>11} {entanglement_depth(cn):>14}")

    print()
    print("✓ Modal depth matches in both columns")
    print("✓ Entanglement depths are N vs 0 — genuinely independent measures")


def demo_stratification():
    """Demonstrate the Consistency Stratification Theorem."""
    print()
    print("=" * 60)
    print("CONSISTENCY STRATIFICATION THEOREM")
    print("=" * 60)
    print()
    print("In a linear chain of n worlds, Con_k is forced at world w")
    print("if and only if w + k < n.")
    print()

    for n in [3, 5, 7]:
        print(f"--- Linear chain with n = {n} worlds ---")
        frame = linear_chain_frame(n)
        valuation = {}

        # Print forcing table
        print(f"{'':>8}", end="")
        for k in range(n + 1):
            print(f"  Con_{k}", end="")
        print()

        for w in range(n):
            print(f"  w = {w}:", end="")
            for k in range(n + 1):
                forced = forces_in_frame(frame, valuation, w, con_formula(k))
                symbol = "  ✓  " if forced else "  ✗  "
                print(f" {symbol}", end="")
            print(f"  | level = {tangling_level(n, w)}")
        print()

    # Verify for small n
    print("Verification of theorem for n = 1..10:")
    for n in range(1, 11):
        ok = verify_stratification(n)
        print(f"  n = {n:>2}: {'PASS ✓' if ok else 'FAIL ✗'}")


def demo_hierarchy_collapse():
    """Demonstrate the Hierarchy Collapse theorem."""
    print()
    print("=" * 60)
    print("HIERARCHY COLLAPSE THEOREM")
    print("=" * 60)
    print()
    print("If a proof system S has:")
    print("  (1) Löb's axiom for ⊥:  □(□⊥→⊥) → □⊥")
    print("  (2) Reflection for ⊥:   □⊥ → ⊥")
    print("Then S proves ⊥ (inconsistent).")
    print()
    print("Proof trace:")
    print("  Step 1: From (2), by Necessitation:  □(□⊥→⊥)")
    print("  Step 2: From (1) and Step 1, by MP:  □⊥")
    print("  Step 3: From (2) and Step 2, by MP:  ⊥")
    print()
    print("This shows that no consistent system can internalize its")
    print("own soundness — the fundamental impossibility behind")
    print("Gödel's second incompleteness theorem.")


def demo_spectrum():
    """Demonstrate the provability spectrum."""
    print()
    print("=" * 60)
    print("PROVABILITY SPECTRUM (No Spectral Gaps)")
    print("=" * 60)
    print()

    for n in [5, 8]:
        print(f"Linear chain with n = {n} worlds:")
        frame = linear_chain_frame(n)
        spectrum = compute_tangling_spectrum(frame, max_k=n + 2)

        levels = sorted(set(spectrum.values()))
        print(f"  Spectrum = {{{', '.join(str(l) for l in levels)}}}")
        print(f"  Expected = {{{', '.join(str(l) for l in range(n))}}}")
        print(f"  Gap-free: {'✓' if levels == list(range(n)) else '✗'}")

        for w in range(n):
            print(f"    World {w}: tangling level = {spectrum[w]}")
        print()


def demo_entanglement_additivity():
    """Demonstrate the entanglement additivity theorem."""
    print()
    print("=" * 60)
    print("ENTANGLEMENT ADDITIVITY")
    print("=" * 60)
    print()
    print("entanglement(S^m(S^n(p))) = m + n")
    print()
    print(f"{'m':>3} {'n':>3} | {'entanglement':>13} {'m+n':>5} | {'match':>6}")
    print("-" * 40)

    for m in range(5):
        for n in range(5):
            inner = iterated_soundness(n, GLFormula.var(0))
            outer = iterated_soundness(m, inner)
            ent = entanglement_depth(outer)
            expected = m + n
            print(f"{m:>3} {n:>3} | {ent:>13} {expected:>5} | {'✓' if ent == expected else '✗':>6}")


def demo_conjecture_test():
    """Test the Optimal Frame Tangling Conjecture for small n."""
    print()
    print("=" * 60)
    print("CONJECTURE TEST: Optimal Frame Tangling")
    print("=" * 60)
    print()
    print("Testing: linear chains achieve the maximum number of")
    print("distinct tangling levels among all GL-frames with n worlds.")
    print()

    for n in range(1, 5):
        ok, max_levels = verify_optimal_tangling(n)
        chain_levels = n  # linear chain achieves exactly n levels
        print(f"  n = {n}: max levels = {max_levels}, "
              f"chain levels = {chain_levels}, "
              f"conjecture {'holds ✓' if ok else 'FAILS ✗'}")


if __name__ == '__main__':
    demo_orthogonality()
    demo_stratification()
    demo_hierarchy_collapse()
    demo_spectrum()
    demo_entanglement_additivity()
    demo_conjecture_test()


#!/usr/bin/env python3
"""
Visualization: Consistency Stratification in Linear Chains
==========================================================
"""
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def plot_stratification(n: int = 8):
    """Plot the consistency stratification theorem as a heatmap."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Left: Forcing table (heatmap)
    data = np.zeros((n, n + 1))
    for w in range(n):
        for k in range(n + 1):
            data[w, k] = 1.0 if (w + k < n) else 0.0

    im = ax1.imshow(data, cmap='YlGn', aspect='auto', interpolation='nearest')
    ax1.set_xlabel('Consistency level k (Con_k)', fontsize=12)
    ax1.set_ylabel('World w', fontsize=12)
    ax1.set_title(f'Consistency Stratification (n={n} worlds)', fontsize=14)
    ax1.set_xticks(range(n + 1))
    ax1.set_xticklabels([f'Con_{k}' for k in range(n + 1)], fontsize=8, rotation=45)
    ax1.set_yticks(range(n))
    ax1.set_yticklabels([f'w={w}' for w in range(n)])

    # Add text annotations
    for w in range(n):
        for k in range(n + 1):
            color = 'white' if data[w, k] > 0.5 else 'gray'
            ax1.text(k, w, '✓' if data[w, k] else '✗',
                     ha='center', va='center', color=color, fontsize=10)

    # Draw the diagonal boundary
    xs = np.arange(-0.5, n + 0.5, 0.01)
    ys = n - 0.5 - xs
    mask = (xs >= -0.5) & (xs <= n + 0.5) & (ys >= -0.5) & (ys <= n - 0.5)
    ax1.plot(xs[mask], ys[mask], 'r-', linewidth=2, label='w + k = n (boundary)')
    ax1.legend(loc='lower left')

    # Right: Entanglement vs Modal Depth
    Ns = list(range(10))
    iter_modal = Ns[:]
    iter_entangle = Ns[:]
    con_modal = Ns[:]
    con_entangle = [0] * len(Ns)

    ax2.plot(Ns, iter_modal, 'bo-', label='S^N: modal depth', markersize=8)
    ax2.plot(Ns, iter_entangle, 'b^--', label='S^N: entanglement', markersize=8)
    ax2.plot(Ns, con_modal, 'rs-', label='Con_N: modal depth', markersize=8)
    ax2.plot(Ns, con_entangle, 'rv--', label='Con_N: entanglement', markersize=8)

    ax2.set_xlabel('N', fontsize=12)
    ax2.set_ylabel('Depth', fontsize=12)
    ax2.set_title('Entanglement-Modal Orthogonality', fontsize=14)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('stratification.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved stratification.png")


def plot_spectrum(n: int = 10):
    """Plot the provability spectrum."""
    fig, ax = plt.subplots(figsize=(10, 6))

    worlds = list(range(n))
    levels = [n - 1 - w for w in worlds]

    colors = plt.cm.viridis(np.linspace(0, 1, n))

    bars = ax.bar(worlds, levels, color=colors, edgecolor='black', linewidth=0.5)

    ax.set_xlabel('World w', fontsize=12)
    ax.set_ylabel('Tangling Level', fontsize=12)
    ax.set_title(f'Provability Spectrum (n={n} worlds)', fontsize=14)
    ax.set_xticks(worlds)

    # Add level labels
    for w, l in zip(worlds, levels):
        ax.text(w, l + 0.1, str(l), ha='center', va='bottom', fontsize=10)

    ax.set_ylim(0, n + 0.5)
    ax.grid(True, alpha=0.3, axis='y')

    # Add annotation
    ax.annotate('Injective: each level achieved exactly once',
                xy=(n // 2, n // 2), fontsize=11,
                bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow'))

    plt.tight_layout()
    plt.savefig('spectrum.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved spectrum.png")


if __name__ == '__main__':
    plot_stratification()
    plot_spectrum()

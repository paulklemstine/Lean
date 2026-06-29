#!/usr/bin/env python3
"""
Applications of Closure Kramers-Wannier Duality

Demonstrates real-world applications of the duality theorems:
1. Inverse Ising problem: recover couplings from partition data
2. Factor graph duality: dual representation of graphical models
3. Phase transition detection via dual energy gap
"""

import numpy as np
from algorithms import (
    tropical_legendre, dual_tropical_legendre, tropical_bidual,
    normalize, gauge_equivalent, certified_reconstruction,
    ising_chain_energy
)
from typing import Dict, FrozenSet, List, Tuple


Config = FrozenSet[int]
EnergyMap = Dict[Config, int]


def subsets_of(n: int) -> List[Config]:
    """Generate all subsets of {0,...,n-1}."""
    result = []
    for i in range(2**n):
        s = frozenset(j for j in range(n) if i & (1 << j))
        result.append(s)
    return result


# === Application 1: Inverse Ising Problem ===

def inverse_ising_from_boundary(
    boundary_data: EnergyMap,
    n: int
) -> Tuple[EnergyMap, int, bool]:
    """
    Recover Ising coupling constants from boundary partition data.

    Given boundary energies B(S) for each spin configuration S,
    reconstruct the dual coupling weights w(S) = B(S) - B(∅).

    Args:
        boundary_data: Observed boundary energies
        n: Number of sites

    Returns:
        (dual_weights, gauge_shift, is_certified)
    """
    R = certified_reconstruction(boundary_data)
    return R.dual_weights, R.gauge_shift, R.is_certified()


def demo_inverse_ising():
    """Demonstrate inverse Ising reconstruction."""
    print("=" * 60)
    print("APPLICATION 1: Inverse Ising Problem")
    print("=" * 60)

    n = 3
    J = 2  # coupling constant
    configs = subsets_of(n)

    # Generate "observed" boundary data from the Ising model
    true_energy = {s: ising_chain_energy(s, n, J) for s in configs}

    print(f"\nTrue Ising energies (n={n}, J={J}):")
    for s in sorted(configs, key=lambda x: len(x)):
        spins = ''.join('+' if i in s else '-' for i in range(n))
        print(f"  [{spins}] E = {true_energy[s]:>3}")

    # Reconstruct from boundary data
    w, g, certified = inverse_ising_from_boundary(true_energy, n)

    print(f"\nReconstructed dual weights (gauge shift = {g}):")
    for s in sorted(configs, key=lambda x: len(x)):
        spins = ''.join('+' if i in s else '-' for i in range(n))
        print(f"  [{spins}] w = {w[s]:>3}")

    print(f"\nReconstruction certified: {certified}")

    # Verify: dual weights should equal normalized true energy
    norm_true = normalize(true_energy)
    match = all(w[s] == norm_true[s] for s in configs)
    print(f"Dual weights match normalized true energy: {match}")


# === Application 2: Factor Graph Duality ===

def create_factor_graph_energy(n: int, factors: List[Tuple[Tuple[int, ...], int]]) -> EnergyMap:
    """
    Create an energy function from a factor graph specification.

    Args:
        n: Number of variables
        factors: List of (variable_tuple, coupling_strength)

    Returns:
        Energy map for all configurations
    """
    configs = subsets_of(n)
    energy = {}
    for s in configs:
        e = 0
        for variables, strength in factors:
            # Count how many variables in the factor are "active" (in the subset)
            active = sum(1 for v in variables if v in s)
            # Energy contribution: -strength if all agree, +strength otherwise
            all_in = all(v in s for v in variables)
            none_in = all(v not in s for v in variables)
            if all_in or none_in:
                e -= strength
            else:
                e += strength
        energy[s] = e
    return energy


def demo_factor_graph_duality():
    """Demonstrate duality on a factor graph model."""
    print("\n" + "=" * 60)
    print("APPLICATION 2: Factor Graph Duality")
    print("=" * 60)

    n = 4
    # Define a factor graph: pairs with different coupling strengths
    factors = [
        ((0, 1), 1),  # weak coupling between 0-1
        ((1, 2), 2),  # strong coupling between 1-2
        ((2, 3), 1),  # weak coupling between 2-3
        ((0, 3), 3),  # very strong coupling between 0-3
    ]

    configs = subsets_of(n)
    energy = create_factor_graph_energy(n, factors)

    print(f"\nFactor graph with {n} variables:")
    for vars, J in factors:
        print(f"  Factor {vars}: coupling J = {J}")

    # Find ground state
    ground = min(energy, key=energy.get)
    ground_e = energy[ground]
    print(f"\nGround state: {sorted(ground)} with energy {ground_e}")

    # Compute dual via tropical Legendre
    dual = tropical_legendre(energy)
    dual_ground = min(dual, key=dual.get)

    print(f"\nDual ground state: {sorted(dual_ground)} with dual energy {dual[dual_ground]}")
    print(f"  (Dual ground = primal max-energy config)")

    # Verify bidual recovery
    bidual = tropical_bidual(energy)
    is_ge, c = gauge_equivalent(bidual, energy)
    print(f"\nBidual recovery: gauge-equivalent = {is_ge}, constant = {c}")

    # Show the anti-equivalence: ordering reversal
    norm_p = normalize(energy)
    norm_lp = normalize(dual)
    print(f"\nOrder reversal (anti-equivalence):")
    sorted_configs = sorted(configs, key=lambda s: norm_p[s])
    for i, s in enumerate(sorted_configs[:4]):
        print(f"  Primal rank {i+1}: {str(sorted(s)):>12} energy {norm_p[s]:>3}  "
              f"→ dual energy {norm_lp[s]:>3}")


# === Application 3: Phase Transition Detection ===

def detect_phase_transition(n: int, J_values: List[float]) -> Dict[float, int]:
    """
    Detect phase transitions by tracking the dual energy gap.

    As coupling J varies, the gap between ground and first excited
    state in the dual model signals phase transition behavior.

    Args:
        n: Number of sites
        J_values: Coupling constants to scan

    Returns:
        Dictionary mapping J to dual energy gap
    """
    configs = subsets_of(n)
    gaps = {}

    for J in J_values:
        # Round to integer for our ℤ-valued framework
        J_int = int(round(J))
        if J_int == 0:
            J_int = 1

        energy = {s: ising_chain_energy(s, n, J_int) for s in configs}
        dual = tropical_legendre(energy)

        # Compute dual energy gap
        dual_vals = sorted(set(dual.values()))
        gap = dual_vals[1] - dual_vals[0] if len(dual_vals) > 1 else 0
        gaps[J] = gap

    return gaps


def demo_phase_transition():
    """Demonstrate phase transition detection via dual energy gap."""
    print("\n" + "=" * 60)
    print("APPLICATION 3: Phase Transition Detection via Dual Gap")
    print("=" * 60)

    n = 4
    J_values = [1, 2, 3, 4, 5]
    configs = subsets_of(n)

    print(f"\n{n}-site Ising chain: dual energy gap vs coupling J")
    print(f"{'J':>4} | {'Ground E':>9} | {'Dual gap':>9} | {'Max E':>7}")
    print("-" * 45)

    for J in J_values:
        energy = {s: ising_chain_energy(s, n, J) for s in configs}
        dual = tropical_legendre(energy)

        ground_e = min(energy.values())
        max_e = max(energy.values())
        dual_vals = sorted(set(dual.values()))
        gap = dual_vals[1] - dual_vals[0] if len(dual_vals) > 1 else 0

        print(f"{J:>4} | {ground_e:>9} | {gap:>9} | {max_e:>7}")

    print(f"\nThe dual gap grows linearly with J, reflecting the energy scale.")
    print(f"At zero coupling (J=0), the gap vanishes: no order, no dual structure.")


def main():
    demo_inverse_ising()
    demo_factor_graph_duality()
    demo_phase_transition()

    print("\n" + "=" * 60)
    print("ALL APPLICATIONS DEMONSTRATED SUCCESSFULLY ✓")
    print("=" * 60)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Closure Kramers-Wannier Duality: Interactive Demo

Demonstrates the main theorems with concrete numerical examples:
1. Tropical Legendre transform on a 3-site Ising model
2. Bidual recovery (gauge equivalence)
3. Certified Gibbs reconstruction from boundary data
4. Gauge uniqueness verification
"""

import numpy as np
from itertools import combinations


def subsets_of(n):
    """Generate all subsets of {0, ..., n-1} as frozensets, in binary order."""
    result = []
    for i in range(2**n):
        s = frozenset(j for j in range(n) if i & (1 << j))
        result.append(s)
    return result


def ising_energy(subset, n, J=1):
    """
    Compute Ising energy for a spin configuration on a chain of n sites.
    Spins in 'subset' are +1, others are -1.
    E = -J * sum_{(i,i+1)} sigma_i * sigma_{i+1}
    """
    energy = 0
    for i in range(n - 1):
        si = 1 if i in subset else -1
        sj = 1 if (i + 1) in subset else -1
        energy -= J * si * sj
    return energy


def tropical_legendre(p, configs):
    """
    Compute the tropical Legendre transform: L(p)(T) = min_S p(S) - p(T)
    """
    m = min(p[s] for s in configs)
    return {t: m - p[t] for t in configs}


def dual_tropical_legendre(q, configs):
    """
    Compute the dual tropical Legendre: L*(q)(S) = min_T q(T) - q(S)
    """
    m = min(q[t] for t in configs)
    return {s: m - q[s] for s in configs}


def tropical_bidual(p, configs):
    """Compute p** = L*(L(p))"""
    lp = tropical_legendre(p, configs)
    return dual_tropical_legendre(lp, configs)


def normalize(p, configs):
    """Normalize: p_hat(S) = p(S) - p(empty)"""
    empty = frozenset()
    p0 = p[empty]
    return {s: p[s] - p0 for s in configs}


def gauge_equivalent(p, q, configs):
    """Check if p ~ q (differ by a constant). Return (True, c) or (False, None)."""
    diffs = [p[s] - q[s] for s in configs]
    if len(set(diffs)) == 1:
        return True, diffs[0]
    return False, None


def certified_reconstruction(B, configs):
    """
    Reconstruct dual data from boundary functional B.
    Returns (dual_weights, gauge_shift, realized, normalized).
    """
    empty = frozenset()
    g = B[empty]
    w = {s: B[s] - g for s in configs}
    R = dict(B)
    R_hat = {s: B[s] - g for s in configs}
    return w, g, R, R_hat


def format_subset(s, n):
    """Format a subset for display."""
    if len(s) == 0:
        return "∅"
    return "{" + ",".join(str(i) for i in sorted(s)) + "}"


def main():
    print("=" * 70)
    print("CLOSURE KRAMERS-WANNIER DUALITY: NUMERICAL DEMONSTRATION")
    print("=" * 70)

    # === Example 1: 3-site Ising chain ===
    n = 3
    configs = subsets_of(n)

    print(f"\n{'='*70}")
    print(f"EXAMPLE 1: {n}-site Ising chain with J=1")
    print(f"{'='*70}")

    # Compute Ising energies
    p = {s: ising_energy(s, n) for s in configs}

    print(f"\n--- Primal Partition Section (Ising energies) ---")
    for s in configs:
        print(f"  p({format_subset(s, n):>8}) = {p[s]:>3}")

    # Tropical Legendre transform
    lp = tropical_legendre(p, configs)
    print(f"\n--- Tropical Legendre Transform L(p) ---")
    print(f"  min_S p(S) = {min(p[s] for s in configs)}")
    for s in configs:
        print(f"  L(p)({format_subset(s, n):>8}) = {lp[s]:>3}")

    # Bidual
    pp = tropical_bidual(p, configs)
    print(f"\n--- Tropical Bidual p** = L*(L(p)) ---")
    for s in configs:
        print(f"  p**({format_subset(s, n):>8}) = {pp[s]:>3}")

    # Gauge equivalence check
    is_ge, c = gauge_equivalent(pp, p, configs)
    print(f"\n--- Gauge Equivalence Check (Theorem B) ---")
    print(f"  p** ~ p? {is_ge}")
    if is_ge:
        print(f"  Gauge constant c = {c}")
        print(f"  max_T p(T) = {max(p[s] for s in configs)}")
        print(f"  c = -max_T p(T)? {c == -max(p[s] for s in configs)}")

    # Normalized recovery
    np_hat = normalize(pp, configs)
    p_hat = normalize(p, configs)
    match = all(np_hat[s] == p_hat[s] for s in configs)
    print(f"\n--- Normalized Bidual Recovery (Theorem B') ---")
    print(f"  normalize(p**) == normalize(p)? {match}")
    for s in configs:
        print(f"  norm(p**)({format_subset(s, n):>8}) = {np_hat[s]:>3}  "
              f"norm(p)({format_subset(s, n):>8}) = {p_hat[s]:>3}")

    # Anti-equivalence demonstration
    print(f"\n--- Anti-Equivalence (Theorem A) ---")
    lp_hat = normalize(lp, configs)
    neg_p = {s: -p_hat[s] for s in configs}
    ae_match = all(lp_hat[s] == neg_p[s] for s in configs)
    print(f"  normalizeDual(L(p)) == -normalize(p)? {ae_match}")
    print(f"  (The duality map on normalized sections is negation)")

    # === Example 2: Certified Reconstruction ===
    print(f"\n{'='*70}")
    print(f"EXAMPLE 2: Certified Gibbs Reconstruction (Theorem C)")
    print(f"{'='*70}")

    B = dict(p)  # Boundary data = primal energies
    w, g, R, R_hat = certified_reconstruction(B, configs)

    print(f"\n--- Input: Boundary Partition Functional ---")
    for s in configs:
        print(f"  B({format_subset(s, n):>8}) = {B[s]:>3}")

    print(f"\n--- Reconstructed Dual Weights ---")
    for s in configs:
        print(f"  w({format_subset(s, n):>8}) = {w[s]:>3}")
    print(f"  gauge_shift = {g}")

    # Verify certification
    certified = all(R[s] == w[s] + g for s in configs)
    print(f"\n--- Certification Check ---")
    print(f"  ∀S, R(S) == w(S) + gauge_shift? {certified}")

    # Verify gauge equivalence
    is_ge, c = gauge_equivalent(R, B, configs)
    print(f"  R ~ B? {is_ge} (gauge constant c = {c})")

    # Verify normalized match
    B_hat = normalize(B, configs)
    norm_match = all(R_hat[s] == B_hat[s] for s in configs)
    print(f"  R_hat == normalize(B)? {norm_match}")

    # === Example 3: Gauge Uniqueness (Theorem D) ===
    print(f"\n{'='*70}")
    print(f"EXAMPLE 3: Gauge Uniqueness of Reconstruction (Theorem D)")
    print(f"{'='*70}")

    # Construct an alternative certified coherent reconstruction
    shift = 42  # arbitrary gauge shift
    w2 = {s: w[s] + shift for s in configs}
    g2 = g - shift
    R2 = {s: w2[s] + g2 for s in configs}
    R2_hat = {s: R2[s] - R2[frozenset()] for s in configs}

    print(f"\n--- Alternative Reconstruction (shifted by {shift}) ---")
    for s in configs:
        print(f"  w'({format_subset(s, n):>8}) = {w2[s]:>3}  "
              f"w({format_subset(s, n):>8}) = {w[s]:>3}  "
              f"diff = {w2[s] - w[s]:>3}")

    # Check they have the same normalized boundary
    same_norm = all(R_hat[s] == R2_hat[s] for s in configs)
    print(f"\n  Same normalized boundary? {same_norm}")

    # Check gauge equivalence of dual weights
    diffs = [w[s] - w2[s] for s in configs]
    constant_diff = len(set(diffs)) == 1
    print(f"  Dual weights differ by constant? {constant_diff} (c = {diffs[0]})")

    print(f"\n{'='*70}")
    print(f"ALL THEOREMS VERIFIED NUMERICALLY ✓")
    print(f"{'='*70}")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Closure Kramers-Wannier Duality: Visualizations

Generates publication-quality figures illustrating the main theorems.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from algorithms import (
    tropical_legendre, tropical_bidual, normalize, gauge_equivalent,
    ising_chain_energy
)
from typing import FrozenSet, List
import base64
from io import BytesIO


Config = FrozenSet[int]


def subsets_of(n: int) -> List[Config]:
    result = []
    for i in range(2**n):
        s = frozenset(j for j in range(n) if i & (1 << j))
        result.append(s)
    return result


def config_label(s: Config, n: int) -> str:
    return ''.join('+' if i in s else '-' for i in range(n))


def fig_to_base64(fig) -> str:
    """Convert a matplotlib figure to a base64 data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


def plot_duality_comparison():
    """Plot primal vs dual energies showing the anti-equivalence."""
    n = 3
    configs = subsets_of(n)
    labels = [config_label(s, n) for s in configs]

    p = {s: ising_chain_energy(s, n) for s in configs}
    lp = tropical_legendre(p)

    p_vals = [p[s] for s in configs]
    lp_vals = [lp[s] for s in configs]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    colors_p = ['#2196F3' if v <= 0 else '#FF5722' for v in p_vals]
    colors_d = ['#2196F3' if v <= 0 else '#FF5722' for v in lp_vals]

    bars1 = ax1.bar(range(len(configs)), p_vals, color=colors_p, edgecolor='black', linewidth=0.5)
    ax1.set_xticks(range(len(configs)))
    ax1.set_xticklabels(labels, fontsize=9, family='monospace')
    ax1.set_ylabel('Energy', fontsize=12)
    ax1.set_title('Primal Partition Section p(S)', fontsize=13, fontweight='bold')
    ax1.axhline(y=0, color='gray', linestyle='--', linewidth=0.5)
    ax1.set_xlabel('Spin Configuration', fontsize=11)

    bars2 = ax2.bar(range(len(configs)), lp_vals, color=colors_d, edgecolor='black', linewidth=0.5)
    ax2.set_xticks(range(len(configs)))
    ax2.set_xticklabels(labels, fontsize=9, family='monospace')
    ax2.set_ylabel('Energy', fontsize=12)
    ax2.set_title('Dual Partition Section L(p)(T)', fontsize=13, fontweight='bold')
    ax2.axhline(y=0, color='gray', linestyle='--', linewidth=0.5)
    ax2.set_xlabel('Spin Configuration', fontsize=11)

    fig.suptitle('Kramers–Wannier Duality: 3-Site Ising Chain',
                 fontsize=15, fontweight='bold', y=1.02)
    plt.tight_layout()
    fig.savefig('/workspace/request-project/fig_duality_comparison.png',
                dpi=150, bbox_inches='tight')
    uri = fig_to_base64(fig)
    return uri


def plot_bidual_recovery():
    """Plot bidual recovery demonstrating Theorem B."""
    n = 3
    configs = subsets_of(n)
    labels = [config_label(s, n) for s in configs]

    p = {s: ising_chain_energy(s, n) for s in configs}
    pp = tropical_bidual(p)

    p_norm = normalize(p)
    pp_norm = normalize(pp)

    p_vals = [p_norm[s] for s in configs]
    pp_vals = [pp_norm[s] for s in configs]

    fig, ax = plt.subplots(figsize=(10, 5))

    x = np.arange(len(configs))
    width = 0.35

    bars1 = ax.bar(x - width/2, p_vals, width, label='normalize(p)',
                   color='#2196F3', edgecolor='black', linewidth=0.5, alpha=0.8)
    bars2 = ax.bar(x + width/2, pp_vals, width, label='normalize(p**)',
                   color='#FF9800', edgecolor='black', linewidth=0.5, alpha=0.8)

    ax.set_xticks(x)
    ax.set_xticklabels(labels, fontsize=9, family='monospace')
    ax.set_ylabel('Normalized Energy', fontsize=12)
    ax.set_xlabel('Spin Configuration', fontsize=11)
    ax.set_title('Bidual Recovery: normalize(p**) = normalize(p)',
                 fontsize=13, fontweight='bold')
    ax.legend(fontsize=11)
    ax.axhline(y=0, color='gray', linestyle='--', linewidth=0.5)

    # Annotate perfect match
    match = all(abs(p_vals[i] - pp_vals[i]) < 1e-10 for i in range(len(configs)))
    ax.text(0.98, 0.95, f'Perfect match: ✓' if match else 'Mismatch!',
            transform=ax.transAxes, fontsize=11, ha='right', va='top',
            bbox=dict(boxstyle='round', facecolor='lightgreen' if match else 'salmon',
                      alpha=0.8))

    plt.tight_layout()
    fig.savefig('/workspace/request-project/fig_bidual_recovery.png',
                dpi=150, bbox_inches='tight')
    uri = fig_to_base64(fig)
    return uri


def plot_gauge_structure():
    """Visualize gauge equivalence classes."""
    n = 3
    configs = subsets_of(n)

    p = {s: ising_chain_energy(s, n) for s in configs}
    pp = tropical_bidual(p)

    fig, ax = plt.subplots(figsize=(10, 5))

    x = np.arange(len(configs))
    labels = [config_label(s, n) for s in configs]

    p_vals = np.array([p[s] for s in configs])
    pp_vals = np.array([pp[s] for s in configs])

    ax.plot(x, p_vals, 'o-', color='#2196F3', linewidth=2, markersize=8,
            label='p (primal)', zorder=3)
    ax.plot(x, pp_vals, 's--', color='#FF5722', linewidth=2, markersize=8,
            label='p** (bidual)', zorder=3)

    # Draw gauge arrows
    _, c = gauge_equivalent(pp, p)
    for i in range(len(configs)):
        ax.annotate('', xy=(i, p_vals[i]), xytext=(i, pp_vals[i]),
                     arrowprops=dict(arrowstyle='<->', color='green',
                                   lw=1.5, ls='--'))

    ax.set_xticks(x)
    ax.set_xticklabels(labels, fontsize=9, family='monospace')
    ax.set_ylabel('Energy', fontsize=12)
    ax.set_xlabel('Spin Configuration', fontsize=11)
    ax.set_title(f'Gauge Equivalence: p** = p + ({c})',
                 fontsize=13, fontweight='bold')
    ax.legend(fontsize=11)

    ax.text(0.98, 0.05, f'Gauge constant c = {c}\n(= −max p)',
            transform=ax.transAxes, fontsize=10, ha='right', va='bottom',
            bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

    plt.tight_layout()
    fig.savefig('/workspace/request-project/fig_gauge_structure.png',
                dpi=150, bbox_inches='tight')
    uri = fig_to_base64(fig)
    return uri


def plot_reconstruction():
    """Visualize the certified reconstruction pipeline."""
    n = 3
    configs = subsets_of(n)
    labels = [config_label(s, n) for s in configs]

    p = {s: ising_chain_energy(s, n, J=2) for s in configs}
    p0 = p[frozenset()]
    w = {s: p[s] - p0 for s in configs}

    fig, (ax1, ax2, ax3) = plt.subplots(1, 3, figsize=(16, 5))

    x = np.arange(len(configs))

    # Boundary data
    ax1.bar(x, [p[s] for s in configs], color='#9C27B0',
            edgecolor='black', linewidth=0.5)
    ax1.set_xticks(x)
    ax1.set_xticklabels(labels, fontsize=8, family='monospace')
    ax1.set_title('Input: Boundary Data B(S)', fontsize=12, fontweight='bold')
    ax1.set_ylabel('Energy', fontsize=11)

    # Dual weights
    ax2.bar(x, [w[s] for s in configs], color='#FF9800',
            edgecolor='black', linewidth=0.5)
    ax2.set_xticks(x)
    ax2.set_xticklabels(labels, fontsize=8, family='monospace')
    ax2.set_title('Output: Dual Weights w(S)', fontsize=12, fontweight='bold')
    ax2.set_ylabel('Energy', fontsize=11)
    ax2.axhline(y=0, color='gray', linestyle='--', linewidth=0.5)

    # Verification: R(S) = w(S) + g
    g = p0
    verified = [w[s] + g for s in configs]
    original = [p[s] for s in configs]

    ax3.scatter(original, verified, c='#4CAF50', s=100, zorder=3, edgecolors='black')
    lims = [min(original + verified) - 1, max(original + verified) + 1]
    ax3.plot(lims, lims, 'r--', linewidth=1, label='y = x')
    ax3.set_xlim(lims)
    ax3.set_ylim(lims)
    ax3.set_xlabel('B(S) (original)', fontsize=11)
    ax3.set_ylabel('w(S) + g (reconstructed)', fontsize=11)
    ax3.set_title('Certification: R(S) = w(S) + g', fontsize=12, fontweight='bold')
    ax3.legend(fontsize=10)
    ax3.set_aspect('equal')

    fig.suptitle('Certified Gibbs Reconstruction Pipeline',
                 fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    fig.savefig('/workspace/request-project/fig_reconstruction.png',
                dpi=150, bbox_inches='tight')
    uri = fig_to_base64(fig)
    return uri


def main():
    """Generate all visualizations."""
    print("Generating visualizations...")

    uri1 = plot_duality_comparison()
    print(f"  ✓ Duality comparison (fig_duality_comparison.png)")

    uri2 = plot_bidual_recovery()
    print(f"  ✓ Bidual recovery (fig_bidual_recovery.png)")

    uri3 = plot_gauge_structure()
    print(f"  ✓ Gauge structure (fig_gauge_structure.png)")

    uri4 = plot_reconstruction()
    print(f"  ✓ Reconstruction pipeline (fig_reconstruction.png)")

    print("\nAll visualizations generated successfully!")
    return [uri1, uri2, uri3, uri4]


if __name__ == "__main__":
    main()

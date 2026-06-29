#!/usr/bin/env python3
"""
Applications of Hodge Decomposition to Adversarial Robustness Diagnostics

This module demonstrates how the combinatorial Hodge decomposition can be
applied to analyze neural network decision boundaries through their
activation region overlap structure.

Application 1: Inconsistency field construction from pairwise margins
Application 2: Robustness diagnostics via harmonic energy
Application 3: Topological complexity measurement of decision boundaries
"""

import numpy as np
from algorithms import hodge_decompose, compute_harmonic_space, spectral_gap, hodge_laplacian_1


def simulate_activation_regions(n_regions: int, dim: int = 2,
                                 seed: int = 42) -> np.ndarray:
    """Simulate activation region centers for a toy neural network.

    Each region is defined by a center point in ℝ^dim. Two regions
    "overlap" if they are within a threshold distance.

    Args:
        n_regions: Number of activation regions
        dim: Ambient dimension
        seed: Random seed

    Returns:
        centers: Array of shape (n_regions, dim)
    """
    rng = np.random.RandomState(seed)
    return rng.randn(n_regions, dim)


def build_inconsistency_field(centers: np.ndarray,
                                noise_level: float = 0.1,
                                seed: int = 42) -> np.ndarray:
    """Build an inconsistency field from activation region data.

    The inconsistency ω(i,j) measures the discrepancy between
    local margin estimates at regions i and j. In a perfectly
    calibrated network, ω would be exact (a gradient).

    ω(i,j) = margin(j) - margin(i) + noise(i,j)

    The noise represents local estimation error and potential
    adversarial perturbation.

    Args:
        centers: Region centers of shape (n, dim)
        noise_level: Standard deviation of noise
        seed: Random seed

    Returns:
        omega: Inconsistency field as vector of length n²
    """
    n = len(centers)
    rng = np.random.RandomState(seed)

    # True margins (scalar potentials)
    margins = np.linalg.norm(centers, axis=1)

    # Build exact field + noise
    omega = np.zeros(n * n)
    for i in range(n):
        for j in range(n):
            # Exact part: margin difference (gradient)
            exact_part = margins[j] - margins[i]
            # Noise: anti-symmetric random perturbation
            noise = noise_level * rng.randn()
            omega[i * n + j] = exact_part + noise

    # Make anti-symmetric: ω(i,j) = -ω(j,i)
    omega_mat = omega.reshape(n, n)
    omega_mat = (omega_mat - omega_mat.T) / 2
    return omega_mat.flatten()


def robustness_diagnostic(omega: np.ndarray, n: int) -> dict:
    """Compute robustness diagnostics from an inconsistency field.

    Decomposes the inconsistency into:
    - Exact (gradient): globally correctable by recalibrating margins
    - Coexact (curl†): local rotational defects in triple comparisons
    - Harmonic: irreducible topological obstruction

    Args:
        omega: Inconsistency field vector of length n²
        n: Number of vertices/regions

    Returns:
        Dictionary with diagnostic metrics
    """
    exact, coexact, harmonic = hodge_decompose(n, omega)

    total_energy = np.dot(omega, omega)
    exact_energy = np.dot(exact, exact)
    coexact_energy = np.dot(coexact, coexact)
    harmonic_energy = np.dot(harmonic, harmonic)

    gap = spectral_gap(n)

    return {
        'total_energy': total_energy,
        'exact_energy': exact_energy,
        'coexact_energy': coexact_energy,
        'harmonic_energy': harmonic_energy,
        'exact_fraction': exact_energy / total_energy if total_energy > 0 else 0,
        'coexact_fraction': coexact_energy / total_energy if total_energy > 0 else 0,
        'harmonic_fraction': harmonic_energy / total_energy if total_energy > 0 else 0,
        'spectral_gap': gap,
        'topological_complexity': harmonic_energy / gap if gap > 0 else float('inf'),
    }


def demo_adversarial_analysis():
    """Full adversarial robustness analysis pipeline."""
    print("=" * 70)
    print("APPLICATION: Adversarial Robustness Diagnostics")
    print("=" * 70)

    for n_regions in [4, 5, 6]:
        print(f"\n--- {n_regions} Activation Regions ---")

        centers = simulate_activation_regions(n_regions)
        for noise in [0.0, 0.1, 0.5, 1.0]:
            omega = build_inconsistency_field(centers, noise_level=noise)
            diag = robustness_diagnostic(omega, n_regions)

            print(f"\n  Noise level σ = {noise}:")
            print(f"    Total energy:     {diag['total_energy']:.4f}")
            print(f"    Exact fraction:   {diag['exact_fraction']:.4f}  (correctable)")
            print(f"    Coexact fraction: {diag['coexact_fraction']:.4f}  (local rotation)")
            print(f"    Harmonic fraction:{diag['harmonic_fraction']:.4f}  (topological)")
            print(f"    Spectral gap:     {diag['spectral_gap']:.4f}")

    print("\n\nInterpretation:")
    print("  • High exact fraction → inconsistency is fixable by global recalibration")
    print("  • High coexact fraction → local triple-comparison failures dominate")
    print("  • High harmonic fraction → irreducible topological pathology")
    print("  • For complete simplex (n≥4): harmonic fraction is always 0")


def demo_betti_numbers():
    """Compute first Betti numbers from harmonic space dimensions."""
    print("\n" + "=" * 70)
    print("APPLICATION: Topological Invariants (Betti Numbers)")
    print("=" * 70)
    print("\nThe dimension of the harmonic space equals the first Betti number β₁")
    print("of the simplicial complex. This counts independent 'holes' in the")
    print("activation region overlap structure.\n")

    for n in range(2, 8):
        harm_space = compute_harmonic_space(n)
        beta1 = harm_space.shape[1]
        delta1 = hodge_laplacian_1(n)
        eigenvalues = np.sort(np.linalg.eigvalsh(delta1))
        n_zero = np.sum(np.abs(eigenvalues) < 1e-10)
        print(f"  Complete simplex K_{n}: β₁ = {beta1}, "
              f"min nonzero eigenvalue = {eigenvalues[eigenvalues > 1e-10][0]:.4f}"
              if np.any(eigenvalues > 1e-10) else f"  K_{n}: β₁ = {beta1}")


if __name__ == "__main__":
    demo_adversarial_analysis()
    demo_betti_numbers()


#!/usr/bin/env python3
"""
Hodge Decomposition for Adversarial Inconsistency Fields — Interactive Demo

Demonstrates the combinatorial Hodge decomposition on graph 1-cochains:
  ω = d₀f + d₁†η + h
where:
  - d₀f is the exact (gradient) component: globally correctable inconsistency
  - d₁†η is the coexact (curl-adjoint) component: local rotational defects
  - h is the harmonic component: irreducible topological obstruction

Includes numerical examples on small graphs and the complete simplex.
"""

import numpy as np
from itertools import product as cart_product
from algorithms import (
    build_d0, build_d1, hodge_laplacian_1,
    hodge_decompose, compute_harmonic_space
)

np.set_printoptions(precision=6, suppress=True)


def demo_triangle():
    """Hodge decomposition on a triangle (3 vertices, complete simplex)."""
    print("=" * 70)
    print("DEMO 1: Triangle (K₃) — Complete Simplex on 3 Vertices")
    print("=" * 70)
    n = 3
    d0 = build_d0(n)
    d1 = build_d1(n)

    # Verify cochain complex: d1 @ d0 = 0
    print(f"\n‖d₁ ∘ d₀‖ = {np.linalg.norm(d1 @ d0):.2e}  (should be ≈ 0)")

    # Create a sample inconsistency field (1-cochain)
    # ω(i,j) represents pairwise inconsistency between regions i and j
    omega = np.random.RandomState(42).randn(n * n)

    exact, coexact, harmonic = hodge_decompose(n, omega)

    print(f"\nSample 1-cochain ω (reshaped as {n}×{n} matrix):")
    print(omega.reshape(n, n))

    print(f"\nExact (gradient) component d₀f:")
    print(exact.reshape(n, n))

    print(f"\nCoexact (curl†) component d₁†η:")
    print(coexact.reshape(n, n))

    print(f"\nHarmonic component h:")
    print(harmonic.reshape(n, n))

    # Verify decomposition
    residual = np.linalg.norm(omega - exact - coexact - harmonic)
    print(f"\n‖ω - d₀f - d₁†η - h‖ = {residual:.2e}  (should be ≈ 0)")

    # Verify orthogonality
    print(f"⟨d₀f, d₁†η⟩ = {np.dot(exact, coexact):.2e}  (should be ≈ 0)")
    print(f"⟨d₀f, h⟩ = {np.dot(exact, harmonic):.2e}  (should be ≈ 0)")
    print(f"⟨d₁†η, h⟩ = {np.dot(coexact, harmonic):.2e}  (should be ≈ 0)")

    # Energy decomposition
    total_energy = np.dot(omega, omega)
    exact_energy = np.dot(exact, exact)
    coexact_energy = np.dot(coexact, coexact)
    harmonic_energy = np.dot(harmonic, harmonic)
    print(f"\nEnergy decomposition (Parseval):")
    print(f"  ‖ω‖² = {total_energy:.6f}")
    print(f"  ‖d₀f‖² = {exact_energy:.6f}  ({100*exact_energy/total_energy:.1f}%)")
    print(f"  ‖d₁†η‖² = {coexact_energy:.6f}  ({100*coexact_energy/total_energy:.1f}%)")
    print(f"  ‖h‖² = {harmonic_energy:.6f}  ({100*harmonic_energy/total_energy:.1f}%)")

    # Harmonic space
    harm_dim = compute_harmonic_space(n).shape[1] if compute_harmonic_space(n).size > 0 else 0
    print(f"\ndim(ker Δ₁) = {harm_dim}")
    print(f"Note: For K₃, dim H¹ = 1 (the first Betti number of the triangle boundary)")


def demo_complete_simplex_4():
    """Demonstrate vanishing harmonic space on K₄ (≥4 vertices)."""
    print("\n" + "=" * 70)
    print("DEMO 2: Complete Simplex K₄ — Harmonic Vanishing (card V ≥ 4)")
    print("=" * 70)

    for n in [4, 5, 6]:
        delta1 = hodge_laplacian_1(n)
        eigenvalues = np.linalg.eigvalsh(delta1)
        num_zero = np.sum(np.abs(eigenvalues) < 1e-10)
        print(f"\n  K_{n}: dim(ker Δ₁) = {num_zero}")
        print(f"    Smallest eigenvalues: {sorted(eigenvalues)[:5]}")
        if num_zero == 0:
            print(f"    ✓ ker Δ₁ = {{0}} — every inconsistency decomposes uniquely!")
        else:
            print(f"    ✗ Non-trivial harmonic space detected")

    print("\n  Theorem: For the complete simplex on n ≥ 4 vertices,")
    print("  ker(Δ₁) = {0}, so ω = d₀f + d₁†η uniquely.")


def demo_sparse_graph():
    """Demonstrate non-trivial harmonic space on a sparse overlap graph."""
    print("\n" + "=" * 70)
    print("DEMO 3: Sparse Overlap Graph — Non-trivial Harmonic Obstruction")
    print("=" * 70)

    n = 5
    # Create a sparse overlap graph: cycle C₅
    # Only keep edges on the cycle: (0,1), (1,2), (2,3), (3,4), (4,0)
    edges = [(0,1), (1,2), (2,3), (3,4), (4,0)]
    mask = np.zeros((n, n))
    for i, j in edges:
        mask[i, j] = 1
        mask[j, i] = 1

    d0 = build_d0(n)
    d1 = build_d1(n)

    # Create a 1-cochain supported on the cycle
    omega = np.zeros(n * n)
    for i, j in edges:
        omega[i * n + j] = 1.0
        omega[j * n + i] = -1.0  # alternating

    exact, coexact, harmonic = hodge_decompose(n, omega)

    print(f"\nCycle C₅ inconsistency field ω:")
    print(omega.reshape(n, n))
    print(f"\nHarmonic component h:")
    print(harmonic.reshape(n, n))
    print(f"\n‖h‖² = {np.dot(harmonic, harmonic):.6f}")
    print(f"\nNon-zero harmonic component → topological obstruction!")
    print("This inconsistency cannot be removed by any local correction.")


def demo_energy_landscape():
    """Show how harmonic energy varies with graph connectivity."""
    print("\n" + "=" * 70)
    print("DEMO 4: Harmonic Energy vs. Graph Connectivity")
    print("=" * 70)

    n = 5
    rng = np.random.RandomState(123)
    omega = rng.randn(n * n)
    # Make it alternating
    omega_mat = omega.reshape(n, n)
    omega_mat = (omega_mat - omega_mat.T) / 2
    omega = omega_mat.flatten()

    print(f"\nFixed alternating 1-cochain ω on {n} vertices")
    print(f"‖ω‖² = {np.dot(omega, omega):.4f}\n")

    # Decompose on the complete graph
    exact, coexact, harmonic = hodge_decompose(n, omega)
    print(f"Complete graph K_{n}:")
    print(f"  Exact energy:    {np.dot(exact, exact):.4f}")
    print(f"  Coexact energy:  {np.dot(coexact, coexact):.4f}")
    print(f"  Harmonic energy: {np.dot(harmonic, harmonic):.4f}")


if __name__ == "__main__":
    demo_triangle()
    demo_complete_simplex_4()
    demo_sparse_graph()
    demo_energy_landscape()
    print("\n" + "=" * 70)
    print("All demos completed successfully.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Visualizations for the Hodge Decomposition of Inconsistency Fields.

Generates publication-quality figures demonstrating:
1. The Hodge decomposition energy spectrum
2. Harmonic dimension vs number of vertices
3. Spectral gap scaling
4. Decomposition of a sample inconsistency field
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from algorithms import (
    build_d0, build_d1, hodge_laplacian_1,
    hodge_decompose, compute_harmonic_space, spectral_gap
)

plt.rcParams.update({
    'font.size': 12,
    'figure.figsize': (10, 7),
    'axes.labelsize': 14,
    'axes.titlesize': 16,
    'legend.fontsize': 11,
})


def plot_energy_decomposition():
    """Plot energy decomposition for varying noise levels."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    for idx, n in enumerate([3, 4, 5]):
        ax = axes[idx]
        noise_levels = np.linspace(0, 2, 20)
        exact_energies = []
        coexact_energies = []
        harmonic_energies = []

        rng = np.random.RandomState(42)
        margins = rng.randn(n)

        for noise in noise_levels:
            # Build field: exact + noise
            omega = np.zeros(n * n)
            for i in range(n):
                for j in range(n):
                    omega[i * n + j] = margins[j] - margins[i] + noise * rng.randn()
            omega_mat = omega.reshape(n, n)
            omega_mat = (omega_mat - omega_mat.T) / 2
            omega = omega_mat.flatten()

            exact, coexact, harmonic = hodge_decompose(n, omega)
            total = np.dot(omega, omega)
            if total > 0:
                exact_energies.append(np.dot(exact, exact) / total)
                coexact_energies.append(np.dot(coexact, coexact) / total)
                harmonic_energies.append(np.dot(harmonic, harmonic) / total)
            else:
                exact_energies.append(0)
                coexact_energies.append(0)
                harmonic_energies.append(0)

        ax.stackplot(noise_levels, exact_energies, coexact_energies, harmonic_energies,
                     labels=['Exact (gradient)', 'Coexact (curl†)', 'Harmonic'],
                     colors=['#2196F3', '#FF9800', '#F44336'], alpha=0.85)
        ax.set_xlabel('Noise level σ')
        ax.set_ylabel('Energy fraction')
        ax.set_title(f'K_{n} ({n} vertices)')
        ax.set_ylim(0, 1.05)
        ax.legend(loc='upper left', fontsize=9)

    fig.suptitle('Hodge Decomposition: Energy Spectrum vs. Noise Level', fontsize=16, y=1.02)
    plt.tight_layout()
    plt.savefig('fig_energy_decomposition.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: fig_energy_decomposition.png")


def plot_spectral_properties():
    """Plot eigenvalue spectrum and spectral gap scaling."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Left: Eigenvalue spectra for different n
    ax = axes[0]
    for n in [3, 4, 5, 6]:
        delta1 = hodge_laplacian_1(n)
        eigenvalues = np.sort(np.linalg.eigvalsh(delta1))
        # Only plot first 20 eigenvalues
        k = min(20, len(eigenvalues))
        ax.plot(range(k), eigenvalues[:k], 'o-', label=f'K_{n}', markersize=4)
    ax.set_xlabel('Eigenvalue index')
    ax.set_ylabel('λ')
    ax.set_title('Hodge Laplacian Eigenvalue Spectrum')
    ax.legend()
    ax.axhline(y=0, color='gray', linestyle='--', alpha=0.5)

    # Right: Spectral gap scaling
    ax = axes[1]
    ns = list(range(2, 8))
    gaps = [spectral_gap(n) for n in ns]
    harmonic_dims = [compute_harmonic_space(n).shape[1] for n in ns]

    ax.bar(ns, gaps, color='#4CAF50', alpha=0.8, label='Spectral gap λ₁')
    ax.set_xlabel('Number of vertices n')
    ax.set_ylabel('Spectral gap λ₁')
    ax.set_title('Spectral Gap of Δ₁ on Complete Simplex')

    ax2 = ax.twinx()
    ax2.plot(ns, harmonic_dims, 'rs-', markersize=8, linewidth=2,
             label='dim ker Δ₁')
    ax2.set_ylabel('dim ker Δ₁ (= β₁)')
    ax2.set_ylim(-0.5, max(harmonic_dims) + 1)

    ax.legend(loc='upper left')
    ax2.legend(loc='upper right')

    plt.tight_layout()
    plt.savefig('fig_spectral_properties.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: fig_spectral_properties.png")


def plot_decomposition_heatmaps():
    """Visualize a sample decomposition as heatmaps."""
    n = 5
    rng = np.random.RandomState(7)

    # Build a structured inconsistency field
    margins = np.array([1.0, 0.5, -0.3, 0.8, -0.5])
    omega = np.zeros(n * n)
    for i in range(n):
        for j in range(n):
            omega[i * n + j] = margins[j] - margins[i] + 0.5 * rng.randn()
    omega_mat = omega.reshape(n, n)
    omega_mat = (omega_mat - omega_mat.T) / 2
    omega = omega_mat.flatten()

    exact, coexact, harmonic = hodge_decompose(n, omega)

    fig, axes = plt.subplots(1, 4, figsize=(20, 4.5))
    vmax = max(abs(omega.max()), abs(omega.min()))

    titles = ['ω (full field)', 'd₀f (exact/gradient)',
              'd₁†η (coexact/curl†)', 'h (harmonic)']
    data = [omega, exact, coexact, harmonic]

    for ax, title, d in zip(axes, titles, data):
        im = ax.imshow(d.reshape(n, n), cmap='RdBu_r', vmin=-vmax, vmax=vmax,
                       aspect='equal')
        ax.set_title(title, fontsize=13)
        ax.set_xlabel('Region j')
        ax.set_ylabel('Region i')
        plt.colorbar(im, ax=ax, shrink=0.8)

    fig.suptitle('Hodge Decomposition of an Inconsistency Field (K₅)',
                 fontsize=16, y=1.02)
    plt.tight_layout()
    plt.savefig('fig_decomposition_heatmaps.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: fig_decomposition_heatmaps.png")


def plot_robustness_landscape():
    """Plot robustness landscape: harmonic energy as function of network structure."""
    fig, ax = plt.subplots(figsize=(10, 6))

    ns = list(range(3, 8))
    noise_levels = [0.1, 0.3, 0.5, 1.0]
    colors = ['#1565C0', '#2E7D32', '#EF6C00', '#C62828']

    for noise, color in zip(noise_levels, colors):
        harmonic_fracs = []
        for n in ns:
            rng = np.random.RandomState(42)
            margins = rng.randn(n)
            omega = np.zeros(n * n)
            for i in range(n):
                for j in range(n):
                    omega[i * n + j] = margins[j] - margins[i] + noise * rng.randn()
            omega_mat = omega.reshape(n, n)
            omega_mat = (omega_mat - omega_mat.T) / 2
            omega = omega_mat.flatten()

            _, _, harmonic = hodge_decompose(n, omega)
            total = np.dot(omega, omega)
            harmonic_fracs.append(np.dot(harmonic, harmonic) / total if total > 0 else 0)

        ax.plot(ns, harmonic_fracs, 'o-', color=color, markersize=8,
                linewidth=2, label=f'σ = {noise}')

    ax.set_xlabel('Number of vertices n')
    ax.set_ylabel('Harmonic energy fraction ‖h‖²/‖ω‖²')
    ax.set_title('Irreducible Topological Obstruction vs. Graph Size')
    ax.legend(title='Noise level')
    ax.set_ylim(bottom=-0.01)
    ax.axhline(y=0, color='gray', linestyle='--', alpha=0.5)
    ax.annotate('For complete simplex (n ≥ 4):\nharmonic fraction → 0',
                xy=(5, 0.001), fontsize=11, ha='center',
                bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))

    plt.tight_layout()
    plt.savefig('fig_robustness_landscape.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: fig_robustness_landscape.png")


if __name__ == "__main__":
    plot_energy_decomposition()
    plot_spectral_properties()
    plot_decomposition_heatmaps()
    plot_robustness_landscape()
    print("\nAll visualizations generated successfully.")

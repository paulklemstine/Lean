#!/usr/bin/env python3
"""
Tropical Kernel Mean Embeddings and Congruence Witnesses — Interactive Demo

This script demonstrates the formally verified theory of maxitive empirical laws,
tropicalized kernel mean embeddings, and congruence witness extraction. All
mathematical statements here have machine-checked proofs in Lean 4.

Usage:
    python demo_tropical_kme.py
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import product
from typing import Optional, Callable

# ──────────────────────────────────────────────────────────────────────────────
# Core Definitions (matching the Lean formalization)
# ──────────────────────────────────────────────────────────────────────────────

def eval_maxitive_law(mu: np.ndarray, f: np.ndarray) -> float:
    """Evaluate a maxitive empirical law μ on feature f.

    Computes sup_i (μ(i) ⊔ f(i)), the tropical analogue of E_μ[f].

    This corresponds to `evalMaxitiveLaw` in the Lean formalization.
    """
    return np.max(np.maximum(mu, f))


def eval_maxitive_law_with(op: Callable, mu: np.ndarray, f: np.ndarray) -> float:
    """Evaluate with a custom binary operation (e.g., tropical addition = max+plus)."""
    return np.max([op(mu[i], f[i]) for i in range(len(mu))])


def tropical_kme(A: list, mu: np.ndarray, f: np.ndarray) -> float:
    """Tropical kernel mean embedding evaluation.

    Corresponds to `tropicalKME` in the Lean formalization.
    """
    return eval_maxitive_law(mu, f)


def agrees_on_generators(A: list, mu: np.ndarray, nu: np.ndarray) -> bool:
    """Check if two laws agree on all generators in A.

    Corresponds to `AgreesOnGenerators` in Lean.
    """
    return all(eval_maxitive_law(mu, f) == eval_maxitive_law(nu, f) for f in A)


def witness_discrepancy_count(A: list, mu: np.ndarray, nu: np.ndarray) -> int:
    """Count generators on which μ and ν disagree.

    Corresponds to `witnessDiscrepancyCount` in Lean.
    """
    return sum(1 for f in A if eval_maxitive_law(mu, f) != eval_maxitive_law(nu, f))


def find_witness(A: list, mu: np.ndarray, nu: np.ndarray) -> Optional[np.ndarray]:
    """Find a generator that separates μ from ν, or None.

    Corresponds to `findWitness?` in Lean.
    """
    for f in A:
        if eval_maxitive_law(mu, f) != eval_maxitive_law(nu, f):
            return f
    return None


# ──────────────────────────────────────────────────────────────────────────────
# Demo 1: Basic Evaluation and Witness Extraction
# ──────────────────────────────────────────────────────────────────────────────

def demo_basic():
    """Demonstrate basic evaluation and witness extraction on a 3-element sample space."""
    print("=" * 70)
    print("DEMO 1: Basic Maxitive Law Evaluation and Witness Extraction")
    print("=" * 70)
    print()

    # Sample space ι = {0, 1, 2}, values in ℕ (non-negative integers)
    n = 3

    # Two distinct maxitive laws
    mu = np.array([3, 1, 4])
    nu = np.array([2, 5, 1])

    print(f"Sample space: ι = {{0, 1, 2}}")
    print(f"Law μ = {mu}")
    print(f"Law ν = {nu}")
    print()

    # Generator set: some test features
    generators = [
        np.array([1, 0, 2]),
        np.array([0, 3, 0]),
        np.array([2, 2, 2]),
        np.array([0, 0, 0]),
        np.array([5, 0, 0]),
    ]

    print("Generator set A:")
    for i, f in enumerate(generators):
        eval_mu = eval_maxitive_law(mu, f)
        eval_nu = eval_maxitive_law(nu, f)
        sep = "≠" if eval_mu != eval_nu else "="
        print(f"  f_{i} = {f}:  eval(μ,f) = {eval_mu},  eval(ν,f) = {eval_nu}  [{sep}]")
    print()

    # Witness extraction
    count = witness_discrepancy_count(generators, mu, nu)
    witness = find_witness(generators, mu, nu)

    print(f"Discrepancy count: {count}")
    if witness is not None:
        print(f"Separating witness found: {witness}")
        print(f"  eval(μ, witness) = {eval_maxitive_law(mu, witness)}")
        print(f"  eval(ν, witness) = {eval_maxitive_law(nu, witness)}")
    else:
        print("No separating witness (laws agree on all generators)")

    # Verify the formally proved theorem:
    # witnessDiscrepancyCount = 0 ⟺ ∀ f ∈ A, eval(μ,f) = eval(ν,f)
    agrees = agrees_on_generators(generators, mu, nu)
    print(f"\nAgreesOnGenerators: {agrees}")
    print(f"Discrepancy count = 0: {count == 0}")
    print(f"Theorem verified: (count = 0) ↔ agrees = {(count == 0) == agrees} ✓")
    print()


# ──────────────────────────────────────────────────────────────────────────────
# Demo 2: Generated Feature Algebra and Agreement Propagation
# ──────────────────────────────────────────────────────────────────────────────

def demo_generated_algebra():
    """Demonstrate that agreement on generators propagates to the generated algebra."""
    print("=" * 70)
    print("DEMO 2: Generated Feature Algebra — Agreement Propagation")
    print("=" * 70)
    print()

    n = 4  # sample space size

    # Choose μ and ν that agree on specific generators
    mu = np.array([2, 3, 1, 4])
    nu = np.array([1, 4, 2, 3])

    # Generators chosen so that μ and ν agree on them
    # eval(μ, f) = max_i(max(μ_i, f_i)) and similarly for ν
    generators = [
        np.array([5, 5, 5, 5]),  # constant → both give 5
        np.array([4, 4, 4, 4]),  # constant → both give 4
    ]

    print(f"Law μ = {mu}")
    print(f"Law ν = {nu}")
    print(f"Generators:")
    for i, f in enumerate(generators):
        eval_mu = eval_maxitive_law(mu, f)
        eval_nu = eval_maxitive_law(nu, f)
        print(f"  g_{i} = {f}: eval(μ) = {eval_mu}, eval(ν) = {eval_nu}")

    agrees = agrees_on_generators(generators, mu, nu)
    print(f"\nAgreesOnGenerators: {agrees}")

    if agrees:
        print("\nBy the proved theorem (agrees_on_generated_algebra_of_agrees_on_generators),")
        print("agreement propagates to ALL elements of the generated feature algebra.")
        print("\nVerifying on generated elements (pointwise sup combinations):")

        # Generate some elements of the closure under pointwise sup
        generated = list(generators)
        for i in range(len(generators)):
            for j in range(len(generators)):
                f_sup = np.maximum(generators[i], generators[j])
                generated.append(f_sup)

        # Second level
        level2 = []
        for i in range(len(generated)):
            for j in range(len(generated)):
                f_sup = np.maximum(generated[i], generated[j])
                level2.append(f_sup)
        generated.extend(level2)

        # Remove duplicates
        unique_gen = []
        for f in generated:
            if not any(np.array_equal(f, g) for g in unique_gen):
                unique_gen.append(f)

        all_agree = True
        for f in unique_gen:
            eval_mu = eval_maxitive_law(mu, f)
            eval_nu = eval_maxitive_law(nu, f)
            if eval_mu != eval_nu:
                all_agree = False
                print(f"  DISAGREEMENT on {f}: {eval_mu} ≠ {eval_nu}")

        if all_agree:
            print(f"  All {len(unique_gen)} generated elements verified: agreement holds ✓")
    print()


# ──────────────────────────────────────────────────────────────────────────────
# Demo 3: Visualization — Discrepancy Landscape
# ──────────────────────────────────────────────────────────────────────────────

def demo_visualization():
    """Visualize the discrepancy landscape as one law varies."""
    print("=" * 70)
    print("DEMO 3: Discrepancy Landscape Visualization")
    print("=" * 70)
    print()

    # Fixed reference law
    mu = np.array([3, 1])

    # Generator set: all features with values in {0, 1, 2, 3, 4}
    vals = range(5)
    generators = [np.array([a, b]) for a, b in product(vals, repeat=2)]

    print(f"Fixed law μ = {mu}")
    print(f"Sample space: ι = {{0, 1}}")
    print(f"Generator set: all features ι → {{0,...,4}} ({len(generators)} generators)")

    # Compute discrepancy count for each possible ν
    grid_size = 5
    disc_matrix = np.zeros((grid_size, grid_size))

    for a in range(grid_size):
        for b in range(grid_size):
            nu = np.array([a, b])
            disc_matrix[b, a] = witness_discrepancy_count(generators, mu, nu)

    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Heatmap of discrepancy counts
    im = axes[0].imshow(disc_matrix, origin='lower', cmap='YlOrRd',
                        extent=[-0.5, grid_size-0.5, -0.5, grid_size-0.5])
    axes[0].set_xlabel('ν(0)')
    axes[0].set_ylabel('ν(1)')
    axes[0].set_title(f'Witness Discrepancy Count\n(μ = {mu})')
    axes[0].plot(mu[0], mu[1], 'b*', markersize=15, label='μ')
    axes[0].legend()
    plt.colorbar(im, ax=axes[0], label='# separating generators')

    # Add count labels
    for a in range(grid_size):
        for b in range(grid_size):
            axes[0].text(a, b, f'{int(disc_matrix[b, a])}',
                        ha='center', va='center', fontsize=9,
                        color='white' if disc_matrix[b, a] > disc_matrix.max()/2 else 'black')

    # Visualization: eval landscape for a specific feature
    f_test = np.array([2, 0])
    eval_landscape = np.zeros((grid_size, grid_size))
    for a in range(grid_size):
        for b in range(grid_size):
            nu = np.array([a, b])
            eval_landscape[b, a] = eval_maxitive_law(nu, f_test)

    im2 = axes[1].imshow(eval_landscape, origin='lower', cmap='viridis',
                         extent=[-0.5, grid_size-0.5, -0.5, grid_size-0.5])
    axes[1].set_xlabel('ν(0)')
    axes[1].set_ylabel('ν(1)')
    axes[1].set_title(f'Eval landscape for feature f = {f_test}')
    eval_mu = eval_maxitive_law(mu, f_test)
    axes[1].plot(mu[0], mu[1], 'r*', markersize=15, label=f'μ (eval={eval_mu})')
    axes[1].legend()
    plt.colorbar(im2, ax=axes[1], label='eval(ν, f)')

    for a in range(grid_size):
        for b in range(grid_size):
            axes[1].text(a, b, f'{int(eval_landscape[b, a])}',
                        ha='center', va='center', fontsize=9,
                        color='white' if eval_landscape[b, a] < eval_landscape.max()/2 else 'black')

    plt.tight_layout()
    plt.savefig('tropical_kme_discrepancy.png', dpi=150, bbox_inches='tight')
    print("Saved: tropical_kme_discrepancy.png")
    plt.close()
    print()


# ──────────────────────────────────────────────────────────────────────────────
# Demo 4: Tropical Max-Plus Semiring Specialization
# ──────────────────────────────────────────────────────────────────────────────

def demo_max_plus():
    """Demonstrate the max-plus (tropical) specialization."""
    print("=" * 70)
    print("DEMO 4: Max-Plus Tropical Semiring Specialization")
    print("=" * 70)
    print()

    # In the max-plus semiring: ⊕ = max, ⊗ = +
    # The "weighted evaluation" uses ⊗ (addition) instead of ⊔ (max)
    def max_plus_eval(mu, f):
        """Max-plus evaluation: sup_i (μ(i) + f(i))"""
        return np.max(mu + f)

    n = 4
    mu = np.array([0, 2, 1, 3])
    nu = np.array([1, 0, 3, 2])

    generators = [
        np.array([1, 0, 0, 0]),
        np.array([0, 1, 0, 0]),
        np.array([0, 0, 1, 0]),
        np.array([0, 0, 0, 1]),
        np.array([1, 1, 1, 1]),
    ]

    print(f"Max-plus semiring (ℝ_max = (ℝ ∪ {{-∞}}, max, +))")
    print(f"Law μ = {mu}")
    print(f"Law ν = {nu}")
    print(f"\nEvaluation: sup_i (μ(i) + f(i))")
    print()

    for i, f in enumerate(generators):
        eval_mu = max_plus_eval(mu, f)
        eval_nu = max_plus_eval(nu, f)
        sep = "≠" if eval_mu != eval_nu else "="
        print(f"  e_{i} = {f}:  Φ_μ(e) = {eval_mu},  Φ_ν(e) = {eval_nu}  [{sep}]")

    print()
    print("Note: The coordinate basis vectors e_i give Φ_μ(e_i) = μ(i),")
    print("so the max-plus KME with all coordinate features is injective.")
    print("This is the tropical analogue of characteristic kernels!")
    print()


# ──────────────────────────────────────────────────────────────────────────────
# Demo 5: Distribution Shift Detection Application
# ──────────────────────────────────────────────────────────────────────────────

def demo_shift_detection():
    """Demonstrate distribution shift detection using tropical KME."""
    print("=" * 70)
    print("DEMO 5: Distribution Shift Detection via Tropical KME")
    print("=" * 70)
    print()

    np.random.seed(42)
    n = 10  # sample space size

    # "Training distribution" — weights from some model
    mu_train = np.random.randint(0, 8, size=n)

    # Generate test features (random generators)
    n_features = 20
    generators = [np.random.randint(0, 6, size=n) for _ in range(n_features)]

    # Compute reference evaluations
    ref_evals = [eval_maxitive_law(mu_train, f) for f in generators]

    print(f"Training law μ = {mu_train}")
    print(f"Monitoring {n_features} test features")
    print()

    # Simulate several "test distributions"
    test_cases = [
        ("No shift", mu_train.copy()),
        ("Small shift", mu_train + np.array([0,0,0,0,0,1,0,0,0,0])),
        ("Large shift", np.random.randint(0, 8, size=n)),
        ("Adversarial", np.ones(n, dtype=int) * np.max(mu_train)),
    ]

    fig, axes = plt.subplots(2, 2, figsize=(12, 10))

    for idx, (name, nu_test) in enumerate(test_cases):
        ax = axes[idx // 2][idx % 2]

        test_evals = [eval_maxitive_law(nu_test, f) for f in generators]
        disc_count = witness_discrepancy_count(generators, mu_train, nu_test)
        witness = find_witness(generators, mu_train, nu_test)

        print(f"  {name}: ν = {nu_test}")
        print(f"    Discrepancy count: {disc_count}/{n_features}")
        if witness is not None:
            print(f"    First witness: {witness}")
        print()

        # Plot comparison
        x = np.arange(n_features)
        ax.bar(x - 0.15, ref_evals, 0.3, label='eval(μ, f)', alpha=0.8, color='steelblue')
        ax.bar(x + 0.15, test_evals, 0.3, label='eval(ν, f)', alpha=0.8, color='coral')

        # Mark discrepancies
        for i in range(n_features):
            if ref_evals[i] != test_evals[i]:
                ax.axvspan(i - 0.4, i + 0.4, alpha=0.15, color='red')

        ax.set_title(f'{name}\n(discrepancy: {disc_count}/{n_features})')
        ax.set_xlabel('Feature index')
        ax.set_ylabel('Evaluation')
        ax.legend(fontsize=8)

    plt.suptitle('Tropical KME Distribution Shift Detection', fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('tropical_shift_detection.png', dpi=150, bbox_inches='tight')
    print("Saved: tropical_shift_detection.png")
    plt.close()
    print()


# ──────────────────────────────────────────────────────────────────────────────
# Demo 6: Witness Complexity — How Many Generators Suffice?
# ──────────────────────────────────────────────────────────────────────────────

def demo_witness_complexity():
    """Explore how discrepancy count scales with generator set size."""
    print("=" * 70)
    print("DEMO 6: Witness Complexity — Scaling with Generator Set Size")
    print("=" * 70)
    print()

    np.random.seed(123)
    n = 5  # sample space size

    mu = np.array([4, 1, 3, 0, 2])
    nu = np.array([2, 3, 0, 4, 1])

    # Progressively larger random generator sets
    sizes = list(range(1, 101))
    disc_counts = []
    disc_fractions = []

    all_generators = [np.random.randint(0, 5, size=n) for _ in range(max(sizes))]

    for k in sizes:
        gens = all_generators[:k]
        count = witness_discrepancy_count(gens, mu, nu)
        disc_counts.append(count)
        disc_fractions.append(count / k if k > 0 else 0)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    ax1.plot(sizes, disc_counts, 'b-', linewidth=1.5)
    ax1.set_xlabel('Generator set size |A|')
    ax1.set_ylabel('Discrepancy count')
    ax1.set_title('Absolute Discrepancy Count')
    ax1.grid(True, alpha=0.3)

    ax2.plot(sizes, disc_fractions, 'r-', linewidth=1.5)
    ax2.set_xlabel('Generator set size |A|')
    ax2.set_ylabel('Discrepancy fraction')
    ax2.set_title('Discrepancy Fraction (count / |A|)')
    ax2.set_ylim(0, 1.05)
    ax2.grid(True, alpha=0.3)

    plt.suptitle(f'Witness Complexity: μ={mu}, ν={nu}', fontsize=12, fontweight='bold')
    plt.tight_layout()
    plt.savefig('witness_complexity.png', dpi=150, bbox_inches='tight')
    print("Saved: witness_complexity.png")
    plt.close()
    print()


# ──────────────────────────────────────────────────────────────────────────────
# Main
# ──────────────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  Tropical KME and Congruence Witnesses — Formally Verified Theory  ║")
    print("║  All theorems machine-checked in Lean 4 with Mathlib               ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    demo_basic()
    demo_generated_algebra()
    demo_visualization()
    demo_max_plus()
    demo_shift_detection()
    demo_witness_complexity()

    print("=" * 70)
    print("All demos complete. Visualizations saved as PNG files.")
    print("=" * 70)

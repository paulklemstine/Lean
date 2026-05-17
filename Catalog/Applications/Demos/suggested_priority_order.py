#!/usr/bin/env python3
"""
Applications of Tropical Perturbation Amplification

Demonstrates real-world applications of the tensorization law and
related results in cryptography, network optimization, and machine learning.
"""

import numpy as np


def application_cryptographic_key_composition():
    """
    Application: Cryptographic Key Space Composition

    When combining independent cryptographic primitives, the total
    security margin (measured in bits) is the sum of individual margins.

    The tropical perturbation bound gives the log-cardinality of the
    key space, and the tensorization law guarantees that composing
    independent key spaces multiplies the total key space size.
    """
    print("=" * 60)
    print("APPLICATION 1: Cryptographic Key Composition")
    print("=" * 60)

    # AES-128 + RSA-2048 composition
    key_bits_aes = 128
    key_bits_rsa = 2048

    # Tropical perturbation bounds (in bits = log2)
    phi_aes = key_bits_aes  # log2(2^128) = 128
    phi_rsa = key_bits_rsa  # log2(2^2048) = 2048

    # By tensorization law: combined security = sum
    phi_combined = phi_aes + phi_rsa

    print(f"AES-128 key space: 2^{key_bits_aes} keys, Φ = {phi_aes} bits")
    print(f"RSA-2048 key space: 2^{key_bits_rsa} keys, Φ = {phi_rsa} bits")
    print(f"Combined key space: 2^{phi_combined} keys, Φ = {phi_combined} bits")
    print()

    # Perturbation stability: if each key has ε error probability
    eps_aes = 2**(-128)
    eps_rsa = 2**(-112)  # effective security against best attacks

    combined_eps = eps_aes + eps_rsa
    print(f"AES security margin: ε₁ = 2^{-128}")
    print(f"RSA security margin: ε₂ ≈ 2^{-112}")
    print(f"Combined margin:     ε₁ + ε₂ ≈ 2^{np.log2(combined_eps):.1f}")
    print(f"(Dominated by weaker primitive, as expected)")
    print()


def application_network_routing():
    """
    Application: Network Routing Optimization

    In network routing, the tropical max functional computes the
    maximum-bandwidth path. The tensorization law shows that
    the routing complexity of a product network (two independent
    subnetworks) is the sum of individual complexities.
    """
    print("=" * 60)
    print("APPLICATION 2: Network Routing Complexity")
    print("=" * 60)

    # Two independent subnetworks
    network_A_nodes = 50   # e.g., regional backbone
    network_B_nodes = 200  # e.g., metropolitan access network

    phi_A = np.log(network_A_nodes)
    phi_B = np.log(network_B_nodes)
    phi_product = np.log(network_A_nodes * network_B_nodes)

    print(f"Network A: {network_A_nodes} nodes, Φ = {phi_A:.4f} nats")
    print(f"Network B: {network_B_nodes} nodes, Φ = {phi_B:.4f} nats")
    print(f"Product network: {network_A_nodes * network_B_nodes} nodes")
    print(f"Φ(A×B) = {phi_product:.4f} = Φ(A) + Φ(B) = {phi_A + phi_B:.4f}")
    print()

    # Simulate routing optimization
    np.random.seed(42)
    w_A = np.random.exponential(1, network_A_nodes)  # link bandwidths
    w_B = np.random.exponential(1, network_B_nodes)

    demands_A = np.random.randn(network_A_nodes)
    demands_B = np.random.randn(network_B_nodes)

    # Factor optima
    opt_A = np.max(demands_A + w_A)
    opt_B = np.max(demands_B + w_B)

    # Product optimum (should equal sum by separability)
    opt_product = float('-inf')
    for i in range(min(network_A_nodes, 50)):  # sample
        for j in range(min(network_B_nodes, 50)):
            val = (demands_A[i] + demands_B[j]) + (w_A[i] + w_B[j])
            opt_product = max(opt_product, val)

    print(f"Optimal routing value (A): {opt_A:.4f}")
    print(f"Optimal routing value (B): {opt_B:.4f}")
    print(f"Sum of optima: {opt_A + opt_B:.4f}")
    print(f"Product optimum (sampled): {opt_product:.4f}")
    print()


def application_ml_model_composition():
    """
    Application: Machine Learning Model Composition

    When composing independent feature extractors (e.g., multi-modal
    learning), the total representation complexity is additive.
    The tropical perturbation bound measures the effective dimension
    of each feature space.
    """
    print("=" * 60)
    print("APPLICATION 3: ML Model Composition Complexity")
    print("=" * 60)

    # Feature spaces of different modalities
    modalities = {
        "Vision (ResNet features)": 2048,
        "Language (BERT tokens)": 30522,
        "Audio (mel bins)": 128,
    }

    total_phi = 0
    print("Individual modalities:")
    for name, dim in modalities.items():
        phi = np.log(dim)
        total_phi += phi
        print(f"  {name}: dim={dim}, Φ = {phi:.4f} nats = {phi/np.log(2):.2f} bits")

    # Product composition
    total_dim = 1
    for dim in modalities.values():
        total_dim *= dim

    product_phi = np.log(total_dim)

    print()
    print(f"Product feature space: dim = {total_dim:,}")
    print(f"Φ(product) = {product_phi:.4f} = sum of Φ = {total_phi:.4f}")
    print(f"Error: {abs(product_phi - total_phi):.2e}")
    print()

    # Perturbation analysis: how robust is the combined model?
    print("Perturbation stability analysis:")
    eps_values = {"Vision": 0.01, "Language": 0.05, "Audio": 0.02}
    total_eps = sum(eps_values.values())
    for name, eps in eps_values.items():
        print(f"  {name}: ε = {eps}")
    print(f"  Combined perturbation bound: ε_total = {total_eps}")
    print(f"  (Errors add linearly, never multiply — by compositional stability)")
    print()


def application_thermodynamic_extensivity():
    """
    Application: Thermodynamic Extensivity Verification

    The tropical perturbation bound behaves like a thermodynamic
    extensive variable (entropy, free energy): it adds for
    non-interacting subsystems.
    """
    print("=" * 60)
    print("APPLICATION 4: Thermodynamic Extensivity")
    print("=" * 60)

    # Simulate n copies of a system
    base_states = 6  # e.g., 6-state spin system
    phi_base = np.log(base_states)

    print(f"Base system: {base_states} states, Φ = {phi_base:.6f} nats")
    print()
    print(f"{'n copies':>10s}  {'Total states':>15s}  {'Φ (computed)':>14s}  "
          f"{'n·Φ₁ (predicted)':>18s}  {'Extensive?':>12s}")
    print("-" * 75)

    for n in range(1, 11):
        total_states = base_states ** n
        phi_computed = np.log(total_states)
        phi_predicted = n * phi_base
        is_extensive = abs(phi_computed - phi_predicted) < 1e-12
        print(f"{n:10d}  {total_states:15d}  {phi_computed:14.6f}  "
              f"{phi_predicted:18.6f}  {'✓' if is_extensive else '✗':>12s}")

    print()
    print("The tropical perturbation bound is perfectly extensive,")
    print("exactly like thermodynamic entropy for ideal (non-interacting) systems.")
    print()


if __name__ == "__main__":
    application_cryptographic_key_composition()
    application_network_routing()
    application_ml_model_composition()
    application_thermodynamic_extensivity()
    print("All applications demonstrated successfully.")


#!/usr/bin/env python3
"""
Tropical Perturbation Amplification: Demos and Numerical Verification

This module demonstrates the key theorems of the tropical perturbation
amplification calculus with concrete numerical examples.
"""

import numpy as np
from itertools import product as cartesian_product


def tropical_perturbation_bound(card: int) -> float:
    """Tropical perturbation bound Φ(S) = log|S|."""
    if card <= 0:
        return float('-inf')
    return np.log(card)


def tropical_max(weights: np.ndarray, f: np.ndarray) -> float:
    """Tropical max functional: max_s (f(s) + w(s))."""
    return np.max(f + weights)


def demo_tensorization_law():
    """
    Demonstrate the tensorization law: Φ(S × T) = Φ(S) + Φ(T).

    We verify this identity for many pairs of support sizes.
    """
    print("=" * 60)
    print("DEMO 1: Tensorization Law")
    print("Φ(S × T) = Φ(S) + Φ(T)")
    print("=" * 60)

    errors = []
    for card_S in range(1, 51):
        for card_T in range(1, 51):
            card_product = card_S * card_T
            lhs = tropical_perturbation_bound(card_product)
            rhs = (tropical_perturbation_bound(card_S)
                    + tropical_perturbation_bound(card_T))
            errors.append(abs(lhs - rhs))

    print(f"Tested {len(errors)} pairs of support sizes (1..50) × (1..50)")
    print(f"Maximum absolute error: {max(errors):.2e}")
    print(f"Mean absolute error:    {np.mean(errors):.2e}")
    print(f"Tensorization law verified: {max(errors) < 1e-14}")
    print()

    # Show a few examples
    print("Examples:")
    for (s, t) in [(3, 5), (7, 11), (10, 10), (2, 100)]:
        prod = s * t
        phi_s = tropical_perturbation_bound(s)
        phi_t = tropical_perturbation_bound(t)
        phi_prod = tropical_perturbation_bound(prod)
        print(f"  |S|={s:3d}, |T|={t:3d}: "
              f"Φ(S×T)={phi_prod:.6f}, Φ(S)+Φ(T)={phi_s+phi_t:.6f}, "
              f"error={abs(phi_prod - phi_s - phi_t):.2e}")
    print()


def demo_n_fold_amplification():
    """
    Demonstrate n-fold amplification: Φ(S^n) = n · Φ(S).
    """
    print("=" * 60)
    print("DEMO 2: N-fold Amplification Law")
    print("Φ(S^n) = n · Φ(S)")
    print("=" * 60)

    card_S = 5
    phi_S = tropical_perturbation_bound(card_S)

    print(f"Base support size |S| = {card_S}, Φ(S) = {phi_S:.6f}")
    print()
    print(f"{'n':>4s}  {'|S^n|':>15s}  {'Φ(S^n)':>12s}  {'n·Φ(S)':>12s}  {'error':>10s}")
    print("-" * 60)

    for n in range(1, 16):
        card_n = card_S ** n
        phi_n = tropical_perturbation_bound(card_n)
        expected = n * phi_S
        error = abs(phi_n - expected)
        print(f"{n:4d}  {card_n:15d}  {phi_n:12.6f}  {expected:12.6f}  {error:10.2e}")
    print()


def demo_exponential_multiplicativity():
    """
    Demonstrate exponential multiplicativity: exp(Φ(S×T)) = exp(Φ(S))·exp(Φ(T)).
    """
    print("=" * 60)
    print("DEMO 3: Exponential Multiplicativity")
    print("exp(Φ(S×T)) = exp(Φ(S)) · exp(Φ(T))")
    print("=" * 60)

    examples = [(3, 7), (5, 11), (10, 10), (2, 50), (13, 17)]

    for (s, t) in examples:
        phi_s = tropical_perturbation_bound(s)
        phi_t = tropical_perturbation_bound(t)
        phi_prod = tropical_perturbation_bound(s * t)

        exp_prod = np.exp(phi_prod)
        exp_s_times_exp_t = np.exp(phi_s) * np.exp(phi_t)

        print(f"|S|={s:3d}, |T|={t:3d}: "
              f"exp(Φ(S×T))={exp_prod:.4f}, "
              f"exp(Φ(S))·exp(Φ(T))={exp_s_times_exp_t:.4f}, "
              f"|S|·|T|={s*t}")

    print()
    print("Note: exp(Φ(S)) = |S| exactly (recovery theorem)")
    print()


def demo_separable_decomposition():
    """
    Demonstrate the separable product decomposition of tropical max.
    """
    print("=" * 60)
    print("DEMO 4: Separable Product Decomposition")
    print("tropMax(S×T, w₁⊕w₂, f₁⊕f₂) = tropMax(S,w₁,f₁) + tropMax(T,w₂,f₂)")
    print("=" * 60)

    np.random.seed(42)

    for trial in range(5):
        n_S = np.random.randint(3, 10)
        n_T = np.random.randint(3, 10)

        w1 = np.random.randn(n_S)
        w2 = np.random.randn(n_T)
        f1 = np.random.randn(n_S)
        f2 = np.random.randn(n_T)

        # Factor maxima
        max_S = tropical_max(w1, f1)
        max_T = tropical_max(w2, f2)

        # Product maximum
        product_vals = []
        for i in range(n_S):
            for j in range(n_T):
                product_vals.append((f1[i] + f2[j]) + (w1[i] + w2[j]))
        max_product = max(product_vals)

        error = abs(max_product - (max_S + max_T))
        print(f"Trial {trial+1}: |S|={n_S}, |T|={n_T}, "
              f"product max={max_product:.6f}, "
              f"sum of maxima={max_S + max_T:.6f}, "
              f"error={error:.2e}")

    print()


def demo_perturbation_stability():
    """
    Demonstrate compositional perturbation stability.
    """
    print("=" * 60)
    print("DEMO 5: Compositional Perturbation Stability")
    print("|Δw_product| ≤ ε₁ + ε₂")
    print("=" * 60)

    np.random.seed(123)

    for trial in range(5):
        n_S, n_T = 10, 8
        eps1, eps2 = 0.1 * (trial + 1), 0.05 * (trial + 1)

        w1 = np.random.randn(n_S)
        w2 = np.random.randn(n_T)

        # Perturbed weights (within eps bounds)
        delta1 = np.random.uniform(-eps1, eps1, n_S)
        delta2 = np.random.uniform(-eps2, eps2, n_T)
        w1p = w1 + delta1
        w2p = w2 + delta2

        # Check product perturbation
        max_product_error = 0
        for i in range(n_S):
            for j in range(n_T):
                prod_orig = w1[i] + w2[j]
                prod_pert = w1p[i] + w2p[j]
                max_product_error = max(max_product_error, abs(prod_orig - prod_pert))

        bound = eps1 + eps2
        print(f"Trial {trial+1}: ε₁={eps1:.3f}, ε₂={eps2:.3f}, "
              f"bound={bound:.3f}, "
              f"actual max error={max_product_error:.6f}, "
              f"within bound: {max_product_error <= bound + 1e-15}")

    print()


def demo_automata_growth():
    """
    Demonstrate the automata state growth connection:
    exp(Φ(S^n)) = |S|^n
    """
    print("=" * 60)
    print("DEMO 6: Automata State Growth")
    print("exp(Φ(S^n)) = |S|^n")
    print("=" * 60)

    for card_S in [2, 3, 5, 10]:
        phi_S = tropical_perturbation_bound(card_S)
        print(f"\nAlphabet size |S| = {card_S}, growth exponent Φ(S) = {phi_S:.6f}")
        print(f"{'n':>4s}  {'|S|^n':>15s}  {'exp(n·Φ(S))':>15s}  {'error':>10s}")
        print("-" * 50)
        for n in range(1, 11):
            actual = card_S ** n
            predicted = np.exp(n * phi_S)
            error = abs(actual - predicted)
            print(f"{n:4d}  {actual:15d}  {predicted:15.2f}  {error:10.2e}")
    print()


if __name__ == "__main__":
    demo_tensorization_law()
    demo_n_fold_amplification()
    demo_exponential_multiplicativity()
    demo_separable_decomposition()
    demo_perturbation_stability()
    demo_automata_growth()
    print("All demos completed successfully.")


#!/usr/bin/env python3
"""
Visualizations for Tropical Perturbation Amplification.
Generates PNG figures demonstrating the key results.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import base64
import io
import json


def fig_to_base64(fig) -> str:
    """Convert a matplotlib figure to a base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


def viz_tensorization():
    """Visualize the tensorization law heatmap."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 4.5))

    sizes = np.arange(1, 51)
    S, T = np.meshgrid(sizes, sizes)

    # Phi(S x T)
    phi_product = np.log(S * T)
    im1 = axes[0].imshow(phi_product, extent=[1, 50, 1, 50],
                          origin='lower', cmap='viridis', aspect='auto')
    axes[0].set_title('Φ(S × T) = log(|S|·|T|)', fontsize=12)
    axes[0].set_xlabel('|S|')
    axes[0].set_ylabel('|T|')
    plt.colorbar(im1, ax=axes[0], label='nats')

    # Phi(S) + Phi(T)
    phi_sum = np.log(S) + np.log(T)
    im2 = axes[1].imshow(phi_sum, extent=[1, 50, 1, 50],
                          origin='lower', cmap='viridis', aspect='auto')
    axes[1].set_title('Φ(S) + Φ(T) = log|S| + log|T|', fontsize=12)
    axes[1].set_xlabel('|S|')
    axes[1].set_ylabel('|T|')
    plt.colorbar(im2, ax=axes[1], label='nats')

    # Error
    error = np.abs(phi_product - phi_sum)
    im3 = axes[2].imshow(error, extent=[1, 50, 1, 50],
                          origin='lower', cmap='Reds', aspect='auto')
    axes[2].set_title('|Φ(S×T) − (Φ(S)+Φ(T))|', fontsize=12)
    axes[2].set_xlabel('|S|')
    axes[2].set_ylabel('|T|')
    plt.colorbar(im3, ax=axes[2], label='absolute error')

    fig.suptitle('Tensorization Law: Φ(S × T) = Φ(S) + Φ(T)', fontsize=14, y=1.02)
    fig.tight_layout()
    fig.savefig('viz_tensorization.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def viz_n_fold():
    """Visualize n-fold amplification for different base sizes."""
    fig, ax = plt.subplots(figsize=(8, 5))

    for card_S in [2, 3, 5, 7, 10]:
        ns = np.arange(1, 21)
        phi_values = ns * np.log(card_S)
        ax.plot(ns, phi_values, 'o-', label=f'|S| = {card_S}', markersize=4)

    ax.set_xlabel('Number of copies n', fontsize=12)
    ax.set_ylabel('Φ(S^n) = n · log|S|', fontsize=12)
    ax.set_title('N-fold Tropical Amplification Law', fontsize=14)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig('viz_n_fold.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def viz_exponential_growth():
    """Visualize exponential state growth exp(Φ(S^n)) = |S|^n."""
    fig, ax = plt.subplots(figsize=(8, 5))

    for card_S in [2, 3, 5]:
        ns = np.arange(1, 16)
        state_counts = card_S ** ns.astype(float)
        ax.semilogy(ns, state_counts, 'o-', label=f'|S| = {card_S}', markersize=5)

    ax.set_xlabel('Number of copies n', fontsize=12)
    ax.set_ylabel('exp(Φ(S^n)) = |S|^n', fontsize=12)
    ax.set_title('Exponential Multiplicativity: State Space Growth', fontsize=14)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3, which='both')
    fig.tight_layout()
    fig.savefig('viz_exponential_growth.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def viz_perturbation_stability():
    """Visualize compositional perturbation stability."""
    fig, ax = plt.subplots(figsize=(8, 5))

    np.random.seed(42)
    n_trials = 200
    eps1_vals = np.random.uniform(0, 1, n_trials)
    eps2_vals = np.random.uniform(0, 1, n_trials)

    actual_errors = []
    for i in range(n_trials):
        n_S, n_T = 10, 8
        w1 = np.random.randn(n_S)
        w2 = np.random.randn(n_T)
        d1 = np.random.uniform(-eps1_vals[i], eps1_vals[i], n_S)
        d2 = np.random.uniform(-eps2_vals[i], eps2_vals[i], n_T)
        max_err = 0
        for s in range(n_S):
            for t in range(n_T):
                err = abs(d1[s] + d2[t])
                max_err = max(max_err, err)
        actual_errors.append(max_err)

    bounds = eps1_vals + eps2_vals
    actual_errors = np.array(actual_errors)

    ax.scatter(bounds, actual_errors, alpha=0.5, s=20, c='steelblue')
    max_val = max(bounds.max(), actual_errors.max()) * 1.1
    ax.plot([0, max_val], [0, max_val], 'r--', linewidth=2, label='bound = ε₁ + ε₂')
    ax.set_xlabel('Predicted bound ε₁ + ε₂', fontsize=12)
    ax.set_ylabel('Actual max product error', fontsize=12)
    ax.set_title('Compositional Perturbation Stability', fontsize=14)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig('viz_perturbation_stability.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


if __name__ == "__main__":
    print("Generating visualizations...")
    b64_tensor = viz_tensorization()
    print(f"  Tensorization heatmap: {len(b64_tensor)} chars")
    b64_nfold = viz_n_fold()
    print(f"  N-fold amplification: {len(b64_nfold)} chars")
    b64_exp = viz_exponential_growth()
    print(f"  Exponential growth: {len(b64_exp)} chars")
    b64_pert = viz_perturbation_stability()
    print(f"  Perturbation stability: {len(b64_pert)} chars")
    print("All visualizations generated.")

    # Save base64 data for PACKAGE.json
    viz_data = {
        "tensorization": b64_tensor,
        "n_fold": b64_nfold,
        "exponential_growth": b64_exp,
        "perturbation_stability": b64_pert
    }
    with open("viz_data.json", "w") as f:
        json.dump(viz_data, f)
    print("Visualization data saved to viz_data.json")

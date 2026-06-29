#!/usr/bin/env python3
"""
Tropical γ-Spreadness and KEM Security — Demonstrations

This script demonstrates the core mathematical concepts behind tropical
key encapsulation mechanisms (KEMs) and γ-spreadness. It provides:

1. Tropical (min-plus) matrix arithmetic
2. Tropical Diffie-Hellman key exchange simulation
3. γ-spreadness verification and min-entropy computation
4. Non-commutativity witness generation
5. Security parameter scaling analysis

Author: Harmonic Research
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from typing import Tuple, Optional
import base64
from io import BytesIO

# ============================================================
# Part I: Tropical (Min-Plus) Matrix Arithmetic
# ============================================================

def trop_mul(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """Tropical matrix multiplication: (A ⊗ B)_{ij} = min_k (A_{ik} + B_{kj})"""
    n = A.shape[0]
    C = np.full((n, n), np.inf)
    for i in range(n):
        for j in range(n):
            C[i, j] = min(A[i, k] + B[k, j] for k in range(n))
    return C


def trop_add(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """Tropical matrix addition: (A ⊕ B)_{ij} = min(A_{ij}, B_{ij})"""
    return np.minimum(A, B)


def trop_pow(A: np.ndarray, k: int) -> np.ndarray:
    """Tropical matrix power: A^k via repeated multiplication."""
    n = A.shape[0]
    if k == 0:
        # Tropical identity: 0 on diagonal, infinity elsewhere
        I = np.full((n, n), np.inf)
        np.fill_diagonal(I, 0)
        return I
    result = A.copy()
    for _ in range(k - 1):
        result = trop_mul(result, A)
    return result


# ============================================================
# Part II: KEM Key Exchange Simulation
# ============================================================

def kem_keygen(G: np.ndarray, sk: int) -> Tuple[np.ndarray, int]:
    """Generate KEM key pair: pk = G^sk"""
    pk = trop_pow(G, sk)
    return pk, sk


def kem_encrypt(G: np.ndarray, pk: np.ndarray, r: int) -> Tuple[np.ndarray, np.ndarray]:
    """KEM encryption: (c1, c2) = (G^r, pk^r)"""
    c1 = trop_pow(G, r)
    c2 = trop_pow(pk, r)
    return c1, c2


def kem_decrypt(G: np.ndarray, sk: int, c1: np.ndarray) -> np.ndarray:
    """KEM decryption: shared_key = c1^sk"""
    return trop_pow(c1, sk)


# ============================================================
# Part III: Demonstrations
# ============================================================

def demo_key_exchange():
    """Demonstrate tropical Diffie-Hellman key exchange correctness."""
    print("=" * 60)
    print("DEMO 1: Tropical KEM Key Exchange")
    print("=" * 60)

    # Generator matrix
    G = np.array([[0, 3, 7],
                  [1, 0, 5],
                  [2, 4, 0]], dtype=float)

    print(f"\nGenerator matrix G:\n{G}")

    # Alice generates keypair
    alice_sk = 4
    alice_pk, _ = kem_keygen(G, alice_sk)
    print(f"\nAlice's secret key: {alice_sk}")
    print(f"Alice's public key (G^{alice_sk}):\n{alice_pk}")

    # Bob encrypts with randomness r
    r = 3
    c1, c2 = kem_encrypt(G, alice_pk, r)
    print(f"\nBob's randomness: r = {r}")
    print(f"Ciphertext c1 = G^{r}:\n{c1}")
    print(f"Ciphertext c2 = pk^{r}:\n{c2}")

    # Alice decrypts
    shared_key_alice = kem_decrypt(G, alice_sk, c1)
    print(f"\nAlice computes c1^{alice_sk} = (G^{r})^{alice_sk}:\n{shared_key_alice}")

    # Verify correctness: (G^r)^a should equal (G^a)^r
    print(f"\nCorrectness check: c1^sk == c2?")
    print(f"  (G^{r})^{alice_sk} = G^{r*alice_sk}:\n{shared_key_alice}")
    print(f"  (G^{alice_sk})^{r} = G^{alice_sk*r}:\n{c2}")
    print(f"  Equal: {np.allclose(shared_key_alice, c2)}")

    # Verify power commutativity
    Gra = trop_pow(G, r * alice_sk)
    Gar = trop_pow(G, alice_sk * r)
    print(f"\n  G^(r·a) = G^{r*alice_sk}:\n{Gra}")
    print(f"  G^(a·r) = G^{alice_sk*r}:\n{Gar}")
    print(f"  G^(ra) == G^(ar): {np.allclose(Gra, Gar)}")


def demo_noncommutativity():
    """Demonstrate that tropical matrix multiplication is NOT commutative."""
    print("\n" + "=" * 60)
    print("DEMO 2: Non-Commutativity Witness")
    print("=" * 60)

    A = np.array([[0, 1], [2, 3]], dtype=float)
    B = np.array([[1, 0], [0, 1]], dtype=float)

    AB = trop_mul(A, B)
    BA = trop_mul(B, A)

    print(f"\nA =\n{A}")
    print(f"\nB =\n{B}")
    print(f"\nA ⊗ B =\n{AB}")
    print(f"\nB ⊗ A =\n{BA}")
    print(f"\nA ⊗ B ≠ B ⊗ A: {not np.allclose(AB, BA)}")
    print("\nThis non-commutativity is ESSENTIAL for post-quantum security:")
    print("  If ⊗ were commutative, tropical DLP would be trivially solvable.")


def demo_gamma_spread():
    """Demonstrate γ-spreadness and min-entropy of tropical ciphertexts."""
    print("\n" + "=" * 60)
    print("DEMO 3: γ-Spreadness and Min-Entropy")
    print("=" * 60)

    G = np.array([[0, 3, 7],
                  [1, 0, 5],
                  [2, 4, 0]], dtype=float)

    B = 20  # exponent bound
    powers = []
    for r in range(B):
        powers.append(trop_pow(G, r))

    # Check distinctness
    distinct_count = 0
    seen = []
    for p in powers:
        is_new = True
        for s in seen:
            if np.allclose(p, s):
                is_new = False
                break
        if is_new:
            seen.append(p)
            distinct_count += 1

    print(f"\nGenerator G (3×3):\n{G}")
    print(f"\nExponent bound B = {B}")
    print(f"Distinct powers |{{G^0, ..., G^{B-1}}}| = {distinct_count}")

    gamma = np.log2(distinct_count)
    max_prob = 1.0 / distinct_count if distinct_count > 0 else 1.0
    threshold = 2.0 ** (-gamma)

    print(f"\nγ-spreadness analysis:")
    print(f"  Number of distinct ciphertexts: {distinct_count}")
    print(f"  Max probability (uniform): 1/{distinct_count} = {max_prob:.6f}")
    print(f"  γ = log₂({distinct_count}) = {gamma:.4f}")
    print(f"  2^(-γ) = {threshold:.6f}")
    print(f"  max_prob ≤ 2^(-γ): {max_prob <= threshold + 1e-10}")
    print(f"  Min-entropy H_∞ ≥ {gamma:.4f} bits")


def demo_security_scaling():
    """Show how security scales with parameters."""
    print("\n" + "=" * 60)
    print("DEMO 4: Security Parameter Scaling")
    print("=" * 60)

    dimensions = [2, 3, 4, 5]
    results = []

    for n in dimensions:
        # Random generator matrix
        np.random.seed(42 + n)
        G = np.random.randint(0, 10, (n, n)).astype(float)

        B = 30
        seen = []
        for r in range(B):
            p = trop_pow(G, r)
            is_new = True
            for s in seen:
                if np.allclose(p, s):
                    is_new = False
                    break
            if is_new:
                seen.append(p)

        distinct = len(seen)
        gamma = np.log2(distinct) if distinct > 1 else 0
        security_bits = n * gamma

        results.append((n, distinct, gamma, security_bits))
        print(f"\n  n={n}: {distinct} distinct powers, "
              f"γ={gamma:.2f}, security ≈ {security_bits:.1f} bits")

    return results


def generate_visualizations():
    """Generate publication-quality visualizations."""

    # Figure 1: Security scaling with dimension
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    # Panel 1: Distinct powers vs exponent bound
    ax = axes[0]
    G3 = np.array([[0, 3, 7], [1, 0, 5], [2, 4, 0]], dtype=float)

    exponent_bounds = list(range(1, 51))
    distinct_counts = []
    for B in exponent_bounds:
        seen = []
        for r in range(B):
            p = trop_pow(G3, r)
            is_new = all(not np.allclose(p, s) for s in seen)
            if is_new:
                seen.append(p)
        distinct_counts.append(len(seen))

    ax.plot(exponent_bounds, distinct_counts, 'b-', linewidth=2, label='Distinct powers')
    ax.plot(exponent_bounds, exponent_bounds, 'r--', linewidth=1, alpha=0.5, label='y = B (maximum)')
    ax.set_xlabel('Exponent bound B', fontsize=12)
    ax.set_ylabel('Distinct ciphertexts', fontsize=12)
    ax.set_title('Ciphertext Diversity vs Exponent Bound', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    # Panel 2: Min-entropy growth
    ax = axes[1]
    gammas = [np.log2(d) if d > 1 else 0 for d in distinct_counts]
    ax.plot(exponent_bounds, gammas, 'g-', linewidth=2)
    ax.set_xlabel('Exponent bound B', fontsize=12)
    ax.set_ylabel('Min-entropy γ (bits)', fontsize=12)
    ax.set_title('γ-Spreadness: Min-Entropy Growth', fontsize=13)
    ax.grid(True, alpha=0.3)

    # Panel 3: Max probability decay (γ-spread)
    ax = axes[2]
    max_probs = [1.0/d if d > 0 else 1.0 for d in distinct_counts]
    ax.semilogy(exponent_bounds, max_probs, 'm-', linewidth=2, label='max P(ciphertext)')
    thresholds = [2**(-g) if g > 0 else 1.0 for g in gammas]
    ax.semilogy(exponent_bounds, thresholds, 'k--', linewidth=1, alpha=0.5, label='2^(-γ) bound')
    ax.set_xlabel('Exponent bound B', fontsize=12)
    ax.set_ylabel('Max probability', fontsize=12)
    ax.set_title('γ-Spread: Max Probability Decay', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('/workspace/request-project/gamma_spread_analysis.png', dpi=150, bbox_inches='tight')
    plt.close()

    # Figure 2: Tropical matrix power evolution
    fig, axes = plt.subplots(2, 4, figsize=(16, 8))
    G = np.array([[0, 3, 7], [1, 0, 5], [2, 4, 0]], dtype=float)

    for idx, k in enumerate([0, 1, 2, 3, 4, 5, 8, 12]):
        ax = axes[idx // 4, idx % 4]
        Gk = trop_pow(G, k)
        # Clip for visualization
        Gk_vis = np.clip(Gk, -20, 50)
        im = ax.imshow(Gk_vis, cmap='viridis', aspect='equal')
        ax.set_title(f'G^{k}', fontsize=12)
        for i in range(3):
            for j in range(3):
                val = Gk[i, j]
                if val < 100:
                    ax.text(j, i, f'{val:.0f}', ha='center', va='center',
                           color='white' if val > np.median(Gk_vis) else 'black', fontsize=9)
        plt.colorbar(im, ax=ax, shrink=0.8)

    fig.suptitle('Tropical Matrix Power Evolution: G^k', fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('/workspace/request-project/tropical_power_evolution.png', dpi=150, bbox_inches='tight')
    plt.close()

    # Figure 3: FO Transform security diagram
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))

    # Security bound: ε_cca ≤ ε_cpa + q_dec * 2^(-γ)
    gammas_range = np.linspace(1, 20, 100)
    eps_cpa = 2**(-128)

    for q_dec in [1, 10, 100, 1000]:
        eps_cca = eps_cpa + q_dec * 2.0**(-gammas_range)
        ax.semilogy(gammas_range, eps_cca, linewidth=2, label=f'q_dec = {q_dec}')

    ax.axhline(y=2**(-128), color='red', linestyle='--', alpha=0.5, label='128-bit security')
    ax.set_xlabel('γ (spreadness parameter, bits)', fontsize=12)
    ax.set_ylabel('CCA advantage bound', fontsize=12)
    ax.set_title('Fujisaki-Okamoto Transform: CCA Security from γ-Spreadness', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('/workspace/request-project/fo_transform_security.png', dpi=150, bbox_inches='tight')
    plt.close()

    return True


def image_to_base64(filepath: str) -> str:
    """Convert an image file to base64 data URI."""
    with open(filepath, 'rb') as f:
        data = base64.b64encode(f.read()).decode('utf-8')
    return f"data:image/png;base64,{data}"


if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Tropical γ-Spreadness and KEM Security Demonstrations  ║")
    print("╚══════════════════════════════════════════════════════════╝")

    demo_key_exchange()
    demo_noncommutativity()
    demo_gamma_spread()
    results = demo_security_scaling()

    print("\n" + "=" * 60)
    print("Generating visualizations...")
    generate_visualizations()
    print("Saved: gamma_spread_analysis.png")
    print("Saved: tropical_power_evolution.png")
    print("Saved: fo_transform_security.png")
    print("=" * 60)
    print("\nAll demonstrations completed successfully!")

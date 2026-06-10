#!/usr/bin/env python3
"""
Transformer Architecture: Mathematical Properties Demonstration

Demonstrates the key theorems proved in the Lean formalization:
1. Softmax shift invariance
2. Softmax as probability distribution
3. Attention score bilinearity
4. Gram matrix factorization
5. Layer normalization centering
6. Softmax monotonicity
"""

import numpy as np

np.set_printoptions(precision=8, suppress=True)


def softmax(x: np.ndarray) -> np.ndarray:
    """Softmax function on a vector."""
    e = np.exp(x - np.max(x))  # shift for numerical stability (exact by Theorem 1)
    return e / e.sum()


def attention_score(Wq: np.ndarray, Wk: np.ndarray, xi: np.ndarray, xj: np.ndarray) -> float:
    """Compute attention score: (Wq·xi)ᵀ(Wk·xj)."""
    return float(np.dot(Wq @ xi, Wk @ xj))


def gram_matrix(Wq: np.ndarray, Wk: np.ndarray) -> np.ndarray:
    """Compute the Gram matrix G = WqᵀWk."""
    return Wq.T @ Wk


def layer_norm(x: np.ndarray, gamma: np.ndarray = None, beta: np.ndarray = None) -> np.ndarray:
    """Layer normalization."""
    mean = x.mean()
    var = ((x - mean) ** 2).mean()
    x_norm = (x - mean) / np.sqrt(var + 1e-12)
    if gamma is not None and beta is not None:
        return gamma * x_norm + beta
    return x_norm


def demo_shift_invariance():
    """Demonstrate Theorem 1: Softmax shift invariance."""
    print("=" * 60)
    print("THEOREM 1: Softmax Shift Invariance")
    print("σ(x + c·1) = σ(x) for all c ∈ ℝ")
    print("=" * 60)

    x = np.array([1.0, 2.5, -0.3, 4.1, 0.7])
    shifts = [0, 100, -100, 1e6, -1e6, np.pi]

    print(f"\nInput vector x = {x}")
    base = softmax(x)
    print(f"softmax(x) = {base}")

    for c in shifts:
        shifted = softmax(x + c)
        error = np.max(np.abs(shifted - base))
        print(f"  c = {c:>12.4f}  |  max|σ(x+c) - σ(x)| = {error:.2e}")

    print("\n✓ Shift invariance verified numerically (machine precision errors only)")


def demo_probability_distribution():
    """Demonstrate Theorem 2: Softmax outputs sum to 1."""
    print("\n" + "=" * 60)
    print("THEOREM 2: Softmax as Probability Distribution")
    print("∑ᵢ σ(x)ᵢ = 1 and σ(x)ᵢ > 0")
    print("=" * 60)

    test_vectors = [
        np.array([0.0, 0.0, 0.0]),
        np.array([1.0, 2.0, 3.0]),
        np.array([-10.0, 0.0, 10.0]),
        np.random.randn(100),
    ]

    for i, x in enumerate(test_vectors):
        s = softmax(x)
        print(f"\nVector {i+1} (dim={len(x)}): sum = {s.sum():.15f}, "
              f"min = {s.min():.2e}, all positive: {np.all(s > 0)}")

    print("\n✓ Probability distribution property verified")


def demo_bilinearity():
    """Demonstrate Theorem 3: Attention score bilinearity."""
    print("\n" + "=" * 60)
    print("THEOREM 3: Attention Score Bilinearity")
    print("score(ax + by, z) = a·score(x,z) + b·score(y,z)")
    print("=" * 60)

    d, dk = 4, 3
    Wq = np.random.randn(dk, d)
    Wk = np.random.randn(dk, d)
    x = np.random.randn(d)
    y = np.random.randn(d)
    z = np.random.randn(d)
    a, b = 2.5, -1.3

    # Left linearity
    lhs = attention_score(Wq, Wk, a * x + b * y, z)
    rhs = a * attention_score(Wq, Wk, x, z) + b * attention_score(Wq, Wk, y, z)
    print(f"\nLeft linearity:  LHS = {lhs:.10f},  RHS = {rhs:.10f},  |diff| = {abs(lhs - rhs):.2e}")

    # Right linearity
    lhs = attention_score(Wq, Wk, z, a * x + b * y)
    rhs = a * attention_score(Wq, Wk, z, x) + b * attention_score(Wq, Wk, z, y)
    print(f"Right linearity: LHS = {lhs:.10f},  RHS = {rhs:.10f},  |diff| = {abs(lhs - rhs):.2e}")

    print("\n✓ Bilinearity verified numerically")


def demo_gram_factorization():
    """Demonstrate Theorem 6: Gram matrix factorization."""
    print("\n" + "=" * 60)
    print("THEOREM 6: Gram Matrix Factorization")
    print("score(xi, xj) = xiᵀ · (WqᵀWk) · xj")
    print("=" * 60)

    d, dk = 5, 3
    Wq = np.random.randn(dk, d)
    Wk = np.random.randn(dk, d)
    xi = np.random.randn(d)
    xj = np.random.randn(d)

    # Direct computation
    score_direct = attention_score(Wq, Wk, xi, xj)

    # Via Gram matrix
    G = gram_matrix(Wq, Wk)
    score_gram = float(xi @ G @ xj)

    print(f"\nDirect: score = {score_direct:.10f}")
    print(f"Gram:   score = {score_gram:.10f}")
    print(f"|diff| = {abs(score_direct - score_gram):.2e}")

    # Eigenvalue analysis
    eigenvalues = np.linalg.eigvals(G)
    print(f"\nGram matrix eigenvalues: {np.sort(np.real(eigenvalues))[::-1]}")
    print(f"Rank of G: {np.linalg.matrix_rank(G)} (max possible: {dk})")

    print("\n✓ Gram factorization verified numerically")


def demo_layer_norm_centering():
    """Demonstrate Theorem 5: Layer normalization centering."""
    print("\n" + "=" * 60)
    print("THEOREM 5: Layer Normalization Centering")
    print("mean(x - mean(x)) = 0")
    print("=" * 60)

    for n in [3, 10, 100, 1000]:
        x = np.random.randn(n) * 10 + 5  # arbitrary mean and scale
        centered = x - x.mean()
        print(f"  n={n:>4d}: mean(x) = {x.mean():>10.4f}, "
              f"mean(centered) = {centered.mean():.2e}, "
              f"mean(layernorm) = {layer_norm(x).mean():.2e}")

    print("\n✓ Centering property verified numerically")


def demo_monotonicity():
    """Demonstrate Theorem 8: Softmax monotonicity."""
    print("\n" + "=" * 60)
    print("THEOREM 8: Softmax Monotonicity")
    print("xᵢ ≤ xⱼ ⟹ σ(x)ᵢ ≤ σ(x)ⱼ")
    print("=" * 60)

    x = np.array([1.0, 2.0, 3.0, 4.0, 5.0])
    s = softmax(x)
    print(f"\nx = {x}")
    print(f"σ(x) = {s}")
    print(f"σ(x) is sorted: {np.all(np.diff(s) >= 0)}")

    # Random test
    n_tests = 10000
    violations = 0
    for _ in range(n_tests):
        x = np.random.randn(10)
        s = softmax(x)
        sorted_x = np.argsort(x)
        sorted_s = np.argsort(s)
        if not np.array_equal(sorted_x, sorted_s):
            violations += 1
    print(f"\nRandom tests: {violations}/{n_tests} ordering violations")

    print("\n✓ Monotonicity verified numerically")


if __name__ == "__main__":
    np.random.seed(42)
    demo_shift_invariance()
    demo_probability_distribution()
    demo_bilinearity()
    demo_gram_factorization()
    demo_layer_norm_centering()
    demo_monotonicity()

    print("\n" + "=" * 60)
    print("ALL DEMONSTRATIONS COMPLETE")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Softmax Shift Invariance and Attention Geometry

Standalone matplotlib visualization demonstrating key theorems
from the transformer architecture formalization.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec


def softmax(x):
    e = np.exp(x - np.max(x))
    return e / e.sum()


def attention_score_matrix(Wq, Wk, X):
    Q = X @ Wq.T
    K = X @ Wk.T
    return Q @ K.T / np.sqrt(Wq.shape[0])


def main():
    np.random.seed(42)
    fig = plt.figure(figsize=(16, 12))
    gs = GridSpec(2, 2, figure=fig, hspace=0.35, wspace=0.3)

    # Panel 1: Softmax shift invariance
    ax1 = fig.add_subplot(gs[0, 0])
    x = np.array([1.0, 2.5, -0.3, 4.1, 0.7])
    shifts = np.linspace(-10, 10, 100)
    for i in range(len(x)):
        values = [softmax(x + c)[i] for c in shifts]
        ax1.plot(shifts, values, label=f'σ(x+c)_{i}', linewidth=2)
    ax1.set_xlabel('Shift c', fontsize=12)
    ax1.set_ylabel('Softmax output', fontsize=12)
    ax1.set_title('Theorem 1: Softmax Shift Invariance\nσ(x + c·1) = σ(x)', fontsize=13, fontweight='bold')
    ax1.legend(fontsize=9)
    ax1.grid(True, alpha=0.3)

    # Panel 2: Softmax as probability distribution
    ax2 = fig.add_subplot(gs[0, 1])
    temperatures = np.linspace(0.1, 5.0, 50)
    x = np.array([1.0, 3.0, 2.0, 0.5, 4.0])
    for temp in [0.2, 0.5, 1.0, 2.0, 5.0]:
        s = softmax(x / temp)
        ax2.bar(np.arange(len(x)) + (temp - 1) * 0.15, s, width=0.15,
                label=f'τ={temp}', alpha=0.8)
    ax2.set_xlabel('Index i', fontsize=12)
    ax2.set_ylabel('σ(x/τ)ᵢ', fontsize=12)
    ax2.set_title('Theorem 2: Softmax → Simplex\n∑ᵢ σ(x)ᵢ = 1, σ(x)ᵢ > 0', fontsize=13, fontweight='bold')
    ax2.legend(fontsize=9)
    ax2.grid(True, alpha=0.3)

    # Panel 3: Gram matrix eigenvalues
    ax3 = fig.add_subplot(gs[1, 0])
    d, dk = 8, 4
    n_samples = 50
    all_eigenvalues = []
    for _ in range(n_samples):
        Wq = np.random.randn(dk, d) * 0.5
        Wk = np.random.randn(dk, d) * 0.5
        G = Wq.T @ Wk
        eigs = np.sort(np.abs(np.linalg.eigvals(G)))[::-1]
        all_eigenvalues.append(eigs)
    all_eigenvalues = np.array(all_eigenvalues)
    mean_eigs = all_eigenvalues.mean(axis=0)
    std_eigs = all_eigenvalues.std(axis=0)
    ax3.errorbar(range(d), mean_eigs, yerr=std_eigs, fmt='o-', capsize=5,
                 color='#e74c3c', linewidth=2, markersize=8)
    ax3.axhline(y=0, color='gray', linestyle='--', alpha=0.5)
    ax3.set_xlabel('Eigenvalue index', fontsize=12)
    ax3.set_ylabel('|λᵢ| (mean ± std)', fontsize=12)
    ax3.set_title(f'Theorem 6: Gram Matrix Spectrum\nG = WqᵀWk ∈ ℝ^{{{d}×{d}}}, rank ≤ {dk}',
                  fontsize=13, fontweight='bold')
    ax3.grid(True, alpha=0.3)

    # Panel 4: Attention heatmap
    ax4 = fig.add_subplot(gs[1, 1])
    seq_len, d = 6, 8
    X = np.random.randn(seq_len, d)
    Wq = np.random.randn(4, d) * 0.5
    Wk = np.random.randn(4, d) * 0.5
    scores = attention_score_matrix(Wq, Wk, X)
    weights = np.array([softmax(scores[i]) for i in range(seq_len)])
    im = ax4.imshow(weights, cmap='YlOrRd', aspect='auto')
    ax4.set_xlabel('Key position j', fontsize=12)
    ax4.set_ylabel('Query position i', fontsize=12)
    ax4.set_title('Attention Weights\nσ(xᵢᵀ G xⱼ / √dₖ)', fontsize=13, fontweight='bold')
    plt.colorbar(im, ax=ax4, shrink=0.8)
    tokens = [f'tok_{i}' for i in range(seq_len)]
    ax4.set_xticks(range(seq_len))
    ax4.set_xticklabels(tokens, fontsize=9)
    ax4.set_yticks(range(seq_len))
    ax4.set_yticklabels(tokens, fontsize=9)

    fig.suptitle('Mathematical Foundations of the Transformer Architecture',
                 fontsize=16, fontweight='bold', y=0.98)
    plt.savefig('transformer_theorems.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: transformer_theorems.png")


if __name__ == "__main__":
    main()

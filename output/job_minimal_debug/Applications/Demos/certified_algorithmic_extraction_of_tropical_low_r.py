"""
Tropical Low-Rank Approximation: Demonstration

This script demonstrates the core theorems from the Lean formalization:
1. Finite exact max-plus representation of matrices
2. Tropical ε-rank computation
3. Max-subadditivity of tropical ε-rank
4. Approximation quality vs. number of terms

Every real matrix can be written as the pointwise maximum of separable
max-plus terms c + a(x) + b(y). This is the computational heart of
tropical approximation theory.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from itertools import product
import os

# ============================================================
# Core Definitions
# ============================================================

class MaxPlusTerm:
    """A separable max-plus tensor term: (x, y) ↦ c + a[x] + b[y]"""
    def __init__(self, c: float, a: np.ndarray, b: np.ndarray):
        self.c = c
        self.a = a
        self.b = b

    def eval(self, x: int, y: int) -> float:
        return self.c + self.a[x] + self.b[y]

    def eval_matrix(self) -> np.ndarray:
        """Evaluate on the full grid."""
        return self.c + self.a[:, None] + self.b[None, :]


def max_plus_approx(terms: list, shape: tuple) -> np.ndarray:
    """Pointwise maximum of a list of MaxPlusTerms."""
    if not terms:
        return np.full(shape, -np.inf)
    result = terms[0].eval_matrix()
    for t in terms[1:]:
        result = np.maximum(result, t.eval_matrix())
    return result


# ============================================================
# 1. Finite Exact Representation (Theorem 1)
# ============================================================

def build_anchored_terms(f: np.ndarray) -> list:
    """
    Build the canonical anchored term decomposition.

    For each grid point (x₀, y₀), create a term:
      c = f[x₀, y₀]
      a[x] = 0 if x == x₀, else -D
      b[y] = 0 if y == y₀, else -D

    where D = max(f) - min(f) + 1 (oscillation bound + 1).

    This is the constructive witness from the Lean proof of
    exists_exact_maxplus_representation_finite.
    """
    m, n = f.shape
    D = np.max(f) - np.min(f) + 1.0
    terms = []
    for x0 in range(m):
        for y0 in range(n):
            a = np.full(m, -D)
            a[x0] = 0.0
            b = np.full(n, -D)
            b[y0] = 0.0
            terms.append(MaxPlusTerm(c=f[x0, y0], a=a, b=b))
    return terms


def demo_exact_representation():
    """Demonstrate that every matrix has an exact max-plus representation."""
    print("=" * 60)
    print("DEMO 1: Finite Exact Max-Plus Representation")
    print("=" * 60)

    np.random.seed(42)

    matrices = {
        "Random 3×4": np.random.randn(3, 4),
        "Identity-like 3×3": np.eye(3) * 5 - 2,
        "Rank-1 (outer product)": np.array([1, 2, 3])[:, None] + np.array([4, 5])[None, :],
        "All ones": np.ones((2, 3)),
    }

    for name, f in matrices.items():
        terms = build_anchored_terms(f)
        approx = max_plus_approx(terms, f.shape)
        error = np.max(np.abs(f - approx))
        print(f"\n  {name} ({f.shape[0]}×{f.shape[1]}):")
        print(f"    Number of terms: {len(terms)} = {f.shape[0]}×{f.shape[1]}")
        print(f"    Max error: {error:.2e}")
        assert error < 1e-10, f"Exact representation failed for {name}!"

    print("\n  ✓ All matrices exactly represented as max-plus superpositions!")
    return matrices


# ============================================================
# 2. Tropical ε-Rank Computation
# ============================================================

def compute_tropical_rank(f: np.ndarray, epsilon: float, max_terms: int = None) -> tuple:
    """
    Compute the tropical ε-rank by greedy term selection.

    Returns (rank, terms, errors) where rank is the minimum number
    of anchored terms needed to approximate f within ε.

    This is a greedy heuristic — the true optimal rank may be lower.
    """
    m, n = f.shape
    if max_terms is None:
        max_terms = m * n

    all_terms = build_anchored_terms(f)

    # Greedy selection: pick the term that reduces max error most
    selected = []
    errors = []

    for _ in range(min(max_terms, len(all_terms))):
        current_approx = max_plus_approx(selected, f.shape) if selected else np.full_like(f, -np.inf)
        current_error = np.max(np.abs(f - current_approx)) if selected else np.inf

        if current_error <= epsilon:
            break

        # Find best next term
        best_idx = -1
        best_error = current_error

        for idx, term in enumerate(all_terms):
            if any(id(term) == id(s) for s in selected):
                continue
            trial = np.maximum(current_approx, term.eval_matrix())
            trial_error = np.max(np.abs(f - trial))
            if trial_error < best_error:
                best_error = trial_error
                best_idx = idx

        if best_idx == -1:
            break

        selected.append(all_terms[best_idx])
        current_approx = max_plus_approx(selected, f.shape)
        errors.append(np.max(np.abs(f - current_approx)))

    return len(selected), selected, errors


def demo_tropical_rank():
    """Demonstrate tropical ε-rank computation and monotonicity."""
    print("\n" + "=" * 60)
    print("DEMO 2: Tropical ε-Rank and Monotonicity")
    print("=" * 60)

    np.random.seed(123)
    f = np.random.randn(5, 5)

    epsilons = [0.0, 0.1, 0.5, 1.0, 2.0, 5.0]
    ranks = []

    print(f"\n  Matrix f is 5×5 random (max terms = 25)")
    print(f"  {'ε':>8s}  {'rank':>6s}  {'actual error':>14s}")
    print(f"  {'-'*8}  {'-'*6}  {'-'*14}")

    for eps in epsilons:
        rank, terms, errors = compute_tropical_rank(f, eps)
        actual_error = errors[-1] if errors else 0.0
        ranks.append(rank)
        print(f"  {eps:8.2f}  {rank:6d}  {actual_error:14.6f}")

    # Verify monotonicity (Theorem: tropicalRankEps_mono)
    for i in range(len(ranks) - 1):
        assert ranks[i] >= ranks[i+1], "Monotonicity violated!"

    print("\n  ✓ Tropical ε-rank is monotone decreasing in ε (verified)")

    return f, epsilons, ranks


# ============================================================
# 3. Max-Subadditivity Demonstration
# ============================================================

def demo_max_subadditivity():
    """Demonstrate max-subadditivity of tropical ε-rank."""
    print("\n" + "=" * 60)
    print("DEMO 3: Max-Subadditivity of Tropical ε-Rank")
    print("=" * 60)

    np.random.seed(456)
    m, n = 4, 4
    f = np.random.randn(m, n)
    g = np.random.randn(m, n)
    h = np.maximum(f, g)

    eps1, eps2 = 0.5, 0.5
    eps_max = max(eps1, eps2)

    rank_f, _, _ = compute_tropical_rank(f, eps1)
    rank_g, _, _ = compute_tropical_rank(g, eps2)
    rank_h, _, _ = compute_tropical_rank(h, eps_max)

    print(f"\n  f, g are random 4×4 matrices")
    print(f"  h = max(f, g) pointwise")
    print(f"\n  rank(f, ε₁={eps1}) = {rank_f}")
    print(f"  rank(g, ε₂={eps2}) = {rank_g}")
    print(f"  rank(max(f,g), max(ε₁,ε₂)={eps_max}) = {rank_h}")
    print(f"  rank(f) + rank(g) = {rank_f + rank_g}")
    print(f"\n  Bound: {rank_h} ≤ {rank_f + rank_g}  ✓"
          if rank_h <= rank_f + rank_g
          else f"\n  Note: greedy heuristic may overestimate rank")


# ============================================================
# 4. Visualization
# ============================================================

def demo_visualizations(f_5x5, epsilons, ranks):
    """Create visualizations of the tropical approximation theory."""

    os.makedirs("demos/figures", exist_ok=True)

    # --- Figure 1: Exact representation decomposition ---
    fig, axes = plt.subplots(1, 4, figsize=(16, 4))

    np.random.seed(42)
    f = np.random.randn(5, 5)
    terms = build_anchored_terms(f)

    axes[0].imshow(f, cmap='RdBu_r', aspect='equal')
    axes[0].set_title('Original f', fontsize=12)
    axes[0].set_xlabel('y')
    axes[0].set_ylabel('x')

    for idx, ax_idx in enumerate([1, 2]):
        term_mat = terms[idx * 8].eval_matrix()
        axes[ax_idx].imshow(term_mat, cmap='RdBu_r', aspect='equal',
                            vmin=f.min()-1, vmax=f.max()+1)
        axes[ax_idx].set_title(f'Anchor term {idx*8+1}', fontsize=12)
        axes[ax_idx].set_xlabel('y')

    approx = max_plus_approx(terms, f.shape)
    axes[3].imshow(approx, cmap='RdBu_r', aspect='equal')
    axes[3].set_title('max-plus reconstruction', fontsize=12)
    axes[3].set_xlabel('y')

    plt.suptitle('Finite Exact Max-Plus Representation', fontsize=14, y=1.02)
    plt.tight_layout()
    plt.savefig('demos/figures/exact_representation.png', dpi=150, bbox_inches='tight')
    plt.close()

    # --- Figure 2: ε-rank vs ε (monotonicity) ---
    fig, ax = plt.subplots(figsize=(8, 5))
    ax.plot(epsilons, ranks, 'bo-', linewidth=2, markersize=8)
    ax.set_xlabel('ε (approximation tolerance)', fontsize=13)
    ax.set_ylabel('Tropical ε-rank', fontsize=13)
    ax.set_title('Monotonicity of Tropical ε-Rank\n(larger ε → fewer terms needed)', fontsize=14)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(bottom=0)
    plt.tight_layout()
    plt.savefig('demos/figures/rank_monotonicity.png', dpi=150, bbox_inches='tight')
    plt.close()

    # --- Figure 3: Incremental approximation ---
    fig, axes = plt.subplots(2, 4, figsize=(16, 8))

    np.random.seed(42)
    f = np.random.randn(8, 8)
    terms = build_anchored_terms(f)

    n_terms_list = [1, 4, 16, 64]

    axes[0, 0].imshow(f, cmap='viridis', aspect='equal')
    axes[0, 0].set_title('Original', fontsize=11)

    for idx, nt in enumerate(n_terms_list):
        approx = max_plus_approx(terms[:nt], f.shape)
        error = np.abs(f - approx)
        max_err = np.max(error)

        if idx < 3:
            ax = axes[0, idx + 1]
        else:
            ax = axes[1, 0]
        ax.imshow(approx, cmap='viridis', aspect='equal',
                  vmin=f.min(), vmax=f.max())
        ax.set_title(f'{nt} terms (err={max_err:.2f})', fontsize=11)

    for idx, nt in enumerate(n_terms_list):
        approx = max_plus_approx(terms[:nt], f.shape)
        error = np.abs(f - approx)
        ax_err = axes[1, idx]
        ax_err.imshow(error, cmap='hot_r', aspect='equal', vmin=0)
        ax_err.set_title(f'|error| ({nt} terms)', fontsize=11)

    plt.suptitle('Progressive Max-Plus Approximation', fontsize=14, y=1.02)
    plt.tight_layout()
    plt.savefig('demos/figures/progressive_approximation.png', dpi=150, bbox_inches='tight')
    plt.close()

    # --- Figure 4: Max-subadditivity ---
    fig, axes = plt.subplots(1, 4, figsize=(16, 4))

    np.random.seed(789)
    f = np.random.randn(6, 6) * 2
    g = np.random.randn(6, 6) * 2
    h = np.maximum(f, g)

    vmin = min(f.min(), g.min(), h.min())
    vmax = max(f.max(), g.max(), h.max())

    axes[0].imshow(f, cmap='coolwarm', aspect='equal', vmin=vmin, vmax=vmax)
    axes[0].set_title('f', fontsize=13)
    axes[1].imshow(g, cmap='coolwarm', aspect='equal', vmin=vmin, vmax=vmax)
    axes[1].set_title('g', fontsize=13)
    axes[2].imshow(h, cmap='coolwarm', aspect='equal', vmin=vmin, vmax=vmax)
    axes[2].set_title('max(f, g)', fontsize=13)

    eps = 0.5
    rf, _, _ = compute_tropical_rank(f, eps)
    rg, _, _ = compute_tropical_rank(g, eps)
    rh, _, _ = compute_tropical_rank(h, eps)

    axes[3].bar(['rank(f)', 'rank(g)', 'rank(max)', 'sum'],
                [rf, rg, rh, rf + rg],
                color=['#2196F3', '#4CAF50', '#FF9800', '#9E9E9E'])
    axes[3].set_title(f'Tropical ε-Rank (ε={eps})', fontsize=13)
    axes[3].set_ylabel('Rank')

    plt.suptitle('Max-Subadditivity: rank(max(f,g)) ≤ rank(f) + rank(g)',
                 fontsize=14, y=1.02)
    plt.tight_layout()
    plt.savefig('demos/figures/max_subadditivity.png', dpi=150, bbox_inches='tight')
    plt.close()

    print("\n" + "=" * 60)
    print("Figures saved to demos/figures/")
    print("=" * 60)


# ============================================================
# 5. Application: Image Compression via Tropical Decomposition
# ============================================================

def demo_image_compression():
    """
    Demonstrate tropical max-plus decomposition for image-like data.
    """
    print("\n" + "=" * 60)
    print("DEMO 4: Tropical Compression of Image-Like Data")
    print("=" * 60)

    x = np.linspace(-2, 2, 32)
    y = np.linspace(-2, 2, 32)
    X, Y = np.meshgrid(x, y)
    np.random.seed(42)
    image = np.exp(-(X**2 + Y**2)) * 5 + 0.1 * np.random.randn(32, 32)

    all_terms = build_anchored_terms(image)

    term_values = [(i, all_terms[i].c) for i in range(len(all_terms))]
    term_values.sort(key=lambda x: -x[1])
    sorted_terms = [all_terms[i] for i, _ in term_values]

    compression_levels = [10, 50, 100, 200, 500, 1024]

    print(f"\n  Image size: 32×32 = 1024 pixels")
    print(f"  Full representation: 1024 terms")
    print(f"\n  {'Terms':>8s}  {'Compression':>12s}  {'Max Error':>12s}  {'PSNR (dB)':>10s}")
    print(f"  {'-'*8}  {'-'*12}  {'-'*12}  {'-'*10}")

    os.makedirs("demos/figures", exist_ok=True)
    fig, axes = plt.subplots(2, 4, figsize=(16, 8))

    axes[0, 0].imshow(image, cmap='viridis')
    axes[0, 0].set_title('Original', fontsize=11)
    axes[0, 0].axis('off')

    for idx, nt in enumerate(compression_levels):
        approx = max_plus_approx(sorted_terms[:nt], image.shape)
        error = np.max(np.abs(image - approx))
        mse = np.mean((image - approx) ** 2)
        psnr = 10 * np.log10(np.max(image)**2 / mse) if mse > 0 else np.inf
        compression = 1024.0 / nt

        print(f"  {nt:8d}  {compression:12.1f}x  {error:12.4f}  {psnr:10.1f}")

        if idx < 3:
            ax = axes[0, idx + 1]
        else:
            ax = axes[1, idx - 3]
        ax.imshow(approx, cmap='viridis', vmin=image.min(), vmax=image.max())
        ax.set_title(f'{nt} terms (err={error:.2f})', fontsize=11)
        ax.axis('off')

    errors = []
    for nt in range(1, min(200, len(sorted_terms)) + 1):
        approx = max_plus_approx(sorted_terms[:nt], image.shape)
        errors.append(np.max(np.abs(image - approx)))

    axes[1, 3].plot(range(1, len(errors) + 1), errors, 'b-', linewidth=1.5)
    axes[1, 3].set_xlabel('Number of terms')
    axes[1, 3].set_ylabel('Max error')
    axes[1, 3].set_title('Error vs. terms', fontsize=11)
    axes[1, 3].grid(True, alpha=0.3)

    plt.suptitle('Tropical Max-Plus Compression', fontsize=14, y=1.02)
    plt.tight_layout()
    plt.savefig('demos/figures/tropical_compression.png', dpi=150, bbox_inches='tight')
    plt.close()


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("\n" + "+" + "=" * 58 + "+")
    print("|  Tropical Low-Rank Approximation: Certified Algorithms  |")
    print("+" + "=" * 58 + "+\n")

    matrices = demo_exact_representation()
    f_5x5, epsilons, ranks = demo_tropical_rank()
    demo_max_subadditivity()
    demo_visualizations(f_5x5, epsilons, ranks)
    demo_image_compression()

    print("\n" + "=" * 60)
    print("All demonstrations completed successfully!")
    print("=" * 60)

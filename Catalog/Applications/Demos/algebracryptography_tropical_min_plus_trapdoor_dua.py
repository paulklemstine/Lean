#!/usr/bin/env python3
"""
Tropical Residuation Trapdoor Duality — Demo & Visualization

Demonstrates the key mathematical structures of min-plus matrix cryptography:
1. Tropical (min-plus) matrix multiplication
2. Public map F_{A,B}(X) = A ⊗ X ⊗ B
3. Fiber ambiguity: multiple preimages mapping to the same output
4. Compression profiles and residuation spectra
5. Visualization of fiber structure and invariant collapse
"""

import numpy as np
import itertools
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from collections import Counter
import base64
from io import BytesIO


# ─── Core Tropical Algebra ─────────────────────────────────────────────

def trop_mul(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """Min-plus matrix multiplication: (A ⊗ B)_{ij} = min_k (A_{ik} + B_{kj})"""
    n = A.shape[0]
    C = np.full((n, n), np.inf)
    for i in range(n):
        for j in range(n):
            C[i, j] = min(A[i, k] + B[k, j] for k in range(n))
    return C


def public_map(A: np.ndarray, B: np.ndarray, X: np.ndarray) -> np.ndarray:
    """Public map F_{A,B}(X) = A ⊗ X ⊗ B"""
    return trop_mul(trop_mul(A, X), B)


def row_mins(X: np.ndarray) -> np.ndarray:
    """Row minima vector"""
    return X.min(axis=1)


def col_mins(X: np.ndarray) -> np.ndarray:
    """Column minima vector"""
    return X.min(axis=0)


def compression_profile(X: np.ndarray) -> dict:
    """Compression profile: row mins + col mins"""
    return {"row_mins": row_mins(X).tolist(), "col_mins": col_mins(X).tolist()}


def residuation_spectrum(X: np.ndarray) -> list:
    """Residuation spectrum: sorted gaps X_{ij} - rowMin_i"""
    rm = row_mins(X)
    gaps = []
    for i in range(X.shape[0]):
        for j in range(X.shape[1]):
            gaps.append(int(X[i, j] - rm[i]))
    return sorted(gaps)


# ─── Demo 1: Associativity verification ────────────────────────────────

def demo_associativity():
    """Verify tropical multiplication is associative on random matrices"""
    print("=" * 60)
    print("DEMO 1: Tropical Multiplication Associativity")
    print("=" * 60)
    np.random.seed(42)
    n = 3
    A = np.random.randint(-5, 6, (n, n)).astype(float)
    B = np.random.randint(-5, 6, (n, n)).astype(float)
    C = np.random.randint(-5, 6, (n, n)).astype(float)

    lhs = trop_mul(trop_mul(A, B), C)  # (A⊗B)⊗C
    rhs = trop_mul(A, trop_mul(B, C))  # A⊗(B⊗C)

    print(f"A =\n{A.astype(int)}")
    print(f"B =\n{B.astype(int)}")
    print(f"C =\n{C.astype(int)}")
    print(f"\n(A⊗B)⊗C =\n{lhs.astype(int)}")
    print(f"A⊗(B⊗C) =\n{rhs.astype(int)}")
    print(f"Equal: {np.allclose(lhs, rhs)}")
    print()


# ─── Demo 2: Fiber Ambiguity ──────────────────────────────────────────

def demo_fiber_ambiguity():
    """Show that the public map with A=B=0 collapses distinct matrices"""
    print("=" * 60)
    print("DEMO 2: Fiber Ambiguity — Multiple Preimages")
    print("=" * 60)
    n = 2
    A = np.zeros((n, n))
    B = np.zeros((n, n))

    X1 = np.array([[0, 1], [1, 1]], dtype=float)
    X2 = np.array([[1, 0], [1, 1]], dtype=float)

    Z1 = public_map(A, B, X1)
    Z2 = public_map(A, B, X2)

    print(f"Public keys: A = B = zero matrix")
    print(f"X₁ = {X1.astype(int).tolist()}")
    print(f"X₂ = {X2.astype(int).tolist()}")
    print(f"F(X₁) = {Z1.astype(int).tolist()}")
    print(f"F(X₂) = {Z2.astype(int).tolist()}")
    print(f"Same image: {np.allclose(Z1, Z2)}")
    print(f"X₁ ≠ X₂: {not np.allclose(X1, X2)}")

    # Check incomparability
    le12 = np.all(X1 <= X2)
    le21 = np.all(X2 <= X1)
    print(f"X₁ ≤ X₂ (entry-wise): {le12}")
    print(f"X₂ ≤ X₁ (entry-wise): {le21}")
    print(f"Incomparable: {not le12 and not le21}")
    print()


# ─── Demo 3: Fiber Size Enumeration ──────────────────────────────────

def demo_fiber_enumeration():
    """Enumerate all bounded matrices in a fiber to measure ambiguity"""
    print("=" * 60)
    print("DEMO 3: Fiber Size Enumeration (n=2, K=2)")
    print("=" * 60)
    n = 2
    K = 2
    A = np.zeros((n, n))
    B = np.zeros((n, n))

    # Target: the zero matrix
    target = np.zeros((n, n))

    # Enumerate all 2×2 matrices with entries in {-K, ..., K}
    fiber = []
    entries = range(-K, K + 1)
    for vals in itertools.product(entries, repeat=n * n):
        X = np.array(vals, dtype=float).reshape(n, n)
        Z = public_map(A, B, X)
        if np.allclose(Z, target):
            fiber.append(X)

    print(f"Target image: all-zeros matrix")
    print(f"Bound K = {K}, dimension n = {n}")
    print(f"Total bounded matrices: {len(entries) ** (n*n)}")
    print(f"Fiber size (preimages of target): {len(fiber)}")

    # Count incomparable pairs
    incomparable = 0
    for i in range(len(fiber)):
        for j in range(i + 1, len(fiber)):
            le_ij = np.all(fiber[i] <= fiber[j])
            le_ji = np.all(fiber[j] <= fiber[i])
            if not le_ij and not le_ji:
                incomparable += 1
    print(f"Incomparable pairs in fiber: {incomparable}")
    print(f"Fiber examples (first 5):")
    for X in fiber[:5]:
        print(f"  {X.astype(int).tolist()}")
    print()
    return fiber


# ─── Demo 4: Spectrum Invariance ─────────────────────────────────────

def demo_spectrum_invariance():
    """Show that additive shift preserves the residuation spectrum"""
    print("=" * 60)
    print("DEMO 4: Spectrum Invariance Under Additive Shift")
    print("=" * 60)
    X = np.array([[1, 3, 5], [2, 4, 1], [0, 2, 3]], dtype=float)
    c = 7

    spec_X = residuation_spectrum(X)
    spec_shifted = residuation_spectrum(X + c)

    print(f"X =\n{X.astype(int)}")
    print(f"X + {c} =\n{(X + c).astype(int)}")
    print(f"Spectrum(X) = {spec_X}")
    print(f"Spectrum(X + {c}) = {spec_shifted}")
    print(f"Spectra equal: {spec_X == spec_shifted}")
    print()


# ─── Demo 5: Row-Min Functoriality ──────────────────────────────────

def demo_rowmin_functoriality():
    """Verify rowMins(A⊗X) = A ⊗_vec rowMins(X)"""
    print("=" * 60)
    print("DEMO 5: Row-Min Functoriality Under Left Multiplication")
    print("=" * 60)
    n = 3
    np.random.seed(123)
    A = np.random.randint(-3, 4, (n, n)).astype(float)
    X = np.random.randint(-3, 4, (n, n)).astype(float)

    AX = trop_mul(A, X)
    rm_AX = row_mins(AX)
    rm_X = row_mins(X)

    # Compute A ⊗_vec rm_X: min_k (A_{ik} + rm_X_k)
    trop_vec_product = np.array([min(A[i, k] + rm_X[k] for k in range(n)) for i in range(n)])

    print(f"A =\n{A.astype(int)}")
    print(f"X =\n{X.astype(int)}")
    print(f"rowMins(A⊗X) = {rm_AX.astype(int)}")
    print(f"A ⊗_vec rowMins(X) = {trop_vec_product.astype(int)}")
    print(f"Equal: {np.allclose(rm_AX, trop_vec_product)}")
    print()


# ─── Visualization 1: Fiber Structure Heatmap ────────────────────────

def viz_fiber_heatmap(fiber):
    """Visualize the fiber structure as a heatmap of pairwise comparability"""
    n_fiber = min(len(fiber), 30)
    comparability = np.zeros((n_fiber, n_fiber))

    for i in range(n_fiber):
        for j in range(n_fiber):
            if i == j:
                comparability[i, j] = 2  # self
            elif np.all(fiber[i] <= fiber[j]):
                comparability[i, j] = 1  # i ≤ j
            elif np.all(fiber[j] <= fiber[i]):
                comparability[i, j] = 1  # j ≤ i
            else:
                comparability[i, j] = 0  # incomparable

    fig, ax = plt.subplots(figsize=(8, 6))
    from matplotlib.colors import ListedColormap
    cmap = ListedColormap(['#e74c3c', '#3498db', '#2ecc71'])
    im = ax.imshow(comparability, cmap=cmap, vmin=0, vmax=2)

    ax.set_title("Fiber Comparability Structure\n(Red = Incomparable, Blue = Comparable, Green = Self)",
                 fontsize=12, fontweight='bold')
    ax.set_xlabel("Matrix index in fiber")
    ax.set_ylabel("Matrix index in fiber")

    plt.tight_layout()
    plt.savefig("/workspace/request-project/fiber_comparability.png", dpi=150)
    plt.close()
    print("Saved fiber_comparability.png")


# ─── Visualization 2: Fiber Size Growth ──────────────────────────────

def viz_fiber_growth():
    """Plot fiber size as K grows for fixed n=2"""
    print("\nComputing fiber sizes for varying K...")
    n = 2
    A = np.zeros((n, n))
    B = np.zeros((n, n))
    target = np.zeros((n, n))

    Ks = range(0, 5)
    fiber_sizes = []
    total_sizes = []

    for K in Ks:
        entries = range(-K, K + 1)
        count = 0
        total = len(entries) ** (n * n)
        for vals in itertools.product(entries, repeat=n * n):
            X = np.array(vals, dtype=float).reshape(n, n)
            Z = public_map(A, B, X)
            if np.allclose(Z, target):
                count += 1
        fiber_sizes.append(count)
        total_sizes.append(total)
        print(f"  K={K}: fiber size = {count}, total = {total}, ratio = {count/total:.4f}")

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    ax1.bar(list(Ks), fiber_sizes, color='#2c3e50', alpha=0.8)
    ax1.set_xlabel("Bound K", fontsize=12)
    ax1.set_ylabel("Fiber Size", fontsize=12)
    ax1.set_title("Inverse Fiber Size vs. Bound K\n(n=2, A=B=0, target=0)", fontsize=13, fontweight='bold')

    ax2.bar(list(Ks), [f / t if t > 0 else 0 for f, t in zip(fiber_sizes, total_sizes)],
            color='#e74c3c', alpha=0.8)
    ax2.set_xlabel("Bound K", fontsize=12)
    ax2.set_ylabel("Fiber / Total", fontsize=12)
    ax2.set_title("Fiber Fraction vs. Bound K", fontsize=13, fontweight='bold')

    plt.tight_layout()
    plt.savefig("/workspace/request-project/fiber_growth.png", dpi=150)
    plt.close()
    print("Saved fiber_growth.png")


# ─── Visualization 3: Spectrum Distribution ─────────────────────────

def viz_spectrum_distribution():
    """Visualize how spectra distribute across random matrices"""
    np.random.seed(42)
    n = 3
    K = 3
    spectra = Counter()

    for _ in range(2000):
        X = np.random.randint(-K, K + 1, (n, n)).astype(float)
        spec = tuple(residuation_spectrum(X))
        spectra[spec] += 1

    # Plot distribution of spectrum multiplicities
    multiplicities = sorted(spectra.values(), reverse=True)

    fig, ax = plt.subplots(figsize=(10, 5))
    ax.bar(range(min(50, len(multiplicities))), multiplicities[:50],
           color='#8e44ad', alpha=0.8)
    ax.set_xlabel("Spectrum class (ranked by frequency)", fontsize=12)
    ax.set_ylabel("Number of matrices", fontsize=12)
    ax.set_title(f"Distribution of Residuation Spectra\n(n={n}, K={K}, 2000 random matrices)",
                 fontsize=13, fontweight='bold')
    ax.set_yscale('log')
    plt.tight_layout()
    plt.savefig("/workspace/request-project/spectrum_distribution.png", dpi=150)
    plt.close()
    print("Saved spectrum_distribution.png")
    print(f"  Unique spectra found: {len(spectra)}")
    print(f"  Most common spectrum occurs: {multiplicities[0]} times")


# ─── Main ────────────────────────────────────────────────────────────

if __name__ == "__main__":
    demo_associativity()
    demo_fiber_ambiguity()
    fiber = demo_fiber_enumeration()
    demo_spectrum_invariance()
    demo_rowmin_functoriality()

    print("\n" + "=" * 60)
    print("VISUALIZATIONS")
    print("=" * 60)
    viz_fiber_heatmap(fiber)
    viz_fiber_growth()
    viz_spectrum_distribution()

    print("\n" + "=" * 60)
    print("ALL DEMOS COMPLETE")
    print("=" * 60)

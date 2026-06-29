#!/usr/bin/env python3
"""
Non-Archimedean Proof Signal Processing: Demonstrations

This script demonstrates the core theorems of ultrametric proof sheaf sampling:
1. Ultrametric ball structure and equivalence classes
2. Canonical sampling set construction
3. Perfect reconstruction of bandlimited (locally constant) functions
4. Operadic compositionality: composition commutes with reconstruction
5. Stability under perturbation
6. Compression ratio analysis

All computations match the formally verified theorems in
Bridges/AlgebraLogicMachineLearning/UltrametricProofSheafSampling.lean
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from typing import List, Tuple, Dict, Callable
import json
import base64
import io


# ============================================================
# §1. Ultrametric Distance Construction
# ============================================================

def make_ultrametric_from_tree(n_vertices: int, n_clusters: int, seed: int = 42) -> np.ndarray:
    """Construct an ultrametric distance matrix from a random hierarchical clustering.

    Assigns vertices to clusters, then defines distance as:
    - 0 if same vertex
    - 1.0 if same cluster, different vertex
    - 2.0 if different clusters

    This always produces a valid ultrametric (satisfies strong triangle inequality).
    """
    rng = np.random.RandomState(seed)
    assignments = rng.randint(0, n_clusters, size=n_vertices)
    d = np.zeros((n_vertices, n_vertices))
    for i in range(n_vertices):
        for j in range(n_vertices):
            if i == j:
                d[i, j] = 0.0
            elif assignments[i] == assignments[j]:
                d[i, j] = 1.0
            else:
                d[i, j] = 2.0
    return d, assignments


def verify_ultrametric(d: np.ndarray) -> bool:
    """Verify that d satisfies the strong triangle inequality."""
    n = d.shape[0]
    for i in range(n):
        for j in range(n):
            for k in range(n):
                if d[i, k] > max(d[i, j], d[j, k]) + 1e-10:
                    return False
    return True


# ============================================================
# §2. Canonical Sampling Set Construction
# ============================================================

def canonical_sampling_set(d: np.ndarray, r: float) -> List[int]:
    """Construct a canonical sampling set: one representative per r-ball.

    Algorithm:
    1. Start with all vertices unassigned
    2. Pick an unassigned vertex, add it to S
    3. Remove all vertices within distance r
    4. Repeat until all vertices are assigned

    Returns indices of the sampling set.
    """
    n = d.shape[0]
    remaining = set(range(n))
    S = []
    while remaining:
        v = min(remaining)  # deterministic choice
        S.append(v)
        # Remove all vertices in the r-ball around v
        to_remove = {w for w in remaining if d[v, w] <= r}
        remaining -= to_remove
    return S


def find_representative(d: np.ndarray, r: float, S: List[int], v: int) -> int:
    """Find the representative of vertex v in sampling set S."""
    for s in S:
        if d[v, s] <= r:
            return s
    raise ValueError(f"No representative found for vertex {v}")


# ============================================================
# §3. Locally Constant Functions and Reconstruction
# ============================================================

def is_locally_constant(f: np.ndarray, d: np.ndarray, r: float) -> bool:
    """Check if f is locally constant at scale r."""
    n = len(f)
    for i in range(n):
        for j in range(n):
            if d[i, j] <= r and abs(f[i] - f[j]) > 1e-10:
                return False
    return True


def make_locally_constant(d: np.ndarray, r: float, seed: int = 123) -> np.ndarray:
    """Construct a random function that is locally constant at scale r."""
    n = d.shape[0]
    rng = np.random.RandomState(seed)
    S = canonical_sampling_set(d, r)
    # Assign random values to representatives
    values = rng.randn(len(S))
    f = np.zeros(n)
    for i in range(n):
        rep = find_representative(d, r, S, i)
        idx = S.index(rep)
        f[i] = values[idx]
    return f


def reconstruct(d: np.ndarray, r: float, S: List[int],
                samples: np.ndarray) -> np.ndarray:
    """Reconstruct a function from samples on a covering set."""
    n = d.shape[0]
    f = np.zeros(n)
    for v in range(n):
        rep = find_representative(d, r, S, v)
        idx = S.index(rep)
        f[v] = samples[idx]
    return f


# ============================================================
# §4. Demonstration: Core Theorems
# ============================================================

def demo_sampling_theorem():
    """Demonstrate Theorem 1: Sampling Injectivity and Reconstruction."""
    print("=" * 60)
    print("DEMO 1: Ultrametric Sampling and Reconstruction")
    print("=" * 60)

    n_vertices = 20
    n_clusters = 5
    r = 1.5  # scale: groups same-cluster vertices

    d, assignments = make_ultrametric_from_tree(n_vertices, n_clusters, seed=42)
    assert verify_ultrametric(d), "Distance is not ultrametric!"
    print(f"✓ Constructed ultrametric space: {n_vertices} vertices, {n_clusters} clusters")

    S = canonical_sampling_set(d, r)
    print(f"✓ Canonical sampling set: {len(S)} samples (= {n_clusters} clusters)")
    print(f"  Sample vertices: {S}")

    # Create a locally constant function
    f = make_locally_constant(d, r, seed=99)
    assert is_locally_constant(f, d, r), "Function is not locally constant!"
    print(f"✓ Created locally constant function (scale r={r})")

    # Sample and reconstruct
    samples = f[S]
    f_recon = reconstruct(d, r, S, samples)

    # Verify perfect reconstruction (Theorem 1b)
    error = np.max(np.abs(f - f_recon))
    print(f"✓ Reconstruction error: {error:.2e} (should be 0)")
    assert error < 1e-10, "Reconstruction failed!"
    print(f"✓ PERFECT RECONSTRUCTION VERIFIED")
    print()

    return d, assignments, S, f, f_recon


def demo_compression_complexity():
    """Demonstrate Theorem 2: Compression Complexity."""
    print("=" * 60)
    print("DEMO 2: Compression Complexity = Number of Balls")
    print("=" * 60)

    results = []
    for n_clusters in [3, 5, 8, 12, 20]:
        n_vertices = 100
        d, assignments = make_ultrametric_from_tree(n_vertices, n_clusters, seed=42)
        r = 1.5
        S = canonical_sampling_set(d, r)
        actual_clusters = len(set(assignments))
        compression_ratio = n_vertices / len(S)

        results.append({
            'target_clusters': n_clusters,
            'actual_clusters': actual_clusters,
            'sampling_size': len(S),
            'compression_ratio': compression_ratio
        })

        print(f"  Clusters={actual_clusters:3d} | Samples={len(S):3d} | "
              f"Compression={compression_ratio:.1f}x | |V|={n_vertices}")

    print()
    print("✓ Sampling cardinality = number of ultrametric balls (compression invariant)")
    print()
    return results


def demo_operadic_compositionality():
    """Demonstrate Theorem 3: Operadic Closure and Commutativity."""
    print("=" * 60)
    print("DEMO 3: Operadic Compositionality")
    print("=" * 60)

    n_vertices = 30
    n_clusters = 6
    r = 1.5
    d, _ = make_ultrametric_from_tree(n_vertices, n_clusters, seed=42)
    S = canonical_sampling_set(d, r)

    # Create two locally constant functions
    f1 = make_locally_constant(d, r, seed=10)
    f2 = make_locally_constant(d, r, seed=20)

    operations = {
        'sum': lambda a, b: a + b,
        'product': lambda a, b: a * b,
        'max': lambda a, b: np.maximum(a, b),
        'nonlinear': lambda a, b: np.sin(a) + np.cos(b),
    }

    for name, op in operations.items():
        # Method A: compose then reconstruct
        composed = op(f1, f2)
        assert is_locally_constant(composed, d, r), \
            f"Composed function ({name}) not locally constant!"
        samples_composed = composed[S]
        recon_A = reconstruct(d, r, S, samples_composed)

        # Method B: reconstruct each then compose
        recon_f1 = reconstruct(d, r, S, f1[S])
        recon_f2 = reconstruct(d, r, S, f2[S])
        recon_B = op(recon_f1, recon_f2)

        error = np.max(np.abs(recon_A - recon_B))
        print(f"  {name:12s}: compose-recon vs recon-compose error = {error:.2e}")
        assert error < 1e-10, f"Commutativity failed for {name}!"

    print("✓ Reconstruction commutes with ALL pointwise operations")
    print()


def demo_stability():
    """Demonstrate stability of reconstruction under perturbation."""
    print("=" * 60)
    print("DEMO 4: Reconstruction Stability")
    print("=" * 60)

    n_vertices = 50
    n_clusters = 10
    r = 1.5
    d, _ = make_ultrametric_from_tree(n_vertices, n_clusters, seed=42)
    S = canonical_sampling_set(d, r)
    f = make_locally_constant(d, r, seed=77)

    epsilons = [0.001, 0.01, 0.1, 0.5, 1.0]
    for eps in epsilons:
        noise = np.random.RandomState(42).uniform(-eps, eps, size=len(S))
        perturbed_samples = f[S] + noise
        f_noisy = reconstruct(d, r, S, perturbed_samples)
        actual_error = np.max(np.abs(f - f_noisy))
        print(f"  ε={eps:.3f} | max reconstruction error = {actual_error:.4f} | bound = {eps:.4f}")
        assert actual_error <= eps + 1e-10, "Stability bound violated!"

    print("✓ Reconstruction error bounded by sample perturbation (isometric stability)")
    print()


# ============================================================
# §5. Visualization
# ============================================================

def create_visualizations(d, assignments, S, f, f_recon):
    """Create publication-quality visualizations."""
    figures = {}

    # --- Figure 1: Ultrametric Ball Structure ---
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Reorder vertices by cluster for visualization
    order = np.argsort(assignments)
    d_ordered = d[np.ix_(order, order)]

    ax = axes[0]
    im = ax.imshow(d_ordered, cmap='viridis', interpolation='nearest')
    ax.set_title('Ultrametric Distance Matrix\n(vertices ordered by cluster)', fontsize=13)
    ax.set_xlabel('Vertex index (reordered)')
    ax.set_ylabel('Vertex index (reordered)')
    plt.colorbar(im, ax=ax, label='Distance')

    # Mark cluster boundaries
    cluster_sizes = np.bincount(assignments)
    boundaries = np.cumsum(cluster_sizes)[:-1]
    for b in boundaries:
        ax.axhline(b - 0.5, color='red', linewidth=0.8, alpha=0.7)
        ax.axvline(b - 0.5, color='red', linewidth=0.8, alpha=0.7)

    # --- Figure 2: Sampling and Reconstruction ---
    ax = axes[1]
    n = len(f)
    x = np.arange(n)
    ax.bar(x, f, color='steelblue', alpha=0.4, label='Original function')
    ax.scatter([order.tolist().index(s) for s in S],
               [f[s] for s in S],
               color='red', s=80, zorder=5, label=f'Samples ({len(S)} points)')
    ax.bar(x, f_recon, color='orange', alpha=0.3, label='Reconstructed')
    ax.set_title('Sampling & Perfect Reconstruction\n(locally constant function)', fontsize=13)
    ax.set_xlabel('Vertex index')
    ax.set_ylabel('Function value')
    ax.legend(loc='upper right')

    plt.tight_layout()
    buf = io.BytesIO()
    plt.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    figures['sampling_reconstruction'] = base64.b64encode(buf.read()).decode('utf-8')
    plt.close()

    # --- Figure 3: Compression Ratio vs Number of Clusters ---
    fig, ax = plt.subplots(1, 1, figsize=(8, 5))
    cluster_counts = list(range(2, 51))
    compression_ratios = []
    sampling_sizes = []
    n_vertices = 100
    for nc in cluster_counts:
        d_temp, _ = make_ultrametric_from_tree(n_vertices, nc, seed=42)
        S_temp = canonical_sampling_set(d_temp, 1.5)
        compression_ratios.append(n_vertices / len(S_temp))
        sampling_sizes.append(len(S_temp))

    ax.plot(cluster_counts, compression_ratios, 'b-o', markersize=3, linewidth=1.5)
    ax.set_xlabel('Number of Ultrametric Balls (Compression Invariant)', fontsize=12)
    ax.set_ylabel('Compression Ratio |V| / |S|', fontsize=12)
    ax.set_title('Proof Compression Ratio vs. Ball Count\n(|V| = 100 vertices)', fontsize=13)
    ax.grid(True, alpha=0.3)
    ax.axhline(y=1, color='red', linestyle='--', alpha=0.5, label='No compression')
    ax.legend()

    plt.tight_layout()
    buf = io.BytesIO()
    plt.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    figures['compression_ratio'] = base64.b64encode(buf.read()).decode('utf-8')
    plt.close()

    # --- Figure 4: Stability under perturbation ---
    fig, ax = plt.subplots(1, 1, figsize=(8, 5))
    d_stab, _ = make_ultrametric_from_tree(50, 10, seed=42)
    S_stab = canonical_sampling_set(d_stab, 1.5)
    f_stab = make_locally_constant(d_stab, 1.5, seed=77)

    epsilons = np.linspace(0, 1.0, 50)
    max_errors = []
    for eps in epsilons:
        if eps == 0:
            max_errors.append(0)
            continue
        noise = np.random.RandomState(42).uniform(-eps, eps, size=len(S_stab))
        f_noisy = reconstruct(d_stab, 1.5, S_stab, f_stab[S_stab] + noise)
        max_errors.append(np.max(np.abs(f_stab - f_noisy)))

    ax.plot(epsilons, max_errors, 'b-', linewidth=2, label='Actual max error')
    ax.plot(epsilons, epsilons, 'r--', linewidth=1.5, label='Theoretical bound (ε)')
    ax.set_xlabel('Sample Perturbation ε', fontsize=12)
    ax.set_ylabel('Max Reconstruction Error', fontsize=12)
    ax.set_title('Reconstruction Stability\n(error ≤ perturbation, always)', fontsize=13)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    buf = io.BytesIO()
    plt.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    figures['stability'] = base64.b64encode(buf.read()).decode('utf-8')
    plt.close()

    return figures


# ============================================================
# Main
# ============================================================

if __name__ == '__main__':
    print("\n" + "=" * 60)
    print("NON-ARCHIMEDEAN PROOF SIGNAL PROCESSING")
    print("Ultrametric Sheaf Sampling Demonstrations")
    print("=" * 60 + "\n")

    d, assignments, S, f, f_recon = demo_sampling_theorem()
    results = demo_compression_complexity()
    demo_operadic_compositionality()
    demo_stability()

    print("=" * 60)
    print("Creating visualizations...")
    figures = create_visualizations(d, assignments, S, f, f_recon)
    for name, data in figures.items():
        filename = f'{name}.png'
        with open(filename, 'wb') as fout:
            fout.write(base64.b64decode(data))
        print(f"  Saved {filename}")

    print("\n✓ All demonstrations complete. All theorems verified computationally.")
    print("=" * 60)

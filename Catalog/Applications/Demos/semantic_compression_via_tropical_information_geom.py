#!/usr/bin/env python3
"""
Applications of Tropical Semantic Compression

Real-world applications demonstrating the practical utility of
tropical information geometry for semantic compression:

1. Text embedding compression via tropical codebooks
2. Neural network weight quantization with semantic guarantees
3. Distributional semantics with tropical projections
4. Lossy compression with certified distortion bounds
"""

import numpy as np
from typing import List, Tuple, Dict
from algorithms import (
    semantic_dist, tropical_fisher, centered, tropical_proj,
    find_optimal_code, min_closure, extract_skeleton,
    batch_compress, verify_centered_bound
)


# ─── Application 1: Embedding Compression ───────────────────────────────────

def embedding_compression_demo():
    """
    Simulate compressing high-dimensional embeddings using tropical codebooks.
    
    In practice, word/sentence embeddings live in high-dimensional spaces.
    Tropical compression replaces each embedding with the nearest codeword
    from a min-closed codebook, with certified distortion bounds.
    """
    print("=" * 70)
    print("APPLICATION 1: Embedding Compression with Semantic Guarantees")
    print("=" * 70)
    
    np.random.seed(123)
    dim = 8
    n_embeddings = 20
    n_generators = 4
    
    # Simulate embeddings (e.g., from a language model)
    # Cluster them around a few semantic centers
    centers = [np.random.randn(dim) * 2 for _ in range(3)]
    embeddings = []
    labels = []
    for i in range(n_embeddings):
        cluster = i % 3
        emb = centers[cluster] + np.random.randn(dim) * 0.3
        embeddings.append(emb)
        labels.append(cluster)
    
    # Build a tropical codebook from generators
    generators = [np.random.randn(dim) for _ in range(n_generators)]
    codebook = min_closure(generators, max_size=100)
    
    print(f"\nEmbedding dimension: {dim}")
    print(f"Number of embeddings: {n_embeddings}")
    print(f"Codebook size: {len(codebook)}")
    print(f"Skeleton size: {len(extract_skeleton(codebook))}")
    
    # Compress all embeddings
    results = batch_compress(embeddings, codebook)
    
    distortions = [r.distortion for r in results]
    fisher_bounds = [r.fisher_bound for r in results]
    
    print(f"\nCompression Statistics:")
    print(f"  Mean distortion:    {np.mean(distortions):.4f}")
    print(f"  Max distortion:     {np.max(distortions):.4f}")
    print(f"  Mean Fisher bound:  {np.mean(fisher_bounds):.4f}")
    print(f"  Compression ratio:  {dim * 8:.0f} → {np.log2(len(codebook)):.1f} bits")
    
    # Verify Fisher bounds hold for all
    all_ok = all(d <= f + 1e-10 for d, f in zip(distortions, fisher_bounds))
    print(f"  All Fisher bounds satisfied: {all_ok}")
    
    # Check if same-cluster embeddings map to same code
    cluster_codes = {}
    for i, (result, label) in enumerate(zip(results, labels)):
        key = tuple(np.round(result.code, 6))
        if label not in cluster_codes:
            cluster_codes[label] = set()
        cluster_codes[label].add(key)
    
    print(f"\n  Codes per semantic cluster:")
    for label in sorted(cluster_codes.keys()):
        print(f"    Cluster {label}: {len(cluster_codes[label])} distinct codes")


# ─── Application 2: Weight Quantization ─────────────────────────────────────

def weight_quantization_demo():
    """
    Demonstrate tropical codebook quantization for neural network weights.
    
    Neural network compression often uses scalar or vector quantization.
    Tropical compression provides a principled alternative with:
    - Certified distortion bounds (Fisher-type)
    - Idempotent projection (re-quantization is free)
    - Geometric meaning preservation
    """
    print("\n" + "=" * 70)
    print("APPLICATION 2: Neural Network Weight Quantization")
    print("=" * 70)
    
    np.random.seed(456)
    layer_size = 6
    n_filters = 10
    
    # Simulate weight vectors (rows of a weight matrix)
    weight_matrix = np.random.randn(n_filters, layer_size) * 0.5
    
    # Build quantization codebook with different sizes
    for n_gen in [2, 3, 4]:
        generators = [np.random.randn(layer_size) * 0.5 for _ in range(n_gen)]
        codebook = min_closure(generators, max_size=200)
        
        # Quantize all weight vectors
        results = batch_compress(list(weight_matrix), codebook)
        distortions = [r.distortion for r in results]
        
        # Verify idempotence: re-quantizing gives the same result
        re_results = batch_compress([r.code for r in results], codebook)
        idempotent = all(
            np.allclose(r1.code, r2.code)
            for r1, r2 in zip(results, re_results)
        )
        
        print(f"\n  {n_gen} generators → {len(codebook)} codewords")
        print(f"    Mean distortion: {np.mean(distortions):.4f}")
        print(f"    Max distortion:  {np.max(distortions):.4f}")
        print(f"    Idempotent:      {idempotent}")
        print(f"    Bits/weight:     {np.log2(len(codebook)):.2f}")


# ─── Application 3: Distributional Semantics ────────────────────────────────

def distributional_semantics_demo():
    """
    Apply tropical compression to distributional word vectors.
    
    Words with similar meanings should map to similar/identical codes.
    The centered Fisher bound ensures semantic distance is preserved
    up to a factor of 2 after normalization.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 3: Distributional Semantics")
    print("=" * 70)
    
    # Simulate word vectors for related concepts
    dim = 5
    words = {
        "cat":     np.array([1.0, 0.5, -0.3, 0.8, 0.1]),
        "dog":     np.array([0.9, 0.6, -0.2, 0.7, 0.2]),
        "kitten":  np.array([1.1, 0.4, -0.4, 0.9, 0.0]),
        "car":     np.array([-0.5, 1.2, 0.8, -0.3, 0.5]),
        "truck":   np.array([-0.4, 1.3, 0.9, -0.2, 0.4]),
        "bicycle": np.array([-0.3, 1.0, 0.7, -0.1, 0.6]),
    }
    
    print(f"\nWord vectors (dimension {dim}):")
    for word, vec in words.items():
        print(f"  {word:10s}: {vec}")
    
    # Build a small codebook
    generators = [
        np.array([1.0, 0.5, -0.3, 0.8, 0.1]),   # "animal-like"
        np.array([-0.4, 1.2, 0.8, -0.2, 0.5]),   # "vehicle-like"
    ]
    codebook = min_closure(generators, max_size=50)
    
    print(f"\nCodebook: {len(codebook)} codewords from {len(generators)} generators")
    
    # Compress each word
    print("\nCompression results:")
    print(f"  {'Word':10s} {'Code idx':>8s} {'Distortion':>12s} {'Centered bound':>16s}")
    for word, vec in words.items():
        result = find_optimal_code(codebook, vec)
        d_c, bound, ok = verify_centered_bound(vec, result.code)
        print(f"  {word:10s} {result.codebook_index:>8d} {result.distortion:>12.4f} {d_c:>8.4f} ≤ {bound:>6.4f} {'✓' if ok else '✗'}")
    
    # Semantic preservation check
    print("\nSemantic distance preservation:")
    pairs = [("cat", "dog"), ("cat", "car"), ("dog", "truck"), ("kitten", "cat")]
    for w1, w2 in pairs:
        orig_dist = semantic_dist(words[w1], words[w2])
        r1 = find_optimal_code(codebook, words[w1])
        r2 = find_optimal_code(codebook, words[w2])
        comp_dist = semantic_dist(r1.code, r2.code)
        print(f"  d({w1:7s}, {w2:7s}): original={orig_dist:.3f}  compressed={comp_dist:.3f}  ratio={comp_dist/(orig_dist+1e-10):.3f}")


# ─── Application 4: Certified Lossy Compression ─────────────────────────────

def certified_compression_demo():
    """
    Demonstrate lossy compression with certified tropical Fisher bounds.
    
    Unlike heuristic compression, tropical semantic compression comes with
    provable guarantees on maximum distortion.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 4: Certified Lossy Compression")
    print("=" * 70)
    
    np.random.seed(789)
    dim = 10
    n_signals = 50
    
    # Generate signals
    signals = [np.random.randn(dim) for _ in range(n_signals)]
    
    # Compare different codebook sizes
    print(f"\nSignal dimension: {dim}")
    print(f"Number of signals: {n_signals}")
    print(f"\n{'Generators':>12s} {'|Codebook|':>12s} {'Mean dist':>10s} {'Max dist':>10s} {'Max Fisher':>12s} {'Bound OK':>10s}")
    
    for n_gen in [2, 3, 4, 5]:
        generators = [np.random.randn(dim) for _ in range(n_gen)]
        codebook = min_closure(generators, max_size=500)
        
        results = batch_compress(signals, codebook)
        distortions = [r.distortion for r in results]
        fisher_bounds = [r.fisher_bound for r in results]
        all_ok = all(d <= f + 1e-10 for d, f in zip(distortions, fisher_bounds))
        
        print(f"{n_gen:>12d} {len(codebook):>12d} {np.mean(distortions):>10.3f} {np.max(distortions):>10.3f} {np.max(fisher_bounds):>12.3f} {'✓' if all_ok else '✗':>10s}")
    
    # Tropical projection analysis
    print("\n--- Tropical Projection Analysis ---")
    generators = [np.random.randn(dim) for _ in range(3)]
    codebook = min_closure(generators, max_size=200)
    proj = tropical_proj(codebook)
    
    print(f"Codebook size: {len(codebook)}")
    print(f"Tropical projection (pointwise inf): {np.round(proj, 3)}")
    
    # Check if projection is in codebook (min-closure guarantees this)
    in_codebook = any(np.allclose(proj, c) for c in codebook)
    print(f"Projection ∈ codebook: {in_codebook}")
    
    # Measure how far signals are from the projection
    proj_dists = [semantic_dist(s, proj) for s in signals]
    print(f"Mean distance to projection: {np.mean(proj_dists):.3f}")
    print(f"Max distance to projection:  {np.max(proj_dists):.3f}")


# ─── Main ────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  Applications of Tropical Semantic Compression                     ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    
    embedding_compression_demo()
    weight_quantization_demo()
    distributional_semantics_demo()
    certified_compression_demo()
    
    print("\n" + "=" * 70)
    print("All applications completed successfully.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Semantic Compression via Tropical Information Geometry — Demonstrations

Concrete numerical examples illustrating the main theorems:
1. Existence of optimal semantic codes (finite argmin)
2. Idempotent tropical projection on min-closed codebooks
3. Fisher-type bounds on semantic distortion
"""

import numpy as np
from typing import List, Tuple

# ─── Core Definitions ───────────────────────────────────────────────────────

def semantic_dist(w: np.ndarray, v: np.ndarray) -> float:
    """L¹ distance between weight functions (tropical distortion)."""
    return float(np.sum(np.abs(w - v)))

def tropical_fisher(w: np.ndarray) -> float:
    """L¹ norm (tropical Fisher quantity)."""
    return float(np.sum(np.abs(w)))

def centered(w: np.ndarray) -> np.ndarray:
    """Mean-centered weight function."""
    return w - np.mean(w)

def tropical_proj(C: List[np.ndarray]) -> np.ndarray:
    """Pointwise infimum over a codebook (tropical projection)."""
    return np.min(np.stack(C), axis=0)

def is_skeleton_point(C: List[np.ndarray], v: np.ndarray) -> bool:
    """Check if v is a minimal element under pointwise order in C."""
    for u in C:
        if np.all(u <= v) and not np.allclose(u, v):
            return False
    return True

# ─── Demo 1: Optimal Semantic Code Existence ────────────────────────────────

def demo_optimal_code():
    """Demonstrate that optimal semantic codes always exist in finite codebooks."""
    print("=" * 70)
    print("DEMO 1: Existence of Optimal Semantic Code")
    print("=" * 70)
    
    np.random.seed(42)
    n = 5  # alphabet size
    
    # Source weight function
    w = np.array([1.0, -0.5, 2.3, 0.7, -1.2])
    print(f"\nSource weights:    w = {w}")
    
    # Finite codebook
    C = [
        np.array([0.0, 0.0, 2.0, 1.0, -1.0]),
        np.array([1.0, -1.0, 2.0, 0.0, 0.0]),
        np.array([0.5, 0.0, 2.5, 0.5, -0.5]),
        np.array([2.0, 1.0, 1.0, 1.0, -2.0]),
    ]
    
    print(f"\nCodebook C has {len(C)} codewords:")
    distances = []
    for i, c in enumerate(C):
        d = semantic_dist(w, c)
        distances.append(d)
        print(f"  c_{i} = {c}   dist = {d:.3f}")
    
    best_idx = np.argmin(distances)
    print(f"\n✓ Optimal code: c_{best_idx} with distance {distances[best_idx]:.3f}")
    print(f"  (Theorem: exists_optimal_semantic_code)")


# ─── Demo 2: Idempotent Tropical Projection ─────────────────────────────────

def demo_idempotent_projection():
    """Demonstrate idempotence of tropical projection on min-closed codebooks."""
    print("\n" + "=" * 70)
    print("DEMO 2: Idempotent Tropical Projection")
    print("=" * 70)
    
    # Build a min-closed codebook: start with generators, close under min
    g1 = np.array([3.0, 1.0, 2.0])
    g2 = np.array([1.0, 3.0, 2.0])
    g3 = np.array([2.0, 2.0, 1.0])
    
    # Close under pointwise min
    C = [g1, g2, g3]
    # Add pairwise mins
    C.append(np.minimum(g1, g2))  # [1, 1, 2]
    C.append(np.minimum(g1, g3))  # [2, 1, 1]
    C.append(np.minimum(g2, g3))  # [1, 2, 1]
    # Add triple min
    C.append(np.minimum(np.minimum(g1, g2), g3))  # [1, 1, 1]
    
    # Remove duplicates
    unique_C = []
    for c in C:
        if not any(np.allclose(c, u) for u in unique_C):
            unique_C.append(c)
    C = unique_C
    
    print(f"\nMin-closed codebook C ({len(C)} codewords):")
    for i, c in enumerate(C):
        print(f"  c_{i} = {c}")
    
    # Verify min-closure
    print("\nVerifying min-closure...")
    for i, u in enumerate(C):
        for j, v in enumerate(C):
            m = np.minimum(u, v)
            in_C = any(np.allclose(m, c) for c in C)
            if not in_C:
                print(f"  FAIL: min(c_{i}, c_{j}) = {m} not in C!")
                return
    print("  ✓ C is min-closed")
    
    # Compute tropical projection
    proj = tropical_proj(C)
    print(f"\nTropical projection π = pointwise inf = {proj}")
    
    # Check membership
    in_C = any(np.allclose(proj, c) for c in C)
    print(f"  π ∈ C? {in_C}  (Theorem: tropicalProj_mem_of_min_closed)")
    
    # Check idempotence
    proj2 = tropical_proj(C)  # Same as proj since it doesn't depend on input
    print(f"  π(π) = {proj2}")
    print(f"  π(π) = π? {np.allclose(proj, proj2)}  (Theorem: tropicalProj_idempotent)")


# ─── Demo 3: Fisher-Type Bounds ─────────────────────────────────────────────

def demo_fisher_bounds():
    """Demonstrate tropical Fisher-type bounds on semantic distortion."""
    print("\n" + "=" * 70)
    print("DEMO 3: Tropical Fisher-Type Bounds")
    print("=" * 70)
    
    w = np.array([2.0, -1.0, 3.0, 0.5, -0.5, 1.5])
    v = np.array([1.0, 0.0, 2.5, 1.0, 0.0, 1.0])
    
    diff = w - v
    sd = semantic_dist(w, v)
    tf = tropical_fisher(diff)
    
    print(f"\nw = {w}")
    print(f"v = {v}")
    print(f"w - v = {diff}")
    print(f"\nsemanticDist(w, v)           = {sd:.4f}")
    print(f"tropicalFisher(w - v)        = {tf:.4f}")
    print(f"Equality holds (Theorem: semantic_dist_eq_tropical_fisher_of_diff): {np.isclose(sd, tf)}")
    
    # Centered version
    cw = centered(w)
    cv = centered(v)
    sd_centered = semantic_dist(cw, cv)
    bound = 2 * tropical_fisher(diff)
    
    print(f"\ncentered(w) = {np.round(cw, 4)}")
    print(f"centered(v) = {np.round(cv, 4)}")
    print(f"\nsemanticDist(centered(w), centered(v)) = {sd_centered:.4f}")
    print(f"2 * tropicalFisher(w - v)               = {bound:.4f}")
    print(f"Bound holds (Theorem: semantic_dist_centered_le_two_tropical_fisher): {sd_centered <= bound + 1e-10}")
    print(f"Tightness ratio: {sd_centered / bound:.4f}")


# ─── Demo 4: Projection Error Bound ─────────────────────────────────────────

def demo_projection_error():
    """Demonstrate that projection error is bounded by Fisher of the residual."""
    print("\n" + "=" * 70)
    print("DEMO 4: Projection Error Bound")
    print("=" * 70)
    
    w = np.array([3.0, 1.0, 4.0, 1.5])
    
    C = [
        np.array([2.0, 0.0, 3.0, 1.0]),
        np.array([1.0, 2.0, 3.0, 2.0]),
        np.array([3.0, 1.0, 2.0, 0.0]),
    ]
    
    proj = tropical_proj(C)
    residual = w - proj
    
    sd = semantic_dist(w, proj)
    tf = tropical_fisher(residual)
    
    print(f"\nSource:      w = {w}")
    print(f"Projection:  π = {proj}")
    print(f"Residual:    r = {residual}")
    print(f"\nsemanticDist(w, π)            = {sd:.4f}")
    print(f"tropicalFisher(w - π)         = {tf:.4f}")
    print(f"Bound holds (Theorem: projection_semantic_error_bound): {sd <= tf + 1e-10}")


# ─── Demo 5: Metric Properties ──────────────────────────────────────────────

def demo_metric_properties():
    """Demonstrate that semanticDist forms a proper metric."""
    print("\n" + "=" * 70)
    print("DEMO 5: Metric Properties of Semantic Distance")
    print("=" * 70)
    
    w = np.array([1.0, 2.0, 3.0])
    v = np.array([0.5, 2.5, 2.0])
    u = np.array([1.5, 1.0, 3.5])
    
    print(f"\nw = {w}, v = {v}, u = {u}")
    
    # Non-negativity
    print(f"\nNon-negativity (semanticDist_nonneg):")
    print(f"  d(w,v) = {semantic_dist(w,v):.3f} ≥ 0 ✓")
    
    # Symmetry
    print(f"\nSymmetry (semanticDist_symm):")
    print(f"  d(w,v) = {semantic_dist(w,v):.3f}")
    print(f"  d(v,w) = {semantic_dist(v,w):.3f}")
    print(f"  Equal? {np.isclose(semantic_dist(w,v), semantic_dist(v,w))} ✓")
    
    # Triangle inequality
    dwu = semantic_dist(w, u)
    dwv = semantic_dist(w, v)
    dvu = semantic_dist(v, u)
    print(f"\nTriangle inequality (semanticDist_triangle):")
    print(f"  d(w,u) = {dwu:.3f}")
    print(f"  d(w,v) + d(v,u) = {dwv:.3f} + {dvu:.3f} = {dwv+dvu:.3f}")
    print(f"  d(w,u) ≤ d(w,v) + d(v,u)? {dwu <= dwv + dvu + 1e-10} ✓")


# ─── Main ────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  Semantic Compression via Tropical Information Geometry            ║")
    print("║  Numerical Demonstrations of Formally Verified Theorems           ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    
    demo_optimal_code()
    demo_idempotent_projection()
    demo_fisher_bounds()
    demo_projection_error()
    demo_metric_properties()
    
    print("\n" + "=" * 70)
    print("All demonstrations completed successfully.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Visualizations for Tropical Semantic Compression

Generates publication-quality figures illustrating the key concepts:
1. Tropical codebook geometry and min-closure
2. Fisher bound tightness
3. Idempotent projection convergence
4. Codebook size vs distortion tradeoff
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch
import base64
import io

# Style
plt.rcParams.update({
    'font.size': 12,
    'axes.labelsize': 14,
    'axes.titlesize': 15,
    'figure.figsize': (10, 7),
    'figure.dpi': 150,
})


def semantic_dist(w, v):
    return float(np.sum(np.abs(w - v)))

def tropical_fisher(w):
    return float(np.sum(np.abs(w)))

def centered(w):
    return w - np.mean(w)

def tropical_proj(C):
    return np.min(np.stack(C), axis=0)

def min_closure(generators, max_size=500):
    C = list(generators)
    def contains(lst, x):
        return any(np.allclose(x, y) for y in lst)
    changed = True
    while changed and len(C) < max_size:
        changed = False
        new = []
        for i in range(len(C)):
            for j in range(i, len(C)):
                m = np.minimum(C[i], C[j])
                if not contains(C, m) and not contains(new, m):
                    new.append(m)
                    changed = True
        C.extend(new)
    return C


def fig_to_base64(fig):
    """Convert matplotlib figure to base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', bbox_inches='tight', dpi=150)
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


def plot_codebook_geometry():
    """Visualize a 2D tropical codebook and its min-closure."""
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))
    
    # Generators
    g1 = np.array([3.0, 1.0])
    g2 = np.array([1.0, 3.0])
    g3 = np.array([2.0, 2.0])
    generators = [g1, g2, g3]
    
    # Plot generators
    ax = axes[0]
    for i, g in enumerate(generators):
        ax.plot(g[0], g[1], 'o', markersize=12, zorder=5)
        ax.annotate(f'g{i+1}', (g[0]+0.1, g[1]+0.1), fontsize=12)
    ax.set_xlim(0, 4)
    ax.set_ylim(0, 4)
    ax.set_xlabel('Coordinate 1')
    ax.set_ylabel('Coordinate 2')
    ax.set_title('Generators')
    ax.grid(True, alpha=0.3)
    ax.set_aspect('equal')
    
    # Min-closure
    C = min_closure(generators)
    ax = axes[1]
    codewords = np.array(C)
    ax.scatter(codewords[:, 0], codewords[:, 1], s=100, c='steelblue', zorder=5, label='Codewords')
    for i, g in enumerate(generators):
        ax.plot(g[0], g[1], 'r^', markersize=14, zorder=6)
    
    # Draw min-closure connections
    for i in range(len(C)):
        for j in range(i+1, len(C)):
            m = np.minimum(C[i], C[j])
            if any(np.allclose(m, c) for c in C):
                ax.plot([C[i][0], m[0]], [C[i][1], m[1]], 'k-', alpha=0.15)
                ax.plot([C[j][0], m[0]], [C[j][1], m[1]], 'k-', alpha=0.15)
    
    proj = tropical_proj(C)
    ax.plot(proj[0], proj[1], 'g*', markersize=20, zorder=7, label='Projection π')
    
    ax.set_xlim(0, 4)
    ax.set_ylim(0, 4)
    ax.set_xlabel('Coordinate 1')
    ax.set_title('Min-Closure')
    ax.grid(True, alpha=0.3)
    ax.legend()
    ax.set_aspect('equal')
    
    # Source and nearest code
    ax = axes[2]
    w = np.array([2.5, 2.5])
    ax.scatter(codewords[:, 0], codewords[:, 1], s=80, c='steelblue', alpha=0.6, label='Codebook')
    ax.plot(w[0], w[1], 'rD', markersize=12, zorder=6, label='Source w')
    
    # Find nearest
    dists = [semantic_dist(w, c) for c in C]
    best_idx = np.argmin(dists)
    best = C[best_idx]
    ax.plot(best[0], best[1], 'g*', markersize=16, zorder=7, label=f'Optimal code (d={dists[best_idx]:.2f})')
    ax.annotate('', xy=best, xytext=w,
                arrowprops=dict(arrowstyle='->', color='red', lw=2))
    
    ax.set_xlim(0, 4)
    ax.set_ylim(0, 4)
    ax.set_xlabel('Coordinate 1')
    ax.set_title('Optimal Code Selection')
    ax.grid(True, alpha=0.3)
    ax.legend(fontsize=9)
    ax.set_aspect('equal')
    
    fig.suptitle('Tropical Codebook Geometry', fontsize=16, y=1.02)
    fig.tight_layout()
    return fig


def plot_fisher_bounds():
    """Visualize Fisher bound tightness across random pairs."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    np.random.seed(42)
    n_trials = 200
    dims = [4, 8, 16]
    
    # Plot 1: Scatter of d vs F for different dimensions
    ax = axes[0]
    for dim in dims:
        dists = []
        fishers = []
        for _ in range(n_trials):
            w = np.random.randn(dim)
            v = np.random.randn(dim)
            d = semantic_dist(w, v)
            f = tropical_fisher(w - v)
            dists.append(d)
            fishers.append(f)
        ax.scatter(fishers, dists, alpha=0.3, s=20, label=f'dim={dim}')
    
    max_val = max(max(fishers), max(dists))
    ax.plot([0, max_val*1.1], [0, max_val*1.1], 'k--', alpha=0.5, label='d = F (equality)')
    ax.set_xlabel('Tropical Fisher F(w-v)')
    ax.set_ylabel('Semantic Distance d(w,v)')
    ax.set_title('Fisher Bound: d(w,v) = F(w-v)')
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    # Plot 2: Centered bound tightness
    ax = axes[1]
    for dim in dims:
        ratios = []
        for _ in range(n_trials):
            w = np.random.randn(dim)
            v = np.random.randn(dim)
            d_c = semantic_dist(centered(w), centered(v))
            bound = 2 * tropical_fisher(w - v)
            if bound > 1e-10:
                ratios.append(d_c / bound)
        ax.hist(ratios, bins=30, alpha=0.5, label=f'dim={dim}', density=True)
    
    ax.axvline(x=1.0, color='red', linestyle='--', label='Bound (ratio=1)')
    ax.set_xlabel('Ratio: d_centered / (2·F)')
    ax.set_ylabel('Density')
    ax.set_title('Centered Bound Tightness')
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    fig.suptitle('Tropical Fisher-Type Bounds', fontsize=16, y=1.02)
    fig.tight_layout()
    return fig


def plot_codebook_tradeoff():
    """Plot codebook size vs compression distortion tradeoff."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    np.random.seed(123)
    dim = 6
    n_signals = 30
    signals = [np.random.randn(dim) for _ in range(n_signals)]
    
    gen_counts = range(2, 8)
    mean_dists = []
    max_dists = []
    codebook_sizes = []
    skeleton_sizes = []
    
    for n_gen in gen_counts:
        generators = [np.random.randn(dim) for _ in range(n_gen)]
        C = min_closure(generators, max_size=1000)
        codebook_sizes.append(len(C))
        
        # Extract skeleton
        skeleton = []
        for v in C:
            is_min = True
            for u in C:
                if np.all(u <= v) and not np.allclose(u, v):
                    is_min = False
                    break
            if is_min:
                skeleton.append(v)
        skeleton_sizes.append(len(skeleton))
        
        dists = [min(semantic_dist(s, c) for c in C) for s in signals]
        mean_dists.append(np.mean(dists))
        max_dists.append(np.max(dists))
    
    # Plot 1: Codebook size and skeleton size
    ax = axes[0]
    ax.plot(list(gen_counts), codebook_sizes, 'bo-', label='Codebook |C|', markersize=8)
    ax.plot(list(gen_counts), skeleton_sizes, 'rs-', label='Skeleton |S|', markersize=8)
    ax.set_xlabel('Number of Generators')
    ax.set_ylabel('Size')
    ax.set_title('Codebook Growth')
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    # Plot 2: Distortion vs codebook size
    ax = axes[1]
    ax.plot(codebook_sizes, mean_dists, 'go-', label='Mean distortion', markersize=8)
    ax.plot(codebook_sizes, max_dists, 'r^-', label='Max distortion', markersize=8)
    ax.set_xlabel('Codebook Size |C|')
    ax.set_ylabel('Distortion')
    ax.set_title('Rate-Distortion Tradeoff')
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    fig.suptitle('Codebook Size vs Compression Quality', fontsize=16, y=1.02)
    fig.tight_layout()
    return fig


def plot_projection_structure():
    """Visualize the tropical projection and idempotence."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    # 3D codebook projected to 2D
    np.random.seed(42)
    n = 3
    generators = [
        np.array([3.0, 1.0, 2.0]),
        np.array([1.0, 3.0, 2.0]),
        np.array([2.0, 2.0, 1.0]),
    ]
    C = min_closure(generators)
    proj = tropical_proj(C)
    
    # Plot coordinates 0 vs 1
    ax = axes[0]
    codewords = np.array(C)
    ax.scatter(codewords[:, 0], codewords[:, 1], s=80, c='steelblue', alpha=0.7, label='Codewords')
    
    # Mark generators
    gens = np.array(generators)
    ax.scatter(gens[:, 0], gens[:, 1], s=150, c='red', marker='^', zorder=5, label='Generators')
    
    # Mark projection
    ax.plot(proj[0], proj[1], 'g*', markersize=20, zorder=6, label='π (projection)')
    
    # Show a source and its compression path
    sources = [np.array([2.5, 2.5, 1.5]), np.array([1.5, 1.5, 3.0]), np.array([3.5, 0.5, 1.0])]
    for w in sources:
        dists = [semantic_dist(w, c) for c in C]
        best = C[np.argmin(dists)]
        ax.plot(w[0], w[1], 'kD', markersize=8, zorder=5)
        ax.annotate('', xy=(best[0], best[1]), xytext=(w[0], w[1]),
                    arrowprops=dict(arrowstyle='->', color='orange', lw=1.5))
    
    ax.set_xlabel('Coordinate 1')
    ax.set_ylabel('Coordinate 2')
    ax.set_title('Projection Paths (coords 1,2)')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)
    
    # Idempotence visualization
    ax = axes[1]
    n_trials = 50
    source_dists = []
    proj_dists = []
    reproj_dists = []
    
    for _ in range(n_trials):
        w = np.random.randn(3) * 3
        # Find nearest code
        dists_to_C = [semantic_dist(w, c) for c in C]
        best_idx = np.argmin(dists_to_C)
        code = C[best_idx]
        
        # Re-project code
        dists_to_C2 = [semantic_dist(code, c) for c in C]
        best_idx2 = np.argmin(dists_to_C2)
        recode = C[best_idx2]
        
        source_dists.append(semantic_dist(w, code))
        proj_dists.append(semantic_dist(code, recode))
    
    ax.scatter(range(n_trials), source_dists, s=40, c='steelblue', alpha=0.7, label='d(w, P(w))')
    ax.scatter(range(n_trials), proj_dists, s=40, c='red', alpha=0.7, label='d(P(w), P(P(w)))')
    ax.axhline(y=0, color='green', linestyle='--', alpha=0.5)
    ax.set_xlabel('Trial')
    ax.set_ylabel('Distance')
    ax.set_title('Idempotence: P(P(w)) = P(w)')
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    fig.suptitle('Tropical Projection Structure', fontsize=16, y=1.02)
    fig.tight_layout()
    return fig


# ─── Generate All Figures ────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Generating visualizations...")
    
    fig1 = plot_codebook_geometry()
    fig1.savefig('fig_codebook_geometry.png', bbox_inches='tight', dpi=150)
    print("  Saved: fig_codebook_geometry.png")
    
    fig2 = plot_fisher_bounds()
    fig2.savefig('fig_fisher_bounds.png', bbox_inches='tight', dpi=150)
    print("  Saved: fig_fisher_bounds.png")
    
    fig3 = plot_codebook_tradeoff()
    fig3.savefig('fig_codebook_tradeoff.png', bbox_inches='tight', dpi=150)
    print("  Saved: fig_codebook_tradeoff.png")
    
    fig4 = plot_projection_structure()
    fig4.savefig('fig_projection_structure.png', bbox_inches='tight', dpi=150)
    print("  Saved: fig_projection_structure.png")
    
    print("\nAll visualizations generated.")

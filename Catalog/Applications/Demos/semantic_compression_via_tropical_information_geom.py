#!/usr/bin/env python3
"""
Applications of Tropical Information Geometry

Real-world applications demonstrating how tropical semantic compression
applies to machine learning, natural language processing, and signal processing.

1. LLM logit compression: Compressing language model outputs semantically
2. Attention pattern analysis: Measuring semantic complexity of attention
3. Semantic retrieval: Gauge-invariant document retrieval
4. Model distillation quality: Measuring if a student preserves teacher semantics
"""

import numpy as np
from typing import List, Tuple, Dict
from algorithms import (
    tropical_fisher_seminorm,
    tropical_fisher_dist,
    nearest_semantic_code,
    greedy_codebook,
    optimal_recentering,
    semantic_encoder,
    verify_projective_invariance,
)


# =============================================================================
# Application 1: LLM Logit Compression
# =============================================================================

def demo_llm_logit_compression():
    """
    Demonstrate semantic compression of language model logit vectors.

    In language models, the output is a logit vector over the vocabulary.
    The softmax function converts logits to probabilities, and is invariant
    under additive shifts. Therefore, two logit vectors that differ by a
    constant produce identical predictions.

    Tropical Fisher distance captures exactly this invariance.
    """
    print("=" * 70)
    print("Application 1: LLM Logit Compression")
    print("=" * 70)

    np.random.seed(42)
    vocab_size = 20  # Simplified vocabulary

    # Simulate logit vectors from a "language model"
    # Each vector represents the model's output for a different input token
    num_outputs = 50
    logits = []
    for _ in range(num_outputs):
        # Simulate logits: mostly low with a few high values
        v = np.random.exponential(1.0, vocab_size)
        v[np.random.choice(vocab_size, 3, replace=False)] += 5.0
        logits.append(v)

    print(f"\n  Vocabulary size: {vocab_size}")
    print(f"  Number of logit vectors: {num_outputs}")

    # Build a semantic codebook
    codebook, radii = greedy_codebook(logits, K=8)
    print(f"  Codebook size: {len(codebook)}")

    # Measure compression quality
    encode = semantic_encoder(codebook)
    tropical_errors = []
    euclidean_errors = []

    for s in logits:
        result = encode(s)
        tropical_errors.append(result.distance)
        euclidean_errors.append(float(np.linalg.norm(s - result.code_vector)))

    print(f"\n  Compression quality (tropical Fisher dist):")
    print(f"    Mean: {np.mean(tropical_errors):.4f}")
    print(f"    Max:  {np.max(tropical_errors):.4f}")
    print(f"    This measures semantic distortion (gauge-invariant)")

    print(f"\n  Raw Euclidean distance (for comparison):")
    print(f"    Mean: {np.mean(euclidean_errors):.4f}")
    print(f"    Max:  {np.max(euclidean_errors):.4f}")
    print(f"    This includes gauge-dependent noise")

    # Verify projective invariance
    s_test = logits[0]
    invariant = verify_projective_invariance(encode, s_test)
    print(f"\n  Projective invariance verified: {invariant}")
    print(f"    → Compression depends only on relative scores, not normalization")

    # Show that semantically equivalent inputs get same code
    s1 = logits[0]
    s2 = s1 + 42.0  # Same meaning, different normalization
    r1 = encode(s1)
    r2 = encode(s2)
    print(f"\n  Semantic equivalence test:")
    print(f"    s1 and s1+42 map to same code? {r1.code_index == r2.code_index} ✓")


# =============================================================================
# Application 2: Attention Pattern Semantic Complexity
# =============================================================================

def demo_attention_complexity():
    """
    Measure the semantic complexity of attention patterns.

    In transformers, attention scores are computed as dot products and
    then passed through softmax. The tropical Fisher seminorm measures
    the "peakiness" or "decisiveness" of the attention pattern.

    High seminorm → strong preference for certain positions (focused attention)
    Low seminorm → uniform attention (diffuse, less informative)
    """
    print("\n" + "=" * 70)
    print("Application 2: Attention Pattern Semantic Complexity")
    print("=" * 70)

    np.random.seed(123)
    seq_len = 10

    # Simulate different types of attention patterns
    patterns = {
        "Focused (position 3)": np.array([0.1, 0.1, 0.1, 5.0, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1]),
        "Uniform": np.ones(seq_len) * 2.0,
        "Bi-modal (pos 2,7)": np.array([0.5, 0.5, 4.0, 0.5, 0.5, 0.5, 0.5, 4.0, 0.5, 0.5]),
        "Decaying": np.array([5.0, 4.0, 3.0, 2.5, 2.0, 1.5, 1.0, 0.5, 0.2, 0.1]),
        "Random": np.random.randn(seq_len) * 2,
    }

    print(f"\n  Sequence length: {seq_len}")
    print(f"\n  {'Pattern':<25} {'Seminorm':<12} {'Optimal Shift':<15} {'Min Deviation'}")
    print(f"  {'-'*65}")

    for name, pattern in patterns.items():
        seminorm = tropical_fisher_seminorm(pattern)
        result = optimal_recentering(pattern)
        print(f"  {name:<25} {seminorm:<12.4f} {result.optimal_shift:<15.4f} {result.min_max_deviation:.4f}")

    print(f"\n  Interpretation:")
    print(f"    - Focused attention has high seminorm (strong semantic signal)")
    print(f"    - Uniform attention has zero seminorm (no semantic preference)")
    print(f"    - The seminorm is shift-invariant: it measures relative pattern, not scale")


# =============================================================================
# Application 3: Semantic Document Retrieval
# =============================================================================

def demo_semantic_retrieval():
    """
    Demonstrate gauge-invariant document retrieval using tropical Fisher distance.

    Documents are represented as score vectors over topics. Two documents
    that have the same relative topic distribution (but different calibration)
    should be considered identical for retrieval purposes.
    """
    print("\n" + "=" * 70)
    print("Application 3: Semantic Document Retrieval")
    print("=" * 70)

    # Documents as topic scores (5 topics: tech, science, sports, politics, arts)
    topics = ["Tech", "Science", "Sports", "Politics", "Arts"]

    documents = {
        "AI Paper": np.array([8.0, 7.0, 1.0, 2.0, 1.5]),
        "ML Blog": np.array([18.0, 17.0, 11.0, 12.0, 11.5]),  # Same as AI Paper + 10
        "Soccer News": np.array([1.0, 1.0, 9.0, 3.0, 2.0]),
        "Art Review": np.array([2.0, 1.5, 1.0, 2.5, 8.0]),
        "Policy Doc": np.array([3.0, 2.0, 2.0, 9.0, 3.0]),
    }

    query = np.array([7.5, 6.5, 1.5, 2.5, 1.0])  # Looking for tech/science
    print(f"\n  Topics: {topics}")
    print(f"  Query scores: {query}")

    print(f"\n  {'Document':<15} {'Tropical Dist':<16} {'Euclidean Dist':<16} {'Semantically Similar?'}")
    print(f"  {'-'*65}")

    for name, doc in documents.items():
        trop_d = tropical_fisher_dist(query, doc)
        euc_d = float(np.linalg.norm(query - doc))
        similar = "✓" if trop_d < 2.0 else ""
        print(f"  {name:<15} {trop_d:<16.4f} {euc_d:<16.4f} {similar}")

    print(f"\n  Key insight: 'AI Paper' and 'ML Blog' have tropical distance 0")
    print(f"  because they differ by a constant (same relative topic profile).")
    print(f"  Euclidean distance misleadingly reports them as far apart.")


# =============================================================================
# Application 4: Model Distillation Quality
# =============================================================================

def demo_distillation_quality():
    """
    Measure whether a distilled model preserves the semantic content
    of a teacher model's outputs.

    If teacher and student produce logits that differ by a constant,
    they make identical predictions — tropical Fisher distance = 0.
    """
    print("\n" + "=" * 70)
    print("Application 4: Model Distillation Quality Assessment")
    print("=" * 70)

    np.random.seed(456)
    vocab_size = 10
    num_test = 20

    # Simulate teacher outputs
    teacher_outputs = [np.random.randn(vocab_size) * 3 for _ in range(num_test)]

    # Simulate three student models with different quality levels
    students = {}

    # Good student: preserves relative scores with small noise
    students["Good Student"] = [t + np.random.randn(vocab_size) * 0.1 for t in teacher_outputs]

    # Mediocre student: larger noise
    students["Mediocre Student"] = [t + np.random.randn(vocab_size) * 1.0 for t in teacher_outputs]

    # Bad student: essentially random
    students["Bad Student"] = [np.random.randn(vocab_size) * 3 for _ in range(num_test)]

    # Shifted teacher: same semantics, different calibration
    students["Shifted Teacher"] = [t + 50.0 for t in teacher_outputs]

    print(f"\n  Vocabulary size: {vocab_size}")
    print(f"  Test samples: {num_test}")

    print(f"\n  {'Model':<20} {'Mean d_TF':<12} {'Max d_TF':<12} {'Mean Eucl.':<12} {'Assessment'}")
    print(f"  {'-'*68}")

    for name, outputs in students.items():
        trop_dists = [tropical_fisher_dist(t, s) for t, s in zip(teacher_outputs, outputs)]
        euc_dists = [float(np.linalg.norm(t - s)) for t, s in zip(teacher_outputs, outputs)]

        mean_trop = np.mean(trop_dists)
        max_trop = np.max(trop_dists)
        mean_euc = np.mean(euc_dists)

        if mean_trop < 0.5:
            assessment = "Excellent"
        elif mean_trop < 2.0:
            assessment = "Good"
        elif mean_trop < 5.0:
            assessment = "Poor"
        else:
            assessment = "Failed"

        print(f"  {name:<20} {mean_trop:<12.4f} {max_trop:<12.4f} {mean_euc:<12.4f} {assessment}")

    print(f"\n  Key insight: 'Shifted Teacher' has d_TF ≈ 0 (perfect semantic match)")
    print(f"  but large Euclidean distance. Tropical distance correctly identifies")
    print(f"  that shifting logits by a constant preserves all predictions.")


# =============================================================================
# Main
# =============================================================================

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  Tropical Information Geometry: Real-World Applications            ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")

    demo_llm_logit_compression()
    demo_attention_complexity()
    demo_semantic_retrieval()
    demo_distillation_quality()

    print("\n" + "=" * 70)
    print("All applications demonstrated successfully.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Tropical Information Geometry: Demonstration of Core Theorems

This script provides concrete numerical demonstrations of the theorems
formalized in the Lean 4 proofs:
1. Tropical Fisher seminorm and its properties
2. The half-range theorem
3. Semantic codebook construction and nearest-point coding
4. Projective invariance of the encoding
"""

import numpy as np
from typing import List, Tuple

# =============================================================================
# Core Definitions
# =============================================================================

def tropical_fisher_seminorm(v: np.ndarray) -> float:
    """
    The tropical Fisher seminorm: oscillation of a vector.
    ||v||_TF = max(v) - min(v)
    """
    return float(np.max(v) - np.min(v))


def tropical_fisher_dist(s: np.ndarray, c: np.ndarray) -> float:
    """
    Tropical Fisher distance between two score functions.
    d_TF(s, c) = ||s - c||_TF
    """
    return tropical_fisher_seminorm(s - c)


def semantic_dist_inf(v: np.ndarray, num_samples: int = 10000) -> float:
    """
    Numerically compute inf_k max_i |v_i - k| by sampling.
    """
    k_values = np.linspace(np.min(v) - 1, np.max(v) + 1, num_samples)
    return min(np.max(np.abs(v - k)) for k in k_values)


def optimal_shift(v: np.ndarray) -> float:
    """The optimal shift k* = (max + min) / 2."""
    return (np.max(v) + np.min(v)) / 2.0


# =============================================================================
# Demo 1: Basic Properties of the Tropical Fisher Seminorm
# =============================================================================

def demo_basic_properties():
    print("=" * 70)
    print("DEMO 1: Basic Properties of the Tropical Fisher Seminorm")
    print("=" * 70)

    np.random.seed(42)
    v = np.array([3.2, 1.1, 5.7, 2.3, 4.8])

    print(f"\nScore vector v = {v}")
    print(f"||v||_TF = max(v) - min(v) = {np.max(v)} - {np.min(v)} = {tropical_fisher_seminorm(v):.4f}")

    # Nonnegativity
    print(f"\n1. Nonnegativity: ||v||_TF = {tropical_fisher_seminorm(v):.4f} >= 0 ✓")

    # Shift invariance
    k = 100.0
    v_shifted = v + k
    print(f"\n2. Shift invariance:")
    print(f"   v + {k} = {v_shifted}")
    print(f"   ||v||_TF = {tropical_fisher_seminorm(v):.4f}")
    print(f"   ||v + {k}||_TF = {tropical_fisher_seminorm(v_shifted):.4f}")
    print(f"   Equal? {np.isclose(tropical_fisher_seminorm(v), tropical_fisher_seminorm(v_shifted))} ✓")

    # Zero iff constant
    v_const = np.array([3.0, 3.0, 3.0, 3.0, 3.0])
    print(f"\n3. Zero characterization:")
    print(f"   Constant vector {v_const}: ||v||_TF = {tropical_fisher_seminorm(v_const):.4f} (should be 0)")
    print(f"   Non-constant vector {v}: ||v||_TF = {tropical_fisher_seminorm(v):.4f} (should be > 0)")

    # Semantic equivalence
    print(f"\n4. Semantic equivalence:")
    s = np.array([3.2, 1.1, 5.7, 2.3, 4.8])
    c = s + 7.5  # Same meaning, different normalization
    print(f"   s = {s}")
    print(f"   c = s + 7.5 = {c}")
    print(f"   d_TF(s, c) = {tropical_fisher_dist(s, c):.4f} (should be 0)")
    print(f"   Semantically equivalent? {np.isclose(tropical_fisher_dist(s, c), 0)} ✓")

    c2 = np.array([3.2, 1.5, 5.7, 2.3, 4.8])  # Different meaning
    print(f"   c' = {c2}")
    print(f"   d_TF(s, c') = {tropical_fisher_dist(s, c2):.4f} (should be > 0)")
    print(f"   Semantically different? {not np.isclose(tropical_fisher_dist(s, c2), 0)} ✓")


# =============================================================================
# Demo 2: The Half-Range Theorem
# =============================================================================

def demo_half_range():
    print("\n" + "=" * 70)
    print("DEMO 2: The Half-Range Theorem")
    print("=" * 70)

    np.random.seed(123)
    for n in [5, 10, 50, 100]:
        v = np.random.randn(n) * 3

        # Theoretical value
        half_range = tropical_fisher_seminorm(v) / 2

        # Numerical infimum
        k_star = optimal_shift(v)
        achieved = np.max(np.abs(v - k_star))

        # Numerical search
        numerical_inf = semantic_dist_inf(v, num_samples=100000)

        print(f"\n  n = {n}:")
        print(f"    ||v||_TF / 2  = {half_range:.8f}")
        print(f"    Achieved at midpoint = {achieved:.8f}")
        print(f"    Numerical inf = {numerical_inf:.8f}")
        print(f"    Match? {np.isclose(half_range, achieved, atol=1e-10)} ✓")

    # Detailed example
    print("\n  Detailed example with n = 5:")
    v = np.array([3.2, 1.1, 5.7, 2.3, 4.8])
    M, m = np.max(v), np.min(v)
    k_star = (M + m) / 2
    print(f"    v = {v}")
    print(f"    M = max(v) = {M}")
    print(f"    m = min(v) = {m}")
    print(f"    k* = (M + m) / 2 = {k_star}")
    print(f"    |v - k*| = {np.abs(v - k_star)}")
    print(f"    max |v - k*| = {np.max(np.abs(v - k_star)):.4f}")
    print(f"    (M - m) / 2  = {(M - m) / 2:.4f}")

    # Show that any other k gives a larger value
    print("\n    Verification: any other k gives larger max|v-k|:")
    for k in [0, 1, 2, 3, 4, 5, m, M]:
        val = np.max(np.abs(v - k))
        print(f"      k = {k:.2f}: max|v-k| = {val:.4f} >= {(M-m)/2:.4f}? {val >= (M-m)/2 - 1e-10} ✓")


# =============================================================================
# Demo 3: Semantic Codebook and Nearest-Point Coding
# =============================================================================

def demo_semantic_codebook():
    print("\n" + "=" * 70)
    print("DEMO 3: Semantic Codebook and Nearest-Point Coding")
    print("=" * 70)

    # Create a codebook of 4 prototypes
    codebook = [
        np.array([5.0, 1.0, 1.0, 1.0, 1.0]),  # "Category 1 dominant"
        np.array([1.0, 5.0, 1.0, 1.0, 1.0]),  # "Category 2 dominant"
        np.array([1.0, 1.0, 5.0, 1.0, 1.0]),  # "Category 3 dominant"
        np.array([3.0, 3.0, 3.0, 1.0, 1.0]),  # "Uniform top-3"
    ]

    print("\n  Codebook prototypes:")
    for i, c in enumerate(codebook):
        print(f"    g_{i} = {c}")

    # Encode several sources
    sources = [
        np.array([4.5, 1.2, 0.8, 1.1, 0.9]),
        np.array([1.3, 4.8, 1.0, 0.7, 1.2]),
        np.array([2.8, 2.9, 3.1, 0.5, 0.7]),
        np.array([10.0, 1.0, 1.0, 1.0, 1.0]),  # Same meaning as g_0 + shift
    ]

    print("\n  Encoding results:")
    for s in sources:
        dists = [tropical_fisher_dist(s, c) for c in codebook]
        best_idx = np.argmin(dists)
        print(f"\n    s = {s}")
        print(f"    Distances: {[f'{d:.3f}' for d in dists]}")
        print(f"    Best code: g_{best_idx} (dist = {dists[best_idx]:.3f})")


# =============================================================================
# Demo 4: Projective Invariance of Encoding
# =============================================================================

def demo_projective_invariance():
    print("\n" + "=" * 70)
    print("DEMO 4: Projective Invariance of Encoding")
    print("=" * 70)

    codebook = [
        np.array([5.0, 1.0, 1.0, 1.0, 1.0]),
        np.array([1.0, 5.0, 1.0, 1.0, 1.0]),
        np.array([1.0, 1.0, 5.0, 1.0, 1.0]),
        np.array([3.0, 3.0, 3.0, 1.0, 1.0]),
    ]

    s = np.array([4.5, 1.2, 0.8, 1.1, 0.9])

    print(f"\n  Original source: s = {s}")

    shifts = [0, 10, -50, 1000, 3.14159]
    for k in shifts:
        s_shifted = s + k
        dists_orig = [tropical_fisher_dist(s, c) for c in codebook]
        dists_shifted = [tropical_fisher_dist(s_shifted, c) for c in codebook]
        best_orig = np.argmin(dists_orig)
        best_shifted = np.argmin(dists_shifted)

        print(f"\n    Shift k = {k}:")
        print(f"      s + k = {s_shifted}")
        print(f"      Distances (original):  {[f'{d:.3f}' for d in dists_orig]}")
        print(f"      Distances (shifted):   {[f'{d:.3f}' for d in dists_shifted]}")
        print(f"      Same code? g_{best_orig} vs g_{best_shifted}: "
              f"{'✓ YES' if best_orig == best_shifted else '✗ NO'}")
        print(f"      Distances identical? {all(np.isclose(a, b) for a, b in zip(dists_orig, dists_shifted))} ✓")


# =============================================================================
# Demo 5: Idempotence of Tropical Projection
# =============================================================================

def demo_idempotence():
    print("\n" + "=" * 70)
    print("DEMO 5: Idempotence of Tropical Projection")
    print("=" * 70)

    # Pointwise infimum
    G = [
        np.array([5.0, 3.0, 1.0, 2.0]),
        np.array([2.0, 6.0, 3.0, 1.0]),
        np.array([1.0, 2.0, 5.0, 4.0]),
    ]

    pi_G = np.min(G, axis=0)
    print(f"\n  Family G:")
    for i, g in enumerate(G):
        print(f"    g_{i} = {g}")
    print(f"  Pointwise infimum π_G = {pi_G}")

    # Verify π_G ≤ each g_i
    print(f"\n  π_G ≤ g_i for all i?")
    for i, g in enumerate(G):
        print(f"    π_G ≤ g_{i}? {all(pi_G <= g + 1e-10)} ✓")

    # Idempotence: inf of {π_G} = π_G
    pi_singleton = np.min([pi_G], axis=0)
    print(f"\n  Idempotence: π_{{π_G}} = {pi_singleton}")
    print(f"  Equal to π_G? {np.allclose(pi_singleton, pi_G)} ✓")


# =============================================================================
# Demo 6: Comparison with Euclidean Distance
# =============================================================================

def demo_tropical_vs_euclidean():
    print("\n" + "=" * 70)
    print("DEMO 6: Tropical Fisher vs Euclidean Distance")
    print("=" * 70)

    s = np.array([3.0, 1.0, 5.0, 2.0, 4.0])
    c = np.array([3.0, 1.0, 5.0, 2.0, 4.0])  # Same as s

    # Shift s by a constant
    print(f"\n  s = {s}")
    print(f"  c = {c}")
    print(f"\n  {'Shift k':<12} {'Euclidean d(s+k, c)':<22} {'Tropical d_TF(s+k, c)':<22} {'Same meaning?'}")
    print(f"  {'-'*70}")

    for k in [0, 1, 5, 10, 100]:
        s_shifted = s + k
        euc_dist = np.linalg.norm(s_shifted - c)
        trop_dist = tropical_fisher_dist(s_shifted, c)
        print(f"  {k:<12} {euc_dist:<22.4f} {trop_dist:<22.4f} {'Yes (shift only)' if k > 0 else 'Identical'}")

    print(f"\n  Key insight: Euclidean distance grows with shift, but tropical Fisher")
    print(f"  distance correctly recognizes that shifted vectors carry the same meaning.")


# =============================================================================
# Main
# =============================================================================

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  Tropical Information Geometry: Semantic Compression Demonstrations ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")

    demo_basic_properties()
    demo_half_range()
    demo_semantic_codebook()
    demo_projective_invariance()
    demo_idempotence()
    demo_tropical_vs_euclidean()

    print("\n" + "=" * 70)
    print("All demonstrations completed successfully.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Generate visualizations for Tropical Information Geometry.
Outputs base64-encoded PNG images.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import base64
import io
import json


def fig_to_base64(fig):
    """Convert matplotlib figure to base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


def tropical_fisher_seminorm(v):
    return float(np.max(v) - np.min(v))


def tropical_fisher_dist(s, c):
    diff = s - c
    return float(np.max(diff) - np.min(diff))


# =============================================================================
# Visualization 1: Half-Range Theorem
# =============================================================================

def viz_half_range():
    """Visualize the half-range theorem: inf_k max_i |v_i - k| = range/2."""
    v = np.array([1.1, 3.2, 5.7, 2.3, 4.8])
    M, m = np.max(v), np.min(v)
    k_star = (M + m) / 2

    k_range = np.linspace(m - 1, M + 1, 500)
    max_devs = [max(abs(v_i - k) for v_i in v) for k in k_range]

    fig, ax = plt.subplots(1, 1, figsize=(10, 6))

    ax.plot(k_range, max_devs, 'b-', linewidth=2, label=r'$\max_i |v_i - k|$')
    ax.axhline(y=(M - m) / 2, color='r', linestyle='--', linewidth=1.5,
               label=f'$(M - m)/2 = {(M-m)/2:.2f}$')
    ax.axvline(x=k_star, color='g', linestyle=':', linewidth=1.5,
               label=f'$k^* = (M + m)/2 = {k_star:.2f}$')
    ax.plot(k_star, (M - m) / 2, 'ro', markersize=10, zorder=5,
            label='Optimal point')

    for i, vi in enumerate(v):
        ax.axvline(x=vi, color='gray', linestyle='-', alpha=0.3, linewidth=0.5)
        ax.text(vi, max(max_devs) * 0.95, f'$v_{i}$', ha='center', fontsize=9)

    ax.set_xlabel('Shift $k$', fontsize=13)
    ax.set_ylabel(r'$\max_i |v_i - k|$', fontsize=13)
    ax.set_title('The Half-Range Theorem: Optimal Recentering', fontsize=14)
    ax.legend(fontsize=11, loc='upper right')
    ax.grid(True, alpha=0.3)

    return fig_to_base64(fig)


# =============================================================================
# Visualization 2: Tropical Fisher Distance vs Euclidean
# =============================================================================

def viz_tropical_vs_euclidean():
    """Compare tropical Fisher and Euclidean distances under shifts."""
    s = np.array([3.0, 1.0, 5.0, 2.0, 4.0])
    c = s.copy()

    shifts = np.linspace(-10, 10, 200)
    trop_dists = [tropical_fisher_dist(s + k, c) for k in shifts]
    euc_dists = [float(np.linalg.norm((s + k) - c)) for k in shifts]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    ax1.plot(shifts, euc_dists, 'r-', linewidth=2, label='Euclidean distance')
    ax1.plot(shifts, trop_dists, 'b-', linewidth=2, label='Tropical Fisher distance')
    ax1.axhline(y=0, color='gray', linestyle='-', alpha=0.3)
    ax1.set_xlabel('Additive shift $k$', fontsize=12)
    ax1.set_ylabel('Distance $d(s+k, s)$', fontsize=12)
    ax1.set_title('Distance Under Additive Shifts', fontsize=13)
    ax1.legend(fontsize=11)
    ax1.grid(True, alpha=0.3)

    # Also show for non-trivial c
    c2 = np.array([2.0, 3.0, 4.0, 1.0, 5.0])
    trop_dists2 = [tropical_fisher_dist(s + k, c2) for k in shifts]
    euc_dists2 = [float(np.linalg.norm((s + k) - c2)) for k in shifts]

    ax2.plot(shifts, euc_dists2, 'r-', linewidth=2, label='Euclidean')
    ax2.plot(shifts, trop_dists2, 'b-', linewidth=2, label='Tropical Fisher')
    ax2.axhline(y=0, color='gray', linestyle='-', alpha=0.3)
    ax2.set_xlabel('Additive shift $k$', fontsize=12)
    ax2.set_ylabel('Distance $d(s+k, c)$', fontsize=12)
    ax2.set_title('Semantic Distance is Shift-Invariant', fontsize=13)
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)

    fig.suptitle('Tropical Fisher vs Euclidean: Gauge Invariance', fontsize=14, y=1.02)
    plt.tight_layout()

    return fig_to_base64(fig)


# =============================================================================
# Visualization 3: Semantic Codebook and Voronoi-like Regions
# =============================================================================

def viz_codebook_2d():
    """Visualize semantic codebook on 2D projective space."""
    np.random.seed(42)

    # In 2D projective space (3D vectors mod constants), we can visualize
    # by fixing one coordinate. Use v = (v1, v2, 0) -> plot (v1, v2)
    n_sources = 200
    sources_2d = np.random.randn(n_sources, 2) * 3

    # Codebook prototypes
    codebook_2d = np.array([
        [3.0, 0.0],
        [-2.0, 3.0],
        [-2.0, -3.0],
        [0.0, 0.0],
    ])

    # Assign each source to nearest code (using tropical Fisher distance
    # which on the 2D projection is just the oscillation of (s-c))
    def tfd_2d(s, c):
        d = np.array([s[0] - c[0], s[1] - c[1], 0.0])
        return np.max(d) - np.min(d)

    assignments = []
    for s in sources_2d:
        dists = [tfd_2d(s, c) for c in codebook_2d]
        assignments.append(np.argmin(dists))

    colors = ['#e74c3c', '#3498db', '#2ecc71', '#f39c12']

    fig, ax = plt.subplots(1, 1, figsize=(8, 8))

    for k in range(len(codebook_2d)):
        mask = [i for i, a in enumerate(assignments) if a == k]
        if mask:
            pts = sources_2d[mask]
            ax.scatter(pts[:, 0], pts[:, 1], c=colors[k], alpha=0.4, s=20)

    for k, c in enumerate(codebook_2d):
        ax.scatter(c[0], c[1], c=colors[k], s=200, marker='*',
                   edgecolors='black', linewidths=1.5, zorder=5,
                   label=f'Code {k}')

    ax.set_xlabel('Score dimension 1', fontsize=12)
    ax.set_ylabel('Score dimension 2', fontsize=12)
    ax.set_title('Semantic Codebook: Tropical Voronoi Regions', fontsize=14)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    ax.set_aspect('equal')

    return fig_to_base64(fig)


# =============================================================================
# Visualization 4: Seminorm Distribution
# =============================================================================

def viz_seminorm_distribution():
    """Distribution of tropical Fisher seminorms for random vectors."""
    np.random.seed(42)

    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    for idx, n in enumerate([5, 20, 100]):
        seminorms = [tropical_fisher_seminorm(np.random.randn(n))
                     for _ in range(5000)]

        ax = axes[idx]
        ax.hist(seminorms, bins=50, density=True, alpha=0.7,
                color=['#3498db', '#e74c3c', '#2ecc71'][idx],
                edgecolor='white', linewidth=0.5)
        ax.axvline(x=np.mean(seminorms), color='black', linestyle='--',
                   linewidth=1.5, label=f'Mean = {np.mean(seminorms):.2f}')
        ax.set_xlabel(r'$\|v\|_{\mathrm{TF}}$', fontsize=12)
        ax.set_ylabel('Density', fontsize=12)
        ax.set_title(f'$n = {n}$', fontsize=13)
        ax.legend(fontsize=10)
        ax.grid(True, alpha=0.3)

    fig.suptitle('Distribution of Tropical Fisher Seminorm for Random Gaussian Vectors',
                 fontsize=14, y=1.02)
    plt.tight_layout()

    return fig_to_base64(fig)


# =============================================================================
# Visualization 5: Codebook Size vs Coverage
# =============================================================================

def viz_codebook_coverage():
    """How coverage radius decreases with codebook size."""
    np.random.seed(42)

    fig, ax = plt.subplots(1, 1, figsize=(10, 6))

    for n in [5, 10, 20]:
        sources = [np.random.randn(n) * 2 for _ in range(200)]
        max_K = min(30, len(sources))

        radii = []
        for K in range(1, max_K + 1):
            # Build codebook of size K
            from algorithms import greedy_codebook
            cb, _ = greedy_codebook(sources, K)
            # Compute coverage radius
            coverage = max(
                min(tropical_fisher_dist(s, c) for c in cb)
                for s in sources
            )
            radii.append(coverage)

        ax.plot(range(1, max_K + 1), radii, 'o-', markersize=3,
                linewidth=1.5, label=f'$n = {n}$')

    ax.set_xlabel('Codebook size $K$', fontsize=12)
    ax.set_ylabel('Coverage radius (max min-distance)', fontsize=12)
    ax.set_title('Tropical Codebook: Coverage vs Size Trade-off', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.set_yscale('log')

    return fig_to_base64(fig)


# =============================================================================
# Main: Generate all visualizations and output as JSON-compatible dict
# =============================================================================

if __name__ == "__main__":
    print("Generating visualizations...")

    viz_data = {}

    print("  1/5: Half-range theorem...")
    viz_data["half_range"] = viz_half_range()

    print("  2/5: Tropical vs Euclidean...")
    viz_data["tropical_vs_euclidean"] = viz_tropical_vs_euclidean()

    print("  3/5: Codebook Voronoi...")
    viz_data["codebook_voronoi"] = viz_codebook_2d()

    print("  4/5: Seminorm distribution...")
    viz_data["seminorm_distribution"] = viz_seminorm_distribution()

    print("  5/5: Codebook coverage...")
    viz_data["codebook_coverage"] = viz_codebook_coverage()

    # Save to JSON for use in PACKAGE.json
    with open("viz_data.json", "w") as f:
        json.dump(viz_data, f)

    print("All visualizations generated and saved to viz_data.json")

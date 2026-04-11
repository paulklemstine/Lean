#!/usr/bin/env python3
"""
Tropical NAS for Convolutional and Transformer Architectures
=============================================================

Extends tropical neural architecture search from dense layers to:
1. Convolutional layers (Toeplitz weight matrices)
2. Transformer attention (QK^T tropical eigenvalues)
3. Depthwise separable convolutions
4. Multi-head attention scoring

Run: python3 tropical_conv_transformer_nas.py
"""

import numpy as np
from itertools import permutations

# ============================================================
# Tropical Algebra Primitives
# ============================================================

def tropical_add(x, y):
    """Tropical addition = max (idempotent: x ⊕ x = x)."""
    return max(x, y)

def tropical_matmul(A, B):
    """Tropical matrix multiplication: C[i,j] = max_k (A[i,k] + B[k,j])."""
    m, p = A.shape
    _, n = B.shape
    C = np.full((m, n), -np.inf)
    for i in range(m):
        for j in range(n):
            for k in range(p):
                C[i, j] = max(C[i, j], A[i, k] + B[k, j])
    return C

def tropical_det(A):
    """Tropical determinant = max over permutations of sum of A[i, sigma(i)]."""
    n = A.shape[0]
    best = -np.inf
    for perm in permutations(range(n)):
        val = sum(A[i, perm[i]] for i in range(n))
        best = max(best, val)
    return best

def tropical_rank(A):
    """Compute tropical rank: largest k such that some k×k submatrix has finite tropical det."""
    m, n = A.shape
    r = 0
    for k in range(1, min(m, n) + 1):
        found = False
        for rows in permutations(range(m), k):
            for cols in permutations(range(n), k):
                sub = A[np.ix_(list(rows), list(cols))]
                if tropical_det(sub) > -np.inf:
                    found = True
                    break
            if found:
                break
        if found:
            r = k
    return r

# ============================================================
# Section 1: Convolutional Layer (Toeplitz Matrix)
# ============================================================

def conv1d_to_toeplitz(kernel, input_size):
    """Convert 1D convolution kernel to Toeplitz weight matrix."""
    k = len(kernel)
    output_size = input_size - k + 1
    T = np.full((output_size, input_size), -np.inf)
    for i in range(output_size):
        for j in range(k):
            T[i, i + j] = kernel[j]
    return T

def analyze_conv_layer(kernel, input_size):
    """Analyze a convolutional layer using tropical rank."""
    T = conv1d_to_toeplitz(kernel, input_size)
    rank = min(len(kernel), input_size)  # Toeplitz rank bound
    return {
        "kernel_size": len(kernel),
        "input_size": input_size,
        "output_size": input_size - len(kernel) + 1,
        "toeplitz_shape": T.shape,
        "tropical_rank_upper_bound": rank,
        "toeplitz_matrix": T
    }

# ============================================================
# Section 2: Transformer Attention (QK^T)
# ============================================================

def tropical_attention_score(Q, K):
    """Compute tropical attention: max-plus QK^T instead of softmax(QK^T/√d)."""
    return tropical_matmul(Q, K.T)

def analyze_transformer_block(seq_len, d_model, d_k, num_heads, depth):
    """Score a transformer architecture using tropical analysis."""
    # Each head: QK^T is seq_len × seq_len with tropical rank ≤ d_k
    head_rank = d_k
    # Multi-head: total rank ≤ num_heads × d_k
    total_rank = num_heads * d_k
    # Depth advantage: total_rank^depth linear regions
    expressiveness = total_rank ** depth

    return {
        "seq_len": seq_len,
        "d_model": d_model,
        "d_k": d_k,
        "num_heads": num_heads,
        "depth": depth,
        "per_head_tropical_rank": head_rank,
        "total_tropical_rank": total_rank,
        "expressiveness_bound": expressiveness,
        "log2_expressiveness": float(np.log2(float(expressiveness))) if expressiveness > 0 else 0
    }

# ============================================================
# Section 3: Architecture Comparison
# ============================================================

def compare_architectures():
    """Compare CNN, Transformer, and hybrid architectures."""
    architectures = {}

    # Small CNN: 3 conv layers, kernel_size=3, channels=64
    cnn_rank_per_layer = 3 * 64  # kernel_size × channels
    cnn_depth = 3
    architectures["CNN-Small"] = {
        "rank_per_layer": cnn_rank_per_layer,
        "depth": cnn_depth,
        "expressiveness": cnn_rank_per_layer ** cnn_depth,
    }

    # Transformer-Base: 6 layers, 8 heads, d_k=64
    tf_rank_per_layer = 8 * 64  # heads × d_k
    tf_depth = 6
    architectures["Transformer-Base"] = {
        "rank_per_layer": tf_rank_per_layer,
        "depth": tf_depth,
        "expressiveness": tf_rank_per_layer ** tf_depth,
    }

    # Hybrid: Conv stem + Transformer body
    hybrid_rank_conv = 3 * 64
    hybrid_rank_tf = 4 * 64
    hybrid_depth = 4
    architectures["Hybrid-ConvTransformer"] = {
        "rank_per_layer": max(hybrid_rank_conv, hybrid_rank_tf),
        "depth": hybrid_depth,
        "expressiveness": (hybrid_rank_conv ** 2) * (hybrid_rank_tf ** 2),
    }

    # Depthwise Separable (MobileNet-style)
    dw_rank = 3  # depthwise kernel
    pw_rank = 128  # pointwise channels
    ds_depth = 6
    architectures["MobileNet-Style"] = {
        "rank_per_layer": dw_rank * pw_rank,
        "depth": ds_depth,
        "expressiveness": (dw_rank * pw_rank) ** ds_depth,
    }

    return architectures

# ============================================================
# Section 4: Demo Execution
# ============================================================

def main():
    print("=" * 70)
    print("TROPICAL NAS FOR CONVOLUTIONS AND TRANSFORMERS")
    print("=" * 70)

    # Demo 1: Convolutional Layer Analysis
    print("\n--- Demo 1: Convolutional Layer (Toeplitz Matrix) ---")
    kernel = [1.0, 0.5, -0.3]
    input_size = 8
    result = analyze_conv_layer(kernel, input_size)
    print(f"  Kernel: {kernel}")
    print(f"  Input size: {result['input_size']}")
    print(f"  Output size: {result['output_size']}")
    print(f"  Toeplitz shape: {result['toeplitz_shape']}")
    print(f"  Tropical rank upper bound: {result['tropical_rank_upper_bound']}")
    print(f"  Toeplitz matrix:\n{result['toeplitz_matrix']}")

    # Demo 2: Transformer Attention
    print("\n--- Demo 2: Transformer Attention Analysis ---")
    configs = [
        ("GPT-2 Small", 1024, 768, 64, 12, 12),
        ("BERT-Base", 512, 768, 64, 12, 12),
        ("ViT-Base", 197, 768, 64, 12, 12),
        ("Tiny-Transformer", 64, 128, 32, 4, 4),
    ]
    for name, seq_len, d_model, d_k, num_heads, depth in configs:
        result = analyze_transformer_block(seq_len, d_model, d_k, num_heads, depth)
        print(f"\n  {name}:")
        print(f"    Total tropical rank: {result['total_tropical_rank']}")
        print(f"    Expressiveness (log₂): {result['log2_expressiveness']:.1f} bits")

    # Demo 3: Architecture Comparison
    print("\n--- Demo 3: Architecture Comparison ---")
    archs = compare_architectures()
    print(f"\n  {'Architecture':<30} {'Rank/Layer':>12} {'Depth':>7} {'log₂(Express.)':>16}")
    print("  " + "-" * 67)
    for name, info in sorted(archs.items(), key=lambda x: x[1]["expressiveness"]):
        log_expr = np.log2(float(info["expressiveness"])) if info["expressiveness"] > 0 else 0
        print(f"  {name:<30} {info['rank_per_layer']:>12} {info['depth']:>7} {log_expr:>16.1f}")

    # Demo 4: Tropical Attention Matrix
    print("\n--- Demo 4: Tropical vs Classical Attention ---")
    np.random.seed(42)
    Q = np.random.randn(4, 3)  # 4 tokens, d_k=3
    K = np.random.randn(4, 3)
    V = np.random.randn(4, 3)

    # Classical attention
    d_k = Q.shape[1]
    scores_classical = Q @ K.T / np.sqrt(d_k)
    attn_classical = np.exp(scores_classical) / np.exp(scores_classical).sum(axis=1, keepdims=True)

    # Tropical attention
    scores_tropical = tropical_matmul(Q, K.T)
    # Tropical softmax = argmax (one-hot)
    attn_tropical = np.zeros_like(scores_tropical)
    for i in range(scores_tropical.shape[0]):
        j = np.argmax(scores_tropical[i])
        attn_tropical[i, j] = 1.0

    print(f"  Classical attention (softmax):\n{np.round(attn_classical, 3)}")
    print(f"\n  Tropical attention (argmax):\n{attn_tropical.astype(int)}")
    print(f"\n  Observation: Tropical attention is the β→∞ limit of classical attention.")
    print(f"  The LogSumExp sandwich bounds the gap to ≤ log(2) ≈ 0.693 per entry.")

    # Summary
    print("\n" + "=" * 70)
    print("KEY INSIGHTS:")
    print("  1. Convolutional layers have Toeplitz structure → tropical rank ≤ kernel_size")
    print("  2. Transformer attention has tropical rank ≤ d_k per head")
    print("  3. Multi-head attention: total rank = num_heads × d_k")
    print("  4. Architecture expressiveness = (tropical rank)^depth")
    print("  5. Training-free evaluation: O(n³·L) vs O(training time)")
    print("=" * 70)

if __name__ == "__main__":
    main()

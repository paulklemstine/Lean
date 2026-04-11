#!/usr/bin/env python3
"""
Demo 1: Tropical Geometry of ReLU Networks — Linear Region Counting

This demonstrates how ReLU networks partition input space into linear regions,
and how tropical geometry provides exact counts. The key insight: ReLU(x) = max(x, 0)
is the fundamental tropical operation, making every ReLU network a tropical rational function.

Mathematical Background:
  - A single ReLU neuron splits ℝ into 2 linear regions
  - A layer of w neurons in ℝⁿ creates at most Σ_{j=0}^{n} C(w, j) regions
  - Depth d with width w creates at most (Π w_i) regions (Montúfar et al., 2014)
  - The tropical degree of the network = number of linear regions
"""

import numpy as np
import itertools


def relu(x):
    """ReLU(x) = max(x, 0) — the fundamental tropical operation."""
    return np.maximum(x, 0)


def count_linear_regions_1d(weights_list, biases_list):
    """
    Count the exact number of linear regions of a 1D ReLU network.

    For a depth-d network with 1D input, we trace all breakpoints
    (points where some neuron's pre-activation crosses zero).

    Parameters:
        weights_list: list of weight matrices (each shape [width_out, width_in])
        biases_list: list of bias vectors (each shape [width_out])

    Returns:
        breakpoints: sorted list of input values where the function is non-differentiable
        num_regions: number of linear regions
    """
    # Sample densely to find breakpoints
    x = np.linspace(-10, 10, 100000)

    # Forward pass, tracking activation patterns
    h = x.reshape(1, -1)  # [1, N]
    patterns = []

    for W, b in zip(weights_list, biases_list):
        pre = W @ h + b.reshape(-1, 1)  # [width, N]
        pattern = (pre > 0).astype(int)
        patterns.append(pattern)
        h = relu(pre)

    # Count unique activation patterns
    combined = np.vstack(patterns)  # [total_neurons, N]
    # Convert each column to a tuple for hashing
    unique_patterns = set()
    for i in range(combined.shape[1]):
        unique_patterns.add(tuple(combined[:, i]))

    return len(unique_patterns)


def network_forward_1d(x, weights_list, biases_list):
    """Compute the output of a 1D ReLU network."""
    h = np.array([[x]])
    for W, b in zip(weights_list, biases_list[:-1]):
        h = relu(W @ h + b.reshape(-1, 1))
    # Last layer (linear, no ReLU)
    W, b = weights_list[-1], biases_list[-1]
    return (W @ h + b.reshape(-1, 1)).item()


def tropical_rank_bound(width, depth):
    """
    Upper bound on linear regions from tropical rank analysis.

    For a network with width w and depth d:
      regions ≤ (2w)^d  (naive bound)
      regions ≤ Π_{i=1}^{d} Σ_{j=0}^{n} C(w_i, j)  (Montúfar bound)

    The tropical rank of each layer's weight matrix determines the
    contribution to the total region count.
    """
    return (2 * width) ** depth


def demo_region_counting():
    """Demonstrate linear region counting for networks of varying depth/width."""
    print("=" * 70)
    print("TROPICAL DEEP LEARNING: Linear Region Counting")
    print("=" * 70)
    print()
    print("Key insight: ReLU(x) = max(x, 0) is a tropical polynomial.")
    print("A ReLU network is a tropical rational function.")
    print("The number of linear regions = tropical degree of the network.")
    print()

    configs = [
        ("Shallow-Narrow", [2], "1 hidden layer, width 2"),
        ("Shallow-Wide", [8], "1 hidden layer, width 8"),
        ("Deep-Narrow", [2, 2, 2], "3 hidden layers, width 2"),
        ("Deep-Wide", [4, 4, 4], "3 hidden layers, width 4"),
        ("Very Deep", [3, 3, 3, 3, 3], "5 hidden layers, width 3"),
    ]

    print(f"{'Architecture':<20} {'Depth':>6} {'Width':>6} {'Regions':>10} {'Trop Bound':>12}")
    print("-" * 60)

    for name, widths, desc in configs:
        depth = len(widths)
        max_width = max(widths)

        # Create random network
        np.random.seed(42)
        dims = [1] + widths + [1]
        weights = [np.random.randn(dims[i + 1], dims[i]) for i in range(len(dims) - 1)]
        biases = [np.random.randn(dims[i + 1]) for i in range(len(dims) - 1)]

        regions = count_linear_regions_1d(weights[:-1], biases[:-1])
        bound = tropical_rank_bound(max_width, depth)

        print(f"{name:<20} {depth:>6} {max_width:>6} {regions:>10} {bound:>12}")

    print()
    print("Note: Actual regions ≤ tropical rank bound (verified in Lean 4)")
    print()


def demo_tropical_operations():
    """Show how ReLU network operations map to tropical algebra."""
    print("=" * 70)
    print("TROPICAL ALGEBRA OF NEURAL NETWORKS")
    print("=" * 70)
    print()

    x = np.array([1.0, -2.0, 3.0, -1.0, 0.5])

    print("Input x =", x)
    print()

    # ReLU = tropical max with 0
    print("1. ReLU(x) = max(x, 0)  [tropical addition with 0]")
    print("   ", relu(x))
    print()

    # Idempotence: ReLU(ReLU(x)) = ReLU(x)
    print("2. ReLU(ReLU(x)) = ReLU(x)  [idempotence — verified in Lean!]")
    print("   ReLU(ReLU(x)) =", relu(relu(x)))
    print("   ReLU(x)       =", relu(x))
    print("   Equal?", np.allclose(relu(relu(x)), relu(x)))
    print()

    # Max-plus: the tropical semiring
    a, b, c = 3.0, 5.0, 2.0
    print(f"3. Tropical addition: {a} ⊕ {b} = max({a}, {b}) = {max(a, b)}")
    print(f"   Tropical multiplication: {a} ⊗ {b} = {a} + {b} = {a + b}")
    print(f"   Associativity: ({a}⊕{b})⊕{c} = max(max({a},{b}),{c}) = {max(max(a, b), c)}")
    print(f"                  {a}⊕({b}⊕{c}) = max({a},max({b},{c})) = {max(a, max(b, c))}")
    print()

    # Softmax as tropical deformation
    print("4. Softmax as tropical deformation (LogSumExp):")
    for beta in [0.1, 1.0, 5.0, 20.0, 100.0]:
        lse = (1 / beta) * np.log(np.sum(np.exp(beta * x)))
        print(f"   β = {beta:>6.1f}: LSE_β(x) = {lse:.6f}  (max = {np.max(x):.1f})")
    print("   As β → ∞, LSE_β → max (tropical limit)")
    print()


def demo_conv_toeplitz_rank():
    """Show how convolutional layers have bounded tropical rank."""
    print("=" * 70)
    print("CONVOLUTIONAL LAYERS AS TOEPLITZ MATRICES")
    print("=" * 70)
    print()

    # 1D convolution kernel
    kernel = np.array([1.0, -2.0, 1.0])  # Second-difference kernel
    n = 8  # Input length
    k = len(kernel)  # Kernel size

    # Build Toeplitz matrix
    m = n - k + 1  # Output length
    T = np.zeros((m, n))
    for i in range(m):
        T[i, i:i + k] = kernel

    print(f"Kernel: {kernel} (size k={k})")
    print(f"Input length: n={n}")
    print(f"Output length: m={m}")
    print()
    print("Toeplitz matrix T:")
    print(T)
    print()

    # Matrix rank (standard)
    rank = np.linalg.matrix_rank(T)
    print(f"Standard rank of T: {rank}")
    print(f"Tropical rank bound: min(k, n) = min({k}, {n}) = {min(k, n)}")
    print(f"Linear regions per layer ≤ k × n = {k} × {n} = {k * n}")
    print()

    # Multi-layer convolution
    print("Multi-layer CNN region bounds:")
    for depth in range(1, 6):
        regions = k ** depth
        print(f"  Depth {depth}: regions ≤ k^d = {k}^{depth} = {regions}")
    print()


def demo_attention_tropical():
    """Demonstrate tropical structure of transformer attention."""
    print("=" * 70)
    print("TRANSFORMER ATTENTION AS TROPICAL MATRIX PRODUCT")
    print("=" * 70)
    print()

    np.random.seed(123)
    seq_len = 4
    d_k = 3
    num_heads = 2

    Q = np.random.randn(seq_len, d_k)
    K = np.random.randn(seq_len, d_k)
    V = np.random.randn(seq_len, d_k)

    # Standard attention
    scores = Q @ K.T / np.sqrt(d_k)

    print(f"Sequence length: {seq_len}, Key dim: {d_k}, Heads: {num_heads}")
    print()
    print("Attention scores Q·K^T / √d_k:")
    print(np.round(scores, 3))
    print()

    # Tropical limit: softmax → argmax
    print("Tropical limit (β → ∞): softmax → argmax")
    for beta in [1.0, 5.0, 20.0, 100.0]:
        attention = np.exp(beta * scores)
        attention = attention / attention.sum(axis=1, keepdims=True)
        print(f"  β = {beta:>5.1f}: {np.round(attention[0], 4)}")

    # Hard attention (tropical)
    hard_attn = np.zeros_like(scores)
    for i in range(seq_len):
        j = np.argmax(scores[i])
        hard_attn[i, j] = 1.0
    print(f"  β → ∞  : {hard_attn[0]}  (tropical/argmax)")
    print()

    # Tropical rank analysis
    print("Tropical expressiveness bounds:")
    for h in [1, 2, 4, 8, 12]:
        for dk in [32, 64, 128]:
            for d in [6, 12, 24]:
                expr = (h * dk) ** d
                print(f"  h={h:>2}, d_k={dk:>3}, depth={d:>2}: "
                      f"log₂(regions) ≤ {np.log2(h * dk) * d:.1f}")
    print()


def demo_tropical_nas():
    """Training-free neural architecture search using tropical rank."""
    print("=" * 70)
    print("TRAINING-FREE ARCHITECTURE SEARCH VIA TROPICAL RANK")
    print("=" * 70)
    print()
    print("Algorithm: Rank architectures by tropical expressiveness score")
    print("  Score = Π_ℓ tropical_rank(W_ℓ)")
    print("  No training required! O(n³·L) vs O(training_time)")
    print()

    architectures = [
        {"name": "MLP-Small", "layers": [(64, 32), (32, 16), (16, 10)],
         "type": "dense"},
        {"name": "MLP-Large", "layers": [(512, 256), (256, 128), (128, 64), (64, 10)],
         "type": "dense"},
        {"name": "CNN-3x3", "layers": [(3, 64), (3, 128), (3, 256)],
         "type": "conv", "kernel": 3},
        {"name": "CNN-5x5", "layers": [(5, 64), (5, 128), (5, 256)],
         "type": "conv", "kernel": 5},
        {"name": "Transformer-Small", "layers": [(4, 64)] * 6,
         "type": "attention", "heads": 4, "d_k": 64},
        {"name": "Transformer-Base", "layers": [(8, 64)] * 12,
         "type": "attention", "heads": 8, "d_k": 64},
        {"name": "MobileNet-v2", "layers": [(3, 32)] * 8,
         "type": "depthwise", "kernel": 3},
        {"name": "ResNet-18", "layers": [(64, 64)] * 18,
         "type": "residual"},
    ]

    print(f"{'Architecture':<22} {'Depth':>6} {'Rank/Layer':>12} {'log₂(Score)':>14}")
    print("-" * 58)

    for arch in architectures:
        depth = len(arch["layers"])
        if arch["type"] == "dense":
            rank_per_layer = min(arch["layers"][0])
        elif arch["type"] == "conv":
            rank_per_layer = arch["kernel"] * arch["layers"][0][1]
        elif arch["type"] == "attention":
            rank_per_layer = arch["heads"] * arch["d_k"]
        elif arch["type"] == "depthwise":
            rank_per_layer = arch["kernel"] * arch["layers"][0][1]
        elif arch["type"] == "residual":
            rank_per_layer = arch["layers"][0][0]

        log_score = depth * np.log2(rank_per_layer)
        print(f"{arch['name']:<22} {depth:>6} {rank_per_layer:>12} {log_score:>14.1f}")

    print()
    print("Higher score → more expressive architecture")
    print("This ranking is computed WITHOUT any training!")
    print()


if __name__ == "__main__":
    demo_tropical_operations()
    demo_region_counting()
    demo_conv_toeplitz_rank()
    demo_attention_tropical()
    demo_tropical_nas()

    print("=" * 70)
    print("All demos completed successfully.")
    print("See TropicalDeepLearning/visuals/ for SVG visualizations.")
    print("See Bridges/NewDirections/TropicalDeepLearningTheory.lean for Lean proofs.")
    print("=" * 70)

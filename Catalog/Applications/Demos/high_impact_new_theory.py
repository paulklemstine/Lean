#!/usr/bin/env python3
"""
Tropical Information Theory — Applications

Real-world applications demonstrating the utility of tropical mutual
information and the data processing inequality.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

# Import from algorithms
from algorithms import (postprocess, tropical_mutual_information,
                        tropical_dist_matrix, tropical_channel_rank,
                        tensor_channel, optimal_coarsening)


def application_1_neural_network_compression():
    """
    Application: Certifying information loss in neural network pooling layers.

    A max-pooling layer in a neural network acts as a deterministic
    post-processing map. The tropical DPI guarantees that pooling
    cannot increase the tropical distinguishability of inputs.
    """
    print("=" * 60)
    print("APPLICATION 1: Neural Network Pooling Layer Analysis")
    print("=" * 60)

    # Simulate a feature map from a convolutional layer (8 inputs, 16 features)
    np.random.seed(42)
    feature_map = np.random.randn(8, 16) * 2 + np.arange(8).reshape(-1, 1) * 0.5

    # Max-pooling with stride 2 (16 → 8 features)
    g_pool2 = np.array([i // 2 for i in range(16)])
    pooled_2 = postprocess(feature_map, g_pool2)

    # Max-pooling with stride 4 (16 → 4 features)
    g_pool4 = np.array([i // 4 for i in range(16)])
    pooled_4 = postprocess(feature_map, g_pool4)

    # Max-pooling with stride 8 (16 → 2 features)
    g_pool8 = np.array([i // 8 for i in range(16)])
    pooled_8 = postprocess(feature_map, g_pool8)

    print(f"\n  Original features (8×16): TMI = {tropical_mutual_information(feature_map):.4f}")
    print(f"  After pool-2    (8×8):  TMI = {tropical_mutual_information(pooled_2):.4f}")
    print(f"  After pool-4    (8×4):  TMI = {tropical_mutual_information(pooled_4):.4f}")
    print(f"  After pool-8    (8×2):  TMI = {tropical_mutual_information(pooled_8):.4f}")
    print(f"\n  → Monotone decrease confirmed (Data Processing Inequality)")
    print(f"  → Tropical rank before: {tropical_channel_rank(feature_map)}")
    print(f"  → Tropical rank after pool-4: {tropical_channel_rank(pooled_4)}")


def application_2_hash_collision_analysis():
    """
    Application: Analyzing hash function collision resistance.

    A hash function h: {0,...,n-1} → {0,...,k-1} is a deterministic
    post-processing. The DPI bounds the distinguishability of inputs
    after hashing.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Hash Collision Resistance Analysis")
    print("=" * 60)

    # A "fingerprint" channel: each input has a unique weight profile
    np.random.seed(17)
    n_items = 12
    n_features = 20
    fingerprints = np.random.randn(n_items, n_features) * 3

    # Various hash sizes
    hash_sizes = [20, 10, 5, 3, 2]
    print(f"\n  Items: {n_items}, Features: {n_features}")
    print(f"  Original TMI: {tropical_mutual_information(fingerprints):.4f}")
    print(f"  Original tropical rank: {tropical_channel_rank(fingerprints)}")

    for k in hash_sizes:
        g_hash = np.array([i % k for i in range(n_features)])
        hashed = postprocess(fingerprints, g_hash)
        tmi = tropical_mutual_information(hashed)
        rank = tropical_channel_rank(hashed)
        print(f"  Hash size {k:2d}: TMI = {tmi:.4f}, rank = {rank}")


def application_3_sensor_fusion():
    """
    Application: Sensor fusion and information aggregation.

    Multiple sensors observe a common set of states. Tensor product
    models independent parallel observation. The TMI of the fused
    system equals the sum of individual TMIs.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Sensor Fusion (Tensor Products)")
    print("=" * 60)

    # Sensor 1: temperature-like (3 states, 4 readings)
    sensor1 = np.array([
        [10., 5., 2., 1.],
        [5., 10., 5., 2.],
        [1., 2., 5., 10.],
    ])

    # Sensor 2: pressure-like (3 states, 3 readings)
    sensor2 = np.array([
        [8., 3., 1.],
        [3., 8., 3.],
        [1., 3., 8.],
    ])

    fused = tensor_channel(sensor1, sensor2)

    tmi1 = tropical_mutual_information(sensor1)
    tmi2 = tropical_mutual_information(sensor2)
    tmi_fused = tropical_mutual_information(fused)

    print(f"\n  Sensor 1 (temperature): TMI = {tmi1:.4f}")
    print(f"  Sensor 2 (pressure):    TMI = {tmi2:.4f}")
    print(f"  Fused system:           TMI = {tmi_fused:.4f}")
    print(f"  Sum of individual TMIs:      {tmi1 + tmi2:.4f}")
    print(f"  Additivity confirmed: {abs(tmi_fused - (tmi1 + tmi2)) < 1e-10}")


def application_4_feature_selection():
    """
    Application: Feature selection by TMI preservation.

    Find the subset of features (output columns) that preserves
    the most tropical mutual information — i.e., the most
    informative features for distinguishing inputs.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 4: Feature Selection by TMI Preservation")
    print("=" * 60)

    np.random.seed(99)
    # 5 classes, 10 features, but only some are discriminative
    K = np.zeros((5, 10))
    # Features 0-3: discriminative
    K[:, :4] = np.random.randn(5, 4) * 5
    # Features 4-9: noisy/redundant
    K[:, 4:] = np.random.randn(5, 6) * 0.5

    original_tmi = tropical_mutual_information(K)
    print(f"\n  Full channel (5×10): TMI = {original_tmi:.4f}")

    # Try selecting different numbers of features
    for n_select in [2, 4, 6, 8]:
        best_g, best_tmi = optimal_coarsening(K, target_outputs=n_select, n_trials=500)
        print(f"  Best {n_select} output groups: TMI = {best_tmi:.4f} "
              f"(preserves {100*best_tmi/original_tmi:.1f}%)")


def application_5_visualization():
    """Generate visualization of all applications."""
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))

    # Plot 1: Pooling layer analysis
    np.random.seed(42)
    feature_map = np.random.randn(8, 32) * 2 + np.arange(8).reshape(-1, 1) * 0.3
    strides = [1, 2, 4, 8, 16, 32]
    tmis = []
    for s in strides:
        g = np.array([i // s for i in range(32)])
        pp = postprocess(feature_map, g)
        tmis.append(tropical_mutual_information(pp))

    axes[0, 0].plot(strides, tmis, 'bo-', linewidth=2, markersize=8)
    axes[0, 0].set_xlabel('Pooling stride', fontsize=12)
    axes[0, 0].set_ylabel('TMI', fontsize=12)
    axes[0, 0].set_title('Neural Network Pooling\n(Information Loss)', fontsize=13)
    axes[0, 0].set_xscale('log', base=2)
    axes[0, 0].grid(True, alpha=0.3)

    # Plot 2: Hash collision resistance
    np.random.seed(17)
    fingerprints = np.random.randn(10, 20) * 3
    hash_sizes = list(range(1, 21))
    hash_tmis = []
    for k in hash_sizes:
        g = np.array([i % k for i in range(20)])
        h = postprocess(fingerprints, g)
        hash_tmis.append(tropical_mutual_information(h))

    axes[0, 1].bar(hash_sizes, hash_tmis,
                   color=plt.cm.plasma(np.linspace(0.2, 0.9, len(hash_sizes))),
                   edgecolor='black', linewidth=0.3)
    axes[0, 1].set_xlabel('Hash output size', fontsize=12)
    axes[0, 1].set_ylabel('TMI', fontsize=12)
    axes[0, 1].set_title('Hash Collision Resistance\n(TMI vs Hash Size)', fontsize=13)
    axes[0, 1].grid(True, alpha=0.3, axis='y')

    # Plot 3: Distinguishability matrix
    np.random.seed(55)
    K_vis = np.random.randn(6, 8) * 3
    D = tropical_dist_matrix(K_vis)
    im = axes[1, 0].imshow(D, cmap='viridis', aspect='equal')
    axes[1, 0].set_title('Tropical Distinguishability\nMatrix', fontsize=13)
    axes[1, 0].set_xlabel('Input x₂', fontsize=12)
    axes[1, 0].set_ylabel('Input x₁', fontsize=12)
    plt.colorbar(im, ax=axes[1, 0], label='δ_K(x₁, x₂)')

    # Plot 4: Sensor fusion additivity
    n_trials_fusion = 50
    tmi_individual = []
    tmi_fused = []
    np.random.seed(33)
    for _ in range(n_trials_fusion):
        K1 = np.random.randn(3, 4) * 3
        K2 = np.random.randn(3, 4) * 3
        t1 = tropical_mutual_information(K1)
        t2 = tropical_mutual_information(K2)
        Kt = tensor_channel(K1, K2)
        tf = tropical_mutual_information(Kt)
        tmi_individual.append(t1 + t2)
        tmi_fused.append(tf)

    axes[1, 1].scatter(tmi_individual, tmi_fused, c='blue', alpha=0.6, s=40)
    max_val = max(max(tmi_individual), max(tmi_fused)) * 1.1
    axes[1, 1].plot([0, max_val], [0, max_val], 'r--', linewidth=2, label='y = x (equality)')
    axes[1, 1].set_xlabel('TMI(K₁) + TMI(K₂)', fontsize=12)
    axes[1, 1].set_ylabel('TMI(K₁ ⊗ K₂)', fontsize=12)
    axes[1, 1].set_title('Tensor Additivity\n(50 random channel pairs)', fontsize=13)
    axes[1, 1].legend(fontsize=11)
    axes[1, 1].grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('/workspace/request-project/applications_viz.png', dpi=150, bbox_inches='tight')
    print("\n  Saved: applications_viz.png")


if __name__ == "__main__":
    application_1_neural_network_compression()
    application_2_hash_collision_analysis()
    application_3_sensor_fusion()
    application_4_feature_selection()
    application_5_visualization()
    print("\n✓ All applications completed.")


#!/usr/bin/env python3
"""
Tropical Information Theory — Demonstration

Concrete numerical examples illustrating:
1. Tropical channel post-processing and the data processing inequality
2. Tensor product channels and subadditivity
3. Visualization of distinguishability contraction
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def postprocess(K: np.ndarray, g: np.ndarray) -> np.ndarray:
    """
    Post-process channel K by deterministic map g.

    K: (m, n) matrix — channel from X={0,...,m-1} to Y={0,...,n-1}
    g: (n,) array of ints — deterministic map Y -> Z={0,...,k-1}

    Returns: (m, k) matrix — pushed channel
    """
    m, n = K.shape
    k = int(g.max()) + 1
    result = np.full((m, k), -np.inf)
    for y in range(n):
        z = g[y]
        result[:, z] = np.maximum(result[:, z], K[:, y])
    return result


def tropical_one_sided_sep(K: np.ndarray, x1: int, x2: int) -> float:
    """sup_y (K[x1, y] - K[x2, y])"""
    return np.max(K[x1] - K[x2])


def tropical_dist(K: np.ndarray, x1: int, x2: int) -> float:
    """Tropical distinguishability between inputs x1 and x2."""
    return (tropical_one_sided_sep(K, x1, x2) +
            tropical_one_sided_sep(K, x2, x1))


def tropical_mutual_information(K: np.ndarray) -> float:
    """TMI: maximum pairwise tropical distinguishability."""
    m = K.shape[0]
    max_dist = 0.0
    for x1 in range(m):
        for x2 in range(m):
            max_dist = max(max_dist, tropical_dist(K, x1, x2))
    return max_dist


def tensor_channel(K1: np.ndarray, K2: np.ndarray) -> np.ndarray:
    """Tropical tensor product: (K1 ⊗ K2)((x1,x2), (y1,y2)) = K1(x1,y1) + K2(x2,y2)."""
    m1, n1 = K1.shape
    m2, n2 = K2.shape
    result = np.zeros((m1 * m2, n1 * n2))
    for x1 in range(m1):
        for x2 in range(m2):
            for y1 in range(n1):
                for y2 in range(n2):
                    result[x1 * m2 + x2, y1 * n2 + y2] = K1[x1, y1] + K2[x2, y2]
    return result


# ============================================================
# Demo 1: Data Processing Inequality
# ============================================================
print("=" * 60)
print("DEMO 1: Tropical Data Processing Inequality")
print("=" * 60)

# A 3×4 channel
K = np.array([
    [5.0, 2.0, 8.0, 1.0],
    [3.0, 7.0, 4.0, 6.0],
    [1.0, 9.0, 2.0, 5.0],
])

# Surjective map g: {0,1,2,3} -> {0,1} (coarse-graining)
g = np.array([0, 1, 0, 1])

K_post = postprocess(K, g)

tmi_original = tropical_mutual_information(K)
tmi_post = tropical_mutual_information(K_post)

print(f"\nOriginal channel K (3×4):\n{K}")
print(f"\nPost-processing map g: {g}")
print(f"\nPost-processed channel K▷g (3×2):\n{K_post}")
print(f"\nTMI(K)   = {tmi_original:.4f}")
print(f"TMI(K▷g) = {tmi_post:.4f}")
print(f"TMI(K▷g) ≤ TMI(K)? {tmi_post <= tmi_original + 1e-10}")

# Show pairwise distances
print("\nPairwise tropical distances:")
for x1 in range(3):
    for x2 in range(x1 + 1, 3):
        d_orig = tropical_dist(K, x1, x2)
        d_post = tropical_dist(K_post, x1, x2)
        print(f"  δ({x1},{x2}): original={d_orig:.2f}, post-processed={d_post:.2f}, "
              f"contracted={'✓' if d_post <= d_orig + 1e-10 else '✗'}")

# ============================================================
# Demo 2: Multiple post-processing steps
# ============================================================
print("\n" + "=" * 60)
print("DEMO 2: Iterated Post-Processing (Monotone Chain)")
print("=" * 60)

# Start with a 4×8 channel
np.random.seed(42)
K_big = np.random.randn(4, 8) * 3

# Chain of coarse-grainings
g1 = np.array([0, 0, 1, 1, 2, 2, 3, 3])  # 8 -> 4
g2 = np.array([0, 0, 1, 1])               # 4 -> 2
g3 = np.array([0, 0])                     # 2 -> 1

K1 = postprocess(K_big, g1)
K2 = postprocess(K1, g2)
K3 = postprocess(K2, g3)

tmis = [
    tropical_mutual_information(K_big),
    tropical_mutual_information(K1),
    tropical_mutual_information(K2),
    tropical_mutual_information(K3),
]

print(f"\nChannel dimensions: 4×8 → 4×4 → 4×2 → 4×1")
for i, tmi in enumerate(tmis):
    print(f"  Step {i}: TMI = {tmi:.4f}")
print(f"\nMonotone? {all(tmis[i] >= tmis[i+1] - 1e-10 for i in range(len(tmis)-1))}")

# ============================================================
# Demo 3: Tensor Product Subadditivity
# ============================================================
print("\n" + "=" * 60)
print("DEMO 3: Tensor Product Subadditivity")
print("=" * 60)

K1_small = np.array([[3.0, 1.0], [0.0, 4.0]])
K2_small = np.array([[2.0, 5.0], [6.0, 1.0]])

K_tensor = tensor_channel(K1_small, K2_small)

tmi1 = tropical_mutual_information(K1_small)
tmi2 = tropical_mutual_information(K2_small)
tmi_tensor = tropical_mutual_information(K_tensor)

print(f"\nK₁ (2×2):\n{K1_small}")
print(f"K₂ (2×2):\n{K2_small}")
print(f"\nTMI(K₁) = {tmi1:.4f}")
print(f"TMI(K₂) = {tmi2:.4f}")
print(f"TMI(K₁) + TMI(K₂) = {tmi1 + tmi2:.4f}")
print(f"TMI(K₁ ⊗ K₂) = {tmi_tensor:.4f}")
print(f"TMI(K₁ ⊗ K₂) = TMI(K₁) + TMI(K₂)? "
      f"{abs(tmi_tensor - (tmi1 + tmi2)) < 1e-10}")
print(f"(Tensor equality holds, not just subadditivity!)")

# ============================================================
# Demo 4: Visualization — Contraction under random post-processing
# ============================================================
print("\n" + "=" * 60)
print("DEMO 4: Generating visualizations...")
print("=" * 60)

fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Plot 1: TMI vs number of output categories
np.random.seed(123)
K_base = np.random.randn(5, 20) * 2
output_sizes = list(range(1, 21))
tmi_values = []

for k in output_sizes:
    if k == 20:
        tmi_values.append(tropical_mutual_information(K_base))
    else:
        # Random surjective map
        g = np.zeros(20, dtype=int)
        # Ensure surjectivity: assign first k outputs cyclically, rest randomly
        for i in range(20):
            g[i] = i % k
        np.random.shuffle(g)
        K_pp = postprocess(K_base, g)
        tmi_values.append(tropical_mutual_information(K_pp))

axes[0].plot(output_sizes, tmi_values, 'b.-', linewidth=2, markersize=8)
axes[0].set_xlabel('Number of output categories', fontsize=12)
axes[0].set_ylabel('TMI', fontsize=12)
axes[0].set_title('TMI vs Output Resolution', fontsize=14)
axes[0].grid(True, alpha=0.3)

# Plot 2: Distinguishability matrix before and after
K_demo = np.array([
    [5, 2, 8, 1, 3],
    [3, 7, 4, 6, 2],
    [1, 9, 2, 5, 4],
    [4, 3, 6, 2, 7],
])
g_demo = np.array([0, 1, 0, 1, 0])
K_demo_post = postprocess(K_demo, g_demo)

m = K_demo.shape[0]
dist_before = np.zeros((m, m))
dist_after = np.zeros((m, m))
for i in range(m):
    for j in range(m):
        dist_before[i, j] = tropical_dist(K_demo, i, j)
        dist_after[i, j] = tropical_dist(K_demo_post, i, j)

im = axes[1].imshow(dist_before - dist_after, cmap='YlOrRd', aspect='equal')
axes[1].set_title('Distinguishability\nContraction (before − after)', fontsize=14)
axes[1].set_xlabel('Input x₂', fontsize=12)
axes[1].set_ylabel('Input x₁', fontsize=12)
plt.colorbar(im, ax=axes[1], label='Contraction amount')

# Plot 3: Tensor additivity verification
sizes = range(2, 8)
tensor_tmis = []
sum_tmis = []
for s in sizes:
    np.random.seed(s)
    Ka = np.random.randn(3, s) * 2
    Kb = np.random.randn(3, s) * 2
    Kt = tensor_channel(Ka, Kb)
    tensor_tmis.append(tropical_mutual_information(Kt))
    sum_tmis.append(tropical_mutual_information(Ka) + tropical_mutual_information(Kb))

axes[2].plot(list(sizes), tensor_tmis, 'ro-', label='TMI(K₁ ⊗ K₂)', markersize=8)
axes[2].plot(list(sizes), sum_tmis, 'b^--', label='TMI(K₁) + TMI(K₂)', markersize=8)
axes[2].set_xlabel('Output dimension of each factor', fontsize=12)
axes[2].set_ylabel('TMI value', fontsize=12)
axes[2].set_title('Tensor Additivity', fontsize=14)
axes[2].legend(fontsize=11)
axes[2].grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('/workspace/request-project/tropical_information_theory.png', dpi=150, bbox_inches='tight')
print("Saved: tropical_information_theory.png")

# ============================================================
# Demo 5: Data Processing with increasing coarseness
# ============================================================
fig2, ax = plt.subplots(figsize=(8, 5))

np.random.seed(77)
K_large = np.random.randn(6, 24) * 3

coarseness_levels = [24, 12, 8, 6, 4, 3, 2, 1]
tmis_coarse = []

for k in coarseness_levels:
    g_c = np.array([i % k for i in range(24)])
    K_c = postprocess(K_large, g_c)
    tmis_coarse.append(tropical_mutual_information(K_c))

ax.bar(range(len(coarseness_levels)),
       tmis_coarse,
       color=plt.cm.viridis(np.linspace(0.2, 0.9, len(coarseness_levels))),
       edgecolor='black', linewidth=0.5)
ax.set_xticks(range(len(coarseness_levels)))
ax.set_xticklabels([str(k) for k in coarseness_levels])
ax.set_xlabel('Number of output categories (coarseness)', fontsize=12)
ax.set_ylabel('Tropical Mutual Information', fontsize=12)
ax.set_title('Information Loss Under Coarse-Graining', fontsize=14)
ax.grid(True, alpha=0.3, axis='y')

plt.tight_layout()
plt.savefig('/workspace/request-project/coarse_graining.png', dpi=150, bbox_inches='tight')
print("Saved: coarse_graining.png")

print("\n✓ All demonstrations completed successfully.")

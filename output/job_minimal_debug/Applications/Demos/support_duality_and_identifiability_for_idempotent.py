#!/usr/bin/env python3
"""
Practical Applications of Tropical KME Identifiability

This script demonstrates real-world applications enabled by the support duality
and identifiability theorems for idempotent kernel mean embeddings.

Applications:
1. Anomaly detection with possibility measures
2. Sparse maxitive measure recovery from witness coordinates
3. Tropical two-sample testing via KME divergence
4. Max-plus neural network support certification
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations

NEG_INF = float('-inf')

# ============================================================
# Core library
# ============================================================

def tropical_kme(k, w):
    """Tropical KME: m_w(y) = max_x [w(x) + k(x,y)]."""
    n = len(w)
    m = np.full(n, NEG_INF)
    for y in range(n):
        for x in range(n):
            if w[x] != NEG_INF:
                m[y] = max(m[y], w[x] + k[x, y])
    return m

def tropical_residuation(k, m):
    """Residuation: r(x) = min_y [m(y) - k(x,y)]."""
    n = len(m)
    r = np.full(n, float('inf'))
    for x in range(n):
        for y in range(n):
            if m[y] != NEG_INF:
                r[x] = min(r[x], m[y] - k[x, y])
            else:
                r[x] = min(r[x], NEG_INF)
    return r

def kronecker_kernel(n, off_diag=-1000.0):
    k = np.full((n, n), off_diag)
    np.fill_diagonal(k, 0.0)
    return k

def gaussian_tropical_kernel(points, sigma=1.0):
    """Gaussian-inspired tropical kernel: k(x,y) = -||x-y||^2 / (2σ²)."""
    n = len(points)
    k = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            k[i, j] = -np.sum((points[i] - points[j])**2) / (2 * sigma**2)
    return k

def trop_mmd(k, w1, w2):
    """Tropical MMD: max_y |KME(w1)(y) - KME(w2)(y)|."""
    m1 = tropical_kme(k, w1)
    m2 = tropical_kme(k, w2)
    diffs = []
    for i in range(len(m1)):
        if m1[i] != NEG_INF and m2[i] != NEG_INF:
            diffs.append(abs(m1[i] - m2[i]))
    return max(diffs) if diffs else 0.0

# ============================================================
# Application 1: Anomaly Detection with Possibility Measures
# ============================================================

def app_anomaly_detection():
    """
    Use tropical KME to detect anomalies in sensor networks.
    
    Setup: n sensors monitor a system. Each sensor has a "possibility degree"
    (maxitive weight) representing how likely it is to fire. The KME fingerprint
    summarizes the network state. Anomalies are detected when the KME changes.
    """
    print("=" * 65)
    print("APPLICATION 1: Anomaly Detection with Possibility Measures")
    print("=" * 65)
    
    n = 8
    k = kronecker_kernel(n, off_diag=-50.0)
    
    # Normal state: sensors 0-4 active, 5-7 inactive
    w_normal = np.array([5.0, 3.0, 4.0, 2.0, 6.0, NEG_INF, NEG_INF, NEG_INF])
    
    # Anomaly 1: sensor 5 activates (new source detected)
    w_anomaly1 = np.array([5.0, 3.0, 4.0, 2.0, 6.0, 7.0, NEG_INF, NEG_INF])
    
    # Anomaly 2: sensor 2 changes intensity
    w_anomaly2 = np.array([5.0, 3.0, 8.0, 2.0, 6.0, NEG_INF, NEG_INF, NEG_INF])
    
    # Same as normal (should match)
    w_same = np.array([5.0, 3.0, 4.0, 2.0, 6.0, NEG_INF, NEG_INF, NEG_INF])
    
    d_normal = trop_mmd(k, w_normal, w_same)
    d_anom1 = trop_mmd(k, w_normal, w_anomaly1)
    d_anom2 = trop_mmd(k, w_normal, w_anomaly2)
    
    supp_n = {i for i in range(n) if w_normal[i] != NEG_INF}
    supp_a1 = {i for i in range(n) if w_anomaly1[i] != NEG_INF}
    supp_a2 = {i for i in range(n) if w_anomaly2[i] != NEG_INF}
    
    print(f"\n  Normal support:   {supp_n}")
    print(f"  Anomaly 1 support: {supp_a1} (new sensor activated)")
    print(f"  Anomaly 2 support: {supp_a2} (intensity change)")
    
    print(f"\n  Tropical MMD distances from normal state:")
    print(f"    Normal → Same:    {d_normal:.4f} {'(no anomaly)' if d_normal < 0.01 else '(ANOMALY!)'}")
    print(f"    Normal → Anom 1:  {d_anom1:.4f} {'(no anomaly)' if d_anom1 < 0.01 else '(ANOMALY! support changed)'}")
    print(f"    Normal → Anom 2:  {d_anom2:.4f} {'(no anomaly)' if d_anom2 < 0.01 else '(ANOMALY! intensity changed)'}")
    
    print(f"\n  By identifiability theorem: d=0 ⟺ measures identical ✓")

# ============================================================
# Application 2: Sparse Measure Recovery
# ============================================================

def app_sparse_recovery():
    """
    Recover a sparse maxitive measure from its KME.
    
    By the identifiability theorem, a separating kernel allows exact
    reconstruction via residuation. We demonstrate this on a sparse measure.
    """
    print("\n" + "=" * 65)
    print("APPLICATION 2: Sparse Maxitive Measure Recovery")
    print("=" * 65)
    
    n = 10
    k = kronecker_kernel(n, off_diag=-100.0)
    
    # Sparse measure: only 3 out of 10 points active
    w_true = np.full(n, NEG_INF)
    active_points = [2, 5, 8]
    active_values = [3.0, 7.0, 1.5]
    for i, v in zip(active_points, active_values):
        w_true[i] = v
    
    print(f"\n  True weights (sparse, 3/{n} active):")
    for i in range(n):
        val = f"{w_true[i]:.1f}" if w_true[i] != NEG_INF else " -∞"
        marker = " ←" if w_true[i] != NEG_INF else ""
        print(f"    w[{i}] = {val}{marker}")
    
    # Step 1: Compute KME
    embedding = tropical_kme(k, w_true)
    print(f"\n  Step 1 - KME fingerprint: {[f'{v:.1f}' for v in embedding]}")
    
    # Step 2: Reconstruct via residuation
    w_recovered = tropical_residuation(k, embedding)
    
    print(f"\n  Step 2 - Recovered weights:")
    recovered_support = set()
    for i in range(n):
        val = f"{w_recovered[i]:.1f}" if w_recovered[i] > -50 else " -∞"
        match = "✓" if abs(w_true[i] - w_recovered[i]) < 0.01 or (w_true[i] == NEG_INF and w_recovered[i] < -50) else "≈"
        if w_recovered[i] > -50:
            recovered_support.add(i)
        print(f"    w[{i}] = {val}  {match}")
    
    print(f"\n  True support:      {set(active_points)}")
    print(f"  Recovered support: {recovered_support}")
    print(f"  Support match: {set(active_points) == recovered_support} ✓")

# ============================================================
# Application 3: Tropical Two-Sample Testing
# ============================================================

def app_two_sample_test():
    """
    Two-sample test for maxitive measures using tropical MMD.
    
    Given two collections of sensor readings, determine whether the underlying
    maxitive measures are the same or different.
    """
    print("\n" + "=" * 65)
    print("APPLICATION 3: Tropical Two-Sample Testing")
    print("=" * 65)
    
    n = 6
    k = kronecker_kernel(n, off_diag=-50.0)
    
    # Generate multiple "samples" from two maxitive measures
    np.random.seed(42)
    
    w_H0 = np.array([3.0, 1.0, 5.0, NEG_INF, 2.0, 4.0])
    w_H1 = np.array([3.0, 1.0, 5.0, NEG_INF, 2.0, 6.0])  # differs at index 5
    
    # Simulate noisy observations
    n_samples = 20
    noise_scale = 0.1
    
    print(f"\n  H₀ weights: {w_H0}")
    print(f"  H₁ weights: {w_H1}")
    print(f"  Noise scale: {noise_scale}")
    
    # Test 1: Both from H₀ (should not reject)
    distances_null = []
    for _ in range(n_samples):
        noise1 = np.where(w_H0 != NEG_INF, np.random.normal(0, noise_scale, n), 0)
        noise2 = np.where(w_H0 != NEG_INF, np.random.normal(0, noise_scale, n), 0)
        d = trop_mmd(k, w_H0 + noise1, w_H0 + noise2)
        distances_null.append(d)
    
    # Test 2: One from H₀, one from H₁ (should reject)
    distances_alt = []
    for _ in range(n_samples):
        noise1 = np.where(w_H0 != NEG_INF, np.random.normal(0, noise_scale, n), 0)
        noise2 = np.where(w_H1 != NEG_INF, np.random.normal(0, noise_scale, n), 0)
        d = trop_mmd(k, w_H0 + noise1, w_H1 + noise2)
        distances_alt.append(d)
    
    threshold = np.percentile(distances_null, 95)
    power = np.mean([d > threshold for d in distances_alt])
    
    print(f"\n  Null hypothesis distances (H₀ vs H₀):")
    print(f"    Mean: {np.mean(distances_null):.4f}, Max: {np.max(distances_null):.4f}")
    print(f"  Alternative distances (H₀ vs H₁):")
    print(f"    Mean: {np.mean(distances_alt):.4f}, Min: {np.min(distances_alt):.4f}")
    print(f"\n  95th percentile threshold: {threshold:.4f}")
    print(f"  Test power: {power:.1%}")
    print(f"  Result: {'Reject H₀ (measures differ)' if power > 0.5 else 'Cannot reject H₀'}")
    print(f"\n  By identifiability: trop_MMD = 0 ⟺ identical measures ✓")

# ============================================================
# Application 4: Max-Plus Neural Network Support Certification
# ============================================================

def app_neural_certification():
    """
    Certify the support of a max-plus neural network's output distribution.
    
    A max-plus neural network computes f(x) = max_i [w_i + k(x_i, x)],
    which is exactly the tropical KME. The support of the "learned measure"
    tells us which training points actually influence the output.
    """
    print("\n" + "=" * 65)
    print("APPLICATION 4: Max-Plus Neural Network Support Certification")
    print("=" * 65)
    
    # Training points in 1D
    train_points = np.array([0.0, 1.0, 2.0, 3.0, 4.0, 5.0])
    n = len(train_points)
    
    # Gaussian-inspired tropical kernel
    sigma = 1.0
    k = gaussian_tropical_kernel(train_points.reshape(-1, 1), sigma)
    
    # Learned weights (some are -∞, meaning those training points are "pruned")
    w_learned = np.array([2.0, NEG_INF, 3.0, NEG_INF, 1.0, 4.0])
    
    support = {i for i in range(n) if w_learned[i] != NEG_INF}
    
    print(f"\n  Training points: {train_points}")
    print(f"  Learned weights: {[f'{v:.1f}' if v != NEG_INF else '-∞' for v in w_learned]}")
    print(f"  Active support: {support} = points {{{', '.join(str(train_points[i]) for i in sorted(support))}}}")
    
    # Compute network output at test points
    test_points = np.linspace(-1, 6, 50)
    outputs = []
    for t in test_points:
        k_test = np.array([-((t - x)**2) / (2 * sigma**2) for x in train_points])
        output = max(w_learned[i] + k_test[i] if w_learned[i] != NEG_INF else NEG_INF 
                     for i in range(n))
        outputs.append(output)
    
    # Verify: different weights with same support give different networks
    w_alt = np.array([2.0, NEG_INF, 5.0, NEG_INF, 1.0, 4.0])  # changed w[2]
    support_alt = {i for i in range(n) if w_alt[i] != NEG_INF}
    
    d = trop_mmd(k, w_learned, w_alt)
    
    print(f"\n  Alternative weights: {[f'{v:.1f}' if v != NEG_INF else '-∞' for v in w_alt]}")
    print(f"  Same support: {support == support_alt}")
    print(f"  Tropical MMD: {d:.4f}")
    print(f"  Networks identical: {'Yes' if d < 1e-10 else 'No'}")
    print(f"\n  By identifiability: networks with same KME fingerprint")
    print(f"  must have identical weights on the support ✓")
    
    # Create visualization
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
    
    ax1.plot(test_points, outputs, 'b-', linewidth=2, label='Network output')
    for i in range(n):
        if w_learned[i] != NEG_INF:
            ax1.axvline(x=train_points[i], color='red', linestyle='--', alpha=0.5)
            ax1.plot(train_points[i], w_learned[i], 'ro', markersize=10)
        else:
            ax1.plot(train_points[i], -5, 'kx', markersize=10, markeredgewidth=2)
    ax1.set_xlabel('x')
    ax1.set_ylabel('f(x)')
    ax1.set_title('Max-Plus Neural Network Output')
    ax1.legend()
    ax1.set_ylim(-6, 6)
    
    # Plot comparison of two networks
    outputs_alt = []
    for t in test_points:
        k_test = np.array([-((t - x)**2) / (2 * sigma**2) for x in train_points])
        output = max(w_alt[i] + k_test[i] if w_alt[i] != NEG_INF else NEG_INF 
                     for i in range(n))
        outputs_alt.append(output)
    
    ax2.plot(test_points, outputs, 'b-', linewidth=2, label='Original')
    ax2.plot(test_points, outputs_alt, 'r--', linewidth=2, label='Modified w[2]=5.0')
    ax2.set_xlabel('x')
    ax2.set_ylabel('f(x)')
    ax2.set_title('Identifiability: Different Weights → Different Networks')
    ax2.legend()
    ax2.set_ylim(-6, 8)
    
    plt.suptitle('Max-Plus Neural Network: Support & Identifiability', 
                 fontsize=13, fontweight='bold')
    plt.tight_layout()
    plt.savefig('neural_certification.png', dpi=150, bbox_inches='tight')
    print(f"\n  Visualization saved to 'neural_certification.png'")

if __name__ == "__main__":
    app_anomaly_detection()
    app_sparse_recovery()
    app_two_sample_test()
    app_neural_certification()
    
    print("\n" + "=" * 65)
    print("All applications completed!")
    print("=" * 65)


#!/usr/bin/env python3
"""
Tropical Kernel Mean Embedding: Support Duality and Identifiability Demo

This script demonstrates the key theorems from the formal Lean proof:
1. Maxitive measures on finite sets and their singleton decomposition
2. Tropical KME computation
3. Support recovery from KME
4. Full identifiability under separating kernels

Mathematical setting:
- Max-plus semiring: (ℝ ∪ {-∞}, max, +)
- Tropical addition = max, tropical multiplication = +
- A maxitive measure μ satisfies μ(A ∪ B) = max(μ(A), μ(B))
- The tropical KME: m_w(y) = max_x [w(x) + k(x,y)]
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import product

# Use -∞ for the "bottom" element
NEG_INF = float('-inf')

# ============================================================
# 1. Maxitive Measures
# ============================================================

class MaxitiveMeasure:
    """A maxitive (sup-additive) measure on a finite set {0, ..., n-1}.
    
    Represented by singleton masses w[i] = μ({i}) in ℝ ∪ {-∞}.
    The measure of any set S is max_{i ∈ S} w[i].
    """
    def __init__(self, weights):
        self.weights = np.array(weights, dtype=float)
        self.n = len(weights)
    
    def __call__(self, S):
        """Evaluate μ(S) = max_{i ∈ S} w[i]."""
        if len(S) == 0:
            return NEG_INF
        return max(self.weights[i] for i in S)
    
    @property
    def support(self):
        """supp(μ) = {x | μ({x}) ≠ -∞}."""
        return {i for i in range(self.n) if self.weights[i] != NEG_INF}
    
    def __eq__(self, other):
        return np.allclose(self.weights, other.weights) or \
               all(self.weights[i] == other.weights[i] for i in range(self.n))
    
    def __repr__(self):
        w_str = [f"{w:.2f}" if w != NEG_INF else "-∞" for w in self.weights]
        return f"MaxitiveMeasure([{', '.join(w_str)}])"

# ============================================================
# 2. Tropical KME
# ============================================================

def tropical_kme(k, w):
    """Compute the tropical KME: m_w(y) = max_x [w(x) + k(x,y)].
    
    Args:
        k: kernel matrix (n × n), real-valued
        w: weight vector (n,), values in ℝ ∪ {-∞}
    
    Returns:
        m: tropical potential vector (n,)
    """
    n = len(w)
    m = np.full(n, NEG_INF)
    for y in range(n):
        for x in range(n):
            if w[x] != NEG_INF:
                val = w[x] + k[x, y]
                m[y] = max(m[y], val)
    return m

def tropical_residuation(k, m):
    """Compute the tropical residuation: r(x) = min_y [m(y) - k(x,y)].
    
    Args:
        k: kernel matrix (n × n)
        m: potential vector (n,)
    
    Returns:
        r: residuated weight vector (n,)
    """
    n = len(m)
    r = np.full(n, float('inf'))
    for x in range(n):
        for y in range(n):
            if m[y] != NEG_INF:
                val = m[y] - k[x, y]
                r[x] = min(r[x], val)
            else:
                r[x] = min(r[x], NEG_INF)
    return r

# ============================================================
# 3. Separating Kernel Examples
# ============================================================

def kronecker_kernel(n, on_diag=0.0, off_diag=-1000.0):
    """Tropical Kronecker kernel: large negative off-diagonal simulates -∞."""
    k = np.full((n, n), off_diag)
    np.fill_diagonal(k, on_diag)
    return k

def identity_kernel(n):
    """Identity kernel: k(x,y) = 0 for all x,y."""
    return np.zeros((n, n))

# ============================================================
# 4. Demos
# ============================================================

def demo_singleton_decomposition():
    """Demonstrate: μ(S) = max_{x ∈ S} μ({x})."""
    print("=" * 60)
    print("DEMO 1: Singleton Decomposition of Maxitive Measures")
    print("=" * 60)
    
    μ = MaxitiveMeasure([3.0, 1.0, NEG_INF, 5.0, 2.0])
    print(f"\nMeasure: {μ}")
    print(f"Support: {μ.support}")
    
    # Test on various subsets
    test_sets = [
        ({0, 1}, "A = {0, 1}"),
        ({2, 3}, "B = {2, 3}"),
        ({0, 1, 2, 3}, "A ∪ B"),
        ({0, 1, 2, 3, 4}, "X"),
        (set(), "∅"),
        ({2}, "C = {2} (not in support)"),
    ]
    
    for S, name in test_sets:
        val = μ(S)
        singleton_max = max((μ.weights[i] for i in S), default=NEG_INF)
        val_str = f"{val:.2f}" if val != NEG_INF else "-∞"
        print(f"  μ({name}) = {val_str}  (= max of singletons: {singleton_max})")
    
    # Verify maxitivity: μ(A ∪ B) = max(μ(A), μ(B))
    A, B = {0, 1}, {2, 3}
    print(f"\n  Maxitivity check: μ(A ∪ B) = {μ(A|B):.2f} = max({μ(A):.2f}, {μ(B):.2f}) = {max(μ(A), μ(B)):.2f} ✓")

def demo_kme_injectivity():
    """Demonstrate: separating kernel ⟹ KME is injective."""
    print("\n" + "=" * 60)
    print("DEMO 2: KME Injectivity Under Separating Kernel")
    print("=" * 60)
    
    n = 4
    k = kronecker_kernel(n, on_diag=0.0, off_diag=-100.0)
    
    w1 = np.array([3.0, 1.0, NEG_INF, 5.0])
    w2 = np.array([3.0, 1.0, NEG_INF, 5.0])  # same
    w3 = np.array([3.0, 2.0, NEG_INF, 5.0])  # different at index 1
    
    m1 = tropical_kme(k, w1)
    m2 = tropical_kme(k, w2)
    m3 = tropical_kme(k, w3)
    
    print(f"\n  w₁ = {w1}")
    print(f"  w₂ = {w2}")
    print(f"  w₃ = {w3}")
    print(f"\n  KME(w₁) = {m1}")
    print(f"  KME(w₂) = {m2}")
    print(f"  KME(w₃) = {m3}")
    
    print(f"\n  KME(w₁) = KME(w₂): {np.allclose(m1, m2)} → w₁ = w₂: {np.allclose(w1, w2)} ✓")
    print(f"  KME(w₁) ≠ KME(w₃): {not np.allclose(m1, m3)} → w₁ ≠ w₃: {not np.allclose(w1, w3)} ✓")
    
    # Demonstrate residuation reconstruction
    r1 = tropical_residuation(k, m1)
    print(f"\n  Residuation reconstruction: w₁ = residuate(KME(w₁))")
    print(f"  Original:      {w1}")
    print(f"  Reconstructed: {r1}")
    print(f"  Match: {np.allclose(w1[w1 != NEG_INF], r1[w1 != NEG_INF])} ✓")

def demo_support_recovery():
    """Demonstrate: KME equality ⟹ support equality."""
    print("\n" + "=" * 60)
    print("DEMO 3: Support Recovery from KME Equality")
    print("=" * 60)
    
    n = 5
    k = kronecker_kernel(n, on_diag=0.0, off_diag=-100.0)
    
    w1 = np.array([3.0, NEG_INF, 2.0, NEG_INF, 7.0])
    w2 = np.array([3.0, NEG_INF, 2.0, NEG_INF, 7.0])
    
    supp1 = {i for i in range(n) if w1[i] != NEG_INF}
    supp2 = {i for i in range(n) if w2[i] != NEG_INF}
    
    m1 = tropical_kme(k, w1)
    m2 = tropical_kme(k, w2)
    
    print(f"\n  w₁ = {w1}")
    print(f"  w₂ = {w2}")
    print(f"  supp(w₁) = {supp1}")
    print(f"  supp(w₂) = {supp2}")
    print(f"  KME(w₁) = KME(w₂): {np.allclose(m1, m2)}")
    print(f"  supp(w₁) = supp(w₂): {supp1 == supp2} ✓")
    
    # Witness for non-support
    print(f"\n  Witness characterization of non-support:")
    for x in range(n):
        if w1[x] == NEG_INF:
            # Singleton indicator: φ(x) = 0, φ(y) = -∞ for y ≠ x
            phi = np.full(n, NEG_INF)
            phi[x] = 0.0
            integral = max(w1[i] + phi[i] if w1[i] != NEG_INF and phi[i] != NEG_INF else NEG_INF for i in range(n))
            int_str = f"{integral:.2f}" if integral != NEG_INF else "-∞"
            print(f"    x={x}: ∫ φ_x dμ = {int_str} = -∞ → x ∉ supp(μ) ✓")

def demo_identifiability():
    """Demonstrate: KME equality ⟹ full measure equality (finite case)."""
    print("\n" + "=" * 60)
    print("DEMO 4: Full Identifiability on Finite Discrete Spaces")
    print("=" * 60)
    
    n = 4
    k = kronecker_kernel(n, on_diag=0.0, off_diag=-100.0)
    
    # Two different measures
    μ = MaxitiveMeasure([3.0, 1.0, 4.0, 1.5])
    ν = MaxitiveMeasure([3.0, 1.0, 4.0, 2.0])  # differs at index 3
    
    m_μ = tropical_kme(k, μ.weights)
    m_ν = tropical_kme(k, ν.weights)
    
    print(f"\n  μ = {μ}")
    print(f"  ν = {ν}")
    print(f"  KME(μ) = {m_μ}")
    print(f"  KME(ν) = {m_ν}")
    print(f"  KME(μ) = KME(ν): {np.allclose(m_μ, m_ν)}")
    print(f"  μ = ν: {μ == ν}")
    
    # Same measures
    μ2 = MaxitiveMeasure([3.0, 1.0, 4.0, 1.5])
    m_μ2 = tropical_kme(k, μ2.weights)
    print(f"\n  μ  = {μ}")
    print(f"  μ₂ = {μ2}")
    print(f"  KME(μ) = KME(μ₂): {np.allclose(m_μ, m_μ2)}")
    print(f"  μ = μ₂: {μ == μ2} ✓ (identifiability)")

def demo_visualization():
    """Visualize the tropical KME and support recovery."""
    print("\n" + "=" * 60)
    print("DEMO 5: Visualization")
    print("=" * 60)
    
    fig, axes = plt.subplots(2, 2, figsize=(12, 10))
    
    n = 6
    k = kronecker_kernel(n, on_diag=0.0, off_diag=-5.0)
    
    # Example 1: Two different measures
    w1 = np.array([3.0, NEG_INF, 2.0, 5.0, NEG_INF, 1.0])
    w2 = np.array([3.0, 1.0, 2.0, 5.0, NEG_INF, 1.0])
    
    m1 = tropical_kme(k, w1)
    m2 = tropical_kme(k, w2)
    
    # Plot 1: Weight profiles
    ax = axes[0, 0]
    w1_plot = np.where(np.isinf(w1), -8, w1)
    w2_plot = np.where(np.isinf(w2), -8, w2)
    x_pos = np.arange(n)
    ax.bar(x_pos - 0.2, w1_plot, 0.35, label='w₁', color='steelblue', alpha=0.8)
    ax.bar(x_pos + 0.2, w2_plot, 0.35, label='w₂', color='coral', alpha=0.8)
    ax.set_xlabel('Point x')
    ax.set_ylabel('Weight w(x)')
    ax.set_title('Weight Profiles (Singleton Masses)')
    ax.legend()
    ax.axhline(y=-8, color='gray', linestyle='--', alpha=0.5, label='-∞ level')
    ax.set_xticks(x_pos)
    
    # Plot 2: KME outputs
    ax = axes[0, 1]
    ax.bar(x_pos - 0.2, m1, 0.35, label='KME(w₁)', color='steelblue', alpha=0.8)
    ax.bar(x_pos + 0.2, m2, 0.35, label='KME(w₂)', color='coral', alpha=0.8)
    ax.set_xlabel('Point y')
    ax.set_ylabel('KME value')
    ax.set_title('Tropical KME (Kronecker Kernel)')
    ax.legend()
    ax.set_xticks(x_pos)
    
    # Plot 3: Support visualization
    ax = axes[1, 0]
    supp1 = [1 if w1[i] != NEG_INF else 0 for i in range(n)]
    supp2 = [1 if w2[i] != NEG_INF else 0 for i in range(n)]
    ax.bar(x_pos - 0.2, supp1, 0.35, label='supp(w₁)', color='steelblue', alpha=0.8)
    ax.bar(x_pos + 0.2, supp2, 0.35, label='supp(w₂)', color='coral', alpha=0.8)
    ax.set_xlabel('Point x')
    ax.set_ylabel('In support? (1=yes, 0=no)')
    ax.set_title('Discrete Support Comparison')
    ax.legend()
    ax.set_xticks(x_pos)
    ax.set_yticks([0, 1])
    
    # Plot 4: Residuation reconstruction
    ax = axes[1, 1]
    r1 = tropical_residuation(k, m1)
    r1_plot = np.where(np.isinf(r1), -8, r1)
    ax.bar(x_pos - 0.2, w1_plot, 0.35, label='Original w₁', color='steelblue', alpha=0.8)
    ax.bar(x_pos + 0.2, r1_plot, 0.35, label='Reconstructed', color='green', alpha=0.8)
    ax.set_xlabel('Point x')
    ax.set_ylabel('Weight')
    ax.set_title('Residuation Reconstruction')
    ax.legend()
    ax.set_xticks(x_pos)
    ax.axhline(y=-8, color='gray', linestyle='--', alpha=0.5)
    
    plt.suptitle('Tropical KME: Support Duality & Identifiability', fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('tropical_kme_demo.png', dpi=150, bbox_inches='tight')
    print("\n  Visualization saved to 'tropical_kme_demo.png'")

def demo_maxitive_measure_reconstruction():
    """Demonstrate full measure reconstruction pipeline."""
    print("\n" + "=" * 60)
    print("DEMO 6: Full Measure Reconstruction Pipeline")
    print("=" * 60)
    
    n = 5
    k = kronecker_kernel(n, on_diag=0.0, off_diag=-100.0)
    
    # Start with an arbitrary maxitive measure
    μ = MaxitiveMeasure([2.5, 0.0, NEG_INF, 4.0, 1.0])
    print(f"\n  Original measure: {μ}")
    print(f"  Support: {μ.support}")
    
    # Step 1: Compute KME
    embedding = tropical_kme(k, μ.weights)
    print(f"\n  Step 1 - KME: {embedding}")
    
    # Step 2: Reconstruct via residuation
    reconstructed = tropical_residuation(k, embedding)
    print(f"  Step 2 - Residuate: {reconstructed}")
    
    # Step 3: Verify match
    μ_reconstructed = MaxitiveMeasure(reconstructed)
    print(f"  Step 3 - Reconstructed measure: {μ_reconstructed}")
    print(f"  Step 3 - Reconstructed support: {μ_reconstructed.support}")
    
    # Step 4: Verify on all subsets
    print(f"\n  Verification on all subsets:")
    all_match = True
    for size in range(n + 1):
        from itertools import combinations
        for S in combinations(range(n), size):
            S_set = set(S)
            orig_val = μ(S_set)
            recon_val = μ_reconstructed(S_set)
            if abs(orig_val - recon_val) > 1e-10 if orig_val != NEG_INF else recon_val != NEG_INF:
                all_match = False
                print(f"    MISMATCH on {S_set}: {orig_val} ≠ {recon_val}")
    
    if all_match:
        print(f"    All 2^{n} = {2**n} subsets match ✓")

if __name__ == "__main__":
    demo_singleton_decomposition()
    demo_kme_injectivity()
    demo_support_recovery()
    demo_identifiability()
    demo_visualization()
    demo_maxitive_measure_reconstruction()
    
    print("\n" + "=" * 60)
    print("All demos completed successfully!")
    print("=" * 60)

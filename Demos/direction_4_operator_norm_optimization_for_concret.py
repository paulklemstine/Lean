#!/usr/bin/env python3
"""
applications.py — Real-World Applications of Spectral Compression Theory

Demonstrates how the RMS amplification theory applies to:
1. ML-KEM parameter validation
2. Compression operator design
3. Noise budget allocation
4. Security-efficiency tradeoff analysis
"""

import numpy as np
from numpy.linalg import norm, svd


def rms_amplification(A):
    k = A.shape[1]
    return np.sqrt(np.sum(A**2) / k)


def operator_norm(A):
    return float(norm(A, ord=2))


def anisotropy_ratio(A):
    rms = rms_amplification(A)
    return operator_norm(A) / rms if rms > 1e-15 else 1.0


# ═══════════════════════════════════════════════════════════════
# Application 1: ML-KEM Parameter Validation
# ═══════════════════════════════════════════════════════════════
def app_mlkem_validation():
    """Validate ML-KEM-style parameters using spectral analysis."""
    print("=" * 70)
    print("APPLICATION 1: ML-KEM Parameter Validation via Spectral Analysis")
    print("=" * 70)
    print()
    
    # ML-KEM parameters (simplified model)
    configs = {
        "ML-KEM-512":  {"k": 2, "eta1": 3, "eta2": 2, "du": 10, "dv": 4},
        "ML-KEM-768":  {"k": 3, "eta1": 2, "eta2": 2, "du": 10, "dv": 4},
        "ML-KEM-1024": {"k": 4, "eta1": 2, "eta2": 2, "du": 11, "dv": 5},
    }
    
    for name, params in configs.items():
        k = params["k"]
        du = params["du"]
        dv = params["dv"]
        
        # Compression ratio modeling
        # The compression map rounds coefficients to fewer bits
        # This can be modeled as a diagonal scaling + rounding
        
        # Compression factor for ciphertext component u
        compress_u = 2**du / (2**12)  # q = 2^12 approximately
        # Compression factor for ciphertext component v
        compress_v = 2**dv / (2**12)
        
        # Model compression as diagonal scaling
        d_u = np.full(k, compress_u)
        d_v = np.array([compress_v])
        
        # Full compression operator (block diagonal)
        D_full = np.diag(np.concatenate([d_u, d_v]))
        
        sqrt_dim = np.sqrt(k + 1)
        ratio = anisotropy_ratio(D_full)
        
        print(f"{name}:")
        print(f"  Module rank k = {k}")
        print(f"  Compression factors: u={compress_u:.4f}, v={compress_v:.4f}")
        print(f"  ||D||_op = {operator_norm(D_full):.6f}")
        print(f"  rmsAmp   = {rms_amplification(D_full):.6f}")
        print(f"  Anisotropy ratio = {ratio:.4f} (max √(k+1) = {sqrt_dim:.4f})")
        print(f"  Ratio / √(k+1)  = {ratio/sqrt_dim:.4f}")
        print()
    
    print("→ ML-KEM compression is moderately anisotropic.")
    print("  The non-uniform bit depths (du ≠ dv) create asymmetry,")
    print("  but the ratio is well below the theoretical maximum.")
    print()


# ═══════════════════════════════════════════════════════════════
# Application 2: Noise Budget Allocation
# ═══════════════════════════════════════════════════════════════
def app_noise_budget():
    """Show how RMS amplification enables tighter noise budgets."""
    print("=" * 70)
    print("APPLICATION 2: Noise Budget Allocation")
    print("=" * 70)
    print()
    
    k = 3  # ML-KEM-768 module rank
    
    # Noise bound from LWE security analysis
    delta = 1.5  # Simplified noise bound
    
    # Decoder tolerance: q/(2t) where q is modulus, t is plaintext modulus
    decoder_tolerance = 832  # q/(2t) for ML-KEM-768 approximately
    
    print(f"Module rank k = {k}")
    print(f"Noise bound δ = {delta}")
    print(f"Decoder tolerance B = {decoder_tolerance}")
    print()
    
    # Compare bounds for different compression strategies
    strategies = [
        ("Uniform compression", np.diag([0.25, 0.25, 0.25])),
        ("Aggressive first coord", np.diag([0.5, 0.2, 0.2])),
        ("Very aggressive", np.diag([0.8, 0.1, 0.1])),
    ]
    
    for name, D in strategies:
        op_bound = operator_norm(D) * delta
        rms_bound = np.sqrt(k) * rms_amplification(D) * delta
        ratio = anisotropy_ratio(D)
        
        op_safe = "✓ SAFE" if op_bound <= decoder_tolerance else "✗ FAIL"
        rms_safe = "✓ SAFE" if rms_bound <= decoder_tolerance else "✗ FAIL"
        
        print(f"  {name}:")
        print(f"    ||D||·δ = {op_bound:.4f} {op_safe}")
        print(f"    √k·rmsAmp·δ = {rms_bound:.4f} {rms_safe}")
        print(f"    Anisotropy: {ratio:.4f}")
        print(f"    Overhead of RMS bound: {(rms_bound/op_bound - 1)*100:.1f}%")
        print()
    
    print("→ The RMS bound is slightly looser but computationally cheaper.")
    print("  For isotropic designs, the overhead vanishes.")
    print()


# ═══════════════════════════════════════════════════════════════
# Application 3: Optimal Compression Design
# ═══════════════════════════════════════════════════════════════
def app_optimal_design():
    """Design optimal compression operators under constraints."""
    print("=" * 70)
    print("APPLICATION 3: Optimal Compression Operator Design")
    print("=" * 70)
    print()
    
    k = 4
    target_compression = 2.0  # Target RMS amplification
    
    print(f"Goal: Design k={k} compression with rmsAmp = {target_compression}")
    print(f"Minimize: operator norm (worst-case noise amplification)")
    print()
    
    # Generate many random diagonal designs with fixed rmsAmp
    np.random.seed(42)
    n_trials = 10000
    best_opnorm = float('inf')
    best_d = None
    worst_opnorm = 0
    worst_d = None
    
    for _ in range(n_trials):
        d = np.abs(np.random.randn(k))
        # Normalize to target rmsAmp
        d = d * (target_compression * np.sqrt(k) / np.sqrt(np.sum(d**2)))
        opnorm = np.max(d)
        
        if opnorm < best_opnorm:
            best_opnorm = opnorm
            best_d = d.copy()
        if opnorm > worst_opnorm:
            worst_opnorm = opnorm
            worst_d = d.copy()
    
    # Balanced design (theorem says this is optimal)
    balanced_d = np.full(k, target_compression)
    balanced_opnorm = target_compression
    
    print(f"Balanced design:     d = [{', '.join(f'{x:.4f}' for x in balanced_d)}]")
    print(f"  ||D||_op = {balanced_opnorm:.6f}")
    print()
    print(f"Best random design:  d = [{', '.join(f'{x:.4f}' for x in best_d)}]")
    print(f"  ||D||_op = {best_opnorm:.6f}")
    print()
    print(f"Worst random design: d = [{', '.join(f'{x:.4f}' for x in worst_d)}]")
    print(f"  ||D||_op = {worst_opnorm:.6f}")
    print()
    print(f"Balanced is optimal: {balanced_opnorm <= best_opnorm + 1e-10}")
    print()
    print("→ The equipartition principle is confirmed: balanced entries")
    print("  minimize the operator norm at fixed RMS amplification.")
    print()


# ═══════════════════════════════════════════════════════════════
# Application 4: Security-Efficiency Tradeoff
# ═══════════════════════════════════════════════════════════════
def app_security_efficiency():
    """Analyze the security-efficiency tradeoff via spectral geometry."""
    print("=" * 70)
    print("APPLICATION 4: Security-Efficiency Tradeoff via Spectral Geometry")
    print("=" * 70)
    print()
    
    print("Key insight: at fixed compression quality (rmsAmp),")
    print("the decryption failure rate is controlled by the anisotropy ratio.")
    print()
    
    k = 4
    rms_target = 1.0
    
    # Generate operators with varying anisotropy
    ratios = [1.0, 1.2, 1.5, 1.8, 2.0]
    
    print(f"{'Anisotropy':>12}  {'||f||_op':>10}  {'Noise margin':>14}  {'Relative margin':>16}")
    print("-" * 60)
    
    delta = 1.0  # Noise bound
    for ratio in ratios:
        # For diagonal: ratio = max|d_i| / rms(d_i)
        # With one large and rest equal:
        # max = ratio * rms_target, sum = k * rms_target^2
        # So we need d = [ratio * rms, c, c, ..., c]
        # where c satisfies: (ratio^2 * rms^2 + (k-1)*c^2)/k = rms^2
        # => c^2 = (k*rms^2 - ratio^2*rms^2)/(k-1) = rms^2*(k-ratio^2)/(k-1)
        if ratio**2 > k:
            continue
        
        large = ratio * rms_target
        c_sq = rms_target**2 * (k - ratio**2) / (k - 1)
        if c_sq < 0:
            continue
        c = np.sqrt(c_sq)
        
        d = np.array([large] + [c] * (k - 1))
        D = np.diag(d)
        
        actual_rms = rms_amplification(D)
        actual_op = operator_norm(D)
        margin = 1.0 / actual_op  # Inverse: higher = safer
        
        print(f"{ratio:>12.2f}  {actual_op:>10.4f}  {margin:>14.4f}  {margin/1.0:>16.4f}")
    
    print()
    print("→ Lower anisotropy ratio = higher noise margin = better security.")
    print("  The equipartition principle says: BALANCE YOUR COMPRESSION.")
    print()


def main():
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  Applications of Spectral Compression Theory                       ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()
    
    app_mlkem_validation()
    app_noise_budget()
    app_optimal_design()
    app_security_efficiency()


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
demo.py — Spectral Gap and Equipartition Principle for Cryptographic Compression

Demonstrates:
1. The √k gap between operator norm and RMS amplification
2. The summation functional as the extremal example
3. Balanced vs. unbalanced compression matrices
4. Anisotropy ratio analysis for ML-KEM-style parameters
5. Random matrix spectral analysis confirming the bound
"""

import numpy as np
from numpy.linalg import norm, svd
import sys


def rms_amplification(A):
    """Compute the RMS amplification of matrix A.
    
    rmsAmp(A) = sqrt((1/k) * sum_i ||A e_i||^2)
              = sqrt(||A||_F^2 / k)
    where k is the number of columns (input dimension).
    """
    k = A.shape[1]
    col_norms_sq = np.sum(A**2, axis=0)
    return np.sqrt(np.sum(col_norms_sq) / k)


def operator_norm(A):
    """Compute the operator norm (largest singular value) of A."""
    return norm(A, ord=2)


def anisotropy_ratio(A):
    """Compute the anisotropy ratio: ||A||_op / rmsAmp(A)."""
    rms = rms_amplification(A)
    if rms < 1e-15:
        return 1.0
    return operator_norm(A) / rms


def frobenius_norm(A):
    """Compute the Frobenius norm of A."""
    return norm(A, ord='fro')


# ═══════════════════════════════════════════════════════════════
# Demo 1: The √k gap — summation functional
# ═══════════════════════════════════════════════════════════════
def demo_sqrt_k_gap():
    print("=" * 70)
    print("DEMO 1: The √k Gap — Summation Functional")
    print("=" * 70)
    print()
    print("The summation functional u(x) = Σ xᵢ maps ℝᵏ → ℝ.")
    print("Theorem: ||u||_op = √k, rmsAmp(u) = 1, ratio = √k (tight!)")
    print()
    print(f"{'k':>4}  {'||u||_op':>10}  {'rmsAmp':>10}  {'√k':>10}  {'ratio':>10}  {'= √k?':>8}")
    print("-" * 60)
    
    for k in [2, 3, 4, 8, 16, 64, 256]:
        # Summation functional: row vector of all ones
        u = np.ones((1, k))
        op = operator_norm(u)
        rms = rms_amplification(u)
        sqrt_k = np.sqrt(k)
        ratio = anisotropy_ratio(u)
        match = "✓" if abs(ratio - sqrt_k) < 1e-10 else "✗"
        print(f"{k:>4}  {op:>10.6f}  {rms:>10.6f}  {sqrt_k:>10.6f}  {ratio:>10.6f}  {match:>8}")
    
    print()
    print("→ The summation functional always achieves ratio = √k exactly.")
    print("  This confirms our sharpness theorem.")
    print()


# ═══════════════════════════════════════════════════════════════
# Demo 2: Balanced vs. unbalanced diagonal maps
# ═══════════════════════════════════════════════════════════════
def demo_balanced_vs_unbalanced():
    print("=" * 70)
    print("DEMO 2: Balanced vs. Unbalanced Diagonal Maps")
    print("=" * 70)
    print()
    print("Equipartition principle: among diagonal maps with fixed Frobenius norm,")
    print("balanced entries (all |dᵢ| equal) minimize the operator norm.")
    print()
    
    k = 4
    target_frobenius = 4.0  # Fixed Frobenius norm
    
    configs = [
        ("Balanced: (2,2,2,2)", [2, 2, 2, 2]),
        ("Slightly unbalanced: (3,2,2,1)", [3, 2, 2, 1]),  
        ("Moderately unbalanced: (3.5,1,1,0.5)", [3.5, 1, 1, 0.5]),
        ("Maximally anisotropic: (4,0,0,0)", [4, 0, 0, 0]),
    ]
    
    # Normalize all to same Frobenius norm
    print(f"{'Configuration':>40}  {'||D||_op':>10}  {'rmsAmp':>10}  {'ratio':>8}  {'Frob':>8}")
    print("-" * 85)
    
    for name, d in configs:
        d = np.array(d, dtype=float)
        # Normalize to target Frobenius norm
        current_frob = np.sqrt(np.sum(d**2))
        if current_frob > 0:
            d = d * (target_frobenius / current_frob)
        D = np.diag(d)
        op = operator_norm(D)
        rms = rms_amplification(D)
        ratio = anisotropy_ratio(D)
        frob = frobenius_norm(D)
        print(f"{name:>40}  {op:>10.4f}  {rms:>10.4f}  {ratio:>8.4f}  {frob:>8.4f}")
    
    print()
    print(f"→ All have the same Frobenius norm ({target_frobenius:.1f}), hence same rmsAmp.")
    print("  But the balanced configuration minimizes the operator norm!")
    print("  This is the equipartition principle in action.")
    print()


# ═══════════════════════════════════════════════════════════════
# Demo 3: Random matrices — the √k bound holds universally
# ═══════════════════════════════════════════════════════════════
def demo_random_matrices():
    print("=" * 70)
    print("DEMO 3: Random Matrices — The √k Bound Holds Universally")
    print("=" * 70)
    print()
    print("For random k×k matrices, we verify:")
    print("  rmsAmp(A) ≤ ||A||_op ≤ √k · rmsAmp(A)")
    print()
    
    np.random.seed(42)
    
    for k in [4, 8, 16, 32]:
        max_ratio = 0
        min_ratio = float('inf')
        num_trials = 1000
        
        for _ in range(num_trials):
            A = np.random.randn(k, k)
            ratio = anisotropy_ratio(A)
            max_ratio = max(max_ratio, ratio)
            min_ratio = min(min_ratio, ratio)
        
        sqrt_k = np.sqrt(k)
        print(f"k={k:>3}: ratio ∈ [{min_ratio:.4f}, {max_ratio:.4f}],  "
              f"√k = {sqrt_k:.4f},  "
              f"max/√k = {max_ratio/sqrt_k:.4f}")
    
    print()
    print("→ The ratio is always in [1, √k], confirming the theorem.")
    print("  For random Gaussian matrices, the ratio is typically close to 1")
    print("  (isotropic behavior), far from the √k worst case.")
    print()


# ═══════════════════════════════════════════════════════════════
# Demo 4: ML-KEM-style compression analysis
# ═══════════════════════════════════════════════════════════════
def demo_mlkem_compression():
    print("=" * 70)
    print("DEMO 4: ML-KEM-Style Compression Analysis")
    print("=" * 70)
    print()
    print("Analyzing spectral properties of compression matrices")
    print("representative of lattice-based key encapsulation schemes.")
    print()
    
    np.random.seed(123)
    
    # ML-KEM-768 has module rank k=3, with NTT-domain operations
    # We simulate block-diagonal compression operators
    k_module = 3  # Module rank
    n_poly = 256   # Polynomial degree (simplified)
    
    # Simulate compression: rounding to fewer bits
    # This is modeled as a diagonal-like operation with quantization
    
    print("Module rank k = 3 (ML-KEM-768 style)")
    print()
    
    # Case 1: Uniform compression (balanced)
    print("Case 1: Uniform compression across all coordinates")
    d_balanced = np.ones(k_module) * 2.5  # Same compression factor
    D_balanced = np.diag(d_balanced)
    print(f"  Entries: {d_balanced}")
    print(f"  ||D||_op = {operator_norm(D_balanced):.4f}")
    print(f"  rmsAmp  = {rms_amplification(D_balanced):.4f}")
    print(f"  Ratio   = {anisotropy_ratio(D_balanced):.4f} (optimal = 1.000)")
    print()
    
    # Case 2: Non-uniform compression (different bit depths per coordinate)
    print("Case 2: Non-uniform compression (different bit depths)")
    d_nonuniform = np.array([4.0, 2.0, 1.0])  # Varying compression
    D_nonuniform = np.diag(d_nonuniform)
    print(f"  Entries: {d_nonuniform}")
    print(f"  ||D||_op = {operator_norm(D_nonuniform):.4f}")
    print(f"  rmsAmp  = {rms_amplification(D_nonuniform):.4f}")
    print(f"  Ratio   = {anisotropy_ratio(D_nonuniform):.4f} (max = √3 = {np.sqrt(3):.4f})")
    print()
    
    # Case 3: Block-diagonal with NTT structure
    print("Case 3: Block-diagonal structure (NTT blocks)")
    blocks = []
    for i in range(k_module):
        # Each block is a circulant-like matrix (NTT structure)
        n_small = 8  # Small block for demonstration
        block = np.random.randn(n_small, n_small) * (1.0 / np.sqrt(n_small))
        blocks.append(block)
    
    A_block = np.block([
        [blocks[0], np.zeros((8,8)), np.zeros((8,8))],
        [np.zeros((8,8)), blocks[1], np.zeros((8,8))],
        [np.zeros((8,8)), np.zeros((8,8)), blocks[2]]
    ])
    
    # Analyze each block and the whole
    for i, block in enumerate(blocks):
        print(f"  Block {i}: ||B||_op = {operator_norm(block):.4f}, "
              f"rmsAmp = {rms_amplification(block):.4f}, "
              f"ratio = {anisotropy_ratio(block):.4f}")
    
    print(f"  Full:   ||A||_op = {operator_norm(A_block):.4f}, "
          f"rmsAmp = {rms_amplification(A_block):.4f}, "
          f"ratio = {anisotropy_ratio(A_block):.4f}")
    print(f"  √(3·8) = {np.sqrt(24):.4f} (theoretical max for k=24)")
    print()
    
    print("→ Block-diagonal structure keeps the anisotropy ratio moderate.")
    print("  The theorem guarantees it never exceeds √k, but structured")
    print("  operators typically achieve much better ratios.")
    print()


# ═══════════════════════════════════════════════════════════════
# Demo 5: Singular value analysis
# ═══════════════════════════════════════════════════════════════
def demo_singular_value_analysis():
    print("=" * 70)
    print("DEMO 5: Singular Value Analysis — The Spectral Picture")
    print("=" * 70)
    print()
    print("The anisotropy ratio measures how 'spread out' the singular values are.")
    print("ratio = max(σᵢ) / rms(σᵢ)")
    print()
    
    k = 8
    
    test_cases = [
        ("Identity", np.eye(k)),
        ("Balanced scaling", np.diag([3]*k)),
        ("Rank-1 (worst case)", np.ones((k, 1)) @ np.ones((1, k)) / np.sqrt(k)),
        ("Geometric decay", np.diag([2**(-i) for i in range(k)])),
        ("Two-level", np.diag([5, 5, 5, 5, 1, 1, 1, 1])),
    ]
    
    print(f"{'Matrix':>25}  {'σ_max':>8}  {'rmsAmp':>8}  {'ratio':>8}  {'√k':>6}")
    print("-" * 65)
    
    for name, A in test_cases:
        sigmas = svd(A, compute_uv=False)
        op = sigmas[0] if len(sigmas) > 0 else 0
        rms = rms_amplification(A)
        ratio = anisotropy_ratio(A)
        print(f"{name:>25}  {op:>8.4f}  {rms:>8.4f}  {ratio:>8.4f}  {np.sqrt(k):>6.4f}")
    
    print()
    print("→ The ratio is always in [1, √k].")
    print("  Identity and balanced scaling achieve ratio = 1 (optimal).")
    print("  The rank-1 case approaches the √k bound.")
    print()


# ═══════════════════════════════════════════════════════════════
# Demo 6: Correctness margin improvement
# ═══════════════════════════════════════════════════════════════
def demo_correctness_margin():
    print("=" * 70)
    print("DEMO 6: Cryptographic Correctness Margin Improvement")
    print("=" * 70)
    print()
    print("Comparing correctness thresholds:")
    print("  Old bound:  B_old = ||f||_op · δ")
    print("  New bound:  B_new = √k · rmsAmp(f) · δ")
    print("  (B_new ≥ B_old always, but B_new may be tighter for parameter search)")
    print()
    
    np.random.seed(456)
    delta = 1.0  # Noise bound
    
    k_values = [2, 3, 4, 8]
    
    for k in k_values:
        # Generate a "typical" compression-like matrix
        A = np.random.randn(k, k) * 0.5 + np.eye(k)
        
        old_bound = operator_norm(A) * delta
        new_bound = np.sqrt(k) * rms_amplification(A) * delta
        improvement = (new_bound / old_bound - 1) * 100
        
        print(f"k={k}: ||f||·δ = {old_bound:.4f},  √k·rmsAmp·δ = {new_bound:.4f}  "
              f"(overhead: {improvement:.1f}%, ratio: {anisotropy_ratio(A):.3f})")
    
    print()
    print("→ The √k·rmsAmp bound is always ≥ the operator norm bound.")
    print("  For well-structured (near-isotropic) operators, the overhead is small.")
    print("  The key insight: rmsAmp is COMPUTABLE from basis images alone,")
    print("  making it useful for parameter optimization even when the exact")
    print("  operator norm is expensive to compute.")
    print()


def main():
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  Spectral Optimization for Cryptographic Compression               ║")
    print("║  RMS Amplification, Anisotropy Ratio, and the √k Gap               ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()
    
    demo_sqrt_k_gap()
    demo_balanced_vs_unbalanced()
    demo_random_matrices()
    demo_mlkem_compression()
    demo_singular_value_analysis()
    demo_correctness_margin()
    
    print("=" * 70)
    print("Summary of Verified Results")
    print("=" * 70)
    print()
    print("1. rmsAmp(f) ≤ ||f||_op ≤ √k · rmsAmp(f)   [Formally verified]")
    print("2. The √k gap is tight (summation functional)  [Formally verified]")
    print("3. Balanced entries minimize ||D||_op at fixed rmsAmp [Formally verified]")
    print("4. Decode correctness from RMS bound          [Formally verified]")
    print()


if __name__ == "__main__":
    main()

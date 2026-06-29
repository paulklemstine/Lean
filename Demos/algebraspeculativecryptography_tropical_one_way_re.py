#!/usr/bin/env python3
"""
Tropical One-Way Kernel Duality: Applications

Demonstrates real-world applications:
1. Tropical hash security analysis
2. Network compression via kernel rank
3. Collision certificate verification
"""

import numpy as np
from algorithms import (
    tropical_gram, compose_kernels, verify_idempotent,
    verify_metric, find_generators, random_tropical_metric,
    tropical_matrix_power, tropical_matrix_multiply
)


def application_security_analysis():
    """Application 1: Tropical Hash Security Analysis
    
    Analyze the security of a tropical hash function by computing
    the kernel profile and checking structural invariants.
    """
    print("=" * 60)
    print("APPLICATION 1: Tropical Hash Security Analysis")
    print("=" * 60)
    
    # Simulate a tropical hash: M^⊗k for various k
    np.random.seed(42)
    n = 4
    M = np.random.uniform(0, 5, (n, n))
    
    print(f"\nBase matrix M ({n}×{n}):")
    print(np.round(M, 2))
    
    for k in [1, 2, 4, 8]:
        Mk = tropical_matrix_power(M, k)
        G = tropical_gram(Mk)
        is_idem, err = verify_idempotent(G)
        zd, sym, tri = verify_metric(G)
        gens = find_generators(G)
        
        print(f"\nk={k}: M^⊗{k}")
        print(f"  Kernel rank: {len(gens)}/{n}")
        print(f"  Symmetric: {sym}, Zero diag: {zd}")
        print(f"  Idempotent: {is_idem} (err: {err:.2e})")
        print(f"  Security indicator: {'HIGH' if len(gens) == n else 'LOW'}")


def application_network_compression():
    """Application 2: Network Compression via Kernel Rank
    
    Demonstrate that the generator rank gives the minimal
    representation size for a tropical network.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Network Compression via Kernel Rank")
    print("=" * 60)
    
    for n in [5, 10, 20]:
        kappa = random_tropical_metric(n, seed=n)
        gens = find_generators(kappa)
        
        # Compression ratio
        original_params = n * n
        compressed_params = len(gens) * n
        ratio = compressed_params / original_params
        
        print(f"\nn={n}: Generator rank = {len(gens)}")
        print(f"  Original parameters: {original_params}")
        print(f"  Compressed parameters: {compressed_params}")
        print(f"  Compression ratio: {ratio:.2%}")


def application_collision_certificates():
    """Application 3: Collision Certificate Verification
    
    Given two inputs that produce the same output through a tropical
    network, extract and verify the collision certificate.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Collision Certificate Verification")
    print("=" * 60)
    
    n = 4
    M = np.array([
        [0, 2, 5, 1],
        [3, 0, 2, 4],
        [1, 3, 0, 2],
        [4, 1, 3, 0]
    ], dtype=float)
    
    G = tropical_gram(M)
    print(f"\nKernel profile of 4×4 network:")
    print(np.round(G, 1))
    
    # Find collision certificates: pairs (a,b) where κ(a,b) is small
    print(f"\nCollision analysis (smaller κ = more likely collision):")
    for a in range(n):
        for b in range(a+1, n):
            # Find witness
            witnesses = []
            for k in range(n):
                if abs(G[a, b] - (M[a, k] + M[b, k])) < 1e-10:
                    witnesses.append(k)
            print(f"  κ({a},{b}) = {G[a,b]:.1f}, witnesses: {witnesses}")


if __name__ == "__main__":
    application_security_analysis()
    application_network_compression()
    application_collision_certificates()
    
    print("\n" + "=" * 60)
    print("ALL APPLICATIONS COMPLETE")
    print("=" * 60)


#!/usr/bin/env python3
"""
Tropical One-Way Kernel Duality: Demonstrations

This module demonstrates the key mathematical objects and theorems from
the tropical kernel duality theory with concrete numerical examples.
"""

import numpy as np
from typing import List, Tuple, Optional


def tropical_gram(M: np.ndarray) -> np.ndarray:
    """Compute the tropical Gram matrix: G[a,b] = min_k(M[a,k] + M[b,k]).
    
    This is the kernel profile of a tropical network.
    
    Args:
        M: n×n matrix over ℝ
    Returns:
        n×n tropical Gram matrix
    """
    n = M.shape[0]
    G = np.zeros((n, n))
    for a in range(n):
        for b in range(n):
            G[a, b] = min(M[a, k] + M[b, k] for k in range(n))
    return G


def compose_kernels(kappa1: np.ndarray, kappa2: np.ndarray) -> np.ndarray:
    """Tropical composition: (κ₁ ⊗ κ₂)(a,c) = min_b(κ₁(a,b) + κ₂(b,c)).
    
    Args:
        kappa1, kappa2: n×n kernel matrices
    Returns:
        n×n composed kernel matrix
    """
    n = kappa1.shape[0]
    result = np.zeros((n, n))
    for a in range(n):
        for c in range(n):
            result[a, c] = min(kappa1[a, b] + kappa2[b, c] for b in range(n))
    return result


def is_idempotent(kappa: np.ndarray, tol: float = 1e-10) -> bool:
    """Check if κ ⊗ κ = κ (tropical idempotency).
    
    Args:
        kappa: n×n kernel matrix
        tol: numerical tolerance
    Returns:
        True if κ is idempotent under tropical composition
    """
    composed = compose_kernels(kappa, kappa)
    return np.allclose(composed, kappa, atol=tol)


def distance_kernel(n: int, d: float) -> np.ndarray:
    """Distance kernel: 0 on diagonal, d off-diagonal.
    
    Args:
        n: matrix size
        d: off-diagonal distance
    Returns:
        n×n distance kernel
    """
    return d * (1 - np.eye(n))


def random_tropical_metric(n: int, max_weight: float = 10.0,
                           rng: Optional[np.random.Generator] = None) -> np.ndarray:
    """Generate a random tropical metric via shortest-path closure.
    
    Creates a random weighted graph and computes all-pairs shortest paths
    using Floyd-Warshall, giving a tropical metric (zero diagonal + triangle).
    
    Args:
        n: number of points
        max_weight: maximum edge weight
        rng: random number generator
    Returns:
        n×n tropical metric matrix
    """
    if rng is None:
        rng = np.random.default_rng()
    
    # Random edge weights
    W = rng.uniform(0, max_weight, (n, n))
    W = (W + W.T) / 2  # Symmetrize
    np.fill_diagonal(W, 0)
    
    # Floyd-Warshall shortest paths
    D = W.copy()
    for k in range(n):
        for i in range(n):
            for j in range(n):
                if D[i, k] + D[k, j] < D[i, j]:
                    D[i, j] = D[i, k] + D[k, j]
    return D


def find_generators(kappa: np.ndarray, tol: float = 1e-10) -> List[int]:
    """Find optimal witness generators for a kernel.
    
    A point k is a generator if there exist a, b such that
    κ(a,b) = κ(a,k) + κ(k,b).
    
    Args:
        kappa: n×n kernel matrix
        tol: numerical tolerance
    Returns:
        List of generator indices
    """
    n = kappa.shape[0]
    generators = []
    for k in range(n):
        is_gen = False
        for a in range(n):
            for b in range(n):
                if abs(kappa[a, b] - (kappa[a, k] + kappa[k, b])) < tol:
                    is_gen = True
                    break
            if is_gen:
                break
        if is_gen:
            generators.append(k)
    return generators


def verify_symmetry(kappa: np.ndarray, tol: float = 1e-10) -> bool:
    """Verify κ(a,b) = κ(b,a)."""
    return np.allclose(kappa, kappa.T, atol=tol)


def verify_triangle(kappa: np.ndarray, tol: float = 1e-10) -> bool:
    """Verify κ(a,c) ≤ κ(a,b) + κ(b,c) for all a,b,c."""
    n = kappa.shape[0]
    for a in range(n):
        for b in range(n):
            for c in range(n):
                if kappa[a, c] > kappa[a, b] + kappa[b, c] + tol:
                    return False
    return True


def demo_basic_kernel_profile():
    """Demo 1: Basic kernel profile computation."""
    print("=" * 60)
    print("DEMO 1: Kernel Profile from Tropical Matrix")
    print("=" * 60)
    
    M = np.array([
        [0, 3, 7],
        [2, 0, 5],
        [4, 1, 0]
    ], dtype=float)
    
    print(f"\nMatrix M:\n{M}")
    
    G = tropical_gram(M)
    print(f"\nTropical Gram (kernel profile) G[a,b] = min_k(M[a,k] + M[b,k]):\n{G}")
    
    print(f"\nSymmetric: {verify_symmetry(G)}")
    print(f"Idempotent (G ⊗ G = G): {is_idempotent(G)}")
    
    # Show witness for each entry
    n = M.shape[0]
    print("\nWitnesses (k achieving the minimum):")
    for a in range(n):
        for b in range(n):
            for k in range(n):
                if abs(G[a, b] - (M[a, k] + M[b, k])) < 1e-10:
                    print(f"  G[{a},{b}] = {G[a,b]:.1f} via k={k}: "
                          f"M[{a},{k}] + M[{b},{k}] = {M[a,k]:.1f} + {M[b,k]:.1f}")
                    break


def demo_idempotent_kernel():
    """Demo 2: Idempotent kernel theorem."""
    print("\n" + "=" * 60)
    print("DEMO 2: Idempotent Kernel Theorem")
    print("=" * 60)
    
    for d in [0, 1, 3, 5, 10]:
        kappa = distance_kernel(3, d)
        composed = compose_kernels(kappa, kappa)
        is_idem = is_idempotent(kappa)
        max_diff = np.max(np.abs(composed - kappa))
        print(f"\nd = {d}: Distance kernel on 3 points")
        print(f"  κ ⊗ κ = κ? {is_idem} (max diff: {max_diff:.2e})")
    
    print("\n--- Random tropical metrics (guaranteed idempotent) ---")
    rng = np.random.default_rng(42)
    for n in [5, 10, 20]:
        kappa = random_tropical_metric(n, rng=rng)
        is_idem = is_idempotent(kappa)
        has_zero_diag = np.allclose(np.diag(kappa), 0)
        has_triangle = verify_triangle(kappa)
        print(f"\nn={n}: Random tropical metric")
        print(f"  Zero diagonal: {has_zero_diag}")
        print(f"  Triangle inequality: {has_triangle}")
        print(f"  Idempotent: {is_idem}")


def demo_non_idempotent():
    """Demo 3: Non-idempotent Gram matrices."""
    print("\n" + "=" * 60)
    print("DEMO 3: Non-Idempotent Gram Matrices")
    print("=" * 60)
    
    rng = np.random.default_rng(123)
    
    diffs = []
    for trial in range(100):
        M = rng.uniform(0, 10, (5, 5))
        G = tropical_gram(M)
        G2 = compose_kernels(G, G)
        diff = np.max(np.abs(G2 - G))
        diffs.append(diff)
    
    diffs = np.array(diffs)
    print(f"\n100 random 5×5 matrices:")
    print(f"  Max |G² - G|: mean={diffs.mean():.3f}, max={diffs.max():.3f}")
    print(f"  Fraction idempotent (tol=1e-6): {np.mean(diffs < 1e-6):.1%}")
    print(f"\nConclusion: General Gram matrices are NOT idempotent.")
    print("Idempotency requires the triangle inequality (= being a metric).")


def demo_generator_rank():
    """Demo 4: Generator rank computation."""
    print("\n" + "=" * 60)
    print("DEMO 4: Generator Rank")
    print("=" * 60)
    
    rng = np.random.default_rng(7)
    
    for n in [5, 10, 15]:
        ranks = []
        for _ in range(50):
            kappa = random_tropical_metric(n, rng=rng)
            gens = find_generators(kappa)
            ranks.append(len(gens))
        
        print(f"\nn={n}: 50 random tropical metrics")
        print(f"  Generator rank: mean={np.mean(ranks):.1f}, "
              f"min={min(ranks)}, max={max(ranks)}")
        print(f"  Rank/n ratio: {np.mean(ranks)/n:.2f}")


def demo_composition_functoriality():
    """Demo 5: Composition preserves structure."""
    print("\n" + "=" * 60)
    print("DEMO 5: Composition Functoriality")
    print("=" * 60)
    
    rng = np.random.default_rng(99)
    
    # Two symmetric kernels
    kappa1 = random_tropical_metric(4, rng=rng)
    kappa2 = random_tropical_metric(4, rng=rng)
    
    composed = compose_kernels(kappa1, kappa2)
    composed_rev = compose_kernels(kappa2, kappa1)
    
    print(f"\nκ₁ symmetric: {verify_symmetry(kappa1)}")
    print(f"κ₂ symmetric: {verify_symmetry(kappa2)}")
    
    # Check: (κ₁ ⊗ κ₂)(a,c) = (κ₂ ⊗ κ₁)(c,a) for symmetric kernels
    max_diff = np.max(np.abs(composed - composed_rev.T))
    print(f"(κ₁⊗κ₂)(a,c) = (κ₂⊗κ₁)(c,a)? max diff = {max_diff:.2e}")
    
    # Composition of idempotent kernels
    comp_self1 = compose_kernels(kappa1, kappa1)
    comp_self2 = compose_kernels(kappa2, kappa2)
    print(f"\nκ₁ idempotent: {is_idempotent(kappa1)}")
    print(f"κ₂ idempotent: {is_idempotent(kappa2)}")
    print(f"κ₁ ⊗ κ₂ symmetric transpose: {max_diff < 1e-10}")


def demo_reconstruction():
    """Demo 6: Network reconstruction from kernel."""
    print("\n" + "=" * 60)
    print("DEMO 6: Certified Reconstruction")
    print("=" * 60)
    
    # Create a tropical metric (idempotent kernel)
    kappa = random_tropical_metric(5, rng=np.random.default_rng(42))
    
    print(f"\nOriginal kernel κ (5×5 tropical metric):")
    print(np.round(kappa, 2))
    
    # Reconstruct: use κ as the network matrix
    # Kernel profile of reconstruction = tropical Gram of κ
    reconstructed_kernel = tropical_gram(kappa)
    
    print(f"\nReconstructed kernel profile:")
    print(np.round(reconstructed_kernel, 2))
    
    # Check bound: reconstructed ≤ original (for metrics)
    bound_holds = np.all(reconstructed_kernel <= kappa + 1e-10)
    print(f"\nReconstruction bound (reconstructed ≤ original): {bound_holds}")
    
    # For tropical metrics, reconstruction = original
    max_diff = np.max(np.abs(reconstructed_kernel - kappa))
    print(f"Max |reconstructed - original|: {max_diff:.2e}")
    print(f"Exact recovery: {max_diff < 1e-10}")


if __name__ == "__main__":
    demo_basic_kernel_profile()
    demo_idempotent_kernel()
    demo_non_idempotent()
    demo_generator_rank()
    demo_composition_functoriality()
    demo_reconstruction()
    
    print("\n" + "=" * 60)
    print("ALL DEMOS COMPLETE")
    print("=" * 60)

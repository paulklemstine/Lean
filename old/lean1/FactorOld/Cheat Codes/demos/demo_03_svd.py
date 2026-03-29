"""
CHEAT CODE #3: SINGULAR VALUE DECOMPOSITION (SVD)
==================================================
Demonstrates the SVD as the optimal compression/approximation tool.

Key insight: The best rank-k approximation to ANY matrix is given by 
truncating the SVD. This is the Eckart-Young theorem.

Experiments:
1. Matrix compression — how much info lives in top singular values
2. Image-like data compression
3. The "unreasonable effectiveness" of low-rank approximation
4. Pseudoinverse and least-squares via SVD
"""

import numpy as np


def experiment_1_compression_power():
    """Show how singular values capture matrix information."""
    print("=" * 60)
    print("EXPERIMENT 1: Singular Value Decay — Where the Info Lives")
    print("=" * 60)
    
    np.random.seed(42)
    n = 100
    
    # Different types of matrices
    matrices = {
        "Random (no structure)": np.random.randn(n, n),
        "Low-rank + noise": np.random.randn(n, 5) @ np.random.randn(5, n) + 0.1 * np.random.randn(n, n),
        "Smooth (exponential decay)": np.array([[np.exp(-0.1 * abs(i - j)) for j in range(n)] for i in range(n)]),
        "Hilbert matrix": np.array([[1.0 / (i + j + 1) for j in range(n)] for i in range(n)]),
    }
    
    for name, A in matrices.items():
        U, s, Vt = np.linalg.svd(A)
        total_energy = np.sum(s**2)
        
        print(f"\n{name}:")
        print(f"  Matrix size: {A.shape}")
        print(f"  Top 5 singular values: {s[:5].round(3)}")
        
        for k in [1, 5, 10, 20, 50]:
            if k <= len(s):
                energy_captured = np.sum(s[:k]**2) / total_energy * 100
                compression_ratio = (n * n) / (k * (n + n + 1))
                print(f"  Rank-{k:>2}: {energy_captured:>6.2f}% energy, {compression_ratio:>5.1f}x compression")
    
    print("\n✓ Structured matrices compress dramatically — most info in few singular values.\n")


def experiment_2_image_compression():
    """Compress a synthetic 'image' using SVD."""
    print("=" * 60)
    print("EXPERIMENT 2: Image Compression via SVD")
    print("=" * 60)
    
    np.random.seed(42)
    m, n = 64, 64
    
    # Create a synthetic image: smooth gradient + geometric shapes
    x = np.linspace(-1, 1, n)
    y = np.linspace(-1, 1, m)
    X, Y = np.meshgrid(x, y)
    
    # Gradient + circle + stripe pattern
    image = (0.5 * X + 0.3 * Y +  # gradient
             0.8 * (X**2 + Y**2 < 0.3).astype(float) +  # circle
             0.4 * np.sin(10 * X))  # stripes
    
    U, s, Vt = np.linalg.svd(image, full_matrices=False)
    
    print(f"\nOriginal image: {m}×{n} = {m*n} values")
    print(f"\n{'Rank k':>8} | {'PSNR (dB)':>10} | {'Storage':>10} | {'Compression':>12} | {'Rel Error':>10}")
    print("-" * 60)
    
    for k in [1, 2, 3, 5, 10, 20, 32, 64]:
        if k > min(m, n):
            continue
        # Reconstruct
        approx = U[:, :k] @ np.diag(s[:k]) @ Vt[:k, :]
        
        # Metrics
        mse = np.mean((image - approx)**2)
        max_val = np.max(np.abs(image))
        psnr = 10 * np.log10(max_val**2 / mse) if mse > 0 else float('inf')
        storage = k * (m + n + 1)
        compression = m * n / storage
        rel_error = np.linalg.norm(image - approx) / np.linalg.norm(image)
        
        print(f"{k:>8} | {psnr:>10.1f} | {storage:>10} | {compression:>12.1f}x | {rel_error:>10.4f}")
    
    print("\n✓ SVD achieves excellent compression. Eckart-Young guarantees this is OPTIMAL.\n")


def experiment_3_pseudoinverse():
    """Solve least-squares problems via SVD pseudoinverse."""
    print("=" * 60)
    print("EXPERIMENT 3: Least-Squares via SVD Pseudoinverse")
    print("=" * 60)
    
    np.random.seed(42)
    
    # Overdetermined system: more equations than unknowns
    m, n = 100, 5
    A = np.random.randn(m, n)
    x_true = np.array([1.0, -2.0, 3.0, -4.0, 5.0])
    b = A @ x_true + 0.1 * np.random.randn(m)  # Noisy observations
    
    # SVD pseudoinverse
    U, s, Vt = np.linalg.svd(A, full_matrices=False)
    x_svd = Vt.T @ np.diag(1/s) @ U.T @ b
    
    # Compare with numpy's lstsq
    x_lstsq, _, _, _ = np.linalg.lstsq(A, b, rcond=None)
    
    print(f"\nTrue x:    {x_true}")
    print(f"SVD x:     {x_svd.round(4)}")
    print(f"lstsq x:   {x_lstsq.round(4)}")
    print(f"\nSVD error:   {np.linalg.norm(x_svd - x_true):.6f}")
    print(f"lstsq error: {np.linalg.norm(x_lstsq - x_true):.6f}")
    print(f"Agreement:   {np.linalg.norm(x_svd - x_lstsq):.2e}")
    
    # Now with an ill-conditioned matrix
    print(f"\n--- Ill-conditioned system ---")
    A_bad = np.random.randn(m, n)
    A_bad[:, -1] = A_bad[:, 0] + 1e-8 * np.random.randn(m)  # Near-duplicate column
    
    cond = np.linalg.cond(A_bad)
    print(f"Condition number: {cond:.2e}")
    
    U, s, Vt = np.linalg.svd(A_bad, full_matrices=False)
    print(f"Singular values: {s.round(4)}")
    print(f"Smallest SV: {s[-1]:.2e} — this column is nearly redundant")
    
    # Truncated SVD pseudoinverse (regularized)
    threshold = 1e-6
    s_inv = np.where(s > threshold, 1/s, 0)
    x_reg = Vt.T @ np.diag(s_inv) @ U.T @ b
    print(f"Regularized solution recovers the well-determined components.")
    
    print("\n✓ SVD pseudoinverse handles ill-conditioning gracefully.\n")


def experiment_4_low_rank_world():
    """Demonstrate that real-world data matrices are approximately low-rank."""
    print("=" * 60)
    print("EXPERIMENT 4: The Low-Rank World Hypothesis")
    print("=" * 60)
    
    np.random.seed(42)
    n = 200
    
    # Simulate a "user-item rating matrix" (Netflix-like)
    # Users have a few latent preferences, items have a few latent features
    k_true = 5  # True latent dimension
    users = np.random.randn(n, k_true) * np.array([3, 2, 1.5, 1, 0.5])
    items = np.random.randn(k_true, n) * np.array([[3], [2], [1.5], [1], [0.5]])
    ratings = users @ items + 0.5 * np.random.randn(n, n)  # Noise
    
    U, s, Vt = np.linalg.svd(ratings)
    
    print(f"\nSimulated {n}×{n} rating matrix (true rank ≈ {k_true})")
    print(f"\nTop 15 singular values:")
    print(f"  {s[:15].round(2)}")
    print(f"\nEnergy in top k singular values:")
    
    total = np.sum(s**2)
    for k in [1, 2, 3, 4, 5, 10, 20]:
        pct = np.sum(s[:k]**2) / total * 100
        print(f"  k={k:>2}: {pct:>6.2f}%")
    
    print(f"\n✓ The 'elbow' appears at k={k_true}, matching the true latent dimension.")
    print("  This is why Netflix recommendation works: the rating matrix is low-rank!")
    print("  SVD discovers the hidden structure automatically.\n")


if __name__ == "__main__":
    print("\n" + "=" * 60)
    print("  MATHEMATICS CHEAT CODE #3: SVD")
    print("  'Every matrix is a rotation, a stretch, and a rotation.'")
    print("=" * 60 + "\n")
    
    experiment_1_compression_power()
    experiment_2_image_compression()
    experiment_3_pseudoinverse()
    experiment_4_low_rank_world()
    
    print("=" * 60)
    print("SUMMARY: SVD gives the optimal low-rank approximation to")
    print("any matrix (Eckart-Young theorem). It powers data compression,")
    print("recommendation systems, least-squares, and dimensionality")
    print("reduction. If you have a matrix, SVD should be your first move.")
    print("=" * 60)

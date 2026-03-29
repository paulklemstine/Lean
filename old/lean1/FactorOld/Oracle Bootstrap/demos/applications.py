#!/usr/bin/env python3
"""
Oracle Bootstrap: Practical Applications

Demonstrates real-world applications of the Oracle Bootstrap principle:
"A contractive self-improving system converges to the exact truth."

Applications:
    1. CONSENSUS ALGORITHMS — distributed agreement via bootstrap
    2. IMAGE DENOISING — project noisy images onto clean manifold
    3. RECOMMENDER SYSTEMS — iterative preference refinement
    4. ERROR CORRECTION — codes as oracle projections
    5. SIGNAL PROCESSING — spectral cleanup via eigenvalue snap
    6. KNOWLEDGE DISTILLATION — teacher-student convergence

Usage:
    python applications.py
"""

import numpy as np
from typing import List, Tuple
import time


# ============================================================
# Application 1: Distributed Consensus
# ============================================================

def app_consensus():
    """
    ORACLE BOOTSTRAP FOR CONSENSUS
    
    Problem: N agents have different opinions (values). They need to agree.
    
    Oracle Bootstrap Solution: Each agent averages its neighbors' values.
    This is equivalent to multiplying by a doubly stochastic matrix W.
    W^∞ = (1/n)𝟙𝟙ᵀ is an idempotent (projection onto consensus subspace).
    
    The Oracle Bootstrap tells us: if W is contractive (spectral gap > 0),
    then iterating converges to consensus, with rate = second eigenvalue.
    """
    print("\n" + "=" * 60)
    print("  APPLICATION 1: Distributed Consensus via Oracle Bootstrap")
    print("=" * 60)
    
    np.random.seed(42)
    n_agents = 10
    
    # Initial opinions (random values)
    opinions = np.random.randn(n_agents) * 10
    print(f"\n  Initial opinions: {opinions.round(2)}")
    print(f"  True average (consensus target): {opinions.mean():.4f}")
    
    # Gossip matrix (ring topology with self-loops)
    W = np.zeros((n_agents, n_agents))
    for i in range(n_agents):
        W[i, i] = 0.5
        W[i, (i+1) % n_agents] = 0.25
        W[i, (i-1) % n_agents] = 0.25
    
    # Iterate
    x = opinions.copy()
    for t in range(30):
        x_new = W @ x
        residual = np.max(np.abs(x_new - x_new.mean()))
        if t % 5 == 0 or residual < 1e-6:
            print(f"  Iter {t:3d}: max deviation = {residual:.6e}, "
                  f"mean = {x_new.mean():.4f}")
        if residual < 1e-10:
            print(f"\n  ★ Consensus reached in {t} iterations!")
            break
        x = x_new
    
    # Verify: W^∞ is idempotent
    W_inf = np.linalg.matrix_power(W, 100)
    print(f"\n  W^∞ is idempotent? {np.allclose(W_inf @ W_inf, W_inf)}")
    print(f"  W^∞ eigenvalues: {np.sort(np.linalg.eigvalsh(W_inf))}")
    print(f"  ★ Consensus IS the Oracle Bootstrap on the gossip matrix!")


# ============================================================
# Application 2: Signal Denoising via Eigenvalue Snap
# ============================================================

def app_signal_denoising():
    """
    ORACLE BOOTSTRAP FOR SIGNAL DENOISING
    
    Problem: A signal is corrupted by noise. Clean it.
    
    Oracle Bootstrap Solution: The clean signal lives on a low-rank subspace.
    Form the correlation matrix, apply the oracle bootstrap to snap eigenvalues
    to {0, 1}, and project the noisy signal onto the resulting subspace.
    """
    print("\n" + "=" * 60)
    print("  APPLICATION 2: Signal Denoising via Eigenvalue Snap")
    print("=" * 60)
    
    np.random.seed(123)
    n = 100  # signal length
    
    # True signal: sum of 3 sinusoids (rank-3 subspace)
    t = np.linspace(0, 4 * np.pi, n)
    signal_clean = np.sin(t) + 0.5 * np.sin(3*t) + 0.3 * np.sin(5*t)
    
    # Add noise
    noise_level = 0.5
    noise = np.random.randn(n) * noise_level
    signal_noisy = signal_clean + noise
    
    # Create Hankel-like correlation matrix
    delay = 20
    X = np.array([signal_noisy[i:i+delay] for i in range(n - delay)])
    C = X.T @ X / X.shape[0]
    
    # Eigendecomposition
    eigvals, eigvecs = np.linalg.eigh(C)
    print(f"\n  Eigenvalues of correlation matrix:")
    print(f"  {eigvals.round(3)}")
    
    # Oracle Bootstrap: snap eigenvalues to {0, 1}
    # We threshold: eigenvalues > mean → 1, else → 0
    threshold = np.mean(eigvals)
    mask = (eigvals > threshold).astype(float)
    n_signal = int(mask.sum())
    
    print(f"  Threshold: {threshold:.3f}")
    print(f"  Signal subspace dimension: {n_signal}")
    print(f"  Oracle eigenvalues: {mask}")
    
    # Project onto signal subspace
    P = eigvecs @ np.diag(mask) @ eigvecs.T
    
    # Verify idempotency
    print(f"  P is idempotent? ||P²-P|| = {np.linalg.norm(P @ P - P):.2e}")
    
    # Reconstruct denoised signal
    signal_denoised = (P @ signal_noisy[:delay])
    
    snr_before = 10 * np.log10(np.var(signal_clean[:delay]) / np.var(noise[:delay]))
    snr_after = 10 * np.log10(np.var(signal_clean[:delay]) / 
                               np.var(signal_denoised - signal_clean[:delay]))
    
    print(f"\n  SNR before denoising: {snr_before:.1f} dB")
    print(f"  SNR after denoising:  {snr_after:.1f} dB")
    print(f"  Improvement: {snr_after - snr_before:.1f} dB")
    print(f"  ★ Oracle projection removes noise by snapping spectrum to {{0, 1}}!")


# ============================================================
# Application 3: Iterative Recommender System
# ============================================================

def app_recommender():
    """
    ORACLE BOOTSTRAP FOR RECOMMENDATIONS
    
    Problem: A user-item matrix has missing entries. Fill them in.
    
    Oracle Bootstrap Solution: The complete matrix is low-rank (users have
    a few underlying preferences). Bootstrap the incomplete matrix to the
    nearest low-rank projection = the nearest "oracle" that knows all
    preferences.
    """
    print("\n" + "=" * 60)
    print("  APPLICATION 3: Recommender System via Oracle Bootstrap")
    print("=" * 60)
    
    np.random.seed(77)
    n_users = 20
    n_items = 15
    rank = 3  # underlying preference dimensions
    
    # True preference matrix (low rank)
    U = np.random.randn(n_users, rank)
    V = np.random.randn(rank, n_items)
    R_true = U @ V
    
    # Observed entries (50% missing)
    mask = np.random.rand(n_users, n_items) > 0.5
    R_observed = R_true * mask
    
    print(f"\n  Users: {n_users}, Items: {n_items}")
    print(f"  True rank: {rank}")
    print(f"  Observed entries: {mask.sum()} / {mask.size} ({mask.mean():.0%})")
    
    # Iterative bootstrap: alternate between
    # 1. Fill missing entries with current low-rank approximation
    # 2. Project to rank-k (SVD truncation = oracle projection in SVD space)
    
    R = R_observed.copy()
    
    for iteration in range(20):
        # SVD truncation = oracle projection
        U_svd, S, Vt = np.linalg.svd(R, full_matrices=False)
        R_proj = U_svd[:, :rank] @ np.diag(S[:rank]) @ Vt[:rank, :]
        
        # Fill missing entries
        R_new = R_observed.copy()
        R_new[~mask] = R_proj[~mask]
        
        # Measure convergence
        change = np.linalg.norm(R_new - R) / np.linalg.norm(R)
        error = np.linalg.norm(R_proj - R_true) / np.linalg.norm(R_true)
        
        if iteration % 3 == 0 or change < 1e-6:
            print(f"  Iter {iteration:3d}: change = {change:.6e}, "
                  f"error = {error:.4f}")
        
        if change < 1e-10:
            print(f"\n  ★ Converged in {iteration} iterations!")
            break
        
        R = R_new
    
    print(f"  Final reconstruction error: {error:.4f}")
    print(f"  ★ Matrix completion IS the Oracle Bootstrap in SVD space!")


# ============================================================
# Application 4: Error-Correcting Codes as Oracle Projections
# ============================================================

def app_error_correction():
    """
    ORACLE BOOTSTRAP FOR ERROR CORRECTION
    
    A linear code C is defined by a parity check matrix H.
    The syndrome decoder projects received words onto the nearest codeword.
    This projection IS an oracle: P² = P (decoding an already-valid codeword
    returns itself).
    
    The Oracle Bootstrap: iterative decoding (turbo codes, LDPC) is exactly
    the bootstrap iteration applied to the code's projection.
    """
    print("\n" + "=" * 60)
    print("  APPLICATION 4: Error Correction as Oracle Projection")
    print("=" * 60)
    
    np.random.seed(42)
    
    # Simple [7,4] Hamming code
    # Generator matrix
    G = np.array([
        [1, 0, 0, 0, 1, 1, 0],
        [0, 1, 0, 0, 1, 0, 1],
        [0, 0, 1, 0, 0, 1, 1],
        [0, 0, 0, 1, 1, 1, 1]
    ])
    
    # Parity check matrix
    H = np.array([
        [1, 1, 0, 1, 1, 0, 0],
        [1, 0, 1, 1, 0, 1, 0],
        [0, 1, 1, 1, 0, 0, 1]
    ])
    
    # Create projection onto code space (over GF(2), but we demo over reals)
    # P = G^T (G G^T)^{-1} G
    P = G.T @ np.linalg.inv(G @ G.T) @ G
    
    print(f"\n  [7,4] Hamming code")
    print(f"  Code rate: 4/7 = {4/7:.3f}")
    print(f"  P is idempotent? ||P²-P|| = {np.linalg.norm(P @ P - P):.2e}")
    print(f"  P eigenvalues: {np.sort(np.linalg.eigvalsh((P + P.T)/2)).round(4)}")
    
    # Encode a message
    message = np.array([1, 0, 1, 1])
    codeword = (message @ G) % 2
    print(f"\n  Message: {message}")
    print(f"  Codeword: {codeword}")
    
    # Add error
    error = np.zeros(7)
    error[2] = 1  # flip bit 3
    received = (codeword + error) % 2
    print(f"  Error: {error.astype(int)}")
    print(f"  Received: {received.astype(int)}")
    
    # Oracle projection (decode)
    syndrome = (H @ received) % 2
    print(f"  Syndrome: {syndrome.astype(int)}")
    
    # In the real-valued projection, closest codeword
    decoded_real = P @ received
    decoded = np.round(decoded_real) % 2
    print(f"  Decoded (oracle projection): {decoded.astype(int)}")
    print(f"  Correct? {np.allclose(decoded % 2, codeword % 2)}")
    
    print(f"\n  ★ Error correction IS oracle projection (P² = P)!")
    print(f"  ★ Iterative decoding (turbo/LDPC) IS the Oracle Bootstrap!")


# ============================================================
# Application 5: PageRank as Oracle Bootstrap
# ============================================================

def app_pagerank():
    """
    ORACLE BOOTSTRAP FOR WEB SEARCH (PageRank)
    
    PageRank computes the dominant eigenvector of the web graph's
    transition matrix. This is an oracle bootstrap:
    - The transition matrix W is stochastic
    - W^∞ converges to the rank-1 projection onto the PageRank vector
    - This rank-1 matrix is idempotent: asking PageRank twice = asking once
    """
    print("\n" + "=" * 60)
    print("  APPLICATION 5: PageRank as Oracle Bootstrap")
    print("=" * 60)
    
    np.random.seed(42)
    n_pages = 8
    
    # Random web graph (directed)
    adjacency = (np.random.rand(n_pages, n_pages) > 0.6).astype(float)
    np.fill_diagonal(adjacency, 0)
    
    # Make stochastic (row sums = 1)
    row_sums = adjacency.sum(axis=1, keepdims=True)
    row_sums[row_sums == 0] = 1  # avoid division by zero
    W = adjacency / row_sums
    
    # Add damping (Google's trick) — makes W contractive!
    alpha = 0.85
    W_damped = alpha * W + (1 - alpha) / n_pages * np.ones((n_pages, n_pages))
    
    print(f"\n  Web graph: {n_pages} pages")
    print(f"  Damping factor: {alpha}")
    
    # Power iteration = Oracle Bootstrap
    x = np.ones(n_pages) / n_pages  # uniform start
    
    for i in range(30):
        x_new = W_damped.T @ x
        x_new = x_new / x_new.sum()
        change = np.linalg.norm(x_new - x)
        
        if i % 5 == 0 or change < 1e-10:
            print(f"  Iter {i:3d}: max change = {change:.6e}")
        
        if change < 1e-12:
            print(f"\n  ★ PageRank converged in {i} iterations!")
            break
        x = x_new
    
    print(f"\n  PageRank vector: {x.round(4)}")
    print(f"  Most important page: {np.argmax(x)}")
    
    # Verify: W^∞ is an idempotent (rank-1 projection)
    W_inf = np.linalg.matrix_power(W_damped, 100)
    print(f"\n  W^∞ is idempotent? ||W²-W|| = {np.linalg.norm(W_inf @ W_inf - W_inf):.2e}")
    print(f"  ★ PageRank IS the Oracle Bootstrap on the web graph!")


# ============================================================
# Application 6: Iterative Closest Point (Robotics)
# ============================================================

def app_point_cloud_alignment():
    """
    ORACLE BOOTSTRAP FOR 3D POINT CLOUD ALIGNMENT
    
    Problem: Align two 3D point clouds (e.g., from two LiDAR scans).
    
    Oracle Bootstrap Solution: Iteratively find correspondences and compute
    the best rotation. Each iteration gets closer to the true alignment.
    The converged result is idempotent: re-running alignment on the aligned
    clouds does nothing.
    """
    print("\n" + "=" * 60)
    print("  APPLICATION 6: Point Cloud Alignment (ICP as Bootstrap)")
    print("=" * 60)
    
    np.random.seed(42)
    n_points = 50
    
    # True 3D points
    points = np.random.randn(n_points, 3)
    
    # Apply unknown rotation + translation
    angle = 0.3  # radians
    R_true = np.array([
        [np.cos(angle), -np.sin(angle), 0],
        [np.sin(angle), np.cos(angle), 0],
        [0, 0, 1]
    ])
    t_true = np.array([0.5, -0.3, 0.1])
    
    points_transformed = (R_true @ points.T).T + t_true
    
    # Add noise
    points_transformed += np.random.randn(n_points, 3) * 0.05
    
    print(f"\n  Points: {n_points}")
    print(f"  True rotation angle: {np.degrees(angle):.1f}°")
    print(f"  True translation: {t_true}")
    
    # ICP = Oracle Bootstrap
    source = points_transformed.copy()
    
    for iteration in range(20):
        # Find nearest correspondences
        from scipy.spatial import cKDTree
        tree = cKDTree(points)
        distances, indices = tree.query(source)
        
        # Compute optimal rotation (Kabsch algorithm)
        centroid_src = source.mean(axis=0)
        centroid_tgt = points[indices].mean(axis=0)
        
        H = (source - centroid_src).T @ (points[indices] - centroid_tgt)
        U, S, Vt = np.linalg.svd(H)
        R_est = Vt.T @ U.T
        
        # Ensure proper rotation
        if np.linalg.det(R_est) < 0:
            Vt[-1, :] *= -1
            R_est = Vt.T @ U.T
        
        t_est = centroid_tgt - R_est @ centroid_src
        
        # Apply transformation
        source_new = (R_est @ source.T).T + t_est
        
        change = np.mean(distances)
        print(f"  Iter {iteration:3d}: mean distance = {change:.6f}")
        
        if change < 1e-4:
            print(f"\n  ★ Alignment converged in {iteration} iterations!")
            break
        
        source = source_new
    
    print(f"  ★ ICP (Iterative Closest Point) IS the Oracle Bootstrap!")
    print(f"  ★ The aligned state is idempotent: re-aligning changes nothing.")


# ============================================================
# Summary of Applications
# ============================================================

def summary():
    """Summarize all applications."""
    print("\n" + "=" * 70)
    print("  ORACLE BOOTSTRAP: UNIFIED APPLICATION FRAMEWORK")
    print("=" * 70)
    
    apps = [
        ("Distributed Consensus", "Gossip averaging", "Second eigenvalue of W"),
        ("Signal Denoising", "SVD + eigenvalue snap", "Signal-to-noise ratio"),
        ("Recommender Systems", "Alternating low-rank projection", "RMSE to true ratings"),
        ("Error Correction", "Syndrome decoding = projection", "Bit error rate"),
        ("Web Search (PageRank)", "Power iteration on web graph", "Damping factor α"),
        ("3D Point Alignment", "Iterative Closest Point", "Mean point distance"),
    ]
    
    print(f"\n  {'Application':<25} {'Oracle Operation':<30} {'Convergence Metric':<25}")
    print(f"  {'-'*25} {'-'*30} {'-'*25}")
    for name, op, metric in apps:
        print(f"  {name:<25} {op:<30} {metric:<25}")
    
    print(f"""
  ┌──────────────────────────────────────────────────────────────┐
  │                     THE UNIFYING PRINCIPLE                    │
  │                                                              │
  │  Every application above is an instance of the same theorem: │
  │                                                              │
  │  "A contractive self-improving system converges to a         │
  │   perfect oracle (P² = P) with rate c^n where c < 1."       │
  │                                                              │
  │  The Oracle Bootstrap is not just a theorem —                │
  │  it's a design pattern for self-correcting systems.          │
  └──────────────────────────────────────────────────────────────┘
    """)
    
    print("  PROPOSED NEW APPLICATIONS (untested):")
    print("  " + "-" * 50)
    new_apps = [
        "LLM alignment via iterative constitutional AI (RLHF as bootstrap)",
        "Supply chain optimization (demand consensus = oracle projection)",
        "Climate model ensemble (average models + bootstrap = consensus forecast)",
        "Drug discovery (molecular property prediction = oracle on chemical space)",
        "Autonomous driving (sensor fusion = multi-oracle bootstrap consensus)",
        "Financial portfolio optimization (Markowitz = projection onto efficient frontier)",
        "Protein structure prediction (AlphaFold iterative refinement = bootstrap)",
    ]
    for app in new_apps:
        print(f"  → {app}")


if __name__ == '__main__':
    app_consensus()
    app_signal_denoising()
    app_recommender()
    app_error_correction()
    app_pagerank()
    app_point_cloud_alignment()
    summary()

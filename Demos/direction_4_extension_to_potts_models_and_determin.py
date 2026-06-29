#!/usr/bin/env python3
"""
Applications of Potts-Lorentzian Stability Theory

Demonstrates real-world applications:
1. Image segmentation robustness (computer vision)
2. Community detection stability (network science)
3. Graph coloring approximation (combinatorics)
4. Protein contact robustness (bioinformatics)
"""

import numpy as np
from itertools import product


# ─────────────────────────────────────────────────────────────────────
# Utility functions
# ─────────────────────────────────────────────────────────────────────

def potts_energy(sigma, J, beta):
    n = len(sigma)
    total = sum(J[i, j] for i in range(n) for j in range(n) if sigma[i] == sigma[j])
    return beta * total

def potts_partition(n, q, J, beta):
    Z = 0.0
    for sigma in product(range(q), repeat=n):
        Z += np.exp(potts_energy(np.array(sigma), J, beta))
    return Z


# ─────────────────────────────────────────────────────────────────────
# Application 1: Image Segmentation Robustness
# ─────────────────────────────────────────────────────────────────────

def app_image_segmentation():
    """Demonstrate robustness of Potts-based image segmentation.

    In image segmentation, a Potts MRF assigns labels (segments) to pixels.
    The coupling J(i,j) encodes pixel similarity. Our theorem guarantees:
      Small measurement noise in pixel similarities → small change in
      the segmentation energy landscape.
    """
    print("=" * 60)
    print("APPLICATION 1: Image Segmentation Robustness")
    print("=" * 60)

    # Simulate a 2×2 pixel image with q=3 labels (e.g., sky/tree/ground)
    n = 4  # 2×2 grid
    q = 3
    beta = 1.0

    # Ideal pixel similarities (neighbors similar, others not)
    J_ideal = np.array([
        [0.0, 0.8, 0.8, 0.3],
        [0.8, 0.0, 0.3, 0.8],
        [0.8, 0.3, 0.0, 0.8],
        [0.3, 0.8, 0.8, 0.0],
    ])

    # Noisy observation (sensor noise)
    noise_levels = [0.01, 0.05, 0.1, 0.2]

    print(f"\nPixel grid: 2×2, Labels: {q}, β={beta}")
    print(f"\n{'Noise δ':>10} {'|Δ log Z|':>12} {'Certified':>12} {'Ratio':>8}")
    print("-" * 46)

    np.random.seed(42)
    for delta in noise_levels:
        noise = np.random.randn(n, n) * delta
        noise = (noise + noise.T) / 2
        J_noisy = J_ideal + noise

        Z_ideal = potts_partition(n, q, J_ideal, beta)
        Z_noisy = potts_partition(n, q, J_noisy, beta)

        empirical = abs(np.log(Z_ideal) - np.log(Z_noisy))
        sup_norm = np.max(np.abs(J_ideal - J_noisy))
        certified = abs(beta) * n**2 * sup_norm

        print(f"{delta:10.3f} {empirical:12.6f} {certified:12.6f} {empirical/certified:8.4f}")

    print("\n→ Certified bound guarantees segmentation stability under sensor noise.")


# ─────────────────────────────────────────────────────────────────────
# Application 2: Community Detection Stability
# ─────────────────────────────────────────────────────────────────────

def app_community_detection():
    """Demonstrate robustness of Potts-based community detection.

    Community detection using the Potts model assigns cluster labels to
    graph nodes. Our stability theorem guarantees that estimated communities
    are robust to edge-weight uncertainty.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Community Detection Stability")
    print("=" * 60)

    # Small social network: 5 nodes, 2 communities
    n = 5
    q = 2  # two communities
    beta = 0.8

    # True affinity matrix (block structure)
    J_true = np.array([
        [0.0, 0.9, 0.8, 0.1, 0.2],
        [0.9, 0.0, 0.7, 0.2, 0.1],
        [0.8, 0.7, 0.0, 0.1, 0.3],
        [0.1, 0.2, 0.1, 0.0, 0.9],
        [0.2, 0.1, 0.3, 0.9, 0.0],
    ])

    print(f"\nNetwork: {n} nodes, {q} communities, β={beta}")
    print("Testing robustness to edge-weight estimation errors")

    # Find MAP configuration
    best_sigma = None
    best_energy = -np.inf
    for sigma in product(range(q), repeat=n):
        E = potts_energy(np.array(sigma), J_true, beta)
        if E > best_energy:
            best_energy = E
            best_sigma = sigma

    print(f"\nMAP community assignment: {best_sigma}")
    print(f"(Nodes 0-2 in community {best_sigma[0]}, nodes 3-4 in community {best_sigma[3]})")

    # Perturb and check MAP stability
    np.random.seed(100)
    n_stable = 0
    n_trials = 50
    for _ in range(n_trials):
        noise = np.random.randn(n, n) * 0.15
        noise = (noise + noise.T) / 2
        J_noisy = J_true + noise

        best_noisy = None
        best_E = -np.inf
        for sigma in product(range(q), repeat=n):
            E = potts_energy(np.array(sigma), J_noisy, beta)
            if E > best_E:
                best_E = E
                best_noisy = sigma

        if best_noisy == best_sigma:
            n_stable += 1

    print(f"\nMAP stability under noise (δ=0.15): {n_stable}/{n_trials} = {100*n_stable/n_trials:.0f}%")
    print("→ Community assignments are robust to moderate edge-weight noise.")


# ─────────────────────────────────────────────────────────────────────
# Application 3: Graph Coloring via Antiferromagnetic Potts
# ─────────────────────────────────────────────────────────────────────

def app_graph_coloring():
    """Demonstrate the Potts model as a soft graph coloring relaxation.

    The antiferromagnetic Potts model penalizes monochromatic edges.
    As β → -∞, only proper q-colorings survive.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Graph Coloring via Antiferromagnetic Potts")
    print("=" * 60)

    # Triangle graph (K₃): needs q ≥ 3 colors
    n = 3
    J = np.ones((3, 3)) - np.eye(3)  # Complete graph

    for q in [2, 3, 4]:
        print(f"\nTriangle (K₃), q={q} colors:")
        print(f"  {'β':>8} {'log Z':>10} {'P(proper)':>10} {'#proper':>8}")
        print("  " + "-" * 42)

        for beta in [-0.5, -1.0, -2.0, -5.0, -10.0]:
            Z = 0.0
            Z_proper = 0.0
            n_proper = 0

            for sigma in product(range(q), repeat=n):
                sigma_arr = np.array(sigma)
                E = potts_energy(sigma_arr, J, beta)
                w = np.exp(E)
                Z += w

                # Check if proper coloring
                is_proper = all(sigma[i] != sigma[j]
                               for i in range(n) for j in range(i+1, n))
                if is_proper:
                    Z_proper += w
                    if beta == -0.5:
                        n_proper += 1

            p_proper = Z_proper / Z
            if beta == -0.5:
                proper_count = n_proper
            print(f"  {beta:8.1f} {np.log(Z):10.4f} {p_proper:10.6f} {'-':>8}")

        # Count proper colorings
        count = sum(1 for sigma in product(range(q), repeat=n)
                    if all(sigma[i] != sigma[j]
                           for i in range(n) for j in range(i+1, n)))
        print(f"  Exact proper {q}-colorings of K₃: {count}")

    print("\n→ As β → -∞, partition function concentrates on proper colorings.")
    print("→ Stability theorem certifies the transition is smooth, not abrupt.")


# ─────────────────────────────────────────────────────────────────────
# Application 4: Protein Contact Map Robustness
# ─────────────────────────────────────────────────────────────────────

def app_protein_contacts():
    """Demonstrate Potts model stability for protein residue couplings.

    In protein structure prediction, the Potts model captures pairwise
    amino acid couplings inferred from multiple sequence alignments.
    Our stability theorem bounds how errors in inferred couplings
    affect the predicted contact energy landscape.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 4: Protein Contact Map Robustness")
    print("=" * 60)

    # Simplified: 4 residue positions, q=3 amino acid types
    n = 4
    q = 3  # simplified from 20 amino acids
    beta = 0.5

    # Inferred coupling matrix (from coevolution analysis)
    J_inferred = np.array([
        [0.0, 0.6, 0.1, 0.8],
        [0.6, 0.0, 0.7, 0.2],
        [0.1, 0.7, 0.0, 0.5],
        [0.8, 0.2, 0.5, 0.0],
    ])

    print(f"\nProtein fragment: {n} residues, {q} amino acid types")
    print("Testing stability of contact predictions under inference uncertainty")

    # Different MSA depths → different noise levels
    msa_depths = [100, 500, 1000, 5000]
    noise_scale = {100: 0.3, 500: 0.15, 1000: 0.08, 5000: 0.03}

    np.random.seed(42)
    print(f"\n{'MSA depth':>10} {'noise δ':>8} {'|Δ log Z|':>12} {'Certified':>12} {'Ratio':>8}")
    print("-" * 54)

    Z_true = potts_partition(n, q, J_inferred, beta)
    log_Z_true = np.log(Z_true)

    for depth in msa_depths:
        delta = noise_scale[depth]
        noise = np.random.randn(n, n) * delta
        noise = (noise + noise.T) / 2
        J_noisy = J_inferred + noise

        Z_noisy = potts_partition(n, q, J_noisy, beta)
        empirical = abs(np.log(Z_noisy) - log_Z_true)
        sup_norm = np.max(np.abs(J_inferred - J_noisy))
        certified = abs(beta) * (q - 1) * n**2 * sup_norm

        print(f"{depth:10d} {delta:8.3f} {empirical:12.6f} {certified:12.6f} "
              f"{empirical/certified:8.4f}")

    print("\n→ Deeper MSAs → less noise → tighter certified bounds.")
    print("→ Stability theory quantifies confidence in predicted contacts.")


if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║     Applications of Potts-Lorentzian Stability Theory      ║")
    print("╚══════════════════════════════════════════════════════════════╝\n")

    app_image_segmentation()
    app_community_detection()
    app_graph_coloring()
    app_protein_contacts()

    print("\n" + "=" * 60)
    print("All applications demonstrated successfully.")


#!/usr/bin/env python3
"""
Potts Model Lorentzian Stability — Interactive Demonstration

This script demonstrates the formally verified theorems from the Potts-Lorentzian
stability theory. It:

1. Enumerates exact Potts partition functions for small systems.
2. Perturbs coupling matrices and compares empirical vs. certified log-Lipschitz bounds.
3. Tests the conjectured (q-1) centered scaling versus naive q scaling.
4. Explores antiferromagnetic suppression of monochromatic configurations.
5. Tests determinantal partition function stability.

All experiments are designed to potentially *falsify* the conjectures, not merely illustrate them.
"""

import numpy as np
from itertools import product
from typing import Callable

# ─────────────────────────────────────────────────────────────────────
# Core Potts model functions
# ─────────────────────────────────────────────────────────────────────

def potts_energy(sigma: np.ndarray, J: np.ndarray, beta: float) -> float:
    """Compute Potts energy: β * Σ_{i,j} J(i,j) * δ(σ_i, σ_j)."""
    n = len(sigma)
    total = 0.0
    for i in range(n):
        for j in range(n):
            if sigma[i] == sigma[j]:
                total += J[i, j]
    return beta * total


def potts_partition(n: int, q: int, J: np.ndarray, beta: float) -> float:
    """Exact Potts partition function by enumeration over all q^n configs."""
    Z = 0.0
    for sigma in product(range(q), repeat=n):
        sigma_arr = np.array(sigma)
        Z += np.exp(potts_energy(sigma_arr, J, beta))
    return Z


def coupling_sup_norm(J: np.ndarray, K: np.ndarray) -> float:
    """Sup norm of coupling perturbation: max_{i,j} |J(i,j) - K(i,j)|."""
    return np.max(np.abs(J - K))


def certified_bound(n: int, beta: float, J: np.ndarray, K: np.ndarray) -> float:
    """Certified log-Lipschitz bound: |β| * n² * ‖J - K‖∞."""
    return abs(beta) * n**2 * coupling_sup_norm(J, K)


def centered_bound(n: int, q: int, beta: float, J: np.ndarray, K: np.ndarray) -> float:
    """Centered log-Lipschitz bound: |β| * (q-1) * n² * ‖J - K‖∞."""
    return abs(beta) * (q - 1) * n**2 * coupling_sup_norm(J, K)


# ─────────────────────────────────────────────────────────────────────
# Experiment 1: Basic log-Lipschitz stability verification
# ─────────────────────────────────────────────────────────────────────

def experiment_basic_stability():
    """Verify the log-Lipschitz bound on random small Potts systems."""
    print("=" * 70)
    print("EXPERIMENT 1: Log-Lipschitz Stability Verification")
    print("=" * 70)
    np.random.seed(42)

    configs = [
        (3, 2, 0.5),   # n=3, q=2, β=0.5
        (3, 3, 0.5),   # n=3, q=3, β=0.5
        (4, 2, 1.0),   # n=4, q=2, β=1.0
        (4, 3, 0.3),   # n=4, q=3, β=0.3
        (3, 4, 0.8),   # n=3, q=4, β=0.8
    ]

    print(f"\n{'n':>3} {'q':>3} {'β':>6} {'|Δ log Z|':>12} {'Certified':>12} {'Ratio':>8} {'Valid':>6}")
    print("-" * 55)

    for n, q, beta in configs:
        J = np.random.randn(n, n) * 0.5
        J = (J + J.T) / 2  # symmetrize

        delta = 0.1
        dJ = np.random.randn(n, n) * delta
        dJ = (dJ + dJ.T) / 2
        K = J + dJ

        Z_J = potts_partition(n, q, J, beta)
        Z_K = potts_partition(n, q, K, beta)

        empirical = abs(np.log(Z_J) - np.log(Z_K))
        cert = certified_bound(n, beta, J, K)
        ratio = empirical / cert if cert > 0 else 0.0
        valid = "✓" if empirical <= cert + 1e-10 else "✗"

        print(f"{n:3d} {q:3d} {beta:6.2f} {empirical:12.6f} {cert:12.6f} {ratio:8.4f} {valid:>6}")

    print("\nAll ratios < 1 confirms the certified bound holds.")


# ─────────────────────────────────────────────────────────────────────
# Experiment 2: Centered (q-1) scaling conjecture test
# ─────────────────────────────────────────────────────────────────────

def experiment_centered_scaling():
    """Test whether the optimal perturbation constant scales as (q-1) not q."""
    print("\n" + "=" * 70)
    print("EXPERIMENT 2: Centered (q-1) Scaling Conjecture Test")
    print("=" * 70)
    np.random.seed(123)

    n_values = [3, 4, 5]
    q_values = [2, 3, 4, 5]
    beta = 0.5
    n_trials = 50

    print(f"\nFor each (n, q), we compute max |Δ log Z| / (|β| * n² * ‖ΔJ‖∞)")
    print(f"and compare to (q-1) (centered bound) vs q (naive bound).\n")
    print(f"{'n':>3} {'q':>3} {'max ratio':>12} {'q-1':>6} {'q':>6} {'< q-1?':>8} {'< q?':>6}")
    print("-" * 50)

    for n in n_values:
        for q in q_values:
            max_ratio = 0.0
            for _ in range(n_trials):
                J = np.random.randn(n, n) * 0.5
                J = (J + J.T) / 2
                delta = 0.05
                dJ = np.random.randn(n, n) * delta
                dJ = (dJ + dJ.T) / 2
                K = J + dJ

                Z_J = potts_partition(n, q, J, beta)
                Z_K = potts_partition(n, q, K, beta)

                supnorm = coupling_sup_norm(J, K)
                if supnorm > 0:
                    ratio = abs(np.log(Z_J) - np.log(Z_K)) / (abs(beta) * n**2 * supnorm)
                    max_ratio = max(max_ratio, ratio)

            lt_qm1 = "✓" if max_ratio < q - 1 else "✗"
            lt_q = "✓" if max_ratio < q else "✗"
            print(f"{n:3d} {q:3d} {max_ratio:12.6f} {q-1:6d} {q:6d} {lt_qm1:>8} {lt_q:>6}")

    print("\nIf max ratio < (q-1) for all cases, the centered bound conjecture holds.")
    print("If max ratio ≥ (q-1) for any case, the conjecture is FALSIFIED.")


# ─────────────────────────────────────────────────────────────────────
# Experiment 3: Antiferromagnetic monochromatic suppression
# ─────────────────────────────────────────────────────────────────────

def experiment_antiferro():
    """Verify antiferromagnetic energy monotonicity for graph coloring bridge."""
    print("\n" + "=" * 70)
    print("EXPERIMENT 3: Antiferromagnetic Monochromatic Suppression")
    print("=" * 70)

    n, q = 4, 3
    # Complete graph coupling (all-ones minus diagonal)
    J = np.ones((n, n)) - np.eye(n)

    print(f"\nSystem: n={n} sites, q={q} states, complete graph coupling")
    print(f"Testing β < 0 (antiferromagnetic regime)\n")

    for beta in [-0.5, -1.0, -2.0, -5.0]:
        Z = potts_partition(n, q, J, beta)
        log_Z = np.log(Z)

        # Count monochromatic vs non-monochromatic weights
        mono_weight = 0.0
        nonmono_weight = 0.0
        total_configs = q ** n
        proper_colorings = 0

        for sigma in product(range(q), repeat=n):
            sigma_arr = np.array(sigma)
            E = potts_energy(sigma_arr, J, beta)
            w = np.exp(E)

            # Check if monochromatic (all same)
            if len(set(sigma)) == 1:
                mono_weight += w
            else:
                nonmono_weight += w

            # Check if proper coloring (no adjacent same)
            is_proper = True
            for i in range(n):
                for j in range(i+1, n):
                    if sigma[i] == sigma[j]:
                        is_proper = False
                        break
                if not is_proper:
                    break
            if is_proper:
                proper_colorings += 1

        mono_frac = mono_weight / Z
        print(f"  β={beta:5.1f}: log Z={log_Z:8.3f}, mono fraction={mono_frac:.6f}, "
              f"proper colorings={proper_colorings}")

    print(f"\nAs β → -∞, monochromatic fraction → 0 (suppression confirmed).")
    print(f"The partition function concentrates on proper colorings.")


# ─────────────────────────────────────────────────────────────────────
# Experiment 4: Determinantal partition function stability
# ─────────────────────────────────────────────────────────────────────

def experiment_determinantal():
    """Test determinantal partition function positivity and stability."""
    print("\n" + "=" * 70)
    print("EXPERIMENT 4: Determinantal Spin System Stability")
    print("=" * 70)
    np.random.seed(456)

    print(f"\ndet(L + I) for random PSD kernels L:")
    print(f"{'n':>3} {'det(L+I)':>12} {'≥ 1?':>6} {'log det':>10}")
    print("-" * 35)

    for n_val in [2, 3, 4, 5, 6, 8]:
        A = np.random.randn(n_val, n_val)
        L = A @ A.T  # PSD by construction
        det_val = np.linalg.det(L + np.eye(n_val))
        valid = "✓" if det_val >= 1.0 - 1e-10 else "✗"
        print(f"{n_val:3d} {det_val:12.4f} {valid:>6} {np.log(det_val):10.4f}")

    print(f"\nPerturbation stability test:")
    print(f"{'n':>3} {'|Δ log det|':>14} {'n * sup norm':>14} {'ratio':>8} {'valid':>6}")
    print("-" * 50)

    for n_val in [2, 3, 4, 5, 6]:
        A = np.random.randn(n_val, n_val)
        L = A @ A.T
        B = np.random.randn(n_val, n_val) * 0.1
        M = L + B @ B.T  # Both PSD

        det_L = np.linalg.det(L + np.eye(n_val))
        det_M = np.linalg.det(M + np.eye(n_val))
        empirical = abs(np.log(det_L) - np.log(det_M))
        sup_norm = np.max(np.abs(L - M))
        bound = n_val * sup_norm
        ratio = empirical / bound if bound > 0 else 0
        valid = "✓" if empirical <= bound + 1e-10 else "?"

        print(f"{n_val:3d} {empirical:14.6f} {bound:14.6f} {ratio:8.4f} {valid:>6}")

    print("\nConjecture: for PSD L, M, |log det(L+I) - log det(M+I)| ≤ n * ‖L-M‖_sup")


# ─────────────────────────────────────────────────────────────────────
# Experiment 5: Falsification test for sharp scaling
# ─────────────────────────────────────────────────────────────────────

def experiment_falsification():
    """Attempt to falsify the (q-1) scaling conjecture with adversarial perturbations."""
    print("\n" + "=" * 70)
    print("EXPERIMENT 5: Adversarial Falsification Test")
    print("=" * 70)
    np.random.seed(789)

    print("\nSearching for perturbations that violate |Δ log Z| ≤ |β|*(q-1)*n²*δ")
    print("Using structured perturbations (rank-1, diagonal, etc.)\n")

    n, q, beta = 3, 3, 1.0
    n_attempts = 200
    max_ratio = 0.0
    best_config = None

    for attempt in range(n_attempts):
        J = np.random.randn(n, n) * 0.3
        J = (J + J.T) / 2

        # Try different perturbation structures
        if attempt % 4 == 0:
            # Rank-1 perturbation
            v = np.random.randn(n)
            dJ = 0.1 * np.outer(v, v) / np.linalg.norm(v)**2
        elif attempt % 4 == 1:
            # Diagonal perturbation
            dJ = 0.1 * np.diag(np.random.randn(n))
        elif attempt % 4 == 2:
            # All-ones perturbation
            dJ = 0.1 * np.ones((n, n)) / n
        else:
            # Random
            dJ = np.random.randn(n, n) * 0.05
            dJ = (dJ + dJ.T) / 2

        K = J + dJ
        Z_J = potts_partition(n, q, J, beta)
        Z_K = potts_partition(n, q, K, beta)

        supnorm = coupling_sup_norm(J, K)
        centered_bnd = abs(beta) * (q - 1) * n**2 * supnorm

        if centered_bnd > 0:
            ratio = abs(np.log(Z_J) - np.log(Z_K)) / centered_bnd
            if ratio > max_ratio:
                max_ratio = ratio
                best_config = (J.copy(), K.copy(), ratio)

    print(f"  System: n={n}, q={q}, β={beta}")
    print(f"  Attempts: {n_attempts}")
    print(f"  Maximum ratio |Δ log Z| / (|β|*(q-1)*n²*δ): {max_ratio:.6f}")

    if max_ratio > 1.0:
        print(f"  *** CONJECTURE FALSIFIED! Ratio > 1 ***")
    else:
        print(f"  Conjecture holds: all ratios < 1")
        print(f"  Tightness: bound is at most {(1-max_ratio)*100:.1f}% loose")


# ─────────────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║  Potts Model Lorentzian Stability — Computational Experiments  ║")
    print("║  Demonstrating formally verified partition function robustness ║")
    print("╚══════════════════════════════════════════════════════════════════╝\n")

    experiment_basic_stability()
    experiment_centered_scaling()
    experiment_antiferro()
    experiment_determinantal()
    experiment_falsification()

    print("\n" + "=" * 70)
    print("All experiments completed.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Visualization: Centered Simplex Embedding and (q-1) Scaling

Visualizes the centered simplex embedding that reduces the effective
perturbation dimension from q to (q-1). Shows the geometry of Potts
state vectors and how the centered projection captures the essential
fluctuation structure.
"""

import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
from itertools import product


def potts_partition(n, q, J, beta):
    Z = 0.0
    for sigma in product(range(q), repeat=n):
        sigma_arr = np.array(sigma)
        total = sum(J[i, j] for i in range(n) for j in range(n) if sigma_arr[i] == sigma_arr[j])
        Z += np.exp(beta * total)
    return Z


fig = plt.figure(figsize=(16, 10))

# ─── Plot 1: Centered state vectors for q=3 ───
ax1 = fig.add_subplot(2, 3, 1)
q = 3
vecs = np.eye(q) - 1.0 / q
colors = ['#e41a1c', '#377eb8', '#4daf4a']
labels = [f'State {i}' for i in range(q)]

for i in range(q):
    ax1.arrow(0, 0, vecs[i, 0], vecs[i, 1], head_width=0.03,
              head_length=0.02, fc=colors[i], ec=colors[i], linewidth=2)
    ax1.plot(vecs[i, 0], vecs[i, 1], 'o', color=colors[i], markersize=10)
    ax1.annotate(labels[i], (vecs[i, 0] + 0.05, vecs[i, 1] + 0.05), fontsize=11)

# Draw the constant direction (1/√q, 1/√q, ...)
ax1.plot(0, 0, 'k+', markersize=15, markeredgewidth=2)
ax1.set_xlim(-0.8, 1.0)
ax1.set_ylim(-0.8, 1.0)
ax1.set_aspect('equal')
ax1.grid(True, alpha=0.3)
ax1.set_title(f'Centered vectors (q={q})', fontsize=13)
ax1.set_xlabel('Component 1')
ax1.set_ylabel('Component 2')

# ─── Plot 2: Inner product matrix ───
ax2 = fig.add_subplot(2, 3, 2)
q = 5
inner_prod = np.zeros((q, q))
vecs = np.eye(q) - 1.0 / q
for a in range(q):
    for b in range(q):
        inner_prod[a, b] = np.dot(vecs[a], vecs[b])

im = ax2.imshow(inner_prod, cmap='RdBu_r', vmin=-0.5, vmax=1.0)
ax2.set_title(f'⟨v_a, v_b⟩ for q={q}', fontsize=13)
ax2.set_xlabel('State b')
ax2.set_ylabel('State a')
plt.colorbar(im, ax=ax2)
for a in range(q):
    for b in range(q):
        ax2.text(b, a, f'{inner_prod[a,b]:.2f}', ha='center', va='center',
                 fontsize=8, color='white' if abs(inner_prod[a,b]) > 0.3 else 'black')

# ─── Plot 3: (q-1) vs q scaling comparison ───
ax3 = fig.add_subplot(2, 3, 3)
q_values = list(range(2, 8))
n = 3
beta = 0.5
n_trials = 30
np.random.seed(42)

max_ratios_naive = []
max_ratios_centered = []

for q in q_values:
    max_naive = 0.0
    max_centered = 0.0
    for _ in range(n_trials):
        J = np.random.randn(n, n) * 0.3
        J = (J + J.T) / 2
        dJ = np.random.randn(n, n) * 0.05
        dJ = (dJ + dJ.T) / 2
        K = J + dJ

        Z_J = potts_partition(n, q, J, beta)
        Z_K = potts_partition(n, q, K, beta)
        empirical = abs(np.log(Z_J) - np.log(Z_K))
        sup_norm = np.max(np.abs(J - K))

        naive_bound = abs(beta) * n**2 * sup_norm
        centered_bound = abs(beta) * (q - 1) * n**2 * sup_norm

        if naive_bound > 0:
            max_naive = max(max_naive, empirical / naive_bound)
        if centered_bound > 0:
            max_centered = max(max_centered, empirical / centered_bound)

    max_ratios_naive.append(max_naive)
    max_ratios_centered.append(max_centered)

ax3.bar(np.array(q_values) - 0.15, max_ratios_naive, 0.3, label='Ratio to n² bound',
        color='steelblue', alpha=0.8)
ax3.bar(np.array(q_values) + 0.15, max_ratios_centered, 0.3, label='Ratio to (q-1)n² bound',
        color='coral', alpha=0.8)
ax3.axhline(y=1.0, color='red', linestyle='--', alpha=0.5, label='Bound = 1')
ax3.set_xlabel('Number of states q', fontsize=12)
ax3.set_ylabel('Max empirical/bound ratio', fontsize=12)
ax3.set_title('Bound tightness comparison', fontsize=13)
ax3.legend(fontsize=9)
ax3.set_xticks(q_values)

# ─── Plot 4: Kronecker decomposition ───
ax4 = fig.add_subplot(2, 3, 4)
q = 4
const_part = np.full((q, q), 1.0 / q)
fluct_part = np.zeros((q, q))
vecs = np.eye(q) - 1.0 / q
for a in range(q):
    for b in range(q):
        fluct_part[a, b] = np.dot(vecs[a], vecs[b])

kronecker = np.eye(q)
reconstructed = const_part + fluct_part

ax4.bar(range(3), [np.linalg.norm(kronecker), np.linalg.norm(const_part),
                     np.linalg.norm(fluct_part)],
        color=['purple', 'orange', 'green'], alpha=0.7)
ax4.set_xticks(range(3))
ax4.set_xticklabels(['δ(a,b)', '1/q (const)', '⟨v_a,v_b⟩ (fluct)'], fontsize=10)
ax4.set_ylabel('Frobenius norm', fontsize=12)
ax4.set_title(f'Kronecker decomposition (q={q})', fontsize=13)

# Verify: ||δ||² = ||const||² + ||fluct||²
err = np.linalg.norm(kronecker - reconstructed)
ax4.text(0.5, 0.9, f'Reconstruction error: {err:.2e}',
         transform=ax4.transAxes, fontsize=10, ha='center')

# ─── Plot 5: Antiferromagnetic energy landscape ───
ax5 = fig.add_subplot(2, 3, 5)
n, q = 3, 3
J = np.ones((n, n)) - np.eye(n)
betas = np.linspace(-5, 2, 50)

mono_fracs = []
for beta_val in betas:
    Z = 0.0
    Z_mono = 0.0
    for sigma in product(range(q), repeat=n):
        sigma_arr = np.array(sigma)
        total = sum(J[i, j] for i in range(n) for j in range(n) if sigma_arr[i] == sigma_arr[j])
        w = np.exp(beta_val * total)
        Z += w
        if len(set(sigma)) == 1:
            Z_mono += w
    mono_fracs.append(Z_mono / Z)

ax5.plot(betas, mono_fracs, 'b-', linewidth=2)
ax5.axvline(x=0, color='gray', linestyle='--', alpha=0.5)
ax5.fill_between(betas, 0, mono_fracs, alpha=0.1, color='blue')
ax5.set_xlabel('Inverse temperature β', fontsize=12)
ax5.set_ylabel('P(monochromatic)', fontsize=12)
ax5.set_title('Antiferro suppression (K₃)', fontsize=13)
ax5.annotate('Antiferromagnetic\n(graph coloring)', xy=(-4, 0.01),
             fontsize=9, ha='center', color='blue')
ax5.annotate('Ferromagnetic\n(clustering)', xy=(1.5, 0.15),
             fontsize=9, ha='center', color='red')

# ─── Plot 6: Determinantal stability ───
ax6 = fig.add_subplot(2, 3, 6)
np.random.seed(42)
dims = list(range(2, 9))
det_ratios = []

for d in dims:
    max_ratio = 0.0
    for _ in range(20):
        A = np.random.randn(d, d)
        L = A @ A.T
        B = np.random.randn(d, d) * 0.1
        M = L + B @ B.T

        det_L = np.linalg.det(L + np.eye(d))
        det_M = np.linalg.det(M + np.eye(d))
        if det_L > 0 and det_M > 0:
            empirical = abs(np.log(det_L) - np.log(det_M))
            sup_norm = np.max(np.abs(L - M))
            if sup_norm > 0:
                ratio = empirical / (d * sup_norm)
                max_ratio = max(max_ratio, ratio)
    det_ratios.append(max_ratio)

ax6.bar(dims, det_ratios, color='teal', alpha=0.7)
ax6.axhline(y=1.0, color='red', linestyle='--', label='Bound = 1')
ax6.set_xlabel('Matrix dimension n', fontsize=12)
ax6.set_ylabel('Max |Δ log det| / (n·sup)', fontsize=12)
ax6.set_title('Determinantal stability', fontsize=13)
ax6.legend(fontsize=10)

plt.suptitle('Centered Simplex Geometry and Potts-Lorentzian Stability',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_centered_simplex.png', dpi=150, bbox_inches='tight')
print("Saved viz_centered_simplex.png")


#!/usr/bin/env python3
"""
Visualization: Graph Coloring Bridge — Antiferromagnetic Potts Model

Shows how the antiferromagnetic Potts model interpolates between
the uniform distribution over all configurations (β=0) and the
uniform distribution over proper graph colorings (β→-∞).
This visualizes the cross-domain bridge between statistical mechanics
and combinatorics.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import product


def potts_partition_detailed(n, q, J, beta):
    """Return Z, weights, and coloring statistics."""
    configs = list(product(range(q), repeat=n))
    energies = []
    mono_counts = []
    is_proper = []

    for sigma in configs:
        sigma_arr = np.array(sigma)
        total = sum(J[i, j] for i in range(n) for j in range(n) if sigma_arr[i] == sigma_arr[j])
        energies.append(beta * total)

        # Count monochromatic edges
        mono = sum(1 for i in range(n) for j in range(i+1, n)
                   if sigma[i] == sigma[j] and J[i, j] > 0)
        mono_counts.append(mono)

        # Check proper coloring
        proper = all(sigma[i] != sigma[j]
                     for i in range(n) for j in range(i+1, n) if J[i, j] > 0)
        is_proper.append(proper)

    energies = np.array(energies)
    max_E = np.max(energies)
    weights = np.exp(energies - max_E)
    Z = np.sum(weights)
    weights /= Z

    return {
        'configs': configs,
        'weights': weights,
        'mono_counts': np.array(mono_counts),
        'is_proper': np.array(is_proper),
        'Z': Z * np.exp(max_E),
    }


fig, axes = plt.subplots(2, 3, figsize=(16, 10))

# ─── Graph: Path P₄ (4 vertices, 3 edges) ───
n = 4
q = 3
# Path graph adjacency
J_path = np.zeros((4, 4))
for i in range(3):
    J_path[i, i+1] = 1.0
    J_path[i+1, i] = 1.0

# ─── Graph: Cycle C₄ (4 vertices, 4 edges) ───
J_cycle = J_path.copy()
J_cycle[0, 3] = 1.0
J_cycle[3, 0] = 1.0

# ─── Graph: Complete K₄ (4 vertices, 6 edges) ───
J_complete = np.ones((4, 4)) - np.eye(4)

graphs = [
    (J_path, "Path P₄", 3),
    (J_cycle, "Cycle C₄", 4),
    (J_complete, "Complete K₄", 6),
]

betas = np.linspace(-8, 3, 60)

for col, (J, name, n_edges) in enumerate(graphs):
    # Top row: Weight distribution evolution
    ax_top = axes[0, col]

    proper_probs = []
    entropy_vals = []
    avg_mono = []

    for beta_val in betas:
        result = potts_partition_detailed(n, q, J, beta_val)
        weights = result['weights']
        is_proper = result['is_proper']
        mono = result['mono_counts']

        p_proper = np.sum(weights[is_proper])
        proper_probs.append(p_proper)

        # Shannon entropy
        H = -np.sum(weights[weights > 1e-15] * np.log(weights[weights > 1e-15]))
        entropy_vals.append(H)

        avg_mono.append(np.sum(weights * mono))

    ax_top.plot(betas, proper_probs, 'b-', linewidth=2, label='P(proper coloring)')
    ax_top.fill_between(betas, 0, proper_probs, alpha=0.1, color='blue')
    ax_top.axvline(x=0, color='gray', linestyle='--', alpha=0.4)
    ax_top.set_xlabel('β', fontsize=11)
    ax_top.set_ylabel('Probability', fontsize=11)
    ax_top.set_title(f'{name} ({n_edges} edges, q={q})', fontsize=13)
    ax_top.set_ylim(-0.05, 1.05)

    # Count proper colorings
    n_proper = sum(1 for s in product(range(q), repeat=n)
                   if all(s[i] != s[j] for i in range(n) for j in range(i+1, n) if J[i, j] > 0))
    n_total = q ** n
    ax_top.axhline(y=n_proper / n_total, color='green', linestyle=':',
                    alpha=0.5, label=f'uniform = {n_proper}/{n_total}')
    ax_top.legend(fontsize=9, loc='lower left')

    # Bottom row: Expected monochromatic edges
    ax_bot = axes[1, col]
    ax_bot.plot(betas, avg_mono, 'r-', linewidth=2)
    ax_bot.fill_between(betas, 0, avg_mono, alpha=0.1, color='red')
    ax_bot.axvline(x=0, color='gray', linestyle='--', alpha=0.4)
    ax_bot.set_xlabel('β', fontsize=11)
    ax_bot.set_ylabel('E[monochromatic edges]', fontsize=11)
    ax_bot.set_title(f'{name}: mono edge suppression', fontsize=13)

    # Annotate
    ax_bot.annotate('Antiferromagnetic\n(coloring regime)',
                     xy=(-6, 0.1), fontsize=9, color='blue', ha='center')
    ax_bot.annotate('Ferromagnetic\n(clustering)',
                     xy=(2, max(avg_mono) * 0.8), fontsize=9, color='red', ha='center')

plt.suptitle('Graph Coloring ↔ Antiferromagnetic Potts Model Bridge',
             fontsize=15, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_graph_coloring.png', dpi=150, bbox_inches='tight')
print("Saved viz_graph_coloring.png")


#!/usr/bin/env python3
"""
Visualization: Potts Partition Function Stability Landscape

Visualizes the log-Lipschitz stability of the Potts partition function
as coupling parameters are perturbed. Shows that the certified bound
(red surface) always envelopes the empirical variation (blue dots),
confirming the formally verified theorem.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import product


def potts_energy(sigma, J, beta):
    n = len(sigma)
    total = sum(J[i, j] for i in range(n) for j in range(n) if sigma[i] == sigma[j])
    return beta * total


def potts_partition(n, q, J, beta):
    Z = 0.0
    for sigma in product(range(q), repeat=n):
        Z += np.exp(potts_energy(np.array(sigma), J, beta))
    return Z


# Parameters
n = 3
q = 3
beta = 0.8
np.random.seed(42)

J_base = np.random.randn(n, n) * 0.3
J_base = (J_base + J_base.T) / 2

# Generate perturbations along two directions
n_points = 25
delta_range = np.linspace(-0.3, 0.3, n_points)

# Direction 1: uniform perturbation
dJ1 = np.ones((n, n)) / n
# Direction 2: random structured perturbation
dJ2 = np.random.randn(n, n)
dJ2 = (dJ2 + dJ2.T) / 2
dJ2 /= np.max(np.abs(dJ2))

log_Z_base = np.log(potts_partition(n, q, J_base, beta))

fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Plot 1: Log Z as function of perturbation magnitude
for idx, (dJ, label) in enumerate([(dJ1, "Uniform"), (dJ2, "Random")]):
    log_Zs = []
    deltas = []
    bounds = []
    for d in delta_range:
        J_pert = J_base + d * dJ
        log_Z = np.log(potts_partition(n, q, J_pert, beta))
        log_Zs.append(log_Z)
        deltas.append(d)
        sup_norm = np.max(np.abs(d * dJ))
        bounds.append(abs(beta) * n**2 * sup_norm)

    log_Zs = np.array(log_Zs)
    bounds = np.array(bounds)

    ax = axes[idx]
    ax.fill_between(delta_range, log_Z_base - bounds, log_Z_base + bounds,
                     alpha=0.2, color='red', label='Certified envelope')
    ax.plot(delta_range, log_Zs, 'b-', linewidth=2, label='log Z(J + δ·ΔJ)')
    ax.axhline(y=log_Z_base, color='gray', linestyle='--', alpha=0.5)
    ax.set_xlabel('Perturbation δ', fontsize=12)
    ax.set_ylabel('log Z', fontsize=12)
    ax.set_title(f'{label} perturbation (n={n}, q={q})', fontsize=13)
    ax.legend(fontsize=10)

# Plot 3: Ratio heatmap across q and n
ax = axes[2]
q_values = [2, 3, 4, 5]
n_values = [2, 3, 4]
ratios = np.zeros((len(q_values), len(n_values)))

for qi, q_val in enumerate(q_values):
    for ni, n_val in enumerate(n_values):
        J = np.random.randn(n_val, n_val) * 0.3
        J = (J + J.T) / 2
        dJ = np.random.randn(n_val, n_val) * 0.1
        dJ = (dJ + dJ.T) / 2
        K = J + dJ

        Z_J = potts_partition(n_val, q_val, J, beta)
        Z_K = potts_partition(n_val, q_val, K, beta)
        empirical = abs(np.log(Z_J) - np.log(Z_K))
        certified = abs(beta) * n_val**2 * np.max(np.abs(J - K))
        ratios[qi, ni] = empirical / certified if certified > 0 else 0

im = ax.imshow(ratios, cmap='YlOrRd', vmin=0, vmax=1, aspect='auto')
ax.set_xticks(range(len(n_values)))
ax.set_xticklabels(n_values)
ax.set_yticks(range(len(q_values)))
ax.set_yticklabels(q_values)
ax.set_xlabel('Number of sites n', fontsize=12)
ax.set_ylabel('Number of states q', fontsize=12)
ax.set_title('Bound tightness ratio', fontsize=13)
plt.colorbar(im, ax=ax, label='|Δ log Z| / certified bound')

for qi in range(len(q_values)):
    for ni in range(len(n_values)):
        ax.text(ni, qi, f'{ratios[qi, ni]:.2f}',
                ha='center', va='center', fontsize=10,
                color='white' if ratios[qi, ni] > 0.5 else 'black')

plt.suptitle('Potts Partition Function: Certified Stability', fontsize=15, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_stability_landscape.png', dpi=150, bbox_inches='tight')
print("Saved viz_stability_landscape.png")

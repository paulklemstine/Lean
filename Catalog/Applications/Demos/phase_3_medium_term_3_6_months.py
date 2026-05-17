"""
Applications of Finite Rate-Distortion Theory and Voice-Leading Geometry

Demonstrates real-world applications:
1. Harmonic reduction / chord simplification
2. Musical style fingerprinting via R(D) curves
3. Optimal arrangement for limited instruments
"""

import numpy as np
from itertools import permutations
from typing import List, Tuple, Dict


def min_voice_leading_dist(a: List[int], b: List[int]) -> float:
    """Minimum L1 voice-leading distance."""
    n = len(a)
    return min(sum(abs(b[p[i]] - a[i]) for i in range(n))
               for p in permutations(range(n)))


def mutual_information(p_xy: np.ndarray) -> float:
    """Mutual information from joint distribution."""
    p_x = p_xy.sum(axis=1)
    p_y = p_xy.sum(axis=0)
    mi = 0.0
    for i in range(p_xy.shape[0]):
        for j in range(p_xy.shape[1]):
            if p_xy[i, j] > 1e-15:
                mi += p_xy[i, j] * np.log2(
                    p_xy[i, j] / (p_x[i] * p_y[j] + 1e-300))
    return mi


def blahut_arimoto(p_x, d, lam, max_iter=1000, tol=1e-10):
    """Blahut-Arimoto for rate-distortion."""
    n_x, n_y = d.shape
    q_y = np.ones(n_y) / n_y
    for _ in range(max_iter):
        log_k = np.log(q_y[None, :] + 1e-300) - lam * d
        log_k -= log_k.max(axis=1, keepdims=True)
        kernel = np.exp(log_k)
        kernel /= kernel.sum(axis=1, keepdims=True)
        q_y_new = (p_x[:, None] * kernel).sum(axis=0)
        if np.max(np.abs(q_y_new - q_y)) < tol:
            break
        q_y = q_y_new
    p_xy = p_x[:, None] * kernel
    rate = mutual_information(p_xy)
    dist = np.sum(p_x[:, None] * kernel * d)
    return kernel, rate, dist


# ============================================================
# Application 1: Harmonic Reduction
# ============================================================

def harmonic_reduction():
    """
    Harmonic reduction: simplify a complex chord progression
    to a smaller palette while minimizing voice-leading distortion.

    This is exactly the rate-distortion problem: find the optimal
    mapping from a rich repertoire to a compressed representation.
    """
    print("=" * 60)
    print("APPLICATION 1: Harmonic Reduction")
    print("=" * 60)

    # A progression from a Bach chorale (simplified)
    progression = [
        ([60, 64, 67, 72], "C"),      # C major
        ([60, 65, 69, 72], "F/C"),     # F major, 2nd inv
        ([59, 62, 67, 71], "G7"),      # G7
        ([60, 64, 67, 72], "C"),       # C major
        ([57, 60, 64, 69], "Am"),      # A minor
        ([59, 62, 65, 71], "G7/B"),    # G7, 1st inv
        ([60, 64, 67, 72], "C"),       # C major
    ]

    chords = [p[0] for p in progression]
    names = [p[1] for p in progression]

    # Prototype palette: just I, IV, V
    prototypes = [
        ([60, 64, 67, 72], "C"),
        ([60, 65, 69, 72], "F"),
        ([59, 62, 67, 71], "G7"),
    ]

    proto_chords = [p[0] for p in prototypes]
    proto_names = [p[1] for p in prototypes]

    # Compute distortion matrix
    d = np.zeros((len(chords), len(proto_chords)))
    for i, c in enumerate(chords):
        for j, p in enumerate(proto_chords):
            d[i, j] = min_voice_leading_dist(c, p)

    # Source distribution (uniform over progression)
    p_x = np.ones(len(chords)) / len(chords)

    # Find optimal assignments at different rates
    print("\n  Original progression:", " → ".join(names))
    print()

    for target_bits in [0.3, 0.8, 1.2]:
        # Binary search for lambda
        lo, hi = 0.01, 50.0
        for _ in range(40):
            mid = (lo + hi) / 2
            _, rate, _ = blahut_arimoto(p_x, d, mid)
            if rate > target_bits:
                lo = mid
            else:
                hi = mid
        kernel, rate, dist = blahut_arimoto(p_x, d, (lo + hi) / 2)

        # Hard assignment: each chord maps to most likely prototype
        assignments = kernel.argmax(axis=1)
        reduced = [proto_names[a] for a in assignments]

        print(f"  At rate ≈ {rate:.2f} bits (distortion ≈ {dist:.1f} semitones):")
        print(f"    Reduced: {' → '.join(reduced)}")
    print()


# ============================================================
# Application 2: Style Fingerprinting
# ============================================================

def style_fingerprinting():
    """
    Musical style fingerprinting via R(D) curves.

    Different musical styles use different chord vocabularies and
    transition patterns. The shape of the R(D) curve captures
    the "compressibility" of a style's harmonic language.
    """
    print("=" * 60)
    print("APPLICATION 2: Style Fingerprinting via R(D)")
    print("=" * 60)

    # Three "styles" with different chord distributions
    styles = {
        'Classical': {
            'chords': [[60,64,67], [65,69,72], [67,71,74], [69,72,76]],
            'dist': np.array([0.4, 0.25, 0.25, 0.1])
        },
        'Jazz': {
            'chords': [[60,64,67,70], [62,65,69,72], [64,67,71,74],
                       [65,69,72,76], [67,71,74,77], [69,72,76,79]],
            'dist': np.array([0.2, 0.15, 0.15, 0.2, 0.15, 0.15])
        },
        'Minimal': {
            'chords': [[60,64,67], [62,66,69]],
            'dist': np.array([0.7, 0.3])
        }
    }

    # Shared prototype space
    prototypes = [[60,64,67], [65,69,72], [67,71,74]]

    for style_name, style in styles.items():
        chords = style['chords']
        p_x = style['dist']
        n_voices = len(chords[0])

        # Distortion matrix
        d_mat = np.zeros((len(chords), len(prototypes)))
        for i, c in enumerate(chords):
            for j, p in enumerate(prototypes):
                if len(c) == len(p):
                    d_mat[i, j] = min_voice_leading_dist(c, p)
                else:
                    # For different-sized chords, use first n_proto voices
                    n = min(len(c), len(p))
                    d_mat[i, j] = min_voice_leading_dist(c[:n], p[:n])

        # Compute R(D) at a few points
        lambdas = [0.1, 0.5, 1.0, 2.0, 5.0, 10.0]
        rates, dists = [], []
        for lam in lambdas:
            _, rate, dist = blahut_arimoto(p_x, d_mat, lam)
            rates.append(rate)
            dists.append(dist)

        entropy = -np.sum(p_x * np.log2(p_x + 1e-300))
        print(f"\n  {style_name}:")
        print(f"    Vocabulary size: {len(chords)} chords")
        print(f"    Entropy: {entropy:.3f} bits")
        print(f"    R(D) samples: ", end='')
        for d_val, r_val in zip(dists[:4], rates[:4]):
            print(f"R({d_val:.1f})={r_val:.3f}  ", end='')
        print()
    print()


# ============================================================
# Application 3: Optimal Arrangement
# ============================================================

def optimal_arrangement():
    """
    Optimal arrangement: given a rich orchestral score, find the
    best reduction for a smaller ensemble (e.g., piano) that
    minimizes voice-leading distortion.
    """
    print("=" * 60)
    print("APPLICATION 3: Optimal Arrangement for Limited Ensemble")
    print("=" * 60)

    # "Orchestral" chords (4 voices, rich voicings)
    orchestral = [
        [48, 60, 64, 72],  # C major, wide spread
        [48, 60, 63, 72],  # C minor, wide spread
        [53, 65, 69, 77],  # F major, wide spread
        [55, 67, 71, 79],  # G major, wide spread
    ]

    # "Piano" prototypes (4 voices, compact voicings)
    piano = [
        [60, 64, 67, 72],  # C major, compact
        [60, 63, 67, 72],  # C minor, compact
        [65, 69, 72, 77],  # F major, compact
        [67, 71, 74, 79],  # G major, compact
    ]

    print("\n  Orchestral → Piano voice-leading distances:")
    orch_names = ['C(wide)', 'Cm(wide)', 'F(wide)', 'G(wide)']
    piano_names = ['C(comp)', 'Cm(comp)', 'F(comp)', 'G(comp)']

    d = np.zeros((4, 4))
    for i in range(4):
        for j in range(4):
            d[i, j] = min_voice_leading_dist(orchestral[i], piano[j])

    print(f"  {'':12s}", end='')
    for name in piano_names:
        print(f"{name:>10s}", end='')
    print()
    for i, name in enumerate(orch_names):
        print(f"  {name:12s}", end='')
        for j in range(4):
            print(f"{d[i,j]:10.0f}", end='')
        print()

    # Optimal assignment (greedy for this small example)
    p_x = np.array([0.3, 0.2, 0.25, 0.25])
    kernel, rate, dist = blahut_arimoto(p_x, d, 1.0)

    assignments = kernel.argmax(axis=1)
    print(f"\n  Optimal arrangement mapping (rate={rate:.3f} bits, dist={dist:.1f}):")
    for i in range(4):
        print(f"    {orch_names[i]} → {piano_names[assignments[i]]}")
    print()


if __name__ == '__main__':
    print("\n" + "=" * 60)
    print("  APPLICATIONS OF RATE-DISTORTION VOICE-LEADING THEORY")
    print("=" * 60 + "\n")

    harmonic_reduction()
    style_fingerprinting()
    optimal_arrangement()

    print("=" * 60)
    print("All applications completed successfully.")
    print("=" * 60)


"""
Finite Rate-Distortion Theory and Voice-Leading Geometry: Demonstrations

This module demonstrates the key mathematical structures formalized in the
Bridges project:
1. Finite rate-distortion computation for binary sources
2. Voice-leading cost computation and triangle inequality verification
3. Tropical/piecewise-linear envelope visualization
4. Bridge: voice-leading as a distortion measure
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from itertools import permutations
from typing import List, Tuple, Dict
import json
import base64
import io


# ============================================================
# 1. FINITE RATE-DISTORTION COMPUTATION
# ============================================================

def binary_entropy(p: float) -> float:
    """Binary entropy function H(p) = -p*log2(p) - (1-p)*log2(1-p)."""
    if p <= 0 or p >= 1:
        return 0.0
    return -p * np.log2(p) - (1 - p) * np.log2(1 - p)


def mutual_information(p_xy: np.ndarray) -> float:
    """Compute mutual information I(X;Y) from joint distribution p_xy."""
    p_x = p_xy.sum(axis=1)
    p_y = p_xy.sum(axis=0)
    mi = 0.0
    for i in range(p_xy.shape[0]):
        for j in range(p_xy.shape[1]):
            if p_xy[i, j] > 1e-15 and p_x[i] > 1e-15 and p_y[j] > 1e-15:
                mi += p_xy[i, j] * np.log2(p_xy[i, j] / (p_x[i] * p_y[j]))
    return mi


def expected_distortion(p_x: np.ndarray, kernel: np.ndarray,
                         d: np.ndarray) -> float:
    """Compute expected distortion E[d(X,Y)] = sum p(x)*K(y|x)*d(x,y)."""
    return np.sum(p_x[:, None] * kernel * d)


def blahut_arimoto(p_x: np.ndarray, d: np.ndarray, lam: float,
                    max_iter: int = 1000, tol: float = 1e-10) -> Tuple[np.ndarray, float]:
    """
    Blahut-Arimoto algorithm for computing rate-distortion.

    For a given Lagrange multiplier lambda, finds the optimal
    test channel minimizing I(X;Y) + lambda * E[d(X,Y)].

    Parameters
    ----------
    p_x : source distribution
    d : distortion matrix (|X| x |Y|)
    lam : Lagrange multiplier (lambda >= 0)
    max_iter : maximum iterations
    tol : convergence tolerance

    Returns
    -------
    kernel : optimal test channel K(y|x)
    rate : achieved mutual information I(X;Y)
    """
    n_x, n_y = d.shape
    # Initialize output distribution uniformly
    q_y = np.ones(n_y) / n_y

    for iteration in range(max_iter):
        # Compute kernel: K(y|x) proportional to q(y) * exp(-lambda * d(x,y))
        log_kernel = np.log(q_y[None, :] + 1e-300) - lam * d
        log_kernel -= log_kernel.max(axis=1, keepdims=True)  # numerical stability
        kernel = np.exp(log_kernel)
        kernel /= kernel.sum(axis=1, keepdims=True)

        # Update output distribution
        q_y_new = (p_x[:, None] * kernel).sum(axis=0)

        # Check convergence
        if np.max(np.abs(q_y_new - q_y)) < tol:
            break
        q_y = q_y_new

    # Compute joint distribution and mutual information
    p_xy = p_x[:, None] * kernel
    rate = mutual_information(p_xy)
    return kernel, rate


def compute_rd_curve(p_x: np.ndarray, d: np.ndarray,
                      n_points: int = 200) -> Tuple[np.ndarray, np.ndarray]:
    """
    Compute the rate-distortion curve R(D) using the Blahut-Arimoto algorithm.

    Sweeps through Lagrange multipliers to trace out the R(D) curve.

    Returns arrays of (distortion, rate) pairs.
    """
    lambdas = np.logspace(-3, 3, n_points)
    distortions = []
    rates = []

    for lam in lambdas:
        kernel, rate = blahut_arimoto(p_x, d, lam)
        dist = expected_distortion(p_x, kernel, d)
        distortions.append(dist)
        rates.append(rate)

    # Add endpoints
    # D_max: trivial coding (use best single symbol)
    d_max = min(p_x @ d[:, j] for j in range(d.shape[1]))
    distortions.append(d_max)
    rates.append(0.0)

    D = np.array(distortions)
    R = np.array(rates)

    # Sort by distortion
    idx = np.argsort(D)
    return D[idx], R[idx]


# ============================================================
# 2. VOICE-LEADING COST COMPUTATION
# ============================================================

def voice_leading_cost(chord_a: List[int], chord_b: List[int],
                        perm: Tuple[int, ...]) -> float:
    """
    Compute the L1 voice-leading cost for a given permutation.

    cost = sum_i |chord_b[perm[i]] - chord_a[i]|
    """
    return sum(abs(chord_b[perm[i]] - chord_a[i]) for i in range(len(chord_a)))


def min_voice_leading_dist(chord_a: List[int], chord_b: List[int]) -> float:
    """
    Compute the minimum voice-leading distance between two chords.

    Minimizes over all permutations of voice assignments.
    """
    n = len(chord_a)
    assert len(chord_b) == n
    min_cost = float('inf')
    for perm in permutations(range(n)):
        cost = voice_leading_cost(chord_a, chord_b, perm)
        min_cost = min(min_cost, cost)
    return min_cost


def verify_triangle_inequality(chords: List[List[int]]) -> bool:
    """
    Verify the triangle inequality d(A,C) <= d(A,B) + d(B,C)
    for all triples of chords.
    """
    n = len(chords)
    for i in range(n):
        for j in range(n):
            for k in range(n):
                d_ac = min_voice_leading_dist(chords[i], chords[k])
                d_ab = min_voice_leading_dist(chords[i], chords[j])
                d_bc = min_voice_leading_dist(chords[j], chords[k])
                if d_ac > d_ab + d_bc + 1e-10:
                    return False
    return True


# ============================================================
# 3. DEMONSTRATIONS
# ============================================================

def demo_binary_source():
    """
    Demo 1: Binary symmetric source with Hamming distortion.

    The classical binary rate-distortion function:
    R(D) = H(p) - H(D)  for 0 <= D <= min(p, 1-p)
    R(D) = 0             for D >= min(p, 1-p)
    """
    print("=" * 60)
    print("DEMO 1: Binary Symmetric Source (Hamming Distortion)")
    print("=" * 60)

    p = 0.3  # Source probability P(X=1) = p
    p_x = np.array([1 - p, p])
    d = np.array([[0, 1], [1, 0]])  # Hamming distortion

    D_vals, R_vals = compute_rd_curve(p_x, d)

    # Analytical solution
    D_min = min(p, 1 - p)
    D_analytical = np.linspace(0, D_min, 100)
    R_analytical = np.array([binary_entropy(p) - binary_entropy(d_val)
                              for d_val in D_analytical])
    R_analytical = np.maximum(R_analytical, 0)

    # Plot
    fig, ax = plt.subplots(1, 1, figsize=(8, 6))
    ax.plot(D_vals, R_vals, 'b.', markersize=3, label='Blahut-Arimoto', alpha=0.5)
    ax.plot(D_analytical, R_analytical, 'r-', linewidth=2, label=f'Analytical: R(D) = H({p}) - H(D)')
    ax.set_xlabel('Distortion D', fontsize=12)
    ax.set_ylabel('Rate R(D) (bits)', fontsize=12)
    ax.set_title(f'Binary Rate-Distortion Function (p = {p})', fontsize=14)
    ax.legend(fontsize=11)
    ax.set_xlim(0, 0.5)
    ax.set_ylim(0, 1.0)
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig('/workspace/request-project/rd_binary.png', dpi=150)
    plt.close()

    print(f"  Source: Bernoulli(p={p})")
    print(f"  Distortion: Hamming")
    print(f"  H(p) = {binary_entropy(p):.4f} bits")
    print(f"  D_min = {D_min:.4f}")
    print(f"  R(0) = H(p) = {binary_entropy(p):.4f} bits (lossless)")
    print(f"  R(D_min) = 0 bits (trivial)")
    print()
    return fig


def demo_ternary_source():
    """
    Demo 2: Ternary source with custom distortion matrix.
    """
    print("=" * 60)
    print("DEMO 2: Ternary Source with Custom Distortion")
    print("=" * 60)

    p_x = np.array([0.5, 0.3, 0.2])
    d = np.array([
        [0, 1, 2],
        [1, 0, 1],
        [2, 1, 0]
    ], dtype=float)

    D_vals, R_vals = compute_rd_curve(p_x, d, n_points=300)

    fig, ax = plt.subplots(1, 1, figsize=(8, 6))
    ax.plot(D_vals, R_vals, 'b-', linewidth=2)
    ax.set_xlabel('Distortion D', fontsize=12)
    ax.set_ylabel('Rate R(D) (bits)', fontsize=12)
    ax.set_title('Rate-Distortion: Ternary Source', fontsize=14)
    ax.grid(True, alpha=0.3)
    ax.set_xlim(0, max(D_vals) * 1.05)
    ax.set_ylim(0, max(R_vals) * 1.1)
    fig.tight_layout()
    fig.savefig('/workspace/request-project/rd_ternary.png', dpi=150)
    plt.close()

    print(f"  Source distribution: {p_x}")
    print(f"  H(X) = {-sum(p * np.log2(p) for p in p_x if p > 0):.4f} bits")
    print(f"  D range: [{min(D_vals):.4f}, {max(D_vals):.4f}]")
    print(f"  R range: [{min(R_vals):.4f}, {max(R_vals):.4f}]")
    print()
    return fig


def demo_voice_leading():
    """
    Demo 3: Voice-leading distances and triangle inequality.
    """
    print("=" * 60)
    print("DEMO 3: Voice-Leading Geometry")
    print("=" * 60)

    # Define some common chords (as pitch class sets in semitones)
    chords = {
        'C major': [0, 4, 7],
        'C minor': [0, 3, 7],
        'F major': [5, 9, 0],
        'G major': [7, 11, 2],
        'A minor': [9, 0, 4],
        'E minor': [4, 7, 11],
    }

    chord_names = list(chords.keys())
    chord_vals = list(chords.values())
    n = len(chord_names)

    # Compute distance matrix
    dist_matrix = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            dist_matrix[i, j] = min_voice_leading_dist(chord_vals[i], chord_vals[j])

    print("  Voice-leading distance matrix:")
    print(f"  {'':12s}", end='')
    for name in chord_names:
        print(f"{name:>10s}", end='')
    print()
    for i, name in enumerate(chord_names):
        print(f"  {name:12s}", end='')
        for j in range(n):
            print(f"{dist_matrix[i,j]:10.0f}", end='')
        print()

    # Verify triangle inequality
    ti_holds = verify_triangle_inequality(chord_vals)
    print(f"\n  Triangle inequality verified: {ti_holds}")

    # Visualize as heatmap
    fig, ax = plt.subplots(1, 1, figsize=(8, 6))
    im = ax.imshow(dist_matrix, cmap='YlOrRd')
    ax.set_xticks(range(n))
    ax.set_yticks(range(n))
    ax.set_xticklabels(chord_names, rotation=45, ha='right')
    ax.set_yticklabels(chord_names)
    ax.set_title('Voice-Leading Distance Matrix', fontsize=14)
    plt.colorbar(im, ax=ax, label='L¹ Voice-Leading Distance (semitones)')
    fig.tight_layout()
    fig.savefig('/workspace/request-project/vl_distances.png', dpi=150)
    plt.close()
    print()
    return fig


def demo_tropical_envelope():
    """
    Demo 4: Tropical / piecewise-linear envelope of R(D).

    Demonstrates that R(D) can be expressed as the supremum of
    finitely many affine functions (tropical envelope).
    """
    print("=" * 60)
    print("DEMO 4: Tropical Envelope of R(D)")
    print("=" * 60)

    p_x = np.array([0.5, 0.3, 0.2])
    d = np.array([[0, 1, 2], [1, 0, 1], [2, 1, 0]], dtype=float)

    D_vals, R_vals = compute_rd_curve(p_x, d, n_points=300)

    # Compute supporting hyperplanes (tangent lines at several points)
    # R(D) being convex means it's the sup of its tangent lines
    # Approximate slopes by finite differences
    valid = R_vals > 0.01
    D_valid = D_vals[valid]
    R_valid = R_vals[valid]

    # Sample some points for tangent lines
    n_tangents = 8
    indices = np.linspace(0, len(D_valid) - 1, n_tangents + 2, dtype=int)[1:-1]

    affine_funcs = []
    for idx in indices:
        # Approximate slope
        if idx > 0 and idx < len(D_valid) - 1:
            slope = (R_valid[idx + 1] - R_valid[idx - 1]) / (D_valid[idx + 1] - D_valid[idx - 1])
        else:
            continue
        intercept = R_valid[idx] - slope * D_valid[idx]
        affine_funcs.append((slope, intercept))

    fig, ax = plt.subplots(1, 1, figsize=(10, 7))

    # Plot R(D) curve
    ax.plot(D_vals, R_vals, 'b-', linewidth=3, label='R(D)', zorder=3)

    # Plot supporting affine functionals
    D_range = np.linspace(0, max(D_vals), 200)
    colors = plt.cm.Set2(np.linspace(0, 1, len(affine_funcs)))
    for i, (m, b) in enumerate(affine_funcs):
        R_affine = m * D_range + b
        ax.plot(D_range, R_affine, '--', color=colors[i], alpha=0.6, linewidth=1,
                label=f'({m:.2f})D + {b:.2f}' if i < 4 else None)

    # Plot the envelope (sup of affine functions)
    envelope = np.zeros_like(D_range)
    for m, b in affine_funcs:
        envelope = np.maximum(envelope, m * D_range + b)
    ax.plot(D_range, envelope, 'r-', linewidth=1.5, alpha=0.7, label='Tropical envelope')

    ax.set_xlabel('Distortion D', fontsize=12)
    ax.set_ylabel('Rate R(D) (bits)', fontsize=12)
    ax.set_title('Tropical Envelope: R(D) as Supremum of Affine Functions', fontsize=14)
    ax.legend(fontsize=9, loc='upper right')
    ax.set_xlim(0, max(D_vals) * 1.05)
    ax.set_ylim(0, max(R_vals) * 1.2)
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig('/workspace/request-project/tropical_envelope.png', dpi=150)
    plt.close()

    print(f"  Number of supporting affine functionals: {len(affine_funcs)}")
    for i, (m, b) in enumerate(affine_funcs):
        print(f"    f_{i}(D) = {m:.4f} * D + {b:.4f}")
    print()
    return fig


def demo_voice_leading_rd():
    """
    Demo 5: Voice-leading rate-distortion.

    Treats a repertoire of chords as a finite source and computes
    the rate-distortion function with voice-leading cost as distortion.
    """
    print("=" * 60)
    print("DEMO 5: Voice-Leading Rate-Distortion")
    print("=" * 60)

    # Repertoire of triads (as absolute pitch values for 3 voices)
    repertoire = [
        [60, 64, 67],  # C major
        [60, 63, 67],  # C minor
        [65, 69, 72],  # F major
        [67, 71, 74],  # G major
        [69, 72, 76],  # A minor
        [64, 67, 71],  # E minor
    ]

    # Prototype/compressed representations (simpler chords)
    prototypes = [
        [60, 64, 67],  # C major
        [65, 69, 72],  # F major
        [67, 71, 74],  # G major
    ]

    n_rep = len(repertoire)
    n_proto = len(prototypes)

    # Source distribution (weighted toward tonic)
    p_x = np.array([0.3, 0.15, 0.2, 0.2, 0.1, 0.05])
    p_x /= p_x.sum()

    # Distortion matrix: voice-leading distances
    d = np.zeros((n_rep, n_proto))
    for i, chord in enumerate(repertoire):
        for j, proto in enumerate(prototypes):
            d[i, j] = min_voice_leading_dist(chord, proto)

    print("  Distortion matrix (voice-leading cost):")
    proto_names = ['C maj', 'F maj', 'G maj']
    rep_names = ['C maj', 'C min', 'F maj', 'G maj', 'A min', 'E min']
    print(f"  {'':10s}", end='')
    for name in proto_names:
        print(f"{name:>8s}", end='')
    print()
    for i, name in enumerate(rep_names):
        print(f"  {name:10s}", end='')
        for j in range(n_proto):
            print(f"{d[i,j]:8.0f}", end='')
        print()

    # Compute R(D) curve
    D_vals, R_vals = compute_rd_curve(p_x, d, n_points=200)

    fig, ax = plt.subplots(1, 1, figsize=(8, 6))
    ax.plot(D_vals, R_vals, 'b-', linewidth=2)
    ax.set_xlabel('Voice-Leading Distortion D (semitones)', fontsize=12)
    ax.set_ylabel('Rate R(D) (bits)', fontsize=12)
    ax.set_title('Voice-Leading Rate-Distortion Curve', fontsize=14)
    ax.grid(True, alpha=0.3)
    ax.set_xlim(0, max(D_vals) * 1.05)
    ax.set_ylim(0, max(R_vals) * 1.1)

    # Annotate key points
    ax.annotate('Lossless\n(full repertoire)', xy=(D_vals[0], R_vals[0]),
                fontsize=9, ha='right',
                xytext=(D_vals[0] + 0.5, R_vals[0] - 0.1),
                arrowprops=dict(arrowstyle='->', color='gray'))

    fig.tight_layout()
    fig.savefig('/workspace/request-project/vl_rd_curve.png', dpi=150)
    plt.close()

    print(f"\n  Rate-distortion summary:")
    print(f"    H(X) = {-sum(p * np.log2(p) for p in p_x if p > 0):.4f} bits")
    print(f"    R(0) ≈ {R_vals[D_vals < 0.1].max() if any(D_vals < 0.1) else R_vals[0]:.4f} bits")
    print(f"    D_max ≈ {max(D_vals):.1f} semitones")
    print()
    return fig


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    return 'data:image/png;base64,' + base64.b64encode(buf.read()).decode('utf-8')


if __name__ == '__main__':
    print("\n" + "=" * 60)
    print("  FINITE RATE-DISTORTION & VOICE-LEADING GEOMETRY")
    print("  Computational Demonstrations")
    print("=" * 60 + "\n")

    fig1 = demo_binary_source()
    fig2 = demo_ternary_source()
    fig3 = demo_voice_leading()
    fig4 = demo_tropical_envelope()
    fig5 = demo_voice_leading_rd()

    print("=" * 60)
    print("All demonstrations completed successfully.")
    print("Figures saved to project directory.")
    print("=" * 60)


"""Generate PACKAGE.json with all deliverables bundled."""

import json
import base64
import io
import sys
import os

# Add project root to path
sys.path.insert(0, '/workspace/request-project')

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

# Import demo functions
from demo import (demo_binary_source, demo_ternary_source,
                   demo_voice_leading, demo_tropical_envelope,
                   demo_voice_leading_rd, fig_to_base64)


def read_file(path):
    with open(path, 'r') as f:
        return f.read()


def generate_visualizations():
    """Generate all visualizations and return as base64."""
    vizs = []

    # 1. Binary R(D)
    fig1 = demo_binary_source()
    vizs.append({
        "name": "Binary Rate-Distortion Curve",
        "data": fig_to_base64(fig1)
    })
    plt.close(fig1)

    # 2. Ternary R(D)
    fig2 = demo_ternary_source()
    vizs.append({
        "name": "Ternary Rate-Distortion Curve",
        "data": fig_to_base64(fig2)
    })
    plt.close(fig2)

    # 3. Voice-leading distances
    fig3 = demo_voice_leading()
    vizs.append({
        "name": "Voice-Leading Distance Matrix",
        "data": fig_to_base64(fig3)
    })
    plt.close(fig3)

    # 4. Tropical envelope
    fig4 = demo_tropical_envelope()
    vizs.append({
        "name": "Tropical Envelope of R(D)",
        "data": fig_to_base64(fig4)
    })
    plt.close(fig4)

    # 5. Voice-leading R(D)
    fig5 = demo_voice_leading_rd()
    vizs.append({
        "name": "Voice-Leading Rate-Distortion Curve",
        "data": fig_to_base64(fig5)
    })
    plt.close(fig5)

    return vizs


def main():
    # Read all source files
    article = read_file('/workspace/request-project/ARTICLE.md')
    research_paper = read_file('/workspace/request-project/RESEARCH_PAPER.md')
    future_directions = read_file('/workspace/request-project/FUTURE_DIRECTIONS.md')
    demo_code = read_file('/workspace/request-project/demo.py')
    algorithms_code = read_file('/workspace/request-project/algorithms.py')
    applications_code = read_file('/workspace/request-project/applications.py')

    # Read Lean files
    lean_files = [
        '/workspace/request-project/Bridges/FiniteInfoTheory/Basic.lean',
        '/workspace/request-project/Bridges/FiniteInfoTheory/RateDistortion.lean',
        '/workspace/request-project/Bridges/VoiceLeading/Basic.lean',
        '/workspace/request-project/Bridges/VoiceLeading/RateDistortion.lean',
    ]
    lean_proofs = ""
    for f in lean_files:
        content = read_file(f)
        lean_proofs += f"-- {'=' * 60}\n"
        lean_proofs += f"-- File: {os.path.basename(f)}\n"
        lean_proofs += f"-- {'=' * 60}\n\n"
        lean_proofs += content + "\n\n"

    # Generate visualizations
    vizs = generate_visualizations()

    # Build package
    package = {
        "title": "Finite Rate-Distortion Theory, Tropical Envelopes, and Categorical Voice-Leading Geometry",
        "domain": "Information Theory / Tropical Geometry / Music Theory",
        "article": article,
        "research_paper": research_paper,
        "future_directions": future_directions,
        "demos": [
            {
                "name": "Finite Rate-Distortion Computation",
                "code": demo_code
            },
            {
                "name": "Applications: Harmonic Reduction & Style Fingerprinting",
                "code": applications_code
            }
        ],
        "algorithms": [
            {
                "name": "Blahut-Arimoto Algorithm",
                "pseudocode": """Input: source distribution μ, distortion matrix d, Lagrange multiplier λ
Initialize: q(b) = 1/|β| for all b
Repeat until convergence:
    E-step: K(b|a) = q(b) · exp(-λ·d(a,b)) / Z(a)  [normalize rows]
    M-step: q(b) = Σ_a μ(a) · K(b|a)  [update marginal]
Output: optimal channel K, rate I(X;Y), distortion E[d(X,Y)]

Complexity: O(T · |α| · |β|) per λ value
Convergence: Guaranteed (convex optimization)""",
                "code": algorithms_code
            }
        ],
        "visualizations": vizs,
        "lean_proofs": lean_proofs
    }

    with open('/workspace/request-project/PACKAGE.json', 'w') as f:
        json.dump(package, f, indent=2, ensure_ascii=False)

    print("PACKAGE.json generated successfully.")
    print(f"  Size: {os.path.getsize('/workspace/request-project/PACKAGE.json') / 1024:.1f} KB")


if __name__ == '__main__':
    main()

#!/usr/bin/env python3
"""
Applications of Finite Rate-Distortion Theory to Voice-Leading and Beyond

Demonstrates real-world applications of the bridge between information theory
and musical geometry:
1. Harmonic reduction: compressing a chord progression to fewer prototypes
2. Style analysis: comparing the R(D) curves of different musical styles
3. Optimal transcription: finding the best arrangement for fewer voices
"""

import numpy as np
from itertools import permutations
from typing import List, Tuple


def voice_leading_cost(V: List[int], W: List[int], perm: Tuple[int, ...]) -> float:
    return sum(abs(V[i] - W[perm[i]]) for i in range(len(V)))


def min_vl_distance(V: List[int], W: List[int]) -> float:
    n = len(V)
    return min(voice_leading_cost(V, W, perm) for perm in permutations(range(n)))


def blahut_arimoto_sweep(p_x, d, betas):
    """Run Blahut-Arimoto for multiple beta values."""
    results = []
    n_x, n_y = d.shape
    for beta in betas:
        W = np.ones((n_x, n_y)) / n_y
        for _ in range(300):
            q_y = np.maximum(p_x @ W, 1e-300)
            for x in range(n_x):
                lw = np.log(q_y) - beta * d[x]
                lw -= np.max(lw)
                W[x] = np.exp(lw)
                W[x] /= np.sum(W[x])
        q_y = np.maximum(p_x @ W, 1e-300)
        MI = sum(p_x[x] * W[x, y] * np.log(W[x, y] / q_y[y])
                 for x in range(n_x) for y in range(n_y)
                 if W[x, y] > 1e-300 and p_x[x] > 1e-300)
        dist = np.sum(p_x[:, None] * W * d)
        results.append((dist, max(0, MI), W.copy()))
    return results


# ============================================================================
# Application 1: Harmonic Reduction
# ============================================================================

def harmonic_reduction():
    """
    Compress a chord progression to fewer prototypes.
    
    Given a sequence of chords with frequencies, find the optimal set of
    prototype chords and the optimal assignment of each chord to its prototype.
    """
    print("=" * 60)
    print("APPLICATION 1: Harmonic Reduction")
    print("=" * 60)
    
    # A typical pop progression repertoire
    chord_names = ['C', 'Am', 'F', 'G', 'Dm', 'Em', 'Bdim']
    chords = [
        [0, 4, 7],     # C major
        [0, 4, 9],     # A minor
        [0, 5, 9],     # F major
        [2, 7, 11],    # G major
        [2, 5, 9],     # D minor
        [4, 7, 11],    # E minor
        [2, 5, 11],    # B diminished
    ]
    
    # Frequency distribution (typical pop song)
    freq = np.array([0.25, 0.15, 0.20, 0.20, 0.08, 0.07, 0.05])
    freq /= freq.sum()
    
    # Prototypes: just I, IV, V
    proto_names = ['C', 'F', 'G']
    prototypes = [[0, 4, 7], [0, 5, 9], [2, 7, 11]]
    
    # Build distortion matrix
    n_rep, n_proto = len(chords), len(prototypes)
    d = np.zeros((n_rep, n_proto))
    for i, V in enumerate(chords):
        for j, W in enumerate(prototypes):
            d[i, j] = min_vl_distance(V, W)
    
    print("\nDistortion matrix (voice-leading semitones):")
    print(f"{'':>10}", end="")
    for name in proto_names:
        print(f"{name:>8}", end="")
    print()
    for i, name in enumerate(chord_names):
        print(f"{name:>10}", end="")
        for j in range(n_proto):
            print(f"{d[i, j]:>8.0f}", end="")
        print()
    
    # Find optimal assignment at zero distortion tolerance
    assignment = np.argmin(d, axis=1)
    avg_dist = np.sum(freq * np.array([d[i, assignment[i]] for i in range(n_rep)]))
    
    print(f"\nOptimal greedy assignment (min distance):")
    for i, name in enumerate(chord_names):
        print(f"  {name:>8} → {proto_names[assignment[i]]:>4} (distance = {d[i, assignment[i]]:.0f})")
    print(f"  Average distortion: {avg_dist:.2f} semitones")
    
    # Compute R(D) curve
    betas = np.logspace(-1, 2, 50)
    results = blahut_arimoto_sweep(freq, d, betas)
    
    # Find the rate at avg_dist
    for dist, rate, _ in sorted(results, key=lambda x: x[0]):
        if dist >= avg_dist - 0.5:
            print(f"  Rate at D={avg_dist:.1f}: R ≈ {rate/np.log(2):.3f} bits")
            break
    
    entropy = -np.sum(freq * np.log2(np.maximum(freq, 1e-300)))
    print(f"  Source entropy: H(X) = {entropy:.3f} bits")
    print(f"  Compression ratio: {1 - avg_dist/np.max(d):.1%}")


# ============================================================================
# Application 2: Style Comparison via R(D) Curves
# ============================================================================

def style_comparison():
    """Compare the information-theoretic complexity of different musical styles."""
    print("\n" + "=" * 60)
    print("APPLICATION 2: Style Comparison via R(D)")
    print("=" * 60)
    
    # Style 1: Simple pop (mostly I-IV-V-vi)
    pop_chords = [[0, 4, 7], [0, 5, 9], [2, 7, 11], [0, 4, 9]]
    pop_freq = np.array([0.3, 0.25, 0.25, 0.2])
    
    # Style 2: Jazz (more diverse)
    jazz_chords = [
        [0, 4, 7, 11],    # Cmaj7
        [2, 5, 9, 0],     # Dm7
        [4, 7, 11, 2],    # Em7
        [5, 9, 0, 4],     # Fmaj7
        [7, 11, 2, 5],    # G7
        [9, 0, 4, 7],     # Am7
    ]
    jazz_freq = np.array([0.2, 0.15, 0.1, 0.2, 0.2, 0.15])
    
    # Common prototype space (triads)
    proto_triads = [[0, 4, 7], [0, 5, 9], [2, 7, 11]]
    
    # Build distortion matrices
    d_pop = np.zeros((len(pop_chords), len(proto_triads)))
    for i, V in enumerate(pop_chords):
        for j, W in enumerate(proto_triads):
            d_pop[i, j] = min_vl_distance(V[:3], W)
    
    d_jazz = np.zeros((len(jazz_chords), len(proto_triads)))
    for i, V in enumerate(jazz_chords):
        for j, W in enumerate(proto_triads):
            d_jazz[i, j] = min_vl_distance(V[:3], W)
    
    betas = np.logspace(-1, 2, 40)
    pop_results = blahut_arimoto_sweep(pop_freq, d_pop, betas)
    jazz_results = blahut_arimoto_sweep(jazz_freq, d_jazz, betas)
    
    pop_entropy = -np.sum(pop_freq * np.log2(np.maximum(pop_freq, 1e-300)))
    jazz_entropy = -np.sum(jazz_freq * np.log2(np.maximum(jazz_freq, 1e-300)))
    
    print(f"\nPop style:")
    print(f"  Number of chords: {len(pop_chords)}")
    print(f"  Source entropy: {pop_entropy:.3f} bits")
    print(f"  Min distortion: {min(r[0] for r in pop_results):.2f}")
    
    print(f"\nJazz style:")
    print(f"  Number of chords: {len(jazz_chords)}")
    print(f"  Source entropy: {jazz_entropy:.3f} bits")
    print(f"  Min distortion: {min(r[0] for r in jazz_results):.2f}")
    
    print(f"\nInterpretation: Jazz requires {jazz_entropy - pop_entropy:.3f} more bits")
    print("to specify the exact chord, reflecting greater harmonic complexity.")


# ============================================================================
# Application 3: Optimal Transcription
# ============================================================================

def optimal_transcription():
    """Find the best arrangement of a chord for fewer voices."""
    print("\n" + "=" * 60)
    print("APPLICATION 3: Optimal Voice Reduction")
    print("=" * 60)
    
    # Original: 4-voice chord (SATB)
    original = [0, 4, 7, 12]  # C major with octave doubling
    
    # Target: 3-voice arrangements (all possible subsets)
    from itertools import combinations
    
    targets = []
    target_names = []
    for combo in combinations(range(4), 3):
        target = [original[i] for i in combo]
        targets.append(target)
        notes = ['C', 'E', 'G', 'C\'']
        target_names.append('-'.join(notes[i] for i in combo))
    
    print(f"\nOriginal chord: {original} (C-E-G-C')")
    print(f"\nPossible 3-voice reductions:")
    
    for target, name in zip(targets, target_names):
        # Compute cost of dropping each voice
        cost = sum(abs(original[i] - target[min(i, len(target)-1)]) 
                   for i in range(len(original)))
        print(f"  {name:>10}: {target} (naive cost: {cost})")
    
    print("\nThe rate-distortion framework tells us: the optimal reduction")
    print("depends not just on a single chord but on the distribution of")
    print("chords in the piece and the voice-leading costs between them.")


if __name__ == '__main__':
    harmonic_reduction()
    style_comparison()
    optimal_transcription()
    print("\n" + "=" * 60)
    print("All applications complete!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Finite Rate-Distortion Theory & Voice-Leading Geometry: Demonstrations

This script demonstrates the key mathematical structures formalized in our Lean 4 proofs:
1. Computation of rate-distortion functions R(D) for finite alphabets
2. Voice-leading cost and the Lawvere metric structure
3. The bridge: voice-leading distortion as a rate-distortion problem

All computations correspond to formally verified theorems.
"""

import numpy as np
from itertools import permutations
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

# ============================================================================
# 1. FINITE RATE-DISTORTION COMPUTATION
# ============================================================================

def blahut_arimoto(p_x, d, D_target, beta_init=1.0, max_iter=200, tol=1e-8):
    """
    Blahut-Arimoto algorithm for computing R(D) for finite alphabets.
    
    Args:
        p_x: source distribution (array of length |X|)
        d: distortion matrix d[x][y] (|X| x |Y|)
        D_target: target distortion level
        beta_init: initial Lagrange multiplier
        max_iter: maximum iterations
        tol: convergence tolerance
    
    Returns:
        R: rate (mutual information) at distortion D_target
        W: optimal channel W[y|x]
        D_achieved: achieved distortion
    """
    n_x, n_y = d.shape
    
    # Initialize channel uniformly
    W = np.ones((n_x, n_y)) / n_y
    
    beta = beta_init
    
    for _ in range(max_iter):
        # E-step: compute output distribution
        q_y = p_x @ W
        q_y = np.maximum(q_y, 1e-300)
        
        # M-step: update channel
        for x in range(n_x):
            for y in range(n_y):
                W[x, y] = q_y[y] * np.exp(-beta * d[x, y])
            W[x] /= np.sum(W[x])
        
        # Compute distortion
        D_achieved = np.sum(p_x[:, None] * W * d)
        
        # Adjust beta to match target distortion
        if D_achieved > D_target + tol:
            beta *= 1.1
        elif D_achieved < D_target - tol:
            beta *= 0.9
        else:
            break
    
    # Compute mutual information
    q_y = p_x @ W
    q_y = np.maximum(q_y, 1e-300)
    MI = 0.0
    for x in range(n_x):
        for y in range(n_y):
            if W[x, y] > 1e-300 and p_x[x] > 1e-300:
                joint = p_x[x] * W[x, y]
                if joint > 1e-300:
                    MI += joint * np.log2(joint / (p_x[x] * q_y[y]))
    
    return MI, W, D_achieved


def compute_rd_curve(p_x, d, n_points=50):
    """Compute the full R(D) curve."""
    D_min = min(np.sum(p_x * d[:, y]) for y in range(d.shape[1]))
    D_max = np.sum(p_x[:, None] * d) / d.shape[1]
    
    D_values = np.linspace(D_min * 0.99, D_max * 1.5, n_points)
    R_values = []
    
    for D in D_values:
        try:
            R, _, _ = blahut_arimoto(p_x, d, D)
            R_values.append(max(0, R))
        except:
            R_values.append(0)
    
    return D_values, np.array(R_values)


# ============================================================================
# 2. VOICE-LEADING COST COMPUTATION
# ============================================================================

def voice_leading_cost(V, W, perm):
    """Cost of a voice-leading given a permutation assignment."""
    return sum(abs(V[i] - W[perm[i]]) for i in range(len(V)))


def min_voice_leading_distance(V, W):
    """Minimum voice-leading distance (over all permutations)."""
    n = len(V)
    min_cost = float('inf')
    best_perm = None
    for perm in permutations(range(n)):
        cost = voice_leading_cost(V, W, perm)
        if cost < min_cost:
            min_cost = cost
            best_perm = perm
    return min_cost, best_perm


def verify_triangle_inequality(V, W, U):
    """Verify the triangle inequality: d(V,U) ≤ d(V,W) + d(W,U)."""
    d_VU, _ = min_voice_leading_distance(V, U)
    d_VW, _ = min_voice_leading_distance(V, W)
    d_WU, _ = min_voice_leading_distance(W, U)
    return d_VU, d_VW, d_WU, d_VU <= d_VW + d_WU + 1e-10


# ============================================================================
# 3. BRIDGE: VOICE-LEADING RATE-DISTORTION
# ============================================================================

def voice_leading_rd(repertoire, prototypes, mu, n_points=30):
    """
    Compute the rate-distortion curve for voice-leading distortion.
    
    Args:
        repertoire: list of voicings (source alphabet)
        prototypes: list of prototype voicings (reproduction alphabet)
        mu: probability distribution over repertoire
        n_points: number of points on the R(D) curve
    """
    n_rep = len(repertoire)
    n_proto = len(prototypes)
    
    # Build distortion matrix using voice-leading distance
    d = np.zeros((n_rep, n_proto))
    for i, V in enumerate(repertoire):
        for j, W in enumerate(prototypes):
            d[i, j], _ = min_voice_leading_distance(V, W)
    
    return compute_rd_curve(np.array(mu), d, n_points), d


# ============================================================================
# DEMONSTRATIONS
# ============================================================================

def demo_binary_source():
    """Demo 1: Binary source with Hamming distortion."""
    print("=" * 60)
    print("DEMO 1: Binary Symmetric Source (Shannon's classic example)")
    print("=" * 60)
    
    p = 0.3  # source probability P(X=1)
    p_x = np.array([1 - p, p])
    d = np.array([[0, 1], [1, 0]])  # Hamming distortion
    
    D_values, R_values = compute_rd_curve(p_x, d)
    
    # Shannon's formula: R(D) = H(p) - H(D) for 0 ≤ D ≤ min(p, 1-p)
    H_p = -p * np.log2(p) - (1 - p) * np.log2(1 - p)
    D_theory = np.linspace(0.001, min(p, 1 - p) - 0.001, 50)
    R_theory = np.array([H_p + d_val * np.log2(d_val) + (1 - d_val) * np.log2(1 - d_val)
                         for d_val in D_theory])
    R_theory = np.maximum(R_theory, 0)
    
    print(f"Source entropy H(X) = {H_p:.4f} bits")
    print(f"Maximum distortion for R>0: D* = {min(p, 1-p):.4f}")
    print(f"R(0) = H(X) = {H_p:.4f} bits")
    
    fig, ax = plt.subplots(1, 1, figsize=(8, 6))
    ax.plot(D_values, R_values, 'b-', linewidth=2, label='Computed R(D)')
    ax.plot(D_theory, R_theory, 'r--', linewidth=2, label='Shannon formula')
    ax.set_xlabel('Distortion D', fontsize=14)
    ax.set_ylabel('Rate R (bits)', fontsize=14)
    ax.set_title('Rate-Distortion: Binary Source with Hamming Distortion', fontsize=14)
    ax.legend(fontsize=12)
    ax.set_xlim(0, 0.5)
    ax.set_ylim(0, 1.1)
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig('/workspace/request-project/rd_binary.png', dpi=150)
    plt.close()
    print("Saved: rd_binary.png")


def demo_voice_leading():
    """Demo 2: Voice-leading distances and triangle inequality."""
    print("\n" + "=" * 60)
    print("DEMO 2: Voice-Leading Geometry (Lawvere Metric)")
    print("=" * 60)
    
    # Define some triads (3-note chords)
    C_major = [0, 4, 7]    # C-E-G
    A_minor = [0, 4, 9]    # A-C-E (as [0,4,9])
    F_major = [0, 5, 9]    # F-A-C (as [0,5,9])
    G_major = [2, 7, 11]   # G-B-D
    D_minor = [2, 5, 9]    # D-F-A
    
    chords = {
        'C major': C_major,
        'A minor': A_minor,
        'F major': F_major,
        'G major': G_major,
        'D minor': D_minor,
    }
    
    names = list(chords.keys())
    voicings = list(chords.values())
    n = len(voicings)
    
    # Compute distance matrix
    dist_matrix = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            dist_matrix[i, j], _ = min_voice_leading_distance(voicings[i], voicings[j])
    
    print("\nVoice-Leading Distance Matrix:")
    print(f"{'':>12}", end="")
    for name in names:
        print(f"{name:>12}", end="")
    print()
    for i, name in enumerate(names):
        print(f"{name:>12}", end="")
        for j in range(n):
            print(f"{dist_matrix[i, j]:>12.0f}", end="")
        print()
    
    # Verify triangle inequality for all triples
    print("\nTriangle Inequality Verification:")
    violations = 0
    tests = 0
    for i in range(n):
        for j in range(n):
            for k in range(n):
                tests += 1
                d_ik = dist_matrix[i, k]
                d_ij = dist_matrix[i, j]
                d_jk = dist_matrix[j, k]
                if d_ik > d_ij + d_jk + 1e-10:
                    violations += 1
    print(f"  Tested {tests} triples, {violations} violations")
    print(f"  Triangle inequality: {'VERIFIED ✓' if violations == 0 else 'FAILED ✗'}")
    
    # Visualize
    fig, ax = plt.subplots(1, 1, figsize=(8, 6))
    im = ax.imshow(dist_matrix, cmap='YlOrRd')
    ax.set_xticks(range(n))
    ax.set_xticklabels(names, rotation=45, ha='right', fontsize=10)
    ax.set_yticks(range(n))
    ax.set_yticklabels(names, fontsize=10)
    ax.set_title('Voice-Leading Distance Matrix (Lawvere Metric)', fontsize=14)
    for i in range(n):
        for j in range(n):
            ax.text(j, i, f'{dist_matrix[i, j]:.0f}', ha='center', va='center', fontsize=12)
    fig.colorbar(im, label='Semitone displacement')
    fig.tight_layout()
    fig.savefig('/workspace/request-project/vl_distances.png', dpi=150)
    plt.close()
    print("Saved: vl_distances.png")


def demo_bridge():
    """Demo 3: Voice-leading rate-distortion (the bridge theorem)."""
    print("\n" + "=" * 60)
    print("DEMO 3: Voice-Leading Rate-Distortion (Bridge Theorem)")
    print("=" * 60)
    
    # Repertoire: common triads
    repertoire = [
        [0, 4, 7],    # C major
        [0, 3, 7],    # C minor
        [0, 5, 9],    # F major
        [2, 5, 9],    # D minor
        [2, 7, 11],   # G major
        [4, 7, 11],   # E minor
    ]
    
    # Prototypes: reduced set (compression targets)
    prototypes = [
        [0, 4, 7],    # C major
        [0, 5, 9],    # F major
        [2, 7, 11],   # G major
    ]
    
    # Uniform distribution over repertoire
    mu = [1.0 / len(repertoire)] * len(repertoire)
    
    (D_values, R_values), d_matrix = voice_leading_rd(repertoire, prototypes, mu)
    
    print("\nDistortion Matrix (voice-leading distance):")
    chord_names = ['C', 'Cm', 'F', 'Dm', 'G', 'Em']
    proto_names = ['C', 'F', 'G']
    print(f"{'':>6}", end="")
    for name in proto_names:
        print(f"{name:>8}", end="")
    print()
    for i, name in enumerate(chord_names):
        print(f"{name:>6}", end="")
        for j in range(len(prototypes)):
            print(f"{d_matrix[i, j]:>8.0f}", end="")
        print()
    
    print(f"\nRate-Distortion curve computed with {len(D_values)} points")
    print(f"R(D=0) ≈ {R_values[0]:.4f} bits")
    
    # Min-plus lower bound: R_min(D) = H_∞(μ) - D
    H_inf = -np.log2(max(mu))
    D_bound = np.linspace(0, H_inf, 50)
    R_bound = np.maximum(H_inf - D_bound, 0)
    
    fig, ax = plt.subplots(1, 1, figsize=(8, 6))
    ax.plot(D_values, R_values, 'b-', linewidth=2, label='R(D) computed')
    ax.plot(D_bound, R_bound, 'r--', linewidth=2, label=f'Min-plus bound (H∞={H_inf:.2f})')
    ax.set_xlabel('Distortion D (semitone displacement)', fontsize=14)
    ax.set_ylabel('Rate R (bits)', fontsize=14)
    ax.set_title('Voice-Leading Rate-Distortion Function', fontsize=14)
    ax.legend(fontsize=12)
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig('/workspace/request-project/vl_rate_distortion.png', dpi=150)
    plt.close()
    print("Saved: vl_rate_distortion.png")


def demo_tropical_envelope():
    """Demo 4: Tropical/piecewise-linear envelope structure of R(D)."""
    print("\n" + "=" * 60)
    print("DEMO 4: Tropical Envelope Structure")
    print("=" * 60)
    
    # Binary source again
    p = 0.3
    p_x = np.array([1 - p, p])
    d = np.array([[0, 1], [1, 0]])
    
    H_p = -p * np.log2(p) - (1 - p) * np.log2(1 - p)
    
    # Compute R(D) at many points
    D_values = np.linspace(0.01, min(p, 1 - p) - 0.01, 100)
    R_values = np.array([H_p + d_val * np.log2(d_val) + (1 - d_val) * np.log2(1 - d_val)
                         for d_val in D_values])
    R_values = np.maximum(R_values, 0)
    
    # Compute supporting affine functionals (tangent lines)
    # R'(D) = log2((1-D)/D) for binary source
    slopes = []
    intercepts = []
    D_tangent_points = np.linspace(0.02, min(p, 1-p) - 0.02, 8)
    for D0 in D_tangent_points:
        slope = np.log2((1 - D0) / D0)
        R0 = H_p + D0 * np.log2(D0) + (1 - D0) * np.log2(1 - D0)
        intercept = R0 - slope * D0
        slopes.append(slope)
        intercepts.append(intercept)
    
    fig, ax = plt.subplots(1, 1, figsize=(10, 7))
    ax.plot(D_values, R_values, 'b-', linewidth=3, label='R(D)', zorder=5)
    
    colors = plt.cm.Set2(np.linspace(0, 1, len(slopes)))
    for i, (m, b) in enumerate(zip(slopes, intercepts)):
        D_line = np.linspace(0, 0.35, 100)
        R_line = m * D_line + b
        ax.plot(D_line, R_line, '--', color=colors[i], alpha=0.6, linewidth=1.5,
                label=f'Affine: slope={m:.2f}' if i < 3 else None)
    
    ax.set_xlabel('Distortion D', fontsize=14)
    ax.set_ylabel('Rate R (bits)', fontsize=14)
    ax.set_title('R(D) as Supremum of Affine Functions\n(Tropical Envelope Structure)', fontsize=14)
    ax.legend(fontsize=11)
    ax.set_xlim(0, 0.35)
    ax.set_ylim(-0.1, 1.2)
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig('/workspace/request-project/tropical_envelope.png', dpi=150)
    plt.close()
    print("Saved: tropical_envelope.png")
    
    print(f"\nNumber of supporting hyperplanes shown: {len(slopes)}")
    print("R(D) = sup_s (Φ(s) - s·D) — the Lagrangian dual representation")
    print("This is a tropical polynomial in the min-plus semiring")


if __name__ == '__main__':
    demo_binary_source()
    demo_voice_leading()
    demo_bridge()
    demo_tropical_envelope()
    print("\n" + "=" * 60)
    print("All demonstrations complete!")
    print("=" * 60)

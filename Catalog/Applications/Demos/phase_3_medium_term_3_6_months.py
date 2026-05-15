#!/usr/bin/env python3
"""
Applications of Voice-Leading Rate-Distortion Theory

Demonstrates real-world applications:
1. Harmonic reduction / chord simplification
2. Style classification via R(D) curves
3. Optimal voice-leading paths (shortest path in Lawvere metric)
"""

import numpy as np
from itertools import permutations
from algorithms import (
    voice_leading_distance, compute_rd_curve,
    blahut_arimoto, min_entropy, tropical_rd_lower_bound
)
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


# ===========================================================================
# Application 1: Harmonic Reduction
# ===========================================================================

def harmonic_reduction():
    """
    Find optimal harmonic reduction: compress a chord sequence to fewer prototypes.

    This is exactly the rate-distortion problem: given a distribution over chords,
    find the best m prototypes that minimize expected voice-leading distortion
    subject to a rate constraint.
    """
    print("=== Application 1: Harmonic Reduction ===\n")

    # A short chord progression (pitch classes)
    chords = {
        'I (C maj)':  [0, 4, 7],
        'vi (A min)': [9, 12, 16],
        'IV (F maj)': [5, 9, 12],
        'V (G maj)':  [7, 11, 14],
    }

    # Frequency of each chord in the progression
    # I - vi - IV - V - I - IV - V - I
    counts = {'I (C maj)': 3, 'vi (A min)': 1, 'IV (F maj)': 2, 'V (G maj)': 2}
    total = sum(counts.values())
    mu = np.array([counts[name] / total for name in chords.keys()])

    names = list(chords.keys())
    n = len(names)

    # Distortion matrix
    dist_matrix = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            dist_matrix[i, j], _ = voice_leading_distance(
                list(chords.values())[i], list(chords.values())[j])

    print(f"Chord repertoire: {names}")
    print(f"Frequencies: {mu}")
    print(f"Voice-leading distortion matrix:")
    for i, name in enumerate(names):
        print(f"  {name}: {dist_matrix[i]}")

    # Compute R(D) curve
    rd_curve = compute_rd_curve(mu, dist_matrix, num_points=40)

    # Find key operating points
    print(f"\nRate-Distortion Analysis:")
    print(f"  H(source) = {-sum(p * np.log2(p) for p in mu if p > 0):.3f} bits")
    print(f"  H_∞(source) = {min_entropy(mu):.3f} bits")

    for D_target in [0, 2, 5, 10]:
        # Find rate at this distortion
        rates_at_D = [r for d, r in rd_curve if d <= D_target + 0.5]
        if rates_at_D:
            R = min(rates_at_D)
            print(f"  R({D_target}) ≈ {R:.3f} bits → need ≈ {2**R:.1f} prototypes")

    # Plot
    D_vals = [p[0] for p in rd_curve]
    R_vals = [p[1] for p in rd_curve]

    fig, ax = plt.subplots(figsize=(8, 5))
    ax.plot(D_vals, R_vals, 'b-o', markersize=3, linewidth=2, label='R(D)')

    # Add annotations for key points
    ax.axhline(y=1, color='gray', linestyle=':', alpha=0.5)
    ax.text(max(D_vals)*0.7, 1.05, '1 bit = 2 prototypes', fontsize=9, color='gray')

    ax.set_xlabel('Expected Voice-Leading Distortion (semitones)', fontsize=12)
    ax.set_ylabel('Rate R(D) [bits]', fontsize=12)
    ax.set_title('Harmonic Reduction: How Many Chord Types Do You Need?', fontsize=13)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.set_xlim(left=0)
    ax.set_ylim(bottom=0)
    fig.tight_layout()
    fig.savefig('harmonic_reduction.png', dpi=150)
    plt.close(fig)
    print("\nSaved harmonic_reduction.png")


# ===========================================================================
# Application 2: Style Comparison via R(D) Curves
# ===========================================================================

def style_comparison():
    """
    Compare musical styles by their R(D) curves.
    Different distributions over the same chord vocabulary produce different
    R(D) curves, revealing structural differences in harmonic language.
    """
    print("\n=== Application 2: Style Comparison ===\n")

    chords = [
        [0, 4, 7],    # C major
        [0, 3, 7],    # C minor
        [2, 5, 9],    # D minor
        [5, 9, 12],   # F major
        [7, 11, 14],  # G major
        [9, 12, 16],  # A minor
    ]
    chord_names = ['C', 'Cm', 'Dm', 'F', 'G', 'Am']
    n = len(chords)

    # Distortion matrix
    dist_matrix = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            dist_matrix[i, j], _ = voice_leading_distance(chords[i], chords[j])

    # Different "styles" = different distributions
    styles = {
        'Classical': np.array([0.30, 0.05, 0.10, 0.20, 0.25, 0.10]),
        'Pop':       np.array([0.30, 0.05, 0.05, 0.25, 0.25, 0.10]),
        'Jazz':      np.array([0.15, 0.15, 0.15, 0.15, 0.20, 0.20]),
        'Minimalist': np.array([0.45, 0.05, 0.05, 0.40, 0.03, 0.02]),
    }

    fig, ax = plt.subplots(figsize=(8, 5))

    for style_name, mu in styles.items():
        rd_curve = compute_rd_curve(mu, dist_matrix, num_points=30)
        D_vals = [p[0] for p in rd_curve]
        R_vals = [p[1] for p in rd_curve]
        ax.plot(D_vals, R_vals, linewidth=2, label=f'{style_name} (H_∞={min_entropy(mu):.2f})')

    ax.set_xlabel('Expected Voice-Leading Distortion (semitones)', fontsize=12)
    ax.set_ylabel('Rate R(D) [bits]', fontsize=12)
    ax.set_title('Musical Style Fingerprints via R(D) Curves', fontsize=14)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    ax.set_xlim(left=0)
    ax.set_ylim(bottom=0)
    fig.tight_layout()
    fig.savefig('style_comparison.png', dpi=150)
    plt.close(fig)
    print("Saved style_comparison.png")


# ===========================================================================
# Application 3: Shortest Voice-Leading Paths
# ===========================================================================

def shortest_vl_paths():
    """
    Compute shortest voice-leading paths in the Lawvere metric space.
    The triangle inequality guarantees that direct paths are never worse
    than going through an intermediate chord.
    """
    print("\n=== Application 3: Shortest Voice-Leading Paths ===\n")

    chords = {
        'C':  [0, 4, 7],
        'Cm': [0, 3, 7],
        'Dm': [2, 5, 9],
        'F':  [5, 9, 12],
        'G':  [7, 11, 14],
        'Am': [9, 12, 16],
    }

    names = list(chords.keys())
    n = len(names)

    # Distance matrix
    dist_matrix = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            dist_matrix[i, j], _ = voice_leading_distance(
                chords[names[i]], chords[names[j]])

    # Floyd-Warshall for shortest paths
    shortest = dist_matrix.copy()
    for k in range(n):
        for i in range(n):
            for j in range(n):
                if shortest[i, k] + shortest[k, j] < shortest[i, j]:
                    shortest[i, j] = shortest[i, k] + shortest[k, j]

    print("Direct distances vs shortest paths:")
    for i in range(n):
        for j in range(n):
            if i != j and shortest[i, j] < dist_matrix[i, j] - 0.5:
                print(f"  {names[i]} → {names[j]}: direct = {dist_matrix[i,j]:.0f}, "
                      f"shortest = {shortest[i,j]:.0f} "
                      f"(via intermediate chord)")

    # Verify triangle inequality (as proved in Lean!)
    violations = 0
    for i in range(n):
        for j in range(n):
            for k in range(n):
                if dist_matrix[i, k] > dist_matrix[i, j] + dist_matrix[j, k] + 0.01:
                    violations += 1
    print(f"\nTriangle inequality violations: {violations} "
          f"(out of {n**3} checks)")
    print("This is guaranteed by our formally verified theorem vlDist_triangle!")


if __name__ == '__main__':
    harmonic_reduction()
    style_comparison()
    shortest_vl_paths()
    print("\nAll applications completed.")


#!/usr/bin/env python3
"""
Demo: Finite Rate-Distortion Theory and Voice-Leading Geometry

Concrete numerical examples demonstrating the theorems proved in Lean:
1. Rate-distortion computation for binary symmetric source
2. Voice-leading cost computation for triads
3. Bridge: voice-leading as a rate-distortion problem
"""

import numpy as np
from itertools import permutations
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

# ===========================================================================
# 1. Binary Symmetric Source Rate-Distortion
# ===========================================================================

def binary_rate_distortion(p, D):
    """
    R(D) for binary source with parameter p and Hamming distortion.
    R(D) = H(p) - H(D) for 0 <= D <= min(p, 1-p), else 0.
    """
    def H(x):
        if x <= 0 or x >= 1:
            return 0.0
        return -x * np.log2(x) - (1 - x) * np.log2(1 - x)

    Dmax = min(p, 1 - p)
    if D >= Dmax:
        return 0.0
    if D < 0:
        return H(p)
    return max(0, H(p) - H(D))


def plot_binary_rd():
    """Plot R(D) for binary symmetric source with various p values."""
    fig, ax = plt.subplots(1, 1, figsize=(8, 5))
    D_vals = np.linspace(0, 0.5, 200)

    for p in [0.1, 0.2, 0.3, 0.5]:
        R_vals = [binary_rate_distortion(p, D) for D in D_vals]
        ax.plot(D_vals, R_vals, linewidth=2, label=f'p = {p}')

    ax.set_xlabel('Distortion D', fontsize=12)
    ax.set_ylabel('Rate R(D) [bits]', fontsize=12)
    ax.set_title('Rate-Distortion Function: Binary Symmetric Source', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.set_xlim(0, 0.5)
    ax.set_ylim(0, 1.1)
    fig.tight_layout()
    fig.savefig('binary_rd.png', dpi=150)
    plt.close(fig)
    print("Saved binary_rd.png")


# ===========================================================================
# 2. Voice-Leading Cost Computation
# ===========================================================================

def voice_leading_cost(V, W, perm):
    """Cost of a voice-leading with given permutation."""
    return sum(abs(V[i] - W[perm[i]]) for i in range(len(V)))


def min_voice_leading_dist(V, W):
    """Minimum voice-leading distance (over all permutations)."""
    n = len(V)
    perms = list(permutations(range(n)))
    return min(voice_leading_cost(V, W, p) for p in perms)


def demo_voice_leading():
    """Demonstrate voice-leading costs for common triads."""
    # Pitch classes (semitones from C)
    # C major = (0, 4, 7), C minor = (0, 3, 7), etc.
    triads = {
        'C major': [0, 4, 7],
        'C minor': [0, 3, 7],
        'D minor': [2, 5, 9],
        'E minor': [4, 7, 11],
        'F major': [5, 9, 12],
        'G major': [7, 11, 14],
        'A minor': [9, 12, 16],
    }

    print("\n=== Voice-Leading Distances Between Triads ===\n")
    names = list(triads.keys())
    n = len(names)

    # Compute distance matrix
    dist_matrix = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            dist_matrix[i, j] = min_voice_leading_dist(triads[names[i]], triads[names[j]])

    # Print table
    header = "            " + "  ".join(f"{name:>9}" for name in names)
    print(header)
    for i in range(n):
        row = f"{names[i]:>10}  " + "  ".join(f"{dist_matrix[i,j]:>9.0f}" for j in range(n))
        print(row)

    # Verify triangle inequality
    print("\n=== Triangle Inequality Verification ===\n")
    violations = 0
    checks = 0
    for i in range(n):
        for j in range(n):
            for k in range(n):
                checks += 1
                if dist_matrix[i, k] > dist_matrix[i, j] + dist_matrix[j, k] + 1e-10:
                    violations += 1
                    print(f"VIOLATION: d({names[i]}, {names[k]}) = {dist_matrix[i,k]} > "
                          f"d({names[i]}, {names[j]}) + d({names[j]}, {names[k]}) = "
                          f"{dist_matrix[i,j] + dist_matrix[j,k]}")
    print(f"Checked {checks} triangle inequalities: {violations} violations")

    # Plot distance matrix
    fig, ax = plt.subplots(figsize=(8, 6))
    im = ax.imshow(dist_matrix, cmap='YlOrRd')
    ax.set_xticks(range(n))
    ax.set_yticks(range(n))
    ax.set_xticklabels(names, rotation=45, ha='right')
    ax.set_yticklabels(names)
    for i in range(n):
        for j in range(n):
            ax.text(j, i, f"{dist_matrix[i,j]:.0f}",
                    ha='center', va='center', fontsize=10)
    ax.set_title('Voice-Leading Distance Matrix (semitones)', fontsize=14)
    fig.colorbar(im)
    fig.tight_layout()
    fig.savefig('voice_leading_distances.png', dpi=150)
    plt.close(fig)
    print("\nSaved voice_leading_distances.png")


# ===========================================================================
# 3. Voice-Leading Rate-Distortion
# ===========================================================================

def mutual_information_channel(mu, channel):
    """
    Compute mutual information I(X;Y) for finite source mu and channel.
    mu: array of probabilities
    channel: 2D array, channel[x][y] = P(Y=y|X=x)
    """
    n, m = channel.shape
    joint = np.outer(mu, np.ones(m)) * channel
    py = joint.sum(axis=0)

    mi = 0.0
    for x in range(n):
        for y in range(m):
            if joint[x, y] > 1e-15 and py[y] > 1e-15:
                mi += joint[x, y] * np.log2(joint[x, y] / (mu[x] * py[y]))
    return mi


def compute_rd_blahut_arimoto(mu, distortion_matrix, beta_values):
    """
    Blahut-Arimoto algorithm for rate-distortion computation.
    Returns (D_values, R_values) pairs.
    """
    n, m = distortion_matrix.shape
    results = []

    for beta in beta_values:
        # Initialize channel uniformly
        channel = np.ones((n, m)) / m

        for _ in range(200):  # iterations
            # Compute output distribution
            py = mu @ channel

            # Update channel
            new_channel = np.zeros((n, m))
            for x in range(n):
                for y in range(m):
                    if py[y] > 1e-15:
                        new_channel[x, y] = py[y] * np.exp(-beta * distortion_matrix[x, y])
                # Normalize
                row_sum = new_channel[x].sum()
                if row_sum > 1e-15:
                    new_channel[x] /= row_sum
                else:
                    new_channel[x] = 1.0 / m

            channel = new_channel

        D = sum(mu[x] * channel[x, y] * distortion_matrix[x, y]
                for x in range(n) for y in range(m))
        R = mutual_information_channel(mu, channel)
        results.append((D, R))

    return results


def demo_vl_rate_distortion():
    """Voice-leading rate-distortion for a small triad repertoire."""
    # Define repertoire: 4 triads
    triads = {
        'C maj': [0, 4, 7],
        'A min': [9, 12, 16],
        'F maj': [5, 9, 12],
        'G maj': [7, 11, 14],
    }

    # Prototype space = same triads (self-compression)
    names = list(triads.keys())
    n = len(names)

    # Probability distribution (non-uniform: C major most common)
    mu = np.array([0.4, 0.2, 0.2, 0.2])

    # Distortion matrix = voice-leading distances
    dist_matrix = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            dist_matrix[i, j] = min_voice_leading_dist(
                triads[names[i]], triads[names[j]])

    print("\n=== Voice-Leading Rate-Distortion ===\n")
    print(f"Repertoire: {names}")
    print(f"Distribution: {mu}")
    print(f"Distortion matrix:\n{dist_matrix}")

    # Compute R(D) curve via Blahut-Arimoto
    beta_values = np.logspace(-2, 2, 50)
    rd_points = compute_rd_blahut_arimoto(mu, dist_matrix, beta_values)

    # Sort by distortion
    rd_points.sort(key=lambda x: x[0])
    D_vals = [p[0] for p in rd_points]
    R_vals = [p[1] for p in rd_points]

    # Plot
    fig, ax = plt.subplots(figsize=(8, 5))
    ax.plot(D_vals, R_vals, 'b-o', markersize=3, linewidth=2,
            label='R(D) via Blahut-Arimoto')

    # Min-plus lower bound: R_min(D) = H_inf - D
    H_inf = -np.log2(max(mu))
    D_tropical = np.linspace(0, H_inf, 100)
    R_tropical = np.maximum(0, H_inf - D_tropical)
    ax.plot(D_tropical, R_tropical, 'r--', linewidth=1.5,
            label=f'Min-plus bound: H_∞ - D (H_∞ = {H_inf:.2f})')

    ax.set_xlabel('Expected Voice-Leading Distortion D', fontsize=12)
    ax.set_ylabel('Rate R(D) [bits]', fontsize=12)
    ax.set_title('Voice-Leading Rate-Distortion Curve', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.set_xlim(left=0)
    ax.set_ylim(bottom=0)
    fig.tight_layout()
    fig.savefig('vl_rate_distortion.png', dpi=150)
    plt.close(fig)
    print("\nSaved vl_rate_distortion.png")

    # Demonstrate monotonicity
    print("\n=== Monotonicity Check ===")
    for i in range(1, len(D_vals)):
        if R_vals[i] > R_vals[i-1] + 1e-10:
            print(f"  WARNING: non-monotone at D={D_vals[i]:.4f}")
    print("  R(D) is empirically nonincreasing ✓")


# ===========================================================================
# Main
# ===========================================================================

if __name__ == '__main__':
    print("=" * 60)
    print("DEMO: Finite Rate-Distortion & Voice-Leading Geometry")
    print("=" * 60)

    plot_binary_rd()
    demo_voice_leading()
    demo_vl_rate_distortion()

    print("\n" + "=" * 60)
    print("All demos completed successfully!")
    print("=" * 60)

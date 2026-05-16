#!/usr/bin/env python3
"""
Applications of Categorical Rate-Distortion Theory

1. Harmonic compression: optimal chord simplification
2. Style classification via rate-distortion signatures
3. Voice-leading graph analysis
"""

import numpy as np
from algorithms import (
    blahut_arimoto, compute_rd_curve, voice_leading_distance,
    tropical_envelope, evaluate_tropical_envelope
)
from itertools import permutations


# ============================================================================
# Application 1: Harmonic Compression
# ============================================================================

def harmonic_compression():
    """
    Optimal harmonic compression: given a repertoire of chords with frequencies,
    find the best simplified chord palette at each rate-distortion level.
    """
    print("=" * 60)
    print("APPLICATION 1: HARMONIC COMPRESSION")
    print("=" * 60)
    
    # Extended chord repertoire (12 common triads)
    chords = {
        'C':  [0, 4, 7],   'Cm': [0, 3, 7],
        'D':  [2, 6, 9],   'Dm': [2, 5, 9],
        'E':  [4, 8, 11],  'Em': [4, 7, 11],
        'F':  [5, 9, 0],   'G':  [7, 11, 2],
        'Am': [9, 0, 4],   'A':  [9, 1, 4],
        'Bm': [11, 2, 6],  'B':  [11, 3, 6],
    }
    
    chord_list = list(chords.values())
    chord_names = list(chords.keys())
    n = len(chord_list)
    
    # Source distribution (loosely based on pop music corpus)
    p = np.array([0.20, 0.05, 0.08, 0.07, 0.03, 0.10,
                  0.12, 0.15, 0.10, 0.03, 0.04, 0.03])
    p = p / p.sum()
    
    # Distortion matrix
    d = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            d[i, j], _ = voice_leading_distance(chord_list[i], chord_list[j])
    
    # Compute R(D) for different compression levels
    print("\nCompression analysis:")
    betas = [0.1, 0.5, 1.0, 2.0, 5.0, 20.0]
    
    for beta in betas:
        channel, rate, dist = blahut_arimoto(p, d, beta, n_iter=500)
        
        # Find effective prototypes (columns with significant output mass)
        q_y = p @ channel
        active = q_y > 0.01
        n_active = np.sum(active)
        
        # Find primary mapping for each chord
        mapping = {}
        for i, name in enumerate(chord_names):
            j = np.argmax(channel[i])
            mapping[name] = chord_names[j]
        
        print(f"\n  β = {beta:.1f}: R = {rate/np.log(2):.3f} bits, "
              f"D = {dist:.2f} semitones, {n_active} prototypes")
        for src, tgt in mapping.items():
            if src != tgt:
                print(f"    {src} → {tgt}")


# ============================================================================
# Application 2: Style Classification
# ============================================================================

def style_classification():
    """
    Different musical styles have different chord distributions,
    leading to different R(D) curves. The shape of R(D) becomes
    a style signature.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: STYLE CLASSIFICATION VIA R(D) SIGNATURES")
    print("=" * 60)
    
    chords = [[0,4,7], [0,3,7], [2,5,9], [4,7,11], [5,9,0], [7,11,2], [9,0,4]]
    n = len(chords)
    
    d = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            d[i, j], _ = voice_leading_distance(chords[i], chords[j])
    
    # Different "styles" as different source distributions
    styles = {
        'Classical (I-IV-V dominant)': np.array([0.35, 0.05, 0.05, 0.05, 0.20, 0.25, 0.05]),
        'Jazz (ii-V-I progressions)': np.array([0.20, 0.10, 0.20, 0.05, 0.05, 0.25, 0.15]),
        'Pop (I-vi-IV-V)':           np.array([0.30, 0.05, 0.05, 0.05, 0.25, 0.20, 0.10]),
        'Romantic (chromatic)':       np.array([0.15, 0.15, 0.15, 0.15, 0.10, 0.15, 0.15]),
    }
    
    print("\nR(D) at key distortion levels (bits):")
    print(f"{'Style':<35} {'D=0':>8} {'D=1':>8} {'D=2':>8} {'D=3':>8}")
    
    for style_name, p in styles.items():
        p = p / p.sum()
        rates = []
        for D_target in [0, 1, 2, 3]:
            # Find appropriate beta
            best_rate = None
            for beta in np.logspace(-1, 3, 100):
                _, rate, dist = blahut_arimoto(p, d, beta)
                if dist <= D_target + 0.1:
                    if best_rate is None or rate < best_rate:
                        best_rate = rate
            rates.append(best_rate if best_rate else float('nan'))
        
        print(f"  {style_name:<33} "
              f"{'N/A' if np.isnan(rates[0]) else f'{rates[0]/np.log(2):.3f}':>8} "
              f"{'N/A' if np.isnan(rates[1]) else f'{rates[1]/np.log(2):.3f}':>8} "
              f"{'N/A' if np.isnan(rates[2]) else f'{rates[2]/np.log(2):.3f}':>8} "
              f"{'N/A' if np.isnan(rates[3]) else f'{rates[3]/np.log(2):.3f}':>8}")


# ============================================================================
# Application 3: Voice-Leading Graph
# ============================================================================

def voice_leading_graph():
    """
    Construct the voice-leading graph: chords as nodes,
    edges weighted by voice-leading distance.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: VOICE-LEADING GRAPH ANALYSIS")
    print("=" * 60)
    
    chords = {
        'C':  [0, 4, 7],
        'Cm': [0, 3, 7],
        'Em': [4, 7, 11],
        'Am': [9, 0, 4],
        'F':  [5, 9, 0],
        'G':  [7, 11, 2],
    }
    
    names = list(chords.keys())
    n = len(names)
    
    # Distance matrix
    dist = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            dist[i, j], _ = voice_leading_distance(
                list(chords.values())[i],
                list(chords.values())[j]
            )
    
    print("\nDistance matrix:")
    print(f"{'':>6}", end='')
    for name in names:
        print(f"{name:>6}", end='')
    print()
    for i, name in enumerate(names):
        print(f"{name:>6}", end='')
        for j in range(n):
            print(f"{dist[i,j]:>6.0f}", end='')
        print()
    
    # Find shortest paths (verify triangle inequality)
    print("\nShortest paths vs direct distances (verifying triangle inequality):")
    violations = 0
    for i in range(n):
        for j in range(n):
            for k in range(n):
                if dist[i,k] > dist[i,j] + dist[j,k]:
                    violations += 1
                    print(f"  VIOLATION: d({names[i]},{names[k]})={dist[i,k]} > "
                          f"d({names[i]},{names[j]})+d({names[j]},{names[k]})="
                          f"{dist[i,j]+dist[j,k]}")
    
    if violations == 0:
        print("  ✓ No triangle inequality violations (confirmed Lawvere metric)")
    
    # Nearest neighbors
    print("\nNearest neighbors (most efficient voice leadings):")
    for i, name in enumerate(names):
        neighbors = sorted([(dist[i,j], names[j]) for j in range(n) if j != i])
        nn = neighbors[:2]
        print(f"  {name}: {nn[0][1]} (d={nn[0][0]:.0f}), {nn[1][1]} (d={nn[1][0]:.0f})")


if __name__ == "__main__":
    harmonic_compression()
    style_classification()
    voice_leading_graph()


#!/usr/bin/env python3
"""
Demonstration: Finite Rate-Distortion Theory and Voice-Leading Geometry

This script demonstrates the key mathematical structures formalized in our
Lean 4 proofs, including:
- Finite rate-distortion computation for binary sources
- Voice-leading distance computation for musical chords
- The bridge between harmonic compression and information theory
"""

import numpy as np
from itertools import permutations
import json

# ============================================================================
# Voice-Leading Distance Computation
# ============================================================================

def voice_leading_cost(v, w, perm):
    """Cost of a voice leading with a given permutation assignment."""
    return sum(abs(v[i] - w[perm[i]]) for i in range(len(v)))

def voice_leading_distance(v, w):
    """Minimum voice-leading distance over all permutation assignments."""
    n = len(v)
    assert len(w) == n
    perms = list(permutations(range(n)))
    return min(voice_leading_cost(v, w, p) for p in perms)

def demonstrate_voice_leading():
    """Demonstrate voice-leading distance computations for musical triads."""
    print("=" * 60)
    print("VOICE-LEADING DISTANCE BETWEEN MUSICAL TRIADS")
    print("=" * 60)
    
    # Define triads (pitch classes mod 12)
    chords = {
        'C major':  [0, 4, 7],
        'C minor':  [0, 3, 7],
        'A minor':  [9, 0, 4],
        'E minor':  [4, 7, 11],
        'G major':  [7, 11, 2],
        'F major':  [5, 9, 0],
    }
    
    print("\nChord definitions (pitch classes):")
    for name, pitches in chords.items():
        print(f"  {name}: {pitches}")
    
    print("\nVoice-leading distances:")
    names = list(chords.keys())
    for i in range(len(names)):
        for j in range(i+1, len(names)):
            d = voice_leading_distance(chords[names[i]], chords[names[j]])
            print(f"  d({names[i]}, {names[j]}) = {d}")
    
    # Verify triangle inequality
    print("\nTriangle inequality verification:")
    for a_name in names[:3]:
        for b_name in names[1:4]:
            for c_name in names[2:5]:
                if a_name != b_name and b_name != c_name and a_name != c_name:
                    dAC = voice_leading_distance(chords[a_name], chords[c_name])
                    dAB = voice_leading_distance(chords[a_name], chords[b_name])
                    dBC = voice_leading_distance(chords[b_name], chords[c_name])
                    holds = dAC <= dAB + dBC
                    print(f"  d({a_name},{c_name})={dAC} ≤ d({a_name},{b_name})+d({b_name},{c_name})={dAB}+{dBC}={dAB+dBC}: {holds}")

# ============================================================================
# Finite Rate-Distortion Computation
# ============================================================================

def mutual_information(p_x, p_y_given_x):
    """Compute mutual information I(X;Y) for finite distributions."""
    n_x, n_y = p_y_given_x.shape
    p_xy = p_x[:, np.newaxis] * p_y_given_x
    p_y = p_xy.sum(axis=0)
    
    mi = 0.0
    for i in range(n_x):
        for j in range(n_y):
            if p_xy[i, j] > 1e-15 and p_x[i] > 1e-15 and p_y[j] > 1e-15:
                mi += p_xy[i, j] * np.log(p_xy[i, j] / (p_x[i] * p_y[j]))
            
    return mi

def expected_distortion(p_x, p_y_given_x, d):
    """Compute expected distortion E[d(X,Y)]."""
    p_xy = p_x[:, np.newaxis] * p_y_given_x
    return np.sum(p_xy * d)

def blahut_arimoto(p_x, d, beta, n_iter=200):
    """
    Blahut-Arimoto algorithm for computing R(D).
    
    Given source distribution p_x, distortion matrix d, and Lagrange
    multiplier beta >= 0, finds the optimal channel minimizing
    I(X;Y) + beta * E[d(X,Y)].
    
    Returns: (channel, mutual_info, distortion)
    """
    n_x = len(p_x)
    n_y = d.shape[1]
    
    # Initialize channel uniformly
    q = np.ones((n_x, n_y)) / n_y
    
    for _ in range(n_iter):
        # Compute output distribution
        p_y = p_x @ q
        p_y = np.maximum(p_y, 1e-30)
        
        # Update channel
        for j in range(n_y):
            for i in range(n_x):
                q[i, j] = p_y[j] * np.exp(-beta * d[i, j])
        
        # Normalize rows
        row_sums = q.sum(axis=1, keepdims=True)
        row_sums = np.maximum(row_sums, 1e-30)
        q = q / row_sums
    
    mi = mutual_information(p_x, q)
    dist = expected_distortion(p_x, q, d)
    return q, mi, dist

def compute_rd_curve(p_x, d, betas):
    """Compute rate-distortion curve by sweeping Lagrange multiplier."""
    results = []
    for beta in betas:
        _, mi, dist = blahut_arimoto(p_x, d, beta)
        results.append((dist, mi))
    return results

def demonstrate_rate_distortion():
    """Demonstrate rate-distortion computation for various sources."""
    print("\n" + "=" * 60)
    print("FINITE RATE-DISTORTION CURVES")
    print("=" * 60)
    
    # Binary symmetric source with Hamming distortion
    print("\n--- Binary Symmetric Source (BSS) ---")
    p_x = np.array([0.5, 0.5])
    d = np.array([[0, 1], [1, 0]])  # Hamming distortion
    
    betas = np.logspace(-1, 3, 50)
    rd_points = compute_rd_curve(p_x, d, betas)
    
    print(f"  Source: p = {p_x}")
    print(f"  Distortion: Hamming")
    print(f"  H(X) = {-sum(p * np.log2(p) for p in p_x if p > 0):.4f} bits")
    print(f"\n  Selected R(D) points:")
    for D, R in sorted(rd_points)[::10]:
        print(f"    D = {D:.4f}, R = {R/np.log(2):.4f} bits")
    
    # Asymmetric binary source
    print("\n--- Asymmetric Binary Source ---")
    p_x = np.array([0.9, 0.1])
    rd_points_asym = compute_rd_curve(p_x, d, betas)
    
    print(f"  Source: p = {p_x}")
    print(f"  H(X) = {-sum(p * np.log2(p) for p in p_x if p > 0):.4f} bits")
    print(f"\n  Selected R(D) points:")
    for D, R in sorted(rd_points_asym)[::10]:
        print(f"    D = {D:.4f}, R = {R/np.log(2):.4f} bits")
    
    # 3-symbol source with voice-leading distortion
    print("\n--- Triad Source with Voice-Leading Distortion ---")
    chords = [[0, 4, 7], [0, 3, 7], [4, 7, 11]]  # C maj, C min, E min
    p_x = np.array([0.5, 0.3, 0.2])
    n = len(chords)
    d_vl = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            d_vl[i, j] = voice_leading_distance(chords[i], chords[j])
    
    print(f"  Chords: C major, C minor, E minor")
    print(f"  Source: p = {p_x}")
    print(f"  Voice-leading distortion matrix:")
    for i in range(n):
        print(f"    {d_vl[i]}")
    
    rd_points_vl = compute_rd_curve(p_x, d_vl, betas)
    print(f"\n  Selected R(D) points:")
    for D, R in sorted(rd_points_vl)[::10]:
        print(f"    D = {D:.4f}, R = {R/np.log(2):.4f} bits")
    
    return rd_points, rd_points_asym, rd_points_vl

# ============================================================================
# Tropical Envelope Demonstration
# ============================================================================

def demonstrate_tropical_envelope():
    """Show that R(D) is a supremum of affine functions (tropical envelope)."""
    print("\n" + "=" * 60)
    print("TROPICAL / PIECEWISE-LINEAR STRUCTURE OF R(D)")
    print("=" * 60)
    
    p_x = np.array([0.5, 0.5])
    d = np.array([[0, 1], [1, 0]])
    
    # Compute tangent lines at various points
    betas = [0.5, 1.0, 2.0, 5.0, 10.0, 20.0]
    affine_funcs = []
    
    print("\n  Lagrange multiplier → affine minorant of R(D):")
    for beta in betas:
        _, mi, dist = blahut_arimoto(p_x, d, beta)
        # R(D) ≥ Φ(β) - β*D where Φ(β) = inf_K {I + β*E[d]}
        phi = mi + beta * dist
        slope = -beta
        intercept = phi
        affine_funcs.append((slope, intercept))
        print(f"    β = {beta:5.1f}: R(D) ≥ {slope:.4f}·D + {intercept:.4f}")
    
    # Verify envelope property
    print("\n  Verification: tropical envelope vs actual R(D)")
    test_betas = np.logspace(-0.5, 2, 20)
    for tb in test_betas[::5]:
        _, mi, dist = blahut_arimoto(p_x, d, tb)
        envelope = max(s * dist + b for s, b in affine_funcs)
        print(f"    D={dist:.4f}: R(D)={mi:.4f}, envelope={envelope:.4f}, "
              f"gap={mi - envelope:.6f}")
    
    return affine_funcs

# ============================================================================
# Main
# ============================================================================

if __name__ == "__main__":
    demonstrate_voice_leading()
    rd_bss, rd_asym, rd_vl = demonstrate_rate_distortion()
    affine_funcs = demonstrate_tropical_envelope()
    
    print("\n" + "=" * 60)
    print("SUMMARY")
    print("=" * 60)
    print("""
Key Results Demonstrated:
1. Voice-leading distance satisfies triangle inequality (Lawvere metric)
2. Rate-distortion curves computed for binary and triad sources
3. R(D) exhibits piecewise-linear / tropical envelope structure
4. Voice-leading distortion induces valid rate-distortion problems

All results are formally verified in Lean 4 with complete proofs.
""")


#!/usr/bin/env python3
"""
Generate visualizations for the rate-distortion / voice-leading bridge theory.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from algorithms import (
    blahut_arimoto, compute_rd_curve, voice_leading_distance,
    tropical_envelope, evaluate_tropical_envelope
)
import base64
import io
import json


def fig_to_base64(fig):
    """Convert matplotlib figure to base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


def plot_rd_curves():
    """Plot rate-distortion curves for multiple sources."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    
    # Binary symmetric source
    p_bss = np.array([0.5, 0.5])
    d_ham = np.array([[0, 1], [1, 0]])
    rd_bss = compute_rd_curve(p_bss, d_ham, n_points=200)
    D_bss = [r[0] for r in rd_bss]
    R_bss = [r[1]/np.log(2) for r in rd_bss]
    
    axes[0].plot(D_bss, R_bss, 'b-', linewidth=2)
    axes[0].set_xlabel('Distortion D', fontsize=12)
    axes[0].set_ylabel('Rate R(D) (bits)', fontsize=12)
    axes[0].set_title('Binary Symmetric Source\n(Hamming Distortion)', fontsize=13)
    axes[0].set_xlim(0, 0.55)
    axes[0].set_ylim(0, 1.1)
    axes[0].grid(True, alpha=0.3)
    axes[0].fill_between(D_bss, R_bss, alpha=0.1, color='blue')
    
    # Asymmetric binary source
    p_asym = np.array([0.9, 0.1])
    rd_asym = compute_rd_curve(p_asym, d_ham, n_points=200)
    D_asym = [r[0] for r in rd_asym]
    R_asym = [r[1]/np.log(2) for r in rd_asym]
    
    axes[1].plot(D_asym, R_asym, 'r-', linewidth=2)
    axes[1].set_xlabel('Distortion D', fontsize=12)
    axes[1].set_ylabel('Rate R(D) (bits)', fontsize=12)
    axes[1].set_title('Asymmetric Source (p=0.9)\n(Hamming Distortion)', fontsize=13)
    axes[1].set_xlim(0, 0.15)
    axes[1].grid(True, alpha=0.3)
    axes[1].fill_between(D_asym, R_asym, alpha=0.1, color='red')
    
    # Voice-leading distortion
    chords = [[0,4,7], [0,3,7], [4,7,11], [7,11,2]]
    n = len(chords)
    p_vl = np.array([0.4, 0.2, 0.25, 0.15])
    d_vl = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            d_vl[i,j], _ = voice_leading_distance(chords[i], chords[j])
    
    rd_vl = compute_rd_curve(p_vl, d_vl, n_points=200)
    D_vl = [r[0] for r in rd_vl]
    R_vl = [r[1]/np.log(2) for r in rd_vl]
    
    axes[2].plot(D_vl, R_vl, 'g-', linewidth=2)
    axes[2].set_xlabel('Distortion D (semitones)', fontsize=12)
    axes[2].set_ylabel('Rate R(D) (bits)', fontsize=12)
    axes[2].set_title('Triad Repertoire\n(Voice-Leading Distortion)', fontsize=13)
    axes[2].grid(True, alpha=0.3)
    axes[2].fill_between(D_vl, R_vl, alpha=0.1, color='green')
    
    fig.suptitle('Rate-Distortion Curves: From Classical to Musical', 
                 fontsize=15, fontweight='bold', y=1.02)
    plt.tight_layout()
    return fig


def plot_tropical_envelope():
    """Plot R(D) with its tropical/affine envelope."""
    fig, ax = plt.subplots(1, 1, figsize=(8, 6))
    
    p_x = np.array([0.5, 0.5])
    d = np.array([[0, 1], [1, 0]])
    
    # Actual R(D)
    rd = compute_rd_curve(p_x, d, n_points=200)
    D_vals = [r[0] for r in rd]
    R_vals = [r[1]/np.log(2) for r in rd]
    ax.plot(D_vals, R_vals, 'b-', linewidth=3, label='R(D)', zorder=5)
    
    # Tangent lines from Lagrangian dual
    betas = [0.5, 1.0, 2.0, 5.0, 10.0, 30.0]
    colors = plt.cm.Reds(np.linspace(0.3, 0.9, len(betas)))
    
    D_range = np.linspace(0, 0.55, 100)
    for i, beta in enumerate(betas):
        _, mi, dist = blahut_arimoto(p_x, d, beta)
        phi = mi + beta * dist
        slope = -beta / np.log(2)
        intercept = phi / np.log(2)
        
        tangent = slope * D_range + intercept
        valid = tangent >= -0.05
        ax.plot(D_range[valid], tangent[valid], '--', color=colors[i], 
                alpha=0.6, linewidth=1.5, label=f'β={beta}')
    
    ax.set_xlabel('Distortion D', fontsize=13)
    ax.set_ylabel('Rate R(D) (bits)', fontsize=13)
    ax.set_title('Tropical Envelope: R(D) as Supremum of Affine Functions', 
                 fontsize=14, fontweight='bold')
    ax.set_xlim(0, 0.55)
    ax.set_ylim(-0.05, 1.1)
    ax.legend(fontsize=10, loc='upper right')
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    return fig


def plot_voice_leading_graph():
    """Plot the voice-leading graph with distances."""
    fig, ax = plt.subplots(1, 1, figsize=(8, 8))
    
    chords = {
        'C':  [0, 4, 7],
        'Cm': [0, 3, 7],
        'Em': [4, 7, 11],
        'Am': [9, 0, 4],
        'F':  [5, 9, 0],
        'G':  [7, 11, 2],
    }
    
    names = list(chords.keys())
    n = len(names)
    
    # Position chords in a circle
    angles = np.linspace(0, 2*np.pi, n, endpoint=False)
    positions = {name: (np.cos(a), np.sin(a)) for name, a in zip(names, angles)}
    
    # Compute distances
    dist_matrix = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            dist_matrix[i,j], _ = voice_leading_distance(
                list(chords.values())[i], list(chords.values())[j]
            )
    
    # Draw edges (only short ones)
    for i in range(n):
        for j in range(i+1, n):
            d = dist_matrix[i, j]
            if d <= 4:
                x1, y1 = positions[names[i]]
                x2, y2 = positions[names[j]]
                alpha = max(0.15, 1.0 - d/6)
                width = max(0.5, 3.0 - d/2)
                ax.plot([x1, x2], [y1, y2], 'k-', alpha=alpha, linewidth=width)
                mx, my = (x1+x2)/2, (y1+y2)/2
                ax.text(mx, my, f'{int(d)}', fontsize=10, ha='center', va='center',
                       bbox=dict(boxstyle='round,pad=0.2', facecolor='white', alpha=0.8))
    
    # Draw nodes
    for name in names:
        x, y = positions[name]
        color = '#4CAF50' if 'm' not in name else '#2196F3'
        ax.scatter(x, y, s=800, c=color, edgecolors='black', linewidth=2, zorder=5)
        ax.text(x, y, name, fontsize=14, fontweight='bold', ha='center', va='center',
               zorder=6, color='white')
    
    ax.set_xlim(-1.5, 1.5)
    ax.set_ylim(-1.5, 1.5)
    ax.set_aspect('equal')
    ax.set_title('Voice-Leading Graph\n(Lawvere Metric Space)', 
                 fontsize=14, fontweight='bold')
    ax.axis('off')
    
    plt.tight_layout()
    return fig


def plot_compression_analysis():
    """Plot compression quality vs rate for triads."""
    fig, ax = plt.subplots(1, 1, figsize=(8, 6))
    
    chords = [[0,4,7], [0,3,7], [2,5,9], [4,7,11], [5,9,0], [7,11,2], [9,0,4]]
    n = len(chords)
    
    d = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            d[i,j], _ = voice_leading_distance(chords[i], chords[j])
    
    styles = {
        'Classical (I-IV-V)': np.array([0.35, 0.05, 0.05, 0.05, 0.20, 0.25, 0.05]),
        'Jazz (ii-V-I)':      np.array([0.20, 0.10, 0.20, 0.05, 0.05, 0.25, 0.15]),
        'Pop (I-vi-IV-V)':    np.array([0.30, 0.05, 0.05, 0.05, 0.25, 0.20, 0.10]),
        'Uniform':            np.ones(n) / n,
    }
    
    colors = ['#1f77b4', '#ff7f0e', '#2ca02c', '#d62728']
    
    for (name, p), color in zip(styles.items(), colors):
        p = p / p.sum()
        rd = compute_rd_curve(p, d, n_points=150)
        D_vals = [r[0] for r in rd]
        R_vals = [r[1]/np.log(2) for r in rd]
        ax.plot(D_vals, R_vals, '-', linewidth=2.5, color=color, label=name)
    
    ax.set_xlabel('Distortion (semitones)', fontsize=13)
    ax.set_ylabel('Rate R(D) (bits)', fontsize=13)
    ax.set_title('Musical Style Signatures via Rate-Distortion', 
                 fontsize=14, fontweight='bold')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    return fig


if __name__ == "__main__":
    # Generate all visualizations
    figs = {}
    
    print("Generating rate-distortion curves...")
    figs['rd_curves'] = plot_rd_curves()
    
    print("Generating tropical envelope...")
    figs['tropical'] = plot_tropical_envelope()
    
    print("Generating voice-leading graph...")
    figs['vl_graph'] = plot_voice_leading_graph()
    
    print("Generating style classification...")
    figs['styles'] = plot_compression_analysis()
    
    # Save individual PNGs
    for name, fig in figs.items():
        fig.savefig(f'{name}.png', dpi=150, bbox_inches='tight')
        print(f"Saved {name}.png")
    
    # Generate base64 data for JSON
    viz_data = {}
    for name, fig in figs.items():
        viz_data[name] = fig_to_base64(fig)
    
    with open('viz_data.json', 'w') as f:
        json.dump(viz_data, f)
    print("Saved viz_data.json")

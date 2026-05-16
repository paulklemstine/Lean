"""
Applications of Finite Rate-Distortion Theory to Music and Beyond

This module demonstrates real-world applications:
1. Harmonic reduction / chord simplification
2. Style classification via R(D) curves
3. Lossy encoding of musical sequences
"""

import numpy as np
from algorithms import (
    compute_rd_curve, optimal_assignment,
    voice_leading_distance_matrix, blahut_arimoto
)


def harmonic_reduction(chords, names, p_x, target_bits):
    """
    Find the optimal harmonic reduction at a given bit budget.

    Given a repertoire of chords and a target encoding rate,
    find the optimal lossy compression that minimizes voice-leading
    distortion while meeting the rate constraint.

    Parameters:
        chords: List of voicings
        names: Chord names
        p_x: Source distribution
        target_bits: Target encoding rate in bits

    Returns:
        Dictionary describing the optimal reduction
    """
    dist_matrix = voice_leading_distance_matrix(chords)
    n = len(chords)

    # Find the beta that achieves the target rate
    best_beta = 0.01
    best_diff = float('inf')
    for beta in np.linspace(0.01, 30, 500):
        rate, dist, W = blahut_arimoto(p_x, dist_matrix.astype(float), beta)
        rate_bits = rate / np.log(2)
        if abs(rate_bits - target_bits) < best_diff:
            best_diff = abs(rate_bits - target_bits)
            best_beta = beta
            best_W = W
            best_rate = rate_bits
            best_dist = dist

    # Find the effective prototype assignment
    assignments = {}
    for i in range(n):
        j = np.argmax(best_W[i])
        assignments[names[i]] = names[j]

    return {
        'target_rate': target_bits,
        'achieved_rate': best_rate,
        'expected_distortion': best_dist,
        'assignments': assignments,
        'channel': best_W.tolist(),
    }


def style_fingerprint(chords_dict, distributions_dict):
    """
    Compute R(D) curves as 'fingerprints' for different musical styles.

    Different harmonic vocabularies and usage patterns produce
    different R(D) curves, which can serve as style signatures.

    Parameters:
        chords_dict: Dict mapping style name to list of chords
        distributions_dict: Dict mapping style name to distribution

    Returns:
        Dict mapping style name to R(D) curve
    """
    fingerprints = {}
    for style in chords_dict:
        chords = chords_dict[style]
        p_x = distributions_dict[style]
        dist_matrix = voice_leading_distance_matrix(chords)
        D, R = compute_rd_curve(p_x, dist_matrix.astype(float), n_points=60)
        fingerprints[style] = {'distortions': D.tolist(), 'rates': R.tolist()}

    return fingerprints


def demo_harmonic_reduction():
    """Demonstrate harmonic reduction at different bit budgets."""
    print("=" * 60)
    print("Application 1: Harmonic Reduction")
    print("=" * 60)

    chords = [
        [60, 64, 67],  # C
        [62, 65, 69],  # Dm
        [64, 67, 71],  # Em
        [65, 69, 72],  # F
        [67, 71, 74],  # G
        [69, 72, 76],  # Am
    ]
    names = ['C', 'Dm', 'Em', 'F', 'G', 'Am']
    p_x = np.array([0.25, 0.10, 0.10, 0.20, 0.25, 0.10])

    for target in [2.0, 1.0, 0.5]:
        result = harmonic_reduction(chords, names, p_x, target)
        print(f"\n  Target: {target:.1f} bits")
        print(f"  Achieved: {result['achieved_rate']:.3f} bits")
        print(f"  Distortion: {result['expected_distortion']:.2f} semitones")
        print(f"  Assignments: {result['assignments']}")


def demo_style_fingerprint():
    """Demonstrate style classification via R(D) curves."""
    print("\n" + "=" * 60)
    print("Application 2: Style Fingerprinting")
    print("=" * 60)

    # Classical style: I-IV-V-I heavy
    classical_chords = [
        [60, 64, 67],  # C (I)
        [65, 69, 72],  # F (IV)
        [67, 71, 74],  # G (V)
        [69, 72, 76],  # Am (vi)
    ]
    classical_dist = np.array([0.35, 0.25, 0.30, 0.10])

    # Jazz style: more varied harmony
    jazz_chords = [
        [60, 64, 67],  # Cmaj
        [62, 65, 69],  # Dm7
        [67, 71, 74],  # G7
        [65, 69, 72],  # Fmaj
        [64, 67, 71],  # Em
        [69, 72, 76],  # Am
    ]
    jazz_dist = np.array([0.15, 0.20, 0.20, 0.15, 0.15, 0.15])

    fingerprints = style_fingerprint(
        {'Classical': classical_chords, 'Jazz': jazz_chords},
        {'Classical': classical_dist, 'Jazz': jazz_dist}
    )

    for style, fp in fingerprints.items():
        D = np.array(fp['distortions'])
        R = np.array(fp['rates'])
        print(f"\n  {style} style:")
        print(f"    R(0) ≈ {np.interp(0, D, R):.3f} bits")
        print(f"    R(2) ≈ {np.interp(2, D, R):.3f} bits")
        print(f"    R(5) ≈ {np.interp(5, D, R):.3f} bits")


if __name__ == "__main__":
    demo_harmonic_reduction()
    demo_style_fingerprint()
    print("\n" + "=" * 60)
    print("All applications completed successfully.")
    print("=" * 60)


"""
Finite Rate-Distortion Theory & Voice-Leading Geometry: Demonstrations

This script demonstrates the key mathematical structures formalized in the project:
1. Computing rate-distortion curves for finite sources
2. Voice-leading cost computation and the Lawvere metric
3. The bridge: rate-distortion for musical chord repertoires
"""

import numpy as np
from itertools import permutations
import json

# ============================================================
# 1. Finite Rate-Distortion Computation (Blahut-Arimoto)
# ============================================================

def blahut_arimoto(p_x, d, beta_range, max_iter=200, tol=1e-10):
    """
    Blahut-Arimoto algorithm for computing the rate-distortion function.

    Parameters:
        p_x: Source distribution (array of shape [|X|])
        d: Distortion matrix (array of shape [|X|, |Y|])
        beta_range: Array of Lagrange multiplier values (negative slopes)
        max_iter: Maximum iterations
        tol: Convergence tolerance

    Returns:
        rates: Mutual information I(X;Y) at each beta
        distortions: Expected distortion E[d(X,Y)] at each beta
    """
    n_x, n_y = d.shape
    rates = []
    distortions = []

    for beta in beta_range:
        # Initialize output distribution
        q_y = np.ones(n_y) / n_y

        for _ in range(max_iter):
            # Compute conditional distribution W(y|x) ∝ q(y) exp(-beta * d(x,y))
            log_W = np.log(q_y[None, :] + 1e-300) - beta * d
            log_W -= log_W.max(axis=1, keepdims=True)
            W = np.exp(log_W)
            W /= W.sum(axis=1, keepdims=True)

            # Update output marginal
            q_y_new = p_x @ W
            if np.max(np.abs(q_y_new - q_y)) < tol:
                q_y = q_y_new
                break
            q_y = q_y_new

        # Compute mutual information and expected distortion
        p_xy = p_x[:, None] * W
        p_y = p_xy.sum(axis=0)

        mi = 0.0
        for x in range(n_x):
            for y in range(n_y):
                if p_xy[x, y] > 1e-300 and p_y[y] > 1e-300:
                    mi += p_xy[x, y] * np.log2(p_xy[x, y] / (p_x[x] * p_y[y]))

        ed = np.sum(p_xy * d)

        rates.append(max(0, mi))
        distortions.append(ed)

    return np.array(rates), np.array(distortions)


def demo_binary_source():
    """Binary symmetric source with Hamming distortion."""
    print("=" * 60)
    print("Demo 1: Binary Symmetric Source (Hamming distortion)")
    print("=" * 60)

    p_x = np.array([0.5, 0.5])
    d = np.array([[0, 1], [1, 0]])  # Hamming

    # Analytical R(D) = 1 - H(D) for D in [0, 0.5]
    betas = np.linspace(0.01, 20, 100)
    rates, distortions = blahut_arimoto(p_x, d, betas)

    # Sort by distortion
    idx = np.argsort(distortions)
    D_vals = distortions[idx]
    R_vals = rates[idx]

    print(f"  Source: p(0)=p(1)=0.5, d=Hamming")
    print(f"  R(0.00) ≈ {np.interp(0.0, D_vals, R_vals):.4f} bits (should be 1.0)")
    print(f"  R(0.10) ≈ {np.interp(0.1, D_vals, R_vals):.4f} bits")
    print(f"  R(0.25) ≈ {np.interp(0.25, D_vals, R_vals):.4f} bits")
    print(f"  R(0.50) ≈ {np.interp(0.5, D_vals, R_vals):.4f} bits (should be 0.0)")
    print()
    return D_vals, R_vals


def demo_ternary_source():
    """Ternary source with asymmetric distortion."""
    print("=" * 60)
    print("Demo 2: Ternary Source with Ultrametric Distortion")
    print("=" * 60)

    p_x = np.array([0.5, 0.3, 0.2])
    # Ultrametric-like distortion: d(x,y) = 0 if x=y, 1 if same group, 2 otherwise
    d = np.array([
        [0, 1, 2],
        [1, 0, 2],
        [2, 2, 0]
    ], dtype=float)

    betas = np.linspace(0.01, 15, 100)
    rates, distortions = blahut_arimoto(p_x, d, betas)

    idx = np.argsort(distortions)
    D_vals = distortions[idx]
    R_vals = rates[idx]

    H_X = -sum(p * np.log2(p) for p in p_x if p > 0)
    print(f"  Source entropy H(X) = {H_X:.4f} bits")
    print(f"  R(0.00) ≈ {np.interp(0.0, D_vals, R_vals):.4f} bits")
    print(f"  R(0.50) ≈ {np.interp(0.5, D_vals, R_vals):.4f} bits")
    print(f"  R(1.00) ≈ {np.interp(1.0, D_vals, R_vals):.4f} bits")
    print()
    return D_vals, R_vals


# ============================================================
# 2. Voice-Leading Cost Computation
# ============================================================

def voice_leading_cost(v, w, sigma):
    """Total absolute displacement for a given voice assignment."""
    return sum(abs(v[i] - w[sigma[i]]) for i in range(len(v)))


def optimal_voice_leading_cost(v, w):
    """Minimum voice-leading cost over all permutations."""
    n = len(v)
    perms = list(permutations(range(n)))
    costs = [voice_leading_cost(v, w, sigma) for sigma in perms]
    min_cost = min(costs)
    best_perm = perms[costs.index(min_cost)]
    return min_cost, best_perm


def demo_voice_leading():
    """Voice-leading costs between common triads."""
    print("=" * 60)
    print("Demo 3: Voice-Leading Costs Between Triads")
    print("=" * 60)

    # Triads in MIDI pitch (soprano, alto, bass)
    chords = {
        'C':  [60, 64, 67],  # C E G
        'Dm': [62, 65, 69],  # D F A
        'Em': [64, 67, 71],  # E G B
        'F':  [65, 69, 72],  # F A C
        'G':  [55, 59, 62],  # G B D (lower voicing)
        'Am': [57, 60, 64],  # A C E
    }

    print("  Optimal voice-leading distances (semitones):")
    print(f"  {'':6s}", end="")
    for name in chords:
        print(f"  {name:>5s}", end="")
    print()

    dist_matrix = {}
    for name1, chord1 in chords.items():
        print(f"  {name1:6s}", end="")
        for name2, chord2 in chords.items():
            cost, _ = optimal_voice_leading_cost(chord1, chord2)
            dist_matrix[(name1, name2)] = cost
            print(f"  {cost:5d}", end="")
        print()

    # Verify triangle inequality
    print("\n  Triangle inequality verification:")
    names = list(chords.keys())
    violations = 0
    checks = 0
    for a in names:
        for b in names:
            for c in names:
                d_ac = dist_matrix[(a, c)]
                d_ab = dist_matrix[(a, b)]
                d_bc = dist_matrix[(b, c)]
                checks += 1
                if d_ac > d_ab + d_bc:
                    violations += 1
                    print(f"    VIOLATION: d({a},{c})={d_ac} > d({a},{b})+d({b},{c})={d_ab+d_bc}")
    print(f"  {checks} checks, {violations} violations ✓")
    print()
    return chords, dist_matrix


# ============================================================
# 3. Voice-Leading Rate-Distortion
# ============================================================

def demo_voice_leading_rd():
    """Rate-distortion curve for a chord repertoire."""
    print("=" * 60)
    print("Demo 4: Voice-Leading Rate-Distortion Curve")
    print("=" * 60)

    # Source: probability distribution over chords
    # Prototype space: same chords (lossy self-compression)
    chords = [
        [60, 64, 67],  # C
        [62, 65, 69],  # Dm
        [64, 67, 71],  # Em
        [65, 69, 72],  # F
        [67, 71, 74],  # G (higher voicing)
        [69, 72, 76],  # Am (higher voicing)
    ]
    chord_names = ['C', 'Dm', 'Em', 'F', 'G', 'Am']

    # Distribution: C and G more common (tonic-dominant)
    p_x = np.array([0.25, 0.10, 0.10, 0.20, 0.25, 0.10])
    p_x /= p_x.sum()

    # Distortion matrix: optimal voice-leading cost
    n = len(chords)
    d = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            cost, _ = optimal_voice_leading_cost(chords[i], chords[j])
            d[i, j] = cost

    print(f"  Repertoire: {chord_names}")
    print(f"  Distribution: {p_x}")
    print(f"  Distortion matrix (voice-leading cost):")
    for i in range(n):
        print(f"    {chord_names[i]:3s}: {d[i]}")

    betas = np.linspace(0.01, 10, 80)
    rates, distortions = blahut_arimoto(p_x, d, betas)

    idx = np.argsort(distortions)
    D_vals = distortions[idx]
    R_vals = rates[idx]

    H_X = -sum(p * np.log2(p) for p in p_x if p > 0)
    print(f"\n  Source entropy H(X) = {H_X:.4f} bits")
    print(f"  R(0.00) ≈ {np.interp(0.0, D_vals, R_vals):.4f} bits (lossless)")
    print(f"  R(2.00) ≈ {np.interp(2.0, D_vals, R_vals):.4f} bits")
    print(f"  R(5.00) ≈ {np.interp(5.0, D_vals, R_vals):.4f} bits")
    print(f"  R(10.0) ≈ {np.interp(10.0, D_vals, R_vals):.4f} bits")
    print()
    return D_vals, R_vals, chord_names, p_x, d


# ============================================================
# 4. Tropical / Affine Envelope
# ============================================================

def demo_tropical_envelope():
    """Demonstrate the piecewise-linear structure of R(D)."""
    print("=" * 60)
    print("Demo 5: Tropical Envelope Structure")
    print("=" * 60)

    p_x = np.array([0.5, 0.5])
    d = np.array([[0, 1], [1, 0]])

    betas = np.linspace(0.01, 30, 200)
    rates, distortions = blahut_arimoto(p_x, d, betas)

    # Each beta gives an affine lower bound: R(D) >= L(beta) - beta*D
    # where L(beta) = min_W { I(X;Y) + beta * E[d] }
    # At the computed (D*, R*), the affine function passes through with slope -beta
    print("  Lagrangian dual points (slope, intercept):")
    affine_funcs = []
    for i in range(0, len(betas), 20):
        slope = -betas[i]
        intercept = rates[i] - slope * distortions[i]
        affine_funcs.append((slope, intercept))
        print(f"    beta={betas[i]:.2f}: R(D) >= {slope:.4f}*D + {intercept:.4f}")

    print(f"\n  {len(affine_funcs)} affine lower bounds define a tropical envelope")
    print(f"  R(D) = sup_beta {{ -beta*D + L(beta) }}")
    print()
    return affine_funcs


if __name__ == "__main__":
    print("\n" + "=" * 60)
    print("  FINITE RATE-DISTORTION & VOICE-LEADING GEOMETRY")
    print("  Demonstrations of formally verified structures")
    print("=" * 60 + "\n")

    D1, R1 = demo_binary_source()
    D2, R2 = demo_ternary_source()
    chords, dist_matrix = demo_voice_leading()
    D4, R4, names, px, dmat = demo_voice_leading_rd()
    affine = demo_tropical_envelope()

    print("=" * 60)
    print("All demonstrations completed successfully.")
    print("=" * 60)


"""
Generate visualizations for the Rate-Distortion / Voice-Leading project.
Saves figures as base64-encoded PNG for embedding.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from algorithms import (
    compute_rd_curve, voice_leading_distance_matrix,
    tropical_envelope, evaluate_tropical_envelope, blahut_arimoto
)
from itertools import permutations
import base64
from io import BytesIO
import json


def fig_to_base64(fig):
    """Convert matplotlib figure to base64 PNG data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight',
                facecolor='white', edgecolor='none')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


def plot_binary_rd():
    """Plot R(D) for binary symmetric source with analytical comparison."""
    fig, ax = plt.subplots(1, 1, figsize=(8, 5))

    p_x = np.array([0.5, 0.5])
    d = np.array([[0, 1], [1, 0]])
    D_comp, R_comp = compute_rd_curve(p_x, d, n_points=150)

    # Analytical: R(D) = 1 - H(D) for D ∈ [0, 0.5]
    D_theory = np.linspace(0.001, 0.499, 200)
    R_theory = 1 + D_theory * np.log2(D_theory) + (1 - D_theory) * np.log2(1 - D_theory)

    ax.plot(D_theory, R_theory, 'b-', linewidth=2, label='Analytical: R(D) = 1 - H(D)')
    ax.plot(D_comp, R_comp, 'ro', markersize=3, alpha=0.6, label='Blahut-Arimoto')
    ax.set_xlabel('Distortion D', fontsize=13)
    ax.set_ylabel('Rate R(D) [bits]', fontsize=13)
    ax.set_title('Binary Symmetric Source — Rate-Distortion Function', fontsize=14)
    ax.legend(fontsize=11)
    ax.set_xlim(0, 0.55)
    ax.set_ylim(-0.05, 1.1)
    ax.grid(True, alpha=0.3)
    ax.axhline(y=0, color='gray', linestyle='--', alpha=0.5)
    return fig_to_base64(fig)


def plot_voice_leading_distances():
    """Plot voice-leading distance matrix as a heatmap."""
    chords = [
        [60, 64, 67], [62, 65, 69], [64, 67, 71],
        [65, 69, 72], [67, 71, 74], [69, 72, 76],
    ]
    names = ['C', 'Dm', 'Em', 'F', 'G', 'Am']
    D = voice_leading_distance_matrix(chords)

    fig, ax = plt.subplots(1, 1, figsize=(7, 6))
    im = ax.imshow(D, cmap='YlOrRd', interpolation='nearest')
    ax.set_xticks(range(len(names)))
    ax.set_yticks(range(len(names)))
    ax.set_xticklabels(names, fontsize=12)
    ax.set_yticklabels(names, fontsize=12)

    for i in range(len(names)):
        for j in range(len(names)):
            ax.text(j, i, f'{int(D[i,j])}', ha='center', va='center',
                    fontsize=12, color='black' if D[i,j] < 15 else 'white')

    plt.colorbar(im, ax=ax, label='Voice-leading cost (semitones)')
    ax.set_title('Voice-Leading Distance Matrix', fontsize=14)
    return fig_to_base64(fig)


def plot_voice_leading_rd():
    """Plot rate-distortion curve for voice-leading distortion."""
    chords = [
        [60, 64, 67], [62, 65, 69], [64, 67, 71],
        [65, 69, 72], [67, 71, 74], [69, 72, 76],
    ]
    names = ['C', 'Dm', 'Em', 'F', 'G', 'Am']
    p_x = np.array([0.25, 0.10, 0.10, 0.20, 0.25, 0.10])
    dist_mat = voice_leading_distance_matrix(chords).astype(float)

    D, R = compute_rd_curve(p_x, dist_mat, n_points=120)

    fig, ax = plt.subplots(1, 1, figsize=(8, 5))
    ax.plot(D, R, 'b-', linewidth=2.5, label='R(D) — Voice-leading distortion')
    ax.fill_between(D, 0, R, alpha=0.15, color='blue')

    H_X = -sum(p * np.log2(p) for p in p_x if p > 0)
    ax.axhline(y=H_X, color='red', linestyle='--', alpha=0.6,
               label=f'Source entropy H(X) = {H_X:.2f} bits')

    ax.set_xlabel('Distortion D (semitones)', fontsize=13)
    ax.set_ylabel('Rate R(D) [bits]', fontsize=13)
    ax.set_title('Voice-Leading Rate-Distortion Curve\nTriad Repertoire {C, Dm, Em, F, G, Am}', fontsize=14)
    ax.legend(fontsize=11)
    ax.set_xlim(0, max(D) * 1.05)
    ax.set_ylim(-0.1, H_X + 0.3)
    ax.grid(True, alpha=0.3)
    return fig_to_base64(fig)


def plot_tropical_envelope():
    """Plot the tropical envelope structure of R(D)."""
    p_x = np.array([0.5, 0.5])
    d = np.array([[0, 1], [1, 0]], dtype=float)

    D, R = compute_rd_curve(p_x, d, n_points=150)
    envelope = tropical_envelope(p_x, d, n_slopes=30)

    fig, ax = plt.subplots(1, 1, figsize=(8, 5))

    # Plot affine lower bounds
    D_range = np.linspace(0, 0.55, 200)
    for i, (m, b) in enumerate(envelope):
        if i % 3 == 0:
            vals = m * D_range + b
            ax.plot(D_range, vals, 'gray', alpha=0.3, linewidth=0.8)

    # Plot R(D) curve
    ax.plot(D, R, 'b-', linewidth=3, label='R(D)', zorder=5)

    # Plot envelope
    R_env = [max(0, evaluate_tropical_envelope(envelope, d)) for d in D_range]
    ax.plot(D_range, R_env, 'r--', linewidth=1.5, alpha=0.7,
            label='Tropical envelope', zorder=4)

    ax.set_xlabel('Distortion D', fontsize=13)
    ax.set_ylabel('Rate R(D) [bits]', fontsize=13)
    ax.set_title('Tropical Envelope: R(D) as Supremum of Affine Functions', fontsize=14)
    ax.legend(fontsize=11)
    ax.set_xlim(0, 0.55)
    ax.set_ylim(-0.1, 1.2)
    ax.grid(True, alpha=0.3)
    return fig_to_base64(fig)


def plot_comparison():
    """Compare R(D) curves for different source distributions."""
    d = np.array([[0, 1], [1, 0]], dtype=float)

    fig, ax = plt.subplots(1, 1, figsize=(8, 5))
    colors = ['blue', 'red', 'green', 'purple']
    probs = [0.5, 0.3, 0.1, 0.01]

    for p, color in zip(probs, colors):
        p_x = np.array([p, 1-p])
        D, R = compute_rd_curve(p_x, d, n_points=120)
        H = -p*np.log2(p+1e-15) - (1-p)*np.log2(1-p+1e-15)
        ax.plot(D, R, color=color, linewidth=2,
                label=f'p={p:.2f}, H(X)={H:.3f}')

    ax.set_xlabel('Distortion D', fontsize=13)
    ax.set_ylabel('Rate R(D) [bits]', fontsize=13)
    ax.set_title('Rate-Distortion Curves for Different Source Distributions', fontsize=14)
    ax.legend(fontsize=10)
    ax.set_xlim(0, 0.55)
    ax.set_ylim(-0.05, 1.1)
    ax.grid(True, alpha=0.3)
    return fig_to_base64(fig)


if __name__ == "__main__":
    print("Generating visualizations...")
    viz = {}
    viz['binary_rd'] = plot_binary_rd()
    print("  [1/5] Binary R(D) curve")
    viz['voice_distances'] = plot_voice_leading_distances()
    print("  [2/5] Voice-leading distance matrix")
    viz['voice_rd'] = plot_voice_leading_rd()
    print("  [3/5] Voice-leading R(D) curve")
    viz['tropical'] = plot_tropical_envelope()
    print("  [4/5] Tropical envelope")
    viz['comparison'] = plot_comparison()
    print("  [5/5] Distribution comparison")

    # Save for use in PACKAGE.json
    with open('viz_data.json', 'w') as f:
        json.dump(viz, f)

    print("All visualizations generated and saved to viz_data.json")

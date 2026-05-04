"""
Tropical Satake Beatpath Robustness — Interactive Demo
======================================================

This script demonstrates the formalized theorems with concrete numerical examples:
1. Computing beatpath strengths via max-min closure (Floyd-Warshall style)
2. Identifying unique beatpath (Schulze) winners
3. Verifying 1-Lipschitz stability under margin perturbation
4. Computing robustness certificates (maximum tolerable perturbation)

The mathematics is verified in Lean 4; this demo makes it tangible.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from itertools import product

# ─────────────────────────────────────────────────────────
# Core algorithms (matching the Lean definitions exactly)
# ─────────────────────────────────────────────────────────

def widemax_step(m, p):
    """One step of max-min closure on n×n margin matrix."""
    n = m.shape[0]
    result = np.copy(p)
    for i in range(n):
        for j in range(n):
            for k in range(n):
                result[i, j] = max(result[i, j], min(p[i, k], m[k, j]))
    return result


def beatpath_iter(m, t):
    """Iterate max-min closure t times."""
    p = np.copy(m)
    for _ in range(t):
        p = widemax_step(m, p)
    return p


def beatpath_strength(m):
    """Compute beatpath strength matrix (n iterations for n×n matrix)."""
    return beatpath_iter(m, m.shape[0])


def is_beatpath_winner(bp, c):
    """Check if candidate c is a beatpath winner."""
    n = bp.shape[0]
    for d in range(n):
        if d != c and bp[c, d] <= bp[d, c]:
            return False
    return True


def beatpath_gap(bp, c):
    """Compute the decisive beatpath gap for candidate c."""
    n = bp.shape[0]
    gaps = []
    for d in range(n):
        if d != c:
            gaps.append(bp[c, d] - bp[d, c])
    return min(gaps) if gaps else float('inf')


def score_margin(H):
    """Margin matrix from score vector: m[i,j] = H[i] - H[j]."""
    n = len(H)
    return np.array([[H[i] - H[j] for j in range(n)] for i in range(n)], dtype=float)


# ─────────────────────────────────────────────────────────
# Demo 1: Basic Beatpath Winner Computation
# ─────────────────────────────────────────────────────────

def demo_basic():
    print("=" * 65)
    print("DEMO 1: Basic Beatpath Winner Computation")
    print("=" * 65)

    # Hecke scores for 3 candidates
    H = np.array([5.0, 3.0, 1.0])
    print(f"\nHecke scores: H = {H}")

    m = score_margin(H)
    print(f"\nPairwise margin matrix (m[i,j] = H[i] - H[j]):")
    print(m)

    bp = beatpath_strength(m)
    print(f"\nBeatpath strength matrix:")
    print(bp)

    for c in range(3):
        winner = is_beatpath_winner(bp, c)
        gap = beatpath_gap(bp, c)
        status = "✓ WINNER" if winner else "✗"
        print(f"  Candidate {c}: {status}, gap = {gap:.4f}")

    print()


# ─────────────────────────────────────────────────────────
# Demo 2: Cyclic Margins (Condorcet Paradox Resolution)
# ─────────────────────────────────────────────────────────

def demo_cyclic():
    print("=" * 65)
    print("DEMO 2: Cyclic Margins — Schulze Resolves Condorcet Paradox")
    print("=" * 65)

    # A margin matrix with a cycle: 0 > 1 > 2 > 0
    # but with different strengths
    m = np.array([
        [ 0.0,  3.0, -1.0],
        [-3.0,  0.0,  5.0],
        [ 1.0, -5.0,  0.0]
    ])

    print(f"\nMargin matrix (cyclic: 0→1 by 3, 1→2 by 5, 2→0 by 1):")
    print(m)

    bp = beatpath_strength(m)
    print(f"\nBeatpath strength matrix:")
    print(bp)

    print("\nAnalysis:")
    print(f"  Beatpath 0→1: direct margin 3, via 2: min(-1,-5)=-5 → strength = {bp[0,1]}")
    print(f"  Beatpath 1→0: direct margin -3, via 2: min(5,1)=1 → strength = {bp[1,0]}")
    print(f"  Beatpath 0→2: direct margin -1, via 1: min(3,5)=3 → strength = {bp[0,2]}")

    for c in range(3):
        winner = is_beatpath_winner(bp, c)
        gap = beatpath_gap(bp, c)
        status = "✓ WINNER" if winner else "✗"
        print(f"  Candidate {c}: {status}, gap = {gap:.4f}")

    print()


# ─────────────────────────────────────────────────────────
# Demo 3: 1-Lipschitz Stability Verification
# ─────────────────────────────────────────────────────────

def demo_lipschitz():
    print("=" * 65)
    print("DEMO 3: 1-Lipschitz Stability of Beatpath Closure")
    print("=" * 65)

    H = np.array([5.0, 3.0, 1.0])
    m = score_margin(H)
    bp = beatpath_strength(m)

    np.random.seed(42)
    num_trials = 1000
    epsilons = [0.1, 0.5, 1.0, 2.0]

    print(f"\nOriginal scores: {H}")
    print(f"Running {num_trials} random perturbation trials...")
    print(f"\n{'ε':>6} | {'max |Δbp|':>12} | {'≤ ε?':>6} | {'winner preserved?':>18}")
    print("-" * 50)

    for eps in epsilons:
        max_bp_diff = 0
        winner_preserved = 0
        original_winner = 0  # candidate 0 is winner for H = [5,3,1]

        for _ in range(num_trials):
            noise = np.random.uniform(-eps, eps, size=(3, 3))
            noise = noise - noise.T  # keep antisymmetric part for realism
            # But our theorem handles arbitrary perturbations, so:
            noise = np.random.uniform(-eps, eps, size=(3, 3))
            m_pert = m + noise

            # Check margin perturbation bound
            actual_eps = np.max(np.abs(m_pert - m))

            bp_pert = beatpath_strength(m_pert)
            bp_diff = np.max(np.abs(bp_pert - bp))
            max_bp_diff = max(max_bp_diff, bp_diff)

            if is_beatpath_winner(bp_pert, original_winner):
                winner_preserved += 1

        lipschitz_ok = "✓" if max_bp_diff <= eps + 1e-10 else "✗"
        pct = winner_preserved / num_trials * 100
        print(f"{eps:6.2f} | {max_bp_diff:12.6f} | {lipschitz_ok:>6} | {pct:6.1f}%")

    print()


# ─────────────────────────────────────────────────────────
# Demo 4: Robustness Certificate Computation
# ─────────────────────────────────────────────────────────

def demo_certificate():
    print("=" * 65)
    print("DEMO 4: Robustness Certificate — Certified Perturbation Radius")
    print("=" * 65)

    H = np.array([5.0, 2.5, 1.0])
    m = score_margin(H)
    bp = beatpath_strength(m)

    winner = None
    for c in range(3):
        if is_beatpath_winner(bp, c):
            winner = c
            break

    gap = beatpath_gap(bp, winner)
    certified_radius = gap / 2

    print(f"\nHecke scores: H = {H}")
    print(f"Beatpath winner: candidate {winner}")
    print(f"Decisive beatpath gap: γ = {gap:.4f}")
    print(f"Certified perturbation radius: ε < γ/2 = {certified_radius:.4f}")
    print(f"\nThis means: for ANY perturbation of the margin matrix with")
    print(f"|m'[i,j] - m[i,j]| ≤ ε < {certified_radius:.4f} for all i,j,")
    print(f"candidate {winner} remains the unique Schulze/beatpath winner.")
    print(f"\nThis is a FORMALLY VERIFIED guarantee (proved in Lean 4).")
    print()


# ─────────────────────────────────────────────────────────
# Demo 5: Visualization — Beatpath Robustness Landscape
# ─────────────────────────────────────────────────────────

def demo_visualization():
    print("=" * 65)
    print("DEMO 5: Visualization — Robustness Landscape")
    print("=" * 65)

    H_base = np.array([5.0, 3.0, 1.0])
    m_base = score_margin(H_base)
    bp_base = beatpath_strength(m_base)
    gap = beatpath_gap(bp_base, 0)
    cert_radius = gap / 2

    # Sweep perturbation magnitude and measure winner stability
    eps_values = np.linspace(0, 3.0, 60)
    trials_per_eps = 500
    np.random.seed(123)

    winner_rates = []
    max_bp_diffs = []

    for eps in eps_values:
        wins = 0
        max_diff = 0
        for _ in range(trials_per_eps):
            noise = np.random.uniform(-eps, eps, size=(3, 3))
            m_pert = m_base + noise
            bp_pert = beatpath_strength(m_pert)
            diff = np.max(np.abs(bp_pert - bp_base))
            max_diff = max(max_diff, diff)
            if is_beatpath_winner(bp_pert, 0):
                wins += 1
        winner_rates.append(wins / trials_per_eps)
        max_bp_diffs.append(max_diff)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Plot 1: Winner preservation rate
    ax1.plot(eps_values, winner_rates, 'b-', linewidth=2, label='Winner preservation rate')
    ax1.axvline(x=cert_radius, color='r', linestyle='--', linewidth=2,
                label=f'Certified radius γ/2 = {cert_radius:.2f}')
    ax1.axhline(y=1.0, color='gray', linestyle=':', alpha=0.5)
    ax1.fill_between(eps_values, 0, 1, where=np.array(eps_values) < cert_radius,
                     alpha=0.15, color='green', label='Certified safe zone')
    ax1.set_xlabel('Perturbation magnitude ε', fontsize=12)
    ax1.set_ylabel('Fraction of trials preserving winner', fontsize=12)
    ax1.set_title('Beatpath Winner Stability under Perturbation', fontsize=13)
    ax1.legend(fontsize=10)
    ax1.set_ylim(-0.05, 1.1)
    ax1.grid(True, alpha=0.3)

    # Plot 2: 1-Lipschitz verification
    ax2.plot(eps_values, max_bp_diffs, 'b-', linewidth=2, label='max |Δ beatpath|')
    ax2.plot(eps_values, eps_values, 'r--', linewidth=2, label='y = ε (Lipschitz bound)')
    ax2.set_xlabel('Perturbation magnitude ε', fontsize=12)
    ax2.set_ylabel('Maximum beatpath strength change', fontsize=12)
    ax2.set_title('1-Lipschitz Property of Max-Min Closure', fontsize=13)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('Bridges/GL3/TropicalSatake/beatpath_robustness.png', dpi=150, bbox_inches='tight')
    print(f"\nVisualization saved to beatpath_robustness.png")
    plt.close()

    # Plot 3: Tournament graph visualization
    fig, axes = plt.subplots(1, 3, figsize=(15, 4.5))
    scenarios = [
        ("Well-separated scores", np.array([5.0, 3.0, 1.0])),
        ("Close scores", np.array([3.0, 2.8, 2.5])),
        ("Adversarial (near-tie)", np.array([3.0, 2.95, 2.9])),
    ]

    for ax, (title, H) in zip(axes, scenarios):
        m = score_margin(H)
        bp = beatpath_strength(m)
        gap_val = beatpath_gap(bp, 0) if is_beatpath_winner(bp, 0) else None
        winner = None
        for c in range(3):
            if is_beatpath_winner(bp, c):
                winner = c
                gap_val = beatpath_gap(bp, c)
                break

        # Draw tournament
        angles = [np.pi/2, np.pi/2 + 2*np.pi/3, np.pi/2 + 4*np.pi/3]
        positions = [(np.cos(a), np.sin(a)) for a in angles]

        for i in range(3):
            color = 'gold' if i == winner else 'lightblue'
            circle = plt.Circle(positions[i], 0.18, color=color, ec='black', linewidth=2, zorder=5)
            ax.add_patch(circle)
            ax.text(positions[i][0], positions[i][1], f'{i}\n({H[i]:.1f})',
                    ha='center', va='center', fontsize=9, fontweight='bold', zorder=6)

        # Draw edges with beatpath strengths
        for i in range(3):
            for j in range(i+1, 3):
                if bp[i, j] > bp[j, i]:
                    # i dominates j
                    dx = positions[j][0] - positions[i][0]
                    dy = positions[j][1] - positions[i][1]
                    ax.annotate('', xy=(positions[j][0]-0.15*dx/np.sqrt(dx**2+dy**2),
                                        positions[j][1]-0.15*dy/np.sqrt(dx**2+dy**2)),
                               xytext=(positions[i][0]+0.15*dx/np.sqrt(dx**2+dy**2),
                                       positions[i][1]+0.15*dy/np.sqrt(dx**2+dy**2)),
                               arrowprops=dict(arrowstyle='->', color='darkblue', lw=2))
                    mid_x = (positions[i][0] + positions[j][0]) / 2
                    mid_y = (positions[i][1] + positions[j][1]) / 2
                    ax.text(mid_x + 0.12, mid_y + 0.08, f'{bp[i,j]:.1f}',
                            fontsize=8, color='darkblue')
                else:
                    dx = positions[i][0] - positions[j][0]
                    dy = positions[i][1] - positions[j][1]
                    ax.annotate('', xy=(positions[i][0]-0.15*dx/np.sqrt(dx**2+dy**2),
                                        positions[i][1]-0.15*dy/np.sqrt(dx**2+dy**2)),
                               xytext=(positions[j][0]+0.15*dx/np.sqrt(dx**2+dy**2),
                                       positions[j][1]+0.15*dy/np.sqrt(dx**2+dy**2)),
                               arrowprops=dict(arrowstyle='->', color='darkred', lw=2))

        cert = gap_val / 2 if gap_val and gap_val > 0 else 0
        ax.set_title(f'{title}\nγ={gap_val:.2f}, ε<{cert:.2f}' if gap_val else title, fontsize=11)
        ax.set_xlim(-1.5, 1.5)
        ax.set_ylim(-1.5, 1.5)
        ax.set_aspect('equal')
        ax.axis('off')

    plt.suptitle('Beatpath Tournaments with Robustness Certificates', fontsize=14, y=1.02)
    plt.tight_layout()
    plt.savefig('Bridges/GL3/TropicalSatake/tournament_graphs.png', dpi=150, bbox_inches='tight')
    print(f"Tournament visualization saved to tournament_graphs.png")
    plt.close()

    print()


# ─────────────────────────────────────────────────────────
# Demo 6: Application — Robust Ensemble Classifier
# ─────────────────────────────────────────────────────────

def demo_application():
    print("=" * 65)
    print("DEMO 6: Application — Robust Multiclass Ensemble Classifier")
    print("=" * 65)

    np.random.seed(7)
    n_models = 5
    n_classes = 3
    class_names = ["Cat", "Dog", "Bird"]

    # Simulate scores from multiple models
    true_scores = np.array([4.2, 3.1, 1.8])
    print(f"\nTrue underlying class scores: {dict(zip(class_names, true_scores))}")
    print(f"\nSimulating {n_models} noisy model predictions:")

    model_scores = []
    for i in range(n_models):
        noise = np.random.normal(0, 0.5, size=3)
        scores = true_scores + noise
        model_scores.append(scores)
        print(f"  Model {i+1}: {dict(zip(class_names, [f'{s:.2f}' for s in scores]))}")

    # Aggregate via pairwise beatpath
    avg_scores = np.mean(model_scores, axis=0)
    m = score_margin(avg_scores)
    bp = beatpath_strength(m)

    print(f"\nAggregated scores: {dict(zip(class_names, [f'{s:.2f}' for s in avg_scores]))}")

    winner = None
    for c in range(3):
        if is_beatpath_winner(bp, c):
            winner = c
            break

    gap = beatpath_gap(bp, winner)
    cert = gap / 2

    print(f"\nBeatpath winner: {class_names[winner]}")
    print(f"Decisive gap: γ = {gap:.4f}")
    print(f"Certified perturbation radius: ε < {cert:.4f}")
    print(f"\n→ The classification '{class_names[winner]}' is CERTIFIED ROBUST")
    print(f"  against any uniform margin perturbation up to {cert:.4f}.")
    print(f"  This is a machine-verified guarantee from our Lean 4 proof.")
    print()


if __name__ == "__main__":
    demo_basic()
    demo_cyclic()
    demo_lipschitz()
    demo_certificate()
    try:
        demo_visualization()
    except Exception as e:
        print(f"  (Visualization skipped: {e})")
    demo_application()

    print("=" * 65)
    print("All demos complete. See BeatpathRobustness.lean for formal proofs.")
    print("=" * 65)

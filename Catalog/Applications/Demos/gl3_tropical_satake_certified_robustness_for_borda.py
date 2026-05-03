"""
GL3 Tropical Satake Certified Robustness for Borda-Count Hecke Score Aggregation
=================================================================================

This demo illustrates the formally verified theorems from BordaRobustness.lean
with concrete numerical examples and visualizations.

Key results demonstrated:
1. Pairwise margin perturbation bounds (Theorem 1)
2. Weighted Borda Lipschitz control (Theorem 1b)
3. Weighted Borda winner certification (Theorem 2)
4. Pairwise sign stability (Theorem 3)
5. Thresholded Borda score invariance (Theorem 4)
6. Borda winner certification (Theorem 5)
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from itertools import combinations


# ============================================================
# Core definitions (matching Lean formalization)
# ============================================================

def pair_margin(S, i, j):
    """Pairwise margin: S[i] - S[j]"""
    return S[i] - S[j]


def weighted_borda(S, i):
    """Weighted Borda score: Ω_i(S) = Σ_{j≠i} (S_i - S_j)"""
    n = len(S)
    return sum(pair_margin(S, i, j) for j in range(n) if j != i)


def borda_score(S, i):
    """Thresholded Borda score: B_i(S) = Σ_{j≠i} 1[S_i > S_j]"""
    n = len(S)
    return sum(1 for j in range(n) if j != i and S[i] > S[j])


def strict_winner_weighted(S):
    """Return the strict weighted Borda winner, or None if tie."""
    n = len(S)
    scores = [weighted_borda(S, i) for i in range(n)]
    w = int(np.argmax(scores))
    if all(scores[j] < scores[w] for j in range(n) if j != w):
        return w
    return None


def strict_winner_borda(S):
    """Return the strict Borda winner, or None if tie."""
    n = len(S)
    scores = [borda_score(S, i) for i in range(n)]
    w = int(np.argmax(scores))
    if all(scores[j] < scores[w] for j in range(n) if j != w):
        return w
    return None


# ============================================================
# Structural identity verification
# ============================================================

def verify_structural_identity(S):
    """Verify: Ω_i = n·S_i - Σ_k S_k  and  Ω_i - Ω_j = n·(S_i - S_j)"""
    n = len(S)
    total = sum(S)
    print(f"  Score vector S = {S}")
    print(f"  n = {n}, Σ S_k = {total:.4f}")
    for i in range(n):
        omega_i = weighted_borda(S, i)
        formula = n * S[i] - total
        print(f"  Ω_{i} = {omega_i:.4f},  n·S_{i} - Σ S_k = {formula:.4f},  match: {np.isclose(omega_i, formula)}")
    for i, j in combinations(range(n), 2):
        diff = weighted_borda(S, i) - weighted_borda(S, j)
        formula = n * (S[i] - S[j])
        print(f"  Ω_{i} - Ω_{j} = {diff:.4f},  n·(S_{i}-S_{j}) = {formula:.4f},  match: {np.isclose(diff, formula)}")


# ============================================================
# Demo 1: Pairwise margin perturbation bound
# ============================================================

def demo_pair_margin_bound():
    """Demonstrate: |m(T,i,j) - m(S,i,j)| ≤ 2η"""
    print("=" * 70)
    print("DEMO 1: Pairwise Margin Perturbation Bound")
    print("  Theorem: |pairMargin(T,i,j) - pairMargin(S,i,j)| ≤ 2η")
    print("=" * 70)

    np.random.seed(42)
    S = np.array([3.0, 1.5, 0.5])
    eta = 0.3

    print(f"\n  Original scores S = {S}")
    print(f"  Perturbation bound η = {eta}")

    # Generate random perturbations
    n_trials = 10000
    max_diffs = []
    for _ in range(n_trials):
        delta = np.random.uniform(-eta, eta, size=3)
        T = S + delta
        for i, j in combinations(range(3), 2):
            diff = abs(pair_margin(T, i, j) - pair_margin(S, i, j))
            max_diffs.append(diff)

    print(f"\n  Over {n_trials} random perturbations:")
    print(f"  Max |Δm| observed: {max(max_diffs):.6f}")
    print(f"  Theoretical bound 2η: {2 * eta:.6f}")
    print(f"  Bound holds: {max(max_diffs) <= 2 * eta + 1e-10}")


# ============================================================
# Demo 2: Weighted Borda perturbation bound
# ============================================================

def demo_weighted_borda_bound():
    """Demonstrate: |Ω_i(T) - Ω_i(S)| ≤ 2(n-1)η"""
    print("\n" + "=" * 70)
    print("DEMO 2: Weighted Borda Perturbation Bound")
    print("  Theorem: |Ω_i(T) - Ω_i(S)| ≤ 2(n-1)η")
    print("=" * 70)

    np.random.seed(42)
    S = np.array([3.0, 1.5, 0.5])
    n = len(S)
    eta = 0.3
    bound = 2 * (n - 1) * eta

    print(f"\n  Original scores S = {S}")
    print(f"  n = {n}, η = {eta}")
    print(f"  Bound = 2·(n-1)·η = 2·{n-1}·{eta} = {bound}")

    n_trials = 10000
    max_diffs = [0.0] * n
    for _ in range(n_trials):
        delta = np.random.uniform(-eta, eta, size=n)
        T = S + delta
        for i in range(n):
            diff = abs(weighted_borda(T, i) - weighted_borda(S, i))
            max_diffs[i] = max(max_diffs[i], diff)

    for i in range(n):
        print(f"  Max |ΔΩ_{i}| observed: {max_diffs[i]:.6f}, bound: {bound:.6f}, holds: {max_diffs[i] <= bound + 1e-10}")


# ============================================================
# Demo 3: Weighted Borda winner certification
# ============================================================

def demo_weighted_winner_certification():
    """Demonstrate the 4(n-1)η margin threshold for winner preservation."""
    print("\n" + "=" * 70)
    print("DEMO 3: Weighted Borda Winner Certification")
    print("  Theorem: margin > 4(n-1)η ⟹ winner preserved")
    print("=" * 70)

    S = np.array([5.0, 2.0, 1.0])
    n = len(S)
    winner = strict_winner_weighted(S)
    print(f"\n  Scores S = {S}")
    print(f"  Weighted Borda scores: {[weighted_borda(S, i) for i in range(n)]}")
    print(f"  Winner: class {winner}")

    # Compute margins
    omega_w = weighted_borda(S, winner)
    for j in range(n):
        if j != winner:
            margin = omega_w - weighted_borda(S, j)
            print(f"  Ω_{winner} - Ω_{j} = {margin:.2f}")

    # Find certified radius
    min_margin = min(omega_w - weighted_borda(S, j) for j in range(n) if j != winner)
    eta_max = min_margin / (4 * (n - 1))
    print(f"\n  Minimum margin: {min_margin:.2f}")
    print(f"  Certified η threshold: {min_margin} / {4*(n-1)} = {eta_max:.4f}")

    # Verify empirically
    np.random.seed(123)
    eta_test = eta_max * 0.99  # Just under threshold
    n_trials = 50000
    winner_preserved = 0
    for _ in range(n_trials):
        delta = np.random.uniform(-eta_test, eta_test, size=n)
        T = S + delta
        if strict_winner_weighted(T) == winner:
            winner_preserved += 1

    print(f"\n  Testing with η = {eta_test:.4f} (99% of threshold):")
    print(f"  Winner preserved in {winner_preserved}/{n_trials} trials ({100*winner_preserved/n_trials:.1f}%)")


# ============================================================
# Demo 4: Pairwise sign stability
# ============================================================

def demo_sign_stability():
    """Demonstrate that large margins prevent sign flips."""
    print("\n" + "=" * 70)
    print("DEMO 4: Pairwise Sign Stability")
    print("  Theorem: 2η < m(S,i,j) ⟹ 0 < m(T,i,j)")
    print("=" * 70)

    S = np.array([5.0, 2.0, 1.0])
    eta = 0.4

    print(f"\n  Scores S = {S}, η = {eta}")
    print(f"  Threshold: 2η = {2*eta}")

    for i, j in combinations(range(3), 2):
        m = pair_margin(S, i, j)
        stable = abs(m) > 2 * eta
        print(f"  m({i},{j}) = {m:.1f}, |m| = {abs(m):.1f}, stable: {stable}")

    # Verify empirically
    np.random.seed(42)
    n_trials = 50000
    flips = 0
    for _ in range(n_trials):
        delta = np.random.uniform(-eta, eta, size=3)
        T = S + delta
        for i, j in combinations(range(3), 2):
            if pair_margin(S, i, j) > 2 * eta:
                if pair_margin(T, i, j) <= 0:
                    flips += 1
            elif pair_margin(S, i, j) < -2 * eta:
                if pair_margin(T, i, j) >= 0:
                    flips += 1

    print(f"\n  Sign flips observed (for stable pairs): {flips} / {n_trials} trials")


# ============================================================
# Demo 5: Borda score invariance
# ============================================================

def demo_borda_invariance():
    """Demonstrate that Borda scores are preserved under sufficient separation."""
    print("\n" + "=" * 70)
    print("DEMO 5: Thresholded Borda Score Invariance")
    print("  Theorem: ∀ i≠j, 2η < |m(S,i,j)| ⟹ B_i(T) = B_i(S)")
    print("=" * 70)

    S = np.array([5.0, 2.0, 0.5])
    n = len(S)

    # Find max η for which all pairwise margins are > 2η
    min_abs_margin = min(abs(pair_margin(S, i, j))
                         for i, j in combinations(range(n), 2))
    eta_max = min_abs_margin / 2
    eta = eta_max * 0.95

    print(f"\n  Scores S = {S}")
    print(f"  Borda scores: {[borda_score(S, i) for i in range(n)]}")
    print(f"  Min |margin|: {min_abs_margin:.2f}")
    print(f"  Max certified η: {eta_max:.4f}")
    print(f"  Testing η = {eta:.4f}")

    # Verify
    np.random.seed(42)
    n_trials = 50000
    score_changes = 0
    for _ in range(n_trials):
        delta = np.random.uniform(-eta, eta, size=n)
        T = S + delta
        for i in range(n):
            if borda_score(T, i) != borda_score(S, i):
                score_changes += 1

    print(f"  Borda score changes: {score_changes} / {n_trials*n} (should be 0)")

    # Show what happens beyond the threshold
    eta_beyond = eta_max * 1.5
    score_changes_beyond = 0
    for _ in range(n_trials):
        delta = np.random.uniform(-eta_beyond, eta_beyond, size=n)
        T = S + delta
        for i in range(n):
            if borda_score(T, i) != borda_score(S, i):
                score_changes_beyond += 1

    print(f"\n  Beyond threshold (η = {eta_beyond:.4f}):")
    print(f"  Borda score changes: {score_changes_beyond} / {n_trials*n}")


# ============================================================
# Demo 6: Borda winner certification
# ============================================================

def demo_borda_winner_certification():
    """Demonstrate the full Borda winner certification theorem."""
    print("\n" + "=" * 70)
    print("DEMO 6: Borda Winner Certification (Main Theorem)")
    print("  Theorem: strict Borda winner + pairwise separation ⟹ winner preserved")
    print("=" * 70)

    S = np.array([5.0, 2.0, 0.5])
    n = len(S)
    winner = strict_winner_borda(S)

    print(f"\n  Scores S = {S}")
    print(f"  Borda scores: {[borda_score(S, i) for i in range(n)]}")
    print(f"  Strict Borda winner: class {winner}")

    min_abs_margin = min(abs(pair_margin(S, i, j))
                         for i, j in combinations(range(n), 2))
    eta_certified = min_abs_margin / 2

    print(f"  Certified η radius: {eta_certified:.4f}")

    # Test at boundary
    np.random.seed(42)
    for frac in [0.5, 0.9, 0.99, 1.0, 1.1, 1.5, 2.0]:
        eta = eta_certified * frac
        n_trials = 20000
        preserved = sum(1 for _ in range(n_trials)
                       if strict_winner_borda(S + np.random.uniform(-eta, eta, size=n)) == winner)
        print(f"  η = {eta:.3f} ({frac:.0%} of cert.): winner preserved {preserved}/{n_trials} ({100*preserved/n_trials:.1f}%)")


# ============================================================
# Visualization: Certified Robustness Region
# ============================================================

def plot_certified_region():
    """Visualize the certified robustness region in score space."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # --- Panel 1: Weighted Borda ---
    ax = axes[0]
    S = np.array([5.0, 2.0, 1.0])
    n = len(S)
    winner = 0  # class 0 is the winner

    omega_w = weighted_borda(S, winner)
    min_margin = min(omega_w - weighted_borda(S, j) for j in range(n) if j != winner)
    eta_max_weighted = min_margin / (4 * (n - 1))

    # Sample perturbations at different η levels
    np.random.seed(42)
    eta_levels = [0.3, 0.6, eta_max_weighted * 0.99, eta_max_weighted * 1.5]
    colors = ['green', 'blue', 'orange', 'red']
    labels = ['η=0.3 (safe)', 'η=0.6 (safe)', f'η={eta_max_weighted*0.99:.2f} (boundary)',
              f'η={eta_max_weighted*1.5:.2f} (unsafe)']

    for eta, color, label in zip(eta_levels, colors, labels):
        winners = []
        for _ in range(2000):
            delta = np.random.uniform(-eta, eta, size=n)
            T = S + delta
            w = strict_winner_weighted(T)
            winners.append(w)

        preserved = sum(1 for w in winners if w == winner)
        ax.bar(labels.index(label), 100 * preserved / len(winners), color=color, alpha=0.7)

    ax.set_ylabel('Winner Preserved (%)')
    ax.set_title('Weighted Borda Winner Certification\n(4(n-1)η threshold)')
    ax.set_xticks(range(len(labels)))
    ax.set_xticklabels([f'η={e:.2f}' for e in eta_levels], rotation=15)
    ax.axhline(y=100, color='gray', linestyle='--', alpha=0.5)
    ax.set_ylim(0, 105)

    # --- Panel 2: Thresholded Borda ---
    ax = axes[1]
    S = np.array([5.0, 2.0, 0.5])
    min_abs_margin = min(abs(pair_margin(S, i, j))
                         for i, j in combinations(range(n), 2))
    eta_max_borda = min_abs_margin / 2

    eta_levels2 = [0.2, 0.5, eta_max_borda * 0.99, eta_max_borda * 1.5]
    colors2 = ['green', 'blue', 'orange', 'red']

    for idx, (eta, color) in enumerate(zip(eta_levels2, colors2)):
        winners = []
        for _ in range(2000):
            delta = np.random.uniform(-eta, eta, size=n)
            T = S + delta
            w = strict_winner_borda(T)
            winners.append(w)

        preserved = sum(1 for w in winners if w == winner)
        ax.bar(idx, 100 * preserved / len(winners), color=color, alpha=0.7)

    ax.set_ylabel('Winner Preserved (%)')
    ax.set_title('Thresholded Borda Winner Certification\n(2η pairwise separation threshold)')
    ax.set_xticks(range(len(eta_levels2)))
    ax.set_xticklabels([f'η={e:.2f}' for e in eta_levels2], rotation=15)
    ax.axhline(y=100, color='gray', linestyle='--', alpha=0.5)
    ax.set_ylim(0, 105)

    plt.tight_layout()
    plt.savefig('Bridges/borda_robustness_certification.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("\n  [Saved: Bridges/borda_robustness_certification.png]")


def plot_perturbation_landscape():
    """Visualize how scores and margins change under perturbation."""
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))

    S = np.array([5.0, 2.0, 0.5])
    n = len(S)
    eta = 0.5

    np.random.seed(42)
    n_trials = 5000

    # Panel 1: Score perturbation
    ax = axes[0]
    for trial in range(min(200, n_trials)):
        delta = np.random.uniform(-eta, eta, size=n)
        T = S + delta
        for i in range(n):
            ax.scatter(i, T[i], alpha=0.05, color=f'C{i}', s=10)
    for i in range(n):
        ax.scatter(i, S[i], color=f'C{i}', s=100, zorder=5, edgecolors='black',
                  label=f'Class {i}: S={S[i]:.1f}')
    ax.set_xlabel('Class')
    ax.set_ylabel('Score')
    ax.set_title(f'Score Perturbation (η={eta})')
    ax.legend()
    ax.set_xticks(range(n))

    # Panel 2: Pairwise margin distribution
    ax = axes[1]
    for i, j in combinations(range(n), 2):
        margins = []
        for _ in range(n_trials):
            delta = np.random.uniform(-eta, eta, size=n)
            T = S + delta
            margins.append(pair_margin(T, i, j))
        ax.hist(margins, bins=50, alpha=0.5, label=f'm({i},{j})')
        m_orig = pair_margin(S, i, j)
        ax.axvline(m_orig, color=f'C{list(combinations(range(n),2)).index((i,j))}',
                  linestyle='--', linewidth=2)

    ax.axvline(0, color='black', linewidth=2)
    ax.set_xlabel('Pairwise Margin')
    ax.set_ylabel('Count')
    ax.set_title(f'Margin Distribution (η={eta})')
    ax.legend()

    # Panel 3: Borda score stability
    ax = axes[2]
    etas = np.linspace(0.01, 2.0, 50)
    winner_rates = []
    for eta_val in etas:
        preserved = 0
        for _ in range(1000):
            delta = np.random.uniform(-eta_val, eta_val, size=n)
            T = S + delta
            if strict_winner_borda(T) == 0:
                preserved += 1
        winner_rates.append(preserved / 1000)

    min_abs_margin = min(abs(pair_margin(S, i, j))
                         for i, j in combinations(range(n), 2))
    eta_cert = min_abs_margin / 2

    ax.plot(etas, winner_rates, 'b-', linewidth=2)
    ax.axvline(eta_cert, color='red', linestyle='--', linewidth=2,
              label=f'Certified η = {eta_cert:.2f}')
    ax.axhline(1.0, color='gray', linestyle=':', alpha=0.5)
    ax.set_xlabel('Perturbation η')
    ax.set_ylabel('Winner Preservation Rate')
    ax.set_title('Borda Winner Stability vs. η')
    ax.legend()
    ax.set_ylim(-0.05, 1.1)

    plt.tight_layout()
    plt.savefig('Bridges/perturbation_landscape.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  [Saved: Bridges/perturbation_landscape.png]")


# ============================================================
# GL3 Application: Certified radius computation
# ============================================================

def demo_gl3_application():
    """Show how the theorems apply to a GL3 classifier scenario."""
    print("\n" + "=" * 70)
    print("APPLICATION: GL3 Tropical Satake Certified Radius")
    print("=" * 70)

    # Simulated GL3 tropical Satake scores for 3 classes
    S = np.array([4.2, 1.8, 0.7])
    n = len(S)
    K = 2.5  # Lipschitz constant from tropical Satake perturbation theorem

    print(f"\n  Class scores S = {S}")
    print(f"  Score Lipschitz constant K = {K}")
    print(f"  Number of classes n = {n}")

    # Weighted Borda certificate
    omega = [weighted_borda(S, i) for i in range(n)]
    print(f"\n  Weighted Borda scores: Ω = {[f'{x:.1f}' for x in omega]}")

    winner = 0
    min_margin_w = min(omega[winner] - omega[j] for j in range(n) if j != winner)
    eps_weighted = min_margin_w / (4 * (n - 1) * K)

    print(f"  Winner: class {winner}")
    print(f"  Min weighted margin: {min_margin_w:.2f}")
    print(f"  Certified ε (weighted): {min_margin_w:.2f} / (4·{n-1}·{K}) = {eps_weighted:.4f}")

    # Borda certificate
    min_abs_pair = min(abs(pair_margin(S, i, j))
                       for i, j in combinations(range(n), 2))
    eps_borda = min_abs_pair / (2 * K)

    print(f"\n  Min |pairwise margin|: {min_abs_pair:.2f}")
    print(f"  Certified ε (Borda): {min_abs_pair:.2f} / (2·{K}) = {eps_borda:.4f}")

    print(f"\n  Summary: Input perturbation ‖δ‖∞ ≤ ε is certified robust when:")
    print(f"    Weighted Borda: ε < {eps_weighted:.4f}")
    print(f"    Thresholded Borda: ε < {eps_borda:.4f}")

    # Structural identity
    print(f"\n  Structural identity verification:")
    print(f"    Ω_0 - Ω_1 = {omega[0]-omega[1]:.1f} = {n}·(S_0-S_1) = {n*(S[0]-S[1]):.1f} ✓")
    print(f"    Ω_0 - Ω_2 = {omega[0]-omega[2]:.1f} = {n}·(S_0-S_2) = {n*(S[0]-S[2]):.1f} ✓")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  GL3 Tropical Satake Certified Robustness for Borda-Count          ║")
    print("║  Hecke Score Aggregation — Numerical Demonstrations                ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")

    # Structural identity
    print("\n" + "=" * 70)
    print("STRUCTURAL IDENTITIES")
    print("  Ω_i = n·S_i - Σ S_k   and   Ω_i - Ω_j = n·(S_i - S_j)")
    print("=" * 70)
    verify_structural_identity(np.array([5.0, 2.0, 1.0]))

    # Run all demos
    demo_pair_margin_bound()
    demo_weighted_borda_bound()
    demo_weighted_winner_certification()
    demo_sign_stability()
    demo_borda_invariance()
    demo_borda_winner_certification()
    demo_gl3_application()

    # Visualizations
    print("\n" + "=" * 70)
    print("GENERATING VISUALIZATIONS")
    print("=" * 70)
    plot_certified_region()
    plot_perturbation_landscape()

    print("\n" + "=" * 70)
    print("ALL DEMOS COMPLETE")
    print("=" * 70)

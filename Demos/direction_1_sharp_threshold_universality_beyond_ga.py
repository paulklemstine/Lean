"""
Tropical Threshold Universality — Applications

Real-world applications of tropical margin theory:
1. Robust classification under adversarial noise
2. Network reliability assessment
3. Optimal assignment stability

Each application shows the tropical margin framework in action.
"""

import numpy as np
from typing import Dict, List, Tuple


def diag_ex_slack(W, i, j):
    return 2.0 * W[i, j] - W[i, i] - W[j, j]


def trop_margin(W):
    n = W.shape[0]
    if n < 2:
        return 0.0
    return min(diag_ex_slack(W, i, j)
               for i in range(n) for j in range(n) if i != j)


def entry_sup_norm(W):
    return float(np.max(np.abs(W)))


# ============================================================
# Application 1: Robust Classification
# ============================================================

def robust_classification_certificate(
    weight_matrix: np.ndarray,
    noise_budget: float
) -> Dict:
    """
    Certify robustness of a tropical classifier under adversarial noise.
    
    Given a weight matrix W and a noise budget ε, determine whether
    the classification (determined by the diagonal assignment) remains
    stable under any perturbation of norm ≤ ε.
    
    The certificate is based on:
        signalGap(W) ≥ 4ε → tropMargin(W + N) ≥ 0 for all ‖N‖∞ ≤ ε
    
    Returns:
        Dictionary with certification results
    
    Example:
        >>> W = np.array([[0, 5, 5], [5, 0, 5], [5, 5, 0]])
        >>> cert = robust_classification_certificate(W, 1.0)
        >>> cert['certified']
        True
    """
    margin = trop_margin(weight_matrix)
    max_tolerable_noise = margin / 4.0 if margin > 0 else 0.0
    certified = margin >= 4 * noise_budget
    
    n = weight_matrix.shape[0]
    # Find the weakest pair
    worst_margin = float('inf')
    worst_pair = (0, 1)
    for i in range(n):
        for j in range(n):
            if i != j:
                s = diag_ex_slack(weight_matrix, i, j)
                if s < worst_margin:
                    worst_margin = s
                    worst_pair = (i, j)
    
    return {
        'signal_gap': margin,
        'noise_budget': noise_budget,
        'max_tolerable_noise': max_tolerable_noise,
        'certified': certified,
        'safety_factor': margin / (4 * noise_budget) if noise_budget > 0 else float('inf'),
        'weakest_pair': worst_pair,
        'weakest_slack': worst_margin
    }


def adversarial_stress_test(
    weight_matrix: np.ndarray,
    noise_levels: np.ndarray,
    num_trials: int = 100,
    seed: int = 42
) -> Dict:
    """
    Empirically test classification stability under increasing noise.
    
    For each noise level ε, generate random perturbations ‖N‖∞ ≤ ε
    and check whether tropMargin(W + N) remains non-negative.
    
    Returns:
        Dictionary with empirical stability probabilities
    """
    rng = np.random.default_rng(seed)
    margin = trop_margin(weight_matrix)
    
    results = {
        'noise_levels': noise_levels,
        'stability_probs': [],
        'signal_gap': margin,
        'theoretical_threshold': margin / 4.0
    }
    
    for eps in noise_levels:
        stable_count = 0
        for _ in range(num_trials):
            N = eps * rng.uniform(-1, 1, weight_matrix.shape)
            if trop_margin(weight_matrix + N) >= 0:
                stable_count += 1
        results['stability_probs'].append(stable_count / num_trials)
    
    return results


# ============================================================
# Application 2: Network Reliability
# ============================================================

def network_reliability_margin(
    adjacency_weights: np.ndarray
) -> Dict:
    """
    Assess network reliability using tropical margin theory.
    
    The tropical margin of a weighted adjacency matrix measures
    the robustness of the network's "diagonal assignment" — the
    self-loop (local processing) preference over cross-connections.
    
    A positive margin means the network prefers local processing
    even under perturbations. The margin value quantifies the
    maximum tolerable link degradation.
    
    Args:
        adjacency_weights: Weighted adjacency matrix
    
    Returns:
        Reliability assessment dictionary
    """
    n = adjacency_weights.shape[0]
    margin = trop_margin(adjacency_weights)
    
    # Identify vulnerable links
    vulnerabilities = []
    for i in range(n):
        for j in range(n):
            if i != j:
                slack = diag_ex_slack(adjacency_weights, i, j)
                vulnerabilities.append({
                    'link': (i, j),
                    'slack': slack,
                    'criticality': 1.0 / (abs(slack) + 1e-10)
                })
    
    vulnerabilities.sort(key=lambda x: x['slack'])
    
    return {
        'margin': margin,
        'max_tolerable_degradation': margin / 4.0 if margin > 0 else 0.0,
        'stable': margin > 0,
        'most_vulnerable_links': vulnerabilities[:3],
        'n_nodes': n
    }


# ============================================================
# Application 3: Optimal Assignment Stability
# ============================================================

def assignment_stability_analysis(
    cost_matrix: np.ndarray,
    perturbation_bound: float
) -> Dict:
    """
    Analyze stability of optimal assignments under cost perturbations.
    
    Uses the ground state stability theorem: if the assignment gap
    exceeds 2δ and costs are perturbed by at most δ, the optimal
    assignment is preserved.
    
    In the tropical margin framework, the diagonal assignment is
    optimal when tropMargin > 0, and remains optimal under noise
    when signalGap ≥ 4 * noise_bound.
    
    Args:
        cost_matrix: n×n cost/score matrix
        perturbation_bound: Maximum entry-wise perturbation δ
    
    Returns:
        Stability analysis results
    """
    n = cost_matrix.shape[0]
    margin = trop_margin(cost_matrix)
    
    # The tropical margin directly measures assignment stability
    # Positive margin = diagonal assignment dominates
    max_safe_perturbation = margin / 4.0 if margin > 0 else 0.0
    
    return {
        'n': n,
        'tropical_margin': margin,
        'perturbation_bound': perturbation_bound,
        'max_safe_perturbation': max_safe_perturbation,
        'assignment_stable': margin >= 4 * perturbation_bound,
        'safety_margin': (margin / 4.0 - perturbation_bound) if margin > 0 else -perturbation_bound
    }


# ============================================================
# Application 4: Signal Detection in Noisy Channels
# ============================================================

def tropical_signal_detector(
    received_matrix: np.ndarray,
    expected_signal: np.ndarray,
    noise_variance_estimate: float
) -> Dict:
    """
    Tropical margin-based signal detection.
    
    Given a received matrix W = S + N where S is the expected signal
    and N is noise, determine whether the signal is detectable by
    checking if tropMargin(W) > 0.
    
    The threshold for detection is governed by √(log n), matching
    extreme-value theory for n² independent noise entries.
    
    Args:
        received_matrix: Observed matrix W = S + N
        expected_signal: Expected signal matrix S
        noise_variance_estimate: Estimated noise variance σ²
    
    Returns:
        Detection results
    """
    n = received_matrix.shape[0]
    sqrt_log_n = np.sqrt(np.log(n)) if n > 1 else 0.0
    
    margin_received = trop_margin(received_matrix)
    margin_signal = trop_margin(expected_signal)
    
    # Estimated noise matrix
    noise_estimate = received_matrix - expected_signal
    noise_norm = entry_sup_norm(noise_estimate)
    
    # Sub-Gaussian noise: ‖N‖∞ ~ σ√(2 log(n²)) = σ√(4 log n)
    expected_noise_scale = np.sqrt(noise_variance_estimate) * 2 * sqrt_log_n
    
    return {
        'n': n,
        'margin_received': margin_received,
        'margin_signal': margin_signal,
        'signal_detected': margin_received > 0,
        'noise_norm': noise_norm,
        'expected_noise_scale': expected_noise_scale,
        'signal_to_noise': margin_signal / (4 * noise_norm) if noise_norm > 0 else float('inf'),
        'sqrt_log_n': sqrt_log_n,
        'detection_threshold': 4 * expected_noise_scale
    }


if __name__ == "__main__":
    rng = np.random.default_rng(42)
    
    print("=" * 60)
    print("Application 1: Robust Classification")
    print("=" * 60)
    n = 4
    # Create a matrix with strong off-diagonal values (positive margin)
    W = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            W[i, j] = 5.0 if i != j else 0.0
    
    cert = robust_classification_certificate(W, 1.0)
    print(f"  Signal gap: {cert['signal_gap']:.2f}")
    print(f"  Max tolerable noise: {cert['max_tolerable_noise']:.2f}")
    print(f"  Certified for ε=1.0: {cert['certified']}")
    print(f"  Safety factor: {cert['safety_factor']:.2f}")
    print()
    
    print("=" * 60)
    print("Application 2: Network Reliability")
    print("=" * 60)
    # Communication network with self-loops (processing costs)
    # and link weights
    adj = np.array([
        [1.0, 4.0, 3.0],
        [4.0, 2.0, 5.0],
        [3.0, 5.0, 1.0]
    ])
    rel = network_reliability_margin(adj)
    print(f"  Margin: {rel['margin']:.2f}")
    print(f"  Stable: {rel['stable']}")
    print(f"  Max degradation: {rel['max_tolerable_degradation']:.2f}")
    if rel['most_vulnerable_links']:
        vl = rel['most_vulnerable_links'][0]
        print(f"  Most vulnerable link: {vl['link']} (slack={vl['slack']:.2f})")
    print()
    
    print("=" * 60)
    print("Application 3: Assignment Stability")
    print("=" * 60)
    cost = np.array([
        [0.0, 8.0, 8.0, 8.0],
        [8.0, 0.0, 8.0, 8.0],
        [8.0, 8.0, 0.0, 8.0],
        [8.0, 8.0, 8.0, 0.0]
    ])
    stab = assignment_stability_analysis(cost, 1.0)
    print(f"  Tropical margin: {stab['tropical_margin']:.2f}")
    print(f"  Max safe perturbation: {stab['max_safe_perturbation']:.2f}")
    print(f"  Stable under δ=1.0: {stab['assignment_stable']}")
    print()
    
    print("=" * 60)
    print("Application 4: Signal Detection")
    print("=" * 60)
    n = 6
    S = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            S[i, j] = 5.0 if i != j else 0.0
    N = 0.5 * rng.standard_normal((n, n))
    W = S + N
    det = tropical_signal_detector(W, S, 0.25)
    print(f"  Signal detected: {det['signal_detected']}")
    print(f"  Margin: {det['margin_received']:.3f}")
    print(f"  Signal-to-noise ratio: {det['signal_to_noise']:.3f}")
    print(f"  √(log n) = {det['sqrt_log_n']:.3f}")
    print()
    
    print("All applications demonstrated.")


"""
Tropical Threshold Universality — Demonstration Script

This script demonstrates the main theoretical results:
1. Computes tropMargin for random matrices from 4+ ensembles
2. Rescales by √(log n) to test universality
3. Plots empirical collapse curves
4. Includes heavy-tailed (Cauchy) counterexample

Usage:
    python demo.py
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from itertools import permutations


def diag_ex_slack(W, i, j):
    """Diagonal exchange slack: 2*W[i,j] - W[i,i] - W[j,j]."""
    return 2 * W[i, j] - W[i, i] - W[j, j]


def trop_margin(W):
    """Tropical margin: min_{i≠j} diagExSlack(W, i, j)."""
    n = W.shape[0]
    if n < 2:
        return 0.0
    margin = float('inf')
    for i in range(n):
        for j in range(n):
            if i != j:
                s = diag_ex_slack(W, i, j)
                if s < margin:
                    margin = s
    return margin


def signal_gap(S):
    """Signal gap = tropMargin(S)."""
    return trop_margin(S)


def entry_sup_norm(W):
    """Entry-wise sup norm: max_{i,j} |W[i,j]|."""
    return np.max(np.abs(W))


def mean_model(n, mu_diag, mu_off):
    """Mean model matrix with diagonal mu_diag, off-diagonal mu_off."""
    M = np.full((n, n), mu_off)
    np.fill_diagonal(M, mu_diag)
    return M


def generate_ensemble(n, ensemble_type, rng=None):
    """Generate an n×n random matrix from the specified ensemble.
    
    All ensembles produce centered, variance-1 entries (where applicable).
    """
    if rng is None:
        rng = np.random.default_rng()
    
    if ensemble_type == 'gaussian':
        return rng.standard_normal((n, n))
    elif ensemble_type == 'rademacher':
        return rng.choice([-1.0, 1.0], size=(n, n))
    elif ensemble_type == 'uniform':
        # Centered uniform on [-√3, √3] has variance 1
        return rng.uniform(-np.sqrt(3), np.sqrt(3), (n, n))
    elif ensemble_type == 'exponential':
        # Centered exponential: Exp(1) - 1, variance = 1
        return rng.exponential(1.0, (n, n)) - 1.0
    elif ensemble_type == 'cauchy':
        # Cauchy (heavy-tailed, NOT sub-Gaussian)
        return rng.standard_cauchy((n, n))
    else:
        raise ValueError(f"Unknown ensemble: {ensemble_type}")


def empirical_positive_probability(n, ensemble_type, signal_strength, 
                                    num_trials=500, rng=None):
    """Estimate P(tropMargin(S + N) ≥ 0) empirically.
    
    S = mean_model with mu_off - mu_diag = signal_strength/2
    N = random noise from ensemble
    """
    if rng is None:
        rng = np.random.default_rng()
    
    S = mean_model(n, 0.0, signal_strength / 2.0)
    count_positive = 0
    for _ in range(num_trials):
        N = generate_ensemble(n, ensemble_type, rng)
        W = S + N
        if trop_margin(W) >= 0:
            count_positive += 1
    return count_positive / num_trials


def demo_perturbation_stability():
    """Demonstrate Theorem: tropMargin(A+E) ≥ tropMargin(A) - 4‖E‖∞."""
    print("=" * 60)
    print("Demo 1: Perturbation Stability")
    print("=" * 60)
    
    rng = np.random.default_rng(42)
    n = 5
    A = rng.standard_normal((n, n))
    
    for delta in [0.1, 0.5, 1.0, 2.0]:
        E = delta * rng.uniform(-1, 1, (n, n))
        margin_A = trop_margin(A)
        margin_AE = trop_margin(A + E)
        bound = margin_A - 4 * entry_sup_norm(E)
        actual_diff = abs(margin_A - margin_AE)
        lipschitz_bound = 4 * entry_sup_norm(E)
        
        print(f"  δ={delta:.1f}: tropMargin(A)={margin_A:.3f}, "
              f"tropMargin(A+E)={margin_AE:.3f}, "
              f"lower bound={bound:.3f}, "
              f"|diff|={actual_diff:.3f} ≤ 4‖E‖∞={lipschitz_bound:.3f} ✓" 
              if actual_diff <= lipschitz_bound + 1e-10 else "VIOLATION!")
    print()


def demo_signal_dominance():
    """Demonstrate: signalGap(S) ≥ 4‖N‖∞ → tropMargin(S+N) ≥ 0."""
    print("=" * 60)
    print("Demo 2: Signal Dominance")
    print("=" * 60)
    
    rng = np.random.default_rng(42)
    n = 6
    
    for gap_factor in [0.5, 1.0, 2.0, 5.0, 10.0]:
        N = rng.standard_normal((n, n))
        noise_norm = entry_sup_norm(N)
        signal_strength = gap_factor * noise_norm
        S = mean_model(n, 0.0, signal_strength)
        sg = signal_gap(S)
        margin = trop_margin(S + N)
        
        dominated = sg >= 4 * noise_norm
        print(f"  gap_factor={gap_factor:.1f}: signalGap={sg:.3f}, "
              f"4‖N‖∞={4*noise_norm:.3f}, "
              f"dominated={'Yes' if dominated else 'No ':>3}, "
              f"margin={margin:.3f} {'≥ 0 ✓' if margin >= -1e-10 else '< 0'}")
    print()


def demo_ground_state_stability():
    """Demonstrate cross-domain: ground state stability under perturbation."""
    print("=" * 60)
    print("Demo 3: Ground State Stability (Cross-Domain)")
    print("=" * 60)
    
    rng = np.random.default_rng(42)
    states = 10
    
    for delta in [0.1, 0.5, 1.0, 2.0]:
        # Create energy landscape with state 0 as ground state
        E = rng.standard_normal(states)
        E[0] = np.max(E[1:]) + 2 * delta + 1.0  # gap ≥ 2δ
        
        # Perturb
        perturbation = rng.uniform(-delta, delta, states)
        E_prime = E + perturbation
        
        original_max = np.argmax(E)
        perturbed_max = np.argmax(E_prime)
        gap = E[0] - np.max(E[1:])
        
        print(f"  δ={delta:.1f}: gap={gap:.2f} ≥ 2δ={2*delta:.1f}, "
              f"original_max={original_max}, perturbed_max={perturbed_max} "
              f"{'✓ stable' if perturbed_max == 0 else '✗ shifted'}")
    print()


def demo_universality_collapse():
    """Demonstrate universality: empirical curves collapse after √(log n) scaling."""
    print("=" * 60)
    print("Demo 4: Universality Collapse")
    print("=" * 60)
    
    rng = np.random.default_rng(42)
    n = 8  # Small for speed
    scale = np.sqrt(np.log(n))
    
    ensembles = ['gaussian', 'rademacher', 'uniform', 'exponential', 'cauchy']
    
    # Sweep signal strength scaled by √(log n)
    scaled_strengths = np.linspace(-2, 6, 12)
    
    results = {}
    for ens in ensembles:
        probs = []
        for s in scaled_strengths:
            signal = s * scale
            p = empirical_positive_probability(n, ens, signal, num_trials=200, rng=rng)
            probs.append(p)
        results[ens] = probs
        print(f"  {ens:12s}: {['%.2f' % p for p in probs]}")
    
    print()
    print("  Sub-Gaussian ensembles (Gaussian, Rademacher, Uniform, Exponential)")
    print("  should show similar curves. Cauchy should differ significantly.")
    print()


def demo_telescoping():
    """Demonstrate the telescoping replacement bound."""
    print("=" * 60)
    print("Demo 5: Telescoping Replacement Bound")
    print("=" * 60)
    
    rng = np.random.default_rng(42)
    n = 5
    m = 10
    
    # Create a sequence of matrices by replacing entries one at a time
    W_start = rng.standard_normal((n, n))
    W_end = rng.standard_normal((n, n))
    
    # Linear interpolation
    margins = []
    for k in range(m + 1):
        t = k / m
        W_k = (1 - t) * W_start + t * W_end
        margins.append(trop_margin(W_k))
    
    # Step bounds
    step_bounds = []
    for k in range(m):
        step_bounds.append(abs(margins[k] - margins[k + 1]))
    
    total_diff = abs(margins[0] - margins[-1])
    sum_steps = sum(step_bounds)
    
    print(f"  n={n}, m={m} interpolation steps")
    print(f"  |tropMargin(W_0) - tropMargin(W_m)| = {total_diff:.4f}")
    print(f"  Σ|step differences|                  = {sum_steps:.4f}")
    print(f"  Triangle inequality: {total_diff:.4f} ≤ {sum_steps:.4f} ✓")
    print()


if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║     Tropical Threshold Universality — Demonstrations    ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()
    
    demo_perturbation_stability()
    demo_signal_dominance()
    demo_ground_state_stability()
    demo_universality_collapse()
    demo_telescoping()
    
    print("All demonstrations complete.")


"""
Visualization: Ground State Stability Under Perturbation

This script visualizes the cross-domain theorem connecting tropical margin
theory to zero-temperature statistical mechanics. It shows how the ground
state (energy maximizer) is preserved under bounded perturbation when the
energy gap is sufficiently large.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def simulate_ground_state_stability(num_states, gap, delta, num_trials, rng):
    """Simulate ground state stability for given gap and delta."""
    preserved = 0
    for _ in range(num_trials):
        # Random energy landscape with state 0 as ground state
        E = rng.standard_normal(num_states)
        E[0] = np.max(E[1:]) + gap
        
        # Perturbation
        pert = rng.uniform(-delta, delta, num_states)
        E_prime = E + pert
        
        if np.argmax(E_prime) == 0:
            preserved += 1
    return preserved / num_trials


# Parameters
rng = np.random.default_rng(42)
num_states = 20
num_trials = 500
delta = 1.0

fig, axes = plt.subplots(1, 3, figsize=(17, 5.5))

# Panel 1: Stability probability vs gap/delta ratio
ratios = np.linspace(0, 5, 30)
gaps = ratios * delta

probs = []
for gap in gaps:
    p = simulate_ground_state_stability(num_states, gap, delta, num_trials, rng)
    probs.append(p)

axes[0].plot(ratios, probs, 'b-o', markersize=4, linewidth=2)
axes[0].axvline(x=2.0, color='red', linestyle='--', linewidth=2, 
                label='Theorem threshold\n(gap = 2δ)', alpha=0.8)
axes[0].fill_between(ratios, 0, 1, where=np.array(ratios) >= 2.0,
                      alpha=0.1, color='green', label='Certified region')
axes[0].set_xlabel('Gap / δ ratio', fontsize=12)
axes[0].set_ylabel('P(ground state preserved)', fontsize=12)
axes[0].set_title('Ground State Stability', fontsize=13, fontweight='bold')
axes[0].legend(fontsize=10)
axes[0].grid(True, alpha=0.3)
axes[0].set_ylim(-0.05, 1.05)

# Panel 2: Energy landscape illustration
E_example = np.array([8.0, 3.0, 4.5, 2.0, 5.0, 1.5, 3.5, 2.5])
delta_ex = 1.0
pert = rng.uniform(-delta_ex, delta_ex, len(E_example))
E_perturbed = E_example + pert

x = np.arange(len(E_example))
width = 0.35

axes[1].bar(x - width/2, E_example, width, label='Original E(a)', 
            color='steelblue', alpha=0.8, edgecolor='navy')
axes[1].bar(x + width/2, E_perturbed, width, label="Perturbed E'(a)",
            color='coral', alpha=0.8, edgecolor='darkred')

# Mark gap
max_non_star = max(E_example[1:])
axes[1].annotate('', xy=(0, max_non_star), xytext=(0, E_example[0]),
                arrowprops=dict(arrowstyle='<->', color='green', lw=2))
axes[1].text(0.4, (E_example[0] + max_non_star) / 2, f'gap = {E_example[0] - max_non_star:.1f}',
            fontsize=10, color='green', fontweight='bold')

# Mark perturbation band
axes[1].axhline(y=E_example[0] - delta_ex, color='gray', linestyle=':', alpha=0.5)
axes[1].axhline(y=E_example[0] + delta_ex, color='gray', linestyle=':', alpha=0.5)

axes[1].set_xlabel('State index a', fontsize=12)
axes[1].set_ylabel('Energy E(a)', fontsize=12)
axes[1].set_title('Energy Landscape + Perturbation', fontsize=13, fontweight='bold')
axes[1].legend(fontsize=10)
axes[1].set_xticks(x)

# Panel 3: Scaling with number of states
state_counts = [5, 10, 20, 50, 100]
for gap_ratio in [1.0, 2.0, 3.0]:
    stability_probs = []
    for ns in state_counts:
        p = simulate_ground_state_stability(ns, gap_ratio * delta, delta, 
                                             num_trials, rng)
        stability_probs.append(p)
    axes[2].plot(state_counts, stability_probs, '-o', markersize=5, 
                 linewidth=2, label=f'gap/δ = {gap_ratio:.0f}')

axes[2].set_xlabel('Number of states', fontsize=12)
axes[2].set_ylabel('P(ground state preserved)', fontsize=12)
axes[2].set_title('Stability vs. Landscape Size', fontsize=13, fontweight='bold')
axes[2].legend(fontsize=10)
axes[2].grid(True, alpha=0.3)
axes[2].set_ylim(-0.05, 1.05)

plt.tight_layout()
plt.savefig('ground_state_stability.png', dpi=150, bbox_inches='tight')
print("Saved: ground_state_stability.png")


"""
Visualization: Perturbation Landscape and Signal-Noise Boundary

This script visualizes the deterministic perturbation stability theorem:
    tropMargin(A + E) ≥ tropMargin(A) - 4‖E‖∞

It creates a heatmap showing tropMargin as a function of signal strength
and noise level, with the theoretical phase boundary overlaid.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def trop_margin(W):
    n = W.shape[0]
    if n < 2:
        return 0.0
    margin = float('inf')
    for i in range(n):
        for j in range(n):
            if i != j:
                s = 2.0 * W[i, j] - W[i, i] - W[j, j]
                if s < margin:
                    margin = s
    return margin


def mean_model(n, mu_diag, mu_off):
    M = np.full((n, n), mu_off)
    np.fill_diagonal(M, mu_diag)
    return M


# Parameters
n = 6
rng = np.random.default_rng(42)

signal_range = np.linspace(0, 8, 30)
noise_range = np.linspace(0, 4, 25)
num_trials = 50

# Compute empirical P(tropMargin ≥ 0) heatmap
prob_map = np.zeros((len(noise_range), len(signal_range)))
margin_map = np.zeros((len(noise_range), len(signal_range)))

for si, sig in enumerate(signal_range):
    for ni, noise_scale in enumerate(noise_range):
        count = 0
        total_margin = 0
        S = mean_model(n, 0.0, sig / 2.0)
        for _ in range(num_trials):
            N = noise_scale * rng.standard_normal((n, n))
            m = trop_margin(S + N)
            total_margin += m
            if m >= 0:
                count += 1
        prob_map[ni, si] = count / num_trials
        margin_map[ni, si] = total_margin / num_trials

fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))

# Panel 1: P(margin ≥ 0) heatmap
im1 = axes[0].imshow(prob_map, extent=[signal_range[0], signal_range[-1],
                                        noise_range[-1], noise_range[0]],
                      aspect='auto', cmap='RdYlGn', vmin=0, vmax=1)
# Theoretical boundary: signalGap = 4 * noise → signal = 4 * noise (for mean model)
# signalGap of mean model = 2*(mu_off - mu_diag) = 2*(sig/2) = sig
# So boundary: sig = 4 * noise_scale * expected_max
# For Gaussian n×n: E[‖N‖∞] ≈ noise_scale * √(2 log(n²))
expected_max_factor = np.sqrt(2 * np.log(n * n))
boundary_noise = signal_range / (4 * expected_max_factor)
axes[0].plot(signal_range, boundary_noise, 'w--', linewidth=2,
             label=f'Theoretical boundary\n(4·E[‖N‖∞] = signalGap)')
axes[0].set_xlabel('Signal strength (2·(μ_off − μ_diag))', fontsize=12)
axes[0].set_ylabel('Noise scale σ', fontsize=12)
axes[0].set_title('P(tropMargin ≥ 0)', fontsize=13, fontweight='bold')
axes[0].legend(fontsize=9, loc='upper left', facecolor='black', 
               labelcolor='white', framealpha=0.7)
plt.colorbar(im1, ax=axes[0], shrink=0.8)

# Panel 2: Average margin heatmap
im2 = axes[1].imshow(margin_map, extent=[signal_range[0], signal_range[-1],
                                          noise_range[-1], noise_range[0]],
                      aspect='auto', cmap='coolwarm', 
                      vmin=-np.max(np.abs(margin_map)), 
                      vmax=np.max(np.abs(margin_map)))
axes[1].contour(signal_range, noise_range, margin_map, levels=[0],
                colors='black', linewidths=2)
axes[1].set_xlabel('Signal strength', fontsize=12)
axes[1].set_ylabel('Noise scale σ', fontsize=12)
axes[1].set_title('E[tropMargin(S + σN)]', fontsize=13, fontweight='bold')
plt.colorbar(im2, ax=axes[1], shrink=0.8)

# Panel 3: Cross-section at fixed noise
noise_idx = len(noise_range) // 3  # moderate noise
axes[2].plot(signal_range, prob_map[noise_idx, :], 'b-o', 
             markersize=4, linewidth=2, label=f'σ = {noise_range[noise_idx]:.1f}')
noise_idx2 = 2 * len(noise_range) // 3  # high noise
axes[2].plot(signal_range, prob_map[noise_idx2, :], 'r-s',
             markersize=4, linewidth=2, label=f'σ = {noise_range[noise_idx2]:.1f}')
axes[2].set_xlabel('Signal strength', fontsize=12)
axes[2].set_ylabel('P(tropMargin ≥ 0)', fontsize=12)
axes[2].set_title('Phase Transition Curves', fontsize=13, fontweight='bold')
axes[2].legend(fontsize=11)
axes[2].grid(True, alpha=0.3)
axes[2].set_ylim(-0.05, 1.05)
axes[2].axhline(y=0.5, color='gray', linestyle='--', alpha=0.5)

plt.tight_layout()
plt.savefig('perturbation_landscape.png', dpi=150, bbox_inches='tight')
print("Saved: perturbation_landscape.png")


"""
Visualization: Universality Collapse of Tropical Margin

This script visualizes the central prediction of tropical threshold universality:
after rescaling by √(log n), the probability curves P(tropMargin ≥ 0) collapse
for sub-Gaussian ensembles but not for heavy-tailed distributions.

The plot shows empirical transition curves for Gaussian, Rademacher, Uniform,
Exponential (all sub-Gaussian) and Cauchy (heavy-tailed counterexample).
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def diag_ex_slack(W, i, j):
    return 2.0 * W[i, j] - W[i, i] - W[j, j]


def trop_margin(W):
    n = W.shape[0]
    if n < 2:
        return 0.0
    margin = float('inf')
    for i in range(n):
        for j in range(n):
            if i != j:
                s = 2.0 * W[i, j] - W[i, i] - W[j, j]
                if s < margin:
                    margin = s
    return margin


def generate_noise(n, ensemble, rng):
    if ensemble == 'Gaussian':
        return rng.standard_normal((n, n))
    elif ensemble == 'Rademacher':
        return rng.choice([-1.0, 1.0], size=(n, n))
    elif ensemble == 'Uniform':
        return rng.uniform(-np.sqrt(3), np.sqrt(3), (n, n))
    elif ensemble == 'Exponential':
        return rng.exponential(1.0, (n, n)) - 1.0
    elif ensemble == 'Cauchy':
        return rng.standard_cauchy((n, n))


def run_universality_test(n, ensembles, scaled_strengths, num_trials, seed=42):
    rng = np.random.default_rng(seed)
    scale = np.sqrt(np.log(n))
    results = {}
    
    for ens in ensembles:
        probs = []
        for s in scaled_strengths:
            signal = s * scale
            S = np.full((n, n), signal / 2.0)
            np.fill_diagonal(S, 0.0)
            count = 0
            for _ in range(num_trials):
                N = generate_noise(n, ens, rng)
                if trop_margin(S + N) >= 0:
                    count += 1
            probs.append(count / num_trials)
        results[ens] = np.array(probs)
    
    return results


# Parameters
n = 8
ensembles = ['Gaussian', 'Rademacher', 'Uniform', 'Exponential', 'Cauchy']
scaled_strengths = np.linspace(-1, 8, 20)
num_trials = 300

results = run_universality_test(n, ensembles, scaled_strengths, num_trials)

# Plot
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

colors = {
    'Gaussian': '#2196F3',
    'Rademacher': '#4CAF50', 
    'Uniform': '#FF9800',
    'Exponential': '#9C27B0',
    'Cauchy': '#F44336'
}

markers = {
    'Gaussian': 'o',
    'Rademacher': 's',
    'Uniform': '^',
    'Exponential': 'D',
    'Cauchy': 'x'
}

# Left panel: all ensembles
for ens in ensembles:
    ax1.plot(scaled_strengths, results[ens], 
             color=colors[ens], marker=markers[ens], markersize=5,
             linewidth=2, label=ens, alpha=0.85)

ax1.set_xlabel('Scaled signal strength (s / √log n)', fontsize=13)
ax1.set_ylabel('P(tropMargin ≥ 0)', fontsize=13)
ax1.set_title(f'Tropical Margin Phase Transition (n={n})', fontsize=14, fontweight='bold')
ax1.legend(fontsize=11, framealpha=0.9)
ax1.grid(True, alpha=0.3)
ax1.set_ylim(-0.05, 1.05)
ax1.axhline(y=0.5, color='gray', linestyle='--', alpha=0.5)

# Right panel: sub-Gaussian only (collapse region)
sub_gaussian = ['Gaussian', 'Rademacher', 'Uniform', 'Exponential']
for ens in sub_gaussian:
    ax2.plot(scaled_strengths, results[ens],
             color=colors[ens], marker=markers[ens], markersize=5,
             linewidth=2, label=ens, alpha=0.85)

# Add Cauchy as faded background
ax2.plot(scaled_strengths, results['Cauchy'],
         color=colors['Cauchy'], marker=markers['Cauchy'], markersize=4,
         linewidth=1.5, label='Cauchy (non-universal)', alpha=0.4, linestyle='--')

ax2.set_xlabel('Scaled signal strength (s / √log n)', fontsize=13)
ax2.set_ylabel('P(tropMargin ≥ 0)', fontsize=13)
ax2.set_title('Sub-Gaussian Universality Collapse', fontsize=14, fontweight='bold')
ax2.legend(fontsize=10, framealpha=0.9)
ax2.grid(True, alpha=0.3)
ax2.set_ylim(-0.05, 1.05)
ax2.axhline(y=0.5, color='gray', linestyle='--', alpha=0.5)

plt.tight_layout()
plt.savefig('universality_collapse.png', dpi=150, bbox_inches='tight')
print("Saved: universality_collapse.png")

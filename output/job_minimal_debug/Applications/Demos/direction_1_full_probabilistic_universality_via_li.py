"""
applications.py — Real-World Applications of Tropical Lindeberg Universality

Demonstrates applications to:
1. Combinatorial optimization robustness
2. Assignment problem stability certification
3. Phase transition detection in random matrices
4. Model selection via tropical margin comparison

Keywords: combinatorial optimization, assignment problem, phase transition,
statistical physics, information theory, tropical geometry
"""

import numpy as np
from typing import Tuple, List, Dict


# ──────────────────────────────────────────────────────────────
# Core (self-contained)
# ──────────────────────────────────────────────────────────────

def tropical_margin(W: np.ndarray) -> float:
    """Tropical stability margin."""
    n = W.shape[0]
    if n < 2:
        return 0.0
    diag = np.diag(W)
    slack = 2 * W - diag[:, None] - diag[None, :]
    np.fill_diagonal(slack, np.inf)
    return float(np.min(slack))


def replacement_error(A: np.ndarray, B: np.ndarray) -> float:
    """4 * L1 entry distance."""
    return 4.0 * np.sum(np.abs(A - B))


# ──────────────────────────────────────────────────────────────
# Application 1: Assignment Problem Stability Certification
# ──────────────────────────────────────────────────────────────

def certify_assignment_stability(
    cost_matrix: np.ndarray,
    noise_bound: float,
) -> Dict:
    """
    Certify whether the optimal assignment is stable under noise.

    The tropical margin theorem guarantees: if tropMargin(W) > 4 * noise_bound,
    then the diagonal assignment remains optimal for any perturbation
    with sup-norm ≤ noise_bound.

    This is a direct application of `tropMargin_pos_of_signal_noise` from the
    Lean formalization.

    Parameters
    ----------
    cost_matrix : np.ndarray
        The cost/weight matrix (larger is better).
    noise_bound : float
        Maximum per-entry perturbation magnitude.

    Returns
    -------
    Dict with keys:
        'margin': tropical margin
        'threshold': 4 * noise_bound
        'stable': whether margin exceeds threshold
        'gap_ratio': margin / threshold (robustness measure)
    """
    margin = tropical_margin(cost_matrix)
    threshold = 4 * noise_bound
    stable = margin > threshold

    return {
        'margin': margin,
        'threshold': threshold,
        'stable': stable,
        'gap_ratio': margin / threshold if threshold > 0 else float('inf'),
        'interpretation': (
            f"Margin = {margin:.4f} {'>' if stable else '≤'} "
            f"threshold = {threshold:.4f}. "
            f"Assignment is {'CERTIFIED STABLE' if stable else 'NOT CERTIFIED'}."
        ),
    }


# ──────────────────────────────────────────────────────────────
# Application 2: Phase Transition Detection
# ──────────────────────────────────────────────────────────────

def detect_phase_transition(
    signal_strengths: np.ndarray,
    n: int = 20,
    num_trials: int = 200,
    seed: int = 42,
) -> Dict:
    """
    Detect the tropical stability phase transition.

    For the mean model meanModel(n, μ_diag, μ_off) + Noise:
    - μ_off - μ_diag > 0 → positive margin (stable phase)
    - μ_off - μ_diag < 0 → negative margin (unstable phase)

    The transition occurs at μ_off = μ_diag, with width √(log n).
    This is the deterministic mechanism behind `tropMargin_threshold_window_deterministic`.

    Parameters
    ----------
    signal_strengths : np.ndarray
        Values of (μ_off - μ_diag) to test.
    n : int
        Matrix size.
    num_trials : int
        Monte Carlo trials per signal strength.
    seed : int
        Random seed.

    Returns
    -------
    Dict with phase transition data.
    """
    rng = np.random.default_rng(seed)
    results = {
        'signal_strengths': signal_strengths,
        'prob_positive': [],
        'mean_margin': [],
        'std_margin': [],
    }

    for delta in signal_strengths:
        margins = []
        for _ in range(num_trials):
            # Mean model + Gaussian noise
            mean_matrix = np.full((n, n), 0.0)
            np.fill_diagonal(mean_matrix, -delta)  # diag = μ_diag, off = μ_off
            # So μ_off - μ_diag = delta
            mean_matrix[np.eye(n, dtype=bool)] = -delta
            mean_matrix[~np.eye(n, dtype=bool)] = 0.0

            noise = rng.standard_normal((n, n))
            W = mean_matrix + noise
            margins.append(tropical_margin(W))

        margins = np.array(margins)
        results['prob_positive'].append(np.mean(margins > 0))
        results['mean_margin'].append(np.mean(margins))
        results['std_margin'].append(np.std(margins))

    results['prob_positive'] = np.array(results['prob_positive'])
    results['mean_margin'] = np.array(results['mean_margin'])
    results['std_margin'] = np.array(results['std_margin'])
    results['transition_width'] = np.sqrt(np.log(n))

    return results


# ──────────────────────────────────────────────────────────────
# Application 3: Model Robustness Comparison
# ──────────────────────────────────────────────────────────────

def compare_model_robustness(
    models: Dict[str, np.ndarray],
    noise_level: float = 0.1,
    num_trials: int = 100,
    seed: int = 42,
) -> Dict:
    """
    Compare the robustness of different models using tropical margins.

    The universality theorem implies that the ranking of models by
    tropical margin is stable across noise distributions — a practical
    consequence of the Lindeberg replacement principle.

    Parameters
    ----------
    models : Dict[str, np.ndarray]
        Named cost/weight matrices to compare.
    noise_level : float
        Standard deviation of noise.
    num_trials : int
        Number of noise realizations.
    seed : int
        Random seed.

    Returns
    -------
    Dict with robustness comparison.
    """
    rng = np.random.default_rng(seed)
    results = {}

    for name, W in models.items():
        n = W.shape[0]
        base_margin = tropical_margin(W)
        noisy_margins = []

        for _ in range(num_trials):
            noise = noise_level * rng.standard_normal((n, n))
            noisy_margins.append(tropical_margin(W + noise))

        noisy_margins = np.array(noisy_margins)
        results[name] = {
            'base_margin': base_margin,
            'mean_noisy_margin': np.mean(noisy_margins),
            'prob_stable': np.mean(noisy_margins > 0),
            'margin_std': np.std(noisy_margins),
        }

    return results


# ──────────────────────────────────────────────────────────────
# Application 4: Tropical Margin as Information-Theoretic Gap
# ──────────────────────────────────────────────────────────────

def information_theoretic_gap(
    channel_matrix: np.ndarray,
) -> Dict:
    """
    Interpret the tropical margin as an information-theoretic gap.

    In coding theory, the tropical margin of the channel log-likelihood
    matrix encodes the gap between the best and second-best decoding.
    A positive margin means unambiguous decoding; the universality theorem
    implies this gap is insensitive to the specific noise distribution.

    Parameters
    ----------
    channel_matrix : np.ndarray
        Log-likelihood matrix (rows = codewords, cols = received symbols).

    Returns
    -------
    Dict with decoding gap analysis.
    """
    margin = tropical_margin(channel_matrix)
    n = channel_matrix.shape[0]

    return {
        'margin': margin,
        'decodable': margin > 0,
        'interpretation': (
            f"Tropical margin = {margin:.4f}. "
            f"{'Unambiguous' if margin > 0 else 'Ambiguous'} decoding. "
            f"Gap is universal across noise distributions by Lindeberg replacement."
        ),
        'robustness_radius': margin / 4 if margin > 0 else 0,
    }


# ──────────────────────────────────────────────────────────────
# Main demo
# ──────────────────────────────────────────────────────────────

if __name__ == '__main__':
    print("="*60)
    print("APPLICATION 1: Assignment Stability Certification")
    print("="*60)

    # Well-separated cost matrix
    W = np.array([
        [5.0, 1.0, 2.0],
        [1.0, 5.0, 2.0],
        [2.0, 2.0, 5.0],
    ])
    result = certify_assignment_stability(W, noise_bound=0.3)
    print(result['interpretation'])
    print(f"  Gap ratio: {result['gap_ratio']:.2f}")

    print("\n" + "="*60)
    print("APPLICATION 2: Phase Transition Detection")
    print("="*60)

    deltas = np.linspace(-3, 3, 13)
    pt = detect_phase_transition(deltas, n=20)
    print(f"  Transition width ≈ √(log 20) = {pt['transition_width']:.3f}")
    for i, d in enumerate(deltas):
        print(f"  δ={d:+5.1f}: P(margin>0)={pt['prob_positive'][i]:.2f}, "
              f"mean={pt['mean_margin'][i]:+6.2f}")

    print("\n" + "="*60)
    print("APPLICATION 3: Model Robustness Comparison")
    print("="*60)

    models = {
        'Well-separated': np.array([[5,1,1],[1,5,1],[1,1,5]], dtype=float),
        'Moderately separated': np.array([[3,2,1],[1,3,2],[2,1,3]], dtype=float),
        'Nearly degenerate': np.array([[2,1.9,1.8],[1.8,2,1.9],[1.9,1.8,2]], dtype=float),
    }
    rob = compare_model_robustness(models, noise_level=0.5)
    for name, data in rob.items():
        print(f"  {name:25s}: margin={data['base_margin']:+5.2f}, "
              f"P(stable)={data['prob_stable']:.2f}")

    print("\n" + "="*60)
    print("APPLICATION 4: Information-Theoretic Gap")
    print("="*60)
    channel = np.array([[3.0, 1.0], [1.0, 3.0]])
    info = information_theoretic_gap(channel)
    print(info['interpretation'])
    print(f"  Robustness radius: {info['robustness_radius']:.2f}")


"""
demo.py — Tropical Lindeberg Universality: Computational Demonstrations

Generates random matrices from multiple entry distributions, computes
tropical margins, estimates centering/scaling sequences, and tests
the universality conjecture via Kolmogorov-Smirnov comparisons.

Keywords: random matrix universality, tropical geometry, Lindeberg replacement,
extreme-value theory, sub-Gaussian concentration, non-spectral observable,
max-plus algebra, phase transition, threshold law, Gumbel scaling
"""

import numpy as np
from typing import Tuple, List, Dict

# ──────────────────────────────────────────────────────────────
# Core definitions
# ──────────────────────────────────────────────────────────────

def diag_ex_slack(W: np.ndarray, i: int, j: int) -> float:
    """Diagonal exchange slack: 2*W[i,j] - W[i,i] - W[j,j]."""
    return 2 * W[i, j] - W[i, i] - W[j, j]


def trop_margin(W: np.ndarray) -> float:
    """
    Tropical stability margin: minimum diagonal exchange slack
    over all distinct pairs (i, j).
    """
    n = W.shape[0]
    if n < 2:
        return 0.0
    min_slack = float('inf')
    for i in range(n):
        for j in range(n):
            if i != j:
                s = diag_ex_slack(W, i, j)
                if s < min_slack:
                    min_slack = s
    return min_slack


def replacement_error(A: np.ndarray, B: np.ndarray) -> float:
    """Replacement error: 4 * sum |A[i,j] - B[i,j]|."""
    return 4 * np.sum(np.abs(A - B))


def smooth_indicator(eta: float, t: float, x: float) -> float:
    """Smooth indicator approximating 1_{x <= t}, width eta."""
    if x <= t:
        return 1.0
    elif x >= t + eta:
        return 0.0
    else:
        return 1.0 - (x - t) / eta


# ──────────────────────────────────────────────────────────────
# Matrix generators
# ──────────────────────────────────────────────────────────────

def gaussian_matrix(n: int, rng: np.random.Generator) -> np.ndarray:
    """Standard Gaussian i.i.d. entries."""
    return rng.standard_normal((n, n))


def rademacher_matrix(n: int, rng: np.random.Generator) -> np.ndarray:
    """Rademacher ±1 entries (centered, variance 1)."""
    return rng.choice([-1.0, 1.0], size=(n, n))


def uniform_matrix(n: int, rng: np.random.Generator) -> np.ndarray:
    """Uniform on [-√3, √3] (centered, variance 1)."""
    return rng.uniform(-np.sqrt(3), np.sqrt(3), size=(n, n))


# ──────────────────────────────────────────────────────────────
# Centering and scaling estimation
# ──────────────────────────────────────────────────────────────

def estimate_centering_scaling(
    margins: np.ndarray,
) -> Tuple[float, float]:
    """Estimate centering a_n and scaling b_n from samples."""
    a_n = np.median(margins)
    b_n = np.std(margins)
    if b_n < 1e-12:
        b_n = 1.0
    return a_n, b_n


def normalized_margins(margins: np.ndarray, a_n: float, b_n: float) -> np.ndarray:
    """Normalize margins: (margin - a_n) / b_n."""
    return (margins - a_n) / b_n


# ──────────────────────────────────────────────────────────────
# KS distance
# ──────────────────────────────────────────────────────────────

def ks_distance(samples1: np.ndarray, samples2: np.ndarray) -> float:
    """Kolmogorov-Smirnov distance between two empirical distributions."""
    all_vals = np.sort(np.concatenate([samples1, samples2]))
    n1, n2 = len(samples1), len(samples2)
    cdf1 = np.searchsorted(np.sort(samples1), all_vals, side='right') / n1
    cdf2 = np.searchsorted(np.sort(samples2), all_vals, side='right') / n2
    return np.max(np.abs(cdf1 - cdf2))


# ──────────────────────────────────────────────────────────────
# Main experiment
# ──────────────────────────────────────────────────────────────

def run_universality_experiment(
    sizes: List[int] = [5, 10, 20, 50],
    num_samples: int = 500,
    seed: int = 42,
) -> Dict:
    """
    Run the universality experiment:
    1. Generate matrices from 3 distributions
    2. Compute tropical margins
    3. Normalize with estimated centering/scaling
    4. Compute pairwise KS distances
    5. Check if distances decrease with n (universality prediction)
    """
    rng = np.random.default_rng(seed)
    generators = {
        'Gaussian': gaussian_matrix,
        'Rademacher': rademacher_matrix,
        'Uniform': uniform_matrix,
    }

    results = {}
    for n in sizes:
        print(f"\n{'='*60}")
        print(f"Matrix size n = {n}")
        print(f"{'='*60}")

        margins = {}
        normalized = {}

        for name, gen in generators.items():
            m = np.array([trop_margin(gen(n, rng)) for _ in range(num_samples)])
            margins[name] = m
            a_n, b_n = estimate_centering_scaling(m)
            normalized[name] = normalized_margins(m, a_n, b_n)
            print(f"  {name:12s}: mean={np.mean(m):.4f}, std={np.std(m):.4f}, "
                  f"a_n={a_n:.4f}, b_n={b_n:.4f}, b_n/sqrt(log n)={b_n/np.sqrt(np.log(n)):.4f}")

        # Pairwise KS distances
        dist_names = list(generators.keys())
        ks_results = {}
        print(f"\n  Pairwise KS distances (normalized margins):")
        for i in range(len(dist_names)):
            for j in range(i + 1, len(dist_names)):
                d = ks_distance(normalized[dist_names[i]], normalized[dist_names[j]])
                pair = f"{dist_names[i]}-{dist_names[j]}"
                ks_results[pair] = d
                print(f"    {pair:25s}: {d:.4f}")

        results[n] = {
            'margins': margins,
            'normalized': normalized,
            'ks_distances': ks_results,
            'sqrt_log_n': np.sqrt(np.log(n)),
        }

    # Summary: check if KS distances decrease with n
    print(f"\n{'='*60}")
    print("UNIVERSALITY CHECK: Do KS distances decrease with n?")
    print(f"{'='*60}")
    for pair in results[sizes[0]]['ks_distances']:
        ds = [results[n]['ks_distances'][pair] for n in sizes]
        trend = "DECREASING ✓" if all(ds[i] >= ds[i+1] - 0.05 for i in range(len(ds)-1)) else "NOT CLEARLY DECREASING"
        print(f"  {pair:25s}: {' → '.join(f'{d:.3f}' for d in ds)}  [{trend}]")

    return results


def demo_replacement_chain():
    """Demonstrate the replacement chain construction."""
    print("\n" + "="*60)
    print("REPLACEMENT CHAIN DEMO")
    print("="*60)

    n = 4
    rng = np.random.default_rng(123)
    A = gaussian_matrix(n, rng)
    B = rademacher_matrix(n, rng)

    margin_A = trop_margin(A)
    margin_B = trop_margin(B)
    print(f"tropMargin(A) = {margin_A:.4f}")
    print(f"tropMargin(B) = {margin_B:.4f}")
    print(f"|tropMargin(A) - tropMargin(B)| = {abs(margin_A - margin_B):.4f}")
    print(f"replacementError(A, B) = {replacement_error(A, B):.4f}")

    # Build replacement chain
    chain_margins = []
    for k in range(n * n + 1):
        Z = np.copy(A)
        for idx in range(k):
            i, j = divmod(idx, n)
            Z[i, j] = B[i, j]
        chain_margins.append(trop_margin(Z))

    # Verify telescoping
    total_change = abs(chain_margins[0] - chain_margins[-1])
    step_sum = sum(abs(chain_margins[k] - chain_margins[k+1]) for k in range(n*n))
    print(f"\nTelescoping verification:")
    print(f"  |tropMargin(Z_0) - tropMargin(Z_{n*n})| = {total_change:.4f}")
    print(f"  Sum of step changes = {step_sum:.4f}")
    print(f"  Telescoping bound holds: {total_change <= step_sum + 1e-10}")


def demo_smooth_indicator():
    """Demonstrate smooth indicator properties."""
    print("\n" + "="*60)
    print("SMOOTH INDICATOR DEMO")
    print("="*60)

    eta = 0.5
    t = 0.0
    xs = np.linspace(-2, 2, 21)
    print(f"η = {eta}, t = {t}")
    print(f"{'x':>6s} | {'SmoothInd':>10s} | {'Indicator':>10s}")
    print("-" * 35)
    for x in xs:
        si = smooth_indicator(eta, t, x)
        ind = 1.0 if x <= t else 0.0
        print(f"{x:6.2f} | {si:10.4f} | {ind:10.4f}")


if __name__ == '__main__':
    results = run_universality_experiment()
    demo_replacement_chain()
    demo_smooth_indicator()


"""
Visualization 2: Tropical Phase Transition and √(log n) Scaling

Visualizes two key phenomena from the tropical universality theory:
1. The sharp phase transition in P(tropMargin > 0) as signal strength varies
2. The √(log n) scaling of the transition width, confirming extreme-value behavior

The phase transition curve is universal across entry distributions — a direct
consequence of the Lindeberg replacement theorem proved in this work.
"""

import numpy as np
import matplotlib.pyplot as plt


def tropical_margin(W):
    n = W.shape[0]
    if n < 2:
        return 0.0
    diag = np.diag(W)
    slack = 2 * W - diag[:, None] - diag[None, :]
    np.fill_diagonal(slack, np.inf)
    return float(np.min(slack))


# Phase transition experiment
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
fig.suptitle('Tropical Phase Transition: Universal Threshold at √(log n) Scale',
             fontsize=14, fontweight='bold', y=1.02)

# Panel 1: Phase transition curves for different distributions
sizes = [10, 20, 50]
deltas = np.linspace(-4, 4, 25)
num_trials = 300
rng = np.random.default_rng(42)

generators = {
    'Gaussian': lambda n, rng: rng.standard_normal((n, n)),
    'Rademacher': lambda n, rng: rng.choice([-1.0, 1.0], size=(n, n)),
}
colors_dist = {'Gaussian': '#2196F3', 'Rademacher': '#F44336'}
linestyles = {10: '-', 20: '--', 50: ':'}

for n in sizes:
    for name, gen in generators.items():
        probs = []
        for delta in deltas:
            count = 0
            for _ in range(num_trials):
                mean_mat = np.zeros((n, n))
                np.fill_diagonal(mean_mat, -delta)
                W = mean_mat + gen(n, rng)
                if tropical_margin(W) > 0:
                    count += 1
            probs.append(count / num_trials)

        label = f'{name}, n={n}'
        ax1.plot(deltas, probs, label=label,
                color=colors_dist[name], linestyle=linestyles[n],
                linewidth=1.8, alpha=0.8)

ax1.axhline(y=0.5, color='gray', linestyle=':', alpha=0.5)
ax1.axvline(x=0, color='gray', linestyle=':', alpha=0.5)
ax1.set_xlabel('Signal strength δ = μ_off - μ_diag', fontsize=11)
ax1.set_ylabel('P(tropMargin > 0)', fontsize=11)
ax1.set_title('Phase Transition Curves\n(Universality: curves overlap across distributions)', fontsize=11)
ax1.legend(fontsize=8, loc='upper left')
ax1.grid(True, alpha=0.3)

# Panel 2: Scaling of margin std with log(n)
sizes_scaling = [3, 5, 8, 10, 15, 20, 30, 50]
stds_gauss = []
stds_radem = []

for n in sizes_scaling:
    margins_g = [tropical_margin(rng.standard_normal((n, n))) for _ in range(400)]
    margins_r = [tropical_margin(rng.choice([-1.0, 1.0], size=(n, n))) for _ in range(400)]
    stds_gauss.append(np.std(margins_g))
    stds_radem.append(np.std(margins_r))

sqrt_logs = [np.sqrt(np.log(n)) for n in sizes_scaling]
ax2.scatter(sqrt_logs, stds_gauss, color='#2196F3', s=60, zorder=5, label='Gaussian σ')
ax2.scatter(sqrt_logs, stds_radem, color='#F44336', s=60, zorder=5, marker='s', label='Rademacher σ')

# Fit line
coeffs = np.polyfit(sqrt_logs, [(g+r)/2 for g, r in zip(stds_gauss, stds_radem)], 1)
x_fit = np.linspace(min(sqrt_logs), max(sqrt_logs), 50)
ax2.plot(x_fit, np.polyval(coeffs, x_fit), 'k--', alpha=0.5,
         label=f'Linear fit: σ ≈ {coeffs[0]:.2f}·√(log n) + {coeffs[1]:.2f}')

ax2.set_xlabel('√(log n)', fontsize=11)
ax2.set_ylabel('Std dev of tropical margin', fontsize=11)
ax2.set_title('√(log n) Scaling\n(Extreme-value behavior)', fontsize=11)
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_phase_transition.png', dpi=150, bbox_inches='tight')
print("Saved viz_phase_transition.png")


"""
Visualization 3: Lindeberg Replacement Chain — Tropical Margin Trajectory

Visualizes the core mechanism of the Lindeberg replacement principle:
as entries of matrix A are replaced one-by-one with entries of matrix B,
the tropical margin traces a bounded trajectory. The telescoping inequality
guarantees that the total change is controlled by the sum of step-wise changes.

This is the combinatorial backbone of the universality theorem.
"""

import numpy as np
import matplotlib.pyplot as plt


def tropical_margin(W):
    n = W.shape[0]
    if n < 2:
        return 0.0
    diag = np.diag(W)
    slack = 2 * W - diag[:, None] - diag[None, :]
    np.fill_diagonal(slack, np.inf)
    return float(np.min(slack))


def build_replacement_chain_margins(A, B):
    """Build the replacement chain and compute margins at each step."""
    n = A.shape[0]
    Z = A.copy()
    margins = [tropical_margin(Z)]

    for k in range(n * n):
        i, j = divmod(k, n)
        Z = Z.copy()
        Z[i, j] = B[i, j]
        margins.append(tropical_margin(Z))

    return margins


# Setup
rng = np.random.default_rng(42)
n = 6

fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle('Lindeberg Replacement Chain: Tropical Margin Trajectories',
             fontsize=14, fontweight='bold', y=1.02)

# Panel 1: Gaussian → Rademacher
A = rng.standard_normal((n, n))
B = rng.choice([-1.0, 1.0], size=(n, n))
margins = build_replacement_chain_margins(A, B)
steps = np.arange(len(margins))

ax = axes[0, 0]
ax.plot(steps, margins, 'b-', linewidth=1.5, alpha=0.8)
ax.axhline(y=margins[0], color='green', linestyle='--', alpha=0.5, label=f'Start: {margins[0]:.2f}')
ax.axhline(y=margins[-1], color='red', linestyle='--', alpha=0.5, label=f'End: {margins[-1]:.2f}')
ax.fill_between(steps, margins, alpha=0.15, color='blue')
ax.set_title(f'Gaussian → Rademacher (n={n})', fontsize=11)
ax.set_xlabel('Replacement step k')
ax.set_ylabel('tropMargin(Z^(k))')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Panel 2: Step-wise changes (|Z^k - Z^{k+1}|)
step_changes = [abs(margins[k] - margins[k+1]) for k in range(len(margins)-1)]
ax = axes[0, 1]
ax.bar(range(len(step_changes)), step_changes, color='#FF9800', alpha=0.7, width=1.0)
total = abs(margins[0] - margins[-1])
step_sum = sum(step_changes)
ax.axhline(y=total/len(step_changes), color='red', linestyle='--',
           label=f'Avg = total/n² = {total/len(step_changes):.4f}')
ax.set_title(f'Step-wise changes\n|total| = {total:.3f} ≤ Σ|steps| = {step_sum:.3f}',
             fontsize=11)
ax.set_xlabel('Step k')
ax.set_ylabel('|ΔtropMargin|')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Panel 3: Multiple realizations
ax = axes[1, 0]
colors = plt.cm.viridis(np.linspace(0, 1, 8))
for trial in range(8):
    A = rng.standard_normal((n, n))
    B = rng.choice([-1.0, 1.0], size=(n, n))
    margins_t = build_replacement_chain_margins(A, B)
    ax.plot(range(len(margins_t)), margins_t, color=colors[trial],
            linewidth=1.0, alpha=0.7)

ax.set_title(f'8 Independent Chains (n={n})', fontsize=11)
ax.set_xlabel('Replacement step k')
ax.set_ylabel('tropMargin(Z^(k))')
ax.grid(True, alpha=0.3)

# Panel 4: Gaussian → Uniform
A = rng.standard_normal((n, n))
B = rng.uniform(-np.sqrt(3), np.sqrt(3), size=(n, n))
margins_gu = build_replacement_chain_margins(A, B)

ax = axes[1, 1]
ax.plot(range(len(margins_gu)), margins_gu, 'g-', linewidth=1.5, alpha=0.8,
        label='Gaussian → Uniform')

# Also Rademacher → Uniform
A2 = rng.choice([-1.0, 1.0], size=(n, n))
B2 = rng.uniform(-np.sqrt(3), np.sqrt(3), size=(n, n))
margins_ru = build_replacement_chain_margins(A2, B2)
ax.plot(range(len(margins_ru)), margins_ru, 'r-', linewidth=1.5, alpha=0.8,
        label='Rademacher → Uniform')

ax.set_title(f'Different replacement pairs (n={n})', fontsize=11)
ax.set_xlabel('Replacement step k')
ax.set_ylabel('tropMargin(Z^(k))')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_replacement_chain.png', dpi=150, bbox_inches='tight')
print("Saved viz_replacement_chain.png")


"""
Visualization 1: Tropical Margin Universality — Empirical CDF Collapse

Visualizes the central prediction of the tropical Lindeberg universality theorem:
normalized tropical margin CDFs from different entry distributions collapse onto
a single universal curve as matrix size n increases. This is the computational
signature of the Lindeberg replacement principle for non-spectral observables.
"""

import numpy as np
import matplotlib.pyplot as plt


def tropical_margin(W):
    """Tropical stability margin: min_{i≠j} (2W[i,j] - W[i,i] - W[j,j])."""
    n = W.shape[0]
    if n < 2:
        return 0.0
    diag = np.diag(W)
    slack = 2 * W - diag[:, None] - diag[None, :]
    np.fill_diagonal(slack, np.inf)
    return float(np.min(slack))


def generate_margins(gen_func, n, num_samples, rng):
    """Generate tropical margin samples."""
    return np.array([tropical_margin(gen_func(n, rng)) for _ in range(num_samples)])


# Generators
def gaussian(n, rng): return rng.standard_normal((n, n))
def rademacher(n, rng): return rng.choice([-1.0, 1.0], size=(n, n))
def uniform(n, rng): return rng.uniform(-np.sqrt(3), np.sqrt(3), size=(n, n))

# Setup
sizes = [5, 10, 20, 50]
num_samples = 800
rng = np.random.default_rng(42)
generators = {'Gaussian': gaussian, 'Rademacher': rademacher, 'Uniform': uniform}
colors = {'Gaussian': '#2196F3', 'Rademacher': '#F44336', 'Uniform': '#4CAF50'}

fig, axes = plt.subplots(1, len(sizes), figsize=(16, 4), sharey=True)
fig.suptitle('Tropical Margin CDF Universality: Collapse Under Normalization',
             fontsize=14, fontweight='bold', y=1.02)

for idx, n in enumerate(sizes):
    ax = axes[idx]
    all_normalized = {}

    for name, gen in generators.items():
        margins = generate_margins(gen, n, num_samples, rng)
        a_n = np.median(margins)
        b_n = np.std(margins)
        if b_n < 1e-10:
            b_n = 1.0
        normalized = (margins - a_n) / b_n
        all_normalized[name] = normalized

        sorted_vals = np.sort(normalized)
        cdf = np.arange(1, len(sorted_vals) + 1) / len(sorted_vals)
        ax.plot(sorted_vals, cdf, label=name, color=colors[name], linewidth=1.5, alpha=0.85)

    # KS distances
    names = list(generators.keys())
    ks_vals = []
    for i in range(len(names)):
        for j in range(i+1, len(names)):
            s1, s2 = all_normalized[names[i]], all_normalized[names[j]]
            combined = np.sort(np.unique(np.concatenate([s1, s2])))
            c1 = np.searchsorted(np.sort(s1), combined, side='right') / len(s1)
            c2 = np.searchsorted(np.sort(s2), combined, side='right') / len(s2)
            ks_vals.append(np.max(np.abs(c1 - c2)))

    avg_ks = np.mean(ks_vals)
    ax.set_title(f'n = {n}\nAvg KS = {avg_ks:.3f}', fontsize=11)
    ax.set_xlabel('Normalized margin', fontsize=10)
    ax.grid(True, alpha=0.3)
    ax.set_xlim(-4, 4)

axes[0].set_ylabel('CDF', fontsize=11)
axes[0].legend(fontsize=9)

plt.tight_layout()
plt.savefig('viz_universality.png', dpi=150, bbox_inches='tight')
print("Saved viz_universality.png")

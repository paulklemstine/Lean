#!/usr/bin/env python3
"""
Tropical Mutual Information — Algorithms

Efficient algorithms for computing min-entropy, tropical mutual information,
and data processing inequality verification.

Time complexity: O(|α|·|β|) for joint distributions on α × β.
Space complexity: O(|α|·|β|) for storing the joint distribution.

Author: Harmonic Research
"""

import numpy as np
from typing import Callable, List, Tuple, Optional


class FiniteDistribution:
    """A finite probability distribution with min-entropy operations.

    Attributes:
        pmf: Array of probabilities (nonneg, sum to 1).
        alphabet_size: Number of outcomes.
    """

    def __init__(self, pmf: np.ndarray):
        pmf = np.asarray(pmf, dtype=float)
        assert np.all(pmf >= 0), "Probabilities must be nonneg"
        assert np.isclose(pmf.sum(), 1.0), f"Probabilities must sum to 1, got {pmf.sum()}"
        self.pmf = pmf
        self.alphabet_size = len(pmf)

    @property
    def max_mass(self) -> float:
        """Max mass: max_x p(x). O(n) time."""
        return float(np.max(self.pmf))

    @property
    def min_entropy(self) -> float:
        """Min-entropy H_∞ = -log2(max_mass). O(n) time."""
        return -np.log2(self.max_mass)

    @property
    def guessing_probability(self) -> float:
        """Optimal guessing probability = max_mass. O(n) time."""
        return self.max_mass

    @property
    def search_complexity(self) -> float:
        """Expected search complexity = 1/max_mass. O(n) time."""
        return 1.0 / self.max_mass

    @staticmethod
    def uniform(n: int) -> 'FiniteDistribution':
        """Uniform distribution on n outcomes."""
        return FiniteDistribution(np.ones(n) / n)

    def pushforward(self, f: Callable[[int], int], range_size: int) -> 'FiniteDistribution':
        """Pushforward through f : [n] → [m]. O(n) time."""
        result = np.zeros(range_size)
        for i, p in enumerate(self.pmf):
            result[f(i)] += p
        return FiniteDistribution(result)


class JointDistribution:
    """A joint distribution on α × β for tropical MI computation.

    The joint pmf is stored as a 2D array of shape (|α|, |β|).

    Attributes:
        joint: 2D array of joint probabilities.
        n_x: Size of first alphabet.
        n_y: Size of second alphabet.
    """

    def __init__(self, joint: np.ndarray):
        joint = np.asarray(joint, dtype=float)
        assert joint.ndim == 2, "Joint must be 2D"
        assert np.all(joint >= 0), "Probabilities must be nonneg"
        assert np.isclose(joint.sum(), 1.0), f"Must sum to 1, got {joint.sum()}"
        self.joint = joint
        self.n_x, self.n_y = joint.shape

    @property
    def marginal_x(self) -> FiniteDistribution:
        """First marginal p_X(x) = Σ_y p(x,y). O(|α|·|β|) time."""
        return FiniteDistribution(self.joint.sum(axis=1))

    @property
    def marginal_y(self) -> FiniteDistribution:
        """Second marginal p_Y(y) = Σ_x p(x,y). O(|α|·|β|) time."""
        return FiniteDistribution(self.joint.sum(axis=0))

    @property
    def adversarial_guess_mass(self) -> float:
        """Adversarial guess mass Σ_y max_x p(x,y). O(|α|·|β|) time.

        This is the adversary's total success probability when they
        observe Y and make the MAP estimate for each y.
        """
        return float(np.sum(np.max(self.joint, axis=0)))

    @property
    def cond_min_entropy(self) -> float:
        """Conditional min-entropy H_∞(X|Y) = -log2(Σ_y max_x p(x,y)).
        O(|α|·|β|) time.
        """
        return -np.log2(self.adversarial_guess_mass)

    @property
    def tropical_mi(self) -> float:
        """Tropical mutual information I_∞(X;Y) = H_∞(X) - H_∞(X|Y).
        O(|α|·|β|) time.

        Always ≥ 0 by the condMinEntropy_le_minEntropy theorem.
        """
        return self.marginal_x.min_entropy - self.cond_min_entropy

    def pushforward_snd(self, f: Callable[[int], int], range_size: int) -> 'JointDistribution':
        """Pushforward on second coordinate.

        Returns the joint distribution p(X, f(Y)).
        By the DPI, tropical_mi can only decrease.

        O(|α|·|β|) time.
        """
        result = np.zeros((self.n_x, range_size))
        for j in range(self.n_y):
            result[:, f(j)] += self.joint[:, j]
        return JointDistribution(result)

    @staticmethod
    def independent(p: FiniteDistribution, q: FiniteDistribution) -> 'JointDistribution':
        """Product distribution (independence). O(|α|·|β|) time."""
        return JointDistribution(np.outer(p.pmf, q.pmf))

    def verify_dpi(self, f: Callable[[int], int], range_size: int) -> dict:
        """Verify the DPI for a specific post-processing function.

        Returns a dictionary with MI values and verification status.
        """
        processed = self.pushforward_snd(f, range_size)
        mi_before = self.tropical_mi
        mi_after = processed.tropical_mi
        return {
            'mi_before': mi_before,
            'mi_after': mi_after,
            'dpi_satisfied': mi_after <= mi_before + 1e-10,
            'information_lost': mi_before - mi_after,
        }


def privacy_mechanism_analysis(
    n_secrets: int,
    n_outputs: int,
    mechanism: np.ndarray
) -> dict:
    """Analyze a privacy mechanism using tropical MI.

    Args:
        n_secrets: Number of secret values.
        n_outputs: Number of mechanism outputs.
        mechanism: Joint distribution p(X,Y) of shape (n_secrets, n_outputs).

    Returns:
        Dictionary with privacy metrics.
    """
    jd = JointDistribution(mechanism)

    return {
        'n_secrets': n_secrets,
        'n_outputs': n_outputs,
        'prior_entropy': jd.marginal_x.min_entropy,
        'posterior_entropy': jd.cond_min_entropy,
        'information_leakage': jd.tropical_mi,
        'adversary_success_rate': jd.adversarial_guess_mass,
        'baseline_success_rate': jd.marginal_x.max_mass,
        'privacy_amplification': jd.marginal_x.max_mass / jd.adversarial_guess_mass,
    }


# ============================================================
# Algorithm: Optimal DPI Certificate
# ============================================================
def find_optimal_coarsening(
    jd: JointDistribution,
    target_mi: float,
    max_partitions: int = 100
) -> Optional[Tuple[dict, float]]:
    """Find a coarsening of Y that achieves target MI.

    Uses greedy merging: repeatedly merge the two Y-values
    whose merging decreases MI the least, until target is reached.

    Time: O(|β|² · |α|) per merge step, O(|β|³ · |α|) total.

    Args:
        jd: Joint distribution.
        target_mi: Target mutual information (≤ current MI).
        max_partitions: Maximum merge steps.

    Returns:
        (partition_map, achieved_mi) or None if target unreachable.
    """
    current = jd.joint.copy()
    n_y = jd.n_y
    # Track which original columns map to which current column
    partition = {i: i for i in range(n_y)}
    active = list(range(n_y))

    for _ in range(max_partitions):
        current_jd = JointDistribution(current[:, active])
        if current_jd.tropical_mi <= target_mi + 1e-10:
            return partition, current_jd.tropical_mi

        if len(active) <= 1:
            break

        # Find best pair to merge
        best_mi = float('inf')
        best_pair = None
        for i in range(len(active)):
            for j in range(i + 1, len(active)):
                trial = current[:, active].copy()
                trial[:, i] += trial[:, j]
                trial = np.delete(trial, j, axis=1)
                trial_jd = JointDistribution(trial)
                if trial_jd.tropical_mi < best_mi:
                    best_mi = trial_jd.tropical_mi
                    best_pair = (i, j)

        if best_pair is None:
            break

        i, j = best_pair
        # Merge column j into column i
        current[:, active[i]] += current[:, active[j]]
        merged_target = active[i]
        removed = active[j]
        for k, v in partition.items():
            if v == removed:
                partition[k] = merged_target
        active.pop(j)

    final_jd = JointDistribution(current[:, active])
    return partition, final_jd.tropical_mi


if __name__ == '__main__':
    print("Tropical MI Algorithm Demonstrations")
    print("=" * 50)

    # Example: Privacy mechanism analysis
    mechanism = np.array([
        [0.15, 0.10, 0.05],
        [0.05, 0.15, 0.10],
        [0.10, 0.05, 0.15],
        [0.03, 0.04, 0.03]
    ])
    result = privacy_mechanism_analysis(4, 3, mechanism)
    print("\nPrivacy Mechanism Analysis:")
    for k, v in result.items():
        print(f"  {k}: {v:.4f}" if isinstance(v, float) else f"  {k}: {v}")

    # Example: DPI verification
    jd = JointDistribution(mechanism)
    f = lambda y: y // 2  # Coarsen output
    dpi = jd.verify_dpi(f, 2)
    print("\nDPI Verification:")
    for k, v in dpi.items():
        print(f"  {k}: {v:.4f}" if isinstance(v, float) else f"  {k}: {v}")

    # Example: Greedy coarsening
    print("\nGreedy Coarsening to target MI = 0.1:")
    result = find_optimal_coarsening(jd, 0.1)
    if result:
        partition, achieved_mi = result
        print(f"  Partition: {partition}")
        print(f"  Achieved MI: {achieved_mi:.4f}")


#!/usr/bin/env python3
"""
Tropical Mutual Information — Real-World Applications

Applications to differential privacy, adversarial ML, and cryptography.

Author: Harmonic Research
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


# ============================================================
# Application 1: Differential Privacy Analysis
# ============================================================
def differential_privacy_analysis():
    """Analyze privacy mechanisms using tropical MI.

    Models a randomized response mechanism where each secret
    value is reported truthfully with probability (1-ε) and
    randomly with probability ε.
    """
    print("=" * 60)
    print("APPLICATION 1: Differential Privacy via Tropical MI")
    print("=" * 60)

    n_secrets = 4
    epsilons = [0.0, 0.1, 0.3, 0.5, 0.7, 0.9, 1.0]

    results = []
    for eps in epsilons:
        # Randomized response mechanism
        mechanism = np.eye(n_secrets) * (1 - eps) + eps / n_secrets
        # Assume uniform prior
        joint = mechanism / n_secrets

        # Compute tropical MI
        p_x = joint.sum(axis=1)
        agm = np.sum(np.max(joint, axis=0))
        h_inf_x = -np.log2(np.max(p_x))
        h_inf_cond = -np.log2(agm)
        mi = h_inf_x - h_inf_cond

        results.append({
            'epsilon': eps,
            'h_inf_x': h_inf_x,
            'h_inf_cond': h_inf_cond,
            'mi': mi,
            'adversary_success': agm,
        })

        print(f"\n  ε = {eps:.1f}:")
        print(f"    H_∞(X) = {h_inf_x:.4f} bits")
        print(f"    H_∞(X|Y) = {h_inf_cond:.4f} bits")
        print(f"    I_∞(X;Y) = {mi:.4f} bits")
        print(f"    Adversary success = {agm:.4f}")

    # Plot
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    eps_vals = [r['epsilon'] for r in results]
    mi_vals = [r['mi'] for r in results]
    adv_vals = [r['adversary_success'] for r in results]

    ax1.plot(eps_vals, mi_vals, 'b-o', linewidth=2, markersize=8)
    ax1.set_xlabel('Noise level ε', fontsize=12)
    ax1.set_ylabel('I_∞(X;Y) [bits]', fontsize=12)
    ax1.set_title('Tropical MI vs Privacy Parameter', fontsize=14)
    ax1.grid(True, alpha=0.3)
    ax1.set_ylim(bottom=0)

    ax2.plot(eps_vals, adv_vals, 'r-s', linewidth=2, markersize=8)
    ax2.axhline(y=1/n_secrets, color='gray', linestyle='--', label='Baseline (1/n)')
    ax2.set_xlabel('Noise level ε', fontsize=12)
    ax2.set_ylabel('Adversary success rate', fontsize=12)
    ax2.set_title('Adversarial Guessing Probability', fontsize=14)
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('privacy_analysis.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("\n  → Saved: privacy_analysis.png")


# ============================================================
# Application 2: Neural Network Information Bottleneck
# ============================================================
def neural_network_bottleneck():
    """Demonstrate the DPI as an information bottleneck constraint.

    Each neural network layer is a deterministic function that
    can only decrease min-entropy (and tropical MI with the input).
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Neural Network Information Bottleneck")
    print("=" * 60)

    np.random.seed(42)

    # Simulate a 3-layer network processing 8-class input
    n_classes = 8
    layer_sizes = [8, 6, 4, 2]

    # Random joint distribution between input X and features
    joint = np.random.dirichlet(np.ones(n_classes * layer_sizes[0])).reshape(n_classes, layer_sizes[0])

    mi_values = []
    entropy_values = []

    print(f"\n  Layer 0 (input, dim={layer_sizes[0]}):")
    p_x = joint.sum(axis=1)
    agm = np.sum(np.max(joint, axis=0))
    mi = -np.log2(np.max(p_x)) - (-np.log2(agm))
    mi_values.append(mi)
    entropy_values.append(-np.log2(np.max(joint.sum(axis=0))))
    print(f"    I_∞(X;Y_0) = {mi:.4f} bits")

    current_joint = joint
    for i in range(1, len(layer_sizes)):
        # Random deterministic map (hash-like)
        f = np.random.randint(0, layer_sizes[i], size=current_joint.shape[1])
        new_joint = np.zeros((n_classes, layer_sizes[i]))
        for j in range(current_joint.shape[1]):
            new_joint[:, f[j]] += current_joint[:, j]

        p_x = new_joint.sum(axis=1)
        agm = np.sum(np.max(new_joint, axis=0))
        mi = -np.log2(np.max(p_x)) - (-np.log2(agm))
        mi_values.append(mi)
        entropy_values.append(-np.log2(np.max(new_joint.sum(axis=0))))

        print(f"  Layer {i} (dim={layer_sizes[i]}):")
        print(f"    I_∞(X;Y_{i}) = {mi:.4f} bits")
        print(f"    DPI satisfied: {mi <= mi_values[i-1] + 1e-10}")

        current_joint = new_joint

    # Plot
    fig, ax = plt.subplots(figsize=(8, 5))
    ax.plot(range(len(mi_values)), mi_values, 'g-D', linewidth=2, markersize=10)
    ax.set_xlabel('Layer', fontsize=12)
    ax.set_ylabel('I_∞(X; Layer output) [bits]', fontsize=12)
    ax.set_title('Information Bottleneck: Tropical MI Through Network Layers', fontsize=14)
    ax.set_xticks(range(len(mi_values)))
    ax.set_xticklabels([f'Layer {i}\n(dim={s})' for i, s in enumerate(layer_sizes)])
    ax.grid(True, alpha=0.3)
    ax.set_ylim(bottom=0)

    plt.tight_layout()
    plt.savefig('bottleneck.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("\n  → Saved: bottleneck.png")


# ============================================================
# Application 3: Cryptographic Key Leakage
# ============================================================
def crypto_key_leakage():
    """Analyze key leakage in a simplified cryptographic setting.

    Models an encryption scheme where the ciphertext leaks
    partial information about the key through side channels.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Cryptographic Key Leakage Analysis")
    print("=" * 60)

    np.random.seed(123)

    key_bits_range = range(2, 9)
    leakage_results = []

    for n_bits in key_bits_range:
        n_keys = 2 ** n_bits
        n_observations = n_keys  # Same number of possible observations

        # Model: each key produces a slightly biased observation
        # Stronger side channel → more leakage
        noise = 0.3
        mechanism = np.eye(n_keys) * (1 - noise) + noise / n_keys
        joint = mechanism / n_keys  # Uniform prior over keys

        p_x = joint.sum(axis=1)
        agm = np.sum(np.max(joint, axis=0))
        mi = -np.log2(np.max(p_x)) - (-np.log2(agm))

        leakage_results.append({
            'bits': n_bits,
            'n_keys': n_keys,
            'mi': mi,
            'prior_entropy': -np.log2(np.max(p_x)),
            'remaining_entropy': -np.log2(agm),
        })

        print(f"\n  {n_bits}-bit key ({n_keys} keys):")
        print(f"    H_∞(Key) = {-np.log2(np.max(p_x)):.4f} bits")
        print(f"    H_∞(Key|Obs) = {-np.log2(agm):.4f} bits")
        print(f"    Leakage I_∞ = {mi:.4f} bits")
        print(f"    Adversary advantage: {agm:.6f}")

    # Plot
    fig, ax = plt.subplots(figsize=(8, 5))
    bits = [r['bits'] for r in leakage_results]
    prior_ent = [r['prior_entropy'] for r in leakage_results]
    remain_ent = [r['remaining_entropy'] for r in leakage_results]
    leakage = [r['mi'] for r in leakage_results]

    ax.plot(bits, prior_ent, 'b-o', label='H_∞(Key)', linewidth=2)
    ax.plot(bits, remain_ent, 'r-s', label='H_∞(Key|Obs)', linewidth=2)
    ax.fill_between(bits, remain_ent, prior_ent, alpha=0.2, color='orange',
                     label='Leakage I_∞')
    ax.set_xlabel('Key size (bits)', fontsize=12)
    ax.set_ylabel('Entropy (bits)', fontsize=12)
    ax.set_title('Cryptographic Key Leakage via Tropical MI', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('crypto_leakage.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("\n  → Saved: crypto_leakage.png")


if __name__ == '__main__':
    differential_privacy_analysis()
    neural_network_bottleneck()
    crypto_key_leakage()
    print("\n" + "=" * 60)
    print("All applications completed successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Tropical Mutual Information — Numerical Demonstrations

Demonstrates the key theorems of tropical (min-entropy based) mutual
information theory with concrete numerical examples.

Author: Harmonic Research
"""

import numpy as np
from typing import Tuple

def max_mass(p: np.ndarray) -> float:
    """Max mass of a distribution: max_x p(x)."""
    return float(np.max(p))

def min_entropy(p: np.ndarray) -> float:
    """Min-entropy H_∞(X) = -log2(max_x p(x))."""
    return -np.log2(max_mass(p))

def marginal_fst(joint: np.ndarray) -> np.ndarray:
    """First marginal: p_X(x) = Σ_y p(x,y)."""
    return joint.sum(axis=1)

def marginal_snd(joint: np.ndarray) -> np.ndarray:
    """Second marginal: p_Y(y) = Σ_x p(x,y)."""
    return joint.sum(axis=0)

def adversarial_guess_mass(joint: np.ndarray) -> float:
    """Adversarial guess mass: Σ_y max_x p(x,y)."""
    return float(np.sum(np.max(joint, axis=0)))

def cond_min_entropy(joint: np.ndarray) -> float:
    """Conditional min-entropy: H_∞(X|Y) = -log2(Σ_y max_x p(x,y))."""
    return -np.log2(adversarial_guess_mass(joint))

def tropical_mi(joint: np.ndarray) -> float:
    """Tropical mutual information: I_∞(X;Y) = H_∞(X) - H_∞(X|Y)."""
    p_x = marginal_fst(joint)
    return min_entropy(p_x) - cond_min_entropy(joint)

def pushforward_snd(joint: np.ndarray, f: dict) -> np.ndarray:
    """Pushforward on second coordinate.
    f maps column indices to new indices."""
    n_rows = joint.shape[0]
    new_cols = max(f.values()) + 1
    result = np.zeros((n_rows, new_cols))
    for j in range(joint.shape[1]):
        result[:, f[j]] += joint[:, j]
    return result

# ============================================================
# Demo 1: Basic Properties
# ============================================================
print("=" * 60)
print("DEMO 1: Min-Entropy Basic Properties")
print("=" * 60)

# Uniform distribution on 4 elements
p_uniform = np.array([0.25, 0.25, 0.25, 0.25])
print(f"\nUniform distribution: {p_uniform}")
print(f"  maxMass = {max_mass(p_uniform):.4f}")
print(f"  H_∞ = {min_entropy(p_uniform):.4f} bits")
print(f"  log2(|α|) = {np.log2(len(p_uniform)):.4f}")
print(f"  H_∞ = log2(|α|)? {np.isclose(min_entropy(p_uniform), np.log2(len(p_uniform)))}")

# Skewed distribution
p_skewed = np.array([0.7, 0.1, 0.1, 0.1])
print(f"\nSkewed distribution: {p_skewed}")
print(f"  maxMass = {max_mass(p_skewed):.4f}")
print(f"  H_∞ = {min_entropy(p_skewed):.4f} bits")
print(f"  H_∞ ≥ 0? {min_entropy(p_skewed) >= 0}")
print(f"  H_∞ ≤ log2(|α|) = {np.log2(len(p_skewed)):.4f}? {min_entropy(p_skewed) <= np.log2(len(p_skewed))}")

# Deterministic distribution
p_det = np.array([1.0, 0.0, 0.0, 0.0])
print(f"\nDeterministic distribution: {p_det}")
print(f"  maxMass = {max_mass(p_det):.4f}")
print(f"  H_∞ = {min_entropy(p_det):.4f} bits (minimum entropy)")

# ============================================================
# Demo 2: Product Distribution Additivity
# ============================================================
print("\n" + "=" * 60)
print("DEMO 2: Min-Entropy Additivity for Product Distributions")
print("=" * 60)

p = np.array([0.6, 0.3, 0.1])
q = np.array([0.5, 0.5])
pq = np.outer(p, q)  # Product distribution

print(f"\np = {p}")
print(f"q = {q}")
print(f"H_∞(p) = {min_entropy(p):.4f}")
print(f"H_∞(q) = {min_entropy(q):.4f}")
print(f"H_∞(p⊗q) = {min_entropy(pq.flatten()):.4f}")
print(f"H_∞(p) + H_∞(q) = {min_entropy(p) + min_entropy(q):.4f}")
print(f"Additive? {np.isclose(min_entropy(pq.flatten()), min_entropy(p) + min_entropy(q))}")

# ============================================================
# Demo 3: Tropical MI Non-Negativity
# ============================================================
print("\n" + "=" * 60)
print("DEMO 3: Tropical MI Non-Negativity")
print("=" * 60)

# Independent joint distribution
joint_indep = np.outer(p, q)
print(f"\nIndependent joint distribution:")
print(f"  p_X = {p}")
print(f"  p_Y = {q}")
print(f"  I_∞(X;Y) = {tropical_mi(joint_indep):.6f}")
print(f"  I_∞ = 0? {np.isclose(tropical_mi(joint_indep), 0)}")

# Correlated joint distribution
joint_corr = np.array([[0.4, 0.1], [0.1, 0.2], [0.05, 0.15]])
print(f"\nCorrelated joint distribution:")
print(joint_corr)
print(f"  p_X = {marginal_fst(joint_corr)}")
print(f"  p_Y = {marginal_snd(joint_corr)}")
print(f"  H_∞(X) = {min_entropy(marginal_fst(joint_corr)):.4f}")
print(f"  H_∞(X|Y) = {cond_min_entropy(joint_corr):.4f}")
print(f"  I_∞(X;Y) = {tropical_mi(joint_corr):.4f}")
print(f"  I_∞ ≥ 0? {tropical_mi(joint_corr) >= -1e-10}")

# Perfectly correlated
joint_perf = np.array([[0.5, 0.0], [0.0, 0.5]])
print(f"\nPerfectly correlated (X=Y):")
print(joint_perf)
print(f"  H_∞(X) = {min_entropy(marginal_fst(joint_perf)):.4f}")
print(f"  H_∞(X|Y) = {cond_min_entropy(joint_perf):.4f}")
print(f"  I_∞(X;Y) = {tropical_mi(joint_perf):.4f}")
print(f"  I_∞ = H_∞(X)? {np.isclose(tropical_mi(joint_perf), min_entropy(marginal_fst(joint_perf)))}")

# ============================================================
# Demo 4: Data Processing Inequality
# ============================================================
print("\n" + "=" * 60)
print("DEMO 4: Data Processing Inequality")
print("=" * 60)

joint = np.array([
    [0.3, 0.05, 0.05, 0.1],
    [0.05, 0.2, 0.1, 0.05],
    [0.02, 0.03, 0.03, 0.02]
])
print(f"\nJoint distribution p(X,Y) on 3×4:")
print(joint)

mi_original = tropical_mi(joint)
print(f"\nI_∞(X;Y) = {mi_original:.4f}")

# Coarsen Y: merge columns {0,1} → 0 and {2,3} → 1
f = {0: 0, 1: 0, 2: 1, 3: 1}
joint_coarse = pushforward_snd(joint, f)
print(f"\nAfter coarsening Y (merge columns 0,1 and 2,3):")
print(joint_coarse)

mi_coarse = tropical_mi(joint_coarse)
print(f"I_∞(X;f(Y)) = {mi_coarse:.4f}")
print(f"I_∞(X;f(Y)) ≤ I_∞(X;Y)? {mi_coarse <= mi_original + 1e-10}")
print(f"Information lost by coarsening: {mi_original - mi_coarse:.4f} bits")

# Further coarsen: merge all into one
g = {0: 0, 1: 0}
joint_trivial = pushforward_snd(joint_coarse, g)
mi_trivial = tropical_mi(joint_trivial)
print(f"\nAfter trivial coarsening (all Y → single value):")
print(f"I_∞(X;const) = {mi_trivial:.6f}")
print(f"I_∞ = 0? {np.isclose(mi_trivial, 0)}")

# ============================================================
# Demo 5: Privacy Application
# ============================================================
print("\n" + "=" * 60)
print("DEMO 5: Privacy Application — Adversarial Guessing Bounds")
print("=" * 60)

# Simulate a "private" dataset with a mechanism
# X = secret, Y = observed output
joint_priv = np.array([
    [0.08, 0.07, 0.06, 0.05, 0.04],
    [0.05, 0.06, 0.08, 0.06, 0.05],
    [0.04, 0.05, 0.06, 0.07, 0.08]
])

p_x = marginal_fst(joint_priv)
agm = adversarial_guess_mass(joint_priv)
h_cond = cond_min_entropy(joint_priv)
mi = tropical_mi(joint_priv)

print(f"\nPrivacy mechanism (3 secrets × 5 outputs):")
print(f"  Prior p_X = {p_x}")
print(f"  H_∞(X) = {min_entropy(p_x):.4f} bits")
print(f"  H_∞(X|Y) = {h_cond:.4f} bits")
print(f"  I_∞(X;Y) = {mi:.4f} bits")
print(f"  Adversarial success rate = {agm:.4f}")
print(f"  Privacy guarantee: adversary succeeds with prob ≤ {agm:.4f}")
print(f"  (Without observing Y: prob ≤ {max_mass(p_x):.4f})")
print(f"  Information leakage: {mi:.4f} bits")

# ============================================================
# Demo 6: Comparison of Naive vs Operational MI
# ============================================================
print("\n" + "=" * 60)
print("DEMO 6: Naive vs Operational Tropical MI")
print("=" * 60)

# The naive definition H_∞(X) + H_∞(Y) - H_∞(X,Y) can be NEGATIVE
joint_anti = np.array([
    [0.0, 0.3],
    [0.3, 0.4]
])

p_x = marginal_fst(joint_anti)
p_y = marginal_snd(joint_anti)

naive_mi = min_entropy(p_x) + min_entropy(p_y) - min_entropy(joint_anti.flatten())
operational_mi = tropical_mi(joint_anti)

print(f"\nAnti-correlated distribution:")
print(joint_anti)
print(f"  p_X = {p_x}, p_Y = {p_y}")
print(f"  H_∞(X) = {min_entropy(p_x):.4f}")
print(f"  H_∞(Y) = {min_entropy(p_y):.4f}")
print(f"  H_∞(X,Y) = {min_entropy(joint_anti.flatten()):.4f}")
print(f"  Naive MI = H_∞(X) + H_∞(Y) - H_∞(X,Y) = {naive_mi:.4f}  ← NEGATIVE!")
print(f"  Operational MI = H_∞(X) - H_∞(X|Y) = {operational_mi:.4f}  ← always ≥ 0 ✓")
print(f"\n  This demonstrates why the operational definition is essential:")
print(f"  the naive formula can produce nonsensical negative values.")

print("\n" + "=" * 60)
print("All demonstrations completed successfully!")
print("=" * 60)


#!/usr/bin/env python3
"""
Tropical Mutual Information — Visualizations

Generate publication-quality figures for the research paper.
"""
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def plot_mi_landscape():
    """Plot I_∞(X;Y) as a function of joint distribution parameters."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    # Plot 1: MI vs correlation strength for 2x2 case
    ax = axes[0]
    correlations = np.linspace(0, 0.49, 100)
    mi_values = []
    for c in correlations:
        joint = np.array([[0.5 - c, c], [c, 0.5 - c]])
        p_x = joint.sum(axis=1)
        agm = np.sum(np.max(joint, axis=0))
        mi = -np.log2(np.max(p_x)) - (-np.log2(agm))
        mi_values.append(mi)

    ax.plot(correlations, mi_values, 'b-', linewidth=2)
    ax.set_xlabel('Correlation parameter c', fontsize=12)
    ax.set_ylabel('I_∞(X;Y) [bits]', fontsize=12)
    ax.set_title('MI vs Correlation (2×2)', fontsize=13)
    ax.grid(True, alpha=0.3)

    # Plot 2: MI vs alphabet size for identity channel
    ax = axes[1]
    sizes = range(2, 33)
    mi_identity = []
    mi_half_noise = []
    for n in sizes:
        # Identity channel (no noise)
        joint_id = np.eye(n) / n
        p_x = joint_id.sum(axis=1)
        agm = np.sum(np.max(joint_id, axis=0))
        mi_identity.append(-np.log2(np.max(p_x)) - (-np.log2(agm)))

        # 50% noise channel
        noise = 0.5
        joint_noise = (np.eye(n) * (1-noise) + noise/n) / n
        p_x = joint_noise.sum(axis=1)
        agm = np.sum(np.max(joint_noise, axis=0))
        mi_half_noise.append(-np.log2(np.max(p_x)) - (-np.log2(agm)))

    ax.plot(list(sizes), mi_identity, 'b-o', markersize=4, label='No noise', linewidth=2)
    ax.plot(list(sizes), mi_half_noise, 'r-s', markersize=4, label='50% noise', linewidth=2)
    ax.plot(list(sizes), [np.log2(n) for n in sizes], 'k--', alpha=0.5, label='log₂(n)')
    ax.set_xlabel('Alphabet size n', fontsize=12)
    ax.set_ylabel('I_∞(X;Y) [bits]', fontsize=12)
    ax.set_title('MI vs Alphabet Size', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    # Plot 3: DPI chain
    ax = axes[2]
    np.random.seed(42)
    n = 16
    joint = np.random.dirichlet(np.ones(n * n)).reshape(n, n)

    chain_mi = []
    current = joint.copy()
    dims = [n]
    while current.shape[1] > 1:
        p_x = current.sum(axis=1)
        agm = np.sum(np.max(current, axis=0))
        mi = -np.log2(np.max(p_x)) - (-np.log2(agm))
        chain_mi.append(mi)

        # Merge pairs
        new_cols = (current.shape[1] + 1) // 2
        new = np.zeros((current.shape[0], new_cols))
        for j in range(current.shape[1]):
            new[:, j // 2] += current[:, j]
        current = new
        dims.append(new_cols)

    # Last point
    p_x = current.sum(axis=1)
    agm = np.sum(np.max(current, axis=0))
    chain_mi.append(-np.log2(np.max(p_x)) - (-np.log2(agm)))

    ax.plot(range(len(chain_mi)), chain_mi, 'g-D', markersize=8, linewidth=2)
    ax.set_xlabel('Coarsening step', fontsize=12)
    ax.set_ylabel('I_∞(X;Y) [bits]', fontsize=12)
    ax.set_title('DPI: MI Under Progressive Coarsening', fontsize=13)
    ax.set_xticks(range(len(chain_mi)))
    ax.set_xticklabels([f'{d}' for d in dims], fontsize=9)
    ax.set_xlabel('Output dimension', fontsize=12)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(bottom=0)

    plt.tight_layout()
    plt.savefig('mi_landscape.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: mi_landscape.png")


def plot_theorem_overview():
    """Create an overview diagram of the theorem dependencies."""
    fig, ax = plt.subplots(figsize=(12, 8))
    ax.set_xlim(0, 12)
    ax.set_ylim(0, 10)
    ax.set_aspect('equal')
    ax.axis('off')

    # Draw boxes and arrows for theorem dependency graph
    boxes = {
        'maxMass': (2, 9, 'maxMass\nmax_x p(x)'),
        'minEntropy': (6, 9, 'minEntropy\n-log(maxMass)'),
        'marginal': (2, 7, 'marginalFst/Snd\nΣ_y p(x,y)'),
        'joint_le': (2, 5, 'maxMass ≤\nmarginal maxMass'),
        'agm': (6, 7, 'adversarialGuessMass\nΣ_y max_x p(x,y)'),
        'condME': (6, 5, 'condMinEntropy\n-log(AGM)'),
        'product': (10, 7, 'H_∞(X⊗Y) =\nH_∞(X)+H_∞(Y)'),
        'MI_nonneg': (4, 3, 'I_∞(X;Y) ≥ 0'),
        'DPI': (8, 3, 'I_∞(X;f(Y)) ≤\nI_∞(X;Y)'),
        'MI_indep': (6, 1, 'I_∞ = 0\nfor independence'),
    }

    for key, (x, y, text) in boxes.items():
        color = '#E3F2FD' if key in ['MI_nonneg', 'DPI', 'MI_indep'] else '#FFF9C4'
        if key in ['MI_nonneg', 'DPI']:
            color = '#C8E6C9'
        ax.add_patch(plt.Rectangle((x-1.3, y-0.6), 2.6, 1.2,
                                    facecolor=color, edgecolor='#333',
                                    linewidth=1.5, zorder=2))
        ax.text(x, y, text, ha='center', va='center', fontsize=8,
                fontweight='bold', zorder=3)

    # Arrows (dependency edges)
    edges = [
        ('maxMass', 'minEntropy'),
        ('maxMass', 'marginal'),
        ('marginal', 'joint_le'),
        ('maxMass', 'agm'),
        ('agm', 'condME'),
        ('joint_le', 'MI_nonneg'),
        ('condME', 'MI_nonneg'),
        ('condME', 'DPI'),
        ('agm', 'DPI'),
        ('product', 'MI_indep'),
        ('MI_nonneg', 'MI_indep'),
    ]

    for src, dst in edges:
        sx, sy, _ = boxes[src]
        dx, dy, _ = boxes[dst]
        ax.annotate('', xy=(dx, dy + 0.6), xytext=(sx, sy - 0.6),
                    arrowprops=dict(arrowstyle='->', color='#666',
                                   lw=1.5, connectionstyle='arc3,rad=0.1'))

    ax.set_title('Tropical Mutual Information — Theorem Dependency Graph',
                fontsize=16, fontweight='bold', pad=20)

    plt.tight_layout()
    plt.savefig('theorem_graph.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: theorem_graph.png")


if __name__ == '__main__':
    plot_mi_landscape()
    plot_theorem_overview()
    print("All visualizations generated!")

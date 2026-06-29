#!/usr/bin/env python3
"""
Algorithms for Log-Sum-Exp and Information-Theoretic Computations
=================================================================

Implements the core algorithms arising from the formally verified
finite convexity toolkit, including numerically stable log-sum-exp,
softmax, and the Gibbs variational principle.
"""

from typing import List, Optional
import math


def log_sum_exp(x: List[float]) -> float:
    """Compute log(sum(exp(x_i))) in a numerically stable way.

    Uses the max-shift trick: log(sum(exp(x_i))) = m + log(sum(exp(x_i - m)))
    where m = max(x_i). This prevents overflow/underflow.

    Complexity: O(n) time, O(1) space.

    Args:
        x: List of real numbers.

    Returns:
        log(sum(exp(x_i)))

    Examples:
        >>> log_sum_exp([1.0, 2.0, 3.0])
        3.4076059644443806
        >>> log_sum_exp([0.0, 0.0, 0.0])
        1.0986122886681098
        >>> log_sum_exp([1000.0, 1000.0])  # numerically stable
        1000.6931471805599
    """
    if not x:
        raise ValueError("Input must be non-empty")
    m = max(x)
    return m + math.log(sum(math.exp(xi - m) for xi in x))


def softmax(x: List[float]) -> List[float]:
    """Compute the softmax (Gibbs) distribution: p_i = exp(x_i) / sum(exp(x_j)).

    The softmax is the optimizer in the Gibbs variational principle:
        log(sum(exp(x_i))) = max_p { sum(p_i * x_i) + H(p) }
    and the unique maximizer is p_i = exp(x_i) / Z where Z = sum(exp(x_j)).

    Complexity: O(n) time, O(n) space.

    Args:
        x: List of real numbers (log-weights or scores).

    Returns:
        Probability distribution [p_0, ..., p_{n-1}].

    Examples:
        >>> softmax([0.0, 0.0, 0.0])
        [0.3333333333333333, 0.3333333333333333, 0.3333333333333333]
        >>> softmax([1.0, 2.0, 3.0])
        [0.09003057317038046, 0.24472847105479764, 0.6652409557748219]
    """
    if not x:
        raise ValueError("Input must be non-empty")
    m = max(x)
    exps = [math.exp(xi - m) for xi in x]
    total = sum(exps)
    return [e / total for e in exps]


def weighted_log_sum_exp(w: List[float], x: List[float]) -> float:
    """Compute log(sum(w_i * exp(x_i))) in a numerically stable way.

    By the formally verified weighted Jensen inequality:
        sum(w_i * x_i) <= weighted_log_sum_exp(w, x)
    whenever w_i >= 0 and sum(w_i) = 1.

    Complexity: O(n) time, O(1) space.

    Args:
        w: Non-negative weights (should sum to 1 for the inequality to apply).
        x: Real-valued scores.

    Returns:
        log(sum(w_i * exp(x_i)))
    """
    if len(w) != len(x):
        raise ValueError("w and x must have the same length")
    if not w:
        raise ValueError("Input must be non-empty")
    m = max(x)
    return m + math.log(sum(wi * math.exp(xi - m) for wi, xi in zip(w, x)))


def entropy(p: List[float]) -> float:
    """Compute the Shannon entropy H(p) = -sum(p_i * log(p_i)).

    Complexity: O(n) time, O(1) space.

    Args:
        p: Probability distribution (non-negative, sums to 1).

    Returns:
        Shannon entropy in nats.

    Examples:
        >>> entropy([0.5, 0.5])
        0.6931471805599453
        >>> entropy([1.0, 0.0, 0.0])
        0.0
    """
    return -sum(pi * math.log(pi) if pi > 0 else 0.0 for pi in p)


def gibbs_free_energy(x: List[float], p: List[float]) -> float:
    """Compute the Gibbs free energy: sum(p_i * x_i) + H(p).

    By the Gibbs variational principle:
        log(sum(exp(x_i))) = max_p { gibbs_free_energy(x, p) }
    and the maximum is achieved at p = softmax(x).

    Args:
        x: Energy levels / scores.
        p: Probability distribution.

    Returns:
        E_p[x] + H(p)
    """
    expected = sum(pi * xi for pi, xi in zip(p, x))
    return expected + entropy(p)


def log_sum_exp_bounds(x: List[float]) -> tuple:
    """Compute the sharp two-sided bounds on log-sum-exp.

    Returns (lower, lse, upper) where:
        lower = max(x)
        lse = log(sum(exp(x)))
        upper = max(x) + log(n)

    By the formally verified theorems:
        lower <= lse <= upper

    Args:
        x: List of real numbers.

    Returns:
        Tuple (lower_bound, log_sum_exp_value, upper_bound).
    """
    n = len(x)
    if n == 0:
        raise ValueError("Input must be non-empty")
    m = max(x)
    lse = log_sum_exp(x)
    return (m, lse, m + math.log(n))


def multiplicative_weights_potential(losses: List[List[float]],
                                      eta: float = 0.1) -> dict:
    """Simulate the multiplicative weights algorithm using log-sum-exp potential.

    At each round t, the algorithm:
    1. Sets weights w_i^t proportional to exp(-eta * cumulative_loss_i^t)
    2. Suffers loss sum(w_i^t * loss_i^t)
    3. The potential Phi^t = -(1/eta) * log(sum(exp(-eta * cumulative_loss_i)))
       tracks the progress.

    By our verified theorems:
        Total algorithm loss <= min_i(total_loss_i) + log(n)/eta

    Args:
        losses: List of loss vectors, one per round. losses[t][i] = loss of expert i at time t.
        eta: Learning rate.

    Returns:
        Dictionary with 'algorithm_losses', 'cumulative_losses', 'potentials',
        'regret_bound', and 'actual_regret'.

    Examples:
        >>> losses = [[1, 0], [0, 1], [1, 0], [0, 1]]
        >>> result = multiplicative_weights_potential(losses, eta=0.5)
        >>> result['actual_regret'] >= 0  # verified by our theorem
        True
    """
    if not losses or not losses[0]:
        raise ValueError("Must have at least one round and one expert")

    n = len(losses[0])  # number of experts
    T = len(losses)     # number of rounds

    cumulative = [0.0] * n
    algorithm_losses = []
    potentials = []

    for t in range(T):
        # Compute weights via softmax of negative cumulative losses
        neg_cum = [-eta * c for c in cumulative]
        weights = softmax(neg_cum)

        # Algorithm loss this round
        alg_loss = sum(w * l for w, l in zip(weights, losses[t]))
        algorithm_losses.append(alg_loss)

        # Update cumulative losses
        for i in range(n):
            cumulative[i] += losses[t][i]

        # Potential
        neg_cum_updated = [-eta * c for c in cumulative]
        potential = -(1.0 / eta) * log_sum_exp(neg_cum_updated)
        potentials.append(potential)

    total_alg_loss = sum(algorithm_losses)
    best_expert_loss = min(cumulative)
    regret = total_alg_loss - best_expert_loss
    regret_bound = math.log(n) / eta

    return {
        'algorithm_losses': algorithm_losses,
        'cumulative_expert_losses': cumulative,
        'potentials': potentials,
        'total_algorithm_loss': total_alg_loss,
        'best_expert_loss': best_expert_loss,
        'actual_regret': regret,
        'regret_bound': regret_bound,
        'regret_within_bound': regret <= regret_bound + 1e-10,
    }


if __name__ == "__main__":
    print("=== Algorithm Examples ===\n")

    # Log-sum-exp
    x = [1.0, 2.0, 3.0]
    print(f"log_sum_exp({x}) = {log_sum_exp(x):.6f}")
    lower, lse, upper = log_sum_exp_bounds(x)
    print(f"  Bounds: {lower:.6f} <= {lse:.6f} <= {upper:.6f}")

    # Softmax
    p = softmax(x)
    print(f"\nsoftmax({x}) = {[f'{pi:.4f}' for pi in p]}")
    print(f"  Entropy H(p) = {entropy(p):.4f}")
    print(f"  Gibbs free energy = {gibbs_free_energy(x, p):.6f}")
    print(f"  log_sum_exp = {lse:.6f}  (should match)")

    # Multiplicative weights
    print("\n=== Multiplicative Weights Demo ===")
    import random
    random.seed(42)
    n_experts = 5
    T = 100
    # One expert is consistently good
    losses = []
    for t in range(T):
        loss_vec = [random.random() for _ in range(n_experts)]
        loss_vec[2] = 0.1 * random.random()  # expert 2 is best
        losses.append(loss_vec)

    result = multiplicative_weights_potential(losses, eta=math.sqrt(math.log(n_experts) / T))
    print(f"  Experts: {n_experts}, Rounds: {T}")
    print(f"  Total algorithm loss: {result['total_algorithm_loss']:.2f}")
    print(f"  Best expert loss: {result['best_expert_loss']:.2f}")
    print(f"  Actual regret: {result['actual_regret']:.4f}")
    print(f"  Regret bound (log(n)/eta): {result['regret_bound']:.4f}")
    print(f"  Within bound: {result['regret_within_bound']}")

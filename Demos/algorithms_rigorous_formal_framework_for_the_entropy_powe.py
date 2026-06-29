"""
Entropy Power Inequality: Core Algorithms

Type-hinted implementations of information-theoretic quantities and bounds.
"""

import math
from typing import List, Tuple


def shannon_entropy(pmf: List[float]) -> float:
    """Compute Shannon entropy H(p) = -Σ p_i log(p_i).

    Convention: 0 log 0 = 0.

    Args:
        pmf: Probability mass function (non-negative, sums to 1).

    Returns:
        Shannon entropy in nats (natural log base).
    """
    return -sum(p * math.log(p) if p > 0 else 0.0 for p in pmf)


def kl_divergence(p: List[float], q: List[float]) -> float:
    """Compute KL divergence D_KL(p || q) = Σ p_i log(p_i / q_i).

    Requires q_i > 0 for all i where p_i > 0.

    Args:
        p: First distribution.
        q: Second distribution (fully supported).

    Returns:
        KL divergence (non-negative by Gibbs' inequality).
    """
    assert len(p) == len(q), "Distributions must have same support size"
    return sum(
        pi * math.log(pi / qi) if pi > 0 else 0.0
        for pi, qi in zip(p, q)
    )


def collision_entropy(pmf: List[float]) -> float:
    """Compute collision (Rényi-2) entropy H₂(p) = -log(Σ p_i²).

    Args:
        pmf: Probability mass function.

    Returns:
        Collision entropy. Always ≤ Shannon entropy (Rényi-Shannon ordering).
    """
    sq_sum = sum(p ** 2 for p in pmf)
    return -math.log(sq_sum) if sq_sum > 0 else float('inf')


def entropy_power(pmf: List[float], n: int) -> float:
    """Compute entropy power N(p) = exp(2H(p)/n).

    Args:
        pmf: Probability mass function.
        n: Support size (dimension analog).

    Returns:
        Entropy power. Bounded above by n^(2/n).
    """
    h = shannon_entropy(pmf)
    return math.exp(2 * h / n)


def volume_entropy_power(card: int, dim: int) -> float:
    """Compute volume entropy power VEP(k, d) = k^(2/d).

    This bridges information theory and convex geometry:
    the EPI N(X+Y) ≥ N(X) + N(Y) is the analog of
    Brunn-Minkowski |A+B|^(1/d) ≥ |A|^(1/d) + |B|^(1/d).

    Args:
        card: Set cardinality.
        dim: Ambient dimension.

    Returns:
        Volume entropy power.
    """
    return card ** (2.0 / dim)


def renyi_entropy(pmf: List[float], alpha: float) -> float:
    """Compute Rényi entropy of order α: H_α(p) = (1/(1-α)) log(Σ p_i^α).

    Special cases:
        α → 1: Shannon entropy
        α = 2: Collision entropy
        α → ∞: Min-entropy -log(max p_i)

    Args:
        pmf: Probability mass function.
        alpha: Order parameter (> 0, ≠ 1).

    Returns:
        Rényi entropy of the given order.
    """
    assert alpha > 0 and alpha != 1.0, "α must be > 0 and ≠ 1"
    power_sum = sum(p ** alpha for p in pmf if p > 0)
    return math.log(power_sum) / (1 - alpha)


def verify_gibbs_inequality(p: List[float], q: List[float]) -> Tuple[float, bool]:
    """Verify Gibbs' inequality: D_KL(p || q) ≥ 0.

    Args:
        p, q: Probability distributions.

    Returns:
        (kl_value, is_nonneg): KL divergence and whether it's ≥ 0.
    """
    kl = kl_divergence(p, q)
    return kl, kl >= -1e-12  # Allow tiny numerical errors


def verify_max_entropy(pmf: List[float]) -> Tuple[float, float, bool]:
    """Verify maximum entropy theorem: H(p) ≤ log(n).

    Args:
        pmf: Probability mass function on n outcomes.

    Returns:
        (entropy, log_n, is_le): Entropy, log(n), and whether H ≤ log(n).
    """
    n = len(pmf)
    h = shannon_entropy(pmf)
    log_n = math.log(n)
    return h, log_n, h <= log_n + 1e-12


def verify_renyi_shannon_ordering(pmf: List[float]) -> Tuple[float, float, bool]:
    """Verify Rényi-Shannon ordering: H₂(p) ≤ H(p).

    Args:
        pmf: Probability mass function.

    Returns:
        (h2, h1, is_le): Collision entropy, Shannon entropy, and whether H₂ ≤ H.
    """
    h2 = collision_entropy(pmf)
    h1 = shannon_entropy(pmf)
    return h2, h1, h2 <= h1 + 1e-12


def test_entropy_power_ratio_conjecture(n: int, num_samples: int = 10000) -> Tuple[float, bool]:
    """Test the entropy power ratio conjecture: H₂(p) ≥ H(p)/2.

    Generates random distributions and checks the bound.

    Args:
        n: Support size.
        num_samples: Number of random distributions to test.

    Returns:
        (min_ratio, conjecture_holds): Minimum ratio found and whether
        all tested distributions satisfy the conjecture.
    """
    import random
    min_ratio = float('inf')
    conjecture_holds = True

    for _ in range(num_samples):
        # Generate random distribution via Dirichlet(1,...,1)
        raw = [random.expovariate(1.0) for _ in range(n)]
        total = sum(raw)
        pmf = [x / total for x in raw]

        h1 = shannon_entropy(pmf)
        h2 = collision_entropy(pmf)

        if h1 > 1e-10:
            ratio = h2 / h1
            min_ratio = min(min_ratio, ratio)
            if ratio < 0.5 - 1e-10:
                conjecture_holds = False

    return min_ratio, conjecture_holds

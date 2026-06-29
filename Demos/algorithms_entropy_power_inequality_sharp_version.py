"""
Algorithms for Entropy Power Inequality computations.

Implements Shannon entropy, Rényi entropy, entropy power,
Brunn-Minkowski defect, and Gaussian proximity computations.
"""

import math
from typing import List, Tuple, Optional


def shannon_entropy(p: List[float]) -> float:
    """Compute Shannon entropy H(p) = -sum p_i log p_i.

    Args:
        p: Probability distribution (non-negative, sums to 1).

    Returns:
        Shannon entropy in nats (using natural logarithm).
    """
    h = 0.0
    for pi in p:
        if pi > 0:
            h -= pi * math.log(pi)
    return h


def renyi_entropy(p: List[float], alpha: float = 2.0) -> float:
    """Compute Rényi entropy H_alpha(p) = 1/(1-alpha) * log(sum p_i^alpha).

    Args:
        p: Probability distribution.
        alpha: Order parameter (must be > 0, != 1).

    Returns:
        Rényi entropy of order alpha.
    """
    if abs(alpha - 1.0) < 1e-10:
        return shannon_entropy(p)
    s = sum(pi ** alpha for pi in p if pi > 0)
    if s <= 0:
        return 0.0
    return (1.0 / (1.0 - alpha)) * math.log(s)


def entropy_power(p: List[float], d: int = 1) -> float:
    """Compute entropy power N(p) = exp(2*H(p)/d).

    Args:
        p: Probability distribution.
        d: Dimension parameter.

    Returns:
        Entropy power.
    """
    h = shannon_entropy(p)
    return math.exp(2 * h / d)


def gaussian_proximity(p: List[float]) -> float:
    """Compute Gaussian proximity delta(p) = log(n) - H(p).

    Measures how far p is from the uniform (maximum entropy) distribution.

    Args:
        p: Probability distribution on n elements.

    Returns:
        Non-negative Gaussian proximity.
    """
    n = len(p)
    if n <= 1:
        return 0.0
    return math.log(n) - shannon_entropy(p)


def brunn_minkowski_defect(card_a: int, card_b: int, card_sum: int,
                           d: int = 1) -> float:
    """Compute Brunn-Minkowski defect.

    delta = |A+B|^{1/d} - |A|^{1/d} - |B|^{1/d}

    Args:
        card_a: Cardinality of set A.
        card_b: Cardinality of set B.
        card_sum: Cardinality of sumset A+B.
        d: Dimension.

    Returns:
        BM defect (should be >= 0 by BM inequality).
    """
    return (card_sum ** (1.0 / d) - card_a ** (1.0 / d) - card_b ** (1.0 / d))


def volume_entropy_power(card: int, d: int = 1) -> float:
    """Compute volume entropy power = card^{2/d}.

    Args:
        card: Cardinality of finite set.
        d: Dimension.

    Returns:
        Volume entropy power.
    """
    return card ** (2.0 / d)


def epi_profile(n_a: float, n_b: float, steps: int = 100) -> List[Tuple[float, float]]:
    """Generate an EPI profile path for Gaussian distributions.

    For Gaussians with entropy powers N_A and N_B, the path along the
    Ornstein-Uhlenbeck semigroup gives:
    N(t) = (1-t)*N_A + t*N_B (linear interpolation, concave)

    Args:
        n_a: Entropy power at t=0.
        n_b: Entropy power at t=1.
        steps: Number of discretization points.

    Returns:
        List of (t, N(t)) pairs.
    """
    result = []
    for i in range(steps + 1):
        t = i / steps
        # For Gaussians, the optimal transport gives linear interpolation
        n_t = (1 - t) * n_a + t * n_b
        result.append((t, n_t))
    return result


def discrete_convolution(p: List[float], q: List[float]) -> List[float]:
    """Compute discrete convolution of two distributions.

    Args:
        p: First distribution (on {0, ..., m-1}).
        q: Second distribution (on {0, ..., n-1}).

    Returns:
        Convolution p*q (on {0, ..., m+n-2}).
    """
    m, n = len(p), len(q)
    result = [0.0] * (m + n - 1)
    for i in range(m):
        for j in range(n):
            result[i + j] += p[i] * q[j]
    return result


def verify_epi_discrete(p: List[float], q: List[float], d: int = 1) -> dict:
    """Verify the EPI for two discrete distributions.

    Checks N(p*q) >= N(p) + N(q) and reports the deficit.

    Args:
        p: First distribution.
        q: Second distribution.
        d: Dimension parameter.

    Returns:
        Dictionary with entropy powers and deficit.
    """
    conv = discrete_convolution(p, q)
    n_p = entropy_power(p, d)
    n_q = entropy_power(q, d)
    n_conv = entropy_power(conv, d)

    return {
        "N_p": n_p,
        "N_q": n_q,
        "N_conv": n_conv,
        "sum": n_p + n_q,
        "deficit": n_conv - (n_p + n_q),
        "epi_holds": n_conv >= n_p + n_q - 1e-10,
        "am_gm_bound": 2 * math.sqrt(n_p * n_q),
    }


def stability_analysis(n: int, num_samples: int = 1000) -> List[dict]:
    """Analyze stability of EPI for random distributions on Fin n.

    Generates random distributions, computes Gaussian proximity,
    and tests the stability conjecture.

    Args:
        n: Support size.
        num_samples: Number of random distributions to test.

    Returns:
        List of analysis results.
    """
    import random
    results = []
    for _ in range(num_samples):
        # Generate random distribution via Dirichlet(1,...,1)
        raw = [random.expovariate(1.0) for _ in range(n)]
        total = sum(raw)
        p = [x / total for x in raw]

        gp = gaussian_proximity(p)
        h = shannon_entropy(p)
        h2 = renyi_entropy(p, 2.0)

        results.append({
            "gaussian_proximity": gp,
            "shannon_entropy": h,
            "renyi_2": h2,
            "renyi_gap": h - h2,  # Should be >= 0 by our theorem
        })

    return results

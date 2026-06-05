"""
Algorithms for Graded Probability Measures

Type-hinted implementations of the core algorithms:
1. GPM construction (tie-breaking refinement)
2. Lexicographic comparison
3. Convex combination
4. Graded entropy computation
"""

from typing import List, Tuple, Set, Optional
import math


def construct_tiebreaking_gpm(
    p: List[float],
) -> Tuple[List[float], List[float]]:
    """Construct a GPM that refines p and breaks all ties.

    Args:
        p: Standard probability distribution (nonneg, sums to 1).

    Returns:
        (std, inf): The standard part (= p) and infinitesimal correction.

    Algorithm:
        1. Set std = p
        2. Set raw[i] = i - (n-1)/2 (centered, injective, zero-sum)
        3. Scale to make corrections small relative to probability gaps
        4. Return (std, scaled_raw)
    """
    n = len(p)
    if n == 0:
        return ([], [])
    if n == 1:
        return (p[:], [0.0])

    # Step 1: Centered linear correction (sums to 0, injective)
    mean = (n - 1) / 2.0
    raw = [i - mean for i in range(n)]

    # Step 2: Find minimum gap in standard probabilities
    sorted_p = sorted(set(p))
    min_gap = min(
        (sorted_p[i + 1] - sorted_p[i] for i in range(len(sorted_p) - 1)),
        default=1.0,
    )

    # Step 3: Scale corrections to be infinitesimal relative to gaps
    max_raw = max(abs(r) for r in raw)
    scale = min(min_gap / (10 * max_raw), 0.001) if max_raw > 0 else 0.001
    inf_vals = [scale * r for r in raw]

    # Step 4: Fix floating point drift
    drift = sum(inf_vals)
    inf_vals[-1] -= drift

    return (p[:], inf_vals)


def lexicographic_compare(
    mu_std: List[float],
    mu_inf: List[float],
    i: int,
    j: int,
) -> int:
    """Compare outcomes i and j under GPM (mu_std, mu_inf).

    Args:
        mu_std: Standard probabilities.
        mu_inf: Infinitesimal corrections.
        i, j: Outcome indices.

    Returns:
        1 if i > j, -1 if i < j, 0 if tied.

    Algorithm:
        1. Compare std parts first
        2. If tied, compare inf parts
    """
    if mu_std[i] > mu_std[j]:
        return 1
    elif mu_std[i] < mu_std[j]:
        return -1
    elif mu_inf[i] > mu_inf[j]:
        return 1
    elif mu_inf[i] < mu_inf[j]:
        return -1
    else:
        return 0


def lex_prob(
    mu_std: List[float],
    mu_inf: List[float],
    S: Set[int],
) -> Tuple[float, float]:
    """Compute the graded probability of subset S.

    Args:
        mu_std: Standard probabilities.
        mu_inf: Infinitesimal corrections.
        S: Subset of outcome indices.

    Returns:
        (std_sum, inf_sum): The graded probability pair.
    """
    std_sum = sum(mu_std[i] for i in S)
    inf_sum = sum(mu_inf[i] for i in S)
    return (std_sum, inf_sum)


def convex_combination(
    mu_std: List[float],
    mu_inf: List[float],
    nu_std: List[float],
    nu_inf: List[float],
    t: float,
) -> Tuple[List[float], List[float]]:
    """Compute the convex combination (1-t)*mu + t*nu.

    Args:
        mu_std, mu_inf: First GPM.
        nu_std, nu_inf: Second GPM.
        t: Mixing parameter in [0, 1].

    Returns:
        (combined_std, combined_inf): The mixed GPM.
    """
    n = len(mu_std)
    combined_std = [(1 - t) * mu_std[i] + t * nu_std[i] for i in range(n)]
    combined_inf = [(1 - t) * mu_inf[i] + t * nu_inf[i] for i in range(n)]
    return (combined_std, combined_inf)


def graded_entropy(
    mu_std: List[float],
    mu_inf: List[float],
) -> Tuple[float, float]:
    """Compute the graded Shannon entropy H_ε(μ) to first order in ε.

    H_ε(μ) = H(μ₀) + ε · (−Σ μ₁(i) · (1 + log μ₀(i)))

    where H(μ₀) is the standard Shannon entropy.

    Args:
        mu_std: Standard probabilities (all positive for well-definedness).
        mu_inf: Infinitesimal corrections.

    Returns:
        (H0, H1): Standard entropy and infinitesimal correction.
    """
    n = len(mu_std)
    H0 = 0.0  # Standard Shannon entropy
    H1 = 0.0  # Infinitesimal correction

    for i in range(n):
        if mu_std[i] > 0:
            H0 -= mu_std[i] * math.log2(mu_std[i])
            H1 -= mu_inf[i] * (1 + math.log(mu_std[i]))

    return (H0, H1)


def ranking(
    mu_std: List[float],
    mu_inf: List[float],
) -> List[int]:
    """Return outcomes ranked from most to least likely under the GPM.

    Args:
        mu_std: Standard probabilities.
        mu_inf: Infinitesimal corrections.

    Returns:
        List of outcome indices sorted by decreasing graded probability.
    """
    n = len(mu_std)
    indices = list(range(n))
    indices.sort(key=lambda i: (mu_std[i], mu_inf[i]), reverse=True)
    return indices


if __name__ == "__main__":
    # Example: Uniform distribution on 4 outcomes
    p = [0.25, 0.25, 0.25, 0.25]
    std, inf = construct_tiebreaking_gpm(p)
    print(f"Standard: {p}")
    print(f"Graded std: {std}")
    print(f"Graded inf: {inf}")
    print(f"Ranking: {ranking(std, inf)}")
    print(f"Entropy: H₀={graded_entropy(std, inf)[0]:.4f}, "
          f"H₁={graded_entropy(std, inf)[1]:.4f}")

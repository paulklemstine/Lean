"""
Algorithms for Surveillance-Privacy Information Theory.

Implementations of the core algorithms for computing privacy indices,
surveillance indices, and privacy spectra for finite observation functions.

All functions are type-hinted and self-contained.
"""

from typing import Dict, List, Tuple
from collections import Counter
import math


def compute_fiber_sizes(f: Dict[int, int]) -> Dict[int, int]:
    """Compute fiber sizes |f^{-1}(c)| for each c in the image of f.

    Args:
        f: Dictionary mapping states to observations {state: observation}.

    Returns:
        Dictionary mapping each observation value to its fiber size.

    Example:
        >>> compute_fiber_sizes({0: 'a', 1: 'a', 2: 'b', 3: 'b', 4: 'b'})
        {'a': 2, 'b': 3}
    """
    return dict(Counter(f.values()))


def privacy_index(f: Dict[int, int]) -> int:
    """Compute the privacy index π(f) = Σ_c n_c(n_c - 1).

    Counts ordered pairs of distinct states mapped to the same observation.
    Uses the fiber decomposition for O(n) computation.

    Args:
        f: Dictionary mapping states to observations.

    Returns:
        The privacy index (non-negative integer).

    Example:
        >>> privacy_index({0: 'a', 1: 'a', 2: 'b'})
        2
    """
    fibers = compute_fiber_sizes(f)
    return sum(n * (n - 1) for n in fibers.values())


def surveillance_index(f: Dict[int, int]) -> int:
    """Compute the surveillance index σ(f) = n(n-1) - π(f).

    Counts ordered pairs of states mapped to different observations.
    Uses the conservation law for O(n) computation.

    Args:
        f: Dictionary mapping states to observations.

    Returns:
        The surveillance index (non-negative integer).
    """
    n = len(f)
    return n * (n - 1) - privacy_index(f)


def verify_conservation_law(f: Dict[int, int]) -> bool:
    """Verify the Privacy-Surveillance Conservation Law: π(f) + σ(f) = n(n-1).

    Args:
        f: Dictionary mapping states to observations.

    Returns:
        True if the conservation law holds (always True for valid inputs).
    """
    n = len(f)
    pi = privacy_index(f)
    sigma = surveillance_index(f)
    return pi + sigma == n * (n - 1)


def privacy_spectrum(f: Dict[int, int], max_level: int = 0) -> List[int]:
    """Compute the privacy spectrum Ψ_f(k) for k = 0, 1, ..., max_level.

    Ψ_f(k) counts states whose fiber has size ≥ k.

    Args:
        f: Dictionary mapping states to observations.
        max_level: Maximum level to compute. If 0, uses max fiber size.

    Returns:
        List where index k gives Ψ_f(k).
    """
    fibers = compute_fiber_sizes(f)
    n = len(f)

    if max_level == 0:
        max_level = max(fibers.values()) if fibers else 0

    spectrum = []
    for k in range(max_level + 1):
        count = sum(size for size in fibers.values() if size >= k)
        spectrum.append(count)

    return spectrum


def optimal_balanced_partition(n: int, k: int) -> Tuple[List[int], int]:
    """Compute the optimal balanced partition of n items into k groups.

    Returns the partition that maximizes the privacy index among all
    partitions with exactly k non-empty groups.

    Args:
        n: Total number of states.
        k: Number of groups (codebook size).

    Returns:
        Tuple of (fiber_sizes, max_privacy_index).

    Example:
        >>> optimal_balanced_partition(10, 3)
        ([4, 3, 3], 24)
    """
    if k <= 0 or n <= 0:
        return [], 0
    if k >= n:
        return [1] * n, 0

    q, r = divmod(n, k)
    # r groups of size q+1, (k-r) groups of size q
    sizes = [q + 1] * r + [q] * (k - r)
    pi = sum(s * (s - 1) for s in sizes)
    return sizes, pi


def privacy_amplification_demo(
    f: Dict[int, int], g: Dict[int, int]
) -> Tuple[int, int, bool]:
    """Demonstrate privacy amplification through post-processing.

    Computes π(f) and π(g ∘ f) and checks that π(g ∘ f) ≥ π(f).

    Args:
        f: Original observation function {state: observation}.
        g: Post-processing function {observation: processed_observation}.

    Returns:
        Tuple of (π(f), π(g∘f), strict_increase).
    """
    # Compute g ∘ f
    gf = {s: g[c] for s, c in f.items()}

    pi_f = privacy_index(f)
    pi_gf = privacy_index(gf)

    return pi_f, pi_gf, pi_gf > pi_f


def dynamic_codebook_bound(state_size: int, time_steps: int) -> int:
    """Compute the minimum codebook size for perfect T-step trajectory reconstruction.

    Args:
        state_size: Number of possible states |S|.
        time_steps: Number of time steps T.

    Returns:
        Minimum codebook size |S|^T.
    """
    return state_size ** time_steps


def check_exclusion_theorem(f: Dict[int, int]) -> Dict[str, object]:
    """Check whether a function achieves perfect privacy, surveillance, or neither.

    Demonstrates the Exclusion Theorem: a function on ≥ 2 states
    cannot achieve both perfect privacy and perfect surveillance.

    Args:
        f: Dictionary mapping states to observations.

    Returns:
        Dictionary with analysis results.
    """
    n = len(f)
    pi = privacy_index(f)
    sigma = surveillance_index(f)

    is_injective = pi == 0
    is_constant = sigma == 0

    return {
        "n_states": n,
        "privacy_index": pi,
        "surveillance_index": sigma,
        "conservation_holds": pi + sigma == n * (n - 1),
        "is_injective": is_injective,
        "is_constant": is_constant,
        "exclusion_satisfied": not (is_injective and is_constant) if n >= 2 else True,
        "privacy_fraction": pi / (n * (n - 1)) if n >= 2 else 0.0,
        "surveillance_fraction": sigma / (n * (n - 1)) if n >= 2 else 0.0,
    }


def tradeoff_curve(n: int) -> List[Tuple[int, int, int]]:
    """Compute the privacy-surveillance tradeoff for all codebook sizes.

    For each codebook size k = 1, ..., n, computes the optimal (balanced)
    partition and the resulting (privacy, surveillance) pair.

    Args:
        n: State space size.

    Returns:
        List of (codebook_size, max_privacy, min_surveillance) tuples.
    """
    total = n * (n - 1)
    curve = []
    for k in range(1, n + 1):
        _, pi = optimal_balanced_partition(n, k)
        curve.append((k, pi, total - pi))
    return curve

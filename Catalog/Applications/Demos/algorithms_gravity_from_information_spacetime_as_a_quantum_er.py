"""
Algorithms for Holographic Gravity as Quantum Error Correction

Type-hinted implementations of the key computational structures.
"""

from typing import Dict, FrozenSet, List, Tuple, Callable
from itertools import combinations
import math


def compute_entropy_profile(
    n_sites: int,
    S_func: Callable[[FrozenSet[int]], float]
) -> Dict[FrozenSet[int], float]:
    """Compute the full entropy profile for n boundary sites.

    Args:
        n_sites: Number of boundary sites
        S_func: Entropy function on subsets

    Returns:
        Dictionary mapping each subset to its entropy
    """
    profile: Dict[FrozenSet[int], float] = {}
    sites = list(range(n_sites))
    for r in range(n_sites + 1):
        for subset in combinations(sites, r):
            fs = frozenset(subset)
            profile[fs] = S_func(fs)
    return profile


def syndrome_defect(
    S: Dict[FrozenSet[int], float],
    X: FrozenSet[int],
    Y: FrozenSet[int]
) -> float:
    """Compute syndrome defect δ(X,Y) = S(X) + S(Y) - S(X∩Y) - S(X∪Y).

    This is the discrete curvature between boundary regions X and Y.
    - δ = 0: flat geometry between X and Y
    - δ > 0: positive curvature (gravitational interaction)
    """
    return S[X] + S[Y] - S[X & Y] - S[X | Y]


def mutual_information(
    S: Dict[FrozenSet[int], float],
    X: FrozenSet[int],
    Y: FrozenSet[int]
) -> float:
    """Compute mutual information I(X:Y) = S(X) + S(Y) - S(X∪Y)."""
    return S[X] + S[Y] - S[X | Y]


def tripartite_information(
    S: Dict[FrozenSet[int], float],
    A: FrozenSet[int],
    B: FrozenSet[int],
    C: FrozenSet[int]
) -> float:
    """Compute tripartite information I₃(A:B:C).

    I₃ ≤ 0 characterizes holographic (monogamous) entanglement.
    I₃ > 0 is possible for generic quantum states (e.g., GHZ).
    """
    return (S[A] + S[B] + S[C]
            - S[A | B] - S[A | C] - S[B | C]
            + S[A | B | C])


def total_defect(
    S: Dict[FrozenSet[int], float],
    n_sites: int
) -> float:
    """Compute total defect Σ_{X,Y} δ(X,Y).

    Total defect = 0 ⟹ flat geometry (rigidity theorem).
    """
    all_subsets: List[FrozenSet[int]] = []
    for r in range(n_sites + 1):
        for subset in combinations(range(n_sites), r):
            all_subsets.append(frozenset(subset))
    return sum(
        syndrome_defect(S, X, Y)
        for X in all_subsets
        for Y in all_subsets
    )


def check_submodularity(
    S: Dict[FrozenSet[int], float],
    n_sites: int
) -> List[Tuple[FrozenSet[int], FrozenSet[int], float]]:
    """Check submodularity S(X)+S(Y) ≥ S(X∩Y)+S(X∪Y) for all pairs.

    Returns list of violations (X, Y, deficit) where deficit < 0.
    """
    violations: List[Tuple[FrozenSet[int], FrozenSet[int], float]] = []
    all_subsets: List[FrozenSet[int]] = []
    for r in range(n_sites + 1):
        for subset in combinations(range(n_sites), r):
            all_subsets.append(frozenset(subset))

    for X in all_subsets:
        for Y in all_subsets:
            deficit = S[X] + S[Y] - S[X & Y] - S[X | Y]
            if deficit < -1e-10:
                violations.append((X, Y, deficit))
    return violations


def check_mmi(
    S: Dict[FrozenSet[int], float],
    n_sites: int
) -> List[Tuple[FrozenSet[int], FrozenSet[int], FrozenSet[int], float]]:
    """Check MMI: I₃(A:B:C) ≤ 0 for all triples.

    Returns list of violations (A, B, C, I₃) where I₃ > 0.
    """
    violations = []
    all_subsets: List[FrozenSet[int]] = []
    for r in range(n_sites + 1):
        for subset in combinations(range(n_sites), r):
            all_subsets.append(frozenset(subset))

    for A in all_subsets:
        for B in all_subsets:
            for C in all_subsets:
                I3 = tripartite_information(S, A, B, C)
                if I3 > 1e-10:
                    violations.append((A, B, C, I3))
    return violations


def singleton_bound_check(n: int, k: int, d: int) -> bool:
    """Check quantum Singleton bound: 2d + k ≤ n + 2."""
    return 2 * d + k <= n + 2


def max_distance_from_area(
    area: float,
    n_qubits: int,
    planck_area: float = 1.0
) -> float:
    """Maximum code distance given boundary area and qubit count.

    D ≤ (N - area/(4·l_P²) + 2) / 2

    Under RT: S = area / (4G), and N = area / l_P² in natural units.
    """
    S = area / (4.0 * planck_area)
    return (n_qubits - S + 2) / 2.0


def rate_distance_curve(n: int) -> List[Tuple[float, float]]:
    """Compute the rate-distance tradeoff curve for an [[n,k,d]] code.

    Returns list of (rate, relative_distance) pairs on the Singleton bound.
    rate = k/n, relative_distance = d/n.
    """
    curve: List[Tuple[float, float]] = []
    for d in range(1, n // 2 + 2):
        k_max = n + 2 - 2 * d
        if k_max >= 0:
            curve.append((k_max / n, d / n))
    return curve

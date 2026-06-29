#!/usr/bin/env python3
"""
Algorithms for Berggren Orbit Dirichlet Series Analysis

Implements:
1. Berggren orbit enumeration and shell decomposition
2. Dirichlet series partial sum computation
3. Convergence threshold estimation
4. Transfer operator spectral analysis (finite approximation)
5. Collision entropy computation for key exchange
"""

import numpy as np
from typing import List, Tuple, Dict, Optional
from collections import defaultdict
import math


# ═══════════════════════════════════════════════════════════════════════
# 1. BERGGREN SEMIGROUP INFRASTRUCTURE
# ═══════════════════════════════════════════════════════════════════════

# Berggren generator matrices in O(2,1;ℤ)
BERGGREN_A = np.array([[ 1, -2,  2],
                        [ 2, -1,  2],
                        [ 2, -2,  3]], dtype=np.int64)

BERGGREN_B = np.array([[ 1,  2,  2],
                        [ 2,  1,  2],
                        [ 2,  2,  3]], dtype=np.int64)

BERGGREN_C = np.array([[-1,  2,  2],
                        [-2,  1,  2],
                        [-2,  2,  3]], dtype=np.int64)

BERGGREN_GENERATORS = [BERGGREN_A, BERGGREN_B, BERGGREN_C]
BERGGREN_ROOT = np.array([3, 4, 5], dtype=np.int64)


def enumerate_berggren_shell(depth: int,
                              root: np.ndarray = BERGGREN_ROOT
                              ) -> List[np.ndarray]:
    """
    Enumerate all triples in the depth-d Berggren shell S_d.

    Algorithm: BFS from root, applying all 3 generators at each step.
    Time: O(3^d), Space: O(3^d)

    Args:
        depth: Word length d
        root: Starting triple (default: (3,4,5))

    Returns:
        List of all triples reachable by words of length exactly d.
    """
    if depth == 0:
        return [root.copy()]

    current_shell = [root.copy()]
    for _ in range(depth):
        next_shell = []
        for v in current_shell:
            for g in BERGGREN_GENERATORS:
                next_shell.append(g @ v)
        current_shell = next_shell

    return current_shell


def enumerate_berggren_orbit(max_depth: int,
                              root: np.ndarray = BERGGREN_ROOT
                              ) -> Dict[int, List[np.ndarray]]:
    """
    Enumerate the Berggren orbit organized by depth shells.

    Returns:
        Dictionary mapping depth d to list of triples in S_d.
    """
    orbit = {}
    current = [root.copy()]
    orbit[0] = current

    for d in range(1, max_depth + 1):
        next_shell = []
        for v in current:
            for g in BERGGREN_GENERATORS:
                next_shell.append(g @ v)
        orbit[d] = next_shell
        current = next_shell

    return orbit


# ═══════════════════════════════════════════════════════════════════════
# 2. DIRICHLET SERIES COMPUTATION
# ═══════════════════════════════════════════════════════════════════════

def dirichlet_partial_sum(s: float, max_depth: int,
                           root: np.ndarray = BERGGREN_ROOT) -> float:
    """
    Compute the partial sum Z_B(s, D) = Σ_{d=0}^{D} Σ_{v∈S_d} H(v)^{-s}.

    Algorithm: Enumerate shells, sum height^{-s} contributions.
    Time: O(Σ_{d=0}^D 3^d) = O(3^D)

    Args:
        s: Dirichlet parameter
        max_depth: Maximum depth D
        root: Starting triple

    Returns:
        Partial sum of the Berggren Dirichlet series.
    """
    orbit = enumerate_berggren_orbit(max_depth, root)
    total = 0.0
    for d, shell in orbit.items():
        for v in shell:
            h = v[2]  # hypotenuse
            if h > 0:
                total += h ** (-s)
    return total


def dirichlet_shell_contributions(s: float, max_depth: int,
                                    root: np.ndarray = BERGGREN_ROOT
                                    ) -> List[float]:
    """
    Compute per-shell contributions to the Dirichlet series.

    Returns list where entry d = Σ_{v∈S_d} H(v)^{-s}.
    """
    orbit = enumerate_berggren_orbit(max_depth, root)
    contributions = []
    for d in range(max_depth + 1):
        shell = orbit[d]
        contrib = sum(v[2] ** (-s) for v in shell if v[2] > 0)
        contributions.append(contrib)
    return contributions


def dirichlet_convergence_ratio(s: float, max_depth: int) -> List[float]:
    """
    Compute successive ratios of shell contributions.

    If the series converges, these ratios should tend to a value < 1.
    The limiting ratio is shellDirichletRatio(3, α, s) = 3 · α^{-s}.
    """
    contribs = dirichlet_shell_contributions(s, max_depth)
    ratios = []
    for d in range(1, len(contribs)):
        if contribs[d - 1] > 0:
            ratios.append(contribs[d] / contribs[d - 1])
        else:
            ratios.append(float('inf'))
    return ratios


# ═══════════════════════════════════════════════════════════════════════
# 3. CONVERGENCE THRESHOLD ESTIMATION
# ═══════════════════════════════════════════════════════════════════════

def estimate_height_growth_factor(max_depth: int = 6) -> float:
    """
    Estimate the minimum height growth factor α.

    Algorithm: For each triple at each depth, compute H(g·v)/H(v)
    for each generator g, and take the global minimum.

    Time: O(Σ 3^d · 3) = O(3^{D+1})

    Returns:
        Minimum observed height growth ratio.
    """
    min_alpha = float('inf')
    orbit = enumerate_berggren_orbit(max_depth)

    for d, shell in orbit.items():
        for v in shell:
            h_v = v[2]
            if h_v <= 0:
                continue
            for g in BERGGREN_GENERATORS:
                w = g @ v
                h_w = w[2]
                ratio = h_w / h_v
                min_alpha = min(min_alpha, ratio)

    return min_alpha


def convergence_threshold(k: int = 3, alpha: Optional[float] = None) -> float:
    """
    Compute the abscissa of convergence σ₀ = log(k)/log(α).

    Args:
        k: Branching factor (default 3 for Berggren)
        alpha: Height growth factor (estimated if None)

    Returns:
        Critical exponent σ₀.
    """
    if alpha is None:
        alpha = estimate_height_growth_factor()
    return math.log(k) / math.log(alpha)


# ═══════════════════════════════════════════════════════════════════════
# 4. TRANSFER OPERATOR (FINITE APPROXIMATION)
# ═══════════════════════════════════════════════════════════════════════

def transfer_operator_matrix(s: float,
                              height_cocycles: Optional[np.ndarray] = None
                              ) -> np.ndarray:
    """
    Compute the 3×3 transfer operator matrix L_s.

    The (i,j) entry is exp(-s · φ(g_j, g_i)) where φ is the
    log-height cocycle.

    If height_cocycles is None, estimates cocycles from the root triple.

    Args:
        s: Spectral parameter
        height_cocycles: 3×3 matrix of log-height cocycles φ(g_j, g_i)

    Returns:
        3×3 transfer operator matrix.
    """
    if height_cocycles is None:
        # Estimate cocycles from root
        cocycles = np.zeros((3, 3))
        for i, g_i in enumerate(BERGGREN_GENERATORS):
            v_i = g_i @ BERGGREN_ROOT
            for j, g_j in enumerate(BERGGREN_GENERATORS):
                w = g_j @ v_i
                cocycles[j, i] = math.log(w[2] / v_i[2])
        height_cocycles = cocycles

    L = np.zeros((3, 3))
    for i in range(3):
        for j in range(3):
            L[i, j] = math.exp(-s * height_cocycles[j, i])

    return L


def transfer_operator_spectral_radius(s: float,
                                        height_cocycles: Optional[np.ndarray] = None
                                        ) -> float:
    """
    Compute the spectral radius of the transfer operator L_s.

    The pressure function P(s) = log(ρ(L_s)).
    The abscissa σ₀ satisfies P(σ₀) = 0, i.e., ρ(L_{σ₀}) = 1.

    Returns:
        Spectral radius ρ(L_s).
    """
    L = transfer_operator_matrix(s, height_cocycles)
    eigenvalues = np.linalg.eigvals(L)
    return max(abs(ev) for ev in eigenvalues)


def pressure_function(s: float,
                       height_cocycles: Optional[np.ndarray] = None
                       ) -> float:
    """
    Compute the topological pressure P(s) = log(ρ(L_s)).

    P(s) > 0 means divergence, P(s) < 0 means convergence.
    The zero P(σ₀) = 0 gives the abscissa of convergence.
    """
    rho = transfer_operator_spectral_radius(s, height_cocycles)
    return math.log(rho) if rho > 0 else float('-inf')


def find_pressure_zero(tol: float = 1e-8, s_low: float = 0.5,
                        s_high: float = 5.0) -> float:
    """
    Find σ₀ where P(σ₀) = 0 by bisection.

    This gives a spectral estimate of the abscissa of convergence.
    """
    # Ensure P(s_low) > 0 and P(s_high) < 0
    p_low = pressure_function(s_low)
    p_high = pressure_function(s_high)

    if p_low <= 0 or p_high >= 0:
        # Adjust bounds
        while p_low <= 0 and s_low > 0.01:
            s_low /= 2
            p_low = pressure_function(s_low)
        while p_high >= 0:
            s_high *= 2
            p_high = pressure_function(s_high)

    while s_high - s_low > tol:
        s_mid = (s_low + s_high) / 2
        p_mid = pressure_function(s_mid)
        if p_mid > 0:
            s_low = s_mid
        else:
            s_high = s_mid

    return (s_low + s_high) / 2


# ═══════════════════════════════════════════════════════════════════════
# 5. COLLISION ENTROPY FOR KEY EXCHANGE
# ═══════════════════════════════════════════════════════════════════════

def word_fiber_analysis(depth: int) -> Dict[Tuple[int, ...], int]:
    """
    Count the number of words mapping to each triple at depth d.

    This gives the fiber sizes of the evaluation map π_d: W_d → S_d.

    Returns:
        Dictionary mapping triple (as tuple) to fiber size.
    """
    shell = enumerate_berggren_shell(depth)
    fibers = defaultdict(int)
    for v in shell:
        fibers[tuple(v)] += 1
    return dict(fibers)


def collision_entropy(depth: int) -> float:
    """
    Compute the Rényi-2 (collision) entropy of the Berggren output
    distribution at depth d.

    H₂ = -log₂(Σ_v p(v)²) where p(v) = fiber_size(v) / 3^d.

    Returns:
        Collision entropy in bits.
    """
    fibers = word_fiber_analysis(depth)
    total = 3 ** depth
    collision_prob = sum((count / total) ** 2 for count in fibers.values())
    if collision_prob > 0:
        return -math.log2(collision_prob)
    return float('inf')


def collision_entropy_bounds(depth: int) -> Tuple[float, float]:
    """
    Compute lower and upper bounds on collision entropy.

    Lower bound: d·log₂(3) - log₂(M) where M = max fiber size.
    Upper bound: log₂(|S_d|) = log₂(number of distinct triples).

    Returns:
        (lower_bound, upper_bound) in bits.
    """
    fibers = word_fiber_analysis(depth)
    max_fiber = max(fibers.values())
    num_distinct = len(fibers)

    lower = depth * math.log2(3) - math.log2(max_fiber)
    upper = math.log2(num_distinct)

    return lower, upper


def keyspace_size(depth: int) -> Tuple[int, int, int]:
    """
    Compute keyspace statistics for Berggren key exchange at depth d.

    Returns:
        (total_words, distinct_triples, max_fiber_size)
    """
    fibers = word_fiber_analysis(depth)
    total = 3 ** depth
    distinct = len(fibers)
    max_fiber = max(fibers.values())
    return total, distinct, max_fiber


# ═══════════════════════════════════════════════════════════════════════
# MAIN: DEMONSTRATION
# ═══════════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("=" * 70)
    print("ALGORITHM DEMONSTRATIONS")
    print("=" * 70)

    # 1. Height growth
    alpha = estimate_height_growth_factor(6)
    sigma0 = convergence_threshold(3, alpha)
    print(f"\n1. Height growth factor α = {alpha:.6f}")
    print(f"   Convergence threshold σ₀ = log(3)/log(α) = {sigma0:.6f}")

    # 2. Transfer operator
    print(f"\n2. Transfer operator spectral analysis:")
    for s in [0.5, 1.0, 1.5, 2.0, 3.0]:
        P = pressure_function(s)
        rho = transfer_operator_spectral_radius(s)
        print(f"   s = {s:.1f}: P(s) = {P:+.4f}, ρ(L_s) = {rho:.6f}")

    sigma0_spectral = find_pressure_zero()
    print(f"   Spectral σ₀ (P(σ₀)=0): {sigma0_spectral:.6f}")

    # 3. Dirichlet series
    print(f"\n3. Dirichlet series partial sums:")
    for s in [1.5, 2.0, 3.0]:
        contribs = dirichlet_shell_contributions(s, 8)
        partial = sum(contribs)
        print(f"   Z_B({s:.1f}, D=8) = {partial:.8f}")
        ratios = dirichlet_convergence_ratio(s, 8)
        print(f"     Shell ratios: {[f'{r:.4f}' for r in ratios[-3:]]}")

    # 4. Collision entropy
    print(f"\n4. Collision entropy for key exchange:")
    for d in range(1, 8):
        H2 = collision_entropy(d)
        lb, ub = collision_entropy_bounds(d)
        total, distinct, max_fib = keyspace_size(d)
        print(f"   d={d}: H₂={H2:.3f} bits, "
              f"keys={distinct}/{total}, max_fiber={max_fib}")

"""
algorithms.py — Lorentzian Gap Surrogate Computation for Quantum LDPC Code Distance

Implements the core algorithms for computing Lorentzian gap surrogates from
measurement-profile distributions on subsets of qubits.

These algorithms mirror the formally verified Lean 4 definitions and theorems
in Pythagorean/LorentzianDistanceCertificate.lean.
"""

import numpy as np
from math import comb
from typing import Dict, List, Tuple, Optional
from itertools import combinations


def layer_weight(mu: Dict[frozenset, float], n: int, k: int) -> float:
    """
    Compute the layer weight: total mass of μ on all k-subsets of [n].

    This is the k-th coefficient of the univariate layer generating polynomial.

    Args:
        mu: Distribution mapping subsets (as frozensets) to probabilities.
        n: Number of qubits.
        k: Target cardinality.

    Returns:
        Sum of μ(S) for all S with |S| = k.
    """
    return sum(v for s, v in mu.items() if len(s) == k)


def all_layer_weights(mu: Dict[frozenset, float], n: int) -> List[float]:
    """
    Compute all layer weights a_0, a_1, ..., a_n.

    Args:
        mu: Distribution on subsets.
        n: Number of qubits.

    Returns:
        List of layer weights [a_0, a_1, ..., a_n].
    """
    return [layer_weight(mu, n, k) for k in range(n + 1)]


def lorentzian_gap(mu: Dict[frozenset, float], n: int) -> float:
    """
    Compute the Lorentzian gap surrogate: the minimum log-concavity slack
    across all adjacent layer pairs with positive denominator.

    For layers k with 1 ≤ k ≤ n-1:
        gap_k = a_k² / (a_{k-1} * a_{k+1}) - 1

    The global gap is min(gap_k) over all valid k.

    Args:
        mu: Distribution on subsets.
        n: Number of qubits.

    Returns:
        The minimum gap value, or float('inf') if no valid pairs exist.
    """
    weights = all_layer_weights(mu, n)
    min_gap = float('inf')

    for k in range(1, n):
        denom = weights[k - 1] * weights[k + 1]
        if denom > 1e-15:
            gap_k = weights[k] ** 2 / denom - 1
            min_gap = min(min_gap, gap_k)

    return min_gap if min_gap != float('inf') else 0.0


def boundary_mass(mu: Dict[frozenset, float], n: int) -> float:
    """
    Compute the boundary mass: total mass on subsets adjacent to zero-mass subsets.

    A subset S is on the boundary if there exists an adjacent exchange neighbor T
    (differing by one element) with μ(T) = 0.

    Args:
        mu: Distribution on subsets.
        n: Number of qubits.

    Returns:
        Total boundary mass.
    """
    universe = set(range(n))
    total = 0.0

    for s, val in mu.items():
        if val <= 0:
            continue
        # Check if s has any zero-mass exchange neighbor
        for i in s:
            for j in universe - s:
                t = frozenset((s - {i}) | {j})
                if mu.get(t, 0.0) == 0.0:
                    total += val
                    break
            else:
                continue
            break

    return total


def hamming_conductance(mu: Dict[frozenset, float], n: int) -> float:
    """
    Compute the Hamming conductance: boundaryMass / totalMass.

    Args:
        mu: Distribution on subsets.
        n: Number of qubits.

    Returns:
        Conductance value.
    """
    total = sum(mu.values())
    if total <= 0:
        return 0.0
    return boundary_mass(mu, n) / total


def exchange_rayleigh_gap(mu: Dict[frozenset, float], n: int, k: int) -> float:
    """
    Compute the minimum product μ(s)*μ(t) over all adjacent exchange pairs
    of k-subsets.

    Args:
        mu: Distribution on subsets.
        n: Number of qubits.
        k: Cardinality of subsets to check.

    Returns:
        Minimum product, or float('inf') if no adjacent pairs exist.
    """
    universe = set(range(n))
    min_product = float('inf')

    k_subsets = list(combinations(range(n), k))
    for s_tuple in k_subsets:
        s = frozenset(s_tuple)
        for i in s:
            for j in universe - s:
                t = frozenset((s - {i}) | {j})
                product = mu.get(s, 0.0) * mu.get(t, 0.0)
                min_product = min(min_product, product)

    return min_product if min_product != float('inf') else 0.0


def compute_distance_certificate(
    mu: Dict[frozenset, float], n: int
) -> Dict[str, float]:
    """
    Compute a full distance certificate from a measurement profile distribution.

    Returns a dictionary with:
    - layer_weights: list of layer weights
    - lorentzian_gap: the global gap surrogate
    - boundary_mass: boundary mass value
    - hamming_conductance: conductance value
    - certified_min_distance: estimated minimum distance from layer vanishing

    Args:
        mu: Distribution on subsets.
        n: Number of qubits.

    Returns:
        Certificate dictionary.
    """
    weights = all_layer_weights(mu, n)
    gap = lorentzian_gap(mu, n)
    bdry = boundary_mass(mu, n)
    cond = hamming_conductance(mu, n)

    # Certified minimum distance: first nonzero layer weight above 0
    cert_dist = 0
    for k in range(1, n + 1):
        if weights[k] > 1e-15:
            cert_dist = k
            break

    return {
        'layer_weights': weights,
        'lorentzian_gap': gap,
        'boundary_mass': bdry,
        'hamming_conductance': cond,
        'certified_min_distance': cert_dist,
        'total_mass': sum(weights),
    }


# === Code Family Generators ===

def uniform_distribution(n: int) -> Dict[frozenset, float]:
    """Uniform distribution over all subsets of [n]."""
    mu = {}
    for k in range(n + 1):
        for s in combinations(range(n), k):
            mu[frozenset(s)] = 1.0 / (2 ** n)
    return mu


def hypergraph_product_surrogate(n: int, rate: float = 0.5) -> Dict[frozenset, float]:
    """
    Surrogate measurement distribution for a hypergraph product code.

    Concentrates mass on subsets near the target weight n*rate,
    with Gaussian-like decay. No mass on low-weight subsets (simulating
    the distance property).

    Args:
        n: Number of qubits.
        rate: Target rate (fraction of weight).

    Returns:
        Distribution dictionary.
    """
    target_k = int(n * rate)
    sigma = max(1, n * 0.1)
    mu = {}
    total = 0.0

    for k in range(n + 1):
        if k < max(2, n // 4):  # Distance gap: no low-weight support
            continue
        weight = np.exp(-0.5 * ((k - target_k) / sigma) ** 2) * comb(n, k)
        if weight > 1e-15:
            for s in combinations(range(n), k):
                mu[frozenset(s)] = weight / comb(n, k)
            total += weight

    # Normalize
    if total > 0:
        for s in mu:
            mu[s] /= total

    return mu


def balanced_product_surrogate(n: int) -> Dict[frozenset, float]:
    """
    Surrogate for balanced product codes: more concentrated distribution
    with stronger distance properties.

    Args:
        n: Number of qubits.

    Returns:
        Distribution dictionary.
    """
    target_k = n // 2
    sigma = max(1, n * 0.05)
    mu = {}
    total = 0.0

    for k in range(n + 1):
        if k < max(3, n // 3):  # Stronger distance gap
            continue
        weight = np.exp(-0.5 * ((k - target_k) / sigma) ** 2) * comb(n, k)
        if weight > 1e-15:
            for s in combinations(range(n), k):
                mu[frozenset(s)] = weight / comb(n, k)
            total += weight

    if total > 0:
        for s in mu:
            mu[s] /= total

    return mu


def repetition_code_surrogate(n: int) -> Dict[frozenset, float]:
    """
    Surrogate for repetition-like codes (poor distance).
    Mass concentrated on very low-weight subsets.

    Args:
        n: Number of qubits.

    Returns:
        Distribution dictionary.
    """
    mu = {}
    total = 0.0

    for k in range(min(3, n + 1)):
        weight = (n + 1 - k) * comb(n, k)
        for s in combinations(range(n), k):
            mu[frozenset(s)] = weight / comb(n, k)
        total += weight

    if total > 0:
        for s in mu:
            mu[s] /= total

    return mu


def punctured_surface_surrogate(n: int) -> Dict[frozenset, float]:
    """
    Surrogate for punctured surface codes: moderate distance but not linear.
    Distance grows as sqrt(n).

    Args:
        n: Number of qubits.

    Returns:
        Distribution dictionary.
    """
    dist = max(1, int(np.sqrt(n)))
    target_k = n // 2
    sigma = max(1, n * 0.15)
    mu = {}
    total = 0.0

    for k in range(n + 1):
        if 0 < k < dist:
            continue
        weight = np.exp(-0.5 * ((k - target_k) / sigma) ** 2) * comb(n, k)
        if weight > 1e-15:
            for s in combinations(range(n), k):
                mu[frozenset(s)] = weight / comb(n, k)
            total += weight

    if total > 0:
        for s in mu:
            mu[s] /= total

    return mu


if __name__ == "__main__":
    # Example usage
    n = 6
    print(f"=== Lorentzian Gap Surrogate Analysis for n={n} ===\n")

    families = {
        "Hypergraph Product": hypergraph_product_surrogate(n),
        "Balanced Product": balanced_product_surrogate(n),
        "Repetition Code": repetition_code_surrogate(n),
        "Punctured Surface": punctured_surface_surrogate(n),
    }

    for name, mu in families.items():
        cert = compute_distance_certificate(mu, n)
        print(f"--- {name} ---")
        print(f"  Layer weights: {[f'{w:.4f}' for w in cert['layer_weights']]}")
        print(f"  Lorentzian gap: {cert['lorentzian_gap']:.6f}")
        print(f"  Boundary mass: {cert['boundary_mass']:.6f}")
        print(f"  Hamming conductance: {cert['hamming_conductance']:.6f}")
        print(f"  Certified min distance: {cert['certified_min_distance']}")
        print()

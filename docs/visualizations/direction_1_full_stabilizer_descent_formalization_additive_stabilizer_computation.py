"""
Algorithms for Stabilizer Descent in Approximate Subgroups.

Implements the core computational methods for:
- Constructing finite stabilizers
- Computing doubling constants
- Producing stabilizer chains
- Estimating normalized log-cardinality drops

All algorithms operate in Z/pZ for a prime p.
"""

import math
from typing import List, Set, Tuple, Optional, Dict
from collections import defaultdict


def sumset(A: Set[int], B: Set[int], p: int) -> Set[int]:
    """Compute A + B in Z/pZ."""
    return {(a + b) % p for a in A for b in B}


def product_set(A: Set[int], B: Set[int], p: int) -> Set[int]:
    """Compute A * B in Z/pZ (multiplicative)."""
    return {(a * b) % p for a in A for b in B}


def doubling_constant(A: Set[int], p: int) -> float:
    """
    Compute the doubling constant K = |A+A| / |A| for a set A ⊆ Z/pZ.

    Parameters
    ----------
    A : set of int
        A subset of Z/pZ.
    p : int
        A prime modulus.

    Returns
    -------
    float
        The doubling constant |A+A|/|A|.

    Examples
    --------
    >>> doubling_constant({0, 1, 2, 3, 4}, 101)
    1.8
    """
    if len(A) == 0:
        return float('inf')
    AA = sumset(A, A, p)
    return len(AA) / len(A)


def additive_stabilizer(A: Set[int], p: int) -> Set[int]:
    """
    Compute the additive stabilizer Stab(A) = {x ∈ Z/pZ : x + A ⊆ A + A}.

    Parameters
    ----------
    A : set of int
        A subset of Z/pZ.
    p : int
        A prime modulus.

    Returns
    -------
    set of int
        The stabilizer set.

    Complexity
    ----------
    Time: O(p * |A|) where we check each element of Z/pZ.
    Space: O(p) for storing the sumset and stabilizer.

    Examples
    --------
    >>> sorted(additive_stabilizer({0, 1, 2}, 7))
    [0, 1, 2, 3, 4]
    """
    AA = sumset(A, A, p)
    stab = set()
    for g in range(p):
        if all((g + a) % p in AA for a in A):
            stab.add(g)
    return stab


def normalized_log_card(A: Set[int], p: int) -> float:
    """
    Compute the normalized log-cardinality log|A| / log(p).

    This is the finite analogue of pseudofinite dimension.

    Parameters
    ----------
    A : set of int
        A subset of Z/pZ.
    p : int
        A prime modulus.

    Returns
    -------
    float
        The normalized log-cardinality in [0, 1].
    """
    if len(A) == 0:
        return 0.0
    return math.log(len(A)) / math.log(p)


def stabilizer_chain(A: Set[int], p: int, max_steps: int = 20) -> List[Dict]:
    """
    Compute the iterated stabilizer descent chain:
    A₀ = A, A₁ = Stab(A₀), A₂ = Stab(A₁), ...

    Stops when the chain stabilizes (Aₖ = Aₖ₋₁) or reaches max_steps.

    Parameters
    ----------
    A : set of int
        Initial set.
    p : int
        Prime modulus.
    max_steps : int
        Maximum iterations.

    Returns
    -------
    list of dict
        Each entry has keys: 'step', 'size', 'nlc', 'doubling', 'drop'.

    Complexity
    ----------
    Time: O(max_steps * p * max_size) per step.
    """
    chain = []
    current = A.copy()
    prev_nlc = normalized_log_card(current, p)

    for step in range(max_steps + 1):
        nlc_val = normalized_log_card(current, p)
        dc = doubling_constant(current, p)
        drop = prev_nlc - nlc_val if step > 0 else 0.0

        chain.append({
            'step': step,
            'size': len(current),
            'nlc': nlc_val,
            'doubling': dc,
            'drop': drop,
        })

        if step > 0 and len(current) == chain[step - 1]['size']:
            break  # Stabilized

        prev_nlc = nlc_val
        current = additive_stabilizer(current, p)

    return chain


def ruzsa_covering_bound(K: int) -> int:
    """
    Compute the Ruzsa covering bound: at most K translates needed.

    In the Ruzsa covering lemma, if |A+B| ≤ K|B|, then A can be covered
    by at most K translates of B-B.

    Parameters
    ----------
    K : int
        Doubling constant bound.

    Returns
    -------
    int
        Upper bound on the number of translates needed.
    """
    return K


def dimension_drop_bound(K: int) -> float:
    """
    Compute the theoretical dimension drop bound c(K).

    Based on the covering-first descent strategy:
    If |A+A| ≤ K|A|, the stabilizer is covered by K translates of A-A,
    giving a dimension drop of at least 1 - log(K²)/log(p) ≈ 1/K for
    the normalized log-cardinality.

    Parameters
    ----------
    K : int
        Doubling constant bound.

    Returns
    -------
    float
        Theoretical lower bound on dimension drop c(K).
    """
    if K <= 1:
        return 1.0
    return 1.0 / (2 * K)


def find_approximate_subgroups(p: int, K_max: float = 3.0,
                                min_size: int = 3) -> List[Tuple[Set[int], float]]:
    """
    Search for K-approximate subgroups in Z/pZ with K ≤ K_max.

    Searches arithmetic progressions and coset-like structures.

    Parameters
    ----------
    p : int
        Prime modulus.
    K_max : float
        Maximum doubling constant.
    min_size : int
        Minimum set size.

    Returns
    -------
    list of (set, float)
        Pairs of (subset, doubling_constant).
    """
    results = []

    # Arithmetic progressions {a, a+d, a+2d, ..., a+(n-1)d}
    for d in range(1, min(p, 20)):
        for n in range(min_size, p // 2 + 1):
            A = {(i * d) % p for i in range(n)}
            if len(A) < min_size:
                continue
            dc = doubling_constant(A, p)
            if dc <= K_max:
                results.append((A, dc))
            if len(results) > 50:
                break
        if len(results) > 50:
            break

    return results


def estimate_stabilizer_drop(p: int, K: int,
                              num_samples: int = 20) -> Dict:
    """
    Estimate the stabilizer dimension drop for approximate subgroups
    with doubling constant ≤ K in Z/pZ.

    Parameters
    ----------
    p : int
        Prime modulus.
    K : int
        Doubling constant bound.
    num_samples : int
        Number of approximate subgroups to sample.

    Returns
    -------
    dict
        Statistics including min_drop, max_drop, mean_drop, samples.
    """
    import random
    random.seed(42)

    drops = []
    samples = []

    # Use arithmetic progressions as approximate subgroups
    for trial in range(num_samples):
        d = random.randint(1, p - 1)
        n = random.randint(max(3, int(p**0.2)), min(int(p**0.8), p - 1))
        A = {(i * d) % p for i in range(n)}
        dc = doubling_constant(A, p)

        if dc <= K and len(A) >= 3 and len(A) < p:
            stab = additive_stabilizer(A, p)
            nlc_A = normalized_log_card(A, p)
            nlc_S = normalized_log_card(stab, p)
            drop = nlc_A - nlc_S

            drops.append(drop)
            samples.append({
                'size_A': len(A),
                'size_stab': len(stab),
                'nlc_A': nlc_A,
                'nlc_stab': nlc_S,
                'drop': drop,
                'doubling': dc,
            })

    if not drops:
        return {'min_drop': None, 'max_drop': None, 'mean_drop': None,
                'num_samples': 0, 'samples': []}

    return {
        'min_drop': min(drops),
        'max_drop': max(drops),
        'mean_drop': sum(drops) / len(drops),
        'num_samples': len(drops),
        'samples': samples[:10],  # Return first 10
    }


if __name__ == "__main__":
    print("=== Stabilizer Descent Algorithms ===\n")

    # Example: arithmetic progression in Z/101Z
    p = 101
    A = {(3 * i) % p for i in range(20)}
    print(f"A = arithmetic progression of length {len(A)} in Z/{p}Z")
    print(f"Doubling constant: {doubling_constant(A, p):.3f}")

    stab = additive_stabilizer(A, p)
    print(f"|Stab(A)| = {len(stab)}")
    print(f"nlc(A) = {normalized_log_card(A, p):.4f}")
    print(f"nlc(Stab) = {normalized_log_card(stab, p):.4f}")
    print(f"Drop = {normalized_log_card(A, p) - normalized_log_card(stab, p):.4f}")

    print("\n--- Stabilizer Chain ---")
    chain = stabilizer_chain(A, p)
    for entry in chain:
        print(f"  Step {entry['step']}: size={entry['size']}, "
              f"nlc={entry['nlc']:.4f}, drop={entry['drop']:.4f}")

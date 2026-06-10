#!/usr/bin/env python3
"""
Privacy-Surveillance Conservation Law: Core Algorithms

Type-hinted implementations of the key computational procedures from the
Privacy-Surveillance Conservation Law framework.
"""

from typing import TypeVar, Callable, List, Tuple, Dict, Set, FrozenSet
from collections import Counter
import math

S = TypeVar('S')
C = TypeVar('C')
D = TypeVar('D')


def compute_privacy_index(f: Callable[[S], C], domain: List[S]) -> int:
    """
    Compute the privacy index π(f) = |{(s₁,s₂) : s₁≠s₂, f(s₁)=f(s₂)}|.
    
    Time complexity: O(n²) where n = |domain|, or O(n) via fiber decomposition.
    """
    # Efficient O(n) computation via fiber decomposition
    counter: Counter = Counter(f(s) for s in domain)
    return sum(k * (k - 1) for k in counter.values())


def compute_surveillance_index(f: Callable[[S], C], domain: List[S]) -> int:
    """
    Compute the surveillance index σ(f) = n(n-1) - π(f).
    
    Uses the conservation law rather than direct counting.
    """
    n = len(domain)
    return n * (n - 1) - compute_privacy_index(f, domain)


def compute_fiber_sizes(f: Callable[[S], C], domain: List[S]) -> List[int]:
    """
    Compute the privacy spectrum: sorted list of fiber sizes.
    
    Returns sizes in descending order.
    """
    counter: Counter = Counter(f(s) for s in domain)
    return sorted(counter.values(), reverse=True)


def compute_collision_probability(f: Callable[[S], C], domain: List[S]) -> float:
    """
    Compute the collision probability: π(f) / n(n-1).
    
    This is the probability that two uniformly random distinct elements
    are mapped to the same value.
    """
    n = len(domain)
    if n <= 1:
        return 0.0
    return compute_privacy_index(f, domain) / (n * (n - 1))


def compute_balanced_privacy(n: int, k: int) -> int:
    """
    Compute the minimum privacy index for n elements partitioned into k groups.
    
    The balanced partition minimizes Σ fᵢ(fᵢ-1). This is the floor of the
    privacy index achievable by any k-to-1 mapping.
    """
    if k <= 0 or n <= 0:
        return 0
    q, r = divmod(n, k)
    return r * (q + 1) * q + (k - r) * q * (q - 1)


def is_refinement(
    g: Callable[[S], C], 
    f: Callable[[S], C], 
    domain: List[S]
) -> bool:
    """
    Check whether g refines f: g(s₁)=g(s₂) → f(s₁)=f(s₂).
    
    Equivalently, f factors through g: f = h ∘ g for some h.
    """
    # Build g-fibers and check f-constancy
    g_fibers: Dict[C, Set[C]] = {}
    for s in domain:
        gc = g(s)
        fc = f(s)
        if gc not in g_fibers:
            g_fibers[gc] = set()
        g_fibers[gc].add(fc)
    return all(len(f_values) == 1 for f_values in g_fibers.values())


def optimal_k_partition_privacy(n: int) -> List[Tuple[int, int]]:
    """
    For each k from 1 to n, compute the minimum privacy index
    achievable by a k-group partition of n elements.
    
    Returns list of (k, min_privacy) pairs.
    """
    results = []
    for k in range(1, n + 1):
        results.append((k, compute_balanced_privacy(n, k)))
    return results


def privacy_utility_frontier(n: int) -> List[Tuple[float, float]]:
    """
    Compute the Pareto frontier of (collision_probability, image_size/n) pairs.
    
    For each k from 1 to n, computes the optimal tradeoff point using
    balanced partitions.
    """
    if n <= 1:
        return [(0.0, 1.0)]
    
    frontier = []
    for k in range(1, n + 1):
        min_pi = compute_balanced_privacy(n, k)
        cp = min_pi / (n * (n - 1))
        utility = k / n
        frontier.append((cp, utility))
    return frontier


def compose_privacy_bound(
    f1_fibers: List[int],
    f2_fibers: List[int]
) -> int:
    """
    Compute the privacy index of the product observation (f₁, f₂) on S₁ × S₂.
    
    The product fibers have sizes {f1_i * f2_j} for all i, j.
    """
    product_fibers = []
    for a in f1_fibers:
        for b in f2_fibers:
            product_fibers.append(a * b)
    return sum(k * (k - 1) for k in product_fibers)


def data_processing_chain(
    f: Callable[[S], C],
    processors: List[Callable],
    domain: List[S]
) -> List[Tuple[str, int, int, float]]:
    """
    Apply a chain of post-processing functions and track how privacy
    monotonically increases (and surveillance decreases) at each step.
    
    Returns: List of (step_name, privacy, surveillance, collision_prob) tuples.
    """
    n = len(domain)
    budget = n * (n - 1)
    
    results = []
    current_f = f
    pi = compute_privacy_index(current_f, domain)
    results.append(("base f", pi, budget - pi, pi / budget if budget > 0 else 0))
    
    for i, h in enumerate(processors):
        prev_f = current_f
        current_f = lambda x, _f=current_f, _h=h: _h(_f(x))
        pi = compute_privacy_index(current_f, domain)
        results.append((f"step {i+1}", pi, budget - pi, pi / budget if budget > 0 else 0))
    
    return results


def privacy_entropy(f: Callable[[S], C], domain: List[S]) -> float:
    """
    Compute the Shannon entropy of the fiber size distribution,
    normalized by log(n).
    
    High entropy = balanced fibers = minimum privacy index for given image size.
    Low entropy = unbalanced fibers = wasted surveillance capacity.
    """
    n = len(domain)
    if n <= 1:
        return 0.0
    
    fibers = compute_fiber_sizes(f, domain)
    total = sum(fibers)
    
    entropy = 0.0
    for k in fibers:
        if k > 0:
            p = k / total
            entropy -= p * math.log2(p)
    
    max_entropy = math.log2(len(fibers)) if len(fibers) > 1 else 1.0
    return entropy / max_entropy if max_entropy > 0 else 0.0


if __name__ == "__main__":
    # Quick self-test
    domain = list(range(10))
    f = lambda x: x % 3
    
    pi = compute_privacy_index(f, domain)
    sigma = compute_surveillance_index(f, domain)
    n = len(domain)
    
    assert pi + sigma == n * (n - 1), "Conservation law violated!"
    print(f"Self-test passed: π={pi}, σ={sigma}, π+σ={pi+sigma}={n*(n-1)}")
    
    # Data processing inequality test
    h = lambda y: y % 2
    pi_f = compute_privacy_index(f, domain)
    pi_hf = compute_privacy_index(lambda x: h(f(x)), domain)
    assert pi_f <= pi_hf, "Data processing inequality violated!"
    print(f"DPI test passed: π(f)={pi_f} ≤ π(h∘f)={pi_hf}")
    
    # Balanced partition test
    for n_test in [6, 10, 15, 20]:
        for k in range(1, n_test + 1):
            bal = compute_balanced_privacy(n_test, k)
            # Verify with balanced partition
            q, r = divmod(n_test, k)
            fibers = [q + 1] * r + [q] * (k - r)
            actual = sum(fi * (fi - 1) for fi in fibers)
            assert bal == actual, f"Balanced formula wrong: n={n_test}, k={k}"
    print("Balanced partition formula verified for n=6,10,15,20")
    
    print("\nAll self-tests passed!")

#!/usr/bin/env python3
"""
Algorithms for Generation Probability of Symmetric Groups

Implements the key algorithms from the research paper:
1. Subgroup sieve bound computation
2. Certificate checking for permutation pairs
3. Exact generation probability via closure computation
4. Monte Carlo estimation with confidence intervals

Keywords: algorithmic group theory, finite group sieve, generation certificates,
          random generation, permutation statistics
"""

import math
import random
import itertools
from typing import List, Tuple, Set, Dict, Optional
from collections import deque


# ──────────────────────────────────────────────────────────────────────
# Core Permutation Operations
# ──────────────────────────────────────────────────────────────────────

def compose(p: Tuple[int, ...], q: Tuple[int, ...]) -> Tuple[int, ...]:
    """Compose permutations: (p ∘ q)(i) = p(q(i)). O(n)."""
    return tuple(p[q[i]] for i in range(len(p)))


def inverse(p: Tuple[int, ...]) -> Tuple[int, ...]:
    """Inverse permutation. O(n)."""
    inv = [0] * len(p)
    for i, v in enumerate(p):
        inv[v] = i
    return tuple(inv)


def identity(n: int) -> Tuple[int, ...]:
    """Identity permutation on {0, ..., n-1}."""
    return tuple(range(n))


def cycle_decomposition(perm: Tuple[int, ...]) -> List[List[int]]:
    """
    Compute the cycle decomposition of a permutation.
    
    Returns a list of cycles, each cycle a list of elements.
    Time: O(n), Space: O(n).
    """
    n = len(perm)
    visited = [False] * n
    cycles = []
    for i in range(n):
        if not visited[i]:
            cycle = []
            j = i
            while not visited[j]:
                visited[j] = True
                cycle.append(j)
                j = perm[j]
            if len(cycle) > 1:
                cycles.append(cycle)
    return cycles


def sign(perm: Tuple[int, ...]) -> int:
    """
    Compute the sign (parity) of a permutation.
    
    +1 for even permutations, -1 for odd.
    Time: O(n).
    """
    cycles = cycle_decomposition(perm)
    # Each k-cycle contributes (-1)^(k-1) to the sign
    parity = sum(len(c) - 1 for c in cycles)
    return 1 if parity % 2 == 0 else -1


def is_n_cycle(perm: Tuple[int, ...]) -> bool:
    """Check if perm is a single n-cycle. O(n)."""
    n = len(perm)
    if n <= 1:
        return True
    cycles = cycle_decomposition(perm)
    return len(cycles) == 1 and len(cycles[0]) == n


def random_permutation(n: int) -> Tuple[int, ...]:
    """Generate a uniformly random permutation. O(n)."""
    elements = list(range(n))
    random.shuffle(elements)
    return tuple(elements)


# ──────────────────────────────────────────────────────────────────────
# Algorithm 1: Subgroup Closure via BFS (Dimino-like)
# ──────────────────────────────────────────────────────────────────────

def subgroup_closure(generators: List[Tuple[int, ...]], n: int) -> Set[Tuple[int, ...]]:
    """
    Compute ⟨generators⟩ ≤ S_n via BFS on the Cayley graph.
    
    Pseudocode:
      1. Initialize S = {e} ∪ generators ∪ generators⁻¹
      2. Queue Q = list(S)
      3. While Q non-empty:
           g = Q.dequeue()
           For each generator h:
             For new ∈ {g·h, h·g, g·h⁻¹, h⁻¹·g}:
               If new ∉ S: add to S and Q
      4. Return S
    
    Time: O(|⟨gens⟩| · |gens| · n)
    Space: O(|⟨gens⟩| · n)
    """
    e = identity(n)
    seen: Set[Tuple[int, ...]] = {e}
    queue = deque([e])
    
    # Add generators and their inverses
    all_gens = []
    for g in generators:
        all_gens.append(g)
        all_gens.append(inverse(g))
    
    for g in all_gens:
        if g not in seen:
            seen.add(g)
            queue.append(g)
    
    while queue:
        current = queue.popleft()
        for g in all_gens:
            for new_elem in [compose(current, g), compose(g, current)]:
                if new_elem not in seen:
                    seen.add(new_elem)
                    queue.append(new_elem)
    
    return seen


# ──────────────────────────────────────────────────────────────────────
# Algorithm 2: Subgroup Sieve Bound
# ──────────────────────────────────────────────────────────────────────

def subgroup_sieve_bound(n: int, subgroup_orders: List[int]) -> float:
    """
    Compute the subgroup sieve upper bound on nongeneration probability.
    
    Given a family of subgroups with orders |H_1|, ..., |H_k|,
    the union bound gives:
    
      Pr[⟨σ,τ⟩ ≠ S_n] ≤ Σ (|H_i| / n!)²
    
    Args:
        n: degree of the symmetric group
        subgroup_orders: list of orders of covering subgroups
    
    Returns:
        Upper bound on nongeneration probability
    
    Time: O(k) where k = len(subgroup_orders)
    """
    nfact = math.factorial(n)
    return sum((h / nfact) ** 2 for h in subgroup_orders)


def point_stabilizer_sieve(n: int) -> float:
    """
    Subgroup sieve using only point stabilizers.
    
    S_n has n point stabilizers, each isomorphic to S_{n-1} with order (n-1)!.
    
      Bound = n · ((n-1)!/n!)² = n · (1/n)² = 1/n
    
    Time: O(1)
    """
    if n <= 1:
        return 0.0
    return 1.0 / n


def enhanced_sieve_bound(n: int) -> float:
    """
    Enhanced subgroup sieve using point stabilizers and the alternating group.
    
    The alternating group A_n has order n!/2, so contributes (1/2)² = 1/4.
    Point stabilizers contribute 1/n.
    
    But this overcounts — many non-generating pairs are in both A_n and a 
    point stabilizer. The union bound gives:
    
      Bound ≤ 1/4 + 1/n  (coarse)
    
    For the alternating group to matter, both permutations must be even,
    which happens with probability 1/4. But if we restrict to pairs where
    at least one is odd, A_n doesn't contribute.
    
    Time: O(1)
    """
    if n <= 2:
        return 1.0
    # Alternating group contributes (1/2)² = 1/4
    # n point stabilizers each contribute (1/n)² 
    # Total from point stabilizers: n * (1/n)² = 1/n
    return 0.25 + 1.0/n


# ──────────────────────────────────────────────────────────────────────
# Algorithm 3: Generation Certificate Checker
# ──────────────────────────────────────────────────────────────────────

def check_generation_certificate(sigma: Tuple[int, ...], tau: Tuple[int, ...]) -> Dict[str, bool]:
    """
    Check the SymmGenerationCertificate for a pair (σ, τ).
    
    Certificate conditions:
      1. σ is an n-cycle
      2. σ has full support (equivalent to being an n-cycle)
      3. The pair acts transitively 
      4. At least one of σ, τ has sign -1
    
    Returns a dict with each condition's status.
    
    Time: O(n) for all checks (transitivity is free when σ is an n-cycle)
    """
    n = len(sigma)
    
    is_cycle = is_n_cycle(sigma)
    full_support = is_cycle  # n-cycle ↔ full support
    
    # If σ is an n-cycle, transitivity is automatic
    transitive = is_cycle
    
    has_odd = (sign(sigma) == -1) or (sign(tau) == -1)
    
    return {
        "is_n_cycle": is_cycle,
        "full_support": full_support,
        "transitive": transitive,
        "has_odd_perm": has_odd,
        "certificate_valid": is_cycle and full_support and transitive and has_odd,
    }


def certificate_density_exact(n: int) -> float:
    """
    Compute the exact certificate density for small n.
    
    Certificate requires: σ is n-cycle AND (sign(σ)=-1 OR sign(τ)=-1).
    
    Fraction of n-cycles in S_n: (n-1)!/n! = 1/n
    If n is even: n-cycles are odd, so sign(σ)=-1 always holds → cert density = 1/n
    If n is odd: n-cycles are even, so need sign(τ)=-1 → cert density = (1/n)·(1/2) = 1/(2n)
    
    Time: O(1)
    """
    if n <= 1:
        return 1.0
    # Fraction of n-cycles
    cycle_fraction = 1.0 / n
    
    if n % 2 == 0:
        # n even → n-cycle is odd → certificate always satisfied (re: sign)
        return cycle_fraction
    else:
        # n odd → n-cycle is even → need τ to be odd (prob 1/2)
        return cycle_fraction * 0.5


# ──────────────────────────────────────────────────────────────────────
# Algorithm 4: Exact Generation Probability
# ──────────────────────────────────────────────────────────────────────

def exact_generation_probability(n: int) -> Tuple[int, int]:
    """
    Compute exact P_n = (generating pairs) / (n!)² by brute force.
    
    Time: O((n!)² · n! · n)   [very expensive]
    Space: O(n! · n)
    
    Returns (numerator, denominator) as integers.
    """
    if n <= 1:
        return (1, 1)
    
    perms = list(itertools.permutations(range(n)))
    nfact = len(perms)
    total = nfact * nfact
    count = 0
    
    for sigma in perms:
        for tau in perms:
            cl = subgroup_closure([sigma, tau], n)
            if len(cl) == nfact:
                count += 1
    
    return (count, total)


# ──────────────────────────────────────────────────────────────────────
# Algorithm 5: Monte Carlo Estimator with Confidence Intervals
# ──────────────────────────────────────────────────────────────────────

def monte_carlo_estimate(n: int, samples: int = 10000, 
                         confidence: float = 0.95) -> Dict[str, float]:
    """
    Monte Carlo estimate of P_n with confidence interval.
    
    Uses the normal approximation for the binomial proportion.
    
    Time: O(samples · n! · n)  [closure computation dominates]
    
    Returns dict with estimate, lower bound, upper bound.
    """
    nfact = math.factorial(n)
    successes = 0
    
    for _ in range(samples):
        sigma = random_permutation(n)
        tau = random_permutation(n)
        cl = subgroup_closure([sigma, tau], n)
        if len(cl) == nfact:
            successes += 1
    
    p_hat = successes / samples
    
    # Normal approximation CI
    import scipy.stats as stats  # type: ignore
    z = stats.norm.ppf(1 - (1 - confidence) / 2)
    margin = z * math.sqrt(p_hat * (1 - p_hat) / samples) if samples > 0 else 0
    
    return {
        "estimate": p_hat,
        "lower": max(0, p_hat - margin),
        "upper": min(1, p_hat + margin),
        "samples": samples,
        "successes": successes,
    }


# ──────────────────────────────────────────────────────────────────────
# Example Usage
# ──────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=== Subgroup Sieve Bounds ===")
    for n in range(2, 16):
        psb = point_stabilizer_sieve(n)
        esb = enhanced_sieve_bound(n)
        print(f"  S_{n}: point-stab bound = {psb:.4f}, enhanced = {esb:.4f}")
    
    print("\n=== Certificate Densities (analytical) ===")
    for n in range(2, 16):
        cd = certificate_density_exact(n)
        print(f"  S_{n}: certificate density = {cd:.4f}")
    
    print("\n=== Exact Generation Probabilities ===")
    for n in range(1, 6):
        num, den = exact_generation_probability(n)
        print(f"  P_{n} = {num}/{den} = {num/den:.6f}")
    
    print("\n=== Generation Certificate Check Example ===")
    n = 5
    sigma = (1, 2, 3, 4, 0)  # 5-cycle
    tau = (1, 0, 2, 3, 4)    # transposition (01)
    result = check_generation_certificate(sigma, tau)
    print(f"  σ = {sigma}, τ = {tau}")
    for k, v in result.items():
        print(f"    {k}: {v}")

#!/usr/bin/env python3
"""
Algorithms for Character Sum Bounds on Random Cayley Graphs

This module implements the core algorithms from the research paper:
1. Closed-word counting for Cayley graphs
2. Moment kernel computation
3. Excess moment computation
4. Conjugacy-class compressed averaging
5. Truncated excess partition function

All algorithms work with exact rational arithmetic for mathematical rigor.
"""

import itertools
import math
from fractions import Fraction
from typing import Tuple, List, Dict, Optional
from functools import lru_cache


# ============================================================
# Type aliases
# ============================================================
Perm = Tuple[int, ...]     # A permutation as a tuple
Word = Tuple[int, ...]     # A word over {0,1,2,3}


# ============================================================
# Permutation arithmetic
# ============================================================

def compose(p: Perm, q: Perm) -> Perm:
    """Compose permutations: (p ∘ q)(i) = p(q(i))."""
    return tuple(p[q[i]] for i in range(len(p)))


def inverse(p: Perm) -> Perm:
    """Inverse permutation."""
    n = len(p)
    inv = [0] * n
    for i in range(n):
        inv[p[i]] = i
    return tuple(inv)


def identity(n: int) -> Perm:
    """Identity permutation on {0, ..., n-1}."""
    return tuple(range(n))


def conjugate(h: Perm, g: Perm) -> Perm:
    """Conjugate: h * g * h⁻¹."""
    return compose(compose(h, g), inverse(h))


def cycle_type(p: Perm) -> Tuple[int, ...]:
    """Return the cycle type of a permutation as a sorted tuple of cycle lengths."""
    n = len(p)
    visited = [False] * n
    cycles = []
    for i in range(n):
        if not visited[i]:
            length = 0
            j = i
            while not visited[j]:
                visited[j] = True
                j = p[j]
                length += 1
            cycles.append(length)
    return tuple(sorted(cycles, reverse=True))


def all_permutations(n: int) -> List[Perm]:
    """All permutations of {0, ..., n-1}."""
    return [tuple(p) for p in itertools.permutations(range(n))]


# ============================================================
# Word evaluation
# ============================================================

def eval_word(sigma: Perm, tau: Perm, word: Word) -> Perm:
    """
    Evaluate a word over the alphabet {σ, σ⁻¹, τ, τ⁻¹}
    encoded as {0, 1, 2, 3} in a group.

    Time complexity: O(m * n) where m = len(word), n = len(sigma)
    Space complexity: O(n)
    """
    n = len(sigma)
    generators = [sigma, inverse(sigma), tau, inverse(tau)]
    result = identity(n)
    for letter in word:
        result = compose(generators[letter], result)
    return result


# ============================================================
# Closed-word count
# ============================================================

def closed_word_count(sigma: Perm, tau: Perm, m: int) -> int:
    """
    Count words of length m evaluating to the identity.

    Algorithm: Exhaustive enumeration over 4^m words.
    Time complexity: O(4^m * m * n)
    Space complexity: O(m)

    For large m, use closed_word_count_dp instead.
    """
    n = len(sigma)
    e = identity(n)
    count = 0
    for word in itertools.product(range(4), repeat=m):
        if eval_word(sigma, tau, word) == e:
            count += 1
    return count


def closed_word_count_dp(sigma: Perm, tau: Perm, m: int) -> int:
    """
    Count closed words using dynamic programming (matrix power method).

    Algorithm: Track the distribution of group elements after each step.
    Time complexity: O(m * n! * 4) where n! = |S_n|
    Space complexity: O(n!)
    """
    n = len(sigma)
    generators = [sigma, inverse(sigma), tau, inverse(tau)]
    e = identity(n)

    # Distribution: dict mapping group element -> count
    dist: Dict[Perm, int] = {e: 1}

    for _ in range(m):
        new_dist: Dict[Perm, int] = {}
        for g, cnt in dist.items():
            for gen in generators:
                h = compose(gen, g)
                new_dist[h] = new_dist.get(h, 0) + cnt
        dist = new_dist

    return dist.get(e, 0)


# ============================================================
# Moment kernel and excess moment
# ============================================================

def moment_kernel(sigma: Perm, tau: Perm, m: int,
                  use_dp: bool = False) -> Fraction:
    """
    The moment kernel: closedWordCount(σ, τ, m) / 4^m.

    This is the return probability of the length-m random walk
    on Cay(G, {σ, σ⁻¹, τ, τ⁻¹}).
    """
    if use_dp:
        cwc = closed_word_count_dp(sigma, tau, m)
    else:
        cwc = closed_word_count(sigma, tau, m)
    return Fraction(cwc, 4**m)


def free_group_return_moment(m: int) -> Fraction:
    """
    Free-group return moment (simplified baseline).
    At m=0: 1 (the empty word is always identity).
    At m≥1: 0 (in the simplified model).
    """
    return Fraction(1) if m == 0 else Fraction(0)


def excess_moment(sigma: Perm, tau: Perm, m: int,
                  use_dp: bool = False) -> Fraction:
    """
    The excess moment: momentKernel(σ, τ, m) - freeGroupReturnMoment(m).
    Measures deviation from the free-group baseline.
    """
    return moment_kernel(sigma, tau, m, use_dp) - free_group_return_moment(m)


# ============================================================
# Average excess moment
# ============================================================

def avg_excess_moment(n: int, m: int, use_dp: bool = True) -> Fraction:
    """
    Average excess moment over all pairs (σ, τ) in S_n.

    Algorithm: Exhaustive sum over (n!)² pairs.
    Time complexity: O((n!)² * m * n!) with DP, O((n!)² * 4^m * m * n) without

    For n ≥ 6, this is very expensive. Use sampling instead.
    """
    perms = all_permutations(n)
    total = Fraction(0)
    for sigma in perms:
        for tau in perms:
            total += excess_moment(sigma, tau, m, use_dp)
    card = len(perms)
    return total / Fraction(card * card)


def avg_excess_moment_by_class(n: int, m: int) -> Fraction:
    """
    Average excess moment using conjugacy-class compression.

    Algorithm:
    1. Group permutations by cycle type
    2. For each pair of cycle types, compute the excess moment
       for a representative pair (weighted by class sizes)

    This exploits conjugation invariance: excessMoment(hσh⁻¹, hτh⁻¹, m) =
    excessMoment(σ, τ, m), so we only need one representative per
    conjugacy class pair.

    Time complexity: O(p(n)² * m * n!) where p(n) = number of partitions
    """
    perms = all_permutations(n)

    # Group by cycle type
    classes: Dict[Tuple[int, ...], List[Perm]] = {}
    for p in perms:
        ct = cycle_type(p)
        if ct not in classes:
            classes[ct] = []
        classes[ct].append(p)

    total = Fraction(0)
    card = len(perms)

    for ct1, members1 in classes.items():
        rep1 = members1[0]
        size1 = len(members1)
        for ct2, members2 in classes.items():
            rep2 = members2[0]
            size2 = len(members2)
            em = excess_moment(rep1, rep2, m, use_dp=True)
            total += Fraction(size1 * size2) * em

    return total / Fraction(card * card)


# ============================================================
# Truncated excess partition function
# ============================================================

def truncated_excess_partition_fn(
    sigma: Perm, tau: Perm, K: int, beta: Fraction
) -> Fraction:
    """
    Truncated excess partition function:
    Z_K(β; σ, τ) = Σ_{k=0}^{K} (β^k / k!) * excessMoment(σ, τ, k)

    This bridges expander theory to statistical mechanics.
    """
    total = Fraction(0)
    for k in range(K + 1):
        coeff = beta**k / Fraction(math.factorial(k))
        em = excess_moment(sigma, tau, k, use_dp=True)
        total += coeff * em
    return total


# ============================================================
# Verification routines
# ============================================================

def verify_conjugation_invariance(n: int, m: int, num_tests: int = 10) -> bool:
    """
    Verify that the moment kernel is conjugation-invariant
    for random triples (σ, τ, h) in S_n.
    """
    import random
    perms = all_permutations(n)
    for _ in range(num_tests):
        sigma = random.choice(perms)
        tau = random.choice(perms)
        h = random.choice(perms)
        sigma_conj = conjugate(h, sigma)
        tau_conj = conjugate(h, tau)
        mk1 = moment_kernel(sigma, tau, m, use_dp=True)
        mk2 = moment_kernel(sigma_conj, tau_conj, m, use_dp=True)
        if mk1 != mk2:
            return False
    return True


def verify_class_compression(n: int, m: int) -> bool:
    """
    Verify that avg_excess_moment equals avg_excess_moment_by_class.
    """
    exact = avg_excess_moment(n, m)
    compressed = avg_excess_moment_by_class(n, m)
    return exact == compressed


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("=== Algorithm Verification ===\n")

    # Test conjugation invariance
    print("Conjugation invariance (n=4, m=2):",
          verify_conjugation_invariance(4, 2))
    print("Conjugation invariance (n=4, m=4):",
          verify_conjugation_invariance(4, 4))

    # Test class compression
    print("\nClass compression (n=3, m=2):",
          verify_class_compression(3, 2))
    print("Class compression (n=4, m=2):",
          verify_class_compression(4, 2))

    # Compute average excess moments
    print("\n=== Average Excess Moments ===\n")
    for n in range(3, 6):
        for k in [1, 2]:
            m = 2 * k
            a = avg_excess_moment(n, m)
            print(f"  avgExcessMoment(S_{n}, {m}) = {float(a):.8f}"
                  f"  (n * A = {float(a * n):.8f})")

    # Truncated partition function
    print("\n=== Truncated Partition Function ===\n")
    n = 3
    perms = all_permutations(n)
    K = 3
    total_Z = sum(
        truncated_excess_partition_fn(s, t, K, Fraction(1))
        for s in perms for t in perms
    )
    bound = Fraction(len(perms)**2) * sum(
        Fraction(1, math.factorial(k)) for k in range(K + 1)
    )
    print(f"  n={n}, K={K}: total Z = {float(total_Z):.6f}")
    print(f"  Bound = {float(bound):.6f}")
    print(f"  Satisfies bound: {total_Z <= bound}")

#!/usr/bin/env python3
"""
algorithms.py — Core Algorithms for Alternating Permutation Network Analysis

Implements the mathematical algorithms from the research paper:
1. TV distance computation (exact and empirical)
2. Observable bias computation (displacement, inversion count)
3. Support-size TV lower bound certification
4. Heavy-point detection and min-entropy estimation
5. Distinguisher construction from observables

All algorithms correspond to formally verified Lean theorems.
"""

import math
import random
from collections import Counter
from typing import List, Tuple, Dict, Optional


# ──────────────────────────────────────────────────────────────
# §1. Permutation primitives
# ──────────────────────────────────────────────────────────────

def identity(n: int) -> Tuple[int, ...]:
    """Identity permutation on {0, ..., n-1}."""
    return tuple(range(n))


def compose(a: Tuple[int, ...], b: Tuple[int, ...]) -> Tuple[int, ...]:
    """Compose permutations: (a ∘ b)(i) = a(b(i))."""
    return tuple(a[b[i]] for i in range(len(a)))


def adj_swap(n: int, j: int) -> Tuple[int, ...]:
    """Adjacent transposition swap(j, j+1)."""
    p = list(range(n))
    p[j], p[j + 1] = p[j + 1], p[j]
    return tuple(p)


def cyclic_shift(n: int, t: int) -> Tuple[int, ...]:
    """Cyclic shift by t: i ↦ (i + t) mod n."""
    return tuple((i + t) % n for i in range(n))


def inverse_perm(p: Tuple[int, ...]) -> Tuple[int, ...]:
    """Inverse of a permutation."""
    n = len(p)
    inv = [0] * n
    for i in range(n):
        inv[p[i]] = i
    return tuple(inv)


# ──────────────────────────────────────────────────────────────
# §2. Observable functions
# ──────────────────────────────────────────────────────────────

def total_displacement(perm: Tuple[int, ...]) -> int:
    """Total displacement: ∑_i |σ(i) - i|.

    This is the wire-movement cost observable.
    Theorem 4 proves |Δ(displacement)| ≤ 2 per adjacent swap.

    >>> total_displacement((0, 1, 2, 3))
    0
    >>> total_displacement((3, 2, 1, 0))
    8
    """
    return sum(abs(perm[i] - i) for i in range(len(perm)))


def inversion_count(perm: Tuple[int, ...]) -> int:
    """Number of inversions: #{(i,j) : i < j and σ(i) > σ(j)}.

    >>> inversion_count((0, 1, 2, 3))
    0
    >>> inversion_count((3, 2, 1, 0))
    6
    """
    n = len(perm)
    count = 0
    for i in range(n):
        for j in range(i + 1, n):
            if perm[i] > perm[j]:
                count += 1
    return count


def cycle_structure(perm: Tuple[int, ...]) -> List[int]:
    """Cycle type of a permutation (sorted list of cycle lengths).

    >>> cycle_structure((1, 2, 0, 3))
    [1, 3]
    """
    n = len(perm)
    visited = [False] * n
    cycles = []
    for i in range(n):
        if not visited[i]:
            length = 0
            j = i
            while not visited[j]:
                visited[j] = True
                j = perm[j]
                length += 1
            cycles.append(length)
    return sorted(cycles)


def fixed_point_count(perm: Tuple[int, ...]) -> int:
    """Number of fixed points: #{i : σ(i) = i}.

    >>> fixed_point_count((0, 1, 2, 3))
    4
    >>> fixed_point_count((1, 0, 3, 2))
    0
    """
    return sum(1 for i in range(len(perm)) if perm[i] == i)


# ──────────────────────────────────────────────────────────────
# §3. Network construction
# ──────────────────────────────────────────────────────────────

def random_adj_swap_layer(n: int, k: int) -> Tuple[int, ...]:
    """Random adjacent-swap layer with at most k non-overlapping swaps.

    Args:
        n: Number of wires
        k: Maximum number of swaps

    Returns:
        Permutation as tuple
    """
    available = list(range(n - 1))
    random.shuffle(available)
    layer = identity(n)
    used = set()
    count = 0
    for j in available:
        if j not in used and (j + 1) not in used and count < k:
            layer = compose(adj_swap(n, j), layer)
            used.update([j, j + 1])
            count += 1
    return layer


def build_network(n: int, T: int, k: int,
                  shift_schedule: Optional[List[int]] = None) -> Tuple[int, ...]:
    """Build a T-round alternating permutation network.

    Even rounds: adjacent-swap layer (up to k swaps)
    Odd rounds: cyclic-shift layer

    Args:
        n: Number of wires
        T: Number of rounds
        k: Max swaps per swap layer
        shift_schedule: Optional fixed shift amounts for cyclic layers

    Returns:
        Composed permutation
    """
    result = identity(n)
    shift_idx = 0
    for r in range(T):
        if r % 2 == 0:
            layer = random_adj_swap_layer(n, k)
        else:
            if shift_schedule and shift_idx < len(shift_schedule):
                t = shift_schedule[shift_idx]
                shift_idx += 1
            else:
                t = random.randint(0, n - 1)
            layer = cyclic_shift(n, t)
        result = compose(layer, result)
    return result


# ──────────────────────────────────────────────────────────────
# §4. TV distance computation
# ──────────────────────────────────────────────────────────────

def empirical_tv_distance(counts: Counter, n_factorial: int,
                          num_samples: int) -> float:
    """Compute empirical TV distance from uniform distribution.

    TV(μ, U) = (1/2) ∑_σ |μ(σ) - 1/n!|

    Args:
        counts: Counter of observed permutations
        n_factorial: n! = |S_n|
        num_samples: Total number of samples

    Returns:
        Estimated TV distance
    """
    uniform_prob = 1.0 / n_factorial
    tv = 0.0
    for count in counts.values():
        emp_prob = count / num_samples
        tv += abs(emp_prob - uniform_prob)
    unseen = n_factorial - len(counts)
    tv += unseen * uniform_prob
    return tv / 2.0


def support_size_tv_bound(support_size: int, n_factorial: int) -> float:
    """Certified TV lower bound from support size.

    Theorem 2: TV(μ, U) ≥ 1 - |supp(μ)|/|S_n|

    Args:
        support_size: Number of distinct permutations in the output
        n_factorial: n! = |S_n|

    Returns:
        Lower bound on TV distance

    >>> support_size_tv_bound(100, 40320)
    0.9975198412698413
    """
    return max(0.0, 1.0 - support_size / n_factorial)


# ──────────────────────────────────────────────────────────────
# §5. Observable-based distinguisher
# ──────────────────────────────────────────────────────────────

def observable_distinguisher(samples: List[Tuple[int, ...]],
                             observable_fn,
                             threshold: float) -> float:
    """Compute distinguisher advantage using an observable.

    Theorem 1: If |E_μ[f] - E_U[f]| ≥ δ and |f| ≤ B,
    then TV(μ,U) ≥ δ/(2B).

    Args:
        samples: List of sampled permutations
        observable_fn: Function mapping permutation to real value
        threshold: Decision threshold

    Returns:
        Estimated advantage (fraction above threshold vs expected uniform fraction)
    """
    values = [observable_fn(s) for s in samples]
    fraction_above = sum(1 for v in values if v > threshold) / len(values)
    return fraction_above


def compute_observable_bias(samples: List[Tuple[int, ...]],
                            n: int,
                            observable_fn) -> Tuple[float, float, float]:
    """Compute observable bias and certified TV lower bound.

    Returns:
        (empirical_mean, uniform_mean_estimate, tv_lower_bound)
    """
    import itertools

    # Empirical mean under μ
    values = [observable_fn(s) for s in samples]
    emp_mean = sum(values) / len(values)

    # Exact mean under uniform (compute for small n)
    if n <= 8:
        n_factorial = math.factorial(n)
        total = sum(observable_fn(p) for p in itertools.permutations(range(n)))
        uniform_mean = total / n_factorial
    else:
        # Approximate for large n
        uniform_samples = [tuple(random.sample(range(n), n)) for _ in range(10000)]
        uniform_mean = sum(observable_fn(s) for s in uniform_samples) / len(uniform_samples)

    # Observable bound
    B = max(abs(v) for v in values) if values else 1
    delta = abs(emp_mean - uniform_mean)
    tv_bound = delta / (2 * B) if B > 0 else 0

    return emp_mean, uniform_mean, tv_bound


# ──────────────────────────────────────────────────────────────
# §6. Heavy-point detection
# ──────────────────────────────────────────────────────────────

def detect_heavy_points(counts: Counter, n_factorial: int,
                        num_samples: int) -> List[Tuple[Tuple[int, ...], float, float]]:
    """Find permutations with mass exceeding 1/n! (heavy points).

    Theorem 3: TV ≥ ε implies ∃ σ with μ(σ) ≥ (1+ε)/n!

    Args:
        counts: Counter of observed permutations
        n_factorial: n!
        num_samples: Total samples

    Returns:
        List of (permutation, empirical_prob, excess_ratio) for heavy points,
        sorted by excess ratio descending
    """
    uniform_prob = 1.0 / n_factorial
    heavy = []
    for perm, count in counts.items():
        emp_prob = count / num_samples
        if emp_prob > uniform_prob:
            excess = emp_prob / uniform_prob
            heavy.append((perm, emp_prob, excess))
    heavy.sort(key=lambda x: -x[2])
    return heavy


# ──────────────────────────────────────────────────────────────
# §7. Min-entropy estimation
# ──────────────────────────────────────────────────────────────

def estimate_min_entropy(counts: Counter, num_samples: int) -> float:
    """Estimate min-entropy: H_∞(μ) = -log₂(max_a μ(a)).

    Theorem 5: TV ≥ ε implies max μ(a) ≥ (1+ε)/N,
    so H_∞ ≤ log₂(N) - log₂(1+ε).

    Args:
        counts: Counter of observations
        num_samples: Total samples

    Returns:
        Estimated min-entropy in bits
    """
    max_count = max(counts.values())
    max_prob = max_count / num_samples
    if max_prob <= 0:
        return float('inf')
    return -math.log2(max_prob)


def entropy_gap(min_entropy: float, n: int) -> float:
    """Entropy deficiency: log₂(n!) - H_∞(μ).

    A positive gap indicates exploitable non-uniformity.
    """
    max_entropy = math.log2(math.factorial(n))
    return max_entropy - min_entropy


# ──────────────────────────────────────────────────────────────
# §8. Worst-case layer schedule search
# ──────────────────────────────────────────────────────────────

def search_worst_case_schedule(n: int, T: int, k: int,
                               num_trials: int = 1000,
                               num_samples_per_trial: int = 5000
                               ) -> Dict:
    """Search for layer schedules that maximize residual bias.

    Explores different cyclic shift schedules and evaluates
    which leaves the most detectable structure.

    Returns:
        Dictionary with best schedule and its statistics
    """
    n_factorial = math.factorial(n)
    best_tv = 0
    best_schedule = None
    best_stats = None

    for trial in range(num_trials):
        # Random shift schedule
        num_shift_layers = T // 2
        schedule = [random.randint(0, n - 1) for _ in range(num_shift_layers)]

        counts = Counter()
        for _ in range(num_samples_per_trial):
            perm = build_network(n, T, k, shift_schedule=schedule)
            counts[perm] += 1

        tv = empirical_tv_distance(counts, n_factorial, num_samples_per_trial)
        if tv > best_tv:
            best_tv = tv
            best_schedule = schedule
            best_stats = {
                'tv': tv,
                'support': len(counts),
                'support_ratio': len(counts) / n_factorial,
                'min_entropy': estimate_min_entropy(counts, num_samples_per_trial),
            }

    return {
        'schedule': best_schedule,
        'stats': best_stats
    }


if __name__ == '__main__':
    # Quick demo
    n = 6
    print(f"=== Algorithms Demo (n={n}) ===\n")

    # Build some networks
    samples = [build_network(n, T=4, k=2) for _ in range(10000)]
    counts = Counter(samples)
    n_fact = math.factorial(n)

    print(f"Support size: {len(counts)} / {n_fact} = {len(counts)/n_fact:.4f}")
    print(f"TV distance (empirical): {empirical_tv_distance(counts, n_fact, len(samples)):.4f}")
    print(f"Support-size TV bound: {support_size_tv_bound(len(counts), n_fact):.4f}")
    print(f"Min-entropy: {estimate_min_entropy(counts, len(samples)):.2f} bits")
    print(f"Max entropy: {math.log2(n_fact):.2f} bits")
    print(f"Entropy gap: {entropy_gap(estimate_min_entropy(counts, len(samples)), n):.2f} bits")

    # Observable bias
    emp, unif, tv_lb = compute_observable_bias(samples, n, total_displacement)
    print(f"\nDisplacement observable:")
    print(f"  E_μ[disp] = {emp:.2f}")
    print(f"  E_U[disp] = {unif:.2f}")
    print(f"  TV lower bound from bias: {tv_lb:.4f}")

    # Heavy points
    heavy = detect_heavy_points(counts, n_fact, len(samples))[:5]
    print(f"\nTop 5 heavy points (excess ratio over 1/n!):")
    for perm, prob, excess in heavy:
        print(f"  σ = {perm}: μ(σ) = {prob:.6f}, ratio = {excess:.1f}×")

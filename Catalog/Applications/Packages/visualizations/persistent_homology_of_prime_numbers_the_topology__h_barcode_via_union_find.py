"""
Algorithms for Persistent Homology of Prime Point Clouds

Implements:
1. Rips filtration computation for 1D point clouds
2. H₀ barcode extraction via union-find
3. Gap distribution analysis
4. Poisson process comparison
"""

import math
from typing import List, Tuple, Optional, Dict
from collections import Counter


class UnionFind:
    """
    Union-Find (Disjoint Set Union) data structure for tracking
    connected components during the Rips filtration.

    Time complexity: O(α(n)) amortized per operation where α is the
    inverse Ackermann function.

    Space complexity: O(n)
    """

    def __init__(self, n: int):
        self.parent = list(range(n))
        self.rank = [0] * n
        self.n_components = n

    def find(self, x: int) -> int:
        """Find root with path compression."""
        if self.parent[x] != x:
            self.parent[x] = self.find(self.parent[x])
        return self.parent[x]

    def union(self, x: int, y: int) -> bool:
        """Union by rank. Returns True if a merge occurred."""
        rx, ry = self.find(x), self.find(y)
        if rx == ry:
            return False
        if self.rank[rx] < self.rank[ry]:
            rx, ry = ry, rx
        self.parent[ry] = rx
        if self.rank[rx] == self.rank[ry]:
            self.rank[rx] += 1
        self.n_components -= 1
        return True


def sieve_primes(n: int) -> List[int]:
    """Sieve of Eratosthenes. O(n log log n) time, O(n) space."""
    if n < 2:
        return []
    is_prime = [True] * (n + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(n**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, n + 1, i):
                is_prime[j] = False
    return [i for i in range(2, n + 1) if is_prime[i]]


def compute_h0_barcode_unionfind(points: List[int]) -> List[Tuple[int, int]]:
    """
    Compute H₀ barcode of a 1D point cloud using union-find.

    For a 1D point cloud, the Rips filtration is equivalent to sorting
    gaps and merging components in order of increasing gap size.

    Algorithm:
    1. Sort points (O(n log n))
    2. Compute gaps between consecutive points (O(n))
    3. Sort gaps (O(n log n))
    4. Process gaps in increasing order, merging components (O(n α(n)))

    Total: O(n log n) time, O(n) space

    Returns: List of (birth, death) pairs. birth=0 for all H₀ bars.
             One bar has death=∞ (represented as -1) for the essential class.
    """
    if len(points) <= 1:
        return [(0, -1)]  # Single essential class

    sorted_pts = sorted(points)
    n = len(sorted_pts)

    # Compute gaps with indices
    gaps_with_idx = []
    for i in range(n - 1):
        gap = sorted_pts[i + 1] - sorted_pts[i]
        gaps_with_idx.append((gap, i))

    # Sort by gap size
    gaps_with_idx.sort()

    # Union-find to track merging
    uf = UnionFind(n)
    barcode = []

    for gap_size, idx in gaps_with_idx:
        if uf.union(idx, idx + 1):
            barcode.append((0, gap_size))  # Component dies at this scale

    # Add essential class
    barcode.append((0, -1))

    return barcode


def compute_h0_barcode_direct(points: List[int]) -> List[Tuple[int, int]]:
    """
    Direct H₀ barcode computation for 1D point clouds.

    For 1D data, the barcode is simply the sorted list of gaps
    (each gap kills one component). No union-find needed.

    O(n log n) time, O(n) space.
    """
    if len(points) <= 1:
        return [(0, -1)]

    sorted_pts = sorted(points)
    gaps = [sorted_pts[i+1] - sorted_pts[i] for i in range(len(sorted_pts) - 1)]

    barcode = [(0, g) for g in sorted(gaps)]
    barcode.append((0, -1))  # Essential class
    return barcode


def gap_distribution_statistics(primes: List[int]) -> Dict[str, float]:
    """
    Compute statistics of the prime gap distribution.

    Returns dict with mean, variance, max, and comparison to log(N) prediction.
    """
    gaps = [primes[i+1] - primes[i] for i in range(len(primes) - 1)]
    N = primes[-1]
    log_N = math.log(N)

    mean_gap = sum(gaps) / len(gaps)
    var_gap = sum((g - mean_gap)**2 for g in gaps) / len(gaps)
    max_gap = max(gaps)

    return {
        "n_primes": len(primes),
        "n_gaps": len(gaps),
        "N": N,
        "log_N": log_N,
        "mean_gap": mean_gap,
        "predicted_mean": log_N,
        "mean_ratio": mean_gap / log_N,
        "variance": var_gap,
        "max_gap": max_gap,
        "max_gap_over_log_N": max_gap / log_N,
        "max_gap_over_log_N_sq": max_gap / (log_N ** 2),
    }


def exponential_fit_test(
    gaps: List[int], log_N: float, k_values: Optional[List[float]] = None
) -> List[Dict[str, float]]:
    """
    Test whether prime gaps follow an exponential distribution with mean log(N).

    The Cramér model predicts P(gap > k·log(N)) ≈ e^(-k).

    Returns list of test results for each k value.
    """
    if k_values is None:
        k_values = [0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 4.0, 5.0]

    n = len(gaps)
    results = []

    for k in k_values:
        threshold = k * log_N
        count_exceeding = sum(1 for g in gaps if g > threshold)
        observed_fraction = count_exceeding / n
        expected_fraction = math.exp(-k)
        ratio = observed_fraction / expected_fraction if expected_fraction > 0 else float('inf')

        results.append({
            "k": k,
            "threshold": threshold,
            "count_exceeding": count_exceeding,
            "observed_fraction": observed_fraction,
            "expected_fraction": expected_fraction,
            "ratio": ratio,
            "log_ratio": math.log(ratio) if ratio > 0 else float('-inf'),
        })

    return results


def persistence_entropy(barcode: List[Tuple[int, int]]) -> float:
    """
    Compute the persistence entropy of a barcode.

    Persistence entropy is defined as:
        H = -Σ (p_i · log(p_i))
    where p_i = persistence_i / total_persistence.

    This measures the "spread" of topological features across scales.
    Higher entropy = more uniform distribution of bar lengths.
    """
    # Filter finite bars
    finite_bars = [(b, d) for b, d in barcode if d >= 0]
    if not finite_bars:
        return 0.0

    persistences = [d - b for b, d in finite_bars]
    total = sum(persistences)
    if total == 0:
        return 0.0

    entropy = 0.0
    for p in persistences:
        if p > 0:
            prob = p / total
            entropy -= prob * math.log(prob)

    return entropy


if __name__ == "__main__":
    # Example usage
    print("Computing H₀ barcode for primes up to 100...")
    primes = sieve_primes(100)
    print(f"Primes: {primes}")

    barcode_uf = compute_h0_barcode_unionfind(primes)
    barcode_direct = compute_h0_barcode_direct(primes)

    print(f"\nBarcode (union-find): {barcode_uf}")
    print(f"Barcode (direct):    {barcode_direct}")

    # Statistics for larger N
    for N in [1000, 10000, 100000, 1000000]:
        primes = sieve_primes(N)
        stats = gap_distribution_statistics(primes)
        print(f"\nN={N}: mean_gap={stats['mean_gap']:.2f}, "
              f"log(N)={stats['log_N']:.2f}, "
              f"ratio={stats['mean_ratio']:.4f}, "
              f"max_gap={stats['max_gap']}")

    # Persistence entropy
    primes = sieve_primes(100000)
    barcode = compute_h0_barcode_direct(primes)
    ent = persistence_entropy(barcode)
    print(f"\nPersistence entropy for primes up to 100000: {ent:.4f}")

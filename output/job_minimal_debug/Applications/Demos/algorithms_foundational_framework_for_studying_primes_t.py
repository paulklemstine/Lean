#!/usr/bin/env python3
"""
Algorithms for the Logarithmic Prime Metric Framework

Type-hinted implementations of the core algorithms for studying prime
distribution through the logarithmic metric d(p,q) = |1/log(p) - 1/log(q)|.
"""

import math
from dataclasses import dataclass, field
from typing import List, Tuple, Optional, Dict, Set


# =============================================================================
# Core Data Structures
# =============================================================================

@dataclass
class PrimeConstellation:
    """A finite set of primes within a log-metric ball."""
    center: int
    radius: float
    primes: List[int] = field(default_factory=list)

    @property
    def size(self) -> int:
        return len(self.primes)

    @property
    def diameter(self) -> float:
        if len(self.primes) < 2:
            return 0.0
        images = [1.0 / math.log(p) for p in self.primes]
        return max(images) - min(images)


@dataclass
class EnergySpectrum:
    """The s-energy spectrum of a prime set."""
    primes: List[int]
    exponents: List[float]
    energies: List[float]


# =============================================================================
# Algorithm 1: Sieve and Transform
# =============================================================================

def sieve_of_eratosthenes(n: int) -> List[int]:
    """
    Standard sieve of Eratosthenes.

    Time: O(n log log n)
    Space: O(n)
    """
    if n < 2:
        return []
    is_prime: List[bool] = [True] * (n + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(n**0.5) + 1):
        if is_prime[i]:
            for j in range(i * i, n + 1, i):
                is_prime[j] = False
    return [i for i in range(2, n + 1) if is_prime[i]]


def log_prime_transform(primes: List[int]) -> List[Tuple[int, float]]:
    """
    Apply the logarithmic prime transform p ↦ 1/log(p).

    Returns list of (prime, image) pairs, sorted by image value (descending).

    Pseudocode:
        FOR each prime p:
            compute t_p = 1/log(p)
        SORT by t_p descending
        RETURN pairs (p, t_p)
    """
    pairs: List[Tuple[int, float]] = [(p, 1.0 / math.log(p)) for p in primes]
    pairs.sort(key=lambda x: -x[1])  # Descending by image (anti-tonic)
    return pairs


# =============================================================================
# Algorithm 2: Box-Counting Dimension Estimator
# =============================================================================

def box_counting_dimension(
    N: int,
    epsilon_range: Optional[List[float]] = None
) -> Dict[str, float]:
    """
    Estimate the box-counting dimension of {1/log(p) : p prime, p ≤ N}.

    Pseudocode:
        SIEVE primes up to N
        COMPUTE images {1/log(p)}
        FOR each scale epsilon:
            COUNT boxes of width epsilon that contain ≥ 1 image point
            RECORD (log(1/epsilon), log(count))
        FIT linear regression to get slope = dimension estimate

    Returns dict with dimension estimate and fitting data.
    """
    primes = sieve_of_eratosthenes(N)
    images: List[float] = sorted(set(1.0 / math.log(p) for p in primes))

    if epsilon_range is None:
        epsilon_range = [10**(-k/3) for k in range(2, 12)]

    log_inv_eps: List[float] = []
    log_counts: List[float] = []

    for epsilon in epsilon_range:
        boxes: Set[int] = set()
        for x in images:
            boxes.add(int(x / epsilon))
        count = len(boxes)
        if count > 1:
            log_inv_eps.append(math.log(1.0 / epsilon))
            log_counts.append(math.log(count))

    # Linear regression: log(count) = dim * log(1/eps) + const
    if len(log_inv_eps) < 2:
        return {'dimension': 0.0, 'r_squared': 0.0, 'data_points': 0}

    n = len(log_inv_eps)
    sx = sum(log_inv_eps)
    sy = sum(log_counts)
    sxx = sum(x*x for x in log_inv_eps)
    sxy = sum(x*y for x, y in zip(log_inv_eps, log_counts))

    denom = n * sxx - sx * sx
    if abs(denom) < 1e-15:
        return {'dimension': 0.0, 'r_squared': 0.0, 'data_points': n}

    slope = (n * sxy - sx * sy) / denom

    # R-squared
    mean_y = sy / n
    ss_tot = sum((y - mean_y)**2 for y in log_counts)
    intercept = (sy - slope * sx) / n
    ss_res = sum((y - slope*x - intercept)**2
                 for x, y in zip(log_inv_eps, log_counts))
    r_sq = 1.0 - ss_res / ss_tot if ss_tot > 0 else 0.0

    return {
        'dimension': slope,
        'r_squared': r_sq,
        'data_points': n,
        'intercept': intercept,
    }


# =============================================================================
# Algorithm 3: Prime Constellation Finder
# =============================================================================

def find_constellations(
    max_prime: int,
    radius: float,
    min_size: int = 3
) -> List[PrimeConstellation]:
    """
    Find all maximal prime constellations of given radius.

    Pseudocode:
        SIEVE primes, compute images
        SORT images (already ordered by transform)
        SLIDING WINDOW of width 2*radius over sorted images
        FOR each window:
            IF window contains ≥ min_size primes:
                RECORD constellation with center = median prime

    Returns list of PrimeConstellation objects.
    """
    pairs = log_prime_transform(sieve_of_eratosthenes(max_prime))
    if not pairs:
        return []

    constellations: List[PrimeConstellation] = []
    n = len(pairs)

    i = 0
    while i < n:
        # Find largest j such that image[i] - image[j] ≤ 2*radius
        j = i
        while j < n and pairs[i][1] - pairs[j][1] <= 2 * radius:
            j += 1
        j -= 1

        window_size = j - i + 1
        if window_size >= min_size:
            # Center is the median prime
            mid = (i + j) // 2
            center_prime = pairs[mid][0]
            member_primes = [pairs[k][0] for k in range(i, j + 1)]
            constellations.append(PrimeConstellation(
                center=center_prime,
                radius=radius,
                primes=sorted(member_primes)
            ))
            i = j + 1  # Move past this constellation
        else:
            i += 1

    return constellations


# =============================================================================
# Algorithm 4: Log-Gap Energy Computation
# =============================================================================

def compute_energy_spectrum(
    primes: List[int],
    s_values: Optional[List[float]] = None
) -> EnergySpectrum:
    """
    Compute the s-energy E_s = Σ_{p<q} (1/d(p,q))^s for multiple s values.

    Pseudocode:
        COMPUTE all pairwise distances d(p,q) for p < q
        FOR each exponent s:
            SUM (1/d)^s over all pairs
        RETURN energy spectrum

    The energy divergence at s = 1/2 is predicted by the box-counting
    dimension conjecture.
    """
    if s_values is None:
        s_values = [0.1 * k for k in range(1, 21)]

    # Precompute all pairwise distances
    distances: List[float] = []
    for i in range(len(primes)):
        for j in range(i + 1, len(primes)):
            d = abs(1.0/math.log(primes[i]) - 1.0/math.log(primes[j]))
            if d > 0:
                distances.append(d)

    energies: List[float] = []
    for s in s_values:
        E = sum((1.0/d)**s for d in distances)
        energies.append(E)

    return EnergySpectrum(
        primes=primes,
        exponents=s_values,
        energies=energies
    )


# =============================================================================
# Algorithm 5: Dimension Gap Detector
# =============================================================================

def dimension_gap_analysis(N_values: Optional[List[int]] = None) -> Dict[str, List]:
    """
    Analyze the dimension gap between Hausdorff (0) and box-counting dimensions.

    For each N, estimates dim_B and computes the gap from 0 (Hausdorff dim).

    Returns structured analysis data.
    """
    if N_values is None:
        N_values = [10**k for k in range(3, 7)]

    results: Dict[str, List] = {
        'N': [],
        'num_primes': [],
        'box_dim': [],
        'gap': [],
        'r_squared': [],
    }

    for N in N_values:
        primes = sieve_of_eratosthenes(N)
        bd = box_counting_dimension(N)
        results['N'].append(N)
        results['num_primes'].append(len(primes))
        results['box_dim'].append(bd['dimension'])
        results['gap'].append(bd['dimension'])  # gap = box_dim - 0
        results['r_squared'].append(bd['r_squared'])

    return results


if __name__ == "__main__":
    # Quick self-test
    print("Testing algorithms...")

    primes = sieve_of_eratosthenes(1000)
    print(f"Primes up to 1000: {len(primes)}")

    pairs = log_prime_transform(primes[:10])
    print(f"Transform (first 10): {[(p, f'{t:.4f}') for p, t in pairs]}")

    bd = box_counting_dimension(100000)
    print(f"Box-counting dim (N=100000): {bd['dimension']:.4f} "
          f"(R²={bd['r_squared']:.4f})")

    consts = find_constellations(10000, 0.005, min_size=5)
    print(f"Constellations (r=0.005, min=5): {len(consts)} found")
    for c in consts[:3]:
        print(f"  Center={c.center}, size={c.size}, diam={c.diameter:.6f}")

    spectrum = compute_energy_spectrum(sieve_of_eratosthenes(50))
    print(f"Energy spectrum (15 primes, s=0.5): E={spectrum.energies[4]:.2f}")

    gap = dimension_gap_analysis([1000, 10000, 100000])
    print(f"Dimension gaps: {[f'{g:.3f}' for g in gap['gap']]}")

    print("All tests passed.")

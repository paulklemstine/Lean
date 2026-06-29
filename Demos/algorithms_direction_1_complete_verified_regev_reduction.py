#!/usr/bin/env python3
"""
Algorithms for Regev Reduction Compositional Verification

Implements the core algorithms from the research:

1. Exact TVD Calculator for finite distributions
2. Hybrid Chain Analyzer - computes and verifies telescope bounds
3. BDD Uniqueness Checker - verifies well-separation conditions
4. LWE Instance Generator - creates LWE samples for testing
5. Quotient Pushforward Engine - applies modulus/dimension reduction

All algorithms use exact arithmetic (Fractions) for verification.
"""

from fractions import Fraction
from itertools import product
from typing import Dict, List, Tuple, Optional, Callable
import math


# ============================================================
# Algorithm 1: Exact TVD Calculator
# ============================================================

class TVDCalculator:
    """Exact total variation distance calculator for finite distributions.

    Uses rational arithmetic for exact computation.
    Time complexity: O(|support(p) ∪ support(q)|)
    Space complexity: O(|support(p) ∪ support(q)|)

    Example:
        >>> calc = TVDCalculator()
        >>> p = {0: Fraction(1,2), 1: Fraction(1,2)}
        >>> q = {0: Fraction(1,3), 1: Fraction(2,3)}
        >>> calc.compute(p, q)
        Fraction(1, 6)
    """

    @staticmethod
    def compute(p: Dict, q: Dict) -> Fraction:
        """Compute TVD(p, q) = (1/2) * Σ_x |p(x) - q(x)|."""
        keys = set(p.keys()) | set(q.keys())
        return Fraction(1, 2) * sum(
            abs(p.get(k, Fraction(0)) - q.get(k, Fraction(0)))
            for k in keys
        )

    @staticmethod
    def verify_contraction(p: Dict, q: Dict, f: Callable) -> Tuple[bool, Fraction, Fraction]:
        """Verify TVD contraction: TVD(f_*p, f_*q) ≤ TVD(p, q).

        Returns (holds, tvd_before, tvd_after).
        """
        tvd_before = TVDCalculator.compute(p, q)

        # Compute pushforward
        fp = {}
        for x, prob in p.items():
            y = f(x)
            fp[y] = fp.get(y, Fraction(0)) + prob

        fq = {}
        for x, prob in q.items():
            y = f(x)
            fq[y] = fq.get(y, Fraction(0)) + prob

        tvd_after = TVDCalculator.compute(fp, fq)
        return tvd_after <= tvd_before, tvd_before, tvd_after

    @staticmethod
    def verify_triangle(p: Dict, q: Dict, r: Dict) -> Tuple[bool, Fraction, Fraction]:
        """Verify triangle inequality: TVD(p,r) ≤ TVD(p,q) + TVD(q,r).

        Returns (holds, lhs, rhs).
        """
        lhs = TVDCalculator.compute(p, r)
        rhs = TVDCalculator.compute(p, q) + TVDCalculator.compute(q, r)
        return lhs <= rhs, lhs, rhs


# ============================================================
# Algorithm 2: Hybrid Chain Analyzer
# ============================================================

class HybridChainAnalyzer:
    """Analyzer for hybrid distribution chains.

    Computes and verifies telescope bounds for security reductions.

    Pseudocode:
        Input: distributions H_0, H_1, ..., H_n
        1. Compute total_tvd = TVD(H_0, H_n)
        2. For i = 0 to n-1:
           - Compute step_tvd[i] = TVD(H_i, H_{i+1})
        3. Verify: total_tvd ≤ Σ step_tvd[i]
        4. Return analysis report

    Time complexity: O(n * |domain|)
    Space complexity: O(n * |domain|)
    """

    def __init__(self, distributions: List[Dict]):
        self.distributions = distributions
        self.n = len(distributions) - 1

    def compute_step_tvds(self) -> List[Fraction]:
        """Compute TVD for each adjacent pair."""
        return [
            TVDCalculator.compute(self.distributions[i], self.distributions[i+1])
            for i in range(self.n)
        ]

    def compute_total_tvd(self) -> Fraction:
        """Compute TVD between first and last distribution."""
        return TVDCalculator.compute(self.distributions[0], self.distributions[-1])

    def verify_telescope(self) -> Dict:
        """Full telescope analysis.

        Returns dict with:
        - total_tvd: TVD(H_0, H_n)
        - step_tvds: list of adjacent TVDs
        - sum_steps: sum of step TVDs
        - bound_holds: whether telescope inequality holds
        - tightest_bound: ratio total/sum (1.0 = tight)
        """
        total = self.compute_total_tvd()
        steps = self.compute_step_tvds()
        step_sum = sum(steps)

        return {
            'total_tvd': total,
            'step_tvds': steps,
            'sum_steps': step_sum,
            'bound_holds': total <= step_sum,
            'tightness': float(total / step_sum) if step_sum > 0 else 1.0
        }

    def find_largest_gap(self) -> Tuple[int, Fraction]:
        """Find the hybrid step with largest TVD gap.

        By hybrid averaging, this step has advantage ≥ total/n.
        """
        steps = self.compute_step_tvds()
        max_idx = max(range(len(steps)), key=lambda i: steps[i])
        return max_idx, steps[max_idx]


# ============================================================
# Algorithm 3: BDD Uniqueness Checker
# ============================================================

class BDDChecker:
    """Bounded Distance Decoding uniqueness checker.

    Verifies the well-separation condition that ensures
    at most one lattice point is within decoding radius.

    Pseudocode:
        Input: lattice basis B, target t, radius r
        1. Enumerate lattice points within 2r of target
        2. Compute minimum distance between distinct points
        3. Check: min_dist > 2r ⟹ unique solution

    Time complexity: O(|lattice_points|² * n)
    Space complexity: O(|lattice_points| * n)
    """

    @staticmethod
    def euclidean_distance(x: Tuple, y: Tuple) -> float:
        return math.sqrt(sum((a - b)**2 for a, b in zip(x, y)))

    @staticmethod
    def check_well_separated(lattice_points: List[Tuple],
                              radius: float) -> Tuple[bool, float]:
        """Check if lattice is well-separated for given radius.

        Returns (is_well_separated, min_distance_between_points).
        """
        min_dist = float('inf')
        for i, p1 in enumerate(lattice_points):
            for j, p2 in enumerate(lattice_points):
                if i < j:
                    d = BDDChecker.euclidean_distance(p1, p2)
                    min_dist = min(min_dist, d)

        return min_dist > 2 * radius, min_dist

    @staticmethod
    def find_closest_lattice_point(lattice_points: List[Tuple],
                                    target: Tuple) -> Tuple[Optional[Tuple], float]:
        """Find the closest lattice point to target.

        Returns (closest_point, distance).
        """
        best = None
        best_dist = float('inf')
        for p in lattice_points:
            d = BDDChecker.euclidean_distance(p, target)
            if d < best_dist:
                best_dist = d
                best = p
        return best, best_dist

    @staticmethod
    def verify_uniqueness(lattice_points: List[Tuple],
                           target: Tuple,
                           radius: float) -> Dict:
        """Complete BDD uniqueness verification.

        Returns analysis report.
        """
        is_sep, min_dist = BDDChecker.check_well_separated(lattice_points, radius)
        within = [p for p in lattice_points
                  if BDDChecker.euclidean_distance(p, target) <= radius]
        closest, closest_dist = BDDChecker.find_closest_lattice_point(
            lattice_points, target)

        return {
            'well_separated': is_sep,
            'min_lattice_distance': min_dist,
            'separation_threshold': 2 * radius,
            'points_within_radius': within,
            'is_unique': len(within) <= 1,
            'closest_point': closest,
            'closest_distance': closest_dist,
        }


# ============================================================
# Algorithm 4: LWE Instance Generator
# ============================================================

class LWEGenerator:
    """Generator for LWE distributions over Z/qZ.

    Creates exact probability distributions for small parameters.

    Pseudocode:
        Input: modulus q, dimension n, secret s, noise dist χ
        1. For each a ∈ (Z/qZ)^n:
           a. For each e in support(χ):
              - Compute b = ⟨a,s⟩ + e mod q
              - Add probability (1/q^n) * χ(e) to sample (a, b)
        2. Return distribution

    Time complexity: O(q^n * |support(χ)|)
    Space complexity: O(q^n * q)
    """

    @staticmethod
    def discrete_gaussian_noise(q: int, sigma: float) -> Dict[int, Fraction]:
        """Approximate discrete Gaussian noise over Z/qZ.

        Args:
            q: Modulus
            sigma: Standard deviation parameter

        Returns:
            Normalized probability distribution
        """
        weights = {}
        for e in range(q):
            centered = min(e, q - e)
            w = math.exp(-centered**2 / (2 * sigma**2))
            weights[e] = Fraction(w).limit_denominator(10000)

        total = sum(weights.values())
        return {e: w / total for e, w in weights.items()}

    @staticmethod
    def generate_lwe_distribution(q: int, n: int, s: Tuple[int, ...],
                                   noise: Dict[int, Fraction]) -> Dict:
        """Generate exact LWE distribution."""
        dist = {}
        vectors = list(product(range(q), repeat=n))
        p_a = Fraction(1, q**n)

        for a in vectors:
            inner = sum(a[i] * s[i] for i in range(n)) % q
            for e, p_e in noise.items():
                b = (inner + e) % q
                key = (a, b)
                dist[key] = dist.get(key, Fraction(0)) + p_a * p_e

        return dist

    @staticmethod
    def uniform_distribution(q: int, n: int) -> Dict:
        """Generate uniform distribution over (Z/qZ)^n × Z/qZ."""
        dist = {}
        vectors = list(product(range(q), repeat=n))
        p = Fraction(1, q**(n+1))
        for a in vectors:
            for b in range(q):
                dist[(a, b)] = p
        return dist


# ============================================================
# Algorithm 5: Quotient Pushforward Engine
# ============================================================

class QuotientPushforward:
    """Engine for computing pushforward distributions under quotient maps.

    Supports modulus reduction, dimension reduction, and arbitrary
    linear maps over finite modules.

    Pseudocode:
        Input: distribution μ, function f
        1. Initialize output distribution ν = {}
        2. For each (x, p) in μ:
           - y = f(x)
           - ν[y] += p
        3. Return ν

    Time complexity: O(|support(μ)|)
    Space complexity: O(|range(f) ∩ support(f_*μ)|)
    """

    @staticmethod
    def pushforward(dist: Dict, f: Callable) -> Dict:
        """Compute pushforward f_*μ."""
        result = {}
        for x, p in dist.items():
            y = f(x)
            result[y] = result.get(y, Fraction(0)) + p
        return result

    @staticmethod
    def modulus_reduction(q_large: int, q_small: int) -> Callable:
        """Create modulus reduction map."""
        def f(sample):
            a, b = sample
            return (tuple(x % q_small for x in a), b % q_small)
        return f

    @staticmethod
    def dimension_projection(n_keep: int) -> Callable:
        """Create dimension projection map keeping first n_keep coords."""
        def f(sample):
            a, b = sample
            return (a[:n_keep], b)
        return f

    @staticmethod
    def compose(f: Callable, g: Callable) -> Callable:
        """Compose two pushforward maps: (g ∘ f)(x) = g(f(x))."""
        return lambda x: g(f(x))

    @staticmethod
    def verify_chain_contraction(dist_p: Dict, dist_q: Dict,
                                  maps: List[Callable]) -> List[Dict]:
        """Verify TVD contraction through a chain of maps.

        Returns list of dicts with TVD at each stage.
        """
        results = []
        p, q = dist_p, dist_q
        tvd_prev = TVDCalculator.compute(p, q)

        results.append({
            'stage': 0,
            'tvd': tvd_prev,
            'contraction': True
        })

        for i, f in enumerate(maps):
            p = QuotientPushforward.pushforward(p, f)
            q = QuotientPushforward.pushforward(q, f)
            tvd_curr = TVDCalculator.compute(p, q)

            results.append({
                'stage': i + 1,
                'tvd': tvd_curr,
                'contraction': tvd_curr <= tvd_prev
            })
            tvd_prev = tvd_curr

        return results


# ============================================================
# Example Usage
# ============================================================

if __name__ == "__main__":
    print("=" * 60)
    print("Algorithm Demonstrations")
    print("=" * 60)

    # TVD Calculator
    print("\n--- TVD Calculator ---")
    p = {0: Fraction(1, 2), 1: Fraction(1, 4), 2: Fraction(1, 4)}
    q_dist = {0: Fraction(1, 3), 1: Fraction(1, 3), 2: Fraction(1, 3)}
    tvd_val = TVDCalculator.compute(p, q_dist)
    print(f"TVD = {tvd_val} = {float(tvd_val):.6f}")

    # Triangle inequality
    r = {0: Fraction(1, 4), 1: Fraction(1, 2), 2: Fraction(1, 4)}
    holds, lhs, rhs = TVDCalculator.verify_triangle(p, q_dist, r)
    print(f"Triangle: {float(lhs):.4f} ≤ {float(rhs):.4f} ? {holds}")

    # LWE Generator
    print("\n--- LWE Instance Generator ---")
    noise = LWEGenerator.discrete_gaussian_noise(5, 1.0)
    print(f"Noise distribution (q=5, σ=1): {', '.join(f'{k}:{float(v):.3f}' for k,v in sorted(noise.items()))}")

    lwe = LWEGenerator.generate_lwe_distribution(5, 1, (2,), noise)
    unif = LWEGenerator.uniform_distribution(5, 1)
    print(f"TVD(LWE, Uniform) = {float(TVDCalculator.compute(lwe, unif)):.6f}")

    # BDD Checker
    print("\n--- BDD Uniqueness Checker ---")
    lattice = [(2*i, 2*j) for i in range(-5, 6) for j in range(-5, 6)]
    result = BDDChecker.verify_uniqueness(lattice, (0, 0), 0.9)
    print(f"Lattice: 2Z × 2Z, target=(0,0), radius=0.9")
    print(f"Well-separated: {result['well_separated']}")
    print(f"Min distance: {result['min_lattice_distance']:.2f}")
    print(f"Unique: {result['is_unique']}")

    # Pushforward Chain
    print("\n--- Quotient Pushforward Chain ---")
    lwe6 = LWEGenerator.generate_lwe_distribution(6, 1, (1,),
        LWEGenerator.discrete_gaussian_noise(6, 1.5))
    unif6 = LWEGenerator.uniform_distribution(6, 1)

    maps = [
        QuotientPushforward.modulus_reduction(6, 3),
    ]
    chain = QuotientPushforward.verify_chain_contraction(lwe6, unif6, maps)
    for step in chain:
        print(f"  Stage {step['stage']}: TVD = {float(step['tvd']):.6f}, "
              f"Contraction: {step['contraction']}")

#!/usr/bin/env python3
"""
algorithms.py — Algorithms for Mixing Time Analysis on Finite Groups

Implements:
1. Spectral gap computation for Cayley graph random walks
2. Certified mixing time bounds from spectral data
3. Observable-based lower bounds on total variation
4. TV distance profile computation
5. Cutoff window estimation

All algorithms include docstrings, type hints, and complexity analysis.
"""

import numpy as np
from math import factorial, log, ceil, sqrt
from typing import List, Tuple, Optional, Callable


def lehmer_encode(perm: Tuple[int, ...], n: int) -> int:
    """
    Convert a permutation to its Lehmer code index.

    Time complexity: O(n²)
    Space complexity: O(n)

    Args:
        perm: Permutation as a tuple of integers 0..n-1
        n: Size of the permutation

    Returns:
        Index in [0, n!) corresponding to the permutation
    """
    available = list(range(n))
    idx = 0
    fact = factorial(n)
    for i in range(n):
        fact //= (n - i)
        pos = available.index(perm[i])
        idx += pos * fact
        available.pop(pos)
    return idx


def lehmer_decode(idx: int, n: int) -> Tuple[int, ...]:
    """
    Convert a Lehmer code index to a permutation.

    Time complexity: O(n²)
    Space complexity: O(n)
    """
    available = list(range(n))
    perm = []
    fact = factorial(n)
    for i in range(n):
        fact //= (n - i)
        pos = idx // fact
        idx %= fact
        perm.append(available.pop(pos))
    return tuple(perm)


def compose_permutations(a: Tuple[int, ...], b: Tuple[int, ...]) -> Tuple[int, ...]:
    """Compose permutations: (a ∘ b)(i) = a(b(i)). O(n) time."""
    return tuple(a[b[i]] for i in range(len(a)))


class CayleyWalkGenerator:
    """
    Generates the transition matrix for a random walk on a Cayley graph.

    The walk is the symmetric random walk: at each step, multiply by a
    uniformly random generator from the symmetric generating set S.

    Time complexity for construction: O(n! · |S| · n²)
    Space complexity: O((n!)²)
    """

    def __init__(self, n: int, generators: List[Tuple[int, ...]]):
        self.n = n
        self.N = factorial(n)
        self.generators = generators
        self.k = len(generators)

    def build_transition_matrix(self, lazy: bool = True) -> np.ndarray:
        """Build the N×N transition matrix.
        If lazy=True, uses P = (I + P_raw)/2 for aperiodicity."""
        P = np.zeros((self.N, self.N))
        for idx in range(self.N):
            perm = lehmer_decode(idx, self.n)
            for gen in self.generators:
                new_perm = compose_permutations(gen, perm)
                new_idx = lehmer_encode(new_perm, self.n)
                P[idx, new_idx] += 1.0 / self.k
        if lazy:
            P = 0.5 * np.eye(self.N) + 0.5 * P
        return P


class SpectralGapAnalyzer:
    """
    Computes and analyzes the spectral gap of a transition matrix.

    The spectral gap is defined as gap = 1 - λ₂ where λ₂ is the
    second-largest eigenvalue (in absolute value) of the transition matrix.

    For a reversible Markov chain with uniform stationary distribution,
    the spectral gap controls:
    - L² mixing: ||P^t(x,·) - π||₂² ≤ (1-gap)^{2t} · (|Ω|-1)/|Ω|
    - TV mixing: ||P^t(x,·) - π||_TV ≤ (1/2)√(|Ω|-1) · (1-gap)^t
    - Variance decay: Var_π(P^t f) ≤ (1-gap)^{2t} · Var_π(f)
    - Relaxation time: τ_rel = 1/gap

    Time complexity: O(N³) for eigenvalue computation (N = state space size)
    """

    def __init__(self, P: np.ndarray):
        self.P = P
        self.N = P.shape[0]
        self._eigenvalues = None
        self._gap = None

    @property
    def eigenvalues(self) -> np.ndarray:
        """All eigenvalues, sorted by absolute value (descending)."""
        if self._eigenvalues is None:
            eigs = np.linalg.eigvalsh(self.P)
            self._eigenvalues = np.sort(np.abs(eigs))[::-1]
        return self._eigenvalues

    @property
    def spectral_gap(self) -> float:
        """The spectral gap: 1 - |λ₂|."""
        if self._gap is None:
            self._gap = 1.0 - self.eigenvalues[1]
        return self._gap

    @property
    def relaxation_time(self) -> float:
        """Relaxation time: 1 / spectral_gap."""
        return 1.0 / self.spectral_gap

    def tv_upper_bound(self, t: int) -> float:
        """
        Certified TV upper bound at time t:
        (1/2) · √(N-1) · (1 - gap)^t

        This is the main theorem (Theorem 1) from the formal development.
        """
        return 0.5 * sqrt(self.N - 1) * (1 - self.spectral_gap) ** t

    def mixing_time_bound(self, epsilon: float) -> int:
        """
        Certified upper bound on ε-mixing time:
        ⌈ log(√(N-1) / (2ε)) / (-log(1-gap)) ⌉

        Time complexity: O(1) (given gap)
        """
        gap = self.spectral_gap
        if gap <= 0 or gap >= 1:
            return self.N  # fallback
        num = log(sqrt(self.N - 1) / (2 * epsilon))
        den = -log(1 - gap)
        return ceil(num / den)

    def variance_decay_bound(self, t: int) -> float:
        """
        Bound on variance decay factor at time t:
        (1 - gap)^{2t}

        Var(A^t f) ≤ (1-gap)^{2t} · Var(f)
        """
        return (1 - self.spectral_gap) ** (2 * t)


class TVProfileComputer:
    """
    Computes the total variation distance profile d(t) = ||P^t(e,·) - π||_TV.

    Time complexity per step: O(N²) for matrix-vector multiplication
    Space complexity: O(N²) for storing P, O(N) for distribution
    """

    def __init__(self, P: np.ndarray, start_state: int = 0):
        self.P = P
        self.N = P.shape[0]
        self.start_state = start_state

    def compute_profile(self, max_steps: int) -> List[float]:
        """
        Compute TV distance from uniform at each time step.

        Returns list of TV distances [d(0), d(1), ..., d(max_steps)].
        """
        uniform = 1.0 / self.N
        dist = np.zeros(self.N)
        dist[self.start_state] = 1.0

        profile = []
        for t in range(max_steps + 1):
            tv = 0.5 * np.sum(np.abs(dist - uniform))
            profile.append(tv)
            if t < max_steps:
                dist = dist @ self.P
        return profile


class ObservableLowerBound:
    """
    Computes observable-based lower bounds on total variation distance.

    Given an observable f : Ω → ℝ with ||f||_∞ ≤ B, if
    |E_μ[f] - E_π[f]| ≥ a, then TV(μ, π) ≥ a / (2B).

    This is the formalization of Theorem 3 from the Lean development.
    """

    def __init__(self, f: np.ndarray, B: float):
        """
        Args:
            f: Observable values f(x) for each state x
            B: Bound on ||f||_∞
        """
        assert B > 0, "Bound B must be positive"
        assert np.all(np.abs(f) <= B + 1e-10), "|f| must be bounded by B"
        self.f = f
        self.B = B
        self.N = len(f)

    def lower_bound(self, dist: np.ndarray) -> float:
        """
        Compute the observable lower bound on TV(dist, uniform).

        Args:
            dist: Current distribution over states

        Returns:
            Lower bound on TV distance
        """
        uniform = 1.0 / self.N
        E_mu_f = np.dot(dist, self.f)
        E_pi_f = np.dot(np.full(self.N, uniform), self.f)
        separation = abs(E_mu_f - E_pi_f)
        return separation / (2 * self.B)


class CutoffDetector:
    """
    Detects cutoff phenomena from TV distance profiles.

    A family of chains exhibits cutoff if for every ε ∈ (0,1),
    t_mix(ε) / t_mix(1-ε) → 1 as n → ∞.

    Equivalently, the transition window t_mix(ε) - t_mix(1-ε) = o(t_mix(ε)).
    """

    @staticmethod
    def find_crossing_time(profile: List[float], threshold: float) -> int:
        """Find first time t where TV distance drops below threshold."""
        for t, tv in enumerate(profile):
            if tv < threshold:
                return t
        return len(profile) - 1

    @staticmethod
    def transition_window(profile: List[float],
                          upper: float = 0.9,
                          lower: float = 0.1) -> Tuple[int, int, int]:
        """
        Compute the transition window [t_upper, t_lower].

        Returns: (t_upper, t_lower, width)
        """
        t_upper = CutoffDetector.find_crossing_time(profile, upper)
        t_lower = CutoffDetector.find_crossing_time(profile, lower)
        return t_upper, t_lower, t_lower - t_upper

    @staticmethod
    def cutoff_ratio(profiles: dict) -> dict:
        """
        Compute cutoff diagnostic ratios for multiple n values.

        Returns dict mapping n to {
            'center': t_mix(0.5),
            'width': t_mix(0.1) - t_mix(0.9),
            'ratio': width / center,
            'center_over_n2logn': center / (n² log n)
        }
        """
        results = {}
        for n, profile in profiles.items():
            center = CutoffDetector.find_crossing_time(profile, 0.5)
            _, _, width = CutoffDetector.transition_window(profile)
            n2logn = n * n * log(n)
            results[n] = {
                'center': center,
                'width': width,
                'ratio': width / center if center > 0 else float('inf'),
                'center_over_n2logn': center / n2logn if n2logn > 0 else 0,
                'width_over_n2': width / (n * n)
            }
        return results


def build_standard_generators(n: int) -> List[Tuple[int, ...]]:
    """
    Build the standard generating set for S_n:
    adjacent transpositions + long cycle + inverse long cycle.
    """
    gens = []
    for i in range(n - 1):
        perm = list(range(n))
        perm[i], perm[i + 1] = perm[i + 1], perm[i]
        gens.append(tuple(perm))
    long_cycle = tuple((i + 1) % n for i in range(n))
    gens.append(long_cycle)
    inv_long_cycle = tuple((i - 1) % n for i in range(n))
    gens.append(inv_long_cycle)
    return gens


def fixed_point_observable(n: int) -> np.ndarray:
    """
    Build the fixed-point count observable for S_n.
    f(σ) = number of fixed points of σ.

    The expected value under uniform is 1 (for any n).
    Starting from identity, f(id) = n.
    """
    N = factorial(n)
    f = np.zeros(N)
    for idx in range(N):
        perm = lehmer_decode(idx, n)
        f[idx] = sum(1 for i in range(n) if perm[i] == i)
    return f


# Example usage
if __name__ == "__main__":
    print("Algorithms for Mixing Time Analysis")
    print("=" * 50)

    for n in [4, 5]:
        print(f"\n--- S_{n} ---")
        gens = build_standard_generators(n)
        walker = CayleyWalkGenerator(n, gens)
        P = walker.build_transition_matrix()

        analyzer = SpectralGapAnalyzer(P)
        print(f"Spectral gap: {analyzer.spectral_gap:.6f}")
        print(f"Relaxation time: {analyzer.relaxation_time:.4f}")

        for eps in [0.25, 0.1, 0.01]:
            bound = analyzer.mixing_time_bound(eps)
            print(f"  t_mix({eps}) upper bound: {bound}")

        profiler = TVProfileComputer(P)
        profile = profiler.compute_profile(200)

        detector = CutoffDetector()
        t_09, t_01, width = detector.transition_window(profile)
        print(f"Transition window: [{t_09}, {t_01}], width = {width}")

        # Observable lower bound using fixed points
        fp = fixed_point_observable(n)
        obs = ObservableLowerBound(fp - 1.0, n - 1)  # center around mean
        dist0 = np.zeros(factorial(n))
        dist0[0] = 1.0
        lb = obs.lower_bound(dist0)
        print(f"Observable lower bound at t=0: {lb:.6f}")

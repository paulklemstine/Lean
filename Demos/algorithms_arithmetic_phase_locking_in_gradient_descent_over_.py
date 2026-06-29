#!/usr/bin/env python3
"""
algorithms.py — Algorithms for Arithmetic Phase Locking Detection

Implements the modular phase locking detector and related algorithms
for analyzing gradient descent dynamics over finite fields.

Core algorithms:
    1. ModularPhaseLockingDetector: Detect phase locking for 1D affine maps
    2. MultiDimAffineLockingDetector: Detect phase locking for nD affine maps
    3. SpectralTorsionAnalyzer: Analyze eigenvalue torsion properties
    4. OrbitAnalyzer: Compute orbit statistics over finite fields
"""

from __future__ import annotations

import math
from dataclasses import dataclass
from typing import Callable


def sieve_primes(bound: int) -> list[int]:
    """Sieve of Eratosthenes. Returns all primes up to bound."""
    if bound < 2:
        return []
    sieve = [True] * (bound + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, int(bound**0.5) + 1):
        if sieve[i]:
            for j in range(i * i, bound + 1, i):
                sieve[j] = False
    return [i for i in range(bound + 1) if sieve[i]]


@dataclass
class OrbitInfo:
    """Information about a single orbit in a discrete dynamical system."""
    preperiod: int      # Steps before entering the cycle (mu)
    period: int         # Length of the cycle (lambda)
    tail: list[int]     # Pre-periodic part of the orbit
    cycle: list[int]    # One full period of the cycle

    @property
    def total_length(self) -> int:
        return self.preperiod + self.period


@dataclass
class LockingReport:
    """Report from the modular phase locking detector."""
    a: int
    b: int
    is_spectrally_torsion: bool
    torsion_order: int | None
    geom_sum_vanishes: bool
    is_locked: bool
    lock_period: int | None
    prime_reports: dict[int, OrbitInfo]

    def locking_density(self, threshold: int) -> float:
        """Fraction of tested primes where period ≤ threshold."""
        if not self.prime_reports:
            return 0.0
        count = sum(1 for info in self.prime_reports.values()
                    if info.period <= threshold)
        return count / len(self.prime_reports)


def compute_orbit_1d(a: int, b: int, x0: int, p: int,
                     max_steps: int | None = None) -> OrbitInfo:
    """
    Compute the orbit of x0 under T(y) = a*y + b (mod p).

    Args:
        a: Multiplier
        b: Additive constant
        x0: Initial point
        p: Prime modulus
        max_steps: Maximum steps (default: p+1)

    Returns:
        OrbitInfo with preperiod, period, tail, and cycle.
    """
    if max_steps is None:
        max_steps = p + 1

    visited: dict[int, int] = {}
    trajectory: list[int] = []
    x = x0 % p

    for t in range(max_steps):
        if x in visited:
            mu = visited[x]
            period = t - mu
            tail = trajectory[:mu]
            cycle = trajectory[mu:]
            return OrbitInfo(preperiod=mu, period=period,
                             tail=tail, cycle=cycle)
        visited[x] = t
        trajectory.append(x)
        x = (a * x + b) % p

    # Fallback (should not happen for p prime with max_steps > p)
    return OrbitInfo(preperiod=len(trajectory), period=0,
                     tail=trajectory, cycle=[])


def compute_orbit_nd(matrix_mod: Callable[[tuple[int, ...]], tuple[int, ...]],
                     x0: tuple[int, ...], p: int,
                     max_steps: int | None = None) -> OrbitInfo:
    """
    Compute the orbit of x0 under an n-dimensional map mod p.

    Args:
        matrix_mod: Function computing T(x) mod p, taking and returning tuples
        x0: Initial point as tuple
        p: Prime modulus
        max_steps: Maximum steps

    Returns:
        OrbitInfo (tail and cycle contain hash indices, not full states)
    """
    if max_steps is None:
        max_steps = p ** len(x0) + 1

    visited: dict[tuple[int, ...], int] = {}
    x = tuple(c % p for c in x0)

    for t in range(max_steps):
        if x in visited:
            mu = visited[x]
            period = t - mu
            return OrbitInfo(preperiod=mu, period=period, tail=[], cycle=[])
        visited[x] = t
        x = matrix_mod(x)

    return OrbitInfo(preperiod=max_steps, period=0, tail=[], cycle=[])


def detect_integer_torsion(a: int) -> int | None:
    """
    Detect if a is a root of unity in Z.
    Over Z, the only roots of unity are {1, -1}.

    Returns the multiplicative order if torsion, None otherwise.
    """
    if a == 1:
        return 1
    elif a == -1:
        return 2
    return None


def geometric_sum(a: int, m: int) -> int:
    """Compute the geometric partial sum: sum_{k=0}^{m-1} a^k."""
    if a == 1:
        return m
    # Use the formula (a^m - 1) / (a - 1) only if exact
    numerator = a**m - 1
    denominator = a - 1
    if numerator % denominator == 0:
        return numerator // denominator
    # Fallback to direct computation
    return sum(a**k for k in range(m))


class ModularPhaseLockingDetector:
    """
    Detect and analyze modular phase locking for 1D affine maps.

    Given T(y) = a*y + b, determines:
    1. Whether spectral torsion holds (a is a root of unity in Z)
    2. Whether the geometric sum condition is satisfied
    3. Empirical orbit periods for primes up to a bound

    Theorem-backed guarantee: if is_locked is True, then for ALL primes,
    every orbit has period dividing lock_period (by spectral_torsion_modp_1d).
    """

    def __init__(self, a: int, b: int):
        self.a = a
        self.b = b

    def analyze(self, prime_bound: int = 1000,
                x0: int = 0) -> LockingReport:
        """
        Run the full phase locking analysis.

        Args:
            prime_bound: Test all primes up to this bound
            x0: Initial point for orbit computation

        Returns:
            LockingReport with full analysis results
        """
        # Step 1: Detect spectral torsion
        torsion_order = detect_integer_torsion(self.a)
        is_torsion = torsion_order is not None

        # Step 2: Check geometric sum condition
        geom_vanishes = False
        lock_period = None
        if is_torsion and torsion_order is not None:
            gs = geometric_sum(self.a, torsion_order)
            geom_vanishes = (gs * self.b == 0)
            if geom_vanishes:
                lock_period = torsion_order

        is_locked = is_torsion and geom_vanishes

        # Step 3: Empirical verification
        primes = sieve_primes(prime_bound)
        prime_reports: dict[int, OrbitInfo] = {}
        for p in primes:
            orbit = compute_orbit_1d(self.a, self.b, x0, p)
            prime_reports[p] = orbit

        # Step 4: Verify theorem prediction
        if is_locked and lock_period is not None:
            for p, info in prime_reports.items():
                if info.period > lock_period:
                    raise RuntimeError(
                        f"THEOREM VIOLATION: p={p}, period={info.period}, "
                        f"expected ≤ {lock_period}. "
                        f"This should never happen by spectral_torsion_modp_1d."
                    )

        return LockingReport(
            a=self.a, b=self.b,
            is_spectrally_torsion=is_torsion,
            torsion_order=torsion_order,
            geom_sum_vanishes=geom_vanishes,
            is_locked=is_locked,
            lock_period=lock_period,
            prime_reports=prime_reports
        )


class MultiDimAffineLockingDetector:
    """
    Detect phase locking for n-dimensional affine maps T(x) = Mx + b.

    Works with integer matrices represented as lists of lists.
    """

    def __init__(self, M: list[list[int]], b: list[int]):
        """
        Args:
            M: n×n integer matrix (list of rows)
            b: n-dimensional integer vector
        """
        self.M = M
        self.b = b
        self.n = len(b)
        assert len(M) == self.n
        assert all(len(row) == self.n for row in M)

    def _mat_mul(self, A: list[list[int]], B: list[list[int]]) -> list[list[int]]:
        """Multiply two integer matrices."""
        n = len(A)
        return [[sum(A[i][k] * B[k][j] for k in range(n))
                 for j in range(n)] for i in range(n)]

    def _mat_vec(self, A: list[list[int]], v: list[int]) -> list[int]:
        """Multiply matrix by vector."""
        return [sum(A[i][j] * v[j] for j in range(len(v)))
                for i in range(len(A))]

    def _mat_pow(self, A: list[list[int]], k: int) -> list[list[int]]:
        """Compute A^k by repeated squaring."""
        n = len(A)
        result = [[1 if i == j else 0 for j in range(n)] for i in range(n)]
        base = [row[:] for row in A]
        while k > 0:
            if k % 2 == 1:
                result = self._mat_mul(result, base)
            base = self._mat_mul(base, base)
            k //= 2
        return result

    def _is_identity(self, A: list[list[int]]) -> bool:
        """Check if A is the identity matrix."""
        n = len(A)
        return all(A[i][j] == (1 if i == j else 0)
                   for i in range(n) for j in range(n))

    def find_torsion_order(self, max_order: int = 100) -> int | None:
        """Find the smallest m > 0 with M^m = I, or None."""
        for m in range(1, max_order + 1):
            if self._is_identity(self._mat_pow(self.M, m)):
                return m
        return None

    def check_geom_sum(self, m: int) -> list[int]:
        """Compute sum_{k=0}^{m-1} M^k * b."""
        result = [0] * self.n
        for k in range(m):
            Mk_b = self._mat_vec(self._mat_pow(self.M, k), self.b)
            result = [result[i] + Mk_b[i] for i in range(self.n)]
        return result

    def analyze(self, prime_bound: int = 100,
                x0: tuple[int, ...] | None = None) -> dict:
        """Run full analysis."""
        if x0 is None:
            x0 = tuple(0 for _ in range(self.n))

        torsion_order = self.find_torsion_order()
        geom_sum = None
        geom_vanishes = False

        if torsion_order is not None:
            geom_sum = self.check_geom_sum(torsion_order)
            geom_vanishes = all(v == 0 for v in geom_sum)

        is_locked = torsion_order is not None and geom_vanishes

        # Test modulo primes
        primes = sieve_primes(prime_bound)
        periods: dict[int, int] = {}

        for p in primes:
            M_mod = self.M
            b_mod = self.b

            def make_map(p_local: int) -> Callable:
                def f(x: tuple[int, ...]) -> tuple[int, ...]:
                    result = self._mat_vec(M_mod, list(x))
                    return tuple((result[i] + b_mod[i]) % p_local
                                 for i in range(self.n))
                return f

            orbit = compute_orbit_nd(make_map(p), x0, p,
                                     max_steps=min(p**self.n, 10000) + 1)
            periods[p] = orbit.period

        return {
            "torsion_order": torsion_order,
            "geom_sum": geom_sum,
            "geom_vanishes": geom_vanishes,
            "is_locked": is_locked,
            "lock_period": torsion_order if is_locked else None,
            "periods": periods,
        }


class OrbitAnalyzer:
    """Analyze orbit statistics across primes."""

    @staticmethod
    def period_statistics(periods: dict[int, int]) -> dict:
        """Compute statistics on a dictionary of {prime: period}."""
        vals = list(periods.values())
        if not vals:
            return {}
        return {
            "min": min(vals),
            "max": max(vals),
            "mean": sum(vals) / len(vals),
            "median": sorted(vals)[len(vals) // 2],
            "distinct_count": len(set(vals)),
            "total_primes": len(vals),
        }

    @staticmethod
    def locking_density(periods: dict[int, int], threshold: int) -> float:
        """Fraction of primes where period ≤ threshold."""
        if not periods:
            return 0.0
        return sum(1 for p in periods.values() if p <= threshold) / len(periods)


# ──────────────────────────────────────────────────────────────
# Example usage
# ──────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=== 1D Modular Phase Locking Detector ===\n")

    # Example 1: Locked system
    detector = ModularPhaseLockingDetector(a=-1, b=4)
    report = detector.analyze(prime_bound=500)
    print(f"Map: T(y) = {report.a}*y + {report.b}")
    print(f"Spectrally torsion: {report.is_spectrally_torsion} "
          f"(order {report.torsion_order})")
    print(f"Geometric sum vanishes: {report.geom_sum_vanishes}")
    print(f"Phase locked: {report.is_locked} (period {report.lock_period})")
    print(f"Locking density (≤2): {report.locking_density(2):.4f}")
    print(f"Locking density (≤5): {report.locking_density(5):.4f}")

    # Example 2: Unlocked system
    print()
    detector2 = ModularPhaseLockingDetector(a=2, b=1)
    report2 = detector2.analyze(prime_bound=500)
    print(f"Map: T(y) = {report2.a}*y + {report2.b}")
    print(f"Spectrally torsion: {report2.is_spectrally_torsion}")
    print(f"Phase locked: {report2.is_locked}")
    stats = OrbitAnalyzer.period_statistics(
        {p: info.period for p, info in report2.prime_reports.items()})
    stats_dict = {k: v for k, v in stats.items() if k != "total_primes"}
    print(f"Period stats: { {k: (f'{v:.1f}' if isinstance(v, float) else v) for k, v in stats_dict.items()} }")
    print(f"Locking density (≤2): {report2.locking_density(2):.4f}")

    # Example 3: 2D locked system
    print("\n=== 2D Modular Phase Locking Detector ===\n")
    detector3 = MultiDimAffineLockingDetector(
        M=[[-1, 0], [0, -1]],
        b=[2, 4]
    )
    result = detector3.analyze(prime_bound=100)
    print(f"Matrix M = -I, b = (2, 4)")
    print(f"Torsion order: {result['torsion_order']}")
    print(f"Geometric sum: {result['geom_sum']}")
    print(f"Phase locked: {result['is_locked']} (period {result['lock_period']})")
    print(f"Sample periods: {dict(list(result['periods'].items())[:10])}")

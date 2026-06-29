"""
Algorithms for Torsion Persistence Spectrum computation and analysis.

Implements the core algorithms from the research paper:
1. TPS computation for persistence modules over ℤ/mℤ
2. Primewise bounded persistence checking
3. Degeneracy verification
4. Systematic counterexample search
"""

import math
from typing import List, Dict, Tuple, Optional, Set
from dataclasses import dataclass


def sieve_primes(n: int) -> List[int]:
    """Sieve of Eratosthenes for primes up to n.

    Time: O(n log log n), Space: O(n)
    """
    if n < 2:
        return []
    is_prime = [True] * (n + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(n**0.5) + 1):
        if is_prime[i]:
            for j in range(i * i, n + 1, i):
                is_prime[j] = False
    return [i for i in range(2, n + 1) if is_prime[i]]


def prime_factors(n: int) -> Set[int]:
    """Return the set of prime factors of n.

    Time: O(√n)
    """
    factors = set()
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors.add(d)
            n //= d
        d += 1
    if n > 1:
        factors.add(n)
    return factors


@dataclass
class TPSResult:
    """Result of TPS computation."""
    group_order: int
    module_length: int
    endomorphisms: List[int]
    tps_by_prime: Dict[int, int]
    total_width: int
    is_degenerate: bool
    is_bounded: Optional[bool] = None
    bound: Optional[int] = None


class PersistenceAnalyzer:
    """Analyzer for torsion persistence spectra of endomorphism modules over ℤ/mℤ.

    The persistence module is defined by a sequence of multiplication-by-r_i
    endomorphisms on ℤ/mℤ.

    Attributes:
        m: Group order (modulus)
        endos: List of multipliers defining the endomorphisms
    """

    def __init__(self, m: int, endomorphisms: List[int]):
        """Initialize with group order m and list of multiplier endomorphisms.

        Args:
            m: modulus for ℤ/mℤ (must be positive)
            endomorphisms: list [r_0, ..., r_{n-1}] of multipliers

        Example:
            >>> pa = PersistenceAnalyzer(6, [2, 3])
            >>> pa.compute_tps(2)
            1
        """
        assert m > 0, "Group order must be positive"
        self.m = m
        self.endos = endomorphisms
        self.n = len(endomorphisms)
        self._primes = sieve_primes(m)
        self._prime_factors = prime_factors(m)

    def compose(self, k: int, a: int) -> int:
        """Compute compose(k)(a) = φ_{k-1} ∘ ... ∘ φ_0 (a).

        Time: O(min(k, n))

        Args:
            k: composition depth
            a: element of ℤ/mℤ

        Returns:
            The image of a under the k-fold composition
        """
        result = a % self.m
        for i in range(min(k, self.n)):
            result = (self.endos[i] * result) % self.m
        return result

    def is_p_torsion(self, p: int, a: int) -> bool:
        """Check if a is p-primary torsion in ℤ/mℤ.

        An element a is p-torsion if a ≠ 0 and p^k · a ≡ 0 (mod m) for some k ≥ 1.

        Time: O(log_p(m))
        """
        a = a % self.m
        if a == 0:
            return False
        pk = p
        while pk <= self.m * self.m:  # generous bound
            if (pk * a) % self.m == 0:
                return True
            pk *= p
        return False

    def additive_order(self, a: int) -> int:
        """Compute the additive order of a in ℤ/mℤ.

        Time: O(m) worst case, O(order(a)) expected
        """
        a = a % self.m
        if a == 0:
            return 1
        return self.m // math.gcd(a, self.m)

    def compute_tps(self, p: int) -> int:
        """Compute TPS_M(p): the torsion persistence spectrum at prime p.

        Algorithm: For each p-torsion element a, track how many steps it
        survives through the filtration.

        Time: O(m · n)

        Args:
            p: a prime number

        Returns:
            Maximum persistence length of p-torsion elements
        """
        max_persistence = 0
        for a in range(1, self.m):
            if not self.is_p_torsion(p, a):
                continue
            # Track survival through filtration
            x = a
            steps = 0
            for i in range(self.n):
                x = (self.endos[i] * x) % self.m
                if x == 0:
                    break
                steps = i + 1
            max_persistence = max(max_persistence, steps)
        return max_persistence

    def compute_all_tps(self) -> Dict[int, int]:
        """Compute TPS at all relevant primes.

        Only primes dividing m can have nonzero TPS.

        Time: O(ω(m) · m · n) where ω(m) = number of prime factors
        """
        return {p: self.compute_tps(p) for p in self._prime_factors}

    def total_torsion_width(self) -> int:
        """Compute the total torsion width = max TPS over all primes.

        Time: O(ω(m) · m · n)
        """
        tps_values = self.compute_all_tps()
        return max(tps_values.values()) if tps_values else 0

    def check_degeneracy(self) -> bool:
        """Check if the module is degenerate.

        Degeneracy: compose(k)(a) = 0 for k ≥ 1 implies compose(1)(a) = 0.

        Time: O(m · n)
        """
        for a in range(self.m):
            c1 = self.compose(1, a)
            if c1 != 0:
                # Check if any later composition kills a
                for k in range(2, self.n + 1):
                    if self.compose(k, a) == 0:
                        return False
        return True

    def check_primewise_bounded(self, B: int) -> bool:
        """Check if TPS(p) ≤ B for all primes p.

        Time: O(ω(m) · m · n)
        """
        for p in self._prime_factors:
            if self.compute_tps(p) > B:
                return False
        return True

    def full_analysis(self, bound: Optional[int] = None) -> TPSResult:
        """Perform complete TPS analysis.

        Returns a TPSResult with all computed invariants.

        Args:
            bound: optional bound B to check primewise boundedness
        """
        tps = self.compute_all_tps()
        width = max(tps.values()) if tps else 0
        degen = self.check_degeneracy()

        result = TPSResult(
            group_order=self.m,
            module_length=self.n,
            endomorphisms=self.endos,
            tps_by_prime=tps,
            total_width=width,
            is_degenerate=degen,
        )

        if bound is not None:
            result.bound = bound
            result.is_bounded = all(v <= bound for v in tps.values())

        return result

    def torsion_entropy(self, p: int) -> float:
        """Compute torsion entropy H_p = log₂(|p-torsion subgroup|).

        Time: O(m · log_p(m))
        """
        count = 0
        for a in range(self.m):
            pk = 1
            while pk <= self.m:
                if (pk * a) % self.m == 0:
                    count += 1
                    break
                pk *= p
        return math.log2(count) if count > 1 else 0.0


def search_counterexamples(
    max_m: int = 50,
    max_n: int = 3,
    bound: int = 1,
    verbose: bool = True,
) -> List[TPSResult]:
    """Systematically search for counterexamples to the formality conjecture.

    A counterexample is a persistence module that:
    - Has primewise bounded TPS (by the given bound)
    - Is NOT degenerate

    Args:
        max_m: maximum group order to test
        max_n: maximum module length to test
        bound: TPS bound to test
        verbose: print progress

    Returns:
        List of counterexamples found (empty if conjecture holds in range)

    Time: O(max_m · max_m^max_n · ω(max_m) · max_m · max_n)
    """
    counterexamples = []

    for m in range(2, max_m + 1):
        if verbose and m % 10 == 0:
            print(f"  Checking m = {m}...")

        # For efficiency, only test small endomorphism spaces
        for n in range(1, max_n + 1):
            # Generate endomorphism tuples
            import itertools
            for endos in itertools.product(range(m), repeat=n):
                pa = PersistenceAnalyzer(m, list(endos))
                if pa.check_primewise_bounded(bound) and not pa.check_degeneracy():
                    result = pa.full_analysis(bound)
                    counterexamples.append(result)
                    if verbose:
                        print(f"  COUNTEREXAMPLE: ℤ/{m} with endos {endos}")

    return counterexamples


def compute_minimal_bound(m: int, n: int) -> int:
    """Find the minimal B such that primewise-bounded-by-B implies degenerate.

    For a given group order m and module length n, find the smallest B
    such that every module over ℤ/mℤ of length n with TPS ≤ B is degenerate.

    Time: O(m^n · ω(m) · m · n · B_max)
    """
    import itertools

    for B in range(n + 1):
        all_ok = True
        for endos in itertools.product(range(m), repeat=n):
            pa = PersistenceAnalyzer(m, list(endos))
            if pa.check_primewise_bounded(B) and not pa.check_degeneracy():
                all_ok = False
                break
        if all_ok:
            return B
    return n  # fallback


if __name__ == "__main__":
    # Example usage
    print("=== Torsion Persistence Spectrum Analysis ===\n")

    # Example 1: ℤ/12 with ×2, ×3
    pa = PersistenceAnalyzer(12, [2, 3])
    result = pa.full_analysis(bound=1)
    print(f"ℤ/12 with ×2, ×3:")
    print(f"  TPS by prime: {result.tps_by_prime}")
    print(f"  Total width: {result.total_width}")
    print(f"  Degenerate: {result.is_degenerate}")
    print(f"  Bounded by 1: {result.is_bounded}")

    # Example 2: Search for counterexamples
    print(f"\nSearching for counterexamples (m ≤ 30, n ≤ 2, B = 1)...")
    cex = search_counterexamples(max_m=30, max_n=2, bound=1, verbose=False)
    print(f"  Found {len(cex)} counterexamples")
    if cex:
        for c in cex[:5]:
            print(f"    ℤ/{c.group_order} with {c.endomorphisms}: TPS = {c.tps_by_prime}")

    # Example 3: Minimal bounds
    print(f"\nMinimal bounds B(m, n) for conjecture:")
    for m in [2, 3, 4, 6, 10, 12]:
        for n_val in [1, 2, 3]:
            B = compute_minimal_bound(m, n_val)
            print(f"  B({m}, {n_val}) = {B}")

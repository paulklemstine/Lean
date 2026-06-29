#!/usr/bin/env python3
"""
Algorithms for Functorial Entropy
==================================

Efficient computation of functorial entropy and related quantities.
Includes:
- O(n) fiber analysis
- O(n log n) entropy computation
- Pipeline entropy analysis
- Landauer cost computation
"""

import math
from collections import Counter
from typing import Callable, Dict, List, Optional, Tuple


class FiberAnalyzer:
    """Analyzes the fiber structure of a function on a finite domain.

    Given f: domain → codomain, computes fiber cardinalities,
    functorial entropy, Landauer cost, and injectivity/surjectivity.

    Time complexity: O(|domain|) for construction, O(1) for queries.
    Space complexity: O(|domain|).
    """

    def __init__(self, f: Callable[[int], int], domain: List[int]):
        """
        Args:
            f: The function to analyze
            domain: The finite domain (list of elements)

        Example:
            >>> analyzer = FiberAnalyzer(lambda x: x % 3, list(range(9)))
            >>> analyzer.entropy()
            1.0986...  # = log(3)
        """
        self.f = f
        self.domain = domain
        self.n = len(domain)

        # Compute image and fiber structure in O(n)
        self._images: Dict[int, int] = {}
        self._fiber_sizes: Counter = Counter()
        for x in domain:
            y = f(x)
            self._images[x] = y
            self._fiber_sizes[y] += 1

        # Cache fiber card for each domain element
        self._fiber_card: Dict[int, int] = {}
        for x in domain:
            self._fiber_card[x] = self._fiber_sizes[self._images[x]]

    def fiber_card(self, a: int) -> int:
        """Return |{x : f(x) = f(a)}|.

        Time: O(1)
        """
        return self._fiber_card[a]

    def entropy(self) -> float:
        """Compute H(f) = (1/|α|) Σ_a log(fiberCard(f, a)).

        Time: O(n)

        Returns:
            The functorial entropy, a non-negative real number.
            Zero iff f is injective on domain.
        """
        if self.n == 0:
            return 0.0
        total = sum(math.log(self._fiber_card[a]) for a in self.domain)
        return total / self.n

    def landauer_cost(self) -> float:
        """Compute total Landauer cost = |α| · H(f).

        Time: O(n)

        Returns:
            Total thermodynamic cost in natural units (k_B T = 1).
        """
        return sum(math.log(self._fiber_card[a]) for a in self.domain)

    def is_injective(self) -> bool:
        """Check if f is injective. Time: O(1) after construction."""
        return all(s == 1 for s in self._fiber_sizes.values())

    def is_surjective(self, codomain: List[int]) -> bool:
        """Check if f is surjective onto codomain. Time: O(|codomain|)."""
        return all(c in self._fiber_sizes for c in codomain)

    def fiber_histogram(self) -> Dict[int, int]:
        """Return histogram of fiber sizes.

        Returns dict mapping fiber_size → count_of_fibers_with_that_size.
        """
        size_counts: Counter = Counter()
        for size in self._fiber_sizes.values():
            size_counts[size] += 1
        return dict(size_counts)

    def summary(self) -> str:
        """Human-readable summary of the fiber analysis."""
        lines = [
            f"Domain size: {self.n}",
            f"Image size: {len(self._fiber_sizes)}",
            f"Injective: {self.is_injective()}",
            f"Entropy H(f): {self.entropy():.6f}",
            f"Landauer cost: {self.landauer_cost():.6f}",
            f"Fiber histogram: {self.fiber_histogram()}",
        ]
        return "\n".join(lines)


class PipelineAnalyzer:
    """Analyzes entropy through a composition pipeline f₁ ∘ f₂ ∘ ··· ∘ fₖ.

    Verifies the Data Processing Inequality: entropy is monotone
    through the pipeline.

    Time: O(k · n) where k = number of stages, n = domain size.
    """

    def __init__(self, domain: List[int]):
        self.domain = domain
        self.stages: List[Tuple[str, Callable]] = []
        self.entropies: List[float] = []
        self._current_func: Optional[Callable] = None

    def add_stage(self, name: str, f: Callable[[int], int]) -> float:
        """Add a stage to the pipeline and return cumulative entropy.

        Args:
            name: Human-readable name for this stage
            f: The function for this stage

        Returns:
            Entropy of the composition up to this stage
        """
        if self._current_func is None:
            self._current_func = f
        else:
            prev = self._current_func
            self._current_func = lambda x, p=prev, g=f: g(p(x))

        analyzer = FiberAnalyzer(self._current_func, self.domain)
        entropy = analyzer.entropy()
        self.stages.append((name, f))
        self.entropies.append(entropy)
        return entropy

    def verify_monotonicity(self) -> bool:
        """Verify Data Processing Inequality holds."""
        for i in range(1, len(self.entropies)):
            if self.entropies[i] < self.entropies[i-1] - 1e-10:
                return False
        return True

    def report(self) -> str:
        """Generate a report of the pipeline analysis."""
        lines = ["Pipeline Entropy Analysis", "=" * 40]
        for i, ((name, _), H) in enumerate(zip(self.stages, self.entropies)):
            lines.append(f"  Stage {i+1} ({name}): H = {H:.6f}")
        lines.append(f"  Monotone: {self.verify_monotonicity()}")
        return "\n".join(lines)


def superadditivity_test(n: int, m: int, k: int,
                         max_tests: int = 10000) -> Tuple[bool, int, float]:
    """Test superadditivity conjecture for random surjections.

    Tests whether H(g∘f) ≥ H(f) + H(g) for surjective f: Fin n → Fin m
    and arbitrary g: Fin m → Fin k.

    Args:
        n, m, k: Domain sizes
        max_tests: Maximum number of random tests

    Returns:
        (conjecture_holds, num_tests, min_gap)
    """
    import random

    min_gap = float('inf')
    tests = 0

    for _ in range(max_tests):
        # Generate random surjection f: [n] → [m]
        f_map = [random.randint(0, m-1) for _ in range(n)]
        if len(set(f_map)) < m:
            continue  # Not surjective

        # Generate random g: [m] → [k]
        g_map = [random.randint(0, k-1) for _ in range(m)]

        domain_n = list(range(n))
        domain_m = list(range(m))

        f_func = lambda x, m=f_map: m[x]
        g_func = lambda x, m=g_map: m[x]
        gf_func = lambda x, f=f_func, g=g_func: g(f(x))

        H_f = FiberAnalyzer(f_func, domain_n).entropy()
        H_g = FiberAnalyzer(g_func, domain_m).entropy()
        H_gf = FiberAnalyzer(gf_func, domain_n).entropy()

        gap = H_gf - (H_f + H_g)
        min_gap = min(min_gap, gap)
        tests += 1

        if gap < -1e-10:
            return (False, tests, gap)

    return (True, tests, min_gap)


# ============================================================
# Example usage
# ============================================================
if __name__ == "__main__":
    # Basic analysis
    print("=== Fiber Analysis ===")
    analyzer = FiberAnalyzer(lambda x: x % 3, list(range(9)))
    print(analyzer.summary())

    print("\n=== Pipeline Analysis ===")
    pipeline = PipelineAnalyzer(list(range(24)))
    pipeline.add_stage("mod 12", lambda x: x % 12)
    pipeline.add_stage("mod 6", lambda x: x % 6)
    pipeline.add_stage("mod 3", lambda x: x % 3)
    pipeline.add_stage("mod 2", lambda x: x % 2)
    print(pipeline.report())

    print("\n=== Superadditivity Test ===")
    holds, tests, gap = superadditivity_test(6, 4, 3, max_tests=5000)
    print(f"Tested {tests} pairs")
    print(f"Conjecture holds: {holds}")
    print(f"Minimum gap: {gap:.6f}")

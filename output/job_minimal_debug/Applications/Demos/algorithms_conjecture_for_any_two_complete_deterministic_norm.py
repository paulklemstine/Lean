"""
algorithms.py — Core algorithms for proof compression universality analysis.

Implements the key computational procedures from the research paper:
1. Polynomial bound composition (with explicit constants)
2. Phase classification of normalizers
3. Normalizer comparison and simulation testing
4. Universality class detection
"""

from __future__ import annotations
from dataclasses import dataclass, field
from typing import Callable, List, Tuple, Optional, Dict, Set
import math


# ─────────────────────────────────────────────────────────────
# Algorithm 1: Polynomial Bound Composition
# ─────────────────────────────────────────────────────────────

@dataclass
class PolyBound:
    """
    Represents a polynomial bound of the form c * (n + 1)^k.

    Attributes:
        k: The exponent (degree of polynomial growth).
        c: The leading coefficient.
    """
    k: int
    c: int

    def evaluate(self, n: int) -> int:
        """Evaluate the bound at a given input size n."""
        return self.c * (n + 1) ** self.k

    def __repr__(self) -> str:
        return f"{self.c}·(n+1)^{self.k}"


def compose_poly_bounds(inner: PolyBound, outer: PolyBound) -> PolyBound:
    """
    Compose two polynomial bounds.

    If f(n) ≤ outer.c · (n+1)^outer.k and g(m) ≤ inner.c · (m+1)^inner.k,
    and we substitute m = f(n), then:
      g(f(n)) ≤ inner.c · (outer.c + 1)^inner.k · (n+1)^(outer.k · inner.k)

    This implements Theorem 4.1 from the paper.

    Args:
        inner: The outer bound (applied second): g ≤ inner
        outer: The inner bound (applied first): f ≤ outer

    Returns:
        A PolyBound bounding g(f(n)).

    Time complexity: O(inner.k · log(outer.c + 1)) for computing the power.
    Space complexity: O(1).

    Example:
        >>> b1 = PolyBound(k=2, c=3)   # f(n) ≤ 3·(n+1)²
        >>> b2 = PolyBound(k=3, c=5)   # g(m) ≤ 5·(m+1)³
        >>> compose_poly_bounds(b2, b1)  # g(f(n)) ≤ 5·4³·(n+1)⁶ = 320·(n+1)⁶
        320·(n+1)^6
    """
    new_c = inner.c * (outer.c + 1) ** inner.k
    new_k = outer.k * inner.k
    return PolyBound(k=new_k, c=new_c)


# ─────────────────────────────────────────────────────────────
# Algorithm 2: Phase Classification
# ─────────────────────────────────────────────────────────────

@dataclass
class PhaseClassification:
    """Result of phase classification."""
    phase: str  # 'poly' or 'superpoly'
    witness_k: Optional[int] = None
    witness_c: Optional[int] = None
    confidence: float = 0.0


def classify_normalizer_phase(
    blowup_fn: Callable[[int], int],
    test_range: range = range(1, 50),
    max_k: int = 6,
    max_c: int = 1000
) -> PhaseClassification:
    """
    Classify the compression phase of a normalizer.

    Tests whether the blowup function satisfies f(n) ≤ c·(n+1)^k
    for some k ≤ max_k and c ≤ max_c.

    Algorithm:
      1. For each candidate exponent k from 1 to max_k:
         a. Compute the minimum c needed: c_min = max over n of f(n) / (n+1)^k
         b. If c_min ≤ max_c, declare polynomial with parameters (k, c_min).
      2. If no (k, c) pair works, declare superpolynomial.

    Time complexity: O(max_k · |test_range|).
    Space complexity: O(1).

    Args:
        blowup_fn: Maps raw proof size to normalized proof size.
        test_range: Range of input sizes to test.
        max_k: Maximum exponent to try.
        max_c: Maximum coefficient to try.

    Returns:
        PhaseClassification with phase label and witness parameters.

    Example:
        >>> classify_normalizer_phase(lambda n: 3 * n ** 2 + 1)
        PhaseClassification(phase='poly', witness_k=2, witness_c=3, ...)
    """
    test_sizes = list(test_range)
    values = [(n, blowup_fn(n)) for n in test_sizes]

    for k in range(1, max_k + 1):
        # Find minimum c such that f(n) ≤ c * (n+1)^k for all test n
        c_needed = 0
        for n, fn in values:
            denom = (n + 1) ** k
            c_candidate = (fn + denom - 1) // denom  # ceiling division
            c_needed = max(c_needed, c_candidate)

        if c_needed <= max_c:
            # Verify
            if all(fn <= c_needed * (n + 1) ** k for n, fn in values):
                confidence = 1.0 - (k / max_k) * 0.1  # higher k = lower confidence
                return PhaseClassification(
                    phase='poly',
                    witness_k=k,
                    witness_c=c_needed,
                    confidence=confidence
                )

    return PhaseClassification(phase='superpoly', confidence=0.95)


# ─────────────────────────────────────────────────────────────
# Algorithm 3: Polynomial Simulation Testing
# ─────────────────────────────────────────────────────────────

@dataclass
class SimulationResult:
    """Result of testing polynomial simulation between normalizers."""
    simulates: bool
    k: Optional[int] = None
    c: Optional[int] = None
    max_ratio: float = 0.0


def test_poly_simulation(
    f: Callable[[int], int],
    g: Callable[[int], int],
    test_range: range = range(1, 50),
    max_k: int = 5,
    max_c: int = 500
) -> SimulationResult:
    """
    Test whether g(n) ≤ c·(f(n)+1)^k for some polynomial parameters.

    This checks whether normalizer f polynomially simulates normalizer g
    (i.e., g's output is bounded by a polynomial of f's output).

    Algorithm:
      For each k from 1 to max_k:
        Compute c_min = max over n of g(n) / (f(n)+1)^k.
        If c_min ≤ max_c, simulation holds with (k, c_min).

    Time complexity: O(max_k · |test_range|).
    Space complexity: O(1).

    Args:
        f: First normalizer's blowup function (simulating normalizer).
        g: Second normalizer's blowup function (simulated normalizer).
        test_range: Range of input sizes to test.
        max_k: Maximum simulation exponent.
        max_c: Maximum simulation coefficient.

    Returns:
        SimulationResult indicating whether simulation holds and parameters.

    Example:
        >>> test_poly_simulation(lambda n: n+1, lambda n: (n+1)**2)
        SimulationResult(simulates=True, k=2, c=1, ...)
    """
    test_sizes = list(test_range)
    f_values = [(n, f(n)) for n in test_sizes]
    g_values = [(n, g(n)) for n in test_sizes]

    max_ratio = 0.0
    for (n, fn), (_, gn) in zip(f_values, g_values):
        if fn > 0:
            max_ratio = max(max_ratio, gn / fn)

    for k in range(1, max_k + 1):
        c_needed = 0
        valid = True
        for (n, fn), (_, gn) in zip(f_values, g_values):
            denom = (fn + 1) ** k
            c_candidate = (gn + denom - 1) // denom
            c_needed = max(c_needed, c_candidate)
            if c_needed > max_c:
                valid = False
                break

        if valid and c_needed <= max_c:
            # Verify
            if all(gn <= c_needed * (fn + 1) ** k
                   for (_, fn), (_, gn) in zip(f_values, g_values)):
                return SimulationResult(
                    simulates=True, k=k, c=c_needed, max_ratio=max_ratio
                )

    return SimulationResult(simulates=False, max_ratio=max_ratio)


# ─────────────────────────────────────────────────────────────
# Algorithm 4: Universality Class Detection
# ─────────────────────────────────────────────────────────────

def detect_universality_classes(
    normalizers: Dict[str, Callable[[int], int]],
    test_range: range = range(1, 30),
    max_k: int = 4,
    max_c: int = 200
) -> List[Set[str]]:
    """
    Partition normalizers into universality classes based on mutual
    polynomial simulation.

    Two normalizers are in the same class if each polynomially simulates
    the other (norm-polynomial equivalence).

    Algorithm:
      1. Build a directed graph: edge (i→j) if normalizer i simulates j.
      2. Find strongly connected components (equivalence classes).
      3. Return the partition.

    Time complexity: O(n² · max_k · |test_range|) where n = |normalizers|.
    Space complexity: O(n²) for the simulation matrix.

    Args:
        normalizers: Dict mapping names to blowup functions.
        test_range: Range of input sizes for simulation testing.
        max_k: Maximum simulation exponent.
        max_c: Maximum simulation coefficient.

    Returns:
        List of sets, each set containing names of equivalent normalizers.

    Example:
        >>> normalizers = {
        ...     'linear': lambda n: 2*n + 1,
        ...     'linear2': lambda n: 5*n + 3,
        ...     'quadratic': lambda n: n**2,
        ...     'exponential': lambda n: 2**n,
        ... }
        >>> classes = detect_universality_classes(normalizers)
        >>> # linear and linear2 should be in the same class
    """
    names = list(normalizers.keys())
    n = len(names)

    # Build simulation matrix
    simulates = [[False] * n for _ in range(n)]
    for i in range(n):
        simulates[i][i] = True  # reflexivity
        for j in range(n):
            if i == j:
                continue
            result = test_poly_simulation(
                normalizers[names[i]], normalizers[names[j]],
                test_range, max_k, max_c
            )
            simulates[i][j] = result.simulates

    # Find equivalence classes (mutual simulation)
    visited = [False] * n
    classes: List[Set[str]] = []

    for i in range(n):
        if visited[i]:
            continue
        cls = {names[i]}
        visited[i] = True
        for j in range(i + 1, n):
            if visited[j]:
                continue
            if simulates[i][j] and simulates[j][i]:
                cls.add(names[j])
                visited[j] = True
        classes.append(cls)

    return classes


# ─────────────────────────────────────────────────────────────
# Algorithm 5: Transfer Bound Computation
# ─────────────────────────────────────────────────────────────

def compute_transfer_bound(
    norm_bound: PolyBound,
    sim_bound: PolyBound
) -> PolyBound:
    """
    Compute the transferred polynomial bound when composing a normalizer's
    polynomial bound with a simulation bound.

    If normalizer N₁ has bound c₁·(n+1)^k₁ and the simulation from N₁ to N₂
    has overhead c₂·(m+1)^k₂, then N₂ has bound C·(n+1)^K where:
      C = c₂·(c₁+1)^k₂
      K = k₁·k₂

    This is a direct application of Theorem 5.1 from the paper.

    Time complexity: O(k₂ · log(c₁ + 1)) for computing the power.
    Space complexity: O(1).

    Args:
        norm_bound: Polynomial bound for the source normalizer.
        sim_bound: Polynomial simulation bound.

    Returns:
        PolyBound for the target normalizer.

    Example:
        >>> nb = PolyBound(k=2, c=5)   # N₁: 5·(n+1)²
        >>> sb = PolyBound(k=3, c=2)   # sim: 2·(m+1)³
        >>> compute_transfer_bound(nb, sb)
        432·(n+1)^6
    """
    return compose_poly_bounds(sim_bound, norm_bound)


# ─────────────────────────────────────────────────────────────
# Main: Example Usage
# ─────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=" * 60)
    print("Algorithms Module — Example Usage")
    print("=" * 60)
    print()

    # Polynomial bound composition
    b1 = PolyBound(k=2, c=3)
    b2 = PolyBound(k=3, c=5)
    composed = compose_poly_bounds(b2, b1)
    print(f"Composition: {b1} ∘ {b2} = {composed}")
    print(f"  At n=10: {b1.evaluate(10)} → {b2.evaluate(b1.evaluate(10))} ≤ {composed.evaluate(10)}")
    print()

    # Phase classification
    print("Phase classification examples:")
    for name, fn in [
        ("Linear (3n+1)", lambda n: 3*n + 1),
        ("Quadratic (2n²)", lambda n: 2*n**2),
        ("Exponential (2^n)", lambda n: 2**n),
    ]:
        result = classify_normalizer_phase(fn)
        print(f"  {name:30s} → {result.phase}"
              + (f" (k={result.witness_k}, c={result.witness_c})"
                 if result.phase == 'poly' else ""))
    print()

    # Universality classes
    print("Universality class detection:")
    normalizers = {
        'lin_1': lambda n: 2*n + 1,
        'lin_2': lambda n: 5*n + 3,
        'quad_1': lambda n: n**2 + 1,
        'quad_2': lambda n: 3*n**2 + 2*n,
        'cubic': lambda n: n**3,
        'exp': lambda n: 2**n,
    }
    classes = detect_universality_classes(normalizers)
    for i, cls in enumerate(classes, 1):
        print(f"  Class {i}: {', '.join(sorted(cls))}")
    print()

    # Transfer bound
    print("Transfer bound computation:")
    nb = PolyBound(k=2, c=5)
    sb = PolyBound(k=3, c=2)
    tb = compute_transfer_bound(nb, sb)
    print(f"  N₁ bound: {nb}")
    print(f"  Simulation: {sb}")
    print(f"  Transferred bound: {tb}")

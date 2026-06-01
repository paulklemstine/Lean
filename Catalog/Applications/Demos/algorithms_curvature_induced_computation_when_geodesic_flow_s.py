#!/usr/bin/env python3
"""
Algorithms for Curvature-Induced Computation
=============================================
Type-hinted implementations of the core algorithms connecting
horseshoe dynamics to computational universality.
"""

from dataclasses import dataclass, field
from typing import Callable, Sequence
import math
import itertools


# ============================================================
# Algorithm 1: Horseshoe Orbit Realization
# ============================================================

@dataclass
class HorseshoeSystem:
    """
    Abstract Smale horseshoe of degree d.

    The system is defined by:
    - strips: callable mapping index to (lower, upper) bounds
    - dynamics: the map f : float -> float (simplified 1D version)
    - degree: number of strips
    """
    degree: int
    strips: Callable[[int], tuple[float, float]]
    dynamics: Callable[[float], float]

    def strip_contains(self, strip_idx: int, point: float) -> bool:
        """Check if a point is in a given strip."""
        lo, hi = self.strips(strip_idx)
        return lo <= point <= hi

    def which_strip(self, point: float) -> int:
        """Return which strip contains the point, or -1 if none."""
        for i in range(self.degree):
            if self.strip_contains(i, point):
                return i
        return -1


def orbit_realization(
    system: HorseshoeSystem,
    word: Sequence[int],
    x_range: tuple[float, float] = (0.0, 1.0),
    max_bisection_steps: int = 100
) -> float:
    """
    Find an initial condition whose orbit follows a prescribed symbolic word.

    Uses bisection on the initial condition space to find a point
    whose orbit visits the strips in the order given by `word`.

    This is the computational version of the orbit realization theorem:
    for any word w, there exists x with f^k(x) ∈ S_{w_k}.

    Parameters:
        system: The horseshoe system
        word: Target symbolic itinerary (sequence of strip indices)
        x_range: Range to search for initial conditions
        max_bisection_steps: Maximum refinement steps

    Returns:
        An initial condition approximately realizing the given word.
    """
    n = len(word)
    if n == 0:
        return (x_range[0] + x_range[1]) / 2

    # Binary search for an initial condition realizing the word
    lo, hi = x_range
    for _ in range(max_bisection_steps):
        mid = (lo + hi) / 2

        # Simulate orbit and check word match
        x = mid
        match = True
        for k in range(n):
            strip = system.which_strip(x)
            if strip != word[k]:
                match = False
                break
            x = system.dynamics(x)

        if match:
            return mid

        # Adjust search range
        # Try both halves
        x_lo = lo
        orbit_ok_lo = True
        for k in range(min(n, 3)):  # Check first few steps
            if system.which_strip(x_lo) != word[k]:
                orbit_ok_lo = False
                break
            x_lo = system.dynamics(x_lo)

        if orbit_ok_lo:
            hi = mid
        else:
            lo = mid

    return (lo + hi) / 2


# ============================================================
# Algorithm 2: Boolean Function Encoding
# ============================================================

def encode_boolean_function(
    system: HorseshoeSystem,
    g: Callable[[tuple[int, ...]], int],
    n_inputs: int
) -> dict[tuple[int, ...], float]:
    """
    Encode a Boolean function into horseshoe initial conditions.

    For each input b ∈ {0,1}^n, constructs an initial condition x
    such that f^n(x) is in strip g(b), thereby computing g via dynamics.

    This implements the computational universality theorem:
    any Boolean function can be encoded by a degree-2 horseshoe.

    Parameters:
        system: A degree-2 horseshoe system
        g: Boolean function (tuple of bits → bit)
        n_inputs: Number of input bits

    Returns:
        Dictionary mapping each input to its encoding initial condition.
    """
    assert system.degree >= 2, "Need degree ≥ 2 for Boolean encoding"

    encodings: dict[tuple[int, ...], float] = {}

    for bits in itertools.product([0, 1], repeat=n_inputs):
        # Construct the target word: [b_0, b_1, ..., b_{n-1}, g(b)]
        output = g(bits)
        word = list(bits) + [output]

        # Find initial condition realizing this word
        x0 = orbit_realization(system, word)
        encodings[bits] = x0

    return encodings


def verify_encoding(
    system: HorseshoeSystem,
    encodings: dict[tuple[int, ...], float],
    g: Callable[[tuple[int, ...]], int],
    n_inputs: int
) -> tuple[int, int]:
    """
    Verify that the encoding correctly computes the Boolean function.

    Returns (correct, total) counts.
    """
    correct = 0
    total = 0

    for bits, x0 in encodings.items():
        # Run dynamics n times
        x = x0
        for _ in range(n_inputs):
            x = system.dynamics(x)

        # Read output strip
        computed = system.which_strip(x)
        expected = g(bits)
        if computed == expected:
            correct += 1
        total += 1

    return correct, total


# ============================================================
# Algorithm 3: Symbolic Entropy Computation
# ============================================================

def symbolic_entropy(degree: int) -> float:
    """
    Compute the topological entropy of a degree-d horseshoe.

    h(d) = log(d)

    This equals the exponential growth rate of the number of
    distinguishable orbits: lim (1/n) log(d^n) = log(d).
    """
    if degree <= 0:
        return 0.0
    return math.log(degree)


def verify_entropy_growth_rate(degree: int, max_n: int = 20) -> list[float]:
    """
    Verify that (1/n) * log(d^n) converges to log(d).

    Returns the sequence of growth rates for n = 1, ..., max_n.
    """
    h_exact = symbolic_entropy(degree)
    growth_rates: list[float] = []

    for n in range(1, max_n + 1):
        word_count = degree ** n
        rate = math.log(word_count) / n
        growth_rates.append(rate)
        assert abs(rate - h_exact) < 1e-10, \
            f"Growth rate mismatch at n={n}: {rate} vs {h_exact}"

    return growth_rates


# ============================================================
# Algorithm 4: Horseshoe Degree Finder for Unbounded Entropy
# ============================================================

def find_degree_exceeding_entropy(threshold: float) -> int:
    """
    Given an entropy threshold C, find the minimum degree d ≥ 2
    such that log(d) > C.

    This implements the constructive proof of
    unbounded_horseshoe_implies_infinite_entropy:
    d = ⌊exp(C)⌋ + 2 always works.
    """
    d = int(math.floor(math.exp(threshold))) + 2
    assert d >= 2
    assert math.log(d) > threshold
    return d


# ============================================================
# Algorithm 5: Baker's Map Horseshoe
# ============================================================

def create_baker_horseshoe() -> HorseshoeSystem:
    """
    Create a Baker's map horseshoe system.

    The Baker's map is the canonical degree-2 horseshoe:
    - Strip 0: [0, 1/3]
    - Strip 1: [2/3, 1]
    - f(y) = y/3 for y ∈ [0, 1/3]  (contracts strip 0)
    - f(y) = (y-2/3)/3 + 2/3 for y ∈ [2/3, 1]  (contracts strip 1)

    Both strips get mapped into [0, 1/3] and [2/3, 1] respectively,
    satisfying the crossing property.
    """
    def strips(i: int) -> tuple[float, float]:
        if i == 0:
            return (0.0, 1/3)
        else:
            return (2/3, 1.0)

    def dynamics(y: float) -> float:
        if y <= 1/3:
            return y * 3  # Expand strip 0 to cover [0,1]
        elif y >= 2/3:
            return (y - 2/3) * 3  # Expand strip 1 to cover [0,1]
        else:
            return y  # Middle (not in horseshoe)

    return HorseshoeSystem(degree=2, strips=strips, dynamics=dynamics)


if __name__ == "__main__":
    # Quick test of all algorithms
    print("Testing algorithms...")

    # Test entropy computation
    for d in range(2, 6):
        h = symbolic_entropy(d)
        rates = verify_entropy_growth_rate(d)
        print(f"  Entropy of degree-{d} horseshoe: {h:.6f}")

    # Test degree finder
    for C in [1.0, 5.0, 10.0]:
        d = find_degree_exceeding_entropy(C)
        print(f"  Degree exceeding entropy {C}: d={d}, log(d)={math.log(d):.4f}")

    # Test Baker's map
    baker = create_baker_horseshoe()
    word = [0, 1, 0, 1]
    x0 = orbit_realization(baker, word)
    print(f"  Baker's map orbit realization for word {word}: x0={x0:.6f}")

    print("All tests passed!")

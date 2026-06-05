#!/usr/bin/env python3
"""
Algorithms for Collatz Parity Dynamics

Type-hinted implementations of the core algorithms from the formal development.
"""

from fractions import Fraction
from typing import Optional


def collatz_step(n: int) -> int:
    """
    Standard Collatz step.
    
    T(n) = n/2 if n is even, 3n+1 if n is odd.
    
    Corresponds to `CollatzParity.T` in Lean.
    
    >>> collatz_step(6)
    3
    >>> collatz_step(7)
    22
    """
    return n // 2 if n % 2 == 0 else 3 * n + 1


def collatz_iter(n: int, k: int) -> int:
    """
    Iterate collatz_step k times.
    
    Corresponds to `CollatzParity.T_iter` in Lean.
    
    >>> collatz_iter(7, 3)
    34
    """
    for _ in range(k):
        n = collatz_step(n)
    return n


def syracuse(n: int) -> int:
    """
    Syracuse map: (3n+1)/2 for odd n.
    
    Corresponds to `CollatzParity.syracuse` in Lean.
    
    >>> syracuse(7)
    11
    """
    return (3 * n + 1) // 2


def stopping_time(n: int, max_steps: int = 10_000_000) -> Optional[int]:
    """
    Compute the stopping time of n: least k with T^k(n) = 1.
    
    Returns None if not found within max_steps.
    
    >>> stopping_time(1)
    0
    >>> stopping_time(7)
    16
    """
    current = n
    for k in range(max_steps):
        if current == 1:
            return k
        current = collatz_step(current)
    return None


def peak_value(n: int) -> tuple[int, int]:
    """
    Compute the peak value and its position along the Collatz orbit of n.
    
    Returns (peak, position) where position is the step at which the peak occurs.
    
    >>> peak_value(27)
    (9232, 77)
    """
    current = n
    peak = n
    peak_pos = 0
    step = 0
    while current != 1:
        current = collatz_step(current)
        step += 1
        if current > peak:
            peak = current
            peak_pos = step
    return peak, peak_pos


def parity_sequence(n: int, k: int) -> list[bool]:
    """
    Compute the parity sequence of the first k iterates of n.
    
    True = odd, False = even.
    
    Corresponds to `CollatzParity.paritySeq` in Lean.
    
    >>> parity_sequence(7, 5)
    [True, False, True, False, True]
    """
    result: list[bool] = []
    current = n
    for _ in range(k):
        result.append(current % 2 == 1)
        current = collatz_step(current)
    return result


def odd_count(parity_seq: list[bool]) -> int:
    """
    Count odd steps in a parity sequence.
    
    Corresponds to `CollatzParity.oddCount` in Lean.
    
    >>> odd_count([True, False, True, False, True])
    3
    """
    return sum(parity_seq)


class ParityDrivenAffineMap:
    """
    A parity-driven affine map on ℚ: x ↦ mul * x + offset.
    
    Corresponds to `CollatzParity.ParityDrivenAffineMap` in Lean.
    """
    
    def __init__(self, mul: Fraction, offset: Fraction):
        self.mul = mul
        self.offset = offset
    
    @staticmethod
    def identity() -> 'ParityDrivenAffineMap':
        """The identity map: x ↦ x."""
        return ParityDrivenAffineMap(Fraction(1), Fraction(0))
    
    @staticmethod
    def even_step() -> 'ParityDrivenAffineMap':
        """Even step: x ↦ x/2."""
        return ParityDrivenAffineMap(Fraction(1, 2), Fraction(0))
    
    @staticmethod
    def odd_step() -> 'ParityDrivenAffineMap':
        """Odd step: x ↦ 3x + 1."""
        return ParityDrivenAffineMap(Fraction(3), Fraction(1))
    
    def eval(self, x: Fraction) -> Fraction:
        """Evaluate the affine map at x."""
        return self.mul * x + self.offset
    
    def compose(self, other: 'ParityDrivenAffineMap') -> 'ParityDrivenAffineMap':
        """Compose self ∘ other: (self ∘ other)(x) = self(other(x))."""
        return ParityDrivenAffineMap(
            self.mul * other.mul,
            self.mul * other.offset + self.offset
        )
    
    @staticmethod
    def from_parity_sequence(parity_seq: list[bool]) -> 'ParityDrivenAffineMap':
        """
        Build the cumulative affine map from a parity sequence.
        
        >>> m = ParityDrivenAffineMap.from_parity_sequence([True, False])
        >>> m.eval(Fraction(7))
        Fraction(11, 1)
        """
        result = ParityDrivenAffineMap.identity()
        for is_odd in parity_seq:
            step = ParityDrivenAffineMap.odd_step() if is_odd else ParityDrivenAffineMap.even_step()
            result = step.compose(result)
        return result
    
    def __repr__(self) -> str:
        return f"AffineMap(x ↦ {self.mul} * x + {self.offset})"


def contraction_inequality(j: int) -> bool:
    """
    Verify the contraction inequality: 3^j < 2^(2j).
    
    Always True for j ≥ 1 (proved in Lean).
    
    >>> contraction_inequality(5)
    True
    """
    return 3**j < 2**(2*j) if j >= 1 else True


def density_contraction(j: int, k: int) -> bool:
    """
    Verify the density contraction: 3^j < 2^(k-j) when 3j ≤ k.
    
    Always True for j ≥ 1 and 3j ≤ k (proved in Lean).
    
    >>> density_contraction(2, 7)
    True
    """
    if j < 1 or 3 * j > k:
        return False
    return 3**j < 2**(k - j)


def cycle_coefficient(e: int, j: int) -> int:
    """
    Compute the cycle coefficient 2^e - 3^j.
    
    Never zero for e, j ≥ 1 (proved in Lean: cycle_coeff_nonzero).
    
    >>> cycle_coefficient(2, 1)
    1
    """
    return 2**e - 3**j


def cycle_equation_check(x0: int, L: int) -> Optional[tuple[int, int, int]]:
    """
    Check if x0 participates in a cycle of length L.
    
    Returns (j, e, C) if it does, None otherwise.
    
    >>> cycle_equation_check(1, 3)
    (1, 2, 1)
    """
    orbit = [x0]
    current = x0
    for _ in range(L):
        current = collatz_step(current)
        orbit.append(current)
    
    if orbit[L] != x0:
        return None
    
    j = sum(1 for x in orbit[:L] if x % 2 == 1)
    e = L - j
    C = cycle_coefficient(e, j) * x0
    return j, e, C


def log_drift(odd_steps: int, even_steps: int) -> float:
    """
    Compute the log-drift: odd_steps * (3/2) - even_steps.
    
    Negative drift indicates orbit contraction.
    
    Corresponds to `CollatzBarrier.logDrift` in Lean.
    
    >>> log_drift(2, 5)
    -2.0
    """
    return odd_steps * 1.5 - even_steps


class ContractionCert:
    """
    A contraction certificate for an orbit segment.
    
    Corresponds to `CollatzBarrier.ContractionCert` in Lean.
    """
    
    def __init__(self, length: int, odd_steps: int):
        assert length >= 1, "Length must be ≥ 1"
        assert 3 * odd_steps <= length, f"Density condition violated: 3*{odd_steps} > {length}"
        self.length = length
        self.odd_steps = odd_steps
    
    def contracts(self) -> bool:
        """Verify that 3^j < 2^(k-j)."""
        j = self.odd_steps
        k = self.length
        if j == 0:
            return 1 < 2**(k)  # always true for k ≥ 1
        return 3**j < 2**(k - j)
    
    @staticmethod
    def chain(c1: 'ContractionCert', c2: 'ContractionCert') -> 'ContractionCert':
        """Chain two contraction certificates."""
        return ContractionCert(
            c1.length + c2.length,
            c1.odd_steps + c2.odd_steps
        )


class ProofBarrierSystem:
    """
    A proof barrier system: captures the Σ₁/Π₂ gap.
    
    Corresponds to `CollatzBarrier.ProofBarrierSystem` in Lean.
    """
    
    def __init__(self, name: str, property_fn, bounded_fn, universal_fn):
        self.name = name
        self.property_fn = property_fn
        self.bounded_fn = bounded_fn
        self.universal_fn = universal_fn
    
    def check_bounded(self, N: int) -> bool:
        """Check bounded version up to N."""
        return self.bounded_fn(N)
    
    def check_monotonicity(self, M: int, N: int) -> bool:
        """Check that bounded(N) → bounded(M) for M ≤ N."""
        if M > N:
            return True  # vacuously true
        if self.bounded_fn(N):
            return self.bounded_fn(M)
        return True  # hypothesis false


# Instantiate for Collatz
collatz_barrier = ProofBarrierSystem(
    name="Collatz",
    property_fn=lambda n: n == 0 or stopping_time(n) is not None,
    bounded_fn=lambda N: all(
        n == 0 or stopping_time(n) is not None 
        for n in range(N + 1)
    ),
    universal_fn=lambda: None  # cannot decide!
)


if __name__ == "__main__":
    # Quick sanity checks
    assert collatz_step(6) == 3
    assert collatz_step(7) == 22
    assert stopping_time(1) == 0
    assert stopping_time(7) == 16
    assert contraction_inequality(10)
    assert density_contraction(3, 10)
    assert cycle_coefficient(2, 1) == 1
    assert cycle_equation_check(1, 3) == (1, 2, 1)
    
    # ParityDrivenAffineMap verification
    m = ParityDrivenAffineMap.from_parity_sequence([True, False])
    assert m.eval(Fraction(7)) == Fraction(11)
    
    print("All algorithm tests passed.")

#!/usr/bin/env python3
"""
Algorithms for the Collatz Affine Monoid Framework

Type-hinted implementations of the core algorithms from the paper.
"""

from dataclasses import dataclass
from typing import Optional
import math


@dataclass(frozen=True)
class CAMElement:
    """An element of the Collatz Affine Monoid.

    Represents the affine map n ↦ (num * n + offset) / denom,
    which is the cumulative effect of a Collatz orbit segment.

    Attributes:
        num: Coefficient of the starting value (always 3^s for valid elements)
        offset: Additive term determined by the parity interleaving
        denom: Denominator (always 2^e for valid elements)
    """
    num: int
    offset: int
    denom: int

    def eval(self, n: int) -> int:
        """Evaluate the numerator: num * n + offset."""
        return self.num * n + self.offset

    def apply(self, n: int) -> float:
        """Apply the full affine map: (num * n + offset) / denom."""
        return self.eval(n) / self.denom

    def compose(self, other: "CAMElement") -> "CAMElement":
        """Monoid multiplication: apply self first, then other.

        Corresponds to concatenating Collatz step sequences.

        Algorithm:
            Given f: n → (f.num*n + f.offset)/f.denom
            and   g: m → (g.num*m + g.offset)/g.denom
            Their composition g∘f is:
                n → (g.num*f.num*n + g.num*f.offset + g.offset*f.denom) / (f.denom*g.denom)

        Time: O(1)
        Space: O(1)
        """
        return CAMElement(
            num=other.num * self.num,
            offset=other.num * self.offset + other.offset * self.denom,
            denom=self.denom * other.denom
        )

    def maps_to_one(self, n: int) -> bool:
        """Check if this CAM element maps n to 1: eval(n) == denom."""
        return self.eval(n) == self.denom

    @property
    def contraction_ratio(self) -> float:
        """The growth/contraction ratio: num/denom.
        
        If < 1: orbit segment contracts (on average)
        If > 1: orbit segment expands
        If = 1: perfectly balanced (only for identity)
        """
        return self.num / self.denom

    @staticmethod
    def identity() -> "CAMElement":
        return CAMElement(1, 0, 1)

    @staticmethod
    def even_step() -> "CAMElement":
        return CAMElement(1, 0, 2)

    @staticmethod
    def odd_step() -> "CAMElement":
        return CAMElement(3, 1, 1)


@dataclass
class OrbitSignature:
    """Records the key invariants of a Collatz orbit segment.

    Attributes:
        odd_steps: Number of steps where the value was odd (s)
        even_steps: Number of steps where the value was even (e)
    """
    odd_steps: int
    even_steps: int

    @property
    def length(self) -> int:
        return self.odd_steps + self.even_steps

    @property
    def growth_factor(self) -> int:
        """3^s: the multiplicative growth from odd steps."""
        return 3 ** self.odd_steps

    @property
    def shrink_factor(self) -> int:
        """2^e: the multiplicative shrinkage from even steps."""
        return 2 ** self.even_steps

    @property
    def is_contracting(self) -> bool:
        """True if 3^s < 2^e: the orbit shrinks."""
        return self.growth_factor < self.shrink_factor

    @property
    def is_expanding(self) -> bool:
        """True if 3^s > 2^e: the orbit grows."""
        return self.growth_factor > self.shrink_factor

    @property
    def odd_density(self) -> float:
        """Fraction of odd steps: s/(s+e)."""
        if self.length == 0:
            return 0.0
        return self.odd_steps / self.length

    @property
    def critical_density(self) -> float:
        """The critical density threshold log(2)/log(6) ≈ 0.3869.
        
        Below this: contracting. Above this: expanding.
        """
        return math.log(2) / math.log(6)


def collatz(n: int) -> int:
    """The Collatz function: n/2 if even, 3n+1 if odd."""
    return n // 2 if n % 2 == 0 else 3 * n + 1


def collatz_orbit(n: int, max_steps: int = 10000) -> list[int]:
    """Compute the Collatz orbit of n until reaching 1 or max_steps.
    
    Algorithm:
        Iteratively apply collatz function, collecting values.
        
    Time: O(stopping_time(n))
    Space: O(stopping_time(n))
    """
    orbit = [n]
    for _ in range(max_steps):
        n = collatz(n)
        orbit.append(n)
        if n == 1:
            break
    return orbit


def build_cam(n: int, steps: Optional[int] = None) -> CAMElement:
    """Build the CAM element for the Collatz orbit of n.
    
    If steps is None, builds until reaching 1.
    
    Algorithm:
        Starting from identity, at each step compose with
        even_step or odd_step based on current value's parity.
        
    Time: O(steps)
    Space: O(1) (not counting orbit storage)
    """
    cam = CAMElement.identity()
    current = n
    step_count = 0
    while True:
        if steps is not None and step_count >= steps:
            break
        if steps is None and current == 1:
            break
        if current % 2 == 0:
            cam = cam.compose(CAMElement.even_step())
            current = current // 2
        else:
            cam = cam.compose(CAMElement.odd_step())
            current = 3 * current + 1
        step_count += 1
    return cam


def compute_signature(n: int, steps: Optional[int] = None) -> OrbitSignature:
    """Compute the orbit signature (odd_steps, even_steps) for n.
    
    Algorithm:
        Count parity at each step of the Collatz iteration.
        
    Time: O(steps)
    Space: O(1)
    """
    odd_count = 0
    even_count = 0
    current = n
    step_count = 0
    while True:
        if steps is not None and step_count >= steps:
            break
        if steps is None and current == 1:
            break
        if current % 2 == 0:
            even_count += 1
            current = current // 2
        else:
            odd_count += 1
            current = 3 * current + 1
        step_count += 1
    return OrbitSignature(odd_count, even_count)


def verify_affine_formula(n: int, k: int) -> bool:
    """Verify: collatz^k(n) * cam.denom == cam.num * n + cam.offset.
    
    This is the central theorem of the CAM framework.
    
    Algorithm:
        1. Compute collatz^k(n) by iteration
        2. Build the CAM element for k steps
        3. Check the algebraic identity
        
    Time: O(k)
    Space: O(1)
    """
    # Compute collatz^k(n)
    current = n
    for _ in range(k):
        current = collatz(current)

    # Build CAM
    cam = build_cam(n, k)

    # Verify
    return current * cam.denom == cam.eval(n)


def find_cam_witness(n: int, max_steps: int = 10000) -> Optional[CAMElement]:
    """Find a CAM element that maps n to 1, if one exists within max_steps.
    
    The Collatz conjecture states this always succeeds for n > 0.
    
    Algorithm:
        Build CAM elements incrementally and check maps_to_one condition.
        
    Time: O(stopping_time(n)) if converges, O(max_steps) otherwise
    Space: O(1)
    """
    cam = CAMElement.identity()
    current = n
    for _ in range(max_steps):
        if current == 1:
            return cam
        if current % 2 == 0:
            cam = cam.compose(CAMElement.even_step())
            current = current // 2
        else:
            cam = cam.compose(CAMElement.odd_step())
            current = 3 * current + 1
    return None


def barrier_depth(n: int, max_steps: int = 10000) -> Optional[int]:
    """Compute the barrier depth: minimum steps to reach 1.
    
    Returns None if n doesn't converge within max_steps.
    
    Time: O(stopping_time(n))
    Space: O(1)
    """
    current = n
    for k in range(max_steps):
        if current == 1:
            return k
        current = collatz(current)
    return None


if __name__ == "__main__":
    # Quick test
    for n in [1, 2, 3, 6, 27]:
        cam = find_cam_witness(n)
        sig = compute_signature(n)
        depth = barrier_depth(n)
        print(f"n={n}: depth={depth}, sig=({sig.odd_steps},{sig.even_steps}), "
              f"CAM={cam}, contracting={sig.is_contracting}")

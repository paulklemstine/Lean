#!/usr/bin/env python3
"""
Collatz Affine Map Algebra — Core Algorithms

Type-hinted implementations of the key algorithms from the Collatz
Parity Vector Algebra theory.
"""

from dataclasses import dataclass
from typing import Optional


@dataclass
class CollatzAffineMap:
    """A Collatz Affine Map (a, b, d) representing x ↦ (a·x + b) / d.

    Invariant: After k Collatz steps starting from n, we have
        T^k(n) · d = a · n + b

    The denominator d is always 2^(number of even steps).
    The numerator coefficient a is always 3^(number of odd steps).
    """
    numerator: int      # a = 3^s
    offset: int         # b (depends on ordering of steps)
    denominator: int    # d = 2^t

    def comp_even(self) -> 'CollatzAffineMap':
        """Compose with an even Collatz step: x ↦ x/2."""
        return CollatzAffineMap(
            numerator=self.numerator,
            offset=self.offset,
            denominator=self.denominator * 2
        )

    def comp_odd(self) -> 'CollatzAffineMap':
        """Compose with an odd Collatz step: x ↦ 3x+1."""
        return CollatzAffineMap(
            numerator=3 * self.numerator,
            offset=3 * self.offset + self.denominator,
            denominator=self.denominator
        )

    def evaluate(self, n: int) -> int:
        """Evaluate the affine map: returns T^k(n) = (a·n + b) / d."""
        assert (self.numerator * n + self.offset) % self.denominator == 0, \
            f"Not divisible: ({self.numerator}*{n} + {self.offset}) / {self.denominator}"
        return (self.numerator * n + self.offset) // self.denominator

    @staticmethod
    def identity() -> 'CollatzAffineMap':
        """The identity map: x ↦ x."""
        return CollatzAffineMap(1, 0, 1)


def collatz_step(n: int) -> int:
    """Standard Collatz step: T(n) = n/2 if even, 3n+1 if odd."""
    return n // 2 if n % 2 == 0 else 3 * n + 1


def collatz_trajectory(n: int, max_steps: int = 10000) -> list[int]:
    """Compute the Collatz trajectory from n until reaching 1."""
    trajectory = [n]
    while n != 1 and len(trajectory) < max_steps:
        n = collatz_step(n)
        trajectory.append(n)
    return trajectory


def parity_vector(n: int, k: int) -> list[int]:
    """Compute the parity vector of the first k Collatz iterates.

    Returns a list of 0s (even) and 1s (odd).
    """
    vec: list[int] = []
    val = n
    for _ in range(k):
        vec.append(val % 2)
        val = collatz_step(val)
    return vec


def build_affine_map(parities: list[int]) -> CollatzAffineMap:
    """Build the Collatz Affine Map from a parity vector.

    Algorithm:
        Start with identity (1, 0, 1).
        For each parity bit p:
            if p == 0: comp_even (multiply denom by 2)
            if p == 1: comp_odd (multiply num by 3, adjust offset)

    Time complexity: O(k) where k = len(parities)
    Space complexity: O(1) (ignoring big integer growth)
    """
    cam = CollatzAffineMap.identity()
    for p in parities:
        if p == 0:
            cam = cam.comp_even()
        else:
            cam = cam.comp_odd()
    return cam


def reconstruct_iterate(n: int, k: int) -> int:
    """Compute T^k(n) using the affine map (without stepping through intermediates).

    This demonstrates the Affine Reconstruction Theorem:
        T^k(n) = (a·n + b) / d
    where (a, b, d) = build_affine_map(parity_vector(n, k)).

    Note: Computing the parity vector still requires stepping through the trajectory,
    so this doesn't save computation. The value is theoretical: it shows the trajectory
    is governed by a single affine equation.
    """
    pvec = parity_vector(n, k)
    cam = build_affine_map(pvec)
    return cam.evaluate(n)


def stopping_time(n: int, max_steps: int = 10000) -> Optional[int]:
    """Compute the stopping time: first k such that T^k(n) < n.

    Returns None if not found within max_steps.
    """
    if n <= 1:
        return 0
    val = n
    for k in range(1, max_steps + 1):
        val = collatz_step(val)
        if val < n:
            return k
    return None


def total_stopping_time(n: int, max_steps: int = 100000) -> Optional[int]:
    """Compute the total stopping time: first k such that T^k(n) = 1.

    Returns None if not found within max_steps.
    """
    if n <= 1:
        return 0
    val = n
    for k in range(1, max_steps + 1):
        val = collatz_step(val)
        if val == 1:
            return k
    return None


def odd_step_ratio(n: int) -> Optional[float]:
    """Compute the ratio of odd steps to total steps in the trajectory to 1.

    Theory predicts this should be close to 1 - log(3)/log(4) ≈ 0.208
    for "generic" starting values.
    """
    traj = collatz_trajectory(n)
    if traj[-1] != 1:
        return None
    total = len(traj) - 1
    if total == 0:
        return 0.0
    odd_count = sum(1 for i in range(total) if traj[i] % 2 == 1)
    return odd_count / total


def syracuse(n: int) -> int:
    """Syracuse accelerated map: S(n) = (3n+1)/2 for odd n."""
    assert n % 2 == 1, f"Syracuse requires odd input, got {n}"
    return (3 * n + 1) // 2


def verify_affine_reconstruction(n: int, k: int) -> bool:
    """Verify the Affine Reconstruction Theorem for specific n, k.

    Checks: T^k(n) * d == a * n + b
    """
    pvec = parity_vector(n, k)
    cam = build_affine_map(pvec)
    iterate = n
    for _ in range(k):
        iterate = collatz_step(iterate)
    return iterate * cam.denominator == cam.numerator * n + cam.offset


if __name__ == "__main__":
    # Verify the reconstruction theorem for many cases
    print("Verifying Affine Reconstruction Theorem...")
    failures = 0
    for n in range(1, 1001):
        for k in [1, 5, 10, 20, 50]:
            if not verify_affine_reconstruction(n, k):
                print(f"  FAILURE at n={n}, k={k}")
                failures += 1
    print(f"  Tested 5000 cases, {failures} failures")
    print()

    # Show odd step ratios
    print("Odd step ratios (predicted ≈ 0.208):")
    for n in [27, 97, 871, 6171, 77031, 837799]:
        ratio = odd_step_ratio(n)
        tst = total_stopping_time(n)
        if ratio is not None and tst is not None:
            print(f"  n={n:>8d}: ratio={ratio:.4f}, total_stopping_time={tst}")

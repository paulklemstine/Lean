#!/usr/bin/env python3
"""
Algorithms for Transfinite Proof Refinement Systems

Type-hinted implementations of the core algorithms from the theory.
"""

from typing import TypeVar, Generic, Callable, Optional, Tuple, List, Protocol
from dataclasses import dataclass
from abc import ABC, abstractmethod

T = TypeVar('T')  # Theorem type
P = TypeVar('P')  # Proof type


class RefinementSystem(Generic[T, P]):
    """
    A proof refinement system with ordinal-valued complexity.

    In practice, we use int for complexity (representing finite ordinals).
    For true ordinal values, see OrdinalValue.
    """
    def __init__(
        self,
        proves: Callable[[P], T],
        complexity: Callable[[P], int],
    ):
        self.proves = proves
        self.complexity = complexity

    def is_refinement(self, p_new: P, p_old: P) -> bool:
        """Check if p_new refines p_old."""
        return (self.proves(p_new) == self.proves(p_old) and
                self.complexity(p_new) < self.complexity(p_old))

    def is_minimal(self, p: P, candidates: List[P]) -> bool:
        """Check if p is minimal among candidates."""
        return not any(self.is_refinement(q, p) for q in candidates)


class Optimizer(Generic[P]):
    """
    A proof optimizer: preserves theorems, never increases complexity.
    """
    def __init__(self, optimize: Callable[[P], P]):
        self._optimize = optimize

    def optimize(self, p: P) -> P:
        return self._optimize(p)

    def iterate(self, n: int, p: P) -> P:
        """Apply optimizer n times."""
        result = p
        for _ in range(n):
            result = self.optimize(result)
        return result


@dataclass
class OrdinalValue:
    """
    Representation of ordinals below ω^ω using Cantor normal form.

    An ordinal in CNF is ω^(k-1) * coeffs[k-1] + ... + ω * coeffs[1] + coeffs[0]
    where coeffs[i] are natural numbers.
    """
    coeffs: List[int]  # coeffs[i] is the coefficient of ω^i

    def __post_init__(self):
        # Remove trailing zeros
        while len(self.coeffs) > 1 and self.coeffs[-1] == 0:
            self.coeffs.pop()

    @staticmethod
    def from_nat(n: int) -> 'OrdinalValue':
        """Create ordinal from natural number."""
        return OrdinalValue([n])

    @staticmethod
    def omega(power: int = 1, coeff: int = 1) -> 'OrdinalValue':
        """Create ω^power * coeff."""
        coeffs = [0] * (power + 1)
        coeffs[power] = coeff
        return OrdinalValue(coeffs)

    def __lt__(self, other: 'OrdinalValue') -> bool:
        max_len = max(len(self.coeffs), len(other.coeffs))
        for i in range(max_len - 1, -1, -1):
            a = self.coeffs[i] if i < len(self.coeffs) else 0
            b = other.coeffs[i] if i < len(other.coeffs) else 0
            if a < b:
                return True
            if a > b:
                return False
        return False

    def __le__(self, other: 'OrdinalValue') -> bool:
        return self == other or self < other

    def __eq__(self, other: object) -> bool:
        if not isinstance(other, OrdinalValue):
            return NotImplemented
        max_len = max(len(self.coeffs), len(other.coeffs))
        for i in range(max_len):
            a = self.coeffs[i] if i < len(self.coeffs) else 0
            b = other.coeffs[i] if i < len(other.coeffs) else 0
            if a != b:
                return False
        return True

    def __repr__(self) -> str:
        if all(c == 0 for c in self.coeffs):
            return "0"
        terms = []
        for i in range(len(self.coeffs) - 1, -1, -1):
            if self.coeffs[i] == 0:
                continue
            if i == 0:
                terms.append(str(self.coeffs[i]))
            elif i == 1:
                if self.coeffs[i] == 1:
                    terms.append("ω")
                else:
                    terms.append(f"ω·{self.coeffs[i]}")
            else:
                if self.coeffs[i] == 1:
                    terms.append(f"ω^{i}")
                else:
                    terms.append(f"ω^{i}·{self.coeffs[i]}")
        return " + ".join(terms) if terms else "0"

    def __hash__(self) -> int:
        return hash(tuple(self.coeffs))


def find_fixed_point(
    optimizer: Callable[[P], P],
    complexity: Callable[[P], int],
    initial: P,
    max_steps: int = 100000,
) -> Tuple[P, int, List[int]]:
    """
    Find the fixed point of an optimizer.

    Returns:
        (fixed_point, num_steps, complexity_trajectory)

    Guaranteed to terminate by the ω-Step Theorem when complexity
    is well-ordered and the optimizer is non-increasing.
    """
    p = initial
    trajectory: List[int] = [complexity(p)]
    steps = 0

    while steps < max_steps:
        p_new = optimizer(p)
        c_new = complexity(p_new)
        trajectory.append(c_new)
        steps += 1

        if c_new == trajectory[-2]:  # Complexity stabilized
            # Check if it stays stable for a few more steps
            stable = True
            for _ in range(min(5, max_steps - steps)):
                p_check = optimizer(p_new)
                if complexity(p_check) != c_new:
                    stable = False
                    break
                p_new = p_check
            if stable:
                return p_new, steps, trajectory

        p = p_new

    return p, steps, trajectory


def verify_lyapunov_certificate(
    optimizer: Callable[[P], P],
    complexity: Callable[[P], int],
    potential: Callable[[P], int],
    test_points: List[P],
) -> Tuple[bool, Optional[str]]:
    """
    Verify that a potential function is a valid Lyapunov certificate.

    Returns:
        (is_valid, error_message)
    """
    for p in test_points:
        p_new = optimizer(p)

        # Check non-increasing
        if potential(p_new) > potential(p):
            return False, f"Potential increased at {p}: V({p})={potential(p)} -> V({p_new})={potential(p_new)}"

        # Check strict decrease when complexity changes
        if complexity(p_new) != complexity(p) and potential(p_new) >= potential(p):
            return False, (f"Potential did not strictly decrease when complexity changed at {p}: "
                          f"C={complexity(p)}->{complexity(p_new)}, V={potential(p)}->{potential(p_new)}")

    return True, None


def compose_optimizers(
    opt1: Callable[[P], P],
    opt2: Callable[[P], P],
) -> Callable[[P], P]:
    """Compose two optimizers: apply opt2 first, then opt1."""
    def composed(p: P) -> P:
        return opt1(opt2(p))
    return composed


def max_chain_length(
    system: RefinementSystem[T, P],
    start: P,
    candidates: List[P],
) -> Tuple[int, List[P]]:
    """
    Find the maximum refinement chain length from start.

    Uses DFS to find the longest chain of strict refinements.
    Returns (length, chain).
    """
    best_chain: List[P] = [start]
    best_length = 0

    def dfs(current: P, chain: List[P], depth: int):
        nonlocal best_chain, best_length

        if depth > best_length:
            best_length = depth
            best_chain = chain.copy()

        for candidate in candidates:
            if system.is_refinement(candidate, current):
                chain.append(candidate)
                dfs(candidate, chain, depth + 1)
                chain.pop()

    dfs(start, [start], 0)
    return best_length, best_chain


def ordinal_optimizer_demo():
    """
    Demonstrate the ordinal optimizer with Cantor normal form ordinals.
    """
    print("Ordinal Optimizer Demo")
    print("=" * 50)

    # System with ordinal complexity ω·a + b
    # Optimizer: decrease b by 1, or if b=0, decrease a by 1 and set b=10
    def optimizer(state: Tuple[int, int]) -> Tuple[int, int]:
        a, b = state
        if b > 0:
            return (a, b - 1)
        elif a > 0:
            return (a - 1, 10)
        else:
            return (0, 0)

    def complexity_ordinal(state: Tuple[int, int]) -> OrdinalValue:
        a, b = state
        return OrdinalValue([b, a])

    initial = (3, 5)
    state = initial
    steps = 0
    print(f"  Initial state: {initial}, complexity: {complexity_ordinal(initial)}")

    while state != (0, 0) and steps < 100:
        state = optimizer(state)
        steps += 1
        if steps <= 10 or state == (0, 0):
            print(f"  Step {steps:3d}: state = {state}, complexity = {complexity_ordinal(state)}")
        elif steps == 11:
            print(f"  ...")

    print(f"  Total steps: {steps}")
    print(f"  Predicted bound (from CNF coefficients): {3 + 5} + intermediate resets")
    print()


if __name__ == "__main__":
    ordinal_optimizer_demo()

    # Quick test of find_fixed_point
    result, steps, traj = find_fixed_point(
        optimizer=lambda x: x // 2,
        complexity=lambda x: x,
        initial=1024,
    )
    print(f"Halving optimizer: 1024 -> {result} in {steps} steps")
    print(f"Trajectory: {traj}")

#!/usr/bin/env python3
"""
Proof Refinement Systems — Core Algorithms

Type-hinted implementations of the key algorithms from the framework.
"""

from dataclasses import dataclass, field
from typing import TypeVar, Generic, Callable, Optional, List, Tuple, Dict
from abc import ABC, abstractmethod

S = TypeVar('S')


@dataclass
class ProofRefinementSystem(Generic[S]):
    """A proof refinement system: states with complexity and refinement."""
    complexity: Callable[[S], int]
    refines: Callable[[S, S], bool]
    
    def is_minimal(self, x: S) -> bool:
        """Check if x is minimal (no further refinement possible)."""
        raise NotImplementedError("Requires enumeration of all states")


@dataclass
class Optimizer(Generic[S]):
    """An optimizer that never increases complexity."""
    step: Callable[[S], S]
    system: ProofRefinementSystem[S]
    
    def is_fixed_point(self, x: S) -> bool:
        """Check if x is a fixed point."""
        return self.step(x) == x
    
    def orbit(self, x: S, n: int) -> S:
        """Compute the orbit: n applications of step starting from x."""
        result = x
        for _ in range(n):
            result = self.step(result)
        return result
    
    def orbit_sequence(self, x: S, max_steps: int) -> List[S]:
        """Generate the orbit sequence until fixed point or max_steps."""
        seq = [x]
        for _ in range(max_steps):
            next_state = self.step(seq[-1])
            seq.append(next_state)
            if next_state == seq[-2]:
                break
        return seq
    
    def find_fixed_point(self, x: S) -> Tuple[S, int]:
        """
        Find a fixed point starting from x.
        Returns (fixed_point, num_steps).
        Guaranteed to terminate for strict optimizers by Theorem 3.4.
        """
        current = x
        steps = 0
        bound = self.system.complexity(x)
        
        while steps <= bound:
            next_state = self.step(current)
            if next_state == current:
                return current, steps
            current = next_state
            steps += 1
        
        # Should never reach here for strict optimizers
        return current, steps


@dataclass
class LyapunovCertificate(Generic[S]):
    """A Lyapunov certificate for an optimizer."""
    potential: Callable[[S], int]
    optimizer: Optimizer[S]
    
    def verify_nonincreasing(self, x: S) -> bool:
        """Verify that potential is non-increasing at x."""
        return self.potential(self.optimizer.step(x)) <= self.potential(x)
    
    def verify_strict(self, x: S) -> bool:
        """Verify that potential stability implies fixed point at x."""
        if self.potential(self.optimizer.step(x)) == self.potential(x):
            return self.optimizer.step(x) == x
        return True
    
    def convergence_bound(self, x: S) -> int:
        """Upper bound on steps to fixed point."""
        return self.potential(x)
    
    def find_fixed_point_with_certificate(self, x: S) -> Tuple[S, int, List[int]]:
        """
        Find fixed point using the Lyapunov certificate.
        Returns (fixed_point, steps, potential_history).
        """
        current = x
        steps = 0
        potentials = [self.potential(x)]
        bound = self.potential(x)
        
        while steps <= bound:
            next_state = self.optimizer.step(current)
            if next_state == current:
                return current, steps, potentials
            current = next_state
            steps += 1
            potentials.append(self.potential(current))
        
        return current, steps, potentials


@dataclass
class MultiObjectiveSystem(Generic[S]):
    """A multi-objective refinement system with k objectives."""
    objectives: List[Callable[[S], int]]
    
    @property
    def k(self) -> int:
        return len(self.objectives)
    
    def total_complexity(self, x: S) -> int:
        """Sum of all objectives."""
        return sum(obj(x) for obj in self.objectives)
    
    def pareto_dominates(self, x: S, y: S) -> bool:
        """Check if y Pareto-dominates x (y is at least as good in all, strictly better in one)."""
        vals_x = [obj(x) for obj in self.objectives]
        vals_y = [obj(y) for obj in self.objectives]
        return (all(vy <= vx for vx, vy in zip(vals_x, vals_y)) and
                any(vy < vx for vx, vy in zip(vals_x, vals_y)))
    
    def to_single_objective(self) -> ProofRefinementSystem[S]:
        """Convert to a single-objective system using the sum."""
        return ProofRefinementSystem(
            complexity=self.total_complexity,
            refines=self.pareto_dominates
        )


def refinement_strategy_run(
    complexity: Callable[[S], int],
    strategy: Callable[[S], Optional[S]],
    start: S
) -> Tuple[S, int, List[S]]:
    """
    Run a refinement strategy until termination.
    
    Args:
        complexity: Complexity measure
        strategy: Returns None if minimal, else a strictly better state
        start: Starting state
    
    Returns:
        (final_state, steps, trajectory)
    
    Guaranteed to terminate within complexity(start) steps by Theorem 3.16.
    """
    current = start
    steps = 0
    trajectory = [current]
    bound = complexity(start)
    
    while steps <= bound:
        result = strategy(current)
        if result is None:
            return current, steps, trajectory
        current = result
        steps += 1
        trajectory.append(current)
    
    return current, steps, trajectory


def compose_morphism(
    f_map: Callable[[S], S],
    g_map: Callable[[S], S]
) -> Callable[[S], S]:
    """Compose two refinement morphisms."""
    return lambda x: f_map(g_map(x))


# ─── Concrete Examples ───────────────────────────────────────────

def linear_chain_system(n: int) -> Tuple[ProofRefinementSystem[int], Optimizer[int]]:
    """Create the linear chain system with n states."""
    system = ProofRefinementSystem[int](
        complexity=lambda x: x,
        refines=lambda x, y: y == x - 1 and x > 0
    )
    optimizer = Optimizer[int](
        step=lambda x: max(0, x - 1),
        system=system
    )
    return system, optimizer


def binary_tree_system() -> Tuple[ProofRefinementSystem[int], Optimizer[int]]:
    """
    Binary tree system where optimization is logarithmic.
    States: positive integers. Complexity: value. Step: halve.
    """
    system = ProofRefinementSystem[int](
        complexity=lambda x: x,
        refines=lambda x, y: y == x // 2 and x > 0
    )
    optimizer = Optimizer[int](
        step=lambda x: x // 2,
        system=system
    )
    return system, optimizer


def product_system(
    sys1: ProofRefinementSystem[S],
    sys2: ProofRefinementSystem[S],
) -> ProofRefinementSystem[Tuple[S, S]]:
    """Construct the product of two refinement systems."""
    return ProofRefinementSystem[Tuple[S, S]](
        complexity=lambda p: sys1.complexity(p[0]) + sys2.complexity(p[1]),
        refines=lambda p, q: (
            (sys1.refines(p[0], q[0]) and p[1] == q[1]) or
            (p[0] == q[0] and sys2.refines(p[1], q[1]))
        )
    )


if __name__ == "__main__":
    # Demo: Linear chain
    sys, opt = linear_chain_system(10)
    fp, steps = opt.find_fixed_point(10)
    print(f"Linear chain from 10: fixed point = {fp}, steps = {steps}")
    
    # Demo: Binary tree (logarithmic convergence)
    sys2, opt2 = binary_tree_system()
    fp2, steps2 = opt2.find_fixed_point(1024)
    print(f"Binary tree from 1024: fixed point = {fp2}, steps = {steps2}")
    
    # Demo: Lyapunov certificate
    cert = LyapunovCertificate[int](
        potential=lambda x: x,
        optimizer=opt
    )
    fp3, steps3, pots = cert.find_fixed_point_with_certificate(10)
    print(f"Lyapunov convergence from 10: {steps3} steps, potentials: {pots}")
    
    # Demo: Refinement strategy
    def halving_strategy(x: int) -> Optional[int]:
        if x == 0:
            return None
        return x // 2 if x % 2 == 0 else x - 1
    
    final, s, traj = refinement_strategy_run(lambda x: x, halving_strategy, 100)
    print(f"Strategy from 100: {s} steps, trajectory length: {len(traj)}")

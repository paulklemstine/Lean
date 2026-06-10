#!/usr/bin/env python3
"""
Algorithms for Reflective Self-Modifying Systems

Implements the core algorithms from the reflective type theory framework:
1. Closure computation on finite knowledge sets
2. Ranked convergence for dependent reflective systems
3. Oracle composition with stability checking
4. Fixed-point detection with convergence certificates

All algorithms include complexity analysis and concrete examples.
"""

from typing import (
    Callable, TypeVar, Generic, Set, FrozenSet,
    Dict, List, Tuple, Optional, Any
)
from dataclasses import dataclass
from enum import Enum


# ============================================================
# Algorithm 1: Closure Operator Computation
# ============================================================

@dataclass
class ClosureResult:
    """Result of closure computation."""
    fixed_point: FrozenSet[int]
    num_iterations: int
    trajectory: List[FrozenSet[int]]
    is_idempotent: bool


def compute_closure(
    F: Callable[[FrozenSet[int]], FrozenSet[int]],
    initial: Set[int],
    max_iter: int = 1000
) -> ClosureResult:
    """
    Compute the closure of a set under an extensive monotone operator.

    Algorithm:
        1. Start with s₀ = initial
        2. Compute s_{n+1} = F(s_n)
        3. Stop when s_{n+1} = s_n (fixed point reached)

    Complexity:
        - Time: O(k · T_F) where k = number of iterations, T_F = cost of F
        - Space: O(|fixed_point|)
        - For idempotent F: k = 1 (immediate convergence)
        - For non-idempotent extensive F on universe of size N: k ≤ N

    Args:
        F: The operator (should be extensive: s ⊆ F(s))
        initial: Starting set
        max_iter: Safety bound on iterations

    Returns:
        ClosureResult with fixed point and convergence data
    """
    current = frozenset(initial)
    trajectory = [current]

    for i in range(max_iter):
        next_s = F(current)
        trajectory.append(next_s)
        if next_s == current:
            # Verify idempotence
            ff = F(next_s)
            return ClosureResult(
                fixed_point=current,
                num_iterations=i + 1,
                trajectory=trajectory,
                is_idempotent=(ff == next_s)
            )
        current = next_s

    raise RuntimeError(f"Closure did not converge in {max_iter} iterations")


def make_idempotent_closure(
    rules: List[Tuple[Set[int], int]]
) -> Callable[[FrozenSet[int]], FrozenSet[int]]:
    """
    Build an idempotent closure operator from derivation rules.

    Each rule (premises, conclusion) says: if premises ⊆ s, add conclusion.
    The closure applies all rules to saturation.

    Complexity:
        - Time per call: O(|rules| · |s|) per iteration, O(N · |rules| · |s|) total
          where N = universe size
        - The resulting operator IS idempotent (F(F(s)) = F(s))
    """
    def F(s: FrozenSet[int]) -> FrozenSet[int]:
        current = set(s)
        changed = True
        while changed:
            changed = False
            for premises, conclusion in rules:
                if premises <= current and conclusion not in current:
                    current.add(conclusion)
                    changed = True
        return frozenset(current)
    return F


# ============================================================
# Algorithm 2: Ranked Convergence
# ============================================================

@dataclass
class ConvergenceResult:
    """Result of ranked convergence computation."""
    fixed_point: Any
    num_steps: int
    trajectory: List[Any]
    ranks: List[int]
    is_genuine_fixed_point: bool  # F(t) = t


def ranked_convergence(
    F: Callable[[int], int],
    rank: Callable[[int], int],
    initial: int,
    max_steps: int = 10000
) -> ConvergenceResult:
    """
    Find the fixed point of a self-modifying system with a decreasing rank.

    Algorithm (corresponds to Theorem 2):
        1. Start at s₀ = initial
        2. Compute s_{n+1} = F(s_n)
        3. Check rank(s_{n+1}) ≤ rank(s_n) (monotone decrease)
        4. Stop when s_{n+1} = s_n

    Complexity:
        - Time: O(rank(initial) · T_F) in the worst case
        - Space: O(1) beyond the trajectory storage
        - Guaranteed to terminate: rank is a natural number that strictly
          decreases at each non-fixed step

    Args:
        F: The update function
        rank: Ranking function μ : State → Nat
        initial: Starting state

    Returns:
        ConvergenceResult with fixed point, trajectory, and rank history
    """
    current = initial
    trajectory = [current]
    ranks = [rank(current)]

    for step in range(max_steps):
        next_s = F(current)
        next_rank = rank(next_s)
        trajectory.append(next_s)
        ranks.append(next_rank)

        if next_s == current:
            return ConvergenceResult(
                fixed_point=current,
                num_steps=step + 1,
                trajectory=trajectory,
                ranks=ranks,
                is_genuine_fixed_point=(F(current) == current)
            )

        # Verify rank decreases
        assert next_rank <= ranks[-2], (
            f"Rank increased! μ({current})={ranks[-2]} → μ({next_s})={next_rank}"
        )
        current = next_s

    raise RuntimeError(f"Did not converge in {max_steps} steps")


# ============================================================
# Algorithm 3: Oracle Composition
# ============================================================

@dataclass
class Oracle:
    """A research oracle with an idempotent validation function."""
    name: str
    validate: Callable[[int], int]

    def is_stable(self, domain: range) -> bool:
        """Check idempotence over a finite domain."""
        return all(
            self.validate(self.validate(h)) == self.validate(h)
            for h in domain
        )

    def knowledge_base(self, domain: range) -> Set[int]:
        """Fixed points of the oracle over a domain."""
        return {h for h in domain if self.validate(h) == h}


def compose_oracles(R: Oracle, S: Oracle) -> Oracle:
    """
    Compose two oracles: (R ∘ S)(h) = R.validate(S.validate(h)).

    The composite is stable (idempotent) when:
        R(S(R(S(h)))) = R(S(h)) for all h

    This is the commutativity condition from Theorem 5.

    Complexity:
        - Time per validation: T_R + T_S
        - Stability check: O(|domain| · (T_R + T_S))
    """
    def composite_validate(h: int) -> int:
        return R.validate(S.validate(h))

    return Oracle(
        name=f"{R.name}∘{S.name}",
        validate=composite_validate
    )


def check_oracle_commutativity(
    R: Oracle, S: Oracle, domain: range
) -> Tuple[bool, Optional[int]]:
    """
    Check the commutativity condition for oracle composition stability.

    Returns (True, None) if the condition holds, or (False, counterexample)
    if it fails.
    """
    for h in domain:
        rs = R.validate(S.validate(h))
        rsrs = R.validate(S.validate(R.validate(S.validate(h))))
        if rs != rsrs:
            return False, h
    return True, None


# ============================================================
# Algorithm 4: General Reflective System
# ============================================================

@dataclass
class ReflectiveSystem:
    """
    A reflective system with dependent next-type, step, and improve.

    In the general theory, NextType : State → Type varies with state.
    In this Python implementation, we model actions as integers and
    the dependency through the step/improve functions.
    """
    name: str
    step: Callable[[int, int], int]   # step(state, action) -> new_state
    improve: Callable[[int], int]      # improve(state) -> best_action
    rank: Callable[[int], int]         # ranking function

    def update(self, s: int) -> int:
        """The induced deterministic update."""
        return self.step(s, self.improve(s))

    def find_fixed_point(self, initial: int, max_steps: int = 10000) -> ConvergenceResult:
        """Find the fixed point by iteration."""
        return ranked_convergence(
            F=self.update,
            rank=self.rank,
            initial=initial,
            max_steps=max_steps
        )

    def is_ranking_valid(self, domain: range) -> bool:
        """Verify the ranking function weakly decreases under update."""
        return all(
            self.rank(self.update(s)) <= self.rank(s)
            for s in domain
        )

    def has_strict_progress(self, domain: range) -> bool:
        """Verify strict progress away from fixed points."""
        return all(
            self.update(s) == s or self.rank(self.update(s)) < self.rank(s)
            for s in domain
        )


# ============================================================
# Algorithm 5: Fixed-Point Certificate
# ============================================================

@dataclass
class FixedPointCertificate:
    """
    A certificate proving that a state is a fixed point.

    Contains the trajectory from initial state to the fixed point
    along with rank data proving termination.
    """
    initial_state: Any
    fixed_point: Any
    num_steps: int
    trajectory: List[Any]
    ranks: List[int]
    verification: str  # "F(t) = t" check result

    def verify(self, F: Callable) -> bool:
        """Independently verify the certificate."""
        # Check trajectory
        for i in range(len(self.trajectory) - 1):
            if F(self.trajectory[i]) != self.trajectory[i + 1]:
                return False
        # Check fixed point
        if F(self.fixed_point) != self.fixed_point:
            return False
        # Check ranks are non-increasing
        for i in range(len(self.ranks) - 1):
            if self.ranks[i + 1] > self.ranks[i]:
                return False
        return True


def certify_convergence(
    system: ReflectiveSystem,
    initial: int
) -> FixedPointCertificate:
    """
    Produce a verifiable certificate of convergence.

    The certificate contains the full trajectory and rank data,
    which can be independently verified without trusting the
    system implementation.

    Complexity:
        - Time: O(rank(initial) · T_update)
        - Certificate size: O(rank(initial))
    """
    result = system.find_fixed_point(initial)

    cert = FixedPointCertificate(
        initial_state=initial,
        fixed_point=result.fixed_point,
        num_steps=result.num_steps,
        trajectory=result.trajectory,
        ranks=result.ranks,
        verification=f"F({result.fixed_point}) = {system.update(result.fixed_point)}"
    )

    assert cert.verify(system.update), "Certificate verification failed!"
    return cert


# ============================================================
# Examples and Usage
# ============================================================

if __name__ == "__main__":
    print("=" * 60)
    print("Algorithm 1: Closure Operator")
    print("=" * 60)

    rules = [
        ({0, 1}, 2),   # knowing 0 and 1 derives 2
        ({2, 3}, 4),   # knowing 2 and 3 derives 4
        ({1, 4}, 5),   # knowing 1 and 4 derives 5
        ({0, 5}, 6),   # knowing 0 and 5 derives 6
    ]
    F = make_idempotent_closure(rules)
    result = compute_closure(F, {0, 1, 3})
    print(f"Initial: {{0, 1, 3}}")
    print(f"Fixed point: {sorted(result.fixed_point)}")
    print(f"Iterations: {result.num_iterations}")
    print(f"Idempotent: {result.is_idempotent}")

    print("\n" + "=" * 60)
    print("Algorithm 2: Ranked Convergence")
    print("=" * 60)

    # Collatz-like system (guaranteed to converge for these values)
    def collatz_step(s: int) -> int:
        if s <= 1:
            return s
        return s // 2 if s % 2 == 0 else s - 1

    result = ranked_convergence(
        F=collatz_step,
        rank=lambda s: s,
        initial=42
    )
    print(f"Initial: 42")
    print(f"Fixed point: {result.fixed_point}")
    print(f"Steps: {result.num_steps}")
    print(f"Trajectory: {result.trajectory}")

    print("\n" + "=" * 60)
    print("Algorithm 3: Oracle Composition")
    print("=" * 60)

    R = Oracle("mod3", lambda h: (h // 3) * 3)
    S = Oracle("even", lambda h: (h // 2) * 2)

    commutes, cex = check_oracle_commutativity(R, S, range(100))
    print(f"R={R.name}, S={S.name}")
    print(f"Commutativity holds: {commutes}")

    RS = compose_oracles(R, S)
    print(f"Composite stable: {RS.is_stable(range(100))}")
    print(f"Knowledge base (R): {sorted(R.knowledge_base(range(20)))}")
    print(f"Knowledge base (S): {sorted(S.knowledge_base(range(20)))}")
    print(f"Knowledge base (R∘S): {sorted(RS.knowledge_base(range(20)))}")

    print("\n" + "=" * 60)
    print("Algorithm 4: Reflective System with Certificate")
    print("=" * 60)

    system = ReflectiveSystem(
        name="gradient_descent",
        step=lambda s, a: s + a,
        improve=lambda s: -1 if s > 0 else (1 if s < 0 else 0),
        rank=lambda s: abs(s)
    )

    cert = certify_convergence(system, 7)
    print(f"System: {system.name}")
    print(f"Initial: {cert.initial_state}")
    print(f"Fixed point: {cert.fixed_point}")
    print(f"Steps: {cert.num_steps}")
    print(f"Trajectory: {cert.trajectory}")
    print(f"Ranks: {cert.ranks}")
    print(f"Verification: {cert.verification}")
    print(f"Certificate valid: {cert.verify(system.update)}")

    # Verify ranking properties
    print(f"\nRanking valid (domain [0,20]): {system.is_ranking_valid(range(21))}")
    print(f"Strict progress (domain [0,20]): {system.has_strict_progress(range(21))}")

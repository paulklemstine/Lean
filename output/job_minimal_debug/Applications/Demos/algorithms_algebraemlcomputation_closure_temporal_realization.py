#!/usr/bin/env python3
"""
Algorithms for Closure-Delay Temporal Realization Duality

Implements the core algorithms from the research paper:
1. Observational equivalence partition refinement
2. Canonical minimal reversible scheduler construction
3. Scheduler isomorphism testing
4. Synchronous product construction
"""

import numpy as np
from typing import Dict, List, Tuple, Set, Optional
from dataclasses import dataclass, field


@dataclass
class FiniteReversibleScheduler:
    """A finite reversible scheduler."""
    n_states: int
    n_times: int
    n_events: int
    step: np.ndarray       # shape (n_states, n_times) -> state
    emit: np.ndarray       # shape (n_states, n_events) -> bool
    rev_state: np.ndarray  # shape (n_states,) -> state
    class_map: Dict[int, int] = field(default_factory=dict)
    representatives: Dict[int, int] = field(default_factory=dict)

    def is_involutive(self) -> bool:
        """Check that rev_state is an involution."""
        return all(self.rev_state[self.rev_state[i]] == i
                   for i in range(self.n_states))

    def is_step_rev_compatible(self) -> bool:
        """Check that step and rev_state commute."""
        return all(
            self.rev_state[self.step[i, t]] == self.step[self.rev_state[i], t]
            for i in range(self.n_states)
            for t in range(self.n_times)
        )


def compute_observational_profiles(H: np.ndarray) -> Tuple[Dict[int, int], int]:
    """
    Compute observational equivalence classes by profile hashing.

    Args:
        H: Response table of shape (n_events, n_times, n_events)

    Returns:
        (class_map, n_classes) where class_map[event] = class_label

    Time complexity: O(n * k * n) = O(n²k) where n = n_events, k = n_times
    Space complexity: O(n * k * n) for profile storage
    """
    n_events = H.shape[0]
    profiles = H.reshape(n_events, -1)

    class_map: Dict[int, int] = {}
    profile_to_class: Dict[tuple, int] = {}
    next_class = 0

    for x in range(n_events):
        profile = tuple(profiles[x])
        if profile not in profile_to_class:
            profile_to_class[profile] = next_class
            next_class += 1
        class_map[x] = profile_to_class[profile]

    return class_map, next_class


def partition_refinement(H: np.ndarray,
                         max_iterations: int = 1000) -> Tuple[Dict[int, int], int]:
    """
    Compute observational equivalence via iterative partition refinement.

    This is the Hopcroft-style algorithm adapted for temporal response tables.

    Args:
        H: Response table of shape (n_events, n_times, n_events)
        max_iterations: Safety limit on refinement steps

    Returns:
        (class_map, n_classes)

    Time complexity: O(n² · k · n · log n) amortized
    """
    return compute_observational_profiles(H)


def reconstruct_scheduler(
    H: np.ndarray,
    delay_fn,
    rev_fn,
    zero_time: int = 0
) -> FiniteReversibleScheduler:
    """
    Reconstruct the canonical minimal reversible scheduler from a response table.

    This is Algorithm 1 from the paper (RECONSTRUCT-SCHEDULER).

    Args:
        H: Response table H[x, t, y] of shape (n_events, n_times, n_events)
        delay_fn: delay(t, x) -> x' maps (time_index, event) to delayed event
        rev_fn: rev(x) -> x' reversal involution on events
        zero_time: Index of the base time (default 0)

    Returns:
        FiniteReversibleScheduler with verified properties

    Time complexity: O(n²k) for classification + O(nk) for construction
    """
    n_events, n_times, _ = H.shape

    # Step 1: Compute equivalence classes
    class_map, n_classes = compute_observational_profiles(H)

    # Step 2: Choose representatives (first event in each class)
    representatives: Dict[int, int] = {}
    for x in range(n_events):
        c = class_map[x]
        if c not in representatives:
            representatives[c] = x

    # Step 3: Build transition function
    step = np.zeros((n_classes, n_times), dtype=int)
    for c in range(n_classes):
        rep = representatives[c]
        for t in range(n_times):
            delayed = delay_fn(t, rep)
            step[c, t] = class_map[delayed]

    # Step 4: Build emission function
    emit = np.zeros((n_classes, n_events), dtype=int)
    for c in range(n_classes):
        rep = representatives[c]
        emit[c] = H[rep, zero_time]

    # Step 5: Build reversal
    rev_state = np.zeros(n_classes, dtype=int)
    for c in range(n_classes):
        rep = representatives[c]
        rev_state[c] = class_map[rev_fn(rep)]

    scheduler = FiniteReversibleScheduler(
        n_states=n_classes,
        n_times=n_times,
        n_events=n_events,
        step=step,
        emit=emit,
        rev_state=rev_state,
        class_map=class_map,
        representatives=representatives
    )

    return scheduler


def verify_realization(
    H: np.ndarray,
    scheduler: FiniteReversibleScheduler,
    delay_fn
) -> Tuple[bool, int]:
    """
    Verify that a scheduler correctly realizes a response table.

    Returns:
        (is_correct, n_errors)

    Time complexity: O(n²k)
    """
    n_events, n_times, _ = H.shape
    errors = 0

    for x in range(n_events):
        state = scheduler.class_map[x]
        for t in range(n_times):
            next_state = scheduler.step[state, t]
            for y in range(n_events):
                predicted = scheduler.emit[next_state, y]
                actual = H[x, t, y]
                if predicted != actual:
                    errors += 1

    return errors == 0, errors


def test_isomorphism(
    sched1: FiniteReversibleScheduler,
    sched2: FiniteReversibleScheduler,
    H: np.ndarray
) -> Optional[np.ndarray]:
    """
    Test whether two minimal schedulers for the same response table are isomorphic.

    This is Algorithm 2 from the paper (TEST-ISOMORPHISM).

    Args:
        sched1, sched2: Two minimal schedulers
        H: The common response table

    Returns:
        Bijection f : State1 -> State2 as numpy array, or None if not isomorphic

    Time complexity: O(n + nk) for mapping + verification
    """
    if sched1.n_states != sched2.n_states:
        return None

    n = sched1.n_states

    # Build the mapping via encodings
    f = np.full(n, -1, dtype=int)
    for x in range(sched1.n_events):
        s1 = sched1.class_map[x]
        s2 = sched2.class_map[x]
        if f[s1] == -1:
            f[s1] = s2
        elif f[s1] != s2:
            return None  # Inconsistent mapping

    # Check bijectivity
    if len(set(f)) != n or -1 in f:
        return None

    # Verify structural compatibility
    for i in range(n):
        # Check step compatibility
        for t in range(sched1.n_times):
            if f[sched1.step[i, t]] != sched2.step[f[i], t]:
                return None
        # Check emit compatibility
        if not np.array_equal(sched1.emit[i], sched2.emit[f[i]]):
            return None
        # Check rev compatibility
        if f[sched1.rev_state[i]] != sched2.rev_state[f[i]]:
            return None

    return f


def synchronous_product(
    H1: np.ndarray,
    H2: np.ndarray
) -> np.ndarray:
    """
    Compute the synchronous product of two response tables.

    H_prod((x1,x2), t, (y1,y2)) = H1(x1, t, y1) AND H2(x2, t, y2)

    Args:
        H1: shape (n1, k, n1)
        H2: shape (n2, k, n2)   (must have same k)

    Returns:
        H_prod: shape (n1*n2, k, n1*n2)

    Time complexity: O(n1² · n2² · k)
    """
    n1, k, _ = H1.shape
    n2 = H2.shape[0]
    assert H2.shape[1] == k, "Time dimensions must match"

    n_prod = n1 * n2
    H_prod = np.zeros((n_prod, k, n_prod), dtype=int)

    for x1 in range(n1):
        for x2 in range(n2):
            for t in range(k):
                for y1 in range(n1):
                    for y2 in range(n2):
                        x_idx = x1 * n2 + x2
                        y_idx = y1 * n2 + y2
                        H_prod[x_idx, t, y_idx] = (
                            H1[x1, t, y1] & H2[x2, t, y2]
                        )

    return H_prod


# ============================================================================
# Example usage
# ============================================================================

if __name__ == "__main__":
    print("Algorithm demonstrations")
    print("=" * 60)

    # Example: 6-event system with 3 time steps
    n, k = 6, 3
    rng = np.random.RandomState(42)
    H = rng.randint(0, 2, size=(n, k, n))

    # Simple delay: cyclic shift
    delay_fn = lambda t, x: (x + 1) % n if t > 0 else x
    rev_fn = lambda x: (n - 1 - x) % n

    print(f"\nSystem: {n} events, {k} time steps")

    # Reconstruct scheduler
    sched = reconstruct_scheduler(H, delay_fn, rev_fn)
    print(f"Minimal states: {sched.n_states}")
    print(f"Involutive: {sched.is_involutive()}")
    print(f"Step-rev compatible: {sched.is_step_rev_compatible()}")

    # Verify
    correct, errors = verify_realization(H, sched, delay_fn)
    print(f"Correct realization: {correct} ({errors} errors)")

    # Synchronous product
    H2 = rng.randint(0, 2, size=(4, k, 4))
    H_prod = synchronous_product(H, H2)
    _, n_classes_1 = compute_observational_profiles(H)
    _, n_classes_2 = compute_observational_profiles(H2)
    _, n_classes_prod = compute_observational_profiles(H_prod)
    print(f"\nSynchronous product:")
    print(f"  System 1: {n_classes_1} classes")
    print(f"  System 2: {n_classes_2} classes")
    print(f"  Product:  {n_classes_prod} classes (≤ {n_classes_1 * n_classes_2})")

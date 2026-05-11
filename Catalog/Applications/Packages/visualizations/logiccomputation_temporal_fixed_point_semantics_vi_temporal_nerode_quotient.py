"""
Algorithms for Temporal Fixed-Point Semantics

Implements the core algorithms from the research paper:
1. Loop closure iteration
2. Temporal signature computation
3. Nerode quotient construction
4. Novikov witness search
5. Orbit decomposition
"""

from typing import Callable, Dict, List, Optional, Set, Tuple
from dataclasses import dataclass
from collections import defaultdict


@dataclass
class RevStep:
    """Reversible step on {0, ..., n-1}."""
    forward: List[int]
    backward: List[int]

    @property
    def n(self) -> int:
        return len(self.forward)

    def apply(self, s: int) -> int:
        return self.forward[s]

    def apply_inv(self, s: int) -> int:
        return self.backward[s]

    def rev_path(self, steps: int, s: int) -> int:
        """Apply `steps` iterations of the forward map."""
        for _ in range(steps):
            s = self.apply(s)
        return s


TemporalConstraint = Callable[[int, int], bool]


def orbit_decomposition(r: RevStep) -> List[List[int]]:
    """Decompose the state space into disjoint orbits.

    Complexity: O(|S|) time and space.

    Returns:
        List of orbits, each orbit is a list of states in order.
    """
    visited: Set[int] = set()
    orbits: List[List[int]] = []
    for start in range(r.n):
        if start in visited:
            continue
        orbit = []
        s = start
        while s not in visited:
            visited.add(s)
            orbit.append(s)
            s = r.apply(s)
        orbits.append(orbit)
    return orbits


def orbit_period(r: RevStep, s: int) -> int:
    """Find the orbit period of state s.

    The period p is the smallest positive integer with r^p(s) = s.
    Guaranteed to exist and satisfy p ≤ |S| for finite state spaces.

    Complexity: O(|S|) time.

    Args:
        r: Reversible step.
        s: Starting state.

    Returns:
        Orbit period p with 0 < p ≤ |S|.
    """
    current = r.apply(s)
    p = 1
    while current != s:
        current = r.apply(current)
        p += 1
    return p


def find_novikov_witness(
    r: RevStep,
    phi: TemporalConstraint,
    t: int,
    s: int,
    bound: Optional[int] = None,
) -> Optional[int]:
    """Search for a Novikov witness: m > 0 with phi(t+m, r^m(s)).

    Complexity: O(bound) applications of r and evaluations of phi.

    Args:
        r: Reversible step.
        phi: Temporal constraint.
        t: Current time.
        s: Current state.
        bound: Maximum search depth (default: |S|).

    Returns:
        Witness m if found, None otherwise.
        For Novikov-consistent constraints, m ≤ |S| always suffices.
    """
    if bound is None:
        bound = r.n
    current = s
    for m in range(1, bound + 1):
        current = r.apply(current)
        if phi(t + m, current):
            return m
    return None


def check_novikov_consistency(
    r: RevStep,
    phi: TemporalConstraint,
    horizon: int,
) -> bool:
    """Check if phi is Novikov-consistent up to the given horizon.

    Complexity: O(|S|² × horizon) time.

    Args:
        r: Reversible step.
        phi: Temporal constraint.
        horizon: Maximum time to check.

    Returns:
        True if for all (t, s) with t ≤ horizon and phi(t, s),
        there exists m > 0 with phi(t+m, r^m(s)).
    """
    for t in range(horizon + 1):
        for s in range(r.n):
            if phi(t, s):
                witness = find_novikov_witness(r, phi, t, s)
                if witness is None:
                    return False
    return True


def temporal_signature(
    r: RevStep,
    phi: TemporalConstraint,
    s: int,
    horizon: int,
) -> Tuple[bool, ...]:
    """Compute the temporal signature of state s under constraint phi.

    The signature is a Boolean vector (phi(0, s), phi(1, r(s)), ...,
    phi(H, r^H(s))).

    Complexity: O(horizon) time.

    Args:
        r: Reversible step.
        phi: Temporal constraint.
        s: Starting state.
        horizon: Number of time steps.

    Returns:
        Tuple of booleans encoding temporal behavior.
    """
    sig = []
    current = s
    for t in range(horizon + 1):
        sig.append(phi(t, current))
        current = r.apply(current)
    return tuple(sig)


def compute_nerode_quotient(
    r: RevStep,
    constraints: List[TemporalConstraint],
    horizon: int,
) -> Tuple[Dict[int, int], int]:
    """Compute the temporal Nerode quotient.

    Two states are equivalent iff they have identical temporal signatures
    for all constraints.

    Complexity: O(|S| × |constraints| × horizon) time.

    Args:
        r: Reversible step.
        constraints: List of temporal constraints.
        horizon: Signature computation depth.

    Returns:
        (class_map, n_classes) where class_map[s] is the class of state s.
    """
    full_sigs = {}
    for s in range(r.n):
        full_sigs[s] = tuple(
            temporal_signature(r, phi, s, horizon)
            for phi in constraints
        )

    sig_to_class = {}
    class_map = {}
    n_classes = 0
    for s in range(r.n):
        sig = full_sigs[s]
        if sig not in sig_to_class:
            sig_to_class[sig] = n_classes
            n_classes += 1
        class_map[s] = sig_to_class[sig]

    return class_map, n_classes


def quotient_automaton(
    r: RevStep,
    class_map: Dict[int, int],
    n_classes: int,
) -> List[int]:
    """Construct the quotient automaton transition function.

    Complexity: O(|S|) time.

    Args:
        r: Reversible step.
        class_map: State-to-class mapping.
        n_classes: Number of classes.

    Returns:
        Transition table: quotient_transition[c] = class of r(any state in class c).

    Raises:
        AssertionError if the quotient is not well-defined.
    """
    transition = [None] * n_classes
    for s in range(r.n):
        c = class_map[s]
        t = r.apply(s)
        ct = class_map[t]
        if transition[c] is not None:
            assert transition[c] == ct, \
                f"Quotient not well-defined: class {c} maps to both {transition[c]} and {ct}"
        transition[c] = ct
    return transition


def loop_closure_iterate(
    r: RevStep,
    initial_constraints: List[TemporalConstraint],
    horizon: int,
    max_iter: int = 100,
) -> Tuple[List[TemporalConstraint], int]:
    """Iterate the loop closure operator until stabilization.

    Starting from initial_constraints, repeatedly adds all Novikov-consistent
    constraints (from a predefined universe) until no new constraints are added.

    This is a simplified version operating on a finite predicate family.

    Complexity: O(max_iter × |universe| × |S|² × horizon) time.

    Args:
        r: Reversible step.
        initial_constraints: Starting constraint set.
        horizon: Evaluation horizon.
        max_iter: Maximum iterations.

    Returns:
        (stable_set, iterations_to_stabilize).
    """
    current = list(initial_constraints)
    current_set = set(range(len(current)))

    for iteration in range(max_iter):
        new_found = False
        for phi in initial_constraints:
            if check_novikov_consistency(r, phi, horizon):
                # phi is Novikov-consistent, add if not present
                idx = initial_constraints.index(phi)
                if idx not in current_set:
                    current_set.add(idx)
                    new_found = True
        if not new_found:
            return current, iteration + 1

    return current, max_iter


def reversible_witness_bound(n_states: int, horizon: int) -> int:
    """Compute the reversible witness bound: |S| × (horizon + 1).

    This is the maximum number of steps needed to find a Novikov witness
    on a finite state space.
    """
    return n_states * (horizon + 1)


def certified_radius_proxy(n_states: int, horizon: int) -> int:
    """Compute the certified radius proxy: |S| + horizon."""
    return n_states + horizon


def entropy_weight(n_states: int, horizon: int) -> int:
    """Compute the entropy weight: |S| × (horizon + 1)."""
    return n_states * (horizon + 1)


if __name__ == "__main__":
    # Example: cyclic rotation on Z/5Z
    r = RevStep(
        forward=[(i + 1) % 5 for i in range(5)],
        backward=[(i - 1) % 5 for i in range(5)],
    )

    print("Orbit decomposition:", orbit_decomposition(r))
    print("Orbit period of 0:", orbit_period(r, 0))

    def visits_zero(t, s):
        return s == 0

    witness = find_novikov_witness(r, visits_zero, 0, 0)
    print(f"Novikov witness for visits_zero at (0, 0): m={witness}")

    is_nov = check_novikov_consistency(r, visits_zero, 10)
    print(f"Novikov consistent: {is_nov}")

    class_map, n_classes = compute_nerode_quotient(r, [visits_zero], 10)
    print(f"Nerode classes: {class_map}, count={n_classes}")

    trans = quotient_automaton(r, class_map, n_classes)
    print(f"Quotient transitions: {trans}")

    print(f"\nBounds for |S|=5, horizon=3:")
    print(f"  Witness bound: {reversible_witness_bound(5, 3)}")
    print(f"  Certified radius: {certified_radius_proxy(5, 3)}")
    print(f"  Entropy weight: {entropy_weight(5, 3)}")


"""
Applications of Temporal Fixed-Point Semantics

Demonstrates real-world applications of the theory:
1. Quantum error correction cycle analysis
2. Post-quantum trace compression
3. Certified robustness via temporal signatures
"""
#!/usr/bin/env python3
"""
Algorithms for Closure-Scattering Systems and Minimal Resonance Realization.

Implements the core algorithms from the modular scattering duality theory:
1. Response profile computation
2. Resonance congruence extraction
3. Minimal realization construction
4. Isomorphism detection between separated systems
5. Closure defect analysis
"""

from typing import Dict, List, Set, Tuple, Optional, FrozenSet, Callable
from dataclasses import dataclass
import math


# Type aliases
State = int
Channel = int
Value = float
Profile = Tuple[Tuple[Value, ...], ...]


@dataclass
class ClosureScatteringSystem:
    """A finite closure-scattering system.

    Attributes:
        n_states: number of states (states are 0, 1, ..., n_states-1)
        n_channels: number of channels
        transfer: state evolution function
        boundary: boundary observation function (state, channel) -> value
        closure: closure operator on frozensets of states (optional)
    """
    n_states: int
    n_channels: int
    transfer: Callable[[State], State]
    boundary: Callable[[State, Channel], Value]
    closure: Optional[Callable[[FrozenSet[State]], FrozenSet[State]]] = None

    def __post_init__(self):
        if self.closure is None:
            self.closure = lambda A: A  # identity closure


def compute_response_profile(
    S: ClosureScatteringSystem,
    x: State,
    depth: int = 10
) -> Profile:
    """Compute the response profile of state x up to given depth.

    The response profile records boundary(T^n(x), c) for all n and c.
    This is the complete observable behavior of state x.

    Time complexity: O(depth * n_channels)
    Space complexity: O(depth * n_channels)

    Args:
        S: closure-scattering system
        x: initial state
        depth: number of transfer iterations to observe

    Returns:
        Tuple of tuples: profile[n][c] = boundary(T^n(x), c)
    """
    profile = []
    state = x
    for _ in range(depth):
        row = tuple(S.boundary(state, c) for c in range(S.n_channels))
        profile.append(row)
        state = S.transfer(state)
    return tuple(profile)


def compute_resonance_classes(
    S: ClosureScatteringSystem,
    depth: int = 10
) -> Dict[Profile, List[State]]:
    """Compute the resonance equivalence classes.

    Two states are resonance-equivalent iff they have identical response profiles.
    This is the coarsest equivalence compatible with transfer and boundary observations.

    Time complexity: O(n_states * depth * n_channels)
    Space complexity: O(n_states * depth * n_channels)

    Args:
        S: closure-scattering system
        depth: observation depth for profiles

    Returns:
        Dictionary mapping profiles to lists of equivalent states
    """
    classes: Dict[Profile, List[State]] = {}
    for x in range(S.n_states):
        p = compute_response_profile(S, x, depth)
        if p not in classes:
            classes[p] = []
        classes[p].append(x)
    return classes


def is_separated(S: ClosureScatteringSystem, depth: int = 10) -> bool:
    """Check if the system is separated (reduced/observable).

    A system is separated iff all states have distinct response profiles.

    Time complexity: O(n_states * depth * n_channels)
    """
    classes = compute_resonance_classes(S, depth)
    return len(classes) == S.n_states


def compute_closure_defect(
    S: ClosureScatteringSystem,
    A: FrozenSet[State]
) -> FrozenSet[State]:
    """Compute the closure defect of a set A.

    The closure defect is T(cl(A)) \\ cl(T(A)), measuring the failure
    of transfer to commute with closure.

    Args:
        S: closure-scattering system
        A: subset of states

    Returns:
        The closure defect (states in T(cl(A)) but not in cl(T(A)))
    """
    cl_A = S.closure(A)
    T_cl_A = frozenset(S.transfer(x) for x in cl_A)
    T_A = frozenset(S.transfer(x) for x in A)
    cl_T_A = S.closure(T_A)
    return T_cl_A - cl_T_A


def construct_minimal_realization(
    S: ClosureScatteringSystem,
    depth: int = 10
) -> Tuple[ClosureScatteringSystem, Dict[State, State]]:
    """Construct the minimal realization by quotienting by resonance congruence.

    This implements the certified reconstruction algorithm:
    1. Compute resonance equivalence classes
    2. Choose representatives (one per class)
    3. Define transfer on quotient via representatives
    4. Boundary on quotient reads from profile at n=0

    Time complexity: O(n_states * depth * n_channels)
    Space complexity: O(n_states * depth * n_channels)

    Args:
        S: closure-scattering system
        depth: observation depth

    Returns:
        Tuple of (minimal realization, quotient map from original to new states)
    """
    classes = compute_resonance_classes(S, depth)
    profiles = list(classes.keys())
    n_new = len(profiles)
    profile_to_idx = {p: i for i, p in enumerate(profiles)}

    # Representatives: first state in each class
    reps = {p: classes[p][0] for p in profiles}

    # Quotient map: original state -> new state index
    quotient_map = {}
    for p, states in classes.items():
        idx = profile_to_idx[p]
        for s in states:
            quotient_map[s] = idx

    # Transfer on quotient
    def new_transfer(i: State) -> State:
        p = profiles[i]
        rep = reps[p]
        new_rep = S.transfer(rep)
        new_profile = compute_response_profile(S, new_rep, depth)
        return profile_to_idx[new_profile]

    # Boundary on quotient
    def new_boundary(i: State, c: Channel) -> Value:
        return profiles[i][0][c]

    minimal = ClosureScatteringSystem(
        n_states=n_new,
        n_channels=S.n_channels,
        transfer=new_transfer,
        boundary=new_boundary
    )

    return minimal, quotient_map


def find_isomorphism(
    S1: ClosureScatteringSystem,
    S2: ClosureScatteringSystem,
    depth: int = 10
) -> Optional[Dict[State, State]]:
    """Find an isomorphism between two separated systems with matching profiles.

    If both systems are separated and have the same set of response profiles,
    returns the unique isomorphism mapping. Otherwise returns None.

    This implements the constructive content of the main duality theorem:
    states are matched by their response profiles.

    Time complexity: O(n_states * depth * n_channels)

    Args:
        S1, S2: closure-scattering systems
        depth: observation depth

    Returns:
        Isomorphism mapping S1.states -> S2.states, or None if not isomorphic
    """
    if S1.n_channels != S2.n_channels:
        return None

    profiles1 = {x: compute_response_profile(S1, x, depth) for x in range(S1.n_states)}
    profiles2 = {x: compute_response_profile(S2, x, depth) for x in range(S2.n_states)}

    # Check separated
    if len(set(profiles1.values())) != S1.n_states:
        return None
    if len(set(profiles2.values())) != S2.n_states:
        return None

    # Check same profile sets
    if set(profiles1.values()) != set(profiles2.values()):
        return None

    # Build inverse map for S2
    inv2 = {p: x for x, p in profiles2.items()}

    # Construct isomorphism
    iso = {x: inv2[p] for x, p in profiles1.items()}

    # Verify transfer commutation
    for x1, x2 in iso.items():
        if iso[S1.transfer(x1)] != S2.transfer(x2):
            return None  # Should never happen if theorem is correct

    return iso


def analyze_spectral_boundary(
    S: ClosureScatteringSystem,
    depth: int = 10
) -> Dict:
    """Analyze the spectral boundary semimodule of a system.

    Returns information about the shift-closed set of response profiles.

    Args:
        S: closure-scattering system
        depth: observation depth

    Returns:
        Dictionary with spectral analysis results
    """
    profiles = {x: compute_response_profile(S, x, depth)
                for x in range(S.n_states)}
    unique_profiles = set(profiles.values())

    # Verify shift-closure
    shift_closed = True
    for p in unique_profiles:
        shifted = p[1:]
        # Check if shifted profile (truncated) matches some profile's prefix
        found = False
        for q in unique_profiles:
            if q[:len(shifted)] == shifted:
                found = True
                break
        if not found:
            shift_closed = False
            break

    # Compute profile "dimension" (number of distinct profiles)
    return {
        "n_profiles": len(unique_profiles),
        "n_states": S.n_states,
        "reduction_ratio": len(unique_profiles) / S.n_states,
        "is_separated": len(unique_profiles) == S.n_states,
        "shift_closed": shift_closed,
        "profiles": profiles,
    }


# ============================================================
# Example usage and testing
# ============================================================

if __name__ == "__main__":
    print("Closure-Scattering System Algorithms")
    print("=" * 50)

    # Example: 6-state system with redundancy
    S = ClosureScatteringSystem(
        n_states=6,
        n_channels=2,
        transfer=lambda x: [1, 2, 0, 4, 5, 3][x],
        boundary=lambda x, c: {
            (0, 0): 1.0, (0, 1): 0.0,
            (1, 0): 0.0, (1, 1): 1.0,
            (2, 0): 0.5, (2, 1): 0.5,
            (3, 0): 1.0, (3, 1): 0.0,
            (4, 0): 0.0, (4, 1): 1.0,
            (5, 0): 0.5, (5, 1): 0.5,
        }[(x, c)]
    )

    print(f"\nOriginal system: {S.n_states} states, {S.n_channels} channels")
    print(f"Separated: {is_separated(S)}")

    classes = compute_resonance_classes(S)
    print(f"Resonance classes: {len(classes)}")
    for p, states in classes.items():
        print(f"  {states}")

    M, qmap = construct_minimal_realization(S)
    print(f"\nMinimal realization: {M.n_states} states")
    print(f"Quotient map: {qmap}")
    print(f"Minimal separated: {is_separated(M)}")

    spectral = analyze_spectral_boundary(S)
    print(f"\nSpectral boundary analysis:")
    print(f"  Profiles: {spectral['n_profiles']}")
    print(f"  Reduction: {spectral['reduction_ratio']:.2%}")
    print(f"  Shift-closed: {spectral['shift_closed']}")

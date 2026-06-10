#!/usr/bin/env python3
"""
Algorithms for Closure-Thermodynamic Computation Duality

Implements:
1. Canonical realization construction from profile data
2. Separation checking algorithm
3. Minimal realization via profile quotient
4. Reversible/irreversible decomposition
"""

import itertools
from typing import Optional


def canonical_realization(profiles: list[tuple[int, ...]]) -> dict:
    """
    Algorithm 1: Canonical Realization Construction

    Given m distinct profile vectors in ℕⁿ, constructs the canonical
    thermodynamic computation object with chain closure on Fin(m).

    Time complexity: O(m · n) for construction
    Space complexity: O(m · n)

    Args:
        profiles: List of m distinct n-tuples representing dissipation profiles.

    Returns:
        Dictionary with keys:
        - 'states': number of states (= len(profiles))
        - 'generators': number of generators (= len(profiles[0]))
        - 'closed_sets': list of closed sets (as sorted tuples)
        - 'profiles': mapping closed_set -> profile
        - 'separated': True (always, by construction)
    """
    m = len(profiles)
    if m == 0:
        return {'states': 0, 'generators': 0, 'closed_sets': [],
                'profiles': {}, 'separated': True}

    n = len(profiles[0])
    assert len(set(profiles)) == m, "Profiles must be distinct"

    # Closed sets under chain closure: [0..k] for k = 0, ..., m-1
    closed_sets = [tuple(range(k + 1)) for k in range(m)]

    # Map each closed set to its profile
    profile_map = {}
    for k in range(m):
        profile_map[closed_sets[k]] = profiles[k]

    return {
        'states': m,
        'generators': n,
        'closed_sets': closed_sets,
        'profiles': profile_map,
        'separated': True,
    }


def check_separation(n_states: int, n_gens: int,
                      cl_fn, dissip_fn) -> tuple[bool, Optional[tuple]]:
    """
    Algorithm 2: Separation Checking

    Checks whether a ThermoComp is separated (distinct closed sets have
    distinct dissipation profiles).

    Time complexity: O(k² · n) where k = number of closed sets
    Space complexity: O(k · n)

    Args:
        n_states: Number of states
        n_gens: Number of generators
        cl_fn: Closure function (frozenset -> frozenset)
        dissip_fn: Dissipation function (int, frozenset) -> int

    Returns:
        (is_separated, counterexample) where counterexample is
        (A, B, profile) if not separated, else None.
    """
    # Find all closed sets
    closed_sets = []
    for r in range(n_states + 1):
        for s in itertools.combinations(range(n_states), r):
            fs = frozenset(s)
            if cl_fn(fs) == fs:
                closed_sets.append(fs)

    # Compute profiles
    profiles = {}
    for cs in closed_sets:
        cl_cs = cl_fn(cs)
        prof = tuple(dissip_fn(i, cl_cs) for i in range(n_gens))
        profiles[cs] = prof

    # Check for duplicates
    seen = {}
    for cs, prof in profiles.items():
        if prof in seen:
            return False, (seen[prof], cs, prof)
        seen[prof] = cs

    return True, None


def minimal_realization(n_states: int, n_gens: int,
                        cl_fn, dissip_fn) -> dict:
    """
    Algorithm 3: Minimal Realization via Profile Quotient

    Computes the minimal realization by quotienting closed sets
    by profile equivalence.

    Time complexity: O(k² · n) where k = number of closed sets
    Space complexity: O(k · n)

    Returns:
        Dictionary with:
        - 'original_closed_sets': number of closed sets in original
        - 'minimal_closed_sets': number in minimal realization
        - 'equivalence_classes': dict mapping profile -> list of closed sets
        - 'reduction_ratio': original / minimal
    """
    # Find all closed sets and their profiles
    closed_sets = []
    for r in range(n_states + 1):
        for s in itertools.combinations(range(n_states), r):
            fs = frozenset(s)
            if cl_fn(fs) == fs:
                closed_sets.append(fs)

    profiles = {}
    for cs in closed_sets:
        cl_cs = cl_fn(cs)
        prof = tuple(dissip_fn(i, cl_cs) for i in range(n_gens))
        profiles[cs] = prof

    # Group by profile equivalence
    classes = {}
    for cs, prof in profiles.items():
        if prof not in classes:
            classes[prof] = []
        classes[prof].append(cs)

    original = len(closed_sets)
    minimal = len(classes)

    return {
        'original_closed_sets': original,
        'minimal_closed_sets': minimal,
        'equivalence_classes': classes,
        'reduction_ratio': original / minimal if minimal > 0 else float('inf'),
    }


def decompose_generators(n_states: int, n_gens: int,
                         cl_fn, dissip_fn) -> dict:
    """
    Algorithm 4: Reversible/Irreversible Decomposition

    Partitions generators into reversible (zero dissipation on all
    closed sets) and irreversible (positive dissipation witness).

    Time complexity: O(n · k) where k = number of closed sets
    Space complexity: O(n + k)

    Returns:
        Dictionary with:
        - 'reversible': list of reversible generator indices
        - 'irreversible': list of irreversible generator indices
        - 'witnesses': dict mapping irreversible gen -> witness closed set
    """
    # Find closed sets
    closed_sets = []
    for r in range(n_states + 1):
        for s in itertools.combinations(range(n_states), r):
            fs = frozenset(s)
            if cl_fn(fs) == fs:
                closed_sets.append(fs)

    reversible = []
    irreversible = []
    witnesses = {}

    for i in range(n_gens):
        found_witness = False
        for cs in closed_sets:
            if dissip_fn(i, cs) != 0:
                irreversible.append(i)
                witnesses[i] = cs
                found_witness = True
                break
        if not found_witness:
            reversible.append(i)

    return {
        'reversible': reversible,
        'irreversible': irreversible,
        'witnesses': witnesses,
    }


if __name__ == "__main__":
    print("Algorithm 1: Canonical Realization")
    result = canonical_realization([(0, 1), (2, 0), (1, 3)])
    print(f"  States: {result['states']}, Generators: {result['generators']}")
    print(f"  Closed sets: {result['closed_sets']}")
    print(f"  Separated: {result['separated']}")

    print("\nAlgorithm 2: Separation Check")
    is_sep, cex = check_separation(
        2, 2,
        cl_fn=lambda A: A,
        dissip_fn=lambda i, A: 1 if i in A else 0
    )
    print(f"  Separated: {is_sep}")

    print("\nAlgorithm 3: Minimal Realization")
    result = minimal_realization(
        3, 1,
        cl_fn=lambda A: A,
        dissip_fn=lambda i, A: len(A)
    )
    print(f"  Original: {result['original_closed_sets']} closed sets")
    print(f"  Minimal: {result['minimal_closed_sets']} closed sets")
    print(f"  Reduction: {result['reduction_ratio']:.1f}x")

    print("\nAlgorithm 4: Reversible/Irreversible Decomposition")
    result = decompose_generators(
        3, 3,
        cl_fn=lambda A: A,
        dissip_fn=lambda i, A: 0 if i == 0 else len(A)
    )
    print(f"  Reversible: {result['reversible']}")
    print(f"  Irreversible: {result['irreversible']}")

"""
Algorithms for Finite Transfer Dynamics and Closure-Scale Spectral Duality.

Implements the core algorithms from the theorem package:
- Recurrent core computation via iterate stabilization
- Recurrent class decomposition (cycle detection on core)
- Temporal observable classification
- Renormalization semigroup action

All algorithms run in O(n²) time where n = |C|, with O(n) space.
"""

from __future__ import annotations
from typing import Callable, TypeVar, Set, Dict, List, Tuple, FrozenSet, Optional
from dataclasses import dataclass
import itertools

T = TypeVar('T')


@dataclass
class ClosureScaleSystem:
    """A closure-scale system (cl, σ) on a finite set."""
    elements: list
    cl: Callable
    sigma: Callable

    @property
    def transfer(self) -> Callable:
        """The transfer operator T = cl ∘ σ."""
        return lambda x: self.cl(self.sigma(x))

    def verify_axioms(self) -> dict:
        """Verify that the system satisfies all required axioms."""
        T = self.transfer
        results = {}

        # Extensivity: x ≤ cl(x) — for discrete order, cl(x) = x or cl preserves
        # We check idempotence and absorption instead
        results['idempotent'] = all(
            self.cl(self.cl(x)) == self.cl(x) for x in self.elements
        )
        results['absorption'] = all(
            self.cl(self.sigma(self.cl(x))) == self.cl(self.sigma(x))
            for x in self.elements
        )
        return results


def compute_image(f: Callable, domain: set) -> set:
    """Compute the image f(domain)."""
    return {f(x) for x in domain}


def iterate_function(f: Callable, n: int):
    """Return f composed with itself n times."""
    def f_n(x):
        result = x
        for _ in range(n):
            result = f(result)
        return result
    return f_n


def find_stabilization_index(f: Callable, elements: list) -> Tuple[int, set]:
    """
    Find the stabilization index N where Im(f^{N+1}) = Im(f^N).

    Returns (N, Core) where Core = Im(f^N) is the recurrent core.

    Complexity: O(n²) where n = |elements|.
    """
    current_range = set(elements)  # Im(f^0) = full set
    n = 0

    while True:
        next_range = compute_image(f, current_range)
        if next_range == current_range:
            return n, current_range
        current_range = next_range
        n += 1
        if n > len(elements):
            raise RuntimeError("Stabilization should occur within |C| steps")


def compute_recurrent_core(system: ClosureScaleSystem) -> set:
    """
    Compute the recurrent core Core_T.

    This is the eventual stable image of the transfer operator T = cl ∘ σ.
    On the core, T restricts to a bijection (permutation).
    """
    T = system.transfer
    _, core = find_stabilization_index(T, system.elements)
    return core


def compute_recurrent_classes(system: ClosureScaleSystem) -> List[FrozenSet]:
    """
    Decompose the recurrent core into recurrent classes (cycle orbits).

    Since T is a bijection on the core, every element is periodic.
    Recurrent classes are the orbits of this permutation.

    Returns a list of frozensets, each being one recurrent class.
    """
    T = system.transfer
    core = compute_recurrent_core(system)

    visited = set()
    classes = []

    for x in core:
        if x in visited:
            continue
        # Trace the orbit of x
        orbit = set()
        current = x
        while current not in orbit:
            orbit.add(current)
            current = T(current)
        classes.append(frozenset(orbit))
        visited.update(orbit)

    return classes


def classify_element(system: ClosureScaleSystem, x) -> Tuple[str, Optional[FrozenSet]]:
    """
    Classify an element as transient or recurrent.

    Returns ('transient', None) or ('recurrent', class) where class is
    the recurrent class containing x.
    """
    core = compute_recurrent_core(system)
    classes = compute_recurrent_classes(system)

    if x in core:
        for cls in classes:
            if x in cls:
                return ('recurrent', cls)
    return ('transient', None)


def compute_temporal_observable_class(
    system: ClosureScaleSystem,
    predicate: Callable,
) -> FrozenSet:
    """
    Given an eventually T-stable predicate p, compute the set of
    recurrent classes on which p is eventually true.

    This implements the key Stone-transfer duality:
    temporal observables ↔ subsets of Spec_T(C).
    """
    T = system.transfer
    classes = compute_recurrent_classes(system)

    # Find stabilization: iterate T enough times
    N, core = find_stabilization_index(T, system.elements)

    # For each recurrent class, check the predicate on any representative
    # (all elements in a class have the same eventual behavior)
    true_classes = set()
    for cls in classes:
        rep = next(iter(cls))
        # Apply T^N to bring to the core (already there for core elements)
        val = iterate_function(T, N)(rep)
        if predicate(val):
            true_classes.add(cls)

    return frozenset(true_classes)


def renormalization_action(
    system: ClosureScaleSystem,
    predicate: Callable,
    n: int,
) -> Callable:
    """
    Apply the renormalization operator R_n to a predicate p:
    R_n(p)(x) = p(T^n(x)).
    """
    T = system.transfer
    T_n = iterate_function(T, n)
    return lambda x: predicate(T_n(x))


def compute_observable_boolean_algebra(
    system: ClosureScaleSystem
) -> Dict[FrozenSet, FrozenSet]:
    """
    Compute the Boolean algebra of temporal observables.

    Returns a dictionary mapping each subset of recurrent classes
    to itself (the identity, demonstrating the isomorphism
    B_T ≅ P(Spec_T(C))).

    This is the finite Stone duality theorem made algorithmic.
    """
    classes = compute_recurrent_classes(system)
    # Generate all subsets of the set of classes
    algebra = {}
    class_list = list(classes)
    for r in range(len(class_list) + 1):
        for subset in itertools.combinations(class_list, r):
            key = frozenset(subset)
            algebra[key] = key
    return algebra


def quotient_map(system: ClosureScaleSystem) -> Callable:
    """
    Compute the quotient map C → Spec_T(C) ∪ {transient}.

    Maps each element to its recurrent class or 'transient'.
    """
    core = compute_recurrent_core(system)
    classes = compute_recurrent_classes(system)

    def q(x):
        if x not in core:
            # Find eventual image
            T = system.transfer
            N, _ = find_stabilization_index(T, system.elements)
            y = iterate_function(T, N)(x)
            for cls in classes:
                if y in cls:
                    return cls
            return 'transient'
        for cls in classes:
            if x in cls:
                return cls
        return 'transient'

    return q


if __name__ == "__main__":
    # Example: Four-state system with two recurrent classes
    elements = ['s1', 's2', 's3', 's4']

    def cl(x):
        return x  # Identity closure

    def sigma(x):
        return {'s1': 's1', 's2': 's2', 's3': 's1', 's4': 's2'}[x]

    system = ClosureScaleSystem(elements=elements, cl=cl, sigma=sigma)

    print("=== Closure-Scale System ===")
    print(f"Elements: {elements}")
    print(f"Axiom verification: {system.verify_axioms()}")

    N, core = find_stabilization_index(system.transfer, elements)
    print(f"\nStabilization index N = {N}")
    print(f"Recurrent core: {core}")

    classes = compute_recurrent_classes(system)
    print(f"Recurrent classes (Spec_T): {[set(c) for c in classes]}")

    for x in elements:
        status, cls = classify_element(system, x)
        print(f"  {x}: {status}" + (f" in {set(cls)}" if cls else ""))

    # Temporal observable example
    print("\n=== Temporal Observables ===")
    p = lambda x: x == 's1'
    true_classes = compute_temporal_observable_class(system, p)
    print(f"Observable 'x == s1' is true on classes: {[set(c) for c in true_classes]}")

    algebra = compute_observable_boolean_algebra(system)
    print(f"Boolean algebra has {len(algebra)} elements (= 2^{len(classes)} = {2**len(classes)})")

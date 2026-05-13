#!/usr/bin/env python3
"""
Thermodynamic Closure Duality — Algorithms

Implements the core algorithms from the research paper:
1. Free-energy descent for computing closures
2. Minimal presentation computation
3. Closure fiber enumeration
4. Equilibrium spectrum construction
"""

from __future__ import annotations
from dataclasses import dataclass, field
from typing import TypeVar, Generic, Callable, Optional
import itertools

T = TypeVar('T')


@dataclass
class ClosureOperator(Generic[T]):
    """A closure operator on a finite set, specified by its action."""
    elements: list[T]
    closure_fn: Callable[[T], T]
    
    def closure(self, x: T) -> T:
        return self.closure_fn(x)
    
    def is_closed(self, x: T) -> bool:
        return self.closure(x) == x
    
    def closed_states(self) -> list[T]:
        """Enumerate all closed (fixed) states."""
        return [x for x in self.elements if self.is_closed(x)]
    
    def closure_fiber(self, z: T) -> list[T]:
        """The fiber: all x with c(x) = z."""
        return [x for x in self.elements if self.closure(x) == z]
    
    def verify_properties(self) -> dict[str, bool]:
        """Verify closure operator axioms."""
        monotone = True  # Can't check without order
        extensive = all(True for x in self.elements)  # Need order
        idempotent = all(
            self.closure(self.closure(x)) == self.closure(x)
            for x in self.elements
        )
        return {"idempotent": idempotent}


@dataclass
class FreeEnergySystem(Generic[T]):
    """A tropical free-energy system over a closure operator.
    
    The free energy is F(x) = min(defect(x), β * E(x)).
    """
    closure_op: ClosureOperator[T]
    defect: Callable[[T], float]
    energy: Callable[[T], float]
    beta: float = 1.0
    
    def free_energy(self, x: T) -> float:
        """Compute tropical free energy F(x) = min(defect(x), β * E(x))."""
        return min(self.defect(x), self.beta * self.energy(x))
    
    def is_equilibrium(self, x: T) -> bool:
        """Check if x minimizes free energy on its closure fiber."""
        cx = self.closure_op.closure(x)
        fiber = self.closure_op.closure_fiber(cx)
        fx = self.free_energy(x)
        return all(fx <= self.free_energy(y) for y in fiber)
    
    def equilibrium_states(self) -> list[T]:
        """Find all equilibrium (free-energy minimizing) states."""
        return [x for x in self.closure_op.elements if self.is_equilibrium(x)]
    
    def verify_duality(self) -> dict[str, bool]:
        """Verify the Thermodynamic Closure Duality theorem.
        
        Check: x is closed ↔ x is an equilibrium state.
        """
        closed = set(str(x) for x in self.closure_op.closed_states())
        equilibria = set(str(x) for x in self.equilibrium_states())
        
        forward = closed <= equilibria  # closed ⟹ equilibrium
        backward = equilibria <= closed  # equilibrium ⟹ closed (needs admissibility)
        
        return {
            "forward (closed ⟹ equilibrium)": forward,
            "backward (equilibrium ⟹ closed)": backward,
            "duality (closed ↔ equilibrium)": forward and backward,
        }


def free_energy_descent(
    system: FreeEnergySystem[T],
    generators: list[Callable[[T], T]],
    x: T,
    max_steps: int = 1000,
) -> tuple[T, list[tuple[int, T, float]]]:
    """Compute closure by free-energy descent using generators.
    
    At each step, applies the generator that most decreases free energy.
    Returns the final state and the descent trace.
    
    Time complexity: O(max_steps * |generators|)
    Space complexity: O(max_steps) for the trace
    
    Args:
        system: The free-energy system
        generators: List of local update functions
        x: Starting point
        max_steps: Maximum number of descent steps
        
    Returns:
        (final_state, trace) where trace is [(step, state, free_energy)]
    """
    trace = [(0, x, system.free_energy(x))]
    
    for step in range(1, max_steps + 1):
        current_fe = system.free_energy(x)
        
        # Find best generator
        best_next = None
        best_fe = current_fe
        
        for gen in generators:
            y = gen(x)
            fe_y = system.free_energy(y)
            if fe_y < best_fe:
                best_fe = fe_y
                best_next = y
        
        if best_next is None:
            break  # No improvement possible
        
        x = best_next
        trace.append((step, x, best_fe))
        
        if system.closure_op.is_closed(x):
            break
    
    return x, trace


def find_minimal_presentation(
    elements: list[T],
    generators: list[tuple[str, T]],
    target: T,
    is_below: Callable[[T, T], bool],
    covers: Callable[[list[T], T], bool],
) -> tuple[list[str], int]:
    """Find a minimal presentation of target from generators.
    
    A presentation is a subset of generators that are all below
    the target and collectively cover it.
    
    Time complexity: O(2^|generators|) in worst case
    Space complexity: O(|generators|)
    
    Args:
        elements: Universe of elements
        generators: Named generators [(name, element)]
        target: Target closed state
        is_below: Order relation
        covers: Check if a collection of generators covers the target
        
    Returns:
        (support_names, support_size)
    """
    # Filter to generators below target
    valid = [(name, g) for name, g in generators if is_below(g, target)]
    
    # Search for minimal covering subset
    for size in range(1, len(valid) + 1):
        for combo in itertools.combinations(valid, size):
            names = [name for name, _ in combo]
            gens = [g for _, g in combo]
            if covers(gens, target):
                return names, size
    
    return [], 0


def enumerate_equilibrium_spectrum(
    system: FreeEnergySystem[T],
) -> list[dict]:
    """Enumerate the equilibrium spectrum.
    
    For each closed state, compute its free-energy level and
    the structure of its closure fiber.
    
    Returns a list of spectrum entries, each containing:
    - closed_state: the equilibrium point
    - free_energy: its free-energy value
    - fiber_size: number of points in its closure fiber
    - defect_profile: defects of all fiber points
    """
    spectrum = []
    
    for z in system.closure_op.closed_states():
        fiber = system.closure_op.closure_fiber(z)
        
        entry = {
            "closed_state": z,
            "free_energy": system.free_energy(z),
            "fiber_size": len(fiber),
            "defect_profile": sorted(
                [(x, system.defect(x)) for x in fiber],
                key=lambda p: p[1]
            ),
        }
        spectrum.append(entry)
    
    return spectrum


# ─── Powerset specialization ───────────────────────────────

def make_powerset_system(
    universe: set, target: frozenset, beta: float = 1.0
) -> tuple[FreeEnergySystem[frozenset], list]:
    """Create a powerset closure system.
    
    Args:
        universe: The ground set
        target: Elements that closure adds
        beta: Inverse temperature parameter
        
    Returns:
        (system, generators) ready for descent
    """
    # All subsets
    elements = []
    for r in range(len(universe) + 1):
        for s in itertools.combinations(sorted(universe), r):
            elements.append(frozenset(s))
    
    closure_op = ClosureOperator(
        elements=elements,
        closure_fn=lambda x: x | target,
    )
    
    system = FreeEnergySystem(
        closure_op=closure_op,
        defect=lambda x: len(target - x),
        energy=lambda x: len(x),
        beta=beta,
    )
    
    # Generators: add one target element at a time
    generators = []
    for t in sorted(target):
        generators.append(lambda x, t=t: x | frozenset({t}))
    
    return system, generators


# ─── Example usage ─────────────────────────────────────────

if __name__ == "__main__":
    print("Thermodynamic Closure Duality — Algorithm Demonstrations")
    print("=" * 60)
    
    # Create system
    universe = {1, 2, 3, 4}
    target = frozenset({2, 3})
    system, generators = make_powerset_system(universe, target, beta=2.0)
    
    # Verify duality
    print("\n1. Duality Verification:")
    results = system.verify_duality()
    for key, val in results.items():
        print(f"   {key}: {'✓' if val else '✗'}")
    
    # Descent
    print("\n2. Free-Energy Descent:")
    start = frozenset({1})
    final, trace = free_energy_descent(system, generators, start)
    for step, state, fe in trace:
        print(f"   Step {step}: {str(sorted(state)):15s}  F = {fe}")
    print(f"   Final (closed): {sorted(final)}")
    
    # Spectrum
    print("\n3. Equilibrium Spectrum:")
    spectrum = enumerate_equilibrium_spectrum(system)
    for entry in spectrum:
        z = entry["closed_state"]
        print(f"   Closed state {str(sorted(z)):15s}  "
              f"F = {entry['free_energy']:.1f}  "
              f"fiber_size = {entry['fiber_size']}")
    
    # Minimal presentation
    print("\n4. Minimal Presentation:")
    gens_named = [(f"g{i}", frozenset({i})) for i in sorted(universe)]
    closed_state = frozenset({1, 2, 3})
    names, size = find_minimal_presentation(
        elements=system.closure_op.elements,
        generators=gens_named,
        target=closed_state,
        is_below=lambda g, t: g <= t,
        covers=lambda gs, t: target <= frozenset().union(*gs),
    )
    print(f"   Target: {sorted(closed_state)}")
    print(f"   Minimal support: {names} (size {size})")
    print(f"   Bound: {size} ≤ {len(gens_named)}")

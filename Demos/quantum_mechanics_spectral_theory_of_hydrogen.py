#!/usr/bin/env python3
"""Numerical demonstrations for the idealized hydrogen spectral model.

The script uses only Python's standard library. It illustrates bound-energy
convergence, azimuthal periodicity and the L_z eigenvalue identity, and the
bipartite structure of a finite dipole-transition graph.
"""

from __future__ import annotations

import cmath
import math
from collections import deque
from dataclasses import dataclass
from typing import Dict, Iterable, List, Optional, Set, Tuple


@dataclass(frozen=True, order=True)
class OrbitalState:
    """Orbital quantum numbers satisfying l >= 0 and |m| <= l."""

    l: int
    m: int

    def __post_init__(self) -> None:
        if self.l < 0 or abs(self.m) > self.l:
            raise ValueError("A state must satisfy l >= 0 and |m| <= l")

    @property
    def parity(self) -> int:
        """Return the orbital parity color l mod 2."""
        return self.l % 2


def bohr_energy(n: int) -> float:
    """Return E_n = -1/n^2 in Rydberg units."""
    if n <= 0:
        raise ValueError("The principal quantum number must be positive")
    return -1.0 / (n * n)


def bound_spectrum(count: int) -> List[float]:
    """Generate the first ``count`` bound-state energies."""
    if count <= 0:
        raise ValueError("count must be positive")
    return [bohr_energy(n) for n in range(1, count + 1)]


def azimuthal_mode(m: int, phi: float) -> complex:
    """Evaluate exp(i m phi)."""
    return cmath.exp(1j * m * phi)


def lz_action(m: int, phi: float) -> complex:
    """Evaluate -i times the analytic derivative of exp(i m phi)."""
    psi = azimuthal_mode(m, phi)
    derivative = 1j * m * psi
    return -1j * derivative


def dipole_allowed(a: OrbitalState, b: OrbitalState) -> bool:
    """Test Delta-l = +/-1 and |Delta-m| <= 1."""
    return abs(a.l - b.l) == 1 and abs(a.m - b.m) <= 1


def orbital_states(l_max: int) -> List[OrbitalState]:
    """Enumerate all (l,m) states with 0 <= l <= l_max."""
    if l_max < 0:
        raise ValueError("l_max must be nonnegative")
    return [OrbitalState(l, m) for l in range(l_max + 1) for m in range(-l, l + 1)]


def transition_graph(l_max: int) -> Dict[OrbitalState, Set[OrbitalState]]:
    """Construct the finite undirected dipole graph through l_max efficiently."""
    states = orbital_states(l_max)
    graph: Dict[OrbitalState, Set[OrbitalState]] = {state: set() for state in states}
    state_set = set(states)
    for state in states:
        next_l = state.l + 1
        if next_l > l_max:
            continue
        for delta_m in (-1, 0, 1):
            candidate = OrbitalState(next_l, state.m + delta_m)
            if candidate in state_set:
                graph[state].add(candidate)
                graph[candidate].add(state)
    return graph


def shortest_path(
    graph: Dict[OrbitalState, Set[OrbitalState]],
    start: OrbitalState,
    goal: OrbitalState,
) -> Optional[List[OrbitalState]]:
    """Return a shortest transition path using breadth-first search."""
    if start not in graph or goal not in graph:
        return None
    queue = deque([start])
    parent: Dict[OrbitalState, Optional[OrbitalState]] = {start: None}
    while queue:
        current = queue.popleft()
        if current == goal:
            path: List[OrbitalState] = []
            node: Optional[OrbitalState] = current
            while node is not None:
                path.append(node)
                node = parent[node]
            return list(reversed(path))
        for neighbor in sorted(graph[current]):
            if neighbor not in parent:
                parent[neighbor] = current
                queue.append(neighbor)
    return None


def verify_walk_parity(path: Iterable[OrbitalState]) -> bool:
    """Check (l_start + l_end) mod 2 = number_of_edges mod 2."""
    vertices = list(path)
    if not vertices:
        raise ValueError("A walk must contain at least one vertex")
    if any(not dipole_allowed(a, b) for a, b in zip(vertices, vertices[1:])):
        return False
    edge_count = len(vertices) - 1
    return (vertices[0].l + vertices[-1].l) % 2 == edge_count % 2


def demonstrate_spectrum(count: int = 12) -> None:
    """Print energies, gaps, and convergence diagnostics."""
    energies = bound_spectrum(count)
    print("BOUND SPECTRUM (Rydberg units)")
    print(" n             E_n          gap to next")
    for index, energy in enumerate(energies, start=1):
        gap = energies[index] - energy if index < count else float("nan")
        gap_text = f"{gap: .10f}" if index < count else "       --"
        print(f"{index:2d}  {energy: .10f}  {gap_text}")
    assert all(energy < 0.0 for energy in energies)
    assert all(a < b for a, b in zip(energies, energies[1:]))
    print(f"E_{count} is {abs(energies[-1]):.6g} below the threshold 0.\n")


def demonstrate_azimuthal_modes() -> None:
    """Numerically test periodicity and the L_z eigenvalue equation."""
    print("AZIMUTHAL MODES")
    phi = 0.731
    for m in (-3, -1, 0, 2, 5):
        psi = azimuthal_mode(m, phi)
        periodic_error = abs(azimuthal_mode(m, phi + 2.0 * math.pi) - psi)
        eigen_error = abs(lz_action(m, phi) - m * psi)
        print(
            f"m={m:2d}: psi={psi.real:+.6f}{psi.imag:+.6f}i, "
            f"periodicity error={periodic_error:.3e}, "
            f"eigenvalue error={eigen_error:.3e}"
        )
        assert periodic_error < 1e-12
        assert eigen_error < 1e-12
    print()


def demonstrate_transition_graph(l_max: int = 5) -> None:
    """Build a graph, verify bipartiteness, and inspect shortest paths."""
    graph = transition_graph(l_max)
    edge_count = sum(len(neighbors) for neighbors in graph.values()) // 2
    assert all(
        state.parity != neighbor.parity
        for state, neighbors in graph.items()
        for neighbor in neighbors
    )
    print("DIPOLE TRANSITION GRAPH")
    print(f"l_max={l_max}, vertices={len(graph)}, undirected edges={edge_count}")
    print("Every edge crosses from even l to odd l: verified.")

    examples: List[Tuple[OrbitalState, OrbitalState]] = [
        (OrbitalState(0, 0), OrbitalState(3, 1)),
        (OrbitalState(1, 0), OrbitalState(5, 0)),
        (OrbitalState(2, -1), OrbitalState(4, 1)),
    ]
    for start, goal in examples:
        path = shortest_path(graph, start, goal)
        if path is None:
            print(f"No route from {start} to {goal}.")
            continue
        edges = len(path) - 1
        assert verify_walk_parity(path)
        labels = " -> ".join(f"({state.l},{state.m})" for state in path)
        print(f"Shortest route ({edges} edges): {labels}")
        print(
            "  endpoint parity sum = "
            f"{(start.l + goal.l) % 2}, path-length parity = {edges % 2}"
        )
    print("The bipartite graph therefore contains no odd cycle.")


def main() -> None:
    """Run all numerical demonstrations."""
    demonstrate_spectrum()
    demonstrate_azimuthal_modes()
    demonstrate_transition_graph()


if __name__ == "__main__":
    main()

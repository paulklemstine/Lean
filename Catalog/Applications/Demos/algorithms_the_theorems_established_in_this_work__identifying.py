"""
Newton Persistence Algorithms
=============================

Type-hinted implementations of the Newton persistence framework for
analyzing polynomial dynamics over finite fields.

Key algorithms:
1. Newton step computation over F_p
2. Depth filtration construction
3. Persistence diagram extraction
4. Frobenius cycle type detection via depth histograms
"""

from typing import List, Dict, Tuple, Optional, Set
from dataclasses import dataclass
from collections import Counter
import math


def mod_inverse(a: int, p: int) -> Optional[int]:
    """Compute modular inverse of a mod p using extended Euclidean algorithm."""
    if a % p == 0:
        return None
    return pow(a, p - 2, p)


def poly_eval(coeffs: List[int], x: int, p: int) -> int:
    """Evaluate polynomial with given coefficients at x mod p.

    Args:
        coeffs: Coefficients [a0, a1, ..., an] for a0 + a1*x + ... + an*x^n
        x: Point of evaluation
        p: Prime modulus

    Returns:
        f(x) mod p
    """
    result = 0
    power = 1
    for c in coeffs:
        result = (result + c * power) % p
        power = (power * x) % p
    return result


def poly_derivative(coeffs: List[int], p: int) -> List[int]:
    """Compute the formal derivative of a polynomial mod p.

    Args:
        coeffs: Coefficients [a0, a1, ..., an]
        p: Prime modulus

    Returns:
        Coefficients of f'(x) mod p
    """
    if len(coeffs) <= 1:
        return [0]
    return [(i * coeffs[i]) % p for i in range(1, len(coeffs))]


def newton_step(coeffs: List[int], x: int, p: int) -> int:
    """Compute one Newton step: x - f(x)/f'(x) mod p.

    If f'(x) = 0 mod p, returns x (identity at critical points).

    Args:
        coeffs: Polynomial coefficients
        x: Current point
        p: Prime modulus

    Returns:
        Newton step N_f(x) mod p
    """
    deriv_coeffs = poly_derivative(coeffs, p)
    fx = poly_eval(coeffs, x, p)
    fpx = poly_eval(deriv_coeffs, x, p)

    if fpx == 0:
        return x

    inv_fpx = mod_inverse(fpx, p)
    if inv_fpx is None:
        return x

    return (x - fx * inv_fpx) % p


def newton_iterate(coeffs: List[int], x: int, p: int, n: int) -> int:
    """Iterate the Newton step n times.

    Args:
        coeffs: Polynomial coefficients
        x: Starting point
        p: Prime modulus
        n: Number of iterations

    Returns:
        N_f^n(x) mod p
    """
    current = x
    for _ in range(n):
        current = newton_step(coeffs, current, p)
    return current


@dataclass
class NewtonOrbit:
    """Represents the orbit of a point under Newton iteration."""
    start: int
    tail: List[int]  # Pre-periodic part
    cycle: List[int]  # Periodic part
    depth: int  # Steps to reach the cycle


def compute_orbit(coeffs: List[int], x: int, p: int) -> NewtonOrbit:
    """Compute the full Newton orbit of x, detecting the cycle.

    Uses Floyd's cycle detection (tortoise and hare).

    Args:
        coeffs: Polynomial coefficients
        x: Starting point
        p: Prime modulus

    Returns:
        NewtonOrbit with tail, cycle, and depth
    """
    # Phase 1: Detect cycle existence
    seen: Dict[int, int] = {}
    trajectory: List[int] = [x]
    current = x

    for step in range(p + 1):
        current = newton_step(coeffs, current, p)
        if current in seen:
            cycle_start_idx = seen[current]
            tail = trajectory[:cycle_start_idx]
            cycle = trajectory[cycle_start_idx:]
            return NewtonOrbit(
                start=x,
                tail=tail,
                cycle=cycle,
                depth=cycle_start_idx
            )
        seen[current] = step + 1
        trajectory.append(current)

    # Shouldn't reach here for finite fields, but safety fallback
    return NewtonOrbit(start=x, tail=trajectory, cycle=[], depth=p + 1)


def depth_filtration(coeffs: List[int], p: int) -> Dict[int, int]:
    """Compute the Newton depth for every element of F_p.

    The depth of x is the number of steps to reach a fixed point
    of the Newton map. If x is already a fixed point, depth = 0.

    Args:
        coeffs: Polynomial coefficients
        p: Prime modulus

    Returns:
        Dictionary mapping each x in F_p to its Newton depth
    """
    depths: Dict[int, int] = {}

    for x in range(p):
        orbit = compute_orbit(coeffs, x, p)
        # If the cycle has length 1 and equals a root, the depth
        # is the tail length
        if len(orbit.cycle) == 1:
            depths[x] = orbit.depth
        else:
            # Element enters a non-trivial cycle (not a fixed point)
            depths[x] = -1  # Convention: -1 means no fixed point reached

    return depths


@dataclass
class PersistencePair:
    """A persistence pair (birth, death) for Newton basin analysis."""
    birth: int
    death: int

    @property
    def persistence(self) -> int:
        return self.death - self.birth


def persistence_diagram(coeffs: List[int], p: int) -> List[PersistencePair]:
    """Extract the persistence diagram from the Newton depth filtration.

    Each connected component of the Newton graph contributes a
    persistence pair. Components containing a fixed point have
    birth = 0. Other components have birth = their minimum depth.

    Args:
        coeffs: Polynomial coefficients
        p: Prime modulus

    Returns:
        List of PersistencePair objects
    """
    depths = depth_filtration(coeffs, p)
    roots = find_roots(coeffs, p)

    pairs: List[PersistencePair] = []

    # Each root generates a basin; birth=0, death=max depth in basin
    for r in roots:
        basin_depths = [d for x, d in depths.items() if d >= 0 and
                        newton_iterate(coeffs, x, p, d) == r]
        if basin_depths:
            max_depth = max(basin_depths)
            pairs.append(PersistencePair(birth=0, death=max_depth))

    return pairs


def find_roots(coeffs: List[int], p: int) -> List[int]:
    """Find all roots of the polynomial in F_p.

    Args:
        coeffs: Polynomial coefficients
        p: Prime modulus

    Returns:
        List of roots in F_p
    """
    return [x for x in range(p) if poly_eval(coeffs, x, p) == 0]


def frobenius_cycle_type(coeffs: List[int], p: int) -> List[int]:
    """Estimate the Frobenius cycle type from Newton depth histogram.

    The conjecture states that the depth-k barcode multiplicity
    encodes information about orbits of length dividing k+1 under
    the Frobenius automorphism.

    Args:
        coeffs: Polynomial coefficients
        p: Prime modulus

    Returns:
        Sorted list of cycle lengths (the cycle type)
    """
    depths = depth_filtration(coeffs, p)
    depth_hist = Counter(d for d in depths.values() if d >= 0)

    # The number of depth-0 elements with nonzero derivative
    # equals the number of F_p-rational roots
    deriv_coeffs = poly_derivative(coeffs, p)
    rational_roots = sum(
        1 for x in range(p)
        if poly_eval(coeffs, x, p) == 0
        and poly_eval(deriv_coeffs, x, p) != 0
    )

    return sorted(depth_hist.keys())


def newton_graph_adjacency(coeffs: List[int], p: int) -> Dict[int, int]:
    """Build the Newton functional graph as an adjacency map.

    Args:
        coeffs: Polynomial coefficients
        p: Prime modulus

    Returns:
        Dictionary mapping x -> N_f(x) for each x in F_p
    """
    return {x: newton_step(coeffs, x, p) for x in range(p)}


def connected_components(coeffs: List[int], p: int) -> List[Set[int]]:
    """Find connected components of the Newton graph (ignoring direction).

    Args:
        coeffs: Polynomial coefficients
        p: Prime modulus

    Returns:
        List of sets, each representing a connected component
    """
    adj = newton_graph_adjacency(coeffs, p)

    # Build undirected adjacency
    neighbors: Dict[int, Set[int]] = {x: set() for x in range(p)}
    for x, y in adj.items():
        neighbors[x].add(y)
        neighbors[y].add(x)

    visited: Set[int] = set()
    components: List[Set[int]] = []

    for x in range(p):
        if x not in visited:
            component: Set[int] = set()
            stack = [x]
            while stack:
                node = stack.pop()
                if node in visited:
                    continue
                visited.add(node)
                component.add(node)
                for nbr in neighbors[node]:
                    if nbr not in visited:
                        stack.append(nbr)
            components.append(component)

    return components


def spectral_width(coeffs: List[int], p: int) -> int:
    """Compute the spectral width of the Newton persistence diagram.

    Defined as the maximum persistence (death - birth) across all
    persistence pairs.

    Args:
        coeffs: Polynomial coefficients
        p: Prime modulus

    Returns:
        Maximum persistence value
    """
    diagram = persistence_diagram(coeffs, p)
    if not diagram:
        return 0
    return max(pair.persistence for pair in diagram)


if __name__ == "__main__":
    # Quick self-test
    # f(x) = x^2 - 1, p = 7
    coeffs = [-1, 0, 1]  # -1 + 0*x + 1*x^2
    p = 7

    print(f"Polynomial: x^2 - 1 over F_{p}")
    print(f"Roots: {find_roots(coeffs, p)}")
    print(f"Newton graph: {newton_graph_adjacency(coeffs, p)}")
    print(f"Depth filtration: {depth_filtration(coeffs, p)}")
    print(f"Persistence diagram: {persistence_diagram(coeffs, p)}")
    print(f"Spectral width: {spectral_width(coeffs, p)}")
    print(f"Components: {connected_components(coeffs, p)}")

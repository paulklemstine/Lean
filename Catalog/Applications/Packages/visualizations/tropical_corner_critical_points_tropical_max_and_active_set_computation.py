#!/usr/bin/env python3
"""
Tropical Morse Theory — Core Algorithms

Efficient algorithms for:
  1. Computing tropical max functions and active sets
  2. Detecting corner critical points
  3. Computing tropical Morse indices
  4. Finding corner crossings along paths
  5. Graph-theoretic discrete Morse analysis
"""

import numpy as np
from typing import List, Tuple, Set, Dict, Optional
from dataclasses import dataclass


# ─────────────────────────────────────────────────────────
# Data Structures
# ─────────────────────────────────────────────────────────

@dataclass
class AffinePiece:
    """An affine function f(x) = grad · x + bias on Rⁿ.

    Attributes:
        grad: Gradient vector (numpy array of shape (n,))
        bias: Scalar bias/constant term
    """
    grad: np.ndarray
    bias: float

    def eval(self, x: np.ndarray) -> float:
        """Evaluate the affine piece at point x."""
        return float(self.grad @ x + self.bias)

    def directional_deriv(self, v: np.ndarray) -> float:
        """Directional derivative in direction v."""
        return float(self.grad @ v)


@dataclass
class CornerCriticalPoint:
    """A detected corner critical point with metadata."""
    point: np.ndarray
    active_indices: List[int]
    tropical_value: float
    morse_index: Optional[int] = None
    is_corner_critical: bool = False


# ─────────────────────────────────────────────────────────
# Algorithm 1: Tropical Max Evaluation
# ─────────────────────────────────────────────────────────

def tropical_max(pieces: List[AffinePiece], x: np.ndarray) -> float:
    """
    Evaluate the tropical max function f(x) = max_i (grad_i · x + bias_i).

    Time complexity: O(m·n) where m = #pieces, n = dimension
    Space complexity: O(m)

    Args:
        pieces: List of affine pieces
        x: Point in Rⁿ

    Returns:
        Maximum value among all affine pieces at x
    """
    return max(p.eval(x) for p in pieces)


def active_indices(pieces: List[AffinePiece], x: np.ndarray,
                   tol: float = 1e-12) -> List[int]:
    """
    Compute the active set: indices of pieces achieving the maximum.

    Time complexity: O(m·n)
    Space complexity: O(m)

    Args:
        pieces: List of affine pieces
        x: Point in Rⁿ
        tol: Numerical tolerance for equality

    Returns:
        List of indices where evalPiece equals tropicalMax
    """
    vals = [p.eval(x) for p in pieces]
    mx = max(vals)
    return [i for i, v in enumerate(vals) if abs(v - mx) < tol]


def is_on_corner_locus(pieces: List[AffinePiece], x: np.ndarray,
                        tol: float = 1e-12) -> bool:
    """
    Check if x lies on the corner locus (≥ 2 active pieces).

    Time complexity: O(m·n)
    """
    return len(active_indices(pieces, x, tol)) >= 2


# ─────────────────────────────────────────────────────────
# Algorithm 2: Corner Critical Point Detection
# ─────────────────────────────────────────────────────────

def is_corner_critical(pieces: List[AffinePiece], x: np.ndarray,
                        n_sample_dirs: int = 1000,
                        tol: float = 1e-12) -> bool:
    """
    Check if x is a corner critical point by sampling directions.

    A point is corner critical if:
    (a) it's on the corner locus (≥ 2 active pieces), AND
    (b) for every direction v, either all active derivatives are 0,
        or some pair of active pieces has opposing derivatives.

    This is checked by sampling random directions. The check is
    conservative: if it returns True, the point is likely critical;
    if False, it's definitively not critical (for the tested directions).

    Time complexity: O(n_sample_dirs · m · n)

    Args:
        pieces: List of affine pieces
        x: Point in Rⁿ
        n_sample_dirs: Number of random directions to sample
        tol: Numerical tolerance

    Returns:
        True if the point appears to be corner critical
    """
    active = active_indices(pieces, x, tol)
    if len(active) < 2:
        return False

    n = len(pieces[0].grad)
    rng = np.random.default_rng(42)

    for _ in range(n_sample_dirs):
        v = rng.standard_normal(n)
        v /= np.linalg.norm(v)

        derivs = [pieces[i].directional_deriv(v) for i in active]

        # Check: are all derivatives zero?
        if all(abs(d) < tol for d in derivs):
            continue

        # Check: do some pair have opposing signs?
        has_positive = any(d > tol for d in derivs)
        has_negative = any(d < -tol for d in derivs)

        if not (has_positive and has_negative) and not all(abs(d) < tol for d in derivs):
            # All nonzero derivs have the same sign — NOT corner critical
            return False

    return True


def is_corner_critical_exact_2piece(p: AffinePiece, q: AffinePiece,
                                     x: np.ndarray,
                                     tol: float = 1e-12) -> bool:
    """
    Exact corner criticality check for the two-piece case.

    For two pieces p, q with equal evaluation at x, corner criticality
    is equivalent to: for all v, p.grad·v * q.grad·v ≤ 0.
    This holds iff q.grad = -c * p.grad for some c ≥ 0.

    Time complexity: O(n)

    Args:
        p, q: The two affine pieces
        x: Point on the wall (evalPiece p x = evalPiece q x)

    Returns:
        True if the point is corner critical
    """
    if abs(p.eval(x) - q.eval(x)) > tol:
        return False

    # Check if q.grad = -c * p.grad for c ≥ 0
    g1, g2 = p.grad, q.grad

    # If both zero, trivially critical
    if np.linalg.norm(g1) < tol and np.linalg.norm(g2) < tol:
        return True

    # If one is zero, critical (zero grad always has product = 0)
    if np.linalg.norm(g1) < tol or np.linalg.norm(g2) < tol:
        return True

    # Check if g2 = -c * g1 for c ≥ 0
    # Compute the ratio g2 / (-g1) component-wise
    nonzero_idx = np.abs(g1) > tol
    if not np.any(nonzero_idx):
        return True

    ratios = g2[nonzero_idx] / (-g1[nonzero_idx])
    # All ratios should be equal and non-negative
    if np.all(ratios >= -tol) and np.max(ratios) - np.min(ratios) < tol * 10:
        return True

    return False


# ─────────────────────────────────────────────────────────
# Algorithm 3: Tropical Morse Index
# ─────────────────────────────────────────────────────────

def tropical_morse_index_2piece(p: AffinePiece, q: AffinePiece) -> int:
    """
    Compute the tropical Morse index for a two-piece wall.

    The index is 1 if the gradients fully oppose (q.grad = -c·p.grad, c ≥ 0),
    and 0 otherwise.

    Time complexity: O(n)

    Args:
        p, q: Two affine pieces

    Returns:
        0 or 1
    """
    g1, g2 = p.grad, q.grad
    tol = 1e-12

    if np.linalg.norm(g1) < tol or np.linalg.norm(g2) < tol:
        return 1

    nonzero_idx = np.abs(g1) > tol
    if not np.any(nonzero_idx):
        return 1

    ratios = g2[nonzero_idx] / (-g1[nonzero_idx])
    if np.all(ratios >= -tol) and np.max(ratios) - np.min(ratios) < tol * 10:
        return 1

    return 0


def sign_opposing_pairs(pieces: List[AffinePiece], active: List[int],
                         v: np.ndarray) -> int:
    """
    Count sign-opposing pairs among active pieces for direction v.

    Time complexity: O(|active|² · n)

    Args:
        pieces: Full list of affine pieces
        active: Indices of active pieces
        v: Direction vector

    Returns:
        Number of ordered pairs (i,j) with opposing directional derivatives
    """
    derivs = [pieces[i].directional_deriv(v) for i in active]
    count = 0
    for i in range(len(active)):
        for j in range(len(active)):
            if derivs[i] * derivs[j] < 0:
                count += 1
    return count


# ─────────────────────────────────────────────────────────
# Algorithm 4: Corner Crossing Detection Along Paths
# ─────────────────────────────────────────────────────────

def find_corner_crossings(pieces: List[AffinePiece],
                           gamma: np.ndarray,
                           tol: float = 1e-10) -> List[CornerCriticalPoint]:
    """
    Find all corner crossings along a discretized path.

    Uses active set tracking and bisection for precise localization.

    Time complexity: O(T · m · n) where T = #path samples

    Args:
        pieces: List of affine pieces
        gamma: Path as array of shape (T, n)
        tol: Tolerance for equality detection

    Returns:
        List of detected corner critical points
    """
    crossings = []
    prev_active = tuple(active_indices(pieces, gamma[0], tol))

    for idx in range(1, len(gamma)):
        curr_active = tuple(active_indices(pieces, gamma[idx], tol))

        if curr_active != prev_active:
            # Active set changed — bisect to find crossing
            pt = _bisect_crossing(pieces, gamma[idx-1], gamma[idx], tol)
            act = active_indices(pieces, pt, tol)

            if len(act) >= 2:
                ccp = CornerCriticalPoint(
                    point=pt,
                    active_indices=act,
                    tropical_value=tropical_max(pieces, pt),
                    is_corner_critical=is_corner_critical(pieces, pt, 100, tol)
                )

                # Compute Morse index for 2-piece case
                if len(act) == 2:
                    ccp.morse_index = tropical_morse_index_2piece(
                        pieces[act[0]], pieces[act[1]])

                crossings.append(ccp)

            prev_active = curr_active

    return crossings


def _bisect_crossing(pieces: List[AffinePiece],
                      x0: np.ndarray, x1: np.ndarray,
                      tol: float, max_iter: int = 50) -> np.ndarray:
    """Bisection to find precise corner crossing between x0 and x1."""
    for _ in range(max_iter):
        mid = (x0 + x1) / 2
        act = active_indices(pieces, mid, tol)
        if len(act) >= 2:
            return mid
        # Move toward the side where the active set is about to change
        act0 = active_indices(pieces, x0, tol)
        if act == act0:
            x0 = mid
        else:
            x1 = mid
    return (x0 + x1) / 2


# ─────────────────────────────────────────────────────────
# Algorithm 5: Graph Discrete Morse Analysis
# ─────────────────────────────────────────────────────────

def graph_critical_points(adj: Dict[int, Set[int]],
                           phi: Dict[int, float]) -> Dict[str, List[int]]:
    """
    Find local maxima, minima, and saddle points on a graph.

    A vertex v is:
    - local maximum if φ(u) ≤ φ(v) for all neighbors u
    - local minimum if φ(v) ≤ φ(u) for all neighbors u
    - saddle point if it has both higher and lower neighbors

    Time complexity: O(V + E) where V = #vertices, E = #edges

    Args:
        adj: Adjacency list {vertex: set of neighbors}
        phi: Height function {vertex: value}

    Returns:
        Dictionary with keys 'max', 'min', 'saddle'
    """
    result = {'max': [], 'min': [], 'saddle': []}

    for v in adj:
        neighbors = adj[v]
        if not neighbors:
            result['max'].append(v)
            result['min'].append(v)
            continue

        has_higher = any(phi[u] > phi[v] for u in neighbors)
        has_lower = any(phi[u] < phi[v] for u in neighbors)

        if not has_higher:
            result['max'].append(v)
        if not has_lower:
            result['min'].append(v)
        if has_higher and has_lower:
            result['saddle'].append(v)

    return result


def euler_characteristic_graph(adj: Dict[int, Set[int]]) -> int:
    """
    Compute the Euler characteristic χ = V - E of a graph.

    Time complexity: O(V + E)
    """
    V = len(adj)
    E = sum(len(neighbors) for neighbors in adj.values()) // 2
    return V - E


def verify_morse_inequality(adj: Dict[int, Set[int]],
                             phi: Dict[int, float]) -> dict:
    """
    Verify the discrete Morse inequality: #local_max ≥ β₀.

    For connected graphs, β₀ = 1 (one connected component).
    The weak Morse inequality states that the number of critical
    points of each index bounds the corresponding Betti number.

    Time complexity: O(V + E)
    """
    crits = graph_critical_points(adj, phi)
    chi = euler_characteristic_graph(adj)

    # Count connected components (β₀) via BFS
    visited = set()
    components = 0
    for v in adj:
        if v not in visited:
            components += 1
            queue = [v]
            while queue:
                u = queue.pop()
                if u in visited:
                    continue
                visited.add(u)
                queue.extend(adj[u] - visited)

    return {
        'n_local_max': len(crits['max']),
        'n_local_min': len(crits['min']),
        'n_saddle': len(crits['saddle']),
        'euler_char': chi,
        'beta_0': components,
        'morse_ineq_max': len(crits['max']) >= components,
        'morse_ineq_min': len(crits['min']) >= components,
    }


# ─────────────────────────────────────────────────────────
# Example Usage
# ─────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Tropical Morse Theory — Algorithm Demonstrations")
    print("=" * 60)

    # Two opposing pieces in R²
    p1 = AffinePiece(np.array([1.0, -1.0]), 0.0)
    p2 = AffinePiece(np.array([-1.0, 1.0]), 0.0)

    origin = np.zeros(2)
    print(f"\nTwo-piece example: f₁=x₀-x₁, f₂=-x₀+x₁")
    print(f"  Active at origin: {active_indices([p1, p2], origin)}")
    print(f"  On corner locus: {is_on_corner_locus([p1, p2], origin)}")
    print(f"  Corner critical: {is_corner_critical_exact_2piece(p1, p2, origin)}")
    print(f"  Morse index: {tropical_morse_index_2piece(p1, p2)}")

    # Path crossing
    t = np.linspace(0, 1, 1000)
    path = np.column_stack([2 - 4*t, -2 + 4*t])
    crossings = find_corner_crossings([p1, p2], path)
    print(f"\n  Corner crossings on path (2,-2)→(-2,2): {len(crossings)}")
    for c in crossings:
        print(f"    Point: ({c.point[0]:.4f}, {c.point[1]:.4f}), "
              f"active: {c.active_indices}, index: {c.morse_index}")

    # Graph Morse theory
    print(f"\nGraph Morse theory:")
    adj = {0: {1}, 1: {0, 2}, 2: {1, 3}, 3: {2, 4}, 4: {3}}
    phi = {0: 1.0, 1: 3.0, 2: 2.0, 3: 4.0, 4: 0.0}
    result = verify_morse_inequality(adj, phi)
    print(f"  Path graph: {result}")

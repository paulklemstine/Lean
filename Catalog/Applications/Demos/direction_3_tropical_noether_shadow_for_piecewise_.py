#!/usr/bin/env python3
"""
Tropical Noether Shadow — Applications

Real-world applications of tropical Noether conservation:
1. Optimality certification for piecewise-linear optimization
2. Network flow duality via tropical mechanics
3. Pythagorean-tropical encoding
"""

import numpy as np
from typing import List, Tuple


def pythagorean_tropical_check(a: float, b: float, c: float) -> dict:
    """Verify the Pythagorean-tropical encoding: max(a², b²) ≤ c².

    For a Pythagorean triple (a² + b² = c²), the tropical (max)
    inequality holds, connecting Pythagorean geometry to tropical
    mechanics.

    Args:
        a, b, c: sides of a triangle (a² + b² should equal c²)

    Returns:
        dict with verification results
    """
    a2, b2, c2 = a**2, b**2, c**2
    is_pythagorean = abs(a2 + b2 - c2) < 1e-10
    tropical_ineq = max(a2, b2) <= c2 + 1e-10
    dominant_leg = "a" if a2 >= b2 else "b"

    return {
        'a': a, 'b': b, 'c': c,
        'a_squared': a2, 'b_squared': b2, 'c_squared': c2,
        'is_pythagorean': is_pythagorean,
        'tropical_inequality_holds': tropical_ineq,
        'max_leg_squared': max(a2, b2),
        'dominant_leg': dominant_leg,
        'tropical_gap': c2 - max(a2, b2),
        'breakpoint': abs(a2 - b2) < 1e-10,  # a = b is the tropical breakpoint
    }


def optimality_certificate(charges: List[float], tol: float = 1e-8) -> dict:
    """Use Noether charge constancy as an optimality certificate.

    If the tropical Noether charge is constant along a trajectory,
    this provides evidence that the trajectory is optimal (or at least
    satisfies the tropical Noether conservation law).

    A charge jump indicates sub-optimality: the trajectory can potentially
    be improved by modifying the segment around the jump.

    Args:
        charges: sequence of Noether charges along trajectory

    Returns:
        dict with certificate information
    """
    if not charges:
        return {'certified': False, 'reason': 'empty trajectory'}

    ref = charges[0]
    max_deviation = max(abs(c - ref) for c in charges)
    jumps = []
    for t in range(len(charges) - 1):
        if abs(charges[t] - charges[t+1]) > tol:
            jumps.append({
                'time': t,
                'charge_before': charges[t],
                'charge_after': charges[t+1],
                'jump_size': abs(charges[t+1] - charges[t]),
            })

    return {
        'certified': max_deviation < tol,
        'max_deviation': max_deviation,
        'num_jumps': len(jumps),
        'jumps': jumps,
        'charge_value': ref if max_deviation < tol else None,
    }


def network_flow_tropical_encoding(num_nodes: int, edges: List[Tuple[int, int, float]],
                                     source: int, sink: int) -> dict:
    """Encode a network flow problem as a tropical Lagrangian system.

    Each edge (u, v, cost) becomes a piece of the tropical Lagrangian.
    The tropical action of a trajectory corresponds to the bottleneck
    (maximum edge cost) along the path.

    Args:
        num_nodes: number of nodes in the network
        edges: list of (source, target, cost) tuples
        source: source node
        sink: sink node

    Returns:
        dict with encoding and shortest path information
    """
    # Build adjacency list
    adj = {i: [] for i in range(num_nodes)}
    for u, v, cost in edges:
        adj[u].append((v, cost))

    # Find min-bottleneck path (tropical shortest path)
    # Using modified Dijkstra with max instead of sum
    import heapq
    dist = [float('inf')] * num_nodes
    dist[source] = float('-inf')  # bottleneck starts at -inf
    parent = [-1] * num_nodes
    pq = [(float('-inf'), source)]

    while pq:
        d, u = heapq.heappop(pq)
        if d > dist[u]:
            continue
        for v, cost in adj[u]:
            new_dist = max(d, cost)  # tropical: max replaces sum
            if new_dist < dist[v]:
                dist[v] = new_dist
                parent[v] = u
                heapq.heappush(pq, (new_dist, v))

    # Reconstruct path
    path = []
    node = sink
    while node != -1:
        path.append(node)
        node = parent[node]
    path.reverse()

    return {
        'num_nodes': num_nodes,
        'num_edges': len(edges),
        'source': source,
        'sink': sink,
        'tropical_action': dist[sink],
        'optimal_path': path if path[0] == source else [],
        'node_potentials': dist,
    }


def demo_pythagorean():
    """Demonstrate Pythagorean-tropical connection."""
    print("=== Pythagorean-Tropical Encoding ===\n")

    triples = [
        (3, 4, 5),
        (5, 12, 13),
        (8, 15, 17),
        (7, 24, 25),
        (1, 1, np.sqrt(2)),  # isosceles right triangle (breakpoint!)
    ]

    for a, b, c in triples:
        result = pythagorean_tropical_check(a, b, c)
        print(f"  ({a}, {b}, {c}):")
        print(f"    Pythagorean: {result['is_pythagorean']}")
        print(f"    max(a²,b²) = {result['max_leg_squared']:.1f} ≤ c² = {result['c_squared']:.1f}")
        print(f"    Tropical gap: {result['tropical_gap']:.1f}")
        print(f"    Dominant leg: {result['dominant_leg']}")
        if result['breakpoint']:
            print(f"    *** BREAKPOINT: a = b (tropical transition) ***")
        print()


def demo_network_flow():
    """Demonstrate network flow via tropical mechanics."""
    print("=== Network Flow via Tropical Mechanics ===\n")

    # Simple network
    edges = [
        (0, 1, 3),
        (0, 2, 1),
        (1, 3, 2),
        (2, 3, 4),
        (1, 2, 1),
    ]

    result = network_flow_tropical_encoding(4, edges, 0, 3)
    print(f"  Network: {result['num_nodes']} nodes, {result['num_edges']} edges")
    print(f"  Source: {result['source']}, Sink: {result['sink']}")
    print(f"  Tropical action (bottleneck): {result['tropical_action']}")
    print(f"  Optimal path: {result['optimal_path']}")
    print(f"  Node potentials: {result['node_potentials']}")
    print()

    # Larger network
    np.random.seed(42)
    n_nodes = 10
    edges2 = []
    for _ in range(25):
        u = np.random.randint(0, n_nodes - 1)
        v = np.random.randint(u + 1, n_nodes)
        cost = np.random.uniform(1, 10)
        edges2.append((u, v, round(cost, 1)))

    result2 = network_flow_tropical_encoding(n_nodes, edges2, 0, n_nodes - 1)
    print(f"  Larger network: {result2['num_nodes']} nodes, {result2['num_edges']} edges")
    print(f"  Tropical action: {result2['tropical_action']:.1f}")
    print(f"  Path: {result2['optimal_path']}")


def demo_optimality():
    """Demonstrate optimality certification."""
    print("=== Optimality Certification ===\n")

    # Constant charges (optimal)
    charges_good = [2.5] * 10
    cert = optimality_certificate(charges_good)
    print(f"  Constant charges: certified = {cert['certified']}")
    print(f"  Charge value: {cert['charge_value']}")
    print()

    # Charges with jump (sub-optimal)
    charges_bad = [2.5, 2.5, 2.5, 3.1, 3.1, 3.1]
    cert2 = optimality_certificate(charges_bad)
    print(f"  Jumping charges: certified = {cert2['certified']}")
    print(f"  Max deviation: {cert2['max_deviation']:.2f}")
    print(f"  Jumps: {cert2['num_jumps']}")
    for j in cert2['jumps']:
        print(f"    t={j['time']}: {j['charge_before']:.1f} → {j['charge_after']:.1f} "
              f"(Δ={j['jump_size']:.1f})")


if __name__ == "__main__":
    demo_pythagorean()
    print("=" * 50)
    print()
    demo_network_flow()
    print("=" * 50)
    print()
    demo_optimality()


#!/usr/bin/env python3
"""
Tropical Noether Shadow — Interactive Demonstration

Generates random tropical Lagrangians with translation symmetry,
computes trajectories, evaluates the tropical Noether charge at each step,
and visualizes piecewise-constancy and breakpoint balance.
"""

import numpy as np
import random
from typing import List, Tuple, Optional


class TropicalLagrangian:
    """A tropical Lagrangian: L(q, v) = max_i (a_i · q + b_i · v + c_i)."""

    def __init__(self, a: np.ndarray, b: np.ndarray, c: np.ndarray):
        """
        Args:
            a: (m, n) position coefficient matrix
            b: (m, n) velocity coefficient matrix
            c: (m,) constant offsets
        """
        self.a = np.array(a, dtype=float)
        self.b = np.array(b, dtype=float)
        self.c = np.array(c, dtype=float)
        self.m = a.shape[0]  # number of pieces
        self.n = a.shape[1]  # dimension

    def piece_val(self, i: int, q: np.ndarray, v: np.ndarray) -> float:
        """Value of piece i at (q, v)."""
        return float(self.a[i] @ q + self.b[i] @ v + self.c[i])

    def eval(self, q: np.ndarray, v: np.ndarray) -> float:
        """Evaluate L(q, v) = max_i piece_val(i, q, v)."""
        return max(self.piece_val(i, q, v) for i in range(self.m))

    def active_piece(self, q: np.ndarray, v: np.ndarray) -> int:
        """Index of the active (maximizing) piece."""
        vals = [self.piece_val(i, q, v) for i in range(self.m)]
        return int(np.argmax(vals))

    def noether_charge(self, xi: np.ndarray, q: np.ndarray, v: np.ndarray) -> float:
        """Tropical Noether charge: b_{j*} · xi."""
        j = self.active_piece(q, v)
        return float(self.b[j] @ xi)

    def has_translation_symmetry(self, xi: np.ndarray, tol: float = 1e-12) -> bool:
        """Check if L has translation symmetry along xi."""
        return all(abs(self.a[i] @ xi) < tol for i in range(self.m))


def generate_symmetric_lagrangian(n: int, m: int, xi: np.ndarray,
                                   uniform_charge: bool = False) -> TropicalLagrangian:
    """Generate a random tropical Lagrangian with translation symmetry along xi.

    Args:
        n: dimension
        m: number of pieces
        xi: symmetry direction
        uniform_charge: if True, all pieces have the same b · xi
    """
    # Position coefficients: a_i · xi = 0
    # Project random vectors onto the orthogonal complement of xi
    xi_norm = xi / np.linalg.norm(xi)
    a = np.random.randn(m, n) * 3
    for i in range(m):
        a[i] -= (a[i] @ xi_norm) * xi_norm  # project out xi component

    # Velocity coefficients
    b = np.random.randn(m, n) * 3
    if uniform_charge:
        # Make all b_i · xi the same
        target = b[0] @ xi
        for i in range(1, m):
            b[i] -= ((b[i] @ xi - target) / (xi @ xi)) * xi

    # Constant offsets
    c = np.random.randn(m) * 2

    return TropicalLagrangian(a, b, c)


def generate_trajectory(n: int, length: int,
                        q_start: Optional[np.ndarray] = None) -> List[np.ndarray]:
    """Generate a random trajectory of given length."""
    if q_start is None:
        q_start = np.random.randn(n)
    positions = [q_start]
    for _ in range(length):
        step = np.random.randn(n) * 0.5
        positions.append(positions[-1] + step)
    return positions


def compute_charges(L: TropicalLagrangian, xi: np.ndarray,
                    positions: List[np.ndarray]) -> Tuple[List[float], List[int], List[bool]]:
    """Compute Noether charges, active pieces, and breakpoints along a trajectory.

    Returns:
        charges: charge at each time step
        active_pieces: active piece index at each step
        breakpoints: True at steps where active piece changes
    """
    T = len(positions) - 1
    charges = []
    active_pieces = []
    breakpoints = []

    for t in range(T):
        q = positions[t]
        v = positions[t + 1] - positions[t]
        charges.append(L.noether_charge(xi, q, v))
        active_pieces.append(L.active_piece(q, v))

    for t in range(T - 1):
        breakpoints.append(active_pieces[t] != active_pieces[t + 1])

    return charges, active_pieces, breakpoints


def verify_piecewise_constancy(charges: List[float], breakpoints: List[bool],
                                tol: float = 1e-10) -> bool:
    """Verify that charges are constant between breakpoints."""
    for t in range(len(breakpoints)):
        if not breakpoints[t]:  # not a breakpoint
            if abs(charges[t] - charges[t + 1]) > tol:
                return False
    return True


def verify_kirchhoff(charges: List[float], breakpoints: List[bool],
                      tol: float = 1e-10) -> Tuple[bool, int]:
    """Verify Kirchhoff's current law (charge balance) at breakpoints.

    Returns:
        (all_balanced, count_breakpoints)
    """
    count = 0
    all_ok = True
    for t in range(len(breakpoints)):
        if breakpoints[t]:
            count += 1
            if abs(charges[t] - charges[t + 1]) > tol:
                all_ok = False
    return all_ok, count


def run_experiment(num_lagrangians: int = 1000, n: int = 2, traj_length: int = 20,
                   uniform_charge: bool = True):
    """Run the main experiment: test tropical Noether conservation.

    Args:
        num_lagrangians: number of random Lagrangians to test
        n: dimension
        traj_length: trajectory length
        uniform_charge: whether to enforce uniform b·xi
    """
    xi = np.zeros(n)
    xi[0] = 1.0  # symmetry along first coordinate

    total_steps = 0
    total_breakpoints = 0
    pw_const_failures = 0
    balance_failures = 0
    global_const_failures = 0

    for trial in range(num_lagrangians):
        m = random.randint(3, 10)
        L = generate_symmetric_lagrangian(n, m, xi, uniform_charge=uniform_charge)

        # Verify symmetry
        assert L.has_translation_symmetry(xi), f"Symmetry check failed at trial {trial}"

        positions = generate_trajectory(n, traj_length)
        charges, active_pieces, breakpoints = compute_charges(L, xi, positions)

        total_steps += len(charges)
        total_breakpoints += sum(breakpoints)

        # Check piecewise constancy
        if not verify_piecewise_constancy(charges, breakpoints):
            pw_const_failures += 1

        # Check Kirchhoff / balance at breakpoints
        balanced, _ = verify_kirchhoff(charges, breakpoints)
        if not balanced:
            balance_failures += 1

        # Check global constancy
        if len(charges) > 1:
            if max(charges) - min(charges) > 1e-10:
                global_const_failures += 1

    print(f"=== Tropical Noether Shadow Experiment ===")
    print(f"Lagrangians tested:     {num_lagrangians}")
    print(f"Dimension:              {n}")
    print(f"Trajectory length:      {traj_length}")
    print(f"Uniform charge:         {uniform_charge}")
    print(f"Total time steps:       {total_steps}")
    print(f"Total breakpoints:      {total_breakpoints}")
    print(f"PW-constancy failures:  {pw_const_failures}")
    print(f"Balance failures:       {balance_failures}")
    print(f"Global const failures:  {global_const_failures}")
    print()

    if pw_const_failures == 0:
        print("✓ Piecewise constancy CONFIRMED in all cases")
    else:
        print(f"✗ Piecewise constancy FAILED in {pw_const_failures} cases")

    if balance_failures == 0 and uniform_charge:
        print("✓ Kirchhoff balance CONFIRMED at all breakpoints")
    elif balance_failures > 0:
        print(f"✗ Kirchhoff balance FAILED in {balance_failures} cases")

    if global_const_failures == 0 and uniform_charge:
        print("✓ Global constancy CONFIRMED (Tropical Noether theorem)")
    elif global_const_failures > 0:
        print(f"  Global constancy failed in {global_const_failures} cases")
        if not uniform_charge:
            print("  (Expected: uniform charge condition not enforced)")


def demo_single_trajectory():
    """Demonstrate a single trajectory with detailed output."""
    np.random.seed(42)
    n = 2
    m = 4
    xi = np.array([1.0, 0.0])

    L = generate_symmetric_lagrangian(n, m, xi, uniform_charge=True)

    print("=== Single Trajectory Demo ===")
    print(f"Lagrangian: {m} pieces on R^{n}")
    print(f"Symmetry direction: xi = {xi}")
    print(f"Translation symmetry: {L.has_translation_symmetry(xi)}")
    print()

    # Show piece structure
    for i in range(m):
        print(f"  Piece {i}: a={L.a[i].round(3)}, b={L.b[i].round(3)}, c={L.c[i]:.3f}")
        print(f"    a·xi = {L.a[i] @ xi:.6f}, b·xi = {L.b[i] @ xi:.6f}")
    print()

    positions = generate_trajectory(n, 15)
    charges, active_pieces, breakpoints = compute_charges(L, xi, positions)

    print(f"{'Step':>4} {'Active':>6} {'Charge':>10} {'Breakpoint':>12}")
    print("-" * 36)
    for t in range(len(charges)):
        bp = "  ←BREAK" if t < len(breakpoints) and breakpoints[t] else ""
        print(f"{t:4d} {active_pieces[t]:6d} {charges[t]:10.6f} {bp}")

    print()
    charge_range = max(charges) - min(charges)
    print(f"Charge range: {charge_range:.2e}")
    if charge_range < 1e-10:
        print("✓ Charge is globally constant!")
    else:
        print("  Charge varies (non-uniform b·xi)")


def demo_counterexample_search():
    """Search for counterexamples to universality (non-uniform b·xi)."""
    np.random.seed(123)
    n = 3
    xi = np.array([1.0, 0.0, 0.0])

    print("=== Counterexample Search (non-uniform charge) ===")
    print(f"Testing with non-uniform b·xi to find charge jumps...")
    print()

    found = 0
    for trial in range(500):
        m = random.randint(3, 8)
        L = generate_symmetric_lagrangian(n, m, xi, uniform_charge=False)
        positions = generate_trajectory(n, 30)
        charges, _, breakpoints = compute_charges(L, xi, positions)

        if len(charges) > 1:
            charge_range = max(charges) - min(charges)
            if charge_range > 0.01:
                found += 1
                if found <= 3:
                    print(f"  Trial {trial}: charge range = {charge_range:.4f}")
                    print(f"    charges = {[round(c, 3) for c in charges[:8]]}...")

    print(f"\n  Found {found}/500 cases with charge variation")
    print(f"  (This is expected: universality requires uniform b·xi or minimality)")


if __name__ == "__main__":
    print("=" * 60)
    print("  TROPICAL NOETHER SHADOW — DEMONSTRATION")
    print("=" * 60)
    print()

    # Demo 1: Single trajectory
    demo_single_trajectory()
    print()
    print("=" * 60)
    print()

    # Demo 2: Large-scale experiment (uniform charge)
    run_experiment(num_lagrangians=1000, n=2, traj_length=20, uniform_charge=True)
    print()
    print("=" * 60)
    print()

    # Demo 3: 3D experiment
    run_experiment(num_lagrangians=500, n=3, traj_length=25, uniform_charge=True)
    print()
    print("=" * 60)
    print()

    # Demo 4: Counterexample search
    demo_counterexample_search()

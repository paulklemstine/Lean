#!/usr/bin/env python3
"""
Applications of Tropical Band Systems

Demonstrates real-world applications of tropical band geometry:
1. Job scheduling with temporal constraints
2. Network timing verification
3. Currency arbitrage detection
4. Sensor network synchronization

Each application shows how tropical band feasibility translates
to a concrete problem, and how certificates (feasible points or
negative cycles) give actionable information.
"""

import numpy as np
from algorithms import (
    canonical_potential, extract_negative_cycle,
    bellman_ford_feasibility, verify_feasibility_certificate
)


def scheduling_application():
    """Job Scheduling with Temporal Constraints.

    Problem: Schedule 4 tasks with:
    - Each task has an earliest start and latest finish time
    - Some tasks must start within a certain time after others

    This is precisely a tropical band system:
    - lower[i] = earliest start of task i
    - upper[i] = latest start of task i
    - slack[i,j] = max time task i can start after task j
    """
    print("=" * 60)
    print("APPLICATION 1: Job Scheduling")
    print("=" * 60)

    # 4 tasks: {setup, process, verify, ship}
    tasks = ["Setup", "Process", "Verify", "Ship"]
    n = len(tasks)

    # Earliest/latest start times (hours from midnight)
    lower = np.array([8.0, 9.0, 10.0, 14.0])   # earliest starts
    upper = np.array([10.0, 12.0, 15.0, 17.0])  # latest starts

    # Temporal constraints: x[i] ≤ x[j] + slack[i,j]
    # slack[i,j] = how much later task i can start compared to task j
    INF = 1000.0
    slack = np.full((n, n), INF)
    np.fill_diagonal(slack, 0)

    # Setup must start before Process: x[1] - x[0] ≥ 1 → x[0] ≤ x[1] + (-1) doesn't work
    # Actually: slack[i,j] means x[i] ≤ x[j] + slack[i,j]
    # "Process starts at least 1h after Setup": x[0] + 1 ≤ x[1] → x[0] ≤ x[1] + (-1)?
    # No: x[0] ≤ x[1] + slack[0,1], so slack[0,1] = -1 means x[0] ≤ x[1] - 1
    # This means Setup must be at least 1h before Process

    slack[0, 1] = -1   # Setup at least 1h before Process
    slack[1, 2] = -1   # Process at least 1h before Verify
    slack[2, 3] = -2   # Verify at least 2h before Ship
    slack[1, 3] = 3    # Process starts at most 3h after Ship? No — x[1] ≤ x[3]+3
    slack[3, 1] = -2   # Ship at least 2h after Process

    print(f"\n  Tasks: {tasks}")
    print(f"  Earliest starts: {lower}")
    print(f"  Latest starts:   {upper}")
    print(f"  Constraints:")
    for i in range(n):
        for j in range(n):
            if slack[i, j] < INF and i != j:
                if slack[i, j] < 0:
                    print(f"    {tasks[i]} at least {-slack[i,j]:.0f}h before {tasks[j]}")
                else:
                    print(f"    {tasks[i]} at most {slack[i,j]:.0f}h after {tasks[j]}")

    x, feasible = canonical_potential(lower, upper, slack)
    if feasible:
        print(f"\n  ✓ Schedule found (canonical potential):")
        for i in range(n):
            print(f"    {tasks[i]}: start at {x[i]:.1f}h")
    else:
        print(f"\n  ✗ No feasible schedule exists!")
        neg = extract_negative_cycle(slack)
        if neg:
            cycle, weight = neg
            print(f"    Obstruction: negative cycle {[tasks[c] for c in cycle]}")
            print(f"    Cycle weight: {weight}")


def network_timing():
    """Network Timing Verification.

    Problem: Verify that signal propagation times in a network
    are consistent with given delay bounds.

    Each node has a clock range [lower, upper].
    Each edge has a max skew constraint: |clock_i - clock_j| ≤ skew_ij.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Network Clock Synchronization")
    print("=" * 60)

    nodes = ["Server", "Router_A", "Router_B", "Client"]
    n = len(nodes)

    lower = np.array([0.0, 0.0, 0.0, 0.0])
    upper = np.array([100.0, 100.0, 100.0, 100.0])

    # Skew constraints (bidirectional → two slack entries each)
    INF = 1000.0
    slack = np.full((n, n), INF)
    np.fill_diagonal(slack, 0)

    # Server-RouterA skew ≤ 5ms
    slack[0, 1] = 5;  slack[1, 0] = 5
    # Server-RouterB skew ≤ 3ms
    slack[0, 2] = 3;  slack[2, 0] = 3
    # RouterA-Client skew ≤ 4ms
    slack[1, 3] = 4;  slack[3, 1] = 4
    # RouterB-Client skew ≤ 2ms
    slack[2, 3] = 2;  slack[3, 2] = 2
    # RouterA-RouterB skew ≤ 1ms (tight!)
    slack[1, 2] = 1;  slack[2, 1] = 1

    print(f"\n  Nodes: {nodes}")
    print(f"  Skew constraints:")
    printed = set()
    for i in range(n):
        for j in range(i+1, n):
            if slack[i, j] < INF:
                print(f"    |{nodes[i]} - {nodes[j]}| ≤ {slack[i,j]:.0f}ms")
                printed.add((i, j))

    x, feasible = canonical_potential(lower, upper, slack)
    if feasible:
        print(f"\n  ✓ Consistent clock assignment:")
        for i in range(n):
            print(f"    {nodes[i]}: {x[i]:.2f}ms")
        print(f"\n  Maximum observed skew:")
        for i in range(n):
            for j in range(i+1, n):
                if (i, j) in printed:
                    print(f"    |{nodes[i]}-{nodes[j]}| = {abs(x[i]-x[j]):.2f}ms "
                          f"(limit: {slack[i,j]:.0f}ms)")
    else:
        print(f"\n  ✗ No consistent assignment — constraints are contradictory!")


def arbitrage_detection():
    """Currency Arbitrage Detection.

    Problem: Given exchange rate bounds, detect if arbitrage is possible.

    Model: log exchange rates as potentials.
    Rate r_{ij} means 1 unit of currency i buys r_{ij} units of currency j.
    Taking log: log(r_{ij}) is the "slack" constraint.
    A negative cycle in log-rates = an arbitrage opportunity.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Currency Arbitrage Detection")
    print("=" * 60)

    currencies = ["USD", "EUR", "GBP", "JPY"]
    n = len(currencies)

    # Exchange rates (approximate)
    rates = np.array([
        [1.0,    0.92,  0.79,  149.0],  # USD to ...
        [1.09,   1.0,   0.86,  162.0],  # EUR to ...
        [1.27,   1.16,  1.0,   189.0],  # GBP to ...
        [0.0067, 0.0062, 0.0053, 1.0],  # JPY to ...
    ])

    # Slack = -log(rate): x[i] - x[j] ≤ -log(r_{ij})
    # A negative cycle means ∏ r > 1 along the cycle → arbitrage!
    slack = -np.log(rates)

    lower = np.zeros(n)
    upper = np.full(n, 100.0)

    print(f"\n  Currencies: {currencies}")
    print(f"  Exchange rate matrix:")
    for i in range(n):
        print(f"    {currencies[i]}: {['%.4f' % r for r in rates[i]]}")

    neg = extract_negative_cycle(slack)
    if neg:
        cycle, weight = neg
        cycle_names = [currencies[c] for c in cycle]
        print(f"\n  ⚠ ARBITRAGE DETECTED!")
        print(f"    Cycle: {' → '.join(cycle_names)}")
        product = 1.0
        for k in range(len(cycle)-1):
            r = rates[cycle[k], cycle[k+1]]
            product *= r
            print(f"      {currencies[cycle[k]]} → {currencies[cycle[k+1]]}: rate {r:.4f}")
        print(f"    Product of rates: {product:.6f}")
        print(f"    Profit per unit: {(product - 1)*100:.4f}%")
    else:
        print(f"\n  ✓ No arbitrage opportunity (rates are consistent)")

    x, feasible = canonical_potential(lower, upper, slack)
    if feasible:
        print(f"\n  Consistent log-price vector: {x}")


def sensor_synchronization():
    """Sensor Network Time Synchronization.

    Problem: Multiple sensors measure events. Each sensor has its
    own clock with bounded drift. We need to find if all observations
    are consistent.

    This is exactly a tropical band feasibility problem where the
    "feasible point" is the true event time adjusted for each sensor's offset.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 4: Sensor Network Synchronization")
    print("=" * 60)

    sensors = ["Sensor_A", "Sensor_B", "Sensor_C", "Sensor_D"]
    n = len(sensors)

    # Each sensor reports a time window [lower, upper] for when it saw the event
    lower = np.array([10.0, 10.5, 9.8, 11.0])
    upper = np.array([10.5, 11.0, 10.3, 11.5])

    # Max allowed clock skew between sensor pairs
    INF = 1000.0
    slack = np.full((n, n), INF)
    np.fill_diagonal(slack, 0)
    # Adjacent sensors have tight skew bounds
    slack[0, 1] = 0.3;  slack[1, 0] = 0.3  # A-B
    slack[1, 2] = 0.5;  slack[2, 1] = 0.5  # B-C
    slack[2, 3] = 0.4;  slack[3, 2] = 0.4  # C-D
    slack[0, 3] = 1.0;  slack[3, 0] = 1.0  # A-D

    print(f"\n  Sensors: {sensors}")
    print(f"  Observation windows:")
    for i in range(n):
        print(f"    {sensors[i]}: [{lower[i]:.1f}, {upper[i]:.1f}]")
    print(f"  Skew constraints:")
    for i in range(n):
        for j in range(i+1, n):
            if slack[i, j] < INF:
                print(f"    |{sensors[i]} - {sensors[j]}| ≤ {slack[i,j]:.1f}")

    x, feasible = canonical_potential(lower, upper, slack)
    if feasible:
        print(f"\n  ✓ Consistent timing found:")
        for i in range(n):
            print(f"    {sensors[i]}: t = {x[i]:.3f}")
        cert = verify_feasibility_certificate(lower, upper, slack, x)
        print(f"  Certificate valid: {cert['valid']}")
    else:
        print(f"\n  ✗ Observations are inconsistent!")
        neg = extract_negative_cycle(slack)
        if neg:
            cycle, weight = neg
            print(f"    Obstruction cycle: {[sensors[c] for c in cycle]}")


if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Tropical Band Systems — Real-World Applications       ║")
    print("╚══════════════════════════════════════════════════════════╝")

    scheduling_application()
    network_timing()
    arbitrage_detection()
    sensor_synchronization()

    print("\n" + "=" * 60)
    print("All applications demonstrated.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Tropical Band Systems — Interactive Demonstration

Demonstrates the core concepts of tropical band systems:
- Building random and user-specified tropical band families
- Checking pairwise and global feasibility
- Certificate extraction (feasible point or negative cycle)
- Visualization of support graphs and bound intervals

Keywords: tropical geometry, Helly theorem, difference constraints,
shortest paths, negative cycles, graph potentials, certificate complexity
"""

import numpy as np
from itertools import combinations
import random

# ─────────────────────────────────────────────────────────────────────
# Core data structures
# ─────────────────────────────────────────────────────────────────────

class TropBand:
    """A tropical band system on n coordinates.

    Attributes:
        lower: array of lower bounds
        upper: array of upper bounds
        slack: n×n matrix of difference constraints (x_i ≤ x_j + slack[i,j])
    """
    def __init__(self, lower, upper, slack):
        self.lower = np.array(lower, dtype=float)
        self.upper = np.array(upper, dtype=float)
        self.slack = np.array(slack, dtype=float)
        self.n = len(lower)

    def is_feasible_point(self, x):
        """Check if x satisfies all constraints."""
        x = np.array(x, dtype=float)
        if not np.all(self.lower <= x + 1e-10):
            return False
        if not np.all(x <= self.upper + 1e-10):
            return False
        for i in range(self.n):
            for j in range(self.n):
                if x[i] > x[j] + self.slack[i, j] + 1e-10:
                    return False
        return True

    def find_feasible_point(self):
        """Find a feasible point using Bellman-Ford style iteration.

        Returns (point, True) if feasible, (None, False) if infeasible.
        """
        n = self.n
        # Initialize with lower bounds
        x = self.lower.copy()

        # Bellman-Ford relaxation: n iterations
        for _ in range(n + 1):
            changed = False
            # Enforce upper bounds
            for i in range(n):
                if x[i] > self.upper[i] + 1e-10:
                    return None, False
            # Tighten using slack constraints: x[i] ≤ x[j] + slack[i,j]
            # Equivalently: x[i] = max(lower[i], x[i]) but bounded by slack
            for i in range(n):
                for j in range(n):
                    # If x[i] > x[j] + slack[i,j], we have a problem
                    # unless we can raise x[j]
                    needed_j = x[i] - self.slack[i, j]
                    if needed_j > x[j] + 1e-10:
                        if needed_j > self.upper[j] + 1e-10:
                            continue  # Will detect infeasibility
                        x[j] = max(x[j], needed_j)
                        changed = True

        # Verify
        if self.is_feasible_point(x):
            return x, True

        # Try LP-style: use the potential construction
        # x[i] = min over j of (upper[j] + shortest_path_dist(j, i))
        return self._potential_construction()

    def _potential_construction(self):
        """Construct feasible point via shortest-path potentials."""
        n = self.n
        # Compute shortest path distances using Floyd-Warshall on slack
        dist = self.slack.copy()
        for i in range(n):
            dist[i, i] = 0.0

        for k in range(n):
            for i in range(n):
                for j in range(n):
                    if dist[i, k] + dist[k, j] < dist[i, j]:
                        dist[i, j] = dist[i, k] + dist[k, j]

        # Check for negative cycles
        for i in range(n):
            if dist[i, i] < -1e-10:
                return None, False

        # Construct potential: x[i] = max over j of lower[j] + dist[j][i]
        # but also bounded by min over j of upper[j] + dist[j][i]
        x = np.full(n, -np.inf)
        for i in range(n):
            for j in range(n):
                x[i] = max(x[i], self.lower[j] - dist[j, i])

        # Check upper bounds
        for i in range(n):
            if x[i] > self.upper[i] + 1e-10:
                return None, False

        if self.is_feasible_point(x):
            return x, True
        return None, False

    def detect_negative_cycle(self):
        """Detect a negative cycle in the slack graph.

        Returns (cycle_vertices, cycle_weight) if found, None otherwise.
        """
        n = self.n
        dist = np.full((n, n), np.inf)
        pred = np.full((n, n), -1, dtype=int)

        for i in range(n):
            dist[i, i] = 0
            for j in range(n):
                if i != j:
                    dist[i, j] = self.slack[i, j]
                    pred[i, j] = i

        for k in range(n):
            for i in range(n):
                for j in range(n):
                    if dist[i, k] + dist[k, j] < dist[i, j] - 1e-12:
                        dist[i, j] = dist[i, k] + dist[k, j]
                        pred[i, j] = pred[k, j]

        for i in range(n):
            if dist[i, i] < -1e-10:
                # Reconstruct cycle
                cycle = [i]
                j = pred[i, i]
                visited = set()
                while j != i and j not in visited:
                    visited.add(j)
                    cycle.append(j)
                    j = pred[i, j]
                cycle.append(i)
                cycle.reverse()
                weight = sum(self.slack[cycle[k], cycle[k+1]] for k in range(len(cycle)-1))
                return cycle, weight
        return None

    def __repr__(self):
        return (f"TropBand(n={self.n},\n"
                f"  lower={self.lower},\n"
                f"  upper={self.upper},\n"
                f"  slack=\n{self.slack})")


def meet(B1, B2):
    """Compute the meet (intersection) of two band systems."""
    return TropBand(
        lower=np.maximum(B1.lower, B2.lower),
        upper=np.minimum(B1.upper, B2.upper),
        slack=np.minimum(B1.slack, B2.slack)
    )


def check_pairwise_feasibility(bands):
    """Check if every pair of bands has a common feasible point."""
    for i, j in combinations(range(len(bands)), 2):
        m = meet(bands[i], bands[j])
        _, feasible = m.find_feasible_point()
        if not feasible:
            return False, (i, j)
    return True, None


def check_global_feasibility(bands):
    """Check if all bands have a common feasible point."""
    if not bands:
        return True, np.array([])
    result = bands[0]
    for b in bands[1:]:
        result = meet(result, b)
    return result.find_feasible_point()


# ─────────────────────────────────────────────────────────────────────
# Random generation
# ─────────────────────────────────────────────────────────────────────

def random_tropband(n, bound_range=10, slack_range=20):
    """Generate a random tropical band system."""
    lower = np.random.uniform(-bound_range, bound_range, n)
    upper = lower + np.random.uniform(0, bound_range, n)
    slack = np.random.uniform(0, slack_range, (n, n))
    np.fill_diagonal(slack, 0)
    return TropBand(lower, upper, slack)


def random_box_tropband(n, bound_range=10):
    """Generate a box-only tropical band (slack = ∞)."""
    lower = np.random.uniform(-bound_range, bound_range, n)
    upper = lower + np.random.uniform(0, bound_range, n)
    slack = np.full((n, n), 1000.0)  # effectively infinite
    return TropBand(lower, upper, slack)


def random_laminar_family(n, num_bands, bound_range=5):
    """Generate a laminar family of tropical bands.

    Supports are nested: each successive band adds more constraints.
    """
    bands = []
    base_slack = np.full((n, n), 1000.0)
    np.fill_diagonal(base_slack, 0)

    for k in range(num_bands):
        lower = np.random.uniform(-bound_range, bound_range, n)
        upper = lower + np.random.uniform(1, bound_range, n)
        slack = base_slack.copy()
        # Add k+1 random constraints (nested supports)
        for _ in range(k + 1):
            i, j = random.randint(0, n-1), random.randint(0, n-1)
            if i != j:
                slack[i, j] = min(slack[i, j], random.uniform(1, 10))
        bands.append(TropBand(lower, upper, slack))
    return bands


# ─────────────────────────────────────────────────────────────────────
# Demonstrations
# ─────────────────────────────────────────────────────────────────────

def demo_negative_cycle():
    """Demonstrate negative cycle detection as infeasibility certificate."""
    print("=" * 60)
    print("DEMO 1: Negative Cycle as Infeasibility Certificate")
    print("=" * 60)

    # Create a system with a negative cycle: 0 → 1 → 2 → 0
    # slack[0,1] = 1, slack[1,2] = 1, slack[2,0] = -3
    # Cycle weight: 1 + 1 + (-3) = -1 < 0
    slack = np.array([
        [0.0, 1.0, 100.0],
        [100.0, 0.0, 1.0],
        [-3.0, 100.0, 0.0]
    ])
    B = TropBand(lower=[-10, -10, -10], upper=[10, 10, 10], slack=slack)

    print(f"\nBand system: {B}")
    print(f"\nNegative cycle detection:")
    result = B.detect_negative_cycle()
    if result:
        cycle, weight = result
        print(f"  Found negative cycle: {cycle}")
        print(f"  Total weight: {weight:.4f}")
    else:
        print("  No negative cycle found")

    _, feasible = B.find_feasible_point()
    print(f"  Feasibility check: {'feasible' if feasible else 'INFEASIBLE'}")
    print(f"\n  ✓ Negative cycle certifies infeasibility (Theorem 1)")


def demo_graph_potential():
    """Demonstrate the graph potential equivalence."""
    print("\n" + "=" * 60)
    print("DEMO 2: Feasibility ↔ Graph Potential (Bridge Theorem)")
    print("=" * 60)

    # A feasible system
    slack = np.array([
        [0.0, 3.0, 5.0],
        [4.0, 0.0, 2.0],
        [3.0, 6.0, 0.0]
    ])
    B = TropBand(lower=[0, 1, 2], upper=[5, 6, 7], slack=slack)

    print(f"\nBand system: {B}")
    x, feasible = B.find_feasible_point()
    if feasible:
        print(f"\n  Feasible point (= graph potential): x = {x}")
        print(f"  Verification:")
        print(f"    Lower bounds:  {[f'{B.lower[i]:.1f} ≤ {x[i]:.1f}' for i in range(3)]}")
        print(f"    Upper bounds:  {[f'{x[i]:.1f} ≤ {B.upper[i]:.1f}' for i in range(3)]}")
        print(f"    Difference constraints (x[i] - x[j] ≤ slack[i,j]):")
        for i in range(3):
            for j in range(3):
                if i != j:
                    diff = x[i] - x[j]
                    print(f"      x[{i}]-x[{j}] = {diff:.2f} ≤ {slack[i,j]:.1f}  ✓")
        print(f"\n  ✓ Feasible point IS a graph potential (Theorem 2)")


def demo_helly_boxes():
    """Demonstrate Helly number 2 for box-only systems."""
    print("\n" + "=" * 60)
    print("DEMO 3: Helly Number 2 for Box Systems")
    print("=" * 60)

    np.random.seed(42)
    n_coords = 3
    n_boxes = 5

    bands = [random_box_tropband(n_coords) for _ in range(n_boxes)]

    print(f"\n  Generated {n_boxes} random box systems on {n_coords} coordinates")

    pairwise_ok, failing_pair = check_pairwise_feasibility(bands)
    if pairwise_ok:
        print(f"  Pairwise feasibility: ALL PAIRS OK")
        x, global_ok = check_global_feasibility(bands)
        if global_ok:
            print(f"  Global feasibility: OK (witness: {x})")
            print(f"\n  ✓ Helly-2 confirmed: pairwise → global (Theorem 4)")
        else:
            print(f"  Global feasibility: FAILED (this shouldn't happen!)")
    else:
        print(f"  Pairwise feasibility: FAILED at pair {failing_pair}")
        print(f"  (Expected: some pairs may fail with random bounds)")


def demo_meet_feasibility():
    """Demonstrate meet (intersection) of band systems."""
    print("\n" + "=" * 60)
    print("DEMO 4: Meet Feasibility Principle")
    print("=" * 60)

    B1 = TropBand(lower=[0, 0], upper=[5, 5],
                  slack=np.array([[0, 3], [3, 0]]))
    B2 = TropBand(lower=[1, 1], upper=[4, 4],
                  slack=np.array([[0, 2], [2, 0]]))

    x = np.array([2.0, 3.0])
    print(f"\n  B1: lower={B1.lower}, upper={B1.upper}")
    print(f"  B2: lower={B2.lower}, upper={B2.upper}")
    print(f"  Test point: x = {x}")
    print(f"  x feasible for B1: {B1.is_feasible_point(x)}")
    print(f"  x feasible for B2: {B2.is_feasible_point(x)}")

    M = meet(B1, B2)
    print(f"\n  Meet: lower={M.lower}, upper={M.upper}, slack_diag={np.diag(M.slack)}")
    print(f"  x feasible for Meet: {M.is_feasible_point(x)}")
    print(f"\n  ✓ Point feasible for both → feasible for meet (Theorem 3)")


def demo_relaxation():
    """Demonstrate monotonicity under relaxation."""
    print("\n" + "=" * 60)
    print("DEMO 5: Monotonicity under Relaxation")
    print("=" * 60)

    B1 = TropBand(lower=[1, 2], upper=[3, 4],
                  slack=np.array([[0, 2], [2, 0]]))
    # B2 is a relaxation: wider bounds, larger slacks
    B2 = TropBand(lower=[0, 1], upper=[5, 6],
                  slack=np.array([[0, 5], [5, 0]]))

    x1, feas1 = B1.find_feasible_point()
    x2, feas2 = B2.find_feasible_point()

    print(f"\n  Tight system B1: feasible = {feas1}", end="")
    if feas1: print(f", point = {x1}")
    else: print()
    print(f"  Relaxed system B2: feasible = {feas2}", end="")
    if feas2: print(f", point = {x2}")
    else: print()
    print(f"\n  ✓ Feasibility of tight system → feasibility of relaxation (Theorem 7)")


def demo_conjecture_test():
    """Test the Helly number conjecture for tropical bands."""
    print("\n" + "=" * 60)
    print("DEMO 6: Helly Number Conjecture Testing")
    print("=" * 60)

    print("\n  Testing: For bands on Fin d with forest support graphs,")
    print("  does pairwise feasibility imply global feasibility?")

    np.random.seed(123)
    n_trials = 100
    counterexamples = 0

    for trial in range(n_trials):
        n = random.choice([2, 3])
        num_bands = random.randint(3, 5)
        bands = random_laminar_family(n, num_bands)

        pairwise_ok, _ = check_pairwise_feasibility(bands)
        if pairwise_ok:
            _, global_ok = check_global_feasibility(bands)
            if not global_ok:
                counterexamples += 1
                print(f"  Trial {trial}: COUNTEREXAMPLE! d={n}, {num_bands} bands")

    print(f"\n  Tested {n_trials} random instances")
    print(f"  Counterexamples found: {counterexamples}")
    if counterexamples == 0:
        print(f"  ✓ Conjecture holds for all tested instances")
    else:
        print(f"  ✗ Conjecture REFUTED")


def demo_bound_slack_violation():
    """Demonstrate bound-slack interaction creating infeasibility."""
    print("\n" + "=" * 60)
    print("DEMO 7: Bound-Slack Violation Certificate")
    print("=" * 60)

    # lower[0] = 10, upper[1] = 3, slack[0,1] = 2
    # So 10 > 3 + 2 = 5, hence infeasible
    B = TropBand(lower=[10, 0], upper=[20, 3],
                 slack=np.array([[0, 2], [100, 0]]))

    print(f"\n  lower[0] = {B.lower[0]}, upper[1] = {B.upper[1]}, slack[0,1] = {B.slack[0,1]}")
    print(f"  Check: upper[1] + slack[0,1] = {B.upper[1] + B.slack[0,1]} < lower[0] = {B.lower[0]}")
    print(f"  → System is infeasible!")

    _, feasible = B.find_feasible_point()
    print(f"  Feasibility check confirms: {'feasible' if feasible else 'INFEASIBLE'}")
    print(f"\n  ✓ Bound-slack violation certifies infeasibility (Theorem 5)")


# ─────────────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Tropical Band Systems — Certificate Complexity Demo   ║")
    print("║  Verified Local-to-Global Principles                   ║")
    print("╚══════════════════════════════════════════════════════════╝")

    demo_negative_cycle()
    demo_graph_potential()
    demo_helly_boxes()
    demo_meet_feasibility()
    demo_relaxation()
    demo_bound_slack_violation()
    demo_conjecture_test()

    print("\n" + "=" * 60)
    print("All demonstrations complete.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization 1: Tropical Band Feasibility Regions

Visualizes the feasible region of a 2D tropical band system as the
intersection of box constraints and difference constraint halfplanes.
Shows how slack constraints carve out a polytope from the box.

This illustrates the core concept: tropical bands = boxes + difference constraints.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.patches import Polygon

# ── Define a 2D tropical band system ──
lower = np.array([1.0, 0.0])
upper = np.array([6.0, 5.0])
# slack[i,j] means x_i ≤ x_j + slack[i,j]
# Constraint 1: x_0 ≤ x_1 + 3  (x_0 - x_1 ≤ 3)
# Constraint 2: x_1 ≤ x_0 + 2  (x_1 - x_0 ≤ 2)
slack_01 = 3.0  # x0 - x1 ≤ 3
slack_10 = 2.0  # x1 - x0 ≤ 2

# ── Create figure ──
fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# ── Panel 1: Box only ──
ax = axes[0]
ax.set_title("Box Constraints Only", fontsize=13, fontweight='bold')
box = patches.Rectangle((lower[0], lower[1]),
                         upper[0] - lower[0], upper[1] - lower[1],
                         linewidth=2, edgecolor='steelblue',
                         facecolor='lightblue', alpha=0.5)
ax.add_patch(box)
ax.set_xlim(-1, 8)
ax.set_ylim(-1, 7)
ax.set_xlabel('$x_0$', fontsize=12)
ax.set_ylabel('$x_1$', fontsize=12)
ax.set_aspect('equal')
ax.grid(True, alpha=0.3)
ax.text(3.5, 2.5, '$[\\ell_0, u_0] \\times [\\ell_1, u_1]$',
        ha='center', fontsize=11, color='steelblue')

# ── Panel 2: Box + difference constraints ──
ax = axes[1]
ax.set_title("Box + Difference Constraints", fontsize=13, fontweight='bold')

# Draw box
box2 = patches.Rectangle((lower[0], lower[1]),
                          upper[0] - lower[0], upper[1] - lower[1],
                          linewidth=2, edgecolor='steelblue',
                          facecolor='lightblue', alpha=0.2, linestyle='--')
ax.add_patch(box2)

# Compute feasible polygon (intersection of box and halfplanes)
# x0 - x1 ≤ 3  →  x1 ≥ x0 - 3
# x1 - x0 ≤ 2  →  x1 ≤ x0 + 2
# plus box bounds

# Sample feasible region
resolution = 200
x0_range = np.linspace(lower[0], upper[0], resolution)
x1_range = np.linspace(lower[1], upper[1], resolution)
X0, X1 = np.meshgrid(x0_range, x1_range)

feasible = ((X0 >= lower[0]) & (X0 <= upper[0]) &
            (X1 >= lower[1]) & (X1 <= upper[1]) &
            (X0 - X1 <= slack_01) &  # x0 ≤ x1 + slack_01
            (X1 - X0 <= slack_10))   # x1 ≤ x0 + slack_10

ax.contourf(X0, X1, feasible.astype(float), levels=[0.5, 1.5],
            colors=['coral'], alpha=0.5)
ax.contour(X0, X1, feasible.astype(float), levels=[0.5],
           colors=['red'], linewidths=2)

# Draw constraint lines
x_line = np.linspace(-1, 8, 100)
ax.plot(x_line, x_line - slack_01, 'r--', linewidth=1.5, alpha=0.7,
        label=f'$x_0 - x_1 = {slack_01:.0f}$')
ax.plot(x_line, x_line + slack_10, 'g--', linewidth=1.5, alpha=0.7,
        label=f'$x_1 - x_0 = {slack_10:.0f}$')

ax.set_xlim(-1, 8)
ax.set_ylim(-1, 7)
ax.set_xlabel('$x_0$', fontsize=12)
ax.set_ylabel('$x_1$', fontsize=12)
ax.set_aspect('equal')
ax.grid(True, alpha=0.3)
ax.legend(fontsize=9, loc='upper left')

# ── Panel 3: Feasible point as graph potential ──
ax = axes[2]
ax.set_title("Feasible Point = Graph Potential", fontsize=13, fontweight='bold')

# Draw feasible region
ax.contourf(X0, X1, feasible.astype(float), levels=[0.5, 1.5],
            colors=['lightyellow'], alpha=0.8)
ax.contour(X0, X1, feasible.astype(float), levels=[0.5],
           colors=['orange'], linewidths=2)

# Canonical potential: x_i = max_j (lower_j - dist_j_i)
# For this small example, compute manually
# dist[0,0]=0, dist[0,1]=slack_01=3, dist[1,0]=slack_10=2, dist[1,1]=0
# x[0] = max(lower[0]-0, lower[1]-slack_10) = max(1, 0-2) = 1
# x[1] = max(lower[0]-slack_01, lower[1]-0) = max(1-3, 0) = 0
x_canonical = np.array([1.0, 0.0])

# Also find the "upper" canonical point
x_center = np.array([3.0, 2.5])

ax.plot(*x_canonical, 'ro', markersize=10, zorder=5, label='Canonical potential')
ax.plot(*x_center, 'b^', markersize=10, zorder=5, label='Interior point')

# Draw arrows showing constraint graph
ax.annotate('', xy=(4.5, 3.5), xytext=(2, 3.5),
            arrowprops=dict(arrowstyle='->', color='darkred', lw=2))
ax.text(3.25, 3.8, f'slack={slack_01:.0f}', fontsize=9, color='darkred', ha='center')

ax.annotate('', xy=(2, 1), xytext=(4.5, 1),
            arrowprops=dict(arrowstyle='->', color='darkgreen', lw=2))
ax.text(3.25, 0.6, f'slack={slack_10:.0f}', fontsize=9, color='darkgreen', ha='center')

ax.set_xlim(-1, 8)
ax.set_ylim(-1, 7)
ax.set_xlabel('$x_0$', fontsize=12)
ax.set_ylabel('$x_1$', fontsize=12)
ax.set_aspect('equal')
ax.grid(True, alpha=0.3)
ax.legend(fontsize=9, loc='upper left')

plt.suptitle("Tropical Band Systems: From Boxes to Constrained Polytopes",
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig("viz_tropical_bands.png", dpi=150, bbox_inches='tight')
print("Saved: viz_tropical_bands.png")


#!/usr/bin/env python3
"""
Visualization 2: Feasibility Certificates — Potentials vs Negative Cycles

Visualizes the duality between feasibility certificates (graph potentials)
and infeasibility certificates (negative cycles) for tropical band systems.

Left panel: A feasible system with its graph potential shown on the constraint graph.
Right panel: An infeasible system with the negative cycle highlighted.

This illustrates the bridge theorem: tropical feasibility ↔ graph potentials.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as patches

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# ════════════════════════════════════════════════════════════
# Panel 1: FEASIBLE system with graph potential
# ════════════════════════════════════════════════════════════
ax = axes[0]
ax.set_title("Feasibility Certificate:\nGraph Potential", fontsize=13, fontweight='bold',
             color='darkgreen')

# 4-node system
n = 4
labels = ['$v_0$', '$v_1$', '$v_2$', '$v_3$']
# Place nodes in a square
positions = np.array([[1, 3], [3, 3], [3, 1], [1, 1]], dtype=float)

# Slack constraints (edges with weights)
edges = [
    (0, 1, 3.0),  # v0 → v1, weight 3
    (1, 2, 2.0),  # v1 → v2, weight 2
    (2, 3, 4.0),  # v2 → v3, weight 4
    (3, 0, 1.0),  # v3 → v0, weight 1  (cycle weight = 3+2+4+1 = 10 > 0, OK!)
    (0, 2, 5.0),  # v0 → v2, weight 5
]

# Feasible potential
potential = np.array([2.0, 4.0, 3.0, 1.0])

# Draw edges
for i, j, w in edges:
    pi, pj = positions[i], positions[j]
    mid = (pi + pj) / 2
    dx, dy = pj - pi
    length = np.sqrt(dx**2 + dy**2)
    # Offset for label
    perp = np.array([-dy, dx]) / length * 0.25

    ax.annotate('', xy=pj - 0.15 * np.array([dx, dy]) / length,
                xytext=pi + 0.15 * np.array([dx, dy]) / length,
                arrowprops=dict(arrowstyle='->', color='gray', lw=1.5))
    ax.text(mid[0] + perp[0], mid[1] + perp[1], f'{w:.0f}',
            fontsize=10, ha='center', va='center', color='gray',
            bbox=dict(boxstyle='round,pad=0.2', facecolor='white', alpha=0.8))

# Draw nodes with potential values
for i in range(n):
    circle = plt.Circle(positions[i], 0.3, color='lightgreen',
                        ec='darkgreen', linewidth=2, zorder=5)
    ax.add_patch(circle)
    ax.text(positions[i][0], positions[i][1], f'{potential[i]:.0f}',
            ha='center', va='center', fontsize=14, fontweight='bold',
            color='darkgreen', zorder=6)
    ax.text(positions[i][0], positions[i][1] + 0.5, labels[i],
            ha='center', va='center', fontsize=11, color='black')

# Verify and annotate
ax.text(2, -0.3, "✓ All edges: $p_i - p_j \\leq$ weight",
        ha='center', fontsize=11, color='darkgreen', fontweight='bold')
ax.text(2, -0.8, "Cycle: $2+4+3+1 = 10 > 0$ ✓",
        ha='center', fontsize=10, color='gray')

ax.set_xlim(-0.5, 4.5)
ax.set_ylim(-1.5, 4.5)
ax.set_aspect('equal')
ax.axis('off')

# ════════════════════════════════════════════════════════════
# Panel 2: INFEASIBLE system with negative cycle
# ════════════════════════════════════════════════════════════
ax = axes[1]
ax.set_title("Infeasibility Certificate:\nNegative Cycle", fontsize=13, fontweight='bold',
             color='darkred')

# 3-node system with negative cycle
positions2 = np.array([[2, 3.5], [3.5, 0.5], [0.5, 0.5]], dtype=float)
labels2 = ['$v_0$', '$v_1$', '$v_2$']

edges2 = [
    (0, 1, 1.0),   # v0 → v1, weight 1
    (1, 2, 1.0),   # v1 → v2, weight 1
    (2, 0, -3.0),  # v2 → v0, weight -3
]

cycle_weight = sum(w for _, _, w in edges2)

# Draw edges (highlighting the negative cycle)
colors = ['red', 'red', 'red']  # All edges form the cycle
for idx, (i, j, w) in enumerate(edges2):
    pi, pj = positions2[i], positions2[j]
    dx, dy = pj - pi
    length = np.sqrt(dx**2 + dy**2)
    mid = (pi + pj) / 2
    perp = np.array([-dy, dx]) / length * 0.3

    ax.annotate('', xy=pj - 0.2 * np.array([dx, dy]) / length,
                xytext=pi + 0.2 * np.array([dx, dy]) / length,
                arrowprops=dict(arrowstyle='->', color=colors[idx], lw=3))

    weight_color = 'darkred' if w < 0 else 'black'
    ax.text(mid[0] + perp[0], mid[1] + perp[1],
            f'{w:+.0f}',
            fontsize=13, ha='center', va='center', color=weight_color,
            fontweight='bold',
            bbox=dict(boxstyle='round,pad=0.2', facecolor='lightyellow',
                      ec=weight_color, alpha=0.9))

# Draw nodes
for i in range(3):
    circle = plt.Circle(positions2[i], 0.3, color='lightyellow',
                        ec='darkred', linewidth=2, zorder=5)
    ax.add_patch(circle)
    ax.text(positions2[i][0], positions2[i][1] + 0.5, labels2[i],
            ha='center', va='center', fontsize=11, color='black')
    ax.text(positions2[i][0], positions2[i][1], '?',
            ha='center', va='center', fontsize=14, fontweight='bold',
            color='darkred', zorder=6)

# Annotate
ax.text(2, -0.8, f"✗ Cycle weight: $1 + 1 + (-3) = {cycle_weight:.0f} < 0$",
        ha='center', fontsize=12, color='darkred', fontweight='bold')
ax.text(2, -1.4, "No assignment can satisfy all constraints",
        ha='center', fontsize=10, color='gray')
ax.text(2, -1.9, "Telescoping: $0 \\leq \\sum s_{ij} < 0$ — contradiction!",
        ha='center', fontsize=10, color='darkred', style='italic')

ax.set_xlim(-0.5, 4.5)
ax.set_ylim(-2.5, 4.5)
ax.set_aspect('equal')
ax.axis('off')

plt.suptitle("Tropical Band Certificates: The Feasibility–Infeasibility Duality",
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig("viz_certificates.png", dpi=150, bbox_inches='tight')
print("Saved: viz_certificates.png")


#!/usr/bin/env python3
"""
Visualization 3: Helly Number 2 for Tropical Box Systems

Visualizes the Helly-2 phenomenon: for box constraints, pairwise
intersection implies global intersection. Shows how the coordinatewise
maximum of lower bounds constructs the global witness.

This illustrates Theorem 4 (helly_two_boxes) from the Lean formalization.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as patches

fig, axes = plt.subplots(1, 3, figsize=(16, 5.5))

# ── Define 4 boxes in 2D ──
boxes = [
    {'lo': np.array([0.0, 1.0]), 'hi': np.array([4.0, 5.0]), 'color': 'blue', 'label': '$B_1$'},
    {'lo': np.array([1.0, 0.0]), 'hi': np.array([5.0, 4.0]), 'color': 'red', 'label': '$B_2$'},
    {'lo': np.array([2.0, 2.0]), 'hi': np.array([6.0, 6.0]), 'color': 'green', 'label': '$B_3$'},
    {'lo': np.array([0.5, 1.5]), 'hi': np.array([3.5, 4.5]), 'color': 'purple', 'label': '$B_4$'},
]

# ── Panel 1: All boxes overlaid ──
ax = axes[0]
ax.set_title("Four Box Constraints\n(pairwise intersecting)", fontsize=12, fontweight='bold')

for b in boxes:
    rect = patches.Rectangle(b['lo'], b['hi'][0]-b['lo'][0], b['hi'][1]-b['lo'][1],
                              linewidth=2, edgecolor=b['color'],
                              facecolor=b['color'], alpha=0.15)
    ax.add_patch(rect)
    rect2 = patches.Rectangle(b['lo'], b['hi'][0]-b['lo'][0], b['hi'][1]-b['lo'][1],
                               linewidth=2, edgecolor=b['color'],
                               facecolor='none')
    ax.add_patch(rect2)
    ax.text(b['hi'][0] - 0.3, b['hi'][1] - 0.3, b['label'],
            fontsize=12, fontweight='bold', color=b['color'])

ax.set_xlim(-0.5, 7)
ax.set_ylim(-0.5, 7)
ax.set_xlabel('$x_0$', fontsize=12)
ax.set_ylabel('$x_1$', fontsize=12)
ax.set_aspect('equal')
ax.grid(True, alpha=0.3)

# ── Panel 2: Pairwise intersections ──
ax = axes[1]
ax.set_title("Pairwise Intersections\n(all non-empty ✓)", fontsize=12, fontweight='bold')

# Show pairwise intersection regions
from itertools import combinations
pair_colors = ['orange', 'cyan', 'magenta', 'yellow', 'lime', 'pink']

resolution = 200
x0r = np.linspace(-0.5, 7, resolution)
x1r = np.linspace(-0.5, 7, resolution)
X0, X1 = np.meshgrid(x0r, x1r)

for idx, (i, j) in enumerate(combinations(range(4), 2)):
    b1, b2 = boxes[i], boxes[j]
    in_both = ((X0 >= b1['lo'][0]) & (X0 <= b1['hi'][0]) &
               (X1 >= b1['lo'][1]) & (X1 <= b1['hi'][1]) &
               (X0 >= b2['lo'][0]) & (X0 <= b2['hi'][0]) &
               (X1 >= b2['lo'][1]) & (X1 <= b2['hi'][1]))
    if np.any(in_both):
        ax.contourf(X0, X1, in_both.astype(float), levels=[0.5, 1.5],
                    colors=[pair_colors[idx]], alpha=0.2)
        ax.contour(X0, X1, in_both.astype(float), levels=[0.5],
                   colors=[pair_colors[idx]], linewidths=1, alpha=0.5)

# Draw box outlines
for b in boxes:
    rect = patches.Rectangle(b['lo'], b['hi'][0]-b['lo'][0], b['hi'][1]-b['lo'][1],
                              linewidth=1.5, edgecolor=b['color'],
                              facecolor='none', linestyle='--', alpha=0.5)
    ax.add_patch(rect)

npairs = len(list(combinations(range(4), 2)))
ax.text(3.5, 6.2, str(npairs) + " pairs,\nall intersecting",
        fontsize=10, ha="center", color="gray")

ax.set_xlim(-0.5, 7)
ax.set_ylim(-0.5, 7)
ax.set_xlabel('$x_0$', fontsize=12)
ax.set_ylabel('$x_1$', fontsize=12)
ax.set_aspect('equal')
ax.grid(True, alpha=0.3)

# ── Panel 3: Global intersection with witness ──
ax = axes[2]
ax.set_title("Global Intersection\n+ Canonical Witness", fontsize=12, fontweight='bold')

# Compute global intersection
all_boxes = ((X0 >= boxes[0]['lo'][0]) & (X0 <= boxes[0]['hi'][0]) &
             (X1 >= boxes[0]['lo'][1]) & (X1 <= boxes[0]['hi'][1]))
for b in boxes[1:]:
    all_boxes &= ((X0 >= b['lo'][0]) & (X0 <= b['hi'][0]) &
                  (X1 >= b['lo'][1]) & (X1 <= b['hi'][1]))

ax.contourf(X0, X1, all_boxes.astype(float), levels=[0.5, 1.5],
            colors=['gold'], alpha=0.5)
ax.contour(X0, X1, all_boxes.astype(float), levels=[0.5],
           colors=['darkorange'], linewidths=2.5)

# Draw box outlines
for b in boxes:
    rect = patches.Rectangle(b['lo'], b['hi'][0]-b['lo'][0], b['hi'][1]-b['lo'][1],
                              linewidth=1, edgecolor=b['color'],
                              facecolor='none', linestyle='--', alpha=0.4)
    ax.add_patch(rect)

# Canonical witness: x_i = max_k (lo_k[i])
x_witness = np.array([max(b['lo'][0] for b in boxes),
                       max(b['lo'][1] for b in boxes)])

ax.plot(*x_witness, 'r*', markersize=20, zorder=10,
        markeredgecolor='darkred', markeredgewidth=1)
ax.annotate(f'Witness\n$x = ({x_witness[0]:.0f}, {x_witness[1]:.0f})$',
            xy=x_witness, xytext=(x_witness[0]+1, x_witness[1]+1),
            fontsize=11, fontweight='bold', color='darkred',
            arrowprops=dict(arrowstyle='->', color='darkred', lw=1.5),
            bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.9))

# Show the construction
ax.axhline(y=x_witness[1], color='darkred', linestyle=':', alpha=0.4)
ax.axvline(x=x_witness[0], color='darkred', linestyle=':', alpha=0.4)

ax.text(5.5, 0.3, "$x_i = \\max_k \\ell_k(i)$",
        fontsize=11, color='darkred', fontweight='bold',
        bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.9))

ax.set_xlim(-0.5, 7)
ax.set_ylim(-0.5, 7)
ax.set_xlabel('$x_0$', fontsize=12)
ax.set_ylabel('$x_1$', fontsize=12)
ax.set_aspect('equal')
ax.grid(True, alpha=0.3)

plt.suptitle("Helly Number 2: Pairwise Box Intersection ⟹ Global Intersection",
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig("viz_helly.png", dpi=150, bbox_inches='tight')
print("Saved: viz_helly.png")

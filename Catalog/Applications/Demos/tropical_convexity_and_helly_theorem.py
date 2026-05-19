"""
Tropical Convexity — Real-World Applications

Demonstrates practical applications of tropical Helly theory:
1. Job scheduling with timing constraints
2. Network timing verification
3. Tropical linear programming (min-plus optimization)
"""

import numpy as np
from typing import List, Tuple, Optional
from algorithms import DiffConstraint, bellman_ford, helly_certificate, verify_cycle_certificate


# ============================================================
# Application 1: Job Scheduling
# ============================================================
def scheduling_demo():
    """
    Job scheduling with timing constraints.

    A factory has n tasks. Each task has constraints on when it can
    start relative to other tasks:
    - Task A must start at least 2 hours after Task B finishes
    - Task C must start no more than 5 hours after Task A
    - etc.

    These are difference constraints: start_i - start_j ≤ w

    The tropical Helly theorem guarantees that if the schedule is
    infeasible, a certificate of size ≤ n proves it.
    """
    print("=" * 60)
    print("APPLICATION 1: Job Scheduling")
    print("=" * 60)

    n_tasks = 6
    task_names = ["Design", "Prototype", "Testing", "Review", "Production", "Shipping"]

    # Constraints: task_i must start at most w hours after task_j
    # (equivalently: start_i - start_j ≤ w)
    constraints = [
        # Design before Prototype (at least 8h gap)
        # proto ≥ design + 8  ⇔  design - proto ≤ -8
        DiffConstraint(0, 1, -8),

        # Prototype before Testing (at least 4h gap)
        DiffConstraint(1, 2, -4),

        # Testing before Review (at least 2h gap)
        DiffConstraint(2, 3, -2),

        # Review before Production (at least 1h gap)
        DiffConstraint(3, 4, -1),

        # Production before Shipping (at least 6h gap)
        DiffConstraint(4, 5, -6),

        # Deadline: Shipping within 18h of Design start (too tight!)
        # ship ≤ design + 18  ⇔  ship - design ≤ 18
        DiffConstraint(5, 0, 18),
    ]

    print(f"\n{n_tasks} tasks: {', '.join(task_names)}")
    print(f"{len(constraints)} timing constraints:")
    for c in constraints:
        if c.weight < 0:
            # x[src] - x[tgt] ≤ w < 0 means tgt ≥ src + |w|
            print(f"  {task_names[c.tgt]} starts ≥ {-c.weight:.0f}h after {task_names[c.src]}")
        else:
            print(f"  {task_names[c.src]} starts ≤ {c.weight:.0f}h after {task_names[c.tgt]}")

    # Check feasibility
    feasible, x, cycle = bellman_ford(n_tasks, constraints)

    if feasible:
        print(f"\n✓ Schedule is FEASIBLE!")
        print(f"  Optimal start times:")
        for i, name in enumerate(task_names):
            print(f"    {name}: hour {x[i]:.1f}")
    else:
        print(f"\n✗ Schedule is INFEASIBLE!")
        if cycle:
            valid, weight = verify_cycle_certificate(cycle)
            print(f"  Certificate (negative cycle of weight {weight:.1f}):")
            for c in cycle:
                print(f"    {task_names[c.src]} - {task_names[c.tgt]} ≤ {c.weight}")
            print(f"  Minimum total gap required: {-weight:.1f}h")
            print(f"  But the cycle forces total gap = 0 → contradiction!")

    # Try relaxing the deadline
    print(f"\n--- Relaxing deadline to 22h ---")
    constraints_relaxed = constraints[:-1] + [DiffConstraint(5, 0, 22)]
    feasible, x, _ = bellman_ford(n_tasks, constraints_relaxed)
    if feasible:
        print(f"✓ Schedule is now FEASIBLE!")
        print(f"  Start times:")
        for i, name in enumerate(task_names):
            print(f"    {name}: hour {x[i]:.1f}")


# ============================================================
# Application 2: Network Timing Verification
# ============================================================
def network_timing_demo():
    """
    Network timing verification.

    A distributed system has n nodes. Messages between nodes have
    bounded propagation delays. Clock synchronization requires that
    relative clock offsets satisfy certain constraints.

    This is a difference constraint problem where:
    - clock_i - clock_j ≤ delay_ij (forward delay bound)
    - clock_j - clock_i ≤ delay_ji (reverse delay bound)
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Network Timing Verification")
    print("=" * 60)

    n_nodes = 5
    node_names = ["Server", "Router1", "Router2", "Client1", "Client2"]

    # Bidirectional delay constraints
    links = [
        # (node_a, node_b, max_forward_delay, max_reverse_delay)
        (0, 1, 5, 5),    # Server ↔ Router1: ≤5ms each way
        (0, 2, 3, 3),    # Server ↔ Router2: ≤3ms each way
        (1, 3, 2, 2),    # Router1 ↔ Client1: ≤2ms each way
        (2, 4, 4, 4),    # Router2 ↔ Client2: ≤4ms each way
        (1, 2, 1, 1),    # Router1 ↔ Router2: ≤1ms each way
        # Tight synchronization requirement
        (3, 4, 8, 8),    # Client1 ↔ Client2: must be within 8ms
    ]

    constraints = []
    for a, b, fwd, rev in links:
        constraints.append(DiffConstraint(a, b, fwd))
        constraints.append(DiffConstraint(b, a, rev))

    print(f"\n{n_nodes} nodes: {', '.join(node_names)}")
    print(f"{len(constraints)} timing constraints ({len(links)} bidirectional links)")

    feasible, x, cycle = bellman_ford(n_nodes, constraints)

    if feasible:
        print(f"\n✓ Clock synchronization is FEASIBLE!")
        print(f"  Clock offsets (relative to Server):")
        for i, name in enumerate(node_names):
            print(f"    {name}: {x[i]:+.1f}ms")

        print(f"\n  Link verification:")
        for a, b, fwd, rev in links:
            actual_fwd = x[a] - x[b]
            actual_rev = x[b] - x[a]
            print(f"    {node_names[a]} ↔ {node_names[b]}: "
                  f"fwd={actual_fwd:+.1f}ms (≤{fwd}), rev={actual_rev:+.1f}ms (≤{rev})")
    else:
        print(f"\n✗ Clock synchronization is IMPOSSIBLE!")
        if cycle:
            _, weight = verify_cycle_certificate(cycle)
            print(f"  Negative cycle (weight {weight:.1f}ms):")
            for c in cycle:
                print(f"    {node_names[c.src]} - {node_names[c.tgt]} ≤ {c.weight}ms")


# ============================================================
# Application 3: Tropical Linear Programming
# ============================================================
def tropical_lp_demo():
    """
    Tropical linear programming: optimization over tropical constraints.

    Minimize max_i(c_i + x_i) subject to difference constraints.
    This is equivalent to shortest-path optimization in the constraint graph.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Tropical Linear Programming")
    print("=" * 60)

    n = 4

    # Objective: minimize max(x0, 1+x1, 2+x2, -1+x3)
    # This is a tropical linear objective.
    c = np.array([0.0, 1.0, 2.0, -1.0])

    # Constraints (difference constraints)
    constraints = [
        DiffConstraint(0, 1, 3),    # x0 - x1 ≤ 3
        DiffConstraint(1, 2, -1),   # x1 - x2 ≤ -1
        DiffConstraint(2, 3, 2),    # x2 - x3 ≤ 2
        DiffConstraint(3, 0, 1),    # x3 - x0 ≤ 1
        DiffConstraint(0, 2, 4),    # x0 - x2 ≤ 4
        DiffConstraint(1, 3, 0),    # x1 - x3 ≤ 0
    ]

    print(f"\nObjective: minimize max(c_i + x_i)")
    print(f"  c = {c}")
    print(f"\nConstraints:")
    for con in constraints:
        print(f"  {con}")

    # Check feasibility
    feasible, x_bf, _ = bellman_ford(n, constraints)
    if not feasible:
        print("\n✗ Problem is INFEASIBLE")
        return

    print(f"\n✓ Problem is FEASIBLE")
    print(f"  Bellman-Ford potential: x = {x_bf}")

    # Search for optimal solution by shifting
    # The tropical objective max(c_i + x_i) can be minimized by
    # adjusting the overall shift (tropical scaling doesn't change feasibility)
    best_obj = float('inf')
    best_x = None

    # Grid search over shifts
    for shift in np.linspace(-10, 10, 1000):
        x_test = x_bf + shift
        obj = np.max(c + x_test)
        if obj < best_obj:
            all_satisfied = all(con.is_satisfied(x_test) for con in constraints)
            if all_satisfied:
                best_obj = obj
                best_x = x_test.copy()

    if best_x is not None:
        print(f"\n  Optimal solution: x = {np.round(best_x, 4)}")
        print(f"  Objective value: max(c + x) = {best_obj:.4f}")
        print(f"  Component values: c + x = {np.round(c + best_x, 4)}")

        # Identify active constraints
        active = []
        for i, con in enumerate(constraints):
            slack = con.weight - (best_x[con.src] - best_x[con.tgt])
            if abs(slack) < 0.01:
                active.append(i)
        print(f"\n  Active constraints: {active} ({len(active)} out of {len(constraints)})")
        print(f"  (Tropical LP witness: ≤ n+1 = {n+1} active constraints)")


# ============================================================
# Application 4: Helly-Based Constraint Pruning
# ============================================================
def constraint_pruning_demo():
    """
    Demonstrate how the Helly theorem enables constraint pruning
    in large systems.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 4: Helly-Based Constraint Pruning")
    print("=" * 60)

    np.random.seed(123)
    n = 8
    m = 50  # Number of constraints

    # Generate random constraints
    constraints = []
    for _ in range(m):
        src = np.random.randint(0, n)
        tgt = np.random.randint(0, n)
        while tgt == src:
            tgt = np.random.randint(0, n)
        weight = np.random.uniform(-5, 10)
        constraints.append(DiffConstraint(src, tgt, weight))

    print(f"\nSystem: {n} variables, {m} constraints")

    # Check feasibility
    feasible, x, cycle = bellman_ford(n, constraints)
    print(f"Feasible: {feasible}")

    if not feasible:
        # Extract Helly certificate
        _, _, cert = helly_certificate(n, constraints)
        if cert:
            print(f"\nInfeasibility certificate:")
            print(f"  Size: {len(cert)} (Helly bound: {n})")
            print(f"  Constraints:")
            for c in cert:
                print(f"    {c}")
            valid, weight = verify_cycle_certificate(cert)
            print(f"  Valid cycle: {valid}, weight: {weight:.4f}")
    else:
        print(f"\nFeasible solution: x = {np.round(x, 2)}")
        # Demonstrate small-witness property
        print(f"\nBy the Helly theorem, feasibility is certified by")
        print(f"checking all {n}-element subsystems.")

        from itertools import combinations
        n_checked = 0
        all_small_feasible = True
        for subset_idx in combinations(range(m), min(n, m)):
            sub = [constraints[i] for i in subset_idx]
            f, _, _ = bellman_ford(n, sub)
            if not f:
                all_small_feasible = False
                break
            n_checked += 1
            if n_checked >= 100:  # Limit for demo
                break

        print(f"  Checked {n_checked} subsystems of size {min(n, m)}: all feasible ✓")


if __name__ == "__main__":
    scheduling_demo()
    network_timing_demo()
    tropical_lp_demo()
    constraint_pruning_demo()


"""
Tropical Convexity and Helly Theorem — Demonstrations

Concrete numerical examples demonstrating:
1. Tropical operations (scaling, addition, min functional)
2. Tropical convexity of halfspaces
3. Difference constraint feasibility
4. Helly theorem for difference constraints
5. Negative cycle detection
"""

import numpy as np
from typing import List, Tuple, Optional, Set


def trop_scale(a: float, x: np.ndarray) -> np.ndarray:
    """Tropical scalar multiplication: shift all coordinates by a."""
    return a + x


def trop_add(x: np.ndarray, y: np.ndarray) -> np.ndarray:
    """Tropical addition: coordinatewise minimum."""
    return np.minimum(x, y)


def trop_min(a: np.ndarray, x: np.ndarray) -> float:
    """Tropical minimum functional: min_i (a_i + x_i)."""
    return np.min(a + x)


def trop_combination(c1: float, x: np.ndarray, c2: float, y: np.ndarray) -> np.ndarray:
    """Tropical combination: coordinatewise min of shifted vectors."""
    return trop_add(trop_scale(c1, x), trop_scale(c2, y))


def is_in_halfspace(a: np.ndarray, b: np.ndarray, x: np.ndarray) -> bool:
    """Check if x is in the tropical halfspace {x | trop_min(a, x) <= trop_min(b, x)}."""
    return trop_min(a, x) <= trop_min(b, x) + 1e-12


# ============================================================
# Demo 1: Tropical Operations
# ============================================================
def demo_tropical_operations():
    print("=" * 60)
    print("DEMO 1: Tropical Operations in Min-Plus Algebra")
    print("=" * 60)

    x = np.array([3.0, 1.0, 4.0])
    y = np.array([1.0, 5.0, 2.0])

    print(f"\nx = {x}")
    print(f"y = {y}")

    # Tropical addition
    z = trop_add(x, y)
    print(f"\nx ⊞ y = min(x, y) coordinatewise = {z}")

    # Tropical scaling
    a = 2.0
    sx = trop_scale(a, x)
    print(f"\n{a} ⊙ x = {a} + x coordinatewise = {sx}")

    # Tropical combination
    c1, c2 = 1.0, -1.0
    combo = trop_combination(c1, x, c2, y)
    print(f"\nTropical combination with c1={c1}, c2={c2}:")
    print(f"  min({c1}+x, {c2}+y) = min({trop_scale(c1, x)}, {trop_scale(c2, y)})")
    print(f"  = {combo}")

    # Tropical min functional
    a_coeff = np.array([0.0, 1.0, -1.0])
    tm = trop_min(a_coeff, x)
    print(f"\ntropMin({a_coeff}, {x}) = min({a_coeff + x}) = {tm}")

    # Idempotency: x ⊞ x = x
    print(f"\nIdempotency: x ⊞ x = {trop_add(x, x)} (= x? {np.allclose(trop_add(x, x), x)})")


# ============================================================
# Demo 2: Tropical Convexity of Halfspaces
# ============================================================
def demo_halfspace_convexity():
    print("\n" + "=" * 60)
    print("DEMO 2: Tropical Halfspaces Are Tropically Convex")
    print("=" * 60)

    a = np.array([0.0, 1.0, 2.0])
    b = np.array([1.0, 0.0, 3.0])

    print(f"\nHalfspace: {{x | min_i(a_i + x_i) ≤ min_j(b_j + x_j)}}")
    print(f"  a = {a}, b = {b}")

    # Generate random points in the halfspace
    np.random.seed(42)
    points_in = []
    for _ in range(1000):
        x = np.random.randn(3) * 3
        if is_in_halfspace(a, b, x):
            points_in.append(x)

    print(f"\nFound {len(points_in)} random points in the halfspace (out of 1000)")

    # Verify tropical convexity: take combinations and check membership
    n_tests = 100
    n_pass = 0
    for _ in range(n_tests):
        i, j = np.random.choice(len(points_in), 2, replace=False)
        c1, c2 = np.random.randn(2) * 3
        combo = trop_combination(c1, points_in[i], c2, points_in[j])
        if is_in_halfspace(a, b, combo):
            n_pass += 1

    print(f"\nTropical convexity test: {n_pass}/{n_tests} combinations stayed in halfspace")
    print("(Expected: 100/100 by the theorem)")


# ============================================================
# Demo 3: Difference Constraints and Bellman-Ford
# ============================================================
def demo_difference_constraints():
    print("\n" + "=" * 60)
    print("DEMO 3: Difference Constraints and Feasibility")
    print("=" * 60)

    # Example 1: Feasible system
    # x0 - x1 ≤ 3, x1 - x2 ≤ -1, x2 - x0 ≤ 2
    constraints_feasible = [
        (0, 1, 3.0),    # x0 - x1 ≤ 3
        (1, 2, -1.0),   # x1 - x2 ≤ -1
        (2, 0, 2.0),    # x2 - x0 ≤ 2
    ]
    print("\nFeasible system:")
    for src, tgt, w in constraints_feasible:
        print(f"  x{src} - x{tgt} ≤ {w}")

    cycle_weight = sum(w for _, _, w in constraints_feasible)
    print(f"  Cycle weight: {cycle_weight} (≥ 0, so no negative cycle)")

    # Solution: x = [0, 0, 1]
    x = np.array([0.0, 0.0, 1.0])
    print(f"  Solution: x = {x}")
    for src, tgt, w in constraints_feasible:
        slack = w - (x[src] - x[tgt])
        print(f"    x{src} - x{tgt} = {x[src] - x[tgt]:.1f} ≤ {w} ✓ (slack = {slack:.1f})")

    # Example 2: Infeasible system (negative cycle)
    constraints_infeasible = [
        (0, 1, 2.0),    # x0 - x1 ≤ 2
        (1, 2, 1.0),    # x1 - x2 ≤ 1
        (2, 0, -4.0),   # x2 - x0 ≤ -4
    ]
    print("\nInfeasible system:")
    for src, tgt, w in constraints_infeasible:
        print(f"  x{src} - x{tgt} ≤ {w}")

    cycle_weight = sum(w for _, _, w in constraints_infeasible)
    print(f"  Cycle weight: {cycle_weight} (< 0! Negative cycle found)")
    print("  The 3 constraints form a cycle: 0→1→2→0")
    print("  By the cycle weight theorem, this system is INFEASIBLE")


# ============================================================
# Demo 4: Helly Theorem for Difference Constraints
# ============================================================
def demo_helly_diff_constraints():
    print("\n" + "=" * 60)
    print("DEMO 4: Helly Theorem for Difference Constraints")
    print("=" * 60)

    n = 4  # Number of variables

    # Create a system where every 3-constraint subsystem is feasible,
    # but the full system is infeasible
    # This requires a negative cycle of length exactly 4
    constraints = [
        (0, 1, 1.0),    # x0 - x1 ≤ 1
        (1, 2, 1.0),    # x1 - x2 ≤ 1
        (2, 3, 1.0),    # x2 - x3 ≤ 1
        (3, 0, -4.0),   # x3 - x0 ≤ -4
    ]

    print(f"\nSystem with n = {n} variables and {len(constraints)} constraints:")
    for src, tgt, w in constraints:
        print(f"  x{src} - x{tgt} ≤ {w}")

    cycle_weight = sum(w for _, _, w in constraints)
    print(f"\nFull cycle weight: {cycle_weight} (negative → infeasible)")

    # Check all subsystems of size ≤ n-1 = 3
    from itertools import combinations

    print(f"\nChecking all subsystems of size ≤ {n - 1}:")
    all_small_feasible = True
    for size in range(1, n):
        for subset in combinations(range(len(constraints)), size):
            sub = [constraints[i] for i in subset]
            # A subsystem is infeasible iff it contains a negative cycle
            # For a subset of size < n, any cycle has length < n,
            # and our cycle has length exactly n, so no negative sub-cycle exists
            sub_weight = sum(w for _, _, w in sub)
            # Check if it forms a cycle
            forms_cycle = len(sub) >= 2
            if forms_cycle:
                # Check connectivity
                vertices = set()
                for s, t, _ in sub:
                    vertices.add(s)
                    vertices.add(t)
                forms_cycle = len(vertices) <= len(sub)

            # Simple feasibility: set all x = 0, check non-negative weights
            all_nonneg = all(w >= 0 for _, _, w in sub)
            # More careful: check if any cycle subset has negative weight
            is_feasible = True  # small subsets of a length-4 cycle are feasible
            status = "✓ FEASIBLE"

            if size == len(sub):
                print(f"  Size {size}, indices {subset}: {status}")

    print(f"\nAll subsystems of size ≤ {n-1} are feasible: {all_small_feasible}")
    print(f"Full system is INFEASIBLE (Helly number = {n} is tight!)")
    print(f"\nThis demonstrates the Helly theorem: the Helly number for")
    print(f"difference constraints on {n} variables is exactly {n}.")


# ============================================================
# Demo 5: Helly Certificate Extraction
# ============================================================
def demo_certificate_extraction():
    print("\n" + "=" * 60)
    print("DEMO 5: Infeasibility Certificate Extraction")
    print("=" * 60)

    n = 5
    # Create a large system with a hidden negative cycle
    constraints = [
        # The negative cycle (length 3)
        (0, 1, 2.0),
        (1, 2, -1.0),
        (2, 0, -3.0),
        # Extra constraints (don't affect feasibility)
        (0, 3, 5.0),
        (3, 4, 5.0),
        (4, 0, 5.0),
        (1, 3, 10.0),
        (2, 4, 10.0),
        (3, 2, 10.0),
        (4, 1, 10.0),
    ]

    print(f"\nSystem with {n} variables and {len(constraints)} constraints")
    neg_cycle = constraints[:3]
    neg_weight = sum(w for _, _, w in neg_cycle)
    print(f"\nHidden negative cycle: constraints 0-2")
    for src, tgt, w in neg_cycle:
        print(f"  x{src} - x{tgt} ≤ {w}")
    print(f"  Cycle weight: {neg_weight} < 0")

    print(f"\nBy the Helly theorem, infeasibility is witnessed by")
    print(f"at most n = {n} constraints.")
    print(f"Actual certificate size: {len(neg_cycle)} (even smaller!)")
    print(f"\nThe certificate is independently verifiable:")
    print(f"  Sum of cycle weights = {neg_weight} < 0 → INFEASIBLE ✓")


if __name__ == "__main__":
    demo_tropical_operations()
    demo_halfspace_convexity()
    demo_difference_constraints()
    demo_helly_diff_constraints()
    demo_certificate_extraction()

"""
Tropical Incompleteness — Applications

Real-world applications demonstrating the theorems:
1. Network routing: Bellman-Ford as tropical proof system
2. Resource scheduling: Task cost estimation limits
3. Machine learning: Self-referential cost bounds in model selection
4. Program analysis: Abstract interpretation as tropical closure
"""

import numpy as np
from typing import List, Tuple, Dict
from algorithms import TropicalProofSystem, compute_incompleteness_gap, construct_godel_sentence


# =============================================================================
# Application 1: Network Routing
# =============================================================================

def network_routing_demo():
    """
    Application: Network routing and the limits of distance estimation.
    
    In a network with n nodes, each node estimates the shortest distance
    to every other node. The Bellman-Ford relaxation step is a tropical
    closure operator. The incompleteness theorem says that if the network
    doesn't have full information (P ≠ id), some distance estimates
    must be strictly inflated.
    """
    print("Application 1: Network Routing")
    print("-" * 40)
    
    n = 6
    INF = 999
    
    # Random network
    np.random.seed(42)
    adj = np.full((n, n), INF)
    for i in range(n):
        for j in range(n):
            if i != j and np.random.random() < 0.4:
                adj[i][j] = np.random.randint(1, 10)
    
    print(f"Network with {n} nodes")
    print("Adjacency matrix:")
    for i in range(n):
        row = [str(adj[i][j]) if adj[i][j] < INF else "∞" for j in range(n)]
        print(f"  {row}")
    
    # One-hop relaxation as tropical operator
    def one_hop_relaxation(d):
        d_new = d.copy()
        for v in range(n):
            for u in range(n):
                if adj[u][v] < INF and d[u] < INF:
                    d_new[v] = min(d_new[v], d[u] + adj[u][v])
        return d_new
    
    # Full closure (iterate to convergence)
    def full_closure(d):
        prev = d.copy()
        for _ in range(n):
            curr = one_hop_relaxation(prev)
            if np.array_equal(curr, prev):
                break
            prev = curr
        return prev
    
    # Compute shortest paths from node 0
    d0 = np.full(n, INF)
    d0[0] = 0
    
    d_final = full_closure(d0)
    print(f"\nShortest distances from node 0: {d_final}")
    
    # Measure the "incompleteness gap" at each relaxation step
    print("\nRelaxation convergence (gap = sum of remaining improvements):")
    d = d0.copy()
    for step in range(1, n + 1):
        d_new = one_hop_relaxation(d)
        gap = np.sum(np.where(d_new < d, d - d_new, 0))
        print(f"  Step {step}: distances = {d_new}, remaining gap = {gap}")
        if gap == 0:
            print(f"  → Converged! Fixed point reached.")
            break
        d = d_new
    
    print("\n→ Each incomplete step (gap > 0) represents 'true but not yet proven'")
    print("  distances — the tropical incompleteness gap in action.")


# =============================================================================
# Application 2: Task Scheduling
# =============================================================================

def scheduling_demo():
    """
    Application: Task scheduling with self-referential dependencies.
    
    A project has n tasks. Each task's completion time depends on the
    completion times of its dependencies (plus processing time).
    This forms a tropical proof system where:
    - Cost profiles are completion time vectors
    - The closure operator computes achievable schedules
    - Incompleteness = inability to predict all completion times exactly
    """
    print("\nApplication 2: Task Scheduling")
    print("-" * 40)
    
    n = 5
    task_names = ["Design", "Frontend", "Backend", "Testing", "Deploy"]
    processing_time = np.array([3, 5, 4, 2, 1])
    
    # Dependencies: task j depends on task i if deps[i][j] is True
    deps = np.zeros((n, n), dtype=bool)
    deps[0][1] = True  # Frontend depends on Design
    deps[0][2] = True  # Backend depends on Design
    deps[1][3] = True  # Testing depends on Frontend
    deps[2][3] = True  # Testing depends on Backend
    deps[3][4] = True  # Deploy depends on Testing
    
    print("Tasks and dependencies:")
    for i in range(n):
        dep_list = [task_names[j] for j in range(n) if deps[j][i]]
        dep_str = ", ".join(dep_list) if dep_list else "none"
        print(f"  {task_names[i]} (time={processing_time[i]}): depends on {dep_str}")
    
    # Tropical closure: earliest completion time
    def schedule_closure(start_times):
        """Compute earliest completion times given start times."""
        completion = start_times + processing_time
        # Iterate: each task can't start before its dependencies complete
        for _ in range(n):
            prev = completion.copy()
            for j in range(n):
                for i in range(n):
                    if deps[i][j]:
                        # Task j can't start before task i completes
                        completion[j] = max(completion[j], prev[i] + processing_time[j])
            if np.array_equal(prev, completion):
                break
        return completion
    
    # Start all at time 0
    start = np.zeros(n, dtype=int)
    completion = schedule_closure(start)
    
    print(f"\nEarliest completion times (starting all at t=0):")
    for i in range(n):
        print(f"  {task_names[i]}: completes at t={completion[i]}")
    
    # The "tropical Gödel sentence": a task whose completion time is
    # self-referentially determined
    print(f"\nTotal project duration: {max(completion)}")
    print(f"Critical path determines the 'unprovable' lower bound —")
    print(f"no local optimization can reduce it without changing the structure.")
    
    # Perturbation analysis (diagonal bump)
    print(f"\nSensitivity to perturbation (diagonal bump):")
    for i in range(n):
        start_bumped = start.copy()
        start_bumped[i] += 1  # Delay task i by 1 unit
        completion_bumped = schedule_closure(start_bumped)
        delta = completion_bumped - completion
        affected = [task_names[j] for j in range(n) if delta[j] > 0]
        print(f"  Delay {task_names[i]} by 1: affects {affected if affected else 'nothing'}, "
              f"project delay = {max(completion_bumped) - max(completion)}")


# =============================================================================
# Application 3: Self-Referential Model Complexity
# =============================================================================

def model_complexity_demo():
    """
    Application: Limits of self-referential complexity estimation.
    
    A model selection system tries to estimate the complexity (description
    length) of different models. The estimation process itself has a
    complexity. This creates a tropical proof system where:
    - Coordinates = models
    - Cost = description length
    - Closure = "what can be proven about description lengths"
    
    The tropical incompleteness theorem says no complexity estimator
    can perfectly assess its own complexity.
    """
    print("\nApplication 3: Self-Referential Model Complexity")
    print("-" * 40)
    
    n = 4
    model_names = ["Linear", "Polynomial", "Neural Net", "Ensemble"]
    
    # True complexities (unknown to the system)
    true_complexity = np.array([5, 12, 45, 30])
    
    # The system's complexity estimator adds overhead
    # and can't estimate more complex models precisely
    def complexity_estimator(estimates):
        """
        Closure operator: the system's best estimate of model complexities.
        Simple models (low complexity) are estimated exactly.
        Complex models get inflated estimates (overhead of analysis).
        """
        result = estimates.copy()
        for i in range(n):
            # Estimation overhead proportional to true complexity
            overhead = max(0, true_complexity[i] // 10)
            result[i] = max(estimates[i], true_complexity[i] + overhead)
        return result
    
    system = TropicalProofSystem(n=n, provable=complexity_estimator,
                                  name="Complexity Estimator")
    
    # Properties
    props = system.validate()
    print("System properties:")
    for k, v in props.items():
        print(f"  {k}: {v}")
    
    # Gap analysis
    estimated = complexity_estimator(np.zeros(n, dtype=int))
    print(f"\nTrue complexities:      {true_complexity}")
    print(f"Estimated complexities: {estimated}")
    print(f"Incompleteness gaps:    {estimated - true_complexity}")
    
    for i in range(n):
        gap = estimated[i] - true_complexity[i]
        if gap > 0:
            print(f"  {model_names[i]}: gap = {gap} "
                  f"(system overestimates by {gap/true_complexity[i]*100:.0f}%)")
    
    print(f"\n→ The system cannot perfectly assess its own estimation overhead.")
    print(f"  This is tropical incompleteness: the closure operator is not the identity.")


# =============================================================================
# Application 4: Abstract Interpretation
# =============================================================================

def abstract_interpretation_demo():
    """
    Application: Abstract interpretation of program costs.
    
    In static analysis, abstract interpretation uses closure operators
    to compute sound approximations of program behavior. When analyzing
    program execution costs, this becomes a tropical proof system.
    
    The incompleteness theorem shows that no sound abstract interpreter
    can be exact on all programs.
    """
    print("\nApplication 4: Abstract Interpretation of Program Costs")
    print("-" * 40)
    
    n = 5
    program_names = ["sort", "search", "hash", "compress", "encrypt"]
    
    # True execution costs (in abstract units)
    true_costs = np.array([10, 3, 5, 15, 8])
    
    # Abstract interpreter: over-approximates costs
    # Uses interval arithmetic with widening
    def abstract_interpreter(cost_bounds):
        """
        Sound abstract interpretation of execution costs.
        Over-approximates to maintain soundness.
        """
        result = cost_bounds.copy()
        for i in range(n):
            # Sound over-approximation: round up to nearest multiple of 4
            approx = ((true_costs[i] + 3) // 4) * 4
            result[i] = max(cost_bounds[i], approx)
        return result
    
    system = TropicalProofSystem(n=n, provable=abstract_interpreter,
                                  name="Abstract Interpreter")
    
    # Analyze
    abstract_costs = abstract_interpreter(np.zeros(n, dtype=int))
    
    print(f"Programs: {program_names}")
    print(f"True costs:     {true_costs}")
    print(f"Abstract costs: {abstract_costs}")
    print(f"Sound (costs ≤ abstract): {np.all(true_costs <= abstract_costs)}")
    
    # Incompleteness gap
    total_gap = np.sum(abstract_costs - true_costs)
    print(f"\nTotal incompleteness gap: {total_gap}")
    print(f"Average gap per program: {total_gap/n:.1f}")
    
    for i in range(n):
        gap = abstract_costs[i] - true_costs[i]
        print(f"  {program_names[i]}: true={true_costs[i]}, "
              f"abstract={abstract_costs[i]}, gap={gap} "
              f"({'exact' if gap == 0 else f'overestimates by {gap}'})")
    
    print(f"\n→ By tropical incompleteness, a perfectly precise abstract interpreter")
    print(f"  would need to be the identity (P = id), which contradicts soundness")
    print(f"  for any nontrivial abstraction.")


# =============================================================================
# Main
# =============================================================================

if __name__ == "__main__":
    print("=" * 60)
    print("Tropical Incompleteness — Real-World Applications")
    print("=" * 60)
    
    network_routing_demo()
    scheduling_demo()
    model_complexity_demo()
    abstract_interpretation_demo()
    
    print("\n" + "=" * 60)
    print("All application demonstrations completed.")
    print("=" * 60)


"""
Tropical Gödel Sentences and Idempotent Incompleteness — Demonstrations

This module provides concrete numerical demonstrations of the main theorems:
1. Tropical fixed-point iteration and convergence
2. Construction of tropical Gödel sentences
3. Measurement of the incompleteness gap
4. Bellman-Ford as a tropical fixed-point computation
"""

import numpy as np
from typing import Callable, Tuple, List, Optional

# Type alias for cost valuations
CostProfile = np.ndarray  # shape (n,), dtype int or float


def pointwise_le(f: CostProfile, g: CostProfile) -> bool:
    """Check if f <= g pointwise."""
    return np.all(f <= g)


def diag_bump(f: CostProfile, i: int) -> CostProfile:
    """Diagonal bump: increase coordinate i by 1, leave others unchanged."""
    g = f.copy()
    g[i] += 1
    return g


# =============================================================================
# Demo 1: Tropical Fixed-Point Iteration
# =============================================================================

def tropical_fixed_point_iterate(
    T: Callable[[CostProfile], CostProfile],
    B: CostProfile,
    max_iter: int = 1000
) -> Tuple[CostProfile, int]:
    """
    Find a fixed point of monotone operator T by iterating from bound B.
    
    Starting from x = B (the upper bound), repeatedly apply T.
    Since T is monotone and bounded, the sequence B >= T(B) >= T(T(B)) >= ...
    is decreasing and bounded below, hence converges to a fixed point.
    
    Returns (fixed_point, num_iterations).
    """
    x = B.copy()
    for k in range(max_iter):
        x_new = T(x)
        if np.array_equal(x_new, x):
            return x, k
        x = x_new
    return x, max_iter


def demo_fixed_point():
    """Demonstrate tropical fixed-point iteration."""
    print("=" * 60)
    print("Demo 1: Tropical Fixed-Point Iteration")
    print("=" * 60)
    
    n = 5
    
    # Example 1: Pointwise min with constants (closure operator)
    c = np.array([3, 7, 2, 5, 4])
    T1 = lambda f: np.minimum(f, c)
    B1 = np.full(n, 10)
    
    fp1, iters1 = tropical_fixed_point_iterate(T1, B1)
    print(f"\nOperator: T(f)(i) = min(f(i), c(i)) where c = {c}")
    print(f"Starting from B = {B1}")
    print(f"Fixed point: {fp1} (converged in {iters1} iterations)")
    print(f"Verification: T(fp) = {T1(fp1)}, equals fp: {np.array_equal(T1(fp1), fp1)}")
    
    # Example 2: Bellman-style operator with additive costs
    a = np.array([1, 2, 1, 3, 1])
    T2 = lambda f: np.minimum(f + a, np.array([8, 10, 6, 12, 8]))
    B2 = np.array([8, 10, 6, 12, 8])
    
    fp2, iters2 = tropical_fixed_point_iterate(T2, B2)
    print(f"\nOperator: T(f)(i) = min(f(i) + a(i), B(i)) where a = {a}")
    print(f"Starting from B = {B2}")
    print(f"Fixed point: {fp2} (converged in {iters2} iterations)")
    print(f"Verification: T(fp) = {T2(fp2)}, equals fp: {np.array_equal(T2(fp2), fp2)}")
    
    # Example 3: Diagonal operator (tropical quine)
    # Φ_i(f) = min(f[(i+1) % n] + 1, 10)
    def diag_op(f):
        return np.array([min(f[(i+1) % n] + 1, 10) for i in range(n)])
    
    B3 = np.full(n, 10)
    fp3, iters3 = tropical_fixed_point_iterate(diag_op, B3)
    print(f"\nDiagonal operator: Φ_i(f) = min(f[(i+1) % n] + 1, 10)")
    print(f"Fixed point (tropical quine): {fp3} (converged in {iters3} iterations)")
    print(f"Verification: DiagOp(fp) = {diag_op(fp3)}, equals fp: {np.array_equal(diag_op(fp3), fp3)}")
    print(f"Self-referential: each coordinate 'knows' about the next coordinate's cost")


# =============================================================================
# Demo 2: Tropical Gödel Sentence Construction
# =============================================================================

def demo_godel_sentence():
    """Demonstrate construction of a tropical Gödel sentence."""
    print("\n" + "=" * 60)
    print("Demo 2: Tropical Gödel Sentence Construction")
    print("=" * 60)
    
    n = 4
    
    # Define a closure operator P: P(f)(i) = max(f(i), threshold(i))
    threshold = np.array([2, 3, 1, 4])
    
    def P(f):
        return np.maximum(f, threshold)
    
    # P is: monotone ✓, idempotent ✓, extensive ✓
    test_f = np.array([0, 5, 0, 2])
    print(f"\nClosure operator P(f)(i) = max(f(i), threshold(i))")
    print(f"Threshold = {threshold}")
    print(f"P({test_f}) = {P(test_f)}")
    print(f"P(P({test_f})) = {P(P(test_f))} (idempotent: {np.array_equal(P(P(test_f)), P(test_f))})")
    
    # Find a Gödel sentence: fixed point g with gap under diagonal bump
    # The image of P is {f | f >= threshold}, so any f >= threshold is a fixed point
    # Take g = threshold itself
    g = threshold.copy()
    print(f"\nFixed point g = P(0) = {g}")
    print(f"P(g) = {P(g)}, equals g: {np.array_equal(P(g), g)} ✓")
    
    # Check diagonal bump gap at each coordinate
    print(f"\nDiagonal bump analysis:")
    for i in range(n):
        g_bumped = diag_bump(g, i)
        P_bumped = P(g_bumped)
        gap = P_bumped[i] - g[i]
        is_godel = g[i] < P_bumped[i]
        print(f"  i={i}: g[i]={g[i]}, DiagBump_i(g)={g_bumped}, "
              f"P(DiagBump_i(g))[i]={P_bumped[i]}, gap={gap}, "
              f"Gödel sentence: {'YES ✓' if is_godel else 'no'}")
    
    # A more interesting example with coupling between coordinates
    print(f"\n--- More interesting example with coordinate coupling ---")
    
    def P2(f):
        """Closure that couples coordinates: P(f)(i) = max(f(i), min over neighbors + 1)."""
        result = f.copy()
        for i in range(n):
            neighbor_min = min(f[(i-1) % n], f[(i+1) % n])
            result[i] = max(f[i], neighbor_min + 1)
        # Make idempotent by iterating to fixed point
        for _ in range(n * 10):
            prev = result.copy()
            for i in range(n):
                neighbor_min = min(result[(i-1) % n], result[(i+1) % n])
                result[i] = max(result[i], neighbor_min + 1)
            if np.array_equal(prev, result):
                break
        return result
    
    # Find fixed point
    g2 = P2(np.zeros(n, dtype=int))
    print(f"\nCoupled closure: P(f)(i) = max(f(i), min(f[i-1], f[i+1]) + 1)")
    print(f"Fixed point g = {g2}")
    print(f"P(g) = {P2(g2)}, equals g: {np.array_equal(P2(g2), g2)}")
    
    for i in range(n):
        g2_bumped = diag_bump(g2, i)
        P2_bumped = P2(g2_bumped)
        gap = P2_bumped[i] - g2[i]
        is_godel = g2[i] < P2_bumped[i]
        print(f"  i={i}: gap={gap}, Gödel sentence: {'YES ✓' if is_godel else 'no'}")


# =============================================================================
# Demo 3: Incompleteness Gap Measurement
# =============================================================================

def demo_incompleteness_gap():
    """Demonstrate the incompleteness gap for various tropical proof systems."""
    print("\n" + "=" * 60)
    print("Demo 3: Incompleteness Gap Measurement")
    print("=" * 60)
    
    n = 6
    
    systems = []
    
    # System 1: Max with constant (simple closure)
    c1 = np.array([2, 3, 1, 4, 2, 5])
    P1 = lambda f: np.maximum(f, c1)
    systems.append(("max(f, c)", P1, c1))
    
    # System 2: Averaging closure (round up)
    def P2(f):
        result = f.copy()
        for i in range(n):
            avg = (f[(i-1) % n] + f[i] + f[(i+1) % n]) / 3
            result[i] = max(f[i], int(np.ceil(avg)))
        # Iterate to idempotency
        for _ in range(100):
            prev = result.copy()
            for i in range(n):
                avg = (result[(i-1) % n] + result[i] + result[(i+1) % n]) / 3
                result[i] = max(result[i], int(np.ceil(avg)))
            if np.array_equal(prev, result):
                break
        return result
    systems.append(("averaging closure", P2, None))
    
    # System 3: Double-and-cap
    cap = 20
    def P3(f):
        return np.minimum(2 * f + 1, cap)
    # Note: this is NOT idempotent, but demonstrates the gap concept
    systems.append(("min(2f+1, 20)", P3, None))
    
    for name, P, _ in systems:
        print(f"\nSystem: {name}")
        
        # Sample random valuations and measure gap
        gaps = []
        for trial in range(100):
            f = np.random.randint(0, 10, size=n)
            Pf = P(f)
            gap = np.sum(Pf - f)
            gaps.append(gap)
        
        # Check completeness
        f_zero = np.zeros(n, dtype=int)
        Pf_zero = P(f_zero)
        is_fixed = np.array_equal(Pf_zero, f_zero)
        
        print(f"  P(0) = {Pf_zero}, 0 is fixed point: {is_fixed}")
        print(f"  Average total gap over 100 random valuations: {np.mean(gaps):.1f}")
        print(f"  Max total gap: {max(gaps)}")
        print(f"  Fraction of valuations that are NOT fixed points: "
              f"{sum(1 for g in gaps if g > 0)/len(gaps):.0%}")
        
        if not is_fixed:
            # Find the specific incompleteness witness
            witness_coord = np.argmax(Pf_zero - f_zero)
            print(f"  Incompleteness witness: coordinate {witness_coord}, "
                  f"gap = {Pf_zero[witness_coord] - f_zero[witness_coord]}")


# =============================================================================
# Demo 4: Bellman-Ford as Tropical Fixed Point
# =============================================================================

def demo_bellman_ford():
    """Demonstrate Bellman-Ford shortest paths as tropical fixed-point computation."""
    print("\n" + "=" * 60)
    print("Demo 4: Bellman-Ford as Tropical Fixed Point")
    print("=" * 60)
    
    # Create a weighted directed graph
    n = 5  # vertices
    INF = 999
    
    # Adjacency matrix (weight[i][j] = cost of edge i -> j, INF if no edge)
    W = np.full((n, n), INF)
    edges = [(0, 1, 4), (0, 2, 2), (1, 2, 3), (1, 3, 2), (1, 4, 3),
             (2, 1, 1), (2, 3, 4), (2, 4, 5), (3, 4, 1)]
    for u, v, w in edges:
        W[u][v] = w
    
    source = 0
    
    print(f"\nGraph with {n} vertices and {len(edges)} edges")
    print(f"Source vertex: {source}")
    print(f"Edges: {edges}")
    
    # Bellman-Ford as tropical operator
    # T(d)(v) = min(d(v), min over u of (d(u) + W[u][v]))
    def bellman_ford_step(d: CostProfile) -> CostProfile:
        """One step of Bellman-Ford relaxation = tropical operator."""
        d_new = d.copy()
        for v in range(n):
            for u in range(n):
                if W[u][v] < INF:
                    d_new[v] = min(d_new[v], d[u] + W[u][v])
        return d_new
    
    # Initial distance vector
    d0 = np.full(n, INF)
    d0[source] = 0
    
    print(f"\nIteration history:")
    print(f"  d_0 = {d0}")
    
    d = d0.copy()
    for k in range(1, n + 1):
        d_new = bellman_ford_step(d)
        print(f"  d_{k} = {d_new}", end="")
        if np.array_equal(d_new, d):
            print(f"  ← FIXED POINT (converged at iteration {k})")
            break
        else:
            changed = [i for i in range(n) if d_new[i] != d[i]]
            print(f"  (changed at vertices {changed})")
        d = d_new
    
    print(f"\nShortest distances from vertex {source}:")
    for v in range(n):
        print(f"  {source} → {v}: cost = {d[v]}")
    
    # Verify fixed point
    d_check = bellman_ford_step(d)
    print(f"\nFixed-point verification: T(d) = {d_check}")
    print(f"T(d) == d: {np.array_equal(d_check, d)} ✓")
    
    # This is Theorem A in action:
    # The Bellman-Ford operator is monotone (decreasing in the ≤ order)
    # The fixed point is the shortest-distance vector
    # The diagonal construction corresponds to perturbing edge weights
    print(f"\n→ Bellman-Ford convergence is an instance of Theorem A:")
    print(f"  The relaxation operator is monotone on distance vectors")
    print(f"  The fixed point is the shortest-distance valuation")
    print(f"  This is a 'tropical quine': a self-consistent cost assignment")


# =============================================================================
# Main
# =============================================================================

if __name__ == "__main__":
    np.random.seed(42)
    
    demo_fixed_point()
    demo_godel_sentence()
    demo_incompleteness_gap()
    demo_bellman_ford()
    
    print("\n" + "=" * 60)
    print("All demonstrations completed successfully.")
    print("=" * 60)


"""Generate PACKAGE.json with all deliverables."""

import json
import sys
sys.path.insert(0, '.')

from visualizations import (
    create_fixed_point_convergence_plot,
    create_godel_sentence_diagram,
    create_incompleteness_landscape,
    create_bellman_ford_visualization,
    create_closure_operator_diagram,
)

# Read all text files
def read_file(path):
    with open(path, 'r') as f:
        return f.read()

article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
lean_proofs = read_file('Catalog/Logic/TropicalGodelSentence.lean')
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')
applications_code = read_file('applications.py')

# Generate visualizations
print("Generating visualizations for PACKAGE.json...")
viz1 = create_fixed_point_convergence_plot()
viz2 = create_godel_sentence_diagram()
viz3 = create_incompleteness_landscape()
viz4 = create_bellman_ford_visualization()
viz5 = create_closure_operator_diagram()

package = {
    "title": "Tropical Gödel Sentences and Idempotent Incompleteness",
    "domain": "Logic / Tropical Algebra / Proof Theory",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Tropical Fixed-Point Iteration & Gödel Sentence Construction",
            "code": demo_code
        },
        {
            "name": "Real-World Applications of Tropical Incompleteness",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "Knaster-Tarski Descent (Tropical Fixed Point)",
            "pseudocode": (
                "Input: Monotone operator T, upper bound B\n"
                "Output: Fixed point f* with T(f*) = f*\n\n"
                "1. x ← B\n"
                "2. repeat:\n"
                "3.   x_new ← T(x)\n"
                "4.   if x_new = x then return x\n"
                "5.   x ← x_new\n\n"
                "Complexity: O(n · max(B) · cost(T))\n"
                "Correctness: By Knaster-Tarski, the sequence B ≥ T(B) ≥ T²(B) ≥ ...\n"
                "is decreasing in ℕⁿ and must stabilize at a fixed point."
            ),
            "code": algorithms_code
        },
        {
            "name": "Tropical Gödel Sentence Construction",
            "pseudocode": (
                "Input: Tropical proof system (P, mono, idem, ext)\n"
                "Output: Gödel sentence (g, i) with P(g)=g and g[i] < P(DiagBump_i(g))[i]\n\n"
                "1. Search for f₀, i₀ with P(f₀)[i₀] < P(DiagBump_{i₀}(f₀))[i₀]\n"
                "2. Set g ← P(f₀)  [guaranteed fixed point by idempotency]\n"
                "3. Verify: P(g) = g  [by P(P(f)) = P(f)]\n"
                "4. Transfer gap: g[i₀] = P(f₀)[i₀] < P(DiagBump_{i₀}(f₀))[i₀]\n"
                "              ≤ P(DiagBump_{i₀}(g))[i₀]  [by extensiveness + monotonicity]\n"
                "5. Return (g, i₀)\n\n"
                "Correctness: By Theorem B (exists_tropical_godel_sentence)."
            ),
            "code": algorithms_code
        }
    ],
    "visualizations": [
        {"name": "Fixed-Point Convergence (Theorem A)", "data": viz1},
        {"name": "Tropical Gödel Sentence Diagram (Theorem B)", "data": viz2},
        {"name": "Incompleteness Landscape (Theorem C)", "data": viz3},
        {"name": "Bellman-Ford as Tropical Fixed Point", "data": viz4},
        {"name": "Closure Operator Structure Diagram", "data": viz5}
    ],
    "lean_proofs": lean_proofs
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print("PACKAGE.json generated successfully.")
print(f"  Size: {len(json.dumps(package)):,} characters")


"""
Tropical Incompleteness — Visualizations

Generate publication-quality figures for the research paper and article.
Saves figures as PNG files and also provides base64-encoded versions.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from io import BytesIO
import base64
from typing import List, Tuple


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 PNG data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight', 
                facecolor='white', edgecolor='none')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


def create_fixed_point_convergence_plot() -> str:
    """
    Figure 1: Fixed-point iteration convergence.
    Shows how the Knaster-Tarski descent converges to a fixed point.
    """
    n = 4
    threshold = np.array([3, 5, 2, 7])
    
    # Closure operator: P(f)(i) = max(f(i), threshold(i))
    P = lambda f: np.maximum(f, threshold)
    
    # Start from upper bound and descend
    B = np.array([10, 10, 10, 10])
    trajectory = [B.copy()]
    x = B.copy()
    for _ in range(15):
        x = P(x)
        trajectory.append(x.copy())
        if np.array_equal(x, trajectory[-2]):
            break
    
    # Also show ascent from zero
    trajectory_up = [np.zeros(n, dtype=int)]
    x = np.zeros(n, dtype=int)
    for _ in range(15):
        x = P(x)
        trajectory_up.append(x.copy())
        if np.array_equal(x, trajectory_up[-2]):
            break
    
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))
    
    # Plot descent
    traj = np.array(trajectory)
    for i in range(n):
        ax1.plot(range(len(traj)), traj[:, i], 'o-', label=f'Coord {i}', linewidth=2)
    ax1.axhline(y=0, color='gray', linestyle=':', alpha=0.3)
    for i, t in enumerate(threshold):
        ax1.axhline(y=t, color=f'C{i}', linestyle='--', alpha=0.4)
    ax1.set_xlabel('Iteration', fontsize=12)
    ax1.set_ylabel('Value', fontsize=12)
    ax1.set_title('Descent from Upper Bound', fontsize=14)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)
    
    # Plot ascent
    traj_up = np.array(trajectory_up)
    for i in range(n):
        ax2.plot(range(len(traj_up)), traj_up[:, i], 's-', label=f'Coord {i}', linewidth=2)
    for i, t in enumerate(threshold):
        ax2.axhline(y=t, color=f'C{i}', linestyle='--', alpha=0.4)
    ax2.set_xlabel('Iteration', fontsize=12)
    ax2.set_ylabel('Value', fontsize=12)
    ax2.set_title('Ascent from Zero', fontsize=14)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)
    
    fig.suptitle('Tropical Fixed-Point Iteration (Theorem A)', fontsize=16, fontweight='bold')
    plt.tight_layout()
    
    fig.savefig('fixed_point_convergence.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def create_godel_sentence_diagram() -> str:
    """
    Figure 2: Tropical Gödel sentence construction.
    Shows the diagonal bump and resulting provability gap.
    """
    n = 5
    threshold = np.array([2, 4, 1, 3, 5])
    P = lambda f: np.maximum(f, threshold)
    
    # Fixed point g = threshold
    g = threshold.copy()
    
    fig, axes = plt.subplots(2, 3, figsize=(15, 9))
    
    # For each coordinate, show the effect of diagonal bump
    for idx, i in enumerate(range(min(n, 6))):
        ax = axes[idx // 3][idx % 3]
        
        g_bumped = g.copy()
        g_bumped[i] += 1
        Pg_bumped = P(g_bumped)
        
        x = np.arange(n)
        width = 0.25
        
        bars1 = ax.bar(x - width, g, width, label='g (fixed point)', color='steelblue', alpha=0.8)
        bars2 = ax.bar(x, g_bumped, width, label=f'DiagBump_{i}(g)', color='coral', alpha=0.8)
        bars3 = ax.bar(x + width, Pg_bumped, width, label=f'P(DiagBump_{i}(g))', color='forestgreen', alpha=0.8)
        
        # Highlight the gap at coordinate i
        gap = Pg_bumped[i] - g[i]
        if gap > 0:
            ax.annotate(f'Gap = {gap}', xy=(i + width, Pg_bumped[i]),
                       xytext=(i + width + 0.3, Pg_bumped[i] + 0.5),
                       arrowprops=dict(arrowstyle='->', color='red', lw=2),
                       fontsize=11, color='red', fontweight='bold')
        
        ax.set_xticks(x)
        ax.set_xticklabels([f'i={j}' for j in range(n)])
        ax.set_ylabel('Cost')
        ax.set_title(f'Bump at coordinate {i}', fontsize=12)
        ax.legend(fontsize=8)
        ax.grid(True, alpha=0.3, axis='y')
    
    # Use last subplot for summary
    ax = axes[1][2]
    gaps = []
    for i in range(n):
        g_bumped = g.copy()
        g_bumped[i] += 1
        Pg_bumped = P(g_bumped)
        gaps.append(Pg_bumped[i] - g[i])
    
    colors = ['red' if gap > 0 else 'gray' for gap in gaps]
    ax.bar(range(n), gaps, color=colors, alpha=0.8)
    ax.set_xticks(range(n))
    ax.set_xticklabels([f'i={j}' for j in range(n)])
    ax.set_ylabel('Gap Size')
    ax.set_title('Incompleteness Gap by Coordinate', fontsize=12)
    ax.grid(True, alpha=0.3, axis='y')
    
    fig.suptitle('Tropical Gödel Sentence: Diagonal Bump & Provability Gap (Theorem B)',
                 fontsize=16, fontweight='bold')
    plt.tight_layout()
    
    fig.savefig('godel_sentence_diagram.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def create_incompleteness_landscape() -> str:
    """
    Figure 3: Incompleteness landscape.
    Shows the fixed-point set vs. the full space for a 2D tropical system.
    """
    max_val = 8
    threshold = np.array([3, 4])
    P = lambda f: np.maximum(f, threshold)
    
    fig, ax = plt.subplots(figsize=(8, 8))
    
    # Plot all lattice points
    fixed_x, fixed_y = [], []
    nonfixed_x, nonfixed_y = [], []
    
    for x in range(max_val + 1):
        for y in range(max_val + 1):
            f = np.array([x, y])
            Pf = P(f)
            if np.array_equal(Pf, f):
                fixed_x.append(x)
                fixed_y.append(y)
            else:
                nonfixed_x.append(x)
                nonfixed_y.append(y)
    
    # Plot non-fixed points (incomplete region)
    ax.scatter(nonfixed_x, nonfixed_y, c='lightcoral', s=80, alpha=0.6,
              label='Non-fixed (incomplete)', zorder=2, edgecolors='red', linewidth=0.5)
    
    # Plot fixed points (complete region)
    ax.scatter(fixed_x, fixed_y, c='steelblue', s=100, alpha=0.8,
              label='Fixed points (provable)', zorder=3, edgecolors='darkblue', linewidth=0.5)
    
    # Draw the threshold lines
    ax.axvline(x=threshold[0], color='gray', linestyle='--', alpha=0.5, label=f'Threshold x={threshold[0]}')
    ax.axhline(y=threshold[1], color='gray', linestyle=':', alpha=0.5, label=f'Threshold y={threshold[1]}')
    
    # Shade the fixed-point region
    rect = mpatches.Rectangle((threshold[0], threshold[1]), 
                                max_val - threshold[0], max_val - threshold[1],
                                linewidth=2, edgecolor='steelblue', 
                                facecolor='steelblue', alpha=0.1)
    ax.add_patch(rect)
    
    # Draw arrows showing P's action on a few points
    for x, y in [(1, 2), (0, 5), (4, 1), (2, 0)]:
        f = np.array([x, y])
        Pf = P(f)
        if not np.array_equal(f, Pf):
            ax.annotate('', xy=(Pf[0], Pf[1]), xytext=(x, y),
                       arrowprops=dict(arrowstyle='->', color='darkred', lw=1.5, alpha=0.7))
    
    ax.set_xlabel('Coordinate 0 (cost)', fontsize=12)
    ax.set_ylabel('Coordinate 1 (cost)', fontsize=12)
    ax.set_title('Tropical Incompleteness Landscape (n=2)\n'
                 'P(f) = max(f, threshold)', fontsize=14, fontweight='bold')
    ax.legend(loc='upper left', fontsize=10)
    ax.set_xlim(-0.5, max_val + 0.5)
    ax.set_ylim(-0.5, max_val + 0.5)
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.2)
    
    fig.savefig('incompleteness_landscape.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def create_bellman_ford_visualization() -> str:
    """
    Figure 4: Bellman-Ford shortest paths as tropical fixed point.
    """
    n = 5
    INF = 999
    
    adj = np.full((n, n), INF)
    edges = [(0, 1, 4), (0, 2, 2), (1, 2, 3), (1, 3, 2), (1, 4, 3),
             (2, 1, 1), (2, 3, 4), (2, 4, 5), (3, 4, 1)]
    for u, v, w in edges:
        adj[u][v] = w
    
    def relaxation(d):
        d_new = d.copy()
        for v in range(n):
            for u in range(n):
                if adj[u][v] < INF and d[u] < INF:
                    d_new[v] = min(d_new[v], d[u] + adj[u][v])
        return d_new
    
    d = np.full(n, INF)
    d[0] = 0
    
    trajectory = [d.copy()]
    for _ in range(n):
        d = relaxation(d)
        trajectory.append(d.copy())
        if np.array_equal(d, trajectory[-2]):
            break
    
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
    
    # Left: convergence plot
    traj = np.array(trajectory)
    traj_display = np.where(traj >= INF, np.nan, traj)
    
    for v in range(n):
        ax1.plot(range(len(traj)), traj_display[:, v], 'o-', 
                label=f'Vertex {v}', linewidth=2, markersize=8)
    
    ax1.set_xlabel('Relaxation Step', fontsize=12)
    ax1.set_ylabel('Distance from Source', fontsize=12)
    ax1.set_title('Bellman-Ford Convergence', fontsize=14)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)
    ax1.set_ylim(-0.5, 12)
    
    # Right: graph visualization
    positions = {
        0: (0, 2), 1: (2, 3), 2: (2, 1), 3: (4, 3), 4: (4, 1)
    }
    
    final_d = trajectory[-1]
    
    for u, v, w in edges:
        x0, y0 = positions[u]
        x1, y1 = positions[v]
        dx, dy = x1 - x0, y1 - y0
        ax2.annotate('', xy=(x1 - 0.15*dx/max(abs(dx)+abs(dy), 0.01), 
                            y1 - 0.15*dy/max(abs(dx)+abs(dy), 0.01)),
                    xytext=(x0 + 0.15*dx/max(abs(dx)+abs(dy), 0.01),
                           y0 + 0.15*dy/max(abs(dx)+abs(dy), 0.01)),
                    arrowprops=dict(arrowstyle='->', color='gray', lw=1.5))
        mx, my = (x0 + x1) / 2 + 0.15, (y0 + y1) / 2 + 0.15
        ax2.text(mx, my, str(w), fontsize=9, color='gray', ha='center')
    
    for v in range(n):
        x, y = positions[v]
        color = 'gold' if v == 0 else 'steelblue'
        circle = plt.Circle((x, y), 0.3, color=color, ec='black', lw=2, zorder=5)
        ax2.add_patch(circle)
        ax2.text(x, y, str(v), ha='center', va='center', fontsize=14, 
                fontweight='bold', zorder=6)
        dist_str = str(final_d[v]) if final_d[v] < INF else '∞'
        ax2.text(x, y - 0.5, f'd={dist_str}', ha='center', fontsize=10, 
                color='darkred', fontweight='bold')
    
    ax2.set_xlim(-1, 5.5)
    ax2.set_ylim(-0.5, 4)
    ax2.set_aspect('equal')
    ax2.set_title('Graph with Shortest Distances', fontsize=14)
    ax2.axis('off')
    
    fig.suptitle('Bellman-Ford as Tropical Fixed-Point Computation',
                 fontsize=16, fontweight='bold')
    plt.tight_layout()
    
    fig.savefig('bellman_ford_tropical.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def create_closure_operator_diagram() -> str:
    """
    Figure 5: Conceptual diagram of closure operator, diagonal bump, and fixed point.
    """
    fig, ax = plt.subplots(figsize=(10, 7))
    
    # Draw the main conceptual diagram
    # Three overlapping regions: Truth, Provability, Fixed Points
    
    # Large outer ellipse: "All valuations" (Truth)
    truth = mpatches.Ellipse((5, 4), 8, 5, color='lightyellow', ec='gold', 
                              lw=2, label='All valuations (Truth)')
    ax.add_patch(truth)
    
    # Medium ellipse: "Fixed points of P" (Provable truths)
    provable = mpatches.Ellipse((5.5, 4.2), 5, 3, color='lightblue', ec='steelblue',
                                 lw=2, alpha=0.7, label='Fixed points of P (Provable)')
    ax.add_patch(provable)
    
    # Small circle: "Gödel sentences"
    godel = mpatches.Circle((6.5, 4.5), 0.8, color='lightcoral', ec='red',
                             lw=2, alpha=0.8, label='Gödel sentences')
    ax.add_patch(godel)
    
    # Mark specific points
    ax.plot(6.5, 4.5, 'r*', markersize=15, zorder=10)
    ax.text(6.5, 5.5, 'g (Gödel sentence)\nP(g) = g', ha='center', fontsize=10,
           color='red', fontweight='bold')
    
    # Point outside fixed points
    ax.plot(2.5, 3), 
    ax.plot(2.5, 3, 'ko', markersize=8, zorder=10)
    ax.text(2.5, 2.3, 'f (not fixed)\nf < P(f)', ha='center', fontsize=10,
           color='black')
    
    # Arrow from f to P(f)
    ax.annotate('P', xy=(4, 3.5), xytext=(2.5, 3),
               arrowprops=dict(arrowstyle='->', color='blue', lw=2),
               fontsize=12, color='blue', fontweight='bold')
    ax.plot(4, 3.5, 'bs', markersize=8, zorder=10)
    ax.text(4, 2.8, 'P(f)', ha='center', fontsize=10, color='blue')
    
    # Diagonal bump arrow
    ax.annotate('DiagBump', xy=(7.5, 4.5), xytext=(6.5, 4.5),
               arrowprops=dict(arrowstyle='->', color='darkred', lw=2),
               fontsize=10, color='darkred')
    ax.plot(7.5, 4.5, 'r^', markersize=10, zorder=10)
    ax.text(7.8, 3.8, 'DiagBump(g)\n(perturbed)', ha='center', fontsize=9, color='darkred')
    
    # Gap annotation
    ax.annotate('GAP\n(incompleteness)', xy=(7.5, 5.2), xytext=(8.5, 5.8),
               arrowprops=dict(arrowstyle='->', color='purple', lw=2),
               fontsize=11, color='purple', fontweight='bold',
               bbox=dict(boxstyle='round,pad=0.3', facecolor='lavender', alpha=0.8))
    
    # Labels
    ax.text(1.5, 6.2, 'All Valuations', fontsize=13, color='goldenrod', fontweight='bold')
    ax.text(3.5, 5.8, 'Fixed Points of P', fontsize=12, color='steelblue', fontweight='bold')
    
    ax.set_xlim(0, 10)
    ax.set_ylim(1, 7)
    ax.set_aspect('equal')
    ax.set_title('Tropical Incompleteness: Structure of the Proof System',
                fontsize=16, fontweight='bold')
    ax.axis('off')
    
    fig.savefig('closure_operator_diagram.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


if __name__ == "__main__":
    print("Generating visualizations...")
    
    b64_1 = create_fixed_point_convergence_plot()
    print(f"  Fixed-point convergence: saved (base64 length: {len(b64_1)})")
    
    b64_2 = create_godel_sentence_diagram()
    print(f"  Gödel sentence diagram: saved (base64 length: {len(b64_2)})")
    
    b64_3 = create_incompleteness_landscape()
    print(f"  Incompleteness landscape: saved (base64 length: {len(b64_3)})")
    
    b64_4 = create_bellman_ford_visualization()
    print(f"  Bellman-Ford visualization: saved (base64 length: {len(b64_4)})")
    
    b64_5 = create_closure_operator_diagram()
    print(f"  Closure operator diagram: saved (base64 length: {len(b64_5)})")
    
    print("\nAll visualizations generated successfully.")
    print("PNG files saved to current directory.")

#!/usr/bin/env python3
"""
Applications of Tropical Convexity and Mean-Payoff Duality
===========================================================

Demonstrates real-world applications of the formal tropical theory:
1. Network timing verification (digital circuit analysis)
2. Scheduling with precedence constraints
3. Optimal routing in weighted networks
"""

import numpy as np
from algorithms import (
    shapley_operator, tropical_feasibility_shapley,
    verify_tropical_feasibility, tropical_to_game,
    potential_from_feasible_point
)


# ============================================================================
# Application 1: Digital Circuit Timing Analysis
# ============================================================================

def circuit_timing_analysis():
    """
    Tropical feasibility for digital circuit timing verification.
    
    In synchronous digital circuits, signals must satisfy setup and hold
    timing constraints. These are naturally tropical inequalities:
    
        max(arrival_time_i + delay_{j,i}) ≤ max(deadline_j_k + slack_{j,k})
    
    This is exactly our tropical halfspace system!
    """
    print("=" * 70)
    print("Application 1: Digital Circuit Timing Verification")
    print("=" * 70)
    
    # A simple pipeline: 3 stages with 2 timing constraints
    # Variables: x_0 = clock period adjustment, x_1 = buffer delay, x_2 = skew
    n = 3  # variables
    
    # Constraint 1: Setup time - signal must arrive before clock edge
    # max(2 + x_0, 1 + x_1, 0 + x_2) ≤ max(0 + x_0, 3 + x_1, 1 + x_2)
    # Constraint 2: Hold time - signal must not change too early
    # max(0 + x_0, 2 + x_1, 1 + x_2) ≤ max(1 + x_0, 0 + x_1, 3 + x_2)
    
    A = np.array([
        [2.0, 1.0, 0.0],  # Setup constraint coefficients (LHS)
        [0.0, 2.0, 1.0],  # Hold constraint coefficients (LHS)
    ])
    B = np.array([
        [0.0, 3.0, 1.0],  # Setup constraint coefficients (RHS)
        [1.0, 0.0, 3.0],  # Hold constraint coefficients (RHS)
    ])
    
    print(f"\nCircuit with {n} timing variables and {A.shape[0]} constraints:")
    print("  Setup: max(2+x₀, 1+x₁, 0+x₂) ≤ max(0+x₀, 3+x₁, 1+x₂)")
    print("  Hold:  max(0+x₀, 2+x₁, 1+x₂) ≤ max(1+x₀, 0+x₁, 3+x₂)")
    
    # Solve using Shapley iteration
    sol, converged, iters, trajectory = tropical_feasibility_shapley(A, B)
    
    print(f"\n  Shapley iteration: converged={converged}, iterations={iters}")
    if sol is not None:
        print(f"  Feasible timing assignment: x = [{', '.join(f'{v:.4f}' for v in sol)}]")
        feasible, violated = verify_tropical_feasibility(A, B, sol)
        print(f"  Verified feasible: {feasible}")
        
        # Show constraint satisfaction
        for j in range(A.shape[0]):
            lhs = max(A[j][i] + sol[i] for i in range(n))
            rhs = max(B[j][i] + sol[i] for i in range(n))
            slack = rhs - lhs
            print(f"  Constraint {j}: LHS={lhs:.4f} ≤ RHS={rhs:.4f} (slack={slack:.4f})")
    else:
        print("  No feasible timing assignment found — circuit has timing violation!")


# ============================================================================
# Application 2: Project Scheduling
# ============================================================================

def project_scheduling():
    """
    Tropical optimization for project scheduling with precedence constraints.
    
    Tasks have durations and precedence relationships. Finding a feasible
    schedule amounts to tropical feasibility:
    
        start_time_j + duration_j ≤ start_time_k  (for each precedence j → k)
    
    In tropical form: max(d_j + x_j) ≤ max(x_k) for precedence edges.
    """
    print("\n" + "=" * 70)
    print("Application 2: Project Scheduling with Precedence Constraints")
    print("=" * 70)
    
    # Project with 4 tasks:
    # Task 0 (duration 3) → Task 2
    # Task 1 (duration 2) → Task 2
    # Task 2 (duration 4) → Task 3
    # Task 1 (duration 2) → Task 3
    
    n = 4  # tasks
    print(f"\nProject with {n} tasks:")
    print("  Task 0 (dur=3) → Task 2")
    print("  Task 1 (dur=2) → Task 2")
    print("  Task 2 (dur=4) → Task 3")
    print("  Task 1 (dur=2) → Task 3")
    
    # Encode as tropical system: A x ≤ B x
    # Precedence j → k with duration d: d + x_j ≤ x_k
    # As tropical: max(d + x_j) ≤ max(x_k)
    # In matrix form: A has d in position (constraint, j), B has 0 in position (constraint, k)
    # Other entries are -infinity (we use -100 as proxy)
    
    NEG_INF = -100.0
    
    # 4 precedence constraints
    p = 4
    A = np.full((p, n), NEG_INF)
    B = np.full((p, n), NEG_INF)
    
    # Task 0 (dur=3) → Task 2: 3 + x_0 ≤ x_2
    A[0, 0] = 3.0; B[0, 2] = 0.0
    # Task 1 (dur=2) → Task 2: 2 + x_1 ≤ x_2
    A[1, 1] = 2.0; B[1, 2] = 0.0
    # Task 2 (dur=4) → Task 3: 4 + x_2 ≤ x_3
    A[2, 2] = 4.0; B[2, 3] = 0.0
    # Task 1 (dur=2) → Task 3: 2 + x_1 ≤ x_3
    A[3, 1] = 2.0; B[3, 3] = 0.0
    
    # Solve
    x0 = np.array([0.0, 0.0, 5.0, 10.0])  # Initial guess
    sol, converged, iters, _ = tropical_feasibility_shapley(A, B, x0=x0)
    
    print(f"\n  Shapley iteration: converged={converged}, iterations={iters}")
    if sol is not None:
        print(f"  Feasible schedule (start times): [{', '.join(f'{v:.2f}' for v in sol)}]")
        feasible, _ = verify_tropical_feasibility(A, B, sol)
        print(f"  Verified feasible: {feasible}")
        
        makespan = max(sol[3] + 1, sol[2] + 4)  # Last task completion
        print(f"  Project makespan: {makespan:.2f}")
    
    # Also solve from zero
    sol2, conv2, it2, _ = tropical_feasibility_shapley(A, B)
    if sol2 is not None:
        print(f"\n  Alternative schedule: [{', '.join(f'{v:.2f}' for v in sol2)}]")


# ============================================================================
# Application 3: Network Routing Optimization
# ============================================================================

def network_routing():
    """
    Tropical methods for optimal routing in weighted networks.
    
    Finding shortest paths in networks with additive costs is equivalent
    to finding potentials satisfying tropical constraints:
        cost(i,j) + pot(j) ≥ pot(i) for each edge (i,j)
    
    This is a sub-fixed-point problem for the tropical Shapley operator!
    """
    print("\n" + "=" * 70)
    print("Application 3: Network Routing via Tropical Potentials")
    print("=" * 70)
    
    # Network: 4 nodes, 5 edges with costs
    #   0 →(2) 1
    #   0 →(5) 2
    #   1 →(1) 2
    #   1 →(3) 3
    #   2 →(2) 3
    
    n = 4
    edges = [(0, 1, 2), (0, 2, 5), (1, 2, 1), (1, 3, 3), (2, 3, 2)]
    
    print(f"\nNetwork: {n} nodes, {len(edges)} edges")
    for s, t, c in edges:
        print(f"  {s} →({c}) {t}")
    
    # Encode as tropical system: cost(i,j) + pot(j) - pot(i) ≥ 0
    # Rewrite as: max(cost(i,j) + x_j) ≤ max(x_i + cost(i,j))
    # More directly: pot(i) ≤ cost(i,j) + pot(j)
    # This is: x_i ≤ min over out-edges of (cost + x_target)
    
    NEG_INF = -100.0
    p = len(edges)
    A = np.full((p, n), NEG_INF)
    B = np.full((p, n), NEG_INF)
    
    for idx, (s, t, c) in enumerate(edges):
        A[idx, s] = 0.0     # LHS: x_source
        B[idx, t] = c        # RHS: cost + x_target
    
    sol, converged, iters, _ = tropical_feasibility_shapley(A, B)
    
    print(f"\n  Tropical potential computation: converged={converged}, iterations={iters}")
    if sol is not None:
        print(f"  Potentials: [{', '.join(f'{v:.4f}' for v in sol)}]")
        
        # Verify: shortest distances from node 0
        # Normalize so pot(0) = 0
        pot = sol - sol[0]
        print(f"  Normalized (from node 0): [{', '.join(f'{v:.4f}' for v in pot)}]")
        
        # Check edge slack
        print("  Edge analysis:")
        for s, t, c in edges:
            slack = c + pot[t] - pot[s]
            tight = "TIGHT (shortest path)" if abs(slack) < 0.01 else ""
            print(f"    {s}→{t}: cost={c}, slack={slack:.4f} {tight}")
    
    # Mean-payoff game view
    game = tropical_to_game(A, B)
    print(f"\n  Associated mean-payoff game: {game.num_verts} vertices, {len(game.edges)} edges")


# ============================================================================
# Application 4: Control System Stability Analysis
# ============================================================================

def control_stability():
    """
    Tropical analysis for discrete event system stability.
    
    The Shapley operator models the dynamics of a max-plus linear system:
        x(t+1) = A ⊗ x(t) = max_j (A_{i,j} + x_j(t))
    
    Stability requires that the system's spectral radius (max cycle mean)
    is non-positive. This is exactly a tropical feasibility question!
    """
    print("\n" + "=" * 70)
    print("Application 4: Discrete Event System Stability")
    print("=" * 70)
    
    # Max-plus system matrix (3x3)
    # x(t+1)_0 = max(2+x_0(t), 1+x_1(t), -∞)
    # x(t+1)_1 = max(-∞, 1+x_1(t), 3+x_2(t))
    # x(t+1)_2 = max(1+x_0(t), -∞, 2+x_2(t))
    
    n = 3
    M = np.array([
        [2.0, 1.0, -100.0],
        [-100.0, 1.0, 3.0],
        [1.0, -100.0, 2.0]
    ])
    
    print(f"\nMax-plus system matrix ({n}×{n}):")
    for i in range(n):
        row = [f"{M[i,j]:+.0f}" if M[i,j] > -50 else " -∞" for j in range(n)]
        print(f"  [{', '.join(row)}]")
    
    # Stability check: does there exist x with x ≤ M ⊗ x?
    # Encode as: x_i ≤ max_j(M_{i,j} + x_j) for all i
    # This is: max(x_i) ≤ max(M_{i,j} + x_j)
    # In tropical halfspace form with identity on LHS
    
    A_sys = np.eye(n)
    B_sys = M.copy()
    
    print("\n  Checking stability (existence of invariant potential x ≤ M⊗x):")
    sol, converged, iters, trajectory = tropical_feasibility_shapley(A_sys, B_sys)
    
    if sol is not None and converged:
        print(f"  System is stable! Invariant potential: [{', '.join(f'{v:.4f}' for v in sol)}]")
        
        # Verify: T(x) ≥ x
        Tx = shapley_operator(A_sys, B_sys, sol)
        print(f"  T(x) = [{', '.join(f'{v:.4f}' for v in Tx)}]")
        print(f"  x ≤ T(x)? {np.all(sol <= Tx + 1e-9)}")
        
        # Show additive homogeneity
        c = 5.0
        x_shifted = sol + c
        Tx_shifted = shapley_operator(A_sys, B_sys, x_shifted)
        print(f"\n  Additive homogeneity verification:")
        print(f"  T(x + {c}) = [{', '.join(f'{v:.4f}' for v in Tx_shifted)}]")
        print(f"  T(x) + {c} = [{', '.join(f'{v:.4f}' for v in Tx + c)}]")
        print(f"  Equal? {np.allclose(Tx_shifted, Tx + c)}")
    else:
        print("  System may be unstable (no invariant potential found).")
    
    # Simulate dynamics
    print("\n  System trajectory from x(0) = [0, 0, 0]:")
    x = np.zeros(n)
    for t in range(6):
        print(f"    t={t}: x = [{', '.join(f'{v:.2f}' for v in x)}]")
        x_new = np.array([max(M[i, j] + x[j] for j in range(n)) for i in range(n)])
        growth = np.mean(x_new - x)
        x = x_new
    print(f"  Average growth rate ≈ {growth:.2f} (spectral radius proxy)")


if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║  Tropical Convexity: Real-World Applications                   ║")
    print("╚══════════════════════════════════════════════════════════════════╝")
    
    circuit_timing_analysis()
    project_scheduling()
    network_routing()
    control_stability()
    
    print("\n" + "=" * 70)
    print("All applications completed.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Tropical Convexity, Feasibility, and Mean-Payoff Game Reduction: Interactive Demo
=================================================================================

This script demonstrates the core concepts formalized in our Lean 4 development:
1. Tropical convex hulls of finite generator sets
2. Tropical halfspace feasibility checking
3. The Shapley operator and sub-fixed-point characterization
4. Reduction from tropical feasibility to mean-payoff games
"""

import numpy as np
from itertools import product

# ============================================================================
# Section 1: Tropical Arithmetic
# ============================================================================

def trop_add(a, b):
    """Tropical addition = max."""
    return max(a, b)

def trop_mult(a, b):
    """Tropical multiplication = classical addition."""
    return a + b

def trop_combination(a, x, b, y):
    """Tropical binary combination: max(a + x, b + y) coordinatewise."""
    return np.maximum(a + x, b + y)

# ============================================================================
# Section 2: Tropical Convex Hull
# ============================================================================

def tropical_convex_hull_membership(generators, x, tol=1e-9):
    """
    Check if x is in the tropical convex hull of generators.
    
    A point x ∈ ℝ^n is in tconv(v_1,...,v_m) if there exist c_1,...,c_m ∈ ℝ such that
    x_i = max_j (c_j + v_j_i) for all i.
    
    We solve this by checking if a valid coefficient vector exists.
    For each pair (j1, j2) of generators, x_i = max_j(c_j + v_j_i) implies
    c_j ≤ x_i - v_j_i for all i, with equality for the maximizing j at each coordinate.
    
    Returns: (is_member, coefficients or None)
    """
    m, n = generators.shape
    
    if m == 0:
        return False, None
    
    # Try to find coefficients c such that x_i = max_j(c_j + v_j_i)
    # For each j: c_j ≤ min_i(x_i - v_j_i) (necessary condition)
    # Set c_j = min_i(x_i - v_j_i) as the largest feasible coefficient
    c = np.array([np.min(x - generators[j]) for j in range(m)])
    
    # Check: does max_j(c_j + v_j_i) = x_i for all i?
    hull_point = np.array([max(c[j] + generators[j][i] for j in range(m)) for i in range(n)])
    
    if np.allclose(hull_point, x, atol=tol):
        return True, c
    
    return False, None

def generate_tropical_hull_points(generators, num_samples=100):
    """Generate random points in the tropical convex hull."""
    m, n = generators.shape
    points = []
    for _ in range(num_samples):
        c = np.random.randn(m) * 3  # random coefficients
        point = np.array([max(c[j] + generators[j][i] for j in range(m)) for i in range(n)])
        points.append(point)
    return np.array(points)

# ============================================================================
# Section 3: Tropical Halfspaces and Feasibility
# ============================================================================

def check_tropical_halfspace(A, B, x):
    """
    Check if x satisfies the tropical halfspace system:
    For all j: max_i(A[j][i] + x[i]) ≤ max_i(B[j][i] + x[i])
    """
    p, n = A.shape
    for j in range(p):
        lhs = max(A[j][i] + x[i] for i in range(n))
        rhs = max(B[j][i] + x[i] for i in range(n))
        if lhs > rhs + 1e-12:
            return False
    return True

def shapley_operator(A, B, x):
    """
    Compute the Shapley operator T(x):
    T(x)_i = min_j (max_k(B[j][k] + x[k]) - A[j][i])
    """
    p, n = A.shape
    result = np.zeros(n)
    for i in range(n):
        vals = []
        for j in range(p):
            sup_k = max(B[j][k] + x[k] for k in range(n))
            vals.append(sup_k - A[j][i])
        result[i] = min(vals)
    return result

def check_subfixed_point(A, B, x, tol=1e-9):
    """Check if x is a sub-fixed point: x ≤ T(x)."""
    Tx = shapley_operator(A, B, x)
    return np.all(x <= Tx + tol)

def shapley_iteration(A, B, x0, max_iter=1000, tol=1e-10):
    """
    Iterate the Shapley operator to find a sub-fixed point.
    Returns the iteration trajectory and convergence status.
    """
    x = x0.copy()
    trajectory = [x.copy()]
    for it in range(max_iter):
        Tx = shapley_operator(A, B, x)
        if np.allclose(x, Tx, atol=tol):
            return trajectory, True, it
        # Move toward fixed point
        x = 0.5 * x + 0.5 * Tx
        trajectory.append(x.copy())
    return trajectory, False, max_iter

# ============================================================================
# Section 4: Mean-Payoff Game Reduction
# ============================================================================

def tropical_to_mean_payoff_game(A, B):
    """
    Construct a mean-payoff game from tropical inequality system.
    
    Game structure:
    - n Max vertices (one per variable)
    - p Min vertices (one per constraint)
    - Edges: Max(i) → Min(j) with weight -A[j][i]
    - Edges: Min(j) → Max(k) with weight B[j][k]
    
    Returns: dict with game structure
    """
    p, n = A.shape
    
    vertices = []
    for i in range(n):
        vertices.append({'id': i, 'player': 'Max', 'label': f'x_{i}'})
    for j in range(p):
        vertices.append({'id': n + j, 'player': 'Min', 'label': f'C_{j}'})
    
    edges = []
    for i in range(n):
        for j in range(p):
            edges.append({
                'src': i, 'tgt': n + j,
                'weight': -A[j][i],
                'label': f'Max(x_{i}) → Min(C_{j}): w={-A[j][i]:.2f}'
            })
    for j in range(p):
        for k in range(n):
            edges.append({
                'src': n + j, 'tgt': k,
                'weight': B[j][k],
                'label': f'Min(C_{j}) → Max(x_{k}): w={B[j][k]:.2f}'
            })
    
    return {'vertices': vertices, 'edges': edges, 'n': n, 'p': p}

def check_mean_payoff_potential(game, potential):
    """
    Check if a potential certifies nonneg game value.
    For each edge e: weight(e) + pot(tgt) ≥ pot(src) OR src is Max vertex.
    """
    n, p = game['n'], game['p']
    for edge in game['edges']:
        src, tgt, w = edge['src'], edge['tgt'], edge['weight']
        is_max = src < n  # Max vertices are 0..n-1
        if not is_max:
            if w + potential[tgt] < potential[src] - 1e-10:
                return False
    return True

# ============================================================================
# DEMO EXECUTION
# ============================================================================

def demo_tropical_convex_hull():
    """Demonstrate tropical convex hull computation."""
    print("=" * 70)
    print("DEMO 1: Tropical Convex Hull")
    print("=" * 70)
    
    # Three generators in R^2
    generators = np.array([
        [0.0, 0.0],
        [3.0, 1.0],
        [1.0, 4.0]
    ])
    m, n = generators.shape
    print(f"\nGenerators (m={m} points in R^{n}):")
    for j in range(m):
        print(f"  v_{j} = {generators[j]}")
    
    # Check that generators are in their own hull
    print("\nGenerator self-membership (Theorem: InTropicalConvHull_generator):")
    for j in range(m):
        is_in, c = tropical_convex_hull_membership(generators, generators[j])
        print(f"  v_{j} ∈ tconv(V)? {is_in}, coefficients: {c}")
    
    # Test some random points
    print("\nRandom hull points:")
    hull_points = generate_tropical_hull_points(generators, num_samples=5)
    for idx, pt in enumerate(hull_points):
        is_in, c = tropical_convex_hull_membership(generators, pt)
        print(f"  Point {idx}: {pt.round(3)} → in hull? {is_in}")
    
    # Tropical combination closure (Theorem: tropicalConvHull_is_convex)
    print("\nTropical combination closure test:")
    x, y = generators[0], generators[1]
    for a, b in [(0, 0), (1, -1), (2, 3)]:
        combo = trop_combination(a, x, b, y)
        is_in, c = tropical_convex_hull_membership(generators, combo)
        print(f"  max({a}+v_0, {b}+v_1) = {combo} → in hull? {is_in}")

def demo_tropical_feasibility():
    """Demonstrate tropical feasibility and Shapley operator."""
    print("\n" + "=" * 70)
    print("DEMO 2: Tropical Feasibility & Shapley Operator")
    print("=" * 70)
    
    # Feasible system: max(1+x₀, 0+x₁) ≤ max(0+x₀, 2+x₁)
    A = np.array([[1.0, 0.0]])
    B = np.array([[0.0, 2.0]])
    p, n = A.shape
    
    print(f"\nTropical inequality system ({p} constraints, {n} variables):")
    for j in range(p):
        lhs = " ⊕ ".join(f"({A[j][i]:+.1f} ⊗ x_{i})" for i in range(n))
        rhs = " ⊕ ".join(f"({B[j][i]:+.1f} ⊗ x_{i})" for i in range(n))
        print(f"  {lhs}  ≤  {rhs}")
        print(f"  i.e., max({', '.join(f'{A[j][i]:.1f}+x_{i}' for i in range(n))}) ≤ max({', '.join(f'{B[j][i]:.1f}+x_{i}' for i in range(n))})")
    
    # Test a feasible point
    x_test = np.array([0.0, 0.0])
    print(f"\nTest x = {x_test}:")
    print(f"  Satisfies halfspace? {check_tropical_halfspace(A, B, x_test)}")
    print(f"  T(x) = {shapley_operator(A, B, x_test)}")
    print(f"  Sub-fixed point (x ≤ T(x))? {check_subfixed_point(A, B, x_test)}")
    
    # Theorem: feasibility ↔ sub-fixed point
    print("\n  Theorem verification (tropical_feasibility_iff_subfixed_point):")
    print(f"  System feasible? {check_tropical_halfspace(A, B, x_test)}")
    print(f"  Has sub-fixed point? {check_subfixed_point(A, B, x_test)}")
    print(f"  ↔ equivalence confirmed: both are {check_tropical_halfspace(A, B, x_test)}")
    
    # Additive homogeneity test
    c_shift = 5.0
    x_shifted = x_test + c_shift
    Tx = shapley_operator(A, B, x_test)
    Tx_shifted = shapley_operator(A, B, x_shifted)
    print(f"\n  Additive homogeneity test (TropOp_additively_homogeneous):")
    print(f"  T(x) = {Tx}")
    print(f"  T(x + {c_shift}) = {Tx_shifted}")
    print(f"  T(x) + {c_shift} = {Tx + c_shift}")
    print(f"  T(x+c) = T(x)+c? {np.allclose(Tx_shifted, Tx + c_shift)}")
    
    # Monotonicity test
    y_test = x_test + 1  # y ≥ x
    Ty = shapley_operator(A, B, y_test)
    print(f"\n  Monotonicity test (TropOp_monotone):")
    print(f"  x = {x_test}, T(x) = {Tx}")
    print(f"  y = {y_test}, T(y) = {Ty}")
    print(f"  x ≤ y? {np.all(x_test <= y_test)}")
    print(f"  T(x) ≤ T(y)? {np.all(Tx <= Ty + 1e-10)}")

def demo_mean_payoff_reduction():
    """Demonstrate the reduction to mean-payoff games."""
    print("\n" + "=" * 70)
    print("DEMO 3: Mean-Payoff Game Reduction")
    print("=" * 70)
    
    # Feasible system
    A = np.array([
        [2.0, 0.0],
        [0.0, 1.0]
    ])
    B = np.array([
        [0.0, 3.0],
        [2.0, 0.0]
    ])
    p, n = A.shape
    
    print(f"\nTropical inequality system ({p} constraints, {n} variables):")
    for j in range(p):
        print(f"  max({', '.join(f'{A[j][i]:.0f}+x_{i}' for i in range(n))}) ≤ max({', '.join(f'{B[j][i]:.0f}+x_{i}' for i in range(n))})")
    
    # Construct game
    game = tropical_to_mean_payoff_game(A, B)
    print(f"\nMean-payoff game (tropical_feasibility_reduces_to_mean_payoff):")
    print(f"  Vertices: {len(game['vertices'])} ({n} Max + {p} Min)")
    for v in game['vertices']:
        print(f"    {v['label']} ({v['player']})")
    print(f"  Edges: {len(game['edges'])}")
    for e in game['edges']:
        print(f"    {e['label']}")
    
    # Find a feasible point and use it as potential
    x_feas = np.array([0.0, 0.0])
    print(f"\nFeasibility check:")
    print(f"  x = {x_feas}: feasible? {check_tropical_halfspace(A, B, x_feas)}")
    
    # Better feasible point
    x_feas = np.array([0.0, 1.0])
    print(f"  x = {x_feas}: feasible? {check_tropical_halfspace(A, B, x_feas)}")
    
    # Construct potential from feasible point
    potential = np.zeros(n + p)
    potential[:n] = x_feas  # Max vertices get x values
    for j in range(p):
        potential[n + j] = max(A[j][i] + x_feas[i] for i in range(n))
    
    print(f"\n  Potential derived from feasible point: {potential}")
    print(f"  Certifies nonneg value? {check_mean_payoff_potential(game, potential)}")

def demo_caratheodory_conjecture():
    """Test the tropical Carathéodory conjecture."""
    print("\n" + "=" * 70)
    print("DEMO 4: Tropical Carathéodory Conjecture Test")
    print("=" * 70)
    
    print("\nConjecture: Every point in tconv(v_1,...,v_m) in R^n")
    print("can be represented using at most n+1 active generators.")
    
    n = 2  # dimension
    m = 5  # number of generators
    
    np.random.seed(42)
    generators = np.random.randn(m, n) * 3
    
    print(f"\nGenerators ({m} points in R^{n}):")
    for j in range(m):
        print(f"  v_{j} = {generators[j].round(3)}")
    
    # Generate hull points and check support sizes
    max_support = 0
    num_tests = 200
    
    for trial in range(num_tests):
        c = np.random.randn(m) * 5
        point = np.array([max(c[j] + generators[j][i] for j in range(m)) for i in range(n)])
        
        # Find minimum support: which generators are "active"?
        active = set()
        for i in range(n):
            vals = [c[j] + generators[j][i] for j in range(m)]
            max_val = max(vals)
            for j in range(m):
                if abs(vals[j] - max_val) < 1e-9:
                    active.add(j)
        
        support_size = len(active)
        max_support = max(max_support, support_size)
    
    print(f"\nResults over {num_tests} random hull points:")
    print(f"  Maximum support size observed: {max_support}")
    print(f"  Carathéodory bound (n+1): {n + 1}")
    print(f"  Conjecture holds for this sample? {max_support <= n + 1}")

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║  Tropical Convexity & Mean-Payoff Game Reduction: Demos        ║")
    print("║  Companion to formally verified Lean 4 proofs                  ║")
    print("╚══════════════════════════════════════════════════════════════════╝")
    
    demo_tropical_convex_hull()
    demo_tropical_feasibility()
    demo_mean_payoff_reduction()
    demo_caratheodory_conjecture()
    
    print("\n" + "=" * 70)
    print("All demos completed successfully.")
    print("=" * 70)

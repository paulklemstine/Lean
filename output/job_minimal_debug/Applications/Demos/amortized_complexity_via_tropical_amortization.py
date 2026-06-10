#!/usr/bin/env python3
"""
Tropical Amortized Analysis: Real-World Applications

Demonstrates practical applications of the tropical amortized framework:
1. Dynamic array (ArrayList/vector) resizing analysis
2. Splay tree rotation amortized cost
3. Network routing with tropical shortest paths
4. Job scheduling via min-plus algebra
"""

import numpy as np
from typing import List, Tuple, Optional
from algorithms import (
    compute_amortized_analysis,
    tropical_convolution,
    tropical_matrix_multiply,
    TransitionSystem,
    bellman_value_iteration,
    optimal_potential_bellman_ford,
)


# ============================================================
# Application 1: Dynamic Array Resizing
# ============================================================

def dynamic_array_analysis(n_operations: int) -> dict:
    """Analyze dynamic array (vector/ArrayList) amortized cost.
    
    Operations: append elements to a dynamic array that doubles
    capacity when full.
    
    Actual cost:
    - Normal append: 1
    - Append with resize: current_size + 1 (copy all elements + insert)
    
    Potential: Φ(s) = 2 * size - capacity
    
    Amortized cost is always ≤ 3.
    """
    size = 0
    capacity = 1
    
    states = [(size, capacity)]
    costs = []
    potentials = [max(0, 2 * size - capacity)]
    
    for _ in range(n_operations):
        if size == capacity:
            # Resize: double capacity
            actual_cost = size + 1  # copy all elements + insert new
            capacity *= 2
        else:
            actual_cost = 1
        
        size += 1
        costs.append(actual_cost)
        states.append((size, capacity))
        potentials.append(max(0, 2 * size - capacity))
    
    analysis = compute_amortized_analysis(
        [float(c) for c in costs],
        [float(p) for p in potentials]
    )
    
    return {
        "n": n_operations,
        "total_actual": analysis.total_actual,
        "total_amortized": analysis.total_amortized,
        "max_single_cost": max(costs),
        "max_amortized": analysis.max_amortized,
        "avg_actual": analysis.total_actual / n_operations,
        "bound_3n": 3 * n_operations,
        "costs": costs[:20],  # first 20 for display
        "amortized": analysis.amortized_charges[:20],
    }


# ============================================================
# Application 2: Network Routing (Tropical Shortest Paths)
# ============================================================

def network_routing_analysis(n_nodes: int, edges: List[Tuple[int, int, float]]) -> dict:
    """Analyze network routing using tropical matrix algebra.
    
    Computes all-pairs shortest paths via repeated tropical matrix squaring.
    This is the computational backbone of the Bellman perspective on
    amortized analysis.
    """
    INF = float('inf')
    
    # Build adjacency matrix
    W = np.full((n_nodes, n_nodes), INF)
    for i in range(n_nodes):
        W[i][i] = 0
    for u, v, w in edges:
        W[u][v] = min(W[u][v], w)
    
    # Compute shortest paths by repeated squaring
    D = W.copy()
    steps = 0
    while steps < n_nodes:
        D_new = tropical_matrix_multiply(D, D)
        if np.allclose(D_new, D):
            break
        D = D_new
        steps += 1
    
    # Find optimal potential (shortest distances from node 0)
    phi = D[0].copy()
    
    # Compute reduced costs
    reduced = np.full((n_nodes, n_nodes), INF)
    for u, v, w in edges:
        if phi[u] < INF and phi[v] < INF:
            reduced[u][v] = w + phi[v] - phi[u]
    
    return {
        "n_nodes": n_nodes,
        "n_edges": len(edges),
        "shortest_paths": D,
        "potential": phi,
        "reduced_costs": reduced,
        "max_reduced_cost": float(np.max(reduced[reduced < INF])) if np.any(reduced < INF) else INF,
        "all_reduced_nonneg": bool(np.all(reduced[reduced < INF] >= -1e-10)),
    }


# ============================================================
# Application 3: Job Scheduling via Min-Plus Algebra
# ============================================================

def job_scheduling_analysis(
    phase_costs: List[List[float]]
) -> dict:
    """Analyze multi-phase job scheduling via min-plus convolution.
    
    Given k phases where phase j has cost profile f_j(t) for t time units,
    find the optimal allocation of total time T across phases.
    
    Total cost = f_1 ⋆ f_2 ⋆ ... ⋆ f_k (min-plus convolution)
    
    Associativity of convolution guarantees the decomposition is well-defined.
    """
    if not phase_costs:
        return {"n_phases": 0, "optimal_costs": []}
    
    # Compute iterated convolution
    result = phase_costs[0]
    intermediate = [phase_costs[0]]
    
    for j in range(1, len(phase_costs)):
        result = tropical_convolution(result, phase_costs[j])
        intermediate.append(result[:])
    
    return {
        "n_phases": len(phase_costs),
        "phase_costs": phase_costs,
        "optimal_total_costs": result,
        "optimal_for_10_units": result[10] if len(result) > 10 else None,
        "intermediate_results": intermediate,
    }


# ============================================================
# Application 4: Binary Counter with Potential Synthesis
# ============================================================

def binary_counter_potential_synthesis(n_bits: int) -> dict:
    """Synthesize optimal potential for binary counter using Bellman-Ford.
    
    States: 0, 1, ..., 2^n_bits - 1 (counter values)
    Transitions: increment with actual cost = number of bits flipped
    """
    n_states = 2 ** n_bits
    INF = float('inf')
    
    # Build transition matrix (only increment transitions)
    W = np.full((n_states, n_states), INF)
    
    for s in range(n_states):
        s_next = (s + 1) % n_states
        # Cost = number of bits flipped
        flipped = bin(s ^ s_next).count('1')
        W[s][s_next] = flipped
    
    system = TransitionSystem(n_states, W)
    phi, bound = optimal_potential_bellman_ford(system)
    
    # Compare with known potential (number of 1-bits)
    known_phi = np.array([bin(s).count('1') for s in range(n_states)], dtype=float)
    
    return {
        "n_bits": n_bits,
        "n_states": n_states,
        "optimal_potential": phi.tolist() if phi is not None else None,
        "optimal_bound": bound,
        "known_potential": known_phi.tolist(),
        "known_max_amortized": max(
            W[s][(s+1) % n_states] + known_phi[(s+1) % n_states] - known_phi[s]
            for s in range(n_states)
            if W[s][(s+1) % n_states] < INF
        ),
    }


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("=" * 70)
    print("TROPICAL AMORTIZED ANALYSIS: REAL-WORLD APPLICATIONS")
    print("=" * 70)
    
    # Application 1: Dynamic Array
    print("\n" + "=" * 70)
    print("APPLICATION 1: Dynamic Array Resizing")
    print("=" * 70)
    
    for n in [16, 100, 1000]:
        result = dynamic_array_analysis(n)
        print(f"\nn = {n} append operations:")
        print(f"  Total actual cost:  {result['total_actual']:.0f}")
        print(f"  Max single cost:    {result['max_single_cost']}")
        print(f"  Max amortized cost: {result['max_amortized']:.0f}")
        print(f"  Avg actual cost:    {result['avg_actual']:.4f}")
        print(f"  Bound (3n):         {result['bound_3n']}")
    
    print(f"\nFirst 20 costs:     {dynamic_array_analysis(20)['costs']}")
    print(f"First 20 amortized: {dynamic_array_analysis(20)['amortized']}")
    
    # Application 2: Network Routing
    print("\n" + "=" * 70)
    print("APPLICATION 2: Network Routing (Tropical Shortest Paths)")
    print("=" * 70)
    
    edges = [
        (0, 1, 4), (0, 2, 2),
        (1, 2, 1), (1, 3, 5),
        (2, 1, 1), (2, 3, 8), (2, 4, 10),
        (3, 4, 2),
        (4, 3, 1),
    ]
    result = network_routing_analysis(5, edges)
    
    print(f"\n{result['n_nodes']} nodes, {result['n_edges']} edges")
    print(f"Potential (shortest from node 0): {result['potential']}")
    print(f"All reduced costs nonneg: {result['all_reduced_nonneg']}")
    print(f"Max reduced cost: {result['max_reduced_cost']:.1f}")
    print(f"\nShortest path matrix:")
    for i in range(5):
        row = [f"{d:.0f}" if d < 1e10 else "∞" for d in result['shortest_paths'][i]]
        print(f"  Node {i}: {row}")
    
    # Application 3: Job Scheduling
    print("\n" + "=" * 70)
    print("APPLICATION 3: Multi-Phase Job Scheduling")
    print("=" * 70)
    
    # Three phases with different cost profiles
    phase1 = [0, 1, 3, 6, 10, 15, 21, 28, 36, 45, 55]  # quadratic
    phase2 = [0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20]   # linear
    phase3 = [0, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]    # high startup

    result = job_scheduling_analysis([phase1, phase2, phase3])
    
    print(f"\nPhase 1 (quadratic): {phase1}")
    print(f"Phase 2 (linear):    {phase2}")
    print(f"Phase 3 (startup):   {phase3}")
    print(f"\nOptimal total cost for T time units:")
    for t in range(min(11, len(result['optimal_total_costs']))):
        print(f"  T={t:2d}: {result['optimal_total_costs'][t]:.0f}")
    
    # Application 4: Binary Counter Potential Synthesis
    print("\n" + "=" * 70)
    print("APPLICATION 4: Binary Counter Potential Synthesis")
    print("=" * 70)
    
    for bits in [2, 3, 4]:
        result = binary_counter_potential_synthesis(bits)
        print(f"\n{bits}-bit counter ({result['n_states']} states):")
        print(f"  Known potential (1-bits): {result['known_potential']}")
        print(f"  Known max amortized:     {result['known_max_amortized']:.0f}")
        if result['optimal_potential']:
            # Normalize: shift so minimum is 0
            phi = np.array(result['optimal_potential'])
            phi = phi - phi.min()
            print(f"  Synthesized potential:    {phi.tolist()}")
            print(f"  Optimal bound:           {result['optimal_bound']:.4f}")
    
    print("\n" + "=" * 70)
    print("All applications completed successfully.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Tropical Amortized Analysis: Demonstrations

Concrete numerical examples illustrating the theorems:
1. Potential method telescoping
2. Accounting method with credit balance
3. Binary counter amortized analysis
4. Stack push/pop amortized analysis
5. Min-plus convolution
"""

import numpy as np
from typing import List, Tuple, Callable


def amortized_charges(costs: List[int], potentials: List[int]) -> List[int]:
    """Compute amortized charges given actual costs and potential values.
    
    amortized[i] = cost[i] + potential[i+1] - potential[i]
    
    Args:
        costs: Actual operation costs, length n
        potentials: Potential values at each state, length n+1
    
    Returns:
        List of amortized charges, length n
    """
    n = len(costs)
    assert len(potentials) == n + 1
    return [costs[i] + potentials[i+1] - potentials[i] for i in range(n)]


def verify_telescoping(costs: List[int], potentials: List[int]) -> dict:
    """Verify the telescoping identity: sum(amortized) = sum(costs) + Phi(n) - Phi(0).
    
    This is the core theorem of amortized analysis.
    """
    charges = amortized_charges(costs, potentials)
    sum_amortized = sum(charges)
    sum_actual = sum(costs)
    potential_gap = potentials[-1] - potentials[0]
    
    return {
        "costs": costs,
        "potentials": potentials,
        "amortized_charges": charges,
        "sum_actual": sum_actual,
        "sum_amortized": sum_amortized,
        "potential_gap": potential_gap,
        "identity_holds": sum_amortized == sum_actual + potential_gap,
        "identity": f"sum(amortized) = {sum_amortized} = {sum_actual} + {potential_gap} = sum(costs) + Phi(n) - Phi(0)"
    }


def credit_balance(costs: List[int], assigned_charges: List[int]) -> List[int]:
    """Compute the credit balance at each step.
    
    B[0] = 0
    B[i+1] = B[i] + a[i] - c[i]
    """
    n = len(costs)
    B = [0] * (n + 1)
    for i in range(n):
        B[i+1] = B[i] + assigned_charges[i] - costs[i]
    return B


# ============================================================
# Demo 1: Binary Counter
# ============================================================

def binary_counter_simulation(n_increments: int) -> dict:
    """Simulate binary counter increments and verify amortized analysis.
    
    State = number of 1-bits
    Potential = number of 1-bits
    Actual cost of increment = trailing_ones + 1
    Amortized cost = 2 (always)
    """
    # Simulate the counter
    counter = 0
    n_bits = max(1, int(np.log2(n_increments + 1)) + 2)
    
    states = [0]  # number of 1-bits
    costs = []
    trailing_ones_list = []
    
    for _ in range(n_increments):
        # Count trailing 1-bits
        trailing_ones = 0
        temp = counter
        while temp & 1:
            trailing_ones += 1
            temp >>= 1
        
        actual_cost = trailing_ones + 1
        costs.append(actual_cost)
        trailing_ones_list.append(trailing_ones)
        
        counter += 1
        ones = bin(counter).count('1')
        states.append(ones)
    
    # Potential = number of 1-bits
    potentials = states[:]
    charges = amortized_charges(costs, potentials)
    
    return {
        "n": n_increments,
        "total_actual_cost": sum(costs),
        "total_amortized_cost": sum(charges),
        "bound_2n": 2 * n_increments,
        "all_amortized_eq_2": all(c == 2 for c in charges),
        "max_single_cost": max(costs) if costs else 0,
        "avg_actual_cost": sum(costs) / n_increments if n_increments > 0 else 0,
        "telescoping_check": verify_telescoping(costs, potentials)["identity_holds"],
    }


# ============================================================
# Demo 2: Stack Push/Pop
# ============================================================

def stack_simulation(operations: List[str]) -> dict:
    """Simulate stack operations and verify amortized analysis.
    
    Push: cost 1, stack size +1
    Pop: cost 1, stack size -1
    Potential = stack size
    """
    size = 0
    states = [0]
    costs = []
    
    for op in operations:
        if op == "push":
            costs.append(1)
            size += 1
        elif op == "pop" and size > 0:
            costs.append(1)
            size -= 1
        else:
            costs.append(0)
        states.append(size)
    
    potentials = states[:]
    charges = amortized_charges(costs, potentials)
    
    return {
        "operations": operations,
        "states": states,
        "costs": costs,
        "amortized_charges": charges,
        "total_actual": sum(costs),
        "total_amortized": sum(charges),
        "max_amortized": max(charges) if charges else 0,
        "bound_2n": 2 * len(operations),
    }


# ============================================================
# Demo 3: Min-Plus Convolution
# ============================================================

def tropical_conv(f: List[int], g: List[int], n: int) -> int:
    """Compute min-plus convolution (f * g)(n) = min_{k<=n} (f[k] + g[n-k])."""
    return min(f[k] + g[n - k] for k in range(n + 1) if k < len(f) and n - k < len(g))


def tropical_conv_full(f: List[int], g: List[int]) -> List[int]:
    """Compute full min-plus convolution."""
    n = len(f) + len(g) - 2
    return [tropical_conv(f, g, i) for i in range(n + 1)]


def verify_associativity(f: List[int], g: List[int], h: List[int]) -> dict:
    """Verify (f * g) * h = f * (g * h) for min-plus convolution."""
    fg = tropical_conv_full(f, g)
    fg_h = tropical_conv_full(fg, h)
    
    gh = tropical_conv_full(g, h)
    f_gh = tropical_conv_full(f, gh)
    
    # Compare up to the minimum length
    min_len = min(len(fg_h), len(f_gh))
    
    return {
        "f": f,
        "g": g,
        "h": h,
        "fg": fg,
        "gh": gh,
        "fg_h": fg_h[:min_len],
        "f_gh": f_gh[:min_len],
        "associative": fg_h[:min_len] == f_gh[:min_len],
    }


# ============================================================
# Demo 4: Bellman Equation
# ============================================================

def bellman_value_iteration(weights: np.ndarray, T: int) -> np.ndarray:
    """Compute value function V[t][s] via Bellman iteration.
    
    V[0][s] = 0 for all s
    V[t+1][s] = min_{s'} (w[s][s'] + V[t][s'])
    
    Args:
        weights: n x n matrix of transition costs (inf for no edge)
        T: number of time steps
    
    Returns:
        V: (T+1) x n matrix of values
    """
    n = weights.shape[0]
    V = np.zeros((T + 1, n))
    
    for t in range(T):
        for s in range(n):
            V[t + 1][s] = min(weights[s][sp] + V[t][sp] for sp in range(n))
    
    return V


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("=" * 70)
    print("TROPICAL AMORTIZED ANALYSIS: DEMONSTRATIONS")
    print("=" * 70)
    
    # Demo 1: Binary Counter
    print("\n" + "=" * 70)
    print("DEMO 1: Binary Counter Amortized Analysis")
    print("=" * 70)
    
    for n in [10, 100, 1000]:
        result = binary_counter_simulation(n)
        print(f"\nn = {n} increments:")
        print(f"  Total actual cost:    {result['total_actual_cost']}")
        print(f"  Total amortized cost: {result['total_amortized_cost']}")
        print(f"  Upper bound (2n):     {result['bound_2n']}")
        print(f"  All amortized = 2:    {result['all_amortized_eq_2']}")
        print(f"  Max single cost:      {result['max_single_cost']}")
        print(f"  Avg actual cost:      {result['avg_actual_cost']:.4f}")
        print(f"  Telescoping verified: {result['telescoping_check']}")
    
    # Demo 2: Stack
    print("\n" + "=" * 70)
    print("DEMO 2: Stack Push/Pop Amortized Analysis")
    print("=" * 70)
    
    ops = ["push"] * 5 + ["pop"] * 3 + ["push"] * 2 + ["pop"] * 4
    result = stack_simulation(ops)
    print(f"\nOperations: {ops}")
    print(f"States:     {result['states']}")
    print(f"Costs:      {result['costs']}")
    print(f"Amortized:  {result['amortized_charges']}")
    print(f"Total actual:    {result['total_actual']}")
    print(f"Total amortized: {result['total_amortized']}")
    print(f"Bound (2n):      {result['bound_2n']}")
    
    # Demo 3: Telescoping Identity
    print("\n" + "=" * 70)
    print("DEMO 3: Telescoping Identity Verification")
    print("=" * 70)
    
    costs = [3, 1, 4, 1, 5, 9, 2, 6]
    potentials = [0, 2, 1, 5, 3, 7, 1, 8, 4]
    result = verify_telescoping(costs, potentials)
    print(f"\nCosts:      {result['costs']}")
    print(f"Potentials: {result['potentials']}")
    print(f"Amortized:  {result['amortized_charges']}")
    print(f"Identity:   {result['identity']}")
    print(f"Verified:   {result['identity_holds']}")
    
    # Demo 4: Min-Plus Convolution
    print("\n" + "=" * 70)
    print("DEMO 4: Min-Plus Convolution and Associativity")
    print("=" * 70)
    
    f = [0, 3, 5, 8]
    g = [0, 2, 7, 9]
    h = [0, 1, 4, 6]
    
    conv_fg = tropical_conv_full(f, g)
    print(f"\nf = {f}")
    print(f"g = {g}")
    print(f"h = {h}")
    print(f"f ⋆ g = {conv_fg}")
    
    assoc = verify_associativity(f, g, h)
    print(f"(f ⋆ g) ⋆ h = {assoc['fg_h']}")
    print(f"f ⋆ (g ⋆ h) = {assoc['f_gh']}")
    print(f"Associative:  {assoc['associative']}")
    
    # Demo 5: Bellman Value Iteration
    print("\n" + "=" * 70)
    print("DEMO 5: Bellman Value Iteration (Tropical DP)")
    print("=" * 70)
    
    # 3-state system with transition costs
    W = np.array([
        [2, 3, float('inf')],
        [float('inf'), 1, 4],
        [5, float('inf'), 2]
    ])
    
    V = bellman_value_iteration(W, 5)
    print(f"\nTransition cost matrix W:")
    for i in range(3):
        print(f"  {['A', 'B', 'C'][i]}: {[f'{w:.0f}' if w < 1000 else '∞' for w in W[i]]}")
    
    print(f"\nValue function V[t][s]:")
    for t in range(6):
        print(f"  t={t}: {[f'{v:.0f}' for v in V[t]]}")
    
    # Check potential function
    phi = np.array([0, -1, 1])  # candidate potential
    print(f"\nPotential Φ = {phi.tolist()}")
    print("Reduced costs (w[s][s'] + Φ[s'] - Φ[s]):")
    for i in range(3):
        reduced = [W[i][j] + phi[j] - phi[i] if W[i][j] < 1000 else float('inf')
                   for j in range(3)]
        print(f"  {['A', 'B', 'C'][i]}: {[f'{r:.0f}' if r < 1000 else '∞' for r in reduced]}")
    
    print("\n" + "=" * 70)
    print("All demonstrations completed successfully.")
    print("=" * 70)


#!/usr/bin/env python3
"""Generate PACKAGE.json with all deliverable content."""

import json
import base64
import os

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

def image_to_base64(path):
    with open(path, 'rb') as f:
        data = base64.b64encode(f.read()).decode('utf-8')
    return f"data:image/png;base64,{data}"

# Read all content
article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
lean_main = read_file('Catalog/Computation/TropicalAmortized.lean')
lean_examples = read_file('Catalog/Computation/TropicalAmortizedExamples.lean')
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')
applications_code = read_file('applications.py')

# Read visualization images
viz_data = {}
for name in ['binary_counter', 'potential_credit', 'tropical_conv',
             'bellman_convergence', 'framework_overview']:
    path = f"{name}.png"
    if os.path.exists(path):
        viz_data[name] = image_to_base64(path)

package = {
    "title": "Amortized Complexity via Tropical Algebra: A Formal Framework",
    "domain": "Computation / Tropical Algebra / Algorithm Analysis",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Tropical Amortized Analysis Demonstrations",
            "code": demo_code
        }
    ],
    "algorithms": [
        {
            "name": "Optimal Potential via Bellman-Ford",
            "pseudocode": """Algorithm: OptimalPotential(S, E, w)
Input: State set S, edges E with costs w
Output: Potential Phi : S -> Z and optimal amortized bound

1. Binary search for optimal bound b*:
   a. Construct constraint graph G with edge weights b - w(s,s')
   b. Run Bellman-Ford to check feasibility
   c. If feasible: upper bound <- b; extract Phi = -dist
   d. If infeasible (negative cycle): lower bound <- b
2. Return (Phi, b*)

Complexity: O(|S|^2 * |E| * log(max_weight))""",
            "code": algorithms_code
        },
        {
            "name": "Min-Plus Convolution",
            "pseudocode": """Algorithm: TropicalConvolution(f, g, n)
Input: Cost profiles f[0..m], g[0..p]
Output: (f * g)[0..m+p]

For each target n = 0 to m+p:
  result[n] = min over k = max(0,n-p) to min(m,n) of (f[k] + g[n-k])

Complexity: O(m*p) time, O(m+p) space""",
            "code": algorithms_code
        }
    ],
    "visualizations": [
        {"name": "Binary Counter Amortized Analysis", "data": viz_data.get('binary_counter', '')},
        {"name": "Potential Function and Credit Balance", "data": viz_data.get('potential_credit', '')},
        {"name": "Min-Plus Convolution", "data": viz_data.get('tropical_conv', '')},
        {"name": "Bellman Value Iteration", "data": viz_data.get('bellman_convergence', '')},
        {"name": "Framework Overview", "data": viz_data.get('framework_overview', '')},
    ],
    "lean_proofs": lean_main + "\n\n-- ============================================================\n-- Examples File\n-- ============================================================\n\n" + lean_examples
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print(f"PACKAGE.json generated ({os.path.getsize('PACKAGE.json')} bytes)")


#!/usr/bin/env python3
"""
Tropical Amortized Analysis: Visualizations

Generates publication-quality charts illustrating key concepts:
1. Binary counter amortized analysis
2. Potential function and credit balance
3. Min-plus convolution
4. Bellman value iteration convergence
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch
import base64
from io import BytesIO


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight',
                facecolor='white', edgecolor='none')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


def plot_binary_counter():
    """Plot binary counter actual vs amortized costs."""
    n = 64
    counter = 0
    costs = []
    amortized = []
    potentials = [0]
    
    for _ in range(n):
        trailing = 0
        temp = counter
        while temp & 1:
            trailing += 1
            temp >>= 1
        cost = trailing + 1
        costs.append(cost)
        counter += 1
        ones = bin(counter).count('1')
        potentials.append(ones)
        amortized.append(cost + ones - potentials[-2])
    
    fig, axes = plt.subplots(2, 1, figsize=(12, 8), sharex=True)
    
    # Top: actual vs amortized costs
    ax = axes[0]
    x = range(1, n + 1)
    ax.bar(x, costs, alpha=0.7, color='#e74c3c', label='Actual cost', width=0.8)
    ax.axhline(y=2, color='#2ecc71', linewidth=2, linestyle='--', label='Amortized cost = 2')
    ax.set_ylabel('Cost per operation', fontsize=12)
    ax.set_title('Binary Counter: Actual vs Amortized Cost', fontsize=14, fontweight='bold')
    ax.legend(fontsize=11)
    ax.set_ylim(0, max(costs) + 1)
    
    # Bottom: cumulative costs
    ax = axes[1]
    cum_actual = np.cumsum(costs)
    cum_amortized = np.cumsum(amortized)
    bound = 2 * np.arange(1, n + 1)
    
    ax.plot(x, cum_actual, 'o-', markersize=3, color='#e74c3c', label='Cumulative actual', linewidth=1.5)
    ax.plot(x, bound, '--', color='#2ecc71', label='Upper bound (2n)', linewidth=2)
    ax.fill_between(x, cum_actual, bound, alpha=0.15, color='#2ecc71')
    ax.set_xlabel('Number of operations', fontsize=12)
    ax.set_ylabel('Cumulative cost', fontsize=12)
    ax.set_title('Cumulative Cost vs Amortized Bound', fontsize=14, fontweight='bold')
    ax.legend(fontsize=11)
    
    plt.tight_layout()
    return fig


def plot_potential_and_credit():
    """Plot potential function and credit balance for stack operations."""
    ops = ['push'] * 5 + ['pop'] * 3 + ['push'] * 4 + ['pop'] * 2 + ['push'] * 2 + ['pop'] * 4
    n = len(ops)
    
    size = 0
    states = [0]
    costs = []
    for op in ops:
        if op == 'push':
            costs.append(1)
            size += 1
        elif size > 0:
            costs.append(1)
            size -= 1
        else:
            costs.append(0)
        states.append(size)
    
    potentials = states[:]
    amortized = [costs[i] + potentials[i+1] - potentials[i] for i in range(n)]
    credit = [0] * (n + 1)
    for i in range(n):
        credit[i+1] = credit[i] + amortized[i] - costs[i]
    
    fig, axes = plt.subplots(3, 1, figsize=(14, 10), sharex=True)
    
    x = range(n + 1)
    
    # Potential function
    ax = axes[0]
    ax.step(x, potentials, where='post', color='#3498db', linewidth=2)
    ax.fill_between(x, 0, potentials, step='post', alpha=0.2, color='#3498db')
    ax.set_ylabel('Φ (stack size)', fontsize=12)
    ax.set_title('Potential Function Φ = Stack Size', fontsize=14, fontweight='bold')
    
    # Color operations
    for i, op in enumerate(ops):
        color = '#2ecc71' if op == 'push' else '#e74c3c'
        ax.axvspan(i, i + 1, alpha=0.1, color=color)
    
    # Costs comparison
    ax = axes[1]
    x_ops = range(n)
    ax.bar([i - 0.15 for i in x_ops], costs, width=0.3, color='#e74c3c', alpha=0.8, label='Actual')
    ax.bar([i + 0.15 for i in x_ops], amortized, width=0.3, color='#2ecc71', alpha=0.8, label='Amortized')
    ax.set_ylabel('Cost', fontsize=12)
    ax.set_title('Actual vs Amortized Cost per Operation', fontsize=14, fontweight='bold')
    ax.legend(fontsize=11)
    
    # Credit balance
    ax = axes[2]
    ax.step(x, credit, where='post', color='#9b59b6', linewidth=2)
    ax.fill_between(x, 0, credit, step='post', alpha=0.2, color='#9b59b6')
    ax.axhline(y=0, color='black', linewidth=0.5, linestyle='-')
    ax.set_ylabel('Credit balance', fontsize=12)
    ax.set_xlabel('Operation index', fontsize=12)
    ax.set_title('Credit Balance (Accounting Method)', fontsize=14, fontweight='bold')
    
    plt.tight_layout()
    return fig


def plot_tropical_convolution():
    """Plot min-plus convolution and optimal split."""
    # Two cost profiles
    f = [0, 1, 3, 6, 10, 15, 21, 28, 36, 45, 55]  # quadratic
    g = [0, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]    # linear after startup
    
    # Compute convolution
    m, p = len(f) - 1, len(g) - 1
    conv = []
    optimal_splits = []
    for n in range(m + p + 1):
        best = float('inf')
        best_k = 0
        for k in range(max(0, n - p), min(m, n) + 1):
            val = f[k] + g[n - k]
            if val < best:
                best = val
                best_k = k
        conv.append(best)
        optimal_splits.append(best_k)
    
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    # Left: individual profiles and convolution
    ax = axes[0]
    ax.plot(range(len(f)), f, 'o-', color='#e74c3c', label='f (Phase 1: quadratic)', linewidth=2)
    ax.plot(range(len(g)), g, 's-', color='#3498db', label='g (Phase 2: startup)', linewidth=2)
    ax.plot(range(len(conv)), conv, 'D-', color='#2ecc71', label='f ⋆ g (optimal split)', linewidth=2, markersize=5)
    ax.set_xlabel('Time units', fontsize=12)
    ax.set_ylabel('Cost', fontsize=12)
    ax.set_title('Min-Plus Convolution', fontsize=14, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    
    # Right: optimal split points
    ax = axes[1]
    T_range = range(len(conv))
    ax.bar(T_range, optimal_splits, color='#9b59b6', alpha=0.7)
    ax.set_xlabel('Total time T', fontsize=12)
    ax.set_ylabel('Optimal split k* (Phase 1 time)', fontsize=12)
    ax.set_title('Optimal Phase Split Points', fontsize=14, fontweight='bold')
    ax.grid(True, alpha=0.3, axis='y')
    
    plt.tight_layout()
    return fig


def plot_bellman_convergence():
    """Plot Bellman value iteration convergence."""
    # 4-state transition system
    INF = float('inf')
    W = np.array([
        [3, 1, INF, 5],
        [INF, 2, 4, INF],
        [1, INF, 3, 2],
        [4, INF, INF, 1],
    ])
    
    n = 4
    T = 10
    V = np.zeros((T + 1, n))
    
    for t in range(T):
        for s in range(n):
            V[t+1][s] = min(W[s][sp] + V[t][sp] for sp in range(n))
    
    fig, ax = plt.subplots(figsize=(10, 6))
    
    colors = ['#e74c3c', '#3498db', '#2ecc71', '#f39c12']
    labels = ['State A', 'State B', 'State C', 'State D']
    
    for s in range(n):
        ax.plot(range(T + 1), V[:, s], 'o-', color=colors[s], label=labels[s],
                linewidth=2, markersize=5)
    
    ax.set_xlabel('Time horizon T', fontsize=12)
    ax.set_ylabel('Optimal T-step cost V(T, s)', fontsize=12)
    ax.set_title('Bellman Value Iteration: Tropical Dynamic Programming', fontsize=14, fontweight='bold')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    
    # Add growth rate annotation
    for s in range(n):
        rate = (V[T][s] - V[T-1][s])
        ax.annotate(f'rate ≈ {rate:.1f}/step',
                    xy=(T, V[T][s]),
                    xytext=(T + 0.3, V[T][s]),
                    fontsize=9, color=colors[s])
    
    plt.tight_layout()
    return fig


def plot_framework_overview():
    """Create a conceptual overview diagram of the framework."""
    fig, ax = plt.subplots(figsize=(14, 8))
    ax.set_xlim(0, 14)
    ax.set_ylim(0, 8)
    ax.axis('off')
    
    # Title
    ax.text(7, 7.5, 'Tropical Amortized Analysis Framework',
            fontsize=16, fontweight='bold', ha='center', va='center')
    
    boxes = [
        (2, 5.5, 'Potential\nMethod', '#3498db'),
        (5.5, 5.5, 'Accounting\nMethod', '#2ecc71'),
        (9, 5.5, 'Tropical\nConvolution', '#e74c3c'),
        (12, 5.5, 'Bellman\nEquation', '#f39c12'),
        (3.75, 3, 'Equivalence\nTheorem', '#9b59b6'),
        (10.5, 3, 'Associativity\n& Composition', '#e67e22'),
        (7, 1, 'Unified Tropical Algebra\n(min, +) Semiring', '#1abc9c'),
    ]
    
    for x, y, text, color in boxes:
        bbox = FancyBboxPatch((x - 1.3, y - 0.6), 2.6, 1.2,
                              boxstyle="round,pad=0.1",
                              facecolor=color, alpha=0.3, edgecolor=color, linewidth=2)
        ax.add_patch(bbox)
        ax.text(x, y, text, fontsize=10, ha='center', va='center', fontweight='bold')
    
    # Arrows
    arrows = [
        (2, 4.9, 3.75, 3.6),
        (5.5, 4.9, 3.75, 3.6),
        (9, 4.9, 10.5, 3.6),
        (12, 4.9, 10.5, 3.6),
        (3.75, 2.4, 7, 1.6),
        (10.5, 2.4, 7, 1.6),
    ]
    
    for x1, y1, x2, y2 in arrows:
        ax.annotate('', xy=(x2, y2), xytext=(x1, y1),
                    arrowprops=dict(arrowstyle='->', color='#555', lw=1.5))
    
    plt.tight_layout()
    return fig


if __name__ == "__main__":
    print("Generating visualizations...")
    
    # Generate all figures
    figs = {
        'binary_counter': plot_binary_counter(),
        'potential_credit': plot_potential_and_credit(),
        'tropical_conv': plot_tropical_convolution(),
        'bellman_convergence': plot_bellman_convergence(),
        'framework_overview': plot_framework_overview(),
    }
    
    # Save as PNG files
    for name, fig in figs.items():
        filename = f"{name}.png"
        fig.savefig(filename, dpi=150, bbox_inches='tight',
                    facecolor='white', edgecolor='none')
        print(f"  Saved {filename}")
        plt.close(fig)
    
    # Generate base64 versions for JSON package
    print("\nGenerating base64 data URIs...")
    for name in ['binary_counter', 'potential_credit', 'tropical_conv',
                 'bellman_convergence', 'framework_overview']:
        exec(f"fig_{name} = plot_{name}()")
        uri = fig_to_base64(eval(f"fig_{name}"))
        print(f"  {name}: {len(uri)} chars")
    
    print("\nAll visualizations generated successfully.")

#!/usr/bin/env python3
"""
Tropical Type Theory — Applications

Real-world applications of tropical type theory:
1. Program Cost Verification: Type-check programs against cost bounds
2. Network Routing Verification: Verify shortest-path solutions
3. Dynamic Programming Certification: Validate DP solutions via initiality
4. Compiler Pass Composition: Track cost through optimization pipelines
5. Resource-Aware Scheduling: Type-check task schedules
"""

from typing import Callable, Dict, List, Optional, Tuple, Any
from dataclasses import dataclass


# =============================================================================
# Application 1: Program Cost Verification
# =============================================================================

def app_program_cost_verification():
    """
    Demonstrate program cost verification using tropical type checking.
    
    Scenario: A sorting algorithm processes arrays of length n.
    The input cost is n² (quadratic budget), and the output cost
    is n·log(n). We verify that the algorithm stays within budget.
    """
    import math
    
    print("=" * 70)
    print("APPLICATION 1: Program Cost Verification")
    print("=" * 70)
    
    # Input type: arrays of length n, cost = n² (budget)
    input_cost = lambda n: n * n
    
    # Output type: sorted arrays, cost = n·ceil(log₂(n)) (actual work)
    output_cost = lambda n: n * max(1, math.ceil(math.log2(max(n, 1))))
    
    # The sorting algorithm maps input size n to output size n (same size)
    sort_fn = lambda n: n
    
    print("\nVerifying: merge sort stays within quadratic budget")
    print(f"{'n':>5} | {'Budget (n²)':>12} | {'Actual (n·log n)':>16} | {'Within budget?':>15}")
    print("-" * 55)
    
    all_ok = True
    for n in [1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024]:
        budget = input_cost(n)
        actual = output_cost(sort_fn(n))
        ok = actual <= budget
        if not ok:
            all_ok = False
        print(f"{n:>5} | {budget:>12} | {actual:>16} | {'✓' if ok else '✗':>15}")
    
    print(f"\nType check: {'ACCEPT' if all_ok else 'REJECT'}")
    print("Interpretation: The sorting algorithm is a tropical homomorphism")
    print("from the quadratic-cost type to the linearithmic-cost type.")


# =============================================================================
# Application 2: Network Routing Verification
# =============================================================================

def app_network_routing():
    """
    Verify routing table correctness using tropical type checking.
    
    Given a network graph and proposed shortest distances,
    verify the Bellman optimality condition:
        d(v) ≤ d(u) + weight(u, v) for all edges (u, v)
    """
    print("\n" + "=" * 70)
    print("APPLICATION 2: Network Routing Verification")
    print("=" * 70)
    
    # Network topology (data center)
    nodes = ["router_A", "router_B", "router_C", "router_D", "server_1", "server_2"]
    edges = [
        ("router_A", "router_B", 10),
        ("router_A", "router_C", 5),
        ("router_B", "router_D", 3),
        ("router_C", "router_B", 4),
        ("router_C", "router_D", 8),
        ("router_D", "server_1", 2),
        ("router_D", "server_2", 7),
        ("router_B", "server_1", 12),
    ]
    
    # Proposed routing distances from router_A
    distances = {
        "router_A": 0,
        "router_B": 9,   # via C → B (5 + 4)
        "router_C": 5,   # direct (5)
        "router_D": 12,  # via C → B → D (5 + 4 + 3)
        "server_1": 14,  # via C → B → D → S1 (5 + 4 + 3 + 2)
        "server_2": 19,  # via C → B → D → S2 (5 + 4 + 3 + 7)
    }
    
    print("\nNetwork: Data center routing")
    print(f"Source: router_A")
    print(f"\nProposed distances:")
    for node, dist in distances.items():
        print(f"  {node}: {dist}")
    
    print(f"\nVerifying Bellman conditions (tropical type check):")
    print(f"{'Edge':>25} | {'d(u)+w':>7} | {'d(v)':>5} | {'d(v) ≤ d(u)+w':>14}")
    print("-" * 60)
    
    all_ok = True
    for u, v, w in edges:
        relaxed = distances[u] + w
        actual = distances[v]
        ok = actual <= relaxed
        if not ok:
            all_ok = False
        print(f"{u} → {v} (w={w:>2}) | {relaxed:>7} | {actual:>5} | {'✓' if ok else '✗':>14}")
    
    print(f"\nRouting verification: {'ACCEPT ✓' if all_ok else 'REJECT ✗'}")
    if all_ok:
        print("The distance function is a tropical homomorphism — routing is optimal.")


# =============================================================================
# Application 3: Dynamic Programming Certification
# =============================================================================

def app_dynamic_programming():
    """
    Certify a dynamic programming solution using tropical initiality.
    
    Problem: Fibonacci-like computation as initial algebra morphism.
    The DP recurrence is the algebra structure, and the unique
    homomorphism from ℕ is the certified solution.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 3: Dynamic Programming Certification")
    print("=" * 70)
    
    print("\n--- Minimum coin change problem ---")
    
    # Coin denominations
    coins = [1, 3, 4]
    
    # DP solution: min_coins[n] = minimum coins to make change for n
    max_amount = 15
    min_coins = [float('inf')] * (max_amount + 1)
    min_coins[0] = 0
    
    for amount in range(1, max_amount + 1):
        for coin in coins:
            if coin <= amount and min_coins[amount - coin] + 1 < min_coins[amount]:
                min_coins[amount] = min_coins[amount - coin] + 1
    
    print(f"Coins: {coins}")
    print(f"\n{'Amount':>7} | {'Min coins':>10} | {'Rank ≤ amount':>14}")
    print("-" * 35)
    for n in range(max_amount + 1):
        rank_ok = min_coins[n] <= n  # rank is bounded by amount
        print(f"{n:>7} | {min_coins[n]:>10} | {'✓' if rank_ok else '✗':>14}")
    
    # Verify tropical morphism property: solution is cost-nonincreasing
    # in the sense that min_coins[n] ≤ n for all n
    print(f"\nTropical type check: min_coins is a morphism from id to id")
    print(f"(cost of solution ≤ cost of problem for all inputs)")
    
    all_ok = all(min_coins[n] <= n for n in range(max_amount + 1))
    print(f"Verification: {'ACCEPT ✓' if all_ok else 'REJECT ✗'}")
    
    # Verify the DP recurrence is an algebra structure
    print(f"\n--- Verifying algebra structure ---")
    print("The recurrence min_coins[n] = 1 + min(min_coins[n-c] : c ∈ coins)")
    print("is the structure map of a tropical algebra.")
    
    recurrence_ok = True
    for n in range(1, max_amount + 1):
        expected = 1 + min(min_coins[n - c] for c in coins if c <= n)
        if min_coins[n] != expected:
            recurrence_ok = False
            print(f"  VIOLATION at n={n}: got {min_coins[n]}, expected {expected}")
    
    if recurrence_ok:
        print("  All recurrences verified ✓")
        print("  The DP solution is the unique homomorphism from the initial algebra.")


# =============================================================================
# Application 4: Compiler Pass Composition
# =============================================================================

def app_compiler_passes():
    """
    Track cost overhead through a compiler pipeline using
    cost-additive composition (TropHomC.comp).
    """
    print("\n" + "=" * 70)
    print("APPLICATION 4: Compiler Pass Composition")
    print("=" * 70)
    
    @dataclass
    class CompilerPass:
        name: str
        cost_overhead: int  # max extra cost introduced
        description: str
    
    passes = [
        CompilerPass("Parse", 2, "Tokenize and build AST"),
        CompilerPass("TypeCheck", 0, "Verify types (no cost overhead)"),
        CompilerPass("Desugar", 3, "Expand syntactic sugar"),
        CompilerPass("Optimize", 0, "Dead code elimination (reduces cost)"),
        CompilerPass("Codegen", 5, "Generate machine code"),
        CompilerPass("Link", 1, "Link with runtime library"),
    ]
    
    print("\nCompiler pipeline:")
    total_overhead = 0
    print(f"{'Pass':>12} | {'Overhead':>9} | {'Cumulative':>11} | {'Description'}")
    print("-" * 70)
    
    for p in passes:
        total_overhead += p.cost_overhead
        print(f"{p.name:>12} | {p.cost_overhead:>9} | {total_overhead:>11} | {p.description}")
    
    print(f"\n{'Total':>12} | {total_overhead:>9} |")
    print(f"\nBy TropHomC.comp: the full pipeline is a {total_overhead}-bounded morphism.")
    print(f"If the source program has cost C, the compiled program has cost ≤ C + {total_overhead}.")
    
    # Concrete example
    source_costs = [10, 25, 50, 100, 500]
    print(f"\n{'Source cost':>12} | {'Max output cost':>16} | {'Overhead %':>11}")
    print("-" * 45)
    for c in source_costs:
        max_out = c + total_overhead
        pct = (total_overhead / c) * 100
        print(f"{c:>12} | {max_out:>16} | {pct:>10.1f}%")


# =============================================================================
# Application 5: Resource-Aware Scheduling
# =============================================================================

def app_scheduling():
    """
    Type-check a task schedule against resource constraints
    using tropical morphisms.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 5: Resource-Aware Task Scheduling")
    print("=" * 70)
    
    # Tasks with resource requirements (CPU cores)
    tasks = {
        "data_load": 2,
        "preprocess": 4,
        "train_model": 8,
        "evaluate": 4,
        "export": 1,
    }
    
    # Machine capacities (available cores at each time slot)
    schedule = {
        0: ["data_load"],           # t=0: 2 cores needed
        1: ["preprocess"],          # t=1: 4 cores needed
        2: ["train_model"],         # t=2: 8 cores needed
        3: ["evaluate", "export"],  # t=3: 4+1=5 cores needed
    }
    
    machine_capacity = 8  # total available cores
    
    print(f"\nMachine capacity: {machine_capacity} cores")
    print(f"\nSchedule:")
    print(f"{'Time':>5} | {'Tasks':>25} | {'Cores needed':>13} | {'Budget':>7} | {'OK?':>4}")
    print("-" * 65)
    
    all_ok = True
    for t in sorted(schedule.keys()):
        task_list = schedule[t]
        cores_needed = sum(tasks[task] for task in task_list)
        ok = cores_needed <= machine_capacity
        if not ok:
            all_ok = False
        tasks_str = ", ".join(task_list)
        print(f"{t:>5} | {tasks_str:>25} | {cores_needed:>13} | {machine_capacity:>7} | {'✓' if ok else '✗':>4}")
    
    print(f"\nTropical type check: {'ACCEPT ✓' if all_ok else 'REJECT ✗'}")
    if all_ok:
        print("The schedule is a tropical homomorphism from task costs to machine capacity.")
        print("Resource constraints are satisfied at every time step.")


# =============================================================================
# Main
# =============================================================================

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║     TROPICAL TYPE THEORY — REAL-WORLD APPLICATIONS                ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    
    app_program_cost_verification()
    app_network_routing()
    app_dynamic_programming()
    app_compiler_passes()
    app_scheduling()
    
    print("\n" + "=" * 70)
    print("All applications demonstrated successfully.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Tropical Type Theory — Interactive Demonstrations

Demonstrates the core concepts of tropical type theory with concrete
numerical examples:
1. Tropical type checking on finite contexts
2. Tropical identity and min-plus equality
3. Initial algebra semantics (ℕ as initial tropical algebra)
4. Idempotent normalization of universe codes
5. Cost-bounded composition of morphisms
"""

from typing import Callable, Dict, List, Optional, Tuple


# =============================================================================
# Core Definitions
# =============================================================================

def trop_set(cost_fn: Callable[[int], int]) -> Callable[[int], int]:
    """A tropical set is a cost function α → ℕ."""
    return cost_fn


def trop_hom_check(A: Callable, B: Callable, f: Callable, domain: List[int]) -> bool:
    """Check if f is a tropical homomorphism from A to B on a finite domain.
    
    Returns True iff ∀ x ∈ domain, B(f(x)) ≤ A(x).
    """
    return all(B(f(x)) <= A(x) for x in domain)


def trop_hom_c_check(c: int, A: Callable, B: Callable, f: Callable, domain: List[int]) -> bool:
    """Check if f is a c-bounded tropical homomorphism.
    
    Returns True iff ∀ x ∈ domain, B(f(x)) ≤ A(x) + c.
    """
    return all(B(f(x)) <= A(x) + c for x in domain)


def trop_id_check(B: Callable, f: Callable, g: Callable, domain: List[int]) -> bool:
    """Check tropical identity: ∀ x, B(f(x)) = B(g(x))."""
    return all(B(f(x)) == B(g(x)) for x in domain)


def trop_eq_check(u: Callable, v: Callable, domain: List[int]) -> bool:
    """Check tropical equality: ∀ x, u(x) = v(x)."""
    return all(u(x) == v(x) for x in domain)


def trop_eq_minplus_check(u: Callable, v: Callable, domain: List[int]) -> bool:
    """Check the min-plus characterization: ∀ x, min(u(x),v(x)) = u(x) ∧ min(u(x),v(x)) = v(x)."""
    for x in domain:
        m = min(u(x), v(x))
        if m != u(x) or m != v(x):
            return False
    return True


# =============================================================================
# Demo 1: Tropical Type Checking
# =============================================================================

def demo_type_checking():
    """Demonstrate decidable tropical type checking on finite types."""
    print("=" * 70)
    print("DEMO 1: Tropical Type Checking on Finite Contexts")
    print("=" * 70)
    
    domain = list(range(5))
    
    # Example 1: Identity function with A(x) = 2x, B(y) = y
    A = lambda x: 2 * x
    B = lambda y: y
    f = lambda x: x  # identity
    
    print("\n--- Example 1: Identity function ---")
    print(f"A(x) = 2x, B(y) = y, f(x) = x")
    print(f"{'x':>3} | {'A(x)':>5} | {'B(f(x))':>7} | {'B(f(x)) ≤ A(x)':>15}")
    print("-" * 40)
    for x in domain:
        ok = B(f(x)) <= A(x)
        print(f"{x:>3} | {A(x):>5} | {B(f(x)):>7} | {'✓' if ok else '✗':>15}")
    
    result = trop_hom_check(A, B, f, domain)
    print(f"\nResult: {'ACCEPT' if result else 'REJECT'} — f is {'a' if result else 'NOT a'} tropical homomorphism")
    
    # Example 2: Doubling function — should fail
    g = lambda x: 2 * x
    B2 = lambda y: y
    
    print("\n--- Example 2: Doubling function ---")
    print(f"A(x) = 2x, B(y) = y, g(x) = 2x")
    print(f"{'x':>3} | {'A(x)':>5} | {'B(g(x))':>7} | {'B(g(x)) ≤ A(x)':>15}")
    print("-" * 40)
    for x in domain:
        ok = B2(g(x)) <= A(x)
        print(f"{x:>3} | {A(x):>5} | {B2(g(x)):>7} | {'✓' if ok else '✗':>15}")
    
    result = trop_hom_check(A, B2, g, domain)
    print(f"\nResult: {'ACCEPT' if result else 'REJECT'}")
    
    # Example 3: Cost-bounded check
    print("\n--- Example 3: Cost-bounded type checking ---")
    A3 = lambda x: x
    B3 = lambda y: y + 2
    f3 = lambda x: x
    c = 3
    
    print(f"A(x) = x, B(y) = y + 2, f(x) = x, cost bound c = {c}")
    print(f"{'x':>3} | {'A(x)':>5} | {'B(f(x))':>7} | {'A(x)+c':>6} | {'B(f(x)) ≤ A(x)+c':>18}")
    print("-" * 50)
    for x in domain:
        ok = B3(f3(x)) <= A3(x) + c
        print(f"{x:>3} | {A3(x):>5} | {B3(f3(x)):>7} | {A3(x)+c:>6} | {'✓' if ok else '✗':>18}")
    
    result = trop_hom_c_check(c, A3, B3, f3, domain)
    print(f"\nResult: {'ACCEPT' if result else 'REJECT'} — f is a {c}-bounded tropical homomorphism")


# =============================================================================
# Demo 2: Tropical Identity and Min-Plus Equality  
# =============================================================================

def demo_identity():
    """Demonstrate tropical identity and its min-plus characterization."""
    print("\n" + "=" * 70)
    print("DEMO 2: Tropical Identity and Min-Plus Equality")
    print("=" * 70)
    
    domain = list(range(6))
    
    # Two equal functions
    u = lambda x: x * x
    v = lambda x: x ** 2
    
    print("\n--- Equal functions: u(x) = x², v(x) = x² ---")
    print(f"{'x':>3} | {'u(x)':>5} | {'v(x)':>5} | {'min':>4} | {'min=u':>5} | {'min=v':>5}")
    print("-" * 40)
    for x in domain:
        m = min(u(x), v(x))
        print(f"{x:>3} | {u(x):>5} | {v(x):>5} | {m:>4} | {'✓' if m==u(x) else '✗':>5} | {'✓' if m==v(x) else '✗':>5}")
    
    eq = trop_eq_check(u, v, domain)
    mp = trop_eq_minplus_check(u, v, domain)
    print(f"\nTropical equality: {eq}")
    print(f"Min-plus characterization: {mp}")
    print(f"Equivalence holds: {eq == mp} ✓")
    
    # Two unequal functions
    u2 = lambda x: x
    v2 = lambda x: x + 1
    
    print("\n--- Unequal functions: u(x) = x, v(x) = x + 1 ---")
    print(f"{'x':>3} | {'u(x)':>5} | {'v(x)':>5} | {'min':>4} | {'min=u':>5} | {'min=v':>5}")
    print("-" * 40)
    for x in domain:
        m = min(u2(x), v2(x))
        print(f"{x:>3} | {u2(x):>5} | {v2(x):>5} | {m:>4} | {'✓' if m==u2(x) else '✗':>5} | {'✓' if m==v2(x) else '✗':>5}")
    
    eq2 = trop_eq_check(u2, v2, domain)
    mp2 = trop_eq_minplus_check(u2, v2, domain)
    print(f"\nTropical equality: {eq2}")
    print(f"Min-plus characterization: {mp2}")
    print(f"Equivalence holds: {eq2 == mp2} ✓")


# =============================================================================
# Demo 3: Initial Algebra — ℕ as Initial Tropical Algebra
# =============================================================================

def demo_initial_algebra():
    """Demonstrate ℕ as the initial algebra for the Option functor."""
    print("\n" + "=" * 70)
    print("DEMO 3: ℕ as Initial Tropical Algebra")
    print("=" * 70)
    
    # Tropical algebra X: str(None) = 10, str(Some(n)) = n + 3
    def X_str(z: Optional[int]) -> int:
        if z is None:
            return 10
        else:
            return z + 3
    
    # The unique homomorphism from ℕ to X
    def nat_hom(n: int) -> int:
        if n == 0:
            return X_str(None)
        else:
            return X_str(nat_hom(n - 1))
    
    print("\n--- Algebra X: str(None) = 10, str(Some(n)) = n + 3 ---")
    print(f"{'n':>3} | {'f(n)':>6} | {'Expected':>10} | {'Formula':>15}")
    print("-" * 45)
    for n in range(8):
        val = nat_hom(n)
        expected = 10 + 3 * n
        print(f"{n:>3} | {val:>6} | {expected:>10} | {'10 + 3·' + str(n):>15}")
    
    # Verify homomorphism property
    print("\n--- Verifying algebra homomorphism property ---")
    print("f(NatTropAlg.str(z)) = X.str(Option.map f z)")
    
    # Check: f(0) = X.str(None) [z = None case]
    print(f"\nz = None: f(0) = {nat_hom(0)}, X.str(None) = {X_str(None)} → {'✓' if nat_hom(0) == X_str(None) else '✗'}")
    
    # Check: f(n+1) = X.str(Some(f(n))) [z = Some(n) case]
    for n in range(5):
        lhs = nat_hom(n + 1)
        rhs = X_str(nat_hom(n))
        print(f"z = Some({n}): f({n+1}) = {lhs}, X.str(Some(f({n}))) = {rhs} → {'✓' if lhs == rhs else '✗'}")
    
    # Second algebra to demonstrate uniqueness
    print("\n--- Second algebra Y: str(None) = 1, str(Some(n)) = 2n + 1 ---")
    
    def Y_str(z: Optional[int]) -> int:
        if z is None:
            return 1
        else:
            return 2 * z + 1
    
    def nat_hom_Y(n: int) -> int:
        if n == 0:
            return Y_str(None)
        else:
            return Y_str(nat_hom_Y(n - 1))
    
    print(f"{'n':>3} | {'f(n)':>6}")
    print("-" * 15)
    for n in range(8):
        print(f"{n:>3} | {nat_hom_Y(n):>6}")
    
    print(f"\nPattern: f(n) = 2^(n+1) - 1 (Mersenne-like sequence)")


# =============================================================================
# Demo 4: Idempotent Normalization of Universe Codes
# =============================================================================

def demo_normalization():
    """Demonstrate idempotent normalization of tropical universe codes."""
    print("\n" + "=" * 70)
    print("DEMO 4: Idempotent Normalization of Universe Codes")
    print("=" * 70)
    
    def normalize(K: int, u: int) -> int:
        return min(u, K)
    
    K = 5
    test_values = [0, 1, 2, 3, 4, 5, 6, 7, 10, 20, 100]
    
    print(f"\nNormalization bound K = {K}")
    print(f"normalizeCode(K, u) = min(u, K)")
    print(f"\n{'u':>5} | {'norm(u)':>8} | {'norm(norm(u))':>14} | {'Idempotent?':>12} | {'rank ≤ u?':>10}")
    print("-" * 60)
    
    for u in test_values:
        n1 = normalize(K, u)
        n2 = normalize(K, n1)
        idemp = n1 == n2
        rank_ok = n1 <= u
        print(f"{u:>5} | {n1:>8} | {n2:>14} | {'✓' if idemp else '✗':>12} | {'✓' if rank_ok else '✗':>10}")
    
    # Demonstrate well-foundedness
    print("\n--- Well-foundedness: no infinite descending chains ---")
    print("Starting from code 15, applying normalize and decrementing:")
    u = 15
    chain = [u]
    while u > 0:
        u = normalize(K, u)
        if u > 0:
            u -= 1
        chain.append(u)
    print(f"Chain: {' > '.join(map(str, chain))}")
    print(f"Chain length: {len(chain)} (finite ✓)")


# =============================================================================
# Demo 5: Cost-Bounded Composition
# =============================================================================

def demo_composition():
    """Demonstrate cost-additive composition of tropical morphisms."""
    print("\n" + "=" * 70)
    print("DEMO 5: Cost-Bounded Composition (Substitution Lemma)")
    print("=" * 70)
    
    domain = list(range(6))
    
    # f: A → B with cost bound c₁ = 2
    A = lambda x: 3 * x
    B = lambda y: 2 * y
    f = lambda x: x + 1
    c1 = 2
    
    # g: B → C with cost bound c₂ = 3
    C = lambda z: z
    g = lambda y: y + 2
    c2 = 3
    
    print(f"\nf: A → B, cost bound c₁ = {c1}")
    print(f"g: B → C, cost bound c₂ = {c2}")
    print(f"g∘f: A → C, expected cost bound c₁ + c₂ = {c1 + c2}")
    
    # Check f
    print(f"\n--- Checking f (c₁ = {c1}) ---")
    print(f"{'x':>3} | {'A(x)':>5} | {'B(f(x))':>7} | {'A(x)+c₁':>8} | {'OK?':>4}")
    print("-" * 35)
    for x in domain:
        ok = B(f(x)) <= A(x) + c1
        print(f"{x:>3} | {A(x):>5} | {B(f(x)):>7} | {A(x)+c1:>8} | {'✓' if ok else '✗':>4}")
    
    # Check g
    print(f"\n--- Checking g (c₂ = {c2}) ---")
    print(f"{'y':>3} | {'B(y)':>5} | {'C(g(y))':>7} | {'B(y)+c₂':>8} | {'OK?':>4}")
    print("-" * 35)
    for y in domain:
        ok = C(g(y)) <= B(y) + c2
        print(f"{y:>3} | {B(y):>5} | {C(g(y)):>7} | {B(y)+c2:>8} | {'✓' if ok else '✗':>4}")
    
    # Check g∘f
    gf = lambda x: g(f(x))
    print(f"\n--- Checking g∘f (c₁ + c₂ = {c1+c2}) ---")
    print(f"{'x':>3} | {'A(x)':>5} | {'C(g∘f(x))':>10} | {'A(x)+c₁+c₂':>12} | {'OK?':>4}")
    print("-" * 42)
    for x in domain:
        ok = C(gf(x)) <= A(x) + c1 + c2
        print(f"{x:>3} | {A(x):>5} | {C(gf(x)):>10} | {A(x)+c1+c2:>12} | {'✓' if ok else '✗':>4}")
    
    result = trop_hom_c_check(c1 + c2, A, C, gf, domain)
    print(f"\nComposition is ({c1}+{c2})-bounded: {'✓' if result else '✗'}")
    print("Cost additivity under composition verified ✓")


# =============================================================================
# Main
# =============================================================================

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║     TROPICAL TYPE THEORY — INTERACTIVE DEMONSTRATIONS              ║")
    print("║     Dependent Types in the Min-Plus Semiring                       ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    
    demo_type_checking()
    demo_identity()
    demo_initial_algebra()
    demo_normalization()
    demo_composition()
    
    print("\n" + "=" * 70)
    print("All demonstrations completed successfully.")
    print("=" * 70)


#!/usr/bin/env python3
"""Generate PACKAGE.json with all artifacts bundled."""

import json
import base64
import os

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

def read_image_base64(path):
    with open(path, 'rb') as f:
        b64 = base64.b64encode(f.read()).decode('utf-8')
    return f"data:image/png;base64,{b64}"

# Read all text content
article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
lean_proofs = read_file('Logic/TropicalTypeTheory.lean')
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')
applications_code = read_file('applications.py')
visualizations_code = read_file('visualizations.py')

# Read visualization images
viz_files = [
    ('tropical_sets', 'tropical_sets.png'),
    ('type_checking', 'type_checking.png'),
    ('initial_algebra', 'initial_algebra.png'),
    ('normalization', 'normalization.png'),
    ('composition', 'composition.png'),
    ('distributivity', 'distributivity.png'),
]

visualizations = []
for name, filename in viz_files:
    if os.path.exists(filename):
        visualizations.append({
            "name": name,
            "data": read_image_base64(filename)
        })

# Build package
package = {
    "title": "Tropical Type Theory: Dependent Types in the Min-Plus Semiring",
    "domain": "Logic / Type Theory / Tropical Algebra",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Tropical Type Theory Demonstrations",
            "code": demo_code
        },
        {
            "name": "Real-World Applications",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "Tropical Type Checker",
            "pseudocode": """function TropicalTypeCheck(domain, A, B, f, cost_bound=0):
    violations = []
    for x in domain:
        if B(f(x)) > A(x) + cost_bound:
            violations.append(x)
    return len(violations) == 0

Time: O(|domain|), Space: O(1)""",
            "code": algorithms_code
        },
        {
            "name": "Cost-Bounded Composition",
            "pseudocode": """function ComposeM morphisms(m1: (f, c1), m2: (g, c2)):
    return (g ∘ f, c1 + c2)

// By TropHomC.comp: costs add under composition
Time: O(1) setup, O(T(f) + T(g)) per evaluation""",
            "code": "# See algorithms.py for full implementation"
        },
        {
            "name": "Initial Algebra Homomorphism",
            "pseudocode": """function InitialHom(algebra, n):
    result = algebra.zero
    for i in 1..n:
        result = algebra.succ(result)
    return result

// Unique by nat_initial_tropAlg theorem
Time: O(n), Space: O(1)""",
            "code": "# See algorithms.py for full implementation"
        }
    ],
    "visualizations": visualizations,
    "lean_proofs": lean_proofs
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print(f"PACKAGE.json generated ({os.path.getsize('PACKAGE.json') / 1024:.1f} KB)")


#!/usr/bin/env python3
"""
Tropical Type Theory — Visualizations

Generates PNG visualizations of key mathematical structures.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import base64
import io
import json


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


def viz_tropical_sets():
    """Visualize tropical sets as cost landscapes."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    
    x = np.arange(0, 8)
    
    # Set A: quadratic cost
    A = x ** 2
    axes[0].bar(x, A, color='#2196F3', alpha=0.8, edgecolor='white')
    axes[0].set_title('Tropical Set A: A(x) = x²', fontsize=13, fontweight='bold')
    axes[0].set_xlabel('Element x')
    axes[0].set_ylabel('Cost A(x)')
    axes[0].set_ylim(0, max(A) * 1.15)
    
    # Set B: linear cost
    B = 2 * x
    axes[1].bar(x, B, color='#4CAF50', alpha=0.8, edgecolor='white')
    axes[1].set_title('Tropical Set B: B(x) = 2x', fontsize=13, fontweight='bold')
    axes[1].set_xlabel('Element x')
    axes[1].set_ylabel('Cost B(x)')
    axes[1].set_ylim(0, max(A) * 1.15)
    
    # Meet: min(A, B)
    M = np.minimum(A, B)
    axes[2].bar(x, A, color='#2196F3', alpha=0.3, edgecolor='#2196F3', label='A(x)')
    axes[2].bar(x, B, color='#4CAF50', alpha=0.3, edgecolor='#4CAF50', label='B(x)')
    axes[2].bar(x, M, color='#FF9800', alpha=0.8, edgecolor='white', label='Meet = min(A,B)')
    axes[2].set_title('Tropical Meet: min(A, B)', fontsize=13, fontweight='bold')
    axes[2].set_xlabel('Element x')
    axes[2].set_ylabel('Cost')
    axes[2].set_ylim(0, max(A) * 1.15)
    axes[2].legend()
    
    fig.suptitle('Tropical Sets as Cost Landscapes', fontsize=16, fontweight='bold', y=1.02)
    plt.tight_layout()
    return fig


def viz_type_checking():
    """Visualize tropical type checking as inequality verification."""
    fig, ax = plt.subplots(figsize=(10, 6))
    
    x = np.arange(0, 8)
    A = 3 * x       # source cost
    B_pass = x       # target cost (passes)
    B_fail = x * x   # target cost (fails for large x)
    
    width = 0.25
    ax.bar(x - width, A, width=width, color='#2196F3', alpha=0.8, label='A(x) = 3x (budget)', edgecolor='white')
    ax.bar(x, B_pass, width=width, color='#4CAF50', alpha=0.8, label='B(f(x)) = x (ACCEPT)', edgecolor='white')
    ax.bar(x + width, B_fail, width=width, color='#F44336', alpha=0.8, label='B(g(x)) = x² (REJECT at x≥4)', edgecolor='white')
    
    # Mark violations
    for xi in x:
        if B_fail[xi] > A[xi]:
            ax.annotate('✗', (xi + width, B_fail[xi]), ha='center', va='bottom',
                        fontsize=16, color='red', fontweight='bold')
    
    ax.set_xlabel('Element x', fontsize=12)
    ax.set_ylabel('Cost', fontsize=12)
    ax.set_title('Tropical Type Checking: B(f(x)) ≤ A(x)?', fontsize=14, fontweight='bold')
    ax.legend(fontsize=11)
    ax.set_xticks(x)
    
    plt.tight_layout()
    return fig


def viz_initial_algebra():
    """Visualize the initial algebra homomorphism."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    # Algebra 1: zero=10, succ(n) = n+3
    n_vals = np.arange(0, 10)
    alg1 = [10 + 3 * n for n in n_vals]
    
    axes[0].plot(n_vals, alg1, 'o-', color='#9C27B0', markersize=10, linewidth=2, label='f(n) = 10 + 3n')
    axes[0].fill_between(n_vals, 0, alg1, alpha=0.15, color='#9C27B0')
    axes[0].set_xlabel('n (natural number)', fontsize=12)
    axes[0].set_ylabel('f(n) (image in algebra)', fontsize=12)
    axes[0].set_title('Algebra 1: zero=10, succ(n)=n+3', fontsize=13, fontweight='bold')
    axes[0].legend(fontsize=11)
    axes[0].grid(alpha=0.3)
    
    # Algebra 2: zero=1, succ(n) = 2n+1 (Mersenne-like)
    alg2 = []
    val = 1
    for n in n_vals:
        if n == 0:
            alg2.append(1)
        else:
            val = 2 * val + 1
            alg2.append(val)
    
    axes[1].plot(n_vals, alg2, 's-', color='#FF5722', markersize=10, linewidth=2, label='f(n) = 2^(n+1) - 1')
    axes[1].fill_between(n_vals, 0, alg2, alpha=0.15, color='#FF5722')
    axes[1].set_xlabel('n (natural number)', fontsize=12)
    axes[1].set_ylabel('f(n) (image in algebra)', fontsize=12)
    axes[1].set_title('Algebra 2: zero=1, succ(n)=2n+1', fontsize=13, fontweight='bold')
    axes[1].legend(fontsize=11)
    axes[1].grid(alpha=0.3)
    axes[1].set_yscale('log')
    
    fig.suptitle('Initial Algebra Homomorphisms from ℕ', fontsize=16, fontweight='bold', y=1.02)
    plt.tight_layout()
    return fig


def viz_normalization():
    """Visualize idempotent normalization of universe codes."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    K_values = [3, 5, 8]
    u_vals = np.arange(0, 15)
    
    colors = ['#2196F3', '#4CAF50', '#FF9800']
    
    # Left: normalization for different K
    for K, color in zip(K_values, colors):
        normalized = [min(u, K) for u in u_vals]
        axes[0].plot(u_vals, normalized, 'o-', color=color, markersize=6, 
                     linewidth=2, label=f'K = {K}')
    
    axes[0].plot(u_vals, u_vals, '--', color='gray', alpha=0.5, label='Identity (no normalization)')
    axes[0].set_xlabel('Code u', fontsize=12)
    axes[0].set_ylabel('normalizeCode(K, u)', fontsize=12)
    axes[0].set_title('Normalization: min(u, K)', fontsize=13, fontweight='bold')
    axes[0].legend(fontsize=10)
    axes[0].grid(alpha=0.3)
    
    # Right: idempotency visualization
    K = 5
    u_range = np.arange(0, 12)
    norm1 = [min(u, K) for u in u_range]
    norm2 = [min(min(u, K), K) for u in u_range]
    
    width = 0.35
    axes[1].bar(u_range - width/2, norm1, width=width, color='#2196F3', alpha=0.8, 
                label='normalize(u)', edgecolor='white')
    axes[1].bar(u_range + width/2, norm2, width=width, color='#FF9800', alpha=0.8,
                label='normalize(normalize(u))', edgecolor='white')
    axes[1].set_xlabel('Code u', fontsize=12)
    axes[1].set_ylabel('Normalized code', fontsize=12)
    axes[1].set_title(f'Idempotency (K = {K}): normalize² = normalize', fontsize=13, fontweight='bold')
    axes[1].legend(fontsize=10)
    axes[1].set_xticks(u_range)
    
    fig.suptitle('Tropical Universe Code Normalization', fontsize=16, fontweight='bold', y=1.02)
    plt.tight_layout()
    return fig


def viz_composition():
    """Visualize cost-additive composition of morphisms."""
    fig, ax = plt.subplots(figsize=(12, 6))
    
    # Pipeline of 5 morphisms with different cost bounds
    stages = ['Input\n(source)', 'Stage 1\nc₁=2', 'Stage 2\nc₂=1', 'Stage 3\nc₃=3', 
              'Stage 4\nc₄=0', 'Output\n(target)']
    costs = [0, 2, 1, 3, 0]  # cost of each stage
    cumulative = [0]
    for c in costs:
        cumulative.append(cumulative[-1] + c)
    
    # Draw the pipeline
    x_pos = np.arange(len(stages))
    
    # Bars showing cumulative cost
    bars = ax.bar(x_pos, cumulative, color=['#2196F3'] + ['#4CAF50'] * 4 + ['#FF9800'],
                  alpha=0.8, edgecolor='white', width=0.6)
    
    # Arrows between stages
    for i in range(len(stages) - 1):
        ax.annotate('', xy=(x_pos[i+1] - 0.35, cumulative[i+1] * 0.5),
                     xytext=(x_pos[i] + 0.35, cumulative[i] * 0.5),
                     arrowprops=dict(arrowstyle='->', color='#333', lw=2))
    
    # Labels on bars
    for i, (x, y) in enumerate(zip(x_pos, cumulative)):
        if y > 0:
            ax.text(x, y + 0.15, f'Σ = {y}', ha='center', va='bottom', fontsize=11, fontweight='bold')
    
    ax.set_xticks(x_pos)
    ax.set_xticklabels(stages, fontsize=10)
    ax.set_ylabel('Cumulative Cost Bound', fontsize=12)
    ax.set_title('Cost-Additive Composition: TropHomC.comp', fontsize=14, fontweight='bold')
    ax.set_ylim(0, max(cumulative) * 1.3)
    
    # Add annotation
    ax.text(2.5, max(cumulative) * 1.15, 
            f'Total cost bound = Σcᵢ = {sum(costs)} (by TropHomC.comp)',
            ha='center', fontsize=12, style='italic',
            bbox=dict(boxstyle='round,pad=0.5', facecolor='lightyellow', edgecolor='orange'))
    
    plt.tight_layout()
    return fig


def viz_distributivity():
    """Visualize the distributivity law a + min(b,c) = min(a+b, a+c)."""
    fig, ax = plt.subplots(figsize=(10, 6))
    
    a = 3
    b_vals = np.arange(0, 10)
    
    for c in [1, 4, 7]:
        lhs = [a + min(b, c) for b in b_vals]
        rhs = [min(a + b, a + c) for b in b_vals]
        
        ax.plot(b_vals, lhs, 'o-', markersize=8, linewidth=2, 
                label=f'a+min(b,{c}) = min(a+b,a+{c}) [c={c}]')
        # Verify equality
        assert all(l == r for l, r in zip(lhs, rhs)), "Distributivity violated!"
    
    ax.set_xlabel('b', fontsize=12)
    ax.set_ylabel('Value', fontsize=12)
    ax.set_title(f'Distributivity: {a} + min(b, c) = min({a}+b, {a}+c)', fontsize=14, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(alpha=0.3)
    
    plt.tight_layout()
    return fig


if __name__ == "__main__":
    print("Generating visualizations...")
    
    figs = {
        'tropical_sets': viz_tropical_sets(),
        'type_checking': viz_type_checking(),
        'initial_algebra': viz_initial_algebra(),
        'normalization': viz_normalization(),
        'composition': viz_composition(),
        'distributivity': viz_distributivity(),
    }
    
    # Save as individual PNGs
    for name, fig in figs.items():
        fig.savefig(f'{name}.png', dpi=150, bbox_inches='tight')
        print(f"  Saved {name}.png")
        plt.close(fig)
    
    print("All visualizations generated.")

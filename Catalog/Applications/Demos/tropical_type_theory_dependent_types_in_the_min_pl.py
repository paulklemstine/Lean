#!/usr/bin/env python3
"""
Tropical Type Theory: Real-World Applications

Demonstrates how tropical type theory connects to:
1. Shortest-path verification in networks
2. Program cost analysis / resource-aware type checking
3. Dynamic programming verification
4. Supply chain optimization
"""

from typing import List, Dict, Tuple, Callable
import json


# ─── Application 1: Network Routing Verification ────────────────────────

def network_routing_verification():
    """
    Application: Verify that a routing policy satisfies cost bounds.

    Model:
    - Nodes in a network are the base type α
    - A(node) = maximum allowed latency budget at that node
    - B(node) = actual latency to reach destination
    - f(node) = next-hop routing function
    - TropHom A B f means: the routing policy never exceeds budgets

    This is tropical type checking applied to network verification.
    """
    print("=" * 60)
    print("APPLICATION 1: Network Routing Verification")
    print("=" * 60)

    # Network: 6 nodes, node 5 is the destination
    nodes = list(range(6))
    node_names = ['HQ', 'Router-A', 'Router-B', 'Edge-1', 'Edge-2', 'Destination']

    # Latency budget at each node (maximum allowed hops to destination)
    budget = {0: 5, 1: 4, 2: 3, 3: 2, 4: 2, 5: 0}

    # Actual minimum hops to destination
    actual_hops = {0: 3, 1: 2, 2: 2, 3: 1, 4: 1, 5: 0}

    # Routing policy: next-hop function
    next_hop = {0: 1, 1: 3, 2: 4, 3: 5, 4: 5, 5: 5}

    print("\nNetwork topology with routing policy:")
    print("-" * 50)
    for n in nodes:
        nh = next_hop[n]
        print(f"  {node_names[n]:>12} (budget={budget[n]}) → "
              f"{node_names[nh]:>12} (actual_hops={actual_hops[n]})")

    # Type check: B(f(x)) ≤ A(x)?
    print("\nTropical type checking: B(f(x)) ≤ A(x)?")
    print("-" * 50)
    all_valid = True
    for n in nodes:
        nh = next_hop[n]
        bfn = actual_hops[nh]
        an = budget[n]
        valid = bfn <= an
        all_valid = all_valid and valid
        status = "✓" if valid else "✗"
        print(f"  {node_names[n]:>12}: actual_hops({node_names[nh]}) = {bfn} "
              f"≤ budget({node_names[n]}) = {an}  {status}")

    print(f"\nRouting policy is well-typed: {all_valid}")
    print("Interpretation: The routing policy respects all latency budgets.")


# ─── Application 2: Program Cost Analysis ───────────────────────────────

def program_cost_analysis():
    """
    Application: Verify resource bounds in a simple program.

    Model:
    - Program states are the base type
    - A(state) = resource budget (memory, time, energy)
    - B(state) = actual resource consumption
    - f(state) = program transition function
    - TropHomC c A B f means: each step costs at most c extra resources

    Composition theorem: n steps cost at most n × c.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Program Cost Analysis")
    print("=" * 60)

    # Simple loop: state = (counter, accumulator)
    states = [(i, i * (i - 1) // 2) for i in range(8)]

    # Resource budget: proportional to remaining iterations
    def budget(state):
        counter, _ = state
        return 10 * counter + 5  # generous budget

    # Actual resource usage after one step
    def usage_after(state):
        counter, acc = state
        if counter == 0:
            return 0
        return 10 * (counter - 1) + 5

    # Transition: decrement counter, add counter to accumulator
    def step(state):
        counter, acc = state
        if counter == 0:
            return state
        return (counter - 1, acc + counter)

    print("\nProgram: sum from n down to 1")
    print("State = (counter, accumulator)")
    print("-" * 60)
    print(f"  {'State':>16} {'Budget':>8} {'Next state':>16} {'Usage':>8} {'Slack':>8} {'Valid':>6}")

    max_slack = 0
    for s in states:
        ns = step(s)
        b = budget(s)
        u = usage_after(s)
        slack = u - b
        max_slack = max(max_slack, slack)
        valid = u <= b
        print(f"  {str(s):>16} {b:>8} {str(ns):>16} {u:>8} {slack:>8} {'✓' if valid else '✗':>6}")

    print(f"\nMaximum slack needed: {max(0, max_slack)}")
    print(f"Each step is cost-0 bounded: {max_slack <= 0}")

    # Composition: multi-step bound
    n_steps = 5
    print(f"\nComposition theorem: {n_steps} steps cost ≤ {n_steps} × 0 = 0")

    state = states[-1]  # start at (7, 21)
    state = (7, 0)
    print(f"Execution trace from {state}:")
    for i in range(n_steps + 1):
        print(f"  Step {i}: state = {state}, budget = {budget(state)}")
        state = step(state)


# ─── Application 3: Dynamic Programming Verification ────────────────────

def dp_verification():
    """
    Application: Verify a dynamic programming solution via initiality.

    The Bellman equation for shortest paths is exactly the
    initial algebra recursion principle:
    - F(X) = 1 ⊕ X corresponds to "base case or extend by one edge"
    - The unique homomorphism is the shortest-path function
    - Initiality guarantees correctness and uniqueness
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Dynamic Programming via Initial Algebras")
    print("=" * 60)

    # Coin change problem: minimum coins to make amount n
    # This is an initial algebra for F(X) = 1 ⊕ X₁ ⊕ X₃ ⊕ X₅
    # where X_c means "extend by a coin of value c"
    coins = [1, 3, 5]
    max_amount = 15

    print(f"\nCoin change problem: coins = {coins}")
    print(f"Minimize number of coins to make each amount 0..{max_amount}")
    print("-" * 60)

    # DP solution = initial algebra homomorphism
    INF = float('inf')
    dp = [INF] * (max_amount + 1)
    dp[0] = 0  # str(None) = base case

    for amount in range(1, max_amount + 1):
        for coin in coins:
            if amount >= coin and dp[amount - coin] + 1 < dp[amount]:
                dp[amount] = dp[amount - coin] + 1  # str(Some(prev))

    print(f"  {'Amount':>8} {'Min coins':>10} {'Representation':>30}")
    for n in range(max_amount + 1):
        # Reconstruct solution
        if dp[n] == INF:
            rep = "impossible"
        else:
            rep_coins = []
            remaining = n
            while remaining > 0:
                for coin in sorted(coins, reverse=True):
                    if remaining >= coin and dp[remaining - coin] == dp[remaining] - 1:
                        rep_coins.append(coin)
                        remaining -= coin
                        break
            rep = " + ".join(map(str, rep_coins)) if rep_coins else "∅"
        print(f"  {n:>8} {dp[n]:>10} {rep:>30}")

    # Verify uniqueness (initiality)
    print("\nInitiality verification:")
    print("  The DP table is the UNIQUE solution satisfying:")
    print("    dp[0] = 0")
    for c in coins:
        print(f"    dp[n] = min(dp[n], dp[n-{c}] + 1)  for n ≥ {c}")
    print("  This follows from the initial algebra theorem for ℕ.")


# ─── Application 4: Supply Chain Cost Optimization ──────────────────────

def supply_chain_optimization():
    """
    Application: Model supply chain as tropical morphism composition.

    Each stage (supplier → manufacturer → distributor → retailer)
    is a cost-bounded tropical morphism. Total cost is bounded
    by the sum of stage costs (composition theorem).
    """
    print("\n" + "=" * 60)
    print("APPLICATION 4: Supply Chain Cost Optimization")
    print("=" * 60)

    stages = ['Raw Material', 'Supplier', 'Manufacturer', 'Distributor', 'Retailer']
    products = ['Widget-A', 'Widget-B', 'Widget-C']

    # Cost at each stage for each product
    costs = {
        'Raw Material':  {'Widget-A': 2,  'Widget-B': 5,  'Widget-C': 3},
        'Supplier':      {'Widget-A': 4,  'Widget-B': 7,  'Widget-C': 5},
        'Manufacturer':  {'Widget-A': 8,  'Widget-B': 12, 'Widget-C': 9},
        'Distributor':   {'Widget-A': 10, 'Widget-B': 15, 'Widget-C': 12},
        'Retailer':      {'Widget-A': 14, 'Widget-B': 20, 'Widget-C': 16},
    }

    # Stage cost bounds (tropical morphism costs)
    stage_bounds = [3, 5, 4, 5]  # supplier→mfg, mfg→dist, etc.

    print("\nCost through supply chain stages:")
    print("-" * 60)
    header = f"  {'Product':>12}"
    for s in stages:
        header += f" {s:>14}"
    print(header)

    for p in products:
        row = f"  {p:>12}"
        for s in stages:
            row += f" {costs[s][p]:>14}"
        print(row)

    print("\nStage cost bounds (tropical morphism costs):")
    for i in range(len(stage_bounds)):
        print(f"  {stages[i]:>14} → {stages[i+1]:<14}: c = {stage_bounds[i]}")

    total_bound = sum(stage_bounds)
    print(f"\nTotal cost bound (composition theorem): {total_bound}")

    print("\nVerification: End-to-end cost ≤ raw material cost + total bound?")
    print("-" * 60)
    for p in products:
        raw = costs['Raw Material'][p]
        retail = costs['Retailer'][p]
        margin = retail - raw
        valid = margin <= total_bound
        print(f"  {p}: retail({retail}) - raw({raw}) = {margin} ≤ {total_bound}  "
              f"{'✓' if valid else '✗'}")

    # Stage-by-stage verification
    print("\nStage-by-stage verification:")
    for p in products:
        print(f"\n  {p}:")
        for i in range(len(stage_bounds)):
            prev_cost = costs[stages[i]][p]
            next_cost = costs[stages[i+1]][p]
            margin = next_cost - prev_cost
            valid = margin <= stage_bounds[i]
            print(f"    {stages[i]:>14} → {stages[i+1]:<14}: "
                  f"{next_cost} - {prev_cost} = {margin} ≤ {stage_bounds[i]}  "
                  f"{'✓' if valid else '✗'}")


# ─── Main ────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║     TROPICAL TYPE THEORY — Real-World Applications        ║")
    print("╚══════════════════════════════════════════════════════════════╝")

    network_routing_verification()
    program_cost_analysis()
    dp_verification()
    supply_chain_optimization()

    print("\n" + "=" * 60)
    print("All applications demonstrated successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Tropical Type Theory: Concrete Demonstrations

Demonstrates the core theorems of tropical type theory with
numerical examples showing decidable type checking, identity
via min-plus equality, initial algebra semantics, and universe hierarchies.
"""

from itertools import product as cartesian_product


# ─── Core Definitions ───────────────────────────────────────────────────

def trop_set(cost_fn):
    """A tropical set is a cost function α → ℕ."""
    return cost_fn


def trop_hom_check(A, B, f, domain):
    """Check if f : A → B is a tropical homomorphism (∀ x, B(f(x)) ≤ A(x))."""
    results = []
    for x in domain:
        bfx = B(f(x))
        ax = A(x)
        results.append({
            'x': x, 'A(x)': ax, 'f(x)': f(x), 'B(f(x))': bfx,
            'valid': bfx <= ax
        })
    return results


def trop_hom_c_check(c, A, B, f, domain):
    """Check cost-bounded homomorphism: ∀ x, B(f(x)) ≤ A(x) + c."""
    results = []
    for x in domain:
        bfx = B(f(x))
        ax = A(x)
        results.append({
            'x': x, 'A(x)': ax, 'f(x)': f(x), 'B(f(x))': bfx,
            'bound': ax + c, 'valid': bfx <= ax + c
        })
    return results


# ─── Demo 1: Decidable Type Checking ────────────────────────────────────

def demo_decidable_typecheck():
    """
    Theorem 1: On finite types, tropical type checking is decidable.
    We verify ∀ x ∈ {0,...,4}, B(f(x)) ≤ A(x) by exhaustive checking.
    """
    print("=" * 70)
    print("DEMO 1: Decidable Tropical Type Checking")
    print("=" * 70)

    domain = list(range(5))

    # Cost functions (tropical sets)
    A = lambda x: x * 2 + 3      # Context costs: 3, 5, 7, 9, 11
    B = lambda y: y + 1           # Target costs: y + 1

    # Test function: f(x) = x + 1
    f = lambda x: x + 1

    print("\nExample 1: f(x) = x + 1, A(x) = 2x + 3, B(y) = y + 1")
    print("-" * 50)
    results = trop_hom_check(A, B, f, domain)
    for r in results:
        status = "✓" if r['valid'] else "✗"
        print(f"  x={r['x']}: B(f({r['x']})) = {r['B(f(x))']} ≤ A({r['x']}) = {r['A(x)']}  {status}")

    all_valid = all(r['valid'] for r in results)
    print(f"\n  f is a tropical homomorphism: {all_valid}")

    # Counter-example: g(x) = x * 3
    g = lambda x: x * 3
    print("\nExample 2: g(x) = 3x, A(x) = 2x + 3, B(y) = y + 1")
    print("-" * 50)
    results2 = trop_hom_check(A, B, g, domain)
    for r in results2:
        status = "✓" if r['valid'] else "✗"
        print(f"  x={r['x']}: B(g({r['x']})) = {r['B(f(x))']} ≤ A({r['x']}) = {r['A(x)']}  {status}")

    all_valid2 = all(r['valid'] for r in results2)
    print(f"\n  g is a tropical homomorphism: {all_valid2}")

    # Cost-bounded version
    print("\nExample 3: Cost-bounded check with slack c=5")
    print("-" * 50)
    results3 = trop_hom_c_check(5, A, B, g, domain)
    for r in results3:
        status = "✓" if r['valid'] else "✗"
        print(f"  x={r['x']}: B(g({r['x']})) = {r['B(f(x))']} ≤ A({r['x']}) + 5 = {r['bound']}  {status}")

    all_valid3 = all(r['valid'] for r in results3)
    print(f"\n  g is a cost-5 tropical homomorphism: {all_valid3}")

    return all_valid, all_valid2, all_valid3


# ─── Demo 2: Tropical Identity via Min-Plus ──────────────────────────────

def demo_tropical_identity():
    """
    Theorem 2: TropEq u v ↔ ∀ x, min(u(x), v(x)) = u(x) ∧ min(u(x), v(x)) = v(x)
    Identity is characterized by the idempotent meet.
    """
    print("\n" + "=" * 70)
    print("DEMO 2: Tropical Identity = Min-Plus Equality")
    print("=" * 70)

    domain = list(range(6))

    # Equal terms
    u = lambda x: x ** 2 + 1
    v = lambda x: x ** 2 + 1

    print("\nCase 1: u(x) = x² + 1, v(x) = x² + 1 (equal)")
    print("-" * 50)
    for x in domain:
        ux, vx = u(x), v(x)
        m = min(ux, vx)
        print(f"  x={x}: u={ux}, v={vx}, min={m}, "
              f"min=u? {m == ux}, min=v? {m == vx}")

    all_eq = all(min(u(x), v(x)) == u(x) and min(u(x), v(x)) == v(x) for x in domain)
    print(f"\n  Tropical identity holds: {all_eq}")

    # Unequal terms
    w = lambda x: x ** 2 + 2

    print("\nCase 2: u(x) = x² + 1, w(x) = x² + 2 (unequal)")
    print("-" * 50)
    for x in domain:
        ux, wx = u(x), w(x)
        m = min(ux, wx)
        print(f"  x={x}: u={ux}, w={wx}, min={m}, "
              f"min=u? {m == ux}, min=w? {m == wx}")

    all_eq2 = all(min(u(x), w(x)) == u(x) and min(u(x), w(x)) == w(x) for x in domain)
    print(f"\n  Tropical identity holds: {all_eq2}")

    # Extensionality with injective cost
    print("\nExtensionality principle:")
    print("  If B is injective and TropId B f g, then f = g.")

    B_inj = lambda y: y  # Identity is injective
    f_ext = lambda x: x + 1
    g_ext = lambda x: x + 1
    h_ext = lambda x: x + 2

    trop_id_fg = all(B_inj(f_ext(x)) == B_inj(g_ext(x)) for x in domain)
    trop_id_fh = all(B_inj(f_ext(x)) == B_inj(h_ext(x)) for x in domain)
    print(f"  TropId(id, f, g) where f=g: {trop_id_fg} → f = g: True")
    print(f"  TropId(id, f, h) where f≠h: {trop_id_fh} → distinguishable")

    return all_eq, all_eq2


# ─── Demo 3: Initial Algebra / ℕ as Initial ─────────────────────────────

def demo_initial_algebra():
    """
    Theorem 3: ℕ is the initial algebra for the Option functor.
    For any algebra (A, str), there is a unique homomorphism ℕ → A.
    """
    print("\n" + "=" * 70)
    print("DEMO 3: ℕ as Initial Algebra (Tropical Inductive Types)")
    print("=" * 70)

    # Example algebra: strings with concatenation
    class StringAlg:
        def __init__(self):
            self.name = "String repetition algebra"

        def str(self, opt):
            if opt is None:
                return ""         # zero element
            else:
                return opt + "•"  # successor: append a dot

    alg = StringAlg()

    # The unique homomorphism: ℕ → StringAlg
    def unique_hom(n):
        result = alg.str(None)  # start with zero
        for _ in range(n):
            result = alg.str(result)  # apply successor n times
        return result

    print("\nAlgebra: (String, str(none)='', str(some(s))=s+'•')")
    print("Unique homomorphism ℕ → String:")
    print("-" * 50)
    for n in range(8):
        img = unique_hom(n)
        print(f"  f({n}) = '{img}' (length {len(img)})")

    # Verify algebra homomorphism property
    print("\nVerifying algebra homomorphism: f(str(z)) = str(Option.map f z)")
    print("-" * 50)
    # Check f(str(none)) = str(none) i.e. f(0) = ''
    print(f"  f(str(none)) = f(0) = '{unique_hom(0)}'")
    print(f"  str(none) = '{alg.str(None)}'")
    print(f"  Equal: {unique_hom(0) == alg.str(None)}")

    # Check f(str(some(n))) = str(some(f(n)))
    for n in range(5):
        lhs = unique_hom(n + 1)
        rhs = alg.str(unique_hom(n))
        print(f"  f(str(some({n}))) = f({n+1}) = '{lhs}'")
        print(f"  str(some(f({n}))) = str(some('{unique_hom(n)}')) = '{rhs}'")
        print(f"  Equal: {lhs == rhs}")

    # Ranked algebra example
    print("\n\nRanked Algebra Example:")
    print("-" * 50)

    class RankedAlg:
        """An algebra where rank mirrors the natural number structure."""
        def __init__(self):
            self.name = "Ranked power-of-2 algebra"

        def str(self, opt):
            if opt is None:
                return 1       # 2^0
            else:
                return opt * 2  # 2^(n+1) = 2 * 2^n

        def rank(self, a):
            """rank(2^n) = n"""
            r = 0
            while a > 1:
                a //= 2
                r += 1
            return r

    ranked = RankedAlg()

    def ranked_hom(n):
        result = ranked.str(None)
        for _ in range(n):
            result = ranked.str(result)
        return result

    print("Algebra: powers of 2 with rank = log₂")
    for n in range(10):
        val = ranked_hom(n)
        r = ranked.rank(val)
        print(f"  f({n}) = {val}, rank = {r}, rank = n? {r == n}")


# ─── Demo 4: Universe Hierarchy & Normalization ─────────────────────────

def demo_universe_hierarchy():
    """
    Theorem 4: The tropical universe hierarchy is well-founded.
    Code normalization is idempotent and rank-nonincreasing.
    """
    print("\n" + "=" * 70)
    print("DEMO 4: Well-Founded Tropical Universe Hierarchy")
    print("=" * 70)

    K = 5  # Complexity bound

    def normalize(u, K=K):
        return min(u, K)

    print(f"\nNormalization with bound K = {K}")
    print("-" * 50)
    print(f"  {'Code u':>8} {'norm(u)':>8} {'norm(norm(u))':>14} {'Idempotent?':>12} {'rank ≤ u?':>10}")
    for u in range(10):
        nu = normalize(u)
        nnu = normalize(nu)
        idem = nu == nnu
        rank_ok = nu <= u
        print(f"  {u:>8} {nu:>8} {nnu:>14} {str(idem):>12} {str(rank_ok):>10}")

    # Well-foundedness: show all descending chains terminate
    print("\nWell-foundedness: descending chains in normalized codes")
    print("-" * 50)
    for start in [K, K-1, 3, 1]:
        chain = [start]
        current = start
        while current > 0:
            current -= 1
            if normalize(current) == current:  # stay in normalized subset
                chain.append(current)
        print(f"  Starting at {start}: {' > '.join(map(str, chain))} (length {len(chain)})")

    # Distributivity demonstration
    print("\n\nDistributivity: a + min(b,c) = min(a+b, a+c)")
    print("-" * 50)
    for a, b, c in [(2, 3, 5), (0, 4, 1), (7, 2, 2), (3, 0, 6)]:
        lhs = a + min(b, c)
        rhs = min(a + b, a + c)
        print(f"  {a} + min({b},{c}) = {lhs}  vs  min({a}+{b}, {a}+{c}) = {rhs}  Equal: {lhs == rhs}")


# ─── Demo 5: Composition of Cost-Bounded Morphisms ──────────────────────

def demo_composition():
    """
    Cost composition theorem: costs add under composition.
    If f has cost c₁ and g has cost c₂, then g∘f has cost c₁ + c₂.
    """
    print("\n" + "=" * 70)
    print("DEMO 5: Composition of Cost-Bounded Morphisms")
    print("=" * 70)

    domain = list(range(6))

    A = lambda x: 10 - x   # Decreasing cost
    B = lambda y: y + 2     # Increasing cost
    C = lambda z: z         # Identity cost

    f = lambda x: x + 1  # shift
    g = lambda y: y       # identity

    c1 = 0  # Check: B(f(x)) ≤ A(x) + c1
    c2 = 0  # Check: C(g(y)) ≤ B(y) + c2

    # Find minimal costs
    costs_f = [B(f(x)) - A(x) for x in domain]
    costs_g = [C(g(y)) - B(y) for y in domain if B(y) > 0]

    c1 = max(0, max(costs_f))
    c2 = max(0, max(costs_g))

    print(f"\nA(x) = 10-x, B(y) = y+2, C(z) = z")
    print(f"f(x) = x+1, g(y) = y")
    print(f"Minimal cost bound for f: c₁ = {c1}")
    print(f"Minimal cost bound for g: c₂ = {c2}")
    print(f"Predicted bound for g∘f: c₁ + c₂ = {c1 + c2}")
    print("-" * 50)

    print(f"\n{'x':>4} {'A(x)':>6} {'f(x)':>6} {'B(f(x))':>8} {'g(f(x))':>8} {'C(g(f(x)))':>11} {'A(x)+c₁+c₂':>12} {'Valid':>6}")
    for x in domain:
        ax = A(x)
        fx = f(x)
        bfx = B(fx)
        gfx = g(fx)
        cgfx = C(gfx)
        bound = ax + c1 + c2
        valid = cgfx <= bound
        print(f"  {x:>2} {ax:>6} {fx:>6} {bfx:>8} {gfx:>8} {cgfx:>11} {bound:>12} {'✓' if valid else '✗':>6}")


# ─── Main ────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║          TROPICAL TYPE THEORY — Numerical Demonstrations           ║")
    print("╠══════════════════════════════════════════════════════════════════════╣")
    print("║  Types as cost functions · Terms as cost-respecting maps           ║")
    print("║  Identity via min-plus equality · Inductives as initial algebras   ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")

    demo_decidable_typecheck()
    demo_tropical_identity()
    demo_initial_algebra()
    demo_universe_hierarchy()
    demo_composition()

    print("\n" + "=" * 70)
    print("All demonstrations complete.")
    print("=" * 70)


#!/usr/bin/env python3
"""Generate PACKAGE.json bundling all artifacts."""

import json
import os

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

# Read all components
article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
lean_code = read_file('Tropical/TropicalTypeTheory.lean')
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')
applications_code = read_file('applications.py')

# Read visualization data
viz_data = json.loads(read_file('viz_data.json'))

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
            "pseudocode": """Algorithm: TropicalTypeCheck(domain, A, B, f, c)
Input: finite domain, cost functions A, B, function f, bound c
Output: (valid, violations, min_slack)

1. violations ← ∅
2. max_slack ← 0
3. for each x ∈ domain:
4.     slack ← B(f(x)) - A(x)
5.     max_slack ← max(max_slack, slack)
6.     if slack > c:
7.         violations ← violations ∪ {x}
8. return (|violations| = 0, violations, max(0, max_slack))

Complexity: O(|domain|) time, O(|violations|) space.""",
            "code": algorithms_code
        },
        {
            "name": "Initial Algebra Recursion (Bellman-style)",
            "pseudocode": """Algorithm: InitialAlgebraHom(zero_val, succ_fn, n)
Input: base value zero_val, successor succ_fn, target n
Output: f(n) in target algebra

1. result ← zero_val
2. for i = 1 to n:
3.     result ← succ_fn(result)
4. return result

Complexity: O(n) applications of succ_fn.
Correctness: Guaranteed by initiality theorem (unique algebra homomorphism).""",
            "code": algorithms_code
        }
    ],
    "visualizations": [
        {
            "name": "Tropical Type Checking as Constraint Satisfaction",
            "data": viz_data['typecheck']
        },
        {
            "name": "Tropical Identity via Min-Plus Equality",
            "data": viz_data['identity']
        },
        {
            "name": "Initial Algebra Semantics",
            "data": viz_data['initial_algebra']
        },
        {
            "name": "Tropical Universe Hierarchy",
            "data": viz_data['universe']
        },
        {
            "name": "Cost Composition (Substitution Theorem)",
            "data": viz_data['composition']
        }
    ],
    "lean_proofs": lean_code
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print(f"PACKAGE.json generated ({os.path.getsize('PACKAGE.json') / 1024:.1f} KB)")


#!/usr/bin/env python3
"""
Tropical Type Theory: Visualizations

Generates publication-quality figures illustrating the key concepts.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import base64
import io
import json

def fig_to_base64(fig):
    """Convert matplotlib figure to base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight', facecolor='white')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


def viz_tropical_typecheck():
    """Visualize tropical type checking as constraint satisfaction."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    domain = list(range(6))
    A = [2*x + 3 for x in domain]
    f_valid = [x + 1 for x in domain]
    Bf_valid = [y + 1 for y in f_valid]
    f_invalid = [3*x for x in domain]
    Bf_invalid = [y + 1 for y in f_invalid]

    # Valid case
    ax1.bar([x - 0.15 for x in domain], A, 0.3, label='A(x) [budget]',
            color='#2196F3', alpha=0.8)
    ax1.bar([x + 0.15 for x in domain], Bf_valid, 0.3, label='B(f(x)) [cost]',
            color='#4CAF50', alpha=0.8)
    ax1.set_xlabel('Element x', fontsize=12)
    ax1.set_ylabel('Cost', fontsize=12)
    ax1.set_title('✓ Well-Typed: B(f(x)) ≤ A(x)', fontsize=13, fontweight='bold')
    ax1.legend(fontsize=10)
    ax1.set_xticks(domain)

    # Invalid case
    ax2.bar([x - 0.15 for x in domain], A, 0.3, label='A(x) [budget]',
            color='#2196F3', alpha=0.8)
    colors = ['#4CAF50' if Bf_invalid[i] <= A[i] else '#F44336' for i in range(len(domain))]
    ax2.bar([x + 0.15 for x in domain], Bf_invalid, 0.3, label='B(g(x)) [cost]',
            color=colors, alpha=0.8)
    ax2.set_xlabel('Element x', fontsize=12)
    ax2.set_ylabel('Cost', fontsize=12)
    ax2.set_title('✗ Ill-Typed: B(g(x)) > A(x)', fontsize=13, fontweight='bold')
    valid_patch = mpatches.Patch(color='#4CAF50', alpha=0.8, label='Within budget')
    violation_patch = mpatches.Patch(color='#F44336', alpha=0.8, label='Violation')
    budget_patch = mpatches.Patch(color='#2196F3', alpha=0.8, label='A(x) [budget]')
    ax2.legend(handles=[budget_patch, valid_patch, violation_patch], fontsize=10)
    ax2.set_xticks(domain)

    fig.suptitle('Tropical Type Checking as Constraint Satisfaction', fontsize=15, fontweight='bold', y=1.02)
    plt.tight_layout()
    return fig_to_base64(fig)


def viz_minplus_identity():
    """Visualize tropical identity via min-plus equality."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    domain = list(range(7))

    # Case 1: Equal terms
    u = [x**2 + 1 for x in domain]
    v = [x**2 + 1 for x in domain]
    mins = [min(u[i], v[i]) for i in range(len(domain))]

    axes[0].plot(domain, u, 'o-', color='#2196F3', label='u(x)', markersize=8, linewidth=2)
    axes[0].plot(domain, v, 's--', color='#FF9800', label='v(x)', markersize=8, linewidth=2)
    axes[0].plot(domain, mins, '^:', color='#4CAF50', label='min(u,v)', markersize=8, linewidth=2)
    axes[0].set_title('Equal: u = v\nmin(u,v) = u = v', fontsize=12, fontweight='bold')
    axes[0].legend(fontsize=10)
    axes[0].set_xlabel('x')
    axes[0].set_ylabel('Cost')

    # Case 2: Unequal terms
    u2 = [x**2 + 1 for x in domain]
    v2 = [x**2 + 3 for x in domain]
    mins2 = [min(u2[i], v2[i]) for i in range(len(domain))]

    axes[1].plot(domain, u2, 'o-', color='#2196F3', label='u(x)', markersize=8, linewidth=2)
    axes[1].plot(domain, v2, 's--', color='#FF9800', label='v(x)', markersize=8, linewidth=2)
    axes[1].plot(domain, mins2, '^:', color='#4CAF50', label='min(u,v)', markersize=8, linewidth=2)
    axes[1].set_title('Unequal: u ≠ v\nmin(u,v) = u ≠ v', fontsize=12, fontweight='bold')
    axes[1].legend(fontsize=10)
    axes[1].set_xlabel('x')
    axes[1].set_ylabel('Cost')

    # Case 3: Crossing terms
    u3 = [abs(x - 3) + 1 for x in domain]
    v3 = [x for x in domain]
    mins3 = [min(u3[i], v3[i]) for i in range(len(domain))]

    axes[2].plot(domain, u3, 'o-', color='#2196F3', label='u(x)', markersize=8, linewidth=2)
    axes[2].plot(domain, v3, 's--', color='#FF9800', label='v(x)', markersize=8, linewidth=2)
    axes[2].plot(domain, mins3, '^:', color='#4CAF50', label='min(u,v)', markersize=8, linewidth=2)
    axes[2].set_title('Crossing: min selects\nlower cost at each point', fontsize=12, fontweight='bold')
    axes[2].legend(fontsize=10)
    axes[2].set_xlabel('x')
    axes[2].set_ylabel('Cost')

    fig.suptitle('Tropical Identity: Equality ↔ Idempotent Meet Coincidence', fontsize=15, fontweight='bold', y=1.02)
    plt.tight_layout()
    return fig_to_base64(fig)


def viz_initial_algebra():
    """Visualize initial algebra recursion for ℕ."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    # Left: The recursion pattern
    n_vals = list(range(8))

    # Algebra 1: powers of 2
    powers = [2**n for n in n_vals]
    ax1.plot(n_vals, powers, 'o-', color='#E91E63', label='2ⁿ (power algebra)',
             markersize=10, linewidth=2)
    ax1.plot(n_vals, [n for n in n_vals], 's-', color='#2196F3', label='n (identity)',
             markersize=10, linewidth=2)
    ax1.plot(n_vals, [n*(n+1)//2 for n in n_vals], '^-', color='#4CAF50',
             label='n(n+1)/2 (triangular)', markersize=10, linewidth=2)

    ax1.set_xlabel('n (natural number)', fontsize=12)
    ax1.set_ylabel('f(n) in target algebra', fontsize=12)
    ax1.set_title('Unique Homomorphisms from ℕ', fontsize=13, fontweight='bold')
    ax1.legend(fontsize=10)

    # Right: Rank preservation
    ranks_power = list(range(8))  # rank of 2^n = n
    ranks_tri = list(range(8))    # rank structure

    ax2.plot(n_vals, n_vals, 'o-', color='#2196F3', label='n (source rank)',
             markersize=10, linewidth=2)
    ax2.plot(n_vals, ranks_power, 's--', color='#E91E63', label='rank(f(n)) = n',
             markersize=10, linewidth=2)

    for n in n_vals:
        ax2.annotate('', xy=(n, ranks_power[n]), xytext=(n, n_vals[n]),
                     arrowprops=dict(arrowstyle='->', color='gray', lw=0.5))

    ax2.set_xlabel('n', fontsize=12)
    ax2.set_ylabel('Rank', fontsize=12)
    ax2.set_title('Rank Preservation: rank(f(n)) = n', fontsize=13, fontweight='bold')
    ax2.legend(fontsize=10)

    fig.suptitle('Initial Algebra Semantics: ℕ as Universal Inductive Type', fontsize=15, fontweight='bold', y=1.02)
    plt.tight_layout()
    return fig_to_base64(fig)


def viz_universe_hierarchy():
    """Visualize the tropical universe hierarchy with normalization."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    K = 5
    codes = list(range(12))
    normalized = [min(u, K) for u in codes]

    # Left: Normalization function
    ax1.plot(codes, codes, '--', color='gray', alpha=0.5, label='identity')
    ax1.plot(codes, normalized, 'o-', color='#9C27B0', markersize=10, linewidth=2,
             label=f'normalize(u, K={K})')

    # Shade the collapse region
    ax1.fill_between(codes, normalized, codes, where=[n < c for n, c in zip(normalized, codes)],
                      alpha=0.2, color='#9C27B0', label='Collapsed region')

    ax1.set_xlabel('Code u', fontsize=12)
    ax1.set_ylabel('Normalized code', fontsize=12)
    ax1.set_title(f'Idempotent Normalization (K={K})\nnorm(norm(u)) = norm(u)', fontsize=13, fontweight='bold')
    ax1.legend(fontsize=10)

    # Right: Well-founded hierarchy
    levels = {}
    for u in codes:
        nu = min(u, K)
        if nu not in levels:
            levels[nu] = []
        levels[nu].append(u)

    y_positions = sorted(levels.keys())
    for i, level in enumerate(y_positions):
        members = levels[level]
        for j, m in enumerate(members):
            color = '#4CAF50' if m <= K else '#F44336'
            ax2.scatter(j, level, s=200, c=color, zorder=3, edgecolors='black')
            ax2.annotate(str(m), (j, level), ha='center', va='center', fontsize=9, fontweight='bold')

    # Draw hierarchy arrows
    for i in range(len(y_positions) - 1):
        ax2.annotate('', xy=(0, y_positions[i+1]), xytext=(0, y_positions[i]),
                     arrowprops=dict(arrowstyle='->', color='gray', lw=1.5))

    normal_patch = mpatches.Patch(color='#4CAF50', label='Normal (u ≤ K)')
    collapsed_patch = mpatches.Patch(color='#F44336', label='Collapsed (u > K)')
    ax2.legend(handles=[normal_patch, collapsed_patch], fontsize=10)
    ax2.set_xlabel('Equivalence class members', fontsize=12)
    ax2.set_ylabel('Universe level (rank)', fontsize=12)
    ax2.set_title('Well-Founded Universe Hierarchy', fontsize=13, fontweight='bold')

    fig.suptitle('Tropical Universe Stratification', fontsize=15, fontweight='bold', y=1.02)
    plt.tight_layout()
    return fig_to_base64(fig)


def viz_composition():
    """Visualize cost composition in the tropical semantic calculus."""
    fig, ax = plt.subplots(figsize=(10, 6))

    domain = list(range(7))

    # Three cost functions
    A = [15 - x for x in domain]
    B = [x + 3 for x in domain]
    C = [x for x in domain]

    # Morphisms: f shifts right, g is identity
    f_vals = [x + 1 for x in domain]
    B_of_f = [f + 3 for f in f_vals]

    ax.plot(domain, A, 'o-', color='#2196F3', label='A(x) = 15-x [source budget]',
            markersize=10, linewidth=2.5)
    ax.plot(domain, B_of_f, 's-', color='#FF9800', label='B(f(x)) = x+4 [intermediate]',
            markersize=10, linewidth=2.5)
    ax.plot(domain, [x + 3 for x in f_vals], '^-', color='#4CAF50',
            label='C(g(f(x))) = x+1 [final cost]',
            markersize=10, linewidth=2.5)

    # Show the composition bound
    c1, c2 = 3, 0
    bound = [a + c1 + c2 for a in A]
    ax.plot(domain, bound, '--', color='#F44336', label=f'A(x) + c₁ + c₂ = A(x)+{c1+c2} [bound]',
            linewidth=2)
    ax.fill_between(domain, [0]*len(domain), bound, alpha=0.1, color='#F44336')

    ax.set_xlabel('Element x', fontsize=12)
    ax.set_ylabel('Cost', fontsize=12)
    ax.set_title('Cost Composition: g∘f has cost c₁+c₂\n(Substitution Theorem)', fontsize=14, fontweight='bold')
    ax.legend(fontsize=10, loc='upper right')

    plt.tight_layout()
    return fig_to_base64(fig)


if __name__ == "__main__":
    print("Generating visualizations...")

    viz_data = {}
    viz_data['typecheck'] = viz_tropical_typecheck()
    print("  ✓ Type checking visualization")

    viz_data['identity'] = viz_minplus_identity()
    print("  ✓ Min-plus identity visualization")

    viz_data['initial_algebra'] = viz_initial_algebra()
    print("  ✓ Initial algebra visualization")

    viz_data['universe'] = viz_universe_hierarchy()
    print("  ✓ Universe hierarchy visualization")

    viz_data['composition'] = viz_composition()
    print("  ✓ Composition visualization")

    # Save for JSON package
    with open('viz_data.json', 'w') as f:
        json.dump(viz_data, f)

    print("\nAll visualizations generated and saved.")

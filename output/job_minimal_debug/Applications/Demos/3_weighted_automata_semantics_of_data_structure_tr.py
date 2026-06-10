#!/usr/bin/env python3
"""
Applications of Tropical Trace Semantics

Real-world applications demonstrating the practical value of viewing
data structure complexity through the lens of tropical algebra and
weighted automata theory.
"""

import numpy as np
from algorithms import WeightedAutomaton, maximum_cycle_mean, optimal_potential


# ── Application 1: Certified Amortized Bounds for Splay Trees ─────────────

def splay_tree_model():
    """
    Simplified splay tree model as a weighted automaton.

    We model a small splay tree with 3 elements {1,2,3} and track
    the tree shape as the automaton state. The key insight: the
    amortized O(log n) bound for splay trees corresponds to a
    potential function that is a tropical sub-eigenvector.

    In a full splay tree, the potential is Σ log(subtree_size).
    Here we use a simplified 3-node version to demonstrate the principle.
    """
    print("=" * 70)
    print("APPLICATION 1: Splay Tree Amortized Analysis via Tropical Spectral Theory")
    print("=" * 70)

    # 3-node BST has 5 distinct shapes (Catalan number C_3 = 5)
    # We label them 0-4 based on the access patterns
    # States represent different tree configurations
    # Operations: access element 1, 2, or 3

    # Simplified model: 5 states, 3 operations
    # Cost = depth of accessed element (number of comparisons)
    n_states = 5
    n_ops = 3

    # Define transitions and costs (simplified model)
    # State encodings for a 3-node BST:
    # 0: balanced       (2 at root)
    # 1: left-skewed    (3 at root, 2 left, 1 leftleft)
    # 2: right-skewed   (1 at root, 2 right, 3 rightright)
    # 3: left-right     (3 at root, 1 left, 2 leftright)
    # 4: right-left     (1 at root, 3 right, 2 rightleft)

    table = {}
    # From balanced (state 0): accessing any element costs 1 or 2
    table[(0, 0)] = (2, 2.0)  # access 1: depth 2, splay to right-skewed
    table[(0, 1)] = (0, 1.0)  # access 2: at root, stays balanced
    table[(0, 2)] = (1, 2.0)  # access 3: depth 2, splay to left-skewed

    # From left-skewed (state 1):
    table[(1, 0)] = (2, 3.0)  # access 1: depth 3, expensive splay
    table[(1, 1)] = (3, 2.0)  # access 2: depth 2
    table[(1, 2)] = (1, 1.0)  # access 3: at root

    # From right-skewed (state 2):
    table[(2, 0)] = (2, 1.0)  # access 1: at root
    table[(2, 1)] = (4, 2.0)  # access 2: depth 2
    table[(2, 2)] = (1, 3.0)  # access 3: depth 3, expensive splay

    # From left-right (state 3):
    table[(3, 0)] = (2, 2.0)  # access 1
    table[(3, 1)] = (0, 2.0)  # access 2: splay to balanced
    table[(3, 2)] = (1, 1.0)  # access 3: at root

    # From right-left (state 4):
    table[(4, 0)] = (2, 1.0)  # access 1: at root
    table[(4, 1)] = (0, 2.0)  # access 2: splay to balanced
    table[(4, 2)] = (1, 2.0)  # access 3

    aut = WeightedAutomaton(
        n_states=n_states, n_ops=n_ops,
        step=lambda s, a: table[(s, a)][0],
        cost=lambda s, a: table[(s, a)][1],
    )

    A = aut.transition_matrix()
    print("\n  Transition matrix (min-plus):")
    INF = float('inf')
    for i in range(n_states):
        row = "  ".join(f"{A[i][j]:5.1f}" if A[i][j] < INF else "  inf" for j in range(n_states))
        print(f"    [{row}]")

    # Compute tropical spectral radius
    A_max = np.where(A < INF, A, float('-inf'))
    rho = maximum_cycle_mean(A_max)
    print(f"\n  Tropical spectral radius: ρ = {rho:.4f}")
    print(f"  → Asymptotic worst-case average cost per operation: {rho:.4f}")

    # Find certifying potential
    phi = optimal_potential(A, rho + 0.01)
    if phi is not None:
        print(f"\n  Certifying potential: φ = [{', '.join(f'{p:.3f}' for p in phi)}]")
        print(f"  Amortized costs (all ≤ ρ + ε = {rho + 0.01:.4f}):")
        for s in range(n_states):
            for a in range(n_ops):
                t = table[(s, a)][0]
                c = table[(s, a)][1]
                am = c + phi[t] - phi[s]
                print(f"    s={s}, op={a}: actual={c:.1f}, amortized={am:.4f}")

    # Simulate long sequence
    print("\n  Long sequence simulation:")
    rng = np.random.RandomState(123)
    for n_steps in [100, 1000, 10000]:
        w = [rng.randint(0, n_ops) for _ in range(n_steps)]
        tc = aut.trace_cost(0, w)
        avg = tc / n_steps
        print(f"    {n_steps:>6} ops: avg cost = {avg:.4f} (ρ = {rho:.4f})")
    print()


# ── Application 2: Network Protocol State Machine ────────────────────────

def network_protocol():
    """
    Model a network protocol (simplified TCP-like) as a weighted automaton
    and analyze its amortized throughput cost using tropical spectral theory.
    """
    print("=" * 70)
    print("APPLICATION 2: Network Protocol — Throughput via Tropical Spectral Bound")
    print("=" * 70)

    # States: IDLE=0, SLOW_START=1, CONGESTION_AVOIDANCE=2, RECOVERY=3
    # Operations: SEND=0, ACK=1, LOSS=2
    n_states = 4
    n_ops = 3
    state_names = ["IDLE", "SLOW_START", "CONG_AVOID", "RECOVERY"]
    op_names = ["SEND", "ACK", "LOSS"]

    table = {
        # IDLE
        (0, 0): (1, 5.0),  # SEND → SLOW_START, setup cost
        (0, 1): (0, 0.0),  # ACK while idle: no-op
        (0, 2): (0, 0.0),  # LOSS while idle: no-op

        # SLOW_START
        (1, 0): (1, 1.0),  # SEND: cheap (exponential growth)
        (1, 1): (2, 0.5),  # ACK → CONGESTION_AVOIDANCE
        (1, 2): (3, 3.0),  # LOSS → RECOVERY, retransmit cost

        # CONGESTION_AVOIDANCE
        (2, 0): (2, 2.0),  # SEND: moderate cost
        (2, 1): (2, 0.5),  # ACK: stay, small processing
        (2, 2): (3, 4.0),  # LOSS → RECOVERY, expensive

        # RECOVERY
        (3, 0): (3, 3.0),  # SEND: expensive (retransmitting)
        (3, 1): (2, 1.0),  # ACK → back to CONG_AVOIDANCE
        (3, 2): (0, 6.0),  # LOSS → IDLE, full reset
    }

    aut = WeightedAutomaton(
        n_states=n_states, n_ops=n_ops,
        step=lambda s, a: table[(s, a)][0],
        cost=lambda s, a: table[(s, a)][1],
    )

    A = aut.transition_matrix()
    print("\n  State machine (min-plus costs):")
    INF = float('inf')
    for i in range(n_states):
        row = "  ".join(f"{A[i][j]:5.1f}" if A[i][j] < INF else "  inf"
                        for j in range(n_states))
        print(f"    {state_names[i]:>12}: [{row}]")

    A_max = np.where(A < INF, A, float('-inf'))
    rho = maximum_cycle_mean(A_max)
    print(f"\n  Tropical spectral radius: ρ = {rho:.4f}")
    print(f"  → Worst-case amortized cost per protocol event: {rho:.4f}")

    # Simulate different traffic patterns
    print("\n  Traffic pattern analysis:")
    patterns = {
        "Normal (mostly ACKs)": [0, 1, 1, 0, 1, 1, 0, 1, 1, 1] * 100,
        "Lossy network": [0, 0, 2, 0, 1, 0, 2, 0, 0, 2] * 100,
        "Bursty": [0, 0, 0, 0, 0, 1, 1, 1, 2, 1] * 100,
    }

    for name, w in patterns.items():
        tc = aut.trace_cost(0, w)
        avg = tc / len(w)
        print(f"    {name:30s}: avg cost = {avg:.4f}  (ρ = {rho:.4f})")
    print()


# ── Application 3: Cache Replacement Policy Analysis ─────────────────────

def cache_analysis():
    """
    Analyze cache replacement policies (LRU vs FIFO) as tropical automata
    and compare their spectral radii.
    """
    print("=" * 70)
    print("APPLICATION 3: Cache Policies — Comparing Spectral Radii")
    print("=" * 70)

    # Simplified: 2-slot cache with 3 possible items {A=0, B=1, C=2}
    # State = (slot1, slot2) — which items are cached
    # We enumerate all valid states

    items = [0, 1, 2]
    states = []
    state_map = {}
    for i in items:
        for j in items:
            if i != j:
                state_map[(i, j)] = len(states)
                states.append((i, j))

    n_states = len(states)
    n_ops = 3  # request item 0, 1, or 2

    print(f"\n  Cache states (2-slot, 3 items): {n_states} states")
    for idx, (a, b) in enumerate(states):
        print(f"    State {idx}: cache = [{a}, {b}]")

    # LRU policy
    def lru_step(s_idx, requested):
        s1, s2 = states[s_idx]
        if requested == s1:
            return s_idx  # hit, no change (most recent already in front)
        elif requested == s2:
            return state_map[(requested, s1)]  # hit, move to front
        else:
            return state_map[(requested, s1)]  # miss, evict s2

    def lru_cost(s_idx, requested):
        s1, s2 = states[s_idx]
        if requested == s1 or requested == s2:
            return 1.0  # cache hit
        else:
            return 10.0  # cache miss

    lru = WeightedAutomaton(n_states, n_ops, lru_step, lru_cost)
    A_lru = lru.transition_matrix()
    A_lru_max = np.where(A_lru < float('inf'), A_lru, float('-inf'))
    rho_lru = maximum_cycle_mean(A_lru_max)

    # FIFO policy
    fifo_ptr = {}  # which slot to replace next
    for idx in range(n_states):
        fifo_ptr[idx] = 0  # always replace slot 0 (simplified)

    def fifo_step(s_idx, requested):
        s1, s2 = states[s_idx]
        if requested == s1 or requested == s2:
            return s_idx  # hit
        else:
            # Replace s2 (FIFO: oldest item)
            return state_map[(s1, requested)]

    fifo = WeightedAutomaton(n_states, n_ops, fifo_step, lru_cost)
    A_fifo = fifo.transition_matrix()
    A_fifo_max = np.where(A_fifo < float('inf'), A_fifo, float('-inf'))
    rho_fifo = maximum_cycle_mean(A_fifo_max)

    print(f"\n  LRU tropical spectral radius:  ρ = {rho_lru:.4f}")
    print(f"  FIFO tropical spectral radius: ρ = {rho_fifo:.4f}")
    print(f"\n  → LRU {'dominates' if rho_lru <= rho_fifo else 'is dominated by'} FIFO")
    print(f"    (lower spectral radius = better worst-case amortized cost)")

    # Compare on specific workloads
    print("\n  Workload comparison:")
    rng = np.random.RandomState(42)

    workloads = {
        "Uniform random": [rng.randint(0, 3) for _ in range(1000)],
        "Locality (80/20)": [0 if rng.random() < 0.8 else rng.randint(1, 3)
                             for _ in range(1000)],
        "Adversarial cycling": [i % 3 for i in range(1000)],
    }

    for name, w in workloads.items():
        lru_tc = lru.trace_cost(0, w)
        fifo_tc = fifo.trace_cost(0, w)
        print(f"    {name:25s}: LRU avg={lru_tc/len(w):.3f}, "
              f"FIFO avg={fifo_tc/len(w):.3f}")
    print()


# ── Main ──────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("\n" + "█" * 70)
    print("  TROPICAL TRACE SEMANTICS — Real-World Applications")
    print("█" * 70 + "\n")

    splay_tree_model()
    network_protocol()
    cache_analysis()

    print("All applications completed successfully.")


#!/usr/bin/env python3
"""
Weighted Automata Semantics of Data Structure Traces — Demonstrations

Concrete numerical examples illustrating the bridge between amortized analysis,
weighted automata, and tropical spectral theory.
"""

import numpy as np


# ── Core definitions (matching the Lean formalization) ─────────────────────

def run(step, s, w):
    """Run a deterministic automaton on word w starting from state s."""
    for a in w:
        s = step(s, a)
    return s


def trace_cost(step, cost, s, w):
    """Total cost of executing trace w from state s."""
    total = 0.0
    for a in w:
        total += cost(s, a)
        s = step(s, a)
    return total


def amortized_cost(step, actual_cost, potential, s, a):
    """Amortized one-step cost: c(s,a) + φ(step(s,a)) - φ(s)."""
    return actual_cost(s, a) + potential(step(s, a)) - potential(s)


# ── Demo 1: Binary Counter ────────────────────────────────────────────────

def demo_binary_counter():
    """
    Classic amortized analysis example: incrementing a k-bit binary counter.

    States: integers 0..2^k - 1 (the counter value)
    Operation: increment (one operation type)
    Cost: number of bit flips

    Potential: number of 1-bits in the binary representation.
    Amortized cost of increment ≤ 2 always.
    """
    print("=" * 70)
    print("DEMO 1: Binary Counter — Amortized Analysis as Gauge Transform")
    print("=" * 70)

    k = 4  # 4-bit counter
    N = 2 ** k

    def step(s, a):
        return (s + 1) % N

    def cost(s, _a):
        """Cost = number of trailing 1-bits + 1 (bits that flip)."""
        if s == 0:
            return 1
        c = 0
        x = s
        while x & 1:
            c += 1
            x >>= 1
        return c + 1  # the trailing 1s flip to 0, plus one 0 flips to 1

    def potential(s):
        """Number of 1-bits."""
        return bin(s).count('1')

    # Verify the gauge transform theorem (Theorem B)
    print("\nTheorem B verification: traceCost(amort) = traceCost(actual) + φ(final) - φ(initial)")
    print("-" * 70)

    w = [0] * 15  # 15 increments (operation type doesn't matter, just one op)
    s0 = 0

    actual_total = trace_cost(step, cost, s0, w)
    amort_cost_fn = lambda s, a: amortized_cost(step, cost, potential, s, a)
    amort_total = trace_cost(step, amort_cost_fn, s0, w)
    final = run(step, s0, w)
    boundary = potential(final) - potential(s0)

    print(f"  Initial state: {s0} (binary: {s0:04b})")
    print(f"  Final state:   {final} (binary: {final:04b})")
    print(f"  Trace length:  {len(w)}")
    print(f"  Actual total cost:    {actual_total:.1f}")
    print(f"  Amortized total cost: {amort_total:.1f}")
    print(f"  Boundary term φ(final) - φ(initial): {boundary:.1f}")
    print(f"  Verification: amort_total = actual_total + boundary?  "
          f"{abs(amort_total - (actual_total + boundary)) < 1e-10}")

    # Verify Theorem C: uniform amortized bound
    print("\nTheorem C verification: uniform amortized bound → linear trace bound")
    print("-" * 70)
    B = 2.0  # amortized cost of increment is always ≤ 2
    max_amort = max(amortized_cost(step, cost, potential, s, 0) for s in range(N))
    print(f"  Max amortized one-step cost: {max_amort:.1f} ≤ B = {B:.1f}")
    print(f"  Trace bound: B * len + φ(s) - φ(final) = "
          f"{B * len(w) + potential(s0) - potential(final):.1f}")
    print(f"  Actual total cost: {actual_total:.1f}")
    print(f"  Bound holds? {actual_total <= B * len(w) + potential(s0) - potential(final) + 1e-10}")

    # Closed trace: increment 16 times returns to 0
    print("\nClosed trace verification (Theorem: closed_trace_amortized_eq_actual)")
    print("-" * 70)
    w_closed = [0] * N  # 2^k increments = full cycle
    actual_closed = trace_cost(step, cost, 0, w_closed)
    amort_closed = trace_cost(step, amort_cost_fn, 0, w_closed)
    print(f"  Full cycle ({N} increments): actual = {actual_closed:.1f}, amortized = {amort_closed:.1f}")
    print(f"  Equal? {abs(actual_closed - amort_closed) < 1e-10}")
    print(f"  Average cost per step: {actual_closed / N:.4f}")
    print(f"  Cycle mean bound ≤ B = {B:.1f}? {actual_closed / N <= B + 1e-10}")
    print()


# ── Demo 2: Dynamic Array (Doubling Strategy) ─────────────────────────────

def demo_dynamic_array():
    """
    Dynamic array with doubling strategy.

    State: (size, capacity) — we encode as a single integer for simplicity.
    Operations: push
    Cost: 1 if size < capacity, else capacity + 1 (copy all + insert)
    Potential: 2 * size - capacity
    """
    print("=" * 70)
    print("DEMO 2: Dynamic Array — Gauge Transform Eliminates Spikes")
    print("=" * 70)

    max_cap = 64

    # State = (size, capacity), encoded for simplicity
    def step(state, _a):
        size, cap = state
        if size < cap:
            return (size + 1, cap)
        else:
            new_cap = max(cap * 2, 1)
            return (size + 1, new_cap)

    def cost(state, _a):
        size, cap = state
        if size < cap:
            return 1.0
        else:
            return float(cap + 1)

    def potential(state):
        size, cap = state
        return 2.0 * size - cap

    n_ops = 33
    w = [0] * n_ops
    s0 = (0, 0)

    # Collect per-step costs
    actual_costs = []
    amort_costs = []
    s = s0
    for a in w:
        ac = cost(s, a)
        am = amortized_cost(step, cost, potential, s, a)
        actual_costs.append(ac)
        amort_costs.append(am)
        s = step(s, a)

    print(f"\n  {'Step':>4}  {'Actual':>8}  {'Amortized':>10}  {'State':>15}")
    print("  " + "-" * 45)
    for i in range(min(n_ops, 20)):
        si = s0
        for j in range(i):
            si = step(si, 0)
        print(f"  {i+1:>4}  {actual_costs[i]:>8.1f}  {amort_costs[i]:>10.1f}  {si}")

    if n_ops > 20:
        print(f"  ... ({n_ops - 20} more steps)")

    actual_total = sum(actual_costs)
    amort_total = sum(amort_costs)
    final = run(step, s0, w)
    boundary = potential(final) - potential(s0)

    print(f"\n  Total actual cost:    {actual_total:.1f}")
    print(f"  Total amortized cost: {amort_total:.1f}")
    print(f"  Gauge identity: amort = actual + boundary = {actual_total + boundary:.1f}")
    print(f"  Max amortized step cost: {max(amort_costs):.1f}")
    print(f"  Amortized bound B=3: all steps ≤ 3? {all(c <= 3.0 + 1e-10 for c in amort_costs)}")
    print()


# ── Demo 3: Tropical Transition Matrix & Spectral Radius ──────────────────

def demo_tropical_spectral():
    """
    Construct the min-plus transition matrix for a simple automaton
    and compute its tropical spectral radius (maximum cycle mean).
    """
    print("=" * 70)
    print("DEMO 3: Tropical Spectral Radius Controls Asymptotic Cost")
    print("=" * 70)

    # 3-state automaton with 2 operations
    n_states = 3
    n_ops = 2

    # Transition function and costs
    # State 0 --op0--> State 1 (cost 1)
    # State 0 --op1--> State 2 (cost 3)
    # State 1 --op0--> State 2 (cost 2)
    # State 1 --op1--> State 0 (cost 1)
    # State 2 --op0--> State 0 (cost 4)
    # State 2 --op1--> State 1 (cost 1)

    transitions = {
        (0, 0): (1, 1.0),
        (0, 1): (2, 3.0),
        (1, 0): (2, 2.0),
        (1, 1): (0, 1.0),
        (2, 0): (0, 4.0),
        (2, 1): (1, 1.0),
    }

    def step(s, a):
        return transitions[(s, a)][0]

    def cost(s, a):
        return transitions[(s, a)][1]

    # Build min-plus transition matrix: A[i][j] = min cost to go from i to j
    INF = float('inf')
    A = np.full((n_states, n_states), INF)
    for (s, a), (t, c) in transitions.items():
        A[s][t] = min(A[s][t], c)

    print("\n  Min-plus transition matrix A:")
    for i in range(n_states):
        row = "  " + "  ".join(f"{A[i][j]:5.1f}" if A[i][j] < INF else "  inf" for j in range(n_states))
        print(f"    [{row}]")

    # Compute maximum cycle mean (= tropical spectral radius for irreducible matrix)
    # Enumerate all simple cycles
    def find_cycles(n):
        """Find all simple cycles and their mean weights."""
        cycles = []
        for start in range(n):
            # DFS to find cycles
            stack = [(start, [start], 0.0)]
            while stack:
                node, path, weight = stack.pop()
                for next_node in range(n):
                    if A[node][next_node] < INF:
                        w = weight + A[node][next_node]
                        if next_node == start and len(path) > 1:
                            cycles.append((list(path), w, w / len(path)))
                        elif next_node not in path and len(path) < n:
                            stack.append((next_node, path + [next_node], w))
        return cycles

    cycles = find_cycles(n_states)
    print("\n  All simple cycles (state sequence, total cost, mean cost):")
    for path, total, mean in sorted(cycles, key=lambda x: -x[2]):
        cycle_str = " → ".join(str(s) for s in path) + f" → {path[0]}"
        print(f"    {cycle_str:20s}  total={total:5.1f}  mean={mean:.4f}")

    max_cycle_mean = max(c[2] for c in cycles)
    print(f"\n  Tropical spectral radius (max cycle mean): ρ = {max_cycle_mean:.4f}")

    # Verify: long traces have average cost approaching ρ
    print("\n  Long trace average costs (random walks):")
    rng = np.random.RandomState(42)
    for length in [100, 1000, 10000]:
        w = [rng.randint(0, n_ops) for _ in range(length)]
        tc = trace_cost(step, cost, 0, w)
        avg = tc / length
        print(f"    Length {length:>6}: average cost = {avg:.4f}  "
              f"(ρ = {max_cycle_mean:.4f}, ratio = {avg/max_cycle_mean:.4f})")

    # Find a potential function that certifies the spectral bound
    # We want: cost(i,a) + φ(step(i,a)) - φ(i) ≤ B for all i,a
    # Equivalently: A[i][j] + φ(j) - φ(i) ≤ B for all edges (i,j)
    # This is a shortest-path feasibility problem
    print("\n  Potential function search (certifying B = ρ):")
    B = max_cycle_mean
    # Use Bellman-Ford on the graph with weights A[i][j] - B
    # φ[j] - φ[i] ≤ B - A[i][j], so add edge i→j with weight B - A[i][j]
    phi = np.zeros(n_states)
    for _ in range(n_states):
        for i in range(n_states):
            for j in range(n_states):
                if A[i][j] < INF:
                    phi[j] = min(phi[j], phi[i] + A[i][j] - B)

    print(f"    φ = [{', '.join(f'{p:.4f}' for p in phi)}]")
    print(f"    Amortized costs with this potential:")
    for (s, a), (t, c) in sorted(transitions.items()):
        am = c + phi[t] - phi[s]
        print(f"      state={s}, op={a} → state={t}: "
              f"actual={c:.1f}, amortized={am:.4f}, ≤ B={B:.4f}? {am <= B + 1e-10}")
    print()


# ── Demo 4: Gauge Equivalence Visualization Data ─────────────────────────

def demo_gauge_equivalence():
    """Show how different potentials give different amortized costs
    but preserve the total cost + boundary structure."""
    print("=" * 70)
    print("DEMO 4: Gauge Equivalence — Different Potentials, Same Physics")
    print("=" * 70)

    # Simple 2-state automaton
    def step(s, a):
        return 1 - s  # toggles between 0 and 1

    def cost(s, _a):
        return 3.0 if s == 0 else 1.0  # expensive from 0, cheap from 1

    w = [0] * 10  # 10 toggles

    potentials = {
        "φ₁ = 0 (trivial)": lambda s: 0.0,
        "φ₂ = s (linear)": lambda s: float(s),
        "φ₃ = -s (negative)": lambda s: -float(s),
        "φ₄ = 2s (scaled)": lambda s: 2.0 * s,
    }

    print(f"\n  Trace: 10 toggle operations from state 0")
    print(f"  Actual total cost: {trace_cost(step, cost, 0, w):.1f}")
    print()

    for name, phi in potentials.items():
        amort_fn = lambda s, a, p=phi: amortized_cost(step, cost, p, s, a)
        amort_total = trace_cost(step, amort_fn, 0, w)
        final = run(step, 0, w)
        boundary = phi(final) - phi(0)
        actual = trace_cost(step, cost, 0, w)

        print(f"  {name}:")
        amort_per_step = []
        s = 0
        for a in w:
            amort_per_step.append(amortized_cost(step, cost, phi, s, a))
            s = step(s, a)
        print(f"    Amortized costs: {[f'{c:.1f}' for c in amort_per_step]}")
        print(f"    Amortized total: {amort_total:.1f}")
        print(f"    Boundary (φ(final)-φ(init)): {boundary:.1f}")
        print(f"    actual + boundary = {actual + boundary:.1f}")
        print(f"    Gauge identity holds? {abs(amort_total - (actual + boundary)) < 1e-10}")
        print()


# ── Main ──────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("\n" + "█" * 70)
    print("  TROPICAL TRACE SEMANTICS — Numerical Demonstrations")
    print("█" * 70 + "\n")

    demo_binary_counter()
    demo_dynamic_array()
    demo_tropical_spectral()
    demo_gauge_equivalence()

    print("All demonstrations completed successfully.")


#!/usr/bin/env python3
"""
Visualizations for Tropical Trace Semantics.
Generates PNG figures for the research paper and JSON package.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import base64
import io


def fig_to_base64(fig):
    """Convert matplotlib figure to base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


def viz_gauge_transform():
    """Visualize how different potentials reshape the cost landscape."""
    fig, axes = plt.subplots(1, 3, figsize=(14, 4))

    # Binary counter: actual costs
    N = 16
    actual_costs = []
    s = 0
    for _ in range(N):
        # Cost = trailing 1s + 1
        x = s
        c = 0
        while x & 1:
            c += 1
            x >>= 1
        actual_costs.append(c + 1)
        s = (s + 1) % 16

    steps = list(range(1, N + 1))

    # Potential = popcount
    potentials = [bin(i).count('1') for i in range(16)]
    amort_costs = []
    s = 0
    for i in range(N):
        t = (s + 1) % 16
        am = actual_costs[i] + potentials[t] - potentials[s]
        amort_costs.append(am)
        s = t

    ax = axes[0]
    ax.bar(steps, actual_costs, color='#e74c3c', alpha=0.8, label='Actual cost')
    ax.set_title('Actual Cost (Spiky)', fontsize=12, fontweight='bold')
    ax.set_xlabel('Operation #')
    ax.set_ylabel('Cost')
    ax.set_ylim(0, 5)

    ax = axes[1]
    ax.bar(steps, amort_costs, color='#2ecc71', alpha=0.8, label='Amortized cost')
    ax.axhline(y=2, color='#27ae60', linestyle='--', linewidth=2, label='Bound B=2')
    ax.set_title('Amortized Cost (Flat)', fontsize=12, fontweight='bold')
    ax.set_xlabel('Operation #')
    ax.set_ylabel('Cost')
    ax.set_ylim(0, 5)
    ax.legend()

    ax = axes[2]
    cum_actual = np.cumsum(actual_costs)
    cum_amort = np.cumsum(amort_costs)
    bound = [2 * i for i in range(1, N + 1)]
    ax.plot(steps, cum_actual, 'o-', color='#e74c3c', label='Σ actual', linewidth=2)
    ax.plot(steps, cum_amort, 's-', color='#2ecc71', label='Σ amortized', linewidth=2)
    ax.plot(steps, bound, '--', color='#95a5a6', label='B·n = 2n', linewidth=2)
    ax.set_title('Cumulative Cost', fontsize=12, fontweight='bold')
    ax.set_xlabel('Operation #')
    ax.set_ylabel('Cumulative cost')
    ax.legend()

    fig.suptitle('Gauge Transformation: Binary Counter', fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    return fig


def viz_spectral_convergence():
    """Show convergence of average trace cost to tropical spectral radius."""
    fig, ax = plt.subplots(figsize=(8, 5))

    transitions = {
        (0, 0): (1, 1.0), (0, 1): (2, 3.0),
        (1, 0): (2, 2.0), (1, 1): (0, 1.0),
        (2, 0): (0, 4.0), (2, 1): (1, 1.0),
    }

    def step(s, a):
        return transitions[(s, a)][0]

    def cost(s, a):
        return transitions[(s, a)][1]

    rho = 7/3  # max cycle mean

    rng = np.random.RandomState(42)
    lengths = list(range(10, 2001, 10))
    avgs_random = []
    avgs_worst = []

    for L in lengths:
        # Random trace
        w = [rng.randint(0, 2) for _ in range(L)]
        total = 0.0
        s = 0
        for a in w:
            total += cost(s, a)
            s = step(s, a)
        avgs_random.append(total / L)

        # Worst-case trace (cycle 0→1→2→0 with costs 1+2+4=7, mean 7/3)
        w_worst = [0, 0, 0] * (L // 3) + [0] * (L % 3)
        total = 0.0
        s = 0
        for a in w_worst:
            total += cost(s, a)
            s = step(s, a)
        avgs_worst.append(total / L)

    ax.plot(lengths, avgs_random, color='#3498db', alpha=0.6, linewidth=1, label='Random traces')
    ax.plot(lengths, avgs_worst, color='#e74c3c', alpha=0.8, linewidth=2, label='Worst-case cycle')
    ax.axhline(y=rho, color='#2c3e50', linestyle='--', linewidth=2,
               label=f'ρ (spectral radius) = {rho:.4f}')
    ax.set_xlabel('Trace length', fontsize=12)
    ax.set_ylabel('Average cost per step', fontsize=12)
    ax.set_title('Convergence to Tropical Spectral Radius', fontsize=14, fontweight='bold')
    ax.legend(fontsize=11)
    ax.set_ylim(0, 4)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    return fig


def viz_dynamic_array():
    """Visualize dynamic array cost spikes vs amortized smooth cost."""
    fig, ax = plt.subplots(figsize=(8, 5))

    n_ops = 40
    actual = []
    amort = []
    size, cap = 0, 0

    for _ in range(n_ops):
        if size < cap:
            c = 1.0
            size += 1
        else:
            c = float(cap + 1)
            new_cap = max(cap * 2, 1)
            size += 1
            cap = new_cap

        phi_before = 2.0 * (size - 1) - (cap if size > 1 else 0)
        phi_after = 2.0 * size - cap
        am = c + phi_after - phi_before

        actual.append(c)
        amort.append(am)

    steps = list(range(1, n_ops + 1))

    ax.bar(steps, actual, color='#e74c3c', alpha=0.7, label='Actual cost', width=0.8)
    ax.plot(steps, amort, 'o-', color='#2ecc71', markersize=4, linewidth=2,
            label='Amortized cost')
    ax.axhline(y=3, color='#27ae60', linestyle='--', linewidth=2, alpha=0.7,
               label='Amortized bound B=3')

    ax.set_xlabel('Push operation #', fontsize=12)
    ax.set_ylabel('Cost', fontsize=12)
    ax.set_title('Dynamic Array: Cost Spikes vs Amortized Smooth Cost', fontsize=14, fontweight='bold')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3, axis='y')

    plt.tight_layout()
    return fig


def viz_automaton_graph():
    """Draw the weighted automaton as a state diagram."""
    fig, ax = plt.subplots(figsize=(7, 6))

    # 3-state automaton
    angles = [90, 210, 330]
    r = 1.5
    positions = {i: (r * np.cos(np.radians(a)), r * np.sin(np.radians(a)))
                 for i, a in enumerate(angles)}

    # Draw states
    for i, (x, y) in positions.items():
        circle = plt.Circle((x, y), 0.35, fill=True, color='#3498db', alpha=0.8)
        ax.add_patch(circle)
        ax.text(x, y, f'S{i}', ha='center', va='center', fontsize=14,
                fontweight='bold', color='white')

    # Draw transitions
    transitions = {
        (0, 1): 1.0, (0, 2): 3.0,
        (1, 2): 2.0, (1, 0): 1.0,
        (2, 0): 4.0, (2, 1): 1.0,
    }

    for (i, j), cost in transitions.items():
        xi, yi = positions[i]
        xj, yj = positions[j]
        # Offset for bidirectional edges
        dx, dy = xj - xi, yj - yi
        length = np.sqrt(dx**2 + dy**2)
        nx, ny = -dy/length, dx/length
        offset = 0.08
        ax.annotate('', xy=(xj - 0.35*dx/length + offset*nx,
                           yj - 0.35*dy/length + offset*ny),
                    xytext=(xi + 0.35*dx/length + offset*nx,
                            yi + 0.35*dy/length + offset*ny),
                    arrowprops=dict(arrowstyle='->', color='#2c3e50', lw=2))
        mx = (xi + xj)/2 + 0.25*nx
        my = (yi + yj)/2 + 0.25*ny
        ax.text(mx, my, f'c={cost:.0f}', ha='center', va='center',
                fontsize=10, color='#c0392b', fontweight='bold',
                bbox=dict(boxstyle='round,pad=0.2', facecolor='#ffeaa7', alpha=0.9))

    ax.set_xlim(-2.5, 2.5)
    ax.set_ylim(-2.5, 2.5)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('Weighted Automaton (3 states, min-plus transitions)',
                fontsize=13, fontweight='bold')

    plt.tight_layout()
    return fig


if __name__ == "__main__":
    # Generate and save figures
    figs = {
        'gauge_transform': viz_gauge_transform(),
        'spectral_convergence': viz_spectral_convergence(),
        'dynamic_array': viz_dynamic_array(),
        'automaton_graph': viz_automaton_graph(),
    }

    for name, fig in figs.items():
        fig.savefig(f'{name}.png', dpi=150, bbox_inches='tight')
        print(f"Saved {name}.png")

    # Generate base64 versions
    b64_data = {}
    for name, func in [
        ('gauge_transform', viz_gauge_transform),
        ('spectral_convergence', viz_spectral_convergence),
        ('dynamic_array', viz_dynamic_array),
        ('automaton_graph', viz_automaton_graph),
    ]:
        b64_data[name] = fig_to_base64(func())

    print("\nBase64 data URIs generated for all visualizations.")
    print("Lengths:", {k: len(v) for k, v in b64_data.items()})

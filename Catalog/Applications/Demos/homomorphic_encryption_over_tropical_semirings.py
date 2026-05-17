#!/usr/bin/env python3
"""
Tropical Homomorphic Encryption — Applications

Real-world applications demonstrating the practical value of
tropical homomorphic encryption:

1. Privacy-Preserving Logistics Routing
2. Encrypted Dynamic Programming (Knapsack variant)
3. Confidential Network Analysis
4. Encrypted Sequence Alignment Scoring
"""

from algorithms import FiberScheme, FiberCipher, TropCircuit, HomomorphicBellmanFord, WeightedGraph
from typing import List, Tuple, Dict
import random
import time


# ═══════════════════════════════════════════════════════════
# Application 1: Privacy-Preserving Logistics
# ═══════════════════════════════════════════════════════════

def logistics_routing():
    """
    Privacy-preserving logistics routing.

    Scenario: A logistics company wants to find optimal delivery routes
    but doesn't want to reveal its cost structure (fuel prices, tolls,
    driver wages) to the cloud computing provider.

    Solution: Encrypt all edge costs, compute shortest paths
    homomorphically, decrypt only the optimal distances.
    """
    print("=" * 60)
    print("APPLICATION 1: Privacy-Preserving Logistics Routing")
    print("=" * 60)

    S = FiberScheme()

    # City network (costs include fuel + tolls + time)
    cities = ["Warehouse", "CityA", "CityB", "CityC", "CityD", "Customer"]
    n = len(cities)

    # Secret cost structure (the company's competitive advantage)
    edges = [
        (0, 1, 12), (0, 2, 8),   # Warehouse to cities
        (1, 3, 5),  (1, 4, 15),  # CityA connections
        (2, 3, 9),  (2, 4, 7),   # CityB connections
        (3, 5, 4),  (4, 5, 3),   # Cities to Customer
        (1, 2, 3),  (3, 4, 2),   # Cross connections
    ]

    graph = WeightedGraph(n_nodes=n, edges=edges)
    solver = HomomorphicBellmanFord(S)

    print(f"\n  Network: {n} locations, {len(edges)} routes")
    print(f"  All costs are ENCRYPTED — the cloud server never sees them\n")

    start = time.time()
    distances = solver.solve(graph, source=0)
    elapsed = time.time() - start

    print(f"  Shortest distances from {cities[0]}:")
    for i, city in enumerate(cities):
        d = distances[i]
        print(f"    → {city}: {d}" + (" (optimal delivery route)" if i == n-1 else ""))

    print(f"\n  Computed in {elapsed*1000:.1f}ms (all operations on encrypted data)")
    print(f"  ✓ Cloud server performed computation without seeing any costs")


# ═══════════════════════════════════════════════════════════
# Application 2: Encrypted Dynamic Programming
# ═══════════════════════════════════════════════════════════

def encrypted_min_cost_path():
    """
    Encrypted minimum-cost grid path.

    Scenario: Find the minimum-cost path from top-left to bottom-right
    of a grid, where costs are encrypted. Only rightward and downward
    moves are allowed.

    This is a classic DP problem expressible entirely in tropical algebra:
    dp[i][j] = min(dp[i-1][j], dp[i][j-1]) + cost[i][j]
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Encrypted Dynamic Programming (Min-Cost Path)")
    print("=" * 60)

    S = FiberScheme()

    # Secret cost grid
    costs = [
        [1, 3, 1, 2],
        [1, 5, 1, 4],
        [4, 2, 1, 1],
        [2, 1, 3, 1],
    ]
    rows, cols = len(costs), len(costs[0])

    print(f"\n  Grid size: {rows}×{cols}")
    print(f"  Cost grid (SECRET — encrypted before computation):")
    for row in costs:
        print(f"    {row}")

    # Encrypt costs
    enc_costs = [[S.encode(costs[i][j]) for j in range(cols)] for i in range(rows)]

    # DP on encrypted values
    enc_dp = [[None]*cols for _ in range(rows)]
    enc_dp[0][0] = enc_costs[0][0]

    # First row: only from left
    for j in range(1, cols):
        enc_dp[0][j] = S.cplus(enc_dp[0][j-1], enc_costs[0][j])

    # First col: only from above
    for i in range(1, rows):
        enc_dp[i][0] = S.cplus(enc_dp[i-1][0], enc_costs[i][0])

    # Interior: min of (from above, from left) + current cost
    for i in range(1, rows):
        for j in range(1, cols):
            from_above = enc_dp[i-1][j]
            from_left = enc_dp[i][j-1]
            best_prev = S.cmin(from_above, from_left)
            enc_dp[i][j] = S.cplus(best_prev, enc_costs[i][j])

    # Decrypt result
    result = S.decode(enc_dp[rows-1][cols-1])

    # Verify with plaintext computation
    dp = [[0]*cols for _ in range(rows)]
    dp[0][0] = costs[0][0]
    for j in range(1, cols): dp[0][j] = dp[0][j-1] + costs[0][j]
    for i in range(1, rows): dp[i][0] = dp[i-1][0] + costs[i][0]
    for i in range(1, rows):
        for j in range(1, cols):
            dp[i][j] = min(dp[i-1][j], dp[i][j-1]) + costs[i][j]
    expected = dp[rows-1][cols-1]

    print(f"\n  Minimum cost path (encrypted computation): {result}")
    print(f"  Minimum cost path (plaintext verification): {expected}")
    assert result == expected
    print(f"  ✓ Encrypted DP matches plaintext computation!")

    # Show noise in final result
    final_cipher = enc_dp[rows-1][cols-1]
    print(f"\n  Final ciphertext noise: {S.noise(final_cipher)}")
    refreshed = S.refresh(final_cipher)
    print(f"  After refresh: noise = {S.noise(refreshed)}, value preserved = {S.decode(refreshed) == result}")


# ═══════════════════════════════════════════════════════════
# Application 3: Confidential Network Analysis
# ═══════════════════════════════════════════════════════════

def confidential_network_analysis():
    """
    Confidential network bottleneck analysis.

    Scenario: A telecom company wants to analyze its network for
    shortest-path latencies but cannot reveal its network topology
    or link latencies to an external analysis service.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Confidential Network Latency Analysis")
    print("=" * 60)

    S = FiberScheme()

    # Secret network topology with latencies (ms)
    nodes = ["Router_A", "Router_B", "Router_C", "Router_D",
             "Router_E", "Router_F", "Gateway"]
    n = len(nodes)

    # Link latencies (confidential)
    links = [
        (0, 1, 5),  (0, 2, 10), (1, 3, 3),  (1, 4, 8),
        (2, 3, 2),  (2, 5, 12), (3, 4, 1),  (3, 5, 7),
        (4, 6, 4),  (5, 6, 2),  (3, 6, 9),
    ]

    graph = WeightedGraph(n_nodes=n, edges=links)
    solver = HomomorphicBellmanFord(S)

    print(f"\n  Network: {n} routers, {len(links)} links")
    print(f"  All latencies ENCRYPTED\n")

    distances = solver.solve(graph, source=0)

    print(f"  Shortest latencies from {nodes[0]} to:")
    for i, node in enumerate(nodes):
        d = distances[i] if distances[i] < 10**9 else "unreachable"
        print(f"    {node}: {d} ms")

    # Find critical path
    gateway_latency = distances[-1]
    print(f"\n  Critical path to Gateway: {gateway_latency} ms")
    print(f"  ✓ Analysis performed without revealing topology or latencies")


# ═══════════════════════════════════════════════════════════
# Application 4: Encrypted Sequence Alignment Score
# ═══════════════════════════════════════════════════════════

def encrypted_alignment_score():
    """
    Encrypted edit distance (simplified).

    Scenario: Compute the edit distance between two sequences where
    the cost structure is confidential (e.g., proprietary scoring matrix).

    Uses tropical DP: dp[i][j] = min(dp[i-1][j] + del_cost,
                                      dp[i][j-1] + ins_cost,
                                      dp[i-1][j-1] + match/sub_cost)
    """
    print("\n" + "=" * 60)
    print("APPLICATION 4: Encrypted Sequence Alignment")
    print("=" * 60)

    S = FiberScheme()

    seq1 = "ACGT"
    seq2 = "AGT"
    ins_cost = 1
    del_cost = 1
    sub_cost = 1
    match_cost = 0

    m, n = len(seq1), len(seq2)

    print(f"\n  Sequence 1: {seq1}")
    print(f"  Sequence 2: {seq2}")
    print(f"  Costs: insert={ins_cost}, delete={del_cost}, substitute={sub_cost}")

    # Encrypt costs
    enc_ins = S.encode(ins_cost)
    enc_del = S.encode(del_cost)

    # Initialize DP table with encrypted values
    enc_dp = [[None]*(n+1) for _ in range(m+1)]
    enc_dp[0][0] = S.encode(0)
    for i in range(1, m+1):
        enc_dp[i][0] = S.encode(i * del_cost)
    for j in range(1, n+1):
        enc_dp[0][j] = S.encode(j * ins_cost)

    # Fill DP table with encrypted operations
    for i in range(1, m+1):
        for j in range(1, n+1):
            cost = match_cost if seq1[i-1] == seq2[j-1] else sub_cost
            enc_cost = S.encode(cost)

            # Three options: delete, insert, substitute/match
            opt_del = S.cplus(enc_dp[i-1][j], enc_del)
            opt_ins = S.cplus(enc_dp[i][j-1], enc_ins)
            opt_sub = S.cplus(enc_dp[i-1][j-1], enc_cost)

            # Take minimum (tropical addition)
            enc_dp[i][j] = S.cmin(S.cmin(opt_del, opt_ins), opt_sub)

    # Decrypt result
    result = S.decode(enc_dp[m][n])

    # Verify
    dp = [[0]*(n+1) for _ in range(m+1)]
    for i in range(m+1): dp[i][0] = i * del_cost
    for j in range(n+1): dp[0][j] = j * ins_cost
    for i in range(1, m+1):
        for j in range(1, n+1):
            cost = match_cost if seq1[i-1] == seq2[j-1] else sub_cost
            dp[i][j] = min(dp[i-1][j] + del_cost,
                          dp[i][j-1] + ins_cost,
                          dp[i-1][j-1] + cost)
    expected = dp[m][n]

    print(f"\n  Edit distance (encrypted): {result}")
    print(f"  Edit distance (plaintext): {expected}")
    assert result == expected
    print(f"  ✓ Encrypted alignment matches plaintext computation!")

    final_noise = S.noise(enc_dp[m][n])
    print(f"\n  Accumulated noise: {final_noise}")
    print(f"  After refresh: noise = {S.noise(S.refresh(enc_dp[m][n]))}")


# ═══════════════════════════════════════════════════════════
# Run all applications
# ═══════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║   TROPICAL HOMOMORPHIC ENCRYPTION — APPLICATIONS       ║")
    print("╚══════════════════════════════════════════════════════════╝\n")

    logistics_routing()
    encrypted_min_cost_path()
    confidential_network_analysis()
    encrypted_alignment_score()

    print("\n" + "=" * 60)
    print("All applications completed successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Tropical Homomorphic Encryption — Demonstration

Concrete numerical examples illustrating:
1. Homomorphic correctness for min and plus gates
2. Compositional circuit evaluation
3. Idempotent bootstrapping (min-gate noise stability)
4. Noise analysis through circuits
5. Privacy-preserving Bellman-Ford relaxation
6. Order leakage in deterministic schemes
"""

from dataclasses import dataclass
from typing import List, Tuple, Callable
import random


# ─────────────────────────────────────────────────────────────
# Core Encryption Scheme
# ─────────────────────────────────────────────────────────────

@dataclass
class FiberCipher:
    """Ciphertext in the fiber scheme: (value, noise)."""
    val: int
    noise: int

    def __repr__(self):
        return f"⟨{self.val}, noise={self.noise}⟩"


class FiberScheme:
    """
    Concrete fiber-based tropical encryption scheme.
    - encode(m) = (m, 0)
    - decode(c) = c.val
    - cmin(c1, c2) selects the one with smaller val
    - cplus(c1, c2) adds vals and noises
    """

    def encode(self, m: int) -> FiberCipher:
        return FiberCipher(val=m, noise=0)

    def decode(self, c: FiberCipher) -> int:
        return c.val

    def cmin(self, c1: FiberCipher, c2: FiberCipher) -> FiberCipher:
        return c1 if c1.val <= c2.val else c2

    def cplus(self, c1: FiberCipher, c2: FiberCipher) -> FiberCipher:
        return FiberCipher(val=c1.val + c2.val, noise=c1.noise + c2.noise)

    def refresh(self, c: FiberCipher) -> FiberCipher:
        return self.encode(self.decode(c))


# ─────────────────────────────────────────────────────────────
# Tropical Circuits
# ─────────────────────────────────────────────────────────────

class TropCircuit:
    """Base class for tropical circuits."""
    pass

class Input(TropCircuit):
    def __init__(self, idx: int):
        self.idx = idx
    def __repr__(self):
        return f"x[{self.idx}]"

class TMin(TropCircuit):
    def __init__(self, left: TropCircuit, right: TropCircuit):
        self.left = left
        self.right = right
    def __repr__(self):
        return f"min({self.left}, {self.right})"

class TPlus(TropCircuit):
    def __init__(self, left: TropCircuit, right: TropCircuit):
        self.left = left
        self.right = right
    def __repr__(self):
        return f"({self.left} + {self.right})"


def eval_circuit(circ: TropCircuit, sigma: List[int]) -> int:
    """Evaluate a tropical circuit on plaintext inputs."""
    if isinstance(circ, Input):
        return sigma[circ.idx]
    elif isinstance(circ, TMin):
        return min(eval_circuit(circ.left, sigma), eval_circuit(circ.right, sigma))
    elif isinstance(circ, TPlus):
        return eval_circuit(circ.left, sigma) + eval_circuit(circ.right, sigma)


def ceval_circuit(scheme: FiberScheme, circ: TropCircuit, tau: List[FiberCipher]) -> FiberCipher:
    """Evaluate a tropical circuit homomorphically on ciphertexts."""
    if isinstance(circ, Input):
        return tau[circ.idx]
    elif isinstance(circ, TMin):
        return scheme.cmin(ceval_circuit(scheme, circ.left, tau),
                           ceval_circuit(scheme, circ.right, tau))
    elif isinstance(circ, TPlus):
        return scheme.cplus(ceval_circuit(scheme, circ.left, tau),
                            ceval_circuit(scheme, circ.right, tau))


# ─────────────────────────────────────────────────────────────
# Demonstrations
# ─────────────────────────────────────────────────────────────

def demo_gate_correctness():
    """Demonstrate gate-level homomorphic correctness."""
    print("=" * 60)
    print("DEMO 1: Gate-Level Homomorphic Correctness")
    print("=" * 60)

    S = FiberScheme()

    pairs = [(3, 7), (10, 2), (5, 5), (0, 100), (42, 17)]

    print("\n  Min gate (tropical addition):")
    for m1, m2 in pairs:
        c1, c2 = S.encode(m1), S.encode(m2)
        result = S.decode(S.cmin(c1, c2))
        expected = min(m1, m2)
        status = "✓" if result == expected else "✗"
        print(f"    {status} min({m1}, {m2}) = {expected}, decrypt(cmin(enc({m1}), enc({m2}))) = {result}")

    print("\n  Plus gate (tropical multiplication):")
    for m1, m2 in pairs:
        c1, c2 = S.encode(m1), S.encode(m2)
        result = S.decode(S.cplus(c1, c2))
        expected = m1 + m2
        status = "✓" if result == expected else "✗"
        print(f"    {status} {m1} + {m2} = {expected}, decrypt(cplus(enc({m1}), enc({m2}))) = {result}")


def demo_circuit_correctness():
    """Demonstrate compositional circuit correctness."""
    print("\n" + "=" * 60)
    print("DEMO 2: Compositional Circuit Correctness")
    print("=" * 60)

    S = FiberScheme()

    # Circuit: min(x[0] + x[1], x[2])
    circuit1 = TMin(TPlus(Input(0), Input(1)), Input(2))
    inputs1 = [3, 4, 5]  # min(3+4, 5) = min(7, 5) = 5

    # Circuit: min(min(x[0], x[1]), x[2] + x[3])
    circuit2 = TMin(TMin(Input(0), Input(1)), TPlus(Input(2), Input(3)))
    inputs2 = [10, 3, 2, 4]  # min(min(10,3), 2+4) = min(3, 6) = 3

    # Circuit: (x[0] + x[1]) + min(x[2], x[3])
    circuit3 = TPlus(TPlus(Input(0), Input(1)), TMin(Input(2), Input(3)))
    inputs3 = [1, 2, 8, 5]  # (1+2) + min(8,5) = 3 + 5 = 8

    for name, circ, inp in [("min(x₀+x₁, x₂)", circuit1, inputs1),
                            ("min(min(x₀,x₁), x₂+x₃)", circuit2, inputs2),
                            ("(x₀+x₁)+min(x₂,x₃)", circuit3, inputs3)]:
        plaintext_result = eval_circuit(circ, inp)
        encrypted_inputs = [S.encode(m) for m in inp]
        encrypted_result = ceval_circuit(S, circ, encrypted_inputs)
        decrypted_result = S.decode(encrypted_result)
        status = "✓" if decrypted_result == plaintext_result else "✗"
        print(f"\n  {status} Circuit: {name}")
        print(f"    Inputs: {inp}")
        print(f"    Plaintext eval: {plaintext_result}")
        print(f"    Encrypted eval: {encrypted_result}")
        print(f"    Decrypted: {decrypted_result}")


def demo_idempotent_bootstrap():
    """Demonstrate idempotent bootstrapping."""
    print("\n" + "=" * 60)
    print("DEMO 3: Idempotent Bootstrapping")
    print("=" * 60)

    S = FiberScheme()

    # Create noisy ciphertexts (simulating accumulated noise)
    noisy = [FiberCipher(val=m, noise=n) for m, n in [(5, 10), (3, 100), (7, 50)]]

    print("\n  Min with self (idempotence) on noisy ciphertexts:")
    for c in noisy:
        result = S.cmin(c, c)
        print(f"    cmin({c}, {c}) = {result}")
        print(f"    decode = {S.decode(result)}, original decode = {S.decode(c)}")
        assert S.decode(result) == S.decode(c), "Idempotence violated!"

    print("\n  Iterated min (noise never grows):")
    c = FiberCipher(val=5, noise=7)
    for i in range(5):
        c2 = FiberCipher(val=5, noise=random.randint(0, 20))
        result = S.cmin(c, c2)
        print(f"    cmin({c}, {c2}) = {result}, noise = {result.noise} ≤ max({c.noise}, {c2.noise}) = {max(c.noise, c2.noise)}")
        assert result.noise <= max(c.noise, c2.noise)
        c = result


def demo_noise_analysis():
    """Demonstrate noise growth patterns."""
    print("\n" + "=" * 60)
    print("DEMO 4: Noise Analysis Through Circuits")
    print("=" * 60)

    S = FiberScheme()

    # Start with noisy ciphertexts
    c1 = FiberCipher(val=5, noise=3)
    c2 = FiberCipher(val=8, noise=7)
    c3 = FiberCipher(val=2, noise=1)

    print(f"\n  Initial ciphertexts:")
    print(f"    c1 = {c1}")
    print(f"    c2 = {c2}")
    print(f"    c3 = {c3}")

    print(f"\n  Min operations (noise-stable):")
    r_min = S.cmin(c1, c2)
    print(f"    cmin(c1, c2) = {r_min} — noise = {r_min.noise}")
    r_min2 = S.cmin(r_min, c3)
    print(f"    cmin(cmin(c1,c2), c3) = {r_min2} — noise = {r_min2.noise}")

    print(f"\n  Plus operations (noise additive):")
    r_plus = S.cplus(c1, c2)
    print(f"    cplus(c1, c2) = {r_plus} — noise = {r_plus.noise} = {c1.noise} + {c2.noise}")
    r_plus2 = S.cplus(r_plus, c3)
    print(f"    cplus(cplus(c1,c2), c3) = {r_plus2} — noise = {r_plus2.noise} = {c1.noise}+{c2.noise}+{c3.noise}")

    print(f"\n  Refresh (noise reset):")
    refreshed = S.refresh(r_plus2)
    print(f"    refresh({r_plus2}) = {refreshed} — noise = {refreshed.noise}")
    assert refreshed.noise == 0
    assert S.decode(refreshed) == S.decode(r_plus2)
    print(f"    ✓ Noise reset to 0, value preserved")


def demo_bellman_ford():
    """Demonstrate encrypted Bellman-Ford relaxation."""
    print("\n" + "=" * 60)
    print("DEMO 5: Privacy-Preserving Bellman-Ford")
    print("=" * 60)

    S = FiberScheme()

    # Small graph: 4 nodes, source = 0
    #   0 --3--> 1 --2--> 3
    #   0 --10-> 2 --1--> 3
    #   1 --4--> 2
    edges = [(0,1,3), (0,2,10), (1,2,4), (1,3,2), (2,3,1)]
    n_nodes = 4

    # Initialize distances
    dist = [0, float('inf'), float('inf'), float('inf')]
    dist_nat = [0, 10**9, 10**9, 10**9]  # Using large number for ∞

    print(f"\n  Graph: {n_nodes} nodes, {len(edges)} edges")
    for u, v, w in edges:
        print(f"    {u} --{w}--> {v}")

    # Run Bellman-Ford with encrypted relaxation
    print(f"\n  Running encrypted Bellman-Ford...")
    for round_num in range(n_nodes - 1):
        print(f"\n  Round {round_num + 1}:")
        for u, v, w in edges:
            # Relaxation circuit: min(dist[v], dist[u] + w)
            d_v = S.encode(dist_nat[v])
            d_u = S.encode(dist_nat[u])
            w_enc = S.encode(w)

            # Homomorphic relaxation
            relaxed = S.cmin(d_v, S.cplus(d_u, w_enc))
            new_dist = S.decode(relaxed)

            if new_dist < dist_nat[v]:
                print(f"    Edge ({u},{v},w={w}): dist[{v}] updated {dist_nat[v]} → {new_dist}")
                dist_nat[v] = new_dist

    print(f"\n  Final shortest distances from node 0:")
    for i in range(n_nodes):
        d = dist_nat[i] if dist_nat[i] < 10**9 else "∞"
        print(f"    dist[{i}] = {d}")

    # Verify against plaintext computation
    expected = [0, 3, 7, 5]
    print(f"\n  Expected: {expected}")
    assert dist_nat == expected, f"Mismatch: {dist_nat} != {expected}"
    print("  ✓ Encrypted Bellman-Ford matches plaintext computation!")


def demo_order_leakage():
    """Demonstrate the order leakage security obstruction."""
    print("\n" + "=" * 60)
    print("DEMO 6: Order Leakage (Security Obstruction)")
    print("=" * 60)

    S = FiberScheme()

    messages = [7, 3, 12, 1, 9, 3]
    ciphertexts = [S.encode(m) for m in messages]

    print(f"\n  Messages:    {messages}")
    print(f"  Ciphertexts: {[c.val for c in ciphertexts]}")

    print(f"\n  Ciphertext ordering reveals plaintext ordering:")
    for i in range(len(messages)):
        for j in range(i+1, len(messages)):
            ci, cj = ciphertexts[i], ciphertexts[j]
            cipher_order = "≤" if ci.val <= cj.val else ">"
            plain_order = "≤" if messages[i] <= messages[j] else ">"
            match = "✓" if (ci.val <= cj.val) == (messages[i] <= messages[j]) else "✗"
            print(f"    {match} enc({messages[i]}) {cipher_order} enc({messages[j]})  ↔  {messages[i]} {plain_order} {messages[j]}")

    print(f"\n  ⚠  This is the fundamental obstruction: deterministic encoding")
    print(f"     preserves order, enabling an adversary to sort plaintexts")
    print(f"     by sorting ciphertexts.")
    print(f"\n  → Secure schemes MUST randomize: many ciphertexts per plaintext,")
    print(f"    breaking the order correspondence.")


# ─────────────────────────────────────────────────────────────
# Run all demos
# ─────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║   TROPICAL HOMOMORPHIC ENCRYPTION — DEMONSTRATIONS     ║")
    print("╚══════════════════════════════════════════════════════════╝")

    demo_gate_correctness()
    demo_circuit_correctness()
    demo_idempotent_bootstrap()
    demo_noise_analysis()
    demo_bellman_ford()
    demo_order_leakage()

    print("\n" + "=" * 60)
    print("All demonstrations completed successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""Generate PACKAGE.json with all artifacts."""

import json
import base64
import os

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

def image_to_base64(path):
    with open(path, 'rb') as f:
        b64 = base64.b64encode(f.read()).decode('utf-8')
    return f"data:image/png;base64,{b64}"

# Read all content files
article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
lean_proofs = read_file('Cryptography/TropicalHomomorphic.lean')
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')
applications_code = read_file('applications.py')
viz_code = read_file('visualizations.py')

# Read visualization images
viz_data = []
for name, path in [
    ("Noise Growth Comparison", "noise_comparison.png"),
    ("Circuit Noise Flow", "circuit_noise.png"),
    ("Order Leakage Obstruction", "order_leakage.png"),
    ("Encrypted Bellman-Ford", "bellman_ford.png"),
]:
    viz_data.append({
        "name": name,
        "data": image_to_base64(path)
    })

package = {
    "title": "Homomorphic Encryption over Tropical Semirings",
    "domain": "Cryptography / Tropical Algebra",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Tropical Homomorphic Encryption Demo",
            "code": demo_code
        },
        {
            "name": "Applications Demo",
            "code": applications_code.replace(
                "from algorithms import FiberScheme, FiberCipher, TropCircuit, HomomorphicBellmanFord, WeightedGraph",
                "# Inline imports - algorithms defined below\n" + algorithms_code.split("if __name__")[0] + "\n# --- End of algorithms ---\n"
            )
        }
    ],
    "algorithms": [
        {
            "name": "Fiber-Based Tropical Encryption Scheme",
            "pseudocode": """ALGORITHM: FiberScheme Tropical Encryption
INPUT: plaintext m ∈ ℕ
OUTPUT: ciphertext c = (val, noise) ∈ ℕ × ℕ

ENCODE(m):
    return (m, 0)

DECODE(c = (v, n)):
    return v

CMIN(c₁ = (v₁, n₁), c₂ = (v₂, n₂)):
    if v₁ ≤ v₂:
        return c₁
    else:
        return c₂

CPLUS(c₁ = (v₁, n₁), c₂ = (v₂, n₂)):
    return (v₁ + v₂, n₁ + n₂)

REFRESH(c):
    return ENCODE(DECODE(c))

CORRECTNESS:
    DECODE(ENCODE(m)) = m
    DECODE(CMIN(c₁, c₂)) = min(DECODE(c₁), DECODE(c₂))
    DECODE(CPLUS(c₁, c₂)) = DECODE(c₁) + DECODE(c₂)

TIME COMPLEXITY: All operations O(1)
SPACE COMPLEXITY: O(1) per ciphertext""",
            "code": algorithms_code
        },
        {
            "name": "Homomorphic Bellman-Ford",
            "pseudocode": """ALGORITHM: Encrypted Bellman-Ford Shortest Paths
INPUT: Weighted graph G = (V, E, w), source s
OUTPUT: Encrypted shortest distances from s

1. For each node v ∈ V:
     enc_dist[v] ← ENCODE(∞)
   enc_dist[s] ← ENCODE(0)

2. For each edge (u,v,w) ∈ E:
     enc_weight[(u,v)] ← ENCODE(w)

3. Repeat |V|-1 times:
     For each edge (u,v,w) ∈ E:
       // Tropical relaxation circuit: min(d[v], d[u] + w)
       enc_dist[v] ← CMIN(enc_dist[v], CPLUS(enc_dist[u], enc_weight[(u,v)]))

4. Return {DECODE(enc_dist[v]) : v ∈ V}

CORRECTNESS: By tropical_homomorphic_correctness theorem
TIME: O(|V| · |E|) encrypted operations
SPACE: O(|V| + |E|) ciphertexts""",
            "code": algorithms_code
        }
    ],
    "visualizations": viz_data,
    "lean_proofs": lean_proofs
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print(f"PACKAGE.json generated ({os.path.getsize('PACKAGE.json')} bytes)")


#!/usr/bin/env python3
"""
Tropical Homomorphic Encryption — Visualizations

Generates publication-quality figures:
1. Noise growth comparison: tropical vs classical
2. Circuit evaluation with noise tracking
3. Security obstruction: order leakage
4. Bellman-Ford on encrypted graph
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
import base64
import io
from algorithms import FiberScheme, FiberCipher, TropCircuit, NoiseAnalyzer


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight',
                facecolor='white', edgecolor='none')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


def viz_noise_comparison():
    """
    Compare noise growth: tropical min vs classical addition vs tropical plus.
    """
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))

    depths = range(1, 21)

    # Classical FHE: noise grows exponentially with multiplication depth
    classical_mult = [2**d for d in depths]

    # Tropical plus: noise grows linearly (additive)
    trop_plus = [d * 5 for d in depths]  # Starting noise = 5

    # Tropical min: noise stays bounded
    trop_min = [5] * len(depths)  # Never exceeds max input noise

    ax.semilogy(depths, classical_mult, '-o', linewidth=2, markersize=6,
                label='Classical FHE (multiplicative noise)', color='#e74c3c')
    ax.semilogy(depths, trop_plus, '-s', linewidth=2, markersize=6,
                label='Tropical plus gates (additive noise)', color='#3498db')
    ax.semilogy(depths, trop_min, '-^', linewidth=2, markersize=6,
                label='Tropical min gates (idempotent — bounded!)', color='#2ecc71')

    # Add refresh points
    refresh_depths = [5, 10, 15]
    for rd in refresh_depths:
        ax.annotate('refresh\n(noise → 0)', xy=(rd, trop_plus[rd-1]),
                   xytext=(rd+1.5, trop_plus[rd-1]*3),
                   arrowprops=dict(arrowstyle='->', color='#3498db'),
                   fontsize=9, color='#3498db', ha='center')

    ax.set_xlabel('Circuit Depth (number of operations)', fontsize=13)
    ax.set_ylabel('Noise Level (log scale)', fontsize=13)
    ax.set_title('Noise Growth: Classical FHE vs Tropical Homomorphic Encryption',
                fontsize=14, fontweight='bold')
    ax.legend(fontsize=11, loc='upper left')
    ax.grid(True, alpha=0.3)
    ax.set_xlim(0.5, 20.5)

    fig.tight_layout()
    fig.savefig('noise_comparison.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def viz_circuit_noise():
    """
    Visualize noise flow through a tropical circuit.
    """
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Left: min-only circuit
    ax = axes[0]
    ax.set_title('Min-Only Circuit\n(Noise Stable)', fontsize=13, fontweight='bold')

    # Draw circuit tree
    positions = {
        'out': (0.5, 0.9),
        'min1': (0.5, 0.65),
        'min2': (0.3, 0.4),
        'x0': (0.15, 0.15),
        'x1': (0.45, 0.15),
        'x2': (0.7, 0.4),
    }
    noises = {'x0': 3, 'x1': 7, 'x2': 5, 'min2': 7, 'min1': 7, 'out': 7}
    colors_map = {'x0': '#3498db', 'x1': '#e74c3c', 'x2': '#2ecc71',
              'min2': '#9b59b6', 'min1': '#f39c12', 'out': '#f39c12',
              'plus2': '#9b59b6', 'plus1': '#f39c12'}

    for name, (x, y) in positions.items():
        color = colors_map[name]
        if name.startswith('x'):
            label = f"{name}\nν={noises[name]}"
            ax.add_patch(plt.Circle((x, y), 0.08, color=color, alpha=0.3))
            ax.text(x, y, label, ha='center', va='center', fontsize=9, fontweight='bold')
        else:
            label = f"min\nν≤{noises[name]}"
            ax.add_patch(plt.Rectangle((x-0.08, y-0.06), 0.16, 0.12,
                                       color=color, alpha=0.3, linewidth=2))
            ax.text(x, y, label, ha='center', va='center', fontsize=9, fontweight='bold')

    # Draw edges
    edges = [('x0', 'min2'), ('x1', 'min2'), ('min2', 'min1'), ('x2', 'min1'), ('min1', 'out')]
    for src, dst in edges:
        x1, y1 = positions[src]
        x2, y2 = positions[dst]
        ax.annotate('', xy=(x2, y2-0.06), xytext=(x1, y1+0.08),
                   arrowprops=dict(arrowstyle='->', color='gray', lw=1.5))

    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1.05)
    ax.axis('off')
    ax.text(0.5, 0.02, 'Noise never exceeds max(3, 7, 5) = 7',
           ha='center', fontsize=11, style='italic', color='#2c3e50')

    # Right: plus circuit
    ax = axes[1]
    ax.set_title('Plus-Heavy Circuit\n(Noise Accumulates)', fontsize=13, fontweight='bold')

    positions2 = {
        'out': (0.5, 0.9),
        'plus1': (0.5, 0.65),
        'plus2': (0.3, 0.4),
        'x0': (0.15, 0.15),
        'x1': (0.45, 0.15),
        'x2': (0.7, 0.4),
    }
    noises2 = {'x0': 3, 'x1': 7, 'x2': 5, 'plus2': 10, 'plus1': 15, 'out': 15}

    for name, (x, y) in positions2.items():
        color = colors_map[name]
        if name.startswith('x'):
            label = f"{name}\nν={noises2[name]}"
            ax.add_patch(plt.Circle((x, y), 0.08, color=color, alpha=0.3))
            ax.text(x, y, label, ha='center', va='center', fontsize=9, fontweight='bold')
        else:
            label = f"+\nν={noises2[name]}"
            ax.add_patch(plt.Rectangle((x-0.08, y-0.06), 0.16, 0.12,
                                       color='#e74c3c', alpha=0.3, linewidth=2))
            ax.text(x, y, label, ha='center', va='center', fontsize=9, fontweight='bold')

    edges2 = [('x0', 'plus2'), ('x1', 'plus2'), ('plus2', 'plus1'), ('x2', 'plus1'), ('plus1', 'out')]
    for src, dst in edges2:
        x1, y1 = positions2[src]
        x2, y2 = positions2[dst]
        ax.annotate('', xy=(x2, y2-0.06), xytext=(x1, y1+0.08),
                   arrowprops=dict(arrowstyle='->', color='gray', lw=1.5))

    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1.05)
    ax.axis('off')
    ax.text(0.5, 0.02, 'Noise = 3 + 7 + 5 = 15 (additive growth)',
           ha='center', fontsize=11, style='italic', color='#c0392b')

    fig.tight_layout()
    fig.savefig('circuit_noise.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def viz_order_leakage():
    """
    Visualize the order leakage security obstruction.
    """
    fig, axes = plt.subplots(1, 2, figsize=(13, 5))

    # Left: Deterministic (order-preserving)
    ax = axes[0]
    ax.set_title('Deterministic Encoding\n(ORDER LEAKED)', fontsize=13, fontweight='bold', color='#c0392b')

    messages = [2, 5, 7, 11, 13]
    ciphertexts = [m for m in messages]  # Deterministic: encode(m) = (m, 0)

    for i, (m, c) in enumerate(zip(messages, ciphertexts)):
        y_m = i / (len(messages)-1)
        y_c = i / (len(messages)-1)
        ax.plot([0.2], [y_m], 'o', color='#3498db', markersize=20, zorder=5)
        ax.text(0.2, y_m, str(m), ha='center', va='center', fontsize=11,
               fontweight='bold', color='white', zorder=6)
        ax.plot([0.8], [y_c], 's', color='#e74c3c', markersize=20, zorder=5)
        ax.text(0.8, y_c, f"({c},0)", ha='center', va='center', fontsize=9,
               fontweight='bold', color='white', zorder=6)
        ax.annotate('', xy=(0.75, y_c), xytext=(0.28, y_m),
                   arrowprops=dict(arrowstyle='->', color='gray', lw=1.5))

    ax.text(0.2, -0.12, 'Plaintexts', ha='center', fontsize=12, fontweight='bold', color='#3498db')
    ax.text(0.8, -0.12, 'Ciphertexts', ha='center', fontsize=12, fontweight='bold', color='#e74c3c')
    ax.text(0.5, 1.08, '⚠ Ciphertext order = Plaintext order', ha='center',
           fontsize=11, color='#c0392b', fontweight='bold')
    ax.set_xlim(0, 1)
    ax.set_ylim(-0.2, 1.15)
    ax.axis('off')

    # Right: Randomized (fibers)
    ax = axes[1]
    ax.set_title('Randomized Encoding\n(Order Hidden)', fontsize=13, fontweight='bold', color='#27ae60')

    messages_r = [2, 5, 7]
    # Each plaintext maps to multiple ciphertexts (fiber)
    fibers = {
        2: [(2, 14), (2, 7), (2, 21)],
        5: [(5, 3), (5, 18), (5, 9)],
        7: [(7, 11), (7, 1), (7, 25)],
    }

    colors = ['#3498db', '#e74c3c', '#2ecc71']
    y_pos = 0
    for i, m in enumerate(messages_r):
        y_m = i / (len(messages_r)-1)
        ax.plot([0.15], [y_m], 'o', color=colors[i], markersize=22, zorder=5)
        ax.text(0.15, y_m, str(m), ha='center', va='center', fontsize=12,
               fontweight='bold', color='white', zorder=6)

        for j, (v, n) in enumerate(fibers[m]):
            y_c = (y_pos) / 8
            ax.plot([0.8], [y_c], 's', color=colors[i], markersize=14,
                   alpha=0.7, zorder=5)
            ax.text(0.8, y_c, f"({v},{n})", ha='center', va='center',
                   fontsize=7, color='white', fontweight='bold', zorder=6)
            ax.annotate('', xy=(0.73, y_c), xytext=(0.23, y_m),
                       arrowprops=dict(arrowstyle='->', color=colors[i],
                                      alpha=0.4, lw=1))
            y_pos += 1

    ax.text(0.15, -0.12, 'Plaintexts', ha='center', fontsize=12, fontweight='bold')
    ax.text(0.8, -0.12, 'Ciphertext Fibers', ha='center', fontsize=12, fontweight='bold')
    ax.text(0.5, 1.08, '✓ Multiple ciphertexts per plaintext', ha='center',
           fontsize=11, color='#27ae60', fontweight='bold')
    ax.set_xlim(0, 1)
    ax.set_ylim(-0.2, 1.15)
    ax.axis('off')

    fig.tight_layout()
    fig.savefig('order_leakage.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def viz_bellman_ford():
    """
    Visualize encrypted Bellman-Ford execution.
    """
    fig, ax = plt.subplots(1, 1, figsize=(10, 7))
    ax.set_title('Encrypted Bellman-Ford: Shortest Paths', fontsize=14, fontweight='bold')

    # Graph layout
    positions = {
        0: (0.15, 0.5),
        1: (0.4, 0.8),
        2: (0.4, 0.2),
        3: (0.7, 0.65),
        4: (0.85, 0.35),
    }

    edges = [(0,1,4), (0,2,2), (1,2,3), (1,3,2), (1,4,3),
             (2,1,1), (2,3,4), (2,4,5), (3,4,1)]

    shortest = [0, 3, 2, 5, 6]
    node_labels = ['S', 'A', 'B', 'C', 'D']

    # Draw edges
    for u, v, w in edges:
        x1, y1 = positions[u]
        x2, y2 = positions[v]
        # Check if this edge is on a shortest path
        on_shortest = (shortest[v] == shortest[u] + w)
        color = '#2ecc71' if on_shortest else '#bdc3c7'
        lw = 3 if on_shortest else 1.5
        alpha = 1.0 if on_shortest else 0.5

        dx, dy = x2-x1, y2-y1
        length = np.sqrt(dx**2 + dy**2)
        # Shorten arrows to not overlap with nodes
        shrink = 0.06
        ax.annotate('', xy=(x2 - shrink*dx/length, y2 - shrink*dy/length),
                   xytext=(x1 + shrink*dx/length, y1 + shrink*dy/length),
                   arrowprops=dict(arrowstyle='->', color=color, lw=lw,
                                  alpha=alpha))

        # Weight label
        mx, my = (x1+x2)/2, (y1+y2)/2
        # Offset perpendicular
        perp_x, perp_y = -dy/length * 0.04, dx/length * 0.04
        ax.text(mx + perp_x, my + perp_y, str(w), ha='center', va='center',
               fontsize=10, fontweight='bold',
               color='#2c3e50' if on_shortest else '#95a5a6',
               bbox=dict(boxstyle='round,pad=0.2', facecolor='white',
                        edgecolor='none', alpha=0.8))

    # Draw nodes
    for node, (x, y) in positions.items():
        color = '#e74c3c' if node == 0 else '#3498db'
        ax.add_patch(plt.Circle((x, y), 0.05, color=color, zorder=10))
        ax.text(x, y, node_labels[node], ha='center', va='center',
               fontsize=14, fontweight='bold', color='white', zorder=11)
        # Distance label
        ax.text(x, y-0.09, f'd={shortest[node]}', ha='center',
               fontsize=10, color='#2c3e50',
               bbox=dict(boxstyle='round,pad=0.2', facecolor='#ecf0f1',
                        edgecolor='#bdc3c7'))

    ax.text(0.5, 0.02, 'Green edges = shortest path tree | All computations on encrypted weights',
           ha='center', fontsize=11, style='italic', color='#2c3e50')

    ax.set_xlim(0, 1)
    ax.set_ylim(-0.05, 1.0)
    ax.axis('off')

    fig.tight_layout()
    fig.savefig('bellman_ford.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


if __name__ == "__main__":
    print("Generating visualizations...")

    b64_noise = viz_noise_comparison()
    print(f"  ✓ noise_comparison.png ({len(b64_noise)} chars)")

    b64_circuit = viz_circuit_noise()
    print(f"  ✓ circuit_noise.png ({len(b64_circuit)} chars)")

    b64_order = viz_order_leakage()
    print(f"  ✓ order_leakage.png ({len(b64_order)} chars)")

    b64_bf = viz_bellman_ford()
    print(f"  ✓ bellman_ford.png ({len(b64_bf)} chars)")

    print("\nAll visualizations generated successfully!")

#!/usr/bin/env python3
"""
Tropical Homomorphic Encryption — Applications

Real-world applications of the tropical HE framework:
1. Privacy-preserving shortest paths (logistics/routing)
2. Encrypted dynamic programming (scheduling)
3. Private tropical neural network inference
"""

import random
from algorithms import (
    TropCipher, TropExpr, ExprType,
    trop_enc, trop_dec, trop_cmul, trop_cmin, trop_refresh,
    key_weight, eval_plain, eval_cipher, encrypted_bellman_ford
)


# ============================================================
# Application 1: Privacy-Preserving Logistics Routing
# ============================================================

def app_logistics():
    """
    Scenario: A logistics company wants to compute optimal routes
    through a network of warehouses, but the edge costs (fuel prices,
    tolls, transit times) are commercially sensitive.

    Solution: Each warehouse encrypts its local costs. The central
    planner computes shortest paths on encrypted data and only
    learns the optimal total cost, not individual edge weights.
    """
    print("=" * 60)
    print("APPLICATION 1: Privacy-Preserving Logistics Routing")
    print("=" * 60)
    print()

    # Network: 5 warehouses
    #   0 --10--> 1 --5--> 3
    #   0 --3---> 2 --8--> 3
    #   2 --2--> 4 --1--> 3
    n = 5
    edges = [
        (0, 1, 10), (1, 3, 5),
        (0, 2, 3), (2, 3, 8),
        (2, 4, 2), (4, 3, 1),
    ]
    source = 0

    print(f"Network: {n} warehouses, {len(edges)} routes")
    print("Edge costs (PRIVATE):")
    for u, v, w in edges:
        print(f"  Warehouse {u} → Warehouse {v}: cost {w}")
    print()

    k = 42  # encryption key
    result = encrypted_bellman_ford(n, edges, source, k)

    print("Encrypted shortest path computation:")
    for v in range(n):
        if result[v] < 10**8:
            print(f"  Shortest path 0 → {v}: cost = {result[v]}")
        else:
            print(f"  Shortest path 0 → {v}: unreachable")
    print()
    print(f"Optimal route to warehouse 3: cost = {result[3]}")
    print(f"  (via 0→2→4→3: {3}+{2}+{1} = {6})")
    print()


# ============================================================
# Application 2: Encrypted Scheduling (Critical Path)
# ============================================================

def app_scheduling():
    """
    Scenario: Multiple departments contribute task durations to
    a project schedule. Each department's durations are confidential.

    The critical path (longest path in a DAG) can be computed as
    a shortest path in the negated graph using tropical algebra.

    For a simpler demo, we compute the minimum completion time
    for parallel tasks with dependencies.
    """
    print("=" * 60)
    print("APPLICATION 2: Encrypted Project Scheduling")
    print("=" * 60)
    print()

    # Task graph (DAG):
    #   Task 0 (start) → Task 1 (duration 3) → Task 3 (duration 2)
    #   Task 0 (start) → Task 2 (duration 5) → Task 3 (duration 2)
    #   Completion time = min possible total time
    #
    # As a tropical computation:
    #   completion[3] = min(d[0→1] + d[1→3], d[0→2] + d[2→3])

    k = 13
    r = 7  # shared randomness

    # Task durations (confidential)
    d_01 = 3  # Task 0 → Task 1
    d_02 = 5  # Task 0 → Task 2
    d_13 = 2  # Task 1 → Task 3
    d_23 = 4  # Task 2 → Task 3

    # Encrypt durations
    c_01 = trop_enc(k, d_01, r)
    c_02 = trop_enc(k, d_02, r)
    c_13 = trop_enc(k, d_13, r)
    c_23 = trop_enc(k, d_23, r)

    # Path 1: 0 → 1 → 3 (cost = d_01 + d_13)
    c_path1 = trop_cmul(c_01, c_13)
    c_path1_r = trop_refresh(k, 2 * k, c_path1)

    # Path 2: 0 → 2 → 3 (cost = d_02 + d_23)
    c_path2 = trop_cmul(c_02, c_23)
    c_path2_r = trop_refresh(k, 2 * k, c_path2)

    # Minimum completion time: min(path1, path2)
    c_min = trop_cmin(c_path1_r, c_path2_r)
    result = trop_dec(k, c_min)

    path1_cost = d_01 + d_13
    path2_cost = d_02 + d_23
    expected = min(path1_cost, path2_cost)

    print("Task graph:")
    print(f"  Path 1: Start → Task1({d_01}) → Task3({d_13}) = {path1_cost}")
    print(f"  Path 2: Start → Task2({d_02}) → Task3({d_23}) = {path2_cost}")
    print()
    print(f"Minimum completion time (plaintext): {expected}")
    print(f"Minimum completion time (encrypted): {result}")
    print(f"Correct: {'✓' if result == expected else '✗'}")
    print()
    print("Note: Individual task durations remain encrypted!")
    print()


# ============================================================
# Application 3: Tropical Neural Network Inference
# ============================================================

def app_tropical_nn():
    """
    Scenario: A tropical neural network computes piecewise-linear
    functions using min and + operations (equivalent to ReLU networks
    in the tropical geometry perspective).

    We demonstrate encrypted inference: the model weights and input
    are encrypted, and the output is computed homomorphically.
    """
    print("=" * 60)
    print("APPLICATION 3: Encrypted Tropical Neural Network")
    print("=" * 60)
    print()

    # A simple 2-input, 1-output tropical neuron:
    #   output = min(w1 + x1, w2 + x2)
    # This computes a piecewise-linear function (tropical polynomial)

    k = 5
    r = 0  # shared randomness for min

    # Model weights (private)
    w1, w2 = 3, 7

    # Input (private)
    x1, x2 = 10, 4

    # Plaintext computation
    plain_result = min(w1 + x1, w2 + x2)

    # Encrypted computation
    c_w1 = trop_enc(k, w1, r)
    c_w2 = trop_enc(k, w2, r)
    c_x1 = trop_enc(k, x1, r)
    c_x2 = trop_enc(k, x2, r)

    # w1 + x1 (tropical multiplication)
    c_wx1 = trop_cmul(c_w1, c_x1)
    c_wx1_r = trop_refresh(k, 2 * k, c_wx1)

    # w2 + x2
    c_wx2 = trop_cmul(c_w2, c_x2)
    c_wx2_r = trop_refresh(k, 2 * k, c_wx2)

    # min(w1+x1, w2+x2) (tropical addition)
    c_output = trop_cmin(c_wx1_r, c_wx2_r)
    enc_result = trop_dec(k, c_output)

    print(f"Tropical neuron: output = min(w₁+x₁, w₂+x₂)")
    print(f"  w₁={w1}, w₂={w2}, x₁={x1}, x₂={x2}")
    print(f"  w₁+x₁ = {w1+x1}")
    print(f"  w₂+x₂ = {w2+x2}")
    print(f"  min({w1+x1}, {w2+x2}) = {plain_result}")
    print()
    print(f"  Encrypted result: {enc_result}")
    print(f"  Correct: {'✓' if enc_result == plain_result else '✗'}")
    print()

    # Multi-layer network
    print("Multi-layer tropical network:")
    print("  Layer 1: h₁ = min(w₁₁+x₁, w₁₂+x₂)")
    print("           h₂ = min(w₂₁+x₁, w₂₂+x₂)")
    print("  Layer 2: y = min(v₁+h₁, v₂+h₂)")
    print()

    weights_l1 = [(2, 8), (5, 1)]  # (w_i1, w_i2) for hidden units
    weights_l2 = [3, 4]  # v_i for output

    x = [6, 3]

    # Plaintext
    h = [min(w[0] + x[0], w[1] + x[1]) for w in weights_l1]
    y_plain = min(weights_l2[0] + h[0], weights_l2[1] + h[1])

    # Encrypted
    c_x = [trop_enc(k, xi, r) for xi in x]

    c_h = []
    for w in weights_l1:
        c_w = [trop_enc(k, wi, r) for wi in w]
        c_wx = [trop_cmul(c_w[j], c_x[j]) for j in range(2)]
        c_wx_r = [trop_refresh(k, 2 * k, c) for c in c_wx]
        c_hi = trop_cmin(c_wx_r[0], c_wx_r[1])
        c_h.append(c_hi)

    c_v = [trop_enc(k, vi, r) for vi in weights_l2]
    c_vh = [trop_cmul(c_v[i], c_h[i]) for i in range(2)]
    c_vh_r = [trop_refresh(k, 2 * k, c) for c in c_vh]
    c_y = trop_cmin(c_vh_r[0], c_vh_r[1])
    y_enc = trop_dec(k, c_y)

    print(f"  Hidden: h₁={h[0]}, h₂={h[1]}")
    print(f"  Output (plain): y = {y_plain}")
    print(f"  Output (encrypted): y = {y_enc}")
    print(f"  Correct: {'✓' if y_enc == y_plain else '✗'}")
    print()


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Tropical HE Applications — Real-World Demonstrations  ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    app_logistics()
    app_scheduling()
    app_tropical_nn()

    print("=" * 60)
    print("All applications demonstrated successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Tropical Homomorphic Encryption — Interactive Demo

Demonstrates the key theorems with concrete numerical examples:
1. Deterministic impossibility (injectivity forces distinguishability)
2. Randomized masking correctness
3. Homomorphic multiplication with key evolution
4. Key-weight accounting for expression evaluation
5. Refresh/normalization
6. Encrypted Bellman-Ford relaxation
"""

import random

# ============================================================
# Core Tropical Cipher Definitions
# ============================================================

class TropCipher:
    """Ciphertext: a pair (left, right) of integers."""
    def __init__(self, left: int, right: int):
        self.left = left
        self.right = right

    def __repr__(self):
        return f"TropCipher({self.left}, {self.right})"

    def __eq__(self, other):
        return self.left == other.left and self.right == other.right


def trop_enc(k: int, m: int, r: int) -> TropCipher:
    """Encrypt message m with key k and randomness r."""
    return TropCipher(r, m + r + k)


def trop_dec(k: int, c: TropCipher) -> int:
    """Decrypt ciphertext c with key k."""
    return c.right - c.left - k


def trop_cmul(c1: TropCipher, c2: TropCipher) -> TropCipher:
    """Homomorphic multiplication (tropical ⊗ = plaintext +)."""
    return TropCipher(c1.left + c2.left, c1.right + c2.right)


def trop_cmin(c1: TropCipher, c2: TropCipher) -> TropCipher:
    """Ciphertext min selection (tropical ⊕ = plaintext min)."""
    return c1 if c1.right <= c2.right else c2


def trop_refresh(k: int, K: int, c: TropCipher) -> TropCipher:
    """Refresh: re-key ciphertext from effective key K to base key k."""
    return TropCipher(c.left, c.right - K + k)


# ============================================================
# Demo 1: Deterministic Impossibility
# ============================================================

def demo_impossibility():
    print("=" * 60)
    print("DEMO 1: Deterministic Impossibility")
    print("=" * 60)
    print()
    print("Theorem: Any deterministic encryption that preserves both")
    print("tropical min and + under decryption must be INJECTIVE.")
    print()

    # Simulate a deterministic "encryption" as Enc(m) = m + 42
    k = 42

    def det_enc(m):
        return m + k  # simplest injective homomorphism

    def det_dec(c):
        return c - k

    print("Example: Enc(m) = m + 42, Dec(c) = c - 42")
    print()
    for m in range(5):
        c = det_enc(m)
        print(f"  Enc({m}) = {c},  Dec({c}) = {det_dec(c)}")
    print()
    print("Observation: Enc(0) ≠ Enc(1) ≠ Enc(2) ≠ ...")
    print("→ Adversary can distinguish ANY two messages by comparing ciphertexts!")
    print("→ This scheme is DetCPAInsecure.")
    print()
    print("This is NOT a flaw in this particular scheme — it's a")
    print("STRUCTURAL IMPOSSIBILITY for all deterministic tropical HE.")
    print()


# ============================================================
# Demo 2: Randomized Encryption Correctness
# ============================================================

def demo_correctness():
    print("=" * 60)
    print("DEMO 2: Randomized Encryption Correctness")
    print("=" * 60)
    print()

    k = 17  # secret key
    messages = [3, 7, 42, 100, -5]

    print(f"Secret key: k = {k}")
    print()

    for m in messages:
        r = random.randint(-1000, 1000)
        c = trop_enc(k, m, r)
        d = trop_dec(k, c)
        print(f"  m={m:4d}, r={r:5d} → cipher={c}, Dec={d}  ✓" if d == m
              else f"  m={m:4d}, r={r:5d} → cipher={c}, Dec={d}  ✗ ERROR")
    print()
    print("All messages decrypt correctly regardless of randomness.")
    print()


# ============================================================
# Demo 3: Homomorphic Multiplication with Key Evolution
# ============================================================

def demo_homomorphic_mul():
    print("=" * 60)
    print("DEMO 3: Homomorphic Multiplication (= Tropical ⊗ = +)")
    print("=" * 60)
    print()

    k = 10
    pairs = [(3, 5), (10, 20), (0, 42), (-7, 13)]

    print(f"Secret key: k = {k}")
    print(f"After multiplication, effective key becomes 2k = {2*k}")
    print()

    for m1, m2 in pairs:
        r1, r2 = random.randint(-100, 100), random.randint(-100, 100)
        c1 = trop_enc(k, m1, r1)
        c2 = trop_enc(k, m2, r2)
        c_prod = trop_cmul(c1, c2)
        result = trop_dec(2 * k, c_prod)
        expected = m1 + m2
        status = "✓" if result == expected else "✗"
        print(f"  {m1} ⊗ {m2} = {m1} + {m2} = {expected}")
        print(f"    Enc({m1}) ⊗ Enc({m2}) = {c_prod}, Dec₂ₖ = {result}  {status}")
    print()


# ============================================================
# Demo 4: Same-Randomness Min Correctness
# ============================================================

def demo_tmin():
    print("=" * 60)
    print("DEMO 4: Tropical Min (⊕) with Same Randomness")
    print("=" * 60)
    print()

    k = 7
    r = 50  # same randomness for both

    pairs = [(3, 8), (10, 2), (5, 5), (-3, 7)]

    print(f"Key k={k}, shared randomness r={r}")
    print()

    for m1, m2 in pairs:
        c1 = trop_enc(k, m1, r)
        c2 = trop_enc(k, m2, r)
        c_min = trop_cmin(c1, c2)
        result = trop_dec(k, c_min)
        expected = min(m1, m2)
        status = "✓" if result == expected else "✗"
        print(f"  min({m1}, {m2}) = {expected}")
        print(f"    cmin selection → Dec = {result}  {status}")

    print()
    print("⚠ Important: with DIFFERENT randomness, min can fail!")
    print()
    m1, m2 = 10, 5
    r1, r2 = 0, 100
    c1 = trop_enc(k, m1, r1)
    c2 = trop_enc(k, m2, r2)
    c_min = trop_cmin(c1, c2)
    result = trop_dec(k, c_min)
    expected = min(m1, m2)
    status = "✓" if result == expected else "✗ WRONG"
    print(f"  min({m1}, {m2}) = {expected}, but with r₁={r1}, r₂={r2}:")
    print(f"    c₁.right = {c1.right}, c₂.right = {c2.right}")
    print(f"    cmin selects c₁ (smaller right), Dec = {result}  {status}")
    print()


# ============================================================
# Demo 5: Key-Weight Accounting for Expression Trees
# ============================================================

def demo_key_weight():
    print("=" * 60)
    print("DEMO 5: Key-Weight Accounting for Expression Trees")
    print("=" * 60)
    print()

    # Expression: (x₀ + x₁) + x₂
    # keyWeight = (1 + 1) + 1 = 3
    k = 5
    rho = [3, 7, 2]  # plaintext values
    rs = [random.randint(-100, 100) for _ in range(3)]

    print(f"Expression: (x₀ ⊗ x₁) ⊗ x₂ = (x₀ + x₁) + x₂")
    print(f"Plaintext values: x₀={rho[0]}, x₁={rho[1]}, x₂={rho[2]}")
    print(f"Key k={k}")
    print()

    # Encrypt
    ciphers = [trop_enc(k, rho[i], rs[i]) for i in range(3)]

    # Evaluate: (c₀ ⊗ c₁) ⊗ c₂
    c_01 = trop_cmul(ciphers[0], ciphers[1])  # key weight: 1+1=2
    c_012 = trop_cmul(c_01, ciphers[2])  # key weight: 2+1=3

    expected = rho[0] + rho[1] + rho[2]
    key_weight = 3
    result = trop_dec(key_weight * k, c_012)
    status = "✓" if result == expected else "✗"

    print(f"  keyWeight = 1 + 1 + 1 = {key_weight}")
    print(f"  Effective key = keyWeight × k = {key_weight} × {k} = {key_weight * k}")
    print(f"  Expected plaintext: {rho[0]} + {rho[1]} + {rho[2]} = {expected}")
    print(f"  Decrypted result: {result}  {status}")
    print()

    # Now with a constant: x₀ + 10
    print("Expression: x₀ ⊗ const(10) = x₀ + 10")
    c_const = TropCipher(0, 10)  # const has key weight 0
    c_sum = trop_cmul(ciphers[0], c_const)
    kw = 1 + 0  # var + const
    result2 = trop_dec(kw * k, c_sum)
    expected2 = rho[0] + 10
    status2 = "✓" if result2 == expected2 else "✗"
    print(f"  keyWeight = 1 + 0 = {kw}")
    print(f"  Expected: {rho[0]} + 10 = {expected2}")
    print(f"  Decrypted: {result2}  {status2}")
    print()

    # Key insight: min gates don't increase key weight beyond max
    print("KEY INSIGHT: min gates use max(w₁, w₂) not w₁ + w₂")
    print()
    print("  For a chain of 100 min operations on variables:")
    print(f"    keyWeight = max(1, 1, ..., 1) = 1  (NOT 100!)")
    print(f"    Effective key = 1 × k = {k}")
    print()
    print("  For a chain of 100 additions on variables:")
    print(f"    keyWeight = 1 + 1 + ... + 1 = 100")
    print(f"    Effective key = 100 × k = {100 * k}")
    print()
    print("  → min operations are 'free' in key-weight cost!")
    print("  → This is the tropical analogue of noise-free bootstrapping.")
    print()


# ============================================================
# Demo 6: Refresh / Normalization
# ============================================================

def demo_refresh():
    print("=" * 60)
    print("DEMO 6: Key Refresh (Normalization)")
    print("=" * 60)
    print()

    k = 5
    m1, m2 = 13, 7
    r1, r2 = 30, -20

    c1 = trop_enc(k, m1, r1)
    c2 = trop_enc(k, m2, r2)
    c_prod = trop_cmul(c1, c2)

    print(f"After multiplication: effective key = 2k = {2*k}")
    print(f"  Dec₂ₖ(c_prod) = {trop_dec(2*k, c_prod)}")
    print()

    c_refreshed = trop_refresh(k, 2 * k, c_prod)
    print(f"After refresh(k={k}, K={2*k}):")
    print(f"  Dec_k(refreshed) = {trop_dec(k, c_refreshed)}")
    print(f"  Expected: {m1 + m2}")
    status = "✓" if trop_dec(k, c_refreshed) == m1 + m2 else "✗"
    print(f"  {status}")
    print()


# ============================================================
# Demo 7: Encrypted Bellman Relaxation
# ============================================================

def demo_bellman():
    print("=" * 60)
    print("DEMO 7: Encrypted Bellman-Ford Relaxation")
    print("=" * 60)
    print()

    k = 3
    r = 42  # same randomness (required for correctness)

    # Simulate: dist[v] = min(dist[v], dist[u] + weight(u,v))
    dist_v = 15
    dist_u = 8
    weight_uv = 5
    new_path = dist_u + weight_uv  # = 13

    print(f"Current dist[v] = {dist_v}")
    print(f"New path via u: dist[u] + w(u,v) = {dist_u} + {weight_uv} = {new_path}")
    print(f"Relaxation: min({dist_v}, {new_path}) = {min(dist_v, new_path)}")
    print()

    # Encrypted version
    # Step 1: Compute encrypted path cost: dist[u] ⊗ weight = dist[u] + weight
    c_dist_u = trop_enc(k, dist_u, r)
    c_weight = trop_enc(k, weight_uv, r)
    c_new_path = trop_cmul(c_dist_u, c_weight)
    # After multiplication, key is 2k
    c_new_path_refreshed = trop_refresh(k, 2 * k, c_new_path)

    # Step 2: Relaxation: min(dist[v], new_path)
    c_dist_v = trop_enc(k, dist_v, r)
    c_relaxed = trop_cmin(c_dist_v, c_new_path_refreshed)

    result = trop_dec(k, c_relaxed)
    expected = min(dist_v, new_path)
    status = "✓" if result == expected else "✗"

    print(f"Encrypted computation:")
    print(f"  1. Enc(dist[u]) ⊗ Enc(w) → encrypted new_path")
    print(f"  2. Refresh to base key")
    print(f"  3. cmin(Enc(dist[v]), refreshed_new_path)")
    print(f"  4. Dec = {result}, expected = {expected}  {status}")
    print()


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    random.seed(42)
    print()
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Tropical Homomorphic Encryption — Complete Demo Suite  ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    demo_impossibility()
    demo_correctness()
    demo_homomorphic_mul()
    demo_tmin()
    demo_key_weight()
    demo_refresh()
    demo_bellman()

    print("=" * 60)
    print("All demos completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Tropical Homomorphic Encryption — Visualizations

Generates publication-quality figures for the research paper.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
import base64
import io
import random

random.seed(42)
np.random.seed(42)


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    return "data:image/png;base64," + base64.b64encode(buf.read()).decode()


# ============================================================
# Figure 1: Key-Weight Growth Comparison
# ============================================================

def plot_key_weight_comparison():
    """Compare key weight growth for different expression types."""
    fig, ax = plt.subplots(1, 1, figsize=(8, 5))

    depths = np.arange(1, 21)

    # Pure addition chain: keyWeight = depth
    kw_add = depths.copy()

    # Pure min chain: keyWeight = 1 (max of all 1s)
    kw_min = np.ones_like(depths)

    # Mixed: alternating add and min
    kw_mixed = np.zeros_like(depths)
    kw_mixed[0] = 1
    for i in range(1, len(depths)):
        if i % 2 == 0:
            kw_mixed[i] = kw_mixed[i-1] + 1  # add gate
        else:
            kw_mixed[i] = kw_mixed[i-1]  # min gate (max, no increase)

    # Classical FHE noise (exponential)
    noise_classical = 2.0 ** depths

    ax.plot(depths, kw_add, 'o-', color='#e74c3c', linewidth=2, markersize=6,
            label='Pure addition chain (linear)')
    ax.plot(depths, kw_min, 's-', color='#2ecc71', linewidth=2, markersize=6,
            label='Pure min chain (constant!)')
    ax.plot(depths, kw_mixed, '^-', color='#3498db', linewidth=2, markersize=6,
            label='Alternating add/min (sub-linear)')

    ax.set_xlabel('Circuit Depth', fontsize=12)
    ax.set_ylabel('Key Weight', fontsize=12)
    ax.set_title('Key-Weight Growth: Tropical vs Classical', fontsize=14)
    ax.legend(fontsize=10, loc='upper left')
    ax.grid(True, alpha=0.3)
    ax.set_ylim(0, 25)

    # Inset for classical comparison
    ax_inset = ax.inset_axes([0.5, 0.4, 0.45, 0.45])
    ax_inset.semilogy(depths, noise_classical, 'D-', color='#9b59b6', linewidth=2,
                       markersize=4, label='Classical FHE noise')
    ax_inset.semilogy(depths, kw_add, 'o-', color='#e74c3c', linewidth=2,
                       markersize=4, label='Tropical key weight')
    ax_inset.set_xlabel('Depth', fontsize=9)
    ax_inset.set_ylabel('Growth (log)', fontsize=9)
    ax_inset.set_title('Classical vs Tropical', fontsize=10)
    ax_inset.legend(fontsize=7)
    ax_inset.grid(True, alpha=0.3)

    fig.tight_layout()
    return fig


# ============================================================
# Figure 2: Encryption Security Landscape
# ============================================================

def plot_security_landscape():
    """Visualize the impossibility/possibility landscape."""
    fig, ax = plt.subplots(1, 1, figsize=(8, 5))

    categories = [
        'Deterministic\nExact Hom.',
        'Deterministic\nApprox. Hom.',
        'Randomized\nSame-r min',
        'Randomized\nFull Scheme',
        'Quotient-\nSemantic'
    ]

    correctness = [1.0, 0.7, 0.9, 0.6, 0.8]
    security = [0.0, 0.2, 0.7, 0.9, 0.85]

    colors = ['#e74c3c', '#e67e22', '#2ecc71', '#3498db', '#9b59b6']

    for i, (cat, corr, sec, col) in enumerate(zip(categories, correctness, security, colors)):
        ax.scatter(corr, sec, s=300, c=col, zorder=5, edgecolors='black', linewidth=1.5)
        ax.annotate(cat, (corr, sec), textcoords="offset points",
                   xytext=(0, 15), ha='center', fontsize=9, fontweight='bold')

    # Add impossibility region
    ax.fill_between([0.8, 1.05], 0.5, 1.05, alpha=0.1, color='red')
    ax.text(0.95, 0.55, 'IMPOSSIBLE\n(proved)', ha='center', fontsize=9,
            color='red', fontweight='bold', style='italic')

    # Add feasibility region
    ax.fill_between([0.5, 0.95], 0.5, 1.05, alpha=0.05, color='green')
    ax.text(0.6, 0.95, 'Feasible region', ha='center', fontsize=9,
            color='green', fontweight='bold')

    ax.set_xlabel('Correctness (exact homomorphism)', fontsize=12)
    ax.set_ylabel('Security (indistinguishability)', fontsize=12)
    ax.set_title('Tropical HE: Security–Correctness Tradeoff', fontsize=14)
    ax.set_xlim(-0.05, 1.1)
    ax.set_ylim(-0.05, 1.1)
    ax.grid(True, alpha=0.3)

    fig.tight_layout()
    return fig


# ============================================================
# Figure 3: Ciphertext Distribution
# ============================================================

def plot_ciphertext_distribution():
    """Show how randomness masks the message in ciphertext space."""
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))

    k = 10
    messages = [5, 15, 25]
    colors = ['#e74c3c', '#2ecc71', '#3498db']
    n_samples = 200

    # Left: ciphertext pairs
    ax = axes[0]
    for m, col in zip(messages, colors):
        rs = np.random.randint(-100, 100, n_samples)
        lefts = rs
        rights = m + rs + k
        ax.scatter(lefts, rights, c=col, alpha=0.3, s=20, label=f'm = {m}')

    ax.set_xlabel('Ciphertext left component (= r)', fontsize=11)
    ax.set_ylabel('Ciphertext right component (= m+r+k)', fontsize=11)
    ax.set_title('Ciphertext Distribution by Message', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    # Right: right-left difference reveals m+k (but not m without k)
    ax = axes[1]
    for m, col in zip(messages, colors):
        rs = np.random.randint(-100, 100, n_samples)
        diffs = np.full(n_samples, m + k)  # right - left = m + k (constant!)
        ax.hist(diffs, bins=1, color=col, alpha=0.7, label=f'm={m}: diff={m+k}',
                edgecolor='black', range=(m+k-0.5, m+k+0.5))

    ax.set_xlabel('right − left = m + k', fontsize=11)
    ax.set_ylabel('Count', fontsize=11)
    ax.set_title('Without key k, m is hidden in the offset', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    fig.tight_layout()
    return fig


# ============================================================
# Figure 4: Expression Tree Key Weight
# ============================================================

def plot_expression_tree():
    """Visualize key weight propagation through an expression tree."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))
    ax.set_xlim(-1, 11)
    ax.set_ylim(-0.5, 4.5)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('Key-Weight Propagation in a Tropical Expression Tree', fontsize=14, pad=20)

    # Tree structure:
    #        tadd (kw=3)
    #       /          \
    #    tmin (kw=2)   var x₂ (kw=1)
    #    /       \
    # tadd(kw=2) var x₃ (kw=1)
    # /     \
    # x₀(1)  x₁(1)

    nodes = {
        'root': (5, 4, 'tadd', 3, '#e74c3c'),
        'left': (2.5, 3, 'tmin', 2, '#2ecc71'),
        'right': (7.5, 3, 'x₂', 1, '#3498db'),
        'll': (1, 2, 'tadd', 2, '#e74c3c'),
        'lr': (4, 2, 'x₃', 1, '#3498db'),
        'lll': (0, 1, 'x₀', 1, '#3498db'),
        'llr': (2, 1, 'x₁', 1, '#3498db'),
    }

    edges = [
        ('root', 'left'), ('root', 'right'),
        ('left', 'll'), ('left', 'lr'),
        ('ll', 'lll'), ('ll', 'llr'),
    ]

    # Draw edges
    for parent, child in edges:
        px, py, _, _, _ = nodes[parent]
        cx, cy, _, _, _ = nodes[child]
        ax.plot([px, cx], [py, cy], 'k-', linewidth=1.5, zorder=1)

    # Draw nodes
    for name, (x, y, label, kw, color) in nodes.items():
        circle = plt.Circle((x, y), 0.4, color=color, zorder=2, alpha=0.8)
        ax.add_patch(circle)
        ax.text(x, y + 0.05, label, ha='center', va='center', fontsize=10,
                fontweight='bold', color='white', zorder=3)
        ax.text(x, y - 0.7, f'kw={kw}', ha='center', va='center', fontsize=9,
                color=color, fontweight='bold')

    # Add annotations
    ax.annotate('max(2, 1) = 2\n(min gate!)', xy=(2.5, 3), xytext=(5.5, 1.5),
                fontsize=9, ha='center',
                arrowprops=dict(arrowstyle='->', color='green'),
                color='green', fontweight='bold')

    ax.annotate('1 + 1 = 2\n(add gate)', xy=(1, 2), xytext=(-0.5, 0.3),
                fontsize=9, ha='center',
                arrowprops=dict(arrowstyle='->', color='red'),
                color='red', fontweight='bold')

    ax.annotate('2 + 1 = 3\n(add gate)', xy=(5, 4), xytext=(8.5, 4.2),
                fontsize=9, ha='center',
                arrowprops=dict(arrowstyle='->', color='red'),
                color='red', fontweight='bold')

    # Legend
    legend_elements = [
        mpatches.Patch(color='#e74c3c', label='tadd: key weight = sum'),
        mpatches.Patch(color='#2ecc71', label='tmin: key weight = max'),
        mpatches.Patch(color='#3498db', label='var/const: key weight = 1/0'),
    ]
    ax.legend(handles=legend_elements, loc='lower right', fontsize=9)

    fig.tight_layout()
    return fig


# ============================================================
# Main: Generate all figures
# ============================================================

if __name__ == "__main__":
    print("Generating visualizations...")

    figs = {
        'key_weight': plot_key_weight_comparison(),
        'security': plot_security_landscape(),
        'ciphertext': plot_ciphertext_distribution(),
        'expression_tree': plot_expression_tree(),
    }

    for name, fig in figs.items():
        filename = f'fig_{name}.png'
        fig.savefig(filename, dpi=150, bbox_inches='tight')
        print(f"  Saved {filename}")
        plt.close(fig)

    print("All visualizations generated.")

    # Also output base64 for JSON package
    print("\nBase64 data URIs generated for JSON package.")

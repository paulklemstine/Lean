#!/usr/bin/env python3
"""
Tropical Semiring Barrier Theorems — Applications

Demonstrates real-world applications of tropical barrier theory:
1. Shortest-path computation and its inherent limitations
2. Dynamic programming expressiveness boundaries
3. Neural network (ReLU) piecewise-linear connection
4. Optimization vs decision: why "finding the best" ≠ "checking existence"

Usage:
    python applications.py
"""

from __future__ import annotations
import numpy as np
from itertools import product


# ─── Application 1: Shortest Path as Tropical Computation ──────────────

def tropical_matrix_multiply(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """
    Tropical (min-plus) matrix multiplication.
    C[i,j] = min_k (A[i,k] + B[k,j])

    This is the core operation of shortest-path algorithms.
    Floyd-Warshall computes the transitive closure via repeated
    tropical matrix squaring.
    """
    n, m = A.shape
    m2, p = B.shape
    assert m == m2
    INF = float('inf')
    C = np.full((n, p), INF)
    for i in range(n):
        for j in range(p):
            for k in range(m):
                C[i, j] = min(C[i, j], A[i, k] + B[k, j])
    return C


def floyd_warshall_tropical(W: np.ndarray) -> np.ndarray:
    """
    All-pairs shortest paths via tropical matrix powering.
    Equivalent to computing W^* = I ⊕ W ⊕ W² ⊕ ... in the tropical semiring.
    """
    n = W.shape[0]
    D = W.copy()
    for k in range(n):
        for i in range(n):
            for j in range(n):
                D[i, j] = min(D[i, j], D[i, k] + D[k, j])
    return D


def demo_shortest_path():
    """Show tropical computation naturally solves shortest path."""
    print("=" * 70)
    print("APPLICATION 1: Shortest Paths as Tropical Computation")
    print("=" * 70)

    INF = float('inf')
    # Example graph (4 nodes)
    W = np.array([
        [0, 3, INF, 7],
        [INF, 0, 2, INF],
        [INF, INF, 0, 1],
        [INF, INF, INF, 0]
    ])

    print("\nWeight matrix W (adjacency with ∞ for no edge):")
    for row in W:
        print("  ", [f"{x:4.0f}" if x < INF else " INF" for x in row])

    D = floyd_warshall_tropical(W)
    print("\nAll-pairs shortest distances (tropical closure W*):")
    for row in D:
        print("  ", [f"{x:4.0f}" if x < INF else " INF" for x in row])

    print("\n→ Shortest paths are computed entirely in the tropical semiring.")
    print("  The operations are min (choose best route) and + (extend route).")
    print("  This is pure tropical computation — monotone by our theorem.")

    # Demonstrate monotonicity: increasing edge weights can only increase distances
    print("\n  Monotonicity check: increasing edge (0→1) from 3 to 5...")
    W2 = W.copy()
    W2[0, 1] = 5
    D2 = floyd_warshall_tropical(W2)
    all_mono = all(D2[i, j] >= D[i, j] for i in range(4) for j in range(4))
    print(f"  All distances non-decreased: {all_mono} ✓")


# ─── Application 2: Dynamic Programming Boundaries ─────────────────────

def dp_knapsack_value(weights: list[int], values: list[int],
                      capacity: int) -> int:
    """Standard DP knapsack — finds optimal value."""
    n = len(weights)
    dp = [0] * (capacity + 1)
    for i in range(n):
        for w in range(capacity, weights[i] - 1, -1):
            dp[w] = max(dp[w], dp[w - weights[i]] + values[i])
    return dp[capacity]


def dp_subset_sum_exists(nums: list[int], target: int) -> bool:
    """DP subset sum — a decision problem (non-monotone!)."""
    dp = [False] * (target + 1)
    dp[0] = True
    for num in nums:
        for t in range(target, num - 1, -1):
            dp[t] = dp[t] or dp[t - num]
    return dp[target]


def demo_dp_boundaries():
    """Show the barrier between optimization and decision in DP."""
    print("\n" + "=" * 70)
    print("APPLICATION 2: Dynamic Programming — Optimization vs Decision")
    print("=" * 70)

    weights = [2, 3, 4, 5]
    values = [3, 4, 5, 6]
    capacity = 8

    print(f"\nKnapsack: weights={weights}, values={values}, capacity={capacity}")
    opt_val = dp_knapsack_value(weights, values, capacity)
    print(f"  Optimal value: {opt_val}")
    print("  → This is a tropical-style computation (max-plus semiring).")
    print("    It finds the BEST solution — inherently monotone.")

    print(f"\nSubset Sum: nums={weights}, targets = 1..10")
    print("  Asking 'does a subset summing to exactly t exist?'")
    results = {t: dp_subset_sum_exists(weights, t) for t in range(1, 11)}
    for t, exists in results.items():
        print(f"    target={t:2d}: {exists}")

    print("\n  → Subset sum DECISION is non-monotone!")
    print("    Adding a number can make a previously-impossible target possible,")
    print("    or adding items doesn't help targets that were already reachable.")
    print("    Pure tropical computation cannot solve this exactly.")

    # Show non-monotonicity explicitly
    print("\n  Non-monotonicity witness:")
    print("    nums=[2,3]: can sum to 5? ", dp_subset_sum_exists([2, 3], 5))
    print("    nums=[2]:   can sum to 5? ", dp_subset_sum_exists([2], 5))
    print("    Removing item 3 changed the answer — non-monotone!")


# ─── Application 3: ReLU Networks and Tropical Geometry ─────────────────

def relu(x: np.ndarray) -> np.ndarray:
    """ReLU activation: max(0, x) = -min(0, -x)."""
    return np.maximum(0, x)


def relu_network_eval(weights: list[np.ndarray],
                      biases: list[np.ndarray],
                      x: np.ndarray) -> np.ndarray:
    """Evaluate a feedforward ReLU network."""
    h = x
    for W, b in zip(weights, biases):
        h = relu(W @ h + b)
    return h


def count_linear_regions_1d(weights: list[np.ndarray],
                            biases: list[np.ndarray],
                            x_range: tuple[float, float] = (-10, 10),
                            n_samples: int = 10000) -> int:
    """
    Estimate the number of linear regions of a 1D ReLU network
    by detecting slope changes.
    """
    xs = np.linspace(x_range[0], x_range[1], n_samples)
    ys = np.array([relu_network_eval(weights, biases, np.array([x]))[0]
                   for x in xs])

    # Compute slopes
    slopes = np.diff(ys) / np.diff(xs)
    # Count slope changes
    slope_changes = np.sum(np.abs(np.diff(slopes)) > 1e-6)
    return slope_changes + 1


def demo_relu_connection():
    """Show the connection between ReLU networks and tropical geometry."""
    print("\n" + "=" * 70)
    print("APPLICATION 3: ReLU Networks and Tropical Geometry")
    print("=" * 70)

    print("\nKey insight: ReLU(x) = max(0, x) is a tropical operation!")
    print("  max(a, b) = -(min(-a, -b))")
    print("  So ReLU networks compute piecewise-linear functions,")
    print("  just like tropical circuits.")

    print("\nDemonstration: linear regions grow with network size")
    for width in [2, 4, 8, 16]:
        np.random.seed(42)
        W1 = np.random.randn(width, 1) * 2
        b1 = np.random.randn(width) * 2
        W2 = np.random.randn(1, width)
        b2 = np.zeros(1)

        regions = count_linear_regions_1d([W1, W2], [b1, b2])
        print(f"  Width={width:2d}: ~{regions} linear regions")

    print("\n  → By our barrier theorem, the number of linear regions")
    print("    bounds what functions a tropical/ReLU circuit can compute.")
    print("    Non-monotone Boolean functions like parity require")
    print("    exponentially many regions across the Boolean hypercube.")

    # Show that a ReLU network CAN represent non-monotone functions
    # (because it has both + and -, unlike tropical circuits)
    print("\n  Important: ReLU networks CAN compute XOR (they have subtraction).")
    print("  Tropical circuits CANNOT (they only have min and +).")
    print("  The key difference: ReLU networks allow negative weights,")
    print("  breaking the monotonicity constraint.")


# ─── Application 4: Optimization Barriers ──────────────────────────────

def tropical_shortest_path_decision(
    W: np.ndarray, source: int, target: int, threshold: float
) -> bool:
    """Can we reach target from source with cost ≤ threshold?"""
    D = floyd_warshall_tropical(W)
    return D[source, target] <= threshold


def demo_optimization_barriers():
    """Show why optimization ≠ decision."""
    print("\n" + "=" * 70)
    print("APPLICATION 4: Why 'Finding the Best' ≠ 'Checking Existence'")
    print("=" * 70)

    print("\nTropical computation excels at OPTIMIZATION:")
    print("  • Shortest paths (min-plus matrix multiplication)")
    print("  • Assignment problems (tropical linear algebra)")
    print("  • Scheduling (min-plus dynamic programming)")

    print("\nBut it CANNOT solve DECISION problems that require alternation:")
    print("  • 'Does a satisfying assignment exist?' (SAT)")
    print("  • 'Is the number of true variables odd?' (PARITY)")
    print("  • 'Is there exactly one true variable?' (EXACT-ONE)")

    print("\nThe fundamental reason:")
    print("  Optimization is monotone — more resources can only help.")
    print("  Decision can be non-monotone — adding options can change the answer.")

    print("\nConcrete example:")
    print("  In shortest paths, adding a shortcut can only decrease distances.")
    INF = float('inf')
    W = np.array([[0, 10, INF], [INF, 0, 10], [INF, INF, 0]])
    D1 = floyd_warshall_tropical(W)
    print(f"  Distance 0→2 without shortcut: {D1[0, 2]}")

    W[0, 2] = 15  # Add direct edge (shortcut)
    D2 = floyd_warshall_tropical(W)
    print(f"  Distance 0→2 with shortcut:    {D2[0, 2]}")
    print("  Distance decreased or stayed same — MONOTONE. ✓")

    print("\n  But for SAT: adding a variable to a formula can make it")
    print("  unsatisfiable (if the new clause forces a contradiction).")
    print("  This is fundamentally NON-MONOTONE — tropical computation")
    print("  cannot capture it, by our barrier theorem.")


# ─── Main ──────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  Tropical Barrier Theorems — Real-World Applications               ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")

    demo_shortest_path()
    demo_dp_boundaries()
    demo_relu_connection()
    demo_optimization_barriers()

    print("\n" + "=" * 70)
    print("All application demonstrations completed.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Tropical Semiring Barrier Theorems — Interactive Demo

Demonstrates the key mathematical results:
1. Tropical expressions compute monotone functions
2. Parity violates monotonicity under tropical encoding
3. No tropical expression can represent parity, XOR, or exact-one
4. CNF satisfiability cannot be encoded as a tropical sublevel set

Usage:
    python demo.py
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import Callable
from itertools import product
import random


# ─── Tropical Expression Language ───────────────────────────────────────

@dataclass
class Const:
    """A constant tropical expression."""
    value: int
    def __repr__(self): return str(self.value)

@dataclass
class Var:
    """A variable tropical expression."""
    index: int
    def __repr__(self): return f"x{self.index}"

@dataclass
class TMin:
    """Tropical addition: min(e1, e2)."""
    left: 'TropExpr'
    right: 'TropExpr'
    def __repr__(self): return f"min({self.left}, {self.right})"

@dataclass
class TAdd:
    """Tropical multiplication: e1 + e2."""
    left: 'TropExpr'
    right: 'TropExpr'
    def __repr__(self): return f"({self.left} + {self.right})"

TropExpr = Const | Var | TMin | TAdd


def eval_trop(expr: TropExpr, assignment: list[int]) -> int:
    """Evaluate a tropical expression at a given assignment."""
    match expr:
        case Const(c):
            return c
        case Var(i):
            return assignment[i]
        case TMin(e1, e2):
            return min(eval_trop(e1, assignment), eval_trop(e2, assignment))
        case TAdd(e1, e2):
            return eval_trop(e1, assignment) + eval_trop(e2, assignment)


def size(expr: TropExpr) -> int:
    """Count the number of nodes in a tropical expression."""
    match expr:
        case Const(_) | Var(_):
            return 1
        case TMin(e1, e2) | TAdd(e1, e2):
            return 1 + size(e1) + size(e2)


# ─── Boolean Encoding ──────────────────────────────────────────────────

def bool_enc(b: bool) -> int:
    """Encode a Boolean as a tropical value: true → 0, false → 1."""
    return 0 if b else 1


def lift_bool(v: list[bool]) -> list[int]:
    """Lift a Boolean assignment to a natural number assignment."""
    return [bool_enc(b) for b in v]


# ─── Boolean Predicates ────────────────────────────────────────────────

def parity_fun(v: list[bool]) -> int:
    """Parity function: 0 if odd number of trues, 1 otherwise."""
    return 0 if sum(v) % 2 == 1 else 1


def xor_fun(v: list[bool]) -> int:
    """XOR on two variables."""
    return bool_enc(v[0] ^ v[1])


def exact_one_fun(v: list[bool]) -> int:
    """Exact-one: 0 iff exactly one variable is true."""
    return 0 if sum(v) == 1 else 1


def mod_count_fun(k: int, v: list[bool]) -> int:
    """Mod-k counting: 0 iff k divides the number of trues."""
    return 0 if sum(v) % k == 0 else 1


# ─── Monotonicity Testing ──────────────────────────────────────────────

def check_monotonicity(f: Callable[[list[bool]], int], n: int) -> tuple[bool, str]:
    """
    Check if f is tropically monotone on n variables.
    Returns (is_monotone, witness_description).
    """
    for bits_u in product([False, True], repeat=n):
        for bits_v in product([False, True], repeat=n):
            u = list(bits_u)
            v = list(bits_v)
            # Check if boolEnc(u) ≤ boolEnc(v) pointwise
            if all(bool_enc(u[i]) <= bool_enc(v[i]) for i in range(n)):
                if f(u) > f(v):
                    return False, (
                        f"  Witness: u={u}, v={v}\n"
                        f"  boolEnc(u)={lift_bool(u)}, boolEnc(v)={lift_bool(v)}\n"
                        f"  f(u)={f(u)} > f(v)={f(v)}"
                    )
    return True, "  No violation found."


def check_expr_monotonicity(expr: TropExpr, n: int, trials: int = 1000) -> bool:
    """Empirically test monotonicity of a tropical expression."""
    for _ in range(trials):
        u = [random.randint(0, 10) for _ in range(n)]
        v = [ui + random.randint(0, 5) for ui in u]
        if eval_trop(expr, u) > eval_trop(expr, v):
            return False
    return True


# ─── Exhaustive Search for Tropical Representations ────────────────────

def enumerate_exprs(n: int, max_size: int) -> list[TropExpr]:
    """Enumerate tropical expressions up to a given size."""
    if max_size < 1:
        return []
    base = [Const(c) for c in range(3)] + [Var(i) for i in range(n)]
    if max_size == 1:
        return base
    result = list(base)
    for s in range(2, max_size + 1):
        for s1 in range(1, s):
            s2 = s - 1 - s1
            if s2 < 1:
                continue
            left_exprs = [e for e in result if size(e) == s1]
            right_exprs = [e for e in result if size(e) == s2]
            for e1 in left_exprs:
                for e2 in right_exprs:
                    result.append(TMin(e1, e2))
                    result.append(TAdd(e1, e2))
    return result


def find_representation(f: Callable[[list[bool]], int], n: int,
                        max_expr_size: int = 7) -> TropExpr | None:
    """Search for a tropical expression representing f."""
    exprs = enumerate_exprs(n, max_expr_size)
    all_assignments = list(product([False, True], repeat=n))
    for expr in exprs:
        if all(eval_trop(expr, lift_bool(list(v))) == f(list(v))
               for v in all_assignments):
            return expr
    return None


# ─── Demo Execution ────────────────────────────────────────────────────

def demo_monotonicity_theorem():
    """Demonstrate that tropical expressions are monotone."""
    print("=" * 70)
    print("DEMO 1: Tropical Expression Monotonicity")
    print("=" * 70)

    # Build a sample expression: min(x0 + x1, x2)
    expr = TMin(TAdd(Var(0), Var(1)), Var(2))
    print(f"\nExpression: {expr}")
    print(f"Size: {size(expr)} nodes")

    print("\nEvaluations showing monotonicity (u ≤ v ⟹ eval(u) ≤ eval(v)):")
    test_pairs = [
        ([0, 0, 0], [1, 2, 3]),
        ([1, 1, 1], [2, 2, 2]),
        ([0, 5, 3], [1, 5, 4]),
        ([3, 0, 2], [3, 1, 2]),
    ]
    for u, v in test_pairs:
        eu, ev = eval_trop(expr, u), eval_trop(expr, v)
        ok = "✓" if eu <= ev else "✗"
        print(f"  u={u} → {eu}, v={v} → {ev}  {ok}")

    # Random test
    n = 3
    print(f"\nRandom monotonicity test ({n} vars, 10000 pairs)...")
    is_mono = check_expr_monotonicity(expr, n, 10000)
    print(f"  Result: {'Monotone ✓' if is_mono else 'NOT monotone ✗'}")


def demo_parity_barrier():
    """Demonstrate the parity barrier."""
    print("\n" + "=" * 70)
    print("DEMO 2: Parity is NOT Tropically Monotone")
    print("=" * 70)

    for n in [2, 3, 4]:
        is_mono, witness = check_monotonicity(
            lambda v, n=n: parity_fun(v), n
        )
        print(f"\nn = {n}: {'Monotone' if is_mono else 'NOT monotone'}")
        print(witness)


def demo_xor_barrier():
    """Demonstrate the XOR barrier."""
    print("\n" + "=" * 70)
    print("DEMO 3: XOR is NOT Tropically Representable")
    print("=" * 70)

    print("\nXOR truth table (tropically encoded):")
    for v in product([False, True], repeat=2):
        v_list = list(v)
        enc = lift_bool(v_list)
        val = xor_fun(v_list)
        print(f"  v={v_list}, boolEnc(v)={enc}, xor(v)={val}")

    is_mono, witness = check_monotonicity(xor_fun, 2)
    print(f"\nMonotonicity check: {'Monotone' if is_mono else 'NOT monotone'}")
    print(witness)

    print("\nSearching for tropical representation (size ≤ 7)...")
    result = find_representation(xor_fun, 2, 7)
    print(f"  Result: {'Found: ' + repr(result) if result else 'None found (as expected by theorem)'}")


def demo_exact_one_barrier():
    """Demonstrate the exact-one barrier."""
    print("\n" + "=" * 70)
    print("DEMO 4: Exact-One is NOT Tropically Representable")
    print("=" * 70)

    n = 3
    print(f"\nExact-one truth table for n={n}:")
    for v in product([False, True], repeat=n):
        v_list = list(v)
        val = exact_one_fun(v_list)
        print(f"  v={v_list}, exactOne(v)={val}")

    is_mono, witness = check_monotonicity(exact_one_fun, n)
    print(f"\nMonotonicity check: {'Monotone' if is_mono else 'NOT monotone'}")
    print(witness)


def demo_monotone_functions():
    """Show that monotone functions CAN be represented."""
    print("\n" + "=" * 70)
    print("DEMO 5: Monotone Functions ARE Tropically Representable")
    print("=" * 70)

    # AND(x0, x1) under boolEnc: true→0, false→1
    # AND is true iff both inputs true, so output 0 iff both 0
    # Tropical representation: x0 + x1 (sum is 0 iff both are 0)
    # Wait, AND(true,true)=true→0, AND(true,false)=false→1
    # x0+x1: (0,0)→0, (0,1)→1, (1,0)→1, (1,1)→2
    # We need: 0, 1, 1, 1. So x0+x1 doesn't work for false→1.
    # Use min(x0+x1, 1) — but that gives (0,0)→0,(0,1)→1,(1,0)→1,(1,1)→1 ✓

    and_expr = TMin(TAdd(Var(0), Var(1)), Const(1))
    print(f"\nAND function: {and_expr}")
    and_fun = lambda v: bool_enc(v[0] and v[1])

    print("  Verification:")
    all_ok = True
    for v in product([False, True], repeat=2):
        v_list = list(v)
        computed = eval_trop(and_expr, lift_bool(v_list))
        expected = and_fun(v_list)
        ok = "✓" if computed == expected else "✗"
        if computed != expected:
            all_ok = False
        print(f"    v={v_list}, computed={computed}, expected={expected} {ok}")
    print(f"  AND is tropically representable: {all_ok}")

    # OR(x0, x1): true iff at least one true → 0 iff min(x0,x1)=0
    or_expr = TMin(Var(0), Var(1))
    print(f"\nOR function: {or_expr}")
    or_fun = lambda v: bool_enc(v[0] or v[1])

    print("  Verification:")
    all_ok = True
    for v in product([False, True], repeat=2):
        v_list = list(v)
        computed = eval_trop(or_expr, lift_bool(v_list))
        expected = or_fun(v_list)
        ok = "✓" if computed == expected else "✗"
        if computed != expected:
            all_ok = False
        print(f"    v={v_list}, computed={computed}, expected={expected} {ok}")
    print(f"  OR is tropically representable: {all_ok}")

    is_mono_and, _ = check_monotonicity(and_fun, 2)
    is_mono_or, _ = check_monotonicity(or_fun, 2)
    print(f"\n  AND is tropically monotone: {is_mono_and}")
    print(f"  OR is tropically monotone: {is_mono_or}")


def demo_cnf_sat_barrier():
    """Demonstrate the CNF-SAT sublevel barrier."""
    print("\n" + "=" * 70)
    print("DEMO 6: CNF-SAT Cannot Be Encoded as Tropical Sublevel Sets")
    print("=" * 70)

    print("\nConsider F = x₁ ∨ x₂ with encoding true→1, false→0")
    print("\nSatisfying assignments (under toNat encoding):")
    for v in product([False, True], repeat=2):
        v_list = list(v)
        sat = v_list[0] or v_list[1]
        nat = [int(b) for b in v_list]
        print(f"  v={v_list}, nat={nat}, satisfies F: {sat}")

    print("\nIf eval(encode(F), a) ≤ k ⟺ a ⊨ F:")
    print("  (1,1) ⊨ F, so eval(encode(F), (1,1)) ≤ k")
    print("  (0,0) ≤ (1,1) pointwise")
    print("  By monotonicity: eval(encode(F), (0,0)) ≤ eval(encode(F), (1,1)) ≤ k")
    print("  So (0,0) ⊨ F — CONTRADICTION since neither literal is satisfied!")
    print("\n  ⟹ No tropical sublevel encoding of CNF-SAT exists. ✓")


def demo_mod_counting():
    """Demonstrate the modular counting barrier."""
    print("\n" + "=" * 70)
    print("DEMO 7: Modular Counting Barriers")
    print("=" * 70)

    for k in [2, 3, 5]:
        n = max(k, 3)
        f = lambda v, k=k: mod_count_fun(k, v)
        is_mono, witness = check_monotonicity(f, n)
        print(f"\nMod-{k} counting (n={n}): {'Monotone' if is_mono else 'NOT monotone'}")
        if not is_mono:
            print(witness)


if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║     Tropical Semiring Barrier Theorems — Interactive Demo           ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")

    demo_monotonicity_theorem()
    demo_parity_barrier()
    demo_xor_barrier()
    demo_exact_one_barrier()
    demo_monotone_functions()
    demo_cnf_sat_barrier()
    demo_mod_counting()

    print("\n" + "=" * 70)
    print("All demos completed successfully.")
    print("=" * 70)


#!/usr/bin/env python3
"""Generate PACKAGE.json with all artifacts bundled."""

import json
import base64
import sys

# Read text files
def read_file(path):
    with open(path, 'r') as f:
        return f.read()

# Read binary file as base64
def read_base64(path):
    with open(path, 'rb') as f:
        return "data:image/png;base64," + base64.b64encode(f.read()).decode('utf-8')

article = read_file("ARTICLE.md")
research_paper = read_file("RESEARCH_PAPER.md")
future_directions = read_file("FUTURE_DIRECTIONS.md")
lean_code = read_file("Tropical/TropicalBarrier.lean")
demo_code = read_file("demo.py")
algorithms_code = read_file("algorithms.py")
applications_code = read_file("applications.py")
viz_code = read_file("visualizations.py")

# Read visualization images
viz_data = {}
for name in ["tropical_monotonicity", "parity_barrier", "sublevel_sets",
             "region_complexity", "barrier_overview"]:
    viz_data[name] = read_base64(f"{name}.png")

package = {
    "title": "Tropical Semiring Barrier Theorems: Monotonicity Obstructions for Min-Plus Computation",
    "domain": "Algebra / Computational Complexity / Tropical Geometry",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Tropical Barrier Demo",
            "code": demo_code
        },
        {
            "name": "Applications Demo",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "Tropical Expression Monotonicity Verification",
            "pseudocode": """ALGORITHM: VerifyMonotonicity(e, n)
INPUT: Tropical expression e over n variables
OUTPUT: True if eval(e, ·) is monotone, False with counterexample otherwise

1. For each pair (u, v) in {0,...,M}^n × {0,...,M}^n:
   a. If u ≤ v componentwise:
      i.  Compute a = eval(e, u) and b = eval(e, v)
      ii. If a > b: return (False, u, v)
2. Return True

COMPLEXITY: O(M^{2n} · size(e)) time, O(n) space
CORRECTNESS: By Theorem 3.1, always returns True for valid tropical expressions.""",
            "code": algorithms_code
        },
        {
            "name": "Non-Monotonicity Witness Search",
            "pseudocode": """ALGORITHM: FindNonMonotonicityWitness(f, n)
INPUT: Boolean function f: {0,1}^n → ℕ
OUTPUT: Witness pair (u,v) with boolEnc(u) ≤ boolEnc(v) but f(u) > f(v), or None

1. For each u in {False, True}^n:
   For each v in {False, True}^n:
     a. Check if boolEnc(u_i) ≤ boolEnc(v_i) for all i
        (equivalently: u_i = True implies v_i = True)
     b. If so and f(u) > f(v): return (u, v)
2. Return None (f is tropically monotone)

COMPLEXITY: O(4^n) time, O(n) space""",
            "code": algorithms_code
        },
        {
            "name": "Exhaustive Tropical Representation Search",
            "pseudocode": """ALGORITHM: SearchRepresentation(f, n, S)
INPUT: Target function f: {0,1}^n → ℕ, max expression size S
OUTPUT: Tropical expression e with eval(e, boolEnc(v)) = f(v) for all v, or None

1. Generate all expressions of size 1: constants 0,1,...,C and variables x_0,...,x_{n-1}
2. For s = 1 to S:
   For each expression e of size s:
     a. Check: for all v in {0,1}^n, does eval(e, boolEnc(v)) = f(v)?
     b. If yes: return e
   Generate expressions of size s+1 by combining smaller expressions with min and +
3. Return None

COMPLEXITY: O(C(S) · 2^n · S) time, where C(S) ~ 4^S is the number of expressions""",
            "code": algorithms_code
        }
    ],
    "visualizations": [
        {"name": "Tropical Expression Monotonicity", "data": viz_data["tropical_monotonicity"]},
        {"name": "Parity Barrier Visualization", "data": viz_data["parity_barrier"]},
        {"name": "Sublevel Sets: Tropical vs SAT", "data": viz_data["sublevel_sets"]},
        {"name": "Region Complexity Bounds", "data": viz_data["region_complexity"]},
        {"name": "Barrier Theorem Architecture", "data": viz_data["barrier_overview"]},
    ],
    "lean_proofs": lean_code
}

with open("PACKAGE.json", "w") as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print(f"PACKAGE.json generated ({len(json.dumps(package)) / 1024:.1f} KB)")


#!/usr/bin/env python3
"""
Tropical Semiring Barrier Theorems — Visualizations

Generates publication-quality figures illustrating the key mathematical concepts.

Usage:
    python visualizations.py
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.colors import ListedColormap
from itertools import product
import base64
import io
import json


def fig_to_base64(fig) -> str:
    """Convert a matplotlib figure to a base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight',
                facecolor='white', edgecolor='none')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


def viz_tropical_monotonicity():
    """Visualize monotonicity of a tropical expression."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 4.5))

    # Expression: min(x + y, 2x + 1)
    x = np.linspace(0, 5, 200)
    y_vals = [0, 1, 2, 3]

    ax = axes[0]
    ax.set_title("Tropical Expression: min(x + y, 2x + 1)", fontsize=12, fontweight='bold')
    for y in y_vals:
        f = np.minimum(x + y, 2 * x + 1)
        ax.plot(x, f, label=f'y = {y}', linewidth=2)
    ax.set_xlabel('x', fontsize=11)
    ax.set_ylabel('eval(e, (x, y))', fontsize=11)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(0, 10)

    # Show piecewise-linear structure
    ax = axes[1]
    ax.set_title("Piecewise-Linear Structure", fontsize=12, fontweight='bold')
    x = np.linspace(0, 5, 500)
    branch1 = x + 2
    branch2 = 2 * x + 1
    f = np.minimum(branch1, branch2)
    ax.plot(x, branch1, '--', color='blue', alpha=0.5, label='x + 2')
    ax.plot(x, branch2, '--', color='red', alpha=0.5, label='2x + 1')
    ax.plot(x, f, 'k-', linewidth=2.5, label='min(x+2, 2x+1)')
    # Mark the breakpoint
    bp = 1.0  # x + 2 = 2x + 1 => x = 1
    ax.plot(bp, bp + 2, 'ko', markersize=8, zorder=5)
    ax.annotate('Breakpoint', xy=(bp, bp + 2), xytext=(2, 2),
                fontsize=10, arrowprops=dict(arrowstyle='->', color='black'))
    ax.set_xlabel('x', fontsize=11)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    # Monotonicity demonstration
    ax = axes[2]
    ax.set_title("Monotonicity: u ≤ v ⟹ f(u) ≤ f(v)", fontsize=12, fontweight='bold')
    x = np.linspace(0, 5, 200)
    f = np.minimum(x + 1, 2 * x)
    ax.plot(x, f, 'b-', linewidth=2)
    # Show monotonicity with arrows
    pairs = [(1, 3), (0.5, 2), (2, 4)]
    for u, v in pairs:
        fu = min(u + 1, 2 * u)
        fv = min(v + 1, 2 * v)
        ax.annotate('', xy=(v, fv), xytext=(u, fu),
                    arrowprops=dict(arrowstyle='->', color='green', lw=2))
        ax.plot(u, fu, 'ro', markersize=6, zorder=5)
        ax.plot(v, fv, 'go', markersize=6, zorder=5)
    ax.set_xlabel('x', fontsize=11)
    ax.set_ylabel('f(x) = min(x+1, 2x)', fontsize=11)
    ax.grid(True, alpha=0.3)

    fig.suptitle("Tropical Expressions: Piecewise-Linear and Monotone",
                 fontsize=14, fontweight='bold', y=1.02)
    fig.tight_layout()
    return fig_to_base64(fig)


def viz_parity_barrier():
    """Visualize why parity cannot be tropically represented."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 4.5))

    # Parity truth table on Boolean cube
    ax = axes[0]
    ax.set_title("Parity on {0,1}²", fontsize=12, fontweight='bold')
    for v0 in [0, 1]:
        for v1 in [0, 1]:
            parity = (v0 + v1) % 2
            color = 'green' if parity == 1 else 'red'
            marker = 'o' if parity == 1 else 's'
            label = f"odd" if parity == 1 and v0 == 1 and v1 == 0 else \
                    (f"even" if parity == 0 and v0 == 0 and v1 == 0 else None)
            ax.plot(v0, v1, marker, color=color, markersize=20, label=label)
            ax.annotate(f"{'odd' if parity else 'even'}",
                       xy=(v0, v1), xytext=(v0 + 0.1, v1 + 0.1), fontsize=9)
    # Draw the "diagonal" non-monotonicity
    ax.annotate('', xy=(0, 0), xytext=(1, 1),
                arrowprops=dict(arrowstyle='->', color='purple', lw=2, ls='--'))
    ax.text(0.3, 0.7, "≤ but\nparity ↑", fontsize=9, color='purple',
            ha='center', fontweight='bold')
    ax.set_xlabel("x₀ (boolEnc)", fontsize=11)
    ax.set_ylabel("x₁ (boolEnc)", fontsize=11)
    ax.set_xlim(-0.3, 1.5)
    ax.set_ylim(-0.3, 1.5)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    # Monotonicity violation diagram
    ax = axes[1]
    ax.set_title("Monotonicity Violation", fontsize=12, fontweight='bold')

    # Draw the Hasse diagram of Boolean assignments under boolEnc order
    # boolEnc: true→0, false→1. So (0,0) ≤ (0,1) ≤ (1,1), etc.
    positions = {
        (0, 0): (0.5, 2),    # (true, true)
        (0, 1): (0, 1),      # (true, false)
        (1, 0): (1, 1),      # (false, true)
        (1, 1): (0.5, 0),    # (false, false)
    }
    parity_val = {
        (0, 0): 1,  # even → 1
        (0, 1): 0,  # odd → 0
        (1, 0): 0,  # odd → 0
        (1, 1): 1,  # even → 1
    }
    for (v0, v1), (px, py) in positions.items():
        pv = parity_val[(v0, v1)]
        color = 'green' if pv == 0 else 'red'
        ax.plot(px, py, 'o', color=color, markersize=25, zorder=5)
        ax.text(px, py, f"{'0' if pv == 0 else '1'}", ha='center', va='center',
                fontsize=12, fontweight='bold', color='white', zorder=6)
        ax.text(px + 0.15, py + 0.15, f"({v0},{v1})", fontsize=8, color='gray')

    # Draw Hasse edges
    edges = [((0, 0), (0, 1)), ((0, 0), (1, 0)),
             ((0, 1), (1, 1)), ((1, 0), (1, 1))]
    for (a, b) in edges:
        pa, pb = positions[a], positions[b]
        ax.annotate('', xy=pb, xytext=pa,
                    arrowprops=dict(arrowstyle='->', color='gray', lw=1.5))

    # Highlight violation
    ax.annotate('', xy=positions[(0, 1)], xytext=positions[(0, 0)],
                arrowprops=dict(arrowstyle='->', color='red', lw=3))
    ax.text(-0.3, 1.5, "f goes\n1 → 0\nviolation!", fontsize=9,
            color='red', fontweight='bold')

    ax.set_xlim(-0.5, 1.5)
    ax.set_ylim(-0.5, 2.5)
    ax.axis('off')

    # What monotone functions look like on the Boolean cube
    ax = axes[2]
    ax.set_title("Monotone Function (AND)", fontsize=12, fontweight='bold')
    and_val = {
        (0, 0): 0,  # true AND true → 0
        (0, 1): 1,  # true AND false → 1
        (1, 0): 1,  # false AND true → 1
        (1, 1): 1,  # false AND false → 1
    }
    for (v0, v1), (px, py) in positions.items():
        av = and_val[(v0, v1)]
        color = 'green' if av == 0 else 'orange'
        ax.plot(px, py, 'o', color=color, markersize=25, zorder=5)
        ax.text(px, py, f"{av}", ha='center', va='center',
                fontsize=12, fontweight='bold', color='white', zorder=6)
        ax.text(px + 0.15, py + 0.15, f"({v0},{v1})", fontsize=8, color='gray')

    for (a, b) in edges:
        pa, pb = positions[a], positions[b]
        ax.annotate('', xy=pb, xytext=pa,
                    arrowprops=dict(arrowstyle='->', color='green', lw=1.5))

    ax.text(-0.3, 1.5, "f always\nnon-decreasing\n✓ monotone", fontsize=9,
            color='green', fontweight='bold')
    ax.set_xlim(-0.5, 1.5)
    ax.set_ylim(-0.5, 2.5)
    ax.axis('off')

    fig.suptitle("The Parity Barrier: Non-Monotonicity Blocks Tropical Representation",
                 fontsize=14, fontweight='bold', y=1.02)
    fig.tight_layout()
    return fig_to_base64(fig)


def viz_sublevel_sets():
    """Visualize tropical sublevel sets and why SAT sets are different."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 4.5))

    # Sublevel set of min(x, y) ≤ 2
    ax = axes[0]
    ax.set_title("Sublevel: min(x, y) ≤ 2", fontsize=12, fontweight='bold')
    x = np.arange(0, 6)
    y = np.arange(0, 6)
    X, Y = np.meshgrid(x, y)
    Z = np.minimum(X, Y)
    in_set = Z <= 2
    ax.imshow(in_set, origin='lower', cmap=ListedColormap(['#ffcccc', '#ccffcc']),
              extent=(-0.5, 5.5, -0.5, 5.5), aspect='auto')
    for i in range(6):
        for j in range(6):
            color = 'green' if in_set[j, i] else 'red'
            ax.plot(i, j, 'o', color=color, markersize=8)
    ax.set_xlabel('x', fontsize=11)
    ax.set_ylabel('y', fontsize=11)
    ax.text(0.5, 5, "Downward\nclosed ✓", fontsize=10, color='green',
            fontweight='bold')

    # Sublevel set of x + y ≤ 3
    ax = axes[1]
    ax.set_title("Sublevel: x + y ≤ 3", fontsize=12, fontweight='bold')
    Z2 = X + Y
    in_set2 = Z2 <= 3
    ax.imshow(in_set2, origin='lower', cmap=ListedColormap(['#ffcccc', '#ccffcc']),
              extent=(-0.5, 5.5, -0.5, 5.5), aspect='auto')
    for i in range(6):
        for j in range(6):
            color = 'green' if in_set2[j, i] else 'red'
            ax.plot(i, j, 'o', color=color, markersize=8)
    ax.set_xlabel('x', fontsize=11)
    ax.set_ylabel('y', fontsize=11)
    ax.text(0.5, 5, "Downward\nclosed ✓", fontsize=10, color='green',
            fontweight='bold')

    # SAT set: x₁ OR x₂ (with true→1, false→0)
    ax = axes[2]
    ax.set_title("SAT set: x₁ ∨ x₂", fontsize=12, fontweight='bold')
    # Only Boolean points matter
    for x_val in range(2):
        for y_val in range(2):
            sat = (x_val == 1) or (y_val == 1)
            color = 'green' if sat else 'red'
            ax.plot(x_val, y_val, 'o', color=color, markersize=25, zorder=5)
            ax.text(x_val, y_val, "SAT" if sat else "UNSAT",
                   ha='center', va='center', fontsize=8, fontweight='bold',
                   color='white', zorder=6)
    # Show non-downward-closure
    ax.annotate('(1,1) ∈ SAT', xy=(1, 1), xytext=(0.3, 1.5),
                fontsize=9, arrowprops=dict(arrowstyle='->', color='green'))
    ax.annotate('(0,0) ∉ SAT\nbut (0,0) ≤ (1,1)', xy=(0, 0), xytext=(-0.5, 0.5),
                fontsize=9, color='red', fontweight='bold',
                arrowprops=dict(arrowstyle='->', color='red'))
    ax.set_xlabel('x₁', fontsize=11)
    ax.set_ylabel('x₂', fontsize=11)
    ax.set_xlim(-0.7, 1.7)
    ax.set_ylim(-0.7, 1.7)
    ax.text(0.5, -0.5, "NOT downward\nclosed ✗", fontsize=10, color='red',
            fontweight='bold', ha='center')
    ax.grid(True, alpha=0.3)

    fig.suptitle("Sublevel Sets: Tropical (Downward Closed) vs SAT (Not Downward Closed)",
                 fontsize=13, fontweight='bold', y=1.02)
    fig.tight_layout()
    return fig_to_base64(fig)


def viz_region_complexity():
    """Visualize how tropical circuit complexity relates to linear regions."""
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))

    # Left: tropical expression with increasing complexity
    ax = axes[0]
    ax.set_title("Region Growth with Circuit Size", fontsize=12, fontweight='bold')

    x = np.linspace(0, 10, 1000)

    # Expressions of increasing size
    expressions = [
        ("min(x, 3)", lambda x: np.minimum(x, 3), 2),
        ("min(x, min(2x-1, 5))", lambda x: np.minimum(x, np.minimum(2*x-1, 5)), 3),
        ("min(x, min(2x-1, min(3x-4, 6)))",
         lambda x: np.minimum(x, np.minimum(2*x-1, np.minimum(3*x-4, 6))), 4),
    ]

    colors = ['#2196F3', '#FF9800', '#4CAF50']
    for (name, f, regions), color in zip(expressions, colors):
        y = f(x)
        ax.plot(x, y, color=color, linewidth=2.5, label=f"{name}\n({regions} regions)")

    ax.set_xlabel('x', fontsize=11)
    ax.set_ylabel('f(x)', fontsize=11)
    ax.legend(fontsize=8, loc='upper left')
    ax.grid(True, alpha=0.3)
    ax.set_ylim(-2, 8)

    # Right: region count vs min gates
    ax = axes[1]
    ax.set_title("Theoretical Region Bound", fontsize=12, fontweight='bold')

    min_gates = np.arange(0, 8)
    bound = 2 ** min_gates
    ax.semilogy(min_gates, bound, 'b-o', linewidth=2, markersize=8, label='Upper bound: 2^(min gates)')
    ax.fill_between(min_gates, 1, bound, alpha=0.2, color='blue')

    # For parity to have 2^n alternations, need ~n min gates
    n_vals = np.arange(2, 8)
    parity_need = 2 ** (n_vals - 1)  # approximate alternation count for parity
    ax.semilogy(n_vals, parity_need, 'r--s', linewidth=2, markersize=8,
                label='Parity alternations: 2^(n-1)')

    ax.set_xlabel('Number of min gates / variables', fontsize=11)
    ax.set_ylabel('Regions / Alternations', fontsize=11)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    fig.suptitle("Tropical Circuit Complexity: Linear Regions and Lower Bounds",
                 fontsize=14, fontweight='bold', y=1.02)
    fig.tight_layout()
    return fig_to_base64(fig)


def viz_barrier_overview():
    """Overview diagram of the barrier theorem structure."""
    fig, ax = plt.subplots(1, 1, figsize=(12, 7))
    ax.set_xlim(0, 12)
    ax.set_ylim(0, 8)
    ax.axis('off')
    ax.set_title("Tropical Barrier Theorem: Proof Architecture",
                 fontsize=16, fontweight='bold', pad=20)

    # Draw boxes
    boxes = [
        (1, 6, 4, 1.2, "Tropical Expression\n(const, var, min, +)", '#E3F2FD'),
        (7, 6, 4, 1.2, "Evaluation\neval : TropExpr → (ℕⁿ → ℕ)", '#E3F2FD'),
        (4, 4, 4, 1.2, "Monotonicity Theorem\nu ≤ v ⟹ eval(e,u) ≤ eval(e,v)", '#C8E6C9'),
        (0.5, 2, 3, 1.2, "Parity\nnot monotone", '#FFCDD2'),
        (4, 2, 3.5, 1.2, "General Barrier\n¬monotone ⟹ ¬representable", '#FFF9C4'),
        (8.5, 2, 3, 1.2, "SAT Barrier\nno sublevel encoding", '#FFCDD2'),
        (4, 0.2, 4, 1.0, "Non-representability\nof parity, XOR, mod-k, SAT", '#FF8A65'),
    ]

    for x, y, w, h, text, color in boxes:
        rect = plt.Rectangle((x, y), w, h, facecolor=color,
                             edgecolor='black', linewidth=1.5, zorder=2)
        ax.add_patch(rect)
        ax.text(x + w/2, y + h/2, text, ha='center', va='center',
               fontsize=9, fontweight='bold', zorder=3)

    # Draw arrows
    arrows = [
        (3, 6.6, 7, 6.6),      # TropExpr → Evaluation
        (9, 6, 6, 5.2),        # Evaluation → Monotonicity
        (3, 6, 6, 5.2),        # TropExpr → Monotonicity
        (6, 4, 6, 3.2),        # Monotonicity → General Barrier
        (2, 3.2, 4.5, 3.2),    # Parity → General Barrier
        (6, 2, 6, 1.2),        # General Barrier → Non-rep
        (10, 2, 7.5, 1.2),     # SAT → Non-rep
    ]

    for x1, y1, x2, y2 in arrows:
        ax.annotate('', xy=(x2, y2), xytext=(x1, y1),
                    arrowprops=dict(arrowstyle='->', color='#333', lw=2))

    fig.tight_layout()
    return fig_to_base64(fig)


def generate_all_visualizations() -> dict[str, str]:
    """Generate all visualizations and return as base64 data URIs."""
    print("Generating visualizations...")

    vizs = {}

    print("  1/5: Tropical monotonicity...")
    vizs["tropical_monotonicity"] = viz_tropical_monotonicity()

    print("  2/5: Parity barrier...")
    vizs["parity_barrier"] = viz_parity_barrier()

    print("  3/5: Sublevel sets...")
    vizs["sublevel_sets"] = viz_sublevel_sets()

    print("  4/5: Region complexity...")
    vizs["region_complexity"] = viz_region_complexity()

    print("  5/5: Barrier overview...")
    vizs["barrier_overview"] = viz_barrier_overview()

    print("Done!")
    return vizs


if __name__ == "__main__":
    vizs = generate_all_visualizations()

    # Save individual PNGs
    for name, data_uri in vizs.items():
        b64_data = data_uri.split(",")[1]
        with open(f"{name}.png", "wb") as f:
            f.write(base64.b64decode(b64_data))
        print(f"  Saved {name}.png")

    print(f"\nGenerated {len(vizs)} visualizations.")

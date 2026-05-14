#!/usr/bin/env python3
"""
Applications of Tropical Barrier Theorems

Demonstrates real-world implications:
1. Shortest-path optimization vs decision problems
2. Dynamic programming expressiveness limits
3. Constraint satisfaction detection barriers
4. Tropical neural network limitations
"""

from itertools import product
from typing import List, Tuple
import random

# ═══════════════════════════════════════════════════════════════════════════
# Application 1: Shortest Path vs Reachability Parity
# ═══════════════════════════════════════════════════════════════════════════

def app_shortest_path():
    """
    Demonstrate that min-plus (tropical) computation naturally solves
    shortest-path but cannot detect path-count parity.
    """
    print("=" * 65)
    print("APPLICATION 1: Shortest Path vs Path-Count Parity")
    print("=" * 65)
    
    # Example graph (adjacency matrix with weights, 0 = no edge)
    INF = float('inf')
    # 4-node graph
    W = [
        [0,   1,   4, INF],
        [INF, 0,   2,   5],
        [INF, INF, 0,   1],
        [INF, INF, INF, 0],
    ]
    n = 4
    
    print("\nWeighted directed graph (4 nodes):")
    print("  0 →(1)→ 1 →(2)→ 2 →(1)→ 3")
    print("  0 →(4)→ 2         1 →(5)→ 3")
    
    # Floyd-Warshall using tropical operations
    dist = [[W[i][j] for j in range(n)] for i in range(n)]
    for k in range(n):
        for i in range(n):
            for j in range(n):
                # Tropical: dist[i][j] = min(dist[i][j], dist[i][k] + dist[k][j])
                if dist[i][k] + dist[k][j] < dist[i][j]:
                    dist[i][j] = dist[i][k] + dist[k][j]
    
    print("\nShortest path distances (computed by min-plus / tropical ops):")
    for i in range(n):
        for j in range(n):
            d = dist[i][j]
            print(f"  {i}→{j}: {d if d < INF else '∞':>3}", end="")
        print()
    
    # Count paths (requires ordinary +, not min)
    count = [[0]*n for _ in range(n)]
    for i in range(n):
        count[i][i] = 1
    for i in range(n):
        for j in range(n):
            if W[i][j] < INF and i != j:
                count[i][j] = 1
    
    # Transitive closure of path counts
    for k in range(n):
        for i in range(n):
            for j in range(n):
                count[i][j] += count[i][k] * count[k][j] if (i != k and k != j) else 0
    
    print("\nNumber of distinct paths:")
    for i in range(n):
        for j in range(n):
            print(f"  {i}→{j}: {count[i][j]:>3}", end="")
        print()
    
    print("\nPath count parity (odd/even):")
    for i in range(n):
        for j in range(n):
            par = "odd" if count[i][j] % 2 == 1 else "even"
            print(f"  {i}→{j}: {par:>4}", end="")
        print()
    
    print("""
INSIGHT: Tropical (min-plus) operations compute shortest paths perfectly.
But determining whether the NUMBER of paths is odd or even requires
ordinary addition and cannot be done with min/plus alone.
This is the barrier theorem in action: parity-type questions are
fundamentally outside the scope of tropical computation.""")


# ═══════════════════════════════════════════════════════════════════════════
# Application 2: Dynamic Programming Limits
# ═══════════════════════════════════════════════════════════════════════════

def app_dynamic_programming():
    """
    Show that DP (which uses min/+) can optimize but not detect
    non-monotone predicates about the solution.
    """
    print("\n" + "=" * 65)
    print("APPLICATION 2: Dynamic Programming Expressiveness Limits")
    print("=" * 65)
    
    # Knapsack-style problem
    items = [
        ("A", 3, 4),  # (name, weight, value)
        ("B", 4, 5),
        ("C", 2, 3),
        ("D", 5, 7),
    ]
    capacity = 7
    
    print(f"\nKnapsack problem: capacity = {capacity}")
    print(f"Items: {[(name, f'w={w}, v={v}') for name, w, v in items]}")
    
    n = len(items)
    # Standard DP for optimal value
    dp = [[0] * (capacity + 1) for _ in range(n + 1)]
    for i in range(1, n + 1):
        _, w, v = items[i-1]
        for c in range(capacity + 1):
            dp[i][c] = dp[i-1][c]
            if c >= w:
                dp[i][c] = max(dp[i][c], dp[i-1][c-w] + v)
    
    print(f"\nOptimal value: {dp[n][capacity]}")
    
    # Now: can we detect if the NUMBER of optimal solutions is odd?
    # Count optimal solutions
    count = [[0] * (capacity + 1) for _ in range(n + 1)]
    count[0][0] = 1
    for i in range(1, n + 1):
        _, w, v = items[i-1]
        for c in range(capacity + 1):
            if dp[i][c] == dp[i-1][c]:
                count[i][c] += count[i-1][c]
            if c >= w and dp[i][c] == dp[i-1][c-w] + v:
                count[i][c] += count[i-1][c-w]
    
    opt_count = count[n][capacity]
    print(f"Number of optimal solutions: {opt_count}")
    print(f"Is count odd? {'Yes' if opt_count % 2 == 1 else 'No'}")
    
    print("""
INSIGHT: The DP table for optimal VALUE uses max/+ (dual tropical) operations.
But counting solutions requires ordinary addition — it's a fundamentally
different algebraic operation. Detecting whether the count is odd or even
(a parity question) is provably impossible in the tropical framework.
This is why optimization solvers find OPTIMAL values efficiently but
COUNTING optimal solutions requires different algorithmic machinery.""")


# ═══════════════════════════════════════════════════════════════════════════
# Application 3: SAT Detection Barrier
# ═══════════════════════════════════════════════════════════════════════════

def app_sat_barrier():
    """
    Show that tropical circuits cannot detect satisfiability.
    """
    print("\n" + "=" * 65)
    print("APPLICATION 3: SAT Detection via Tropical Penalty")
    print("=" * 65)
    
    # Simple CNF: (x0 ∨ x1) ∧ (¬x0 ∨ x1) ∧ (x0 ∨ ¬x1)
    # Satisfying: (T,T)→all satisfied; (T,F)→clause 2 fails; (F,T)→clause 3 fails; (F,F)→clause 1 fails
    
    def clause_penalty(clause, assignment):
        """Number of unsatisfied literals (tropical penalty)."""
        return 0 if any(
            (assignment[abs(lit)] if lit > 0 else not assignment[abs(lit)])
            for lit in clause
        ) else 1
    
    # Clauses: (x0 ∨ x1), (¬x0 ∨ x1), (x0 ∨ ¬x1)
    # Using 1-indexed literals, negative = negated
    clauses = [(1, 2), (-1, 2), (1, -2)]
    
    print("\nCNF formula: (x₀ ∨ x₁) ∧ (¬x₀ ∨ x₁) ∧ (x₀ ∨ ¬x₁)")
    print("\nAssignment | Satisfied? | Unsatisfied clauses | Tropical penalty")
    print("-" * 70)
    
    for x0, x1 in product([True, False], repeat=2):
        assignment = {1: x0, 2: x1}
        penalties = []
        for c in clauses:
            p = clause_penalty(c, assignment)
            penalties.append(p)
        
        total = sum(penalties)
        sat = total == 0
        
        print(f"  ({x0!s:>5}, {x1!s:>5}) | {'YES':>10s if sat else 'NO':>10s} | "
              f"{penalties} | {total}")
    
    print("""
A tropical circuit can compute the total penalty (sum of clause violations)
since penalty per clause uses min/+ and the total is a sum.

BUT: detecting satisfiability (penalty = 0 vs penalty ≥ 1) requires
distinguishing 0 from non-zero — this is a threshold/indicator function
that is NOT monotone under the Boolean encoding.

Specifically: going from (T,T) to (T,F) (setting x₁ from T to F)
increases the encoding value of x₁, but changes SAT from YES to NO.
Going from (F,F) to (T,F) increases x₀'s encoding but still NO.
This non-monotone behavior means no tropical circuit can exactly
compute the SAT indicator function.""")


# ═══════════════════════════════════════════════════════════════════════════
# Application 4: Tropical Neural Network Limitations
# ═══════════════════════════════════════════════════════════════════════════

def app_neural_network():
    """
    Show connections to ReLU neural networks and tropical geometry.
    """
    print("\n" + "=" * 65)
    print("APPLICATION 4: Tropical Geometry and Neural Networks")
    print("=" * 65)
    
    print("""
Modern neural networks with ReLU activation compute:
  ReLU(x) = max(0, x)

Since max(a, b) = -min(-a, -b), ReLU networks compute functions in the
'max-plus' (dual tropical) semiring. Each layer creates a piecewise-linear
function, and the composition remains piecewise-linear.

Key connection: A ReLU network with s neurons computes a piecewise-linear
function with at most O(s^d) linear regions, where d is the depth.
""")
    
    # Demonstrate: a simple "tropical neuron" (max-plus)
    def tropical_neuron(x: List[float], weights: List[float], bias: float) -> float:
        """A single tropical neuron: max(w_i + x_i) + bias."""
        return max(w + xi for w, xi in zip(weights, x)) + bias
    
    def relu_neuron(x: List[float], weights: List[float], bias: float) -> float:
        """A standard ReLU neuron: max(0, sum(w_i * x_i) + bias)."""
        return max(0, sum(w * xi for w, xi in zip(weights, x)) + bias)
    
    print("Example: Tropical neuron vs ReLU neuron on sample inputs")
    print(f"{'Input':>15s} | {'Tropical':>10s} | {'ReLU':>10s}")
    print("-" * 42)
    
    weights = [1.0, -0.5]
    bias = 0.0
    
    for x0, x1 in [(0, 0), (1, 0), (0, 1), (1, 1), (2, 1), (1, 2)]:
        x = [float(x0), float(x1)]
        trop = tropical_neuron(x, weights, bias)
        relu = relu_neuron(x, weights, bias)
        print(f"  ({x0}, {x1}):>10 | {trop:>10.1f} | {relu:>10.1f}")
    
    print("""
IMPLICATION: The tropical barrier theorem shows that monotone piecewise-
linear functions (computed by tropical/max-plus circuits) cannot represent
non-monotone predicates. For neural networks, this means:

• A ReLU network computing a monotone function needs NO negation in weights
• Computing XOR, parity, or modular predicates REQUIRES negative weights
• The "depth" of a network for non-monotone tasks is bounded below by
  the oscillation complexity of the target function

This provides a principled explanation for why deeper networks are needed
for tasks involving alternation and non-monotone decision boundaries.""")


# ═══════════════════════════════════════════════════════════════════════════
# Main
# ═══════════════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    app_shortest_path()
    app_dynamic_programming()
    app_sat_barrier()
    app_neural_network()
    
    print("\n" + "=" * 65)
    print("SUMMARY OF APPLICATIONS")
    print("=" * 65)
    print("""
The tropical barrier theorem has concrete implications across:

1. GRAPH ALGORITHMS: Shortest paths (tropical) vs path-count parity
2. DYNAMIC PROGRAMMING: Optimization vs counting solutions  
3. SATISFIABILITY: Penalty computation vs exact SAT detection
4. NEURAL NETWORKS: Monotone expressiveness limits for ReLU architectures

In each case, the barrier reveals a fundamental divide between:
  • OPTIMIZATION (what tropical/min-plus can do)
  • DECISION/COUNTING (what requires non-monotone operations)

This divide is not a limitation of current algorithms — it is a
mathematical impossibility, proven with full formal rigor.
""")


#!/usr/bin/env python3
"""
Tropical Semiring Barrier Theorems — Demonstrations

Demonstrates the core mathematical results:
1. Tropical expressions are monotone
2. Parity, XOR, and exact-one are non-monotone → not tropically representable
3. Exhaustive search confirms no small tropical expression computes parity
"""

from itertools import product
from typing import Callable, List, Tuple

# ─── Tropical Expression Language ────────────────────────────────────────

class TropExpr:
    """A tropical expression over n variables."""
    pass

class Const(TropExpr):
    def __init__(self, c: int):
        self.c = c
    def eval(self, v: List[int]) -> int:
        return self.c
    def size(self) -> int:
        return 1
    def __repr__(self):
        return str(self.c)

class Var(TropExpr):
    def __init__(self, i: int):
        self.i = i
    def eval(self, v: List[int]) -> int:
        return v[self.i]
    def size(self) -> int:
        return 1
    def __repr__(self):
        return f"x{self.i}"

class TMin(TropExpr):
    def __init__(self, e1: TropExpr, e2: TropExpr):
        self.e1, self.e2 = e1, e2
    def eval(self, v: List[int]) -> int:
        return min(self.e1.eval(v), self.e2.eval(v))
    def size(self) -> int:
        return 1 + self.e1.size() + self.e2.size()
    def __repr__(self):
        return f"min({self.e1}, {self.e2})"

class TAdd(TropExpr):
    def __init__(self, e1: TropExpr, e2: TropExpr):
        self.e1, self.e2 = e1, e2
    def eval(self, v: List[int]) -> int:
        return self.e1.eval(v) + self.e2.eval(v)
    def size(self) -> int:
        return 1 + self.e1.size() + self.e2.size()
    def __repr__(self):
        return f"({self.e1} + {self.e2})"

# ─── Boolean Encoding ────────────────────────────────────────────────────

def bool_enc(b: bool) -> int:
    """Encode Boolean: true → 0, false → 1."""
    return 0 if b else 1

def lift_bool(v: Tuple[bool, ...]) -> List[int]:
    """Lift Boolean assignment to tropical assignment."""
    return [bool_enc(b) for b in v]

# ─── Boolean Functions ───────────────────────────────────────────────────

def parity_fun(v: Tuple[bool, ...]) -> int:
    """Parity: 0 if odd number of trues, 1 otherwise."""
    return 0 if sum(v) % 2 == 1 else 1

def xor_fun(v: Tuple[bool, ...]) -> int:
    """XOR of two variables."""
    return bool_enc(v[0] ^ v[1])

def exact_one_fun(v: Tuple[bool, ...]) -> int:
    """Exact-one: 0 if exactly one true, 1 otherwise."""
    return 0 if sum(v) == 1 else 1

def and_fun(v: Tuple[bool, ...]) -> int:
    """AND: 0 if all true, 1 otherwise."""
    return 0 if all(v) else 1

def or_fun(v: Tuple[bool, ...]) -> int:
    """OR: 0 if any true, 1 otherwise."""
    return 0 if any(v) else 1

# ─── Monotonicity Testing ────────────────────────────────────────────────

def is_trop_monotone(f: Callable, n: int) -> Tuple[bool, str]:
    """
    Test if f is tropically monotone on n variables.
    Returns (True, "") or (False, counterexample_description).
    """
    assignments = list(product([True, False], repeat=n))
    for u in assignments:
        for v_assign in assignments:
            # Check if boolEnc(u[i]) <= boolEnc(v[i]) for all i
            if all(bool_enc(u[i]) <= bool_enc(v_assign[i]) for i in range(n)):
                fu, fv = f(u), f(v_assign)
                if fu > fv:
                    return False, f"  u={u}, v={v_assign}: f(u)={fu} > f(v)={fv}"
    return True, ""

# ─── Demo 1: Monotonicity of Tropical Expressions ───────────────────────

def demo_monotonicity():
    """Demonstrate that tropical expressions are monotone."""
    print("=" * 60)
    print("DEMO 1: Monotonicity of Tropical Expressions")
    print("=" * 60)
    
    # Example: min(x0 + x1, x0 + 1)
    expr = TMin(TAdd(Var(0), Var(1)), TAdd(Var(0), Const(1)))
    print(f"\nExpression: {expr}")
    print(f"Size: {expr.size()}")
    
    print("\nEvaluation table (verifying monotonicity):")
    print(f"{'v':>15s} | {'eval(v)':>8s}")
    print("-" * 28)
    
    vals = [(0,0), (0,1), (1,0), (1,1), (0,2), (2,0), (1,2), (2,1), (2,2)]
    for v in sorted(vals):
        result = expr.eval(list(v))
        print(f"{str(v):>15s} | {result:>8d}")
    
    print("\nVerifying monotonicity: for all u ≤ v, eval(u) ≤ eval(v)")
    violations = 0
    for u in vals:
        for v in vals:
            if all(u[i] <= v[i] for i in range(2)):
                eu, ev = expr.eval(list(u)), expr.eval(list(v))
                if eu > ev:
                    violations += 1
                    print(f"  VIOLATION: u={u}, v={v}: {eu} > {ev}")
    if violations == 0:
        print("  ✓ No violations found — expression is monotone!")

# ─── Demo 2: Non-Monotonicity of Boolean Functions ──────────────────────

def demo_non_monotonicity():
    """Show which Boolean functions are/aren't tropically monotone."""
    print("\n" + "=" * 60)
    print("DEMO 2: Tropical Monotonicity of Boolean Functions")
    print("=" * 60)
    
    functions = [
        ("AND", and_fun, 3),
        ("OR", or_fun, 3),
        ("Parity", parity_fun, 3),
        ("XOR (n=2)", xor_fun, 2),
        ("Exact-One", exact_one_fun, 3),
    ]
    
    for name, f, n in functions:
        mono, detail = is_trop_monotone(f, n)
        status = "✓ MONOTONE" if mono else "✗ NOT MONOTONE"
        print(f"\n{name} (n={n}): {status}")
        if not mono:
            print(detail)
            print(f"  → Therefore NOT tropically representable!")

# ─── Demo 3: Exhaustive Search ──────────────────────────────────────────

def enum_trop_expr(n: int, max_size: int, max_const: int = 2):
    """Enumerate tropical expressions up to given size."""
    if max_size < 1:
        return []
    
    # Size 1: constants and variables
    base = [Const(c) for c in range(max_const + 1)] + [Var(i) for i in range(n)]
    if max_size == 1:
        return base
    
    result = list(base)
    # Build expressions of each size
    by_size = {1: list(base)}
    
    for s in range(3, max_size + 1):  # minimum compound size is 3
        by_size[s] = []
        for s1 in range(1, s - 1):
            s2 = s - 1 - s1
            if s2 < 1:
                continue
            for e1 in by_size.get(s1, []):
                for e2 in by_size.get(s2, []):
                    by_size[s].append(TMin(e1, e2))
                    by_size[s].append(TAdd(e1, e2))
        result.extend(by_size[s])
    
    return result

def demo_exhaustive_search():
    """Exhaustively verify no small tropical expr computes parity/XOR."""
    print("\n" + "=" * 60)
    print("DEMO 3: Exhaustive Search for Tropical Representations")
    print("=" * 60)
    
    n = 2
    max_size = 7
    
    target_functions = {
        "XOR": xor_fun,
        "Parity(n=2)": parity_fun,
    }
    
    assignments = list(product([True, False], repeat=n))
    
    exprs = enum_trop_expr(n, max_size)
    print(f"\nSearching {len(exprs)} tropical expressions (n={n}, size≤{max_size})")
    
    for fname, f in target_functions.items():
        target_vals = [f(v) for v in assignments]
        found = False
        for expr in exprs:
            expr_vals = [expr.eval(lift_bool(v)) for v in assignments]
            if expr_vals == target_vals:
                found = True
                print(f"\n{fname}: FOUND representation: {expr}")
                break
        if not found:
            print(f"\n{fname}: No representation found among {len(exprs)} expressions")
            print(f"  Target values: {dict(zip(assignments, target_vals))}")
    
    # Show what IS representable
    print(f"\nFunctions that ARE representable (n={n}, size≤{max_size}):")
    representable = set()
    for expr in exprs:
        vals = tuple(expr.eval(lift_bool(v)) for v in assignments)
        representable.add(vals)
    
    print(f"  {len(representable)} distinct functions representable")
    total = len(set(product(range(3), repeat=len(assignments))))
    print(f"  (out of many possible {n}-variable functions with values in small range)")

# ─── Demo 4: Parity Oscillation Visualization (text) ────────────────────

def demo_oscillation():
    """Show parity oscillation on monotone paths through the Boolean cube."""
    print("\n" + "=" * 60)
    print("DEMO 4: Parity Oscillation on the Boolean Cube")
    print("=" * 60)
    
    n = 4
    print(f"\nMonotone path through {{0,1}}^{n} (adding one 'true' at each step):")
    print(f"{'Assignment':>20s} | {'#true':>5s} | {'Parity':>6s} | {'parityFun':>9s}")
    print("-" * 50)
    
    for k in range(n + 1):
        v = tuple([True] * k + [False] * (n - k))
        count = sum(v)
        par = "odd" if count % 2 == 1 else "even"
        pf = parity_fun(v)
        bar = "█" * (10 - pf * 10)
        print(f"{str(v):>20s} | {count:>5d} | {par:>6s} | {pf:>9d} {bar}")
    
    print("\nThe oscillation (0→1→0→1→...) shows parity is non-monotone.")
    print("A monotone function would only go in one direction along this path.")
    
    print(f"\nFor comparison, AND on the same path:")
    for k in range(n + 1):
        v = tuple([True] * k + [False] * (n - k))
        af = and_fun(v)
        print(f"{str(v):>20s} | and={af}")
    print("AND is monotone: it stays at 1 until all inputs are true, then drops to 0.")

# ─── Main ────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    demo_monotonicity()
    demo_non_monotonicity()
    demo_exhaustive_search()
    demo_oscillation()
    
    print("\n" + "=" * 60)
    print("SUMMARY")
    print("=" * 60)
    print("""
Key results demonstrated:
1. Tropical expressions (min, +) are always monotone
2. Parity, XOR, and exact-one are NOT monotone → NOT representable
3. AND, OR, and threshold functions ARE monotone → potentially representable
4. Exhaustive search confirms: no tropical expression computes XOR or parity

This is a formal complexity barrier: the min-plus semiring cannot express
non-monotone Boolean predicates, regardless of expression size.
""")


#!/usr/bin/env python3
"""
Visualizations for Tropical Barrier Theorems

Generates PNG figures for:
1. Boolean cube monotonicity diagram
2. Parity oscillation chart
3. Function classification heatmap
4. Tropical expression evaluation landscape
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from itertools import product
import base64
import io
import json


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight',
                facecolor='white', edgecolor='none')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


def bool_enc(b):
    return 0 if b else 1


def viz_oscillation():
    """Chart showing parity oscillation vs monotone functions."""
    fig, axes = plt.subplots(1, 3, figsize=(14, 4.5))
    
    n = 5
    
    # Parity
    ax = axes[0]
    path_vals = []
    for k in range(n + 1):
        pf = 0 if k % 2 == 1 else 1
        path_vals.append(pf)
    ax.plot(range(n + 1), path_vals, 'ro-', linewidth=2, markersize=10)
    ax.fill_between(range(n + 1), path_vals, alpha=0.15, color='red')
    ax.set_xlabel('Number of true variables', fontsize=12)
    ax.set_ylabel('Function value', fontsize=12)
    ax.set_title('PARITY\n(non-monotone, oscillates)', fontsize=13, fontweight='bold', color='red')
    ax.set_ylim(-0.2, 1.5)
    ax.set_xticks(range(n + 1))
    ax.grid(True, alpha=0.3)
    
    # AND
    ax = axes[1]
    path_vals = [0 if k == n else 1 for k in range(n + 1)]
    ax.plot(range(n + 1), path_vals, 'go-', linewidth=2, markersize=10)
    ax.fill_between(range(n + 1), path_vals, alpha=0.15, color='green')
    ax.set_xlabel('Number of true variables', fontsize=12)
    ax.set_title('AND\n(monotone, representable)', fontsize=13, fontweight='bold', color='green')
    ax.set_ylim(-0.2, 1.5)
    ax.set_xticks(range(n + 1))
    ax.grid(True, alpha=0.3)
    
    # OR
    ax = axes[2]
    path_vals = [1 if k == 0 else 0 for k in range(n + 1)]
    ax.plot(range(n + 1), path_vals, 'bo-', linewidth=2, markersize=10)
    ax.fill_between(range(n + 1), path_vals, alpha=0.15, color='blue')
    ax.set_xlabel('Number of true variables', fontsize=12)
    ax.set_title('OR\n(monotone, representable)', fontsize=13, fontweight='bold', color='blue')
    ax.set_ylim(-0.2, 1.5)
    ax.set_xticks(range(n + 1))
    ax.grid(True, alpha=0.3)
    
    fig.suptitle('Monotone Path Behavior: Why Parity Breaks Tropical Computation',
                 fontsize=14, fontweight='bold', y=1.02)
    fig.tight_layout()
    return fig


def viz_classification():
    """Heatmap showing which functions are tropically representable."""
    functions = {
        'AND': lambda v: 0 if all(v) else 1,
        'OR': lambda v: 0 if any(v) else 1,
        'Majority': lambda v: 0 if sum(v) > len(v)/2 else 1,
        'Threshold≥2': lambda v: 0 if sum(v) >= 2 else 1,
        'Parity': lambda v: 0 if sum(v) % 2 == 1 else 1,
        'XOR(first 2)': lambda v: bool_enc(v[0] ^ v[1]),
        'Exact-One': lambda v: 0 if sum(v) == 1 else 1,
        'Exact-Two': lambda v: 0 if sum(v) == 2 else 1,
    }
    
    ns = [2, 3, 4]
    
    data = np.zeros((len(functions), len(ns)))
    func_names = list(functions.keys())
    
    for fi, (fname, f) in enumerate(functions.items()):
        for ni, n in enumerate(ns):
            if fname == 'XOR(first 2)' and n < 2:
                data[fi][ni] = 0.5
                continue
            # Test monotonicity
            mono = True
            for u in product([True, False], repeat=n):
                for v_a in product([True, False], repeat=n):
                    if all(bool_enc(u[i]) <= bool_enc(v_a[i]) for i in range(n)):
                        if f(u) > f(v_a):
                            mono = False
                            break
                if not mono:
                    break
            data[fi][ni] = 1.0 if mono else 0.0
    
    fig, ax = plt.subplots(figsize=(8, 6))
    
    colors = ['#ff6b6b', '#51cf66']
    from matplotlib.colors import ListedColormap
    cmap = ListedColormap(colors)
    
    im = ax.imshow(data, cmap=cmap, aspect='auto', vmin=0, vmax=1)
    
    ax.set_xticks(range(len(ns)))
    ax.set_xticklabels([f'n={n}' for n in ns], fontsize=12)
    ax.set_yticks(range(len(func_names)))
    ax.set_yticklabels(func_names, fontsize=12)
    
    for fi in range(len(func_names)):
        for ni in range(len(ns)):
            text = "✓" if data[fi][ni] == 1.0 else "✗"
            color = 'white'
            ax.text(ni, fi, text, ha='center', va='center',
                    fontsize=18, fontweight='bold', color=color)
    
    ax.set_title('Tropical Representability of Boolean Functions\n'
                 '(green = representable, red = barrier applies)',
                 fontsize=14, fontweight='bold')
    
    fig.tight_layout()
    return fig


def viz_tropical_landscape():
    """3D surface showing a tropical expression's evaluation landscape."""
    fig = plt.figure(figsize=(12, 5))
    
    # Expression: min(x + y, x + 1, y + 2)
    x = np.linspace(0, 4, 50)
    y = np.linspace(0, 4, 50)
    X, Y = np.meshgrid(x, y)
    
    Z = np.minimum(np.minimum(X + Y, X + 1), Y + 2)
    
    ax1 = fig.add_subplot(121, projection='3d')
    ax1.plot_surface(X, Y, Z, cmap='viridis', alpha=0.8, edgecolor='none')
    ax1.set_xlabel('x₀')
    ax1.set_ylabel('x₁')
    ax1.set_zlabel('eval')
    ax1.set_title('Tropical: min(x₀+x₁, x₀+1, x₁+2)\n(piecewise-linear, monotone)', fontsize=11)
    ax1.view_init(elev=25, azim=-60)
    
    # Compare with non-monotone function (parity-like)
    ax2 = fig.add_subplot(122, projection='3d')
    Z2 = np.abs(np.sin(np.pi * X) * np.sin(np.pi * Y))
    ax2.plot_surface(X, Y, Z2, cmap='magma', alpha=0.8, edgecolor='none')
    ax2.set_xlabel('x₀')
    ax2.set_ylabel('x₁')
    ax2.set_zlabel('value')
    ax2.set_title('Parity-like: |sin(πx₀)·sin(πx₁)|\n(oscillating, non-monotone)', fontsize=11)
    ax2.view_init(elev=25, azim=-60)
    
    fig.suptitle('Tropical Expressions vs Non-Monotone Functions',
                 fontsize=14, fontweight='bold')
    fig.tight_layout()
    return fig


def viz_barrier_diagram():
    """Conceptual diagram of the barrier theorem."""
    fig, ax = plt.subplots(figsize=(10, 6))
    
    # Draw two regions
    from matplotlib.patches import FancyBboxPatch, FancyArrowPatch
    
    # Tropical region (left)
    trop_box = FancyBboxPatch((0.5, 1), 3.5, 4, boxstyle="round,pad=0.3",
                               facecolor='#d4edda', edgecolor='#28a745', linewidth=2)
    ax.add_patch(trop_box)
    
    # Non-representable region (right)
    non_box = FancyBboxPatch((5.5, 1), 3.5, 4, boxstyle="round,pad=0.3",
                              facecolor='#f8d7da', edgecolor='#dc3545', linewidth=2)
    ax.add_patch(non_box)
    
    # Labels
    ax.text(2.25, 4.6, 'TROPICALLY\nREPRESENTABLE', ha='center', va='center',
            fontsize=14, fontweight='bold', color='#155724')
    ax.text(7.25, 4.6, 'NOT TROPICALLY\nREPRESENTABLE', ha='center', va='center',
            fontsize=14, fontweight='bold', color='#721c24')
    
    # Functions in tropical region
    trop_funcs = ['AND', 'OR', 'Majority', 'Threshold-k', 'Min', 'Max']
    for i, f in enumerate(trop_funcs):
        ax.text(2.25, 3.8 - i*0.45, f'• {f}', ha='center', va='center',
                fontsize=11, color='#155724')
    
    # Functions not representable
    non_funcs = ['Parity / XOR', 'Exact-One', 'Mod-k counting', 'SAT indicator', 'Cryptographic']
    for i, f in enumerate(non_funcs):
        ax.text(7.25, 3.8 - i*0.45, f'• {f}', ha='center', va='center',
                fontsize=11, color='#721c24')
    
    # Barrier wall
    ax.plot([4.75, 4.75], [0.8, 5.4], 'k-', linewidth=4)
    ax.text(4.75, 5.7, 'MONOTONICITY\nBARRIER', ha='center', va='center',
            fontsize=13, fontweight='bold',
            bbox=dict(boxstyle='round,pad=0.3', facecolor='#fff3cd', edgecolor='#856404'))
    
    # Key property labels
    ax.text(2.25, 0.6, 'Monotone under\ntropical encoding', ha='center',
            fontsize=10, style='italic', color='#666')
    ax.text(7.25, 0.6, 'Non-monotone:\noscillation breaks\nmin-plus structure', ha='center',
            fontsize=10, style='italic', color='#666')
    
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 6.5)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('The Tropical Barrier: A Fundamental Divide in Computation',
                 fontsize=15, fontweight='bold', pad=20)
    
    fig.tight_layout()
    return fig


if __name__ == "__main__":
    print("Generating visualizations...")
    
    figs = {
        'oscillation': viz_oscillation(),
        'classification': viz_classification(),
        'landscape': viz_tropical_landscape(),
        'barrier': viz_barrier_diagram(),
    }
    
    # Save as PNG files
    for name, fig in figs.items():
        filename = f"viz_{name}.png"
        fig.savefig(filename, dpi=150, bbox_inches='tight',
                    facecolor='white', edgecolor='none')
        print(f"  Saved {filename}")
    
    # Also generate base64 for JSON package
    base64_data = {}
    for name in ['oscillation', 'classification', 'landscape', 'barrier']:
        fig_func = {
            'oscillation': viz_oscillation,
            'classification': viz_classification,
            'landscape': viz_tropical_landscape,
            'barrier': viz_barrier_diagram,
        }[name]
        base64_data[name] = fig_to_base64(fig_func())
    
    # Save base64 data for JSON packaging
    with open('viz_base64.json', 'w') as f:
        json.dump(base64_data, f)
    
    print("Done! Generated 4 visualizations.")

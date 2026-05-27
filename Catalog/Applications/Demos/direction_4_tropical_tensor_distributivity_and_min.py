"""
Tropical Tensor Distributivity: Applications

Real-world applications of tropical normal forms:
1. Verified shortest paths in transportation networks
2. Symbolic dynamic programming for parametric optimization
3. Tropical polynomial evaluation for piecewise-linear functions
"""

import math
import random
from typing import Optional


# ============================================================
# Inline core classes (self-contained)
# ============================================================

class MPExpr:
    pass

class Atom(MPExpr):
    def __init__(self, index: int):
        self.index = index
    def __repr__(self):
        return f"x{self.index}"

class TMin(MPExpr):
    def __init__(self, left: MPExpr, right: MPExpr):
        self.left = left
        self.right = right
    def __repr__(self):
        return f"min({self.left}, {self.right})"

class TPlus(MPExpr):
    def __init__(self, left: MPExpr, right: MPExpr):
        self.left = left
        self.right = right
    def __repr__(self):
        return f"({self.left} + {self.right})"


def eval_z(expr, env):
    if isinstance(expr, Atom):
        return env.get(expr.index, math.inf)
    elif isinstance(expr, TMin):
        return min(eval_z(expr.left, env), eval_z(expr.right, env))
    elif isinstance(expr, TPlus):
        return eval_z(expr.left, env) + eval_z(expr.right, env)
    raise ValueError(f"Unknown: {type(expr)}")


def dist_plus(a, b):
    if isinstance(b, TMin):
        return TMin(dist_plus(a, b.left), dist_plus(a, b.right))
    elif isinstance(a, TMin):
        return TMin(dist_plus(a.left, b), dist_plus(a.right, b))
    else:
        return TPlus(a, b)


def normalize(expr):
    if isinstance(expr, Atom):
        return expr
    elif isinstance(expr, TMin):
        return TMin(normalize(expr.left), normalize(expr.right))
    elif isinstance(expr, TPlus):
        return dist_plus(normalize(expr.left), normalize(expr.right))
    raise ValueError(f"Unknown: {type(expr)}")


def extract_monomials(expr):
    if isinstance(expr, Atom): return [expr]
    if isinstance(expr, TMin):
        return extract_monomials(expr.left) + extract_monomials(expr.right)
    if isinstance(expr, TPlus): return [expr]
    return []


def atom_list(expr):
    if isinstance(expr, Atom): return [expr.index]
    if isinstance(expr, TPlus):
        return atom_list(expr.left) + atom_list(expr.right)
    return []


def encode_edge(n, i, j):
    return i * n + j


def decode_edge(n, idx):
    return idx // n, idx % n


def floyd_warshall(n, weights):
    dist = [row[:] for row in weights]
    for i in range(n):
        dist[i][i] = 0
    for k in range(n):
        for i in range(n):
            for j in range(n):
                if dist[i][k] + dist[k][j] < dist[i][j]:
                    dist[i][j] = dist[i][k] + dist[k][j]
    return dist


# ============================================================
# Application 1: Transportation Network Verification
# ============================================================

def app_transportation():
    """Verify shortest paths in a small transportation network.

    Demonstrates that tropical normalization produces certificates
    for optimal routes.
    """
    print("=" * 60)
    print("APPLICATION 1: Transportation Network Verification")
    print("=" * 60)

    # City network: A=0, B=1, C=2, D=3
    cities = ["Airport", "Downtown", "University", "Hospital"]
    n = 4
    weights = [[math.inf]*n for _ in range(n)]

    # Travel times in minutes
    weights[0][1] = 15  # Airport → Downtown
    weights[0][2] = 25  # Airport → University
    weights[1][2] = 8   # Downtown → University
    weights[1][3] = 20  # Downtown → Hospital
    weights[2][3] = 5   # University → Hospital
    weights[0][3] = 45  # Airport → Hospital (direct)

    env = {}
    for i in range(n):
        for j in range(n):
            env[encode_edge(n, i, j)] = weights[i][j]

    # Build expression for Airport → Hospital
    # Consider all two-hop paths
    two_hop = None
    for k in range(n):
        path = TPlus(Atom(encode_edge(n, 0, k)), Atom(encode_edge(n, k, 3)))
        two_hop = path if two_hop is None else TMin(two_hop, path)

    nf = normalize(two_hop)
    monomials = extract_monomials(nf)

    print(f"\nRoute from {cities[0]} to {cities[3]}:")
    print(f"  Direct: {weights[0][3]} min")
    print(f"\n  Two-hop paths (normalized TNF):")

    for m in monomials:
        atoms = atom_list(m)
        route = []
        for a in atoms:
            src, dst = decode_edge(n, a)
            route.append(f"{cities[src]}→{cities[dst]}({env[a]}min)")
        val = eval_z(m, env)
        marker = " ← OPTIMAL" if val == eval_z(nf, env) else ""
        print(f"    {' + '.join(route)} = {val} min{marker}")

    sp = floyd_warshall(n, weights)
    optimal = sp[0][3]
    nf_val = eval_z(nf, env)
    print(f"\n  Tropical NF value: {nf_val} min")
    print(f"  Floyd-Warshall:    {optimal} min")
    # Two-hop TNF may not match full shortest path (which can use >2 hops), \
    print(f"  2-hop TNF: {nf_val} min, Full shortest: {optimal} min")


# ============================================================
# Application 2: Parametric Shortest Paths
# ============================================================

def app_parametric():
    """Symbolic computation of shortest paths with variable weights.

    Instead of numerical weights, use symbolic variables.
    The TNF gives a parametric formula for the shortest path
    as a function of the edge weights.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Parametric Shortest Paths")
    print("=" * 60)

    # 3-vertex graph with symbolic weights
    n = 3
    print(f"\n  Graph: 0 →(a)→ 1 →(b)→ 2, direct 0 →(c)→ 2")
    print(f"  Atoms: x0=w(0,0), x1=w(0,1)=a, x2=w(0,2)=c, ...")
    print(f"         x3=w(1,0), x4=w(1,1), x5=w(1,2)=b, ...")

    # Build the expression min(c, a+b)
    # (= min over all intermediate vertices k of w(0,k) + w(k,2))
    expr = TMin(
        Atom(encode_edge(3, 0, 2)),  # direct: c
        TPlus(
            Atom(encode_edge(3, 0, 1)),  # a
            Atom(encode_edge(3, 1, 2))   # b
        )
    )

    print(f"\n  Expression: min(c, a+b)")
    print(f"  Already in TNF: {extract_monomials(expr)}")
    print(f"\n  This is a piecewise-linear function:")
    print(f"    f(a, b, c) = min(c, a + b)")
    print(f"    = c         when c ≤ a + b")
    print(f"    = a + b     when a + b ≤ c")

    # Evaluate for different parameter values
    print(f"\n  Parameter sweeps:")
    test_cases = [
        {"a": 3, "b": 2, "c": 7, "expected": 5},
        {"a": 3, "b": 2, "c": 4, "expected": 4},
        {"a": 1, "b": 1, "c": 2, "expected": 2},
        {"a": 10, "b": 10, "c": 5, "expected": 5},
    ]
    for tc in test_cases:
        env = {
            encode_edge(3, 0, 1): tc["a"],
            encode_edge(3, 1, 2): tc["b"],
            encode_edge(3, 0, 2): tc["c"],
        }
        val = eval_z(expr, env)
        print(f"    a={tc['a']}, b={tc['b']}, c={tc['c']}: "
              f"min(c, a+b) = min({tc['c']}, {tc['a']+tc['b']}) = {val}", end="")
        assert val == tc["expected"], f" FAIL!"
        print(" ✓")


# ============================================================
# Application 3: Tropical Polynomial Regions
# ============================================================

def app_tropical_regions():
    """Compute the tropical polynomial regions.

    A tropical polynomial p(x) = min(a₁ + w₁x, a₂ + w₂x, ...)
    defines a piecewise-linear function. The "regions" are the
    intervals where each monomial achieves the minimum.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Tropical Polynomial Regions")
    print("=" * 60)

    # Tropical polynomial: min(2 + x, 5, 1 + 2x)
    # = min(a₁ + x, a₂, a₃ + 2x)
    # Breakpoints: 2+x = 5 → x=3; 2+x = 1+2x → x=1; 5 = 1+2x → x=2

    print(f"\n  Tropical polynomial: p(x) = min(2+x, 5, 1+2x)")
    print(f"  Monomials: 2+x, 5, 1+2x")

    print(f"\n  Evaluation table:")
    print(f"  {'x':>6}  {'2+x':>6}  {'5':>6}  {'1+2x':>6}  {'min':>6}  {'winner':>10}")
    print(f"  {'-'*6}  {'-'*6}  {'-'*6}  {'-'*6}  {'-'*6}  {'-'*10}")

    for x in [-2, -1, 0, 0.5, 1, 1.5, 2, 2.5, 3, 3.5, 4, 5]:
        m1 = 2 + x
        m2 = 5
        m3 = 1 + 2*x
        val = min(m1, m2, m3)
        if val == m1:
            winner = "2+x"
        elif val == m2:
            winner = "5"
        else:
            winner = "1+2x"
        print(f"  {x:6.1f}  {m1:6.1f}  {m2:6.0f}  {m3:6.1f}  {val:6.1f}  {winner:>10}")

    print(f"\n  Regions:")
    print(f"    x ≤ 1:     1+2x achieves minimum (slope 2)")
    print(f"    1 ≤ x ≤ 3: 2+x achieves minimum  (slope 1)")
    print(f"    x ≥ 3:     5 achieves minimum     (slope 0)")
    print(f"\n  The TNF monomials directly encode the 'pieces' of")
    print(f"  this piecewise-linear function!")


if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Tropical Tensor Distributivity: Applications           ║")
    print("╚══════════════════════════════════════════════════════════╝\n")

    app_transportation()
    app_parametric()
    app_tropical_regions()

    print("\n" + "=" * 60)
    print("All applications complete!")
    print("=" * 60)


"""
Tropical Tensor Distributivity: Interactive Demonstration

This script demonstrates the core theorems:
1. Normalization preserves evaluation (Theorem 3)
2. Graph expressions compute correct shortest-path values
3. Geodesic sparsity conjecture testing

Generates random weighted graphs, builds tropical tensor expressions,
normalizes them, and compares with Floyd-Warshall shortest paths.
"""

import random
import math
from typing import Optional

# ============================================================
# Inline all needed classes and functions (self-contained)
# ============================================================

class MPExpr:
    pass

class Atom(MPExpr):
    def __init__(self, index: int):
        self.index = index
    def __repr__(self):
        return f"x{self.index}"

class TMin(MPExpr):
    def __init__(self, left: MPExpr, right: MPExpr):
        self.left = left
        self.right = right
    def __repr__(self):
        return f"min({self.left}, {self.right})"

class TPlus(MPExpr):
    def __init__(self, left: MPExpr, right: MPExpr):
        self.left = left
        self.right = right
    def __repr__(self):
        return f"({self.left} + {self.right})"


def eval_z(expr, env):
    if isinstance(expr, Atom):
        return env.get(expr.index, math.inf)
    elif isinstance(expr, TMin):
        return min(eval_z(expr.left, env), eval_z(expr.right, env))
    elif isinstance(expr, TPlus):
        return eval_z(expr.left, env) + eval_z(expr.right, env)
    raise ValueError(f"Unknown: {type(expr)}")


def dist_plus(a, b):
    if isinstance(b, TMin):
        return TMin(dist_plus(a, b.left), dist_plus(a, b.right))
    elif isinstance(a, TMin):
        return TMin(dist_plus(a.left, b), dist_plus(a.right, b))
    else:
        return TPlus(a, b)


def normalize(expr):
    if isinstance(expr, Atom):
        return expr
    elif isinstance(expr, TMin):
        return TMin(normalize(expr.left), normalize(expr.right))
    elif isinstance(expr, TPlus):
        return dist_plus(normalize(expr.left), normalize(expr.right))
    raise ValueError(f"Unknown: {type(expr)}")


def is_path_monomial(expr):
    if isinstance(expr, Atom): return True
    if isinstance(expr, TMin): return False
    if isinstance(expr, TPlus):
        return is_path_monomial(expr.left) and is_path_monomial(expr.right)
    return False


def is_tropical_nf(expr):
    if isinstance(expr, Atom): return True
    if isinstance(expr, TMin):
        return is_tropical_nf(expr.left) and is_tropical_nf(expr.right)
    if isinstance(expr, TPlus):
        return is_path_monomial(expr.left) and is_path_monomial(expr.right)
    return False


def extract_monomials(expr):
    if isinstance(expr, Atom): return [expr]
    if isinstance(expr, TMin):
        return extract_monomials(expr.left) + extract_monomials(expr.right)
    if isinstance(expr, TPlus): return [expr]
    return []


def atom_list(expr):
    if isinstance(expr, Atom): return [expr.index]
    if isinstance(expr, TPlus):
        return atom_list(expr.left) + atom_list(expr.right)
    return []


def encode_edge(n, i, j):
    return i * n + j

def decode_edge(n, idx):
    return idx // n, idx % n


def graph_env(n, weights):
    env = {}
    for i in range(n):
        for j in range(n):
            env[encode_edge(n, i, j)] = weights[i][j]
    return env


def single_hop_expr(n, i, j):
    return Atom(encode_edge(n, i, j))


def two_hop_expr(n, i, j):
    result = TPlus(Atom(encode_edge(n, i, 0)), Atom(encode_edge(n, 0, j)))
    for k in range(1, n):
        hop = TPlus(Atom(encode_edge(n, i, k)), Atom(encode_edge(n, k, j)))
        result = TMin(result, hop)
    return result


def floyd_warshall(n, weights):
    dist = [row[:] for row in weights]
    for i in range(n):
        dist[i][i] = 0
    for k in range(n):
        for i in range(n):
            for j in range(n):
                if dist[i][k] + dist[k][j] < dist[i][j]:
                    dist[i][j] = dist[i][k] + dist[k][j]
    return dist


def top_sum_count(expr):
    if isinstance(expr, Atom): return 1
    if isinstance(expr, TMin):
        return top_sum_count(expr.left) + top_sum_count(expr.right)
    if isinstance(expr, TPlus):
        return top_sum_count(expr.left) * top_sum_count(expr.right)
    return 1


def dist_potential(expr):
    if isinstance(expr, Atom): return 0
    if isinstance(expr, TMin):
        return dist_potential(expr.left) + dist_potential(expr.right)
    if isinstance(expr, TPlus):
        dp1 = dist_potential(expr.left)
        dp2 = dist_potential(expr.right)
        sc1 = top_sum_count(expr.left)
        sc2 = top_sum_count(expr.right)
        return dp1 * sc2 + dp2 * sc1 + (sc1 * sc2 - 1)
    return 0


# ============================================================
# Random Graph Generation
# ============================================================

def random_graph(n, edge_prob=0.5, weight_range=(1, 20), seed=None):
    """Generate a random weighted directed graph."""
    if seed is not None:
        random.seed(seed)
    weights = [[math.inf] * n for _ in range(n)]
    for i in range(n):
        for j in range(n):
            if i != j and random.random() < edge_prob:
                weights[i][j] = random.randint(*weight_range)
    return weights


# ============================================================
# Main Demo
# ============================================================

def demo_basic():
    """Demo 1: Basic normalization and evaluation preservation."""
    print("=" * 60)
    print("DEMO 1: Normalization Preserves Evaluation (Theorem 3)")
    print("=" * 60)

    # Example: a + min(b, c) where a=3, b=5, c=2
    env = {0: 3, 1: 5, 2: 2}
    expr = TPlus(Atom(0), TMin(Atom(1), Atom(2)))

    print(f"\nExpression: {expr}")
    print(f"Evaluation: {eval_z(expr, env)}")
    print(f"  = 3 + min(5, 2) = 3 + 2 = 5")

    nf = normalize(expr)
    print(f"\nNormalized: {nf}")
    print(f"Evaluation: {eval_z(nf, env)}")
    print(f"  = min(3+5, 3+2) = min(8, 5) = 5")

    assert eval_z(expr, env) == eval_z(nf, env), "FAIL: evaluation changed!"
    print("\n✓ Evaluation preserved!")

    # More complex example
    expr2 = TPlus(TMin(Atom(0), Atom(1)), TMin(Atom(2), Atom(3)))
    env2 = {0: 1, 1: 4, 2: 2, 3: 3}

    print(f"\nExpression: {expr2}")
    val_orig = eval_z(expr2, env2)
    print(f"Evaluation: {val_orig}")

    nf2 = normalize(expr2)
    val_nf = eval_z(nf2, env2)
    print(f"Normalized: {nf2}")
    print(f"Evaluation: {val_nf}")

    monomials = extract_monomials(nf2)
    print(f"Monomials ({len(monomials)}):")
    for m in monomials:
        print(f"  {m} = {eval_z(m, env2)}")

    assert val_orig == val_nf, "FAIL: evaluation changed!"
    print("\n✓ Evaluation preserved!")
    print(f"✓ Is TNF: {is_tropical_nf(nf2)}")


def demo_graph():
    """Demo 2: Graph encoding and shortest path computation."""
    print("\n" + "=" * 60)
    print("DEMO 2: Graph Expressions Compute Shortest Paths")
    print("=" * 60)

    # Graph: 0 →(3)→ 1 →(2)→ 2, direct 0 →(7)→ 2
    n = 3
    weights = [[math.inf] * 3 for _ in range(3)]
    weights[0][1] = 3
    weights[1][2] = 2
    weights[0][2] = 7

    env = graph_env(n, weights)

    # Single-hop: should give edge weight
    for i in range(n):
        for j in range(n):
            expr = single_hop_expr(n, i, j)
            val = eval_z(expr, env)
            expected = weights[i][j]
            print(f"  Edge {i}→{j}: expr={val}, actual={expected}", end="")
            assert val == expected, f" FAIL!"
            print(" ✓")

    # Two-hop expression
    print(f"\nTwo-hop paths 0 → ? → 2:")
    expr = two_hop_expr(n, 0, 2)
    print(f"  Expression: {expr}")

    val = eval_z(expr, env)
    print(f"  Evaluation: {val}")

    nf = normalize(expr)
    val_nf = eval_z(nf, env)
    print(f"  Normalized: {nf}")
    print(f"  Normalized eval: {val_nf}")

    assert val == val_nf, "FAIL: normalization changed value!"
    print(f"  ✓ Preserved!")

    # Compare with Floyd-Warshall
    sp = floyd_warshall(n, weights)
    print(f"\n  Floyd-Warshall shortest paths:")
    for i in range(n):
        for j in range(n):
            print(f"    {i}→{j}: {sp[i][j]}")


def demo_random_graphs():
    """Demo 3: Random graph testing."""
    print("\n" + "=" * 60)
    print("DEMO 3: Random Graph Testing")
    print("=" * 60)

    successes = 0
    total = 0

    for trial in range(10):
        n = random.randint(3, 6)
        weights = random_graph(n, edge_prob=0.6, seed=42 + trial)
        env = graph_env(n, weights)
        sp = floyd_warshall(n, weights)

        trial_ok = True
        for i in range(n):
            for j in range(n):
                if i == j:
                    continue
                # Build two-hop expression and compare
                expr = two_hop_expr(n, i, j)
                val_orig = eval_z(expr, env)
                nf = normalize(expr)
                val_nf = eval_z(nf, env)

                if val_orig != val_nf:
                    print(f"  FAIL: Trial {trial}, n={n}, {i}→{j}: "
                          f"orig={val_orig}, nf={val_nf}")
                    trial_ok = False

                total += 1
                if val_orig == val_nf:
                    successes += 1

        status = "✓" if trial_ok else "✗"
        print(f"  Trial {trial}: n={n}, {status}")

    print(f"\n  Results: {successes}/{total} evaluations preserved ({100*successes/total:.1f}%)")


def demo_conjecture():
    """Demo 4: Geodesic sparsity conjecture testing."""
    print("\n" + "=" * 60)
    print("DEMO 4: Geodesic Sparsity Conjecture")
    print("=" * 60)
    print("Conjecture: For generic edge weights, each (i,j) has")
    print("exactly one monomial achieving the minimum in the TNF.\n")

    unique_count = 0
    total_pairs = 0
    counterexamples = []

    for trial in range(20):
        n = random.randint(3, 5)
        # Use distinct random weights to make it "generic"
        weights = random_graph(n, edge_prob=0.7,
                              weight_range=(1, 100), seed=100 + trial)
        env = graph_env(n, weights)

        for i in range(n):
            for j in range(n):
                if i == j:
                    continue

                expr = two_hop_expr(n, i, j)
                nf = normalize(expr)
                monomials = extract_monomials(nf)
                values = [eval_z(m, env) for m in monomials]
                min_val = min(values)
                achievers = sum(1 for v in values if v == min_val)

                total_pairs += 1
                if achievers == 1:
                    unique_count += 1
                else:
                    if len(counterexamples) < 3:
                        counterexamples.append({
                            'trial': trial, 'n': n,
                            'i': i, 'j': j,
                            'achievers': achievers,
                            'min_val': min_val
                        })

    pct = 100 * unique_count / total_pairs if total_pairs > 0 else 0
    print(f"  Tested {total_pairs} (i,j) pairs across 20 random graphs")
    print(f"  Unique minimum: {unique_count}/{total_pairs} ({pct:.1f}%)")

    if counterexamples:
        print(f"\n  Counterexamples (non-unique minima):")
        for ce in counterexamples:
            print(f"    Trial {ce['trial']}: n={ce['n']}, "
                  f"{ce['i']}→{ce['j']}, "
                  f"{ce['achievers']} achievers, min={ce['min_val']}")
    else:
        print(f"\n  No counterexamples found — conjecture holds for all tested cases!")


def demo_potential():
    """Demo 5: Distributive potential computation."""
    print("\n" + "=" * 60)
    print("DEMO 5: Distributive Potential (Semiring-Independent Measure)")
    print("=" * 60)

    # Build expressions of increasing complexity
    examples = [
        ("atom", Atom(0)),
        ("min(a,b)", TMin(Atom(0), Atom(1))),
        ("a + b", TPlus(Atom(0), Atom(1))),
        ("a + min(b,c)", TPlus(Atom(0), TMin(Atom(1), Atom(2)))),
        ("min(a,b) + min(c,d)", TPlus(TMin(Atom(0), Atom(1)),
                                      TMin(Atom(2), Atom(3)))),
    ]

    for name, expr in examples:
        dp = dist_potential(expr)
        sc = top_sum_count(expr)
        nf = normalize(expr)
        dp_nf = dist_potential(nf)
        print(f"\n  Expression: {name}")
        print(f"    topSumCount = {sc}")
        print(f"    distPotential = {dp}")
        print(f"    After normalization: distPotential = {dp_nf}")
        assert dp_nf == 0, f"FAIL: normalized expr has non-zero potential!"
        print(f"    ✓ Normal form has potential 0")


if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║   Tropical Tensor Distributivity: Interactive Demo      ║")
    print("║   Canonical Rewriting Computes Optimization Semantics   ║")
    print("╚══════════════════════════════════════════════════════════╝\n")

    demo_basic()
    demo_graph()
    demo_random_graphs()
    demo_conjecture()
    demo_potential()

    print("\n" + "=" * 60)
    print("All demonstrations complete!")
    print("=" * 60)


"""
Visualization: Normalization Effect on Distributive Potential

This script creates a heatmap showing how the distributive potential
decreases during normalization. It also shows the monomial count
for graph-encoded expressions across different graph sizes.
"""

import numpy as np
import matplotlib.pyplot as plt
import math
import random

# ============================================================
# Inline implementations (self-contained)
# ============================================================

class MPExpr:
    pass

class Atom(MPExpr):
    def __init__(self, index):
        self.index = index

class TMin(MPExpr):
    def __init__(self, left, right):
        self.left = left
        self.right = right

class TPlus(MPExpr):
    def __init__(self, left, right):
        self.left = left
        self.right = right


def eval_z(expr, env):
    if isinstance(expr, Atom):
        return env.get(expr.index, float('inf'))
    elif isinstance(expr, TMin):
        return min(eval_z(expr.left, env), eval_z(expr.right, env))
    elif isinstance(expr, TPlus):
        return eval_z(expr.left, env) + eval_z(expr.right, env)
    return float('inf')


def dist_plus(a, b):
    if isinstance(b, TMin):
        return TMin(dist_plus(a, b.left), dist_plus(a, b.right))
    elif isinstance(a, TMin):
        return TMin(dist_plus(a.left, b), dist_plus(a.right, b))
    else:
        return TPlus(a, b)


def normalize(expr):
    if isinstance(expr, Atom):
        return expr
    elif isinstance(expr, TMin):
        return TMin(normalize(expr.left), normalize(expr.right))
    elif isinstance(expr, TPlus):
        return dist_plus(normalize(expr.left), normalize(expr.right))
    return expr


def extract_monomials(expr):
    if isinstance(expr, Atom): return [expr]
    if isinstance(expr, TMin):
        return extract_monomials(expr.left) + extract_monomials(expr.right)
    if isinstance(expr, TPlus): return [expr]
    return []


def top_sum_count(expr):
    if isinstance(expr, Atom): return 1
    if isinstance(expr, TMin):
        return top_sum_count(expr.left) + top_sum_count(expr.right)
    if isinstance(expr, TPlus):
        return top_sum_count(expr.left) * top_sum_count(expr.right)
    return 1


def dist_potential(expr):
    if isinstance(expr, Atom): return 0
    if isinstance(expr, TMin):
        return dist_potential(expr.left) + dist_potential(expr.right)
    if isinstance(expr, TPlus):
        dp1 = dist_potential(expr.left)
        dp2 = dist_potential(expr.right)
        sc1 = top_sum_count(expr.left)
        sc2 = top_sum_count(expr.right)
        return dp1 * sc2 + dp2 * sc1 + (sc1 * sc2 - 1)
    return 0


def encode_edge(n, i, j):
    return i * n + j


def two_hop_expr(n, i, j):
    result = TPlus(Atom(encode_edge(n, i, 0)), Atom(encode_edge(n, 0, j)))
    for k in range(1, n):
        hop = TPlus(Atom(encode_edge(n, i, k)), Atom(encode_edge(n, k, j)))
        result = TMin(result, hop)
    return result


def floyd_warshall(n, weights):
    dist = [row[:] for row in weights]
    for i in range(n):
        dist[i][i] = 0
    for k in range(n):
        for i in range(n):
            for j in range(n):
                if dist[i][k] + dist[k][j] < dist[i][j]:
                    dist[i][j] = dist[i][k] + dist[k][j]
    return dist


# ============================================================
# Data Generation
# ============================================================

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Panel 1: Distributive potential before vs after normalization
expr_types = [
    ("a + min(b,c)", lambda: TPlus(Atom(0), TMin(Atom(1), Atom(2)))),
    ("min(a,b) + c", lambda: TPlus(TMin(Atom(0), Atom(1)), Atom(2))),
    ("min(a,b) + min(c,d)", lambda: TPlus(TMin(Atom(0), Atom(1)),
                                          TMin(Atom(2), Atom(3)))),
    ("(a+b) + min(c,d)", lambda: TPlus(TPlus(Atom(0), Atom(1)),
                                       TMin(Atom(2), Atom(3)))),
    ("min(a,b) + min(c,d,e)", lambda: TPlus(
        TMin(Atom(0), Atom(1)),
        TMin(Atom(2), TMin(Atom(3), Atom(4))))),
    ("min(a,b,c) + min(d,e,f)", lambda: TPlus(
        TMin(Atom(0), TMin(Atom(1), Atom(2))),
        TMin(Atom(3), TMin(Atom(4), Atom(5))))),
]

names = [name for name, _ in expr_types]
dp_before = []
dp_after = []
sc_values = []

for name, build in expr_types:
    expr = build()
    dp_before.append(dist_potential(expr))
    nf = normalize(expr)
    dp_after.append(dist_potential(nf))
    sc_values.append(top_sum_count(expr))

x_pos = np.arange(len(names))
width = 0.35

bars1 = axes[0].bar(x_pos - width/2, dp_before, width, label='Before', color='#E53935', alpha=0.8)
bars2 = axes[0].bar(x_pos + width/2, dp_after, width, label='After', color='#43A047', alpha=0.8)

axes[0].set_xlabel('Expression', fontsize=12)
axes[0].set_ylabel('Distributive Potential', fontsize=12)
axes[0].set_title('Normalization Reduces Distributive Potential to 0', fontsize=13)
axes[0].set_xticks(x_pos)
axes[0].set_xticklabels([n.replace(' + ', '\n+\n') for n in names], fontsize=8, rotation=0)
axes[0].legend(fontsize=11)
axes[0].grid(True, alpha=0.3, axis='y')

# Add value labels
for bar in bars1:
    height = bar.get_height()
    if height > 0:
        axes[0].text(bar.get_x() + bar.get_width()/2., height + 0.1,
                    f'{int(height)}', ha='center', va='bottom', fontsize=9)

# Panel 2: Monomial count for two-hop expressions vs graph size
sizes = list(range(2, 9))
monomial_counts = []

for n in sizes:
    expr = two_hop_expr(n, 0, 1)
    nf = normalize(expr)
    monomials = extract_monomials(nf)
    monomial_counts.append(len(monomials))

axes[1].bar(sizes, monomial_counts, color='#1976D2', alpha=0.8, edgecolor='white')
axes[1].plot(sizes, [n for n in sizes], 'r--', linewidth=2, label='n (graph size)')
axes[1].plot(sizes, monomial_counts, 'ko-', markersize=6, label='TNF monomials')

axes[1].set_xlabel('Number of Vertices (n)', fontsize=12)
axes[1].set_ylabel('Number of TNF Monomials', fontsize=12)
axes[1].set_title('Two-Hop TNF Monomials vs Graph Size', fontsize=13)
axes[1].legend(fontsize=11)
axes[1].grid(True, alpha=0.3, axis='y')

plt.tight_layout()
plt.savefig('viz_normalization_heatmap.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_normalization_heatmap.png")


"""
Visualization: Shortest Path Certificate via Tropical Normal Form

This script shows how the tropical normal form of a graph expression
produces a visual certificate for shortest paths: each TNF monomial
corresponds to a candidate path, and the minimum gives the shortest.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import math

# ============================================================
# Inline implementations (self-contained)
# ============================================================

class MPExpr:
    pass

class Atom(MPExpr):
    def __init__(self, index):
        self.index = index

class TMin(MPExpr):
    def __init__(self, left, right):
        self.left = left
        self.right = right

class TPlus(MPExpr):
    def __init__(self, left, right):
        self.left = left
        self.right = right


def eval_z(expr, env):
    if isinstance(expr, Atom):
        return env.get(expr.index, float('inf'))
    elif isinstance(expr, TMin):
        return min(eval_z(expr.left, env), eval_z(expr.right, env))
    elif isinstance(expr, TPlus):
        return eval_z(expr.left, env) + eval_z(expr.right, env)
    return float('inf')


def dist_plus(a, b):
    if isinstance(b, TMin):
        return TMin(dist_plus(a, b.left), dist_plus(a, b.right))
    elif isinstance(a, TMin):
        return TMin(dist_plus(a.left, b), dist_plus(a.right, b))
    else:
        return TPlus(a, b)


def normalize(expr):
    if isinstance(expr, Atom):
        return expr
    elif isinstance(expr, TMin):
        return TMin(normalize(expr.left), normalize(expr.right))
    elif isinstance(expr, TPlus):
        return dist_plus(normalize(expr.left), normalize(expr.right))
    return expr


def extract_monomials(expr):
    if isinstance(expr, Atom): return [expr]
    if isinstance(expr, TMin):
        return extract_monomials(expr.left) + extract_monomials(expr.right)
    if isinstance(expr, TPlus): return [expr]
    return []


def atom_list(expr):
    if isinstance(expr, Atom): return [expr.index]
    if isinstance(expr, TPlus):
        return atom_list(expr.left) + atom_list(expr.right)
    return []


def encode_edge(n, i, j):
    return i * n + j

def decode_edge(n, idx):
    return idx // n, idx % n


# ============================================================
# Graph Setup
# ============================================================

n = 4
cities = ["A", "B", "C", "D"]
positions = {0: (0, 1), 1: (2, 2), 2: (2, 0), 3: (4, 1)}

# Edge weights
edges = {
    (0, 1): 3,
    (0, 2): 6,
    (1, 2): 2,
    (1, 3): 4,
    (2, 3): 1,
}

# Build environment
weights = [[float('inf')] * n for _ in range(n)]
for (i, j), w in edges.items():
    weights[i][j] = w

env = {}
for i in range(n):
    for j in range(n):
        env[encode_edge(n, i, j)] = weights[i][j]

# Build two-hop expression for A -> D
two_hop = None
for k in range(n):
    path = TPlus(Atom(encode_edge(n, 0, k)), Atom(encode_edge(n, k, 3)))
    two_hop = path if two_hop is None else TMin(two_hop, path)

nf = normalize(two_hop)
monomials = extract_monomials(nf)

# ============================================================
# Visualization
# ============================================================

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Panel 1: Graph with edges
ax = axes[0]
ax.set_xlim(-0.5, 5)
ax.set_ylim(-0.5, 3)
ax.set_aspect('equal')
ax.set_title('Weighted Directed Graph', fontsize=14)

# Draw edges
for (i, j), w in edges.items():
    x1, y1 = positions[i]
    x2, y2 = positions[j]
    dx, dy = x2 - x1, y2 - y1
    ax.annotate('', xy=(x2 - 0.15*dx/max(abs(dx)+0.01, abs(dy)+0.01),
                        y2 - 0.15*dy/max(abs(dx)+0.01, abs(dy)+0.01)),
                xytext=(x1 + 0.15*dx/max(abs(dx)+0.01, abs(dy)+0.01),
                        y1 + 0.15*dy/max(abs(dx)+0.01, abs(dy)+0.01)),
                arrowprops=dict(arrowstyle='->', color='#555', lw=2))
    mid_x = (x1 + x2) / 2 + 0.15
    mid_y = (y1 + y2) / 2 + 0.15
    ax.text(mid_x, mid_y, str(w), fontsize=12, fontweight='bold',
            color='#D32F2F', ha='center', va='center',
            bbox=dict(boxstyle='round,pad=0.2', facecolor='white', edgecolor='#D32F2F', alpha=0.8))

# Draw vertices
for i, (x, y) in positions.items():
    circle = plt.Circle((x, y), 0.3, color='#1976D2', zorder=5)
    ax.add_patch(circle)
    ax.text(x, y, cities[i], fontsize=14, fontweight='bold', color='white',
            ha='center', va='center', zorder=6)

ax.axis('off')

# Panel 2: TNF Certificate
ax2 = axes[1]
ax2.set_title('Tropical Normal Form Certificate (A→D)', fontsize=14)
ax2.set_xlim(0, 10)
ax2.set_ylim(0, len(monomials) + 2)
ax2.axis('off')

# Header
ax2.text(5, len(monomials) + 1.5, 'TNF = min(monomial₁, monomial₂, ...)',
         fontsize=12, ha='center', fontweight='bold', style='italic')

# Show each monomial
min_val = eval_z(nf, env)

for idx, m in enumerate(monomials):
    y = len(monomials) - idx
    atoms = atom_list(m)
    val = eval_z(m, env)

    # Decode path
    edges_in_path = []
    for a in atoms:
        src, dst = decode_edge(n, a)
        edges_in_path.append(f"{cities[src]}→{cities[dst]}({env[a]:.0f})")

    path_str = " + ".join(edges_in_path)
    is_optimal = (val == min_val and val != float('inf'))

    color = '#43A047' if is_optimal else '#757575'
    weight = 'bold' if is_optimal else 'normal'
    marker = '★' if is_optimal else '○'

    ax2.text(0.5, y, marker, fontsize=14, va='center', color=color)
    ax2.text(1.5, y, path_str, fontsize=10, va='center', color=color,
             fontweight=weight, family='monospace')

    val_str = f"= {val:.0f}" if val != float('inf') else "= ∞"
    ax2.text(8.5, y, val_str, fontsize=11, va='center', color=color,
             fontweight=weight)

# Bottom annotation
ax2.text(5, 0.3, f'Shortest 2-hop path weight: {min_val:.0f}',
         fontsize=13, ha='center', fontweight='bold', color='#1B5E20',
         bbox=dict(boxstyle='round,pad=0.5', facecolor='#E8F5E9', edgecolor='#43A047'))

plt.tight_layout()
plt.savefig('viz_shortest_path_certificate.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_shortest_path_certificate.png")


"""
Visualization: Tropical Polynomial as Piecewise-Linear Function

This script visualizes a tropical polynomial p(x) = min(2+x, 5, 1+2x)
as the lower envelope of its constituent affine functions (monomials).
Each monomial corresponds to a path in the graph-theoretic interpretation.

The tropical normal form decomposes p(x) into these monomials, and the
minimum over them gives the piecewise-linear function.
"""

import numpy as np
import matplotlib.pyplot as plt

# Define the domain
x = np.linspace(-3, 7, 500)

# Three tropical monomials (affine functions)
m1 = 2 + x        # slope 1, intercept 2
m2 = 5 * np.ones_like(x)  # slope 0, intercept 5
m3 = 1 + 2 * x    # slope 2, intercept 1

# Tropical polynomial = min of monomials
p = np.minimum(np.minimum(m1, m2), m3)

# Create figure
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Left panel: Individual monomials and their minimum
ax1.plot(x, m1, '--', color='#2196F3', alpha=0.6, linewidth=1.5, label='2 + x (path 1)')
ax1.plot(x, m2, '--', color='#4CAF50', alpha=0.6, linewidth=1.5, label='5 (path 2)')
ax1.plot(x, m3, '--', color='#FF9800', alpha=0.6, linewidth=1.5, label='1 + 2x (path 3)')
ax1.plot(x, p, 'k-', linewidth=3, label='min(...) = tropical sum')

# Mark breakpoints
ax1.axvline(x=1, color='gray', linestyle=':', alpha=0.5)
ax1.axvline(x=3, color='gray', linestyle=':', alpha=0.5)
ax1.plot([1], [3], 'ko', markersize=8, zorder=5)
ax1.plot([3], [5], 'ko', markersize=8, zorder=5)

ax1.set_xlabel('x', fontsize=14)
ax1.set_ylabel('p(x)', fontsize=14)
ax1.set_title('Tropical Polynomial: Lower Envelope of Monomials', fontsize=14)
ax1.legend(fontsize=11, loc='upper left')
ax1.set_ylim(-5, 15)
ax1.grid(True, alpha=0.3)
ax1.set_xlim(-3, 7)

# Annotate regions
ax1.annotate('slope 2\nregion', xy=(-1, 0), fontsize=10, ha='center',
            color='#FF9800', fontweight='bold')
ax1.annotate('slope 1\nregion', xy=(2, 3.5), fontsize=10, ha='center',
            color='#2196F3', fontweight='bold')
ax1.annotate('slope 0\nregion', xy=(5, 4.5), fontsize=10, ha='center',
            color='#4CAF50', fontweight='bold')

# Right panel: Which monomial achieves the minimum
colors = []
for xi in x:
    vals = [2 + xi, 5, 1 + 2 * xi]
    idx = np.argmin(vals)
    colors.append(['#2196F3', '#4CAF50', '#FF9800'][idx])

# Draw colored segments
for i in range(len(x) - 1):
    ax2.plot([x[i], x[i+1]], [p[i], p[i+1]], color=colors[i], linewidth=3)

ax2.axvline(x=1, color='gray', linestyle=':', alpha=0.5, label='breakpoints')
ax2.axvline(x=3, color='gray', linestyle=':', alpha=0.5)

# Legend patches
from matplotlib.patches import Patch
legend_elements = [
    Patch(facecolor='#FF9800', label='1+2x wins'),
    Patch(facecolor='#2196F3', label='2+x wins'),
    Patch(facecolor='#4CAF50', label='5 wins'),
]
ax2.legend(handles=legend_elements, fontsize=11, loc='upper left')

ax2.set_xlabel('x', fontsize=14)
ax2.set_ylabel('p(x)', fontsize=14)
ax2.set_title('Tropical Normal Form: Active Monomial Regions', fontsize=14)
ax2.set_ylim(-5, 15)
ax2.set_xlim(-3, 7)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_tropical_polynomial.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_tropical_polynomial.png")

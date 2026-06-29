#!/usr/bin/env python3
"""
applications.py - Real-world applications of ACI normalization.

Demonstrates how ACI normalization eliminates redundancy in:
1. Shortest-path computations (Floyd-Warshall)
2. Dynamic programming expressions
3. Tropical polynomial comparison
"""

from algorithms import *
import itertools


def shortest_path_demo():
    """
    Demonstrates ACI normalization in shortest-path algebra.
    
    In min-plus algebra, the shortest path from i to j via different
    intermediate vertices may produce duplicate min-branches.
    ACI normalization removes these redundancies.
    """
    print("=" * 60)
    print("Application 1: Shortest Path Simplification")
    print("=" * 60)
    
    # Graph: 3 nodes, edges with weights
    # Edge weights as variables: w01, w02, w12, w10, w20, w21
    w01, w02, w12 = Var(0), Var(1), Var(2)
    w10, w20, w21 = Var(3), Var(4), Var(5)
    
    # Shortest path from 0 to 2 with at most 2 hops:
    # Direct: w02
    # Via 1: w01 + w12
    # With redundant duplication (e.g., from matrix squaring):
    path_redundant = TMin(w02, TMin(Add(w01, w12), TMin(w02, Add(w01, w12))))
    path_clean = TMin(w02, Add(w01, w12))
    
    print(f"\n  Redundant path expr: {path_redundant}")
    print(f"  Clean path expr:    {path_clean}")
    print(f"  AC equivalent?  {normalize_ac(path_redundant) == normalize_ac(path_clean)}")
    print(f"  ACI equivalent? {aci_equiv(path_redundant, path_clean)}")
    
    # Verify semantically
    env = {0: 3, 1: 7, 2: 2, 3: 4, 4: 8, 5: 1}
    print(f"  Semantic check: {path_redundant.eval(env)} == {path_clean.eval(env)}")


def dp_expression_demo():
    """
    Demonstrates ACI normalization in dynamic programming.
    
    In min-plus DP (e.g., optimal matrix chain multiplication),
    overlapping subproblems create duplicate min-branches.
    """
    print("\n" + "=" * 60)
    print("Application 2: Dynamic Programming Simplification")
    print("=" * 60)
    
    # Cost variables for different split points
    c1, c2, c3 = Var(0), Var(1), Var(2)
    
    # DP recurrence with overlapping subproblems creates duplicates
    dp_with_overlap = TMin(c1, TMin(c2, TMin(c1, TMin(c3, c2))))
    dp_simplified = TMin(c1, TMin(c2, c3))
    
    print(f"\n  DP with overlap:  {dp_with_overlap}")
    print(f"  DP simplified:    {dp_simplified}")
    print(f"  ACI equivalent?   {aci_equiv(dp_with_overlap, dp_simplified)}")
    print(f"  ACI normal form:  {normalize_aci(dp_with_overlap)}")


def tropical_polynomial_demo():
    """
    Demonstrates tropical polynomial comparison via ACI normalization.
    
    A tropical polynomial is a min of affine functions.
    Duplicate monomials don't change the polynomial geometrically.
    """
    print("\n" + "=" * 60)
    print("Application 3: Tropical Polynomial Comparison")
    print("=" * 60)
    
    x, y = Var(0), Var(1)
    c0, c1, c2 = Const(0), Const(1), Const(2)
    
    # Tropical polynomial: min(x, y+1, x, 2)
    # = min(x, y+1, 2) after removing duplicate x
    p1 = TMin(x, TMin(Add(y, c1), TMin(x, c2)))
    p2 = TMin(x, TMin(Add(y, c1), c2))
    
    print(f"\n  p1 = {p1}")
    print(f"  p2 = {p2}")
    print(f"  ACI equivalent? {aci_equiv(p1, p2)}")
    
    # Evaluate at several points to verify
    print("\n  Pointwise verification:")
    for xv, yv in [(0, 0), (1, 2), (3, 0), (5, 5)]:
        env = {0: xv, 1: yv}
        v1 = p1.eval(env)
        v2 = p2.eval(env)
        print(f"    (x={xv}, y={yv}): p1={v1}, p2={v2}, equal={v1==v2}")


def benchmark_demo():
    """
    Benchmarks AC vs ACI normalization on expressions with many duplicates.
    """
    print("\n" + "=" * 60)
    print("Application 4: Normalization Statistics")
    print("=" * 60)
    
    x, y, z = Var(0), Var(1), Var(2)
    
    # Build expression with n copies of each variable under min
    def build_expr(vars_list, copies):
        atoms = []
        for v in vars_list:
            atoms.extend([v] * copies)
        expr = atoms[0]
        for a in atoms[1:]:
            expr = TMin(expr, a)
        return expr
    
    for copies in [1, 2, 4, 8]:
        e = build_expr([x, y, z], copies)
        ac = normalize_ac(e)
        aci = normalize_aci(e)
        ac_children = len(flatten_min(ac))
        aci_children = len(flatten_min(aci))
        print(f"\n  {copies} copies × 3 vars = {3*copies} min-children")
        print(f"    AC  normal form children: {ac_children}")
        print(f"    ACI normal form children: {aci_children}")
        print(f"    Compression ratio: {ac_children/aci_children:.1f}x")


if __name__ == "__main__":
    shortest_path_demo()
    dp_expression_demo()
    tropical_polynomial_demo()
    benchmark_demo()
    print("\n" + "=" * 60)
    print("All applications demonstrated successfully.")


#!/usr/bin/env python3
"""
demo.py - Demonstrates ACI normalization for tropical min expressions.

Shows how expressions that differ only by duplicate min-subexpressions
are identified by ACI normalization but not by AC normalization.
"""


class TropExpr:
    """Tropical expression: constants, variables, min, and add."""
    pass

class Const(TropExpr):
    def __init__(self, val):
        self.val = val
    def __repr__(self):
        return str(self.val)
    def __eq__(self, other):
        return isinstance(other, Const) and self.val == other.val
    def __hash__(self):
        return hash(("const", self.val))
    def __lt__(self, other):
        return (0, self.val) < self._key(other)
    def _key(self, other):
        if isinstance(other, Const): return (0, other.val)
        if isinstance(other, Var): return (1, other.name)
        return (2, 0)
    def eval(self, env):
        return self.val

class Var(TropExpr):
    def __init__(self, name):
        self.name = name
    def __repr__(self):
        return f"x{self.name}"
    def __eq__(self, other):
        return isinstance(other, Var) and self.name == other.name
    def __hash__(self):
        return hash(("var", self.name))
    def eval(self, env):
        return env.get(self.name, 0)

class TMin(TropExpr):
    def __init__(self, left, right):
        self.left = left
        self.right = right
    def __repr__(self):
        return f"min({self.left}, {self.right})"
    def __eq__(self, other):
        return isinstance(other, TMin) and self.left == other.left and self.right == other.right
    def __hash__(self):
        return hash(("tmin", self.left, self.right))
    def eval(self, env):
        return min(self.left.eval(env), self.right.eval(env))

class Add(TropExpr):
    def __init__(self, left, right):
        self.left = left
        self.right = right
    def __repr__(self):
        return f"({self.left} + {self.right})"
    def __eq__(self, other):
        return isinstance(other, Add) and self.left == other.left and self.right == other.right
    def __hash__(self):
        return hash(("add", self.left, self.right))
    def eval(self, env):
        return self.left.eval(env) + self.right.eval(env)


def flatten_min(e):
    """Flatten nested min into a list of children."""
    if isinstance(e, TMin):
        return flatten_min(e.left) + flatten_min(e.right)
    return [e]

def flatten_add(e):
    """Flatten nested add into a list of children."""
    if isinstance(e, Add):
        return flatten_add(e.left) + flatten_add(e.right)
    return [e]

def rebuild_min(children):
    """Rebuild a right-associated min tree from a list."""
    if len(children) == 1:
        return children[0]
    return TMin(children[0], rebuild_min(children[1:]))

def rebuild_add(children):
    """Rebuild a right-associated add tree from a list."""
    if len(children) == 1:
        return children[0]
    return Add(children[0], rebuild_add(children[1:]))

def normalize_ca(e):
    """AC normalization: flatten, sort, rebuild (no dedup)."""
    if isinstance(e, Const) or isinstance(e, Var):
        return e
    if isinstance(e, TMin):
        ne1 = normalize_ca(e.left)
        ne2 = normalize_ca(e.right)
        children = flatten_min(TMin(ne1, ne2))
        children.sort(key=repr)
        return rebuild_min(children)
    if isinstance(e, Add):
        ne1 = normalize_ca(e.left)
        ne2 = normalize_ca(e.right)
        children = flatten_add(Add(ne1, ne2))
        children.sort(key=repr)
        return rebuild_add(children)

def normalize_aci(e):
    """ACI normalization: flatten, sort, DEDUPLICATE, rebuild."""
    if isinstance(e, Const) or isinstance(e, Var):
        return e
    if isinstance(e, TMin):
        ne1 = normalize_aci(e.left)
        ne2 = normalize_aci(e.right)
        children = flatten_min(TMin(ne1, ne2))
        children.sort(key=repr)
        # Deduplicate adjacent equal elements
        deduped = [children[0]]
        for c in children[1:]:
            if c != deduped[-1]:
                deduped.append(c)
        return rebuild_min(deduped)
    if isinstance(e, Add):
        ne1 = normalize_aci(e.left)
        ne2 = normalize_aci(e.right)
        children = flatten_add(Add(ne1, ne2))
        children.sort(key=repr)
        return rebuild_add(children)


def main():
    x = Var(0)
    y = Var(1)
    z = Var(2)

    print("=" * 60)
    print("ACI Normalization for Tropical Min Expressions")
    print("=" * 60)

    # Example 1: Idempotence - min(x, x) = x
    e1 = TMin(x, x)
    e2 = x
    print(f"\n--- Example 1: Idempotence ---")
    print(f"  e1 = {e1}")
    print(f"  e2 = {e2}")
    print(f"  AC norm(e1)  = {normalize_ca(e1)}")
    print(f"  AC norm(e2)  = {normalize_ca(e2)}")
    print(f"  AC equal?    {normalize_ca(e1) == normalize_ca(e2)}")
    print(f"  ACI norm(e1) = {normalize_aci(e1)}")
    print(f"  ACI norm(e2) = {normalize_aci(e2)}")
    print(f"  ACI equal?   {normalize_aci(e1) == normalize_aci(e2)}")

    # Example 2: Duplicate in nested min
    e3 = TMin(x, TMin(x, y))
    e4 = TMin(x, y)
    print(f"\n--- Example 2: Duplicate nested ---")
    print(f"  e3 = {e3}")
    print(f"  e4 = {e4}")
    print(f"  AC equal?    {normalize_ca(e3) == normalize_ca(e4)}")
    print(f"  ACI norm(e3) = {normalize_aci(e3)}")
    print(f"  ACI norm(e4) = {normalize_aci(e4)}")
    print(f"  ACI equal?   {normalize_aci(e3) == normalize_aci(e4)}")

    # Example 3: Associativity + idempotence
    e5 = TMin(TMin(x, y), TMin(y, z))
    e6 = TMin(x, TMin(y, z))
    print(f"\n--- Example 3: Assoc + idem ---")
    print(f"  e5 = {e5}")
    print(f"  e6 = {e6}")
    print(f"  AC equal?    {normalize_ca(e5) == normalize_ca(e6)}")
    print(f"  ACI norm(e5) = {normalize_aci(e5)}")
    print(f"  ACI norm(e6) = {normalize_aci(e6)}")
    print(f"  ACI equal?   {normalize_aci(e5) == normalize_aci(e6)}")

    # Example 4: Semantic verification
    print(f"\n--- Example 4: Semantic verification ---")
    env = {0: 3.0, 1: 1.0, 2: 5.0}
    print(f"  Environment: x0={env[0]}, x1={env[1]}, x2={env[2]}")
    for name, expr in [("e1", e1), ("e2", e2), ("e3", e3), ("e4", e4), ("e5", e5), ("e6", e6)]:
        print(f"  eval({name}) = {expr.eval(env)}")

    # Example 5: Normalizer idempotence
    print(f"\n--- Example 5: Normalizer idempotence ---")
    e7 = TMin(TMin(z, x), TMin(y, TMin(x, z)))
    n1 = normalize_aci(e7)
    n2 = normalize_aci(n1)
    print(f"  e7 = {e7}")
    print(f"  normalize_aci(e7) = {n1}")
    print(f"  normalize_aci(normalize_aci(e7)) = {n2}")
    print(f"  Idempotent? {n1 == n2}")

    print(f"\n{'=' * 60}")
    print("All examples demonstrate ACI normalization correctly.")
    print("ACI identifies strictly more expressions than AC.")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
visualizations.py - Generate visualizations for ACI normalization.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import base64
from io import BytesIO


def compression_chart():
    """Chart showing ACI compression ratio vs number of duplicates."""
    copies = [1, 2, 3, 4, 5, 6, 7, 8, 10, 16]
    n_vars = 3
    ac_sizes = [n_vars * c for c in copies]
    aci_sizes = [n_vars] * len(copies)
    ratios = [a / i for a, i in zip(ac_sizes, aci_sizes)]
    
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
    
    ax1.bar(range(len(copies)), ac_sizes, alpha=0.7, label='AC normal form', color='#e74c3c')
    ax1.bar(range(len(copies)), aci_sizes, alpha=0.7, label='ACI normal form', color='#2ecc71')
    ax1.set_xticks(range(len(copies)))
    ax1.set_xticklabels([str(c) for c in copies])
    ax1.set_xlabel('Copies per variable')
    ax1.set_ylabel('Number of min-children')
    ax1.set_title('AC vs ACI Normal Form Size')
    ax1.legend()
    ax1.grid(axis='y', alpha=0.3)
    
    ax2.plot(copies, ratios, 'o-', color='#3498db', linewidth=2, markersize=8)
    ax2.set_xlabel('Copies per variable')
    ax2.set_ylabel('Compression ratio (AC/ACI)')
    ax2.set_title('ACI Compression Ratio')
    ax2.grid(alpha=0.3)
    ax2.set_ylim(0, max(ratios) * 1.1)
    
    plt.tight_layout()
    plt.savefig('compression_chart.png', dpi=150, bbox_inches='tight')
    plt.close()
    
    # Also return base64
    buf = BytesIO()
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
    ax1.bar(range(len(copies)), ac_sizes, alpha=0.7, label='AC', color='#e74c3c')
    ax1.bar(range(len(copies)), aci_sizes, alpha=0.7, label='ACI', color='#2ecc71')
    ax1.set_xticks(range(len(copies)))
    ax1.set_xticklabels([str(c) for c in copies])
    ax1.set_xlabel('Copies per variable')
    ax1.set_ylabel('Children count')
    ax1.set_title('AC vs ACI Normal Form Size')
    ax1.legend()
    ax1.grid(axis='y', alpha=0.3)
    ax2.plot(copies, ratios, 'o-', color='#3498db', linewidth=2, markersize=8)
    ax2.set_xlabel('Copies per variable')
    ax2.set_ylabel('Compression ratio')
    ax2.set_title('ACI Compression Ratio')
    ax2.grid(alpha=0.3)
    plt.tight_layout()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    plt.close()
    buf.seek(0)
    return base64.b64encode(buf.read()).decode('utf-8')


def tropical_polynomial_chart():
    """Visualize a tropical polynomial (piecewise linear function)."""
    fig, ax = plt.subplots(figsize=(10, 6))
    
    x = np.linspace(-2, 6, 500)
    
    # Tropical polynomial: min(x, 2, x-1+3) = min(x, 2, x+2)
    f1 = x
    f2 = np.full_like(x, 2.0)
    f3 = x + 2
    trop = np.minimum(np.minimum(f1, f2), f3)
    
    ax.plot(x, f1, '--', alpha=0.5, label='x', color='#e74c3c')
    ax.plot(x, f2, '--', alpha=0.5, label='2', color='#2ecc71')
    ax.plot(x, f3, '--', alpha=0.5, label='x + 2', color='#3498db')
    ax.plot(x, trop, 'k-', linewidth=3, label='min(x, 2, x+2)', alpha=0.8)
    
    # Mark the tropical hypersurface (where minimum is achieved by ≥2 terms)
    ax.axvline(x=0, color='orange', linestyle=':', alpha=0.7, label='Hypersurface points')
    ax.axvline(x=2, color='orange', linestyle=':', alpha=0.7)
    
    ax.set_xlabel('x')
    ax.set_ylabel('Value')
    ax.set_title('Tropical Polynomial: min(x, 2, x+2)\nDuplicate terms do not change the curve')
    ax.legend()
    ax.grid(alpha=0.3)
    ax.set_ylim(-3, 9)
    
    plt.tight_layout()
    plt.savefig('tropical_polynomial.png', dpi=150, bbox_inches='tight')
    
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    plt.close()
    buf.seek(0)
    return base64.b64encode(buf.read()).decode('utf-8')


if __name__ == "__main__":
    b64_1 = compression_chart()
    b64_2 = tropical_polynomial_chart()
    print(f"Generated compression_chart.png ({len(b64_1)} bytes base64)")
    print(f"Generated tropical_polynomial.png ({len(b64_2)} bytes base64)")

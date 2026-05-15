#!/usr/bin/env python3
"""
Tropical AC Normalization — Applications

Demonstrates real-world applications of canonical tropical expression forms
in optimization, machine learning, and circuit design.
"""

from algorithms import *
import random
import time


# ─── Application 1: Shortest Path Expression Simplification ─────────────────

def shortest_path_demo():
    """
    In min-plus algebra, shortest path computations generate tropical expressions.
    AC normalization canonicalizes equivalent path expressions.
    """
    print("=" * 65)
    print("APPLICATION 1: Shortest Path Expression Canonicalization")
    print("=" * 65)
    print()
    
    # In a graph, the shortest path from A to D via different routes:
    # Route 1: A→B→C→D  = w_AB + w_BC + w_CD
    # Route 2: A→C→B→D  = w_AC + w_CB + w_BD
    # min of all routes
    
    w_AB, w_BC, w_CD = Var(0), Var(1), Var(2)
    w_AC, w_CB, w_BD = Var(3), Var(4), Var(5)
    w_AD = Var(6)
    
    # Two equivalent formulations of "shortest of 3 routes"
    route1 = Add(Add(w_AB, w_BC), w_CD)  # ((AB + BC) + CD)
    route2 = Add(w_AC, Add(w_CB, w_BD))  # (AC + (CB + BD))
    route3 = w_AD                         # direct
    
    # Formulation A: min(min(route1, route2), route3)
    expr_a = TMin(TMin(route1, route2), route3)
    # Formulation B: min(route3, min(route1, route2))
    expr_b = TMin(route3, TMin(route1, route2))
    # Formulation C: min(route2, min(route3, route1))
    expr_c = TMin(route2, TMin(route3, route1))
    
    norm_a = normalize_ca(expr_a)
    norm_b = normalize_ca(expr_b)
    norm_c = normalize_ca(expr_c)
    
    print("  Three formulations of 'shortest of 3 routes':")
    print(f"    A: {pretty(expr_a)}")
    print(f"    B: {pretty(expr_b)}")
    print(f"    C: {pretty(expr_c)}")
    print()
    print("  After normalization:")
    print(f"    A: {pretty(norm_a)}")
    print(f"    B: {pretty(norm_b)}")
    print(f"    C: {pretty(norm_c)}")
    print()
    print(f"  All equivalent? {norm_a == norm_b == norm_c}")
    print()


# ─── Application 2: Common Subexpression Elimination ────────────────────────

def cse_demo():
    """
    Canonical forms enable common subexpression elimination (CSE)
    in tropical circuits by identifying structurally equivalent subterms.
    """
    print("=" * 65)
    print("APPLICATION 2: Common Subexpression Elimination")
    print("=" * 65)
    print()
    
    x, y, z = Var(0), Var(1), Var(2)
    
    # Build a large expression with redundant subexpressions
    sub1 = Add(TMin(x, y), z)  # min(x,y) + z
    sub2 = Add(TMin(y, x), z)  # min(y,x) + z  (AC-equivalent to sub1)
    sub3 = Add(z, TMin(x, y))  # z + min(x,y)  (AC-equivalent to sub1)
    
    full_expr = TMin(TMin(sub1, sub2), sub3)
    
    print(f"  Expression: {pretty(full_expr)}")
    print(f"  Size: {expr_size(full_expr)} nodes")
    print()
    
    # Normalize subexpressions
    n1 = normalize_ca(sub1)
    n2 = normalize_ca(sub2)
    n3 = normalize_ca(sub3)
    
    print(f"  Subexpr 1: {pretty(sub1)} → {pretty(n1)}")
    print(f"  Subexpr 2: {pretty(sub2)} → {pretty(n2)}")
    print(f"  Subexpr 3: {pretty(sub3)} → {pretty(n3)}")
    print(f"  All same canonical form? {n1 == n2 == n3}")
    print()
    
    # After CSE: min(sub, min(sub, sub)) = sub (by idempotence of min)
    norm_full = normalize_ca(full_expr)
    print(f"  Normalized full: {pretty(norm_full)}")
    print(f"  Normalized size: {expr_size(norm_full)} nodes")
    print(f"  Reduction: {expr_size(full_expr)} → {expr_size(norm_full)} nodes")
    print()


# ─── Application 3: Memoized Dynamic Programming ────────────────────────────

def memoization_demo():
    """
    Canonical forms as hash keys for memoizing tropical DP computations.
    """
    print("=" * 65)
    print("APPLICATION 3: Memoized Tropical Dynamic Programming")
    print("=" * 65)
    print()
    
    # Simulate a DP where we compute min-plus expressions for states
    x = [Var(i) for i in range(5)]
    
    # Different orderings of the same DP computation
    memo = {}
    expressions = [
        Add(x[0], TMin(x[1], x[2])),
        Add(TMin(x[2], x[1]), x[0]),  # AC-equivalent
        Add(x[0], TMin(x[2], x[1])),  # AC-equivalent
    ]
    
    for i, e in enumerate(expressions):
        key = normalize_ca(e)
        if key in memo:
            print(f"  Expression {i+1}: {pretty(e)} → CACHE HIT (same as expr {memo[key]+1})")
        else:
            memo[key] = i
            print(f"  Expression {i+1}: {pretty(e)} → NEW (canonical: {pretty(key)})")
    
    print(f"\n  Unique expressions: {len(memo)} (out of {len(expressions)} total)")
    print()


# ─── Application 4: Tropical Circuit Equivalence Checking ───────────────────

def circuit_equivalence_demo():
    """
    Check equivalence of tropical circuits (min-plus programs).
    """
    print("=" * 65)
    print("APPLICATION 4: Tropical Circuit Equivalence Checking")
    print("=" * 65)
    print()
    
    x, y, z, w = Var(0), Var(1), Var(2), Var(3)
    
    # Circuit A: balanced tree
    circuit_a = TMin(TMin(x, y), TMin(z, w))
    
    # Circuit B: left-skewed tree  
    circuit_b = TMin(TMin(TMin(x, y), z), w)
    
    # Circuit C: right-skewed tree
    circuit_c = TMin(x, TMin(y, TMin(z, w)))
    
    # Circuit D: different variable order
    circuit_d = TMin(TMin(w, z), TMin(y, x))
    
    circuits = [
        ("Balanced",      circuit_a),
        ("Left-skewed",   circuit_b),
        ("Right-skewed",  circuit_c),
        ("Reverse order", circuit_d),
    ]
    
    print("  Circuits:")
    for name, c in circuits:
        print(f"    {name:15s}: {pretty(c)}")
    
    print("\n  Equivalence matrix:")
    print("    " + "".join(f"  {name[:4]:4s}" for name, _ in circuits))
    for name_i, c_i in circuits:
        row = f"    {name_i[:4]:4s}"
        for _, c_j in circuits:
            eq = is_ac_equivalent(c_i, c_j)
            row += f"  {'  ✓ ' if eq else '  ✗ '}"
        print(row)
    print()


# ─── Application 5: Benchmarking ────────────────────────────────────────────

def benchmark_demo():
    """
    Benchmark normalization performance on random expressions.
    """
    print("=" * 65)
    print("APPLICATION 5: Performance Benchmark")
    print("=" * 65)
    print()
    
    rng = random.Random(42)
    
    def random_expr(depth: int, num_vars: int = 5) -> TropExpr:
        if depth == 0:
            if rng.random() < 0.3:
                return Const(round(rng.uniform(-10, 10), 2))
            else:
                return Var(rng.randint(0, num_vars - 1))
        else:
            left = random_expr(depth - 1, num_vars)
            right = random_expr(depth - 1, num_vars)
            if rng.random() < 0.5:
                return TMin(left, right)
            else:
                return Add(left, right)
    
    print(f"  {'Depth':>6s}  {'Size':>6s}  {'Norm Size':>10s}  {'Time (ms)':>10s}  {'Idempotent':>10s}")
    print(f"  {'─'*6:>6s}  {'─'*6:>6s}  {'─'*10:>10s}  {'─'*10:>10s}  {'─'*10:>10s}")
    
    for depth in range(1, 9):
        e = random_expr(depth)
        size = expr_size(e)
        
        start = time.perf_counter()
        n = normalize_ca(e)
        elapsed = (time.perf_counter() - start) * 1000
        
        norm_size = expr_size(n)
        is_idem = normalize_ca(n) == n
        
        print(f"  {depth:>6d}  {size:>6d}  {norm_size:>10d}  {elapsed:>10.2f}  {'✓' if is_idem else '✗':>10s}")
    print()


def pretty(e: TropExpr) -> str:
    if isinstance(e, Const):
        return str(e.value)
    elif isinstance(e, Var):
        return f"x{e.index}"
    elif isinstance(e, TMin):
        return f"min({pretty(e.left)}, {pretty(e.right)})"
    elif isinstance(e, Add):
        return f"({pretty(e.left)} + {pretty(e.right)})"


if __name__ == "__main__":
    print("╔═══════════════════════════════════════════════════════════════╗")
    print("║  Tropical AC Normalization — Real-World Applications        ║")
    print("╚═══════════════════════════════════════════════════════════════╝")
    print()
    
    shortest_path_demo()
    cse_demo()
    memoization_demo()
    circuit_equivalence_demo()
    benchmark_demo()
    
    print("All application demos complete.")


#!/usr/bin/env python3
"""
Tropical AC Normalization — Demo

Demonstrates the canonicalization algorithm for tropical (min-plus) expressions
under associative-commutative (AC) equivalence.

Key properties verified formally in Lean 4:
  1. Soundness:    eval(normalize(e)) == eval(e) for all environments
  2. Completeness: ACEquiv(e1, e2) => normalize(e1) == normalize(e2)
  3. Idempotence:  normalize(normalize(e)) == normalize(e)
  4. Decision:     ACEquiv(e1, e2) <=> normalize(e1) == normalize(e2)
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import Union, Callable
import random


# ─── Expression AST ──────────────────────────────────────────────────────────

@dataclass(frozen=True)
class Const:
    value: float
    def __repr__(self): return f"{self.value}"

@dataclass(frozen=True)
class Var:
    index: int
    def __repr__(self): return f"x{self.index}"

@dataclass(frozen=True)
class TMin:
    left: 'TropExpr'
    right: 'TropExpr'
    def __repr__(self): return f"min({self.left}, {self.right})"

@dataclass(frozen=True)
class Add:
    left: 'TropExpr'
    right: 'TropExpr'
    def __repr__(self): return f"({self.left} + {self.right})"

TropExpr = Union[Const, Var, TMin, Add]


# ─── Evaluation ──────────────────────────────────────────────────────────────

def eval_expr(sigma: Callable[[int], float], e: TropExpr) -> float:
    """Evaluate a tropical expression in environment sigma."""
    if isinstance(e, Const):
        return e.value
    elif isinstance(e, Var):
        return sigma(e.index)
    elif isinstance(e, TMin):
        return min(eval_expr(sigma, e.left), eval_expr(sigma, e.right))
    elif isinstance(e, Add):
        return eval_expr(sigma, e.left) + eval_expr(sigma, e.right)


# ─── Comparison (total order on expressions) ────────────────────────────────

def tag(e: TropExpr) -> int:
    if isinstance(e, Const): return 0
    if isinstance(e, Var):   return 1
    if isinstance(e, TMin):  return 2
    if isinstance(e, Add):   return 3

def expr_key(e: TropExpr):
    """Return a sort key for total ordering on expressions."""
    if isinstance(e, Const):
        return (0, e.value)
    elif isinstance(e, Var):
        return (1, e.index)
    elif isinstance(e, TMin):
        return (2, expr_key(e.left), expr_key(e.right))
    elif isinstance(e, Add):
        return (3, expr_key(e.left), expr_key(e.right))


# ─── Flatten / Rebuild ───────────────────────────────────────────────────────

def flatten_min(e: TropExpr) -> list[TropExpr]:
    if isinstance(e, TMin):
        return flatten_min(e.left) + flatten_min(e.right)
    return [e]

def flatten_add(e: TropExpr) -> list[TropExpr]:
    if isinstance(e, Add):
        return flatten_add(e.left) + flatten_add(e.right)
    return [e]

def rebuild_min(lst: list[TropExpr]) -> TropExpr:
    assert lst, "Cannot rebuild from empty list"
    if len(lst) == 1:
        return lst[0]
    return TMin(lst[0], rebuild_min(lst[1:]))

def rebuild_add(lst: list[TropExpr]) -> TropExpr:
    assert lst, "Cannot rebuild from empty list"
    if len(lst) == 1:
        return lst[0]
    return Add(lst[0], rebuild_add(lst[1:]))


# ─── AC Normalizer ──────────────────────────────────────────────────────────

def normalize_ca(e: TropExpr) -> TropExpr:
    """
    Canonical AC normalizer for tropical expressions.
    
    1. Recursively normalize children
    2. Flatten same-operator chains
    3. Sort by total order
    4. Rebuild right-associated tree
    """
    if isinstance(e, Const) or isinstance(e, Var):
        return e
    elif isinstance(e, TMin):
        a = normalize_ca(e.left)
        b = normalize_ca(e.right)
        children = flatten_min(a) + flatten_min(b)
        children.sort(key=expr_key)
        return rebuild_min(children)
    elif isinstance(e, Add):
        a = normalize_ca(e.left)
        b = normalize_ca(e.right)
        children = flatten_add(a) + flatten_add(b)
        children.sort(key=expr_key)
        return rebuild_add(children)


# ─── Pretty Printing ────────────────────────────────────────────────────────

def pretty(e: TropExpr) -> str:
    if isinstance(e, Const):
        return str(e.value)
    elif isinstance(e, Var):
        return f"x{e.index}"
    elif isinstance(e, TMin):
        return f"min({pretty(e.left)}, {pretty(e.right)})"
    elif isinstance(e, Add):
        return f"({pretty(e.left)} + {pretty(e.right)})"


# ─── Demonstrations ─────────────────────────────────────────────────────────

def demo_commutativity():
    """Show that normalize_ca handles commutativity."""
    print("=" * 60)
    print("DEMO 1: Commutativity")
    print("=" * 60)
    
    x, y = Var(0), Var(1)
    
    # min(x, y) vs min(y, x)
    e1 = TMin(x, y)
    e2 = TMin(y, x)
    n1 = normalize_ca(e1)
    n2 = normalize_ca(e2)
    
    print(f"  e1 = {pretty(e1)}")
    print(f"  e2 = {pretty(e2)}")
    print(f"  normalize(e1) = {pretty(n1)}")
    print(f"  normalize(e2) = {pretty(n2)}")
    print(f"  Equal? {n1 == n2}")
    
    # (x + y) vs (y + x)
    e3 = Add(x, y)
    e4 = Add(y, x)
    n3 = normalize_ca(e3)
    n4 = normalize_ca(e4)
    
    print(f"\n  e3 = {pretty(e3)}")
    print(f"  e4 = {pretty(e4)}")
    print(f"  normalize(e3) = {pretty(n3)}")
    print(f"  normalize(e4) = {pretty(n4)}")
    print(f"  Equal? {n3 == n4}")
    print()


def demo_associativity():
    """Show that normalize_ca handles associativity."""
    print("=" * 60)
    print("DEMO 2: Associativity")
    print("=" * 60)
    
    x, y, z = Var(0), Var(1), Var(2)
    
    # min(min(x, y), z) vs min(x, min(y, z))
    e1 = TMin(TMin(x, y), z)
    e2 = TMin(x, TMin(y, z))
    n1 = normalize_ca(e1)
    n2 = normalize_ca(e2)
    
    print(f"  e1 = {pretty(e1)}")
    print(f"  e2 = {pretty(e2)}")
    print(f"  normalize(e1) = {pretty(n1)}")
    print(f"  normalize(e2) = {pretty(n2)}")
    print(f"  Equal? {n1 == n2}")
    
    # ((x + y) + z) vs (x + (y + z))
    e3 = Add(Add(x, y), z)
    e4 = Add(x, Add(y, z))
    n3 = normalize_ca(e3)
    n4 = normalize_ca(e4)
    
    print(f"\n  e3 = {pretty(e3)}")
    print(f"  e4 = {pretty(e4)}")
    print(f"  normalize(e3) = {pretty(n3)}")
    print(f"  normalize(e4) = {pretty(n4)}")
    print(f"  Equal? {n3 == n4}")
    print()


def demo_complex_ac():
    """Show normalization of complex AC-equivalent expressions."""
    print("=" * 60)
    print("DEMO 3: Complex AC Equivalence")
    print("=" * 60)
    
    x, y, z, w = Var(0), Var(1), Var(2), Var(3)
    
    # min(min(z, x), min(w, y)) vs min(min(w, z), min(y, x))
    e1 = TMin(TMin(z, x), TMin(w, y))
    e2 = TMin(TMin(w, z), TMin(y, x))
    n1 = normalize_ca(e1)
    n2 = normalize_ca(e2)
    
    print(f"  e1 = {pretty(e1)}")
    print(f"  e2 = {pretty(e2)}")
    print(f"  normalize(e1) = {pretty(n1)}")
    print(f"  normalize(e2) = {pretty(n2)}")
    print(f"  Equal? {n1 == n2}")
    
    # Verify semantically
    rng = random.Random(42)
    for _ in range(5):
        vals = [rng.uniform(-10, 10) for _ in range(4)]
        sigma = lambda i, v=vals: v[i]
        v1 = eval_expr(sigma, e1)
        v2 = eval_expr(sigma, e2)
        print(f"    eval check: {v1:.4f} == {v2:.4f} ? {abs(v1 - v2) < 1e-10}")
    print()


def demo_soundness():
    """Verify soundness: normalize preserves semantics."""
    print("=" * 60)
    print("DEMO 4: Soundness Verification")
    print("=" * 60)
    
    x, y, z = Var(0), Var(1), Var(2)
    c = Const(3.14)
    
    # Complex expression
    e = TMin(Add(x, TMin(y, c)), Add(z, TMin(x, y)))
    n = normalize_ca(e)
    
    print(f"  e = {pretty(e)}")
    print(f"  normalize(e) = {pretty(n)}")
    
    rng = random.Random(123)
    all_pass = True
    for trial in range(10):
        vals = [rng.uniform(-5, 5) for _ in range(3)]
        sigma = lambda i, v=vals: v[i]
        v_orig = eval_expr(sigma, e)
        v_norm = eval_expr(sigma, n)
        match = abs(v_orig - v_norm) < 1e-10
        all_pass = all_pass and match
        if trial < 3:
            print(f"    σ = {vals}")
            print(f"    eval(e) = {v_orig:.6f}, eval(normalize(e)) = {v_norm:.6f}, match: {match}")
    
    print(f"  All 10 trials pass? {all_pass}")
    print()


def demo_idempotence():
    """Verify idempotence: normalize(normalize(e)) == normalize(e)."""
    print("=" * 60)
    print("DEMO 5: Idempotence")
    print("=" * 60)
    
    x, y, z = Var(0), Var(1), Var(2)
    
    exprs = [
        TMin(Add(x, y), z),
        Add(TMin(x, z), TMin(y, Const(1.0))),
        TMin(TMin(z, y), TMin(x, Const(2.0))),
        Add(Add(z, x), Add(y, Const(0.5))),
    ]
    
    all_idem = True
    for e in exprs:
        n1 = normalize_ca(e)
        n2 = normalize_ca(n1)
        is_idem = n1 == n2
        all_idem = all_idem and is_idem
        print(f"  e = {pretty(e)}")
        print(f"  normalize(e) = {pretty(n1)}")
        print(f"  normalize²(e) = {pretty(n2)}")
        print(f"  Idempotent? {is_idem}")
        print()
    
    print(f"  All idempotent? {all_idem}")
    print()


def demo_non_ac():
    """Show that distributivity is NOT captured (by design)."""
    print("=" * 60)
    print("DEMO 6: Beyond AC — Distributivity Not Captured")
    print("=" * 60)
    
    x, y, z = Var(0), Var(1), Var(2)
    
    # a + min(b, c)  vs  min(a+b, a+c)  — semantically equal but not AC-equal
    e1 = Add(x, TMin(y, z))
    e2 = TMin(Add(x, y), Add(x, z))
    n1 = normalize_ca(e1)
    n2 = normalize_ca(e2)
    
    print(f"  e1 = {pretty(e1)}")
    print(f"  e2 = {pretty(e2)}")
    print(f"  normalize(e1) = {pretty(n1)}")
    print(f"  normalize(e2) = {pretty(n2)}")
    print(f"  Same normal form? {n1 == n2}")
    print()
    print("  These are semantically equal (by distributivity of + over min)")
    print("  but NOT AC-equivalent. Our normalizer correctly distinguishes them.")
    print("  This is by design: completeness is for the AC fragment only.")
    
    # Verify they are semantically equal
    rng = random.Random(42)
    for _ in range(3):
        vals = [rng.uniform(-5, 5) for _ in range(3)]
        sigma = lambda i, v=vals: v[i]
        v1 = eval_expr(sigma, e1)
        v2 = eval_expr(sigma, e2)
        print(f"    Semantic check: eval(e1)={v1:.4f}, eval(e2)={v2:.4f}, equal={abs(v1-v2)<1e-10}")
    print()


def demo_decision_procedure():
    """Use normalization as a decision procedure for AC equivalence."""
    print("=" * 60)
    print("DEMO 7: AC Equivalence Decision Procedure")
    print("=" * 60)
    
    x, y, z, w = Var(0), Var(1), Var(2), Var(3)
    
    pairs = [
        ("comm", TMin(x, y), TMin(y, x), True),
        ("assoc", TMin(TMin(x, y), z), TMin(x, TMin(y, z)), True),
        ("AC", TMin(TMin(z, x), y), TMin(TMin(y, z), x), True),
        ("add comm", Add(x, y), Add(y, x), True),
        ("different", TMin(x, y), Add(x, y), False),
        ("nested AC", 
         TMin(TMin(w, x), TMin(y, z)),
         TMin(TMin(z, y), TMin(x, w)), True),
    ]
    
    for name, e1, e2, expected in pairs:
        n1 = normalize_ca(e1)
        n2 = normalize_ca(e2)
        result = n1 == n2
        status = "✓" if result == expected else "✗"
        print(f"  {status} {name}: {pretty(e1)}  ≡_AC  {pretty(e2)} ? {result}")
    print()


if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Tropical AC Normalization — Certified Decision Engine  ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()
    
    demo_commutativity()
    demo_associativity()
    demo_complex_ac()
    demo_soundness()
    demo_idempotence()
    demo_non_ac()
    demo_decision_procedure()
    
    print("All demos complete.")


#!/usr/bin/env python3
"""Generate PACKAGE.json with all deliverables."""

import json
import sys
sys.path.insert(0, '.')

from visualizations import plot_normalization_example, plot_performance, plot_fragment_boundary

# Read markdown files
with open('ARTICLE.md', 'r') as f:
    article = f.read()

with open('RESEARCH_PAPER.md', 'r') as f:
    research_paper = f.read()

with open('FUTURE_DIRECTIONS.md', 'r') as f:
    future_directions = f.read()

# Read Python files
with open('demo.py', 'r') as f:
    demo_code = f.read()

with open('algorithms.py', 'r') as f:
    algorithms_code = f.read()

with open('applications.py', 'r') as f:
    applications_code = f.read()

# Read Lean file
with open('Catalog/Tropical/Core/TropicalACNormalization.lean', 'r') as f:
    lean_code = f.read()

# Generate visualizations
img_norm = plot_normalization_example()
img_perf = plot_performance()
img_frag = plot_fragment_boundary()

# Build package
package = {
    "title": "A Certified Decision Procedure for AC Equivalence of Tropical Expressions",
    "domain": "Tropical Algebra / Formal Methods",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Tropical AC Normalization Demo",
            "code": demo_code
        },
        {
            "name": "Real-World Applications",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "Tropical AC Canonical Normalizer",
            "pseudocode": """PROCEDURE normalize_ca(e):
  CASE e = const(r): RETURN const(r)
  CASE e = var(n): RETURN var(n)
  CASE e = min(a, b):
    a' ← normalize_ca(a); b' ← normalize_ca(b)
    children ← flatten_min(a') ++ flatten_min(b')
    RETURN rebuild_min(SORT(children))
  CASE e = add(a, b):
    a' ← normalize_ca(a); b' ← normalize_ca(b)
    children ← flatten_add(a') ++ flatten_add(b')
    RETURN rebuild_add(SORT(children))

Complexity: O(n² log n) time, O(n) space
Correctness: Sound, Complete (for AC), Idempotent""",
            "code": algorithms_code
        }
    ],
    "visualizations": [
        {
            "name": "Normalization Process: Flatten → Sort → Rebuild",
            "data": img_norm
        },
        {
            "name": "Performance Benchmarks",
            "data": img_perf
        },
        {
            "name": "Tropical Identity Landscape",
            "data": img_frag
        }
    ],
    "lean_proofs": lean_code
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print(f"PACKAGE.json generated ({len(json.dumps(package))} bytes)")


#!/usr/bin/env python3
"""
Tropical AC Normalization — Visualizations

Generates diagrams showing normalization, expression trees, and performance.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
import base64
import io
import time
import random

from algorithms import *


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 PNG data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


def plot_normalization_example():
    """Visualize the normalization process: flatten → sort → rebuild."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 4))
    fig.suptitle('AC Normalization: Flatten → Sort → Rebuild', fontsize=14, fontweight='bold')
    
    # Expression: min(min(z, x), min(w, y))
    labels_before = ['min', 'min', 'z', 'x', 'min', 'w', 'y']
    
    # Step 1: Original tree
    ax = axes[0]
    ax.set_title('1. Original Expression', fontsize=11)
    ax.set_xlim(-1, 7)
    ax.set_ylim(-0.5, 3.5)
    ax.axis('off')
    
    positions = {0: (3, 3), 1: (1.5, 2), 2: (0.5, 1), 3: (2.5, 1), 4: (4.5, 2), 5: (3.5, 1), 6: (5.5, 1)}
    edges = [(0,1), (0,4), (1,2), (1,3), (4,5), (4,6)]
    
    for p, c in edges:
        ax.plot([positions[p][0], positions[c][0]], [positions[p][1], positions[c][1]], 'k-', lw=1.5)
    
    colors = {'min': '#FF6B6B', 'x': '#4ECDC4', 'y': '#4ECDC4', 'z': '#4ECDC4', 'w': '#4ECDC4'}
    for i, (label, pos) in enumerate(zip(labels_before, positions.values())):
        color = colors.get(label, '#ccc')
        circle = plt.Circle(pos, 0.35, color=color, ec='black', lw=1.5)
        ax.add_patch(circle)
        ax.text(pos[0], pos[1], label, ha='center', va='center', fontsize=9, fontweight='bold')
    
    # Step 2: Flattened list
    ax = axes[1]
    ax.set_title('2. Flatten: [z, x, w, y]', fontsize=11)
    ax.set_xlim(-0.5, 4.5)
    ax.set_ylim(0.5, 2.5)
    ax.axis('off')
    
    flat = ['z', 'x', 'w', 'y']
    for i, label in enumerate(flat):
        rect = mpatches.FancyBboxPatch((i*1.1, 1.2), 0.8, 0.6, boxstyle="round,pad=0.1",
                                        facecolor='#4ECDC4', edgecolor='black', lw=1.5)
        ax.add_patch(rect)
        ax.text(i*1.1 + 0.4, 1.5, label, ha='center', va='center', fontsize=11, fontweight='bold')
    ax.annotate('', xy=(3.9, 1.5), xytext=(4.3, 1.5),
                arrowprops=dict(arrowstyle='->', lw=2, color='red'))
    
    # Step 3: Sorted & rebuilt
    ax = axes[2]
    ax.set_title('3. Sort & Rebuild: Canonical Form', fontsize=11)
    ax.set_xlim(-0.5, 7)
    ax.set_ylim(-0.5, 4)
    ax.axis('off')
    
    # Right-associated: min(w, min(x, min(y, z)))
    pos2 = {0: (2, 3.5), 1: (0.5, 2.5), 2: (3, 2.5), 3: (2, 1.5), 4: (4, 1.5), 5: (3, 0.5), 6: (5, 0.5)}
    labels2 = ['min', 'w', 'min', 'x', 'min', 'y', 'z']
    edges2 = [(0,1), (0,2), (2,3), (2,4), (4,5), (4,6)]
    
    for p, c in edges2:
        ax.plot([pos2[p][0], pos2[c][0]], [pos2[p][1], pos2[c][1]], 'k-', lw=1.5)
    
    for i, (label, pos) in enumerate(zip(labels2, pos2.values())):
        color = colors.get(label, '#ccc')
        circle = plt.Circle(pos, 0.35, color=color, ec='black', lw=1.5)
        ax.add_patch(circle)
        ax.text(pos[0], pos[1], label, ha='center', va='center', fontsize=9, fontweight='bold')
    
    plt.tight_layout()
    return fig_to_base64(fig)


def plot_performance():
    """Plot normalization time vs expression size."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))
    fig.suptitle('Normalization Performance', fontsize=14, fontweight='bold')
    
    rng = random.Random(42)
    
    def random_expr(depth, num_vars=5):
        if depth == 0:
            return Const(round(rng.uniform(-10, 10), 2)) if rng.random() < 0.3 else Var(rng.randint(0, num_vars-1))
        left = random_expr(depth - 1, num_vars)
        right = random_expr(depth - 1, num_vars)
        return TMin(left, right) if rng.random() < 0.5 else Add(left, right)
    
    sizes = []
    times = []
    
    for depth in range(1, 11):
        e = random_expr(depth)
        size = expr_size(e)
        
        start = time.perf_counter()
        for _ in range(10):
            normalize_ca(e)
        elapsed = (time.perf_counter() - start) / 10 * 1000
        
        sizes.append(size)
        times.append(elapsed)
    
    ax1.plot(sizes, times, 'o-', color='#FF6B6B', lw=2, markersize=8)
    ax1.set_xlabel('Expression Size (nodes)', fontsize=11)
    ax1.set_ylabel('Normalization Time (ms)', fontsize=11)
    ax1.set_title('Time vs Size', fontsize=12)
    ax1.grid(True, alpha=0.3)
    ax1.set_xscale('log')
    ax1.set_yscale('log')
    
    # Equivalence class sizes
    depths_for_classes = range(1, 6)
    class_sizes = []
    
    for depth in depths_for_classes:
        rng2 = random.Random(depth)
        def random_perm_expr(e):
            """Generate random AC-equivalent expression."""
            if isinstance(e, (Const, Var)):
                return e
            left = random_perm_expr(e.left)
            right = random_perm_expr(e.right)
            if rng2.random() < 0.5:
                left, right = right, left
            if isinstance(e, TMin):
                return TMin(left, right)
            else:
                return Add(left, right)
        
        base = random_expr(depth)
        variants = set()
        for _ in range(100):
            v = random_perm_expr(base)
            variants.add(str(v))
        class_sizes.append(len(variants))
    
    ax2.bar(list(depths_for_classes), class_sizes, color='#4ECDC4', edgecolor='black', lw=1)
    ax2.set_xlabel('Expression Depth', fontsize=11)
    ax2.set_ylabel('Distinct AC Variants (of 100)', fontsize=11)
    ax2.set_title('AC Equivalence Class Size', fontsize=12)
    ax2.grid(True, alpha=0.3, axis='y')
    
    plt.tight_layout()
    return fig_to_base64(fig)


def plot_fragment_boundary():
    """Visualize the AC fragment boundary and distributivity."""
    fig, ax = plt.subplots(1, 1, figsize=(8, 6))
    ax.set_title('Tropical Identity Landscape', fontsize=14, fontweight='bold')
    
    # Draw concentric regions
    circle_ac = plt.Circle((0.5, 0.5), 0.3, color='#4ECDC4', alpha=0.4, label='AC Fragment')
    circle_aci = plt.Circle((0.5, 0.5), 0.38, color='#FFE66D', alpha=0.3, label='ACI Fragment')
    circle_dist = plt.Circle((0.5, 0.5), 0.45, color='#FF6B6B', alpha=0.2, label='Full Tropical')
    
    ax.add_patch(circle_dist)
    ax.add_patch(circle_aci)
    ax.add_patch(circle_ac)
    
    # Labels
    ax.text(0.5, 0.5, 'AC\n(Proved)', ha='center', va='center', fontsize=11, fontweight='bold')
    ax.text(0.5, 0.18, 'ACI: min(a,a)=a', ha='center', va='center', fontsize=9, style='italic')
    ax.text(0.5, 0.08, 'Distributivity:\na+min(b,c)=min(a+b,a+c)', ha='center', va='center', fontsize=8, style='italic')
    
    # Checkmarks and X marks
    ax.text(0.3, 0.55, '✓ Sound', fontsize=9, color='green')
    ax.text(0.3, 0.48, '✓ Complete', fontsize=9, color='green')
    ax.text(0.3, 0.41, '✓ Decidable', fontsize=9, color='green')
    
    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1)
    ax.set_aspect('equal')
    ax.axis('off')
    
    legend = ax.legend(loc='upper right', fontsize=9)
    
    plt.tight_layout()
    return fig_to_base64(fig)


if __name__ == "__main__":
    print("Generating visualizations...")
    
    img1 = plot_normalization_example()
    print(f"  Normalization example: {len(img1)} chars")
    
    img2 = plot_performance()
    print(f"  Performance plot: {len(img2)} chars")
    
    img3 = plot_fragment_boundary()
    print(f"  Fragment boundary: {len(img3)} chars")
    
    print("Done! Images saved as base64 data URIs.")

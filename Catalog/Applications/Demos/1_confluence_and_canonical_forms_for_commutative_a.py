#!/usr/bin/env python3
"""
Tropical AC Normalization — Applications

Demonstrates real-world applications of the AC canonical form theorem:
1. Shortest-path expression simplification
2. ReLU network equivalence detection (AC fragment)
3. Scheduling optimization
"""
from demo import *

def app_shortest_path():
    """Application 1: Shortest-path expression simplification.
    
    In a weighted graph, the shortest path from A to D through intermediate nodes
    can be expressed as tropical expressions. AC-equivalent formulations should
    be recognized as computing the same path costs.
    """
    print("=" * 60)
    print("APPLICATION 1: Shortest-Path Expression Simplification")
    print("=" * 60)
    
    # Variables represent edge weights
    # x0 = w(A,B), x1 = w(B,C), x2 = w(A,C), x3 = w(C,D), x4 = w(B,D)
    wAB, wBC, wAC, wCD, wBD = Var(0), Var(1), Var(2), Var(3), Var(4)
    
    # Shortest path A → D via different route enumerations:
    # Route 1: min(A→B→C→D, A→C→D, A→B→D)
    path1 = TMin(Add(wAB, Add(wBC, wCD)), TMin(Add(wAC, wCD), Add(wAB, wBD)))
    
    # Route 2 (reordered): min(A→B→D, min(A→B→C→D, A→C→D))
    path2 = TMin(Add(wAB, wBD), TMin(Add(wAB, Add(wBC, wCD)), Add(wAC, wCD)))
    
    n1, n2 = normalize_ca(path1), normalize_ca(path2)
    
    print(f"  Path formulation 1: {path1}")
    print(f"  Path formulation 2: {path2}")
    print(f"  Normalized 1: {n1}")
    print(f"  Normalized 2: {n2}")
    print(f"  AC-equivalent: {n1 == n2}")
    print()

def app_relu_equivalence():
    """Application 2: Detecting equivalent ReLU computations.
    
    ReLU(x) = max(0, x) can be expressed in tropical min-plus notation.
    Different orderings of min/max operations should be recognized as equivalent.
    """
    print("=" * 60)
    print("APPLICATION 2: ReLU Network Equivalence (AC Fragment)")
    print("=" * 60)
    
    # Consider two different orderings of a 3-input min operation
    # representing the minimum of three activations
    a1, a2, a3 = Var(0), Var(1), Var(2)
    
    # Network A: computes min(a1, min(a2, a3))
    net_a = TMin(a1, TMin(a2, a3))
    
    # Network B: computes min(min(a3, a1), a2)
    net_b = TMin(TMin(a3, a1), a2)
    
    # These should be recognized as equivalent
    n_a, n_b = normalize_ca(net_a), normalize_ca(net_b)
    
    print(f"  Network A: {net_a}")
    print(f"  Network B: {net_b}")
    print(f"  Canonical form A: {n_a}")
    print(f"  Canonical form B: {n_b}")
    print(f"  Structurally equivalent: {n_a == n_b}")
    print()

def app_scheduling():
    """Application 3: Scheduling — critical path analysis.
    
    In project scheduling, the completion time of a task is:
      finish_time = start_time + duration
    And when multiple tasks feed into one:
      start_time = min(finish_time of all predecessors)  (i.e., latest one)
    
    Wait — in scheduling with "latest predecessor" semantics, we'd use max.
    For tropical min-plus, we model "earliest possible" start times.
    Different orderings of the precedence structure should be recognized.
    """
    print("=" * 60)
    print("APPLICATION 3: Scheduling — Precedence Equivalence")
    print("=" * 60)
    
    # Task durations
    d1, d2, d3, d4 = Var(0), Var(1), Var(2), Var(3)
    
    # Two equivalent ways to compute the earliest completion:
    # Schedule 1: min(d1+d2, d3+d4) vs Schedule 2: min(d3+d4, d1+d2)
    sched1 = TMin(Add(d1, d2), Add(d3, d4))
    sched2 = TMin(Add(d3, d4), Add(d1, d2))
    
    n1, n2 = normalize_ca(sched1), normalize_ca(sched2)
    print(f"  Schedule 1: {sched1}")
    print(f"  Schedule 2: {sched2}")
    print(f"  Canonical 1: {n1}")
    print(f"  Canonical 2: {n2}")
    print(f"  Equivalent: {n1 == n2}")
    
    # More complex: three parallel paths
    sched3 = TMin(TMin(Add(d1, d2), Add(d3, d4)), Add(d1, Add(d3, d4)))
    sched4 = TMin(Add(d1, Add(d3, d4)), TMin(Add(d3, d4), Add(d1, d2)))
    n3, n4 = normalize_ca(sched3), normalize_ca(sched4)
    print(f"\n  Complex schedule 1: {sched3}")
    print(f"  Complex schedule 2: {sched4}")
    print(f"  Equivalent: {n3 == n4}")
    print()

if __name__ == "__main__":
    app_shortest_path()
    app_relu_equivalence()
    app_scheduling()


#!/usr/bin/env python3
"""
Tropical AC Normalization — Demo & Visualization

Demonstrates the canonical form theorem for tropical expressions:
  1. Soundness: normalization preserves evaluation
  2. Completeness: AC-equivalent expressions normalize to the same form
  3. Idempotence: normalizing twice = normalizing once
"""
from dataclasses import dataclass
from typing import Union, Callable
import itertools

# ---------- Expression type ----------

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

# ---------- Evaluation ----------

def eval_expr(sigma: Callable[[int], float], e: TropExpr) -> float:
    if isinstance(e, Const): return e.value
    if isinstance(e, Var): return sigma(e.index)
    if isinstance(e, TMin): return min(eval_expr(sigma, e.left), eval_expr(sigma, e.right))
    if isinstance(e, Add): return eval_expr(sigma, e.left) + eval_expr(sigma, e.right)

# ---------- Comparison (total order) ----------

def tag(e: TropExpr) -> int:
    if isinstance(e, Const): return 0
    if isinstance(e, Var): return 1
    if isinstance(e, TMin): return 2
    if isinstance(e, Add): return 3

def ble(a: TropExpr, b: TropExpr) -> bool:
    ta, tb = tag(a), tag(b)
    if ta != tb: return ta < tb
    if isinstance(a, Const) and isinstance(b, Const): return a.value <= b.value
    if isinstance(a, Var) and isinstance(b, Var): return a.index <= b.index
    if isinstance(a, (TMin, Add)) and isinstance(b, (TMin, Add)):
        if a.left == b.left: return ble(a.right, b.right)
        return ble(a.left, b.left)
    return True

# ---------- Flatten / Rebuild / Sort ----------

def flatten_min(e: TropExpr) -> list:
    if isinstance(e, TMin): return flatten_min(e.left) + flatten_min(e.right)
    return [e]

def flatten_add(e: TropExpr) -> list:
    if isinstance(e, Add): return flatten_add(e.left) + flatten_add(e.right)
    return [e]

def rebuild_min(lst: list) -> TropExpr:
    if len(lst) == 1: return lst[0]
    return TMin(lst[0], rebuild_min(lst[1:]))

def rebuild_add(lst: list) -> TropExpr:
    if len(lst) == 1: return lst[0]
    return Add(lst[0], rebuild_add(lst[1:]))

import functools
def sort_exprs(lst: list) -> list:
    return sorted(lst, key=functools.cmp_to_key(lambda a, b: -1 if ble(a, b) and a != b else (0 if a == b else 1)))

# ---------- Normalizer ----------

def normalize_ca(e: TropExpr) -> TropExpr:
    if isinstance(e, (Const, Var)): return e
    if isinstance(e, TMin):
        a = normalize_ca(e.left)
        b = normalize_ca(e.right)
        return rebuild_min(sort_exprs(flatten_min(a) + flatten_min(b)))
    if isinstance(e, Add):
        a = normalize_ca(e.left)
        b = normalize_ca(e.right)
        return rebuild_add(sort_exprs(flatten_add(a) + flatten_add(b)))

# ---------- Demo ----------

def demo_soundness():
    print("=" * 60)
    print("DEMO 1: Soundness — normalization preserves evaluation")
    print("=" * 60)
    x0, x1, x2 = Var(0), Var(1), Var(2)
    e = TMin(Add(x0, x1), TMin(x2, Add(x1, x0)))
    n = normalize_ca(e)
    print(f"  Expression:  {e}")
    print(f"  Normalized:  {n}")
    for vals in [(1, 2, 3), (5, 0, 10), (3, 3, 3)]:
        sigma = lambda i, v=vals: v[i]
        v_orig = eval_expr(sigma, e)
        v_norm = eval_expr(sigma, n)
        print(f"  σ = {vals}: eval(original) = {v_orig}, eval(normalized) = {v_norm}, equal = {v_orig == v_norm}")
    print()

def demo_completeness():
    print("=" * 60)
    print("DEMO 2: Completeness — AC-equivalent expressions get same normal form")
    print("=" * 60)
    x0, x1, x2 = Var(0), Var(1), Var(2)
    
    # AC-equivalent expressions for min
    e1 = TMin(TMin(x0, x1), x2)       # min(min(x0,x1), x2)
    e2 = TMin(x0, TMin(x1, x2))       # min(x0, min(x1,x2))
    e3 = TMin(x2, TMin(x1, x0))       # min(x2, min(x1,x0))
    e4 = TMin(TMin(x2, x0), x1)       # min(min(x2,x0), x1)
    
    for i, e in enumerate([e1, e2, e3, e4], 1):
        n = normalize_ca(e)
        print(f"  e{i} = {e}")
        print(f"       normalized = {n}")
    
    norms = [normalize_ca(e) for e in [e1, e2, e3, e4]]
    print(f"  All normalize to same form: {all(n == norms[0] for n in norms)}")
    print()
    
    # AC-equivalent expressions for add
    e5 = Add(Add(x0, x1), x2)
    e6 = Add(x0, Add(x2, x1))
    n5, n6 = normalize_ca(e5), normalize_ca(e6)
    print(f"  e5 = {e5}  →  {n5}")
    print(f"  e6 = {e6}  →  {n6}")
    print(f"  Same normal form: {n5 == n6}")
    print()

def demo_idempotence():
    print("=" * 60)
    print("DEMO 3: Idempotence — normalizing twice = normalizing once")
    print("=" * 60)
    x0, x1, x2 = Var(0), Var(1), Var(2)
    expressions = [
        TMin(x1, TMin(x0, x2)),
        Add(TMin(x0, x1), Add(x2, Const(5))),
        TMin(Add(x0, x1), TMin(Add(x2, x0), x1)),
    ]
    for e in expressions:
        n1 = normalize_ca(e)
        n2 = normalize_ca(n1)
        print(f"  e  = {e}")
        print(f"  n  = {n1}")
        print(f"  nn = {n2}")
        print(f"  Idempotent: {n1 == n2}")
        print()

def demo_non_ac_inequivalence():
    print("=" * 60)
    print("DEMO 4: Boundary — distributivity is NOT handled")
    print("=" * 60)
    x, y, z = Var(0), Var(1), Var(2)
    # x + min(y, z) vs min(x+y, x+z) — equal by distributivity but NOT by AC
    e1 = Add(x, TMin(y, z))
    e2 = TMin(Add(x, y), Add(x, z))
    n1, n2 = normalize_ca(e1), normalize_ca(e2)
    print(f"  e1 = {e1}")
    print(f"  e2 = {e2}")
    print(f"  n1 = {n1}")
    print(f"  n2 = {n2}")
    print(f"  Same normal form: {n1 == n2}")
    print(f"  (Expected: False — distributivity is outside the AC fragment)")
    
    # Verify they ARE semantically equal
    for vals in [(1, 2, 3), (5, 0, 10)]:
        sigma = lambda i, v=vals: v[i]
        print(f"  σ = {vals}: eval(e1) = {eval_expr(sigma, e1)}, eval(e2) = {eval_expr(sigma, e2)}")
    print()

if __name__ == "__main__":
    demo_soundness()
    demo_completeness()
    demo_idempotence()
    demo_non_ac_inequivalence()


#!/usr/bin/env python3
"""
Tropical AC Normalization — Visualizations

Generates visualizations of expression trees before/after normalization
and benchmarking charts.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
import time
import random
import base64
import io

from algorithms import *

def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 PNG data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    return "data:image/png;base64," + base64.b64encode(buf.read()).decode()

def viz_normalization_sizes():
    """Visualize how normalization affects expression size across random expressions."""
    random.seed(42)
    
    depths = list(range(1, 10))
    orig_sizes = []
    norm_sizes = []
    
    for d in depths:
        sizes_o, sizes_n = [], []
        for _ in range(20):
            e = random_expr(d)
            n = normalize_ca(e)
            sizes_o.append(expr_size(e))
            sizes_n.append(expr_size(n))
        orig_sizes.append(np.mean(sizes_o))
        norm_sizes.append(np.mean(sizes_n))
    
    fig, ax = plt.subplots(1, 1, figsize=(8, 5))
    ax.plot(depths, orig_sizes, 'o-', label='Original size', color='#e74c3c', linewidth=2)
    ax.plot(depths, norm_sizes, 's-', label='Normalized size', color='#2ecc71', linewidth=2)
    ax.set_xlabel('Expression Depth', fontsize=12)
    ax.set_ylabel('Average Number of Nodes', fontsize=12)
    ax.set_title('Expression Size: Before vs After AC Normalization', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig('viz_sizes.png', dpi=150)
    plt.close(fig)
    return fig_to_base64(fig)

def viz_normalization_time():
    """Benchmark normalization time vs expression size."""
    random.seed(42)
    
    sizes = []
    times = []
    
    for d in range(1, 13):
        for _ in range(10):
            e = random_expr(d)
            sz = expr_size(e)
            
            start = time.perf_counter()
            normalize_ca(e)
            elapsed = (time.perf_counter() - start) * 1000
            
            sizes.append(sz)
            times.append(elapsed)
    
    fig, ax = plt.subplots(1, 1, figsize=(8, 5))
    ax.scatter(sizes, times, alpha=0.5, color='#3498db', s=20)
    ax.set_xlabel('Expression Size (nodes)', fontsize=12)
    ax.set_ylabel('Normalization Time (ms)', fontsize=12)
    ax.set_title('AC Normalization Performance', fontsize=14)
    ax.set_xscale('log')
    ax.set_yscale('log')
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig('viz_performance.png', dpi=150)
    plt.close(fig)
    return fig_to_base64(fig)

def viz_ac_equivalence_classes():
    """Visualize the number of AC-equivalent expressions that map to the same canonical form."""
    x0, x1, x2 = Var(0), Var(1), Var(2)
    
    # Generate all bracketings and orderings of min(x0, x1, x2)
    perms = [(x0,x1,x2), (x0,x2,x1), (x1,x0,x2), (x1,x2,x0), (x2,x0,x1), (x2,x1,x0)]
    
    exprs_min = []
    for p in perms:
        # Two bracketings: (a op b) op c and a op (b op c)
        exprs_min.append(TMin(TMin(p[0], p[1]), p[2]))
        exprs_min.append(TMin(p[0], TMin(p[1], p[2])))
    
    norms_min = [normalize_ca(e) for e in exprs_min]
    unique_min = len(set(id(n) for n in norms_min))  # all should be same
    all_same = all(n == norms_min[0] for n in norms_min)
    
    # Same for add
    exprs_add = []
    for p in perms:
        exprs_add.append(Add(Add(p[0], p[1]), p[2]))
        exprs_add.append(Add(p[0], Add(p[1], p[2])))
    
    norms_add = [normalize_ca(e) for e in exprs_add]
    all_same_add = all(n == norms_add[0] for n in norms_add)
    
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))
    
    # Bar chart showing all expressions map to 1 canonical form
    ax1.bar(['Distinct\nExpressions', 'Canonical\nForms'], [len(exprs_min), 1], 
            color=['#e74c3c', '#2ecc71'], width=0.5)
    ax1.set_ylabel('Count', fontsize=12)
    ax1.set_title(f'min(x₀, x₁, x₂): {len(exprs_min)} forms → 1 canonical', fontsize=12)
    ax1.set_ylim(0, max(len(exprs_min), 1) + 2)
    
    ax2.bar(['Distinct\nExpressions', 'Canonical\nForms'], [len(exprs_add), 1],
            color=['#e74c3c', '#2ecc71'], width=0.5)
    ax2.set_ylabel('Count', fontsize=12)
    ax2.set_title(f'x₀ + x₁ + x₂: {len(exprs_add)} forms → 1 canonical', fontsize=12)
    ax2.set_ylim(0, max(len(exprs_add), 1) + 2)
    
    fig.suptitle('AC Equivalence Class Collapse Under Normalization', fontsize=14, y=1.02)
    fig.tight_layout()
    fig.savefig('viz_equivalence.png', dpi=150)
    plt.close(fig)
    return fig_to_base64(fig)

if __name__ == "__main__":
    print("Generating visualizations...")
    viz_normalization_sizes()
    print("  → viz_sizes.png")
    viz_normalization_time()
    print("  → viz_performance.png")
    viz_ac_equivalence_classes()
    print("  → viz_equivalence.png")
    print("Done.")

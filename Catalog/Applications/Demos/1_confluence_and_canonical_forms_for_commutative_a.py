"""
Tropical AC Normalization — Applications

Demonstrates real-world applications of tropical expression canonicalization:
1. Shortest-path expression simplification
2. Expression deduplication / CSE
3. Neural network (ReLU) piecewise-linear function canonicalization
"""
from demo import (TropExpr, Const, Var, TMin, Add,
                  normalize_ca, eval_expr, expr_key)


# ─────────────────────────────────────────
# Application 1: Shortest-Path Expressions
# ─────────────────────────────────────────

def shortest_path_demo():
    """
    In tropical algebra, shortest-path computation is matrix multiplication:
        (A ⊗ B)_{ij} = min_k (A_{ik} + B_{kj})

    This naturally produces tropical expressions. AC normalization
    eliminates redundant structure from these expressions.
    """
    print("=" * 60)
    print("APPLICATION 1: Shortest-Path Expression Simplification")
    print("=" * 60)

    # Graph with 3 nodes, edge weights as constants
    # Edges: 0→1 (weight 3), 0→2 (weight 7), 1→2 (weight 2), 2→1 (weight 4)
    w01, w02, w12, w21 = Const(3), Const(7), Const(2), Const(4)

    # Path expressions from node 0 to node 2:
    # Direct: 0 → 2 (weight 7)
    path_direct = w02

    # Via node 1: 0 → 1 → 2 (weight 3 + 2 = 5)
    path_via_1 = Add(w01, w12)

    # Shortest path: min(direct, via_1) = min(7, 5) = 5
    shortest = TMin(path_direct, path_via_1)

    # Alternative expression of the same: min(3+2, 7)
    shortest_alt = TMin(path_via_1, path_direct)

    print(f"  Path 0→2 direct:  {path_direct}")
    print(f"  Path 0→1→2:      {path_via_1}")
    print(f"  Shortest (v1):   {shortest}")
    print(f"  Shortest (v2):   {shortest_alt}")
    print(f"  Normalized (v1): {normalize_ca(shortest)}")
    print(f"  Normalized (v2): {normalize_ca(shortest_alt)}")
    print(f"  Same form? {expr_key(normalize_ca(shortest)) == expr_key(normalize_ca(shortest_alt))}")

    sigma = lambda i: 0
    print(f"  Value: {eval_expr(sigma, shortest)}")
    print()


# ─────────────────────────────────────────
# Application 2: Common Subexpression Elimination
# ─────────────────────────────────────────

def cse_demo():
    """
    Normalization enables common subexpression elimination (CSE)
    by giving AC-equivalent subexpressions the same canonical form.
    """
    print("=" * 60)
    print("APPLICATION 2: Common Subexpression Elimination")
    print("=" * 60)

    x0, x1, x2 = Var(0), Var(1), Var(2)

    # Two subexpressions that differ only by AC
    sub1 = Add(x0, Add(x1, x2))      # x0 + (x1 + x2)
    sub2 = Add(Add(x2, x0), x1)      # (x2 + x0) + x1

    # A larger expression using both
    big_expr = TMin(Add(sub1, Const(1)), Add(sub2, Const(2)))

    n_sub1 = normalize_ca(sub1)
    n_sub2 = normalize_ca(sub2)

    print(f"  sub1 = {sub1}")
    print(f"  sub2 = {sub2}")
    print(f"  normalize(sub1) = {n_sub1}")
    print(f"  normalize(sub2) = {n_sub2}")
    print(f"  Same? {expr_key(n_sub1) == expr_key(n_sub2)}")
    print(f"  → CSE can merge these into a single computation")

    # Count unique subexpressions before and after normalization
    def collect_subexprs(e):
        """Collect all subexpressions."""
        result = [e]
        if isinstance(e, (TMin, Add)):
            result += collect_subexprs(e.left) + collect_subexprs(e.right)
        return result

    subs = collect_subexprs(big_expr)
    keys_before = set(expr_key(s) for s in subs)
    keys_after = set(expr_key(normalize_ca(s)) for s in subs)

    print(f"\n  Full expression: {big_expr}")
    print(f"  Subexpressions (before): {len(keys_before)} distinct")
    print(f"  Subexpressions (after):  {len(keys_after)} distinct")
    print(f"  Eliminated: {len(keys_before) - len(keys_after)} redundant forms")
    print()


# ─────────────────────────────────────────
# Application 3: Tropical View of ReLU Networks
# ─────────────────────────────────────────

def relu_demo():
    """
    ReLU(x) = max(0, x) can be expressed in tropical algebra
    (using max-plus convention, the dual of min-plus).

    In min-plus: ReLU(x) = -max(0, x) = min(0, -x) after negation.

    More interestingly, compositions of affine maps and ReLU operations
    produce piecewise-linear functions, which are tropical polynomials.

    AC normalization can simplify these tropical representations.
    """
    print("=" * 60)
    print("APPLICATION 3: Tropical View of Piecewise-Linear Functions")
    print("=" * 60)

    x = Var(0)

    # f(x) = min(x, 0) — tropical ReLU (negated)
    relu_neg = TMin(x, Const(0))

    # g(x) = min(x + 1, 2) — shifted/clamped
    g = TMin(Add(x, Const(1)), Const(2))

    # Composition-like: min(min(x, 0), min(x + 1, 2))
    # vs min(x, 0, x + 1, 2) = min(min(x, x + 1), min(0, 2))
    composed1 = TMin(relu_neg, g)
    composed2 = TMin(TMin(x, Add(x, Const(1))), TMin(Const(0), Const(2)))

    n1 = normalize_ca(composed1)
    n2 = normalize_ca(composed2)

    print(f"  f(x) = {relu_neg}")
    print(f"  g(x) = {g}")
    print(f"  Composed v1: {composed1}")
    print(f"  Composed v2: {composed2}")
    print(f"  Normalized v1: {n1}")
    print(f"  Normalized v2: {n2}")
    print(f"  Same canonical form? {expr_key(n1) == expr_key(n2)}")

    # Evaluate at a few points
    print(f"\n  Evaluation comparison:")
    for val in [-2.0, -1.0, 0.0, 1.0, 2.0, 3.0]:
        sigma = lambda i, v=val: v
        v1 = eval_expr(sigma, composed1)
        v2 = eval_expr(sigma, composed2)
        print(f"    x={val:5.1f}: v1={v1:6.2f}, v2={v2:6.2f}, equal={abs(v1-v2)<1e-10}")
    print()


# ─────────────────────────────────────────
# Application 4: Scheduling Optimization
# ─────────────────────────────────────────

def scheduling_demo():
    """
    In job scheduling, the completion time of a task is:
        finish(j) = start(j) + duration(j)

    With precedence constraints, start times involve min/max:
        start(j) = max(release(j), max(finish(pred1), finish(pred2), ...))

    In the dual (min-plus) convention, these become tropical expressions.
    AC normalization simplifies the precedence DAG expressions.
    """
    print("=" * 60)
    print("APPLICATION 4: Scheduling Expression Simplification")
    print("=" * 60)

    # Three jobs with durations
    d0, d1, d2 = Const(3), Const(5), Const(2)

    # Job 0 starts at time 0
    # Job 1 starts after job 0: start(1) = finish(0) = 0 + 3 = 3
    # Job 2 starts after both job 0 and job 1 (parallel paths)

    finish0 = Add(Const(0), d0)  # 0 + 3 = 3
    finish1 = Add(finish0, d1)   # 3 + 5 = 8

    # finish(2) = min(finish(0), finish(1)) + d2  (earliest available + duration)
    # Two equivalent ways to write this:
    expr1 = Add(TMin(finish0, finish1), d2)
    expr2 = Add(TMin(finish1, finish0), d2)  # same, just swapped

    # More complex: nested version with different association
    finish0_alt = Add(d0, Const(0))  # same as finish0 but args swapped
    expr3 = Add(TMin(finish0_alt, finish1), d2)

    n1 = normalize_ca(expr1)
    n2 = normalize_ca(expr2)
    n3 = normalize_ca(expr3)

    print(f"  finish(0) = {finish0}")
    print(f"  finish(1) = {finish1}")
    print(f"  Expr1: {expr1}")
    print(f"  Expr2: {expr2}")
    print(f"  Expr3: {expr3}")
    print(f"  Norm1: {n1}")
    print(f"  Norm2: {n2}")
    print(f"  Norm3: {n3}")
    print(f"  1≡2? {expr_key(n1) == expr_key(n2)}")
    print(f"  1≡3? {expr_key(n1) == expr_key(n3)}")

    sigma = lambda i: 0
    print(f"  Value: {eval_expr(sigma, expr1)}")
    print()


if __name__ == "__main__":
    shortest_path_demo()
    cse_demo()
    relu_demo()
    scheduling_demo()
    print("All application demos completed.")


"""
Tropical AC Normalization — Interactive Demo

Demonstrates the canonicalization procedure for tropical expressions
under associativity and commutativity of min and +.
"""
import random
from dataclasses import dataclass
from typing import Union, Callable

# ─────────────────────────────────────────
# Tropical Expression Syntax
# ─────────────────────────────────────────

class TropExpr:
    """Base class for tropical expressions."""
    pass

@dataclass(frozen=True)
class Const(TropExpr):
    value: float
    def __repr__(self): return f"{self.value}"

@dataclass(frozen=True)
class Var(TropExpr):
    index: int
    def __repr__(self): return f"x{self.index}"

@dataclass(frozen=True)
class TMin(TropExpr):
    left: TropExpr
    right: TropExpr
    def __repr__(self): return f"min({self.left}, {self.right})"

@dataclass(frozen=True)
class Add(TropExpr):
    left: TropExpr
    right: TropExpr
    def __repr__(self): return f"({self.left} + {self.right})"


# ─────────────────────────────────────────
# Evaluation
# ─────────────────────────────────────────

def eval_expr(sigma: Callable[[int], float], e: TropExpr) -> float:
    """Evaluate a tropical expression under variable assignment sigma."""
    if isinstance(e, Const):
        return e.value
    elif isinstance(e, Var):
        return sigma(e.index)
    elif isinstance(e, TMin):
        return min(eval_expr(sigma, e.left), eval_expr(sigma, e.right))
    elif isinstance(e, Add):
        return eval_expr(sigma, e.left) + eval_expr(sigma, e.right)
    raise TypeError(f"Unknown expression type: {type(e)}")


# ─────────────────────────────────────────
# Flattening
# ─────────────────────────────────────────

def flatten_min(e: TropExpr) -> list:
    """Flatten a tmin tree into a list of non-tmin children."""
    if isinstance(e, TMin):
        return flatten_min(e.left) + flatten_min(e.right)
    return [e]

def flatten_add(e: TropExpr) -> list:
    """Flatten an add tree into a list of non-add children."""
    if isinstance(e, Add):
        return flatten_add(e.left) + flatten_add(e.right)
    return [e]


# ─────────────────────────────────────────
# Sorting Key (concrete total order)
# ─────────────────────────────────────────

def expr_key(e: TropExpr):
    """Produce a sortable key for a TropExpr."""
    if isinstance(e, Const):
        return (0, e.value)
    elif isinstance(e, Var):
        return (1, e.index)
    elif isinstance(e, TMin):
        return (2, expr_key(e.left), expr_key(e.right))
    elif isinstance(e, Add):
        return (3, expr_key(e.left), expr_key(e.right))
    raise TypeError


# ─────────────────────────────────────────
# Rebuilding
# ─────────────────────────────────────────

def rebuild_min(lst: list) -> TropExpr:
    """Rebuild a right-associated tmin chain from a nonempty list."""
    assert len(lst) >= 1
    if len(lst) == 1:
        return lst[0]
    return TMin(lst[0], rebuild_min(lst[1:]))

def rebuild_add(lst: list) -> TropExpr:
    """Rebuild a right-associated add chain from a nonempty list."""
    assert len(lst) >= 1
    if len(lst) == 1:
        return lst[0]
    return Add(lst[0], rebuild_add(lst[1:]))


# ─────────────────────────────────────────
# Normalization
# ─────────────────────────────────────────

def normalize_ca(e: TropExpr) -> TropExpr:
    """AC-canonicalize a tropical expression.

    1. Recursively normalize subexpressions
    2. Flatten same-operator subtrees
    3. Sort children
    4. Rebuild right-associated chain
    """
    if isinstance(e, (Const, Var)):
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
    raise TypeError


# ─────────────────────────────────────────
# Random Expression Generator
# ─────────────────────────────────────────

def random_expr(depth: int, num_vars: int = 3, num_consts: int = 3) -> TropExpr:
    """Generate a random tropical expression of given depth."""
    if depth <= 0:
        if random.random() < 0.5:
            return Var(random.randint(0, num_vars - 1))
        else:
            return Const(round(random.uniform(-5, 5), 1))
    op = random.choice([TMin, Add])
    return op(random_expr(depth - 1, num_vars, num_consts),
              random_expr(depth - 1, num_vars, num_consts))


def random_ac_variant(e: TropExpr, moves: int = 5) -> TropExpr:
    """Apply random AC moves (comm, assoc) to create an equivalent expression."""
    for _ in range(moves):
        e = _apply_random_ac_move(e)
    return e

def _apply_random_ac_move(e: TropExpr) -> TropExpr:
    """Apply a single random AC move somewhere in the expression."""
    if isinstance(e, TMin):
        r = random.random()
        if r < 0.3:
            # Commutativity
            return TMin(e.right, e.left)
        elif r < 0.5 and isinstance(e.left, TMin):
            # Associativity: (a min b) min c -> a min (b min c)
            return TMin(e.left.left, TMin(e.left.right, e.right))
        elif r < 0.7 and isinstance(e.right, TMin):
            # Reverse associativity
            return TMin(TMin(e.left, e.right.left), e.right.right)
        else:
            # Recurse
            if random.random() < 0.5:
                return TMin(_apply_random_ac_move(e.left), e.right)
            else:
                return TMin(e.left, _apply_random_ac_move(e.right))
    elif isinstance(e, Add):
        r = random.random()
        if r < 0.3:
            return Add(e.right, e.left)
        elif r < 0.5 and isinstance(e.left, Add):
            return Add(e.left.left, Add(e.left.right, e.right))
        elif r < 0.7 and isinstance(e.right, Add):
            return Add(Add(e.left, e.right.left), e.right.right)
        else:
            if random.random() < 0.5:
                return Add(_apply_random_ac_move(e.left), e.right)
            else:
                return Add(e.left, _apply_random_ac_move(e.right))
    return e


# ─────────────────────────────────────────
# Demos
# ─────────────────────────────────────────

def demo_basic():
    """Basic demonstration of normalization."""
    print("=" * 60)
    print("DEMO 1: Basic Normalization")
    print("=" * 60)

    x0, x1, x2 = Var(0), Var(1), Var(2)

    # Example: min(min(x2, x0), x1) should normalize to min(x0, min(x1, x2))
    e1 = TMin(TMin(x2, x0), x1)
    e2 = TMin(x0, TMin(x1, x2))

    n1 = normalize_ca(e1)
    n2 = normalize_ca(e2)

    print(f"  e1 = {e1}")
    print(f"  e2 = {e2}")
    print(f"  normalize(e1) = {n1}")
    print(f"  normalize(e2) = {n2}")
    print(f"  Equal? {expr_key(n1) == expr_key(n2)}")
    print()

    # Example with add: (x1 + x0) + x2 vs x0 + (x2 + x1)
    e3 = Add(Add(x1, x0), x2)
    e4 = Add(x0, Add(x2, x1))

    n3 = normalize_ca(e3)
    n4 = normalize_ca(e4)

    print(f"  e3 = {e3}")
    print(f"  e4 = {e4}")
    print(f"  normalize(e3) = {n3}")
    print(f"  normalize(e4) = {n4}")
    print(f"  Equal? {expr_key(n3) == expr_key(n4)}")
    print()


def demo_soundness():
    """Verify soundness: normalization preserves evaluation."""
    print("=" * 60)
    print("DEMO 2: Soundness Verification")
    print("=" * 60)

    random.seed(42)
    n_tests = 100
    n_vars = 4
    passed = 0

    for _ in range(n_tests):
        e = random_expr(depth=4, num_vars=n_vars)
        ne = normalize_ca(e)

        # Test with 5 random assignments
        all_ok = True
        for _ in range(5):
            vals = [random.uniform(-10, 10) for _ in range(n_vars)]
            sigma = lambda i, v=vals: v[i]
            v1 = eval_expr(sigma, e)
            v2 = eval_expr(sigma, ne)
            if abs(v1 - v2) > 1e-10:
                all_ok = False
                break

        if all_ok:
            passed += 1

    print(f"  Tested {n_tests} random expressions × 5 assignments each")
    print(f"  Passed: {passed}/{n_tests}")
    print()


def demo_completeness():
    """Verify completeness: AC-equivalent expressions have same normal form."""
    print("=" * 60)
    print("DEMO 3: Completeness Verification")
    print("=" * 60)

    random.seed(123)
    n_tests = 100
    passed = 0

    for _ in range(n_tests):
        e = random_expr(depth=3, num_vars=3)
        e_variant = random_ac_variant(e, moves=10)

        n1 = normalize_ca(e)
        n2 = normalize_ca(e_variant)

        if expr_key(n1) == expr_key(n2):
            passed += 1

    print(f"  Generated {n_tests} pairs of AC-equivalent expressions")
    print(f"  Same normal form: {passed}/{n_tests}")
    print()


def demo_idempotence():
    """Verify idempotence: normalizing twice = normalizing once."""
    print("=" * 60)
    print("DEMO 4: Idempotence Verification")
    print("=" * 60)

    random.seed(456)
    n_tests = 100
    passed = 0

    for _ in range(n_tests):
        e = random_expr(depth=4, num_vars=4)
        n1 = normalize_ca(e)
        n2 = normalize_ca(n1)

        if expr_key(n1) == expr_key(n2):
            passed += 1

    print(f"  Tested {n_tests} random expressions")
    print(f"  Idempotent: {passed}/{n_tests}")
    print()


def demo_boundary():
    """Show that distributivity lies outside the AC fragment."""
    print("=" * 60)
    print("DEMO 5: Distributivity Boundary")
    print("=" * 60)

    a, b, c = Const(1), Const(2), Const(3)

    # a + min(b, c) vs min(a+b, a+c)
    e1 = Add(a, TMin(b, c))
    e2 = TMin(Add(a, b), Add(a, c))

    n1 = normalize_ca(e1)
    n2 = normalize_ca(e2)

    sigma = lambda i: 0  # dummy, all constants

    print(f"  e1 = {e1}")
    print(f"  e2 = {e2}")
    print(f"  eval(e1) = {eval_expr(sigma, e1)}")
    print(f"  eval(e2) = {eval_expr(sigma, e2)}")
    print(f"  normalize(e1) = {n1}")
    print(f"  normalize(e2) = {n2}")
    print(f"  Same normal form? {expr_key(n1) == expr_key(n2)}")
    print(f"  → Semantically equal but NOT AC-equivalent (different root operators)")
    print()


if __name__ == "__main__":
    demo_basic()
    demo_soundness()
    demo_completeness()
    demo_idempotence()
    demo_boundary()
    print("All demos completed.")


"""Generate PACKAGE.json with all deliverables bundled."""
import json
import base64
import os

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

def read_image_base64(path):
    with open(path, 'rb') as f:
        data = base64.b64encode(f.read()).decode('utf-8')
    return f"data:image/png;base64,{data}"

# Read all content
article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
lean_code = read_file('Tropical/ACNormalForm.lean')
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')
applications_code = read_file('applications.py')
viz_code = read_file('visualizations.py')

# Read images
viz_files = [
    ('viz_performance.png', 'Normalization Performance (O(N log N))'),
    ('viz_deduplication.png', 'Deduplication Power'),
    ('viz_soundness.png', 'Soundness Verification'),
    ('viz_tropical_functions.png', 'Tropical Piecewise-Linear Functions'),
]

visualizations = []
for fname, name in viz_files:
    if os.path.exists(fname):
        visualizations.append({
            'name': name,
            'data': read_image_base64(fname)
        })

package = {
    'title': 'Canonical Forms for Tropical AC Normalization: A Certified Decision Procedure',
    'domain': 'Tropical Algebra',
    'article': article,
    'research_paper': research_paper,
    'future_directions': future_directions,
    'demos': [
        {
            'name': 'Tropical AC Normalization Demo',
            'code': demo_code
        },
        {
            'name': 'Real-World Applications',
            'code': applications_code
        }
    ],
    'algorithms': [
        {
            'name': 'AC Normalization Algorithm',
            'pseudocode': """NORMALIZE(e):
    case Const(r): return Const(r)
    case Var(n): return Var(n)
    case TMin(a, b):
        a' = NORMALIZE(a)
        b' = NORMALIZE(b)
        children = FLATTEN_MIN(a') ++ FLATTEN_MIN(b')
        SORT(children)
        return REBUILD_MIN(children)
    case Add(a, b):
        a' = NORMALIZE(a)
        b' = NORMALIZE(b)
        children = FLATTEN_ADD(a') ++ FLATTEN_ADD(b')
        SORT(children)
        return REBUILD_ADD(children)

Complexity: O(N log N) time, O(N) space
Properties: Sound, Complete (for AC), Idempotent""",
            'code': algorithms_code
        }
    ],
    'visualizations': visualizations,
    'lean_proofs': lean_code
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print(f"PACKAGE.json generated ({os.path.getsize('PACKAGE.json')} bytes)")


"""
Tropical AC Normalization — Visualizations

Generates publication-quality figures illustrating the normalization
algorithm and its properties.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import random
import time
import io
import base64

# Import from our modules
import sys
sys.path.insert(0, '.')
from algorithms import (TropExpr, Const, Var, TMin, Add,
                         normalize_ca, eval_expr, expr_key, expr_size,
                         random_expr, flatten_min, flatten_add)


def fig_to_base64(fig) -> str:
    """Convert a matplotlib figure to a base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


def viz_normalization_performance():
    """Plot normalization time vs expression size."""
    random.seed(2024)

    depths = list(range(2, 14))
    sizes = []
    times = []

    for d in depths:
        for _ in range(30):
            e = random_expr(d, num_vars=4)
            s = expr_size(e)
            t0 = time.perf_counter()
            normalize_ca(e)
            t1 = time.perf_counter()
            sizes.append(s)
            times.append((t1 - t0) * 1000)

    fig, ax = plt.subplots(1, 1, figsize=(8, 5))
    ax.scatter(sizes, times, alpha=0.4, s=15, color='#2196F3')

    # Fit N log N trend
    s_arr = np.array(sizes, dtype=float)
    t_arr = np.array(times, dtype=float)
    mask = s_arr > 10
    if mask.sum() > 5:
        nlogn = s_arr[mask] * np.log2(s_arr[mask])
        coeff = np.median(t_arr[mask] / nlogn)
        s_fit = np.linspace(10, max(sizes), 200)
        t_fit = coeff * s_fit * np.log2(s_fit)
        ax.plot(s_fit, t_fit, 'r--', linewidth=2, label='O(N log N) fit')

    ax.set_xlabel('Expression Size (nodes)', fontsize=12)
    ax.set_ylabel('Normalization Time (ms)', fontsize=12)
    ax.set_title('AC Normalization Performance', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    fig.tight_layout()

    return fig


def viz_deduplication_power():
    """Bar chart showing deduplication ratio at different depths."""
    random.seed(42)

    depths = [2, 3, 4, 5, 6, 7, 8]
    before_counts = []
    after_counts = []

    for d in depths:
        exprs = [random_expr(d, num_vars=3) for _ in range(300)]
        kb = set(expr_key(e) for e in exprs)
        ka = set(expr_key(normalize_ca(e)) for e in exprs)
        before_counts.append(len(kb))
        after_counts.append(len(ka))

    fig, ax = plt.subplots(1, 1, figsize=(8, 5))
    x = np.arange(len(depths))
    w = 0.35
    bars1 = ax.bar(x - w/2, before_counts, w, label='Before normalization',
                   color='#FF9800', alpha=0.8)
    bars2 = ax.bar(x + w/2, after_counts, w, label='After normalization',
                   color='#4CAF50', alpha=0.8)

    ax.set_xlabel('Expression Depth', fontsize=12)
    ax.set_ylabel('Distinct Expression Forms', fontsize=12)
    ax.set_title('Deduplication Power of AC Normalization', fontsize=14)
    ax.set_xticks(x)
    ax.set_xticklabels(depths)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3, axis='y')
    fig.tight_layout()

    return fig


def viz_soundness_errors():
    """Histogram of evaluation errors (should all be zero)."""
    random.seed(123)

    errors = []
    for _ in range(500):
        e = random_expr(depth=5, num_vars=4)
        ne = normalize_ca(e)
        vals = [random.uniform(-10, 10) for _ in range(4)]
        sigma = lambda i, v=vals: v[i]
        v1 = eval_expr(sigma, e)
        v2 = eval_expr(sigma, ne)
        errors.append(abs(v1 - v2))

    fig, ax = plt.subplots(1, 1, figsize=(8, 5))
    ax.hist(errors, bins=50, color='#2196F3', alpha=0.8, edgecolor='white')
    ax.set_xlabel('|eval(e) - eval(normalize(e))|', fontsize=12)
    ax.set_ylabel('Count', fontsize=12)
    ax.set_title('Soundness Verification: All Errors Are Zero', fontsize=14)
    ax.axvline(x=0, color='red', linewidth=2, linestyle='--', label='Expected: 0')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3, axis='y')

    max_err = max(errors)
    ax.annotate(f'Max error: {max_err:.2e}',
                xy=(0.95, 0.95), xycoords='axes fraction',
                ha='right', va='top', fontsize=12,
                bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow'))
    fig.tight_layout()

    return fig


def viz_tropical_functions():
    """Plot tropical piecewise-linear functions before/after normalization."""
    x = Var(0)

    # f(x) = min(x, min(2-x, 1))
    e1 = TMin(x, TMin(Add(Const(2), TMin(Const(0), x)), Const(1)))
    # Rearranged version
    e2 = TMin(Const(1), TMin(TMin(Add(Const(2), TMin(Const(0), x)), x), Const(1)))

    n1 = normalize_ca(e1)
    n2 = normalize_ca(e2)

    xs = np.linspace(-3, 5, 500)
    y1 = [eval_expr(lambda i, v=v: v, e1) for v in xs]
    y2 = [eval_expr(lambda i, v=v: v, e2) for v in xs]
    yn = [eval_expr(lambda i, v=v: v, n1) for v in xs]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    ax1.plot(xs, y1, 'b-', linewidth=2, label='Original e₁')
    ax1.plot(xs, y2, 'r--', linewidth=2, label='Rearranged e₂')
    ax1.set_xlabel('x', fontsize=12)
    ax1.set_ylabel('f(x)', fontsize=12)
    ax1.set_title('Tropical Functions (Before Normalization)', fontsize=13)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)

    ax2.plot(xs, yn, 'g-', linewidth=2, label='Normalized')
    ax2.plot(xs, y1, 'b:', linewidth=1, alpha=0.5, label='Original')
    ax2.set_xlabel('x', fontsize=12)
    ax2.set_ylabel('f(x)', fontsize=12)
    ax2.set_title('After AC Normalization', fontsize=13)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    same = expr_key(n1) == expr_key(n2)
    fig.suptitle(f'Same canonical form: {same}', fontsize=11, y=1.02)
    fig.tight_layout()

    return fig


if __name__ == "__main__":
    print("Generating visualizations...")

    fig1 = viz_normalization_performance()
    fig1.savefig('viz_performance.png', dpi=150, bbox_inches='tight')
    print("  Saved viz_performance.png")

    fig2 = viz_deduplication_power()
    fig2.savefig('viz_deduplication.png', dpi=150, bbox_inches='tight')
    print("  Saved viz_deduplication.png")

    fig3 = viz_soundness_errors()
    fig3.savefig('viz_soundness.png', dpi=150, bbox_inches='tight')
    print("  Saved viz_soundness.png")

    fig4 = viz_tropical_functions()
    fig4.savefig('viz_tropical_functions.png', dpi=150, bbox_inches='tight')
    print("  Saved viz_tropical_functions.png")

    print("All visualizations generated.")

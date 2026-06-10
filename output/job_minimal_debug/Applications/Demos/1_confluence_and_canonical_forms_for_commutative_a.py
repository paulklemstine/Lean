#!/usr/bin/env python3
"""
Tropical AC Canonical Forms: Applications

Demonstrates real-world applications of tropical AC normalization.
"""

from dataclasses import dataclass
from typing import List, Dict, Tuple, Optional
from functools import cmp_to_key


# --- Expression Types (reused from algorithms.py) ---

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
    left: 'Expr'
    right: 'Expr'
    def __repr__(self): return f"min({self.left}, {self.right})"

@dataclass(frozen=True)
class Add:
    left: 'Expr'
    right: 'Expr'
    def __repr__(self): return f"({self.left} + {self.right})"

Expr = object  # Union type hint


def expr_tag(e) -> int:
    if isinstance(e, Const): return 0
    if isinstance(e, Var): return 1
    if isinstance(e, TMin): return 2
    if isinstance(e, Add): return 3
    return -1

def expr_cmp(e1, e2) -> int:
    t1, t2 = expr_tag(e1), expr_tag(e2)
    if t1 != t2: return -1 if t1 < t2 else 1
    if isinstance(e1, Const):
        return -1 if e1.value < e2.value else (0 if e1.value == e2.value else 1)
    if isinstance(e1, Var):
        return -1 if e1.index < e2.index else (0 if e1.index == e2.index else 1)
    if isinstance(e1, (TMin, Add)):
        c = expr_cmp(e1.left, e2.left)
        return c if c != 0 else expr_cmp(e1.right, e2.right)
    return 0

_key = cmp_to_key(expr_cmp)

def flatten_min(e): return flatten_min(e.left) + flatten_min(e.right) if isinstance(e, TMin) else [e]
def flatten_add(e): return flatten_add(e.left) + flatten_add(e.right) if isinstance(e, Add) else [e]
def build_min(l): return l[0] if len(l) == 1 else TMin(l[0], build_min(l[1:]))
def build_add(l): return l[0] if len(l) == 1 else Add(l[0], build_add(l[1:]))

def normalize_ca(e):
    if isinstance(e, (Const, Var)): return e
    if isinstance(e, TMin):
        a, b = normalize_ca(e.left), normalize_ca(e.right)
        children = sorted(flatten_min(TMin(a, b)), key=_key)
        return build_min(children)
    if isinstance(e, Add):
        a, b = normalize_ca(e.left), normalize_ca(e.right)
        children = sorted(flatten_add(Add(a, b)), key=_key)
        return build_add(children)

def evaluate(e, env):
    if isinstance(e, Const): return e.value
    if isinstance(e, Var): return env(e.index)
    if isinstance(e, TMin): return min(evaluate(e.left, env), evaluate(e.right, env))
    if isinstance(e, Add): return evaluate(e.left, env) + evaluate(e.right, env)


# ============================================================
# Application 1: Shortest Path Verification
# ============================================================

def shortest_path_demo():
    """
    Demonstrate how tropical normalization verifies shortest-path equivalence.
    
    In a weighted graph, the shortest path from s to t through intermediate
    nodes can be expressed as a tropical expression:
      path = min over all routes (sum of edge weights along route)
    
    Two different routing strategies are equivalent iff their tropical
    expressions have the same AC canonical form.
    """
    print("=" * 60)
    print("APPLICATION 1: Shortest Path Verification")
    print("=" * 60)
    
    # Edge weights as variables
    # x0 = w(A,B), x1 = w(A,C), x2 = w(B,D), x3 = w(C,D), x4 = w(B,C)
    wAB, wAC, wBD, wCD, wBC = Var(0), Var(1), Var(2), Var(3), Var(4)
    
    # Strategy 1: enumerate paths explicitly
    # A->B->D, A->C->D, A->B->C->D
    route1 = TMin(Add(wAB, wBD), TMin(Add(wAC, wCD), Add(Add(wAB, wBC), wCD)))
    
    # Strategy 2: different enumeration order
    # A->C->D, A->B->C->D, A->B->D  
    route2 = TMin(Add(wAC, wCD), TMin(Add(wCD, Add(wBC, wAB)), Add(wBD, wAB)))
    
    n1 = normalize_ca(route1)
    n2 = normalize_ca(route2)
    
    print(f"\n  Strategy 1: {route1}")
    print(f"  Canonical:  {n1}")
    print(f"\n  Strategy 2: {route2}")
    print(f"  Canonical:  {n2}")
    print(f"\n  AC-Equivalent: {n1 == n2}")
    
    # Verify with concrete weights
    weights = {0: 3, 1: 5, 2: 2, 3: 4, 4: 1}
    env = lambda i: weights.get(i, 0)
    v1 = evaluate(route1, env)
    v2 = evaluate(route2, env)
    print(f"\n  With weights A-B=3, A-C=5, B-D=2, C-D=4, B-C=1:")
    print(f"  Strategy 1 value: {v1}")
    print(f"  Strategy 2 value: {v2}")
    print(f"  Values match: {abs(v1 - v2) < 1e-10}")


# ============================================================
# Application 2: Common Subexpression Elimination
# ============================================================

def cse_demo():
    """
    Demonstrate how canonical forms enable common subexpression elimination.
    
    Two subexpressions that are AC-equivalent can be identified and shared,
    reducing computation.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Common Subexpression Elimination")
    print("=" * 60)
    
    x0, x1, x2, x3 = Var(0), Var(1), Var(2), Var(3)
    
    # A complex expression with redundant subexpressions
    sub1 = Add(x0, Add(x1, x2))    # x0 + x1 + x2
    sub2 = Add(x2, Add(x0, x1))    # x2 + x0 + x1 (same up to AC!)
    sub3 = Add(Add(x1, x2), x0)    # (x1 + x2) + x0 (same up to AC!)
    
    expr = TMin(Add(sub1, x3), TMin(Add(sub2, x3), Add(sub3, x3)))
    
    print(f"\n  Expression: {expr}")
    print(f"  Size: {count_nodes(expr)} nodes")
    
    # Normalize
    norm = normalize_ca(expr)
    print(f"\n  Normalized: {norm}")
    print(f"  Size: {count_nodes(norm)} nodes")
    
    # Identify unique normalized subexpressions
    subs = set()
    collect_subexprs(norm, subs)
    print(f"\n  Unique subexpressions after normalization: {len(subs)}")
    
    subs_orig = set()
    collect_subexprs(expr, subs_orig)
    print(f"  Unique subexpressions before normalization: {len(subs_orig)}")
    print(f"  Reduction: {len(subs_orig) - len(subs)} fewer unique subexpressions")


def count_nodes(e) -> int:
    if isinstance(e, (Const, Var)): return 1
    if isinstance(e, (TMin, Add)): return 1 + count_nodes(e.left) + count_nodes(e.right)
    return 0

def collect_subexprs(e, s: set):
    s.add(e)
    if isinstance(e, (TMin, Add)):
        collect_subexprs(e.left, s)
        collect_subexprs(e.right, s)


# ============================================================
# Application 3: Tropical Expression Equivalence Checker
# ============================================================

def equivalence_checker_demo():
    """
    Build an equivalence checker for tropical expressions using
    canonical forms as a decision procedure.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: AC Equivalence Decision Procedure")
    print("=" * 60)
    
    x0, x1, x2 = Var(0), Var(1), Var(2)
    c1, c2 = Const(1.0), Const(2.0)
    
    test_cases = [
        # (expr1, expr2, expected_AC_equiv)
        (TMin(x0, x1), TMin(x1, x0), True, "min commutativity"),
        (Add(x0, x1), Add(x1, x0), True, "add commutativity"),
        (TMin(TMin(x0, x1), x2), TMin(x0, TMin(x1, x2)), True, "min associativity"),
        (Add(Add(x0, x1), x2), Add(x0, Add(x1, x2)), True, "add associativity"),
        (TMin(x0, x1), TMin(x0, x2), False, "different children"),
        (Add(x0, c1), Add(x0, c2), False, "different constants"),
        (TMin(x0, x0), x0, False, "idempotence (NOT AC)"),
        (Add(x0, TMin(x1, x2)), TMin(Add(x0, x1), Add(x0, x2)), False, 
         "distributivity (NOT AC)"),
    ]
    
    print()
    for e1, e2, expected, name in test_cases:
        n1 = normalize_ca(e1)
        n2 = normalize_ca(e2)
        result = n1 == n2
        status = "✓" if result == expected else "✗ WRONG"
        print(f"  {name:30s} | AC-equiv: {result!s:5s} (expected {expected!s:5s}) {status}")


if __name__ == "__main__":
    shortest_path_demo()
    cse_demo()
    equivalence_checker_demo()


#!/usr/bin/env python3
"""
Tropical AC Canonical Forms: Demonstration

This script demonstrates the flatten-sort-rebuild normalization procedure
for tropical (min-plus) expressions, showing how AC-equivalent expressions
normalize to identical canonical forms.
"""

from dataclasses import dataclass
from typing import Union, List, Callable
from functools import reduce


# --- Expression AST ---

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
    left: 'Expr'
    right: 'Expr'
    def __repr__(self): return f"min({self.left}, {self.right})"

@dataclass(frozen=True)
class Add:
    left: 'Expr'
    right: 'Expr'
    def __repr__(self): return f"({self.left} + {self.right})"

Expr = Union[Const, Var, TMin, Add]


# --- Evaluation ---

def evaluate(expr: Expr, env: Callable[[int], float]) -> float:
    """Evaluate a tropical expression in an environment."""
    if isinstance(expr, Const): return expr.value
    if isinstance(expr, Var): return env(expr.index)
    if isinstance(expr, TMin): return min(evaluate(expr.left, env), evaluate(expr.right, env))
    if isinstance(expr, Add): return evaluate(expr.left, env) + evaluate(expr.right, env)
    raise ValueError(f"Unknown expression type: {type(expr)}")


# --- Comparison ---

def tag(expr: Expr) -> int:
    if isinstance(expr, Const): return 0
    if isinstance(expr, Var): return 1
    if isinstance(expr, TMin): return 2
    if isinstance(expr, Add): return 3
    return -1

def cmp(e1: Expr, e2: Expr) -> int:
    """Compare two expressions. Returns -1, 0, or 1."""
    t1, t2 = tag(e1), tag(e2)
    if t1 != t2:
        return -1 if t1 < t2 else 1
    if isinstance(e1, Const) and isinstance(e2, Const):
        return -1 if e1.value < e2.value else (0 if e1.value == e2.value else 1)
    if isinstance(e1, Var) and isinstance(e2, Var):
        return -1 if e1.index < e2.index else (0 if e1.index == e2.index else 1)
    if isinstance(e1, (TMin, Add)) and isinstance(e2, type(e1)):
        c = cmp(e1.left, e2.left)
        return c if c != 0 else cmp(e1.right, e2.right)
    return 0

from functools import cmp_to_key
sort_key = cmp_to_key(cmp)


# --- Flattening ---

def flatten_min(expr: Expr) -> List[Expr]:
    if isinstance(expr, TMin):
        return flatten_min(expr.left) + flatten_min(expr.right)
    return [expr]

def flatten_add(expr: Expr) -> List[Expr]:
    if isinstance(expr, Add):
        return flatten_add(expr.left) + flatten_add(expr.right)
    return [expr]


# --- Building ---

def build_min(exprs: List[Expr]) -> Expr:
    if len(exprs) == 1: return exprs[0]
    return TMin(exprs[0], build_min(exprs[1:]))

def build_add(exprs: List[Expr]) -> Expr:
    if len(exprs) == 1: return exprs[0]
    return Add(exprs[0], build_add(exprs[1:]))


# --- Normalization ---

def normalize_ca(expr: Expr) -> Expr:
    """Normalize a tropical expression for AC equivalence."""
    if isinstance(expr, (Const, Var)):
        return expr
    if isinstance(expr, TMin):
        a = normalize_ca(expr.left)
        b = normalize_ca(expr.right)
        children = flatten_min(TMin(a, b))
        children.sort(key=sort_key)
        return build_min(children)
    if isinstance(expr, Add):
        a = normalize_ca(expr.left)
        b = normalize_ca(expr.right)
        children = flatten_add(Add(a, b))
        children.sort(key=sort_key)
        return build_add(children)
    raise ValueError(f"Unknown expression type: {type(expr)}")


# --- Demonstrations ---

def demo_basic():
    """Demonstrate basic AC normalization."""
    print("=" * 60)
    print("DEMO 1: Basic AC Normalization")
    print("=" * 60)

    x0, x1, x2 = Var(0), Var(1), Var(2)

    # Commutativity of min
    e1 = TMin(x0, x1)
    e2 = TMin(x1, x0)
    n1, n2 = normalize_ca(e1), normalize_ca(e2)
    print(f"\n  {e1}")
    print(f"  normalizes to: {n1}")
    print(f"  {e2}")
    print(f"  normalizes to: {n2}")
    print(f"  Equal: {n1 == n2} ✓" if n1 == n2 else f"  Equal: {n1 == n2} ✗")

    # Associativity of min
    e3 = TMin(TMin(x0, x1), x2)
    e4 = TMin(x0, TMin(x1, x2))
    n3, n4 = normalize_ca(e3), normalize_ca(e4)
    print(f"\n  {e3}")
    print(f"  normalizes to: {n3}")
    print(f"  {e4}")
    print(f"  normalizes to: {n4}")
    print(f"  Equal: {n3 == n4} ✓" if n3 == n4 else f"  Equal: {n3 == n4} ✗")

    # Mixed AC
    e5 = TMin(x2, TMin(x0, x1))
    e6 = TMin(TMin(x1, x2), x0)
    n5, n6 = normalize_ca(e5), normalize_ca(e6)
    print(f"\n  {e5}")
    print(f"  normalizes to: {n5}")
    print(f"  {e6}")
    print(f"  normalizes to: {n6}")
    print(f"  Equal: {n5 == n6} ✓" if n5 == n6 else f"  Equal: {n5 == n6} ✗")


def demo_add():
    """Demonstrate AC normalization for addition."""
    print("\n" + "=" * 60)
    print("DEMO 2: Addition AC Normalization")
    print("=" * 60)

    x0, x1, x2 = Var(0), Var(1), Var(2)
    c3 = Const(3.0)

    e1 = Add(Add(x2, c3), Add(x0, x1))
    e2 = Add(x0, Add(x1, Add(x2, c3)))
    e3 = Add(Add(c3, x1), Add(x2, x0))

    for e in [e1, e2, e3]:
        n = normalize_ca(e)
        print(f"\n  {e}")
        print(f"  normalizes to: {n}")

    n1, n2, n3 = normalize_ca(e1), normalize_ca(e2), normalize_ca(e3)
    print(f"\n  All equal: {n1 == n2 == n3} ✓" if n1 == n2 == n3 else f"  Not all equal ✗")


def demo_nested():
    """Demonstrate normalization of nested expressions."""
    print("\n" + "=" * 60)
    print("DEMO 3: Nested Expressions")
    print("=" * 60)

    x0, x1 = Var(0), Var(1)
    c1, c2 = Const(1.0), Const(2.0)

    # min(x0 + x1, x1 + x0) — children are AC-equivalent sums
    e1 = TMin(Add(x0, x1), Add(x1, x0))
    n1 = normalize_ca(e1)
    print(f"\n  {e1}")
    print(f"  normalizes to: {n1}")

    # Deeply nested: min(min(1+x0, x1+2), min(2+x1, x0+1))
    e2 = TMin(TMin(Add(c1, x0), Add(x1, c2)), TMin(Add(c2, x1), Add(x0, c1)))
    e3 = TMin(TMin(Add(x0, c1), Add(c2, x1)), TMin(Add(x1, c2), Add(c1, x0)))
    n2, n3 = normalize_ca(e2), normalize_ca(e3)
    print(f"\n  {e2}")
    print(f"  normalizes to: {n2}")
    print(f"  {e3}")
    print(f"  normalizes to: {n3}")
    print(f"  Equal: {n2 == n3} ✓" if n2 == n3 else f"  Equal: {n2 == n3} ✗")


def demo_soundness():
    """Demonstrate that normalization preserves semantics."""
    print("\n" + "=" * 60)
    print("DEMO 4: Soundness Verification")
    print("=" * 60)

    import random
    random.seed(42)

    x0, x1, x2 = Var(0), Var(1), Var(2)

    exprs = [
        TMin(TMin(x0, x1), x2),
        TMin(x2, TMin(x1, x0)),
        Add(Add(x0, x1), x2),
        Add(x2, Add(x0, x1)),
        TMin(Add(x0, x1), Add(x1, x2)),
    ]

    print("\n  Testing 100 random environments per expression...")
    all_ok = True
    for expr in exprs:
        norm = normalize_ca(expr)
        for _ in range(100):
            env = lambda i, vals=[random.uniform(-10, 10) for _ in range(3)]: vals[i] if i < 3 else 0
            v1 = evaluate(expr, env)
            v2 = evaluate(norm, env)
            if abs(v1 - v2) > 1e-10:
                print(f"  MISMATCH: {expr} -> {v1} vs {norm} -> {v2}")
                all_ok = False
    print(f"  All tests passed ✓" if all_ok else "  Some tests FAILED ✗")


def demo_idempotence():
    """Demonstrate that normalization is idempotent."""
    print("\n" + "=" * 60)
    print("DEMO 5: Idempotence")
    print("=" * 60)

    x0, x1, x2 = Var(0), Var(1), Var(2)

    exprs = [
        TMin(x2, TMin(x0, x1)),
        Add(Add(x1, x0), Add(x2, Const(5.0))),
        TMin(Add(x0, x1), TMin(x2, Const(3.0))),
    ]

    all_ok = True
    for expr in exprs:
        n1 = normalize_ca(expr)
        n2 = normalize_ca(n1)
        ok = n1 == n2
        all_ok = all_ok and ok
        print(f"\n  {expr}")
        print(f"  normalize_ca:           {n1}")
        print(f"  normalize_ca²:          {n2}")
        print(f"  Idempotent: {ok} ✓" if ok else f"  Idempotent: {ok} ✗")

    print(f"\n  All idempotent ✓" if all_ok else "\n  Some NOT idempotent ✗")


if __name__ == "__main__":
    demo_basic()
    demo_add()
    demo_nested()
    demo_soundness()
    demo_idempotence()
    print("\n" + "=" * 60)
    print("All demonstrations complete.")
    print("=" * 60)

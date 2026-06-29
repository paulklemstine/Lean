#!/usr/bin/env python3
"""
EML Depth Separation — Applications

Real-world applications of the depth separation theory:
1. Compiler optimization barriers for symbolic math systems
2. Complexity certification for expression evaluation
3. Growth rate classification for scientific computing
"""

import math
from typing import List, Tuple, Callable
from algorithms import iter_exp, Expr, NodeType, certify_growth_bound, test_representability


# ============================================================
# Application 1: Compiler Optimization Barrier Detection
# ============================================================

def analyze_compilation_barrier(target_name: str,
                                target_fn: Callable[[float], float],
                                max_depth: int = 3,
                                max_size: int = 9):
    """
    Analyze whether a target function can be compiled into bounded-depth EML.

    This application is relevant for symbolic math compilers that need to
    transform expressions into a restricted instruction set (like EML).
    The depth separation theorem tells us when compilation is impossible.

    Args:
        target_name: Human-readable name
        target_fn: The target function
        max_depth: Maximum EML depth to search
        max_size: Maximum expression size to search

    Returns:
        Analysis report as string.
    """
    grid = [0.5, 1.0, 1.5, 2.0, 2.5, 3.0]

    print(f"\n--- Compilation Barrier Analysis: {target_name} ---")

    for D in range(max_depth + 1):
        result = test_representability(target_fn, D, max_size, grid)
        if result:
            print(f"  Depth {D}: COMPILABLE (size={result.size})")
            print(f"    Expression: {result}")
        else:
            print(f"  Depth {D}: No compilation found (size ≤ {max_size})")

    # Growth rate analysis
    growth_samples = []
    for x in [10.0, 20.0, 50.0, 100.0]:
        try:
            val = target_fn(x)
            if not math.isinf(val) and val > 0:
                growth_samples.append((x, math.log(val)))
        except (OverflowError, ValueError):
            growth_samples.append((x, float('inf')))

    if growth_samples:
        print(f"  Growth behavior:")
        for x, log_val in growth_samples:
            if math.isinf(log_val):
                print(f"    f({x}) = OVERFLOW")
            else:
                print(f"    log(f({x})) ≈ {log_val:.2f}")


# ============================================================
# Application 2: Expression Complexity Certification
# ============================================================

def certify_expression_complexity(expr: Expr) -> dict:
    """
    Certify the complexity class of an EML expression.

    Uses the growth bound theorem to classify the expression's
    asymptotic growth rate:
    - Level 0: polynomial growth
    - Level 1: single-exponential growth
    - Level k: k-fold iterated exponential growth

    Args:
        expr: The expression to classify

    Returns:
        Certification report.
    """
    D = expr.eml_depth
    grid = [float(i) for i in range(1, 30)]

    report = {
        'eml_depth': D,
        'size': expr.size,
        'has_inv': expr.has_inv,
        'growth_level_bound': D + 1,
        'growth_bound_certified': False
    }

    # Verify growth bound
    cert = certify_growth_bound(expr, grid)
    for C, info in cert.items():
        if info['certified']:
            report['growth_bound_certified'] = True
            report['certified_C'] = C
            report['max_ratio'] = info['max_ratio']
            break

    return report


# ============================================================
# Application 3: Scientific Computing Growth Classification
# ============================================================

def classify_growth_rate(fn: Callable[[float], float],
                         name: str = "f") -> str:
    """
    Classify the growth rate of a function using the iterExp hierarchy.

    Tests whether the function grows:
    - Polynomially (level 0)
    - Single-exponentially (level 1)
    - Double-exponentially (level 2)
    - etc.

    This is useful for predicting numerical overflow in scientific
    computing and choosing appropriate data representations.

    Args:
        fn: The function to classify
        name: Display name

    Returns:
        Classification string.
    """
    test_points = [10.0, 50.0, 100.0, 500.0]

    print(f"\n--- Growth Classification: {name} ---")

    # Compare against iterExp levels
    for level in range(5):
        exceeds = False
        for x in test_points:
            try:
                val = abs(fn(x))
                bound = iter_exp(level, x)
                if math.isinf(bound):
                    break
                if val > bound:
                    exceeds = True
                    break
            except (OverflowError, ValueError):
                exceeds = True
                break

        if not exceeds:
            print(f"  Growth level: ≤ {level} (bounded by iterExp({level}, x))")
            if level == 0:
                return f"{name} has sub-linear growth"
            elif level == 1:
                return f"{name} has at most single-exponential growth"
            else:
                return f"{name} has at most {level}-fold exponential growth"

    print(f"  Growth level: > 4 (exceeds iterExp(4, x))")
    return f"{name} has super-tetration growth"


# ============================================================
# Demo
# ============================================================

if __name__ == "__main__":
    print("=" * 70)
    print("APPLICATION DEMOS")
    print("=" * 70)

    # Application 1: Compiler barriers
    print("\n" + "=" * 70)
    print("Application 1: Compiler Optimization Barriers")
    print("=" * 70)

    analyze_compilation_barrier("exp(x)", lambda x: math.exp(x))
    analyze_compilation_barrier("exp(exp(x))", lambda x: math.exp(math.exp(x)))
    analyze_compilation_barrier("x * exp(x^2)", lambda x: x * math.exp(x**2))
    analyze_compilation_barrier("iterExp(3, x)", lambda x: iter_exp(3, x))

    # Application 2: Complexity certification
    print("\n" + "=" * 70)
    print("Application 2: Expression Complexity Certification")
    print("=" * 70)

    exprs = [
        ("x + 1", Expr(NodeType.ADD, left=Expr(NodeType.VAR),
                        right=Expr(NodeType.CONST, value=1.0))),
        ("exp(x)", Expr(NodeType.EML, left=Expr(NodeType.CONST, value=1.0),
                        right=Expr(NodeType.VAR))),
        ("exp(exp(x))", Expr(NodeType.EML, left=Expr(NodeType.CONST, value=1.0),
                             right=Expr(NodeType.EML,
                                        left=Expr(NodeType.CONST, value=1.0),
                                        right=Expr(NodeType.VAR)))),
    ]

    for name, expr in exprs:
        report = certify_expression_complexity(expr)
        print(f"\n  {name}:")
        print(f"    EML depth: {report['eml_depth']}")
        print(f"    Size: {report['size']}")
        print(f"    Growth level bound: ≤ iterExp({report['growth_level_bound']}, Cx)")
        print(f"    Certified: {report['growth_bound_certified']}")

    # Application 3: Growth classification
    print("\n" + "=" * 70)
    print("Application 3: Growth Rate Classification")
    print("=" * 70)

    classify_growth_rate(lambda x: x**3, "x³")
    classify_growth_rate(lambda x: math.exp(x), "exp(x)")
    classify_growth_rate(lambda x: math.exp(math.exp(x)), "exp(exp(x))")
    classify_growth_rate(lambda x: iter_exp(3, x), "iterExp(3, x)")


#!/usr/bin/env python3
"""
EML Depth Separation — Interactive Demo

Demonstrates the depth separation theorem for EML expressions:
bounded-depth EML cannot represent high-level iterated exponentials.

Includes:
- Iterated exponential computation and visualization
- Depth-bounded EML expression enumeration and evaluation
- Growth bound verification
- Minimal size search for depth-bounded representations
"""

import math
import itertools
from typing import Optional, Callable, List, Tuple
from dataclasses import dataclass
from enum import Enum, auto


# ============================================================
# Expression Trees
# ============================================================

class ExprType(Enum):
    VAR = auto()
    CONST = auto()
    ADD = auto()
    MUL = auto()
    NEG = auto()
    EML = auto()  # eml(a,b) = a * exp(b)


@dataclass
class EMLExpr:
    """EML expression tree."""
    kind: ExprType
    value: Optional[float] = None  # for CONST
    left: Optional['EMLExpr'] = None
    right: Optional['EMLExpr'] = None

    def eval(self, x: float) -> float:
        """Evaluate the expression at x."""
        if self.kind == ExprType.VAR:
            return x
        elif self.kind == ExprType.CONST:
            return self.value
        elif self.kind == ExprType.ADD:
            return self.left.eval(x) + self.right.eval(x)
        elif self.kind == ExprType.MUL:
            return self.left.eval(x) * self.right.eval(x)
        elif self.kind == ExprType.NEG:
            return -self.left.eval(x)
        elif self.kind == ExprType.EML:
            a = self.left.eval(x)
            b = self.right.eval(x)
            try:
                return a * math.exp(b)
            except OverflowError:
                return float('inf')
        raise ValueError(f"Unknown kind: {self.kind}")

    @property
    def size(self) -> int:
        if self.kind in (ExprType.VAR, ExprType.CONST):
            return 1
        elif self.kind == ExprType.NEG:
            return 1 + self.left.size
        else:
            return 1 + self.left.size + self.right.size

    @property
    def eml_depth(self) -> int:
        if self.kind in (ExprType.VAR, ExprType.CONST):
            return 0
        elif self.kind == ExprType.NEG:
            return self.left.eml_depth
        elif self.kind in (ExprType.ADD, ExprType.MUL):
            return max(self.left.eml_depth, self.right.eml_depth)
        elif self.kind == ExprType.EML:
            return 1 + max(self.left.eml_depth, self.right.eml_depth)
        return 0

    def __repr__(self):
        if self.kind == ExprType.VAR:
            return "x"
        elif self.kind == ExprType.CONST:
            return f"{self.value}"
        elif self.kind == ExprType.ADD:
            return f"({self.left} + {self.right})"
        elif self.kind == ExprType.MUL:
            return f"({self.left} * {self.right})"
        elif self.kind == ExprType.NEG:
            return f"(-{self.left})"
        elif self.kind == ExprType.EML:
            return f"eml({self.left}, {self.right})"
        return "?"


# Constructors
def var():
    return EMLExpr(ExprType.VAR)

def const(c):
    return EMLExpr(ExprType.CONST, value=c)

def add(a, b):
    return EMLExpr(ExprType.ADD, left=a, right=b)

def mul(a, b):
    return EMLExpr(ExprType.MUL, left=a, right=b)

def neg(a):
    return EMLExpr(ExprType.NEG, left=a)

def eml(a, b):
    return EMLExpr(ExprType.EML, left=a, right=b)


# ============================================================
# Iterated Exponential
# ============================================================

def iter_exp(n: int, x: float) -> float:
    """Compute iterExp(n, x) = exp^(n)(x)."""
    result = x
    for _ in range(n):
        try:
            result = math.exp(result)
        except OverflowError:
            return float('inf')
    return result


def canonical_eml(n: int) -> EMLExpr:
    """Build the canonical EML expression for iterExp(n):
    eml(1, eml(1, ... eml(1, x)...)) with n layers."""
    if n == 0:
        return var()
    return eml(const(1.0), canonical_eml(n - 1))


# ============================================================
# Enumeration of depth-bounded EML expressions
# ============================================================

def enumerate_eml(max_size: int, max_depth: int,
                  constants: List[float] = [1.0]) -> List[EMLExpr]:
    """Enumerate EMLExpr trees up to given size and depth bounds."""
    cache = {}

    def gen(size_budget: int, depth_budget: int) -> List[EMLExpr]:
        key = (size_budget, depth_budget)
        if key in cache:
            return cache[key]
        if size_budget <= 0:
            cache[key] = []
            return []
        exprs = [var()]
        for c in constants:
            exprs.append(const(c))
        if size_budget >= 2:
            for sub in gen(size_budget - 1, depth_budget):
                exprs.append(neg(sub))
        if size_budget >= 3:
            for s1 in range(1, size_budget - 1):
                s2 = size_budget - 1 - s1
                left_exprs = gen(s1, depth_budget)
                right_exprs = gen(s2, depth_budget)
                for l in left_exprs[:10]:  # limit branching
                    for r in right_exprs[:10]:
                        exprs.append(add(l, r))
                        exprs.append(mul(l, r))
                        if depth_budget >= 1 and l.eml_depth < depth_budget and r.eml_depth < depth_budget:
                            exprs.append(eml(l, r))
        cache[key] = exprs
        return exprs

    return gen(max_size, max_depth)


# ============================================================
# Search and Verification
# ============================================================

def grid_matches(expr: EMLExpr, target_fn: Callable[[float], float],
                 grid: List[float], tol: float = 1e-10) -> bool:
    """Check if expr matches target_fn on all grid points."""
    for x in grid:
        try:
            val = expr.eval(x)
            tgt = target_fn(x)
            if abs(val) == float('inf') or abs(tgt) == float('inf'):
                if val != tgt:
                    return False
            elif abs(val - tgt) > tol * max(1, abs(tgt)):
                return False
        except (OverflowError, ValueError):
            return False
    return True


def search_eml(depth: int, max_size: int, grid: List[float],
               target_fn: Callable[[float], float]) -> Optional[EMLExpr]:
    """Search for an EMLExpr of given depth bound that matches target on grid."""
    for size in range(1, max_size + 1):
        candidates = enumerate_eml(size, depth)
        for expr in candidates:
            if expr.eml_depth <= depth and grid_matches(expr, target_fn, grid):
                return expr
    return None


# ============================================================
# Growth Bound Verification
# ============================================================

def verify_growth_bound(expr: EMLExpr, depth: int, grid: List[float]) -> dict:
    """Verify the growth bound |e.eval(x)| ≤ iterExp(D+1, C*x) for various C."""
    results = {}
    for C in [1.0, 2.0, 5.0, 10.0, 50.0]:
        violations = 0
        max_ratio = 0.0
        for x in grid:
            try:
                val = abs(expr.eval(x))
                bound = iter_exp(depth + 1, C * x)
                if bound == float('inf'):
                    continue
                if val > bound:
                    violations += 1
                if bound > 0:
                    max_ratio = max(max_ratio, val / bound)
            except (OverflowError, ValueError):
                continue
        results[C] = {'violations': violations, 'max_ratio': max_ratio}
    return results


# ============================================================
# Demo
# ============================================================

def demo_iterated_exponentials():
    """Demonstrate the iterated exponential growth hierarchy."""
    print("=" * 70)
    print("DEMO 1: Iterated Exponential Growth Hierarchy")
    print("=" * 70)
    print()
    print("iterExp(n, x) = exp^(n)(x)")
    print()

    x = 2.0
    print(f"At x = {x}:")
    for n in range(7):
        val = iter_exp(n, x)
        if val == float('inf'):
            print(f"  iterExp({n}, {x}) = OVERFLOW (> 10^308)")
        elif val > 1e15:
            print(f"  iterExp({n}, {x}) ≈ 10^{math.log10(val):.1f}")
        else:
            print(f"  iterExp({n}, {x}) = {val:.6g}")
    print()
    print("Observation: Each level grows astronomically faster than the previous.")
    print()


def demo_canonical_construction():
    """Demonstrate canonical EML representations."""
    print("=" * 70)
    print("DEMO 2: Canonical EML Representations")
    print("=" * 70)
    print()

    for n in range(5):
        expr = canonical_eml(n)
        print(f"  iterExp({n}): {expr}")
        print(f"    emlDepth = {expr.eml_depth}, size = {expr.size}")
        x = 1.0
        print(f"    eval({x}) = {expr.eval(x):.6g} vs iterExp({n},{x}) = {iter_exp(n, x):.6g}")
        print()


def demo_depth_separation():
    """Demonstrate the depth separation phenomenon."""
    print("=" * 70)
    print("DEMO 3: Depth Separation — Search for Bounded-Depth Representations")
    print("=" * 70)
    print()

    grid = [0.5, 1.0, 1.5, 2.0, 2.5]

    for D in range(4):
        print(f"Depth bound D = {D}:")
        for n in range(D + 4):
            target = lambda x, n=n: iter_exp(n, x)
            max_search_size = 7
            result = search_eml(D, max_search_size, grid, target)
            if result is not None:
                print(f"  iterExp({n}): FOUND at size {result.size} — {result}")
            else:
                if n <= D:
                    # Should be findable with larger size
                    print(f"  iterExp({n}): Not found up to size {max_search_size} (may need larger search)")
                else:
                    print(f"  iterExp({n}): NOT FOUND (consistent with separation theorem)")
        print()


def demo_growth_bounds():
    """Verify growth bounds computationally."""
    print("=" * 70)
    print("DEMO 4: Growth Bound Verification")
    print("=" * 70)
    print()

    grid = [float(i) for i in range(1, 20)]

    # Test some depth-1 expressions
    exprs = [
        ("eml(1, x) = exp(x)", eml(const(1.0), var()), 1),
        ("eml(x, x) = x·exp(x)", eml(var(), var()), 1),
        ("eml(1, eml(1, x)) = exp(exp(x))", eml(const(1.0), eml(const(1.0), var())), 2),
    ]

    for name, expr, depth in exprs:
        print(f"  Expression: {name}")
        print(f"  emlDepth = {expr.eml_depth}")
        results = verify_growth_bound(expr, depth, grid)
        for C, info in results.items():
            status = "✓" if info['violations'] == 0 else f"✗ ({info['violations']} violations)"
            print(f"    C={C:5.1f}: {status}, max ratio = {info['max_ratio']:.4f}")
        print()


def demo_minimal_size():
    """Search for minimal representations at different depths."""
    print("=" * 70)
    print("DEMO 5: Minimal Size vs Depth (Falsifiable Conjecture Test)")
    print("=" * 70)
    print()
    print("For each n, find minimal EMLExpr size at various depth bounds.")
    print("Conjecture: for fixed D, minimal size grows exponentially in n.")
    print()

    grid = [0.5, 1.0, 1.5, 2.0]
    max_size = 9

    print(f"{'n':>3} | {'D=1':>6} | {'D=2':>6} | {'D=3':>6} | {'D=4':>6}")
    print("-" * 40)

    for n in range(1, 5):
        target = lambda x, n=n: iter_exp(n, x)
        row = f"{n:>3} |"
        for D in range(1, 5):
            result = search_eml(D, max_size, grid, target)
            if result is not None:
                row += f" {result.size:>5} |"
            else:
                row += f"   >={max_size} |"
        print(row)

    print()
    print("Key: Values show minimal expression size found.")
    print("'>=' means no match found up to that size (separation may apply).")


if __name__ == "__main__":
    demo_iterated_exponentials()
    demo_canonical_construction()
    demo_depth_separation()
    demo_growth_bounds()
    demo_minimal_size()

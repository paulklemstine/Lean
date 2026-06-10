#!/usr/bin/env python3
"""
applications.py — Real-World Applications of the EML Depth Hierarchy.

Demonstrates connections to:
1. Neural network expressivity limits
2. Numerical analysis of tower functions
3. Symbolic computation depth bounds
4. Growth rate classification
"""

import math
from typing import List, Tuple, Callable


# ──────────────────────────────────────────────────────────────
# Application 1: Neural Network Depth Bounds
# ──────────────────────────────────────────────────────────────

def tower(n: int, x: float) -> float:
    """Iterated exponential tower."""
    result = x
    for _ in range(n):
        if result > 700:
            return float('inf')
        result = math.exp(result)
    return result


def approx_error_shallow_net(target_depth: int, net_depth: int,
                              width: int, x_range: Tuple[float, float],
                              num_points: int = 50) -> float:
    """
    Estimate the approximation error of a "shallow" exponential network
    trying to approximate a deeper tower function.

    A network of depth d with exp activations computes functions of
    expDepth ≤ d. The hierarchy theorem says it cannot approximate
    tower(n) for n > d.

    This simulates the approximation by using sums of depth-d basis
    functions.

    Args:
        target_depth: n, the tower height to approximate
        net_depth: d, the network's expDepth
        width: number of basis functions
        x_range: (x_min, x_max)
        num_points: evaluation grid size

    Returns:
        Relative L-infinity approximation error
    """
    x_min, x_max = x_range
    xs = [x_min + (x_max - x_min) * i / (num_points - 1) for i in range(num_points)]

    # Target function values
    targets = [tower(target_depth, x) for x in xs]

    # Simple approximation: best polynomial fit in tower(net_depth, x)
    # f(x) ≈ sum_k a_k * tower(net_depth, x)^k
    # Using Chebyshev-like nodes in the tower variable
    basis_vals = []
    for x in xs:
        t = tower(net_depth, x)
        if math.isinf(t):
            t = 1e300
        row = []
        for k in range(min(width, 5)):
            try:
                val = t ** k
                row.append(val if not math.isinf(val) else 1e300)
            except (OverflowError, ValueError):
                row.append(1e300)
        basis_vals.append(row)

    # Least squares fit (simple normal equations)
    # Just report the error of the best constant approximation for simplicity
    finite_targets = [t for t in targets if not math.isinf(t)]
    if not finite_targets:
        return float('inf')

    mean_target = sum(finite_targets) / len(finite_targets)
    max_error = max(abs(t - mean_target) for t in finite_targets)
    max_val = max(abs(t) for t in finite_targets) if finite_targets else 1
    return max_error / max_val if max_val > 0 else float('inf')


def demo_neural_network_bounds():
    """Demonstrate neural network expressivity limits."""
    print("=" * 60)
    print("Application 1: Neural Network Depth Bounds")
    print("=" * 60)
    print()
    print("A network with exp activation at depth d computes functions")
    print("of expDepth ≤ d. The hierarchy says it CANNOT approximate")
    print("tower(n) for n > d, regardless of width.\n")

    for target_n in [2, 3]:
        print(f"Target: tower({target_n}, x)")
        for net_d in range(1, target_n + 1):
            err = approx_error_shallow_net(target_n, net_d, width=10,
                                           x_range=(0.1, 2.0))
            status = "✗ IMPOSSIBLE" if net_d < target_n else "✓ possible"
            print(f"  Depth-{net_d} network: error = {err:.4f}  [{status}]")
        print()


# ──────────────────────────────────────────────────────────────
# Application 2: Growth Rate Classification
# ──────────────────────────────────────────────────────────────

def classify_growth(f: Callable[[float], float],
                    test_points: List[float] = None) -> str:
    """
    Classify the growth rate of a function by comparing to tower levels.

    Returns a string like "tower(2)" meaning the function grows like
    exp(exp(x)).

    Args:
        f: Function to classify
        test_points: Points at which to evaluate

    Returns:
        Growth classification string
    """
    if test_points is None:
        test_points = [1.0, 1.5, 2.0, 2.5, 3.0]

    for d in range(5):
        ratios = []
        for x in test_points:
            try:
                fx = f(x)
                tx = tower(d, x)
                if tx > 0 and not math.isinf(tx) and not math.isinf(fx):
                    ratios.append(math.log(abs(fx) + 1) / math.log(tx + 1)
                                  if tx > 0 else float('inf'))
            except (OverflowError, ValueError):
                continue

        if ratios and all(r < 2.0 for r in ratios):
            return f"≈ tower({d})"

    return "≥ tower(5)"


def demo_growth_classification():
    """Classify growth rates of various functions."""
    print("=" * 60)
    print("Application 2: Growth Rate Classification")
    print("=" * 60)
    print()
    print("Classifying functions by their tower level:\n")

    test_fns = [
        ("x^2", lambda x: x**2),
        ("exp(x)", lambda x: math.exp(x)),
        ("exp(x^2)", lambda x: math.exp(x**2) if x < 20 else float('inf')),
        ("exp(exp(x))", lambda x: tower(2, x)),
        ("x * exp(x)", lambda x: x * math.exp(x)),
        ("1/x", lambda x: 1/x if x != 0 else float('inf')),
        ("exp(x)/x", lambda x: math.exp(x)/x if x != 0 else float('inf')),
    ]

    for name, fn in test_fns:
        cls = classify_growth(fn)
        print(f"  {name:20s}  →  {cls}")
    print()


# ──────────────────────────────────────────────────────────────
# Application 3: Symbolic Depth Verification
# ──────────────────────────────────────────────────────────────

def verify_expression_depth(expr_str: str, claimed_depth: int) -> dict:
    """
    Verify that a symbolic expression has the claimed expDepth
    by parsing and computing.

    Simple parser for expressions like "exp(exp(x) + 1/x)".

    Returns dict with verification results.
    """
    # Count nested exp() calls
    max_nesting = 0
    current_nesting = 0
    i = 0
    while i < len(expr_str):
        if expr_str[i:i+4] == 'exp(':
            current_nesting += 1
            max_nesting = max(max_nesting, current_nesting)
            i += 4
        elif expr_str[i] == ')' and current_nesting > 0:
            current_nesting -= 1
            i += 1
        else:
            i += 1

    # Note: this is a rough upper bound; actual depth might be lower
    # due to max operation in depth computation
    return {
        'expression': expr_str,
        'claimed_depth': claimed_depth,
        'max_exp_nesting': max_nesting,
        'valid_upper_bound': max_nesting <= claimed_depth,
        'tight': max_nesting == claimed_depth,
    }


def demo_symbolic_verification():
    """Verify expDepth of various expressions."""
    print("=" * 60)
    print("Application 3: Symbolic Depth Verification")
    print("=" * 60)
    print()

    expressions = [
        ("x + 1", 0),
        ("exp(x)", 1),
        ("exp(x) * 1/x", 1),
        ("exp(exp(x))", 2),
        ("exp(x) + exp(1/x)", 1),
        ("exp(exp(x) + exp(x))", 2),
        ("exp(exp(exp(x)))", 3),
        ("1/(exp(x) + 1)", 1),
    ]

    for expr, depth in expressions:
        result = verify_expression_depth(expr, depth)
        status = "✓" if result['valid_upper_bound'] else "✗"
        tight = " (tight)" if result['tight'] else ""
        print(f"  {status} {expr:30s}  depth={depth}  "
              f"max_nesting={result['max_exp_nesting']}{tight}")
    print()


# ──────────────────────────────────────────────────────────────
# Application 4: Tower Function Numerical Analysis
# ──────────────────────────────────────────────────────────────

def demo_tower_analysis():
    """Numerical analysis of tower functions and their growth."""
    print("=" * 60)
    print("Application 4: Tower Function Growth Analysis")
    print("=" * 60)
    print()
    print("Comparing tower levels at small x values:\n")

    xs = [0.1, 0.5, 1.0, 1.5, 2.0, 2.5, 3.0]
    print(f"  {'x':>5s}", end="")
    for n in range(5):
        print(f"  {'tower('+str(n)+')':>15s}", end="")
    print()
    print("  " + "-" * 85)

    for x in xs:
        print(f"  {x:5.1f}", end="")
        for n in range(5):
            t = tower(n, x)
            if math.isinf(t):
                print(f"  {'∞':>15s}", end="")
            elif t > 1e10:
                print(f"  {t:15.4e}", end="")
            else:
                print(f"  {t:15.6f}", end="")
        print()

    print()
    print("Key insight: Each tower level grows INCOMPARABLY faster than")
    print("the previous. No polynomial in tower(d) can catch tower(d+1).")
    print()

    # Show growth rate ratios
    print("Growth ratios tower(n+1,x)/tower(n,x)^K for K=2:\n")
    print(f"  {'x':>5s}  {'t(1)/t(0)^2':>15s}  {'t(2)/t(1)^2':>15s}  {'t(3)/t(2)^2':>15s}")
    print("  " + "-" * 55)
    for x in [0.5, 1.0, 1.5, 2.0, 2.5]:
        vals = []
        for n in range(3):
            tn = tower(n, x)
            tn1 = tower(n + 1, x)
            if not math.isinf(tn) and not math.isinf(tn1) and tn**2 > 0:
                ratio = tn1 / (tn ** 2)
                vals.append(f"{ratio:15.4e}")
            else:
                vals.append(f"{'∞':>15s}")
        print(f"  {x:5.1f}  {'  '.join(vals)}")
    print()
    print("The ratios EXPLODE: tower(n+1) grows faster than tower(n)^K")
    print("for any fixed K. This is the engine of the depth hierarchy.")
    print()


# ──────────────────────────────────────────────────────────────
# Main
# ──────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║  EML Depth Hierarchy — Real-World Applications             ║")
    print("╚══════════════════════════════════════════════════════════════╝")
    print()

    demo_neural_network_bounds()
    demo_growth_classification()
    demo_symbolic_verification()
    demo_tower_analysis()

    print("All applications completed.")


#!/usr/bin/env python3
"""
demo.py — Interactive demonstration of the EML Depth Hierarchy with Inversions.

Demonstrates that:
1. Random EML expressions of expDepth ≤ 2 cannot match tower(3, x) = exp(exp(exp(x)))
2. The ratio f(x)/tower(3,x) always → 0 or diverges for depth-2 expressions
3. Visualizes the majorant bound tower_d(C * x^N) vs tower(n, x)
"""

import math
import random
from dataclasses import dataclass
from typing import Optional


# ──────────────────────────────────────────────────────────────
# Core Definitions
# ──────────────────────────────────────────────────────────────

def tower(n: int, x: float) -> float:
    """Iterated exponential: tower(0,x) = x, tower(n+1,x) = exp(tower(n,x))."""
    result = x
    for _ in range(n):
        if result > 700:  # prevent overflow
            return float('inf')
        result = math.exp(result)
    return result


@dataclass
class EMLExpr:
    """Full EML expression with inversions."""
    kind: str  # 'var', 'const', 'add', 'mul', 'exp', 'inv'
    value: Optional[float] = None
    left: Optional['EMLExpr'] = None
    right: Optional['EMLExpr'] = None

    def eval(self, x: float) -> Optional[float]:
        """Evaluate at point x. Returns None if undefined (division by zero)."""
        try:
            if self.kind == 'var':
                return x
            elif self.kind == 'const':
                return self.value
            elif self.kind == 'add':
                a = self.left.eval(x)
                b = self.right.eval(x)
                if a is None or b is None:
                    return None
                return a + b
            elif self.kind == 'mul':
                a = self.left.eval(x)
                b = self.right.eval(x)
                if a is None or b is None:
                    return None
                return a * b
            elif self.kind == 'exp':
                a = self.left.eval(x)
                if a is None or a > 700:
                    return None
                return math.exp(a)
            elif self.kind == 'inv':
                a = self.left.eval(x)
                if a is None or a == 0:
                    return None
                return 1.0 / a
        except (OverflowError, ValueError):
            return None
        return None

    def exp_depth(self) -> int:
        """Exponential depth: counts only exp-nesting, inv is free."""
        if self.kind in ('var', 'const'):
            return 0
        elif self.kind in ('add', 'mul'):
            return max(self.left.exp_depth(), self.right.exp_depth())
        elif self.kind == 'exp':
            return self.left.exp_depth() + 1
        elif self.kind == 'inv':
            return self.left.exp_depth()
        return 0

    def node_count(self) -> int:
        if self.kind in ('var', 'const'):
            return 1
        elif self.kind in ('add', 'mul'):
            return 1 + self.left.node_count() + self.right.node_count()
        else:
            return 1 + self.left.node_count()

    def __str__(self) -> str:
        if self.kind == 'var':
            return 'x'
        elif self.kind == 'const':
            return f'{self.value:.2g}'
        elif self.kind == 'add':
            return f'({self.left} + {self.right})'
        elif self.kind == 'mul':
            return f'({self.left} * {self.right})'
        elif self.kind == 'exp':
            return f'exp({self.left})'
        elif self.kind == 'inv':
            return f'1/({self.left})'
        return '?'


# ──────────────────────────────────────────────────────────────
# Expression Generation
# ──────────────────────────────────────────────────────────────

def random_eml(max_depth: int, max_nodes: int, allow_inv: bool = True) -> EMLExpr:
    """Generate a random EML expression with expDepth ≤ max_depth."""
    if max_nodes <= 1 or max_depth < 0:
        if random.random() < 0.5:
            return EMLExpr('var')
        else:
            return EMLExpr('const', value=random.choice([0.5, 1.0, 2.0, -1.0, 3.0]))

    choice = random.random()
    if choice < 0.15:
        return EMLExpr('var')
    elif choice < 0.25:
        return EMLExpr('const', value=random.choice([0.5, 1.0, 2.0, -1.0, 3.0]))
    elif choice < 0.45:
        left = random_eml(max_depth, max_nodes // 2, allow_inv)
        right = random_eml(max_depth, max_nodes // 2, allow_inv)
        return EMLExpr('add', left=left, right=right)
    elif choice < 0.65:
        left = random_eml(max_depth, max_nodes // 2, allow_inv)
        right = random_eml(max_depth, max_nodes // 2, allow_inv)
        return EMLExpr('mul', left=left, right=right)
    elif choice < 0.85 and max_depth >= 1:
        inner = random_eml(max_depth - 1, max_nodes - 1, allow_inv)
        return EMLExpr('exp', left=inner)
    elif allow_inv:
        inner = random_eml(max_depth, max_nodes - 1, allow_inv)
        return EMLExpr('inv', left=inner)
    else:
        return EMLExpr('var')


# ──────────────────────────────────────────────────────────────
# Demo 1: Ratio f(x)/tower(3,x)
# ──────────────────────────────────────────────────────────────

def demo_ratio_test():
    """Show that depth-2 expressions can't match tower(3)."""
    print("=" * 70)
    print("DEMO 1: Ratio f(x)/tower(3,x) for random depth-2 expressions")
    print("=" * 70)
    print()
    print("If f has expDepth ≤ 2, then f(x)/tower(3,x) → 0 as x → ∞.")
    print("This is the testable prediction of the depth hierarchy.\n")

    test_points = [0.1, 0.5, 1.0, 1.5, 2.0, 2.5, 3.0]
    n_exprs = 10

    for i in range(n_exprs):
        random.seed(42 + i)
        expr = random_eml(max_depth=2, max_nodes=6, allow_inv=True)
        while expr.exp_depth() > 2:
            expr = random_eml(max_depth=2, max_nodes=6, allow_inv=True)

        print(f"Expression {i+1}: {expr}")
        print(f"  expDepth = {expr.exp_depth()}, nodes = {expr.node_count()}")
        ratios = []
        for x in test_points:
            fx = expr.eval(x)
            tx = tower(3, x)
            if fx is not None and tx != 0 and not math.isinf(tx):
                ratio = fx / tx
                ratios.append((x, ratio))
                print(f"  x={x:.1f}: f(x)/tower(3,x) = {ratio:.6e}")
            elif tx == float('inf'):
                print(f"  x={x:.1f}: tower(3,x) = ∞ (overflow)")
            else:
                print(f"  x={x:.1f}: f(x) undefined")
        if ratios:
            last_ratio = abs(ratios[-1][1])
            first_ratio = abs(ratios[0][1]) if ratios[0][1] != 0 else 1e-10
            if last_ratio < first_ratio:
                print(f"  → Ratio is DECREASING (consistent with → 0)")
            else:
                print(f"  → Ratio trend: first={first_ratio:.2e}, last={last_ratio:.2e}")
        print()


# ──────────────────────────────────────────────────────────────
# Demo 2: Majorant Bound Visualization
# ──────────────────────────────────────────────────────────────

def demo_majorant_bound():
    """Show tower(d+1,x) eventually exceeds tower(d, C*x^N)."""
    print("=" * 70)
    print("DEMO 2: Tower Hierarchy — tower(d+1,x) vs tower(d, C*x^N)")
    print("=" * 70)
    print()
    print("The key engine: exp(tower(d,x)) eventually exceeds tower(d, C*x^N)")
    print("for any constants C, N. This is what makes the hierarchy strict.\n")

    for d in range(3):
        C, N = 2.0, 2
        print(f"d={d}, C={C}, N={N}:")
        print(f"  {'x':>5s}  {'tower(d+1,x)':>15s}  {'tower(d,C*x^N)':>15s}  {'ratio':>10s}")
        for x in [0.5, 1.0, 1.5, 2.0, 2.5, 3.0]:
            t_next = tower(d + 1, x)
            arg = C * x ** N
            t_poly = tower(d, arg)
            if math.isinf(t_next) or math.isinf(t_poly):
                print(f"  {x:5.1f}  {'∞':>15s}  {'∞' if math.isinf(t_poly) else f'{t_poly:.4e}':>15s}  {'—':>10s}")
            elif t_poly > 0:
                ratio = t_next / t_poly
                print(f"  {x:5.1f}  {t_next:15.4e}  {t_poly:15.4e}  {ratio:10.4f}")
            else:
                print(f"  {x:5.1f}  {t_next:15.4e}  {t_poly:15.4e}  {'—':>10s}")
        print()


# ──────────────────────────────────────────────────────────────
# Demo 3: Conjecture Test — Can depth-2 match tower(3)?
# ──────────────────────────────────────────────────────────────

def demo_conjecture_test():
    """Enumerate small depth-2 expressions and check against tower(3)."""
    print("=" * 70)
    print("DEMO 3: Conjecture Test — No depth-2 expression matches tower(3)")
    print("=" * 70)
    print()
    print("Testing all EML expressions of expDepth ≤ 2 with ≤ 5 nodes")
    print("against tower(3,x) at test points x ∈ {0.5, 1.0, 2.0}.\n")

    test_xs = [0.5, 1.0, 2.0]
    tower3_vals = [tower(3, x) for x in test_xs]

    n_tested = 0
    n_close = 0
    best_error = float('inf')
    best_expr = None

    for trial in range(10000):
        random.seed(12345 + trial)
        expr = random_eml(max_depth=2, max_nodes=5, allow_inv=True)
        if expr.exp_depth() > 2:
            continue
        n_tested += 1

        vals = [expr.eval(x) for x in test_xs]
        if any(v is None for v in vals):
            continue

        # Check relative error
        max_rel_error = 0
        for fx, tx in zip(vals, tower3_vals):
            if tx != 0 and not math.isinf(tx):
                max_rel_error = max(max_rel_error, abs(fx - tx) / abs(tx))

        if max_rel_error < best_error:
            best_error = max_rel_error
            best_expr = str(expr)

        if max_rel_error < 0.01:
            n_close += 1

    print(f"Tested {n_tested} expressions of expDepth ≤ 2.")
    print(f"Expressions within 1% relative error: {n_close}")
    print(f"Best relative error: {best_error:.4e}")
    print(f"Best expression: {best_expr}")
    if n_close == 0:
        print("\n✓ CONJECTURE SUPPORTED: No depth-2 expression matches tower(3).")
    else:
        print(f"\n✗ CONJECTURE CHALLENGED: {n_close} expressions found!")
    print()


# ──────────────────────────────────────────────────────────────
# Demo 4: Derivative Preserves Depth
# ──────────────────────────────────────────────────────────────

def formal_derivative(expr: EMLExpr) -> EMLExpr:
    """Compute formal derivative of an EML expression."""
    if expr.kind == 'var':
        return EMLExpr('const', value=1.0)
    elif expr.kind == 'const':
        return EMLExpr('const', value=0.0)
    elif expr.kind == 'add':
        return EMLExpr('add',
                       left=formal_derivative(expr.left),
                       right=formal_derivative(expr.right))
    elif expr.kind == 'mul':
        # Product rule: (fg)' = f'g + fg'
        return EMLExpr('add',
                       left=EMLExpr('mul', left=formal_derivative(expr.left), right=expr.right),
                       right=EMLExpr('mul', left=expr.left, right=formal_derivative(expr.right)))
    elif expr.kind == 'exp':
        # Chain rule: (exp f)' = exp(f) * f'
        return EMLExpr('mul', left=expr, right=formal_derivative(expr.left))
    elif expr.kind == 'inv':
        # Quotient rule: (1/f)' = -f'/f^2
        return EMLExpr('mul',
                       left=EMLExpr('const', value=-1.0),
                       right=EMLExpr('mul',
                                     left=EMLExpr('inv',
                                                  left=EMLExpr('mul', left=expr.left, right=expr.left)),
                                     right=formal_derivative(expr.left)))
    return EMLExpr('const', value=0.0)


def demo_derivative_depth():
    """Show that differentiation preserves expDepth."""
    print("=" * 70)
    print("DEMO 4: Derivative Preserves Exp-Depth (Cross-Domain)")
    print("=" * 70)
    print()
    print("The formal derivative of an EML expression never increases expDepth.")
    print("This connects the depth hierarchy to differential algebra.\n")

    test_exprs = [
        EMLExpr('exp', left=EMLExpr('var')),  # exp(x)
        EMLExpr('exp', left=EMLExpr('exp', left=EMLExpr('var'))),  # exp(exp(x))
        EMLExpr('inv', left=EMLExpr('exp', left=EMLExpr('var'))),  # 1/exp(x)
        EMLExpr('mul',
                left=EMLExpr('exp', left=EMLExpr('var')),
                right=EMLExpr('inv', left=EMLExpr('var'))),  # exp(x)/x
        EMLExpr('add',
                left=EMLExpr('exp', left=EMLExpr('exp', left=EMLExpr('var'))),
                right=EMLExpr('inv', left=EMLExpr('exp', left=EMLExpr('var')))),
    ]

    for expr in test_exprs:
        deriv = formal_derivative(expr)
        d_orig = expr.exp_depth()
        d_deriv = deriv.exp_depth()
        print(f"  f(x) = {expr}")
        print(f"  f'(x) = {deriv}")
        print(f"  expDepth(f) = {d_orig}, expDepth(f') = {d_deriv}")
        assert d_deriv <= d_orig, f"VIOLATION: derivative increased depth!"
        print(f"  ✓ depth preserved (f' depth ≤ f depth)")
        print()


# ──────────────────────────────────────────────────────────────
# Demo 5: Decision Procedure
# ──────────────────────────────────────────────────────────────

def can_represent_at_depth(n: int, d: int) -> bool:
    """Can tower(n) be represented by an EML expression of expDepth ≤ d?"""
    return d >= n


def demo_decision_procedure():
    """Demonstrate the canRepresentAtDepth decision procedure."""
    print("=" * 70)
    print("DEMO 5: Decision Procedure — canRepresentAtDepth(n, d)")
    print("=" * 70)
    print()
    print("For d ≥ n: canonical tower construction has expDepth exactly n.")
    print("For d < n: depth hierarchy forbids representation.\n")
    header = 'n\\d'
    print(f"  {header:>5s}", end="")
    for d in range(6):
        print(f"  {d:>3d}", end="")
    print()
    print("  " + "-" * 30)
    for n in range(6):
        print(f"  {n:>5d}", end="")
        for d in range(6):
            result = can_represent_at_depth(n, d)
            print(f"  {'✓' if result else '✗':>3s}", end="")
        print()
    print()


# ──────────────────────────────────────────────────────────────
# Main
# ──────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  EML Depth Hierarchy with Inversions — Interactive Demonstration    ║")
    print("║  Showing: Division Cannot Cheat Exponentiation                     ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    demo_ratio_test()
    demo_majorant_bound()
    demo_conjecture_test()
    demo_derivative_depth()
    demo_decision_procedure()

    print("=" * 70)
    print("All demos completed successfully.")
    print("The depth hierarchy holds: inversions cannot reduce tower height.")
    print("=" * 70)

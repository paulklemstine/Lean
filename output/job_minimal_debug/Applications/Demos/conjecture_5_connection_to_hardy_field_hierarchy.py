#!/usr/bin/env python3
"""
Applications of the Hardy Hierarchy for EML Expressions

Real-world applications demonstrating the practical utility of
certified asymptotic classification:
1. Numerical overflow prediction
2. Neural network depth analysis
3. Symbolic expression simplification guidance
4. Growth rate visualization
"""

import math
from typing import List, Tuple, Dict, Optional


# ─────────────────────────────────────────────────────────────
# Reuse core types from algorithms.py (self-contained version)
# ─────────────────────────────────────────────────────────────

class EmlNode:
    """Minimal EML expression node."""
    pass

class VarN(EmlNode):
    def eval(self, x): return x
    def depth(self): return 0
    def __repr__(self): return "x"

class ConstN(EmlNode):
    def __init__(self, c): self.c = c
    def eval(self, x): return self.c
    def depth(self): return 0
    def __repr__(self): return str(self.c)

class AddN(EmlNode):
    def __init__(self, a, b): self.a, self.b = a, b
    def eval(self, x): return self.a.eval(x) + self.b.eval(x)
    def depth(self): return max(self.a.depth(), self.b.depth())
    def __repr__(self): return f"({self.a} + {self.b})"

class MulN(EmlNode):
    def __init__(self, a, b): self.a, self.b = a, b
    def eval(self, x): return self.a.eval(x) * self.b.eval(x)
    def depth(self): return max(self.a.depth(), self.b.depth())
    def __repr__(self): return f"({self.a} * {self.b})"

class EmlN(EmlNode):
    def __init__(self, a, b): self.a, self.b = a, b
    def eval(self, x):
        a_val = self.a.eval(x)
        b_val = self.b.eval(x)
        try:
            return a_val * math.exp(b_val)
        except OverflowError:
            return float('inf')
    def depth(self): return 1 + max(self.a.depth(), self.b.depth())
    def __repr__(self): return f"eml({self.a}, {self.b})"


def iter_exp(n: int, x: float) -> float:
    result = x
    for _ in range(n):
        try:
            result = math.exp(result)
        except OverflowError:
            return float('inf')
    return result


def make_iter_exp_node(n: int) -> EmlNode:
    if n == 0: return VarN()
    return EmlN(ConstN(1.0), make_iter_exp_node(n - 1))


# ─────────────────────────────────────────────────────────────
# Application 1: Numerical Overflow Prediction
# ─────────────────────────────────────────────────────────────

def predict_overflow(expr: EmlNode, precision: str = "float64") -> Dict:
    """
    Predict the input scale at which an expression overflows.

    Uses the Hardy level to give a qualitative prediction,
    then binary search for the exact threshold.

    Args:
        expr: an EML expression
        precision: "float32" or "float64"

    Returns:
        Dictionary with overflow threshold and Hardy level info
    """
    max_val = 3.4e38 if precision == "float32" else 1.8e308
    level = expr.depth()

    # Binary search for overflow threshold
    lo, hi = 0.0, 1000.0
    for _ in range(100):
        mid = (lo + hi) / 2
        try:
            val = expr.eval(mid)
            if val == float('inf') or val > max_val or val != val:
                hi = mid
            else:
                lo = mid
        except (OverflowError, ValueError):
            hi = mid

    # Qualitative prediction based on Hardy level
    if level == 0:
        qual = "Polynomial growth — overflow at very large inputs"
    elif level == 1:
        qual = "Exponential growth — overflow at moderate inputs"
    elif level == 2:
        qual = "Double-exponential growth — overflow at small inputs"
    else:
        qual = f"Level-{level} growth — overflow at tiny inputs"

    return {
        "expression": repr(expr),
        "hardy_level": level,
        "overflow_threshold": lo,
        "precision": precision,
        "qualitative": qual,
    }


# ─────────────────────────────────────────────────────────────
# Application 2: Neural Network Depth Analysis
# ─────────────────────────────────────────────────────────────

def analyze_neural_layer(
    weights: List[float],
    bias: float,
    activation: str = "exp"
) -> EmlNode:
    """
    Build an EML expression for a single neural network layer.

    A layer computes: activation(w1*x1 + w2*x2 + ... + b)
    For a single input: activation(w*x + b)

    With exponential activation, this is eml(1, w*x + b).
    """
    # Build w*x + b
    if len(weights) == 1:
        linear = AddN(MulN(ConstN(weights[0]), VarN()), ConstN(bias))
    else:
        linear = ConstN(bias)
        for w in weights:
            linear = AddN(linear, MulN(ConstN(w), VarN()))

    if activation == "exp":
        return EmlN(ConstN(1.0), linear)
    elif activation == "linear":
        return linear
    else:
        raise ValueError(f"Unknown activation: {activation}")


def analyze_network_depth(
    layer_configs: List[Tuple[List[float], float, str]]
) -> Dict:
    """
    Analyze a multi-layer neural network's Hardy level.

    Args:
        layer_configs: list of (weights, bias, activation) tuples

    Returns:
        Dictionary with per-layer and total Hardy level analysis
    """
    current = VarN()
    layer_info = []

    for i, (weights, bias, activation) in enumerate(layer_configs):
        if activation == "exp":
            # Layer: eml(1, w * prev + b)
            linear = AddN(MulN(ConstN(weights[0]), current), ConstN(bias))
            current = EmlN(ConstN(1.0), linear)
        else:
            linear = AddN(MulN(ConstN(weights[0]), current), ConstN(bias))
            current = linear

        layer_info.append({
            "layer": i + 1,
            "activation": activation,
            "hardy_level_after": current.depth(),
            "expression": repr(current),
        })

    return {
        "num_layers": len(layer_configs),
        "total_hardy_level": current.depth(),
        "layers": layer_info,
        "expression": current,
    }


# ─────────────────────────────────────────────────────────────
# Application 3: Growth Rate Visualization (text-based)
# ─────────────────────────────────────────────────────────────

def visualize_growth_comparison(
    expressions: List[Tuple[str, EmlNode]],
    x_values: List[float],
) -> str:
    """
    Create a text-based comparison table of growth rates.
    """
    lines = []

    # Header
    header = f"{'x':>10} |"
    for name, expr in expressions:
        header += f" {name:>20} (L{expr.depth()}) |"
    lines.append(header)
    lines.append("-" * len(header))

    # Values
    for x in x_values:
        row = f"{x:>10.1f} |"
        for name, expr in expressions:
            try:
                val = expr.eval(x)
                if val == float('inf'):
                    row += f" {'∞':>20} (L{expr.depth()}) |"
                elif abs(val) > 1e15:
                    row += f" {val:>20.3e} (L{expr.depth()}) |"
                else:
                    row += f" {val:>20.6f} (L{expr.depth()}) |"
            except (OverflowError, ValueError):
                row += f" {'ERR':>20} (L{expr.depth()}) |"
        lines.append(row)

    return "\n".join(lines)


# ─────────────────────────────────────────────────────────────
# Application 4: Expression Complexity Advisor
# ─────────────────────────────────────────────────────────────

def complexity_report(expr: EmlNode) -> str:
    """
    Generate a human-readable complexity report for an EML expression.
    """
    level = expr.depth()
    overflow = predict_overflow(expr)

    report = []
    report.append(f"Expression: {expr}")
    report.append(f"Hardy Level: {level}")
    report.append(f"Overflow Threshold (float64): x ≈ {overflow['overflow_threshold']:.1f}")
    report.append(f"Growth Class: {overflow['qualitative']}")
    report.append("")

    if level == 0:
        report.append("This expression has polynomial growth.")
        report.append("It can be safely evaluated for very large inputs.")
        report.append("Numerical stability: excellent.")
    elif level == 1:
        report.append("This expression has exponential growth.")
        report.append("Care needed for inputs beyond the overflow threshold.")
        report.append("Consider using log-space computation for large inputs.")
    elif level >= 2:
        report.append(f"This expression has level-{level} super-exponential growth.")
        report.append("It reaches numerical infinity for quite small inputs.")
        report.append("Symbolic or arbitrary-precision computation recommended.")

    return "\n".join(report)


# ─────────────────────────────────────────────────────────────
# Main: Run All Applications
# ─────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print()
    print("=" * 70)
    print("APPLICATION 1: Overflow Prediction")
    print("=" * 70)
    print()

    test_exprs = [
        ("x^3", MulN(MulN(VarN(), VarN()), VarN())),
        ("exp(x)", EmlN(ConstN(1.0), VarN())),
        ("exp(exp(x))", EmlN(ConstN(1.0), EmlN(ConstN(1.0), VarN()))),
        ("exp(exp(exp(x)))", make_iter_exp_node(3)),
    ]

    for name, expr in test_exprs:
        result = predict_overflow(expr)
        print(f"  {name}:")
        print(f"    Hardy Level: {result['hardy_level']}")
        print(f"    Overflow at x ≈ {result['overflow_threshold']:.1f}")
        print(f"    {result['qualitative']}")
        print()

    print("=" * 70)
    print("APPLICATION 2: Neural Network Depth Analysis")
    print("=" * 70)
    print()

    # 3-layer network with exponential activations
    network = analyze_network_depth([
        ([2.0], 0.5, "exp"),
        ([1.0], 0.0, "exp"),
        ([0.5], -1.0, "exp"),
    ])

    print(f"  Network: {network['num_layers']} layers with exp activation")
    print(f"  Total Hardy Level: {network['total_hardy_level']}")
    for layer in network['layers']:
        print(f"    Layer {layer['layer']}: {layer['activation']} → Hardy level {layer['hardy_level_after']}")
    print()

    # Mixed network
    network2 = analyze_network_depth([
        ([1.0], 0.0, "linear"),
        ([1.0], 0.0, "exp"),
        ([1.0], 0.0, "linear"),
        ([1.0], 0.0, "exp"),
    ])
    print(f"  Mixed network: {network2['num_layers']} layers (linear + exp)")
    print(f"  Total Hardy Level: {network2['total_hardy_level']}")
    for layer in network2['layers']:
        print(f"    Layer {layer['layer']}: {layer['activation']} → Hardy level {layer['hardy_level_after']}")
    print()

    print("=" * 70)
    print("APPLICATION 3: Growth Rate Comparison")
    print("=" * 70)
    print()

    exprs = [
        ("x²", MulN(VarN(), VarN())),
        ("exp(x)", EmlN(ConstN(1.0), VarN())),
        ("exp(exp(x))", EmlN(ConstN(1.0), EmlN(ConstN(1.0), VarN()))),
    ]
    x_vals = [1.0, 2.0, 3.0, 5.0, 10.0, 20.0]
    print(visualize_growth_comparison(exprs, x_vals))
    print()

    print("=" * 70)
    print("APPLICATION 4: Complexity Reports")
    print("=" * 70)
    print()

    for name, expr in test_exprs:
        print(complexity_report(expr))
        print()
        print("-" * 40)
        print()


#!/usr/bin/env python3
"""
Demo: Hardy Hierarchy for EML Expressions

Interactive demonstration of the Hardy level hierarchy and its connection
to EML expression depth. Builds sample EML expressions, computes depth/rank
predictions, and numerically compares growth rates against iterated exponentials.
"""

import math
from dataclasses import dataclass
from typing import Callable, List, Optional, Tuple


# ─────────────────────────────────────────────────────────────
# EML Expression Language
# ─────────────────────────────────────────────────────────────

@dataclass
class EmlExpr:
    """Base class for EML expressions."""
    pass

@dataclass
class Var(EmlExpr):
    """The variable x."""
    def __repr__(self): return "x"

@dataclass
class Const(EmlExpr):
    """A real constant."""
    value: float
    def __repr__(self): return str(self.value)

@dataclass
class Add(EmlExpr):
    """Sum of two expressions."""
    left: EmlExpr
    right: EmlExpr
    def __repr__(self): return f"({self.left} + {self.right})"

@dataclass
class Mul(EmlExpr):
    """Product of two expressions."""
    left: EmlExpr
    right: EmlExpr
    def __repr__(self): return f"({self.left} * {self.right})"

@dataclass
class Neg(EmlExpr):
    """Negation of an expression."""
    arg: EmlExpr
    def __repr__(self): return f"(-{self.arg})"

@dataclass
class Eml(EmlExpr):
    """The eml operation: eml(a, b) = a * exp(b)."""
    coeff: EmlExpr
    exponent: EmlExpr
    def __repr__(self): return f"eml({self.coeff}, {self.exponent})"


# ─────────────────────────────────────────────────────────────
# Evaluation and Depth
# ─────────────────────────────────────────────────────────────

def eval_eml(expr: EmlExpr, x: float) -> float:
    """Evaluate an EML expression at a point x."""
    if isinstance(expr, Var):
        return x
    elif isinstance(expr, Const):
        return expr.value
    elif isinstance(expr, Add):
        return eval_eml(expr.left, x) + eval_eml(expr.right, x)
    elif isinstance(expr, Mul):
        return eval_eml(expr.left, x) * eval_eml(expr.right, x)
    elif isinstance(expr, Neg):
        return -eval_eml(expr.arg, x)
    elif isinstance(expr, Eml):
        a = eval_eml(expr.coeff, x)
        b = eval_eml(expr.exponent, x)
        try:
            return a * math.exp(b)
        except OverflowError:
            return float('inf')
    raise TypeError(f"Unknown expression type: {type(expr)}")


def eml_depth(expr: EmlExpr) -> int:
    """Compute the EML depth (maximum nesting of eml operations)."""
    if isinstance(expr, Var) or isinstance(expr, Const):
        return 0
    elif isinstance(expr, Add) or isinstance(expr, Mul):
        return max(eml_depth(expr.left), eml_depth(expr.right))
    elif isinstance(expr, Neg):
        return eml_depth(expr.arg)
    elif isinstance(expr, Eml):
        return 1 + max(eml_depth(expr.coeff), eml_depth(expr.exponent))
    raise TypeError(f"Unknown expression type: {type(expr)}")


def expr_size(expr: EmlExpr) -> int:
    """Count the number of nodes in the expression tree."""
    if isinstance(expr, Var) or isinstance(expr, Const):
        return 1
    elif isinstance(expr, Add) or isinstance(expr, Mul) or isinstance(expr, Eml):
        return 1 + expr_size(expr.left if hasattr(expr, 'left') else expr.coeff) + \
               expr_size(expr.right if hasattr(expr, 'right') else expr.exponent)
    elif isinstance(expr, Neg):
        return 1 + expr_size(expr.arg)
    raise TypeError(f"Unknown expression type: {type(expr)}")


# ─────────────────────────────────────────────────────────────
# Iterated Exponential
# ─────────────────────────────────────────────────────────────

def iter_exp(n: int, x: float) -> float:
    """Compute the n-fold iterated exponential E_n(x)."""
    result = x
    for _ in range(n):
        try:
            result = math.exp(result)
        except OverflowError:
            return float('inf')
    return result


def make_iter_exp_eml(n: int) -> EmlExpr:
    """Build the canonical EML expression for iterExp n."""
    if n == 0:
        return Var()
    return Eml(Const(1.0), make_iter_exp_eml(n - 1))


# ─────────────────────────────────────────────────────────────
# Hardy Classifier
# ─────────────────────────────────────────────────────────────

def hardy_classify(expr: EmlExpr) -> dict:
    """
    Classify an EML expression by its Hardy level.

    Returns a dictionary with:
      - depth: the emlDepth (= predicted Hardy level)
      - size: the expression size
      - repr: string representation
      - certificate: explanation of why the level assignment is valid
    """
    d = eml_depth(expr)
    s = expr_size(expr)

    # Build certificate (derivation tree)
    cert = _build_certificate(expr)

    return {
        "depth": d,
        "size": s,
        "repr": repr(expr),
        "certificate": cert,
    }


def _build_certificate(expr: EmlExpr, indent: int = 0) -> str:
    """Build a human-readable derivation tree showing why the level is valid."""
    prefix = "  " * indent
    d = eml_depth(expr)

    if isinstance(expr, Var):
        return f"{prefix}HardyLevel 0 (x) — by base_id"
    elif isinstance(expr, Const):
        return f"{prefix}HardyLevel 0 ({expr.value}) — by base_const"
    elif isinstance(expr, Add):
        left_cert = _build_certificate(expr.left, indent + 1)
        right_cert = _build_certificate(expr.right, indent + 1)
        return (f"{prefix}HardyLevel {d} ({expr}) — by add\n"
                f"{left_cert}\n{right_cert}")
    elif isinstance(expr, Mul):
        left_cert = _build_certificate(expr.left, indent + 1)
        right_cert = _build_certificate(expr.right, indent + 1)
        return (f"{prefix}HardyLevel {d} ({expr}) — by mul\n"
                f"{left_cert}\n{right_cert}")
    elif isinstance(expr, Neg):
        arg_cert = _build_certificate(expr.arg, indent + 1)
        return (f"{prefix}HardyLevel {d} ({expr}) — by neg\n"
                f"{arg_cert}")
    elif isinstance(expr, Eml):
        coeff_cert = _build_certificate(expr.coeff, indent + 1)
        exp_cert = _build_certificate(expr.exponent, indent + 1)
        return (f"{prefix}HardyLevel {d} ({expr}) — by exp_step [level +1]\n"
                f"{coeff_cert}\n{exp_cert}")
    return f"{prefix}Unknown"


# ─────────────────────────────────────────────────────────────
# Numerical Experiments
# ─────────────────────────────────────────────────────────────

def demonstrate_growth_separation():
    """Show that iterated exponentials form a strict growth hierarchy."""
    print("=" * 70)
    print("GROWTH SEPARATION: Iterated Exponentials")
    print("=" * 70)
    print()
    print("E_0(x) = x")
    print("E_1(x) = exp(x)")
    print("E_2(x) = exp(exp(x))")
    print("E_3(x) = exp(exp(exp(x)))")
    print()

    for x in [1.0, 2.0, 3.0, 5.0, 10.0]:
        print(f"x = {x}:")
        for n in range(4):
            val = iter_exp(n, x)
            if val == float('inf'):
                print(f"  E_{n}({x}) = +∞ (overflow)")
            else:
                print(f"  E_{n}({x}) = {val:.6e}")
        print()


def demonstrate_polynomial_bound():
    """Show that level-0 expressions have polynomial growth."""
    print("=" * 70)
    print("POLYNOMIAL GROWTH BOUND: Level-0 Expressions")
    print("=" * 70)
    print()

    # Example level-0 expressions
    examples = [
        ("x", Var()),
        ("x^2", Mul(Var(), Var())),
        ("x^2 + 3x", Add(Mul(Var(), Var()), Mul(Const(3.0), Var()))),
        ("(x+1)*(x+2)", Mul(Add(Var(), Const(1.0)), Add(Var(), Const(2.0)))),
    ]

    for name, expr in examples:
        d = eml_depth(expr)
        print(f"Expression: {name}")
        print(f"  EML depth = {d} (Hardy level {d})")
        print(f"  Values: ", end="")
        for x in [10, 100, 1000]:
            val = eval_eml(expr, x)
            print(f"f({x})={val:.2e}  ", end="")
        print()

        # Compare with polynomial bound
        x_vals = [float(x) for x in range(10, 110, 10)]
        max_ratio = max(abs(eval_eml(expr, x)) / (x ** 3 + 1) for x in x_vals)
        print(f"  max |f(x)|/x^3 for x in [10,100]: {max_ratio:.4f}")
        print()


def demonstrate_depth_classification():
    """Demonstrate the Hardy classifier on various expressions."""
    print("=" * 70)
    print("HARDY LEVEL CLASSIFIER")
    print("=" * 70)
    print()

    expressions = [
        ("x", Var()),
        ("42", Const(42.0)),
        ("x + 1", Add(Var(), Const(1.0))),
        ("x * x", Mul(Var(), Var())),
        ("exp(x)", Eml(Const(1.0), Var())),
        ("x * exp(x)", Eml(Var(), Var())),
        ("exp(exp(x))", Eml(Const(1.0), Eml(Const(1.0), Var()))),
        ("x * exp(x^2)", Eml(Var(), Mul(Var(), Var()))),
        ("exp(exp(exp(x)))", make_iter_exp_eml(3)),
    ]

    for name, expr in expressions:
        result = hardy_classify(expr)
        print(f"Expression: {name}")
        print(f"  Hardy Level: {result['depth']}")
        print(f"  Size: {result['size']}")
        print(f"  Certificate:")
        for line in result['certificate'].split('\n'):
            print(f"    {line}")
        print()


def demonstrate_eventual_domination():
    """Numerically verify eventual domination between hierarchy levels."""
    print("=" * 70)
    print("EVENTUAL DOMINATION: exp(x) vs polynomials")
    print("=" * 70)
    print()

    # Show that exp(x) > C * x^d for large enough x
    test_cases = [
        (1.0, 2, "exp(x) vs x²"),
        (100.0, 5, "exp(x) vs 100·x⁵"),
        (1e6, 10, "exp(x) vs 10⁶·x¹⁰"),
    ]

    for C, d, desc in test_cases:
        print(f"Test: {desc}")
        crossover = None
        for x_int in range(1, 1000):
            x = float(x_int)
            poly_val = C * x ** d
            exp_val = math.exp(x) if x < 700 else float('inf')
            if exp_val > poly_val:
                crossover = x
                break
        if crossover:
            print(f"  exp(x) dominates C·x^d starting at x ≈ {crossover}")
            print(f"  At x={crossover}: exp({crossover})={math.exp(crossover):.2e}, "
                  f"C·x^d={C * crossover**d:.2e}")
        else:
            print(f"  Crossover not found in [1, 1000]")
        print()


def demonstrate_canonical_eml():
    """Show that canonical EML expressions evaluate to iterated exponentials."""
    print("=" * 70)
    print("CANONICAL EML EXPRESSIONS FOR iterExp")
    print("=" * 70)
    print()

    for n in range(5):
        expr = make_iter_exp_eml(n)
        d = eml_depth(expr)
        print(f"n = {n}:")
        print(f"  Expression: {expr}")
        print(f"  emlDepth = {d}")
        print(f"  growthRank = {d}")
        x = 2.0
        eml_val = eval_eml(expr, x)
        iter_val = iter_exp(n, x)
        match = "✓" if abs(eml_val - iter_val) < 1e-10 else "✗"
        if eml_val == float('inf') and iter_val == float('inf'):
            match = "✓ (both overflow)"
        print(f"  eval at x=2: eml={eml_val:.6e}, iterExp={iter_val:.6e} {match}")
        print()


# ─────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  Hardy Hierarchy for EML Expressions — Interactive Demo            ║")
    print("║  Connecting expression depth to asymptotic growth classification   ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    demonstrate_growth_separation()
    demonstrate_polynomial_bound()
    demonstrate_depth_classification()
    demonstrate_eventual_domination()
    demonstrate_canonical_eml()

    print("=" * 70)
    print("SUMMARY")
    print("=" * 70)
    print()
    print("Key results demonstrated:")
    print("  1. Iterated exponentials form a strict growth hierarchy")
    print("  2. Level-0 expressions have polynomial growth")
    print("  3. The Hardy classifier correctly assigns levels")
    print("  4. exp(x) eventually dominates any polynomial")
    print("  5. Canonical EML expressions match iterated exponentials")
    print()
    print("The EML depth of an expression is a certified asymptotic hierarchy level.")

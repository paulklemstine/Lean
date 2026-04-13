#!/usr/bin/env python3
"""
EML Explorer: Interactive Demonstration of the EML Operator

The EML (Exp-Minus-Log) operator eml(x,y) = exp(x) - ln(y) is a single binary
operator that generates all elementary functions from the constant 1.

This demo shows:
1. Basic EML evaluation and identity verification
2. Bootstrapping: building constants from 1
3. Building elementary functions (exp, ln, +, -, *, /)
4. EML tree visualization and complexity analysis
5. Symbolic regression via EML trees
"""

import cmath
import math
from dataclasses import dataclass
from typing import Optional, Callable
import json

# ============================================================
# 1. Core EML Operator
# ============================================================

def eml(x: complex, y: complex) -> complex:
    """The EML operator: eml(x, y) = exp(x) - ln(y)."""
    return cmath.exp(x) - cmath.log(y)

def eml_real(x: float, y: float) -> float:
    """Real-valued EML for positive y."""
    return math.exp(x) - math.log(y)

def edl(x: complex, y: complex) -> complex:
    """The EDL variant: edl(x, y) = exp(x) / ln(y)."""
    return cmath.exp(x) / cmath.log(y)

def anti_eml(x: complex, y: complex) -> complex:
    """The anti-EML: anti_eml(x, y) = ln(x) - exp(y)."""
    return cmath.log(x) - cmath.exp(y)


# ============================================================
# 2. EML Expression Trees
# ============================================================

@dataclass
class EMLTree:
    """An EML expression tree node."""
    kind: str  # 'const', 'var', 'eml'
    value: Optional[complex] = None
    name: Optional[str] = None
    left: Optional['EMLTree'] = None
    right: Optional['EMLTree'] = None

    def eval(self, variables: dict = None) -> complex:
        """Evaluate the EML tree."""
        if variables is None:
            variables = {}
        if self.kind == 'const':
            return self.value
        elif self.kind == 'var':
            return variables.get(self.name, 0)
        elif self.kind == 'eml':
            l = self.left.eval(variables)
            r = self.right.eval(variables)
            return eml(l, r)
        raise ValueError(f"Unknown kind: {self.kind}")

    def depth(self) -> int:
        if self.kind in ('const', 'var'):
            return 0
        return 1 + max(self.left.depth(), self.right.depth())

    def leaf_count(self) -> int:
        if self.kind in ('const', 'var'):
            return 1
        return self.left.leaf_count() + self.right.leaf_count()

    def node_count(self) -> int:
        if self.kind in ('const', 'var'):
            return 0
        return 1 + self.left.node_count() + self.right.node_count()

    def __repr__(self):
        if self.kind == 'const':
            return f"{self.value}"
        elif self.kind == 'var':
            return self.name
        return f"eml({self.left}, {self.right})"

# Shorthand constructors
ONE = EMLTree('const', value=1)
def VAR(name='x'):
    return EMLTree('var', name=name)
def EML(left, right):
    return EMLTree('eml', left=left, right=right)


# ============================================================
# 3. Bootstrapping: Building Constants from 1
# ============================================================

def demo_bootstrapping():
    """Show how constants are built from 1 using eml."""
    print("=" * 60)
    print("BOOTSTRAPPING: Building Constants from 1")
    print("=" * 60)

    # e = eml(1, 1) = exp(1) - ln(1) = e - 0 = e
    e_tree = EML(ONE, ONE)
    e_val = e_tree.eval()
    print(f"\ne = eml(1, 1) = {e_val.real:.10f}")
    print(f"  (actual e  = {math.e:.10f})")

    # e^e = eml(e, 1) = exp(e)
    ee_tree = EML(e_tree, ONE)
    ee_val = ee_tree.eval()
    print(f"\nexp(e) = eml(eml(1,1), 1) = {ee_val.real:.10f}")
    print(f"  (actual    = {math.exp(math.e):.10f})")

    # e - 1 = eml(1, e) = exp(1) - ln(e) = e - 1
    em1_tree = EML(ONE, e_tree)
    em1_val = em1_tree.eval()
    print(f"\ne - 1 = eml(1, eml(1,1)) = {em1_val.real:.10f}")
    print(f"  (actual    = {math.e - 1:.10f})")

    # exp(e-1) = eml(e-1, 1)
    exp_em1 = EML(em1_tree, ONE)
    print(f"\nexp(e-1) = eml(eml(1,eml(1,1)), 1) = {exp_em1.eval().real:.10f}")
    print(f"  (actual    = {math.exp(math.e - 1):.10f})")

    # More complex: e^(e^e) = eml(eml(eml(1,1),1), 1)
    eee_tree = EML(ee_tree, ONE)
    print(f"\nexp(exp(e)) = {eee_tree.eval().real:.6e}")
    print(f"  (actual    = {math.exp(math.exp(math.e)):.6e})")

    print(f"\nBootstrap chain depths:")
    print(f"  e:        depth={e_tree.depth()}, leaves={e_tree.leaf_count()}")
    print(f"  exp(e):   depth={ee_tree.depth()}, leaves={ee_tree.leaf_count()}")
    print(f"  e-1:      depth={em1_tree.depth()}, leaves={em1_tree.leaf_count()}")

    return e_tree


# ============================================================
# 4. Building Elementary Functions
# ============================================================

def demo_elementary_functions():
    """Show how elementary functions are recovered from eml."""
    print("\n" + "=" * 60)
    print("RECOVERING ELEMENTARY FUNCTIONS")
    print("=" * 60)

    x = VAR('x')

    # exp(x) = eml(x, 1)
    exp_tree = EML(x, ONE)
    test_val = 2.0
    print(f"\nexp(x) = eml(x, 1)")
    print(f"  exp({test_val}) = {exp_tree.eval({'x': test_val}).real:.10f}")
    print(f"  actual     = {math.exp(test_val):.10f}")

    # Subtraction: a - b = eml(ln(a), exp(b))
    # For a > 0: eml(ln(a), exp(b)) = exp(ln(a)) - ln(exp(b)) = a - b
    a, b = 5.0, 3.0
    sub_result = eml(cmath.log(a), cmath.exp(b))
    print(f"\na - b = eml(ln(a), exp(b))")
    print(f"  {a} - {b} = {sub_result.real:.10f}")
    print(f"  actual = {a - b:.10f}")

    # Addition: a + b = eml(ln(a), exp(-b))
    add_result = eml(cmath.log(a), cmath.exp(-b))
    print(f"\na + b = eml(ln(a), exp(-b))")
    print(f"  {a} + {b} = {add_result.real:.10f}")
    print(f"  actual = {a + b:.10f}")

    # Multiplication via exp-log: a * b = exp(ln(a) + ln(b))
    mul_via_log = cmath.exp(cmath.log(a) + cmath.log(b))
    print(f"\na * b = exp(ln(a) + ln(b))")
    print(f"  {a} * {b} = {mul_via_log.real:.10f}")
    print(f"  actual = {a * b:.10f}")

    # Division: a / b = exp(ln(a) - ln(b))
    div_via_log = cmath.exp(cmath.log(a) - cmath.log(b))
    print(f"\na / b = exp(ln(a) - ln(b))")
    print(f"  {a} / {b} = {div_via_log.real:.10f}")
    print(f"  actual = {a / b:.10f}")

    # sin and cos via Euler's formula (requires complex intermediate values!)
    # sin(x) = Im(exp(ix)) = Im(eml(ix, 1))
    theta = 1.0
    exp_itheta = eml(1j * theta, 1)
    sin_val = exp_itheta.imag
    cos_val = exp_itheta.real
    print(f"\nsin(x) via Euler: Im(eml(ix, 1))")
    print(f"  sin({theta}) = {sin_val:.10f}")
    print(f"  actual   = {math.sin(theta):.10f}")
    print(f"  cos({theta}) = {cos_val:.10f}")
    print(f"  actual   = {math.cos(theta):.10f}")

    # iπ = ln(-1), needed to access trig functions
    i_pi = cmath.log(-1)
    print(f"\niπ = ln(-1) = {i_pi}")
    print(f"  (complex intermediate values are essential for trig!)")


# ============================================================
# 5. Verifying Key Identities
# ============================================================

def demo_identities():
    """Verify the key algebraic identities of EML."""
    print("\n" + "=" * 60)
    print("VERIFYING EML IDENTITIES")
    print("=" * 60)

    # Identity 1: eml(x, 1) = exp(x)
    for x in [0, 1, 2, -1, 1+2j]:
        lhs = eml(x, 1)
        rhs = cmath.exp(x)
        err = abs(lhs - rhs)
        print(f"  eml({x}, 1) = exp({x}): error = {err:.2e}")

    print()

    # Identity 2: antiEml(x, y) = -eml(y, x)
    pairs = [(1, 2), (3+1j, 2-1j), (0.5, 0.5)]
    for x, y in pairs:
        lhs = anti_eml(x, y)
        rhs = -eml(y, x)
        err = abs(lhs - rhs)
        print(f"  antiEml({x}, {y}) = -eml({y}, {x}): error = {err:.2e}")

    print()

    # Identity 3: eml(ln(a), exp(b)) = a - b for a ≠ 0
    for a, b in [(5, 3), (1, 1), (10, 7)]:
        lhs = eml(cmath.log(a), cmath.exp(b))
        rhs = a - b
        err = abs(lhs - rhs)
        print(f"  eml(ln({a}), exp({b})) = {a}-{b}: error = {err:.2e}")

    print()

    # Identity 4: Non-commutativity
    print(f"  eml(0, 1) = {eml(0, 1)}")
    print(f"  eml(1, 2) = {eml(1, 2)}")
    print(f"  eml(2, 1) = {eml(2, 1)}")
    print(f"  Non-commutative: eml(1,2) ≠ eml(2,1) ✓")


# ============================================================
# 6. EML Complexity Analysis
# ============================================================

def demo_complexity():
    """Analyze EML tree complexity for various functions."""
    print("\n" + "=" * 60)
    print("EML COMPLEXITY ANALYSIS")
    print("=" * 60)

    # Catalan numbers (closed form)
    def catalan(n):
        from math import comb
        return comb(2*n, n) // (n + 1)

    print("\nCatalan numbers (# of tree topologies with n internal nodes):")
    for n in range(8):
        c = catalan(n)
        labeled = c * 2**(n+1)  # 2 terminals: {1, x}
        print(f"  C({n}) = {c:>5}  |  Labeled trees (k=2): {labeled:>6}")

    print("\nKnown EML complexities (leaf counts):")
    complexities = [
        ("id(x) = x",        1, "var x"),
        ("1",                 1, "const 1"),
        ("exp(x)",            2, "eml(x, 1)"),
        ("e",                 2, "eml(1, 1)"),
        ("e - 1",             3, "eml(1, eml(1, 1))"),
        ("exp(e)",            3, "eml(eml(1,1), 1)"),
        ("exp(exp(x))",       3, "eml(eml(x,1), 1)"),
        ("multiplication",   17, "upper bound from paper"),
        ("π",                53, "optimized upper bound"),
    ]
    for name, leaves, expr in complexities:
        print(f"  {name:20s}: ≤ {leaves:3d} leaves  [{expr}]")

    # Master formula parameter counts
    print("\nMaster formula parameter counts by depth:")
    for n in range(1, 6):
        params = 5 * 2**n - 6
        leaves = 2**n
        topo = catalan(leaves - 1)
        print(f"  Depth {n}: {params:>6} parameters, {leaves:>4} leaves, "
              f"{topo:>10} topologies")


# ============================================================
# 7. The Two-Button Calculator
# ============================================================

class TwoButtonCalculator:
    """A calculator with only two buttons: PUSH_1 and EML.

    Stack-based: PUSH_1 pushes the constant 1.
    EML pops two values and pushes eml(top, second).
    """

    def __init__(self):
        self.stack = []
        self.history = []

    def push_one(self):
        """Push the constant 1 onto the stack."""
        self.stack.append(complex(1))
        self.history.append("PUSH_1")

    def push_x(self, x: complex):
        """Push a variable value (for function evaluation)."""
        self.stack.append(x)
        self.history.append(f"PUSH_x({x})")

    def apply_eml(self):
        """Pop two values and push eml(top, second)."""
        if len(self.stack) < 2:
            raise ValueError("Stack underflow: need 2 values for EML")
        y = self.stack.pop()  # second argument
        x = self.stack.pop()  # first argument
        result = eml(x, y)
        self.stack.append(result)
        self.history.append("EML")

    def peek(self) -> complex:
        """Look at the top of the stack."""
        return self.stack[-1]

    def __repr__(self):
        return f"Stack: {self.stack}\nHistory: {' '.join(self.history)}"


def demo_two_button_calculator():
    """Demonstrate the two-button calculator."""
    print("\n" + "=" * 60)
    print("TWO-BUTTON CALCULATOR DEMO")
    print("=" * 60)

    # Compute e
    calc = TwoButtonCalculator()
    calc.push_one()
    calc.push_one()
    calc.apply_eml()
    print(f"\nCompute e:")
    print(f"  Program: PUSH_1, PUSH_1, EML")
    print(f"  Result: {calc.peek().real:.10f}")
    print(f"  Expected: {math.e:.10f}")

    # Compute exp(e) = e^e
    calc2 = TwoButtonCalculator()
    calc2.push_one()
    calc2.push_one()
    calc2.apply_eml()  # stack: [e]
    calc2.push_one()
    calc2.apply_eml()  # stack: [exp(e)]
    print(f"\nCompute exp(e):")
    print(f"  Program: PUSH_1, PUSH_1, EML, PUSH_1, EML")
    print(f"  Result: {calc2.peek().real:.10f}")
    print(f"  Expected: {math.exp(math.e):.10f}")

    # Compute exp(x) for x = 2
    calc3 = TwoButtonCalculator()
    calc3.push_x(2.0)
    calc3.push_one()
    calc3.apply_eml()
    print(f"\nCompute exp(2):")
    print(f"  Program: PUSH_x(2), PUSH_1, EML")
    print(f"  Result: {calc3.peek().real:.10f}")
    print(f"  Expected: {math.exp(2):.10f}")


# ============================================================
# 8. EML Symbolic Regression (Simple)
# ============================================================

def demo_symbolic_regression():
    """Simple EML symbolic regression at depth 1."""
    print("\n" + "=" * 60)
    print("EML SYMBOLIC REGRESSION (Depth 1)")
    print("=" * 60)

    # All depth-1 EML trees over {1, x}, evaluated at x=2
    print("\nAll depth-1 EML trees over {1, x} at x=2:")
    tree_evals = [
        ("eml(1,1)", eml(1, 1)),
        ("eml(1,x)", eml(1, 2)),
        ("eml(x,1)", eml(2, 1)),
        ("eml(x,x)", eml(2, 2)),
    ]
    for name, val in tree_evals:
        print(f"  {name:15s} = {val.real:12.6f} + {val.imag:12.6f}i")

    # Target matching
    print("\nTarget matching at x=2:")
    targets = {
        'exp(x)': cmath.exp(2),
        'exp(1)=e': cmath.exp(1),
        'x²': 4,
        'x+1': 3,
        '2x': 4,
        'ln(x)': cmath.log(2),
    }

    print(f"  {'Target':15s} {'Value':>15s} {'Best match':15s} {'Error':>12s}")
    for name, target in targets.items():
        best_tree = None
        best_err = float('inf')

        for t, tv in [('1', 1), ('x', 2)]:
            err = abs(complex(tv) - target)
            if err < best_err:
                best_err = err
                best_tree = t

        for tree_name, val in tree_evals:
            err = abs(val - target)
            if err < best_err:
                best_err = err
                best_tree = tree_name

        print(f"  {name:15s} {target.real:15.6f} {best_tree:15s} {best_err:12.2e}")


# ============================================================
# 9. EML Family Classification
# ============================================================

def demo_classification():
    """Explore the family of EML-like operators."""
    print("\n" + "=" * 60)
    print("EML FAMILY CLASSIFICATION")
    print("=" * 60)

    # The general family: f(exp(x), log(y))
    operators = {
        'EML':      lambda x, y: cmath.exp(x) - cmath.log(y),
        'EDL':      lambda x, y: cmath.exp(x) / cmath.log(y),
        'anti-EML': lambda x, y: cmath.log(x) - cmath.exp(y),
        'EAL':      lambda x, y: cmath.exp(x) + cmath.log(y),
        'EML*':     lambda x, y: cmath.exp(x) * cmath.log(y),
    }

    print("\nOperator evaluations at (x=1, y=e):")
    x, y = 1, math.e
    for name, op in operators.items():
        try:
            val = op(x, y)
            print(f"  {name:10s}(1, e) = {val.real:12.6f} + {val.imag:12.6f}i")
        except Exception as e:
            print(f"  {name:10s}(1, e) = ERROR: {e}")

    # The affine family: a*exp(x) + b*log(y) + c
    print("\nAffine EML family: a·exp(x) + b·log(y) + c")
    print("  Standard EML:  a=1, b=-1, c=0")
    print("  Anti-EML swap: a=-1, b=1, c=0 (with args swapped)")
    print("  Additive EML:  a=1, b=1, c=0")

    # Check which recover exp(x) from F(x, 1) where log(1) = 0
    print("\nRecovering exp from F(x, 1) = a·exp(x) + c:")
    print("  For a=1, c=0: F(x,1) = exp(x) ✓")
    print("  For a=1, c=1: F(x,1) = exp(x) + 1 (shifted)")
    print("  For a=-1, c=0: F(x,1) = -exp(x) (negated)")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║        EML EXPLORER: The Continuous Sheffer Stroke      ║")
    print("║        eml(x, y) = exp(x) - ln(y)                      ║")
    print("╚══════════════════════════════════════════════════════════╝")

    demo_bootstrapping()
    demo_elementary_functions()
    demo_identities()
    demo_complexity()
    demo_two_button_calculator()
    demo_symbolic_regression()
    demo_classification()

    print("\n" + "=" * 60)
    print("All demos completed successfully!")
    print("=" * 60)

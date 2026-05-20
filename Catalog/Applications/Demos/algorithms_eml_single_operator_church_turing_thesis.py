#!/usr/bin/env python3
"""
EML Single Operator Universality — Algorithms

Implements the core algorithms from the research paper:
1. EML compilation: translating exp/log expressions to eml-only form
2. Size analysis of compiled expressions
3. Derivative computation in the EML algebra
4. Representability checker for elementary grammars

All algorithms correspond to formally verified theorems in Lean 4.
"""

import math
from typing import Optional, List, Tuple, Dict, Callable
from dataclasses import dataclass, field
from enum import Enum, auto
import random


# ============================================================
# §1. Expression Types
# ============================================================

class NodeType(Enum):
    """Node types for expression trees."""
    CONST = "const"
    VAR = "var"
    ADD = "add"
    MUL = "mul"
    NEG = "neg"
    INV = "inv"
    EXP = "exp"
    LOG = "log"
    EML = "eml"  # eml(x, y) = exp(x) - log(y)


@dataclass
class Node:
    """Expression tree node with evaluation and compilation."""
    kind: NodeType
    value: Optional[float] = None
    var_idx: Optional[int] = None
    children: List['Node'] = field(default_factory=list)

    @staticmethod
    def const(v: float) -> 'Node':
        return Node(NodeType.CONST, value=v)

    @staticmethod
    def var(i: int = 0) -> 'Node':
        return Node(NodeType.VAR, var_idx=i)

    @staticmethod
    def add(a: 'Node', b: 'Node') -> 'Node':
        return Node(NodeType.ADD, children=[a, b])

    @staticmethod
    def mul(a: 'Node', b: 'Node') -> 'Node':
        return Node(NodeType.MUL, children=[a, b])

    @staticmethod
    def neg(a: 'Node') -> 'Node':
        return Node(NodeType.NEG, children=[a])

    @staticmethod
    def inv(a: 'Node') -> 'Node':
        return Node(NodeType.INV, children=[a])

    @staticmethod
    def exp(a: 'Node') -> 'Node':
        return Node(NodeType.EXP, children=[a])

    @staticmethod
    def log(a: 'Node') -> 'Node':
        return Node(NodeType.LOG, children=[a])

    @staticmethod
    def eml(a: 'Node', b: 'Node') -> 'Node':
        """eml(a, b) = exp(a) - log(b)"""
        return Node(NodeType.EML, children=[a, b])

    def size(self) -> int:
        """Count nodes in the expression tree.

        Time complexity: O(n) where n is the tree size.
        Space complexity: O(d) stack depth where d is tree depth.
        """
        return 1 + sum(c.size() for c in self.children)

    def depth(self) -> int:
        """Maximum depth of the expression tree."""
        if not self.children:
            return 0
        return 1 + max(c.depth() for c in self.children)

    def eval(self, env: Dict[int, float]) -> float:
        """Evaluate the expression tree in the given environment.

        Args:
            env: Mapping from variable indices to values.

        Returns:
            The computed real value.

        Time complexity: O(n) where n is the tree size.
        """
        if self.kind == NodeType.CONST:
            return self.value
        elif self.kind == NodeType.VAR:
            return env.get(self.var_idx, 0.0)
        elif self.kind == NodeType.ADD:
            return self.children[0].eval(env) + self.children[1].eval(env)
        elif self.kind == NodeType.MUL:
            return self.children[0].eval(env) * self.children[1].eval(env)
        elif self.kind == NodeType.NEG:
            return -self.children[0].eval(env)
        elif self.kind == NodeType.INV:
            v = self.children[0].eval(env)
            return 1.0 / v if v != 0 else float('inf')
        elif self.kind == NodeType.EXP:
            return math.exp(self.children[0].eval(env))
        elif self.kind == NodeType.LOG:
            v = self.children[0].eval(env)
            return math.log(v) if v > 0 else 0.0  # Match Lean's total log
        elif self.kind == NodeType.EML:
            a = self.children[0].eval(env)
            b = self.children[1].eval(env)
            log_b = math.log(b) if b > 0 else 0.0
            return math.exp(a) - log_b
        raise ValueError(f"Unknown node type: {self.kind}")


# ============================================================
# §2. EML Compilation Algorithm
# ============================================================

def compile_to_eml_only(expr: Node) -> Node:
    """
    Compile an expression tree with separate exp/log nodes into
    an equivalent tree using only the eml primitive for transcendentals.

    Algorithm (structural recursion on the expression tree):
    - Leaves (const, var): unchanged
    - Binary ops (add, mul): recurse on children
    - Unary ops (neg, inv): recurse on child
    - exp(e) → eml(compile(e), const(1))
        Correctness: eml(e', 1) = exp(e') - log(1) = exp(e') - 0 = exp(e')
    - log(e) → add(const(1), neg(eml(const(0), compile(e))))
        Correctness: 1 + (-(exp(0) - log(e'))) = 1 - (1 - log(e')) = log(e')

    Time complexity: O(n) where n = size(expr)
    Space complexity: O(n) for the output tree
    Size bound: size(output) ≤ 5 · size(input) (proven in Lean)

    Args:
        expr: Input expression tree (may contain EXP, LOG nodes)

    Returns:
        Equivalent expression tree using only EML for transcendentals.

    >>> x = Node.var(0)
    >>> compiled = compile_to_eml_only(Node.exp(x))
    >>> compiled.eval({0: 1.0})  # Should equal e ≈ 2.718
    2.718281828459045
    """
    if expr.kind in (NodeType.CONST, NodeType.VAR):
        return Node(expr.kind, value=expr.value, var_idx=expr.var_idx)

    if expr.kind == NodeType.EXP:
        # exp(e) = eml(e, 1)
        return Node.eml(compile_to_eml_only(expr.children[0]), Node.const(1.0))

    if expr.kind == NodeType.LOG:
        # log(e) = 1 - eml(0, e) = add(1, neg(eml(0, e)))
        compiled_child = compile_to_eml_only(expr.children[0])
        return Node.add(
            Node.const(1.0),
            Node.neg(Node.eml(Node.const(0.0), compiled_child))
        )

    # For all other nodes, recurse on children
    new_children = [compile_to_eml_only(c) for c in expr.children]
    return Node(expr.kind, value=expr.value, var_idx=expr.var_idx,
                children=new_children)


def is_eml_only(expr: Node) -> bool:
    """Check that an expression uses only EML (not EXP or LOG) for transcendentals.

    Time complexity: O(n)
    """
    if expr.kind in (NodeType.EXP, NodeType.LOG):
        return False
    return all(is_eml_only(c) for c in expr.children)


# ============================================================
# §3. Size Analysis
# ============================================================

def analyze_size_expansion(expr: Node) -> Dict:
    """
    Analyze the size expansion from compilation.

    Returns a dictionary with:
    - original_size: size of input
    - compiled_size: size of compiled output
    - ratio: compiled_size / original_size
    - bound: theoretical bound (5x, proven in Lean)
    - within_bound: whether the ratio is within the proven bound

    Time complexity: O(n)
    """
    compiled = compile_to_eml_only(expr)
    orig_size = expr.size()
    comp_size = compiled.size()
    ratio = comp_size / orig_size if orig_size > 0 else 0

    return {
        'original_size': orig_size,
        'compiled_size': comp_size,
        'ratio': ratio,
        'bound': 5.0,
        'within_bound': comp_size <= 5 * orig_size,
    }


def batch_size_analysis(depth: int = 5, trials: int = 100) -> Dict:
    """
    Generate random expressions up to given depth and analyze
    size expansion statistics.

    Returns aggregate statistics.
    """
    ratios = []
    for _ in range(trials):
        expr = random_expression(depth)
        analysis = analyze_size_expansion(expr)
        ratios.append(analysis['ratio'])

    return {
        'trials': trials,
        'depth': depth,
        'mean_ratio': sum(ratios) / len(ratios),
        'max_ratio': max(ratios),
        'min_ratio': min(ratios),
        'all_within_bound': all(r <= 5.0 for r in ratios),
    }


def random_expression(max_depth: int, p_leaf: float = 0.3) -> Node:
    """Generate a random expression tree."""
    if max_depth <= 0 or random.random() < p_leaf:
        if random.random() < 0.5:
            return Node.const(random.uniform(-5, 5))
        else:
            return Node.var(random.randint(0, 2))

    kind = random.choice(['add', 'mul', 'neg', 'inv', 'exp', 'log'])
    if kind == 'add':
        return Node.add(random_expression(max_depth-1, p_leaf),
                        random_expression(max_depth-1, p_leaf))
    elif kind == 'mul':
        return Node.mul(random_expression(max_depth-1, p_leaf),
                        random_expression(max_depth-1, p_leaf))
    elif kind == 'neg':
        return Node.neg(random_expression(max_depth-1, p_leaf))
    elif kind == 'inv':
        return Node.inv(random_expression(max_depth-1, p_leaf))
    elif kind == 'exp':
        return Node.exp(random_expression(max_depth-1, p_leaf))
    else:
        return Node.log(random_expression(max_depth-1, p_leaf))


# ============================================================
# §4. Symbolic Derivative in the EML Algebra
# ============================================================

def symbolic_derivative(expr: Node, var: int = 0) -> Node:
    """
    Compute the symbolic derivative d/dx of an expression tree.

    Uses standard differentiation rules:
    - d/dx[c] = 0
    - d/dx[x_i] = 1 if i == var, else 0
    - d/dx[f + g] = f' + g'
    - d/dx[f * g] = f'*g + f*g'
    - d/dx[-f] = -f'
    - d/dx[1/f] = -f' / f²
    - d/dx[exp(f)] = f' * exp(f)
    - d/dx[log(f)] = f' / f
    - d/dx[eml(f, g)] = f'*exp(f) - g'/g
        (since eml(f,g) = exp(f) - log(g))

    The result is an expression in the same algebra, demonstrating
    closure under differentiation (Theorem: deriv_eml_composition).

    Time complexity: O(n) where n = size(expr)
    Space complexity: O(n²) for the output (no simplification)

    Args:
        expr: Expression tree to differentiate
        var: Variable index to differentiate with respect to

    Returns:
        Expression tree for the derivative
    """
    if expr.kind == NodeType.CONST:
        return Node.const(0.0)
    elif expr.kind == NodeType.VAR:
        return Node.const(1.0 if expr.var_idx == var else 0.0)
    elif expr.kind == NodeType.ADD:
        return Node.add(
            symbolic_derivative(expr.children[0], var),
            symbolic_derivative(expr.children[1], var)
        )
    elif expr.kind == NodeType.MUL:
        f, g = expr.children
        fp = symbolic_derivative(f, var)
        gp = symbolic_derivative(g, var)
        return Node.add(Node.mul(fp, g), Node.mul(f, gp))
    elif expr.kind == NodeType.NEG:
        return Node.neg(symbolic_derivative(expr.children[0], var))
    elif expr.kind == NodeType.INV:
        f = expr.children[0]
        fp = symbolic_derivative(f, var)
        return Node.neg(Node.mul(fp, Node.inv(Node.mul(f, f))))
    elif expr.kind == NodeType.EXP:
        f = expr.children[0]
        fp = symbolic_derivative(f, var)
        return Node.mul(fp, Node.exp(f))
    elif expr.kind == NodeType.LOG:
        f = expr.children[0]
        fp = symbolic_derivative(f, var)
        return Node.mul(fp, Node.inv(f))
    elif expr.kind == NodeType.EML:
        # d/dx[eml(f,g)] = d/dx[exp(f) - log(g)] = f'*exp(f) - g'/g
        f, g = expr.children
        fp = symbolic_derivative(f, var)
        gp = symbolic_derivative(g, var)
        return Node.add(
            Node.mul(fp, Node.exp(f)),
            Node.neg(Node.mul(gp, Node.inv(g)))
        )
    raise ValueError(f"Unknown node type: {expr.kind}")


# ============================================================
# §5. Representability Checker
# ============================================================

def check_representability(target_fn: Callable[[float], float],
                          domain: Tuple[float, float] = (0.1, 5.0),
                          max_depth: int = 4,
                          n_samples: int = 20,
                          tolerance: float = 1e-6,
                          max_attempts: int = 5000) -> Optional[Node]:
    """
    Brute-force search for an EML-only expression that matches a target function.

    Enumerates expression trees up to the given depth and checks whether
    they match the target function on sampled domain points.

    Args:
        target_fn: The target function to represent
        domain: (lo, hi) domain for sampling
        max_depth: Maximum expression tree depth
        n_samples: Number of sample points for comparison
        tolerance: Maximum allowed error for a match
        max_attempts: Maximum number of random expressions to try

    Returns:
        An EML-only expression matching the target, or None.

    Time complexity: O(max_attempts · n_samples · tree_eval_time)
    """
    sample_xs = [domain[0] + (domain[1] - domain[0]) * i / (n_samples - 1)
                 for i in range(n_samples)]
    target_ys = [target_fn(x) for x in sample_xs]

    for _ in range(max_attempts):
        expr = random_eml_expression(max_depth)
        try:
            match = True
            for x, ty in zip(sample_xs, target_ys):
                ey = expr.eval({0: x})
                if not math.isfinite(ey) or abs(ey - ty) > tolerance:
                    match = False
                    break
            if match:
                return expr
        except (ValueError, OverflowError, ZeroDivisionError):
            continue

    return None


def random_eml_expression(max_depth: int) -> Node:
    """Generate a random EML-only expression (no separate exp/log)."""
    if max_depth <= 0 or random.random() < 0.35:
        if random.random() < 0.5:
            return Node.const(random.choice([0.0, 1.0, -1.0, 2.0, 0.5, -0.5]))
        else:
            return Node.var(0)

    kind = random.choice(['add', 'mul', 'neg', 'eml'])
    if kind == 'add':
        return Node.add(random_eml_expression(max_depth-1),
                        random_eml_expression(max_depth-1))
    elif kind == 'mul':
        return Node.mul(random_eml_expression(max_depth-1),
                        random_eml_expression(max_depth-1))
    elif kind == 'neg':
        return Node.neg(random_eml_expression(max_depth-1))
    else:
        return Node.eml(random_eml_expression(max_depth-1),
                        random_eml_expression(max_depth-1))


# ============================================================
# §6. Numerical Verification of Catalog Identities
# ============================================================

def verify_catalog_identities(n_samples: int = 100) -> Dict:
    """
    Numerically verify the key EML catalog identities:

    1. eml(x, 1) = exp(x)
    2. 1 - eml(0, y) = log(y)  for y > 0
    3. eml(log(a), exp(b)) = a - b  for a > 0

    Returns verification results with maximum errors.
    """
    results = {}

    # Identity 1: eml(x, 1) = exp(x)
    max_err = 0.0
    for _ in range(n_samples):
        x = random.uniform(-5, 5)
        eml_val = math.exp(x) - math.log(1.0)  # eml(x, 1)
        exp_val = math.exp(x)
        max_err = max(max_err, abs(eml_val - exp_val))
    results['eml_x_1_equals_exp'] = {'max_error': max_err, 'passed': max_err < 1e-14}

    # Identity 2: 1 - eml(0, y) = log(y) for y > 0
    max_err = 0.0
    for _ in range(n_samples):
        y = random.uniform(0.01, 100)
        eml_val = math.exp(0) - math.log(y)  # eml(0, y)
        reconstructed = 1.0 - eml_val  # should equal log(y)
        log_val = math.log(y)
        max_err = max(max_err, abs(reconstructed - log_val))
    results['one_minus_eml_0_y_equals_log'] = {'max_error': max_err, 'passed': max_err < 1e-14}

    # Identity 3: eml(log(a), exp(b)) = a - b for a > 0
    max_err = 0.0
    for _ in range(n_samples):
        a = random.uniform(0.01, 100)
        b = random.uniform(-5, 5)
        eml_val = math.exp(math.log(a)) - math.log(math.exp(b))  # eml(log a, exp b)
        target = a - b
        max_err = max(max_err, abs(eml_val - target))
    results['eml_log_exp_equals_sub'] = {'max_error': max_err, 'passed': max_err < 1e-10}

    return results


# ============================================================
# §7. Main: Run All Algorithms
# ============================================================

if __name__ == "__main__":
    print("=" * 60)
    print("  EML ALGORITHMS — DEMONSTRATION")
    print("=" * 60)

    # 1. Compilation demo
    print("\n--- §1. Compilation Algorithm ---")
    x = Node.var(0)
    test_exprs = [
        ("exp(x)", Node.exp(x)),
        ("log(x)", Node.log(x)),
        ("exp(x) + log(x)", Node.add(Node.exp(x), Node.log(x))),
        ("exp(exp(x))", Node.exp(Node.exp(x))),
    ]
    for name, expr in test_exprs:
        compiled = compile_to_eml_only(expr)
        analysis = analyze_size_expansion(expr)
        val_orig = expr.eval({0: 2.0})
        val_comp = compiled.eval({0: 2.0})
        print(f"  {name:20s}  size: {analysis['original_size']:2d} → "
              f"{analysis['compiled_size']:2d} ({analysis['ratio']:.1f}×)  "
              f"val: {val_orig:.6f} = {val_comp:.6f}  "
              f"eml_only: {is_eml_only(compiled)}")

    # 2. Size analysis
    print("\n--- §2. Size Analysis (random expressions) ---")
    for depth in [3, 5, 7]:
        stats = batch_size_analysis(depth=depth, trials=200)
        print(f"  depth={depth}: mean ratio={stats['mean_ratio']:.2f}, "
              f"max ratio={stats['max_ratio']:.2f}, "
              f"all ≤ 5x: {stats['all_within_bound']}")

    # 3. Symbolic derivative
    print("\n--- §3. Symbolic Derivative ---")
    eml_expr = Node.eml(x, Node.add(x, Node.const(1.0)))
    deriv = symbolic_derivative(eml_expr)
    print(f"  d/dx[eml(x, x+1)]:")
    for xv in [0.5, 1.0, 2.0]:
        val = deriv.eval({0: xv})
        # Manual: d/dx[exp(x) - log(x+1)] = exp(x) - 1/(x+1)
        expected = math.exp(xv) - 1.0/(xv + 1.0)
        print(f"    x={xv}: computed={val:.6f}, expected={expected:.6f}, "
              f"error={abs(val-expected):.2e}")

    # 4. Catalog identities
    print("\n--- §4. Catalog Identity Verification ---")
    identities = verify_catalog_identities()
    for name, result in identities.items():
        status = "✓ PASS" if result['passed'] else "✗ FAIL"
        print(f"  {name}: {status} (max error: {result['max_error']:.2e})")

    print("\n" + "=" * 60)
    print("  All algorithms executed successfully.")
    print("=" * 60)

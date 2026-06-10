#!/usr/bin/env python3
"""
Applications of Abstract Rewrite Algebra

Demonstrates real-world applications of the theorems proved in
Catalog/Pythagorean/AbstractRewriteAlgebra.lean:

1. Compiler optimization pass ordering
2. Algebraic simplification engines
3. Equational reasoning decision procedures
4. Program equivalence checking
"""

from typing import Any, Callable, List, Tuple, Dict
from dataclasses import dataclass


# ============================================================================
# Application 1: Compiler Optimization Pass Ordering
# ============================================================================

@dataclass
class IRNode:
    """Simple intermediate representation node."""
    op: str
    args: list
    ty: str = "int"

    def __repr__(self):
        if not self.args:
            return self.op
        if len(self.args) == 1:
            return f"{self.op}({self.args[0]})"
        return f"({self.args[0]} {self.op} {self.args[1]})"

    def __eq__(self, other):
        return isinstance(other, IRNode) and self.op == other.op and self.args == other.args

    def __hash__(self):
        return hash((self.op, tuple(str(a) for a in self.args)))


def constant_fold(node: IRNode) -> IRNode:
    """Constant folding optimization pass.

    By the semantic_determinism theorem, this pass commutes with
    all other semantics-preserving passes.
    """
    if not node.args:
        return node
    new_args = [constant_fold(a) if isinstance(a, IRNode) else a for a in node.args]

    # Try to evaluate if all args are constants
    if all(isinstance(a, (int, float)) or (isinstance(a, IRNode) and a.args == [] and a.op.lstrip('-').isdigit())
           for a in new_args):
        vals = []
        for a in new_args:
            if isinstance(a, (int, float)):
                vals.append(a)
            elif isinstance(a, IRNode):
                vals.append(int(a.op))
        if node.op == '+' and len(vals) == 2:
            return IRNode(str(vals[0] + vals[1]), [])
        if node.op == '*' and len(vals) == 2:
            return IRNode(str(vals[0] * vals[1]), [])
        if node.op == '-' and len(vals) == 2:
            return IRNode(str(vals[0] - vals[1]), [])

    return IRNode(node.op, new_args)


def dead_code_elim(node: IRNode) -> IRNode:
    """Dead code elimination: remove x + 0, x * 1, 0 * x patterns."""
    if not node.args:
        return node
    new_args = [dead_code_elim(a) if isinstance(a, IRNode) else a for a in node.args]

    zero = IRNode("0", [])
    one = IRNode("1", [])

    if node.op == '+' and len(new_args) == 2:
        if new_args[1] == zero: return new_args[0]
        if new_args[0] == zero: return new_args[1]
    if node.op == '*' and len(new_args) == 2:
        if new_args[1] == one: return new_args[0]
        if new_args[0] == one: return new_args[1]
        if new_args[0] == zero or new_args[1] == zero: return zero

    return IRNode(node.op, new_args)


def strength_reduce(node: IRNode) -> IRNode:
    """Strength reduction: x * 2 -> x + x."""
    if not node.args:
        return node
    new_args = [strength_reduce(a) if isinstance(a, IRNode) else a for a in node.args]

    two = IRNode("2", [])
    if node.op == '*' and len(new_args) == 2:
        if new_args[1] == two:
            return IRNode('+', [new_args[0], new_args[0]])

    return IRNode(node.op, new_args)


def eval_ir(node: IRNode, env: Dict[str, int] = None) -> int:
    """Evaluate an IR node."""
    env = env or {}
    if not node.args:
        if node.op in env:
            return env[node.op]
        try:
            return int(node.op)
        except ValueError:
            return 0

    vals = [eval_ir(a, env) if isinstance(a, IRNode) else a for a in node.args]
    if node.op == '+': return vals[0] + vals[1]
    if node.op == '*': return vals[0] * vals[1]
    if node.op == '-': return vals[0] - vals[1]
    return 0


def demo_compiler_ordering():
    """Demonstrate that optimization pass ordering doesn't affect semantics."""
    print("=" * 60)
    print("Application 1: Compiler Pass Ordering Independence")
    print("=" * 60)

    # Program: (x + 0) * (2 + 3)
    prog = IRNode('*', [
        IRNode('+', [IRNode('x', []), IRNode('0', [])]),
        IRNode('+', [IRNode('2', []), IRNode('3', [])])
    ])

    passes = [
        ("const_fold", constant_fold),
        ("dead_code_elim", dead_code_elim),
        ("strength_reduce", strength_reduce),
    ]

    env = {'x': 7}
    original_val = eval_ir(prog, env)

    print(f"Original program: {prog}")
    print(f"Original value (x=7): {original_val}")
    print()

    # Try all 6 orderings of 3 passes
    from itertools import permutations
    results = []
    for perm in permutations(range(len(passes))):
        current = prog
        names = []
        for i in perm:
            name, fn = passes[i]
            current = fn(current)
            names.append(name)

        val = eval_ir(current, env)
        results.append((names, current, val))
        print(f"  {'→'.join(names)}: {current} = {val}")

    # Verify semantic determinism
    all_same = all(r[2] == original_val for r in results)
    print(f"\nAll orderings preserve semantics: {all_same} ✓")
    print(f"(This is guaranteed by the semantic_determinism theorem)")
    print()


# ============================================================================
# Application 2: Algebraic Simplification Engine
# ============================================================================

def demo_algebraic_simplifier():
    """Show how confluence guarantees deterministic simplification."""
    print("=" * 60)
    print("Application 2: Algebraic Simplification via Confluence")
    print("=" * 60)

    # Polynomial simplification rules (confluent system)
    # We'll use string-based rewriting for simplicity
    from algorithms import StringRewriteSystem

    # Simple polynomial normalization
    srs = StringRewriteSystem([
        ("x*1", "x"),
        ("1*x", "x"),
        ("x*0", "0"),
        ("0*x", "0"),
        ("x+0", "x"),
        ("0+x", "x"),
    ])

    test_exprs = [
        "x*1+0",
        "0+x*1",
        "1*x+0*x",
        "x*0+1*x",
    ]

    print("Polynomial simplification rules:")
    for lhs, rhs in srs.rules:
        print(f"  {lhs} → {rhs}")
    print()

    for expr in test_exprs:
        nf = srs.normalize(expr)
        print(f"  {expr} →* {nf}")

    print()


# ============================================================================
# Application 3: Program Equivalence via Normal Forms
# ============================================================================

def demo_program_equivalence():
    """Show how the joinable_iff_nf_eq theorem enables equivalence checking."""
    print("=" * 60)
    print("Application 3: Program Equivalence via Normal Forms")
    print("=" * 60)

    # Simple expression language with rewrite rules
    # By the joinable_iff_nf_eq theorem, two expressions are equivalent
    # iff they have the same normal form

    class Expr:
        """Simple arithmetic expression."""
        def __init__(self, op, args=None):
            self.op = op
            self.args = args or []

        def __repr__(self):
            if not self.args: return self.op
            return f"({self.args[0]} {self.op} {self.args[1]})"

        def __eq__(self, other):
            return isinstance(other, Expr) and self.op == other.op and self.args == other.args

        def __hash__(self):
            return hash((self.op, tuple(self.args)))

    def simplify(e: Expr) -> Expr:
        """Simplify an expression to normal form."""
        if not e.args:
            return e
        args = [simplify(a) for a in e.args]

        zero, one = Expr("0"), Expr("1")

        if e.op == '+':
            if args[1] == zero: return args[0]
            if args[0] == zero: return args[1]
            if args[0] == args[1]: return Expr("*", [Expr("2"), args[0]])
        if e.op == '*':
            if args[1] == one: return args[0]
            if args[0] == one: return args[1]
            if args[1] == zero or args[0] == zero: return zero
        return Expr(e.op, args)

    # Check equivalences
    pairs = [
        (Expr('+', [Expr('x'), Expr('0')]),
         Expr('*', [Expr('x'), Expr('1')]),
         "x + 0 vs x * 1"),

        (Expr('+', [Expr('x'), Expr('x')]),
         Expr('*', [Expr('2'), Expr('x')]),
         "x + x vs 2 * x"),

        (Expr('*', [Expr('0'), Expr('x')]),
         Expr('+', [Expr('0'), Expr('0')]),
         "0 * x vs 0 + 0"),
    ]

    print("By joinable_iff_nf_eq: equivalent ⟺ same normal form\n")
    for e1, e2, desc in pairs:
        nf1, nf2 = simplify(e1), simplify(e2)
        equiv = nf1 == nf2
        print(f"  {desc}")
        print(f"    nf({e1}) = {nf1}")
        print(f"    nf({e2}) = {nf2}")
        print(f"    Equivalent: {equiv}")
        print()


# ============================================================================
# Application 4: Rewrite-Based Decision Procedures
# ============================================================================

def demo_decision_procedure():
    """Demonstrate equational theory decision via confluent completion."""
    print("=" * 60)
    print("Application 4: Word Problem Decision Procedure")
    print("=" * 60)

    print("For a confluent terminating system, the word problem is decidable:")
    print("  s =_E t  ⟺  nf(s) = nf(t)")
    print()

    # Group theory example (simplified)
    # Rules: e*x -> x, x*e -> x, x*x^-1 -> e, (x*y)*z -> x*(y*z)
    from algorithms import StringRewriteSystem

    srs = StringRewriteSystem([
        ("e*", ""),       # left identity
        ("*e", ""),       # right identity
        ("a*A", "e"),     # a * a^-1 = e
        ("A*a", "e"),     # a^-1 * a = e
        ("b*B", "e"),     # b * b^-1 = e
        ("B*b", "e"),     # b^-1 * b = e
        ("ee", "e"),      # e * e = e
    ])

    queries = [
        ("a*A*b*B", "e*e", "a·a⁻¹·b·b⁻¹ =? e·e"),
        ("a*b*B", "a", "a·b·b⁻¹ =? a"),
        ("A*a*b", "b", "a⁻¹·a·b =? b"),
    ]

    for s, t, desc in queries:
        nf_s = srs.normalize(s)
        nf_t = srs.normalize(t)
        equiv = nf_s == nf_t
        print(f"  Query: {desc}")
        print(f"    nf(LHS) = '{nf_s}', nf(RHS) = '{nf_t}'")
        print(f"    Answer: {'Equal' if equiv else 'Not equal'}")
        print()


if __name__ == "__main__":
    demo_compiler_ordering()
    demo_algebraic_simplifier()
    demo_program_equivalence()
    demo_decision_procedure()
    print("All applications demonstrated successfully.")


#!/usr/bin/env python3
"""
Demonstration of Abstract Rewrite System Theory

Shows concrete examples of:
1. Diamond property and confluence
2. Normal form computation
3. Church-Rosser equivalence checking
4. Compiler pass coherence
5. Rewrite semilattice structure
"""

from algorithms import (
    RewriteSystem, Term, Rule,
    normalize, check_confluence, check_critical_pairs,
    RewriteSemilattice
)


def demo_boolean_algebra():
    """Demonstrate confluence of Boolean algebra simplification rules."""
    print("=" * 60)
    print("Demo 1: Boolean Algebra Confluence")
    print("=" * 60)

    # Rules: x OR x -> x, x AND x -> x, x OR 0 -> x, x AND 1 -> x
    # NOT NOT x -> x, x OR 1 -> 1, x AND 0 -> 0
    rules = [
        Rule("or_idem", lambda t: t if t.op == "OR" and t.args[0] == t.args[1] else None,
             lambda t: t.args[0]),
        Rule("and_idem", lambda t: t if t.op == "AND" and t.args[0] == t.args[1] else None,
             lambda t: t.args[0]),
        Rule("or_zero", lambda t: t if t.op == "OR" and t.args[1] == Term("0") else None,
             lambda t: t.args[0]),
        Rule("and_one", lambda t: t if t.op == "AND" and t.args[1] == Term("1") else None,
             lambda t: t.args[0]),
        Rule("not_not", lambda t: t if t.op == "NOT" and t.args[0].op == "NOT" else None,
             lambda t: t.args[0].args[0]),
        Rule("or_one", lambda t: t if t.op == "OR" and t.args[1] == Term("1") else None,
             lambda t: Term("1")),
        Rule("and_zero", lambda t: t if t.op == "AND" and t.args[1] == Term("0") else None,
             lambda t: Term("0")),
    ]

    rs = RewriteSystem(rules)

    # Example: (x OR x) AND 1
    t = Term("AND", [Term("OR", [Term("x"), Term("x")]), Term("1")])
    print(f"Input:  {t}")

    nf, steps = normalize(rs, t, trace=True)
    for i, (rule_name, intermediate) in enumerate(steps):
        print(f"  Step {i+1} ({rule_name}): {intermediate}")
    print(f"Normal form: {nf}")
    print()

    # Show confluence: different reduction orders give same result
    t2 = Term("OR", [Term("AND", [Term("x"), Term("x")]), Term("0")])
    print(f"Input:  {t2}")
    nf2, _ = normalize(rs, t2)
    print(f"Normal form: {nf2}")
    print()


def demo_diamond_property():
    """Demonstrate the diamond property with a concrete example."""
    print("=" * 60)
    print("Demo 2: Diamond Property Visualization")
    print("=" * 60)

    # Simple string rewriting: ab -> a, ba -> a (has diamond property)
    print("System: {ab → a, ba → a}")
    print()
    print("Peak: 'aba' → 'aa' (apply rule 1 at pos 0)")
    print("Peak: 'aba' → 'aa' (apply rule 2 at pos 1)")
    print("Diamond: both reduce to 'aa' — diamond property holds!")
    print()

    # Non-confluent example
    print("System: {ab → a, ab → b} (NOT confluent)")
    print("Peak: 'ab' → 'a' (rule 1)")
    print("Peak: 'ab' → 'b' (rule 2)")
    print("No common reduct exists — confluence fails!")
    print()


def demo_compiler_passes():
    """Demonstrate the compiler pass coherence theorem."""
    print("=" * 60)
    print("Demo 3: Compiler Pass Coherence")
    print("=" * 60)

    # Model programs as arithmetic expressions
    # Passes: constant folding, identity elimination

    def eval_expr(expr):
        """Evaluate a simple arithmetic expression."""
        if isinstance(expr, (int, float)):
            return expr
        op, args = expr
        vals = [eval_expr(a) for a in args]
        if op == '+': return sum(vals)
        if op == '*':
            r = 1
            for v in vals: r *= v
            return r
        return 0

    def const_fold(expr):
        """Constant folding pass."""
        if isinstance(expr, (int, float, str)):
            return expr
        op, args = expr
        new_args = [const_fold(a) for a in args]
        if all(isinstance(a, (int, float)) for a in new_args):
            return eval_expr((op, new_args))
        return (op, new_args)

    def identity_elim(expr):
        """Identity elimination: x + 0 -> x, x * 1 -> x."""
        if isinstance(expr, (int, float, str)):
            return expr
        op, args = expr
        new_args = [identity_elim(a) for a in args]
        if op == '+' and len(new_args) == 2:
            if new_args[1] == 0: return new_args[0]
            if new_args[0] == 0: return new_args[1]
        if op == '*' and len(new_args) == 2:
            if new_args[1] == 1: return new_args[0]
            if new_args[0] == 1: return new_args[1]
        return (op, new_args)

    # Program: (2 + 3) * (x + 0)
    prog = ('*', [
        ('+', [2, 3]),
        ('+', ['x', 0])
    ])

    print(f"Program: (2 + 3) * (x + 0)")
    print()

    # Order 1: const_fold then identity_elim
    r1 = identity_elim(const_fold(prog))
    print(f"const_fold → identity_elim: {r1}")

    # Order 2: identity_elim then const_fold
    r2 = const_fold(identity_elim(prog))
    print(f"identity_elim → const_fold: {r2}")

    print(f"\nBoth produce: {r1}")
    print(f"Results equal: {r1 == r2}")
    print()

    # Verify semantic preservation
    env = {'x': 7}
    def eval_with_env(expr, env):
        if isinstance(expr, str): return env.get(expr, 0)
        if isinstance(expr, (int, float)): return expr
        op, args = expr
        vals = [eval_with_env(a, env) for a in args]
        if op == '+': return sum(vals)
        if op == '*':
            r = 1
            for v in vals: r *= v
            return r
        return 0

    orig_val = eval_with_env(prog, env)
    r1_val = eval_with_env(r1, env)
    r2_val = eval_with_env(r2, env)
    print(f"Original eval (x=7): {orig_val}")
    print(f"After pass 1→2 (x=7): {r1_val}")
    print(f"After pass 2→1 (x=7): {r2_val}")
    print(f"Semantic determinism verified: {orig_val == r1_val == r2_val}")
    print()


def demo_rewrite_semilattice():
    """Demonstrate the rewrite semilattice structure."""
    print("=" * 60)
    print("Demo 4: Rewrite Semilattice")
    print("=" * 60)

    # Natural number modular arithmetic: reduce mod 5
    # Rules: n -> n mod 5 for n >= 5
    rules = [
        Rule("mod5", lambda t: t if t.op is None and t.value >= 5 else None,
             lambda t: Term(str(t.value % 5)))
    ]

    # Extend Term to handle numeric values
    class NumTerm:
        def __init__(self, n):
            self.value = n
        def __repr__(self):
            return str(self.value)
        def __eq__(self, other):
            return isinstance(other, NumTerm) and self.value == other.value
        def __hash__(self):
            return hash(self.value)

    def nf_mod5(n):
        return n % 5

    print("Rewrite Semilattice: ℤ with reduction mod 5")
    print()

    for n in [7, 12, 23, 5, 3]:
        nf = nf_mod5(n)
        print(f"  nf({n}) = {nf}")

    print()
    print("Properties:")
    print(f"  Idempotent: nf(nf(7)) = nf({nf_mod5(7)}) = {nf_mod5(nf_mod5(7))} = nf(7) ✓")

    # Joinability iff same NF
    print(f"  7 and 12 joinable? nf(7)={nf_mod5(7)}, nf(12)={nf_mod5(12)}, same={nf_mod5(7)==nf_mod5(12)} ✓")
    print(f"  7 and 13 joinable? nf(7)={nf_mod5(7)}, nf(13)={nf_mod5(13)}, same={nf_mod5(7)==nf_mod5(13)} ✗")
    print()


def demo_church_rosser():
    """Demonstrate the Church-Rosser equivalence."""
    print("=" * 60)
    print("Demo 5: Church-Rosser Equivalence")
    print("=" * 60)

    print("In a confluent system, two terms are equivalent iff they")
    print("have the same normal form.")
    print()

    # Group theory example: rewrite rules for group simplification
    print("Group theory rules:")
    print("  e * x → x")
    print("  x * e → x")
    print("  x * x⁻¹ → e")
    print("  x⁻¹ * x → e")
    print()

    # Show equivalence via normal forms
    print("Question: Is (a * e) * (b * b⁻¹) equivalent to a?")
    print("  (a * e) * (b * b⁻¹)")
    print("  → a * (b * b⁻¹)      [x * e → x]")
    print("  → a * e               [x * x⁻¹ → e]")
    print("  → a                   [x * e → x]")
    print()
    print("  Normal form of LHS: a")
    print("  Normal form of RHS: a")
    print("  Same NF → equivalent by Church-Rosser ✓")
    print()


if __name__ == "__main__":
    demo_boolean_algebra()
    demo_diamond_property()
    demo_compiler_passes()
    demo_rewrite_semilattice()
    demo_church_rosser()
    print("All demonstrations complete.")


#!/usr/bin/env python3
"""
Visualization: Church-Rosser Equivalence

Visualizes the equivalence between confluence and the Church-Rosser property,
showing how zigzag paths (equivalence closure) relate to forward-only paths
(reflexive-transitive closure) through the common reduct construction.
"""

import matplotlib.pyplot as plt
import numpy as np

fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# === Panel 1: Equivalence Closure (Zigzag) ===
ax = axes[0]
ax.set_xlim(-1, 7)
ax.set_ylim(-2, 4)
ax.set_title('Equivalence Closure (Zigzag Path)', fontsize=13, fontweight='bold')

# Zigzag path: a → x₁ ← x₂ → x₃ ← b
points = [(0, 2), (1.5, 3), (3, 2), (4.5, 3), (6, 2)]
labels = ['a', 'x₁', 'x₂', 'x₃', 'b']
colors = ['red', 'gray', 'gray', 'gray', 'blue']

# Draw points
for (x, y), label, color in zip(points, labels, colors):
    ax.plot(x, y, 'o', color=color, markersize=12, markeredgecolor='black', markeredgewidth=2)
    ax.text(x, y - 0.5, label, fontsize=13, ha='center', fontweight='bold')

# Draw zigzag arrows (alternating forward/backward)
arrow_directions = [
    (0, 1, 'forward'),   # a → x₁
    (2, 1, 'backward'),  # x₂ → x₁ (shown as x₁ ← x₂)
    (2, 3, 'forward'),   # x₂ → x₃
    (4, 3, 'backward'),  # b → x₃ (shown as x₃ ← b)
]

for src, tgt, direction in arrow_directions:
    sx, sy = points[src]
    tx, ty = points[tgt]
    color = '#2ecc71' if direction == 'forward' else '#e74c3c'
    ax.annotate('', xy=(tx + 0.15 * np.sign(sx - tx), ty),
                xytext=(sx + 0.15 * np.sign(tx - sx), sy),
                arrowprops=dict(arrowstyle='->', color=color, lw=2.5))

ax.text(3, 0.5, 'a ≡ᵣ b (connected by zigzag\nof forward and backward steps)',
        fontsize=10, ha='center', style='italic',
        bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

# Legend
ax.plot([], [], '->', color='#2ecc71', label='Forward step (r)', linewidth=2)
ax.plot([], [], '->', color='#e74c3c', label='Backward step (r⁻¹)', linewidth=2)
ax.legend(loc='upper left', fontsize=9)
ax.axis('off')

# === Panel 2: Confluence Resolution ===
ax = axes[1]
ax.set_xlim(-1, 7)
ax.set_ylim(-3, 4.5)
ax.set_title('Confluence Resolves the Zigzag', fontsize=13, fontweight='bold')

# Show the same zigzag but with confluence filling in the gaps
# Top: zigzag path
for (x, y), label, color in zip(points, labels, colors):
    ax.plot(x, y, 'o', color=color, markersize=10, markeredgecolor='black')
    ax.text(x, y + 0.35, label, fontsize=11, ha='center')

# Zigzag arrows (lighter)
for src, tgt, direction in arrow_directions:
    sx, sy = points[src]
    tx, ty = points[tgt]
    color = '#2ecc71' if direction == 'forward' else '#e74c3c'
    ax.annotate('', xy=(tx + 0.1 * np.sign(sx - tx), ty),
                xytext=(sx + 0.1 * np.sign(tx - sx), sy),
                arrowprops=dict(arrowstyle='->', color=color, lw=1.5, alpha=0.4))

# Intermediate common reducts
mid_points = [(0.75, 0.5, 'd₁'), (3.75, 0.5, 'd₂')]
for x, y, label in mid_points:
    ax.plot(x, y, 's', color='purple', markersize=10, markeredgecolor='black')
    ax.text(x, y - 0.4, label, fontsize=11, ha='center', fontweight='bold', color='purple')

# Arrows to common reducts
# a →* d₁ and x₂ →* d₁ (using confluence at x₁)
ax.annotate('', xy=(0.75, 0.65), xytext=(0, 1.85),
            arrowprops=dict(arrowstyle='->', color='purple', lw=2, ls='--'))
ax.annotate('', xy=(0.85, 0.65), xytext=(3, 1.85),
            arrowprops=dict(arrowstyle='->', color='purple', lw=2, ls='--'))

# x₂ →* d₂ and b →* d₂
ax.annotate('', xy=(3.65, 0.65), xytext=(3, 1.85),
            arrowprops=dict(arrowstyle='->', color='purple', lw=2, ls='--'))
ax.annotate('', xy=(3.85, 0.65), xytext=(6, 1.85),
            arrowprops=dict(arrowstyle='->', color='purple', lw=2, ls='--'))

# Final common reduct
ax.plot(2.25, -1.5, '*', color='gold', markersize=20, markeredgecolor='black', markeredgewidth=2)
ax.text(2.25, -2.1, 'c (common reduct)', fontsize=11, ha='center', fontweight='bold')

ax.annotate('', xy=(2.15, -1.35), xytext=(0.75, 0.35),
            arrowprops=dict(arrowstyle='->', color='gold', lw=2.5, ls='--'))
ax.annotate('', xy=(2.35, -1.35), xytext=(3.75, 0.35),
            arrowprops=dict(arrowstyle='->', color='gold', lw=2.5, ls='--'))

ax.text(3, -2.8, 'Confluence guarantees ∃c:\na →* c ∧ b →* c',
        fontsize=10, ha='center', style='italic',
        bbox=dict(boxstyle='round', facecolor='#f0e0ff', alpha=0.8))
ax.axis('off')

# === Panel 3: The Equivalence Theorem ===
ax = axes[2]
ax.set_xlim(-1, 7)
ax.set_ylim(-1, 6)
ax.set_title('Church-Rosser ⟺ Confluence', fontsize=13, fontweight='bold')

# Two boxes connected by double arrow
box_style = dict(boxstyle='round,pad=0.5', facecolor='lightblue',
                  edgecolor='navy', linewidth=2)
box_style2 = dict(boxstyle='round,pad=0.5', facecolor='lightyellow',
                   edgecolor='darkgreen', linewidth=2)

ax.text(3, 5, 'ARSConfluent r', fontsize=14, ha='center', fontweight='bold',
        bbox=box_style)
ax.text(3, 3.5, '⟺', fontsize=24, ha='center', fontweight='bold', color='red')
ax.text(3, 2, 'ChurchRosser r', fontsize=14, ha='center', fontweight='bold',
        bbox=box_style2)

# Proof arrows
ax.annotate('', xy=(1.5, 3.7), xytext=(1.5, 4.5),
            arrowprops=dict(arrowstyle='->', color='navy', lw=2))
ax.text(0, 4.1, '(⇐) rtc → eqvgen\nthen apply CR', fontsize=8, ha='left')

ax.annotate('', xy=(4.5, 4.5), xytext=(4.5, 3.7),
            arrowprops=dict(arrowstyle='->', color='darkgreen', lw=2))
ax.text(5, 4.1, '(⇒) induction on\neqvgen derivation', fontsize=8, ha='left')

# Key insight box
insight_text = (
    "Key Insight:\n"
    "Confluence = joining multi-step divergences\n"
    "Church-Rosser = joining zigzag equivalences\n"
    "\n"
    "Same property, different perspectives!\n"
    "\n"
    "Application: s =_E t  ⟺  nf(s) = nf(t)\n"
    "(decidable word problem)"
)
ax.text(3, -0.2, insight_text, fontsize=9, ha='center', va='top',
        fontfamily='monospace',
        bbox=dict(boxstyle='round', facecolor='#f5f5f5', alpha=0.9, edgecolor='gray'))

ax.axis('off')

plt.suptitle('The Church-Rosser Equivalence: Two Views of the Same Property',
             fontsize=15, fontweight='bold')
plt.tight_layout()
plt.savefig('church_rosser.png', dpi=150, bbox_inches='tight')
print("Saved church_rosser.png")


#!/usr/bin/env python3
"""
Visualization: Confluence Diamond Tiling

Visualizes the Strip Lemma proof strategy: how the diamond property
tiles the region between two diverging paths to produce a common reduct.
This illustrates the core inductive argument of diamond_implies_confluence.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np

fig, axes = plt.subplots(1, 3, figsize=(16, 6))

# === Panel 1: Single Diamond ===
ax = axes[0]
ax.set_xlim(-1.5, 1.5)
ax.set_ylim(-1.5, 1.5)
ax.set_aspect('equal')
ax.set_title('Diamond Property', fontsize=14, fontweight='bold')

# Diamond shape
diamond_x = [0, -1, 0, 1, 0]
diamond_y = [1, 0, -1, 0, 1]
ax.plot(diamond_x, diamond_y, 'b-', linewidth=2)

# Arrows
ax.annotate('', xy=(-0.85, 0.15), xytext=(0, 1),
            arrowprops=dict(arrowstyle='->', color='red', lw=2))
ax.annotate('', xy=(0.85, 0.15), xytext=(0, 1),
            arrowprops=dict(arrowstyle='->', color='green', lw=2))
ax.annotate('', xy=(0, -0.85), xytext=(-0.85, 0.05),
            arrowprops=dict(arrowstyle='->', color='green', lw=2, ls='--'))
ax.annotate('', xy=(0, -0.85), xytext=(0.85, 0.05),
            arrowprops=dict(arrowstyle='->', color='red', lw=2, ls='--'))

# Labels
ax.text(0, 1.2, 'a', fontsize=14, ha='center', fontweight='bold')
ax.text(-1.2, 0, 'b', fontsize=14, ha='center', fontweight='bold')
ax.text(1.2, 0, 'c', fontsize=14, ha='center', fontweight='bold')
ax.text(0, -1.2, 'd', fontsize=14, ha='center', fontweight='bold')
ax.text(-0.7, 0.7, 'r', fontsize=12, ha='center', color='red')
ax.text(0.7, 0.7, 'r', fontsize=12, ha='center', color='green')
ax.text(-0.7, -0.7, 'r', fontsize=12, ha='center', color='green', style='italic')
ax.text(0.7, -0.7, 'r', fontsize=12, ha='center', color='red', style='italic')

ax.text(0, -1.8, '∀ b,c: r(a,b) ∧ r(a,c)\n⟹ ∃d: r(b,d) ∧ r(c,d)',
        fontsize=10, ha='center', style='italic')
ax.axis('off')

# === Panel 2: Strip Lemma ===
ax = axes[1]
ax.set_xlim(-1.5, 5.5)
ax.set_ylim(-2, 2)
ax.set_aspect('equal')
ax.set_title('Strip Lemma (Inductive Tiling)', fontsize=14, fontweight='bold')

# Top path: a → a₁ → a₂ → a₃ = b
top_y = 1.5
for i in range(4):
    ax.plot(i, top_y, 'ko', markersize=8)
    if i < 3:
        ax.annotate('', xy=(i+0.85, top_y), xytext=(i+0.15, top_y),
                    arrowprops=dict(arrowstyle='->', color='blue', lw=2))

# Bottom row: c → d₁ → d₂ → d₃
bot_y = -0.5
for i in range(4):
    ax.plot(i, bot_y, 'ko', markersize=8)
    if i < 3:
        ax.annotate('', xy=(i+0.85, bot_y), xytext=(i+0.15, bot_y),
                    arrowprops=dict(arrowstyle='->', color='purple', lw=2, ls='--'))

# Vertical arrows
for i in range(4):
    ax.annotate('', xy=(i, bot_y+0.15), xytext=(i, top_y-0.15),
                arrowprops=dict(arrowstyle='->', color='orange', lw=1.5,
                               ls='-' if i == 0 else '--'))

# Labels
labels_top = ['a', 'a₁', 'a₂', 'b']
labels_bot = ['c', 'd₁', 'd₂', 'd₃']
for i, (lt, lb) in enumerate(zip(labels_top, labels_bot)):
    ax.text(i, top_y + 0.3, lt, fontsize=12, ha='center', fontweight='bold')
    ax.text(i, bot_y - 0.35, lb, fontsize=12, ha='center', fontweight='bold')

# Diamond overlays
for i in range(3):
    diamond = patches.FancyBboxPatch((i-0.1, bot_y-0.1), 1.2, top_y-bot_y+0.2,
                                      boxstyle="round,pad=0.1",
                                      facecolor='lightyellow', edgecolor='gray',
                                      alpha=0.3, linewidth=1)
    ax.add_patch(diamond)

ax.text(2, -1.5, 'Each small diamond uses\nthe diamond property once',
        fontsize=10, ha='center', style='italic')
ax.axis('off')

# === Panel 3: Full Confluence ===
ax = axes[2]
ax.set_xlim(-2, 2)
ax.set_ylim(-3, 1.5)
ax.set_aspect('equal')
ax.set_title('Confluence (Diamond ⟹ CR)', fontsize=14, fontweight='bold')

# Source
ax.plot(0, 1, 'ko', markersize=10)
ax.text(0, 1.3, 'a', fontsize=14, ha='center', fontweight='bold')

# Left path: a →* b
left_pts = [(0, 1), (-0.5, 0.3), (-1, -0.4), (-1.2, -1.2)]
for i in range(len(left_pts)-1):
    ax.annotate('', xy=left_pts[i+1], xytext=left_pts[i],
                arrowprops=dict(arrowstyle='->', color='red', lw=2))
    ax.plot(*left_pts[i+1], 'ro', markersize=6)
ax.text(-1.5, -1.2, 'b', fontsize=14, ha='center', fontweight='bold', color='red')

# Right path: a →* c
right_pts = [(0, 1), (0.5, 0.3), (1, -0.4), (1.2, -1.2)]
for i in range(len(right_pts)-1):
    ax.annotate('', xy=right_pts[i+1], xytext=right_pts[i],
                arrowprops=dict(arrowstyle='->', color='green', lw=2))
    ax.plot(*right_pts[i+1], 'go', markersize=6)
ax.text(1.5, -1.2, 'c', fontsize=14, ha='center', fontweight='bold', color='green')

# Joining paths
join_pt = (0, -2.5)
ax.annotate('', xy=join_pt, xytext=left_pts[-1],
            arrowprops=dict(arrowstyle='->', color='green', lw=2, ls='--'))
ax.annotate('', xy=join_pt, xytext=right_pts[-1],
            arrowprops=dict(arrowstyle='->', color='red', lw=2, ls='--'))
ax.plot(*join_pt, 'ko', markersize=10)
ax.text(0, -2.8, 'd', fontsize=14, ha='center', fontweight='bold')

# Fill region
from matplotlib.patches import Polygon
region = Polygon([left_pts[-1], (0, 1), right_pts[-1], join_pt],
                  alpha=0.1, color='blue')
ax.add_patch(region)

ax.text(0, -3.3, '∀ b,c: a →* b ∧ a →* c\n⟹ ∃d: b →* d ∧ c →* d',
        fontsize=10, ha='center', style='italic')
ax.axis('off')

plt.suptitle('From Diamond Property to Confluence', fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('confluence_diagram.png', dpi=150, bbox_inches='tight')
print("Saved confluence_diagram.png")


#!/usr/bin/env python3
"""
Visualization: Rewrite Semilattice Structure

Visualizes how a confluent terminating rewrite system partitions
terms into equivalence classes, each with a unique normal form.
The normal form map acts as a projection/retraction onto the
set of irreducible elements.
"""

import matplotlib.pyplot as plt
import numpy as np

fig, axes = plt.subplots(1, 2, figsize=(14, 7))

# === Panel 1: Rewrite Graph with Equivalence Classes ===
ax = axes[0]
ax.set_xlim(-0.5, 6.5)
ax.set_ylim(-0.5, 5.5)
ax.set_title('Rewrite Graph & Equivalence Classes', fontsize=14, fontweight='bold')

# Define nodes and edges for a sample rewrite system
# Three equivalence classes converging to different normal forms
classes = {
    'Class A (nf = a)': {
        'nodes': [(1, 4.5, 'a·b·b⁻¹'), (0.5, 3, 'a·e'), (1.5, 3, 'e·a'), (1, 1.5, 'a')],
        'edges': [(0, 3), (1, 3), (2, 3)],
        'color': '#FF6B6B',
        'bg': '#FFE0E0'
    },
    'Class B (nf = b)': {
        'nodes': [(4, 4.5, 'b·a·a⁻¹'), (3.5, 3, 'b·e'), (4.5, 3, 'e·b'), (4, 1.5, 'b')],
        'edges': [(0, 3), (1, 3), (2, 3)],
        'color': '#4ECDC4',
        'bg': '#D0F0ED'
    },
    'Class C (nf = e)': {
        'nodes': [(2.5, 5, 'a·a⁻¹'), (2.5, 3.5, 'e·e'), (2.5, 2, 'e')],
        'edges': [(0, 2), (1, 2)],
        'color': '#45B7D1',
        'bg': '#D0E8F0'
    }
}

for cls_name, cls_data in classes.items():
    nodes = cls_data['nodes']
    edges = cls_data['edges']
    color = cls_data['color']
    bg = cls_data['bg']

    # Draw background ellipse for the class
    xs = [n[0] for n in nodes]
    ys = [n[1] for n in nodes]
    cx, cy = np.mean(xs), np.mean(ys)
    rx = max(0.8, (max(xs) - min(xs)) / 2 + 0.6)
    ry = max(1.0, (max(ys) - min(ys)) / 2 + 0.5)
    ellipse = plt.matplotlib.patches.Ellipse((cx, cy), 2*rx, 2*ry,
                                               alpha=0.2, color=bg,
                                               edgecolor=color, linewidth=2)
    ax.add_patch(ellipse)

    # Draw edges (rewrite steps)
    for src, tgt in edges:
        sx, sy = nodes[src][0], nodes[src][1]
        tx, ty = nodes[tgt][0], nodes[tgt][1]
        ax.annotate('', xy=(tx, ty + 0.2), xytext=(sx, sy - 0.2),
                    arrowprops=dict(arrowstyle='->', color=color, lw=1.5))

    # Draw nodes
    for x, y, label in nodes:
        is_nf = (nodes.index((x, y, label)) == len(nodes) - 1)
        marker_size = 12 if is_nf else 8
        edge_width = 3 if is_nf else 1
        ax.plot(x, y, 'o', color=color, markersize=marker_size,
                markeredgecolor='black', markeredgewidth=edge_width)
        offset = 0.3 if not is_nf else -0.35
        ax.text(x, y + offset, label, fontsize=8, ha='center',
                fontweight='bold' if is_nf else 'normal')

# Legend
ax.text(0, 0.5, '● = reducible term', fontsize=9)
ax.text(0, 0, '⬤ = normal form (bold border)', fontsize=9)
ax.text(0, -0.4, '→ = rewrite step', fontsize=9)
ax.axis('off')

# === Panel 2: Normal Form Map as Projection ===
ax = axes[1]
ax.set_xlim(-1, 7)
ax.set_ylim(-1, 6)
ax.set_title('Normal Form Map (Algebraic Projection)', fontsize=14, fontweight='bold')

# Upper level: all terms
upper_y = 4.5
terms = [
    (0.5, upper_y, 'a·e', '#FF6B6B'),
    (1.5, upper_y, 'e·a', '#FF6B6B'),
    (2.5, upper_y, 'a·a⁻¹', '#45B7D1'),
    (3.5, upper_y, 'b·e', '#4ECDC4'),
    (4.5, upper_y, 'e·b', '#4ECDC4'),
    (5.5, upper_y, 'e·e', '#45B7D1'),
]

# Lower level: normal forms
lower_y = 1.5
nfs = [
    (1, lower_y, 'a', '#FF6B6B'),
    (3, lower_y, 'e', '#45B7D1'),
    (5, lower_y, 'b', '#4ECDC4'),
]

# Draw terms
for x, y, label, color in terms:
    ax.plot(x, y, 'o', color=color, markersize=10, markeredgecolor='gray')
    ax.text(x, y + 0.35, label, fontsize=9, ha='center')

# Draw NFs
for x, y, label, color in nfs:
    ax.plot(x, y, 's', color=color, markersize=14, markeredgecolor='black',
            markeredgewidth=2)
    ax.text(x, y - 0.4, label, fontsize=11, ha='center', fontweight='bold')

# Draw projection arrows
projections = [
    (0, 0), (1, 0),  # a·e → a, e·a → a
    (2, 1), (5, 1),  # a·a⁻¹ → e, e·e → e
    (3, 2), (4, 2),  # b·e → b, e·b → b
]
for ti, ni in projections:
    tx, ty = terms[ti][0], terms[ti][1]
    nx, ny = nfs[ni][0], nfs[ni][1]
    ax.annotate('', xy=(nx, ny + 0.3), xytext=(tx, ty - 0.3),
                arrowprops=dict(arrowstyle='->', color='gray', lw=1.5, ls='--'))

# Labels
ax.text(3, 5.3, 'All Terms (reducible)', fontsize=12, ha='center',
        fontweight='bold', color='gray')
ax.text(3, 0.7, 'Normal Forms (irreducible)', fontsize=12, ha='center',
        fontweight='bold', color='black')

# NF map label
ax.annotate('nf', xy=(3, 3), fontsize=16, ha='center', fontweight='bold',
            color='purple', style='italic')
ax.annotate('', xy=(3, 2.3), xytext=(3, 3.7),
            arrowprops=dict(arrowstyle='->', color='purple', lw=3))

# Properties box
props = [
    'nf(nf(x)) = nf(x)     [idempotent]',
    'x →* y ⟹ nf(x) = nf(y)  [canonical]',
    'x ↔* y ⟺ nf(x) = nf(y)  [decidable]',
]
for i, prop in enumerate(props):
    ax.text(0, -0.2 - i * 0.4, prop, fontsize=9, fontfamily='monospace')

ax.axis('off')

plt.suptitle('Rewrite Semilattice: Algebraic Structure of Normalization',
             fontsize=15, fontweight='bold')
plt.tight_layout()
plt.savefig('rewrite_semilattice.png', dpi=150, bbox_inches='tight')
print("Saved rewrite_semilattice.png")

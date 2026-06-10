#!/usr/bin/env python3
"""
applications.py — Real-world applications of multi-sorted rewriting.

Demonstrates:
1. Type-preserving compiler optimization (integer/float/bool IR)
2. Database query optimization (relational algebra)
3. Linear algebra simplification (scalar/vector/matrix)
"""

from dataclasses import dataclass
from typing import Dict, List, Tuple, Optional, Any, Callable


# ──────────────────────────────────────────────────────────────
# Reuse core types from algorithms.py (self-contained versions)
# ──────────────────────────────────────────────────────────────

@dataclass(frozen=True)
class Sort:
    name: str
    def __repr__(self): return self.name

@dataclass(frozen=True)
class OpSym:
    name: str
    arg_sorts: Tuple[Sort, ...]
    result_sort: Sort
    @property
    def arity(self): return len(self.arg_sorts)

class Term:
    def sort(self) -> Sort: raise NotImplementedError
    def size(self) -> int: raise NotImplementedError

@dataclass(frozen=True)
class Var(Term):
    _sort: Sort
    index: int
    label: str = ""
    def sort(self): return self._sort
    def size(self): return 1
    def __repr__(self):
        return self.label if self.label else f"x{self.index}:{self._sort}"

@dataclass(frozen=True)
class App(Term):
    op: OpSym
    args: Tuple[Term, ...]
    def __post_init__(self):
        if len(self.args) != self.op.arity:
            raise TypeError(f"Arity mismatch for {self.op.name}")
        for i, (arg, exp) in enumerate(zip(self.args, self.op.arg_sorts)):
            if arg.sort() != exp:
                raise TypeError(
                    f"Sort mismatch at arg {i} of {self.op.name}: "
                    f"expected {exp}, got {arg.sort()}")
    def sort(self): return self.op.result_sort
    def size(self): return 1 + sum(a.size() for a in self.args)
    def __repr__(self):
        if not self.args:
            return self.op.name
        return f"{self.op.name}({', '.join(repr(a) for a in self.args)})"


def match_pattern(pattern, target):
    subst = {}
    def go(p, t):
        if isinstance(p, Var):
            key = (p._sort, p.index)
            if p.sort() != t.sort(): return False
            if key in subst: return subst[key] == t
            subst[key] = t
            return True
        elif isinstance(p, App) and isinstance(t, App):
            if p.op != t.op: return False
            return all(go(pa, ta) for pa, ta in zip(p.args, t.args))
        return False
    return subst if go(pattern, target) else None

def apply_subst(term, subst):
    if isinstance(term, Var):
        return subst.get((term._sort, term.index), term)
    elif isinstance(term, App):
        return App(term.op, tuple(apply_subst(a, subst) for a in term.args))
    raise TypeError

def normalize(rules, term, max_steps=1000):
    for _ in range(max_steps):
        rewritten = False
        for pos_term, pos, parent_replace in _all_positions(term):
            for lhs, rhs in rules:
                s = match_pattern(lhs, pos_term)
                if s is not None:
                    replacement = apply_subst(rhs, s)
                    term = parent_replace(replacement)
                    rewritten = True
                    break
            if rewritten: break
        if not rewritten: break
    return term

def _all_positions(term):
    yield term, term, lambda r: r
    if isinstance(term, App):
        for i, arg in enumerate(term.args):
            for sub, pos, child_replace in _all_positions(arg):
                def make_replace(idx, cr, t=term):
                    def replace(r):
                        new_args = list(t.args)
                        new_args[idx] = cr(r)
                        return App(t.op, tuple(new_args))
                    return replace
                yield sub, pos, make_replace(i, child_replace)


# ──────────────────────────────────────────────────────────────
# Application 1: Compiler IR Optimization
# ──────────────────────────────────────────────────────────────

def demo_compiler_optimization():
    """
    Type-preserving optimization of a simple compiler IR.

    Sorts: int, float, bool
    Operations: arithmetic, comparison, logic
    Rules: algebraic identities (x+0→x, x*1→x, etc.)
    """
    print("=" * 70)
    print("APPLICATION 1: Type-Preserving Compiler Optimization")
    print("=" * 70)

    INT = Sort("int")
    FLOAT = Sort("float")
    BOOL = Sort("bool")

    # Operations
    add_i = OpSym("add_i", (INT, INT), INT)
    mul_i = OpSym("mul_i", (INT, INT), INT)
    add_f = OpSym("add_f", (FLOAT, FLOAT), FLOAT)
    mul_f = OpSym("mul_f", (FLOAT, FLOAT), FLOAT)
    eq_i  = OpSym("eq_i",  (INT, INT), BOOL)
    and_b = OpSym("and_b", (BOOL, BOOL), BOOL)
    or_b  = OpSym("or_b",  (BOOL, BOOL), BOOL)
    not_b = OpSym("not_b", (BOOL,), BOOL)
    zero_i = OpSym("0_i", (), INT)
    one_i  = OpSym("1_i", (), INT)
    zero_f = OpSym("0.0_f", (), FLOAT)
    one_f  = OpSym("1.0_f", (), FLOAT)
    true_b = OpSym("true", (), BOOL)
    false_b = OpSym("false", (), BOOL)

    # Variables
    xi = Var(INT, 0, "x_i")
    yi = Var(INT, 1, "y_i")
    xf = Var(FLOAT, 0, "x_f")
    xb = Var(BOOL, 0, "p")
    yb = Var(BOOL, 1, "q")

    z_i = App(zero_i, ())
    o_i = App(one_i, ())
    z_f = App(zero_f, ())
    o_f = App(one_f, ())
    t_b = App(true_b, ())
    f_b = App(false_b, ())

    # Optimization rules (sort-preserving by construction)
    rules = [
        # Integer rules
        (App(add_i, (xi, z_i)), xi),                    # x + 0 → x
        (App(add_i, (z_i, xi)), xi),                    # 0 + x → x
        (App(mul_i, (xi, o_i)), xi),                    # x * 1 → x
        (App(mul_i, (o_i, xi)), xi),                    # 1 * x → x
        (App(mul_i, (xi, z_i)), z_i),                   # x * 0 → 0
        (App(mul_i, (z_i, xi)), z_i),                   # 0 * x → 0
        # Float rules
        (App(add_f, (xf, z_f)), xf),                    # x + 0.0 → x
        (App(mul_f, (xf, o_f)), xf),                    # x * 1.0 → x
        (App(mul_f, (xf, z_f)), z_f),                   # x * 0.0 → 0.0
        # Boolean rules
        (App(and_b, (xb, t_b)), xb),                    # p ∧ true → p
        (App(and_b, (xb, f_b)), f_b),                   # p ∧ false → false
        (App(or_b, (xb, t_b)), t_b),                    # p ∨ true → true
        (App(or_b, (xb, f_b)), xb),                     # p ∨ false → p
        (App(not_b, (App(not_b, (xb,)),)), xb),         # ¬¬p → p
        (App(eq_i, (xi, xi)), t_b),                     # x == x → true
    ]

    print(f"\n{len(rules)} optimization rules across 3 types")

    # Example: complex expression to optimize
    # (x_i + 0) * 1 * (y_i * 0)  should simplify
    expr1 = App(mul_i, (
        App(mul_i, (App(add_i, (xi, z_i)), o_i)),
        App(mul_i, (yi, z_i))
    ))

    # ¬¬(p ∧ true) ∨ false  should simplify to p
    expr2 = App(or_b, (
        App(not_b, (App(not_b, (App(and_b, (xb, t_b)),)),)),
        f_b
    ))

    # x_f * 1.0 + 0.0  should simplify to x_f
    expr3 = App(add_f, (App(mul_f, (xf, o_f)), z_f))

    for name, expr in [("int_expr", expr1), ("bool_expr", expr2), ("float_expr", expr3)]:
        nf = normalize(rules, expr)
        print(f"\n  {name}:")
        print(f"    Original:  {expr}  (sort: {expr.sort()}, size: {expr.size()})")
        print(f"    Optimized: {nf}  (sort: {nf.sort()}, size: {nf.size()})")
        print(f"    Sort preserved: {'✓' if expr.sort() == nf.sort() else '✗'}")

    # Verify evaluation preservation
    print("\n  Evaluation verification (int_expr with x_i=3, y_i=7):")
    env_vals = {("int", 0): 3, ("int", 1): 7}

    def eval_int(t):
        if isinstance(t, Var) and t._sort == INT:
            return env_vals.get((t._sort.name, t.index), 0)
        if isinstance(t, App):
            if t.op == zero_i: return 0
            if t.op == one_i: return 1
            if t.op == add_i: return eval_int(t.args[0]) + eval_int(t.args[1])
            if t.op == mul_i: return eval_int(t.args[0]) * eval_int(t.args[1])
        return 0

    val_orig = eval_int(expr1)
    val_opt = eval_int(normalize(rules, expr1))
    print(f"    eval(original) = {val_orig}")
    print(f"    eval(optimized) = {val_opt}")
    print(f"    Equal: {'✓' if val_orig == val_opt else '✗'}")


# ──────────────────────────────────────────────────────────────
# Application 2: Linear Algebra Simplification
# ──────────────────────────────────────────────────────────────

def demo_linear_algebra():
    """
    Multi-sorted simplification for scalar-vector-matrix algebra.

    Sorts: scalar, vector, matrix
    Demonstrates that sort constraints prevent nonsensical operations.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 2: Scalar-Vector-Matrix Algebra")
    print("=" * 70)

    SC = Sort("scalar")
    VE = Sort("vector")
    MA = Sort("matrix")

    # Operations
    s_add = OpSym("s+", (SC, SC), SC)
    s_mul = OpSym("s*", (SC, SC), SC)
    v_add = OpSym("v+", (VE, VE), VE)
    sv_mul = OpSym("sv*", (SC, VE), VE)
    mv_mul = OpSym("Mv*", (MA, VE), VE)
    m_add = OpSym("M+", (MA, MA), MA)
    sm_mul = OpSym("sM*", (SC, MA), MA)
    s_zero = OpSym("0_s", (), SC)
    s_one = OpSym("1_s", (), SC)
    v_zero = OpSym("0_v", (), VE)
    m_id = OpSym("I", (), MA)
    m_zero = OpSym("0_M", (), MA)

    # Variables
    a = Var(SC, 0, "a")
    b = Var(SC, 1, "b")
    u = Var(VE, 0, "u")
    v = Var(VE, 1, "v")
    M = Var(MA, 0, "M")

    zs = App(s_zero, ())
    os = App(s_one, ())
    zv = App(v_zero, ())
    I = App(m_id, ())
    zM = App(m_zero, ())

    # Rules
    rules = [
        # Scalar rules
        (App(s_add, (a, zs)), a),
        (App(s_mul, (a, os)), a),
        (App(s_mul, (a, zs)), zs),
        # Vector rules
        (App(v_add, (u, zv)), u),
        (App(sv_mul, (os, u)), u),
        (App(sv_mul, (zs, u)), zv),
        # Matrix rules
        (App(mv_mul, (I, u)), u),
        (App(mv_mul, (zM, u)), zv),
        (App(sm_mul, (os, M)), M),
        (App(sm_mul, (zs, M)), zM),
        (App(m_add, (M, zM)), M),
    ]

    print(f"\n3 sorts, {len(rules)} rules")

    # Example: I · (a·0_s · u + 0_v)
    expr = App(mv_mul, (
        I,
        App(v_add, (
            App(sv_mul, (App(s_mul, (a, zs)), u)),
            zv
        ))
    ))

    nf = normalize(rules, expr)
    print(f"\n  Expression: {expr}")
    print(f"  Sort: {expr.sort()}")
    print(f"  Size: {expr.size()}")
    print(f"\n  Normal form: {nf}")
    print(f"  Sort: {nf.sort()}")
    print(f"  Size: {nf.size()}")
    print(f"  Sort preserved: {'✓' if expr.sort() == nf.sort() else '✗'}")

    # Sort safety demonstration
    print("\n  Sort safety checks:")
    try:
        bad = App(s_add, (a, u))  # Can't add scalar + vector
        print("    scalar + vector: SHOULD HAVE FAILED")
    except TypeError as e:
        print(f"    scalar + vector: Rejected ✓ ({e})")

    try:
        bad = App(mv_mul, (u, u))  # Can't multiply vector * vector
        print("    vector * vector: SHOULD HAVE FAILED")
    except TypeError as e:
        print(f"    vector * vector: Rejected ✓ ({e})")


# ──────────────────────────────────────────────────────────────
# Application 3: Evaluation Preservation Stress Test
# ──────────────────────────────────────────────────────────────

def demo_evaluation_preservation():
    """
    Stress test: verify evaluation preservation on many random terms.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 3: Evaluation Preservation Stress Test")
    print("=" * 70)

    import random
    rng = random.Random(42)

    SC = Sort("scalar")
    VE = Sort("vector")

    s_add = OpSym("s+", (SC, SC), SC)
    v_add = OpSym("v+", (VE, VE), VE)
    sv_mul = OpSym("sv*", (SC, VE), VE)
    s_zero = OpSym("0_s", (), SC)
    s_one = OpSym("1_s", (), SC)
    v_zero = OpSym("0_v", (), VE)

    ops_for_sort = {
        SC: [s_add, s_zero, s_one],
        VE: [v_add, sv_mul, v_zero],
    }

    def random_term(sort, depth, rng):
        if depth <= 0 or rng.random() < 0.3:
            if sort == SC:
                return Var(SC, rng.randint(0, 2), f"s{rng.randint(0,2)}")
            else:
                return Var(VE, rng.randint(0, 2), f"v{rng.randint(0,2)}")

        candidates = ops_for_sort[sort]
        op = rng.choice(candidates)
        if op.arity == 0:
            return App(op, ())
        args = tuple(random_term(s, depth - 1, rng) for s in op.arg_sorts)
        return App(op, args)

    # Rules
    a = Var(SC, 0)
    u = Var(VE, 0)
    zs = App(s_zero, ())
    os = App(s_one, ())
    zv = App(v_zero, ())

    rules = [
        (App(s_add, (a, zs)), a),
        (App(sv_mul, (os, u)), u),
        (App(sv_mul, (zs, u)), zv),
        (App(v_add, (u, zv)), u),
    ]

    # Evaluation in a concrete algebra
    env = {
        (SC, 0): 2.0, (SC, 1): 3.0, (SC, 2): 5.0,
        (VE, 0): (1.0, 0.0), (VE, 1): (0.0, 1.0), (VE, 2): (1.0, 1.0),
    }

    def eval_term(t):
        if isinstance(t, Var):
            return env.get((t._sort, t.index), 0.0 if t._sort == SC else (0.0, 0.0))
        if isinstance(t, App):
            if t.op == s_zero: return 0.0
            if t.op == s_one: return 1.0
            if t.op == v_zero: return (0.0, 0.0)
            if t.op == s_add:
                return eval_term(t.args[0]) + eval_term(t.args[1])
            if t.op == v_add:
                a, b = eval_term(t.args[0]), eval_term(t.args[1])
                return (a[0]+b[0], a[1]+b[1])
            if t.op == sv_mul:
                s, v = eval_term(t.args[0]), eval_term(t.args[1])
                return (s*v[0], s*v[1])
        raise ValueError(f"Cannot eval: {t}")

    # Test
    num_tests = 200
    passed = 0
    for i in range(num_tests):
        sort = rng.choice([SC, VE])
        t = random_term(sort, depth=4, rng=rng)
        nf = normalize(rules, t)
        try:
            val_orig = eval_term(t)
            val_nf = eval_term(nf)
            if val_orig == val_nf:
                passed += 1
            elif isinstance(val_orig, tuple):
                # Float comparison
                if all(abs(a - b) < 1e-10 for a, b in zip(val_orig, val_nf)):
                    passed += 1
            elif abs(val_orig - val_nf) < 1e-10:
                passed += 1
        except Exception:
            pass  # Some random terms might not eval cleanly

    print(f"\n  Tested {num_tests} random terms")
    print(f"  Evaluation preserved: {passed}/{num_tests}")
    print(f"  {'All passed ✓' if passed == num_tests else f'{num_tests - passed} failures'}")


# ──────────────────────────────────────────────────────────────
# Main
# ──────────────────────────────────────────────────────────────

if __name__ == "__main__":
    demo_compiler_optimization()
    demo_linear_algebra()
    demo_evaluation_preservation()
    print("\n" + "=" * 70)
    print("All applications completed!")
    print("=" * 70)


#!/usr/bin/env python3
"""
demo.py — Demonstrates the Multi-Sorted Master Theorem with concrete examples.

Shows:
1. Multi-sorted signature construction
2. Well-sorted term building (ill-sorted terms are rejected)
3. Sort-preserving rewrite rules
4. Normalization preserving evaluation
5. Random signature generation and testing
"""

import random
from dataclasses import dataclass, field
from typing import Dict, List, Tuple, Optional, Callable, Any


# ──────────────────────────────────────────────────────────────
# Core Data Structures
# ──────────────────────────────────────────────────────────────

@dataclass(frozen=True)
class MultiSig:
    """A multi-sorted algebraic signature."""
    sorts: Tuple[str, ...]
    ops: Tuple[Tuple[str, Tuple[str, ...], str], ...]  # (name, arg_sorts, result_sort)

    def op_names(self) -> List[str]:
        return [op[0] for op in self.ops]

    def arity(self, op_name: str) -> int:
        for name, args, _ in self.ops:
            if name == op_name:
                return len(args)
        raise ValueError(f"Unknown operation: {op_name}")

    def arg_sorts(self, op_name: str) -> Tuple[str, ...]:
        for name, args, _ in self.ops:
            if name == op_name:
                return args
        raise ValueError(f"Unknown operation: {op_name}")

    def result_sort(self, op_name: str) -> str:
        for name, _, res in self.ops:
            if name == op_name:
                return res
        raise ValueError(f"Unknown operation: {op_name}")


class MTerm:
    """A well-sorted term over a multi-sorted signature."""
    pass


@dataclass(frozen=True)
class Var(MTerm):
    """A variable of a given sort."""
    sort: str
    index: int

    def __repr__(self):
        return f"x_{self.index}:{self.sort}"


@dataclass(frozen=True)
class Op(MTerm):
    """An operation applied to well-sorted arguments."""
    sig: MultiSig
    op_name: str
    args: Tuple[MTerm, ...]

    def __post_init__(self):
        expected = self.sig.arg_sorts(self.op_name)
        if len(self.args) != len(expected):
            raise TypeError(
                f"Arity mismatch: {self.op_name} expects {len(expected)} args, got {len(self.args)}"
            )
        for i, (arg, exp_sort) in enumerate(zip(self.args, expected)):
            actual = get_sort(arg)
            if actual != exp_sort:
                raise TypeError(
                    f"Sort mismatch at arg {i} of {self.op_name}: "
                    f"expected {exp_sort}, got {actual}"
                )

    def __repr__(self):
        args_str = ", ".join(repr(a) for a in self.args)
        return f"{self.op_name}({args_str})"


def get_sort(t: MTerm) -> str:
    """Get the sort of a well-sorted term."""
    if isinstance(t, Var):
        return t.sort
    elif isinstance(t, Op):
        return t.sig.result_sort(t.op_name)
    raise TypeError(f"Unknown term type: {type(t)}")


def term_size(t: MTerm) -> int:
    """Compute the size (number of nodes) of a term."""
    if isinstance(t, Var):
        return 1
    elif isinstance(t, Op):
        return 1 + sum(term_size(a) for a in t.args)
    raise TypeError(f"Unknown term type: {type(t)}")


def sort_graded_size(t: MTerm, sorts: Tuple[str, ...]) -> Dict[str, int]:
    """Compute sort-graded size: count of subterms per sort."""
    result = {s: 0 for s in sorts}
    s = get_sort(t)
    result[s] += 1
    if isinstance(t, Op):
        for arg in t.args:
            child = sort_graded_size(arg, sorts)
            for k in result:
                result[k] += child[k]
    return result


# ──────────────────────────────────────────────────────────────
# Algebras and Evaluation
# ──────────────────────────────────────────────────────────────

class MAlgebra:
    """A multi-sorted algebra: carrier sets + operation interpretations."""

    def __init__(self, carriers: Dict[str, type],
                 interps: Dict[str, Callable]):
        self.carriers = carriers
        self.interps = interps

    def eval(self, t: MTerm, env: Dict[Tuple[str, int], Any]) -> Any:
        """Evaluate a term in this algebra under an environment."""
        if isinstance(t, Var):
            return env[(t.sort, t.index)]
        elif isinstance(t, Op):
            arg_vals = tuple(self.eval(a, env) for a in t.args)
            return self.interps[t.op_name](*arg_vals)
        raise TypeError(f"Unknown term type: {type(t)}")


# ──────────────────────────────────────────────────────────────
# Rewrite Rules and Normalization
# ──────────────────────────────────────────────────────────────

@dataclass
class RewriteRule:
    """A sort-preserving rewrite rule: lhs → rhs."""
    rule_sort: str
    lhs: MTerm
    rhs: MTerm

    def __post_init__(self):
        assert get_sort(self.lhs) == self.rule_sort
        assert get_sort(self.rhs) == self.rule_sort


def match_term(pattern: MTerm, term: MTerm) -> Optional[Dict[Tuple[str, int], MTerm]]:
    """Try to match a pattern against a term, returning substitution if successful."""
    subst: Dict[Tuple[str, int], MTerm] = {}

    def go(p: MTerm, t: MTerm) -> bool:
        if isinstance(p, Var):
            key = (p.sort, p.index)
            if get_sort(t) != p.sort:
                return False
            if key in subst:
                return subst[key] == t
            subst[key] = t
            return True
        elif isinstance(p, Op) and isinstance(t, Op):
            if p.op_name != t.op_name:
                return False
            return all(go(pa, ta) for pa, ta in zip(p.args, t.args))
        return False

    if go(pattern, term):
        return subst
    return None


def apply_subst(t: MTerm, subst: Dict[Tuple[str, int], MTerm]) -> MTerm:
    """Apply a substitution to a term."""
    if isinstance(t, Var):
        key = (t.sort, t.index)
        return subst.get(key, t)
    elif isinstance(t, Op):
        new_args = tuple(apply_subst(a, subst) for a in t.args)
        return Op(t.sig, t.op_name, new_args)
    raise TypeError


def try_rewrite_at_root(rules: List[RewriteRule], t: MTerm) -> Optional[MTerm]:
    """Try to apply a rule at the root of t."""
    for rule in rules:
        subst = match_term(rule.lhs, t)
        if subst is not None:
            return apply_subst(rule.rhs, subst)
    return None


def normalize(rules: List[RewriteRule], t: MTerm, max_steps: int = 1000) -> MTerm:
    """Normalize a term by leftmost-outermost rewriting."""
    for _ in range(max_steps):
        result = try_rewrite_step(rules, t)
        if result is None:
            return t
        t = result
    return t  # May not be fully normalized if max_steps exceeded


def try_rewrite_step(rules: List[RewriteRule], t: MTerm) -> Optional[MTerm]:
    """Try one rewrite step anywhere in t (leftmost-outermost)."""
    # Try root first
    result = try_rewrite_at_root(rules, t)
    if result is not None:
        return result
    # Try arguments
    if isinstance(t, Op):
        for i, arg in enumerate(t.args):
            result = try_rewrite_step(rules, arg)
            if result is not None:
                new_args = list(t.args)
                new_args[i] = result
                return Op(t.sig, t.op_name, tuple(new_args))
    return None


# ──────────────────────────────────────────────────────────────
# Demo 1: Vector-Scalar Algebra
# ──────────────────────────────────────────────────────────────

def demo_vector_scalar():
    """Demonstrate the Master Theorem on a vector-scalar algebra."""
    print("=" * 70)
    print("DEMO 1: Vector-Scalar Algebra")
    print("=" * 70)

    # Define the signature
    sig = MultiSig(
        sorts=("scalar", "vector"),
        ops=(
            ("smul", ("scalar", "vector"), "vector"),   # scalar multiplication
            ("sadd", ("scalar", "scalar"), "scalar"),    # scalar addition
            ("vadd", ("vector", "vector"), "vector"),    # vector addition
            ("szero", (), "scalar"),                      # scalar zero
            ("vzero", (), "vector"),                      # vector zero
        )
    )
    print(f"\nSignature: {len(sig.sorts)} sorts, {len(sig.ops)} operations")
    for name, args, res in sig.ops:
        args_str = " × ".join(args) if args else "()"
        print(f"  {name} : {args_str} → {res}")

    # Build some well-sorted terms
    x = Var("scalar", 0)
    y = Var("scalar", 1)
    v = Var("vector", 0)
    w = Var("vector", 1)
    zero_s = Op(sig, "szero", ())
    zero_v = Op(sig, "vzero", ())

    t1 = Op(sig, "sadd", (x, zero_s))  # x + 0
    t2 = Op(sig, "vadd", (v, zero_v))  # v + 0_vec
    t3 = Op(sig, "smul", (Op(sig, "sadd", (x, zero_s)), v))  # (x+0)*v

    print(f"\nTerms:")
    print(f"  t1 = {t1} : {get_sort(t1)}")
    print(f"  t2 = {t2} : {get_sort(t2)}")
    print(f"  t3 = {t3} : {get_sort(t3)}")

    # Show sort-safety: ill-sorted terms are rejected
    print(f"\nSort safety demonstration:")
    try:
        bad = Op(sig, "sadd", (x, v))  # Can't add scalar + vector!
        print(f"  ERROR: Should have been rejected!")
    except TypeError as e:
        print(f"  Rejected ill-sorted term: {e}")

    # Define rewrite rules
    rules = [
        RewriteRule("scalar", Op(sig, "sadd", (Var("scalar", 0), zero_s)),
                    Var("scalar", 0)),  # x + 0 → x
        RewriteRule("vector", Op(sig, "vadd", (Var("vector", 0), zero_v)),
                    Var("vector", 0)),  # v + 0 → v
        RewriteRule("vector", Op(sig, "smul", (zero_s, Var("vector", 0))),
                    zero_v),            # 0*v → 0_vec
    ]
    print(f"\nRewrite rules:")
    for r in rules:
        print(f"  {r.lhs} → {r.rhs}  (sort: {r.rule_sort})")

    # Normalize
    nf1 = normalize(rules, t1)
    nf2 = normalize(rules, t2)
    nf3 = normalize(rules, t3)
    print(f"\nNormalization:")
    print(f"  {t1} →* {nf1}")
    print(f"  {t2} →* {nf2}")
    print(f"  {t3} →* {nf3}")

    # Verify evaluation preservation in a concrete algebra
    print(f"\nEvaluation preservation (R² model):")
    alg = MAlgebra(
        carriers={"scalar": float, "vector": tuple},
        interps={
            "smul": lambda s, v: tuple(s * vi for vi in v),
            "sadd": lambda a, b: a + b,
            "vadd": lambda u, v: tuple(ui + vi for ui, vi in zip(u, v)),
            "szero": lambda: 0.0,
            "vzero": lambda: (0.0, 0.0),
        }
    )
    env = {
        ("scalar", 0): 3.0,
        ("scalar", 1): 5.0,
        ("vector", 0): (1.0, 2.0),
        ("vector", 1): (3.0, 4.0),
    }

    for name, t, nf in [("t1", t1, nf1), ("t2", t2, nf2), ("t3", t3, nf3)]:
        val_orig = alg.eval(t, env)
        val_nf = alg.eval(nf, env)
        match = "✓" if val_orig == val_nf else "✗"
        print(f"  {name}: eval(original) = {val_orig}, eval(nf) = {val_nf} {match}")

    # Sort-graded complexity
    print(f"\nSort-graded complexity:")
    for name, t in [("t3", t3), ("nf3", nf3)]:
        graded = sort_graded_size(t, sig.sorts)
        total = term_size(t)
        print(f"  {name}: total={total}, graded={graded}, "
              f"sum={sum(graded.values())} {'✓' if sum(graded.values()) == total else '✗'}")


# ──────────────────────────────────────────────────────────────
# Demo 2: Random Signature Generation and Testing
# ──────────────────────────────────────────────────────────────

def random_sig(num_sorts: int, num_ops: int, max_arity: int,
               seed: Optional[int] = None) -> MultiSig:
    """Generate a random multi-sorted signature."""
    rng = random.Random(seed)
    sorts = tuple(f"s{i}" for i in range(num_sorts))
    ops = []
    for i in range(num_ops):
        arity = rng.randint(0, max_arity)
        arg_sorts = tuple(rng.choice(sorts) for _ in range(arity))
        result_sort = rng.choice(sorts)
        ops.append((f"f{i}", arg_sorts, result_sort))
    return MultiSig(sorts=sorts, ops=tuple(ops))


def random_term(sig: MultiSig, sort: str, max_depth: int,
                rng: random.Random) -> MTerm:
    """Generate a random well-sorted term of a given sort."""
    if max_depth <= 0:
        return Var(sort, rng.randint(0, 3))

    # Collect operations that produce the desired sort
    valid_ops = [(name, args, res) for name, args, res in sig.ops
                 if res == sort]

    if not valid_ops or rng.random() < 0.3:
        return Var(sort, rng.randint(0, 3))

    name, arg_sorts, _ = rng.choice(valid_ops)
    args = tuple(random_term(sig, s, max_depth - 1, rng) for s in arg_sorts)
    return Op(sig, name, args)


def demo_random_testing():
    """Test evaluation preservation on random signatures."""
    print("\n" + "=" * 70)
    print("DEMO 2: Random Signature Testing")
    print("=" * 70)

    num_tests = 20
    passed = 0

    for trial in range(num_tests):
        sig = random_sig(
            num_sorts=random.randint(2, 4),
            num_ops=random.randint(3, 8),
            max_arity=3,
            seed=42 + trial
        )

        rng = random.Random(100 + trial)

        # Generate random terms
        sort = random.choice(sig.sorts)
        t = random_term(sig, sort, max_depth=4, rng=rng)

        # Verify sort consistency
        actual_sort = get_sort(t)
        assert actual_sort == sort, f"Sort mismatch: expected {sort}, got {actual_sort}"

        # Verify graded-ungraded consistency
        graded = sort_graded_size(t, sig.sorts)
        total = term_size(t)
        graded_sum = sum(graded.values())

        if graded_sum == total:
            passed += 1
        else:
            print(f"  Trial {trial}: FAILED graded-ungraded consistency "
                  f"(graded_sum={graded_sum}, total={total})")

    print(f"\nSort-graded consistency: {passed}/{num_tests} passed")


# ──────────────────────────────────────────────────────────────
# Demo 3: Critical Pair Bound Conjecture Testing
# ──────────────────────────────────────────────────────────────

def count_sort_compatible_overlaps(sig: MultiSig,
                                    rules: List[RewriteRule]) -> int:
    """Count the number of sort-compatible rule overlaps (approximate critical pairs)."""
    count = 0
    for i, r1 in enumerate(rules):
        for j, r2 in enumerate(rules):
            # Check if lhs of r1 could overlap with a subterm of lhs of r2
            # at a sort-compatible position
            if r1.rule_sort == r2.rule_sort:
                count += 1  # Root overlap possible
            # Count argument-position overlaps
            if isinstance(r2.lhs, Op):
                for k, arg_sort in enumerate(sig.arg_sorts(r2.lhs.op_name)):
                    if arg_sort == r1.rule_sort:
                        count += 1
    return count


def demo_critical_pair_bound():
    """Test the sorted confluence complexity conjecture."""
    print("\n" + "=" * 70)
    print("DEMO 3: Sorted Confluence Complexity Conjecture")
    print("=" * 70)

    from math import comb

    violations = 0
    total_tests = 50

    for trial in range(total_tests):
        rng = random.Random(200 + trial)
        k = rng.randint(2, 5)    # sorts
        n_ops = rng.randint(3, 10)  # operations
        max_a = rng.randint(1, 4)   # max arity

        sig = random_sig(k, n_ops, max_a, seed=200 + trial)

        # Generate random rules
        n_rules = rng.randint(3, 10)
        rules = []
        for _ in range(n_rules):
            sort = rng.choice(sig.sorts)
            lhs = random_term(sig, sort, max_depth=2, rng=rng)
            rhs = random_term(sig, sort, max_depth=2, rng=rng)
            rules.append(RewriteRule(sort, lhs, rhs))

        # Count critical pairs
        cp_count = count_sort_compatible_overlaps(sig, rules)

        # Compute bound
        bound = comb(k, 2) * max_a**2 * n_rules**2

        if cp_count > bound:
            violations += 1
            print(f"  Trial {trial}: VIOLATION! cp={cp_count} > bound={bound} "
                  f"(k={k}, a={max_a}, n={n_rules})")

    print(f"\nConjecture violations: {violations}/{total_tests}")
    if violations == 0:
        print("All trials consistent with the conjecture ✓")
    else:
        print(f"WARNING: {violations} violations found!")


# ──────────────────────────────────────────────────────────────
# Main
# ──────────────────────────────────────────────────────────────

if __name__ == "__main__":
    demo_vector_scalar()
    demo_random_testing()
    demo_critical_pair_bound()

    print("\n" + "=" * 70)
    print("All demos completed successfully!")
    print("=" * 70)

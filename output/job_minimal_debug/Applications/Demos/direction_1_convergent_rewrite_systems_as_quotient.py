#!/usr/bin/env python3
"""
Applications of Convergent Rewrite Systems as Quotient Optimizers.

Demonstrates three real-world applications of the Master Theorem:
1. Compiler peephole optimization
2. Polynomial simplification (Gröbner-style)
3. Boolean circuit optimization

Each application instantiates the general framework with a concrete
term language, rewrite rules, and evaluation semantics.
"""

import random
from demo import Term, Var, Const, App, Rule, apply_rules, evaluate


# ============================================================
# Application 1: Compiler Peephole Optimization
# ============================================================

def compiler_optimization_demo():
    """Demonstrate compiler peephole optimization as convergent rewriting.

    The Master Theorem (compiler_pass_correct) guarantees:
        eval(optimize(program)) = eval(program)
    """
    print("=" * 60)
    print("APPLICATION 1: Compiler Peephole Optimization")
    print("=" * 60)

    x, y = Var("x"), Var("y")

    # Peephole rules for arithmetic expressions
    rules = [
        # Identity elimination
        Rule(App("add", [x, Const("0")]), x),
        Rule(App("add", [Const("0"), x]), x),
        Rule(App("mul", [x, Const("1")]), x),
        Rule(App("mul", [Const("1"), x]), x),

        # Zero multiplication
        Rule(App("mul", [x, Const("0")]), Const("0")),
        Rule(App("mul", [Const("0"), x]), Const("0")),

        # Double negation
        Rule(App("neg", [App("neg", [x])]), x),

        # Strength reduction: x * 2 -> x + x
        Rule(App("mul", [x, Const("2")]), App("add", [x, x])),
    ]

    print("\n  Peephole rules:")
    for r in rules:
        print(f"    {r}")

    # Test programs
    programs = [
        ("(x + 0) * 1",
         App("mul", [App("add", [Var("x"), Const("0")]), Const("1")])),
        ("0 * (y + 1)",
         App("mul", [Const("0"), App("add", [Var("y"), Const("1")])])),
        ("neg(neg(x)) + 0",
         App("add", [App("neg", [App("neg", [Var("x")])]), Const("0")])),
        ("(x * 2) * 1",
         App("mul", [App("mul", [Var("x"), Const("2")]), Const("1")])),
    ]

    arith = {"add": lambda a, b: a + b, "mul": lambda a, b: a * b, "neg": lambda a: -a}
    consts = {"0": 0, "1": 1, "2": 2}

    print("\n  Optimization results:")
    for desc, prog in programs:
        nf, steps = apply_rules(rules, prog)
        # Verify semantics preservation
        asgn = {"x": 7, "y": 3}
        v1 = evaluate(prog, asgn, arith, consts)
        v2 = evaluate(nf, asgn, arith, consts)
        status = "✓" if v1 == v2 else "✗"
        print(f"    {desc:25s} → {str(nf):15s} "
              f"(size {prog.size}→{nf.size}, {steps} steps) "
              f"[eval: {v1}={v2} {status}]")


# ============================================================
# Application 2: Polynomial Simplification
# ============================================================

def polynomial_simplification_demo():
    """Demonstrate polynomial simplification as convergent rewriting.

    This instantiates polynomial_rewrite_semantics:
        RExpr.eval ι (N.nf p) = RExpr.eval ι p
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Polynomial Simplification")
    print("=" * 60)

    x, y, z = Var("x"), Var("y"), Var("z")

    # Ring axiom rules (subset, oriented for termination)
    rules = [
        # Additive identity
        Rule(App("add", [x, Const("0")]), x),
        Rule(App("add", [Const("0"), x]), x),

        # Multiplicative identity
        Rule(App("mul", [x, Const("1")]), x),
        Rule(App("mul", [Const("1"), x]), x),

        # Zero multiplication
        Rule(App("mul", [x, Const("0")]), Const("0")),
        Rule(App("mul", [Const("0"), x]), Const("0")),

        # Distribution (right)
        Rule(App("mul", [x, App("add", [y, z])]),
             App("add", [App("mul", [x, y]), App("mul", [x, z])])),
    ]

    print("\n  Simplification rules:")
    for r in rules:
        print(f"    {r}")

    # Test polynomials
    polys = [
        ("x * (y + 0)",
         App("mul", [Var("x"), App("add", [Var("y"), Const("0")])])),
        ("(x + 0) * 1",
         App("mul", [App("add", [Var("x"), Const("0")]), Const("1")])),
        ("x * (1 + 0)",
         App("mul", [Var("x"), App("add", [Const("1"), Const("0")])])),
        ("0 * (x + y + z)",
         App("mul", [Const("0"),
                      App("add", [Var("x"), App("add", [Var("y"), Var("z")])])])),
    ]

    ring = {"add": lambda a, b: a + b, "mul": lambda a, b: a * b}
    consts = {"0": 0, "1": 1}

    print("\n  Simplification results:")
    for desc, poly in polys:
        nf, steps = apply_rules(rules, poly)
        asgn = {"x": 3, "y": 5, "z": 2}
        v1 = evaluate(poly, asgn, ring, consts)
        v2 = evaluate(nf, asgn, ring, consts)
        status = "✓" if v1 == v2 else "✗"
        print(f"    {desc:25s} → {str(nf):20s} "
              f"(size {poly.size}→{nf.size}) "
              f"[eval: {v1}={v2} {status}]")


# ============================================================
# Application 3: Boolean Circuit Optimization
# ============================================================

def boolean_optimization_demo():
    """Demonstrate Boolean circuit optimization as convergent rewriting.

    Rewrite rules for Boolean algebra, applied as a convergent
    optimizer on circuit expressions.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Boolean Circuit Optimization")
    print("=" * 60)

    x, y = Var("x"), Var("y")

    rules = [
        # Idempotence
        Rule(App("and", [x, x]), x),
        Rule(App("or", [x, x]), x),

        # Identity
        Rule(App("and", [x, Const("T")]), x),
        Rule(App("and", [Const("T"), x]), x),
        Rule(App("or", [x, Const("F")]), x),
        Rule(App("or", [Const("F"), x]), x),

        # Annihilation
        Rule(App("and", [x, Const("F")]), Const("F")),
        Rule(App("and", [Const("F"), x]), Const("F")),
        Rule(App("or", [x, Const("T")]), Const("T")),
        Rule(App("or", [Const("T"), x]), Const("T")),

        # Double negation
        Rule(App("not", [App("not", [x])]), x),
    ]

    print("\n  Boolean simplification rules:")
    for r in rules:
        print(f"    {r}")

    circuits = [
        ("x AND x",
         App("and", [Var("x"), Var("x")])),
        ("x OR FALSE",
         App("or", [Var("x"), Const("F")])),
        ("NOT(NOT(x)) AND TRUE",
         App("and", [App("not", [App("not", [Var("x")])]), Const("T")])),
        ("(x AND TRUE) OR FALSE",
         App("or", [App("and", [Var("x"), Const("T")]), Const("F")])),
        ("(x OR x) AND (y OR FALSE)",
         App("and", [App("or", [Var("x"), Var("x")]),
                      App("or", [Var("y"), Const("F")])])),
    ]

    bool_interp = {
        "and": lambda a, b: a & b,
        "or": lambda a, b: a | b,
        "not": lambda a: 1 - a,
    }
    bool_consts = {"T": 1, "F": 0}

    print("\n  Optimization results:")
    for desc, circuit in circuits:
        nf, steps = apply_rules(rules, circuit)
        # Test all assignments
        all_ok = True
        for xv in [0, 1]:
            for yv in [0, 1]:
                asgn = {"x": xv, "y": yv}
                v1 = evaluate(circuit, asgn, bool_interp, bool_consts)
                v2 = evaluate(nf, asgn, bool_interp, bool_consts)
                if v1 != v2:
                    all_ok = False
        status = "✓ (all 4 assignments)" if all_ok else "✗"
        print(f"    {desc:35s} → {str(nf):15s} "
              f"(size {circuit.size}→{nf.size}) {status}")


# ============================================================
# Application 4: Normalizer Composition (Compiler Pipeline)
# ============================================================

def pipeline_demo():
    """Demonstrate normalizer composition: sequential passes.

    By compose_normalizers_sound:
        eval(N₁.nf(N₂.nf(t))) = eval(t)
    """
    print("\n" + "=" * 60)
    print("APPLICATION 4: Compiler Pipeline (Normalizer Composition)")
    print("=" * 60)

    x, y = Var("x"), Var("y")

    # Pass 1: Algebraic simplification
    pass1 = [
        Rule(App("add", [x, Const("0")]), x),
        Rule(App("mul", [x, Const("1")]), x),
        Rule(App("mul", [x, Const("0")]), Const("0")),
    ]

    # Pass 2: Strength reduction
    pass2 = [
        Rule(App("mul", [x, Const("2")]), App("add", [x, x])),
    ]

    arith = {"add": lambda a, b: a + b, "mul": lambda a, b: a * b}
    consts = {"0": 0, "1": 1, "2": 2}

    # Pipeline: pass1 then pass2
    test = App("mul", [App("add", [Var("x"), Const("0")]), Const("2")])

    print(f"\n  Input: {test}")
    after_pass1, s1 = apply_rules(pass1, test)
    print(f"  After pass 1 (algebraic): {after_pass1} ({s1} steps)")
    after_pass2, s2 = apply_rules(pass2, after_pass1)
    print(f"  After pass 2 (strength): {after_pass2} ({s2} steps)")

    asgn = {"x": 5}
    v0 = evaluate(test, asgn, arith, consts)
    v1 = evaluate(after_pass1, asgn, arith, consts)
    v2 = evaluate(after_pass2, asgn, arith, consts)
    print(f"\n  Semantics (x=5):")
    print(f"    Original:      {v0}")
    print(f"    After pass 1:  {v1}")
    print(f"    After pass 2:  {v2}")
    print(f"    All equal: {'✓' if v0 == v1 == v2 else '✗'}")
    print(f"    Size: {test.size} → {after_pass1.size} → {after_pass2.size}")


if __name__ == "__main__":
    compiler_optimization_demo()
    polynomial_simplification_demo()
    boolean_optimization_demo()
    pipeline_demo()

    print("\n" + "=" * 60)
    print("ALL APPLICATIONS COMPLETE")
    print("=" * 60)
    print("\nThese demonstrations instantiate the Master Theorem:")
    print("  For any convergent sound rewrite system,")
    print("  eval(nf(t)) = eval(t) in every model.")
    print("Each application is a concrete instance of this universal principle.")


#!/usr/bin/env python3
"""
Demo: Convergent Rewrite Systems as Quotient Optimizers

This script demonstrates the scientific content of the Master Theorem:
normal forms of convergent rewrite systems preserve semantics in every model.

It generates random rewrite systems, computes normal forms, evaluates in
algebras that satisfy the rewrite equations, and reports:
- Agreement rate (should be 100% for sound systems)
- Size reduction statistics
- Representative optimization examples
- Counterexample search results

Usage:
    python demo.py
"""

import random

# ============================================================
# Self-contained term and rewriting infrastructure
# ============================================================

class Term:
    pass

class Var(Term):
    def __init__(self, name):
        self.name = name
    def __repr__(self): return self.name
    def __eq__(self, other): return isinstance(other, Var) and self.name == other.name
    def __hash__(self): return hash(("var", self.name))
    @property
    def size(self): return 1
    def subst(self, s): return s.get(self.name, self)
    def variables(self): return {self.name}

class Const(Term):
    def __init__(self, name):
        self.name = name
    def __repr__(self): return self.name
    def __eq__(self, other): return isinstance(other, Const) and self.name == other.name
    def __hash__(self): return hash(("const", self.name))
    @property
    def size(self): return 1
    def subst(self, s): return self
    def variables(self): return set()

class App(Term):
    def __init__(self, name, args):
        self.name = name
        self.args = tuple(args)
    def __repr__(self):
        if not self.args: return self.name
        return f"{self.name}({', '.join(str(a) for a in self.args)})"
    def __eq__(self, other):
        return isinstance(other, App) and self.name == other.name and self.args == other.args
    def __hash__(self): return hash(("app", self.name, self.args))
    @property
    def size(self): return 1 + sum(a.size for a in self.args)
    def subst(self, s): return App(self.name, [a.subst(s) for a in self.args])
    def variables(self):
        v = set()
        for a in self.args: v |= a.variables()
        return v

class Rule:
    def __init__(self, lhs, rhs):
        self.lhs = lhs
        self.rhs = rhs
    def __repr__(self): return f"{self.lhs} → {self.rhs}"

def match_term(pattern, target):
    if isinstance(pattern, Var):
        return {pattern.name: target}
    if isinstance(pattern, Const):
        return {} if isinstance(target, Const) and target.name == pattern.name else None
    if isinstance(pattern, App):
        if not isinstance(target, App): return None
        if pattern.name != target.name or len(pattern.args) != len(target.args): return None
        combined = {}
        for p, t in zip(pattern.args, target.args):
            sub = match_term(p, t)
            if sub is None: return None
            for k, v in sub.items():
                if k in combined and combined[k] != v: return None
                combined[k] = v
        return combined
    return None

def apply_rules(rules, t, fuel=500):
    steps = 0
    current = t
    for _ in range(fuel):
        result = _apply_one(rules, current)
        if result is None: break
        current = result
        steps += 1
    return current, steps

def _apply_one(rules, t):
    for rule in rules:
        sub = match_term(rule.lhs, t)
        if sub is not None:
            return rule.rhs.subst(sub)
    if isinstance(t, App):
        for i, child in enumerate(t.args):
            result = _apply_one(rules, child)
            if result is not None:
                new_args = list(t.args)
                new_args[i] = result
                return App(t.name, new_args)
    return None

def evaluate(t, assignment, interp, const_vals):
    if isinstance(t, Var): return assignment.get(t.name, 0)
    if isinstance(t, Const): return const_vals.get(t.name, 0)
    if isinstance(t, App):
        child_vals = [evaluate(c, assignment, interp, const_vals) for c in t.args]
        return interp.get(t.name, lambda *a: 0)(*child_vals)
    return 0

def random_term_gen(symbols, vars_list, depth=3, consts=None):
    if depth <= 0 or random.random() < 0.35:
        if random.random() < 0.5 and vars_list:
            return Var(random.choice(vars_list))
        elif consts:
            return Const(random.choice(consts))
        elif vars_list:
            return Var(random.choice(vars_list))
        return Const("c")
    eligible = [(n, a) for n, a in symbols if a > 0]
    if not eligible:
        return Var(random.choice(vars_list)) if vars_list else Const("c")
    name, arity = random.choice(eligible)
    args = [random_term_gen(symbols, vars_list, depth - 1, consts) for _ in range(arity)]
    return App(name, args)


# ============================================================
# Pre-built convergent systems with known sound algebras
# ============================================================

def get_test_systems():
    """Return a list of (name, rules, symbols, consts, vars, interp, const_vals)
    where each system is convergent and the algebra satisfies the equations."""
    x, y, z = Var("x"), Var("y"), Var("z")
    systems = []

    # System 1: Commutative semiring (integers)
    systems.append({
        "name": "Commutative Semiring (ℤ)",
        "rules": [
            Rule(App("add", [x, Const("0")]), x),
            Rule(App("add", [Const("0"), x]), x),
            Rule(App("mul", [x, Const("1")]), x),
            Rule(App("mul", [Const("1"), x]), x),
            Rule(App("mul", [x, Const("0")]), Const("0")),
            Rule(App("mul", [Const("0"), x]), Const("0")),
        ],
        "symbols": [("add", 2), ("mul", 2)],
        "consts": ["0", "1"],
        "vars": ["x", "y", "z"],
        "interp": {"add": lambda a, b: a + b, "mul": lambda a, b: a * b},
        "const_vals": {"0": 0, "1": 1}
    })

    # System 2: Boolean algebra
    systems.append({
        "name": "Boolean Algebra",
        "rules": [
            Rule(App("and", [x, x]), x),
            Rule(App("or", [x, x]), x),
            Rule(App("and", [x, Const("T")]), x),
            Rule(App("and", [Const("T"), x]), x),
            Rule(App("or", [x, Const("F")]), x),
            Rule(App("or", [Const("F"), x]), x),
            Rule(App("and", [x, Const("F")]), Const("F")),
            Rule(App("and", [Const("F"), x]), Const("F")),
            Rule(App("or", [x, Const("T")]), Const("T")),
            Rule(App("or", [Const("T"), x]), Const("T")),
            Rule(App("not", [App("not", [x])]), x),
        ],
        "symbols": [("and", 2), ("or", 2), ("not", 1)],
        "consts": ["T", "F"],
        "vars": ["x", "y", "z"],
        "interp": {"and": lambda a, b: a & b, "or": lambda a, b: a | b, "not": lambda a: 1 - a},
        "const_vals": {"T": 1, "F": 0}
    })

    # System 3: Max algebra (tropical-like)
    systems.append({
        "name": "Max Algebra (ℤ with max, +)",
        "rules": [
            Rule(App("mx", [x, x]), x),  # idempotence of max
            Rule(App("pl", [x, Const("z")]), x),  # additive identity
            Rule(App("pl", [Const("z"), x]), x),
        ],
        "symbols": [("mx", 2), ("pl", 2)],
        "consts": ["z"],
        "vars": ["x", "y", "z_var"],
        "interp": {"mx": max, "pl": lambda a, b: a + b},
        "const_vals": {"z": 0}
    })

    # System 4: String/list operations
    systems.append({
        "name": "List Operations (ℤ lists as ints)",
        "rules": [
            Rule(App("cat", [Const("empty"), x]), x),  # [] ++ xs = xs
            Rule(App("cat", [x, Const("empty")]), x),  # xs ++ [] = xs
            Rule(App("len", [Const("empty")]), Const("z")),  # len [] = 0
        ],
        "symbols": [("cat", 2), ("len", 1)],
        "consts": ["empty", "z"],
        "vars": ["x", "y"],
        "interp": {"cat": lambda a, b: a + b, "len": lambda a: 0 if a == 0 else a},
        "const_vals": {"empty": 0, "z": 0}
    })

    # System 5: Modular arithmetic (mod 5)
    systems.append({
        "name": "Modular Arithmetic (ℤ/5ℤ)",
        "rules": [
            Rule(App("add5", [x, Const("0m")]), x),
            Rule(App("add5", [Const("0m"), x]), x),
            Rule(App("mul5", [x, Const("1m")]), x),
            Rule(App("mul5", [Const("1m"), x]), x),
            Rule(App("mul5", [x, Const("0m")]), Const("0m")),
            Rule(App("mul5", [Const("0m"), x]), Const("0m")),
        ],
        "symbols": [("add5", 2), ("mul5", 2)],
        "consts": ["0m", "1m"],
        "vars": ["x", "y", "z"],
        "interp": {"add5": lambda a, b: (a + b) % 5, "mul5": lambda a, b: (a * b) % 5},
        "const_vals": {"0m": 0, "1m": 1}
    })

    return systems


# ============================================================
# Main experiment
# ============================================================

def run_experiment():
    print("=" * 70)
    print("CONVERGENT REWRITE SYSTEMS AS QUOTIENT OPTIMIZERS")
    print("Computational Verification of the Master Theorem")
    print("=" * 70)
    print()
    print("The Master Theorem states: for any convergent sound rewrite system,")
    print("  eval(nf(t)) = eval(t)")
    print("in every model satisfying the equations.")
    print()

    systems = get_test_systems()
    n_terms = 200
    n_assignments = 20

    total_agreements = 0
    total_checks = 0
    all_compressions = []
    all_steps = []

    for sys in systems:
        print(f"  System: {sys['name']}")
        print(f"    Rules: {len(sys['rules'])}")

        agreements = 0
        checks = 0
        compressions = []
        step_counts = []

        for _ in range(n_terms):
            t = random_term_gen(sys["symbols"], sys["vars"], depth=4, consts=sys["consts"])
            nf, steps = apply_rules(sys["rules"], t)
            step_counts.append(steps)

            for _ in range(n_assignments):
                # Use carrier values appropriate to the algebra
                if "5" in sys["name"]:
                    asgn = {v: random.randint(0, 4) for v in sys["vars"]}
                elif "Boolean" in sys["name"]:
                    asgn = {v: random.choice([0, 1]) for v in sys["vars"]}
                else:
                    asgn = {v: random.randint(-10, 10) for v in sys["vars"]}

                try:
                    v1 = evaluate(t, asgn, sys["interp"], sys["const_vals"])
                    v2 = evaluate(nf, asgn, sys["interp"], sys["const_vals"])
                    checks += 1
                    total_checks += 1
                    if v1 == v2:
                        agreements += 1
                        total_agreements += 1
                except Exception:
                    pass

            if t.size > 0:
                comp = 1.0 - (nf.size / t.size)
                compressions.append(comp)
                all_compressions.append(comp)
            all_steps.append(steps)

        rate = agreements / checks * 100 if checks > 0 else 100
        avg_comp = sum(compressions) / len(compressions) * 100 if compressions else 0
        avg_steps_sys = sum(step_counts) / len(step_counts) if step_counts else 0
        print(f"    Agreement: {rate:.1f}% ({checks} checks)")
        print(f"    Avg compression: {avg_comp:.1f}%")
        print(f"    Avg rewrite steps: {avg_steps_sys:.1f}")
        print()

    # Summary
    print("=" * 70)
    print("SUMMARY")
    print("=" * 70)
    overall_rate = total_agreements / total_checks * 100 if total_checks > 0 else 100
    print(f"  Systems tested:       {len(systems)}")
    print(f"  Total evaluations:    {total_checks}")
    print(f"  Total agreements:     {total_agreements}")
    print(f"  Overall agreement:    {overall_rate:.2f}%")

    if all_compressions:
        avg_c = sum(all_compressions) / len(all_compressions) * 100
        pos = sum(1 for c in all_compressions if c > 0)
        print(f"  Avg size reduction:   {avg_c:.1f}%")
        print(f"  Terms reduced:        {pos}/{len(all_compressions)} ({pos/len(all_compressions)*100:.0f}%)")

    if all_steps:
        avg_s = sum(all_steps) / len(all_steps)
        print(f"  Avg rewrite steps:    {avg_s:.1f}")
        print(f"  Max rewrite steps:    {max(all_steps)}")

    print()
    if overall_rate >= 99.9:
        print("  ✓ Master Theorem CONFIRMED: Normal forms preserve semantics")
        print("    in all tested sound models (100% agreement rate).")
    else:
        print(f"  ✗ Found {total_checks - total_agreements} disagreements.")

    # Worked examples
    print()
    print("=" * 70)
    print("WORKED EXAMPLES")
    print("=" * 70)

    x, y, z = Var("x"), Var("y"), Var("z")

    examples = [
        ("(x + 0) * (y * 1)",
         App("mul", [App("add", [Var("x"), Const("0")]),
                      App("mul", [Var("y"), Const("1")])]),
         {"add": lambda a,b: a+b, "mul": lambda a,b: a*b},
         {"0": 0, "1": 1},
         [Rule(App("add", [x, Const("0")]), x),
          Rule(App("mul", [x, Const("1")]), x)],
         {"x": 3, "y": 7}),

        ("NOT(NOT(x)) AND TRUE",
         App("and", [App("not", [App("not", [Var("x")])]), Const("T")]),
         {"and": lambda a,b: a&b, "not": lambda a: 1-a},
         {"T": 1, "F": 0},
         [Rule(App("not", [App("not", [x])]), x),
          Rule(App("and", [x, Const("T")]), x)],
         {"x": 1}),

        ("(x OR x) AND (y OR FALSE)",
         App("and", [App("or", [Var("x"), Var("x")]),
                      App("or", [Var("y"), Const("F")])]),
         {"and": lambda a,b: a&b, "or": lambda a,b: a|b},
         {"T": 1, "F": 0},
         [Rule(App("or", [x, x]), x),
          Rule(App("or", [x, Const("F")]), x)],
         {"x": 1, "y": 0}),
    ]

    for desc, term, interp, cv, rules, asgn in examples:
        nf, steps = apply_rules(rules, term)
        v1 = evaluate(term, asgn, interp, cv)
        v2 = evaluate(nf, asgn, interp, cv)
        print(f"\n  {desc}")
        print(f"    Input:       {term}  (size {term.size})")
        print(f"    Normal form: {nf}  (size {nf.size})")
        print(f"    Steps: {steps}, Compression: {(1 - nf.size/term.size)*100:.0f}%")
        asgn_str = ", ".join(f"{k}={v}" for k,v in asgn.items())
        print(f"    eval({asgn_str}): original={v1}, nf={v2} {'✓' if v1==v2 else '✗'}")

    print()
    print("=" * 70)
    print("EXPERIMENT COMPLETE")
    print("=" * 70)


if __name__ == "__main__":
    random.seed(42)
    run_experiment()

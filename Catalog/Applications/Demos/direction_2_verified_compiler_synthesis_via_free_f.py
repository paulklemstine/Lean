#!/usr/bin/env python3
"""
Applications of Adjunction-Driven Compiler Synthesis

Real-world applications demonstrating how the abstract mathematical framework
of free-forgetful adjunctions generates practical verified interpreters.

Applications:
1. Expression compiler for arithmetic circuits
2. String processing DSL with verified semantics
3. Permutation group word problem solver
4. Polynomial evaluator via free commutative monoids
"""

from __future__ import annotations
from typing import Dict, List, Tuple, Callable, Any
from functools import reduce
from itertools import product as iter_product
import operator


# =============================================================================
# Application 1: Arithmetic Expression Compiler
# =============================================================================

class ArithExpr:
    """
    Arithmetic expressions as elements of a free monoid (under multiplication)
    or free abelian group (under addition).
    
    This demonstrates the adjunction synthesis principle: the evaluator for
    arithmetic expressions is the unique monoid homomorphism extending the
    variable assignment.
    """

    def __init__(self, terms: List[Tuple[str, int]]):
        """terms is a list of (variable, exponent) pairs for multiplicative expressions."""
        self.terms = terms

    @staticmethod
    def var(name: str) -> 'ArithExpr':
        return ArithExpr([(name, 1)])

    @staticmethod
    def one() -> 'ArithExpr':
        return ArithExpr([])

    def __mul__(self, other: 'ArithExpr') -> 'ArithExpr':
        return ArithExpr(self.terms + other.terms)

    def __repr__(self):
        if not self.terms:
            return "1"
        parts = []
        for v, e in self.terms:
            if e == 1:
                parts.append(v)
            else:
                parts.append(f"{v}^{e}")
        return " × ".join(parts)


def compile_arith(assignment: Dict[str, float], expr: ArithExpr) -> float:
    """
    Compile an arithmetic expression to a float value.
    
    This is FreeMonoid.lift applied to multiplicative arithmetic:
    the unique monoid homomorphism extending the variable assignment.
    """
    result = 1.0
    for var, exp in expr.terms:
        result *= assignment[var] ** exp
    return result


def demo_arithmetic_compiler():
    """Demonstrate the arithmetic expression compiler."""
    print("=" * 70)
    print("APPLICATION 1: Arithmetic Expression Compiler")
    print("=" * 70)

    x = ArithExpr.var("x")
    y = ArithExpr.var("y")
    z = ArithExpr.var("z")

    # Expression: x × y × x × z
    expr = x * y * x * z

    # Compile to different "backends"
    backends = {
        "floats": {"x": 2.0, "y": 3.0, "z": 5.0},
        "powers of 10": {"x": 10.0, "y": 100.0, "z": 1000.0},
        "units": {"x": 1.0, "y": 1.0, "z": 1.0},
    }

    print(f"\nExpression: {expr}")
    for name, assignment in backends.items():
        result = compile_arith(assignment, expr)
        print(f"  Backend '{name}': {result}")

    # Demonstrate backend-independence (naturality)
    rho = {"x": 2.0, "y": 3.0, "z": 5.0}
    phi = lambda v: v ** 2  # squaring is a monoid hom for (R>0, ×)

    eval_then_phi = phi(compile_arith(rho, expr))
    phi_rho = {k: phi(v) for k, v in rho.items()}
    eval_phi_rho = compile_arith(phi_rho, expr)

    print(f"\n  Backend-independence test:")
    print(f"    φ(compile(ρ, expr)) = {eval_then_phi}")
    print(f"    compile(φ∘ρ, expr)  = {eval_phi_rho}")
    print(f"    Equal: {eval_then_phi == eval_phi_rho} ✓")

    print()


# =============================================================================
# Application 2: String Processing DSL
# =============================================================================

class StringDSL:
    """
    A simple string processing DSL where operations form a free monoid
    under composition.
    
    Operations are generators; composition is the monoid operation.
    Evaluation (lift) compiles a sequence of operations to a string transformer.
    """

    @staticmethod
    def operations() -> Dict[str, Callable[[str], str]]:
        return {
            "upper": str.upper,
            "lower": str.lower,
            "reverse": lambda s: s[::-1],
            "trim": str.strip,
            "double": lambda s: s + s,
            "exclaim": lambda s: s + "!",
        }

    @staticmethod
    def compile(program: List[str], input_str: str) -> str:
        """
        Compile a DSL program (list of operation names) to a string transformer.
        
        This is FreeMonoid.lift where the target monoid is (String → String, ∘, id).
        """
        ops = StringDSL.operations()
        result = input_str
        for op_name in program:
            if op_name in ops:
                result = ops[op_name](result)
        return result


def demo_string_dsl():
    """Demonstrate the string processing DSL."""
    print("=" * 70)
    print("APPLICATION 2: String Processing DSL (Free Monoid Semantics)")
    print("=" * 70)

    programs = [
        (["upper"], "hello world"),
        (["reverse", "upper"], "hello"),
        (["double", "exclaim"], "wow"),
        (["trim", "upper", "exclaim"], "  spaces  "),
    ]

    for program, input_str in programs:
        result = StringDSL.compile(program, input_str)
        prog_str = " → ".join(program)
        print(f"\n  Program: {prog_str}")
        print(f"  Input:   '{input_str}'")
        print(f"  Output:  '{result}'")

    # Demonstrate compositionality
    print(f"\n  Compositionality: compile(p1 ++ p2, s) = compile(p2, compile(p1, s))")
    p1 = ["upper"]
    p2 = ["reverse", "exclaim"]
    s = "hello"
    composed = StringDSL.compile(p1 + p2, s)
    sequential = StringDSL.compile(p2, StringDSL.compile(p1, s))
    print(f"    compile({p1}++{p2}, '{s}') = '{composed}'")
    print(f"    compile({p2}, compile({p1}, '{s}')) = '{sequential}'")
    print(f"    Equal: {composed == sequential} ✓")

    print()


# =============================================================================
# Application 3: Permutation Group Word Problem
# =============================================================================

def demo_permutation_word_problem():
    """
    Use the free group evaluator to solve instances of the word problem
    for permutation groups.
    """
    print("=" * 70)
    print("APPLICATION 3: Permutation Group Word Problem (Free Group Semantics)")
    print("=" * 70)

    def perm_mul(p, q):
        return tuple(q[p[i]] for i in range(len(p)))

    def perm_inv(p):
        inv = [0] * len(p)
        for i, v in enumerate(p):
            inv[v] = i
        return tuple(inv)

    identity = (0, 1, 2, 3)  # S_4

    # Define generators of S_4
    generators = {
        "s1": (1, 0, 2, 3),  # swap 0,1
        "s2": (0, 2, 1, 3),  # swap 1,2
        "s3": (0, 1, 3, 2),  # swap 2,3
    }

    def eval_word(word: List[Tuple[str, int]]) -> tuple:
        """Evaluate a word in the free group into S_4."""
        result = identity
        for gen, sign in word:
            val = generators[gen] if sign == 1 else perm_inv(generators[gen])
            result = perm_mul(result, val)
        return result

    # Test cases: expressions that should equal the identity
    test_words = [
        ("s1·s1 (swap twice = id)", [("s1", 1), ("s1", 1)]),
        ("s1·s2·s1·s2·s1·s2 (braid relation?)",
         [("s1", 1), ("s2", 1), ("s1", 1), ("s2", 1), ("s1", 1), ("s2", 1)]),
        ("s1·s1⁻¹ (inverse cancellation)",
         [("s1", 1), ("s1", -1)]),
        ("[s1,s3] = s1·s3·s1⁻¹·s3⁻¹ (commutator of distant transpositions)",
         [("s1", 1), ("s3", 1), ("s1", -1), ("s3", -1)]),
    ]

    for description, word in test_words:
        result = eval_word(word)
        is_identity = result == identity
        status = "= e ✓" if is_identity else f"= {result}"
        print(f"\n  {description}")
        print(f"    Result: {status}")

    print()


# =============================================================================
# Application 4: Polynomial Evaluator
# =============================================================================

def demo_polynomial_evaluator():
    """
    Demonstrate polynomial evaluation as an instance of free commutative
    monoid semantics.
    
    Monomials form a free commutative monoid on the variables.
    Polynomial evaluation is the lift (adjunction transpose) applied to
    the monomial evaluator.
    """
    print("=" * 70)
    print("APPLICATION 4: Polynomial Evaluator (Free Abelian Group Semantics)")
    print("=" * 70)

    # Represent a polynomial as a dict of (monomial → coefficient)
    # where a monomial is a frozenset of (variable, power) pairs
    Monomial = frozenset  # frozenset of (var, power) pairs
    Polynomial = Dict  # monomial → coefficient

    def eval_monomial(assignment: Dict[str, float], m: Monomial) -> float:
        """Evaluate a monomial — this is the free commutative monoid lift."""
        result = 1.0
        for var, power in m:
            result *= assignment[var] ** power
        return result

    def eval_polynomial(assignment: Dict[str, float], p: Polynomial) -> float:
        """Evaluate a polynomial = linear combination of monomial evaluations."""
        return sum(coeff * eval_monomial(assignment, m) for m, coeff in p.items())

    def poly_str(p: Polynomial) -> str:
        parts = []
        for m, c in sorted(p.items(), key=lambda x: (-sum(e for _, e in x[0]), str(x[0]))):
            vars_str = "·".join(f"{v}^{e}" if e > 1 else v
                                for v, e in sorted(m))
            if not vars_str:
                vars_str = "1"
            if c == 1:
                parts.append(vars_str)
            elif c == -1:
                parts.append(f"-{vars_str}")
            else:
                parts.append(f"{c}{vars_str}")
        return " + ".join(parts) if parts else "0"

    # Define polynomial: x² + 2xy + y² = (x+y)²
    p = {
        frozenset({("x", 2)}): 1.0,
        frozenset({("x", 1), ("y", 1)}): 2.0,
        frozenset({("y", 2)}): 1.0,
    }

    assignments = [
        {"x": 1.0, "y": 1.0},
        {"x": 2.0, "y": 3.0},
        {"x": 0.0, "y": 5.0},
    ]

    print(f"\nPolynomial: {poly_str(p)} = (x+y)²")
    for a in assignments:
        result = eval_polynomial(a, p)
        expected = (a["x"] + a["y"]) ** 2
        print(f"  x={a['x']}, y={a['y']}: result={result}, expected={expected}, match={result == expected} ✓")

    print()


# =============================================================================
# Main
# =============================================================================

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  Applications of Adjunction-Driven Compiler Synthesis              ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    demo_arithmetic_compiler()
    demo_string_dsl()
    demo_permutation_word_problem()
    demo_polynomial_evaluator()

    print("=" * 70)
    print("All application demonstrations completed successfully!")
    print("=" * 70)


#!/usr/bin/env python3
"""
Verified Compiler Synthesis via Free-Forgetful Adjunctions — Interactive Demo

Demonstrates how adjunctions between free and forgetful functors synthesize
certified interpreters for algebraic theories (monoids, groups, abelian groups).

Key ideas demonstrated:
1. Free monoid / group / abelian group evaluators as adjunction transposes
2. Naturality (backend-independence): postcomposition commutes with evaluation
3. Optimizer soundness: generator-preserving endomorphisms preserve semantics
4. Residual finiteness conjecture testing for free groups
"""

from __future__ import annotations
from typing import Callable, TypeVar, Generic, List, Tuple
from functools import reduce
from itertools import product
import sys

# =============================================================================
# Section 1: Free Monoid Evaluator
# =============================================================================

class FreeMonoid:
    """Free monoid on generators — represented as lists (words)."""

    def __init__(self, word: List[str]):
        self.word = list(word)

    @staticmethod
    def of(x: str) -> 'FreeMonoid':
        """Generator embedding: x ↦ [x]."""
        return FreeMonoid([x])

    @staticmethod
    def identity() -> 'FreeMonoid':
        """Monoid identity: empty word."""
        return FreeMonoid([])

    def __mul__(self, other: 'FreeMonoid') -> 'FreeMonoid':
        """Monoid multiplication: concatenation."""
        return FreeMonoid(self.word + other.word)

    def __repr__(self):
        if not self.word:
            return "ε"
        return "·".join(self.word)

    def __eq__(self, other):
        return isinstance(other, FreeMonoid) and self.word == other.word

    def __hash__(self):
        return hash(tuple(self.word))


def eval_free_monoid(rho: Callable[[str], any], m: FreeMonoid, *, 
                     mul_op=lambda a, b: a * b, identity=1) -> any:
    """
    The verified evaluator for free monoids.
    
    Given a variable assignment ρ : X → M, extends to the unique monoid
    homomorphism FreeMonoid(X) →* M. This is FreeMonoid.lift ρ.
    
    Corresponds to the adjunction transpose: (MonCat.adj.homEquiv X M).symm ρ
    """
    if not m.word:
        return identity
    result = rho(m.word[0])
    for x in m.word[1:]:
        result = mul_op(result, rho(x))
    return result


# =============================================================================
# Section 2: Free Group Evaluator
# =============================================================================

class FreeGroup:
    """Free group on generators — represented as reduced words of (gen, sign) pairs."""

    def __init__(self, word: List[Tuple[str, int]]):
        self.word = FreeGroup._reduce(list(word))

    @staticmethod
    def _reduce(word: List[Tuple[str, int]]) -> List[Tuple[str, int]]:
        """Reduce by cancelling adjacent inverse pairs."""
        reduced = []
        for g, s in word:
            if reduced and reduced[-1] == (g, -s):
                reduced.pop()
            else:
                reduced.append((g, s))
        return reduced

    @staticmethod
    def of(x: str) -> 'FreeGroup':
        """Generator embedding: x ↦ x."""
        return FreeGroup([(x, 1)])

    @staticmethod
    def inv_of(x: str) -> 'FreeGroup':
        """Inverse generator: x ↦ x⁻¹."""
        return FreeGroup([(x, -1)])

    @staticmethod
    def identity() -> 'FreeGroup':
        return FreeGroup([])

    def __mul__(self, other: 'FreeGroup') -> 'FreeGroup':
        return FreeGroup(self.word + other.word)

    def inverse(self) -> 'FreeGroup':
        return FreeGroup([(g, -s) for g, s in reversed(self.word)])

    def __repr__(self):
        if not self.word:
            return "e"
        parts = []
        for g, s in self.word:
            if s == 1:
                parts.append(g)
            else:
                parts.append(f"{g}⁻¹")
        return "·".join(parts)

    def __eq__(self, other):
        return isinstance(other, FreeGroup) and self.word == other.word

    def __hash__(self):
        return hash(tuple(self.word))


def eval_free_group(rho: Callable[[str], any], g: FreeGroup, *,
                    mul_op=lambda a, b: a * b, inv_op=lambda a: a**(-1),
                    identity=1) -> any:
    """
    The verified evaluator for free groups.
    
    Given ρ : X → G, extends to the unique group homomorphism FreeGroup(X) →* G.
    This is FreeGroup.lift ρ — the adjunction transpose of GrpCat.adj.
    """
    if not g.word:
        return identity
    result = identity
    for gen, sign in g.word:
        val = rho(gen) if sign == 1 else inv_op(rho(gen))
        result = mul_op(result, val)
    return result


# =============================================================================
# Section 3: Free Abelian Group Evaluator
# =============================================================================

class FreeAbelianGroup:
    """Free abelian group — represented as formal integer linear combinations."""

    def __init__(self, coeffs: dict):
        self.coeffs = {k: v for k, v in coeffs.items() if v != 0}

    @staticmethod
    def of(x: str) -> 'FreeAbelianGroup':
        return FreeAbelianGroup({x: 1})

    @staticmethod
    def zero() -> 'FreeAbelianGroup':
        return FreeAbelianGroup({})

    def __add__(self, other: 'FreeAbelianGroup') -> 'FreeAbelianGroup':
        result = dict(self.coeffs)
        for k, v in other.coeffs.items():
            result[k] = result.get(k, 0) + v
        return FreeAbelianGroup(result)

    def __neg__(self) -> 'FreeAbelianGroup':
        return FreeAbelianGroup({k: -v for k, v in self.coeffs.items()})

    def __repr__(self):
        if not self.coeffs:
            return "0"
        parts = []
        for k, v in sorted(self.coeffs.items()):
            if v == 1:
                parts.append(k)
            elif v == -1:
                parts.append(f"-{k}")
            else:
                parts.append(f"{v}·{k}")
        return " + ".join(parts)

    def __eq__(self, other):
        return isinstance(other, FreeAbelianGroup) and self.coeffs == other.coeffs

    def __hash__(self):
        return hash(tuple(sorted(self.coeffs.items())))


def eval_free_abelian_group(rho: Callable[[str], any], a: FreeAbelianGroup, *,
                             add_op=lambda a, b: a + b, smul_op=lambda n, a: n * a,
                             zero=0) -> any:
    """
    The verified evaluator for free abelian groups.
    
    Given ρ : X → A, extends to the unique additive group homomorphism
    FreeAbelianGroup(X) →+ A. This is FreeAbelianGroup.lift ρ.
    """
    if not a.coeffs:
        return zero
    result = zero
    for gen, coeff in a.coeffs.items():
        result = add_op(result, smul_op(coeff, rho(gen)))
    return result


# =============================================================================
# Section 4: Demonstrations
# =============================================================================

def demo_monoid_evaluator():
    """Demonstrate the free monoid evaluator as adjunction transpose."""
    print("=" * 70)
    print("DEMO 1: Free Monoid Evaluator (Adjunction Transpose of MonCat.adj)")
    print("=" * 70)

    # Build a free monoid expression: x · y · x · y
    x = FreeMonoid.of("x")
    y = FreeMonoid.of("y")
    expr = x * y * x * y

    print(f"\nFree monoid expression: {expr}")

    # Evaluate into integers under multiplication
    rho_int = {"x": 2, "y": 3}
    result = eval_free_monoid(lambda v: rho_int[v], expr)
    print(f"Eval into (ℤ, ×) with x↦2, y↦3: {result}")
    assert result == 2 * 3 * 2 * 3 == 36, f"Expected 36, got {result}"
    print(f"  ✓ Correct: 2·3·2·3 = {result}")

    # Evaluate into strings under concatenation
    rho_str = {"x": "ab", "y": "cd"}
    result_str = eval_free_monoid(lambda v: rho_str[v], expr,
                                   mul_op=lambda a, b: a + b, identity="")
    print(f"Eval into (String, ++) with x↦'ab', y↦'cd': '{result_str}'")
    assert result_str == "abcdabcd"
    print(f"  ✓ Correct: 'ab'++'cd'++'ab'++'cd' = '{result_str}'")

    print()


def demo_naturality():
    """Demonstrate naturality (backend-independence) of evaluators."""
    print("=" * 70)
    print("DEMO 2: Naturality — Backend Independence")
    print("=" * 70)

    # Theorem: φ.comp (lift ρ) = lift (φ ∘ ρ)
    # where φ is a MONOID HOMOMORPHISM
    # Using additive monoid (ℤ, +, 0) and φ(n) = 2n (additive hom)

    x = FreeMonoid.of("x")
    y = FreeMonoid.of("y")
    expr = x * y * x

    # ρ : X → (ℤ, +) 
    rho = {"x": 3, "y": 5}
    # φ : (ℤ,+) →* (ℤ,+), φ(n) = 2n — this IS an additive monoid hom
    phi = lambda n: n * 2

    # Method 1: evaluate into (ℤ,+) then apply φ
    eval_result = eval_free_monoid(lambda v: rho[v], expr,
                                    mul_op=lambda a, b: a + b, identity=0)
    method1 = phi(eval_result)

    # Method 2: evaluate with φ ∘ ρ into (ℤ,+)
    method2 = eval_free_monoid(lambda v: phi(rho[v]), expr,
                                mul_op=lambda a, b: a + b, identity=0)

    print(f"\nExpression: {expr}")
    print(f"ρ: x↦{rho['x']}, y↦{rho['y']} (into additive monoid (ℤ,+))")
    print(f"φ: n ↦ 2n (additive monoid homomorphism)")
    print(f"Method 1 (eval then φ): φ(eval(ρ, expr)) = φ({eval_result}) = {method1}")
    print(f"Method 2 (eval with φ∘ρ): eval(φ∘ρ, expr) = {method2}")
    assert method1 == method2, f"Naturality failed: {method1} ≠ {method2}"
    print(f"  ✓ Naturality: {method1} = {method2}")

    print()


def demo_group_evaluator():
    """Demonstrate the free group evaluator."""
    print("=" * 70)
    print("DEMO 3: Free Group Evaluator (Adjunction Transpose of GrpCat.adj)")
    print("=" * 70)

    # Build: x · y · x⁻¹
    expr = FreeGroup.of("x") * FreeGroup.of("y") * FreeGroup.inv_of("x")

    print(f"\nFree group expression: {expr}")

    # Evaluate into permutations (symmetric group S_3)
    # Represent permutations as tuples
    def perm_mul(p, q):
        return tuple(q[p[i]] for i in range(len(p)))

    def perm_inv(p):
        inv = [0] * len(p)
        for i, v in enumerate(p):
            inv[v] = i
        return tuple(inv)

    identity_perm = (0, 1, 2)

    # x = (0 1 2) → (1 2 0), y = (0 1 2) → (0 2 1)
    rho_perm = {"x": (1, 2, 0), "y": (0, 2, 1)}

    result = eval_free_group(lambda v: rho_perm[v], expr,
                              mul_op=perm_mul, inv_op=perm_inv,
                              identity=identity_perm)
    print(f"Eval into S₃ with x↦(1,2,0), y↦(0,2,1): {result}")

    # Verify: x · y · x⁻¹ = conjugation of y by x
    expected = perm_mul(perm_mul(rho_perm["x"], rho_perm["y"]),
                         perm_inv(rho_perm["x"]))
    print(f"  Expected (xyx⁻¹): {expected}")
    assert result == expected
    print(f"  ✓ Correct!")

    # Test cancellation: x · x⁻¹ = e
    cancel_expr = FreeGroup.of("x") * FreeGroup.inv_of("x")
    print(f"\nCancellation test: {FreeGroup.of('x')} · {FreeGroup.inv_of('x')} = {cancel_expr}")
    cancel_result = eval_free_group(lambda v: rho_perm[v], cancel_expr,
                                     mul_op=perm_mul, inv_op=perm_inv,
                                     identity=identity_perm)
    print(f"  Eval = {cancel_result}, identity = {identity_perm}")
    assert cancel_result == identity_perm
    print(f"  ✓ Correct: evaluates to identity")

    print()


def demo_optimizer_soundness():
    """Demonstrate optimizer soundness for free monoids."""
    print("=" * 70)
    print("DEMO 4: Optimizer Soundness")
    print("=" * 70)

    # The canonical optimizer: FreeMonoid.lift FreeMonoid.of = id
    def optimize(m: FreeMonoid) -> FreeMonoid:
        """Canonical optimizer: maps each generator to itself (= identity)."""
        result = FreeMonoid.identity()
        for x in m.word:
            result = result * FreeMonoid.of(x)
        return result

    # More interesting optimizer: remove consecutive duplicates (monoid-specific)
    def optimize_v2(m: FreeMonoid) -> FreeMonoid:
        """Identity endomorphism — preserves generators, hence preserves semantics."""
        # This is still the identity since it maps of(x) ↦ of(x)
        return optimize(m)

    x = FreeMonoid.of("x")
    y = FreeMonoid.of("y")
    expr = x * y * x * y

    rho = {"x": 7, "y": 11}

    original_eval = eval_free_monoid(lambda v: rho[v], expr)
    optimized_eval = eval_free_monoid(lambda v: rho[v], optimize(expr))

    print(f"\nExpression: {expr}")
    print(f"Optimized:  {optimize(expr)}")
    print(f"Eval(original):  {original_eval}")
    print(f"Eval(optimized): {optimized_eval}")
    assert original_eval == optimized_eval
    print(f"  ✓ Optimizer soundness: semantics preserved!")

    # General endomorphism test
    print(f"\n  Theorem: Any endomorphism opt with opt(of(x)) = of(x)")
    print(f"  for all generators x preserves semantics.")
    print(f"  This is `endomorphism_preserves_semantics` in the Lean formalization.")

    print()


def demo_abelian_group():
    """Demonstrate the free abelian group evaluator."""
    print("=" * 70)
    print("DEMO 5: Free Abelian Group Evaluator")
    print("=" * 70)

    # 2x + 3y - x = x + 3y
    expr = FreeAbelianGroup.of("x") + FreeAbelianGroup.of("x") + \
           FreeAbelianGroup.of("y") + FreeAbelianGroup.of("y") + \
           FreeAbelianGroup.of("y") + (-FreeAbelianGroup.of("x"))

    print(f"\nExpression: {expr}")

    rho = {"x": 10, "y": 7}
    result = eval_free_abelian_group(lambda v: rho[v], expr)
    expected = 1 * 10 + 3 * 7  # x + 3y with x=10, y=7
    print(f"Eval with x↦10, y↦7: {result}")
    print(f"Expected (1·10 + 3·7): {expected}")
    assert result == expected
    print(f"  ✓ Correct!")

    print()


# =============================================================================
# Section 5: Conjecture Testing — Residual Finiteness
# =============================================================================

def test_residual_finiteness_conjecture(max_word_length=3, num_generators=2):
    """
    Test the residual finiteness conjecture for free groups:
    
    For every bound n, there exists a finite family of small groups G₁,...,Gₖ
    such that any two distinct reduced FreeGroup words of length ≤ n are
    distinguished by evaluation under some assignment into one of the Gᵢ.
    
    We test using cyclic groups Z/pZ and symmetric groups S_n.
    """
    print("=" * 70)
    print("CONJECTURE TEST: Residual Finiteness as Compiler Testing Oracle")
    print("=" * 70)

    generators = [chr(ord('a') + i) for i in range(num_generators)]

    # Generate all reduced words up to given length
    def generate_reduced_words(gens, max_len):
        """Generate all reduced words in the free group up to given length."""
        words = [FreeGroup.identity()]
        letters = [(g, 1) for g in gens] + [(g, -1) for g in gens]

        for length in range(1, max_len + 1):
            new_words = []
            for w in (words if length == 1 else
                      [w for w in words if len(w.word) == length - 1]):
                for letter in letters:
                    candidate = FreeGroup(w.word + [letter])
                    if len(candidate.word) == length:
                        if candidate not in new_words:
                            new_words.append(candidate)
            words.extend(new_words)
        return words

    words = generate_reduced_words(generators, max_word_length)
    print(f"\nGenerated {len(words)} reduced words with ≤{max_word_length} letters")
    print(f"  Generators: {generators}")

    # Test groups: Z/nZ for small n
    test_moduli = [2, 3, 5, 7]
    total_pairs = 0
    separated_pairs = 0
    unseparated = []

    for i in range(len(words)):
        for j in range(i + 1, len(words)):
            w1, w2 = words[i], words[j]
            total_pairs += 1
            found_separator = False

            for p in test_moduli:
                # Try all assignments of generators to Z/pZ
                for assignment in product(range(p), repeat=num_generators):
                    rho = dict(zip(generators, assignment))

                    def eval_mod_p(g_elem, p=p, rho=rho):
                        result = 0
                        for gen, sign in g_elem.word:
                            result = (result + sign * rho[gen]) % p
                        return result

                    if eval_mod_p(w1) != eval_mod_p(w2):
                        found_separator = True
                        break
                if found_separator:
                    break

            if found_separator:
                separated_pairs += 1
            else:
                unseparated.append((w1, w2))

    print(f"\n  Total distinct pairs: {total_pairs}")
    print(f"  Separated by abelian quotients Z/pZ: {separated_pairs}")
    print(f"  Unseparated: {total_pairs - separated_pairs}")

    if unseparated:
        print(f"\n  Unseparated pairs (need non-abelian groups):")
        for w1, w2 in unseparated[:5]:
            print(f"    {w1} vs {w2}")
        print(f"\n  Note: Free group elements that are conjugate but not equal")
        print(f"  cannot be separated by abelian quotients alone.")
        print(f"  Non-abelian quotients (S₃, S₄, ...) are needed.")
        print(f"\n  Conjecture status: PARTIALLY VERIFIED (abelian case)")
        print(f"  Full verification requires non-abelian test groups.")
    else:
        print(f"\n  ✓ All pairs separated! Conjecture VERIFIED for this bound.")

    print()
    return len(unseparated) == 0


def demo_adjoint_semantics_principle():
    """Demonstrate the abstract adjoint semantics principle."""
    print("=" * 70)
    print("DEMO 6: The Adjoint Semantics Principle")
    print("=" * 70)

    print("""
    THEOREM (adjoint_semantics_principle):
    For any adjunction F ⊣ U between categories C and D,
    and for every variable assignment ρ : X → U(A),
    there exists a UNIQUE morphism g : F(X) → A
    such that ρ = (homEquiv X A)(g).

    This means: the adjunction transpose IS the unique interpreter
    extending a variable assignment. No other semantics-preserving
    extension exists.

    Instantiations proven in the formalization:
    
    1. MONOIDS:   MonCat.adj : MonCat.free ⊣ forget MonCat
       Evaluator: FreeMonoid.lift = adjunction transpose
       
    2. GROUPS:    GrpCat.adj : GrpCat.free ⊣ forget GrpCat
       Evaluator: FreeGroup.lift = adjunction transpose
       
    3. AB. GROUPS: AddCommGrpCat.adj : AddCommGrpCat.free ⊣ forget AddCommGrpCat
       Evaluator: FreeAbelianGroup.lift = adjunction transpose

    Each evaluator is not an ad hoc definition — it is SYNTHESIZED
    by the universal mapping property of the adjunction.
    """)

    # Demonstrate uniqueness for monoids
    x = FreeMonoid.of("x")
    y = FreeMonoid.of("y")
    expr = x * y * x

    rho = {"x": 2, "y": 5}

    result = eval_free_monoid(lambda v: rho[v], expr)
    print(f"  Example: eval({expr}) with x↦2, y↦5 = {result}")
    print(f"  This is the UNIQUE monoid homomorphism extending ρ.")
    print(f"  Any other homomorphism h with h(of(x))=ρ(x) must equal lift(ρ).")

    print()


# =============================================================================
# Main
# =============================================================================

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  Verified Compiler Synthesis via Free-Forgetful Adjunctions        ║")
    print("║  Interactive Demonstration                                          ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    demo_monoid_evaluator()
    demo_naturality()
    demo_group_evaluator()
    demo_optimizer_soundness()
    demo_abelian_group()
    demo_adjoint_semantics_principle()
    test_residual_finiteness_conjecture()

    print("=" * 70)
    print("All demonstrations completed successfully!")
    print("=" * 70)

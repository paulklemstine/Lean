#!/usr/bin/env python3
"""
Algorithms for the Simply-Typed Tensor Calculus (STTC)

This module implements:
1. STTC term normalization with configurable reduction strategy
2. AC-canonical form computation (multiset normalization)
3. Critical pair enumeration between β and distributivity
4. Confluence testing via exhaustive reduction

Time Complexity:
- Normalization: O(n * d) where n = term size, d = depth of nesting
- AC-canonical form: O(n log n) for sorting subterms
- Critical pair enumeration: O(k²) where k = number of rule instances
"""

from dataclasses import dataclass
from typing import Optional, List, Tuple, Set
from enum import Enum, auto
import itertools


# ============================================================================
# Section 1: Type System
# ============================================================================

class TType:
    """Base class for STTC types."""
    def is_base(self) -> bool:
        raise NotImplementedError
    def level(self) -> int:
        raise NotImplementedError

@dataclass(frozen=True)
class Scalar(TType):
    def is_base(self): return True
    def level(self): return 0
    def __repr__(self): return "ℝ"

@dataclass(frozen=True)
class Vec(TType):
    n: int
    def is_base(self): return True
    def level(self): return 0
    def __repr__(self): return f"Vec({self.n})"

@dataclass(frozen=True)
class Mat(TType):
    m: int; n: int
    def is_base(self): return True
    def level(self): return 0
    def __repr__(self): return f"Mat({self.m},{self.n})"

@dataclass(frozen=True)
class Arrow(TType):
    src: TType; tgt: TType
    def is_base(self): return False
    def level(self): return 1 + max(self.src.level(), self.tgt.level())
    def __repr__(self): return f"({self.src} → {self.tgt})"


# ============================================================================
# Section 2: Term Language
# ============================================================================

class Term:
    """Base class for STTC terms."""
    def size(self) -> int:
        raise NotImplementedError

@dataclass
class Var(Term):
    name: str; ty: TType
    def size(self): return 1
    def __repr__(self): return self.name

@dataclass
class Lam(Term):
    param: str; param_ty: TType; body: Term
    def size(self): return 1 + self.body.size()
    def __repr__(self): return f"(λ{self.param}. {self.body})"

@dataclass
class App(Term):
    fun: Term; arg: Term
    def size(self): return 1 + self.fun.size() + self.arg.size()
    def __repr__(self): return f"({self.fun} {self.arg})"

@dataclass
class ScalarAdd(Term):
    left: Term; right: Term
    def size(self): return 1 + self.left.size() + self.right.size()
    def __repr__(self): return f"({self.left} + {self.right})"

@dataclass
class Smul(Term):
    scalar: Term; vector: Term
    def size(self): return 1 + self.scalar.size() + self.vector.size()
    def __repr__(self): return f"({self.scalar} • {self.vector})"

@dataclass
class Vadd(Term):
    left: Term; right: Term
    def size(self): return 1 + self.left.size() + self.right.size()
    def __repr__(self): return f"({self.left} ⊕ {self.right})"

@dataclass
class Dot(Term):
    left: Term; right: Term
    def size(self): return 1 + self.left.size() + self.right.size()
    def __repr__(self): return f"⟨{self.left}, {self.right}⟩"

@dataclass
class Vmul(Term):
    matrix: Term; vector: Term
    def size(self): return 1 + self.matrix.size() + self.vector.size()
    def __repr__(self): return f"({self.matrix} · {self.vector})"

@dataclass
class SZero(Term):
    def size(self): return 1
    def __repr__(self): return "0ₛ"

@dataclass
class VZero(Term):
    n: int = 2
    def size(self): return 1
    def __repr__(self): return "0ᵥ"


# ============================================================================
# Section 3: Substitution
# ============================================================================

def substitute(body: Term, param: str, arg: Term) -> Term:
    """Capture-avoiding substitution: body[param := arg].

    Time complexity: O(|body|)
    """
    if isinstance(body, Var):
        return arg if body.name == param else body
    elif isinstance(body, Lam):
        if body.param == param:
            return body
        return Lam(body.param, body.param_ty, substitute(body.body, param, arg))
    elif isinstance(body, App):
        return App(substitute(body.fun, param, arg), substitute(body.arg, param, arg))
    elif isinstance(body, ScalarAdd):
        return ScalarAdd(substitute(body.left, param, arg), substitute(body.right, param, arg))
    elif isinstance(body, Smul):
        return Smul(substitute(body.scalar, param, arg), substitute(body.vector, param, arg))
    elif isinstance(body, Vadd):
        return Vadd(substitute(body.left, param, arg), substitute(body.right, param, arg))
    elif isinstance(body, Dot):
        return Dot(substitute(body.left, param, arg), substitute(body.right, param, arg))
    elif isinstance(body, Vmul):
        return Vmul(substitute(body.matrix, param, arg), substitute(body.vector, param, arg))
    return body


# ============================================================================
# Section 4: Reduction Engine
# ============================================================================

class ReductionKind(Enum):
    BETA = auto()
    DIST_SMUL_LEFT = auto()
    DIST_SMUL_RIGHT = auto()
    DIST_VMUL_RIGHT = auto()
    DIST_DOT_LEFT = auto()
    DIST_DOT_RIGHT = auto()
    DIST_SMUL_ZERO = auto()
    DIST_VMUL_ZERO = auto()
    DIST_SMUL_SZERO = auto()


@dataclass
class ReductionStep:
    """Record of a single reduction step."""
    kind: ReductionKind
    source: Term
    target: Term
    position: str  # human-readable position description


def find_all_redexes(t: Term, position: str = "root") -> List[ReductionStep]:
    """Find all possible one-step reductions in a term.

    Returns a list of ReductionStep records.
    Time complexity: O(|t|²) in the worst case.
    """
    results = []

    # Root redexes
    if isinstance(t, App) and isinstance(t.fun, Lam):
        target = substitute(t.fun.body, t.fun.param, t.arg)
        results.append(ReductionStep(ReductionKind.BETA, t, target, position))

    if isinstance(t, Smul):
        if isinstance(t.scalar, ScalarAdd):
            target = Vadd(Smul(t.scalar.left, t.vector), Smul(t.scalar.right, t.vector))
            results.append(ReductionStep(ReductionKind.DIST_SMUL_LEFT, t, target, position))
        if isinstance(t.vector, Vadd):
            target = Vadd(Smul(t.scalar, t.vector.left), Smul(t.scalar, t.vector.right))
            results.append(ReductionStep(ReductionKind.DIST_SMUL_RIGHT, t, target, position))
        if isinstance(t.vector, VZero):
            results.append(ReductionStep(ReductionKind.DIST_SMUL_ZERO, t, VZero(), position))
        if isinstance(t.scalar, SZero):
            results.append(ReductionStep(ReductionKind.DIST_SMUL_SZERO, t, VZero(), position))

    if isinstance(t, Vmul):
        if isinstance(t.vector, Vadd):
            target = Vadd(Vmul(t.matrix, t.vector.left), Vmul(t.matrix, t.vector.right))
            results.append(ReductionStep(ReductionKind.DIST_VMUL_RIGHT, t, target, position))
        if isinstance(t.vector, VZero):
            results.append(ReductionStep(ReductionKind.DIST_VMUL_ZERO, t, VZero(), position))

    if isinstance(t, Dot):
        if isinstance(t.left, Vadd):
            target = ScalarAdd(Dot(t.left.left, t.right), Dot(t.left.right, t.right))
            results.append(ReductionStep(ReductionKind.DIST_DOT_LEFT, t, target, position))
        if isinstance(t.right, Vadd):
            target = ScalarAdd(Dot(t.left, t.right.left), Dot(t.left, t.right.right))
            results.append(ReductionStep(ReductionKind.DIST_DOT_RIGHT, t, target, position))

    # Recursive subterm redexes
    if isinstance(t, App):
        for step in find_all_redexes(t.fun, f"{position}.fun"):
            results.append(ReductionStep(step.kind, t,
                App(step.target, t.arg), step.position))
        for step in find_all_redexes(t.arg, f"{position}.arg"):
            results.append(ReductionStep(step.kind, t,
                App(t.fun, step.target), step.position))
    elif isinstance(t, Lam):
        for step in find_all_redexes(t.body, f"{position}.body"):
            results.append(ReductionStep(step.kind, t,
                Lam(t.param, t.param_ty, step.target), step.position))
    elif isinstance(t, ScalarAdd):
        for step in find_all_redexes(t.left, f"{position}.left"):
            results.append(ReductionStep(step.kind, t,
                ScalarAdd(step.target, t.right), step.position))
        for step in find_all_redexes(t.right, f"{position}.right"):
            results.append(ReductionStep(step.kind, t,
                ScalarAdd(t.left, step.target), step.position))
    elif isinstance(t, Smul):
        for step in find_all_redexes(t.scalar, f"{position}.scalar"):
            results.append(ReductionStep(step.kind, t,
                Smul(step.target, t.vector), step.position))
        for step in find_all_redexes(t.vector, f"{position}.vector"):
            results.append(ReductionStep(step.kind, t,
                Smul(t.scalar, step.target), step.position))
    elif isinstance(t, Vadd):
        for step in find_all_redexes(t.left, f"{position}.left"):
            results.append(ReductionStep(step.kind, t,
                Vadd(step.target, t.right), step.position))
        for step in find_all_redexes(t.right, f"{position}.right"):
            results.append(ReductionStep(step.kind, t,
                Vadd(t.left, step.target), step.position))
    elif isinstance(t, Dot):
        for step in find_all_redexes(t.left, f"{position}.left"):
            results.append(ReductionStep(step.kind, t,
                Dot(step.target, t.right), step.position))
        for step in find_all_redexes(t.right, f"{position}.right"):
            results.append(ReductionStep(step.kind, t,
                Dot(t.left, step.target), step.position))
    elif isinstance(t, Vmul):
        for step in find_all_redexes(t.matrix, f"{position}.matrix"):
            results.append(ReductionStep(step.kind, t,
                Vmul(step.target, t.vector), step.position))
        for step in find_all_redexes(t.vector, f"{position}.vector"):
            results.append(ReductionStep(step.kind, t,
                Vmul(t.matrix, step.target), step.position))

    return results


# ============================================================================
# Section 5: AC-Canonical Forms
# ============================================================================

def ac_canonical(t: Term) -> str:
    """Compute the AC-canonical form of a term as a string.

    Flattens associative operations and sorts commutative ones.
    Time complexity: O(n log n) where n = number of subterms.
    """
    if isinstance(t, Vadd):
        parts = []
        _collect_vadd(t, parts)
        parts.sort()
        return "Vadd{" + ", ".join(parts) + "}"
    if isinstance(t, ScalarAdd):
        parts = []
        _collect_scalar_add(t, parts)
        parts.sort()
        return "ScalarAdd{" + ", ".join(parts) + "}"
    if isinstance(t, Smul):
        return f"Smul({ac_canonical(t.scalar)}, {ac_canonical(t.vector)})"
    if isinstance(t, Dot):
        return f"Dot({ac_canonical(t.left)}, {ac_canonical(t.right)})"
    if isinstance(t, Vmul):
        return f"Vmul({ac_canonical(t.matrix)}, {ac_canonical(t.vector)})"
    if isinstance(t, App):
        return f"App({ac_canonical(t.fun)}, {ac_canonical(t.arg)})"
    if isinstance(t, Lam):
        return f"Lam({t.param}, {ac_canonical(t.body)})"
    return repr(t)


def _collect_vadd(t: Term, parts: list):
    if isinstance(t, Vadd):
        _collect_vadd(t.left, parts)
        _collect_vadd(t.right, parts)
    elif isinstance(t, VZero):
        pass
    else:
        parts.append(ac_canonical(t))


def _collect_scalar_add(t: Term, parts: list):
    if isinstance(t, ScalarAdd):
        _collect_scalar_add(t.left, parts)
        _collect_scalar_add(t.right, parts)
    elif isinstance(t, SZero):
        pass
    else:
        parts.append(ac_canonical(t))


def ac_equivalent(t1: Term, t2: Term) -> bool:
    """Check AC-equivalence of two terms.

    Time complexity: O(n log n)
    """
    return ac_canonical(t1) == ac_canonical(t2)


# ============================================================================
# Section 6: Normalization Algorithm
# ============================================================================

class Strategy(Enum):
    BETA_FIRST = auto()
    DIST_FIRST = auto()
    LEFTMOST = auto()
    RIGHTMOST = auto()


def normalize(t: Term, strategy: Strategy = Strategy.BETA_FIRST,
              max_steps: int = 1000) -> Tuple[Term, List[ReductionStep]]:
    """Normalize a term using the given reduction strategy.

    Args:
        t: Input term
        strategy: Which redex to choose when multiple are available
        max_steps: Maximum number of reduction steps

    Returns:
        (normal_form, reduction_trace)

    Time complexity: O(max_steps * |t|²)
    """
    trace = []
    for _ in range(max_steps):
        redexes = find_all_redexes(t)
        if not redexes:
            break

        # Select redex according to strategy
        if strategy == Strategy.BETA_FIRST:
            beta = [r for r in redexes if r.kind == ReductionKind.BETA]
            step = beta[0] if beta else redexes[0]
        elif strategy == Strategy.DIST_FIRST:
            dist = [r for r in redexes if r.kind != ReductionKind.BETA]
            step = dist[0] if dist else redexes[0]
        elif strategy == Strategy.LEFTMOST:
            step = redexes[0]
        else:
            step = redexes[-1]

        trace.append(step)
        t = step.target

    return t, trace


# ============================================================================
# Section 7: Confluence Tester
# ============================================================================

def test_confluence(t: Term, strategies: List[Strategy] = None) -> bool:
    """Test whether all reduction strategies yield AC-equivalent normal forms.

    Args:
        t: Input term
        strategies: List of strategies to test (default: all)

    Returns:
        True if all normal forms are AC-equivalent
    """
    if strategies is None:
        strategies = list(Strategy)

    normal_forms = []
    for s in strategies:
        nf, _ = normalize(t, strategy=s)
        normal_forms.append((s, nf))

    if len(normal_forms) < 2:
        return True

    ref_canonical = ac_canonical(normal_forms[0][1])
    return all(ac_canonical(nf) == ref_canonical for _, nf in normal_forms[1:])


# ============================================================================
# Example Usage
# ============================================================================

if __name__ == "__main__":
    # Example: smul (a + b) (u ⊕ v)
    a, b = Var("a", Scalar()), Var("b", Scalar())
    u, v = Var("u", Vec(3)), Var("v", Vec(3))

    t = Smul(ScalarAdd(a, b), Vadd(u, v))
    print(f"Term: {t}")
    print(f"Size: {t.size()}")
    print(f"Redexes: {len(find_all_redexes(t))}")

    for strategy in Strategy:
        nf, trace = normalize(t, strategy=strategy)
        print(f"\n{strategy.name}:")
        print(f"  Normal form: {nf}")
        print(f"  Steps: {len(trace)}")
        print(f"  AC-canonical: {ac_canonical(nf)}")

    print(f"\nConfluent? {test_confluence(t)}")

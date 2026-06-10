"""
EML Expression Complexity: Core Algorithms

This module implements the EML expression complexity theory in Python,
providing expression types, compilation, normalization, size analysis,
and enumeration of expressions up to bounded depth.

The central primitive is:
    eml(x, y) = exp(x) - log(y)

which serves as a universal gate for unary elementary real functions.
"""

from __future__ import annotations
import math
from dataclasses import dataclass
from typing import Optional, Callable
from enum import Enum, auto
from itertools import product


# ============================================================
# Source Grammar: UExpr (Unary Elementary Expressions)
# ============================================================

class UExprKind(Enum):
    VAR = auto()
    CONST = auto()
    ADD = auto()
    SUB = auto()
    MUL = auto()
    DIV = auto()
    EXP = auto()
    LOG = auto()


@dataclass(frozen=True)
class UExpr:
    """A unary elementary expression over ℝ."""
    kind: UExprKind
    value: Optional[float] = None      # for CONST
    left: Optional['UExpr'] = None     # for binary ops, or unary operand
    right: Optional['UExpr'] = None    # for binary ops

    @staticmethod
    def var() -> 'UExpr':
        return UExpr(UExprKind.VAR)

    @staticmethod
    def const(c: float) -> 'UExpr':
        return UExpr(UExprKind.CONST, value=c)

    @staticmethod
    def add(a: 'UExpr', b: 'UExpr') -> 'UExpr':
        return UExpr(UExprKind.ADD, left=a, right=b)

    @staticmethod
    def sub(a: 'UExpr', b: 'UExpr') -> 'UExpr':
        return UExpr(UExprKind.SUB, left=a, right=b)

    @staticmethod
    def mul(a: 'UExpr', b: 'UExpr') -> 'UExpr':
        return UExpr(UExprKind.MUL, left=a, right=b)

    @staticmethod
    def div(a: 'UExpr', b: 'UExpr') -> 'UExpr':
        return UExpr(UExprKind.DIV, left=a, right=b)

    @staticmethod
    def exp(e: 'UExpr') -> 'UExpr':
        return UExpr(UExprKind.EXP, left=e)

    @staticmethod
    def log(e: 'UExpr') -> 'UExpr':
        return UExpr(UExprKind.LOG, left=e)

    def size(self) -> int:
        """Count all nodes in the expression tree."""
        if self.kind in (UExprKind.VAR, UExprKind.CONST):
            return 1
        elif self.kind in (UExprKind.ADD, UExprKind.SUB, UExprKind.MUL, UExprKind.DIV):
            return 1 + self.left.size() + self.right.size()
        else:  # EXP, LOG
            return 1 + self.left.size()

    def transcendence_rank(self) -> int:
        """Count transcendental (exp/log) nodes."""
        if self.kind in (UExprKind.VAR, UExprKind.CONST):
            return 0
        elif self.kind in (UExprKind.ADD, UExprKind.SUB, UExprKind.MUL, UExprKind.DIV):
            return self.left.transcendence_rank() + self.right.transcendence_rank()
        else:  # EXP, LOG
            return 1 + self.left.transcendence_rank()

    def eval(self, x: float) -> Optional[float]:
        """Evaluate at x. Returns None on domain errors."""
        try:
            if self.kind == UExprKind.VAR:
                return x
            elif self.kind == UExprKind.CONST:
                return self.value
            elif self.kind == UExprKind.ADD:
                v1, v2 = self.left.eval(x), self.right.eval(x)
                return v1 + v2 if v1 is not None and v2 is not None else None
            elif self.kind == UExprKind.SUB:
                v1, v2 = self.left.eval(x), self.right.eval(x)
                return v1 - v2 if v1 is not None and v2 is not None else None
            elif self.kind == UExprKind.MUL:
                v1, v2 = self.left.eval(x), self.right.eval(x)
                return v1 * v2 if v1 is not None and v2 is not None else None
            elif self.kind == UExprKind.DIV:
                v1, v2 = self.left.eval(x), self.right.eval(x)
                if v1 is None or v2 is None or v2 == 0:
                    return None
                return v1 / v2
            elif self.kind == UExprKind.EXP:
                v = self.left.eval(x)
                if v is None:
                    return None
                if abs(v) > 700:  # overflow guard
                    return None
                return math.exp(v)
            elif self.kind == UExprKind.LOG:
                v = self.left.eval(x)
                if v is None or v <= 0:
                    return None
                return math.log(v)
        except (OverflowError, ValueError):
            return None

    def pretty(self) -> str:
        """Human-readable string representation."""
        if self.kind == UExprKind.VAR:
            return "x"
        elif self.kind == UExprKind.CONST:
            return str(self.value)
        elif self.kind == UExprKind.ADD:
            return f"({self.left.pretty()} + {self.right.pretty()})"
        elif self.kind == UExprKind.SUB:
            return f"({self.left.pretty()} - {self.right.pretty()})"
        elif self.kind == UExprKind.MUL:
            return f"({self.left.pretty()} * {self.right.pretty()})"
        elif self.kind == UExprKind.DIV:
            return f"({self.left.pretty()} / {self.right.pretty()})"
        elif self.kind == UExprKind.EXP:
            return f"exp({self.left.pretty()})"
        elif self.kind == UExprKind.LOG:
            return f"log({self.left.pretty()})"


# ============================================================
# Target Grammar: EMLExpr
# ============================================================

class EMLExprKind(Enum):
    VAR = auto()
    CONST = auto()
    ADD = auto()
    SUB = auto()
    MUL = auto()
    DIV = auto()
    EML = auto()


@dataclass(frozen=True)
class EMLExpr:
    """An EML expression: field ops + eml(x,y) = exp(x) - log(y)."""
    kind: EMLExprKind
    value: Optional[float] = None
    left: Optional['EMLExpr'] = None
    right: Optional['EMLExpr'] = None

    @staticmethod
    def var() -> 'EMLExpr':
        return EMLExpr(EMLExprKind.VAR)

    @staticmethod
    def const(c: float) -> 'EMLExpr':
        return EMLExpr(EMLExprKind.CONST, value=c)

    @staticmethod
    def add(a: 'EMLExpr', b: 'EMLExpr') -> 'EMLExpr':
        return EMLExpr(EMLExprKind.ADD, left=a, right=b)

    @staticmethod
    def sub(a: 'EMLExpr', b: 'EMLExpr') -> 'EMLExpr':
        return EMLExpr(EMLExprKind.SUB, left=a, right=b)

    @staticmethod
    def mul(a: 'EMLExpr', b: 'EMLExpr') -> 'EMLExpr':
        return EMLExpr(EMLExprKind.MUL, left=a, right=b)

    @staticmethod
    def div(a: 'EMLExpr', b: 'EMLExpr') -> 'EMLExpr':
        return EMLExpr(EMLExprKind.DIV, left=a, right=b)

    @staticmethod
    def eml(a: 'EMLExpr', b: 'EMLExpr') -> 'EMLExpr':
        return EMLExpr(EMLExprKind.EML, left=a, right=b)

    def esize(self) -> int:
        """Count all nodes in the expression tree."""
        if self.kind in (EMLExprKind.VAR, EMLExprKind.CONST):
            return 1
        else:
            return 1 + self.left.esize() + self.right.esize()

    def eml_rank(self) -> int:
        """Count the number of eml nodes."""
        if self.kind in (EMLExprKind.VAR, EMLExprKind.CONST):
            return 0
        elif self.kind == EMLExprKind.EML:
            return 1 + self.left.eml_rank() + self.right.eml_rank()
        else:
            return self.left.eml_rank() + self.right.eml_rank()

    def eeval(self, x: float) -> Optional[float]:
        """Evaluate at x. Returns None on domain errors."""
        try:
            if self.kind == EMLExprKind.VAR:
                return x
            elif self.kind == EMLExprKind.CONST:
                return self.value
            elif self.kind == EMLExprKind.ADD:
                v1, v2 = self.left.eeval(x), self.right.eeval(x)
                return v1 + v2 if v1 is not None and v2 is not None else None
            elif self.kind == EMLExprKind.SUB:
                v1, v2 = self.left.eeval(x), self.right.eeval(x)
                return v1 - v2 if v1 is not None and v2 is not None else None
            elif self.kind == EMLExprKind.MUL:
                v1, v2 = self.left.eeval(x), self.right.eeval(x)
                return v1 * v2 if v1 is not None and v2 is not None else None
            elif self.kind == EMLExprKind.DIV:
                v1, v2 = self.left.eeval(x), self.right.eeval(x)
                if v1 is None or v2 is None or v2 == 0:
                    return None
                return v1 / v2
            elif self.kind == EMLExprKind.EML:
                v1, v2 = self.left.eeval(x), self.right.eeval(x)
                if v1 is None or v2 is None or v2 <= 0:
                    return None
                if abs(v1) > 700:
                    return None
                return math.exp(v1) - math.log(v2)
        except (OverflowError, ValueError):
            return None

    def pretty(self) -> str:
        """Human-readable string representation."""
        if self.kind == EMLExprKind.VAR:
            return "x"
        elif self.kind == EMLExprKind.CONST:
            return str(self.value)
        elif self.kind == EMLExprKind.ADD:
            return f"({self.left.pretty()} + {self.right.pretty()})"
        elif self.kind == EMLExprKind.SUB:
            return f"({self.left.pretty()} - {self.right.pretty()})"
        elif self.kind == EMLExprKind.MUL:
            return f"({self.left.pretty()} * {self.right.pretty()})"
        elif self.kind == EMLExprKind.DIV:
            return f"({self.left.pretty()} / {self.right.pretty()})"
        elif self.kind == EMLExprKind.EML:
            return f"eml({self.left.pretty()}, {self.right.pretty()})"


# ============================================================
# Compiler: UExpr → EMLExpr
# ============================================================

def compile(e: UExpr) -> EMLExpr:
    """Compile a UExpr into EMLExpr by replacing exp/log with eml.

    Translation:
        exp(e)  →  eml(compile(e), 1)       since eml(x,1) = exp(x) - log(1) = exp(x)
        log(e)  →  1 - eml(0, compile(e))   since eml(0,y) = exp(0) - log(y) = 1 - log(y)

    Correctness and size bounds are formally verified in the Lean development.

    Time complexity: O(size(e))
    Size bound: esize(compile(e)) ≤ 4 * size(e)
    """
    if e.kind == UExprKind.VAR:
        return EMLExpr.var()
    elif e.kind == UExprKind.CONST:
        return EMLExpr.const(e.value)
    elif e.kind == UExprKind.ADD:
        return EMLExpr.add(compile(e.left), compile(e.right))
    elif e.kind == UExprKind.SUB:
        return EMLExpr.sub(compile(e.left), compile(e.right))
    elif e.kind == UExprKind.MUL:
        return EMLExpr.mul(compile(e.left), compile(e.right))
    elif e.kind == UExprKind.DIV:
        return EMLExpr.div(compile(e.left), compile(e.right))
    elif e.kind == UExprKind.EXP:
        return EMLExpr.eml(compile(e.left), EMLExpr.const(1.0))
    elif e.kind == UExprKind.LOG:
        return EMLExpr.sub(
            EMLExpr.const(1.0),
            EMLExpr.eml(EMLExpr.const(0.0), compile(e.left))
        )


# ============================================================
# Normalizer
# ============================================================

def eml_normalize(e: EMLExpr) -> EMLExpr:
    """Normalize an EMLExpr by constant folding and identity elimination.

    Simplifications performed:
        add(e, const 0) → e
        add(const 0, e) → e
        sub(e, const 0) → e
        mul(e, const 1) → e
        mul(const 1, e) → e
        mul(_, const 0) → const 0
        mul(const 0, _) → const 0
        const-const folding for all operations
        eml(const a, const b) → const(exp(a) - log(b)) when b > 0

    Time complexity: O(esize(e))
    """
    if e.kind in (EMLExprKind.VAR, EMLExprKind.CONST):
        return e

    left = eml_normalize(e.left)
    right = eml_normalize(e.right) if e.right else None

    # Constant folding
    if (left.kind == EMLExprKind.CONST and
        right is not None and right.kind == EMLExprKind.CONST):
        a, b = left.value, right.value
        try:
            if e.kind == EMLExprKind.ADD:
                return EMLExpr.const(a + b)
            elif e.kind == EMLExprKind.SUB:
                return EMLExpr.const(a - b)
            elif e.kind == EMLExprKind.MUL:
                return EMLExpr.const(a * b)
            elif e.kind == EMLExprKind.DIV and b != 0:
                return EMLExpr.const(a / b)
            elif e.kind == EMLExprKind.EML and b > 0 and abs(a) < 700:
                return EMLExpr.const(math.exp(a) - math.log(b))
        except (OverflowError, ValueError):
            pass

    # Identity simplifications
    if e.kind == EMLExprKind.ADD:
        if right.kind == EMLExprKind.CONST and right.value == 0:
            return left
        if left.kind == EMLExprKind.CONST and left.value == 0:
            return right
    elif e.kind == EMLExprKind.SUB:
        if right.kind == EMLExprKind.CONST and right.value == 0:
            return left
    elif e.kind == EMLExprKind.MUL:
        if right.kind == EMLExprKind.CONST and right.value == 1:
            return left
        if left.kind == EMLExprKind.CONST and left.value == 1:
            return right
        if (right.kind == EMLExprKind.CONST and right.value == 0) or \
           (left.kind == EMLExprKind.CONST and left.value == 0):
            return EMLExpr.const(0.0)

    return EMLExpr(e.kind, left=left, right=right)


# ============================================================
# Enumeration
# ============================================================

def enumerate_uexprs(max_depth: int, constants: list[float] = None) -> list[UExpr]:
    """Enumerate all UExpr up to a given tree depth.

    Args:
        max_depth: Maximum tree depth (0 = leaves only).
        constants: Constants to include (default: [0, 1, 2]).

    Returns:
        List of all UExpr up to the given depth.
    """
    if constants is None:
        constants = [0.0, 1.0, 2.0]

    cache: dict[int, list[UExpr]] = {}

    def gen(d: int) -> list[UExpr]:
        if d in cache:
            return cache[d]
        if d == 0:
            result = [UExpr.var()] + [UExpr.const(c) for c in constants]
            cache[d] = result
            return result

        prev = gen(d - 1)
        result = list(prev)  # include all smaller expressions

        # Unary ops
        for e in prev:
            if e.size() < 2**d:  # size guard
                result.append(UExpr.exp(e))
                result.append(UExpr.log(e))

        # Binary ops (only using expressions from smaller depths to control growth)
        small = gen(d - 1)
        # Use a limited set to avoid combinatorial explosion
        limited = small[:min(len(small), 20)]
        for a in limited:
            for b in limited:
                if a.size() + b.size() < 2**d:
                    result.append(UExpr.add(a, b))
                    result.append(UExpr.mul(a, b))

        cache[d] = result
        return result

    return gen(max_depth)


# ============================================================
# Analysis Functions
# ============================================================

def analyze_compilation(e: UExpr) -> dict:
    """Analyze the compilation of a UExpr to EML form.

    Returns a dictionary with size metrics, rank metrics, and
    evaluation comparison at sample points.
    """
    compiled = compile(e)
    normalized = eml_normalize(compiled)

    test_points = [0.5, 1.0, 1.5, 2.0, 3.0]
    eval_matches = []
    for x in test_points:
        orig_val = e.eval(x)
        comp_val = compiled.eeval(x)
        norm_val = normalized.eeval(x)
        match = True
        if orig_val is not None and comp_val is not None:
            match = abs(orig_val - comp_val) < 1e-10
        elif orig_val is None and comp_val is None:
            match = True
        else:
            match = False
        eval_matches.append({
            'x': x,
            'original': orig_val,
            'compiled': comp_val,
            'normalized': norm_val,
            'match': match
        })

    return {
        'original_expr': e.pretty(),
        'compiled_expr': compiled.pretty(),
        'normalized_expr': normalized.pretty(),
        'original_size': e.size(),
        'compiled_size': compiled.esize(),
        'normalized_size': normalized.esize(),
        'size_ratio': compiled.esize() / e.size() if e.size() > 0 else 0,
        'normalized_ratio': normalized.esize() / e.size() if e.size() > 0 else 0,
        'transcendence_rank': e.transcendence_rank(),
        'eml_rank': compiled.eml_rank(),
        'rank_preserved': compiled.eml_rank() == e.transcendence_rank(),
        'evaluations': eval_matches,
        'bound_satisfied': compiled.esize() <= 4 * e.size(),
    }


def compute_dag_size(e: EMLExpr) -> int:
    """Compute the DAG size of an EMLExpr (number of unique subtrees).

    This measures sharing potential: if dag_size << tree_size,
    then the expression benefits significantly from sharing.
    """
    seen = set()

    def traverse(expr: EMLExpr) -> None:
        key = id(expr)
        if key in seen:
            return
        seen.add(key)
        if expr.left is not None:
            traverse(expr.left)
        if expr.right is not None:
            traverse(expr.right)

    traverse(e)
    return len(seen)


if __name__ == "__main__":
    # Quick self-test
    x = UExpr.var()
    e = UExpr.exp(UExpr.log(x))  # exp(log(x)) = x for x > 0
    result = analyze_compilation(e)
    print(f"Expression: {result['original_expr']}")
    print(f"Compiled:   {result['compiled_expr']}")
    print(f"Size: {result['original_size']} → {result['compiled_size']} (ratio: {result['size_ratio']:.2f})")
    print(f"Bound 4n satisfied: {result['bound_satisfied']}")
    print(f"Rank preserved: {result['rank_preserved']}")
    for ev in result['evaluations']:
        print(f"  x={ev['x']}: orig={ev['original']}, compiled={ev['compiled']}, match={ev['match']}")

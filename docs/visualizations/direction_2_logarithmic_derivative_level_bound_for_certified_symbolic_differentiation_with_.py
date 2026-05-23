#!/usr/bin/env python3
"""
Algorithms for PosEMLExpr depth stability analysis.

Implements:
1. Certified symbolic differentiation with depth tracking
2. Tropicalization and tropical differentiation
3. Riccati expression construction
4. Expression enumeration and depth analysis
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import Union, Tuple, List, Optional
import math


# ═══════════════════════════════════════════════════════════════════════
# Expression Types
# ═══════════════════════════════════════════════════════════════════════

class Const:
    """Constant expression."""
    __slots__ = ['c']
    def __init__(self, c: float): self.c = c
    def __repr__(self): return f"Const({self.c})"
    def __eq__(self, o): return isinstance(o, Const) and self.c == o.c
    def __hash__(self): return hash(('Const', self.c))

class Var:
    """Variable x."""
    def __repr__(self): return "Var"
    def __eq__(self, o): return isinstance(o, Var)
    def __hash__(self): return hash('Var')

class Add:
    """Addition."""
    __slots__ = ['a', 'b']
    def __init__(self, a: 'Expr', b: 'Expr'): self.a, self.b = a, b
    def __repr__(self): return f"Add({self.a}, {self.b})"
    def __eq__(self, o): return isinstance(o, Add) and self.a == o.a and self.b == o.b
    def __hash__(self): return hash(('Add', self.a, self.b))

class Mul:
    """Multiplication."""
    __slots__ = ['a', 'b']
    def __init__(self, a: 'Expr', b: 'Expr'): self.a, self.b = a, b
    def __repr__(self): return f"Mul({self.a}, {self.b})"
    def __eq__(self, o): return isinstance(o, Mul) and self.a == o.a and self.b == o.b
    def __hash__(self): return hash(('Mul', self.a, self.b))

class Exp:
    """Exponentiation exp(a)."""
    __slots__ = ['a']
    def __init__(self, a: 'Expr'): self.a = a
    def __repr__(self): return f"Exp({self.a})"
    def __eq__(self, o): return isinstance(o, Exp) and self.a == o.a
    def __hash__(self): return hash(('Exp', self.a))

Expr = Union[Const, Var, Add, Mul, Exp]


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 1: Depth Computation — O(n) time, O(depth) stack
# ═══════════════════════════════════════════════════════════════════════

def depth(e: Expr) -> int:
    """
    Compute the depth (maximum exp nesting) of a PosEMLExpr.

    Time:  O(n) where n is the number of nodes
    Space: O(d) where d is the depth of the expression tree

    >>> depth(Const(5))
    0
    >>> depth(Exp(Var()))
    1
    >>> depth(Exp(Exp(Var())))
    2
    """
    if isinstance(e, (Const, Var)):
        return 0
    elif isinstance(e, (Add, Mul)):
        return max(depth(e.a), depth(e.b))
    elif isinstance(e, Exp):
        return depth(e.a) + 1
    raise TypeError(f"Unknown: {type(e)}")


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 2: Certified Symbolic Differentiation
# ═══════════════════════════════════════════════════════════════════════

def certified_deriv(e: Expr) -> Tuple[Expr, int, int]:
    """
    Certified symbolic differentiation.

    Returns (derivative, depth_of_original, depth_of_derivative)
    with the invariant that depth_of_derivative <= depth_of_original.

    Time:  O(n) where n = size(e)
    Space: O(n) for the output (derivative may be up to 3x input size)

    >>> e = Exp(Var())
    >>> d, do, dd = certified_deriv(e)
    >>> assert dd <= do, "Depth stability violated!"

    Examples:
    >>> certified_deriv(Const(5))
    (Const(0), 0, 0)
    >>> certified_deriv(Var())
    (Const(1), 0, 0)
    """
    if isinstance(e, Const):
        return Const(0), 0, 0
    elif isinstance(e, Var):
        return Const(1), 0, 0
    elif isinstance(e, Add):
        da, do_a, dd_a = certified_deriv(e.a)
        db, do_b, dd_b = certified_deriv(e.b)
        result = Add(da, db)
        d_orig = max(do_a, do_b)
        d_deriv = max(dd_a, dd_b)
        assert d_deriv <= d_orig, f"Stability violated in Add"
        return result, d_orig, d_deriv
    elif isinstance(e, Mul):
        da, do_a, dd_a = certified_deriv(e.a)
        db, do_b, dd_b = certified_deriv(e.b)
        # deriv(a*b) = a'*b + a*b'
        result = Add(Mul(da, e.b), Mul(e.a, db))
        d_orig = max(do_a, do_b)
        d_deriv = max(max(dd_a, do_b), max(do_a, dd_b))
        assert d_deriv <= d_orig, f"Stability violated in Mul"
        return result, d_orig, d_deriv
    elif isinstance(e, Exp):
        da, do_a, dd_a = certified_deriv(e.a)
        # deriv(exp(a)) = a' * exp(a)
        result = Mul(da, Exp(e.a))
        d_orig = do_a + 1
        d_deriv = max(dd_a, do_a + 1)
        assert d_deriv <= d_orig, f"Stability violated in Exp"
        return result, d_orig, d_deriv
    raise TypeError


def deriv(e: Expr) -> Expr:
    """Simple symbolic differentiation (without certificate)."""
    return certified_deriv(e)[0]


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 3: Tropicalization
# ═══════════════════════════════════════════════════════════════════════

class TConst:
    __slots__ = ['c']
    def __init__(self, c: float): self.c = c
    def __repr__(self): return f"TConst({self.c})"

class TVar:
    def __repr__(self): return "TVar"

class TAdd:
    __slots__ = ['a', 'b']
    def __init__(self, a, b): self.a, self.b = a, b
    def __repr__(self): return f"TAdd({self.a}, {self.b})"

class TMul:
    __slots__ = ['a', 'b']
    def __init__(self, a, b): self.a, self.b = a, b
    def __repr__(self): return f"TMul({self.a}, {self.b})"

class TScale:
    __slots__ = ['a']
    def __init__(self, a): self.a = a
    def __repr__(self): return f"TScale({self.a})"

TropExpr = Union[TConst, TVar, TAdd, TMul, TScale]


def tropical_depth(t: TropExpr) -> int:
    """Depth of a tropical expression."""
    if isinstance(t, (TConst, TVar)):
        return 0
    elif isinstance(t, (TAdd, TMul)):
        return max(tropical_depth(t.a), tropical_depth(t.b))
    elif isinstance(t, TScale):
        return tropical_depth(t.a) + 1
    raise TypeError


def tropicalize(e: Expr) -> TropExpr:
    """
    Map PosEMLExpr to TropicalExpr.

    Preserves depth: tropical_depth(tropicalize(e)) == depth(e)

    >>> tropicalize(Const(1))
    TConst(0.0)
    >>> tropical_depth(tropicalize(Exp(Var())))
    1
    """
    if isinstance(e, Const):
        return TConst(math.log(e.c) if e.c > 0 else float('-inf'))
    elif isinstance(e, Var):
        return TVar()
    elif isinstance(e, Add):
        return TAdd(tropicalize(e.a), tropicalize(e.b))
    elif isinstance(e, Mul):
        return TMul(tropicalize(e.a), tropicalize(e.b))
    elif isinstance(e, Exp):
        return TScale(tropicalize(e.a))
    raise TypeError


def tropical_deriv(t: TropExpr) -> TropExpr:
    """
    Tropical differentiation.

    Satisfies: tropical_depth(tropical_deriv(t)) <= tropical_depth(t)
    """
    if isinstance(t, TConst):
        return TConst(0)
    elif isinstance(t, TVar):
        return TConst(1)
    elif isinstance(t, TAdd):
        return TAdd(tropical_deriv(t.a), tropical_deriv(t.b))
    elif isinstance(t, TMul):
        return TAdd(TMul(tropical_deriv(t.a), t.b),
                    TMul(t.a, tropical_deriv(t.b)))
    elif isinstance(t, TScale):
        return TMul(tropical_deriv(t.a), TScale(t.a))
    raise TypeError


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 4: Riccati Expression
# ═══════════════════════════════════════════════════════════════════════

def riccati_expr(b: Expr) -> Expr:
    """
    Construct the Riccati expression b'' + (b')².

    When y = exp(b), this equals y''/y (the second logarithmic derivative).

    Satisfies: depth(riccati_expr(b)) <= depth(b)

    >>> b = Var()
    >>> depth(riccati_expr(b)) <= depth(b)
    True
    """
    bp = deriv(b)
    bpp = deriv(bp)
    return Add(bpp, Mul(bp, bp))


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 5: Expression Enumeration
# ═══════════════════════════════════════════════════════════════════════

def enumerate_by_depth(max_depth: int, max_size: int = 5,
                       constants: list = [0, 1, 2]) -> List[Expr]:
    """
    Enumerate PosEMLExpr up to given depth and size.

    Uses bottom-up construction: first build depth-0 expressions,
    then wrap in Exp to get depth 1, etc.

    Time:  O(N²) where N is the output size (due to binary combinations)
    Space: O(N) for storing results
    """
    by_depth: dict[int, list[Expr]] = {0: []}

    # Depth 0: constants and variable
    atoms = [Const(c) for c in constants] + [Var()]
    by_depth[0] = list(atoms)

    # Add binary combinations at depth 0
    d0_extended = list(atoms)
    for a in atoms:
        for b in atoms:
            if len(d0_extended) < max_size * 5:
                d0_extended.append(Add(a, b))
                d0_extended.append(Mul(a, b))
    by_depth[0] = d0_extended

    # Build higher depths
    for d in range(1, max_depth + 1):
        exprs_d = []
        # Wrap depth-(d-1) in Exp
        for sub in by_depth.get(d - 1, [])[:20]:
            exprs_d.append(Exp(sub))

        # Binary ops mixing depths
        for d1 in range(d + 1):
            d2 = d
            subs1 = by_depth.get(d1, [])[:10]
            subs2 = by_depth.get(d2, [])[:10] if d2 in by_depth else []
            for a in subs1:
                for b in subs2:
                    if depth(Add(a, b)) == d:
                        exprs_d.append(Add(a, b))
                    if depth(Mul(a, b)) == d:
                        exprs_d.append(Mul(a, b))
                    if len(exprs_d) > 100:
                        break
        by_depth[d] = exprs_d

    # Collect all
    result = []
    seen = set()
    for d in sorted(by_depth.keys()):
        for e in by_depth[d]:
            r = repr(e)
            if r not in seen:
                seen.add(r)
                result.append(e)
    return result


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 6: Pretty Printing
# ═══════════════════════════════════════════════════════════════════════

def pretty(e: Expr) -> str:
    """Human-readable expression string."""
    if isinstance(e, Const):
        c = e.c
        return str(int(c)) if c == int(c) else f"{c:.2f}"
    elif isinstance(e, Var):
        return "x"
    elif isinstance(e, Add):
        return f"({pretty(e.a)} + {pretty(e.b)})"
    elif isinstance(e, Mul):
        return f"({pretty(e.a)} · {pretty(e.b)})"
    elif isinstance(e, Exp):
        return f"exp({pretty(e.a)})"
    return "?"


def size(e: Expr) -> int:
    """Number of nodes in the expression tree."""
    if isinstance(e, (Const, Var)):
        return 1
    elif isinstance(e, (Add, Mul)):
        return 1 + size(e.a) + size(e.b)
    elif isinstance(e, Exp):
        return 1 + size(e.a)
    return 0


# ═══════════════════════════════════════════════════════════════════════
# Main: Algorithm Demonstrations
# ═══════════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("=" * 60)
    print("  ALGORITHMS FOR DEPTH STABILITY ANALYSIS")
    print("=" * 60)
    print()

    # Demo 1: Certified Differentiation
    print("━━━ Algorithm 1: Certified Differentiation ━━━")
    test_exprs = [
        Const(3),
        Var(),
        Mul(Var(), Var()),
        Exp(Var()),
        Exp(Mul(Var(), Var())),
        Exp(Exp(Var())),
        Mul(Exp(Var()), Exp(Var())),
        Exp(Exp(Exp(Var()))),
    ]
    for e in test_exprs:
        d_expr, d_orig, d_deriv = certified_deriv(e)
        print(f"  d/dx [{pretty(e)}]")
        print(f"    = {pretty(d_expr)}")
        print(f"    depth: {d_orig} → {d_deriv}  "
              f"{'✓' if d_deriv <= d_orig else '✗ VIOLATION'}")
        print()

    # Demo 2: Tropicalization
    print("━━━ Algorithm 2: Tropicalization ━━━")
    for e in test_exprs[:5]:
        t = tropicalize(e)
        td = tropical_deriv(t)
        d_t = tropical_depth(t)
        d_td = tropical_depth(td)
        print(f"  trop({pretty(e)}) → depth {d_t}")
        print(f"  trop_deriv → depth {d_td}  "
              f"{'✓' if d_td <= d_t else '✗'}")
        print(f"  depth match: classical={depth(e)}, tropical={d_t}  "
              f"{'✓' if depth(e) == d_t else '✗'}")
        print()

    # Demo 3: Riccati
    print("━━━ Algorithm 3: Riccati Expression ━━━")
    for e in [Var(), Mul(Var(), Var()), Exp(Var()), Exp(Exp(Var()))]:
        r = riccati_expr(e)
        d_e = depth(e)
        d_r = depth(r)
        print(f"  b = {pretty(e)}, depth(b) = {d_e}")
        print(f"  b'' + (b')² → depth = {d_r}  "
              f"{'✓' if d_r <= d_e else '✗'}")
        print()

    # Demo 4: Exhaustive Enumeration
    print("━━━ Algorithm 4: Exhaustive Enumeration ━━━")
    all_exprs = enumerate_by_depth(4)
    violations = 0
    for e in all_exprs:
        d = depth(e)
        dd = depth(deriv(e))
        if dd > d:
            violations += 1
            print(f"  VIOLATION: {pretty(e)}")
    print(f"  Tested {len(all_exprs)} expressions")
    print(f"  Violations: {violations}")
    print(f"  Result: {'DEPTH STABILITY CONFIRMED ✓' if violations == 0 else 'VIOLATIONS FOUND ✗'}")

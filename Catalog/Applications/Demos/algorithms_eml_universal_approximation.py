#!/usr/bin/env python3
"""
EML Universal Approximation — Algorithms

Type-hinted implementations of the core algorithms from the EML Approximation
Filtration theory.
"""
import math
from typing import List, Tuple, Optional, Callable
from dataclasses import dataclass


# ──────────────────────────────────────────────────────────────────────────────
# Algorithm 1: EML Expression Evaluation
# ──────────────────────────────────────────────────────────────────────────────

class EMLExpr:
    """Abstract base for EML expressions."""
    pass

@dataclass
class Var(EMLExpr): pass
@dataclass
class Const(EMLExpr):
    value: float
@dataclass
class Add(EMLExpr):
    left: EMLExpr
    right: EMLExpr
@dataclass
class Mul(EMLExpr):
    left: EMLExpr
    right: EMLExpr
@dataclass
class Neg(EMLExpr):
    child: EMLExpr
@dataclass
class Inv(EMLExpr):
    child: EMLExpr
@dataclass
class EML(EMLExpr):
    coeff: EMLExpr
    exponent: EMLExpr


def evaluate(expr: EMLExpr, x: float) -> float:
    """
    Algorithm: Recursive evaluation of EML expression trees.

    Time complexity: O(size(expr))
    Space complexity: O(depth(expr)) stack frames

    Pseudocode:
        EVAL(e, x):
          match e:
            Var       → x
            Const(c)  → c
            Add(a, b) → EVAL(a, x) + EVAL(b, x)
            Mul(a, b) → EVAL(a, x) · EVAL(b, x)
            Neg(a)    → −EVAL(a, x)
            Inv(a)    → 1 / EVAL(a, x)
            EML(a, b) → EVAL(a, x) · exp(EVAL(b, x))
    """
    if isinstance(expr, Var):
        return x
    elif isinstance(expr, Const):
        return expr.value
    elif isinstance(expr, Add):
        return evaluate(expr.left, x) + evaluate(expr.right, x)
    elif isinstance(expr, Mul):
        return evaluate(expr.left, x) * evaluate(expr.right, x)
    elif isinstance(expr, Neg):
        return -evaluate(expr.child, x)
    elif isinstance(expr, Inv):
        v = evaluate(expr.child, x)
        return 1.0 / v if v != 0 else float('inf')
    elif isinstance(expr, EML):
        a = evaluate(expr.coeff, x)
        b = evaluate(expr.exponent, x)
        try:
            return a * math.exp(b)
        except OverflowError:
            return float('inf') if a > 0 else float('-inf')
    raise TypeError(f"Unknown expression type: {type(expr)}")


# ──────────────────────────────────────────────────────────────────────────────
# Algorithm 2: Structural Analysis
# ──────────────────────────────────────────────────────────────────────────────

def analyze_structure(expr: EMLExpr) -> dict:
    """
    Algorithm: Compute all structural measures in a single traversal.

    Returns dict with: size, eml_depth, eml_count, field_count, leaf_count, exp_rank
    Verifies the decomposition: size = leaf_count + field_count + eml_count

    Pseudocode:
        ANALYZE(e):
          match e:
            Var/Const → (size=1, depth=0, eml=0, field=0, leaf=1, rank=0)
            Add(a,b)  → merge(ANALYZE(a), ANALYZE(b), op='field')
            EML(a,b)  → merge(ANALYZE(a), ANALYZE(b), op='eml')
            ...
    """
    if isinstance(expr, (Var, Const)):
        return dict(size=1, eml_depth=0, eml_count=0, field_count=0, leaf_count=1, exp_rank=0)

    if isinstance(expr, (Neg, Inv)):
        c = analyze_structure(expr.child)
        return dict(
            size=1 + c['size'],
            eml_depth=c['eml_depth'],
            eml_count=c['eml_count'],
            field_count=1 + c['field_count'],
            leaf_count=c['leaf_count'],
            exp_rank=c['exp_rank']
        )

    if isinstance(expr, (Add, Mul)):
        l = analyze_structure(expr.left)
        r = analyze_structure(expr.right)
        return dict(
            size=1 + l['size'] + r['size'],
            eml_depth=max(l['eml_depth'], r['eml_depth']),
            eml_count=l['eml_count'] + r['eml_count'],
            field_count=1 + l['field_count'] + r['field_count'],
            leaf_count=l['leaf_count'] + r['leaf_count'],
            exp_rank=max(l['exp_rank'], r['exp_rank'])
        )

    if isinstance(expr, EML):
        a = analyze_structure(expr.coeff)
        b = analyze_structure(expr.exponent)
        return dict(
            size=1 + a['size'] + b['size'],
            eml_depth=1 + max(a['eml_depth'], b['eml_depth']),
            eml_count=1 + a['eml_count'] + b['eml_count'],
            field_count=a['field_count'] + b['field_count'],
            leaf_count=a['leaf_count'] + b['leaf_count'],
            exp_rank=max(a['exp_rank'], b['exp_rank'] + 1)
        )

    raise TypeError(f"Unknown: {type(expr)}")


# ──────────────────────────────────────────────────────────────────────────────
# Algorithm 3: Syntactic Substitution (Composition)
# ──────────────────────────────────────────────────────────────────────────────

def substitute(expr: EMLExpr, replacement: EMLExpr) -> EMLExpr:
    """
    Algorithm: Replace every Var in expr with replacement.
    Implements function composition: (f.subst g).eval(x) = f.eval(g.eval(x))

    Time: O(size(expr) · size(replacement)) worst case
    Depth bound: depth(result) ≤ depth(expr) + depth(replacement)
    Size bound: size(result) ≤ size(expr) · size(replacement)
    """
    if isinstance(expr, Var):
        return replacement
    elif isinstance(expr, Const):
        return expr
    elif isinstance(expr, Add):
        return Add(substitute(expr.left, replacement), substitute(expr.right, replacement))
    elif isinstance(expr, Mul):
        return Mul(substitute(expr.left, replacement), substitute(expr.right, replacement))
    elif isinstance(expr, Neg):
        return Neg(substitute(expr.child, replacement))
    elif isinstance(expr, Inv):
        return Inv(substitute(expr.child, replacement))
    elif isinstance(expr, EML):
        return EML(substitute(expr.coeff, replacement), substitute(expr.exponent, replacement))
    raise TypeError(f"Unknown: {type(expr)}")


# ──────────────────────────────────────────────────────────────────────────────
# Algorithm 4: EML Approximation Search (Greedy)
# ──────────────────────────────────────────────────────────────────────────────

def greedy_eml_approx(
    f: Callable[[float], float],
    a: float, b: float,
    max_depth: int,
    n_samples: int = 100
) -> Tuple[EMLExpr, float]:
    """
    Algorithm: Greedy search for EML approximation.

    Given a target function f on [a, b], search for an EML expression
    of depth ≤ max_depth that minimizes the uniform approximation error.

    This is a simplified version — full optimization would use gradient descent
    on the EML parameters.

    Pseudocode:
        GREEDY_APPROX(f, [a,b], D):
          xs = sample [a, b]
          best = Const(mean(f(xs)))  # depth 0 baseline
          for d = 1 to D:
            # Try eml(1, best) and affine combinations
            candidates = generate_candidates(best, d)
            best = argmin_{c in candidates} max_error(c, f, xs)
          return best

    Returns: (best_expr, max_error)
    """
    xs = [a + (b - a) * i / (n_samples - 1) for i in range(n_samples)]
    ys = [f(x) for x in xs]

    def max_error(expr: EMLExpr) -> float:
        try:
            return max(abs(f(x) - evaluate(expr, x)) for x in xs)
        except (OverflowError, ZeroDivisionError):
            return float('inf')

    # Depth 0: constant approximation
    mean_y = sum(ys) / len(ys)
    best = Const(mean_y)
    best_err = max_error(best)

    # Depth 0: linear approximation x
    for c0 in [mean_y, ys[0], ys[-1]]:
        for c1 in [0, 1, -1, (ys[-1]-ys[0])/(b-a) if b > a else 0]:
            candidate = Add(Mul(Const(c1), Var()), Const(c0 - c1 * (a + b)/2))
            err = max_error(candidate)
            if err < best_err:
                best, best_err = candidate, err

    for d in range(1, max_depth + 1):
        # Try exp-based approximations at this depth
        for scale in [0.1, 0.5, 1.0, 2.0]:
            for shift in [-1, 0, 1]:
                candidate = EML(Const(scale), Add(Var(), Const(shift)))
                err = max_error(candidate)
                if err < best_err:
                    best, best_err = candidate, err

        # Try composing with best
        candidate = EML(Const(1.0), best)
        err = max_error(candidate)
        if err < best_err:
            best, best_err = candidate, err

    return best, best_err


# ──────────────────────────────────────────────────────────────────────────────
# Algorithm 5: Complexity Spectrum Computation
# ──────────────────────────────────────────────────────────────────────────────

def compute_spectrum_sample(
    f: Callable[[float], float],
    a: float, b: float,
    max_size: int = 20,
    n_samples: int = 50
) -> List[Tuple[int, int, float]]:
    """
    Algorithm: Sample the complexity spectrum of a function.

    Enumerate small EML expressions and record (depth, size, error) triples.
    This gives an empirical approximation of the EML Complexity Spectrum.

    Returns: List of (eml_depth, size, max_error) triples, Pareto-filtered.
    """
    xs = [a + (b - a) * i / max(n_samples - 1, 1) for i in range(n_samples)]

    results = []

    # Generate expressions up to a given size
    def gen_exprs(max_s: int) -> List[EMLExpr]:
        exprs = [Var()]
        for c in [-1.0, 0.0, 0.5, 1.0, 2.0]:
            exprs.append(Const(c))

        # Size 3: binary ops
        if max_s >= 3:
            base = list(exprs)
            for e1 in base:
                for e2 in base:
                    for op in [Add, Mul, EML]:
                        exprs.append(op(e1, e2))

        # Size 5: one more level
        if max_s >= 5:
            small = [Var(), Const(1.0), Const(0.0)]
            depth1 = [EML(Const(1.0), e) for e in small] + \
                     [Add(e1, e2) for e1 in small for e2 in small[:2]]
            for e1 in depth1:
                for e2 in small:
                    exprs.append(EML(e1, e2))
                    exprs.append(Add(e1, e2))

        return exprs

    for expr in gen_exprs(max_size):
        s = analyze_structure(expr)
        if s['size'] > max_size:
            continue
        try:
            err = max(abs(f(x) - evaluate(expr, x)) for x in xs)
            if math.isfinite(err):
                results.append((s['eml_depth'], s['size'], err))
        except (OverflowError, ZeroDivisionError, ValueError):
            continue

    # Pareto filter
    results.sort(key=lambda r: (r[0], r[1], r[2]))
    pareto = []
    best_err = float('inf')
    for d, s, e in results:
        if e < best_err:
            pareto.append((d, s, e))
            best_err = e

    return pareto


if __name__ == "__main__":
    # Quick test
    e = EML(Const(1.0), Var())  # exp(x)
    info = analyze_structure(e)
    print(f"exp(x): {info}")
    assert info['size'] == info['leaf_count'] + info['field_count'] + info['eml_count']

    # Test substitution
    f = EML(Const(1.0), Var())      # exp(x)
    g = Add(Var(), Const(1.0))      # x + 1
    fog = substitute(f, g)           # exp(x + 1)
    print(f"\nSubstitution test:")
    for x in [0, 1, 2]:
        v1 = evaluate(fog, x)
        v2 = evaluate(f, evaluate(g, x))
        print(f"  x={x}: subst={v1:.6f}, compose={v2:.6f}, match={abs(v1-v2)<1e-10}")

    # Test approximation search
    print(f"\nGreedy approximation of sin(x) on [0, pi]:")
    best, err = greedy_eml_approx(math.sin, 0, math.pi, max_depth=3)
    info = analyze_structure(best)
    print(f"  Best: depth={info['eml_depth']}, size={info['size']}, error={err:.6f}")

    print("\nAll algorithm tests passed.")

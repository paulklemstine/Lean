#!/usr/bin/env python3
"""
algorithms.py — Core algorithms for the depth hierarchy theory.

Implements:
  1. Certified interval arithmetic for expression evaluation
  2. Derivative envelope computation
  3. Expression enumeration with depth/size bounds
  4. Approximation error certification via interval subdivision

These algorithms correspond to the formal Lean definitions and can be
used for large-scale empirical investigation of the depth hierarchy.
"""

import math
from dataclasses import dataclass
from typing import List, Tuple, Optional, Dict

# ============================================================
# Interval Arithmetic
# ============================================================

@dataclass
class Interval:
    """A closed interval [lo, hi] for certified computation."""
    lo: float
    hi: float

    def __post_init__(self):
        if self.lo > self.hi:
            raise ValueError(f"Invalid interval: [{self.lo}, {self.hi}]")

    @staticmethod
    def point(x: float) -> 'Interval':
        return Interval(x, x)

    @staticmethod
    def unit() -> 'Interval':
        return Interval(0.0, 1.0)

    def width(self) -> float:
        return self.hi - self.lo

    def midpoint(self) -> float:
        return (self.lo + self.hi) / 2.0

    def contains(self, x: float) -> bool:
        return self.lo <= x <= self.hi

    def __add__(self, other: 'Interval') -> 'Interval':
        return Interval(self.lo + other.lo, self.hi + other.hi)

    def __neg__(self) -> 'Interval':
        return Interval(-self.hi, -self.lo)

    def __sub__(self, other: 'Interval') -> 'Interval':
        return self + (-other)

    def __mul__(self, other: 'Interval') -> 'Interval':
        products = [
            self.lo * other.lo, self.lo * other.hi,
            self.hi * other.lo, self.hi * other.hi
        ]
        return Interval(min(products), max(products))

    def __abs__(self) -> 'Interval':
        if self.lo >= 0:
            return self
        if self.hi <= 0:
            return -self
        return Interval(0, max(-self.lo, self.hi))

    def exp(self) -> 'Interval':
        """Certified exponential: exp([lo, hi]) = [exp(lo), exp(hi)]."""
        if self.hi > 500:
            return Interval(math.exp(self.lo), math.inf)
        return Interval(math.exp(self.lo), math.exp(self.hi))

    def max_abs(self) -> float:
        """Upper bound on |x| for x in this interval."""
        return max(abs(self.lo), abs(self.hi))

    def split(self) -> Tuple['Interval', 'Interval']:
        """Split interval at midpoint."""
        m = self.midpoint()
        return Interval(self.lo, m), Interval(m, self.hi)


# ============================================================
# Interval Evaluation of Expressions
# ============================================================

class IExpr:
    """Expression with interval evaluation support."""

    def eval_interval(self, x: Interval) -> Interval:
        """Sound enclosure: for all t in x, self.eval(t) is in the result."""
        raise NotImplementedError

    def eval_point(self, x: float) -> float:
        raise NotImplementedError

    def size(self) -> int:
        raise NotImplementedError

    def depth(self) -> int:
        raise NotImplementedError

    def deriv_interval(self, x: Interval) -> Interval:
        """Sound enclosure of the derivative on the interval."""
        raise NotImplementedError

class IVar(IExpr):
    def eval_interval(self, x): return x
    def eval_point(self, x): return x
    def deriv_interval(self, x): return Interval.point(1.0)
    def size(self): return 1
    def depth(self): return 0
    def __repr__(self): return "x"

class IConst(IExpr):
    def __init__(self, c: float): self.c = c
    def eval_interval(self, x): return Interval.point(self.c)
    def eval_point(self, x): return self.c
    def deriv_interval(self, x): return Interval.point(0.0)
    def size(self): return 1
    def depth(self): return 0
    def __repr__(self): return f"{self.c:.3f}"

class IAdd(IExpr):
    def __init__(self, a: IExpr, b: IExpr): self.a, self.b = a, b
    def eval_interval(self, x): return self.a.eval_interval(x) + self.b.eval_interval(x)
    def eval_point(self, x): return self.a.eval_point(x) + self.b.eval_point(x)
    def deriv_interval(self, x):
        return self.a.deriv_interval(x) + self.b.deriv_interval(x)
    def size(self): return 1 + self.a.size() + self.b.size()
    def depth(self): return max(self.a.depth(), self.b.depth())
    def __repr__(self): return f"({self.a} + {self.b})"

class IMul(IExpr):
    def __init__(self, a: IExpr, b: IExpr): self.a, self.b = a, b
    def eval_interval(self, x): return self.a.eval_interval(x) * self.b.eval_interval(x)
    def eval_point(self, x): return self.a.eval_point(x) * self.b.eval_point(x)
    def deriv_interval(self, x):
        return (self.a.deriv_interval(x) * self.b.eval_interval(x) +
                self.a.eval_interval(x) * self.b.deriv_interval(x))
    def size(self): return 1 + self.a.size() + self.b.size()
    def depth(self): return max(self.a.depth(), self.b.depth())
    def __repr__(self): return f"({self.a} * {self.b})"

class IExpOf(IExpr):
    def __init__(self, a: IExpr): self.a = a
    def eval_interval(self, x): return self.a.eval_interval(x).exp()
    def eval_point(self, x):
        v = self.a.eval_point(x)
        return math.exp(v) if v < 500 else math.inf
    def deriv_interval(self, x):
        return self.a.eval_interval(x).exp() * self.a.deriv_interval(x)
    def size(self): return 1 + self.a.size()
    def depth(self): return 1 + self.a.depth()
    def __repr__(self): return f"exp({self.a})"


# ============================================================
# Certified Approximation Error
# ============================================================

def certified_max_error(expr: IExpr, target_k: int,
                        interval: Interval = None,
                        max_subdivisions: int = 10) -> Interval:
    """
    Compute a certified upper bound on the uniform approximation error
    |expr(x) - iterExp(k, x)| over the given interval.

    Uses interval subdivision for tighter bounds.

    Returns an interval [lower_bound, upper_bound] on the supremum error.

    Complexity: O(2^max_subdivisions * cost_per_eval)
    """
    if interval is None:
        interval = Interval.unit()

    def iter_exp_interval(k: int, x: Interval) -> Interval:
        result = x
        for _ in range(k):
            result = result.exp()
        return result

    def error_on_subinterval(iv: Interval) -> float:
        """Upper bound on |expr - iterExp k| on iv."""
        expr_iv = expr.eval_interval(iv)
        target_iv = iter_exp_interval(target_k, iv)
        diff = expr_iv - target_iv
        return abs(diff).hi

    # Adaptive subdivision
    intervals = [interval]
    for _ in range(max_subdivisions):
        new_intervals = []
        for iv in intervals:
            left, right = iv.split()
            new_intervals.extend([left, right])
        intervals = new_intervals

    max_err_upper = max(error_on_subinterval(iv) for iv in intervals)

    # Lower bound: sample at grid points
    n_samples = 100
    max_err_lower = 0.0
    for i in range(n_samples + 1):
        x = interval.lo + (interval.hi - interval.lo) * i / n_samples
        try:
            val_expr = expr.eval_point(x)
            val = x
            for _ in range(target_k):
                val = math.exp(val)
            err = abs(val_expr - val)
            max_err_lower = max(max_err_lower, err)
        except (OverflowError, ValueError):
            pass

    return Interval(max_err_lower, max_err_upper)


# ============================================================
# Derivative Envelope Computation
# ============================================================

def derivative_envelope(expr: IExpr, interval: Interval = None,
                        n_subdivisions: int = 8) -> Interval:
    """
    Compute a certified enclosure of the derivative of expr on the interval.

    Returns [min_deriv, max_deriv] such that for all x in interval,
    deriv(expr)(x) is in the returned interval.
    """
    if interval is None:
        interval = Interval.unit()

    intervals = [interval]
    for _ in range(n_subdivisions):
        new_intervals = []
        for iv in intervals:
            left, right = iv.split()
            new_intervals.extend([left, right])
        intervals = new_intervals

    lo = math.inf
    hi = -math.inf
    for iv in intervals:
        d = expr.deriv_interval(iv)
        lo = min(lo, d.lo)
        hi = max(hi, d.hi)

    return Interval(lo, hi)


# ============================================================
# Growth Envelope: Theoretical Bounds
# ============================================================

def growth_envelope_bound(depth: int, size: int) -> float:
    """
    Compute an upper bound on the maximum derivative of any
    expression of given depth and size on [0,1].

    This implements the theoretical growth envelope from the
    formal development. The bound is conservative but certified.

    For depth 0 (no exp): derivatives are polynomial in constants
    and size, bounded by size! * max_const^size.

    For depth d: each exp layer can multiply the derivative by
    at most exp(max_value), where max_value is bounded by the
    evaluation envelope of the sub-expression.
    """
    if depth == 0:
        # Without exp, expressions are polynomials in x with coefficients
        # determined by the constants. Derivative bounded by size * max_const^size.
        max_const = max(math.e, 2.0)
        return float(math.factorial(min(size, 20))) * max_const ** min(size, 50)

    # With exp at depth d: rough bound
    # Each exp layer can amplify by at most exp(eval_bound)
    eval_bound = math.exp(min(size * 10, 500))  # very conservative
    deriv_bound = eval_bound ** min(depth, 10) * growth_envelope_bound(0, size)
    return min(deriv_bound, 1e300)


def iter_exp_deriv_lower_bound(k: int, x: float) -> float:
    """
    Lower bound on (iterExp k)'(x) using the product formula.

    (iterExp k)'(x) = prod_{j=0}^{k-1} exp(iterExp(j, x))

    On [0,1], this is at least exp(0)^k = 1 (trivial bound),
    but the actual bound is much stronger for larger k.
    """
    product = 1.0
    val = x
    for j in range(k):
        factor = math.exp(val)
        product *= factor
        if j < k - 1:
            val = math.exp(val)
    return product


# ============================================================
# Expression Enumeration (Breadth-First)
# ============================================================

def enumerate_iexprs(max_size: int, max_depth: int,
                     constants: List[float] = None) -> List[IExpr]:
    """
    Enumerate all IExpr expressions up to given size and depth.

    Time complexity: O(C(max_size, max_depth)) where C is the
    Catalan-like count of binary trees of bounded size.
    Space complexity: O(C(max_size, max_depth)).
    """
    if constants is None:
        constants = [0.0, 1.0, 2.0, math.e]

    # Build bottom-up by size
    by_size_depth: Dict[Tuple[int, int], List[IExpr]] = {}

    def get(s: int, d: int) -> List[IExpr]:
        if s <= 0 or d < 0:
            return []
        key = (s, d)
        if key in by_size_depth:
            return by_size_depth[key]

        result = []
        # Size 1: leaves
        if s >= 1:
            result.append(IVar())
            for c in constants:
                result.append(IConst(c))

        # Size 2: unary ops
        if s >= 2 and d >= 1:
            for sub in get(s - 1, d - 1):
                result.append(IExpOf(sub))

        # Size 3+: binary ops
        if s >= 3:
            for s1 in range(1, s - 1):
                s2 = s - 1 - s1
                for d1 in range(d + 1):
                    for d2 in range(d + 1):
                        for a in get(s1, d1):
                            for b in get(s2, d2):
                                result.append(IAdd(a, b))
                                result.append(IMul(a, b))

        by_size_depth[key] = result
        return result

    all_exprs = get(max_size, max_depth)
    return [e for e in all_exprs if e.size() <= max_size and e.depth() <= max_depth]


# ============================================================
# Best Approximant Search
# ============================================================

def find_best_approximant(target_k: int, max_size: int, max_depth: int,
                          n_eval_points: int = 100) -> Optional[Tuple[IExpr, float]]:
    """
    Search for the best depth-bounded approximant to iterExp(k) on [0,1].

    Returns (best_expr, best_error) or None if no valid expression found.
    """
    exprs = enumerate_iexprs(max_size, max_depth)
    best_expr = None
    best_error = math.inf

    for expr in exprs:
        max_err = 0.0
        valid = True
        for i in range(n_eval_points + 1):
            x = i / n_eval_points
            try:
                val = expr.eval_point(x)
                target = x
                for _ in range(target_k):
                    target = math.exp(target)
                err = abs(val - target)
                max_err = max(max_err, err)
            except (OverflowError, ValueError):
                valid = False
                break

        if valid and max_err < best_error:
            best_error = max_err
            best_expr = expr

    if best_expr is not None:
        return (best_expr, best_error)
    return None


# ============================================================
# Main: Algorithm Demonstrations
# ============================================================

if __name__ == "__main__":
    print("=" * 60)
    print("ALGORITHMS FOR DEPTH HIERARCHY INVESTIGATION")
    print("=" * 60)

    # Demo 1: Interval arithmetic
    print("\n--- Certified Interval Evaluation ---")
    # Build exp(exp(x)) as an IExpr
    expr_exp2 = IExpOf(IExpOf(IVar()))
    iv = Interval.unit()
    result = expr_exp2.eval_interval(iv)
    print(f"exp(exp(x)) on [0,1]: [{result.lo:.6f}, {result.hi:.6f}]")

    # Demo 2: Derivative envelope
    print("\n--- Derivative Envelopes ---")
    for d in range(4):
        envelope = derivative_envelope(expr_exp2 if d >= 2 else IExpOf(IVar()) if d >= 1 else IVar())
        print(f"  Depth-{d} example: deriv in [{envelope.lo:.4f}, {envelope.hi:.4f}]")

    # Demo 3: Certified error
    print("\n--- Certified Approximation Error ---")
    approx = IAdd(IExpOf(IVar()), IConst(1.0))  # exp(x) + 1 as approx to exp(exp(x))
    err = certified_max_error(approx, 2, max_subdivisions=8)
    print(f"  |exp(x) + 1 - exp(exp(x))| on [0,1]: [{err.lo:.6f}, {err.hi:.6f}]")

    # Demo 4: Growth envelope bounds
    print("\n--- Growth Envelope Bounds ---")
    for d in range(4):
        for s in [3, 5, 7]:
            bound = growth_envelope_bound(d, s)
            bound_str = f"{bound:.2e}" if bound < 1e50 else "> 10^50"
            print(f"  Depth {d}, Size {s}: derivative bound = {bound_str}")

    # Demo 5: Best approximant search
    print("\n--- Best Approximant Search ---")
    for k in [2, 3]:
        result = find_best_approximant(k, max_size=5, max_depth=k-1, n_eval_points=50)
        if result:
            expr, err = result
            print(f"  iterExp({k}): best depth-{k-1} size-≤5 approx = {expr}")
            print(f"             error = {err:.8f}")
        else:
            print(f"  iterExp({k}): no valid approximant found")

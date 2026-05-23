#!/usr/bin/env python3
"""
Algorithms for the Spectral Margin Framework

Implements the key algorithms from the research paper:
1. ControlledInvMajorantHeight — compute poly-tower majorant height
2. EstimateSpectralMargin — numerical spectral margin estimation
3. HasControlledInverses — recursive structural check
4. GrowthComparison — compare expression growth with iterExp bounds

All algorithms include docstrings, type hints, and example usage.
"""

import math
from dataclasses import dataclass, field
from typing import Optional
from enum import Enum, auto


# ==============================================================================
# Data Structures
# ==============================================================================

class NodeType(Enum):
    """EML expression node types."""
    VAR = auto()
    CONST = auto()
    ADD = auto()
    MUL = auto()
    NEG = auto()
    INV = auto()
    EML = auto()


@dataclass
class Expr:
    """
    EML expression tree.

    The EML language is: var, const(c), add(a,b), mul(a,b), neg(a), inv(a), eml(a,b).
    eml(a, b) represents a * exp(b).
    """
    kind: NodeType
    value: float = 0.0
    children: list = field(default_factory=list)

    def eval(self, x: float) -> float:
        """Evaluate expression at point x."""
        if self.kind == NodeType.VAR:
            return x
        elif self.kind == NodeType.CONST:
            return self.value
        elif self.kind == NodeType.ADD:
            return self.children[0].eval(x) + self.children[1].eval(x)
        elif self.kind == NodeType.MUL:
            return self.children[0].eval(x) * self.children[1].eval(x)
        elif self.kind == NodeType.NEG:
            return -self.children[0].eval(x)
        elif self.kind == NodeType.INV:
            v = self.children[0].eval(x)
            return 1.0 / v if v != 0 else float('inf')
        elif self.kind == NodeType.EML:
            a = self.children[0].eval(x)
            b = self.children[1].eval(x)
            try:
                return a * math.exp(b)
            except OverflowError:
                return float('inf') if a > 0 else float('-inf')
        raise ValueError(f"Unknown node type: {self.kind}")

    @property
    def eml_depth(self) -> int:
        """Compute the EML depth (max nesting of eml operations)."""
        if self.kind in (NodeType.VAR, NodeType.CONST):
            return 0
        elif self.kind in (NodeType.ADD, NodeType.MUL):
            return max(c.eml_depth for c in self.children)
        elif self.kind in (NodeType.NEG, NodeType.INV):
            return self.children[0].eml_depth
        elif self.kind == NodeType.EML:
            return 1 + max(c.eml_depth for c in self.children)
        return 0

    @property
    def size(self) -> int:
        """Number of nodes in the expression tree."""
        return 1 + sum(c.size for c in self.children)


# ==============================================================================
# Algorithm 1: Spectral Margin Estimation
# ==============================================================================

def estimate_spectral_margin(
    expr: Expr,
    num_samples: int = 10000,
    x_min: float = 1e-6,
    x_max: float = 1e6,
    refine_steps: int = 50
) -> float:
    """
    Estimate the spectral margin of an EML expression.

    The spectral margin is inf { |eval(e, x)| : x > 0 }.

    Algorithm:
    1. Generate log-spaced sample points in [x_min, x_max].
    2. Evaluate |e(x)| at each point and find the minimum.
    3. Refine around the minimum using golden section search.

    Args:
        expr: The EML expression to evaluate.
        num_samples: Number of initial sample points.
        x_min: Lower bound of sampling range.
        x_max: Upper bound of sampling range.
        refine_steps: Number of golden section refinement steps.

    Returns:
        Estimated lower bound on spectralMargin(e).

    Complexity:
        Time: O(num_samples * |expr| + refine_steps * |expr|)
        Space: O(|expr|) for recursion

    Example:
        >>> e = Expr(NodeType.ADD, children=[
        ...     Expr(NodeType.VAR),
        ...     Expr(NodeType.CONST, value=1.0)
        ... ])
        >>> estimate_spectral_margin(e)  # x + 1 on (0, inf), margin ≈ 1.0
        1.0001...
    """
    # Phase 1: Coarse sampling
    best_x = x_min
    best_val = float('inf')

    log_min = math.log10(x_min)
    log_max = math.log10(x_max)

    for i in range(num_samples):
        t = log_min + (log_max - log_min) * i / (num_samples - 1)
        x = 10.0 ** t
        try:
            val = abs(expr.eval(x))
            if val < best_val:
                best_val = val
                best_x = x
        except (OverflowError, ZeroDivisionError, ValueError):
            pass

    # Phase 2: Golden section refinement around best_x
    phi = (1 + math.sqrt(5)) / 2
    a = max(x_min, best_x / 100)
    b = min(x_max, best_x * 100)

    for _ in range(refine_steps):
        x1 = b - (b - a) / phi
        x2 = a + (b - a) / phi
        try:
            f1 = abs(expr.eval(x1))
            f2 = abs(expr.eval(x2))
            if f1 < f2:
                b = x2
                if f1 < best_val:
                    best_val = f1
            else:
                a = x1
                if f2 < best_val:
                    best_val = f2
        except (OverflowError, ZeroDivisionError, ValueError):
            break

    return best_val


# ==============================================================================
# Algorithm 2: Controlled Inverses Check
# ==============================================================================

@dataclass
class ControlledInversesResult:
    """Result of checking for controlled inverses."""
    is_controlled: bool
    min_spectral_margin: float
    inv_count: int
    uncontrolled_locations: list = field(default_factory=list)


def check_controlled_inverses(
    expr: Expr,
    margin_threshold: float = 1e-6
) -> ControlledInversesResult:
    """
    Check if an EML expression has controlled inverses.

    An expression has controlled inverses if every inv node's argument
    has spectral margin > 0 (estimated above margin_threshold).

    Args:
        expr: The EML expression to check.
        margin_threshold: Minimum spectral margin to consider "controlled".

    Returns:
        ControlledInversesResult with details about the check.

    Complexity:
        Time: O(|expr| * sampling_cost) where sampling_cost is the
              spectral margin estimation cost per inv node.
        Space: O(|expr|)

    Example:
        >>> e = Expr(NodeType.INV, children=[
        ...     Expr(NodeType.ADD, children=[
        ...         Expr(NodeType.VAR),
        ...         Expr(NodeType.CONST, value=1.0)
        ...     ])
        ... ])
        >>> result = check_controlled_inverses(e)
        >>> result.is_controlled
        True
    """
    result = ControlledInversesResult(
        is_controlled=True,
        min_spectral_margin=float('inf'),
        inv_count=0
    )

    def _check(e: Expr, path: str = "root"):
        if e.kind in (NodeType.VAR, NodeType.CONST):
            return
        elif e.kind == NodeType.INV:
            result.inv_count += 1
            margin = estimate_spectral_margin(e.children[0], num_samples=5000)
            result.min_spectral_margin = min(result.min_spectral_margin, margin)
            if margin < margin_threshold:
                result.is_controlled = False
                result.uncontrolled_locations.append(
                    f"{path}/inv (margin ≈ {margin:.2e})"
                )
            _check(e.children[0], f"{path}/inv/arg")
        elif e.kind == NodeType.NEG:
            _check(e.children[0], f"{path}/neg")
        else:
            for i, child in enumerate(e.children):
                _check(child, f"{path}/{e.kind.name.lower()}/{i}")

    _check(expr)
    return result


# ==============================================================================
# Algorithm 3: Poly-Tower Majorant Height
# ==============================================================================

@dataclass
class MajorantInfo:
    """Information about a poly-tower majorant."""
    height: int
    C: float
    N: int
    description: str = ""


def compute_majorant_height(expr: Expr) -> MajorantInfo:
    """
    Compute the poly-tower majorant height for a controlled-inverse expression.

    For an expression e with controlled inverses of depth D,
    |eval(e, x)| ≤ iterExp(h, C * x^N) for large x.

    The KEY insight: inv nodes contribute height 0 (constants are bounded).
    Only eml nodes increase the height.

    Args:
        expr: The EML expression (assumed to have controlled inverses).

    Returns:
        MajorantInfo with height, constants, and description.

    Complexity:
        Time: O(|expr| * spectral_margin_cost) for inv nodes
        Space: O(depth(expr)) for recursion

    Example:
        >>> e = Expr(NodeType.EML, children=[
        ...     Expr(NodeType.CONST, value=1.0),
        ...     Expr(NodeType.VAR)
        ... ])
        >>> info = compute_majorant_height(e)
        >>> info.height
        1
    """
    if expr.kind == NodeType.VAR:
        return MajorantInfo(0, 1.0, 1, "var: |x| ≤ x")
    elif expr.kind == NodeType.CONST:
        return MajorantInfo(0, abs(expr.value) + 1, 0,
                           f"const({expr.value}): bounded by {abs(expr.value)+1}")
    elif expr.kind == NodeType.NEG:
        info = compute_majorant_height(expr.children[0])
        info.description = f"neg: same as child ({info.description})"
        return info
    elif expr.kind == NodeType.INV:
        margin = estimate_spectral_margin(expr.children[0], num_samples=5000)
        if margin > 0:
            bound = 1.0 / margin + 1
            return MajorantInfo(0, bound, 0,
                              f"inv: |1/f| ≤ {bound:.4f} (margin={margin:.6f}). "
                              f"HEIGHT STAYS AT 0!")
        else:
            return MajorantInfo(0, float('inf'), 0,
                              "inv: UNCONTROLLED (margin ≈ 0)")
    elif expr.kind == NodeType.ADD:
        left = compute_majorant_height(expr.children[0])
        right = compute_majorant_height(expr.children[1])
        h = max(left.height, right.height)
        C = 2 * (left.C + right.C) + math.log(2)
        N = max(left.N, right.N) + 1
        return MajorantInfo(h, C, N,
                           f"add: max({left.height},{right.height})={h}")
    elif expr.kind == NodeType.MUL:
        left = compute_majorant_height(expr.children[0])
        right = compute_majorant_height(expr.children[1])
        h = max(left.height, right.height)
        C = left.C + right.C
        N = left.N + right.N
        return MajorantInfo(h, C, N,
                           f"mul: max({left.height},{right.height})={h}")
    elif expr.kind == NodeType.EML:
        left = compute_majorant_height(expr.children[0])
        right = compute_majorant_height(expr.children[1])
        h = max(left.height, right.height) + 1
        C = left.C + right.C + 1
        N = left.N + right.N + 1
        return MajorantInfo(h, C, N,
                           f"eml: max({left.height},{right.height})+1={h}")
    return MajorantInfo(0, 1.0, 0, "unknown")


# ==============================================================================
# Algorithm 4: Growth Comparison
# ==============================================================================

def iter_exp(n: int, x: float) -> float:
    """Compute iterExp(n, x) = exp^n(x)."""
    result = x
    for _ in range(n):
        try:
            result = math.exp(result)
        except OverflowError:
            return float('inf')
    return result


def compare_growth(
    expr: Expr,
    depth: int,
    test_points: list[float] = None
) -> dict:
    """
    Compare expression growth with iterExp(depth+1, x).

    Args:
        expr: The EML expression to evaluate.
        depth: The depth D of the expression.
        test_points: Points at which to evaluate.

    Returns:
        Dictionary mapping x to (expr_val, iterExp_val, ratio).

    Example:
        >>> e = Expr(NodeType.EML, children=[
        ...     Expr(NodeType.CONST, value=1.0),
        ...     Expr(NodeType.VAR)
        ... ])
        >>> results = compare_growth(e, 1, [1, 2, 5])
    """
    if test_points is None:
        test_points = [0.5, 1, 2, 3, 5, 10, 20, 50]

    results = {}
    for x in test_points:
        try:
            expr_val = expr.eval(x)
            ie_val = iter_exp(depth + 1, x)
            ratio = expr_val / ie_val if ie_val != float('inf') and ie_val > 0 else 0
            results[x] = {
                'expr_value': expr_val,
                'iterExp_value': ie_val,
                'ratio': ratio,
                'dominated': expr_val < ie_val
            }
        except (OverflowError, ZeroDivisionError):
            results[x] = {
                'expr_value': float('inf'),
                'iterExp_value': float('inf'),
                'ratio': None,
                'dominated': None
            }
    return results


# ==============================================================================
# Example Usage
# ==============================================================================

if __name__ == "__main__":
    print("=" * 60)
    print("SPECTRAL MARGIN FRAMEWORK — ALGORITHMS")
    print("=" * 60)

    # Build expression: exp(x) * (1/(x+1))
    x = Expr(NodeType.VAR)
    one = Expr(NodeType.CONST, value=1.0)
    x_plus_1 = Expr(NodeType.ADD, children=[x, one])
    inv_xp1 = Expr(NodeType.INV, children=[x_plus_1])
    exp_x = Expr(NodeType.EML, children=[one, x])
    expr = Expr(NodeType.MUL, children=[exp_x, inv_xp1])

    print(f"\nExpression: exp(x) * (1/(x+1))")
    print(f"EML Depth: {expr.eml_depth}")
    print(f"Size: {expr.size}")

    # Algorithm 1: Spectral margin
    margin = estimate_spectral_margin(x_plus_1)
    print(f"\nSpectral margin of (x+1): {margin:.6f}")

    # Algorithm 2: Controlled inverses check
    result = check_controlled_inverses(expr)
    print(f"\nControlled inverses: {result.is_controlled}")
    print(f"  Inv count: {result.inv_count}")
    print(f"  Min margin: {result.min_spectral_margin:.6f}")

    # Algorithm 3: Majorant height
    info = compute_majorant_height(expr)
    print(f"\nMajorant height: {info.height}")
    print(f"  C ≈ {info.C:.4f}, N = {info.N}")
    print(f"  Description: {info.description}")

    # Algorithm 4: Growth comparison
    print(f"\nGrowth comparison with iterExp({expr.eml_depth + 1}, x):")
    growth = compare_growth(expr, expr.eml_depth, [1, 2, 5, 10])
    for x_val, data in growth.items():
        dom = "✓ dominated" if data['dominated'] else "✗ not dominated"
        print(f"  x={x_val}: f(x)={data['expr_value']:.4g}, "
              f"iterExp={data['iterExp_value']:.4g}, {dom}")

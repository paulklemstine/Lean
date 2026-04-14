#!/usr/bin/env python3
"""
EML Symbolic Regression Engine v3

Given data points (x, y), finds the simplest EML tree expression
f(x) that approximates y = f(x).

Key insight from the EML framework:
  The search space for depth-n EML trees is parameterized by
  5·2ⁿ − 6 real parameters (affine transformations at leaves),
  vs the combinatorial explosion of traditional symbolic regression.

This demo implements:
1. EML tree parameterization with continuous optimization
2. Depth-annealing: start shallow, increase depth
3. Multi-start optimization for robustness
4. Comparison with known physics formulas
"""

import math
import random
import sys
from typing import List, Tuple, Optional, Callable

# ============================================================
# Parameterized EML Tree
# ============================================================

class ParamEMLNode:
    """A node in a parameterized EML tree.
    Each leaf computes a*x + b (affine transformation).
    Each internal node computes eml(left, right) = exp(left) - ln(right).
    """
    pass

class ParamLeaf(ParamEMLNode):
    def __init__(self, a: float = 1.0, b: float = 0.0):
        self.a = a  # slope
        self.b = b  # intercept

    def eval(self, x: float) -> Optional[float]:
        return self.a * x + self.b

    def param_count(self) -> int:
        return 2

    def get_params(self) -> List[float]:
        return [self.a, self.b]

    def set_params(self, params: List[float]) -> int:
        self.a = params[0]
        self.b = params[1]
        return 2

    def __repr__(self):
        if abs(self.a) < 1e-10:
            return f"{self.b:.4f}"
        if abs(self.b) < 1e-10:
            return f"{self.a:.4f}·x"
        return f"({self.a:.4f}·x + {self.b:.4f})"

class ParamNode(ParamEMLNode):
    def __init__(self, left: ParamEMLNode, right: ParamEMLNode,
                 a: float = 1.0, b: float = 0.0):
        self.left = left
        self.right = right
        self.a = a  # output scaling
        self.b = b  # output shift

    def eval(self, x: float) -> Optional[float]:
        l = self.left.eval(x)
        r = self.right.eval(x)
        if l is None or r is None:
            return None
        try:
            exp_val = math.exp(l)
            if r <= 0:
                return None
            log_val = math.log(r)
            result = self.a * (exp_val - log_val) + self.b
            if math.isnan(result) or math.isinf(result):
                return None
            return result
        except (OverflowError, ValueError):
            return None

    def param_count(self) -> int:
        return 2 + self.left.param_count() + self.right.param_count()

    def get_params(self) -> List[float]:
        return [self.a, self.b] + self.left.get_params() + self.right.get_params()

    def set_params(self, params: List[float]) -> int:
        self.a = params[0]
        self.b = params[1]
        idx = 2
        idx += self.left.set_params(params[idx:])
        idx += self.right.set_params(params[idx:])
        return idx

    def __repr__(self):
        inner = f"eml({self.left}, {self.right})"
        if abs(self.a - 1) < 1e-10 and abs(self.b) < 1e-10:
            return inner
        return f"({self.a:.4f}·{inner} + {self.b:.4f})"

# ============================================================
# Tree Construction
# ============================================================

def make_balanced_tree(depth: int) -> ParamEMLNode:
    """Create a balanced parameterized EML tree of given depth."""
    if depth == 0:
        return ParamLeaf(random.gauss(0, 0.5), random.gauss(0, 0.5))
    left = make_balanced_tree(depth - 1)
    right = make_balanced_tree(depth - 1)
    return ParamNode(left, right, 1.0 + random.gauss(0, 0.1), random.gauss(0, 0.1))

def master_formula_params(depth: int) -> int:
    """Number of parameters in a depth-n balanced EML tree."""
    if depth == 0:
        return 2
    return 5 * 2**depth - 6

# ============================================================
# Loss Function and Optimization
# ============================================================

def compute_loss(tree: ParamEMLNode, data: List[Tuple[float, float]]) -> float:
    """Mean squared error on data."""
    total = 0.0
    count = 0
    for x, y_true in data:
        y_pred = tree.eval(x)
        if y_pred is not None:
            total += (y_pred - y_true) ** 2
            count += 1
    if count == 0:
        return float('inf')
    return total / count + (len(data) - count) * 1e6  # penalty for failures

def numerical_gradient(tree: ParamEMLNode, data: List[Tuple[float, float]],
                       eps: float = 1e-6) -> List[float]:
    """Compute numerical gradient of loss w.r.t. parameters."""
    params = tree.get_params()
    grad = []
    base_loss = compute_loss(tree, data)

    for i in range(len(params)):
        params_plus = params.copy()
        params_plus[i] += eps
        tree.set_params(params_plus)
        loss_plus = compute_loss(tree, data)
        grad.append((loss_plus - base_loss) / eps)
        tree.set_params(params)  # restore

    return grad

def gradient_descent(tree: ParamEMLNode, data: List[Tuple[float, float]],
                     lr: float = 0.001, steps: int = 1000,
                     verbose: bool = False) -> float:
    """Simple gradient descent optimization."""
    best_loss = float('inf')
    best_params = tree.get_params()

    for step in range(steps):
        loss = compute_loss(tree, data)
        if loss < best_loss:
            best_loss = loss
            best_params = tree.get_params()

        if verbose and step % 100 == 0:
            print(f"  Step {step:5d}: loss = {loss:.6e}")

        if loss < 1e-10:
            break

        grad = numerical_gradient(tree, data)
        params = tree.get_params()

        # Gradient clipping
        grad_norm = math.sqrt(sum(g**2 for g in grad) + 1e-20)
        if grad_norm > 10:
            grad = [g * 10 / grad_norm for g in grad]

        new_params = [p - lr * g for p, g in zip(params, grad)]
        tree.set_params(new_params)

    tree.set_params(best_params)
    return best_loss

# ============================================================
# Symbolic Regression
# ============================================================

def eml_regression(data: List[Tuple[float, float]],
                   max_depth: int = 3,
                   num_restarts: int = 10,
                   verbose: bool = True) -> Tuple[ParamEMLNode, float]:
    """Find the simplest EML tree fitting the data."""
    best_tree = None
    best_loss = float('inf')
    best_depth = 0

    for depth in range(max_depth + 1):
        n_params = master_formula_params(depth)
        if verbose:
            print(f"\n{'='*60}")
            print(f"Depth {depth}: {n_params} parameters, searching...")

        for restart in range(num_restarts):
            tree = make_balanced_tree(depth)
            loss = gradient_descent(tree, data, lr=0.01, steps=500)

            if loss < best_loss:
                best_loss = loss
                best_tree = tree
                best_depth = depth
                if verbose:
                    print(f"  Restart {restart}: loss = {loss:.6e} ← new best!")

            if best_loss < 1e-8:
                break

        if best_loss < 1e-8:
            if verbose:
                print(f"  Converged at depth {depth}!")
            break

    if verbose:
        print(f"\n{'='*60}")
        print(f"Best tree (depth {best_depth}, loss {best_loss:.6e}):")
        print(f"  {best_tree}")

    return best_tree, best_loss

# ============================================================
# Physics Benchmarks
# ============================================================

def generate_data(f: Callable, x_range: Tuple[float, float],
                  n: int = 50) -> List[Tuple[float, float]]:
    """Generate training data from a known function."""
    data = []
    for i in range(n):
        x = x_range[0] + (x_range[1] - x_range[0]) * i / (n - 1)
        try:
            y = f(x)
            if not math.isnan(y) and not math.isinf(y):
                data.append((x, y))
        except:
            pass
    return data

def benchmark_physics():
    """Benchmark EML regression on known physics formulas."""
    print("\n" + "=" * 70)
    print("EML SYMBOLIC REGRESSION — PHYSICS BENCHMARKS")
    print("=" * 70)

    benchmarks = [
        ("exp(x)", lambda x: math.exp(x), (0, 2)),
        ("x²", lambda x: x**2, (0, 3)),
        ("x³", lambda x: x**3, (0, 2)),
        ("1/x", lambda x: 1/x, (0.5, 3)),
        ("√x", lambda x: math.sqrt(x), (0.1, 5)),
        ("ln(x)", lambda x: math.log(x), (0.5, 5)),
        ("sin-approx (x - x³/6)", lambda x: x - x**3/6, (-1, 1)),
    ]

    results = []
    for name, f, x_range in benchmarks:
        print(f"\n{'—'*60}")
        print(f"Target: y = {name}")
        data = generate_data(f, x_range)
        tree, loss = eml_regression(data, max_depth=2, num_restarts=5, verbose=False)
        status = "✓" if loss < 1e-4 else "✗"
        print(f"  Result: {status} loss = {loss:.6e}")
        print(f"  Tree: {tree}")
        results.append((name, loss, status))

    print(f"\n{'='*60}")
    print("Summary:")
    print(f"{'Function':>30s}  {'Loss':>12s}  {'Status':>6s}")
    print("-" * 52)
    for name, loss, status in results:
        print(f"{name:>30s}  {loss:12.6e}  {status:>6s}")

# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║   EML SYMBOLIC REGRESSION ENGINE v3                     ║")
    print("║   Finding formulas with a single operation              ║")
    print("╚══════════════════════════════════════════════════════════╝")

    # Quick demo: fit exp(x) - should find eml(x, 1)
    print("\nQuick demo: fitting y = exp(x)")
    data = generate_data(lambda x: math.exp(x), (0, 2))
    tree, loss = eml_regression(data, max_depth=2, num_restarts=5)

    # Run benchmarks
    benchmark_physics()

    print(f"\nParameter growth: depth 1 → {master_formula_params(1)} params, "
          f"depth 2 → {master_formula_params(2)} params, "
          f"depth 3 → {master_formula_params(3)} params")

#!/usr/bin/env python3
"""
algorithms.py — EML Category: Core Algorithms

Type-hinted implementations of the key constructions in the EML category.
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import Callable, List, Optional, Tuple, Union
import numpy as np


# ============================================================
# 1. ScalarEMLTree: Explicit derivation trees
# ============================================================

@dataclass
class EMLTree:
    """Base class for EML derivation tree nodes."""
    pass

@dataclass
class Coord(EMLTree):
    """Coordinate projection: x ↦ x[i]"""
    index: int

@dataclass
class Const(EMLTree):
    """Constant: x ↦ c"""
    value: float

@dataclass
class Add(EMLTree):
    """Addition: x ↦ left(x) + right(x)"""
    left: EMLTree
    right: EMLTree

@dataclass
class Mul(EMLTree):
    """Multiplication: x ↦ left(x) * right(x)"""
    left: EMLTree
    right: EMLTree

@dataclass
class Exp(EMLTree):
    """Exponential: x ↦ exp(child(x))"""
    child: EMLTree

@dataclass
class Log(EMLTree):
    """Logarithm: x ↦ log(child(x))"""
    child: EMLTree


def evaluate(tree: EMLTree, x: np.ndarray) -> float:
    """Evaluate an EML derivation tree at input vector x."""
    if isinstance(tree, Coord):
        return float(x[tree.index])
    elif isinstance(tree, Const):
        return tree.value
    elif isinstance(tree, Add):
        return evaluate(tree.left, x) + evaluate(tree.right, x)
    elif isinstance(tree, Mul):
        return evaluate(tree.left, x) * evaluate(tree.right, x)
    elif isinstance(tree, Exp):
        return float(np.exp(evaluate(tree.child, x)))
    elif isinstance(tree, Log):
        return float(np.log(evaluate(tree.child, x)))
    else:
        raise ValueError(f"Unknown tree type: {type(tree)}")


def node_count(tree: EMLTree) -> int:
    """Count total nodes in the derivation tree."""
    if isinstance(tree, (Coord, Const)):
        return 1
    elif isinstance(tree, (Add, Mul)):
        return node_count(tree.left) + node_count(tree.right) + 1
    elif isinstance(tree, (Exp, Log)):
        return node_count(tree.child) + 1
    else:
        raise ValueError(f"Unknown tree type: {type(tree)}")


def depth(tree: EMLTree) -> int:
    """Compute depth (height) of the derivation tree."""
    if isinstance(tree, (Coord, Const)):
        return 0
    elif isinstance(tree, (Add, Mul)):
        return max(depth(tree.left), depth(tree.right)) + 1
    elif isinstance(tree, (Exp, Log)):
        return depth(tree.child) + 1
    else:
        raise ValueError(f"Unknown tree type: {type(tree)}")


# ============================================================
# 2. Category operations
# ============================================================

def identity_tree(n: int) -> List[EMLTree]:
    """Identity morphism: n trees, each projecting one coordinate."""
    return [Coord(i) for i in range(n)]


def compose_trees(
    outer: List[EMLTree],
    inner: List[EMLTree],
    n_input: int
) -> List[EMLTree]:
    """
    Compose EML vector maps at the tree level.
    outer: m trees in k variables (the g map)
    inner: k trees in n variables (the f map)
    Result: m trees in n variables (g ∘ f)

    Uses substitution: replace each Coord(i) in outer with inner[i].
    """
    def substitute(tree: EMLTree) -> EMLTree:
        if isinstance(tree, Coord):
            return inner[tree.index]
        elif isinstance(tree, Const):
            return tree
        elif isinstance(tree, Add):
            return Add(substitute(tree.left), substitute(tree.right))
        elif isinstance(tree, Mul):
            return Mul(substitute(tree.left), substitute(tree.right))
        elif isinstance(tree, Exp):
            return Exp(substitute(tree.child))
        elif isinstance(tree, Log):
            return Log(substitute(tree.child))
        else:
            raise ValueError(f"Unknown tree type: {type(tree)}")

    return [substitute(t) for t in outer]


def pair_trees(
    f_trees: List[EMLTree],
    g_trees: List[EMLTree]
) -> List[EMLTree]:
    """Pairing: concatenate output trees to form the product map."""
    return f_trees + g_trees


def curry_trees(
    trees: List[EMLTree],
    theta: np.ndarray,
    p: int
) -> List[EMLTree]:
    """
    Curry: fix the first p inputs to constants theta[0..p-1].
    Remaining variables are shifted: Coord(p+j) -> Coord(j).
    """
    def fix_params(tree: EMLTree) -> EMLTree:
        if isinstance(tree, Coord):
            if tree.index < p:
                return Const(float(theta[tree.index]))
            else:
                return Coord(tree.index - p)
        elif isinstance(tree, Const):
            return tree
        elif isinstance(tree, Add):
            return Add(fix_params(tree.left), fix_params(tree.right))
        elif isinstance(tree, Mul):
            return Mul(fix_params(tree.left), fix_params(tree.right))
        elif isinstance(tree, Exp):
            return Exp(fix_params(tree.child))
        elif isinstance(tree, Log):
            return Log(fix_params(tree.child))
        else:
            raise ValueError(f"Unknown tree type: {type(tree)}")

    return [fix_params(t) for t in trees]


# ============================================================
# 3. Iterated exponential construction
# ============================================================

def iter_exp_tree(k: int) -> EMLTree:
    """Build the k-fold iterated exponential tree."""
    tree: EMLTree = Coord(0)
    for _ in range(k):
        tree = Exp(tree)
    return tree


# ============================================================
# 4. Log-affine map algebra
# ============================================================

@dataclass
class LogAffineMap:
    """A log-affine map f(x) = exp(sum_i w_i * log(x_i) + c)."""
    weights: np.ndarray
    offset: float

    def evaluate(self, x: np.ndarray) -> float:
        """Evaluate on positive vector x."""
        assert np.all(x > 0), "Input must be strictly positive"
        return float(np.exp(np.sum(self.weights * np.log(x)) + self.offset))

    def log_coords(self, x: np.ndarray) -> float:
        """Value in log coordinates: sum_i w_i * log(x_i) + c"""
        return float(np.sum(self.weights * np.log(x)) + self.offset)

    def __mul__(self, other: LogAffineMap) -> LogAffineMap:
        """Multiplication closure: (f*g)(x) has weights w1+w2, offset c1+c2."""
        return LogAffineMap(
            weights=self.weights + other.weights,
            offset=self.offset + other.offset
        )


# ============================================================
# 5. Demonstration
# ============================================================

if __name__ == "__main__":
    print("=== EML Tree Algebra ===")

    # Build: eml(x0, x1) = exp(x0) - log(x1)
    eml_tree = Add(Exp(Coord(0)), Mul(Const(-1.0), Log(Coord(1))))
    x = np.array([1.0, 2.0])
    print(f"eml({x[0]}, {x[1]}) = {evaluate(eml_tree, x):.6f}")
    print(f"  node_count = {node_count(eml_tree)}")
    print(f"  depth = {depth(eml_tree)}")

    print("\n=== Iterated Exponential Hierarchy ===")
    for k in range(6):
        t = iter_exp_tree(k)
        print(f"  exp^[{k}]: depth={depth(t)}, nodes={node_count(t)}, "
              f"value at 0.1 = {evaluate(t, np.array([0.1])):.6f}")

    print("\n=== Composition ===")
    # f: R^2 -> R^2, f(x) = (exp(x0), x0 + x1)
    f_trees = [Exp(Coord(0)), Add(Coord(0), Coord(1))]
    # g: R^2 -> R^1, g(y) = y0 * y1
    g_trees = [Mul(Coord(0), Coord(1))]
    # g ∘ f: R^2 -> R^1
    gf_trees = compose_trees(g_trees, f_trees, 2)
    x = np.array([1.0, 2.0])
    print(f"  g(f({x})) = {evaluate(gf_trees[0], x):.6f}")
    print(f"  Expected exp(1)*(1+2) = {np.exp(1)*3:.6f}")
    print(f"  Composed tree nodes: {node_count(gf_trees[0])}")

    print("\n=== Log-Affine Algebra ===")
    f = LogAffineMap(np.array([2.0, 0.5]), 1.0)
    g = LogAffineMap(np.array([-1.0, 3.0]), 0.0)
    fg = f * g
    x = np.array([2.0, 3.0])
    print(f"  f(x) = {f.evaluate(x):.6f}")
    print(f"  g(x) = {g.evaluate(x):.6f}")
    print(f"  (f*g)(x) = {fg.evaluate(x):.6f}")
    print(f"  f(x)*g(x) = {f.evaluate(x) * g.evaluate(x):.6f}")
    print(f"  In log coords: f -> {f.log_coords(x):.4f}, g -> {g.log_coords(x):.4f}")

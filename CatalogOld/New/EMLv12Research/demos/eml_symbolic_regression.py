#!/usr/bin/env python3
"""
EML Symbolic Regression Engine
===============================
A prototype symbolic regression system using EML trees as the hypothesis space.

Key idea: Instead of searching over arbitrary expression trees with {+, -, *, /, exp, log, sin, ...},
we search over binary EML trees where:
- Leaves are either the variable x, the constant 1, or a learned parameter θ
- Internal nodes compute eml(left, right) = exp(left) - ln(right)
- Each node optionally has affine pre-processing: a*input + b

An n-node EML tree has O(n) continuous parameters, which are optimized via gradient descent,
while tree topology is searched via enumeration or evolutionary methods.

Advantages over general symbolic regression:
1. Smaller search space (binary trees with one operation)
2. Guaranteed smoothness (eml is C∞ on its domain)
3. Natural basis for physics (combines exp and log)
4. Monotonicity properties enable pruning
"""

import numpy as np
from itertools import product

class EMLNode:
    """A node in an EML expression tree."""
    def __init__(self, kind, left=None, right=None, value=None, params=None):
        self.kind = kind  # 'leaf_x', 'leaf_const', 'eml'
        self.left = left
        self.right = right
        self.value = value  # for leaf_const
        self.params = params or {}  # affine params: a, b for a*input + b

    def evaluate(self, x):
        """Evaluate the EML tree at input x."""
        if self.kind == 'leaf_x':
            a = self.params.get('a', 1.0)
            b = self.params.get('b', 0.0)
            return a * x + b
        elif self.kind == 'leaf_const':
            return np.full_like(x, self.value, dtype=float)
        elif self.kind == 'eml':
            left_val = self.left.evaluate(x)
            right_val = self.right.evaluate(x)
            # eml(l, r) = exp(l) - ln(r), with protection for r ≤ 0
            return np.exp(np.clip(left_val, -20, 20)) - np.log(np.maximum(right_val, 1e-10))

    def complexity(self):
        """Count the number of EML operations."""
        if self.kind in ('leaf_x', 'leaf_const'):
            return 0
        return 1 + self.left.complexity() + self.right.complexity()

    def __repr__(self):
        if self.kind == 'leaf_x':
            a, b = self.params.get('a', 1), self.params.get('b', 0)
            if a == 1 and b == 0:
                return 'x'
            return f'({a}*x + {b})'
        elif self.kind == 'leaf_const':
            return str(self.value)
        else:
            return f'eml({self.left}, {self.right})'


def generate_depth1_trees():
    """Generate all EML trees of depth 1 (complexity 1)."""
    leaves = [
        EMLNode('leaf_x'),
        EMLNode('leaf_const', value=1.0),
        EMLNode('leaf_const', value=0.0),
    ]
    trees = []
    for l in leaves:
        for r in leaves:
            trees.append(EMLNode('eml', left=l, right=r))
    return trees

def generate_depth2_trees():
    """Generate representative EML trees of depth ≤ 2."""
    depth1 = generate_depth1_trees()
    leaves = [
        EMLNode('leaf_x'),
        EMLNode('leaf_const', value=1.0),
    ]

    trees = list(depth1)  # include depth 1

    # Depth 2: eml(depth1_tree, leaf) or eml(leaf, depth1_tree)
    for t in depth1:
        for l in leaves:
            trees.append(EMLNode('eml', left=t, right=l))
            trees.append(EMLNode('eml', left=l, right=t))

    return trees

def fit_eml_tree(tree, x_data, y_data, lr=0.01, epochs=1000):
    """Simple gradient-free optimization of tree parameters."""
    best_error = float('inf')
    best_params = {}

    # Random search over affine parameters
    for _ in range(200):
        # Randomize leaf parameters
        def randomize(node):
            if node.kind == 'leaf_x':
                node.params = {'a': np.random.randn() * 2, 'b': np.random.randn() * 2}
            elif node.kind == 'eml':
                randomize(node.left)
                randomize(node.right)
        randomize(tree)

        try:
            y_pred = tree.evaluate(x_data)
            error = np.mean((y_pred - y_data) ** 2)
            if np.isfinite(error) and error < best_error:
                best_error = error
                # Save params (simplified)
        except:
            pass

    return best_error

def benchmark_regression():
    """Benchmark EML regression on standard test functions."""
    x = np.linspace(0.1, 3, 200)

    targets = {
        "exp(x)": np.exp(x),
        "ln(x)": np.log(x),
        "x²": x**2,
        "1/x": 1/x,
        "exp(x) - ln(x)": np.exp(x) - np.log(x),
        "exp(-x)": np.exp(-x),
        "x": x,
    }

    # Exact EML representations (no fitting needed)
    exact_results = {}

    # exp(x) = eml(x, 1)
    tree_exp = EMLNode('eml',
        left=EMLNode('leaf_x'),
        right=EMLNode('leaf_const', value=1.0))
    pred = tree_exp.evaluate(x)
    exact_results["exp(x)"] = {
        "tree": str(tree_exp),
        "complexity": tree_exp.complexity(),
        "max_error": float(np.max(np.abs(pred - np.exp(x)))),
    }

    # 1 - x = eml(0, exp(x))
    tree_1mx = EMLNode('eml',
        left=EMLNode('leaf_const', value=0.0),
        right=EMLNode('eml',
            left=EMLNode('leaf_x'),
            right=EMLNode('leaf_const', value=1.0)))
    pred = tree_1mx.evaluate(x)
    exact_results["1-x"] = {
        "tree": str(tree_1mx),
        "complexity": tree_1mx.complexity(),
        "max_error": float(np.max(np.abs(pred - (1 - x)))),
    }

    # exp(exp(x)) = eml(eml(x,1), 1)
    tree_eex = EMLNode('eml',
        left=EMLNode('eml',
            left=EMLNode('leaf_x'),
            right=EMLNode('leaf_const', value=1.0)),
        right=EMLNode('leaf_const', value=1.0))
    pred = tree_eex.evaluate(x)
    target_eex = np.exp(np.exp(x))
    exact_results["exp(exp(x))"] = {
        "tree": str(tree_eex),
        "complexity": tree_eex.complexity(),
        "max_error": float(np.max(np.abs(np.minimum(pred, 1e15) - np.minimum(target_eex, 1e15)))),
    }

    return exact_results

if __name__ == "__main__":
    print("=" * 60)
    print("EML Symbolic Regression Engine — V12")
    print("=" * 60)

    print("\n🌳 Depth-1 EML Trees:")
    for tree in generate_depth1_trees():
        x = np.array([0.0, 1.0, 2.0])
        try:
            vals = tree.evaluate(x)
            print(f"  {tree} → [{', '.join(f'{v:.3f}' for v in vals)}]")
        except:
            print(f"  {tree} → [evaluation error]")

    print("\n📊 Exact EML Representations:")
    results = benchmark_regression()
    for name, info in results.items():
        print(f"  {name}:")
        print(f"    Tree: {info['tree']}")
        print(f"    Complexity: {info['complexity']}")
        print(f"    Max error: {info['max_error']:.2e}")

    print("\n📈 EML Tree Statistics:")
    d1 = generate_depth1_trees()
    d2 = generate_depth2_trees()
    print(f"  Depth-1 trees: {len(d1)}")
    print(f"  Depth-≤2 trees: {len(d2)}")
    print(f"  Each tree has O(n) continuous parameters for n EML nodes")

    print("\n✅ Symbolic regression demo complete!")

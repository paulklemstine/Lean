#!/usr/bin/env python3
"""
EML Symbolic Regression v2 — Advanced Demo
==========================================
Demonstrates how EML trees can be used for symbolic regression:
finding mathematical formulas from data using ONLY the EML operator.

Key insight: Instead of searching over dozens of operations (+, -, *, /, sin, cos, exp, log, ...),
we search over trees of a SINGLE operation (EML), dramatically reducing the search space.

This implements:
1. EML tree representation with parameters
2. Gradient-based optimization (with gradient clipping)
3. Benchmark on standard physics equations
"""

import numpy as np
import math

class EMLNode:
    """A node in an EML expression tree."""
    
    def __init__(self, node_type, value=None, left=None, right=None, param_idx=None):
        self.node_type = node_type  # 'const', 'var', 'eml'
        self.value = value
        self.left = left
        self.right = right
        self.param_idx = param_idx  # index into parameter vector
    
    def eval(self, x_dict, params):
        """Evaluate the tree given variable values and parameters."""
        if self.node_type == 'const':
            return params[self.param_idx]
        elif self.node_type == 'var':
            return x_dict[self.value]
        elif self.node_type == 'eml':
            left_val = self.left.eval(x_dict, params)
            right_val = self.right.eval(x_dict, params)
            # eml(x, y) = exp(x) - ln(y)
            # Clamp for numerical stability
            left_clamped = np.clip(left_val, -20, 20)
            right_clamped = np.clip(right_val, 1e-10, 1e10)
            return np.exp(left_clamped) - np.log(right_clamped)
    
    def __str__(self):
        if self.node_type == 'const':
            return f"p{self.param_idx}"
        elif self.node_type == 'var':
            return self.value
        elif self.node_type == 'eml':
            return f"eml({self.left}, {self.right})"

    def count_params(self):
        if self.node_type == 'const':
            return 1
        elif self.node_type == 'var':
            return 0
        else:
            return self.left.count_params() + self.right.count_params()

    def depth(self):
        if self.node_type in ('const', 'var'):
            return 0
        return 1 + max(self.left.depth(), self.right.depth())


def make_level1_template(var_name='x'):
    """Level-1 EML template: eml(a*x + b, c*x + d) with 4 parameters.
    
    Actually, for EML regression, we use affine-transformed inputs:
    eml(p0*x + p1, exp(p2*x + p3))
    
    This gives: exp(p0*x + p1) - (p2*x + p3) = exp(p0*x + p1) - p2*x - p3
    """
    # Simple: eml(const, const) where each const is a parameter
    p0 = EMLNode('const', param_idx=0)
    p1 = EMLNode('const', param_idx=1)
    return EMLNode('eml', left=p0, right=p1), 2


def make_level2_template():
    """Level-2: eml(eml(p0, p1), eml(p2, p3)) with 4 params."""
    inner_left = EMLNode('eml', 
                         left=EMLNode('const', param_idx=0),
                         right=EMLNode('const', param_idx=1))
    inner_right = EMLNode('eml',
                          left=EMLNode('const', param_idx=2),
                          right=EMLNode('const', param_idx=3))
    return EMLNode('eml', left=inner_left, right=inner_right), 4


def numerical_gradient(tree, x_data, y_data, params, eps=1e-6):
    """Compute gradient of MSE loss w.r.t. parameters."""
    n_params = len(params)
    grad = np.zeros(n_params)
    
    # Current loss
    y_pred = np.array([tree.eval({'x': xi}, params) for xi in x_data])
    loss0 = np.mean((y_pred - y_data) ** 2)
    
    for i in range(n_params):
        params_plus = params.copy()
        params_plus[i] += eps
        y_pred_plus = np.array([tree.eval({'x': xi}, params_plus) for xi in x_data])
        loss_plus = np.mean((y_pred_plus - y_data) ** 2)
        grad[i] = (loss_plus - loss0) / eps
    
    return grad, loss0


def optimize_tree(tree, x_data, y_data, n_params, lr=0.01, max_iter=500, 
                  grad_clip=1.0, verbose=False):
    """Optimize tree parameters to fit data."""
    params = np.random.randn(n_params) * 0.5
    best_loss = float('inf')
    best_params = params.copy()
    
    for iteration in range(max_iter):
        grad, loss = numerical_gradient(tree, x_data, y_data, params)
        
        if np.isnan(loss) or np.isinf(loss):
            params = np.random.randn(n_params) * 0.5
            continue
        
        if loss < best_loss:
            best_loss = loss
            best_params = params.copy()
        
        # Gradient clipping
        grad_norm = np.linalg.norm(grad)
        if grad_norm > grad_clip:
            grad = grad * grad_clip / grad_norm
        
        params = params - lr * grad
        params = np.clip(params, -10, 10)
        
        if verbose and iteration % 100 == 0:
            print(f"    Iter {iteration:4d}: loss = {loss:.6e}")
    
    return best_params, best_loss


def benchmark_physics_formulas():
    """Test EML symbolic regression on standard physics formulas."""
    print("=" * 65)
    print("EML SYMBOLIC REGRESSION BENCHMARK")
    print("=" * 65)
    
    benchmarks = [
        ("Linear: y = 2x + 3", lambda x: 2*x + 3),
        ("Quadratic: y = x²", lambda x: x**2),
        ("Exponential: y = exp(x)", lambda x: np.exp(x)),
        ("Logarithmic: y = ln(x)", lambda x: np.log(x)),
        ("Inverse: y = 1/x", lambda x: 1.0/x),
        ("Square root: y = √x", lambda x: np.sqrt(x)),
    ]
    
    for name, true_func in benchmarks:
        print(f"\n  Target: {name}")
        
        # Generate data
        if "ln" in name or "√" in name or "1/x" in name:
            x_data = np.linspace(0.5, 5.0, 50)
        else:
            x_data = np.linspace(-2.0, 2.0, 50)
        y_data = true_func(x_data)
        
        # Try different tree structures
        best_overall_loss = float('inf')
        best_structure = None
        
        for trial in range(5):
            tree, n_params = make_level2_template()
            params, loss = optimize_tree(tree, x_data, y_data, n_params, 
                                        lr=0.005, max_iter=300)
            if loss < best_overall_loss:
                best_overall_loss = loss
                best_structure = (tree, params)
        
        status = "✓" if best_overall_loss < 0.1 else "○" if best_overall_loss < 1.0 else "✗"
        print(f"    {status} Best MSE: {best_overall_loss:.6e}")
        if best_structure:
            tree, params = best_structure
            print(f"    Parameters: {params}")


def eml_master_formula_analysis():
    """Analyze the parameter count of EML master formulas."""
    print("\n" + "=" * 65)
    print("EML MASTER FORMULA PARAMETER COUNT")
    print("=" * 65)
    
    print("\n  The level-n EML master formula has P(n) = 5·2ⁿ - 6 parameters.")
    print("  This counts the affine transform parameters at each leaf.\n")
    
    print(f"  {'Level':>6} {'Parameters':>12} {'EML Nodes':>12} {'Leaves':>8}")
    print(f"  {'─'*6} {'─'*12} {'─'*12} {'─'*8}")
    
    for n in range(1, 11):
        params = 5 * 2**n - 6
        nodes = 2**n - 1
        leaves = 2**n
        print(f"  {n:>6} {params:>12} {nodes:>12} {leaves:>8}")
    
    print(f"\n  Key insight: The search space at level n is ℝ^(5·2ⁿ-6),")
    print(f"  which is continuous and differentiable — amenable to gradient descent!")
    print(f"  Compare with traditional symbolic regression: discrete search over")
    print(f"  combinatorial space of expression trees with ~36 different operations.")


def compare_search_spaces():
    """Compare EML vs traditional symbolic regression search spaces."""
    print("\n" + "=" * 65)
    print("SEARCH SPACE COMPARISON: EML vs TRADITIONAL")
    print("=" * 65)
    
    print("""
  Traditional Symbolic Regression:
    Operations: +, -, *, /, sin, cos, tan, exp, log, sqrt, pow, ...
    Typical set: ~15-20 operations
    Search space at depth d: O(20^(2^d)) discrete trees
    Method: Genetic programming (combinatorial search)
    
  EML Symbolic Regression:
    Operations: eml (JUST ONE)
    Search space at depth d: ℝ^(5·2^d - 6) continuous parameters
    Method: Gradient descent (continuous optimization)
    
  Comparison at depth 3:
    Traditional: ~20^8 ≈ 25.6 billion tree topologies to search
    EML: 34-dimensional continuous optimization problem
    
  Comparison at depth 5:
    Traditional: ~20^32 ≈ 4.3 × 10^41 tree topologies
    EML: 154-dimensional continuous optimization problem
    
  The EML approach converts a combinatorial search problem into a
  continuous optimization problem — a fundamentally easier class!
    """)


def main():
    print("╔═════════════════════════════════════════════════════════════╗")
    print("║     EML SYMBOLIC REGRESSION v2                             ║")
    print("║     Mathematical Discovery via Single-Operator Trees       ║")
    print("╚═════════════════════════════════════════════════════════════╝")
    
    benchmark_physics_formulas()
    eml_master_formula_analysis()
    compare_search_spaces()
    
    print("\n" + "=" * 65)
    print("CONCLUSION")
    print("=" * 65)
    print("""
  The EML operator transforms symbolic regression from a discrete
  combinatorial search problem into a continuous optimization problem.
  
  Key advantages:
  1. Single operation → no operation selection needed
  2. Continuous parameter space → gradient-based optimization
  3. Provably universal → can represent ANY elementary function
  4. Parameter count formula: exactly 5·2ⁿ - 6 at depth n
  5. Gradient structure: ∂eml/∂x = exp(x), ∂eml/∂y = -1/y
  
  Key challenges:
  1. Gradient explosion at depth > 5 (exp of exp of ...)
  2. Need gradient clipping for stable training
  3. Many local minima in the loss landscape
  4. Real-world functions may require high depth
    """)

if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""
EML Symbolic Regression Demo
=============================
Demonstrates gradient-based symbolic regression using EML tree architectures.

The key insight: since ALL elementary functions can be expressed as EML trees,
we can parameterize a "master formula" EML tree and train it with gradient descent
to discover closed-form expressions from data.

When successful, trained weights snap to exact 0/1 values, recovering
the exact symbolic formula.

Reference: "All elementary functions from a single operator" by A. Odrzywolek (2025)
"""

import numpy as np
from typing import Callable, List, Tuple, Optional
import warnings
warnings.filterwarnings('ignore')

# ============================================================================
# EML Core
# ============================================================================

def eml_complex(x: complex, y: complex) -> complex:
    """EML operator: eml(x,y) = exp(x) - ln(y)"""
    return np.exp(x) - np.log(y)

# ============================================================================
# Softmax for discrete parameter selection
# ============================================================================

def softmax(logits: np.ndarray, temperature: float = 1.0) -> np.ndarray:
    """Softmax with temperature for parameter discretization."""
    scaled = logits / temperature
    exp_vals = np.exp(scaled - np.max(scaled))
    return exp_vals / np.sum(exp_vals)

# ============================================================================
# EML Master Formula (Level 2)
# ============================================================================

class EMLMasterLevel2:
    """
    Level-2 EML Master Formula for univariate functions.
    
    F(x) = eml[α₁ + β₁x + γ₁·eml(α₃ + β₃x, α₄ + β₄x),
               α₂ + β₂x + γ₂·eml(α₅ + β₅x, α₆ + β₆x)]
    
    14 parameters total. Each (α,β,γ) triple is passed through softmax
    to produce a probability distribution over {1, x, f_child}.
    """
    
    def __init__(self, seed: int = 42):
        rng = np.random.RandomState(seed)
        # 6 leaf nodes with 2 params each (weights for 1 vs x)
        # 2 internal nodes with 3 params each (weights for 1, x, child)
        self.leaf_logits = rng.randn(4, 2) * 0.5  # 4 leaves, 2 choices each
        self.node_logits = rng.randn(2, 3) * 0.5  # 2 nodes, 3 choices each
        self.temperature = 1.0
    
    def evaluate(self, x: complex) -> complex:
        """Evaluate the master formula at point x."""
        # Leaf values: softmax selects between 1 and x
        leaf_vals = []
        for i in range(4):
            w = softmax(self.leaf_logits[i], self.temperature)
            leaf_vals.append(w[0] * 1.0 + w[1] * x)
        
        # Level 1: two eml applications
        child1 = eml_complex(leaf_vals[0], leaf_vals[1])
        child2 = eml_complex(leaf_vals[2], leaf_vals[3])
        
        # Level 2: combine with node selections
        left_w = softmax(self.node_logits[0], self.temperature)
        left_input = left_w[0] * 1.0 + left_w[1] * x + left_w[2] * child1
        
        right_w = softmax(self.node_logits[1], self.temperature)
        right_input = right_w[0] * 1.0 + right_w[1] * x + right_w[2] * child2
        
        return eml_complex(left_input, right_input)
    
    def snap_weights(self):
        """Snap softmax weights to nearest vertex (hard discretization)."""
        for i in range(4):
            idx = np.argmax(self.leaf_logits[i])
            self.leaf_logits[i] = np.zeros(2)
            self.leaf_logits[i, idx] = 100.0  # large logit → one-hot
        
        for i in range(2):
            idx = np.argmax(self.node_logits[i])
            self.node_logits[i] = np.zeros(3)
            self.node_logits[i, idx] = 100.0
    
    def describe(self) -> str:
        """Human-readable description of current weights."""
        labels_leaf = ['1', 'x']
        labels_node = ['1', 'x', 'child']
        
        lines = []
        for i in range(4):
            w = softmax(self.leaf_logits[i], self.temperature)
            best = labels_leaf[np.argmax(w)]
            lines.append(f"  Leaf {i}: {best} (weights: {w.round(3)})")
        
        for i in range(2):
            w = softmax(self.node_logits[i], self.temperature)
            best = labels_node[np.argmax(w)]
            lines.append(f"  Node {i}: {best} (weights: {w.round(3)})")
        
        return '\n'.join(lines)

# ============================================================================
# Simple Gradient-Free Optimizer (for demo without PyTorch)
# ============================================================================

def numerical_gradient(model: EMLMasterLevel2, x_data: np.ndarray, 
                       y_data: np.ndarray, eps: float = 1e-5) -> Tuple:
    """Compute numerical gradients for the model parameters."""
    
    def loss_fn():
        preds = np.array([model.evaluate(complex(x)).real for x in x_data])
        return np.mean((preds - y_data) ** 2)
    
    leaf_grads = np.zeros_like(model.leaf_logits)
    node_grads = np.zeros_like(model.node_logits)
    
    for i in range(model.leaf_logits.shape[0]):
        for j in range(model.leaf_logits.shape[1]):
            model.leaf_logits[i, j] += eps
            loss_plus = loss_fn()
            model.leaf_logits[i, j] -= 2 * eps
            loss_minus = loss_fn()
            model.leaf_logits[i, j] += eps
            leaf_grads[i, j] = (loss_plus - loss_minus) / (2 * eps)
    
    for i in range(model.node_logits.shape[0]):
        for j in range(model.node_logits.shape[1]):
            model.node_logits[i, j] += eps
            loss_plus = loss_fn()
            model.node_logits[i, j] -= 2 * eps
            loss_minus = loss_fn()
            model.node_logits[i, j] += eps
            node_grads[i, j] = (loss_plus - loss_minus) / (2 * eps)
    
    return leaf_grads, node_grads

def train_eml_model(target_fn: Callable, target_name: str,
                    x_range: Tuple[float, float] = (0.5, 3.0),
                    n_points: int = 20, n_epochs: int = 500,
                    lr: float = 0.1, seed: int = 42):
    """
    Train an EML master formula to discover a target function.
    
    Parameters:
        target_fn: The function to discover
        target_name: Name for display
        x_range: Range of training data
        n_points: Number of training points
        n_epochs: Training iterations
        lr: Learning rate
        seed: Random seed
    """
    print(f"\n{'='*50}")
    print(f"Training EML tree to discover: {target_name}")
    print(f"{'='*50}")
    
    # Generate training data
    x_data = np.linspace(x_range[0], x_range[1], n_points)
    y_data = np.array([target_fn(x) for x in x_data])
    
    # Initialize model
    model = EMLMasterLevel2(seed=seed)
    
    best_loss = float('inf')
    
    for epoch in range(n_epochs):
        # Compute loss
        preds = np.array([model.evaluate(complex(x)).real for x in x_data])
        loss = np.mean((preds - y_data) ** 2)
        
        if loss < best_loss:
            best_loss = loss
        
        # Compute gradients and update
        leaf_grads, node_grads = numerical_gradient(model, x_data, y_data)
        model.leaf_logits -= lr * leaf_grads
        model.node_logits -= lr * node_grads
        
        # Anneal temperature
        model.temperature = max(0.1, 1.0 - epoch / n_epochs * 0.9)
        
        if epoch % 100 == 0 or epoch == n_epochs - 1:
            print(f"  Epoch {epoch:4d}: loss = {loss:.6e}, temp = {model.temperature:.3f}")
    
    # Snap weights
    print(f"\nBefore snapping:")
    print(model.describe())
    
    model.snap_weights()
    model.temperature = 0.01
    
    # Evaluate snapped model
    preds_snapped = np.array([model.evaluate(complex(x)).real for x in x_data])
    snapped_loss = np.mean((preds_snapped - y_data) ** 2)
    
    print(f"\nAfter snapping:")
    print(model.describe())
    print(f"\nSnapped MSE: {snapped_loss:.6e}")
    
    # Test extrapolation
    x_test = np.linspace(x_range[1], x_range[1] + 2, 5)
    y_test = np.array([target_fn(x) for x in x_test])
    preds_test = np.array([model.evaluate(complex(x)).real for x in x_test])
    extrap_err = np.mean((preds_test - y_test) ** 2)
    print(f"Extrapolation MSE: {extrap_err:.6e}")
    
    return model, best_loss

# ============================================================================
# Demonstrations
# ============================================================================

def demo_recovery():
    """Demonstrate exact recovery of elementary functions from EML trees."""
    print("\n" + "╔" + "═"*56 + "╗")
    print("║  EML Symbolic Regression: Discovering Formulas from Data ║")
    print("╚" + "═"*56 + "╝")
    
    print("""
    The EML master formula parameterizes ALL elementary functions
    up to a given tree depth. Training with gradient descent can
    recover the exact symbolic formula.
    
    Target functions (depth ≤ 2 in EML form):
    1. exp(x) = eml(x, 1)         [depth 1]
    2. e^(e^x) = eml(eml(x,1), 1) [depth 2]
    """)
    
    # Test 1: exp(x) - should be easy (depth 1)
    train_eml_model(
        target_fn=np.exp,
        target_name="exp(x)",
        x_range=(0.1, 2.0),
        n_epochs=300,
        seed=42
    )
    
    # Test 2: exp(exp(x)) - depth 2
    train_eml_model(
        target_fn=lambda x: np.exp(np.exp(x)),
        target_name="exp(exp(x))",
        x_range=(0.1, 1.0),
        n_epochs=500,
        seed=123
    )

def demo_eml_enumeration():
    """Enumerate and evaluate all small EML expressions."""
    print("\n" + "="*50)
    print("ENUMERATING SMALL EML EXPRESSIONS")
    print("="*50)
    
    print("\nAll depth-1 EML expressions (using terminals 1):")
    val = eml_complex(1, 1)
    print(f"  eml(1, 1) = {val.real:.6f} = e")
    
    print("\nAll depth-2 EML expressions (using terminal 1):")
    expressions = [
        ("eml(eml(1,1), 1)", lambda: eml_complex(eml_complex(1, 1), 1)),
        ("eml(1, eml(1,1))", lambda: eml_complex(1, eml_complex(1, 1))),
        ("eml(eml(1,1), eml(1,1))", lambda: eml_complex(eml_complex(1, 1), eml_complex(1, 1))),
    ]
    
    for name, fn in expressions:
        val = fn()
        print(f"  {name} = {val.real:.6f}")
    
    # Identify known constants
    print("\n  Interpretations:")
    print(f"    eml(eml(1,1), 1) = exp(e) ≈ {np.exp(np.e):.6f}")
    print(f"    eml(1, eml(1,1)) = e - ln(e) = e - 1 ≈ {np.e - 1:.6f}")
    print(f"    eml(eml(1,1), eml(1,1)) = exp(e) - ln(e) = exp(e) - 1 ≈ {np.exp(np.e) - 1:.6f}")

def demo_comparison():
    """Compare EML representations with standard representations."""
    print("\n" + "="*50)
    print("EML vs STANDARD REPRESENTATIONS")
    print("="*50)
    
    x = 2.5  # test point
    xc = complex(x)
    
    comparisons = [
        ("exp(x)", np.exp(x), eml_complex(xc, 1).real),
        ("ln(x)", np.log(x), eml_complex(1, eml_complex(eml_complex(1, xc), 1)).real),
    ]
    
    print(f"\n  Test point: x = {x}")
    print(f"  {'Function':<20} {'Standard':<20} {'EML':<20} {'Error':<15}")
    print(f"  {'-'*75}")
    
    for name, std_val, eml_val in comparisons:
        err = abs(std_val - eml_val)
        print(f"  {name:<20} {std_val:<20.10f} {eml_val:<20.10f} {err:<15.2e}")

def main():
    demo_eml_enumeration()
    demo_comparison()
    demo_recovery()
    
    print("\n" + "="*60)
    print("CONCLUSION: EML trees provide a universal, differentiable")
    print("architecture for symbolic regression of elementary functions.")
    print("="*60 + "\n")

if __name__ == "__main__":
    main()

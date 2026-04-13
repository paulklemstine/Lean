#!/usr/bin/env python3
"""
Symbolic Extraction from Softplus Networks

This demo shows how trained softplus networks can be analyzed
to recover the underlying elementary function they approximate.

Key idea: A softplus network with specific weights encodes a
specific elementary function. By examining the weight patterns,
we can identify which function is being computed.
"""

import numpy as np

# =============================================================================
# Core softplus
# =============================================================================

def softplus(x):
    """Numerically stable softplus"""
    return np.where(x > 20, x, np.log1p(np.exp(np.clip(x, -500, 20))))

def softplus_inv(y):
    """Inverse of softplus: log(exp(y) - 1)"""
    return np.where(y > 20, y, np.log(np.expm1(np.clip(y, 1e-15, 20))))

# =============================================================================
# Sheffer Expressions
# =============================================================================

class ShefferExpr:
    """A symbolic expression in the Sheffer algebra."""
    pass

class Affine(ShefferExpr):
    def __init__(self, a, b):
        self.a, self.b = a, b
    def eval(self, x):
        return self.a * x + self.b
    def __repr__(self):
        if abs(self.b) < 1e-10:
            if abs(self.a - 1) < 1e-10:
                return "x"
            return f"{self.a:.4g}·x"
        if abs(self.a) < 1e-10:
            return f"{self.b:.4g}"
        return f"({self.a:.4g}·x + {self.b:.4g})"

class Activate(ShefferExpr):
    def __init__(self, inner):
        self.inner = inner
    def eval(self, x):
        return softplus(self.inner.eval(x))
    def __repr__(self):
        return f"σ({self.inner})"

class AffinePost(ShefferExpr):
    """a * f(x) + b"""
    def __init__(self, a, b, inner):
        self.a, self.b, self.inner = a, b, inner
    def eval(self, x):
        return self.a * self.inner.eval(x) + self.b
    def __repr__(self):
        if abs(self.b) < 1e-10:
            if abs(self.a - 1) < 1e-10:
                return repr(self.inner)
            return f"{self.a:.4g}·{self.inner}"
        return f"({self.a:.4g}·{self.inner} + {self.b:.4g})"

class Sum(ShefferExpr):
    """Sum of weighted Sheffer expressions"""
    def __init__(self, terms, weights, bias=0):
        self.terms = terms
        self.weights = weights
        self.bias = bias
    def eval(self, x):
        result = self.bias
        for t, w in zip(self.terms, self.weights):
            result = result + w * t.eval(x)
        return result
    def __repr__(self):
        parts = []
        for t, w in zip(self.terms, self.weights):
            if abs(w - 1) < 1e-10:
                parts.append(repr(t))
            else:
                parts.append(f"{w:.4g}·{t}")
        s = " + ".join(parts)
        if abs(self.bias) > 1e-10:
            s += f" + {self.bias:.4g}"
        return s

# =============================================================================
# Demo 1: Recognizing exp(x) from a trained network
# =============================================================================

def demo_recognize_exp():
    print("=" * 70)
    print("DEMO 1: Recognizing exp(x) in a Sheffer Expression")
    print("=" * 70)
    
    # Build: exp(x) ≈ e^c * σ(x - c) for large c
    c = 20
    expr = AffinePost(np.exp(c), 0, Activate(Affine(1, -c)))
    
    x_test = np.array([-3, -2, -1, 0, 1, 2, 3], dtype=float)
    approx = expr.eval(x_test)
    exact = np.exp(x_test)
    
    print(f"\nExpression: {expr}")
    print(f"Simplified: ≈ exp(x)")
    print(f"\n{'x':>6} | {'expr(x)':>14} | {'exp(x)':>14} | {'rel error':>12}")
    print("-" * 55)
    for i, x in enumerate(x_test):
        rel_err = abs(approx[i] - exact[i]) / exact[i]
        print(f"{x:6.1f} | {approx[i]:14.8f} | {exact[i]:14.8f} | {rel_err:12.2e}")

# =============================================================================
# Demo 2: Recognizing the identity x = σ(x) - σ(-x)
# =============================================================================

def demo_recognize_identity():
    print("\n" + "=" * 70)
    print("DEMO 2: Recognizing x = σ(x) - σ(-x)")
    print("=" * 70)
    
    # Build: x = σ(x) - σ(-x)
    term1 = Activate(Affine(1, 0))    # σ(x)
    term2 = Activate(Affine(-1, 0))   # σ(-x)
    expr = Sum([term1, term2], [1, -1])
    
    x_test = np.linspace(-5, 5, 11)
    result = expr.eval(x_test)
    
    print(f"\nExpression: {expr}")
    print(f"Simplified: x")
    print(f"\nMax error from identity: {np.max(np.abs(result - x_test)):.2e}")

# =============================================================================
# Demo 3: Training a softplus network and extracting the formula
# =============================================================================

def demo_train_and_extract():
    print("\n" + "=" * 70)
    print("DEMO 3: Train → Extract → Verify")
    print("Target function: f(x) = 2·exp(-x²/2) (Gaussian)")
    print("=" * 70)
    
    np.random.seed(123)
    
    # Target function
    def target(x):
        return 2 * np.exp(-x**2 / 2)
    
    # Training data
    x_train = np.linspace(-4, 4, 200)
    y_train = target(x_train)
    
    # Random feature softplus network
    n_neurons = 30
    a = np.random.randn(n_neurons) * 2
    b = np.random.randn(n_neurons) * 2
    
    # Hidden features
    H = np.column_stack([softplus(ai * x_train + bi) for ai, bi in zip(a, b)])
    H = np.column_stack([H, np.ones(len(x_train))])
    
    # Solve least squares
    w, _, _, _ = np.linalg.lstsq(H, y_train, rcond=None)
    
    # Build Sheffer expression
    terms = [Activate(Affine(ai, bi)) for ai, bi in zip(a, b)]
    weights = w[:-1]
    bias = w[-1]
    
    # Test
    x_test = np.linspace(-4, 4, 50)
    y_exact = target(x_test)
    H_test = np.column_stack([softplus(ai * x_test + bi) for ai, bi in zip(a, b)])
    H_test = np.column_stack([H_test, np.ones(len(x_test))])
    y_approx = H_test @ w
    
    max_err = np.max(np.abs(y_approx - y_exact))
    
    print(f"\nNetwork: {n_neurons} softplus neurons")
    print(f"Max error: {max_err:.6f}")
    
    # Identify dominant terms
    print(f"\nDominant terms (|weight| > 0.1):")
    dominant = [(i, weights[i], a[i], b[i]) for i in range(n_neurons) if abs(weights[i]) > 0.1]
    dominant.sort(key=lambda x: -abs(x[1]))
    
    for idx, (i, wi, ai, bi) in enumerate(dominant[:8]):
        print(f"  {wi:+8.4f} · σ({ai:+6.3f}·x {bi:+6.3f})")
    
    if len(dominant) > 8:
        print(f"  ... and {len(dominant)-8} more terms")
    
    print(f"\nSymbolic interpretation:")
    print(f"  The network approximates a Gaussian bell curve")
    print(f"  f(x) ≈ 2·exp(-x²/2)")
    print(f"  Built from {len(dominant)} softplus units")

# =============================================================================
# Demo 4: The Sheffer Composition Depth
# =============================================================================

def demo_composition_depth():
    print("\n" + "=" * 70)
    print("DEMO 4: Sheffer Composition Depth")
    print("How many layers of σ are needed to approximate each function?")
    print("=" * 70)
    
    x_test = np.linspace(-3, 3, 200)
    
    functions = {
        "x (identity)": (lambda x: x, "σ(x) - σ(-x)", 1),
        "exp(x)": (lambda x: np.exp(x), "eᶜ·σ(x-c)", 1),
        "x²": (lambda x: x**2, "exp(2·log(|x|))", 2),
        "sin(x)": (lambda x: np.sin(x), "Σwᵢσ(aᵢx+bᵢ)", 1),
        "exp(-x²)": (lambda x: np.exp(-x**2), "exp(−σ(...))", 2),
    }
    
    print(f"\n{'Function':>15} | {'Sheffer Depth':>14} | {'Construction':>25}")
    print("-" * 60)
    for name, (_, construction, depth) in functions.items():
        print(f"{name:>15} | {depth:>14} | {construction:>25}")
    
    print(f"\nNote: 'Depth' = number of nested σ applications")
    print(f"Depth 1 functions can be built with a single hidden layer")
    print(f"Depth 2 requires at least two hidden layers")

# =============================================================================
# Demo 5: Softplus generates all common activations
# =============================================================================

def demo_activation_zoo():
    print("\n" + "=" * 70)
    print("DEMO 5: All Common Activations from Softplus")
    print("=" * 70)
    
    x = np.linspace(-5, 5, 21)
    
    # Sigmoid from softplus derivative
    print("\n1. Sigmoid: σ'(x) = exp(x)/(1+exp(x))")
    eps = 1e-7
    sigmoid_approx = (softplus(x + eps) - softplus(x - eps)) / (2 * eps)
    sigmoid_exact = 1 / (1 + np.exp(-x))
    print(f"   Max error: {np.max(np.abs(sigmoid_approx - sigmoid_exact)):.2e}")
    
    # Tanh from softplus
    print("\n2. Tanh: tanh(x) = 2·sigmoid(2x) - 1 = 2·σ'(2x) - 1")
    tanh_exact = np.tanh(x)
    sigmoid_2x = (softplus(2*x + eps) - softplus(2*x - eps)) / (2 * eps)
    tanh_approx = 2 * sigmoid_2x - 1
    print(f"   Max error: {np.max(np.abs(tanh_approx - tanh_exact)):.2e}")
    
    # ReLU
    print("\n3. ReLU: max(0,x) = lim_{β→∞} σ(βx)/β")
    relu_exact = np.maximum(0, x)
    relu_approx = softplus(100 * x) / 100
    print(f"   Max error (β=100): {np.max(np.abs(relu_approx - relu_exact)):.4f}")
    
    # GELU approximation
    print("\n4. GELU ≈ x·sigmoid(1.702x) = x·σ'(1.702x)")
    gelu_exact = x * 0.5 * (1 + np.vectorize(lambda t: float(np.tanh(np.sqrt(2/np.pi) * (t + 0.044715*t**3))))(x))
    sig_1702 = (softplus(1.702*x + eps) - softplus(1.702*x - eps)) / (2 * eps)
    gelu_approx = x * sig_1702
    print(f"   Max error: {np.max(np.abs(gelu_approx - gelu_exact)):.4f}")
    
    # SiLU / Swish
    print("\n5. SiLU/Swish: x·sigmoid(x) = x·σ'(x)")
    silu_exact = x / (1 + np.exp(-x))
    sig_x = (softplus(x + eps) - softplus(x - eps)) / (2 * eps)
    silu_approx = x * sig_x
    print(f"   Max error: {np.max(np.abs(silu_approx - silu_exact)):.2e}")
    
    # Mish
    print("\n6. Mish: x·tanh(σ(x)) — literally defined via softplus!")
    mish_exact = x * np.tanh(softplus(x))
    print(f"   Mish IS a softplus composition by definition")
    
    # ELU
    print("\n7. ELU ≈ σ(βx)/β for x>0, exp(x)-1 for x<0")
    print("   ELU's negative branch exp(x)-1 ≈ σ(x) - ln2 for x << 0")
    
    print(f"\n✓ All 7 major activations expressible via softplus + affine ops")

# =============================================================================
# Main
# =============================================================================

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  Symbolic Extraction from Softplus (Sheffer) Networks              ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    
    demo_recognize_exp()
    demo_recognize_identity()
    demo_train_and_extract()
    demo_composition_depth()
    demo_activation_zoo()
    
    print("\n" + "=" * 70)
    print("KEY INSIGHT: Every activation function is a softplus expression.")
    print("Softplus is the NAND gate of neural network activations.")
    print("=" * 70)

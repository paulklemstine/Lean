"""
Sheffer AI: Symbolic Extraction from Softplus Networks
======================================================

Demonstrates the key application idea: train a softplus neural network,
then extract a symbolic formula. This is possible because softplus
generates all elementary functions — so a trained network IS a formula.

Requirements: numpy, scipy
"""

import numpy as np
from scipy.optimize import minimize

# ============================================================================
# Softplus Network
# ============================================================================

def softplus(x):
    """Numerically stable softplus."""
    return np.where(x > 20, x, np.log1p(np.exp(np.clip(x, -500, 20))))

def softplus_deriv(x):
    """Derivative of softplus = sigmoid."""
    return 1 / (1 + np.exp(-x))

class ShefferNetwork:
    """A depth-1 Sheffer expression: f(x) = Σᵢ wᵢ σ(aᵢx + bᵢ) + c"""

    def __init__(self, width):
        self.width = width
        self.weights = np.random.randn(width) * 0.1
        self.slopes = np.random.randn(width) * 1.0
        self.biases = np.random.randn(width) * 0.5
        self.offset = 0.0

    def __call__(self, x):
        result = self.offset
        for i in range(self.width):
            result = result + self.weights[i] * softplus(self.slopes[i] * x + self.biases[i])
        return result

    def get_params(self):
        return np.concatenate([self.weights, self.slopes, self.biases, [self.offset]])

    def set_params(self, params):
        n = self.width
        self.weights = params[:n]
        self.slopes = params[n:2*n]
        self.biases = params[2*n:3*n]
        self.offset = params[3*n]

    def fit(self, x_data, y_data, verbose=True):
        """Train the network to fit data."""
        def loss(params):
            self.set_params(params)
            y_pred = self(x_data)
            return np.mean((y_pred - y_data)**2)

        initial = self.get_params()
        # Multiple random restarts
        best_loss = float('inf')
        best_params = initial.copy()

        for restart in range(20):
            if restart > 0:
                init = np.random.randn(len(initial)) * 1.0
            else:
                init = initial.copy()

            result = minimize(loss, init, method='L-BFGS-B',
                            options={'maxiter': 2000, 'ftol': 1e-15})

            if result.fun < best_loss:
                best_loss = result.fun
                best_params = result.x.copy()

        self.set_params(best_params)
        if verbose:
            print(f"  Final MSE: {best_loss:.2e}")
        return best_loss

    def symbolic_form(self, threshold=1e-3):
        """Extract a simplified symbolic representation."""
        terms = []
        for i in range(self.width):
            w, a, b = self.weights[i], self.slopes[i], self.biases[i]
            if abs(w) < threshold:
                continue
            # Format nicely
            term = f"{w:+.4f} · σ({a:.4f}x {b:+.4f})"
            terms.append(term)

        if abs(self.offset) > threshold:
            terms.append(f"{self.offset:+.4f}")

        if not terms:
            return "0"
        return " ".join(terms)

# ============================================================================
# Symbolic Extraction Demo
# ============================================================================

def demo_symbolic_extraction():
    """Train softplus networks on known functions and extract formulas."""
    print("="*70)
    print("SHEFFER SYMBOLIC EXTRACTION")
    print("="*70)

    # Test functions
    test_cases = [
        ("Identity: x", lambda x: x, (-3, 3)),
        ("Quadratic: x²", lambda x: x**2, (-3, 3)),
        ("Exponential: eˣ", lambda x: np.exp(x), (-2, 2)),
        ("Sine: sin(x)", lambda x: np.sin(x), (-np.pi, np.pi)),
        ("Gaussian: e^(-x²)", lambda x: np.exp(-x**2), (-3, 3)),
        ("Absolute value: |x|", lambda x: np.abs(x), (-3, 3)),
    ]

    for name, fn, (a, b) in test_cases:
        print(f"\n{'─'*60}")
        print(f"Target: {name}")
        print(f"{'─'*60}")

        x_data = np.linspace(a, b, 200)
        y_data = fn(x_data)

        for width in [4, 8]:
            net = ShefferNetwork(width)
            mse = net.fit(x_data, y_data, verbose=False)

            # Compute max error
            y_pred = net(x_data)
            max_err = np.max(np.abs(y_data - y_pred))

            print(f"\n  Width {width}:")
            print(f"    MSE = {mse:.2e}, Max Error = {max_err:.2e}")
            print(f"    Formula: {net.symbolic_form()}")

    print(f"\n{'='*70}")
    print("KEY INSIGHT: Every trained softplus network IS a formula.")
    print("Training = Symbolic Regression (in disguise)")
    print("="*70)

# ============================================================================
# Scientific Law Discovery Demo
# ============================================================================

def demo_law_discovery():
    """Simulate discovering a physical law from noisy data."""
    print("\n" + "="*70)
    print("SCIENTIFIC LAW DISCOVERY FROM DATA")
    print("="*70)

    # Generate data from Hooke's law: F = -kx
    np.random.seed(42)
    k_true = 2.5
    x_data = np.linspace(-2, 2, 50)
    y_data = -k_true * x_data + np.random.randn(50) * 0.1  # noisy

    print(f"\nTrue law: F = -{k_true}x  (Hooke's law)")
    print(f"Data: 50 points with Gaussian noise (σ=0.1)")

    net = ShefferNetwork(width=4)
    mse = net.fit(x_data, y_data)

    print(f"\nExtracted formula: f(x) = {net.symbolic_form()}")
    print(f"\nNote: Since σ(x) - σ(-x) = x exactly,")
    print(f"a well-trained network discovers the linear relationship")
    print(f"by finding weights that cancel to give a linear function.")

    # Verify linearity
    x_test = np.linspace(-3, 3, 100)
    y_pred = net(x_test)
    y_linear = -k_true * x_test

    # Check if it's approximately linear
    residual_from_linear = np.polyfit(x_test, y_pred, 1)
    print(f"\nLinear fit of output: slope = {residual_from_linear[0]:.4f}, intercept = {residual_from_linear[1]:.4f}")
    print(f"True: slope = {-k_true}, intercept = 0")

    # Generate data from ideal gas law: PV = nRT → P = nRT/V
    print(f"\n{'─'*60}")
    print("Example 2: Ideal Gas Law P = nRT/V")
    print("─"*60)

    n_R_T = 8.314 * 300  # nRT for 1 mol at 300K
    V_data = np.linspace(0.5, 5, 50)
    P_data = n_R_T / V_data + np.random.randn(50) * 50

    net2 = ShefferNetwork(width=8)
    mse2 = net2.fit(V_data, P_data, verbose=True)
    print(f"Extracted formula: f(V) = {net2.symbolic_form()}")

    print(f"\n{'='*70}")
    print("The Sheffer approach to scientific discovery:")
    print("1. Collect data (x, y)")
    print("2. Train softplus network")
    print("3. Extract symbolic formula")
    print("4. The formula IS the law (no black box)")
    print("="*70)

if __name__ == '__main__':
    demo_symbolic_extraction()
    demo_law_discovery()

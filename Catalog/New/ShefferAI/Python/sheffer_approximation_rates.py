"""
Sheffer AI: Approximation Rate Analysis
========================================

Computational study of how quickly depth-1 Sheffer expressions
approximate various function classes. Produces the convergence
tables and plots referenced in the research paper.

Requirements: numpy, scipy
"""

import numpy as np
from scipy.optimize import minimize

def softplus(x):
    return np.where(x > 20, x, np.log1p(np.exp(np.clip(x, -500, 20))))

def best_sheffer_approx(target_fn, interval, width, num_restarts=50):
    """Find the best depth-1 Sheffer approximation of given width."""
    a, b = interval
    x = np.linspace(a, b, 300)
    y_true = target_fn(x)

    def make_prediction(params, x):
        n = width
        w = params[:n]
        slopes = params[n:2*n]
        biases = params[2*n:3*n]
        offset = params[3*n]
        result = offset * np.ones_like(x)
        for i in range(n):
            result += w[i] * softplus(slopes[i] * x + biases[i])
        return result

    def loss(params):
        y_pred = make_prediction(params, x)
        return np.mean((y_pred - y_true)**2)

    best_loss = float('inf')
    best_params = None
    n_params = 3 * width + 1

    for _ in range(num_restarts):
        init = np.random.randn(n_params) * 1.0
        try:
            result = minimize(loss, init, method='L-BFGS-B',
                            options={'maxiter': 3000, 'ftol': 1e-15})
            if result.fun < best_loss:
                best_loss = result.fun
                best_params = result.x.copy()
        except:
            pass

    if best_params is not None:
        y_pred = make_prediction(best_params, x)
        max_err = np.max(np.abs(y_true - y_pred))
    else:
        max_err = float('inf')

    return max_err

def run_convergence_study():
    """Compute approximation errors for various targets and widths."""
    print("="*75)
    print("SHEFFER APPROXIMATION RATE STUDY")
    print("="*75)
    print()

    targets = {
        'sin(x)':      (lambda x: np.sin(x),      (-np.pi, np.pi)),
        'cos(x)':      (lambda x: np.cos(x),      (-np.pi, np.pi)),
        'x²':          (lambda x: x**2,            (-3, 3)),
        'x³':          (lambda x: x**3,            (-2, 2)),
        'exp(-x²)':    (lambda x: np.exp(-x**2),   (-3, 3)),
        '1/(1+x²)':   (lambda x: 1/(1+x**2),      (-3, 3)),
    }

    widths = [4, 8, 16, 32]

    # Header
    print(f"{'Target':<15}", end='')
    for w in widths:
        print(f"{'n='+str(w):>12}", end='')
    print(f"{'Rate':>12}")
    print("-" * 75)

    results = {}

    for name, (fn, interval) in targets.items():
        errors = []
        for w in widths:
            np.random.seed(42)
            err = best_sheffer_approx(fn, interval, w, num_restarts=30)
            errors.append(err)

        # Estimate convergence rate
        if len(errors) >= 2 and errors[0] > 0 and errors[-1] > 0:
            log_ratio = np.log(errors[0] / errors[-1])
            log_n_ratio = np.log(widths[-1] / widths[0])
            rate = log_ratio / log_n_ratio if log_n_ratio > 0 else 0
        else:
            rate = 0

        results[name] = errors

        print(f"{name:<15}", end='')
        for e in errors:
            print(f"{e:>12.4e}", end='')
        print(f"{rate:>12.2f}")

    print()
    print("Rate column: estimated as -log(E_n1/E_n2)/log(n1/n2)")
    print("Rate ≈ 2 indicates O(1/n²) convergence (Jackson-type)")
    print()

    return results

def verify_jackson_conjecture():
    """Test the Sheffer-Jackson conjecture for smooth functions."""
    print("\n" + "="*75)
    print("SHEFFER-JACKSON CONJECTURE VERIFICATION")
    print("="*75)
    print()
    print("Conjecture: For f ∈ Cᵏ([a,b]), the best depth-1 width-n")
    print("Sheffer approximation satisfies E_n(f) = O(n^{-k}).")
    print()

    # Test with functions of known smoothness
    smooth_targets = {
        'C∞: sin(x)':     (lambda x: np.sin(x),                 (-np.pi, np.pi), 'inf'),
        'C∞: exp(-x²)':   (lambda x: np.exp(-x**2),             (-3, 3),         'inf'),
        'C¹: |x|^(3/2)':  (lambda x: np.abs(x)**1.5,            (-2, 2),         '1'),
        'C⁰: |x|':        (lambda x: np.abs(x),                 (-2, 2),         '0'),
    }

    widths = [8, 16, 32]

    for name, (fn, interval, smoothness) in smooth_targets.items():
        errors = []
        for w in widths:
            np.random.seed(42)
            err = best_sheffer_approx(fn, interval, w, num_restarts=20)
            errors.append(err)

        if errors[0] > 0 and errors[-1] > 0:
            rate = np.log(errors[0]/errors[-1]) / np.log(widths[-1]/widths[0])
        else:
            rate = 0

        print(f"  {name:<25} errors: {errors[0]:.2e} → {errors[-1]:.2e}  rate: {rate:.2f}")

    print()
    print("Expected: C∞ functions → fast convergence (rate > 2)")
    print("          C⁰ functions → slow convergence (rate ≈ 1)")

if __name__ == '__main__':
    results = run_convergence_study()
    verify_jackson_conjecture()

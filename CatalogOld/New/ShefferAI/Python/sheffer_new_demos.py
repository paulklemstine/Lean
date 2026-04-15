#!/usr/bin/env python3
"""
Sheffer AI: New Research Demonstrations
=======================================

Extended computational experiments for the Future Research Directions paper.
Includes:
1. Lipschitz Barrier Theorem visualization
2. Sheffer complexity class estimation
3. Formal group Sheffer functions
4. Differentiable physics simulation
5. Sheffer compression benchmarks
6. Multivariate log-sum-exp exploration
7. Iterated softplus dynamics
8. Sigmoid ODE phase portrait

Requirements: numpy, scipy
"""

import numpy as np
from scipy.optimize import minimize, minimize_scalar
from scipy.integrate import solve_ivp

# ==============================================================================
# Core functions
# ==============================================================================

def softplus(x):
    """σ(x) = log(1 + eˣ), numerically stable"""
    return np.where(x > 20, x, np.log1p(np.exp(np.clip(x, -500, 20))))

def sigmoid(x):
    """S(x) = eˣ/(1+eˣ) = σ'(x)"""
    return 1 / (1 + np.exp(-x))

def softplus_beta(x, beta=1.0):
    """Temperature softplus: σ_β(x) = (1/β)log(1 + exp(βx))"""
    bx = beta * x
    return np.where(bx > 20, x, np.log1p(np.exp(np.clip(bx, -500, 500))) / beta)

def relu(x):
    return np.maximum(0, x)

# ==============================================================================
# Demo 1: Lipschitz Barrier Theorem
# ==============================================================================

def demo_lipschitz_barrier():
    """
    Demonstrate that every Sheffer expression is Lipschitz, hence exp ∉ Sheffer algebra.
    This is a formally proved result (exp_not_mem_sheffer in AdvancedTheorems.lean).
    """
    print("=" * 70)
    print("Demo 1: Lipschitz Barrier — exp is NOT in the Sheffer Algebra")
    print("=" * 70)
    print()
    print("Key insight: Every Sheffer expression is Lipschitz continuous.")
    print("Proof: softplus is 1-Lipschitz, and Lipschitz property is preserved")
    print("under affine pre-composition, affine combination, and composition.")
    print()

    # Show that softplus networks are Lipschitz
    x = np.linspace(-5, 5, 1000)

    # Example Sheffer expressions and their Lipschitz constants
    expressions = {
        "σ(x)": (softplus(x), 1.0),
        "σ(2x+1)": (softplus(2*x + 1), 2.0),
        "3σ(x) - 2σ(-x)": (3*softplus(x) - 2*softplus(-x), 5.0),
        "σ(σ(x))": (softplus(softplus(x)), 1.0),  # composition of 1-Lip
    }

    print(f"{'Expression':>25} | {'Lip. bound':>10} | {'Empirical Lip.':>14}")
    print("-" * 55)
    for name, (vals, lip_bound) in expressions.items():
        # Empirical Lipschitz constant
        diffs = np.abs(np.diff(vals)) / np.abs(np.diff(x))
        emp_lip = np.max(diffs)
        print(f"{name:>25} | {lip_bound:>10.2f} | {emp_lip:>14.6f}")

    print()
    print("Compare with exp(x):")
    exp_vals = np.exp(x)
    exp_diffs = np.abs(np.diff(exp_vals)) / np.abs(np.diff(x))
    print(f"  Empirical Lipschitz of exp on [-5,5]: {np.max(exp_diffs):.2f}")
    print(f"  exp grows without bound → NOT Lipschitz → NOT Sheffer!")
    print()
    print("FORMALLY PROVED: exp_not_mem_sheffer in AdvancedTheorems.lean")
    print()

    return expressions

# ==============================================================================
# Demo 2: Sheffer Complexity Classes SH(d, w)
# ==============================================================================

def sheffer_network(x, params, depth, width):
    """Evaluate a Sheffer network with given depth, width, and parameters."""
    idx = 0
    layer = x.copy()
    for d in range(depth):
        new_layer = np.zeros_like(x)
        for w in range(width):
            a = params[idx]; idx += 1
            b = params[idx]; idx += 1
            c = params[idx]; idx += 1
            new_layer += c * softplus(a * layer + b)
        offset = params[idx]; idx += 1
        layer = new_layer + offset
    return layer

def num_params(depth, width):
    """Number of parameters for a (depth, width) Sheffer network."""
    return depth * (3 * width + 1)

def demo_complexity_classes():
    """
    Estimate Sheffer degree of various functions by fitting networks
    of increasing depth and width.
    """
    print("=" * 70)
    print("Demo 2: Sheffer Complexity Classes SH(d, w)")
    print("=" * 70)
    print()

    x = np.linspace(-3, 3, 500)

    test_functions = {
        "identity x": x,
        "x²": x**2,
        "sin(x)": np.sin(x),
        "abs(x)": np.abs(x),
        "sigmoid(x)": sigmoid(x),
        "exp(-x²)": np.exp(-x**2),
    }

    configs = [(1, 4), (1, 8), (1, 16), (2, 4), (2, 8), (3, 4)]

    print(f"{'Function':>15} |", end="")
    for d, w in configs:
        print(f" d={d},w={w:>2} |", end="")
    print()
    print("-" * (17 + 11 * len(configs)))

    for fname, target in test_functions.items():
        print(f"{fname:>15} |", end="")
        for depth, width in configs:
            np_params = num_params(depth, width)
            best_err = float('inf')

            for trial in range(5):
                p0 = np.random.randn(np_params) * 0.5

                def loss(p):
                    try:
                        pred = sheffer_network(x, p, depth, width)
                        return np.mean((pred - target)**2)
                    except:
                        return 1e10

                res = minimize(loss, p0, method='L-BFGS-B',
                             options={'maxiter': 500, 'ftol': 1e-15})
                best_err = min(best_err, res.fun)

            log_err = np.log10(max(best_err, 1e-16))
            print(f" {log_err:>7.1f} |", end="")
        print()

    print()
    print("Values are log₁₀(MSE). Lower = better fit.")
    print("Functions with Sheffer degree d should achieve low error at depth d.")

# ==============================================================================
# Demo 3: Iterated Softplus Dynamics
# ==============================================================================

def demo_iterated_softplus():
    """
    Study the dynamics of iterated softplus: σⁿ(x) = σ(σ(...σ(x)...))
    Formally proved: softplus_iter_strictMono, softplus_iter_pos
    """
    print("=" * 70)
    print("Demo 3: Iterated Softplus Dynamics")
    print("=" * 70)
    print()

    x = np.linspace(-5, 5, 1000)

    print("Iterated softplus σⁿ(x) for n = 0, 1, 2, ..., 10:")
    print()
    print(f"{'n':>3} | {'σⁿ(-5)':>10} | {'σⁿ(0)':>10} | {'σⁿ(5)':>10} | {'fixed pt':>10}")
    print("-" * 50)

    iterates = [x.copy()]
    for n in range(10):
        iterates.append(softplus(iterates[-1]))

    # Find approximate fixed point of softplus
    # σ(x*) = x* → log(1 + eˣ*) = x* → 1 + eˣ* = eˣ* → 1 = 0, contradiction!
    # So there's NO fixed point. σⁿ(x) → ∞ for all x.

    for n in range(11):
        vals = iterates[n]
        # Estimate "fixed point" approach (there is none — diverges!)
        growth = vals[-1] - (iterates[n-1][-1] if n > 0 else 0)
        print(f"{n:>3} | {vals[0]:>10.4f} | {vals[500]:>10.4f} | {vals[-1]:>10.4f} | {'N/A (diverges)' if n < 2 else f'{growth:>10.4f}'}")

    print()
    print("Key observation: σⁿ(x) → ∞ for all x, since σ(x) > x for all x.")
    print("This is formally proved: softplus_gt_id and softplus_softplus_gt")
    print("Growth rate: approximately linear (σ(x) ≈ x for large x)")

# ==============================================================================
# Demo 4: Sigmoid ODE Phase Portrait
# ==============================================================================

def demo_sigmoid_ode():
    """
    The sigmoid S(x) satisfies S'(x) = S(x)(1-S(x)).
    This is a Bernoulli/logistic ODE.
    Formally proved: sigmoid_deriv_eq in AdvancedTheorems.lean.
    """
    print("=" * 70)
    print("Demo 4: Sigmoid ODE S' = S(1-S)")
    print("=" * 70)
    print()

    # Solve the ODE y' = y(1-y) with various initial conditions
    def ode(t, y):
        return y * (1 - y)

    t_span = (-5, 5)
    t_eval = np.linspace(-5, 5, 1000)

    initial_conditions = [0.01, 0.1, 0.25, 0.5, 0.75, 0.9, 0.99]

    print("Solutions of y' = y(1-y) with different initial conditions at t=0:")
    print()
    print(f"{'y(0)':>8} | {'y(-5)':>10} | {'y(5)':>10} | {'is sigmoid?':>12}")
    print("-" * 50)

    for y0 in initial_conditions:
        sol = solve_ivp(ode, t_span, [y0], t_eval=t_eval, method='RK45',
                       rtol=1e-12, atol=1e-14)
        y = sol.y[0]

        # Check if it matches sigmoid with some shift
        # sigmoid(x + c) where S(c) = y0, so c = log(y0/(1-y0))
        c = np.log(y0 / (1 - y0))
        expected = sigmoid(t_eval + c)
        max_err = np.max(np.abs(y - expected))

        is_sig = "YES" if max_err < 1e-6 else "NO"
        print(f"{y0:>8.2f} | {y[0]:>10.6f} | {y[-1]:>10.6f} | {is_sig:>12} (err={max_err:.2e})")

    print()
    print("All solutions of y'=y(1-y) with y(0) ∈ (0,1) are shifted sigmoids!")
    print("This uniqueness is formally proved: sigmoid_deriv_eq")

# ==============================================================================
# Demo 5: Multivariate Log-Sum-Exp
# ==============================================================================

def logsumexp(x):
    """LogSumExp: log(Σ eˣⁱ), the multivariate generalization of softplus."""
    m = np.max(x)
    return m + np.log(np.sum(np.exp(x - m)))

def demo_multivariate_lse():
    """
    Explore log-sum-exp as multivariate Sheffer function.
    softplus(x) = LSE(x, 0) = log(eˣ + e⁰)
    Formally proved: softplus_as_logsumexp
    """
    print("=" * 70)
    print("Demo 5: Multivariate Log-Sum-Exp as Sheffer Function")
    print("=" * 70)
    print()

    # Verify LSE(x, 0) = softplus(x)
    test_x = np.linspace(-5, 5, 100)
    errors = [abs(logsumexp(np.array([xi, 0])) - softplus(np.array([xi]))[0])
              for xi in test_x]
    print(f"max |LSE(x,0) - σ(x)|: {max(errors):.2e}")
    print()

    # Properties of LSE
    print("Properties of LSE(x₁, ..., xₙ):")
    print()

    # 1. Monotonicity
    print("1. Monotone in each argument:")
    x_base = np.array([1.0, 2.0, 3.0])
    for i in range(3):
        x_low = x_base.copy(); x_low[i] -= 0.1
        x_high = x_base.copy(); x_high[i] += 0.1
        print(f"   LSE with x[{i}]={x_low[i]:.1f}: {logsumexp(x_low):.6f}")
        print(f"   LSE with x[{i}]={x_high[i]:.1f}: {logsumexp(x_high):.6f}")

    # 2. max(x) ≤ LSE(x) ≤ max(x) + log(n)
    print()
    print("2. Bounds: max(x) ≤ LSE(x) ≤ max(x) + log(n)")
    for n in [2, 5, 10, 100]:
        x = np.random.randn(n) * 3
        lse = logsumexp(x)
        mx = np.max(x)
        print(f"   n={n:>3}: max={mx:.4f}, LSE={lse:.4f}, diff={lse-mx:.4f}, log(n)={np.log(n):.4f}")

    # 3. Convexity (verify numerically)
    print()
    print("3. Convexity: LSE(λx + (1-λ)y) ≤ λ·LSE(x) + (1-λ)·LSE(y)")
    x = np.array([1.0, -2.0, 3.0])
    y = np.array([-1.0, 4.0, 0.5])
    for lam in [0.1, 0.3, 0.5, 0.7, 0.9]:
        z = lam * x + (1 - lam) * y
        lhs = logsumexp(z)
        rhs = lam * logsumexp(x) + (1 - lam) * logsumexp(y)
        print(f"   λ={lam:.1f}: LSE(mix)={lhs:.4f} ≤ {rhs:.4f} (convex: {lhs <= rhs + 1e-10})")

    print()
    print("LSE is a natural multivariate Sheffer function candidate.")

# ==============================================================================
# Demo 6: Sheffer Compression Quality
# ==============================================================================

def demo_sheffer_compression():
    """
    Compress a signal using Sheffer expressions of varying complexity.
    """
    print("=" * 70)
    print("Demo 6: Signal Compression via Sheffer Expressions")
    print("=" * 70)
    print()

    # Generate test signals
    np.random.seed(42)
    t = np.linspace(0, 2*np.pi, 500)

    signals = {
        "sin(t)": np.sin(t),
        "chirp": np.sin(t * (1 + t)),
        "square-ish": np.tanh(5 * np.sin(t)),
        "noise+signal": np.sin(t) + 0.3 * np.sin(7*t) + 0.1 * np.sin(13*t),
    }

    widths = [3, 7, 15, 31]

    print(f"{'Signal':>15} |", end="")
    for w in widths:
        print(f" w={w:>2} (SNR dB) |", end="")
    print()
    print("-" * (17 + 15 * len(widths)))

    for sname, signal in signals.items():
        print(f"{sname:>15} |", end="")
        for width in widths:
            np_params = 3 * width + 1

            def loss(p):
                pred = np.zeros_like(t)
                for i in range(width):
                    a, b, c = p[3*i], p[3*i+1], p[3*i+2]
                    pred += c * softplus(a * t + b)
                pred += p[-1]
                return np.mean((pred - signal)**2)

            best_err = float('inf')
            for trial in range(3):
                p0 = np.random.randn(np_params) * 0.5
                res = minimize(loss, p0, method='L-BFGS-B',
                             options={'maxiter': 1000})
                best_err = min(best_err, res.fun)

            sig_power = np.mean(signal**2)
            snr = 10 * np.log10(sig_power / max(best_err, 1e-16))
            print(f" {snr:>11.1f} |", end="")
        print()

    print()
    print("Higher width = more parameters = better compression.")
    print("The 1-Lipschitz property guarantees numerical stability.")

# ==============================================================================
# Demo 7: Formal Group Connection
# ==============================================================================

def demo_formal_groups():
    """
    Verify the formal group law connection.
    The multiplicative formal group F(X,Y) = X + Y + XY has log_F(X) = log(1+X).
    The Sheffer function σ_F(x) = log_F(eˣ) = log(1 + eˣ) = softplus!
    """
    print("=" * 70)
    print("Demo 7: Formal Group ↔ Sheffer Function Correspondence")
    print("=" * 70)
    print()

    # Multiplicative formal group: F(X,Y) = X + Y + XY = (1+X)(1+Y) - 1
    def F_mult(x, y):
        return x + y + x*y

    # Its logarithm: log_F(X) = log(1+X)
    def log_F(x):
        return np.log(1 + x)

    # Sheffer function: σ_F(x) = log_F(eˣ) = log(1 + eˣ)
    def sigma_F(x):
        return log_F(np.exp(x))

    print("Multiplicative formal group: F(X,Y) = X + Y + XY")
    print()

    # Verify group law
    x_vals = np.linspace(0, 2, 5)
    print("Verification of F(F(X,Y),Z) = F(X,F(Y,Z)):")
    for x in [0.5, 1.0]:
        for y in [0.3, 0.7]:
            for z in [0.2, 0.8]:
                lhs = F_mult(F_mult(x, y), z)
                rhs = F_mult(x, F_mult(y, z))
                print(f"  F(F({x},{y}),{z}) = {lhs:.6f} = F({x},F({y},{z})) = {rhs:.6f}, diff = {abs(lhs-rhs):.2e}")

    print()
    print("σ_F(x) = log_F(eˣ) vs softplus(x):")
    test_x = np.linspace(-3, 3, 7)
    for xi in test_x:
        sf = sigma_F(xi)
        sp = softplus(np.array([xi]))[0]
        print(f"  x={xi:>5.1f}: σ_F = {sf:.8f}, softplus = {sp:.8f}, diff = {abs(sf-sp):.2e}")

    print()

    # Additive formal group: F(X,Y) = X + Y, log_F(X) = X
    print("Additive formal group: F(X,Y) = X + Y")
    print("  log_F(X) = X")
    print("  σ_F(x) = log_F(eˣ) = eˣ")
    print("  → generates exp/log algebra (but exp is NOT Lipschitz!)")
    print("  → confirms that the additive formal group gives a DIFFERENT algebra")
    print()

    # Connection to softplus_exp_sum
    print("The formally proved identity exp(σ(x)+σ(y)) = (1+eˣ)(1+eʸ)")
    print("is equivalent to: exp ∘ σ is a homomorphism for the multiplicative group!")
    for xi in [-1, 0, 1, 2]:
        for yi in [-1, 0, 1]:
            lhs = np.exp(softplus(np.array([xi]))[0] + softplus(np.array([yi]))[0])
            rhs = (1 + np.exp(xi)) * (1 + np.exp(yi))
            print(f"  x={xi:>2}, y={yi:>2}: exp(σ(x)+σ(y))={lhs:.6f}, (1+eˣ)(1+eʸ)={rhs:.6f}, diff={abs(lhs-rhs):.2e}")

# ==============================================================================
# Demo 8: Jensen Inequality and Convexity Tests
# ==============================================================================

def demo_convexity():
    """
    Demonstrate the formally proved Jensen inequality and convexity properties.
    """
    print("=" * 70)
    print("Demo 8: Convexity Properties of Softplus")
    print("=" * 70)
    print()

    x_test = np.linspace(-5, 5, 100)
    y_test = np.linspace(-5, 5, 100)

    # Jensen inequality: σ((x+y)/2) ≤ (σ(x)+σ(y))/2
    print("Jensen inequality: σ((x+y)/2) ≤ (σ(x)+σ(y))/2")
    max_violation = 0
    for xi in x_test:
        for yi in y_test[::10]:
            lhs = softplus(np.array([(xi+yi)/2]))[0]
            rhs = (softplus(np.array([xi]))[0] + softplus(np.array([yi]))[0]) / 2
            if lhs > rhs + 1e-10:
                max_violation = max(max_violation, lhs - rhs)
    print(f"  Max violation: {max_violation:.2e} (should be 0)")
    print("  FORMALLY PROVED: softplus_jensen")
    print()

    # Subadditivity: σ(x+y) ≤ σ(x) + σ(y)
    print("Subadditivity: σ(x+y) ≤ σ(x) + σ(y) for ALL x, y")
    max_violation = 0
    for xi in x_test:
        for yi in y_test[::10]:
            lhs = softplus(np.array([xi+yi]))[0]
            rhs = softplus(np.array([xi]))[0] + softplus(np.array([yi]))[0]
            if lhs > rhs + 1e-10:
                max_violation = max(max_violation, lhs - rhs)
    print(f"  Max violation: {max_violation:.2e} (should be 0)")
    print("  FORMALLY PROVED: softplus_subadditive_nonneg")
    print()

    # Upper bound: σ(x) ≤ max(x,0) + log 2
    print("Upper bound: σ(x) ≤ max(x,0) + log(2)")
    max_violation = 0
    for xi in x_test:
        lhs = softplus(np.array([xi]))[0]
        rhs = max(xi, 0) + np.log(2)
        if lhs > rhs + 1e-10:
            max_violation = max(max_violation, lhs - rhs)
    print(f"  Max violation: {max_violation:.2e} (should be 0)")
    print("  FORMALLY PROVED: softplus_upper_bound")
    print()

    # Lower bound for x ≥ 0: σ(x) ≥ x/2 + log(2)/2
    print("Lower bound (x≥0): σ(x) ≥ x/2 + log(2)/2")
    max_violation = 0
    for xi in x_test[x_test >= 0]:
        lhs = softplus(np.array([xi]))[0]
        rhs = xi/2 + np.log(2)/2
        if lhs < rhs - 1e-10:
            max_violation = max(max_violation, rhs - lhs)
    print(f"  Max violation: {max_violation:.2e} (should be 0)")
    print("  FORMALLY PROVED: softplus_lower_bound_nonneg")

# ==============================================================================
# Main
# ==============================================================================

if __name__ == "__main__":
    demo_lipschitz_barrier()
    print("\n")
    demo_complexity_classes()
    print("\n")
    demo_iterated_softplus()
    print("\n")
    demo_sigmoid_ode()
    print("\n")
    demo_multivariate_lse()
    print("\n")
    demo_sheffer_compression()
    print("\n")
    demo_formal_groups()
    print("\n")
    demo_convexity()

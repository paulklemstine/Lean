#!/usr/bin/env python3
"""
SPB–EML Bridge: Experimental Investigations
=============================================

Tests key hypotheses:
H1: SPB neurons on periodic data
H2: Random SPB → Cauchy invariant measure
H3: Finite field SPB group orders (p±1 law)
H4: 3D SPB = quaternion multiplication
H5: SPB approximation rates
"""

import numpy as np
from collections import Counter


# ============================================================
# Core operators
# ============================================================

def spb(x, y):
    """Stereographic Projection Bridge: (x+y)/(1-xy)"""
    d = 1 - x * y
    if isinstance(d, np.ndarray):
        return np.where(np.abs(d) < 1e-15, np.inf, (x + y) / d)
    return (x + y) / d if abs(d) > 1e-15 else float('inf')

def eml(x, y):
    """Exp-Minus-Log: exp(x) - ln(y)"""
    return np.exp(x) - np.log(y)

def spb_via_eml(x, y):
    """Compute spb(x,y) using only EML operations.
    spb(x,y) = eml(eml(0, 1-xy) - eml(0, x+y), 1)
    """
    if x + y <= 0 or 1 - x*y <= 0:
        return None  # signs don't allow this decomposition
    e1 = eml(0, 1 - x*y)  # = 1 - ln(1-xy)
    e2 = eml(0, x + y)     # = 1 - ln(x+y)
    return eml(e1 - e2, 1)  # = exp(ln(x+y) - ln(1-xy))


# ============================================================
# Experiment 1: Verify SPB-EML Conversion
# ============================================================

def experiment_spb_eml_conversion():
    """Verify spb(x,y) = eml(eml(0,1-xy) - eml(0,x+y), 1)"""
    print("=" * 70)
    print("EXPERIMENT 1: SPB–EML Conversion Accuracy")
    print("=" * 70)

    np.random.seed(42)
    errors = []
    n_tests = 10000

    for _ in range(n_tests):
        x = np.random.uniform(0.01, 0.9)
        y = np.random.uniform(0.01, 0.9)
        if x * y >= 1 or x + y <= 0:
            continue

        direct = spb(x, y)
        via_eml = spb_via_eml(x, y)
        if via_eml is not None:
            errors.append(abs(direct - via_eml))

    errors = np.array(errors)
    print(f"  Tests: {len(errors)}")
    print(f"  Max error:  {errors.max():.2e}")
    print(f"  Mean error: {errors.mean():.2e}")
    print(f"  Median:     {np.median(errors):.2e}")
    print(f"  All < 1e-10: {np.all(errors < 1e-10)}")
    print()


# ============================================================
# Experiment 2: Random SPB → Cauchy Distribution
# ============================================================

def experiment_random_spb_cauchy():
    """Test: random SPB iteration converges to Cauchy distribution"""
    print("=" * 70)
    print("EXPERIMENT 2: Random SPB Iteration → Cauchy Distribution")
    print("=" * 70)

    np.random.seed(42)

    # Iterate x_{n+1} = spb(x_n, a_n) with a_n ~ N(0,1)
    n_iter = 100000
    n_burnin = 10000

    x = 0.0
    samples = []

    for i in range(n_iter + n_burnin):
        a = np.random.normal(0, 1)
        x = spb(x, a)

        # Clip to prevent overflow
        if abs(x) > 1e10:
            x = np.sign(x) * 1e10

        if i >= n_burnin:
            samples.append(x)

    samples = np.array(samples)

    # Test against Cauchy distribution
    # Cauchy CDF: F(x) = 0.5 + arctan(x/γ)/π
    # For Cauchy(0, γ): median = 0, IQR = 2γ
    q25, q50, q75 = np.percentile(samples, [25, 50, 75])
    iqr = q75 - q25
    gamma_est = iqr / 2  # For Cauchy, IQR = 2γ

    print(f"  Samples: {len(samples)}")
    print(f"  Median:  {q50:.4f} (expected: ~0)")
    print(f"  IQR:     {iqr:.4f}")
    print(f"  γ_est:   {gamma_est:.4f}")
    print(f"  Fraction |x| > 10:  {np.mean(np.abs(samples) > 10):.4f}")
    print(f"  Fraction |x| > 100: {np.mean(np.abs(samples) > 100):.4f}")

    # Cauchy has heavy tails: fraction > 10 should be ~arctan(10/γ)/π ≈ ...
    # For Gaussian, fraction > 10 would be essentially 0
    print(f"  → Heavy tails confirm Cauchy-like distribution ({'Yes' if np.mean(np.abs(samples) > 10) > 0.01 else 'No'})")
    print()


# ============================================================
# Experiment 3: Finite Field SPB Group Orders
# ============================================================

def experiment_finite_field():
    """Test the p±1 law for SPB groups over F_p"""
    print("=" * 70)
    print("EXPERIMENT 3: Finite Field SPB Group Orders (p±1 Law)")
    print("=" * 70)
    print("  Hypothesis: |SPB(F_p)| = p+1 if p≡3(4), p-1 if p≡1(4)")
    print()

    def spb_mod(x, y, p):
        d = (1 - x * y) % p
        if d == 0:
            return None  # pole
        return ((x + y) % p * pow(d, -1, p)) % p

    def find_spb_group_order(p):
        """Find the full group order by trying all generators g=2..p-1
        and returning the max orbit size (including infinity)."""
        max_size = 0
        for g in range(2, p):
            orbit = set()
            current = 0
            for _ in range(2*p + 5):
                orbit.add(current)
                nxt = spb_mod(current, g, p)
                if nxt is None:
                    orbit.add('inf')
                    # spb(inf, g) = -1/g mod p
                    current = (-pow(g, -1, p)) % p
                elif nxt in orbit:
                    break
                else:
                    current = nxt
            max_size = max(max_size, len(orbit))
            if max_size >= p + 1:
                break
        return max_size

    primes = [p for p in range(3, 200) if all(p % k != 0 for k in range(2, int(p**0.5)+1))]

    correct = 0
    total = 0

    print(f"  {'p':>5} {'p%4':>4} {'predicted':>10} {'actual':>8} {'match':>6}")
    print("  " + "-" * 38)

    for p in primes[:30]:  # Show first 30
        predicted = p + 1 if p % 4 == 3 else p - 1
        actual = find_spb_group_order(p)
        match = actual == predicted
        if match:
            correct += 1
        total += 1
        symbol = "✓" if match else "✗"
        print(f"  {p:5d} {p%4:4d} {predicted:10d} {actual:8} {symbol:>6}")

    # Check all primes
    for p in primes[30:]:
        predicted = p + 1 if p % 4 == 3 else p - 1
        actual = find_spb_group_order(p)
        if actual == predicted:
            correct += 1
        total += 1

    print(f"\n  Total primes tested: {total}")
    print(f"  Correct predictions: {correct}/{total} ({100*correct/total:.1f}%)")
    print()


# ============================================================
# Experiment 4: 3D SPB and Quaternions
# ============================================================

def experiment_3d_spb():
    """Test: 3D SPB corresponds to quaternion multiplication"""
    print("=" * 70)
    print("EXPERIMENT 4: 3D SPB ↔ Quaternion Multiplication")
    print("=" * 70)

    def spb3(u, v):
        """Correct 3D SPB derived from quaternion multiplication via
        stereographic projection of S³:
        spb₃(u,v) = ((1-|v|²)u + (1-|u|²)v + 2u×v) / (1 + |u|²|v|² - 2u·v)
        
        NOTE: The naive formula (u+v+u×v)/(1-u·v) is INCORRECT.
        The correct formula involves the norms |u|² and |v|².
        When restricted to 1D (u=(a,0,0), v=(b,0,0)), this reduces to
        the standard spb(a,b) = (a+b)/(1-ab).
        """
        nu2 = np.dot(u, u)
        nv2 = np.dot(v, v)
        cross = np.cross(u, v)
        dot = np.dot(u, v)
        denom = 1 + nu2 * nv2 - 2 * dot
        if abs(denom) < 1e-15:
            return np.array([np.inf, np.inf, np.inf])
        return ((1 - nv2) * u + (1 - nu2) * v + 2 * cross) / denom

    def quat_mul(q1, q2):
        """Quaternion multiplication (w, x, y, z)"""
        w1, x1, y1, z1 = q1
        w2, x2, y2, z2 = q2
        return np.array([
            w1*w2 - x1*x2 - y1*y2 - z1*z2,
            w1*x2 + x1*w2 + y1*z2 - z1*y2,
            w1*y2 - x1*z2 + y1*w2 + z1*x2,
            w1*z2 + x1*y2 - y1*x2 + z1*w2
        ])

    def cayley3(u):
        """3D Cayley: ℝ³ → S³ (as unit quaternion) via stereographic
        projection inverse: u → ((1-|u|²), 2u) / (1+|u|²)."""
        norm_sq = np.dot(u, u)
        denom = 1 + norm_sq
        return np.array([
            (1 - norm_sq) / denom,
            2*u[0] / denom,
            2*u[1] / denom,
            2*u[2] / denom
        ])

    def cayley3_inv(q):
        """Inverse 3D Cayley: S³ → ℝ³"""
        w, x, y, z = q
        if abs(1 + w) < 1e-15:
            return np.array([np.inf, np.inf, np.inf])
        return np.array([x, y, z]) / (1 + w)

    print("  Testing: C₃(spb₃(u,v)) = C₃(u) · C₃(v)")
    print()

    np.random.seed(42)
    max_error = 0

    for trial in range(10):
        u = np.random.randn(3) * 0.5
        v = np.random.randn(3) * 0.5

        # Method 1: SPB then Cayley
        s = spb3(u, v)
        lhs = cayley3(s)

        # Method 2: Cayley then quaternion multiply
        cu = cayley3(u)
        cv = cayley3(v)
        rhs = quat_mul(cu, cv)

        error = np.linalg.norm(lhs - rhs)
        max_error = max(max_error, error)

        if trial < 5:
            print(f"  Trial {trial+1}:")
            print(f"    u = [{u[0]:.4f}, {u[1]:.4f}, {u[2]:.4f}]")
            print(f"    v = [{v[0]:.4f}, {v[1]:.4f}, {v[2]:.4f}]")
            print(f"    spb₃(u,v) = [{s[0]:.4f}, {s[1]:.4f}, {s[2]:.4f}]")
            print(f"    |C₃(spb₃) - C₃(u)·C₃(v)| = {error:.2e}")
            print()

    print(f"  Max error over 10 trials: {max_error:.2e}")
    print(f"  → 3D SPB = quaternion multiplication: {'✓ CONFIRMED' if max_error < 1e-10 else '✗ FAILED'}")
    print()

    # Non-commutativity check
    print("  Non-commutativity (Thomas-Wigner rotation):")
    u = np.array([0.5, 0.3, 0.0])
    v = np.array([0.0, 0.4, 0.2])
    suv = spb3(u, v)
    svu = spb3(v, u)
    print(f"    spb₃(u,v) = [{suv[0]:.6f}, {suv[1]:.6f}, {suv[2]:.6f}]")
    print(f"    spb₃(v,u) = [{svu[0]:.6f}, {svu[1]:.6f}, {svu[2]:.6f}]")
    print(f"    Difference: {np.linalg.norm(suv - svu):.6f}")
    print(f"    → Non-commutative: {'✓ YES' if np.linalg.norm(suv - svu) > 1e-10 else '✗ NO'}")
    print()


# ============================================================
# Experiment 5: SPB Approximation Rates
# ============================================================

def experiment_approximation():
    """Test SPB tree approximation of continuous functions"""
    print("=" * 70)
    print("EXPERIMENT 5: SPB Tree Approximation Rates")
    print("=" * 70)
    print("  Target: f(x) = sin(3x) on [-1, 1]")
    print()

    # SPB trees of depth n generate tan(P(arctan(x))) where P is a polynomial
    # For depth n, we can represent tan(n·arctan(x)) = Chebyshev-like

    x = np.linspace(-0.99, 0.99, 1000)
    target = np.sin(3 * x)

    errors = []
    for n in range(1, 15):
        # tan(n·arctan(x)) is the SPB "basis function" of order n
        # Approximate target as linear combination via least squares
        basis = np.zeros((len(x), n))
        for k in range(n):
            basis[:, k] = np.tan((k+1) * np.arctan(x))
            # Clip to prevent overflow
            basis[:, k] = np.clip(basis[:, k], -100, 100)

        # Solve least squares
        try:
            coeffs, _, _, _ = np.linalg.lstsq(basis, target, rcond=None)
            approx = basis @ coeffs
            err = np.max(np.abs(target - approx))
            errors.append(err)
            print(f"  Depth {n:2d}: max error = {err:.6e}")
        except:
            errors.append(float('inf'))
            print(f"  Depth {n:2d}: FAILED (numerical issues)")

    if len(errors) > 3:
        # Estimate convergence rate
        log_errors = [np.log(e) for e in errors if e > 0 and e < 1]
        if len(log_errors) > 3:
            rates = [log_errors[i+1] - log_errors[i] for i in range(len(log_errors)-1)]
            avg_rate = np.mean(rates[-3:])
            print(f"\n  Estimated convergence rate: ~exp({avg_rate:.2f}·n)")
            print(f"  Effective ratio ρ = {np.exp(-avg_rate):.2f}")
    print()


# ============================================================
# Experiment 6: Cauchy Entropy Additivity
# ============================================================

def experiment_entropy():
    """Verify H(spb(x,y)) = H(x) + H(y) - 2·ln|1-xy| over many samples"""
    print("=" * 70)
    print("EXPERIMENT 6: Cauchy Entropy Additivity (Large-Scale)")
    print("=" * 70)

    np.random.seed(42)
    n = 100000

    x = np.random.uniform(-5, 5, n)
    y = np.random.uniform(-5, 5, n)

    # Filter out poles
    mask = np.abs(1 - x*y) > 1e-8
    x, y = x[mask], y[mask]

    s = spb(x, y)
    H = lambda t: np.log(1 + t**2)

    lhs = H(s)
    rhs = H(x) + H(y) - 2 * np.log(np.abs(1 - x*y))

    errors = np.abs(lhs - rhs)

    print(f"  Samples tested: {len(x)}")
    print(f"  Max error:  {errors.max():.2e}")
    print(f"  Mean error: {errors.mean():.2e}")
    print(f"  99th percentile: {np.percentile(errors, 99):.2e}")
    print(f"  All < 1e-10: {np.all(errors < 1e-10)}")
    print()


# ============================================================
# Experiment 7: SPB Neuron vs Standard Neuron
# ============================================================

def experiment_spb_neuron():
    """Simple comparison: SPB neuron vs linear neuron on periodic data"""
    print("=" * 70)
    print("EXPERIMENT 7: SPB Neuron vs Linear Neuron (Periodic Data)")
    print("=" * 70)

    np.random.seed(42)

    # Generate periodic data
    n = 200
    x = np.linspace(0, 4*np.pi, n)
    y_true = np.sin(x) + 0.5 * np.sin(3*x)

    # SPB neuron: y = spb(w1*x, w2*x) = (w1+w2)*x / (1 - w1*w2*x²)
    # This naturally generates rational functions with periodic behavior

    # Grid search for best SPB weights
    best_spb_err = float('inf')
    best_w = (0, 0)

    for w1 in np.linspace(-2, 2, 100):
        for w2 in np.linspace(-2, 2, 100):
            try:
                pred = spb(w1 * np.tan(x/4), w2 * np.tan(x/4))
                err = np.mean((pred - y_true)**2)
                if np.isfinite(err) and err < best_spb_err:
                    best_spb_err = err
                    best_w = (w1, w2)
            except:
                pass

    # Linear neuron: y = w1*x + w2
    A = np.vstack([x, np.ones(n)]).T
    coeffs = np.linalg.lstsq(A, y_true, rcond=None)[0]
    linear_pred = A @ coeffs
    linear_err = np.mean((linear_pred - y_true)**2)

    # Polynomial neuron (degree 5)
    poly_coeffs = np.polyfit(x, y_true, 5)
    poly_pred = np.polyval(poly_coeffs, x)
    poly_err = np.mean((poly_pred - y_true)**2)

    print(f"  Target: sin(x) + 0.5*sin(3x)")
    print(f"  Linear neuron MSE:     {linear_err:.6f}")
    print(f"  Polynomial (deg 5) MSE: {poly_err:.6f}")
    print(f"  SPB neuron MSE:        {best_spb_err:.6f} (w1={best_w[0]:.2f}, w2={best_w[1]:.2f})")
    print()


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║     SPB–EML Bridge: Experimental Investigations            ║")
    print("║     Testing Key Hypotheses                                  ║")
    print("╚══════════════════════════════════════════════════════════════╝")
    print()

    experiment_spb_eml_conversion()
    experiment_random_spb_cauchy()
    experiment_finite_field()
    experiment_3d_spb()
    experiment_approximation()
    experiment_entropy()
    experiment_spb_neuron()

    print("=" * 70)
    print("All experiments complete!")
    print("=" * 70)

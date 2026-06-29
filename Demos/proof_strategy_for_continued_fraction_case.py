#!/usr/bin/env python3
"""
Applications of Continued Fraction Spectral Mixing Theory

Demonstrates real-world applications:
1. Pseudorandom number quality testing via CF digit correlations
2. Diophantine approximation quality bounds
3. Euclidean algorithm runtime statistics
4. Cryptographic key generation quality analysis
"""

import numpy as np
from typing import List, Tuple
import time


def gauss_map(x: float) -> float:
    """The Gauss map T(x) = fract(1/x)."""
    if x <= 0:
        return 0.0
    return 1.0 / x - int(1.0 / x)


def cf_digits(x: float, k: int) -> List[int]:
    """Extract first k CF digits."""
    digits = []
    for _ in range(k):
        if x <= 1e-15:
            break
        a = int(1.0 / x)
        digits.append(a)
        x = gauss_map(x)
    return digits


# ============================================================
# Application 1: Pseudorandomness Testing
# ============================================================
def test_pseudorandomness():
    """
    Test: do CF digits of pseudorandom numbers behave like
    independent draws from the Gauss-Kuzmin distribution?

    The mixing theorem predicts that digits separated by
    large gaps should be nearly independent.
    """
    print("=" * 60)
    print("APPLICATION 1: Pseudorandomness Quality via CF Digits")
    print("=" * 60)

    N = 20000
    rng = np.random.default_rng(42)

    # Test 1: Python's random
    samples = rng.uniform(0.001, 0.999, N)

    # Collect digit pairs at various separations
    separations = [0, 1, 2, 5, 10, 20]
    max_digit = 5

    print(f"\n  Testing {N} random numbers")
    print(f"  Checking independence of digit pairs at various separations")
    print(f"\n  {'Sep':<6} {'χ² stat':<12} {'p-value':<12} {'Independent?'}")
    print("  " + "-" * 45)

    for sep in separations:
        # Count joint digit frequencies
        joint = np.zeros((max_digit, max_digit))
        marginal1 = np.zeros(max_digit)
        marginal2 = np.zeros(max_digit)
        count = 0

        for x in samples:
            digits = cf_digits(x, sep + 2)
            if len(digits) >= sep + 2:
                d1 = min(digits[0], max_digit) - 1
                d2 = min(digits[sep + 1], max_digit) - 1
                if 0 <= d1 < max_digit and 0 <= d2 < max_digit:
                    joint[d1, d2] += 1
                    marginal1[d1] += 1
                    marginal2[d2] += 1
                    count += 1

        if count > 0:
            # Chi-squared test for independence
            chi2 = 0
            for i in range(max_digit):
                for j in range(max_digit):
                    expected = marginal1[i] * marginal2[j] / count
                    if expected > 0:
                        chi2 += (joint[i, j] - expected) ** 2 / expected

            dof = (max_digit - 1) ** 2
            # Approximate p-value (chi2 with dof degrees of freedom)
            p_value = 1 - min(chi2 / dof, 5.0) / 5.0  # rough approximation
            independent = "Yes" if chi2 < 2 * dof else "Borderline" if chi2 < 3 * dof else "No"
            print(f"  {sep:<6} {chi2:<12.2f} {p_value:<12.4f} {independent}")


# ============================================================
# Application 2: Diophantine Approximation Bounds
# ============================================================
def diophantine_bounds():
    """
    Use the mixing theorem to predict the quality of
    rational approximations to random reals.

    The key insight: mixing implies that large partial quotients
    (which give unusually good approximations) occur with
    predictable frequency.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Diophantine Approximation Quality")
    print("=" * 60)

    N = 10000
    K = 30  # digits to examine
    rng = np.random.default_rng(123)

    # Generate random reals and compute their CF expansions
    all_digits = []
    for _ in range(N):
        x = rng.uniform(0.001, 0.999)
        digits = cf_digits(x, K)
        all_digits.extend(digits)

    digits_arr = np.array(all_digits)

    # Gauss-Kuzmin predictions
    print(f"\n  Analyzing {len(all_digits)} CF digits from {N} random reals")
    print(f"\n  {'Statistic':<30} {'Observed':<12} {'GK Theory':<12}")
    print("  " + "-" * 55)

    # Mean digit
    mean_d = np.mean(digits_arr)
    # Theoretical mean: sum k * log2((k+1)^2/(k(k+2))) for k=1..inf ≈ ∞ (diverges!)
    # But truncated mean is finite
    theory_mean = sum(k * np.log2((k+1)**2 / (k*(k+2))) for k in range(1, 100))
    print(f"  {'Mean partial quotient':<30} {mean_d:<12.4f} {theory_mean:<12.4f}")

    # Probability of digit = 1
    prob_1 = np.mean(digits_arr == 1)
    theory_1 = np.log2(4/3)
    print(f"  {'P(digit = 1)':<30} {prob_1:<12.4f} {theory_1:<12.4f}")

    # Probability of digit ≥ 10 (large digit = good approximation)
    prob_large = np.mean(digits_arr >= 10)
    theory_large = 1 - sum(np.log2((k+1)**2 / (k*(k+2))) for k in range(1, 10))
    print(f"  {'P(digit ≥ 10)':<30} {prob_large:<12.4f} {theory_large:<12.4f}")

    # Consecutive large digits (mixing predicts near independence)
    pairs = list(zip(digits_arr[:-1], digits_arr[1:]))
    both_ge5 = sum(1 for a, b in pairs if a >= 5 and b >= 5) / len(pairs)
    indep_pred = np.mean(digits_arr >= 5) ** 2
    print(f"  {'P(two consec ≥ 5)':<30} {both_ge5:<12.4f} {indep_pred:<12.4f}")


# ============================================================
# Application 3: Euclidean Algorithm Statistics
# ============================================================
def euclidean_algorithm_stats():
    """
    The CF expansion is the Euclidean algorithm in disguise.
    The number of steps equals the number of CF digits.
    Mixing theory predicts step-count distributions.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Euclidean Algorithm Runtime Analysis")
    print("=" * 60)

    def gcd_steps(a: int, b: int) -> int:
        """Count steps in Euclidean algorithm."""
        steps = 0
        while b > 0:
            a, b = b, a % b
            steps += 1
        return steps

    # Test with random pairs
    N = 50000
    max_val = 10000
    rng = np.random.default_rng(42)

    steps_list = []
    for _ in range(N):
        a = rng.integers(1, max_val)
        b = rng.integers(1, max_val)
        steps_list.append(gcd_steps(a, b))

    steps_arr = np.array(steps_list)
    mean_steps = np.mean(steps_arr)
    std_steps = np.std(steps_arr)

    # Theory: mean ≈ (12 ln 2 / π²) ln(max_val) ≈ 0.8427 * ln(max_val)
    theory_mean = 12 * np.log(2) / np.pi**2 * np.log(max_val)
    theory_const = 12 * np.log(2) / np.pi**2

    print(f"\n  {N} random pairs with entries up to {max_val}")
    print(f"  Mean steps: {mean_steps:.2f} (theory: {theory_mean:.2f})")
    print(f"  Std steps:  {std_steps:.2f}")
    print(f"  Porter constant: {theory_const:.4f}")

    # Distribution
    print(f"\n  {'Steps':<8} {'Count':<10} {'Frequency':<12}")
    print("  " + "-" * 30)
    for s in range(1, 25):
        count = np.sum(steps_arr == s)
        if count > 0:
            print(f"  {s:<8} {count:<10} {count/N:<12.4f}")


# ============================================================
# Application 4: Information-Theoretic Decay
# ============================================================
def information_decay():
    """
    Demonstrate that mutual information between CF digits
    decays exponentially with separation, as predicted by
    the mixing theorem.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 4: Information-Theoretic Digit Decay")
    print("=" * 60)

    N = 50000
    max_digit = 8
    max_sep = 15
    rng = np.random.default_rng(42)

    # Generate equilibrium samples
    samples = rng.uniform(0.001, 0.999, N)
    for _ in range(200):
        samples = np.array([gauss_map(x) for x in samples])

    # Compute mutual information at various separations
    print(f"\n  Mutual information I(a_1; a_{1+sep}) vs separation")
    print(f"\n  {'Separation':<12} {'MI (bits)':<15} {'Log MI':<12}")
    print("  " + "-" * 40)

    mis = []
    for sep in range(max_sep + 1):
        # Collect digit pairs
        joint = np.zeros((max_digit, max_digit))
        count = 0

        for x in samples:
            digits = cf_digits(x, sep + 2)
            if len(digits) >= sep + 2:
                d1 = min(digits[0], max_digit) - 1
                d2 = min(digits[sep + 1], max_digit) - 1
                if 0 <= d1 < max_digit and 0 <= d2 < max_digit:
                    joint[d1, d2] += 1
                    count += 1

        if count > 100:
            joint /= count
            marginal1 = joint.sum(axis=1)
            marginal2 = joint.sum(axis=0)

            mi = 0
            for i in range(max_digit):
                for j in range(max_digit):
                    if joint[i, j] > 1e-10 and marginal1[i] > 1e-10 and marginal2[j] > 1e-10:
                        mi += joint[i, j] * np.log2(joint[i, j] / (marginal1[i] * marginal2[j]))

            mis.append(mi)
            log_mi = np.log(abs(mi)) if abs(mi) > 1e-15 else -99
            print(f"  {sep:<12} {mi:<15.6f} {log_mi:<12.4f}")

    # Fit exponential decay
    if len(mis) > 5:
        valid = [(i, m) for i, m in enumerate(mis) if m > 1e-6 and i >= 1]
        if len(valid) >= 3:
            ns = np.array([v[0] for v in valid])
            log_m = np.array([np.log(v[1]) for v in valid])
            slope, _ = np.polyfit(ns, log_m, 1)
            print(f"\n  Estimated MI decay rate: exp({slope:.4f} * n)")
            print(f"  Decay ratio per step: {np.exp(slope):.4f}")


if __name__ == "__main__":
    test_pseudorandomness()
    diophantine_bounds()
    euclidean_algorithm_stats()
    information_decay()
    print("\n" + "=" * 60)
    print("All applications completed!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Continued Fraction Dynamics: Demonstrations and Numerical Experiments

Demonstrates the key mathematical concepts from the formalized theory:
1. Gauss map dynamics and orbit visualization
2. Continued fraction matrix encoding
3. Exponential decorrelation of cylinder observables
4. Convergent computation via matrix products
"""

import numpy as np
from fractions import Fraction
from typing import List, Tuple


def gauss_map(x: float) -> float:
    """The Gauss continued fraction map T(x) = fract(1/x)."""
    if x == 0:
        return 0.0
    return 1.0 / x - int(1.0 / x)


def partial_quotient(x: float) -> int:
    """Extract the first partial quotient: floor(1/x)."""
    if x <= 0:
        return 0
    return int(1.0 / x)


def cf_digits(x: float, k: int) -> List[int]:
    """Extract the first k continued fraction digits of x."""
    digits = []
    for _ in range(k):
        if x <= 0:
            break
        a = int(1.0 / x)
        digits.append(a)
        x = gauss_map(x)
    return digits


def cf_matrix(a: int) -> np.ndarray:
    """The continued fraction matrix [[0, 1], [1, a]]."""
    return np.array([[0, 1], [1, a]], dtype=np.int64)


def word_matrix(digits: List[int]) -> np.ndarray:
    """Product of CF matrices for a digit word."""
    M = np.eye(2, dtype=np.int64)
    for a in digits:
        M = M @ cf_matrix(a)
    return M


def convergent_from_matrix(M: np.ndarray) -> Tuple[int, int]:
    """Extract convergent p/q from word matrix."""
    return int(M[0, 1]), int(M[1, 1])


def gauss_measure_density(x: float) -> float:
    """The Gauss measure density: 1/((1+x) * log(2))."""
    return 1.0 / ((1 + x) * np.log(2))


# ============================================================
# Demo 1: Gauss Map Orbits
# ============================================================
def demo_gauss_orbits():
    """Show how the Gauss map generates continued fraction digits."""
    print("=" * 60)
    print("DEMO 1: Gauss Map Orbits and CF Digits")
    print("=" * 60)

    test_values = [
        ("√2 - 1", np.sqrt(2) - 1),
        ("π - 3", np.pi - 3),
        ("e - 2", np.e - 2),
        ("1/φ² (golden ratio)", 2 / (1 + np.sqrt(5))),
    ]

    for name, x0 in test_values:
        digits = cf_digits(x0, 10)
        print(f"\n  x = {name} ≈ {x0:.10f}")
        print(f"  CF digits: {digits}")

        # Show orbit
        x = x0
        orbit = [x]
        for _ in range(5):
            x = gauss_map(x)
            orbit.append(x)
        print(f"  Orbit: {' → '.join(f'{v:.4f}' for v in orbit)}")


# ============================================================
# Demo 2: Matrix Encoding and Determinants
# ============================================================
def demo_matrix_encoding():
    """Verify the matrix encoding and determinant theorem."""
    print("\n" + "=" * 60)
    print("DEMO 2: Matrix Encoding (Theorem: det = (-1)^length)")
    print("=" * 60)

    test_words = [
        [1],
        [1, 2],
        [1, 2, 3],
        [2, 3, 1, 4],
        [1, 1, 1, 1, 1],
        [3, 7, 15, 1],  # digits of π
    ]

    print(f"\n  {'Word':<20} {'det(M)':<10} {'(-1)^len':<10} {'Match?'}")
    print("  " + "-" * 50)

    for w in test_words:
        M = word_matrix(w)
        det = int(np.round(np.linalg.det(M)))
        expected = (-1) ** len(w)
        match = "✓" if det == expected else "✗"
        print(f"  {str(w):<20} {det:<10} {expected:<10} {match}")

        # Also show convergent
        p, q = convergent_from_matrix(M)
        if q != 0:
            print(f"    Convergent: {p}/{q} = {p/q:.10f}")


# ============================================================
# Demo 3: Exponential Decorrelation
# ============================================================
def demo_decorrelation():
    """Numerically estimate correlation decay for cylinder observables."""
    print("\n" + "=" * 60)
    print("DEMO 3: Exponential Decorrelation of Cylinder Observables")
    print("=" * 60)

    N = 100000  # sample size
    max_lag = 20

    # Generate Gauss-measure samples via the map
    # Start with uniform and apply the map many times to equilibrate
    rng = np.random.default_rng(42)
    x_samples = rng.uniform(0.001, 0.999, N)
    for _ in range(100):  # burn-in
        x_samples = np.array([gauss_map(x) for x in x_samples])

    # Define cylinder observables
    def f_obs(x):
        """Observable: first digit indicator (a_1 = 1)."""
        return 1.0 if partial_quotient(x) == 1 else 0.0

    def g_obs(x):
        """Observable: first digit indicator (a_1 = 2)."""
        return 1.0 if partial_quotient(x) == 2 else 0.0

    f_vals = np.array([f_obs(x) for x in x_samples])
    mean_f = np.mean(f_vals)

    print(f"\n  Observable f: indicator(a₁ = 1)")
    print(f"  Observable g: indicator(a₁ = 2)")
    print(f"  Mean(f) = {mean_f:.4f} (theory: log₂(4/3) ≈ {np.log2(4/3):.4f})")

    g_vals = np.array([g_obs(x) for x in x_samples])
    mean_g = np.mean(g_vals)
    print(f"  Mean(g) = {mean_g:.4f} (theory: log₂(9/8) ≈ {np.log2(9/8):.4f})")

    # Compute correlations at various lags
    correlations = []
    print(f"\n  {'Lag n':<8} {'|Corr(f,g,n)|':<18} {'Log|Corr|':<15}")
    print("  " + "-" * 40)

    current_x = x_samples.copy()
    for lag in range(max_lag + 1):
        if lag > 0:
            current_x = np.array([gauss_map(x) for x in current_x])

        g_shifted = np.array([g_obs(x) for x in current_x])
        corr = np.mean(f_vals * g_shifted) - mean_f * mean_g
        abs_corr = abs(corr)
        correlations.append(abs_corr)

        if abs_corr > 1e-15:
            print(f"  {lag:<8} {abs_corr:<18.6e} {np.log(abs_corr):<15.4f}")
        else:
            print(f"  {lag:<8} {abs_corr:<18.6e} {'(≈ 0)':<15}")

    # Estimate decay rate
    valid = [(n, c) for n, c in enumerate(correlations) if c > 1e-10 and n >= 2]
    if len(valid) >= 2:
        ns = np.array([v[0] for v in valid])
        log_corrs = np.array([np.log(v[1]) for v in valid])
        # Linear fit: log|corr| ≈ log(C) + n * log(ρ)
        slope, intercept = np.polyfit(ns, log_corrs, 1)
        rho_est = np.exp(slope)
        C_est = np.exp(intercept)
        print(f"\n  Estimated decay rate ρ ≈ {rho_est:.4f}")
        print(f"  Estimated constant C ≈ {C_est:.4f}")
        print(f"  (ρ < 1 confirms exponential mixing)")


# ============================================================
# Demo 4: Convergent Approximation Quality
# ============================================================
def demo_convergents():
    """Show how convergents approximate irrational numbers."""
    print("\n" + "=" * 60)
    print("DEMO 4: Convergent Approximation via Matrix Products")
    print("=" * 60)

    targets = [
        ("√2", np.sqrt(2), [1, 2, 2, 2, 2, 2, 2, 2, 2, 2]),
        ("π", np.pi, [3, 7, 15, 1, 292, 1, 1, 1, 2]),
        ("e", np.e, [2, 1, 2, 1, 1, 4, 1, 1, 6, 1]),
    ]

    for name, true_val, digits in targets:
        print(f"\n  {name} = {true_val:.15f}")
        print(f"  CF digits: {digits}")
        print(f"  {'k':<4} {'p_k/q_k':<20} {'|error|':<15} {'q_k²|error|':<12}")
        print("  " + "-" * 55)

        for k in range(1, len(digits) + 1):
            M = word_matrix(digits[:k])
            p, q = convergent_from_matrix(M)
            if q != 0:
                approx = p / q
                error = abs(true_val - approx)
                quality = q * q * error
                print(f"  {k:<4} {p}/{q:<12} {error:<15.2e} {quality:<12.4f}")


# ============================================================
# Demo 5: Gauss-Kuzmin Statistics
# ============================================================
def demo_gauss_kuzmin():
    """Verify Gauss-Kuzmin distribution of partial quotients."""
    print("\n" + "=" * 60)
    print("DEMO 5: Gauss-Kuzmin Distribution")
    print("=" * 60)

    N = 200000
    rng = np.random.default_rng(123)
    x_samples = rng.uniform(0.001, 0.999, N)

    # Equilibrate under Gauss map
    for _ in range(200):
        x_samples = np.array([gauss_map(x) for x in x_samples])

    # Count digit frequencies
    digits = [partial_quotient(x) for x in x_samples if x > 0]
    max_digit = 10
    counts = {k: 0 for k in range(1, max_digit + 1)}
    for d in digits:
        if 1 <= d <= max_digit:
            counts[d] += 1

    total = sum(counts.values())
    print(f"\n  {'Digit':<8} {'Observed':<12} {'GK Theory':<12} {'Ratio'}")
    print("  " + "-" * 45)

    for k in range(1, max_digit + 1):
        observed = counts[k] / total
        theory = np.log2((k + 1) ** 2 / (k * (k + 2)))
        ratio = observed / theory if theory > 0 else 0
        print(f"  {k:<8} {observed:<12.4f} {theory:<12.4f} {ratio:<8.4f}")


if __name__ == "__main__":
    demo_gauss_orbits()
    demo_matrix_encoding()
    demo_decorrelation()
    demo_convergents()
    demo_gauss_kuzmin()
    print("\n" + "=" * 60)
    print("All demos completed successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualizations for Continued Fraction Spectral Mixing Theory

Generates publication-quality figures showing:
1. Gauss map dynamics and orbits
2. Correlation decay (exponential mixing)
3. Gauss-Kuzmin distribution
4. Matrix determinant pattern
5. Transfer operator spectrum
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from typing import List
import base64
from io import BytesIO


def gauss_map(x: float) -> float:
    if x <= 0:
        return 0.0
    return 1.0 / x - int(1.0 / x)


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 PNG string."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    return "data:image/png;base64," + base64.b64encode(buf.read()).decode()


# ============================================================
# Figure 1: Gauss Map Graph
# ============================================================
def plot_gauss_map():
    """Plot the Gauss map T(x) = fract(1/x)."""
    fig, ax = plt.subplots(1, 1, figsize=(8, 6))

    for n in range(1, 12):
        x = np.linspace(1/(n+1) + 0.001, 1/n - 0.001, 200)
        y = 1/x - n
        ax.plot(x, y, 'b-', linewidth=1.5, alpha=0.8)

    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1)
    ax.set_xlabel('x', fontsize=14)
    ax.set_ylabel('T(x)', fontsize=14)
    ax.set_title('The Gauss Map: T(x) = fract(1/x)', fontsize=16)
    ax.grid(True, alpha=0.3)
    ax.set_aspect('equal')

    # Add partition lines
    for n in range(1, 8):
        ax.axvline(x=1/n, color='gray', linestyle='--', alpha=0.3)

    fig.savefig('gauss_map.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64


# ============================================================
# Figure 2: Exponential Correlation Decay
# ============================================================
def plot_correlation_decay():
    """Plot exponential decay of correlations."""
    fig, ax = plt.subplots(1, 1, figsize=(8, 6))

    N = 80000
    max_lag = 25

    rng = np.random.default_rng(42)
    samples = rng.uniform(0.001, 0.999, N)
    for _ in range(200):
        samples = np.array([gauss_map(x) for x in samples])

    def f_obs(x):
        return 1.0 if x > 0 and int(1/x) == 1 else 0.0
    def g_obs(x):
        return 1.0 if x > 0 and int(1/x) == 2 else 0.0

    f_vals = np.array([f_obs(x) for x in samples])
    g_vals = np.array([g_obs(x) for x in samples])
    mean_f = np.mean(f_vals)
    mean_g = np.mean(g_vals)

    correlations = []
    current = samples.copy()
    for lag in range(max_lag + 1):
        if lag > 0:
            current = np.array([gauss_map(x) for x in current])
        g_shifted = np.array([g_obs(x) for x in current])
        corr = abs(np.mean(f_vals * g_shifted) - mean_f * mean_g)
        correlations.append(corr)

    lags = np.arange(max_lag + 1)

    # Plot on log scale
    valid_mask = np.array(correlations) > 1e-12
    ax.semilogy(lags[valid_mask], np.array(correlations)[valid_mask],
                'bo-', markersize=6, label='|Corr(f, g, n)|')

    # Fit exponential
    valid = [(n, c) for n, c in enumerate(correlations) if c > 1e-10 and n >= 1]
    if len(valid) >= 3:
        ns = np.array([v[0] for v in valid])
        log_c = np.array([np.log(v[1]) for v in valid])
        slope, intercept = np.polyfit(ns, log_c, 1)
        fit_line = np.exp(intercept + slope * lags)
        ax.semilogy(lags, fit_line, 'r--', linewidth=2,
                    label=f'C·ρⁿ (ρ ≈ {np.exp(slope):.3f})')

    ax.set_xlabel('Lag n', fontsize=14)
    ax.set_ylabel('|Correlation|', fontsize=14)
    ax.set_title('Exponential Mixing: Correlation Decay under Gauss Map', fontsize=15)
    ax.legend(fontsize=12)
    ax.grid(True, alpha=0.3)

    fig.savefig('correlation_decay.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64


# ============================================================
# Figure 3: Gauss-Kuzmin Distribution
# ============================================================
def plot_gauss_kuzmin():
    """Plot the Gauss-Kuzmin distribution of partial quotients."""
    fig, ax = plt.subplots(1, 1, figsize=(8, 6))

    max_k = 12
    ks = np.arange(1, max_k + 1)
    theory = np.array([np.log2((k+1)**2 / (k*(k+2))) for k in ks])

    # Empirical
    N = 100000
    rng = np.random.default_rng(42)
    samples = rng.uniform(0.001, 0.999, N)
    for _ in range(200):
        samples = np.array([gauss_map(x) for x in samples])

    digits = [int(1/x) for x in samples if x > 0]
    empirical = np.array([sum(1 for d in digits if d == k) / len(digits) for k in ks])

    bar_width = 0.35
    ax.bar(ks - bar_width/2, empirical, bar_width, label='Empirical', color='steelblue', alpha=0.8)
    ax.bar(ks + bar_width/2, theory, bar_width, label='Gauss-Kuzmin Theory', color='coral', alpha=0.8)

    ax.set_xlabel('Partial Quotient k', fontsize=14)
    ax.set_ylabel('Probability', fontsize=14)
    ax.set_title('Gauss-Kuzmin Distribution of CF Digits', fontsize=16)
    ax.legend(fontsize=12)
    ax.set_xticks(ks)
    ax.grid(True, alpha=0.3, axis='y')

    fig.savefig('gauss_kuzmin.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64


# ============================================================
# Figure 4: Convergent Approximation
# ============================================================
def plot_convergent_quality():
    """Plot convergent approximation errors."""
    fig, ax = plt.subplots(1, 1, figsize=(8, 6))

    targets = [
        ('√2', np.sqrt(2), [1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2]),
        ('π', np.pi, [3, 7, 15, 1, 292, 1, 1, 1, 2, 1]),
        ('e', np.e, [2, 1, 2, 1, 1, 4, 1, 1, 6, 1, 1, 8]),
    ]

    for name, val, digits in targets:
        errors = []
        for k in range(1, len(digits) + 1):
            M = np.eye(2, dtype=np.int64)
            for a in digits[:k]:
                M = M @ np.array([[0, 1], [1, a]], dtype=np.int64)
            p, q = int(M[0, 1]), int(M[1, 1])
            if q != 0:
                errors.append(abs(val - p/q))

        ax.semilogy(range(1, len(errors) + 1), errors, 'o-',
                    markersize=5, label=name)

    ax.set_xlabel('Number of CF digits k', fontsize=14)
    ax.set_ylabel('|x - pₖ/qₖ|', fontsize=14)
    ax.set_title('Convergent Approximation Quality', fontsize=16)
    ax.legend(fontsize=12)
    ax.grid(True, alpha=0.3)

    fig.savefig('convergent_quality.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64


# ============================================================
# Figure 5: Transfer Operator Spectrum
# ============================================================
def plot_spectrum():
    """Visualize the spectrum of the transfer operator."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Build transfer operator matrix
    grid_size = 100
    n_max = 40
    grid = np.linspace(0.01, 0.99, grid_size)
    matrix = np.zeros((grid_size, grid_size))

    for i, x in enumerate(grid):
        for n in range(1, n_max + 1):
            y = 1.0 / (x + n)
            weight = 1.0 / (x + n) ** 2
            j = np.argmin(np.abs(grid - y))
            matrix[i, j] += weight

    col_sums = matrix.sum(axis=0)
    col_sums[col_sums == 0] = 1
    matrix /= col_sums

    evals = np.linalg.eigvals(matrix)

    # Plot eigenvalues in complex plane
    ax = axes[0]
    theta = np.linspace(0, 2*np.pi, 100)
    ax.plot(np.cos(theta), np.sin(theta), 'k--', alpha=0.3)
    ax.scatter(evals.real, evals.imag, c='steelblue', s=20, alpha=0.6)
    ax.scatter([1], [0], c='red', s=100, zorder=5, label='λ₁ = 1')
    ax.set_xlabel('Re(λ)', fontsize=12)
    ax.set_ylabel('Im(λ)', fontsize=12)
    ax.set_title('Eigenvalues of Transfer Operator', fontsize=14)
    ax.set_aspect('equal')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Plot sorted |eigenvalues|
    ax = axes[1]
    sorted_abs = sorted(np.abs(evals), reverse=True)[:30]
    ax.bar(range(len(sorted_abs)), sorted_abs, color='steelblue', alpha=0.8)
    ax.axhline(y=1, color='red', linestyle='--', alpha=0.5, label='λ = 1')
    if len(sorted_abs) > 1:
        gap = 1 - sorted_abs[1]
        ax.annotate(f'Spectral gap ≈ {gap:.3f}',
                   xy=(1, sorted_abs[1]),
                   xytext=(5, sorted_abs[1] + 0.15),
                   arrowprops=dict(arrowstyle='->', color='red'),
                   fontsize=11, color='red')
    ax.set_xlabel('Eigenvalue index', fontsize=12)
    ax.set_ylabel('|λ|', fontsize=12)
    ax.set_title('Eigenvalue Magnitudes (Spectral Gap)', fontsize=14)
    ax.legend()
    ax.grid(True, alpha=0.3, axis='y')

    fig.tight_layout()
    fig.savefig('spectrum.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64


if __name__ == "__main__":
    print("Generating visualizations...")

    b64_gauss = plot_gauss_map()
    print("  ✓ Gauss map plot saved")

    b64_corr = plot_correlation_decay()
    print("  ✓ Correlation decay plot saved")

    b64_gk = plot_gauss_kuzmin()
    print("  ✓ Gauss-Kuzmin distribution plot saved")

    b64_conv = plot_convergent_quality()
    print("  ✓ Convergent quality plot saved")

    b64_spec = plot_spectrum()
    print("  ✓ Spectrum plot saved")

    print("\nAll visualizations generated!")
    print(f"Base64 string lengths: gauss={len(b64_gauss)}, corr={len(b64_corr)}, "
          f"gk={len(b64_gk)}, conv={len(b64_conv)}, spec={len(b64_spec)}")

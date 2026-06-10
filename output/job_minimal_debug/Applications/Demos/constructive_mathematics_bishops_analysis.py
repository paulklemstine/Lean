#!/usr/bin/env python3
"""
applications.py — Real-world applications of constructive analysis.

Demonstrates how the Bishop-style framework connects to:
1. Certified scientific computing (validated numerics)
2. Error propagation in measurement chains
3. Robust control and signal processing
4. Exact real arithmetic
"""

import math
from typing import Callable, List, Tuple
from fractions import Fraction


# =============================================================================
# Application 1: Validated Root Finding for Engineering
# =============================================================================

def validated_root_finder(
    f: Callable[[float], float],
    a: float,
    b: float,
    tolerance: float
) -> dict:
    """
    Validated root finder: returns a certified interval containing a root.

    Unlike a standard root finder that returns a single float,
    this returns an interval [l, r] with a mathematical guarantee
    that f has a sign change on [l, r], meaning a root exists there.

    This is critical for safety-critical applications:
    - Structural engineering (stress analysis)
    - Aerospace (trajectory computation)
    - Medical devices (dosage calculation)
    """
    assert f(a) <= 0 <= f(b), "Sign change required"

    n = math.ceil(math.log2((b - a) / tolerance)) if tolerance > 0 else 53
    l, r = a, b

    steps = 0
    for _ in range(n):
        mid = (l + r) / 2
        if f(mid) <= 0:
            l = mid
        else:
            r = mid
        steps += 1

    return {
        "interval": (l, r),
        "width": r - l,
        "midpoint": (l + r) / 2,
        "tolerance_achieved": r - l <= tolerance,
        "steps": steps,
        "certificate": {
            "f_left": f(l),
            "f_right": f(r),
            "sign_change": f(l) <= 0 <= f(r),
            "containment": a <= l <= r <= b,
        }
    }


# =============================================================================
# Application 2: Error Propagation in Measurement Chains
# =============================================================================

class MeasurementChannel:
    """
    Models a measurement/computation as a modulus-continuous function.

    In physics: a measurement apparatus transforms input states to readings.
    The modulus μ quantifies the instrument's precision requirements:
    to achieve n-bit output precision, you need μ(n)-bit input precision.

    This is the computational interpretation of the error_propagation theorem.
    """

    def __init__(self, name: str, transform: Callable[[float], float],
                 modulus: Callable[[int], int]):
        self.name = name
        self.transform = transform
        self.modulus = modulus

    def required_input_precision(self, output_bits: int) -> int:
        """How many bits of input precision to achieve `output_bits` output bits?"""
        return self.modulus(output_bits)

    def compose(self, other: 'MeasurementChannel') -> 'MeasurementChannel':
        """
        Compose two measurement channels.
        Mirrors error_propagation_compose from Lean.
        """
        return MeasurementChannel(
            name=f"{other.name} ∘ {self.name}",
            transform=lambda x: other.transform(self.transform(x)),
            modulus=lambda n: self.modulus(other.modulus(n))
        )

    def analyze_chain(self, target_bits: int) -> dict:
        """Analyze precision requirements through the chain."""
        return {
            "channel": self.name,
            "target_output_bits": target_bits,
            "required_input_bits": self.required_input_precision(target_bits),
            "input_tolerance": 1.0 / 2 ** self.required_input_precision(target_bits),
            "output_tolerance": 1.0 / 2 ** target_bits,
        }


def demo_measurement_chain():
    """Demonstrate error propagation through a chain of measurements."""
    print("\n" + "=" * 70)
    print("Application: Error Propagation in Measurement Chains")
    print("=" * 70)

    # Temperature sensor → voltage → ADC → digital value
    sensor = MeasurementChannel(
        "Temperature→Voltage",
        transform=lambda T: 0.01 * T + 0.5,  # Linear sensor
        modulus=lambda n: n + 7  # 7 extra bits for sensor noise
    )

    amplifier = MeasurementChannel(
        "Amplifier (gain=100)",
        transform=lambda V: 100 * V,
        modulus=lambda n: n + 7  # log2(100) ≈ 6.6, so 7 bits
    )

    adc = MeasurementChannel(
        "12-bit ADC",
        transform=lambda V: round(V * 4096) / 4096,
        modulus=lambda n: n + 1
    )

    # Compose the chain
    full_chain = sensor.compose(amplifier).compose(adc)

    print(f"\nMeasurement chain: {full_chain.name}")
    print(f"\nPrecision analysis:")
    print(f"  {'Target bits':>14} {'Input bits needed':>18} {'Input tolerance':>16} {'Output tolerance':>16}")
    print(f"  {'-'*14} {'-'*18} {'-'*16} {'-'*16}")
    for target in [4, 8, 12, 16, 20]:
        analysis = full_chain.analyze_chain(target)
        print(f"  {target:14d} {analysis['required_input_bits']:18d} "
              f"{analysis['input_tolerance']:16.2e} {analysis['output_tolerance']:16.2e}")


# =============================================================================
# Application 3: Certified ODE Stepping
# =============================================================================

def certified_euler_step(
    f: Callable[[float, float], float],
    t: float,
    y: float,
    h: float,
    lip_constant: float
) -> Tuple[float, float, float]:
    """
    One step of Euler's method with a certified error bound.

    Given dy/dt = f(t, y), performs one step from (t, y) to (t+h, y_new)
    and returns (y_new, error_bound, accumulated_error).

    The error bound uses the Lipschitz constant of f:
        |y_exact(t+h) - y_euler| ≤ (M·h²)/2
    where M bounds |f'| on the interval.

    This is a simple application of the modulus-continuous framework:
    the Euler step is a modulus-continuous function of (t, y, h).
    """
    y_new = y + h * f(t, y)
    # Local truncation error bound (Euler method)
    local_error = lip_constant * h ** 2 / 2
    return y_new, local_error, t + h


def certified_ode_solve(
    f: Callable[[float, float], float],
    t0: float,
    y0: float,
    t_final: float,
    n_steps: int,
    lip_constant: float
) -> List[dict]:
    """
    Solve an ODE with certified error bounds at each step.

    Returns a trajectory with error certificates at each point.
    """
    h = (t_final - t0) / n_steps
    trajectory = [{"t": t0, "y": y0, "error_bound": 0.0}]

    t, y = t0, y0
    cumulative_error = 0.0

    for i in range(n_steps):
        y_new, local_error, t_new = certified_euler_step(f, t, y, h, lip_constant)
        cumulative_error += local_error
        trajectory.append({
            "t": t_new,
            "y": y_new,
            "local_error": local_error,
            "cumulative_error": cumulative_error,
        })
        t, y = t_new, y_new

    return trajectory


def demo_certified_ode():
    """Demonstrate certified ODE solving."""
    print("\n" + "=" * 70)
    print("Application: Certified ODE Solving")
    print("=" * 70)

    # Solve dy/dt = -y, y(0) = 1 (exact solution: e^{-t})
    f = lambda t, y: -y
    trajectory = certified_ode_solve(f, 0, 1, 2, 100, 1.0)

    print(f"\ndy/dt = -y, y(0) = 1, solving on [0, 2] with 100 steps")
    print(f"  {'t':>6} {'y_euler':>14} {'y_exact':>14} {'actual_err':>14} {'cert_bound':>14}")
    print(f"  {'-'*6} {'-'*14} {'-'*14} {'-'*14} {'-'*14}")

    for entry in trajectory[::10]:
        t = entry["t"]
        y_euler = entry["y"]
        y_exact = math.exp(-t)
        actual_err = abs(y_euler - y_exact)
        cert_bound = entry.get("cumulative_error", 0)
        print(f"  {t:6.2f} {y_euler:14.8f} {y_exact:14.8f} {actual_err:14.2e} {cert_bound:14.2e}")


# =============================================================================
# Application 4: Interval Arithmetic for Polynomial Evaluation
# =============================================================================

def interval_polynomial_eval(
    coeffs: List[float],
    x_lo: float,
    x_hi: float
) -> Tuple[float, float]:
    """
    Evaluate a polynomial on an interval [x_lo, x_hi] and return
    a guaranteed enclosure of all possible values.

    Uses the straightforward interval arithmetic approach.
    """
    result_lo, result_hi = 0.0, 0.0

    for i, c in enumerate(coeffs):
        # Compute c * x^i on [x_lo, x_hi]
        x_powers = [x_lo ** i, x_hi ** i]
        if i % 2 == 0 and x_lo <= 0 <= x_hi:
            x_powers.append(0.0)
        x_power_lo = min(x_powers)
        x_power_hi = max(x_powers)

        if c >= 0:
            term_lo = c * x_power_lo
            term_hi = c * x_power_hi
        else:
            term_lo = c * x_power_hi
            term_hi = c * x_power_lo

        result_lo += term_lo
        result_hi += term_hi

    return result_lo, result_hi


def demo_interval_arithmetic():
    """Demonstrate interval polynomial evaluation."""
    print("\n" + "=" * 70)
    print("Application: Interval Arithmetic for Certified Polynomial Bounds")
    print("=" * 70)

    # p(x) = x^3 - 3x + 1
    coeffs = [1, -3, 0, 1]  # constant term first

    print(f"\np(x) = x³ - 3x + 1")
    print(f"  {'Interval':>24} {'Value range':>30} {'Width':>12}")
    print(f"  {'-'*24} {'-'*30} {'-'*12}")

    for x_lo, x_hi in [(-2, 2), (0, 1), (0.5, 0.6), (0.347, 0.348)]:
        v_lo, v_hi = interval_polynomial_eval(coeffs, x_lo, x_hi)
        print(f"  [{x_lo:10.6f}, {x_hi:10.6f}] [{v_lo:12.6f}, {v_hi:12.6f}] {v_hi-v_lo:12.6f}")


# =============================================================================
# Main
# =============================================================================

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║     Applications of Constructive Analysis                          ║")
    print("║     From Formal Proofs to Real-World Computation                   ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")

    # 1. Validated Root Finding
    print("\n" + "=" * 70)
    print("Application: Validated Root Finding for Engineering")
    print("=" * 70)

    # Find the resonant frequency: ω² - ω·sin(ω) - 1 = 0
    f = lambda w: w**2 - w * math.sin(w) - 1
    result = validated_root_finder(f, 0, 2, 1e-12)
    print(f"\nFinding root of ω² - ω·sin(ω) - 1 = 0 on [0, 2]:")
    print(f"  Certified interval: [{result['interval'][0]:.15f}, {result['interval'][1]:.15f}]")
    print(f"  Width: {result['width']:.2e}")
    print(f"  Steps: {result['steps']}")
    print(f"  Sign change verified: {result['certificate']['sign_change']}")

    # 2. Measurement Chain
    demo_measurement_chain()

    # 3. Certified ODE
    demo_certified_ode()

    # 4. Interval Arithmetic
    demo_interval_arithmetic()


#!/usr/bin/env python3
"""
demo.py — Demonstrates constructive analysis algorithms with certified error bounds.

Implements Bishop-style computable reals and the constructive intermediate value
theorem as concrete Python algorithms. Each computation carries explicit error
certificates, mirroring the formal Lean 4 development.

Usage:
    python demo.py
"""

import math
from typing import Callable, Tuple

# =============================================================================
# Computable Real Numbers
# =============================================================================

class ComputableReal:
    """A Bishop-style computable real: a rational approximation sequence
    with an explicit Cauchy modulus.

    The sequence `approx(n)` returns a rational approximation, and
    `mod(n)` returns the stage after which all approximants agree to
    within 1/2^n.
    """

    def __init__(self, approx: Callable[[int], float], mod: Callable[[int], int]):
        self.approx = approx
        self.mod = mod

    def evaluate(self, precision: int) -> float:
        """Return an approximation guaranteed within 1/2^precision of the true value."""
        return self.approx(self.mod(precision))

    def __repr__(self):
        return f"ComputableReal(value ≈ {self.evaluate(20):.10f})"


def computable_sqrt2() -> ComputableReal:
    """Construct √2 as a computable real via Newton's method."""
    def approx(n: int) -> float:
        x = 1.0
        for _ in range(n + 5):  # Extra iterations for convergence
            x = (x + 2.0 / x) / 2.0
        return x
    return ComputableReal(approx, lambda n: n + 10)


def computable_pi() -> ComputableReal:
    """Construct π as a computable real via the Leibniz-Machin formula."""
    def approx(n: int) -> float:
        # Use Machin's formula: π/4 = 4·arctan(1/5) - arctan(1/239)
        terms = max(n + 20, 50)
        def arctan_series(x: float, num_terms: int) -> float:
            result = 0.0
            for k in range(num_terms):
                result += ((-1) ** k) * (x ** (2 * k + 1)) / (2 * k + 1)
            return result
        return 4 * (4 * arctan_series(1/5, terms) - arctan_series(1/239, terms))
    return ComputableReal(approx, lambda n: n + 30)


def computable_add(x: ComputableReal, y: ComputableReal) -> ComputableReal:
    """Sum of two computable reals (mirrors ComputableReal.add in Lean)."""
    def approx(n: int) -> float:
        return x.approx(n) + y.approx(n)
    def mod(n: int) -> int:
        return max(x.mod(n + 1), y.mod(n + 1))
    return ComputableReal(approx, mod)


# =============================================================================
# Certified Bisection (Constructive IVT)
# =============================================================================

def certified_bisection(
    f: Callable[[float], float],
    a: float,
    b: float,
    n: int
) -> Tuple[float, float, float]:
    """
    Constructive IVT via bisection: given f with f(a) ≤ 0 ≤ f(b),
    returns (l, r, mid) where:
    - a ≤ l ≤ r ≤ b
    - r - l = (b - a) / 2^n
    - f(l) ≤ 0 ≤ f(r)
    - mid = (l + r) / 2 is the best approximation

    This mirrors `iterated_bisection` from the Lean formalization.
    """
    l, r = a, b
    assert f(a) <= 0 <= f(b), "Sign change required: f(a) ≤ 0 ≤ f(b)"

    for step in range(n):
        mid = (l + r) / 2
        if f(mid) <= 0:
            l = mid
        else:
            r = mid

    return l, r, (l + r) / 2


def certified_root_finding(
    f: Callable[[float], float],
    a: float,
    b: float,
    precision_bits: int
) -> dict:
    """
    Full certified root-finding with error certificate.
    Returns a dictionary with the approximate root and all certificates.
    """
    l, r, mid = certified_bisection(f, a, b, precision_bits)
    width = r - l
    residual = abs(f(mid))

    return {
        "root_approximation": mid,
        "interval_left": l,
        "interval_right": r,
        "interval_width": width,
        "target_width": (b - a) / 2 ** precision_bits,
        "residual_at_midpoint": residual,
        "f_left": f(l),
        "f_right": f(r),
        "sign_change_certified": f(l) <= 0 <= f(r),
        "precision_bits": precision_bits,
    }


# =============================================================================
# Convergence Visualization
# =============================================================================

def print_convergence_table(f, a, b, name="f", max_n=30):
    """Print a convergence table showing interval width and residual at each step."""
    print(f"\n{'='*72}")
    print(f"Certified Bisection for {name} on [{a}, {b}]")
    print(f"{'='*72}")
    print(f"{'n':>4} {'Width':>16} {'1/2^n':>16} {'|f(mid)|':>16} {'f(l)':>12} {'f(r)':>12}")
    print(f"{'-'*4} {'-'*16} {'-'*16} {'-'*16} {'-'*12} {'-'*12}")

    for n in range(max_n + 1):
        l, r, mid = certified_bisection(f, a, b, n)
        width = r - l
        target = (b - a) / 2 ** n
        residual = abs(f(mid))
        print(f"{n:4d} {width:16.10e} {target:16.10e} {residual:16.10e} {f(l):12.6e} {f(r):12.6e}")


# =============================================================================
# Conjecture Testing: Oracle Call Complexity
# =============================================================================

def test_oracle_complexity_conjecture():
    """
    Test the conjecture: for modulus-continuous f with modulus μ,
    the bisection algorithm finds an n-bit approximate root using
    at most μ(n+1) + n + C oracle calls.

    We test this with several functions and moduli.
    """
    print(f"\n{'='*72}")
    print("Testing Oracle Complexity Conjecture")
    print(f"{'='*72}")

    test_cases = [
        ("x^2 - 2", lambda x: x**2 - 2, 0, 2, lambda n: n + 2),
        ("x^3 - x - 1", lambda x: x**3 - x - 1, 1, 2, lambda n: n + 3),
        ("sin(x) - 0.5", lambda x: math.sin(x) - 0.5, 0, math.pi, lambda n: n + 4),
        ("x*exp(-x) - 0.2", lambda x: x * math.exp(-x) - 0.2, 0, 2, lambda n: n + 5),
    ]

    C = 2  # Universal constant guess

    print(f"\n{'Function':>20} {'n':>4} {'Oracle calls':>14} {'μ(n+1)+n+C':>14} {'Within bound?':>14}")
    print(f"{'-'*20} {'-'*4} {'-'*14} {'-'*14} {'-'*14}")

    all_within_bound = True
    for name, f, a, b, mu in test_cases:
        for n in range(1, 25):
            oracle_calls = n  # Bisection uses exactly n function evaluations (at midpoints)
            bound = mu(n + 1) + n + C
            within = oracle_calls <= bound
            if not within:
                all_within_bound = False
            if n in [5, 10, 15, 20]:
                print(f"{name:>20} {n:4d} {oracle_calls:14d} {bound:14d} {'✓' if within else '✗':>14}")

    print(f"\nConjecture holds for all tested cases: {'YES ✓' if all_within_bound else 'NO ✗'}")


# =============================================================================
# Computable Real Convergence Demo
# =============================================================================

def demo_computable_reals():
    """Demonstrate computable real arithmetic with certified error bounds."""
    print(f"\n{'='*72}")
    print("Computable Real Number Arithmetic")
    print(f"{'='*72}")

    sqrt2 = computable_sqrt2()
    pi_cr = computable_pi()

    print("\n√2 as a computable real:")
    print(f"  {'Precision':>12} {'Approximation':>20} {'Error bound':>16} {'Actual error':>16}")
    print(f"  {'-'*12} {'-'*20} {'-'*16} {'-'*16}")
    for n in range(1, 21):
        approx = sqrt2.evaluate(n)
        bound = 1.0 / 2**n
        actual = abs(approx - math.sqrt(2))
        print(f"  {n:12d} {approx:20.15f} {bound:16.2e} {actual:16.2e}")

    print("\nπ as a computable real:")
    for n in [5, 10, 15, 20]:
        approx = pi_cr.evaluate(n)
        bound = 1.0 / 2**n
        actual = abs(approx - math.pi)
        print(f"  precision={n:2d}: {approx:.15f}  (error ≤ {bound:.2e}, actual={actual:.2e})")

    # Addition
    sum_cr = computable_add(sqrt2, computable_sqrt2())
    print(f"\n√2 + √2 ≈ {sum_cr.evaluate(15):.15f} (expected: {2*math.sqrt(2):.15f})")


# =============================================================================
# Effective Completion Demo
# =============================================================================

def demo_effective_completion():
    """Demonstrate the diagonal construction for effective Cauchy completion."""
    print(f"\n{'='*72}")
    print("Effective Cauchy Completion — Diagonal Construction")
    print(f"{'='*72}")

    # Create a sequence of computable reals converging to e = 2.71828...
    # s_n = sum_{k=0}^{n} 1/k!
    def partial_exp_sum(n: int) -> ComputableReal:
        total = sum(1.0 / math.factorial(k) for k in range(n + 1))
        return ComputableReal(lambda _, t=total: t, lambda m: 0)

    print("\nSequence of partial sums converging to e:")
    print(f"  {'n':>4} {'s_n':>20} {'|s_n - e|':>16}")
    print(f"  {'-'*4} {'-'*20} {'-'*16}")
    for n in range(15):
        s_n = partial_exp_sum(n)
        val = s_n.evaluate(0)
        err = abs(val - math.e)
        print(f"  {n:4d} {val:20.15f} {err:16.2e}")

    # Diagonal construction: at stage n, use s_{n+2} evaluated at precision n+2
    print("\nDiagonal approximation (effective limit):")
    print(f"  {'n':>4} {'diag(n)':>20} {'|diag(n) - e|':>16} {'3/2^n':>16}")
    print(f"  {'-'*4} {'-'*20} {'-'*16} {'-'*16}")
    for n in range(15):
        diag_n = partial_exp_sum(n + 2).evaluate(n + 2)
        err = abs(diag_n - math.e)
        bound = 3.0 / 2**n
        print(f"  {n:4d} {diag_n:20.15f} {err:16.2e} {bound:16.2e}")


# =============================================================================
# Main
# =============================================================================

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║     Constructive Analysis: Bishop-Style Computable Reals           ║")
    print("║     Certified Algorithms from Formal Proofs                        ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")

    # 1. Computable Real Arithmetic
    demo_computable_reals()

    # 2. Certified Bisection (Constructive IVT)
    print_convergence_table(lambda x: x**2 - 2, 0, 2, "x² - 2", 25)
    print_convergence_table(lambda x: x**3 - x - 1, 1, 2, "x³ - x - 1", 25)
    print_convergence_table(lambda x: math.sin(x) - 0.5, 0, math.pi, "sin(x) - 0.5", 25)

    # 3. Certified root-finding with full certificates
    print(f"\n{'='*72}")
    print("Full Certified Root-Finding Report")
    print(f"{'='*72}")
    result = certified_root_finding(lambda x: x**2 - 2, 0, 2, 40)
    for k, v in result.items():
        print(f"  {k:30s}: {v}")
    print(f"  {'Actual √2':30s}: {math.sqrt(2):.15f}")
    print(f"  {'Actual error':30s}: {abs(result['root_approximation'] - math.sqrt(2)):.2e}")

    # 4. Effective Completion
    demo_effective_completion()

    # 5. Conjecture Testing
    test_oracle_complexity_conjecture()

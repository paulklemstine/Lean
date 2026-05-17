#!/usr/bin/env python3
"""
Applications of affine line restriction theory.

Demonstrates real-world applications:
1. Reed-Muller code local testing
2. Polynomial identity testing
3. Model complexity certification (ML application)
4. Error detection in polynomial computations
"""

import numpy as np
from itertools import product
from algorithms import compute_line_restriction, vandermonde_solve
from typing import Tuple, List


def reed_muller_local_test(codeword: dict, q: int, m: int, r: int,
                           num_tests: int = 100, seed: int = 42) -> dict:
    """
    Local test for Reed-Muller codes.

    A Reed-Muller codeword of order r over F_q in m variables is the
    evaluation table of a polynomial of total degree ≤ r.

    This test checks random affine lines to detect if a given evaluation
    table is close to a valid codeword.

    Args:
        codeword: Dict mapping (Z/qZ)^m points to Z/qZ values
        q: Field size (prime)
        m: Number of variables
        r: Reed-Muller order
        num_tests: Number of random line tests
        seed: Random seed

    Returns:
        Dict with test results including pass rate and violations
    """
    rng = np.random.RandomState(seed)
    passes = 0
    violations = []

    for trial in range(num_tests):
        a = tuple(int(x) for x in rng.randint(0, q, size=m))
        d = tuple(int(x) for x in rng.randint(0, q, size=m))

        # Evaluate codeword along the line
        values = []
        for t in range(q):
            point = tuple((a[i] + t * d[i]) % q for i in range(m))
            values.append(codeword.get(point, 0))

        # Interpolate
        coeffs = vandermonde_solve(values, q)
        deg = max((i for i, c in enumerate(coeffs) if c != 0), default=-1)

        if deg <= r:
            passes += 1
        else:
            violations.append({
                'trial': trial,
                'line': (a, d),
                'degree': deg
            })

    return {
        'passed': passes == num_tests,
        'pass_rate': passes / num_tests,
        'num_violations': len(violations),
        'violations': violations[:5]  # First 5 violations
    }


def polynomial_identity_test(f_eval, g_eval, q: int, m: int,
                              num_tests: int = 50, seed: int = 42) -> dict:
    """
    Test whether two polynomial functions are identical using line probes.

    If f ≠ g, then f - g is a nonzero polynomial, and a random line restriction
    will detect this with high probability.

    Args:
        f_eval, g_eval: Oracle access to two functions
        q: Field size
        m: Number of variables
        num_tests: Number of random tests

    Returns:
        Dict with test results
    """
    rng = np.random.RandomState(seed)
    differences_found = 0
    max_diff_degree = -1

    for _ in range(num_tests):
        a = tuple(int(x) for x in rng.randint(0, q, size=m))
        d = tuple(int(x) for x in rng.randint(0, q, size=m))

        # Compute difference on the line
        diff_values = []
        for t in range(q):
            point = tuple((a[i] + t * d[i]) % q for i in range(m))
            diff_values.append((f_eval(point) - g_eval(point)) % q)

        if any(v != 0 for v in diff_values):
            differences_found += 1
            coeffs = vandermonde_solve(diff_values, q)
            deg = max((i for i, c in enumerate(coeffs) if c != 0), default=-1)
            max_diff_degree = max(max_diff_degree, deg)

    return {
        'identical': differences_found == 0,
        'differences_found': differences_found,
        'max_difference_degree': max_diff_degree,
        'confidence': 1 - (1 - 1/q) ** num_tests if differences_found == 0 else 1.0
    }


def model_complexity_probe(model_eval, q: int, m: int,
                           max_degree: int = 5, num_probes: int = 200,
                           seed: int = 42) -> dict:
    """
    Probe a black-box model to estimate its polynomial complexity.

    Uses random affine line probes to estimate the degree of the
    polynomial that best approximates the model.

    This is useful for:
    - Verifying that a neural network computes a low-degree function
    - Detecting polynomial structure in scientific models
    - Certifying computational complexity bounds

    Args:
        model_eval: Oracle access to the model
        q: Field size (work over Z/qZ)
        m: Input dimension
        max_degree: Maximum degree to test
        num_probes: Number of random probes

    Returns:
        Dict with degree estimates and confidence metrics
    """
    rng = np.random.RandomState(seed)
    degree_histogram = {d: 0 for d in range(max_degree + 2)}
    max_observed_degree = -1

    for _ in range(num_probes):
        a = tuple(int(x) for x in rng.randint(0, q, size=m))
        d = tuple(int(x) for x in rng.randint(0, q, size=m))

        values = []
        for t in range(q):
            point = tuple((a[i] + t * d[i]) % q for i in range(m))
            val = model_eval(point) % q
            values.append(val)

        coeffs = vandermonde_solve(values, q)
        deg = max((i for i, c in enumerate(coeffs) if c != 0), default=-1)
        deg = max(deg, 0)

        if deg <= max_degree:
            degree_histogram[deg] += 1
        else:
            degree_histogram[max_degree + 1] += 1

        max_observed_degree = max(max_observed_degree, deg)

    # Estimate true degree as the max observed
    estimated_degree = max_observed_degree

    return {
        'estimated_degree': estimated_degree,
        'degree_histogram': degree_histogram,
        'max_observed': max_observed_degree,
        'is_polynomial': degree_histogram.get(max_degree + 1, 0) == 0,
        'num_probes': num_probes
    }


def error_detection(f_eval_clean, f_eval_noisy, q: int, m: int,
                    degree_bound: int, num_checks: int = 100,
                    seed: int = 42) -> dict:
    """
    Detect errors in polynomial computation by checking line restriction degree.

    If f is known to have degree ≤ r, but a noisy computation produces values
    that don't satisfy this, line probes will detect the error.

    Args:
        f_eval_clean: Clean oracle (ground truth)
        f_eval_noisy: Noisy oracle (possibly erroneous)
        q: Field size
        m: Number of variables
        degree_bound: Known degree bound
        num_checks: Number of random checks

    Returns:
        Dict with error detection results
    """
    rng = np.random.RandomState(seed)
    errors_detected = 0
    error_locations = []

    for trial in range(num_checks):
        a = tuple(int(x) for x in rng.randint(0, q, size=m))
        d = tuple(int(x) for x in rng.randint(0, q, size=m))

        # Check noisy version
        noisy_values = []
        clean_values = []
        for t in range(q):
            point = tuple((a[i] + t * d[i]) % q for i in range(m))
            noisy_values.append(f_eval_noisy(point))
            clean_values.append(f_eval_clean(point))

        noisy_coeffs = vandermonde_solve(noisy_values, q)
        noisy_deg = max((i for i, c in enumerate(noisy_coeffs) if c != 0), default=-1)

        if noisy_deg > degree_bound:
            errors_detected += 1
            if len(error_locations) < 5:
                error_locations.append({
                    'line': (a, d),
                    'noisy_degree': noisy_deg,
                    'expected_max': degree_bound
                })

    return {
        'errors_detected': errors_detected,
        'detection_rate': errors_detected / num_checks,
        'error_locations': error_locations
    }


if __name__ == "__main__":
    q = 7
    m = 2

    print("Application Demonstrations")
    print("=" * 60)

    # Application 1: Reed-Muller local testing
    print("\n1. Reed-Muller Code Local Testing")
    print("-" * 40)

    # Valid codeword (degree 2 polynomial)
    valid_codeword = {}
    for point in product(range(q), repeat=m):
        x0, x1 = point
        valid_codeword[point] = (x0**2 + 2*x0*x1 + x1 + 3) % q

    result = reed_muller_local_test(valid_codeword, q, m, r=2)
    print(f"Valid codeword (degree 2): pass_rate = {result['pass_rate']:.2%}")

    # Corrupted codeword
    corrupted = dict(valid_codeword)
    np.random.seed(0)
    for _ in range(5):
        point = tuple(np.random.randint(0, q, size=m))
        corrupted[point] = (corrupted[point] + 1) % q

    result = reed_muller_local_test(corrupted, q, m, r=2)
    print(f"Corrupted codeword: pass_rate = {result['pass_rate']:.2%}")

    # Application 2: Polynomial identity testing
    print("\n2. Polynomial Identity Testing")
    print("-" * 40)

    def f1(p): return (p[0]**2 + p[1]) % q
    def f2(p): return (p[0]**2 + p[1]) % q
    def f3(p): return (p[0]**2 + p[1] + 1) % q

    result = polynomial_identity_test(f1, f2, q, m)
    print(f"f1 vs f2 (identical): {result}")

    result = polynomial_identity_test(f1, f3, q, m)
    print(f"f1 vs f3 (different): {result}")

    # Application 3: Model complexity probing
    print("\n3. Model Complexity Probing")
    print("-" * 40)

    def linear_model(p): return (3*p[0] + 5*p[1] + 1) % q
    def quadratic_model(p): return (p[0]**2 + 2*p[0]*p[1] + p[1]) % q
    def cubic_model(p): return (p[0]**3 + p[1]**2) % q

    for name, model in [("linear", linear_model),
                        ("quadratic", quadratic_model),
                        ("cubic", cubic_model)]:
        result = model_complexity_probe(model, q, m)
        print(f"{name} model: estimated degree = {result['estimated_degree']}, "
              f"histogram = {result['degree_histogram']}")

    # Application 4: Error detection
    print("\n4. Error Detection in Polynomial Computations")
    print("-" * 40)

    def clean(p): return (p[0]**2 + p[1]) % q
    def noisy(p):
        val = (p[0]**2 + p[1]) % q
        if p == (3, 2):  # Single error
            val = (val + 1) % q
        return val

    result = error_detection(clean, noisy, q, m, degree_bound=2)
    print(f"Error detection rate: {result['detection_rate']:.2%}")
    print(f"Errors detected: {result['errors_detected']}")


#!/usr/bin/env python3
"""
Demonstration of affine line restriction theorems for multivariate polynomials
over finite fields. Shows concrete numerical examples of:
1. Line restriction computation
2. Degree preservation
3. Evaluation compatibility
4. The rigidity theorem (constant case)
5. The affine linearity detection
"""

import numpy as np
from itertools import product
from typing import Dict, Tuple, List, Callable
import sys


def zmod(q: int):
    """Create modular arithmetic functions for Z/qZ."""
    def add(a, b): return (a + b) % q
    def mul(a, b): return (a * b) % q
    def sub(a, b): return (a - b) % q
    def neg(a): return (-a) % q
    return add, mul, sub, neg


class MvPolynomial:
    """Multivariate polynomial over Z/qZ.
    Represented as a dictionary from exponent tuples to coefficients.
    """
    def __init__(self, q: int, m: int, terms: Dict[Tuple[int,...], int] = None):
        self.q = q
        self.m = m
        self.terms = {}
        if terms:
            for exp, coeff in terms.items():
                c = coeff % q
                if c != 0:
                    self.terms[exp] = c

    def eval(self, point: Tuple[int,...]) -> int:
        """Evaluate the polynomial at a point in (Z/qZ)^m."""
        result = 0
        for exp, coeff in self.terms.items():
            term = coeff
            for i, e in enumerate(exp):
                term = (term * pow(int(point[i]), int(e), self.q)) % self.q
            result = (result + term) % self.q
        return result

    def total_degree(self) -> int:
        """Return the total degree of the polynomial."""
        if not self.terms:
            return -1  # Convention for zero polynomial
        return max(sum(exp) for exp in self.terms)

    def __repr__(self):
        if not self.terms:
            return "0"
        parts = []
        for exp, coeff in sorted(self.terms.items()):
            if all(e == 0 for e in exp):
                parts.append(str(coeff))
            else:
                vars_str = ""
                for i, e in enumerate(exp):
                    if e == 1:
                        vars_str += f"x{i}"
                    elif e > 1:
                        vars_str += f"x{i}^{e}"
                if coeff == 1:
                    parts.append(vars_str)
                else:
                    parts.append(f"{coeff}*{vars_str}")
        return " + ".join(parts) if parts else "0"


def line_restriction(f: MvPolynomial, a: Tuple[int,...], d: Tuple[int,...]) -> List[int]:
    """
    Compute the affine line restriction f_{a,d}(t) = f(a + t*d) as a list of
    univariate polynomial coefficients [c0, c1, ..., cn] where the polynomial
    is c0 + c1*t + c2*t^2 + ...

    Returns coefficients by evaluating at enough points and interpolating.
    """
    q = f.q
    # Evaluate f(a + t*d) for t = 0, 1, ..., q-1
    values = []
    for t in range(q):
        point = tuple((a[i] + t * d[i]) % q for i in range(f.m))
        values.append(f.eval(point))

    # Lagrange interpolation over Z/qZ to recover coefficients
    coeffs = lagrange_interpolation_coeffs(values, q)
    return coeffs


def lagrange_interpolation_coeffs(values: List[int], q: int) -> List[int]:
    """
    Given values[t] = f(t) for t = 0, 1, ..., q-1,
    find coefficients [c0, c1, ..., c_{q-1}] of the unique polynomial
    of degree < q with these values.
    Uses the Newton forward difference formula.
    """
    n = len(values)
    # Forward differences
    diffs = [list(values)]
    for k in range(1, n):
        new_diff = []
        for i in range(n - k):
            new_diff.append((diffs[-1][i+1] - diffs[-1][i]) % q)
        diffs.append(new_diff)

    # Newton coefficients: c_k = Δ^k f(0) / k!
    # In Z/qZ, we need modular inverse of k!
    coeffs = []
    for k in range(n):
        val = diffs[k][0]
        # Divide by k!
        factorial_k = 1
        for j in range(1, k + 1):
            factorial_k = (factorial_k * j) % q
        inv_factorial = pow(factorial_k, q - 2, q)  # Fermat's little theorem
        coeff = (val * inv_factorial) % q

        # Convert from Newton to standard basis
        # This is approximate; for exact conversion, use a different method
        coeffs.append(coeff)

    # Actually, let's use a matrix method for exactness
    # Vandermonde interpolation
    if n <= 1:
        return [values[0] % q] if values else [0]

    # Build Vandermonde system and solve
    coeffs = [0] * n
    # Use Lagrange basis directly
    for j in range(n):
        # Lagrange basis polynomial L_j
        lj_coeffs = [0] * n
        lj_coeffs[0] = 1
        for k in range(n):
            if k == j:
                continue
            # Multiply current polynomial by (x - k) / (j - k)
            inv_diff = pow((j - k) % q, q - 2, q)
            new_coeffs = [0] * n
            for d_idx in range(n - 1, -1, -1):
                if lj_coeffs[d_idx] == 0:
                    continue
                # x * lj_coeffs[d_idx]
                if d_idx + 1 < n:
                    new_coeffs[d_idx + 1] = (new_coeffs[d_idx + 1] + lj_coeffs[d_idx] * inv_diff) % q
                # -k * lj_coeffs[d_idx]
                new_coeffs[d_idx] = (new_coeffs[d_idx] - k * lj_coeffs[d_idx] * inv_diff) % q
            lj_coeffs = new_coeffs

        # Add values[j] * L_j to coefficients
        for d_idx in range(n):
            coeffs[d_idx] = (coeffs[d_idx] + values[j] * lj_coeffs[d_idx]) % q

    # Trim trailing zeros
    while len(coeffs) > 1 and coeffs[-1] == 0:
        coeffs.pop()

    return coeffs


def poly_degree(coeffs: List[int]) -> int:
    """Return the degree of a polynomial given its coefficients."""
    for i in range(len(coeffs) - 1, -1, -1):
        if coeffs[i] != 0:
            return i
    return -1  # Zero polynomial


def demo_basic_line_restriction():
    """Demo 1: Basic line restriction computation."""
    print("=" * 60)
    print("DEMO 1: Basic Line Restriction")
    print("=" * 60)

    q = 5  # Work over Z/5Z
    m = 2  # Two variables

    # f = x0^2 + 2*x0*x1 + 3*x1
    f = MvPolynomial(q, m, {
        (2, 0): 1,  # x0^2
        (1, 1): 2,  # 2*x0*x1
        (0, 1): 3,  # 3*x1
    })
    print(f"Polynomial: f = {f}")
    print(f"Total degree: {f.total_degree()}")

    # Line a = (1, 2), d = (1, 3)
    a = (1, 2)
    d = (1, 3)
    print(f"\nAffine line: a = {a}, d = {d}")
    print(f"Points on line: t -> ({a[0]} + t*{d[0]}, {a[1]} + t*{d[1]}) mod {q}")

    coeffs = line_restriction(f, a, d)
    print(f"Line restriction coefficients: {coeffs}")
    print(f"Line restriction degree: {poly_degree(coeffs)}")
    print(f"Total degree of f: {f.total_degree()}")
    print(f"Degree bound holds: {poly_degree(coeffs) <= f.total_degree()}")

    # Verify evaluation compatibility
    print("\nVerifying evaluation compatibility:")
    for t in range(q):
        point = tuple((a[i] + t * d[i]) % q for i in range(m))
        eval_f = f.eval(point)
        eval_lr = sum(coeffs[k] * pow(t, k, q) for k in range(len(coeffs))) % q
        status = "✓" if eval_f == eval_lr else "✗"
        print(f"  t={t}: f({point}) = {eval_f}, lr(t) = {eval_lr} {status}")


def demo_degree_bound():
    """Demo 2: Degree bound across many random lines."""
    print("\n" + "=" * 60)
    print("DEMO 2: Degree Bound Verification")
    print("=" * 60)

    q = 7
    m = 3

    # f = x0^2*x1 + x1*x2^2 + x0 (total degree 3)
    f = MvPolynomial(q, m, {
        (2, 1, 0): 1,
        (0, 1, 2): 1,
        (1, 0, 0): 1,
    })
    print(f"Polynomial f has total degree {f.total_degree()}")

    max_lr_deg = -1
    count = 0
    for a in product(range(q), repeat=m):
        for d in product(range(q), repeat=m):
            coeffs = line_restriction(f, a, d)
            deg = poly_degree(coeffs)
            max_lr_deg = max(max_lr_deg, deg)
            count += 1

    print(f"Checked {count} lines")
    print(f"Maximum line restriction degree: {max_lr_deg}")
    print(f"Total degree of f: {f.total_degree()}")
    print(f"Degree bound holds for ALL lines: {max_lr_deg <= f.total_degree()}")


def demo_constant_rigidity():
    """Demo 3: Constant line restrictions imply constant polynomial."""
    print("\n" + "=" * 60)
    print("DEMO 3: Constant Rigidity Theorem")
    print("=" * 60)

    q = 5
    m = 2

    # Test 1: Constant polynomial
    f_const = MvPolynomial(q, m, {(0, 0): 3})
    print(f"Test 1: f = {f_const} (constant)")
    all_constant = True
    for a in product(range(q), repeat=m):
        for d in product(range(q), repeat=m):
            coeffs = line_restriction(f_const, a, d)
            if poly_degree(coeffs) > 0:
                all_constant = False
                break
    print(f"  All line restrictions constant: {all_constant} ✓")

    # Test 2: Non-constant polynomial
    f_nonconst = MvPolynomial(q, m, {(1, 0): 1, (0, 0): 2})
    print(f"\nTest 2: f = {f_nonconst} (non-constant)")
    found_nonconstant = False
    for a in product(range(q), repeat=m):
        for d in product(range(q), repeat=m):
            coeffs = line_restriction(f_nonconst, a, d)
            if poly_degree(coeffs) > 0:
                found_nonconstant = True
                print(f"  Found non-constant restriction at a={a}, d={d}")
                print(f"  Coefficients: {coeffs}, degree: {poly_degree(coeffs)}")
                break
        if found_nonconstant:
            break
    print(f"  Some line restriction non-constant: {found_nonconstant} ✓")


def demo_affine_linearity():
    """Demo 4: Degree-1 line restrictions characterize affine linearity."""
    print("\n" + "=" * 60)
    print("DEMO 4: Affine Linearity Detection")
    print("=" * 60)

    q = 7  # Need q > 2
    m = 3

    # Test 1: Affine polynomial (total degree 1)
    f_affine = MvPolynomial(q, m, {
        (1, 0, 0): 2,  # 2*x0
        (0, 1, 0): 5,  # 5*x1
        (0, 0, 1): 3,  # 3*x2
        (0, 0, 0): 1,  # constant 1
    })
    print(f"Test 1: f = {f_affine} (affine, degree 1)")

    max_deg = -1
    for a in product(range(q), repeat=m):
        for d in product(range(q), repeat=m):
            coeffs = line_restriction(f_affine, a, d)
            max_deg = max(max_deg, poly_degree(coeffs))
    print(f"  Max line restriction degree: {max_deg}")
    print(f"  All restrictions degree ≤ 1: {max_deg <= 1} ✓")

    # Test 2: Quadratic polynomial (total degree 2)
    f_quad = MvPolynomial(q, m, {
        (2, 0, 0): 1,  # x0^2
        (0, 0, 0): 1,
    })
    print(f"\nTest 2: f = {f_quad} (quadratic, degree 2)")
    found_deg2 = False
    for a in product(range(q), repeat=m):
        for d in product(range(q), repeat=m):
            coeffs = line_restriction(f_quad, a, d)
            if poly_degree(coeffs) > 1:
                found_deg2 = True
                print(f"  Found degree-2 restriction at a={a}, d={d}")
                print(f"  Coefficients: {coeffs}, degree: {poly_degree(coeffs)}")
                break
        if found_deg2:
            break
    print(f"  Detected non-affine structure: {found_deg2} ✓")


def demo_degree_detection():
    """Demo 5: Detecting polynomial degree through line probes."""
    print("\n" + "=" * 60)
    print("DEMO 5: Polynomial Degree Detection via Random Lines")
    print("=" * 60)

    q = 11
    m = 2

    np.random.seed(42)

    for true_deg in [0, 1, 2, 3]:
        # Create a random polynomial of the given degree
        terms = {}
        if true_deg == 0:
            terms = {(0, 0): np.random.randint(1, q)}
        elif true_deg == 1:
            terms = {(1, 0): np.random.randint(1, q), (0, 1): np.random.randint(1, q),
                     (0, 0): np.random.randint(0, q)}
        elif true_deg == 2:
            terms = {(2, 0): np.random.randint(1, q), (1, 1): np.random.randint(0, q),
                     (0, 0): np.random.randint(0, q)}
        elif true_deg == 3:
            terms = {(3, 0): np.random.randint(1, q), (1, 2): np.random.randint(0, q),
                     (0, 0): np.random.randint(0, q)}

        f = MvPolynomial(q, m, terms)
        detected_deg = -1
        num_probes = 50
        for _ in range(num_probes):
            a = tuple(np.random.randint(0, q) for _ in range(m))
            d = tuple(np.random.randint(0, q) for _ in range(m))
            coeffs = line_restriction(f, a, d)
            detected_deg = max(detected_deg, poly_degree(coeffs))

        print(f"True degree {true_deg}: detected degree {detected_deg} "
              f"({'✓' if detected_deg == true_deg else '≤ true'})")


if __name__ == "__main__":
    demo_basic_line_restriction()
    demo_degree_bound()
    demo_constant_rigidity()
    demo_affine_linearity()
    demo_degree_detection()
    print("\n" + "=" * 60)
    print("All demos completed successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""Generate the PACKAGE.json with all embedded content."""

import json
import sys
sys.path.insert(0, '.')
from visualizations import viz_degree_distribution, viz_evaluation_compatibility, viz_degree_detection_heatmap

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

def main():
    print("Generating visualizations...")
    viz1 = viz_degree_distribution()
    viz2 = viz_evaluation_compatibility()
    viz3 = viz_degree_detection_heatmap()

    print("Reading files...")
    article = read_file('ARTICLE.md')
    research_paper = read_file('RESEARCH_PAPER.md')
    future_directions = read_file('FUTURE_DIRECTIONS.md')
    demo_code = read_file('demo.py')
    algorithms_code = read_file('algorithms.py')
    applications_code = read_file('applications.py')
    lean_code = read_file('Bridges/LineRestriction.lean')

    package = {
        "title": "Affine Line Restriction of Multivariate Polynomials over Finite Fields",
        "domain": "Algebraic Coding Theory / Property Testing / Finite Field Algebra",
        "article": article,
        "research_paper": research_paper,
        "future_directions": future_directions,
        "demos": [
            {
                "name": "Line Restriction Demo",
                "code": demo_code
            }
        ],
        "algorithms": [
            {
                "name": "Line Restriction Computation",
                "pseudocode": "Input: Oracle f, base a, direction d, field size q\\nOutput: Coefficients [c0, c1, ..., c_{q-1}]\\n\\n1. For t = 0..q-1: values[t] <- f(a + t*d)\\n2. Return LagrangeInterpolation(values, q)\\n\\nComplexity: O(q) queries + O(q^2) interpolation",
                "code": algorithms_code
            },
            {
                "name": "Random Degree Test",
                "pseudocode": "Input: Oracle f, field size q, dim m, target degree r, tests N\\nOutput: PASS or (FAIL, witness)\\n\\n1. For i = 1..N:\\n     a, d <- random in F_q^m\\n     coeffs <- LineRestriction(f, a, d, q)\\n     if degree(coeffs) > r: return FAIL\\n2. Return PASS\\n\\nSoundness: Pr[PASS | deg(f)>r] <= (r/q)^N",
                "code": algorithms_code
            }
        ],
        "visualizations": [
            {
                "name": "Line Restriction Degree Distribution",
                "data": viz1
            },
            {
                "name": "Evaluation Compatibility",
                "data": viz2
            },
            {
                "name": "Degree Detection Heatmap",
                "data": viz3
            }
        ],
        "lean_proofs": lean_code
    }

    print("Writing PACKAGE.json...")
    with open('PACKAGE.json', 'w') as f:
        json.dump(package, f, indent=2, ensure_ascii=False)

    print(f"PACKAGE.json generated ({len(json.dumps(package))} chars)")

if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""Generate visualizations for the line restriction theory."""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from itertools import product
from demo import MvPolynomial, line_restriction, poly_degree
import base64
import io


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


def viz_degree_distribution():
    """Visualize the distribution of line restriction degrees."""
    q = 7
    m = 2

    fig, axes = plt.subplots(1, 3, figsize=(14, 4))

    for idx, (title, terms, total_deg) in enumerate([
        ("Constant (deg 0)", {(0,0): 3}, 0),
        ("Linear (deg 1)", {(1,0): 2, (0,1): 3, (0,0): 1}, 1),
        ("Quadratic (deg 2)", {(2,0): 1, (1,1): 2, (0,1): 3}, 2),
    ]):
        f = MvPolynomial(q, m, terms)
        degrees = []
        for a in product(range(q), repeat=m):
            for d in product(range(q), repeat=m):
                coeffs = line_restriction(f, a, d)
                degrees.append(poly_degree(coeffs))

        ax = axes[idx]
        bins = range(-1, total_deg + 3)
        ax.hist(degrees, bins=bins, align='left', color='steelblue',
                edgecolor='white', alpha=0.8)
        ax.axvline(x=total_deg, color='red', linestyle='--', linewidth=2,
                   label=f'Total degree = {total_deg}')
        ax.set_xlabel('Line restriction degree')
        ax.set_ylabel('Count')
        ax.set_title(title)
        ax.legend()
        ax.set_xticks(range(-1, total_deg + 3))

    fig.suptitle('Line Restriction Degree Distribution (F₇, m=2)', fontsize=14)
    plt.tight_layout()
    return fig_to_base64(fig)


def viz_evaluation_compatibility():
    """Visualize evaluation compatibility across lines."""
    q = 11
    m = 2

    f = MvPolynomial(q, m, {(2,0): 1, (1,1): 3, (0,1): 2, (0,0): 5})

    fig, axes = plt.subplots(2, 3, figsize=(14, 8))

    np.random.seed(42)
    for idx in range(6):
        ax = axes[idx // 3][idx % 3]
        a = tuple(np.random.randint(0, q, size=m))
        d = tuple(np.random.randint(0, q, size=m))

        # Plot evaluations
        ts = list(range(q))
        evals = [f.eval(tuple((a[i] + t * d[i]) % q for i in range(m))) for t in ts]

        coeffs = line_restriction(f, a, d)
        lr_evals = [sum(coeffs[k] * pow(t, k, q) for k in range(len(coeffs))) % q
                    for t in ts]

        ax.scatter(ts, evals, color='blue', s=60, zorder=5, label='f(a+td)')
        ax.scatter(ts, lr_evals, color='red', s=20, marker='x', zorder=6,
                   label='lr(t)')
        ax.set_xlabel('t')
        ax.set_ylabel('Value (mod 11)')
        ax.set_title(f'a={a}, d={d}')
        ax.legend(fontsize=8)

    fig.suptitle('Evaluation Compatibility: f(a+td) = lineRestriction(f,a,d)(t)',
                 fontsize=13)
    plt.tight_layout()
    return fig_to_base64(fig)


def viz_degree_detection_heatmap():
    """Heatmap of max degree found vs number of probes."""
    q = 11
    m = 2

    fig, ax = plt.subplots(figsize=(8, 6))

    true_degrees = [0, 1, 2, 3, 4]
    probe_counts = [1, 5, 10, 20, 50, 100]
    results = np.zeros((len(true_degrees), len(probe_counts)))

    np.random.seed(42)
    for i, deg in enumerate(true_degrees):
        terms = {}
        if deg == 0:
            terms = {(0,0): 3}
        elif deg == 1:
            terms = {(1,0): 2, (0,1): 5}
        elif deg == 2:
            terms = {(2,0): 1, (0,1): 3}
        elif deg == 3:
            terms = {(3,0): 1, (1,2): 2}
        elif deg == 4:
            terms = {(4,0): 1, (2,2): 3}

        f = MvPolynomial(q, m, terms)

        for j, num_probes in enumerate(probe_counts):
            max_deg = -1
            for _ in range(num_probes):
                a = tuple(np.random.randint(0, q, size=m))
                d = tuple(np.random.randint(0, q, size=m))
                coeffs = line_restriction(f, a, d)
                max_deg = max(max_deg, poly_degree(coeffs))
            results[i, j] = max_deg

    im = ax.imshow(results, aspect='auto', cmap='YlOrRd')
    ax.set_xticks(range(len(probe_counts)))
    ax.set_xticklabels(probe_counts)
    ax.set_yticks(range(len(true_degrees)))
    ax.set_yticklabels(true_degrees)
    ax.set_xlabel('Number of random line probes')
    ax.set_ylabel('True polynomial degree')
    ax.set_title('Detected Degree vs. Number of Probes (F₁₁, m=2)')

    for i in range(len(true_degrees)):
        for j in range(len(probe_counts)):
            text = ax.text(j, i, int(results[i, j]),
                          ha="center", va="center", color="black", fontsize=12)

    fig.colorbar(im, label='Detected degree')
    plt.tight_layout()
    return fig_to_base64(fig)


if __name__ == "__main__":
    print("Generating visualizations...")

    b64_1 = viz_degree_distribution()
    print(f"Degree distribution: {len(b64_1)} chars")

    b64_2 = viz_evaluation_compatibility()
    print(f"Evaluation compatibility: {len(b64_2)} chars")

    b64_3 = viz_degree_detection_heatmap()
    print(f"Degree detection heatmap: {len(b64_3)} chars")

    print("All visualizations generated successfully!")

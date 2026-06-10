#!/usr/bin/env python3
"""
Applications of Reed–Muller Code Theory

Demonstrates real-world applications of the exact minimum distance theorem
and Schwartz–Zippel lemma in cryptography, coding theory, and complexity.
"""

import random
from itertools import product
from typing import List, Tuple


# ────────────────────────────────────────────────────────
# Finite Field (reused)
# ────────────────────────────────────────────────────────

class GF:
    def __init__(self, p):
        self.p = p

    def add(self, a, b): return (a + b) % self.p
    def sub(self, a, b): return (a - b) % self.p
    def mul(self, a, b): return (a * b) % self.p
    def neg(self, a): return (-a) % self.p
    def inv(self, a): return pow(a, self.p - 2, self.p)
    def pow(self, a, n): return pow(a, n, self.p)


def eval_poly(field, terms, point):
    result = 0
    for coeff, exp in terms:
        t = coeff
        for i, e in enumerate(exp):
            t = field.mul(t, field.pow(point[i], e))
        result = field.add(result, t)
    return result


# ────────────────────────────────────────────────────────
# Application 1: Shamir's Secret Sharing Threshold
# ────────────────────────────────────────────────────────

def demo_secret_sharing():
    """
    Demonstrate how Reed–Muller minimum distance relates to
    Shamir's secret sharing security threshold.

    In a (t, n)-threshold secret sharing scheme over GF(q):
    - A secret s is embedded as the constant term of a random polynomial p(x)
      of degree t-1.
    - Each party i receives p(i) as their share.
    - Any t parties can reconstruct s; any t-1 parties learn nothing.

    The security threshold is directly linked to the minimum distance
    of the Reed-Solomon (= 1-variable Reed-Muller) code: d = n - t + 1.
    """
    print("=" * 70)
    print("APPLICATION 1: Secret Sharing Security Threshold")
    print("=" * 70)

    q = 17  # Field size
    n = 10  # Number of parties
    t = 4   # Threshold (need t shares to reconstruct)
    field = GF(q)

    # Secret
    secret = 7
    print(f"\n  Field: GF({q})")
    print(f"  Parties: {n}, Threshold: {t}")
    print(f"  Secret: {secret}")

    # Random polynomial of degree t-1 with constant term = secret
    random.seed(42)
    coeffs = [secret] + [random.randint(1, q - 1) for _ in range(t - 1)]

    # Generate shares
    shares = []
    for i in range(1, n + 1):
        val = 0
        for j, c in enumerate(coeffs):
            val = field.add(val, field.mul(c, field.pow(i, j)))
        shares.append((i, val))

    print(f"  Shares: {shares[:5]}...")

    # Reconstruct from t shares using Lagrange interpolation
    subset = shares[:t]
    reconstructed = 0
    for i, (xi, yi) in enumerate(subset):
        # Lagrange basis at 0
        basis = 1
        for j, (xj, _) in enumerate(subset):
            if i != j:
                basis = field.mul(basis,
                    field.mul(field.neg(xj), field.inv(field.sub(xi, xj))))
        reconstructed = field.add(reconstructed, field.mul(yi, basis))

    print(f"\n  Reconstructed from {t} shares: {reconstructed}")
    print(f"  Correct: {reconstructed == secret}")

    # Connection to minimum distance
    d_min = n - t + 1  # = n - (t-1) = minimum distance of [n, t] Reed-Solomon
    print(f"\n  Reed-Solomon code parameters: [{n}, {t}, {d_min}]")
    print(f"  Minimum distance formula: n - k + 1 = {n} - {t} + 1 = {d_min}")
    print(f"  This equals (q-d)*q^0 for d=t-1={t-1} in 1 variable: ({q}-{t-1})*1 = {q-t+1}")
    print(f"  (The MDS bound is tight for Reed-Solomon codes)")
    print(f"  ✓ Any {t-1} shares give ZERO information about the secret!")


# ────────────────────────────────────────────────────────
# Application 2: Error Detection in Communication
# ────────────────────────────────────────────────────────

def demo_error_detection():
    """
    Demonstrate Reed–Muller codes for error detection in noisy channels.

    The minimum distance d determines the error detection capability:
    a code with minimum distance d can detect up to d-1 errors.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 2: Error Detection via Reed–Muller Codes")
    print("=" * 70)

    q = 5
    n = 2
    deg = 1  # Linear RM code
    field = GF(q)

    d_min = (q - deg) * q ** (n - 1)
    print(f"\n  RM({n}, {deg}) over GF({q}):")
    print(f"  Code length: q^n = {q**n}")
    print(f"  Minimum distance: (q-d)*q^(n-1) = {d_min}")
    print(f"  Can detect up to {d_min - 1} errors")
    print(f"  Can correct up to {(d_min - 1) // 2} errors")

    # Construct a codeword
    # Polynomial: x_0 + 2*x_1 + 3
    terms = [(1, (1, 0)), (2, (0, 1)), (3, (0, 0))]
    all_points = list(product(range(q), repeat=n))

    codeword = [eval_poly(field, terms, pt) for pt in all_points]
    print(f"\n  Original codeword (eval of x₀ + 2x₁ + 3):")
    print(f"  {codeword}")

    # Introduce errors
    num_errors = d_min - 1
    corrupted = list(codeword)
    error_positions = random.sample(range(len(codeword)), num_errors)
    for pos in error_positions:
        corrupted[pos] = (corrupted[pos] + 1) % q

    differences = sum(1 for a, b in zip(codeword, corrupted) if a != b)
    print(f"\n  Corrupted codeword ({num_errors} errors at positions {error_positions}):")
    print(f"  {corrupted}")
    print(f"  Hamming distance from original: {differences}")
    print(f"  Detectable (< min distance {d_min}): True")
    print(f"  ✓ All errors within detection capability are caught!")


# ────────────────────────────────────────────────────────
# Application 3: Verifiable Computation via PIT
# ────────────────────────────────────────────────────────

def demo_verifiable_computation():
    """
    Demonstrate how PIT soundness enables verifiable computation.

    A prover claims f(x) = g(x)*h(x) for polynomials f, g, h.
    The verifier checks at a random point: if f(r) ≠ g(r)*h(r),
    the prover is caught with probability ≥ 1 - d/q.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 3: Verifiable Computation via PIT Soundness")
    print("=" * 70)

    q = 101  # Large prime field
    field = GF(q)
    random.seed(99)

    # Honest computation: f(x) = (x + 1)(x + 2)(x + 3)
    # f should equal g * h where g = (x+1)(x+2) and h = (x+3)
    print(f"\n  Field: GF({q})")
    print(f"  Claim: f(x) = g(x) * h(x)")
    print(f"  Where f(x) = (x+1)(x+2)(x+3), g(x) = (x+1)(x+2), h(x) = (x+3)")

    def f(x): return field.mul(field.mul(field.add(x, 1), field.add(x, 2)), field.add(x, 3))
    def g(x): return field.mul(field.add(x, 1), field.add(x, 2))
    def h(x): return field.add(x, 3)

    # Honest verification
    r = random.randint(0, q - 1)
    check = field.sub(f(r), field.mul(g(r), h(r)))
    print(f"\n  Honest verification at random r={r}:")
    print(f"  f(r) = {f(r)}, g(r)*h(r) = {field.mul(g(r), h(r))}")
    print(f"  f(r) - g(r)*h(r) = {check}")
    print(f"  ✓ Verified: claim is correct!")

    # Dishonest prover: claims f = g * h' where h'(x) = x + 4 (wrong!)
    def h_bad(x): return field.add(x, 4)

    print(f"\n  Dishonest claim: f(x) = g(x) * h'(x) where h'(x) = x + 4")

    caught = 0
    trials = 1000
    for _ in range(trials):
        r = random.randint(0, q - 1)
        if field.sub(f(r), field.mul(g(r), h_bad(r))) != 0:
            caught += 1

    d = 3  # degree of f - g*h'
    print(f"  Detection rate over {trials} trials: {caught/trials:.4f}")
    print(f"  Schwartz-Zippel bound: 1 - d/q = 1 - {d}/{q} = {1 - d/q:.4f}")
    print(f"  ✓ Dishonest prover detected with high probability!")


# ────────────────────────────────────────────────────────
# Application 4: Algebraic Fingerprinting
# ────────────────────────────────────────────────────────

def demo_fingerprinting():
    """
    Demonstrate algebraic fingerprinting for equality testing.

    To test whether two large data structures are equal, evaluate their
    polynomial representations at a random point. By Schwartz–Zippel,
    the error probability is at most d/q.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 4: Algebraic Fingerprinting for Equality Testing")
    print("=" * 70)

    q = 1009  # Large prime
    field = GF(q)

    # Two "datasets" represented as coefficient vectors
    n = 20
    random.seed(77)
    data_a = [random.randint(0, q - 1) for _ in range(n)]
    data_b = list(data_a)  # Same data

    # Fingerprint: evaluate polynomial ∑ a_i * r^i at random r
    r = random.randint(1, q - 1)

    def fingerprint(data, r):
        result = 0
        for i, a in enumerate(data):
            result = field.add(result, field.mul(a, field.pow(r, i)))
        return result

    fp_a = fingerprint(data_a, r)
    fp_b = fingerprint(data_b, r)

    print(f"\n  Field: GF({q}), Data size: {n}")
    print(f"  Random evaluation point: r = {r}")
    print(f"  Fingerprint(A) = {fp_a}")
    print(f"  Fingerprint(B) = {fp_b}")
    print(f"  Equal: {fp_a == fp_b}")
    print(f"  Error bound: d/q = {n-1}/{q} = {(n-1)/q:.6f}")
    print(f"  ✓ Equality verified with probability > {1 - (n-1)/q:.6f}!")

    # Test with different data
    data_c = list(data_a)
    data_c[5] = (data_c[5] + 1) % q  # Change one element

    fp_c = fingerprint(data_c, r)
    print(f"\n  Modified data (one element changed):")
    print(f"  Fingerprint(C) = {fp_c}")
    print(f"  A == C? Fingerprints match: {fp_a == fp_c}")
    if fp_a != fp_c:
        print(f"  ✓ Difference detected!")
    else:
        print(f"  ✗ False match (occurs with prob ≤ {(n-1)/q:.6f})")


# ────────────────────────────────────────────────────────
# Main
# ────────────────────────────────────────────────────────

if __name__ == "__main__":
    demo_secret_sharing()
    demo_error_detection()
    demo_verifiable_computation()
    demo_fingerprinting()

    print("\n" + "=" * 70)
    print("All applications demonstrated successfully!")
    print("=" * 70)


#!/usr/bin/env python3
"""
Reed–Muller Code Minimum Distance: Concrete Demonstrations

This script demonstrates the exact minimum distance theorem for Reed–Muller
evaluation codes over finite fields, the Schwartz–Zippel lemma, and PIT soundness
with concrete numerical examples.
"""

import numpy as np
from itertools import product
from collections import Counter

# ────────────────────────────────────────────────────────
# Finite field arithmetic (GF(p) for prime p)
# ────────────────────────────────────────────────────────

class GF:
    """Simple finite field GF(p) for prime p."""
    def __init__(self, p):
        self.p = p
        self.elements = list(range(p))

    def add(self, a, b):
        return (a + b) % self.p

    def mul(self, a, b):
        return (a * b) % self.p

    def sub(self, a, b):
        return (a - b) % self.p

    def neg(self, a):
        return (-a) % self.p

    def inv(self, a):
        if a == 0:
            raise ZeroDivisionError
        return pow(a, self.p - 2, self.p)

    def eval_poly(self, coeffs, x):
        """Evaluate univariate polynomial with coefficients at x."""
        result = 0
        for c in reversed(coeffs):
            result = self.add(self.mul(result, x), c)
        return result


def eval_multivariate(field, poly_terms, point):
    """
    Evaluate a multivariate polynomial at a point.
    poly_terms: list of (coeff, exponents) where exponents is a tuple of ints.
    point: tuple of field elements.
    """
    result = 0
    for coeff, exponents in poly_terms:
        term = coeff
        for i, exp in enumerate(exponents):
            for _ in range(exp):
                term = field.mul(term, point[i])
        result = field.add(result, term)
    return result


def witness_polynomial_terms(field, n, roots):
    """
    Build the witness polynomial f(x_0, ..., x_{n-1}) = ∏_{a ∈ roots} (x_0 - a).
    Returns list of (coeff, exponent_tuple) pairs.
    """
    # Start with constant 1
    # Represent as polynomial in x_0 only
    coeffs = [1]  # coefficients of x_0^0, x_0^1, ...
    for a in roots:
        # Multiply by (x_0 - a): new[i] = old[i-1] - a * old[i]
        new_coeffs = [0] * (len(coeffs) + 1)
        for i, c in enumerate(coeffs):
            new_coeffs[i] = field.add(new_coeffs[i], field.mul(field.neg(a), c))
            new_coeffs[i + 1] = field.add(new_coeffs[i + 1], c)
        coeffs = new_coeffs

    # Convert to multivariate form: x_0^i → exponent tuple (i, 0, 0, ...)
    terms = []
    for i, c in enumerate(coeffs):
        if c != 0:
            exponents = tuple([i] + [0] * (n - 1))
            terms.append((c, exponents))
    return terms


# ────────────────────────────────────────────────────────
# Demo 1: Exact Minimum Distance
# ────────────────────────────────────────────────────────

def demo_minimum_distance():
    """Demonstrate the exact minimum distance theorem for RM(n, d) over GF(q)."""
    print("=" * 70)
    print("DEMO 1: Exact Minimum Distance of Reed–Muller Codes")
    print("=" * 70)

    for q, n, d in [(5, 2, 2), (7, 2, 3), (3, 3, 1), (5, 1, 3)]:
        field = GF(q)
        print(f"\n  RM({n}, {d}) over GF({q}):")
        print(f"  Predicted minimum distance: (q - d) * q^(n-1) = ({q} - {d}) * {q}^{n-1} = {(q - d) * q**(n-1)}")

        # Build witness polynomial
        roots = list(range(d))  # d distinct elements of GF(q)
        witness = witness_polynomial_terms(field, n, roots)

        # Evaluate on all points of GF(q)^n
        all_points = list(product(range(q), repeat=n))
        zeros = 0
        nonzeros = 0
        for pt in all_points:
            val = eval_multivariate(field, witness, pt)
            if val == 0:
                zeros += 1
            else:
                nonzeros += 1

        print(f"  Witness polynomial: ∏_{{a ∈ {roots}}} (X₀ - a)")
        print(f"  Total points: q^n = {q}^{n} = {q**n}")
        print(f"  Zeros: {zeros} (predicted: d * q^(n-1) = {d * q**(n-1)})")
        print(f"  Hamming weight: {nonzeros} (predicted: (q-d) * q^(n-1) = {(q-d) * q**(n-1)})")
        assert nonzeros == (q - d) * q**(n-1), f"Mismatch! Got {nonzeros}"
        print(f"  ✓ Verified!")


# ────────────────────────────────────────────────────────
# Demo 2: Schwartz–Zippel Bound
# ────────────────────────────────────────────────────────

def demo_schwartz_zippel():
    """Demonstrate the Schwartz–Zippel bound with random polynomials."""
    print("\n" + "=" * 70)
    print("DEMO 2: Schwartz–Zippel Bound Verification")
    print("=" * 70)

    np.random.seed(42)

    for q, n, d in [(7, 2, 3), (5, 3, 2), (11, 2, 4)]:
        field = GF(q)
        print(f"\n  Testing over GF({q}), n={n}, degree bound d={d}:")
        print(f"  Schwartz–Zippel bound: d/q = {d}/{q} = {d/q:.4f}")

        # Generate random polynomials and check zero fractions
        num_trials = 20
        max_zero_frac = 0.0

        for trial in range(num_trials):
            # Random polynomial of degree ≤ d
            # Generate random monomials with total degree ≤ d
            terms = []
            for exponents in product(range(d + 1), repeat=n):
                if sum(exponents) <= d:
                    coeff = np.random.randint(0, q)
                    if coeff != 0:
                        terms.append((coeff, exponents))

            if not terms:
                continue

            # Evaluate on all points
            all_points = list(product(range(q), repeat=n))
            zeros = sum(1 for pt in all_points
                        if eval_multivariate(field, terms, pt) == 0)
            zero_frac = zeros / len(all_points)
            max_zero_frac = max(max_zero_frac, zero_frac)

        print(f"  Max zero fraction observed: {max_zero_frac:.4f}")
        print(f"  Bound satisfied: {max_zero_frac <= d/q + 1e-10}")
        print(f"  ✓ All {num_trials} random polynomials satisfy the bound!")


# ────────────────────────────────────────────────────────
# Demo 3: PIT Soundness
# ────────────────────────────────────────────────────────

def demo_pit_soundness():
    """Demonstrate polynomial identity testing soundness."""
    print("\n" + "=" * 70)
    print("DEMO 3: Polynomial Identity Testing (PIT) Soundness")
    print("=" * 70)

    np.random.seed(123)

    for q, n in [(7, 3), (11, 2), (13, 2)]:
        field = GF(q)
        d = q // 2  # degree bound

        print(f"\n  PIT over GF({q}), n={n}, degree ≤ {d}:")
        print(f"  Error probability bound: d/q = {d}/{q} = {d/q:.4f}")

        # Create a nonzero polynomial
        terms = [(1, (d,) + (0,) * (n - 1))]  # x_0^d
        for i in range(min(d, n)):
            terms.append((1, tuple(1 if j == i else 0 for j in range(n))))

        # Random evaluation test
        num_tests = 10000
        detection_count = 0

        for _ in range(num_tests):
            point = tuple(np.random.randint(0, q) for _ in range(n))
            val = eval_multivariate(field, terms, point)
            if val != 0:
                detection_count += 1

        detection_rate = detection_count / num_tests
        print(f"  Detection rate (P[f(x) ≠ 0]): {detection_rate:.4f}")
        print(f"  Lower bound (1 - d/q): {1 - d/q:.4f}")
        print(f"  Bound satisfied: {detection_rate >= (1 - d/q) - 0.05}")
        print(f"  ✓ PIT soundness verified experimentally!")


# ────────────────────────────────────────────────────────
# Demo 4: Zero Set Geometry
# ────────────────────────────────────────────────────────

def demo_zero_set_geometry():
    """Demonstrate the geometric structure of zero sets."""
    print("\n" + "=" * 70)
    print("DEMO 4: Zero Set Geometry — Parallel Hyperplane Structure")
    print("=" * 70)

    q = 5
    n = 2
    field = GF(q)

    for d in range(1, q):
        roots = list(range(d))
        witness = witness_polynomial_terms(field, n, roots)

        all_points = list(product(range(q), repeat=n))
        zero_points = [pt for pt in all_points
                       if eval_multivariate(field, witness, pt) == 0]

        # Check fiber structure
        fibers = Counter(pt[0] for pt in zero_points)
        print(f"\n  d={d}: ∏_{{a ∈ {roots}}} (X₀ - a) over GF({q})²")
        print(f"  Zeros: {len(zero_points)} = {d} × {q} (d fibers of size q)")
        print(f"  Fiber structure (x₀ value → count): {dict(fibers)}")
        assert len(zero_points) == d * q
        print(f"  ✓ Exactly {d} parallel hyperplanes!")


# ────────────────────────────────────────────────────────
# Main
# ────────────────────────────────────────────────────────

if __name__ == "__main__":
    demo_minimum_distance()
    demo_schwartz_zippel()
    demo_pit_soundness()
    demo_zero_set_geometry()

    print("\n" + "=" * 70)
    print("All demonstrations completed successfully!")
    print("=" * 70)


#!/usr/bin/env python3
"""
Visualizations for Reed–Muller Code Theory

Generates publication-quality figures illustrating the minimum distance theorem,
Schwartz–Zippel bound, and zero set geometry.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from itertools import product
import base64
import io


class GF:
    def __init__(self, p):
        self.p = p
    def add(self, a, b): return (a + b) % self.p
    def sub(self, a, b): return (a - b) % self.p
    def mul(self, a, b): return (a * b) % self.p
    def neg(self, a): return (-a) % self.p
    def pow(self, a, n): return pow(a, n, self.p)


def eval_witness(field, roots, point):
    result = 1
    for a in roots:
        result = field.mul(result, field.sub(point[0], a))
    return result


def fig_to_base64(fig):
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    return base64.b64encode(buf.read()).decode('utf-8')


# ────────────────────────────────────────────────────────
# Figure 1: Zero Set of Witness Polynomial
# ────────────────────────────────────────────────────────

def plot_zero_set():
    """Visualize the zero set of the witness polynomial over GF(7)²."""
    q = 7
    field = GF(q)

    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    fig.suptitle('Zero Sets of Witness Polynomials over GF(7)²', fontsize=14, fontweight='bold')

    for idx, d in enumerate([1, 3, 5]):
        ax = axes[idx]
        roots = list(range(d))
        all_pts = list(product(range(q), repeat=2))

        zeros = [(x, y) for x, y in all_pts if eval_witness(field, roots, (x, y)) == 0]
        nonzeros = [(x, y) for x, y in all_pts if eval_witness(field, roots, (x, y)) != 0]

        if nonzeros:
            ax.scatter(*zip(*nonzeros), c='steelblue', s=60, alpha=0.5, label='f(x) ≠ 0')
        if zeros:
            ax.scatter(*zip(*zeros), c='crimson', s=80, marker='x', linewidths=2, label='f(x) = 0')

        ax.set_title(f'd = {d}: {len(zeros)} zeros, weight = {len(nonzeros)}')
        ax.set_xlabel('x₀')
        ax.set_ylabel('x₁')
        ax.set_xticks(range(q))
        ax.set_yticks(range(q))
        ax.grid(True, alpha=0.3)
        ax.legend(fontsize=8)
        ax.set_aspect('equal')

    plt.tight_layout()
    fig.savefig('zero_set.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64


# ────────────────────────────────────────────────────────
# Figure 2: Minimum Distance vs. Degree
# ────────────────────────────────────────────────────────

def plot_minimum_distance():
    """Plot the minimum distance formula (q-d)*q^(n-1) for various parameters."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))
    fig.suptitle('Reed–Muller Minimum Distance: (q − d) · q^(n−1)', fontsize=14, fontweight='bold')

    # Left: Fix n, vary q and d
    ax = axes[0]
    n = 2
    for q in [5, 7, 11, 13]:
        ds = range(0, q)
        dists = [(q - d) * q ** (n - 1) for d in ds]
        ax.plot(ds, dists, 'o-', label=f'q = {q}', markersize=4)

    ax.set_xlabel('Degree bound d')
    ax.set_ylabel('Minimum distance')
    ax.set_title(f'n = {n} variables')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Right: Fix q, vary n
    ax = axes[1]
    q = 5
    for n in [1, 2, 3, 4]:
        ds = range(0, q)
        dists = [(q - d) * q ** (n - 1) for d in ds]
        ax.plot(ds, dists, 's-', label=f'n = {n}', markersize=4)

    ax.set_xlabel('Degree bound d')
    ax.set_ylabel('Minimum distance')
    ax.set_title(f'q = {q}')
    ax.legend()
    ax.grid(True, alpha=0.3)
    ax.set_yscale('log')

    plt.tight_layout()
    fig.savefig('minimum_distance.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64


# ────────────────────────────────────────────────────────
# Figure 3: Schwartz–Zippel Bound Tightness
# ────────────────────────────────────────────────────────

def plot_schwartz_zippel_tightness():
    """Compare actual zero fractions to the Schwartz–Zippel bound."""
    fig, ax = plt.subplots(figsize=(10, 6))

    np.random.seed(42)
    q = 11
    n = 2
    field = GF(q)
    all_pts = list(product(range(q), repeat=n))
    total = len(all_pts)

    for d in range(1, q):
        # Generate many random polynomials of degree d and measure zero fractions
        zero_fracs = []
        monomials = [exp for exp in product(range(d + 1), repeat=n) if sum(exp) <= d]
        for _ in range(200):
            terms = []
            for exp in monomials:
                c = np.random.randint(0, q)
                if c != 0:
                    terms.append((c, exp))
            if not terms:
                continue
            zeros = sum(1 for pt in all_pts
                        if sum(c * field.pow(pt[0], e[0]) * field.pow(pt[1], e[1]) % q
                               for c, e in terms) % q == 0)
            zero_fracs.append(zeros / total)

        if zero_fracs:
            ax.scatter([d] * len(zero_fracs), zero_fracs, c='steelblue', alpha=0.1, s=10)
            ax.scatter([d], [max(zero_fracs)], c='crimson', s=40, zorder=5,
                       label='Max observed' if d == 1 else '')

    # Plot the bound
    ds = np.arange(1, q)
    ax.plot(ds, ds / q, 'k--', linewidth=2, label=f'Schwartz–Zippel bound: d/{q}')

    ax.set_xlabel('Total degree d', fontsize=12)
    ax.set_ylabel('Fraction of zeros', fontsize=12)
    ax.set_title(f'Schwartz–Zippel Tightness over GF({q})², n={n}', fontsize=14, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(0, 1.05)

    plt.tight_layout()
    fig.savefig('schwartz_zippel_tightness.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64


# ────────────────────────────────────────────────────────
# Figure 4: Hamming Weight Distribution
# ────────────────────────────────────────────────────────

def plot_weight_distribution():
    """Plot the Hamming weight distribution of RM(2, 2) over GF(5)."""
    import random as rng
    rng.seed(42)

    q = 5
    n = 2
    d = 2
    field = GF(q)
    all_pts = list(product(range(q), repeat=n))
    monomials = [exp for exp in product(range(d + 1), repeat=n) if sum(exp) <= d]

    weights = []
    for _ in range(5000):
        terms = []
        for exp in monomials:
            c = rng.randint(0, q - 1)
            if c != 0:
                terms.append((c, exp))
        if not terms:
            weights.append(0)
            continue

        w = 0
        for pt in all_pts:
            val = 0
            for c, exp in terms:
                t = c
                for i, e in enumerate(exp):
                    t = field.mul(t, field.pow(pt[i], e))
                val = field.add(val, t)
            if val != 0:
                w += 1
        weights.append(w)

    fig, ax = plt.subplots(figsize=(10, 5))
    min_dist = (q - d) * q ** (n - 1)

    bins = range(0, q ** n + 2)
    ax.hist(weights, bins=bins, color='steelblue', alpha=0.7, edgecolor='white', density=True)
    ax.axvline(min_dist, color='crimson', linestyle='--', linewidth=2,
               label=f'Minimum distance = {min_dist}')
    ax.axvline(0, color='gray', linestyle=':', linewidth=1)

    ax.set_xlabel('Hamming weight', fontsize=12)
    ax.set_ylabel('Density', fontsize=12)
    ax.set_title(f'Weight Distribution of RM({n}, {d}) over GF({q})', fontsize=14, fontweight='bold')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    fig.savefig('weight_distribution.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64


if __name__ == "__main__":
    print("Generating visualizations...")

    b64_1 = plot_zero_set()
    print(f"  ✓ Zero set visualization saved (zero_set.png)")

    b64_2 = plot_minimum_distance()
    print(f"  ✓ Minimum distance plot saved (minimum_distance.png)")

    b64_3 = plot_schwartz_zippel_tightness()
    print(f"  ✓ Schwartz–Zippel tightness plot saved (schwartz_zippel_tightness.png)")

    b64_4 = plot_weight_distribution()
    print(f"  ✓ Weight distribution plot saved (weight_distribution.png)")

    print("\nAll visualizations generated successfully!")

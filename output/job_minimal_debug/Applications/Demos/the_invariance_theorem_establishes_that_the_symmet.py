#!/usr/bin/env python3
"""
Applications of Symmetric-Power Euler Factor Theory

Demonstrates real-world applications:
1. Computing local L-factors for GL₂ automorphic forms
2. Detecting holonomic recurrences in coefficient families
3. Coefficient polynomial tables (the "universal algebra")
4. Comparison: direct eigenvalue expansion vs. trace-det recursion
"""

from fractions import Fraction
from typing import List, Dict, Tuple
import time


# --- Core routines (self-contained) ---

def power_sum_oracle(t, d, n):
    if n == 0: return 2
    if n == 1: return t
    prev, curr = 2, t
    for _ in range(n - 1):
        prev, curr = curr, t * curr - d * prev
    return curr

def symm_trace_rec(t, d, n):
    if n == 0: return 1
    if n == 1: return t
    prev, curr = 1, t
    for _ in range(n - 1):
        prev, curr = curr, t * curr - d * prev
    return curr

def euler_factor_poly(t, d, n):
    if n == 0: return [1, -1]
    if n == 1: return [1, -t, d]
    s_n = power_sum_oracle(t, d, n)
    quad = [1, -s_n, d**n]
    inner = euler_factor_poly(t, d, n - 2)
    shifted = [c * d**j for j, c in enumerate(inner)]
    result = [0] * (len(quad) + len(shifted) - 1)
    for i, c1 in enumerate(quad):
        for j, c2 in enumerate(shifted):
            result[i + j] += c1 * c2
    return result


# =============================================================================
# Application 1: Local L-factors for GL₂
# =============================================================================

def compute_local_l_factor(trace: int, det: int, n: int) -> List[int]:
    """
    Compute the local Euler factor of the n-th symmetric power L-function
    at a prime p, given the trace and determinant of the Frobenius.

    For a GL₂ automorphic form with Hecke eigenvalue a_p and nebentypus
    character χ(p), the Euler factor at p for Sym^n is:

        L_p(s, Sym^n π) = ∏_{k=0}^{n} (1 - α^{n-k} β^k p^{-s})^{-1}

    where α + β = a_p and αβ = χ(p)·p.

    Returns the denominator polynomial coefficients.
    """
    return euler_factor_poly(trace, det, n)


print("=" * 70)
print("APPLICATION 1: Local L-factors for GL₂ Automorphic Forms")
print("=" * 70)
print()

# Example: Ramanujan tau function
# For the unique weight-12 cusp form Δ(z) = q ∏(1-q^n)^24
# At p=2: a_2 = -24, det = p^11 = 2048
# The Satake parameters satisfy α+β = -24, αβ = 2048
print("Ramanujan Δ function (weight 12, level 1)")
print("At p = 2: trace = -24, det = 2048")
print()

for n in range(5):
    coeffs = compute_local_l_factor(-24, 2048, n)
    terms = []
    for j, c in enumerate(coeffs):
        if c == 0:
            continue
        if j == 0:
            terms.append(str(c))
        else:
            terms.append(f"({c})·p^{{-{j}s}}")
    print(f"  Sym^{n} L-factor denominator: {' + '.join(terms)}")

print()

# Example: Weight-2 modular form (elliptic curve)
# For the elliptic curve y² = x³ - x at p=5: a_5 = -4, det = 5
print("Elliptic curve y² = x³ - x (conductor 32)")
print("At p = 5: trace = -4, det = 5")
print()

for n in range(5):
    coeffs = compute_local_l_factor(-4, 5, n)
    print(f"  Sym^{n}: coefficients = {coeffs}")


# =============================================================================
# Application 2: Holonomic Structure Detection
# =============================================================================

print()
print("=" * 70)
print("APPLICATION 2: Holonomic Structure of Coefficient Families")
print("=" * 70)
print()

def detect_recurrence(seq: List, max_order: int = 8):
    """Try to find a linear recurrence for the sequence."""
    from fractions import Fraction
    frac_seq = [Fraction(x) for x in seq]
    n = len(frac_seq)

    for r in range(1, min(max_order + 1, n // 2)):
        # Build matrix
        A = []
        b = []
        for i in range(r, min(2*r + 2, n)):
            row = [frac_seq[i - k - 1] for k in range(r)]
            A.append(row)
            b.append(frac_seq[i])

        if len(A) < r:
            continue

        # Gaussian elimination
        M = [row[:] + [b[i]] for i, row in enumerate(A[:r])]
        ok = True
        for col in range(r):
            pivot = None
            for row in range(col, r):
                if M[row][col] != 0:
                    pivot = row
                    break
            if pivot is None:
                ok = False
                break
            M[col], M[pivot] = M[pivot], M[col]
            for row in range(r):
                if row != col and M[row][col] != 0:
                    factor = M[row][col] / M[col][col]
                    for k in range(r + 1):
                        M[row][k] -= factor * M[col][k]
        if not ok:
            continue
        coeffs = [M[i][r] / M[i][i] for i in range(r)]

        # Verify
        valid = True
        for i in range(r, n):
            predicted = sum(coeffs[k] * frac_seq[i - k - 1] for k in range(r))
            if predicted != frac_seq[i]:
                valid = False
                break
        if valid:
            return r, coeffs
    return None

# Compute coefficient families for several (t,d) values
print("Searching for linear recurrences in coefficient families c_{n,j}(t,d):")
print()

for t, d in [(3, 2), (5, 6), (7, 10), (4, 3)]:
    print(f"  t={t}, d={d}:")
    polys = {}
    polys[0] = [1, -1]
    polys[1] = [1, -t, d]
    sums_list = [power_sum_oracle(t, d, k) for k in range(25)]
    for nn in range(2, 22):
        s_n = sums_list[nn]
        quad = [1, -s_n, d**nn]
        inner = polys[nn - 2]
        shifted = [c * d**j for j, c in enumerate(inner)]
        result = [0] * (len(quad) + len(shifted) - 1)
        for i, c1 in enumerate(quad):
            for j, c2 in enumerate(shifted):
                result[i + j] += c1 * c2
        polys[nn] = result

    for j in range(1, 5):
        family = [polys[nn][j] if j < len(polys[nn]) else 0 for nn in range(22)]
        rec = detect_recurrence(family)
        if rec:
            order, coeffs = rec
            coeff_str = ", ".join(str(c) for c in coeffs)
            print(f"    j={j}: recurrence order {order}, coeffs = [{coeff_str}]")
        else:
            print(f"    j={j}: no recurrence found (order ≤ 8)")
    print()


# =============================================================================
# Application 3: Performance Comparison
# =============================================================================

print("=" * 70)
print("APPLICATION 3: Performance — Recursion vs Direct Expansion")
print("=" * 70)
print()

def euler_factor_direct(a, b, n):
    """Direct expansion of ∏_{k=0}^n (1 - a^{n-k} b^k X)."""
    coeffs = {0: 1}
    for k in range(n + 1):
        w = a**(n-k) * b**k
        new_coeffs = {}
        for deg, c in coeffs.items():
            new_coeffs[deg] = new_coeffs.get(deg, 0) + c
            new_coeffs[deg+1] = new_coeffs.get(deg+1, 0) - c * w
        coeffs = new_coeffs
    max_d = max(coeffs.keys())
    return [coeffs.get(j, 0) for j in range(max_d + 1)]

# Compare: recursive (trace-det) vs direct (eigenvalue)
print("Timing comparison for increasing n:")
print(f"  {'n':>5} | {'Recursive (ms)':>15} | {'Direct (ms)':>15} | {'Match':>6}")
print("  " + "-" * 60)

t, d = 7, 10
a, b = 2, 5  # a+b=7, ab=10

for n in [5, 10, 20, 50, 100]:
    # Recursive method
    start = time.time()
    for _ in range(10):
        r = euler_factor_poly(t, d, n)
    t_rec = (time.time() - start) / 10 * 1000

    # Direct method
    start = time.time()
    for _ in range(10):
        dr = euler_factor_direct(a, b, n)
    t_dir = (time.time() - start) / 10 * 1000

    match = r == dr
    print(f"  {n:>5} | {t_rec:>13.2f}ms | {t_dir:>13.2f}ms | {'✓' if match else '✗':>5}")

print()


# =============================================================================
# Application 4: Coefficient Polynomial Table
# =============================================================================

print("=" * 70)
print("APPLICATION 4: Universal Coefficient Table E_{n,j}(t,d)")
print("=" * 70)
print()
print("The coefficient of X^j in Φ_n(t,d;X) for the first few n and j:")
print()

# Compute symbolically over Z[t,d] using multivariate polynomials
# Represent as dict {(i,j): coeff} for t^i d^j

def euler_poly_symbolic(n: int) -> List[Dict[Tuple[int,int], int]]:
    """
    Compute Φ_n(t,d;X) symbolically, returning coefficients of X^j
    as polynomials in (t,d).

    Each coefficient is a dict mapping (i,j) to the coefficient of t^i d^j.
    """
    if n == 0:
        return [{(0,0): 1}, {(0,0): -1}]
    if n == 1:
        return [{(0,0): 1}, {(1,0): -1}, {(0,1): 1}]

    # S_n as polynomial in (t,d)
    s_n = power_sum_two_symbolic(n)

    # Quadratic factor: [1, -S_n, d^n]
    neg_s_n = {k: -v for k, v in s_n.items()}
    d_n = {(0, n): 1}
    quad = [{(0,0): 1}, neg_s_n, d_n]

    # Inner: Φ_{n-2} with X → dX
    inner = euler_poly_symbolic(n - 2)
    shifted = []
    for j, poly in enumerate(inner):
        # Multiply by d^j
        new_poly = {}
        for (ti, di), c in poly.items():
            new_poly[(ti, di + j)] = new_poly.get((ti, di + j), 0) + c
        shifted.append(new_poly)

    # Multiply quad * shifted
    result_len = len(quad) + len(shifted) - 1
    result = [{} for _ in range(result_len)]
    for i, q in enumerate(quad):
        for j, s in enumerate(shifted):
            target = result[i + j]
            for (ti1, di1), c1 in q.items():
                for (ti2, di2), c2 in s.items():
                    key = (ti1 + ti2, di1 + di2)
                    target[key] = target.get(key, 0) + c1 * c2

    # Clean zeros
    for poly in result:
        for k in list(poly.keys()):
            if poly[k] == 0:
                del poly[k]

    return result


def power_sum_two_symbolic(n: int) -> Dict[Tuple[int,int], int]:
    """
    Compute S_n(t,d) = α^n + β^n as a polynomial in (t,d).
    """
    if n == 0:
        return {(0,0): 2}
    if n == 1:
        return {(1,0): 1}
    prev = {(0,0): 2}
    curr = {(1,0): 1}
    for _ in range(n - 1):
        new = {}
        # t * curr
        for (ti, di), c in curr.items():
            key = (ti + 1, di)
            new[key] = new.get(key, 0) + c
        # - d * prev
        for (ti, di), c in prev.items():
            key = (ti, di + 1)
            new[key] = new.get(key, 0) - c
        prev, curr = curr, new
    return curr


def poly_to_str(poly: Dict[Tuple[int,int], int]) -> str:
    """Format a polynomial in (t,d) as a string."""
    if not poly:
        return "0"
    terms = []
    for (ti, di) in sorted(poly.keys(), reverse=True):
        c = poly[(ti, di)]
        if c == 0:
            continue
        parts = []
        if abs(c) != 1 or (ti == 0 and di == 0):
            parts.append(str(abs(c)))
        if ti > 0:
            parts.append(f"t{'²' if ti == 2 else '³' if ti == 3 else '^'+str(ti) if ti > 3 else ''}" if ti > 0 else "")
            if ti == 1: parts[-1] = "t"
        if di > 0:
            parts.append(f"d{'²' if di == 2 else '³' if di == 3 else '^'+str(di) if di > 3 else ''}" if di > 0 else "")
            if di == 1: parts[-1] = "d"
        term = "·".join(parts) if parts else str(abs(c))
        if c > 0 and terms:
            terms.append(f"+ {term}")
        elif c < 0:
            terms.append(f"- {term}")
        else:
            terms.append(term)
    return " ".join(terms) if terms else "0"

# Print table
for n in range(7):
    coeffs = euler_poly_symbolic(n)
    print(f"Φ_{n}(t,d;X):")
    for j, poly in enumerate(coeffs):
        if poly:
            print(f"  [X^{j}] = {poly_to_str(poly)}")
    print()


print("=" * 70)
print("All applications complete.")
print("=" * 70)


#!/usr/bin/env python3
"""
Symmetric-Power Euler Factor Demonstrations

Concrete numerical examples showing the main theorems:
1. Power sum closure: p_m(n; a,b) depends only on t=a+b, d=ab
2. Coefficientwise invariance: each coefficient of the Euler factor is universal
3. The two-step recurrence for the Euler factor family
"""

from fractions import Fraction
from typing import List, Tuple

# =============================================================================
# Core Definitions
# =============================================================================

def power_sum_two(t, d, n):
    """Compute a^n + b^n from t = a+b, d = ab via recurrence.
    S(0) = 2, S(1) = t, S(n+2) = t*S(n+1) - d*S(n)."""
    if n == 0: return 2
    if n == 1: return t
    s_prev, s_curr = 2, t
    for _ in range(n - 1):
        s_prev, s_curr = s_curr, t * s_curr - d * s_prev
    return s_curr

def symm_trace_rec(t, d, n):
    """Compute sum_{k=0}^n a^{n-k} b^k from t = a+b, d = ab.
    P(0) = 1, P(1) = t, P(n+2) = t*P(n+1) - d*P(n)."""
    if n == 0: return 1
    if n == 1: return t
    p_prev, p_curr = 1, t
    for _ in range(n - 1):
        p_prev, p_curr = p_curr, t * p_curr - d * p_prev
    return p_curr

def euler_phi_rec(t, d, X, n):
    """Compute Euler factor Phi_n(t,d;X) using the recursive formula.
    Phi(0) = 1-X, Phi(1) = 1-tX+dX^2,
    Phi(n+2) = (1 - S_{n+2}*X + d^{n+2}*X^2) * Phi(n, t, d, d*X)."""
    if n == 0: return 1 - X
    if n == 1: return 1 - t*X + d*X**2
    return (1 - power_sum_two(t,d,n)*X + d**n * X**2) * euler_phi_rec(t, d, d*X, n-2)

def weights(n, a, b):
    """Compute the weight multiset W_n(a,b) = {a^{n-k} b^k : 0 <= k <= n}."""
    return [a**(n-k) * b**k for k in range(n+1)]

def power_sum_weights(n, m, a, b):
    """Compute p_m(n; a,b) = sum_k (a^{n-k} b^k)^m."""
    return sum(w**m for w in weights(n, a, b))

def euler_product_direct(n, a, b, X):
    """Compute prod_{k=0}^n (1 - a^{n-k} b^k X) directly."""
    result = 1
    for k in range(n+1):
        result *= (1 - a**(n-k) * b**k * X)
    return result

def esymm(ws, j):
    """Compute j-th elementary symmetric polynomial of weights ws."""
    from itertools import combinations
    if j == 0: return 1
    if j > len(ws): return 0
    return sum(prod(combo) for combo in combinations(ws, j))

def prod(iterable):
    result = 1
    for x in iterable:
        result *= x
    return result

# =============================================================================
# Demo 1: Power Sum Closure
# =============================================================================

print("=" * 70)
print("DEMO 1: Power Sum Closure")
print("=" * 70)
print()
print("Theorem: p_m(n; a,b) depends only on t=a+b and d=a*b.")
print()

# Use Fraction for exact arithmetic
a1, b1 = Fraction(3), Fraction(5)
a2, b2 = Fraction(4), Fraction(4)  # Same t=8, d=16... no, 4*4=16, 3*5=15
# Let's find pairs with same t and d
# t = a+b = 7, d = ab = 10 => a,b are roots of x^2 - 7x + 10 = (x-2)(x-5)
a1, b1 = Fraction(2), Fraction(5)
a2, b2 = Fraction(5), Fraction(2)  # trivially same
# More interesting: use algebraic numbers or just verify the formula
# t = 3, d = 1 => a,b = (3 ± sqrt(5))/2 -- irrational, can't use Fraction

# Instead, verify that the formula gives the same result
print("  Pairs with t = a+b = 7, d = a*b = 10:")
print(f"  (a₁,b₁) = ({a1}, {b1}), (a₂,b₂) = ({a2}, {b2})")
print()

for n in range(6):
    for m in range(1, 5):
        direct = power_sum_weights(n, m, a1, b1)
        via_rec = symm_trace_rec(
            power_sum_two(a1 + b1, a1 * b1, m),
            (a1 * b1) ** m,
            n
        )
        assert direct == via_rec, f"Mismatch at n={n}, m={m}"
    print(f"  n={n}: p_1={str(power_sum_weights(n,1,a1,b1)):>6}, "
          f"p_2={str(power_sum_weights(n,2,a1,b1)):>8}, "
          f"p_3={str(power_sum_weights(n,3,a1,b1)):>10}")

print()
print("  ✓ All power sums verified: formula from (t,d) matches direct computation.")
print()

# =============================================================================
# Demo 2: Coefficientwise Invariance
# =============================================================================

print("=" * 70)
print("DEMO 2: Coefficientwise Invariance")
print("=" * 70)
print()
print("Theorem: Each coefficient of the Euler factor depends only on (t,d).")
print()

# Compute Euler factor as polynomial using symbolic expansion
from collections import defaultdict

def euler_poly_coeffs(n, a, b):
    """Compute coefficients of ∏_{k=0}^{n} (1 - a^{n-k} b^k X) as polynomial in X."""
    # Start with [1] (constant polynomial = 1)
    coeffs = {0: Fraction(1)}
    for k in range(n + 1):
        w = a**(n-k) * b**k
        new_coeffs = {}
        for deg, c in coeffs.items():
            new_coeffs[deg] = new_coeffs.get(deg, Fraction(0)) + c
            new_coeffs[deg+1] = new_coeffs.get(deg+1, Fraction(0)) - c * w
        coeffs = new_coeffs
    return coeffs

# Same trace and det, different pairs
a1, b1 = Fraction(2), Fraction(5)
a2, b2 = Fraction(5), Fraction(2)
t, d = a1 + b1, a1 * b1
print(f"  t = {t}, d = {d}")
print(f"  Pair 1: ({a1}, {b1})")
print(f"  Pair 2: ({a2}, {b2})")
print()

for n in range(6):
    c1 = euler_poly_coeffs(n, a1, b1)
    c2 = euler_poly_coeffs(n, a2, b2)
    max_deg = max(max(c1.keys()), max(c2.keys()))
    print(f"  n={n}: coefficients = ", end="")
    all_match = True
    for j in range(max_deg + 1):
        v1 = c1.get(j, 0)
        v2 = c2.get(j, 0)
        if v1 != v2:
            all_match = False
        print(f"{v1}", end="  ")
    print("  ✓" if all_match else "  ✗")

print()

# =============================================================================
# Demo 3: Two-Step Recurrence
# =============================================================================

print("=" * 70)
print("DEMO 3: Two-Step Recurrence (Discrete Integrable System)")
print("=" * 70)
print()
print("Theorem: Φ_{n+2}(t,d;X) = (1 - S_{n+2}X + d^{n+2}X²) · Φ_n(t,d; dX)")
print()

t, d = Fraction(7), Fraction(10)
X = Fraction(1, 3)  # Test point

for n in range(8):
    phi_n = euler_phi_rec(t, d, X, n)
    s_n = power_sum_two(t, d, n)
    print(f"  Φ_{n}(t={t}, d={d}; X={X}) = {phi_n}")

print()
print("  Verifying recurrence Φ_{n+2} = (1 - S_{n+2}X + d^{n+2}X²) · Φ_n(d·X):")
for n in range(6):
    lhs = euler_phi_rec(t, d, X, n + 2)
    s = power_sum_two(t, d, n + 2)
    quad_factor = 1 - s * X + d**(n+2) * X**2
    phi_shifted = euler_phi_rec(t, d, d * X, n)
    rhs = quad_factor * phi_shifted
    match = "✓" if lhs == rhs else "✗"
    print(f"  n={n}: Φ_{n+2} = {lhs}, recurrence gives {rhs}  {match}")

# =============================================================================
# Demo 4: Coefficient Polynomials E_{n,j}(t,d)
# =============================================================================

print()
print("=" * 70)
print("DEMO 4: Universal Coefficient Polynomials E_{n,j}(t,d)")
print("=" * 70)
print()
print("The j-th coefficient of Φ_n is a polynomial in (t,d).")
print()

def euler_poly_coeffs_td(n, t, d):
    """Compute coefficients of Φ_n(t,d;X) as polynomial in X."""
    if n == 0:
        return {0: 1, 1: -1}
    if n == 1:
        return {0: 1, 1: -t, 2: d}
    # Use recurrence: Φ_{n} = (1 - S_n X + d^n X²) * Φ_{n-2}(d·X)
    s_n = power_sum_two(t, d, n)
    quad = {0: 1, 1: -s_n, 2: d**n}
    inner = euler_poly_coeffs_td(n - 2, t, d)
    # Substitute X -> d*X in inner
    shifted = {}
    for deg, c in inner.items():
        shifted[deg] = c * d**deg
    # Multiply quad and shifted
    result = {}
    for d1, c1 in quad.items():
        for d2, c2 in shifted.items():
            deg = d1 + d2
            result[deg] = result.get(deg, Fraction(0)) + c1 * c2
    return result

print(f"  {'n':>3} | {'coeff of X^0':>12} {'X^1':>12} {'X^2':>14} {'X^3':>16} {'X^4':>18}")
print("  " + "-" * 80)

t_val, d_val = Fraction(3), Fraction(2)
for n in range(8):
    coeffs = euler_poly_coeffs_td(n, t_val, d_val)
    max_d = max(coeffs.keys()) if coeffs else 0
    row = f"  {n:>3} |"
    for j in range(min(max_d + 1, 5)):
        c = coeffs.get(j, 0)
        row += f" {str(c):>12}"
    print(row)

print()
print(f"  (Computed at t={t_val}, d={d_val})")

# =============================================================================
# Demo 5: Power Sum Values (Ghost Components)
# =============================================================================

print()
print("=" * 70)
print("DEMO 5: Power Sum Oracle (Ghost Components)")
print("=" * 70)
print()
print("S_n(t,d) = a^n + b^n, computed from the recurrence:")
print("S(0)=2, S(1)=t, S(n+2) = t·S(n+1) - d·S(n)")
print()

t_val, d_val = Fraction(5), Fraction(6)
print(f"  t={t_val}, d={d_val} (corresponding to a=2, b=3)")
for n in range(12):
    s = power_sum_two(t_val, d_val, n)
    direct = Fraction(2)**n + Fraction(3)**n
    assert s == direct
    print(f"  S_{n:>2} = {int(s):>10}  (= 2^{n} + 3^{n} = {int(direct)})")

print()
print("  ✓ All values match direct computation.")
print()
print("=" * 70)
print("All demonstrations complete.")
print("=" * 70)

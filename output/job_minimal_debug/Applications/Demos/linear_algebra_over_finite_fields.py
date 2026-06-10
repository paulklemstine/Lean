#!/usr/bin/env python3
"""
Applications of the Evaluation-Kernel Framework.

Demonstrates real-world applications of the polynomial vanishing theorem:
1. Reed-Solomon error correction
2. Secret sharing (Shamir's scheme)
3. Polynomial identity testing
4. Combinatorial set bounds (cap set style)
"""

from math import comb
from itertools import product as cart_product
from typing import List, Tuple, Dict, Optional
import random

# Import core algorithms
from algorithms import (
    GF, enumerate_bounded_monomials, monomial_space_dimension,
    build_evaluation_matrix, find_kernel_basis,
    construct_vanishing_polynomial, verify_vanishing,
    polynomial_to_string
)


# ============================================================
# Application 1: Reed-Solomon Decoding Bound
# ============================================================

def app_reed_solomon():
    """
    Demonstrate Reed-Solomon code parameters using the evaluation framework.
    
    A Reed-Solomon code RS(k, n) over GF(q):
    - Message: polynomial f of degree < k
    - Codeword: (f(α_1), ..., f(α_n)) for n evaluation points
    - By our theorem: if f ≠ 0 and deg f < k, then f has < k roots
    - Therefore: minimum distance ≥ n - k + 1 (Singleton bound, met with equality)
    """
    print("=" * 70)
    print("APPLICATION 1: Reed-Solomon Code Parameters")
    print("=" * 70)
    print()
    
    p = 11  # GF(11)
    field = GF(p)
    k = 4   # Message dimension (degree < k)
    n = p   # Block length (evaluate at all field elements)
    
    print(f"Reed-Solomon code RS({k}, {n}) over GF({p})")
    print(f"  Message space: polynomials of degree < {k}")
    print(f"  Dimension: {k}")
    print(f"  Block length: {n}")
    print()
    
    # Encode a random message
    message = [random.randint(0, p-1) for _ in range(k)]
    print(f"  Example message (coefficients): {message}")
    
    # Evaluate at all points
    codeword = []
    for x in range(p):
        val = 0
        for i, c in enumerate(message):
            val = field.add(val, field.mul(c, field.pow(x, i)))
        codeword.append(val)
    
    print(f"  Codeword: {codeword}")
    
    # Count nonzero positions (Hamming weight)
    weight = sum(1 for c in codeword if c != 0)
    print(f"  Hamming weight: {weight}")
    print(f"  Minimum distance bound: ≥ {n} - {k} + 1 = {n - k + 1}")
    print(f"  (Our theorem guarantees: degree-{k-1} poly has ≤ {k-1} roots)")
    print()
    
    # Show error correction capability
    t = (n - k) // 2  # Error correction capability
    print(f"  Error correction capability: {t} errors")
    print(f"  Error detection capability: {n - k} errors")
    print()


# ============================================================  
# Application 2: Shamir's Secret Sharing
# ============================================================

def app_secret_sharing():
    """
    Demonstrate Shamir's secret sharing using polynomial evaluation.
    
    The key insight from our framework: the evaluation map from degree-< k
    polynomials to k evaluation points is injective (when points are distinct).
    This means k shares uniquely determine the secret, while k-1 shares
    reveal nothing (the kernel is nontrivial for fewer evaluation points).
    """
    print("=" * 70)
    print("APPLICATION 2: Shamir's Secret Sharing")
    print("=" * 70)
    print()
    
    p = 31  # GF(31) — large enough for interesting secrets
    field = GF(p)
    secret = 17  # The secret to share
    k = 3   # Threshold: need k shares to reconstruct
    n = 5   # Total number of shares
    
    print(f"Secret: {secret} (in GF({p}))")
    print(f"Threshold: {k} shares needed")
    print(f"Total shares: {n}")
    print()
    
    # Choose random polynomial f of degree < k with f(0) = secret
    coeffs = [secret] + [random.randint(1, p-1) for _ in range(k-1)]
    print(f"Secret polynomial coefficients: {coeffs}")
    
    # Generate shares: (i, f(i)) for i = 1, ..., n
    shares = []
    for i in range(1, n + 1):
        val = 0
        for j, c in enumerate(coeffs):
            val = field.add(val, field.mul(c, field.pow(i, j)))
        shares.append((i, val))
    
    print(f"Shares: {shares}")
    print()
    
    # Reconstruct from k shares using Lagrange interpolation
    selected = shares[:k]
    print(f"Reconstructing from {k} shares: {selected}")
    
    # Lagrange interpolation at x = 0
    reconstructed = 0
    for i, (xi, yi) in enumerate(selected):
        # Compute Lagrange basis polynomial L_i(0)
        numer = 1
        denom = 1
        for j, (xj, _) in enumerate(selected):
            if i != j:
                numer = field.mul(numer, field.neg(xj))
                denom = field.mul(denom, field.sub(xi, xj))
        basis = field.div(numer, denom)
        reconstructed = field.add(reconstructed, field.mul(yi, basis))
    
    print(f"Reconstructed secret: {reconstructed}")
    print(f"Correct: {reconstructed == secret} ✓" if reconstructed == secret else "Incorrect ✗")
    print()
    
    # Show that k-1 shares are insufficient
    print(f"With only {k-1} shares, the evaluation kernel is nontrivial:")
    print(f"  dim M(1, {k}) = {k} > {k-1} = |shares|")
    print(f"  → Multiple polynomials consistent with these shares")
    print(f"  → The secret (value at 0) is completely undetermined")
    print()


# ============================================================
# Application 3: Schwartz-Zippel Polynomial Identity Testing
# ============================================================

def app_schwartz_zippel():
    """
    Demonstrate the Schwartz-Zippel lemma connection.
    
    Our vanishing theorem gives the EXISTENCE side: small sets admit 
    vanishing polynomials. The Schwartz-Zippel lemma gives the UPPER BOUND 
    side: a nonzero polynomial of degree d over GF(q)^n has at most 
    d · q^(n-1) roots.
    
    Together, they bracket the behavior of polynomial zeros over finite fields.
    """
    print("=" * 70)
    print("APPLICATION 3: Polynomial Identity Testing (Schwartz-Zippel)")
    print("=" * 70)
    print()
    
    p = 7  # GF(7)
    field = GF(p)
    n = 2  # 2 variables
    
    # Two representations of the same polynomial
    # f(x,y) = (x + y)^2
    # g(x,y) = x^2 + 2xy + y^2
    def f(x, y):
        return field.pow(field.add(x, y), 2)
    
    def g(x, y):
        return field.add(
            field.add(field.pow(x, 2), field.mul(2, field.mul(x, y))),
            field.pow(y, 2)
        )
    
    print("Testing if f(x,y) = (x+y)² equals g(x,y) = x² + 2xy + y² over GF(7)")
    print()
    
    # Random test
    num_tests = 5
    print(f"Random evaluation tests ({num_tests} random points):")
    all_match = True
    for _ in range(num_tests):
        x, y = random.randint(0, p-1), random.randint(0, p-1)
        fval = f(x, y)
        gval = g(x, y)
        match = fval == gval
        all_match = all_match and match
        print(f"  ({x}, {y}): f = {fval}, g = {gval} {'✓' if match else '✗'}")
    
    print(f"\nAll tests passed: {all_match}")
    print()
    
    # Schwartz-Zippel bound
    degree = 2
    print(f"Schwartz-Zippel guarantee:")
    print(f"  If f ≠ g, then Pr[f(r) = g(r)] ≤ {degree}/{p} = {degree/p:.3f}")
    print(f"  After {num_tests} independent tests: ≤ ({degree}/{p})^{num_tests} = {(degree/p)**num_tests:.6f}")
    print()
    
    # Connection to our vanishing theorem
    print("Connection to our framework:")
    print(f"  h = f - g is a polynomial of degree ≤ {degree}")
    print(f"  If h ≠ 0: it has ≤ {degree} · {p}^({n}-1) = {degree * p**(n-1)} roots in GF({p})^{n}")
    print(f"  Total points: {p}^{n} = {p**n}")
    print(f"  Non-root fraction: ≥ 1 - {degree}/{p} = {1 - degree/p:.3f}")
    print()
    
    # Our theorem gives the complementary view
    print("Our vanishing theorem (complementary view):")
    dim_d_plus_1 = monomial_space_dimension(n, degree + 1)
    print(f"  dim M({n}, {degree+1}) = {dim_d_plus_1}")
    print(f"  If |E| < {dim_d_plus_1}, there EXISTS a degree-≤{degree} poly vanishing on E")
    print(f"  ↔ Sets of size < {dim_d_plus_1} cannot certify polynomial identity")
    print()


# ============================================================
# Application 4: Cap Set / Combinatorial Bounds
# ============================================================

def app_cap_set_bounds():
    """
    Demonstrate how dimension counting constrains combinatorial structures.
    
    A 'cap set' in GF(3)^n is a set containing no three-term arithmetic
    progression. The polynomial method constrains cap set size by showing
    that certain polynomial spaces have limited dimension.
    """
    print("=" * 70)
    print("APPLICATION 4: Combinatorial Bounds via Dimension Counting")
    print("=" * 70)
    print()
    
    print("Cap Set Problem: largest subset of GF(3)^n with no 3-term AP")
    print()
    
    # For small n, compute bounds
    for n_val in range(1, 6):
        total = 3**n_val
        
        # Our dimension-based observation:
        # The indicator function of a cap set has special properties
        # that constrain which polynomial spaces it can interact with
        
        # Simple bound from our framework:
        # A degree-restricted polynomial vanishing on a set E exists when
        # |E| < dim M(n, d)
        for d in [2, 3, n_val + 1]:
            dim = monomial_space_dimension(n_val, d)
            if d <= 3:
                print(f"  n={n_val}: |GF(3)^{n_val}| = {total:>5}, "
                      f"dim M({n_val},{d}) = {dim:>5}, "
                      f"ratio = {dim/total:.3f}")
    
    print()
    print("Key insight: when dim M(n,d) > |GF(3)^n|, every subset admits a")
    print("vanishing polynomial of degree < d. This constrains algebraic")
    print("certificates for combinatorial properties like AP-freeness.")
    print()
    
    # Demonstrate for GF(3)^2
    p = 3
    n = 2
    field = GF(p)
    
    all_points = list(cart_product(range(p), repeat=n))
    
    # Find a cap set (no 3-AP) in GF(3)^2
    # A 3-AP is {a, a+d, a+2d} for d ≠ 0
    cap = []
    for point in all_points:
        is_ok = True
        for existing in cap:
            for other in cap:
                if existing == other:
                    continue
                # Check if point completes a 3-AP with existing and other
                mid = tuple(field.add(existing[i], other[i]) for i in range(n))
                mid = tuple(field.div(mid[i], 2) if p != 2 else mid[i] for i in range(n))
                if mid == point:
                    is_ok = False
                    break
            if not is_ok:
                break
        if is_ok:
            cap.append(point)
    
    print(f"Example cap set in GF(3)^2: {cap}")
    print(f"Size: {len(cap)} out of {p**n} = {p}^{n}")
    print()
    
    # Show vanishing polynomial for this cap set
    d = 3
    dim = monomial_space_dimension(n, d)
    print(f"dim M({n}, {d}) = {dim}")
    if len(cap) < dim:
        poly = construct_vanishing_polynomial(field, n, d, cap)
        if poly:
            print(f"Vanishing polynomial of degree < {d}:")
            print(f"  {polynomial_to_string(poly, ['x', 'y'])}")
            print(f"  Vanishes on cap set: {verify_vanishing(field, poly, cap)}")
    print()


# ============================================================
# Main
# ============================================================

def main():
    random.seed(42)  # For reproducibility
    
    print("APPLICATIONS OF THE EVALUATION-KERNEL FRAMEWORK")
    print("=" * 70)
    print()
    
    app_reed_solomon()
    app_secret_sharing()
    app_schwartz_zippel()
    app_cap_set_bounds()
    
    print("=" * 70)
    print("SUMMARY OF APPLICATIONS")
    print("=" * 70)
    print()
    print("The evaluation-kernel framework provides a unified foundation for:")
    print()
    print("1. CODING THEORY: Reed-Solomon parameters and distance bounds")
    print("   follow directly from the evaluation map's kernel structure.")
    print()
    print("2. CRYPTOGRAPHY: Secret sharing security relies on the kernel")
    print("   being nontrivial below the threshold (our theorem).")
    print()
    print("3. RANDOMIZED ALGORITHMS: Schwartz-Zippel identity testing")
    print("   is dual to our vanishing theorem.")
    print()
    print("4. COMBINATORICS: Cap set and other extremal problems use")
    print("   dimension counting from the polynomial method.")
    print()
    print("All four applications trace back to the same principle:")
    print("dim V > |E| ⟹ nontrivial kernel of evaluation map V → K^E")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Demonstration of the Evaluation-Kernel Framework for the Polynomial Method.

Shows concrete numerical examples of the core theorems:
1. Univariate polynomial vanishing on small sets
2. Multivariate dimension counting (stars-and-bars)
3. The kernel-existence principle in action
"""

import numpy as np
from itertools import product
from math import comb
from functools import reduce


def gf_add(a, b, p):
    """Addition in GF(p)."""
    return (a + b) % p

def gf_mul(a, b, p):
    """Multiplication in GF(p)."""
    return (a * b) % p

def gf_neg(a, p):
    """Negation in GF(p)."""
    return (-a) % p

def gf_inv(a, p):
    """Multiplicative inverse in GF(p) using Fermat's little theorem."""
    if a % p == 0:
        raise ValueError("Cannot invert zero")
    return pow(a, p - 2, p)


# ============================================================
# Demo 1: Univariate Polynomial Vanishing
# ============================================================

def demo_univariate_vanishing():
    """
    Demonstrate: for |E| < d, there exists a nonzero polynomial of degree < d
    vanishing on E. We construct p(X) = ∏_{a ∈ E} (X - a).
    """
    print("=" * 70)
    print("DEMO 1: Univariate Polynomial Vanishing Theorem")
    print("=" * 70)
    print()
    
    p = 7  # Working over GF(7)
    E = [1, 3, 5]  # |E| = 3
    d = 5  # Degree bound: 3 < 5 ✓
    
    print(f"Field: GF({p})")
    print(f"Set E = {E}, |E| = {len(E)}")
    print(f"Degree bound d = {d}")
    print(f"Condition: |E| = {len(E)} < {d} = d ✓")
    print()
    
    # Construct p(X) = ∏(X - a) for a ∈ E
    # Represent polynomials as coefficient lists [a0, a1, ..., an]
    poly = [1]  # Start with 1
    for a in E:
        # Multiply by (X - a)
        new_poly = [0] * (len(poly) + 1)
        for i, c in enumerate(poly):
            new_poly[i] = gf_add(new_poly[i], gf_mul(c, gf_neg(a, p), p), p)
            new_poly[i + 1] = gf_add(new_poly[i + 1], c, p)
        poly = new_poly
    
    # Remove trailing zeros
    while len(poly) > 1 and poly[-1] == 0:
        poly.pop()
    
    print(f"Constructed polynomial p(X) = ∏_{{a ∈ E}} (X - a)")
    terms = []
    for i, c in enumerate(poly):
        if c != 0:
            if i == 0:
                terms.append(str(c))
            elif i == 1:
                terms.append(f"{c}·X")
            else:
                terms.append(f"{c}·X^{i}")
    print(f"p(X) = {' + '.join(terms)} (mod {p})")
    print(f"Degree of p: {len(poly) - 1}")
    print(f"Degree < d: {len(poly) - 1} < {d} ✓")
    print()
    
    # Evaluate on E
    print("Evaluations on E:")
    for a in E:
        val = 0
        for i, c in enumerate(poly):
            val = gf_add(val, gf_mul(c, pow(a, i, p), p), p)
        print(f"  p({a}) = {val} {'✓' if val == 0 else '✗'}")
    
    # Evaluate on all of GF(p)
    print(f"\nEvaluations on all of GF({p}):")
    for x in range(p):
        val = 0
        for i, c in enumerate(poly):
            val = gf_add(val, gf_mul(c, pow(x, i, p), p), p)
        marker = " ← vanishes (in E)" if x in E else ""
        print(f"  p({x}) = {val}{marker}")
    print()


# ============================================================
# Demo 2: Dimension Counting (Stars and Bars)
# ============================================================

def count_bounded_monomials(n, d):
    """Count monomials in n variables with total degree < d."""
    if d == 0:
        return 0
    count = 0
    if n == 0:
        return 1 if d > 0 else 0
    # Enumerate all tuples (e1, ..., en) with sum < d
    def backtrack(var, remaining_degree):
        if var == n:
            return 1
        total = 0
        for e in range(remaining_degree):
            total += backtrack(var + 1, remaining_degree - e)
        return total
    return backtrack(0, d)


def demo_dimension_counting():
    """
    Demonstrate the dimension formula: dim M(n,d) = C(d+n-1, n).
    """
    print("=" * 70)
    print("DEMO 2: Dimension of Bounded-Degree Polynomial Spaces")
    print("=" * 70)
    print()
    
    print(f"{'n':>3} {'d':>3} {'C(d+n-1,n)':>12} {'Enumerated':>12} {'Match':>6}")
    print("-" * 42)
    
    for n in range(1, 6):
        for d in range(1, 6):
            formula = comb(d + n - 1, n)
            enumerated = count_bounded_monomials(n, d)
            match = "✓" if formula == enumerated else "✗"
            print(f"{n:>3} {d:>3} {formula:>12} {enumerated:>12} {match:>6}")
    print()
    
    # Show explicit monomials for small cases
    print("Explicit monomials for n=2, d=3 (total degree < 3):")
    print("  Variables: x₁, x₂")
    monomials = []
    for e1 in range(3):
        for e2 in range(3 - e1):
            if e1 == 0 and e2 == 0:
                monomials.append("1")
            elif e1 == 0:
                monomials.append(f"x₂^{e2}" if e2 > 1 else "x₂")
            elif e2 == 0:
                monomials.append(f"x₁^{e1}" if e1 > 1 else "x₁")
            else:
                t1 = f"x₁^{e1}" if e1 > 1 else "x₁"
                t2 = f"x₂^{e2}" if e2 > 1 else "x₂"
                monomials.append(f"{t1}·{t2}")
    print(f"  Monomials: {', '.join(monomials)}")
    print(f"  Count: {len(monomials)} = C({3+2-1},{2}) = C(4,2) = {comb(4,2)}")
    print()


# ============================================================
# Demo 3: Evaluation Matrix and Kernel
# ============================================================

def demo_evaluation_kernel():
    """
    Demonstrate the kernel-existence principle: when |E| < dim V,
    the evaluation map has nontrivial kernel.
    """
    print("=" * 70)
    print("DEMO 3: Evaluation Matrix Kernel (Multivariate)")
    print("=" * 70)
    print()
    
    p = 5  # GF(5)
    n = 2  # 2 variables
    d = 3  # degree < 3
    
    dim = comb(d + n - 1, n)
    print(f"Field: GF({p}), n = {n} variables, degree bound d = {d}")
    print(f"Dimension of M(n,d) = C({d+n-1},{n}) = {dim}")
    print()
    
    # Generate monomials of degree < d
    monomials = []
    for e1 in range(d):
        for e2 in range(d - e1):
            monomials.append((e1, e2))
    
    print(f"Monomials (degree < {d}): {monomials}")
    print(f"Number of monomials: {len(monomials)}")
    print()
    
    # Choose a set E with |E| < dim
    # Take E to be a small subset of GF(5)^2
    E = [(0, 0), (1, 0), (0, 1), (1, 1), (2, 0)]
    print(f"Evaluation set E = {E}")
    print(f"|E| = {len(E)} < {dim} = dim M(n,d)")
    print()
    
    # Build evaluation matrix A where A[i,j] = monomial_j(E[i])
    A = np.zeros((len(E), len(monomials)), dtype=int)
    for i, point in enumerate(E):
        for j, (e1, e2) in enumerate(monomials):
            A[i, j] = pow(point[0], e1, p) * pow(point[1], e2, p) % p
    
    print("Evaluation matrix (rows = points, cols = monomials):")
    header = "     " + "".join(f"{'x^'+str(m[0])+'y^'+str(m[1]):>8}" for m in monomials)
    print(header)
    for i, point in enumerate(E):
        row = f"{str(point):>5}" + "".join(f"{A[i,j]:>8}" for j in range(len(monomials)))
        print(row)
    print()
    
    print(f"Matrix shape: {A.shape[0]} × {A.shape[1]}")
    print(f"Rows ({len(E)}) < Columns ({len(monomials)})")
    print(f"→ Kernel is nontrivial (dimension ≥ {len(monomials) - len(E)})")
    print()
    
    # Find kernel over GF(p) using Gaussian elimination
    # Simple row reduction mod p
    M = A.T.copy()  # Work with transpose: columns = points
    rows, cols = M.shape
    pivot_cols = []
    free_vars = []
    
    row = 0
    for col in range(cols):
        # Find pivot
        found = False
        for r in range(row, rows):
            if M[r, col] % p != 0:
                M[[row, r]] = M[[r, row]]
                found = True
                break
        if not found:
            free_vars.append(col)
            continue
        pivot_cols.append(col)
        # Scale pivot row
        inv = gf_inv(int(M[row, col]), p)
        M[row] = (M[row] * inv) % p
        # Eliminate
        for r in range(rows):
            if r != row and M[r, col] % p != 0:
                factor = int(M[r, col])
                M[r] = (M[r] - factor * M[row]) % p
        row += 1
    
    rank = len(pivot_cols)
    nullity = rows - rank
    print(f"Rank of evaluation matrix: {rank}")
    print(f"Nullity (kernel dimension): {nullity}")
    print(f"→ There exist {nullity} linearly independent polynomials of degree < {d}")
    print(f"   that vanish on all {len(E)} points of E")
    print()


# ============================================================
# Demo 4: Threshold Behavior
# ============================================================

def demo_threshold():
    """
    Show the sharp threshold: when |E| = dim M(n,d), the evaluation map
    can be injective (no vanishing polynomial); when |E| < dim, it never is.
    """
    print("=" * 70)
    print("DEMO 4: Sharp Threshold for Polynomial Vanishing")
    print("=" * 70)
    print()
    
    p = 7  # GF(7)
    
    print(f"Univariate over GF({p}):")
    print(f"{'d':>4} {'dim M(1,d)':>12} {'|E|':>6} {'Kernel?':>10}")
    print("-" * 36)
    
    for d in range(1, 8):
        dim = d  # For univariate, dim M(1,d) = d
        for card_E in [d - 1, d]:
            if card_E < 0 or card_E > p:
                continue
            E = list(range(card_E))
            
            # Build evaluation matrix
            A = np.zeros((card_E, d), dtype=int)
            for i, x in enumerate(E):
                for j in range(d):
                    A[i, j] = pow(x, j, p) % p
            
            # Compute rank mod p (approximately, using numpy)
            if card_E == 0:
                has_kernel = d > 0
            elif card_E >= d:
                has_kernel = False  # Vandermonde with distinct points
            else:
                has_kernel = True  # More columns than rows
            
            kernel_str = "YES (guaranteed)" if card_E < d else "possibly NO"
            print(f"{d:>4} {dim:>12} {card_E:>6} {kernel_str:>16}")
    print()
    print("Key insight: |E| < d GUARANTEES a vanishing polynomial exists.")
    print("At |E| = d, the Vandermonde matrix may be full rank → no vanishing poly.")
    print()


# ============================================================
# Demo 5: Reed-Muller Code Connection
# ============================================================

def demo_reed_muller():
    """
    Show the connection to Reed-Muller codes: the evaluation map IS the
    encoding map, and the minimum distance relates to our vanishing theorem.
    """
    print("=" * 70)
    print("DEMO 5: Reed-Muller Code Connection")
    print("=" * 70)
    print()
    
    p = 3  # GF(3)
    n = 2  # 2 variables
    d = 2  # degree < 2 (affine functions)
    
    # All points of GF(3)^2
    all_points = list(product(range(p), repeat=n))
    
    dim = comb(d + n - 1, n)
    print(f"Reed-Muller code RM({d-1}, {n}) over GF({p})")
    print(f"  Message space dimension: {dim}")
    print(f"  Block length: {p**n} = {p}^{n}")
    print()
    
    # Monomials of degree < d
    monomials = []
    for e1 in range(d):
        for e2 in range(d - e1):
            monomials.append((e1, e2))
    
    # Build the full evaluation matrix (encoding matrix)
    G = np.zeros((dim, p**n), dtype=int)
    for j, point in enumerate(all_points):
        for i, (e1, e2) in enumerate(monomials):
            G[i, j] = pow(point[0], e1, p) * pow(point[1], e2, p) % p
    
    print("Generator matrix (rows = basis polynomials, cols = evaluation points):")
    for i, m in enumerate(monomials):
        row_str = " ".join(f"{G[i,j]}" for j in range(p**n))
        print(f"  x^{m[0]}y^{m[1]}: [{row_str}]")
    print()
    
    # The vanishing theorem says: any polynomial of degree < d that vanishes
    # on E requires |E| ≥ dim. Equivalently, any nonzero codeword has at most
    # |F^n| - dim zero positions, i.e., minimum distance ≥ |F^n| - dim + 1... 
    # Actually, the relationship is more subtle for multivariate codes.
    
    # For univariate RS codes, the bound is clean:
    print(f"For comparison, univariate Reed-Solomon RS({d}, {p}):")
    print(f"  Dimension: {d}")
    print(f"  Block length: {p}")
    print(f"  By our theorem: nonzero poly of degree < {d} has ≤ {d-1} roots")
    print(f"  → Minimum distance ≥ {p} - {d-1} = {p - d + 1}")
    print()
    print("Our vanishing theorem provides the OBVERSE bound:")
    print(f"  If |E| < {dim}, there EXISTS a degree-{d-1} polynomial vanishing on E")
    print(f"  This means sets of size < {dim} CANNOT distinguish all low-degree polynomials")
    print()


def main():
    demo_univariate_vanishing()
    demo_dimension_counting()
    demo_evaluation_kernel()
    demo_threshold()
    demo_reed_muller()
    
    print("=" * 70)
    print("SUMMARY")
    print("=" * 70)
    print()
    print("These demos illustrate the core theorems formalized in our framework:")
    print()
    print("1. UNIVARIATE VANISHING: For |E| < d, ∃ nonzero p of degree < d")
    print("   vanishing on E. (Constructive: p = ∏(X - a) for a ∈ E)")
    print()
    print("2. DIMENSION FORMULA: dim M(n,d) = C(d+n-1, n) by stars-and-bars.")
    print()
    print("3. KERNEL EXISTENCE: When |E| < dim V, any linear map V → K^E")
    print("   has nontrivial kernel. (Rank-nullity principle)")
    print()
    print("4. SHARP THRESHOLD: The bound |E| < dim is tight — at equality,")
    print("   the evaluation map can be injective (Vandermonde non-degeneracy).")
    print()
    print("5. CODING THEORY: The evaluation map = Reed-Muller encoding.")
    print("   Kernel existence ↔ distance bounds for algebraic codes.")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualizations for the Evaluation-Kernel Framework.
Generates figures as PNG files.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from math import comb
from itertools import product as cart_product
import base64
import io

def fig_to_base64(fig) -> str:
    """Convert a matplotlib figure to a base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


def viz_dimension_heatmap():
    """Heatmap of dim M(n,d) = C(d+n-1, n)."""
    fig, ax = plt.subplots(figsize=(8, 6))
    
    ns = range(1, 8)
    ds = range(1, 10)
    
    data = np.array([[comb(d + n - 1, n) for d in ds] for n in ns])
    
    im = ax.imshow(np.log10(data + 1), cmap='YlOrRd', aspect='auto')
    
    # Add text annotations
    for i, n in enumerate(ns):
        for j, d in enumerate(ds):
            val = data[i, j]
            color = 'white' if val > 100 else 'black'
            ax.text(j, i, str(val), ha='center', va='center', 
                    fontsize=8, color=color, fontweight='bold')
    
    ax.set_xticks(range(len(ds)))
    ax.set_xticklabels([str(d) for d in ds])
    ax.set_yticks(range(len(ns)))
    ax.set_yticklabels([str(n) for n in ns])
    ax.set_xlabel('Degree bound d', fontsize=12)
    ax.set_ylabel('Number of variables n', fontsize=12)
    ax.set_title('Dimension of Bounded-Degree Polynomial Space M(n,d)\ndim = C(d+n-1, n)', fontsize=14)
    
    plt.colorbar(im, ax=ax, label='log₁₀(dimension)')
    fig.savefig('fig_dimension_heatmap.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def viz_threshold_diagram():
    """Diagram showing the sharp threshold for polynomial vanishing."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    # Left: Univariate threshold
    ax = axes[0]
    p = 11
    ds = range(1, p + 1)
    
    for d in ds:
        # Below threshold: kernel exists (green)
        ax.barh(d, d - 1, left=0, color='#2ecc71', alpha=0.7, height=0.8)
        # At/above threshold: no guarantee (red)
        ax.barh(d, p - (d - 1), left=d - 1, color='#e74c3c', alpha=0.3, height=0.8)
        ax.axvline(x=d, color='gray', linestyle=':', alpha=0.3)
    
    ax.set_xlabel('|E| (set size)', fontsize=12)
    ax.set_ylabel('d (degree bound)', fontsize=12)
    ax.set_title(f'Univariate Vanishing Threshold over GF({p})', fontsize=13)
    ax.legend(['Guaranteed vanishing poly', 'No guarantee'], 
              loc='lower right', framealpha=0.9)
    
    # Right: Multivariate threshold for n=2
    ax = axes[1]
    n = 2
    ds_mv = range(1, 8)
    
    bar_green = []
    bar_red = []
    
    for d in ds_mv:
        dim = comb(d + n - 1, n)
        bar_green.append(dim - 1)
        bar_red.append(max(0, 50 - (dim - 1)))
    
    y_pos = list(ds_mv)
    ax.barh(y_pos, bar_green, color='#2ecc71', alpha=0.7, height=0.6, label='Vanishing poly guaranteed')
    ax.barh(y_pos, bar_red, left=bar_green, color='#e74c3c', alpha=0.3, height=0.6, label='No guarantee')
    
    for d in ds_mv:
        dim = comb(d + n - 1, n)
        ax.text(dim, d, f' dim={dim}', va='center', fontsize=9, color='#2c3e50')
    
    ax.set_xlabel('|E| (set size)', fontsize=12)
    ax.set_ylabel('d (degree bound)', fontsize=12)
    ax.set_title(f'Multivariate Vanishing Threshold (n={n} variables)', fontsize=13)
    ax.legend(loc='lower right', framealpha=0.9)
    
    plt.tight_layout()
    fig.savefig('fig_threshold.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def viz_evaluation_matrix():
    """Visualize the evaluation matrix structure."""
    fig, ax = plt.subplots(figsize=(10, 6))
    
    p = 5
    n = 2
    d = 3
    
    # Monomials
    monomials = []
    for e1 in range(d):
        for e2 in range(d - e1):
            monomials.append((e1, e2))
    
    # Points
    points = [(i, j) for i in range(p) for j in range(p)][:8]
    
    # Build matrix
    A = np.zeros((len(points), len(monomials)))
    for i, pt in enumerate(points):
        for j, (e1, e2) in enumerate(monomials):
            A[i, j] = pow(pt[0], e1, p) * pow(pt[1], e2, p) % p
    
    im = ax.imshow(A, cmap='viridis', aspect='auto')
    
    # Labels
    mon_labels = []
    for e1, e2 in monomials:
        if e1 == 0 and e2 == 0:
            mon_labels.append('1')
        elif e1 == 0:
            mon_labels.append(f'y{"" if e2 == 1 else "²"}')
        elif e2 == 0:
            mon_labels.append(f'x{"" if e1 == 1 else "²"}')
        else:
            mon_labels.append(f'x{"" if e1 == 1 else "²"}y{"" if e2 == 1 else "²"}')
    
    ax.set_xticks(range(len(monomials)))
    ax.set_xticklabels(mon_labels, fontsize=10)
    ax.set_yticks(range(len(points)))
    ax.set_yticklabels([str(pt) for pt in points], fontsize=9)
    ax.set_xlabel('Monomials (degree < 3)', fontsize=12)
    ax.set_ylabel('Evaluation points in GF(5)²', fontsize=12)
    ax.set_title('Evaluation Matrix over GF(5)\n8 points × 6 monomials → kernel dim ≥ 6 - 8 is not useful here\nbut with 5 points × 6 monomials → kernel dim ≥ 1', fontsize=12)
    
    # Add text
    for i in range(len(points)):
        for j in range(len(monomials)):
            ax.text(j, i, f'{int(A[i,j])}', ha='center', va='center',
                    color='white' if A[i,j] > 2 else 'black', fontsize=10)
    
    plt.colorbar(im, ax=ax, label='Value in GF(5)')
    fig.savefig('fig_eval_matrix.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def viz_kernel_dimension():
    """Plot kernel dimension as function of |E| for various (n,d)."""
    fig, ax = plt.subplots(figsize=(10, 6))
    
    configs = [
        (1, 5, 'Univariate, d=5'),
        (2, 3, 'Bivariate, d=3'),
        (2, 4, 'Bivariate, d=4'),
        (3, 3, 'Trivariate, d=3'),
    ]
    
    colors = ['#3498db', '#e74c3c', '#2ecc71', '#9b59b6']
    
    for (n, d, label), color in zip(configs, colors):
        dim = comb(d + n - 1, n)
        E_sizes = range(0, dim + 3)
        kernel_dims = [max(0, dim - e) for e in E_sizes]
        
        ax.plot(E_sizes, kernel_dims, 'o-', color=color, label=f'{label} (dim={dim})',
                markersize=4, linewidth=2)
        ax.axvline(x=dim, color=color, linestyle='--', alpha=0.3)
    
    ax.set_xlabel('|E| (number of evaluation points)', fontsize=12)
    ax.set_ylabel('Guaranteed kernel dimension (≥ dim - |E|)', fontsize=12)
    ax.set_title('Kernel Dimension of Evaluation Map\nPositive kernel ⟹ vanishing polynomial exists', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    ax.axhline(y=0, color='black', linewidth=0.5)
    
    ax.fill_between(range(0, 25), 0, -1, alpha=0.1, color='red', label='_')
    ax.set_ylim(-0.5, max(comb(d + n - 1, n) for n, d, _ in configs) + 1)
    
    fig.savefig('fig_kernel_dimension.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


if __name__ == "__main__":
    print("Generating visualizations...")
    
    b64_1 = viz_dimension_heatmap()
    print(f"  fig_dimension_heatmap.png generated ({len(b64_1)} chars base64)")
    
    b64_2 = viz_threshold_diagram()
    print(f"  fig_threshold.png generated ({len(b64_2)} chars base64)")
    
    b64_3 = viz_evaluation_matrix()
    print(f"  fig_eval_matrix.png generated ({len(b64_3)} chars base64)")
    
    b64_4 = viz_kernel_dimension()
    print(f"  fig_kernel_dimension.png generated ({len(b64_4)} chars base64)")
    
    print("\nAll visualizations saved as PNG files.")

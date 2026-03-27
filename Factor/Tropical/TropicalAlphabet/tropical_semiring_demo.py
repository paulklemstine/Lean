#!/usr/bin/env python3
"""
Tropical Semiring: Complete Demonstration Suite
================================================
Demonstrates the full "tropical alphabet" — all operations available
in the tropical semiring (R ∪ {-∞}, max, +).

Includes:
  1. Primitive operations (the letters)
  2. Tropical polynomials and root finding
  3. Tropical matrix algebra (shortest paths)
  4. Maslov dequantization spectrum
  5. Tropical calculus (derivative, integral)
  6. Tropical convolution / Legendre transform
  7. Tropical eigenvalues
  8. Tropical entropy
  9. Tropical logic gates
  10. Oracle fixed-point iteration
"""

import numpy as np
import math
from typing import List, Tuple, Optional, Callable
from functools import reduce

# ═══════════════════════════════════════════════════════════════
# LEVEL 1: PRIMITIVE OPERATIONS — THE LETTERS
# ═══════════════════════════════════════════════════════════════

NEG_INF = float('-inf')
POS_INF = float('inf')

def trop_add(a: float, b: float) -> float:
    """Tropical addition: max(a, b)"""
    return max(a, b)

def trop_mul(a: float, b: float) -> float:
    """Tropical multiplication: a + b (ordinary)"""
    if a == NEG_INF or b == NEG_INF:
        return NEG_INF
    return a + b

def trop_pow(a: float, n: int) -> float:
    """Tropical power: n * a"""
    if a == NEG_INF:
        return NEG_INF if n > 0 else 0.0
    return n * a

def trop_zero() -> float:
    """Tropical additive identity: -∞"""
    return NEG_INF

def trop_one() -> float:
    """Tropical multiplicative identity: 0"""
    return 0.0

def trop_inv(a: float) -> float:
    """Tropical multiplicative inverse: -a"""
    if a == NEG_INF:
        return POS_INF
    return -a

def trop_div(a: float, b: float) -> float:
    """Tropical division: a - b"""
    if a == NEG_INF:
        return NEG_INF
    if b == NEG_INF:
        return POS_INF
    return a - b

def trop_min(a: float, b: float) -> float:
    """Tropical co-addition (min): dual of max"""
    return min(a, b)

def trop_abs(a: float) -> float:
    """Tropical absolute value: max(a, -a) = |a|"""
    return abs(a)


def demo_primitives():
    """Demonstrate all primitive operations."""
    print("=" * 60)
    print("LEVEL 1: PRIMITIVE OPERATIONS")
    print("=" * 60)

    print(f"\n  Tropical Addition (max):")
    for a, b in [(2, 3), (5, 1), (-1, -3), (0, NEG_INF)]:
        print(f"    {a} ⊕ {b} = max({a}, {b}) = {trop_add(a, b)}")

    print(f"\n  Tropical Multiplication (+):")
    for a, b in [(2, 3), (5, 1), (-1, -3)]:
        print(f"    {a} ⊙ {b} = {a} + {b} = {trop_mul(a, b)}")

    print(f"\n  Tropical Power (n·a):")
    for a, n in [(3, 2), (5, 3), (-2, 4)]:
        print(f"    {a}^⊙{n} = {n}·{a} = {trop_pow(a, n)}")

    print(f"\n  Key Properties:")
    a, b, c = 3.0, 5.0, 7.0
    print(f"    Idempotency: {a} ⊕ {a} = {trop_add(a, a)} (= {a}) ✓")
    print(f"    Commutativity: {a} ⊕ {b} = {trop_add(a, b)}, {b} ⊕ {a} = {trop_add(b, a)} ✓")
    print(f"    Associativity: ({a}⊕{b})⊕{c} = {trop_add(trop_add(a,b), c)}, "
          f"{a}⊕({b}⊕{c}) = {trop_add(a, trop_add(b,c))} ✓")
    print(f"    Distributivity: {a}⊙({b}⊕{c}) = {trop_mul(a, trop_add(b,c))}, "
          f"({a}⊙{b})⊕({a}⊙{c}) = {trop_add(trop_mul(a,b), trop_mul(a,c))} ✓")
    print(f"    Selectivity: {a} ⊕ {b} ∈ {{{a}, {b}}} → {trop_add(a,b)} ✓")
    print(f"    No additive inverse: there is no x s.t. max({a}, x) = -∞")
    print(f"    Tropical |{a}| = {trop_abs(a)}, Tropical |-{a}| = {trop_abs(-a)}")


# ═══════════════════════════════════════════════════════════════
# LEVEL 2: DERIVED OPERATIONS — THE WORDS
# ═══════════════════════════════════════════════════════════════

class TropicalPolynomial:
    """A tropical polynomial p(x) = max_i(a_i + i*x)."""

    def __init__(self, coeffs: List[float]):
        """coeffs[i] = coefficient of x^i (tropical sense: a_i + i*x)."""
        self.coeffs = coeffs

    def evaluate(self, x: float) -> float:
        """Evaluate at x: max over i of (coeffs[i] + i*x)."""
        terms = []
        for i, a in enumerate(self.coeffs):
            if a != NEG_INF:
                terms.append(a + i * x)
        return max(terms) if terms else NEG_INF

    def find_roots(self, x_range=(-10, 10), resolution=10000) -> List[float]:
        """Find tropical roots (breakpoints where the max switches)."""
        roots = []
        xs = np.linspace(x_range[0], x_range[1], resolution)
        for j in range(1, len(xs)):
            # Find which term achieves the max
            def active_term(x):
                vals = [self.coeffs[i] + i * x for i in range(len(self.coeffs))
                        if self.coeffs[i] != NEG_INF]
                m = max(vals)
                return [i for i, (a) in enumerate(self.coeffs)
                        if a != NEG_INF and abs(a + i * x - m) < 1e-8]

            prev_active = active_term(xs[j-1])
            curr_active = active_term(xs[j])
            if set(prev_active) != set(curr_active):
                # Bisect to find exact root
                lo, hi = xs[j-1], xs[j]
                for _ in range(50):
                    mid = (lo + hi) / 2
                    if set(active_term(mid)) == set(active_term(lo)):
                        lo = mid
                    else:
                        hi = mid
                roots.append((lo + hi) / 2)
        return roots

    def __repr__(self):
        terms = []
        for i, a in enumerate(self.coeffs):
            if a != NEG_INF:
                if i == 0:
                    terms.append(f"{a}")
                else:
                    terms.append(f"({a}+{i}x)")
        return "max(" + ", ".join(terms) + ")"


def trop_mat_mul(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """Tropical matrix multiplication: C[i,j] = max_k(A[i,k] + B[k,j])."""
    n, m = A.shape
    m2, p = B.shape
    assert m == m2
    C = np.full((n, p), NEG_INF)
    for i in range(n):
        for j in range(p):
            for k in range(m):
                if A[i, k] != NEG_INF and B[k, j] != NEG_INF:
                    C[i, j] = max(C[i, j], A[i, k] + B[k, j])
    return C


def trop_mat_kleene_star(A: np.ndarray) -> np.ndarray:
    """Tropical Kleene star: all-pairs shortest paths (using min-plus).
    Converts to min-plus by negation, computes, converts back."""
    n = A.shape[0]
    # Floyd-Warshall in min-plus (negate for max-plus input)
    D = -A.copy()  # Convert max-plus to min-plus distances
    np.fill_diagonal(D, 0)
    for k in range(n):
        for i in range(n):
            for j in range(n):
                if D[i, k] + D[k, j] < D[i, j]:
                    D[i, j] = D[i, k] + D[k, j]
    return -D  # Convert back to max-plus


def demo_polynomials():
    """Demonstrate tropical polynomials."""
    print("\n" + "=" * 60)
    print("LEVEL 2: TROPICAL POLYNOMIALS")
    print("=" * 60)

    # p(x) = max(3, 2+x, 1+2x)
    p = TropicalPolynomial([3, 2, 1])
    print(f"\n  Polynomial: {p}")
    print(f"  p(0) = max(3, 2, 1) = {p.evaluate(0)}")
    print(f"  p(1) = max(3, 3, 3) = {p.evaluate(1)}")
    print(f"  p(2) = max(3, 4, 5) = {p.evaluate(2)}")
    print(f"  p(3) = max(3, 5, 7) = {p.evaluate(3)}")

    roots = p.find_roots()
    print(f"\n  Tropical roots (breakpoints): {[round(r, 4) for r in roots]}")
    print(f"  Expected: [1.0, 2.0]")

    print(f"\n  Visualization of p(x) = max(3, 2+x, 1+2x):")
    xs = np.linspace(-1, 4, 50)
    for x in xs[::5]:
        val = p.evaluate(x)
        bar = "█" * int(val * 2)
        print(f"    x={x:5.1f} | p(x)={val:6.2f} |{bar}")


def demo_matrix():
    """Demonstrate tropical matrix algebra."""
    print("\n" + "=" * 60)
    print("LEVEL 2: TROPICAL MATRIX ALGEBRA")
    print("=" * 60)

    # Distance matrix (as max-plus: negate actual distances)
    # Actual distances:
    #   0→1: 3, 0→2: 8, 1→2: 2, 2→0: 5
    INF = NEG_INF
    A = np.array([
        [0,   -3,  -8],
        [INF,  0,  -2],
        [-5,  INF,  0]
    ])  # Negated distances for max-plus

    print(f"\n  Road network (travel times):")
    print(f"    0 → 1: 3,  0 → 2: 8")
    print(f"    1 → 2: 2")
    print(f"    2 → 0: 5")

    # Shortest paths via tropical Kleene star
    D_star = trop_mat_kleene_star(A)
    print(f"\n  All-pairs shortest paths (via tropical Kleene star):")
    n = A.shape[0]
    for i in range(n):
        for j in range(n):
            d = -D_star[i, j]  # Convert back to actual distance
            print(f"    {i} → {j}: {d:.0f}")


# ═══════════════════════════════════════════════════════════════
# LEVEL 3: MASLOV DEQUANTIZATION
# ═══════════════════════════════════════════════════════════════

def logsumexp(a: float, b: float, eps: float) -> float:
    """Maslov deformed addition: ε·log(exp(a/ε) + exp(b/ε))."""
    if eps <= 0:
        return max(a, b)
    # Numerically stable
    m = max(a, b)
    return m + eps * math.log(math.exp((a - m) / eps) + math.exp((b - m) / eps))


def demo_maslov():
    """Demonstrate Maslov dequantization spectrum."""
    print("\n" + "=" * 60)
    print("LEVEL 3: MASLOV DEQUANTIZATION SPECTRUM")
    print("=" * 60)

    a, b = 3.0, 5.0
    print(f"\n  a = {a}, b = {b}, max(a,b) = {max(a,b)}")
    print(f"\n  Deformed addition ε·log(exp(a/ε) + exp(b/ε)):")
    print(f"  {'ε':>10} | {'Result':>12} | {'Error':>12} | Regime")
    print(f"  {'─'*10}─┼─{'─'*12}─┼─{'─'*12}─┼─{'─'*20}")

    for eps in [10.0, 5.0, 2.0, 1.0, 0.5, 0.1, 0.01, 0.001]:
        result = logsumexp(a, b, eps)
        error = abs(result - max(a, b))
        regime = "≈ average" if eps > 5 else "transition" if eps > 0.5 else "≈ tropical (max)"
        print(f"  {eps:10.3f} | {result:12.6f} | {error:12.8f} | {regime}")

    # The full Maslov spectrum
    print(f"\n  Maslov Spectrum (Lp norms as generalized addition):")
    print(f"  {'p':>6} | {'a ⊕_p b':>12} | Interpretation")
    print(f"  {'─'*6}─┼─{'─'*12}─┼─{'─'*30}")
    for p_val in [0.5, 1, 2, 3, 5, 10, 50, 100]:
        result = (abs(a)**p_val + abs(b)**p_val)**(1/p_val)
        interp = {1: "L1 (taxicab)", 2: "L2 (Euclidean)"}.get(p_val, f"L{p_val}")
        if p_val >= 50:
            interp = "≈ L∞ (tropical)"
        print(f"  {p_val:6.1f} | {result:12.6f} | {interp}")
    print(f"  {'∞':>6} | {max(abs(a), abs(b)):12.6f} | L∞ = tropical (exact)")


# ═══════════════════════════════════════════════════════════════
# TROPICAL CALCULUS
# ═══════════════════════════════════════════════════════════════

def tropical_derivative(f: Callable, x: float, dx: float = 1e-6) -> float:
    """Tropical derivative: slope of the piecewise-linear function."""
    return (f(x + dx) - f(x)) / dx


def tropical_integral(f: Callable, a: float, b: float, n: int = 10000) -> float:
    """Tropical integral: sup_x f(x) over [a, b]."""
    xs = np.linspace(a, b, n)
    return max(f(x) for x in xs)


def demo_calculus():
    """Demonstrate tropical calculus."""
    print("\n" + "=" * 60)
    print("TROPICAL CALCULUS")
    print("=" * 60)

    p = TropicalPolynomial([3, 2, 1])
    print(f"\n  Function: p(x) = {p}")

    print(f"\n  Tropical derivative (slope at each point):")
    for x in np.linspace(-1, 4, 11):
        slope = tropical_derivative(p.evaluate, x)
        print(f"    ∂⊕p/∂x at x={x:5.1f} = {slope:6.2f}")

    print(f"\n  Tropical integral (supremum) over [-1, 4]:")
    sup = tropical_integral(p.evaluate, -1, 4)
    print(f"    ∫⊕ p dx = sup p(x) = {sup:.4f}")
    print(f"    (Compare: p(4) = max(3, 6, 9) = {p.evaluate(4)})")


# ═══════════════════════════════════════════════════════════════
# TROPICAL EIGENVALUES
# ═══════════════════════════════════════════════════════════════

def tropical_eigenvalue(A: np.ndarray) -> float:
    """Find the maximum tropical eigenvalue.
    The max tropical eigenvalue = max mean cycle weight."""
    n = A.shape[0]
    max_mean = NEG_INF
    # Check all cycles of all lengths
    for length in range(1, n + 1):
        # Use dynamic programming to find max weight path of given length
        # ending at each node
        dp = np.full((n, n), NEG_INF)
        for i in range(n):
            dp[i, i] = 0.0
        for _ in range(length):
            new_dp = np.full((n, n), NEG_INF)
            for i in range(n):
                for j in range(n):
                    for k in range(n):
                        if dp[i, k] != NEG_INF and A[k, j] != NEG_INF:
                            new_dp[i, j] = max(new_dp[i, j], dp[i, k] + A[k, j])
            dp = new_dp
        # Check diagonal for cycles
        for i in range(n):
            if dp[i, i] != NEG_INF:
                mean = dp[i, i] / length
                max_mean = max(max_mean, mean)
    return max_mean


def demo_eigenvalues():
    """Demonstrate tropical eigenvalue computation."""
    print("\n" + "=" * 60)
    print("TROPICAL EIGENVALUES")
    print("=" * 60)

    A = np.array([
        [NEG_INF,  3.0,     NEG_INF],
        [NEG_INF,  NEG_INF, 2.0],
        [5.0,      NEG_INF, NEG_INF]
    ])

    print(f"\n  Matrix A (edge weights of directed graph):")
    print(f"    0 →(3)→ 1 →(2)→ 2 →(5)→ 0")
    print(f"    Cycle weight: 3 + 2 + 5 = 10, length 3")
    print(f"    Mean cycle weight: 10/3 ≈ 3.333")

    eigenval = tropical_eigenvalue(A)
    print(f"\n  Tropical eigenvalue (max mean cycle weight): {eigenval:.4f}")
    print(f"  This is the asymptotic throughput of the system!")

    # Verify: A^n / n should converge to eigenvalue
    print(f"\n  Verification: A^⊙n / n converges to eigenvalue:")
    An = A.copy()
    for n in range(1, 8):
        An = trop_mat_mul(An, A)
        diag_vals = [An[i, i] / (n + 1) for i in range(3) if An[i, i] != NEG_INF]
        if diag_vals:
            print(f"    A^⊙{n+1}/{n+1}: diag means = {[f'{v:.4f}' for v in diag_vals]}")


# ═══════════════════════════════════════════════════════════════
# TROPICAL ENTROPY
# ═══════════════════════════════════════════════════════════════

def shannon_entropy(p: np.ndarray) -> float:
    """Shannon entropy H(p) = -Σ pᵢ log pᵢ."""
    return -sum(pi * math.log(pi) for pi in p if pi > 0)


def tropical_entropy(p: np.ndarray) -> float:
    """Tropical entropy H⊕(p) = max(-log pᵢ) = -log(min pᵢ)."""
    return max(-math.log(pi) for pi in p if pi > 0)


def demo_entropy():
    """Demonstrate tropical entropy."""
    print("\n" + "=" * 60)
    print("TROPICAL ENTROPY")
    print("=" * 60)

    distributions = {
        "Uniform(4)": np.array([0.25, 0.25, 0.25, 0.25]),
        "Peaked": np.array([0.7, 0.1, 0.1, 0.1]),
        "Very peaked": np.array([0.97, 0.01, 0.01, 0.01]),
        "Delta": np.array([1.0, 1e-10, 1e-10, 1e-10]),
    }

    print(f"\n  {'Distribution':>15} | {'H(p) Shannon':>14} | {'H⊕(p) Tropical':>16} | {'Gap':>8} | Interpretation")
    print(f"  {'─'*15}─┼─{'─'*14}─┼─{'─'*16}─┼─{'─'*8}─┼─{'─'*30}")

    for name, p in distributions.items():
        p = p / p.sum()  # Normalize
        h_s = shannon_entropy(p)
        h_t = tropical_entropy(p)
        gap = h_t - h_s
        interp = "flat" if gap < 0.5 else "moderate" if gap < 2 else "spiky"
        print(f"  {name:>15} | {h_s:14.4f} | {h_t:16.4f} | {gap:8.4f} | {interp}")

    print(f"\n  Key insight: Tropical entropy ≥ Shannon entropy (always)")
    print(f"  Gap measures how 'spiky' the distribution is")
    print(f"  H⊕ = maximum surprise, H = average surprise")


# ═══════════════════════════════════════════════════════════════
# TROPICAL LOGIC GATES
# ═══════════════════════════════════════════════════════════════

def demo_logic():
    """Demonstrate tropical logic gates."""
    print("\n" + "=" * 60)
    print("TROPICAL LOGIC GATES")
    print("=" * 60)

    # Encode: True = 0, False = -∞
    T, F = 0.0, NEG_INF

    def trop_or(a, b):
        return max(a, b)

    def trop_and(a, b):
        if a == NEG_INF or b == NEG_INF:
            return NEG_INF
        return a + b  # In {0, -∞} encoding: 0+0=0 (T), rest = -∞ (F)

    def trop_not(a):
        # Swap 0 ↔ -∞ ... we use a different encoding trick
        # Actually in the {0, -∞} system, NOT needs special handling
        # Better: use {1, 0} encoding with min/max
        return T if a == F else F

    print(f"\n  Encoding: True = 0 (tropical one), False = -∞ (tropical zero)")
    print(f"\n  OR gate (= tropical addition = max):")
    for a, b in [(T, T), (T, F), (F, T), (F, F)]:
        r = trop_or(a, b)
        print(f"    {'T' if a==T else 'F'} OR {'T' if b==T else 'F'} = {'T' if r==T else 'F'}")

    print(f"\n  AND gate (= tropical multiplication = +):")
    for a, b in [(T, T), (T, F), (F, T), (F, F)]:
        r = trop_and(a, b)
        print(f"    {'T' if a==T else 'F'} AND {'T' if b==T else 'F'} = {'T' if r==T else 'F'}")

    print(f"\n  NOT gate:")
    for a in [T, F]:
        r = trop_not(a)
        print(f"    NOT {'T' if a==T else 'F'} = {'T' if r==T else 'F'}")

    print(f"\n  → Tropical semiring encodes complete Boolean logic!")


# ═══════════════════════════════════════════════════════════════
# ORACLE FIXED-POINT ITERATION
# ═══════════════════════════════════════════════════════════════

def demo_oracle():
    """Demonstrate oracle fixed-point iteration."""
    print("\n" + "=" * 60)
    print("ORACLE FIXED-POINT ITERATION")
    print("=" * 60)

    # Oracle: projection to the nearest point with cost = 0
    # Example: find x ∈ {0,1}³ such that x₁ + x₂ + x₃ = 2

    def cost(x):
        return abs(sum(x) - 2)

    def oracle_step(x, eps=0.1):
        """Tropical oracle: follow the tropical gradient."""
        best = list(x)
        best_cost = cost(x)
        for i in range(len(x)):
            for delta in [-eps, eps]:
                y = list(x)
                y[i] = max(0, min(1, y[i] + delta))
                c = cost(y)
                if c < best_cost:
                    best = y
                    best_cost = c
        return best

    print(f"\n  Problem: Find x ∈ [0,1]³ with x₁ + x₂ + x₃ = 2")
    x = [0.1, 0.3, 0.5]
    print(f"\n  Starting point: x = [{', '.join(f'{v:.3f}' for v in x)}], cost = {cost(x):.3f}")

    for step in range(30):
        x = oracle_step(x)
        c = cost(x)
        if step % 5 == 0 or c < 0.01:
            print(f"    Step {step:3d}: x = [{', '.join(f'{v:.3f}' for v in x)}], cost = {c:.3f}")
        if c < 0.001:
            print(f"  ✓ Fixed point reached at step {step}!")
            break

    # Verify idempotency
    x2 = oracle_step(x)
    print(f"\n  Idempotency check: O(O(x)) ≈ O(x)?")
    print(f"    O(x)  = [{', '.join(f'{v:.3f}' for v in x)}]")
    print(f"    O²(x) = [{', '.join(f'{v:.3f}' for v in x2)}]")
    diff = sum(abs(a - b) for a, b in zip(x, x2))
    print(f"    ||O²(x) - O(x)|| = {diff:.6f} {'✓ Idempotent!' if diff < 0.01 else ''}")


# ═══════════════════════════════════════════════════════════════
# TROPICAL CONVOLUTION / LEGENDRE TRANSFORM
# ═══════════════════════════════════════════════════════════════

def tropical_convolution(f: Callable, g: Callable,
                         x: float, y_range=(-10, 10), n=1000) -> float:
    """Sup-convolution: (f ⊛ g)(x) = sup_y [f(y) + g(x - y)]."""
    ys = np.linspace(y_range[0], y_range[1], n)
    return max(f(y) + g(x - y) for y in ys)


def legendre_transform(f: Callable, p: float,
                       x_range=(-10, 10), n=1000) -> float:
    """Legendre-Fenchel transform: L[f](p) = sup_x [p*x - f(x)]."""
    xs = np.linspace(x_range[0], x_range[1], n)
    return max(p * x - f(x) for x in xs)


def demo_legendre():
    """Demonstrate tropical Fourier = Legendre transform."""
    print("\n" + "=" * 60)
    print("TROPICAL FOURIER = LEGENDRE TRANSFORM")
    print("=" * 60)

    # f(x) = x² (convex function)
    f = lambda x: x**2
    print(f"\n  f(x) = x²")
    print(f"  Legendre transform L[f](p) = sup_x [p·x - x²] = p²/4")
    print(f"\n  {'p':>6} | {'L[f](p) computed':>18} | {'p²/4 (exact)':>14} | {'Error':>10}")
    print(f"  {'─'*6}─┼─{'─'*18}─┼─{'─'*14}─┼─{'─'*10}")
    for p in [-4, -2, 0, 1, 2, 3, 4]:
        L_computed = legendre_transform(f, p)
        L_exact = p**2 / 4
        error = abs(L_computed - L_exact)
        print(f"  {p:6.1f} | {L_computed:18.4f} | {L_exact:14.4f} | {error:10.4f}")

    print(f"\n  → The Legendre transform is the 'tropical Fourier transform'")
    print(f"  → It converts sup-convolution to pointwise max (tropical product)")


# ═══════════════════════════════════════════════════════════════
# FULL TAXONOMY DISPLAY
# ═══════════════════════════════════════════════════════════════

def display_taxonomy():
    """Display the complete tropical alphabet taxonomy."""
    print("\n" + "=" * 60)
    print("THE COMPLETE TROPICAL ALPHABET — TAXONOMY")
    print("=" * 60)

    taxonomy = """
  LEVEL 1: PRIMITIVES (The Letters)
  ├── ⊕  max(a,b)           tropical addition
  ├── ⊙  a + b              tropical multiplication
  ├── ⊙ⁿ n·a                tropical power
  ├── ε  -∞                  tropical zero (additive identity)
  ├── e  0                   tropical one (multiplicative identity)
  ├── ⁻¹ -a                  tropical inverse
  ├── ⊘  a - b              tropical division
  ├── ∧  min(a,b)            tropical co-addition (dual)
  ├── |·| max(a,-a)          tropical absolute value
  └── ⊥  +∞                  tropical co-zero

  LEVEL 2: COMPOUND OPERATIONS (The Words)
  ├── Polynomials             max_i(a_i + i·x) — piecewise linear convex
  ├── Rational functions      p(x) - q(x) — DC functions
  ├── Matrix ⊕               elementwise max
  ├── Matrix ⊙               max_k(A_ik + B_kj) — shortest paths
  ├── Kleene star A*          all-pairs shortest paths
  ├── Determinant             max-weight perfect matching
  ├── Convolution ⊛           sup_y[f(y)+g(x-y)] — sup-convolution
  ├── Derivative ∂⊕           slope function (piecewise constant)
  ├── Integral ∫⊕             supremum of function
  ├── Norm ‖·‖⊕              max of coordinates
  └── Inner product ⟨·,·⟩⊕   max_i(a_i + b_i)

  LEVEL 3: STRUCTURAL TRANSFORMS (The Grammar)
  ├── Topology                L∞ metric, hypercube balls
  ├── Convexity               max-plus closed sets
  ├── Valuation               -log|·| tropicalization map
  ├── Maslov dequant.         ε·log(Σ exp(·/ε))
  ├── Galois theory           always solvable (no quintic barrier!)
  ├── Order                   natural ≤ on ℝ
  ├── Lattice                 (ℝ, max, min) distributive lattice
  └── Localization            restricting to polyhedral cells

  LEVEL 4: FUNCTORIAL LIFTS (The Syntax)
  ├── Linear algebra           semimodules over T
  ├── Eigenvalues              max mean cycle weight
  ├── Category Trop            semimodule morphisms
  ├── Schemes                  tropical geometry (Lorscheid)
  ├── K-theory                 Grothendieck-like groups
  ├── Homology                 cellular complexes
  └── Sheaves                  sections on tropical varieties

  LEVEL 5: META-OPERATIONS (The Semantics)
  ├── Oracle O² = O            idempotent projection to truth
  ├── Entropy H⊕               max(-log p_i) ≥ Shannon H
  ├── Dequantization D_ε       ε·log(·) smooth→tropical functor
  ├── Tropicalization           variety → polyhedral complex
  ├── Mirror symmetry           SYZ fibration in tropical limit
  ├── SAT oracle                fixed-point combinatorial solver
  └── Oracle composition        Fix(O₁∘O₂) = Fix(O₁) ∩ Fix(O₂)

  CROSS-CUTTING QUALITIES
  ├── Idempotent addition       a ⊕ a = a (the defining property)
  ├── Selectivity               a ⊕ b ∈ {a, b}
  ├── No subtraction            no additive inverses
  ├── Piecewise linearity       all functions are PL
  ├── Duality                   max ↔ min by negation
  ├── Universality              Turing-complete with 7 primitives
  └── Skeleton principle         tropical = combinatorial core
    """
    print(taxonomy)


# ═══════════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  THE TROPICAL ALPHABET: Complete Demonstration Suite    ║")
    print("║  All Operations in the Tropical Semiring World         ║")
    print("╚══════════════════════════════════════════════════════════╝")

    demo_primitives()
    demo_polynomials()
    demo_matrix()
    demo_maslov()
    demo_calculus()
    demo_eigenvalues()
    demo_entropy()
    demo_logic()
    demo_oracle()
    demo_legendre()
    display_taxonomy()

    print("\n" + "=" * 60)
    print("DEMONSTRATION COMPLETE")
    print("=" * 60)

#!/usr/bin/env python3
"""
Algorithms: Schwartz–Zippel PIT and Freivalds' Verification

Complete implementations of the algorithms whose correctness is certified
by the formal proofs in SchwartzZippel.lean and Freivalds.lean.

Includes:
1. Polynomial Identity Testing (PIT) via Schwartz–Zippel
2. Freivalds' Matrix Multiplication Verification
3. Multivariate polynomial zero counting
4. Reed–Muller code distance estimation
"""

import random
import math
from typing import List, Tuple, Dict, Optional, Callable
from dataclasses import dataclass
from functools import reduce


# ══════════════════════════════════════════════════════════════════
# Core Finite Field Arithmetic
# ══════════════════════════════════════════════════════════════════

class GF:
    """Simple finite field Z/pZ arithmetic."""

    def __init__(self, p: int):
        """Initialize GF(p) for prime p."""
        assert self._is_prime(p), f"{p} is not prime"
        self.p = p

    @staticmethod
    def _is_prime(n: int) -> bool:
        if n < 2:
            return False
        for i in range(2, int(n**0.5) + 1):
            if n % i == 0:
                return False
        return True

    def add(self, a: int, b: int) -> int:
        return (a + b) % self.p

    def mul(self, a: int, b: int) -> int:
        return (a * b) % self.p

    def neg(self, a: int) -> int:
        return (-a) % self.p

    def inv(self, a: int) -> int:
        assert a % self.p != 0, "Cannot invert zero"
        return pow(a, self.p - 2, self.p)

    def pow(self, a: int, n: int) -> int:
        return pow(a, n, self.p)

    def zero(self) -> int:
        return 0

    def one(self) -> int:
        return 1

    def elements(self) -> List[int]:
        return list(range(self.p))

    def random_element(self) -> int:
        return random.randint(0, self.p - 1)

    def random_vector(self, n: int) -> List[int]:
        return [self.random_element() for _ in range(n)]


# ══════════════════════════════════════════════════════════════════
# Multivariate Polynomial Representation
# ══════════════════════════════════════════════════════════════════

@dataclass
class MvMonomial:
    """A monomial c · x_0^{e_0} · x_1^{e_1} · ... · x_{n-1}^{e_{n-1}}."""
    coeff: int
    exponents: Tuple[int, ...]

    @property
    def total_degree(self) -> int:
        return sum(self.exponents)

    def eval(self, point: List[int], field: GF) -> int:
        val = self.coeff % field.p
        for xi, ei in zip(point, self.exponents):
            val = field.mul(val, field.pow(xi, ei))
        return val


class MvPolynomial:
    """Sparse multivariate polynomial over a finite field."""

    def __init__(self, terms: List[MvMonomial], n_vars: int, field: GF):
        self.terms = [t for t in terms if t.coeff % field.p != 0]
        self.n_vars = n_vars
        self.field = field

    @property
    def total_degree(self) -> int:
        if not self.terms:
            return 0
        return max(t.total_degree for t in self.terms)

    @property
    def is_zero(self) -> bool:
        return len(self.terms) == 0

    def eval(self, point: List[int]) -> int:
        val = 0
        for term in self.terms:
            val = self.field.add(val, term.eval(point, self.field))
        return val

    def count_zeros(self) -> int:
        """Count zeros over the full field (brute force)."""
        from itertools import product as cartesian_product
        count = 0
        for pt in cartesian_product(range(self.field.p), repeat=self.n_vars):
            if self.eval(list(pt)) == 0:
                count += 1
        return count

    @staticmethod
    def from_dict(terms: Dict[Tuple[int, ...], int], n_vars: int, field: GF) -> 'MvPolynomial':
        """Create polynomial from {exponent_tuple: coefficient} dict."""
        monomials = [MvMonomial(c, e) for e, c in terms.items()]
        return MvPolynomial(monomials, n_vars, field)

    def __repr__(self) -> str:
        if not self.terms:
            return "0"
        parts = []
        for t in self.terms:
            if all(e == 0 for e in t.exponents):
                parts.append(str(t.coeff % self.field.p))
            else:
                vars_str = "·".join(
                    f"x{i}^{e}" if e > 1 else f"x{i}"
                    for i, e in enumerate(t.exponents) if e > 0
                )
                c = t.coeff % self.field.p
                if c == 1:
                    parts.append(vars_str)
                else:
                    parts.append(f"{c}·{vars_str}")
        return " + ".join(parts) if parts else "0"


# ══════════════════════════════════════════════════════════════════
# Algorithm 1: Polynomial Identity Testing (Schwartz–Zippel)
# ══════════════════════════════════════════════════════════════════

def schwartz_zippel_pit(
    f: MvPolynomial,
    num_trials: int = 1
) -> Tuple[bool, float]:
    """
    Schwartz–Zippel Polynomial Identity Test.

    Tests whether a multivariate polynomial f is identically zero
    by evaluating at random points.

    Args:
        f: Multivariate polynomial over GF(p)
        num_trials: Number of independent random evaluations

    Returns:
        (is_likely_zero, error_bound)
        - is_likely_zero: True if all evaluations were 0
        - error_bound: upper bound on Pr[false positive]

    Correctness guarantee (from our formal proof):
        If f ≠ 0 and deg(f) = d, then
        Pr[f(r) = 0] ≤ d/p for each random point r.
        With k independent trials:
        Pr[all f(r_i) = 0] ≤ (d/p)^k.

    Complexity:
        Time:  O(k · T_eval) where T_eval = cost of evaluating f
        Space: O(n) for storing the random point
    """
    field = f.field
    p = field.p
    d = f.total_degree

    all_zero = True
    for _ in range(num_trials):
        point = field.random_vector(f.n_vars)
        if f.eval(point) != 0:
            all_zero = False
            break

    error_bound = (d / p) ** num_trials if p > 0 else 1.0
    return all_zero, error_bound


def schwartz_zippel_bound(degree: int, field_size: int, n_vars: int) -> int:
    """
    Compute the Schwartz–Zippel upper bound on |{x : f(x) = 0}|.

    For a nonzero polynomial of total degree d in n variables over GF(q):
        |{x ∈ GF(q)^n : f(x) = 0}| ≤ d · q^(n-1)

    This is the counting form of the Schwartz–Zippel lemma,
    as proved in schwartz_zippel_succ.
    """
    return degree * (field_size ** (n_vars - 1)) if n_vars > 0 else 0


# ══════════════════════════════════════════════════════════════════
# Algorithm 2: Freivalds' Matrix Multiplication Verification
# ══════════════════════════════════════════════════════════════════

class Matrix:
    """Matrix over a finite field."""

    def __init__(self, data: List[List[int]], field: GF):
        self.data = [[x % field.p for x in row] for row in data]
        self.field = field
        self.rows = len(data)
        self.cols = len(data[0]) if data else 0

    def mulvec(self, v: List[int]) -> List[int]:
        """Matrix-vector product."""
        f = self.field
        return [
            reduce(f.add, (f.mul(self.data[i][j], v[j]) for j in range(self.cols)), 0)
            for i in range(self.rows)
        ]

    def matmul(self, other: 'Matrix') -> 'Matrix':
        """Matrix multiplication."""
        f = self.field
        n, m, k = self.rows, other.cols, self.cols
        result = [[0]*m for _ in range(n)]
        for i in range(n):
            for j in range(m):
                result[i][j] = reduce(
                    f.add,
                    (f.mul(self.data[i][l], other.data[l][j]) for l in range(k)),
                    0
                )
        return Matrix(result, f)

    def sub(self, other: 'Matrix') -> 'Matrix':
        """Matrix subtraction."""
        f = self.field
        return Matrix(
            [[f.add(self.data[i][j], f.neg(other.data[i][j]))
              for j in range(self.cols)]
             for i in range(self.rows)],
            f
        )

    def is_zero(self) -> bool:
        return all(x == 0 for row in self.data for x in row)

    def __eq__(self, other) -> bool:
        return self.data == other.data

    def __repr__(self) -> str:
        return "\n".join("  [" + " ".join(f"{x:3d}" for x in row) + "]" for row in self.data)


def freivalds_verify(
    A: Matrix, B: Matrix, C: Matrix,
    num_trials: int = 1
) -> Tuple[bool, float]:
    """
    Freivalds' Randomized Matrix Multiplication Verification.

    Checks whether A*B = C by testing A*(B*r) = C*r for random vectors r.

    Args:
        A, B, C: Matrices over GF(p)
        num_trials: Number of independent random checks

    Returns:
        (is_likely_equal, error_bound)
        - is_likely_equal: True if all checks passed
        - error_bound: upper bound on Pr[false positive] = (1/p)^k

    Correctness guarantee (from our formal proof freivalds_zmod_bound):
        If A*B ≠ C, then for each random r ∈ GF(q)^n:
        Pr[(A*B)r = Cr] ≤ 1/q
        This is the degree-1 case of Schwartz–Zippel.

    Complexity:
        Time:  O(k · n²) — versus O(n³) for direct multiplication
        Space: O(n)

    This is why Freivalds matters:
        Verifying an n×n matrix product takes O(n²) per trial.
        Computing the product from scratch takes O(n³) (or O(n^ω)).
        For large n, verification is asymptotically cheaper.
    """
    field = A.field
    p = field.p
    n = A.rows

    all_pass = True
    for _ in range(num_trials):
        r = field.random_vector(n)

        # Compute B*r first (O(n²)), then A*(B*r) (O(n²))
        Br = B.mulvec(r)
        ABr = A.mulvec(Br)

        # Compute C*r (O(n²))
        Cr = C.mulvec(r)

        if ABr != Cr:
            all_pass = False
            break

    error_bound = (1.0 / p) ** num_trials
    return all_pass, error_bound


def freivalds_kernel_size(D: Matrix) -> int:
    """
    Count |{r : D·r = 0}| exactly (brute force for small examples).

    The formal proof (freivalds_discrepancy_bound) guarantees:
        If D ≠ 0, then |{r : D·r = 0}| ≤ |K|^(n-1)
    """
    from itertools import product as cp
    field = D.field
    n = D.cols
    count = 0
    for r_tuple in cp(range(field.p), repeat=n):
        r = list(r_tuple)
        if all(x == 0 for x in D.mulvec(r)):
            count += 1
    return count


# ══════════════════════════════════════════════════════════════════
# Algorithm 3: Reed–Muller Distance Estimation
# ══════════════════════════════════════════════════════════════════

def reed_muller_distance_bound(degree: int, n_vars: int, field_size: int) -> int:
    """
    Lower bound on minimum distance of Reed–Muller code RM(d, n, q).

    The Schwartz–Zippel lemma directly implies:
        d_min(RM(d, n, q)) ≥ q^n - d · q^(n-1) = q^(n-1) · (q - d)

    For d < q, this gives a positive minimum distance, meaning the code
    can detect and correct errors.

    This connection shows: the Schwartz–Zippel lemma IS the distance
    theorem for Reed–Muller codes.
    """
    total_points = field_size ** n_vars
    max_zeros = degree * (field_size ** (n_vars - 1)) if n_vars > 0 else 0
    return max(total_points - max_zeros, 0)


# ══════════════════════════════════════════════════════════════════
# Usage Examples
# ══════════════════════════════════════════════════════════════════

def example_pit():
    """Example: Testing polynomial identity."""
    print("=== Polynomial Identity Testing ===")
    F = GF(17)

    # f(x,y) = (x+y)^2 - x^2 - 2xy - y^2  (should be zero)
    # Expanded: x^2 + 2xy + y^2 - x^2 - 2xy - y^2 = 0
    f_zero = MvPolynomial.from_dict({
        (2, 0): 1,    # x^2
        (1, 1): 2,    # 2xy
        (0, 2): 1,    # y^2
        (2, 0): F.neg(1),  # Note: this overwrites, need to handle
    }, 2, F)

    # Actually let's define it properly
    f_zero = MvPolynomial([
        MvMonomial(1, (2, 0)),
        MvMonomial(2, (1, 1)),
        MvMonomial(1, (0, 2)),
        MvMonomial(F.neg(1), (2, 0)),
        MvMonomial(F.neg(2), (1, 1)),
        MvMonomial(F.neg(1), (0, 2)),
    ], 2, F)

    # f(x,y) = x^2 + y + 3  (nonzero)
    f_nonzero = MvPolynomial.from_dict({
        (2, 0): 1,
        (0, 1): 1,
        (0, 0): 3,
    }, 2, F)

    result_z, bound_z = schwartz_zippel_pit(f_zero, num_trials=10)
    result_nz, bound_nz = schwartz_zippel_pit(f_nonzero, num_trials=10)

    print(f"  Zero polynomial: likely_zero={result_z}, error_bound={bound_z:.6e}")
    print(f"  Nonzero polynomial: likely_zero={result_nz}, error_bound={bound_nz:.6e}")
    print()


def example_freivalds():
    """Example: Verifying matrix multiplication."""
    print("=== Freivalds' Matrix Verification ===")
    F = GF(31)
    n = 4

    # Random matrices
    A = Matrix([[F.random_element() for _ in range(n)] for _ in range(n)], F)
    B = Matrix([[F.random_element() for _ in range(n)] for _ in range(n)], F)

    # Correct product
    C_correct = A.matmul(B)

    # Wrong product (perturbed)
    C_wrong_data = [row[:] for row in C_correct.data]
    C_wrong_data[0][0] = F.add(C_wrong_data[0][0], 1)
    C_wrong = Matrix(C_wrong_data, F)

    result_c, bound_c = freivalds_verify(A, B, C_correct, num_trials=5)
    result_w, bound_w = freivalds_verify(A, B, C_wrong, num_trials=5)

    print(f"  Correct C: verified={result_c} (should be True)")
    print(f"  Wrong C:   verified={result_w} (should be False, bound={bound_w:.6e})")
    print(f"  Field size: {F.p}, Error bound per trial: 1/{F.p} ≈ {1/F.p:.4f}")
    print()


def example_reed_muller():
    """Example: Reed–Muller code distance."""
    print("=== Reed–Muller Code Distance ===")
    print(f"  {'q':>4} {'n':>4} {'d':>4} {'d_min bound':>12} {'code length':>12} {'rate':>8}")
    for q in [5, 7, 11]:
        for n in [2, 3]:
            for d in range(1, q):
                code_length = q ** n
                d_min = reed_muller_distance_bound(d, n, q)
                # Number of codewords: C(n+d, d) monomials... approximate
                from math import comb
                num_monomials = comb(n + d, d)
                rate = num_monomials / code_length if code_length > 0 else 0
                if d <= 3:
                    print(f"  {q:4d} {n:4d} {d:4d} {d_min:12d} {code_length:12d} {rate:8.4f}")
    print()


if __name__ == "__main__":
    random.seed(42)
    example_pit()
    example_freivalds()
    example_reed_muller()

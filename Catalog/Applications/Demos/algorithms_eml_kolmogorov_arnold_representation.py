#!/usr/bin/env python3
"""
EML-KA Algorithms: Constructive Kolmogorov-Arnold Decompositions
================================================================

Type-hinted implementations of the core EML-KA algorithms.
"""

from typing import List, Tuple, Callable
import numpy as np
from dataclasses import dataclass

# ---- EML Chain Operations ----

@dataclass
class EMLOp:
    """An elementary EML operation."""
    kind: str  # 'exp', 'log', or 'affine'
    a: float = 0.0
    b: float = 0.0

    def eval(self, x: float) -> float:
        if self.kind == 'exp':
            return np.exp(x)
        elif self.kind == 'log':
            return np.log(x) if x > 0 else float('-inf')
        elif self.kind == 'affine':
            return self.a * x + self.b
        raise ValueError(f"Unknown op kind: {self.kind}")

    def depth(self) -> int:
        return 0 if self.kind == 'affine' else 1


def eval_chain(chain: List[EMLOp], x: float) -> float:
    """Evaluate an EML chain (outermost operation first)."""
    result = x
    for op in reversed(chain):
        result = op.eval(result)
    return result


def chain_depth(chain: List[EMLOp]) -> int:
    """Count transcendental operations in a chain."""
    return sum(op.depth() for op in chain)


# ---- EML-KA Decomposition ----

@dataclass
class EMLKA:
    """A bivariate EML-KA decomposition with Q terms."""
    phi1: List[List[EMLOp]]  # Inner chains for x
    phi2: List[List[EMLOp]]  # Inner chains for y
    Phi: List[List[EMLOp]]   # Outer chains

    @property
    def Q(self) -> int:
        return len(self.phi1)

    def eval(self, x: float, y: float) -> float:
        """Evaluate the decomposition at (x, y)."""
        total = 0.0
        for q in range(self.Q):
            inner = eval_chain(self.phi1[q], x) + eval_chain(self.phi2[q], y)
            total += eval_chain(self.Phi[q], inner)
        return total

    def total_depth(self) -> int:
        """Maximum total chain depth across all terms."""
        return max(
            chain_depth(self.phi1[q]) + chain_depth(self.phi2[q]) + chain_depth(self.Phi[q])
            for q in range(self.Q)
        )


# ---- Constructive Decompositions ----

def scaled_log(a: float) -> List[EMLOp]:
    """Chain for x ↦ a · log(x)."""
    return [EMLOp('affine', a, 0), EMLOp('log')]


def mul_emlka() -> EMLKA:
    """1-term EML-KA for multiplication: x·y = exp(log(x) + log(y))."""
    return EMLKA(
        phi1=[[EMLOp('log')]],
        phi2=[[EMLOp('log')]],
        Phi=[[EMLOp('exp')]]
    )


def monomial_emlka(a: int, b: int) -> EMLKA:
    """1-term EML-KA for x^a · y^b."""
    return EMLKA(
        phi1=[scaled_log(a)],
        phi2=[scaled_log(b)],
        Phi=[[EMLOp('exp')]]
    )


def div_emlka() -> EMLKA:
    """1-term EML-KA for x/y."""
    return EMLKA(
        phi1=[[EMLOp('log')]],
        phi2=[[EMLOp('affine', -1, 0), EMLOp('log')]],
        Phi=[[EMLOp('exp')]]
    )


def add_emlka() -> EMLKA:
    """2-term EML-KA for x + y."""
    return EMLKA(
        phi1=[[], [EMLOp('affine', 0, 0)]],
        phi2=[[EMLOp('affine', 0, 0)], []],
        Phi=[[], []]
    )


def polynomial_emlka(
    coeffs: List[float],
    exps_a: List[int],
    exps_b: List[int]
) -> EMLKA:
    """
    M-term EML-KA for Σ c_i · x^a_i · y^b_i.

    Algorithm:
    1. For each monomial term, create inner chains: slog(a_i), slog(b_i)
    2. Outer chain: affine(c_i, 0) ∘ exp
    3. The sum over terms gives the polynomial evaluation
    """
    M = len(coeffs)
    return EMLKA(
        phi1=[scaled_log(a) for a in exps_a],
        phi2=[scaled_log(b) for b in exps_b],
        Phi=[[EMLOp('affine', c, 0), EMLOp('exp')] for c in coeffs]
    )


def power_mean_chain(r: float) -> Callable[[float, float], float]:
    """
    Compute power mean M_r(x,y) = ((x^r + y^r)/2)^(1/r)
    via EML chains.

    Uses: exp((1/r) · log((exp(r·log(x)) + exp(r·log(y))) / 2))
    """
    def compute(x: float, y: float) -> float:
        u = np.exp(r * np.log(x))  # x^r via EML
        v = np.exp(r * np.log(y))  # y^r via EML
        return np.exp((1/r) * np.log((u + v) / 2))
    return compute


# ---- Log-Space Operations ----

def log_encode(x: float, y: float) -> Tuple[float, float]:
    """Encode (x,y) in log-space."""
    return (np.log(x), np.log(y))


def exp_decode(u: float, v: float) -> Tuple[float, float]:
    """Decode from log-space."""
    return (np.exp(u), np.exp(v))


def log_sum_exp(x: float, y: float) -> float:
    """
    Numerically stable log-sum-exp.
    Satisfies: max(x,y) ≤ LSE(x,y) ≤ max(x,y) + log(2).
    """
    m = max(x, y)
    return m + np.log(np.exp(x - m) + np.exp(y - m))


def fenchel_young_gap(x: float, s: float) -> float:
    """
    Fenchel-Young duality gap: exp(x) + s·log(s) - s - x·s.
    Always ≥ 0, tight at x = log(s).
    """
    return np.exp(x) + s * np.log(s) - s - x * s


# ---- Verification ----

def verify_decomposition(
    decomp: EMLKA,
    target: Callable[[float, float], float],
    test_points: List[Tuple[float, float]],
    tol: float = 1e-10
) -> bool:
    """Verify an EML-KA decomposition matches a target function."""
    for x, y in test_points:
        computed = decomp.eval(x, y)
        expected = target(x, y)
        if abs(computed - expected) > tol:
            print(f"  FAIL at ({x}, {y}): got {computed}, expected {expected}")
            return False
    return True


if __name__ == "__main__":
    test_pts = [(1.5, 2.0), (0.5, 3.0), (2.0, 0.7), (1.0, 1.0)]

    print("Verifying EML-KA decompositions:")

    d_mul = mul_emlka()
    ok = verify_decomposition(d_mul, lambda x, y: x * y, test_pts)
    print(f"  Multiplication (Q={d_mul.Q}, depth={d_mul.total_depth()}): {'PASS' if ok else 'FAIL'}")

    d_div = div_emlka()
    ok = verify_decomposition(d_div, lambda x, y: x / y, test_pts)
    print(f"  Division (Q={d_div.Q}, depth={d_div.total_depth()}): {'PASS' if ok else 'FAIL'}")

    d_add = add_emlka()
    ok = verify_decomposition(d_add, lambda x, y: x + y, test_pts)
    print(f"  Addition (Q={d_add.Q}, depth={d_add.total_depth()}): {'PASS' if ok else 'FAIL'}")

    d_mon = monomial_emlka(2, 3)
    ok = verify_decomposition(d_mon, lambda x, y: x**2 * y**3, test_pts)
    print(f"  x²y³ (Q={d_mon.Q}, depth={d_mon.total_depth()}): {'PASS' if ok else 'FAIL'}")

    d_poly = polynomial_emlka([3, 2, 1], [2, 1, 0], [1, 2, 1])
    ok = verify_decomposition(d_poly, lambda x, y: 3*x**2*y + 2*x*y**2 + y, test_pts)
    print(f"  3x²y+2xy²+y (Q={d_poly.Q}, depth={d_poly.total_depth()}): {'PASS' if ok else 'FAIL'}")

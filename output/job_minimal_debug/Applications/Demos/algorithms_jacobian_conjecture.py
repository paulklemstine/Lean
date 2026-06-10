#!/usr/bin/env python3
"""
Keller Map Reduction: Core Algorithms

Implements the computational methods from the research paper:
1. Jacobian matrix and determinant computation
2. Linear part extraction
3. Normalization to identity linear part
4. Cubic homogeneous detection
5. Formal inverse reconstruction
6. Nilpotency checking for Drużkowski matrices

All algorithms operate on polynomial maps represented as
dictionaries mapping monomial exponent tuples to coefficients.
"""

import numpy as np
from typing import Dict, Tuple, List, Optional
from dataclasses import dataclass


# Type aliases
Monomial = Tuple[int, ...]
Polynomial = Dict[Monomial, float]
PolyMapType = List[Polynomial]


@dataclass
class NormalizationResult:
    """Result of normalizing a polynomial map to identity linear part."""
    normalized_map: PolyMapType
    linear_part: np.ndarray
    linear_part_inv: np.ndarray
    success: bool


@dataclass
class InverseResult:
    """Result of formal inverse reconstruction."""
    inverse_map: PolyMapType
    residual: float
    max_degree_used: int
    success: bool


def zero_monomial(n: int) -> Monomial:
    """The zero monomial (constant term)."""
    return tuple(0 for _ in range(n))


def unit_monomial(n: int, j: int) -> Monomial:
    """The j-th unit monomial x_j."""
    return tuple(1 if k == j else 0 for k in range(n))


def monomial_degree(m: Monomial) -> int:
    """Total degree of a monomial."""
    return sum(m)


def poly_add(p: Polynomial, q: Polynomial) -> Polynomial:
    """Add two polynomials."""
    result = dict(p)
    for m, c in q.items():
        result[m] = result.get(m, 0) + c
    return {k: v for k, v in result.items() if abs(v) > 1e-14}


def poly_scale(c: float, p: Polynomial) -> Polynomial:
    """Scale a polynomial by a constant."""
    return {m: c * v for m, v in p.items() if abs(c * v) > 1e-14}


def poly_mul(p: Polynomial, q: Polynomial, n: int) -> Polynomial:
    """Multiply two polynomials."""
    result: Polynomial = {}
    for m1, c1 in p.items():
        for m2, c2 in q.items():
            new_m = tuple(m1[i] + m2[i] for i in range(n))
            result[new_m] = result.get(new_m, 0) + c1 * c2
    return {k: v for k, v in result.items() if abs(v) > 1e-14}


def poly_pow(p: Polynomial, exp: int, n: int) -> Polynomial:
    """Compute p^exp."""
    if exp == 0:
        return {zero_monomial(n): 1.0}
    result = dict(p)
    for _ in range(exp - 1):
        result = poly_mul(result, p, n)
    return result


def poly_eval(p: Polynomial, x: np.ndarray) -> float:
    """Evaluate polynomial at a point."""
    val = 0.0
    for m, c in p.items():
        term = c
        for j, e in enumerate(m):
            if e > 0:
                term *= x[j] ** e
        val += term
    return val


def identity_polymap(n: int) -> PolyMapType:
    """The identity polynomial map."""
    return [{unit_monomial(n, i): 1.0} for i in range(n)]


# ============================================================
# Algorithm 1: Jacobian Matrix Computation
# ============================================================

def partial_deriv(p: Polynomial, var: int, n: int) -> Polynomial:
    """Compute ∂p/∂x_{var}.
    
    Time: O(|p|) where |p| is the number of monomials.
    Space: O(|p|).
    """
    result: Polynomial = {}
    for m, c in p.items():
        e = m[var]
        if e == 0:
            continue
        new_m = list(m)
        new_m[var] = e - 1
        result[tuple(new_m)] = c * e
    return result


def jacobian_matrix(F: PolyMapType, n: int) -> List[List[Polynomial]]:
    """Compute the symbolic Jacobian matrix.
    
    Returns J where J[i][j] = ∂F_i/∂x_j.
    Time: O(n² · max|F_i|).
    """
    return [[partial_deriv(F[i], j, n) for j in range(n)] for i in range(n)]


def jacobian_det_at_point(F: PolyMapType, n: int, x: np.ndarray) -> float:
    """Evaluate the Jacobian determinant at a point.
    
    Time: O(n² · max|F_i| + n³) for evaluation + determinant.
    """
    J = jacobian_matrix(F, n)
    J_num = np.array([[poly_eval(J[i][j], x) for j in range(n)] for i in range(n)])
    return np.linalg.det(J_num)


# ============================================================
# Algorithm 2: Linear Part Extraction
# ============================================================

def extract_linear_part(F: PolyMapType, n: int) -> np.ndarray:
    """Extract the n×n linear part matrix.
    
    Entry (i,j) = coefficient of x_j in F_i.
    Time: O(n² · max|F_i|).
    """
    L = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            m = unit_monomial(n, j)
            L[i][j] = F[i].get(m, 0.0)
    return L


# ============================================================
# Algorithm 3: Keller Condition Check
# ============================================================

def check_keller(F: PolyMapType, n: int, num_points: int = 30,
                 tol: float = 1e-8) -> Tuple[bool, Optional[float]]:
    """Check if det(JF) is constant (Keller condition).
    
    Uses random sampling. Not a proof, but a reliable heuristic.
    Time: O(num_points · (n² · max|F_i| + n³)).
    """
    dets = [jacobian_det_at_point(F, n, np.random.randn(n)) for _ in range(num_points)]
    dets = np.array(dets)
    if np.std(dets) < tol:
        return True, float(np.mean(dets))
    return False, None


# ============================================================
# Algorithm 4: Normalization to Identity Linear Part
# ============================================================

def substitute_linear(p: Polynomial, A: np.ndarray, n: int) -> Polynomial:
    """Substitute x_j -> Σ_l A[j][l] x_l into polynomial p.
    
    Time: O(|p| · n^d) where d is max degree.
    """
    result: Polynomial = {}
    for m, c in p.items():
        expanded = {zero_monomial(n): 1.0}
        for j, e in enumerate(m):
            if e == 0:
                continue
            linear = {unit_monomial(n, l): A[j][l] for l in range(n) if abs(A[j][l]) > 1e-14}
            power = poly_pow(linear, e, n)
            expanded = poly_mul(expanded, power, n)
        for em, ec in expanded.items():
            result[em] = result.get(em, 0) + c * ec
    return {k: v for k, v in result.items() if abs(v) > 1e-14}


def normalize_keller_map(F: PolyMapType, n: int) -> NormalizationResult:
    """Normalize a polynomial map to have identity linear part.
    
    Given F with invertible linear part L, computes G = F ∘ L⁻¹.
    
    Time: O(n · max|F_i| · n^d) where d is max degree of F.
    """
    L = extract_linear_part(F, n)
    det_L = np.linalg.det(L)
    
    if abs(det_L) < 1e-12:
        return NormalizationResult(F, L, np.eye(n), False)
    
    L_inv = np.linalg.inv(L)
    G = [substitute_linear(F[i], L_inv, n) for i in range(n)]
    
    return NormalizationResult(G, L, L_inv, True)


# ============================================================
# Algorithm 5: Cubic Homogeneous Detection
# ============================================================

def is_cubic_homogeneous(F: PolyMapType, n: int, tol: float = 1e-12) -> bool:
    """Check if F = Id + H where H is homogeneous of degree 3.
    
    Time: O(n · max|F_i|).
    """
    for i in range(n):
        for m, c in F[i].items():
            d = monomial_degree(m)
            if m == unit_monomial(n, i):
                if abs(c - 1.0) > tol:
                    return False
                continue
            if abs(c) > tol and d != 3:
                return False
    return True


# ============================================================
# Algorithm 6: Formal Inverse Reconstruction
# ============================================================

def formal_inverse(F: PolyMapType, n: int, max_deg: int = 8) -> InverseResult:
    """Reconstruct the formal inverse of F = Id + H.
    
    Uses the Neumann series: G = Id - H + H∘H - H∘H∘H + ...
    implemented via iterative composition G_{k+1} = Id - H(G_k).
    
    Time: O(max_deg · n · |H|^{max_deg}).
    Convergence: Exact for nilpotent JH after finitely many steps.
    """
    # Extract H = F - Id
    H = []
    for i in range(n):
        h = dict(F[i])
        m_id = unit_monomial(n, i)
        h[m_id] = h.get(m_id, 0) - 1.0
        H.append({k: v for k, v in h.items() if abs(v) > 1e-14})
    
    # Iterate: G_{k+1} = Id - H(G_k)
    G = identity_polymap(n)
    
    for _ in range(max_deg):
        new_G = []
        for i in range(n):
            # G_i = x_i - H_i(G)
            new_poly = {unit_monomial(n, i): 1.0}
            h_composed = compose_truncated(H[i], G, n, max_deg)
            for m, c in h_composed.items():
                new_poly[m] = new_poly.get(m, 0) - c
            new_G.append({k: v for k, v in new_poly.items() if abs(v) > 1e-14})
        G = new_G
    
    # Check residual
    residual = check_residual(F, G, n)
    
    return InverseResult(G, residual, max_deg, residual < 1e-6)


def compose_truncated(p: Polynomial, G: PolyMapType, n: int, max_deg: int) -> Polynomial:
    """Compose polynomial p with map G, truncating at max_deg."""
    result: Polynomial = {}
    for m, c in p.items():
        if monomial_degree(m) > max_deg:
            continue
        term = {zero_monomial(n): c}
        for j, e in enumerate(m):
            if e == 0:
                continue
            gj_pow = poly_pow(G[j], e, n)
            term = poly_mul(term, gj_pow, n)
        for em, ec in term.items():
            if monomial_degree(em) <= max_deg:
                result[em] = result.get(em, 0) + ec
    return {k: v for k, v in result.items() if abs(v) > 1e-14}


def check_residual(F: PolyMapType, G: PolyMapType, n: int, num_points: int = 20) -> float:
    """Check ||F(G(x)) - x|| at random points."""
    total = 0.0
    for _ in range(num_points):
        x = np.random.randn(n) * 0.5
        gx = np.array([poly_eval(G[i], x) for i in range(n)])
        fgx = np.array([poly_eval(F[i], gx) for i in range(n)])
        total += np.linalg.norm(fgx - x)
    return total / num_points


# ============================================================
# Algorithm 7: Drużkowski Map Construction
# ============================================================

def druzkowski_map(A: np.ndarray) -> PolyMapType:
    """Construct F(x) = x + (Ax)^[3].
    
    Time: O(n³) for the cubic expansion.
    """
    n = A.shape[0]
    F = []
    for i in range(n):
        poly: Polynomial = {unit_monomial(n, i): 1.0}
        linear = {unit_monomial(n, j): A[i][j] for j in range(n) if abs(A[i][j]) > 1e-14}
        cubic = poly_pow(linear, 3, n)
        for m, c in cubic.items():
            poly[m] = poly.get(m, 0) + c
        F.append({k: v for k, v in poly.items() if abs(v) > 1e-14})
    return F


# ============================================================
# Algorithm 8: Matrix Nilpotency Check
# ============================================================

def nilpotency_index(A: np.ndarray, tol: float = 1e-10) -> Optional[int]:
    """Find the nilpotency index of a matrix, or None if not nilpotent.
    
    Returns the smallest k such that A^k = 0, or None.
    Time: O(n^3 · n) worst case.
    """
    n = A.shape[0]
    power = np.eye(n)
    for k in range(1, n + 2):
        power = power @ A
        if np.linalg.norm(power) < tol:
            return k
    return None


if __name__ == "__main__":
    np.random.seed(42)
    
    # Example: 3x3 Drużkowski map
    A = np.array([[0, 1, 0], [0, 0, 1], [0, 0, 0]], dtype=float)
    n = 3
    
    print("=== Drużkowski Map Example ===")
    print(f"Matrix A:\n{A}")
    print(f"Nilpotency index: {nilpotency_index(A)}")
    
    F = druzkowski_map(A)
    print(f"\nKeller check: {check_keller(F, n)}")
    print(f"Cubic homogeneous: {is_cubic_homogeneous(F, n)}")
    
    norm = normalize_keller_map(F, n)
    print(f"Normalization success: {norm.success}")
    
    inv = formal_inverse(F, n, max_deg=10)
    print(f"Inverse reconstruction: success={inv.success}, residual={inv.residual:.2e}")

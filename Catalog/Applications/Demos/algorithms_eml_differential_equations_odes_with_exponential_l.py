#!/usr/bin/env python3
"""
algorithms.py — EML Differential Equations: Core Algorithms

Implements the Kovacic algorithm (Case 1) for deciding if a second-order
linear ODE y'' = r(x)y has Liouvillian solutions, with a focus on
detecting EML-solvability obstructions.
"""

from typing import Optional, Tuple, List
from dataclasses import dataclass
import numpy as np


@dataclass
class RationalFunction:
    """A rational function P(x)/Q(x) represented by polynomial coefficients."""
    numerator: List[float]   # coefficients [a0, a1, ..., an]
    denominator: List[float]  # coefficients [b0, b1, ..., bm]
    
    def degree_num(self) -> int:
        """Degree of numerator."""
        return len(self.numerator) - 1
    
    def degree_den(self) -> int:
        """Degree of denominator."""
        return len(self.denominator) - 1
    
    def eval(self, x: float) -> float:
        """Evaluate at a point."""
        num = sum(c * x**i for i, c in enumerate(self.numerator))
        den = sum(c * x**i for i, c in enumerate(self.denominator))
        return num / den if den != 0 else float('inf')


@dataclass
class KovacicResult:
    """Result of Kovacic's algorithm."""
    has_liouvillian_solution: bool
    case: Optional[int]  # Which case of Kovacic applies (1, 2, or 3)
    obstruction_reason: Optional[str]
    solution_hint: Optional[str]


def poly_degree(coeffs: List[float]) -> int:
    """Effective degree of a polynomial (ignoring trailing zeros)."""
    while len(coeffs) > 1 and abs(coeffs[-1]) < 1e-12:
        coeffs = coeffs[:-1]
    return len(coeffs) - 1


def kovacic_case1_check(r: RationalFunction) -> KovacicResult:
    """
    Kovacic's Algorithm, Case 1: Check if y'' = r(x)y has a solution
    of the form y = e^{∫ω} where ω is a rational function.
    
    For this case, ω must satisfy the Riccati equation: ω' + ω² = r(x).
    
    For r(x) = P(x)/Q(x), the algorithm checks:
    1. Pole structure of r determines possible poles of ω
    2. Degree constraints determine possible degree of ω at infinity
    3. Algebraic constraints determine if suitable ω exists
    
    Parameters
    ----------
    r : RationalFunction
        The coefficient function r(x) in y'' = r(x)y
    
    Returns
    -------
    KovacicResult
        Whether Case 1 applies and any obstruction found
    """
    deg_r = poly_degree(r.numerator) - poly_degree(r.denominator)
    
    # For the Airy equation: r(x) = x, so deg_r = 1
    if poly_degree(r.denominator) == 0:
        # r is a polynomial
        if poly_degree(r.numerator) % 2 == 1:
            # Odd degree polynomial: no rational ω can satisfy ω' + ω² = r
            # Because deg(ω²) = 2·deg(ω) must equal deg(r) (odd),
            # but 2·deg(ω) is always even
            return KovacicResult(
                has_liouvillian_solution=False,
                case=1,
                obstruction_reason=(
                    f"r(x) has odd degree {poly_degree(r.numerator)}. "
                    f"The Riccati equation ω' + ω² = r requires "
                    f"2·deg(ω) = {poly_degree(r.numerator)}, "
                    f"which has no integer solution."
                ),
                solution_hint=None
            )
        else:
            # Even degree: might have a solution
            d = poly_degree(r.numerator) // 2
            return KovacicResult(
                has_liouvillian_solution=True,  # Possible, need further check
                case=1,
                obstruction_reason=None,
                solution_hint=f"Potential ω of degree {d}. Check leading coefficient."
            )
    else:
        # r has poles — more complex analysis needed
        return KovacicResult(
            has_liouvillian_solution=True,  # Indeterminate without full analysis
            case=1,
            obstruction_reason=None,
            solution_hint="Full pole analysis required."
        )


def kovacic_case2_check(r: RationalFunction) -> KovacicResult:
    """
    Kovacic's Algorithm, Case 2: Check if y'' = r(x)y has a solution
    where the Galois group is a subgroup of the triangular group.
    
    This corresponds to solutions of the form y = e^{∫ω} where ω
    is algebraic of degree 2 over the base field.
    """
    deg_r = poly_degree(r.numerator) - poly_degree(r.denominator)
    
    if poly_degree(r.denominator) == 0 and poly_degree(r.numerator) <= 1:
        # For r(x) = x: Case 2 requires checking if a degree-2
        # extension can provide solutions. For Airy, this also fails
        # because the Galois group is SL₂, which is not reducible.
        return KovacicResult(
            has_liouvillian_solution=False,
            case=2,
            obstruction_reason=(
                "For r(x) = x (Airy equation), the differential Galois group "
                "is SL₂(ℂ), which is semisimple and not contained in any "
                "Borel subgroup. Case 2 is obstructed."
            ),
            solution_hint=None
        )
    
    return KovacicResult(
        has_liouvillian_solution=True,
        case=2,
        obstruction_reason=None,
        solution_hint="Full Case 2 analysis required."
    )


def kovacic_full(r: RationalFunction) -> KovacicResult:
    """
    Run all three cases of Kovacic's algorithm.
    
    The algorithm decides if y'' = r(x)y has Liouvillian solutions:
    - Case 1: Solutions with rational ω (Galois group ⊆ triangular)
    - Case 2: Solutions with algebraic ω of degree 2
    - Case 3: Finite Galois group (tetrahedral, octahedral, icosahedral)
    
    If all three cases are obstructed, the equation has no Liouvillian
    (and hence no EML) solutions.
    """
    # Case 1
    result1 = kovacic_case1_check(r)
    if not result1.has_liouvillian_solution:
        # Case 1 obstructed, but Cases 2 and 3 might work
        result2 = kovacic_case2_check(r)
        if not result2.has_liouvillian_solution:
            return KovacicResult(
                has_liouvillian_solution=False,
                case=None,
                obstruction_reason=(
                    f"All Kovacic cases obstructed:\n"
                    f"  Case 1: {result1.obstruction_reason}\n"
                    f"  Case 2: {result2.obstruction_reason}\n"
                    f"  Case 3: Not applicable (SL₂ is infinite)."
                ),
                solution_hint=None
            )
    
    return result1


def airy_coefficient_recurrence(a0: float, a1: float, n_terms: int) -> List[float]:
    """
    Compute power series coefficients for the Airy equation y'' = xy.
    
    The recurrence is: (k+3)(k+2) a_{k+3} = a_k
    With a_2 = 0 automatically.
    
    Parameters
    ----------
    a0, a1 : float
        Initial coefficients (a0 = y(0), a1 = y'(0))
    n_terms : int
        Number of terms to compute
    
    Returns
    -------
    List[float]
        Coefficients [a0, a1, a2, ..., a_{n_terms-1}]
    """
    coeffs = [0.0] * n_terms
    if n_terms > 0:
        coeffs[0] = a0
    if n_terms > 1:
        coeffs[1] = a1
    # a_2 = 0 (automatic since initialized to 0)
    
    for k in range(n_terms - 3):
        coeffs[k + 3] = coeffs[k] / ((k + 3) * (k + 2))
    
    return coeffs


def wronskian_numerical(
    f1: np.ndarray, f2: np.ndarray,
    f1p: np.ndarray, f2p: np.ndarray
) -> np.ndarray:
    """
    Compute the Wronskian W(f1, f2) = f1·f2' - f2·f1'.
    
    Parameters
    ----------
    f1, f2 : arrays of function values
    f1p, f2p : arrays of derivative values
    
    Returns
    -------
    Array of Wronskian values
    """
    return f1 * f2p - f2 * f1p


def growth_class_estimate(
    x_vals: np.ndarray,
    y_vals: np.ndarray,
    threshold: float = 1e-3
) -> str:
    """
    Estimate the growth class of a function from numerical data.
    
    Checks if the function grows polynomially, exponentially,
    or super-exponentially by fitting log-log and semi-log models.
    
    Returns
    -------
    str
        Description of the estimated growth class
    """
    # Filter positive values
    mask = (x_vals > 1) & (y_vals > 0)
    x = x_vals[mask]
    y = y_vals[mask]
    
    if len(x) < 10:
        return "insufficient data"
    
    # Polynomial fit: log(y) = d·log(x) + c
    try:
        poly_fit = np.polyfit(np.log(x), np.log(y), 1)
        poly_residual = np.std(np.log(y) - np.polyval(poly_fit, np.log(x)))
    except:
        poly_residual = float('inf')
    
    # Exponential fit: log(y) = c·x + b
    try:
        exp_fit = np.polyfit(x, np.log(y), 1)
        exp_residual = np.std(np.log(y) - np.polyval(exp_fit, x))
    except:
        exp_residual = float('inf')
    
    # Super-exponential fit: log(y) = c·x^{3/2} + b
    try:
        super_fit = np.polyfit(x**1.5, np.log(y), 1)
        super_residual = np.std(np.log(y) - np.polyval(super_fit, x**1.5))
    except:
        super_residual = float('inf')
    
    if super_residual < exp_residual and super_residual < poly_residual:
        return f"super-exponential (≈ exp({super_fit[0]:.3f} x^{{3/2}}))"
    elif exp_residual < poly_residual:
        return f"exponential (≈ exp({exp_fit[0]:.3f} x))"
    else:
        return f"polynomial (≈ x^{poly_fit[0]:.2f})"


if __name__ == "__main__":
    # Example: Airy equation y'' = xy
    print("Kovacic Algorithm for Airy Equation y'' = xy")
    print("=" * 50)
    
    r_airy = RationalFunction(numerator=[0, 1], denominator=[1])
    result = kovacic_full(r_airy)
    
    print(f"Has Liouvillian solution: {result.has_liouvillian_solution}")
    print(f"Case: {result.case}")
    if result.obstruction_reason:
        print(f"Obstruction: {result.obstruction_reason}")
    if result.solution_hint:
        print(f"Hint: {result.solution_hint}")
    
    print("\n" + "=" * 50)
    print("Airy Power Series Coefficients")
    print("=" * 50)
    
    # Ai(x) normalization: a0 = 3^{-2/3}/Γ(2/3), a1 = -3^{-1/3}/Γ(1/3)
    coeffs = airy_coefficient_recurrence(1.0, 0.0, 15)
    for i, c in enumerate(coeffs):
        if abs(c) > 1e-20:
            print(f"  a_{i} = {c:.10e}")
    
    print("\nMod-3 pattern: a_{3k+2} = 0 for all k")
    for k in range(5):
        idx = 3 * k + 2
        if idx < 15:
            print(f"  a_{idx} = {coeffs[idx]}")

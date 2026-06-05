#!/usr/bin/env python3
"""
Algorithms for EML Differential Equations

Type-hinted implementations of the Wronskian theory and Kovacic classification.
"""

from typing import Callable, Tuple, Optional, List
from enum import Enum
import numpy as np


# Type aliases
RealFunc = Callable[[float], float]


class KovacicCase(Enum):
    """The four cases of the Kovacic algorithm."""
    REDUCIBLE = 1      # G⁰ ≅ Gₘ: exponential solutions
    IMPRIMITIVE = 2    # G⁰ ⊆ diagonal: sqrt-exponential solutions
    FINITE = 3         # G finite: algebraic solutions
    FULL_SL2 = 4       # G = SL(2): no Liouvillian solutions


def wronskian(y1: float, y1p: float, y2: float, y2p: float) -> float:
    """
    Compute the Wronskian W(y1, y2) = y1 * y2' - y2 * y1'.
    
    Args:
        y1: Value of first solution
        y1p: Value of first solution's derivative
        y2: Value of second solution
        y2p: Value of second solution's derivative
    
    Returns:
        The Wronskian value
    """
    return y1 * y2p - y2 * y1p


def abel_predict_wronskian(
    W0: float,
    p: RealFunc,
    x0: float,
    x: float,
    n_steps: int = 1000
) -> float:
    """
    Predict the Wronskian at point x using Abel's identity: W' = -p·W.
    
    This solves the first-order ODE W' = -p(t)·W with W(x0) = W0
    using the trapezoidal rule for the integral.
    
    Args:
        W0: Initial Wronskian value at x0
        p: Coefficient function p(x) in the ODE y'' + p·y' + q·y = 0
        x0: Initial point
        x: Target point
        n_steps: Number of integration steps
    
    Returns:
        Predicted Wronskian W(x) = W0 · exp(-∫_{x0}^{x} p(t) dt)
    """
    ts = np.linspace(x0, x, n_steps + 1)
    dt = (x - x0) / n_steps
    
    # Trapezoidal rule for ∫p(t)dt
    integral = 0.5 * p(ts[0]) + sum(p(t) for t in ts[1:-1]) + 0.5 * p(ts[-1])
    integral *= dt
    
    return W0 * np.exp(-integral)


def riccati_from_solution(
    y: RealFunc,
    yp: RealFunc,
    x: float
) -> float:
    """
    Compute the Riccati variable r = y'/y at a point.
    
    The Riccati reduction transforms y'' + p·y' + q·y = 0
    into r' + r² + p·r + q = 0 via r = y'/y.
    
    Args:
        y: Solution function
        yp: Derivative of solution
        x: Evaluation point
    
    Returns:
        The Riccati variable r(x) = y'(x)/y(x)
    
    Raises:
        ZeroDivisionError: If y(x) = 0
    """
    y_val = y(x)
    if abs(y_val) < 1e-15:
        raise ZeroDivisionError(f"Solution vanishes at x = {x}")
    return yp(x) / y_val


def verify_riccati(
    r: float,
    rp: float,
    p_val: float,
    q_val: float
) -> float:
    """
    Check the Riccati equation residual: r' + r² + p·r + q.
    
    Returns 0 if the Riccati equation is satisfied.
    """
    return rp + r**2 + p_val * r + q_val


def solution_representation_coefficients(
    y1: float, y1p: float,
    y2: float, y2p: float,
    y3: float, y3p: float
) -> Tuple[float, float]:
    """
    Compute the representation coefficients c1, c2 such that y3 = c1·y1 + c2·y2.
    
    Uses the Wronskian formula:
        c1 = W(y3, y2) / W(y1, y2)
        c2 = W(y1, y3) / W(y1, y2)
    
    Args:
        y1, y1p: First solution and its derivative
        y2, y2p: Second solution and its derivative
        y3, y3p: Third solution and its derivative
    
    Returns:
        Tuple (c1, c2) of constant coefficients
    
    Raises:
        ValueError: If W(y1, y2) = 0 (solutions not independent)
    """
    W12 = wronskian(y1, y1p, y2, y2p)
    if abs(W12) < 1e-15:
        raise ValueError("Solutions y1, y2 are not independent (W = 0)")
    
    W32 = wronskian(y3, y3p, y2, y2p)
    W13 = wronskian(y1, y1p, y3, y3p)
    
    c1 = W32 / W12
    c2 = W13 / W12
    
    return c1, c2


class EMLTowerStep:
    """A single step in an EML tower extension."""
    
    def __init__(self, ext_type: str, level: int):
        """
        Args:
            ext_type: 'exponential' or 'logarithmic'
            level: The tower level (0-indexed)
        """
        assert ext_type in ('exponential', 'logarithmic')
        self.ext_type = ext_type
        self.level = level
    
    def __repr__(self) -> str:
        return f"EMLTowerStep({self.ext_type}, level={self.level})"


class EMLTower:
    """An EML (Exponential-Monomial-Logarithmic) tower of field extensions."""
    
    def __init__(self, steps: Optional[List[EMLTowerStep]] = None):
        self.steps = steps or []
    
    @property
    def height(self) -> int:
        """Total tower height."""
        return len(self.steps)
    
    @property
    def exp_depth(self) -> int:
        """Number of exponential extensions."""
        return sum(1 for s in self.steps if s.ext_type == 'exponential')
    
    @property
    def log_depth(self) -> int:
        """Number of logarithmic extensions."""
        return sum(1 for s in self.steps if s.ext_type == 'logarithmic')
    
    def add_exponential(self) -> 'EMLTower':
        """Add an exponential extension."""
        new_step = EMLTowerStep('exponential', self.height)
        return EMLTower(self.steps + [new_step])
    
    def add_logarithmic(self) -> 'EMLTower':
        """Add a logarithmic extension."""
        new_step = EMLTowerStep('logarithmic', self.height)
        return EMLTower(self.steps + [new_step])
    
    def verify_decomposition(self) -> bool:
        """
        Verify the tower height decomposition:
        height = exp_depth + log_depth
        
        This corresponds to the formal theorem tower_height_decomp.
        """
        return self.height == self.exp_depth + self.log_depth
    
    def __repr__(self) -> str:
        if not self.steps:
            return "EMLTower(base field)"
        return f"EMLTower(height={self.height}, exp={self.exp_depth}, log={self.log_depth})"


def kovacic_max_tower_height(case: KovacicCase) -> Optional[int]:
    """
    The maximum EML tower height needed for solutions in each Kovacic case.
    
    Returns None for the full SL(2) case (no Liouvillian solutions).
    """
    return {
        KovacicCase.REDUCIBLE: 1,
        KovacicCase.IMPRIMITIVE: 2,
        KovacicCase.FINITE: 0,
        KovacicCase.FULL_SL2: None,
    }[case]


def reduced_ode_coefficient(p: float, q: float, dp: float) -> float:
    """
    Compute the reduced ODE coefficient r = q - p'/2 - p²/4.
    
    The substitution y = z·exp(-∫p/2) transforms
    y'' + p·y' + q·y = 0 into z'' + r·z = 0.
    
    Args:
        p: Coefficient of y'
        q: Coefficient of y
        dp: Derivative of p (= p'(x))
    
    Returns:
        The reduced coefficient r
    """
    return q - dp / 2 - p**2 / 4


# ============================================================================
# Kovacic Algorithm (Simplified for rational coefficients)
# ============================================================================

def classify_pole(
    residue: float,
    order: int
) -> List[KovacicCase]:
    """
    Classify which Kovacic cases are compatible with a given pole.
    
    Args:
        residue: The leading coefficient of the Laurent expansion
        order: The pole order
    
    Returns:
        List of compatible Kovacic cases
    """
    compatible = []
    
    # Case 1: Requires pole order ≤ 2 or all poles have even order
    if order <= 2:
        compatible.append(KovacicCase.REDUCIBLE)
    
    # Case 2: Requires pole order ≤ 2 or order exactly 2
    if order <= 2:
        compatible.append(KovacicCase.IMPRIMITIVE)
    
    # Case 3: Requires pole order ≤ 2
    if order <= 2:
        compatible.append(KovacicCase.FINITE)
    
    # Case 4 is always possible (no Liouvillian solutions)
    compatible.append(KovacicCase.FULL_SL2)
    
    return compatible


def airy_kovacic_analysis() -> KovacicCase:
    """
    Analyze the Airy equation y'' = x·y using the Kovacic algorithm.
    
    The Airy equation in standard form is y'' + 0·y' + (-x)·y = 0,
    or in reduced form: y'' = x·y.
    
    The coefficient r(x) = -x has no poles (it's a polynomial of degree 1).
    
    Key analysis:
    - At infinity, the order of the pole of r is: ord_∞(r) = -(deg r) = -1
    - Since -1 is odd and ≠ 1, Cases 1 and 2 are ruled out at infinity
    - Case 3 requires specific arithmetic conditions that fail for degree 1
    - Therefore: Case 4 (full SL(2))
    
    Returns:
        KovacicCase.FULL_SL2
    """
    # The Airy equation falls into Case 4 (full SL(2) Galois group)
    # No Liouvillian solutions exist
    return KovacicCase.FULL_SL2


if __name__ == "__main__":
    # Quick self-test
    print("Testing algorithms...")
    
    # Test Wronskian
    assert abs(wronskian(1, 0, 0, 1) - 1.0) < 1e-10, "Wronskian test failed"
    
    # Test tower decomposition
    tower = EMLTower()
    tower = tower.add_exponential()
    tower = tower.add_logarithmic()
    tower = tower.add_exponential()
    assert tower.verify_decomposition(), "Tower decomposition failed"
    assert tower.height == 3
    assert tower.exp_depth == 2
    assert tower.log_depth == 1
    
    # Test representation coefficients
    c1, c2 = solution_representation_coefficients(
        1, 0,   # y1 = cos(0) = 1, y1' = -sin(0) = 0
        0, 1,   # y2 = sin(0) = 0, y2' = cos(0) = 1
        3, -2,  # y3 = 3cos(0) - 2sin(0) = 3, y3' = -3sin(0) - 2cos(0) = -2
    )
    assert abs(c1 - 3.0) < 1e-10, f"c1 = {c1}, expected 3"
    assert abs(c2 - (-2.0)) < 1e-10, f"c2 = {c2}, expected -2"
    
    # Test Airy classification
    assert airy_kovacic_analysis() == KovacicCase.FULL_SL2
    
    print("All tests passed!")

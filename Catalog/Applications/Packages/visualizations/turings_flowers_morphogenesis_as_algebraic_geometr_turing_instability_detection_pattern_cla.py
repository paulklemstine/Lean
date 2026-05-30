"""
Algorithms for Turing Pattern Analysis as Algebraic Geometry

Implements the core algorithms from the research paper:
1. Turing instability detection
2. Dispersion analysis
3. Pattern classification
4. Algebraic curve fitting to zero sets
"""

import numpy as np
from typing import Tuple, Optional, Dict, List


class LinearizedRDSystem:
    """
    A linearized two-species reaction-diffusion system.
    
    The system near steady state is:
        ∂u/∂t = Du·∇²u + a·u + b·v
        ∂v/∂t = Dv·∇²v + c·u + d·v
    
    Attributes:
        Du, Dv: Diffusion coefficients (both positive)
        a, b, c, d: Jacobian entries of the reaction kinetics
    
    Time complexity: O(1) for all property computations
    Space complexity: O(1)
    """
    
    def __init__(self, Du: float, Dv: float,
                 a: float, b: float, c: float, d: float):
        assert Du > 0 and Dv > 0, "Diffusion coefficients must be positive"
        self.Du = Du
        self.Dv = Dv
        self.a = a
        self.b = b
        self.c = c
        self.d = d
    
    @property
    def trace(self) -> float:
        """Trace of the Jacobian."""
        return self.a + self.d
    
    @property
    def determinant(self) -> float:
        """Determinant of the Jacobian."""
        return self.a * self.d - self.b * self.c
    
    @property
    def alpha(self) -> float:
        """Leading coefficient of dispersion quadratic: Du * Dv."""
        return self.Du * self.Dv
    
    @property
    def beta(self) -> float:
        """Linear coefficient: a*Dv + d*Du."""
        return self.a * self.Dv + self.d * self.Du
    
    @property
    def gamma(self) -> float:
        """Constant term: det J."""
        return self.determinant
    
    @property
    def discriminant(self) -> float:
        """Discriminant of the dispersion quadratic: β² - 4αγ."""
        return self.beta**2 - 4 * self.alpha * self.gamma
    
    def dispersion(self, q: float) -> float:
        """
        Evaluate the dispersion relation h(q) at wavenumber² = q.
        
        h(q) = α·q² - β·q + γ
        
        When h(q) < 0, the mode at wavenumber √q is unstable.
        
        Time: O(1)
        """
        return self.alpha * q**2 - self.beta * q + self.gamma
    
    def is_turing_unstable(self) -> bool:
        """
        Check the Turing instability criterion.
        
        Conditions (all must hold):
        1. tr(J) < 0  (stable without diffusion — both eigenvalues have Re < 0)
        2. det(J) > 0  (stable without diffusion — no saddle point)
        3. β > 0       (necessary for diffusion to destabilize)
        4. Δ > 0       (dispersion relation achieves negative values)
        
        Time: O(1)
        """
        return (self.trace < 0 and
                self.determinant > 0 and
                self.beta > 0 and
                self.discriminant > 0)
    
    def critical_wavenumber(self) -> Optional[float]:
        """
        The critical wavenumber² at which the dispersion minimum occurs.
        Returns q_c = β / (2α), or None if β ≤ 0.
        
        Time: O(1)
        """
        if self.beta <= 0:
            return None
        return self.beta / (2 * self.alpha)
    
    def unstable_band(self) -> Optional[Tuple[float, float]]:
        """
        The range of unstable wavenumbers² [q₁, q₂].
        Returns None if no instability.
        
        The roots of h(q) = 0 are:
            q = (β ± √Δ) / (2α)
        
        Time: O(1)
        """
        if not self.is_turing_unstable():
            return None
        sqrt_disc = np.sqrt(self.discriminant)
        q1 = (self.beta - sqrt_disc) / (2 * self.alpha)
        q2 = (self.beta + sqrt_disc) / (2 * self.alpha)
        return (q1, q2)


def genus_degree(d: int) -> int:
    """
    Arithmetic genus of a smooth projective plane curve of degree d.
    
    Formula: g = (d-1)(d-2)/2
    
    This is a fundamental invariant connecting algebraic degree to topology.
    
    Time: O(1)
    Space: O(1)
    
    Examples:
        >>> genus_degree(2)  # conic
        0
        >>> genus_degree(3)  # cubic (elliptic curve)
        1
        >>> genus_degree(6)  # sextic
        10
    """
    if d < 2:
        return 0
    return (d - 1) * (d - 2) // 2


def classify_pattern(genus: int) -> str:
    """
    Classify a Turing pattern by the genus of its algebraic curve.
    
    - Genus 0: spots (topologically spherical, e.g., leopard spots)
    - Genus 1: stripes (topologically toroidal, e.g., zebra stripes)  
    - Genus ≥ 2: labyrinth (multiply connected, e.g., brain coral)
    
    Time: O(1)
    """
    if genus == 0:
        return "spots"
    elif genus == 1:
        return "stripes"
    else:
        return "labyrinth"


def predict_pattern(n_modes: int) -> Dict[str, any]:
    """
    Predict the algebraic properties of a Turing pattern with n modes.
    
    The Turing-Algebraic Conjecture predicts:
    - Algebraic degree = 2n
    - Genus = (2n-1)(2n-2)/2
    - Topology determined by genus
    
    Time: O(1)
    
    Args:
        n_modes: Number of unstable Fourier modes
    
    Returns:
        Dictionary with predicted algebraic properties
    """
    degree = 2 * n_modes
    genus = genus_degree(degree)
    topology = classify_pattern(genus)
    euler_char = 2 - 2 * genus
    
    return {
        "n_modes": n_modes,
        "predicted_degree": degree,
        "genus": genus,
        "topology": topology,
        "euler_characteristic": euler_char,
        "bezout_self_intersection": degree * degree,
    }


def simulate_gray_scott(N: int = 128, F: float = 0.04, k: float = 0.06,
                         Du: float = 0.16, Dv: float = 0.08,
                         n_steps: int = 10000, dt: float = 1.0) -> Tuple[np.ndarray, np.ndarray]:
    """
    Simulate the Gray-Scott reaction-diffusion model.
    
    ∂u/∂t = Du·∇²u - u·v² + F·(1 - u)
    ∂v/∂t = Dv·∇²v + u·v² - (F + k)·v
    
    Uses finite differences on a periodic N×N grid.
    
    Time: O(N² · n_steps)
    Space: O(N²)
    
    Args:
        N: Grid size
        F: Feed rate
        k: Kill rate
        Du, Dv: Diffusion coefficients
        n_steps: Number of time steps
        dt: Time step
    
    Returns:
        (u, v): Final concentration fields
    """
    u = np.ones((N, N))
    v = np.zeros((N, N))
    
    # Seed a small perturbation in the center
    r = N // 4
    cx, cy = N // 2, N // 2
    u[cx-r:cx+r, cy-r:cy+r] = 0.50
    v[cx-r:cx+r, cy-r:cy+r] = 0.25
    u += 0.05 * np.random.randn(N, N)
    v += 0.05 * np.random.randn(N, N)
    
    for _ in range(n_steps):
        # Laplacian via finite differences (periodic boundary)
        Lu = (np.roll(u, 1, 0) + np.roll(u, -1, 0) +
              np.roll(u, 1, 1) + np.roll(u, -1, 1) - 4 * u)
        Lv = (np.roll(v, 1, 0) + np.roll(v, -1, 0) +
              np.roll(v, 1, 1) + np.roll(v, -1, 1) - 4 * v)
        
        uvv = u * v * v
        u += dt * (Du * Lu - uvv + F * (1 - u))
        v += dt * (Dv * Lv + uvv - (F + k) * v)
        
        u = np.clip(u, 0, 1)
        v = np.clip(v, 0, 1)
    
    return u, v


def fit_algebraic_curve(points: np.ndarray, max_degree: int = 6) -> Dict[str, any]:
    """
    Fit an algebraic curve to a set of 2D points.
    
    Fits polynomials of degree d = 1, 2, ..., max_degree and finds
    the degree that minimizes the residual.
    
    A polynomial of degree d in (x, y) has (d+1)(d+2)/2 monomials.
    We solve min ||A·c||² where A is the Vandermonde-like matrix.
    
    Time: O(n · d² + d⁶) for n points and degree d
    Space: O(n · d²)
    
    Args:
        points: (n, 2) array of (x, y) coordinates
        max_degree: Maximum polynomial degree to try
    
    Returns:
        Dictionary with best degree, residuals, and coefficients
    """
    x, y = points[:, 0], points[:, 1]
    n = len(x)
    
    residuals = {}
    coefficients = {}
    
    for d in range(1, max_degree + 1):
        # Build monomial matrix: x^i * y^j for i+j <= d
        monomials = []
        for i in range(d + 1):
            for j in range(d + 1 - i):
                monomials.append(x**i * y**j)
        
        A = np.column_stack(monomials)
        
        # Find the null space (smallest singular value)
        _, s, Vt = np.linalg.svd(A)
        
        # The residual is the smallest singular value
        residuals[d] = s[-1] / s[0] if s[0] > 0 else float('inf')
        coefficients[d] = Vt[-1]
    
    best_degree = min(residuals, key=residuals.get)
    
    return {
        "best_degree": best_degree,
        "residuals": residuals,
        "coefficients": coefficients[best_degree],
        "genus": genus_degree(best_degree),
        "topology": classify_pattern(genus_degree(best_degree)),
    }


# Example usage
if __name__ == "__main__":
    # Create a Turing system
    system = LinearizedRDSystem(Du=0.01, Dv=1.0, a=0.5, b=-1.0, c=1.0, d=-1.5)
    
    print("Turing Instability Analysis:")
    print(f"  Is Turing unstable: {system.is_turing_unstable()}")
    print(f"  Discriminant: {system.discriminant:.4f}")
    
    if system.is_turing_unstable():
        band = system.unstable_band()
        print(f"  Unstable band: q ∈ [{band[0]:.4f}, {band[1]:.4f}]")
        print(f"  Critical wavenumber²: {system.critical_wavenumber():.4f}")
    
    print("\nPattern Predictions:")
    for n in range(1, 5):
        pred = predict_pattern(n)
        print(f"  {n} mode(s): degree={pred['predicted_degree']}, "
              f"genus={pred['genus']}, type={pred['topology']}")

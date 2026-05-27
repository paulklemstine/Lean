"""
Algorithms for computing the free spectral edge functional.

Implements the Stieltjes-denominator equation f_μ(x) = 1/σ² solver
for finite atomic probability laws, using both bisection and polynomial
root-finding approaches.
"""

import numpy as np
from typing import List, Tuple, Optional


class SpectralAtom:
    """A weighted point mass in a finite spectrum."""
    def __init__(self, loc: float, weight: float):
        assert weight >= 0, f"Weight must be nonneg, got {weight}"
        self.loc = loc
        self.weight = weight

    def __repr__(self) -> str:
        return f"SpectralAtom(loc={self.loc}, weight={self.weight})"


class FiniteSpectrumLaw:
    """A finite atomic probability law on ℝ."""
    def __init__(self, atoms: List[SpectralAtom]):
        assert len(atoms) > 0, "Must have at least one atom"
        total = sum(a.weight for a in atoms)
        assert abs(total - 1.0) < 1e-10, f"Weights must sum to 1, got {total}"
        self.atoms = atoms

    def stieltjes_denom(self, x: float) -> float:
        """Compute f_μ(x) = Σ wᵢ/(x - aᵢ)²."""
        return sum(a.weight / (x - a.loc)**2 for a in self.atoms)

    def stieltjes_denom_deriv(self, x: float) -> float:
        """Compute f_μ'(x) = -2 Σ wᵢ/(x - aᵢ)³."""
        return sum(-2 * a.weight / (x - a.loc)**3 for a in self.atoms)

    def max_loc(self) -> float:
        """Maximum atom location."""
        return max(a.loc for a in self.atoms)

    def __repr__(self) -> str:
        return f"FiniteSpectrumLaw({self.atoms})"


def spike_law(n: int, spike: float) -> FiniteSpectrumLaw:
    """Create the spike law μ_{n,λ} = (1/n)δ_λ + ((n-1)/n)δ_0.

    Args:
        n: Dimension parameter (positive integer).
        spike: Location of the spike eigenvalue.

    Returns:
        FiniteSpectrumLaw with two atoms.
    """
    assert n > 0
    return FiniteSpectrumLaw([
        SpectralAtom(spike, 1.0 / n),
        SpectralAtom(0.0, (n - 1.0) / n),
    ])


def approximate_free_right_edge(
    mu: FiniteSpectrumLaw,
    sigma: float,
    left: Optional[float] = None,
    right: Optional[float] = None,
    steps: int = 100,
) -> float:
    """Bisection algorithm to approximate the free spectral edge.

    Finds x > max supp(μ) such that f_μ(x) = 1/σ².

    Args:
        mu: Finite spectrum law.
        sigma: Noise parameter (positive).
        left: Left bracket (default: max_loc + epsilon).
        right: Right bracket (default: max_loc + 10*sigma).
        steps: Number of bisection steps.

    Returns:
        Approximate free edge location.
    """
    assert sigma > 0
    target = 1.0 / sigma**2
    max_loc = mu.max_loc()

    if left is None:
        left = max_loc + 1e-6
    if right is None:
        right = max_loc + 10 * sigma + 10

    # Ensure brackets are valid
    assert left > max_loc, "Left bracket must be > max atom location"

    for _ in range(steps):
        mid = (left + right) / 2
        if mu.stieltjes_denom(mid) > target:
            left = mid
        else:
            right = mid

    return (left + right) / 2


def solve_spike_edge_quartic(
    n: int, spike: float, sigma: float
) -> Optional[float]:
    """Solve the free-edge quartic for the spike law.

    For μ_{n,λ}, the edge equation reduces to a quartic polynomial.
    Returns the largest real root exceeding max(0, spike).

    Args:
        n: Dimension parameter.
        spike: Spike location.
        sigma: Noise parameter.

    Returns:
        Free edge or None if no valid root exists.
    """
    # From the edge equation:
    # (1/n)*x^2 + ((n-1)/n)*(x-λ)^2 = x^2*(x-λ)^2 / σ²
    # Multiply by σ²:
    # (σ²/n)*x^2 + σ²*(n-1)/n*(x-λ)^2 = x^2*(x-λ)^2
    # Expand x^2*(x-λ)^2 = x^4 - 2λx^3 + λ²x^2
    # (σ²/n)*x^2 + σ²*(n-1)/n*(x^2 - 2λx + λ²) = x^4 - 2λx^3 + λ²x^2
    # Collect:
    # x^4 - 2λx^3 + (λ² - σ²/n - σ²(n-1)/n)x^2 + 2σ²(n-1)/n*λ*x - σ²(n-1)/n*λ² = 0
    # Note: σ²/n + σ²(n-1)/n = σ²
    # So: x^4 - 2λx^3 + (λ² - σ²)x^2 + 2σ²(n-1)/n*λ*x - σ²(n-1)/n*λ² = 0

    s2 = sigma**2
    frac = (n - 1.0) / n
    coeffs = [
        1,                          # x^4
        -2 * spike,                 # x^3
        spike**2 - s2,              # x^2
        2 * s2 * frac * spike,      # x^1
        -s2 * frac * spike**2,      # x^0
    ]

    roots = np.roots(coeffs)
    threshold = max(0, spike) + 1e-10

    # Filter real roots above the threshold
    real_roots = []
    for r in roots:
        if abs(r.imag) < 1e-8 and r.real > threshold:
            real_roots.append(r.real)

    if not real_roots:
        return None
    return max(real_roots)


def is_free_edge_candidate(
    mu: FiniteSpectrumLaw, sigma: float, x: float, tol: float = 1e-8
) -> bool:
    """Check if x is approximately a free-edge candidate.

    Args:
        mu: Finite spectrum law.
        sigma: Noise parameter.
        x: Point to check.
        tol: Tolerance for the equation.

    Returns:
        True if x > all atom locs and f_μ(x) ≈ 1/σ².
    """
    if any(a.loc >= x for a in mu.atoms):
        return False
    return abs(mu.stieltjes_denom(x) - 1.0 / sigma**2) < tol


if __name__ == "__main__":
    # Example: spike law with n=100, spike=3, sigma=1
    n, s, sigma = 100, 3.0, 1.0
    mu = spike_law(n, s)
    edge_bisect = approximate_free_right_edge(mu, sigma)
    edge_quartic = solve_spike_edge_quartic(n, s, sigma)
    print(f"Spike law n={n}, λ={s}, σ={sigma}")
    print(f"  Bisection edge:  {edge_bisect:.6f}")
    print(f"  Quartic edge:    {edge_quartic:.6f}")
    print(f"  Naive 2σ:        {2*sigma:.6f}")
    print(f"  Is candidate:    {is_free_edge_candidate(mu, sigma, edge_bisect)}")

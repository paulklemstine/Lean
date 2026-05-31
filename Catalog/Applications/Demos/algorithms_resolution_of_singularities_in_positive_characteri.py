"""
Resolution of Singularities in Positive Characteristic: Core Algorithms

This module implements the key algebraic algorithms for analyzing and resolving
singularities of polynomials over finite fields F_p.
"""

from typing import Dict, List, Optional, Tuple, Set
from dataclasses import dataclass, field
from math import gcd
from functools import reduce


@dataclass
class Monomial:
    """A monomial a * x_0^{e_0} * ... * x_{d-1}^{e_{d-1}} over F_p."""
    coeff: int
    exponents: Tuple[int, ...]
    
    @property
    def total_degree(self) -> int:
        return sum(self.exponents)
    
    def __repr__(self) -> str:
        terms = []
        for i, e in enumerate(self.exponents):
            if e > 0:
                terms.append(f"x{i}^{e}" if e > 1 else f"x{i}")
        var_str = "*".join(terms) if terms else "1"
        return f"{self.coeff}*{var_str}"


@dataclass 
class PolynomialFp:
    """A multivariate polynomial over F_p."""
    p: int  # characteristic
    dim: int  # number of variables
    terms: List[Monomial] = field(default_factory=list)
    
    def reduce_mod_p(self) -> 'PolynomialFp':
        """Reduce all coefficients mod p."""
        new_terms = []
        for m in self.terms:
            c = m.coeff % self.p
            if c != 0:
                new_terms.append(Monomial(c, m.exponents))
        return PolynomialFp(self.p, self.dim, new_terms)
    
    @property
    def support(self) -> Set[Tuple[int, ...]]:
        """The set of exponent vectors with nonzero coefficient."""
        return {m.exponents for m in self.terms if m.coeff % self.p != 0}
    
    def multiplicity_at_origin(self) -> int:
        """Compute the multiplicity (order of vanishing) at the origin.
        
        This is the minimum total degree among all monomials with nonzero coefficient.
        """
        reduced = self.reduce_mod_p()
        if not reduced.terms:
            return float('inf')  # type: ignore
        return min(m.total_degree for m in reduced.terms)
    
    def formal_derivative(self, var_index: int) -> 'PolynomialFp':
        """Compute the formal partial derivative with respect to x_{var_index}.
        
        In characteristic p, this sends x_i^{pk} to 0 (derivative vanishing).
        """
        new_terms = []
        for m in self.terms:
            e = m.exponents[var_index]
            if e > 0:
                new_coeff = (m.coeff * e) % self.p
                if new_coeff != 0:
                    new_exp = list(m.exponents)
                    new_exp[var_index] = e - 1
                    new_terms.append(Monomial(new_coeff, tuple(new_exp)))
        return PolynomialFp(self.p, self.dim, new_terms)
    
    def is_singular_at_origin(self) -> bool:
        """Check if the polynomial defines a singular variety at the origin.
        
        Uses the Jacobian criterion: singular iff f(0) = 0 and all 
        partial derivatives vanish at 0.
        """
        if self.multiplicity_at_origin() < 1:
            return False
        if self.multiplicity_at_origin() >= 2:
            return True  # multiplicity >= 2 implies singular
        # Multiplicity 1: check if all partials vanish at origin
        for i in range(self.dim):
            deriv = self.formal_derivative(i)
            if deriv.multiplicity_at_origin() == 0:
                return False  # some partial is nonzero at origin
        return True


def compute_inseparability_degree(f: PolynomialFp) -> int:
    """Compute the inseparability degree of a polynomial over F_p.
    
    The inseparability degree is the largest k such that p^k divides
    every exponent in every variable for every monomial in the support.
    
    This is the key invariant measuring the Frobenius obstruction to
    resolution in positive characteristic.
    
    Args:
        f: A polynomial over F_p
        
    Returns:
        The inseparability degree k >= 0
    """
    f = f.reduce_mod_p()
    if not f.terms:
        return 0
    
    # Collect all exponents appearing in the support
    all_exponents: List[int] = []
    for m in f.terms:
        all_exponents.extend(m.exponents)
    
    # Filter out zeros (constant terms don't contribute)
    nonzero_exps = [e for e in all_exponents if e > 0]
    if not nonzero_exps:
        return 0
    
    # Find largest k such that p^k divides all nonzero exponents
    k = 0
    p = f.p
    while True:
        pk_next = p ** (k + 1)
        if all(e % pk_next == 0 for e in nonzero_exps):
            k += 1
        else:
            break
    
    return k


def blowup_at_origin_affine_chart(f: PolynomialFp, chart: int) -> PolynomialFp:
    """Compute the strict transform of f under blowup at the origin.
    
    In the i-th affine chart of the blowup, we substitute:
        x_j -> x_i * x_j  for j != i
        x_i -> x_i
    and then divide by x_i^m where m is the multiplicity.
    
    Args:
        f: Polynomial to blow up
        chart: Which affine chart to use (0, ..., dim-1)
        
    Returns:
        The strict transform in the chosen affine chart
    """
    f = f.reduce_mod_p()
    m = f.multiplicity_at_origin()
    
    if m == 0 or m == float('inf'):
        return f
    
    # Apply the substitution x_j -> x_{chart} * x_j for j != chart
    new_terms = []
    for mon in f.terms:
        new_exp = list(mon.exponents)
        # The power of x_{chart} gained from substitution
        extra_power = sum(e for j, e in enumerate(mon.exponents) if j != chart)
        new_exp[chart] += extra_power
        new_terms.append(Monomial(mon.coeff, tuple(new_exp)))
    
    # Divide by x_{chart}^m (subtract m from the chart variable's exponent)
    strict_terms = []
    for mon in new_terms:
        new_exp = list(mon.exponents)
        new_exp[chart] -= m
        if new_exp[chart] >= 0:
            strict_terms.append(Monomial(mon.coeff, tuple(new_exp)))
    
    return PolynomialFp(f.p, f.dim, strict_terms).reduce_mod_p()


@dataclass
class BlowupStep:
    """Record of a single blowup step."""
    chart: int
    multiplicity_before: int
    multiplicity_after: int
    insep_degree: int
    polynomial: PolynomialFp


def resolution_sequence(f: PolynomialFp, max_steps: int = 100) -> List[BlowupStep]:
    """Attempt to resolve the singularity of f at the origin by iterated blowup.
    
    At each step, chooses the affine chart that minimizes the resulting multiplicity.
    
    Args:
        f: Polynomial with singularity at origin
        max_steps: Maximum number of blowup steps
        
    Returns:
        List of BlowupStep records showing the resolution process
    """
    steps = []
    current = f.reduce_mod_p()
    
    for _ in range(max_steps):
        m = current.multiplicity_at_origin()
        if m <= 1:
            break
        
        # Try all charts, pick the one with lowest resulting multiplicity
        best_chart = 0
        best_mult = float('inf')
        best_transform = current
        
        for chart in range(current.dim):
            transform = blowup_at_origin_affine_chart(current, chart)
            new_mult = transform.multiplicity_at_origin()
            if new_mult < best_mult:
                best_mult = new_mult
                best_chart = chart
                best_transform = transform
        
        insep = compute_inseparability_degree(current)
        steps.append(BlowupStep(
            chart=best_chart,
            multiplicity_before=m,
            multiplicity_after=int(best_mult),
            insep_degree=insep,
            polynomial=current
        ))
        
        current = best_transform
        
        # Safety: if multiplicity didn't decrease, we're stuck
        if best_mult >= m:
            break
    
    return steps


def newton_polygon_2d(f: PolynomialFp) -> List[Tuple[int, int]]:
    """Compute the Newton polygon of a bivariate polynomial.
    
    Returns the vertices of the lower convex hull of the support points.
    
    Args:
        f: A bivariate polynomial (dim=2)
        
    Returns:
        List of (i, j) vertices of the Newton polygon
    """
    assert f.dim == 2, "Newton polygon is for bivariate polynomials"
    
    f = f.reduce_mod_p()
    points = [(m.exponents[0], m.exponents[1]) for m in f.terms]
    
    if not points:
        return []
    
    # Compute lower convex hull
    points.sort()
    
    # Filter to get the "Newton polygon" boundary:
    # points on the boundary of the convex hull closest to axes
    hull = []
    for p_pt in points:
        while len(hull) >= 2:
            # Check if the last point makes a left turn
            o, a, b = hull[-2], hull[-1], p_pt
            cross = (a[0] - o[0]) * (b[1] - o[1]) - (a[1] - o[1]) * (b[0] - o[0])
            if cross <= 0:
                hull.pop()
            else:
                break
        hull.append(p_pt)
    
    return hull


def frobenius_image(f: PolynomialFp) -> PolynomialFp:
    """Apply the Frobenius endomorphism: f(x) -> f(x^p) = f(x)^p.
    
    Since we're in characteristic p, (f(x))^p = f(x^p) by the freshman's dream.
    This raises all exponents by a factor of p and raises coefficients to the p-th power.
    
    Args:
        f: Input polynomial
        
    Returns:
        The Frobenius image f^p = f(x^p)
    """
    new_terms = []
    for m in f.terms:
        # Coefficient: a^p mod p. By Fermat's little theorem, a^p = a mod p
        new_coeff = m.coeff  # a^p ≡ a (mod p)
        new_exp = tuple(e * f.p for e in m.exponents)
        new_terms.append(Monomial(new_coeff, new_exp))
    
    return PolynomialFp(f.p, f.dim, new_terms).reduce_mod_p()


# Type-hinted utility functions

def all_monomials_of_degree(dim: int, degree: int) -> List[Tuple[int, ...]]:
    """Generate all exponent vectors of given total degree in given dimension."""
    if dim == 1:
        return [(degree,)]
    result = []
    for i in range(degree + 1):
        for rest in all_monomials_of_degree(dim - 1, degree - i):
            result.append((i,) + rest)
    return result


def random_polynomial_fp(p: int, dim: int, max_degree: int, seed: int = 42) -> PolynomialFp:
    """Generate a random polynomial over F_p with given maximum degree.
    
    Uses a deterministic seed for reproducibility.
    """
    import random
    rng = random.Random(seed)
    
    terms = []
    for d in range(2, max_degree + 1):  # Start from degree 2 for singularity
        for exp in all_monomials_of_degree(dim, d):
            coeff = rng.randint(0, p - 1)
            if coeff != 0:
                terms.append(Monomial(coeff, exp))
    
    return PolynomialFp(p, dim, terms).reduce_mod_p()

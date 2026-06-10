"""
Tropical Fermat Theory: Algorithms and Implementations

Type-hinted implementations of key algorithms from the tropical Fermat
theory formalization, including tropical arithmetic, Fermat equation
solving, and tropical variety computation.
"""

from typing import List, Tuple, Set, Optional


# --- Tropical Arithmetic ---

def tropical_add(a: int, b: int) -> int:
    """Tropical addition: min(a, b)."""
    return min(a, b)


def tropical_mul(a: int, b: int) -> int:
    """Tropical multiplication: a + b (classical)."""
    return a + b


def tropical_pow(a: int, n: int) -> int:
    """Tropical exponentiation: n * a (classical).
    
    Since tropical multiplication is classical addition,
    raising to the nth power means adding a to itself n times,
    which is n * a in classical arithmetic.
    """
    return n * a


# --- Tropical Fermat Equation ---

def is_tropical_fermat_solution(x: int, y: int, z: int, n: int) -> bool:
    """Test whether (x, y, z) satisfies x^n ⊕ y^n = z^n in tropical arithmetic.
    
    By the Fermat reduction theorem, this is equivalent to min(x, y) = z,
    independent of n (for n >= 1).
    
    Args:
        x, y, z: Tropical integers (as classical integers via untrop)
        n: Exponent (must be >= 1)
    
    Returns:
        True iff trop(x)^n + trop(y)^n = trop(z)^n in Tropical ℤ
    """
    assert n >= 1, "Exponent must be at least 1"
    return min(x, y) == z


def enumerate_fermat_solutions(bound: int, n: int) -> List[Tuple[int, int, int]]:
    """Enumerate all tropical Fermat solutions with |x|, |y|, |z| ≤ bound.
    
    By degree independence, the solutions are the same for all n >= 1:
    {(x, y, z) : z = min(x, y)}.
    """
    solutions = []
    for x in range(-bound, bound + 1):
        for y in range(-bound, bound + 1):
            z = min(x, y)
            if abs(z) <= bound:
                solutions.append((x, y, z))
    return solutions


# --- Tropical Monomials and Polynomials ---

class TropMonomial:
    """A tropical monomial c ⊗ x^i ⊗ y^j, evaluated classically as c + i*x + j*y."""
    
    def __init__(self, coeff: int, x_exp: int, y_exp: int):
        self.coeff = coeff
        self.x_exp = x_exp
        self.y_exp = y_exp
    
    def eval(self, x: int, y: int) -> int:
        """Evaluate the monomial at (x, y) in classical coordinates."""
        return self.coeff + self.x_exp * x + self.y_exp * y
    
    def __repr__(self) -> str:
        terms = []
        if self.coeff != 0:
            terms.append(str(self.coeff))
        if self.x_exp == 1:
            terms.append("x")
        elif self.x_exp > 1:
            terms.append(f"{self.x_exp}x")
        if self.y_exp == 1:
            terms.append("y")
        elif self.y_exp > 1:
            terms.append(f"{self.y_exp}y")
        return " + ".join(terms) if terms else "0"


class TropPoly:
    """A tropical polynomial: a list of monomials evaluated via min (tropical sum)."""
    
    def __init__(self, monomials: List[TropMonomial]):
        self.monomials = monomials
    
    def eval(self, x: int, y: int) -> int:
        """Evaluate the tropical polynomial at (x, y): min of all monomial values."""
        if not self.monomials:
            return 0
        return min(m.eval(x, y) for m in self.monomials)
    
    def monomial_values(self, x: int, y: int) -> List[int]:
        """Return the list of individual monomial evaluations."""
        return [m.eval(x, y) for m in self.monomials]


def fermat_poly(n: int) -> TropPoly:
    """The tropical Fermat polynomial of degree n: min(nx, ny, 0)."""
    return TropPoly([
        TropMonomial(0, n, 0),  # nx
        TropMonomial(0, 0, n),  # ny
        TropMonomial(0, 0, 0),  # 0
    ])


# --- Tropical Varieties ---

def is_in_tropical_variety(poly: TropPoly, x: int, y: int) -> bool:
    """Test whether (x, y) lies in the tropical variety of the polynomial.
    
    A point is in the tropical variety iff the minimum of the monomial
    evaluations is achieved by at least two distinct monomials.
    """
    values = poly.monomial_values(x, y)
    if not values:
        return False
    min_val = min(values)
    count = sum(1 for v in values if v == min_val)
    return count >= 2


def classify_tropical_line_ray(x: int, y: int) -> Optional[str]:
    """Classify which ray of the standard tropical line a point lies on.
    
    Returns:
        "diagonal" if x = y ≤ 0
        "y-axis" if x = 0 and y ≥ 0
        "x-axis" if y = 0 and x ≥ 0
        None if the point is not on the tropical line
    """
    if x == y and x <= 0:
        return "diagonal"
    elif x == 0 and y >= 0:
        return "y-axis"
    elif y == 0 and x >= 0:
        return "x-axis"
    return None


def compute_tropical_variety(poly: TropPoly, bound: int) -> Set[Tuple[int, int]]:
    """Compute the tropical variety of a polynomial within a bounding box."""
    variety = set()
    for x in range(-bound, bound + 1):
        for y in range(-bound, bound + 1):
            if is_in_tropical_variety(poly, x, y):
                variety.add((x, y))
    return variety


# --- Balancing Condition ---

def check_balancing(rays: List[Tuple[Tuple[int, int], int]]) -> bool:
    """Check the tropical balancing condition at a vertex.
    
    Args:
        rays: List of (direction_vector, weight) pairs
    
    Returns:
        True iff the weighted sum of direction vectors is (0, 0)
    """
    total_x = sum(w * d[0] for d, w in rays)
    total_y = sum(w * d[1] for d, w in rays)
    return total_x == 0 and total_y == 0


def fermat_rays(n: int) -> List[Tuple[Tuple[int, int], int]]:
    """The three rays of the tropical Fermat curve of degree n."""
    return [
        ((-1, -1), n),  # Diagonal ray
        ((1, 0), n),    # x-axis ray
        ((0, 1), n),    # y-axis ray
    ]


# --- Degree Independence Verification ---

def verify_degree_independence(max_degree: int, bound: int) -> bool:
    """Verify that tropical Fermat varieties are the same for all degrees 1..max_degree.
    
    Returns True iff all varieties within the bounding box are identical.
    """
    base_variety = compute_tropical_variety(fermat_poly(1), bound)
    for n in range(2, max_degree + 1):
        variety_n = compute_tropical_variety(fermat_poly(n), bound)
        if variety_n != base_variety:
            return False
    return True


# --- Genus Computation ---

def tropical_fermat_genus(n: int) -> int:
    """The genus of the tropical Fermat curve of degree n.
    
    The tropical Fermat curve is a tree (trident) with 1 vertex
    and 3 unbounded rays, so its genus is always 0.
    """
    return 0  # genus = 1 - V + E_compact = 1 - 1 + 0 = 0

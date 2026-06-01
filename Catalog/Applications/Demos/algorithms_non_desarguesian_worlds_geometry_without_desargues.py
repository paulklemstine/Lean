"""
Non-Desarguesian Geometry: Core Algorithms

Implements Hall quasifield arithmetic, projective plane construction,
and non-Desarguesian property verification.
"""

from typing import Tuple, List, Optional, Set, Dict


# Type aliases
Element = Tuple[int, int]  # Element of GF(p^2) as (a, b) representing a + b*alpha


def gf9_add(x: Element, y: Element, p: int = 3) -> Element:
    """Addition in GF(p^2): component-wise mod p."""
    return ((x[0] + y[0]) % p, (x[1] + y[1]) % p)


def gf9_neg(x: Element, p: int = 3) -> Element:
    """Negation in GF(p^2)."""
    return ((-x[0]) % p, (-x[1]) % p)


def gf9_mul(x: Element, y: Element, p: int = 3) -> Element:
    """Standard field multiplication in GF(p^2) = GF(p)[alpha]/(alpha^2 + 1).
    
    (a + b*alpha)(c + d*alpha) = (ac - bd) + (ad + bc)*alpha
    In characteristic p, -1 = p-1, so -bd = (p-1)*bd.
    For p=3: -bd = 2*bd.
    """
    a, b = x
    c, d = y
    return ((a * c + (p - 1) * b * d) % p, (a * d + b * c) % p)


def frobenius(x: Element, p: int = 3) -> Element:
    """Frobenius automorphism on GF(p^2): x -> x^p.
    
    For GF(p)[alpha]/(alpha^2 + 1):
    sigma(a + b*alpha) = a + b*alpha^p
    alpha^p = alpha * alpha^(p-1)
    
    For p=3: alpha^3 = alpha * alpha^2 = alpha * (-1) = -alpha = 2*alpha
    So sigma(a, b) = (a, (p-1)*b)
    """
    return (x[0], ((p - 1) * x[1]) % p)


def hall_mul(x: Element, y: Element, p: int = 3) -> Element:
    """Hall multiplication on GF(p^2).
    
    x ○ y = x * y          if y in GF(p) (i.e., y[1] = 0)
    x ○ y = sigma(x) * y   if y not in GF(p) (i.e., y[1] != 0)
    
    Expanding for p=3, alpha^2 = -1 = 2:
    d = 0: (ac, bc)
    d != 0: (ac + bd, ad + 2bc)
    """
    a, b = x
    c, d = y
    if d % p == 0:
        return ((a * c) % p, (b * c) % p)
    else:
        return ((a * c + b * d) % p, (a * d + (p - 1) * b * c) % p)


def is_associative(mul_fn, elements: List[Element], p: int = 3) -> Tuple[bool, Optional[Tuple[Element, Element, Element]]]:
    """Check if a multiplication is associative over given elements.
    Returns (True, None) if associative, (False, (x, y, z)) with witness otherwise.
    """
    for x in elements:
        for y in elements:
            for z in elements:
                lhs = mul_fn(mul_fn(x, y, p), z, p)
                rhs = mul_fn(x, mul_fn(y, z, p), p)
                if lhs != rhs:
                    return False, (x, y, z)
    return True, None


def is_right_distributive(mul_fn, add_fn, elements: List[Element], p: int = 3) -> bool:
    """Check right distributivity: (a + b) ○ c = a ○ c + b ○ c."""
    for a in elements:
        for b in elements:
            for c in elements:
                lhs = mul_fn(add_fn(a, b, p), c, p)
                rhs = add_fn(mul_fn(a, c, p), mul_fn(b, c, p), p)
                if lhs != rhs:
                    return False
    return True


def is_left_distributive(mul_fn, add_fn, elements: List[Element], p: int = 3) -> bool:
    """Check left distributivity: a ○ (b + c) = a ○ b + a ○ c."""
    for a in elements:
        for b in elements:
            for c in elements:
                lhs = mul_fn(a, add_fn(b, c, p), p)
                rhs = add_fn(mul_fn(a, b, p), mul_fn(a, c, p), p)
                if lhs != rhs:
                    return False
    return True


def gf_elements(p: int = 3) -> List[Element]:
    """Generate all elements of GF(p^2)."""
    return [(a, b) for a in range(p) for b in range(p)]


def build_hall_plane(p: int = 3) -> Dict:
    """Construct the Hall projective plane of order p^2.
    
    Points: (x, y) for x, y in GF(p^2), plus ideal points [m] for m in GF(p^2), plus [infinity].
    Lines: [m, b] = {(x, m○x + b) : x in GF(p^2)} ∪ {[m]},
           plus [infinity_line] = {[m] : m in GF(p^2)} ∪ {[infinity]}.
    
    Returns dict with points, lines, and incidence data.
    """
    elements = gf_elements(p)
    n = p * p  # order
    
    # Points
    affine_points = [(x, y) for x in elements for y in elements]
    ideal_points = [('ideal', m) for m in elements]
    inf_point = ('infinity',)
    
    all_points = affine_points + ideal_points + [inf_point]
    
    # Lines
    affine_lines = []
    for m in elements:
        for b in elements:
            line_points = set()
            for x in elements:
                mx = hall_mul(m, x, p)
                y = gf9_add(mx, b, p)
                line_points.add((x, y))
            line_points.add(('ideal', m))
            affine_lines.append(('line', m, b, frozenset(line_points)))
    
    # Vertical lines: x = c
    vertical_lines = []
    for c in elements:
        line_points = set()
        for y in elements:
            line_points.add((c, y))
        line_points.add(inf_point)
        vertical_lines.append(('vline', c, frozenset(line_points)))
    
    # Line at infinity
    inf_line_points = set(ideal_points) | {inf_point}
    inf_line = ('inf_line', frozenset(inf_line_points))
    
    all_lines = affine_lines + vertical_lines + [inf_line]
    
    return {
        'order': n,
        'num_points': len(all_points),
        'num_lines': len(all_lines),
        'points': all_points,
        'lines': all_lines,
        'expected_points': n**2 + n + 1,
        'expected_lines': n**2 + n + 1,
    }


def verify_plane_axioms(plane: Dict, p: int = 3) -> Dict:
    """Verify projective plane axioms for a constructed plane."""
    points = plane['points']
    lines = plane['lines']
    
    # Extract point sets for each line
    def get_line_points(line):
        if line[0] == 'line':
            return line[3]
        elif line[0] == 'vline':
            return line[2]
        else:
            return line[1]
    
    line_point_sets = [get_line_points(l) for l in lines]
    
    # Check: each line has n+1 points
    n = plane['order']
    line_sizes = [len(ps) for ps in line_point_sets]
    uniform = all(s == n + 1 for s in line_sizes)
    
    # Check: two points determine a unique line (sample check)
    sample_checks = 0
    axiom1_ok = True
    for i, p1 in enumerate(points[:20]):
        for p2 in points[i+1:i+20]:
            if p1 == p2:
                continue
            containing = [j for j, ps in enumerate(line_point_sets) if p1 in ps and p2 in ps]
            if len(containing) != 1:
                axiom1_ok = False
            sample_checks += 1
    
    return {
        'num_points': len(points),
        'num_lines': len(lines),
        'uniform_line_size': uniform,
        'line_size': n + 1,
        'axiom1_sample_ok': axiom1_ok,
        'sample_checks': sample_checks,
    }


def collineation_group_order_hall(q: int) -> int:
    """Known collineation group order for the Hall plane of order q^2.
    
    For the Hall plane of order q^2 (q a prime power, q > 2):
    |Aut(Hall(q^2))| = q^2 * (q^2 - 1)^2 * 2
    
    This is much smaller than |PGL(3, q^2)|.
    """
    n = q * q
    return n * (n - 1) ** 2 * 2


def pgl_order(d: int, q: int) -> int:
    """Order of PGL(d, GF(q))."""
    numerator = 1
    for i in range(d):
        numerator *= q**d - q**i
    return numerator // (q - 1)

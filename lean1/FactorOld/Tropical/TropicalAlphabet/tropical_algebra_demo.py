#!/usr/bin/env python3
"""
╔══════════════════════════════════════════════════════════════════════╗
║  THE TROPICAL ALPHABET: A Complete Taxonomy of Tropical Operations  ║
║  Interactive Demo & Computational Laboratory                        ║
╚══════════════════════════════════════════════════════════════════════╝

This module implements the full "alphabet" of operations available in
the tropical semiring T = (ℝ ∪ {+∞}, min, +), including:

  TIER 0 - ATOMS:
    ⊕ (tropical add = min)
    ⊗ (tropical mult = +)

  TIER 1 - DERIVED SCALARS:
    Tropical power, tropical absolute value, tropical sign

  TIER 2 - POLYNOMIAL ALGEBRA:
    Tropical polynomials, tropical roots, Newton polygons

  TIER 3 - LINEAR ALGEBRA:
    Tropical matrices, tropical determinant, tropical eigenvalues,
    Kleene star (shortest-path closure)

  TIER 4 - ANALYSIS:
    Tropical Fourier transform (= Legendre-Fenchel conjugate),
    tropical convolution (= infimal convolution),
    tropical differential operator

  TIER 5 - GEOMETRY:
    Tropical lines, tropical curves, tropical convex hulls

  TIER 6 - LOGIC:
    Boolean-to-tropical embedding, SAT encoding

Author: Meta Oracle Collective
"""

import numpy as np
from itertools import permutations
from typing import List, Tuple, Optional, Callable
import json

# ═══════════════════════════════════════════════════════════════
# TIER 0: THE TWO ATOMS
# ═══════════════════════════════════════════════════════════════

INF = float('inf')

def trop_add(a: float, b: float) -> float:
    """Tropical addition: a ⊕ b = min(a, b)
    
    This is the additive operation of the min-plus tropical semiring.
    Identity element: +∞ (tropical zero)
    
    Key properties:
    - Commutative: a ⊕ b = b ⊕ a
    - Associative: (a ⊕ b) ⊕ c = a ⊕ (b ⊕ c)
    - Idempotent: a ⊕ a = a  ← THIS IS THE MIND-BENDING PART
    """
    return min(a, b)

def trop_mul(a: float, b: float) -> float:
    """Tropical multiplication: a ⊗ b = a + b
    
    This is the multiplicative operation of the min-plus tropical semiring.
    Identity element: 0 (tropical one)
    Absorbing element: +∞ (tropical zero absorbs: ∞ + x = ∞)
    
    Key properties:
    - Commutative: a ⊗ b = b ⊗ a
    - Associative
    - Distributes over ⊕: a ⊗ (b ⊕ c) = (a ⊗ b) ⊕ (a ⊗ c)
      i.e., a + min(b,c) = min(a+b, a+c) ✓
    """
    if a == INF or b == INF:
        return INF
    return a + b

# ═══════════════════════════════════════════════════════════════
# TIER 1: DERIVED SCALAR OPERATIONS
# ═══════════════════════════════════════════════════════════════

def trop_pow(a: float, n: int) -> float:
    """Tropical power: a^⊗n = a ⊗ a ⊗ ... ⊗ a (n times) = n * a
    
    Since ⊗ is classical +, tropical exponentiation is classical multiplication!
    This is the first beautiful inversion: exponentiation dequantizes to multiplication.
    """
    if a == INF:
        return INF
    return n * a

def trop_neg(a: float) -> float:
    """Tropical negation (multiplicative inverse): a^⊗(-1) = -a
    
    In the full tropical semifield T* = (ℝ, min, +), every finite element
    has a multiplicative inverse: -a, since a ⊗ (-a) = a + (-a) = 0 = 𝟙.
    
    NOTE: There is NO additive inverse! Since a ⊕ b = min(a,b),
    there is no b such that a ⊕ b = +∞ (the tropical zero) unless a = +∞.
    This is the fundamental asymmetry of tropical algebra.
    """
    if a == INF:
        return INF  # ∞ has no multiplicative inverse in extended system
    return -a

def trop_div(a: float, b: float) -> float:
    """Tropical division: a ⊘ b = a ⊗ b^⊗(-1) = a + (-b) = a - b"""
    if b == INF:
        return INF  
    if a == INF:
        return INF
    return a - b

def trop_abs(a: float) -> float:
    """Tropical absolute value: |a|_T = a ⊕ (-a) = min(a, -a)
    
    This has a fascinating property: |a|_T ≤ 0 always!
    And |a|_T = 0 iff a = 0.
    So tropical absolute value measures "distance from tropical one (=0)".
    """
    if a == INF:
        return INF
    return min(a, -a)

def trop_multi_add(*args: float) -> float:
    """n-ary tropical addition: ⊕ᵢ aᵢ = min(a₁, ..., aₙ)"""
    return min(args)

# ═══════════════════════════════════════════════════════════════
# TIER 2: TROPICAL POLYNOMIALS
# ═══════════════════════════════════════════════════════════════

class TropicalPolynomial:
    """A tropical polynomial p(x) = ⊕ᵢ (cᵢ ⊗ x^⊗i) = minᵢ(cᵢ + i·x)
    
    Stored as a list of coefficients [c₀, c₁, ..., cₙ].
    
    THE FUNDAMENTAL INSIGHT:
    A tropical polynomial is a piecewise-linear concave function!
    Each monomial cᵢ + i·x is a line with slope i and y-intercept cᵢ.
    The tropical sum (min) takes the lower envelope of these lines.
    
    TROPICAL FUNDAMENTAL THEOREM OF ALGEBRA:
    A tropical polynomial of degree n has exactly n roots (counted
    with multiplicity), where a "root" is a point where the minimum
    is achieved by at least two monomials (a "bend" in the piecewise-linear graph).
    """
    
    def __init__(self, coeffs: List[float]):
        """coeffs[i] = coefficient of x^⊗i = coefficient of the line with slope i"""
        self.coeffs = coeffs
        self.degree = len(coeffs) - 1
    
    def evaluate(self, x: float) -> float:
        """Evaluate: p(x) = minᵢ(cᵢ + i·x)"""
        if x == INF:
            return min(c for c in self.coeffs if c != INF) if any(c != INF for c in self.coeffs) else INF
        vals = []
        for i, c in enumerate(self.coeffs):
            if c != INF:
                vals.append(c + i * x)
        return min(vals) if vals else INF
    
    def roots(self) -> List[float]:
        """Find tropical roots: points where the min is achieved by ≥2 monomials.
        
        At a root, cᵢ + i·x = cⱼ + j·x for some i ≠ j.
        So x = (cᵢ - cⱼ)/(j - i).
        
        The roots of the "convex hull" of the Newton polygon give the tropical roots.
        """
        # Find the lower convex hull of points (i, cᵢ)
        points = [(i, c) for i, c in enumerate(self.coeffs) if c != INF]
        if len(points) < 2:
            return []
        
        # Compute slopes between consecutive hull points = tropical roots
        hull = self._lower_convex_hull(points)
        roots = []
        for k in range(len(hull) - 1):
            i1, c1 = hull[k]
            i2, c2 = hull[k + 1]
            # Root = negative slope of hull edge
            root = (c1 - c2) / (i2 - i1)
            multiplicity = i2 - i1
            for _ in range(multiplicity):
                roots.append(root)
        return sorted(roots)
    
    def _lower_convex_hull(self, points):
        """Lower convex hull of (index, coefficient) points.
        Actually we need the hull that determines where min switches."""
        points = sorted(points)
        hull = []
        for p in points:
            while len(hull) >= 2:
                # Check if the last point is above the line from hull[-2] to p
                x1, y1 = hull[-2]
                x2, y2 = hull[-1]
                x3, y3 = p
                # Cross product: if turning right (or straight), pop
                if (x2 - x1) * (y3 - y1) - (y2 - y1) * (x3 - x1) <= 0:
                    hull.pop()
                else:
                    break
            hull.append(p)
        return hull
    
    def __repr__(self):
        terms = []
        for i, c in enumerate(self.coeffs):
            if c == INF:
                continue
            if i == 0:
                terms.append(f"{c}")
            elif i == 1:
                terms.append(f"({c} + x)")
            else:
                terms.append(f"({c} + {i}x)")
        return " ⊕ ".join(terms) if terms else "∞"

def trop_poly_add(p: TropicalPolynomial, q: TropicalPolynomial) -> TropicalPolynomial:
    """Tropical polynomial addition: (p ⊕ q)(x) = min(p(x), q(x))
    Coefficient-wise: (p⊕q)ᵢ = min(pᵢ, qᵢ)"""
    n = max(len(p.coeffs), len(q.coeffs))
    pc = p.coeffs + [INF] * (n - len(p.coeffs))
    qc = q.coeffs + [INF] * (n - len(q.coeffs))
    return TropicalPolynomial([min(a, b) for a, b in zip(pc, qc)])

def trop_poly_mul(p: TropicalPolynomial, q: TropicalPolynomial) -> TropicalPolynomial:
    """Tropical polynomial multiplication: convolution under (min, +)
    (p⊗q)ₖ = minᵢ₊ⱼ₌ₖ(pᵢ + qⱼ)
    
    This is the min-plus convolution, dual to ordinary convolution!"""
    n = p.degree + q.degree + 1
    result = [INF] * n
    for i, ci in enumerate(p.coeffs):
        for j, cj in enumerate(q.coeffs):
            if ci != INF and cj != INF:
                result[i + j] = min(result[i + j], ci + cj)
    return TropicalPolynomial(result)


# ═══════════════════════════════════════════════════════════════
# TIER 3: TROPICAL LINEAR ALGEBRA
# ═══════════════════════════════════════════════════════════════

class TropicalMatrix:
    """A matrix over the tropical semiring.
    
    Tropical matrix multiplication: (A ⊗ B)ᵢⱼ = ⊕ₖ (Aᵢₖ ⊗ Bₖⱼ) = minₖ(Aᵢₖ + Bₖⱼ)
    
    THIS IS FLOYD-WARSHALL! The (i,j) entry of A^⊗n gives the shortest path
    from i to j using at most n edges. Tropical linear algebra IS shortest-path theory.
    """
    
    def __init__(self, data: List[List[float]]):
        self.data = [row[:] for row in data]
        self.rows = len(data)
        self.cols = len(data[0]) if data else 0
    
    def __matmul__(self, other: 'TropicalMatrix') -> 'TropicalMatrix':
        """Tropical matrix multiplication"""
        assert self.cols == other.rows
        result = [[INF] * other.cols for _ in range(self.rows)]
        for i in range(self.rows):
            for j in range(other.cols):
                for k in range(self.cols):
                    val = trop_mul(self.data[i][k], other.data[k][j])
                    result[i][j] = trop_add(result[i][j], val)
        return TropicalMatrix(result)
    
    def trop_det(self) -> float:
        """Tropical determinant: tdet(A) = ⊕_σ ⊗ᵢ A_{i,σ(i)}
                                         = min over permutations σ of Σᵢ A_{i,σ(i)}
        
        This is the ASSIGNMENT PROBLEM! The tropical determinant equals
        the minimum weight perfect matching in a bipartite graph.
        Solvable in O(n³) by the Hungarian algorithm.
        """
        n = self.rows
        assert n == self.cols, "Must be square"
        
        best = INF
        for perm in permutations(range(n)):
            total = sum(self.data[i][perm[i]] for i in range(n))
            best = min(best, total)
        return best
    
    def trop_trace(self) -> float:
        """Tropical trace: tr_T(A) = ⊕ᵢ Aᵢᵢ = minᵢ Aᵢᵢ"""
        return min(self.data[i][i] for i in range(min(self.rows, self.cols)))
    
    def trop_eigenvalue(self) -> float:
        """The maximum tropical eigenvalue λ satisfies:
        A ⊗ v = λ ⊗ v  (tropically: min_j(A_{ij} + v_j) = λ + v_i for all i)
        
        By the max-plus spectral theorem, the critical eigenvalue equals
        the minimum cycle mean: λ = min over cycles C of (weight(C)/length(C))
        
        This can be computed by Karp's algorithm.
        """
        n = self.rows
        assert n == self.cols
        
        # Compute shortest paths of length exactly k: d[k][i][j]
        # d[0][i][i] = 0, d[0][i][j] = ∞ for i≠j
        d = [[[INF]*n for _ in range(n)] for _ in range(n+1)]
        for i in range(n):
            d[0][i][i] = 0
        
        for k in range(1, n+1):
            for i in range(n):
                for j in range(n):
                    for m in range(n):
                        val = d[k-1][i][m]
                        if val != INF and self.data[m][j] != INF:
                            d[k][i][j] = min(d[k][i][j], val + self.data[m][j])
        
        # Karp's algorithm: λ = min_i max_k (d[n][i][i] - d[k][i][i]) / (n - k)
        # But we use the simpler: min cycle mean
        min_mean = INF
        for i in range(n):
            if d[n][i][i] == INF:
                continue
            max_ratio = -INF
            for k in range(n):
                if d[k][i][i] != INF:
                    ratio = (d[n][i][i] - d[k][i][i]) / (n - k)
                    max_ratio = max(max_ratio, ratio)
            if max_ratio != -INF:
                min_mean = min(min_mean, max_ratio)
        
        return min_mean
    
    def kleene_star(self) -> 'TropicalMatrix':
        """Kleene star: A* = I ⊕ A ⊕ A² ⊕ A³ ⊕ ... = ⊕_{k≥0} A^k
        
        In the min-plus semiring, (A*)ᵢⱼ = shortest path distance from i to j.
        Computable by Floyd-Warshall in O(n³).
        
        The Kleene star exists (converges) iff A has no negative-weight cycles.
        """
        n = self.rows
        # Initialize with I ⊕ A
        result = [[INF]*n for _ in range(n)]
        for i in range(n):
            result[i][i] = 0  # Identity
            for j in range(n):
                result[i][j] = min(result[i][j], self.data[i][j])
        
        # Floyd-Warshall
        for k in range(n):
            for i in range(n):
                for j in range(n):
                    if result[i][k] != INF and result[k][j] != INF:
                        result[i][j] = min(result[i][j], result[i][k] + result[k][j])
        
        return TropicalMatrix(result)
    
    def trop_rank(self) -> int:
        """Tropical rank: the largest k such that there exists a k×k
        tropically non-singular submatrix.
        
        A matrix is tropically singular if the minimum in the tropical
        determinant is achieved by ≥2 permutations.
        
        Tropical rank ≤ classical rank, but can be strictly less!
        """
        n = min(self.rows, self.cols)
        for k in range(n, 0, -1):
            # Check all k×k submatrices
            from itertools import combinations
            for rows in combinations(range(self.rows), k):
                for cols in combinations(range(self.cols), k):
                    sub = TropicalMatrix([[self.data[i][j] for j in cols] for i in rows])
                    if self._is_tropically_nonsingular(sub):
                        return k
        return 0
    
    @staticmethod
    def _is_tropically_nonsingular(A: 'TropicalMatrix') -> bool:
        """A is tropically non-singular if the tropical determinant
        is achieved by exactly one permutation."""
        n = A.rows
        best = INF
        count = 0
        for perm in permutations(range(n)):
            total = sum(A.data[i][perm[i]] for i in range(n))
            if total < best:
                best = total
                count = 1
            elif total == best:
                count += 1
        return count == 1
    
    def __repr__(self):
        rows_str = []
        for row in self.data:
            rows_str.append("[" + ", ".join(f"{x:6.1f}" if x != INF else "   ∞  " for x in row) + "]")
        return "\n".join(rows_str)


# ═══════════════════════════════════════════════════════════════
# TIER 4: TROPICAL ANALYSIS
# ═══════════════════════════════════════════════════════════════

def tropical_fourier_transform(f: Callable[[float], float], 
                                xi: float, 
                                sample_range=(-10, 10), 
                                n_samples=1000) -> float:
    """Tropical Fourier Transform: f̂(ξ) = ⊕_x (f(x) ⊗ ξ·x) = inf_x (f(x) + ξ·x)
    
    THIS IS THE LEGENDRE-FENCHEL TRANSFORM (up to sign)!
    
    The classical Fourier transform: F̂(ξ) = ∫ f(x) · e^{iξx} dx
    Under Maslov dequantization (ℏ→0):
    - ∫ → inf (sum → min)
    - · → + (multiply → add)
    - e^{iξx} → ξ·x
    
    So the tropical Fourier transform is EXACTLY the convex conjugate.
    
    Properties preserved from classical FT:
    - Tropical convolution theorem: FT(f ⊗_conv g) = FT(f) ⊕... wait, actually:
      FT of infimal convolution = pointwise sum
    - Involution: FT(FT(f)) = f for convex f (Fenchel-Moreau theorem!)
    """
    lo, hi = sample_range
    xs = np.linspace(lo, hi, n_samples)
    vals = [f(x) + xi * x for x in xs]
    return min(vals)

def tropical_convolution(f: Callable[[float], float], 
                         g: Callable[[float], float],
                         z: float,
                         sample_range=(-10, 10),
                         n_samples=1000) -> float:
    """Tropical convolution: (f ⊛ g)(z) = ⊕_x (f(x) ⊗ g(z⊘x)) = inf_x (f(x) + g(z-x))
    
    This is the INFIMAL CONVOLUTION from convex analysis!
    
    Key theorem: The tropical FT of a tropical convolution is the
    tropical product (= classical sum) of the tropical FTs:
    FT(f ⊛ g) = FT(f) ⊗ FT(g)  i.e.  (f⊛g)*(ξ) = f*(ξ) + g*(ξ)
    
    This is the direct analog of FT(f*g) = FT(f)·FT(g) in classical analysis.
    """
    lo, hi = sample_range
    xs = np.linspace(lo, hi, n_samples)
    vals = [f(x) + g(z - x) for x in xs]
    return min(vals)

def tropical_derivative(f: Callable[[float], float], x: float, h: float = 1e-6) -> float:
    """Tropical derivative: Df(x) = lim_{ε→0} (f(x+ε) ⊘ f(x)) ⊘ ε
                                  = lim_{ε→0} (f(x+ε) - f(x)) / ε
    
    For piecewise-linear functions (which tropical polynomials are),
    this is just the slope of the current linear piece!
    
    The tropical derivative is the CLASSICAL derivative for piecewise-linear functions.
    At bend points (tropical roots), it has a jump discontinuity.
    """
    return (f(x + h) - f(x)) / h

def tropical_integral(f: Callable[[float], float], 
                      a: float, b: float, 
                      n_samples: int = 1000) -> float:
    """Tropical integral: ⊕_{[a,b]} f = inf_{x ∈ [a,b]} f(x)
    
    The tropical integral is just the infimum!
    Since the tropical sum is min, integrating (= continuous summing) gives inf.
    
    Properties:
    - Monotone: if f ≤ g then ∫_T f ≤ ∫_T g  (in the tropical order)
    - Additive over ⊗: ∫_T (f ⊗ g) = ∫_T f ⊗ ∫_T g ... NO! Not true.
    - But: ∫_T (c ⊗ f) = c ⊗ ∫_T f  (i.e., inf(c + f(x)) = c + inf f(x))
    """
    xs = np.linspace(a, b, n_samples)
    return min(f(x) for x in xs)


# ═══════════════════════════════════════════════════════════════
# TIER 5: TROPICAL GEOMETRY
# ═══════════════════════════════════════════════════════════════

def tropical_line_2d(a: float, b: float, c: float) -> Callable:
    """A tropical line in T² is defined by: a⊗x ⊕ b⊗y ⊕ c = min(a+x, b+y, c)
    
    The "line" is the set of points where the minimum is achieved by ≥2 terms.
    This gives a TREE with 3 rays emanating from the vertex (-a+c, -b+c) — no wait,
    the vertex is where all three terms are equal.
    
    a+x = b+y = c  →  x = c-a, y = c-b
    
    Three rays:
    1. x ≤ c-a, y = c-b (ray going left)
    2. y ≤ c-b, x = c-a (ray going down)  
    3. x-y = (b-a), x ≥ c-a (ray going up-right with slope 1)
    """
    def point_on_line(x, y):
        terms = [a + x, b + y, c]
        m = min(terms)
        count = sum(1 for t in terms if abs(t - m) < 1e-10)
        return count >= 2
    return point_on_line

def tropical_curve_points(poly_2d: List[Tuple[int, int, float]], 
                          grid_range=(-5, 5), resolution=200):
    """Compute points on a tropical curve in ℝ².
    
    A tropical curve is the corner locus of a tropical polynomial in 2 variables:
    p(x,y) = ⊕_{(i,j)} c_{ij} ⊗ x^i ⊗ y^j = min_{(i,j)} (c_{ij} + ix + jy)
    
    The curve is the set where the min is achieved by ≥2 monomials.
    
    FUNDAMENTAL THEOREM: Tropical curves are balanced polyhedral complexes.
    Each edge has a rational slope and a positive integer weight satisfying
    the balancing condition at each vertex.
    """
    lo, hi = grid_range
    xs = np.linspace(lo, hi, resolution)
    ys = np.linspace(lo, hi, resolution)
    
    curve_points = []
    for x in xs:
        for y in ys:
            vals = [c + i*x + j*y for i, j, c in poly_2d]
            m = min(vals)
            # Count how many monomials achieve the minimum
            achievers = sum(1 for v in vals if abs(v - m) < 0.05 * (hi - lo) / resolution)
            if achievers >= 2:
                curve_points.append((x, y))
    
    return curve_points

def tropical_convex_hull(points: List[List[float]]) -> List[List[float]]:
    """Tropical convex hull of a set of points.
    
    A set S is tropically convex if for all x, y ∈ S and all λ, μ ∈ T:
    λ⊗x ⊕ μ⊗y ∈ S, where operations are componentwise.
    i.e., (min(λ+x₁, μ+y₁), ..., min(λ+xₙ, μ+yₙ)) ∈ S
    
    Tropical convex hull = intersection of all tropically convex sets containing the points.
    
    KEY INSIGHT: Tropical convexity is the image of classical convexity under
    the logarithm map! (Viro, 2001)
    """
    # Approximate by sampling tropical combinations
    hull_points = list(points)
    for _ in range(100):
        for i in range(len(points)):
            for j in range(i+1, len(points)):
                for lam in np.linspace(-5, 5, 20):
                    for mu in np.linspace(-5, 5, 20):
                        new_point = [min(lam + points[i][k], mu + points[j][k]) 
                                    for k in range(len(points[0]))]
                        hull_points.append(new_point)
    return hull_points


# ═══════════════════════════════════════════════════════════════
# TIER 6: TROPICAL LOGIC — THE SAT CONNECTION
# ═══════════════════════════════════════════════════════════════

def boolean_to_tropical(b: bool) -> float:
    """Embed Boolean into tropical: True → 0 (tropical one), False → ∞ (tropical zero)
    
    Under this embedding:
    - OR → ⊕ (min):  T∨F = min(0,∞) = 0 = T  ✓
    - AND → ⊗ (+):   T∧T = 0+0 = 0 = T  ✓, T∧F = 0+∞ = ∞ = F  ✓
    - NOT: requires leaving the semiring (no additive inverses!)
    
    This means SAT (without negation) is directly encodable.
    For negation, we use the EXTENDED tropical semiring with a "twist".
    """
    return 0.0 if b else INF

def tropical_or(a: float, b: float) -> float:
    """Boolean OR via tropical addition"""
    return trop_add(a, b)  # min(a, b)

def tropical_and(a: float, b: float) -> float:
    """Boolean AND via tropical multiplication"""
    return trop_mul(a, b)  # a + b

def tropical_not_approx(a: float, M: float = 1000.0) -> float:
    """Approximate NOT using tropical operations.
    
    In the pure tropical semiring, NOT doesn't exist.
    But we can approximate it: NOT(x) ≈ M ⊘ x = M - x
    where M is a large constant.
    
    For x = 0 (True):  NOT ≈ M (large = "very false")
    For x = ∞ (False): NOT ≈ -∞ (but we clamp to 0)
    
    This is a SOFT negation, analogous to how LogSumExp softens min.
    """
    if a == INF:
        return 0.0
    return max(0, M - a)


# ═══════════════════════════════════════════════════════════════
# DEMONSTRATIONS
# ═══════════════════════════════════════════════════════════════

def demo_tier0():
    """Demonstrate the mind-bending properties of tropical atoms."""
    print("=" * 70)
    print("TIER 0: THE TROPICAL ATOMS — Where 3 + 3 = 3")
    print("=" * 70)
    
    print("\n⊕ (Tropical Addition = min):")
    print(f"  3 ⊕ 5 = min(3,5) = {trop_add(3, 5)}")
    print(f"  3 ⊕ 3 = min(3,3) = {trop_add(3, 3)}  ← IDEMPOTENT! 3 'plus' 3 = 3")
    print(f"  3 ⊕ ∞ = min(3,∞) = {trop_add(3, INF)}  ← ∞ is the additive identity")
    
    print("\n⊗ (Tropical Multiplication = +):")
    print(f"  3 ⊗ 5 = 3+5 = {trop_mul(3, 5)}")
    print(f"  3 ⊗ 0 = 3+0 = {trop_mul(3, 0)}  ← 0 is the multiplicative identity")
    print(f"  3 ⊗ ∞ = 3+∞ = {trop_mul(3, INF)}  ← ∞ absorbs")
    
    print("\nDistributivity: a ⊗ (b ⊕ c) = (a⊗b) ⊕ (a⊗c)")
    a, b, c = 2, 3, 5
    lhs = trop_mul(a, trop_add(b, c))
    rhs = trop_add(trop_mul(a, b), trop_mul(a, c))
    print(f"  {a} ⊗ ({b} ⊕ {c}) = {a} + min({b},{c}) = {lhs}")
    print(f"  ({a}⊗{b}) ⊕ ({a}⊗{c}) = min({a}+{b}, {a}+{c}) = {rhs}")
    print(f"  Equal? {lhs == rhs} ✓")

def demo_tier1():
    """Demonstrate derived scalar operations."""
    print("\n" + "=" * 70)
    print("TIER 1: DERIVED SCALARS — Where x² = 2x")
    print("=" * 70)
    
    print("\nTropical Powers: a^⊗n = n·a")
    for a in [3, -2, 0]:
        for n in [2, 3, 5]:
            print(f"  {a}^⊗{n} = {n}·{a} = {trop_pow(a, n)}")
    
    print("\nTropical Negation (multiplicative inverse):")
    for a in [3, -2, 7]:
        print(f"  -{a}_T = {trop_neg(a)},  verify: {a} ⊗ {trop_neg(a)} = {trop_mul(a, trop_neg(a))} = 0 ✓")
    
    print("\nTropical Absolute Value: |a|_T = min(a, -a)")
    for a in [-3, -1, 0, 1, 3]:
        print(f"  |{a}|_T = min({a}, {-a}) = {trop_abs(a)}")
    print("  Note: |a|_T ≤ 0 always! (tropical abs is ≤ tropical one)")

def demo_tier2():
    """Demonstrate tropical polynomials."""
    print("\n" + "=" * 70)
    print("TIER 2: TROPICAL POLYNOMIALS — Piecewise Linear Functions")
    print("=" * 70)
    
    # p(x) = 3 ⊕ (1⊗x) ⊕ (0⊗x²) = min(3, 1+x, 2x)
    p = TropicalPolynomial([3, 1, 0])
    print(f"\np(x) = {p}")
    print("     = min(3, 1+x, 2x)")
    
    print("\nEvaluations:")
    for x in [-2, -1, 0, 1, 2, 3, 4]:
        print(f"  p({x}) = min(3, {1+x}, {2*x}) = {p.evaluate(x)}")
    
    roots = p.roots()
    print(f"\nTropical roots: {roots}")
    print("  (Points where the piecewise-linear function bends)")
    print("  Root at x=1: where (1+x)=(2x) → x=1")
    print("  Root at x=2: where 3=(1+x) → x=2")
    
    # Tropical FTA
    print("\n★ TROPICAL FUNDAMENTAL THEOREM OF ALGEBRA:")
    print(f"  Degree {p.degree} polynomial has {len(roots)} roots ✓")
    
    # Polynomial multiplication
    q = TropicalPolynomial([2, 0])  # min(2, x)
    pq = trop_poly_mul(p, q)
    print(f"\nq(x) = {q}")
    print(f"p ⊗ q = {pq}")
    print(f"Roots of p: {p.roots()}")
    print(f"Roots of q: {q.roots()}")
    print(f"Roots of p⊗q: {pq.roots()}")
    print("  (Union of roots, counting multiplicity)")

def demo_tier3():
    """Demonstrate tropical linear algebra."""
    print("\n" + "=" * 70)
    print("TIER 3: TROPICAL LINEAR ALGEBRA — Shortest Paths Are Matrix Powers")
    print("=" * 70)
    
    # Adjacency matrix of a weighted graph
    A = TropicalMatrix([
        [INF,   2,   INF,  INF],
        [INF,  INF,   3,    7],
        [INF,  INF,  INF,   1],
        [ 4,   INF,  INF,  INF]
    ])
    print("\nWeighted directed graph (adjacency matrix):")
    print(A)
    
    print(f"\nTropical trace: min diagonal = {A.trop_trace()}")
    
    # A² = shortest 2-edge paths
    A2 = A @ A
    print("\nA² (shortest 2-edge paths):")
    print(A2)
    
    # Kleene star = all shortest paths
    Astar = A.kleene_star()
    print("\nA* = Kleene star (ALL shortest paths, Floyd-Warshall):")
    print(Astar)
    
    # Eigenvalue
    lam = A.trop_eigenvalue()
    print(f"\nTropical eigenvalue (min cycle mean): λ = {lam}")
    print(f"  (Average edge weight on the lightest cycle)")
    
    # Determinant
    B = TropicalMatrix([
        [1, 2, 3],
        [4, 0, 5],
        [2, 1, 0]
    ])
    print(f"\nTropical determinant of")
    print(B)
    print(f"tdet = min over permutations of Σᵢ B_{{i,σ(i)}} = {B.trop_det()}")
    print("  = minimum weight perfect matching (Assignment Problem!)")

def demo_tier4():
    """Demonstrate tropical analysis."""
    print("\n" + "=" * 70)
    print("TIER 4: TROPICAL ANALYSIS — Legendre Transforms Are Fourier Transforms")
    print("=" * 70)
    
    # f(x) = x² (a convex function)
    f = lambda x: x**2
    
    print("\nTropical Fourier Transform of f(x) = x²:")
    print("  f̂(ξ) = inf_x (x² + ξx) = -ξ²/4  (the Legendre-Fenchel transform)")
    for xi in [-4, -2, 0, 2, 4]:
        ft = tropical_fourier_transform(f, xi)
        exact = -xi**2 / 4
        print(f"  f̂({xi}) ≈ {ft:.4f}  (exact: {exact:.4f})")
    
    print("\nTropical Convolution (= Infimal Convolution):")
    g = lambda x: abs(x)
    h = lambda x: x**2
    for z in [-2, 0, 2]:
        conv = tropical_convolution(g, h, z)
        print(f"  (|·| ⊛ (·)²)({z}) = inf_x (|x| + (z-x)²) ≈ {conv:.4f}")
    
    print("\nTropical Integral (= Infimum):")
    integral = tropical_integral(lambda x: (x-1)**2 + 3, -5, 5)
    print(f"  ∫_T[-5,5] ((x-1)² + 3) = inf_{{x∈[-5,5]}} ((x-1)² + 3) = {integral:.4f}")
    print(f"  (Exact: 3.0, achieved at x=1)")
    
    print("\n★ THE GRAND ANALOGY:")
    print("  Classical:  ∫ f(x)·g(ξ-x) dx    (convolution)")
    print("  Tropical:   inf_x [f(x)+g(ξ-x)]  (infimal convolution)")
    print("  Classical:  FT(f*g) = FT(f)·FT(g)")
    print("  Tropical:   LF(f⊛g) = LF(f)+LF(g)  ← Legendre-Fenchel!")

def demo_tier5():
    """Demonstrate tropical geometry."""
    print("\n" + "=" * 70)
    print("TIER 5: TROPICAL GEOMETRY — Where Lines Are Trees")
    print("=" * 70)
    
    print("\nA tropical line min(a+x, b+y, c):")
    print("  With a=0, b=0, c=0: vertex at (0,0)")
    print("  Three rays: left, down, and diagonal (slope 1)")
    
    is_on_line = tropical_line_2d(0, 0, 0)
    on_count = 0
    for x in np.linspace(-3, 3, 61):
        for y in np.linspace(-3, 3, 61):
            if is_on_line(x, y):
                on_count += 1
    print(f"  Points on the tropical line (grid check): {on_count}")
    
    print("\nTropical curve: min(0, x, y, 1+x+y)")
    print("  This is a tropical conic (degree 2 curve in TP²)")
    curve = tropical_curve_points(
        [(0, 0, 0), (1, 0, 0), (0, 1, 0), (1, 1, 1)],
        grid_range=(-3, 3), resolution=100
    )
    print(f"  Found {len(curve)} approximate curve points")

def demo_tier6():
    """Demonstrate the Boolean-tropical connection."""
    print("\n" + "=" * 70)
    print("TIER 6: TROPICAL LOGIC — SAT Lives in the Tropics")
    print("=" * 70)
    
    T, F = boolean_to_tropical(True), boolean_to_tropical(False)
    print(f"\n  True  → {T} (tropical one)")
    print(f"  False → {F} (tropical zero)")
    
    print("\n  OR truth table via tropical ⊕ (min):")
    for a in [True, False]:
        for b in [True, False]:
            ta, tb = boolean_to_tropical(a), boolean_to_tropical(b)
            result = tropical_or(ta, tb)
            classical = a or b
            print(f"    {a} OR {b} = {classical},  {ta} ⊕ {tb} = {result} → {result == 0.0}  {'✓' if (result == 0.0) == classical else '✗'}")
    
    print("\n  AND truth table via tropical ⊗ (+):")
    for a in [True, False]:
        for b in [True, False]:
            ta, tb = boolean_to_tropical(a), boolean_to_tropical(b)
            result = tropical_and(ta, tb)
            classical = a and b
            print(f"    {a} AND {b} = {classical},  {ta} ⊗ {tb} = {result} → {result == 0.0}  {'✓' if (result == 0.0) == classical else '✗'}")
    
    print("\n★ KEY INSIGHT: SAT clauses are tropical polynomials!")
    print("  Clause (x₁ ∨ x₂ ∨ x₃) = x₁ ⊕ x₂ ⊕ x₃ = min(x₁, x₂, x₃)")
    print("  CNF conjunction = ⊗ of clauses = sum of mins")
    print("  SAT ↔ tropical polynomial evaluates to 0 (= True)")


def demo_taxonomy_summary():
    """Print the complete taxonomy."""
    print("\n" + "=" * 70)
    print("THE COMPLETE TROPICAL ALPHABET — A Taxonomy")
    print("=" * 70)
    
    taxonomy = {
        "TIER 0 — ATOMS (The Two Primitive Operations)": {
            "⊕ (trop_add)": "min(a,b) — idempotent, commutative, associative",
            "⊗ (trop_mul)": "a + b — commutative, associative, distributes over ⊕",
            "𝟘 (trop_zero)": "+∞ — additive identity",
            "𝟙 (trop_one)": "0 — multiplicative identity",
        },
        "TIER 1 — DERIVED SCALARS": {
            "a^⊗n (trop_pow)": "n·a — tropical exponentiation IS classical multiplication",
            "a⁻¹ (trop_neg)": "-a — multiplicative inverse (no additive inverse exists!)",
            "a ⊘ b (trop_div)": "a - b — tropical division",
            "|a|_T (trop_abs)": "min(a,-a) — always ≤ 0",
        },
        "TIER 2 — POLYNOMIALS": {
            "p(x) = ⊕ᵢ cᵢ⊗x^⊗i": "min_i(c_i + i·x) — piecewise linear!",
            "Tropical roots": "Bend points of the piecewise-linear graph",
            "p ⊕ q": "Coefficient-wise min",
            "p ⊗ q": "Min-plus convolution of coefficients",
            "Newton polygon": "Encodes root structure via convex hull",
        },
        "TIER 3 — LINEAR ALGEBRA": {
            "(A⊗B)ᵢⱼ": "min_k(A_ik + B_kj) — shortest path composition",
            "tdet(A)": "min_σ Σᵢ A_{i,σ(i)} — assignment problem!",
            "A* (Kleene star)": "⊕_{k≥0} A^k — all-pairs shortest paths",
            "λ (eigenvalue)": "Minimum cycle mean — Karp's algorithm",
            "Tropical rank": "Largest non-singular submatrix size",
        },
        "TIER 4 — ANALYSIS (Idempotent Analysis)": {
            "f̂(ξ) = inf_x(f(x)+ξx)": "Tropical FT = Legendre-Fenchel transform!",
            "(f⊛g)(z) = inf_x(f(x)+g(z-x))": "Tropical convolution = infimal convolution",
            "∫_T f = inf f": "Tropical integral = infimum",
            "Df(x)": "Classical derivative (for PL functions = slope)",
        },
        "TIER 5 — GEOMETRY": {
            "Tropical line": "A tree with 3 rays — NOT a line!",
            "Tropical curve": "Balanced polyhedral complex (1-skeleton of Newton polytope dual)",
            "Tropical variety": "Corner locus of a tropical polynomial map",
            "Tropical convex hull": "Image of log-map of classical convex hull",
        },
        "TIER 6 — LOGIC": {
            "True → 0, False → ∞": "Boolean embedding",
            "OR = ⊕": "min(0,∞) = 0 = True ✓",
            "AND = ⊗": "0+0 = 0 = True; 0+∞ = ∞ = False ✓",
            "SAT clause = ⊕ of vars": "min of variable values",
            "CNF = ⊗ of clauses": "Sum of clause values; = 0 iff satisfiable",
        },
    }
    
    for tier, ops in taxonomy.items():
        print(f"\n  {tier}")
        for name, desc in ops.items():
            print(f"    {name:30s} │ {desc}")
    
    print("\n" + "=" * 70)
    print("CROSS-CUTTING THEMES")
    print("=" * 70)
    print("""
  1. DEQUANTIZATION: Every classical operation has a tropical shadow.
     Classical → Tropical under the map log(Σ exp(·/ε)) as ε→0.
     
  2. PIECEWISE LINEARITY: Every tropical polynomial is piecewise linear.
     This is why tropical geometry connects to polyhedral combinatorics.
     
  3. OPTIMIZATION DUALITY: Tropical analysis IS convex optimization.
     Fourier transform = Legendre-Fenchel, convolution = infimal conv.
     
  4. SHORTEST PATHS: Tropical linear algebra IS graph algorithms.
     Matrix multiplication = path composition, Kleene star = Floyd-Warshall.
     
  5. NO SUBTRACTION: The deepest asymmetry. a ⊕ b = a implies b is 
     "absorbed". Information is lost. This is why tropical geometry has
     a fundamentally different character from classical algebraic geometry.
     
  6. IDEMPOTENCY: a ⊕ a = a. This single property (min(a,a)=a) ripples
     through the entire theory, making tropical algebra "maximally 
     non-cancellative" and connecting to lattice theory.
""")


if __name__ == "__main__":
    demo_tier0()
    demo_tier1()
    demo_tier2()
    demo_tier3()
    demo_tier4()
    demo_tier5()
    demo_tier6()
    demo_taxonomy_summary()

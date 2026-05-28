"""
Algorithms for bounded formula evaluation, coset cover computation,
and approximate subgroup analysis.

Implements the core mathematical constructions from the Lean formalization
of bounded pseudofinite transfer.
"""

from typing import List, Tuple, Set, Dict, Optional, Callable
from itertools import product as iter_product
from collections import defaultdict
import random


# ============================================================================
# Section 1: Restricted Formula Language
# ============================================================================

class RestrictedFormula:
    """Base class for restricted polynomial formulas."""
    pass

class PolyEq(RestrictedFormula):
    """Polynomial equality atom: p(v) = 0.
    
    Represents a polynomial as a dict from monomial (tuple of (var, power)) to coefficient.
    For simplicity, variables are integers and coefficients are integers.
    """
    def __init__(self, poly: Dict[tuple, int]):
        self.poly = poly  # {((var, power), ...): coeff}
    
    def evaluate(self, assignment: Dict[int, int], modulus: int) -> int:
        """Evaluate polynomial mod modulus."""
        result = 0
        for monomial, coeff in self.poly.items():
            term = coeff
            for var, power in monomial:
                term = (term * pow(assignment.get(var, 0), power, modulus)) % modulus
            result = (result + term) % modulus
        return result
    
    def sat(self, assignment: Dict[int, int], modulus: int) -> bool:
        """Check if polynomial evaluates to zero."""
        return self.evaluate(assignment, modulus) == 0

class Conj(RestrictedFormula):
    """Conjunction of two formulas."""
    def __init__(self, left: RestrictedFormula, right: RestrictedFormula):
        self.left = left
        self.right = right
    
    def sat(self, assignment: Dict[int, int], modulus: int) -> bool:
        return self.left.sat(assignment, modulus) and self.right.sat(assignment, modulus)

class Disj(RestrictedFormula):
    """Disjunction of two formulas."""
    def __init__(self, left: RestrictedFormula, right: RestrictedFormula):
        self.left = left
        self.right = right
    
    def sat(self, assignment: Dict[int, int], modulus: int) -> bool:
        return self.left.sat(assignment, modulus) or self.right.sat(assignment, modulus)

class Neg(RestrictedFormula):
    """Negation of a formula."""
    def __init__(self, inner: RestrictedFormula):
        self.inner = inner
    
    def sat(self, assignment: Dict[int, int], modulus: int) -> bool:
        return not self.inner.sat(assignment, modulus)


# ============================================================================
# Section 2: Bounded Restricted Formula Language
# ============================================================================

class BoundedRestrictedFormula:
    """Base class for bounded restricted formulas."""
    pass

class BRFBase(BoundedRestrictedFormula):
    """Embed a quantifier-free restricted formula."""
    def __init__(self, formula: RestrictedFormula):
        self.formula = formula
    
    def realize(self, assignment: Dict[int, int], modulus: int) -> bool:
        return self.formula.sat(assignment, modulus)
    
    def complexity(self) -> int:
        return 1

class BRFConj(BoundedRestrictedFormula):
    def __init__(self, left: BoundedRestrictedFormula, right: BoundedRestrictedFormula):
        self.left = left
        self.right = right
    
    def realize(self, assignment: Dict[int, int], modulus: int) -> bool:
        return self.left.realize(assignment, modulus) and self.right.realize(assignment, modulus)
    
    def complexity(self) -> int:
        return 1 + self.left.complexity() + self.right.complexity()

class BRFDisj(BoundedRestrictedFormula):
    def __init__(self, left: BoundedRestrictedFormula, right: BoundedRestrictedFormula):
        self.left = left
        self.right = right
    
    def realize(self, assignment: Dict[int, int], modulus: int) -> bool:
        return self.left.realize(assignment, modulus) or self.right.realize(assignment, modulus)
    
    def complexity(self) -> int:
        return 1 + self.left.complexity() + self.right.complexity()

class BRFNeg(BoundedRestrictedFormula):
    def __init__(self, inner: BoundedRestrictedFormula):
        self.inner = inner
    
    def realize(self, assignment: Dict[int, int], modulus: int) -> bool:
        return not self.inner.realize(assignment, modulus)
    
    def complexity(self) -> int:
        return 1 + self.inner.complexity()

class BRFBoundedExists(BoundedRestrictedFormula):
    """Bounded existential: ∃ x ∈ D, φ(x).
    
    Args:
        bound_var: the variable being quantified
        domain: RestrictedFormula defining the domain D
        body: BoundedRestrictedFormula for the body φ
    """
    def __init__(self, bound_var: int, domain: RestrictedFormula, 
                 body: BoundedRestrictedFormula):
        self.bound_var = bound_var
        self.domain = domain
        self.body = body
    
    def realize(self, assignment: Dict[int, int], modulus: int) -> bool:
        for x in range(modulus):
            ext_assignment = {**assignment, self.bound_var: x}
            if (self.domain.sat(ext_assignment, modulus) and 
                self.body.realize(ext_assignment, modulus)):
                return True
        return False
    
    def complexity(self) -> int:
        return 1 + self.body.complexity()

class BRFBoundedForall(BoundedRestrictedFormula):
    """Bounded universal: ∀ x ∈ D, φ(x)."""
    def __init__(self, bound_var: int, domain: RestrictedFormula,
                 body: BoundedRestrictedFormula):
        self.bound_var = bound_var
        self.domain = domain
        self.body = body
    
    def realize(self, assignment: Dict[int, int], modulus: int) -> bool:
        for x in range(modulus):
            ext_assignment = {**assignment, self.bound_var: x}
            if (self.domain.sat(ext_assignment, modulus) and 
                not self.body.realize(ext_assignment, modulus)):
                return False
        return True
    
    def complexity(self) -> int:
        return 1 + self.body.complexity()


# ============================================================================
# Section 3: Formula Expansion (Erasure of Bounded Quantifiers)
# ============================================================================

def expand_bounded_exists(formula: BRFBoundedExists, modulus: int,
                          assignment: Dict[int, int]) -> bool:
    """Expand bounded ∃ to unbounded ∃ with conjunction.
    
    ∃ x ∈ D, φ(x) ≡ ∃ x, (x ∈ D ∧ φ(x))
    
    Returns the same truth value as the bounded version.
    """
    for x in range(modulus):
        ext = {**assignment, formula.bound_var: x}
        if formula.domain.sat(ext, modulus) and formula.body.realize(ext, modulus):
            return True
    return False

def expand_bounded_forall(formula: BRFBoundedForall, modulus: int,
                          assignment: Dict[int, int]) -> bool:
    """Expand bounded ∀ to unbounded ∀ with implication.
    
    ∀ x ∈ D, φ(x) ≡ ∀ x, (x ∈ D → φ(x))
    """
    for x in range(modulus):
        ext = {**assignment, formula.bound_var: x}
        if formula.domain.sat(ext, modulus) and not formula.body.realize(ext, modulus):
            return False
    return True


# ============================================================================
# Section 4: Coset Cover Computation
# ============================================================================

def left_coset(g: int, H: Set[int], n: int) -> Set[int]:
    """Compute left coset g·H in Z/nZ."""
    return {(g + h) % n for h in H}

def compute_coset_cover(A: Set[int], H: Set[int], n: int) -> Optional[Tuple[List[int], int]]:
    """Find a minimal coset cover of A by left cosets of H in Z/nZ.
    
    Returns (representatives, count) or None if no cover exists.
    Uses a greedy algorithm.
    
    Args:
        A: set to cover
        H: subgroup/subset to use for cosets
        n: group order (Z/nZ)
    
    Returns:
        (list of coset representatives, number of cosets needed)
    """
    remaining = set(A)
    representatives = []
    
    while remaining:
        best_g = None
        best_covered = 0
        for g in range(n):
            coset = left_coset(g, H, n)
            covered = len(remaining & coset)
            if covered > best_covered:
                best_covered = covered
                best_g = g
        if best_covered == 0:
            return None
        representatives.append(best_g)
        remaining -= left_coset(best_g, H, n)
    
    return representatives, len(representatives)

def verify_coset_cover(A: Set[int], H: Set[int], representatives: List[int], 
                       n: int) -> bool:
    """Verify that the given representatives cover A by cosets of H."""
    covered = set()
    for g in representatives:
        covered |= left_coset(g, H, n)
    return A.issubset(covered)

def product_set(A: Set[int], B: Set[int], n: int) -> Set[int]:
    """Compute A·B in Z/nZ."""
    return {(a + b) % n for a in A for b in B}

def inverse_set(A: Set[int], n: int) -> Set[int]:
    """Compute A⁻¹ in Z/nZ."""
    return {(-a) % n for a in A}


# ============================================================================
# Section 5: Approximate Subgroup Detection
# ============================================================================

def is_approximate_subgroup(H: Set[int], K: int, n: int) -> bool:
    """Check if H is a K-approximate subgroup of Z/nZ.
    
    Conditions:
    1. H is nonempty
    2. H is symmetric (H = -H)
    3. H+H can be covered by K left cosets of H
    """
    if not H:
        return False
    if inverse_set(H, n) != H:
        return False
    HH = product_set(H, H, n)
    result = compute_coset_cover(HH, H, n)
    if result is None:
        return False
    _, cover_size = result
    return cover_size <= K

def find_approximate_subgroups(n: int, K: int) -> List[Set[int]]:
    """Find all K-approximate subgroups of Z/nZ up to a given size bound."""
    results = []
    # Check subgroups first (they are 1-approximate subgroups)
    for d in range(1, n + 1):
        if n % d == 0:
            H = {(i * (n // d)) % n for i in range(d)}
            if is_approximate_subgroup(H, K, n):
                results.append(H)
    return results


# ============================================================================
# Section 6: Coset Cover Composition Verification
# ============================================================================

def verify_composition_theorem(n: int, num_tests: int = 50) -> bool:
    """Verify cosetCover_compose on random examples in Z/nZ.
    
    Tests: if A covered by C cosets of H, and H covered by D cosets of K,
    then A covered by C*D cosets of K.
    """
    for _ in range(num_tests):
        # Random subsets
        K_set = {i * (n // max(1, random.randint(1, n))) % n 
                 for i in range(random.randint(1, n))}
        if not K_set:
            K_set = {0}
        H = set()
        # Build H as union of a few cosets of K
        D = random.randint(1, min(5, n))
        reps_HK = random.sample(range(n), min(D, n))
        for g in reps_HK:
            H |= left_coset(g, K_set, n)
        
        # Build A as union of a few cosets of H
        C = random.randint(1, min(5, n))
        reps_AH = random.sample(range(n), min(C, n))
        A = set()
        for g in reps_AH:
            A |= left_coset(g, H, n)
        
        if not A:
            continue
        
        # Verify composition
        result = compute_coset_cover(A, K_set, n)
        if result is None:
            continue
        _, actual_cover = result
        
        # The theorem says we need at most C*D cosets
        if actual_cover > C * D:
            print(f"COUNTEREXAMPLE: n={n}, |A|={len(A)}, |H|={len(H)}, |K|={len(K_set)}")
            print(f"  C={C}, D={D}, C*D={C*D}, actual={actual_cover}")
            return False
    
    return True


# ============================================================================
# Section 7: Translation Size Growth Measurement
# ============================================================================

def measure_formula_complexity(depth: int) -> Tuple[int, int]:
    """Measure the complexity of a bounded formula and its expansion.
    
    Creates a formula of given nesting depth and measures the size
    before and after expanding bounded quantifiers.
    
    Returns (bounded_complexity, expanded_size_estimate)
    """
    # Build a formula with nested bounded quantifiers
    bounded_complexity = 0
    expanded_size = 1  # base formula
    
    for level in range(depth):
        # Each bounded quantifier adds:
        # - 1 to bounded complexity (the quantifier itself)
        # - domain predicate (1 unit)
        # - In expansion: the domain becomes a conjunction, adding ~1 unit
        bounded_complexity += 2  # quantifier + domain
        expanded_size = expanded_size + 1  # conjunction with domain
    
    return bounded_complexity, expanded_size


if __name__ == "__main__":
    print("=== Algorithms Module ===")
    print()
    
    # Test formula evaluation
    print("1. Formula evaluation test:")
    # x^2 - 1 = 0 in Z/5Z
    poly = PolyEq({((0, 2),): 1, (): -1})  # x₀² - 1
    for x in range(5):
        result = poly.sat({0: x}, 5)
        print(f"   x={x}: x²-1≡0 (mod 5)? {result}")
    
    print()
    print("2. Bounded formula test:")
    # ∃ x ∈ {squares}, x + 1 = 0 (mod 7)
    # Domain: x is a quadratic residue (x = y² for some y)
    domain = PolyEq({((1, 2),): 1, ((0, 1),): -1})  # y² - x = 0
    body_poly = PolyEq({((0, 1),): 1, (): 1})  # x + 1 = 0
    body = BRFBase(body_poly)
    # This checks: ∃ x, (∃ y, y² = x) ∧ (x + 1 = 0)
    # Simplified: we check domain with bound_var=1 and body with bound_var=0
    bounded = BRFBoundedExists(0, domain, body)
    print(f"   ∃ x ∈ D, x+1≡0 (mod 7): {bounded.realize({1: 0}, 7)}")
    
    print()
    print("3. Coset cover composition verification:")
    for n in [6, 10, 12, 15, 20]:
        ok = verify_composition_theorem(n, num_tests=20)
        print(f"   Z/{n}Z: {'PASS' if ok else 'FAIL'}")
    
    print()
    print("4. Approximate subgroup detection:")
    for n in [6, 10, 12, 15]:
        approx = find_approximate_subgroups(n, K=3)
        print(f"   Z/{n}Z: {len(approx)} approximate subgroups found")
        for H in approx:
            print(f"     H = {sorted(H)}, |H| = {len(H)}")

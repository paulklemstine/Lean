#!/usr/bin/env python3
"""
Algorithms for Semiring-Relative Mathematical Reality

This module implements the key algorithms from the research paper:
1. Generic semiring evaluation over expression lists
2. Deduplication-based normalization (the "alien shadow" map)
3. Semiring identity testing (checking if an identity holds universally)
4. Support extraction and comparison
5. Theorem landscape classification
"""

from typing import List, Dict, Set, Tuple, Callable, Any, Optional
from dataclasses import dataclass
from functools import reduce
from itertools import product
import operator


# ─── Core Data Structures ──────────────────────────────────────────────────

@dataclass
class Semiring:
    """A semiring specified by its operations and domain.
    
    A semiring (S, +, ·, 0, 1) has:
    - An additive operation that is commutative and associative with identity 0
    - A multiplicative operation that is associative with identity 1
    - Multiplication distributes over addition
    - 0 annihilates under multiplication
    
    We represent this computationally with explicit operation functions.
    """
    name: str
    domain: List[Any]  # finite sample of the domain for testing
    add: Callable[[Any, Any], Any]
    mul: Callable[[Any, Any], Any]
    zero: Any
    one: Any
    power: Optional[Callable[[Any, int], Any]] = None
    
    def pow(self, x: Any, n: int) -> Any:
        """Compute x^n in this semiring."""
        if self.power is not None:
            return self.power(x, n)
        result = self.one
        for _ in range(n):
            result = self.mul(result, x)
        return result
    
    def is_add_idempotent(self) -> bool:
        """Test whether addition is idempotent: a + a = a for all a in domain.
        
        Time complexity: O(|domain|)
        Space complexity: O(1)
        """
        return all(self.add(a, a) == a for a in self.domain)
    
    def eval_list(self, x: Any, exponents: List[int]) -> Any:
        """Evaluate ∑ x^i for i in exponents.
        
        Time complexity: O(|exponents| · cost(pow))
        Space complexity: O(1)
        """
        result = self.zero
        for i in exponents:
            result = self.add(result, self.pow(x, i))
        return result


# ─── Standard Semirings ────────────────────────────────────────────────────

# The natural numbers (ℕ, +, ·, 0, 1)
NAT_SEMIRING = Semiring(
    name="ℕ (Natural Numbers)",
    domain=list(range(10)),
    add=operator.add,
    mul=operator.mul,
    zero=0,
    one=1,
    power=operator.pow,
)

# The tropical semiring (ℝ ∪ {-∞}, max, +, -∞, 0)
# We use a finite subset for testing
TROPICAL_SEMIRING = Semiring(
    name="Tropical (max-plus)",
    domain=[float('-inf')] + list(range(-5, 6)),
    add=max,
    mul=operator.add,
    zero=float('-inf'),
    one=0,
    power=lambda x, n: x * n,  # "power" in tropical = repeated addition = multiplication
)

# The Boolean semiring ({0, 1}, ∨, ∧, 0, 1)
BOOLEAN_SEMIRING = Semiring(
    name="Boolean ({0,1}, ∨, ∧)",
    domain=[False, True],
    add=lambda a, b: a or b,
    mul=lambda a, b: a and b,
    zero=False,
    one=True,
    power=lambda x, n: x if n == 0 or x else (True if n == 0 else x),
)

# Min-plus semiring (ℝ ∪ {+∞}, min, +, +∞, 0)
MINPLUS_SEMIRING = Semiring(
    name="Min-Plus",
    domain=[float('inf')] + list(range(-5, 6)),
    add=min,
    mul=operator.add,
    zero=float('inf'),
    one=0,
    power=lambda x, n: x * n,
)


# ─── Algorithm 1: Alien Shadow Map (Deduplication Normalization) ───────────

def alien_shadow(exponents: List[int]) -> List[int]:
    """
    The Alien Shadow Map: normalize a list of exponents by deduplication.
    
    This is the key operation that an idempotent civilization would consider
    trivial — for them, this normalization changes nothing. For a classical
    civilization, it loses multiplicity information.
    
    Algorithm: Order-preserving deduplication via seen-set tracking.
    
    Time complexity: O(n) expected (hash set operations)
    Space complexity: O(n) for the seen set
    
    Args:
        exponents: List of exponents [i₁, i₂, ..., iₙ]
    
    Returns:
        Order-preserving deduplication of the input
    
    Example:
        >>> alien_shadow([0, 1, 0, 1, 1])
        [0, 1]
        >>> alien_shadow([3, 1, 4, 1, 5, 9, 2, 6, 5])
        [3, 1, 4, 5, 9, 2, 6]
    """
    seen: Set[int] = set()
    result: List[int] = []
    for i in exponents:
        if i not in seen:
            seen.add(i)
            result.append(i)
    return result


# ─── Algorithm 2: Semiring Identity Tester ─────────────────────────────────

@dataclass
class IdentityTestResult:
    """Result of testing a polynomial identity across semirings."""
    identity_description: str
    results: Dict[str, bool]  # semiring name -> holds?
    counterexamples: Dict[str, Optional[Tuple]]  # semiring name -> counterexample or None
    
    def separation_witnesses(self) -> List[Tuple[str, str]]:
        """Return pairs of semirings where the identity separates them."""
        pairs = []
        names = list(self.results.keys())
        for i, n1 in enumerate(names):
            for n2 in names[i+1:]:
                if self.results[n1] != self.results[n2]:
                    pairs.append((n1, n2))
        return pairs


def test_dedup_identity(semirings: List[Semiring], 
                        test_lists: List[List[int]],
                        test_points: List[Any]) -> IdentityTestResult:
    """
    Test whether eval(L) = eval(dedup(L)) holds in each semiring.
    
    This is the core identity that separates idempotent from classical worlds.
    
    Algorithm:
    For each semiring S:
        For each test list L and point x:
            Compute eval_S(x, L) and eval_S(x, dedup(L))
            If they differ, record a counterexample
    
    Time complexity: O(|semirings| · |test_lists| · |test_points| · max_list_len)
    Space complexity: O(max_list_len) for deduplication
    
    Args:
        semirings: List of semirings to test
        test_lists: Lists of exponents to evaluate
        test_points: Evaluation points (should be elements of each semiring's domain)
    
    Returns:
        IdentityTestResult with per-semiring results
    """
    results: Dict[str, bool] = {}
    counterexamples: Dict[str, Optional[Tuple]] = {}
    
    for S in semirings:
        holds = True
        cex = None
        for L in test_lists:
            shadow = alien_shadow(L)
            for x in test_points:
                try:
                    val_L = S.eval_list(x, L)
                    val_shadow = S.eval_list(x, shadow)
                    if val_L != val_shadow:
                        holds = False
                        cex = (L, x, val_L, val_shadow)
                        break
                except (TypeError, ValueError):
                    continue
            if not holds:
                break
        results[S.name] = holds
        counterexamples[S.name] = cex
    
    return IdentityTestResult(
        identity_description="eval(L) = eval(dedup(L)) [multiplicity collapse]",
        results=results,
        counterexamples=counterexamples,
    )


# ─── Algorithm 3: Theorem Landscape Classifier ────────────────────────────

@dataclass
class TheoremLandscape:
    """Classification of polynomial identities by which semirings support them."""
    universal: List[str]       # True in ALL tested semirings
    classical_only: List[str]  # True in ℕ/ℤ but not tropical
    tropical_only: List[str]   # True in tropical but not ℕ
    neither: List[str]         # False in both


def classify_identities() -> TheoremLandscape:
    """
    Classify fundamental algebraic identities by their semiring support.
    
    Tests each identity against both ℕ and the tropical semiring to determine
    which algebraic substrate supports it.
    
    Time complexity: O(|identities| · |test_values|²)
    Space complexity: O(|identities|)
    
    Returns:
        TheoremLandscape classifying each identity
    """
    universal = []
    classical_only = []
    tropical_only = []
    neither = []
    
    test_vals_nat = list(range(1, 6))
    test_vals_trop = list(range(-3, 4))
    
    # Identity: a + a = a (idempotence)
    nat_idem = all(a + a == a for a in test_vals_nat)
    trop_idem = all(max(a, a) == a for a in test_vals_trop)
    if nat_idem and trop_idem:
        universal.append("Idempotence: a+a = a")
    elif trop_idem:
        tropical_only.append("Idempotence: a+a = a")
    elif nat_idem:
        classical_only.append("Idempotence: a+a = a")
    else:
        neither.append("Idempotence: a+a = a")
    
    # Identity: a + b = b + a (commutativity)
    nat_comm = all(a + b == b + a for a in test_vals_nat for b in test_vals_nat)
    trop_comm = all(max(a, b) == max(b, a) for a in test_vals_trop for b in test_vals_trop)
    if nat_comm and trop_comm:
        universal.append("Commutativity: a+b = b+a")
    
    # Identity: a + 0 = a (identity element)
    nat_id = all(a + 0 == a for a in test_vals_nat)
    trop_id = all(max(a, float('-inf')) == a for a in test_vals_trop)
    if nat_id and trop_id:
        universal.append("Additive identity: a+0 = a")
    
    # Identity: 1+1 = 2 (counting)
    nat_count = (1 + 1 == 2)
    trop_count = (max(0, 0) == 2)  # tropical 1 = 0, tropical 2 = ??
    if nat_count and not trop_count:
        classical_only.append("Counting: 1+1 = 2")
    
    # Identity: a·(b+c) = a·b + a·c (distributivity)
    nat_dist = all(a*(b+c) == a*b + a*c 
                   for a in test_vals_nat 
                   for b in test_vals_nat 
                   for c in test_vals_nat)
    trop_dist = all(a + max(b, c) == max(a+b, a+c) 
                    for a in test_vals_trop 
                    for b in test_vals_trop 
                    for c in test_vals_trop)
    if nat_dist and trop_dist:
        universal.append("Distributivity: a·(b+c) = a·b + a·c")
    
    return TheoremLandscape(
        universal=universal,
        classical_only=classical_only,
        tropical_only=tropical_only,
        neither=neither,
    )


# ─── Algorithm 4: Support Shadow Computation ──────────────────────────────

def compute_support_shadow(coefficients: Dict[int, int]) -> Set[int]:
    """
    Compute the support shadow of a polynomial with given coefficients.
    
    The support shadow maps a polynomial ∑ cᵢ · x^i to the set {i : cᵢ ≠ 0}.
    This is exactly the information that survives passage to an idempotent semiring.
    
    Time complexity: O(n) where n = number of terms
    Space complexity: O(k) where k = number of nonzero coefficients
    
    Args:
        coefficients: Dictionary mapping exponent -> coefficient
    
    Returns:
        Set of exponents with nonzero coefficients
    """
    return {exp for exp, coeff in coefficients.items() if coeff != 0}


def polynomials_tropically_equivalent(p: Dict[int, int], q: Dict[int, int]) -> bool:
    """
    Test whether two polynomials are tropically equivalent.
    
    Two polynomials are tropically equivalent if and only if they have the same
    support — i.e., the same set of exponents with nonzero coefficients.
    This is a consequence of the Support Invariance Theorem.
    
    Time complexity: O(n + m) where n, m are the number of terms
    Space complexity: O(n + m)
    
    Args:
        p, q: Polynomials as coefficient dictionaries
    
    Returns:
        True if p and q have the same support
    """
    return compute_support_shadow(p) == compute_support_shadow(q)


# ─── Algorithm 5: Information Loss Quantifier ─────────────────────────────

def information_loss(exponents: List[int]) -> Dict[str, Any]:
    """
    Quantify how much information is lost by idempotent collapse.
    
    Measures the difference between the original list and its deduplication
    across multiple metrics.
    
    Time complexity: O(n log n) for sorting
    Space complexity: O(n)
    
    Args:
        exponents: List of exponents
    
    Returns:
        Dictionary with loss metrics
    """
    shadow = alien_shadow(exponents)
    
    original_length = len(exponents)
    shadow_length = len(shadow)
    
    # Count multiplicities
    from collections import Counter
    counts = Counter(exponents)
    max_multiplicity = max(counts.values()) if counts else 0
    total_excess = sum(c - 1 for c in counts.values())
    
    return {
        "original_length": original_length,
        "shadow_length": shadow_length,
        "elements_lost": original_length - shadow_length,
        "compression_ratio": shadow_length / original_length if original_length > 0 else 1.0,
        "max_multiplicity": max_multiplicity,
        "total_excess_multiplicity": total_excess,
        "multiplicity_distribution": dict(counts),
        "information_destroyed": original_length > shadow_length,
    }


# ─── Main Demo ─────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║  ALGORITHMS: Semiring-Relative Mathematical Reality        ║")
    print("╚══════════════════════════════════════════════════════════════╝\n")
    
    # Test dedup identity across semirings
    print("─── Identity Test: eval(L) = eval(dedup(L)) ───")
    test_lists = [[0, 0], [1, 1, 1], [0, 1, 0], [2, 3, 2, 3], [0, 1, 2]]
    result = test_dedup_identity(
        [NAT_SEMIRING, TROPICAL_SEMIRING, BOOLEAN_SEMIRING],
        test_lists,
        [1, 2, 3],
    )
    
    for name, holds in result.results.items():
        status = "HOLDS" if holds else "FAILS"
        cex = result.counterexamples[name]
        print(f"  {name}: {status}")
        if cex:
            L, x, v1, v2 = cex
            print(f"    Counterexample: L={L}, x={x}, eval(L)={v1}, eval(dedup(L))={v2}")
    
    seps = result.separation_witnesses()
    if seps:
        print(f"\n  Separation witnesses: {seps}")
    
    # Classify identities
    print("\n─── Theorem Landscape Classification ───")
    landscape = classify_identities()
    print(f"  Universal (all semirings): {landscape.universal}")
    print(f"  Classical only (ℕ):       {landscape.classical_only}")
    print(f"  Tropical only:            {landscape.tropical_only}")
    
    # Information loss
    print("\n─── Information Loss Analysis ───")
    test = [0, 1, 0, 1, 1, 2, 3, 2]
    loss = information_loss(test)
    print(f"  Expression: {test}")
    print(f"  Shadow:     {alien_shadow(test)}")
    print(f"  Elements lost: {loss['elements_lost']}")
    print(f"  Compression ratio: {loss['compression_ratio']:.2%}")
    print(f"  Multiplicity distribution: {loss['multiplicity_distribution']}")
    
    # Tropical equivalence
    print("\n─── Tropical Equivalence Testing ───")
    p1 = {0: 3, 1: 7, 2: 1}
    p2 = {0: 1, 1: 1, 2: 100}
    p3 = {0: 1, 1: 1, 3: 1}
    
    print(f"  p1 = 3 + 7x + x²")
    print(f"  p2 = 1 + x + 100x²")
    print(f"  p3 = 1 + x + x³")
    print(f"  p1 ≡ p2 (tropically)? {polynomials_tropically_equivalent(p1, p2)}")
    print(f"  p1 ≡ p3 (tropically)? {polynomials_tropically_equivalent(p1, p3)}")
    print(f"  Support of p1: {compute_support_shadow(p1)}")
    print(f"  Support of p3: {compute_support_shadow(p3)}")

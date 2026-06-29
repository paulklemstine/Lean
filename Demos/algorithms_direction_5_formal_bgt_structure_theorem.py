"""
Algorithms for Approximate Subgroup Analysis

Implements the core algorithms from the BGT (Breuillard-Green-Tao)
structure theorem and related product growth machinery.

Algorithms:
1. ApproximateSubgroupClassifier - Classify K-approximate subgroups
2. ProductGrowthAnalyzer - Analyze product set growth sequences
3. CayleyDiameterComputer - Compute Cayley graph diameters
4. RuzsaCoveringFinder - Find Ruzsa coverings (greedy algorithm)
"""

from typing import Set, Dict, List, Tuple, Optional, Callable
from dataclasses import dataclass
from collections import defaultdict
import math


@dataclass
class GroupElement:
    """Abstract group element with operation defined by a table."""
    value: int
    
    def __hash__(self):
        return hash(self.value)
    
    def __eq__(self, other):
        return self.value == other.value


class FiniteGroup:
    """
    A finite group defined by its multiplication table.
    
    Supports Z/nZ and direct products thereof.
    
    Args:
        n: Order of the group (for Z/nZ)
        op: Binary operation (a, b) -> c
        inv: Inversion function a -> a^{-1}
        identity: Identity element
    
    Time complexity: O(1) per operation
    Space complexity: O(n) for the group
    """
    
    def __init__(self, n: int, 
                 op: Callable[[int, int], int] = None,
                 inv: Callable[[int], int] = None,
                 identity: int = 0):
        self.n = n
        self.op = op or (lambda a, b: (a + b) % n)
        self.inv = inv or (lambda a: (-a) % n)
        self.identity = identity
        self.elements = set(range(n))
    
    def multiply(self, a: int, b: int) -> int:
        return self.op(a, b)
    
    def invert(self, a: int) -> int:
        return self.inv(a)
    
    def product_set(self, A: Set[int], B: Set[int]) -> Set[int]:
        """Compute A · B = {a*b : a ∈ A, b ∈ B}."""
        return {self.multiply(a, b) for a in A for b in B}
    
    def triple_product(self, A: Set[int]) -> Set[int]:
        """Compute A · A · A."""
        return self.product_set(self.product_set(A, A), A)
    
    def power_set(self, A: Set[int], k: int) -> Set[int]:
        """Compute A^k (k-fold product)."""
        if k == 0:
            return {self.identity}
        result = A.copy()
        for _ in range(k - 1):
            result = self.product_set(result, A)
        return result
    
    def is_symmetric(self, A: Set[int]) -> bool:
        """Check if A is closed under inversion."""
        return all(self.invert(a) in A for a in A)
    
    def symmetric_closure(self, A: Set[int]) -> Set[int]:
        """Compute {1} ∪ A ∪ A⁻¹."""
        return {self.identity} | A | {self.invert(a) for a in A}
    
    def is_subgroup(self, A: Set[int]) -> bool:
        """Check if A is a subgroup."""
        if self.identity not in A:
            return False
        if not self.is_symmetric(A):
            return False
        return self.product_set(A, A) == A


@dataclass
class ApproxSubgroupCertificate:
    """
    Certificate that a set is a K-approximate subgroup.
    
    Fields:
        carrier: The set A
        K: The approximation constant
        is_symmetric: Whether A = A⁻¹
        is_subgroup: Whether A is a genuine subgroup
        doubling_const: |A²|/|A|
        tripling_const: |A³|/|A|
        classification: 'subgroup', 'near-subgroup', or 'expanding'
    """
    carrier: Set[int]
    K: float
    is_symmetric: bool
    is_subgroup: bool
    doubling_const: float
    tripling_const: float
    classification: str


class ApproximateSubgroupClassifier:
    """
    Classify K-approximate subgroups using the BGT structure theorem.
    
    Algorithm:
    1. Compute A², A³, check symmetry
    2. Compute K = |A³|/|A| (tripling constant)
    3. If K = 1: A is a subgroup (BGT base case)
    4. If K < 2: A is "near" a subgroup (small growth regime)
    5. If K ≥ 2: A exhibits genuine expansion
    
    Time complexity: O(|A|³) for tripling computation
    Space complexity: O(|A|³) for storing triple product
    
    >>> G = FiniteGroup(12)
    >>> clf = ApproximateSubgroupClassifier(G)
    >>> cert = clf.classify({0, 3, 6, 9})
    >>> cert.classification
    'subgroup'
    """
    
    def __init__(self, group: FiniteGroup):
        self.group = group
    
    def classify(self, A: Set[int]) -> ApproxSubgroupCertificate:
        """Classify a set as an approximate subgroup."""
        G = self.group
        
        # Ensure identity is present
        if G.identity not in A:
            A = A | {G.identity}
        
        # Compute product sets
        AA = G.product_set(A, A)
        AAA = G.product_set(AA, A)
        
        # Compute constants
        card_A = len(A)
        doubling = len(AA) / card_A if card_A > 0 else 0
        tripling = len(AAA) / card_A if card_A > 0 else 0
        K = math.ceil(tripling)
        
        symmetric = G.is_symmetric(A)
        subgroup = G.is_subgroup(A)
        
        # Classification based on tripling constant
        if tripling <= 1.0 + 1e-10:
            classification = 'subgroup'
        elif tripling < 2.0:
            classification = 'near-subgroup'
        else:
            classification = 'expanding'
        
        return ApproxSubgroupCertificate(
            carrier=A,
            K=K,
            is_symmetric=symmetric,
            is_subgroup=subgroup,
            doubling_const=doubling,
            tripling_const=tripling,
            classification=classification
        )


@dataclass
class GrowthSequence:
    """
    Growth sequence data for iterated product sets.
    
    Fields:
        sizes: List of |A^k| for k = 0, 1, ..., N
        ratios: List of |A^{k+1}|/|A^k| growth ratios
        saturation_step: Step at which A^k = G (or None)
        is_monotone: Whether the sequence is strictly increasing
    """
    sizes: List[int]
    ratios: List[float]
    saturation_step: Optional[int]
    is_monotone: bool


class ProductGrowthAnalyzer:
    """
    Analyze the growth sequence |A|, |A²|, |A³|, ...
    
    Algorithm:
    1. Iteratively compute A^k for k = 1, 2, ...
    2. Track cardinalities and growth ratios
    3. Detect saturation (A^k = A^{k+1})
    4. Verify growth dichotomy
    
    Time complexity: O(N · |G|²) where N is saturation step
    Space complexity: O(|G|) per step
    
    >>> G = FiniteGroup(15)
    >>> analyzer = ProductGrowthAnalyzer(G)
    >>> seq = analyzer.analyze({0, 1, 14})
    >>> seq.is_monotone
    True
    """
    
    def __init__(self, group: FiniteGroup):
        self.group = group
    
    def analyze(self, A: Set[int], max_steps: int = None) -> GrowthSequence:
        """Analyze the growth sequence of A."""
        G = self.group
        if max_steps is None:
            max_steps = G.n + 1
        
        sizes = [1]  # |A^0| = |{1}| = 1
        current = {G.identity}
        ratios = []
        saturation = None
        is_mono = True
        
        for k in range(1, max_steps + 1):
            current = G.product_set(current, A)
            sizes.append(len(current))
            
            if len(sizes) >= 2:
                ratio = sizes[-1] / sizes[-2] if sizes[-2] > 0 else float('inf')
                ratios.append(ratio)
                if sizes[-1] <= sizes[-2]:
                    is_mono = False
            
            if current == G.elements:
                saturation = k
                break
        
        return GrowthSequence(
            sizes=sizes,
            ratios=ratios,
            saturation_step=saturation,
            is_monotone=is_mono
        )


class CayleyDiameterComputer:
    """
    Compute the diameter of the Cayley graph Cay(G, A).
    
    The diameter is the smallest N such that A^N = G.
    By the growth dichotomy theorem, this is at most |G|.
    
    Algorithm:
    1. Start with S = A
    2. Iteratively compute S = S · A
    3. When S = G, return the step count
    
    Time complexity: O(diam · |G|²)
    Space complexity: O(|G|)
    
    >>> G = FiniteGroup(7)
    >>> computer = CayleyDiameterComputer(G)
    >>> computer.compute({0, 1, 6})
    3
    """
    
    def __init__(self, group: FiniteGroup):
        self.group = group
    
    def compute(self, A: Set[int]) -> int:
        """Compute the Cayley diameter for generating set A."""
        G = self.group
        current = A.copy()
        
        for k in range(1, G.n + 1):
            if current == G.elements:
                return k
            current = G.product_set(current, A)
        
        return -1  # A doesn't generate G


class RuzsaCoveringFinder:
    """
    Find a Ruzsa covering: T ⊆ B with B ⊆ T · (A⁻¹ · A).
    
    Uses the greedy algorithm:
    1. Pick any uncovered b ∈ B
    2. Add b to T
    3. Mark all elements in {b} · (A⁻¹ · A) as covered
    4. Repeat until B is fully covered
    
    Time complexity: O(|T| · |A|²)
    Space complexity: O(|A|² + |B|)
    
    Guaranteed: |T| ≤ |A·B|/|A| when the sets are chosen
    to maximize disjointness of translates.
    """
    
    def __init__(self, group: FiniteGroup):
        self.group = group
    
    def find_covering(self, A: Set[int], B: Set[int]) -> Tuple[Set[int], int]:
        """
        Find a covering of B by translates of A⁻¹·A.
        
        Returns:
            (T, cover_size) where T is the set of translators
            and cover_size = |T · (A⁻¹·A)|
        """
        G = self.group
        
        # Compute A⁻¹ · A
        A_inv = {G.invert(a) for a in A}
        AinvA = G.product_set(A_inv, A)
        
        T = set()
        covered = set()
        uncovered = B.copy()
        
        while uncovered:
            # Pick any uncovered element
            b = min(uncovered)  # deterministic choice
            T.add(b)
            
            # Mark everything in {b} · (A⁻¹ · A) as covered
            translate = {G.multiply(b, x) for x in AinvA}
            covered |= translate
            uncovered -= translate
        
        return T, len(G.product_set(T, AinvA))


# ─────────────────────────────────────────────────────────────
# Example usage
# ─────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Algorithm Demonstrations")
    print("=" * 50)
    
    # 1. Classify approximate subgroups
    G = FiniteGroup(24)
    clf = ApproximateSubgroupClassifier(G)
    
    test_sets = [
        {0, 4, 8, 12, 16, 20},    # Subgroup 6Z/24Z
        {0, 1, 23},                # Small generating set
        {0, 2, 4, 6, 8, 10},      # Near-subgroup
        {0, 1, 2, 3, 22, 23},     # Interval with inv
    ]
    
    print("\n1. Approximate Subgroup Classification (Z/24Z)")
    for A in test_sets:
        cert = clf.classify(A)
        print(f"   A={sorted(cert.carrier)[:6]}{'...' if len(cert.carrier)>6 else ''}: "
              f"K={cert.K}, σ={cert.doubling_const:.2f}, "
              f"τ={cert.tripling_const:.2f}, "
              f"class={cert.classification}")
    
    # 2. Growth analysis
    G = FiniteGroup(30)
    analyzer = ProductGrowthAnalyzer(G)
    
    print("\n2. Growth Sequence Analysis (Z/30Z)")
    for A in [{0, 1, 29}, {0, 7, 23}]:
        seq = analyzer.analyze(A)
        print(f"   A={sorted(A)}: sat={seq.saturation_step}, "
              f"mono={seq.is_monotone}, "
              f"sizes={seq.sizes[:6]}...")
    
    # 3. Cayley diameter
    print("\n3. Cayley Graph Diameters")
    comp = CayleyDiameterComputer(FiniteGroup(30))
    for A in [{0, 1, 29}, {0, 7, 23}, {0, 1, 7, 23, 29}]:
        d = comp.compute(A)
        print(f"   A={sorted(A)}: diameter={d}")
    
    # 4. Ruzsa covering
    G = FiniteGroup(20)
    rcf = RuzsaCoveringFinder(G)
    A = {0, 1, 2, 3, 4}
    B = set(range(20))
    T, cover = rcf.find_covering(A, B)
    print(f"\n4. Ruzsa Covering (Z/20Z)")
    print(f"   A={sorted(A)}, B=Z/20Z")
    print(f"   T={sorted(T)}, |T|={len(T)}")
    print(f"   |A⁻¹·A| = {len(G.product_set({G.invert(a) for a in A}, A))}")

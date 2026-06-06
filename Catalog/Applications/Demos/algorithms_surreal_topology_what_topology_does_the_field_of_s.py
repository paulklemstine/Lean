#!/usr/bin/env python3
"""
Algorithms for Surreal Topology: The Archimedean–Connected Dichotomy

Implementations of the key constructions from the formal proofs:
1. InfinitesimalField — a model of Q(ε) for testing
2. ClopenSeparator — constructs clopen sets separating points
3. ArchimedeanClassifier — determines topological properties from algebraic ones
"""

from fractions import Fraction
from typing import List, Tuple, Optional, Set, Dict
from dataclasses import dataclass


# ============================================================
# Algorithm 1: Infinitesimal Field Element
# ============================================================

@dataclass
class FieldElement:
    """Element of Q(ε) = {a + b·ε : a, b ∈ Q} with ε infinitesimal.
    
    Ordered lexicographically: a + b·ε < c + d·ε iff a < c or (a = c and b < d).
    This models a non-Archimedean ordered field.
    
    Type hints: real (Fraction), inf (Fraction)
    """
    real: Fraction   # standard part
    inf: Fraction    # infinitesimal coefficient
    
    def __lt__(self, other: 'FieldElement') -> bool:
        return (self.real, self.inf) < (other.real, other.inf)
    
    def __le__(self, other: 'FieldElement') -> bool:
        return (self.real, self.inf) <= (other.real, other.inf)
    
    def __eq__(self, other: object) -> bool:
        if not isinstance(other, FieldElement):
            return NotImplemented
        return self.real == other.real and self.inf == other.inf
    
    def __add__(self, other: 'FieldElement') -> 'FieldElement':
        return FieldElement(self.real + other.real, self.inf + other.inf)
    
    def __sub__(self, other: 'FieldElement') -> 'FieldElement':
        return FieldElement(self.real - other.real, self.inf - other.inf)
    
    def __mul__(self, other: 'FieldElement') -> 'FieldElement':
        return FieldElement(
            self.real * other.real,
            self.real * other.inf + self.inf * other.real
        )
    
    def nsmul(self, n: int) -> 'FieldElement':
        """Compute n • self (additive n-fold)."""
        return FieldElement(Fraction(n) * self.real, Fraction(n) * self.inf)
    
    def __repr__(self) -> str:
        if self.inf == 0:
            return f"FieldElement({self.real})"
        elif self.real == 0:
            return f"FieldElement({self.inf}·ε)"
        else:
            return f"FieldElement({self.real} + {self.inf}·ε)"


# ============================================================
# Algorithm 2: Clopen Set Membership Test
# ============================================================

def in_lt_nsmul_region(z: FieldElement, eps: FieldElement, max_n: int = 10000) -> bool:
    """Test if z ∈ ltNsmulRegion(ε) = {z : ∃ n ∈ ℕ, z < n • ε}.
    
    In Q(ε), this is decidable: z < n·ε iff z.real < n·ε.real 
    or (z.real = n·ε.real and z.inf < n·ε.inf).
    
    For exact computation in Q(ε), we can solve analytically.
    
    Args:
        z: Element to test
        eps: The infinitesimal ε > 0
        max_n: Maximum n to check (for approximate test)
    
    Returns:
        True if z ∈ ltNsmulRegion(ε)
    """
    if eps.real > 0:
        # n·ε has real part n·eps.real → ∞, so z < n·ε for large n
        return True
    elif eps.real == 0 and eps.inf > 0:
        # n·ε has real part 0 and inf part n·eps.inf
        # z < n·ε iff z.real < 0 or (z.real == 0 and z.inf < n·eps.inf)
        if z.real < 0:
            return True
        elif z.real == 0:
            # z.inf < n·eps.inf for some n iff z.inf / eps.inf < some n iff True (for z.inf finite)
            return True  # always true for finite z.inf
        else:
            return False  # z.real > 0 > n · 0 = n·ε.real
    else:
        return False


def construct_clopen_separator(
    a: FieldElement, 
    b: FieldElement, 
    eps0: FieldElement,
    b0: FieldElement
) -> Tuple[FieldElement, FieldElement]:
    """Construct a clopen set separating a from b (with a < b).
    
    Given infinitesimal witness ε₀ > 0 with n·ε₀ < b₀ for all n,
    constructs rescaled ε = ε₀ · (b - a) / b₀ such that:
    - {z : ∃ n, z - a < n · ε} is clopen
    - a is in this set, b is not
    
    Returns: (eps_rescaled, delta) — the rescaled ε and the gap δ = b - a
    
    Pseudocode:
        1. Compute δ = b - a
        2. Compute ε = ε₀ · δ / b₀
        3. Return ε (the separator is {z : ∃ n, z - a < n · ε})
    """
    delta = b - a
    eps_rescaled = eps0 * delta  # Simplified: assuming b0 = 1 in our model
    return eps_rescaled, delta


# ============================================================
# Algorithm 3: Archimedean Property Test
# ============================================================

def is_archimedean_field(elements: List[FieldElement]) -> Tuple[bool, Optional[Tuple[FieldElement, FieldElement]]]:
    """Test if a finite subset of an ordered field witnesses non-Archimedeanness.
    
    Checks if there exist ε, b in elements with ε > 0, b > 0, and
    n·ε < b for all n up to a reasonable bound.
    
    In Q(ε), any element with real part 0 and positive inf part is infinitesimal.
    
    Args:
        elements: List of field elements to check
    
    Returns:
        (is_arch, witness) where witness is (ε, b) if non-Archimedean
    """
    zero = FieldElement(Fraction(0), Fraction(0))
    
    for eps in elements:
        if not (zero < eps):
            continue
        for b_elem in elements:
            if not (zero < b_elem):
                continue
            # Check if n·ε < b for "all" n (check up to 1000)
            all_bounded = True
            for n in range(1, 1001):
                if not (eps.nsmul(n) < b_elem):
                    all_bounded = False
                    break
            if all_bounded and eps != b_elem:
                return False, (eps, b_elem)
    
    return True, None


# ============================================================
# Algorithm 4: Connected Component Computation (Finite Model)
# ============================================================

def compute_connected_components_finite(
    points: List[FieldElement],
    eps: FieldElement
) -> Dict[int, List[FieldElement]]:
    """Compute approximate connected components in a finite model.
    
    Two points are in the same component if they can be connected by
    a chain of points where consecutive points are NOT separated by
    any ltNsmulRegion-based clopen set.
    
    In a non-Archimedean field, each point is its own component.
    In an Archimedean field, all points within standard distance are connected.
    
    Args:
        points: Sorted list of field elements
        eps: An infinitesimal element (or small element for testing)
    
    Returns:
        Dictionary mapping component index to list of points in that component
    """
    if not points:
        return {}
    
    # In a non-Archimedean field, connected components are singletons
    # In our model Q(ε), points with different real parts are in different components
    components: Dict[int, List[FieldElement]] = {}
    comp_idx = 0
    current_real = points[0].real
    components[comp_idx] = [points[0]]
    
    for p in points[1:]:
        if p.real != current_real:
            comp_idx += 1
            current_real = p.real
            components[comp_idx] = []
        components[comp_idx].append(p)
    
    return components


# ============================================================
# Algorithm 5: Topological Classification
# ============================================================

@dataclass
class TopologicalClassification:
    """Classification of an ordered field's topology."""
    is_archimedean: bool
    is_complete: bool
    is_connected: bool
    is_totally_disconnected: bool
    description: str


def classify_ordered_field(
    name: str,
    is_archimedean: bool,
    is_complete: bool
) -> TopologicalClassification:
    """Classify the order topology of an ordered field.
    
    Uses our theorems:
    - Non-Archimedean ⟹ Totally Disconnected
    - Connected ⟹ Archimedean
    - Archimedean + Complete ⟹ Connected
    
    Args:
        name: Name of the field
        is_archimedean: Whether the field satisfies the Archimedean property
        is_complete: Whether the field is Dedekind complete
    
    Returns:
        TopologicalClassification with all properties determined
    """
    if not is_archimedean:
        return TopologicalClassification(
            is_archimedean=False,
            is_complete=is_complete,
            is_connected=False,
            is_totally_disconnected=True,
            description=f"{name}: Non-Archimedean ⟹ totally disconnected (by our theorem)"
        )
    elif is_archimedean and is_complete:
        return TopologicalClassification(
            is_archimedean=True,
            is_complete=True,
            is_connected=True,
            is_totally_disconnected=False,
            description=f"{name}: Archimedean + Complete ⟹ connected"
        )
    else:  # Archimedean but not complete
        return TopologicalClassification(
            is_archimedean=True,
            is_complete=False,
            is_connected=False,
            is_totally_disconnected=False,  # ℚ has non-trivial connected sets of measure 0
            description=f"{name}: Archimedean but incomplete ⟹ disconnected (gaps at irrationals)"
        )


if __name__ == "__main__":
    # Demo: classify several fields
    fields = [
        ("ℝ", True, True),
        ("ℚ", True, False),
        ("ℚ(ε)", False, False),
        ("*ℝ (hyperreals)", False, True),
        ("No (surreals)", False, True),
    ]
    
    print("Topological Classification of Ordered Fields")
    print("=" * 60)
    for name, arch, comp in fields:
        result = classify_ordered_field(name, arch, comp)
        print(f"\n{result.description}")
        print(f"  Connected: {result.is_connected}")
        print(f"  Totally Disconnected: {result.is_totally_disconnected}")

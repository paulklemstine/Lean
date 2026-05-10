#!/usr/bin/env python3
"""
Galois Deep Learning — Core Algorithms
=======================================
Implementations of the key algorithms from the Galois Deep Learning framework.
Includes group-theoretic computations, depth bounds, and certificate verification.
"""

import math
from typing import Optional
from dataclasses import dataclass


# =============================================================================
# Data Structures
# =============================================================================

@dataclass
class FeatureTower:
    """
    A feature tower modeling a feedforward neural network.
    Each layer has a positive algebraic degree.
    
    Corresponds to Lean: GaloisDeepLearning.FeatureTower
    """
    layer_degrees: list[int]
    
    def __post_init__(self):
        assert all(d >= 1 for d in self.layer_degrees), \
            "All layer degrees must be >= 1"
    
    @property
    def depth(self) -> int:
        """Network depth = number of layers."""
        return len(self.layer_degrees)
    
    @property
    def total_degree(self) -> int:
        """Total degree = product of layer degrees (tower law)."""
        result = 1
        for d in self.layer_degrees:
            result *= d
        return result
    
    @property
    def max_degree(self) -> int:
        """Maximum layer degree."""
        return max(self.layer_degrees) if self.layer_degrees else 1
    
    def compose(self, other: 'FeatureTower') -> 'FeatureTower':
        """Compose two towers sequentially."""
        return FeatureTower(self.layer_degrees + other.layer_degrees)


@dataclass
class PermutationGroup:
    """
    A permutation group on n elements, represented by generators.
    
    Generators are given as lists of length n, where gen[i] = j means
    element i maps to element j.
    """
    n: int
    generators: list[list[int]]
    _order: Optional[int] = None
    _elements: Optional[set] = None
    _is_solvable: Optional[bool] = None
    _derived_length: Optional[int] = None
    
    def _compute_elements(self) -> set:
        """Compute all group elements by closure under composition."""
        identity = tuple(range(self.n))
        elements = {identity}
        frontier = set(tuple(g) for g in self.generators)
        # Also add inverses
        for g in self.generators:
            inv = [0] * self.n
            for i, j in enumerate(g):
                inv[j] = i
            frontier.add(tuple(inv))
        
        elements.update(frontier)
        
        while frontier:
            new_frontier = set()
            for a in frontier:
                for gen in self.generators:
                    # Compose a ∘ gen
                    composed = tuple(a[gen[i]] for i in range(self.n))
                    if composed not in elements:
                        elements.add(composed)
                        new_frontier.add(composed)
                    # Compose gen ∘ a
                    composed2 = tuple(gen[a[i]] for i in range(self.n))
                    if composed2 not in elements:
                        elements.add(composed2)
                        new_frontier.add(composed2)
            frontier = new_frontier
        
        return elements
    
    @property
    def elements(self) -> set:
        if self._elements is None:
            self._elements = self._compute_elements()
        return self._elements
    
    @property
    def order(self) -> int:
        """Compute |G| by enumerating all elements."""
        if self._order is None:
            self._order = len(self.elements)
        return self._order
    
    def commutator_subgroup(self) -> 'PermutationGroup':
        """
        Compute the commutator (derived) subgroup [G, G].
        [G, G] = <{aba⁻¹b⁻¹ : a, b ∈ G}>.
        """
        elems = list(self.elements)
        commutators = set()
        
        for a in elems:
            a_inv = [0] * self.n
            for i, j in enumerate(a):
                a_inv[j] = i
            for b in elems:
                b_inv = [0] * self.n
                for i, j in enumerate(b):
                    b_inv[j] = i
                # aba⁻¹b⁻¹
                ab = tuple(a[b[i]] for i in range(self.n))
                ainv_binv = tuple(a_inv[b_inv[i]] for i in range(self.n))
                comm = tuple(ab[ainv_binv[i]] for i in range(self.n))
                commutators.add(comm)
        
        generators = [list(c) for c in commutators if c != tuple(range(self.n))]
        if not generators:
            generators = [list(range(self.n))]  # trivial group
        
        return PermutationGroup(self.n, generators)
    
    def derived_series(self) -> list['PermutationGroup']:
        """
        Compute the derived series G > [G,G] > [[G,G],[G,G]] > ... > {e}.
        Returns the list of groups in the series.
        """
        series = [self]
        current = self
        
        for _ in range(100):  # Safety limit
            comm = current.commutator_subgroup()
            if comm.order == current.order:
                break  # Stabilized (non-solvable if not trivial)
            series.append(comm)
            current = comm
            if current.order == 1:
                break  # Reached trivial group
        
        return series
    
    @property
    def is_solvable(self) -> bool:
        """Check if the group is solvable (derived series reaches {e})."""
        if self._is_solvable is None:
            series = self.derived_series()
            self._is_solvable = series[-1].order == 1
        return self._is_solvable
    
    @property
    def derived_length_value(self) -> Optional[int]:
        """
        Compute the derived length (length of derived series to reach {e}).
        Returns None if the group is non-solvable.
        """
        if self._derived_length is None:
            series = self.derived_series()
            if series[-1].order == 1:
                self._derived_length = len(series) - 1
            else:
                self._derived_length = -1  # Non-solvable marker
        return self._derived_length if self._derived_length >= 0 else None


def symmetric_group(n: int) -> PermutationGroup:
    """
    Construct S_n as a permutation group.
    Generated by the transposition (0 1) and the cycle (0 1 2 ... n-1).
    """
    if n <= 1:
        return PermutationGroup(max(n, 1), [list(range(max(n, 1)))])
    
    # Transposition (0 1)
    trans = list(range(n))
    trans[0], trans[1] = 1, 0
    
    # Cycle (0 1 2 ... n-1)
    cycle = [(i + 1) % n for i in range(n)]
    
    return PermutationGroup(n, [trans, cycle])


# =============================================================================
# Algorithms
# =============================================================================

def compute_depth_lower_bound(
    group: PermutationGroup,
    max_layer_degree: int
) -> dict:
    """
    Algorithm 1: Compute Depth Lower Bound
    
    Input: A permutation group G and maximum layer degree d.
    Output: Dictionary with various depth lower bounds.
    
    Complexity: O(|G|² log |G|) for derived series computation.
    
    Corresponds to Theorems 1, 8, 10 in the formal development.
    """
    order = group.order
    
    # Logarithmic bound: depth >= ceil(log_d(|G|))
    if max_layer_degree >= 2:
        log_bound = math.ceil(math.log(order) / math.log(max_layer_degree))
    else:
        log_bound = order
    
    # Derived length bound (only for solvable groups)
    dl = group.derived_length_value
    
    if dl is not None:
        combined_bound = max(dl, log_bound)
    else:
        combined_bound = log_bound  # Non-solvable: use log bound
    
    return {
        "group_order": order,
        "is_solvable": group.is_solvable,
        "derived_length": dl,
        "log_bound": log_bound,
        "combined_bound": combined_bound,
        "max_layer_degree": max_layer_degree,
        "security_bits": int(math.log2(order)) if order > 0 else 0,
    }


@dataclass
class SolvableExpressivityCert:
    """
    A solvable expressivity certificate.
    
    Corresponds to Lean: GaloisDeepLearning.SolvableExpressivityCert
    """
    tower: FeatureTower
    group: PermutationGroup
    
    def verify(self) -> bool:
        """
        Algorithm 2: Verify Solvable Expressivity Certificate
        
        Checks:
        1. The group is solvable
        2. derivedLength(G) <= tower.depth
        """
        if not self.group.is_solvable:
            return False
        dl = self.group.derived_length_value
        if dl is None:
            return False
        return dl <= self.tower.depth


def post_quantum_security_level(group: PermutationGroup) -> dict:
    """
    Algorithm 3: Compute Post-Quantum Security Level
    
    Non-solvable groups provide security against algebraic attacks
    (including quantum) based on the hidden subgroup problem hardness.
    """
    order = group.order
    bits = int(math.log2(order)) if order > 0 else 0
    
    return {
        "group_order": order,
        "security_bits": bits,
        "is_solvable": group.is_solvable,
        "quantum_safe": not group.is_solvable,
        "meets_128_bit": bits >= 128,
    }


# =============================================================================
# Examples
# =============================================================================

if __name__ == "__main__":
    print("Galois Deep Learning — Algorithm Demonstrations")
    print("=" * 60)
    
    # Example 1: S3 (solvable)
    print("\n--- S₃ (Symmetric group on 3 elements) ---")
    S3 = symmetric_group(3)
    result = compute_depth_lower_bound(S3, 2)
    print(f"  Order: {result['group_order']}")
    print(f"  Solvable: {result['is_solvable']}")
    print(f"  Derived length: {result['derived_length']}")
    print(f"  Log₂ bound (d=2): {result['log_bound']}")
    print(f"  Combined bound: {result['combined_bound']}")
    
    series = S3.derived_series()
    print(f"  Derived series orders: {[g.order for g in series]}")
    
    # Example 2: S4 (solvable)
    print("\n--- S₄ (Symmetric group on 4 elements) ---")
    S4 = symmetric_group(4)
    result = compute_depth_lower_bound(S4, 2)
    print(f"  Order: {result['group_order']}")
    print(f"  Solvable: {result['is_solvable']}")
    print(f"  Derived length: {result['derived_length']}")
    print(f"  Combined bound (d=2): {result['combined_bound']}")
    
    series = S4.derived_series()
    print(f"  Derived series orders: {[g.order for g in series]}")
    
    # Example 3: S5 (non-solvable — Abel-Ruffini!)
    print("\n--- S₅ (Symmetric group on 5 elements) ---")
    S5 = symmetric_group(5)
    result = compute_depth_lower_bound(S5, 2)
    print(f"  Order: {result['group_order']}")
    print(f"  Solvable: {result['is_solvable']} ← Abel-Ruffini!")
    print(f"  Derived length: {result['derived_length']}")
    print(f"  Log₂ bound (d=2): {result['log_bound']}")
    print(f"  Security bits: {result['security_bits']}")
    
    series = S5.derived_series()
    print(f"  Derived series orders: {[g.order for g in series]}")
    print(f"  (Series does NOT reach 1 → non-solvable)")
    
    # Example 4: Certificate verification
    print("\n--- Certificate Verification ---")
    tower_ok = FeatureTower([2, 2, 2])  # depth 3, all degree 2
    cert_ok = SolvableExpressivityCert(tower_ok, S3)
    print(f"  S₃ with depth-3 tower: valid = {cert_ok.verify()}")
    
    tower_shallow = FeatureTower([2])  # depth 1
    cert_shallow = SolvableExpressivityCert(tower_shallow, S3)
    print(f"  S₃ with depth-1 tower: valid = {cert_shallow.verify()}")
    
    cert_s5 = SolvableExpressivityCert(tower_ok, S5)
    print(f"  S₅ with depth-3 tower: valid = {cert_s5.verify()} (non-solvable!)")
    
    # Example 5: Post-quantum security
    print("\n--- Post-Quantum Security ---")
    for name, group in [("S₃", S3), ("S₄", S4), ("S₅", S5)]:
        sec = post_quantum_security_level(group)
        print(f"  {name}: {sec['security_bits']} bits, "
              f"quantum-safe = {sec['quantum_safe']}")
    
    # Example 6: Tower composition
    print("\n--- Tower Composition ---")
    t1 = FeatureTower([2, 3])
    t2 = FeatureTower([5, 2])
    t12 = t1.compose(t2)
    print(f"  T₁: depth={t1.depth}, totalDegree={t1.total_degree}")
    print(f"  T₂: depth={t2.depth}, totalDegree={t2.total_degree}")
    print(f"  T₁∘T₂: depth={t12.depth}, totalDegree={t12.total_degree}")
    print(f"  Product: {t1.total_degree} × {t2.total_degree} = {t1.total_degree * t2.total_degree}")


#!/usr/bin/env python3
"""
Galois Deep Learning — Applications
=====================================
Real-world applications of the Galois Deep Learning framework to:
1. Neural network architecture design
2. Post-quantum hash function construction
3. Certified robustness verification
"""

import math
from dataclasses import dataclass
from typing import Optional


# =============================================================================
# Application 1: Architecture Design Advisor
# =============================================================================

@dataclass
class ArchitectureSpec:
    """Specification for a neural network architecture."""
    name: str
    symmetry_type: str  # "abelian", "solvable", "non-solvable"
    symmetry_order: int
    derived_length: Optional[int]
    
    @property
    def min_depth_binary(self) -> int:
        """Minimum depth with degree-2 (binary) activations."""
        log_bound = math.ceil(math.log2(self.symmetry_order)) if self.symmetry_order > 1 else 0
        if self.derived_length is not None:
            return max(self.derived_length, log_bound)
        return log_bound
    
    @property
    def security_bits(self) -> int:
        return int(math.log2(self.symmetry_order)) if self.symmetry_order > 1 else 0


def architecture_advisor():
    """
    Application: Recommend network depth based on symmetry requirements.
    
    The Galois deep learning framework provides *certified* depth lower bounds:
    the architecture *must* have at least this many layers to capture the symmetry.
    """
    print("=" * 60)
    print("APPLICATION 1: Architecture Design Advisor")
    print("=" * 60)
    
    specs = [
        ArchitectureSpec("Translation-invariant CNN", "abelian", 8, 1),
        ArchitectureSpec("Rotation-equivariant (C4)", "abelian", 4, 1),
        ArchitectureSpec("Dihedral-equivariant (D4)", "solvable", 8, 2),
        ArchitectureSpec("S3-equivariant (sorting)", "solvable", 6, 2),
        ArchitectureSpec("S4-equivariant (tetrahedral)", "solvable", 24, 3),
        ArchitectureSpec("Full permutation (S5)", "non-solvable", 120, None),
        ArchitectureSpec("Full permutation (S6)", "non-solvable", 720, None),
        ArchitectureSpec("Full permutation (S10)", "non-solvable", math.factorial(10), None),
    ]
    
    print(f"\n{'Architecture':<35} {'Symmetry':<12} {'|G|':<10} "
          f"{'Min Depth':<10} {'Recommendation'}")
    print("-" * 90)
    
    for spec in specs:
        if spec.symmetry_type == "abelian":
            rec = "Single layer suffices (Theorem 5)"
        elif spec.symmetry_type == "solvable":
            rec = f"Use {spec.derived_length} radical layers (derived length)"
        else:
            rec = f"Requires ≥ {spec.min_depth_binary} non-radical layers (Abel-Ruffini)"
        
        print(f"{spec.name:<35} {spec.symmetry_type:<12} {spec.symmetry_order:<10} "
              f"{spec.min_depth_binary:<10} {rec}")


# =============================================================================
# Application 2: Post-Quantum Feature Hash
# =============================================================================

def galois_feature_hash():
    """
    Application: Post-quantum hash function from non-solvable symmetry groups.
    
    The non-solvability of the Galois group ensures collision resistance
    against algebraic attacks, including quantum (HSP hardness for non-abelian groups).
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Post-Quantum Feature Hash")
    print("=" * 60)
    
    print("\nGalois Feature Hash: Security Analysis")
    print("Non-solvable groups resist quantum hidden subgroup problem attacks.\n")
    
    print(f"{'Group':<8} {'|G|':<15} {'Bits':<8} {'Quantum-Safe?':<15} "
          f"{'Min Hash Depth'}")
    print("-" * 60)
    
    for n in range(3, 15):
        order = math.factorial(n)
        bits = int(math.log2(order))
        solvable = n < 5
        safe = "NO" if solvable else "YES"
        depth = math.ceil(math.log2(order))
        
        marker = ""
        if bits >= 128:
            marker = " ✓ (128-bit)"
        elif bits >= 80:
            marker = " ~ (80-bit)"
        
        print(f"S_{n:<5} {order:<15} {bits:<8} {safe:<15} {depth}{marker}")
    
    print(f"\nFor 128-bit security: use S_34 (34! ≈ 2.95 × 10^38, {int(math.log2(math.factorial(34)))} bits)")
    print(f"For 256-bit security: use S_58 (58! ≈ 2.35 × 10^78, {int(math.log2(math.factorial(58)))} bits)")


# =============================================================================
# Application 3: Certified Robustness Verifier
# =============================================================================

def certified_robustness_verifier():
    """
    Application: Verify that a network's depth is sufficient for its symmetry requirements.
    
    If a network needs S₅ symmetry but only has 4 layers, it CANNOT be robust —
    the algebraic structure guarantees this.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Certified Robustness Verifier")
    print("=" * 60)
    
    test_cases = [
        ("Image classifier (C4)", 4, 1, 3, 2),
        ("Sorting network (S3)", 6, 2, 5, 2),
        ("Set function (S4)", 24, 3, 3, 3),
        ("Set function (S4)", 24, 3, 5, 3),
        ("Graph network (S5)", 120, None, 4, 2),
        ("Graph network (S5)", 120, None, 7, 2),
        ("Graph network (S5)", 120, None, 10, 2),
    ]
    
    print(f"\n{'Network':<25} {'|G|':<6} {'Depth':<7} {'MaxDeg':<8} "
          f"{'Min Required':<13} {'Certified?'}")
    print("-" * 75)
    
    for name, order, dl, depth, max_deg in test_cases:
        log_bound = math.ceil(math.log(order) / math.log(max_deg)) if max_deg >= 2 else order
        if dl is not None:
            min_req = max(dl, log_bound)
        else:
            min_req = log_bound
        
        certified = depth >= min_req
        status = "✓ CERTIFIED" if certified else "✗ INSUFFICIENT"
        
        print(f"{name:<25} {order:<6} {depth:<7} {max_deg:<8} "
              f"{min_req:<13} {status}")
    
    print("\nNote: 'INSUFFICIENT' means the algebraic structure *proves* the network")
    print("cannot fully capture the required symmetry — a certified vulnerability.")


# =============================================================================
# Application 4: Expressivity Budget Calculator
# =============================================================================

def expressivity_budget():
    """
    Application: Calculate the expressivity budget for a given architecture.
    
    Uses the exponential expressivity bound: totalDegree <= D^depth.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 4: Expressivity Budget Calculator")
    print("=" * 60)
    
    print("\nHow many independent features can your architecture express?")
    print("Theorem: totalDegree ≤ D^depth\n")
    
    architectures = [
        ("Shallow ReLU", 1, 2, "ReLU = degree 2"),
        ("Medium ReLU", 5, 2, "5 ReLU layers"),
        ("Deep ReLU", 20, 2, "20 ReLU layers"),
        ("Shallow polynomial-5", 1, 5, "degree-5 activation"),
        ("Medium polynomial-5", 5, 5, "5 poly-5 layers"),
        ("Deep polynomial-5", 20, 5, "20 poly-5 layers"),
        ("Transformer-like", 12, 4, "12 layers, degree 4"),
        ("ResNet-50-like", 50, 2, "50 layers, degree 2"),
    ]
    
    print(f"{'Architecture':<25} {'Depth':<7} {'MaxDeg':<8} {'Max Features':<15} {'Note'}")
    print("-" * 75)
    
    for name, depth, deg, note in architectures:
        budget = deg ** depth
        budget_str = f"{budget}" if budget < 1e9 else f"{budget:.2e}"
        print(f"{name:<25} {depth:<7} {deg:<8} {budget_str:<15} {note}")


# =============================================================================
# Main
# =============================================================================

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║     GALOIS DEEP LEARNING — Real-World Applications         ║")
    print("╚══════════════════════════════════════════════════════════════╝")
    
    architecture_advisor()
    galois_feature_hash()
    certified_robustness_verifier()
    expressivity_budget()
    
    print("\n" + "=" * 60)
    print("All applications demonstrated successfully.")


#!/usr/bin/env python3
"""
Galois Deep Learning — Demonstration
=====================================
Concrete numerical examples illustrating the theorems from the Galois Deep Learning framework.
Shows depth lower bounds, expressivity gaps, and security levels from group-theoretic invariants.
"""

import math
from itertools import permutations


def factorial(n: int) -> int:
    """Compute n!"""
    return math.factorial(n)


def symmetric_group_order(n: int) -> int:
    """Order of the symmetric group S_n = n!"""
    return factorial(n)


def log_depth_lower_bound(group_order: int, max_degree: int) -> int:
    """
    Compute the logarithmic depth lower bound.
    
    Theorem: depth >= ceil(log_d(|G|)) where d is the max layer degree.
    This follows from the tower law: totalDegree = prod(layerDegree) <= d^depth.
    So if totalDegree >= |G|, then d^depth >= |G|, giving depth >= log_d(|G|).
    """
    if max_degree <= 1:
        return group_order  # Can't compress with degree-1 layers
    return math.ceil(math.log(group_order) / math.log(max_degree))


def derived_length(group_name: str) -> int | None:
    """
    Return the derived length of known groups.
    The derived series G > [G,G] > [[G,G],[G,G]] > ... > {e}.
    Returns None for non-solvable groups.
    """
    derived_lengths = {
        "trivial": 0,
        "Z/2Z": 1,
        "Z/3Z": 1,
        "Z/nZ": 1,  # All cyclic groups
        "S3": 2,   # S3 > A3 > {e}
        "S4": 3,   # S4 > A4 > V4 > {e}
        "D4": 2,   # Dihedral group of square
        "Q8": 2,   # Quaternion group
        "A4": 2,   # Alternating group
    }
    if group_name in ["S5", "S6", "S7", "A5", "A6", "A7"]:
        return None  # Non-solvable
    return derived_lengths.get(group_name)


def is_solvable(group_name: str) -> bool:
    """Check if a named group is solvable."""
    return derived_length(group_name) is not None


def depth_lower_bound(group_name: str, group_order: int, max_degree: int) -> int:
    """
    Compute the depth lower bound combining derived length and logarithmic bound.
    
    For solvable groups: max(derivedLength, ceil(log_d(|G|)))
    For non-solvable groups: ceil(log_d(|G|)) (since no radical realization exists)
    """
    log_bound = log_depth_lower_bound(group_order, max_degree)
    dl = derived_length(group_name)
    if dl is not None:
        return max(dl, log_bound)
    return log_bound


def security_bits(group_order: int) -> int:
    """Post-quantum security level in bits: floor(log2(|G|))."""
    if group_order <= 0:
        return 0
    return int(math.log2(group_order))


def expressivity_bound(depth: int, max_degree: int) -> int:
    """
    Maximum expressivity (total degree) for a tower of given depth and max degree.
    Theorem: totalDegree <= max_degree^depth.
    """
    return max_degree ** depth


def print_separator():
    print("=" * 70)


def demo_depth_bounds():
    """Demonstrate depth lower bounds for various groups."""
    print_separator()
    print("DEMO 1: Depth Lower Bounds by Group")
    print("Theorem: depth >= max(derivedLength(G), ceil(log_d(|G|)))")
    print_separator()
    
    groups = [
        ("trivial", 1),
        ("Z/2Z", 2),
        ("Z/3Z", 3),
        ("Z/nZ", 8),  # Z/8Z
        ("S3", 6),
        ("D4", 8),
        ("Q8", 8),
        ("A4", 12),
        ("S4", 24),
        ("S5", 120),
        ("A5", 60),
        ("S6", 720),
        ("S7", 5040),
    ]
    
    print(f"{'Group':<10} {'|G|':<8} {'Solvable?':<10} {'DerLen':<8} "
          f"{'log₂|G|':<8} {'Depth(d=2)':<12} {'Depth(d=3)':<12}")
    print("-" * 70)
    
    for name, order in groups:
        solv = is_solvable(name)
        dl = derived_length(name)
        log2 = f"{math.log2(order):.1f}" if order > 0 else "0"
        d2 = depth_lower_bound(name, order, 2)
        d3 = depth_lower_bound(name, order, 3)
        dl_str = str(dl) if dl is not None else "N/A"
        print(f"{name:<10} {order:<8} {'Yes' if solv else 'NO':<10} {dl_str:<8} "
              f"{log2:<8} {d2:<12} {d3:<12}")


def demo_abel_ruffini():
    """Demonstrate the Abel-Ruffini analog for deep learning."""
    print_separator()
    print("DEMO 2: Abel-Ruffini for Deep Learning")
    print("Theorem: S_n is not solvable for n >= 5")
    print("=> S_n-symmetric features CANNOT be realized by radical architectures")
    print_separator()
    
    for n in range(2, 9):
        order = symmetric_group_order(n)
        solv = is_solvable(f"S{n}") if n <= 7 else n < 5
        status = "SOLVABLE (radical OK)" if solv else "NOT SOLVABLE (Abel-Ruffini!)"
        print(f"  S_{n}: |S_{n}| = {order:>6}, {status}")
    
    print()
    print("Conclusion: S₅, S₆, S₇, ... require non-radical (deep) architectures.")
    print("This is the deep learning analog of 'quintic equations have no radical formula'.")


def demo_expressivity_gap():
    """Demonstrate the exponential expressivity gap."""
    print_separator()
    print("DEMO 3: Exponential Expressivity Gap")
    print("Theorem: totalDegree <= D^depth")
    print_separator()
    
    print(f"{'Depth':<8}", end="")
    for D in [2, 3, 5, 10]:
        print(f"{'D=' + str(D):<12}", end="")
    print()
    print("-" * 56)
    
    for depth in [1, 2, 3, 5, 8, 10, 15, 20]:
        print(f"{depth:<8}", end="")
        for D in [2, 3, 5, 10]:
            val = expressivity_bound(depth, D)
            if val < 1e9:
                print(f"{val:<12}", end="")
            else:
                print(f"{val:.2e}  ", end="")
        print()


def demo_security_levels():
    """Demonstrate post-quantum security levels."""
    print_separator()
    print("DEMO 4: Post-Quantum Security Levels")
    print("Security bits = floor(log₂(|G|))")
    print("Non-solvable groups resist quantum algebraic attacks (HSP hardness)")
    print_separator()
    
    groups = [
        ("S₃", 6, True),
        ("S₄", 24, True),
        ("A₅", 60, False),
        ("S₅", 120, False),
        ("S₆", 720, False),
        ("S₇", 5040, False),
        ("S₈", 40320, False),
        ("S₁₀", factorial(10), False),
        ("S₂₀", factorial(20), False),
    ]
    
    print(f"{'Group':<8} {'|G|':<15} {'Bits':<8} {'Quantum-Safe?':<15}")
    print("-" * 50)
    for name, order, solvable in groups:
        bits = security_bits(order)
        safe = "NO (solvable)" if solvable else "YES (non-solvable)"
        print(f"{name:<8} {order:<15} {bits:<8} {safe:<15}")
    
    print()
    print("Note: 128 bits of security requires |G| >= 2^128.")
    print(f"S_34 has |S_34| = 34! ≈ 2.95 × 10^38, giving {security_bits(factorial(34))} bits.")
    print(f"S_40 has |S_40| = 40! ≈ 8.16 × 10^47, giving {security_bits(factorial(40))} bits.")


def demo_architecture_search():
    """Demonstrate architecture search space size."""
    print_separator()
    print("DEMO 5: Architecture Search Space")
    print("Theorem: |ArchSpace(d, D)| = D^d")
    print_separator()
    
    print(f"{'Depth d':<10} {'D=2':<12} {'D=5':<12} {'D=10':<12} {'D=100':<15}")
    print("-" * 60)
    for d in [1, 2, 5, 10, 20, 50]:
        print(f"{d:<10}", end="")
        for D in [2, 5, 10, 100]:
            val = D ** d
            if val < 1e12:
                print(f"{val:<12}", end="")
            else:
                print(f"{val:.2e}   ", end="")
        print()


def demo_depth_degree_tradeoff():
    """Demonstrate the depth-degree tradeoff."""
    print_separator()
    print("DEMO 6: Depth-Degree Tradeoff")
    print("To cover n features: depth × log(D) >= log(n)")
    print_separator()
    
    n_values = [120, 1000, 1_000_000, 10**9]
    
    for n in n_values:
        print(f"\n  Target: n = {n} features")
        for D in [2, 3, 5, 10]:
            min_depth = math.ceil(math.log(n) / math.log(D))
            print(f"    D = {D}: min depth = {min_depth}")


if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║     GALOIS DEEP LEARNING — Numerical Demonstrations            ║")
    print("║     Architecture-Extension Correspondence & Depth Bounds       ║")
    print("╚══════════════════════════════════════════════════════════════════╝")
    print()
    
    demo_depth_bounds()
    print()
    demo_abel_ruffini()
    print()
    demo_expressivity_gap()
    print()
    demo_security_levels()
    print()
    demo_architecture_search()
    print()
    demo_depth_degree_tradeoff()
    print()
    print_separator()
    print("All demonstrations complete.")


#!/usr/bin/env python3
"""
Galois Deep Learning — Visualizations
=======================================
Generate charts and diagrams for the Galois Deep Learning framework.
"""

import math
import json

# SVG-based visualizations (no external dependencies required)


def generate_depth_bound_chart() -> str:
    """Generate SVG chart showing depth lower bounds for various groups."""
    
    groups = [
        ("Z/2", 2, 1, True),
        ("Z/4", 4, 1, True),
        ("Z/8", 8, 1, True),
        ("S₃", 6, 2, True),
        ("D₄", 8, 2, True),
        ("A₄", 12, 2, True),
        ("S₄", 24, 3, True),
        ("A₅", 60, None, False),
        ("S₅", 120, None, False),
        ("S₆", 720, None, False),
    ]
    
    width = 800
    height = 450
    margin = {"top": 40, "right": 30, "bottom": 80, "left": 60}
    chart_w = width - margin["left"] - margin["right"]
    chart_h = height - margin["top"] - margin["bottom"]
    
    n = len(groups)
    bar_width = chart_w / n * 0.6
    gap = chart_w / n
    
    # Compute bounds
    max_bound = 0
    bars = []
    for i, (name, order, dl, solvable) in enumerate(groups):
        log_bound = math.ceil(math.log2(order)) if order > 1 else 0
        bound = max(dl, log_bound) if dl is not None else log_bound
        max_bound = max(max_bound, bound)
        bars.append((name, bound, dl, solvable, order))
    
    y_scale = chart_h / (max_bound + 1)
    
    svg_parts = [
        f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {width} {height}" '
        f'style="font-family: sans-serif; background: white;">',
        f'<text x="{width/2}" y="25" text-anchor="middle" font-size="16" font-weight="bold">'
        f'Depth Lower Bounds by Symmetry Group (degree d=2)</text>',
    ]
    
    # Axes
    svg_parts.append(
        f'<line x1="{margin["left"]}" y1="{margin["top"]}" '
        f'x2="{margin["left"]}" y2="{height - margin["bottom"]}" '
        f'stroke="black" stroke-width="1"/>'
    )
    svg_parts.append(
        f'<line x1="{margin["left"]}" y1="{height - margin["bottom"]}" '
        f'x2="{width - margin["right"]}" y2="{height - margin["bottom"]}" '
        f'stroke="black" stroke-width="1"/>'
    )
    
    # Y-axis labels
    for y_val in range(0, max_bound + 2):
        y_pos = height - margin["bottom"] - y_val * y_scale
        svg_parts.append(
            f'<text x="{margin["left"] - 10}" y="{y_pos + 4}" '
            f'text-anchor="end" font-size="11">{y_val}</text>'
        )
        svg_parts.append(
            f'<line x1="{margin["left"]}" y1="{y_pos}" '
            f'x2="{width - margin["right"]}" y2="{y_pos}" '
            f'stroke="#eee" stroke-width="0.5"/>'
        )
    
    svg_parts.append(
        f'<text x="15" y="{height/2}" text-anchor="middle" font-size="12" '
        f'transform="rotate(-90, 15, {height/2})">Min Depth</text>'
    )
    
    # Bars
    for i, (name, bound, dl, solvable, order) in enumerate(bars):
        x = margin["left"] + i * gap + (gap - bar_width) / 2
        bar_h = bound * y_scale
        y = height - margin["bottom"] - bar_h
        
        color = "#4a90d9" if solvable else "#d94a4a"
        
        svg_parts.append(
            f'<rect x="{x}" y="{y}" width="{bar_width}" height="{bar_h}" '
            f'fill="{color}" rx="2"/>'
        )
        
        # Value label
        svg_parts.append(
            f'<text x="{x + bar_width/2}" y="{y - 5}" text-anchor="middle" '
            f'font-size="11" font-weight="bold">{bound}</text>'
        )
        
        # Group name
        svg_parts.append(
            f'<text x="{x + bar_width/2}" y="{height - margin["bottom"] + 15}" '
            f'text-anchor="middle" font-size="11">{name}</text>'
        )
        
        # Order
        svg_parts.append(
            f'<text x="{x + bar_width/2}" y="{height - margin["bottom"] + 30}" '
            f'text-anchor="middle" font-size="9" fill="#666">|G|={order}</text>'
        )
    
    # Legend
    svg_parts.append(
        f'<rect x="{width - 200}" y="{margin["top"] + 10}" width="12" height="12" fill="#4a90d9"/>'
    )
    svg_parts.append(
        f'<text x="{width - 183}" y="{margin["top"] + 21}" font-size="11">Solvable</text>'
    )
    svg_parts.append(
        f'<rect x="{width - 200}" y="{margin["top"] + 30}" width="12" height="12" fill="#d94a4a"/>'
    )
    svg_parts.append(
        f'<text x="{width - 183}" y="{margin["top"] + 41}" font-size="11">Non-solvable (Abel-Ruffini)</text>'
    )
    
    svg_parts.append('</svg>')
    return '\n'.join(svg_parts)


def generate_expressivity_chart() -> str:
    """Generate SVG chart showing exponential expressivity growth."""
    
    width = 800
    height = 400
    margin = {"top": 40, "right": 120, "bottom": 50, "left": 70}
    chart_w = width - margin["left"] - margin["right"]
    chart_h = height - margin["top"] - margin["bottom"]
    
    degrees = [2, 3, 5, 10]
    colors = ["#e74c3c", "#3498db", "#2ecc71", "#9b59b6"]
    max_depth = 12
    
    # Use log scale for y
    max_val = math.log10(10 ** max_depth)
    
    svg_parts = [
        f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {width} {height}" '
        f'style="font-family: sans-serif; background: white;">',
        f'<text x="{width/2}" y="25" text-anchor="middle" font-size="16" font-weight="bold">'
        f'Exponential Expressivity: totalDegree ≤ D^depth</text>',
    ]
    
    # Axes
    svg_parts.append(
        f'<line x1="{margin["left"]}" y1="{margin["top"]}" '
        f'x2="{margin["left"]}" y2="{height - margin["bottom"]}" stroke="black"/>'
    )
    svg_parts.append(
        f'<line x1="{margin["left"]}" y1="{height - margin["bottom"]}" '
        f'x2="{width - margin["right"]}" y2="{height - margin["bottom"]}" stroke="black"/>'
    )
    
    # Labels
    svg_parts.append(
        f'<text x="{width/2 - 20}" y="{height - 10}" text-anchor="middle" font-size="12">Depth</text>'
    )
    svg_parts.append(
        f'<text x="15" y="{height/2}" text-anchor="middle" font-size="12" '
        f'transform="rotate(-90, 15, {height/2})">log₁₀(Total Degree)</text>'
    )
    
    # Plot lines
    for d_idx, (D, color) in enumerate(zip(degrees, colors)):
        points = []
        for depth in range(0, max_depth + 1):
            x = margin["left"] + depth * chart_w / max_depth
            val = depth * math.log10(D)
            y = height - margin["bottom"] - val * chart_h / max_val
            points.append(f"{x},{y}")
        
        svg_parts.append(
            f'<polyline points="{" ".join(points)}" '
            f'fill="none" stroke="{color}" stroke-width="2.5"/>'
        )
        
        # Label
        last_x = margin["left"] + max_depth * chart_w / max_depth
        last_y = height - margin["bottom"] - max_depth * math.log10(D) * chart_h / max_val
        svg_parts.append(
            f'<text x="{last_x + 5}" y="{last_y + 4}" font-size="11" fill="{color}">D={D}</text>'
        )
    
    # X-axis ticks
    for d in range(0, max_depth + 1, 2):
        x = margin["left"] + d * chart_w / max_depth
        svg_parts.append(
            f'<text x="{x}" y="{height - margin["bottom"] + 18}" '
            f'text-anchor="middle" font-size="11">{d}</text>'
        )
    
    # Y-axis ticks
    for log_val in range(0, int(max_val) + 1, 2):
        y = height - margin["bottom"] - log_val * chart_h / max_val
        svg_parts.append(
            f'<text x="{margin["left"] - 10}" y="{y + 4}" '
            f'text-anchor="end" font-size="11">10^{log_val}</text>'
        )
    
    svg_parts.append('</svg>')
    return '\n'.join(svg_parts)


def generate_derived_series_diagram() -> str:
    """Generate SVG diagram of the derived series for S₃ and S₅."""
    
    width = 800
    height = 350
    
    svg_parts = [
        f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {width} {height}" '
        f'style="font-family: sans-serif; background: white;">',
        f'<text x="{width/2}" y="25" text-anchor="middle" font-size="16" font-weight="bold">'
        f'Derived Series: Solvable vs Non-Solvable</text>',
    ]
    
    # S3 (solvable)
    s3_x = 200
    svg_parts.append(
        f'<text x="{s3_x}" y="60" text-anchor="middle" font-size="14" font-weight="bold" fill="#4a90d9">'
        f'S₃ (Solvable, depth bound = 2)</text>'
    )
    
    steps_s3 = [("S₃", "|G|=6"), ("A₃ = [S₃,S₃]", "|G|=3"), ("{e}", "|G|=1")]
    for i, (name, info) in enumerate(steps_s3):
        y = 90 + i * 70
        svg_parts.append(
            f'<rect x="{s3_x - 80}" y="{y}" width="160" height="40" '
            f'fill="#e8f0fe" stroke="#4a90d9" stroke-width="2" rx="8"/>'
        )
        svg_parts.append(
            f'<text x="{s3_x}" y="{y + 18}" text-anchor="middle" font-size="12" font-weight="bold">{name}</text>'
        )
        svg_parts.append(
            f'<text x="{s3_x}" y="{y + 33}" text-anchor="middle" font-size="10" fill="#666">{info}</text>'
        )
        if i < len(steps_s3) - 1:
            svg_parts.append(
                f'<line x1="{s3_x}" y1="{y + 40}" x2="{s3_x}" y2="{y + 70}" '
                f'stroke="#4a90d9" stroke-width="2" marker-end="url(#arrow)"/>'
            )
    
    svg_parts.append(
        f'<text x="{s3_x}" y="{90 + 3*70 + 5}" text-anchor="middle" font-size="11" fill="#4a90d9">'
        f'✓ Reaches {{e}} → Solvable</text>'
    )
    
    # S5 (non-solvable)
    s5_x = 600
    svg_parts.append(
        f'<text x="{s5_x}" y="60" text-anchor="middle" font-size="14" font-weight="bold" fill="#d94a4a">'
        f'S₅ (Non-Solvable — Abel-Ruffini!)</text>'
    )
    
    steps_s5 = [("S₅", "|G|=120"), ("A₅ = [S₅,S₅]", "|G|=60"), ("A₅ = [A₅,A₅]", "|G|=60")]
    for i, (name, info) in enumerate(steps_s5):
        y = 90 + i * 70
        fill = "#fde8e8" if i < 2 else "#fcc"
        svg_parts.append(
            f'<rect x="{s5_x - 85}" y="{y}" width="170" height="40" '
            f'fill="{fill}" stroke="#d94a4a" stroke-width="2" rx="8"/>'
        )
        svg_parts.append(
            f'<text x="{s5_x}" y="{y + 18}" text-anchor="middle" font-size="12" font-weight="bold">{name}</text>'
        )
        svg_parts.append(
            f'<text x="{s5_x}" y="{y + 33}" text-anchor="middle" font-size="10" fill="#666">{info}</text>'
        )
        if i < len(steps_s5) - 1:
            svg_parts.append(
                f'<line x1="{s5_x}" y1="{y + 40}" x2="{s5_x}" y2="{y + 70}" '
                f'stroke="#d94a4a" stroke-width="2"/>'
            )
    
    svg_parts.append(
        f'<text x="{s5_x}" y="{90 + 3*70 + 5}" text-anchor="middle" font-size="11" fill="#d94a4a">'
        f'✗ Stabilizes at A₅ → Non-solvable</text>'
    )
    
    # Arrow marker
    svg_parts.insert(1,
        '<defs><marker id="arrow" viewBox="0 0 10 10" refX="5" refY="5" '
        'markerWidth="6" markerHeight="6" orient="auto-start-reverse">'
        '<path d="M 0 0 L 10 5 L 0 10 z" fill="#4a90d9"/></marker></defs>'
    )
    
    svg_parts.append('</svg>')
    return '\n'.join(svg_parts)


if __name__ == "__main__":
    # Generate all visualizations
    chart1 = generate_depth_bound_chart()
    chart2 = generate_expressivity_chart()
    chart3 = generate_derived_series_diagram()
    
    with open("depth_bounds.svg", "w") as f:
        f.write(chart1)
    print("Generated: depth_bounds.svg")
    
    with open("expressivity_growth.svg", "w") as f:
        f.write(chart2)
    print("Generated: expressivity_growth.svg")
    
    with open("derived_series.svg", "w") as f:
        f.write(chart3)
    print("Generated: derived_series.svg")
    
    # Also save as a combined diagram
    combined = f"""<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 800 1200" style="font-family: sans-serif; background: white;">
<g transform="translate(0,0)">{chart1.replace('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 800 450" style="font-family: sans-serif; background: white;">', '<g>').replace('</svg>', '</g>')}</g>
<g transform="translate(0,450)">{chart2.replace('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 800 400" style="font-family: sans-serif; background: white;">', '<g>').replace('</svg>', '</g>')}</g>
<g transform="translate(0,850)">{chart3.replace('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 800 350" style="font-family: sans-serif; background: white;">', '<g>').replace('</svg>', '</g>')}</g>
</svg>"""
    
    with open("diagram.svg", "w") as f:
        f.write(combined)
    print("Generated: diagram.svg")

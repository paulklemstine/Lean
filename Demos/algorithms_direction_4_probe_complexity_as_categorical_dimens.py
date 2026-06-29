#!/usr/bin/env python3
"""
Probe Complexity Algorithms

Implements algorithms for computing and testing probe complexity
in finite categories, with specializations for:
- Finite-dimensional vector spaces over finite fields
- Semisimple representation categories
- Module categories over finite rings

References:
- Pythagorean/ProbeComplexity/CategoricalDimension.lean (formal verification)
- RESEARCH_PAPER.md (mathematical details)
"""

from typing import List, Tuple, Dict, Set, Optional, Callable, Any
from itertools import combinations, product as cart_product
import numpy as np


# ============================================================================
# Core Data Structures
# ============================================================================

class Morphism:
    """Represents a morphism in a finite category."""

    def __init__(self, source: str, target: str, data: Any, label: str = ""):
        self.source = source
        self.target = target
        self.data = data  # Concrete representation (e.g., matrix)
        self.label = label

    def __eq__(self, other):
        if not isinstance(other, Morphism):
            return False
        return (self.source == other.source and
                self.target == other.target and
                np.array_equal(self.data, other.data))

    def __hash__(self):
        return hash((self.source, self.target, self.data.tobytes() if hasattr(self.data, 'tobytes') else str(self.data)))

    def __repr__(self):
        return f"Mor({self.source}→{self.target}, {self.label or self.data})"


class FiniteCategoryData:
    """
    Complete data for a finite category.

    Attributes:
        objects: list of object names
        hom_sets: dict mapping (source, target) -> list of Morphism
        compose: function (Morphism, Morphism) -> Morphism
        identities: dict mapping object -> Morphism (identity morphism)
    """

    def __init__(
        self,
        objects: List[str],
        hom_sets: Dict[Tuple[str, str], List[Morphism]],
        compose: Callable[[Morphism, Morphism], Morphism],
        identities: Dict[str, Morphism]
    ):
        self.objects = objects
        self.hom_sets = hom_sets
        self.compose = compose
        self.identities = identities

    def hom(self, source: str, target: str) -> List[Morphism]:
        """Get the hom-set Hom(source, target)."""
        return self.hom_sets.get((source, target), [])


# ============================================================================
# Algorithm 1: Test Separation
# ============================================================================

def test_separation(
    cat: FiniteCategoryData,
    probes: List[str],
    verbose: bool = False
) -> bool:
    """
    Test whether a set of probe objects is precompose-separating.

    A set S is precompose-separating if for all parallel morphisms f ≠ g : X → Y,
    there exists P ∈ S and h : P → X such that h ∘ f ≠ h ∘ g.

    Time complexity: O(|Ob|² · |Hom|² · |S| · |Hom|)
    Space complexity: O(1) additional

    Args:
        cat: The finite category
        probes: List of probe object names
        verbose: If True, print unseparated pairs

    Returns:
        True if probes form a separating family
    """
    for X in cat.objects:
        for Y in cat.objects:
            morphisms = cat.hom(X, Y)
            for i, f in enumerate(morphisms):
                for j in range(i + 1, len(morphisms)):
                    g = morphisms[j]
                    if f == g:
                        continue

                    # Check if probes separate f and g
                    separated = False
                    for P in probes:
                        for h in cat.hom(P, X):
                            hf = cat.compose(h, f)
                            hg = cat.compose(h, g)
                            if hf != hg:
                                separated = True
                                break
                        if separated:
                            break

                    if not separated:
                        if verbose:
                            print(f"  UNSEPARATED: {f} vs {g}")
                        return False
    return True


# ============================================================================
# Algorithm 2: Compute Probe Complexity (Exact)
# ============================================================================

def compute_probe_complexity(
    cat: FiniteCategoryData,
    verbose: bool = False
) -> Tuple[int, List[str]]:
    """
    Compute the exact probe complexity of a finite category.

    Searches through subsets of increasing size until a separating
    family is found.

    Time complexity: O(C(n, pc) · |Ob|² · |Hom|² · pc · |Hom|)
    Space complexity: O(n) for the combinatorial search

    Args:
        cat: The finite category
        verbose: If True, print progress

    Returns:
        Tuple of (probe_complexity, minimal_separating_family)
    """
    n = len(cat.objects)

    for k in range(n + 1):
        if verbose:
            print(f"  Testing subsets of size {k}...")

        for subset in combinations(cat.objects, k):
            probes = list(subset)
            if test_separation(cat, probes):
                if verbose:
                    print(f"  Found separating family: {probes}")
                return k, probes

    # This should never happen (Theorem: univ is always separating)
    return n, list(cat.objects)


# ============================================================================
# Algorithm 3: Compute Probe Complexity (Optimized for Semisimple)
# ============================================================================

def compute_probe_complexity_semisimple(
    simples: List[str],
    cat: FiniteCategoryData,
    verbose: bool = False
) -> Tuple[int, List[str]]:
    """
    Compute probe complexity for a semisimple category with known simples.

    In a semisimple category, the simples form a separating family
    (Conjecture, verified computationally). This algorithm verifies this
    and reports the result.

    Time complexity: O(|Ob|² · |Hom|² · n · |Hom|) where n = |simples|
    Space complexity: O(1) additional

    Args:
        simples: List of simple object names
        cat: The finite category
        verbose: If True, print details

    Returns:
        Tuple of (probe_complexity, separating_family)
    """
    if verbose:
        print(f"  Candidate probe basis (simples): {simples}")

    # Verify that simples form a separating family
    if test_separation(cat, simples, verbose=verbose):
        if verbose:
            print(f"  ✓ Simples form a separating family")

        # Check minimality: try removing each simple
        for i, s in enumerate(simples):
            reduced = simples[:i] + simples[i+1:]
            if test_separation(cat, reduced):
                if verbose:
                    print(f"  ⚠ Removing {s} still separates — not minimal!")
                # Fall back to exact computation
                return compute_probe_complexity(cat, verbose)

        if verbose:
            print(f"  ✓ No simple can be removed — family is minimal")
        return len(simples), simples
    else:
        if verbose:
            print(f"  ✗ Simples do NOT form a separating family!")
            print(f"  Falling back to exact computation...")
        return compute_probe_complexity(cat, verbose)


# ============================================================================
# Algorithm 4: Profile Capacity Bound
# ============================================================================

def profile_capacity_bound(
    cat: FiniteCategoryData,
    probes: List[str],
    X: str,
    Y: str
) -> int:
    """
    Compute the profile capacity bound for Hom(X, Y) given probes.

    The bound is: |Hom(X, Y)| ≤ ∏_{P ∈ probes} |Hom(P, Y)|^|Hom(P, X)|

    This is the information-theoretic capacity bound from
    card_hom_le_profile_capacity.

    Args:
        cat: The finite category
        probes: List of probe objects
        X, Y: Source and target objects

    Returns:
        The capacity bound
    """
    capacity = 1
    for P in probes:
        hom_px = len(cat.hom(P, X))
        hom_py = len(cat.hom(P, Y))
        capacity *= hom_py ** hom_px
    return capacity


def verify_capacity_bounds(
    cat: FiniteCategoryData,
    probes: List[str],
    verbose: bool = True
) -> bool:
    """
    Verify the profile capacity bound for all hom-sets.

    Returns True if the bound holds for all (X, Y).
    """
    all_hold = True
    for X in cat.objects:
        for Y in cat.objects:
            actual = len(cat.hom(X, Y))
            bound = profile_capacity_bound(cat, probes, X, Y)
            holds = actual <= bound
            if verbose:
                status = "✓" if holds else "✗"
                print(f"  {status} |Hom({X},{Y})| = {actual} ≤ {bound}")
            if not holds:
                all_hold = False
    return all_hold


# ============================================================================
# Algorithm 5: Discrimination Curve
# ============================================================================

def discrimination_fraction(
    cat: FiniteCategoryData,
    probes: List[str],
    num_samples: int = 1000
) -> float:
    """
    Compute the fraction of random morphism pairs distinguished by probes.

    This measures the "partial separation" power of an incomplete probe set,
    relevant to the categorical compressed sensing direction.

    Args:
        cat: The finite category
        probes: List of probe objects
        num_samples: Number of random pairs to test

    Returns:
        Fraction of pairs successfully separated (0.0 to 1.0)
    """
    import random

    separated_count = 0
    total_pairs = 0

    for _ in range(num_samples):
        # Pick random X, Y
        X = random.choice(cat.objects)
        Y = random.choice(cat.objects)
        morphisms = cat.hom(X, Y)
        if len(morphisms) < 2:
            continue

        # Pick two distinct morphisms
        f, g = random.sample(morphisms, 2)
        if f == g:
            continue
        total_pairs += 1

        # Check separation
        separated = False
        for P in probes:
            for h in cat.hom(P, X):
                hf = cat.compose(h, f)
                hg = cat.compose(h, g)
                if hf != hg:
                    separated = True
                    break
            if separated:
                break

        if separated:
            separated_count += 1

    if total_pairs == 0:
        return 1.0  # No pairs to test
    return separated_count / total_pairs


# ============================================================================
# Category Constructors
# ============================================================================

def make_fvect_category(q: int, max_dim: int = 2) -> FiniteCategoryData:
    """
    Construct FVect(F_q) with objects of dimension 0, 1, ..., max_dim.

    Args:
        q: Field size (must be prime)
        max_dim: Maximum dimension of objects

    Returns:
        FiniteCategoryData for FVect(F_q)
    """
    objects = [f"F{q}^{d}" for d in range(max_dim + 1)]
    dims = list(range(max_dim + 1))

    def all_matrices(rows, cols):
        if rows == 0 or cols == 0:
            return [np.zeros((max(rows, 1), max(cols, 1)), dtype=int)]
        entries = list(range(q))
        result = []
        for vals in cart_product(entries, repeat=rows * cols):
            mat = np.array(vals, dtype=int).reshape(rows, cols)
            result.append(mat)
        return result

    hom_sets = {}
    for i, d1 in enumerate(dims):
        for j, d2 in enumerate(dims):
            matrices = all_matrices(d2, d1)
            hom_sets[(objects[i], objects[j])] = [
                Morphism(objects[i], objects[j], m) for m in matrices
            ]

    def compose(f: Morphism, g: Morphism) -> Morphism:
        result_data = (g.data @ f.data) % q
        return Morphism(f.source, g.target, result_data)

    identities = {
        objects[d]: Morphism(objects[d], objects[d], np.eye(max(d, 1), dtype=int))
        for d in range(max_dim + 1)
    }

    return FiniteCategoryData(objects, hom_sets, compose, identities)


# ============================================================================
# Main Demo
# ============================================================================

if __name__ == "__main__":
    print("=" * 60)
    print("  PROBE COMPLEXITY ALGORITHMS")
    print("=" * 60)

    # Example: FVect(F_2) with dim ≤ 2
    print("\n--- FVect(F_2) ---")
    cat = make_fvect_category(2, max_dim=2)
    pc, basis = compute_probe_complexity(cat, verbose=True)
    print(f"  Probe complexity: {pc}")
    print(f"  Minimal separating family: {basis}")

    # Verify capacity bounds
    print("\n  Capacity bounds with minimal separating family:")
    verify_capacity_bounds(cat, basis)

    # Discrimination curve
    print("\n  Discrimination curve:")
    for k in range(len(cat.objects) + 1):
        for subset in combinations(cat.objects, k):
            frac = discrimination_fraction(cat, list(subset), num_samples=500)
            print(f"    Probes={list(subset)}: {frac*100:.0f}% pairs separated")
            break  # Just one example per size

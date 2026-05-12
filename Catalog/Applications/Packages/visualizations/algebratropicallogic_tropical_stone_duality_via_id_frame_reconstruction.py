"""
Tropical Stone Duality — Algorithms

This module implements the core algorithms from the Tropical Stone Duality theory:
1. Canonical preorder computation on spectra
2. Frame reconstruction from algebraic data
3. Evaluation map construction and verification
4. Residuation checking
"""

from typing import List, Tuple, Dict, Set, Callable, Optional
from dataclasses import dataclass
import itertools


# =============================================================================
# Generic Bounded Lattice with Heyting Implication
# =============================================================================

@dataclass(frozen=True)
class LatticeElement:
    """A generic lattice element identified by name."""
    name: str

    def __repr__(self):
        return self.name


class HeytingLattice:
    """A finite bounded lattice with Heyting implication.

    This is the algebraic side of Tropical Stone Duality: an 'idempotent
    Heyting semimodule' in the terminology of the theory.

    Attributes:
        elements: list of all elements
        le: order relation as a dict of sets
        sup: join operation
        inf: meet operation
        himp: Heyting implication
        top: greatest element
        bot: least element
    """

    def __init__(
        self,
        elements: List[LatticeElement],
        le_pairs: List[Tuple[LatticeElement, LatticeElement]],
        sup: Dict[Tuple[LatticeElement, LatticeElement], LatticeElement],
        inf: Dict[Tuple[LatticeElement, LatticeElement], LatticeElement],
        himp: Dict[Tuple[LatticeElement, LatticeElement], LatticeElement],
        top: LatticeElement,
        bot: LatticeElement,
    ):
        self.elements = elements
        self.le_set = set(le_pairs)
        self.sup_table = sup
        self.inf_table = inf
        self.himp_table = himp
        self.top = top
        self.bot = bot

    def le(self, a: LatticeElement, b: LatticeElement) -> bool:
        return (a, b) in self.le_set

    def join(self, a: LatticeElement, b: LatticeElement) -> LatticeElement:
        return self.sup_table[(a, b)]

    def meet(self, a: LatticeElement, b: LatticeElement) -> LatticeElement:
        return self.inf_table[(a, b)]

    def imp(self, a: LatticeElement, b: LatticeElement) -> LatticeElement:
        return self.himp_table[(a, b)]

    def verify_residuation(self) -> bool:
        """Verify: a ⊓ x ≤ b iff x ≤ himp(a, b) for all a, x, b.

        Time complexity: O(n^3) where n = |elements|.
        """
        for a in self.elements:
            for x in self.elements:
                for b in self.elements:
                    lhs = self.le(self.meet(a, x), b)
                    rhs = self.le(x, self.imp(a, b))
                    if lhs != rhs:
                        return False
        return True


# =============================================================================
# Tropical Point (Morphism to Truth Object)
# =============================================================================

class TropicalPoint:
    """A tropical prime point: a structure-preserving map from a Heyting
    lattice to a truth object (Bool).

    Attributes:
        name: identifier for the point
        values: dict mapping lattice elements to bool
    """

    def __init__(self, name: str, values: Dict[LatticeElement, bool]):
        self.name = name
        self.values = values

    def __call__(self, x: LatticeElement) -> bool:
        return self.values[x]

    def __repr__(self):
        return self.name

    def verify_sup_preservation(self, lattice: HeytingLattice) -> bool:
        """Check: p(a ⊔ b) = p(a) ∨ p(b) for all a, b."""
        for a in lattice.elements:
            for b in lattice.elements:
                if self(lattice.join(a, b)) != (self(a) or self(b)):
                    return False
        return True

    def verify_bounds(self, lattice: HeytingLattice) -> bool:
        """Check: p(⊤) = True and p(⊥) = False."""
        return self(lattice.top) == True and self(lattice.bot) == False

    def verify_imp_compatibility(self, lattice: HeytingLattice) -> bool:
        """Check: p(a) ≤ p(b) → p(himp(a,b)) = True."""
        for a in lattice.elements:
            for b in lattice.elements:
                if self(a) <= self(b):
                    if not self(lattice.imp(a, b)):
                        return False
        return True


# =============================================================================
# Algorithm 1: Canonical Preorder Computation
# =============================================================================

def compute_canonical_preorder(
    points: List[TropicalPoint],
    elements: List[LatticeElement],
) -> Dict[Tuple[str, str], bool]:
    """Compute the canonical preorder on a finite spectrum.

    The canonical preorder is: p ≤ q iff ∀ a ∈ M, p(a) ≤ q(a).

    Args:
        points: list of tropical prime points
        elements: list of lattice elements

    Returns:
        Dictionary mapping (p.name, q.name) to bool.

    Time complexity: O(|points|^2 × |elements|)
    Space complexity: O(|points|^2)
    """
    result = {}
    for p in points:
        for q in points:
            le = all(p(a) <= q(a) for a in elements)
            result[(p.name, q.name)] = le
    return result


# =============================================================================
# Algorithm 2: Frame Reconstruction
# =============================================================================

@dataclass
class KripkeFrame:
    """A finite Kripke frame: worlds with accessibility relation."""
    worlds: List[str]
    relation: Dict[Tuple[str, str], bool]

    def is_reflexive(self) -> bool:
        return all(self.relation.get((w, w), False) for w in self.worlds)

    def is_transitive(self) -> bool:
        for u in self.worlds:
            for v in self.worlds:
                for w in self.worlds:
                    if (self.relation.get((u, v), False) and
                        self.relation.get((v, w), False) and
                        not self.relation.get((u, w), False)):
                        return False
        return True

    def display(self):
        """Print the frame's accessibility relation."""
        print(f"  Worlds: {self.worlds}")
        print(f"  Relations:")
        for u in self.worlds:
            related = [v for v in self.worlds if self.relation.get((u, v), False)]
            print(f"    {u} → {related}")


def reconstruct_frame(
    points: List[TropicalPoint],
    elements: List[LatticeElement],
) -> KripkeFrame:
    """Reconstruct a finite Kripke frame from the prime spectrum.

    This is the core algorithmic content of Tropical Stone Duality:
    given the algebraic data (points evaluating elements), we extract
    the semantic frame.

    Args:
        points: tropical prime points (the spectrum)
        elements: lattice elements

    Returns:
        A KripkeFrame whose worlds are the points and whose relation
        is the canonical preorder.

    Time complexity: O(|points|^2 × |elements|)

    Pseudocode:
        1. For each pair (p, q) of points:
           a. Check if p(a) ≤ q(a) for ALL elements a
           b. If yes, set p → q in the frame
        2. Return the frame

    The correctness theorem (computeCanonicalOrder_spec) guarantees
    this computed relation equals the canonical preorder.
    """
    preorder = compute_canonical_preorder(points, elements)
    worlds = [p.name for p in points]
    return KripkeFrame(worlds=worlds, relation=preorder)


# =============================================================================
# Algorithm 3: Evaluation Map and Separation Check
# =============================================================================

def check_separation(
    points: List[TropicalPoint],
    elements: List[LatticeElement],
) -> Tuple[bool, Optional[Tuple[LatticeElement, LatticeElement]]]:
    """Check whether points separate all distinct elements.

    Args:
        points: list of tropical prime points
        elements: list of lattice elements

    Returns:
        (True, None) if separated, or (False, (a, b)) for a non-separated pair.

    Time complexity: O(|elements|^2 × |points|)
    """
    for a in elements:
        for b in elements:
            if a != b:
                separated = any(p(a) != p(b) for p in points)
                if not separated:
                    return False, (a, b)
    return True, None


def compute_evaluation_map(
    points: List[TropicalPoint],
    elements: List[LatticeElement],
) -> Dict[LatticeElement, Tuple[bool, ...]]:
    """Compute the evaluation map: M → (Spec → Bool).

    Args:
        points: list of tropical prime points
        elements: list of lattice elements

    Returns:
        Dictionary mapping each element to its tuple of evaluations.

    Time complexity: O(|elements| × |points|)
    """
    return {a: tuple(p(a) for p in points) for a in elements}


# =============================================================================
# Algorithm 4: Implication Table Reconstruction
# =============================================================================

def reconstruct_implication_table(
    lattice: HeytingLattice,
    points: List[TropicalPoint],
) -> Dict[Tuple[LatticeElement, LatticeElement], Tuple[bool, ...]]:
    """Reconstruct the implication table from the spectrum.

    For each pair (a, b), compute the evaluation of himp(a, b) at each point.

    Time complexity: O(|elements|^2 × |points|)
    """
    table = {}
    for a in lattice.elements:
        for b in lattice.elements:
            h = lattice.imp(a, b)
            table[(a, b)] = tuple(p(h) for p in points)
    return table


# =============================================================================
# Diamond Lattice Construction
# =============================================================================

def build_diamond_lattice() -> HeytingLattice:
    """Construct the 4-element diamond lattice with Heyting implication."""
    bot = LatticeElement('⊥')
    left = LatticeElement('a')
    right = LatticeElement('b')
    top = LatticeElement('⊤')
    elems = [bot, left, right, top]

    # Order: bot ≤ everything, everything ≤ top, a ∥ b
    le_pairs = [(x, y) for x in elems for y in elems
                if x == bot or y == top or x == y]

    # Sup table
    sup = {}
    for x in elems:
        for y in elems:
            if x == bot: sup[(x, y)] = y
            elif y == bot: sup[(x, y)] = x
            elif x == top or y == top: sup[(x, y)] = top
            elif x == y: sup[(x, y)] = x
            else: sup[(x, y)] = top

    # Inf table
    inf = {}
    for x in elems:
        for y in elems:
            if x == top: inf[(x, y)] = y
            elif y == top: inf[(x, y)] = x
            elif x == bot or y == bot: inf[(x, y)] = bot
            elif x == y: inf[(x, y)] = x
            else: inf[(x, y)] = bot

    # Heyting implication
    himp = {
        (bot, bot): top, (bot, left): top, (bot, right): top, (bot, top): top,
        (left, bot): right, (left, left): top, (left, right): right, (left, top): top,
        (right, bot): left, (right, left): left, (right, right): top, (right, top): top,
        (top, bot): bot, (top, left): left, (top, right): right, (top, top): top,
    }

    return HeytingLattice(elems, le_pairs, sup, inf, himp, top, bot)


def build_diamond_points(lattice: HeytingLattice) -> List[TropicalPoint]:
    """Build the two separating points for the diamond lattice."""
    bot, left, right, top = lattice.elements

    p_left = TropicalPoint('p_L', {bot: False, left: True, right: False, top: True})
    p_right = TropicalPoint('p_R', {bot: False, left: False, right: True, top: True})

    return [p_left, p_right]


# =============================================================================
# Main demonstration
# =============================================================================

if __name__ == "__main__":
    print("\n" + "=" * 60)
    print("ALGORITHMS — Tropical Stone Duality")
    print("=" * 60)

    # Build diamond lattice
    lattice = build_diamond_lattice()
    points = build_diamond_points(lattice)

    # 1. Verify residuation
    print("\n1. Residuation verification:")
    ok = lattice.verify_residuation()
    print(f"   {'✓' if ok else '✗'} Residuation holds: {ok}")

    # 2. Verify points
    print("\n2. Point verification:")
    for p in points:
        sup_ok = p.verify_sup_preservation(lattice)
        bnd_ok = p.verify_bounds(lattice)
        imp_ok = p.verify_imp_compatibility(lattice)
        print(f"   {p.name}: sup={'✓' if sup_ok else '✗'}, "
              f"bounds={'✓' if bnd_ok else '✗'}, imp={'✓' if imp_ok else '✗'}")

    # 3. Check separation
    print("\n3. Separation check:")
    sep, witness = check_separation(points, lattice.elements)
    print(f"   {'✓' if sep else '✗'} Fully separating: {sep}")

    # 4. Compute evaluation map
    print("\n4. Evaluation map:")
    eval_map = compute_evaluation_map(points, lattice.elements)
    for elem, vals in eval_map.items():
        print(f"   eval({elem}) = {vals}")

    # 5. Reconstruct frame
    print("\n5. Frame reconstruction:")
    frame = reconstruct_frame(points, lattice.elements)
    frame.display()
    print(f"   Reflexive: {frame.is_reflexive()}")
    print(f"   Transitive: {frame.is_transitive()}")

    # 6. Implication table
    print("\n6. Reconstructed implication table (as evaluations):")
    imp_table = reconstruct_implication_table(lattice, points)
    for (a, b), vals in imp_table.items():
        print(f"   himp({a}, {b}) evaluated = {vals}")

    # 7. Verify order embedding
    print("\n7. Order embedding verification:")
    all_ok = True
    for a in lattice.elements:
        for b in lattice.elements:
            alg_le = lattice.le(a, b)
            sem_le = all(p(a) <= p(b) for p in points)
            if alg_le != sem_le:
                print(f"   ✗ {a} ≤ {b}: algebraic={alg_le}, semantic={sem_le}")
                all_ok = False
    if all_ok:
        print("   ✓ Order embedding verified for all pairs.")

    print("\n" + "=" * 60)
    print("All algorithms completed successfully.")
    print("=" * 60)

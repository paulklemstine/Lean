"""
Algorithms for Berggren Lattice-Reduction Duality

Implements the core algorithms from the research:
1. Berggren tree enumeration
2. Gram semimodule construction
3. Myhill-Nerode quotient (reduction)
4. Certified basis reconstruction
"""

import numpy as np
from typing import Tuple, List, Dict, Set, Optional, FrozenSet
from math import gcd
from dataclasses import dataclass, field
from collections import defaultdict

# ============================================================
# Core Data Structures
# ============================================================

@dataclass(frozen=True)
class PrimitivePythTriple:
    """A primitive Pythagorean triple (a, b, c) with a² + b² = c²."""
    a: int
    b: int
    c: int

    def __post_init__(self):
        assert self.a > 0 and self.b > 0 and self.c > 0
        assert self.a**2 + self.b**2 == self.c**2
        assert gcd(self.a, self.b) == 1
        assert self.a % 2 != self.b % 2

    @property
    def gram(self) -> 'Gram2':
        """Gram matrix from this triple."""
        return Gram2(self.a**2, self.a * self.b, self.b**2)


@dataclass(frozen=True)
class Gram2:
    """A 2×2 symmetric PSD integer matrix [[m00, m01], [m01, m11]]."""
    m00: int
    m01: int
    m11: int

    @property
    def trace(self) -> int:
        return self.m00 + self.m11

    @property
    def det(self) -> int:
        return self.m00 * self.m11 - self.m01**2

    @property
    def spectrum(self) -> Tuple[int, int]:
        """Length spectrum (trace, det)."""
        return (self.trace, self.det)

    def as_matrix(self) -> np.ndarray:
        return np.array([[self.m00, self.m01],
                         [self.m01, self.m11]], dtype=int)


# ============================================================
# Algorithm 1: Berggren Tree Enumeration
# ============================================================

# Berggren matrices
B_MATRICES = [
    np.array([[1, -2, 2], [2, -1, 2], [2, -2, 3]], dtype=int),  # B1
    np.array([[1, 2, 2], [2, 1, 2], [2, 2, 3]], dtype=int),    # B2
    np.array([[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]], dtype=int), # B3
]


def berggren_step(i: int, triple: PrimitivePythTriple) -> PrimitivePythTriple:
    """
    Apply the i-th Berggren matrix (i ∈ {0,1,2}) to a primitive triple.

    Time complexity: O(1)
    Space complexity: O(1)

    Args:
        i: Berggren matrix index (0, 1, or 2)
        triple: Input primitive Pythagorean triple

    Returns:
        New primitive Pythagorean triple
    """
    v = np.array([triple.a, triple.b, triple.c], dtype=int)
    result = B_MATRICES[i] @ v
    return PrimitivePythTriple(int(result[0]), int(result[1]), int(result[2]))


def enumerate_berggren_tree(max_hypotenuse: int = 1000) -> List[PrimitivePythTriple]:
    """
    Enumerate all primitive Pythagorean triples up to a given hypotenuse bound
    using breadth-first Berggren tree traversal.

    Time complexity: O(N) where N is the number of triples
    Space complexity: O(N)

    Args:
        max_hypotenuse: Maximum value of c

    Returns:
        List of all primitive Pythagorean triples with c ≤ max_hypotenuse
    """
    root = PrimitivePythTriple(3, 4, 5)
    result = [root]
    queue = [root]

    while queue:
        triple = queue.pop(0)
        for i in range(3):
            child = berggren_step(i, triple)
            if child.c <= max_hypotenuse:
                result.append(child)
                queue.append(child)

    return sorted(result, key=lambda t: (t.c, t.a))


# ============================================================
# Algorithm 2: Gram Semimodule Construction
# ============================================================

@dataclass
class TripleTreeGramSemimodule:
    """
    A finite triple-tree Gram semimodule.

    States are labeled by Gram matrices, with a Berggren action on states
    and a distinguished root state.
    """
    states: List[int]  # state indices
    act: Dict[Tuple[int, int], int]  # (berggren_idx, state) -> state
    gram_labels: Dict[int, Gram2]  # state -> Gram2
    root: int

    @property
    def size(self) -> int:
        return len(self.states)

    def follow_word(self, word: List[int], start: Optional[int] = None) -> int:
        """Follow a word from a state."""
        x = start if start is not None else self.root
        for i in word:
            x = self.act.get((i, x), x)
        return x

    def gram_behavior(self, state: int, max_depth: int = 4) -> Dict:
        """
        Compute the Gram behavior of a state up to given depth.

        This is the function w ↦ gramSpectrum(gram(followWord(w, state)))
        for all words w of length ≤ max_depth.

        Time complexity: O(3^max_depth)
        """
        behaviors = {}

        def dfs(current_state: int, word: Tuple[int, ...], depth: int):
            behaviors[word] = self.gram_labels[current_state].spectrum
            if depth < max_depth:
                for i in range(3):
                    next_state = self.act.get((i, current_state), current_state)
                    dfs(next_state, word + (i,), depth + 1)

        dfs(state, (), 0)
        return behaviors


def build_semimodule_from_triples(
    triples: List[PrimitivePythTriple],
    depth: int = 2
) -> TripleTreeGramSemimodule:
    """
    Build a Gram semimodule from a set of triples with Berggren dynamics.

    Time complexity: O(|triples| × 3^depth)
    Space complexity: O(|triples| × 3^depth)

    Args:
        triples: List of primitive Pythagorean triples to use as initial states
        depth: Depth of Berggren expansion

    Returns:
        A TripleTreeGramSemimodule
    """
    triple_to_idx = {}
    states = []
    act = {}
    gram_labels = {}

    def ensure_state(t: PrimitivePythTriple) -> int:
        key = (t.a, t.b, t.c)
        if key not in triple_to_idx:
            idx = len(states)
            triple_to_idx[key] = idx
            states.append(idx)
            gram_labels[idx] = t.gram
        return triple_to_idx[key]

    # Add initial triples
    for t in triples:
        ensure_state(t)

    # Expand by Berggren steps
    frontier = list(triples)
    for _ in range(depth):
        new_frontier = []
        for t in frontier:
            src = triple_to_idx[(t.a, t.b, t.c)]
            for i in range(3):
                child = berggren_step(i, t)
                dst = ensure_state(child)
                act[(i, src)] = dst
                new_frontier.append(child)
        frontier = new_frontier

    root = triple_to_idx[(triples[0].a, triples[0].b, triples[0].c)]
    return TripleTreeGramSemimodule(states, act, gram_labels, root)


# ============================================================
# Algorithm 3: Myhill-Nerode Quotient (Reduction)
# ============================================================

def compute_nerode_quotient(
    sm: TripleTreeGramSemimodule,
    max_depth: int = 5
) -> TripleTreeGramSemimodule:
    """
    Compute the Myhill-Nerode quotient of a Gram semimodule.

    Two states are identified if they have identical Gram behavior
    (same spectrum for all future words).

    This is the analogue of DFA minimization for Gram semimodules.

    Time complexity: O(|states|² × 3^max_depth)
    Space complexity: O(|states| × 3^max_depth)

    Args:
        sm: Input semimodule
        max_depth: Depth for behavior comparison

    Returns:
        Reduced semimodule (minimal representative)
    """
    # Compute behaviors for all states
    behaviors = {}
    for s in sm.states:
        beh = tuple(sorted(sm.gram_behavior(s, max_depth).items()))
        behaviors[s] = beh

    # Group states by behavior
    behavior_classes = defaultdict(list)
    for s, beh in behaviors.items():
        behavior_classes[beh].append(s)

    # Build quotient: one representative per class
    class_rep = {}  # old state -> representative
    representatives = []
    for beh, members in behavior_classes.items():
        rep = min(members)
        representatives.append(rep)
        for m in members:
            class_rep[m] = rep

    # Build new semimodule on representatives
    new_states = list(range(len(representatives)))
    rep_to_new = {r: i for i, r in enumerate(representatives)}

    new_act = {}
    new_gram = {}
    for i, rep in enumerate(representatives):
        new_gram[i] = sm.gram_labels[rep]
        for j in range(3):
            old_target = sm.act.get((j, rep), rep)
            new_target = rep_to_new[class_rep[old_target]]
            new_act[(j, i)] = new_target

    new_root = rep_to_new[class_rep[sm.root]]

    return TripleTreeGramSemimodule(new_states, new_act, new_gram, new_root)


def is_reduced(sm: TripleTreeGramSemimodule, max_depth: int = 5) -> bool:
    """
    Check if a semimodule is reduced (no two states have the same behavior).

    Time complexity: O(|states|² × 3^max_depth)
    """
    behaviors = set()
    for s in sm.states:
        beh = tuple(sorted(sm.gram_behavior(s, max_depth).items()))
        if beh in behaviors:
            return False
        behaviors.add(beh)
    return True


# ============================================================
# Algorithm 4: Certified Basis Reconstruction
# ============================================================

@dataclass
class CertifiedBasisWitness:
    """
    A certified basis witness for a lattice presentation.

    Contains basis vectors and a verified bound on their norms
    relative to the Gram matrix diagonal.
    """
    basis_vecs: List[Tuple[int, int]]
    gram_matrix: np.ndarray
    bound: int
    is_certified: bool

    def verify(self) -> bool:
        """Verify the certification conditions."""
        n = len(self.basis_vecs)
        if self.bound < 1:
            return False

        # Check Gram reproduction
        for i in range(n):
            for j in range(n):
                ip = (self.basis_vecs[i][0] * self.basis_vecs[j][0] +
                      self.basis_vecs[i][1] * self.basis_vecs[j][1])
                if ip != self.gram_matrix[i, j]:
                    return False

        # Check norm bounds
        for i in range(n):
            norm_sq = self.basis_vecs[i][0]**2 + self.basis_vecs[i][1]**2
            if norm_sq > self.bound * self.gram_matrix[i, i]:
                return False

        return True


def reconstruct_basis(
    gram: np.ndarray,
    basis_vecs: List[Tuple[int, int]]
) -> CertifiedBasisWitness:
    """
    Construct a certified basis witness from a Gram matrix and basis vectors.

    The bound factor is 1 (optimal) when the original basis vectors are used.

    Time complexity: O(n²)
    Space complexity: O(n²)

    Args:
        gram: The Gram matrix
        basis_vecs: The basis vectors

    Returns:
        A CertifiedBasisWitness with verified optimality bound
    """
    witness = CertifiedBasisWitness(
        basis_vecs=basis_vecs,
        gram_matrix=gram,
        bound=1,
        is_certified=True
    )

    # Verify
    assert witness.verify(), "Certification failed!"
    return witness


# ============================================================
# Algorithm 5: Gram Profile Classification
# ============================================================

def classify_gram_profile(triples: List[PrimitivePythTriple]) -> Dict[int, List[PrimitivePythTriple]]:
    """
    Classify triples by their Gram trace (= c²).

    Two triples with the same c² value produce Gram matrices with
    identical spectra (trace = c², det = 0), so they are equivalent
    in the Myhill-Nerode sense for semimodules with identity action.

    Time complexity: O(n log n)

    Args:
        triples: List of primitive Pythagorean triples

    Returns:
        Dictionary mapping c² values to lists of triples
    """
    classes = defaultdict(list)
    for t in triples:
        classes[t.c**2].append(t)
    return dict(classes)


# ============================================================
# Main: Run all algorithms
# ============================================================

if __name__ == "__main__":
    print("Berggren Lattice-Reduction Duality: Algorithms")
    print("=" * 60)

    # Algorithm 1: Enumerate triples
    print("\n--- Algorithm 1: Berggren Tree Enumeration ---")
    triples = enumerate_berggren_tree(100)
    print(f"Found {len(triples)} primitive Pythagorean triples with c ≤ 100:")
    for t in triples[:10]:
        print(f"  ({t.a}, {t.b}, {t.c})")
    if len(triples) > 10:
        print(f"  ... and {len(triples) - 10} more")

    # Algorithm 2: Build semimodule
    print("\n--- Algorithm 2: Semimodule Construction ---")
    root_triple = PrimitivePythTriple(3, 4, 5)
    sm = build_semimodule_from_triples([root_triple], depth=2)
    print(f"Semimodule: {sm.size} states")

    # Algorithm 3: Reduction
    print("\n--- Algorithm 3: Myhill-Nerode Quotient ---")
    print(f"  Before: {sm.size} states, reduced: {is_reduced(sm)}")
    sm_red = compute_nerode_quotient(sm)
    print(f"  After:  {sm_red.size} states, reduced: {is_reduced(sm_red)}")

    # Algorithm 4: Reconstruction
    print("\n--- Algorithm 4: Certified Reconstruction ---")
    basis = [(3, 4), (5, 12), (8, 15)]
    n = len(basis)
    gram = np.zeros((n, n), dtype=int)
    for i in range(n):
        for j in range(n):
            gram[i, j] = basis[i][0]*basis[j][0] + basis[i][1]*basis[j][1]

    witness = reconstruct_basis(gram, basis)
    print(f"  Basis: {witness.basis_vecs}")
    print(f"  Bound: {witness.bound}")
    print(f"  Verified: {witness.verify()}")

    # Algorithm 5: Classification
    print("\n--- Algorithm 5: Gram Profile Classification ---")
    classes = classify_gram_profile(triples)
    print(f"  {len(classes)} distinct Gram trace classes from {len(triples)} triples")
    for c_sq, members in sorted(classes.items())[:5]:
        member_str = ", ".join(f"({t.a},{t.b},{t.c})" for t in members)
        print(f"  c² = {c_sq}: {member_str}")

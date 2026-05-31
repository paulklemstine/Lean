"""
Algorithms for Semantic Structures and Group Analogies.

Implements the core mathematical constructions from the
Isomorphisms of Meaning framework.
"""

from typing import TypeVar, Callable, Optional, List, Tuple, Dict, Set
from itertools import permutations
from collections import Counter
from math import factorial

T = TypeVar('T')
L = TypeVar('L')


# ─── Semantic Structures ───

class SemanticStructure:
    """A semantic structure: a finite set {0, ..., n-1} with a labeling function."""

    def __init__(self, labels: List) -> None:
        self.n = len(labels)
        self.labels = list(labels)

    def label(self, i: int) -> object:
        return self.labels[i]

    def semantic_entropy(self) -> int:
        """Number of distinct labels used."""
        return len(set(self.labels))

    def is_semantically_equivalent(self, other: 'SemanticStructure') -> bool:
        """Check if self and other are semantically equivalent.

        Two structures are semantically equivalent if there exists a permutation
        σ such that other.label(σ(i)) = self.label(i) for all i.
        """
        if self.n != other.n:
            return False
        for perm in permutations(range(self.n)):
            if all(other.labels[perm[i]] == self.labels[i] for i in range(self.n)):
                return True
        return False

    def semantic_automorphisms(self) -> List[Tuple[int, ...]]:
        """Return all label-preserving permutations."""
        auts: List[Tuple[int, ...]] = []
        for perm in permutations(range(self.n)):
            if all(self.labels[perm[i]] == self.labels[i] for i in range(self.n)):
                auts.append(perm)
        return auts

    def __repr__(self) -> str:
        return f"SemanticStructure({self.labels})"


def identity_label(n: int) -> SemanticStructure:
    """The identity labeling: element i gets label i."""
    return SemanticStructure(list(range(n)))


def const_label(n: int, label: object) -> SemanticStructure:
    """The constant labeling: every element gets the same label."""
    return SemanticStructure([label] * n)


# ─── Group Analogies ───

class GroupAnalogy:
    """Implements group analogy a:b :: c:d in an additive group (integers mod n)."""

    @staticmethod
    def holds(a: int, b: int, c: int, d: int, n: int) -> bool:
        """Check if a:b :: c:d holds in Z/nZ.

        In additive notation: b - a ≡ d - c (mod n).
        """
        return (b - a) % n == (d - c) % n

    @staticmethod
    def complete(a: int, b: int, c: int, n: int) -> int:
        """Complete the analogy a:b :: c:? in Z/nZ.

        Returns d = c + (b - a) mod n.
        """
        return (c + b - a) % n

    @staticmethod
    def count_valid_quadruples(n: int) -> int:
        """Count valid analogy quadruples in Z/nZ."""
        count = 0
        for a in range(n):
            for b in range(n):
                for c in range(n):
                    for d in range(n):
                        if GroupAnalogy.holds(a, b, c, d, n):
                            count += 1
        return count


# ─── 2-Isomorphisms ───

def are_2_isomorphic(
    f: Tuple[int, ...], g: Tuple[int, ...], n: int, m: int
) -> bool:
    """Check if two bijections f, g : Fin n → Fin m are 2-isomorphic.

    f and g are represented as tuples of length n with values in {0, ..., m-1}.
    Two bijections are 2-isomorphic if there exist automorphisms s of Fin n and
    t of Fin m such that t(f(x)) = g(s(x)) for all x.
    """
    for s in permutations(range(n)):
        for t in permutations(range(m)):
            if all(t[f[x]] == g[s[x]] for x in range(n)):
                return True
    return False


def count_2_iso_classes(n: int) -> int:
    """Count the number of 2-isomorphism equivalence classes of bijections Fin n → Fin n."""
    all_perms = list(permutations(range(n)))
    visited: Set[int] = set()
    classes = 0
    for i, f in enumerate(all_perms):
        if i in visited:
            continue
        classes += 1
        for j, g in enumerate(all_perms):
            if j not in visited and are_2_isomorphic(f, g, n, n):
                visited.add(j)
    return classes


# ─── Entropy-Rigidity Analysis ───

def entropy_rigidity_analysis(n: int, k: int) -> Dict:
    """Analyze the entropy-rigidity duality for structures on Fin n with k labels.

    Returns statistics about the relationship between semantic entropy and
    automorphism group size across all possible labelings.
    """
    from itertools import product as cart_product

    results: Dict[int, List[int]] = {}  # entropy -> list of aut group sizes

    for labels in cart_product(range(k), repeat=n):
        s = SemanticStructure(list(labels))
        ent = s.semantic_entropy()
        aut_count = len(s.semantic_automorphisms())
        if ent not in results:
            results[ent] = []
        results[ent].append(aut_count)

    analysis: Dict = {}
    for ent in sorted(results):
        sizes = results[ent]
        analysis[ent] = {
            'count': len(sizes),
            'min_aut': min(sizes),
            'max_aut': max(sizes),
            'avg_aut': sum(sizes) / len(sizes),
        }

    return analysis


# ─── Semantic Equivalence Classes ───

def count_semantic_classes(n: int, k: int) -> int:
    """Count distinct semantic equivalence classes on Fin n with labels in Fin k.

    This is equivalent to the number of multisets of size n from k elements,
    which is C(n+k-1, k-1).
    """
    from math import comb
    return comb(n + k - 1, k - 1)


def orbit_size(label_counts: Tuple[int, ...]) -> int:
    """Compute the orbit size of a labeling with given color class sizes.

    By the orbit-stabilizer theorem: |orbit| = n! / ∏(nᵢ!)
    where n = ∑ nᵢ.
    """
    n = sum(label_counts)
    denom = 1
    for c in label_counts:
        denom *= factorial(c)
    return factorial(n) // denom

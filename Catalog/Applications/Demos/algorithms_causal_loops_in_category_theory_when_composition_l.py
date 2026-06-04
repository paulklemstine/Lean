"""
Algorithms for Almost-Monoids and Controlled Associativity Failure.

This module implements the core algorithms from the research:
1. Almost-monoid construction and verification
2. Pentagon coherence checking
3. Binary tree reassociation path finding
4. Catalan number computation
5. Associator defect analysis
"""

from typing import Callable, Dict, List, Optional, Tuple, Set
from dataclasses import dataclass
from itertools import product as cartesian_product
from functools import lru_cache


# --- Binary Trees (Parenthesizations) ---

@dataclass(frozen=True)
class BinTree:
    """A binary tree representing a parenthesization."""
    left: Optional['BinTree'] = None
    right: Optional['BinTree'] = None

    @property
    def is_leaf(self) -> bool:
        return self.left is None and self.right is None

    @property
    def leaf_count(self) -> int:
        if self.is_leaf:
            return 1
        return self.left.leaf_count + self.right.leaf_count

    def __repr__(self) -> str:
        if self.is_leaf:
            return "·"
        return f"({self.left} ∘ {self.right})"


LEAF = BinTree()


def left_assoc(n: int) -> BinTree:
    """Construct the left-associated tree with n leaves."""
    if n <= 1:
        return LEAF
    result = LEAF
    for _ in range(n - 1):
        result = BinTree(result, LEAF)
    return result


def right_assoc(n: int) -> BinTree:
    """Construct the right-associated tree with n leaves."""
    if n <= 1:
        return LEAF
    result = LEAF
    for _ in range(n - 1):
        result = BinTree(LEAF, result)
    return result


def all_trees(n: int) -> List[BinTree]:
    """Generate all binary trees with n leaves (Catalan number many)."""
    if n <= 0:
        return []
    if n == 1:
        return [LEAF]
    result: List[BinTree] = []
    for k in range(1, n):
        for left in all_trees(k):
            for right in all_trees(n - k):
                result.append(BinTree(left, right))
    return result


@lru_cache(maxsize=100)
def catalan(n: int) -> int:
    """Compute the n-th Catalan number C(n)."""
    if n <= 1:
        return 1
    return sum(catalan(k) * catalan(n - 1 - k) for k in range(n))


# --- Almost-Monoid ---

@dataclass
class AlmostMonoid:
    """An almost-monoid on a finite set {0, 1, ..., n-1}.

    Attributes:
        n: Size of the underlying set.
        mul: Binary operation (i, j) -> k.
        one: Identity element.
        associator: Map (a, b, c) -> permutation of {0..n-1}.
    """
    n: int
    mul: Callable[[int, int], int]
    one: int
    associator: Callable[[int, int, int, int], int]

    def verify_identity(self) -> bool:
        """Check left and right identity axioms."""
        for a in range(self.n):
            if self.mul(self.one, a) != a:
                return False
            if self.mul(a, self.one) != a:
                return False
        return True

    def verify_controlled_assoc(self) -> bool:
        """Check controlled associativity: (a*b)*c = α(a,b,c)(a*(b*c))."""
        for a in range(self.n):
            for b in range(self.n):
                for c in range(self.n):
                    lhs = self.mul(self.mul(a, b), c)
                    rhs = self.associator(a, b, c, self.mul(a, self.mul(b, c)))
                    if lhs != rhs:
                        return False
        return True

    def verify_bijective(self) -> bool:
        """Check that associator(a,b,c) is a bijection for each triple."""
        for a in range(self.n):
            for b in range(self.n):
                for c in range(self.n):
                    image = set()
                    for x in range(self.n):
                        image.add(self.associator(a, b, c, x))
                    if len(image) != self.n:
                        return False
        return True

    def is_strict(self) -> bool:
        """Check if all associators are the identity."""
        for a in range(self.n):
            for b in range(self.n):
                for c in range(self.n):
                    for x in range(self.n):
                        if self.associator(a, b, c, x) != x:
                            return False
        return True

    def defect(self, a: int, b: int, c: int) -> int:
        """Compute the associator defect for triple (a, b, c)."""
        x = self.mul(a, self.mul(b, c))
        return 0 if self.associator(a, b, c, x) == x else 1

    def total_defect(self) -> int:
        """Sum of defects over all triples."""
        return sum(
            self.defect(a, b, c)
            for a in range(self.n)
            for b in range(self.n)
            for c in range(self.n)
        )


def check_pentagon_coherence(am: AlmostMonoid) -> bool:
    """Verify pentagon coherence: α(a,b,cd)(α(ab,c,d)(x)) = α(a,bc,d)(α(a,b,c)(x))
    for all a, b, c, d, x."""
    n = am.n
    for a in range(n):
        for b in range(n):
            for c in range(n):
                for d in range(n):
                    cd = am.mul(c, d)
                    ab = am.mul(a, b)
                    bc = am.mul(b, c)
                    for x in range(n):
                        lhs = am.associator(a, b, cd,
                                            am.associator(ab, c, d, x))
                        rhs = am.associator(a, bc, d,
                                            am.associator(a, b, c, x))
                        if lhs != rhs:
                            return False
    return True


def make_strict_monoid(n: int, mul: Callable[[int, int], int], one: int) -> AlmostMonoid:
    """Create a strict almost-monoid from a genuine monoid operation."""
    return AlmostMonoid(
        n=n,
        mul=mul,
        one=one,
        associator=lambda a, b, c, x: x  # identity
    )


# --- Reassociation Path Finding ---

def find_rotations_to_left(tree: BinTree) -> List[Tuple[BinTree, BinTree]]:
    """Find a sequence of left rotations transforming tree to left-associated form.
    Returns list of (before, after) pairs."""
    steps: List[Tuple[BinTree, BinTree]] = []
    current = tree

    def needs_rotation(t: BinTree) -> bool:
        if t.is_leaf:
            return False
        if not t.right.is_leaf:
            return True
        return needs_rotation(t.left)

    while needs_rotation(current):
        # Find rightmost non-leaf right child and rotate
        if not current.is_leaf and not current.right.is_leaf:
            # Rotate: node(a, node(b, c)) -> node(node(a, b), c)
            a, bc = current.left, current.right
            b, c = bc.left, bc.right
            new = BinTree(BinTree(a, b), c)
            steps.append((current, new))
            current = new
        elif not current.is_leaf:
            # Recurse into left subtree
            left_steps = find_rotations_to_left(current.left)
            for before, after in left_steps:
                old = BinTree(before, current.right)
                new = BinTree(after, current.right)
                steps.append((old, new))
            current = BinTree(left_steps[-1][1] if left_steps else current.left,
                              current.right)

    return steps


def reassociation_path(t1: BinTree, t2: BinTree) -> List[Tuple[BinTree, str, BinTree]]:
    """Find a path of reassociation steps from t1 to t2.
    Returns list of (from, direction, to) triples."""
    # Simple approach: both to left-associated, then reverse second path
    path1 = find_rotations_to_left(t1)
    path2 = find_rotations_to_left(t2)

    forward = [(b, "→", a) for b, a in path1]
    backward = [(a, "←", b) for b, a in reversed(path2)]

    return forward + backward


# --- Enumeration ---

def enumerate_almost_monoids_on_bool() -> List[AlmostMonoid]:
    """Enumerate all almost-monoids on {0, 1} (Bool)."""
    results: List[AlmostMonoid] = []

    # There are 2^4 = 16 possible binary operations on {0,1}
    for op_bits in range(16):
        mul = lambda a, b, bits=op_bits: (bits >> (a * 2 + b)) & 1

        for one in range(2):
            # Check identity axioms
            ok = True
            for a in range(2):
                if mul(one, a) != a or mul(a, one) != a:
                    ok = False
                    break
            if not ok:
                continue

            # For each triple (a,b,c), determine what the associator must do
            # (a*b)*c = α(a,b,c)(a*(b*c))
            # So α(a,b,c) must map a*(b*c) ↦ (a*b)*c
            # And α can be any bijection extending this constraint

            # For {0,1}, a bijection is either id or swap
            # α(a,b,c) must map x₀ = a*(b*c) to y₀ = (a*b)*c
            # If x₀ = y₀, α can be id or swap
            # If x₀ ≠ y₀, α must be swap

            for assoc_bits in range(256):  # 2^8 choices for 8 triples
                def make_assoc(bits: int):
                    def assoc(a: int, b: int, c: int, x: int) -> int:
                        triple_idx = a * 4 + b * 2 + c
                        use_swap = (bits >> triple_idx) & 1
                        if use_swap:
                            return 1 - x
                        return x
                    return assoc

                am = AlmostMonoid(2, mul, one, make_assoc(assoc_bits))
                if am.verify_controlled_assoc() and am.verify_bijective():
                    results.append(am)

    return results


# --- Main verification ---

def verify_all_theorems() -> Dict[str, bool]:
    """Verify key theorems computationally on small examples."""
    results: Dict[str, bool] = {}

    # Theorem 1: Z/2Z under addition is a strict almost-monoid
    z2_mul = lambda a, b: (a + b) % 2
    z2 = make_strict_monoid(2, z2_mul, 0)
    results["Z2_is_strict_almost_monoid"] = (
        z2.verify_identity() and
        z2.verify_controlled_assoc() and
        z2.verify_bijective() and
        z2.is_strict()
    )

    # Theorem 2: Strict implies pentagon
    results["strict_implies_pentagon"] = check_pentagon_coherence(z2)

    # Tree leaf count preservation
    for n in range(1, 6):
        la = left_assoc(n)
        ra = right_assoc(n)
        results[f"left_assoc_{n}_count"] = (la.leaf_count == n)
        results[f"right_assoc_{n}_count"] = (ra.leaf_count == n)

    # Catalan numbers
    expected_catalan = [1, 1, 2, 5, 14, 42, 132]
    for i, expected in enumerate(expected_catalan):
        results[f"catalan_{i}"] = (catalan(i) == expected)

    # Number of trees
    for n in range(1, 7):
        trees = all_trees(n)
        results[f"tree_count_{n}"] = (len(trees) == catalan(n - 1))

    return results


if __name__ == "__main__":
    results = verify_all_theorems()
    print("=== Computational Verification ===")
    for name, passed in results.items():
        status = "✓" if passed else "✗"
        print(f"  {status} {name}")

    all_passed = all(results.values())
    print(f"\n{'All tests passed!' if all_passed else 'Some tests FAILED!'}")

"""
Oracle Closure Algebras: Core Algorithms

Type-hinted implementations of the oracle hierarchy framework,
including the closure operator, resolvability preorder, and
incompleteness kernel computation.
"""

from typing import Callable, Set, List, Tuple, Optional
from dataclasses import dataclass


@dataclass
class OracleHierarchy:
    """
    Concrete oracle hierarchy where:
    - Sentences are natural numbers
    - Con(k) = 2k + 1 (odd numbers)
    - Provable(n, s) iff s = 2k+1 for some k < n
    - True_(s) iff s is odd
    - bot = 0
    """

    def con_sentence(self, k: int) -> int:
        """Consistency sentence for level k."""
        return 2 * k + 1

    def is_true(self, s: int) -> bool:
        """Truth predicate: odd numbers are true."""
        return s % 2 == 1

    def is_provable(self, n: int, s: int) -> bool:
        """Provability at level n: s = 2k+1 for some k < n."""
        if s % 2 == 0:
            return False
        k = (s - 1) // 2
        return k < n

    def provable_set(self, n: int, max_sentence: int = 100) -> Set[int]:
        """Compute provable set at level n (bounded)."""
        return {s for s in range(max_sentence) if self.is_provable(n, s)}

    def oracle_closure(self, n: int, k: int, max_sentence: int = 100) -> Set[int]:
        """Oracle closure at depth k from level n."""
        return self.provable_set(n + k, max_sentence)

    def incompleteness_kernel(self, n: int, max_sentence: int = 100) -> Set[int]:
        """Incompleteness kernel at level n: true but not provable."""
        return {s for s in range(max_sentence)
                if self.is_true(s) and not self.is_provable(n, s)}

    def diagonal_resistance(self, s: int) -> Optional[int]:
        """
        Minimum level at which s becomes provable.
        Returns None if s is never provable (not odd).
        """
        if not self.is_true(s):
            return None
        k = (s - 1) // 2
        return k + 1

    def resolvability_le(self, phi: int, psi: int, max_level: int = 100) -> bool:
        """
        Check if phi <=_r psi (phi is resolvability-dominated by psi)
        up to a finite number of levels.
        """
        for n in range(max_level):
            if self.is_provable(n, psi) and not self.is_provable(n, phi):
                return False
        return True

    def is_antichain(self, sentences: List[int], max_level: int = 100) -> bool:
        """Check if a list of sentences forms an antichain in resolvability order."""
        for i, s1 in enumerate(sentences):
            for j, s2 in enumerate(sentences):
                if i != j:
                    if (self.resolvability_le(s1, s2, max_level) and
                            self.resolvability_le(s2, s1, max_level)):
                        return False
        return True


def compute_kernel_descent(H: OracleHierarchy, max_level: int = 10,
                           max_sentence: int = 50) -> List[Tuple[int, int]]:
    """
    Compute the sizes of incompleteness kernels at each level.
    Returns list of (level, kernel_size) pairs showing strict descent.
    """
    result = []
    for n in range(max_level):
        kernel = H.incompleteness_kernel(n, max_sentence)
        result.append((n, len(kernel)))
    return result


def verify_non_idempotence(H: OracleHierarchy, n: int,
                           max_sentence: int = 100) -> Tuple[bool, Set[int]]:
    """
    Verify that Cl(n,1) != Cl(n,2) by finding the difference.
    Returns (is_different, difference_set).
    """
    cl1 = H.oracle_closure(n, 1, max_sentence)
    cl2 = H.oracle_closure(n, 2, max_sentence)
    diff = cl2 - cl1
    return (len(diff) > 0, diff)


def verify_antichain_theorem(H: OracleHierarchy, max_k: int = 10) -> bool:
    """
    Verify that Con(0), Con(1), ..., Con(max_k-1) form an antichain.
    """
    con_sentences = [H.con_sentence(k) for k in range(max_k)]
    return H.is_antichain(con_sentences, max_level=max_k + 5)


def compute_closure_chain(H: OracleHierarchy, n: int = 0,
                          max_depth: int = 10,
                          max_sentence: int = 50) -> List[Tuple[int, int]]:
    """
    Compute the strictly increasing chain of oracle closure sets.
    Returns (depth, set_size) pairs.
    """
    result = []
    for k in range(max_depth):
        cl = H.oracle_closure(n, k, max_sentence)
        result.append((k, len(cl)))
    return result


if __name__ == "__main__":
    H = OracleHierarchy()

    print("=== Oracle Closure Algebra: Algorithm Verification ===\n")

    # Verify non-idempotence
    for n in range(5):
        is_diff, diff = verify_non_idempotence(H, n)
        print(f"Cl({n},1) ≠ Cl({n},2): {is_diff}, difference: {diff}")

    print()

    # Verify antichain
    is_ac = verify_antichain_theorem(H, max_k=8)
    print(f"Diagonal antichain (k=0..7): {is_ac}")

    print()

    # Kernel descent
    descent = compute_kernel_descent(H, max_level=8, max_sentence=30)
    for level, size in descent:
        print(f"  |K({level})| = {size}")

    print()

    # Closure chain
    chain = compute_closure_chain(H, n=0, max_depth=8, max_sentence=30)
    for depth, size in chain:
        print(f"  |Cl(0,{depth})| = {size}")

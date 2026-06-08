"""
Algorithms for Holographic Polymatroids

Type-hinted implementations of the key algorithms from the research.
"""

from typing import FrozenSet, Callable, List, Tuple, Set, Optional
from itertools import combinations
from dataclasses import dataclass


# Type aliases
Element = int
Subset = FrozenSet[Element]
RankFunction = Callable[[Subset], int]


def powerset(ground: Set[Element]) -> List[Subset]:
    """Generate all subsets of a ground set."""
    elems = sorted(ground)
    result: List[Subset] = []
    for r in range(len(elems) + 1):
        for combo in combinations(elems, r):
            result.append(frozenset(combo))
    return result


@dataclass
class PolymatroidVerification:
    """Result of verifying the polymatroid axioms."""
    is_valid: bool
    violations: List[str]


def verify_polymatroid(n: int, rho: RankFunction) -> PolymatroidVerification:
    """
    Verify that a rank function satisfies the polymatroid axioms.
    
    Algorithm:
    1. Check normalization: rho(∅) = 0
    2. Check non-negativity: rho(S) ≥ 0 for all S
    3. Check monotonicity: S ⊆ T ⟹ rho(S) ≤ rho(T)
    4. Check submodularity: rho(S) + rho(T) ≥ rho(S∩T) + rho(S∪T)
    
    Complexity: O(4^n) — checks all pairs of subsets.
    
    Args:
        n: Size of the ground set {0, ..., n-1}
        rho: The rank function to verify
    
    Returns:
        PolymatroidVerification with validity and any violations
    """
    ground = set(range(n))
    subsets = powerset(ground)
    violations: List[str] = []
    
    # P1: Normalization
    if rho(frozenset()) != 0:
        violations.append(f"P1: rho(∅) = {rho(frozenset())} ≠ 0")
    
    # P2: Non-negativity
    for S in subsets:
        if rho(S) < 0:
            violations.append(f"P2: rho({set(S)}) = {rho(S)} < 0")
    
    # P3: Monotonicity
    for S in subsets:
        for T in subsets:
            if S <= T and rho(S) > rho(T):
                violations.append(
                    f"P3: rho({set(S)}) = {rho(S)} > rho({set(T)}) = {rho(T)}")
    
    # P4: Submodularity
    for S in subsets:
        for T in subsets:
            lhs = rho(S) + rho(T)
            rhs = rho(S & T) + rho(S | T)
            if lhs < rhs:
                violations.append(
                    f"P4: rho({set(S)}) + rho({set(T)}) = {lhs} "
                    f"< rho(∩) + rho(∪) = {rhs}")
    
    return PolymatroidVerification(
        is_valid=len(violations) == 0,
        violations=violations
    )


def compute_entropy_vector(n: int, rho: RankFunction) -> dict:
    """
    Compute the full entropy vector of a polymatroid.
    
    Returns a dictionary mapping each subset to its rank value.
    """
    ground = set(range(n))
    return {S: rho(S) for S in powerset(ground)}


def mutual_information(rho: RankFunction, A: Subset, B: Subset) -> int:
    """Compute I(A:B) = rho(A) + rho(B) - rho(A|B)."""
    return rho(A) + rho(B) - rho(A | B)


def conditional_mutual_information(
    rho: RankFunction, A: Subset, B: Subset, C: Subset
) -> int:
    """Compute I(A:C|B) = rho(AB) + rho(BC) - rho(B) - rho(ABC)."""
    return (rho(A | B) + rho(B | C) - rho(B) - rho(A | B | C))


def syndrome_defect(rho: RankFunction, X: Subset, Y: Subset) -> int:
    """Compute δ(X,Y) = rho(X) + rho(Y) - rho(X∩Y) - rho(X∪Y)."""
    return rho(X) + rho(Y) - rho(X & Y) - rho(X | Y)


def check_mmi(n: int, rho: RankFunction) -> Tuple[bool, Optional[Tuple]]:
    """
    Check Monogamy of Mutual Information (MMI).
    
    MMI: For all pairwise disjoint A, B, C:
      rho(AB) + rho(AC) + rho(BC) ≥ rho(A) + rho(B) + rho(C) + rho(ABC)
    
    Returns (True, None) if MMI holds, or (False, (A, B, C)) with a violation.
    """
    ground = list(range(n))
    for size_a in range(1, n):
        for A_tuple in combinations(ground, size_a):
            A = frozenset(A_tuple)
            remaining = [x for x in ground if x not in A]
            for size_b in range(1, len(remaining)):
                for B_tuple in combinations(remaining, size_b):
                    B = frozenset(B_tuple)
                    C = frozenset(x for x in remaining if x not in B)
                    if len(C) == 0:
                        continue
                    lhs = rho(A | B) + rho(A | C) + rho(B | C)
                    rhs = rho(A) + rho(B) + rho(C) + rho(A | B | C)
                    if lhs < rhs:
                        return False, (set(A), set(B), set(C))
    return True, None


@dataclass
class SingletonCheck:
    """Result of checking the Singleton bound."""
    n: int
    k: int
    d: int
    satisfies_singleton: bool
    is_mds: bool
    redundancy: int
    min_redundancy: int
    excess: int


def check_singleton_bound(n: int, k: int, d: int) -> SingletonCheck:
    """
    Check if code parameters [[n, k, d]] satisfy the quantum Singleton bound.
    
    The bound states: 2d + k ≤ n + 2.
    The code is MDS if equality holds: 2d + k = n + 2.
    """
    satisfies = 2 * d + k <= n + 2
    is_mds = 2 * d + k == n + 2
    redundancy = n - k
    min_redundancy = 2 * (d - 1)
    excess = redundancy - min_redundancy
    
    return SingletonCheck(
        n=n, k=k, d=d,
        satisfies_singleton=satisfies,
        is_mds=is_mds,
        redundancy=redundancy,
        min_redundancy=min_redundancy,
        excess=excess
    )


def toric_code_params(L: int) -> Tuple[int, int, int]:
    """Compute toric code parameters [[2L², 2, L]]."""
    return 2 * L**2, 2, L


def holographic_dictionary(area_planck: int) -> Tuple[int, int, int]:
    """
    Apply the holographic dictionary.
    
    Maps boundary area (in Planck units) to code parameters:
    - n = area_planck
    - k = area_planck / 4 (BH entropy)
    - d = area_planck / 4 + 1 (code distance)
    """
    assert area_planck % 4 == 0, "Area must be divisible by 4"
    n = area_planck
    k = area_planck // 4
    d = area_planck // 4 + 1
    return n, k, d


if __name__ == "__main__":
    # Verify trivial polymatroid
    rho = lambda S: len(S)
    result = verify_polymatroid(4, rho)
    print(f"Trivial polymatroid valid: {result.is_valid}")
    
    # Check MMI for trivial polymatroid
    mmi_ok, violation = check_mmi(4, rho)
    print(f"Trivial polymatroid satisfies MMI: {mmi_ok}")
    
    # Check min-rank polymatroid
    rho2 = lambda S: min(len(S), 2)
    result2 = verify_polymatroid(3, rho2)
    print(f"Min-rank polymatroid valid: {result2.is_valid}")
    
    # Singleton bounds
    for name, n, k, d in [("Perfect", 5, 1, 3), ("Steane", 7, 1, 3)]:
        sc = check_singleton_bound(n, k, d)
        print(f"{name} [[{n},{k},{d}]]: Singleton={sc.satisfies_singleton}, "
              f"MDS={sc.is_mds}, excess={sc.excess}")
    
    # Toric code family
    for L in range(2, 8):
        n, k, d = toric_code_params(L)
        sc = check_singleton_bound(n, k, d)
        print(f"Toric L={L}: [[{n},{k},{d}]], "
              f"Singleton={sc.satisfies_singleton}, "
              f"d²≤n: {d**2 <= n}")

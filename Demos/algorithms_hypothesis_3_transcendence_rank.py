#!/usr/bin/env python3
"""
Algorithms for Structural Transcendence Rank

Implements the verified algorithms from the research paper:
- Exhaustive rank search (exact, exponential)
- Greedy rank lower bound (approximate, polynomial)
- Tropical matrix complexity computation
- Architecture expression analysis

All algorithms correspond to formally verified counterparts in Lean 4.
"""

from itertools import combinations
from typing import Callable, FrozenSet, Set, List, Tuple, Optional, Dict
import time


# ============================================================================
# Core Types
# ============================================================================

ClosureOp = Callable[[FrozenSet], FrozenSet]


# ============================================================================
# Algorithm 1: Exhaustive Rank Search (Verified)
# ============================================================================

def search_transcendence_rank(
    cl: ClosureOp,
    A: FrozenSet,
) -> Tuple[int, FrozenSet]:
    """
    Exhaustive search for the maximum cardinality independent subset.

    Corresponds to `searchTranscendenceRank` in Lean, which is proved
    equal to `finTranscendenceRank` (soundness + completeness).

    Args:
        cl: Closure operator mapping finite sets to their closure
        A: Ambient finite set

    Returns:
        Tuple of (rank, witness): the maximum independent set size
        and a witness achieving it.

    Time complexity: O(2^|A| · |A| · T_cl)
    Space complexity: O(|A|)
    """
    best_rank = 0
    best_witness: FrozenSet = frozenset()

    for k in range(len(A), -1, -1):
        if k <= best_rank:
            break  # Can't improve
        for subset_tuple in combinations(A, k):
            S = frozenset(subset_tuple)
            if _is_independent(cl, S):
                if k > best_rank:
                    best_rank = k
                    best_witness = S
                break  # Found one of this size, try smaller

    return best_rank, best_witness


def _is_independent(cl: ClosureOp, S: FrozenSet) -> bool:
    """Check independence: no element is in the closure of the rest."""
    for s in S:
        rest = S - {s}
        if s in cl(rest):
            return False
    return True


# ============================================================================
# Algorithm 2: Greedy Rank Lower Bound (Polynomial)
# ============================================================================

def greedy_rank_lower_bound(
    cl: ClosureOp,
    A: FrozenSet,
) -> Tuple[int, FrozenSet]:
    """
    Greedy algorithm for finding a large independent subset.

    Not verified in Lean, but provides a polynomial-time lower bound.
    By the monotonicity theorem, any independent set gives a valid
    lower bound on the transcendence rank.

    Args:
        cl: Closure operator
        A: Ambient finite set

    Returns:
        Tuple of (lower_bound, witness)

    Time complexity: O(|A|^2 · T_cl)
    """
    independent: Set = set()

    for a in sorted(A):
        candidate = frozenset(independent | {a})
        if _is_independent(cl, candidate):
            independent.add(a)

    witness = frozenset(independent)
    return len(witness), witness


# ============================================================================
# Algorithm 3: Tropical Matrix Complexity
# ============================================================================

def trop_mul(A: List[List[int]], B: List[List[int]]) -> List[List[int]]:
    """
    Tropical matrix multiplication: (A ⊗ B)ᵢⱼ = maxₖ(Aᵢₖ + Bₖⱼ).

    Corresponds to `tropMul` in Lean.

    Time complexity: O(n³)
    """
    n = len(A)
    assert all(len(row) == n for row in A), "A must be square"
    assert len(B) == n and all(len(row) == n for row in B), "B must be square"

    return [
        [max(A[i][k] + B[k][j] for k in range(n)) for j in range(n)]
        for i in range(n)
    ]


def trop_complexity(A: List[List[int]]) -> int:
    """
    Tropical complexity: number of distinct entry values.

    Corresponds to `tropComplexity` in Lean.

    Time complexity: O(n²)
    """
    values = set()
    for row in A:
        for val in row:
            values.add(val)
    return len(values)


def trop_power(A: List[List[int]], k: int) -> List[List[int]]:
    """Compute A^⊗k (k-fold tropical product)."""
    n = len(A)
    # Identity for tropical multiplication: -∞ off-diagonal, 0 on diagonal
    # For integer approximation, use a large negative number
    NEG_INF = -10**9
    result = [[NEG_INF if i != j else 0 for j in range(n)] for i in range(n)]
    base = [row[:] for row in A]

    while k > 0:
        if k % 2 == 1:
            result = trop_mul(result, base)
        base = trop_mul(base, base)
        k //= 2

    return result


# ============================================================================
# Algorithm 4: Perturbation Analysis
# ============================================================================

def perturb_closure(
    cl: ClosureOp,
    P: FrozenSet,
) -> ClosureOp:
    """
    Perturb a closure operator by adding P to every closure.

    Corresponds to `perturbClosure` in Lean.
    """
    def cl_perturbed(S: FrozenSet) -> FrozenSet:
        return cl(S) | P
    return cl_perturbed


def rank_stability_analysis(
    cl: ClosureOp,
    A: FrozenSet,
    max_perturbation_size: int = 3,
) -> Dict:
    """
    Analyze how transcendence rank changes under perturbations.

    For each perturbation size 0, 1, ..., max_perturbation_size,
    compute the minimum rank over all perturbations of that size.

    Returns a dictionary with analysis results.
    """
    base_rank, base_witness = search_transcendence_rank(cl, A)

    results = {
        "base_rank": base_rank,
        "base_witness": sorted(base_witness),
        "perturbation_analysis": [],
    }

    for p_size in range(max_perturbation_size + 1):
        min_rank = base_rank
        worst_P = frozenset()

        for P_tuple in combinations(A, p_size):
            P = frozenset(P_tuple)
            cl_p = perturb_closure(cl, P)
            rank_p, _ = search_transcendence_rank(cl_p, A)
            if rank_p < min_rank:
                min_rank = rank_p
                worst_P = P

        # Verify stability theorem
        assert base_rank <= min_rank + p_size, \
            f"Stability theorem violated: {base_rank} > {min_rank} + {p_size}"

        results["perturbation_analysis"].append({
            "perturbation_size": p_size,
            "min_rank": min_rank,
            "worst_perturbation": sorted(worst_P),
            "stability_bound": min_rank + p_size,
            "stability_holds": base_rank <= min_rank + p_size,
        })

    return results


# ============================================================================
# Algorithm 5: Architecture Expression Analysis
# ============================================================================

class ArchExpr:
    """Architecture expression type."""
    pass

class Gen(ArchExpr):
    def generator_count(self): return 1
    def depth(self): return 1
    def max_width(self): return 1
    def __repr__(self): return "g"

class Id(ArchExpr):
    def generator_count(self): return 0
    def depth(self): return 0
    def max_width(self): return 0
    def __repr__(self): return "id"

class Seq(ArchExpr):
    def __init__(self, l: ArchExpr, r: ArchExpr):
        self.l, self.r = l, r
    def generator_count(self):
        return self.l.generator_count() + self.r.generator_count()
    def depth(self):
        return self.l.depth() + self.r.depth()
    def max_width(self):
        return max(self.l.max_width(), self.r.max_width())
    def __repr__(self): return f"({self.l} ; {self.r})"

class Par(ArchExpr):
    def __init__(self, l: ArchExpr, r: ArchExpr):
        self.l, self.r = l, r
    def generator_count(self):
        return self.l.generator_count() + self.r.generator_count()
    def depth(self):
        return max(self.l.depth(), self.r.depth())
    def max_width(self):
        return self.l.max_width() + self.r.max_width()
    def __repr__(self): return f"({self.l} | {self.r})"


def analyze_architecture(e: ArchExpr) -> Dict:
    """
    Complete analysis of an architecture expression.

    Returns rank, depth, width, and tradeoff verification.
    """
    rank = e.generator_count()
    d = e.depth()
    w = e.max_width()

    return {
        "expression": str(e),
        "transcendence_rank": rank,
        "depth": d,
        "max_width": w,
        "depth_times_width": d * w,
        "tradeoff_holds": rank <= d * w,
    }


# ============================================================================
# Example Usage
# ============================================================================

if __name__ == "__main__":
    print("=== Algorithm Demonstrations ===\n")

    # 1. Closure system rank
    print("--- Exhaustive Rank Search ---")
    A = frozenset(range(1, 8))

    # Interval closure
    def cl_interval(S):
        if not S: return S
        lo, hi = min(S), max(S)
        return frozenset(range(lo, hi + 1)) & A

    start = time.time()
    rank, witness = search_transcendence_rank(cl_interval, A)
    elapsed = time.time() - start
    print(f"  Set: {sorted(A)}")
    print(f"  Closure: interval closure")
    print(f"  Rank: {rank}")
    print(f"  Witness: {sorted(witness)}")
    print(f"  Time: {elapsed:.4f}s\n")

    # Compare with greedy
    greedy_rank, greedy_witness = greedy_rank_lower_bound(cl_interval, A)
    print(f"  Greedy lower bound: {greedy_rank}")
    print(f"  Greedy witness: {sorted(greedy_witness)}")
    print(f"  Exact match: {greedy_rank == rank}\n")

    # 2. Tropical complexity
    print("--- Tropical Complexity ---")
    A_mat = [[0, 1, 2], [3, 0, 1], [2, 3, 0]]
    B_mat = [[1, 2, 0], [0, 1, 2], [2, 0, 1]]
    C_mat = trop_mul(A_mat, B_mat)

    print(f"  A complexity: {trop_complexity(A_mat)}")
    print(f"  B complexity: {trop_complexity(B_mat)}")
    print(f"  A⊗B complexity: {trop_complexity(C_mat)}")
    print(f"  Bound: {trop_complexity(A_mat) * trop_complexity(B_mat)}\n")

    # 3. Perturbation analysis
    print("--- Perturbation Analysis ---")
    A_small = frozenset(range(1, 6))
    cl_discrete = lambda S: S

    results = rank_stability_analysis(cl_discrete, A_small, max_perturbation_size=3)
    print(f"  Base rank: {results['base_rank']}")
    for entry in results["perturbation_analysis"]:
        print(f"  |P|={entry['perturbation_size']}: "
              f"min_rank={entry['min_rank']}, "
              f"bound={entry['stability_bound']}, "
              f"holds={entry['stability_holds']}")
    print()

    # 4. Architecture analysis
    print("--- Architecture Analysis ---")
    g = Gen()
    architectures = [
        Gen(),
        Seq(g, g),
        Par(g, g),
        Seq(Par(g, g), Seq(g, g)),
        Par(Par(g, g), Par(g, g)),
    ]

    for arch in architectures:
        info = analyze_architecture(arch)
        print(f"  {info['expression']}: "
              f"rank={info['transcendence_rank']}, "
              f"depth={info['depth']}, "
              f"width={info['max_width']}, "
              f"d×w={info['depth_times_width']}, "
              f"tradeoff={'✓' if info['tradeoff_holds'] else '✗'}")

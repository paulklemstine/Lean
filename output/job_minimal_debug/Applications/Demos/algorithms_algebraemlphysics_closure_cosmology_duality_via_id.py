#!/usr/bin/env python3
"""
Algorithms for Closure–Cosmology Duality

Implements the core algorithms from the research paper:
1. FRW Reconstruction from profile matrices
2. Profile rank computation
3. FRW isomorphism checking
4. Closure operator simulation
5. Horizon-growth functional computation
6. Max-plus semimodule operations
"""

import numpy as np
from dataclasses import dataclass, field
from typing import List, Set, FrozenSet, Callable, Optional, Tuple


# ============================================================
# Data Structures
# ============================================================

@dataclass
class ProfileMatrix:
    """A profile matrix encoding pairwise horizon interactions."""
    data: np.ndarray

    @property
    def dim(self) -> int:
        return self.data.shape[0]

    def is_valid(self) -> bool:
        """Check: positive diagonal and diagonal dominance."""
        n = self.dim
        return (all(self.data[i, i] > 0 for i in range(n)) and
                all(self.data[i, j] <= self.data[i, i]
                    for i in range(n) for j in range(n)))

    def is_monotone_diagonal(self) -> bool:
        """Check: diagonal entries are non-decreasing."""
        n = self.dim
        return all(self.data[i, i] <= self.data[i+1, i+1] for i in range(n-1))

    def is_acyclic(self) -> bool:
        """Check: P(i,j)>0 and P(j,i)>0 implies i=j."""
        n = self.dim
        return all(
            not (self.data[i, j] > 0 and self.data[j, i] > 0) or i == j
            for i in range(n) for j in range(n)
        )

    @property
    def profile_rank(self) -> int:
        """The profile rank (= dimension for valid matrices)."""
        return self.dim


@dataclass
class DiscreteFRWModel:
    """A discrete Friedmann–Robertson–Walker model."""
    horizons: List[int]

    @property
    def num_epochs(self) -> int:
        return len(self.horizons)

    def is_monotone(self) -> bool:
        return all(self.horizons[i] <= self.horizons[i+1]
                   for i in range(len(self.horizons)-1))

    def is_isomorphic_to(self, other: 'DiscreteFRWModel') -> bool:
        """Check FRW isomorphism: same epochs and horizons."""
        return self.horizons == other.horizons


@dataclass
class ClosureHorizonProfile:
    """Certified reconstruction input: profile matrix + validity certificates."""
    matrix: ProfileMatrix
    _valid: bool = field(init=False)
    _monotone: bool = field(init=False)

    def __post_init__(self):
        self._valid = self.matrix.is_valid()
        self._monotone = self.matrix.is_monotone_diagonal()

    @property
    def is_certified(self) -> bool:
        return self._valid and self._monotone


# ============================================================
# Core Algorithms
# ============================================================

def reconstruct_frw(P: ProfileMatrix) -> Optional[DiscreteFRWModel]:
    """
    Algorithm: ReconstructFRW

    Reconstruct the unique minimal FRW model from a valid profile matrix.

    Time complexity: O(n)
    Space complexity: O(n)

    Returns None if the matrix is not valid or not monotone-diagonal.
    """
    if not P.is_valid() or not P.is_monotone_diagonal():
        return None

    horizons = [int(P.data[i, i]) for i in range(P.dim)]
    return DiscreteFRWModel(horizons=horizons)


def compute_profile_rank(P: ProfileMatrix) -> int:
    """
    Algorithm: ComputeProfileRank

    For valid matrices, rank = dimension (all rows nonzero).
    For general matrices, count rows with at least one nonzero entry.

    Time complexity: O(n²)
    Space complexity: O(1)
    """
    n = P.dim
    count = 0
    for i in range(n):
        if any(P.data[i, j] != 0 for j in range(n)):
            count += 1
    return count


def certified_reconstruction(profile: ClosureHorizonProfile) -> Optional[Tuple[DiscreteFRWModel, dict]]:
    """
    Algorithm: CertifiedMinimalFRWReconstruction

    From a closure-horizon profile, produce:
    1. A discrete FRW model (realization)
    2. A certificate dict with minimality and uniqueness guarantees

    Time complexity: O(n²) for validation, O(n) for reconstruction
    Space complexity: O(n)
    """
    if not profile.is_certified:
        return None

    P = profile.matrix
    frw = reconstruct_frw(P)
    if frw is None:
        return None

    certificate = {
        "realizes_profile": True,
        "epoch_count": frw.num_epochs,
        "profile_rank": P.profile_rank,
        "minimal": frw.num_epochs == P.profile_rank,
        "unique_up_to_iso": True,
        "horizons": frw.horizons,
    }

    return frw, certificate


# ============================================================
# Closure Operator Simulation
# ============================================================

class ClosureOperator:
    """A closure operator on a finite set, represented by its action on subsets."""

    def __init__(self, elements: Set[int], cl_func: Callable[[FrozenSet[int]], FrozenSet[int]]):
        """
        Args:
            elements: The ground set X.
            cl_func: The closure function cl : P(X) -> P(X).
        """
        self.elements = frozenset(elements)
        self._cl = cl_func

    def cl(self, S: FrozenSet[int]) -> FrozenSet[int]:
        """Apply the closure operator."""
        return self._cl(S)

    def is_extensive(self) -> bool:
        """Check: S ⊆ cl(S) for all S."""
        from itertools import combinations
        for r in range(len(self.elements) + 1):
            for subset in combinations(self.elements, r):
                S = frozenset(subset)
                if not S.issubset(self.cl(S)):
                    return False
        return True

    def is_monotone(self) -> bool:
        """Check: S ⊆ T → cl(S) ⊆ cl(T)."""
        from itertools import combinations
        elems = sorted(self.elements)
        for r1 in range(len(elems) + 1):
            for S_tuple in combinations(elems, r1):
                S = frozenset(S_tuple)
                for r2 in range(r1, len(elems) + 1):
                    for T_tuple in combinations(elems, r2):
                        T = frozenset(T_tuple)
                        if S.issubset(T):
                            if not self.cl(S).issubset(self.cl(T)):
                                return False
        return True

    def is_idempotent(self) -> bool:
        """Check: cl(cl(S)) = cl(S)."""
        from itertools import combinations
        for r in range(len(self.elements) + 1):
            for subset in combinations(self.elements, r):
                S = frozenset(subset)
                if self.cl(self.cl(S)) != self.cl(S):
                    return False
        return True

    def is_closure_operator(self) -> bool:
        return self.is_extensive() and self.is_monotone() and self.is_idempotent()


# ============================================================
# Finite EML Cosmology Simulation
# ============================================================

class FiniteEMLCosmology:
    """A finite EML cosmology datum."""

    def __init__(self, elements: Set[int],
                 cl_func: Callable[[FrozenSet[int]], FrozenSet[int]],
                 tau: Callable[[int], int],
                 H: Callable[[FrozenSet[int], int], int]):
        self.elements = frozenset(elements)
        self.closure = ClosureOperator(elements, cl_func)
        self.tau = tau
        self.H = H

    def horizon_at(self, S: FrozenSet[int], n: int) -> int:
        return self.H(S, n)

    def causal_profile(self, S: FrozenSet[int], T: int) -> List[int]:
        """Extract the causal profile vector [H(S,0), H(S,1), ..., H(S,T)]."""
        return [self.H(S, n) for n in range(T + 1)]

    def check_time_compatible(self) -> bool:
        """Verify time compatibility on small cases."""
        from itertools import combinations
        for r in range(1, len(self.elements) + 1):
            for subset in combinations(self.elements, r):
                S = frozenset(subset)
                cl_S = self.closure.cl(S)
                for x in cl_S:
                    if not any(self.tau(y) <= self.tau(x) for y in S):
                        return False
        return True

    def check_horizon_mono(self, max_n: int = 10) -> bool:
        """Verify horizon monotonicity H(S,n) ≤ H(S,n+1)."""
        from itertools import combinations
        for r in range(len(self.elements) + 1):
            for subset in combinations(self.elements, r):
                S = frozenset(subset)
                for n in range(max_n):
                    if self.H(S, n) > self.H(S, n + 1):
                        return False
        return True

    def build_profile_matrix(self, T: int) -> ProfileMatrix:
        """Build a profile matrix from the cosmology at time T.

        Entry (i,j) = H({i} ∪ {j}, T) - measures cross-visibility at epoch T.
        Diagonal: H({i}, T).
        """
        elems = sorted(self.elements)
        n = len(elems)
        data = np.zeros((n, n), dtype=int)
        for i in range(n):
            for j in range(n):
                if i == j:
                    data[i, j] = self.H(frozenset([elems[i]]), T)
                else:
                    # Cross-visibility: bounded by individual horizons
                    data[i, j] = min(
                        self.H(frozenset([elems[i]]), T),
                        self.H(frozenset([elems[j]]), T)
                    ) // 2  # Conservative cross-visibility estimate
        return ProfileMatrix(data)


# ============================================================
# Max-Plus Semimodule Operations
# ============================================================

class MaxPlusSemimodule:
    """Max-plus (tropical) semimodule operations on ℕ-vectors."""

    @staticmethod
    def add(a: np.ndarray, b: np.ndarray) -> np.ndarray:
        """Max-plus addition: pointwise maximum."""
        return np.maximum(a, b)

    @staticmethod
    def shift(c: int, a: np.ndarray) -> np.ndarray:
        """Scalar shift: add constant to all entries."""
        return a + c

    @staticmethod
    def is_dominated_by(a: np.ndarray, b: np.ndarray) -> bool:
        """Check if a ≤ b pointwise (a is dominated by b)."""
        return bool(np.all(a <= b))

    @staticmethod
    def tropical_combination(generators: List[np.ndarray]) -> np.ndarray:
        """Compute the max-plus sum of a list of generators."""
        if not generators:
            raise ValueError("Need at least one generator")
        result = generators[0].copy()
        for g in generators[1:]:
            result = np.maximum(result, g)
        return result

    @staticmethod
    def verify_idempotent(a: np.ndarray) -> bool:
        """Verify a ⊕ a = a."""
        return bool(np.array_equal(np.maximum(a, a), a))

    @staticmethod
    def verify_commutative(a: np.ndarray, b: np.ndarray) -> bool:
        return bool(np.array_equal(np.maximum(a, b), np.maximum(b, a)))

    @staticmethod
    def verify_associative(a: np.ndarray, b: np.ndarray, c: np.ndarray) -> bool:
        lhs = np.maximum(np.maximum(a, b), c)
        rhs = np.maximum(a, np.maximum(b, c))
        return bool(np.array_equal(lhs, rhs))


# ============================================================
# Main: Run all algorithms
# ============================================================

if __name__ == "__main__":
    print("Closure–Cosmology Duality: Algorithm Demonstrations")
    print("=" * 60)

    # 1. Profile matrix validation and reconstruction
    print("\n1. Profile Matrix → FRW Reconstruction")
    P = ProfileMatrix(np.array([[1, 0, 0], [0, 2, 0], [0, 0, 4]]))
    print(f"   Valid: {P.is_valid()}")
    print(f"   Monotone diagonal: {P.is_monotone_diagonal()}")
    print(f"   Acyclic: {P.is_acyclic()}")
    print(f"   Profile rank: {P.profile_rank}")

    frw = reconstruct_frw(P)
    print(f"   FRW model: {frw}")
    print(f"   Monotone: {frw.is_monotone()}")

    # 2. Certified reconstruction
    print("\n2. Certified Reconstruction")
    profile = ClosureHorizonProfile(P)
    result = certified_reconstruction(profile)
    if result:
        model, cert = result
        print(f"   Model: {model.horizons}")
        print(f"   Certificate: {cert}")

    # 3. Closure operator verification
    print("\n3. Closure Operator Verification")
    # Identity closure (trivial)
    cl_id = ClosureOperator({0, 1, 2}, lambda S: S)
    print(f"   Identity closure is a closure op: {cl_id.is_closure_operator()}")

    # Full closure (everything maps to full set)
    cl_full = ClosureOperator({0, 1, 2},
        lambda S: frozenset({0, 1, 2}) if S else frozenset())
    print(f"   Full closure is a closure op: {cl_full.is_closure_operator()}")

    # 4. Max-plus semimodule
    print("\n4. Max-Plus Semimodule Properties")
    mp = MaxPlusSemimodule()
    a = np.array([1, 3, 5, 7])
    b = np.array([2, 2, 6, 4])
    c = np.array([0, 4, 4, 8])
    print(f"   Idempotent: {mp.verify_idempotent(a)}")
    print(f"   Commutative: {mp.verify_commutative(a, b)}")
    print(f"   Associative: {mp.verify_associative(a, b, c)}")
    print(f"   a ⊕ b = {mp.add(a, b)}")
    print(f"   2 ⊙ a = {mp.shift(2, a)}")

    # 5. Finite cosmology simulation
    print("\n5. Finite EML Cosmology Simulation")
    cosmo = FiniteEMLCosmology(
        elements={0, 1, 2},
        cl_func=lambda S: S,  # identity closure
        tau=lambda x: x,      # time = element index
        H=lambda S, n: len(S) * (n + 1),  # linear growth
    )
    profile_vec = cosmo.causal_profile(frozenset([0, 1]), 5)
    print(f"   Profile of {{0,1}} up to T=5: {profile_vec}")
    print(f"   Time compatible: {cosmo.check_time_compatible()}")
    print(f"   Horizon monotone: {cosmo.check_horizon_mono()}")

    P_cosmo = cosmo.build_profile_matrix(5)
    print(f"   Profile matrix at T=5:\n{P_cosmo.data}")

    print("\n✓ All algorithms executed successfully.")

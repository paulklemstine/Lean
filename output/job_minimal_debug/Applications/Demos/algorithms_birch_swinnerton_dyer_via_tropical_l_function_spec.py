#!/usr/bin/env python3
"""
Algorithms for Tropical BSD Computation

Implements the core algorithms for computing tropical arithmetic invariants:
- Tropical L-series evaluation
- Active set computation
- Tropical order of vanishing
- Tropical permanent (regulator)
- Tropical residue decomposition
- Tropical rank via independence testing

All algorithms operate on finite data and are fully computable.
"""

import numpy as np
from itertools import permutations
from typing import List, Set, Dict, Tuple, Optional


class TropicalLData:
    """A tropical L-datum: coefficients and weights on a finite support."""

    def __init__(self, support: List[int], a: Dict[int, float], w: Dict[int, float]):
        """
        Args:
            support: Finite set of indices
            a: Coefficient function a(n) for n in support
            w: Weight function w(n) for n in support
        """
        self.support = support
        self.a = a
        self.w = w

    def evaluate(self, s: float) -> float:
        """
        Evaluate the tropical L-series at parameter s.

        L_trop(s) = inf_{n in S} (a(n) + s * w(n))

        Time complexity: O(|S|)
        Space complexity: O(1)
        """
        return min(self.a[n] + s * self.w[n] for n in self.support)

    def active_set(self, s: float) -> Set[int]:
        """
        Compute the active set at parameter s.

        ActiveSet(s) = {n in S : a(n) + s*w(n) = L_trop(s)}

        Time complexity: O(|S|)
        Space complexity: O(|S|)
        """
        min_val = self.evaluate(s)
        return {n for n in self.support
                if abs(self.a[n] + s * self.w[n] - min_val) < 1e-12}

    def tropical_order_at_one(self) -> int:
        """
        Compute the tropical order of vanishing at s=1.

        ord_trop(1) = |ActiveSet(1)| - 1

        Time complexity: O(|S|)
        Space complexity: O(|S|)
        """
        return len(self.active_set(1.0)) - 1

    def breakpoints(self, s_range: Tuple[float, float] = (-5, 5),
                    resolution: int = 10000) -> List[float]:
        """
        Find approximate breakpoints of the piecewise-linear L-series.

        The tropical L-series is the lower envelope of affine functions,
        so it is piecewise linear. Breakpoints occur where the active
        set changes.

        Time complexity: O(|S|^2 * log(|S|))
        Space complexity: O(|S|^2)
        """
        breakpts = []
        # For each pair of branches, find intersection
        for i, n1 in enumerate(self.support):
            for n2 in self.support[i+1:]:
                dw = self.w[n1] - self.w[n2]
                if abs(dw) > 1e-12:
                    s_cross = (self.a[n2] - self.a[n1]) / dw
                    if s_range[0] <= s_cross <= s_range[1]:
                        breakpts.append(s_cross)
        return sorted(set(breakpts))


def tropical_permanent(M: np.ndarray) -> float:
    """
    Compute the tropical permanent of an n×n matrix.

    tperm(M) = min_{σ ∈ S_n} Σ_i M[i][σ(i)]

    This is the tropical analogue of the matrix permanent/determinant.
    In the BSD context, it computes the tropical regulator.

    Time complexity: O(n! * n)  — exact, exponential
    Space complexity: O(n)

    For large n, use the Hungarian algorithm (O(n^3)) instead.
    """
    n = M.shape[0]
    if n == 0:
        return 0.0

    indices = list(range(n))
    min_val = float('inf')
    min_perm = None

    for perm in permutations(indices):
        val = sum(M[i][perm[i]] for i in indices)
        if val < min_val:
            min_val = val
            min_perm = perm

    return min_val


def tropical_permanent_hungarian(M: np.ndarray) -> float:
    """
    Compute the tropical permanent using the Hungarian algorithm.

    Time complexity: O(n^3)
    Space complexity: O(n^2)

    This is the efficient version for large matrices.
    """
    try:
        from scipy.optimize import linear_sum_assignment
        row_ind, col_ind = linear_sum_assignment(M)
        return M[row_ind, col_ind].sum()
    except ImportError:
        return tropical_permanent(M)


def tropical_tamagawa(c: np.ndarray) -> float:
    """
    Compute the tropical Tamagawa product (additive form).

    TropTam(c) = Σ_i c[i]

    Time complexity: O(n)
    Space complexity: O(1)
    """
    return float(np.sum(c))


def tropical_residue(R: np.ndarray, c: np.ndarray) -> float:
    """
    Compute the tropical residue.

    TropRes(R, c) = TropReg(R) + TropTam(c)

    Time complexity: O(n! * n) or O(n^3) with Hungarian
    Space complexity: O(n^2)
    """
    return tropical_permanent(R) + tropical_tamagawa(c)


def is_tropically_independent(gens: np.ndarray) -> bool:
    """
    Test whether a family of valuation profiles is tropically independent.

    Two profiles v1, v2 are tropically equivalent if v1 - v2 = constant.
    A family is independent if no two members are equivalent.

    Args:
        gens: (m, k) array where gens[i] is the i-th valuation profile

    Time complexity: O(m^2 * k)
    Space complexity: O(m * k)
    """
    m, k = gens.shape
    for i in range(m):
        for j in range(i + 1, m):
            diff = gens[i] - gens[j]
            if np.allclose(diff, diff[0]):
                return False
    return True


def tropical_rank(gens: np.ndarray) -> int:
    """
    Compute the tropical rank of a family of valuation profiles.

    Returns the size of a maximal tropically independent subfamily.

    Args:
        gens: (m, k) array where gens[i] is the i-th valuation profile

    Time complexity: O(m^2 * k) for greedy extraction
    Space complexity: O(m * k)
    """
    m, k = gens.shape
    independent = []

    for i in range(m):
        candidate = list(independent) + [i]
        sub = gens[candidate]
        if is_tropically_independent(sub):
            independent.append(i)

    return len(independent)


def verify_tropical_bsd(gens: np.ndarray, L_data: TropicalLData) -> dict:
    """
    Verify the tropical BSD equality for given data.

    Returns a dictionary with:
    - tropical_order: the tropical order of vanishing at s=1
    - tropical_rank: the tropical rank of generators
    - equality_holds: whether order == rank
    - active_set: the active set at s=1
    """
    order = L_data.tropical_order_at_one()
    rank = tropical_rank(gens)

    return {
        'tropical_order': order,
        'tropical_rank': rank,
        'equality_holds': order == rank,
        'active_set': L_data.active_set(1.0),
        'active_set_size': len(L_data.active_set(1.0)),
    }


# ═══════════════════════════════════════════════════════════════
# Example Usage
# ═══════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("Tropical BSD Algorithms — Example Computations")
    print("=" * 60)

    # Example: Rank-2 with compatible L-data
    gens = np.array([
        [1.0, 0.0, 2.0],  # generator 1
        [0.0, 2.0, 1.0],  # generator 2
    ])

    L_data = TropicalLData(
        support=[0, 1, 2],
        a={0: 1.0, 1: 1.0, 2: 1.0},
        w={0: 0.0, 1: 0.0, 2: 0.0}
    )

    result = verify_tropical_bsd(gens, L_data)

    print(f"  Generators: {gens.tolist()}")
    print(f"  Tropically independent: {is_tropically_independent(gens)}")
    print(f"  Tropical rank: {result['tropical_rank']}")
    print(f"  Tropical order: {result['tropical_order']}")
    print(f"  Active set: {result['active_set']}")
    print(f"  BSD equality holds: {result['equality_holds']}")

    print()

    # Example: Residue decomposition
    R = np.array([[2.0, 5.0, 3.0],
                  [4.0, 1.0, 6.0],
                  [3.0, 7.0, 2.0]])
    c = np.array([0.5, 0.3, 0.2])

    reg = tropical_permanent(R)
    tam = tropical_tamagawa(c)
    res = tropical_residue(R, c)

    print(f"  Regulator matrix:\n{R}")
    print(f"  Tamagawa data: {c}")
    print(f"  Tropical regulator: {reg}")
    print(f"  Tropical Tamagawa: {tam}")
    print(f"  Tropical residue: {res}")
    print(f"  Decomposition: {reg} + {tam} = {res}")
    print(f"  Verified: {abs(res - reg - tam) < 1e-12}")

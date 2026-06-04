#!/usr/bin/env python3
"""
Holographic Code Complex — Core Algorithms

Type-hinted implementations of the key algorithms from the formalization.
"""

from dataclasses import dataclass, field
from typing import List, Set, Dict, Tuple, Optional, FrozenSet
import math


@dataclass(frozen=True)
class CodeParams:
    """Quantum code parameters [[n, k, d]] satisfying the Singleton bound."""
    n: int
    k: int
    d: int

    def __post_init__(self):
        assert self.n > 0, "n must be positive"
        assert self.k <= self.n, "k must be ≤ n"
        assert self.d > 0, "d must be positive"
        assert 2 * self.d + self.k <= self.n + 2, "Singleton bound violated"

    @property
    def redundancy(self) -> int:
        return self.n - self.k

    @property
    def is_mds(self) -> bool:
        return 2 * self.d + self.k == self.n + 2

    @property
    def singleton_entropy(self) -> float:
        return (self.n - self.k) / 2.0

    @property
    def singleton_gap(self) -> int:
        return (self.n + 2) - (2 * self.d + self.k)

    @property
    def rate(self) -> float:
        return self.k / self.n

    @property
    def distance_ratio(self) -> float:
        return self.d / self.n


@dataclass
class CodeGraph:
    """A weighted graph modeling a tensor network.

    Vertices are numbered 0..V-1.
    Weights are symmetric with zero diagonal.
    """
    V: int
    weights: List[List[float]]
    boundary: Set[int] = field(default_factory=set)

    def __post_init__(self):
        assert len(self.weights) == self.V
        for row in self.weights:
            assert len(row) == self.V

    def cut_weight(self, S: Set[int]) -> float:
        """Compute the cut weight: total weight of edges from S to V\\S."""
        total = 0.0
        complement = set(range(self.V)) - S
        for i in S:
            for j in complement:
                total += self.weights[i][j]
        return total


def greedy_step(G: CodeGraph, S: Set[int]) -> Tuple[Set[int], bool]:
    """One step of the greedy entanglement wedge algorithm.

    Returns (new_set, changed).
    """
    current_cut = G.cut_weight(S)
    for v in range(G.V):
        if v not in S:
            new_S = S | {v}
            if G.cut_weight(new_S) <= current_cut:
                return new_S, True
    return S, False


def greedy_wedge(G: CodeGraph, A: Set[int], max_steps: Optional[int] = None) -> Set[int]:
    """Compute the greedy entanglement wedge of boundary region A.

    Algorithm:
        1. Start with S = A
        2. While there exists v ∉ S with cut(S ∪ {v}) ≤ cut(S):
           - Add v to S
        3. Return S

    Guaranteed to terminate within V steps (by greedyWedge_terminates).
    """
    if max_steps is None:
        max_steps = G.V

    S = set(A)
    for _ in range(max_steps):
        S, changed = greedy_step(G, S)
        if not changed:
            break
    return S


def rt_singleton_check(code: CodeParams) -> Dict[str, float]:
    """Check the RT-Singleton equivalence for a given code.

    Returns a dictionary with key quantities.
    """
    s_ent = code.singleton_entropy
    return {
        "n": code.n,
        "k": code.k,
        "d": code.d,
        "singleton_entropy": s_ent,
        "singleton_entropy_plus_1": s_ent + 1,
        "is_mds": code.is_mds,
        "singleton_gap": code.singleton_gap,
        "rate": code.rate,
        "distance_ratio": code.distance_ratio,
        "tradeoff_lhs": code.rate + 2 * code.distance_ratio,
        "tradeoff_rhs": 1 + 2 / code.n,
    }


def entropy_cone_dimensions(N: int) -> Dict[str, int]:
    """Compute entropy cone dimensions for N parties.

    Returns:
        - dim: 2^N - 1 (full entropy cone dimension)
        - geodesics: C(N, 2) (number of pairwise entanglements)
        - mmi_constraints: C(N, 3) (number of MMI constraints)
        - effective_dim: dim - mmi_constraints
    """
    dim = 2**N - 1
    geodesics = math.comb(N, 2)
    mmi = math.comb(N, 3) if N >= 3 else 0
    return {
        "N": N,
        "dim": dim,
        "geodesics": geodesics,
        "mmi_constraints": mmi,
        "effective_dim": dim - mmi,
        "geodesics_le_dim": geodesics <= dim,
        "mmi_le_dim": mmi <= dim,
    }


def compose_codes(c1: CodeParams, c2: CodeParams, bonds: int) -> Dict[str, int]:
    """Compute parameters of composed tensor network code.

    When two codes share `bonds` contracted indices:
    - n_composed = n1 + n2 - 2 * bonds
    - k_composed = k1 + k2
    - d_composed ≥ min(d1, d2)
    """
    n_composed = c1.n + c2.n - 2 * bonds
    k_composed = c1.k + c2.k
    d_composed = min(c1.d, c2.d)

    return {
        "n": n_composed,
        "k": k_composed,
        "d_lower_bound": d_composed,
        "singleton_satisfied": 2 * d_composed + k_composed <= n_composed + 2,
    }


def happy_pentagon() -> Dict[str, any]:
    """Compute parameters of the HaPPY pentagon code.

    5 copies of [[5,1,3]] arranged on a 5-cycle.
    Each tensor has 5 legs: 2 bonded to neighbors, 3 boundary.
    """
    local = CodeParams(5, 1, 3)

    # Pentagon: 5 tensors, each bonding 2 legs to neighbors
    n_global = 5 * 3  # 5 tensors × 3 boundary legs
    k_global = 5 * 1  # 5 logical qubits
    d_global = 3       # minimum cut through pentagon

    global_code = CodeParams(n_global, k_global, d_global)

    return {
        "local_code": f"[[{local.n},{local.k},{local.d}]]",
        "local_is_mds": local.is_mds,
        "global_n": n_global,
        "global_k": k_global,
        "global_d": d_global,
        "global_is_mds": global_code.is_mds,
        "global_gap": global_code.singleton_gap,
        "global_redundancy": global_code.redundancy,
        "singleton_entropy": global_code.singleton_entropy,
        "gap_equals_2d": global_code.singleton_gap == 2 * d_global,
    }


if __name__ == "__main__":
    # Test all algorithms
    print("=== RT-Singleton Check ===")
    for n, k, d, name in [(5, 1, 3, "Perfect"), (7, 1, 3, "Steane"), (15, 5, 3, "Pentagon")]:
        code = CodeParams(n, k, d)
        result = rt_singleton_check(code)
        print(f"  {name}: {result}")

    print("\n=== Entropy Cone ===")
    for N in range(2, 7):
        print(f"  N={N}: {entropy_cone_dimensions(N)}")

    print("\n=== HaPPY Pentagon ===")
    print(f"  {happy_pentagon()}")

    print("\n=== Composition ===")
    c1 = CodeParams(5, 1, 3)
    c2 = CodeParams(5, 1, 3)
    print(f"  Two [[5,1,3]] with 1 bond: {compose_codes(c1, c2, 1)}")

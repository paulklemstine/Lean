#!/usr/bin/env python3
"""
Algorithms for Holographic Gravity as Quantum Error Correction.

Implements the core algorithms from the research paper:
1. Holographic code parameter computation
2. Reconstruction decision algorithm
3. Tropical shortest path (Floyd-Warshall)
4. Complementary recovery verification
5. HaPPY code family generation
6. Code concatenation
"""

from dataclasses import dataclass
from typing import List, Tuple, Optional
import math


# ============================================================
# Algorithm 1: Holographic Code Parameters
# ============================================================

@dataclass
class HolographicCodeParams:
    """Parameters and derived quantities for a holographic code.

    Attributes:
        n: Number of boundary (physical) qubits
        k: Number of bulk (logical) qubits
        d: Code distance
        fourG: Discretized Newton's constant (default 1)
    """
    n: int
    k: int
    d: int
    fourG: int = 1

    def compute_all(self) -> dict:
        """Compute all derived parameters in O(1) time and space.

        Returns:
            Dictionary with entropy, area, singleton_deficit, erasure_capacity,
            is_mds, singleton_valid, entropy_ratio.
        """
        entropy = self.n - self.k
        area = self.fourG * entropy
        singleton_lhs = 2 * self.d + self.k
        singleton_rhs = self.n + 2
        singleton_deficit = singleton_rhs - singleton_lhs

        return {
            'entropy': entropy,
            'area': area,
            'erasure_capacity': self.d - 1,
            'singleton_deficit': singleton_deficit,
            'is_mds': singleton_deficit == 0,
            'singleton_valid': singleton_lhs <= singleton_rhs,
            'entropy_ratio': entropy / self.n if self.n > 0 else 0,
            'rate': self.k / self.n if self.n > 0 else 0,
        }


# ============================================================
# Algorithm 2: Reconstruction Decision
# ============================================================

def can_reconstruct(n: int, d: int, region_size: int) -> bool:
    """Decide if a boundary region can reconstruct bulk information.

    O(1) time and space.

    Args:
        n: Total boundary qubits
        d: Code distance
        region_size: Size of the boundary region

    Returns:
        True if the region can reconstruct all bulk qubits.

    Examples:
        >>> can_reconstruct(5, 3, 3)
        True
        >>> can_reconstruct(5, 3, 2)
        False
    """
    return n - region_size < d


def max_bulk_reconstruction(n: int, k: int, d: int, region_size: int) -> int:
    """Maximum number of bulk qubits reconstructable from a boundary region.

    O(1) time and space.

    Args:
        n: Total boundary qubits
        k: Total bulk qubits
        d: Code distance
        region_size: Size of the boundary region

    Returns:
        k if full reconstruction is possible, 0 otherwise.

    Examples:
        >>> max_bulk_reconstruction(5, 1, 3, 3)
        1
        >>> max_bulk_reconstruction(5, 1, 3, 2)
        0
    """
    if region_size + d > n:
        return k
    return 0


# ============================================================
# Algorithm 3: Tropical Shortest Path (Floyd-Warshall)
# ============================================================

def tropical_shortest_paths(weights: List[List[float]]) -> List[List[float]]:
    """Compute all-pairs shortest paths using tropical Floyd-Warshall.

    Uses the tropical semiring (min, +) where:
    - Tropical addition = min
    - Tropical multiplication = ordinary addition

    Time complexity: O(n³)
    Space complexity: O(n²)

    Args:
        weights: n×n weight matrix. Use float('inf') for absent edges.
                 weights[i][i] should be 0.

    Returns:
        n×n matrix of shortest path distances.

    Examples:
        >>> # Pentagon graph
        >>> n = 5
        >>> INF = float('inf')
        >>> W = [[INF]*n for _ in range(n)]
        >>> for i in range(n):
        ...     W[i][i] = 0
        ...     W[i][(i+1)%n] = 1
        ...     W[(i+1)%n][i] = 1
        >>> D = tropical_shortest_paths(W)
        >>> D[0][2]  # shortest path from v0 to v2
        2.0
    """
    n = len(weights)
    dist = [row[:] for row in weights]

    for k in range(n):
        for i in range(n):
            for j in range(n):
                # Tropical relaxation: min(current, path via k)
                tropical_sum = dist[i][k] + dist[k][j]  # tropical multiplication
                dist[i][j] = min(dist[i][j], tropical_sum)  # tropical addition

    return dist


def verify_triangle_inequality(dist: List[List[float]]) -> bool:
    """Verify the triangle inequality for a distance matrix.

    O(n³) time.

    Args:
        dist: n×n distance matrix.

    Returns:
        True if d(i,k) ≤ d(i,j) + d(j,k) for all i,j,k.
    """
    n = len(dist)
    for i in range(n):
        for j in range(n):
            for k in range(n):
                if dist[i][k] > dist[i][j] + dist[j][k] + 1e-10:
                    return False
    return True


# ============================================================
# Algorithm 4: Complementary Recovery Verification
# ============================================================

def verify_complementary_recovery(n: int, k: int, d: int) -> Tuple[bool, Optional[int]]:
    """Verify complementary recovery for all boundary region sizes.

    For k ≥ 1, checks that no region AND its complement can both reconstruct.

    O(n) time.

    Args:
        n: Boundary qubits
        k: Bulk qubits
        d: Code distance

    Returns:
        (True, None) if complementary recovery holds for all sizes.
        (False, size) if a counterexample is found at the given size.
    """
    if k < 1:
        return (True, None)

    for size in range(n + 1):
        region_corrects = n - size < d
        complement_corrects = size < d  # complement has size n - size; n - (n-size) = size
        if region_corrects and complement_corrects:
            return (False, size)

    return (True, None)


# ============================================================
# Algorithm 5: HaPPY Code Family Generation
# ============================================================

def happy_family(max_level: int) -> List[HolographicCodeParams]:
    """Generate the HaPPY code family up to a given level.

    O(L) time and space.

    Args:
        max_level: Maximum level L.

    Returns:
        List of HolographicCodeParams for levels 0..max_level.

    Examples:
        >>> codes = happy_family(3)
        >>> codes[0].n, codes[0].k, codes[0].d
        (5, 1, 3)
        >>> codes[3].n, codes[3].k, codes[3].d
        (20, 4, 3)
    """
    return [
        HolographicCodeParams(
            n=5 * (L + 1),
            k=L + 1,
            d=3,
            fourG=1,
        )
        for L in range(max_level + 1)
    ]


# ============================================================
# Algorithm 6: Code Concatenation
# ============================================================

def concatenate_codes(
    outer: HolographicCodeParams,
    inner: HolographicCodeParams,
) -> HolographicCodeParams:
    """Concatenate two quantum codes.

    The concatenated code has parameters [[n₁n₂, k₁k₂, d₁d₂]].

    O(1) time and space.

    Args:
        outer: Outer code parameters.
        inner: Inner code parameters.

    Returns:
        Concatenated code parameters.

    Examples:
        >>> outer = HolographicCodeParams(5, 1, 3)
        >>> inner = HolographicCodeParams(5, 1, 3)
        >>> result = concatenate_codes(outer, inner)
        >>> result.n, result.k, result.d
        (25, 1, 9)
    """
    return HolographicCodeParams(
        n=outer.n * inner.n,
        k=outer.k * inner.k,
        d=outer.d * inner.d,
    )


# ============================================================
# Algorithm 7: MDS Code Enumeration
# ============================================================

def find_mds_codes(max_n: int, max_d: int) -> List[Tuple[int, int, int]]:
    """Find all MDS quantum codes [[n, k, d]] with given bounds.

    An MDS code satisfies 2d + k = n + 2 with k ≥ 1, d ≥ 1.

    O(max_n × max_d) time.

    Args:
        max_n: Maximum number of physical qubits.
        max_d: Maximum code distance.

    Returns:
        List of (n, k, d) triples.
    """
    codes = []
    for d in range(1, max_d + 1):
        for k in range(1, max_n + 1):
            n = 2 * d + k - 2
            if 1 <= n <= max_n and k <= n:
                codes.append((n, k, d))
    return codes


if __name__ == "__main__":
    # Example usage
    print("=== HaPPY Code Family ===")
    family = happy_family(5)
    for L, code in enumerate(family):
        params = code.compute_all()
        print(f"  L={L}: [[{code.n},{code.k},{code.d}]] "
              f"S={params['entropy']} A={params['area']} "
              f"MDS={'Yes' if params['is_mds'] else 'No'} "
              f"S/n={params['entropy_ratio']:.4f}")

    print("\n=== Complementary Recovery ===")
    for n, k, d in [(5, 1, 3), (7, 1, 3), (9, 1, 3)]:
        result, cex = verify_complementary_recovery(n, k, d)
        print(f"  [[{n},{k},{d}]]: {'Holds' if result else f'FAILS at size {cex}'}")

    print("\n=== Tropical Shortest Paths (Pentagon) ===")
    n = 5
    INF = float('inf')
    W = [[INF] * n for _ in range(n)]
    for i in range(n):
        W[i][i] = 0
        W[i][(i + 1) % n] = 1
        W[(i + 1) % n][i] = 1
    D = tropical_shortest_paths(W)
    print(f"  Distance matrix:\n  {D}")
    print(f"  Triangle inequality: {verify_triangle_inequality(D)}")

    print("\n=== MDS Codes (n ≤ 30) ===")
    mds = find_mds_codes(30, 10)
    for n, k, d in mds[:10]:
        print(f"  [[{n},{k},{d}]]")

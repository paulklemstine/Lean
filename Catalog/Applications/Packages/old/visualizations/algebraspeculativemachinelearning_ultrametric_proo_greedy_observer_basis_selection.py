#!/usr/bin/env python3
"""
Algorithms for Ultrametric Proof Rate-Distortion Theory

Implements the core algorithms from the formalization:
1. Ultrametric ball partition computation
2. Observer code generation
3. Greedy observer basis selection
4. Certified decoder reconstruction
5. Rate-distortion curve computation
"""

from typing import List, Set, Dict, Tuple, Optional
import math


# ============================================================
# Algorithm 1: Ultrametric Ball Partition
# ============================================================

def ultrametric_ball_partition(
    d: List[List[float]], epsilon: float
) -> List[Set[int]]:
    """Compute the canonical ε-ball partition of an ultrametric space.

    In an ultrametric space, ε-balls are either disjoint or equal
    (the Ball Dichotomy Theorem). This means the partition is canonical
    and unique — there is exactly one way to partition the space at scale ε.

    Algorithm:
        For each unassigned point x, compute its ε-ball B(x,ε) = {y | d(x,y) ≤ ε}
        and mark all points in the ball as assigned.

    Time complexity: O(n²) where n = |P|
    Space complexity: O(n)

    Args:
        d: Distance matrix (n × n, symmetric, satisfying ultrametric inequality)
        epsilon: Scale parameter ε ≥ 0

    Returns:
        List of disjoint sets partitioning {0, ..., n-1}
    """
    n = len(d)
    assigned: Set[int] = set()
    partition: List[Set[int]] = []

    for i in range(n):
        if i not in assigned:
            ball = {j for j in range(n) if d[i][j] <= epsilon}
            partition.append(ball)
            assigned |= ball

    return partition


# ============================================================
# Algorithm 2: Observer Code Generation
# ============================================================

def observer_code(
    obs: List[List[float]], x: int
) -> Tuple[float, ...]:
    """Compute the observer code of a point.

    The observer code maps each proof state to its vector of observation values.
    Two points have the same code iff they are code-equal (ObsCodeEq).

    Time complexity: O(|O|)

    Args:
        obs: Observer matrix (|O| × n), where obs[o][x] = observation value
        x: Point index

    Returns:
        Tuple of observation values (the code)
    """
    return tuple(obs[o][x] for o in range(len(obs)))


def code_partition(
    obs: List[List[float]], n: int
) -> List[Set[int]]:
    """Partition points by observer code equality.

    Time complexity: O(n · |O|)

    Args:
        obs: Observer matrix
        n: Number of points

    Returns:
        List of equivalence classes under code equality
    """
    codes: Dict[Tuple[float, ...], Set[int]] = {}
    for i in range(n):
        c = observer_code(obs, i)
        if c not in codes:
            codes[c] = set()
        codes[c].add(i)
    return list(codes.values())


# ============================================================
# Algorithm 3: Greedy Observer Basis Selection
# ============================================================

def greedy_observer_basis(
    d: List[List[float]],
    obs: List[List[float]],
    epsilon: float
) -> List[int]:
    """Select a minimum-cardinality observer basis using the greedy algorithm.

    At each step, selects the observer that separates the most currently-
    unseparated pairs. In the ultrametric setting with laminar partition
    structure, this greedy strategy achieves optimality.

    Algorithm:
        1. Initialize unseparated = {(x,y) | d(x,y) > ε}
        2. While unseparated ≠ ∅:
           a. For each available observer o, count how many unseparated
              pairs it separates
           b. Select o* = argmax(separation count)
           c. Add o* to basis, remove separated pairs from unseparated

    Time complexity: O(|O|² · n²)
    Space complexity: O(n²)

    Args:
        d: Distance matrix
        obs: Observer matrix
        epsilon: Scale parameter

    Returns:
        List of selected observer indices forming a certified basis
    """
    n = len(d)
    n_obs = len(obs)

    # Find all pairs needing separation
    unseparated: Set[Tuple[int, int]] = set()
    for i in range(n):
        for j in range(i + 1, n):
            if d[i][j] > epsilon:
                unseparated.add((i, j))

    basis: List[int] = []
    available: Set[int] = set(range(n_obs))

    while unseparated and available:
        best_obs = -1
        best_separated: Set[Tuple[int, int]] = set()

        for o in available:
            separated = {(i, j) for (i, j) in unseparated
                        if obs[o][i] != obs[o][j]}
            if len(separated) > len(best_separated):
                best_obs = o
                best_separated = separated

        if not best_separated:
            break

        basis.append(best_obs)
        available.discard(best_obs)
        unseparated -= best_separated

    return basis


# ============================================================
# Algorithm 4: Certified Decoder
# ============================================================

class CertifiedDecoder:
    """A certified decoder that reconstructs proof states from observer codes.

    Given a spectrally separating observer family at scale ε, the decoder
    maps each observer code to a representative proof state, with the
    guarantee that the reconstruction error is at most ε.

    The decoder is constructed by:
    1. Computing the code partition
    2. Selecting a representative from each class
    3. Building a lookup table from codes to representatives
    """

    def __init__(
        self,
        obs: List[List[float]],
        n: int,
        epsilon: float,
        d: Optional[List[List[float]]] = None
    ):
        """Initialize the certified decoder.

        Args:
            obs: Observer matrix
            n: Number of points
            epsilon: Distortion budget
            d: Distance matrix (for verification only)
        """
        self.obs = obs
        self.n = n
        self.epsilon = epsilon
        self.d = d

        # Build lookup table
        self.code_to_representative: Dict[Tuple[float, ...], int] = {}
        self.code_to_class: Dict[Tuple[float, ...], Set[int]] = {}

        for i in range(n):
            c = observer_code(obs, i)
            if c not in self.code_to_representative:
                self.code_to_representative[c] = i
                self.code_to_class[c] = set()
            self.code_to_class[c].add(i)

    def decode(self, code: Tuple[float, ...]) -> int:
        """Decode an observer code to a representative point.

        Returns:
            Index of a representative point with the given code.
            Guaranteed: d(decoded, original) ≤ ε for any original with this code.
        """
        return self.code_to_representative.get(code, -1)

    def verify_certification(self) -> bool:
        """Verify the certification: max intra-class distance ≤ ε.

        Returns:
            True if all classes satisfy the distortion bound.
        """
        if self.d is None:
            raise ValueError("Distance matrix required for verification")

        for code, members in self.code_to_class.items():
            for a in members:
                for b in members:
                    if self.d[a][b] > self.epsilon + 1e-10:
                        return False
        return True

    @property
    def code_count(self) -> int:
        """Number of distinct codes (= covering number)."""
        return len(self.code_to_representative)

    @property
    def rate(self) -> float:
        """Proof rate: log₂ of the code count."""
        return math.log2(self.code_count) if self.code_count > 0 else 0


# ============================================================
# Algorithm 5: Rate-Distortion Curve
# ============================================================

def rate_distortion_curve(
    d: List[List[float]]
) -> List[Tuple[float, float, int]]:
    """Compute the complete rate-distortion curve R(ε).

    The rate-distortion function in the ultrametric setting is a step function:
    R(ε) = log₂(N(ε)) where N(ε) is the covering number.

    Algorithm:
        1. Collect all distinct positive distances
        2. For each distance level ε, compute N(ε)
        3. Return the pairs (ε, R(ε), N(ε))

    Time complexity: O(n² · D) where D = number of distinct distances
    Space complexity: O(n + D)

    Returns:
        List of (epsilon, rate, covering_number) tuples
    """
    n = len(d)
    all_dists = sorted(set(d[i][j] for i in range(n) for j in range(i + 1, n) if d[i][j] > 0))

    results: List[Tuple[float, float, int]] = []

    # At ε = 0, each point is its own class
    results.append((0.0, math.log2(n), n))

    # At each distance threshold
    for eps in all_dists:
        partition = ultrametric_ball_partition(d, eps)
        n_eps = len(partition)
        rate = math.log2(n_eps) if n_eps > 0 else 0
        results.append((eps, rate, n_eps))

    return results


# ============================================================
# Algorithm 6: Ultrametric Verification
# ============================================================

def verify_ultrametric(d: List[List[float]]) -> Tuple[bool, Optional[Tuple[int, int, int]]]:
    """Verify the ultrametric inequality for a distance matrix.

    Checks d(x,z) ≤ max(d(x,y), d(y,z)) for all triples.

    Returns:
        (True, None) if the matrix is ultrametric
        (False, (x,y,z)) with a violating triple otherwise
    """
    n = len(d)
    for i in range(n):
        for j in range(n):
            for k in range(n):
                if d[i][k] > max(d[i][j], d[j][k]) + 1e-10:
                    return False, (i, j, k)
    return True, None


# ============================================================
# Example Usage
# ============================================================

if __name__ == "__main__":
    # Example: 6-point ultrametric space
    d = [
        [0, 1, 2, 2, 4, 4],
        [1, 0, 2, 2, 4, 4],
        [2, 2, 0, 1, 4, 4],
        [2, 2, 1, 0, 4, 4],
        [4, 4, 4, 4, 0, 1],
        [4, 4, 4, 4, 1, 0],
    ]

    print("=== Ultrametric Algorithms Demo ===\n")

    # Verify ultrametric
    is_ultra, violation = verify_ultrametric(d)
    print(f"1. Ultrametric verification: {is_ultra}")

    # Ball partition at various scales
    print("\n2. Ball partitions:")
    for eps in [0.5, 1, 2, 4]:
        partition = ultrametric_ball_partition(d, eps)
        print(f"   ε={eps}: {[sorted(c) for c in partition]}")

    # Observer codes (using indicator observers)
    print("\n3. Observer codes at ε=1:")
    partition_1 = ultrametric_ball_partition(d, 1)
    obs = [[1.0 if j in cls else 0.0 for j in range(6)] for cls in partition_1]
    for i in range(6):
        print(f"   Point {i}: code = {observer_code(obs, i)}")

    # Greedy basis
    print("\n4. Greedy basis selection at ε=1:")
    basis = greedy_observer_basis(d, obs, 1)
    print(f"   Basis: {basis} (size {len(basis)})")

    # Certified decoder
    print("\n5. Certified decoder at ε=1:")
    decoder = CertifiedDecoder(obs, 6, 1, d)
    print(f"   Code count (= covering number): {decoder.code_count}")
    print(f"   Rate: {decoder.rate:.3f} bits")
    print(f"   Certification verified: {decoder.verify_certification()}")

    # Rate-distortion curve
    print("\n6. Rate-distortion curve:")
    curve = rate_distortion_curve(d)
    for eps, rate, n_eps in curve:
        print(f"   ε={eps:.1f}: N(ε)={n_eps}, R(ε)={rate:.3f}")

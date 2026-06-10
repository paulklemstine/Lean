#!/usr/bin/env python3
"""
Algorithms for Ultrametric Observer–Code Duality

Implements the core algorithms from the research paper:
1. Ultrametric verification (O(n³))
2. Level partition computation (O(n²))
3. Canonical code construction (O(n² · L))
4. Separation reconstruction from level data (O(n² · L))
5. Random ultrametric generation via dendrogram (O(n²))
6. Dendrogram (hierarchical clustering) extraction
"""

from typing import List, Dict, Tuple, Set, Optional
from dataclasses import dataclass
from collections import defaultdict


@dataclass
class FiniteObserverSystem:
    """A finite ultrametric space with ℕ-valued separation.

    Attributes:
        labels: Names for the observers
        sep: Separation matrix (symmetric, zero diagonal, ultrametric)
    """
    labels: List[str]
    sep: List[List[int]]

    @property
    def n(self) -> int:
        return len(self.labels)

    @property
    def max_sep(self) -> int:
        return max(self.sep[i][j] for i in range(self.n) for j in range(self.n))

    def verify(self) -> bool:
        """Verify all ultrametric axioms. O(n³) time."""
        n = self.n
        for i in range(n):
            if self.sep[i][i] != 0:
                raise ValueError(f"sep({self.labels[i]},{self.labels[i]}) != 0")
        for i in range(n):
            for j in range(n):
                if self.sep[i][j] != self.sep[j][i]:
                    raise ValueError(f"Symmetry violated at ({i},{j})")
        for i in range(n):
            for j in range(i + 1, n):
                if self.sep[i][j] <= 0:
                    raise ValueError(f"Non-positive separation for distinct {i},{j}")
        for i in range(n):
            for j in range(n):
                for k in range(n):
                    if self.sep[i][k] > max(self.sep[i][j], self.sep[j][k]):
                        raise ValueError(
                            f"Ultrametric violated: sep({i},{k})={self.sep[i][k]} > "
                            f"max(sep({i},{j})={self.sep[i][j]}, sep({j},{k})={self.sep[j][k]})"
                        )
        return True


@dataclass
class LevelPartition:
    """A partition of elements at a given level."""
    level: int
    classes: List[List[int]]  # Each inner list is an equivalence class

    @property
    def num_classes(self) -> int:
        return len(self.classes)

    def class_of(self, elem: int) -> int:
        """Return the class index containing elem."""
        for idx, cls in enumerate(self.classes):
            if elem in cls:
                return idx
        raise ValueError(f"Element {elem} not found in any class")


@dataclass
class PrimeCongruenceCode:
    """A canonical code realization of an observer system.

    Each observer gets a code tuple: its equivalence class index at each level.
    Two observers agree at level n iff sep(x,y) ≤ n.
    """
    n_elements: int
    max_level: int
    codes: Dict[int, Tuple[int, ...]]  # element -> code tuple
    partitions: Dict[int, LevelPartition]  # level -> partition


def compute_level_partition(sys: FiniteObserverSystem, level: int) -> LevelPartition:
    """Compute the partition at a given level using union-find.

    levelRel(n, x, y) iff sep(x,y) ≤ n.

    Time: O(n²α(n)) with union-find, simplified to O(n²) here.
    Space: O(n)
    """
    n = sys.n
    parent = list(range(n))
    rank = [0] * n

    def find(x: int) -> int:
        while parent[x] != x:
            parent[x] = parent[parent[x]]  # path compression
            x = parent[x]
        return x

    def union(x: int, y: int):
        rx, ry = find(x), find(y)
        if rx == ry:
            return
        if rank[rx] < rank[ry]:
            rx, ry = ry, rx
        parent[ry] = rx
        if rank[rx] == rank[ry]:
            rank[rx] += 1

    for i in range(n):
        for j in range(i + 1, n):
            if sys.sep[i][j] <= level:
                union(i, j)

    # Extract classes
    class_map: Dict[int, List[int]] = defaultdict(list)
    for i in range(n):
        class_map[find(i)].append(i)

    return LevelPartition(level=level, classes=list(class_map.values()))


def build_canonical_code(sys: FiniteObserverSystem) -> PrimeCongruenceCode:
    """Construct the canonical prime-congruence code.

    For each element, the code is the tuple of its equivalence class index
    at each level from 0 to max_sep.

    Time: O(n² · L) where L = max_sep
    Space: O(n · L)

    The key property (canonicalCode_correct):
        code(x)[level] == code(y)[level]  iff  sep(x,y) ≤ level
    """
    max_level = sys.max_sep
    partitions = {}
    codes: Dict[int, List[int]] = {i: [] for i in range(sys.n)}

    for level in range(max_level + 1):
        part = compute_level_partition(sys, level)
        partitions[level] = part
        for i in range(sys.n):
            codes[i].append(part.class_of(i))

    return PrimeCongruenceCode(
        n_elements=sys.n,
        max_level=max_level,
        codes={i: tuple(c) for i, c in codes.items()},
        partitions=partitions,
    )


def verify_code_faithfulness(sys: FiniteObserverSystem, code: PrimeCongruenceCode) -> bool:
    """Verify that a code is faithful: code agreement at level n ↔ sep ≤ n.

    Time: O(n² · L)
    """
    for i in range(sys.n):
        for j in range(i + 1, sys.n):
            for level in range(code.max_level + 1):
                code_agree = code.codes[i][level] == code.codes[j][level]
                sep_ok = sys.sep[i][j] <= level
                if code_agree != sep_ok:
                    return False
    return True


def reconstruct_sep_from_code(code: PrimeCongruenceCode) -> List[List[int]]:
    """Reconstruct the separation matrix from a canonical code.

    sep(x,y) = min{n : code(x)[n] == code(y)[n]}

    This implements the reconstruction theorem: the code uniquely
    determines the separation.

    Time: O(n² · L)
    Space: O(n²)
    """
    n = code.n_elements
    sep = [[0] * n for _ in range(n)]

    for i in range(n):
        for j in range(i + 1, n):
            for level in range(code.max_level + 1):
                if code.codes[i][level] == code.codes[j][level]:
                    sep[i][j] = level
                    sep[j][i] = level
                    break
            else:
                sep[i][j] = code.max_level + 1
                sep[j][i] = code.max_level + 1

    return sep


def extract_dendrogram(sys: FiniteObserverSystem) -> List[Tuple[int, List[int], List[int]]]:
    """Extract the dendrogram (merge history) from an observer system.

    Returns a list of (merge_level, cluster_A, cluster_B) triples,
    ordered by merge level.

    Time: O(n² · L)
    """
    merges = []
    prev_partition = compute_level_partition(sys, 0)

    for level in range(1, sys.max_sep + 1):
        curr_partition = compute_level_partition(sys, level)

        # Find which classes merged
        for curr_cls in curr_partition.classes:
            # Find all previous classes that are subsets of this class
            prev_parts = []
            for prev_cls in prev_partition.classes:
                if set(prev_cls).issubset(set(curr_cls)):
                    prev_parts.append(prev_cls)

            if len(prev_parts) > 1:
                # A merge happened
                for i in range(1, len(prev_parts)):
                    merges.append((level, prev_parts[0], prev_parts[i]))
                    # Update the "base" for further merges at this level
                    prev_parts[0] = prev_parts[0] + prev_parts[i]

        prev_partition = curr_partition

    return merges


def generate_random_ultrametric(n: int, max_levels: int = 10, seed: int = 42) -> FiniteObserverSystem:
    """Generate a random ultrametric space via random dendrogram construction.

    Algorithm:
    1. Start with n singleton clusters
    2. At each level, randomly merge some pairs of clusters
    3. Set sep(x,y) = level for newly merged elements
    4. Continue until single cluster remains

    Time: O(n²)
    Space: O(n²)
    """
    import random
    rng = random.Random(seed)

    clusters = [[i] for i in range(n)]
    sep = [[0] * n for _ in range(n)]
    level = 0

    while len(clusters) > 1:
        level += 1
        if level > max_levels:
            # Force merge all remaining
            all_elems = [e for c in clusters for e in c]
            for a in all_elems:
                for b in all_elems:
                    if sep[a][b] == 0 and a != b:
                        sep[a][b] = level
                        sep[b][a] = level
            break

        rng.shuffle(clusters)
        new_clusters = []
        i = 0
        while i < len(clusters):
            if i + 1 < len(clusters) and rng.random() < 0.4:
                merged = clusters[i] + clusters[i + 1]
                for a in clusters[i]:
                    for b in clusters[i + 1]:
                        sep[a][b] = level
                        sep[b][a] = level
                new_clusters.append(merged)
                i += 2
            else:
                new_clusters.append(clusters[i])
                i += 1
        clusters = new_clusters

    labels = [f"O_{i}" for i in range(n)]
    return FiniteObserverSystem(labels=labels, sep=sep)


# ─────────────────────────────────────────────────────────────
# Example usage
# ─────────────────────────────────────────────────────────────
if __name__ == "__main__":
    # Phylogenetic example
    sys = FiniteObserverSystem(
        labels=["Human", "Chimp", "Gorilla", "Dog", "Cat"],
        sep=[
            [0, 1, 2, 4, 4],
            [1, 0, 2, 4, 4],
            [2, 2, 0, 4, 4],
            [4, 4, 4, 0, 3],
            [4, 4, 4, 3, 0],
        ]
    )

    print("Verifying ultrametric axioms...")
    sys.verify()
    print("✓ Valid ultrametric")

    print("\nBuilding canonical code...")
    code = build_canonical_code(sys)
    for i, label in enumerate(sys.labels):
        print(f"  {label}: {code.codes[i]}")

    print("\nVerifying faithfulness...")
    assert verify_code_faithfulness(sys, code)
    print("✓ Code is faithful")

    print("\nReconstructing separation from code...")
    reconstructed = reconstruct_sep_from_code(code)
    assert reconstructed == sys.sep
    print("✓ Reconstruction matches original")

    print("\nDendrogram merges:")
    merges = extract_dendrogram(sys)
    for level, a, b in merges:
        a_names = [sys.labels[i] for i in a]
        b_names = [sys.labels[i] for i in b]
        print(f"  Level {level}: {a_names} ∪ {b_names}")

    print("\nGenerating random 12-point ultrametric...")
    rand_sys = generate_random_ultrametric(12, seed=123)
    rand_sys.verify()
    rand_code = build_canonical_code(rand_sys)
    assert verify_code_faithfulness(rand_sys, rand_code)
    reconstructed2 = reconstruct_sep_from_code(rand_code)
    assert reconstructed2 == rand_sys.sep
    print("✓ Random system: verified, coded, and reconstructed successfully")

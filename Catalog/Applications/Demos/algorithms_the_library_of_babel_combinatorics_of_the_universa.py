#!/usr/bin/env python3
"""
Algorithms for the Babel Graded Graph.

Type-hinted implementations of the key algorithms from the research:
shell enumeration, graded graph construction, conservation verification,
sphere-packing bounds, and catalog collision analysis.
"""

from math import comb, log, log2, ceil
from typing import Iterator, NamedTuple
from itertools import combinations, product as iterproduct


class ShellInfo(NamedTuple):
    """Information about a single Hamming shell."""
    distance: int
    size: int
    trans_up: int
    trans_down: int
    expansion_ratio: float


class BabelGradedGraph(NamedTuple):
    """The Babel Graded Graph structure."""
    alphabet_size: int
    volume_length: int
    shells: list[ShellInfo]
    library_size: int


def shell_size(A: int, L: int, k: int) -> int:
    """Compute the size of the k-th Hamming shell: C(L,k) * (A-1)^k.

    Args:
        A: Alphabet size (≥ 1)
        L: Volume length (≥ 0)
        k: Shell index (0 ≤ k ≤ L)

    Returns:
        Number of volumes at Hamming distance exactly k from any reference.
    """
    if k < 0 or k > L:
        return 0
    return comb(L, k) * (A - 1) ** k


def trans_up(A: int, L: int, k: int) -> int:
    """Upward transition multiplicity: (L - k) * (A - 1).

    From a volume in shell k, the number of single-character changes
    that increase the Hamming distance by 1.
    """
    if k >= L:
        return 0
    return (L - k) * (A - 1)


def trans_down(k: int) -> int:
    """Downward transition multiplicity: k.

    From a volume in shell k, the number of single-character changes
    that decrease the Hamming distance by 1.
    """
    return k


def expansion_ratio(A: int, L: int, k: int) -> float:
    """The expansion ratio from shell k to shell k+1.

    Equals (L - k) * (A - 1) / (k + 1).
    When > 1, shells are growing; when < 1, shells are shrinking.
    """
    return (L - k) * (A - 1) / (k + 1)


def build_babel_graded_graph(A: int, L: int) -> BabelGradedGraph:
    """Construct the complete Babel Graded Graph.

    Args:
        A: Alphabet size (≥ 2)
        L: Volume length (≥ 1)

    Returns:
        BabelGradedGraph with all shell information.
    """
    shells = []
    for k in range(L + 1):
        shells.append(ShellInfo(
            distance=k,
            size=shell_size(A, L, k),
            trans_up=trans_up(A, L, k),
            trans_down=trans_down(k),
            expansion_ratio=expansion_ratio(A, L, k) if k < L else 0.0
        ))
    return BabelGradedGraph(
        alphabet_size=A,
        volume_length=L,
        shells=shells,
        library_size=A ** L
    )


def verify_conservation(G: BabelGradedGraph) -> list[tuple[int, bool]]:
    """Verify the detailed balance (conservation) law for all shell pairs.

    Returns list of (k, valid) pairs where valid indicates whether
    shellSize(k) * transUp(k) == shellSize(k+1) * transDown(k+1).
    """
    results = []
    for k in range(G.volume_length):
        s_k = G.shells[k]
        s_k1 = G.shells[k + 1]
        lhs = s_k.size * s_k.trans_up
        rhs = s_k1.size * s_k1.trans_down
        results.append((k, lhs == rhs))
    return results


def verify_partition(G: BabelGradedGraph) -> bool:
    """Verify that shell sizes sum to library size (binomial theorem)."""
    return sum(s.size for s in G.shells) == G.library_size


def hamming_ball_size(A: int, L: int, r: int) -> int:
    """Size of Hamming ball of radius r: sum of shell sizes 0..r."""
    return sum(shell_size(A, L, k) for k in range(min(r, L) + 1))


def sphere_packing_bound(A: int, L: int, min_dist: int) -> int:
    """Maximum code size by the sphere-packing (Hamming) bound.

    For a code with minimum distance d, packing radius is floor((d-1)/2).
    """
    r = (min_dist - 1) // 2
    ball = hamming_ball_size(A, L, r)
    if ball == 0:
        return A ** L
    return A ** L // ball


def catalog_collision_bound(A: int, L: int, D: int) -> int:
    """Lower bound on the largest fiber of any D-valued catalog.

    By the pigeonhole principle, some label must be shared by
    at least ceil(A^L / D) volumes.
    """
    return ceil(A ** L / D)


def equator_distance(A: int, L: int) -> int:
    """The shell index where expansion ratio drops below 1.

    This is approximately L * (A-1) / A.
    """
    for k in range(L + 1):
        if expansion_ratio(A, L, k) < 1:
            return k
    return L


def enumerate_shell(
    A: int, L: int, k: int, ref: tuple[int, ...]
) -> Iterator[tuple[int, ...]]:
    """Enumerate all volumes at Hamming distance k from a reference.

    Yields each volume as a tuple of integers in range(A).

    Args:
        A: Alphabet size
        L: Volume length
        k: Target Hamming distance
        ref: Reference volume as tuple of length L
    """
    for positions in combinations(range(L), k):
        # For each choice of k positions to change
        for offsets in iterproduct(range(1, A), repeat=k):
            # For each choice of non-zero offsets
            vol = list(ref)
            for pos, offset in zip(positions, offsets):
                vol[pos] = (ref[pos] + offset) % A
            yield tuple(vol)


def hamming_distance(v: tuple[int, ...], w: tuple[int, ...]) -> int:
    """Compute the Hamming distance between two volumes."""
    return sum(1 for a, b in zip(v, w) if a != b)


def entropy_bits(A: int, L: int) -> float:
    """Information content of the Library in bits: L * log2(A)."""
    return L * log2(A)


def catalog_info_loss(A: int, L: int, D: int) -> float:
    """Information lost per volume when using D labels, in bits.

    Each volume has L * log2(A) bits; after labeling, only log2(D) bits
    remain. The loss is L * log2(A) - log2(D).
    """
    return L * log2(A) - log2(D)


if __name__ == "__main__":
    # Quick verification
    G = build_babel_graded_graph(4, 16)
    assert verify_partition(G), "Partition verification failed"
    conserv = verify_conservation(G)
    assert all(v for _, v in conserv), "Conservation verification failed"
    print(f"Babel Graded Graph (A=4, L=16):")
    print(f"  Library size: {G.library_size:,}")
    print(f"  Shells: {len(G.shells)}")
    print(f"  Partition verified: ✓")
    print(f"  Conservation verified: ✓ ({len(conserv)} checks)")
    print(f"  Equator at shell: {equator_distance(4, 16)}")
    print(f"  Sphere-packing bound (d=3): {sphere_packing_bound(4, 16, 3):,}")
    print(f"  Information content: {entropy_bits(4, 16):.1f} bits")

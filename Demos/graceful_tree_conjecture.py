#!/usr/bin/env python3
"""Numerical demonstrations for graceful paths, stars, and edge partitions."""

from __future__ import annotations

from collections import Counter
from dataclasses import dataclass
from typing import Hashable, Iterable, Sequence, TypeVar

Vertex = TypeVar("Vertex", bound=Hashable)
Edge = tuple[int, int]


@dataclass(frozen=True)
class GracefulCertificate:
    """A labeling together with its ordered edge differences."""

    graph: str
    edge_count: int
    labels: tuple[int, ...]
    differences: tuple[int, ...]

    @property
    def is_graceful(self) -> bool:
        """Return whether the data satisfy the graceful-labeling conditions."""
        n = self.edge_count
        return (
            len(self.labels) == n + 1
            and len(set(self.labels)) == len(self.labels)
            and all(0 <= label <= n for label in self.labels)
            and sorted(self.differences) == list(range(1, n + 1))
        )


def path_label(n: int, position: int) -> int:
    """Return the alternating graceful label at a path position."""
    if n < 0 or not 0 <= position <= n:
        raise ValueError("Require n >= 0 and 0 <= position <= n.")
    return position // 2 if position % 2 == 0 else n - position // 2


def graceful_path(n: int) -> GracefulCertificate:
    """Construct and certify the standard graceful labeling of an n-edge path."""
    if n < 0:
        raise ValueError("The number of edges must be nonnegative.")
    labels = tuple(path_label(n, i) for i in range(n + 1))
    differences = tuple(abs(labels[i + 1] - labels[i]) for i in range(n))
    return GracefulCertificate("path", n, labels, differences)


def graceful_star(n: int) -> GracefulCertificate:
    """Label a star center by zero and its n leaves by 1 through n."""
    if n < 0:
        raise ValueError("The number of leaves must be nonnegative.")
    labels = tuple(range(n + 1))  # center first, followed by leaves
    differences = tuple(abs(labels[j] - labels[0]) for j in range(1, n + 1))
    return GracefulCertificate("star", n, labels, differences)


def normalize_edge(u: int, v: int) -> Edge:
    """Represent an undirected loop-free edge canonically."""
    if u == v:
        raise ValueError("Simple graphs do not contain loops.")
    return (u, v) if u < v else (v, u)


def complete_graph_edges(order: int) -> set[Edge]:
    """Return the edge set of the complete graph on vertices 0 through order-1."""
    if order < 0:
        raise ValueError("The graph order must be nonnegative.")
    return {(u, v) for u in range(order) for v in range(u + 1, order)}


def audit_edge_partition(
    host_edges: set[Edge], pieces: Sequence[Iterable[Edge]], expected_size: int
) -> tuple[bool, Counter[Edge]]:
    """Check containment, equal piece size, exact coverage, and uniqueness."""
    if expected_size < 0:
        raise ValueError("Expected piece size must be nonnegative.")
    normalized_pieces: list[set[Edge]] = []
    for piece in pieces:
        normalized = {normalize_edge(*edge) for edge in piece}
        normalized_pieces.append(normalized)
    counts: Counter[Edge] = Counter(
        edge for piece in normalized_pieces for edge in piece
    )
    valid = (
        all(len(piece) == expected_size for piece in normalized_pieces)
        and all(piece <= host_edges for piece in normalized_pieces)
        and set(counts) == host_edges
        and all(counts[edge] == 1 for edge in host_edges)
        and len(host_edges) == len(normalized_pieces) * expected_size
    )
    return valid, counts


def triangle_partition_example() -> tuple[set[Edge], list[set[Edge]]]:
    """Partition the six edges of K4 into three two-edge pieces."""
    host = complete_graph_edges(4)
    pieces = [
        {normalize_edge(0, 1), normalize_edge(0, 2)},
        {normalize_edge(0, 3), normalize_edge(1, 2)},
        {normalize_edge(1, 3), normalize_edge(2, 3)},
    ]
    return host, pieces


def print_certificate(certificate: GracefulCertificate) -> None:
    """Print a compact numerical certificate."""
    print(f"{certificate.graph.title()} with {certificate.edge_count} edges")
    print(f"  labels:      {list(certificate.labels)}")
    print(f"  differences: {list(certificate.differences)}")
    print(f"  graceful:    {certificate.is_graceful}")


def main() -> None:
    """Run representative path, star, and partition demonstrations."""
    for n in (0, 1, 7, 12):
        print_certificate(graceful_path(n))
    print()
    for n in (0, 1, 7, 12):
        print_certificate(graceful_star(n))

    print("\nExact edge-partition demonstration")
    host, pieces = triangle_partition_example()
    valid, counts = audit_edge_partition(host, pieces, expected_size=2)
    print(f"  host edges: {len(host)}")
    print(f"  pieces: {len(pieces)} of size 2")
    print(f"  counting identity: {len(host)} = {len(pieces)} * 2")
    print(f"  exact partition: {valid}")
    print(f"  occurrence counts: {dict(sorted(counts.items()))}")

    assert all(graceful_path(n).is_graceful for n in range(101))
    assert all(graceful_star(n).is_graceful for n in range(101))
    assert valid
    print("\nAll demonstrations and bounded checks passed.")


if __name__ == "__main__":
    main()

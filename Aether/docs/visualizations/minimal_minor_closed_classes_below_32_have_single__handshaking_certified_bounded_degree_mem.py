"""Handshaking-Certified Bounded-Degree Membership Test.

Mirrors `maxDegree_mono`, `boundedDegreeClass_minorClosed`, and
`edgeFinset_card_le_of_maxDegree_two`.
"""
from __future__ import annotations

from typing import Dict, FrozenSet, Sequence, Tuple

Edge = FrozenSet[int]


def degrees(vertex_count: int, edges: Sequence[Edge]) -> Dict[int, int]:
    deg: Dict[int, int] = {v: 0 for v in range(vertex_count)}
    for e in edges:
        for v in e:
            deg[v] += 1
    return deg


def max_degree(vertex_count: int, edges: Sequence[Edge]) -> int:
    deg = degrees(vertex_count, edges)
    return max(deg.values(), default=0)


def bounded_degree_certificate(
    vertex_count: int, edges: Sequence[Edge], d: int
) -> Tuple[int, bool]:
    """Return (Delta, member_of_D_d). For d == 2 a member additionally satisfies
    the certified handshaking bound |E| <= |V|. Runs in O(|V| + |E|)."""
    deg = degrees(vertex_count, edges)
    delta = max(deg.values(), default=0)
    # Handshaking identity: sum of degrees equals twice the edge count.
    assert sum(deg.values()) == 2 * len(edges)
    member = delta <= d
    if d == 2 and member:
        assert len(edges) <= vertex_count  # certified bound |E| <= |V|
    return delta, member


if __name__ == "__main__":
    c5 = [frozenset((i, (i + 1) % 5)) for i in range(5)]
    print(bounded_degree_certificate(5, c5, 2))  # (2, True)

#!/usr/bin/env python3
"""Numerical demonstrations of rooted and ordinary P3 path irregularity."""
from __future__ import annotations

from dataclasses import dataclass
from typing import Dict, Iterable, List, Sequence, Set, Tuple

Edge = Tuple[int, int]


@dataclass(frozen=True)
class P3Profiles:
    degrees: List[int]
    central: List[int]
    end: List[int]
    ordinary: List[int]


def adjacency_lists(vertex_count: int, edges: Iterable[Edge]) -> List[Set[int]]:
    """Build validated adjacency sets for a finite simple graph."""
    adjacency: List[Set[int]] = [set() for _ in range(vertex_count)]
    for u, v in edges:
        if not (0 <= u < vertex_count and 0 <= v < vertex_count):
            raise ValueError("edge endpoint outside the vertex set")
        if u == v:
            raise ValueError("loops are not allowed")
        if v in adjacency[u]:
            raise ValueError("parallel edges are not allowed")
        adjacency[u].add(v)
        adjacency[v].add(u)
    return adjacency


def p3_profiles(vertex_count: int, edges: Iterable[Edge]) -> P3Profiles:
    """Compute degree, center-rooted, end-rooted, and ordinary P3 profiles."""
    adjacency = adjacency_lists(vertex_count, edges)
    degree = [len(neighbors) for neighbors in adjacency]
    central = [d * (d - 1) // 2 for d in degree]
    end = [sum(degree[u] - 1 for u in adjacency[v]) for v in range(vertex_count)]
    ordinary = [central[v] + end[v] for v in range(vertex_count)]
    return P3Profiles(degree, central, end, ordinary)


def is_injective(values: Sequence[int]) -> bool:
    return len(values) == len(set(values))


def affine_profiles(
    intercepts: Sequence[Sequence[int]], slopes: Sequence[Sequence[int]], t: int
) -> List[List[int]]:
    """Evaluate a finite family of affine profiles c[i][v] + t*m[i][v]."""
    if len(intercepts) != len(slopes):
        raise ValueError("intercept and slope families must have the same size")
    result: List[List[int]] = []
    for c_row, m_row in zip(intercepts, slopes):
        if len(c_row) != len(m_row):
            raise ValueError("each intercept row must match its slope row")
        if any(x < 0 for x in (*c_row, *m_row)) or t < 0:
            raise ValueError("profiles are defined here over nonnegative integers")
        result.append([c + t * m for c, m in zip(c_row, m_row)])
    return result


def affine_separation_certificate(
    intercepts: Sequence[Sequence[int]], slopes: Sequence[Sequence[int]]
) -> Tuple[int, bool]:
    """Return the threshold B+1 and whether every slope row is injective."""
    if not intercepts or not all(intercepts):
        raise ValueError("at least one nonempty profile is required")
    if len(intercepts) != len(slopes):
        raise ValueError("intercept and slope families must have the same size")
    for c_row, m_row in zip(intercepts, slopes):
        if len(c_row) != len(m_row):
            raise ValueError("row lengths must match")
        if any(x < 0 for x in (*c_row, *m_row)):
            raise ValueError("coefficients must be nonnegative")
    bound = max(max(row) for row in intercepts)
    return bound + 1, all(is_injective(row) for row in slopes)


def compensation_pairs(profiles: P3Profiles) -> List[Tuple[int, int]]:
    """List equal-degree pairs with equal central and unequal end counts."""
    pairs: List[Tuple[int, int]] = []
    n = len(profiles.degrees)
    for v in range(n):
        for w in range(v + 1, n):
            if (profiles.degrees[v] == profiles.degrees[w]
                    and profiles.central[v] == profiles.central[w]
                    and profiles.end[v] != profiles.end[w]):
                pairs.append((v, w))
    return pairs


def run_six_vertex_demo() -> None:
    edges = [(0, 2), (0, 3), (0, 5), (1, 2), (1, 4), (2, 3)]
    p = p3_profiles(6, edges)
    print("Six-vertex boundary example")
    print("degrees: ", p.degrees)
    print("central: ", p.central)
    print("end:     ", p.end)
    print("ordinary:", p.ordinary)
    print("ordinary injective:", is_injective(p.ordinary))
    print("end injective:     ", is_injective(p.end))
    print("compensating equal-degree pairs:", compensation_pairs(p))
    assert p.degrees == [3, 2, 3, 2, 1, 1]
    assert p.central == [3, 1, 3, 1, 0, 0]
    assert p.end == [3, 2, 4, 4, 1, 2]
    assert p.ordinary == [6, 3, 7, 5, 1, 2]
    assert is_injective(p.ordinary) and not is_injective(p.end)


def run_affine_demo() -> None:
    intercepts = [[5, 0, 4], [0, 5, 2]]
    slopes = [[0, 1, 2], [3, 1, 2]]
    threshold, certified = affine_separation_certificate(intercepts, slopes)
    at_boundary = affine_profiles(intercepts, slopes, threshold - 1)
    above_boundary = affine_profiles(intercepts, slopes, threshold)
    print("\nSimultaneous affine separation")
    print("certified:", certified, "first universally certified parameter:", threshold)
    print("at boundary t=5:", at_boundary,
          "injective rows:", [is_injective(row) for row in at_boundary])
    print("above bound t=6:", above_boundary,
          "injective rows:", [is_injective(row) for row in above_boundary])
    assert certified and threshold == 6
    assert not is_injective(at_boundary[0])
    assert all(is_injective(row) for row in above_boundary)


def run_degree_collision_demo() -> None:
    edges = [(0, 2), (0, 3), (0, 5), (1, 2), (1, 4), (2, 3)]
    p = p3_profiles(6, edges)
    print("\nDegree-collision audit")
    for v, w in compensation_pairs(p):
        print(f"vertices {v},{w}: degree={p.degrees[v]}, "
              f"central={p.central[v]}, end={p.end[v]} vs {p.end[w]}")
    assert compensation_pairs(p) == [(0, 2), (1, 3), (4, 5)]


if __name__ == "__main__":
    run_six_vertex_demo()
    run_affine_demo()
    run_degree_collision_demo()

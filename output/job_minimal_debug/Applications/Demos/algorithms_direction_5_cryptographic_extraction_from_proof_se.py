#!/usr/bin/env python3
"""
Algorithms for Proof-Search One-Way Function Theory

Implements the core algorithms from the research paper:
1. Walk counting (recursive and DP)
2. Obstructed walk counting
3. Walk verification
4. Density estimation
5. Proof architecture analysis
"""

from dataclasses import dataclass, field
from typing import Dict, List, Optional, Set, Tuple
import random


@dataclass
class ProofArchitecture:
    """A proof architecture: directed graph with source and target.

    Attributes:
        graph: Adjacency list representation (vertex -> list of neighbors)
        source: Source vertex
        target: Target vertex
    """
    graph: Dict[int, List[int]]
    source: int
    target: int

    @property
    def vertices(self) -> Set[int]:
        return set(self.graph.keys())

    @property
    def branch_bound(self) -> int:
        """Maximum out-degree B."""
        return max(len(self.graph[v]) for v in self.graph) if self.graph else 0

    def degree(self, v: int) -> int:
        return len(self.graph.get(v, []))

    def is_obstructed(self, v: int, rho: int) -> bool:
        return self.degree(v) <= rho

    def obstruction_set(self, rho: int) -> Set[int]:
        return {v for v in self.graph if self.is_obstructed(v, rho)}

    def obstruction_density(self, rho: int) -> float:
        n = len(self.graph)
        return len(self.obstruction_set(rho)) / n if n > 0 else 0.0


def walk_count_recursive(graph: Dict[int, List[int]], s: int, n: int) -> int:
    """Recursive walk count (matches the Lean definition).

    walkCount(E, s, 0) = 1
    walkCount(E, s, n+1) = Σ_{v ∈ E(s)} walkCount(E, v, n)

    Time: O(B^n) — exponential, use DP for efficiency.
    """
    if n == 0:
        return 1
    return sum(walk_count_recursive(graph, v, n - 1) for v in graph.get(s, []))


def walk_count_dp(
    graph: Dict[int, List[int]], s: int, n: int
) -> Dict[int, int]:
    """Walk count via dynamic programming.

    Returns dict mapping terminal vertex to count of walks ending there.
    Time: O(n · |E|), Space: O(|V|).
    """
    current = {v: 0 for v in graph}
    current[s] = 1
    for _ in range(n):
        next_count = {v: 0 for v in graph}
        for u, cnt in current.items():
            if cnt > 0:
                for v in graph.get(u, []):
                    next_count[v] += cnt
        current = next_count
    return current


def total_walk_count(graph: Dict[int, List[int]], s: int, n: int) -> int:
    """Total number of walks of length n from s."""
    return sum(walk_count_dp(graph, s, n).values())


def obstructed_walk_count_recursive(
    graph: Dict[int, List[int]], rho: int, s: int, n: int, k: int
) -> int:
    """Recursive obstructed walk count (matches the Lean definition).

    Time: exponential — use DP version for efficiency.
    """
    if k == 0:
        return walk_count_recursive(graph, s, n)
    if n == 0:
        return 0
    is_obs = len(graph.get(s, [])) <= rho
    new_k = k - 1 if is_obs else k
    return sum(
        obstructed_walk_count_recursive(graph, rho, v, n - 1, new_k)
        for v in graph.get(s, [])
    )


def obstructed_walk_count_dp(
    graph: Dict[int, List[int]], rho: int, s: int, n: int, min_k: int
) -> int:
    """Count walks from s of length n with ≥ min_k obstructed vertices.

    Uses DP tracking (vertex, obstruction_count) pairs.
    Time: O(n^2 · |E|), Space: O(n · |V|).
    """
    # State: (vertex, obs_count) -> walk count
    current: Dict[Tuple[int, int], int] = {(s, 0): 1}
    for step in range(n):
        next_state: Dict[Tuple[int, int], int] = {}
        for (u, obs), cnt in current.items():
            if cnt == 0:
                continue
            is_obs = len(graph.get(u, [])) <= rho
            new_obs = obs + (1 if is_obs else 0)
            for v in graph.get(u, []):
                key = (v, new_obs)
                next_state[key] = next_state.get(key, 0) + cnt
        current = next_state
    return sum(cnt for (_, obs), cnt in current.items() if obs >= min_k)


def obstructed_walk_count_by_target(
    graph: Dict[int, List[int]], rho: int, s: int, t: int, n: int, min_k: int
) -> int:
    """Count walks from s to t of length n with ≥ min_k obstructions."""
    current: Dict[Tuple[int, int], int] = {(s, 0): 1}
    for step in range(n):
        next_state: Dict[Tuple[int, int], int] = {}
        for (u, obs), cnt in current.items():
            if cnt == 0:
                continue
            is_obs = len(graph.get(u, [])) <= rho
            new_obs = obs + (1 if is_obs else 0)
            for v in graph.get(u, []):
                key = (v, new_obs)
                next_state[key] = next_state.get(key, 0) + cnt
        current = next_state
    return sum(cnt for (v, obs), cnt in current.items() if v == t and obs >= min_k)


def verify_walk(
    graph: Dict[int, List[int]], s: int, t: int, walk: List[int]
) -> bool:
    """Verify a walk is valid: starts at s, ends at t, follows edges.

    Time: O(n), Space: O(1).
    This is the "easy verification" half of the one-wayness surrogate.
    """
    if not walk or walk[0] != s or walk[-1] != t:
        return False
    for i in range(len(walk) - 1):
        if walk[i + 1] not in graph.get(walk[i], []):
            return False
    return True


def walk_obstruction_count(
    graph: Dict[int, List[int]], rho: int, walk: List[int]
) -> int:
    """Count obstructed steps in a walk.

    Step i is obstructed if deg(walk[i]) ≤ ρ.
    Time: O(n).
    """
    count = 0
    for i in range(len(walk) - 1):
        if len(graph.get(walk[i], [])) <= rho:
            count += 1
    return count


def density_bound(B: int, rho: int, k: int) -> float:
    """Compute the theoretical density bound (ρ/B)^k.

    This is the maximum fraction of valid walks among all B^n candidates.
    """
    if B == 0:
        return 0.0
    return (rho / B) ** k


def empirical_density(
    graph: Dict[int, List[int]], s: int, t: int, n: int, rho: int, min_k: int
) -> Tuple[float, int, int]:
    """Compute empirical density of valid walks.

    Returns (density, valid_count, total_count).
    """
    B = max(len(graph[v]) for v in graph) if graph else 1
    total = B ** n
    valid = obstructed_walk_count_by_target(graph, rho, s, t, n, min_k)
    return valid / total if total > 0 else 0.0, valid, total


@dataclass
class ArchitectureAnalysis:
    """Complete analysis of a proof architecture."""
    architecture: ProofArchitecture
    walk_length: int
    rho: int
    branch_bound: int = 0
    total_walks: int = 0
    obstruction_density_value: float = 0.0
    density_by_k: Dict[int, float] = field(default_factory=dict)
    bounds_by_k: Dict[int, float] = field(default_factory=dict)

    def analyze(self) -> "ArchitectureAnalysis":
        """Run complete analysis."""
        A = self.architecture
        self.branch_bound = A.branch_bound
        self.total_walks = total_walk_count(A.graph, A.source, self.walk_length)
        self.obstruction_density_value = A.obstruction_density(self.rho)

        for k in range(self.walk_length + 1):
            valid = obstructed_walk_count_by_target(
                A.graph, self.rho, A.source, A.target,
                self.walk_length, k
            )
            ambient = self.branch_bound ** self.walk_length
            self.density_by_k[k] = valid / ambient if ambient > 0 else 0
            self.bounds_by_k[k] = density_bound(self.branch_bound, self.rho, k)
        return self

    def summary(self) -> str:
        """Generate human-readable summary."""
        lines = [
            f"Proof Architecture Analysis",
            f"  Vertices: {len(self.architecture.graph)}",
            f"  Branch bound B: {self.branch_bound}",
            f"  Obstruction threshold ρ: {self.rho}",
            f"  Obstruction density: {self.obstruction_density_value:.2%}",
            f"  Walk length n: {self.walk_length}",
            f"  Total walks: {self.total_walks:,}",
            f"  Ambient space B^n: {self.branch_bound**self.walk_length:,}",
            f"",
            f"  {'k':>3} | {'Empirical':>12} | {'Bound':>12} | {'OK':>3}",
            f"  {'-'*40}",
        ]
        for k in sorted(self.density_by_k.keys()):
            emp = self.density_by_k[k]
            bnd = self.bounds_by_k[k]
            ok = "✓" if emp <= bnd + 1e-12 else "✗"
            lines.append(f"  {k:>3} | {emp:>12.2e} | {bnd:>12.2e} | {ok:>3}")
        return "\n".join(lines)


def generate_proof_architecture(
    n_vertices: int, B: int, rho: int, obstruction_frac: float,
    source: int = 0, target: int = -1, seed: int = 42
) -> ProofArchitecture:
    """Generate a random proof architecture with controlled obstructions."""
    if target < 0:
        target = n_vertices - 1
    rng = random.Random(seed)
    n_obstructed = int(n_vertices * obstruction_frac)
    obstructed = set(rng.sample(range(n_vertices), n_obstructed))
    graph: Dict[int, List[int]] = {}
    for v in range(n_vertices):
        if v in obstructed:
            deg = rng.randint(1, min(rho, n_vertices))
        else:
            deg = rng.randint(max(rho + 1, 1), min(B, n_vertices))
        neighbors = rng.sample(range(n_vertices), min(deg, n_vertices))
        graph[v] = neighbors
    return ProofArchitecture(graph=graph, source=source, target=target)


if __name__ == "__main__":
    print("=== Proof Architecture Analysis ===\n")
    arch = generate_proof_architecture(
        n_vertices=30, B=5, rho=2, obstruction_frac=0.4, seed=42
    )
    analysis = ArchitectureAnalysis(
        architecture=arch, walk_length=8, rho=2
    ).analyze()
    print(analysis.summary())

#!/usr/bin/env python3
"""
Algorithms for Automated Bridge Discovery

Implements the bridge search algorithm and multi-hop path finding
described in the research paper. Includes:
- Candidate map generation
- Certificate verification
- Bridge graph construction
- Multi-hop path search (BFS)
- Bridge network analysis
"""

from dataclasses import dataclass, field
from typing import Callable, Optional, List, Dict, Set, Tuple
from collections import deque
import itertools


@dataclass
class TheorySpec:
    """A theory specification with carrier ℕ, invariant, witness, and bound."""
    name: str
    inv: Callable[[int], int]
    witness: Callable[[int], bool]
    lower_bound: int

    def check_soundness(self, x: int) -> bool:
        if self.witness(x):
            return self.lower_bound <= self.inv(x)
        return True


@dataclass
class SearchCertificate:
    """A search certificate: candidate map with verified properties."""
    source: TheorySpec
    target: TheorySpec
    map_fn: Callable[[int], int]
    verified: bool = False
    test_range: int = 100  # range of elements tested

    def verify(self, n: int = 100) -> bool:
        """Verify witness preservation and monotonicity on [0, n)."""
        for x in range(n):
            # Check witness preservation
            if self.source.witness(x):
                if not self.target.witness(self.map_fn(x)):
                    self.verified = False
                    return False
            # Check monotonicity
            if self.source.inv(x) > self.target.inv(self.map_fn(x)):
                self.verified = False
                return False
        self.verified = True
        self.test_range = n
        return True


def search_bridge(
    source: TheorySpec,
    target: TheorySpec,
    candidates: Optional[List[Callable[[int], int]]] = None,
    test_range: int = 100
) -> Optional[SearchCertificate]:
    """
    Search for a bridge morphism from source to target.

    Args:
        source: Source theory specification
        target: Target theory specification
        candidates: List of candidate map functions to try
        test_range: Range of natural numbers to test

    Returns:
        A verified SearchCertificate if found, None otherwise

    Complexity: O(|candidates| * test_range) per bridge attempt
    """
    if candidates is None:
        # Default candidates: identity, successor, predecessor, doubling
        candidates = [
            lambda x: x,           # identity
            lambda x: x + 1,       # successor
            lambda x: x + 2,       # +2
            lambda x: 2 * x,       # doubling
            lambda x: x * x,       # squaring
            lambda x: max(0, x-1), # predecessor (truncated)
        ]

    for map_fn in candidates:
        cert = SearchCertificate(source, target, map_fn)
        if cert.verify(test_range):
            return cert

    return None


def build_bridge_graph(
    specs: List[TheorySpec],
    candidates: Optional[List[Callable[[int], int]]] = None,
    test_range: int = 100
) -> Dict[Tuple[str, str], SearchCertificate]:
    """
    Build the complete bridge graph by searching for morphisms
    between all pairs of specifications.

    Args:
        specs: List of theory specifications
        candidates: Candidate maps to try
        test_range: Test range for verification

    Returns:
        Dictionary mapping (source_name, target_name) to certificates

    Complexity: O(n² * |candidates| * test_range)
    """
    graph: Dict[Tuple[str, str], SearchCertificate] = {}

    for s in specs:
        for t in specs:
            if s.name == t.name:
                continue
            cert = search_bridge(s, t, candidates, test_range)
            if cert is not None:
                graph[(s.name, t.name)] = cert

    return graph


def find_path(
    graph: Dict[Tuple[str, str], SearchCertificate],
    source_name: str,
    target_name: str,
    max_hops: int = 5
) -> Optional[List[SearchCertificate]]:
    """
    Find a path of bridges from source to target using BFS.

    Args:
        graph: Bridge graph (edges are certificates)
        source_name: Name of source specification
        target_name: Name of target specification
        max_hops: Maximum number of hops allowed

    Returns:
        List of certificates forming the path, or None if no path exists

    Complexity: O(V + E) where V = #specs, E = #bridges
    """
    if source_name == target_name:
        return []

    # Build adjacency list
    adj: Dict[str, List[Tuple[str, SearchCertificate]]] = {}
    for (s, t), cert in graph.items():
        if s not in adj:
            adj[s] = []
        adj[s].append((t, cert))

    # BFS
    queue: deque = deque([(source_name, [])])
    visited: Set[str] = {source_name}

    while queue:
        current, path = queue.popleft()

        if len(path) >= max_hops:
            continue

        for neighbor, cert in adj.get(current, []):
            if neighbor == target_name:
                return path + [cert]
            if neighbor not in visited:
                visited.add(neighbor)
                queue.append((neighbor, path + [cert]))

    return None


def compose_path(
    path: List[SearchCertificate]
) -> Optional[Callable[[int], int]]:
    """Compose a path of certificates into a single map function."""
    if not path:
        return lambda x: x

    result = path[0].map_fn
    for cert in path[1:]:
        prev = result
        result = lambda x, p=prev, c=cert: c.map_fn(p(x))
    return result


def transport_bound(
    path: List[SearchCertificate],
    x: int
) -> Tuple[int, int, bool]:
    """
    Transport a witness along a path and verify the bound.

    Returns: (final_element, final_invariant, bound_verified)
    """
    if not path:
        return (x, 0, True)

    source = path[0].source
    current = x

    for cert in path:
        current = cert.map_fn(current)

    target = path[-1].target
    final_inv = target.inv(current)
    bound_ok = source.lower_bound <= final_inv

    return (current, final_inv, bound_ok)


def analyze_network(
    specs: List[TheorySpec],
    graph: Dict[Tuple[str, str], SearchCertificate]
) -> Dict:
    """
    Analyze the bridge network: connectivity, reachability, components.
    """
    # Build adjacency list
    adj: Dict[str, Set[str]] = {s.name: set() for s in specs}
    for (s, t) in graph:
        adj[s].add(t)

    # Compute reachability (transitive closure)
    reachability: Dict[str, Set[str]] = {}
    for s in specs:
        visited = set()
        queue = deque([s.name])
        while queue:
            current = queue.popleft()
            if current in visited:
                continue
            visited.add(current)
            for neighbor in adj.get(current, set()):
                queue.append(neighbor)
        reachability[s.name] = visited - {s.name}

    # Statistics
    n = len(specs)
    direct_bridges = len(graph)
    max_possible = n * (n - 1)
    reachable_pairs = sum(len(v) for v in reachability.values())

    return {
        "num_specs": n,
        "direct_bridges": direct_bridges,
        "max_possible_bridges": max_possible,
        "density": direct_bridges / max_possible if max_possible > 0 else 0,
        "reachable_pairs": reachable_pairs,
        "reachability_density": reachable_pairs / max_possible if max_possible > 0 else 0,
        "reachability": {k: sorted(v) for k, v in reachability.items()},
        "adjacency": {k: sorted(v) for k, v in adj.items()},
    }


# ============================================================
# Main demo
# ============================================================

if __name__ == "__main__":
    # Define specifications
    specs = [
        TheorySpec("Height", lambda n: n, lambda n: n >= 1, 1),
        TheorySpec("Cell", lambda n: n * (n + 1), lambda _: True, 0),
        TheorySpec("Dimension", lambda n: n + 1, lambda n: n >= 1, 1),
        TheorySpec("Security", lambda n: n + 2, lambda n: n >= 1, 2),
        TheorySpec("Coding", lambda n: n, lambda n: n >= 1, 1),
        TheorySpec("Collision", lambda n: n, lambda n: n >= 1, 1),
    ]

    print("=" * 70)
    print("ALGORITHM 1: Automated Bridge Discovery")
    print("=" * 70)

    graph = build_bridge_graph(specs, test_range=50)

    print(f"\nDiscovered {len(graph)} bridges:")
    for (s, t), cert in sorted(graph.items()):
        print(f"  {s} → {t} (verified on [0, {cert.test_range}))")

    print("\n" + "=" * 70)
    print("ALGORITHM 2: Multi-Hop Path Search")
    print("=" * 70)

    # Search for paths between all pairs
    for s in specs:
        for t in specs:
            if s.name != t.name:
                path = find_path(graph, s.name, t.name)
                if path:
                    names = [s.name] + [c.target.name for c in path]
                    hops = len(path)
                    print(f"  {s.name} → {t.name}: "
                          f"{' → '.join(names)} ({hops} hop{'s' if hops != 1 else ''})")

    print("\n" + "=" * 70)
    print("ALGORITHM 3: Network Analysis")
    print("=" * 70)

    analysis = analyze_network(specs, graph)
    print(f"\n  Specifications: {analysis['num_specs']}")
    print(f"  Direct bridges: {analysis['direct_bridges']}")
    print(f"  Max possible: {analysis['max_possible_bridges']}")
    print(f"  Density: {analysis['density']:.2%}")
    print(f"  Reachable pairs: {analysis['reachable_pairs']}")
    print(f"  Reachability density: {analysis['reachability_density']:.2%}")

    print("\n  Reachability:")
    for name, reachable in sorted(analysis['reachability'].items()):
        print(f"    {name} can reach: {', '.join(reachable) if reachable else '(none)'}")

    print("\n" + "=" * 70)
    print("ALGORITHM 4: Witness Transport Along Discovered Path")
    print("=" * 70)

    path = find_path(graph, "Coding", "Security")
    if path:
        names = ["Coding"] + [c.target.name for c in path]
        print(f"\n  Path: {' → '.join(names)}")
        print(f"\n  Transport results:")
        for x in range(1, 8):
            elem, inv, ok = transport_bound(path, x)
            print(f"    Code length {x} → element {elem}, "
                  f"invariant {inv}, bound verified: {ok}")

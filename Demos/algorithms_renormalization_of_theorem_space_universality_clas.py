"""
Algorithms for Theorem Space Renormalization: Universality Classes

This module implements the core algorithms for studying universality classes
of mathematical theories through renormalization group flow on proof
dependency hypergraphs.
"""
from __future__ import annotations
from typing import Callable, TypeVar, Generic, Any
from dataclasses import dataclass, field
from collections import Counter
import math

T = TypeVar('T')


@dataclass
class StrictDepthFlow(Generic[T]):
    """A strict depth flow: step function + depth measure.
    
    The depth measure strictly decreases at non-fixed points,
    guaranteeing convergence to a fixed point.
    """
    step: Callable[[T], T]
    depth: Callable[[T], int]
    
    def iterate(self, x: T, n: int) -> T:
        """Apply step function n times."""
        result = x
        for _ in range(n):
            result = self.step(result)
        return result
    
    def find_fixed_point(self, x: T) -> tuple[T, int]:
        """Find the fixed point reached from x and the number of steps."""
        current = x
        steps = 0
        while True:
            next_val = self.step(current)
            if next_val == current:
                return current, steps
            current = next_val
            steps += 1
            if steps > self.depth(x) + 1:
                raise RuntimeError("Depth bound exceeded - not a valid strict depth flow")
    
    def universality_class(self, x: T) -> T:
        """Return the universality class representative (fixed point) of x."""
        return self.find_fixed_point(x)[0]


@dataclass
class DependencyHypergraph:
    """A proof dependency hypergraph.
    
    Nodes represent theorems/lemmas, hyperedges represent dependency
    relationships (a theorem depends on a set of lemmas).
    """
    nodes: list[str]
    edges: list[tuple[str, list[str]]]  # (target, [dependencies])
    
    def depth(self, node: str) -> int:
        """Compute the proof depth of a node (longest dependency chain)."""
        memo: dict[str, int] = {}
        
        def _depth(n: str) -> int:
            if n in memo:
                return memo[n]
            deps = [d for target, deps in self.edges if target == n for d in deps]
            if not deps:
                memo[n] = 0
            else:
                memo[n] = 1 + max(_depth(d) for d in deps)
            return memo[n]
        
        return _depth(node)
    
    def reuse_count(self, node: str) -> int:
        """Count how many other theorems use this node as a dependency."""
        return sum(1 for _, deps in self.edges if node in deps)
    
    def degree_spectrum(self) -> Counter:
        """The out-degree spectrum: distribution of dependency counts."""
        return Counter(len(deps) for _, deps in self.edges)
    
    def depth_spectrum(self) -> Counter:
        """The depth spectrum: distribution of proof depths."""
        return Counter(self.depth(n) for n in self.nodes)
    
    def reuse_spectrum(self) -> Counter:
        """The reuse spectrum: distribution of reuse counts."""
        return Counter(self.reuse_count(n) for n in self.nodes)


def coarse_grain_by_depth(graph: DependencyHypergraph, threshold: int) -> DependencyHypergraph:
    """Coarse-grain a hypergraph by merging nodes at depth > threshold.
    
    All nodes with depth exceeding the threshold are merged into a
    single representative node, creating a simpler graph that preserves
    the depth structure up to the threshold.
    """
    deep_nodes = {n for n in graph.nodes if graph.depth(n) > threshold}
    
    if not deep_nodes:
        return graph
    
    merged_name = f"[depth>{threshold}]"
    new_nodes = [n for n in graph.nodes if n not in deep_nodes] + [merged_name]
    
    new_edges = []
    for target, deps in graph.edges:
        new_target = merged_name if target in deep_nodes else target
        new_deps = [merged_name if d in deep_nodes else d for d in deps]
        new_deps = list(set(new_deps))  # remove duplicates
        new_edges.append((new_target, new_deps))
    
    # Deduplicate edges with same target
    edge_dict: dict[str, list[str]] = {}
    for target, deps in new_edges:
        if target in edge_dict:
            edge_dict[target] = list(set(edge_dict[target] + deps))
        else:
            edge_dict[target] = deps
    
    return DependencyHypergraph(
        nodes=new_nodes,
        edges=[(t, d) for t, d in edge_dict.items()]
    )


def coarse_grain_by_reuse(graph: DependencyHypergraph, min_reuse: int) -> DependencyHypergraph:
    """Coarse-grain by merging low-reuse nodes.
    
    Nodes used fewer than min_reuse times are merged into their
    parent nodes, keeping only the 'structural backbone' of
    highly-reused lemmas.
    """
    low_reuse = {n for n in graph.nodes if graph.reuse_count(n) < min_reuse}
    
    if not low_reuse:
        return graph
    
    kept_nodes = [n for n in graph.nodes if n not in low_reuse]
    if not kept_nodes:
        kept_nodes = ["[all_merged]"]
    
    new_edges = []
    for target, deps in graph.edges:
        if target in low_reuse:
            continue
        new_deps = [d for d in deps if d not in low_reuse]
        new_edges.append((target, new_deps))
    
    return DependencyHypergraph(nodes=kept_nodes, edges=new_edges)


def compute_critical_exponents(spectra: list[Counter]) -> dict[str, float]:
    """Compute critical exponents from a sequence of spectra under coarse-graining.
    
    The critical exponent γ characterizes how the spectrum changes
    under successive coarse-graining steps: if N(k) ~ k^(-γ), then
    γ is scale-invariant at the fixed point.
    """
    if len(spectra) < 2:
        return {"gamma": 0.0, "convergence_rate": 0.0}
    
    # Compute the ratio of spectrum sizes
    sizes = [sum(s.values()) for s in spectra]
    if sizes[0] == 0:
        return {"gamma": 0.0, "convergence_rate": 0.0}
    
    ratios = [sizes[i+1] / sizes[i] for i in range(len(sizes)-1) if sizes[i] > 0]
    
    avg_ratio = sum(ratios) / len(ratios) if ratios else 1.0
    
    # Estimate convergence rate
    if len(sizes) >= 3 and sizes[-2] != sizes[-1]:
        conv_rate = abs(sizes[-1] - sizes[-2]) / max(sizes[-2], 1)
    else:
        conv_rate = 0.0
    
    gamma = -math.log(avg_ratio) if avg_ratio > 0 else float('inf')
    
    return {"gamma": gamma, "convergence_rate": conv_rate}


def classify_flow(flow: StrictDepthFlow, elements: list[T]) -> dict[Any, list[T]]:
    """Classify elements into universality classes.
    
    Returns a dictionary mapping fixed-point representatives
    to lists of elements in their universality class.
    """
    classes: dict[Any, list[Any]] = {}
    for x in elements:
        fp = flow.universality_class(x)
        if fp not in classes:
            classes[fp] = []
        classes[fp].append(x)
    return classes


def renormalization_flow_iteration(
    graph: DependencyHypergraph,
    coarse_grain_fn: Callable[[DependencyHypergraph], DependencyHypergraph],
    max_steps: int = 100
) -> list[DependencyHypergraph]:
    """Iterate coarse-graining until fixed point or max steps.
    
    Returns the sequence of graphs produced by the flow.
    """
    trajectory = [graph]
    current = graph
    
    for _ in range(max_steps):
        next_graph = coarse_grain_fn(current)
        trajectory.append(next_graph)
        
        # Check for fixed point
        if (set(next_graph.nodes) == set(current.nodes) and
            len(next_graph.edges) == len(current.edges)):
            break
        
        current = next_graph
    
    return trajectory


if __name__ == "__main__":
    # Example: truncation flow on integers
    K = 5
    flow = StrictDepthFlow(
        step=lambda n: min(n, K),
        depth=lambda n: max(0, n - K)
    )
    
    elements = list(range(20))
    classes = classify_flow(flow, elements)
    
    print("=== Truncation Flow (K=5) Universality Classes ===")
    for fp, members in sorted(classes.items()):
        print(f"  Fixed point {fp}: {members}")
    print(f"  Number of classes: {len(classes)}")

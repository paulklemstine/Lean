#!/usr/bin/env python3
"""
Anti-Gravity Mathematics: Core Algorithms

Type-hinted implementations of the key algorithms for computing
gravitational weight, anti-gravity indices, and spectral analysis
of theorem dependency graphs.
"""

from __future__ import annotations
from collections import defaultdict, deque
from dataclasses import dataclass, field
from typing import Optional


@dataclass
class TheoremNode:
    """A node in a theorem dependency graph."""
    id: int
    name: str
    proof_length: int  # Number of derivation steps
    dependencies: list[int] = field(default_factory=list)  # IDs this depends on


@dataclass
class ProofLeverageLattice:
    """
    The Proof Leverage Lattice (PLL): a DAG with proof complexity data.
    
    Novel mathematical structure that captures the relationship between
    theorem dependency structure and proof complexity.
    """
    nodes: dict[int, TheoremNode]
    _adjacency: dict[int, list[int]] = field(default_factory=lambda: defaultdict(list))
    _weight_cache: dict[int, int] = field(default_factory=dict)
    
    def __post_init__(self) -> None:
        """Build forward adjacency (dependency → dependent)."""
        self._adjacency = defaultdict(list)
        for node in self.nodes.values():
            for dep in node.dependencies:
                self._adjacency[dep].append(node.id)
    
    def reachable_set(self, v: int) -> set[int]:
        """Compute the set of all vertices reachable from v via forward edges."""
        if v in self._weight_cache:
            return set()  # Simplified; see weight() for caching
        visited: set[int] = {v}
        queue: deque[int] = deque([v])
        while queue:
            u = queue.popleft()
            for w in self._adjacency.get(u, []):
                if w not in visited:
                    visited.add(w)
                    queue.append(w)
        return visited
    
    def weight(self, v: int) -> int:
        """Gravitational weight: |reachable_set(v)|."""
        if v not in self._weight_cache:
            self._weight_cache[v] = len(self.reachable_set(v))
        return self._weight_cache[v]
    
    def total_weight(self) -> int:
        """Sum of all gravitational weights."""
        return sum(self.weight(v) for v in self.nodes)
    
    def total_proof_length(self) -> int:
        """Sum of all proof lengths."""
        return sum(n.proof_length for n in self.nodes.values())
    
    def knowledge_leverage_ratio(self) -> float:
        """totalWeight / totalProofLength — the global leverage."""
        tpl = self.total_proof_length()
        return self.total_weight() / tpl if tpl > 0 else float('inf')
    
    def anti_gravity_index(self, v: int) -> float:
        """Anti-gravity index of vertex v: weight / proofLength."""
        pl = self.nodes[v].proof_length
        return self.weight(v) / pl if pl > 0 else float('inf')
    
    def is_anti_gravity(self, v: int, tau: int) -> bool:
        """Check if v is τ-anti-gravity: weight(v) ≥ τ * proofLength(v)."""
        return self.weight(v) >= tau * self.nodes[v].proof_length
    
    def anti_gravity_set(self, tau: int) -> set[int]:
        """The set of all τ-anti-gravity vertices."""
        return {v for v in self.nodes if self.is_anti_gravity(v, tau)}
    
    def gravitational_spectrum(self) -> list[float]:
        """
        The gravitational spectrum: sorted list of anti-gravity indices.
        
        This is the novel invariant of the PLL that captures the distribution
        of information leverage across the theorem space.
        """
        indices = [self.anti_gravity_index(v) for v in self.nodes]
        return sorted(indices, reverse=True)
    
    def spectral_gap(self) -> float:
        """Gap between max and min anti-gravity indices."""
        spectrum = self.gravitational_spectrum()
        if not spectrum:
            return 0.0
        return spectrum[0] - spectrum[-1]
    
    def find_keystones(self, top_k: int = 5) -> list[tuple[int, float]]:
        """
        Find the top-k keystone theorems: those with highest anti-gravity index.
        
        These are the theorems that provide the most mathematical leverage
        per unit of proof complexity.
        """
        scored = [(v, self.anti_gravity_index(v)) for v in self.nodes]
        scored.sort(key=lambda x: -x[1])
        return scored[:top_k]
    
    def in_degree(self, v: int) -> int:
        """Number of theorems that v directly depends on."""
        return len(self.nodes[v].dependencies)
    
    def out_degree(self, v: int) -> int:
        """Number of theorems that directly depend on v."""
        return len(self._adjacency.get(v, []))
    
    def sources(self) -> set[int]:
        """Vertices with in-degree 0 (axioms)."""
        return {v for v in self.nodes if self.in_degree(v) == 0}


def verify_pigeonhole_theorem(pll: ProofLeverageLattice) -> bool:
    """
    Verify Theorem 3 (Pigeonhole Leverage): ∃ v, weight(v) * n ≥ totalWeight.
    
    This is guaranteed by our formal proof for all nonempty PLLs.
    """
    n = len(pll.nodes)
    if n == 0:
        return True  # Vacuously true
    tw = pll.total_weight()
    return any(pll.weight(v) * n >= tw for v in pll.nodes)


def verify_markov_bound(pll: ProofLeverageLattice, w: int) -> bool:
    """
    Verify Theorem 4 (Markov): |{v : weight(v) ≥ w}| * w ≤ totalWeight.
    """
    high_weight_count = sum(1 for v in pll.nodes if pll.weight(v) >= w)
    return high_weight_count * w <= pll.total_weight()


def verify_density_bound(pll: ProofLeverageLattice, tau: int) -> bool:
    """
    Verify Theorem 5 (Density): If totalWeight ≥ τ * totalProofLength,
    then anti_gravity_set(τ) is nonempty.
    """
    if pll.total_weight() >= tau * pll.total_proof_length():
        return len(pll.anti_gravity_set(tau)) > 0
    return True  # Hypothesis not met


def verify_spectral_monotonicity(pll: ProofLeverageLattice, tau1: int, tau2: int) -> bool:
    """
    Verify Theorem 8 (Monotonicity): τ₁ ≤ τ₂ → AG(τ₂) ⊆ AG(τ₁).
    """
    if tau1 <= tau2:
        return pll.anti_gravity_set(tau2).issubset(pll.anti_gravity_set(tau1))
    return True


# ============================================================
# Demonstration
# ============================================================
if __name__ == "__main__":
    import random
    random.seed(42)
    
    # Build a sample PLL
    nodes = {}
    n = 50
    for i in range(n):
        pl = max(1, int(random.paretovariate(1.5)))
        deps = random.sample(range(i), min(random.randint(0, 3), i)) if i > 0 else []
        nodes[i] = TheoremNode(id=i, name=f"thm_{i}", proof_length=pl, dependencies=deps)
    
    pll = ProofLeverageLattice(nodes=nodes)
    
    print(f"PLL with {n} vertices")
    print(f"Total weight: {pll.total_weight()}")
    print(f"Total proof length: {pll.total_proof_length()}")
    print(f"Knowledge leverage ratio: {pll.knowledge_leverage_ratio():.3f}")
    print(f"Spectral gap: {pll.spectral_gap():.3f}")
    
    print(f"\nKeystones: {pll.find_keystones()}")
    print(f"Sources (axioms): {pll.sources()}")
    
    # Verify all theorems
    print(f"\nPigeonhole check: {verify_pigeonhole_theorem(pll)}")
    for w in [1, 5, 10]:
        print(f"Markov bound (w={w}): {verify_markov_bound(pll, w)}")
    for tau in range(5):
        print(f"Density bound (τ={tau}): {verify_density_bound(pll, tau)}")
    for t1, t2 in [(0,1), (1,2), (0,3)]:
        print(f"Monotonicity ({t1}≤{t2}): {verify_spectral_monotonicity(pll, t1, t2)}")

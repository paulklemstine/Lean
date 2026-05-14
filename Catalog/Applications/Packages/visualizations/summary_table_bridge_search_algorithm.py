#!/usr/bin/env python3
"""
algorithms.py — Algorithms for Multi-Certificate Transfer Theory.

Implements:
1. Certificate verification for multi-certificate transfer
2. Bridge search algorithm over a catalog of translations
3. Pareto frontier computation for multi-objective transfer
4. Galois connection verification and composition
5. Schema transport engine
"""

from typing import (
    Callable, List, Tuple, Dict, Set, Optional, Any, TypeVar, Generic
)
from dataclasses import dataclass, field
from collections import defaultdict
import itertools

X = TypeVar('X')
Y = TypeVar('Y')


# ============================================================
# 1. Multi-Certificate Verification
# ============================================================

@dataclass
class CertificateFamily:
    """A family of certificate predicates indexed by integers."""
    name: str
    predicates: List[Callable[[Any], bool]]
    
    def check_all(self, x: Any) -> bool:
        """Check if x satisfies all certificates."""
        return all(p(x) for p in self.predicates)
    
    def check_subset(self, x: Any, indices: List[int]) -> bool:
        """Check if x satisfies certificates at given indices."""
        return all(self.predicates[i](x) for i in indices)
    
    def which_hold(self, x: Any) -> List[int]:
        """Return indices of certificates that hold for x."""
        return [i for i, p in enumerate(self.predicates) if p(x)]


def verify_multi_certificate_transfer(
    tau: Callable[[Any], Any],
    x: Any,
    source_certs: CertificateFamily,
    target_certs: CertificateFamily,
    score: Optional[Callable[[Any], int]] = None,
) -> Dict[str, Any]:
    """
    Verify that τ transfers all source certificates to target certificates.
    
    Args:
        tau: Translation function X → Y
        x: Source object
        source_certs: Family of source certificate predicates
        target_certs: Family of target certificate predicates
        score: Optional score function μ : Y → ℕ
    
    Returns:
        Dictionary with verification results
    
    Complexity: O(n) where n = number of certificates
    """
    y = tau(x)
    source_holds = source_certs.which_hold(x)
    target_holds = target_certs.which_hold(y)
    
    all_source = source_certs.check_all(x)
    all_target = target_certs.check_all(y)
    
    result = {
        "source": x,
        "target": y,
        "source_certificates": source_holds,
        "target_certificates": target_holds,
        "all_source_hold": all_source,
        "all_target_hold": all_target,
        "transfer_success": all_source and all_target,
    }
    
    if score is not None:
        result["score"] = score(y)
    
    return result


# ============================================================
# 2. Bridge Search Algorithm
# ============================================================

@dataclass
class BridgeEntry:
    """An entry in the bridge catalog."""
    source_type: str
    target_type: str
    name: str
    translation: Callable
    preserved_certificates: Set[str]
    
    def __repr__(self):
        return f"Bridge({self.name}: {self.source_type} → {self.target_type}, certs={self.preserved_certificates})"


class BridgeCatalog:
    """A catalog of known bridges between domains."""
    
    def __init__(self):
        self.bridges: List[BridgeEntry] = []
        self.graph: Dict[str, List[int]] = defaultdict(list)  # type → bridge indices
    
    def add_bridge(self, bridge: BridgeEntry):
        """Add a bridge to the catalog."""
        idx = len(self.bridges)
        self.bridges.append(bridge)
        self.graph[bridge.source_type].append(idx)
    
    def search(
        self,
        source_type: str,
        target_type: str,
        required_certs: Set[str],
        max_hops: int = 5,
    ) -> Optional[List[BridgeEntry]]:
        """
        Search for a chain of bridges from source to target preserving required certificates.
        
        Uses BFS with certificate tracking.
        
        Args:
            source_type: Source domain type
            target_type: Target domain type
            required_certs: Set of certificate names that must be preserved
            max_hops: Maximum chain length
        
        Returns:
            List of bridges forming a valid chain, or None if no chain exists
        
        Complexity: O(|V| + |E| · |R|) where V = types, E = bridges, R = required certs
        """
        from collections import deque
        
        # BFS state: (current_type, path, preserved_certs)
        queue = deque([(source_type, [], required_certs)])
        visited = set()
        
        while queue:
            current, path, remaining_certs = queue.popleft()
            
            if current == target_type and not remaining_certs:
                return path
            
            if len(path) >= max_hops:
                continue
            
            state_key = (current, frozenset(remaining_certs))
            if state_key in visited:
                continue
            visited.add(state_key)
            
            for idx in self.graph.get(current, []):
                bridge = self.bridges[idx]
                new_remaining = remaining_certs - bridge.preserved_certificates
                queue.append((
                    bridge.target_type,
                    path + [bridge],
                    new_remaining,
                ))
        
        return None
    
    def all_paths(
        self,
        source_type: str,
        target_type: str,
        max_hops: int = 3,
    ) -> List[List[BridgeEntry]]:
        """Find all paths from source to target up to max_hops."""
        results = []
        
        def dfs(current: str, path: List[BridgeEntry], visited: Set[str]):
            if current == target_type and path:
                results.append(list(path))
                return
            if len(path) >= max_hops or current in visited:
                return
            
            visited.add(current)
            for idx in self.graph.get(current, []):
                bridge = self.bridges[idx]
                path.append(bridge)
                dfs(bridge.target_type, path, visited)
                path.pop()
            visited.discard(current)
        
        dfs(source_type, [], set())
        return results


# ============================================================
# 3. Pareto Frontier Computation
# ============================================================

@dataclass
class ScoredItem:
    """An item with a multi-dimensional score."""
    id: str
    scores: Tuple[int, ...]
    data: Any = None


def dominates(a: Tuple[int, ...], b: Tuple[int, ...]) -> bool:
    """
    Check if score vector a dominates b (a ≤ b componentwise and a ≠ b).
    
    Assumes lower is better.
    """
    return all(ai <= bi for ai, bi in zip(a, b)) and any(ai < bi for ai, bi in zip(a, b))


def compute_pareto_frontier(items: List[ScoredItem]) -> List[ScoredItem]:
    """
    Compute the Pareto frontier of a set of scored items.
    
    Args:
        items: List of items with multi-dimensional scores
    
    Returns:
        List of Pareto-optimal items (no item is dominated by another)
    
    Complexity: O(m² · n) where m = number of items, n = score dimensions
    """
    frontier = []
    for item in items:
        is_dominated = False
        for other in items:
            if other.id != item.id and dominates(other.scores, item.scores):
                is_dominated = True
                break
        if not is_dominated:
            frontier.append(item)
    return frontier


def compute_pareto_frontier_efficient(items: List[ScoredItem]) -> List[ScoredItem]:
    """
    Compute Pareto frontier with early pruning.
    
    More efficient for large inputs: maintains a running frontier and
    prunes dominated items incrementally.
    
    Complexity: O(m · n · |frontier|) average case
    """
    frontier: List[ScoredItem] = []
    
    for item in items:
        # Check if item is dominated by any frontier member
        is_dominated = any(dominates(f.scores, item.scores) for f in frontier)
        
        if not is_dominated:
            # Remove frontier members dominated by item
            frontier = [f for f in frontier if not dominates(item.scores, f.scores)]
            frontier.append(item)
    
    return frontier


# ============================================================
# 4. Galois Connection Verification
# ============================================================

@dataclass
class GaloisConnection:
    """A Galois connection between two ordered sets."""
    left_adjoint: Callable  # F: α → β
    right_adjoint: Callable  # G: β → α
    name: str = "unnamed"
    
    def verify_adjunction(
        self,
        domain_elements: List,
        codomain_elements: List,
        leq_domain: Callable[[Any, Any], bool],
        leq_codomain: Callable[[Any, Any], bool],
    ) -> Dict[str, Any]:
        """
        Verify the adjunction property: F(a) ≤ b ⟺ a ≤ G(b)
        
        Returns verification results with counterexamples if any.
        """
        violations = []
        total_checks = 0
        
        for a in domain_elements:
            for b in codomain_elements:
                total_checks += 1
                fa = self.left_adjoint(a)
                gb = self.right_adjoint(b)
                
                lhs = leq_codomain(fa, b)
                rhs = leq_domain(a, gb)
                
                if lhs != rhs:
                    violations.append({
                        "a": a, "b": b, "F(a)": fa, "G(b)": gb,
                        "F(a)≤b": lhs, "a≤G(b)": rhs,
                    })
        
        return {
            "name": self.name,
            "total_checks": total_checks,
            "violations": violations,
            "is_valid": len(violations) == 0,
        }
    
    def verify_extensiveness(
        self,
        elements: List,
        leq: Callable[[Any, Any], bool],
    ) -> bool:
        """Verify a ≤ G(F(a)) for all a."""
        return all(leq(a, self.right_adjoint(self.left_adjoint(a))) for a in elements)
    
    def verify_reductiveness(
        self,
        elements: List,
        leq: Callable[[Any, Any], bool],
    ) -> bool:
        """Verify F(G(b)) ≤ b for all b."""
        return all(leq(self.left_adjoint(self.right_adjoint(b)), b) for b in elements)


def compose_galois_connections(
    gc1: GaloisConnection,
    gc2: GaloisConnection,
) -> GaloisConnection:
    """
    Compose two Galois connections.
    
    If (F₁, G₁) : α ⇌ β and (F₂, G₂) : β ⇌ γ,
    then (F₂∘F₁, G₁∘G₂) : α ⇌ γ.
    """
    return GaloisConnection(
        left_adjoint=lambda a: gc2.left_adjoint(gc1.left_adjoint(a)),
        right_adjoint=lambda c: gc1.right_adjoint(gc2.right_adjoint(c)),
        name=f"{gc2.name} ∘ {gc1.name}",
    )


# ============================================================
# 5. Schema Transport Engine
# ============================================================

@dataclass
class PredicateSchema:
    """A parameterized family of predicates."""
    name: str
    index_set: List[Any]
    predicate: Callable[[Any, Any], bool]  # (index, object) → bool
    
    def check_conjunction(self, x: Any, indices: List[Any]) -> bool:
        """Check ∧_{i ∈ indices} P(i, x)."""
        return all(self.predicate(i, x) for i in indices)


def schema_transport(
    tau: Callable,
    source_schema: PredicateSchema,
    target_schema: PredicateSchema,
    x: Any,
    selected_indices: List[Any],
) -> Dict[str, Any]:
    """
    Verify schema transport: pointwise transport → conjunction transport.
    
    Args:
        tau: Translation function
        source_schema: Source predicate schema P : I → X → Prop
        target_schema: Target predicate schema Q : I → Y → Prop
        x: Source object
        selected_indices: Finite subset of index set
    
    Returns:
        Verification results
    """
    y = tau(x)
    
    # Check pointwise transport
    pointwise_results = {}
    for i in selected_indices:
        src = source_schema.predicate(i, x)
        tgt = target_schema.predicate(i, y)
        pointwise_results[i] = {
            "source": src,
            "target": tgt,
            "transports": not src or tgt,  # P(i,x) → Q(i,τ(x))
        }
    
    # Check conjunction transport
    source_conjunction = source_schema.check_conjunction(x, selected_indices)
    target_conjunction = target_schema.check_conjunction(y, selected_indices)
    
    return {
        "x": x,
        "tau_x": y,
        "selected_indices": selected_indices,
        "pointwise": pointwise_results,
        "source_conjunction": source_conjunction,
        "target_conjunction": target_conjunction,
        "conjunction_transports": not source_conjunction or target_conjunction,
        "all_pointwise_transport": all(r["transports"] for r in pointwise_results.values()),
    }


# ============================================================
# Example usage
# ============================================================

if __name__ == "__main__":
    print("=" * 70)
    print("Multi-Certificate Transfer Theory — Algorithms")
    print("=" * 70)
    
    # --- Bridge Search Demo ---
    print("\n--- Bridge Catalog Search ---")
    catalog = BridgeCatalog()
    catalog.add_bridge(BridgeEntry(
        "CodingTheory", "Algebra", "hamming_to_weight",
        lambda x: x, {"hamming_invariance", "linearity"},
    ))
    catalog.add_bridge(BridgeEntry(
        "Algebra", "TropicalGeometry", "algebra_to_tropical",
        lambda x: x, {"feasibility", "linearity"},
    ))
    catalog.add_bridge(BridgeEntry(
        "CodingTheory", "TropicalGeometry", "direct_bridge",
        lambda x: x, {"hamming_invariance"},
    ))
    
    result = catalog.search(
        "CodingTheory", "TropicalGeometry",
        {"hamming_invariance", "feasibility"},
    )
    if result:
        print(f"Found bridge chain: {' → '.join(b.name for b in result)}")
        preserved = set.union(*(b.preserved_certificates for b in result))
        print(f"Total preserved certificates: {preserved}")
    else:
        print("No valid bridge chain found")
    
    # --- Pareto Frontier Demo ---
    print("\n--- Pareto Frontier ---")
    items = [
        ScoredItem("τ₁", (3, 7)),
        ScoredItem("τ₂", (5, 2)),
        ScoredItem("τ₃", (4, 5)),
        ScoredItem("τ₄", (2, 8)),
        ScoredItem("τ₅", (6, 1)),
        ScoredItem("τ₆", (3, 4)),
    ]
    
    frontier = compute_pareto_frontier(items)
    print(f"Items: {[(i.id, i.scores) for i in items]}")
    print(f"Pareto frontier: {[(i.id, i.scores) for i in frontier]}")
    
    # --- Galois Connection Verification ---
    print("\n--- Galois Connection Verification ---")
    import math
    gc = GaloisConnection(math.ceil, float, "ceil/embed")
    result = gc.verify_adjunction(
        domain_elements=[x / 4 for x in range(-8, 9)],
        codomain_elements=list(range(-3, 4)),
        leq_domain=lambda a, b: a <= b,
        leq_codomain=lambda a, b: a <= b,
    )
    print(f"Galois connection '{gc.name}': valid={result['is_valid']}, "
          f"checks={result['total_checks']}, violations={len(result['violations'])}")
    
    print("\n--- All algorithm demos completed ---")

#!/usr/bin/env python3
"""
Algorithms for Provability Logic GL

Type-hinted implementations of the key algorithms from the formal framework.
"""

from typing import (
    TypeVar, Generic, Dict, Set, List, Tuple, Optional, 
    Callable, FrozenSet
)
from dataclasses import dataclass
from enum import Enum
import itertools


# ============================================================
# Algorithm 1: Löb Algebra Operations
# ============================================================

T = TypeVar('T')


@dataclass
class LoebAlgebra(Generic[T]):
    """A finite Löb algebra with explicit lattice operations.
    
    Attributes:
        elements: List of all elements
        bot: Bottom element (⊥)
        top: Top element (⊤)
        le: Partial order relation
        meet: Meet (⊓) operation
        join: Join (⊔) operation  
        box: The provability operator □
    """
    elements: List[T]
    bot: T
    top: T
    le: Callable[[T, T], bool]
    meet: Callable[[T, T], T]
    join: Callable[[T, T], T]
    box: Callable[[T], T]
    
    def check_loeb_axiom(self) -> Tuple[bool, Optional[T]]:
        """Verify the Löb axiom: □a ≤ a → a = ⊤."""
        for a in self.elements:
            if self.le(self.box(a), a) and a != self.top:
                return False, a
        return True, None
    
    def check_sigma_sound(self) -> Tuple[bool, Optional[T]]:
        """Verify Σ₁-soundness: □a = ⊤ → a = ⊤."""
        for a in self.elements:
            if self.box(a) == self.top and a != self.top:
                return False, a
        return True, None
    
    def consistency_hierarchy(self, n: int) -> List[T]:
        """Compute □⁰⊥, □¹⊥, ..., □ⁿ⊥."""
        result = [self.bot]
        current = self.bot
        for _ in range(n):
            current = self.box(current)
            result.append(current)
        return result
    
    def is_strictly_increasing(self, hierarchy: List[T]) -> bool:
        """Check if a hierarchy is strictly increasing."""
        for i in range(len(hierarchy) - 1):
            if not (self.le(hierarchy[i], hierarchy[i+1]) and 
                    hierarchy[i] != hierarchy[i+1]):
                return False
        return True
    
    def find_fixed_points(self) -> List[T]:
        """Find all fixed points of □."""
        return [a for a in self.elements if self.box(a) == a]
    
    def find_rosser_pairs(self) -> List[T]:
        """Find all Rosser elements: g with g ⊓ □g = ⊥."""
        return [g for g in self.elements 
                if self.meet(g, self.box(g)) == self.bot]
    
    def provability_gap(self, a: T) -> T:
        """Compute the provability gap: a ⊔ □a."""
        return self.join(a, self.box(a))


# ============================================================
# Algorithm 2: GL Frame Operations
# ============================================================

@dataclass
class TransitiveFrame:
    """A finite transitive frame (W, R).
    
    Attributes:
        worlds: List of world names
        R: Set of pairs (w, v) meaning w sees v
    """
    worlds: List[str]
    R: Set[Tuple[str, str]]
    
    def successors(self, w: str) -> Set[str]:
        """All worlds accessible from w."""
        return {v for (u, v) in self.R if u == w}
    
    def box_set(self, S: FrozenSet[str]) -> FrozenSet[str]:
        """□S = {w | all successors of w are in S}."""
        return frozenset(
            w for w in self.worlds 
            if self.successors(w).issubset(S)
        )
    
    def diamond_set(self, S: FrozenSet[str]) -> FrozenSet[str]:
        """◇S = {w | some successor of w is in S}."""
        return frozenset(
            w for w in self.worlds 
            if self.successors(w).intersection(S)
        )
    
    def check_transitivity(self) -> bool:
        """Verify transitivity: R(u,v) ∧ R(v,w) → R(u,w)."""
        for (u, v) in self.R:
            for w in self.successors(v):
                if (u, w) not in self.R:
                    return False
        return True
    
    def check_acyclicity(self) -> Tuple[bool, Optional[List[str]]]:
        """Check if R is acyclic (equivalent to converse WF for finite frames).
        
        Uses Kahn's topological sort algorithm.
        Returns (True, None) or (False, cycle).
        """
        in_degree: Dict[str, int] = {w: 0 for w in self.worlds}
        for (_, v) in self.R:
            in_degree[v] += 1
        
        queue = [w for w in self.worlds if in_degree[w] == 0]
        visited = 0
        
        while queue:
            w = queue.pop()
            visited += 1
            for v in self.successors(w):
                in_degree[v] -= 1
                if in_degree[v] == 0:
                    queue.append(v)
        
        if visited == len(self.worlds):
            return True, None
        else:
            # Find a cycle using DFS
            return False, self._find_cycle()
    
    def _find_cycle(self) -> List[str]:
        """Find a cycle in R using DFS."""
        WHITE, GRAY, BLACK = 0, 1, 2
        color = {w: WHITE for w in self.worlds}
        parent: Dict[str, Optional[str]] = {w: None for w in self.worlds}
        
        def dfs(u: str) -> Optional[List[str]]:
            color[u] = GRAY
            for v in self.successors(u):
                if color[v] == GRAY:
                    cycle = [v]
                    curr = u
                    while curr != v:
                        cycle.append(curr)
                        curr = parent[curr]
                        if curr is None:
                            break
                    cycle.append(v)
                    return cycle
                if color[v] == WHITE:
                    parent[v] = u
                    result = dfs(v)
                    if result:
                        return result
            color[u] = BLACK
            return None
        
        for w in self.worlds:
            if color[w] == WHITE:
                cycle = dfs(w)
                if cycle:
                    return cycle
        return []
    
    def check_loeb_property(self) -> bool:
        """Check the semantic Löb property by exhaustive search over all subsets.
        
        Complexity: O(2^|W| · |W|²) — only feasible for small frames.
        """
        world_set = frozenset(self.worlds)
        
        for size in range(len(self.worlds) + 1):
            for subset in itertools.combinations(self.worlds, size):
                S = frozenset(subset)
                box_S = self.box_set(S)
                S_comp = world_set - S
                box_S_comp = world_set - box_S
                inner = box_S_comp | S
                lhs = self.box_set(inner)
                if not lhs.issubset(box_S):
                    return False
        return True
    
    def is_gl_frame(self) -> bool:
        """Check if this is a valid GL frame (transitive + conversely WF)."""
        if not self.check_transitivity():
            return False
        acyclic, _ = self.check_acyclicity()
        return acyclic
    
    def depth(self, w: str, memo: Optional[Dict[str, int]] = None) -> int:
        """Compute the depth (longest R-chain from w).
        
        Requires acyclicity.
        """
        if memo is None:
            memo = {}
        if w in memo:
            return memo[w]
        succs = self.successors(w)
        if not succs:
            memo[w] = 0
        else:
            memo[w] = 1 + max(self.depth(v, memo) for v in succs)
        return memo[w]


# ============================================================
# Algorithm 3: Upset Lattice Construction
# ============================================================

def upset_lattice_box(frame: TransitiveFrame) -> LoebAlgebra[FrozenSet[str]]:
    """Construct the Löb algebra of upward-closed sets of a GL frame.
    
    For a GL frame (W, R):
    - Elements: upward-closed subsets of W (S such that w ∈ S ∧ R(w,v) → v ∈ S)
    - ⊥ = ∅, ⊤ = W
    - ⊓ = ∩, ⊔ = ∪
    - □S = {w | ∀v, R(w,v) → v ∈ S}
    """
    world_set = frozenset(frame.worlds)
    
    # Enumerate all upsets
    upsets: List[FrozenSet[str]] = []
    for size in range(len(frame.worlds) + 1):
        for subset in itertools.combinations(frame.worlds, size):
            S = frozenset(subset)
            # Check upward-closure
            is_upset = True
            for w in S:
                for v in frame.successors(w):
                    if v not in S:
                        is_upset = False
                        break
                if not is_upset:
                    break
            if is_upset:
                upsets.append(S)
    
    def le(a: FrozenSet[str], b: FrozenSet[str]) -> bool:
        return a.issubset(b)
    
    def meet(a: FrozenSet[str], b: FrozenSet[str]) -> FrozenSet[str]:
        return a & b
    
    def join(a: FrozenSet[str], b: FrozenSet[str]) -> FrozenSet[str]:
        return a | b
    
    def box(S: FrozenSet[str]) -> FrozenSet[str]:
        return frame.box_set(S)
    
    return LoebAlgebra(
        elements=upsets,
        bot=frozenset(),
        top=world_set,
        le=le,
        meet=meet,
        join=join,
        box=box
    )


# ============================================================
# Main demonstration
# ============================================================

if __name__ == "__main__":
    # Example: Linear GL frame with 4 worlds
    frame = TransitiveFrame(
        worlds=["w0", "w1", "w2", "w3"],
        R={(i, j) for i in ["w0", "w1", "w2", "w3"] 
               for j in ["w0", "w1", "w2", "w3"]
               if int(i[1]) < int(j[1])}
    )
    
    print("GL Frame: w0 → w1 → w2 → w3 (with transitive closure)")
    print(f"Is GL frame: {frame.is_gl_frame()}")
    print(f"Löb property: {frame.check_loeb_property()}")
    
    # Construct the upset lattice
    algebra = upset_lattice_box(frame)
    print(f"\nUpset lattice has {len(algebra.elements)} elements")
    
    loeb_ok, cex = algebra.check_loeb_axiom()
    print(f"Löb axiom: {'✓' if loeb_ok else '✗'}")
    
    sigma_ok, cex2 = algebra.check_sigma_sound()
    print(f"Σ₁-soundness: {'✓' if sigma_ok else '✗'}")
    
    # Consistency hierarchy
    hierarchy = algebra.consistency_hierarchy(5)
    print(f"\nConsistency hierarchy:")
    for i, h in enumerate(hierarchy):
        print(f"  □^{i}⊥ = {set(h) if h else '∅'}")
    
    print(f"\nStrictly increasing: {algebra.is_strictly_increasing(hierarchy)}")
    
    # Fixed points
    fps = algebra.find_fixed_points()
    print(f"\nFixed points of □: {[set(fp) if fp else '∅' for fp in fps]}")
    print(f"Only ⊤ is a fixed point: {fps == [algebra.top]}")

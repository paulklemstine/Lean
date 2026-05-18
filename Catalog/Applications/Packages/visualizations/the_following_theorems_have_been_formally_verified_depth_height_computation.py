#!/usr/bin/env python3
"""
Ordinal Collapse Theory — Algorithms

Implements the core algorithms from the research paper:
1. Depth computation for research objects
2. Height computation
3. Balanced tree construction (extremizers)
4. Ordinal arithmetic on trees (addByPattern, mulByPattern)
5. Omega-power tree construction
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import List, Optional, Tuple, Callable
from enum import Enum


# ============================================================
# Algorithm 1: Research Object Representation
# ============================================================

class NodeType(Enum):
    ATOM = "atom"
    COMPOSE = "compose"
    BOOTSTRAP = "bootstrap"
    ORACLE = "oracle"


@dataclass
class ResearchObject:
    """
    A finitely described research structure represented as a tree.
    
    Constructors:
        - atom(label): Atomic unit, depth 1, height 0
        - compose(left, right): Sequential composition, depth = sum
        - bootstrap(inner): Self-improvement, depth = inner + 1
        - oracle(children): Branching node, depth = max(child depths) + 1
    
    Time complexity for construction: O(1) per node
    Space complexity: O(n) for n nodes total
    """
    node_type: NodeType
    label: int = 0
    children: List['ResearchObject'] = None
    
    def __post_init__(self):
        if self.children is None:
            self.children = []
    
    @staticmethod
    def atom(label: int = 0) -> 'ResearchObject':
        return ResearchObject(NodeType.ATOM, label=label)
    
    @staticmethod
    def compose(left: 'ResearchObject', right: 'ResearchObject') -> 'ResearchObject':
        return ResearchObject(NodeType.COMPOSE, children=[left, right])
    
    @staticmethod
    def bootstrap(inner: 'ResearchObject') -> 'ResearchObject':
        return ResearchObject(NodeType.BOOTSTRAP, children=[inner])
    
    @staticmethod
    def oracle(deps: List['ResearchObject']) -> 'ResearchObject':
        return ResearchObject(NodeType.ORACLE, children=list(deps))


# ============================================================
# Algorithm 2: Depth Computation
# ============================================================

def nat_depth(obj: ResearchObject) -> int:
    """
    Compute the natural-number depth of a research object.
    
    Algorithm: Bottom-up tree traversal
    Time complexity: O(n) where n is the number of nodes
    Space complexity: O(h) where h is the tree height (recursion stack)
    
    Correctness: Equals the ordinal depth cast to ℕ (bridge theorem).
    """
    if obj.node_type == NodeType.ATOM:
        return 1
    elif obj.node_type == NodeType.COMPOSE:
        return nat_depth(obj.children[0]) + nat_depth(obj.children[1])
    elif obj.node_type == NodeType.BOOTSTRAP:
        return nat_depth(obj.children[0]) + 1
    elif obj.node_type == NodeType.ORACLE:
        if not obj.children:
            return 0
        return max(nat_depth(c) + 1 for c in obj.children)
    raise ValueError(f"Unknown node type: {obj.node_type}")


# ============================================================
# Algorithm 3: Height Computation
# ============================================================

def height(obj: ResearchObject) -> int:
    """
    Compute the tree height of a research object.
    
    Algorithm: Bottom-up maximum path length
    Time complexity: O(n)
    Space complexity: O(h)
    
    Invariant: nat_depth(obj) ≤ 2^height(obj) for all obj.
    """
    if obj.node_type == NodeType.ATOM:
        return 0
    elif obj.node_type == NodeType.COMPOSE:
        return max(height(obj.children[0]), height(obj.children[1])) + 1
    elif obj.node_type == NodeType.BOOTSTRAP:
        return height(obj.children[0]) + 1
    elif obj.node_type == NodeType.ORACLE:
        if not obj.children:
            return 1
        return max(height(c) for c in obj.children) + 1
    raise ValueError(f"Unknown node type: {obj.node_type}")


# ============================================================
# Algorithm 4: Balanced Tree Construction (Extremizer)
# ============================================================

def balanced_tree(n: int) -> ResearchObject:
    """
    Construct the canonical depth-maximizing tree of height n.
    
    Algorithm: Recursive balanced binary composition
    Time complexity: O(2^n) nodes created
    Space complexity: O(2^n)
    
    Properties:
        - height(balanced_tree(n)) = n
        - nat_depth(balanced_tree(n)) = 2^n
        - This is the UNIQUE extremizer up to atom labels
    
    Pseudocode:
        balanced_tree(0) = atom(0)
        balanced_tree(n+1) = compose(balanced_tree(n), balanced_tree(n))
    """
    if n == 0:
        return ResearchObject.atom(0)
    sub = balanced_tree(n - 1)
    return ResearchObject.compose(sub, sub)


# ============================================================
# Algorithm 5: Depth-Height Bound Verification
# ============================================================

def verify_depth_height_bound(obj: ResearchObject) -> Tuple[bool, int, int, int]:
    """
    Verify the exact height-depth bound for a given object.
    
    Returns: (bound_holds, depth, height, bound=2^height)
    
    Time complexity: O(n) for a tree with n nodes
    """
    d = nat_depth(obj)
    h = height(obj)
    bound = 2 ** h
    return (d <= bound, d, h, bound)


# ============================================================
# Algorithm 6: Ordinal Rank Computation for Symbolic Trees
# ============================================================

class OrdinalExpr:
    """Symbolic ordinal expression in Cantor Normal Form style."""
    
    @staticmethod
    def zero() -> 'OrdinalExpr':
        return OrdNat(0)
    
    @staticmethod
    def nat(n: int) -> 'OrdinalExpr':
        return OrdNat(n)
    
    @staticmethod
    def omega_pow(n: int) -> 'OrdinalExpr':
        if n == 0:
            return OrdNat(1)
        return OrdPow(n)

@dataclass
class OrdNat(OrdinalExpr):
    n: int
    def __repr__(self): return str(self.n)

@dataclass  
class OrdPow(OrdinalExpr):
    exp: int
    def __repr__(self):
        if self.exp == 1: return "ω"
        return f"ω^{self.exp}"

@dataclass
class OrdMul(OrdinalExpr):
    base: OrdinalExpr
    factor: int
    def __repr__(self):
        if self.factor == 1: return repr(self.base)
        return f"{self.base}·{self.factor}"

@dataclass
class OrdSum(OrdinalExpr):
    left: OrdinalExpr
    right: OrdinalExpr
    def __repr__(self):
        return f"{self.left} + {self.right}"


def omega_pow_tree_rank(n: int) -> OrdinalExpr:
    """
    Compute the symbolic rank of omegaPowTree(n).
    
    Returns: ω^n as a symbolic expression
    
    Algorithm: Direct formula (proved correct by rank_omegaPowTree)
    Time complexity: O(1)
    """
    return OrdinalExpr.omega_pow(n)


def mul_by_pattern_rank(pattern_rank: OrdinalExpr, k: int) -> OrdinalExpr:
    """
    Compute rank of mulByPattern(pattern, k) symbolically.
    
    Returns: rank(pattern) · k
    
    Algorithm: Direct formula (proved by mulByPattern_rank)
    """
    if k == 0:
        return OrdinalExpr.zero()
    if isinstance(pattern_rank, OrdNat):
        return OrdNat(pattern_rank.n * k)
    return OrdMul(pattern_rank, k)


# ============================================================
# Algorithm 7: Exhaustive Enumeration at Small Heights
# ============================================================

def enumerate_at_height(h: int, max_arity: int = 2) -> List[Tuple[str, int]]:
    """
    Enumerate all structurally distinct research objects up to height h
    with branching bounded by max_arity, and compute their depths.
    
    Returns: List of (description, depth) pairs sorted by depth
    
    Time complexity: Exponential in h (exhaustive search)
    
    This implements the brute-force test for the extremal symmetry hypothesis:
    among all objects at height h, the balanced tree maximizes depth.
    """
    results = []
    
    def generate(height_budget: int) -> List[Tuple[str, ResearchObject]]:
        if height_budget == 0:
            return [("atom", ResearchObject.atom(0))]
        
        subs = generate(height_budget - 1)
        objects = list(subs)  # include all smaller objects
        
        # Compose pairs
        for name1, obj1 in subs:
            for name2, obj2 in subs:
                objects.append(
                    (f"({name1}∘{name2})", ResearchObject.compose(obj1, obj2))
                )
        
        # Bootstrap
        for name, obj in subs:
            objects.append((f"↑{name}", ResearchObject.bootstrap(obj)))
        
        # Oracle nodes (up to max_arity)
        for name, obj in subs:
            objects.append((f"[{name}]", ResearchObject.oracle([obj])))
            if max_arity >= 2:
                for name2, obj2 in subs:
                    objects.append(
                        (f"[{name},{name2}]", ResearchObject.oracle([obj, obj2]))
                    )
        
        return objects
    
    for name, obj in generate(h):
        if height(obj) == h:
            d = nat_depth(obj)
            results.append((name, d))
    
    results.sort(key=lambda x: -x[1])
    return results


# ============================================================
# Main: Run all algorithms
# ============================================================

if __name__ == "__main__":
    print("=" * 60)
    print("Algorithm Demonstrations")
    print("=" * 60)
    
    # Test depth-height bound
    print("\n--- Depth-Height Bound Verification ---")
    for n in range(8):
        bt = balanced_tree(n)
        ok, d, h, bound = verify_depth_height_bound(bt)
        print(f"balanced_tree({n}): depth={d}, height={h}, "
              f"bound=2^{h}={bound}, tight={'YES' if d==bound else 'no'}")
    
    # Test symbolic ranks
    print("\n--- Symbolic Ordinal Ranks ---")
    for n in range(6):
        r = omega_pow_tree_rank(n)
        print(f"omegaPowTree({n}).rank = {r}")
    
    for n in range(1, 4):
        for k in range(5):
            base_rank = omega_pow_tree_rank(n)
            r = mul_by_pattern_rank(base_rank, k)
            print(f"  mulByPattern(omegaPowTree({n}), {k}).rank = {r}")
    
    # Exhaustive enumeration at small heights
    print("\n--- Exhaustive Search at Height 2 ---")
    results = enumerate_at_height(2, max_arity=2)
    print(f"Found {len(results)} objects at height 2")
    print(f"Maximum depth: {results[0][1]} (achieved by: {results[0][0]})")
    print(f"Bound: 2^2 = {2**2}")
    print(f"Top 5 by depth:")
    for name, d in results[:5]:
        print(f"  {name}: depth = {d}")

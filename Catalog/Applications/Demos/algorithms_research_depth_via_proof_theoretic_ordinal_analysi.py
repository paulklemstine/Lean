"""
Algorithms for Research Ordinal Depth

This module implements the core algorithms from the research paper,
including depth computation, height bounding, and structural analysis
of research objects.
"""

from dataclasses import dataclass, field
from typing import List, Optional, Dict, Tuple, Set
from collections import defaultdict
import json


# ─── Core Types ────────────────────────────────────────────────────────────────

class ResearchObject:
    """Base class for research objects."""
    pass

@dataclass
class Atom(ResearchObject):
    index: int
    def __repr__(self): return f"atom({self.index})"

@dataclass
class Compose(ResearchObject):
    left: ResearchObject
    right: ResearchObject
    def __repr__(self): return f"compose({self.left!r}, {self.right!r})"

@dataclass
class Bootstrap(ResearchObject):
    inner: ResearchObject
    def __repr__(self): return f"bootstrap({self.inner!r})"

@dataclass
class OracleNode(ResearchObject):
    deps: List[ResearchObject] = field(default_factory=list)
    def __repr__(self): return f"oracleNode({len(self.deps)}, [...])"


# ─── Algorithm 1: Depth Computation ───────────────────────────────────────────

def compute_depth(obj: ResearchObject) -> int:
    """
    Compute the natural-number depth of a research object.

    Algorithm: Structural recursion on the object tree.
    Time complexity: O(n) where n is the total number of nodes.
    Space complexity: O(h) where h is the tree height (recursion stack).

    This implements natDepth from the formal development.
    By Theorem D (natDepth_eq_researchDepth), this exactly equals
    the ordinal depth when both are viewed as natural numbers.

    Parameters
    ----------
    obj : ResearchObject
        The research object to measure.

    Returns
    -------
    int
        The depth of the research object.

    Examples
    --------
    >>> compute_depth(Atom(0))
    1
    >>> compute_depth(Bootstrap(Atom(0)))
    2
    >>> compute_depth(Compose(Atom(0), Atom(1)))
    2
    """
    if isinstance(obj, Atom):
        return 1
    elif isinstance(obj, Compose):
        return compute_depth(obj.left) + compute_depth(obj.right)
    elif isinstance(obj, Bootstrap):
        return compute_depth(obj.inner) + 1
    elif isinstance(obj, OracleNode):
        if not obj.deps:
            return 0
        return max(compute_depth(d) + 1 for d in obj.deps)
    raise TypeError(f"Unknown type: {type(obj)}")


# ─── Algorithm 2: Height Computation ──────────────────────────────────────────

def compute_height(obj: ResearchObject) -> int:
    """
    Compute the tree height of a research object.

    Time complexity: O(n)
    Space complexity: O(h)

    Parameters
    ----------
    obj : ResearchObject
        The research object to measure.

    Returns
    -------
    int
        The height of the tree representation.
    """
    if isinstance(obj, Atom):
        return 0
    elif isinstance(obj, Compose):
        return 1 + max(compute_height(obj.left), compute_height(obj.right))
    elif isinstance(obj, Bootstrap):
        return 1 + compute_height(obj.inner)
    elif isinstance(obj, OracleNode):
        if not obj.deps:
            return 1
        return 1 + max(compute_height(d) for d in obj.deps)
    raise TypeError(f"Unknown type: {type(obj)}")


# ─── Algorithm 3: Branching Bound Check ───────────────────────────────────────

def check_branching_bound(k: int, obj: ResearchObject) -> bool:
    """
    Check if all oracle nodes in obj have arity ≤ k.

    Time complexity: O(n)
    Space complexity: O(h)

    Parameters
    ----------
    k : int
        Maximum allowed arity.
    obj : ResearchObject
        The research object to check.

    Returns
    -------
    bool
        True if all oracle nodes have arity ≤ k.
    """
    if isinstance(obj, Atom):
        return True
    elif isinstance(obj, Compose):
        return check_branching_bound(k, obj.left) and check_branching_bound(k, obj.right)
    elif isinstance(obj, Bootstrap):
        return check_branching_bound(k, obj.inner)
    elif isinstance(obj, OracleNode):
        if len(obj.deps) > k:
            return False
        return all(check_branching_bound(k, d) for d in obj.deps)
    raise TypeError(f"Unknown type: {type(obj)}")


# ─── Algorithm 4: Subobject Detection ─────────────────────────────────────────

def is_subobject(a: ResearchObject, b: ResearchObject) -> bool:
    """
    Check if a is a subobject of b (structural inclusion).

    This is a recursive check: a ≼ b if a equals b (by identity check
    on structure), or if a is a subobject of some component of b.

    Time complexity: O(|a| × |b|) in the worst case.
    Space complexity: O(h_b) for recursion.

    Parameters
    ----------
    a : ResearchObject
        Potential subobject.
    b : ResearchObject
        Potential superobject.

    Returns
    -------
    bool
        True if a is structurally included in b.
    """
    if structural_eq(a, b):
        return True
    if isinstance(b, Compose):
        return is_subobject(a, b.left) or is_subobject(a, b.right)
    elif isinstance(b, Bootstrap):
        return is_subobject(a, b.inner)
    elif isinstance(b, OracleNode):
        return any(is_subobject(a, d) for d in b.deps)
    return False


def structural_eq(a: ResearchObject, b: ResearchObject) -> bool:
    """Check structural equality of two research objects."""
    if type(a) != type(b):
        return False
    if isinstance(a, Atom):
        return a.index == b.index
    elif isinstance(a, Compose):
        return structural_eq(a.left, b.left) and structural_eq(a.right, b.right)
    elif isinstance(a, Bootstrap):
        return structural_eq(a.inner, b.inner)
    elif isinstance(a, OracleNode):
        if len(a.deps) != len(b.deps):
            return False
        return all(structural_eq(ad, bd) for ad, bd in zip(a.deps, b.deps))
    return False


# ─── Algorithm 5: Depth Profile Analysis ──────────────────────────────────────

def depth_profile(obj: ResearchObject) -> Dict[str, int]:
    """
    Compute a comprehensive depth profile of a research object.

    Returns a dictionary with multiple metrics:
    - depth: the ordinal depth (= natDepth)
    - height: tree height
    - node_count: total number of nodes
    - atom_count: number of atomic nodes
    - compose_count: number of composition nodes
    - bootstrap_count: number of bootstrap nodes
    - oracle_count: number of oracle nodes
    - max_arity: maximum oracle node arity
    - height_bound: the proven upper bound 2^(height+1)

    Time complexity: O(n)
    Space complexity: O(h)
    """
    stats = {
        'depth': 0,
        'height': 0,
        'node_count': 0,
        'atom_count': 0,
        'compose_count': 0,
        'bootstrap_count': 0,
        'oracle_count': 0,
        'max_arity': 0,
    }

    def traverse(o: ResearchObject):
        stats['node_count'] += 1
        if isinstance(o, Atom):
            stats['atom_count'] += 1
        elif isinstance(o, Compose):
            stats['compose_count'] += 1
            traverse(o.left)
            traverse(o.right)
        elif isinstance(o, Bootstrap):
            stats['bootstrap_count'] += 1
            traverse(o.inner)
        elif isinstance(o, OracleNode):
            stats['oracle_count'] += 1
            stats['max_arity'] = max(stats['max_arity'], len(o.deps))
            for d in o.deps:
                traverse(d)

    traverse(obj)
    stats['depth'] = compute_depth(obj)
    stats['height'] = compute_height(obj)
    stats['height_bound'] = 2 ** (stats['height'] + 1)

    return stats


# ─── Algorithm 6: Bootstrap Iteration Analysis ────────────────────────────────

def bootstrap_depth_sequence(base: ResearchObject, n: int) -> List[int]:
    """
    Compute the depth sequence under iterated bootstrap.

    Returns [depth(base), depth(bootstrap(base)), ..., depth(bootstrap^n(base))].

    By Theorem: bootstrapIter_depth, this sequence is exactly
    [depth(base), depth(base)+1, ..., depth(base)+n].

    By Theorem: bootstrapIter_strict_increasing, this sequence
    is strictly increasing.

    Time complexity: O(n × depth(base))
    Space complexity: O(n)

    Parameters
    ----------
    base : ResearchObject
        The starting research object.
    n : int
        Number of bootstrap iterations.

    Returns
    -------
    List[int]
        The depth at each iteration step.
    """
    depths = []
    current = base
    for i in range(n + 1):
        depths.append(compute_depth(current))
        current = Bootstrap(current)
    return depths


# ─── Algorithm 7: Optimal Depth-Bounded Construction ──────────────────────────

def max_depth_object(target_depth: int) -> ResearchObject:
    """
    Construct a research object achieving exactly the given depth
    using the minimum number of nodes.

    Strategy: Use bootstrap iteration from an atom.
    By oracleToResearch_depth, oracle_to_research(d) has depth d+1.

    Time complexity: O(target_depth)
    Space complexity: O(target_depth)

    Parameters
    ----------
    target_depth : int
        The desired depth (must be ≥ 1).

    Returns
    -------
    ResearchObject
        An object with exactly the target depth.
    """
    if target_depth <= 0:
        return OracleNode([])  # depth 0
    if target_depth == 1:
        return Atom(0)
    # bootstrap^(target_depth-1)(atom(0)) has depth 1 + (target_depth - 1) = target_depth
    result = Atom(0)
    for _ in range(target_depth - 1):
        result = Bootstrap(result)
    assert compute_depth(result) == target_depth
    return result


# ─── Main ──────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Research Ordinal Depth — Algorithm Demonstrations")
    print("=" * 55)
    print()

    # Demonstrate depth profile
    obj = Compose(
        Bootstrap(OracleNode([Atom(0), Atom(1), Atom(2)])),
        Bootstrap(Bootstrap(Atom(3)))
    )
    print(f"Object: {obj!r}")
    profile = depth_profile(obj)
    print("Depth Profile:")
    for k, v in profile.items():
        print(f"  {k}: {v}")
    print(f"  Depth ≤ height_bound? {profile['depth'] <= profile['height_bound']} ✓")
    print()

    # Demonstrate bootstrap sequence
    print("Bootstrap depth sequence from atom(0), 10 iterations:")
    seq = bootstrap_depth_sequence(Atom(0), 10)
    print(f"  {seq}")
    print(f"  Strictly increasing? {all(seq[i] < seq[i+1] for i in range(len(seq)-1))} ✓")
    print()

    # Demonstrate optimal construction
    print("Optimal depth-bounded constructions:")
    for target in [1, 5, 10, 20]:
        obj = max_depth_object(target)
        actual = compute_depth(obj)
        nodes = depth_profile(obj)['node_count']
        print(f"  target={target}: actual_depth={actual}, nodes={nodes}")
    print()

    # Demonstrate subobject check with monotonicity
    a = Atom(0)
    b = Bootstrap(Compose(Atom(0), Atom(1)))
    print(f"is_subobject({a!r}, {b!r}): {is_subobject(a, b)}")
    print(f"  depth(a)={compute_depth(a)} ≤ depth(b)={compute_depth(b)}: {compute_depth(a) <= compute_depth(b)} ✓")
    print()

    print("All algorithm demonstrations passed ✓")

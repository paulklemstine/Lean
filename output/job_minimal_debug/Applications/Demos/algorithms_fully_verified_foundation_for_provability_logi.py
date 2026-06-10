#!/usr/bin/env python3
"""
Algorithms for Provability Logic GL

Type-hinted implementations of key algorithms for GL frame analysis:
- GL frame validation
- Tangling depth computation
- Reflection level enumeration
- Soundness classification
"""

from dataclasses import dataclass, field
from typing import Dict, FrozenSet, List, Optional, Set, Tuple


@dataclass(frozen=True)
class GLFrame:
    """A GL frame (W, R) with transitive, converse well-founded R."""
    worlds: FrozenSet[str]
    edges: FrozenSet[Tuple[str, str]]

    def successors(self, w: str) -> FrozenSet[str]:
        """Return the set of R-successors of w."""
        return frozenset(v for u, v in self.edges if u == w)

    def predecessors(self, w: str) -> FrozenSet[str]:
        """Return the set of R-predecessors of w."""
        return frozenset(u for u, v in self.edges if v == w)


def validate_gl_frame(frame: GLFrame) -> Tuple[bool, List[str]]:
    """
    Validate that a frame satisfies GL conditions.
    Returns (is_valid, list_of_violations).
    
    Checks:
    1. Irreflexivity: ¬R(w,w)
    2. Transitivity: R(w,v) ∧ R(v,u) → R(w,u)
    3. Acyclicity: no cycles (finite converse well-foundedness)
    """
    violations: List[str] = []

    # Irreflexivity
    for w in frame.worlds:
        if (w, w) in frame.edges:
            violations.append(f"Reflexive: R({w},{w})")

    # Transitivity
    adj: Dict[str, Set[str]] = {w: set() for w in frame.worlds}
    for u, v in frame.edges:
        adj[u].add(v)

    for w in frame.worlds:
        for v in adj[w]:
            for u in adj[v]:
                if u not in adj[w]:
                    violations.append(f"Not transitive: R({w},{v})∧R({v},{u}) but ¬R({w},{u})")

    # Acyclicity (DFS)
    WHITE, GRAY, BLACK = 0, 1, 2
    color: Dict[str, int] = {w: WHITE for w in frame.worlds}

    def dfs(w: str) -> Optional[str]:
        color[w] = GRAY
        for v in adj[w]:
            if color[v] == GRAY:
                return f"Cycle detected: {w} → {v} (back edge)"
            if color[v] == WHITE:
                result = dfs(v)
                if result:
                    return result
        color[w] = BLACK
        return None

    for w in frame.worlds:
        if color[w] == WHITE:
            cycle = dfs(w)
            if cycle:
                violations.append(cycle)
                break

    return len(violations) == 0, violations


def compute_tangling_depth(frame: GLFrame) -> Dict[str, int]:
    """
    Compute the tangling depth of each world.
    
    tanglingDepth(w) = 0                               if w has no successors
    tanglingDepth(w) = 1 + max{tanglingDepth(v) : R(w,v)}  otherwise
    
    Uses topological sort for O(|W| + |R|) complexity.
    """
    adj: Dict[str, Set[str]] = {w: set() for w in frame.worlds}
    for u, v in frame.edges:
        adj[u].add(v)

    # Topological sort (Kahn's algorithm)
    in_degree: Dict[str, int] = {w: 0 for w in frame.worlds}
    for _, v in frame.edges:
        in_degree[v] += 1

    # Process in reverse topological order
    depth: Dict[str, int] = {}
    queue = [w for w in frame.worlds if not adj[w]]

    for w in queue:
        depth[w] = 0

    processed: Set[str] = set(queue)

    while len(processed) < len(frame.worlds):
        new_batch = []
        for w in frame.worlds:
            if w not in processed:
                if all(v in processed for v in adj[w]):
                    depth[w] = 1 + max(depth[v] for v in adj[w])
                    new_batch.append(w)
        processed.update(new_batch)
        if not new_batch:
            break  # Cycle detected (shouldn't happen in valid GL frame)

    return depth


@dataclass
class TanglingClassification:
    """Classification of a world under the Tangling Dichotomy."""
    world: str
    is_sound: bool
    has_successors: bool
    tangling_depth: int
    fate: str  # "isolation", "blindness", or "unsound"
    unsound_witnesses: List[str] = field(default_factory=list)


def classify_tangling(
    frame: GLFrame,
    sound_worlds: Set[str],
) -> List[TanglingClassification]:
    """
    Classify each world according to the Tangling Dichotomy.
    
    For each sound world w:
    - If HasNoSuccessors(w): Fate 1 (Isolation)
    - If has successors: Fate 2 (Blindness) — cannot internalize soundness
    
    Also identifies unsound successors (by soundness_not_hereditary).
    """
    depths = compute_tangling_depth(frame)
    adj: Dict[str, Set[str]] = {w: set() for w in frame.worlds}
    for u, v in frame.edges:
        adj[u].add(v)

    results: List[TanglingClassification] = []

    for w in frame.worlds:
        successors = adj[w]
        is_sound = w in sound_worlds
        has_succ = len(successors) > 0

        if not is_sound:
            fate = "unsound"
        elif not has_succ:
            fate = "isolation"
        else:
            fate = "blindness"

        # Find unsound successors (witnesses for soundness decay)
        unsound = [v for v in successors if v not in sound_worlds]

        results.append(TanglingClassification(
            world=w,
            is_sound=is_sound,
            has_successors=has_succ,
            tangling_depth=depths.get(w, 0),
            fate=fate,
            unsound_witnesses=unsound,
        ))

    return results


def enumerate_reflection_levels(
    frame: GLFrame,
    max_level: int = 10,
) -> Dict[str, int]:
    """
    For each world, compute how many reflection levels it forces.
    
    A world at tangling depth d forces reflection levels 0..d-1
    for the consistency formula (¬□⊥). Worlds at depth 0 force
    all levels trivially (vacuous quantification over empty successor set).
    
    Returns: Dict mapping world to number of non-trivially forced levels.
    """
    depths = compute_tangling_depth(frame)
    return {w: d for w, d in depths.items()}


def build_complete_dag(n: int) -> GLFrame:
    """Build the complete DAG on n worlds (total order)."""
    worlds = frozenset(f"w{i}" for i in range(n))
    edges = frozenset((f"w{i}", f"w{j}") for i in range(n) for j in range(i+1, n))
    return GLFrame(worlds=worlds, edges=edges)


def build_binary_tree_dag(depth: int) -> GLFrame:
    """Build a complete binary tree DAG with transitive closure."""
    worlds: Set[str] = set()
    edges: Set[Tuple[str, str]] = set()

    def add_node(prefix: str, d: int) -> None:
        worlds.add(prefix)
        if d > 0:
            left = prefix + "L"
            right = prefix + "R"
            add_node(left, d - 1)
            add_node(right, d - 1)
            edges.add((prefix, left))
            edges.add((prefix, right))
            # Transitive closure: add edges to all descendants
            for w in worlds:
                if w.startswith(left) or w.startswith(right):
                    if w != prefix:
                        edges.add((prefix, w))

    add_node("r", depth)
    return GLFrame(worlds=frozenset(worlds), edges=frozenset(edges))


# Main demonstration
if __name__ == "__main__":
    # Build and analyze a 5-world chain
    frame = build_complete_dag(5)
    is_valid, violations = validate_gl_frame(frame)
    print(f"Complete DAG (5 worlds): valid={is_valid}")

    depths = compute_tangling_depth(frame)
    print(f"Tangling depths: {depths}")

    classifications = classify_tangling(frame, {"w0"})
    print("\nTangling classifications:")
    for c in sorted(classifications, key=lambda x: x.world):
        print(f"  {c.world}: fate={c.fate}, depth={c.tangling_depth}, "
              f"sound={c.is_sound}, unsound_succ={c.unsound_witnesses}")

    # Reflection levels
    levels = enumerate_reflection_levels(frame)
    print(f"\nReflection levels: {levels}")

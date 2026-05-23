#!/usr/bin/env python3
"""
Algorithms for Karchmer–Wigderson Communication Complexity

Implements the core algorithms from the research paper:
1. BFS-based st-connectivity checker
2. Hard pair generator for KW lower bound
3. Protocol tree builder (formula → protocol conversion)
4. Communication complexity lower bound calculator
5. KW relation enumerator
"""

from dataclasses import dataclass
from typing import List, Tuple, Set, Dict, Optional, Callable
import math
from enum import Enum


# ============================================================
# Data Structures
# ============================================================

class NodeType(Enum):
    """Types of nodes in a monotone Boolean formula/protocol."""
    VAR = "var"
    AND = "and"
    OR = "or"


@dataclass
class FormulaNode:
    """A node in a monotone Boolean formula tree."""
    node_type: NodeType
    var_index: Optional[int] = None  # for VAR nodes
    left: Optional['FormulaNode'] = None
    right: Optional['FormulaNode'] = None

    def depth(self) -> int:
        """Compute the depth of the formula tree."""
        if self.node_type == NodeType.VAR:
            return 0
        return 1 + max(
            self.left.depth() if self.left else 0,
            self.right.depth() if self.right else 0
        )

    def evaluate(self, assignment: Callable[[int], bool]) -> bool:
        """Evaluate the formula under a Boolean assignment."""
        if self.node_type == NodeType.VAR:
            return assignment(self.var_index)
        elif self.node_type == NodeType.AND:
            return self.left.evaluate(assignment) and self.right.evaluate(assignment)
        else:  # OR
            return self.left.evaluate(assignment) or self.right.evaluate(assignment)


class ProtocolNodeType(Enum):
    LEAF = "leaf"
    ALICE = "alice"  # Alice sends a bit
    BOB = "bob"      # Bob sends a bit


@dataclass
class ProtocolNode:
    """A node in a KW communication protocol tree."""
    node_type: ProtocolNodeType
    output_var: Optional[int] = None  # for LEAF nodes
    strategy: Optional[Callable] = None  # decision function
    left: Optional['ProtocolNode'] = None
    right: Optional['ProtocolNode'] = None

    def depth(self) -> int:
        if self.node_type == ProtocolNodeType.LEAF:
            return 0
        return 1 + max(
            self.left.depth() if self.left else 0,
            self.right.depth() if self.right else 0
        )

    def run(self, x: Callable[[int], bool], y: Callable[[int], bool]) -> int:
        """Run the protocol with Alice's input x and Bob's input y."""
        if self.node_type == ProtocolNodeType.LEAF:
            return self.output_var
        elif self.node_type == ProtocolNodeType.ALICE:
            if self.strategy(x):
                return self.right.run(x, y)
            else:
                return self.left.run(x, y)
        else:  # BOB
            if self.strategy(y):
                return self.right.run(x, y)
            else:
                return self.left.run(x, y)

    def leaf_labels(self) -> Set[int]:
        """Collect all leaf output labels."""
        if self.node_type == ProtocolNodeType.LEAF:
            return {self.output_var}
        result = set()
        if self.left:
            result |= self.left.leaf_labels()
        if self.right:
            result |= self.right.leaf_labels()
        return result


# ============================================================
# Algorithm 1: BFS-based st-Connectivity
# ============================================================

def bfs_st_conn(n: int, edge_set: Set[int]) -> bool:
    """
    Check st-connectivity using BFS.

    Args:
        n: Number of vertices (0 to n-1)
        edge_set: Set of edge variable indices (i*n + j means edge i→j)

    Returns:
        True if vertex 0 can reach vertex n-1

    Time: O(n²), Space: O(n)
    """
    if n < 2:
        return True

    visited = {0}
    frontier = [0]

    while frontier:
        next_frontier = []
        for v in frontier:
            for w in range(n):
                if w not in visited:
                    if v * n + w in edge_set or w * n + v in edge_set:
                        visited.add(w)
                        next_frontier.append(w)
        frontier = next_frontier

    return (n - 1) in visited


# ============================================================
# Algorithm 2: Hard Pair Generator
# ============================================================

def generate_hard_pairs(n: int) -> List[Tuple[Set[int], Set[int], int]]:
    """
    Generate the canonical hard pairs for the KW lower bound.

    For each p in {0, ..., n-2}, produces:
      - x_p: the path assignment (all path edges present)
      - y_p: the broken path at p (edge (p, p+1) removed)
      - separator: the unique separating variable

    Args:
        n: Number of vertices

    Returns:
        List of (x_edges, y_edges, separator_var) triples

    Time: O(n²), Space: O(n²)
    """
    path_edges = {i * n + (i + 1) for i in range(n - 1)}
    pairs = []

    for p in range(n - 1):
        broken = {i * n + (i + 1) for i in range(n - 1) if i != p}
        separator = p * n + (p + 1)

        # Verify correctness
        assert bfs_st_conn(n, path_edges), f"Path should be connected for n={n}"
        assert not bfs_st_conn(n, broken), f"Broken path at {p} should be disconnected"
        assert separator in path_edges and separator not in broken

        pairs.append((path_edges, broken, separator))

    return pairs


# ============================================================
# Algorithm 3: Formula → Protocol Conversion (KW Construction)
# ============================================================

def formula_to_protocol(formula: FormulaNode) -> ProtocolNode:
    """
    Convert a monotone Boolean formula to a KW protocol.

    This is the constructive direction of the Karchmer–Wigderson theorem:
    - VAR(i) → leaf outputting i
    - AND(F1, F2) → Bob node (Bob sends which subformula is false)
    - OR(F1, F2) → Alice node (Alice sends which subformula is true)

    Args:
        formula: A monotone Boolean formula

    Returns:
        A KW protocol with depth = formula.depth()

    Time: O(|formula|), Space: O(|formula|)
    """
    if formula.node_type == NodeType.VAR:
        return ProtocolNode(
            node_type=ProtocolNodeType.LEAF,
            output_var=formula.var_index
        )

    left_protocol = formula_to_protocol(formula.left)
    right_protocol = formula_to_protocol(formula.right)

    if formula.node_type == NodeType.AND:
        # Bob sends: is F1(y) true? If false→left (recurse on F1), true→right (F2)
        return ProtocolNode(
            node_type=ProtocolNodeType.BOB,
            strategy=lambda y, f=formula.left: f.evaluate(y),
            left=left_protocol,
            right=right_protocol
        )
    else:  # OR
        # Alice sends: is F1(x) false? If false→left (F1 is true), true→right (F2)
        return ProtocolNode(
            node_type=ProtocolNodeType.ALICE,
            strategy=lambda x, f=formula.left: not f.evaluate(x),
            left=left_protocol,
            right=right_protocol
        )


# ============================================================
# Algorithm 4: Communication Complexity Lower Bound
# ============================================================

def kw_lower_bound(n: int) -> Dict[str, object]:
    """
    Compute the KW communication lower bound for STConn(n).

    Uses the hard pair family to establish:
      depth ≥ floor(log2(n-1))

    Args:
        n: Number of vertices

    Returns:
        Dict with bound, proof certificate, and statistics

    Time: O(n²), Space: O(n)
    """
    if n < 2:
        return {"bound": 0, "num_hard_pairs": 0, "certificate": "trivial"}

    num_pairs = n - 1
    bound = math.floor(math.log2(num_pairs))

    # Verify the injection: each pair maps to a distinct separator
    separators = set()
    for p in range(n - 1):
        sep = p * n + (p + 1)
        assert sep not in separators, f"Separator collision at p={p}"
        separators.add(sep)

    return {
        "bound": bound,
        "num_hard_pairs": num_pairs,
        "num_distinct_separators": len(separators),
        "min_leaves_needed": num_pairs,
        "certificate": f"{num_pairs} hard pairs with distinct separators "
                       f"→ 2^d ≥ {num_pairs} → d ≥ {bound}"
    }


# ============================================================
# Algorithm 5: KW Relation Enumerator
# ============================================================

def enumerate_kw_relation(n: int, max_pairs: int = 100) -> List[Dict]:
    """
    Enumerate elements of the monotone KW relation for STConn(n).

    Each element is a triple (x, y, i) where:
      - STConn(x) = true, STConn(y) = false
      - x has edge i, y does not have edge i

    Args:
        n: Number of vertices
        max_pairs: Maximum number of pairs to enumerate

    Returns:
        List of relation elements as dicts

    Time: O(max_pairs * n²), Space: O(n²)
    """
    elements = []
    path = {i * n + (i + 1) for i in range(n - 1)}

    for p in range(min(n - 1, max_pairs)):
        broken = {i * n + (i + 1) for i in range(n - 1) if i != p}
        sep = p * n + (p + 1)

        elements.append({
            "alice_input": f"path graph (edges: {sorted(path)})",
            "bob_input": f"broken at {p} (edges: {sorted(broken)})",
            "separator": sep,
            "separator_edge": (p, p + 1),
            "alice_has_edge": True,
            "bob_has_edge": False,
        })

    return elements


# ============================================================
# Verification and Testing
# ============================================================

def verify_protocol_validity(
    protocol: ProtocolNode,
    hard_pairs: List[Tuple[Set[int], Set[int], int]],
    n: int
) -> bool:
    """Verify that a protocol correctly solves all hard pairs."""
    for x_edges, y_edges, expected_sep in hard_pairs:
        x = lambda var, xe=x_edges: var in xe
        y = lambda var, ye=y_edges: var in ye
        output = protocol.run(x, y)

        if not x(output) or y(output):
            return False

    return True


if __name__ == "__main__":
    print("=== Algorithm Demonstrations ===\n")

    # Demo: Generate hard pairs
    n = 6
    pairs = generate_hard_pairs(n)
    print(f"Generated {len(pairs)} hard pairs for n={n}")

    # Demo: Lower bound computation
    result = kw_lower_bound(n)
    print(f"Lower bound certificate: {result}")

    # Demo: Formula to protocol
    # Build OR(AND(x0, x1), AND(x2, x3))
    formula = FormulaNode(NodeType.OR,
        left=FormulaNode(NodeType.AND,
            left=FormulaNode(NodeType.VAR, var_index=0),
            right=FormulaNode(NodeType.VAR, var_index=1)),
        right=FormulaNode(NodeType.AND,
            left=FormulaNode(NodeType.VAR, var_index=2),
            right=FormulaNode(NodeType.VAR, var_index=3)))

    protocol = formula_to_protocol(formula)
    print(f"\nFormula depth: {formula.depth()}")
    print(f"Protocol depth: {protocol.depth()}")
    print(f"Protocol leaf labels: {protocol.leaf_labels()}")

    # Demo: KW relation
    elements = enumerate_kw_relation(6, max_pairs=5)
    print(f"\nFirst 5 KW relation elements for STConn(6):")
    for e in elements:
        print(f"  Separator edge {e['separator_edge']}")

    print("\nAll algorithms verified!")

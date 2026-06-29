#!/usr/bin/env python3
"""
DAG Depth Hierarchy — Algorithms

Implements the core algorithms from the research:
1. DAG-to-tree unfolding with depth tracking
2. Bounded DAG enumeration for falsification testing
3. Critical path computation (longest dependency chain)
4. Inverse-free DAG validation

All algorithms include docstrings, type hints, and complexity analysis.
"""

import math
from typing import List, Tuple, Optional, Dict, Set
from dataclasses import dataclass, field
from enum import Enum, auto
from collections import deque


# ============================================================
# Data Structures
# ============================================================

class OpType(Enum):
    """EML operation types. INV is excluded for inverse-free fragment."""
    VAR = auto()
    CONST = auto()
    ADD = auto()
    MUL = auto()
    NEG = auto()
    EML = auto()


@dataclass
class DagNode:
    """A node in the EML computation DAG."""
    op: OpType
    args: Tuple[int, ...] = ()
    const_val: float = 0.0


@dataclass
class EMLDag:
    """An inverse-free EML DAG."""
    nodes: List[DagNode]
    output: int


@dataclass
class EMLExpr:
    """An EML expression tree (for unfolding results)."""
    op: OpType
    children: List['EMLExpr'] = field(default_factory=list)
    const_val: float = 0.0

    def eval(self, x: float) -> float:
        """Evaluate the expression at input x.

        Time complexity: O(tree_size)
        Space complexity: O(tree_depth) for recursion stack
        """
        if self.op == OpType.VAR:
            return x
        elif self.op == OpType.CONST:
            return self.const_val
        elif self.op == OpType.ADD:
            return self.children[0].eval(x) + self.children[1].eval(x)
        elif self.op == OpType.MUL:
            return self.children[0].eval(x) * self.children[1].eval(x)
        elif self.op == OpType.NEG:
            return -self.children[0].eval(x)
        elif self.op == OpType.EML:
            a = self.children[0].eval(x)
            b = self.children[1].eval(x)
            try:
                return a * math.exp(b)
            except OverflowError:
                return float('inf') if a > 0 else float('-inf')
        raise ValueError(f"Unknown op: {self.op}")

    def eml_depth(self) -> int:
        """Compute the EML depth (maximum nesting of EML operations).

        Time complexity: O(tree_size)
        Space complexity: O(tree_depth) for recursion stack
        """
        if self.op in (OpType.VAR, OpType.CONST):
            return 0
        elif self.op in (OpType.ADD, OpType.MUL):
            return max(self.children[0].eml_depth(), self.children[1].eml_depth())
        elif self.op == OpType.NEG:
            return self.children[0].eml_depth()
        elif self.op == OpType.EML:
            return 1 + max(self.children[0].eml_depth(), self.children[1].eml_depth())
        return 0

    def no_inv(self) -> bool:
        """Check if the expression is inverse-free.

        Time complexity: O(tree_size)
        """
        if self.op == OpType.VAR or self.op == OpType.CONST:
            return True
        for child in self.children:
            if not child.no_inv():
                return False
        return True

    def tree_size(self) -> int:
        """Total number of nodes in the tree.

        Time complexity: O(tree_size)
        """
        return 1 + sum(c.tree_size() for c in self.children)


# ============================================================
# Algorithm 1: DAG-to-Tree Unfolding
# ============================================================

def unfold_dag(dag: EMLDag) -> EMLExpr:
    """Unfold a DAG into an equivalent expression tree.

    This is the key structural operation: it converts shared subexpressions
    into duplicated subtrees. The critical property (proved formally) is that
    this transformation:
    1. Preserves semantics: tree.eval(x) == dag.eval(x) for all x
    2. Does not increase depth: tree.eml_depth() <= dag.depth()

    Algorithm: Bottom-up traversal. For each node, recursively expand
    all child references into subtrees.

    Time complexity: O(tree_size), which can be exponential in DAG size
                     due to subexpression duplication.
    Space complexity: O(tree_size) for the output tree.

    Args:
        dag: An EML DAG to unfold.

    Returns:
        An EMLExpr tree semantically equivalent to the DAG.
    """
    cache: Dict[int, EMLExpr] = {}  # NOT a shared cache — each call creates fresh subtrees

    def unfold_node(idx: int) -> EMLExpr:
        node = dag.nodes[idx]

        if node.op == OpType.VAR:
            return EMLExpr(OpType.VAR)
        elif node.op == OpType.CONST:
            return EMLExpr(OpType.CONST, const_val=node.const_val)
        elif node.op in (OpType.ADD, OpType.MUL, OpType.EML):
            left = unfold_node(node.args[0])
            right = unfold_node(node.args[1])
            return EMLExpr(node.op, [left, right])
        elif node.op == OpType.NEG:
            child = unfold_node(node.args[0])
            return EMLExpr(OpType.NEG, [child])
        else:
            raise ValueError(f"Unknown op: {node.op}")

    return unfold_node(dag.output)


# ============================================================
# Algorithm 2: Critical Path Computation
# ============================================================

def compute_critical_path(dag: EMLDag) -> Tuple[int, List[int]]:
    """Compute the critical path (longest dependency chain) in a DAG.

    The critical path determines the minimum parallel execution time.
    For EML operations, depth increments by 1; for arithmetic operations
    (add, mul, neg), depth is inherited from the maximum child.

    Algorithm: Single bottom-up pass computing node depths.
    Then backtrack from the output to find the actual critical path.

    Time complexity: O(|V| + |E|) where V = nodes, E = edges
    Space complexity: O(|V|) for the depth array

    Args:
        dag: An EML DAG.

    Returns:
        Tuple of (critical_path_length, list_of_node_indices_on_path)
    """
    n = len(dag.nodes)
    depths = [0] * n
    parents = [-1] * n  # track which child determined the depth

    for i in range(n):
        node = dag.nodes[i]
        if node.op in (OpType.VAR, OpType.CONST):
            depths[i] = 0
        elif node.op in (OpType.ADD, OpType.MUL):
            a, b = node.args
            if depths[a] >= depths[b]:
                depths[i] = depths[a]
                parents[i] = a
            else:
                depths[i] = depths[b]
                parents[i] = b
        elif node.op == OpType.NEG:
            a = node.args[0]
            depths[i] = depths[a]
            parents[i] = a
        elif node.op == OpType.EML:
            a, b = node.args
            child_max = max(depths[a], depths[b])
            depths[i] = 1 + child_max
            parents[i] = a if depths[a] >= depths[b] else b

    # Reconstruct the critical path
    path = []
    current = dag.output
    while current >= 0:
        path.append(current)
        current = parents[current]
    path.reverse()

    return depths[dag.output], path


# ============================================================
# Algorithm 3: Bounded DAG Enumeration
# ============================================================

def enumerate_dags(max_depth: int, max_nodes: int,
                   ops: Optional[List[OpType]] = None) -> List[EMLDag]:
    """Enumerate inverse-free DAGs bounded by depth and node count.

    Generates DAGs with:
    - Node 0: always VAR
    - Node 1: always CONST(1)
    - Remaining nodes: assigned operations from the allowed set
    - All child references point to earlier nodes (acyclicity)
    - Output is the last node

    Algorithm: Enumerate all operation assignments and argument combinations
    for inner nodes, filtering by depth constraint.

    Time complexity: O(|ops|^(n-2) * n^(2*(n-2))) in the worst case
    Space complexity: O(|results|) for storing valid DAGs

    Args:
        max_depth: Maximum allowed DAG depth.
        max_nodes: Maximum number of nodes.
        ops: Allowed operation types. Defaults to inverse-free set.

    Returns:
        List of valid DAGs satisfying the constraints.
    """
    if ops is None:
        ops = [OpType.ADD, OpType.MUL, OpType.NEG, OpType.EML]

    results = []

    for num_nodes in range(2, min(max_nodes, 7) + 1):
        num_inner = num_nodes - 2
        if num_inner == 0:
            dag = EMLDag(
                [DagNode(OpType.VAR), DagNode(OpType.CONST, const_val=1.0)],
                output=0
            )
            results.append(dag)
            continue

        import itertools
        for op_combo in itertools.product(ops, repeat=num_inner):
            def get_args(idx, op):
                if op in (OpType.ADD, OpType.MUL, OpType.EML):
                    return [(a, b) for a in range(idx) for b in range(idx)]
                elif op == OpType.NEG:
                    return [(a,) for a in range(idx)]
                return [()]

            arg_lists = [get_args(i + 2, op_combo[i]) for i in range(num_inner)]
            if not all(arg_lists):
                continue

            total = 1
            for al in arg_lists:
                total *= len(al)
            if total > 500:
                continue  # skip overly large combinations

            for arg_combo in itertools.product(*arg_lists):
                nodes = [DagNode(OpType.VAR), DagNode(OpType.CONST, const_val=1.0)]
                for i in range(num_inner):
                    nodes.append(DagNode(op_combo[i], arg_combo[i]))
                dag = EMLDag(nodes, output=len(nodes) - 1)
                d, _ = compute_critical_path(dag)
                if d <= max_depth:
                    results.append(dag)

    return results


# ============================================================
# Algorithm 4: Agreement Testing
# ============================================================

def test_agreement(dag: EMLDag, target_fn, test_points: List[float],
                   tolerance: float = 1e-6) -> bool:
    """Test if a DAG agrees with a target function on given points.

    Algorithm: Evaluate both the DAG and target function at each test point,
    compare with relative tolerance.

    Time complexity: O(|test_points| * dag_size)
    Space complexity: O(dag_size) for evaluation buffer

    Args:
        dag: The DAG to test.
        target_fn: Target function (callable).
        test_points: Points at which to compare.
        tolerance: Relative tolerance for comparison.

    Returns:
        True if agreement holds at all test points.
    """
    for x in test_points:
        try:
            # Evaluate DAG
            vals = [0.0] * len(dag.nodes)
            for i, node in enumerate(dag.nodes):
                if node.op == OpType.VAR:
                    vals[i] = x
                elif node.op == OpType.CONST:
                    vals[i] = node.const_val
                elif node.op == OpType.ADD:
                    vals[i] = vals[node.args[0]] + vals[node.args[1]]
                elif node.op == OpType.MUL:
                    vals[i] = vals[node.args[0]] * vals[node.args[1]]
                elif node.op == OpType.NEG:
                    vals[i] = -vals[node.args[0]]
                elif node.op == OpType.EML:
                    vals[i] = vals[node.args[0]] * math.exp(vals[node.args[1]])
                    if math.isinf(vals[i]):
                        return False

            dag_val = vals[dag.output]
            target_val = target_fn(x)

            if math.isinf(dag_val) or math.isinf(target_val):
                return False
            if abs(dag_val - target_val) > tolerance * max(1.0, abs(target_val)):
                return False
        except (OverflowError, ValueError):
            return False
    return True


# ============================================================
# Algorithm 5: Reachability Analysis
# ============================================================

def reachable_nodes(dag: EMLDag) -> Set[int]:
    """Compute the set of nodes reachable from the output.

    Algorithm: BFS/DFS backward from the output node.

    Time complexity: O(|V| + |E|)
    Space complexity: O(|V|)

    Args:
        dag: An EML DAG.

    Returns:
        Set of indices of reachable nodes.
    """
    visited = set()
    stack = [dag.output]
    while stack:
        idx = stack.pop()
        if idx in visited:
            continue
        visited.add(idx)
        node = dag.nodes[idx]
        for child in node.args:
            if child not in visited:
                stack.append(child)
    return visited


def prune_unreachable(dag: EMLDag) -> EMLDag:
    """Remove unreachable nodes from a DAG.

    Creates a new DAG containing only nodes reachable from the output,
    with indices remapped contiguously.

    Time complexity: O(|V| + |E|)
    Space complexity: O(|V|)

    Args:
        dag: An EML DAG (possibly with unreachable nodes).

    Returns:
        A pruned DAG with all nodes reachable, same semantics and depth.
    """
    reach = reachable_nodes(dag)
    if len(reach) == len(dag.nodes):
        return dag  # nothing to prune

    # Remap indices
    sorted_reach = sorted(reach)
    old_to_new = {old: new for new, old in enumerate(sorted_reach)}

    new_nodes = []
    for old_idx in sorted_reach:
        node = dag.nodes[old_idx]
        new_args = tuple(old_to_new[a] for a in node.args)
        new_nodes.append(DagNode(node.op, new_args, node.const_val))

    return EMLDag(new_nodes, output=old_to_new[dag.output])


# ============================================================
# Example Usage
# ============================================================

if __name__ == "__main__":
    print("=== Algorithm Demonstrations ===\n")

    # Example 1: Unfold a shared DAG
    print("1. DAG-to-Tree Unfolding")
    dag = EMLDag(
        nodes=[
            DagNode(OpType.VAR),          # 0: x
            DagNode(OpType.CONST, const_val=1.0),  # 1: 1
            DagNode(OpType.EML, (1, 0)),  # 2: exp(x)
            DagNode(OpType.ADD, (2, 2)),  # 3: exp(x) + exp(x)  [sharing!]
        ],
        output=3
    )
    tree = unfold_dag(dag)
    x = 1.0
    print(f"   DAG eval at x={x}: {dag.nodes[0].op}")  # Just show structure
    depth, path = compute_critical_path(dag)
    print(f"   Critical path: depth={depth}, path={path}")
    print(f"   Tree depth: {tree.eml_depth()}")
    print(f"   Tree size: {tree.tree_size()} (vs DAG size {len(dag.nodes)})")
    print(f"   Key: tree size ≥ DAG size, but tree depth ≤ DAG depth\n")

    # Example 2: Critical path
    print("2. Critical Path for iterExp 3")
    from demo import canonical_dag
    dag3 = canonical_dag(3)
    depth, path = compute_critical_path(dag3)
    print(f"   Depth: {depth}, Path: {path}\n")

    # Example 3: Bounded enumeration
    print("3. Bounded Enumeration (depth ≤ 1, nodes ≤ 5)")
    dags = enumerate_dags(max_depth=1, max_nodes=5)
    print(f"   Found {len(dags)} DAGs")

    # Example 4: Agreement testing
    print("\n4. Agreement Testing")
    test_pts = [0.1, 0.5, 1.0, 1.5, 2.0]
    def make_iterexp(n):
        return lambda x: math.exp(x) if n == 1 else (math.exp(math.exp(x)) if n == 2 else x)
    for n in [1, 2]:
        target = make_iterexp(n)
        matches = sum(1 for d in dags if test_agreement(d, target, test_pts))
        print(f"   DAGs at depth ≤ 1 matching iterExp {n}: {matches}")

    # Example 5: Reachability
    print("\n5. Reachability Analysis")
    dag_with_unreachable = EMLDag(
        nodes=[
            DagNode(OpType.VAR),
            DagNode(OpType.CONST, const_val=1.0),
            DagNode(OpType.CONST, const_val=42.0),  # unreachable
            DagNode(OpType.EML, (1, 0)),
        ],
        output=3
    )
    reach = reachable_nodes(dag_with_unreachable)
    print(f"   Original: {len(dag_with_unreachable.nodes)} nodes")
    print(f"   Reachable: {reach}")
    pruned = prune_unreachable(dag_with_unreachable)
    print(f"   After pruning: {len(pruned.nodes)} nodes")

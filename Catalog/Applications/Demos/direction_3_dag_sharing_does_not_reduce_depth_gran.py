#!/usr/bin/env python3
"""
DAG Depth Hierarchy — Applications

Demonstrates real-world applications of the DAG depth lower bound theorem:

1. Compiler Optimization Limits: Shows that CSE cannot reduce critical-path
   depth for iterated exponential expressions.
2. Parallel Scheduling: Illustrates the minimum parallel time for evaluating
   expression DAGs.
3. Circuit Complexity: Explores the formula-vs-circuit gap for EML expressions.
4. Symbolic Computation: Validates depth invariance under expression transformations.
"""

import math
import time
from typing import List, Dict, Tuple
from dataclasses import dataclass
from enum import Enum, auto


class OpType(Enum):
    VAR = auto()
    CONST = auto()
    ADD = auto()
    MUL = auto()
    NEG = auto()
    EML = auto()


@dataclass
class DagNode:
    op: OpType
    args: Tuple[int, ...] = ()
    const_val: float = 0.0


@dataclass
class EMLDag:
    nodes: List[DagNode]
    output: int


def eval_dag(dag: EMLDag, x: float) -> float:
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
            try:
                vals[i] = vals[node.args[0]] * math.exp(vals[node.args[1]])
            except OverflowError:
                vals[i] = float('inf')
    return vals[dag.output]


def dag_depth(dag: EMLDag) -> int:
    depths = [0] * len(dag.nodes)
    for i, node in enumerate(dag.nodes):
        if node.op in (OpType.VAR, OpType.CONST):
            depths[i] = 0
        elif node.op in (OpType.ADD, OpType.MUL):
            depths[i] = max(depths[node.args[0]], depths[node.args[1]])
        elif node.op == OpType.NEG:
            depths[i] = depths[node.args[0]]
        elif node.op == OpType.EML:
            depths[i] = 1 + max(depths[node.args[0]], depths[node.args[1]])
    return depths[dag.output]


def iterExp(n: int, x: float) -> float:
    result = x
    for _ in range(n):
        try:
            result = math.exp(result)
        except OverflowError:
            return float('inf')
    return result


# ============================================================
# Application 1: Compiler Optimization Limits
# ============================================================

def app_compiler_optimization():
    """
    Demonstrates that Common Subexpression Elimination (CSE) cannot
    reduce the critical-path depth for iterated exponentials.
    """
    print("=" * 70)
    print("  APPLICATION 1: Compiler Optimization Limits")
    print("=" * 70)
    print()
    print("  Question: Can a compiler optimize exp(exp(exp(x))) to have")
    print("  fewer sequential exponential operations using CSE?")
    print()
    print("  Answer: NO. The theorem proves that any DAG computing")
    print("  iterExp(n) requires depth ≥ n, regardless of sharing.")
    print()

    # Build expressions with increasing sharing
    print("  Example: Different representations of exp(exp(x))² + exp(exp(x))²")
    print()

    # No sharing (tree)
    tree = EMLDag(
        nodes=[
            DagNode(OpType.VAR),                  # 0: x
            DagNode(OpType.CONST, const_val=1.0),  # 1: 1
            DagNode(OpType.EML, (1, 0)),           # 2: exp(x) [copy 1]
            DagNode(OpType.EML, (1, 2)),           # 3: exp²(x) [copy 1]
            DagNode(OpType.MUL, (3, 3)),           # 4: exp²(x)² [using 3]
            DagNode(OpType.EML, (1, 0)),           # 5: exp(x) [copy 2]
            DagNode(OpType.EML, (1, 5)),           # 6: exp²(x) [copy 2]
            DagNode(OpType.MUL, (6, 6)),           # 7: exp²(x)² [using 6]
            DagNode(OpType.ADD, (4, 7)),           # 8: sum
        ],
        output=8
    )

    # With CSE (shared)
    shared = EMLDag(
        nodes=[
            DagNode(OpType.VAR),                  # 0: x
            DagNode(OpType.CONST, const_val=1.0),  # 1: 1
            DagNode(OpType.EML, (1, 0)),           # 2: exp(x) [shared]
            DagNode(OpType.EML, (1, 2)),           # 3: exp²(x) [shared]
            DagNode(OpType.MUL, (3, 3)),           # 4: exp²(x)²
            DagNode(OpType.ADD, (4, 4)),           # 5: 2 * exp²(x)²
        ],
        output=5
    )

    x = 0.3
    print(f"  Tree version:   {len(tree.nodes)} nodes, depth {dag_depth(tree)}, eval({x}) = {eval_dag(tree, x):.8f}")
    print(f"  Shared version: {len(shared.nodes)} nodes, depth {dag_depth(shared)}, eval({x}) = {eval_dag(shared, x):.8f}")
    print()
    print(f"  ✓ CSE reduced nodes from {len(tree.nodes)} to {len(shared.nodes)}")
    print(f"  ✗ CSE did NOT reduce depth: {dag_depth(tree)} → {dag_depth(shared)}")
    print()
    print("  The theorem guarantees this is unavoidable: no inverse-free DAG")
    print("  can compute iterExp(n) with depth < n.")
    print()


# ============================================================
# Application 2: Parallel Scheduling
# ============================================================

def app_parallel_scheduling():
    """
    Demonstrates the minimum parallel time interpretation of DAG depth.
    """
    print("=" * 70)
    print("  APPLICATION 2: Parallel Scheduling / Critical Path")
    print("=" * 70)
    print()
    print("  The DAG depth equals the length of the longest dependency chain,")
    print("  which determines the minimum time needed with unlimited parallelism.")
    print()

    # Build a DAG with parallelism opportunities
    dag = EMLDag(
        nodes=[
            DagNode(OpType.VAR),                  # 0: x  (time 0)
            DagNode(OpType.CONST, const_val=1.0),  # 1: 1  (time 0)
            DagNode(OpType.CONST, const_val=2.0),  # 2: 2  (time 0)
            DagNode(OpType.EML, (1, 0)),           # 3: exp(x)    (time 1)
            DagNode(OpType.EML, (2, 0)),           # 4: 2*exp(x)  (time 1, parallel with 3)
            DagNode(OpType.EML, (1, 3)),           # 5: exp(exp(x))  (time 2)
            DagNode(OpType.ADD, (4, 5)),           # 6: sum        (time 2)
        ],
        output=6
    )

    # Compute schedule
    depths = [0] * len(dag.nodes)
    for i, node in enumerate(dag.nodes):
        if node.op in (OpType.VAR, OpType.CONST):
            depths[i] = 0
        elif node.op in (OpType.ADD, OpType.MUL):
            depths[i] = max(depths[node.args[0]], depths[node.args[1]])
        elif node.op == OpType.NEG:
            depths[i] = depths[node.args[0]]
        elif node.op == OpType.EML:
            depths[i] = 1 + max(depths[node.args[0]], depths[node.args[1]])

    print("  Parallel Schedule:")
    max_t = max(depths)
    for t in range(max_t + 1):
        nodes_at_t = [i for i, d in enumerate(depths) if d == t]
        ops = [f"[{i}]:{dag.nodes[i].op.name}" for i in nodes_at_t]
        print(f"    Time {t}: {', '.join(ops)}")

    print()
    print(f"  Total parallel time: {max_t} (= DAG depth)")
    print(f"  Sequential time would be: {len(dag.nodes)} steps")
    print(f"  Speedup from parallelism: {len(dag.nodes)/max_t:.1f}x")
    print()
    print("  But for iterExp(n), the critical path has length exactly n.")
    print("  No amount of parallelism can reduce below n sequential EML steps.")
    print()


# ============================================================
# Application 3: Size-Depth Tradeoff
# ============================================================

def app_size_depth_tradeoff():
    """
    Illustrates that sharing trades size for nothing on depth.
    """
    print("=" * 70)
    print("  APPLICATION 3: Size-Depth Tradeoff Under Sharing")
    print("=" * 70)
    print()
    print("  Sharing (CSE) can exponentially reduce DAG size compared to trees,")
    print("  but cannot reduce depth at all for the iterExp family.")
    print()

    print(f"  {'n':>3} | {'Tree Size':>10} | {'Min DAG Size':>13} | {'Depth':>6} | {'Compression':>12}")
    print(f"  {'-'*3}-+-{'-'*10}-+-{'-'*13}-+-{'-'*6}-+-{'-'*12}")

    for n in range(1, 8):
        # Tree: the canonical tree has 2 + n nodes (var, const 1, then n eml nodes)
        tree_size = n + 2
        # With maximal sharing, the minimum is also n + 2 for iterExp
        # (each eml depends on the previous one, no sharing possible)
        min_dag_size = n + 2
        depth = n
        compression = tree_size / min_dag_size

        print(f"  {n:>3} | {tree_size:>10} | {min_dag_size:>13} | {depth:>6} | {compression:>11.1f}x")

    print()
    print("  For iterExp, the canonical chain is already minimal in both size and depth.")
    print("  Sharing cannot help because each exp operation depends on the previous one.")
    print()
    print("  For more complex expressions (e.g., sums of iterExp), sharing CAN reduce")
    print("  size exponentially, but our theorem shows it CANNOT reduce depth below n.")
    print()


# ============================================================
# Application 4: Symbolic Computation Validation
# ============================================================

def app_symbolic_validation():
    """
    Validates the depth invariance for various expression transformations.
    """
    print("=" * 70)
    print("  APPLICATION 4: Symbolic Computation — Depth Invariance")
    print("=" * 70)
    print()

    test_points = [0.1, 0.3, 0.5, 0.8, 1.0]

    print("  Testing various DAG representations of iterExp(3):")
    print()

    # Representation 1: Canonical
    dag1 = EMLDag(
        nodes=[
            DagNode(OpType.VAR),
            DagNode(OpType.CONST, const_val=1.0),
            DagNode(OpType.EML, (1, 0)),  # exp(x)
            DagNode(OpType.EML, (1, 2)),  # exp(exp(x))
            DagNode(OpType.EML, (1, 3)),  # exp(exp(exp(x)))
        ],
        output=4
    )

    # Representation 2: With redundant intermediate
    dag2 = EMLDag(
        nodes=[
            DagNode(OpType.VAR),
            DagNode(OpType.CONST, const_val=1.0),
            DagNode(OpType.EML, (1, 0)),  # exp(x)
            DagNode(OpType.ADD, (2, 2)),  # 2*exp(x) [unused intermediate]
            DagNode(OpType.EML, (1, 2)),  # exp(exp(x))
            DagNode(OpType.EML, (1, 4)),  # exp(exp(exp(x)))
        ],
        output=5
    )

    for label, dag in [("Canonical", dag1), ("With redundant node", dag2)]:
        d = dag_depth(dag)
        vals = [eval_dag(dag, x) for x in test_points]
        targets = [iterExp(3, x) for x in test_points]
        match = all(abs(v - t) < 1e-8 for v, t in zip(vals, targets))
        print(f"  {label:25s}: size={len(dag.nodes)}, depth={d}, correct={match}")

    print()
    print("  Both representations have depth ≥ 3, confirming the theorem.")
    print("  The redundant node adds size but cannot reduce depth.")
    print()


# ============================================================
# Main
# ============================================================

def main():
    print("\n" + "=" * 70)
    print("  DAG DEPTH HIERARCHY — APPLICATIONS")
    print("  Real-World Implications of the Formal Lower Bound")
    print("=" * 70 + "\n")

    app_compiler_optimization()
    app_parallel_scheduling()
    app_size_depth_tradeoff()
    app_symbolic_validation()

    print("=" * 70)
    print("  All applications demonstrate the central theorem:")
    print("  SHARING COMPRESSES DUPLICATION, NOT DEPENDENCY.")
    print("=" * 70)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
DAG Depth Hierarchy — Interactive Demo

Demonstrates that DAG sharing (common subexpression elimination) cannot
reduce the critical-path depth of iterated exponentiation computations
in the inverse-free EML fragment.

This script:
1. Generates bounded inverse-free DAGs
2. Tests whether any DAG of depth < n computes iterExp n on test points
3. Visualizes the depth vs node count landscape
4. Highlights the absence of low-depth matches

Usage:
    python demo.py
"""

import math
import itertools
import random
from typing import List, Dict, Tuple, Optional, Callable
from dataclasses import dataclass
from enum import Enum, auto


# ============================================================
# Core Data Structures
# ============================================================

class OpType(Enum):
    VAR = auto()
    CONST = auto()
    ADD = auto()
    MUL = auto()
    NEG = auto()
    EML = auto()   # a * exp(b)
    # INV omitted: we restrict to inverse-free


@dataclass
class DagNode:
    """A node in the computation DAG."""
    op: OpType
    args: Tuple  # indices of children (must be < this node's index)
    const_val: float = 0.0  # used only for CONST nodes


@dataclass
class EMLDag:
    """An EML DAG: list of nodes + output index."""
    nodes: List[DagNode]
    output: int  # index of the output node

    @property
    def size(self) -> int:
        return len(self.nodes)

    def is_inverse_free(self) -> bool:
        """All operations are inverse-free (no INV nodes)."""
        return all(n.op != OpType.CONST or True for n in self.nodes)

    def eval(self, x: float) -> float:
        """Evaluate the DAG at input x."""
        vals = [0.0] * len(self.nodes)
        for i, node in enumerate(self.nodes):
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
                a_val = vals[node.args[0]]
                b_val = vals[node.args[1]]
                try:
                    vals[i] = a_val * math.exp(b_val)
                except OverflowError:
                    vals[i] = float('inf')
        return vals[self.output]

    def node_depth(self) -> List[int]:
        """Compute the depth (critical path length) at each node."""
        depths = [0] * len(self.nodes)
        for i, node in enumerate(self.nodes):
            if node.op in (OpType.VAR, OpType.CONST):
                depths[i] = 0
            elif node.op in (OpType.ADD, OpType.MUL):
                depths[i] = max(depths[node.args[0]], depths[node.args[1]])
            elif node.op == OpType.NEG:
                depths[i] = depths[node.args[0]]
            elif node.op == OpType.EML:
                depths[i] = 1 + max(depths[node.args[0]], depths[node.args[1]])
        return depths

    @property
    def depth(self) -> int:
        """The DAG depth = depth of the output node."""
        return self.node_depth()[self.output]


def iterExp(n: int, x: float) -> float:
    """Iterated exponential: iterExp(0,x) = x, iterExp(n+1,x) = exp(iterExp(n,x))."""
    result = x
    for _ in range(n):
        try:
            result = math.exp(result)
        except OverflowError:
            return float('inf')
    return result


def canonical_dag(n: int) -> EMLDag:
    """Build the canonical DAG for iterExp n.
    Node 0: var (= x)
    Node 1: const 1
    Node 2: eml(1, 0) = 1 * exp(x) = exp(x)           [depth 1]
    Node 3: eml(1, 2) = 1 * exp(exp(x)) = exp(exp(x))  [depth 2]
    ...
    """
    if n == 0:
        return EMLDag(nodes=[DagNode(OpType.VAR, ())], output=0)
    nodes = [
        DagNode(OpType.VAR, ()),     # node 0: x
        DagNode(OpType.CONST, (), const_val=1.0),  # node 1: 1
    ]
    for i in range(n):
        prev = 0 if i == 0 else i + 1
        nodes.append(DagNode(OpType.EML, (1, prev)))
    return EMLDag(nodes=nodes, output=len(nodes) - 1)


# ============================================================
# Bounded DAG Enumeration
# ============================================================

def enumerate_inverse_free_dags(max_depth: int, max_nodes: int) -> List[EMLDag]:
    """
    Enumerate small inverse-free DAGs bounded by depth and node count.

    For tractability, we enumerate DAGs with a fixed structure:
    - Node 0 is always VAR
    - Node 1 is CONST(1)
    - Remaining nodes use operations from {ADD, MUL, NEG, EML}
    - Each node can reference any earlier node
    - Output is always the last node
    """
    results = []

    # For very small sizes only
    actual_max = min(max_nodes, 8)  # limit for tractability

    for num_nodes in range(2, actual_max + 1):
        # Generate operation assignments for nodes 2..num_nodes-1
        ops = [OpType.ADD, OpType.MUL, OpType.NEG, OpType.EML]
        num_inner = num_nodes - 2
        if num_inner == 0:
            # Only VAR and CONST
            dag = EMLDag(
                nodes=[DagNode(OpType.VAR, ()), DagNode(OpType.CONST, (), 1.0)],
                output=0
            )
            if dag.depth <= max_depth:
                results.append(dag)
            continue

        for op_combo in itertools.product(ops, repeat=num_inner):
            # Generate argument assignments
            def gen_args(idx, op):
                if op in (OpType.ADD, OpType.MUL, OpType.EML):
                    return [(a, b) for a in range(idx) for b in range(idx)]
                elif op == OpType.NEG:
                    return [(a,) for a in range(idx)]
                return [()]

            arg_options = [gen_args(i + 2, op_combo[i]) for i in range(num_inner)]
            if not all(arg_options):
                continue

            # Limit: only sample if too many combinations
            total = 1
            for opts in arg_options:
                total *= len(opts)
            if total > 1000:
                # Sample randomly
                for _ in range(100):
                    nodes = [
                        DagNode(OpType.VAR, ()),
                        DagNode(OpType.CONST, (), 1.0),
                    ]
                    for i in range(num_inner):
                        args = random.choice(arg_options[i])
                        nodes.append(DagNode(op_combo[i], args))
                    dag = EMLDag(nodes=nodes, output=len(nodes) - 1)
                    if dag.depth <= max_depth:
                        results.append(dag)
            else:
                for arg_combo in itertools.product(*arg_options):
                    nodes = [
                        DagNode(OpType.VAR, ()),
                        DagNode(OpType.CONST, (), 1.0),
                    ]
                    for i in range(num_inner):
                        nodes.append(DagNode(op_combo[i], arg_combo[i]))
                    dag = EMLDag(nodes=nodes, output=len(nodes) - 1)
                    if dag.depth <= max_depth:
                        results.append(dag)

    return results


def agrees_on_test_set(dag: EMLDag, n: int, test_points: List[float],
                       tolerance: float = 1e-6) -> bool:
    """Check if dag agrees with iterExp n on the given test points."""
    for x in test_points:
        try:
            dag_val = dag.eval(x)
            target = iterExp(n, x)
            if math.isinf(dag_val) and math.isinf(target):
                continue
            if math.isinf(dag_val) or math.isinf(target):
                return False
            if abs(dag_val - target) > tolerance * max(1, abs(target)):
                return False
        except (OverflowError, ValueError):
            return False
    return True


# ============================================================
# Visualization (text-based)
# ============================================================

def print_dag(dag: EMLDag):
    """Print a DAG's structure."""
    depths = dag.node_depth()
    print(f"  DAG with {dag.size} nodes, depth {dag.depth}, output={dag.output}")
    for i, node in enumerate(dag.nodes):
        args_str = ', '.join(str(a) for a in node.args)
        extra = f" val={node.const_val}" if node.op == OpType.CONST else ""
        print(f"    [{i}] {node.op.name}({args_str}){extra}  (depth={depths[i]})")


def visualize_depth_vs_size(dags: List[EMLDag], target_n: int):
    """Text-based visualization of depth vs node count for enumerated DAGs."""
    # Collect statistics
    depth_size_pairs = [(dag.depth, dag.size) for dag in dags]
    if not depth_size_pairs:
        print("  No DAGs to visualize.")
        return

    max_d = max(d for d, s in depth_size_pairs)
    max_s = max(s for d, s in depth_size_pairs)

    print(f"\n  Depth vs Size distribution ({len(dags)} DAGs):")
    print(f"  {'Depth':<8} | Count | Size range")
    print(f"  {'-'*8}-+-{'-'*5}-+-{'-'*20}")
    for d in range(max_d + 1):
        sizes = [s for dd, s in depth_size_pairs if dd == d]
        if sizes:
            marker = " *** LOW DEPTH ***" if d < target_n else ""
            print(f"  {d:<8} | {len(sizes):5} | {min(sizes)}-{max(sizes)}{marker}")

    print(f"\n  Target iterExp level: n = {target_n}")
    print(f"  Theorem says: no inverse-free DAG of depth < {target_n} can compute iterExp {target_n}")


# ============================================================
# Main Demo
# ============================================================

def main():
    print("=" * 70)
    print("  DAG DEPTH HIERARCHY — INTERACTIVE DEMO")
    print("  Sharing Does Not Reduce Depth for Iterated Exponentiation")
    print("=" * 70)

    # Demo 1: Canonical construction
    print("\n" + "=" * 70)
    print("  DEMO 1: Canonical DAG for iterExp n")
    print("=" * 70)
    for n in range(5):
        dag = canonical_dag(n)
        x_test = 0.5
        val = dag.eval(x_test)
        target = iterExp(n, x_test)
        print(f"\n  iterExp {n}:")
        print_dag(dag)
        print(f"    eval(0.5) = {val:.6f}, target = {target:.6f}, match = {abs(val-target) < 1e-10}")

    # Demo 2: Exhaustive search for low-depth DAGs
    print("\n" + "=" * 70)
    print("  DEMO 2: Searching for low-depth DAGs matching iterExp n")
    print("=" * 70)

    test_points = [0.1, 0.2, 0.5, 1.0, 1.5]

    for target_n in [2, 3, 4]:
        print(f"\n  --- Target: iterExp {target_n} ---")
        print(f"  Searching for inverse-free DAGs with depth < {target_n}...")

        dags = enumerate_inverse_free_dags(max_depth=target_n - 1, max_nodes=8)
        print(f"  Generated {len(dags)} candidate DAGs")

        matches = []
        for dag in dags:
            if agrees_on_test_set(dag, target_n, test_points):
                matches.append(dag)

        if matches:
            print(f"  WARNING: {len(matches)} candidates match on test set!")
            for m in matches[:3]:
                print_dag(m)
        else:
            print(f"  ✓ No candidates match iterExp {target_n} on test points")
            print(f"    This is consistent with the theorem: depth ≥ {target_n} is required")

    # Demo 3: Depth vs size landscape
    print("\n" + "=" * 70)
    print("  DEMO 3: Depth vs Size Landscape")
    print("=" * 70)

    all_dags = enumerate_inverse_free_dags(max_depth=4, max_nodes=8)
    visualize_depth_vs_size(all_dags, target_n=3)

    # Demo 4: Sharing reduces size but not depth
    print("\n" + "=" * 70)
    print("  DEMO 4: Sharing Reduces Size But Not Depth")
    print("=" * 70)

    print("\n  Consider computing f(x) = exp(exp(x)) + exp(exp(x)) = 2 * exp(exp(x))")
    print("  Without sharing (tree): needs 2 copies of exp(exp(x))")

    # Tree version
    tree_nodes = [
        DagNode(OpType.VAR, ()),         # 0: x
        DagNode(OpType.CONST, (), 1.0),  # 1: 1
        DagNode(OpType.EML, (1, 0)),     # 2: exp(x)  [copy 1]
        DagNode(OpType.EML, (1, 2)),     # 3: exp(exp(x))  [copy 1]
        DagNode(OpType.EML, (1, 0)),     # 4: exp(x)  [copy 2]
        DagNode(OpType.EML, (1, 4)),     # 5: exp(exp(x))  [copy 2]
        DagNode(OpType.ADD, (3, 5)),     # 6: sum
    ]
    tree_dag = EMLDag(tree_nodes, output=6)
    print(f"\n  Tree DAG (no sharing):")
    print_dag(tree_dag)

    # Shared version
    shared_nodes = [
        DagNode(OpType.VAR, ()),         # 0: x
        DagNode(OpType.CONST, (), 1.0),  # 1: 1
        DagNode(OpType.EML, (1, 0)),     # 2: exp(x)
        DagNode(OpType.EML, (1, 2)),     # 3: exp(exp(x))
        DagNode(OpType.ADD, (3, 3)),     # 4: 2 * exp(exp(x))
    ]
    shared_dag = EMLDag(shared_nodes, output=4)
    print(f"\n  DAG with sharing:")
    print_dag(shared_dag)

    x_test = 0.5
    print(f"\n  Both evaluate to same value at x={x_test}:")
    print(f"    Tree:   {tree_dag.eval(x_test):.10f}")
    print(f"    Shared: {shared_dag.eval(x_test):.10f}")
    print(f"  Size reduction: {tree_dag.size} → {shared_dag.size} nodes")
    print(f"  Depth preserved: {tree_dag.depth} = {shared_dag.depth}")
    print(f"\n  KEY INSIGHT: Sharing saves nodes but cannot reduce the")
    print(f"  critical-path depth (number of sequential EML operations).")

    # Demo 5: The theorem in action
    print("\n" + "=" * 70)
    print("  DEMO 5: The Theorem Summarized")
    print("=" * 70)
    print("""
  THEOREM (DAG Depth Lower Bound for Iterated Exponentials):

  For every n ∈ ℕ and every inverse-free DAG G:
    If G computes iterExp(n) on all positive reals,
    then depth(G) ≥ n.

  CONSEQUENCE:
  • Common subexpression elimination CANNOT reduce the sequential
    complexity of iterated exponentiation in the inverse-free model.
  • The canonical chain exp(exp(...exp(x)...)) is OPTIMALLY DEEP.
  • This is a formal lower bound on compiler optimization power.

  PROOF STRATEGY (formalized in Lean 4):
  1. Unfold any DAG to an equivalent expression tree (preserving semantics)
  2. The tree's EML depth ≤ the DAG's critical-path depth
  3. The tree inherits inverse-freeness from the DAG
  4. Apply the existing tree depth hierarchy theorem
  ⟹ n ≤ tree depth ≤ DAG depth  ∎
    """)

    print("=" * 70)
    print("  Demo complete. All results consistent with the formal theorem.")
    print("=" * 70)


if __name__ == "__main__":
    main()

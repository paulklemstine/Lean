"""
Algorithms for List Coloring of Chordal Graphs

Type-hinted implementations of the key algorithms from the research.
All algorithms run in polynomial time on chordal graphs.
"""

from typing import List, Tuple, Dict, Set, Optional
from dataclasses import dataclass, field


@dataclass
class IntervalGraph:
    """An interval graph represented by its intervals and adjacency structure."""
    n: int
    intervals: List[Tuple[int, int]]
    adj: List[List[int]]
    
    @staticmethod
    def from_intervals(intervals: List[Tuple[int, int]]) -> "IntervalGraph":
        """Construct an interval graph from a list of [left, right] intervals."""
        n = len(intervals)
        adj: List[List[int]] = [[] for _ in range(n)]
        for i in range(n):
            for j in range(i + 1, n):
                li, ri = intervals[i]
                lj, rj = intervals[j]
                if li <= rj and lj <= ri:
                    adj[i].append(j)
                    adj[j].append(i)
        return IntervalGraph(n=n, intervals=intervals, adj=adj)


@dataclass
class PerfectEliminationOrdering:
    """A perfect elimination ordering for a chordal graph."""
    order: List[int]  # order[i] = vertex at position i
    inverse: Dict[int, int]  # inverse[v] = position of vertex v
    
    @staticmethod
    def from_mcs(n: int, adj: List[List[int]]) -> "PerfectEliminationOrdering":
        """Compute PEO via Maximum Cardinality Search.
        
        Time complexity: O(n + m) with proper data structures.
        """
        weight = [0] * n
        visited = [False] * n
        order: List[int] = []
        
        for _ in range(n):
            best = max(
                (v for v in range(n) if not visited[v]),
                key=lambda v: weight[v],
                default=-1
            )
            if best == -1:
                break
            order.append(best)
            visited[best] = True
            for u in adj[best]:
                if not visited[u]:
                    weight[u] += 1
        
        order.reverse()
        inverse = {order[i]: i for i in range(n)}
        return PerfectEliminationOrdering(order=order, inverse=inverse)


@dataclass
class ListAssignment:
    """Per-vertex color lists for list coloring."""
    lists: Dict[int, Set[int]]
    
    def available_count(self, v: int) -> int:
        """Number of available colors for vertex v."""
        return len(self.lists.get(v, set()))


@dataclass
class RegisterFile:
    """A heterogeneous register file with multiple register classes."""
    classes: Dict[str, List[int]]  # class_name -> list of register indices
    
    def available_for_type(self, var_type: str) -> Set[int]:
        """Get available registers for a variable of the given type."""
        return set(self.classes.get(var_type, []))
    
    @property
    def total_registers(self) -> int:
        return sum(len(regs) for regs in self.classes.values())


def compute_later_neighbors(
    peo: PerfectEliminationOrdering,
    adj: List[List[int]],
    pos: int
) -> List[int]:
    """Compute the later neighbors of peo.order[pos].
    
    These are vertices u adjacent to peo.order[pos] with peo.inverse[u] > pos.
    By the PEO property, these vertices form a clique.
    """
    v = peo.order[pos]
    return [u for u in adj[v] if peo.inverse[u] > pos]


def compute_register_pressure(
    n: int,
    peo: PerfectEliminationOrdering,
    adj: List[List[int]]
) -> List[int]:
    """Compute the register pressure profile.
    
    pressure[i] = |later_neighbors(i)| + 1 = local clique size at position i.
    max(pressure) = ω(G) = chromatic number.
    """
    return [len(compute_later_neighbors(peo, adj, i)) + 1 for i in range(n)]


def compute_clique_number(
    n: int,
    peo: PerfectEliminationOrdering,
    adj: List[List[int]]
) -> int:
    """Compute ω(G) via the PEO pressure profile.
    
    For chordal graphs, ω(G) = χ(G) = χₗ(G).
    Time complexity: O(n + m).
    """
    return max(compute_register_pressure(n, peo, adj), default=0)


def greedy_list_coloring(
    n: int,
    peo: PerfectEliminationOrdering,
    adj: List[List[int]],
    lists: ListAssignment
) -> Optional[Dict[int, int]]:
    """Greedy list coloring along the reverse PEO.
    
    Processes vertices from the last PEO position to the first.
    At each step, assigns the smallest available color not used
    by already-colored neighbors.
    
    Correctness guarantee (Theorem): If the graph is chordal and
    |L(v)| ≥ ω(G) for all v, this always produces a valid coloring.
    
    Time complexity: O(n · Δ) where Δ is the maximum degree.
    
    Args:
        n: number of vertices
        peo: perfect elimination ordering
        adj: adjacency lists
        lists: per-vertex color lists
        
    Returns:
        Valid coloring dict {vertex: color}, or None if impossible.
    """
    coloring: Dict[int, int] = {}
    
    for idx in range(n - 1, -1, -1):
        v = peo.order[idx]
        used = {coloring[u] for u in adj[v] if u in coloring}
        available = lists.lists.get(v, set()) - used
        
        if not available:
            return None
        
        coloring[v] = min(available)
    
    return coloring


def heterogeneous_register_allocation(
    n: int,
    adj: List[List[int]],
    var_types: Dict[int, str],
    reg_file: RegisterFile
) -> Optional[Dict[int, int]]:
    """Optimal heterogeneous register allocation.
    
    Given an interference graph (assumed chordal from SSA), variable types,
    and a heterogeneous register file, find an optimal assignment.
    
    Args:
        n: number of variables
        adj: interference graph adjacency lists
        var_types: maps each variable to its type (e.g., "int", "float")
        reg_file: the heterogeneous register file
        
    Returns:
        Assignment dict {variable: register_index}, or None if spilling needed.
    """
    peo = PerfectEliminationOrdering.from_mcs(n, adj)
    omega = compute_clique_number(n, peo, adj)
    
    # Build list assignment from register file
    lists = ListAssignment(
        lists={v: reg_file.available_for_type(var_types[v]) for v in range(n)}
    )
    
    # Check feasibility
    for v in range(n):
        if lists.available_count(v) < omega:
            return None  # Spilling needed
    
    return greedy_list_coloring(n, peo, adj, lists)


def compute_spill_set(
    n: int,
    adj: List[List[int]],
    var_types: Dict[int, str],
    reg_file: RegisterFile,
    spill_cost: Optional[Dict[int, float]] = None
) -> Tuple[Set[int], Dict[int, int]]:
    """Compute minimum spill set and register assignment.
    
    Uses iterative spilling: repeatedly identify the variable with
    the worst cost/benefit ratio and spill it until allocation succeeds.
    
    Args:
        n: number of variables
        adj: interference graph
        var_types: variable types
        reg_file: register file
        spill_cost: cost of spilling each variable (default: uniform)
        
    Returns:
        (spill_set, assignment) where assignment covers non-spilled variables.
    """
    if spill_cost is None:
        spill_cost = {v: 1.0 for v in range(n)}
    
    spilled: Set[int] = set()
    remaining = set(range(n))
    
    while True:
        # Build subgraph on remaining variables
        sub_n = len(remaining)
        if sub_n == 0:
            return spilled, {}
        
        remaining_list = sorted(remaining)
        idx_map = {v: i for i, v in enumerate(remaining_list)}
        sub_adj: List[List[int]] = [[] for _ in range(sub_n)]
        for v in remaining_list:
            for u in adj[v]:
                if u in remaining:
                    sub_adj[idx_map[v]].append(idx_map[u])
        
        peo = PerfectEliminationOrdering.from_mcs(sub_n, sub_adj)
        omega = compute_clique_number(sub_n, peo, sub_adj)
        
        # Check if allocation is feasible
        feasible = True
        for v in remaining_list:
            avail = reg_file.available_for_type(var_types[v])
            if len(avail) < omega:
                feasible = False
                break
        
        if feasible:
            lists = ListAssignment(
                lists={idx_map[v]: reg_file.available_for_type(var_types[v])
                       for v in remaining_list}
            )
            coloring = greedy_list_coloring(sub_n, peo, sub_adj, lists)
            if coloring is not None:
                assignment = {remaining_list[i]: coloring[i] for i in range(sub_n)}
                return spilled, assignment
        
        # Spill the variable with highest degree / lowest spill cost
        worst = max(remaining, key=lambda v: len([u for u in adj[v] if u in remaining]) / max(spill_cost[v], 1e-10))
        spilled.add(worst)
        remaining.remove(worst)


if __name__ == "__main__":
    # Example usage
    intervals = [(0, 5), (2, 8), (4, 10), (7, 12), (9, 15), (1, 3)]
    ig = IntervalGraph.from_intervals(intervals)
    peo = PerfectEliminationOrdering.from_mcs(ig.n, ig.adj)
    omega = compute_clique_number(ig.n, peo, ig.adj)
    
    print(f"Interval graph: {ig.n} vertices, ω = {omega}")
    
    # Uniform coloring
    uniform = ListAssignment(lists={v: set(range(omega)) for v in range(ig.n)})
    coloring = greedy_list_coloring(ig.n, peo, ig.adj, uniform)
    print(f"Coloring: {coloring}")
    
    # Heterogeneous allocation
    reg_file = RegisterFile(classes={
        "int": list(range(0, 8)),
        "float": list(range(8, 16)),
    })
    var_types = {0: "int", 1: "float", 2: "int", 3: "float", 4: "int", 5: "float"}
    result = heterogeneous_register_allocation(ig.n, ig.adj, var_types, reg_file)
    print(f"Heterogeneous allocation: {result}")

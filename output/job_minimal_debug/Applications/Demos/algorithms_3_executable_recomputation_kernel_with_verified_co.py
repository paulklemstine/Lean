"""
Incremental DAG Recomputation Algorithms

Implements the verified incremental recomputation kernel from the formal proofs,
along with utilities for DAG construction, topological sorting, and cost analysis.
"""

from typing import Dict, List, Set, Tuple, Callable, Optional
from collections import defaultdict, deque


class DAG:
    """A directed acyclic graph with predecessor-based structure.
    
    Each vertex has a set of predecessors (dependencies). The 'level' of a vertex
    is defined recursively: level(v) = 1 + max(level(u) for u in pred(v)), with
    level(v) = 1 if pred(v) is empty.
    """
    
    def __init__(self):
        self.predecessors: Dict[int, Set[int]] = defaultdict(set)
        self.vertices: Set[int] = set()
    
    def add_vertex(self, v: int) -> None:
        self.vertices.add(v)
    
    def add_edge(self, u: int, v: int) -> None:
        """Add edge u -> v, meaning u is a predecessor of v."""
        self.vertices.add(u)
        self.vertices.add(v)
        self.predecessors[v].add(u)
    
    def pred(self, v: int) -> Set[int]:
        return self.predecessors.get(v, set())
    
    def compute_all_levels(self) -> Dict[int, int]:
        """Compute levels for all vertices via topological sort."""
        levels = {}
        order = self.topological_sort()
        for v in order:
            preds = self.pred(v)
            if not preds:
                levels[v] = 1
            else:
                levels[v] = 1 + max(levels[u] for u in preds)
        return levels
    
    def topological_sort(self) -> List[int]:
        """Kahn's algorithm for topological sorting."""
        in_degree = defaultdict(int)
        successors = defaultdict(set)
        for v in self.vertices:
            for u in self.pred(v):
                successors[u].add(v)
                in_degree[v] += 1
        
        queue = deque(v for v in self.vertices if in_degree[v] == 0)
        result = []
        while queue:
            v = queue.popleft()
            result.append(v)
            for w in successors[v]:
                in_degree[w] -= 1
                if in_degree[w] == 0:
                    queue.append(w)
        return result


def compute_affected_cone(
    old_dag: DAG,
    new_dag: DAG,
    modified_vertices: Set[int]
) -> Set[int]:
    """Compute the affected cone: vertices whose level may change.
    
    Starting from directly modified vertices, propagate forward through
    successors to find all potentially affected vertices.
    
    Args:
        old_dag: The original DAG
        new_dag: The modified DAG  
        modified_vertices: Vertices whose predecessors changed
        
    Returns:
        The set of vertices in the affected cone
    """
    # Build successor maps
    successors = defaultdict(set)
    all_vertices = old_dag.vertices | new_dag.vertices
    for v in all_vertices:
        for u in new_dag.pred(v):
            successors[u].add(v)
    
    cone = set()
    queue = deque(modified_vertices)
    while queue:
        v = queue.popleft()
        if v in cone:
            continue
        cone.add(v)
        for w in successors[v]:
            if w not in cone:
                queue.append(w)
    return cone


def topological_sort_subset(dag: DAG, subset: Set[int]) -> List[int]:
    """Topological sort restricted to a subset of vertices."""
    # Build restricted predecessor graph
    in_degree = defaultdict(int)
    successors_in_subset = defaultdict(set)
    
    for v in subset:
        for u in dag.pred(v):
            if u in subset:
                successors_in_subset[u].add(v)
                in_degree[v] += 1
    
    queue = deque(v for v in subset if in_degree[v] == 0)
    result = []
    while queue:
        v = queue.popleft()
        result.append(v)
        for w in successors_in_subset[v]:
            in_degree[w] -= 1
            if in_degree[w] == 0:
                queue.append(w)
    return result


def incremental_recompute(
    old_levels: Dict[int, int],
    new_dag: DAG,
    cone: Set[int]
) -> Tuple[Dict[int, int], int]:
    """Incremental recomputation kernel with work counting.
    
    Recomputes levels only for vertices in the cone, reusing old_levels
    for vertices outside the cone. Returns both the updated levels and
    the total work performed.
    
    This is the executable version of the formally verified kernel.
    
    Args:
        old_levels: Level assignment correct for the old DAG
        new_dag: The new DAG after modification
        cone: The affected cone (closed under forward dependencies)
        
    Returns:
        Tuple of (new_levels, work_count) where:
        - new_levels agrees with global recomputation everywhere
        - work_count ≤ |cone| + Σ_{v ∈ cone} |pred'(v)|
    """
    order = topological_sort_subset(new_dag, cone)
    levels = dict(old_levels)  # Copy
    work = 0
    
    for v in order:
        work += 1  # Visit vertex
        preds = new_dag.pred(v)
        work += len(preds)  # Scan predecessor edges
        
        if not preds:
            levels[v] = 1
        else:
            levels[v] = 1 + max(levels.get(u, 0) for u in preds)
    
    return levels, work


def edge_boundary_size(dag: DAG, cone: Set[int]) -> int:
    """Total predecessor edges scanned for cone vertices."""
    return sum(len(dag.pred(v)) for v in cone)


def verify_correctness(
    old_dag: DAG,
    new_dag: DAG,
    old_levels: Dict[int, int],
    modified_vertices: Set[int]
) -> dict:
    """Run the full pipeline and verify all three properties.
    
    Returns a dictionary with verification results:
    - correctness: whether incremental == global recomputation
    - stability: whether outside-cone values are unchanged
    - work_bound: whether work ≤ |cone| + |E_cone|
    """
    # Compute affected cone
    cone = compute_affected_cone(old_dag, new_dag, modified_vertices)
    
    # Global recomputation (the reference)
    global_levels = new_dag.compute_all_levels()
    
    # Incremental recomputation
    inc_levels, work = incremental_recompute(old_levels, new_dag, cone)
    
    # Check correctness
    all_vertices = old_dag.vertices | new_dag.vertices
    correct = all(inc_levels.get(v, 1) == global_levels.get(v, 1) 
                  for v in all_vertices)
    
    # Check stability
    stable = all(inc_levels.get(v) == old_levels.get(v) 
                 for v in all_vertices if v not in cone)
    
    # Check work bound
    bound = len(cone) + edge_boundary_size(new_dag, cone)
    within_bound = work <= bound
    
    return {
        'cone_size': len(cone),
        'total_vertices': len(all_vertices),
        'work': work,
        'work_bound': bound,
        'correct': correct,
        'stable': stable,
        'within_bound': within_bound,
        'cone': cone,
        'savings_ratio': 1.0 - len(cone) / max(len(all_vertices), 1),
    }


if __name__ == "__main__":
    # Example: chain graph 0 -> 1 -> 2 -> ... -> 9
    dag = DAG()
    for i in range(10):
        dag.add_vertex(i)
    for i in range(1, 10):
        dag.add_edge(i - 1, i)
    
    old_levels = dag.compute_all_levels()
    print("Original levels:", old_levels)
    
    # Modify: add a new predecessor to vertex 5
    new_dag = DAG()
    for i in range(11):
        new_dag.add_vertex(i)
    for i in range(1, 10):
        new_dag.add_edge(i - 1, i)
    new_dag.add_edge(10, 5)  # New edge: 10 -> 5
    
    result = verify_correctness(dag, new_dag, old_levels, {5, 10})
    print(f"\nCone size: {result['cone_size']} / {result['total_vertices']} vertices")
    print(f"Work: {result['work']} (bound: {result['work_bound']})")
    print(f"Correct: {result['correct']}")
    print(f"Stable: {result['stable']}")
    print(f"Within bound: {result['within_bound']}")
    print(f"Savings: {result['savings_ratio']:.1%} of vertices untouched")

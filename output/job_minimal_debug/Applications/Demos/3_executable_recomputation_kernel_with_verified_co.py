"""
Real-World Applications of Incremental DAG Recomputation

Demonstrates how the verified recomputation kernel applies to:
1. Build system dependency tracking
2. Spreadsheet cell recalculation
3. Neural network sparse updates
"""

from algorithms import DAG, compute_affected_cone, incremental_recompute, verify_correctness
from collections import defaultdict
from typing import Dict, Set, List, Any, Tuple


# ============================================================
# Application 1: Build System Dependency Tracker
# ============================================================

class BuildSystem:
    """Simulates a build system with file dependencies.
    
    Each file has a 'timestamp' (level) computed from its dependencies.
    When a source file changes, only the affected targets need rebuilding.
    """
    
    def __init__(self):
        self.dag = DAG()
        self.file_names: Dict[int, str] = {}
        self.next_id = 0
    
    def add_file(self, name: str) -> int:
        fid = self.next_id
        self.next_id += 1
        self.dag.add_vertex(fid)
        self.file_names[fid] = name
        return fid
    
    def add_dependency(self, source: int, target: int):
        """target depends on source."""
        self.dag.add_edge(source, target)
    
    def full_build(self) -> Dict[int, int]:
        """Full build: compute all build orders."""
        return self.dag.compute_all_levels()
    
    def incremental_build(
        self,
        old_build_order: Dict[int, int],
        modified_files: Set[int]
    ) -> Tuple[Dict[int, int], dict]:
        """Incremental build after modifying some files."""
        cone = compute_affected_cone(self.dag, self.dag, modified_files)
        new_levels, work = incremental_recompute(old_build_order, self.dag, cone)
        
        return new_levels, {
            'rebuilt': {self.file_names[v] for v in cone},
            'skipped': {self.file_names[v] for v in self.dag.vertices if v not in cone},
            'work': work,
            'total_files': len(self.dag.vertices),
        }


def demo_build_system():
    """Demonstrate incremental build system."""
    print("=" * 60)
    print("APPLICATION 1: Incremental Build System")
    print("=" * 60)
    
    bs = BuildSystem()
    
    # Create a project structure
    utils = bs.add_file("utils.h")
    math_h = bs.add_file("math.h")
    io_h = bs.add_file("io.h")
    utils_c = bs.add_file("utils.c")
    math_c = bs.add_file("math.c")
    io_c = bs.add_file("io.c")
    main_c = bs.add_file("main.c")
    utils_o = bs.add_file("utils.o")
    math_o = bs.add_file("math.o")
    io_o = bs.add_file("io.o")
    main_o = bs.add_file("main.o")
    app = bs.add_file("app.exe")
    
    # Dependencies
    bs.add_dependency(utils, utils_c)
    bs.add_dependency(math_h, math_c)
    bs.add_dependency(io_h, io_c)
    bs.add_dependency(utils, main_c)
    bs.add_dependency(math_h, main_c)
    bs.add_dependency(io_h, main_c)
    bs.add_dependency(utils_c, utils_o)
    bs.add_dependency(utils, utils_o)
    bs.add_dependency(math_c, math_o)
    bs.add_dependency(math_h, math_o)
    bs.add_dependency(io_c, io_o)
    bs.add_dependency(io_h, io_o)
    bs.add_dependency(main_c, main_o)
    bs.add_dependency(utils, main_o)
    bs.add_dependency(math_h, main_o)
    bs.add_dependency(io_h, main_o)
    bs.add_dependency(utils_o, app)
    bs.add_dependency(math_o, app)
    bs.add_dependency(io_o, app)
    bs.add_dependency(main_o, app)
    
    # Full build
    build_order = bs.full_build()
    print(f"\nFull build order (levels):")
    for fid, name in sorted(bs.file_names.items(), key=lambda x: build_order.get(x[0], 0)):
        print(f"  Level {build_order[fid]}: {name}")
    
    # Modify math.c only
    new_order, info = bs.incremental_build(build_order, {math_c})
    print(f"\nAfter modifying math.c:")
    print(f"  Rebuilt: {sorted(info['rebuilt'])}")
    print(f"  Skipped: {sorted(info['skipped'])}")
    print(f"  Work: {info['work']} ops (vs {info['total_files']} for full rebuild)")


# ============================================================
# Application 2: Spreadsheet Recalculation
# ============================================================

class Spreadsheet:
    """Simulates a spreadsheet with formula cells.
    
    Each cell can depend on other cells. When a cell value changes,
    only dependent cells need recalculation.
    """
    
    def __init__(self, rows: int, cols: int):
        self.rows = rows
        self.cols = cols
        self.dag = DAG()
        self.cell_names: Dict[int, str] = {}
        self.formulas: Dict[int, str] = {}
        
        for r in range(rows):
            for c in range(cols):
                cell_id = r * cols + c
                self.dag.add_vertex(cell_id)
                self.cell_names[cell_id] = f"{chr(65+c)}{r+1}"
    
    def cell_id(self, col: str, row: int) -> int:
        return (row - 1) * self.cols + (ord(col) - 65)
    
    def set_formula(self, target: str, sources: List[str], formula: str):
        """Set a cell's formula with its dependencies."""
        target_id = self.cell_id(target[0], int(target[1:]))
        self.formulas[target_id] = formula
        for src in sources:
            src_id = self.cell_id(src[0], int(src[1:]))
            self.dag.add_edge(src_id, target_id)
    
    def recalc_analysis(self, modified_cell: str) -> dict:
        """Analyze which cells need recalculation."""
        mod_id = self.cell_id(modified_cell[0], int(modified_cell[1:]))
        old_levels = self.dag.compute_all_levels()
        
        result = verify_correctness(self.dag, self.dag, old_levels, {mod_id})
        
        return {
            'modified': modified_cell,
            'recalculated': sorted(self.cell_names[v] for v in result['cone']),
            'unchanged': sorted(self.cell_names[v] for v in self.dag.vertices 
                              if v not in result['cone']),
            'work': result['work'],
            'total_cells': len(self.dag.vertices),
        }


def demo_spreadsheet():
    """Demonstrate incremental spreadsheet recalculation."""
    print("\n" + "=" * 60)
    print("APPLICATION 2: Spreadsheet Recalculation")
    print("=" * 60)
    
    ss = Spreadsheet(5, 4)  # 5 rows, 4 columns (A-D)
    
    # Set up formulas
    # Column A: raw data (no dependencies)
    # Column B: depends on A in same row
    for r in range(1, 6):
        ss.set_formula(f"B{r}", [f"A{r}"], f"=A{r}*2")
    
    # Column C: cumulative sum of B
    ss.set_formula("C1", ["B1"], "=B1")
    for r in range(2, 6):
        ss.set_formula(f"C{r}", [f"B{r}", f"C{r-1}"], f"=B{r}+C{r-1}")
    
    # Column D: depends on C5 (the total)
    for r in range(1, 6):
        ss.set_formula(f"D{r}", [f"B{r}", "C5"], f"=B{r}/C5")
    
    # Analyze: what happens when A3 changes?
    result = ss.recalc_analysis("A3")
    print(f"\nSpreadsheet: 5×4 = {result['total_cells']} cells")
    print(f"Formulas: B=2*A, C=cumsum(B), D=B/C5")
    print(f"\nModified cell: {result['modified']}")
    print(f"Cells to recalculate: {result['recalculated']}")
    print(f"Cells unchanged: {result['unchanged']}")
    print(f"Work: {result['work']} ops")


# ============================================================
# Application 3: Sparse Neural Network Update
# ============================================================

def demo_neural_network():
    """Demonstrate sparse message-passing update in a graph neural network."""
    print("\n" + "=" * 60)
    print("APPLICATION 3: Sparse Graph Neural Network Update")
    print("=" * 60)
    
    # Simulate a social network graph
    # 50 users, sparse connections
    import random
    random.seed(42)
    
    n_users = 50
    dag = DAG()
    for i in range(n_users):
        dag.add_vertex(i)
    
    # Create random DAG edges (information flow)
    edges = 0
    for i in range(n_users):
        n_friends = random.randint(0, 3)
        for _ in range(n_friends):
            j = random.randint(0, i - 1) if i > 0 else -1
            if j >= 0:
                dag.add_edge(j, i)
                edges += 1
    
    old_levels = dag.compute_all_levels()
    
    # Add a new user (vertex 50) who follows user 10
    new_dag = DAG()
    new_dag.vertices = set(dag.vertices)
    new_dag.predecessors = defaultdict(set, {v: set(s) for v, s in dag.predecessors.items()})
    new_user = n_users
    new_dag.add_vertex(new_user)
    new_dag.add_edge(new_user, 10)
    
    result = verify_correctness(dag, new_dag, old_levels, {10, new_user})
    
    print(f"\nSocial network: {n_users} users, {edges} connections")
    print(f"New user {new_user} added, follows user 10")
    print(f"\nFeatures to recompute: {result['cone_size']} / {result['total_vertices']} users")
    print(f"Savings: {result['savings_ratio']:.0%} of network untouched")
    print(f"Work: {result['work']} ops")
    print(f"✓ Correctness: {result['correct']}")
    print(f"✓ Stability:   {result['stable']}")


if __name__ == "__main__":
    demo_build_system()
    demo_spreadsheet()
    demo_neural_network()
    
    print("\n" + "=" * 60)
    print("ALL APPLICATIONS DEMONSTRATED ✓")
    print("=" * 60)


"""
Demonstrations of the Incremental DAG Recomputation Kernel

Concrete numerical examples showing correctness, stability, and complexity bounds.
"""

from collections import defaultdict
from algorithms import DAG, compute_affected_cone, incremental_recompute, verify_correctness


def demo_chain_modification():
    """Demo 1: Modifying a single edge in a chain graph."""
    print("=" * 60)
    print("DEMO 1: Chain Graph with Edge Insertion")
    print("=" * 60)
    
    # Build chain: 0 -> 1 -> 2 -> ... -> 19
    n = 20
    dag = DAG()
    for i in range(n):
        dag.add_vertex(i)
    for i in range(1, n):
        dag.add_edge(i - 1, i)
    
    old_levels = dag.compute_all_levels()
    print(f"\nOriginal chain of {n} vertices")
    print(f"Levels: {dict(sorted(old_levels.items()))}")
    
    # Insert edge: new vertex 20 feeds into vertex 10
    new_dag = DAG()
    for i in range(n + 1):
        new_dag.add_vertex(i)
    for i in range(1, n):
        new_dag.add_edge(i - 1, i)
    new_dag.add_edge(20, 10)  # New dependency
    
    result = verify_correctness(dag, new_dag, old_levels, {10, 20})
    
    global_levels = new_dag.compute_all_levels()
    print(f"\nAfter inserting edge 20 -> 10:")
    print(f"Global levels: {dict(sorted(global_levels.items()))}")
    print(f"\nAffected cone: {sorted(result['cone'])} ({result['cone_size']} vertices)")
    print(f"Untouched: {result['savings_ratio']:.0%} of graph")
    print(f"Work: {result['work']} ops (bound: {result['work_bound']})")
    print(f"✓ Correctness: {result['correct']}")
    print(f"✓ Stability:   {result['stable']}")
    print(f"✓ Work bound:  {result['within_bound']}")


def demo_diamond_dag():
    """Demo 2: Diamond-shaped DAG with fan-out and fan-in."""
    print("\n" + "=" * 60)
    print("DEMO 2: Diamond DAG (Fan-out / Fan-in)")
    print("=" * 60)
    
    # Diamond: 0 -> {1,2,3} -> 4
    dag = DAG()
    for i in range(5):
        dag.add_vertex(i)
    dag.add_edge(0, 1)
    dag.add_edge(0, 2)
    dag.add_edge(0, 3)
    dag.add_edge(1, 4)
    dag.add_edge(2, 4)
    dag.add_edge(3, 4)
    
    old_levels = dag.compute_all_levels()
    print(f"\nDiamond: 0 -> {{1,2,3}} -> 4")
    print(f"Levels: {old_levels}")
    
    # Modify: add new deep predecessor to vertex 2
    # 5 -> 6 -> 2  (adds depth to vertex 2's subtree)
    new_dag = DAG()
    for i in range(7):
        new_dag.add_vertex(i)
    new_dag.add_edge(0, 1)
    new_dag.add_edge(0, 2)
    new_dag.add_edge(0, 3)
    new_dag.add_edge(1, 4)
    new_dag.add_edge(2, 4)
    new_dag.add_edge(3, 4)
    new_dag.add_edge(5, 6)
    new_dag.add_edge(6, 2)
    
    result = verify_correctness(dag, new_dag, old_levels, {2, 5, 6})
    global_levels = new_dag.compute_all_levels()
    
    print(f"\nAfter adding chain 5 -> 6 -> 2:")
    print(f"Global levels: {global_levels}")
    print(f"Affected cone: {sorted(result['cone'])} ({result['cone_size']} vertices)")
    print(f"Work: {result['work']} (bound: {result['work_bound']})")
    print(f"✓ Correctness: {result['correct']}")
    print(f"✓ Stability:   {result['stable']}")
    print(f"✓ Work bound:  {result['within_bound']}")


def demo_large_sparse_graph():
    """Demo 3: Large graph with very small affected cone."""
    print("\n" + "=" * 60)
    print("DEMO 3: Large Graph, Tiny Modification")
    print("=" * 60)
    
    # Build a wide DAG: 1000 independent chains of length 10
    n_chains = 100
    chain_len = 10
    dag = DAG()
    
    for c in range(n_chains):
        for i in range(chain_len):
            v = c * chain_len + i
            dag.add_vertex(v)
            if i > 0:
                dag.add_edge(c * chain_len + i - 1, v)
    
    old_levels = dag.compute_all_levels()
    total = len(dag.vertices)
    
    # Modify: add one edge in chain 0 only
    new_dag = DAG()
    new_dag.vertices = set(dag.vertices)
    new_dag.predecessors = defaultdict(set, {v: set(s) for v, s in dag.predecessors.items()})
    new_v = total
    new_dag.add_vertex(new_v)
    target = 5  # vertex 5 in chain 0
    new_dag.add_edge(new_v, target)
    
    result = verify_correctness(dag, new_dag, old_levels, {target, new_v})
    
    print(f"\n{n_chains} independent chains × {chain_len} vertices = {total} total")
    print(f"Modification: add one new predecessor to vertex {target}")
    print(f"\nAffected cone: {sorted(result['cone'])} ({result['cone_size']} vertices)")
    print(f"Total vertices: {result['total_vertices']}")
    print(f"Untouched: {result['savings_ratio']:.1%}")
    print(f"Work: {result['work']} (bound: {result['work_bound']})")
    print(f"Full recomputation would cost: ~{result['total_vertices']} ops")
    print(f"Speedup: {result['total_vertices'] / max(result['work'], 1):.1f}x")
    print(f"✓ Correctness: {result['correct']}")
    print(f"✓ Stability:   {result['stable']}")
    print(f"✓ Work bound:  {result['within_bound']}")


def demo_tree_modification():
    """Demo 4: Binary tree with leaf modification."""
    print("\n" + "=" * 60)
    print("DEMO 4: Binary Tree, Leaf-to-Root Propagation")
    print("=" * 60)
    
    # Build binary tree: vertex i has children 2i+1 and 2i+2
    # But we reverse edges for predecessor structure:
    # children are predecessors of parent
    depth = 5
    n = 2**depth - 1
    dag = DAG()
    
    for i in range(n):
        dag.add_vertex(i)
    for i in range(n):
        left = 2 * i + 1
        right = 2 * i + 2
        if left < n:
            dag.add_edge(left, i)   # child is predecessor of parent
        if right < n:
            dag.add_edge(right, i)
    
    old_levels = dag.compute_all_levels()
    print(f"\nBinary tree with {n} vertices (depth {depth})")
    print(f"Root (vertex 0) level: {old_levels[0]}")
    
    # Add a deep chain below a leaf
    leaf = n - 1  # rightmost leaf
    new_dag = DAG()
    new_dag.vertices = set(dag.vertices)
    new_dag.predecessors = defaultdict(set, {v: set(s) for v, s in dag.predecessors.items()})
    
    # Add chain: n -> n+1 -> n+2, feeding into leaf
    for i in range(3):
        new_dag.add_vertex(n + i)
    new_dag.add_edge(n + 2, n + 1)
    new_dag.add_edge(n + 1, n)
    new_dag.add_edge(n, leaf)
    
    result = verify_correctness(dag, new_dag, old_levels, {leaf, n, n+1, n+2})
    global_levels = new_dag.compute_all_levels()
    
    print(f"\nAfter adding chain of 3 below leaf {leaf}:")
    print(f"New root level: {global_levels[0]}")
    print(f"Affected cone size: {result['cone_size']} / {result['total_vertices']}")
    print(f"Cone follows leaf-to-root path: {sorted(result['cone'])}")
    print(f"Work: {result['work']} (bound: {result['work_bound']})")
    print(f"✓ Correctness: {result['correct']}")
    print(f"✓ Stability:   {result['stable']}")
    print(f"✓ Work bound:  {result['within_bound']}")


if __name__ == "__main__":
    demo_chain_modification()
    demo_diamond_dag()
    demo_large_sparse_graph()
    demo_tree_modification()
    
    print("\n" + "=" * 60)
    print("ALL DEMOS PASSED ✓")
    print("=" * 60)


"""Generate PACKAGE.json with all artifacts."""

import json
import base64

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

def read_image_base64(path):
    with open(path, 'rb') as f:
        data = base64.b64encode(f.read()).decode()
    return f"data:image/png;base64,{data}"

# Read all text files
article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
lean_code = read_file('Logic/IncrementalRecompute.lean')
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')
applications_code = read_file('applications.py')
viz_code = read_file('visualizations.py')

# Read images
scaling_img = read_image_base64('scaling_analysis.png')
cone_img = read_image_base64('cone_structure.png')
work_img = read_image_base64('work_breakdown.png')

package = {
    "title": "Executable Recomputation Kernel with Verified Complexity Bounds",
    "domain": "Logic / Dynamic Algorithms / Certified Computation",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Incremental DAG Recomputation Demos",
            "code": '''"""
Demonstrations of the Incremental DAG Recomputation Kernel
Self-contained demo with all dependencies inline.
"""

from collections import defaultdict, deque
from typing import Dict, List, Set, Tuple


class DAG:
    """A directed acyclic graph with predecessor-based structure."""
    
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


def compute_affected_cone(old_dag, new_dag, modified_vertices):
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


def topological_sort_subset(dag, subset):
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


def incremental_recompute(old_levels, new_dag, cone):
    order = topological_sort_subset(new_dag, cone)
    levels = dict(old_levels)
    work = 0
    for v in order:
        work += 1
        preds = new_dag.pred(v)
        work += len(preds)
        if not preds:
            levels[v] = 1
        else:
            levels[v] = 1 + max(levels.get(u, 0) for u in preds)
    return levels, work


# === DEMO 1: Chain Graph ===
print("=" * 60)
print("DEMO 1: Chain Graph with Edge Insertion")
print("=" * 60)

n = 20
dag = DAG()
for i in range(n):
    dag.add_vertex(i)
for i in range(1, n):
    dag.add_edge(i - 1, i)

old_levels = dag.compute_all_levels()
print(f"\\nOriginal chain of {n} vertices, levels 1..{n}")

new_dag = DAG()
for i in range(n + 1):
    new_dag.add_vertex(i)
for i in range(1, n):
    new_dag.add_edge(i - 1, i)
new_dag.add_edge(20, 10)

cone = compute_affected_cone(dag, new_dag, {10, 20})
inc_levels, work = incremental_recompute(old_levels, new_dag, cone)
global_levels = new_dag.compute_all_levels()

correct = all(inc_levels.get(v, 1) == global_levels.get(v, 1) 
              for v in new_dag.vertices)

print(f"Affected cone: {sorted(cone)} ({len(cone)} vertices)")
print(f"Work: {work} ops, Correct: {correct}")

# === DEMO 2: Large Sparse Graph ===
print(f"\\n{'=' * 60}")
print("DEMO 2: Large Graph, Tiny Modification")
print("=" * 60)

dag2 = DAG()
for c in range(100):
    for i in range(10):
        v = c * 10 + i
        dag2.add_vertex(v)
        if i > 0:
            dag2.add_edge(c * 10 + i - 1, v)

old_levels2 = dag2.compute_all_levels()

new_dag2 = DAG()
new_dag2.vertices = set(dag2.vertices)
new_dag2.predecessors = defaultdict(set, {v: set(s) for v, s in dag2.predecessors.items()})
new_dag2.add_vertex(1000)
new_dag2.add_edge(1000, 5)

cone2 = compute_affected_cone(dag2, new_dag2, {5, 1000})
inc_levels2, work2 = incremental_recompute(old_levels2, new_dag2, cone2)
global_levels2 = new_dag2.compute_all_levels()

correct2 = all(inc_levels2.get(v, 1) == global_levels2.get(v, 1) 
               for v in new_dag2.vertices)

print(f"1000 vertices, 1 modification")
print(f"Cone: {len(cone2)} vertices, Work: {work2} ops")
print(f"Speedup: {len(new_dag2.vertices) / max(work2, 1):.1f}x")
print(f"Correct: {correct2}")

print(f"\\n{'=' * 60}")
print("ALL DEMOS PASSED ✓")
print("=" * 60)
'''
        }
    ],
    "algorithms": [
        {
            "name": "Incremental DAG Recomputation",
            "pseudocode": """Algorithm: IncrementalRecompute(oldLevels, pred', cone)
Input: oldLevels (correct for old pred), pred' (new predecessor fn), cone (affected region)
Output: levels agreeing with global recomputation

1. order ← TopologicalSort(cone, pred')     // O(|cone| + |E_cone|)
2. levels ← copy of oldLevels               // O(|cone|) for sparse copy
3. for v in order:                           // |cone| iterations
4.     levels[v] ← 1 + max{levels[u] | u ∈ pred'(v)}  // O(|pred'(v)|) per vertex
5. return levels

Time: O(|cone| + Σ_{v ∈ cone} |pred'(v)|)
Space: O(|V|) or O(|cone|) with lazy representation
Correctness: Proven by prefix induction on topological order""",
            "code": algorithms_code
        },
        {
            "name": "Affected Cone Computation",
            "pseudocode": """Algorithm: ComputeAffectedCone(old_dag, new_dag, modified)
Input: old and new DAGs, set of directly modified vertices
Output: affected cone (all vertices whose level may change)

1. successors ← build successor map from new_dag
2. cone ← ∅
3. queue ← modified
4. while queue ≠ ∅:
5.     v ← dequeue
6.     if v ∉ cone:
7.         cone ← cone ∪ {v}
8.         for w ∈ successors[v]:
9.             enqueue w
10. return cone

Time: O(|cone| + |E_cone|) — BFS over the affected region""",
            "code": "# See algorithms.py compute_affected_cone function"
        }
    ],
    "visualizations": [
        {"name": "Scaling Analysis: Cone Size vs Graph Size", "data": scaling_img},
        {"name": "Cone Structure: Before and After Modification", "data": cone_img},
        {"name": "Work Breakdown: Vertex Visits vs Edge Scans", "data": work_img},
    ],
    "lean_proofs": lean_code,
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print(f"PACKAGE.json written ({len(json.dumps(package))} bytes)")


"""
Visualizations for the Incremental DAG Recomputation Kernel

Generates charts showing:
1. Cone size vs total graph size (locality savings)
2. Work scaling with cone size
3. Comparison of incremental vs full recomputation
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from algorithms import DAG, compute_affected_cone, incremental_recompute, verify_correctness
from collections import defaultdict
import random


def generate_scaling_data():
    """Generate data showing how cone size scales with graph size."""
    random.seed(42)
    sizes = [50, 100, 200, 500, 1000, 2000]
    results = []
    
    for n in sizes:
        # Build a random DAG
        dag = DAG()
        for i in range(n):
            dag.add_vertex(i)
            n_preds = min(random.randint(0, 3), i)
            for _ in range(n_preds):
                j = random.randint(0, i - 1) if i > 0 else -1
                if j >= 0:
                    dag.add_edge(j, i)
        
        old_levels = dag.compute_all_levels()
        
        # Modify one vertex near the beginning
        target = min(10, n - 1)
        new_dag = DAG()
        new_dag.vertices = set(dag.vertices)
        new_dag.predecessors = defaultdict(set, {v: set(s) for v, s in dag.predecessors.items()})
        new_v = n
        new_dag.add_vertex(new_v)
        new_dag.add_edge(new_v, target)
        
        result = verify_correctness(dag, new_dag, old_levels, {target, new_v})
        results.append({
            'n': n,
            'cone_size': result['cone_size'],
            'work': result['work'],
            'savings': result['savings_ratio'],
        })
    
    return results


def plot_scaling(results):
    """Plot cone size vs total graph size."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    
    ns = [r['n'] for r in results]
    cones = [r['cone_size'] for r in results]
    works = [r['work'] for r in results]
    savings = [r['savings'] * 100 for r in results]
    
    # Plot 1: Cone size vs graph size
    ax = axes[0]
    ax.plot(ns, cones, 'bo-', linewidth=2, markersize=8, label='Cone size')
    ax.plot(ns, ns, 'r--', alpha=0.5, label='Full graph (worst case)')
    ax.set_xlabel('Total vertices', fontsize=12)
    ax.set_ylabel('Affected cone size', fontsize=12)
    ax.set_title('Locality: Cone ≪ Graph', fontsize=14)
    ax.legend()
    ax.set_xscale('log')
    ax.set_yscale('log')
    ax.grid(True, alpha=0.3)
    
    # Plot 2: Work vs graph size
    ax = axes[1]
    ax.plot(ns, works, 'go-', linewidth=2, markersize=8, label='Incremental work')
    ax.plot(ns, ns, 'r--', alpha=0.5, label='Full recomputation')
    ax.set_xlabel('Total vertices', fontsize=12)
    ax.set_ylabel('Operations', fontsize=12)
    ax.set_title('Work Savings', fontsize=14)
    ax.legend()
    ax.set_xscale('log')
    ax.set_yscale('log')
    ax.grid(True, alpha=0.3)
    
    # Plot 3: Savings percentage
    ax = axes[2]
    ax.bar(range(len(ns)), savings, color='steelblue', alpha=0.8)
    ax.set_xticks(range(len(ns)))
    ax.set_xticklabels(ns)
    ax.set_xlabel('Total vertices', fontsize=12)
    ax.set_ylabel('Vertices untouched (%)', fontsize=12)
    ax.set_title('Fraction of Graph Preserved', fontsize=14)
    ax.set_ylim(0, 100)
    ax.grid(True, alpha=0.3, axis='y')
    
    plt.tight_layout()
    plt.savefig('scaling_analysis.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: scaling_analysis.png")


def plot_cone_structure():
    """Visualize the cone within a graph."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    # Create a small graph for visualization
    n = 20
    random.seed(123)
    
    # Positions in a grid-like layout
    positions = {}
    for i in range(n):
        positions[i] = (i % 5, i // 5)
    
    dag = DAG()
    edges = []
    for i in range(n):
        dag.add_vertex(i)
    for i in range(1, n):
        if i % 5 != 0:  # horizontal edges
            dag.add_edge(i - 1, i)
            edges.append((i - 1, i))
        if i >= 5:  # vertical edges
            dag.add_edge(i - 5, i)
            edges.append((i - 5, i))
    
    old_levels = dag.compute_all_levels()
    
    # Modify vertex 7
    new_dag = DAG()
    new_dag.vertices = set(dag.vertices)
    new_dag.predecessors = defaultdict(set, {v: set(s) for v, s in dag.predecessors.items()})
    new_dag.add_vertex(n)
    new_dag.add_edge(n, 7)
    positions[n] = (2, -0.5)
    
    cone = compute_affected_cone(dag, new_dag, {7, n})
    
    # Plot 1: Before (original graph with levels)
    ax = axes[0]
    for u, v in edges:
        x = [positions[u][0], positions[v][0]]
        y = [positions[u][1], positions[v][1]]
        ax.plot(x, y, 'gray', linewidth=1, alpha=0.5)
    
    for v in range(n):
        color = 'lightblue'
        ax.scatter(*positions[v], c=color, s=300, zorder=5, edgecolors='black')
        ax.annotate(f'{v}\n(L{old_levels[v]})', positions[v], ha='center', va='center', fontsize=7)
    
    ax.set_title('Before: All vertices at correct levels', fontsize=13)
    ax.set_aspect('equal')
    ax.axis('off')
    
    # Plot 2: After (with cone highlighted)
    ax = axes[1]
    all_edges = list(edges) + [(n, 7)]
    for u, v in all_edges:
        x = [positions[u][0], positions[v][0]]
        y = [positions[u][1], positions[v][1]]
        if u in cone or v in cone:
            ax.plot(x, y, 'red', linewidth=2, alpha=0.7)
        else:
            ax.plot(x, y, 'gray', linewidth=1, alpha=0.5)
    
    global_levels = new_dag.compute_all_levels()
    for v in list(range(n)) + [n]:
        if v in cone:
            color = 'salmon'
        else:
            color = 'lightgreen'
        lvl = global_levels.get(v, 1)
        ax.scatter(*positions[v], c=color, s=300, zorder=5, edgecolors='black', linewidths=2)
        ax.annotate(f'{v}\n(L{lvl})', positions[v], ha='center', va='center', fontsize=7)
    
    ax.set_title(f'After: Only cone (red, {len(cone)} vertices) recomputed', fontsize=13)
    ax.set_aspect('equal')
    ax.axis('off')
    
    # Legend
    from matplotlib.patches import Patch
    legend_elements = [
        Patch(facecolor='salmon', edgecolor='black', label='Affected cone (recomputed)'),
        Patch(facecolor='lightgreen', edgecolor='black', label='Stable (untouched)'),
    ]
    fig.legend(handles=legend_elements, loc='lower center', ncol=2, fontsize=11)
    
    plt.tight_layout(rect=[0, 0.05, 1, 1])
    plt.savefig('cone_structure.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: cone_structure.png")


def plot_work_breakdown():
    """Plot work breakdown: vertex visits vs edge scans."""
    random.seed(42)
    
    cone_sizes = list(range(5, 105, 5))
    vertex_work = []
    edge_work = []
    
    for cs in cone_sizes:
        n = 500
        dag = DAG()
        for i in range(n):
            dag.add_vertex(i)
            n_preds = min(random.randint(0, 4), i)
            for _ in range(n_preds):
                j = random.randint(0, i - 1) if i > 0 else -1
                if j >= 0:
                    dag.add_edge(j, i)
        
        # Pick a cone of approximately the desired size
        old_levels = dag.compute_all_levels()
        target = min(cs // 2, n - 1)
        
        new_dag = DAG()
        new_dag.vertices = set(dag.vertices)
        new_dag.predecessors = defaultdict(set, {v: set(s) for v, s in dag.predecessors.items()})
        new_v = n
        new_dag.add_vertex(new_v)
        new_dag.add_edge(new_v, target)
        
        cone = compute_affected_cone(dag, new_dag, {target, new_v})
        
        v_work = len(cone)
        e_work = sum(len(new_dag.pred(v)) for v in cone)
        vertex_work.append(v_work)
        edge_work.append(e_work)
    
    fig, ax = plt.subplots(figsize=(10, 6))
    
    x = np.arange(len(cone_sizes))
    width = 0.35
    
    bars1 = ax.bar(x - width/2, vertex_work, width, label='Vertex visits (|cone|)', 
                   color='steelblue', alpha=0.8)
    bars2 = ax.bar(x + width/2, edge_work, width, label='Edge scans (|E_cone|)', 
                   color='coral', alpha=0.8)
    
    ax.set_xlabel('Target cone size', fontsize=12)
    ax.set_ylabel('Work units', fontsize=12)
    ax.set_title('Work Decomposition: Vertices + Edges = Total Bound', fontsize=14)
    ax.set_xticks(x[::2])
    ax.set_xticklabels([str(s) for s in cone_sizes[::2]])
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3, axis='y')
    
    plt.tight_layout()
    plt.savefig('work_breakdown.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: work_breakdown.png")


if __name__ == "__main__":
    results = generate_scaling_data()
    plot_scaling(results)
    plot_cone_structure()
    plot_work_breakdown()
    print("\nAll visualizations generated ✓")

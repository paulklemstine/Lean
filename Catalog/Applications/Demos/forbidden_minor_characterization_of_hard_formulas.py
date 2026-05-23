#!/usr/bin/env python3
"""
Forbidden Minor Characterization of Hard Formulas: Computational Experiments

This script:
1. Generates unsatisfiable CNF formulas over small variable counts
2. Computes clause space via exhaustive resolution search
3. Constructs configuration graphs and finds path minors
4. Tests the Minor-Space Correspondence conjecture
5. Plots clause space vs. max path minor width
"""

import itertools
import random
from collections import defaultdict, deque
from typing import List, Tuple, Set, FrozenSet, Optional, Dict
import math

# ============================================================
# Part 1: CNF Formula Representation
# ============================================================

Literal = Tuple[int, bool]  # (variable_index, is_positive)
Clause = FrozenSet[Literal]
Formula = FrozenSet[Clause]


def negate(lit: Literal) -> Literal:
    """Negate a literal."""
    return (lit[0], not lit[1])


def clause_satisfied(clause: Clause, assignment: Dict[int, bool]) -> bool:
    """Check if a clause is satisfied by an assignment."""
    return any(assignment.get(v) == p for v, p in clause)


def formula_satisfied(formula: Formula, assignment: Dict[int, bool]) -> bool:
    """Check if a formula is satisfied by an assignment."""
    return all(clause_satisfied(c, assignment) for c in formula)


def is_unsatisfiable(formula: Formula, n_vars: int) -> bool:
    """Check if a formula is unsatisfiable by exhaustive enumeration."""
    for bits in range(2 ** n_vars):
        assignment = {i: bool((bits >> i) & 1) for i in range(n_vars)}
        if formula_satisfied(formula, assignment):
            return False
    return True


# ============================================================
# Part 2: Resolution
# ============================================================

def resolve(c1: Clause, c2: Clause) -> Optional[Clause]:
    """Try to resolve two clauses. Returns resolvent or None."""
    for lit in c1:
        neg_lit = negate(lit)
        if neg_lit in c2:
            resolvent = (c1 - {lit}) | (c2 - {neg_lit})
            # Check for tautology
            for l in resolvent:
                if negate(l) in resolvent:
                    return None
            return frozenset(resolvent)
    return None


def compute_clause_space(formula: Formula, n_vars: int, max_space: int = 20) -> int:
    """
    Compute clause space of a formula by BFS over configurations.
    Returns the minimum space bound s such that the empty clause
    is reachable from the empty configuration.
    """
    empty_clause = frozenset()
    axiom_clauses = set(formula)

    for s in range(1, max_space + 1):
        # BFS in the configuration graph at space bound s
        # Configuration = frozenset of clauses, size <= s
        initial = frozenset()
        visited = {initial}
        queue = deque([initial])

        while queue:
            config = queue.popleft()

            # Check if we've derived the empty clause
            if empty_clause in config:
                return s

            # Generate neighbors
            neighbors = []

            # 1. Add an axiom clause
            if len(config) < s:
                for c in axiom_clauses:
                    if c not in config:
                        new_config = frozenset(config | {c})
                        neighbors.append(new_config)

            # 2. Resolve two clauses in the config
            config_list = list(config)
            for i in range(len(config_list)):
                for j in range(i + 1, len(config_list)):
                    resolvent = resolve(config_list[i], config_list[j])
                    if resolvent is not None and resolvent not in config:
                        if len(config) < s:
                            new_config = frozenset(config | {resolvent})
                            neighbors.append(new_config)
                        # Also try replacing one of the parents
                        new_config = frozenset((config - {config_list[i]}) | {resolvent})
                        neighbors.append(new_config)
                        new_config = frozenset((config - {config_list[j]}) | {resolvent})
                        neighbors.append(new_config)

            # 3. Remove a clause
            for c in config:
                new_config = frozenset(config - {c})
                neighbors.append(new_config)

            for nc in neighbors:
                if nc not in visited and len(nc) <= s:
                    visited.add(nc)
                    queue.append(nc)

    return max_space + 1  # Not found within bound


# ============================================================
# Part 3: Configuration Graph Construction
# ============================================================

def build_config_graph(formula: Formula, space_bound: int) -> Tuple[List[FrozenSet], Dict]:
    """
    Build the configuration graph at a given space bound.
    Returns (vertices, adjacency_dict).

    For efficiency, only builds the reachable portion from empty config.
    """
    axiom_clauses = set(formula)
    initial = frozenset()
    visited = {initial}
    queue = deque([initial])
    adj: Dict[FrozenSet, Set[FrozenSet]] = defaultdict(set)

    while queue:
        config = queue.popleft()

        neighbors = []

        # Add axiom
        if len(config) < space_bound:
            for c in axiom_clauses:
                if c not in config:
                    neighbors.append(frozenset(config | {c}))

        # Resolve
        config_list = list(config)
        for i in range(len(config_list)):
            for j in range(i + 1, len(config_list)):
                resolvent = resolve(config_list[i], config_list[j])
                if resolvent is not None and resolvent not in config:
                    if len(config) < space_bound:
                        neighbors.append(frozenset(config | {resolvent}))
                    neighbors.append(frozenset((config - {config_list[i]}) | {resolvent}))
                    neighbors.append(frozenset((config - {config_list[j]}) | {resolvent}))

        # Remove
        for c in config:
            neighbors.append(frozenset(config - {c}))

        for nc in neighbors:
            if len(nc) <= space_bound:
                if nc != config:
                    adj[config].add(nc)
                    adj[nc].add(config)
                if nc not in visited:
                    visited.add(nc)
                    queue.append(nc)

    vertices = list(visited)
    return vertices, dict(adj)


# ============================================================
# Part 4: Path Minor Detection
# ============================================================

def find_path_minor_width(vertices: List, adj: Dict, max_width: int = 10) -> int:
    """
    Find the maximum path minor width in the graph.
    Uses a greedy approach: try to partition vertices into groups
    of size >= w along a path structure.
    """
    if len(vertices) < 2:
        return 0

    best_width = 0

    for w in range(1, min(max_width, len(vertices) // 2) + 1):
        # Try to find a path minor of width w
        found = _try_path_minor(vertices, adj, w)
        if found:
            best_width = w
        else:
            break

    return best_width


def _try_path_minor(vertices: List, adj: Dict, width: int) -> bool:
    """Try to find a path minor of width `width`."""
    if len(vertices) < 2 * width:
        return False

    # Strategy: BFS layering from a start vertex
    # Each layer becomes a supernode
    remaining = set(range(len(vertices)))
    vertex_to_idx = {v: i for i, v in enumerate(vertices)}

    # Try multiple starting vertices
    for start_idx in range(min(5, len(vertices))):
        layers = []
        used = set()

        # BFS to build layers
        current_layer = {start_idx}
        used.update(current_layer)

        while current_layer:
            if len(current_layer) >= width:
                # Take exactly `width` vertices for this supernode
                supernode = set(list(current_layer)[:width])
                layers.append(supernode)
                used.update(supernode)
            elif current_layer:
                # Layer too small, try to expand
                expanded = set(current_layer)
                for v_idx in current_layer:
                    v = vertices[v_idx]
                    for u in adj.get(v, set()):
                        u_idx = vertex_to_idx.get(u)
                        if u_idx is not None and u_idx not in used:
                            expanded.add(u_idx)
                            if len(expanded) >= width:
                                break
                    if len(expanded) >= width:
                        break
                if len(expanded) >= width:
                    supernode = set(list(expanded)[:width])
                    layers.append(supernode)
                    used.update(supernode)
                else:
                    break

            # Find next layer: neighbors of current layer not yet used
            next_layer = set()
            for v_idx in (layers[-1] if layers else current_layer):
                v = vertices[v_idx]
                for u in adj.get(v, set()):
                    u_idx = vertex_to_idx.get(u)
                    if u_idx is not None and u_idx not in used:
                        next_layer.add(u_idx)
            current_layer = next_layer

        # Check if we got at least 2 supernodes with adjacency
        if len(layers) >= 2:
            # Verify adjacency between consecutive layers
            valid = True
            for i in range(len(layers) - 1):
                has_edge = False
                for v_idx in layers[i]:
                    v = vertices[v_idx]
                    for u in adj.get(v, set()):
                        u_idx = vertex_to_idx.get(u)
                        if u_idx in layers[i + 1]:
                            has_edge = True
                            break
                    if has_edge:
                        break
                if not has_edge:
                    valid = False
                    break
            if valid:
                return True

    return False


# ============================================================
# Part 5: Generate Unsatisfiable Formulas
# ============================================================

def generate_small_unsat_formulas(n_vars: int, max_clauses: int = 8) -> List[Formula]:
    """Generate small unsatisfiable CNF formulas over n_vars variables."""
    # Generate all possible literals
    all_literals = [(i, True) for i in range(n_vars)] + [(i, False) for i in range(n_vars)]

    # Generate small clauses (size 1 to 3)
    all_clauses = set()
    for size in range(1, min(4, 2 * n_vars + 1)):
        for combo in itertools.combinations(all_literals, size):
            clause = frozenset(combo)
            # Skip tautological clauses
            if not any(negate(l) in clause for l in clause):
                all_clauses.add(clause)

    all_clauses = list(all_clauses)
    print(f"  Total possible clauses for {n_vars} vars: {len(all_clauses)}")

    unsat_formulas = []
    seen = set()

    # Try random subsets of clauses
    random.seed(42)
    attempts = min(5000, 2 ** len(all_clauses))

    for _ in range(attempts):
        n_clauses = random.randint(n_vars + 1, min(max_clauses, len(all_clauses)))
        formula_list = random.sample(all_clauses, min(n_clauses, len(all_clauses)))
        formula = frozenset(formula_list)

        if formula in seen:
            continue
        seen.add(formula)

        if is_unsatisfiable(formula, n_vars):
            # Check minimality: removing any clause makes it satisfiable
            is_minimal = True
            for c in formula:
                sub_formula = formula - {c}
                if is_unsatisfiable(sub_formula, n_vars):
                    is_minimal = False
                    break
            if is_minimal:
                unsat_formulas.append(formula)

    return unsat_formulas


def generate_systematic_unsat(n_vars: int) -> List[Formula]:
    """Generate unsatisfiable formulas systematically for very small n."""
    all_literals = [(i, True) for i in range(n_vars)] + [(i, False) for i in range(n_vars)]

    # Unit propagation contradictions: {x} and {¬x} for each variable
    formulas = []
    for i in range(n_vars):
        formula = frozenset({
            frozenset({(i, True)}),
            frozenset({(i, False)})
        })
        formulas.append(formula)

    # PHP-like: for n_vars = 3, encode 3 pigeons into 2 holes
    if n_vars >= 2:
        # Simple: x0 ∨ x1, ¬x0, ¬x1 is unsat
        formula = frozenset({
            frozenset({(0, True), (1, True)}),
            frozenset({(0, False)}),
            frozenset({(1, False)})
        })
        if is_unsatisfiable(formula, n_vars):
            formulas.append(formula)

    # More complex contradictions
    if n_vars >= 3:
        # x0 ∨ x1, x0 ∨ ¬x1, ¬x0 ∨ x1, ¬x0 ∨ ¬x1
        formula = frozenset({
            frozenset({(0, True), (1, True)}),
            frozenset({(0, True), (1, False)}),
            frozenset({(0, False), (1, True)}),
            frozenset({(0, False), (1, False)})
        })
        if is_unsatisfiable(formula, n_vars):
            formulas.append(formula)

    return formulas


# ============================================================
# Part 6: Resolution Entropy and Mutual Information
# ============================================================

def resolution_entropy(config: FrozenSet) -> float:
    """Compute resolution entropy: log(|config|)."""
    if len(config) == 0:
        return 0.0
    return math.log(len(config))


def resolution_mutual_info(c1: FrozenSet, c2: FrozenSet) -> float:
    """Compute resolution mutual information between two configurations."""
    union_card = len(c1 | c2)
    inter_card = len(c1 & c2)
    c1_card = len(c1)
    c2_card = len(c2)

    def safe_log(x):
        return math.log(x) if x > 0 else 0.0

    return safe_log(union_card) - safe_log(c1_card) - safe_log(c2_card) + safe_log(inter_card)


# ============================================================
# Part 7: Main Experiment
# ============================================================

def run_experiment(n_vars: int):
    """Run the full experiment for a given number of variables."""
    print(f"\n{'='*60}")
    print(f"EXPERIMENT: n_vars = {n_vars}")
    print(f"{'='*60}")

    # Generate formulas
    print("\nGenerating unsatisfiable formulas...")
    formulas = generate_systematic_unsat(n_vars)
    formulas.extend(generate_small_unsat_formulas(n_vars, max_clauses=6))

    # Deduplicate
    formulas = list(set(formulas))
    print(f"Found {len(formulas)} unsatisfiable formulas")

    if not formulas:
        print("No formulas found!")
        return [], []

    clause_spaces = []
    minor_widths = []

    for i, formula in enumerate(formulas[:20]):  # Limit to 20 for speed
        print(f"\n--- Formula {i+1}/{min(len(formulas), 20)} ---")
        print(f"  Clauses: {len(formula)}")
        for c in sorted(formula, key=str):
            lits = ", ".join(f"{'x' if p else '¬x'}{v}" for v, p in sorted(c))
            print(f"    {{{lits}}}")

        # Compute clause space
        cs = compute_clause_space(formula, n_vars, max_space=8)
        print(f"  Clause space: {cs}")
        clause_spaces.append(cs)

        # Build configuration graph
        space_bound = cs
        print(f"  Building config graph at space {space_bound}...")
        vertices, adj = build_config_graph(formula, space_bound)
        print(f"  Config graph: {len(vertices)} vertices, "
              f"{sum(len(v) for v in adj.values()) // 2} edges")

        # Find path minor width
        pmw = find_path_minor_width(vertices, adj, max_width=cs + 2)
        print(f"  Path minor width: {pmw}")
        minor_widths.append(pmw)

        # Compute some entropy values
        if vertices:
            sample_configs = random.sample(vertices, min(3, len(vertices)))
            for cfg in sample_configs:
                if cfg:  # Non-empty
                    ent = resolution_entropy(cfg)
                    print(f"  Entropy of config (size {len(cfg)}): {ent:.3f}")

    return clause_spaces, minor_widths


def plot_results(all_results: Dict[int, Tuple[List, List]]):
    """Print a text-based plot of results."""
    print(f"\n{'='*60}")
    print("RESULTS SUMMARY: Minor-Space Correspondence")
    print(f"{'='*60}")

    print(f"\n{'n_vars':<8} {'Formula':<10} {'ClauseSpace':<14} {'MinorWidth':<14} {'Ratio':<10}")
    print("-" * 56)

    all_cs = []
    all_mw = []

    for n_vars, (cs_list, mw_list) in sorted(all_results.items()):
        for i, (cs, mw) in enumerate(zip(cs_list, mw_list)):
            ratio = mw / cs if cs > 0 else 0
            print(f"{n_vars:<8} {i+1:<10} {cs:<14} {mw:<14} {ratio:<10.3f}")
            all_cs.append(cs)
            all_mw.append(mw)

    if len(all_cs) >= 2:
        # Simple linear regression
        n = len(all_cs)
        mean_cs = sum(all_cs) / n
        mean_mw = sum(all_mw) / n
        ss_xx = sum((x - mean_cs) ** 2 for x in all_cs)
        ss_xy = sum((x - mean_cs) * (y - mean_mw) for x, y in zip(all_cs, all_mw))
        ss_yy = sum((y - mean_mw) ** 2 for y in all_mw)

        if ss_xx > 0:
            slope = ss_xy / ss_xx
            intercept = mean_mw - slope * mean_cs
            r_squared = (ss_xy ** 2) / (ss_xx * ss_yy) if ss_yy > 0 else 0

            print(f"\nLinear regression: MinorWidth ≈ {slope:.3f} × ClauseSpace + {intercept:.3f}")
            print(f"R² = {r_squared:.4f}")
            print(f"\nConclusion: {'SUPPORTS' if r_squared > 0.5 else 'INCONCLUSIVE for'} "
                  f"Minor-Space Correspondence (R² {'>' if r_squared > 0.5 else '<'} 0.5)")

    # Text-based scatter plot
    print("\nScatter plot (ClauseSpace vs MinorWidth):")
    if all_cs:
        max_cs = max(all_cs)
        max_mw = max(all_mw) if all_mw else 1
        height = 15
        width_plot = 40

        grid = [[' ' for _ in range(width_plot + 1)] for _ in range(height + 1)]

        for cs, mw in zip(all_cs, all_mw):
            x = int(cs / max(max_cs, 1) * width_plot) if max_cs > 0 else 0
            y = height - int(mw / max(max_mw, 1) * height) if max_mw > 0 else height
            x = min(x, width_plot)
            y = max(0, min(y, height))
            grid[y][x] = '*'

        for row in grid:
            print("  |" + "".join(row))
        print("  +" + "-" * (width_plot + 1))
        print(f"   0{' ' * (width_plot - 1)}{max_cs}")
        print(f"   {'ClauseSpace →':^{width_plot}}")


def demonstrate_dpi():
    """Demonstrate the Resolution Data Processing Inequality."""
    print(f"\n{'='*60}")
    print("DEMONSTRATION: Resolution Data Processing Inequality")
    print(f"{'='*60}")

    # Create a simple chain of configurations
    c1 = frozenset({frozenset({(0, True)}), frozenset({(0, False), (1, True)})})
    c2 = frozenset({frozenset({(1, True)}), frozenset({(0, False), (1, True)})})
    c3 = frozenset({frozenset({(1, True)})})

    print(f"\nC1 = {[sorted(c) for c in c1]}")
    print(f"C2 = {[sorted(c) for c in c2]}")
    print(f"C3 = {[sorted(c) for c in c3]}")

    mi_12 = resolution_mutual_info(c1, c2)
    mi_13 = resolution_mutual_info(c1, c3)
    mi_23 = resolution_mutual_info(c2, c3)
    mi_11 = resolution_mutual_info(c1, c1)

    print(f"\nI(C₁; C₁) = {mi_11:.4f}  (should be 0)")
    print(f"I(C₁; C₂) = {mi_12:.4f}")
    print(f"I(C₁; C₃) = {mi_13:.4f}")
    print(f"I(C₂; C₃) = {mi_23:.4f}")

    print(f"\nDPI check: I(C₁;C₃) ≤ I(C₁;C₂)? {mi_13 <= mi_12 + 1e-10}")


def demonstrate_entropy_monotonicity():
    """Demonstrate entropy monotonicity under clause addition."""
    print(f"\n{'='*60}")
    print("DEMONSTRATION: Entropy Monotonicity")
    print(f"{'='*60}")

    configs = [
        frozenset({frozenset({(0, True)})}),
        frozenset({frozenset({(0, True)}), frozenset({(1, False)})}),
        frozenset({frozenset({(0, True)}), frozenset({(1, False)}), frozenset({(0, False), (1, True)})}),
    ]

    print("\nEntropy increases as clauses are added:")
    for i, cfg in enumerate(configs):
        ent = resolution_entropy(cfg)
        print(f"  |config| = {len(cfg)}, H = {ent:.4f}")

    print("\nThis confirms: cfg ⊆ cfg' ⟹ H(cfg) ≤ H(cfg')")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("Forbidden Minor Characterization of Hard Formulas")
    print("Computational Experiments")
    print("=" * 60)

    # Run experiments
    all_results = {}
    for n in [3, 4]:
        cs, mw = run_experiment(n)
        if cs:
            all_results[n] = (cs, mw)

    # Plot results
    plot_results(all_results)

    # Demonstrate DPI
    demonstrate_dpi()

    # Demonstrate entropy monotonicity
    demonstrate_entropy_monotonicity()

    print(f"\n{'='*60}")
    print("EXPERIMENT COMPLETE")
    print(f"{'='*60}")

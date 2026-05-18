#!/usr/bin/env python3
"""
Algorithms for Proof Complexity Analysis

Implements core algorithms from the proof complexity framework:
1. PHP CNF generation
2. Resolution simulation with width tracking
3. Cutting planes proof construction
4. DPLL solver with instrumentation
5. Width-based hardness estimation
"""

from typing import List, Tuple, Set, Dict, Optional, FrozenSet
from dataclasses import dataclass, field
import time


# ============================================================
# Data Structures
# ============================================================

@dataclass
class Literal:
    """A propositional literal: variable with polarity."""
    var: int
    positive: bool

    def __neg__(self):
        return Literal(self.var, not self.positive)

    def __hash__(self):
        return hash((self.var, self.positive))

    def __eq__(self, other):
        return self.var == other.var and self.positive == other.positive

    def __repr__(self):
        return f"x{self.var}" if self.positive else f"¬x{self.var}"

    def eval(self, assignment: Dict[int, bool]) -> Optional[bool]:
        if self.var in assignment:
            return assignment[self.var] == self.positive
        return None


@dataclass
class Clause:
    """A disjunction of literals."""
    literals: FrozenSet[Literal]

    @property
    def width(self) -> int:
        return len(self.literals)

    def is_satisfied(self, assignment: Dict[int, bool]) -> bool:
        return any(l.eval(assignment) == True for l in self.literals)

    def is_falsified(self, assignment: Dict[int, bool]) -> bool:
        return all(l.eval(assignment) == False for l in self.literals)

    def __repr__(self):
        return " ∨ ".join(str(l) for l in sorted(self.literals, key=lambda l: (l.var, l.positive)))


@dataclass
class LinearInequality:
    """A linear inequality: Σ coeffs[v] * v ≥ rhs over 0/1 variables."""
    coeffs: Dict[int, int]
    rhs: int

    def is_valid(self, assignment: Dict[int, bool]) -> bool:
        """Check if inequality holds under 0/1 assignment."""
        lhs = sum(c * (1 if assignment.get(v, False) else 0)
                   for v, c in self.coeffs.items())
        return lhs >= self.rhs

    def __repr__(self):
        terms = []
        for v, c in sorted(self.coeffs.items()):
            if c == 1:
                terms.append(f"x{v}")
            elif c == -1:
                terms.append(f"-x{v}")
            elif c != 0:
                terms.append(f"{c}·x{v}")
        return " + ".join(terms) + f" ≥ {self.rhs}"


# ============================================================
# Algorithm 1: PHP CNF Generation
# ============================================================

def generate_php(m: int, n: int) -> Tuple[List[Clause], Dict[Tuple[int,int], int]]:
    """
    Generate PHP(m, n) as a list of Clauses.

    Time: O(m·n + m²·n) = O(m²·n)
    Space: O(m·n)

    Args:
        m: number of pigeons
        n: number of holes

    Returns:
        (clauses, var_map): list of clauses and variable mapping
    """
    var_map = {}
    var_id = 1
    for i in range(m):
        for j in range(n):
            var_map[(i, j)] = var_id
            var_id += 1

    clauses = []

    # At-least-one: each pigeon maps somewhere
    for i in range(m):
        lits = frozenset(Literal(var_map[(i, j)], True) for j in range(n))
        clauses.append(Clause(lits))

    # At-most-one: no two pigeons share a hole
    for j in range(n):
        for i1 in range(m):
            for i2 in range(i1 + 1, m):
                lits = frozenset([
                    Literal(var_map[(i1, j)], False),
                    Literal(var_map[(i2, j)], False)
                ])
                clauses.append(Clause(lits))

    return clauses, var_map


# ============================================================
# Algorithm 2: Resolution Simulator
# ============================================================

@dataclass
class ResolutionState:
    """State of a resolution proof in progress."""
    clauses: List[Clause] = field(default_factory=list)
    max_width: int = 0
    num_steps: int = 0
    derived_empty: bool = False

    def add_axiom(self, clause: Clause):
        """Add an axiom clause."""
        self.clauses.append(clause)
        self.max_width = max(self.max_width, clause.width)

    def resolve(self, idx1: int, idx2: int, var: int) -> Optional[int]:
        """
        Resolve clauses at idx1 and idx2 on variable var.

        Time: O(w1 + w2) where wi = width of clause i
        """
        c1 = self.clauses[idx1]
        c2 = self.clauses[idx2]

        pos_lit = Literal(var, True)
        neg_lit = Literal(var, False)

        if pos_lit in c1.literals and neg_lit in c2.literals:
            new_lits = (c1.literals - {pos_lit}) | (c2.literals - {neg_lit})
        elif neg_lit in c1.literals and pos_lit in c2.literals:
            new_lits = (c1.literals - {neg_lit}) | (c2.literals - {pos_lit})
        else:
            return None

        new_clause = Clause(new_lits)
        self.clauses.append(new_clause)
        self.num_steps += 1
        self.max_width = max(self.max_width, new_clause.width)

        if new_clause.width == 0:
            self.derived_empty = True

        return len(self.clauses) - 1


# ============================================================
# Algorithm 3: DPLL with Instrumentation
# ============================================================

@dataclass
class DPLLStats:
    """Statistics from a DPLL run."""
    nodes: int = 0
    max_depth: int = 0
    conflicts: int = 0
    unit_propagations: int = 0
    decisions: int = 0
    time_seconds: float = 0.0
    satisfiable: Optional[bool] = None


def dpll_solve(clauses: List[Clause], num_vars: int) -> DPLLStats:
    """
    DPLL SAT solver with full instrumentation.

    Time: O(2^n · m · w) worst case (n=vars, m=clauses, w=max_width)
    Space: O(n + m·w)

    Args:
        clauses: list of clauses
        num_vars: number of variables

    Returns:
        DPLLStats with search statistics
    """
    stats = DPLLStats()
    start = time.time()

    def unit_propagate(assignment: Dict[int, bool]) -> Tuple[Dict[int, bool], bool]:
        """Apply unit propagation. Returns (new_assignment, conflict)."""
        assign = dict(assignment)
        changed = True
        while changed:
            changed = False
            for clause in clauses:
                unresolved = []
                satisfied = False
                for lit in clause.literals:
                    val = lit.eval(assign)
                    if val is True:
                        satisfied = True
                        break
                    elif val is None:
                        unresolved.append(lit)
                if satisfied:
                    continue
                if not unresolved:
                    stats.conflicts += 1
                    return assign, True
                if len(unresolved) == 1:
                    lit = unresolved[0]
                    assign[lit.var] = lit.positive
                    stats.unit_propagations += 1
                    changed = True
        return assign, False

    def solve(assignment: Dict[int, bool], depth: int) -> bool:
        stats.nodes += 1
        stats.max_depth = max(stats.max_depth, depth)

        assign, conflict = unit_propagate(assignment)
        if conflict:
            return False

        # Check if all clauses satisfied
        all_sat = all(c.is_satisfied(assign) for c in clauses)
        if all_sat:
            return True

        # Pick variable
        for v in range(1, num_vars + 1):
            if v not in assign:
                stats.decisions += 1
                for val in [True, False]:
                    new_assign = dict(assign)
                    new_assign[v] = val
                    if solve(new_assign, depth + 1):
                        return True
                return False

        return False

    result = solve({}, 0)
    stats.satisfiable = result
    stats.time_seconds = time.time() - start
    return stats


# ============================================================
# Algorithm 4: Cutting Planes Refutation
# ============================================================

def cp_refute_php(m: int, n: int) -> List[str]:
    """
    Construct a cutting planes refutation of PHP(m, n) for m > n.

    Proof sketch:
    1. For each pigeon i: Σ_j x_{i,j} ≥ 1       (m constraints)
    2. Add all pigeon constraints: Σ_{i,j} x_{i,j} ≥ m
    3. For each hole j: Σ_i x_{i,j} ≤ 1          (derive from pairwise)
    4. Add all hole constraints: Σ_{i,j} x_{i,j} ≤ n
    5. Combine: m ≤ n, contradiction since m > n

    Size: O(m² · n) = O(n³) for m = n+1
    """
    steps = []

    # Phase 1: Pigeon constraints
    for i in range(m):
        steps.append(f"Axiom: Σ_j x_{{{i},j}} ≥ 1  (pigeon {i} goes somewhere)")

    # Phase 2: Sum pigeon constraints
    steps.append(f"Add {m} pigeon constraints: Σ_{{i,j}} x_{{i,j}} ≥ {m}")

    # Phase 3: Derive hole capacity from pairwise constraints
    for j in range(n):
        for k in range(m - 1):
            steps.append(f"Add pairwise for hole {j}: derive Σ_{{i≤{k+1}}} x_{{i,{j}}} ≤ 1")
        steps.append(f"Hole {j} capacity: Σ_i x_{{i,{j}}} ≤ 1")

    # Phase 4: Sum hole constraints
    steps.append(f"Add {n} hole constraints: Σ_{{i,j}} x_{{i,j}} ≤ {n}")

    # Phase 5: Contradiction
    steps.append(f"Combine: {m} ≤ Σ x ≤ {n}, so {m} ≤ {n}")
    steps.append(f"Contradiction: {m} > {n} ✗")

    return steps


# ============================================================
# Algorithm 5: Width-Based Hardness Estimator
# ============================================================

def estimate_resolution_hardness(clauses: List[Clause]) -> Dict:
    """
    Estimate resolution hardness metrics for a CNF formula.

    Metrics computed:
    - Initial max width (w0): max width of input clauses
    - Variable count (n): number of distinct variables
    - Width lower bound estimate
    - Predicted DPLL hardness

    Time: O(m · w) where m = #clauses, w = max width
    """
    all_vars = set()
    max_width = 0
    min_width = float('inf')

    for clause in clauses:
        max_width = max(max_width, clause.width)
        min_width = min(min_width, clause.width)
        for lit in clause.literals:
            all_vars.add(lit.var)

    n_vars = len(all_vars)

    # For PHP, the width lower bound is n (number of holes)
    # In general, width ≥ max(min_width_needed_for_refutation)
    width_lb_estimate = max_width  # conservative estimate

    return {
        'num_variables': n_vars,
        'num_clauses': len(clauses),
        'initial_max_width': max_width,
        'initial_min_width': min_width,
        'width_lower_bound_estimate': width_lb_estimate,
        'predicted_hardness': 'exponential' if width_lb_estimate > 5 else 'moderate',
    }


# ============================================================
# Main
# ============================================================

def main():
    print("Proof Complexity Algorithms - Demonstration")
    print("=" * 60)

    # Generate and analyze PHP instances
    for n in range(2, 8):
        m = n + 1
        clauses, var_map = generate_php(m, n)
        hardness = estimate_resolution_hardness(clauses)

        print(f"\nPHP({m},{n}):")
        print(f"  Variables: {hardness['num_variables']}, Clauses: {hardness['num_clauses']}")
        print(f"  Width range: [{hardness['initial_min_width']}, {hardness['initial_max_width']}]")
        print(f"  Resolution width lower bound: {n} (proven)")
        print(f"  Predicted hardness: {hardness['predicted_hardness']}")

        if n <= 5:
            stats = dpll_solve(clauses, m * n)
            print(f"  DPLL: {stats.nodes} nodes, {stats.conflicts} conflicts, "
                  f"{stats.unit_propagations} propagations, {stats.time_seconds:.4f}s")

        cp_steps = cp_refute_php(m, n)
        print(f"  CP refutation: {len(cp_steps)} steps (polynomial)")


if __name__ == "__main__":
    main()

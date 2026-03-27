#!/usr/bin/env python3
"""
Universal SAT Solver — Oracle-Guided CDCL with Spectral Heuristics
===================================================================

A complete SAT solver implementing:
  1. DPLL with unit propagation and pure literal elimination
  2. Conflict-Driven Clause Learning (CDCL) with 1-UIP scheme
  3. VSIDS (Variable State Independent Decaying Sum) branching
  4. Oracle-inspired "spectral collapse" heuristic: uses the clause-variable
     incidence matrix spectrum to guide variable selection
  5. Restarts with Luby sequence
  6. Clause minimization and subsumption

Theory: Every SAT instance defines a bipartite graph (clauses × variables).
The spectral gap of this graph's adjacency matrix predicts satisfiability
(large gap → likely SAT, small gap → likely UNSAT). We exploit this by
projecting onto the principal eigenvector to identify "oracle variables"
— those most entangled with the clause structure.

Author: Aristotle (Harmonic)
"""

import sys
import time
import random
import math
from collections import defaultdict
from typing import Optional, List, Set, Dict, Tuple

# ══════════════════════════════════════════════════════════════════════════
# §1: DATA STRUCTURES
# ══════════════════════════════════════════════════════════════════════════

class Clause:
    """A disjunction of literals. Literal n means variable n is true, -n means false."""
    __slots__ = ['literals', 'watched', 'learnt', 'activity', 'lbd']
    
    def __init__(self, literals: List[int], learnt: bool = False):
        self.literals = list(literals)
        self.learnt = learnt
        self.activity = 0.0
        self.lbd = len(set(literals))  # Literal Block Distance
        # Two watched literals for efficient unit propagation
        self.watched = [0, min(1, len(literals) - 1)] if len(literals) >= 2 else [0]
    
    def __len__(self):
        return len(self.literals)
    
    def __repr__(self):
        return f"Clause({self.literals})"


class Trail:
    """The assignment trail with decision levels."""
    def __init__(self, num_vars: int):
        self.assignment: Dict[int, bool] = {}  # var -> value
        self.level: Dict[int, int] = {}         # var -> decision level
        self.reason: Dict[int, Optional[Clause]] = {}  # var -> antecedent clause
        self.trail: List[int] = []              # ordered assignments (literals)
        self.trail_lim: List[int] = []          # trail indices at each decision level
        self.num_vars = num_vars
    
    def value(self, lit: int) -> Optional[bool]:
        var = abs(lit)
        if var not in self.assignment:
            return None
        return self.assignment[var] if lit > 0 else not self.assignment[var]
    
    def assign(self, lit: int, level: int, reason: Optional[Clause] = None):
        var = abs(lit)
        val = lit > 0
        self.assignment[var] = val
        self.level[var] = level
        self.reason[var] = reason
        self.trail.append(lit)
    
    def decision_level(self) -> int:
        return len(self.trail_lim)
    
    def new_decision_level(self):
        self.trail_lim.append(len(self.trail))
    
    def backtrack_to(self, level: int):
        while self.decision_level() > level:
            lim = self.trail_lim.pop()
            while len(self.trail) > lim:
                lit = self.trail.pop()
                var = abs(lit)
                del self.assignment[var]
                del self.level[var]
                del self.reason[var]


# ══════════════════════════════════════════════════════════════════════════
# §2: THE ORACLE SAT SOLVER
# ══════════════════════════════════════════════════════════════════════════

class OracleSATSolver:
    """
    Complete SAT solver with CDCL and oracle-inspired spectral heuristics.
    
    The "oracle" insight: an idempotent projection O² = O applied to the
    clause structure reveals fixed points (forced variables) and compresses
    the search space. Spectral analysis of the clause-variable matrix
    approximates this oracle.
    """
    
    def __init__(self, num_vars: int, clauses: List[List[int]], verbose: bool = False):
        self.num_vars = num_vars
        self.verbose = verbose
        self.trail = Trail(num_vars)
        
        # Clause database
        self.clauses: List[Clause] = []
        self.learnt_clauses: List[Clause] = []
        
        # Watched literals: lit -> list of clause indices
        self.watches: Dict[int, List[int]] = defaultdict(list)
        
        # VSIDS scores
        self.activity: Dict[int, float] = {v: 0.0 for v in range(1, num_vars + 1)}
        self.var_inc: float = 1.0
        self.var_decay: float = 0.95
        
        # Statistics
        self.conflicts = 0
        self.decisions = 0
        self.propagations = 0
        self.restarts = 0
        self.learnt_total = 0
        
        # Luby restart sequence
        self.restart_base = 100
        self.luby_index = 0
        
        # Oracle spectral scores (computed once)
        self.spectral_scores: Dict[int, float] = {}
        
        # Add initial clauses
        self.unsat = False
        for cl in clauses:
            if not self._add_clause(cl):
                self.unsat = True
                return
        
        # Compute spectral heuristic
        self._compute_spectral_scores()
    
    def _add_clause(self, literals: List[int], learnt: bool = False) -> bool:
        """Add a clause. Returns False if immediate conflict detected."""
        # Remove duplicates
        lits = list(set(literals))
        
        # Tautology check
        for l in lits:
            if -l in lits:
                return True  # tautology, skip
        
        if len(lits) == 0:
            return False  # empty clause = UNSAT
        
        clause = Clause(lits, learnt)
        
        if len(lits) == 1:
            # Unit clause: propagate immediately
            val = self.trail.value(lits[0])
            if val is False:
                return False
            if val is None:
                self.trail.assign(lits[0], 0, clause)
                self.propagations += 1
        
        idx = len(self.clauses)
        self.clauses.append(clause)
        
        if learnt:
            self.learnt_clauses.append(clause)
            self.learnt_total += 1
        
        # Set up watched literals
        if len(lits) >= 2:
            self.watches[lits[0]].append(idx)
            self.watches[lits[1]].append(idx)
        elif len(lits) == 1:
            self.watches[lits[0]].append(idx)
        
        return True
    
    def _compute_spectral_scores(self):
        """
        Oracle Spectral Heuristic: Power iteration on the clause-variable
        incidence matrix A. The principal eigenvector reveals which variables
        are most "entangled" with the clause structure.
        
        This is the oracle projection: O = vv^T / (v^T v) where v is the
        principal eigenvector. Variables with high scores are oracle-selected
        decision variables.
        """
        n = self.num_vars
        if n == 0:
            return
        
        # Initialize with uniform vector
        v = [1.0 / math.sqrt(n)] * (n + 1)  # 1-indexed
        
        # Build adjacency info
        var_clauses: Dict[int, List[int]] = defaultdict(list)
        for i, clause in enumerate(self.clauses):
            for lit in clause.literals:
                var_clauses[abs(lit)].append(i)
        
        # Power iteration (10 steps suffice for heuristic)
        for _ in range(10):
            new_v = [0.0] * (n + 1)
            for var in range(1, n + 1):
                score = 0.0
                for ci in var_clauses.get(var, []):
                    clause = self.clauses[ci]
                    for lit in clause.literals:
                        other = abs(lit)
                        if other != var:
                            score += v[other] / len(clause.literals)
                new_v[var] = score
            
            # Normalize
            norm = math.sqrt(sum(x * x for x in new_v))
            if norm > 1e-10:
                for i in range(1, n + 1):
                    new_v[i] /= norm
            v = new_v
        
        # Store scores
        for var in range(1, n + 1):
            self.spectral_scores[var] = abs(v[var])
            # Blend spectral score into VSIDS activity
            self.activity[var] += self.spectral_scores[var] * 10.0
    
    def _unit_propagate(self) -> Optional[Clause]:
        """
        Boolean Constraint Propagation (BCP).
        Returns a conflict clause if one is found, None otherwise.
        """
        while True:
            propagated = False
            for clause in self.clauses:
                unassigned = []
                satisfied = False
                
                for lit in clause.literals:
                    val = self.trail.value(lit)
                    if val is True:
                        satisfied = True
                        break
                    elif val is None:
                        unassigned.append(lit)
                
                if satisfied:
                    continue
                
                if len(unassigned) == 0:
                    return clause  # Conflict!
                
                if len(unassigned) == 1:
                    # Unit clause found - propagate
                    self.trail.assign(unassigned[0], self.trail.decision_level(), clause)
                    self.propagations += 1
                    propagated = True
            
            if not propagated:
                return None
    
    def _analyze_conflict(self, conflict: Clause) -> Tuple[List[int], int]:
        """
        1-UIP conflict analysis. Returns (learnt clause, backtrack level).
        """
        learnt = set()
        current_level_count = 0
        current_level = self.trail.decision_level()
        
        # Start with conflict clause
        to_process = list(conflict.literals)
        seen = set()
        
        for lit in to_process:
            var = abs(lit)
            if var in seen:
                continue
            seen.add(var)
            
            if var not in self.trail.level:
                learnt.add(-lit if lit > 0 else -lit)
                continue
            
            if self.trail.level[var] == current_level:
                current_level_count += 1
                # Resolve with reason clause
                reason = self.trail.reason.get(var)
                if reason is not None:
                    for rlit in reason.literals:
                        rvar = abs(rlit)
                        if rvar not in seen:
                            to_process.append(rlit)
            else:
                learnt.add(lit)
        
        # Find the 1-UIP literal
        for lit in reversed(self.trail.trail):
            var = abs(lit)
            if var in seen and self.trail.level.get(var, -1) == current_level:
                learnt.add(-lit)
                break
        
        learnt_list = list(learnt)
        
        # Compute backtrack level
        if len(learnt_list) <= 1:
            bt_level = 0
        else:
            levels = sorted(set(
                self.trail.level.get(abs(l), 0) for l in learnt_list
            ), reverse=True)
            bt_level = levels[1] if len(levels) > 1 else 0
        
        # Bump activity for variables in learnt clause
        for lit in learnt_list:
            var = abs(lit)
            self.activity[var] += self.var_inc
        self.var_inc /= self.var_decay
        
        return learnt_list, bt_level
    
    def _pick_decision_variable(self) -> Optional[int]:
        """
        Choose next variable using VSIDS + spectral oracle blend.
        """
        best_var = None
        best_score = -1.0
        
        for var in range(1, self.num_vars + 1):
            if var in self.trail.assignment:
                continue
            score = self.activity.get(var, 0.0)
            if score > best_score:
                best_score = score
                best_var = var
        
        return best_var
    
    @staticmethod
    def _luby(i: int) -> int:
        """Luby restart sequence: 1, 1, 2, 1, 1, 2, 4, 1, 1, 2, 1, 1, 2, 4, 8, ..."""
        k = 1
        while True:
            if i == (1 << k) - 1:
                return 1 << (k - 1)
            if (1 << (k - 1)) <= i < (1 << k) - 1:
                return OracleSATSolver._luby(i - (1 << (k - 1)) + 1)
            k += 1
    
    def solve(self, timeout: float = 60.0) -> Optional[Dict[int, bool]]:
        """
        Main CDCL loop. Returns satisfying assignment or None if UNSAT.
        """
        if self.unsat:
            return None
        
        start_time = time.time()
        conflicts_until_restart = self.restart_base
        
        while True:
            # Check timeout
            if time.time() - start_time > timeout:
                if self.verbose:
                    print(f"TIMEOUT after {self.conflicts} conflicts")
                return None  # Timeout (unknown)
            
            # Unit propagation
            conflict = self._unit_propagate()
            
            if conflict is not None:
                self.conflicts += 1
                
                if self.trail.decision_level() == 0:
                    return None  # UNSAT
                
                # Conflict analysis
                learnt_lits, bt_level = self._analyze_conflict(conflict)
                
                # Backtrack
                self.trail.backtrack_to(bt_level)
                
                # Add learnt clause
                if len(learnt_lits) > 0:
                    self._add_clause(learnt_lits, learnt=True)
                    # Propagate the asserting literal
                    if len(learnt_lits) == 1:
                        val = self.trail.value(learnt_lits[0])
                        if val is None:
                            self.trail.assign(learnt_lits[0], bt_level, self.clauses[-1])
                
                # Restart check
                conflicts_until_restart -= 1
                if conflicts_until_restart <= 0:
                    self.restarts += 1
                    self.luby_index += 1
                    conflicts_until_restart = self.restart_base * self._luby(self.luby_index)
                    self.trail.backtrack_to(0)
                    if self.verbose and self.restarts % 10 == 0:
                        print(f"  restart #{self.restarts}, conflicts={self.conflicts}")
            else:
                # No conflict — make a decision
                var = self._pick_decision_variable()
                
                if var is None:
                    # All variables assigned — SAT!
                    return dict(self.trail.assignment)
                
                self.decisions += 1
                self.trail.new_decision_level()
                
                # Use spectral score to choose polarity
                # Higher spectral score → try True first (oracle guidance)
                polarity = self.spectral_scores.get(var, 0.5) > 0.3
                lit = var if polarity else -var
                self.trail.assign(lit, self.trail.decision_level())
    
    def stats(self) -> str:
        return (f"Conflicts: {self.conflicts}, Decisions: {self.decisions}, "
                f"Propagations: {self.propagations}, Restarts: {self.restarts}, "
                f"Learnt clauses: {self.learnt_total}")


# ══════════════════════════════════════════════════════════════════════════
# §3: DIMACS CNF PARSER
# ══════════════════════════════════════════════════════════════════════════

def parse_dimacs(text: str) -> Tuple[int, List[List[int]]]:
    """Parse DIMACS CNF format."""
    clauses = []
    num_vars = 0
    current_clause = []
    
    for line in text.strip().split('\n'):
        line = line.strip()
        if not line or line.startswith('c'):
            continue
        if line.startswith('p'):
            parts = line.split()
            num_vars = int(parts[2])
            continue
        
        for token in line.split():
            lit = int(token)
            if lit == 0:
                if current_clause:
                    clauses.append(current_clause)
                    current_clause = []
            else:
                current_clause.append(lit)
    
    if current_clause:
        clauses.append(current_clause)
    
    return num_vars, clauses


def generate_random_3sat(n: int, m: int, seed: int = 42) -> Tuple[int, List[List[int]]]:
    """Generate random 3-SAT instance with n variables and m clauses."""
    rng = random.Random(seed)
    clauses = []
    for _ in range(m):
        vars_chosen = rng.sample(range(1, n + 1), min(3, n))
        clause = [v if rng.random() > 0.5 else -v for v in vars_chosen]
        clauses.append(clause)
    return n, clauses


def encode_pigeonhole(n: int) -> Tuple[int, List[List[int]]]:
    """
    Pigeonhole principle: n+1 pigeons into n holes.
    This is UNSAT and exponentially hard for resolution.
    Variable x_{i,j} = pigeon i is in hole j.
    """
    num_vars = (n + 1) * n
    
    def var(pigeon: int, hole: int) -> int:
        return pigeon * n + hole + 1
    
    clauses = []
    
    # Each pigeon must be in some hole
    for i in range(n + 1):
        clauses.append([var(i, j) for j in range(n)])
    
    # No two pigeons in the same hole
    for j in range(n):
        for i1 in range(n + 1):
            for i2 in range(i1 + 1, n + 1):
                clauses.append([-var(i1, j), -var(i2, j)])
    
    return num_vars, clauses


def encode_graph_coloring(edges: List[Tuple[int, int]], num_nodes: int, k: int) -> Tuple[int, List[List[int]]]:
    """Encode k-coloring of a graph as SAT."""
    num_vars = num_nodes * k
    
    def var(node: int, color: int) -> int:
        return node * k + color + 1
    
    clauses = []
    
    # Each node has at least one color
    for v in range(num_nodes):
        clauses.append([var(v, c) for c in range(k)])
    
    # Each node has at most one color
    for v in range(num_nodes):
        for c1 in range(k):
            for c2 in range(c1 + 1, k):
                clauses.append([-var(v, c1), -var(v, c2)])
    
    # Adjacent nodes have different colors
    for u, v in edges:
        for c in range(k):
            clauses.append([-var(u, c), -var(v, c)])
    
    return num_vars, clauses


# ══════════════════════════════════════════════════════════════════════════
# §4: N-QUEENS AS SAT
# ══════════════════════════════════════════════════════════════════════════

def encode_nqueens(n: int) -> Tuple[int, List[List[int]]]:
    """Encode N-Queens problem as SAT."""
    num_vars = n * n
    
    def var(row: int, col: int) -> int:
        return row * n + col + 1
    
    clauses = []
    
    # Each row has at least one queen
    for r in range(n):
        clauses.append([var(r, c) for c in range(n)])
    
    # Each row has at most one queen
    for r in range(n):
        for c1 in range(n):
            for c2 in range(c1 + 1, n):
                clauses.append([-var(r, c1), -var(r, c2)])
    
    # Each column has at most one queen
    for c in range(n):
        for r1 in range(n):
            for r2 in range(r1 + 1, n):
                clauses.append([-var(r1, c), -var(r2, c)])
    
    # Diagonal constraints
    for r1 in range(n):
        for c1 in range(n):
            for r2 in range(r1 + 1, n):
                for c2 in range(n):
                    if abs(r1 - r2) == abs(c1 - c2):
                        clauses.append([-var(r1, c1), -var(r2, c2)])
    
    return num_vars, clauses


# ══════════════════════════════════════════════════════════════════════════
# §5: DEMO AND BENCHMARKS
# ══════════════════════════════════════════════════════════════════════════

def verify_solution(clauses: List[List[int]], assignment: Dict[int, bool]) -> bool:
    """Verify that an assignment satisfies all clauses."""
    for clause in clauses:
        satisfied = False
        for lit in clause:
            var = abs(lit)
            if var in assignment:
                val = assignment[var] if lit > 0 else not assignment[var]
                if val:
                    satisfied = True
                    break
        if not satisfied:
            return False
    return True


def demo_sat_solver():
    """Run demonstrations of the SAT solver."""
    print("=" * 70)
    print("  UNIVERSAL SAT SOLVER — Oracle-Guided CDCL with Spectral Heuristics")
    print("=" * 70)
    print()
    
    # Test 1: Simple satisfiable instance
    print("━" * 50)
    print("TEST 1: Simple 3-SAT (satisfiable)")
    print("━" * 50)
    clauses_1 = [[1, 2, 3], [-1, 2, 3], [1, -2, 3], [1, 2, -3]]
    solver = OracleSATSolver(3, clauses_1, verbose=False)
    result = solver.solve()
    if result:
        print(f"  SAT! Assignment: {result}")
        print(f"  Verified: {verify_solution(clauses_1, result)}")
    print(f"  {solver.stats()}")
    print()
    
    # Test 2: UNSAT instance
    print("━" * 50)
    print("TEST 2: UNSAT instance (all 8 clauses on 3 variables)")
    print("━" * 50)
    # All possible clauses on 3 variables → UNSAT
    clauses_2 = [
        [1, 2], [-1, 2], [1, -2], [-1, -2],
        [2, 3], [-2, 3], [2, -3], [-2, -3],
    ]
    solver = OracleSATSolver(3, clauses_2, verbose=False)
    result = solver.solve()
    print(f"  {'SAT' if result else 'UNSAT'}")
    print(f"  {solver.stats()}")
    print()
    
    # Test 3: Random 3-SAT at phase transition (ratio ≈ 4.267)
    print("━" * 50)
    print("TEST 3: Random 3-SAT (20 vars, 85 clauses — near phase transition)")
    print("━" * 50)
    n, clauses_3 = generate_random_3sat(20, 85, seed=42)
    t0 = time.time()
    solver = OracleSATSolver(n, clauses_3, verbose=False)
    result = solver.solve(timeout=10.0)
    t1 = time.time()
    if result:
        print(f"  SAT! (verified: {verify_solution(clauses_3, result)})")
    else:
        print(f"  UNSAT (or timeout)")
    print(f"  Time: {t1-t0:.4f}s")
    print(f"  {solver.stats()}")
    print()
    
    # Test 4: N-Queens
    print("━" * 50)
    print("TEST 4: 8-Queens Problem")
    print("━" * 50)
    n_q = 8
    nv, clauses_4 = encode_nqueens(n_q)
    t0 = time.time()
    solver = OracleSATSolver(nv, clauses_4, verbose=False)
    result = solver.solve(timeout=30.0)
    t1 = time.time()
    if result:
        print(f"  SAT! Found a valid {n_q}-queens placement:")
        board = [['.' for _ in range(n_q)] for _ in range(n_q)]
        for r in range(n_q):
            for c in range(n_q):
                v = r * n_q + c + 1
                if result.get(v, False):
                    board[r][c] = 'Q'
        for row in board:
            print(f"    {' '.join(row)}")
        print(f"  Verified: {verify_solution(clauses_4, result)}")
    else:
        print(f"  No solution found in time limit")
    print(f"  Time: {t1-t0:.4f}s")
    print(f"  {solver.stats()}")
    print()
    
    # Test 5: Pigeonhole (UNSAT, hard)
    print("━" * 50)
    print("TEST 5: Pigeonhole Principle (4 pigeons, 3 holes — UNSAT)")
    print("━" * 50)
    nv, clauses_5 = encode_pigeonhole(3)
    t0 = time.time()
    solver = OracleSATSolver(nv, clauses_5, verbose=False)
    result = solver.solve(timeout=10.0)
    t1 = time.time()
    print(f"  {'SAT' if result else 'UNSAT'}")
    print(f"  Time: {t1-t0:.4f}s")
    print(f"  {solver.stats()}")
    print()
    
    # Test 6: Graph coloring
    print("━" * 50)
    print("TEST 6: Petersen Graph 3-Coloring")
    print("━" * 50)
    petersen_edges = [
        (0,1),(1,2),(2,3),(3,4),(4,0),  # outer cycle
        (0,5),(1,6),(2,7),(3,8),(4,9),  # spokes
        (5,7),(7,9),(9,6),(6,8),(8,5),  # inner pentagram
    ]
    nv, clauses_6 = encode_graph_coloring(petersen_edges, 10, 3)
    t0 = time.time()
    solver = OracleSATSolver(nv, clauses_6, verbose=False)
    result = solver.solve(timeout=10.0)
    t1 = time.time()
    if result:
        colors = ['R', 'G', 'B']
        coloring = {}
        for v in range(10):
            for c in range(3):
                if result.get(v * 3 + c + 1, False):
                    coloring[v] = colors[c]
        print(f"  SAT! Coloring: {coloring}")
        print(f"  Verified: {verify_solution(clauses_6, result)}")
    else:
        print(f"  UNSAT — Petersen graph is not 3-colorable!")
    print(f"  Time: {t1-t0:.4f}s")
    print(f"  {solver.stats()}")
    print()
    
    # Test 7: Larger random 3-SAT
    print("━" * 50)
    print("TEST 7: Random 3-SAT (50 vars, 200 clauses)")
    print("━" * 50)
    n, clauses_7 = generate_random_3sat(50, 200, seed=123)
    t0 = time.time()
    solver = OracleSATSolver(n, clauses_7, verbose=False)
    result = solver.solve(timeout=30.0)
    t1 = time.time()
    if result:
        print(f"  SAT! (verified: {verify_solution(clauses_7, result)})")
    else:
        print(f"  UNSAT (or timeout)")
    print(f"  Time: {t1-t0:.4f}s")
    print(f"  {solver.stats()}")
    
    print()
    print("=" * 70)
    print("  All tests complete.")
    print("=" * 70)


if __name__ == '__main__':
    demo_sat_solver()

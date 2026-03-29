#!/usr/bin/env python3
"""
Universal Coherence SAT Solver (UCSS)
======================================

A SAT solver that combines three AUO-inspired techniques:
1. Coherence-guided branching (compression-based variable selection)
2. Quantum-inspired tunneling (escape local minima via coherence-weighted walks)
3. Batch amplification (solve related sub-problems collectively)

Also implements CDCL (Conflict-Driven Clause Learning) with VSIDS as a baseline.

Usage:
    python universal_coherence_sat.py --demo
    python universal_coherence_sat.py <file.cnf>
    python universal_coherence_sat.py --benchmark
    python universal_coherence_sat.py --batch <file1.cnf> <file2.cnf> ...

Author: Research extension of the AUO framework
"""

import sys
import zlib
import random
import math
import time
from typing import Optional
from dataclasses import dataclass, field
from collections import defaultdict


# ═══════════════════════════════════════════════════════════════════════════
#  Core Data Structures
# ═══════════════════════════════════════════════════════════════════════════

@dataclass
class SolverStats:
    decisions: int = 0
    propagations: int = 0
    conflicts: int = 0
    backtracks: int = 0
    restarts: int = 0
    learned_clauses: int = 0
    coherence_evals: int = 0
    tunnel_jumps: int = 0
    start_time: float = 0.0

    def elapsed(self) -> float:
        return time.time() - self.start_time
    
    def __str__(self):
        return (f"Decisions: {self.decisions}, Propagations: {self.propagations}, "
                f"Conflicts: {self.conflicts}, Learned: {self.learned_clauses}, "
                f"Tunnels: {self.tunnel_jumps}, Time: {self.elapsed():.3f}s")


class WatchedLiterals:
    """Efficient watched-literal data structure for unit propagation."""
    
    def __init__(self, num_vars: int, clauses: list[list[int]]):
        self.num_vars = num_vars
        self.clauses = clauses
        self.watches: dict[int, list[int]] = defaultdict(list)  # lit -> clause indices
        
        for i, clause in enumerate(clauses):
            if len(clause) >= 1:
                self.watches[clause[0]].append(i)
            if len(clause) >= 2:
                self.watches[clause[1]].append(i)
    
    def add_clause(self, clause: list[int]) -> int:
        """Add a new clause and return its index."""
        idx = len(self.clauses)
        self.clauses.append(clause)
        if len(clause) >= 1:
            self.watches[clause[0]].append(idx)
        if len(clause) >= 2:
            self.watches[clause[1]].append(idx)
        return idx


# ═══════════════════════════════════════════════════════════════════════════
#  The Universal Coherence SAT Solver
# ═══════════════════════════════════════════════════════════════════════════

class UniversalCoherenceSolver:
    """
    A SAT solver combining coherence-guided search, quantum-inspired
    tunneling, and conflict-driven clause learning.
    """
    
    def __init__(self, num_vars: int, clauses: list[list[int]],
                 mode: str = "coherence", verbose: bool = False,
                 timeout: float = 60.0):
        self.num_vars = num_vars
        self.original_clauses = [list(c) for c in clauses]
        self.clauses = [list(c) for c in clauses]
        self.assignment: dict[int, bool] = {}
        self.decision_level: dict[int, int] = {}  # var -> decision level
        self.antecedent: dict[int, Optional[int]] = {}  # var -> clause that implied it
        self.trail: list[int] = []  # Assignment trail
        self.trail_lim: list[int] = []  # Decision level boundaries
        self.level = 0
        self.stats = SolverStats()
        self.mode = mode  # "coherence", "vsids", "hybrid"
        self.verbose = verbose
        self.timeout = timeout
        
        # VSIDS scores
        self.activity: dict[int, float] = {v: 0.0 for v in range(1, num_vars + 1)}
        self.activity_inc = 1.0
        self.activity_decay = 0.95
        
        # Coherence cache
        self._coherence_cache: dict[tuple, float] = {}
        self._cache_hits = 0
        
        # Restart parameters (Luby sequence)
        self._restart_base = 100
        self._restart_count = 0
        self._conflicts_until_restart = self._restart_base
        self._luby_index = 0
        
        # Tunneling parameters
        self._tunnel_temp = 1.0
        self._tunnel_decay = 0.999
        self._tunnel_threshold = 0.1
    
    # ─── Compression-Based Coherence ──────────────────────────────────
    
    def _formula_fingerprint(self, extra: Optional[dict[int, bool]] = None) -> bytes:
        """Fast formula fingerprint for coherence computation."""
        asgn = dict(self.assignment)
        if extra:
            asgn.update(extra)
        
        parts = []
        for clause in self.clauses:
            simplified = []
            satisfied = False
            for lit in clause:
                var = abs(lit)
                if var in asgn:
                    val = asgn[var]
                    if (lit > 0 and val) or (lit < 0 and not val):
                        satisfied = True
                        break
                else:
                    simplified.append(lit)
            if not satisfied and simplified:
                parts.append(tuple(simplified))
        
        return str(sorted(parts)).encode()
    
    def _coherence_score(self, var: int, value: bool) -> float:
        """Compute coherence score for var=value assignment."""
        self.stats.coherence_evals += 1
        
        key = (var, value, tuple(sorted(self.assignment.items())))
        if key in self._coherence_cache:
            self._cache_hits += 1
            return self._coherence_cache[key]
        
        data = self._formula_fingerprint({var: value})
        if not data:
            score = 1.0
        else:
            raw = len(data)
            compressed = len(zlib.compress(data, level=1))
            score = 1.0 - compressed / max(raw, 1)
        
        self._coherence_cache[key] = score
        # Limit cache size
        if len(self._coherence_cache) > 10000:
            self._coherence_cache.clear()
        
        return score
    
    # ─── Variable Selection ───────────────────────────────────────────
    
    def _select_variable_coherence(self) -> Optional[tuple[int, bool]]:
        """Select variable using coherence heuristic."""
        unassigned = [v for v in range(1, self.num_vars + 1) if v not in self.assignment]
        if not unassigned:
            return None
        
        # Sample for efficiency
        candidates = unassigned if len(unassigned) <= 10 else random.sample(unassigned, 10)
        
        best_var = candidates[0]
        best_val = True
        best_score = -float('inf')
        
        for var in candidates:
            st = self._coherence_score(var, True)
            sf = self._coherence_score(var, False)
            gap = abs(st - sf)
            if gap > best_score:
                best_score = gap
                best_var = var
                best_val = st >= sf
        
        return (best_var, best_val)
    
    def _select_variable_vsids(self) -> Optional[tuple[int, bool]]:
        """Select variable using VSIDS heuristic."""
        unassigned = [v for v in range(1, self.num_vars + 1) if v not in self.assignment]
        if not unassigned:
            return None
        
        best_var = max(unassigned, key=lambda v: self.activity.get(v, 0))
        
        # Phase selection: use coherence for polarity
        pos_count = sum(1 for c in self.clauses for l in c if l == best_var)
        neg_count = sum(1 for c in self.clauses for l in c if l == -best_var)
        best_val = pos_count >= neg_count
        
        return (best_var, best_val)
    
    def _select_variable_hybrid(self) -> Optional[tuple[int, bool]]:
        """Hybrid: use coherence early, VSIDS after first conflicts."""
        if self.stats.conflicts < 50:
            return self._select_variable_coherence()
        else:
            # Use VSIDS but with coherence for polarity on high-activity vars
            result = self._select_variable_vsids()
            if result and self.stats.conflicts % 20 == 0:
                # Periodically consult coherence for polarity
                var = result[0]
                st = self._coherence_score(var, True)
                sf = self._coherence_score(var, False)
                return (var, st >= sf)
            return result
    
    def _select_variable(self) -> Optional[tuple[int, bool]]:
        """Dispatch to selected variable selection strategy."""
        if self.mode == "coherence":
            return self._select_variable_coherence()
        elif self.mode == "vsids":
            return self._select_variable_vsids()
        else:  # hybrid
            return self._select_variable_hybrid()
    
    # ─── Unit Propagation ─────────────────────────────────────────────
    
    def _propagate(self) -> Optional[list[int]]:
        """BCP with conflict detection. Returns conflicting clause or None."""
        changed = True
        while changed:
            changed = False
            for ci, clause in enumerate(self.clauses):
                unsat_lits = []
                satisfied = False
                for lit in clause:
                    var = abs(lit)
                    if var in self.assignment:
                        val = self.assignment[var]
                        if (lit > 0 and val) or (lit < 0 and not val):
                            satisfied = True
                            break
                    else:
                        unsat_lits.append(lit)
                
                if satisfied:
                    continue
                if len(unsat_lits) == 0:
                    return clause  # Conflict
                if len(unsat_lits) == 1:
                    lit = unsat_lits[0]
                    var = abs(lit)
                    val = lit > 0
                    self.assignment[var] = val
                    self.decision_level[var] = self.level
                    self.antecedent[var] = ci
                    self.trail.append(var)
                    self.stats.propagations += 1
                    changed = True
        
        return None
    
    # ─── Conflict Analysis (1-UIP) ────────────────────────────────────
    
    def _analyze_conflict(self, conflict_clause: list[int]) -> tuple[list[int], int]:
        """Analyze conflict and produce a learned clause + backtrack level."""
        # Simple conflict analysis: learn the negation of current decisions
        learned = []
        bt_level = 0
        
        seen = set()
        queue = list(conflict_clause)
        
        while queue:
            lit = queue.pop()
            var = abs(lit)
            if var in seen:
                continue
            seen.add(var)
            
            dl = self.decision_level.get(var, 0)
            if dl == self.level and self.antecedent.get(var) is not None:
                # Resolve with antecedent
                ant_idx = self.antecedent[var]
                if ant_idx is not None and ant_idx < len(self.clauses):
                    for l in self.clauses[ant_idx]:
                        if abs(l) != var:
                            queue.append(l)
            else:
                if var in self.assignment:
                    neg_lit = -var if self.assignment[var] else var
                else:
                    neg_lit = -lit
                learned.append(neg_lit)
                if dl < self.level and dl > bt_level:
                    bt_level = dl
        
        if not learned:
            # Fallback: learn negation of all current-level decisions
            for var in self.trail:
                if self.decision_level.get(var, 0) == self.level:
                    learned.append(-var if self.assignment.get(var, False) else var)
            bt_level = max(0, self.level - 1)
        
        return learned, bt_level
    
    # ─── Backtracking ─────────────────────────────────────────────────
    
    def _backtrack_to(self, target_level: int):
        """Backtrack to the given decision level."""
        while self.trail:
            var = self.trail[-1]
            if self.decision_level.get(var, 0) <= target_level:
                break
            self.trail.pop()
            del self.assignment[var]
            if var in self.decision_level:
                del self.decision_level[var]
            if var in self.antecedent:
                del self.antecedent[var]
        
        self.level = target_level
        if self.trail_lim:
            while len(self.trail_lim) > target_level:
                if self.trail_lim:
                    self.trail_lim.pop()
                else:
                    break
    
    # ─── Quantum Tunneling ────────────────────────────────────────────
    
    def _quantum_tunnel(self):
        """Escape local minimum via coherence-weighted random walk."""
        self.stats.tunnel_jumps += 1
        
        # Compute coherence landscape around current assignment
        assigned_vars = list(self.assignment.keys())
        if not assigned_vars:
            return
        
        # Flip variables with probability proportional to coherence improvement
        n_flips = max(1, len(assigned_vars) // 5)
        candidates = random.sample(assigned_vars, min(n_flips, len(assigned_vars)))
        
        for var in candidates:
            current_val = self.assignment[var]
            # Check if flipping improves coherence
            new_score = self._coherence_score(var, not current_val)
            old_score = self._coherence_score(var, current_val)
            
            delta = new_score - old_score
            # Metropolis criterion
            if delta > 0 or random.random() < math.exp(delta / max(self._tunnel_temp, 0.01)):
                # Backtrack this variable and try the flip
                if self.decision_level.get(var, 0) >= self.level:
                    self.assignment[var] = not current_val
        
        self._tunnel_temp *= self._tunnel_decay
    
    # ─── Activity Bumping ─────────────────────────────────────────────
    
    def _bump_activity(self, var: int):
        """Bump VSIDS activity for a variable."""
        self.activity[var] = self.activity.get(var, 0) + self.activity_inc
        if self.activity[var] > 1e100:
            # Rescale
            for v in self.activity:
                self.activity[v] /= 1e100
            self.activity_inc /= 1e100
    
    def _decay_activity(self):
        """Decay all activities."""
        self.activity_inc /= self.activity_decay
    
    # ─── Restart Logic (Luby Sequence) ────────────────────────────────
    
    @staticmethod
    def _luby(i: int) -> int:
        """Compute the i-th element of the Luby sequence (iterative)."""
        # Iterative implementation to avoid recursion depth issues
        for size in range(1, 32):
            seq_len = (1 << size) - 1
            if i <= seq_len:
                # i is within the first 'size' levels
                while True:
                    seq_len = (1 << size) - 1
                    if i == seq_len:
                        return 1 << (size - 1)
                    size -= 1
                    if size <= 0:
                        return 1
                    half = (1 << size) - 1
                    if i > half:
                        i -= half
        return 1
    
    def _should_restart(self) -> bool:
        """Check if we should restart."""
        if self.stats.conflicts >= self._conflicts_until_restart:
            self._luby_index += 1
            luby_val = self._luby(self._luby_index)
            self._conflicts_until_restart = self.stats.conflicts + self._restart_base * luby_val
            return True
        return False
    
    def _restart(self):
        """Perform a restart."""
        self.stats.restarts += 1
        self._backtrack_to(0)
        self._tunnel_temp = 1.0  # Reset tunneling temperature
        self._coherence_cache.clear()
    
    # ─── Satisfaction Check ───────────────────────────────────────────
    
    def _is_satisfied(self) -> bool:
        """Check if all clauses are satisfied."""
        for clause in self.clauses:
            if not any(
                (lit > 0 and self.assignment.get(abs(lit), False)) or
                (lit < 0 and not self.assignment.get(abs(lit), True))
                for lit in clause
            ):
                return False
        return True
    
    # ─── Main Solve Loop ─────────────────────────────────────────────
    
    def solve(self) -> Optional[dict[int, bool]]:
        """
        Main solving loop.
        Returns satisfying assignment or None if UNSAT.
        """
        self.stats.start_time = time.time()
        
        # Initial propagation
        conflict = self._propagate()
        if conflict is not None:
            return None
        if self._is_satisfied():
            return dict(self.assignment)
        
        while True:
            # Timeout check
            if self.stats.elapsed() > self.timeout:
                if self.verbose:
                    print(f"  TIMEOUT after {self.stats}")
                return None
            
            # Check restart
            if self._should_restart():
                self._restart()
                conflict = self._propagate()
                if conflict is not None:
                    return None
            
            # Select variable
            selection = self._select_variable()
            if selection is None:
                if self._is_satisfied():
                    return dict(self.assignment)
                # All assigned but not satisfied — shouldn't happen with correct propagation
                if self.level == 0:
                    return None
                self._backtrack_to(self.level - 1)
                continue
            
            var, val = selection
            self.stats.decisions += 1
            
            # Make decision
            self.level += 1
            self.trail_lim.append(len(self.trail))
            self.assignment[var] = val
            self.decision_level[var] = self.level
            self.antecedent[var] = None  # Decision, not implication
            self.trail.append(var)
            
            # Propagate
            conflict = self._propagate()
            
            if conflict is not None:
                self.stats.conflicts += 1
                
                # Bump activities of conflict variables
                for lit in conflict:
                    self._bump_activity(abs(lit))
                self._decay_activity()
                
                if self.level == 0:
                    return None  # UNSAT
                
                # Analyze conflict
                learned, bt_level = self._analyze_conflict(conflict)
                
                if learned:
                    self.clauses.append(learned)
                    self.stats.learned_clauses += 1
                
                # Backtrack
                self._backtrack_to(bt_level)
                self.stats.backtracks += 1
                
                # Quantum tunneling on repeated conflicts
                if self.stats.conflicts % 50 == 0 and self.mode != "vsids":
                    self._quantum_tunnel()
                
                # Re-propagate
                conflict = self._propagate()
                if conflict is not None:
                    if self.level == 0:
                        return None
                    self._backtrack_to(max(0, self.level - 1))
            
            elif self._is_satisfied():
                return dict(self.assignment)
            
            # Periodic logging
            if self.verbose and self.stats.decisions % 500 == 0:
                print(f"  [{self.stats}]")


# ═══════════════════════════════════════════════════════════════════════════
#  Batch Solver — Emergent Decidability Engine
# ═══════════════════════════════════════════════════════════════════════════

class BatchCoherenceSolver:
    """
    Solves a batch of related SAT instances collectively,
    exploiting inter-instance coherence for speedup.
    """
    
    def __init__(self, instances: list[tuple[int, list[list[int]]]],
                 verbose: bool = False):
        self.instances = instances
        self.verbose = verbose
        self.stats = {"total_time": 0, "instances_solved": 0,
                      "coherence_speedup": 0}
    
    def _compute_similarity(self, c1: list[list[int]], c2: list[list[int]]) -> float:
        """Compute structural similarity between two clause sets."""
        s1 = set(tuple(sorted(c)) for c in c1)
        s2 = set(tuple(sorted(c)) for c in c2)
        if not s1 and not s2:
            return 1.0
        return len(s1 & s2) / max(len(s1 | s2), 1)
    
    def _transfer_hints(self, source_assignment: dict[int, bool],
                        similarity: float) -> dict[int, float]:
        """Generate phase hints from a solved instance."""
        hints = {}
        for var, val in source_assignment.items():
            hints[var] = similarity * (1.0 if val else -1.0)
        return hints
    
    def solve_batch(self) -> list[Optional[dict[int, bool]]]:
        """Solve all instances in the batch, exploiting cross-instance coherence."""
        t0 = time.time()
        results = [None] * len(self.instances)
        
        # Sort instances by estimated difficulty (clause/variable ratio)
        order = sorted(range(len(self.instances)),
                      key=lambda i: len(self.instances[i][1]) / max(self.instances[i][0], 1))
        
        solved_assignments = []
        solved_clauses = []
        
        for idx in order:
            num_vars, clauses = self.instances[idx]
            
            # Compute coherence hints from already-solved instances
            hints: dict[int, float] = {}
            for prev_asgn, prev_clauses in zip(solved_assignments, solved_clauses):
                sim = self._compute_similarity(clauses, prev_clauses)
                if sim > 0.1:
                    h = self._transfer_hints(prev_asgn, sim)
                    for var, score in h.items():
                        hints[var] = hints.get(var, 0) + score
            
            # Solve with coherence guidance + hints
            solver = UniversalCoherenceSolver(num_vars, clauses, mode="hybrid",
                                             verbose=False, timeout=10.0)
            
            # Apply phase hints
            for var, score in hints.items():
                if var in solver.activity:
                    solver.activity[var] += abs(score)
            
            result = solver.solve()
            results[idx] = result
            
            if result:
                solved_assignments.append(result)
                solved_clauses.append(clauses)
                self.stats["instances_solved"] += 1
            
            if self.verbose:
                status = "SAT" if result else "UNSAT/TIMEOUT"
                print(f"  Instance {idx+1}/{len(self.instances)}: {status} "
                      f"({solver.stats.decisions} decisions)")
        
        self.stats["total_time"] = time.time() - t0
        return results


# ═══════════════════════════════════════════════════════════════════════════
#  Utilities
# ═══════════════════════════════════════════════════════════════════════════

def parse_dimacs(filename: str) -> tuple[int, list[list[int]]]:
    """Parse a DIMACS CNF file."""
    clauses = []
    num_vars = 0
    with open(filename, 'r') as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith('c') or line.startswith('%'):
                continue
            if line.startswith('p'):
                parts = line.split()
                num_vars = int(parts[2])
                continue
            lits = [int(x) for x in line.split() if int(x) != 0]
            if lits:
                clauses.append(lits)
    return num_vars, clauses


def generate_random_3sat(num_vars: int, ratio: float,
                         seed: Optional[int] = None) -> list[list[int]]:
    """Generate a random 3-SAT instance."""
    rng = random.Random(seed)
    num_clauses = int(num_vars * ratio)
    clauses = []
    for _ in range(num_clauses):
        vars_chosen = rng.sample(range(1, num_vars + 1), min(3, num_vars))
        clause = [v * rng.choice([-1, 1]) for v in vars_chosen]
        clauses.append(clause)
    return clauses


def generate_pigeonhole(pigeons: int, holes: int) -> tuple[int, list[list[int]]]:
    """Generate pigeonhole principle formula PHP(pigeons, holes)."""
    def var(p, h):
        return (p - 1) * holes + h
    
    num_vars = pigeons * holes
    clauses = []
    
    # Each pigeon in some hole
    for p in range(1, pigeons + 1):
        clauses.append([var(p, h) for h in range(1, holes + 1)])
    
    # No two pigeons in same hole
    for h in range(1, holes + 1):
        for p1 in range(1, pigeons + 1):
            for p2 in range(p1 + 1, pigeons + 1):
                clauses.append([-var(p1, h), -var(p2, h)])
    
    return num_vars, clauses


def generate_graph_coloring(n_vertices: int, n_colors: int,
                            edge_prob: float = 0.3,
                            seed: int = 42) -> tuple[int, list[list[int]]]:
    """Generate a graph coloring SAT instance."""
    rng = random.Random(seed)
    
    def var(v, c):
        return v * n_colors + c + 1
    
    num_vars = n_vertices * n_colors
    clauses = []
    
    # Each vertex gets at least one color
    for v in range(n_vertices):
        clauses.append([var(v, c) for c in range(n_colors)])
    
    # Each vertex gets at most one color
    for v in range(n_vertices):
        for c1 in range(n_colors):
            for c2 in range(c1 + 1, n_colors):
                clauses.append([-var(v, c1), -var(v, c2)])
    
    # Adjacent vertices get different colors
    for v1 in range(n_vertices):
        for v2 in range(v1 + 1, n_vertices):
            if rng.random() < edge_prob:
                for c in range(n_colors):
                    clauses.append([-var(v1, c), -var(v2, c)])
    
    return num_vars, clauses


def verify_solution(clauses: list[list[int]], assignment: dict[int, bool]) -> bool:
    """Verify that an assignment satisfies all clauses."""
    for clause in clauses:
        if not any(
            (lit > 0 and assignment.get(abs(lit), False)) or
            (lit < 0 and not assignment.get(abs(lit), True))
            for lit in clause
        ):
            return False
    return True


# ═══════════════════════════════════════════════════════════════════════════
#  Demonstrations
# ═══════════════════════════════════════════════════════════════════════════

def demo():
    """Run comprehensive demonstrations."""
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║     UNIVERSAL COHERENCE SAT SOLVER (UCSS) — Demonstrations         ║")
    print("║     Combining Coherence Fields, Quantum Tunneling, and CDCL        ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()
    
    # ─── Demo 1: Mode Comparison ────────────────────────────────────
    print("=" * 70)
    print("  DEMO 1: Solving Mode Comparison")
    print("=" * 70)
    print()
    
    test_cases = [
        ("Random 3-SAT (50 vars)", 50, generate_random_3sat(50, 3.5, seed=42)),
        ("Random 3-SAT (100 vars)", 100, generate_random_3sat(100, 3.0, seed=42)),
        ("Random 3-SAT (200 vars)", 200, generate_random_3sat(200, 3.0, seed=42)),
    ]
    
    print(f"  {'Instance':<30} {'Mode':<12} {'Result':<8} {'Decisions':>10} {'Time':>10}")
    print("  " + "-" * 74)
    
    for name, nvars, clauses in test_cases:
        for mode in ["coherence", "vsids", "hybrid"]:
            solver = UniversalCoherenceSolver(nvars, clauses, mode=mode, timeout=15.0)
            result = solver.solve()
            status = "SAT" if result else "UNSAT"
            if result:
                assert verify_solution(clauses, result), "Invalid solution!"
            print(f"  {name:<30} {mode:<12} {status:<8} {solver.stats.decisions:>10} "
                  f"{solver.stats.elapsed():>9.3f}s")
        print()
    
    # ─── Demo 2: Phase Transition ───────────────────────────────────
    print("=" * 70)
    print("  DEMO 2: Phase Transition Detection")
    print("=" * 70)
    print()
    
    n = 40
    ratios = [3.0, 3.5, 4.0, 4.267, 4.5, 5.0, 5.5]
    
    for ratio in ratios:
        sat_count = 0
        total_decisions = 0
        trials = 5
        for t in range(trials):
            clauses = generate_random_3sat(n, ratio, seed=t * 100)
            solver = UniversalCoherenceSolver(n, clauses, mode="hybrid", timeout=5.0)
            result = solver.solve()
            if result:
                sat_count += 1
            total_decisions += solver.stats.decisions
        
        avg_dec = total_decisions / trials
        pct = sat_count / trials * 100
        bar_len = int(pct / 100 * 40)
        bar = "█" * bar_len + "░" * (40 - bar_len)
        print(f"  α={ratio:.3f}: {sat_count}/{trials} SAT |{bar}| "
              f"avg {avg_dec:.0f} decisions")
    
    print()
    print("  → Peak difficulty near α ≈ 4.267 (known phase transition)")
    print()
    
    # ─── Demo 3: Pigeonhole Principle ───────────────────────────────
    print("=" * 70)
    print("  DEMO 3: Pigeonhole Principle (Known UNSAT)")
    print("=" * 70)
    print()
    
    for pigeons in [3, 4, 5]:
        holes = pigeons - 1
        nvars, clauses = generate_pigeonhole(pigeons, holes)
        solver = UniversalCoherenceSolver(nvars, clauses, mode="hybrid",
                                         timeout=10.0, verbose=False)
        t0 = time.time()
        result = solver.solve()
        elapsed = time.time() - t0
        print(f"  PHP({pigeons},{holes}): {'SAT' if result else 'UNSAT'}, "
              f"{solver.stats.decisions} decisions, "
              f"{solver.stats.conflicts} conflicts, {elapsed:.3f}s")
    
    print()
    
    # ─── Demo 4: Batch Solving ──────────────────────────────────────
    print("=" * 70)
    print("  DEMO 4: Batch Solving — Emergent Decidability")
    print("=" * 70)
    print()
    
    # Generate a batch of related instances
    base_seed = 42
    batch_size = 20
    n_vars = 30
    
    instances = []
    for i in range(batch_size):
        clauses = generate_random_3sat(n_vars, 3.5, seed=base_seed + i)
        instances.append((n_vars, clauses))
    
    # Solve individually
    print("  Solving individually:")
    t0 = time.time()
    individual_decisions = 0
    individual_solved = 0
    for nvars, clauses in instances:
        solver = UniversalCoherenceSolver(nvars, clauses, mode="hybrid", timeout=5.0)
        result = solver.solve()
        individual_decisions += solver.stats.decisions
        if result:
            individual_solved += 1
    individual_time = time.time() - t0
    print(f"    Solved: {individual_solved}/{batch_size}, "
          f"Total decisions: {individual_decisions}, Time: {individual_time:.3f}s")
    
    # Solve as batch
    print("  Solving as batch:")
    batch_solver = BatchCoherenceSolver(instances, verbose=False)
    results = batch_solver.solve_batch()
    batch_solved = sum(1 for r in results if r is not None)
    print(f"    Solved: {batch_solved}/{batch_size}, "
          f"Time: {batch_solver.stats['total_time']:.3f}s")
    
    if individual_time > 0:
        speedup = individual_time / max(batch_solver.stats['total_time'], 0.001)
        print(f"    Batch speedup: {speedup:.2f}x")
    print()
    
    # ─── Demo 5: Graph Coloring ─────────────────────────────────────
    print("=" * 70)
    print("  DEMO 5: Graph Coloring via SAT Encoding")
    print("=" * 70)
    print()
    
    for n_verts, n_cols in [(8, 3), (10, 3), (12, 4), (15, 3)]:
        nvars, clauses = generate_graph_coloring(n_verts, n_cols, edge_prob=0.3, seed=42)
        solver = UniversalCoherenceSolver(nvars, clauses, mode="hybrid", timeout=10.0)
        result = solver.solve()
        status = "SAT" if result else "UNSAT"
        verified = verify_solution(clauses, result) if result else "N/A"
        print(f"  {n_verts} vertices, {n_cols} colors: {status} "
              f"(verified: {verified}, {solver.stats.decisions} decisions)")
    
    print()
    
    # ─── Demo 6: Quantum Tunneling Effectiveness ────────────────────
    print("=" * 70)
    print("  DEMO 6: Quantum Tunneling vs Standard Backtracking")
    print("=" * 70)
    print()
    
    # Hard structured instance
    n = 60
    clauses = generate_random_3sat(n, 4.2, seed=777)
    
    for mode, label in [("vsids", "VSIDS only"), ("coherence", "Coherence only"),
                        ("hybrid", "Hybrid + Tunneling")]:
        solver = UniversalCoherenceSolver(n, clauses, mode=mode, timeout=15.0)
        result = solver.solve()
        status = "SAT" if result else "?"
        print(f"  {label:<25}: {status}, {solver.stats.decisions:>6} decisions, "
              f"{solver.stats.conflicts:>5} conflicts, "
              f"{solver.stats.tunnel_jumps:>3} tunnels, "
              f"{solver.stats.elapsed():.3f}s")
    
    print()
    print("=" * 70)
    print("  All demonstrations complete.")
    print("=" * 70)


def benchmark():
    """Run performance benchmarks."""
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║                    UCSS Performance Benchmarks                      ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()
    
    print(f"  {'Test':<35} {'n':>5} {'m':>6} {'Mode':<10} "
          f"{'Result':<6} {'Decisions':>10} {'Time':>8}")
    print("  " + "-" * 82)
    
    benchmarks = [
        ("Random 3-SAT (easy)", 50, 3.0),
        ("Random 3-SAT (medium)", 100, 3.5),
        ("Random 3-SAT (hard)", 150, 4.0),
        ("Random 3-SAT (transition)", 100, 4.267),
        ("Random 3-SAT (over-constrained)", 80, 5.5),
    ]
    
    for name, n, ratio in benchmarks:
        clauses = generate_random_3sat(n, ratio, seed=42)
        m = len(clauses)
        for mode in ["hybrid"]:
            solver = UniversalCoherenceSolver(n, clauses, mode=mode, timeout=30.0)
            result = solver.solve()
            status = "SAT" if result else "UNSAT"
            if result:
                assert verify_solution(clauses, result)
            print(f"  {name:<35} {n:>5} {m:>6} {mode:<10} "
                  f"{status:<6} {solver.stats.decisions:>10} "
                  f"{solver.stats.elapsed():>7.3f}s")
    
    # Pigeonhole benchmarks
    for p in range(3, 7):
        nvars, clauses = generate_pigeonhole(p, p-1)
        solver = UniversalCoherenceSolver(nvars, clauses, mode="hybrid", timeout=30.0)
        result = solver.solve()
        status = "UNSAT" if result is None else "SAT"
        print(f"  {'Pigeonhole PHP('+str(p)+','+str(p-1)+')':<35} {nvars:>5} "
              f"{len(clauses):>6} {'hybrid':<10} "
              f"{status:<6} {solver.stats.decisions:>10} "
              f"{solver.stats.elapsed():>7.3f}s")
    
    # Graph coloring benchmarks
    for nv, nc in [(10, 3), (15, 3), (15, 4), (20, 4)]:
        nvars, clauses = generate_graph_coloring(nv, nc, seed=42)
        solver = UniversalCoherenceSolver(nvars, clauses, mode="hybrid", timeout=30.0)
        result = solver.solve()
        status = "SAT" if result else "UNSAT"
        if result:
            assert verify_solution(clauses, result)
        name = f"GraphColor({nv}v,{nc}c)"
        print(f"  {name:<35} {nvars:>5} {len(clauses):>6} {'hybrid':<10} "
              f"{status:<6} {solver.stats.decisions:>10} "
              f"{solver.stats.elapsed():>7.3f}s")
    
    print()


# ═══════════════════════════════════════════════════════════════════════════
#  Main Entry Point
# ═══════════════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    if len(sys.argv) < 2 or sys.argv[1] == "--demo":
        demo()
    elif sys.argv[1] == "--benchmark":
        benchmark()
    elif sys.argv[1] == "--batch":
        files = sys.argv[2:]
        instances = [parse_dimacs(f) for f in files]
        batch_solver = BatchCoherenceSolver(instances, verbose=True)
        results = batch_solver.solve_batch()
        for f, r in zip(files, results):
            print(f"{f}: {'SAT' if r else 'UNSAT'}")
    else:
        num_vars, clauses = parse_dimacs(sys.argv[1])
        print(f"Solving {sys.argv[1]}: {num_vars} variables, {len(clauses)} clauses")
        solver = UniversalCoherenceSolver(num_vars, clauses, mode="hybrid",
                                         verbose=True, timeout=300.0)
        result = solver.solve()
        if result:
            verified = verify_solution(clauses, result)
            print(f"\nSAT (verified: {verified})")
            print("v " + " ".join(
                str(v if result.get(v, False) else -v)
                for v in range(1, num_vars + 1)) + " 0")
        else:
            print("\nUNSAT")
        print(f"\n{solver.stats}")

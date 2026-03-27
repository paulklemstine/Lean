#!/usr/bin/env python3
"""
Coherence-Guided SAT Solver
============================

A complete SAT solver inspired by the Algorithmic Universal Oracle (AUO).
Uses Lempel-Ziv compressibility as a proxy for Kolmogorov complexity to
guide branching decisions. Implements DPLL with coherence-based variable
and polarity selection.

This is a fully functional solver that accepts DIMACS CNF format.

Usage:
    python coherence_sat.py <file.cnf>
    python coherence_sat.py --random <nvars> <clause_ratio>
    python coherence_sat.py --demo
"""

import sys
import zlib
import random
import time
from typing import Optional
from dataclasses import dataclass, field


@dataclass
class SolverStats:
    decisions: int = 0
    propagations: int = 0
    conflicts: int = 0
    backtracks: int = 0
    coherence_evals: int = 0
    start_time: float = 0.0

    def elapsed(self) -> float:
        return time.time() - self.start_time


class CoherenceSATSolver:
    """
    A DPLL-based SAT solver with coherence-guided branching.
    
    The core idea: at each branching decision, choose the variable and
    polarity that maximize the compressibility of the resulting simplified
    formula. This is a computable approximation to the AUO's coherence
    criterion.
    """

    def __init__(self, num_vars: int, clauses: list[list[int]], verbose: bool = False):
        self.num_vars = num_vars
        self.clauses = clauses  # List of lists of signed literals
        self.assignment: dict[int, bool] = {}
        self.decision_stack: list[tuple[int, bool, set]] = []  # (var, value, propagated_vars)
        self.stats = SolverStats()
        self.verbose = verbose

        # Watched literals data structure (2-watched-literal scheme)
        self.watches: dict[int, list[int]] = {}  # literal -> list of clause indices
        for lit in range(-num_vars, num_vars + 1):
            if lit != 0:
                self.watches[lit] = []
        
        for i, clause in enumerate(self.clauses):
            if len(clause) >= 1:
                self.watches[clause[0]].append(i)
            if len(clause) >= 2:
                self.watches[clause[1]].append(i)

    def _compress_size(self, data: bytes) -> int:
        """Compute compressed size as a proxy for Kolmogorov complexity."""
        return len(zlib.compress(data, level=1))

    def _formula_to_bytes(self, extra_assignment: Optional[dict[int, bool]] = None) -> bytes:
        """
        Encode current formula state as bytes for compressibility analysis.
        Uses the current assignment plus any extra trial assignment.
        """
        assignment = dict(self.assignment)
        if extra_assignment:
            assignment.update(extra_assignment)

        # Encode simplified formula
        parts = []
        for clause in self.clauses:
            simplified = []
            satisfied = False
            for lit in clause:
                var = abs(lit)
                if var in assignment:
                    val = assignment[var]
                    if (lit > 0 and val) or (lit < 0 and not val):
                        satisfied = True
                        break
                else:
                    simplified.append(lit)
            if not satisfied and simplified:
                parts.append(bytes([(abs(l) % 256) ^ (128 if l < 0 else 0) for l in simplified]))
        
        return b'|'.join(parts)

    def _coherence_score(self, var: int, value: bool) -> float:
        """
        Compute the coherence score for assigning var=value.
        Higher score = more compressible result = more coherent.
        """
        self.stats.coherence_evals += 1
        trial = {var: value}
        data = self._formula_to_bytes(trial)
        if not data:
            return float('inf')  # Formula is satisfied — maximally coherent
        compressed = self._compress_size(data)
        raw = len(data)
        if raw == 0:
            return float('inf')
        # Coherence = compression ratio (higher = more compressible = better)
        return 1.0 - compressed / raw

    def _select_variable(self) -> Optional[tuple[int, bool]]:
        """
        Select the next variable and polarity using coherence-guided heuristic.
        
        Strategy: Among unassigned variables, pick the one where the difference
        in coherence between True and False is largest (most decisive), then
        choose the more coherent polarity.
        """
        unassigned = [v for v in range(1, self.num_vars + 1) if v not in self.assignment]
        if not unassigned:
            return None

        # For efficiency, sample if there are too many unassigned variables
        candidates = unassigned if len(unassigned) <= 8 else random.sample(unassigned, 8)

        best_var = candidates[0]
        best_val = True
        best_gap = -1.0

        for var in candidates:
            score_true = self._coherence_score(var, True)
            score_false = self._coherence_score(var, False)
            gap = abs(score_true - score_false)
            if gap > best_gap:
                best_gap = gap
                best_var = var
                best_val = score_true >= score_false

        return (best_var, best_val)

    def _propagate(self) -> Optional[list[int]]:
        """
        Boolean Constraint Propagation (unit propagation).
        Returns None if no conflict, or the conflicting clause if conflict found.
        """
        changed = True
        while changed:
            changed = False
            for i, clause in enumerate(self.clauses):
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
                    return clause  # Conflict!
                
                if len(unsat_lits) == 1:
                    # Unit clause — must propagate
                    lit = unsat_lits[0]
                    var = abs(lit)
                    val = lit > 0
                    self.assignment[var] = val
                    self.stats.propagations += 1
                    changed = True
        
        return None

    def _is_satisfied(self) -> bool:
        """Check if all clauses are satisfied."""
        for clause in self.clauses:
            satisfied = False
            for lit in clause:
                var = abs(lit)
                if var in self.assignment:
                    val = self.assignment[var]
                    if (lit > 0 and val) or (lit < 0 and not val):
                        satisfied = True
                        break
            if not satisfied:
                return False
        return True

    def solve(self) -> Optional[dict[int, bool]]:
        """
        Main DPLL loop with coherence-guided branching.
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
            # Select variable using coherence heuristic
            selection = self._select_variable()
            if selection is None:
                if self._is_satisfied():
                    return dict(self.assignment)
                else:
                    # Need to backtrack
                    if not self._backtrack():
                        return None
                    continue

            var, val = selection
            self.stats.decisions += 1

            # Save state for backtracking
            saved_assignment = dict(self.assignment)
            
            # Try the coherent choice first
            self.assignment[var] = val
            self.decision_stack.append((var, val, set(saved_assignment.keys())))

            if self.verbose and self.stats.decisions % 100 == 0:
                print(f"  [Decisions: {self.stats.decisions}, "
                      f"Propagations: {self.stats.propagations}, "
                      f"Conflicts: {self.stats.conflicts}, "
                      f"Time: {self.stats.elapsed():.2f}s]")

            conflict = self._propagate()
            if conflict is not None:
                self.stats.conflicts += 1
                if not self._backtrack():
                    return None
            elif self._is_satisfied():
                return dict(self.assignment)

    def _backtrack(self) -> bool:
        """
        Backtrack to the most recent decision point and try the opposite value.
        Uses chronological backtracking (non-chronological would be CDCL).
        """
        while self.decision_stack:
            var, val, saved_keys = self.decision_stack.pop()
            self.stats.backtracks += 1

            # Restore assignment to state before this decision
            self.assignment = {k: v for k, v in self.assignment.items() if k in saved_keys}

            # Try the opposite value
            opposite = not val
            self.assignment[var] = opposite
            # Mark as tried both ways (don't push back to stack)
            
            conflict = self._propagate()
            if conflict is None:
                if self._is_satisfied():
                    return True
                return True  # Continue solving from here
            else:
                self.stats.conflicts += 1
                # Continue backtracking
        
        return False  # Exhausted all possibilities — UNSAT


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


def generate_random_3sat(num_vars: int, clause_ratio: float) -> list[list[int]]:
    """Generate a random 3-SAT instance."""
    num_clauses = int(num_vars * clause_ratio)
    clauses = []
    for _ in range(num_clauses):
        vars_chosen = random.sample(range(1, num_vars + 1), 3)
        clause = [v * random.choice([-1, 1]) for v in vars_chosen]
        clauses.append(clause)
    return clauses


def verify_solution(clauses: list[list[int]], assignment: dict[int, bool]) -> bool:
    """Verify that an assignment satisfies all clauses."""
    for clause in clauses:
        satisfied = False
        for lit in clause:
            var = abs(lit)
            if var in assignment:
                val = assignment[var]
                if (lit > 0 and val) or (lit < 0 and not val):
                    satisfied = True
                    break
        if not satisfied:
            return False
    return True


def demo():
    """Run a demonstration of the coherence SAT solver."""
    print("=" * 70)
    print("  COHERENCE-GUIDED SAT SOLVER — Demonstration")
    print("  Inspired by the Algorithmic Universal Oracle")
    print("=" * 70)
    print()

    # Demo 1: Small satisfiable instance
    print("Demo 1: Small SAT instance (5 variables, 10 clauses)")
    print("-" * 50)
    random.seed(42)
    clauses_1 = generate_random_3sat(5, 2.0)
    print(f"  Clauses: {clauses_1}")
    solver = CoherenceSATSolver(5, clauses_1, verbose=False)
    result = solver.solve()
    if result:
        verified = verify_solution(clauses_1, result)
        print(f"  Result: SAT")
        print(f"  Assignment: {result}")
        print(f"  Verified: {verified}")
    else:
        print(f"  Result: UNSAT")
    print(f"  Stats: {solver.stats.decisions} decisions, "
          f"{solver.stats.propagations} propagations, "
          f"{solver.stats.coherence_evals} coherence evaluations")
    print()

    # Demo 2: Phase transition experiment
    print("Demo 2: Phase transition experiment (20 variables)")
    print("-" * 50)
    ratios = [3.0, 3.5, 4.0, 4.267, 4.5, 5.0]
    for ratio in ratios:
        sat_count = 0
        total_time = 0
        trials = 10
        for trial in range(trials):
            random.seed(1000 + trial)
            clauses = generate_random_3sat(20, ratio)
            solver = CoherenceSATSolver(20, clauses)
            t0 = time.time()
            result = solver.solve()
            total_time += time.time() - t0
            if result is not None:
                sat_count += 1
        print(f"  Ratio {ratio:.3f}: {sat_count}/{trials} SAT, "
              f"avg time {total_time/trials*1000:.1f}ms")
    print()

    # Demo 3: Pigeonhole principle (known UNSAT)
    print("Demo 3: Pigeonhole principle PHP(4,3) — known UNSAT")
    print("-" * 50)
    # 4 pigeons, 3 holes
    # Variables: p_{i,j} = pigeon i in hole j (i=1..4, j=1..3)
    def php_var(pigeon, hole):
        return (pigeon - 1) * 3 + hole  # 1-indexed
    
    clauses_php = []
    # Each pigeon must be in some hole
    for i in range(1, 5):
        clauses_php.append([php_var(i, j) for j in range(1, 4)])
    # No two pigeons in the same hole
    for j in range(1, 4):
        for i1 in range(1, 5):
            for i2 in range(i1 + 1, 5):
                clauses_php.append([-php_var(i1, j), -php_var(i2, j)])
    
    solver = CoherenceSATSolver(12, clauses_php, verbose=False)
    t0 = time.time()
    result = solver.solve()
    elapsed = time.time() - t0
    print(f"  Result: {'SAT' if result else 'UNSAT'}")
    print(f"  Time: {elapsed*1000:.1f}ms")
    print(f"  Stats: {solver.stats.decisions} decisions, "
          f"{solver.stats.conflicts} conflicts")
    print()

    # Demo 4: Coherence analysis
    print("Demo 4: Coherence landscape visualization")
    print("-" * 50)
    random.seed(123)
    clauses_viz = generate_random_3sat(10, 4.0)
    solver = CoherenceSATSolver(10, clauses_viz)
    print("  Variable | Coherence(T) | Coherence(F) | Gap    | Choice")
    print("  " + "-" * 60)
    for var in range(1, 11):
        ct = solver._coherence_score(var, True)
        cf = solver._coherence_score(var, False)
        gap = abs(ct - cf)
        choice = "TRUE" if ct >= cf else "FALSE"
        print(f"  x_{var:<6} | {ct:>11.4f}  | {cf:>11.4f}  | {gap:.4f} | {choice}")
    print()
    print("  Higher coherence = more compressible = more 'natural' choice")
    print("  Larger gap = more decisive variable = prioritize first")

    print()
    print("=" * 70)
    print("  All demonstrations complete.")
    print("=" * 70)


if __name__ == "__main__":
    if len(sys.argv) < 2 or sys.argv[1] == "--demo":
        demo()
    elif sys.argv[1] == "--random":
        nvars = int(sys.argv[2]) if len(sys.argv) > 2 else 100
        ratio = float(sys.argv[3]) if len(sys.argv) > 3 else 4.267
        print(f"Generating random 3-SAT: {nvars} variables, ratio {ratio}")
        clauses = generate_random_3sat(nvars, ratio)
        solver = CoherenceSATSolver(nvars, clauses, verbose=True)
        t0 = time.time()
        result = solver.solve()
        elapsed = time.time() - t0
        if result:
            verified = verify_solution(clauses, result)
            print(f"\nSAT (verified: {verified})")
        else:
            print(f"\nUNSAT")
        print(f"Time: {elapsed:.3f}s")
        print(f"Decisions: {solver.stats.decisions}")
        print(f"Conflicts: {solver.stats.conflicts}")
        print(f"Coherence evaluations: {solver.stats.coherence_evals}")
    else:
        num_vars, clauses = parse_dimacs(sys.argv[1])
        print(f"Solving {sys.argv[1]}: {num_vars} variables, {len(clauses)} clauses")
        solver = CoherenceSATSolver(num_vars, clauses, verbose=True)
        t0 = time.time()
        result = solver.solve()
        elapsed = time.time() - t0
        if result:
            verified = verify_solution(clauses, result)
            print(f"\nSAT (verified: {verified})")
            print(f"v " + " ".join(
                str(v if result.get(v, False) else -v) 
                for v in range(1, num_vars + 1)) + " 0")
        else:
            print(f"\nUNSAT")
        print(f"Time: {elapsed:.3f}s")

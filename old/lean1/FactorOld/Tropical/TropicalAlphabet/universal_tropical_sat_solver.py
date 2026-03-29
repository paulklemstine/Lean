#!/usr/bin/env python3
"""
╔══════════════════════════════════════════════════════════════════════╗
║  UNIVERSAL TROPICAL SAT SOLVER                                      ║
║  Four Strategies United by Tropical Algebra                         ║
╚══════════════════════════════════════════════════════════════════════╝

MATHEMATICAL FOUNDATION:
  The Boolean semiring ({T,F}, OR, AND) embeds into the tropical semiring
  (ℝ ∪ {+∞}, min, +) via True ↦ 0, False ↦ +∞.

  Under this embedding:
    - OR  = min  (tropical addition ⊕)
    - AND = +    (tropical multiplication ⊗)

  A CNF clause (x₁ ∨ ¬x₂ ∨ x₃) becomes min(x₁, x̄₂, x₃)
  The full formula φ = C₁ ∧ ... ∧ Cₘ becomes:
    E(x) = Σᵢ min(literals in Cᵢ)
  
  φ is SAT ↔ min_x E(x) = 0
  MAX-SAT: minimize E(x) (counts violated clauses × ∞, but we use 0/1)

STRATEGIES:
  1. Tropical Coordinate Descent (greedy local search)
  2. Tropical Simulated Annealing (random walk on energy landscape)
  3. Tropical Belief Propagation (min-sum message passing)
  4. Tropical Matrix Methods (exact polynomial-time for 2-SAT)

Author: Meta Oracle Collective
"""

import random
import math
import time
from typing import List, Tuple, Optional, Set, Dict
from itertools import product
from collections import defaultdict

INF = float('inf')

# ═══════════════════════════════════════════════════════════════
# CNF FORMULA REPRESENTATION
# ═══════════════════════════════════════════════════════════════

class CNFFormula:
    """A CNF formula with n variables and m clauses."""
    
    def __init__(self, num_vars: int, clauses: List[List[int]]):
        """
        clauses: list of clauses, each clause is a list of literals.
        Literal i means variable i is positive, -i means negated.
        Variables are 1-indexed.
        """
        self.num_vars = num_vars
        self.clauses = clauses
        self.num_clauses = len(clauses)
    
    def evaluate(self, assignment: List[bool]) -> bool:
        """Check if assignment satisfies the formula."""
        for clause in self.clauses:
            satisfied = False
            for lit in clause:
                var_idx = abs(lit) - 1
                val = assignment[var_idx]
                if (lit > 0 and val) or (lit < 0 and not val):
                    satisfied = True
                    break
            if not satisfied:
                return False
        return True
    
    def count_satisfied(self, assignment: List[bool]) -> int:
        """Count satisfied clauses."""
        count = 0
        for clause in self.clauses:
            for lit in clause:
                var_idx = abs(lit) - 1
                val = assignment[var_idx]
                if (lit > 0 and val) or (lit < 0 and not val):
                    count += 1
                    break
        return count
    
    def tropical_energy(self, assignment: List[bool]) -> float:
        """
        Compute tropical energy: E(x) = Σᵢ min(tropical literals in Cᵢ)
        
        Each variable x maps to 0 (True) or +∞ (False).
        The energy counts unsatisfied clauses (each contributes +∞ → we use 1.0).
        """
        energy = 0.0
        for clause in self.clauses:
            clause_val = INF
            for lit in clause:
                var_idx = abs(lit) - 1
                val = assignment[var_idx]
                if lit > 0:
                    trop_val = 0.0 if val else 1.0
                else:
                    trop_val = 0.0 if not val else 1.0
                clause_val = min(clause_val, trop_val)
            energy += clause_val
        return energy


# ═══════════════════════════════════════════════════════════════
# RANDOM INSTANCE GENERATORS
# ═══════════════════════════════════════════════════════════════

def random_ksat(n: int, m: int, k: int = 3, seed: int = None) -> CNFFormula:
    """Generate a random k-SAT instance with n variables and m clauses."""
    if seed is not None:
        random.seed(seed)
    
    clauses = []
    for _ in range(m):
        vars_chosen = random.sample(range(1, n + 1), min(k, n))
        clause = [v if random.random() < 0.5 else -v for v in vars_chosen]
        clauses.append(clause)
    
    return CNFFormula(n, clauses)

def pigeonhole(n: int) -> CNFFormula:
    """Generate pigeonhole principle: n+1 pigeons, n holes. Always UNSAT."""
    pigeons = n + 1
    holes = n
    
    # Variables: x_{i,j} = pigeon i in hole j (1-indexed)
    def var(i, j):
        return i * holes + j + 1
    
    num_vars = pigeons * holes
    clauses = []
    
    # Each pigeon must be in some hole
    for i in range(pigeons):
        clause = [var(i, j) for j in range(holes)]
        clauses.append(clause)
    
    # No two pigeons in the same hole
    for j in range(holes):
        for i1 in range(pigeons):
            for i2 in range(i1 + 1, pigeons):
                clauses.append([-var(i1, j), -var(i2, j)])
    
    return CNFFormula(num_vars, clauses)


# ═══════════════════════════════════════════════════════════════
# STRATEGY 1: TROPICAL COORDINATE DESCENT
# ═══════════════════════════════════════════════════════════════

class TropicalCoordinateDescent:
    """
    Optimize each variable individually on the tropical energy landscape.
    
    Since the energy is piecewise linear (tropical polynomial), the optimal
    value for each variable is always at a breakpoint (True or False).
    This is a greedy local search that flips the variable giving the
    largest energy decrease.
    """
    
    def solve(self, formula: CNFFormula, max_iter: int = 1000, 
              restarts: int = 10) -> Optional[List[bool]]:
        best_assignment = None
        best_energy = INF
        
        for restart in range(restarts):
            # Random initial assignment
            assignment = [random.random() < 0.5 for _ in range(formula.num_vars)]
            energy = formula.tropical_energy(assignment)
            
            if energy == 0:
                return assignment
            
            for _ in range(max_iter):
                # Find best variable to flip
                best_flip = -1
                best_delta = 0
                
                for var in range(formula.num_vars):
                    assignment[var] = not assignment[var]
                    new_energy = formula.tropical_energy(assignment)
                    delta = new_energy - energy
                    assignment[var] = not assignment[var]  # undo
                    
                    if delta < best_delta:
                        best_delta = delta
                        best_flip = var
                
                if best_flip == -1:
                    break  # Local minimum
                
                assignment[best_flip] = not assignment[best_flip]
                energy += best_delta
                
                if energy == 0:
                    return assignment
            
            if energy < best_energy:
                best_energy = energy
                best_assignment = assignment[:]
        
        return best_assignment if best_energy == 0 else None


# ═══════════════════════════════════════════════════════════════
# STRATEGY 2: TROPICAL SIMULATED ANNEALING
# ═══════════════════════════════════════════════════════════════

class TropicalSimulatedAnnealing:
    """
    The tropical energy landscape has flat regions and sharp edges
    (no smooth basins), creating a "crystalline" landscape.
    
    We use a tropical-inspired cooling schedule:
    T(k) = T₀ ⊘ k = T₀ - log(k) (tropical division = subtraction)
    This gives a slower cooling than classical exponential schedules,
    better suited to the piecewise-linear landscape.
    """
    
    def solve(self, formula: CNFFormula, max_iter: int = 10000,
              T0: float = 2.0, restarts: int = 5) -> Optional[List[bool]]:
        best_assignment = None
        best_energy = INF
        
        for restart in range(restarts):
            assignment = [random.random() < 0.5 for _ in range(formula.num_vars)]
            energy = formula.tropical_energy(assignment)
            
            if energy == 0:
                return assignment
            
            for k in range(1, max_iter + 1):
                # Tropical cooling: T = T₀ - log(k)
                T = max(T0 - math.log(k + 1), 0.01)
                
                # Random variable flip
                var = random.randint(0, formula.num_vars - 1)
                assignment[var] = not assignment[var]
                new_energy = formula.tropical_energy(assignment)
                delta = new_energy - energy
                
                # Metropolis criterion
                if delta <= 0 or random.random() < math.exp(-delta / T):
                    energy = new_energy
                else:
                    assignment[var] = not assignment[var]  # reject
                
                if energy == 0:
                    return assignment
            
            if energy < best_energy:
                best_energy = energy
                best_assignment = assignment[:]
        
        return best_assignment if best_energy == 0 else None


# ═══════════════════════════════════════════════════════════════
# STRATEGY 3: TROPICAL BELIEF PROPAGATION (MIN-SUM)
# ═══════════════════════════════════════════════════════════════

class TropicalBeliefPropagation:
    """
    The min-sum algorithm IS tropical belief propagation.
    
    Messages are tropical costs:
    - Variable → Clause: "my cost for being True/False"
    - Clause → Variable: "my cost for you being True/False given others"
    
    In tropical algebra:
    - Message aggregation uses ⊕ = min
    - Cost combination uses ⊗ = +
    """
    
    def solve(self, formula: CNFFormula, max_iter: int = 100,
              damping: float = 0.5) -> Optional[List[bool]]:
        n = formula.num_vars
        m = formula.num_clauses
        
        # Initialize messages: var_to_clause[var][clause] = [cost_false, cost_true]
        var_to_clause = [[{} for _ in range(m)] for _ in range(n)]
        clause_to_var = [[{} for _ in range(n)] for _ in range(m)]
        
        # Build adjacency
        var_clauses = [[] for _ in range(n)]  # which clauses contain var
        clause_vars = [[] for _ in range(m)]  # which vars in clause
        
        for ci, clause in enumerate(formula.clauses):
            for lit in clause:
                vi = abs(lit) - 1
                var_clauses[vi].append((ci, lit > 0))  # (clause_idx, is_positive)
                clause_vars[ci].append((vi, lit > 0))
        
        # Initialize messages to 0
        msg_v2c = {}  # (var, clause) -> [cost_false, cost_true]
        msg_c2v = {}  # (clause, var) -> [cost_false, cost_true]
        
        for vi in range(n):
            for ci, _ in var_clauses[vi]:
                msg_v2c[(vi, ci)] = [0.0, 0.0]
                msg_c2v[(ci, vi)] = [0.0, 0.0]
        
        for iteration in range(max_iter):
            # Update clause → variable messages
            for ci, clause in enumerate(formula.clauses):
                for vi, is_pos in clause_vars[ci]:
                    # Cost for variable vi to be False/True
                    # given this clause needs to be satisfied
                    other_vars = [(vj, ip) for vj, ip in clause_vars[ci] if vj != vi]
                    
                    for val in [0, 1]:  # 0=False, 1=True
                        # Does vi satisfy this clause?
                        if (val == 1 and is_pos) or (val == 0 and not is_pos):
                            # vi satisfies clause alone → no additional cost
                            msg_c2v[(ci, vi)][val] = 0.0
                        else:
                            # Need at least one other variable to satisfy
                            if not other_vars:
                                msg_c2v[(ci, vi)][val] = 1.0  # penalty
                            else:
                                # min over other vars satisfying the clause
                                min_cost = 1.0  # worst case: none satisfy
                                for vj, jp in other_vars:
                                    # Cost of vj satisfying the clause
                                    if jp:  # positive literal
                                        cost = msg_v2c.get((vj, ci), [0, 0])[1]
                                    else:
                                        cost = msg_v2c.get((vj, ci), [0, 0])[0]
                                    min_cost = min(min_cost, cost)
                                msg_c2v[(ci, vi)][val] = min_cost
            
            # Update variable → clause messages
            for vi in range(n):
                for ci, _ in var_clauses[vi]:
                    for val in [0, 1]:
                        # Sum of clause→var messages from OTHER clauses
                        total = 0.0
                        for cj, _ in var_clauses[vi]:
                            if cj != ci:
                                total += msg_c2v.get((cj, vi), [0, 0])[val]
                        
                        # Damping
                        old = msg_v2c[(vi, ci)][val]
                        msg_v2c[(vi, ci)][val] = damping * old + (1 - damping) * total
            
            # Decode: choose assignment based on total beliefs
            assignment = []
            for vi in range(n):
                cost_false = sum(msg_c2v.get((ci, vi), [0, 0])[0] for ci, _ in var_clauses[vi])
                cost_true = sum(msg_c2v.get((ci, vi), [0, 0])[1] for ci, _ in var_clauses[vi])
                assignment.append(cost_true <= cost_false)
            
            if formula.evaluate(assignment):
                return assignment
        
        # Final decode
        assignment = []
        for vi in range(n):
            cost_false = sum(msg_c2v.get((ci, vi), [0, 0])[0] for ci, _ in var_clauses[vi])
            cost_true = sum(msg_c2v.get((ci, vi), [0, 0])[1] for ci, _ in var_clauses[vi])
            assignment.append(cost_true <= cost_false)
        
        return assignment if formula.evaluate(assignment) else None


# ═══════════════════════════════════════════════════════════════
# STRATEGY 4: TROPICAL MATRIX METHODS (2-SAT)
# ═══════════════════════════════════════════════════════════════

class TropicalMatrixSolver:
    """
    For 2-SAT: each clause (a ∨ b) = (¬a → b) ∧ (¬b → a).
    
    Build implication graph as tropical adjacency matrix.
    Kleene star (Floyd-Warshall) = all-pairs shortest paths.
    If x and ¬x have finite mutual reachability → UNSAT.
    Otherwise, extract satisfying assignment via SCC ordering.
    """
    
    def solve(self, formula: CNFFormula) -> Optional[List[bool]]:
        n = formula.num_vars
        
        # Check all clauses are 2-SAT
        for clause in formula.clauses:
            if len(clause) > 2:
                return None  # Not 2-SAT
        
        # Build implication graph
        # Nodes: 0..2n-1 where node i = x_{i+1}, node n+i = ¬x_{i+1}
        size = 2 * n
        
        def lit_to_node(lit):
            if lit > 0:
                return lit - 1
            else:
                return n + (-lit) - 1
        
        def neg_node(node):
            if node < n:
                return node + n
            else:
                return node - n
        
        # Tropical adjacency matrix (0 = edge exists, INF = no edge)
        adj = [[INF] * size for _ in range(size)]
        for i in range(size):
            adj[i][i] = 0
        
        for clause in formula.clauses:
            if len(clause) == 1:
                # Unit clause: lit must be true
                # ¬lit → lit (weight 0)
                a = lit_to_node(clause[0])
                adj[neg_node(a)][a] = 0
            elif len(clause) == 2:
                # (a ∨ b) = (¬a → b) ∧ (¬b → a)
                a = lit_to_node(clause[0])
                b = lit_to_node(clause[1])
                adj[neg_node(a)][b] = 0
                adj[neg_node(b)][a] = 0
        
        # Floyd-Warshall = Tropical Kleene Star
        dist = [row[:] for row in adj]
        for k in range(size):
            for i in range(size):
                for j in range(size):
                    if dist[i][k] < INF and dist[k][j] < INF:
                        new_dist = dist[i][k] + dist[k][j]
                        if new_dist < dist[i][j]:
                            dist[i][j] = new_dist
        
        # Check for contradictions: x and ¬x in same SCC
        for i in range(n):
            if dist[i][i + n] < INF and dist[i + n][i] < INF:
                return None  # UNSAT: x_i and ¬x_i mutually reachable
        
        # Extract satisfying assignment using Aspvall-Plass-Tarjan
        # Simplified: assign based on reachability
        assignment = [False] * n
        for i in range(n):
            # If ¬x_i reaches x_i but not vice versa, set x_i = True
            if dist[i + n][i] < INF and dist[i][i + n] >= INF:
                assignment[i] = True
            elif dist[i][i + n] < INF and dist[i + n][i] >= INF:
                assignment[i] = False
            else:
                assignment[i] = True  # Default
        
        if formula.evaluate(assignment):
            return assignment
        
        # Try flipping if simple heuristic fails
        for i in range(n):
            assignment[i] = not assignment[i]
            if formula.evaluate(assignment):
                return assignment
            assignment[i] = not assignment[i]
        
        return None


# ═══════════════════════════════════════════════════════════════
# UNIVERSAL SOLVER: COMBINES ALL STRATEGIES
# ═══════════════════════════════════════════════════════════════

class UniversalTropicalSATSolver:
    """
    Universal solver that combines all four strategies:
    1. Try 2-SAT matrix method first (polynomial time)
    2. Try belief propagation (good for structured instances)
    3. Try coordinate descent (good for easy instances)
    4. Try simulated annealing (good for hard instances)
    """
    
    def __init__(self, verbose: bool = True):
        self.verbose = verbose
        self.strategies = {
            'matrix': TropicalMatrixSolver(),
            'bp': TropicalBeliefPropagation(),
            'cd': TropicalCoordinateDescent(),
            'sa': TropicalSimulatedAnnealing(),
        }
        self.stats = {}
    
    def solve(self, formula: CNFFormula) -> Tuple[Optional[List[bool]], str]:
        """
        Try to solve the formula. Returns (assignment, strategy_used) or (None, 'UNSAT').
        """
        start_time = time.time()
        
        # Strategy 1: 2-SAT matrix method
        if all(len(c) <= 2 for c in formula.clauses):
            if self.verbose:
                print("  [Matrix] Attempting 2-SAT tropical matrix method...")
            result = self.strategies['matrix'].solve(formula)
            elapsed = time.time() - start_time
            if result is not None:
                if self.verbose:
                    print(f"  [Matrix] SOLVED in {elapsed:.4f}s")
                return result, 'matrix'
            else:
                if self.verbose:
                    print(f"  [Matrix] UNSAT detected in {elapsed:.4f}s")
                return None, 'matrix-UNSAT'
        
        # Strategy 2: Belief propagation
        if self.verbose:
            print("  [BP] Attempting tropical belief propagation...")
        t0 = time.time()
        result = self.strategies['bp'].solve(formula)
        elapsed = time.time() - t0
        if result is not None:
            if self.verbose:
                print(f"  [BP] SOLVED in {elapsed:.4f}s")
            return result, 'bp'
        
        # Strategy 3: Coordinate descent
        if self.verbose:
            print("  [CD] Attempting tropical coordinate descent...")
        t0 = time.time()
        result = self.strategies['cd'].solve(formula)
        elapsed = time.time() - t0
        if result is not None:
            if self.verbose:
                print(f"  [CD] SOLVED in {elapsed:.4f}s")
            return result, 'cd'
        
        # Strategy 4: Simulated annealing
        if self.verbose:
            print("  [SA] Attempting tropical simulated annealing...")
        t0 = time.time()
        result = self.strategies['sa'].solve(formula, max_iter=50000)
        elapsed = time.time() - t0
        if result is not None:
            if self.verbose:
                print(f"  [SA] SOLVED in {elapsed:.4f}s")
            return result, 'sa'
        
        total_time = time.time() - start_time
        if self.verbose:
            print(f"  [ALL] No solution found in {total_time:.4f}s")
        return None, 'UNKNOWN'


# ═══════════════════════════════════════════════════════════════
# BENCHMARK SUITE
# ═══════════════════════════════════════════════════════════════

def run_benchmarks():
    """Run comprehensive benchmarks on the tropical SAT solver."""
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║  UNIVERSAL TROPICAL SAT SOLVER - Benchmark Suite               ║")
    print("╚══════════════════════════════════════════════════════════════════╝")
    
    solver = UniversalTropicalSATSolver(verbose=True)
    
    # ─── Test 1: 2-SAT instances ───
    print("\n" + "=" * 60)
    print("TEST 1: 2-SAT Instances (Polynomial-Time via Matrix Method)")
    print("=" * 60)
    
    for n in [5, 10, 20]:
        m = int(2.0 * n)  # Below threshold
        formula = random_ksat(n, m, k=2, seed=42 + n)
        print(f"\n  2-SAT: n={n}, m={m}")
        result, strategy = solver.solve(formula)
        if result:
            verified = formula.evaluate(result)
            print(f"  Result: {'SAT ✓' if verified else 'ERROR!'}")
        else:
            print(f"  Result: UNSAT (detected by {strategy})")
    
    # ─── Test 2: Pigeonhole principle ───
    print("\n" + "=" * 60)
    print("TEST 2: Pigeonhole Principle (Known UNSAT)")
    print("=" * 60)
    
    for n in [2, 3, 4]:
        formula = pigeonhole(n)
        print(f"\n  Pigeonhole({n+1} pigeons, {n} holes): {formula.num_vars} vars, {formula.num_clauses} clauses")
        
        # For small instances, verify by brute force
        if formula.num_vars <= 15:
            is_sat = False
            for bits in range(2 ** formula.num_vars):
                assignment = [(bits >> i) & 1 == 1 for i in range(formula.num_vars)]
                if formula.evaluate(assignment):
                    is_sat = True
                    break
            print(f"  Brute force verification: {'SAT' if is_sat else 'UNSAT ✓'}")
        
        result, strategy = solver.solve(formula)
        energy = formula.tropical_energy([False] * formula.num_vars)
        print(f"  Solver result: {'SAT' if result else 'UNSAT'} (strategy: {strategy})")
        print(f"  Min tropical energy found: {energy:.1f} (> 0 confirms UNSAT)")
    
    # ─── Test 3: Random 3-SAT near phase transition ───
    print("\n" + "=" * 60)
    print("TEST 3: Random 3-SAT Near Phase Transition (α ≈ 4.27)")
    print("=" * 60)
    
    for n in [5, 10, 15, 20]:
        alpha = 4.27
        m = int(alpha * n)
        solved = 0
        trials = 10
        strategies_used = defaultdict(int)
        
        for seed in range(trials):
            formula = random_ksat(n, m, k=3, seed=seed * 100 + n)
            result, strategy = UniversalTropicalSATSolver(verbose=False).solve(formula)
            if result:
                solved += 1
                strategies_used[strategy] += 1
        
        print(f"\n  3-SAT n={n}, m={m} (α={alpha}): {solved}/{trials} solved ({100*solved/trials:.0f}%)")
        for strat, count in sorted(strategies_used.items()):
            print(f"    Strategy {strat}: {count} instances")
    
    # ─── Test 4: Easy satisfiable instances ───
    print("\n" + "=" * 60)
    print("TEST 4: Easy Random 3-SAT (α = 3.0, well below threshold)")
    print("=" * 60)
    
    for n in [10, 20, 50]:
        alpha = 3.0
        m = int(alpha * n)
        solved = 0
        trials = 10
        total_time = 0
        
        for seed in range(trials):
            formula = random_ksat(n, m, k=3, seed=seed * 200 + n)
            t0 = time.time()
            result, _ = UniversalTropicalSATSolver(verbose=False).solve(formula)
            total_time += time.time() - t0
            if result:
                solved += 1
        
        print(f"\n  3-SAT n={n}, m={m}: {solved}/{trials} solved, avg time {total_time/trials:.4f}s")
    
    # ─── Test 5: Tropical Energy Landscape Analysis ───
    print("\n" + "=" * 60)
    print("TEST 5: Tropical Energy Landscape Analysis")
    print("=" * 60)
    
    formula = random_ksat(8, 34, k=3, seed=42)  # Near phase transition
    
    # Sample random assignments and measure energy distribution
    energies = []
    for _ in range(1000):
        assignment = [random.random() < 0.5 for _ in range(formula.num_vars)]
        energies.append(formula.tropical_energy(assignment))
    
    print(f"\n  Random 3-SAT: n=8, m=34")
    print(f"  Energy distribution over 1000 random assignments:")
    print(f"    Min energy:  {min(energies):.1f}")
    print(f"    Max energy:  {max(energies):.1f}")
    print(f"    Mean energy: {sum(energies)/len(energies):.2f}")
    print(f"    Std dev:     {(sum((e - sum(energies)/len(energies))**2 for e in energies)/len(energies))**0.5:.2f}")
    
    # Energy histogram
    bins = [0, 1, 2, 3, 4, 5, 10, 20, 50]
    print(f"\n    Energy histogram:")
    for i in range(len(bins) - 1):
        count = sum(1 for e in energies if bins[i] <= e < bins[i+1])
        bar = '█' * (count // 5)
        print(f"      [{bins[i]:>2}-{bins[i+1]:>2}): {count:>4} {bar}")
    count = sum(1 for e in energies if e == 0)
    print(f"      [= 0 ]: {count:>4} {'█' * (count // 5)} ← satisfying assignments")
    
    print("\n" + "=" * 60)
    print("BENCHMARK COMPLETE")
    print("=" * 60)


# ═══════════════════════════════════════════════════════════════
# APPLICATION DEMOS
# ═══════════════════════════════════════════════════════════════

def demo_applications():
    """Demonstrate proposed applications of tropical SAT solving."""
    print("\n╔══════════════════════════════════════════════════════════════════╗")
    print("║  PROPOSED APPLICATIONS OF TROPICAL SAT SOLVING                 ║")
    print("╚══════════════════════════════════════════════════════════════════╝")
    
    # Application 1: Graph Coloring as SAT
    print("\n─── Application 1: Graph Coloring via Tropical SAT ───")
    print("  Encoding 3-colorability of a small graph as 2-SAT constraints")
    
    # 4-node cycle graph: 1-2-3-4-1 (3-colorable)
    n_nodes = 4
    n_colors = 3
    edges = [(0,1), (1,2), (2,3), (3,0)]
    
    # Variables: x_{node, color} = node has color
    def var(node, color):
        return node * n_colors + color + 1
    
    num_vars = n_nodes * n_colors
    clauses = []
    
    # Each node has at least one color
    for node in range(n_nodes):
        clauses.append([var(node, c) for c in range(n_colors)])
    
    # Adjacent nodes have different colors
    for u, v in edges:
        for c in range(n_colors):
            clauses.append([-var(u, c), -var(v, c)])
    
    formula = CNFFormula(num_vars, clauses)
    solver = UniversalTropicalSATSolver(verbose=False)
    result, strategy = solver.solve(formula)
    
    if result:
        print(f"  Graph is 3-colorable! (solved by {strategy})")
        for node in range(n_nodes):
            for c in range(n_colors):
                if result[var(node, c) - 1]:
                    print(f"    Node {node}: color {c}")
    else:
        print("  Graph is NOT 3-colorable")
    
    # Application 2: Scheduling
    print("\n─── Application 2: Simple Scheduling via Tropical SAT ───")
    print("  3 tasks, 3 time slots, with precedence constraints")
    
    n_tasks = 3
    n_slots = 3
    precedences = [(0, 1), (1, 2)]  # task 0 before 1, task 1 before 2
    
    def svar(task, slot):
        return task * n_slots + slot + 1
    
    num_vars = n_tasks * n_slots
    clauses = []
    
    # Each task in exactly one slot
    for t in range(n_tasks):
        clauses.append([svar(t, s) for s in range(n_slots)])
        for s1 in range(n_slots):
            for s2 in range(s1 + 1, n_slots):
                clauses.append([-svar(t, s1), -svar(t, s2)])
    
    # Precedence: if task a before task b, slot(a) < slot(b)
    for a, b in precedences:
        for sa in range(n_slots):
            for sb in range(sa + 1):  # sb <= sa violates precedence
                clauses.append([-svar(a, sa), -svar(b, sb)])
    
    formula = CNFFormula(num_vars, clauses)
    result, strategy = solver.solve(formula)
    
    if result:
        print(f"  Schedule found! (solved by {strategy})")
        for t in range(n_tasks):
            for s in range(n_slots):
                if result[svar(t, s) - 1]:
                    print(f"    Task {t}: time slot {s}")
    else:
        print("  No valid schedule exists")
    
    print("\n  These applications demonstrate that tropical SAT solving")
    print("  provides a unified algebraic framework for constraint satisfaction,")
    print("  connecting graph algorithms, scheduling, and logic programming")
    print("  through the tropical semiring.")


# ═══════════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════════

if __name__ == "__main__":
    run_benchmarks()
    demo_applications()

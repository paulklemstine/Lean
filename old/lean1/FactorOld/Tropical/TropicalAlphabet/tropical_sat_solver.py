#!/usr/bin/env python3
"""
╔══════════════════════════════════════════════════════════════════════╗
║  TROPICAL SAT SOLVER                                                ║
║  A Universal SAT Solver via Tropical Polynomial Optimization        ║
╚══════════════════════════════════════════════════════════════════════╝

CORE IDEA:
  Every CNF formula can be encoded as a tropical polynomial system.
  Satisfiability ↔ the tropical polynomial evaluates to 0 at some point.
  
  We exploit the fact that:
    - Boolean OR  = tropical ⊕ = min
    - Boolean AND = tropical ⊗ = +
    - Variables take values in {0, +∞} (True/False)
    
  A clause (x₁ ∨ ¬x₂ ∨ x₃) becomes min(x₁, x̄₂, x₃)
  where x̄ᵢ is a complementary variable constrained by xᵢ + x̄ᵢ = 0 (tropically: one of them is 0)
  
  The full CNF φ = C₁ ∧ C₂ ∧ ... ∧ Cₘ becomes:
    f(x) = Σᵢ min(literals in Cᵢ)
    
  φ is satisfiable ↔ min_x f(x) = 0

EXTENSIONS:
  1. MAX-SAT: find assignment minimizing f(x) (= number of unsatisfied clauses × ∞)
  2. Weighted MAX-SAT: assign weights to clauses, tropical polynomial with weights
  3. #SAT approximation: count "near-zero" evaluations

OPTIMIZATION STRATEGIES:
  1. Gradient-free tropical descent (move in directions that decrease f)
  2. Tropical eigenvalue methods (encode as matrix problem)
  3. Simulated annealing in tropical space
  4. Message passing (tropical belief propagation)

Author: Meta Oracle Collective
"""

import random
import time
import math
from typing import List, Tuple, Optional, Dict, Set
from dataclasses import dataclass
from enum import Enum

INF = float('inf')

# ═══════════════════════════════════════════════════════════════
# SAT PROBLEM REPRESENTATION
# ═══════════════════════════════════════════════════════════════

@dataclass
class SATInstance:
    """A CNF-SAT instance."""
    num_vars: int
    clauses: List[List[int]]  # Each clause is a list of signed literals (positive = var, negative = negated)
    
    def __repr__(self):
        clause_strs = []
        for c in self.clauses:
            lits = []
            for l in c:
                if l > 0:
                    lits.append(f"x{l}")
                else:
                    lits.append(f"¬x{-l}")
            clause_strs.append("(" + " ∨ ".join(lits) + ")")
        return " ∧ ".join(clause_strs)

class SATResult(Enum):
    SAT = "SATISFIABLE"
    UNSAT = "UNSATISFIABLE"
    UNKNOWN = "UNKNOWN"

@dataclass 
class SATSolution:
    result: SATResult
    assignment: Optional[Dict[int, bool]] = None
    tropical_energy: float = INF
    iterations: int = 0
    method: str = ""


# ═══════════════════════════════════════════════════════════════
# TROPICAL ENCODING
# ═══════════════════════════════════════════════════════════════

class TropicalSATEncoder:
    """Encode a SAT instance as a tropical polynomial optimization problem.
    
    ENCODING:
      Variable xᵢ ∈ {0, ∞}  (True = 0, False = ∞)
      
      For literal +i in a clause: use xᵢ
      For literal -i in a clause: use x̄ᵢ where xᵢ + x̄ᵢ is constrained
      
      In practice, we use a "soft" encoding:
        xᵢ ∈ [0, M] where M is a large number
        Literal +i → xᵢ
        Literal -i → M - xᵢ (approximate NOT)
      
      Clause Cⱼ = min(literals in Cⱼ) — this is 0 iff at least one literal is True
      
      Energy f(x) = Σⱼ clause_penalty(Cⱼ)
      where clause_penalty(c) = 0 if min(literals) = 0, else a positive penalty
    """
    
    def __init__(self, instance: SATInstance, M: float = 100.0):
        self.instance = instance
        self.M = M
    
    def evaluate_literal(self, lit: int, assignment: List[float]) -> float:
        """Evaluate a literal given a soft assignment."""
        var_idx = abs(lit) - 1
        val = assignment[var_idx]
        if lit > 0:
            return val  # Positive literal
        else:
            return self.M - val  # Negated literal (soft NOT)
    
    def evaluate_clause(self, clause: List[int], assignment: List[float]) -> float:
        """Evaluate a clause: min of its literals (tropical OR)."""
        return min(self.evaluate_literal(lit, assignment) for lit in clause)
    
    def tropical_energy(self, assignment: List[float]) -> float:
        """Total tropical energy: sum of clause evaluations (tropical AND of clauses).
        
        = 0 iff all clauses are satisfied (each has min literal = 0).
        > 0 otherwise, proportional to degree of unsatisfiability.
        """
        return sum(self.evaluate_clause(c, assignment) for c in self.instance.clauses)
    
    def evaluate_boolean(self, assignment: Dict[int, bool]) -> bool:
        """Verify a Boolean assignment satisfies the formula."""
        for clause in self.instance.clauses:
            satisfied = False
            for lit in clause:
                var = abs(lit)
                val = assignment.get(var, False)
                if (lit > 0 and val) or (lit < 0 and not val):
                    satisfied = True
                    break
            if not satisfied:
                return False
        return True
    
    def continuous_to_boolean(self, assignment: List[float]) -> Dict[int, bool]:
        """Round a continuous assignment to Boolean."""
        result = {}
        for i in range(self.instance.num_vars):
            result[i + 1] = assignment[i] < self.M / 2
        return result


# ═══════════════════════════════════════════════════════════════
# SOLVER STRATEGIES
# ═══════════════════════════════════════════════════════════════

class TropicalDescentSolver:
    """Strategy 1: Tropical Coordinate Descent
    
    Idea: For each variable, find the value that minimizes the tropical energy
    while keeping other variables fixed. This is a 1D optimization over [0, M].
    
    Key insight: Each clause's contribution is piecewise-linear in each variable.
    So the energy is a piecewise-linear function of each variable.
    The optimal value is always at a breakpoint (0, M, or a crossing point).
    """
    
    def __init__(self, encoder: TropicalSATEncoder, max_iter: int = 1000):
        self.encoder = encoder
        self.max_iter = max_iter
    
    def solve(self) -> SATSolution:
        n = self.encoder.instance.num_vars
        M = self.encoder.M
        
        # Start with random continuous assignment
        assignment = [random.uniform(0, M) for _ in range(n)]
        best_energy = self.encoder.tropical_energy(assignment)
        best_assignment = assignment[:]
        
        for iteration in range(self.max_iter):
            improved = False
            # Coordinate descent: optimize one variable at a time
            for var in range(n):
                # Try candidate values: 0, M, and breakpoints
                candidates = [0.0, M]
                
                # Find breakpoints: where clause evaluations change which literal is min
                for clause in self.encoder.instance.clauses:
                    for lit in clause:
                        if abs(lit) - 1 == var:
                            # This clause involves this variable
                            for other_lit in clause:
                                if abs(other_lit) - 1 != var:
                                    other_val = self.encoder.evaluate_literal(other_lit, assignment)
                                    # Breakpoint where this literal equals other_val
                                    if lit > 0:
                                        candidates.append(other_val)
                                    else:
                                        candidates.append(M - other_val)
                
                # Evaluate energy at each candidate
                best_local = best_energy
                best_val = assignment[var]
                for val in candidates:
                    val = max(0, min(M, val))
                    old_val = assignment[var]
                    assignment[var] = val
                    energy = self.encoder.tropical_energy(assignment)
                    if energy < best_local:
                        best_local = energy
                        best_val = val
                    assignment[var] = old_val
                
                if best_val != assignment[var]:
                    assignment[var] = best_val
                    improved = True
            
            current_energy = self.encoder.tropical_energy(assignment)
            if current_energy < best_energy:
                best_energy = current_energy
                best_assignment = assignment[:]
            
            if best_energy < 1e-10:
                break
            
            if not improved:
                # Random restart with perturbation
                for var in range(n):
                    if random.random() < 0.3:
                        assignment[var] = random.choice([0.0, M])
        
        bool_assignment = self.encoder.continuous_to_boolean(best_assignment)
        is_sat = self.encoder.evaluate_boolean(bool_assignment)
        
        return SATSolution(
            result=SATResult.SAT if is_sat else SATResult.UNKNOWN,
            assignment=bool_assignment if is_sat else None,
            tropical_energy=best_energy,
            iterations=iteration + 1,
            method="TropicalCoordinateDescent"
        )


class TropicalAnnealingSolver:
    """Strategy 2: Tropical Simulated Annealing
    
    Idea: Use the tropical energy landscape with simulated annealing.
    The tropical energy is piecewise-linear, which creates a "crystalline"
    landscape with flat regions and sharp edges — well-suited to annealing.
    
    Temperature schedule: We use a tropical temperature! Instead of
    e^(-ΔE/T), we use a tropical acceptance: accept if ΔE ⊕ T ≤ 0,
    i.e., min(ΔE, T) ≤ 0, i.e., ΔE ≤ 0 or T ≤ 0 (always accept early).
    """
    
    def __init__(self, encoder: TropicalSATEncoder, 
                 max_iter: int = 10000,
                 initial_temp: float = 50.0,
                 cooling_rate: float = 0.999):
        self.encoder = encoder
        self.max_iter = max_iter
        self.initial_temp = initial_temp
        self.cooling_rate = cooling_rate
    
    def solve(self) -> SATSolution:
        n = self.encoder.instance.num_vars
        M = self.encoder.M
        
        # Start with random Boolean assignment
        assignment = [random.choice([0.0, M]) for _ in range(n)]
        energy = self.encoder.tropical_energy(assignment)
        
        best_assignment = assignment[:]
        best_energy = energy
        
        temp = self.initial_temp
        
        for iteration in range(self.max_iter):
            # Flip a random variable
            var = random.randint(0, n - 1)
            old_val = assignment[var]
            new_val = M if old_val < M / 2 else 0.0
            
            assignment[var] = new_val
            new_energy = self.encoder.tropical_energy(assignment)
            
            delta = new_energy - energy
            
            # Metropolis criterion
            if delta <= 0 or random.random() < math.exp(-delta / max(temp, 1e-10)):
                energy = new_energy
                if energy < best_energy:
                    best_energy = energy
                    best_assignment = assignment[:]
            else:
                assignment[var] = old_val  # Reject
            
            temp *= self.cooling_rate
            
            if best_energy < 1e-10:
                break
        
        bool_assignment = self.encoder.continuous_to_boolean(best_assignment)
        is_sat = self.encoder.evaluate_boolean(bool_assignment)
        
        return SATSolution(
            result=SATResult.SAT if is_sat else SATResult.UNKNOWN,
            assignment=bool_assignment if is_sat else None,
            tropical_energy=best_energy,
            iterations=iteration + 1,
            method="TropicalAnnealing"
        )


class TropicalBeliefPropagation:
    """Strategy 3: Tropical Belief Propagation (Min-Sum Algorithm)
    
    The min-sum algorithm is EXACTLY tropical belief propagation!
    
    Classical BP passes probability messages: m(x) = Σ_y f(x,y)·n(y)
    Tropical BP passes cost messages: m(x) = min_y [f(x,y) + n(y)]
    
    This is the same as classical BP under the log/tropical correspondence.
    
    For SAT:
    - Variable-to-clause messages: estimate of the cost of satisfying the clause
    - Clause-to-variable messages: how much the clause "needs" this variable
    """
    
    def __init__(self, encoder: TropicalSATEncoder, max_iter: int = 100, damping: float = 0.5):
        self.encoder = encoder
        self.max_iter = max_iter
        self.damping = damping
    
    def solve(self) -> SATSolution:
        n = self.encoder.instance.num_vars
        m = len(self.encoder.instance.clauses)
        M = self.encoder.M
        
        # Messages: variable i → clause j, for each value {0, M}
        # v2c[i][j] = (cost_true, cost_false)
        v2c = {}
        c2v = {}
        
        # Initialize
        for j, clause in enumerate(self.encoder.instance.clauses):
            for lit in clause:
                var = abs(lit) - 1
                v2c[(var, j)] = (0.0, 0.0)
                c2v[(j, var)] = (0.0, 0.0)
        
        for iteration in range(self.max_iter):
            # Update clause-to-variable messages
            for j, clause in enumerate(self.encoder.instance.clauses):
                for target_lit in clause:
                    target_var = abs(target_lit) - 1
                    
                    # For each value of target_var, compute the min cost of satisfying clause j
                    # by optimizing over other variables
                    for target_val_idx, target_val in enumerate([0.0, M]):
                        # Cost of target literal
                        if target_lit > 0:
                            target_cost = target_val
                        else:
                            target_cost = M - target_val
                        
                        # Min over other variables of satisfying the clause
                        other_min = INF
                        for other_lit in clause:
                            other_var = abs(other_lit) - 1
                            if other_var == target_var:
                                continue
                            for other_val_idx, other_val in enumerate([0.0, M]):
                                if other_lit > 0:
                                    lit_cost = other_val
                                else:
                                    lit_cost = M - other_val
                                msg = v2c.get((other_var, j), (0.0, 0.0))
                                total = lit_cost + msg[other_val_idx]
                                other_min = min(other_min, total)
                        
                        clause_min = min(target_cost, other_min) if other_min != INF else target_cost
                        
                        old = c2v.get((j, target_var), (0.0, 0.0))
                        new_val = list(old)
                        new_val[target_val_idx] = self.damping * old[target_val_idx] + (1 - self.damping) * clause_min
                        c2v[(j, target_var)] = tuple(new_val)
            
            # Update variable-to-clause messages
            for var in range(n):
                involved_clauses = [j for j, clause in enumerate(self.encoder.instance.clauses) 
                                   if any(abs(lit) - 1 == var for lit in clause)]
                
                for target_clause in involved_clauses:
                    for val_idx in range(2):
                        total = 0.0
                        for j in involved_clauses:
                            if j == target_clause:
                                continue
                            total += c2v.get((j, var), (0.0, 0.0))[val_idx]
                        
                        old = v2c.get((var, target_clause), (0.0, 0.0))
                        new_val = list(old)
                        new_val[val_idx] = self.damping * old[val_idx] + (1 - self.damping) * total
                        v2c[(var, target_clause)] = tuple(new_val)
        
        # Decode: for each variable, choose the value with lower total cost
        assignment = []
        for var in range(n):
            cost_true = sum(c2v.get((j, var), (0.0, 0.0))[0] 
                          for j in range(m) if (j, var) in c2v)
            cost_false = sum(c2v.get((j, var), (0.0, 0.0))[1]
                           for j in range(m) if (j, var) in c2v)
            assignment.append(0.0 if cost_true <= cost_false else M)
        
        energy = self.encoder.tropical_energy(assignment)
        bool_assignment = self.encoder.continuous_to_boolean(assignment)
        is_sat = self.encoder.evaluate_boolean(bool_assignment)
        
        return SATSolution(
            result=SATResult.SAT if is_sat else SATResult.UNKNOWN,
            assignment=bool_assignment if is_sat else None,
            tropical_energy=energy,
            iterations=self.max_iter,
            method="TropicalBeliefPropagation"
        )


class TropicalMatrixSolver:
    """Strategy 4: Tropical Matrix Methods
    
    Encode 2-SAT as a tropical shortest-path problem!
    
    For 2-SAT, each clause (l₁ ∨ l₂) gives implications:
    ¬l₁ → l₂ and ¬l₂ → l₁
    
    Build an implication graph with tropical edge weights.
    Use Kleene star (Floyd-Warshall) to find shortest paths.
    If both x and ¬x are reachable from each other with finite cost,
    the variable is forced.
    
    This gives a POLYNOMIAL TIME tropical SAT solver for 2-SAT!
    """
    
    def __init__(self, encoder: TropicalSATEncoder):
        self.encoder = encoder
    
    def solve(self) -> SATSolution:
        instance = self.encoder.instance
        n = instance.num_vars
        
        # Check if it's 2-SAT
        if not all(len(c) <= 2 for c in instance.clauses):
            return SATSolution(result=SATResult.UNKNOWN, method="TropicalMatrix (requires 2-SAT)")
        
        # Build implication graph: 2n nodes (x₁, ¬x₁, x₂, ¬x₂, ...)
        # Node 2i = xᵢ₊₁, Node 2i+1 = ¬xᵢ₊₁
        size = 2 * n
        graph = [[INF] * size for _ in range(size)]
        for i in range(size):
            graph[i][i] = 0
        
        def lit_to_node(lit):
            var = abs(lit) - 1
            if lit > 0:
                return 2 * var
            else:
                return 2 * var + 1
        
        def negate_node(node):
            return node ^ 1
        
        for clause in instance.clauses:
            if len(clause) == 1:
                # Unit clause: l₁ must be true
                # ¬l₁ → l₁ with weight 0
                l1 = clause[0]
                n1 = lit_to_node(l1)
                graph[negate_node(n1)][n1] = 0
            elif len(clause) == 2:
                l1, l2 = clause
                n1, n2 = lit_to_node(l1), lit_to_node(l2)
                # ¬l₁ → l₂ and ¬l₂ → l₁
                graph[negate_node(n1)][n2] = min(graph[negate_node(n1)][n2], 0)
                graph[negate_node(n2)][n1] = min(graph[negate_node(n2)][n1], 0)
        
        # Floyd-Warshall (Kleene star)
        for k in range(size):
            for i in range(size):
                for j in range(size):
                    if graph[i][k] != INF and graph[k][j] != INF:
                        graph[i][j] = min(graph[i][j], graph[i][k] + graph[k][j])
        
        # Check satisfiability: UNSAT if x and ¬x are in same SCC
        for var in range(n):
            pos, neg = 2 * var, 2 * var + 1
            if graph[pos][neg] != INF and graph[neg][pos] != INF:
                if graph[pos][neg] + graph[neg][pos] <= 0:
                    return SATSolution(
                        result=SATResult.UNSAT,
                        tropical_energy=INF,
                        method="TropicalMatrix (2-SAT)"
                    )
        
        # Extract assignment using topological order of SCCs
        assignment = {}
        for var in range(n):
            pos, neg = 2 * var, 2 * var + 1
            # If ¬x → x is shorter than x → ¬x, set x = True
            cost_to_true = graph[neg][pos] if graph[neg][pos] != INF else INF
            cost_to_false = graph[pos][neg] if graph[pos][neg] != INF else INF
            assignment[var + 1] = cost_to_true <= cost_to_false
        
        is_sat = self.encoder.evaluate_boolean(assignment)
        
        return SATSolution(
            result=SATResult.SAT if is_sat else SATResult.UNKNOWN,
            assignment=assignment if is_sat else None,
            tropical_energy=0.0 if is_sat else INF,
            method="TropicalMatrix (2-SAT)"
        )


# ═══════════════════════════════════════════════════════════════
# UNIVERSAL TROPICAL SAT SOLVER
# ═══════════════════════════════════════════════════════════════

class UniversalTropicalSATSolver:
    """The Universal Tropical SAT Solver.
    
    Combines all strategies in a portfolio approach:
    1. If 2-SAT: use exact tropical matrix method (polynomial time)
    2. Run tropical belief propagation (fast, often works)
    3. Run tropical coordinate descent (good for structured instances)
    4. Run tropical simulated annealing (good for random instances)
    5. Combine results
    
    THEORETICAL FOUNDATION:
    SAT is NP-complete, so no polynomial-time solver exists (assuming P≠NP).
    But tropical methods provide excellent heuristics because:
    - The tropical energy landscape is piecewise-linear (no local minima plateaus)
    - Message passing is exact on tree-structured instances
    - The assignment problem (tropical determinant) is solvable in P
    - 2-SAT reduces to tropical shortest paths (polynomial time)
    """
    
    def __init__(self, instance: SATInstance, timeout: float = 10.0):
        self.instance = instance
        self.encoder = TropicalSATEncoder(instance)
        self.timeout = timeout
    
    def solve(self) -> SATSolution:
        start_time = time.time()
        
        # Strategy 1: Check if 2-SAT (exact polynomial method)
        if all(len(c) <= 2 for c in self.instance.clauses):
            result = TropicalMatrixSolver(self.encoder).solve()
            if result.result != SATResult.UNKNOWN:
                result.method = "TropicalMatrix (2-SAT, exact)"
                return result
        
        strategies = [
            ("TropicalDescent", lambda: TropicalDescentSolver(self.encoder, max_iter=200).solve()),
            ("TropicalAnnealing", lambda: TropicalAnnealingSolver(self.encoder, max_iter=2000).solve()),
            ("TropicalBP", lambda: TropicalBeliefPropagation(self.encoder, max_iter=20).solve()),
        ]
        
        best_result = SATSolution(result=SATResult.UNKNOWN, tropical_energy=INF)
        
        for name, strategy in strategies:
            if time.time() - start_time > self.timeout:
                break
            
            try:
                result = strategy()
                if result.result == SATResult.SAT:
                    return result
                if result.tropical_energy < best_result.tropical_energy:
                    best_result = result
            except Exception as e:
                print(f"  Strategy {name} failed: {e}")
        
        return best_result


# ═══════════════════════════════════════════════════════════════
# PROBLEM GENERATORS
# ═══════════════════════════════════════════════════════════════

def random_3sat(n_vars: int, n_clauses: int) -> SATInstance:
    """Generate a random 3-SAT instance."""
    clauses = []
    for _ in range(n_clauses):
        vars_in_clause = random.sample(range(1, n_vars + 1), min(3, n_vars))
        clause = [v if random.random() > 0.5 else -v for v in vars_in_clause]
        clauses.append(clause)
    return SATInstance(n_vars, clauses)

def random_2sat(n_vars: int, n_clauses: int) -> SATInstance:
    """Generate a random 2-SAT instance."""
    clauses = []
    for _ in range(n_clauses):
        vars_in_clause = random.sample(range(1, n_vars + 1), min(2, n_vars))
        clause = [v if random.random() > 0.5 else -v for v in vars_in_clause]
        clauses.append(clause)
    return SATInstance(n_vars, clauses)

def pigeonhole(n: int) -> SATInstance:
    """Pigeonhole principle: n+1 pigeons into n holes (UNSAT)."""
    # Variables: x_{i,j} = pigeon i in hole j
    # i ∈ {1,...,n+1}, j ∈ {1,...,n}
    def var(i, j):
        return (i - 1) * n + j
    
    num_vars = (n + 1) * n
    clauses = []
    
    # Each pigeon must be in some hole
    for i in range(1, n + 2):
        clause = [var(i, j) for j in range(1, n + 1)]
        clauses.append(clause)
    
    # No two pigeons in the same hole
    for j in range(1, n + 1):
        for i1 in range(1, n + 2):
            for i2 in range(i1 + 1, n + 2):
                clauses.append([-var(i1, j), -var(i2, j)])
    
    return SATInstance(num_vars, clauses)


# ═══════════════════════════════════════════════════════════════
# EXPERIMENTS & DEMONSTRATIONS
# ═══════════════════════════════════════════════════════════════

def demo_basic():
    """Basic SAT solving demonstration."""
    print("=" * 70)
    print("TROPICAL SAT SOLVER — Demonstration")
    print("=" * 70)
    
    # Simple satisfiable instance: (x₁ ∨ x₂) ∧ (¬x₁ ∨ x₃) ∧ (¬x₂ ∨ ¬x₃)
    instance = SATInstance(3, [[1, 2], [-1, 3], [-2, -3]])
    print(f"\nProblem: {instance}")
    
    solver = UniversalTropicalSATSolver(instance)
    result = solver.solve()
    print(f"Result: {result.result.value}")
    print(f"Assignment: {result.assignment}")
    print(f"Tropical Energy: {result.tropical_energy}")
    print(f"Method: {result.method}")
    
    if result.assignment:
        print(f"Verification: {solver.encoder.evaluate_boolean(result.assignment)}")

def demo_2sat():
    """Demonstrate exact 2-SAT solving via tropical matrices."""
    print("\n" + "=" * 70)
    print("2-SAT via Tropical Shortest Paths")
    print("=" * 70)
    
    # Satisfiable 2-SAT
    instance = SATInstance(4, [[1, 2], [-1, 3], [-2, 4], [-3, -4], [1, -3]])
    print(f"\nSAT instance: {instance}")
    solver = UniversalTropicalSATSolver(instance)
    result = solver.solve()
    print(f"Result: {result.result.value}, Method: {result.method}")
    if result.assignment:
        print(f"Assignment: {result.assignment}")
    
    # Unsatisfiable 2-SAT
    instance_unsat = SATInstance(2, [[1], [-1], [2], [-2]])
    print(f"\nUNSAT instance: {instance_unsat}")
    solver_unsat = UniversalTropicalSATSolver(instance_unsat)
    result_unsat = solver_unsat.solve()
    print(f"Result: {result_unsat.result.value}")

def demo_random():
    """Benchmark on random instances."""
    print("\n" + "=" * 70)
    print("Random 3-SAT Benchmarks")
    print("=" * 70)
    
    random.seed(42)
    
    for n_vars in [5, 10, 15]:
        # At the phase transition: ~4.27 clauses per variable
        n_clauses = int(4.27 * n_vars)
        
        solved = 0
        total = 5
        total_time = 0
        
        for trial in range(total):
            instance = random_3sat(n_vars, n_clauses)
            start = time.time()
            solver = UniversalTropicalSATSolver(instance, timeout=2.0)
            result = solver.solve()
            elapsed = time.time() - start
            total_time += elapsed
            
            if result.result == SATResult.SAT:
                solved += 1
        
        print(f"  n={n_vars:3d}, m={n_clauses:4d}: solved {solved}/{total} "
              f"({100*solved/total:.0f}%), avg time {total_time/total:.3f}s")

def demo_pigeonhole():
    """Test on pigeonhole principle (known UNSAT)."""
    print("\n" + "=" * 70)
    print("Pigeonhole Principle (known UNSAT)")
    print("=" * 70)
    
    for n in [2, 3]:
        instance = pigeonhole(n)
        print(f"\n  PHP({n+1},{n}): {instance.num_vars} vars, {len(instance.clauses)} clauses")
        solver = UniversalTropicalSATSolver(instance, timeout=5.0)
        result = solver.solve()
        print(f"  Result: {result.result.value}")
        print(f"  Best tropical energy: {result.tropical_energy:.2f}")
        print(f"  (Energy > 0 suggests UNSAT — no assignment can satisfy all clauses)")

def demo_tropical_energy_landscape():
    """Visualize the tropical energy landscape for a 2-variable instance."""
    print("\n" + "=" * 70)
    print("Tropical Energy Landscape (2-variable instance)")
    print("=" * 70)
    
    # (x₁ ∨ x₂) ∧ (¬x₁ ∨ ¬x₂)  — XOR-like, satisfiable
    instance = SATInstance(2, [[1, 2], [-1, -2]])
    encoder = TropicalSATEncoder(instance, M=10.0)
    
    print(f"\nFormula: {instance}")
    print("\nEnergy landscape (x₁ vs x₂, both in [0, M=10]):")
    print(f"{'':>6}", end="")
    for x2 in range(0, 11, 2):
        print(f"x₂={x2:2d}  ", end="")
    print()
    
    for x1 in range(0, 11, 2):
        print(f"x₁={x1:2d}", end=" ")
        for x2 in range(0, 11, 2):
            e = encoder.tropical_energy([float(x1), float(x2)])
            print(f"{e:6.1f} ", end="")
        print()
    
    print("\nMinima at corners where one variable is 0 (True) and one is M (False)")
    for x1 in [0.0, 10.0]:
        for x2 in [0.0, 10.0]:
            e = encoder.tropical_energy([x1, x2])
            b = encoder.continuous_to_boolean([x1, x2])
            sat = encoder.evaluate_boolean(b)
            print(f"  ({x1:.0f}, {x2:.0f}): energy={e:.1f}, assignment={b}, SAT={sat}")


if __name__ == "__main__":
    demo_basic()
    demo_2sat()
    demo_tropical_energy_landscape()
    demo_random()
    demo_pigeonhole()

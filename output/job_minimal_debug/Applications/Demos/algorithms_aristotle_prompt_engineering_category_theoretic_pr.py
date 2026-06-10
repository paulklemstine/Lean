"""
Algorithms for Galois Connection-Based Prompt Optimization

Implements the core algorithms from the research paper:
1. Galois connection verification
2. Closure operator computation
3. Iterative prompt refinement with convergence guarantee
4. Closed element enumeration
5. Complete lattice operations on closed elements
"""

from typing import (
    TypeVar, Generic, Callable, Set, FrozenSet, List, Tuple, Optional, Dict
)
from dataclasses import dataclass
from functools import reduce

T = TypeVar('T')
U = TypeVar('U')


# ===========================================================================
# Core Data Structures
# ===========================================================================

@dataclass
class GaloisConnection(Generic[T, U]):
    """
    A Galois connection between two partially ordered sets.
    
    Given monotone maps eval: P → Q and back: Q → P,
    the pair forms a Galois connection if:
        eval(p) ≤ q  ⟺  p ≤ back(q)
    for all p ∈ P, q ∈ Q.
    
    Attributes:
        eval_fn: The left adjoint (prompt → quality evaluation)
        back_fn: The right adjoint (quality → prompt reconstruction)
        le_P: Partial order on P
        le_Q: Partial order on Q
    """
    eval_fn: Callable[[T], U]
    back_fn: Callable[[U], T]
    le_P: Callable[[T, T], bool]
    le_Q: Callable[[U, U], bool]
    
    def closure(self, p: T) -> T:
        """Compute the closure cl(p) = back(eval(p))."""
        return self.back_fn(self.eval_fn(p))
    
    def interior(self, q: U) -> U:
        """Compute the interior int(q) = eval(back(q))."""
        return self.eval_fn(self.back_fn(q))
    
    def is_closed(self, p: T) -> bool:
        """Check if p is a closed (optimal) element."""
        return self.closure(p) == p
    
    def is_open(self, q: U) -> bool:
        """Check if q is an open (achievable quality) element."""
        return self.interior(q) == q
    
    def verify(self, P_elements: List[T], Q_elements: List[U]) -> bool:
        """
        Verify the Galois connection property on finite sets.
        
        Checks: eval(p) ≤ q  ⟺  p ≤ back(q) for all p ∈ P, q ∈ Q.
        
        Time complexity: O(|P| × |Q|)
        Space complexity: O(1)
        """
        for p in P_elements:
            for q in Q_elements:
                lhs = self.le_Q(self.eval_fn(p), q)
                rhs = self.le_P(p, self.back_fn(q))
                if lhs != rhs:
                    return False
        return True


# ===========================================================================
# Algorithm 1: Iterative Prompt Refinement
# ===========================================================================

def iterative_refinement(
    gc: GaloisConnection[T, U],
    p0: T,
    max_iter: int = 1000
) -> Tuple[T, int, List[T]]:
    """
    Iterative prompt refinement via closure iteration.
    
    Starting from initial prompt p₀, computes:
        p_{n+1} = back(eval(p_n))
    
    until convergence (p_n = p_{n+1}).
    
    THEOREM: On a finite partial order, this converges in at most
    |P| steps to a closed (optimal) prompt.
    
    Args:
        gc: Galois connection
        p0: Initial prompt
        max_iter: Safety bound on iterations
    
    Returns:
        (optimal_prompt, num_steps, trajectory)
    
    Time complexity: O(N × (T_eval + T_back)) where N ≤ |P|
    Space complexity: O(N) for storing the trajectory
    """
    trajectory = [p0]
    current = p0
    
    for step in range(max_iter):
        next_p = gc.closure(current)
        trajectory.append(next_p)
        
        if next_p == current:
            return current, step, trajectory
        
        current = next_p
    
    raise RuntimeError(f"Failed to converge in {max_iter} iterations")


# ===========================================================================
# Algorithm 2: Alternating Optimization
# ===========================================================================

def alternating_optimization(
    gc: GaloisConnection[T, U],
    p0: T,
    max_iter: int = 1000
) -> Tuple[T, U, int, List[Tuple[T, U]]]:
    """
    Alternating optimization between prompt and quality spaces.
    
    Alternates:
        q_n = eval(p_n)
        p_{n+1} = back(q_n)
    
    THEOREM: This produces the same sequence as closure iteration,
    and converges to a prompt-quality pair (p*, q*) where:
        - p* is a closed (optimal) prompt
        - q* is an open (achievable) quality level
        - eval(p*) = q* and back(q*) = p*
    
    Args:
        gc: Galois connection
        p0: Initial prompt
        max_iter: Safety bound
    
    Returns:
        (optimal_prompt, optimal_quality, num_steps, trajectory)
    """
    trajectory = []
    current_p = p0
    
    for step in range(max_iter):
        current_q = gc.eval_fn(current_p)
        trajectory.append((current_p, current_q))
        
        next_p = gc.back_fn(current_q)
        
        if next_p == current_p:
            return current_p, current_q, step, trajectory
        
        current_p = next_p
    
    raise RuntimeError(f"Failed to converge in {max_iter} iterations")


# ===========================================================================
# Algorithm 3: Enumerate All Closed Elements
# ===========================================================================

def enumerate_closed_elements(
    gc: GaloisConnection[T, U],
    P_elements: List[T]
) -> List[T]:
    """
    Enumerate all closed (optimal) elements of the prompt space.
    
    THEOREM: The set of closed elements forms a complete lattice.
    
    Time complexity: O(|P| × (T_eval + T_back))
    Space complexity: O(|closed|)
    """
    return [p for p in P_elements if gc.is_closed(p)]


def enumerate_open_elements(
    gc: GaloisConnection[T, U],
    Q_elements: List[U]
) -> List[U]:
    """
    Enumerate all open (achievable quality) elements.
    
    Time complexity: O(|Q| × (T_eval + T_back))
    """
    return [q for q in Q_elements if gc.is_open(q)]


# ===========================================================================
# Algorithm 4: Least Closed Element Above
# ===========================================================================

def least_closed_above(
    gc: GaloisConnection[T, U],
    p: T
) -> T:
    """
    Compute the least closed element above p.
    
    THEOREM (Universal Property): cl(p) is the unique element satisfying:
    1. cl(p) is closed
    2. p ≤ cl(p)
    3. For all closed p', if p ≤ p' then cl(p) ≤ p'
    
    Time complexity: O(T_eval + T_back) — single closure application
    """
    return gc.closure(p)


# ===========================================================================
# Algorithm 5: Powerset Galois Connection from Incidence Relation
# ===========================================================================

def powerset_galois_connection(
    features: List[str],
    metrics: List[str],
    incidence: Set[Tuple[str, str]]
) -> GaloisConnection[FrozenSet[str], FrozenSet[str]]:
    """
    Construct a Galois connection on powersets from an incidence relation.
    
    Given R ⊆ Features × Metrics:
        eval(S) = {j ∈ Metrics | ∀i, R(i,j) → i ∈ S}
        back(T) = {i ∈ Features | ∀j, R(i,j) → j ∈ T}
    
    This is the standard construction from Formal Concept Analysis.
    """
    def eval_fn(S: FrozenSet[str]) -> FrozenSet[str]:
        return frozenset(
            j for j in metrics
            if all(i in S for i in features if (i, j) in incidence)
        )
    
    def back_fn(T: FrozenSet[str]) -> FrozenSet[str]:
        return frozenset(
            i for i in features
            if all(j in T for j in metrics if (i, j) in incidence)
        )
    
    def le_set(a: FrozenSet[str], b: FrozenSet[str]) -> bool:
        return a.issubset(b)
    
    return GaloisConnection(eval_fn, back_fn, le_set, le_set)


# ===========================================================================
# Algorithm 6: Convergence Analysis
# ===========================================================================

def convergence_analysis(
    gc: GaloisConnection[T, U],
    P_elements: List[T]
) -> Dict:
    """
    Analyze convergence properties of iterative refinement.
    
    Returns statistics on:
    - Number of closed elements
    - Maximum convergence steps from any starting point
    - Average convergence steps
    - Distribution of convergence steps
    """
    results = {
        'total_elements': len(P_elements),
        'closed_elements': 0,
        'max_steps': 0,
        'total_steps': 0,
        'step_distribution': {},
        'convergence_map': {}
    }
    
    for p in P_elements:
        optimal, steps, trajectory = iterative_refinement(gc, p)
        
        if steps == 0:
            results['closed_elements'] += 1
        
        results['max_steps'] = max(results['max_steps'], steps)
        results['total_steps'] += steps
        results['step_distribution'][steps] = results['step_distribution'].get(steps, 0) + 1
        results['convergence_map'][p] = (optimal, steps)
    
    results['avg_steps'] = results['total_steps'] / len(P_elements) if P_elements else 0
    
    return results


# ===========================================================================
# Example Usage
# ===========================================================================

if __name__ == "__main__":
    print("ALGORITHM DEMONSTRATIONS")
    print("=" * 60)
    
    # --- Model 1: Linear orders ---
    print("\n--- Linear Order Model ---")
    gc_linear = GaloisConnection(
        eval_fn=lambda p: {0: 0, 1: 0, 2: 1}[p],
        back_fn=lambda q: {0: 1, 1: 2}[q],
        le_P=lambda a, b: a <= b,
        le_Q=lambda a, b: a <= b,
    )
    
    print(f"GC verified: {gc_linear.verify([0,1,2], [0,1])}")
    
    for p0 in [0, 1, 2]:
        opt, steps, traj = iterative_refinement(gc_linear, p0)
        print(f"  Refine({p0}): {' → '.join(map(str, traj))} (steps={steps})")
    
    # --- Model 2: Powerset ---
    print("\n--- Powerset Model (Formal Concept Analysis) ---")
    features = ['specificity', 'density', 'depth', 'breadth']
    metrics_ = ['novelty', 'rigor', 'completeness']
    incidence = {
        ('specificity', 'novelty'), ('specificity', 'rigor'),
        ('density', 'rigor'), ('density', 'completeness'),
        ('depth', 'novelty'), ('depth', 'completeness'),
        ('breadth', 'novelty'), ('breadth', 'rigor'), ('breadth', 'completeness'),
    }
    
    gc_powerset = powerset_galois_connection(features, metrics_, incidence)
    
    # Test some closures
    test = [frozenset(), frozenset(['breadth']), frozenset(features)]
    for S in test:
        cl = gc_powerset.closure(S)
        S_str = '{' + ', '.join(sorted(S)) + '}' if S else '∅'
        cl_str = '{' + ', '.join(sorted(cl)) + '}' if cl else '∅'
        print(f"  cl({S_str}) = {cl_str}  {'[CLOSED]' if cl == S else ''}")
    
    # Convergence analysis
    print("\n--- Convergence Analysis (Linear Model) ---")
    analysis = convergence_analysis(gc_linear, [0, 1, 2])
    print(f"  Total elements: {analysis['total_elements']}")
    print(f"  Closed elements: {analysis['closed_elements']}")
    print(f"  Max steps to converge: {analysis['max_steps']}")
    print(f"  Avg steps: {analysis['avg_steps']:.2f}")
    print(f"  Step distribution: {analysis['step_distribution']}")

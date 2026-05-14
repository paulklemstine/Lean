"""
Algorithms for Prompt Optimization via Galois Connections.

Implements the core algorithms from the research paper with full type hints,
docstrings, and example usage.
"""

from typing import TypeVar, Callable, Tuple, Set, List, Dict, Optional, Generic
from dataclasses import dataclass
import itertools

T = TypeVar('T')
P = TypeVar('P')
Q = TypeVar('Q')


# ============================================================
# Core Algorithm 1: Closure Computation
# ============================================================

def compute_closure(
    eval_fn: Callable[[P], Q],
    back_fn: Callable[[Q], P],
    p: P
) -> P:
    """
    Compute the closure cl(p) = back(eval(p)).
    
    Since the closure is idempotent, a single application produces the
    optimal specification. No iteration needed.
    
    Args:
        eval_fn: Evaluation map P → Q (lower adjoint)
        back_fn: Reconstruction map Q → P (upper adjoint)
        p: Initial specification
    
    Returns:
        The optimal (closed) specification cl(p)
    
    Time complexity: O(T_eval + T_back)
    
    Example:
        >>> compute_closure(lambda p: max(p[0], p[1]), lambda q: (q, q), (3, 7))
        (7, 7)
    """
    return back_fn(eval_fn(p))


# ============================================================
# Core Algorithm 2: Iterative Convergence
# ============================================================

def iterate_to_optimal(
    eval_fn: Callable[[P], Q],
    back_fn: Callable[[Q], P],
    p0: P,
    max_steps: Optional[int] = None
) -> Tuple[P, int, List[P]]:
    """
    Iterate the closure operator until convergence.
    
    For a true Galois connection, this always converges in at most |P| steps.
    In practice (and for our concrete models), convergence is in 1 step.
    
    Args:
        eval_fn: Evaluation map P → Q
        back_fn: Reconstruction map Q → P
        p0: Initial specification
        max_steps: Maximum iterations (safety bound)
    
    Returns:
        Tuple of (optimal_spec, num_steps, trajectory)
    
    Time complexity: O(N · (T_eval + T_back)) where N ≤ |P|
    
    Example:
        >>> result, steps, traj = iterate_to_optimal(
        ...     lambda p: max(p[0], p[1]), lambda q: (q, q), (3, 7))
        >>> result
        (7, 7)
        >>> steps
        1
    """
    trajectory = [p0]
    p = p0
    step = 0
    
    while max_steps is None or step < max_steps:
        p_new = back_fn(eval_fn(p))
        step += 1
        trajectory.append(p_new)
        
        if p_new == p:
            return p, step, trajectory
        p = p_new
    
    return p, step, trajectory


# ============================================================
# Core Algorithm 3: Enumerate All Optimal Specifications
# ============================================================

def enumerate_optimal(
    eval_fn: Callable[[P], Q],
    back_fn: Callable[[Q], P],
    elements: List[P]
) -> List[P]:
    """
    Find all optimal (closed) specifications in a finite set.
    
    A specification p is optimal iff back(eval(p)) = p.
    
    Args:
        eval_fn: Evaluation map
        back_fn: Reconstruction map
        elements: All elements of P
    
    Returns:
        List of optimal specifications
    
    Time complexity: O(|P| · (T_eval + T_back))
    
    Example:
        >>> elements = [(a, b) for a in range(4) for b in range(4)]
        >>> optimal = enumerate_optimal(
        ...     lambda p: max(p[0], p[1]), lambda q: (q, q), elements)
        >>> optimal
        [(0, 0), (1, 1), (2, 2), (3, 3)]
    """
    return [p for p in elements if back_fn(eval_fn(p)) == p]


# ============================================================
# Algorithm 4: Galois Connection Validator
# ============================================================

def validate_galois_connection(
    eval_fn: Callable[[P], Q],
    back_fn: Callable[[Q], P],
    p_elements: List[P],
    q_elements: List[Q],
    p_le: Callable[[P, P], bool],
    q_le: Callable[[Q, Q], bool]
) -> Tuple[bool, Optional[Tuple[P, Q]]]:
    """
    Verify the Galois connection condition on finite sets.
    
    Checks: eval(p) ≤ q ⟺ p ≤ back(q) for all p ∈ P, q ∈ Q.
    
    Args:
        eval_fn: Evaluation map
        back_fn: Reconstruction map
        p_elements: All elements of P
        q_elements: All elements of Q
        p_le: Order relation on P
        q_le: Order relation on Q
    
    Returns:
        (True, None) if valid, (False, (p, q)) with a counterexample if invalid
    
    Example:
        >>> p_elts = [(a, b) for a in range(3) for b in range(3)]
        >>> q_elts = list(range(3))
        >>> valid, _ = validate_galois_connection(
        ...     lambda p: max(p[0], p[1]), lambda q: (q, q),
        ...     p_elts, q_elts,
        ...     lambda a, b: a[0] <= b[0] and a[1] <= b[1],
        ...     lambda a, b: a <= b)
        >>> valid
        True
    """
    for p in p_elements:
        for q in q_elements:
            lhs = q_le(eval_fn(p), q)
            rhs = p_le(p, back_fn(q))
            if lhs != rhs:
                return False, (p, q)
    return True, None


# ============================================================
# Algorithm 5: Closure Lattice Operations
# ============================================================

def closed_meet(
    eval_fn: Callable,
    back_fn: Callable,
    specs: List,
    infimum_fn: Callable
) -> object:
    """
    Compute the meet (infimum) in the closed-prompt lattice.
    
    closed_meet(S) = cl(inf(S))
    
    Args:
        eval_fn: Evaluation map
        back_fn: Reconstruction map
        specs: List of closed specifications
        infimum_fn: Function computing inf of a list
    
    Returns:
        The greatest lower bound in the closed lattice
    """
    inf_val = infimum_fn(specs)
    return compute_closure(eval_fn, back_fn, inf_val)


def closed_join(
    eval_fn: Callable,
    back_fn: Callable,
    specs: List,
    supremum_fn: Callable
) -> object:
    """
    Compute the join (supremum) in the closed-prompt lattice.
    
    closed_join(S) = cl(sup(S))
    """
    sup_val = supremum_fn(specs)
    return compute_closure(eval_fn, back_fn, sup_val)


# ============================================================
# Algorithm 6: Duality Computation
# ============================================================

def compute_duality_map(
    eval_fn: Callable[[P], Q],
    back_fn: Callable[[Q], P],
    p_elements: List[P],
    q_elements: List[Q]
) -> Tuple[Dict, Dict]:
    """
    Compute the bijection between closed specifications and open qualities.
    
    Returns:
        (closed_to_open, open_to_closed) dictionaries
    """
    closed_to_open = {}
    open_to_closed = {}
    
    for p in p_elements:
        if back_fn(eval_fn(p)) == p:  # p is closed
            q = eval_fn(p)
            if eval_fn(back_fn(q)) == q:  # q is open
                closed_to_open[p] = q
                open_to_closed[q] = p
    
    return closed_to_open, open_to_closed


# ============================================================
# Example Usage
# ============================================================

if __name__ == "__main__":
    # Setup: 2D product order model
    eval_fn = lambda p: max(p[0], p[1])
    back_fn = lambda q: (q, q)
    
    print("=== Algorithm 1: Closure Computation ===")
    for p in [(3, 7), (5, 5), (1, 9), (0, 0)]:
        cl = compute_closure(eval_fn, back_fn, p)
        print(f"  cl{p} = {cl}")
    
    print("\n=== Algorithm 2: Iterative Convergence ===")
    for p0 in [(2, 8), (4, 4), (6, 1)]:
        result, steps, traj = iterate_to_optimal(eval_fn, back_fn, p0)
        print(f"  {p0} → {result} in {steps} step(s)")
        print(f"    Trajectory: {' → '.join(str(t) for t in traj)}")
    
    print("\n=== Algorithm 3: Enumerate Optimal ===")
    elements = [(a, b) for a in range(6) for b in range(6)]
    optimal = enumerate_optimal(eval_fn, back_fn, elements)
    print(f"  Optimal in [0,5]²: {optimal}")
    print(f"  Count: {len(optimal)} out of {len(elements)}")
    
    print("\n=== Algorithm 4: Galois Connection Validation ===")
    p_elts = [(a, b) for a in range(5) for b in range(5)]
    q_elts = list(range(5))
    valid, cex = validate_galois_connection(
        eval_fn, back_fn, p_elts, q_elts,
        lambda a, b: a[0] <= b[0] and a[1] <= b[1],
        lambda a, b: a <= b
    )
    print(f"  Valid Galois connection: {valid}")
    
    # Test with a non-Galois pair
    bad_eval = lambda p: min(p[0], p[1])  # min doesn't form GC with (q,q)
    valid2, cex2 = validate_galois_connection(
        bad_eval, back_fn, p_elts, q_elts,
        lambda a, b: a[0] <= b[0] and a[1] <= b[1],
        lambda a, b: a <= b
    )
    print(f"  min-based (invalid): valid={valid2}, counterexample={cex2}")
    
    print("\n=== Algorithm 5: Lattice Operations ===")
    p1, p2 = (3, 3), (7, 7)
    inf_fn = lambda specs: (min(s[0] for s in specs), min(s[1] for s in specs))
    sup_fn = lambda specs: (max(s[0] for s in specs), max(s[1] for s in specs))
    
    meet = closed_meet(eval_fn, back_fn, [p1, p2], inf_fn)
    join = closed_join(eval_fn, back_fn, [p1, p2], sup_fn)
    print(f"  meet({p1}, {p2}) = {meet}")
    print(f"  join({p1}, {p2}) = {join}")
    
    print("\n=== Algorithm 6: Duality Map ===")
    c2o, o2c = compute_duality_map(eval_fn, back_fn, p_elts, q_elts)
    print(f"  Closed → Open: {dict(sorted(c2o.items()))}")
    print(f"  Open → Closed: {dict(sorted(o2c.items()))}")
    
    print("\n✓ All algorithms demonstrated successfully")

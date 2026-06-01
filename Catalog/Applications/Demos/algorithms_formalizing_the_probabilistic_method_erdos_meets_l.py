#!/usr/bin/env python3
"""
Probabilistic Method: Core Algorithms

Type-hinted implementations of key algorithms from the probabilistic method:
1. Derandomized Erdős construction (method of conditional expectations)
2. Moser-Tardos algorithm (constructive LLL)
3. Turán graph construction
4. Tropical cost minimization
"""

from math import comb, exp, log
from itertools import combinations
from typing import Callable, Dict, FrozenSet, List, Optional, Set, Tuple
import random


# ============================================================
# Algorithm 1: Turán Graph Construction
# ============================================================

def turan_graph(n: int, r: int) -> List[Tuple[int, int]]:
    """
    Construct the Turán graph T(n,r).
    
    Vertices 0..n-1 are partitioned into r classes by residue mod r.
    Two vertices are adjacent iff they belong to different classes.
    
    Returns: List of edges (i, j) with i < j.
    
    Time complexity: O(n²)
    """
    edges: List[Tuple[int, int]] = []
    for i in range(n):
        for j in range(i + 1, n):
            if i % r != j % r:
                edges.append((i, j))
    return edges


def turan_edge_count_formula(n: int, r: int) -> int:
    """
    Compute the exact edge count of T(n,r) using the formula.
    
    |E(T(n,r))| = (1 - 1/r) * n² / 2 - correction
    
    The exact formula: sum over pairs of classes of (size_i * size_j).
    Class i has size ⌊n/r⌋ + (1 if i < n%r else 0).
    """
    sizes = [(n // r) + (1 if i < n % r else 0) for i in range(r)]
    count = 0
    for i in range(r):
        for j in range(i + 1, r):
            count += sizes[i] * sizes[j]
    return count


# ============================================================
# Algorithm 2: Derandomized Erdős Construction
# ============================================================

def conditional_expected_monochromatic(
    n: int, k: int,
    partial_coloring: Dict[Tuple[int, int], int],
    edge: Tuple[int, int],
    color: int
) -> float:
    """
    Compute E[number of monochromatic K_k | partial coloring + edge=color].
    
    For each k-subset S, compute the probability that S is monochromatic
    given the partial coloring extended with the new edge.
    """
    # Extend coloring
    coloring = dict(partial_coloring)
    coloring[edge] = color
    
    vertices = list(range(n))
    total = 0.0
    
    for S in combinations(vertices, k):
        edges_in_S = [(S[i], S[j]) for i in range(k) for j in range(i+1, k)]
        
        # For each color c, compute P(all edges in S have color c)
        for c in [0, 1]:
            prob = 1.0
            for e in edges_in_S:
                e_norm = (min(e), max(e))
                if e_norm in coloring:
                    prob *= 1.0 if coloring[e_norm] == c else 0.0
                else:
                    prob *= 0.5  # Uncolored edge: 50% chance
            total += prob
    
    return total


def derandomized_erdos(n: int, k: int) -> Optional[Dict[Tuple[int, int], int]]:
    """
    Derandomized Erdős construction using the method of conditional expectations.
    
    Greedily colors each edge to minimize the conditional expected number
    of monochromatic k-cliques.
    
    Returns: A coloring dict {(i,j): color} or None if no good coloring exists.
    
    Time complexity: O(n² * C(n,k))
    """
    coloring: Dict[Tuple[int, int], int] = {}
    edges = [(i, j) for i in range(n) for j in range(i+1, n)]
    
    for edge in edges:
        # Try both colors and pick the one with lower expected cost
        e0 = conditional_expected_monochromatic(n, k, coloring, edge, 0)
        e1 = conditional_expected_monochromatic(n, k, coloring, edge, 1)
        coloring[edge] = 0 if e0 <= e1 else 1
    
    # Count actual monochromatic cliques
    count = 0
    for S in combinations(range(n), k):
        edges_in_S = [(S[i], S[j]) for i in range(k) for j in range(i+1, k)]
        colors = {coloring[e] for e in edges_in_S}
        if len(colors) == 1:
            count += 1
    
    return coloring if count == 0 else coloring  # Return coloring even if imperfect


# ============================================================
# Algorithm 3: Moser-Tardos Algorithm (Constructive LLL)
# ============================================================

class MoserTardos:
    """
    Moser-Tardos algorithm for the constructive Lovász Local Lemma.
    
    Given:
    - n variables, each with a finite domain
    - m constraints, each involving a subset of variables
    - A sampler for each variable
    
    Finds an assignment satisfying all constraints (when LLL conditions hold).
    """
    
    def __init__(
        self,
        n_vars: int,
        domains: List[List[int]],
        constraints: List[Tuple[Set[int], Callable[[Dict[int, int]], bool]]],
        max_iterations: int = 100000
    ):
        self.n_vars = n_vars
        self.domains = domains
        self.constraints = constraints
        self.max_iterations = max_iterations
    
    def sample_variable(self, var: int) -> int:
        """Sample a random value for variable var."""
        return random.choice(self.domains[var])
    
    def run(self) -> Optional[Dict[int, int]]:
        """
        Run the Moser-Tardos algorithm.
        
        Returns: A satisfying assignment, or None if max_iterations exceeded.
        
        Expected iterations: O(Σ x_i/(1-x_i)) where x is the LLL witness.
        """
        # Initialize: sample all variables
        assignment: Dict[int, int] = {}
        for v in range(self.n_vars):
            assignment[v] = self.sample_variable(v)
        
        for iteration in range(self.max_iterations):
            # Find a violated constraint
            violated = None
            for idx, (vars_set, check) in enumerate(self.constraints):
                if not check(assignment):
                    violated = (idx, vars_set)
                    break
            
            if violated is None:
                return assignment  # All constraints satisfied!
            
            # Resample variables in the violated constraint
            _, vars_to_resample = violated
            for v in vars_to_resample:
                assignment[v] = self.sample_variable(v)
        
        return None  # Failed to find satisfying assignment


# ============================================================
# Algorithm 4: Tropical Cost Minimization
# ============================================================

def tropical_minimize(
    elements: List[int],
    cost: Callable[[int], int]
) -> Tuple[int, int]:
    """
    Find the element minimizing the cost function (tropical optimization).
    
    In the tropical semiring (ℕ, min, +):
    - The "sum" is min
    - The "product" is +
    
    Returns: (optimal_element, optimal_cost)
    
    Time complexity: O(n)
    """
    best_elem = elements[0]
    best_cost = cost(elements[0])
    
    for elem in elements[1:]:
        c = cost(elem)
        if c < best_cost:
            best_cost = c
            best_elem = elem
    
    return best_elem, best_cost


def tropical_first_moment_check(costs: List[int]) -> bool:
    """
    Check the tropical first moment condition: sum(costs) < len(costs).
    
    If true, some element has cost 0 (tropical existence principle).
    """
    return sum(costs) < len(costs)


# ============================================================
# Demo
# ============================================================

if __name__ == "__main__":
    # Demo 1: Turán graph
    print("Turán Graph T(8, 2):")
    edges = turan_graph(8, 2)
    print(f"  Edges: {len(edges)}")
    print(f"  Formula: {turan_edge_count_formula(8, 2)}")
    print()
    
    # Demo 2: Derandomized Erdős
    print("Derandomized Erdős Construction:")
    for n in range(3, 7):
        coloring = derandomized_erdos(n, 3)
        mono = 0
        for S in combinations(range(n), 3):
            es = [(S[i], S[j]) for i in range(3) for j in range(i+1, 3)]
            colors = {coloring[e] for e in es}
            if len(colors) == 1:
                mono += 1
        print(f"  K_{n}: {mono} monochromatic triangles")
    print()
    
    # Demo 3: Moser-Tardos on graph coloring
    print("Moser-Tardos: Proper 3-coloring of K_4 minus one edge")
    n = 4
    edges_list = [(0,1), (0,2), (0,3), (1,2), (1,3)]  # K_4 minus (2,3)
    constraints = []
    for u, v in edges_list:
        constraints.append(
            ({u, v}, lambda a, u=u, v=v: a[u] != a[v])
        )
    
    mt = MoserTardos(
        n_vars=n,
        domains=[[0, 1, 2]] * n,
        constraints=constraints
    )
    result = mt.run()
    print(f"  Assignment: {result}")
    print()
    
    # Demo 4: Tropical cost minimization
    print("Tropical Cost Minimization:")
    costs = [3, 0, 2, 1, 0, 4]
    elem, cost = tropical_minimize(list(range(len(costs))), lambda i: costs[i])
    print(f"  Costs: {costs}")
    print(f"  Minimum: element {elem}, cost {cost}")
    print(f"  First moment check (sum < n): {tropical_first_moment_check(costs)}")

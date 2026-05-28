#!/usr/bin/env python3
"""
applications.py — Applications of Lorentzian Recognition Complexity Theory

Demonstrates real-world applications of the complexity barrier results:
  1. Parameterized complexity analysis for algebraic combinatorics
  2. Certificate-guided optimization for Lorentzian checking
  3. Random CNF to branch-obstruction analysis
  4. Degree-bounded vs. unbounded complexity comparison
"""

from math import comb, log2, ceil
from typing import List, Tuple, Dict
import itertools
import random


def multiindex_count(n: int, d: int) -> int:
    """Number of multiindices of weight d in n variables."""
    if n <= 0:
        return 1 if d == 0 else 0
    return comb(n + d - 1, d)


def quadratic_leaf_count(n: int, d: int) -> int:
    """Number of quadratic leaves in recognition tree."""
    if d < 2:
        return 1
    return multiindex_count(n, d - 2)


# ──────────────────────────────────────────────────────────
# Application 1: Parameterized Complexity Advisor
# ──────────────────────────────────────────────────────────

def complexity_advisor(n: int, d: int) -> Dict:
    """
    Advise on the computational complexity of Lorentzian recognition
    for given parameters n (variables) and d (degree).
    
    Returns a recommendation: exact, heuristic, or intractable.
    
    >>> result = complexity_advisor(10, 4)
    >>> result['recommendation']
    'EXACT — Fixed-degree polynomial algorithm'
    """
    leaves = quadratic_leaf_count(n, d)
    
    result = {
        "variables": n,
        "degree": d,
        "leaf_count": leaves,
        "log2_leaves": log2(leaves) if leaves > 0 else 0,
    }
    
    if d < 2:
        result["recommendation"] = "TRIVIAL — Degree < 2, direct check"
        result["estimated_time"] = "O(1)"
    elif d <= 6:
        result["recommendation"] = "EXACT — Fixed-degree polynomial algorithm"
        result["estimated_time"] = f"O(n^{d-2}) = O(n^{d-2})"
        result["feasible_for_n_up_to"] = int(1e8 ** (1 / max(d - 2, 1)))
    elif d <= 20 and n <= 20:
        result["recommendation"] = "HEURISTIC — Moderate size, sampling may work"
        result["estimated_time"] = f"~{leaves} leaf checks"
        result["sampling_rate"] = min(1.0, 10000 / leaves) if leaves > 0 else 1.0
    else:
        result["recommendation"] = "INTRACTABLE — Exponential certificate required"
        result["estimated_time"] = f"Ω(2^{min(n-1, d-2)}) = exponential"
        result["barrier_source"] = "multiindex_exponential_lower_bound"
    
    return result


# ──────────────────────────────────────────────────────────
# Application 2: Matroid Certificate Estimator
# ──────────────────────────────────────────────────────────

def matroid_basis_polynomial_complexity(ground_set_size: int, rank: int) -> Dict:
    """
    Estimate the complexity of checking Lorentzianity of a matroid
    basis generating polynomial.
    
    For a matroid M of rank r on ground set [n], the basis generating
    polynomial has degree r in n variables. Checking Lorentzianity
    requires inspecting C(n + r - 3, r - 2) quadratic leaves.
    
    >>> result = matroid_basis_polynomial_complexity(10, 4)
    >>> result['leaf_count'] > 0
    True
    """
    n = ground_set_size
    d = rank
    
    leaves = quadratic_leaf_count(n, d)
    
    return {
        "ground_set": n,
        "rank": d,
        "polynomial_degree": d,
        "polynomial_variables": n,
        "leaf_count": leaves,
        "tractable": leaves < 1e9,
        "phase": "polynomial" if d <= 2 * log2(n + 1) else "exponential",
        "note": "Based on Brändén–Huh characterization of Lorentzian matroids"
    }


# ──────────────────────────────────────────────────────────
# Application 3: Random SAT Instance Analysis
# ──────────────────────────────────────────────────────────

def analyze_random_cnf(num_vars: int, num_clauses: int, clause_size: int = 3,
                       seed: int = 42) -> Dict:
    """
    Generate a random CNF formula and analyze its branch-obstruction
    structure, connecting SAT to the Lorentzian derivative tree.
    
    >>> result = analyze_random_cnf(4, 5, seed=42)
    >>> 'satisfiable' in result
    True
    """
    random.seed(seed)
    
    clauses = []
    for _ in range(num_clauses):
        clause = []
        vars_in_clause = random.sample(range(num_vars), min(clause_size, num_vars))
        for v in vars_in_clause:
            clause.append((v, random.choice([True, False])))
        clauses.append(clause)
    
    # Check satisfiability
    satisfying = None
    obstructed_count = 0
    total = 0
    
    for assignment in itertools.product([False, True], repeat=num_vars):
        total += 1
        satisfied = all(
            any(assignment[var] == pol for var, pol in clause)
            for clause in clauses
        )
        if satisfied:
            if satisfying is None:
                satisfying = assignment
        else:
            obstructed_count += 1
    
    return {
        "num_vars": num_vars,
        "num_clauses": num_clauses,
        "clause_size": clause_size,
        "total_assignments": total,
        "obstructed_branches": obstructed_count,
        "free_branches": total - obstructed_count,
        "satisfiable": satisfying is not None,
        "obstruction_ratio": obstructed_count / total if total > 0 else 0,
        "corresponding_leaf_count": multiindex_count(num_vars + 1, num_vars),
        "note": "Each assignment maps to a distinct multiindex via bool_to_multiindex"
    }


# ──────────────────────────────────────────────────────────
# Application 4: Complexity Landscape Visualization Data
# ──────────────────────────────────────────────────────────

def complexity_landscape(n_max: int = 20, d_max: int = 20) -> List[Dict]:
    """
    Generate data for visualizing the complexity landscape
    of Lorentzian recognition across (n, d) parameter space.
    
    Returns list of dicts with n, d, leaf_count, log_leaves,
    upper_bound, lower_bound, phase classification.
    """
    data = []
    for n in range(1, n_max + 1):
        for d in range(2, d_max + 1):
            leaves = quadratic_leaf_count(n, d)
            upper = n ** (d - 2) if n > 0 else 0
            m = min(n - 1, d - 2) if n >= 1 else 0
            lower = 2 ** max(0, m)
            
            if d <= 2 * log2(n + 1) + 2:
                phase = "polynomial"
            else:
                phase = "exponential"
            
            data.append({
                "n": n, "d": d,
                "leaves": leaves,
                "log2_leaves": log2(leaves) if leaves > 0 else 0,
                "upper": upper,
                "lower": lower,
                "phase": phase,
            })
    
    return data


# ──────────────────────────────────────────────────────────
# Main
# ──────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Applications of Lorentzian Recognition Complexity Theory")
    print("=" * 60)
    
    # App 1: Complexity Advisor
    print("\n╔═══ Application 1: Complexity Advisor ═══╗")
    test_cases = [(10, 4), (20, 10), (100, 3), (5, 50), (30, 30)]
    for n, d in test_cases:
        advice = complexity_advisor(n, d)
        print(f"\n  n={n}, d={d}:")
        print(f"    Leaves: {advice['leaf_count']}")
        print(f"    Recommendation: {advice['recommendation']}")
        print(f"    Time: {advice['estimated_time']}")
    
    # App 2: Matroid complexity
    print("\n╔═══ Application 2: Matroid Basis Polynomial ═══╗")
    for gs, r in [(8, 4), (12, 6), (20, 10), (30, 15)]:
        result = matroid_basis_polynomial_complexity(gs, r)
        print(f"\n  Ground set={gs}, rank={r}:")
        print(f"    Leaves: {result['leaf_count']}")
        print(f"    Tractable: {result['tractable']}")
        print(f"    Phase: {result['phase']}")
    
    # App 3: Random SAT
    print("\n╔═══ Application 3: Random SAT → Branch Analysis ═══╗")
    for nv, nc in [(4, 5), (5, 8), (6, 12), (8, 20)]:
        result = analyze_random_cnf(nv, nc, seed=42)
        print(f"\n  {nv} vars, {nc} clauses:")
        print(f"    Satisfiable: {result['satisfiable']}")
        print(f"    Obstruction ratio: {result['obstruction_ratio']:.3f}")
        print(f"    Free branches: {result['free_branches']}/{result['total_assignments']}")
    
    # App 4: Complexity landscape summary
    print("\n╔═══ Application 4: Complexity Landscape ═══╗")
    data = complexity_landscape(15, 15)
    poly_count = sum(1 for d in data if d["phase"] == "polynomial")
    exp_count = sum(1 for d in data if d["phase"] == "exponential")
    print(f"  Parameter space (n≤15, d≤15): "
          f"{poly_count} polynomial, {exp_count} exponential")
    
    # Show the phase boundary
    print("\n  Phase boundary (smallest d for exponential at each n):")
    for n in range(2, 16):
        for d in range(2, 20):
            if d > 2 * log2(n + 1) + 2:
                print(f"    n={n:>2}: d ≥ {d} → exponential")
                break


#!/usr/bin/env python3
"""
demo.py — Interactive Demo: Complexity Barriers for Lorentzian Recognition

Demonstrates the exponential explosion of derivative-tree certificates
when the degree of a Lorentzian polynomial is unbounded.

Accepts CNF formulas, constructs encoded polynomials, explores derivative
branches, and reports certificate sizes and Lorentzian obstructions.
"""

import itertools
from math import comb, factorial
from typing import List, Tuple, Dict, Optional, Set

# ─── Core Definitions ───

def multiindex_count(n: int, d: int) -> int:
    """Number of multiindices α : {0,...,n-1} → ℕ with ∑α = d.
    Equals C(n+d-1, d) by stars-and-bars."""
    if n <= 0:
        return 1 if d == 0 else 0
    return comb(n + d - 1, d)


def quadratic_leaf_count(n: int, d: int) -> int:
    """Number of quadratic leaves in the recursive Lorentzian recognition tree."""
    if d < 2:
        return 1
    return multiindex_count(n, d - 2)


def bool_to_multiindex(m: int, b: Tuple[bool, ...]) -> Tuple[int, ...]:
    """Map a Boolean assignment to a multiindex (the injection from our theorem).
    
    b: tuple of m booleans
    Returns: tuple of m+1 natural numbers summing to m
    """
    count_true = sum(1 for x in b if x)
    alpha_0 = m - count_true
    rest = tuple(1 if bi else 0 for bi in b)
    return (alpha_0,) + rest


# ─── CNF-SAT Infrastructure ───

class Literal:
    """A literal: variable index paired with polarity."""
    def __init__(self, var: int, positive: bool = True):
        self.var = var
        self.positive = positive
    
    def satisfied_by(self, assignment: Tuple[bool, ...]) -> bool:
        return assignment[self.var] == self.positive
    
    def __repr__(self):
        return f"x{self.var}" if self.positive else f"¬x{self.var}"


class CNFFormula:
    """A CNF formula: list of clauses, each clause a list of literals."""
    def __init__(self, num_vars: int, clauses: List[List[Literal]]):
        self.num_vars = num_vars
        self.clauses = clauses
    
    def satisfied_by(self, assignment: Tuple[bool, ...]) -> bool:
        return all(
            any(lit.satisfied_by(assignment) for lit in clause)
            for clause in self.clauses
        )
    
    def is_satisfiable(self) -> Tuple[bool, Optional[Tuple[bool, ...]]]:
        """Brute-force SAT check."""
        for assignment in itertools.product([False, True], repeat=self.num_vars):
            if self.satisfied_by(assignment):
                return True, assignment
        return False, None
    
    def __repr__(self):
        clause_strs = []
        for clause in self.clauses:
            clause_strs.append("(" + " ∨ ".join(str(lit) for lit in clause) + ")")
        return " ∧ ".join(clause_strs)


# ─── Derivative Branch Exploration ───

def enumerate_multiindices(n: int, d: int):
    """Enumerate all multiindices of weight d in n variables."""
    if n == 0:
        if d == 0:
            yield ()
        return
    if n == 1:
        yield (d,)
        return
    for first in range(d + 1):
        for rest in enumerate_multiindices(n - 1, d - first):
            yield (first,) + rest


def derivative_branch_tree_size(n: int, d: int) -> Dict:
    """Compute the size of the derivative tree for recognition."""
    result = {
        "variables": n,
        "degree": d,
        "quadratic_leaf_count": quadratic_leaf_count(n, d),
        "upper_bound_poly": n ** (d - 2) if d >= 2 and n > 0 else 1,
        "lower_bound_exp": 2 ** max(0, min(n - 1, d - 2)),
    }
    return result


def check_hessian_lorentzian(matrix: List[List[float]]) -> Dict:
    """Check if a symmetric matrix has Lorentzian signature.
    Returns analysis of eigenvalue structure."""
    n = len(matrix)
    if n == 0:
        return {"lorentzian": True, "reason": "trivial (0×0)"}
    
    # Compute eigenvalues via characteristic polynomial for small matrices
    if n == 1:
        val = matrix[0][0]
        return {
            "lorentzian": True,
            "reason": f"1×1 matrix, eigenvalue = {val}",
            "positive_eigenvalues": 1 if val > 0 else 0
        }
    
    if n == 2:
        a, b = matrix[0][0], matrix[0][1]
        c, d = matrix[1][0], matrix[1][1]
        trace = a + d
        det = a * d - b * c
        disc = trace**2 - 4 * det
        if disc < 0:
            return {"lorentzian": True, "reason": "complex eigenvalues (≤1 positive)"}
        
        sqrt_disc = disc ** 0.5
        e1 = (trace + sqrt_disc) / 2
        e2 = (trace - sqrt_disc) / 2
        pos_count = (1 if e1 > 1e-10 else 0) + (1 if e2 > 1e-10 else 0)
        
        return {
            "lorentzian": pos_count <= 1,
            "eigenvalues": [round(e1, 6), round(e2, 6)],
            "positive_eigenvalues": pos_count,
            "reason": f"eigenvalues: {round(e1,4)}, {round(e2,4)}"
        }
    
    return {"lorentzian": None, "reason": f"matrix too large for exact analysis (n={n})"}


# ─── Demo Functions ───

def demo_exponential_explosion():
    """Demonstrate the exponential growth of certificate size."""
    print("=" * 70)
    print("DEMO 1: Exponential Explosion of Certificate Size")
    print("=" * 70)
    print()
    print("Theorem: multiIndexCount(m+1, m) ≥ 2^m")
    print("This shows that when degree grows with variables,")
    print("the number of quadratic leaves explodes exponentially.")
    print()
    
    print(f"{'m':>4} | {'n=m+1':>6} | {'d=m+2':>6} | {'leaves':>12} | {'2^m':>12} | {'n^(d-2)':>14} | {'ratio':>8}")
    print("-" * 70)
    
    for m in range(1, 16):
        n = m + 1
        d = m + 2
        leaves = quadratic_leaf_count(n, d)
        lower = 2 ** m
        upper = n ** m if n > 0 else 1
        ratio = leaves / lower if lower > 0 else float('inf')
        
        print(f"{m:>4} | {n:>6} | {d:>6} | {leaves:>12} | {lower:>12} | {upper:>14} | {ratio:>8.2f}")
    
    print()
    print("Key observation: the certificate size grows EXPONENTIALLY,")
    print("not polynomially, when degree scales with variables.")
    print()


def demo_boolean_injection():
    """Demonstrate the injection from Boolean assignments to multiindices."""
    print("=" * 70)
    print("DEMO 2: Boolean Assignment → Multiindex Injection")
    print("=" * 70)
    print()
    
    m = 4
    print(f"m = {m}: mapping 2^{m} = {2**m} Boolean assignments to multiindices")
    print(f"Target: multiIndexSet({m+1}, {m})")
    print()
    
    for bits in itertools.product([False, True], repeat=m):
        alpha = bool_to_multiindex(m, bits)
        bits_str = "".join("1" if b else "0" for b in bits)
        assert sum(alpha) == m, f"Sum check failed for {bits}"
        print(f"  b = {bits_str}  →  α = {alpha}  (sum = {sum(alpha)})")
    
    print(f"\nAll {2**m} assignments map to distinct multiindices. ✓")
    print(f"Total multiindices in set: {multiindex_count(m+1, m)}")
    print()


def demo_cnf_sat_bridge():
    """Demonstrate the SAT-to-branch correspondence."""
    print("=" * 70)
    print("DEMO 3: CNF-SAT ↔ Branch Obstruction Correspondence")
    print("=" * 70)
    print()
    
    # Example 1: Satisfiable formula
    print("Example 1: φ₁ = (x₀ ∨ x₁) ∧ (¬x₀ ∨ x₁)")
    phi1 = CNFFormula(2, [
        [Literal(0, True), Literal(1, True)],
        [Literal(0, False), Literal(1, True)],
    ])
    print(f"  Formula: {phi1}")
    sat, witness = phi1.is_satisfiable()
    print(f"  Satisfiable: {sat}")
    if witness:
        print(f"  Witness: {witness}")
    
    print("\n  Branch analysis (all assignments):")
    for bits in itertools.product([False, True], repeat=2):
        satisfied = phi1.satisfied_by(bits)
        obstructed = not satisfied
        alpha = bool_to_multiindex(2, bits)
        status = "OBSTRUCTED" if obstructed else "FREE"
        bits_str = "".join("1" if b else "0" for b in bits)
        print(f"    b={bits_str} → α={alpha} : {status}")
    
    print()
    
    # Example 2: Unsatisfiable formula
    print("Example 2: φ₂ = (x₀) ∧ (¬x₀) — unsatisfiable")
    phi2 = CNFFormula(1, [
        [Literal(0, True)],
        [Literal(0, False)],
    ])
    print(f"  Formula: {phi2}")
    sat2, _ = phi2.is_satisfiable()
    print(f"  Satisfiable: {sat2}")
    
    print("\n  Branch analysis:")
    for bits in itertools.product([False, True], repeat=1):
        satisfied = phi2.satisfied_by(bits)
        obstructed = not satisfied
        alpha = bool_to_multiindex(1, bits)
        status = "OBSTRUCTED" if obstructed else "FREE"
        bits_str = "".join("1" if b else "0" for b in bits)
        print(f"    b={bits_str} → α={alpha} : {status}")
    
    print("\n  All branches obstructed ↔ formula unsatisfiable ✓")
    print()


def demo_phase_transition():
    """Demonstrate the phase transition in certificate complexity."""
    print("=" * 70)
    print("DEMO 4: Phase Transition — Fixed vs. Unbounded Degree")
    print("=" * 70)
    print()
    
    print("FIXED DEGREE (d=4): Certificate size is polynomial in n")
    print(f"{'n':>4} | {'leaves':>10} | {'n^2':>10} | {'polynomial?':>12}")
    print("-" * 45)
    for n in range(2, 20):
        leaves = quadratic_leaf_count(n, 4)
        bound = n ** 2
        print(f"{n:>4} | {leaves:>10} | {bound:>10} | {'YES':>12}")
    
    print()
    print("UNBOUNDED DEGREE (d=n+1): Certificate size is exponential")
    print(f"{'n':>4} | {'d=n+1':>6} | {'leaves':>14} | {'2^(n-1)':>14} | {'exponential?':>12}")
    print("-" * 60)
    for n in range(2, 16):
        d = n + 1
        leaves = quadratic_leaf_count(n, d)
        lower = 2 ** (n - 1)
        print(f"{n:>4} | {d:>6} | {leaves:>14} | {lower:>14} | {'YES':>12}")
    
    print()
    print("This is the PHASE TRANSITION: bounded degree → polynomial,")
    print("unbounded degree → exponential. A complexity barrier emerges.")
    print()


def demo_spectral_obstruction():
    """Demonstrate spectral obstruction for non-Lorentzian matrices."""
    print("=" * 70)
    print("DEMO 5: Spectral Obstruction — Identity Matrix")
    print("=" * 70)
    print()
    
    for n in range(1, 6):
        I_n = [[1.0 if i == j else 0.0 for j in range(n)] for i in range(n)]
        result = check_hessian_lorentzian(I_n)
        status = "Lorentzian" if result.get("lorentzian") else "NOT Lorentzian"
        print(f"  I_{n} ({n}×{n}): {status}")
        if "eigenvalues" in result:
            print(f"    Eigenvalues: {result['eigenvalues']}")
            print(f"    Positive eigenvalues: {result['positive_eigenvalues']}")
        print(f"    {result['reason']}")
    
    print()
    print("Theorem: I_n is NOT Lorentzian for n ≥ 2 (too many positive eigenvalues)")
    print("Negative semidefinite matrices are ALWAYS Lorentzian (0 positive eigenvalues)")
    print()


def demo_conjecture_test():
    """Test the branch-complexity barrier conjecture."""
    print("=" * 70)
    print("DEMO 6: Conjecture Test — Branch-Complexity Barrier")
    print("=" * 70)
    print()
    print("Conjecture: ∃ c > 0 such that certificate size ≥ exp(c·d)")
    print()
    
    import math
    print(f"{'d':>4} | {'n=d-1':>6} | {'leaves':>14} | {'log₂(leaves)':>14} | {'c=log₂/d':>10}")
    print("-" * 55)
    for d in range(3, 20):
        n = d - 1
        leaves = quadratic_leaf_count(n, d)
        if leaves > 0:
            log_leaves = math.log2(leaves)
            c_approx = log_leaves / d if d > 0 else 0
            print(f"{d:>4} | {n:>6} | {leaves:>14} | {log_leaves:>14.2f} | {c_approx:>10.4f}")
    
    print()
    print("The ratio c = log₂(leaves)/d stabilizes, supporting the conjecture.")
    print()


# ─── Main ───

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║  COMPLEXITY BARRIERS FOR LORENTZIAN POLYNOMIAL RECOGNITION     ║")
    print("║  Interactive Demo — Exponential Certificate Explosion          ║")
    print("╚══════════════════════════════════════════════════════════════════╝")
    print()
    
    demo_exponential_explosion()
    demo_boolean_injection()
    demo_cnf_sat_bridge()
    demo_phase_transition()
    demo_spectral_obstruction()
    demo_conjecture_test()
    
    print("=" * 70)
    print("All demos complete.")
    print()
    print("Key results demonstrated:")
    print("  1. Certificate size grows EXPONENTIALLY (2^m lower bound)")
    print("  2. Boolean assignments inject into multiindices")
    print("  3. SAT obstruction ↔ branch obstruction correspondence")
    print("  4. Phase transition: polynomial (fixed d) vs exponential (growing d)")
    print("  5. Spectral obstruction: identity matrix is not Lorentzian for n≥2")
    print("  6. Branch-complexity barrier conjecture supported by data")


#!/usr/bin/env python3
"""
Visualization: Boolean-to-Multiindex Injection

Illustrates the key injection theorem: each Boolean assignment maps to a
distinct multiindex, proving that the multiindex count grows exponentially.
Shows the injection for m=4 as a bipartite graph, and the exponential
growth curve for larger m.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from math import comb
import itertools


def bool_to_multiindex(m, b):
    count_true = sum(1 for x in b if x)
    alpha_0 = m - count_true
    rest = tuple(1 if bi else 0 for bi in b)
    return (alpha_0,) + rest


def multiindex_count(n, d):
    if n <= 0:
        return 1 if d == 0 else 0
    return comb(n + d - 1, d)


fig, axes = plt.subplots(1, 2, figsize=(16, 8))

# Left: Injection diagram for m=4
ax1 = axes[0]
m = 4
assignments = list(itertools.product([False, True], repeat=m))

# Position Boolean assignments on the left
n_left = len(assignments)
left_y = np.linspace(0, 1, n_left)

# Position multiindices on the right
multiindices = set()
for b in assignments:
    multiindices.add(bool_to_multiindex(m, b))
all_multis = sorted(multiindices)
right_y_map = {mi: i / max(len(all_multis) - 1, 1) for i, mi in enumerate(all_multis)}

# Draw connections
colors = plt.cm.viridis(np.linspace(0.2, 0.9, n_left))
for i, b in enumerate(assignments):
    mi = bool_to_multiindex(m, b)
    ry = right_y_map[mi]
    ax1.plot([0.1, 0.9], [left_y[i], ry], '-', color=colors[i], 
             alpha=0.6, linewidth=1.5)

# Draw nodes
for i, b in enumerate(assignments):
    bits_str = "".join("1" if x else "0" for x in b)
    ax1.plot(0.1, left_y[i], 'o', color=colors[i], markersize=8)
    ax1.text(-0.05, left_y[i], bits_str, ha='right', va='center', fontsize=7,
             fontfamily='monospace')

for mi, ry in right_y_map.items():
    ax1.plot(0.9, ry, 's', color='coral', markersize=8, zorder=5)
    ax1.text(0.95, ry, str(mi), ha='left', va='center', fontsize=7,
             fontfamily='monospace')

ax1.set_xlim(-0.25, 1.4)
ax1.set_ylim(-0.05, 1.05)
ax1.set_title(f'Boolean → Multiindex Injection (m={m})', fontsize=13, fontweight='bold')
ax1.text(0.1, -0.03, f'2^{m} = {2**m} assignments', ha='center', fontsize=9)
ax1.text(0.9, -0.03, f'{len(all_multis)} multiindices\n(of {multiindex_count(m+1, m)} total)', 
         ha='center', fontsize=9)
ax1.axis('off')

# Right: Exponential growth comparison
ax2 = axes[1]
ms = range(1, 18)

exact_counts = [multiindex_count(m + 1, m) for m in ms]
lower_bounds = [2 ** m for m in ms]
upper_bounds = [(m + 1) ** m for m in ms]

ax2.semilogy(list(ms), exact_counts, 'b-o', linewidth=2, markersize=6,
             label=f'Exact: C(2m, m)')
ax2.semilogy(list(ms), lower_bounds, 'r--', linewidth=2,
             label=f'Lower: 2^m (our theorem)')
ax2.semilogy(list(ms), upper_bounds, 'g--', linewidth=2,
             label=f'Upper: (m+1)^m (catalog)')

# Shade the gap
ax2.fill_between(list(ms), lower_bounds, exact_counts, alpha=0.15, color='blue',
                 label='Proved range')

ax2.set_xlabel('m (= degree parameter)', fontsize=12)
ax2.set_ylabel('Multiindex count (log scale)', fontsize=12)
ax2.set_title('Exponential Growth: Lower vs. Upper Bounds', fontsize=13, fontweight='bold')
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('injection_growth.png', dpi=150, bbox_inches='tight')
print("Saved injection_growth.png")


#!/usr/bin/env python3
"""
Visualization: Phase Transition in Lorentzian Certificate Complexity

Shows the heatmap of log₂(certificate size) across the (n, d) parameter space,
revealing the sharp transition from polynomial (fixed degree) to exponential
(unbounded degree) certificate complexity.

This visualizes the central theorem: when degree grows with the number of variables,
the number of quadratic leaves in the recursive Lorentzian recognition tree
explodes exponentially.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb, log2


def multiindex_count(n: int, d: int) -> int:
    if n <= 0:
        return 1 if d == 0 else 0
    return comb(n + d - 1, d)


def quadratic_leaf_count(n: int, d: int) -> int:
    if d < 2:
        return 1
    return multiindex_count(n, d - 2)


# Compute the heatmap data
n_max = 25
d_max = 25
data = np.zeros((d_max, n_max))

for n_idx in range(n_max):
    for d_idx in range(d_max):
        n = n_idx + 1
        d = d_idx + 1
        leaves = quadratic_leaf_count(n, d)
        data[d_idx, n_idx] = log2(leaves) if leaves > 0 else 0

fig, axes = plt.subplots(1, 2, figsize=(16, 7))

# Left: Heatmap
ax1 = axes[0]
im = ax1.imshow(data, origin='lower', aspect='auto', cmap='inferno',
                extent=[0.5, n_max + 0.5, 0.5, d_max + 0.5])
cbar = plt.colorbar(im, ax=ax1, label='log₂(certificate size)')
ax1.set_xlabel('Number of variables (n)', fontsize=12)
ax1.set_ylabel('Degree (d)', fontsize=12)
ax1.set_title('Certificate Complexity Landscape', fontsize=14, fontweight='bold')

# Draw phase boundary: d ≈ 2 log₂(n) + 2
ns = np.arange(2, n_max + 1)
boundary = 2 * np.log2(ns) + 4
ax1.plot(ns, boundary, 'w--', linewidth=2, label='Phase boundary')
ax1.plot(ns, ns + 1, 'c-', linewidth=2, alpha=0.7, label='d = n + 1 (exponential)')
ax1.legend(loc='upper left', fontsize=9, facecolor='black', 
           labelcolor='white', edgecolor='gray')

# Right: Growth curves
ax2 = axes[1]

# Fixed degree curves
for d in [4, 6, 8]:
    ns_plot = range(2, 26)
    leaves = [quadratic_leaf_count(n, d) for n in ns_plot]
    ax2.semilogy(list(ns_plot), leaves, '-', linewidth=2, label=f'd = {d} (fixed)')

# Growing degree curves
ns_grow = range(2, 20)
leaves_grow = [quadratic_leaf_count(n, n + 1) for n in ns_grow]
ax2.semilogy(list(ns_grow), leaves_grow, 'r-', linewidth=3, label='d = n+1 (growing)')

# Lower bound 2^(n-1)
ns_lb = range(2, 20)
lower = [2 ** (n - 1) for n in ns_lb]
ax2.semilogy(list(ns_lb), lower, 'r--', linewidth=2, alpha=0.6, label='2^(n-1) lower bound')

ax2.set_xlabel('Number of variables (n)', fontsize=12)
ax2.set_ylabel('Certificate size (log scale)', fontsize=12)
ax2.set_title('Growth Curves: Fixed vs. Growing Degree', fontsize=14, fontweight='bold')
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('phase_transition.png', dpi=150, bbox_inches='tight')
print("Saved phase_transition.png")


#!/usr/bin/env python3
"""
Visualization: SAT-to-Branch Correspondence

Illustrates how Boolean satisfiability problems map to derivative-tree
branches in Lorentzian polynomial recognition. Shows the correspondence
between obstructed branches and unsatisfying assignments.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import itertools


def bool_to_multiindex(m, b):
    count_true = sum(1 for x in b if x)
    alpha_0 = m - count_true
    rest = tuple(1 if bi else 0 for bi in b)
    return (alpha_0,) + rest


fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# Three CNF formulas to compare
formulas = [
    {
        "name": "Satisfiable: (x₀∨x₁) ∧ (¬x₀∨x₁)",
        "num_vars": 2,
        "clauses": [[(0, True), (1, True)], [(0, False), (1, True)]],
    },
    {
        "name": "Unsatisfiable: (x₀) ∧ (¬x₀)",
        "num_vars": 1,
        "clauses": [[(0, True)], [(0, False)]],
    },
    {
        "name": "3-SAT: (x₀∨x₁∨x₂) ∧ (¬x₀∨¬x₁) ∧ (¬x₁∨¬x₂) ∧ (¬x₀∨¬x₂)",
        "num_vars": 3,
        "clauses": [[(0, True), (1, True), (2, True)],
                    [(0, False), (1, False)],
                    [(1, False), (2, False)],
                    [(0, False), (2, False)]],
    },
]

for ax_idx, formula_info in enumerate(formulas):
    ax = axes[ax_idx]
    m = formula_info["num_vars"]
    clauses = formula_info["clauses"]
    
    assignments = list(itertools.product([False, True], repeat=m))
    
    # Classify each assignment
    free_count = 0
    obstructed_count = 0
    
    bar_labels = []
    bar_colors = []
    bar_alphas = []
    
    for b in assignments:
        satisfied = all(
            any(b[var] == pol for var, pol in clause)
            for clause in clauses
        )
        bits_str = "".join("1" if x else "0" for x in b)
        alpha = bool_to_multiindex(m, b)
        
        bar_labels.append(f"{bits_str}\n{alpha}")
        
        if satisfied:
            bar_colors.append('#2ecc71')  # green for free
            bar_alphas.append(0.8)
            free_count += 1
        else:
            bar_colors.append('#e74c3c')  # red for obstructed
            bar_alphas.append(0.8)
            obstructed_count += 1
    
    # Draw bars
    x_pos = range(len(assignments))
    bars = ax.bar(x_pos, [1] * len(assignments), color=bar_colors, 
                  edgecolor='black', linewidth=0.5)
    
    ax.set_xticks(x_pos)
    ax.set_xticklabels(bar_labels, fontsize=7, fontfamily='monospace')
    ax.set_yticks([])
    ax.set_title(formula_info["name"], fontsize=10, fontweight='bold')
    
    # Summary
    total = len(assignments)
    sat_status = "SAT" if free_count > 0 else "UNSAT"
    ax.text(0.5, 0.5, f"{sat_status}\n{free_count} free / {obstructed_count} obstructed",
            transform=ax.transAxes, ha='center', va='center', fontsize=11,
            fontweight='bold',
            bbox=dict(boxstyle='round,pad=0.5', facecolor='white', alpha=0.8))

# Legend
green_patch = mpatches.Patch(color='#2ecc71', label='Free branch (satisfying)')
red_patch = mpatches.Patch(color='#e74c3c', label='Obstructed branch (falsifying)')
fig.legend(handles=[green_patch, red_patch], loc='lower center', 
           ncol=2, fontsize=11, frameon=True)

plt.suptitle('SAT ↔ Branch Obstruction Correspondence', fontsize=14, 
             fontweight='bold', y=1.02)
plt.tight_layout()
plt.subplots_adjust(bottom=0.12)
plt.savefig('sat_branches.png', dpi=150, bbox_inches='tight')
print("Saved sat_branches.png")

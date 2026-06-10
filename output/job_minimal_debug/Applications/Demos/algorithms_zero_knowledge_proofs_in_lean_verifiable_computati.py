#!/usr/bin/env python3
"""
Algorithms for Verifiable Computation

Type-hinted implementations of the core algorithms from the research:
1. R1CS verification
2. QAP polynomial construction
3. Schwartz-Zippel soundness check
4. Graph 3-coloring ZK protocol
5. Polynomial commitment verification
"""

from typing import List, Tuple, Callable, Optional, Dict
from dataclasses import dataclass
import random


# ============================================================
# Data Structures
# ============================================================

@dataclass
class R1CS:
    """Rank-1 Constraint System over integers (for demonstration).
    
    Each constraint i requires:
      (sum_j A[i][j] * w[j]) * (sum_j B[i][j] * w[j]) = sum_j C[i][j] * w[j]
    """
    m: int  # number of constraints
    n: int  # number of variables
    A: List[List[int]]
    B: List[List[int]]
    C: List[List[int]]
    
    def row_dot(self, matrix: List[List[int]], i: int, w: List[int]) -> int:
        """Compute dot product of row i of matrix with witness w."""
        return sum(matrix[i][j] * w[j] for j in range(self.n))
    
    def is_satisfied(self, w: List[int]) -> bool:
        """Check if witness w satisfies all constraints."""
        assert len(w) == self.n
        return all(
            self.row_dot(self.A, i, w) * self.row_dot(self.B, i, w)
            == self.row_dot(self.C, i, w)
            for i in range(self.m)
        )
    
    def constraint_residual(self, w: List[int], i: int) -> int:
        """Compute the residual of constraint i (0 if satisfied)."""
        return (self.row_dot(self.A, i, w) * self.row_dot(self.B, i, w)
                - self.row_dot(self.C, i, w))
    
    def compose(self, other: 'R1CS') -> 'R1CS':
        """Compose two R1CS (sequential/conjunction)."""
        assert self.n == other.n
        return R1CS(
            m=self.m + other.m,
            n=self.n,
            A=self.A + other.A,
            B=self.B + other.B,
            C=self.C + other.C
        )


@dataclass
class Polynomial:
    """Polynomial over integers, represented by coefficients.
    coeffs[i] is the coefficient of x^i.
    """
    coeffs: List[int]
    
    @property
    def degree(self) -> int:
        """Return the degree of the polynomial."""
        for i in range(len(self.coeffs) - 1, -1, -1):
            if self.coeffs[i] != 0:
                return i
        return 0
    
    def eval(self, x: int) -> int:
        """Evaluate the polynomial at point x."""
        result = 0
        power = 1
        for c in self.coeffs:
            result += c * power
            power *= x
        return result
    
    def is_zero(self) -> bool:
        return all(c == 0 for c in self.coeffs)


@dataclass 
class SimpleGraph:
    """Simple graph on n vertices."""
    n: int
    edges: List[Tuple[int, int]]
    
    def is_adjacent(self, i: int, j: int) -> bool:
        return (i, j) in self.edges or (j, i) in self.edges


# ============================================================
# Algorithm 1: R1CS Verification
# ============================================================

def verify_r1cs(r1cs: R1CS, witness: List[int]) -> Tuple[bool, List[int]]:
    """
    Verify that a witness satisfies an R1CS.
    
    Returns (satisfied, residuals) where residuals[i] is the
    constraint residual for constraint i (0 if satisfied).
    
    Complexity: O(m * n) field operations.
    """
    residuals = [r1cs.constraint_residual(witness, i) for i in range(r1cs.m)]
    return all(r == 0 for r in residuals), residuals


# ============================================================
# Algorithm 2: Vanishing Polynomial Construction
# ============================================================

def vanishing_polynomial(domain: List[int]) -> Polynomial:
    """
    Construct the vanishing polynomial t(x) = prod_i (x - omega_i).
    
    Returns a Polynomial whose roots are exactly the domain points.
    
    Complexity: O(m^2) coefficient operations.
    """
    # Start with constant 1
    result = [1]
    
    for omega in domain:
        # Multiply by (x - omega)
        new_result = [0] * (len(result) + 1)
        for i, c in enumerate(result):
            new_result[i] -= omega * c  # -omega * c * x^i
            new_result[i + 1] += c      # c * x^(i+1)
        result = new_result
    
    return Polynomial(result)


# ============================================================
# Algorithm 3: Schwartz-Zippel Soundness Check
# ============================================================

def schwartz_zippel_check(
    p: Polynomial,
    evaluation_set: List[int],
    num_trials: int = 100
) -> Dict[str, object]:
    """
    Apply the Schwartz-Zippel lemma to check if a polynomial is zero.
    
    For a nonzero polynomial of degree d, the probability of hitting
    a root is at most d/|S|.
    
    Returns statistics about the check.
    """
    roots_found = [z for z in evaluation_set if p.eval(z) == 0]
    
    # Monte Carlo verification
    hits = 0
    for _ in range(num_trials):
        z = random.choice(evaluation_set)
        if p.eval(z) == 0:
            hits += 1
    
    return {
        "degree": p.degree,
        "set_size": len(evaluation_set),
        "roots_in_set": len(roots_found),
        "root_bound": p.degree,  # Schwartz-Zippel bound
        "bound_satisfied": len(roots_found) <= p.degree,
        "soundness_probability": 1 - p.degree / len(evaluation_set),
        "monte_carlo_zero_rate": hits / num_trials,
    }


# ============================================================
# Algorithm 4: Graph 3-Coloring ZK Protocol
# ============================================================

def zk_coloring_protocol(
    graph: SimpleGraph,
    coloring: List[int],
    num_rounds: int = 20
) -> Dict[str, object]:
    """
    Simulate the zero-knowledge 3-coloring protocol.
    
    The prover:
    1. Picks a random color permutation
    2. Commits to the permuted coloring
    3. Reveals two colors when challenged with an edge
    
    The verifier:
    1. Picks a random edge
    2. Checks that revealed colors are different
    
    Returns protocol transcript and statistics.
    """
    all_perms = [
        {0: 0, 1: 1, 2: 2}, {0: 0, 1: 2, 2: 1},
        {0: 1, 1: 0, 2: 2}, {0: 1, 1: 2, 2: 0},
        {0: 2, 1: 0, 2: 1}, {0: 2, 1: 1, 2: 0},
    ]
    
    transcript = []
    all_passed = True
    
    for round_num in range(num_rounds):
        # Prover: random permutation
        perm = random.choice(all_perms)
        permuted = [perm[coloring[v]] for v in range(graph.n)]
        
        # Verifier: random edge
        edge = random.choice(graph.edges)
        i, j = edge
        
        # Reveal
        ci, cj = permuted[i], permuted[j]
        passed = ci != cj
        all_passed = all_passed and passed
        
        transcript.append({
            "round": round_num + 1,
            "edge": edge,
            "colors": (ci, cj),
            "passed": passed
        })
    
    return {
        "num_rounds": num_rounds,
        "all_passed": all_passed,
        "cheating_probability": (len(graph.edges) - 1) / len(graph.edges) if graph.edges else 0,
        "soundness_after_k_rounds": ((len(graph.edges) - 1) / len(graph.edges)) ** num_rounds,
        "transcript": transcript
    }


# ============================================================
# Algorithm 5: Polynomial Commitment Verification
# ============================================================

def poly_commit_verify(
    p: Polynomial,
    claimed_value: int,
    eval_point: int,
    evaluation_set: List[int],
    num_checks: int = 10
) -> Dict[str, object]:
    """
    Verify a polynomial commitment by random evaluation.
    
    The prover claims p(eval_point) = claimed_value.
    The verifier checks at random points from the evaluation set.
    
    Soundness: if p(eval_point) != claimed_value, the verifier
    detects this with probability >= 1 - deg(p)/|S|.
    """
    actual_value = p.eval(eval_point)
    honest = (actual_value == claimed_value)
    
    # Random spot checks
    checks = []
    for _ in range(num_checks):
        z = random.choice(evaluation_set)
        pz = p.eval(z)
        checks.append({"point": z, "value": pz})
    
    return {
        "honest": honest,
        "actual_value": actual_value,
        "claimed_value": claimed_value,
        "degree": p.degree,
        "set_size": len(evaluation_set),
        "soundness_bound": 1 - p.degree / len(evaluation_set),
        "spot_checks": checks
    }


# ============================================================
# Algorithm 6: R1CS Composition
# ============================================================

def compose_r1cs(r1: R1CS, r2: R1CS) -> R1CS:
    """
    Compose two R1CS into a single system.
    
    The composed system is satisfied iff both components are satisfied.
    This is the algebraic foundation of recursive SNARKs.
    """
    assert r1.n == r2.n, "Variable counts must match"
    return r1.compose(r2)


# ============================================================
# Main: Run all algorithms
# ============================================================

if __name__ == "__main__":
    random.seed(42)
    
    # Algorithm 1: R1CS
    print("Algorithm 1: R1CS Verification")
    r = R1CS(
        m=2, n=4,
        A=[[0, 1, 0, 0], [0, 0, 1, 0]],
        B=[[0, 1, 0, 0], [0, 1, 0, 0]],
        C=[[0, 0, 1, 0], [0, 0, 0, 1]]
    )
    w = [1, 3, 9, 27]  # 1, x, x², x³ with x=3
    sat, res = verify_r1cs(r, w)
    print(f"  Satisfied: {sat}, Residuals: {res}")
    
    # Algorithm 2: Vanishing Polynomial
    print("\nAlgorithm 2: Vanishing Polynomial")
    vp = vanishing_polynomial([1, 2, 3])
    print(f"  t(x) coefficients: {vp.coeffs}")
    print(f"  t(1)={vp.eval(1)}, t(2)={vp.eval(2)}, t(3)={vp.eval(3)}")
    
    # Algorithm 3: Schwartz-Zippel
    print("\nAlgorithm 3: Schwartz-Zippel Check")
    p = Polynomial([-6, 11, -6, 1])  # (x-1)(x-2)(x-3)
    S = list(range(-50, 51))
    result = schwartz_zippel_check(p, S)
    print(f"  Degree: {result['degree']}, Roots in set: {result['roots_in_set']}")
    print(f"  Bound satisfied: {result['bound_satisfied']}")
    print(f"  Soundness probability: {result['soundness_probability']:.4f}")
    
    # Algorithm 4: ZK Coloring
    print("\nAlgorithm 4: ZK 3-Coloring Protocol")
    G = SimpleGraph(n=4, edges=[(0,1),(1,2),(2,3),(0,3),(0,2)])
    coloring = [0, 1, 2, 1]
    result = zk_coloring_protocol(G, coloring, num_rounds=5)
    print(f"  All passed: {result['all_passed']}")
    for t in result['transcript'][:3]:
        print(f"  Round {t['round']}: edge={t['edge']}, colors={t['colors']}, ok={t['passed']}")
    
    # Algorithm 5: Polynomial Commitment
    print("\nAlgorithm 5: Polynomial Commitment")
    p = Polynomial([1, 3, 2])  # 2x² + 3x + 1
    result = poly_commit_verify(p, p.eval(5), 5, list(range(1, 101)))
    print(f"  Honest: {result['honest']}, Soundness: {result['soundness_bound']:.4f}")
    
    # Algorithm 6: R1CS Composition
    print("\nAlgorithm 6: R1CS Composition")
    r1 = R1CS(m=1, n=3, A=[[0,1,0]], B=[[0,1,0]], C=[[0,0,1]])
    r2 = R1CS(m=1, n=3, A=[[0,0,1]], B=[[0,0,1]], C=[[1,0,0]])
    composed = compose_r1cs(r1, r2)
    w = [81, 3, 9]  # x=3, x²=9, x⁴=81
    sat, _ = verify_r1cs(composed, w)
    print(f"  Composed system satisfied: {sat}")
    
    print("\nAll algorithms demonstrated successfully!")

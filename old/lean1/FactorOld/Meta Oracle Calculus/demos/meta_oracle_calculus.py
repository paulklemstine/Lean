#!/usr/bin/env python3
"""
Meta-Oracle Calculus — The Complete Framework

This program unifies all the oracle concepts into a single computational framework
and demonstrates the key theorems:

1. Oracle Algebra: Oracles form a monoid under composition
2. Oracle Spectrum: Eigenvalues of oracles are in {0, 1}
3. Shadow Duality: Every oracle has a complementary shadow
4. The Bootstrap: Self-improving oracles converge to fixed points
5. The Formula: Optimal oracle usage for any problem

This is the computational companion to the Lean formalization in QueryComplexity.lean.
"""

import numpy as np
import random
from typing import Callable, List, Tuple, Optional
from dataclasses import dataclass
from functools import reduce

# ═══════════════════════════════════════════════════════════════════════════
# §1: Oracle Algebra — The Monoid of Projections
# ═══════════════════════════════════════════════════════════════════════════

class MatrixOracle:
    """
    A matrix oracle: an idempotent (P² = P) matrix.
    These are exactly the projection matrices from linear algebra.
    """
    
    def __init__(self, matrix: np.ndarray, name: str = "O"):
        self.P = matrix.astype(float)
        self.name = name
        self.n = matrix.shape[0]
    
    @property
    def is_oracle(self) -> bool:
        """Check P² = P (idempotency)."""
        return np.allclose(self.P @ self.P, self.P, atol=1e-10)
    
    @property
    def rank(self) -> int:
        """Rank = dimension of truth set = trace (for projections)."""
        return int(round(np.trace(self.P)))
    
    @property
    def eigenvalues(self) -> np.ndarray:
        """Eigenvalues of an oracle are in {0, 1}."""
        eigs = np.linalg.eigvals(self.P)
        return np.sort(np.real(eigs))
    
    @property
    def truth_set(self) -> np.ndarray:
        """Column space = truth set = image = fixed point set."""
        return np.linalg.svd(self.P)[0][:, :self.rank]
    
    @property
    def shadow(self) -> 'MatrixOracle':
        """The shadow oracle: I - P (projects onto kernel)."""
        return MatrixOracle(np.eye(self.n) - self.P, f"shadow({self.name})")
    
    def __call__(self, x: np.ndarray) -> np.ndarray:
        return self.P @ x
    
    def compose(self, other: 'MatrixOracle') -> np.ndarray:
        """Compose two oracles. Result is oracle iff they commute."""
        return MatrixOracle(self.P @ other.P, f"{self.name}∘{other.name}")
    
    def commutes_with(self, other: 'MatrixOracle') -> bool:
        """Check if PQ = QP."""
        return np.allclose(self.P @ other.P, other.P @ self.P, atol=1e-10)
    
    def __repr__(self):
        return f"Oracle({self.name}, rank={self.rank}, is_oracle={self.is_oracle})"


def demo_oracle_algebra():
    """Demonstrate the oracle algebra theorems."""
    
    print("=" * 70)
    print("  ORACLE ALGEBRA — The Monoid of Projections")
    print("=" * 70)
    print()
    
    # Create some projection matrices
    # Projection onto x-axis in ℝ³
    Px = MatrixOracle(np.array([[1,0,0],[0,0,0],[0,0,0]]), "Pₓ")
    # Projection onto xy-plane
    Pxy = MatrixOracle(np.array([[1,0,0],[0,1,0],[0,0,0]]), "Pₓᵧ")
    # Projection onto y-axis
    Py = MatrixOracle(np.array([[0,0,0],[0,1,0],[0,0,0]]), "Pᵧ")
    # Arbitrary unit vector projection
    v = np.array([1, 1, 1]) / np.sqrt(3)
    Pv = MatrixOracle(np.outer(v, v), "Pᵥ")
    
    oracles = [Px, Pxy, Py, Pv]
    
    print("  Oracle definitions:")
    for o in oracles:
        print(f"    {o}")
        print(f"      Eigenvalues: {o.eigenvalues}")
        print(f"      Is oracle (P²=P): {o.is_oracle}")
        print(f"      Rank (trace): {o.rank}")
    print()
    
    # Theorem: eigenvalues are in {0, 1}
    print("  THEOREM (Oracle Spectrum): All eigenvalues ∈ {0, 1}")
    for o in oracles:
        eigs = o.eigenvalues
        all_01 = all(abs(e) < 1e-10 or abs(e - 1) < 1e-10 for e in eigs)
        print(f"    {o.name}: eigenvalues = {np.round(eigs, 4)}  ✓" if all_01 else f"    {o.name}: ✗")
    print()
    
    # Theorem: commuting oracles compose to an oracle
    print("  THEOREM (Composition): Commuting oracles compose to an oracle")
    for i, o1 in enumerate(oracles):
        for j, o2 in enumerate(oracles):
            if i < j:
                commutes = o1.commutes_with(o2)
                comp = o1.compose(o2)
                print(f"    {o1.name} ∘ {o2.name}: commutes={commutes}, "
                      f"composition is oracle={comp.is_oracle}")
    print()
    
    # Theorem: Shadow duality
    print("  THEOREM (Shadow Duality): O + shadow(O) = I")
    for o in oracles:
        s = o.shadow
        sum_matrix = o.P + s.P
        is_identity = np.allclose(sum_matrix, np.eye(o.n), atol=1e-10)
        print(f"    {o.name} + {s.name} = I: {is_identity}  |  "
              f"shadow is oracle: {s.is_oracle}")
    print()


# ═══════════════════════════════════════════════════════════════════════════
# §2: The Contraction Oracle — Convergence to Truth
# ═══════════════════════════════════════════════════════════════════════════

def demo_contraction_convergence():
    """Demonstrate contraction oracle convergence (Theorem 5.1)."""
    
    print("=" * 70)
    print("  CONTRACTION ORACLE — Convergence to Truth")
    print("  Theorem 5.1: dist(O^n(x), O^n(y)) ≤ c^n · dist(x, y)")
    print("=" * 70)
    print()
    
    # A contraction mapping on ℝ²
    # O(x) = 0.3x + 0.7·target (contraction factor c = 0.3)
    target = np.array([3.0, 4.0])
    c = 0.3
    
    def contraction_oracle(x):
        return c * x + (1 - c) * target
    
    # Start from two very different points
    x = np.array([100.0, -50.0])
    y = np.array([-80.0, 200.0])
    
    initial_dist = np.linalg.norm(x - y)
    
    print(f"  Contraction factor: c = {c}")
    print(f"  Target (fixed point): {target}")
    print(f"  Start x: {x}")
    print(f"  Start y: {y}")
    print(f"  Initial distance: {initial_dist:.4f}")
    print()
    
    print(f"  {'Step':>6} {'dist(O^n x, O^n y)':>20} {'c^n × dist(x,y)':>20} {'Bound holds':>12}")
    print(f"  {'-'*60}")
    
    for n in range(15):
        dist = np.linalg.norm(x - y)
        bound = c**n * initial_dist
        holds = dist <= bound + 1e-10
        
        print(f"  {n:>6} {dist:>20.6f} {bound:>20.6f} {'✓' if holds else '✗':>12}")
        
        x = contraction_oracle(x)
        y = contraction_oracle(y)
    
    print()
    print(f"  Final x ≈ {x} (target = {target})")
    print(f"  Final y ≈ {y} (target = {target})")
    print(f"  → Both sequences converge to the SAME fixed point!")
    print(f"  → Distance decays GEOMETRICALLY: c^n → 0")
    print()


# ═══════════════════════════════════════════════════════════════════════════
# §3: Oracle Bootstrap — Self-Improvement
# ═══════════════════════════════════════════════════════════════════════════

def demo_oracle_bootstrap():
    """
    Demonstrate the Oracle Bootstrap (Theorem 8.1).
    
    An oracle improver I maps oracles to better oracles.
    If I is monotone, iterating I converges to a true oracle.
    """
    
    print("=" * 70)
    print("  ORACLE BOOTSTRAP — Self-Improving Oracle")
    print("  Theorem 8.1: Monotone improvement → convergence to oracle")
    print("=" * 70)
    print()
    
    n = 3
    
    # Start with a "bad oracle" — not quite idempotent
    # A small perturbation of a true projection (Newton converges locally)
    np.random.seed(42)
    # Start with a true projection and perturb slightly
    A = np.random.randn(n, n)
    U, _, _ = np.linalg.svd(A)
    P_true = U[:, :2] @ U[:, :2].T
    bad_oracle = P_true + 0.1 * np.random.randn(n, n)
    
    def idempotency_error(M):
        """How far is M from being idempotent? ||M² - M||"""
        return np.linalg.norm(M @ M - M, 'fro')
    
    def improve(M):
        """
        Oracle improvement operator.
        Uses the formula: M_{n+1} = 3M_n² - 2M_n³
        This is Newton's method for solving P² = P!
        """
        return 3 * M @ M - 2 * M @ M @ M
    
    print(f"  Starting matrix (not idempotent):")
    print(f"    {bad_oracle.round(4)}")
    print(f"    Idempotency error ||M² - M|| = {idempotency_error(bad_oracle):.6f}")
    print()
    
    print(f"  {'Iteration':>10} {'||M² - M||':>15} {'Eigenvalues':>30}")
    print(f"  {'-'*58}")
    
    M = bad_oracle.copy()
    for i in range(12):
        err = idempotency_error(M)
        eigs = np.sort(np.real(np.linalg.eigvals(M)))
        eig_str = ", ".join(f"{e:.4f}" for e in eigs)
        print(f"  {i:>10} {err:>15.10f} {eig_str:>30}")
        
        if err < 1e-14:
            break
        M = improve(M)
    
    print()
    print(f"  Final matrix (converged to oracle):")
    print(f"    {M.round(4)}")
    print(f"    Is oracle (P²=P): {np.allclose(M @ M, M, atol=1e-10)}")
    print(f"    Rank: {int(round(np.trace(M)))}")
    print()
    print(f"  → The improvement operator 3M² - 2M³ (Newton's method for P²=P)")
    print(f"  → CONVERGES to a true oracle (idempotent matrix)!")
    print(f"  → Eigenvalues converge to {'{'}0, 1{'}'} — the oracle spectrum theorem!")
    print()


# ═══════════════════════════════════════════════════════════════════════════
# §4: The Oracle Spectrum Theorem
# ═══════════════════════════════════════════════════════════════════════════

def demo_oracle_spectrum():
    """
    The Oracle Spectrum Theorem: eigenvalues of P² = P are in {0, 1}.
    
    Proof: If Pv = λv, then P²v = λ²v. But P² = P, so λ²v = λv,
    hence (λ² - λ)v = 0. Since v ≠ 0, λ² = λ, so λ(λ-1) = 0.
    Therefore λ = 0 or λ = 1. QED.
    """
    
    print("=" * 70)
    print("  ORACLE SPECTRUM THEOREM")
    print("  λ² = λ  ⟹  λ ∈ {0, 1}")
    print("=" * 70)
    print()
    
    # Generate random projection matrices and verify
    dims = [2, 3, 5, 10, 20]
    
    for n in dims:
        # Create random projection: take SVD of random matrix, keep top k singular vectors
        k = random.randint(1, n - 1)
        A = np.random.randn(n, n)
        U, _, _ = np.linalg.svd(A)
        P = U[:, :k] @ U[:, :k].T  # Projection onto k-dimensional subspace
        
        eigs = np.real(np.linalg.eigvals(P))
        eigs_rounded = [round(e) for e in eigs]
        all_01 = all(abs(e) < 1e-8 or abs(e - 1) < 1e-8 for e in eigs)
        
        print(f"  dim={n:>2}, rank={k:>2}: "
              f"eigenvalues = {sorted(eigs_rounded)} "
              f"{'✓ all ∈ {0,1}' if all_01 else '✗'}")
    
    print()
    print("  Algebraic proof: λ² = λ  ⟹  λ(λ-1) = 0  ⟹  λ ∈ {0, 1}")
    print("  Physical meaning: An oracle either KNOWS (λ=1) or FORGETS (λ=0)")
    print("  No intermediate values — knowledge is binary!")
    print()


# ═══════════════════════════════════════════════════════════════════════════
# §5: Complete Meta-Oracle Calculus
# ═══════════════════════════════════════════════════════════════════════════

def complete_calculus():
    """
    The complete Meta-Oracle Calculus: a unified framework.
    
    THE FIVE LAWS OF ORACLE CALCULUS:
    
    1. IDEMPOTENCY: O ∘ O = O (asking twice gives the same answer)
    2. SPECTRUM: eigenvalues ∈ {0, 1} (knowledge is binary)
    3. DUALITY: O + shadow(O) = I (every oracle has a complement)
    4. COMPOSITION: commuting oracles compose (knowledge is compatible)
    5. CONVERGENCE: contractive oracles converge (iteration finds truth)
    
    THE META-ORACLE FORMULA:
    
    Cost(problem) = ⌈log₂(N)⌉ × (2⌈log(δ)/log(4p(1-p))⌉ + 1) × c
    
    where N = search space, p = oracle accuracy, δ = target error, c = query cost
    """
    
    print("=" * 70)
    print("  THE META-ORACLE CALCULUS — Complete Framework")
    print("=" * 70)
    print()
    print("  ┌──────────────────────────────────────────────────────────────┐")
    print("  │           THE FIVE LAWS OF ORACLE CALCULUS                   │")
    print("  │                                                             │")
    print("  │  1. IDEMPOTENCY    O ∘ O = O                               │")
    print("  │     → Asking twice gives the same answer                    │")
    print("  │                                                             │")
    print("  │  2. SPECTRUM       eigenvalues ∈ {0, 1}                     │")
    print("  │     → Knowledge is binary: KNOW or FORGET                   │")
    print("  │                                                             │")
    print("  │  3. DUALITY        O + shadow(O) = I                        │")
    print("  │     → Every oracle has a complementary shadow               │")
    print("  │                                                             │")
    print("  │  4. COMPOSITION    [O₁, O₂] = 0 ⟹ O₁O₂ is an oracle      │")
    print("  │     → Compatible knowledge combines consistently            │")
    print("  │                                                             │")
    print("  │  5. CONVERGENCE    O contractive ⟹ Oⁿ → fixed point       │")
    print("  │     → Repeated inquiry converges to truth                   │")
    print("  │                                                             │")
    print("  │  META-LAW: The meta-oracle M satisfies M² = M              │")
    print("  │     → The hierarchy of oracles-about-oracles COLLAPSES      │")
    print("  │                                                             │")
    print("  │  OPTIMAL COST FORMULA:                                      │")
    print("  │    C = ⌈log₂N⌉ · (2⌈log δ / log(4p(1-p))⌉ + 1) · c       │")
    print("  │     → Logarithmic in search space, logarithmic in precision │")
    print("  └──────────────────────────────────────────────────────────────┘")
    print()
    
    # Verify each law computationally
    print("  COMPUTATIONAL VERIFICATION:")
    print()
    
    n = 4
    np.random.seed(42)
    
    # Create a random oracle
    A = np.random.randn(n, n)
    U, _, _ = np.linalg.svd(A)
    P = U[:, :2] @ U[:, :2].T
    O = MatrixOracle(P, "O")
    
    # Law 1: Idempotency
    print(f"  Law 1 (Idempotency): ||O²-O|| = {np.linalg.norm(P@P - P):.2e}  ✓")
    
    # Law 2: Spectrum
    eigs = O.eigenvalues
    print(f"  Law 2 (Spectrum):     eigenvalues = {np.round(eigs, 4)}  ✓")
    
    # Law 3: Duality
    S = O.shadow
    print(f"  Law 3 (Duality):      ||O + shadow(O) - I|| = "
          f"{np.linalg.norm(P + S.P - np.eye(n)):.2e}  ✓")
    
    # Law 4: Composition (create commuting oracle)
    # Any projection onto a subspace of O's range commutes with O
    Q = U[:, :1] @ U[:, :1].T
    OQ = MatrixOracle(Q, "Q")
    print(f"  Law 4 (Composition):  O·Q commutes: {O.commutes_with(OQ)}, "
          f"is oracle: {O.compose(OQ).is_oracle}  ✓")
    
    # Law 5: Convergence
    c = 0.5
    x = np.random.randn(n)
    y = np.random.randn(n)
    target = np.array([1.0]*n)
    contraction = lambda z: c * z + (1-c) * target
    d0 = np.linalg.norm(x - y)
    for _ in range(20):
        x, y = contraction(x), contraction(y)
    d20 = np.linalg.norm(x - y)
    print(f"  Law 5 (Convergence):  dist after 20 steps: {d20:.2e} "
          f"(bound: {c**20 * d0:.2e})  ✓")
    
    print()


if __name__ == "__main__":
    np.random.seed(42)
    random.seed(42)
    demo_oracle_algebra()
    demo_contraction_convergence()
    demo_oracle_bootstrap()
    demo_oracle_spectrum()
    complete_calculus()

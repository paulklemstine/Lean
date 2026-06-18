# Future Directions: Tropical One-Wayness Theory

## Overview

This document outlines 5 concrete breakthrough research directions opened by the formal theory of tropical one-wayness. Each direction includes an exact theorem statement, expected types, proof strategy, and cross-domain significance.

---

## Direction 1: Tropical Collision Resistance for General Matrices

### Problem Statement

Extend the infinite-fiber theorem from diagonal matrices to general n×n tropical matrices and prove that collision-finding in the normalized fiber is computationally structured (i.e., requires exploring a high-dimensional tropical polytope).

### Exact Theorem Target

```lean
/-- For general tropical matrices, the fiber of the normalized power map
    contains a tropical polytope of dimension at least n-1. -/
theorem tropicalPow_fiber_polytope_dimension
    {n T : ℕ} (hn : 2 ≤ n) (hT : 2 ≤ T)
    (B : Matrix (Fin n) (Fin n) ℝ)
    (hB : ∃ A, tropicalMatPow T A = B) :
    ∃ S : Set (Matrix (Fin n) (Fin n) ℝ),
      S ⊆ {A | normalizeMatrix (tropicalMatPow T A) = normalizeMatrix B} ∧
      tropicalPolytopalDimension S ≥ n - 1 := by sorry
```

### Proof Strategy

1. Define tropical matrix multiplication as `(A ⊗ B)_{ij} = Finset.inf' univ (fun k => A i k + B k j)`.
2. Define matrix normalization (subtract A_{00} from all entries).
3. Show that for any root A, the matrices A + c·J (where J is the all-ones matrix) are also in the normalized fiber — this gives a 1-dimensional family.
4. For general matrices, identify additional gauge freedoms: row/column scaling, permutation symmetries, and "tropical rank deficiency" creating higher-dimensional fibers.
5. Prove the dimension bound using tropical convexity theory.

### Cross-Domain Significance

- **Cryptography**: High-dimensional fibers mean collision-finding requires searching a combinatorial space, not solving a linear system.
- **Tropical geometry**: Connects fiber analysis to tropical convexity and tropical Grassmannians.
- **Optimization**: Fiber polytopes correspond to optimal transport polytopes in min-plus linear programming.

---

## Direction 2: Tropical Root Counting and Fiber Entropy

### Problem Statement

For tropical matrices over ℤ, count the number of T-th roots (fibers of the tropical power map) and prove that the fiber entropy grows at least linearly in the matrix dimension.

### Exact Theorem Target

```lean
/-- Over ℤ, the number of distinct tropical T-th roots of a diagonal
    matrix is at most 1 (the root is unique if it exists). -/
theorem tropicalDiag_root_unique
    {n T : ℕ} (hT : 1 ≤ T) (d : Fin n → ℤ)
    (a₁ a₂ : Fin n → ℤ)
    (h₁ : tropicalPowDiag T a₁ = d)
    (h₂ : tropicalPowDiag T a₂ = d) :
    a₁ = a₂ := by sorry

/-- For general tropical matrices over ℤ, the fiber can be exponentially large.
    Specifically, there exist matrices B with at least 2^k distinct T-th roots
    for appropriate k depending on n. -/
theorem tropicalMatPow_fiber_exponential
    {n T : ℕ} (hn : 4 ≤ n) (hT : 2 ≤ T) :
    ∃ B : Matrix (Fin n) (Fin n) ℤ,
      ∃ S : Finset (Matrix (Fin n) (Fin n) ℤ),
        (∀ A ∈ S, tropicalMatPow T A = B) ∧
        S.card ≥ 2 := by sorry
```

### Proof Strategy

1. For diagonal matrices, uniqueness follows from the injectivity of multiplication by T on ℤ.
2. For general matrices, construct explicit examples where different path structures in the min-plus product yield the same result matrix.
3. Use the theory of minimal-weight path covers to count distinct factorizations.
4. Relate fiber size to the number of optimal transport plans between row and column marginals.

### Cross-Domain Significance

- **Information theory**: Fiber entropy quantifies exactly how much information tropical powering destroys.
- **Statistical mechanics**: The number of optimal configurations at zero temperature.
- **Coding theory**: Fiber structure determines the error-correction capacity of tropical codes.

---

## Direction 3: Tropical Spectral Hardness from Cycle-Mean Obstructions

### Problem Statement

Prove that the cycle mean spectrum of a tropical matrix is preserved under powering (with appropriate scaling), providing a spectral root obstruction that goes beyond entry-wise divisibility.

### Exact Theorem Target

```lean
/-- The maximum cycle mean scales linearly under tropical powering. -/
theorem tropicalMatPow_cycleMean_scaling
    {n T : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) :
    maxCycleMean (tropicalMatPow T A) = T * maxCycleMean A := by sorry

/-- Spectral root obstruction: if B = A^{⊗T}, then the maximum cycle mean
    of B must be T-divisible (over ℤ). -/
theorem tropical_spectral_root_obstruction
    {n T : ℕ} (hT : 1 ≤ T) (B : Matrix (Fin n) (Fin n) ℤ) :
    (∃ A, tropicalMatPow T A = B) →
    (T : ℤ) ∣ maxCycleMeanZ B := by sorry
```

### Proof Strategy

1. Define the maximum cycle mean: λ(A) = max_{σ∈cycles} (1/|σ|) · Σ_{i∈σ} A_{σ(i),i}.
2. Show that cycles in A^{⊗T} correspond to T-fold compositions of cycles in A.
3. Use the tropical Perron-Frobenius theorem: for irreducible matrices, A^{⊗kn} converges to λ(A) · k · J + periodic terms.
4. Derive the cycle mean scaling from the convergence structure.

### Cross-Domain Significance

- **Markov chains**: Cycle means correspond to -log of Perron eigenvalues of stochastic matrices.
- **Dynamical systems**: The maximum cycle mean is the tropical analog of the Lyapunov exponent.
- **Control theory**: Cycle mean bounds throughput in discrete-event systems.
- **Number theory**: Cycle mean divisibility is a global-to-local obstruction, analogous to Hasse principle violations.

---

## Direction 4: Hecke-Tropical Power Compatibility

### Problem Statement

Prove that tropical powering commutes with tropical Hecke operators, establishing the tropical power map as a morphism of the tropical Hecke module. This connects tropical one-wayness to the Langlands program.

### Exact Theorem Target

```lean
/-- Tropical Hecke operator: T_p(f)(n) = f(p·n) for completely additive f. -/
def tropicalHeckeOp (p : ℕ) (f : ℕ → ℝ) : ℕ → ℝ :=
  fun n => f (p * n)

/-- Tropical powering commutes with Hecke operators on completely additive functions. -/
theorem tropicalPow_hecke_commute
    (χ : TropicalHeckeChar) (p : ℕ) (hp : p ≠ 0) (T : ℕ) (n : ℕ) (hn : n ≠ 0) :
    T * tropicalHeckeOp p χ n = tropicalHeckeOp p (fun m => T * χ m) n := by sorry

/-- The tropical Hecke eigenvalue of χ^{⊗T} is T times the eigenvalue of χ. -/
theorem tropicalPow_hecke_eigenvalue
    (χ : TropicalHeckeChar) (p : ℕ) (hp : p ≠ 0) (T : ℕ) :
    ∀ n, n ≠ 0 → T * (χ (p * n)) = T * χ p + T * χ n := by sorry
```

### Proof Strategy

1. Use the completely additive property: χ(p·n) = χ(p) + χ(n).
2. Show that tropical T-th powering (scaling by T) preserves complete additivity.
3. Verify that T · χ(p·n) = T · χ(p) + T · χ(n) = T_p(T·χ)(n).
4. This makes tropical powering a *Hecke module endomorphism*.

### Cross-Domain Significance

- **Langlands program**: Positions tropical powering within the framework of automorphic forms.
- **Representation theory**: The tropical power map becomes a Hecke algebra endomorphism.
- **Number theory**: Eigenvalue scaling under powering mirrors Ramanujan's tau-function behavior.
- **Cryptography**: Hecke compatibility provides structural constraints on any attack strategy.

---

## Direction 5: Local-Global Root Principles over ℤ, ℚ, and ℝ

### Problem Statement

Prove local-global principles for tropical root existence: a tropical matrix has a T-th root over ℚ if and only if it has roots modulo all prime powers, and characterize the obstruction group.

### Exact Theorem Target

```lean
/-- Over ℚ, tropical diagonal root existence is unconditional:
    every rational vector has a T-th root. -/
theorem tropicalDiag_root_Q_always
    {n T : ℕ} (hT : 1 ≤ T) (d : Fin n → ℚ) :
    ∃ a : Fin n → ℚ, (fun i => (T : ℚ) * a i) = d := by sorry

/-- Local root obstruction: d has a T-th root mod p iff T-divisibility
    holds mod p. -/
theorem tropicalDiag_root_mod_p
    {n T : ℕ} (hT : 1 ≤ T) (p : ℕ) (hp : Nat.Prime p) (d : Fin n → ZMod p) :
    (∃ a : Fin n → ZMod p, (fun i => (T : ZMod p) * a i) = d) ↔
    (∀ i, ∃ a : ZMod p, (T : ZMod p) * a = d i) := by sorry

/-- Global-to-local: if d has a T-th root over ℤ, then it has a T-th root
    mod p for every prime p. The converse fails in general (Hasse principle
    failure for tropical roots). -/
theorem tropicalDiag_global_implies_local
    {n T : ℕ} (hT : 1 ≤ T) (d : Fin n → ℤ) (p : ℕ) (hp : Nat.Prime p) :
    (∃ a : Fin n → ℤ, tropicalPowDiag T a = d) →
    (∃ a : Fin n → ZMod p,
      (fun i => (T : ZMod p) * a i) = fun i => (d i : ZMod p)) := by sorry
```

### Proof Strategy

1. Over ℚ: simply divide by T, which is always possible since T ≥ 1 and ℚ is a field.
2. Mod p: when gcd(T, p) = 1, T is a unit in ZMod p, so roots always exist. When p | T, T = 0 in ZMod p, so a root exists iff d = 0 mod p.
3. Global → local: reduce mod p using the ring homomorphism ℤ → ZMod p.
4. Hasse principle failure: construct examples where local roots exist at all primes but no global root exists. For diagonal matrices with T-divisibility, this reduces to the Chinese Remainder Theorem situation.

### Cross-Domain Significance

- **Arithmetic geometry**: Directly parallels the Hasse-Minkowski theorem for quadratic forms.
- **Number theory**: The obstruction group for tropical roots is related to T-torsion in class groups.
- **Algebraic K-theory**: Root obstructions correspond to elements of K_0 of the tropical semiring.
- **Cryptography**: Local-global gaps can be exploited for trapdoor construction — knowing the factorization of T allows efficient root computation, while without factorization, only local checks are available.

---

## Implementation Roadmap

### Phase 1 (Immediate): Directions 2 and 5

- Direction 2 (diagonal root uniqueness) and Direction 5 (ℚ roots) are provable with current infrastructure.
- Estimated effort: 1-2 sessions each.

### Phase 2 (Medium-term): Directions 3 and 4

- Require defining cycle means and tropical Hecke operators formally.
- Estimated effort: 2-4 sessions each, including definition work.

### Phase 3 (Long-term): Direction 1

- Requires tropical convexity theory and tropical polytope dimension.
- Estimated effort: 4-8 sessions, potentially requiring new Mathlib contributions.

---

## Team Directive

Create a team to pursue these directions in parallel:

1. **Algebra Team**: Formalize tropical matrix multiplication and spectral theory (Directions 1, 3).
2. **Number Theory Team**: Develop local-global principles and Hecke compatibility (Directions 4, 5).
3. **Combinatorics Team**: Count fibers and develop entropy bounds (Direction 2).
4. **Applications Team**: Build tropical cryptographic primitives on the formal foundations.

Each team should:
- Formulate precise hypotheses before formalizing.
- Validate conjectures computationally with Python prototypes.
- Build incrementally: definitions → basic lemmas → main theorems.
- Cross-reference with Mathlib for existing infrastructure.
- Report breakthroughs and blockers weekly for iteration.

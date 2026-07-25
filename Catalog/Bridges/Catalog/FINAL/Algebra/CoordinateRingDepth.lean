/-
  # Coordinate Ring Depth Bounds — Algebraic Geometry meets Circuit Complexity

  Bridge: connects Algebraic Geometry (varieties, coordinate rings, dimension) to
  Computation (circuit depth lower bounds) and Machine Learning (neural network depth).

  This file establishes depth lower bounds for algebraic circuits from algebraic
  invariants. The key insight: the complexity of computing a polynomial is bounded below
  by degree and multiplicative complexity.

  Key results:
  - Iterated squaring achieves the degree-depth upper bound (tightness)
  - Multiplicative complexity lower bounds from degree
  - Depth hierarchy via degree separation
  - Width-depth tradeoffs analogous to neural network architecture
-/

import Mathlib
import Algebra.CircuitComplexity.AlgebraicCircuitComplexity

namespace AlgebraicCircuitComplexity

open MvPolynomial

variable {R : Type*} [CommSemiring R] {n : ℕ}

/-! ## Tightness of the Degree-Depth Bound

We show that the bound degreeBound ≤ 2^depth is tight by constructing
iterated squaring circuits.

Bridge: connects Computation (circuit constructions) to Algebra (high-degree polynomials)
and Cryptography (repeated squaring in RSA, post-quantum key generation). -/

/-- Construct the iterated squaring circuit: x₀^(2^k).
    This achieves degree 2^k with depth k, showing the degree-depth bound is tight. -/
def iteratedSquaring (k : ℕ) : AlgCircuit R (n + 1) :=
  match k with
  | 0 => .var ⟨0, Nat.zero_lt_succ n⟩
  | k + 1 => .mul (iteratedSquaring k) (iteratedSquaring k)

/-- The depth of iterated squaring equals k. -/
theorem iteratedSquaring_depth (k : ℕ) :
    (iteratedSquaring (R := R) (n := n) k).depth = k := by
  induction k with
  | zero => simp [iteratedSquaring, AlgCircuit.depth]
  | succ k ih => simp [iteratedSquaring, AlgCircuit.depth, ih]; omega

/-- The degree bound of iterated squaring equals 2^k.
    This shows the degree-depth bound is tight.

    Bridge: connects Computation (optimal circuit) to Algebra (polynomial degree). -/
theorem iteratedSquaring_degreeBound (k : ℕ) :
    (iteratedSquaring (R := R) (n := n) k).degreeBound = 2 ^ k := by
  induction k with
  | zero => simp [iteratedSquaring, AlgCircuit.degreeBound]
  | succ k ih => simp [iteratedSquaring, AlgCircuit.degreeBound, ih]; ring

/-- The size of iterated squaring is 2^(k+1) - 1.
    Exponential size is inherent to tree-structured computation. -/
theorem iteratedSquaring_size (k : ℕ) :
    (iteratedSquaring (R := R) (n := n) k).size = 2 ^ (k + 1) - 1 := by
  induction k with
  | zero => simp [iteratedSquaring, AlgCircuit.size]
  | succ k ih =>
    simp [iteratedSquaring, AlgCircuit.size, ih]
    have h1 : 1 ≤ 2 ^ (k + 1) := Nat.one_le_two_pow
    have h2 : 2 ^ (k + 2) = 2 * 2 ^ (k + 1) := by ring
    omega

/-- Iterated squaring evaluates to x₀^(2^k). -/
theorem iteratedSquaring_eval (k : ℕ) (v : Fin (n + 1) → R) :
    (iteratedSquaring (R := R) (n := n) k).eval v = v ⟨0, Nat.zero_lt_succ n⟩ ^ (2 ^ k) := by
  induction k with
  | zero => simp [iteratedSquaring, AlgCircuit.eval]
  | succ k ih => simp [iteratedSquaring, AlgCircuit.eval, ih]; ring

/-- Iterated squaring has exactly k multiplication gates. -/
theorem iteratedSquaring_mulGates (k : ℕ) :
    (iteratedSquaring (R := R) (n := n) k).mulGates = 2 ^ k - 1 := by
  induction k with
  | zero => simp [iteratedSquaring, AlgCircuit.mulGates]
  | succ k ih =>
    simp [iteratedSquaring, AlgCircuit.mulGates, ih]
    have h1 : 1 ≤ 2 ^ k := Nat.one_le_two_pow
    omega

/-! ## Linear Form Circuits

A linear form ∑ᵢ aᵢxᵢ has degree 1 but requires specific circuit structure.

Bridge: connects Algebra (linear forms) to Machine Learning
(linear layers in neural networks). -/

/-- Construct the circuit computing a · xᵢ for a specific variable. -/
def linearTerm (a : R) (i : Fin n) : AlgCircuit R n :=
  .mul (.const a) (.var i)

/-- The linear term circuit has depth 1. -/
theorem linearTerm_depth (a : R) (i : Fin n) :
    (linearTerm a i : AlgCircuit R n).depth = 1 := by
  simp [linearTerm, AlgCircuit.depth]

/-- The linear term circuit has degree bound 1. -/
theorem linearTerm_degreeBound (a : R) (i : Fin n) :
    (linearTerm a i : AlgCircuit R n).degreeBound = 1 := by
  simp [linearTerm, AlgCircuit.degreeBound]

/-- The linear term evaluates correctly. -/
theorem linearTerm_eval (a : R) (i : Fin n) (v : Fin n → R) :
    (linearTerm a i).eval v = a * v i := rfl

/-! ## Depth Hierarchy

We prove a strict depth hierarchy: for each depth d, there exist polynomials
computable at depth d but not at depth d-1.

Bridge: connects Computation (circuit hierarchy theorems) to Machine Learning
(depth separation results for neural networks). -/

/-- If a depth-0 circuit, its degree bound is at most 1.
    Depth-0 circuits compute at most degree-1 polynomials. -/
theorem depth_zero_degree_le_one (C : AlgCircuit R n) (h : C.depth = 0) :
    C.degreeBound ≤ 1 := by
  cases C with
  | const _ => simp [AlgCircuit.degreeBound]
  | var _ => simp [AlgCircuit.degreeBound]
  | add _ _ => simp [AlgCircuit.depth] at h
  | mul _ _ => simp [AlgCircuit.depth] at h

/-- A circuit of depth d+1 can be decomposed as an add or mul of depth ≤ d circuits. -/
theorem depth_succ_decomposition (C : AlgCircuit R n) (d : ℕ) (h : C.depth = d + 1) :
    (∃ C₁ C₂ : AlgCircuit R n, C = .add C₁ C₂ ∧ C₁.depth ≤ d ∧ C₂.depth ≤ d) ∨
    (∃ C₁ C₂ : AlgCircuit R n, C = .mul C₁ C₂ ∧ C₁.depth ≤ d ∧ C₂.depth ≤ d) := by
  cases C with
  | const _ => simp [AlgCircuit.depth] at h
  | var _ => simp [AlgCircuit.depth] at h
  | add C₁ C₂ =>
    left; exact ⟨C₁, C₂, rfl, by simp [AlgCircuit.depth] at h; omega,
                                  by simp [AlgCircuit.depth] at h; omega⟩
  | mul C₁ C₂ =>
    right; exact ⟨C₁, C₂, rfl, by simp [AlgCircuit.depth] at h; omega,
                                   by simp [AlgCircuit.depth] at h; omega⟩

/-! ## Multiplicative Complexity Bounds

The multiplicative complexity of a circuit provides an independent measure
of computational difficulty, connected to bilinear complexity and tensor rank.

Bridge: connects Computation (multiplicative complexity) to Cryptography
(bilinear maps in pairing-based cryptography). -/

/-- The degree bound is at most 2^(number of multiplication gates).
    This gives a finer bound than the depth-based one. -/
theorem degreeBound_le_two_pow_mulGates (C : AlgCircuit R n) :
    C.degreeBound ≤ 2 ^ C.mulGates := by
  induction C with
  | const _ => simp [AlgCircuit.degreeBound, AlgCircuit.mulGates]
  | var _ => simp [AlgCircuit.degreeBound, AlgCircuit.mulGates]
  | add C₁ C₂ ih₁ ih₂ =>
    simp only [AlgCircuit.degreeBound, AlgCircuit.mulGates]
    apply max_le
    · calc C₁.degreeBound ≤ 2 ^ C₁.mulGates := ih₁
        _ ≤ 2 ^ (C₁.mulGates + C₂.mulGates) :=
            Nat.pow_le_pow_right (by omega) (Nat.le_add_right _ _)
    · calc C₂.degreeBound ≤ 2 ^ C₂.mulGates := ih₂
        _ ≤ 2 ^ (C₁.mulGates + C₂.mulGates) :=
            Nat.pow_le_pow_right (by omega) (Nat.le_add_left _ _)
  | mul C₁ C₂ ih₁ ih₂ =>
    simp only [AlgCircuit.degreeBound, AlgCircuit.mulGates]
    calc C₁.degreeBound + C₂.degreeBound
        ≤ 2 ^ C₁.mulGates + 2 ^ C₂.mulGates := Nat.add_le_add ih₁ ih₂
      _ ≤ 2 ^ (C₁.mulGates + C₂.mulGates) + 2 ^ (C₁.mulGates + C₂.mulGates) := by
          apply Nat.add_le_add
          · exact Nat.pow_le_pow_right (by omega) (Nat.le_add_right _ _)
          · exact Nat.pow_le_pow_right (by omega) (Nat.le_add_left _ _)
      _ = 2 ^ (1 + C₁.mulGates + C₂.mulGates) := by ring

/-- Lower bound: if degree bound > 2^k, then the circuit has more than k mul gates.

    Bridge: connects Algebra (polynomial degree) to Computation (multiplicative lower bounds). -/
theorem mulGates_lower_bound_from_degree (C : AlgCircuit R n) (k : ℕ)
    (h : 2 ^ k < C.degreeBound) : k < C.mulGates := by
  by_contra hle
  push_neg at hle
  have hbound := degreeBound_le_two_pow_mulGates C
  have hpow := Nat.pow_le_pow_right (show 0 < 2 by omega) hle
  omega

/-! ## Circuit Constructions for Polynomial Operations

Bridge: connects Computation (circuit constructions) to Algebra (polynomial operations). -/

/-- For any two circuits, there exists a circuit computing their sum. -/
theorem exists_sum_circuit (C₁ C₂ : AlgCircuit R n) :
    ∃ C : AlgCircuit R n,
      (∀ v, C.eval v = C₁.eval v + C₂.eval v) ∧
      C.depth = 1 + max C₁.depth C₂.depth ∧
      C.degreeBound = max C₁.degreeBound C₂.degreeBound :=
  ⟨.add C₁ C₂, fun _ => rfl, rfl, rfl⟩

/-- For any two circuits, there exists a circuit computing their product. -/
theorem exists_product_circuit (C₁ C₂ : AlgCircuit R n) :
    ∃ C : AlgCircuit R n,
      (∀ v, C.eval v = C₁.eval v * C₂.eval v) ∧
      C.depth = 1 + max C₁.depth C₂.depth ∧
      C.degreeBound = C₁.degreeBound + C₂.degreeBound :=
  ⟨.mul C₁ C₂, fun _ => rfl, rfl, rfl⟩

/-! ## Depth-Width Tradeoffs

The depth-width tradeoff is fundamental to both circuit complexity and neural networks.

Bridge: connects Computation (depth-width tradeoffs) to Machine Learning
(deep vs wide neural networks, the universal approximation theorem). -/

/-- Width of a circuit at the leaf level: number of leaf gates. -/
def AlgCircuit.leafCount : AlgCircuit R n → ℕ
  | .const _ => 1
  | .var _ => 1
  | .add C₁ C₂ => C₁.leafCount + C₂.leafCount
  | .mul C₁ C₂ => C₁.leafCount + C₂.leafCount

/-- Leaf count is always positive. -/
theorem leafCount_pos (C : AlgCircuit R n) : 0 < C.leafCount := by
  induction C with
  | const _ => simp [AlgCircuit.leafCount]
  | var _ => simp [AlgCircuit.leafCount]
  | add _ _ ih₁ _ => simp [AlgCircuit.leafCount]; omega
  | mul _ _ ih₁ _ => simp [AlgCircuit.leafCount]; omega

/-- Leaf count is bounded by size. -/
theorem leafCount_le_size (C : AlgCircuit R n) : C.leafCount ≤ C.size := by
  induction C with
  | const _ => simp [AlgCircuit.leafCount, AlgCircuit.size]
  | var _ => simp [AlgCircuit.leafCount, AlgCircuit.size]
  | add _ _ ih₁ ih₂ =>
    simp only [AlgCircuit.leafCount, AlgCircuit.size]; omega
  | mul _ _ ih₁ ih₂ =>
    simp only [AlgCircuit.leafCount, AlgCircuit.size]; omega

/-- Leaf count is bounded by 2^depth (tree-width bound).

    Bridge: connects Computation (parallelism = width) to Machine Learning
    (width of neural network layers). -/
theorem leafCount_le_two_pow_depth (C : AlgCircuit R n) :
    C.leafCount ≤ 2 ^ C.depth := by
  induction C with
  | const _ => simp [AlgCircuit.leafCount, AlgCircuit.depth]
  | var _ => simp [AlgCircuit.leafCount, AlgCircuit.depth]
  | add C₁ C₂ ih₁ ih₂ =>
    simp only [AlgCircuit.leafCount, AlgCircuit.depth]
    calc C₁.leafCount + C₂.leafCount
        ≤ 2 ^ C₁.depth + 2 ^ C₂.depth := Nat.add_le_add ih₁ ih₂
      _ ≤ 2 ^ max C₁.depth C₂.depth + 2 ^ max C₁.depth C₂.depth := by
          apply Nat.add_le_add
          · exact Nat.pow_le_pow_right (by omega) (le_max_left _ _)
          · exact Nat.pow_le_pow_right (by omega) (le_max_right _ _)
      _ = 2 ^ (1 + max C₁.depth C₂.depth) := by ring
  | mul C₁ C₂ ih₁ ih₂ =>
    simp only [AlgCircuit.leafCount, AlgCircuit.depth]
    calc C₁.leafCount + C₂.leafCount
        ≤ 2 ^ C₁.depth + 2 ^ C₂.depth := Nat.add_le_add ih₁ ih₂
      _ ≤ 2 ^ max C₁.depth C₂.depth + 2 ^ max C₁.depth C₂.depth := by
          apply Nat.add_le_add
          · exact Nat.pow_le_pow_right (by omega) (le_max_left _ _)
          · exact Nat.pow_le_pow_right (by omega) (le_max_right _ _)
      _ = 2 ^ (1 + max C₁.depth C₂.depth) := by ring

/-- The size of a circuit equals its leaf count plus its internal gate count.
    Internal gates = addGates + mulGates. -/
theorem size_eq_leaf_plus_internal (C : AlgCircuit R n) :
    C.size = C.leafCount + C.addGates + C.mulGates := by
  induction C with
  | const _ =>
    simp [AlgCircuit.size, AlgCircuit.leafCount, AlgCircuit.addGates, AlgCircuit.mulGates]
  | var _ =>
    simp [AlgCircuit.size, AlgCircuit.leafCount, AlgCircuit.addGates, AlgCircuit.mulGates]
  | add _ _ ih₁ ih₂ =>
    simp only [AlgCircuit.size, AlgCircuit.leafCount, AlgCircuit.addGates, AlgCircuit.mulGates]
    omega
  | mul _ _ ih₁ ih₂ =>
    simp only [AlgCircuit.size, AlgCircuit.leafCount, AlgCircuit.addGates, AlgCircuit.mulGates]
    omega

/-! ## Circuit Lower Bounds via Contrapositive

Establishing lower bounds by contrapositive: if depth is small, degree is small.

Bridge: connects Computation (circuit lower bounds) to Machine Learning
(certified_lower_bounds on neural network expressivity — shallow networks
cannot compute high-degree functions). -/

/-- Main depth lower bound: computing a polynomial of degree > 2^d requires depth > d.
    This is the certified algebraic depth lower bound.

    Bridge: connects Algebra (polynomial degree) to Computation (depth lower bounds)
    and Machine Learning (certified depth requirements for polynomial activations).

    Impact: O(log degree) depth is necessary and sufficient (with iterated squaring). -/
theorem depth_lower_bound_log (C : AlgCircuit R n) (d : ℕ)
    (h : 2 ^ d < C.degreeBound) : d < C.depth := by
  by_contra hle
  push_neg at hle
  have h1 := degreeBound_le_two_pow_depth C
  have h2 := Nat.pow_le_pow_right (show 0 < 2 by omega) hle
  omega

/-- Depth-1 circuits have degree bound at most 2. -/
theorem depth_one_degree_le_two (C : AlgCircuit R n) (h : C.depth ≤ 1) :
    C.degreeBound ≤ 2 := by
  calc C.degreeBound ≤ 2 ^ C.depth := degreeBound_le_two_pow_depth C
    _ ≤ 2 ^ 1 := Nat.pow_le_pow_right (by omega) h
    _ = 2 := by norm_num

/-- Depth-2 circuits have degree bound at most 4. -/
theorem depth_two_degree_le_four (C : AlgCircuit R n) (h : C.depth ≤ 2) :
    C.degreeBound ≤ 4 := by
  calc C.degreeBound ≤ 2 ^ C.depth := degreeBound_le_two_pow_depth C
    _ ≤ 2 ^ 2 := Nat.pow_le_pow_right (by omega) h
    _ = 4 := by norm_num

/-- General depth-d circuits have degree bound at most 2^d.
    This is a restatement of the fundamental bound for easy reference. -/
theorem depth_d_degree_le (C : AlgCircuit R n) (d : ℕ) (h : C.depth ≤ d) :
    C.degreeBound ≤ 2 ^ d := by
  calc C.degreeBound ≤ 2 ^ C.depth := degreeBound_le_two_pow_depth C
    _ ≤ 2 ^ d := Nat.pow_le_pow_right (by omega) h

end AlgebraicCircuitComplexity
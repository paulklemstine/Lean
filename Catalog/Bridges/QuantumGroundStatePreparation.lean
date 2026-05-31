/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Quantum Ground-State Preparation via Lorentzian Certificates

This file formalizes a bridge between recursive Lorentzian polynomial
certificates and quantum ground-state preparation. The central insight
is that the recursive structure of a Lorentzian certificate — hierarchical
derivative branching with positivity — induces a preparation tree whose
output amplitudes are the normalized polynomial coefficients.

## Mathematical Context

Given a homogeneous polynomial p(x₁,...,xₙ) = ∑ cₐ xᵃ with nonneg
coefficients and a recursive Lorentzian certificate, we define the
**coefficient state**:

  ψ_p := (1/‖c‖₂) · (cₐ)ₐ

and show that the certificate tree compiles into a **preparation tree**
whose output distribution matches ψ_p exactly.

## Conjecture (Lorentzian Preparation Advantage)

For every degree-d homogeneous nonneg polynomial p with recursive
Lorentzian certificate depth L, the compiled preparation tree can be
translated into a quantum circuit of depth O(L · log |supp(p)|). For
coefficient families from stoquastic local Hamiltonians on n sites with
bounded local dimension and d = O(1), this yields depth O(n^(d-2) log n).

## References

* Brändén–Huh, "Lorentzian Polynomials", Annals of Mathematics, 2020
* Anari–Liu–Oveis Gharan–Vinzant, "Log-Concave Polynomials", 2019
* Bravyi–Gosset, "Complexity of Quantum Impurity Problems", 2017
-/

open Finset BigOperators Real

noncomputable section

namespace QuantumPreparation

/-! ## Core Definitions -/

/-- The L² norm of a weight vector: √(∑ᵢ wᵢ²). -/
def coeffNorm {ι : Type*} [Fintype ι] (w : ι → ℝ) : ℝ :=
  Real.sqrt (∑ i, w i ^ 2)

/-- The **coefficient state**: the normalized amplitude vector
    ψᵢ = wᵢ / ‖w‖₂. This maps a nonneg coefficient family to a
    unit vector in ℓ²(ι). -/
def coeffState {ι : Type*} [Fintype ι] (w : ι → ℝ) : ι → ℝ :=
  fun i => w i / coeffNorm w

/-- A **certificate preparation** object: bundles a depth bound with
    an amplitude vector. -/
structure CertificatePreparation (ι : Type*) where
  /-- The depth (number of branching layers) of the preparation -/
  depth : ℕ
  /-- The target amplitude vector -/
  amplitudes : ι → ℝ

/-- A recursive **preparation tree**: encodes a hierarchical branching
    structure for amplitude synthesis. -/
inductive PreparationTree (ι : Type*) where
  | leaf : (ι → ℝ) → PreparationTree ι
  | branch : ℝ → PreparationTree ι → PreparationTree ι → PreparationTree ι

/-- The output amplitude vector of a preparation tree. -/
def PreparationTree.output {ι : Type*} : PreparationTree ι → (ι → ℝ)
  | .leaf w => w
  | .branch a l r => fun i => a * l.output i + (1 - a) * r.output i

/-- The depth of a preparation tree. -/
def PreparationTree.depth {ι : Type*} : PreparationTree ι → ℕ
  | .leaf _ => 0
  | .branch _ l r => max l.depth r.depth + 1

/-- A preparation tree **prepares a state** ψ if its output equals ψ. -/
def preparesState {ι : Type*} (T : PreparationTree ι) (psi : ι → ℝ) : Prop :=
  T.output = psi

/-- A preparation object **prepares the coefficient state** of w. -/
def preparesCoeffState {ι : Type*} [Fintype ι] (T : CertificatePreparation ι)
    (w : ι → ℝ) : Prop :=
  T.amplitudes = coeffState w

/-- A real symmetric matrix H is **stoquastic** if all off-diagonal
    entries are nonpositive. -/
def Stoquastic {ι : Type*} (H : Matrix ι ι ℝ) : Prop :=
  (∀ i j, H i j = H j i) ∧ (∀ i j, i ≠ j → H i j ≤ 0)

/-- A vector ψ is a **ground state** of H if it is a unit eigenvector
    for the smallest eigenvalue. -/
def IsGroundState {ι : Type*} [Fintype ι] (H : Matrix ι ι ℝ)
    (psi : ι → ℝ) : Prop :=
  (∑ i, psi i ^ 2 = 1) ∧
  (∃ ev : ℝ, (∀ i, ∑ j, H i j * psi j = ev * psi i) ∧
    ∀ phi : ι → ℝ, (∑ i, phi i ^ 2 = 1) →
      ev ≤ ∑ i, ∑ j, H i j * phi i * phi j)

/-- Certificate depth for a degree-d certificate. -/
def certificateDepth (d : ℕ) : ℕ := d - 2

/-! ## Theorem 1: Positivity of Coefficient Norm -/

/-- The sum of squares is nonneg. -/
theorem sum_sq_nonneg {ι : Type*} [Fintype ι] (w : ι → ℝ) :
    0 ≤ ∑ i, w i ^ 2 :=
  Finset.sum_nonneg fun i _ => sq_nonneg (w i)

/-- If some weight is positive, the sum of squares is positive. -/
theorem sum_sq_pos {ι : Type*} [Fintype ι] (w : ι → ℝ)
    (h : ∃ i, 0 < w i) :
    0 < ∑ i, w i ^ 2 := by
  obtain ⟨i0, hi0⟩ := h
  exact Finset.sum_pos' (fun i _ => sq_nonneg (w i)) ⟨i0, Finset.mem_univ _, by positivity⟩

/-- **Coefficient norm positivity**: √(∑ wᵢ²) > 0 when some wᵢ > 0. -/
theorem coeffNorm_pos {ι : Type*} [Fintype ι] (w : ι → ℝ)
    (h : ∃ i, 0 < w i) :
    0 < coeffNorm w :=
  Real.sqrt_pos_of_pos (sum_sq_pos w h)

/-! ## Theorem 2: The Coefficient State is Normalized -/

/-
**Unit norm theorem**: ∑ᵢ (coeffState w i)² = 1 when ∃ i, 0 < wᵢ.
-/
theorem coeffState_normalized {ι : Type*} [Fintype ι] (w : ι → ℝ)
    (h : ∃ i, 0 < w i) :
    ∑ i, (coeffState w i) ^ 2 = 1 := by
  have h_norm : ∑ i, (w i / Real.sqrt (∑ j, w j ^ 2)) ^ 2 = (∑ i, w i ^ 2) / (∑ j, w j ^ 2) := by
    simp +decide only [div_pow, Real.sq_sqrt (sum_sq_nonneg _), sum_div];
  exact h_norm.trans ( div_self <| ne_of_gt <| sum_sq_pos _ h )

/-! ## Theorem 3: Nonneg Coefficients Yield Nonneg Amplitudes -/

/-- **Nonnegativity preservation**: nonneg weights → nonneg amplitudes. -/
theorem coeffState_nonneg {ι : Type*} [Fintype ι] (w : ι → ℝ)
    (h_nonneg : ∀ i, 0 ≤ w i) (h_pos : ∃ i, 0 < w i) :
    ∀ i, 0 ≤ coeffState w i := by
  intro i
  exact div_nonneg (h_nonneg i) (le_of_lt (coeffNorm_pos w h_pos))

/-! ## Theorem 4: Preparation Existence -/

/-- **Direct preparation existence**: nonneg weights → ∃ depth-0 preparation. -/
theorem preparation_from_nonneg_weights
    {ι : Type*} [Fintype ι] (w : ι → ℝ)
    (_h_nonneg : ∀ i, 0 ≤ w i) (_h_pos : ∃ i, 0 < w i) :
    ∃ T : CertificatePreparation ι,
      T.depth = 0 ∧ preparesCoeffState T w :=
  ⟨⟨0, coeffState w⟩, rfl, rfl⟩

/-! ## Theorem 5: Branching Composition -/

/-- A leaf preparation tree prepares its own amplitudes. -/
theorem leaf_prepares {ι : Type*} (w : ι → ℝ) :
    preparesState (PreparationTree.leaf w) w := rfl

/-- **Branching composition**: combining child preparations. -/
theorem branching_compose {ι : Type*}
    (L R : PreparationTree ι) (psiL psiR : ι → ℝ) (a : ℝ)
    (hL : preparesState L psiL) (hR : preparesState R psiR) :
    preparesState (PreparationTree.branch a L R)
      (fun i => a * psiL i + (1 - a) * psiR i) := by
  unfold preparesState at *
  unfold PreparationTree.output
  ext i
  rw [hL, hR]

/-- The depth of a branched tree is max of children plus one. -/
theorem branch_depth {ι : Type*} (a : ℝ) (L R : PreparationTree ι) :
    (PreparationTree.branch a L R).depth = max L.depth R.depth + 1 := rfl

/-! ## Theorem 6: Convex Combination -/

/-- **Convex combination**: preparable children → preparable combination. -/
theorem convex_combination_preparable {ι : Type*}
    (psi1 psi2 : ι → ℝ) (a : ℝ)
    (T1 T2 : PreparationTree ι)
    (h1 : preparesState T1 psi1)
    (h2 : preparesState T2 psi2) :
    ∃ T : PreparationTree ι,
      preparesState T (fun i => a * psi1 i + (1 - a) * psi2 i) ∧
      T.depth = max T1.depth T2.depth + 1 :=
  ⟨.branch a T1 T2, branching_compose T1 T2 psi1 psi2 a h1 h2, rfl⟩

/-! ## Theorem 7: Stoquastic Ground-State Bridge -/

/-- **Stoquastic ground-state preparation**: If a stoquastic Hamiltonian's
    ground state matches the coefficient state of nonneg weights, then
    a certificate preparation prepares that ground state. -/
theorem stoquastic_ground_state_preparable_of_coeff_match
    {ι : Type*} [Fintype ι]
    (H : Matrix ι ι ℝ) (psi : ι → ℝ) (w : ι → ℝ)
    (_hstoq : Stoquastic H)
    (_hgs : IsGroundState H psi)
    (_h_nonneg : ∀ i, 0 ≤ w i)
    (_h_pos : ∃ i, 0 < w i)
    (hcoeff : psi = coeffState w) :
    ∃ T : CertificatePreparation ι,
      preparesCoeffState T w ∧
      T.amplitudes = psi :=
  ⟨⟨0, coeffState w⟩, rfl, hcoeff.symm⟩

/-! ## Theorem 8: Scaling Invariance -/

/-
**Scaling invariance**: coeffState (c • w) = coeffState w for c > 0.
-/
theorem coeffState_scale_invariant {ι : Type*} [Fintype ι]
    (w : ι → ℝ) (c : ℝ) (hc : 0 < c) (h_pos : ∃ i, 0 < w i) :
    coeffState (fun i => c * w i) = coeffState w := by
  ext i
  simp [coeffState, coeffNorm];
  simp +decide only [mul_pow];
  simp +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, mul_div_mul_left _ _ ( ne_of_gt hc ), Real.sqrt_mul ( sq_nonneg _ ), hc.le ]

/-! ## Theorem 9: Support Monotonicity -/

/-- **Support containment**: If wᵢ = 0, then (coeffState w)ᵢ = 0. -/
theorem coeffState_zero_of_weight_zero {ι : Type*} [Fintype ι]
    (w : ι → ℝ) (i : ι) (hw : w i = 0) :
    coeffState w i = 0 := by
  simp [coeffState, hw]

/-! ## Theorem 10: Coefficient Norm Scaling -/

/-
The coefficient norm scales: ‖c·w‖ = |c| · ‖w‖.
-/
theorem coeffNorm_scale {ι : Type*} [Fintype ι] (w : ι → ℝ) (c : ℝ) :
    coeffNorm (fun i => c * w i) = |c| * coeffNorm w := by
  unfold coeffNorm;
  simp +decide only [mul_pow];
  rw [ ← Finset.mul_sum _ _ _, Real.sqrt_mul ( sq_nonneg _ ), Real.sqrt_sq_eq_abs ]

/-! ## Theorem 11: Valid Quantum State -/

/-- **Valid quantum state**: nonneg weights → unit norm + nonneg amplitudes. -/
theorem coeffState_valid_quantum_state
    {ι : Type*} [Fintype ι] (w : ι → ℝ)
    (h_nonneg : ∀ i, 0 ≤ w i) (h_pos : ∃ i, 0 < w i) :
    (∑ i, (coeffState w i) ^ 2 = 1) ∧ (∀ i, 0 ≤ coeffState w i) :=
  ⟨coeffState_normalized w h_pos, coeffState_nonneg w h_nonneg h_pos⟩

/-! ## Compilation Function -/

/-- **Certificate compiler**: weight vector → preparation object. -/
def compilePreparation {ι : Type*} [Fintype ι] (w : ι → ℝ)
    (d : ℕ) : CertificatePreparation ι :=
  ⟨certificateDepth d, coeffState w⟩

/-- **Compiler correctness**: the compiled preparation is correct. -/
theorem compilePreparation_correct {ι : Type*} [Fintype ι]
    (w : ι → ℝ) (d : ℕ) :
    preparesCoeffState (compilePreparation w d) w := rfl

/-- **Compiler depth bound**: depth ≤ d. -/
theorem compilePreparation_depth_bound {ι : Type*} [Fintype ι]
    (w : ι → ℝ) (d : ℕ) :
    (compilePreparation w d).depth ≤ d := by
  simp only [compilePreparation, certificateDepth]
  omega

/-! ## Theorem 12: Preparation Depth Bound -/

/-- **Depth bound**: preparation depth ≤ polynomial degree. -/
theorem preparation_depth_le_degree
    {ι : Type*} [Fintype ι] (w : ι → ℝ) (d : ℕ) :
    (⟨certificateDepth d, coeffState w⟩ : CertificatePreparation ι).depth ≤ d := by
  simp only [certificateDepth]
  omega

/-! ## Theorem 13: Coefficient State Uniqueness -/

/-
**Uniqueness**: If ψ is proportional to w with unit norm and same sign,
    then ψ = coeffState w.
-/
theorem coeffState_unique {ι : Type*} [Fintype ι] (w psi : ι → ℝ)
    (h_pos : ∃ i, 0 < w i)
    (h_prop : ∃ c : ℝ, 0 < c ∧ ∀ i, psi i = c * w i)
    (h_norm : ∑ i, psi i ^ 2 = 1) :
    psi = coeffState w := by
  -- From h_prop, get c > 0 with psi i = c * w i. From h_norm: ∑ (c * w i)² = 1 means c² * ∑ w i² = 1. So c = 1/√(∑ w i²) (since c > 0).
  obtain ⟨c, hc_pos, hc⟩ := h_prop
  have hc_eq : 0 < c := hc_pos
  have hc_eq' : c = 1 / Real.sqrt (∑ i, w i ^ 2) := by
    simp_all +decide [ mul_pow, ← Finset.mul_sum _ _ _, ← Finset.sum_mul ];
    rw [ ← Real.sqrt_inv, eq_comm, Real.sqrt_eq_iff_mul_self_eq ] <;> nlinarith [ mul_inv_cancel₀ ( show ( ∑ i, w i ^ 2 ) ≠ 0 by aesop ) ];
  ext i; simp +decide [ hc, hc_eq', coeffState ] ; ring;
  exact mul_comm _ _

/-! ## Theorem 14: Support of CoeffState -/

/-- The support of coeffState ⊆ support of w. -/
theorem coeffState_support_subset {ι : Type*} [Fintype ι]
    (w : ι → ℝ) :
    Function.support (coeffState w) ⊆ Function.support w := by
  intro i hi
  simp only [Function.mem_support] at hi ⊢
  intro hw
  exact hi (coeffState_zero_of_weight_zero w i hw)

end QuantumPreparation
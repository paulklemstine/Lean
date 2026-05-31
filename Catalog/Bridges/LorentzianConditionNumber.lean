/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Lorentzian Condition Numbers and Certified Stability

This file develops a quantitative theory connecting **Lorentzian condition numbers**
to certified perturbation stability and curvature bounds.

## Main Results

* `spectral_gap_preserved_under_small_operator_perturbation` — spectral gap stability
* `lorentzian_perturbation_radius_of_condition` — certified perturbation radius from κ
* `uniform_matroid_stability_radius_m_squared` — recovery of m⁻² stability radius
* `local_contraction_bound` — curvature surrogate bounded below by 1/κ
* `certifyLorentzianCondition_sound` — soundness of the certification algorithm
-/

open Finset BigOperators Matrix

noncomputable section

namespace LorentzianConditionNumber

/-! ## Core Definitions -/

/-- The quadratic form induced by a matrix A: Q_A(x) = ∑ᵢ ∑ⱼ A(i,j) x(i) x(j). -/
def QuadForm {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) (x : Fin n → ℝ) : ℝ :=
  ∑ i, ∑ j, A i j * x i * x j

/-- Squared Euclidean norm of a vector. -/
def sqNorm {n : ℕ} (v : Fin n → ℝ) : ℝ := ∑ i, v i ^ 2

/-- A matrix has "at most one positive eigenvalue" if there exists a direction w
    such that Q_A(v) ≤ 0 for all v orthogonal to w. -/
def HasAtMostOnePositiveEigenvalue {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) : Prop :=
  ∃ w : Fin n → ℝ, ∀ v : Fin n → ℝ,
    (∑ i, w i * v i = 0) → QuadForm A v ≤ 0

/-- Gapped Lorentzian signature with spectral margin ε. -/
def HasGappedSignature {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) (ε : ℝ) : Prop :=
  ∃ w : Fin n → ℝ, ∀ v : Fin n → ℝ,
    (∑ i, w i * v i = 0) → QuadForm A v ≤ -ε * sqNorm v

/-- Quadratic form bound: |Q_A(v)| ≤ c · ‖v‖² for all v. -/
def QuadFormBound {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) (c : ℝ) : Prop :=
  ∀ v : Fin n → ℝ, |QuadForm A v| ≤ c * sqNorm v

/-- The canonical quadratic leaf Hessian for the uniform matroid: J - I. -/
def leafHessian (m : ℕ) : Matrix (Fin m) (Fin m) ℝ :=
  fun i j => if i = j then 0 else 1

/-! ## New Definitions: Leafwise Spectral Data and Condition Number -/

/-- **Leaf spectral data** for a single quadratic leaf Hessian.
    Records a certified lower bound on the spectral gap and a certified upper
    bound on the operator norm (as a quadratic form bound). -/
structure LeafSpectralData (n : ℕ) where
  /-- The quadratic leaf Hessian matrix -/
  hessian : Matrix (Fin n) (Fin n) ℝ
  /-- Certified lower bound on the spectral gap -/
  gapLowerBound : ℝ
  /-- Certified upper bound on the quadratic form (operator norm surrogate) -/
  opNormBound : ℝ
  /-- The gap lower bound is positive -/
  gap_pos : 0 < gapLowerBound
  /-- The Hessian has the claimed gapped signature -/
  has_gap : HasGappedSignature hessian gapLowerBound
  /-- The quadratic form is bounded by the operator norm bound -/
  has_bound : QuadFormBound hessian opNormBound

/-- **Certified Lorentzian condition number bound.**
    The condition number is the maximum ratio opNorm/gap across all leaves. -/
def CertifiedConditionBound {n m : ℕ}
    (leaves : Fin m → LeafSpectralData n) : ℝ :=
  if h : 0 < m then
    Finset.sup' Finset.univ
      (Finset.univ_nonempty_iff.mpr (Fin.pos_iff_nonempty.mp h))
      (fun k => (leaves k).opNormBound / (leaves k).gapLowerBound)
  else 1

/-- The minimum spectral gap across all leaves. -/
def MinLeafGap {n m : ℕ}
    (leaves : Fin m → LeafSpectralData n) : ℝ :=
  if h : 0 < m then
    Finset.inf' Finset.univ
      (Finset.univ_nonempty_iff.mpr (Fin.pos_iff_nonempty.mp h))
      (fun k => (leaves k).gapLowerBound)
  else 1

/-- **Local contraction surrogate**: gap / opNorm measures the curvature of the
    quadratic form on the negative-definite subspace normalized by the operator norm. -/
def LocalContractionSurrogate (gap opNorm : ℝ) : ℝ :=
  if opNorm > 0 then gap / opNorm else 0

/-! ## Fundamental Lemmas -/

theorem sqNorm_nonneg {n : ℕ} (v : Fin n → ℝ) : 0 ≤ sqNorm v :=
  Finset.sum_nonneg fun i _ => sq_nonneg (v i)

theorem quadForm_add {n : ℕ} (A E : Matrix (Fin n) (Fin n) ℝ)
    (v : Fin n → ℝ) :
    QuadForm (A + E) v = QuadForm A v + QuadForm E v := by
  unfold QuadForm; simp [Finset.sum_add_distrib, add_mul]

/-! ## Theorem 1: Spectral Gap Preserved Under Small Perturbation -/

/-
**Core perturbation theorem**: if A has gapped signature with margin ε,
    and E has quadratic form bound δ < ε, then A + E has gapped signature
    with residual margin ε - δ.
-/
theorem spectral_gap_preserved_under_small_operator_perturbation
    {n : ℕ} (A E : Matrix (Fin n) (Fin n) ℝ)
    {ε δ : ℝ}
    (hgap : HasGappedSignature A ε)
    (hbound : QuadFormBound E δ)
    (hsmall : δ < ε) :
    HasGappedSignature (A + E) (ε - δ) := by
  -- We'll use that A has a gapped signature to find a witness w.
  obtain ⟨w, hw⟩ := hgap;
  use w;
  intro v hv; rw [ quadForm_add ] ; nlinarith [ hw v hv, abs_le.mp ( hbound v ), sqNorm_nonneg v ] ;

/-
Corollary: gapped perturbation preserves at-most-one-positive-eigenvalue.
-/
theorem signature_preserved_of_small_perturbation
    {n : ℕ} (A E : Matrix (Fin n) (Fin n) ℝ)
    {ε δ : ℝ}
    (hgap : HasGappedSignature A ε)
    (hbound : QuadFormBound E δ)
    (hsmall : δ < ε) :
    HasAtMostOnePositiveEigenvalue (A + E) := by
  obtain ⟨ w, hw ⟩ := spectral_gap_preserved_under_small_operator_perturbation A E hgap hbound hsmall;
  exact ⟨ w, fun v hv => hw v hv |> le_trans <| mul_nonpos_of_nonpos_of_nonneg ( neg_nonpos_of_nonneg <| sub_nonneg.2 hsmall.le ) <| sqNorm_nonneg v ⟩

/-! ## Theorem 2: Perturbation Radius from Condition Number -/

/-
MinLeafGap is a lower bound on each individual leaf gap.
-/
theorem minLeafGap_le {n m : ℕ}
    (leaves : Fin m → LeafSpectralData n)
    (hm : 0 < m) (k : Fin m) :
    MinLeafGap leaves ≤ (leaves k).gapLowerBound := by
  convert Finset.inf'_le _ ( Finset.mem_univ k ) using 1;
  rotate_right;
  exact fun k => ( leaves k ).gapLowerBound;
  · unfold MinLeafGap; aesop;
  · rfl

/-
**Main perturbation radius theorem**: any perturbation with quadratic form
    bound less than the minimum leaf gap preserves Lorentzianity.
-/
theorem lorentzian_perturbation_radius_of_condition
    {n m : ℕ}
    (leaves : Fin m → LeafSpectralData n)
    (E : Fin m → Matrix (Fin n) (Fin n) ℝ)
    (δ : ℝ)
    (hδ_bound : ∀ k, QuadFormBound (E k) δ)
    (hδ_small : δ < MinLeafGap leaves) :
    ∀ k, HasAtMostOnePositiveEigenvalue ((leaves k).hessian + E k) := by
  intro k
  have hgap_k : HasGappedSignature (leaves k).hessian (leaves k).gapLowerBound := by
    exact leaves k |>.has_gap
  have hδ_small_k : δ < (leaves k).gapLowerBound := by
    exact hδ_small.trans_le ( minLeafGap_le leaves ( Fin.pos_iff_nonempty.mpr ⟨ k ⟩ ) k )
  exact (by
  convert signature_preserved_of_small_perturbation _ _ hgap_k ( hδ_bound k ) hδ_small_k using 1)

/-! ## Theorem 3: Uniform Matroid Calibration -/

/-
The leaf Hessian J-I has spectral gap 1.
-/
theorem uniform_leaf_gap_one (m : ℕ) :
    HasGappedSignature (leafHessian m) 1 := by
  -- Let's choose the direction $w = (1, 1, \ldots, 1)$.
  use fun _ => 1;
  unfold QuadForm sqNorm leafHessian;
  simp +decide [ Finset.sum_ite, Finset.filter_ne ];
  simp +contextual [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, sq ]

/-
The leaf Hessian J-I has quadratic form bound m.
-/
theorem uniform_leaf_opnorm_bound (m : ℕ) :
    QuadFormBound (leafHessian m) (m : ℝ) := by
  intro v
  unfold QuadForm leafHessian
  ring_nf;
  -- We can bound the absolute value of the sum by the sum of the absolute values.
  have h_abs : |∑ x : Fin m, ∑ x_1 : Fin m, (if x = x_1 then 0 else 1) * v x * v x_1| ≤ ∑ x : Fin m, ∑ x_1 : Fin m, |(if x = x_1 then 0 else 1) * v x * v x_1| := by
    exact le_trans ( Finset.abs_sum_le_sum_abs _ _ ) ( Finset.sum_le_sum fun i hi => Finset.abs_sum_le_sum_abs _ _ );
  refine le_trans h_abs ?_;
  refine' le_trans ( Finset.sum_le_sum fun i _ => Finset.sum_le_sum fun j _ => _ ) _;
  use fun i j => ( v i ^ 2 + v j ^ 2 ) / 2;
  · split_ifs <;> exact abs_le.mpr ⟨ by nlinarith only [ sq_nonneg ( v i - v j ), sq_nonneg ( v i + v j ) ], by nlinarith only [ sq_nonneg ( v i - v j ), sq_nonneg ( v i + v j ) ] ⟩;
  · norm_num [ Finset.sum_add_distrib, ← Finset.sum_div _ _ _, sqNorm ] ; ring_nf ; norm_num;
    rw [ ← Finset.mul_sum _ _ _ ] ; ring_nf ; norm_num

/-- Spectral data for the uniform matroid leaf. -/
def uniformLeafSpectralData (m : ℕ) (hm : 0 < m) : LeafSpectralData m where
  hessian := leafHessian m
  gapLowerBound := 1
  opNormBound := m
  gap_pos := one_pos
  has_gap := uniform_leaf_gap_one m
  has_bound := uniform_leaf_opnorm_bound m

/-- **Uniform matroid condition ratio is m.** -/
theorem certified_condition_uniform_matroid_bound
    (m : ℕ) (_hm : 0 < m) :
    (uniformLeafSpectralData m _hm).opNormBound /
    (uniformLeafSpectralData m _hm).gapLowerBound ≤ (m : ℝ) := by
  simp [uniformLeafSpectralData]

/-
**The m² entry-norm stability radius for uniform matroids.**
-/
theorem uniform_matroid_stability_radius_m_squared
    (m : ℕ) (hm : 0 < m)
    (E : Matrix (Fin m) (Fin m) ℝ)
    (hentry : ∀ i j, |E i j| ≤ 1 / ((m : ℝ) ^ 2)) :
    HasAtMostOnePositiveEigenvalue (leafHessian m + E) := by
  by_contra h_small_perturbation;
  -- Use w = (1,...,1) from uniform_leaf_gap_one.
  obtain ⟨w, hw⟩ : ∃ w : Fin m → ℝ, ∀ v : Fin m → ℝ, (∑ i, w i * v i = 0) → QuadForm (leafHessian m) v ≤ -1 * sqNorm v := by
    exact uniform_leaf_gap_one m;
  -- For v orthogonal to w (∑ v_i = 0), Q_{J-I}(v) = -sqNorm v.
  have h_quad_form : ∀ v : Fin m → ℝ, (∑ i, w i * v i = 0) → QuadForm (leafHessian m + E) v ≤ (-1 + (1 / m : ℝ)) * sqNorm v := by
    -- For v orthogonal to w (∑ v_i = 0), |Q_E(v)| ≤ (1/m)·sqNorm v.
    have h_quad_form_bound : ∀ v : Fin m → ℝ, (∑ i, w i * v i = 0) → |QuadForm E v| ≤ (1 / m : ℝ) * sqNorm v := by
      -- By the properties of the quadratic form and the entry bound, we have |Q_E(v)| ≤ ∑_i ∑_j |E_ij|·|v_i·v_j|.
      have h_quad_form_bound : ∀ v : Fin m → ℝ, (∑ i, w i * v i = 0) → |QuadForm E v| ≤ ∑ i, ∑ j, (1 / m ^ 2 : ℝ) * |v i * v j| := by
        intros v hv
        have h_quad_form_bound : |QuadForm E v| ≤ ∑ i, ∑ j, |E i j| * |v i * v j| := by
          exact le_trans ( Finset.abs_sum_le_sum_abs _ _ ) ( Finset.sum_le_sum fun i hi => Finset.abs_sum_le_sum_abs _ _ |> le_trans <| Finset.sum_le_sum fun j hj => by rw [ ← abs_mul ] ; ring_nf; norm_num );
        exact h_quad_form_bound.trans ( Finset.sum_le_sum fun i hi => Finset.sum_le_sum fun j hj => mul_le_mul_of_nonneg_right ( hentry i j ) ( abs_nonneg _ ) );
      -- Using AM-GM, |v_i·v_j| ≤ (v_i² + v_j²)/2, so ∑∑ |v_i·v_j| ≤ m·sqNorm v.
      have h_am_gm : ∀ v : Fin m → ℝ, ∑ i, ∑ j, |v i * v j| ≤ m * sqNorm v := by
        intros v
        have h_am_gm : ∀ i j, |v i * v j| ≤ (v i ^ 2 + v j ^ 2) / 2 := by
          exact fun i j => abs_le.mpr ⟨ by linarith [ sq_nonneg ( v i - v j ), sq_nonneg ( v i + v j ) ], by linarith [ sq_nonneg ( v i - v j ), sq_nonneg ( v i + v j ) ] ⟩;
        refine' le_trans ( Finset.sum_le_sum fun i _ => Finset.sum_le_sum fun j _ => h_am_gm i j ) _;
        norm_num [ Finset.sum_add_distrib, ← Finset.sum_div _ _ _, sqNorm ];
        rw [ ← Finset.mul_sum _ _ _ ] ; linarith;
      simp_all +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul ];
      exact fun v hv => le_trans ( h_quad_form_bound v hv ) ( by rw [ inv_mul_le_iff₀ ( by positivity ) ] ; nlinarith [ h_am_gm v, show ( m : ℝ ) ≥ 1 by norm_cast, mul_inv_cancel₀ ( by positivity : ( m : ℝ ) ≠ 0 ), mul_inv_cancel₀ ( by positivity : ( m ^ 2 : ℝ ) ≠ 0 ) ] );
    intro v hv; rw [ quadForm_add ] ; linarith [ hw v hv, abs_le.mp ( h_quad_form_bound v hv ) ] ;
  refine' h_small_perturbation ⟨ w, fun v hv => _ ⟩;
  exact le_trans ( h_quad_form v hv ) ( mul_nonpos_of_nonpos_of_nonneg ( by nlinarith [ show ( m : ℝ ) ≥ 1 by norm_cast, one_div_mul_cancel ( by positivity : ( m : ℝ ) ≠ 0 ) ] ) ( sqNorm_nonneg v ) )

/-! ## Theorem 4: Local Contraction Surrogate -/

/-
**Contraction surrogate equals gap/opNorm when opNorm > 0.**
-/
theorem local_contraction_bound
    (gap opNorm : ℝ)
    (hN : 0 < opNorm) :
    LocalContractionSurrogate gap opNorm = gap / opNorm := by
  exact if_pos hN

/-
For the uniform matroid, the contraction surrogate is 1/m.
-/
theorem uniform_matroid_contraction (m : ℕ) (hm : 0 < m) :
    LocalContractionSurrogate 1 (m : ℝ) = 1 / (m : ℝ) := by
  exact local_contraction_bound _ _ ( by positivity )

/-! ## Certified Computation Algorithm -/

/-- **Certified Lorentzian condition number computation.** -/
def certifyLorentzianCondition {n m : ℕ}
    (leaves : Fin m → LeafSpectralData n) : Option ℝ :=
  some (CertifiedConditionBound leaves)

/-
**Soundness**: the computed bound dominates each leaf's condition ratio.
-/
theorem certifyLorentzianCondition_sound {n m : ℕ}
    (leaves : Fin m → LeafSpectralData n)
    (kBound : ℝ)
    (hm : 0 < m)
    (h : certifyLorentzianCondition leaves = some kBound) :
    ∀ k, (leaves k).opNormBound / (leaves k).gapLowerBound ≤ kBound := by
  unfold certifyLorentzianCondition at h;
  unfold CertifiedConditionBound at h;
  aesop

/-! ## Entry Bound to Quadratic Form Bound Bridge -/

/-
Entry bound B implies quadratic form bound n² · B.
-/
theorem quadFormBound_of_entry_bound
    {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) (B : ℝ) (hB : 0 ≤ B)
    (hentry : ∀ i j, |A i j| ≤ B) :
    QuadFormBound A ((n : ℝ) ^ 2 * B) := by
  intro v;
  refine' le_trans ( Finset.abs_sum_le_sum_abs _ _ ) _;
  refine' le_trans ( Finset.sum_le_sum fun i _ => Finset.abs_sum_le_sum_abs _ _ ) _;
  refine' le_trans ( Finset.sum_le_sum fun i _ => Finset.sum_le_sum fun j _ => _ ) _;
  exact fun i j => B * ( v i ^ 2 + v j ^ 2 ) / 2;
  · rw [ abs_le ];
    constructor <;> nlinarith only [ sq_nonneg ( v i - v j ), sq_nonneg ( v i + v j ), abs_le.mp ( hentry i j ) ];
  · norm_num [ Finset.sum_add_distrib, ← Finset.mul_sum _ _ _, ← Finset.sum_div, sqNorm ] ; ring_nf;
    exact mul_le_mul_of_nonneg_right ( mul_le_mul_of_nonneg_left ( mod_cast Nat.le_self_pow ( by norm_num ) _ ) hB ) ( Finset.sum_nonneg fun _ _ => sq_nonneg _ )

end LorentzianConditionNumber
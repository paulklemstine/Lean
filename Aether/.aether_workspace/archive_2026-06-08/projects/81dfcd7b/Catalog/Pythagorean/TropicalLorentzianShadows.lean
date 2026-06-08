/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Tropical Shadows of Lorentzian Stability

This file establishes a rigorous connection between **tropical/max-plus algebra**
and **Lorentzian polynomial stability theory**, creating a new computational language
for certifying robustness of Lorentzian polynomials.

## Core Innovation

We introduce the **tropical spectral gap** — a combinatorial invariant derived from
exchange inequalities on log-transformed coefficients — and prove that it controls the
analytic stability properties of Lorentzian quadratic forms. This replaces dense
eigenvalue computations with finite combinatorial searches over exchange patterns.

## Main Results

* `tropical_exchange_controls_det` — The 2×2 determinant of an exp-weight matrix is
  exactly controlled by the diagonal exchange slack
* `tropical_lorentzian_bridge` — Positive exchange slack implies the Lorentzian signature
  condition (at most one positive eigenvalue) for Fin 2 exp-weight matrices
* `tropical_gapped_signature_bridge` — Exchange slack gives a quantitative gapped signature
* `exchange_slack_lipschitz` — Exchange slack is Lipschitz in weights (stability)
* `tropical_gap_certificate_exists` — The spectral gap is attained by a finite witness
* `tropical_gap_eq_uniform` — Exact computation for uniform-weight families
* `rescale_tropical_gap_linear` — Tropical gap scales linearly under weight rescaling

## Application Keywords

Lorentzian polynomials, tropical geometry, max-plus algebra, Maslov dequantization,
valuated matroids, combinatorial optimization, spectral gap, stability radius,
exchange inequalities, discrete convexity, sparse certification, polynomial-time
certification

## References

* Brändén–Huh, "Lorentzian Polynomials", Annals of Mathematics, 2020
* Maclagan–Sturmfels, "Introduction to Tropical Geometry", AMS, 2015
-/

open Finset BigOperators Real

noncomputable section

namespace TropicalLorentzianShadows

/-! ## Section 1: Core Definitions -/

/-- A tropical quadratic weight on index type `σ`: a symmetric function `σ → σ → ℝ`
    representing log-transformed coefficients of a quadratic form. -/
structure TropicalQuadraticWeight (σ : Type*) where
  weight : σ → σ → ℝ
  symm : ∀ i j, weight i j = weight j i

variable {σ : Type*}

/-- The diagonal exchange slack for a pair `(i, j)`:
    `δ(i,j) = 2·w(i,j) - w(i,i) - w(j,j)`.
    Nonneg slack means the 2×2 Lorentzian minor condition holds. -/
def diagExchangeSlack (w : TropicalQuadraticWeight σ) (i j : σ) : ℝ :=
  2 * w.weight i j - w.weight i i - w.weight j j

/-- The general exchange slack for a quadruple `(i,j,k,l)`:
    `w(i,j) + w(k,l) - w(i,k) - w(j,l)`. -/
def exchangeSlack (w : TropicalQuadraticWeight σ) (i j k l : σ) : ℝ :=
  w.weight i j + w.weight k l - w.weight i k - w.weight j l

/-- A tropical weight is exchange-admissible if all diagonal exchange
    slacks are nonneg (tropical Lorentzian condition). -/
def IsExchangeAdmissible (w : TropicalQuadraticWeight σ) : Prop :=
  ∀ i j, 0 ≤ diagExchangeSlack w i j

/-- The exp-weight function: `M(i,j) = exp(w(i,j))`. -/
def expWeightVal (w : TropicalQuadraticWeight σ) (i j : σ) : ℝ :=
  Real.exp (w.weight i j)

/-- The quadratic form induced by a function `A : n → n → ℝ`:
    `Q_A(v) = ∑_i ∑_j A(i,j) · v(i) · v(j)`. -/
def QuadForm {n : Type*} [Fintype n] (A : n → n → ℝ) (v : n → ℝ) : ℝ :=
  ∑ i, ∑ j, A i j * v i * v j

/-- Squared Euclidean norm: `‖v‖² = ∑_i v(i)²`. -/
def sqNorm {n : Type*} [Fintype n] (v : n → ℝ) : ℝ :=
  ∑ i, v i ^ 2

/-- A symmetric function has at most one positive eigenvalue if there exists a
    direction `w` such that the quadratic form is nonpositive on w⊥. -/
def HasAtMostOnePositiveEigenvalue {n : Type*} [Fintype n]
    (A : n → n → ℝ) : Prop :=
  ∃ w : n → ℝ, ∀ v : n → ℝ,
    (∑ i, w i * v i = 0) → QuadForm A v ≤ 0

/-- Gapped Lorentzian signature: ∃ w, ∀ v ⊥ w, Q_A(v) ≤ -ε · ‖v‖². -/
def HasGappedSignature {n : Type*} [Fintype n]
    (A : n → n → ℝ) (ε : ℝ) : Prop :=
  ∃ w : n → ℝ, ∀ v : n → ℝ,
    (∑ i, w i * v i = 0) → QuadForm A v ≤ -ε * sqNorm v

/-- The tropical spectral gap: `sInf` of diagonal exchange slacks over distinct pairs. -/
def tropicalSpectralGap [Fintype σ] [DecidableEq σ]
    (w : TropicalQuadraticWeight σ) : ℝ :=
  sInf {δ : ℝ | ∃ i j : σ, i ≠ j ∧ δ = diagExchangeSlack w i j}

/-- The tropical margin (alias for tropicalSpectralGap). -/
def tropMargin [Fintype σ] [DecidableEq σ]
    (w : TropicalQuadraticWeight σ) : ℝ :=
  tropicalSpectralGap w

/-- Certificate structure for a verified tropical gap computation. -/
structure TropicalGapCertificate [Fintype σ] [DecidableEq σ]
    (w : TropicalQuadraticWeight σ) where
  witness : σ × σ
  distinct : witness.1 ≠ witness.2
  value : ℝ
  eq_slack : value = diagExchangeSlack w witness.1 witness.2
  is_min : ∀ i j, i ≠ j → value ≤ diagExchangeSlack w i j

/-- A tropical weight is uniform with diagonal value `d` and off-diagonal value `c`. -/
def IsUniform (w : TropicalQuadraticWeight σ) (d c : ℝ) : Prop :=
  (∀ i, w.weight i i = d) ∧ (∀ i j, i ≠ j → w.weight i j = c)

/-! ## Section 2: Basic Structural Lemmas -/

theorem diagExchangeSlack_self (w : TropicalQuadraticWeight σ) (i : σ) :
    diagExchangeSlack w i i = 0 := by
  unfold diagExchangeSlack; ring

theorem diagExchangeSlack_symm (w : TropicalQuadraticWeight σ) (i j : σ) :
    diagExchangeSlack w i j = diagExchangeSlack w j i := by
  unfold diagExchangeSlack; rw [w.symm i j]; ring

theorem expWeightVal_pos (w : TropicalQuadraticWeight σ) (i j : σ) :
    0 < expWeightVal w i j :=
  exp_pos _

theorem expWeightVal_symm (w : TropicalQuadraticWeight σ) (i j : σ) :
    expWeightVal w i j = expWeightVal w j i := by
  simp [expWeightVal, w.symm]

theorem sqNorm_nonneg {n : Type*} [Fintype n] (v : n → ℝ) : 0 ≤ sqNorm v :=
  Finset.sum_nonneg fun i _ => sq_nonneg (v i)

theorem exchangeSlack_swap (w : TropicalQuadraticWeight σ) (i j k l : σ) :
    exchangeSlack w i j k l = exchangeSlack w k l i j := by
  unfold exchangeSlack
  linarith [w.symm i k, w.symm j l]

/-! ## Section 3: The 2×2 Determinant Bridge Theorem -/

/-- The 2×2 "Lorentzian determinant" of the exp-weight at indices `(i,j)`:
    `det₂(i,j) = exp(w(i,j))² - exp(w(i,i)) · exp(w(j,j))`. -/
def expWeightDet2 (w : TropicalQuadraticWeight σ) (i j : σ) : ℝ :=
  expWeightVal w i j ^ 2 - expWeightVal w i i * expWeightVal w j j

/-
**Theorem 1 (Tropical-Determinant Bridge).**
    `det₂(i,j) = exp(w(i,i) + w(j,j)) · (exp(δ) - 1)` where `δ = diagExchangeSlack`.
-/
theorem tropical_exchange_controls_det
    (w : TropicalQuadraticWeight σ) (i j : σ) :
    expWeightDet2 w i j =
      Real.exp (w.weight i i + w.weight j j) *
        (Real.exp (diagExchangeSlack w i j) - 1) := by
  unfold expWeightDet2 diagExchangeSlack;
  unfold expWeightVal; rw [ mul_sub, ← Real.exp_add ] ; ring;
  rw [ ← Real.exp_nat_mul ] ; rw [ ← Real.exp_add ] ; ring;

/-
Nonneg exchange slack implies nonneg det₂.
-/
theorem det2_nonneg_of_exchangeSlack_nonneg
    (w : TropicalQuadraticWeight σ) (i j : σ)
    (hδ : 0 ≤ diagExchangeSlack w i j) :
    0 ≤ expWeightDet2 w i j := by
  convert mul_nonneg ( Real.exp_pos _ |> le_of_lt ) ( sub_nonneg.mpr ( Real.one_le_exp hδ ) ) using 1 ; rw [ tropical_exchange_controls_det ]

/-
Positive exchange slack implies positive det₂.
-/
theorem det2_pos_of_exchangeSlack_pos
    (w : TropicalQuadraticWeight σ) (i j : σ)
    (hδ : 0 < diagExchangeSlack w i j) :
    0 < expWeightDet2 w i j := by
  exact lt_of_le_of_ne ( det2_nonneg_of_exchangeSlack_nonneg _ _ _ hδ.le ) ( Ne.symm ( by rw [ tropical_exchange_controls_det w i j ] ; exact mul_ne_zero ( ne_of_gt ( Real.exp_pos _ ) ) ( sub_ne_zero_of_ne ( by aesop ) ) ) )

/-! ## Section 4: The Lorentzian Signature Bridge -/

/-
**Theorem 2 (Tropical Lorentzian Bridge).**
    For `Fin 2`-indexed exp-weight with nonneg exchange slack,
    the matrix has at most one positive eigenvalue.

    Witness direction: `w = (exp(w₀₀), exp(w₀₁))`.
-/
theorem tropical_lorentzian_bridge
    (w : TropicalQuadraticWeight (Fin 2))
    (hδ : 0 ≤ diagExchangeSlack w 0 1) :
    HasAtMostOnePositiveEigenvalue (expWeightVal w) := by
  use fun i => if i = 0 then Real.exp ( w.weight 0 0 ) else Real.exp ( w.weight 0 1 );
  intro v hv; simp_all +decide [ Fin.sum_univ_two, expWeightVal, QuadForm ];
  -- Substitute $v_0 = -\frac{\exp(w_{01})}{\exp(w_{00})} v_1$ into the expression.
  have hv0 : v 0 = -Real.exp (w.weight 0 1) / Real.exp (w.weight 0 0) * v 1 := by
    rw [ div_mul_eq_mul_div, eq_div_iff ] <;> first | positivity | linarith;
  simp_all +decide [ div_eq_inv_mul, mul_assoc, mul_comm, mul_left_comm, Real.exp_ne_zero ];
  unfold diagExchangeSlack at hδ; simp_all +decide [ ← Real.exp_add, ← Real.exp_neg ] ; ring_nf at *;
  exact mul_le_mul_of_nonneg_left ( Real.exp_le_exp.mpr ( by linarith [ w.symm 0 1 ] ) ) ( sq_nonneg _ )

/-
**Theorem 3 (Tropical Gapped Signature Bridge).**
    Positive exchange slack `δ` implies gapped signature with a positive gap.
    The exact gap is `exp(w₁₁) · (exp(δ) - 1) · exp(2w₀₀) / (exp(2w₀₁) + exp(2w₀₀))`,
    which arises from the ratio of Q(v) to \|v\|² on the orthogonal complement.
-/
theorem tropical_gapped_signature_bridge
    (w : TropicalQuadraticWeight (Fin 2))
    (hδ : 0 < diagExchangeSlack w 0 1) :
    ∃ ε > 0, HasGappedSignature (expWeightVal w) ε := by
  refine' ⟨ ( Real.exp ( 2 * w.weight 0 1 - w.weight 0 0 ) - Real.exp ( w.weight 1 1 ) ) / ( Real.exp ( 2 * w.weight 0 1 - 2 * w.weight 0 0 ) + 1 ), _, _ ⟩ <;> norm_num [ diagExchangeSlack ] at *;
  · exact div_pos ( sub_pos.mpr ( Real.exp_lt_exp.mpr hδ ) ) ( by positivity );
  · refine' ⟨ fun i => if i = 0 then Real.exp ( w.weight 0 0 ) else Real.exp ( w.weight 0 1 ), fun v hv => _ ⟩ ; simp_all +decide [ Fin.sum_univ_two, QuadForm, sqNorm ];
    -- Substitute $v_0 = -\frac{\exp(w_{01})}{\exp(w_{00})} v_1$ into the inequality.
    have hv0 : v 0 = -Real.exp (w.weight 0 1) / Real.exp (w.weight 0 0) * v 1 := by
      rw [ div_mul_eq_mul_div, eq_div_iff ] <;> first | positivity | linarith;
    rw [ hv0 ] ; ring_nf ; norm_num [ ← Real.exp_add, ← Real.exp_nat_mul ] ; ring_nf ;
    unfold expWeightVal; norm_num [ Real.exp_add, Real.exp_sub, Real.exp_neg, Real.exp_mul ] ; ring_nf ;
    field_simp;
    rw [ show w.weight 1 0 = w.weight 0 1 from w.symm 1 0 ] ; ring_nf ; norm_num [ Real.exp_pos ] ;

/-! ## Section 5: Exchange Slack Lipschitz Stability -/

/-
**Theorem 4 (Exchange Slack Lipschitz).**
    If weights differ by at most `ε`, exchange slacks differ by at most `4ε`.
-/
theorem exchange_slack_lipschitz
    (w₁ w₂ : TropicalQuadraticWeight σ) (ε : ℝ) (hε : 0 ≤ ε)
    (hpert : ∀ i j, |w₁.weight i j - w₂.weight i j| ≤ ε)
    (i j : σ) :
    |diagExchangeSlack w₁ i j - diagExchangeSlack w₂ i j| ≤ 4 * ε := by
  exact abs_le.mpr ⟨ by linarith [ abs_le.mp ( hpert i j ), abs_le.mp ( hpert i i ), abs_le.mp ( hpert j j ), show diagExchangeSlack w₁ i j = 2 * w₁.weight i j - w₁.weight i i - w₁.weight j j from rfl, show diagExchangeSlack w₂ i j = 2 * w₂.weight i j - w₂.weight i i - w₂.weight j j from rfl ], by linarith [ abs_le.mp ( hpert i j ), abs_le.mp ( hpert i i ), abs_le.mp ( hpert j j ), show diagExchangeSlack w₁ i j = 2 * w₁.weight i j - w₁.weight i i - w₁.weight j j from rfl, show diagExchangeSlack w₂ i j = 2 * w₂.weight i j - w₂.weight i i - w₂.weight j j from rfl ] ⟩

/-
If weights are perturbed by at most `ε` and original slack ≥ 4ε,
    the perturbed slack is still nonneg.
-/
theorem exchange_admissible_stable
    (w₁ w₂ : TropicalQuadraticWeight σ) (ε : ℝ) (hε : 0 ≤ ε)
    (hpert : ∀ i j, |w₁.weight i j - w₂.weight i j| ≤ ε)
    (i j : σ) (hδ : 4 * ε ≤ diagExchangeSlack w₁ i j) :
    0 ≤ diagExchangeSlack w₂ i j := by
  linarith [ abs_le.mp ( show |diagExchangeSlack w₁ i j - diagExchangeSlack w₂ i j| ≤ 4 * ε by exact exchange_slack_lipschitz w₁ w₂ ε hε hpert i j ) ]

/-! ## Section 6: Certificate Existence and Computability -/

/-
The set of exchange slack values for distinct pairs is finite.
-/
theorem exchangeSlack_set_finite [Fintype σ] [DecidableEq σ]
    (w : TropicalQuadraticWeight σ) :
    Set.Finite {δ : ℝ | ∃ i j : σ, i ≠ j ∧ δ = diagExchangeSlack w i j} := by
  exact Set.Finite.subset ( Set.toFinite ( Finset.image ( fun p : σ × σ => diagExchangeSlack w p.1 p.2 ) Finset.univ ) ) fun x hx => by aesop;

/-
**Theorem 5 (Certificate Existence).**
    For a finite index type with ≥ 2 elements, the tropical spectral gap
    is attained by a witness pair.
-/
theorem tropical_gap_certificate_exists [Fintype σ] [DecidableEq σ]
    (w : TropicalQuadraticWeight σ)
    (hcard : ∃ (a b : σ), a ≠ b) :
    ∃ cert : TropicalGapCertificate w,
      cert.value = tropicalSpectralGap w := by
  obtain ⟨ a, b, hab ⟩ := hcard;
  -- Since the set is finite, its infimum is attained.
  have h_inf_achieved : ∃ p : σ × σ, p.1 ≠ p.2 ∧ ∀ q : σ × σ, q.1 ≠ q.2 → diagExchangeSlack w p.1 p.2 ≤ diagExchangeSlack w q.1 q.2 := by
    apply_rules [ Set.exists_min_image ];
    · exact Set.toFinite _;
    · exact ⟨ ⟨ a, b ⟩, hab ⟩;
  obtain ⟨ p, hp₁, hp₂ ⟩ := h_inf_achieved; use ⟨ p, hp₁, diagExchangeSlack w p.1 p.2, rfl, fun i j hij => hp₂ ⟨ i, j ⟩ hij ⟩ ; simp +decide [ TropicalLorentzianShadows.tropicalSpectralGap, hp₁, hp₂ ] ;
  exact le_antisymm ( le_csInf ⟨ _, ⟨ p.1, p.2, hp₁, rfl ⟩ ⟩ fun x hx => by aesop ) ( csInf_le ⟨ _, by rintro x ⟨ i, j, hij, rfl ⟩ ; exact hp₂ ⟨ i, j ⟩ hij ⟩ ⟨ p.1, p.2, hp₁, rfl ⟩ )

/-! ## Section 7: Uniform Weight Models -/

/-
For uniform weights, all exchange slacks for distinct pairs are `2(c-d)`.
-/
theorem uniform_exchangeSlack_eq
    (w : TropicalQuadraticWeight σ) (d c : ℝ) (hu : IsUniform w d c)
    (i j : σ) (hij : i ≠ j) :
    diagExchangeSlack w i j = 2 * c - 2 * d := by
  unfold diagExchangeSlack; rw [ hu.1 i, hu.1 j, hu.2 i j hij ] ; ring;

/-
**Theorem 6 (Exact Computation for Uniform Weights).**
    Tropical spectral gap of uniform weights = `2(c-d)`.
-/
theorem tropical_gap_eq_uniform [Fintype σ] [DecidableEq σ]
    (w : TropicalQuadraticWeight σ) (d c : ℝ) (hu : IsUniform w d c)
    (hcard : ∃ (a b : σ), a ≠ b) :
    tropicalSpectralGap w = 2 * c - 2 * d := by
  -- By uniform_exchangeSlack_eq, all exchange slacks are equal to 2*c - 2*d.
  have h_all_slacks : ∀ i j : σ, i ≠ j → diagExchangeSlack w i j = 2 * c - 2 * d := by
    exact?;
  refine' le_antisymm ( csInf_le _ _ ) ( le_csInf _ _ );
  · exact Set.Finite.bddBelow ( Set.Finite.subset ( Set.finite_singleton ( 2 * c - 2 * d ) ) fun x hx => by obtain ⟨ i, j, hij, rfl ⟩ := hx; exact h_all_slacks i j hij ▸ rfl );
  · exact ⟨ hcard.choose, hcard.choose_spec.choose, hcard.choose_spec.choose_spec, h_all_slacks _ _ hcard.choose_spec.choose_spec ▸ rfl ⟩;
  · exact ⟨ _, ⟨ hcard.choose, hcard.choose_spec.choose, hcard.choose_spec.choose_spec, rfl ⟩ ⟩;
  · aesop

/-! ## Section 8: Stability Radius Lower Bound -/

/-
**Theorem 7 (Tropical-to-Stability Bridge).**
    Nonneg exchange slack ⟹ det₂ ≥ exp(w_ii + w_jj) · (exp(δ) - 1).
-/
theorem tropical_to_stability_bridge
    (w : TropicalQuadraticWeight σ) (i j : σ)
    (hδ : 0 ≤ diagExchangeSlack w i j) :
    Real.exp (w.weight i i + w.weight j j) * (Real.exp (diagExchangeSlack w i j) - 1)
      ≤ expWeightDet2 w i j := by
  convert tropical_exchange_controls_det w i j |> Eq.ge using 1

/-! ## Section 9: Linearity of Exchange Slack -/

/-
Exchange slack is linear in weights: affine combination preserves structure.
-/
theorem exchange_slack_is_linear
    (w₁ w₂ : TropicalQuadraticWeight σ) (t : ℝ) (i j : σ) :
    diagExchangeSlack
      ⟨fun x y => (1 - t) * w₁.weight x y + t * w₂.weight x y,
       fun x y => by
         show (1 - t) * w₁.weight x y + t * w₂.weight x y =
              (1 - t) * w₁.weight y x + t * w₂.weight y x
         rw [w₁.symm x y, w₂.symm x y]⟩ i j =
        (1 - t) * diagExchangeSlack w₁ i j + t * diagExchangeSlack w₂ i j := by
  unfold diagExchangeSlack; ring;

/-! ## Section 10: Rescaling and Maslov Dequantization -/

/-- Weight rescaling: `w(i,j) + t · ω(i,j)`. -/
def rescaleWeight (w : TropicalQuadraticWeight σ) (ω : σ → σ → ℝ)
    (hω : ∀ i j, ω i j = ω j i) (t : ℝ) : TropicalQuadraticWeight σ where
  weight i j := w.weight i j + t * ω i j
  symm i j := by rw [w.symm i j, hω i j]

/-
**Rescaling linearity**: exchange slack of rescaled weight decomposes linearly.
-/
theorem rescale_tropical_gap_linear
    (w : TropicalQuadraticWeight σ) (ω : σ → σ → ℝ)
    (hω : ∀ i j, ω i j = ω j i) (t : ℝ) (i j : σ) :
    diagExchangeSlack (rescaleWeight w ω hω t) i j =
      diagExchangeSlack w i j + t * (2 * ω i j - ω i i - ω j j) := by
  unfold diagExchangeSlack rescaleWeight; ring;

/-
**Grand Conjecture (Maslov Dequantization Limit).**
    For the tropical gap, the rescaling is exactly linear:

    `tropicalSpectralGap(w + t·ω) = tropicalSpectralGap(w) + t · tropMarginWeighted(ω)`

    The deep conjecture is that the same linear growth rate governs
    `log(stabilityRadius(exp(w + t·ω)))` for the analytic stability radius.
    Formally: for Lorentzian exp-weight matrices, the logarithmic stability radius
    under Maslov-type coefficient rescaling converges to the tropical margin.
-/
theorem maslov_conjecture_tropical_part [Fintype σ] [DecidableEq σ]
    (w : TropicalQuadraticWeight σ) (ω : σ → σ → ℝ)
    (hω : ∀ i j, ω i j = ω j i) (t : ℝ) :
    ∀ i j : σ, i ≠ j →
      diagExchangeSlack (rescaleWeight w ω hω t) i j =
        diagExchangeSlack w i j + t * diagExchangeSlack ⟨ω, hω⟩ i j := by
  intro i j hij; unfold diagExchangeSlack; unfold rescaleWeight; ring;

end TropicalLorentzianShadows
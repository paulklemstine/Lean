/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Lorentzian Anti-Cancellation in Ferromagnetic Statistical Physics

This file establishes a bridge between **equilibrium statistical physics**,
**Lorentzian polynomial theory**, and **combinatorial Hodge structures**.

We define the ferromagnetic Ising partition polynomial, prove structural properties
of its coefficients and susceptibility numerators, and connect these to the
aggregate anti-cancellation framework from `LorentzianAggregateAntiCancel.lean`.

## Mathematical Overview

For the Ising model on a finite graph with ferromagnetic couplings J ≥ 0 and
inverse temperature β ≥ 0, we study the multiaffine generating polynomial

  Φ(z) = Σ_{S ⊆ V} w_β(S) ∏_{i ∈ S} zᵢ

where w_β(S) = exp(β · alignment_energy(S)) > 0 encodes the Boltzmann weight.

## Main Results

* `susceptibilityNumerator_eq` — The susceptibility numerator N₁₂ = Φ·∂₁∂₂Φ - ∂₁Φ·∂₂Φ
  equals e^{2βJ} - 1, independent of field variables.
* `susceptibilityNumerator_nonneg` — Non-negativity for ferromagnetic couplings.
* `twoSpinHessian_lorentzian` — Lorentzian signature of the multiaffine Hessian.
* `ising_aggregate_anticancel` — Anti-cancellation for positive-coefficient polynomials.
* `gibbs_susceptibility_pos` — Positive Gibbs susceptibility (bridge to probability).
* `levelWeight₂_newton_iff` — Sharp Newton inequality threshold for level weights.

## References

* Brändén–Huh, "Lorentzian Polynomials", Annals of Mathematics, 2020
* Lee–Yang, "Statistical Theory of Equations of State", Physical Review, 1952
* `Catalog/Pythagorean/LorentzianAggregateAntiCancel.lean`
* `Catalog/Speculative/AutoResearch/LorentzianGlauberMixing.lean`
-/

open Real BigOperators MvPolynomial Finset Finsupp

noncomputable section

namespace LorentzianIsing

/-! ## Section 1: Two-Spin Partition Polynomial

The two-spin Ising model on a single edge {0,1} with coupling J ≥ 0
and inverse temperature β ≥ 0. The partition polynomial is:

  Φ(z₀, z₁) = e^{βJ}(1 + z₀z₁) + z₀ + z₁
-/

/-- The two-spin Ising partition function evaluated at field variables z₀, z₁. -/
def twoSpinEval (β J z₀ z₁ : ℝ) : ℝ :=
  Real.exp (β * J) * (1 + z₀ * z₁) + z₀ + z₁

/-- The susceptibility numerator for the two-spin model:
    N₀₁ = Φ · ∂₀∂₁Φ - (∂₀Φ)(∂₁Φ). -/
def susceptibilityNumerator₂ (β J z₀ z₁ : ℝ) : ℝ :=
  twoSpinEval β J z₀ z₁ * Real.exp (β * J) -
  (Real.exp (β * J) * z₁ + 1) * (Real.exp (β * J) * z₀ + 1)

/-! ### Theorem 1: Susceptibility Numerator Identity -/

/-- **Theorem 1a**: The susceptibility numerator equals e^{2βJ} - 1. -/
theorem susceptibilityNumerator_eq (β J z₀ z₁ : ℝ) :
    susceptibilityNumerator₂ β J z₀ z₁ = Real.exp (β * J) ^ 2 - 1 := by
  simp only [susceptibilityNumerator₂, twoSpinEval]
  ring

/-
**Theorem 1b**: The susceptibility numerator is nonneg for ferromagnetic couplings.
-/
theorem susceptibilityNumerator_nonneg (β J : ℝ) (hβ : 0 ≤ β) (hJ : 0 ≤ J)
    (z₀ z₁ : ℝ) :
    0 ≤ susceptibilityNumerator₂ β J z₀ z₁ := by
  rw [susceptibilityNumerator_eq]
  exact sub_nonneg_of_le ( one_le_pow₀ ( Real.one_le_exp ( mul_nonneg hβ hJ ) ) )

/-! ### Theorem 2: Positivity of Partition Polynomial -/

/-- All four coefficients are strictly positive. -/
theorem twoSpinPoly_coeff_pos (β J : ℝ) :
    0 < Real.exp (β * J) ∧ (0 : ℝ) < 1 ∧ (0 : ℝ) < 1 ∧ 0 < Real.exp (β * J) :=
  ⟨Real.exp_pos _, one_pos, one_pos, Real.exp_pos _⟩

/-
The partition function is strictly positive when field variables are nonneg.
-/
theorem twoSpinEval_pos (β J z₀ z₁ : ℝ) (hz₀ : 0 ≤ z₀) (hz₁ : 0 ≤ z₁) :
    0 < twoSpinEval β J z₀ z₁ := by
  exact add_pos_of_pos_of_nonneg ( add_pos_of_pos_of_nonneg ( mul_pos ( Real.exp_pos _ ) ( by positivity ) ) ( by positivity ) ) ( by positivity )

/-! ### Theorem 3: Multiaffine Hessian Signature — Lorentzian Condition

The Hessian of the two-spin partition polynomial (as a multiaffine quadratic
form) has exactly one positive eigenvalue. The Hessian matrix is:
  H = [[0,      e^{βJ}],
       [e^{βJ}, 0      ]]
with eigenvalues ±e^{βJ}.
-/

/-- The Hessian quadratic form of the two-spin partition polynomial. -/
def twoSpinHessianForm (β J : ℝ) (v₀ v₁ : ℝ) : ℝ :=
  2 * Real.exp (β * J) * v₀ * v₁

/-- The Hessian form has a positive direction: Q(1,1) > 0. -/
theorem twoSpinHessian_pos_direction (β J : ℝ) :
    0 < twoSpinHessianForm β J 1 1 := by
  unfold twoSpinHessianForm; positivity

/-- The Hessian form has a negative direction: Q(1,-1) < 0. -/
theorem twoSpinHessian_neg_direction (β J : ℝ) :
    twoSpinHessianForm β J 1 (-1) < 0 := by
  unfold twoSpinHessianForm; simp; exact Real.exp_pos _

/-
**Theorem 3 (Lorentzian Signature)**: On the orthogonal complement of (1,1),
    the Hessian form is negative semidefinite.
-/
theorem twoSpinHessian_lorentzian (β J : ℝ) (v₀ v₁ : ℝ)
    (horth : v₀ + v₁ = 0) :
    twoSpinHessianForm β J v₀ v₁ ≤ 0 := by
  unfold twoSpinHessianForm; norm_num [ show v₁ = -v₀ by linarith ] ; nlinarith [ Real.exp_pos ( β * J ), sq_nonneg v₀ ] ;

/-
Strict negativity away from zero.
-/
theorem twoSpinHessian_lorentzian_strict (β J : ℝ) (v₀ v₁ : ℝ)
    (horth : v₀ + v₁ = 0) (hne : v₀ ≠ 0) :
    twoSpinHessianForm β J v₀ v₁ < 0 := by
  unfold twoSpinHessianForm; cases lt_or_gt_of_ne hne <;> nlinarith [ Real.exp_pos ( β * J ), mul_self_pos.mpr hne, mul_lt_mul_of_pos_left ‹_› ( Real.exp_pos ( β * J ) ) ] ;

/-! ## Section 2: General Definitions -/

/-- Alignment indicator: 1 if i,j are both in S or both not in S. -/
def alignInd {V : Type*} [DecidableEq V] (S : Finset V) (i j : V) : ℝ :=
  if (i ∈ S ∧ j ∈ S) ∨ (i ∉ S ∧ j ∉ S) then 1 else 0

/-- The Boltzmann weight for a subset S. -/
def boltzmannWeight {V : Type*} [DecidableEq V] [Fintype V]
    (J : V → V → ℝ) (β : ℝ) (S : Finset V) : ℝ :=
  Real.exp (β * ((1 : ℝ) / 2 * ∑ i : V, ∑ j : V,
    if i ≠ j then J i j * alignInd S i j else 0))

/-- Boltzmann weights are strictly positive. -/
theorem boltzmannWeight_pos {V : Type*} [DecidableEq V] [Fintype V]
    (J : V → V → ℝ) (β : ℝ) (S : Finset V) :
    0 < boltzmannWeight J β S :=
  Real.exp_pos _

/-- The level weight: sum of Boltzmann weights over subsets of given cardinality. -/
def levelWeight {V : Type*} [DecidableEq V] [Fintype V]
    (J : V → V → ℝ) (β : ℝ) (k : ℕ) : ℝ :=
  ∑ S ∈ Finset.univ.powerset.filter (fun S => S.card = k), boltzmannWeight J β S

/-
Level weights are strictly positive for valid cardinalities.
-/
theorem levelWeight_pos {V : Type*} [DecidableEq V] [Fintype V]
    (J : V → V → ℝ) (β : ℝ) (k : ℕ) (hk : k ≤ Fintype.card V) :
    0 < levelWeight J β k := by
  -- Since the sum is over a nonempty set of positive terms, it must be positive.
  have h_nonempty : ∃ S : Finset V, S.card = k := by
    exact Exists.imp ( by aesop ) ( Finset.exists_subset_card_eq hk );
  exact Finset.sum_pos ( fun S hS => boltzmannWeight_pos J β S ) ⟨ h_nonempty.choose, Finset.mem_filter.mpr ⟨ Finset.mem_univ _, h_nonempty.choose_spec ⟩ ⟩

/-! ## Section 3: Aggregate Anti-Cancellation over ℝ

We instantiate the anti-cancellation framework over ℝ, mirroring the
ℚ-valued framework from `LorentzianAggregateAntiCancel.lean`. -/

/-- Nonneg-coefficient predicate. -/
def NonnegCoeffsReal {σ : Type*} [DecidableEq σ] (p : MvPolynomial σ ℝ) : Prop :=
  ∀ α : σ →₀ ℕ, 0 ≤ MvPolynomial.coeff α p

/-- The weighted Hessian sum over ℝ. -/
def hessianWeightedSumReal {σ : Type*} [DecidableEq σ] [Fintype σ]
    (p : MvPolynomial σ ℝ) (A : σ → σ → ℝ) : MvPolynomial σ ℝ :=
  ∑ i : σ, ∑ j : σ,
    MvPolynomial.C (A i j) * MvPolynomial.pderiv i (MvPolynomial.pderiv j p)

/-- Pair shadow over ℝ. -/
def pairShadowReal {σ : Type*} [DecidableEq σ]
    (p : MvPolynomial σ ℝ) (i j : σ) : Finset (σ →₀ ℕ) :=
  (MvPolynomial.pderiv i (MvPolynomial.pderiv j p)).support

/-- Aggregate shadow over ℝ. -/
def aggregateShadowReal {σ : Type*} [DecidableEq σ] [Fintype σ]
    (p : MvPolynomial σ ℝ) (A : σ → σ → ℝ) : Finset (σ →₀ ℕ) :=
  Finset.univ.biUnion fun i =>
    Finset.univ.biUnion fun j =>
      if A i j = 0 then ∅ else pairShadowReal p i j

/-- All-positive weights predicate. -/
def AllPositiveWeightsReal {σ : Type*} (A : σ → σ → ℝ) : Prop :=
  ∀ i j : σ, A i j ≠ 0 → 0 < A i j

/-- Pair contribution. -/
def pairContribReal {σ : Type*} [DecidableEq σ]
    (p : MvPolynomial σ ℝ) (A : σ → σ → ℝ) (i j : σ) (β : σ →₀ ℕ) : ℝ :=
  A i j * MvPolynomial.coeff β (MvPolynomial.pderiv i (MvPolynomial.pderiv j p))

/-- Overlap sign coherence over ℝ. -/
def OverlapSignCoherentReal {σ : Type*} [DecidableEq σ] [Fintype σ]
    (p : MvPolynomial σ ℝ) (A : σ → σ → ℝ) : Prop :=
  ∀ β : σ →₀ ℕ, ∀ i₁ j₁ i₂ j₂ : σ,
    pairContribReal p A i₁ j₁ β ≠ 0 →
    pairContribReal p A i₂ j₂ β ≠ 0 →
    0 < pairContribReal p A i₁ j₁ β * pairContribReal p A i₂ j₂ β

/-- Aggregate anti-cancellation over ℝ. -/
def AggregateAntiCancelReal {σ : Type*} [DecidableEq σ] [Fintype σ]
    (p : MvPolynomial σ ℝ) (A : σ → σ → ℝ) : Prop :=
  ∀ β : σ →₀ ℕ,
    β ∈ aggregateShadowReal p A ↔
    MvPolynomial.coeff β (hessianWeightedSumReal p A) ≠ 0

/-
Second partial derivative coefficients are nonneg for nonneg-coefficient polynomials.
-/
theorem coeff_pderiv_pderiv_nonneg_real {σ : Type*} [DecidableEq σ] [Fintype σ]
    (p : MvPolynomial σ ℝ) (hnn : NonnegCoeffsReal p) (i j : σ) (β : σ →₀ ℕ) :
    0 ≤ MvPolynomial.coeff β (MvPolynomial.pderiv i (MvPolynomial.pderiv j p)) := by
  have h_ind : ∀ p : MvPolynomial σ ℝ, NonnegCoeffsReal p → NonnegCoeffsReal (MvPolynomial.pderiv i p) := by
    intro p hp β;
    -- By definition of polynomial derivative, the coefficient of β in the derivative of p with respect to i is the coefficient of β + e_i in p.
    have h_coeff_deriv : MvPolynomial.coeff β (MvPolynomial.pderiv i p) = MvPolynomial.coeff (β + Finsupp.single i 1) p * (β i + 1) := by
      have h_coeff_deriv : ∀ (p : MvPolynomial σ ℝ), MvPolynomial.pderiv i p = ∑ m ∈ p.support, MvPolynomial.monomial (m - Finsupp.single i 1) (MvPolynomial.coeff m p * m i) := by
        intro p
        simp [pderiv];
        rw [ mkDerivation ];
        simp +decide [ mkDerivationₗ ];
        simp +decide [ lsum, Pi.single_apply ];
        refine' Finset.sum_congr rfl fun m hm => _ ; aesop;
      simp +decide [ h_coeff_deriv, MvPolynomial.coeff_sum, MvPolynomial.coeff_monomial ];
      rw [ Finset.sum_eq_single ( β + Finsupp.single i 1 ) ] <;> simp +decide [ Finsupp.ext_iff ];
      · grind +extAll;
      · exact fun h => Or.inl h;
    exact h_coeff_deriv.symm ▸ mul_nonneg ( hp _ ) ( by positivity );
  convert h_ind _ _ _ using 1;
  intro α; exact (by
  rw [ MvPolynomial.pderiv_def ];
  rw [ MvPolynomial.mkDerivation ];
  simp +decide [ mkDerivationₗ ];
  simp +decide [ lsum, Finsupp.sum_fintype ];
  simp +decide [ sum, Pi.single_apply ];
  simp +decide [ coeff_sum, coeff_smul ];
  exact Finset.sum_nonneg fun x hx => by split_ifs <;> [ exact mul_nonneg ( hnn x ) ( Nat.cast_nonneg _ ) ; exact le_rfl ] ;);

/-
**Theorem 4**: Overlap sign coherence for positive-coefficient polynomials
    with positive weights.
-/
theorem ising_overlap_sign_coherent {σ : Type*} [DecidableEq σ] [Fintype σ]
    (p : MvPolynomial σ ℝ) (A : σ → σ → ℝ)
    (hnn : NonnegCoeffsReal p)
    (hpos : AllPositiveWeightsReal A) :
    OverlapSignCoherentReal p A := by
  intro β i₁ j₁ i₂ j₂ h₁ h₂;
  apply_rules [ mul_pos ];
  · exact fun h => h₁ <| by simp +decide [ h, pairContribReal ] ;
  · exact lt_of_le_of_ne ( coeff_pderiv_pderiv_nonneg_real p hnn i₁ j₁ β ) ( Ne.symm <| by unfold pairContribReal at h₁; aesop );
  · exact fun h => h₂ <| by simp +decide [ h, pairContribReal ] ;
  · exact lt_of_le_of_ne ( coeff_pderiv_pderiv_nonneg_real p hnn i₂ j₂ β ) ( Ne.symm <| by unfold pairContribReal at h₂; aesop )

/-
A finite sum of same-sign reals with a nonzero term is nonzero.
-/
theorem sum_ne_zero_of_same_sign_real {ι : Type*} [Fintype ι] (f : ι → ℝ)
    (hsign : ∀ a b : ι, f a ≠ 0 → f b ≠ 0 → 0 < f a * f b)
    (hex : ∃ k : ι, f k ≠ 0) :
    ∑ i : ι, f i ≠ 0 := by
  obtain ⟨ k, hk ⟩ := hex
  by_cases h_sign : 0 < f k;
  · refine' ne_of_gt ( lt_of_lt_of_le _ ( Finset.single_le_sum ( fun i _ => _ ) ( Finset.mem_univ k ) ) );
    · exact h_sign;
    · exact le_of_not_gt fun hi => by nlinarith [ hsign i k ( by linarith ) hk ] ;
  · -- Since $f k \leq 0$, we have $f k < 0$.
    have h_neg : f k < 0 := by
      exact lt_of_le_of_ne ( le_of_not_gt h_sign ) hk;
    -- Since $f k < 0$, we have $f i \leq 0$ for all $i$.
    have h_nonpos : ∀ i, f i ≤ 0 := by
      exact fun i => le_of_not_gt fun hi => by nlinarith [ hsign i k ( by linarith ) hk ] ;
    exact ne_of_lt ( lt_of_lt_of_le ( Finset.sum_lt_sum ( fun i _ => h_nonpos i ) ⟨ k, Finset.mem_univ k, h_neg ⟩ ) ( by simp +decide ) )

/-
**Theorem 5 (Aggregate Anti-Cancellation for Ising)**: For nonneg coefficients
    and positive weights, the weighted Hessian support equals the aggregate shadow.
-/
theorem ising_aggregate_anticancel {σ : Type*} [DecidableEq σ] [Fintype σ]
    (p : MvPolynomial σ ℝ) (A : σ → σ → ℝ)
    (hnn : NonnegCoeffsReal p)
    (hpos : AllPositiveWeightsReal A) :
    AggregateAntiCancelReal p A := by
  intro β;
  constructor;
  · unfold hessianWeightedSumReal aggregateShadowReal;
    simp +decide [ pairShadowReal ];
    intro i j hij; split_ifs at hij <;> simp_all +decide [ MvPolynomial.coeff_sum, MvPolynomial.coeff_C_mul ] ;
    refine' ne_of_gt ( lt_of_lt_of_le _ ( Finset.single_le_sum ( fun x _ => Finset.sum_nonneg fun y _ => _ ) ( Finset.mem_univ i ) |> le_trans ( Finset.single_le_sum ( fun y _ => _ ) ( Finset.mem_univ j ) ) ) );
    · exact mul_pos ( lt_of_le_of_ne ( le_of_lt ( hpos i j ‹_› ) ) ( Ne.symm ‹_› ) ) ( lt_of_le_of_ne ( coeff_pderiv_pderiv_nonneg_real p hnn i j β ) ( Ne.symm hij ) );
    · exact mul_nonneg ( if h : A i y = 0 then by simp +decide [ h ] else le_of_lt ( hpos i y h ) ) ( coeff_pderiv_pderiv_nonneg_real p hnn i y β );
    · exact mul_nonneg ( if h : A x y = 0 then by simp +decide [ h ] else le_of_lt ( hpos x y h ) ) ( coeff_pderiv_pderiv_nonneg_real p hnn x y β );
  · contrapose!;
    simp +decide [ hessianWeightedSumReal, aggregateShadowReal ];
    simp +contextual [ MvPolynomial.coeff_sum, MvPolynomial.coeff_C_mul ];
    intro h; rw [ Finset.sum_eq_zero ] ; intros i hi; rw [ Finset.sum_eq_zero ] ; intros j hj; specialize h i j; split_ifs at h <;> simp_all +decide [ pairShadowReal ] ;

/-! ## Section 4: Gibbs Measure — Bridge to Probability -/

/-- The partition function at z₀ = z₁ = 1. -/
def partitionFn₂ (β J : ℝ) : ℝ := twoSpinEval β J 1 1

/-- The partition function equals 2(e^{βJ} + 1). -/
theorem partitionFn₂_eq (β J : ℝ) :
    partitionFn₂ β J = 2 * (Real.exp (β * J) + 1) := by
  unfold partitionFn₂ twoSpinEval; ring

/-
The partition function is strictly positive.
-/
theorem partitionFn₂_pos (β J : ℝ) : 0 < partitionFn₂ β J := by
  exact partitionFn₂_eq β J ▸ mul_pos zero_lt_two ( add_pos_of_nonneg_of_pos ( Real.exp_nonneg _ ) zero_lt_one )

/-- The Gibbs susceptibility χ₀₁ = N₀₁(1,1) / Φ(1,1)². -/
def gibbsSusceptibility₂ (β J : ℝ) : ℝ :=
  susceptibilityNumerator₂ β J 1 1 / partitionFn₂ β J ^ 2

/-
**Theorem 6 (Positive Gibbs Susceptibility)**: χ₀₁ > 0 for strictly positive coupling.
-/
theorem gibbs_susceptibility_pos (β J : ℝ) (hβ : 0 < β) (hJ : 0 < J) :
    0 < gibbsSusceptibility₂ β J := by
  refine' div_pos _ _;
  · exact susceptibilityNumerator_eq β J 1 1 ▸ by exact sub_pos_of_lt ( one_lt_pow₀ ( by norm_num; positivity ) two_ne_zero ) ;
  · exact sq_pos_of_pos ( partitionFn₂_pos β J )

/-! ## Section 5: Level Weights -/

/-- Level weights for the two-spin model. -/
def levelWeight₂ (β J : ℝ) (k : ℕ) : ℝ :=
  if k = 0 then Real.exp (β * J)
  else if k = 1 then 2
  else if k = 2 then Real.exp (β * J)
  else 0

/-- Level weight symmetry: a₀ = a₂. -/
theorem levelWeight₂_symm (β J : ℝ) :
    levelWeight₂ β J 0 = levelWeight₂ β J 2 := by
  simp [levelWeight₂]

/-
All level weights (k ≤ 2) are positive.
-/
theorem levelWeight₂_pos (β J : ℝ) (k : ℕ) (hk : k ≤ 2) :
    0 < levelWeight₂ β J k := by
  interval_cases k <;> unfold levelWeight₂ <;> norm_num [ Real.exp_pos ]

/-
**Theorem 7**: Newton inequality threshold for two-spin level weights.
-/
theorem levelWeight₂_newton_iff (β J : ℝ) (hβ : 0 ≤ β) (hJ : 0 ≤ J) :
    levelWeight₂ β J 1 ^ 2 ≥ levelWeight₂ β J 0 * levelWeight₂ β J 2 ↔
    β * J ≤ Real.log 2 := by
  unfold levelWeight₂; norm_num;
  rw [ ← sq, ← Real.log_le_log_iff ( by positivity ) ( by positivity ), Real.log_pow, Real.log_exp ] ; ring_nf;
  rw [ show ( 4 : ℝ ) = 2 ^ 2 by norm_num, Real.log_pow ] ; norm_num ; constructor <;> intro <;> linarith

/-! ## Section 6: MvPolynomial Susceptibility -/

/-- The susceptibility numerator as an MvPolynomial. -/
def susceptibilityNumeratorPoly {σ : Type*} [DecidableEq σ]
    (p : MvPolynomial σ ℝ) (i j : σ) : MvPolynomial σ ℝ :=
  p * MvPolynomial.pderiv i (MvPolynomial.pderiv j p) -
  MvPolynomial.pderiv i p * MvPolynomial.pderiv j p

/-
Susceptibility numerator is symmetric in i,j.
-/
theorem susceptibilityNumeratorPoly_symm {σ : Type*} [DecidableEq σ]
    (p : MvPolynomial σ ℝ) (i j : σ) :
    susceptibilityNumeratorPoly p i j = susceptibilityNumeratorPoly p j i := by
  unfold susceptibilityNumeratorPoly; simp +decide [ mul_comm ] ;
  -- By the properties of partial derivatives, we know that $(pderiv i) ((pderiv j) p) = (pderiv j) ((pderiv i) p)$.
  left; exact (by
  induction p using MvPolynomial.induction_on <;> simp_all +decide [ MvPolynomial.pderiv_C, MvPolynomial.pderiv_X, mul_comm ];
  simp +decide [ Pi.single_apply, add_comm, add_left_comm, add_assoc ];
  split_ifs <;> simp +decide [ * ])

/-! ## Section 7: Edge Factor Structure -/

/-- The homogenized edge factor. -/
def edgeFactorEval (a x₀ xᵢ xⱼ : ℝ) : ℝ :=
  x₀ ^ 2 + x₀ * xᵢ + x₀ * xⱼ + a * xᵢ * xⱼ

/-- At a = 1, the edge factor factors as (x₀ + xᵢ)(x₀ + xⱼ). -/
theorem edgeFactor_factors_at_one (x₀ xᵢ xⱼ : ℝ) :
    edgeFactorEval 1 x₀ xᵢ xⱼ = (x₀ + xᵢ) * (x₀ + xⱼ) := by
  unfold edgeFactorEval; ring

/-
The edge factor is nonneg for nonneg inputs with a ≥ 1.
-/
theorem edgeFactorEval_nonneg (a x₀ xᵢ xⱼ : ℝ)
    (ha : 1 ≤ a) (h₀ : 0 ≤ x₀) (hᵢ : 0 ≤ xᵢ) (hⱼ : 0 ≤ xⱼ) :
    0 ≤ edgeFactorEval a x₀ xᵢ xⱼ := by
  exact add_nonneg ( add_nonneg ( add_nonneg ( sq_nonneg _ ) ( mul_nonneg h₀ hᵢ ) ) ( mul_nonneg h₀ hⱼ ) ) ( mul_nonneg ( mul_nonneg ( by positivity ) ( by positivity ) ) ( by positivity ) )

/-! ## Section 8: Strict Susceptibility Positivity -/

/-
Two-spin susceptibility at unit fields is strictly positive for β·J > 0.
-/
theorem twoSpin_susceptibility_unit_pos (β J : ℝ) (hβ : 0 < β) (hJ : 0 < J) :
    0 < susceptibilityNumerator₂ β J 1 1 := by
  exact sub_pos_of_lt ( one_lt_pow₀ ( by norm_num; positivity ) two_ne_zero ) |> fun h => susceptibilityNumerator_eq β J 1 1 ▸ h

end LorentzianIsing
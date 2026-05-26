/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Black-Box Group Recognition via Characteristic Polynomial Certificates

This file develops a certified recognition theory for matrix groups based on
characteristic polynomial statistics. The central insight is that for a group
isomorphic to GL_n(𝔽_q), the characteristic polynomial of a random element
encodes two orthogonal global parameters: its degree rigidly determines n,
and its factorization statistics are governed by q in quantitatively separable ways.

## Main Definitions

* `CharpolyFingerprint`: Structure storing empirical statistics of sampled
  characteristic polynomials.
* `TheoreticalFingerprint`: Theoretically predicted fingerprint for GL_n(𝔽_q).
* `fingerprintLoss`: Score measuring discrepancy between observed and predicted
  fingerprints.
* `recognitionScore`: Objective function for parameter identification.

## Main Results

* `charpoly_degree_eq_fintype_card`: Degree of charpoly equals matrix dimension.
* `fingerprint_degree_recovers_dimension`: Sampled charpolys recover dimension.
* `fingerprintLoss_eq_zero_iff`: Loss is zero iff rates match exactly.
* `true_params_unique_minimizer`: True parameters uniquely minimize the loss.
* `spectral_distinguisher`: Separated rates yield a certified distinguisher.
* `perfect_fingerprint_identifies_params`: Perfect data identifies parameters.
* `irreducible_charpoly_no_proper_invariant`: Irreducible charpoly implies
  the action is irreducible (no nontrivial invariant subspace).

## Cross-Domain Bridges

- **Analytic Number Theory**: Counting irreducible polynomials over finite
  fields is the function-field analogue of the prime number theorem.
- **Cryptography**: Characteristic-polynomial fingerprints serve as certified
  distinguishers for hidden linear groups.
- **Statistical Learning**: Recognition is an inverse problem: infer latent
  parameters (n,q) from spectral observations.

## References

* Lidl, R., Niederreiter, H. (1997). Finite Fields. Cambridge University Press.
* Flajolet, P., Sedgewick, R. (2009). Analytic Combinatorics. Cambridge.
-/

import Mathlib

open Polynomial Matrix Finset

/-! ## Core Definitions for Recognition Framework -/

/-- A `CharpolyFingerprint` stores the empirical statistics of a sample of
characteristic polynomials. This is the observable data from which we aim
to recover the ambient parameters (n, q) of a black-box matrix group. -/
structure CharpolyFingerprint where
  /-- The common degree of all sampled characteristic polynomials -/
  dim : ℕ
  /-- The number of polynomials sampled -/
  sampleSize : ℕ
  /-- The number of sampled polynomials that are irreducible -/
  numIrreducible : ℕ
  /-- The number of sampled polynomials that split completely -/
  numSplit : ℕ
  /-- The number of sampled polynomials that are squarefree -/
  numSquarefree : ℕ
  /-- The irreducible count does not exceed the sample size -/
  irred_le : numIrreducible ≤ sampleSize
  /-- The split count does not exceed the sample size -/
  split_le : numSplit ≤ sampleSize
  /-- The squarefree count does not exceed the sample size -/
  sqfree_le : numSquarefree ≤ sampleSize

/-- The empirical irreducible rate from a fingerprint. -/
def CharpolyFingerprint.irredRate (fp : CharpolyFingerprint) : ℚ :=
  if fp.sampleSize = 0 then 0
  else (fp.numIrreducible : ℚ) / fp.sampleSize

/-- The empirical split rate from a fingerprint. -/
def CharpolyFingerprint.splitRate (fp : CharpolyFingerprint) : ℚ :=
  if fp.sampleSize = 0 then 0
  else (fp.numSplit : ℚ) / fp.sampleSize

/-- A `TheoreticalFingerprint` represents the theoretically predicted polynomial
statistics for monic degree-n polynomials over 𝔽_q. -/
structure TheoreticalFingerprint where
  /-- The matrix dimension -/
  dim : ℕ
  /-- The field size -/
  fieldSize : ℕ
  /-- The theoretical fraction of irreducible monic degree-n polynomials -/
  irredRate : ℚ
  /-- The theoretical fraction of completely split monic degree-n polynomials -/
  splitRate : ℚ
  /-- The irreducible rate is nonneg -/
  irredRate_nonneg : 0 ≤ irredRate
  /-- The irreducible rate is at most 1 -/
  irredRate_le_one : irredRate ≤ 1
  /-- The split rate is nonneg -/
  splitRate_nonneg : 0 ≤ splitRate
  /-- The split rate is at most 1 -/
  splitRate_le_one : splitRate ≤ 1

/-- The `fingerprintLoss` measures the squared discrepancy between an empirical
fingerprint and a theoretical prediction. -/
def fingerprintLoss (fp : CharpolyFingerprint) (tf : TheoreticalFingerprint) : ℚ :=
  (fp.irredRate - tf.irredRate) ^ 2 + (fp.splitRate - tf.splitRate) ^ 2

/-- A score function comparing an empirical fingerprint to theoretical predictions.
Lower score = better match. -/
def recognitionScore (fp : CharpolyFingerprint)
    (candidateIrredRate candidateSplitRate : ℚ) : ℚ :=
  (fp.irredRate - candidateIrredRate) ^ 2 +
  (fp.splitRate - candidateSplitRate) ^ 2

/-! ## Theorem 1: Degree Rigidity -/

/-- **Degree rigidity of characteristic polynomials.**
The degree of the characteristic polynomial of any matrix equals the matrix
dimension. This is the first recognition invariant. -/
theorem charpoly_degree_eq_fintype_card
    {K : Type*} [CommRing K] [Nontrivial K]
    {n : Type*} [Fintype n] [DecidableEq n]
    (A : Matrix n n K) :
    A.charpoly.natDegree = Fintype.card n :=
  Matrix.charpoly_natDegree_eq_dim A

/-
**Fingerprint degree recovers dimension.**
If all sampled characteristic polynomials from n×n matrices have degree d,
then d must equal the matrix dimension.
-/
theorem fingerprint_degree_recovers_dimension
    {K : Type*} [CommRing K] [Nontrivial K]
    {n : Type*} [Fintype n] [DecidableEq n]
    {d : ℕ}
    (S : Finset (Matrix n n K))
    (hS : S.Nonempty)
    (hdeg : ∀ A ∈ S, A.charpoly.natDegree = d) :
    d = Fintype.card n := by
  exact hdeg _ hS.choose_spec ▸ charpoly_degree_eq_fintype_card hS.choose

/-! ## Theorem 2: Irreducible Charpoly — Invariant Subspace Theorem

This connects to the certificate infrastructure in `MatrixGroupGeneration.lean`.
We prove self-contained that irreducible charpoly implies no proper invariant
subspaces, which is the structural heart of Singer-cycle certificates. -/

/-- A submodule `W` is invariant under `φ` if φ maps W into W. -/
def IsInvariantSub {K V : Type*} [Field K] [AddCommGroup V] [Module K V]
    (φ : Module.End K V) (W : Submodule K V) : Prop :=
  ∀ w, w ∈ W → φ w ∈ W

/-
**Irreducible charpoly implies no proper nontrivial invariant subspace.**
This is the structural heart of Singer-cycle recognition: if the characteristic
polynomial is irreducible, the linear action is irreducible. Any matrix with
this property acts as a "Singer-like" element in the group.
-/
theorem irreducible_charpoly_no_proper_invariant
    {K V : Type*} [Field K] [AddCommGroup V] [Module K V]
    [FiniteDimensional K V]
    (φ : Module.End K V)
    (hirr : Irreducible φ.charpoly) :
    ¬ ∃ W : Submodule K V,
        W ≠ ⊥ ∧ W ≠ ⊤ ∧ IsInvariantSub φ W := by
  intro h
  obtain ⟨W, hW_ne_bot, hW_ne_top, hW_inv⟩ := h
  have h_minpoly : minpoly K (φ.restrict hW_inv) ∣ LinearMap.charpoly φ := by
    refine' minpoly.dvd K _ _;
    have h_charpoly : (LinearMap.charpoly φ).aeval φ = 0 := by
      convert LinearMap.aeval_self_charpoly φ;
    ext w; simp_all +decide [ Polynomial.aeval_eq_sum_range ] ;
    convert congr_arg ( fun f => f w ) h_charpoly using 1;
    induction' ( LinearMap.charpoly φ |> Polynomial.natDegree ) with n ih <;> simp_all +decide [ pow_succ', Finset.sum_range_succ ];
    exact congr_arg _ ( by exact Nat.recOn n ( by simp +decide ) fun n ihn => by simp +decide [ *, pow_succ' ] );
  -- Since the minimal polynomial of the restriction divides the characteristic polynomial and the characteristic polynomial is irreducible, the minimal polynomial must be either a unit or the characteristic polynomial itself.
  by_cases h_minpoly_unit : minpoly K (φ.restrict hW_inv) = 1;
  · have := minpoly.aeval K ( LinearMap.restrict φ hW_inv );
    obtain ⟨ w, hw ⟩ := ( Submodule.ne_bot_iff _ ).mp hW_ne_bot;
    replace this := congr_arg ( fun f => f ⟨ w, hw.1 ⟩ ) this ; simp_all +decide [ LinearMap.ext_iff ];
  · -- Since the minimal polynomial of the restriction divides the characteristic polynomial and the characteristic polynomial is irreducible, the minimal polynomial must be an associate of the characteristic polynomial.
    have h_minpoly_assoc : Associated (minpoly K (φ.restrict hW_inv)) (LinearMap.charpoly φ) := by
      obtain ⟨ q, hq ⟩ := h_minpoly;
      cases hirr.2 hq <;> simp_all +decide [ Polynomial.isUnit_iff_degree_eq_zero ];
      · have := minpoly.monic ( show IsIntegral K ( LinearMap.restrict φ hW_inv ) from by exact ( LinearMap.isIntegral _ ) ) ; rw [ Polynomial.degree_eq_natDegree ] at * <;> aesop;
      · rw [ Polynomial.eq_C_of_degree_eq_zero ‹q.degree = 0› ] at hirr ⊢;
        exact associated_of_dvd_dvd ( dvd_mul_right _ _ ) ( by exact ⟨ C ( q.coeff 0 ) ⁻¹, by rw [ mul_assoc, ← C_mul, mul_inv_cancel₀ ( by aesop_cat ), C_1, mul_one ] ⟩ );
    -- Since the minimal polynomial of the restriction is an associate of the characteristic polynomial, their degrees must be equal.
    have h_deg_eq : Polynomial.natDegree (minpoly K (φ.restrict hW_inv)) = Polynomial.natDegree (LinearMap.charpoly φ) := by
      exact Polynomial.natDegree_eq_of_degree_eq ( Polynomial.degree_eq_degree_of_associated h_minpoly_assoc );
    -- However, the degree of the minimal polynomial of the restriction is at most the dimension of W, which is strictly less than the dimension of V.
    have h_deg_lt : Polynomial.natDegree (minpoly K (φ.restrict hW_inv)) ≤ Module.finrank K W := by
      have h_deg_lt : Polynomial.natDegree (minpoly K (φ.restrict hW_inv)) ≤ Polynomial.natDegree (LinearMap.charpoly (φ.restrict hW_inv)) := by
        exact Polynomial.natDegree_le_of_dvd ( LinearMap.minpoly_dvd_charpoly _ ) ( by exact LinearMap.charpoly_monic _ |> fun h => h.ne_zero );
      grind +suggestions;
    have h_deg_lt : Polynomial.natDegree (LinearMap.charpoly φ) = Module.finrank K V := by
      convert LinearMap.charpoly_natDegree φ;
    exact absurd ‹Polynomial.natDegree ( minpoly K ( LinearMap.restrict φ hW_inv ) ) ≤ Module.finrank K W› ( by linarith [ show Module.finrank K W < Module.finrank K V from Submodule.finrank_lt ( by aesop ) ] )

/-! ## Theorem 3: Fingerprint Loss Properties -/

/-
**Fingerprint loss is nonneg.** Sum of squares.
-/
theorem fingerprintLoss_nonneg (fp : CharpolyFingerprint) (tf : TheoreticalFingerprint) :
    0 ≤ fingerprintLoss fp tf := by
  exact add_nonneg ( sq_nonneg _ ) ( sq_nonneg _ )

/-
**Fingerprint loss is zero iff rates match exactly.**
-/
theorem fingerprintLoss_eq_zero_iff (fp : CharpolyFingerprint) (tf : TheoreticalFingerprint) :
    fingerprintLoss fp tf = 0 ↔
      fp.irredRate = tf.irredRate ∧ fp.splitRate = tf.splitRate := by
  unfold fingerprintLoss; rw [ add_eq_zero_iff_of_nonneg ] <;> norm_num [ sq_nonneg ] ; constructor <;> intros <;> simp_all +decide [ sub_eq_zero, add_eq_zero_iff_eq_neg ] ;

/-! ## Theorem 4: Separation of Distinct Parameters -/

/-
**Distinct theoretical fingerprints are separated.**
Any empirical fingerprint has positive loss against at least one of two
fingerprints with different rates. This is the key separation lemma.
-/
theorem distinct_fingerprints_separated
    (tf₁ tf₂ : TheoreticalFingerprint)
    (hne : tf₁.irredRate ≠ tf₂.irredRate ∨ tf₁.splitRate ≠ tf₂.splitRate)
    (fp : CharpolyFingerprint) :
    0 < fingerprintLoss fp tf₁ ∨ 0 < fingerprintLoss fp tf₂ := by
  by_contra h_contra;
  simp_all +decide [ not_or, fingerprintLoss_eq_zero_iff ];
  exact hne.elim ( fun h => h <| by linarith [ fingerprintLoss_eq_zero_iff fp tf₁ |>.1 <| le_antisymm h_contra.1 <| fingerprintLoss_nonneg fp tf₁, fingerprintLoss_eq_zero_iff fp tf₂ |>.1 <| le_antisymm h_contra.2 <| fingerprintLoss_nonneg fp tf₂ ] ) fun h => h <| by linarith [ fingerprintLoss_eq_zero_iff fp tf₁ |>.1 <| le_antisymm h_contra.1 <| fingerprintLoss_nonneg fp tf₁, fingerprintLoss_eq_zero_iff fp tf₂ |>.1 <| le_antisymm h_contra.2 <| fingerprintLoss_nonneg fp tf₂ ] ;

/-
**True parameters uniquely minimize the loss.**
If the empirical rates match the true theoretical rates, then the loss is
zero at the true parameters and positive at any distinct candidate.
-/
theorem true_params_unique_minimizer
    (tf_true tf_other : TheoreticalFingerprint)
    (hne : tf_true.irredRate ≠ tf_other.irredRate ∨
           tf_true.splitRate ≠ tf_other.splitRate)
    (fp : CharpolyFingerprint)
    (hmatch_irr : fp.irredRate = tf_true.irredRate)
    (hmatch_split : fp.splitRate = tf_true.splitRate) :
    fingerprintLoss fp tf_true = 0 ∧ 0 < fingerprintLoss fp tf_other := by
  refine' ⟨ _, _ ⟩ <;> simp_all +decide [ fingerprintLoss ];
  cases hne <;> nlinarith [ mul_self_pos.2 ( sub_ne_zero.2 ‹_› ) ]

/-! ## Theorem 5: Concentration Backbone -/

/-
**Deviation implies squared-loss bound.**
If the empirical rate deviates from p by more than ε, then the squared
deviation exceeds ε². Deterministic backbone of concentration inequalities.
-/
theorem empirical_deviation_implies_loss_bound
    {k m : ℕ} {p ε : ℚ}
    (hm : 0 < m)
    (hε : 0 < ε)
    (hdev : ε < |((k : ℚ) / m) - p|) :
    ε ^ 2 < (((k : ℚ) / m) - p) ^ 2 := by
  convert pow_lt_pow_left₀ hdev ( by positivity ) two_ne_zero using 1 ; norm_num [ sq_abs ]

/-! ## Theorem 6: Dimension Recovery Algorithm -/

/-- Dimension recovery: check if all degrees agree, return the common value. -/
def recoverDimension (degrees : List ℕ) : Option ℕ :=
  match degrees with
  | [] => none
  | d :: ds => if ds.all (· == d) then some d else none

/-
**Dimension recovery correctness.**
-/
theorem recoverDimension_correct
    {d : ℕ} {degrees : List ℕ}
    (hne : degrees ≠ [])
    (hall : ∀ x ∈ degrees, x = d) :
    recoverDimension degrees = some d := by
  rcases degrees with ( _ | ⟨ d', ds ⟩ ) <;> simp_all +decide [ recoverDimension ];
  exact hall.2

/-! ## Cross-Domain Bridge: Cryptographic Distinguisher -/

/-
**Spectral distinguishing theorem (cryptographic bridge).**
If two rates are separated by at least 2δ, then any observation within δ of
one rate is farther than δ from the other. This is the mathematical foundation
for using charpoly statistics as cryptographic distinguishers.
-/
theorem spectral_distinguisher
    {r₁ r₂ δ : ℚ}
    (hδ : 0 < δ)
    (hsep : 2 * δ ≤ |r₁ - r₂|)
    {r_obs : ℚ}
    (hclose : |r_obs - r₁| < δ) :
    δ ≤ |r_obs - r₂| := by
  cases abs_cases ( r₁ - r₂ ) <;> cases abs_cases ( r_obs - r₂ ) <;> cases abs_cases ( r_obs - r₁ ) <;> linarith

/-! ## Recognition Score Properties -/

/-
**Recognition score is nonneg.**
-/
theorem recognitionScore_nonneg (fp : CharpolyFingerprint)
    (r₁ r₂ : ℚ) : 0 ≤ recognitionScore fp r₁ r₂ := by
  exact add_nonneg ( sq_nonneg _ ) ( sq_nonneg _ )

/-
**Recognition score is zero iff rates match.**
-/
theorem recognitionScore_eq_zero_iff (fp : CharpolyFingerprint)
    (r₁ r₂ : ℚ) :
    recognitionScore fp r₁ r₂ = 0 ↔
      fp.irredRate = r₁ ∧ fp.splitRate = r₂ := by
  -- By definition of recognitionScore, we have that recognitionScore fp r₁ r₂ = (fp.irredRate - r₁)^2 + (fp.splitRate - r₂)^2.
  have h_def : recognitionScore fp r₁ r₂ = (fp.irredRate - r₁) ^ 2 + (fp.splitRate - r₂) ^ 2 := by
    rfl;
  constructor <;> intro h <;> simp_all +decide [ add_eq_zero_iff_of_nonneg, sq_nonneg ];
  constructor <;> nlinarith only [ h_def ]

/-
**Perfect fingerprint identifies parameters uniquely.**
If empirical rates match the true rates, then the score is zero at the true
parameters and positive at any distinct candidate.
-/
theorem perfect_fingerprint_identifies_params
    (fp : CharpolyFingerprint)
    {r₁ r₂ r₁' r₂' : ℚ}
    (hmatch₁ : fp.irredRate = r₁)
    (hmatch₂ : fp.splitRate = r₂)
    (hne : r₁ ≠ r₁' ∨ r₂ ≠ r₂') :
    recognitionScore fp r₁ r₂ = 0 ∧ 0 < recognitionScore fp r₁' r₂' := by
  unfold recognitionScore;
  cases hne <;> simp_all +decide [ sub_eq_iff_eq_add ];
  · nlinarith [ mul_self_pos.2 ( sub_ne_zero.2 ‹_› ) ];
  · nlinarith [ mul_self_pos.2 ( sub_ne_zero.2 ‹_› ) ]

/-! ## Necklace Formula: Counting Irreducible Polynomials

The number of monic irreducible polynomials of degree n over 𝔽_q is
N(q,n) = (1/n) ∑_{d|n} μ(n/d) q^d (the necklace formula).

The irreducible rate N(q,n)/q^n ≈ 1/n + O(1/q) depends detectably on q,
enabling field-size identification. -/

/-- The number of monic irreducible polynomials of degree n over 𝔽_q,
defined via the necklace formula. -/
noncomputable def numIrreducibleMonic (q n : ℕ) : ℕ :=
  if n = 0 then 0
  else ((Finset.filter (· ∣ n) (Finset.range (n + 1))).sum
    (fun d => (ArithmeticFunction.moebius (n / d) : ℤ) * (q ^ d : ℤ))).toNat / n

/-- The theoretical irreducible rate. -/
noncomputable def irreducibleRate (q n : ℕ) : ℚ :=
  if q = 0 ∨ n = 0 then 0
  else (numIrreducibleMonic q n : ℚ) / (q ^ n : ℚ)
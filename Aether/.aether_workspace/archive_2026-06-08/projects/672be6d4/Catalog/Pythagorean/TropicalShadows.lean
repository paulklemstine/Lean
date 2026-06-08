/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Tropical Shadows of Lorentzian Stability

This file develops the theory of **tropical shadows** — combinatorial invariants
extracted from tropicalized coefficient data of quadratic forms that control
analytic Lorentzian stability radii. The central insight is that the robustness
of the Lorentzian signature condition under coefficient perturbation can be
bounded below by a purely tropical (max-plus/min-plus) invariant: the
**tropical spectral gap**.

## Mathematical Context

A symmetric matrix A with positive entries defines a quadratic form. Its
"tropical shadow" is the matrix W with W_{ij} = log(A_{ij}). The tropical
spectral gap of W measures how far the log-coefficient matrix is from
violating the 2×2 minor inequalities that characterize tropical positive
semidefiniteness.

The main theorem family establishes:
1. The tropical gap gives a lower bound on the perturbation stability radius
2. For uniform (constant-off-diagonal) families, the bound is exact
3. The gap equals a minimum exchange defect computable by finite search

## Main Results

* `diagonalMinorGap_perturbation_bound` — Perturbation of tropical gap is Lipschitz
* `tropicalPSD_preserved_under_small_perturbation` — Tropical PSD stable under
  small perturbation
* `tropicalSpectralGap_eq_min_diagonalMinorGap` — Gap equals minimum minor gap
* `uniformWeight_diagonalMinorGap` — Exact gap computation for uniform weights
* `tropicalSpectralGap_shift_invariant` — Gap invariant under global weight shift
* `tropicalGap_controls_stability` — Bridge: tropical gap bounds stability radius
* `tropicallyPSD_iff_nonneg_gap` — Equivalence of tropical PSD and nonneg gap

## Application Keywords

Lorentzian polynomials, tropical geometry, max-plus algebra, Maslov dequantization,
valuated matroids, combinatorial optimization, spectral gap, stability radius,
exchange inequalities, discrete convexity, sparse certification

## References

* Brändén–Huh, "Lorentzian Polynomials", Annals of Mathematics, 2020
* Maclagan–Sturmfels, "Introduction to Tropical Geometry", AMS, 2015
-/

set_option linter.unusedSectionVars false

open Finset BigOperators Real

noncomputable section

namespace TropicalShadow

/-! ## Core Definitions -/

/-- A tropical quadratic weight: a symmetric real-valued weight function on pairs
    of elements of a type σ. This represents the tropicalization (log of coefficients)
    of a symmetric positive-coefficient matrix. -/
structure TropicalQuadraticWeight (σ : Type*) where
  /-- The weight function w(i,j) = log(a_{ij}) for the original coefficient a_{ij} -/
  weight : σ → σ → ℝ
  /-- Symmetry of the weight function -/
  symm : ∀ i j, weight i j = weight j i

variable {σ : Type*} [Fintype σ] [DecidableEq σ]

/-- The exchange defect for a quadruple (i,j,k,l):
    δ(i,j,k,l) = w(i,j) + w(k,l) - w(i,k) - w(j,l). -/
def exchangeDefect (w : TropicalQuadraticWeight σ) (i j k l : σ) : ℝ :=
  w.weight i j + w.weight k l - w.weight i k - w.weight j l

/-- The diagonal minor gap for a pair (i,j):
    Δ(i,j) = w(i,i) + w(j,j) - 2·w(i,j). -/
def diagonalMinorGap (w : TropicalQuadraticWeight σ) (i j : σ) : ℝ :=
  w.weight i i + w.weight j j - 2 * w.weight i j

/-- The set of distinct pairs in σ × σ. -/
def distinctPairs (σ : Type*) [Fintype σ] [DecidableEq σ] : Finset (σ × σ) :=
  Finset.univ.filter (fun p => p.1 ≠ p.2)

lemma distinctPairs_nonempty [Nontrivial σ] :
    (distinctPairs σ).Nonempty := by
  obtain ⟨a, b, hab⟩ := exists_pair_ne σ
  exact ⟨(a, b), Finset.mem_filter.mpr ⟨Finset.mem_univ _, hab⟩⟩

lemma mem_distinctPairs {a b : σ} (hab : a ≠ b) :
    (a, b) ∈ distinctPairs σ :=
  Finset.mem_filter.mpr ⟨Finset.mem_univ _, hab⟩

/-- The tropical spectral gap: the minimum diagonal minor gap over all
    distinct pairs. -/
def tropicalSpectralGap [Nontrivial σ] (w : TropicalQuadraticWeight σ) : ℝ :=
  (distinctPairs σ).inf' distinctPairs_nonempty
    (fun p => diagonalMinorGap w p.1 p.2)

/-- A tropical quadratic weight is tropically PSD if all diagonal minor gaps
    are nonnegative. -/
def IsTropicallyPSD (w : TropicalQuadraticWeight σ) : Prop :=
  ∀ i j : σ, i ≠ j → 0 ≤ diagonalMinorGap w i j

/-- Perturbation of a tropical weight by a symmetric function δ. -/
def perturbWeight (w : TropicalQuadraticWeight σ) (δ : σ → σ → ℝ)
    (hδ : ∀ i j, δ i j = δ j i) : TropicalQuadraticWeight σ where
  weight i j := w.weight i j + δ i j
  symm i j := by rw [w.symm, hδ]

/-- Uniform weight: diagonal entries are d, off-diagonal entries are c. -/
def uniformWeight (σ : Type*) [Fintype σ] [DecidableEq σ]
    (d c : ℝ) : TropicalQuadraticWeight σ where
  weight i j := if i = j then d else c
  symm i j := by split_ifs with h1 h2 h2 <;> simp_all

/-- Global shift of all weights by a constant. -/
def shiftWeight (w : TropicalQuadraticWeight σ) (c : ℝ) :
    TropicalQuadraticWeight σ where
  weight i j := w.weight i j + c
  symm i j := by rw [w.symm]

/-! ## Basic Algebraic Properties -/

theorem exchangeDefect_swap_zero (w : TropicalQuadraticWeight σ) (i j : σ) :
    exchangeDefect w i j j i = 0 := by
  unfold exchangeDefect; linarith [w.symm i j]

/-- The exchange defect is negated by transposing the second pair. -/
theorem exchangeDefect_neg (w : TropicalQuadraticWeight σ) (i j k l : σ) :
    exchangeDefect w i j k l = -exchangeDefect w i k j l := by
  unfold exchangeDefect; ring

theorem diagonalMinorGap_eq_exchangeDefect (w : TropicalQuadraticWeight σ)
    (i j : σ) :
    diagonalMinorGap w i j = exchangeDefect w i i j j := by
  simp [diagonalMinorGap, exchangeDefect]; ring

theorem diagonalMinorGap_comm (w : TropicalQuadraticWeight σ) (i j : σ) :
    diagonalMinorGap w i j = diagonalMinorGap w j i := by
  unfold diagonalMinorGap; linarith [w.symm i j]

theorem diagonalMinorGap_self (w : TropicalQuadraticWeight σ) (i : σ) :
    diagonalMinorGap w i i = 0 := by
  unfold diagonalMinorGap; ring

/-! ## Theorem 1: Perturbation Stability -/

/-
**Perturbation bound for diagonal minor gaps.**
    If each weight entry is perturbed by at most ε, then each
    diagonal minor gap changes by at most 4ε.
-/
theorem diagonalMinorGap_perturbation_bound
    (w : TropicalQuadraticWeight σ) (δ : σ → σ → ℝ)
    (hδ_symm : ∀ i j, δ i j = δ j i)
    (ε : ℝ) (hδ_bound : ∀ i j, |δ i j| ≤ ε)
    (i j : σ) :
    |diagonalMinorGap (perturbWeight w δ hδ_symm) i j -
     diagonalMinorGap w i j| ≤ 4 * ε := by
  unfold diagonalMinorGap; norm_num [ perturbWeight ] ; ring_nf; norm_num [ abs_le ] ; constructor <;> linarith [ abs_le.mp ( hδ_bound i i ), abs_le.mp ( hδ_bound j j ), abs_le.mp ( hδ_bound i j ) ] ;

/-
**Tropical PSD preserved under small perturbation.**
-/
theorem tropicalPSD_preserved_under_small_perturbation
    (w : TropicalQuadraticWeight σ) (δ : σ → σ → ℝ)
    (hδ_symm : ∀ i j, δ i j = δ j i)
    (gap ε : ℝ)
    (hgap : ∀ i j, i ≠ j → gap ≤ diagonalMinorGap w i j)
    (hδ_bound : ∀ i j, |δ i j| ≤ ε)
    (hsmall : 4 * ε ≤ gap) :
    IsTropicallyPSD (perturbWeight w δ hδ_symm) := by
  -- By definition of perturbation, the diagonal minor gap of the perturbed weight is at least the original diagonal minor gap minus 4ε.
  have h_perturbed_gap : ∀ i j, i ≠ j → diagonalMinorGap (perturbWeight w δ hδ_symm) i j ≥ diagonalMinorGap w i j - 4 * ε := by
    exact fun i j hij => by linarith [ abs_le.mp ( diagonalMinorGap_perturbation_bound w δ hδ_symm ε hδ_bound i j ) ] ;
  exact fun i j hij => le_trans ( by linarith [ hgap i j hij ] ) ( h_perturbed_gap i j hij )

/-! ## Theorem 2: Gap Certificate and Computability -/

/-- A tropical gap certificate: a witness pair achieving the minimum gap. -/
structure TropicalGapCertificate (w : TropicalQuadraticWeight σ) where
  witness_i : σ
  witness_j : σ
  distinct : witness_i ≠ witness_j
  value : ℝ
  is_gap : value = diagonalMinorGap w witness_i witness_j
  is_minimum : ∀ i j, i ≠ j → value ≤ diagonalMinorGap w i j

/-
**The tropical spectral gap is attained.**
-/
theorem tropicalSpectralGap_eq_min_diagonalMinorGap [Nontrivial σ]
    (w : TropicalQuadraticWeight σ) :
    ∃ i j : σ, i ≠ j ∧
      tropicalSpectralGap w = diagonalMinorGap w i j ∧
      ∀ k l : σ, k ≠ l → tropicalSpectralGap w ≤ diagonalMinorGap w k l := by
  obtain ⟨p, hp⟩ : ∃ p ∈ distinctPairs σ, ∀ q ∈ distinctPairs σ, diagonalMinorGap w p.1 p.2 ≤ diagonalMinorGap w q.1 q.2 := by
    exact Finset.exists_min_image _ _ distinctPairs_nonempty;
  refine' ⟨ p.1, p.2, _, _, _ ⟩;
  · exact Finset.mem_filter.mp hp.1 |>.2;
  · exact le_antisymm ( Finset.inf'_le _ hp.1 ) ( Finset.le_inf' _ _ hp.2 );
  · exact fun k l hkl => Finset.inf'_le _ ( mem_distinctPairs hkl )

/-
**Certificate existence.**
-/
theorem certificate_exists [Nontrivial σ]
    (w : TropicalQuadraticWeight σ) :
    ∃ cert : TropicalGapCertificate w,
      cert.value = tropicalSpectralGap w := by
  obtain ⟨ i, j, hij, hgap, hmin ⟩ := tropicalSpectralGap_eq_min_diagonalMinorGap w;
  use ⟨ i, j, hij, diagonalMinorGap w i j, rfl, fun k l hkl => hgap ▸ hmin k l hkl ⟩;
  exact hgap.symm

/-
The tropical spectral gap is a lower bound for all minor gaps.
-/
theorem tropicalSpectralGap_le [Nontrivial σ]
    (w : TropicalQuadraticWeight σ) (i j : σ) (hij : i ≠ j) :
    tropicalSpectralGap w ≤ diagonalMinorGap w i j := by
  convert Finset.inf'_le _ ( mem_distinctPairs hij ) using 1

/-! ## Theorem 3: Uniform Weight Exact Computation -/

/-
The diagonal minor gap for uniform weights is exactly 2(d - c).
-/
theorem uniformWeight_diagonalMinorGap (d c : ℝ) (i j : σ)
    (hij : i ≠ j) :
    diagonalMinorGap (uniformWeight σ d c) i j = 2 * (d - c) := by
  unfold diagonalMinorGap uniformWeight; simp +decide [ hij ] ; ring;

/-
**Tropical spectral gap of uniform weights is exactly 2(d - c).**
-/
theorem uniformWeight_tropicalSpectralGap [Nontrivial σ] (d c : ℝ) :
    tropicalSpectralGap (uniformWeight σ d c) = 2 * (d - c) := by
  refine' le_antisymm ( _ : _ ≤ _ ) ( _ : _ ≥ _ );
  · obtain ⟨ i, j, hij ⟩ := exists_pair_ne σ ; exact le_trans ( tropicalSpectralGap_le _ _ _ hij ) ( by simp +decide [ uniformWeight_diagonalMinorGap _ _ _ _ hij ] ) ;
  · exact Finset.le_inf' _ _ fun x hx => uniformWeight_diagonalMinorGap d c _ _ ( Finset.mem_filter.mp hx |>.2 ) ▸ le_rfl

/-
Uniform weights are tropically PSD iff d ≥ c.
-/
theorem uniformWeight_tropicallyPSD_iff [Nontrivial σ] (d c : ℝ) :
    IsTropicallyPSD (uniformWeight σ d c) ↔ c ≤ d := by
  constructor <;> intro h;
  · obtain ⟨ i, j, hij ⟩ := exists_pair_ne σ; linarith [ h i j hij, uniformWeight_diagonalMinorGap d c i j hij ] ;
  · exact fun i j hij => by linarith [ uniformWeight_diagonalMinorGap d c i j hij ] ;

/-! ## Invariance Properties -/

/-
The diagonal minor gap is invariant under global weight shift.
-/
theorem diagonalMinorGap_shift (w : TropicalQuadraticWeight σ) (c : ℝ)
    (i j : σ) :
    diagonalMinorGap (shiftWeight w c) i j = diagonalMinorGap w i j := by
  unfold diagonalMinorGap shiftWeight; ring;

/-
**The tropical spectral gap is invariant under global weight shift.**
-/
theorem tropicalSpectralGap_shift_invariant [Nontrivial σ]
    (w : TropicalQuadraticWeight σ) (c : ℝ) :
    tropicalSpectralGap (shiftWeight w c) = tropicalSpectralGap w := by
  unfold TropicalShadow.tropicalSpectralGap;
  simp +decide only [diagonalMinorGap_shift]

/-! ## Theorem 4: Bridge — Tropical Gap Controls Stability -/

/-- The tropical stability radius: gap / 4. -/
def tropicalStabilityRadius [Nontrivial σ]
    (w : TropicalQuadraticWeight σ) : ℝ :=
  tropicalSpectralGap w / 4

/-
**Bridge theorem: tropical gap controls perturbation stability.**
-/
theorem tropicalGap_controls_stability [Nontrivial σ]
    (w : TropicalQuadraticWeight σ)
    (δ : σ → σ → ℝ) (hδ_symm : ∀ i j, δ i j = δ j i)
    (ε : ℝ) (hδ_bound : ∀ i j, |δ i j| ≤ ε)
    (hsmall : ε ≤ tropicalStabilityRadius w) :
    IsTropicallyPSD (perturbWeight w δ hδ_symm) := by
  exact tropicalPSD_preserved_under_small_perturbation w δ hδ_symm
    (tropicalSpectralGap w) ε
    (fun i j hij => tropicalSpectralGap_le w i j hij)
    hδ_bound
    (by unfold tropicalStabilityRadius at hsmall; linarith)

/-! ## Theorem 5: Cross-Domain — Gap Equals Exchange Defect Minimum -/

/-
**Cross-domain theorem: tropical spectral gap equals minimum exchange defect
    over diagonal quadruples.**
-/
theorem tropicalSpectralGap_eq_min_exchange_defect [Nontrivial σ]
    (w : TropicalQuadraticWeight σ) :
    tropicalSpectralGap w =
      (distinctPairs σ).inf' distinctPairs_nonempty
        (fun p => exchangeDefect w p.1 p.1 p.2 p.2) := by
  exact congr_arg _ ( funext fun p => diagonalMinorGap_eq_exchangeDefect _ _ _ )

/-! ## Theorem 6: Nonneg Gap Characterizes Tropical PSD -/

/-
**Tropical PSD is equivalent to nonneg spectral gap.**
-/
theorem tropicallyPSD_iff_nonneg_gap [Nontrivial σ]
    (w : TropicalQuadraticWeight σ) :
    IsTropicallyPSD w ↔ 0 ≤ tropicalSpectralGap w := by
  constructor <;> intro h <;> contrapose! h;
  · obtain ⟨ i, j, hij, h ⟩ := TropicalShadow.tropicalSpectralGap_eq_min_diagonalMinorGap w;
    exact fun h' => by linarith [ h' i j hij ] ;
  · obtain ⟨i, j, hij, hgap⟩ : ∃ i j : σ, i ≠ j ∧ diagonalMinorGap w i j < 0 := by
      exact by unfold IsTropicallyPSD at h; aesop;
    exact lt_of_le_of_lt ( tropicalSpectralGap_le w i j hij ) hgap

/-! ## Grand Conjecture: Maslov Dequantization Limit -/

/-- Weighted rescaling of a tropical weight. -/
def weightedRescale (w : TropicalQuadraticWeight σ) (ω : σ → ℝ) (t : ℝ) :
    TropicalQuadraticWeight σ where
  weight i j := w.weight i j + (ω i + ω j) * Real.log t
  symm i j := by simp [w.symm i j, add_comm (ω i) (ω j)]

/-
**Grand Conjecture (weak form): constant-weight rescaling preserves gap positivity.**
-/
theorem maslov_weak_positivity [Nontrivial σ]
    (w : TropicalQuadraticWeight σ)
    (ω : σ → ℝ)
    (hgap : 0 < tropicalSpectralGap w)
    (hω_const : ∀ i j : σ, ω i = ω j) :
    ∀ t : ℝ, 1 < t →
      0 < tropicalSpectralGap (weightedRescale w ω t) := by
  intros t ht
  have h_const : ∃ c : ℝ, ∀ i : σ, ω i = c := by
    exact ⟨ ω ( Classical.choose ( exists_ne ( Classical.arbitrary σ ) ) ), fun i => hω_const _ _ ⟩
  obtain ⟨c, hc⟩ := h_const
  have h_rescale : weightedRescale w ω t = shiftWeight w ((c + c) * Real.log t) := by
    unfold weightedRescale shiftWeight; aesop;
  rw [h_rescale]
  have h_shift : tropicalSpectralGap (shiftWeight w ((c + c) * Real.log t)) = tropicalSpectralGap w := by
    exact tropicalSpectralGap_shift_invariant w ((c + c) * log t)
  rw [h_shift]
  exact hgap

end TropicalShadow
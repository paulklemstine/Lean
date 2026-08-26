import Mathlib
import Computation.SpectralUnfoldingGapStatistics

/-!
# The exact two-level correlation of the unfolded quadratic spectrum: a staircase

This file computes the two-level correlation function `pairCorrCount` of the unfolded
quadratic spectrum (the picket fence `λ_k = k`) **exactly, for every window size `n` and
every distance `t ≥ 0`**:

`picket_pairCorr_formula` : `R₂(n,t) = 2 ∑_{d=1}^{⌊t⌋} (n - d)`,

whence `picket_pairCorr_closed_form` : `R₂(n,t) = 2⌊t⌋n - ⌊t⌋(⌊t⌋+1)` as soon as
`⌊t⌋ ≤ n`, and after normalization `picket_pairCorr_density_tendsto` :

`R₂(n,t)/n → 2⌊t⌋`.

The limit is a **staircase**: it is constant between consecutive integers
(`picket_pairCorr_staircase`).  This is the sharpest possible contrast with the two
random-matrix universality classes, whose two-level densities are
*continuous* in `t` (`2t` for Poisson, `2t - ∫ sinc²` for the GUE).  In particular the
deterministic spectrum is not described by either class at any scale.
-/

namespace Catalog.Computation.SpectralStaircase

open Catalog.Computation.SpectralUnfolding
open Finset Filter
open scoped Topology

/-- The distance between two natural numbers, as a natural number. -/
def natDist (i j : ℕ) : ℕ := max i j - min i j

lemma abs_cast_sub_eq_natDist (i j : ℕ) : |(i : ℝ) - (j : ℝ)| = (natDist i j : ℝ) := by
  rcases le_total i j with h | h
  · have h1 : (i : ℝ) ≤ (j : ℝ) := by exact_mod_cast h
    rw [abs_of_nonpos (by linarith), natDist, max_eq_right h, min_eq_left h, Nat.cast_sub h]
    ring
  · have h1 : (j : ℝ) ≤ (i : ℝ) := by exact_mod_cast h
    rw [abs_of_nonneg (by linarith), natDist, max_eq_left h, min_eq_right h, Nat.cast_sub h]

lemma natDist_pos_of_ne {i j : ℕ} (h : i ≠ j) : 0 < natDist i j := by
  rcases lt_or_gt_of_ne h with h' | h' <;> simp [natDist] <;> omega

open scoped Classical in
/-- **The exact two-level correlation of the picket fence.** -/
theorem picket_pairCorr_formula (n : ℕ) (t : ℝ) (ht : 0 ≤ t) :
    pairCorrCount unfoldedQuad n t = 2 * ∑ d ∈ Finset.Icc 1 ⌊t⌋₊, (n - d) := by
  classical
  set m : ℕ := ⌊t⌋₊ with hm
  have hfloor : (m : ℝ) ≤ t := Nat.floor_le ht
  have hset : Finset.filter
      (fun p : ℕ × ℕ => p.1 ≠ p.2 ∧ |unfoldedQuad p.1 - unfoldedQuad p.2| ≤ t)
      ((range n) ×ˢ (range n))
      = (Finset.Icc 1 m).biUnion (fun d =>
          ((range (n - d)).image (fun i => (i, i + d)))
            ∪ ((range (n - d)).image (fun i => (i + d, i)))) := by
    ext ⟨i, j⟩
    simp only [Finset.mem_filter, Finset.mem_product, mem_range, Finset.mem_biUnion,
      Finset.mem_union, Finset.mem_image, Finset.mem_Icc, unfoldedQuad_eq, Prod.mk.injEq]
    constructor
    · rintro ⟨⟨hi, hj⟩, hne, hle⟩
      rw [abs_cast_sub_eq_natDist] at hle
      have hd1 : 1 ≤ natDist i j := natDist_pos_of_ne hne
      have hdm : natDist i j ≤ m := by
        rw [hm]
        exact Nat.le_floor hle
      refine ⟨natDist i j, ⟨hd1, hdm⟩, ?_⟩
      rcases lt_or_gt_of_ne hne with h | h
      · left
        refine ⟨i, ?_, rfl, ?_⟩ <;> simp only [natDist] <;> omega
      · right
        refine ⟨j, ?_, ?_, rfl⟩ <;> simp only [natDist] <;> omega
    · rintro ⟨d, ⟨hd1, hdm⟩, hcase⟩
      have hdt : (d : ℝ) ≤ t := le_trans (by exact_mod_cast hdm) hfloor
      rcases hcase with ⟨k, hk, hk1, hk2⟩ | ⟨k, hk, hk1, hk2⟩
      · subst hk1; subst hk2
        refine ⟨⟨by omega, by omega⟩, by omega, ?_⟩
        rw [abs_cast_sub_eq_natDist]
        have : natDist k (k + d) = d := by simp only [natDist]; omega
        rw [this]
        exact hdt
      · subst hk1; subst hk2
        refine ⟨⟨by omega, by omega⟩, by omega, ?_⟩
        rw [abs_cast_sub_eq_natDist]
        have : natDist (k + d) k = d := by simp only [natDist]; omega
        rw [this]
        exact hdt
  have hdisj : ∀ d₁ ∈ Finset.Icc 1 m, ∀ d₂ ∈ Finset.Icc 1 m, d₁ ≠ d₂ →
      Disjoint (((range (n - d₁)).image (fun i => (i, i + d₁)))
          ∪ ((range (n - d₁)).image (fun i => (i + d₁, i))))
        (((range (n - d₂)).image (fun i => (i, i + d₂)))
          ∪ ((range (n - d₂)).image (fun i => (i + d₂, i)))) := by
    intro d₁ _ d₂ _ hne
    rw [Finset.disjoint_left]
    rintro ⟨i, j⟩ ha hb
    simp only [Finset.mem_union, Finset.mem_image, mem_range, Prod.mk.injEq] at ha hb
    rcases ha with ⟨k, _, hk1, hk2⟩ | ⟨k, _, hk1, hk2⟩ <;>
      rcases hb with ⟨l, _, hl1, hl2⟩ | ⟨l, _, hl1, hl2⟩ <;> omega
  have hcard : ∀ d ∈ Finset.Icc 1 m,
      (((range (n - d)).image (fun i => (i, i + d)))
        ∪ ((range (n - d)).image (fun i => (i + d, i)))).card = 2 * (n - d) := by
    intro d hd
    rw [Finset.mem_Icc] at hd
    have hinj1 : Function.Injective (fun i : ℕ => (i, i + d)) := by
      intro a b hab
      simpa using congrArg Prod.fst hab
    have hinj2 : Function.Injective (fun i : ℕ => ((i + d, i) : ℕ × ℕ)) := by
      intro a b hab
      simpa using congrArg Prod.snd hab
    have hdd : Disjoint ((range (n - d)).image (fun i => (i, i + d)))
        ((range (n - d)).image (fun i => ((i + d, i) : ℕ × ℕ))) := by
      rw [Finset.disjoint_left]
      rintro ⟨i, j⟩ ha hb
      simp only [Finset.mem_image, mem_range, Prod.mk.injEq] at ha hb
      obtain ⟨k, _, hk1, hk2⟩ := ha
      obtain ⟨l, _, hl1, hl2⟩ := hb
      omega
    rw [Finset.card_union_of_disjoint hdd, Finset.card_image_of_injective _ hinj1,
      Finset.card_image_of_injective _ hinj2, card_range]
    omega
  have hpd : (↑(Finset.Icc 1 m) : Set ℕ).PairwiseDisjoint (fun d =>
      ((range (n - d)).image (fun i => (i, i + d)))
        ∪ ((range (n - d)).image (fun i => (i + d, i)))) := by
    intro d₁ h1 d₂ h2 hne
    simp only [Function.onFun]
    exact hdisj d₁ (by simpa using h1) d₂ (by simpa using h2) hne
  rw [pairCorrCount, hset, Finset.card_biUnion hpd, Finset.sum_congr rfl hcard,
    ← Finset.mul_sum]

/-- The pair correlation of the picket fence only depends on `⌊t⌋`: it is a staircase,
constant between consecutive integers.  Both universality classes have strictly
increasing, continuous two-level densities. -/
theorem picket_pairCorr_staircase (n : ℕ) (t : ℝ) (ht : 0 ≤ t) :
    pairCorrCount unfoldedQuad n t = pairCorrCount unfoldedQuad n ((⌊t⌋₊ : ℕ) : ℝ) := by
  rw [picket_pairCorr_formula n t ht,
    picket_pairCorr_formula n ((⌊t⌋₊ : ℕ) : ℝ) (Nat.cast_nonneg _), Nat.floor_natCast]

lemma sum_form (n : ℕ) : ∀ m : ℕ, m ≤ n →
    2 * ∑ d ∈ Finset.Icc 1 m, (n - d) + m * (m + 1) = 2 * m * n := by
  intro m
  induction m with
  | zero => simp
  | succ k ih =>
    intro hk
    have hk' : k ≤ n := by omega
    have hsum := ih hk'
    rw [Finset.sum_Icc_succ_top (by omega : 1 ≤ k + 1)]
    zify [hk] at hsum ⊢
    linear_combination hsum

/-- Closed form for the two-level correlation of the picket fence. -/
theorem picket_pairCorr_closed_form (n : ℕ) (t : ℝ) (ht : 0 ≤ t) (hmn : ⌊t⌋₊ ≤ n) :
    pairCorrCount unfoldedQuad n t = 2 * ⌊t⌋₊ * n - ⌊t⌋₊ * (⌊t⌋₊ + 1) := by
  rw [picket_pairCorr_formula n t ht]
  exact Nat.eq_sub_of_add_eq (sum_form n ⌊t⌋₊ hmn)

/-- **The pair-correlation density of the unfolded quadratic spectrum is the staircase
`2⌊t⌋`**, not the continuous Poisson value `2t`, and not the GUE value. -/
theorem picket_pairCorr_density_tendsto (t : ℝ) (ht : 0 ≤ t) :
    Tendsto (fun n : ℕ => (pairCorrCount unfoldedQuad n t : ℝ) / n) atTop
      (𝓝 (2 * (⌊t⌋₊ : ℝ))) := by
  set m : ℕ := ⌊t⌋₊ with hm
  have heq : ∀ n : ℕ, m ≤ n → 0 < n →
      (pairCorrCount unfoldedQuad n t : ℝ) / n = 2 * (m : ℝ) - (m * (m + 1) : ℝ) / n := by
    intro n hmn hn
    have hnat : pairCorrCount unfoldedQuad n t = 2 * ∑ d ∈ Finset.Icc 1 m, (n - d) :=
      picket_pairCorr_formula n t ht
    have hsf := congrArg (fun x : ℕ => (x : ℝ)) (sum_form n m hmn)
    have hnR : (n : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr hn.ne'
    have hcast : ((pairCorrCount unfoldedQuad n t : ℕ) : ℝ)
        = 2 * (m : ℝ) * (n : ℝ) - (m : ℝ) * ((m : ℝ) + 1) := by
      rw [hnat]
      push_cast at hsf ⊢
      linarith
    rw [hcast]
    field_simp
  have hlim : Tendsto (fun n : ℕ => 2 * (m : ℝ) - (m * (m + 1) : ℝ) / n) atTop
      (𝓝 (2 * (m : ℝ))) := by
    have h0 : Tendsto (fun n : ℕ => (m * (m + 1) : ℝ) / n) atTop (𝓝 0) :=
      tendsto_const_div_atTop_nhds_zero_nat _
    simpa using tendsto_const_nhds.sub h0
  refine hlim.congr' ?_
  filter_upwards [eventually_ge_atTop (m + 1)] with n hn
  exact (heq n (by omega) (by omega)).symm

end Catalog.Computation.SpectralStaircase
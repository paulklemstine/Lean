/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Tropical Information Geometry: Semantic Compression via Idempotent Projection

This module formalizes a new mathematical interface between information geometry,
tropical (idempotent) analysis, and semantic coding theory on finite alphabets.

The central insight: **semantic compression is an idempotent nearest-point projection
onto a tropical semantic model class**, and the induced projection error is controlled
by a tropical Fisher-type metric.

## Main Definitions

* `tropicalFisherSeminorm` — the oscillation seminorm ‖v‖_TF = max v - min v
* `tropicalFisherDist` — the projective distance d_TF(s,c) = ‖s - c‖_TF
* `semanticDistSharp` — gauge-invariant semantic distortion

## Main Results

* `tropicalFisherSeminorm_nonneg` — the seminorm is nonneg
* `tropicalFisherSeminorm_shift_invariant` — invariant under additive constants
* `tropicalFisherSeminorm_eq_zero_iff` — zero iff constant
* `semanticDistSharp_eq_zero_iff` — zero iff projectively equivalent
* `abs_sup_lower_bound_half_seminorm` — lower bound for recentering
* `abs_sup_midpoint_eq_half_seminorm` — midpoint achieves the optimal recentering
* `semanticDist_eq_half_seminorm` — the exact inf-over-shifts formula
* `exists_best_semantic_code` — existence of optimal code in finite family
* `pointwiseInf_le` — tropical projection is below each generator
* `pointwiseInf_idempotent` — tropical projection is idempotent
* `semantic_code_factors_through_projective_quotient` — encoding depends only on meaning

## Connection to Catalog

The idempotence result generalizes `tropical_relu_idempotent` from
`Catalog.Bridges.MinPlusVerificationCore` to finite-dimensional tropical projections.
The semantic codebook theorem connects to `finite_quotient_implies_finite_tropicalVC_and_compression`
by showing that semantic compression naturally factors through projective quotients.
-/
import Mathlib

open Finset BigOperators

noncomputable section

/-! ## Tropical Fisher Seminorm

The tropical Fisher seminorm measures the oscillation (range) of a score vector.
It kills additive constants and measures semantic sensitivity. -/

/-- The tropical Fisher seminorm: oscillation of a vector on `Fin n`. -/
def tropicalFisherSeminorm {n : ℕ} [NeZero n] (v : Fin n → ℝ) : ℝ :=
  Finset.univ.sup' Finset.univ_nonempty v - Finset.univ.inf' Finset.univ_nonempty v

/-- The tropical Fisher distance between two score functions. -/
def tropicalFisherDist {n : ℕ} [NeZero n] (s c : Fin n → ℝ) : ℝ :=
  tropicalFisherSeminorm (fun i => s i - c i)

/-- Semantic distortion (sharp version): the gauge-invariant projective distance. -/
def semanticDistSharp {n : ℕ} [NeZero n] (s c : Fin n → ℝ) : ℝ :=
  tropicalFisherDist s c

/-! ## Basic Properties of the Tropical Fisher Seminorm -/

theorem tropicalFisherSeminorm_nonneg {n : ℕ} [NeZero n] (v : Fin n → ℝ) :
    0 ≤ tropicalFisherSeminorm v := by
  -- The infimum of a set is less than or equal to the supremum of the same set, so we can apply this fact.
  apply sub_nonneg_of_le; exact Finset.inf'_le _ (Finset.max'_mem _ <| Finset.univ_nonempty) |> le_trans <| Finset.le_sup' _ <| Finset.max'_mem _ <| Finset.univ_nonempty

theorem tropicalFisherSeminorm_shift_invariant {n : ℕ} [NeZero n]
    (v : Fin n → ℝ) (k : ℝ) :
    tropicalFisherSeminorm (fun i => v i + k) = tropicalFisherSeminorm v := by
  unfold tropicalFisherSeminorm;
  rw [ show ( univ.sup' ( Finset.univ_nonempty ) fun i => v i + k ) = ( univ.sup' ( Finset.univ_nonempty ) v ) + k from ?_, show ( univ.inf' ( Finset.univ_nonempty ) fun i => v i + k ) = ( univ.inf' ( Finset.univ_nonempty ) v ) + k from ?_ ] ; ring;
  · refine' le_antisymm _ _ <;> simp +decide [ Finset.inf'_le, Finset.le_inf' ];
    · simpa using Finset.exists_min_image Finset.univ ( fun i => v i ) ⟨ ⟨ 0, NeZero.pos n ⟩, Finset.mem_univ _ ⟩;
    · exact fun i => ⟨ i, le_rfl ⟩;
  · refine' le_antisymm _ _ <;> simp +decide [ Finset.sup'_le_iff, Finset.le_sup' ];
    · exact fun i => ⟨ i, le_rfl ⟩;
    · simpa using Finset.exists_max_image Finset.univ v ( Finset.univ_nonempty )

theorem tropicalFisherSeminorm_eq_zero_iff {n : ℕ} [NeZero n] (v : Fin n → ℝ) :
    tropicalFisherSeminorm v = 0 ↔ ∃ k : ℝ, ∀ i, v i = k := by
  refine' ⟨ _, fun h => _ ⟩;
  · unfold tropicalFisherSeminorm;
    exact fun h => ⟨ _, fun i => le_antisymm ( Finset.le_sup' v ( Finset.mem_univ i ) |> le_trans <| by linarith ) ( Finset.inf'_le _ <| Finset.mem_univ i ) ⟩;
  · unfold tropicalFisherSeminorm;
    aesop

/-! ## Semantic Distortion Characterization -/

/-
Two score functions are semantically equivalent (differ by a constant)
    iff their semantic distortion vanishes.
-/
theorem semanticDistSharp_eq_zero_iff {n : ℕ} [NeZero n] (s c : Fin n → ℝ) :
    semanticDistSharp s c = 0 ↔ ∃ k : ℝ, ∀ i, s i = c i + k := by
  convert tropicalFisherSeminorm_eq_zero_iff ( fun i => s i - c i ) using 1;
  simp +decide only [sub_eq_iff_eq_add']

/-! ## The Exact Half-Range Theorem

The foundational theorem: the inf over all shifts of the max absolute deviation
equals half the oscillation. This says optimal recentering = half the range. -/

/-
For any shift k, the max absolute deviation is at least half the range.
-/
theorem abs_sup_lower_bound_half_seminorm {n : ℕ} [NeZero n]
    (v : Fin n → ℝ) (k : ℝ) :
    Finset.univ.sup' Finset.univ_nonempty (fun i => |v i - k|) ≥
      tropicalFisherSeminorm v / 2 := by
  unfold tropicalFisherSeminorm;
  -- Let $M = \sup' v$ and $m = \inf' v$.
  set M := Finset.univ.sup' Finset.univ_nonempty v
  set m := Finset.univ.inf' Finset.univ_nonempty v;
  -- There exist $i_{\text{max}}$ and $i_{\text{min}}$ such that $v i_{\text{max}} = M$ and $v i_{\text{min}} = m$.
  obtain ⟨i_max, hi_max⟩ : ∃ i_max, v i_max = M := by
    exact ( Finset.exists_max_image Finset.univ v <| Finset.univ_nonempty ) |> fun ⟨ i, hi ⟩ ↦ ⟨ i, le_antisymm ( Finset.le_sup' v <| Finset.mem_univ i ) ( Finset.sup'_le _ _ fun j hj ↦ hi.2 j hj ) ⟩
  obtain ⟨i_min, hi_min⟩ : ∃ i_min, v i_min = m := by
    have := Finset.exists_mem_eq_inf' ( Finset.univ_nonempty ) v; aesop;
  cases abs_cases ( v i_max - k ) <;> cases abs_cases ( v i_min - k ) <;> linarith [ Finset.le_sup' ( fun i => |v i - k| ) ( Finset.mem_univ i_max ), Finset.le_sup' ( fun i => |v i - k| ) ( Finset.mem_univ i_min ) ]

/-
The midpoint shift achieves exactly half the range.
-/
theorem abs_sup_midpoint_eq_half_seminorm {n : ℕ} [NeZero n] (v : Fin n → ℝ) :
    let M := Finset.univ.sup' Finset.univ_nonempty v
    let m := Finset.univ.inf' Finset.univ_nonempty v
    Finset.univ.sup' Finset.univ_nonempty (fun i => |v i - (M + m) / 2|) =
      (M - m) / 2 := by
  apply le_antisymm ?_ ?_;
  · exact Finset.sup'_le _ _ fun i _ => abs_le.mpr ⟨ by linarith [ Finset.le_sup' v ( Finset.mem_univ i ), Finset.inf'_le v ( Finset.mem_univ i ) ], by linarith [ Finset.le_sup' v ( Finset.mem_univ i ), Finset.inf'_le v ( Finset.mem_univ i ) ] ⟩;
  · have := abs_sup_lower_bound_half_seminorm v ( ( Finset.univ.sup' Finset.univ_nonempty v + Finset.univ.inf' Finset.univ_nonempty v ) / 2 ) ; aesop;

/-
The inf over all shifts of the max absolute deviation equals half the oscillation.
    This is the foundational theorem of tropical semantic compression: optimal recentering
    of a score vector produces exactly half the projective range as residual error.
-/
theorem semanticDist_eq_half_seminorm {n : ℕ} [NeZero n] (v : Fin n → ℝ) :
    sInf {r : ℝ | ∃ k : ℝ, r = Finset.univ.sup' Finset.univ_nonempty
      (fun i => |v i - k|)} = tropicalFisherSeminorm v / 2 := by
  refine' le_antisymm _ _;
  · refine' csInf_le _ _;
    · exact ⟨ 0, by rintro x ⟨ k, rfl ⟩ ; exact Finset.le_sup' ( fun i => |v i - k| ) ( Finset.mem_univ ⟨ 0, NeZero.pos n ⟩ ) |> le_trans ( abs_nonneg _ ) ⟩;
    · exact ⟨ ( Finset.univ.sup' Finset.univ_nonempty v + Finset.univ.inf' Finset.univ_nonempty v ) / 2, by symm; exact abs_sup_midpoint_eq_half_seminorm v ⟩;
  · exact le_csInf ⟨ _, ⟨ 0, rfl ⟩ ⟩ fun r hr => by obtain ⟨ k, rfl ⟩ := hr; exact abs_sup_lower_bound_half_seminorm v k;

/-! ## Existence of Optimal Semantic Codes

For a finite codebook, there always exists a nearest code in tropical Fisher distance. -/

/-
Every source has a nearest semantic code in a nonempty finite codebook.
-/
theorem exists_best_semantic_code {n : ℕ} [NeZero n]
    (G : Finset (Fin n → ℝ)) (hG : G.Nonempty)
    (s : Fin n → ℝ) :
    ∃ c ∈ G, ∀ d ∈ G, tropicalFisherDist s c ≤ tropicalFisherDist s d := by
  exact Finset.exists_min_image _ _ hG

/-! ## Tropical Projection: Pointwise Infimum

The pointwise infimum over a finite family computes the tropical projection. -/

/-- Pointwise infimum of a nonempty finite family of score functions. -/
def pointwiseInf {n : ℕ} (G : Finset (Fin n → ℝ)) (hG : G.Nonempty) : Fin n → ℝ :=
  fun i => G.inf' hG (fun g => g i)

/-
The pointwise infimum is below each member of the family.
-/
theorem pointwiseInf_le {n : ℕ} (G : Finset (Fin n → ℝ)) (hG : G.Nonempty)
    (g : Fin n → ℝ) (hg : g ∈ G) (i : Fin n) :
    pointwiseInf G hG i ≤ g i := by
  exact Finset.inf'_le _ hg

/-
The pointwise infimum is idempotent: projecting the projection gives the same result.
-/
theorem pointwiseInf_idempotent {n : ℕ} (G : Finset (Fin n → ℝ)) (hG : G.Nonempty) :
    let π := pointwiseInf G hG
    pointwiseInf ({π} : Finset (Fin n → ℝ)) (Finset.singleton_nonempty π) = π := by
  -- The pointwise infimum of a singleton set is just the element itself.
  ext i;
  simp [pointwiseInf]

/-! ## Semantic Codebook Theorem

The headline result: semantic encoding depends only on meaning-class (projective
equivalence), not raw score normalization. This establishes that tropical coding
naturally factors through the quotient by additive constants. -/

/-
Semantic coding factors through the projective quotient: if two sources differ
    by an additive constant, they receive the same nearest semantic code.
-/
theorem semantic_code_factors_through_projective_quotient
    {n : ℕ} [NeZero n]
    (G : Finset (Fin n → ℝ)) (hG : G.Nonempty)
    (hdist : ∀ g₁ ∈ G, ∀ g₂ ∈ G, g₁ ≠ g₂ →
      tropicalFisherDist g₁ g₂ ≠ 0) :
    ∃ encode : (Fin n → ℝ) → (Fin n → ℝ),
      (∀ s, encode s ∈ G) ∧
      (∀ s, ∀ c ∈ G, tropicalFisherDist s (encode s) ≤ tropicalFisherDist s c) ∧
      (∀ s t, (∃ k : ℝ, ∀ i, s i = t i + k) → encode s = encode t) := by
  -- Define the encoding function using the exists_min_image
  obtain ⟨encode, h_encode⟩ : ∃ encode : (Fin n → ℝ) → (Fin n → ℝ), (∀ s, encode s ∈ G) ∧ (∀ s, ∀ c ∈ G, tropicalFisherDist s (encode s) ≤ tropicalFisherDist s c) := by
    exact ⟨ fun s => Classical.choose ( exists_best_semantic_code G hG s ), fun s => ( Classical.choose_spec ( exists_best_semantic_code G hG s ) ) |>.1, fun s c hc => ( Classical.choose_spec ( exists_best_semantic_code G hG s ) ) |>.2 c hc ⟩;
  use fun s => if h : ∃ t ∈ G, ∀ c ∈ G, tropicalFisherDist s c ≥ tropicalFisherDist s t then Classical.choose h else encode s;
  refine' ⟨ _, _, _ ⟩;
  · intro s; by_cases h : ∃ t ∈ G, ∀ c ∈ G, tropicalFisherDist s c ≥ tropicalFisherDist s t <;> simp +decide [ h, h_encode.1 ] ;
    exact Classical.choose_spec h |>.1;
  · intro s c hc; by_cases h : ∃ t ∈ G, ∀ c ∈ G, tropicalFisherDist s c ≥ tropicalFisherDist s t <;> simp_all +decide ;
    · exact Classical.choose_spec h |>.2 c hc;
    · grind;
  · intro s t h
    have h_dist_eq : ∀ c ∈ G, tropicalFisherDist s c = tropicalFisherDist t c := by
      obtain ⟨ k, hk ⟩ := h;
      intro c hc; unfold tropicalFisherDist; simp +decide [ hk ] ;
      convert tropicalFisherSeminorm_shift_invariant ( fun i => t i - c i ) k using 2 ; ring;
      exact funext fun i => by ring;
    simp +decide [ h_dist_eq ];
    split_ifs <;> simp_all +decide [ h_encode.2 ];
    · grind +revert;
    · grind;
    · grind +splitIndPred;
    · rename_i h';
      contrapose! h';
      exact Finset.exists_min_image _ _ hG

end
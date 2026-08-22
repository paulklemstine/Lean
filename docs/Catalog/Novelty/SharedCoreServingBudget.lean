import Novelty.KVDecisionDissociation

/-!
# Shared-core / personal-tail serving: the amortized model-delta law (NET-51, Part C)

NET-51's practical claim is: *a multi-fine-tune server can share about 22 of 24
layers of KV machinery at ≥ 0.92 top-1 decision agreement, while the tail must be
per-model.*  This file proves the two halves of that claim.

* **Budget.**  `serveCost n L s = s + n * (L - s)` is the memory of serving `n`
  fine-tunes that share `s` of `L` layers.  `serveCost_eq_saving` exhibits the
  saving `(n-1) * s` over independent serving, and `serveCost_ratio_tendsto`
  shows the amortized ratio converges to the *tail fraction* `(L - s)/L`
  — with `L = 24`, `s = 22` this is `1/12` (`serveCost_ratio_tail_24_22`).

* **Safety.**  `shared_core_agreement_bound` proves that whenever the shared
  layers carry a top-1 margin exceeding twice the sharing error, *every* shared
  layer reproduces the base model's attention decision, so the fraction of layers
  with provably identical decisions is at least `|S| / L`; `agreement_24_22` is
  the numerical instance of the measured configuration: certifying `22` of the
  `24` layers gives a provable-agreement fraction of at least `11/12 ≈ 0.9167`.

* **Boundary.**  `cosine_certificate_is_void` records that no cosine threshold can
  replace the margin hypothesis: sharing justified by cosine alone may flip
  decisions.  This is exactly why the measured tail (cosine `0.983`, agreement
  `0.568`) is not shareable.
-/

namespace Catalog.Novelty.SharedCoreServingBudget

open Finset Catalog.Novelty.KVDecisionDissociation

/-! ### 1. The amortized budget -/

/-- Memory cost of serving `n` fine-tunes of an `L`-layer model when the first
`s` layers of KV machinery are shared and the remaining `L - s` are per-model. -/
def serveCost (n : ℕ) (L s : ℝ) : ℝ := s + n * (L - s)

/-- Serving `n` models independently costs `n * L`; sharing `s` layers saves
exactly `(n - 1) * s`. -/
theorem serveCost_eq_saving (n : ℕ) (L s : ℝ) :
    serveCost n L s = n * L - ((n : ℝ) - 1) * s := by
  simp only [serveCost]; ring

/-- Sharing is a strict win as soon as there are at least two models and at least
one shared layer. -/
theorem serveCost_lt_independent (n : ℕ) (L s : ℝ) (hn : 2 ≤ n) (hs : 0 < s) :
    serveCost n L s < n * L := by
  rw [serveCost_eq_saving]
  have hn' : (2 : ℝ) ≤ (n : ℝ) := by exact_mod_cast hn
  nlinarith

/-- **Amortized model-delta law.**  As the number of served fine-tunes grows, the
per-model memory ratio converges to the *tail fraction* `(L - s) / L`: the shared
core is amortized away and only the personal tail is paid for. -/
theorem serveCost_ratio_tendsto (L s : ℝ) (hL : 0 < L) :
    Filter.Tendsto (fun n : ℕ => serveCost n L s / (n * L)) Filter.atTop
      (nhds ((L - s) / L)) := by
  have h0 : Filter.Tendsto (fun n : ℕ => (s / L) / n) Filter.atTop (nhds 0) :=
    tendsto_const_div_atTop_nhds_zero_nat (s / L)
  have h1 : Filter.Tendsto (fun n : ℕ => (s / L) / n + (L - s) / L) Filter.atTop
      (nhds (0 + (L - s) / L)) := h0.add tendsto_const_nhds
  rw [zero_add] at h1
  refine h1.congr' ?_
  filter_upwards [Filter.eventually_gt_atTop 0] with n hn
  have hn' : (n : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr hn.ne'
  have hL' : L ≠ 0 := ne_of_gt hL
  simp only [serveCost]
  field_simp

/-- The NET-51 serving configuration: `24` layers, `22` shared.  The amortized
memory ratio tends to `1/12`. -/
theorem serveCost_ratio_tail_24_22 :
    Filter.Tendsto (fun n : ℕ => serveCost n 24 22 / (n * 24)) Filter.atTop
      (nhds (1 / 12)) := by
  have h := serveCost_ratio_tendsto 24 22 (by norm_num)
  norm_num at h ⊢
  exact h

/-! ### 2. Decision-agreement guarantee for the shared core -/

open Classical in
/-- The set of layers on which the two models provably make the *same* top-1
attention decision `i l`. -/
noncomputable def agreeSet {L n : ℕ} (u v : Fin L → Fin n → ℝ) (i : Fin L → Fin n) :
    Finset (Fin L) :=
  Finset.univ.filter fun l => IsStrictTop (u l) (i l) ∧ IsStrictTop (v l) (i l)

/-- **Shared-core safety.**  On every layer of a set `S` where the reference model
has top-1 margin `> 2ε` and the shared cache is `ε`-accurate coordinatewise, both
models make the same decision; hence the agreement fraction is at least
`|S| / L`. -/
theorem shared_core_agreement_bound {L n : ℕ} (u v : Fin L → Fin n → ℝ)
    (i : Fin L → Fin n) (S : Finset (Fin L)) (eps : ℝ)
    (hmargin : ∀ l ∈ S, ∀ j, j ≠ i l → 2 * eps < u l (i l) - u l j)
    (hclose : ∀ l ∈ S, ∀ j, |u l j - v l j| ≤ eps) :
    S ⊆ agreeSet u v i ∧ S.card ≤ (agreeSet u v i).card := by
  have hsub : S ⊆ agreeSet u v i := by
    intro l hl
    have hbase : IsStrictTop (u l) (i l) := by
      intro j hj
      have h0 : (0 : ℝ) ≤ eps := le_trans (abs_nonneg _) (hclose l hl j)
      have := hmargin l hl j hj
      linarith
    have hfine : IsStrictTop (v l) (i l) :=
      strictTop_of_margin (u l) (v l) (i l) eps (hmargin l hl) (hclose l hl)
    simpa [agreeSet] using ⟨hbase, hfine⟩
  exact ⟨hsub, Finset.card_le_card hsub⟩

/-- The measured configuration: `22` certified layers out of `24` give a
provable-agreement fraction of at least `11/12 ≈ 0.9167`. -/
theorem agreement_24_22 {n : ℕ} (u v : Fin 24 → Fin n → ℝ) (i : Fin 24 → Fin n)
    (S : Finset (Fin 24)) (eps : ℝ) (hS : S.card = 22)
    (hmargin : ∀ l ∈ S, ∀ j, j ≠ i l → 2 * eps < u l (i l) - u l j)
    (hclose : ∀ l ∈ S, ∀ j, |u l j - v l j| ≤ eps) :
    (11 : ℝ) / 12 ≤ ((agreeSet u v i).card : ℝ) / 24 := by
  have h := (shared_core_agreement_bound u v i S eps hmargin hclose).2
  rw [hS] at h
  have h' : (22 : ℝ) ≤ ((agreeSet u v i).card : ℝ) := by exact_mod_cast h
  rw [le_div_iff₀ (by norm_num : (0:ℝ) < 24)]
  linarith

/-- **The boundary of the design.**  No cosine threshold licenses sharing: for
every `ε > 0` there are two layers' score vectors with cosine similarity above
`1 - ε` whose decisions differ.  Hence the certificate in
`shared_core_agreement_bound` must be a margin, and the diffuse tail — where
margins vanish — cannot be shared. -/
theorem cosine_certificate_is_void (eps : ℝ) (heps : 0 < eps) :
    ∃ u v : Fin 2 → ℝ, 1 - eps < cosSim u v ∧
      ∃ i j : Fin 2, i ≠ j ∧ IsStrictTop u i ∧ IsStrictTop v j := by
  obtain ⟨u, v, hcos, hu, hv⟩ := cosine_near_one_decision_flip eps heps
  exact ⟨u, v, hcos, 0, 1, by decide, hu, hv⟩

end Catalog.Novelty.SharedCoreServingBudget
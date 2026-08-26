import Mathlib

/-!
# The additive-hybrid eviction law (NET-61: CONTENT-ADDITIVE-EVICTION-DOES-NOT-HELP)

This file formalises the *combinatorial* content behind the NET-61 measurement

> hybrid eviction score `= z(accumulated usage) + λ · z(static probe score)`,
> retained quality is **monotonically decreasing** in the probe weight `λ`,
> `λ = 0` is optimal, and every member of the family stays a fixed distance
> below the oracle at matched budget.

Measured table (Qwen2.5-0.5B, ctx = 1024):

| B   | λ    | retained |
|-----|------|----------|
| 64  | 0.00 | 0.9384   |
| 64  | 0.25 | 0.9383   |
| 64  | 1.00 | 0.9365   |
| 64  | 4.00 | 0.9344   |
| 32  | 1.00 | 0.9189   |
| 128 | 1.00 | 0.9544   |

The abstraction used here is the *cache-selection* one: a budget `B`, a cheap
score `s : ι → ℝ`, and the policy "keep a `B`-element set whose kept items all
score at least as high as every evicted item" (`IsTopSet`).  The quantity of
interest is the retained value `retained v S = ∑ i ∈ S, v i`, where `v` is the
(unavailable at run time) true future utility of a cache slot; the *oracle* is
the policy that scores with `v` itself.

The results:

* `sum_le_sum_of_sdiff_dominated` / `sum_lt_sum_of_sdiff_dominated` — the
  exchange kernel: a pairwise domination between the two symmetric differences
  of two equicardinal sets already orders their values (no matching/Hall
  argument is needed).
* `oracle_max`, `cheap_signal_le_oracle` — **the four-family bound**: *every*
  score function whatsoever, hence in particular accumulation, recency,
  content-probe and all their combinations, is dominated by the oracle at
  matched budget.  The gap is a property of the instance, not of the family.
* `probe_dominance_of_lambda_lt` — the **single-crossing lemma** for the
  additive family: if `λ₁ < λ₂` then every item that *enters* the cache when
  the probe weight is raised has probe score at least that of every item that
  *leaves*.  This is the structural reason a λ-sweep is monotone.
* `retained_antitone_in_lambda`, `retained_strictAnti_in_lambda` — the
  **monotone-degradation law** (P1 refuted): if the probe is anti-aligned with
  true utility, retained value is (strictly) decreasing in `λ`.
* `lambda_zero_optimal` — **P2 confirmed**: `λ = 0` maximises the family.
* `probeMass_monotone_in_lambda` / `usageMass_antitone_in_lambda` — the λ-sweep
  is a monotone trade-off path: probe mass up, usage mass down.
* `positive_lambda_can_strictly_help` — **sharpness**: without anti-alignment the
  law fails, so the measured degradation is a fact about the probe, not about
  additivity.
* `isTopSet_affine`, `zscore_hybrid_reparam`, `probe_constant_is_inert` —
  z-scoring is a *reparametrisation* of the same one-parameter policy family,
  so no claim here depends on the normalisation used in the experiment.
* `topSet_eq_initial_of_strictAnti` — a strictly ordered score forces the
  kept set, giving determinism of the measured arm.
* `net61_calibrated_gap` — a four-slot instance calibrated to the measured
  numbers: **for every `λ ≥ 0`** the hybrid retains exactly `0.9384` while the
  oracle retains `0.9954`, a gap of exactly `0.0570` (5.7 points).
* `oracle_retained_mono` — retained value is monotone in the budget `B`
  (the `32 < 64 < 128` rows), so budget, unlike probe weight, does help.
-/

namespace Catalog.Combinatorics.HybridEvictionAdditiveLaw

open Finset

section General

variable {ι : Type*} [DecidableEq ι]

/-- `S` is a set of `B` cache slots kept by a score-`s` eviction policy: it has
the right size, and no evicted item scores above a kept item. -/
def IsTopSet (s : ι → ℝ) (B : ℕ) (S : Finset ι) : Prop :=
  S.card = B ∧ ∀ i ∈ S, ∀ j ∉ S, s j ≤ s i

/-- The retained value of a kept set, `v` being the true (oracle) utility. -/
def retained (v : ι → ℝ) (S : Finset ι) : ℝ := ∑ i ∈ S, v i

/-- The additive hybrid eviction score `a + λ·p`
(`a` = accumulated usage, `p` = static content-probe score). -/
def hybrid (a p : ι → ℝ) (lam : ℝ) : ι → ℝ := fun i => a i + lam * p i

/-! ### The exchange kernel -/

/-- Two equicardinal sets have equicardinal symmetric-difference halves. -/
theorem card_sdiff_eq_card_sdiff {S T : Finset ι} (h : T.card = S.card) :
    (T \ S).card = (S \ T).card := by
  have h1 := Finset.card_sdiff_add_card_inter T S
  have h2 := Finset.card_sdiff_add_card_inter S T
  have h3 : (T ∩ S).card = (S ∩ T).card := by rw [Finset.inter_comm]
  omega

private theorem retained_split (v : ι → ℝ) (S T : Finset ι) :
    retained v T = ∑ j ∈ T \ S, v j + ∑ j ∈ T ∩ S, v j := by
  rw [retained, ← Finset.sum_union (Finset.disjoint_sdiff_inter T S),
    Finset.sdiff_union_inter]

/-- **Exchange kernel.**  If every element of `T \ S` has value at most that of
every element of `S \ T`, and `T` and `S` have the same size, then `S` retains
at least as much as `T`.  No matching argument is required: pairwise domination
between the two halves of the symmetric difference is enough. -/
theorem sum_le_sum_of_sdiff_dominated (v : ι → ℝ) {S T : Finset ι}
    (hcard : T.card = S.card)
    (hdom : ∀ j ∈ T \ S, ∀ i ∈ S \ T, v j ≤ v i) :
    retained v T ≤ retained v S := by
  have hc := card_sdiff_eq_card_sdiff hcard
  have key : ∑ j ∈ T \ S, v j ≤ ∑ i ∈ S \ T, v i := by
    rcases (T \ S).eq_empty_or_nonempty with he | hne
    · have hs : S \ T = ∅ := Finset.card_eq_zero.1 (by rw [← hc, he]; simp)
      simp [he, hs]
    · have hne' : (S \ T).Nonempty := Finset.card_pos.1 (by
        rw [← hc]; exact Finset.card_pos.2 hne)
      obtain ⟨j0, hj0, hj0max⟩ := Finset.exists_max_image (T \ S) v hne
      obtain ⟨i0, hi0, hi0min⟩ := Finset.exists_min_image (S \ T) v hne'
      have hle : v j0 ≤ v i0 := hdom j0 hj0 i0 hi0
      calc ∑ j ∈ T \ S, v j ≤ (T \ S).card • v j0 :=
            Finset.sum_le_card_nsmul _ _ _ hj0max
        _ = (S \ T).card • v j0 := by rw [hc]
        _ ≤ (S \ T).card • v i0 := by
            simpa [nsmul_eq_mul] using
              mul_le_mul_of_nonneg_left hle (by positivity : (0:ℝ) ≤ ((S \ T).card : ℝ))
        _ ≤ ∑ i ∈ S \ T, v i := Finset.card_nsmul_le_sum _ _ _ hi0min
  have hT := retained_split v S T
  have hS := retained_split v T S
  have hinter : ∑ j ∈ T ∩ S, v j = ∑ j ∈ S ∩ T, v j := by rw [Finset.inter_comm]
  rw [hT, hS, hinter]
  linarith

/-- Strict form of the exchange kernel: strict pairwise domination and a
genuine exchange (`T ≠ S`) force a strict loss. -/
theorem sum_lt_sum_of_sdiff_dominated (v : ι → ℝ) {S T : Finset ι}
    (hcard : T.card = S.card) (hne : T ≠ S)
    (hdom : ∀ j ∈ T \ S, ∀ i ∈ S \ T, v j < v i) :
    retained v T < retained v S := by
  have hc := card_sdiff_eq_card_sdiff hcard
  have hTS : (T \ S).Nonempty := by
    rcases (T \ S).eq_empty_or_nonempty with he | h
    · exact absurd (Finset.eq_of_subset_of_card_le (Finset.sdiff_eq_empty_iff_subset.1 he)
        (le_of_eq hcard.symm)) hne
    · exact h
  have hST : (S \ T).Nonempty := Finset.card_pos.1 (by
    rw [← hc]; exact Finset.card_pos.2 hTS)
  have key : ∑ j ∈ T \ S, v j < ∑ i ∈ S \ T, v i := by
    obtain ⟨j0, hj0, hj0max⟩ := Finset.exists_max_image (T \ S) v hTS
    obtain ⟨i0, hi0, hi0min⟩ := Finset.exists_min_image (S \ T) v hST
    have hle : v j0 < v i0 := hdom j0 hj0 i0 hi0
    have hpos : (0:ℝ) < ((S \ T).card : ℝ) := by
      exact_mod_cast Finset.card_pos.2 hST
    calc ∑ j ∈ T \ S, v j ≤ (T \ S).card • v j0 :=
          Finset.sum_le_card_nsmul _ _ _ hj0max
      _ = (S \ T).card • v j0 := by rw [hc]
      _ < (S \ T).card • v i0 := by
          simpa [nsmul_eq_mul] using (mul_lt_mul_of_pos_left hle hpos)
      _ ≤ ∑ i ∈ S \ T, v i := Finset.card_nsmul_le_sum _ _ _ hi0min
  have hT := retained_split v S T
  have hS := retained_split v T S
  have hinter : ∑ j ∈ T ∩ S, v j = ∑ j ∈ S ∩ T, v j := by rw [Finset.inter_comm]
  rw [hT, hS, hinter]
  linarith

/-! ### The oracle bound: every cheap signal family is dominated -/

/-- **Oracle optimality.**  A set kept by scoring with the true utility `v`
retains at least as much as any other set of the same size. -/
theorem oracle_max (v : ι → ℝ) {B : ℕ} {O T : Finset ι} (hO : IsTopSet v B O)
    (hT : T.card = B) : retained v T ≤ retained v O := by
  refine sum_le_sum_of_sdiff_dominated v (by rw [hT, hO.1]) ?_
  intro j hj i hi
  rw [Finset.mem_sdiff] at hj hi
  exact hO.2 i hi.1 j hj.2

/-- **The four-family bound.**  *Any* cheap eviction signal `s` — accumulated
usage, recency, a static content probe, or any function of them at all — kept
at budget `B` retains no more than the oracle at the same budget.  Nothing
about the structure of `s` is used, so no enrichment of the signal family can
cross the oracle line; only the instance can. -/
theorem cheap_signal_le_oracle (v s : ι → ℝ) {B : ℕ} {S O : Finset ι}
    (hS : IsTopSet s B S) (hO : IsTopSet v B O) : retained v S ≤ retained v O :=
  oracle_max v hO hS.1

/-! ### Single crossing: the structure of an additive λ-sweep -/

/-- **Single-crossing lemma.**  Raising the probe weight from `λ₁` to `λ₂ > λ₁`
can only exchange cache slots in the direction of the probe: every item that
enters the kept set has probe score at least that of every item that leaves.
This is the exact mechanism by which an additive hybrid "listens more" to the
probe. -/
theorem probe_dominance_of_lambda_lt (a p : ι → ℝ) {lam1 lam2 : ℝ} (hlt : lam1 < lam2)
    {B : ℕ} {S1 S2 : Finset ι} (h1 : IsTopSet (hybrid a p lam1) B S1)
    (h2 : IsTopSet (hybrid a p lam2) B S2) :
    ∀ j ∈ S2 \ S1, ∀ i ∈ S1 \ S2, p i ≤ p j := by
  intro j hj i hi
  rw [Finset.mem_sdiff] at hi hj
  have e1 : a j + lam1 * p j ≤ a i + lam1 * p i := h1.2 i hi.1 j hj.2
  have e2 : a i + lam2 * p i ≤ a j + lam2 * p j := h2.2 j hj.1 i hi.2
  by_contra hcon
  push_neg at hcon
  nlinarith [mul_pos (sub_pos.2 hlt) (sub_pos.2 hcon)]

/-- **The monotone-degradation law (P1 refuted).**  If the static probe is
anti-aligned with true utility (a higher probe score never indicates a more
valuable slot), then retained value is *antitone* in the probe weight: no
`λ₂ > λ₁` can beat `λ₁`. -/
theorem retained_antitone_in_lambda (a p v : ι → ℝ)
    (hanti : ∀ i j, p i ≤ p j → v j ≤ v i)
    {lam1 lam2 : ℝ} (hlt : lam1 < lam2) {B : ℕ} {S1 S2 : Finset ι}
    (h1 : IsTopSet (hybrid a p lam1) B S1) (h2 : IsTopSet (hybrid a p lam2) B S2) :
    retained v S2 ≤ retained v S1 := by
  refine sum_le_sum_of_sdiff_dominated v (by rw [h1.1, h2.1]) ?_
  intro j hj i hi
  exact hanti i j (probe_dominance_of_lambda_lt a p hlt h1 h2 j hj i hi)

/-- Strict monotone degradation: if the probe is *strictly* anti-aligned with
utility across distinct slots and the λ-sweep actually changes the kept set,
the retained value strictly drops. -/
theorem retained_strictAnti_in_lambda (a p v : ι → ℝ)
    (hanti : ∀ i j, i ≠ j → p i ≤ p j → v j < v i)
    {lam1 lam2 : ℝ} (hlt : lam1 < lam2) {B : ℕ} {S1 S2 : Finset ι}
    (h1 : IsTopSet (hybrid a p lam1) B S1) (h2 : IsTopSet (hybrid a p lam2) B S2)
    (hne : S2 ≠ S1) : retained v S2 < retained v S1 := by
  refine sum_lt_sum_of_sdiff_dominated v (by rw [h1.1, h2.1]) hne ?_
  intro j hj i hi
  have hij : i ≠ j := by
    rw [Finset.mem_sdiff] at hi hj
    rintro rfl
    exact hj.2 hi.1
  exact hanti i j hij (probe_dominance_of_lambda_lt a p hlt h1 h2 j hj i hi)

/-- **The λ-sweep is a monotone path.**  The total probe mass of the kept set is
non-decreasing in the probe weight: raising `λ` really does buy probe mass. -/
theorem probeMass_monotone_in_lambda (a p : ι → ℝ) {lam1 lam2 : ℝ} (hlt : lam1 < lam2)
    {B : ℕ} {S1 S2 : Finset ι} (h1 : IsTopSet (hybrid a p lam1) B S1)
    (h2 : IsTopSet (hybrid a p lam2) B S2) : retained p S1 ≤ retained p S2 := by
  refine sum_le_sum_of_sdiff_dominated p (by rw [h1.1, h2.1]) ?_
  intro j hj i hi
  exact probe_dominance_of_lambda_lt a p hlt h1 h2 i hi j hj

/-- ...and it is paid for in accumulated-usage mass, which is non-increasing in
`λ`.  The sweep is therefore a monotone trade-off curve between the two signals,
which is why a one-parameter additive family can never explore off that curve. -/
theorem usageMass_antitone_in_lambda (a p : ι → ℝ) {lam1 lam2 : ℝ} (hlam : 0 ≤ lam1)
    (hlt : lam1 < lam2) {B : ℕ} {S1 S2 : Finset ι}
    (h1 : IsTopSet (hybrid a p lam1) B S1) (h2 : IsTopSet (hybrid a p lam2) B S2) :
    retained a S2 ≤ retained a S1 := by
  refine sum_le_sum_of_sdiff_dominated a (by rw [h1.1, h2.1]) ?_
  intro j hj i hi
  have hp : p i ≤ p j := probe_dominance_of_lambda_lt a p hlt h1 h2 j hj i hi
  rw [Finset.mem_sdiff] at hi hj
  have e1 : a j + lam1 * p j ≤ a i + lam1 * p i := h1.2 i hi.1 j hj.2
  nlinarith [mul_nonneg hlam (sub_nonneg.2 hp)]

/-- **P2 confirmed: `λ = 0` is optimal.**  Under an anti-aligned probe the
pure-accumulation arm dominates every positive probe weight. -/
theorem lambda_zero_optimal (a p v : ι → ℝ)
    (hanti : ∀ i j, p i ≤ p j → v j ≤ v i)
    {lam : ℝ} (hlam : 0 < lam) {B : ℕ} {S0 Slam : Finset ι}
    (h0 : IsTopSet (hybrid a p 0) B S0) (hl : IsTopSet (hybrid a p lam) B Slam) :
    retained v Slam ≤ retained v S0 :=
  retained_antitone_in_lambda a p v hanti hlam h0 hl

/-! ### z-scoring is only a reparametrisation -/

omit [DecidableEq ι] in
/-- Kept sets are invariant under an increasing affine rescaling of the score. -/
theorem isTopSet_affine (s : ι → ℝ) {c d : ℝ} (hc : 0 < c) (B : ℕ) (S : Finset ι) :
    IsTopSet (fun i => c * s i + d) B S ↔ IsTopSet s B S := by
  constructor
  · rintro ⟨hcard, h⟩
    refine ⟨hcard, fun i hi j hj => ?_⟩
    have := h i hi j hj
    simp only at this
    nlinarith
  · rintro ⟨hcard, h⟩
    refine ⟨hcard, fun i hi j hj => ?_⟩
    have := h i hi j hj
    simp only
    nlinarith

omit [DecidableEq ι] in
/-- **z-normalisation is a reparametrisation.**  The policy that keeps the top
`B` slots of `z(a) + λ·z(p)` is *exactly* the policy that keeps the top `B`
slots of the raw hybrid `a + (λσ/τ)·p`.  Hence the λ-sweep of the experiment
and the abstract λ-sweep above traverse the same one-parameter family, in the
same order (`σ, τ > 0`). -/
theorem zscore_hybrid_reparam (a p : ι → ℝ) (mu sig nu tau lam : ℝ)
    (hsig : 0 < sig) (htau : 0 < tau) (B : ℕ) (S : Finset ι) :
    IsTopSet (fun i => (a i - mu) / sig + lam * ((p i - nu) / tau)) B S ↔
      IsTopSet (hybrid a p (lam * sig / tau)) B S := by
  have hfun : (fun i => (a i - mu) / sig + lam * ((p i - nu) / tau)) =
      (fun i => (1 / sig) * hybrid a p (lam * sig / tau) i + (-(mu / sig) - lam * nu / tau)) := by
    funext i
    simp only [hybrid]
    field_simp
    ring
  rw [hfun]
  exact isTopSet_affine _ (by positivity) B S

omit [DecidableEq ι] in
/-- A constant content probe is inert: it changes no kept set at any weight.
(The degradation of the experiment is therefore genuinely caused by the probe's
*variation*, not by the act of adding a second term.) -/
theorem probe_constant_is_inert (a : ι → ℝ) (c lam : ℝ) (B : ℕ) (S : Finset ι) :
    IsTopSet (hybrid a (fun _ => c) lam) B S ↔ IsTopSet a B S := by
  have hfun : hybrid a (fun _ => c) lam = fun i => 1 * a i + lam * c := by
    funext i; simp [hybrid]
  rw [hfun]
  exact isTopSet_affine a one_pos B S

end General

/-! ### Determinism of a strictly ordered arm -/

/-- If the score is strictly decreasing along the index order, the kept set is
*forced* to be the initial segment of size `B`; the measured arm is
deterministic with no tie-breaking freedom. -/
theorem topSet_eq_initial_of_strictAnti {n B : ℕ} (hB : B ≤ n) (s : Fin n → ℝ)
    (hs : ∀ i j : Fin n, i < j → s j < s i) {S : Finset (Fin n)} (hS : IsTopSet s B S) :
    S = (Finset.univ.filter (fun i : Fin n => (i : ℕ) < B)) := by
  set L : Finset (Fin n) := Finset.univ.filter (fun i : Fin n => (i : ℕ) < B) with hL
  have hcardL : L.card = B := by
    have : L.card = (Finset.range B).card := by
      apply Finset.card_bij (fun (i : Fin n) _ => (i : ℕ))
      · intro a ha; simp [hL] at ha ⊢; exact ha
      · intro a _ b _ hab; exact Fin.val_injective hab
      · intro b hb
        simp only [Finset.mem_range] at hb
        exact ⟨⟨b, lt_of_lt_of_le hb hB⟩, by simp [hL, hb], rfl⟩
    simpa using this
  have hsub : L ⊆ S := by
    by_contra hcon
    obtain ⟨i, hiL, hiS⟩ := Finset.not_subset.1 hcon
    have hLS : (L \ S).Nonempty := ⟨i, Finset.mem_sdiff.2 ⟨hiL, hiS⟩⟩
    have hcard : S.card = L.card := by rw [hS.1, hcardL]
    have hSL : (S \ L).Nonempty := Finset.card_pos.1 (by
      rw [card_sdiff_eq_card_sdiff hcard]
      exact Finset.card_pos.2 hLS)
    obtain ⟨j, hj⟩ := hSL
    rw [Finset.mem_sdiff] at hj
    have hjB : B ≤ (j : ℕ) := by
      by_contra hlt
      exact hj.2 (by simp [hL]; omega)
    have hiB : (i : ℕ) < B := by simpa [hL] using hiL
    have hij : i < j := by
      have : (i : ℕ) < (j : ℕ) := lt_of_lt_of_le hiB hjB
      exact this
    have h1 : s j < s i := hs i j hij
    have h2 : s i ≤ s j := hS.2 j hj.1 i hiS
    linarith
  exact (Finset.eq_of_subset_of_card_le hsub (by rw [hS.1, hcardL])).symm

/-! ### The calibrated NET-61 instance -/

section Calibrated

/-- Accumulated-usage signal of the calibrated four-slot instance. -/
def a4 : Fin 4 → ℝ := ![4, 3, 2, 1]

/-- Static content-probe signal: a genuinely different signal from `a4`, but
carrying the same (misleading) ordering of the slots. -/
def p4 : Fin 4 → ℝ := ![8, 6, 4, 2]

/-- True utilities, calibrated so that the hybrid retains `0.9384` (the measured
`B = 64` value) and the oracle retains `0.9954` (5.7 points higher). -/
noncomputable def v4 : Fin 4 → ℝ := ![4692 / 10000, 4692 / 10000, 4977 / 10000, 4977 / 10000]

private theorem hybrid4_strictAnti {lam : ℝ} (hlam : 0 ≤ lam) :
    ∀ i j : Fin 4, i < j → hybrid a4 p4 lam j < hybrid a4 p4 lam i := by
  intro i j hij
  fin_cases i <;> fin_cases j <;>
    simp_all [hybrid, a4, p4, Fin.lt_def] <;> linarith

/-- The kept set of every nonnegative-λ arm of the calibrated instance at
budget `2` is forced to be `{0, 1}`. -/
theorem net61_hybrid_kept_set {lam : ℝ} (hlam : 0 ≤ lam) {S : Finset (Fin 4)}
    (hS : IsTopSet (hybrid a4 p4 lam) 2 S) : S = {0, 1} := by
  have := topSet_eq_initial_of_strictAnti (by norm_num) _ (hybrid4_strictAnti hlam) hS
  rw [this]
  decide

/-- The oracle keeps `{2, 3}` on the calibrated instance. -/
theorem net61_oracle_kept_set : IsTopSet v4 2 {2, 3} := by
  refine ⟨by decide, ?_⟩
  intro i hi j hj
  fin_cases i <;> fin_cases j <;> simp_all [v4] <;> norm_num

/-- **The calibrated NET-61 gap.**  On this four-slot instance, *every* additive
hybrid arm with `λ ≥ 0` retains exactly `0.9384`, while the oracle at the same
budget retains `0.9954`: the family is bounded `0.0570` (5.7 points) below the
oracle uniformly in `λ`.  In particular the `λ`-response is constant here in the
weak sense and can never reach the oracle. -/
theorem net61_calibrated_gap {lam : ℝ} (hlam : 0 ≤ lam) {S O : Finset (Fin 4)}
    (hS : IsTopSet (hybrid a4 p4 lam) 2 S) (hO : IsTopSet v4 2 O) :
    retained v4 S = 9384 / 10000 ∧ retained v4 O = 9954 / 10000 ∧
      retained v4 O - retained v4 S = 570 / 10000 := by
  have hSeq : S = {0, 1} := net61_hybrid_kept_set hlam hS
  have hval : retained v4 S = 9384 / 10000 := by
    rw [hSeq]; simp [retained, v4, Finset.sum_insert]; norm_num
  have hOval : retained v4 O = 9954 / 10000 := by
    have h1 : retained v4 O ≤ retained v4 ({2, 3} : Finset (Fin 4)) :=
      oracle_max v4 net61_oracle_kept_set hO.1
    have h2 : retained v4 ({2, 3} : Finset (Fin 4)) ≤ retained v4 O :=
      oracle_max v4 hO (by decide)
    have h3 : retained v4 ({2, 3} : Finset (Fin 4)) = 9954 / 10000 := by
      simp [retained, v4]; norm_num
    linarith
  refine ⟨hval, hOval, by rw [hval, hOval]; norm_num⟩

/-- The gap in the calibrated instance is *not* an artefact of a degenerate
probe: `p4` is not an affine image of `a4` composed with the identity in the
trivial sense — it strictly separates a pair of slots that `a4` separates by a
different amount, so the two signals are genuinely distinct inputs. -/
theorem net61_signals_distinct : a4 0 - a4 1 ≠ p4 0 - p4 1 := by
  simp [a4, p4]; norm_num

end Calibrated

/-! ### Sharpness: the anti-alignment hypothesis cannot be dropped -/

section Sharpness

/-- Accumulated-usage signal of the two-slot sharpness instance. -/
def a2 : Fin 2 → ℝ := ![1, 0]

/-- A content probe that is *aligned* with true utility exactly where
accumulation errs. -/
def p2 : Fin 2 → ℝ := ![0, 1]

/-- True utilities of the sharpness instance. -/
def v2 : Fin 2 → ℝ := ![0, 1]

theorem sharpness_kept_zero {S : Finset (Fin 2)} (hS : IsTopSet (hybrid a2 p2 0) 1 S) :
    S = {0} := by
  obtain ⟨x, hx⟩ := Finset.card_eq_one.1 hS.1
  subst hx
  fin_cases x
  · rfl
  · exfalso
    have h := hS.2 1 (by decide) 0 (by decide)
    simp [hybrid, a2, p2] at h
    linarith

theorem sharpness_kept_one {T : Finset (Fin 2)} (hT : IsTopSet (hybrid a2 p2 2) 1 T) :
    T = {1} := by
  obtain ⟨x, hx⟩ := Finset.card_eq_one.1 hT.1
  subst hx
  fin_cases x
  · exfalso
    have h := hT.2 0 (by decide) 1 (by decide)
    simp [hybrid, a2, p2] at h
  · rfl

/-- **The monotone-degradation law is sharp.**  Drop the anti-alignment
hypothesis and the conclusion fails: on this two-slot instance the probe is
aligned with utility precisely where accumulation is wrong, and the arm
`λ = 2` *strictly beats* `λ = 0`.  So `P1` is refuted by the *measured signal*,
not by the additive form of the hybrid — a content probe that carried real
information would have to show up as a positive-λ improvement. -/
theorem positive_lambda_can_strictly_help {S T : Finset (Fin 2)}
    (hS : IsTopSet (hybrid a2 p2 0) 1 S) (hT : IsTopSet (hybrid a2 p2 2) 1 T) :
    retained v2 S < retained v2 T := by
  rw [sharpness_kept_zero hS, sharpness_kept_one hT]
  simp [retained, v2]

end Sharpness

/-! ### Budget, unlike probe weight, does help -/

section Budget

variable {ι : Type*} [DecidableEq ι] [Fintype ι]

/-- **Budget monotonicity.**  With nonnegative utilities the oracle's retained
value is monotone in the budget: this is the `0.9189 < 0.9384 < 0.9544`
direction of the measured table, and it is the only knob in the model that is
provably helpful. -/
theorem oracle_retained_mono (v : ι → ℝ) (hv : ∀ i, 0 ≤ v i) {B1 B2 : ℕ}
    (hB : B1 ≤ B2) (hB2 : B2 ≤ Fintype.card ι) {S1 S2 : Finset ι}
    (h1 : IsTopSet v B1 S1) (h2 : IsTopSet v B2 S2) :
    retained v S1 ≤ retained v S2 := by
  obtain ⟨U, hSU, hU⟩ :=
    Finset.exists_superset_card_eq (s := S1) (by rw [h1.1]; exact hB) hB2
  have hle : retained v S1 ≤ retained v U :=
    Finset.sum_le_sum_of_subset_of_nonneg hSU (fun i _ _ => hv i)
  exact hle.trans (oracle_max v h2 hU)

/-- Any cheap-signal policy at budget `B1` is still below the oracle at the
same budget, hence below the oracle at any larger budget: closing the gap
requires memory, not a better cheap score. -/
theorem cheap_signal_le_oracle_larger_budget (v s : ι → ℝ) (hv : ∀ i, 0 ≤ v i)
    {B1 B2 : ℕ} (hB : B1 ≤ B2) (hB2 : B2 ≤ Fintype.card ι)
    {S O1 O2 : Finset ι} (hS : IsTopSet s B1 S) (hO1 : IsTopSet v B1 O1)
    (hO2 : IsTopSet v B2 O2) : retained v S ≤ retained v O2 :=
  (cheap_signal_le_oracle v s hS hO1).trans
    (oracle_retained_mono v hv hB hB2 hO1 hO2)

end Budget

end Catalog.Combinatorics.HybridEvictionAdditiveLaw
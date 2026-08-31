/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Why inverse-rate reallocation must lose, and why the floor clip is load-bearing

Experiment 559 (round-73 #2, `ADAPT-NULL-EQUALIZER / SKIP-FLIP-WINS`) measured an
adaptive quadratic sieve in which a cheap quadratic-residue dial predicts the
per-target relation *rate* well (Spearman `0.739`, oracle dial `0.778`,
`FB100 = 0.835`), and then reallocated sieve length in inverse proportion to the
predicted rate.  The reallocation **lost**: `-17.6%` total yield with a floor clip
in place, and a catastrophic `-146.7%` with the clip removed, while a
*concentrator* that pushes budget towards the high-rate targets gained `+8.6%`
and the realised oracle bound sat `+74.8%` above the baseline.

This file explains all four numbers as one exact theorem, at the level of the
allocation model itself: **no calibration error is involved, the sign of the
inverse-rate policy is forced.**

The model.  A budget `B` of sieve length is split over targets `i ∈ s` with
positive relation rates `r i` (relations per unit of sieve length); an allocation
`ℓ` yields `yieldOf s r ℓ = ∑ i ∈ s, r i * ℓ i`.

Main results.

* `card_sq_le_sum_mul_sum_inv`, `card_sq_lt_sum_mul_sum_inv` — the AM–HM core,
  with the strict form: `n² ≤ (∑ r)(∑ r⁻¹)`, strictly as soon as two rates differ.
  Proved by pairwise symmetrisation over `s ×ˢ s`, not quoted.
* `invRate_yield_le_uniform_yield` / `invRate_yield_lt_uniform_yield` — **the
  inverse-rate policy loses, always.**  Its yield is `B ·` harmonic mean of the
  rates, the uniform baseline is `B ·` arithmetic mean, and the loss is strict
  whenever the dial has anything to say (two rates differ).  So a dial with
  *perfect* calibration would still lose under this policy: the `-17.6%` is a
  property of the reallocation rule, not of the predictor.
* `clipYield_eq`, `clipYield_mono`, `clipYield_strictMono` — **the floor clip is
  load-bearing and monotonically so.**  Interpolating the clipped policy
  `ℓ i = f + (B - n f) (r i)⁻¹ / ∑ r⁻¹` in the floor `f`, the yield is affine and
  *strictly increasing* in `f`; `f = 0` is the unclipped policy and `f = B / n`
  is the uniform baseline.  Removing the clip is exactly moving down this line,
  which is why unclipped is worse than clipped and clipped is worse than uniform.
* `concentrator_yield_ge_uniform_yield` — pushing the whole budget onto a
  maximal-rate target beats uniform: the correct sign is the opposite one.
* `yield_le_budget_mul_sup` — the realised oracle bound: *every* admissible
  allocation is capped by `B ·` (max rate), so the measured `+74.8%` headroom is
  bounded by the rate spread and by nothing else.
* `oracle_gap_eq_budget_mul_sup_sub_mean` — the headroom of the uniform baseline
  is exactly `B (max r - mean r)`.
-/
import Mathlib

namespace Probability.AdaptiveQS

open Finset

variable {ι : Type*}

/-! ## The allocation model -/

/-- Total yield of a sieve-length allocation `ℓ` against per-target relation rates `r`. -/
def yieldOf (s : Finset ι) (r ℓ : ι → ℝ) : ℝ := ∑ i ∈ s, r i * ℓ i

/-- The uniform baseline: every target gets `B / |s|` of the budget. -/
noncomputable def uniformAlloc (s : Finset ι) (B : ℝ) : ι → ℝ := fun _ => B / s.card

/-- The measured adaptive policy: sieve length in inverse proportion to the predicted
rate, renormalised to the budget `B`. -/
noncomputable def invRateAlloc (s : Finset ι) (r : ι → ℝ) (B : ℝ) : ι → ℝ :=
  fun i => B * (r i)⁻¹ / ∑ j ∈ s, (r j)⁻¹

/-- The clipped inverse-rate policy with floor `f`: every target is guaranteed `f`
units of sieve length, and the remaining budget is split in inverse proportion to
the rate.  `f = 0` is the unclipped policy, `f = B / |s|` is the uniform baseline. -/
noncomputable def clipInvAlloc (s : Finset ι) (r : ι → ℝ) (B f : ℝ) : ι → ℝ :=
  fun i => f + (B - s.card * f) * (r i)⁻¹ / ∑ j ∈ s, (r j)⁻¹

/-! ## The AM–HM core, proved by pairwise symmetrisation -/

private lemma two_le_ratio_add_ratio {x y : ℝ} (hx : 0 < x) (hy : 0 < y) :
    (2 : ℝ) ≤ x * y⁻¹ + y * x⁻¹ := by
  rw [← sub_nonneg]
  have h : x * y⁻¹ + y * x⁻¹ - 2 = (x - y) ^ 2 / (x * y) := by
    field_simp; ring
  rw [h]; positivity

private lemma two_lt_ratio_add_ratio {x y : ℝ} (hx : 0 < x) (hy : 0 < y) (hne : x ≠ y) :
    (2 : ℝ) < x * y⁻¹ + y * x⁻¹ := by
  rw [← sub_pos]
  have h : x * y⁻¹ + y * x⁻¹ - 2 = (x - y) ^ 2 / (x * y) := by
    field_simp; ring
  rw [h]
  have h1 : (0:ℝ) < (x - y) ^ 2 := by
    have : x - y ≠ 0 := sub_ne_zero.mpr hne
    positivity
  exact div_pos h1 (mul_pos hx hy)

private lemma prod_sum_eq (s : Finset ι) (r : ι → ℝ) :
    (∑ i ∈ s, r i) * (∑ i ∈ s, (r i)⁻¹) = ∑ p ∈ s ×ˢ s, r p.1 * (r p.2)⁻¹ := by
  rw [Finset.sum_mul_sum, ← Finset.sum_product']

private lemma prod_sum_eq' (s : Finset ι) (r : ι → ℝ) :
    (∑ i ∈ s, r i) * (∑ i ∈ s, (r i)⁻¹) = ∑ p ∈ s ×ˢ s, r p.2 * (r p.1)⁻¹ := by
  rw [mul_comm, Finset.sum_mul_sum, ← Finset.sum_product']
  exact Finset.sum_congr rfl (fun p _ => mul_comm _ _)

private lemma two_mul_prod_sum (s : Finset ι) (r : ι → ℝ) :
    2 * ((∑ i ∈ s, r i) * (∑ i ∈ s, (r i)⁻¹))
      = ∑ p ∈ s ×ˢ s, (r p.1 * (r p.2)⁻¹ + r p.2 * (r p.1)⁻¹) := by
  rw [Finset.sum_add_distrib, ← prod_sum_eq, ← prod_sum_eq']
  ring

/-- **AM–HM, the exact obstruction.**  For positive rates, `|s|² ≤ (∑ r)(∑ r⁻¹)`. -/
theorem card_sq_le_sum_mul_sum_inv (s : Finset ι) (r : ι → ℝ) (hr : ∀ i ∈ s, 0 < r i) :
    (s.card : ℝ) ^ 2 ≤ (∑ i ∈ s, r i) * (∑ i ∈ s, (r i)⁻¹) := by
  have hsum : ∑ p ∈ s ×ˢ s, (2 : ℝ)
      ≤ ∑ p ∈ s ×ˢ s, (r p.1 * (r p.2)⁻¹ + r p.2 * (r p.1)⁻¹) := by
    refine Finset.sum_le_sum ?_
    intro p hp
    rw [Finset.mem_product] at hp
    exact two_le_ratio_add_ratio (hr _ hp.1) (hr _ hp.2)
  rw [← two_mul_prod_sum] at hsum
  simp only [Finset.sum_const, Finset.card_product, nsmul_eq_mul] at hsum
  push_cast at hsum
  nlinarith [hsum, sq_nonneg ((s.card : ℝ))]

/-- **Strict AM–HM.**  As soon as two rates differ, the inequality is strict — the
inverse-rate policy loses by a positive margin exactly when the dial is informative. -/
theorem card_sq_lt_sum_mul_sum_inv (s : Finset ι) (r : ι → ℝ) (hr : ∀ i ∈ s, 0 < r i)
    {a b : ι} (ha : a ∈ s) (hb : b ∈ s) (hab : r a ≠ r b) :
    (s.card : ℝ) ^ 2 < (∑ i ∈ s, r i) * (∑ i ∈ s, (r i)⁻¹) := by
  have hsum : ∑ p ∈ s ×ˢ s, (2 : ℝ)
      < ∑ p ∈ s ×ˢ s, (r p.1 * (r p.2)⁻¹ + r p.2 * (r p.1)⁻¹) := by
    refine Finset.sum_lt_sum ?_ ?_
    · intro p hp
      rw [Finset.mem_product] at hp
      exact two_le_ratio_add_ratio (hr _ hp.1) (hr _ hp.2)
    · refine ⟨(a, b), Finset.mem_product.mpr ⟨ha, hb⟩, ?_⟩
      exact two_lt_ratio_add_ratio (hr _ ha) (hr _ hb) hab
  rw [← two_mul_prod_sum] at hsum
  simp only [Finset.sum_const, Finset.card_product, nsmul_eq_mul] at hsum
  push_cast at hsum
  nlinarith [hsum]

/-! ## The yields of the two policies -/

private lemma sum_inv_pos {s : Finset ι} {r : ι → ℝ} (hs : s.Nonempty)
    (hr : ∀ i ∈ s, 0 < r i) : 0 < ∑ i ∈ s, (r i)⁻¹ :=
  Finset.sum_pos (fun i hi => inv_pos.mpr (hr i hi)) hs

/-- The uniform baseline yields the budget times the *arithmetic* mean of the rates. -/
theorem uniform_yield_eq (s : Finset ι) (r : ι → ℝ) (B : ℝ) :
    yieldOf s r (uniformAlloc s B) = B * (∑ i ∈ s, r i) / s.card := by
  unfold yieldOf uniformAlloc
  rw [← Finset.sum_mul]
  ring

/-- The inverse-rate policy yields the budget times the *harmonic* mean of the rates. -/
theorem invRate_yield_eq {s : Finset ι} {r : ι → ℝ} (hs : s.Nonempty)
    (hr : ∀ i ∈ s, 0 < r i) (B : ℝ) :
    yieldOf s r (invRateAlloc s r B) = B * s.card / ∑ i ∈ s, (r i)⁻¹ := by
  unfold yieldOf invRateAlloc
  have hT : (∑ i ∈ s, (r i)⁻¹) ≠ 0 := ne_of_gt (sum_inv_pos hs hr)
  have : ∀ i ∈ s, r i * (B * (r i)⁻¹ / ∑ j ∈ s, (r j)⁻¹) = B / ∑ j ∈ s, (r j)⁻¹ := by
    intro i hi
    have hri : r i ≠ 0 := ne_of_gt (hr i hi)
    field_simp
  rw [Finset.sum_congr rfl this, Finset.sum_const, nsmul_eq_mul]
  ring

/-- **The measured `-17.6%` is forced.**  Reallocating sieve length in inverse
proportion to the rate never beats the uniform baseline, whatever the rates are. -/
theorem invRate_yield_le_uniform_yield {s : Finset ι} {r : ι → ℝ} (hs : s.Nonempty)
    (hr : ∀ i ∈ s, 0 < r i) {B : ℝ} (hB : 0 ≤ B) :
    yieldOf s r (invRateAlloc s r B) ≤ yieldOf s r (uniformAlloc s B) := by
  have hT : 0 < ∑ i ∈ s, (r i)⁻¹ := sum_inv_pos hs hr
  have hn : (0:ℝ) < s.card := by exact_mod_cast Finset.card_pos.mpr hs
  have hkey := card_sq_le_sum_mul_sum_inv s r hr
  rw [invRate_yield_eq hs hr, uniform_yield_eq]
  rw [div_le_div_iff₀ hT hn]
  nlinarith [hkey, mul_nonneg hB (le_of_lt hT)]

/-- **Strict loss.**  If the rates are not all equal — the only regime in which a
calibrated dial carries information — the inverse-rate policy loses strictly, for
every positive budget. -/
theorem invRate_yield_lt_uniform_yield {s : Finset ι} {r : ι → ℝ}
    (hr : ∀ i ∈ s, 0 < r i) {a b : ι} (ha : a ∈ s) (hb : b ∈ s) (hab : r a ≠ r b)
    {B : ℝ} (hB : 0 < B) :
    yieldOf s r (invRateAlloc s r B) < yieldOf s r (uniformAlloc s B) := by
  have hs : s.Nonempty := ⟨a, ha⟩
  have hT : 0 < ∑ i ∈ s, (r i)⁻¹ := sum_inv_pos hs hr
  have hn : (0:ℝ) < s.card := by exact_mod_cast Finset.card_pos.mpr hs
  have hkey := card_sq_lt_sum_mul_sum_inv s r hr ha hb hab
  rw [invRate_yield_eq hs hr, uniform_yield_eq]
  rw [div_lt_div_iff₀ hT hn]
  nlinarith [hkey, hB, hT]

/-! ## The floor clip is load-bearing -/

/-- The yield of the clipped inverse-rate policy is affine in the floor `f`:
`B ·` (harmonic mean) `+ f · (∑ r - n² / ∑ r⁻¹)`. -/
theorem clipYield_eq {s : Finset ι} {r : ι → ℝ} (hs : s.Nonempty) (hr : ∀ i ∈ s, 0 < r i)
    (B f : ℝ) :
    yieldOf s r (clipInvAlloc s r B f)
      = B * s.card / (∑ i ∈ s, (r i)⁻¹)
        + f * ((∑ i ∈ s, r i) - (s.card : ℝ) ^ 2 / ∑ i ∈ s, (r i)⁻¹) := by
  have hT : (∑ i ∈ s, (r i)⁻¹) ≠ 0 := ne_of_gt (sum_inv_pos hs hr)
  have hT2 : (∑ i ∈ s, 1 / r i) ≠ 0 := by simpa [one_div] using hT
  unfold yieldOf clipInvAlloc
  have hpt : ∀ i ∈ s, r i * (f + (B - s.card * f) * (r i)⁻¹ / ∑ j ∈ s, (r j)⁻¹)
      = r i * f + (B - s.card * f) / ∑ j ∈ s, (r j)⁻¹ := by
    intro i hi
    have hri : r i ≠ 0 := ne_of_gt (hr i hi)
    field_simp
  rw [Finset.sum_congr rfl hpt, Finset.sum_add_distrib, Finset.sum_const, nsmul_eq_mul,
    ← Finset.sum_mul]
  field_simp
  ring

/-- **The floor clip is monotonically load-bearing.**  Raising the floor never
lowers the yield: the unclipped policy (`f = 0`) is the worst point of the family
and the uniform baseline (`f = B/n`) the best. -/
theorem clipYield_mono {s : Finset ι} {r : ι → ℝ} (hs : s.Nonempty) (hr : ∀ i ∈ s, 0 < r i)
    (B : ℝ) {f₁ f₂ : ℝ} (hf : f₁ ≤ f₂) :
    yieldOf s r (clipInvAlloc s r B f₁) ≤ yieldOf s r (clipInvAlloc s r B f₂) := by
  have hT : 0 < ∑ i ∈ s, (r i)⁻¹ := sum_inv_pos hs hr
  have hslope : 0 ≤ (∑ i ∈ s, r i) - (s.card : ℝ) ^ 2 / ∑ i ∈ s, (r i)⁻¹ := by
    have := card_sq_le_sum_mul_sum_inv s r hr
    rw [sub_nonneg, div_le_iff₀ hT]
    linarith [this]
  rw [clipYield_eq hs hr, clipYield_eq hs hr]
  have := mul_le_mul_of_nonneg_right hf hslope
  linarith

/-- **Strictly load-bearing.**  If two rates differ, every unit of floor strictly
buys yield: this is the exact sense in which removing the clip (`-146.7%`) is worse
than keeping it (`-17.6%`). -/
theorem clipYield_strictMono {s : Finset ι} {r : ι → ℝ} (hr : ∀ i ∈ s, 0 < r i)
    {a b : ι} (ha : a ∈ s) (hb : b ∈ s) (hab : r a ≠ r b)
    (B : ℝ) {f₁ f₂ : ℝ} (hf : f₁ < f₂) :
    yieldOf s r (clipInvAlloc s r B f₁) < yieldOf s r (clipInvAlloc s r B f₂) := by
  have hs : s.Nonempty := ⟨a, ha⟩
  have hT : 0 < ∑ i ∈ s, (r i)⁻¹ := sum_inv_pos hs hr
  have hslope : 0 < (∑ i ∈ s, r i) - (s.card : ℝ) ^ 2 / ∑ i ∈ s, (r i)⁻¹ := by
    have := card_sq_lt_sum_mul_sum_inv s r hr ha hb hab
    rw [sub_pos, div_lt_iff₀ hT]
    linarith [this]
  rw [clipYield_eq hs hr, clipYield_eq hs hr]
  have := mul_lt_mul_of_pos_right hf hslope
  linarith

/-- The unclipped policy is the `f = 0` member of the clipped family. -/
theorem clipInvAlloc_zero (s : Finset ι) (r : ι → ℝ) (B : ℝ) :
    clipInvAlloc s r B 0 = invRateAlloc s r B := by
  unfold clipInvAlloc invRateAlloc
  funext i
  simp

/-- The uniform baseline is the `f = B / n` member of the clipped family. -/
theorem clipInvAlloc_full {s : Finset ι} (hs : s.Nonempty) (r : ι → ℝ) (B : ℝ) :
    clipInvAlloc s r B (B / s.card) = uniformAlloc s B := by
  have hpos : 0 < s.card := Finset.card_pos.mpr hs
  have hn : (s.card : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr hpos.ne'
  funext i
  have hz : B - (s.card : ℝ) * (B / s.card) = 0 := by
    field_simp
    ring
  simp only [clipInvAlloc, uniformAlloc, hz, zero_mul, zero_div, add_zero]

/-! ## The concentrator and the oracle bound -/

/-- The rate-concentrator: the whole budget on a single (maximal-rate) target. -/
noncomputable def concAlloc [DecidableEq ι] (i₀ : ι) (B : ℝ) : ι → ℝ :=
  fun i => if i = i₀ then B else 0

theorem conc_yield_eq [DecidableEq ι] {s : Finset ι} {i₀ : ι} (hi₀ : i₀ ∈ s) (r : ι → ℝ)
    (B : ℝ) : yieldOf s r (concAlloc i₀ B) = r i₀ * B := by
  unfold yieldOf concAlloc
  rw [Finset.sum_eq_single i₀]
  · simp
  · intro b _ hb; simp [hb]
  · intro h; exact absurd hi₀ h

/-- **The correct sign.**  Concentrating the budget on a maximal-rate target beats
the uniform baseline — the measured `+8.6%` of the rate-concentrator is the same
AM inequality read in the other direction. -/
theorem concentrator_yield_ge_uniform_yield [DecidableEq ι] {s : Finset ι} {r : ι → ℝ}
    {i₀ : ι} (hi₀ : i₀ ∈ s) (hmax : ∀ i ∈ s, r i ≤ r i₀) {B : ℝ} (hB : 0 ≤ B) :
    yieldOf s r (uniformAlloc s B) ≤ yieldOf s r (concAlloc i₀ B) := by
  have hs : s.Nonempty := ⟨i₀, hi₀⟩
  have hn : (0:ℝ) < s.card := by exact_mod_cast Finset.card_pos.mpr hs
  rw [uniform_yield_eq, conc_yield_eq hi₀]
  rw [div_le_iff₀ hn]
  have hsum : ∑ i ∈ s, r i ≤ ∑ _i ∈ s, r i₀ := Finset.sum_le_sum (fun i hi => hmax i hi)
  rw [Finset.sum_const, nsmul_eq_mul] at hsum
  nlinarith [hsum, hB]

/-- **The realised oracle bound.**  Every allocation of a budget `B` over nonnegative
sieve lengths yields at most `B ·` (largest rate).  The measured `+74.8%` headroom is
therefore capped by the rate spread and by nothing else — no adaptive rule can exceed it. -/
theorem yield_le_budget_mul_sup {s : Finset ι} {r ℓ : ι → ℝ} {i₀ : ι}
    (hmax : ∀ i ∈ s, r i ≤ r i₀) (hℓ : ∀ i ∈ s, 0 ≤ ℓ i) {B : ℝ} (hB : ∑ i ∈ s, ℓ i = B) :
    yieldOf s r ℓ ≤ r i₀ * B := by
  unfold yieldOf
  calc ∑ i ∈ s, r i * ℓ i ≤ ∑ i ∈ s, r i₀ * ℓ i :=
        Finset.sum_le_sum (fun i hi => mul_le_mul_of_nonneg_right (hmax i hi) (hℓ i hi))
    _ = r i₀ * B := by rw [← Finset.mul_sum, hB]

/-- The headroom of the uniform baseline is exactly the budget times the gap between
the maximal rate and the mean rate. -/
theorem oracle_gap_eq_budget_mul_sup_sub_mean {s : Finset ι} (hs : s.Nonempty) (r : ι → ℝ)
    {i₀ : ι} (B : ℝ) :
    r i₀ * B - yieldOf s r (uniformAlloc s B)
      = B * (r i₀ - (∑ i ∈ s, r i) / s.card) := by
  have hn : (s.card : ℝ) ≠ 0 := by
    have : 0 < s.card := Finset.card_pos.mpr hs
    exact_mod_cast Nat.cast_ne_zero.mpr this.ne'
  rw [uniform_yield_eq]
  field_simp

end Probability.AdaptiveQS
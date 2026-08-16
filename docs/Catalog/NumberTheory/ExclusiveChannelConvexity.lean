/-
# NET-30 / Catalog·NumberTheory — Where the saturation lives: the convexity
dichotomy of exclusive-block ablations

`NumberTheory.ExclusiveChannelInterventions` shows that an *affine* boundary
read-out is additive: the whole-block ablation drop equals the sum of the
single-coordinate drops, so the measured s = 13, k = 2 signature (all single
drops inside `±0.002`, block drop `0.2436`) is affinely impossible.  This file
locates the exact boundary of that no-go.

Model the read-out along the block ray as `φ (∑ i, s i)`, where `s i ≥ 0` is the
gain contributed by exclusive coordinate `i` and `φ : ℝ → ℝ` is an arbitrary
scalar nonlinearity (the saturating gate of the trained cell).  Write
`S = ∑ i, s i`, block drop `D = φ S - φ 0`, single drop `dᵢ = φ S - φ (S - s i)`.

* `chord_le_of_convexOn` / `le_chord_of_concaveOn`: the one-line chord
  inequality behind everything, `a * (φ S - φ 0) ≤ S * (φ S - φ (S - a))`
  for convex `φ` and `0 ≤ a ≤ S`, and its reverse for concave `φ`.
* `convex_block_drop_le_sum_single_drops`: **convex read-outs cannot hide the
  block.**  `D ≤ ∑ i, dᵢ`.  With affine `φ` this is the equality of the
  companion file; with convex `φ` it is still an upper bound, so a `k`-fold
  no-op tolerance `ε` caps the block drop at `k · ε`
  (`convex_block_drop_le_card_mul`).
* `concave_sum_single_drops_le_block_drop`: **concave (saturating) read-outs
  can.**  `∑ i, dᵢ ≤ D`, and the gap is unbounded.
* `concave_single_drop_le_share`: the quantitative saturation law
  `dᵢ ≤ (s i / S) · D`; with an equal split over `k` coordinates
  (`concave_single_drop_le_of_equal_shares`) every single drop is at most
  `D / k` **while the block drop stays `D`**.  This is the formal shape of the
  measured trend "self-sufficiency of single coordinates rises with `k`":
  under a saturating gate, redundancy is forced by concavity alone, at rate
  `1/k`, with no appeal to what the network learned.
* `s13_k2_no_convex_readout`, `s13_readout_defect_negative`: applied to the
  published numbers, the s = 13 arm is a **strict-concavity certificate**: the
  redundancy defect `∑ dᵢ - D` is measured at `≤ 0.004 - 0.2436 < 0`, which no
  convex — a fortiori no affine — read-out can produce.

The upshot for the round: "1-redundant but block-dependent" is not an exotic
coincidence, it is exactly the signature of a *saturated* boundary channel, and
it needs `k ≥ 2` (companion file) plus strict concavity (here).
-/

import Mathlib
import NumberTheory.ExclusiveChannelInterventions

namespace NumberTheory.ExclusiveChannel

open Finset

variable {k : ℕ}

/-! ## The chord inequality -/

/-- For a convex `φ` and `0 ≤ a ≤ S` (with `0 < S`), the last-`a` chord is at
least as steep as the full chord: `a * (φ S - φ 0) ≤ S * (φ S - φ (S - a))`. -/
theorem chord_le_of_convexOn {φ : ℝ → ℝ} (hφ : ConvexOn ℝ Set.univ φ) {S a : ℝ}
    (hS : 0 < S) (ha : 0 ≤ a) (haS : a ≤ S) :
    a * (φ S - φ 0) ≤ S * (φ S - φ (S - a)) := by
  have hSne : S ≠ 0 := ne_of_gt hS
  have hkey : φ (S - a) ≤ (a / S) * φ 0 + ((S - a) / S) * φ S := by
    have hab : a / S + (S - a) / S = 1 := by field_simp; ring
    have h := hφ.2 (Set.mem_univ (0 : ℝ)) (Set.mem_univ S)
      (div_nonneg ha hS.le) (div_nonneg (by linarith : (0:ℝ) ≤ S - a) hS.le) hab
    have hpt : (a / S) • (0 : ℝ) + ((S - a) / S) • S = S - a := by
      simp only [smul_eq_mul, mul_zero, zero_add]
      field_simp
    rw [hpt] at h
    simpa [smul_eq_mul] using h
  have hmul : S * φ (S - a) ≤ a * φ 0 + (S - a) * φ S := by
    have h2 := mul_le_mul_of_nonneg_left hkey hS.le
    have h3 : S * ((a / S) * φ 0 + ((S - a) / S) * φ S) = a * φ 0 + (S - a) * φ S := by
      field_simp
    linarith [h2, h3.le, h3.ge]
  nlinarith

/-- Concave version of `chord_le_of_convexOn`. -/
theorem le_chord_of_concaveOn {φ : ℝ → ℝ} (hφ : ConcaveOn ℝ Set.univ φ) {S a : ℝ}
    (hS : 0 < S) (ha : 0 ≤ a) (haS : a ≤ S) :
    S * (φ S - φ (S - a)) ≤ a * (φ S - φ 0) := by
  have hneg : ConvexOn ℝ Set.univ (fun x => -φ x) := hφ.neg
  have := chord_le_of_convexOn hneg hS ha haS
  simp only at this
  nlinarith

/-! ## Block drop versus single drops -/

/-- The block gain `S = ∑ i, s i` dominates each individual gain. -/
theorem le_sum_of_nonneg {s : Fin k → ℝ} (hs : ∀ i, 0 ≤ s i) (i : Fin k) :
    s i ≤ ∑ j, s j :=
  Finset.single_le_sum (fun j _ => hs j) (Finset.mem_univ i)

/-- **Convex read-outs cannot hide the block.**  If the scalar nonlinearity is
convex, the whole-block drop is at most the sum of the single-coordinate drops.
(For affine `φ` this is an equality — the additivity of the companion file.) -/
theorem convex_block_drop_le_sum_single_drops {φ : ℝ → ℝ} (hφ : ConvexOn ℝ Set.univ φ)
    {s : Fin k → ℝ} (hs : ∀ i, 0 ≤ s i) (hS : 0 < ∑ j, s j) :
    φ (∑ j, s j) - φ 0 ≤ ∑ i, (φ (∑ j, s j) - φ ((∑ j, s j) - s i)) := by
  set S := ∑ j, s j with hSdef
  have hchord : ∀ i : Fin k, s i * (φ S - φ 0) ≤ S * (φ S - φ (S - s i)) := fun i =>
    chord_le_of_convexOn hφ hS (hs i) (hSdef ▸ le_sum_of_nonneg hs i)
  have hsum : ∑ i : Fin k, (s i * (φ S - φ 0))
      ≤ ∑ i : Fin k, S * (φ S - φ (S - s i)) :=
    Finset.sum_le_sum fun i _ => hchord i
  rw [← Finset.sum_mul, ← Finset.mul_sum, ← hSdef] at hsum
  exact le_of_mul_le_mul_left (by linarith [hsum]) hS

/-- **Convex saturation bound.**  With single-coordinate no-op tolerance `ε`, a
convex read-out loses at most `k · ε` from the whole block. -/
theorem convex_block_drop_le_card_mul {φ : ℝ → ℝ} (hφ : ConvexOn ℝ Set.univ φ)
    {s : Fin k → ℝ} {ε : ℝ} (hs : ∀ i, 0 ≤ s i) (hS : 0 < ∑ j, s j)
    (hsmall : ∀ i, φ (∑ j, s j) - φ ((∑ j, s j) - s i) ≤ ε) :
    φ (∑ j, s j) - φ 0 ≤ k * ε := by
  refine (convex_block_drop_le_sum_single_drops hφ hs hS).trans ?_
  calc ∑ i : Fin k, (φ (∑ j, s j) - φ ((∑ j, s j) - s i)) ≤ ∑ _i : Fin k, ε :=
        Finset.sum_le_sum fun i _ => hsmall i
    _ = k * ε := by simp [mul_comm]

/-- **Concave read-outs can hide the block.**  For a saturating (concave) scalar
nonlinearity the inequality reverses: the sum of the single-coordinate drops is
at most the whole-block drop, so all single drops can vanish while the block
drop does not. -/
theorem concave_sum_single_drops_le_block_drop {φ : ℝ → ℝ} (hφ : ConcaveOn ℝ Set.univ φ)
    {s : Fin k → ℝ} (hs : ∀ i, 0 ≤ s i) (hS : 0 < ∑ j, s j) :
    ∑ i, (φ (∑ j, s j) - φ ((∑ j, s j) - s i)) ≤ φ (∑ j, s j) - φ 0 := by
  set S := ∑ j, s j with hSdef
  have hchord : ∀ i : Fin k, S * (φ S - φ (S - s i)) ≤ s i * (φ S - φ 0) := fun i =>
    le_chord_of_concaveOn hφ hS (hs i) (hSdef ▸ le_sum_of_nonneg hs i)
  have hsum : ∑ i : Fin k, S * (φ S - φ (S - s i))
      ≤ ∑ i : Fin k, (s i * (φ S - φ 0)) :=
    Finset.sum_le_sum fun i _ => hchord i
  rw [← Finset.sum_mul, ← Finset.mul_sum, ← hSdef] at hsum
  exact le_of_mul_le_mul_left (by linarith [hsum]) hS

/-- **The saturation law, quantitative form.**  Under a concave read-out the
drop caused by ablating coordinate `i` is at most its *share* `s i / S` of the
whole-block drop. -/
theorem concave_single_drop_le_share {φ : ℝ → ℝ} (hφ : ConcaveOn ℝ Set.univ φ)
    {s : Fin k → ℝ} (hs : ∀ i, 0 ≤ s i) (hS : 0 < ∑ j, s j) (i : Fin k) :
    φ (∑ j, s j) - φ ((∑ j, s j) - s i)
      ≤ (s i / ∑ j, s j) * (φ (∑ j, s j) - φ 0) := by
  set S := ∑ j, s j with hSdef
  have h := le_chord_of_concaveOn hφ hS (hs i) (hSdef ▸ le_sum_of_nonneg hs i)
  rw [div_mul_eq_mul_div, le_div_iff₀ hS]
  linarith [h]

/-- **Internalisation saturates at rate `1/k`.**  With the block gain split
equally over `k ≥ 1` exclusive coordinates and a concave read-out, every single
coordinate is worth at most `1/k` of the block: single ablations become no-ops
at rate `1/k`, while the whole-block drop is unchanged. -/
theorem concave_single_drop_le_of_equal_shares {φ : ℝ → ℝ} (hφ : ConcaveOn ℝ Set.univ φ)
    {S : ℝ} (hS : 0 < S) (hk : 0 < k) (i : Fin k)
    (s : Fin k → ℝ) (hsplit : ∀ j, s j = S / k) :
    φ (∑ j, s j) - φ ((∑ j, s j) - s i) ≤ (φ S - φ 0) / k := by
  have hkR : (0 : ℝ) < k := by exact_mod_cast hk
  have hs : ∀ j, 0 ≤ s j := fun j => by rw [hsplit j]; positivity
  have hsum : ∑ j, s j = S := by
    simp [hsplit, Finset.sum_const, Finset.card_univ]
    field_simp
  have hSpos : 0 < ∑ j, s j := by rw [hsum]; exact hS
  have h := concave_single_drop_le_share hφ hs hSpos i
  rw [hsum] at h ⊢
  rw [hsplit i] at h ⊢
  calc φ S - φ (S - S / k) ≤ (S / k / S) * (φ S - φ 0) := h
    _ = (φ S - φ 0) / k := by field_simp

/-! ## The measured k = 2, s = 13 arm is a strict-concavity certificate -/

/-- **No convex read-out fits the s = 13 arm.**  Single-coordinate drops inside
the reported no-op band `0.002` and a whole-block drop of `0.2436` are
incompatible with convexity at `k = 2` — the convex bound caps the block at
`0.004`.  Since affine read-outs are convex, this strengthens
`s13_k2_no_affine_readout`. -/
theorem s13_k2_no_convex_readout :
    ¬ ∃ (φ : ℝ → ℝ) (s : Fin 2 → ℝ), ConvexOn ℝ Set.univ φ ∧ (∀ i, 0 ≤ s i) ∧
        0 < ∑ j, s j ∧
        (∀ i, φ (∑ j, s j) - φ ((∑ j, s j) - s i) ≤ 2 / 1000) ∧
        φ (∑ j, s j) - φ 0 = 2436 / 10000 := by
  rintro ⟨φ, s, hφ, hs, hS, hsmall, hblock⟩
  have h := convex_block_drop_le_card_mul hφ hs hS hsmall
  rw [hblock] at h
  norm_num at h

/-- **Redundancy defect.**  `redundancyDefect = (∑ single drops) - (block drop)`:
nonnegative for convex read-outs, nonpositive for concave ones, zero for affine
ones.  Its measured sign is therefore a curvature certificate. -/
noncomputable def redundancyDefect (φ : ℝ → ℝ) (s : Fin k → ℝ) : ℝ :=
  (∑ i, (φ (∑ j, s j) - φ ((∑ j, s j) - s i))) - (φ (∑ j, s j) - φ 0)

theorem redundancyDefect_nonneg_of_convex {φ : ℝ → ℝ} (hφ : ConvexOn ℝ Set.univ φ)
    {s : Fin k → ℝ} (hs : ∀ i, 0 ≤ s i) (hS : 0 < ∑ j, s j) :
    0 ≤ redundancyDefect φ s := by
  have := convex_block_drop_le_sum_single_drops hφ hs hS
  simp only [redundancyDefect]
  linarith

theorem redundancyDefect_nonpos_of_concave {φ : ℝ → ℝ} (hφ : ConcaveOn ℝ Set.univ φ)
    {s : Fin k → ℝ} (hs : ∀ i, 0 ≤ s i) (hS : 0 < ∑ j, s j) :
    redundancyDefect φ s ≤ 0 := by
  have := concave_sum_single_drops_le_block_drop hφ hs hS
  simp only [redundancyDefect]
  linarith

/-- **The s = 13 certificate.**  A read-out whose two single drops are inside
the no-op band and whose block drop is the measured `0.2436` has strictly
negative redundancy defect, hence is not convex. -/
theorem s13_readout_defect_negative {φ : ℝ → ℝ} {s : Fin 2 → ℝ}
    (hsmall : ∀ i, φ (∑ j, s j) - φ ((∑ j, s j) - s i) ≤ 2 / 1000)
    (hblock : φ (∑ j, s j) - φ 0 = 2436 / 10000) :
    redundancyDefect φ s ≤ -(2396 / 10000) := by
  have hsum : ∑ i, (φ (∑ j, s j) - φ ((∑ j, s j) - s i)) ≤ 2 * (2 / 1000) := by
    calc ∑ i, (φ (∑ j, s j) - φ ((∑ j, s j) - s i)) ≤ ∑ _i : Fin 2, (2 / 1000 : ℝ) :=
          Finset.sum_le_sum fun i _ => hsmall i
      _ = 2 * (2 / 1000) := by simp
  simp only [redundancyDefect, hblock]
  linarith

/-- Consequently the s = 13 read-out is not convex along the block ray. -/
theorem s13_readout_not_convex {φ : ℝ → ℝ} {s : Fin 2 → ℝ} (hs : ∀ i, 0 ≤ s i)
    (hS : 0 < ∑ j, s j)
    (hsmall : ∀ i, φ (∑ j, s j) - φ ((∑ j, s j) - s i) ≤ 2 / 1000)
    (hblock : φ (∑ j, s j) - φ 0 = 2436 / 10000) :
    ¬ ConvexOn ℝ Set.univ φ := by
  intro hφ
  have h1 := redundancyDefect_nonneg_of_convex hφ hs hS
  have h2 := s13_readout_defect_negative hsmall hblock
  linarith

end NumberTheory.ExclusiveChannel
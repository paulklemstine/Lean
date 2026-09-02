import Mathlib
import Shared.AttentionBudgetKnee
import Pythagorean.NET79GeometricRatioKnee
import Pythagorean.NET55SizeInvariantKnee

/-!
# NET-55 — auditing the measured sweep: what a knee table can and cannot say

The NET-55 round reports two sweeps of the agreement ratio against the retained key
budget (gate `0.98`, held-out wikitext, Qwen2.5-1.5B):

```
ctx  512 :   8 ↦ 0.9727 ✗   16 ↦ 0.9896 ✓   24 ↦ 0.9915   32 ↦ 0.9969   48 ↦ 0.9993   64 ↦ 0.9988
ctx 1024 :                  16 ↦ 0.9806 ✓   24 ↦ 0.9867   32 ↦ 0.9881   48 ↦ 0.9928   64 ↦ 0.9927
                            96 ↦ 0.9954  128 ↦ 0.9974
```

This file proves three things about such tables, using only the model-free
`AttentionBudget` theory.

* **The razor is sound at 512** (`net55_razor_bracket_512`): a fail at `8` and a pass at
  `16` pin the knee to `(8, 16]`.  Monotonicity of retained mass is the only input.
* **The grid floor is a genuine hole at 1024** (`net55_grid_floor_indeterminate`): a pass
  at `16` with nothing measured below it is compatible with a knee of `16` *and* with a
  knee of `1`.  Two explicit profiles realise the two extremes, so the reported
  `k* = 16` at `1024` is an upper bound only — the sub-16 addendum is logically
  necessary, not a matter of taste.
* **The reported sweeps are not retained-mass curves**
  (`net55_sweep_512_not_retained_mass`, `net55_sweep_1024_not_retained_mass`): both
  tables *decrease* somewhere (`48 ↦ 0.9993 > 64 ↦ 0.9988` at `512`, and
  `48 ↦ 0.9928 > 64 ↦ 0.9927` at `1024`), while the retained mass of any positive
  profile is strictly increasing in the budget below the context length.  Hence the
  measured agreement ratio is *not* the retained-mass functional; it is a downstream,
  non-monotone read-out of it, and knee brackets read off it inherit that caveat.

The positive counterpart is a complete characterisation of which two-point segments a
sweep *can* have: `two_point_sweep_realizable_iff` says the only constraint is strict
increase inside `(0, 1)`.  The proof rests on a general realization principle,
`retained_of_cumulative`: every strictly increasing cumulative profile starting at `0`
is the head-mass function of a genuine positive attention profile.

-- !-- Lab Notes -- !--
Hypothesizer (audit cycle):
 (A1) Two grid points bracket the knee; one grid point does not, and the gap is
      *maximal*: a single pass at `k` is compatible with every knee in `[1, k]`. [BOLD]
 (A2) Monotonicity is the *only* constraint on a two-point sweep segment: a strictly
      increasing pair inside `(0,1)` is always realizable by a genuine profile.  [BOLD]
 (A3) Both measured NET-55 sweeps violate monotonicity at `48 → 64`, so neither is a
      retained-mass curve; the discrepancy is the metric, not the model.

Experimenter: A1 = `net55_razor_bracket_512` (positive half) plus
`net55_grid_floor_indeterminate` (negative half, explicit geometric witnesses with knees
`16` and `1`); A2 = `two_point_sweep_realizable_iff` via `blockProfile`;
A3 = `net55_sweep_512_not_retained_mass` and `net55_sweep_1024_not_retained_mass`.
All proved, zero sorries.

Analyst: the failure mode found in A3 is the useful one.  Retained mass is monotone by
`retained_lt_retained`, so *any* non-monotonicity in a measured sweep certifies that the
measured functional is not retained mass.  The observed decrease is small (`5e-4` and
`1e-4`, both inside the quoted `SE ≈ 0.3%`), which locates the effect exactly: it is
sampling noise on a downstream accuracy statistic, and therefore the knee brackets are
statements about that statistic, not about attention mass.

Critic: `net55_grid_floor_indeterminate` is not a pathological witness — the low-knee
profile is a perfectly ordinary geometric profile with a strong spectral gap, which is
precisely the regime the round claims real models occupy.  So the indeterminacy is a
live possibility, not a formal quibble.
-/

namespace PythKnee

open Finset AttentionBudget

/-! ## The razor at context 512 -/

/-- **The NET-55 razor at `512`.**  The measured failure at `k = 8` (`0.9727 < 0.98`)
and the pass at `k = 16` bracket the knee in `(8, 16]`.  Only monotonicity of the
retained mass is used. -/
theorem net55_razor_bracket_512 {w : ℕ → ℝ} {n : ℕ} (hw : ∀ i, 0 < w i) (hn : 0 < n)
    (h8 : retained w n 8 = 9727 / 10000) (h16 : (98 / 100 : ℝ) ≤ retained w n 16) :
    8 < kstar w n (98 / 100) ∧ kstar w n (98 / 100) ≤ 16 := by
  refine knee_bracket hw hn (by norm_num) ?_ h16
  rw [h8]; norm_num

/-! ## The grid floor at context 1024 is a genuine hole -/

/-- The `1/100` geometric profile has knee `1`: a single key clears the `0.98` gate. -/
theorem knee_hundredth_98 {n : ℕ} (hn : 64 ≤ n) :
    kstar (geomProfile (1 / 100)) n (98 / 100) = 1 := by
  refine kstar_geomProfile_eq_of_small_powers (by norm_num) (by norm_num)
    (m := 64) (by norm_num) hn (by norm_num) (by omega) (by norm_num) (by norm_num) ?_
  norm_num

/-- **The grid floor is a hole.**  At context `1024` the round measured a pass at `k=16`
and nothing below it.  That single measurement is compatible with a knee of `16` and
with a knee of `1`: two genuine positive attention profiles both clear the gate at `16`
while their knees differ by fifteen keys.  Consequently `k* = 16` at `1024` is an upper
bound only. -/
theorem net55_grid_floor_indeterminate :
    ∃ w₁ w₂ : ℕ → ℝ, (∀ i, 0 < w₁ i) ∧ (∀ i, 0 < w₂ i) ∧
      (98 / 100 : ℝ) ≤ retained w₁ 1024 16 ∧ (98 / 100 : ℝ) ≤ retained w₂ 1024 16 ∧
      kstar w₁ 1024 (98 / 100) = 16 ∧ kstar w₂ 1024 (98 / 100) = 1 := by
  refine ⟨geomProfile (39 / 50), geomProfile (1 / 100), geomProfile_pos (by norm_num),
    geomProfile_pos (by norm_num), ?_, ?_, net55_flat_knee_chain.2, knee_hundredth_98 (by norm_num)⟩
  · have h := gate_le_retained_kstar (w := geomProfile (39 / 50)) (n := 1024)
      (τ := 98 / 100) (geomProfile_pos (by norm_num)) (by norm_num) (by norm_num)
    rwa [net55_flat_knee_chain.2] at h
  · refine le_trans ?_ (one_sub_pow_le_retained_geomProfile (r := 1 / 100)
      (by norm_num) (by norm_num) 1024 16 (by norm_num))
    norm_num

/-! ## Which sweeps are realizable?  A cumulative-profile principle -/

/-- **Realization principle.**  Every strictly increasing cumulative function `F` with
`F 0 = 0` is the head-mass function of a genuine positive attention profile, namely its
increment sequence.  Retained mass is then read off `F` directly. -/
theorem retained_of_cumulative (F : ℕ → ℝ) (hF0 : F 0 = 0) (hF : StrictMono F) :
    ∃ w : ℕ → ℝ, (∀ i, 0 < w i) ∧ (∀ k, headMass w k = F k) := by
  refine ⟨fun i => F (i + 1) - F i, fun i => sub_pos.mpr (hF (by omega)), fun k => ?_⟩
  have := Finset.sum_range_sub F k
  simpa [headMass, hF0] using this

/-! ### A three-block profile realizing a prescribed two-point sweep -/

/-- A profile that is constant on `[0, p)`, on `[p, q)` and on `[q, ∞)`. -/
noncomputable def blockProfile (p q : ℕ) (a b c : ℝ) : ℕ → ℝ :=
  fun i => if i < p then a else if i < q then b else c

lemma blockProfile_pos {p q : ℕ} {a b c : ℝ} (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) :
    ∀ i, 0 < blockProfile p q a b c i := by
  intro i
  unfold blockProfile
  split_ifs <;> assumption

lemma headMass_succ (w : ℕ → ℝ) (k : ℕ) : headMass w (k + 1) = headMass w k + w k := by
  simp [headMass, Finset.sum_range_succ]

lemma headMass_block_low {p q : ℕ} {a b c : ℝ} :
    ∀ {k : ℕ}, k ≤ p → headMass (blockProfile p q a b c) k = (k : ℝ) * a := by
  intro k
  induction k with
  | zero => intro _; simp [headMass]
  | succ m ih =>
      intro h
      have hm : blockProfile p q a b c m = a := by
        unfold blockProfile; rw [if_pos (by omega)]
      rw [headMass_succ, ih (by omega), hm]
      push_cast
      ring

lemma headMass_block_mid {p q : ℕ} {a b c : ℝ} :
    ∀ {k : ℕ}, p ≤ k → k ≤ q →
      headMass (blockProfile p q a b c) k = (p : ℝ) * a + ((k : ℝ) - p) * b := by
  intro k hpk
  induction k, hpk using Nat.le_induction with
  | base => intro _; rw [headMass_block_low le_rfl]; ring
  | succ m hm ih =>
      intro h
      have hval : blockProfile p q a b c m = b := by
        unfold blockProfile; rw [if_neg (by omega), if_pos (by omega)]
      rw [headMass_succ, ih (by omega), hval]
      push_cast
      ring

lemma headMass_block_high {p q : ℕ} {a b c : ℝ} (hpq : p ≤ q) :
    ∀ {k : ℕ}, q ≤ k →
      headMass (blockProfile p q a b c) k
        = (p : ℝ) * a + ((q : ℝ) - p) * b + ((k : ℝ) - q) * c := by
  intro k hqk
  induction k, hqk using Nat.le_induction with
  | base => rw [headMass_block_mid hpq le_rfl]; ring
  | succ m hm ih =>
      have hval : blockProfile p q a b c m = c := by
        unfold blockProfile; rw [if_neg (by omega), if_neg (by omega)]
      rw [headMass_succ, ih, hval]
      push_cast
      ring

/-- **A2 — monotonicity is the only constraint.**  For grid points `0 < p < q < n`, a
pair of measured retained fractions `(v₁, v₂)` at budgets `p` and `q` is realizable by a
genuine positive attention profile **iff** it is strictly increasing inside `(0, 1)`.
Everything else a sweep table might show is unconstrained. -/
theorem two_point_sweep_realizable_iff {p q n : ℕ} (hp : 0 < p) (hpq : p < q) (hqn : q < n)
    (v₁ v₂ : ℝ) :
    (∃ w : ℕ → ℝ, (∀ i, 0 < w i) ∧ retained w n p = v₁ ∧ retained w n q = v₂) ↔
      (0 < v₁ ∧ v₁ < v₂ ∧ v₂ < 1) := by
  constructor
  · rintro ⟨w, hw, h1, h2⟩
    refine ⟨?_, ?_, ?_⟩
    · rw [← h1, retained, min_eq_left (by omega : p ≤ n)]
      exact div_pos (headMass_pos hw hp) (headMass_pos hw (by omega))
    · rw [← h1, ← h2]
      exact retained_lt_retained hw hpq (by omega)
    · rw [← h2]
      exact retained_lt_one hw (by omega)
  · rintro ⟨hv1, hv12, hv2⟩
    have hpR : (0 : ℝ) < p := by exact_mod_cast hp
    have hqp : (0 : ℝ) < (q : ℝ) - p := by
      have : (p : ℝ) < q := by exact_mod_cast hpq
      linarith
    have hnq : (0 : ℝ) < (n : ℝ) - q := by
      have : (q : ℝ) < n := by exact_mod_cast hqn
      linarith
    set a := v₁ / p with ha
    set b := (v₂ - v₁) / ((q : ℝ) - p) with hb
    set c := (1 - v₂) / ((n : ℝ) - q) with hc
    have hapos : 0 < a := div_pos hv1 hpR
    have hbpos : 0 < b := div_pos (by linarith) hqp
    have hcpos : 0 < c := div_pos (by linarith) hnq
    refine ⟨blockProfile p q a b c, blockProfile_pos hapos hbpos hcpos, ?_, ?_⟩
    · have hp' : headMass (blockProfile p q a b c) p = v₁ := by
        rw [headMass_block_low le_rfl, ha]; field_simp
      have hn' : headMass (blockProfile p q a b c) n = 1 := by
        rw [headMass_block_high (by omega) (by omega : q ≤ n), ha, hb, hc]
        field_simp
        ring
      rw [retained, min_eq_left (by omega : p ≤ n), hp', hn', div_one]
    · have hq' : headMass (blockProfile p q a b c) q = v₂ := by
        rw [headMass_block_mid (by omega) le_rfl, ha, hb]
        field_simp
        ring
      have hn' : headMass (blockProfile p q a b c) n = 1 := by
        rw [headMass_block_high (by omega) (by omega : q ≤ n), ha, hb, hc]
        field_simp
        ring
      rw [retained, min_eq_left (by omega : q ≤ n), hq', hn', div_one]

/-! ## The measured sweeps are not retained-mass curves -/

/-- A decreasing pair of retained fractions is impossible below the context length. -/
theorem no_retained_inversion {w : ℕ → ℝ} {n j k : ℕ} (hw : ∀ i, 0 < w i) (hjk : j < k)
    (hkn : k < n) : retained w n j < retained w n k :=
  retained_lt_retained hw hjk (by omega)

/-- **A3 at ctx 512.**  No positive attention profile can produce the reported pair
`48 ↦ 0.9993`, `64 ↦ 0.9988`: retained mass is strictly increasing in the budget.  The
measured agreement ratio is therefore not the retained-mass functional. -/
theorem net55_sweep_512_not_retained_mass :
    ¬ ∃ w : ℕ → ℝ, (∀ i, 0 < w i) ∧ retained w 512 48 = 9993 / 10000 ∧
      retained w 512 64 = 9988 / 10000 := by
  rintro ⟨w, hw, h48, h64⟩
  have := no_retained_inversion hw (j := 48) (k := 64) (n := 512) (by norm_num) (by norm_num)
  rw [h48, h64] at this
  norm_num at this

/-- **A3 at ctx 1024.**  The same violation occurs in the second sweep at
`48 ↦ 0.9928`, `64 ↦ 0.9927`, so the effect is not a single fluke of one cell. -/
theorem net55_sweep_1024_not_retained_mass :
    ¬ ∃ w : ℕ → ℝ, (∀ i, 0 < w i) ∧ retained w 1024 48 = 9928 / 10000 ∧
      retained w 1024 64 = 9927 / 10000 := by
  rintro ⟨w, hw, h48, h64⟩
  have := no_retained_inversion hw (j := 48) (k := 64) (n := 1024) (by norm_num) (by norm_num)
  rw [h48, h64] at this
  norm_num at this

/-- By contrast the *monotone* part of the `512` sweep is realizable exactly: some
genuine positive profile has retained fractions `0.9727` at `8` keys and `0.9896` at
`16` keys on a context of `512`.  The inconsistency of the full table is therefore
located precisely at the `48 → 64` step. -/
theorem net55_sweep_512_prefix_realizable :
    ∃ w : ℕ → ℝ, (∀ i, 0 < w i) ∧ retained w 512 8 = 9727 / 10000 ∧
      retained w 512 16 = 9896 / 10000 :=
  (two_point_sweep_realizable_iff (p := 8) (q := 16) (n := 512) (by norm_num) (by norm_num)
    (by norm_num) _ _).mpr (by norm_num)

end PythKnee
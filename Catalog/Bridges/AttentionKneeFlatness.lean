/-
  # Cycle 3: the flatness dichotomy for the Cauchy–Schwarz knee floor

  `Bridges.AttentionKneeGeometry` gives order/grid control of the retention knee
  `k*(g)`, and `Bridges.AttentionKneeEntropyBound` gives the information-theoretic
  floor `k*(g) ≥ g² / E`, where `E` is the attention energy (collision
  probability).  The obvious question left open by cycle 2 — and recorded as the
  fifth direction of `FUTURE_DIRECTIONS.md` ("Flatness Dichotomy for the
  Cauchy–Schwarz Knee Floor") — is *how lossy* that floor is on a genuinely
  decaying row.  The conjecture recorded there was that on a geometric row
  `w i = (1 - a) aⁱ` the ratio

      (true knee) / (energy floor)

  **grows without bound** as `a → 1⁻`, since the true knee is logarithmic in
  `1/(1-g)` while the floor is `g²(1+a)/(1-a)`.

  This module settles it, and the recorded conjecture is **refuted**:

  * `geoRow_knee_le_log_bound`:  `k*(g) ≤ 1 + log(1/(1-g)) / (1-a)`;
  * `geoRow_knee_ge_floor`:      `g²(1+a)/(1-a) ≤ k*(g)`  (Cauchy–Schwarz, via
    the exact energy `E(a) = (1-a)/(1+a)`);
  * `geoRow_flatness_ratio_bounded` / `geoRow_ratio_blowup_refuted`: the two
    sides differ by at most the factor `(1 + log(1/(1-g)))/g²`, which depends on
    the gate **only** — uniformly in `a ∈ (0,1)`.  Both quantities diverge like
    `1/(1-a)`, so their ratio stays bounded and the floor is tight up to a
    gate-only constant.

  For the NET-63 gate `g = 0.98` the constant is explicit and small:
  `net63_flatness_constant_lt_six` shows six keys of slack suffice,
  `k* ≤ 6 · (g²/E)` for every geometric row.

  Consequences for the experimental thread.  The energy floor is *not* a weak
  bound that only bites on flat rows: on the entire geometric family it is
  within a factor `≈5` of the truth at gate `0.98`.  Hence a measured
  collision entropy really does predict the key budget up to a constant, which
  is what the deployment table needs; and the "flatness diagnostic" proposed in
  cycle 2 cannot be read off the ratio, because that ratio is bounded.

  All statements below are proved from scratch, with complete proofs.
-/

import Mathlib
import Bridges.AttentionKneeGeometry
import Bridges.AttentionKneeEntropyBound

namespace Bridges.AttentionKneeFlatness

open Finset Bridges.AttentionKneeGeometry Bridges.AttentionKneeEntropyBound

/-! ## 1. The geometric attention row -/

/-- The geometric (exponentially decaying) attention row `w i = (1 - a) aⁱ`,
a probability profile for `0 ≤ a < 1`. -/
def geoRow (a : ℝ) : ℕ → ℝ := fun i => (1 - a) * a ^ i

lemma geoRow_nonneg {a : ℝ} (ha0 : 0 ≤ a) (ha1 : a ≤ 1) (i : ℕ) : 0 ≤ geoRow a i := by
  have : (0:ℝ) ≤ a ^ i := pow_nonneg ha0 i
  have h1 : (0:ℝ) ≤ 1 - a := by linarith
  exact mul_nonneg h1 this

lemma geoRow_antitone {a : ℝ} (ha0 : 0 ≤ a) (ha1 : a ≤ 1) : Antitone (geoRow a) := by
  intro i j hij
  have hpow : a ^ j ≤ a ^ i := pow_le_pow_of_le_one ha0 ha1 hij
  have h1 : (0:ℝ) ≤ 1 - a := by linarith
  exact mul_le_mul_of_nonneg_left hpow h1

/-- Closed form of the retention curve: the first `k` keys of a geometric row
retain `1 - aᵏ`. -/
lemma mass_geoRow (a : ℝ) (k : ℕ) : mass (geoRow a) k = 1 - a ^ k := by
  induction k with
  | zero => simp
  | succ n ih =>
      rw [mass_succ, ih]
      unfold geoRow
      ring

/-- The total attention energy (collision probability) of a geometric row:
`E(a) = (1-a)/(1+a)`. -/
noncomputable def geoEnergy (a : ℝ) : ℝ := (1 - a) / (1 + a)

lemma geoEnergy_pos {a : ℝ} (ha0 : 0 ≤ a) (ha1 : a < 1) : 0 < geoEnergy a := by
  unfold geoEnergy
  apply div_pos <;> linarith

/-- Every truncation of a geometric row has energy at most `E(a) = (1-a)/(1+a)`,
with equality in the limit. -/
lemma energy_geoRow_le {a : ℝ} (ha0 : 0 ≤ a) (ha1 : a < 1) (k : ℕ) :
    energy (geoRow a) k ≤ geoEnergy a := by
  have hsq : ∀ i : ℕ, (geoRow a i) ^ 2 = (1 - a) ^ 2 * (a ^ 2) ^ i := by
    intro i; unfold geoRow; rw [mul_pow, ← pow_mul, ← pow_mul, Nat.mul_comm]
  have hsum : energy (geoRow a) k = (1 - a) ^ 2 * ∑ i ∈ Finset.range k, (a ^ 2) ^ i := by
    simp [energy, hsq, Finset.mul_sum]
  have hlt : a ^ 2 < 1 := by nlinarith
  have hne : a ^ 2 - 1 ≠ 0 := by nlinarith
  have hgeom : ∑ i ∈ Finset.range k, (a ^ 2) ^ i = ((a ^ 2) ^ k - 1) / (a ^ 2 - 1) :=
    geom_sum_eq (by intro h; apply hne; rw [h]; ring) k
  have hnum : (0:ℝ) ≤ (a ^ 2) ^ k := pow_nonneg (sq_nonneg a) k
  have hle1 : (a ^ 2) ^ k ≤ 1 := pow_le_one₀ (sq_nonneg a) (le_of_lt hlt)
  have hbound : ∑ i ∈ Finset.range k, (a ^ 2) ^ i ≤ 1 / (1 - a ^ 2) := by
    have hswap : ((a ^ 2) ^ k - 1) / (a ^ 2 - 1) = (1 - (a ^ 2) ^ k) / (1 - a ^ 2) := by
      rw [div_eq_div_iff hne (by nlinarith)]
      ring
    rw [hgeom, hswap]
    gcongr <;> nlinarith
  have h1a : (0:ℝ) ≤ (1 - a) ^ 2 := sq_nonneg _
  calc energy (geoRow a) k = (1 - a) ^ 2 * ∑ i ∈ Finset.range k, (a ^ 2) ^ i := hsum
    _ ≤ (1 - a) ^ 2 * (1 / (1 - a ^ 2)) := by
        exact mul_le_mul_of_nonneg_left hbound h1a
    _ = geoEnergy a := by
        unfold geoEnergy
        rw [show (1:ℝ) - a ^ 2 = (1 - a) * (1 + a) by ring]
        field_simp

/-! ## 2. The knee of a geometric row -/

/-- A power certificate is exactly a key budget: `aᴺ ≤ 1 - g` forces the knee
below `N`. -/
theorem geoRow_knee_le_of_pow_le {a g : ℝ} {N : ℕ} (hcert : a ^ N ≤ 1 - g) :
    knee (geoRow a) g ≤ N := by
  refine knee_le_of_pass ?_
  rw [mass_geoRow]
  linarith

/-- Conversely the knee itself certifies its power bound (for a genuinely
decaying row the gate is eventually met). -/
theorem geoRow_pow_knee_le {a g : ℝ} (ha1 : a < 1) (hg : g < 1) :
    a ^ (knee (geoRow a) g) ≤ 1 - g := by
  obtain ⟨N, hN⟩ := exists_pow_lt_of_lt_one (show (0:ℝ) < 1 - g by linarith) ha1
  have hex : ∃ k, g ≤ mass (geoRow a) k := by
    refine ⟨N, ?_⟩
    rw [mass_geoRow]; linarith
  have := knee_pass hex
  rw [mass_geoRow] at this
  linarith

/-- **The knee is logarithmic in the gate deficit.**  For a geometric row of
ratio `a`, `k*(g) ≤ 1 + log(1/(1-g))/(1-a)`. -/
theorem geoRow_knee_le_log_bound {a g : ℝ} (ha0 : 0 < a) (ha1 : a < 1)
    (hg0 : 0 ≤ g) (hg1 : g < 1) :
    (knee (geoRow a) g : ℝ) ≤ 1 + Real.log (1 - g)⁻¹ / (1 - a) := by
  set L : ℝ := Real.log (1 - g)⁻¹ with hL
  have hgpos : (0:ℝ) < 1 - g := by linarith
  have hLnonneg : 0 ≤ L := by
    rw [hL, Real.log_nonneg_iff (by positivity)]
    rw [le_inv_comm₀ (by norm_num) hgpos]
    linarith
  have hloga : Real.log a ≤ a - 1 := Real.log_le_sub_one_of_pos ha0
  have hnegloga : 0 < -Real.log a := by
    have : Real.log a < 0 := Real.log_neg ha0 ha1
    linarith
  set N : ℕ := ⌈L / (1 - a)⌉₊ with hN
  have h1a : (0:ℝ) < 1 - a := by linarith
  have hNge : L / (1 - a) ≤ (N : ℝ) := Nat.le_ceil _
  -- `N * (-log a) ≥ L`
  have hstep : L ≤ (N : ℝ) * (-Real.log a) := by
    have h1 : L ≤ (N : ℝ) * (1 - a) := by
      rw [div_le_iff₀ h1a] at hNge; linarith
    have h2 : (N : ℝ) * (1 - a) ≤ (N : ℝ) * (-Real.log a) := by
      apply mul_le_mul_of_nonneg_left _ (Nat.cast_nonneg N)
      linarith
    linarith
  -- hence `a^N ≤ 1 - g`
  have hpowpos : (0:ℝ) < a ^ N := pow_pos ha0 N
  have hlogpow : Real.log (a ^ N) ≤ Real.log (1 - g) := by
    rw [Real.log_pow]
    have hlogeq : Real.log (1 - g) = -L := by
      rw [hL, Real.log_inv]; ring
    rw [hlogeq]
    nlinarith
  have hcert : a ^ N ≤ 1 - g := by
    have := Real.exp_le_exp.mpr hlogpow
    rwa [Real.exp_log hpowpos, Real.exp_log hgpos] at this
  have hknee : knee (geoRow a) g ≤ N := geoRow_knee_le_of_pow_le hcert
  have hkR : (knee (geoRow a) g : ℝ) ≤ (N : ℝ) := by exact_mod_cast hknee
  have hceil : (N : ℝ) < L / (1 - a) + 1 :=
    Nat.ceil_lt_add_one (by positivity)
  linarith

/-- **The Cauchy–Schwarz floor for a geometric row**: `g²(1+a)/(1-a) ≤ k*(g)`. -/
theorem geoRow_knee_ge_floor {a g : ℝ} (ha0 : 0 ≤ a) (ha1 : a < 1)
    (hg0 : 0 ≤ g) (hg1 : g < 1) :
    g ^ 2 / geoEnergy a ≤ (knee (geoRow a) g : ℝ) := by
  obtain ⟨N, hN⟩ := exists_pow_lt_of_lt_one (show (0:ℝ) < 1 - g by linarith) ha1
  have hex : ∃ k, g ≤ mass (geoRow a) k := by
    refine ⟨N, ?_⟩
    rw [mass_geoRow]; linarith
  exact knee_ge_gate_sq_div_energy hg0 (geoEnergy_pos ha0 ha1)
    (fun k => energy_geoRow_le ha0 ha1 k) hex

/-! ## 3. The dichotomy: the floor is tight up to a gate-only constant -/

/-- **Main theorem of cycle 3 (refutation of the recorded conjecture).**  On the
whole geometric family the true knee never exceeds the Cauchy–Schwarz energy
floor by more than the factor `(1 + log(1/(1-g)))/g²`, which does *not* depend
on the decay ratio `a`.  Both sides blow up like `1/(1-a)` as `a → 1⁻`, so the
ratio stays bounded. -/
theorem geoRow_flatness_ratio_bounded {a g : ℝ} (ha0 : 0 < a) (ha1 : a < 1)
    (hg0 : 0 < g) (hg1 : g < 1) :
    (knee (geoRow a) g : ℝ)
      ≤ ((1 + Real.log (1 - g)⁻¹) / g ^ 2) * (g ^ 2 / geoEnergy a) := by
  have h1a : (0:ℝ) < 1 - a := by linarith
  have hgpos : (0:ℝ) < 1 - g := by linarith
  set L : ℝ := Real.log (1 - g)⁻¹ with hL
  have hLnonneg : 0 ≤ L := by
    rw [hL, Real.log_nonneg_iff (by positivity)]
    rw [le_inv_comm₀ (by norm_num) hgpos]
    linarith
  have hupper := geoRow_knee_le_log_bound ha0 ha1 (le_of_lt hg0) hg1
  -- rewrite the right-hand side
  have hRHS : ((1 + L) / g ^ 2) * (g ^ 2 / geoEnergy a) = (1 + L) * (1 + a) / (1 - a) := by
    unfold geoEnergy
    field_simp
  rw [hRHS]
  have hstep : 1 + L / (1 - a) ≤ (1 + L) * (1 + a) / (1 - a) := by
    rw [le_div_iff₀ h1a]
    have h : (1 + L / (1 - a)) * (1 - a) = (1 - a) + L := by field_simp
    rw [h]
    nlinarith
  linarith

/-- Restated as the explicit refutation of "the ratio grows without bound":
there is a single constant, depending on the gate alone, that dominates the
knee-to-floor ratio for *every* geometric row. -/
theorem geoRow_ratio_blowup_refuted {g : ℝ} (hg0 : 0 < g) (hg1 : g < 1) :
    ∃ C : ℝ, 0 < C ∧ ∀ a : ℝ, 0 < a → a < 1 →
      (knee (geoRow a) g : ℝ) ≤ C * (g ^ 2 / geoEnergy a) := by
  have hgpos : (0:ℝ) < 1 - g := by linarith
  have hLnonneg : 0 ≤ Real.log (1 - g)⁻¹ := by
    rw [Real.log_nonneg_iff (by positivity)]
    rw [le_inv_comm₀ (by norm_num) hgpos]
    linarith
  refine ⟨(1 + Real.log (1 - g)⁻¹) / g ^ 2, by positivity, ?_⟩
  intro a ha0 ha1
  exact geoRow_flatness_ratio_bounded ha0 ha1 hg0 hg1

/-- **Two-sided pin.**  For a geometric row the knee is sandwiched between the
energy floor and a constant multiple of it. -/
theorem geoRow_knee_sandwich {a g : ℝ} (ha0 : 0 < a) (ha1 : a < 1)
    (hg0 : 0 < g) (hg1 : g < 1) :
    g ^ 2 / geoEnergy a ≤ (knee (geoRow a) g : ℝ) ∧
      (knee (geoRow a) g : ℝ)
        ≤ ((1 + Real.log (1 - g)⁻¹) / g ^ 2) * (g ^ 2 / geoEnergy a) :=
  ⟨geoRow_knee_ge_floor (le_of_lt ha0) ha1 (le_of_lt hg0) hg1,
    geoRow_flatness_ratio_bounded ha0 ha1 hg0 hg1⟩

/-! ## 4. The NET-63 gate: an explicit small constant -/

lemma log_fifty_lt_four : Real.log 50 < 4 := by
  have he : (50:ℝ) < Real.exp 4 := by
    have h1 : (2.7182818283:ℝ) < Real.exp 1 := Real.exp_one_gt_d9
    have h4 : Real.exp 4 = (Real.exp 1) ^ 4 := by
      rw [← Real.exp_nat_mul]; norm_num
    have hpos : (0:ℝ) < Real.exp 1 := Real.exp_pos 1
    rw [h4]
    nlinarith [pow_pos hpos 2, pow_pos hpos 3]
  have := Real.log_lt_log (by norm_num) he
  rwa [Real.log_exp] at this

/-- At the NET-63 gate `g = 0.98` the flatness constant is smaller than `6`:
on every geometric row the true key budget is within a factor six of the
collision-entropy floor.  So an entropy measurement predicts the deployment
budget to within one small constant, uniformly over decay rates. -/
theorem net63_flatness_constant_lt_six {a : ℝ} (ha0 : 0 < a) (ha1 : a < 1) :
    (knee (geoRow a) 0.98 : ℝ) ≤ 6 * ((0.98:ℝ) ^ 2 / geoEnergy a) := by
  have hfloor_pos : (0:ℝ) < (0.98:ℝ) ^ 2 / geoEnergy a := by
    have := geoEnergy_pos (le_of_lt ha0) ha1
    positivity
  have hmain := geoRow_flatness_ratio_bounded (g := (0.98:ℝ)) ha0 ha1 (by norm_num) (by norm_num)
  have hlog : Real.log ((1:ℝ) - 0.98)⁻¹ < 4 := by
    have h50 : ((1:ℝ) - 0.98)⁻¹ = 50 := by norm_num
    rw [h50]; exact log_fifty_lt_four
  have hconst : (1 + Real.log ((1:ℝ) - 0.98)⁻¹) / (0.98:ℝ) ^ 2 ≤ 6 := by
    rw [div_le_iff₀ (by norm_num)]
    nlinarith
  calc (knee (geoRow a) 0.98 : ℝ)
      ≤ ((1 + Real.log ((1:ℝ) - 0.98)⁻¹) / (0.98:ℝ) ^ 2) * ((0.98:ℝ) ^ 2 / geoEnergy a) := hmain
    _ ≤ 6 * ((0.98:ℝ) ^ 2 / geoEnergy a) :=
        mul_le_mul_of_nonneg_right hconst (le_of_lt hfloor_pos)

/-- A concrete instance of the sandwich: the dyadic row `a = 1/2` (the profile
`geometricProfile` of cycle 1, up to indexing) has energy `1/3` and knee exactly
`6` at gate `0.98`, against a floor of `0.9604 · 3 = 2.8812` — a ratio of
`2.08`, comfortably inside the constant `6`. -/
theorem dyadic_knee_and_floor :
    geoEnergy (1/2 : ℝ) = 1/3 ∧ knee (geoRow (1/2 : ℝ)) 0.98 = 6 ∧
      (0.98:ℝ) ^ 2 / geoEnergy (1/2 : ℝ) ≤ (knee (geoRow (1/2 : ℝ)) 0.98 : ℝ) := by
  have hE : geoEnergy (1/2 : ℝ) = 1/3 := by unfold geoEnergy; norm_num
  have hknee : knee (geoRow (1/2 : ℝ)) 0.98 = 6 := by
    refine knee_eq_of_fail_pass (geoRow_nonneg (by norm_num) (by norm_num)) ?_ ?_ (by norm_num)
    · norm_num [mass_geoRow]
    · norm_num [mass_geoRow]
  refine ⟨hE, hknee, ?_⟩
  rw [hE, hknee]
  norm_num

/-!
## Lab Notes (cycle 3)

* Recorded conjecture (FUTURE_DIRECTIONS, direction 5): on geometric rows the
  ratio `(true knee)/(g²/E)` "grows without bound as `a → 1`".
  **Refuted** (`geoRow_ratio_blowup_refuted`): the ratio is bounded by
  `(1 + log(1/(1-g)))/g²`, a function of the gate alone.  The source of the
  error is that both quantities diverge at the same rate `1/(1-a)`:
  `k* ≈ log(1/(1-g))/(1-a)` and `g²/E = g²(1+a)/(1-a)`.
* Numerical check at the NET-63 gate `g = 0.98`:
  `log(1/(0.02)) = log 50 ≈ 3.912`, constant `(1+3.912)/0.9604 ≈ 5.11 < 6`
  (`net63_flatness_constant_lt_six`, using `log 50 < 4`).
* Dyadic instance `a = 1/2`: `E = 1/3`, floor `= 2.8812`, true knee `= 6`
  (`dyadic_knee_and_floor`), ratio `2.08` — consistent with the bound and with
  the cycle-1 computation `knee geometricProfile 0.98 = 6`.
-/

end Bridges.AttentionKneeFlatness
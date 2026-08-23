/-
  # Cycle 4: where the collision-entropy floor really fails

  Cycle 2 (`Bridges.AttentionKneeEntropyBound`) proved the Cauchy–Schwarz floor

      `k*(g) ≥ g² / E`,      `E = attention energy (collision probability)`,

  and cycle 3 (`Bridges.AttentionKneeFlatness`) showed that on a *geometric* row
  `w i = (1-a) aⁱ` the floor is tight up to a factor depending on the gate alone,
  uniformly in the decay ratio `a`.  That refuted the conjectured blow-up in `a`
  and raised the obvious follow-up (direction **C6** of `FUTURE_DIRECTIONS.md`):
  is the floor tight for *every* sorted row, or is the bounded-ratio phenomenon
  special to exponential decay?

  This module settles that question in the strong direction: **the floor is not
  tight in general, and the loss is unbounded even at a fixed gate.**  The
  witness is the "spike + plateau" family — one dominant key of weight `1/2`
  followed by `2m` equal keys of weight `1/(4m)` — a genuine sorted probability
  row (`spikeRow_antitone`, `mass_spikeRow_total`):

  * `mass_spikeRow`   — closed-form retention `1/2 + k/(4m)`;
  * `spikeRow_knee`   — at gate `3/4` the knee is exactly `m + 1`, so it grows
    linearly in the plateau length;
  * `energy_spikeRow_le` / `spikeRow_energy_ge_quarter` — the energy stays pinned
    in `[1/4, 1/4 + 1/(8m)]`, i.e. the Rényi-2 entropy never exceeds `2` bits,
    because the spike alone already accounts for a quarter of the energy;
  * `spikeRow_floor_le` — hence the Cauchy–Schwarz floor never exceeds `9/4`
    keys, while the true knee is `m + 1`;
  * `heavyTail_floor_ratio_unbounded` — for every `R` there is such a row whose
    knee exceeds `R` times its energy floor;
  * `entropy_floor_tightness_dichotomy` — the two halves side by side: bounded
    ratio on the whole geometric family, unbounded ratio on the spike family.

  Consequence for the NET-63 thread: an entropy (Rényi-2) measurement alone can
  *never* certify a key budget — it only ever gives a lower bound that can be
  off by an arbitrary factor.  The upper half of the bracket must come from a
  tail/decay hypothesis (cycle 1's `knee_le_of_geometric_tail`), and the
  gate-only constant of cycle 3 is a theorem *about exponential decay*, not a
  universal law.
-/

import Mathlib
import Bridges.AttentionKneeGeometry
import Bridges.AttentionKneeEntropyBound
import Bridges.AttentionKneeFlatness

namespace Bridges.AttentionKneeHeavyTail

open Finset Bridges.AttentionKneeGeometry Bridges.AttentionKneeEntropyBound
open Bridges.AttentionKneeFlatness

/-! ## 1. The spike-plus-plateau row -/

/-- `spikeRow m` is the sorted probability row consisting of one dominant key of
weight `1/2` followed by a plateau of `2m` keys of weight `1/(4m)`. -/
noncomputable def spikeRow (m : ℕ) : ℕ → ℝ :=
  fun i => if i = 0 then 1 / 2 else if i ≤ 2 * m then 1 / (4 * m) else 0

@[simp] lemma spikeRow_zero (m : ℕ) : spikeRow m 0 = 1 / 2 := by simp [spikeRow]

lemma spikeRow_mid {m i : ℕ} (h0 : i ≠ 0) (h : i ≤ 2 * m) :
    spikeRow m i = 1 / (4 * m) := by simp [spikeRow, h0, h]

lemma spikeRow_tail {m i : ℕ} (h : 2 * m < i) : spikeRow m i = 0 := by
  have h0 : i ≠ 0 := by omega
  simp [spikeRow, h0, Nat.not_le.mpr h]

lemma spikeRow_nonneg (m : ℕ) (i : ℕ) : 0 ≤ spikeRow m i := by
  unfold spikeRow
  split_ifs
  · norm_num
  · exact div_nonneg (by norm_num) (by positivity)
  · exact le_refl 0

lemma spikeRow_antitone {m : ℕ} (hm : 1 ≤ m) : Antitone (spikeRow m) := by
  have hmR : (1:ℝ) ≤ (m : ℝ) := by exact_mod_cast hm
  intro i j hij
  by_cases hj0 : j = 0
  · subst hj0
    have : i = 0 := Nat.le_zero.mp hij
    subst this
    exact le_rfl
  · by_cases hi0 : i = 0
    · subst hi0
      rw [spikeRow_zero]
      by_cases hj : j ≤ 2 * m
      · rw [spikeRow_mid hj0 hj]
        rw [div_le_div_iff₀ (by linarith) (by norm_num)]
        linarith
      · rw [spikeRow_tail (by omega)]; norm_num
    · by_cases hj : j ≤ 2 * m
      · rw [spikeRow_mid hj0 hj, spikeRow_mid hi0 (by omega)]
      · rw [spikeRow_tail (by omega)]
        by_cases hi : i ≤ 2 * m
        · rw [spikeRow_mid hi0 hi]; positivity
        · rw [spikeRow_tail (by omega)]

/-! ## 2. Retention: a linear plateau -/

/-- Closed form for the retained mass inside the plateau. -/
lemma mass_spikeRow {m : ℕ} (hm : 1 ≤ m) :
    ∀ k ≤ 2 * m, mass (spikeRow m) (k + 1) = 1 / 2 + k / (4 * m) := by
  have hmR : (0:ℝ) < (m : ℝ) := by exact_mod_cast hm
  intro k
  induction k with
  | zero => intro _; simp [mass_succ]
  | succ n ih =>
    intro hn
    have hn' : n ≤ 2 * m := by omega
    rw [mass_succ, ih hn', spikeRow_mid (by omega) hn]
    push_cast
    field_simp
    ring

/-- The row is a probability distribution: its total mass is `1`. -/
lemma mass_spikeRow_total {m : ℕ} (hm : 1 ≤ m) :
    mass (spikeRow m) (2 * m + 1) = 1 := by
  have hmR : (0:ℝ) < (m : ℝ) := by exact_mod_cast hm
  rw [mass_spikeRow hm (2 * m) le_rfl]
  push_cast
  field_simp
  ring

/-! ## 3. Energy: pinned by the spike -/

lemma energy_succ (w : ℕ → ℝ) (k : ℕ) : energy w (k + 1) = energy w k + (w k) ^ 2 := by
  simp [energy, Finset.sum_range_succ]

lemma energy_spikeRow {m : ℕ} (hm : 1 ≤ m) :
    ∀ k ≤ 2 * m, energy (spikeRow m) (k + 1) = 1 / 4 + k / (16 * (m : ℝ) ^ 2) := by
  have hmR : (0:ℝ) < (m : ℝ) := by exact_mod_cast hm
  intro k
  induction k with
  | zero => intro _; simp [energy]; norm_num
  | succ n ih =>
    intro hn
    have hn' : n ≤ 2 * m := by omega
    rw [energy_succ, ih hn', spikeRow_mid (by omega) hn]
    push_cast
    field_simp
    ring

/-- Beyond the plateau the energy is constant, equal to `1/4 + 1/(8m)`. -/
lemma energy_spikeRow_const {m : ℕ} (hm : 1 ≤ m) :
    ∀ k, 2 * m + 1 ≤ k → energy (spikeRow m) k = 1 / 4 + 1 / (8 * (m : ℝ)) := by
  have hmR : (0:ℝ) < (m : ℝ) := by exact_mod_cast hm
  intro k hk
  induction k, hk using Nat.le_induction with
  | base =>
    rw [energy_spikeRow hm (2 * m) le_rfl]
    push_cast
    field_simp
    ring
  | succ n hn ih =>
    rw [energy_succ, ih, spikeRow_tail (by omega)]
    ring

/-- The energy of the spike row never exceeds `1/4 + 1/(8m)`. -/
lemma energy_spikeRow_le {m : ℕ} (hm : 1 ≤ m) (k : ℕ) :
    energy (spikeRow m) k ≤ 1 / 4 + 1 / (8 * (m : ℝ)) := by
  by_cases hk : 2 * m + 1 ≤ k
  · exact le_of_eq (energy_spikeRow_const hm k hk)
  · have : k ≤ 2 * m + 1 := by omega
    calc energy (spikeRow m) k ≤ energy (spikeRow m) (2 * m + 1) := energy_mono this
      _ = 1 / 4 + 1 / (8 * (m : ℝ)) := energy_spikeRow_const hm _ le_rfl

/-- The spike alone already carries a quarter of the energy, so the Rényi-2
entropy of the whole family is at most `2` bits, no matter how long the
plateau. -/
lemma spikeRow_energy_ge_quarter (m : ℕ) {k : ℕ} (hk : 1 ≤ k) :
    (1:ℝ) / 4 ≤ energy (spikeRow m) k := by
  have h1 : energy (spikeRow m) 1 = 1 / 4 := by
    simp [energy]; norm_num
  calc (1:ℝ) / 4 = energy (spikeRow m) 1 := h1.symm
    _ ≤ energy (spikeRow m) k := energy_mono hk

/-! ## 4. The knee grows linearly in the plateau length -/

/-- At the gate `3/4` the spike row needs exactly `m + 1` keys. -/
theorem spikeRow_knee {m : ℕ} (hm : 1 ≤ m) :
    knee (spikeRow m) (3 / 4) = m + 1 := by
  have hmR : (0:ℝ) < (m : ℝ) := by exact_mod_cast hm
  have hpass : mass (spikeRow m) (m + 1) = 3 / 4 := by
    rw [mass_spikeRow hm m (by omega)]
    field_simp
    ring
  have hfail : mass (spikeRow m) m < 3 / 4 := by
    obtain ⟨n, rfl⟩ : ∃ n, m = n + 1 := ⟨m - 1, by omega⟩
    rw [mass_spikeRow (by omega) n (by omega)]
    have hn : (0:ℝ) ≤ (n : ℝ) := Nat.cast_nonneg n
    push_cast
    have h4 : (0:ℝ) < 4 * ((n : ℝ) + 1) := by linarith
    have key : (n : ℝ) / (4 * ((n : ℝ) + 1)) < 1 / 4 := by
      rw [div_lt_div_iff₀ h4 (by norm_num)]
      linarith
    linarith
  refine knee_eq_of_fail_pass (fun i => spikeRow_nonneg m i) ?_ (le_of_eq hpass.symm) (by omega)
  simpa using hfail

/-! ## 5. The floor is unboundedly lossy -/

/-- The Cauchy–Schwarz floor for the spike family never exceeds `9/4` keys —
while the true knee is `m + 1`. -/
theorem spikeRow_floor_le {m : ℕ} (hm : 1 ≤ m) :
    (3 / 4 : ℝ) ^ 2 / (1 / 4 + 1 / (8 * (m : ℝ))) ≤ 9 / 4 := by
  have hmR : (0:ℝ) < (m : ℝ) := by exact_mod_cast hm
  have hE : (0:ℝ) < 1 / 4 + 1 / (8 * (m : ℝ)) := by positivity
  rw [div_le_iff₀ hE]
  have : (0:ℝ) < 1 / (8 * (m : ℝ)) := by positivity
  nlinarith

/-- **Main theorem of cycle 4.**  The collision-entropy floor `g²/E` can
under-estimate the true key budget by an arbitrarily large factor, at a fixed
gate, on genuinely sorted probability rows. -/
theorem heavyTail_floor_ratio_unbounded (R : ℝ) :
    ∃ (w : ℕ → ℝ) (E : ℝ), (∀ i, 0 ≤ w i) ∧ Antitone w ∧ 0 < E ∧
      (∀ k, energy w k ≤ E) ∧ (∃ k, (3 / 4 : ℝ) ≤ mass w k) ∧
      R * ((3 / 4 : ℝ) ^ 2 / E) < (knee w (3 / 4) : ℝ) := by
  obtain ⟨m₀, hm₀⟩ := exists_nat_gt ((9 / 4 : ℝ) * |R|)
  refine ⟨spikeRow (m₀ + 1), 1 / 4 + 1 / (8 * ((m₀ + 1 : ℕ) : ℝ)),
    fun i => spikeRow_nonneg _ i, spikeRow_antitone (by omega), by positivity,
    fun k => energy_spikeRow_le (by omega) k, ⟨m₀ + 1 + 1, ?_⟩, ?_⟩
  · have := mass_spikeRow (m := m₀ + 1) (by omega) (m₀ + 1) (by omega)
    rw [show m₀ + 1 + 1 = (m₀ + 1) + 1 from rfl, this]
    push_cast
    have hquart : ((m₀ : ℝ) + 1) / (4 * ((m₀ : ℝ) + 1)) = 1 / 4 := by
      have : (0:ℝ) < (m₀ : ℝ) + 1 := by positivity
      field_simp
    rw [hquart]
    norm_num
  · have hfloor := spikeRow_floor_le (m := m₀ + 1) (by omega)
    have hknee := spikeRow_knee (m := m₀ + 1) (by omega)
    have hFpos : (0:ℝ) < (3 / 4 : ℝ) ^ 2 / (1 / 4 + 1 / (8 * ((m₀ + 1 : ℕ) : ℝ))) := by
      have : (0:ℝ) < ((m₀ + 1 : ℕ) : ℝ) := by positivity
      positivity
    rw [hknee]
    have h1 : R * ((3 / 4 : ℝ) ^ 2 / (1 / 4 + 1 / (8 * ((m₀ + 1 : ℕ) : ℝ))))
        ≤ |R| * (9 / 4) := by
      calc R * ((3 / 4 : ℝ) ^ 2 / (1 / 4 + 1 / (8 * ((m₀ + 1 : ℕ) : ℝ))))
          ≤ |R| * ((3 / 4 : ℝ) ^ 2 / (1 / 4 + 1 / (8 * ((m₀ + 1 : ℕ) : ℝ)))) := by
            exact mul_le_mul_of_nonneg_right (le_abs_self R) (le_of_lt hFpos)
        _ ≤ |R| * (9 / 4) := mul_le_mul_of_nonneg_left hfloor (abs_nonneg R)
    have h2 : |R| * (9 / 4) < ((m₀ : ℝ) + 1 + 1) := by
      have : (9 / 4 : ℝ) * |R| < (m₀ : ℝ) := hm₀
      linarith
    push_cast at h1 ⊢
    linarith

/-- **The dichotomy.**  On the geometric family the knee-to-floor ratio is
bounded by a gate-only constant (cycle 3); on the spike-plus-plateau family it
is unbounded at the same gate.  Exponential decay, not sortedness, is what makes
the entropy floor informative. -/
theorem entropy_floor_tightness_dichotomy :
    (∃ C : ℝ, 0 < C ∧ ∀ a : ℝ, 0 < a → a < 1 →
        (knee (geoRow a) (3 / 4) : ℝ) ≤ C * ((3 / 4 : ℝ) ^ 2 / geoEnergy a)) ∧
    (∀ C : ℝ, ∃ (w : ℕ → ℝ) (E : ℝ), (∀ i, 0 ≤ w i) ∧ Antitone w ∧ 0 < E ∧
        (∀ k, energy w k ≤ E) ∧ (∃ k, (3 / 4 : ℝ) ≤ mass w k) ∧
        C * ((3 / 4 : ℝ) ^ 2 / E) < (knee w (3 / 4) : ℝ)) :=
  ⟨geoRow_ratio_blowup_refuted (by norm_num) (by norm_num),
    fun C => heavyTail_floor_ratio_unbounded C⟩

end Bridges.AttentionKneeHeavyTail
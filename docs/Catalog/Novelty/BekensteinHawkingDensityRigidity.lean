import Novelty.BekensteinHawkingUniversality

/-!
# Rigidity of the horizon entropy density: exactly when is the area law non-degenerate?

`Novelty.BekensteinHawkingUniversality` shows that every puncture model with a
minimal-area puncture (`1 ≤ deg 1`) and at most exponential degeneracies
(`deg k ≤ B ^ k`) has a well-defined entropy density

`L = lim_{A → ∞} log W(A) / A ∈ [log (deg 1), log (2B)]`.

The lower bound `log (deg 1)` is vacuous when `deg 1 = 1`, and it is exactly in
that regime that the area law could conceivably degenerate into a *sub-extensive*
law `log W(A) = o(A)`.  This file settles that boundary case completely.

## Main results

* `gW_pow_le` / `two_pow_le_gW` : supermultiplicativity iterated along the
  arithmetic progression `n ↦ n * m`;
* `gDensity_ge_of_two_le_gW` : a **single** area `m ≥ 1` carrying two distinct
  microstates already forces `L ≥ (log 2)/m > 0`.  Positivity of the entropy
  density is therefore a finite-area certificate, not an asymptotic statement;
* `gStates_degenerate` / `gW_degenerate` : in the unique degenerate model
  (`deg 1 = 1` and `deg k = 0` for `k ≥ 2`) the horizon has exactly one
  microstate at every area;
* `gDensity_pos_iff` : **rigidity.**  `L > 0` if and only if the model is not the
  degenerate one, i.e. iff `2 ≤ deg 1` or some puncture of area `k ≥ 2` exists.
  Consequently every non-degenerate isolated-horizon model obeys a genuine
  (two-sided, extensive) area law `c·A ≤ log W(A) ≤ C·A`, and no model in this
  class has a sub-extensive or super-extensive ("volume") entropy.

This closes the open part of Conjecture 4 of `FUTURE_DIRECTIONS.md`.
-/

open Finset Filter

namespace BekensteinHawking
namespace Universal

/-! ## Iterated supermultiplicativity -/

/-- Concatenating `n` blocks of area `m` embeds `(gW m)^n` microstates into area
`n * m`. -/
lemma gW_pow_le (deg : ℕ → ℕ) (m n : ℕ) : (gW deg m) ^ n ≤ gW deg (n * m) := by
  induction n with
  | zero => simp
  | succ n ih =>
      calc (gW deg m) ^ (n + 1) = (gW deg m) ^ n * gW deg m := by ring
        _ ≤ gW deg (n * m) * gW deg m := Nat.mul_le_mul_right _ ih
        _ ≤ gW deg (n * m + m) := gW_supermul deg _ _
        _ = gW deg ((n + 1) * m) := by ring_nf

/-- A single area `m` with at least two microstates yields exponential growth. -/
lemma two_pow_le_gW (deg : ℕ → ℕ) (m : ℕ) (hm : 2 ≤ gW deg m) (n : ℕ) :
    2 ^ n ≤ gW deg (n * m) :=
  le_trans (Nat.pow_le_pow_left hm n) (gW_pow_le deg m n)

/-- **Finite certificate for a positive entropy density.**  If some area `m ≥ 1`
supports two distinct horizon microstates, the entropy density is at least
`(log 2)/m`. -/
theorem gDensity_ge_of_two_le_gW (deg : ℕ → ℕ) (m : ℕ) (hm1 : 1 ≤ m) (hm : 2 ≤ gW deg m)
    {L : ℝ} (hL : Tendsto (fun n : ℕ => Real.log (gW deg n) / n) atTop (nhds L)) :
    Real.log 2 / m ≤ L := by
  have hmul : Tendsto (fun n : ℕ => n * m) atTop atTop := by
    refine tendsto_atTop_atTop.2 (fun b => ⟨b, fun a ha => ?_⟩)
    exact le_trans ha (Nat.le_mul_of_pos_right a hm1)
  have hsub : Tendsto (fun n : ℕ => Real.log (gW deg (n * m)) / (n * m : ℕ)) atTop (nhds L) :=
    hL.comp hmul
  refine le_of_tendsto_of_tendsto tendsto_const_nhds hsub ?_
  filter_upwards [eventually_ge_atTop 1] with n hn
  have hmR : (0:ℝ) < m := by exact_mod_cast hm1
  have hnR : (0:ℝ) < n := by exact_mod_cast hn
  have hle : ((2:ℕ) ^ n : ℝ) ≤ (gW deg (n * m) : ℝ) := by exact_mod_cast two_pow_le_gW deg m hm n
  have hpos : (0:ℝ) < ((2:ℕ) ^ n : ℝ) := by positivity
  have hlog := Real.log_le_log hpos hle
  rw [Real.log_pow] at hlog
  push_cast at hlog
  rw [div_le_div_iff₀ hmR (by push_cast; positivity)]
  push_cast
  nlinarith [hlog]

/-! ## The unique degenerate model -/

/-- In the degenerate model (one internal state for the minimal puncture, no
punctures of larger area) the horizon of area `n` has a *unique* microstate:
`n` minimal punctures. -/
lemma gStates_degenerate (deg : ℕ → ℕ) (h1 : deg 1 = 1) (h2 : ∀ k, 2 ≤ k → deg k = 0) (n : ℕ) :
    gStates deg n = {List.replicate n (1, 0)} := by
  have hconf : ∀ n : ℕ, IsGConfig deg (List.replicate n ((1:ℕ), (0:ℕ))) := by
    intro n p hp
    rw [List.eq_of_mem_replicate hp]
    exact ⟨le_rfl, by rw [h1]; norm_num⟩
  have harea : ∀ n : ℕ, gArea (List.replicate n ((1:ℕ), (0:ℕ))) = n := by
    intro n
    simp [gArea, List.map_replicate]
  ext l
  rw [mem_gStates_iff, Finset.mem_singleton]
  constructor
  · rintro ⟨hc, ha⟩
    induction l generalizing n with
    | nil => simp [gArea] at ha; simp [← ha]
    | cons p t ih =>
        obtain ⟨hk, hd⟩ := hc p (by simp)
        have hp1 : p.1 = 1 := by
          by_contra hne
          have : 2 ≤ p.1 := by omega
          rw [h2 p.1 this] at hd
          omega
        have hp2 : p.2 = 0 := by
          rw [hp1, h1] at hd
          omega
        have hat : gArea t = n - 1 := by
          simp only [gArea_cons, hp1] at ha
          omega
        have hn1 : 1 ≤ n := by
          simp only [gArea_cons, hp1] at ha
          omega
        have hIH := ih (n - 1) (fun q hq => hc q (List.mem_cons_of_mem p hq)) hat
        have hpe : p = ((1:ℕ), (0:ℕ)) := Prod.ext hp1 hp2
        rw [hpe, hIH]
        conv_rhs => rw [show n = (n - 1) + 1 by omega]
        rw [List.replicate_succ]
  · rintro rfl
    exact ⟨hconf n, harea n⟩

/-- The degenerate model has exactly one microstate at every area. -/
lemma gW_degenerate (deg : ℕ → ℕ) (h1 : deg 1 = 1) (h2 : ∀ k, 2 ≤ k → deg k = 0) (n : ℕ) :
    gW deg n = 1 := by
  rw [gW, gStates_degenerate deg h1 h2 n, Finset.card_singleton]

/-- In the degenerate model the entropy density vanishes. -/
theorem gDensity_eq_zero_of_degenerate (deg : ℕ → ℕ) (h1 : deg 1 = 1)
    (h2 : ∀ k, 2 ≤ k → deg k = 0) {L : ℝ}
    (hL : Tendsto (fun n : ℕ => Real.log (gW deg n) / n) atTop (nhds L)) : L = 0 := by
  have hcongr : (fun n : ℕ => Real.log (gW deg n) / n) = fun _ : ℕ => (0:ℝ) := by
    funext n
    rw [gW_degenerate deg h1 h2 n]
    simp
  rw [hcongr] at hL
  exact tendsto_nhds_unique hL tendsto_const_nhds

/-! ## Existence of a two-state area in every non-degenerate model -/

/-- Any non-degenerate model has an area supporting at least two microstates. -/
lemma exists_gW_two_le (deg : ℕ → ℕ) (hdeg1 : 1 ≤ deg 1)
    (h : 2 ≤ deg 1 ∨ ∃ k, 2 ≤ k ∧ 1 ≤ deg k) : ∃ m, 1 ≤ m ∧ 2 ≤ gW deg m := by
  rcases h with h | ⟨k, hk2, hkd⟩
  · refine ⟨1, le_rfl, ?_⟩
    have := pow_le_gW deg 1
    simpa using le_trans h (by simpa using this)
  · refine ⟨k, by omega, ?_⟩
    have hmem1 : List.replicate k ((1:ℕ), (0:ℕ)) ∈ gStates deg k := by
      rw [mem_gStates_iff]
      refine ⟨?_, ?_⟩
      · intro p hp
        rw [List.eq_of_mem_replicate hp]
        refine ⟨le_rfl, ?_⟩
        show (0:ℕ) < deg 1
        omega
      · simp [gArea, List.map_replicate]
    have hmem2 : [((k:ℕ), (0:ℕ))] ∈ gStates deg k := by
      rw [mem_gStates_iff]
      refine ⟨?_, ?_⟩
      · intro p hp
        rw [List.mem_singleton.mp hp]
        refine ⟨by omega, ?_⟩
        show (0:ℕ) < deg k
        omega
      · simp [gArea]
    have hne : List.replicate k ((1:ℕ), (0:ℕ)) ≠ [((k:ℕ), (0:ℕ))] := by
      intro hcon
      have hlen : (List.replicate k ((1:ℕ), (0:ℕ))).length = 1 := by rw [hcon]; simp
      rw [List.length_replicate] at hlen
      omega
    exact Finset.one_lt_card.2 ⟨_, hmem1, _, hmem2, hne⟩

/-! ## The rigidity theorem -/

/-- **Rigidity of the area law.**  The entropy density of a puncture model is
strictly positive exactly when the model is not the degenerate one; equivalently,
the horizon entropy is sub-extensive (`log W(A) = o(A)`) only in the single model
with one internal state for the minimal puncture and no larger punctures, where
it vanishes identically. -/
theorem gDensity_pos_iff (deg : ℕ → ℕ) (hdeg1 : 1 ≤ deg 1) {L : ℝ}
    (hL : Tendsto (fun n : ℕ => Real.log (gW deg n) / n) atTop (nhds L)) :
    0 < L ↔ (2 ≤ deg 1 ∨ ∃ k, 2 ≤ k ∧ 1 ≤ deg k) := by
  constructor
  · intro hpos
    by_contra hcon
    push_neg at hcon
    obtain ⟨h1, h2⟩ := hcon
    have h1' : deg 1 = 1 := by omega
    have h2' : ∀ k, 2 ≤ k → deg k = 0 := by
      intro k hk
      have := h2 k hk
      omega
    rw [gDensity_eq_zero_of_degenerate deg h1' h2' hL] at hpos
    exact lt_irrefl 0 hpos
  · intro h
    obtain ⟨m, hm1, hm⟩ := exists_gW_two_le deg hdeg1 h
    have hmR : (0:ℝ) < m := by exact_mod_cast hm1
    have hlog2 : (0:ℝ) < Real.log 2 := Real.log_pos (by norm_num)
    have hquot : (0:ℝ) < Real.log 2 / m := by positivity
    linarith [gDensity_ge_of_two_le_gW deg m hm1 hm hL]

/-- **No volume law and no sub-extensive law.**  Every non-degenerate puncture
model has an entropy density in the *open-below* bracket `(0, log (2B)]`; the
horizon entropy is therefore exactly of area order. -/
theorem gEntropy_strictly_extensive (deg : ℕ → ℕ) (hdeg1 : 1 ≤ deg 1) (B : ℕ)
    (hdeg : ∀ k, deg k ≤ B ^ k) (hnd : 2 ≤ deg 1 ∨ ∃ k, 2 ≤ k ∧ 1 ≤ deg k) {L : ℝ}
    (hL : Tendsto (fun n : ℕ => Real.log (gW deg n) / n) atTop (nhds L)) :
    0 < L ∧ L ≤ Real.log (2 * B) := by
  refine ⟨(gDensity_pos_iff deg hdeg1 hL).2 hnd, ?_⟩
  have hWpos : ∀ n, (0:ℝ) < (gW deg n : ℝ) := by
    intro n
    exact_mod_cast Nat.lt_of_lt_of_le Nat.zero_lt_one (one_le_gW deg hdeg1 n)
  refine le_of_tendsto_of_tendsto hL tendsto_const_nhds ?_
  filter_upwards [eventually_ge_atTop 1] with n hn
  have hnpos : (0:ℝ) < n := by exact_mod_cast hn
  have hle : (gW deg n : ℝ) ≤ ((2 * B : ℕ) : ℝ) ^ n := by
    exact_mod_cast gW_le_pow deg B hdeg n
  have hlog := Real.log_le_log (hWpos n) hle
  rw [Real.log_pow] at hlog
  rw [div_le_iff₀ hnpos]
  push_cast at hlog ⊢
  linarith

/-- The concrete isolated-horizon model (`deg k = k + 1`) is non-degenerate, so
its entropy density is strictly positive — recovering `log (2+√2) > 0` from the
purely structural rigidity theorem. -/
theorem entropyDensity_pos_of_rigidity : 0 < entropyDensity := by
  have hL : Tendsto (fun n : ℕ => Real.log (gW (fun k => k + 1) n) / n) atTop
      (nhds entropyDensity) := entropyDensity_eq_universal_limit
  exact (gDensity_pos_iff (fun k => k + 1) (by norm_num) hL).2 (Or.inl (by norm_num))

end Universal
end BekensteinHawking
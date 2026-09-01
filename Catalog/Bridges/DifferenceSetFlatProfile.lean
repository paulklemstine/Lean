/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Difference-set records realise the flat, slightly negative lag profile

Companion to `Catalog.Bridges.PositionalAutocorrelationBias` (paper 249,
hit-position thread).  That file proves that mean-centring alone forces the
average sample autocorrelation over the `n - 1` nonzero lags of a cyclic record
to be exactly `-1/(n-1)`, and that a *perfectly flat* profile is pinned to that
level.  It leaves open which records actually attain it.

This file closes that question for 0/1 records — the case the experiment
measures.  For the indicator record of a set `S ⊆ ZMod n` the mean-centred
cyclic autocovariance at lag `k` is *exactly*

  `C(k) = d_S(k) - |S|² / n`,

where `d_S(k) = #{a ∈ S : a + k ∈ S}` is the difference multiplicity of `S` at
`k` (`cAutocov_indic`).  Consequently the lag profile is flat over the nonzero
lags **iff** the difference multiplicity is constant there
(`constant_profile_iff_constant_diffMult`), i.e. iff `S` is a cyclic difference
set; and in that case the common autocorrelation level is exactly `-1/(n-1)`
(`difference_set_profile_eq_neg_inv`).

So the "maximally flat, slightly negative" shape recorded in the experiment is
attained by a fully deterministic, design-theoretic record: flatness at the
artefact level carries no dependence information whatsoever.  The planar
difference set `{0, 1, 3} ⊆ ZMod 7` is verified as an explicit instance
(`fano_difference_set_diffMult`, `fano_difference_set_profile`).
-/

import Bridges.PositionalAutocorrelationBias

open Finset

namespace DifferenceSetFlatProfile

open PositionalAutocorrelationBias

variable {n : ℕ} [NeZero n]

/-- The 0/1 record supported on `S`. -/
def indic (S : Finset (ZMod n)) (i : ZMod n) : ℝ := if i ∈ S then 1 else 0

/-- Difference multiplicity of `S` at lag `k`: the number of `a ∈ S` with
`a + k ∈ S`. -/
def diffMult (S : Finset (ZMod n)) (k : ZMod n) : ℕ :=
  (S.filter (fun a => a + k ∈ S)).card

/-- A general shape for the mean-centred cyclic autocovariance: raw lag product
minus the square of the total, normalised. -/
theorem cAutocov_eq_raw (x : ZMod n → ℝ) (k : ZMod n) :
    cAutocov x k = (∑ i, x i * x (i + k)) - (∑ i, x i) ^ 2 / n := by
  have hn : (n : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr (NeZero.ne n)
  have hshift : ∑ i, x (i + k) = ∑ i, x i :=
    Fintype.sum_equiv (Equiv.addRight k) _ _ (fun _ => rfl)
  have hcard : ((Finset.univ : Finset (ZMod n)).card : ℝ) = n := by
    rw [Finset.card_univ, ZMod.card n]
  unfold cAutocov resid
  have : ∀ i : ZMod n, (x i - cmean x) * (x (i + k) - cmean x)
      = x i * x (i + k) - cmean x * x (i + k) - cmean x * x i + cmean x * cmean x := by
    intro i; ring
  rw [Finset.sum_congr rfl (fun i _ => this i)]
  rw [Finset.sum_add_distrib, Finset.sum_sub_distrib, Finset.sum_sub_distrib,
    ← Finset.mul_sum, ← Finset.mul_sum, hshift, Finset.sum_const, nsmul_eq_mul, hcard]
  unfold cmean
  field_simp
  ring

/-- The total mass of a 0/1 record is the cardinality of its support. -/
theorem sum_indic (S : Finset (ZMod n)) : ∑ i, indic S i = (S.card : ℝ) := by
  unfold indic
  rw [Finset.sum_ite_mem, Finset.univ_inter, Finset.sum_const, nsmul_eq_mul, mul_one]

/-- The raw lag-`k` product of a 0/1 record counts differences. -/
theorem sum_indic_mul_shift (S : Finset (ZMod n)) (k : ZMod n) :
    ∑ i, indic S i * indic S (i + k) = (diffMult S k : ℝ) := by
  unfold indic diffMult
  have hpt : ∀ i : ZMod n, (if i ∈ S then (1:ℝ) else 0) * (if i + k ∈ S then 1 else 0)
      = if i ∈ S then (if i + k ∈ S then (1:ℝ) else 0) else 0 := by
    intro i; split <;> simp
  have hcard : (((S.filter (fun a => a + k ∈ S)).card : ℕ) : ℝ)
      = ∑ i ∈ S, if i + k ∈ S then (1:ℝ) else 0 := by
    rw [Finset.card_filter]
    push_cast
    simp
  rw [Finset.sum_congr rfl (fun i _ => hpt i), Finset.sum_ite_mem, Finset.univ_inter, hcard]

/-- **The autocovariance of a 0/1 record is its difference multiplicity, recentred.**
For every set `S ⊆ ZMod n` and every lag `k`,
`C(k) = d_S(k) - |S|²/n`. -/
theorem cAutocov_indic (S : Finset (ZMod n)) (k : ZMod n) :
    cAutocov (indic S) k = (diffMult S k : ℝ) - (S.card : ℝ) ^ 2 / n := by
  rw [cAutocov_eq_raw, sum_indic_mul_shift, sum_indic]

omit [NeZero n] in
/-- At lag `0` the difference multiplicity is the support size. -/
theorem diffMult_zero (S : Finset (ZMod n)) : diffMult S 0 = S.card := by
  unfold diffMult
  refine congrArg Finset.card (Finset.filter_true_of_mem ?_)
  intro a ha
  simpa using ha

/-- The variance of a 0/1 record: `|S| (1 - |S|/n)`. -/
theorem cAutocov_indic_zero (S : Finset (ZMod n)) :
    cAutocov (indic S) 0 = (S.card : ℝ) - (S.card : ℝ) ^ 2 / n := by
  rw [cAutocov_indic, diffMult_zero]

/-- A 0/1 record is nonconstant exactly when its support is proper and nonempty;
then its variance is strictly positive. -/
theorem cAutocov_indic_zero_pos (S : Finset (ZMod n)) (hne : S.Nonempty)
    (hlt : S.card < n) : 0 < cAutocov (indic S) 0 := by
  have hn : (0 : ℝ) < n := by
    have := NeZero.ne n
    have : 0 < n := Nat.pos_of_ne_zero this
    exact_mod_cast this
  have hcpos : (0 : ℝ) < S.card := by
    have : 0 < S.card := Finset.card_pos.mpr hne
    exact_mod_cast this
  have hclt : (S.card : ℝ) < n := by exact_mod_cast hlt
  rw [cAutocov_indic_zero]
  rw [sub_pos, div_lt_iff₀ hn, sq]
  exact mul_lt_mul_of_pos_left hclt hcpos

/-- **Flat profile ⟺ constant difference multiplicity.**  For a 0/1 record with
nonzero variance, the sample autocorrelation is constant over the nonzero lags
if and only if the difference multiplicity of the support is constant there,
i.e. iff the support is a cyclic difference set. -/
theorem constant_profile_iff_constant_diffMult (S : Finset (ZMod n))
    (hvar : cAutocov (indic S) 0 ≠ 0) :
    (∃ t : ℝ, ∀ k ∈ Finset.univ.erase (0 : ZMod n), cAutocorr (indic S) k = t)
      ↔ (∃ l : ℕ, ∀ k ∈ Finset.univ.erase (0 : ZMod n), diffMult S k = l) := by
  constructor
  · rintro ⟨t, ht⟩
    rcases Finset.eq_empty_or_nonempty (Finset.univ.erase (0 : ZMod n)) with hemp | ⟨k0, hk0⟩
    · exact ⟨0, fun k hk => absurd hk (by simp [hemp])⟩
    refine ⟨diffMult S k0, fun k hk => ?_⟩
    have hcov : ∀ k ∈ Finset.univ.erase (0 : ZMod n),
        cAutocov (indic S) k = t * cAutocov (indic S) 0 := by
      intro k hk
      have := ht k hk
      unfold cAutocorr at this
      field_simp at this
      linarith [this]
    have h1 := hcov k hk
    have h2 := hcov k0 hk0
    rw [cAutocov_indic] at h1 h2
    have : (diffMult S k : ℝ) = (diffMult S k0 : ℝ) := by linarith
    exact_mod_cast this
  · rintro ⟨l, hl⟩
    refine ⟨((l : ℝ) - (S.card : ℝ) ^ 2 / n) / cAutocov (indic S) 0, fun k hk => ?_⟩
    unfold cAutocorr
    rw [cAutocov_indic, hl k hk]

/-- **Difference-set records attain the artefact level exactly.**  If the support
has constant difference multiplicity over the nonzero lags (a cyclic difference
set), then every nonzero-lag autocorrelation equals `-1/(n-1)`: the flat,
slightly negative profile of the experimental record is realised by a
deterministic design. -/
theorem difference_set_profile_eq_neg_inv (S : Finset (ZMod n)) (hn : 2 ≤ n)
    (hvar : cAutocov (indic S) 0 ≠ 0) (l : ℕ)
    (hl : ∀ k ∈ Finset.univ.erase (0 : ZMod n), diffMult S k = l)
    {k : ZMod n} (hk : k ≠ 0) :
    cAutocorr (indic S) k = -1 / (n - 1 : ℝ) := by
  obtain ⟨t, ht⟩ :=
    (constant_profile_iff_constant_diffMult S hvar).mpr ⟨l, hl⟩
  have hkmem : k ∈ Finset.univ.erase (0 : ZMod n) := by
    simp [Finset.mem_erase, hk]
  rw [ht k hkmem]
  exact constant_profile_eq_neg_inv (indic S) hn hvar t ht

/-- The planar difference set `{0, 1, 3} ⊆ ZMod 7`: every nonzero lag has
difference multiplicity exactly `1`. -/
theorem fano_difference_set_diffMult :
    ∀ k ∈ Finset.univ.erase (0 : ZMod 7),
      diffMult ({0, 1, 3} : Finset (ZMod 7)) k = 1 := by
  decide

/-- Its lag profile is *exactly* the artefact level `-1/6` at all six nonzero
lags — a completely deterministic record whose measured autocorrelation profile
is flat and slightly negative. -/
theorem fano_difference_set_profile {k : ZMod 7} (hk : k ≠ 0) :
    cAutocorr (indic ({0, 1, 3} : Finset (ZMod 7))) k = -1 / 6 := by
  have hcard : ({0, 1, 3} : Finset (ZMod 7)).card = 3 := by decide
  have hvar : cAutocov (indic ({0, 1, 3} : Finset (ZMod 7))) 0 ≠ 0 := by
    rw [cAutocov_indic_zero, hcard]
    norm_num
  have h := difference_set_profile_eq_neg_inv ({0, 1, 3} : Finset (ZMod 7))
    (by norm_num) hvar 1 fano_difference_set_diffMult hk
  exact h.trans (by norm_num)

end DifferenceSetFlatProfile
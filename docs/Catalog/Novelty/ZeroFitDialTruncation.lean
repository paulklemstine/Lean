import Mathlib
import Novelty.ZeroFitDialU64

/-!
# Truncated zero-count statistics cannot explain the U64 dial

Cycle 3 of the round-61 investigation.

Cycle 1 (`Novelty.ZeroFitDialU64`) showed that the *full* 2-adic tie profile has ceiling
`ρ² → 6/7`, far above the recorded `ρ² = 0.419904`, and that the ceiling is essentially
constant in the bitlen.  A natural rescue for a "the statistic is to blame" explanation is
**truncation**: real instrumentation caps the trailing-zero count at some `c`, merging all
draws with `v₂ ≥ c` (and the draw `0`) into one big block.  Since a big block destroys a lot
of rank variance, one might hope that a small cap explains the low reading.

This file computes that ceiling exactly and refutes the hope:

`ρ²(b, c) = (6/7) · (8^b − 8^{b−c}) / (8^b − 2^b)`  (`capped_spearmanSq`)

which is **increasing in the cap** and bounded below by `3/4` for every cap `c ≥ 1`
(`capped_ge_three_quarters`).  Since the recorded pooled reading is `ρ² = 0.419904 < 3/4`,
*no* truncation of the zero-count statistic can produce it (`no_truncation_explains_u64`).

Two consistency checks fall out.  At `c = 1` the profile is the even/odd split and the
formula gives `(3/4)·2^{2b}/(2^{2b} − 1)`, matching the balanced two-class value
`3jk/((j+k)² − 1)` of `Novelty.ZeroFitDialNested`.  At `c = b` it reproduces the full
dyadic ceiling of cycle 1.

Conclusion of the three cycles: the decline of the zero-fit dial is a property of the
*response*, not of the zero-count statistic, however that statistic is quantised.
-/

open Finset

namespace Catalog.Novelty.ZeroFitDialTruncation

open Catalog.Novelty.ZeroFitDialU64

/-- Tie profile of the trailing-zero count on `{0, …, 2^m − 1}` capped at `c`:
blocks `2^{m−1}, 2^{m−2}, …, 2^{m−c}` and one merged tail block of size `2^{m−c}`. -/
def capped : ℕ → ℕ → List ℕ
  | m, 0 => [2 ^ m]
  | 0, _ + 1 => [1]
  | m + 1, c + 1 => 2 ^ m :: capped m c

lemma capped_sum : ∀ (m c : ℕ), c ≤ m → (capped m c).sum = 2 ^ m := by
  intro m c
  induction c generalizing m with
  | zero => intro _; simp [capped]
  | succ c ih =>
      intro h
      match m with
      | 0 => omega
      | m + 1 =>
          have hc : c ≤ m := by omega
          simp [capped, ih m hc, pow_succ]
          ring

lemma capped_tieCorr : ∀ (m c : ℕ), c ≤ m →
    12 * tieCorr (capped m c) = ((8 : ℚ) ^ m + 6 * 8 ^ (m - c)) / 7 - 2 ^ m := by
  intro m c
  induction c generalizing m with
  | zero =>
      intro _
      have hnil : tieCorr ([] : List ℕ) = 0 := rfl
      rw [capped, tieCorr_cons, hnil, Nat.sub_zero]
      push_cast
      rw [pow_two_cube m]
      ring
  | succ c ih =>
      intro h
      match m with
      | 0 => omega
      | m + 1 =>
          have hc : c ≤ m := by omega
          have hsub : m + 1 - (c + 1) = m - c := by omega
          rw [capped, tieCorr_cons, mul_add, ih m hc, hsub]
          push_cast
          have h8 : ((2 : ℚ) ^ m) ^ 3 = 8 ^ m := pow_two_cube m
          rw [pow_succ (8 : ℚ) m, pow_succ (2 : ℚ) m]
          linarith [h8]

/-- **Exact ceiling of a truncated zero-count statistic.** -/
theorem capped_spearmanSq (b c : ℕ) (hc : c ≤ b) (hb : 1 ≤ b) :
    spearmanSq (capped b c) = (6 / 7) * ((8 : ℚ) ^ b - 8 ^ (b - c)) / ((8 : ℚ) ^ b - 2 ^ b) := by
  have hsum : (capped b c).sum = 2 ^ b := capped_sum b c hc
  have h2 : 2 ≤ (capped b c).sum := by
    rw [hsum]
    calc 2 = 2 ^ 1 := rfl
      _ ≤ 2 ^ b := Nat.pow_le_pow_right (by norm_num) hb
  have hx : (2 : ℚ) ≤ (2 : ℚ) ^ b := by
    calc (2 : ℚ) = 2 ^ 1 := (pow_one 2).symm
      _ ≤ 2 ^ b := pow_le_pow_right₀ (by norm_num) hb
  have hcast : (((capped b c).sum : ℕ) : ℚ) = (2 : ℚ) ^ b := by rw [hsum]; push_cast; ring
  have h8 : ((2 : ℚ) ^ b) ^ 3 = 8 ^ b := pow_two_cube b
  rw [spearmanSq_eq _ h2, hcast, capped_tieCorr b c hc, h8]
  have hden : ((8 : ℚ) ^ b - 2 ^ b) ≠ 0 := by
    have : (0 : ℚ) < ((2 : ℚ) ^ b) ^ 3 - 2 ^ b := cube_sub_self_pos hx
    rw [h8] at this
    exact ne_of_gt this
  field_simp
  ring

/-- The truncated ceiling never drops below `3/4`, whatever the cap `c ≥ 1` and bitlen. -/
theorem capped_ge_three_quarters (b c : ℕ) (hc1 : 1 ≤ c) (hc : c ≤ b) (hb : 1 ≤ b) :
    3 / 4 ≤ spearmanSq (capped b c) := by
  rw [capped_spearmanSq b c hc hb]
  have h8b : (0 : ℚ) < (8 : ℚ) ^ b := by positivity
  have hx : (2 : ℚ) ≤ (2 : ℚ) ^ b := by
    calc (2 : ℚ) = 2 ^ 1 := (pow_one 2).symm
      _ ≤ 2 ^ b := pow_le_pow_right₀ (by norm_num) hb
  have h8 : ((2 : ℚ) ^ b) ^ 3 = 8 ^ b := pow_two_cube b
  have hden : (0 : ℚ) < (8 : ℚ) ^ b - 2 ^ b := by
    have := cube_sub_self_pos hx
    rw [h8] at this
    exact this
  -- the merged tail has size `2^{b-c} ≤ 2^{b-1}`, so `8^{b-c} ≤ 8^b/8`
  have hle : (8 : ℚ) ^ (b - c) ≤ (8 : ℚ) ^ (b - 1) :=
    pow_le_pow_right₀ (by norm_num) (by omega)
  have hstep : (8 : ℚ) ^ b = 8 * 8 ^ (b - 1) := by
    conv_lhs => rw [show b = (b - 1) + 1 from by omega]
    rw [pow_succ]
    ring
  have hbound : (8 : ℚ) ^ b - 8 ^ (b - c) ≥ 7 / 8 * 8 ^ b := by
    rw [hstep]; linarith
  rw [le_div_iff₀ hden]
  have h2b : (0 : ℚ) < (2 : ℚ) ^ b := by positivity
  nlinarith

/-- **No truncation explains the U64 reading.**  Every capped zero-count statistic has ceiling
at least `3/4`, while the recorded pooled reading is `ρ² = 0.419904`. -/
theorem no_truncation_explains_u64 (b c : ℕ) (hc1 : 1 ≤ c) (hc : c ≤ b) (hb : 1 ≤ b) :
    pooled ^ 2 < spearmanSq (capped b c) := by
  have h := capped_ge_three_quarters b c hc1 hc hb
  have : pooled ^ 2 < 3 / 4 := by norm_num [pooled]
  linarith

/-- Consistency check with cycle 1: at full cap `c = b` the formula reproduces the dyadic
ceiling `(6/7)(1 + 1/(2^b(2^b+1)))`. -/
theorem capped_full_eq_dyadic (b : ℕ) (hb : 1 ≤ b) :
    spearmanSq (capped b b) = spearmanSq (dyadicBlocks b) := by
  rw [capped_spearmanSq b b le_rfl hb, dyadic_spearmanSq b hb, Nat.sub_self, pow_zero]
  have hx : (2 : ℚ) ≤ (2 : ℚ) ^ b := by
    calc (2 : ℚ) = 2 ^ 1 := (pow_one 2).symm
      _ ≤ 2 ^ b := pow_le_pow_right₀ (by norm_num) hb
  have h8 : ((2 : ℚ) ^ b) ^ 3 = 8 ^ b := pow_two_cube b
  set x : ℚ := (2 : ℚ) ^ b with hxdef
  have h1 : x ≠ 0 := by linarith
  have h2 : x + 1 ≠ 0 := by linarith
  have h3 : x - 1 ≠ 0 := by intro hcon; linarith
  have hrw : (8 : ℚ) ^ b = x ^ 3 := h8.symm
  rw [hrw]
  have hfac : x ^ 3 - x = x * (x - 1) * (x + 1) := by ring
  rw [hfac]
  field_simp
  ring

/-- Consistency check with cycle 2: at cap `c = 1` the profile is the even/odd split and the
ceiling is the balanced two-class value `(3/4)·4^b/(4^b − 1)`. -/
theorem capped_one_eq_binary (b : ℕ) (hb : 1 ≤ b) :
    spearmanSq (capped b 1) = 3 / 4 * ((4 : ℚ) ^ b / ((4 : ℚ) ^ b - 1)) := by
  rw [capped_spearmanSq b 1 hb hb]
  have hx : (2 : ℚ) ≤ (2 : ℚ) ^ b := by
    calc (2 : ℚ) = 2 ^ 1 := (pow_one 2).symm
      _ ≤ 2 ^ b := pow_le_pow_right₀ (by norm_num) hb
  have h8 : ((2 : ℚ) ^ b) ^ 3 = 8 ^ b := pow_two_cube b
  have h4 : ((2 : ℚ) ^ b) ^ 2 = 4 ^ b := by rw [← pow_mul, mul_comm, pow_mul]; norm_num
  have hstep : (8 : ℚ) ^ (b - 1) = (8 : ℚ) ^ b / 8 := by
    have hb1 : b = (b - 1) + 1 := by omega
    rw [show (8 : ℚ) ^ b = 8 ^ ((b - 1) + 1) from by rw [← hb1], pow_succ]
    ring
  rw [hstep]
  set x : ℚ := (2 : ℚ) ^ b with hxdef
  have h1 : x ≠ 0 := by linarith
  have hx1 : x - 1 ≠ 0 := by intro hcon; linarith
  have hx1' : x + 1 ≠ 0 := by linarith
  have hrw8 : (8 : ℚ) ^ b = x ^ 3 := h8.symm
  have hrw4 : (4 : ℚ) ^ b = x ^ 2 := h4.symm
  rw [hrw8, hrw4]
  have hfac : x ^ 3 - x = x * (x - 1) * (x + 1) := by ring
  have hfac2 : x ^ 2 - 1 = (x - 1) * (x + 1) := by ring
  rw [hfac, hfac2]
  field_simp
  ring

end Catalog.Novelty.ZeroFitDialTruncation
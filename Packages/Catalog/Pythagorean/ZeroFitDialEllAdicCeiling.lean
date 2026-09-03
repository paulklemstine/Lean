import Mathlib
import Novelty.ZeroFitDialU64
import Pythagorean.ZeroFitDialRelationRate48
import Pythagorean.ZeroFitDialBitlenStable

/-!
# The ℓ-adic ceiling family: the modulus axis, in contrast with the bitlen axis

## Research context (FACT round-47 #1, exp 508, cycle 2)

`Pythagorean.ZeroFitDialBitlenStable` proved that the *bitlen* axis is inert: the entire
ceiling ladder of the zero-fit dial depends on the bitlen only through the Möbius factor
`X/(X-1)`, `X = 8^b`, so bitlen 48 and bitlen 52 are indistinguishable to `10^{-40}`.

That immediately raises the complementary question, which this file settles: *is any axis of
the construction non-inert?*  The natural candidate is the **sampling modulus** `ℓ`: the
2-adic valuation profile is replaced by the `ℓ`-adic one, on `{0, …, ℓ^b - 1}`.  The answer
is yes, and sharply so — the modulus moves the ceiling by an `O(1)` amount, and the recorded
dial *excludes* every modulus `ℓ ≥ 5`.

## Main results

* `ellBlocks` — the `ℓ`-adic valuation tie profile, with `ellBlocks 2 = dyadicBlocks`
  (`ellBlocks_two`).
* `tieCorr_ell` — the tie correction is a base-`ℓ³` repunit:
  `12·Σ(m³-m)/12 · (ℓ³-1) = (ℓ-1)³(ℓ^{3b}-1) - (ℓ^b-1)(ℓ³-1)`.
* `ell_spearmanSq` — **the closed ceiling**:
  `ρ² = (3ℓ/(ℓ²+ℓ+1))·(1 + 1/(x(x+1)))`, `x = ℓ^b`.  At `ℓ = 2` this is exactly the
  catalog's `(6/7)(1 + 1/(2^b(2^b+1)))`, recovered as `ell_two_recovers_dyadic`.
* `ell_ceiling_close` — for fixed `ℓ` the ceiling is within `ℓ^{-2b}` of the modulus-only
  limit `3ℓ/(ℓ²+ℓ+1)`: bitlen-stability holds verbatim for every modulus.
* `ell_limit_strict_anti` — the limit is *strictly decreasing* in `ℓ`, contradicting the
  naive expectation that a finer valuation grading helps; the reason is that the class
  `v = 0` swallows a fraction `(ℓ-1)/ℓ` of the sample.
* `recorded_dial_forces_small_modulus` — **payload**: the recorded dial `0.7192` is
  incompatible with every sampling modulus `ℓ ≥ 5`, at every bitlen.
* `moduli_two_three_four_admissible` — and `ℓ ∈ {2,3,4}` are all admissible, so the
  exclusion is sharp.
* `modulus_axis_is_live` — the contrast: the bitlen axis moves the ceiling by `< 10^{-40}`,
  the modulus axis by `> 0.16` in a single step.
* `card_ell_adic_block`, `ellBlocks_eq_valuation_profile` — the arithmetic bridge: the list
  `ellBlocks` is genuinely the profile of the `ℓ`-adic valuation classes, each of size
  `(ℓ-1)·ℓ^{b-1-k}` (e.g. `ℓ = 3, b = 3` gives `[18, 6, 2, 1]`), generalising the catalog's
  `card_two_adic_block` from `ℓ = 2`.
-/

open Catalog.Novelty.ZeroFitDialU64
open Catalog.Pythagorean.ZeroFitDialRelationRate48
open Catalog.Pythagorean.ZeroFitDialBitlenStable

namespace Catalog.Pythagorean.ZeroFitDialEllAdicCeiling

/-! ## 1. The `ℓ`-adic tie profile -/

/-- Tie profile of the `ℓ`-adic valuation on `{0, …, ℓ^b - 1}`: the class `v = k` has
`(ℓ-1)·ℓ^{b-1-k}` elements, and `0` is a singleton class of its own. -/
def ellBlocks (l : ℕ) : ℕ → List ℕ
  | 0 => [1]
  | b + 1 => (l - 1) * l ^ b :: ellBlocks l b

/-- At modulus `2` this is precisely the catalog's dyadic profile. -/
lemma ellBlocks_two (b : ℕ) : ellBlocks 2 b = dyadicBlocks b := by
  induction b with
  | zero => rfl
  | succ k ih => simp [ellBlocks, dyadicBlocks, ih]

lemma ellBlocks_sum (l b : ℕ) (hl : 1 ≤ l) : (ellBlocks l b).sum = l ^ b := by
  induction b with
  | zero => simp [ellBlocks]
  | succ k ih =>
      have hstep : (l - 1) * l ^ k + l ^ k = l ^ (k + 1) := by
        have h : l - 1 + 1 = l := by omega
        calc (l - 1) * l ^ k + l ^ k = (l - 1 + 1) * l ^ k := by ring
          _ = l * l ^ k := by rw [h]
          _ = l ^ (k + 1) := by ring
      simp [ellBlocks, ih, hstep]

/-! ## 2. The tie correction is a base-`ℓ³` repunit -/

/-- **Repunit form of the `ℓ`-adic tie correction.**  Summing `(m³-m)/12` over the
valuation classes telescopes against the geometric series `Σ_{k<b} ℓ^{3k}`. -/
theorem tieCorr_ell (l b : ℕ) (hl : 2 ≤ l) :
    12 * tieCorr (ellBlocks l b) * (((l : ℚ)) ^ 3 - 1)
      = ((l : ℚ) - 1) ^ 3 * (((l : ℚ) ^ b) ^ 3 - 1)
        - ((l : ℚ) ^ b - 1) * (((l : ℚ)) ^ 3 - 1) := by
  have hcast : ((l - 1 : ℕ) : ℚ) = (l : ℚ) - 1 := by
    have : (1 : ℕ) ≤ l := by omega
    push_cast [Nat.cast_sub this]
    ring
  induction b with
  | zero => simp [ellBlocks, tieCorr]
  | succ k ih =>
      have hm : (((l - 1) * l ^ k : ℕ) : ℚ) = ((l : ℚ) - 1) * (l : ℚ) ^ k := by
        push_cast [hcast]
        ring
      rw [ellBlocks, tieCorr_cons]
      have hexp : ((l : ℚ) ^ (k + 1)) = (l : ℚ) * (l : ℚ) ^ k := by ring
      rw [mul_add, add_mul, hm, hexp, ih]
      ring

/-! ## 3. The closed ceiling at modulus `ℓ` -/

/-- The modulus-only limit of the ceiling: `3ℓ/(ℓ²+ℓ+1)`. -/
def ellLimit (l : ℕ) : ℚ := 3 * (l : ℚ) / ((l : ℚ) ^ 2 + (l : ℚ) + 1)

/-- **The `ℓ`-adic tie ceiling.**  For modulus `ℓ ≥ 2` and `b ≥ 1`,
`ρ² = (3ℓ/(ℓ²+ℓ+1))·(1 + 1/(x(x+1)))` with `x = ℓ^b`.  The modulus enters through the
`O(1)` prefactor, the bitlen only through the `1/(x(x+1))` Möbius correction. -/
theorem ell_spearmanSq (l b : ℕ) (hl : 2 ≤ l) (hb : 1 ≤ b) :
    spearmanSq (ellBlocks l b)
      = ellLimit l * (1 + 1 / ((l : ℚ) ^ b * ((l : ℚ) ^ b + 1))) := by
  have hL : (2 : ℚ) ≤ (l : ℚ) := by exact_mod_cast hl
  have hx : (2 : ℚ) ≤ (l : ℚ) ^ b := by
    calc (2 : ℚ) = (2 : ℚ) ^ 1 := (pow_one 2).symm
      _ ≤ (l : ℚ) ^ 1 := by
          apply pow_le_pow_left₀ (by norm_num) hL
      _ ≤ (l : ℚ) ^ b := by
          apply pow_le_pow_right₀ (by linarith) hb
  have hsum : (ellBlocks l b).sum = l ^ b := ellBlocks_sum l b (by omega)
  have h2 : 2 ≤ (ellBlocks l b).sum := by
    rw [hsum]
    calc 2 = 2 ^ 1 := rfl
      _ ≤ 2 ^ b := Nat.pow_le_pow_right (by norm_num) hb
      _ ≤ l ^ b := Nat.pow_le_pow_left hl b
  have hcastsum : (((ellBlocks l b).sum : ℕ) : ℚ) = (l : ℚ) ^ b := by
    rw [hsum]; push_cast; ring
  have hkey := tieCorr_ell l b hl
  set x : ℚ := (l : ℚ) ^ b with hxdef
  set L : ℚ := (l : ℚ) with hLdef
  have hL3pos : (8 : ℚ) ≤ L ^ 3 := by
    have h := pow_le_pow_left₀ (by norm_num : (0 : ℚ) ≤ 2) hL 3
    norm_num at h
    linarith
  have hL3 : L ^ 3 - 1 ≠ 0 := by intro hc; linarith
  have hxne : x ≠ 0 := by linarith
  have hx1 : x + 1 ≠ 0 := by linarith
  have hxm1 : x - 1 ≠ 0 := by intro hc; linarith
  have hquadpos : (0 : ℚ) < L ^ 2 + L + 1 := by nlinarith [sq_nonneg L]
  have hquad : L ^ 2 + L + 1 ≠ 0 := ne_of_gt hquadpos
  have htie : 12 * tieCorr (ellBlocks l b)
      = (((L - 1) ^ 3 * (x ^ 3 - 1)) - (x - 1) * (L ^ 3 - 1)) / (L ^ 3 - 1) := by
    field_simp
    linarith [hkey]
  rw [spearmanSq_eq _ h2, hcastsum, htie, ellLimit]
  have hcube : x ^ 3 - x = x * (x - 1) * (x + 1) := by ring
  rw [hcube]
  have hfac : L ^ 3 - 1 = (L - 1) * (L ^ 2 + L + 1) := by ring
  rw [hfac]
  have hLm1 : L - 1 ≠ 0 := by intro hc; nlinarith
  field_simp
  ring

/-- Consistency with the catalog: at modulus `2` the formula is the recorded dyadic
ceiling `(6/7)(1 + 1/(2^b(2^b+1)))`. -/
theorem ell_two_recovers_dyadic (b : ℕ) (hb : 1 ≤ b) :
    spearmanSq (ellBlocks 2 b) = (6 / 7) * (1 + 1 / ((2 : ℚ) ^ b * (2 ^ b + 1))) := by
  rw [ellBlocks_two, dyadic_spearmanSq b hb]

/-! ## 4. Bitlen stability at every modulus -/

/-- For fixed modulus the ceiling is within `ℓ^{-2b}` of its bitlen-free limit: the
bitlen-stability of the main cycle is a modulus-uniform phenomenon. -/
theorem ell_ceiling_close (l b : ℕ) (hl : 2 ≤ l) (hb : 1 ≤ b) :
    spearmanSq (ellBlocks l b) - ellLimit l ≤ 1 / ((l : ℚ) ^ b) ^ 2 := by
  have hL : (2 : ℚ) ≤ (l : ℚ) := by exact_mod_cast hl
  have hx : (2 : ℚ) ≤ (l : ℚ) ^ b := by
    calc (2 : ℚ) = (2 : ℚ) ^ 1 := (pow_one 2).symm
      _ ≤ (l : ℚ) ^ 1 := by apply pow_le_pow_left₀ (by norm_num) hL
      _ ≤ (l : ℚ) ^ b := by apply pow_le_pow_right₀ (by linarith) hb
  rw [ell_spearmanSq l b hl hb, ellLimit]
  set x : ℚ := (l : ℚ) ^ b with hxdef
  set L : ℚ := (l : ℚ) with hLdef
  have hquad : (0 : ℚ) < L ^ 2 + L + 1 := by nlinarith
  have hlim1 : 3 * L / (L ^ 2 + L + 1) ≤ 1 := by
    rw [div_le_one hquad]
    nlinarith [sq_nonneg (L - 1)]
  have hlim0 : (0 : ℚ) ≤ 3 * L / (L ^ 2 + L + 1) := by positivity
  have hstep : 3 * L / (L ^ 2 + L + 1) * (1 + 1 / (x * (x + 1)))
      - 3 * L / (L ^ 2 + L + 1) = (3 * L / (L ^ 2 + L + 1)) * (1 / (x * (x + 1))) := by
    ring
  rw [hstep]
  have hxpos : (0 : ℚ) < x := by linarith
  have hfrac : 1 / (x * (x + 1)) ≤ 1 / x ^ 2 := by
    apply one_div_le_one_div_of_le (by positivity)
    nlinarith
  have hpos : (0 : ℚ) < 1 / (x * (x + 1)) := by positivity
  calc (3 * L / (L ^ 2 + L + 1)) * (1 / (x * (x + 1)))
      ≤ 1 * (1 / (x * (x + 1))) := by nlinarith
    _ ≤ 1 / x ^ 2 := by linarith

/-! ## 5. The modulus axis is live -/

/-- **The modulus-only ceiling is strictly decreasing in `ℓ`.**  A finer valuation grading
*hurts*: the class `v = 0` absorbs the fraction `(ℓ-1)/ℓ` of the sample, and the ties it
creates outweigh the extra classes. -/
theorem ell_limit_strict_anti (l m : ℕ) (hl : 2 ≤ l) (hlm : l < m) :
    ellLimit m < ellLimit l := by
  have hL : (2 : ℚ) ≤ (l : ℚ) := by exact_mod_cast hl
  have hM : (l : ℚ) < (m : ℚ) := by exact_mod_cast hlm
  unfold ellLimit
  have hql : (0 : ℚ) < (l : ℚ) ^ 2 + (l : ℚ) + 1 := by nlinarith
  have hqm : (0 : ℚ) < (m : ℚ) ^ 2 + (m : ℚ) + 1 := by nlinarith
  rw [div_lt_div_iff₀ hqm hql]
  nlinarith [mul_pos (by linarith : (0 : ℚ) < (m : ℚ) - (l : ℚ))
    (by nlinarith : (0 : ℚ) < (l : ℚ) * (m : ℚ) - 1)]

/-- The ceiling always dominates its modulus-only limit. -/
lemma ellLimit_le_ceiling (l b : ℕ) (hl : 2 ≤ l) (hb : 1 ≤ b) :
    ellLimit l ≤ spearmanSq (ellBlocks l b) := by
  have hL : (2 : ℚ) ≤ (l : ℚ) := by exact_mod_cast hl
  have hx : (2 : ℚ) ≤ (l : ℚ) ^ b := by
    calc (2 : ℚ) = (2 : ℚ) ^ 1 := (pow_one 2).symm
      _ ≤ (l : ℚ) ^ 1 := by apply pow_le_pow_left₀ (by norm_num) hL
      _ ≤ (l : ℚ) ^ b := by apply pow_le_pow_right₀ (by linarith) hb
  rw [ell_spearmanSq l b hl hb, ellLimit]
  set x : ℚ := (l : ℚ) ^ b with hxdef
  set L : ℚ := (l : ℚ) with hLdef
  have hquad : (0 : ℚ) < L ^ 2 + L + 1 := by nlinarith
  have hlim0 : (0 : ℚ) ≤ 3 * L / (L ^ 2 + L + 1) := by positivity
  have hpos : (0 : ℚ) ≤ 1 / (x * (x + 1)) := by positivity
  nlinarith

/-- **Payload: the recorded dial bounds the sampling modulus.**  At modulus `ℓ ≥ 5` the
whole ceiling is at most `1/2`, so the recorded `0.7192` (i.e. `ρ² = 0.51724…`) is
unattainable — at every bitlen.  The measurement therefore certifies `ℓ ≤ 4`. -/
theorem recorded_dial_forces_small_modulus (l b : ℕ) (hl : 5 ≤ l) (hb : 1 ≤ b) :
    spearmanSq (ellBlocks l b) < t48A ^ 2 := by
  have hl2 : 2 ≤ l := by omega
  have hL : (5 : ℚ) ≤ (l : ℚ) := by exact_mod_cast hl
  have hx : (5 : ℚ) ≤ (l : ℚ) ^ b := by
    calc (5 : ℚ) = (5 : ℚ) ^ 1 := (pow_one 5).symm
      _ ≤ (l : ℚ) ^ 1 := by apply pow_le_pow_left₀ (by norm_num) hL
      _ ≤ (l : ℚ) ^ b := by apply pow_le_pow_right₀ (by linarith) hb
  rw [ell_spearmanSq l b hl2 hb, ellLimit]
  set x : ℚ := (l : ℚ) ^ b with hxdef
  set L : ℚ := (l : ℚ) with hLdef
  have hquad : (0 : ℚ) < L ^ 2 + L + 1 := by nlinarith
  have hlim : 3 * L / (L ^ 2 + L + 1) ≤ 15 / 31 := by
    rw [div_le_div_iff₀ hquad (by norm_num)]
    nlinarith [sq_nonneg (L - 5)]
  have hlim0 : (0 : ℚ) ≤ 3 * L / (L ^ 2 + L + 1) := by positivity
  have hfrac : 1 / (x * (x + 1)) ≤ 1 / 30 := by
    apply one_div_le_one_div_of_le (by norm_num)
    nlinarith
  have hfrac0 : (0 : ℚ) ≤ 1 / (x * (x + 1)) := by positivity
  have hbound : 3 * L / (L ^ 2 + L + 1) * (1 + 1 / (x * (x + 1))) ≤ 1 / 2 := by
    nlinarith
  have hdial : (1 : ℚ) / 2 < t48A ^ 2 := by norm_num [t48A]
  linarith

/-- The exclusion is sharp: moduli `2`, `3` and `4` all clear the recorded dial. -/
theorem moduli_two_three_four_admissible (b : ℕ) (hb : 1 ≤ b) :
    t48A ^ 2 < spearmanSq (ellBlocks 2 b) ∧
    t48A ^ 2 < spearmanSq (ellBlocks 3 b) ∧
    t48A ^ 2 < spearmanSq (ellBlocks 4 b) := by
  refine ⟨?_, ?_, ?_⟩
  · have h := ellLimit_le_ceiling 2 b (by norm_num) hb
    have hval : ellLimit 2 = 6 / 7 := by norm_num [ellLimit]
    have hd : t48A ^ 2 < (6 : ℚ) / 7 := by norm_num [t48A]
    linarith [hval ▸ h]
  · have h := ellLimit_le_ceiling 3 b (by norm_num) hb
    have hval : ellLimit 3 = 9 / 13 := by norm_num [ellLimit]
    have hd : t48A ^ 2 < (9 : ℚ) / 13 := by norm_num [t48A]
    linarith [hval ▸ h]
  · have h := ellLimit_le_ceiling 4 b (by norm_num) hb
    have hval : ellLimit 4 = 4 / 7 := by norm_num [ellLimit]
    have hd : t48A ^ 2 < (4 : ℚ) / 7 := by norm_num [t48A]
    linarith [hval ▸ h]

/-- **The two axes contrasted.**  Moving the bitlen from 48 to 52 moves every ceiling of
the ladder by less than `10^{-40}`; moving the modulus from `2` to `3` moves the ceiling by
more than `0.16`.  Bitlen is a nuisance parameter of the dial; the modulus is not. -/
theorem modulus_axis_is_live :
    (∀ t : ℕ, 1 ≤ t → t ≤ 47 → |bulkCeil 47 t - bulkCeil 51 t| ≤ 1 / 10 ^ 40) ∧
    16 / 100 < ellLimit 2 - ellLimit 3 := by
  refine ⟨fun t ht1 ht => (ladder_48_52_indistinguishable t ht1 ht).2.2, ?_⟩
  norm_num [ellLimit]

/-! ## 6. Arithmetic bridge: `ellBlocks` really is the `ℓ`-adic valuation profile

Everything above treats `ellBlocks` as a formal list.  This section proves that it is the
genuine tie profile of the `ℓ`-adic valuation on `{0, …, ℓ^b - 1}`, generalising the
catalog's `card_two_adic_block` / `dyadicBlocks_eq_valuation_profile` from `ℓ = 2`. -/

/-- The `k`-th `ℓ`-adic valuation class inside `{0, …, ℓ^b - 1}`. -/
def ellAdicBlock (l b k : ℕ) : Finset ℕ :=
  (Finset.range (l ^ b)).filter fun x => l ^ k ∣ x ∧ ¬ l ^ (k + 1) ∣ x

/-- **Class cardinality at modulus `ℓ`.**  Exactly `(ℓ-1)·ℓ^{b-1-k}` of the integers below
`ℓ^b` have `ℓ`-adic valuation exactly `k`. -/
theorem card_ell_adic_block (l b k : ℕ) (hl : 2 ≤ l) (hk : k < b) :
    (ellAdicBlock l b k).card = (l - 1) * l ^ (b - 1 - k) := by
  have hlpos : 0 < l := by omega
  have hpk : 0 < l ^ k := pow_pos hlpos k
  have himg : ellAdicBlock l b k
      = ((Finset.range (l ^ (b - 1 - k))) ×ˢ (Finset.Ico 1 l)).image
          (fun p => l ^ k * (l * p.1 + p.2)) := by
    ext x
    simp only [ellAdicBlock, Finset.mem_filter, Finset.mem_range, Finset.mem_image,
      Finset.mem_product, Finset.mem_Ico, Prod.exists]
    constructor
    · rintro ⟨hx, ⟨u, rfl⟩, hnd⟩
      have hu : ¬ l ∣ u := by
        rintro ⟨v, rfl⟩
        exact hnd ⟨v, by rw [pow_succ]; ring⟩
      have hr : 1 ≤ u % l := by
        rcases Nat.eq_zero_or_pos (u % l) with h | h
        · exact absurd (Nat.dvd_of_mod_eq_zero h) hu
        · exact h
      have hrl : u % l < l := Nat.mod_lt _ hlpos
      have hb : b = k + 1 + (b - 1 - k) := by omega
      have hxlt : u < l ^ (b - k) := by
        have hbk : b = k + (b - k) := by omega
        rw [hbk, pow_add] at hx
        exact lt_of_mul_lt_mul_left hx (Nat.zero_le _)
      have hq : u / l < l ^ (b - 1 - k) := by
        have hpow : l ^ (b - k) = l * l ^ (b - 1 - k) := by
          rw [← pow_succ']
          congr 1
          omega
        rw [hpow] at hxlt
        exact Nat.div_lt_of_lt_mul (by linarith [hxlt])
      exact ⟨u / l, u % l, ⟨hq, hr, hrl⟩, by rw [Nat.div_add_mod u l]⟩
    · rintro ⟨q, r, ⟨hq, hr1, hrl⟩, rfl⟩
      refine ⟨?_, ⟨l * q + r, rfl⟩, ?_⟩
      · have hb : b = k + 1 + (b - 1 - k) := by omega
        have hlt : l * q + r < l * l ^ (b - 1 - k) := by
          have : q + 1 ≤ l ^ (b - 1 - k) := hq
          nlinarith
        calc l ^ k * (l * q + r) < l ^ k * (l * l ^ (b - 1 - k)) :=
              mul_lt_mul_of_pos_left hlt hpk
          _ = l ^ b := by
              rw [← pow_succ', ← pow_add]
              congr 1
              omega
      · rintro ⟨v, hv⟩
        rw [pow_succ] at hv
        have hv' : l ^ k * (l * q + r) = l ^ k * (l * v) := by rw [hv]; ring
        have heq : l * q + r = l * v := Nat.eq_of_mul_eq_mul_left hpk hv'
        have hqv : q < v := by
          by_contra hcon
          push_neg at hcon
          have hle : l * v ≤ l * q := Nat.mul_le_mul (le_refl l) hcon
          linarith
        have hstep : l * (q + 1) ≤ l * v := Nat.mul_le_mul (le_refl l) hqv
        have hring : l * (q + 1) = l * q + l := by ring
        linarith
  have hinj : Set.InjOn (fun p : ℕ × ℕ => l ^ k * (l * p.1 + p.2))
      ((Finset.range (l ^ (b - 1 - k))) ×ˢ (Finset.Ico 1 l) : Finset (ℕ × ℕ)) := by
    rintro ⟨q, r⟩ hp ⟨q', r'⟩ hp' hEq
    simp only [Finset.coe_product, Set.mem_prod, Finset.mem_coe, Finset.mem_Ico] at hp hp'
    simp only at hEq
    have hsum : l * q + r = l * q' + r' := Nat.eq_of_mul_eq_mul_left hpk hEq
    have hr : r < l := hp.2.2
    have hr' : r' < l := hp'.2.2
    have hqq : q = q' := by
      rcases lt_trichotomy q q' with h | h | h
      · have hstep : l * (q + 1) ≤ l * q' := Nat.mul_le_mul (le_refl l) h
        have hring : l * (q + 1) = l * q + l := by ring
        linarith
      · exact h
      · have hstep : l * (q' + 1) ≤ l * q := Nat.mul_le_mul (le_refl l) h
        have hring : l * (q' + 1) = l * q' + l := by ring
        linarith
    have hmod : r = r' := by
      rw [hqq] at hsum
      linarith
    simp [hqq, hmod]
  rw [himg, Finset.card_image_of_injOn hinj, Finset.card_product, Finset.card_range,
    Nat.card_Ico]
  exact Nat.mul_comm _ _

/-- The `ℓ`-adic profile is literally the list of valuation-class sizes, capped by the
singleton class `{0}`. -/
theorem ellBlocks_eq_valuation_profile (l b : ℕ) (hl : 2 ≤ l) :
    ellBlocks l b = ((List.range b).map fun k => (ellAdicBlock l b k).card) ++ [1] := by
  have hcard : ∀ k ∈ List.range b, (ellAdicBlock l b k).card = (l - 1) * l ^ (b - 1 - k) := by
    intro k hk
    exact card_ell_adic_block l b k hl (List.mem_range.1 hk)
  rw [List.map_congr_left hcard]
  clear hcard
  induction b with
  | zero => simp [ellBlocks]
  | succ n ih =>
      rw [ellBlocks, List.range_succ_eq_map, List.map_cons, List.map_map, List.cons_append]
      simp only [Nat.succ_sub_one, Nat.sub_zero]
      congr 1
      have hfun : ((fun a => (l - 1) * l ^ (n - a)) ∘ Nat.succ)
          = (fun k : ℕ => (l - 1) * l ^ (n - 1 - k)) := by
        funext k
        simp only [Function.comp_apply]
        congr 2
        omega
      rw [hfun]
      exact ih

/-- The `ℓ`-adic classes together with `{0}` exhaust `{0, …, ℓ^b - 1}`. -/
theorem ell_adic_profile_sum (l b : ℕ) (hl : 2 ≤ l) :
    (((List.range b).map fun k => (ellAdicBlock l b k).card) ++ [1]).sum = l ^ b := by
  rw [← ellBlocks_eq_valuation_profile l b hl]
  exact ellBlocks_sum l b (by omega)

end Catalog.Pythagorean.ZeroFitDialEllAdicCeiling
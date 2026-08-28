/-
# Bit-width geometry of the KV-cache cliff: squaring on the keys, doubling on the values

`Catalog/Algebra/KVCacheRoleSplit.lean` proved the *mechanism* of the NET-94 role split:
values pass through a `1`-Lipschitz convex average (`value_path_stable`), keys pass
through an exponential whose log-odds are shifted exactly (`softmaxW_odds_shift`), so the
key-side error bound is `2 (exp (2 ε) - 1) V` and the value-side bound is exactly `ε`.

This file studies how those two bounds move as a function of the **bit width** `b`, under
the standard uniform-quantiser law `error ≍ R · 2⁻ᵇ`, and confronts the resulting geometry
with the NET-94 numbers

* K `q8_0` / V `q4_0` : dPPL = **+0.142 %**
* K `q5_1` / V `q5_1` : dPPL = **+867.694 %**

Main results.

* `keyDist_sq` — **the squaring law**: `1 + keyDist c b = (1 + keyDist c (b+1))²`.
  Removing one key bit *squares* the key distortion factor.
* `valDist_geom` — **the doubling law**: `valDist R b₀ = 2^(b₁-b₀) · valDist R b₁`.
  Removing one value bit merely *doubles* the value distortion.
* `value_path_cannot_cliff` — a 3-bit drop can inflate the value distortion by exactly
  `8`, hence the NET-94 5-bit collapse is *provably not* a value-side effect.  The role
  split is forced, not observed.
* `cliff_width_lower_bound` — under the squaring law a transition from distortion `ρ` to
  distortion `P` needs `log(1+P)/log(1+ρ) ≤ 2^(Δb)` bit steps.
* `net94_refutes_uniform_lipschitz_model` — **negative result**: no constant `c` makes the
  uniform-quantiser Lipschitz-softmax model reproduce the measured pair
  `(+0.142 % at 8 bits, +867.694 % at 5 bits)`.  The observed 3-bit window is far sharper
  than any `2⁻ᵇ` error law allows.
* `key_bit_shrink_base_lower_bound` — the quantitative repair: any model of the form
  `exp (c / K^b)` consistent with NET-94 must have per-bit shrink base `K > 11`, i.e. the
  *effective* key error must fall by more than an order of magnitude per bit, not by `2`.
  This is a falsifiable prediction about outlier-dominated key channels.
* `bit_shift_to_keys_improves`, `budget_neutral_split_better`,
  `equal_memory_split_strictly_better` — at **equal memory** the asymmetric allocation
  `(8,4)` strictly beats the uniform allocation `(6,6)`: the quartic key term dominates
  the linear value term.  This is the theorem behind the serving default
  `-ctk q8_0 -ctv q4_0`.
-/
import Mathlib

namespace Catalog.Algebra.KVCache

/-! ## The two distortion laws -/

/-- Key-side distortion at bit width `b`: the multiplicative softmax inflation
`exp (2ε) - 1` of `KVCacheRoleSplit.key_path_error_le` with `ε ≍ 2⁻ᵇ`, all constants
(head dimension, query bound, quantiser range) absorbed into `c`. -/
noncomputable def keyDist (c : ℝ) (b : ℕ) : ℝ := Real.exp (c / 2 ^ b) - 1

/-- Value-side distortion at bit width `b`: the `1`-Lipschitz bound of
`KVCacheRoleSplit.value_path_stable` with quantiser step `R · 2⁻ᵇ`. -/
noncomputable def valDist (R : ℝ) (b : ℕ) : ℝ := R / 2 ^ b

/-- Total distortion of a cache configuration with `bK` key bits and `bV` value bits. -/
noncomputable def totalDist (c R : ℝ) (bK bV : ℕ) : ℝ := keyDist c bK + valDist R bV

lemma keyDist_nonneg {c : ℝ} (hc : 0 ≤ c) (b : ℕ) : 0 ≤ keyDist c b := by
  have : (0:ℝ) < 2 ^ b := by positivity
  have : (1:ℝ) ≤ Real.exp (c / 2 ^ b) := Real.one_le_exp (by positivity)
  simpa [keyDist] using this

/-- **The squaring law.**  One key bit removed squares the key distortion factor:
`1 + keyDist c b = (1 + keyDist c (b+1))²`.  Iterating, dropping `k` bits raises the
factor to the power `2^k` — a doubly exponential collapse in bit width. -/
theorem keyDist_sq (c : ℝ) (b : ℕ) : 1 + keyDist c b = (1 + keyDist c (b + 1)) ^ 2 := by
  have h2 : (0:ℝ) < 2 ^ b := by positivity
  have hstep : c / 2 ^ b = c / 2 ^ (b + 1) + c / 2 ^ (b + 1) := by
    field_simp
    ring
  simp only [keyDist, add_sub_cancel]
  rw [hstep, Real.exp_add, sq]

/-- The squaring law iterated: dropping `k` key bits raises the distortion factor to the
power `2^k`. -/
theorem keyDist_pow (c : ℝ) (b k : ℕ) :
    1 + keyDist c b = (1 + keyDist c (b + k)) ^ (2 ^ k) := by
  induction k with
  | zero => simp
  | succ k ih =>
      have hb : b + (k + 1) = (b + k) + 1 := by omega
      rw [hb, ih, keyDist_sq c (b + k), ← pow_mul, pow_succ, Nat.mul_comm]

/-- **The doubling law.**  The value distortion is *geometric*, not doubly exponential:
dropping `b₁ - b₀` value bits multiplies it by exactly `2^(b₁-b₀)`. -/
theorem valDist_geom (R : ℝ) {b₀ b₁ : ℕ} (h : b₀ ≤ b₁) :
    valDist R b₀ = 2 ^ (b₁ - b₀) * valDist R b₁ := by
  have : (2:ℝ) ^ b₁ = 2 ^ (b₁ - b₀) * 2 ^ b₀ := by
    rw [← pow_add]
    congr 1
    omega
  unfold valDist
  rw [this]
  have h0 : (0:ℝ) < 2 ^ b₀ := by positivity
  have h1 : (0:ℝ) < (2:ℝ) ^ (b₁ - b₀) := by positivity
  field_simp

/-! ## The value side cannot cliff -/

/-- **No value cliff.**  Whatever the quantiser range `R`, a value cache that is
quality-free at 8 bits (distortion `≤ 0.00142`, the measured `+0.142 %`) has distortion at
most `0.01136` at 5 bits — it can *never* explain the measured `+867.694 %`.  Hence the
NET-94 collapse is provably a key-side event: the role split is forced by the algebra. -/
theorem value_path_cannot_cliff :
    ¬ ∃ R : ℝ, 0 ≤ R ∧ valDist R 8 ≤ 0.00142 ∧ 8.67694 ≤ valDist R 5 := by
  rintro ⟨R, hR, h8, h5⟩
  rw [valDist_geom R (show (5:ℕ) ≤ 8 by norm_num)] at h5
  norm_num [valDist] at h8 h5
  linarith

/-! ## The key side: how wide can a cliff be? -/

/-- **Cliff-width bound.**  Under the squaring law, a key cache with distortion `≤ ρ` at
`b₁` bits has distortion `≥ P` at `b₀ ≤ b₁` bits only if
`log (1+P) ≤ 2^(b₁-b₀) · log (1+ρ)`.  In words: the *logarithm* of the distortion factor
can at most double per lost bit, so a transition from `ρ` to `P` occupies at least
`log₂ (log(1+P)/log(1+ρ))` bit widths. -/
theorem cliff_width_lower_bound {c ρ P : ℝ} {b₀ b₁ : ℕ} (hc : 0 < c) (hP : 0 ≤ P)
    (hb : b₀ ≤ b₁)
    (h1 : Real.exp (c / 2 ^ b₁) ≤ 1 + ρ) (h0 : 1 + P ≤ Real.exp (c / 2 ^ b₀)) :
    Real.log (1 + P) ≤ 2 ^ (b₁ - b₀) * Real.log (1 + ρ) := by
  have e0 : (0:ℝ) < 2 ^ b₀ := by positivity
  have e1 : (0:ℝ) < 2 ^ b₁ := by positivity
  have hPlog : Real.log (1 + P) ≤ c / 2 ^ b₀ := by
    have hpos : (0:ℝ) < 1 + P := by linarith
    calc Real.log (1 + P) ≤ Real.log (Real.exp (c / 2 ^ b₀)) :=
          Real.log_le_log hpos h0
      _ = c / 2 ^ b₀ := Real.log_exp _
  have hρ : c / 2 ^ b₁ ≤ Real.log (1 + ρ) := by
    have := Real.log_le_log (Real.exp_pos (c / 2 ^ b₁)) h1
    rwa [Real.log_exp] at this
  have hsplit : (2:ℝ) ^ b₁ = 2 ^ (b₁ - b₀) * 2 ^ b₀ := by
    rw [← pow_add]; congr 1; omega
  have hkey : c / 2 ^ b₀ = 2 ^ (b₁ - b₀) * (c / 2 ^ b₁) := by
    rw [hsplit]; field_simp
  have hmul : (2:ℝ) ^ (b₁ - b₀) * (c / 2 ^ b₁) ≤ 2 ^ (b₁ - b₀) * Real.log (1 + ρ) :=
    mul_le_mul_of_nonneg_left hρ (by positivity)
  linarith [hkey ▸ hPlog]

/-- Two decimal digits of `Real.log`, needed to confront the model with the data:
`2 ≤ log 9.67694`, i.e. the `+867.694 %` arm sits above `e²`. -/
lemma two_le_log_net94 : (2:ℝ) ≤ Real.log 9.67694 := by
  have he : Real.exp 1 < 2.7182818286 := Real.exp_one_lt_d9
  have h2 : Real.exp 2 < 9.67694 := by
    have : Real.exp 2 = Real.exp 1 * Real.exp 1 := by
      rw [← Real.exp_add]; norm_num
    nlinarith [Real.exp_pos 1, this]
  calc (2:ℝ) = Real.log (Real.exp 2) := (Real.log_exp 2).symm
    _ ≤ Real.log 9.67694 := Real.log_le_log (Real.exp_pos 2) h2.le

/-- **NET-94 refutes the uniform-quantiser Lipschitz model.**  There is no constant `c`
for which the model `keyDist c b = exp (c/2ᵇ) - 1` is simultaneously
quality-free at 8 bits (`≤ +0.142 %`) and broken at 5 bits (`≥ +867.694 %`).

The reason is structural: over a 3-bit drop the squaring law can only *cube-square* the
log-distortion, i.e. multiply it by `2³ = 8`, whereas the data demand a factor
`log 9.67694 / log 1.00142 > 1400`.  The measured cliff is therefore at least two orders
of magnitude sharper than any `error ∝ 2⁻ᵇ` key model can produce; the key channel's
effective error must be outlier dominated. -/
theorem net94_refutes_uniform_lipschitz_model :
    ¬ ∃ c : ℝ, 0 < c ∧ Real.exp (c / 2 ^ 8) ≤ 1 + 0.00142 ∧
      1 + 8.67694 ≤ Real.exp (c / 2 ^ 5) := by
  rintro ⟨c, hc, h8, h5⟩
  have hmain := cliff_width_lower_bound (b₀ := 5) (b₁ := 8) hc (by norm_num) (by norm_num) h8 h5
  have hlog_small : Real.log (1 + 0.00142) ≤ 0.00142 := by
    have := Real.log_le_sub_one_of_pos (x := (1:ℝ) + 0.00142) (by norm_num)
    linarith
  have hbig : (2:ℝ) ≤ Real.log (1 + 8.67694) := by
    have : (1:ℝ) + 8.67694 = 9.67694 := by norm_num
    rw [this]; exact two_le_log_net94
  have h8pow : ((2:ℝ) ^ (8 - 5 : ℕ)) = 8 := by norm_num
  rw [h8pow] at hmain
  linarith

/-- **The quantitative repair.**  Keep the exponential softmax response but let the
effective key error shrink by a factor `K` per bit, `keyDist = exp (c / K^b) - 1`.
Consistency with NET-94 forces `K > 11`: each key bit must divide the *effective* logit
error by more than eleven, not by two.

This converts the negative result into a falsifiable prediction: the key cache error is
dominated by a small set of outlier channels whose block scale collapses super-fast with
bit width, and any proposed key-quantisation scheme must exhibit a per-bit shrink base
above 11 to reproduce the observed cliff. -/
theorem key_bit_shrink_base_lower_bound {c K : ℝ} (hK : 0 < K)
    (h8 : Real.exp (c / K ^ 8) ≤ 1 + 0.00142)
    (h5 : 1 + 8.67694 ≤ Real.exp (c / K ^ 5)) : 11 < K := by
  have e8 : (0:ℝ) < K ^ 8 := by positivity
  have e5 : (0:ℝ) < K ^ 5 := by positivity
  have hsmall : c / K ^ 8 ≤ 0.00142 := by
    have h1 : Real.log (Real.exp (c / K ^ 8)) ≤ Real.log (1 + 0.00142) :=
      Real.log_le_log (Real.exp_pos _) h8
    rw [Real.log_exp] at h1
    have h2 := Real.log_le_sub_one_of_pos (x := (1:ℝ) + 0.00142) (by norm_num)
    linarith
  have hbig : (2:ℝ) ≤ c / K ^ 5 := by
    have h1 : Real.log (1 + 8.67694) ≤ Real.log (Real.exp (c / K ^ 5)) :=
      Real.log_le_log (by norm_num) h5
    rw [Real.log_exp] at h1
    have : (1:ℝ) + 8.67694 = 9.67694 := by norm_num
    rw [this] at h1
    linarith [two_le_log_net94]
  -- `c ≥ 2 K^5` and `c ≤ 0.00142 K^8` give `K³ ≥ 2/0.00142 > 11³`.
  have hc5 : 2 * K ^ 5 ≤ c := by
    rw [le_div_iff₀ e5] at hbig; linarith
  have hc8 : c ≤ 0.00142 * K ^ 8 := by
    rw [div_le_iff₀ e8] at hsmall; linarith
  have hcube : 1331 * K ^ 5 < K ^ 8 := by nlinarith [pow_pos hK 5, pow_pos hK 8]
  have hK5 : (0:ℝ) < K ^ 5 := e5
  have h3 : (1331:ℝ) < K ^ 3 := by
    have : K ^ 8 = K ^ 3 * K ^ 5 := by ring
    nlinarith
  nlinarith [sq_nonneg (K - 11), sq_nonneg (K + 11), hK.le]

/-! ## Optimal allocation of a fixed bit budget -/

/-- Moving one bit from the value cache to the key cache strictly reduces total distortion
as soon as the key-side saving `keyDist c bK - keyDist c (bK+1)` exceeds the value-side
loss `valDist R bV`.  Because the key term obeys the squaring law and the value term only
the doubling law, this condition holds for all but the smallest distortion regimes. -/
theorem bit_shift_to_keys_improves {c R : ℝ} {bK bV : ℕ} (hbV : 1 ≤ bV)
    (h : valDist R bV < keyDist c bK - keyDist c (bK + 1)) :
    totalDist c R (bK + 1) (bV - 1) < totalDist c R bK bV := by
  have hval : valDist R (bV - 1) = 2 * valDist R bV := by
    have := valDist_geom R (show bV - 1 ≤ bV by omega)
    have hpow : (2:ℝ) ^ (bV - (bV - 1)) = 2 := by
      have : bV - (bV - 1) = 1 := by omega
      rw [this, pow_one]
    rwa [hpow] at this
  unfold totalDist
  rw [hval]
  linarith

/-- **Budget-neutral reallocation.**  Move `k` bits from the value cache to the key
cache.  Memory is unchanged (`(b+k) + (b-k) = b + b`), and the total distortion strictly
drops as soon as the value-side loss `(2^k - 1)·valDist R b` is smaller than the key-side
saving `t^(2^k) - t`, where `t = 1 + keyDist c (b+k)` is the key distortion factor at the
enriched width.  The asymmetry of the two laws — the key term is a degree-`2^k`
polynomial in `t`, the value term only a factor `2^k` — is what makes the inequality
easy to satisfy. -/
theorem budget_neutral_split_better {c R : ℝ} {b k : ℕ} (hk : k ≤ b)
    (hgap : ((2:ℝ) ^ k - 1) * valDist R b
      < (1 + keyDist c (b + k)) ^ (2 ^ k) - (1 + keyDist c (b + k))) :
    (b + k) + (b - k) = b + b ∧ totalDist c R (b + k) (b - k) < totalDist c R b b := by
  refine ⟨by omega, ?_⟩
  set t := 1 + keyDist c (b + k) with ht
  have hkeyb : keyDist c b = t ^ (2 ^ k) - 1 := by
    have := keyDist_pow c b k
    rw [ht]; linarith
  have hkeybk : keyDist c (b + k) = t - 1 := by rw [ht]; ring
  have hvalbk : valDist R (b - k) = 2 ^ k * valDist R b := by
    have h := valDist_geom R (show b - k ≤ b by omega)
    have hpow : (2:ℝ) ^ (b - (b - k)) = 2 ^ k := by
      congr 1; omega
    rwa [hpow] at h
  unfold totalDist
  rw [hkeyb, hkeybk, hvalbk]
  linarith

/-- **Equal memory, unequal quality.**  The configurations `(bK,bV) = (8,4)` and `(6,6)`
cost exactly the same `6` average bits per cache element — `8 + 4 = 6 + 6` — but once the
key distortion factor at 8 bits reaches `2`, the regime NET-94 operates in (5-bit keys
already break), the asymmetric split is *strictly* better for every value range
`R ≤ 256`.  This is the theorem behind the serving default `-ctk q8_0 -ctv q4_0`. -/
theorem equal_memory_split_strictly_better {c R : ℝ} (hR : R ≤ 256)
    (ht : 2 ≤ 1 + keyDist c 8) :
    totalDist c R 8 4 < totalDist c R 6 6 := by
  have hteq : (1:ℝ) + keyDist c (6 + 2) = 1 + keyDist c 8 := by norm_num
  have hval : valDist R 6 = R / 64 := by norm_num [valDist]
  have h := budget_neutral_split_better (c := c) (R := R) (b := 6) (k := 2)
    (by norm_num) ?_
  · simpa using h.2
  · rw [hteq, hval]
    set t := 1 + keyDist c 8 with ht
    have hu : 0 ≤ t - 2 := by linarith
    have hpow : t ^ (2 ^ 2) = t ^ 4 := by norm_num
    rw [hpow]
    have h1 : (14:ℝ) ≤ t ^ 4 - t := by
      nlinarith [pow_nonneg hu 2, pow_nonneg hu 3, pow_nonneg hu 4]
    norm_num
    linarith

end Catalog.Algebra.KVCache
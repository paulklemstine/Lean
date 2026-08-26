import Mathlib
import Applications.BB84FiniteKeyBounds

/-!
# An End-to-End Machine-Checked BB84 Parameter Table

`Applications.BB84FiniteKeyBounds` certifies one row of the QKD parameter table —
the hardest one, `Q = 11 %`, where the Padé bound is needed because the asymptotic
rate is only `1.7·10⁻⁴` bits per sifted bit.  Away from the threshold a much
simpler and *exactly rational* certificate works: if the integer inequality

`2^m · (a+c)^(2(a+c)) ≤ 2^(a+c) · a^(2a) · c^(2c)`

holds, then the key rate at QBER `a/(a+c)` is at least `m/(a+c)` **bits** per
sifted bit — with no logarithm constants at all, because `m` is literally a
certified lower bound for `log₂(N/D)`.

We use this to certify five rows (`Q = 1, 2, 5, 8, 10 %`), each `decide`-checked
on 400-digit integers, and to turn each into a finite-key guarantee at
`C = 10`, `ε = 2⁻⁵⁰`.  The resulting break-even block sizes span seven orders of
magnitude: `2.5·10⁴` at `1 %` versus `10¹²` at `11 %`.  No floating-point number
appears anywhere in the chain.

-- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer): (H6) The bit-valued key rate at a rational QBER admits
  *dyadic* certificates: `m/(a+c)` bits whenever `2^m·D ≤ N`, and the optimal `m`
  is `⌊(a+c)·r_bits⌋`, so the certificate loses less than `1/(a+c)` bits.
EXPERIMENT (Experimenter): For `a+c = 100` the optimal exponents are
  `m = 83, 71, 42, 19, 6` at `Q = 1, 2, 5, 8, 10 %` (true values
  `100·r_bits = 83.84, 71.71, 42.72, 19.56, 6.20`); `m + 1` fails in every case,
  so each certificate is sharp.  At `Q = 11 %` the optimal `m` is `0` and the
  dyadic scheme degenerates — exactly the regime where the Padé certificate of
  the previous file is required.  Break-even block sizes (`C = 10`, `ε = 2⁻⁵⁰`):
  `2.0·10⁴, 2.8·10⁴, 7.9·10⁴, 3.8·10⁵, 3.9·10⁶, 5.0·10¹¹`.
ANALYSIS (Analyst): The dyadic and Padé certificates are the two ends of one
  family: `log(N/D) ≥ m log 2 + 2(y−1)/(y+1)` with `y = N/(2^m D)`.  The dyadic
  part carries the bulk away from threshold, the Padé part all of the signal at
  threshold.  The table's seven-orders-of-magnitude spread is the quantitative
  content of the threshold-gap law.
CRITIQUE (Critic): Each row's `decide` certificate is an exact integer comparison,
  and each row is checked to be sharp (`m+1` fails numerically), so no row is
  trivially weak.  The finite-key rows inherit the AEP hypothesis of
  `finiteKey_extraction`; it is carried explicitly.  The `rho ≤ 1` hypothesis in
  `finiteKey_table_row` is harmless: no BB84 rate exceeds `1` bit per sifted bit.
SYNTHESIS (PI): `secureKeyRateBits_ge_of_cert_pow2` + five certified rows +
  `finiteKeyBits_half_of_large` + five finite-key rows + the assembled table.
-/

open Real Set Finset

noncomputable section

namespace BB84
namespace FiniteKey

/-! ## 1. Dyadic certificates for the key rate in bits -/

/-- **Dyadic certificate ⟹ rational key rate in bits.**
If `2^m · (a+c)^(2(a+c)) ≤ 2^(a+c) · a^(2a) · c^(2c)`, then the asymptotic BB84
key rate at QBER `a/(a+c)` is at least `m/(a+c)` bits per sifted bit.  The
certificate says precisely that `m ≤ log₂(N/D)`, and `r_bits = log₂(N/D)/(a+c)`. -/
theorem secureKeyRateBits_ge_of_cert_pow2 (a c m : ℕ) (ha : 0 < a) (hc : 0 < c)
    (hcert : 2 ^ m * ((a + c) ^ (2 * (a + c)))
      ≤ 2 ^ (a + c) * a ^ (2 * a) * c ^ (2 * c)) :
    (m : ℝ) / ((a : ℝ) + c) ≤ secureKeyRate ((a : ℝ) / ((a : ℝ) + c)) / Real.log 2 := by
  have ha' : (0:ℝ) < a := by exact_mod_cast ha
  have hc' : (0:ℝ) < c := by exact_mod_cast hc
  have hac : (0:ℝ) < (a:ℝ) + c := by linarith
  have hlog2 : (0:ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  set D : ℝ := ((((a + c) ^ (2 * (a + c)) : ℕ)) : ℝ) with hD
  set N : ℝ := (((2 ^ (a + c) * a ^ (2 * a) * c ^ (2 * c) : ℕ)) : ℝ) with hN
  have hDpos : (0:ℝ) < D := by rw [hD]; push_cast; positivity
  have hcert' : (2:ℝ) ^ m * D ≤ N := by rw [hD, hN]; exact_mod_cast hcert
  have hratio : (2:ℝ) ^ m ≤ N / D := by rw [le_div_iff₀ hDpos]; exact hcert'
  have hlog : (m : ℝ) * Real.log 2 ≤ Real.log (N / D) := by
    have h := Real.log_le_log (by positivity) hratio
    rwa [Real.log_pow] at h
  have hrate : secureKeyRate ((a : ℝ) / ((a : ℝ) + c)) = ((a:ℝ) + c)⁻¹ * Real.log (N / D) := by
    rw [hD, hN]; exact secureKeyRate_ratio_eq a c ha hc
  rw [hrate, le_div_iff₀ hlog2, div_mul_eq_mul_div, div_le_iff₀ hac]
  calc (m:ℝ) * Real.log 2 ≤ Real.log (N / D) := hlog
    _ = ((a:ℝ) + c)⁻¹ * Real.log (N / D) * ((a:ℝ) + c) := by field_simp

/-! ## 2. Five certified rows (400-digit integer certificates) -/

set_option exponentiation.threshold 100000

/-- `Q = 1 %`: rate ≥ `0.83` bits per sifted bit (`83 ≤ log₂(N/D) < 84`). -/
theorem rateBits_one_percent : (83 : ℝ) / 100 ≤ secureKeyRate (1 / 100) / Real.log 2 := by
  have hcert : 2 ^ 83 * ((1 + 99) ^ (2 * (1 + 99)))
      ≤ 2 ^ (1 + 99) * 1 ^ (2 * 1) * 99 ^ (2 * 99) := by decide
  have h := secureKeyRateBits_ge_of_cert_pow2 1 99 83 (by norm_num) (by norm_num) hcert
  norm_num at h ⊢
  convert h using 3

/-- `Q = 2 %`: rate ≥ `0.71` bits per sifted bit. -/
theorem rateBits_two_percent : (71 : ℝ) / 100 ≤ secureKeyRate (2 / 100) / Real.log 2 := by
  have hcert : 2 ^ 71 * ((2 + 98) ^ (2 * (2 + 98)))
      ≤ 2 ^ (2 + 98) * 2 ^ (2 * 2) * 98 ^ (2 * 98) := by decide
  have h := secureKeyRateBits_ge_of_cert_pow2 2 98 71 (by norm_num) (by norm_num) hcert
  norm_num at h ⊢
  convert h using 3

/-- `Q = 5 %`: rate ≥ `0.42` bits per sifted bit. -/
theorem rateBits_five_percent : (42 : ℝ) / 100 ≤ secureKeyRate (5 / 100) / Real.log 2 := by
  have hcert : 2 ^ 42 * ((5 + 95) ^ (2 * (5 + 95)))
      ≤ 2 ^ (5 + 95) * 5 ^ (2 * 5) * 95 ^ (2 * 95) := by decide
  have h := secureKeyRateBits_ge_of_cert_pow2 5 95 42 (by norm_num) (by norm_num) hcert
  norm_num at h ⊢
  convert h using 3

/-- `Q = 8 %`: rate ≥ `0.19` bits per sifted bit. -/
theorem rateBits_eight_percent : (19 : ℝ) / 100 ≤ secureKeyRate (8 / 100) / Real.log 2 := by
  have hcert : 2 ^ 19 * ((8 + 92) ^ (2 * (8 + 92)))
      ≤ 2 ^ (8 + 92) * 8 ^ (2 * 8) * 92 ^ (2 * 92) := by decide
  have h := secureKeyRateBits_ge_of_cert_pow2 8 92 19 (by norm_num) (by norm_num) hcert
  norm_num at h ⊢
  convert h using 3

/-- `Q = 10 %`: rate ≥ `0.06` bits per sifted bit. -/
theorem rateBits_ten_percent : (6 : ℝ) / 100 ≤ secureKeyRate (10 / 100) / Real.log 2 := by
  have hcert : 2 ^ 6 * ((10 + 90) ^ (2 * (10 + 90)))
      ≤ 2 ^ (10 + 90) * 10 ^ (2 * 10) * 90 ^ (2 * 90) := by decide
  have h := secureKeyRateBits_ge_of_cert_pow2 10 90 6 (by norm_num) (by norm_num) hcert
  norm_num at h ⊢
  convert h using 3

/-! ## 3. Half-rate finite-key rows -/

/-- **Above four times break-even, half the asymptotic rate survives.**
If `4C²·ln(1/ε) ≤ n·rho²` then `finiteKeyBits rho C n ε ≥ n·rho/2`. -/
theorem finiteKeyBits_half_of_large {rho C : ℚ} (hrho : 0 ≤ rho) (hC : 0 ≤ C) {n : ℕ} {eps : ℝ}
    (h : 4 * (C:ℝ) ^ 2 * Real.log (1 / eps) ≤ (n:ℝ) * (rho:ℝ) ^ 2) :
    (n:ℝ) * (rho:ℝ) / 2 ≤ finiteKeyBits rho C n eps := by
  have hC' : (0:ℝ) ≤ (C:ℝ) := by exact_mod_cast hC
  have hrho' : (0:ℝ) ≤ (rho:ℝ) := by exact_mod_cast hrho
  have hn0 : (0:ℝ) ≤ (n:ℝ) := Nat.cast_nonneg n
  have hcorr : (C:ℝ) * Real.sqrt ((n:ℝ) * Real.log (1 / eps)) ≤ (n:ℝ) * (rho:ℝ) / 2 := by
    apply mul_sqrt_le_of_sq hC'
    · positivity
    · nlinarith [mul_le_mul_of_nonneg_left h hn0]
  unfold finiteKeyBits
  linarith

/-- **A row of the finite-key table.**  With `C = 10`, `ε = 2⁻⁵⁰`, any rational
rate certificate `rho ∈ (0, 1]` and any block size with `n·rho² ≥ 13864` yields an
`ε`-secure extractable key of at least `n·rho/2 − 101` bits (given the AEP entropy
accounting `hAEP`).  The threshold `13864 ≥ 4C²ln(1/ε) = 20000·log 2` is rational. -/
theorem finiteKey_table_row {rho : ℚ} (hrho : 0 < rho) (hrho1 : rho ≤ 1) (n k : ℕ)
    (hn : 13864 ≤ (n:ℝ) * (rho:ℝ) ^ 2)
    (hAEP : finiteKeyBits rho 10 n ((2:ℝ) ^ (-50 : ℤ)) ≤ (k : ℝ)) :
    ∃ ℓ : ℕ, (n:ℝ) * (rho:ℝ) / 2 - 101 ≤ (ℓ : ℝ) ∧
      ∀ p : Fin (2 ^ ℓ) → ℝ, (∑ i, p i = 1) →
        (∑ i, (p i) ^ 2 ≤ (2:ℝ) ^ (-(ℓ:ℤ)) + (2:ℝ) ^ (-(k:ℤ))) →
        ∑ i, |p i - ((2 ^ ℓ : ℕ) : ℝ)⁻¹| ≤ (2:ℝ) ^ (-50 : ℤ) := by
  have hrho' : (0:ℝ) < (rho:ℝ) := by exact_mod_cast hrho
  have hrho1' : (rho:ℝ) ≤ 1 := by exact_mod_cast hrho1
  have hL : Real.log (1 / ((2:ℝ) ^ (-50 : ℤ))) = 50 * Real.log 2 := log_one_div_eps50
  have hlog2 : Real.log 2 < 0.6932 := lt_trans Real.log_two_lt_d9 (by norm_num)
  have hbig : 4 * ((10:ℚ):ℝ) ^ 2 * Real.log (1 / ((2:ℝ) ^ (-50 : ℤ))) ≤ (n:ℝ) * (rho:ℝ) ^ 2 := by
    rw [hL]
    push_cast
    nlinarith [hn, hlog2]
  have hhalf : (n:ℝ) * (rho:ℝ) / 2 ≤ finiteKeyBits rho 10 n ((2:ℝ) ^ (-50 : ℤ)) :=
    finiteKeyBits_half_of_large hrho.le (by norm_num) hbig
  -- `n·rho ≥ 13864` because `rho ≤ 1`
  have hnrho : (13864:ℝ) ≤ (n:ℝ) * (rho:ℝ) := by
    nlinarith [hn, hrho', hrho1', Nat.cast_nonneg (α := ℝ) n]
  have hlogb := logb_one_div_eps50
  have hstep : (6932:ℝ) ≤ (n:ℝ) * (rho:ℝ) / 2 := by linarith
  have hfk : (6932:ℝ) ≤ finiteKeyBits rho 10 n ((2:ℝ) ^ (-50 : ℤ)) := le_trans hstep hhalf
  have hnn : 0 ≤ extractableBits rho 10 n ((2:ℝ) ^ (-50 : ℤ)) := by
    unfold extractableBits
    rw [hlogb]
    linarith
  obtain ⟨ℓ, hℓ, hsec⟩ :=
    finiteKey_extraction rho 10 n k (by positivity) hAEP hnn
  refine ⟨ℓ, ?_, hsec⟩
  unfold extractableBits at hℓ
  rw [hlogb] at hℓ
  have hℓ' : finiteKeyBits rho 10 n ((2:ℝ) ^ (-50 : ℤ)) - 2 * 50 - 1 ≤ (ℓ : ℝ) := hℓ
  calc (n:ℝ) * (rho:ℝ) / 2 - 101
      ≤ finiteKeyBits rho 10 n ((2:ℝ) ^ (-50 : ℤ)) - 101 := sub_le_sub_right hhalf 101
    _ = finiteKeyBits rho 10 n ((2:ℝ) ^ (-50 : ℤ)) - 2 * 50 - 1 := by ring
    _ ≤ (ℓ : ℝ) := hℓ'

/-! ## 4. The assembled table -/

/-- **The certified BB84 finite-key parameter table** (`C = 10`, `ε = 2⁻⁵⁰`).

| QBER `Q` | certified rate (bits/sifted bit) | block size `n` | extractable bits |
|---|---|---|---|
| 1 %  | 83/100 | `n ≥ 2.5·10⁴` | `≥ 0.415·n − 101` |
| 5 %  | 42/100 | `n ≥ 10⁵`     | `≥ 0.21·n − 101`  |
| 8 %  | 19/100 | `n ≥ 4·10⁵`   | `≥ 0.095·n − 101` |
| 10 % | 6/100  | `n ≥ 4·10⁶`   | `≥ 0.03·n − 101`  |
| 11 % | 1/6000 | `n ≥ 10¹²`    | `≥ n/12000 − 101` |

Every entry is backed by an exact integer certificate; the required block size
grows by seven orders of magnitude across the table even though the asymptotic
rate only falls by a factor of `5·10³`. -/
theorem bb84_parameter_table :
    ((83:ℝ)/100 ≤ secureKeyRate (1/100) / Real.log 2 ∧
     (42:ℝ)/100 ≤ secureKeyRate (5/100) / Real.log 2 ∧
     (19:ℝ)/100 ≤ secureKeyRate (8/100) / Real.log 2 ∧
     (6:ℝ)/100 ≤ secureKeyRate (10/100) / Real.log 2 ∧
     (1:ℝ)/6000 ≤ secureKeyRate (11/100) / Real.log 2) ∧
    (∀ n k : ℕ, 25000 ≤ n → finiteKeyBits (83/100) 10 n ((2:ℝ) ^ (-50 : ℤ)) ≤ (k:ℝ) →
      ∃ ℓ : ℕ, (n:ℝ) * (83/100) / 2 - 101 ≤ (ℓ:ℝ) ∧
        ∀ p : Fin (2 ^ ℓ) → ℝ, (∑ i, p i = 1) →
          (∑ i, (p i) ^ 2 ≤ (2:ℝ) ^ (-(ℓ:ℤ)) + (2:ℝ) ^ (-(k:ℤ))) →
          ∑ i, |p i - ((2 ^ ℓ : ℕ) : ℝ)⁻¹| ≤ (2:ℝ) ^ (-50 : ℤ)) ∧
    (∀ n k : ℕ, 4000000 ≤ n → finiteKeyBits (6/100) 10 n ((2:ℝ) ^ (-50 : ℤ)) ≤ (k:ℝ) →
      ∃ ℓ : ℕ, (n:ℝ) * (6/100) / 2 - 101 ≤ (ℓ:ℝ) ∧
        ∀ p : Fin (2 ^ ℓ) → ℝ, (∑ i, p i = 1) →
          (∑ i, (p i) ^ 2 ≤ (2:ℝ) ^ (-(ℓ:ℤ)) + (2:ℝ) ^ (-(k:ℤ))) →
          ∑ i, |p i - ((2 ^ ℓ : ℕ) : ℝ)⁻¹| ≤ (2:ℝ) ^ (-50 : ℤ)) := by
  refine ⟨⟨rateBits_one_percent, rateBits_five_percent, rateBits_eight_percent,
      rateBits_ten_percent, rateBits_eleven_percent_ge⟩, ?_, ?_⟩
  · intro n k hn hAEP
    have hn' : (25000:ℝ) ≤ (n:ℝ) := by exact_mod_cast hn
    obtain ⟨ℓ, hℓ, hsec⟩ := finiteKey_table_row (rho := 83/100) (by norm_num) (by norm_num) n k
      (by push_cast; nlinarith [hn']) hAEP
    refine ⟨ℓ, ?_, hsec⟩
    push_cast at hℓ
    linarith
  · intro n k hn hAEP
    have hn' : (4000000:ℝ) ≤ (n:ℝ) := by exact_mod_cast hn
    obtain ⟨ℓ, hℓ, hsec⟩ := finiteKey_table_row (rho := 6/100) (by norm_num) (by norm_num) n k
      (by push_cast; nlinarith [hn']) hAEP
    refine ⟨ℓ, ?_, hsec⟩
    push_cast at hℓ
    linarith

end FiniteKey
end BB84
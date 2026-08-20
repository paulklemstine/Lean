/-
# Consequences of the `q`-analogue of Kummer's theorem

Three structural corollaries of `QKummer.qBinom_padicValNat`:

* `QKummer.padicValNat_qBinom_dilate` — **self-similarity**: on the sublattice of indices that
  are multiples of the period `d`, the `ℓ`-adic valuation of the Gaussian binomial coefficient
  collapses to the *classical* one, `v_ℓ(binom(dN, dA)_q) = v_ℓ(binom(N, A))`;
* `QKummer.dvd_qBinom_iff` — **divisibility criterion**: `ℓ ∣ binom(n,k)_q` exactly when the
  base-`d` addition of `k` and `n-k` carries, or the classical binomial coefficient of the
  base-`d` quotients is divisible by `ℓ`;
* `QKummer.dvd_qBinom_iff_orderOf` — the same criterion for an odd prime `ℓ ∤ q`, where the
  hypothesis on the offset `e` is discharged by `QKummer.one_le_padicValNat_qNat_orderOf`.
-/
import Catalog.NumberTheory.QKummer.Valuation

namespace QKummer

section General

variable {q ℓ d e : ℕ} [hp : Fact ℓ.Prime]

theorem dvd_iff_one_le_padicValNat {a : ℕ} (ha : a ≠ 0) :
    ℓ ∣ a ↔ 1 ≤ padicValNat ℓ a := by
  have h := padicValNat_dvd_iff_le (p := ℓ) (a := a) (n := 1) ha
  rwa [pow_one] at h

/-- **Self-similarity of the `q`-Pascal triangle.**  Along indices divisible by the period `d`
there is no base-`d` carry, and the `q`-Kummer formula degenerates to the classical Kummer
count: `v_ℓ(binom(dN, dA)_q) = v_ℓ(binom(N, A))`. -/
theorem padicValNat_qBinom_dilate (h : IsQRegular q ℓ d e) {N A : ℕ} (hA : A ≤ N) :
    padicValNat ℓ (qBinom q (d * N) (d * A)) = padicValNat ℓ (N.choose A) := by
  have hd := h.pos
  have hsub : d * N - d * A = d * (N - A) := by
    rw [Nat.mul_sub_left_distrib]
  have hN : (d * N) / d = (d * A) / d + (d * N - d * A) / d + 0 := by
    rw [hsub, Nat.mul_div_cancel_left _ hd, Nat.mul_div_cancel_left _ hd,
      Nat.mul_div_cancel_left _ hd]
    omega
  have key := qBinom_padicValNat_of_carry h (Nat.mul_le_mul_left d hA) (Nat.zero_le 1) hN
  rw [Nat.mul_div_cancel_left _ hd, Nat.mul_div_cancel_left _ hd] at key
  simpa using key

/-- **`q`-Legendre formula in digit-sum form.**  Multiplying the `q`-Legendre formula by `ℓ - 1`
and applying the classical Legendre/`digits` identity gives
`(ℓ-1) * v_ℓ([n]_q!) = (ℓ-1) * e * ⌊n/d⌋ + (⌊n/d⌋ - s_ℓ(⌊n/d⌋))`, where `s_ℓ` is the sum of the
base-`ℓ` digits. -/
theorem sub_one_mul_qFact_padicValNat (h : IsQRegular q ℓ d e) (n : ℕ) :
    (ℓ - 1) * padicValNat ℓ (qFact q n)
      = (ℓ - 1) * (e * (n / d)) + ((n / d) - ((Nat.digits ℓ (n / d)).sum)) := by
  rw [qFact_padicValNat h n, Nat.mul_add, sub_one_mul_padicValNat_factorial]

/-- The classical Kummer count is bounded by the base-`ℓ` logarithm. -/
theorem padicValNat_choose_le_log {n k : ℕ} (hkn : k ≤ n) :
    padicValNat ℓ (n.choose k) ≤ Nat.log ℓ n := by
  rw [padicValNat_choose hkn (Nat.lt_succ_self (Nat.log ℓ n))]
  calc ((Finset.Ico 1 (Nat.log ℓ n + 1)).filter
          (fun i => ℓ ^ i ≤ k % ℓ ^ i + (n - k) % ℓ ^ i)).card
      ≤ (Finset.Ico 1 (Nat.log ℓ n + 1)).card := Finset.card_filter_le _ _
    _ = Nat.log ℓ n := by simp

/-- **Logarithmic growth.**  The `ℓ`-adic valuation of a Gaussian binomial coefficient exceeds the
offset `e` by at most a logarithmic amount: it is at most `e + log_ℓ(⌊n/d⌋) + log_ℓ(⌊(n-k)/d⌋+1)`. -/
theorem padicValNat_qBinom_le (h : IsQRegular q ℓ d e) {n k : ℕ} (hk : k ≤ n) :
    padicValNat ℓ (qBinom q n k)
      ≤ e + Nat.log ℓ (n / d) + Nat.log ℓ ((n - k) / d + 1) := by
  have hkle : k / d ≤ n / d := Nat.div_le_div_right hk
  have hval := qBinom_padicValNat h hk
  have h1 : padicValNat ℓ ((n / d).choose (k / d)) ≤ Nat.log ℓ (n / d) :=
    padicValNat_choose_le_log hkle
  have h2 : padicValNat ℓ ((n - k) / d + 1) ≤ Nat.log ℓ ((n - k) / d + 1) :=
    padicValNat_le_nat_log _
  rw [hval]
  by_cases hcarry : d ≤ k % d + (n - k) % d
  · rw [if_pos hcarry]; omega
  · rw [if_neg hcarry]; omega

/-- **Divisibility criterion.**  With `c ≤ 1` the base-`d` carry, and provided the offset `e` is
positive whenever a carry can occur, `ℓ` divides `binom(n,k)_q` exactly when there is a base-`d`
carry or `ℓ` divides the classical binomial coefficient of the base-`d` quotients. -/
theorem dvd_qBinom_iff (h : IsQRegular q ℓ d e) {n k c : ℕ} (hk : k ≤ n) (hc1 : c ≤ 1)
    (hN : n / d = k / d + (n - k) / d + c) (he : c = 1 → 1 ≤ e) :
    ℓ ∣ qBinom q n k ↔ c = 1 ∨ ℓ ∣ (n / d).choose (k / d) := by
  have hkle : k / d ≤ n / d := by
    rw [hN]
    exact le_trans (Nat.le_add_right _ _) (Nat.le_add_right _ _)
  have hval := qBinom_padicValNat_of_carry h hk hc1 hN
  rw [dvd_iff_one_le_padicValNat (qBinom_pos hk).ne',
    dvd_iff_one_le_padicValNat (Nat.choose_pos hkle).ne', hval]
  constructor
  · intro hpos
    by_contra hcon
    push_neg at hcon
    obtain ⟨hc0, hch⟩ := hcon
    have hc : c = 0 := by omega
    rw [hc] at hpos
    omega
  · rintro (hc | hch)
    · have := he hc
      subst hc
      have : 1 ≤ e * 1 := by omega
      omega
    · omega

end General

section OddPrime

variable {q ℓ : ℕ} [hp : Fact ℓ.Prime]

/-- If the multiplicative order `d` of `q` modulo `ℓ` exceeds `1`, then `ℓ` genuinely divides the
`q`-integer `[d]_q`, i.e. the offset `e = v_ℓ([d]_q)` is positive. -/
theorem one_le_padicValNat_qNat_orderOf (hq : 2 ≤ q)
    (hd : 1 < orderOf ((q : ℕ) : ZMod ℓ)) :
    1 ≤ padicValNat ℓ (qNat q (orderOf ((q : ℕ) : ZMod ℓ))) := by
  set d := orderOf ((q : ℕ) : ZMod ℓ) with hdef
  have hdvd : ℓ ∣ q ^ d - 1 := (orderOf_dvd_iff_dvd_pow_sub_one hq d).mp dvd_rfl
  rw [← sub_one_mul_qNat (by omega : 1 ≤ q) d] at hdvd
  rcases (Nat.Prime.dvd_mul hp.out).mp hdvd with h1 | h2
  · exfalso
    have h11 : ℓ ∣ q ^ 1 - 1 := by simpa using h1
    have := (orderOf_dvd_iff_dvd_pow_sub_one hq 1).mpr h11
    have : d = 1 := Nat.dvd_one.mp this
    omega
  · exact (dvd_iff_one_le_padicValNat (qNat_pos q (by omega)).ne').mp h2

/-- **Divisibility criterion for an odd prime `ℓ ∤ q`.**  `ℓ ∣ binom(n,k)_q` exactly when adding
`k` and `n-k` carries out of the base-`d` digit (`d = ord_ℓ(q)`), or when `ℓ` divides the
classical binomial coefficient `binom(⌊n/d⌋, ⌊k/d⌋)`. -/
theorem dvd_qBinom_iff_orderOf (hodd : Odd ℓ) (hq : 2 ≤ q) (hnd : ¬ ℓ ∣ q) {n k : ℕ}
    (hk : k ≤ n) :
    ℓ ∣ qBinom q n k ↔
      (orderOf ((q : ℕ) : ZMod ℓ) ≤ k % orderOf ((q : ℕ) : ZMod ℓ)
          + (n - k) % orderOf ((q : ℕ) : ZMod ℓ))
        ∨ ℓ ∣ (n / orderOf ((q : ℕ) : ZMod ℓ)).choose (k / orderOf ((q : ℕ) : ZMod ℓ)) := by
  set d := orderOf ((q : ℕ) : ZMod ℓ) with hdef
  have hreg := isQRegular_of_odd_prime hodd hq hnd
  rw [← hdef] at hreg
  set c := (if d ≤ k % d + (n - k) % d then 1 else 0) with hc
  have hN : n / d = k / d + (n - k) / d + c := by
    have hn : k + (n - k) = n := by omega
    conv_lhs => rw [← hn]
    exact div_add_div_add_carry hreg.pos k (n - k)
  have he : c = 1 → 1 ≤ padicValNat ℓ (qNat q d) := by
    intro hc1
    have hdpos : 1 < d := by
      by_contra hcon
      have hd1 : d = 1 := by have := hreg.pos; omega
      have hfalse : ¬ (1 ≤ k % 1 + (n - k) % 1) := by omega
      rw [hc, hd1, if_neg hfalse] at hc1
      exact absurd hc1 (by norm_num)
    exact hdef ▸ one_le_padicValNat_qNat_orderOf hq (hdef ▸ hdpos)
  have hcrit := dvd_qBinom_iff hreg hk (by rw [hc]; split <;> simp) hN he
  rw [hcrit, hc]
  constructor
  · rintro (h1 | h2)
    · left
      by_contra hcon
      rw [if_neg hcon] at h1
      exact absurd h1 (by norm_num)
    · exact Or.inr h2
  · rintro (h1 | h2)
    · left
      rw [if_pos h1]
    · exact Or.inr h2

end OddPrime

end QKummer
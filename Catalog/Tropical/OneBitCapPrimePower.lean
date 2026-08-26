/-
# The one-bit cap, II: the primary-component envelope

Here the universal envelope of `Tropical.OneBitCapCore` is evaluated exactly for a
prime power `n = q ^ k`.  The evaluation rests on one structural observation:

* multiplying both exponents by `q` is a bijection from `box (q ^ k)` onto the
  sub-box of pairs both divisible by `q`, and it *preserves the splitting type*;
* off that sub-box at least one exponent is a unit, so the larger type class has
  the maximal size `φ (q ^ (k+1))`.

That gives the exact self-similar recursion

  `W (q^(k+1)) = (q^(2k+2) - q^(2k)) · log₂ φ(q^(k+1)) + W (q^k)`

for the class-average `W`, and hence the closed form

  `Ipair (q ^ k) ≤ (1 - q^{-2k}) · ( q² log₂ q / (q² - 1) - log₂ (q-1) )`.

The right-hand side is **exactly** `Ipair (2 ^ k)` when `q = 2` (proved in
`Tropical.OneBitCapTwoPower`), and is smaller than `39/40 < 1` for every odd
prime `q`: this is the odd half of the even/odd dichotomy, in its correct
primary-component form.
-/
import Tropical.OneBitCapCore

namespace CyclicTypeChannel

open Finset

/-! ## 1. The class-average `W` -/

/-- The pointwise integrand of the universal envelope: the log of the size of the
*larger* of the two type classes. -/
noncomputable def maxTot (n : ℕ) (x : ℕ × ℕ) : ℝ :=
  Real.logb 2 (max (Nat.totient (ordType n x.1)) (Nat.totient (ordType n x.2)) : ℝ)

/-- The (unnormalised) class average appearing in the universal envelope. -/
noncomputable def Wsum (n : ℕ) : ℝ := ∑ x ∈ box n, maxTot n x

theorem Ipair_le_Wsum {n : ℕ} (hn : 0 < n) :
    Ipair n ≤ Real.logb 2 n - Wsum n / ((n : ℝ) ^ 2) :=
  Ipair_le_maxTotient hn

/-! ## 2. Arithmetic of the splitting type on a prime power -/

/-- Scaling by `q` preserves the splitting type: `T_{q^{k+1}} (q a) = T_{q^k} a`. -/
theorem ordType_scale {q : ℕ} (hq : 0 < q) (k a : ℕ) :
    ordType (q ^ (k + 1)) (q * a) = ordType (q ^ k) a := by
  have h : q ^ (k + 1) = q * q ^ k := by ring
  rw [ordType, ordType, h, Nat.gcd_mul_left, Nat.mul_div_mul_left _ _ hq]

/-- A unit exponent has the full splitting type. -/
theorem ordType_of_not_dvd {q : ℕ} (hq : q.Prime) {m a : ℕ} (h : ¬ q ∣ a) :
    ordType (q ^ m) a = q ^ m := by
  have hco : Nat.Coprime a (q ^ m) :=
    Nat.Coprime.pow_right _ ((Nat.Prime.coprime_iff_not_dvd hq).2 h).symm
  rw [ordType, hco, Nat.div_one]

/-- Totient is monotone along divisibility. -/
theorem totient_le_of_dvd {d n : ℕ} (hn : 0 < n) (h : d ∣ n) :
    Nat.totient d ≤ Nat.totient n :=
  Nat.le_of_dvd (Nat.totient_pos.2 hn) (Nat.totient_dvd_of_dvd h)

/-- Off the sub-box of pairs divisible by `q`, the larger type class has the
maximal size. -/
theorem maxTot_of_not_both_dvd {q : ℕ} (hq : q.Prime) {m : ℕ} {x : ℕ × ℕ}
    (h : ¬ (q ∣ x.1 ∧ q ∣ x.2)) :
    maxTot (q ^ m) x = Real.logb 2 (Nat.totient (q ^ m) : ℝ) := by
  have hqpos : 0 < q ^ m := pow_pos hq.pos m
  have hle : ∀ a : ℕ, Nat.totient (ordType (q ^ m) a) ≤ Nat.totient (q ^ m) := fun a =>
    totient_le_of_dvd hqpos (ordType_dvd a)
  have key : max (Nat.totient (ordType (q ^ m) x.1)) (Nat.totient (ordType (q ^ m) x.2))
      = Nat.totient (q ^ m) := by
    rcases not_and_or.1 h with h1 | h1
    · have : ordType (q ^ m) x.1 = q ^ m := ordType_of_not_dvd hq h1
      rw [this]
      exact max_eq_left (hle x.2)
    · have : ordType (q ^ m) x.2 = q ^ m := ordType_of_not_dvd hq h1
      rw [this]
      exact max_eq_right (hle x.1)
  rw [maxTot, ← Nat.cast_max, key]

/-! ## 3. Counting the deep sub-box -/

/-- `#{a < q * m : q ∣ a} = m`. -/
theorem card_dvd_range {q m : ℕ} (hq : 0 < q) :
    #{a ∈ range (q * m) | q ∣ a} = m := by
  classical
  have himg : {a ∈ range (q * m) | q ∣ a} = (range m).image (fun i => q * i) := by
    ext a
    simp only [Finset.mem_filter, Finset.mem_range, Finset.mem_image]
    constructor
    · rintro ⟨ha, i, rfl⟩
      exact ⟨i, Nat.lt_of_mul_lt_mul_left ha, rfl⟩
    · rintro ⟨i, hi, rfl⟩
      exact ⟨mul_lt_mul_of_pos_left hi hq, ⟨i, rfl⟩⟩
  rw [himg, Finset.card_image_of_injective _
    (fun a b hab => Nat.eq_of_mul_eq_mul_left hq hab), Finset.card_range]

/-- The sub-box of pairs both divisible by `q` is the image of the smaller box
under doubling of the exponents. -/
theorem deep_subbox {q : ℕ} (hq : 0 < q) (k : ℕ) :
    {x ∈ box (q ^ (k + 1)) | q ∣ x.1 ∧ q ∣ x.2}
      = (box (q ^ k)).image (fun z => (q * z.1, q * z.2)) := by
  have hpow : q ^ (k + 1) = q * q ^ k := by ring
  ext y
  obtain ⟨a, b⟩ := y
  simp only [Finset.mem_filter, mem_box_iff, Finset.mem_image, Prod.exists, Prod.mk.injEq, hpow]
  constructor
  · rintro ⟨⟨h1, h2⟩, ⟨u, hu⟩, ⟨v, hv⟩⟩
    subst hu
    subst hv
    exact ⟨u, v, ⟨Nat.lt_of_mul_lt_mul_left h1, Nat.lt_of_mul_lt_mul_left h2⟩, rfl, rfl⟩
  · rintro ⟨u, v, huv, hu, hv⟩
    subst hu
    subst hv
    exact ⟨⟨mul_lt_mul_of_pos_left huv.1 hq, mul_lt_mul_of_pos_left huv.2 hq⟩,
      ⟨u, rfl⟩, ⟨v, rfl⟩⟩

/-- The number of pairs in `box (q^(k+1))` with at least one unit exponent. -/
theorem card_shallow {q : ℕ} (hq : 0 < q) (k : ℕ) :
    (#{x ∈ box (q ^ (k + 1)) | ¬ (q ∣ x.1 ∧ q ∣ x.2)} : ℝ)
      = (q : ℝ) ^ (2 * (k + 1)) - (q : ℝ) ^ (2 * k) := by
  classical
  have hdeep : #{x ∈ box (q ^ (k + 1)) | q ∣ x.1 ∧ q ∣ x.2} = q ^ k * q ^ k := by
    rw [deep_subbox hq k, Finset.card_image_of_injective _ (fun z w hzw => by
      have h1 : q * z.1 = q * w.1 := congrArg Prod.fst hzw
      have h2 : q * z.2 = q * w.2 := congrArg Prod.snd hzw
      exact Prod.ext (Nat.eq_of_mul_eq_mul_left hq h1) (Nat.eq_of_mul_eq_mul_left hq h2)),
      card_box]
  have htot : #{x ∈ box (q ^ (k + 1)) | q ∣ x.1 ∧ q ∣ x.2}
      + #{x ∈ box (q ^ (k + 1)) | ¬ (q ∣ x.1 ∧ q ∣ x.2)} = q ^ (k + 1) * q ^ (k + 1) := by
    rw [Finset.card_filter_add_card_filter_not, card_box]
  have : (#{x ∈ box (q ^ (k + 1)) | ¬ (q ∣ x.1 ∧ q ∣ x.2)} : ℕ)
      = q ^ (k + 1) * q ^ (k + 1) - q ^ k * q ^ k := by omega
  rw [this]
  have hle : q ^ k * q ^ k ≤ q ^ (k + 1) * q ^ (k + 1) := by
    exact Nat.mul_le_mul (Nat.pow_le_pow_right hq (by omega)) (Nat.pow_le_pow_right hq (by omega))
  push_cast [Nat.cast_sub hle]
  ring

/-! ## 4. The self-similar recursion -/

theorem Wsum_succ {q : ℕ} (hq : q.Prime) (k : ℕ) :
    Wsum (q ^ (k + 1))
      = ((q : ℝ) ^ (2 * (k + 1)) - (q : ℝ) ^ (2 * k))
          * Real.logb 2 (Nat.totient (q ^ (k + 1)) : ℝ) + Wsum (q ^ k) := by
  classical
  have hq0 : 0 < q := hq.pos
  have hsplit := Finset.sum_filter_add_sum_filter_not (box (q ^ (k + 1)))
    (fun x => q ∣ x.1 ∧ q ∣ x.2) (maxTot (q ^ (k + 1)))
  have hdeep : ∑ x ∈ {x ∈ box (q ^ (k + 1)) | q ∣ x.1 ∧ q ∣ x.2}, maxTot (q ^ (k + 1)) x
      = Wsum (q ^ k) := by
    rw [deep_subbox hq0 k, Finset.sum_image (fun z _ w _ hzw => by
      have h1 : q * z.1 = q * w.1 := congrArg Prod.fst hzw
      have h2 : q * z.2 = q * w.2 := congrArg Prod.snd hzw
      exact Prod.ext (Nat.eq_of_mul_eq_mul_left hq0 h1) (Nat.eq_of_mul_eq_mul_left hq0 h2))]
    refine Finset.sum_congr rfl fun z _ => ?_
    simp only [maxTot, ordType_scale hq0 k]
  have hshallow : ∑ x ∈ {x ∈ box (q ^ (k + 1)) | ¬ (q ∣ x.1 ∧ q ∣ x.2)}, maxTot (q ^ (k + 1)) x
      = ((q : ℝ) ^ (2 * (k + 1)) - (q : ℝ) ^ (2 * k))
          * Real.logb 2 (Nat.totient (q ^ (k + 1)) : ℝ) := by
    rw [Finset.sum_congr rfl (fun x hx =>
      maxTot_of_not_both_dvd hq (Finset.mem_filter.1 hx).2)]
    rw [Finset.sum_const, nsmul_eq_mul, card_shallow hq0 k]
  rw [Wsum, ← hsplit, hdeep, hshallow]
  ring

/-! ## 5. The closed form of the envelope -/

/-- `log₂ φ(q^(k+1)) = k log₂ q + log₂ (q-1)` for a prime `q`. -/
theorem logb_totient_prime_pow {q : ℕ} (hq : q.Prime) (k : ℕ) :
    Real.logb 2 (Nat.totient (q ^ (k + 1)) : ℝ)
      = (k : ℝ) * Real.logb 2 q + Real.logb 2 ((q : ℝ) - 1) := by
  have hq1 : (1 : ℝ) < (q : ℝ) := by exact_mod_cast hq.one_lt
  have htot : (Nat.totient (q ^ (k + 1)) : ℝ) = (q : ℝ) ^ k * ((q : ℝ) - 1) := by
    rw [Nat.totient_prime_pow hq (Nat.succ_pos k), Nat.succ_sub_one, Nat.cast_mul,
      Nat.cast_pow, Nat.cast_sub hq.one_le, Nat.cast_one]
  rw [htot, Real.logb_mul (by positivity) (by linarith), Real.logb_pow]

/-- **The exact closed form of the primary envelope.** -/
theorem Wsum_prime_pow_closed {q : ℕ} (hq : q.Prime) (k : ℕ) :
    ((q : ℝ) ^ 2 - 1) * ((k : ℝ) * Real.logb 2 q * (q : ℝ) ^ (2 * k) - Wsum (q ^ k))
      = ((q : ℝ) ^ (2 * k) - 1)
          * ((q : ℝ) ^ 2 * Real.logb 2 q - ((q : ℝ) ^ 2 - 1) * Real.logb 2 ((q : ℝ) - 1)) := by
  induction k with
  | zero =>
      have hbox : box (q ^ 0) = {((0 : ℕ), (0 : ℕ))} := by
        ext y
        simp only [mem_box_iff, pow_zero, Finset.mem_singleton]
        constructor
        · rintro ⟨h1, h2⟩
          exact Prod.ext (by omega) (by omega)
        · rintro rfl
          exact ⟨by norm_num, by norm_num⟩
      have hW : Wsum (q ^ 0) = 0 := by
        rw [Wsum, hbox]
        simp [maxTot, ordType]
      rw [hW]
      norm_num
  | succ k ih =>
      have hrec := Wsum_succ hq k
      rw [logb_totient_prime_pow hq k] at hrec
      have hpow : (q : ℝ) ^ (2 * (k + 1)) = (q : ℝ) ^ (2 * k) * (q : ℝ) ^ 2 := by
        rw [← pow_add]
        ring_nf
      rw [hrec, hpow]
      push_cast
      linear_combination ih

/-! ## 6. The primary envelope in closed form -/

/-- **The primary-component envelope.**  For every prime `q` and every `k`,
`Ipair (q^k) ≤ (1 - q^{-2k}) (q² log₂ q/(q²-1) - log₂ (q-1))`. -/
theorem Ipair_prime_pow_le {q : ℕ} (hq : q.Prime) (k : ℕ) :
    Ipair (q ^ k)
      ≤ (1 - 1 / (q : ℝ) ^ (2 * k))
        * ((q : ℝ) ^ 2 * Real.logb 2 q / ((q : ℝ) ^ 2 - 1) - Real.logb 2 ((q : ℝ) - 1)) := by
  have hq2 : (2 : ℝ) ≤ (q : ℝ) := by exact_mod_cast hq.two_le
  have hqpos : (0 : ℝ) < (q : ℝ) := by linarith
  have hq21 : (0 : ℝ) < (q : ℝ) ^ 2 - 1 := by nlinarith
  have hpk : (0 : ℝ) < (q : ℝ) ^ (2 * k) := by positivity
  have hn : 0 < q ^ k := pow_pos hq.pos k
  have hkey := Ipair_le_Wsum hn
  have hcast : ((q ^ k : ℕ) : ℝ) = (q : ℝ) ^ k := Nat.cast_pow q k
  rw [hcast] at hkey
  have hlogb : Real.logb 2 ((q : ℝ) ^ k) = (k : ℝ) * Real.logb 2 q := by
    rw [Real.logb_pow]
  have hsq : ((q : ℝ) ^ k) ^ 2 = (q : ℝ) ^ (2 * k) := by
    rw [← pow_mul]; ring_nf
  rw [hlogb, hsq] at hkey
  have hclosed := Wsum_prime_pow_closed hq k
  have hW : Wsum (q ^ k)
      = (k : ℝ) * Real.logb 2 q * (q : ℝ) ^ (2 * k)
        - ((q : ℝ) ^ (2 * k) - 1)
            * ((q : ℝ) ^ 2 * Real.logb 2 q - ((q : ℝ) ^ 2 - 1) * Real.logb 2 ((q : ℝ) - 1))
          / ((q : ℝ) ^ 2 - 1) := by
    field_simp at hclosed ⊢
    linarith [hclosed]
  rw [hW] at hkey
  refine hkey.trans (le_of_eq ?_)
  field_simp
  ring

/-! ## 7. The odd half of the dichotomy -/

/-- The envelope constant is below `39/40` for every odd prime. -/
theorem envelope_lt_one {q : ℕ} (hq : q.Prime) (hq2 : q ≠ 2) :
    (q : ℝ) ^ 2 * Real.logb 2 q / ((q : ℝ) ^ 2 - 1) - Real.logb 2 ((q : ℝ) - 1)
      ≤ 39 / 40 := by
  have hq3 : 3 ≤ q := by
    have := hq.two_le
    rcases eq_or_lt_of_le this with h | h
    · exact absurd h.symm hq2
    · omega
  have hqR : (3 : ℝ) ≤ (q : ℝ) := by exact_mod_cast hq3
  have hqpos : (0 : ℝ) < (q : ℝ) := by linarith
  have hq21 : (0 : ℝ) < (q : ℝ) ^ 2 - 1 := by nlinarith
  set L := Real.logb 2 (q : ℝ) with hL
  -- the split `q² L/(q²-1) = L + L/(q²-1)`
  have hsplit : (q : ℝ) ^ 2 * L / ((q : ℝ) ^ 2 - 1) = L + L / ((q : ℝ) ^ 2 - 1) := by
    field_simp
    ring
  -- `L - log₂ (q-1) = log₂ (q/(q-1)) ≤ log₂ (3/2) < 3/5`
  have hgap : L - Real.logb 2 ((q : ℝ) - 1) ≤ 3 / 5 := by
    have hratio : Real.logb 2 ((q : ℝ) / ((q : ℝ) - 1)) ≤ Real.logb 2 (3 / 2) := by
      refine Real.logb_le_logb_of_le (by norm_num) (div_pos hqpos (by linarith)) ?_
      rw [div_le_div_iff₀ (by linarith) (by norm_num)]
      linarith
    have hdiv : Real.logb 2 ((q : ℝ) / ((q : ℝ) - 1)) = L - Real.logb 2 ((q : ℝ) - 1) := by
      rw [Real.logb_div (by linarith) (by linarith)]
    have h32 : Real.logb 2 (3 / 2 : ℝ) = Real.logb 2 3 - 1 := by
      rw [Real.logb_div (by norm_num) (by norm_num)]
      simp
    have h3 : Real.logb 2 (3 : ℝ) < 8 / 5 := lb_three_lt
    rw [hdiv, h32] at hratio
    linarith
  -- `L/(q²-1) ≤ q/(q²-1) ≤ 3/8`
  have hsmall : L / ((q : ℝ) ^ 2 - 1) ≤ 3 / 8 := by
    have hLq : L ≤ (q : ℝ) := by rw [hL]; exact logb_two_le_self hq.pos
    have h1 : L / ((q : ℝ) ^ 2 - 1) ≤ (q : ℝ) / ((q : ℝ) ^ 2 - 1) := by
      gcongr
    have h2 : (q : ℝ) / ((q : ℝ) ^ 2 - 1) ≤ 3 / 8 := by
      rw [div_le_div_iff₀ hq21 (by norm_num)]
      nlinarith
    linarith
  rw [hsplit]
  linarith

/-- **Odd primary components are strictly below the one-bit cap.**  For every odd
prime `q` and every exponent `k`, the type-pair channel of the cyclic order
`q ^ k` carries strictly less than one bit — in fact at most `39/40`. -/
theorem Ipair_odd_prime_pow_lt_one {q : ℕ} (hq : q.Prime) (hq2 : q ≠ 2) (k : ℕ) :
    Ipair (q ^ k) < 1 := by
  have hq2R : (2 : ℝ) ≤ (q : ℝ) := by exact_mod_cast hq.two_le
  have hpk : (0 : ℝ) < (q : ℝ) ^ (2 * k) := by positivity
  have hfac : (0 : ℝ) ≤ 1 - 1 / (q : ℝ) ^ (2 * k) := by
    have : 1 / (q : ℝ) ^ (2 * k) ≤ 1 := by
      rw [div_le_one hpk]
      exact one_le_pow₀ (by linarith)
    linarith
  have hfac1 : 1 - 1 / (q : ℝ) ^ (2 * k) ≤ 1 := by
    have hpos : (0 : ℝ) < 1 / (q : ℝ) ^ (2 * k) := by positivity
    linarith
  have hE := envelope_lt_one hq hq2
  have hle := Ipair_prime_pow_le hq k
  set E := (q : ℝ) ^ 2 * Real.logb 2 q / ((q : ℝ) ^ 2 - 1) - Real.logb 2 ((q : ℝ) - 1) with hEdef
  rcases le_total E 0 with h | h
  · nlinarith
  · nlinarith

end CyclicTypeChannel
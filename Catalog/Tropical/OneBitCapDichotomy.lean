/-
# The one-bit cap, IV: the corrected even/odd dichotomy

The conjecture C3 asserts that the type-pair channel of a cyclic order breaks the
one-bit cap *exactly* when the order is even.  The half of C3 concerning even
orders is proved here in sharp form:

* `Ipair (2 ^ k) = (4/3)(1 - 4^{-k})` (`Tropical.OneBitCapTwoPower`), so the
  `2`-primary tower attains the cap exactly at `k = 1` and exceeds it for `k ≥ 2`;
* every even order other than `2` is strictly above the cap
  (`one_lt_Ipair_of_even`), and every even order is at least at the cap;
* the *prime-power* dichotomy is exactly as C3 predicts:
  `1 < Ipair (q ^ k) ↔ q = 2 ∧ 2 ≤ k` (`one_lt_Ipair_prime_pow_iff`).

The odd half of C3, however, is **false** as literally stated: the catalogue
already exhibits an odd order above the cap
(`CyclicTypeChannel.exists_odd_order_above_cap`).  The correct statement is the
*primary-component* one: every odd primary component is strictly sub-critical, in
fact `Ipair (q ^ k) ≤ 39/40` for every odd prime `q`
(`Ipair_odd_prime_pow_le`), so an odd order can only break the cap by
accumulating many distinct primary components: `Ipair n ≤ (39/40) ω(n)`.

The engine of the even half is the new strict positivity estimate
`Real.logb 2 n / n ^ 2 ≤ Ipair n` (`Ipair_ge_logb_div_sq`), obtained from the
class-wise envelope by isolating the single degenerate class `T = (1,1)`.
-/
import Tropical.OneBitCapTwoPower
import Shared.CyclicTypeChannelOdd
import Shared.CyclicTypeChannelFamilies

namespace CyclicTypeChannel

open Finset

/-! ## 1. The degenerate class and strict positivity -/

/-- Only the zero exponent has the trivial splitting type. -/
theorem eq_zero_of_ordType_eq_one {n a : ℕ} (ha : a < n)
    (h : ordType n a = 1) : a = 0 := by
  have hd : Nat.gcd a n ∣ n := Nat.gcd_dvd_right _ _
  have hg : n = Nat.gcd a n * 1 := Nat.eq_mul_of_div_eq_right hd h
  have hna : n ∣ a := by
    rw [mul_one] at hg
    rw [hg]
    exact Nat.gcd_dvd_left a n
  exact Nat.eq_zero_of_dvd_of_lt hna ha

/-- **A quantitative lower bound for the channel.**  For every `n ≥ 1`,
`Ipair n ≥ log₂ n / n²`.

The proof isolates the single degenerate type class `T = (1,1)`: it consists of
the pair `(0,0)` alone, so it carries no residue entropy at all, while every other
class contributes at most the trivial bound `log₂ n`. -/
theorem Ipair_ge_logb_div_sq {n : ℕ} (hn : 0 < n) :
    Real.logb 2 n / ((n : ℝ) ^ 2) ≤ Ipair n := by
  classical
  have hnR : (0 : ℝ) < (n : ℝ) := by exact_mod_cast hn
  set L := Real.logb 2 (n : ℝ) with hL
  set psi : ℕ × ℕ → ℝ := fun t => if t = (1, 1) then 0 else L with hpsi
  have hzero : ∀ x ∈ box n, ordPair n x = (1, 1) → x = ((0 : ℕ), (0 : ℕ)) := by
    intro x hx h
    obtain ⟨hx1, hx2⟩ := mem_box_iff.1 hx
    have h1 : ordType n x.1 = 1 := congrArg Prod.fst h
    have h2 : ordType n x.2 = 1 := congrArg Prod.snd h
    exact Prod.ext (eq_zero_of_ordType_eq_one hx1 h1)
      (eq_zero_of_ordType_eq_one hx2 h2)
  have hord00 : ordPair n ((0 : ℕ), (0 : ℕ)) = (1, 1) := by
    simp [ordPair, ordType, Nat.div_self hn]
  have hcls : ∀ x ∈ box n,
      uEnt {y ∈ box n | ordPair n y = ordPair n x} (prodRes n) ≤ psi (ordPair n x) := by
    intro x hx
    by_cases h11 : ordPair n x = (1, 1)
    · have hcard : #{y ∈ box n | ordPair n y = ordPair n x} ≤ 1 := by
        refine Finset.card_le_one.2 ?_
        intro a ha b hb
        simp only [Finset.mem_filter] at ha hb
        rw [hzero a ha.1 (ha.2.trans h11), hzero b hb.1 (hb.2.trans h11)]
      rw [uEnt_of_card_le_one hcard, hpsi]
      simp [h11]
    · have hmaps : ∀ y ∈ {y ∈ box n | ordPair n y = ordPair n x},
          prodRes n y ∈ range n := by
        intro y _
        exact Finset.mem_range.2 (Nat.mod_lt _ hn)
      have := uEnt_le_logb_card_of_mapsTo (S := range n)
        (by simpa using hn) hmaps
      rw [Finset.card_range] at this
      rw [hpsi]
      simpa [h11] using this
  have hsum : (∑ x ∈ box n, psi (ordPair n x)) = ((n : ℝ) ^ 2 - 1) * L := by
    have hcongr : ∀ x ∈ box n,
        psi (ordPair n x) = L - (if x = ((0 : ℕ), (0 : ℕ)) then L else 0) := by
      intro x hx
      by_cases h11 : ordPair n x = (1, 1)
      · have hx0 : x = ((0 : ℕ), (0 : ℕ)) := hzero x hx h11
        simp [hpsi, hx0, hord00]
      · have hx0 : x ≠ ((0 : ℕ), (0 : ℕ)) := by
          intro hc
          exact h11 (by rw [hc]; exact hord00)
        simp [hpsi, h11, hx0]
    have h00 : ((0 : ℕ), (0 : ℕ)) ∈ box n := mem_box_iff.2 ⟨hn, hn⟩
    rw [Finset.sum_congr rfl hcongr, Finset.sum_sub_distrib, Finset.sum_const,
      Finset.sum_ite_eq' (box n) ((0 : ℕ), (0 : ℕ)) (fun _ => L), if_pos h00,
      nsmul_eq_mul, card_box']
    ring
  have hkey := Ipair_ge_avg hn psi hcls
  rw [hsum] at hkey
  refine le_trans (le_of_eq ?_) hkey
  field_simp
  ring

/-- **Every non-trivial cyclic order carries a strictly positive amount of
information.** -/
theorem Ipair_pos {n : ℕ} (hn : 2 ≤ n) : 0 < Ipair n := by
  have hn0 : 0 < n := by omega
  have hnR : (2 : ℝ) ≤ (n : ℝ) := by exact_mod_cast hn
  have hlog : 0 < Real.logb 2 (n : ℝ) :=
    Real.logb_pos (by norm_num) (by linarith)
  have hsq : (0 : ℝ) < (n : ℝ) ^ 2 := by positivity
  exact lt_of_lt_of_le (div_pos hlog hsq) (Ipair_ge_logb_div_sq hn0)

/-! ## 2. The two-primary tower -/

/-- The `2`-primary tower attains the cap exactly at `k = 1`. -/
theorem Ipair_two_pow_eq_one_iff (k : ℕ) : Ipair (2 ^ k) = 1 ↔ k = 1 := by
  rw [Ipair_two_pow_eq]
  constructor
  · intro h
    have h4 : (0 : ℝ) < 4 ^ k := by positivity
    have hk : (4 : ℝ) ^ k = 4 := by
      field_simp at h
      linarith
    by_contra hk1
    rcases Nat.lt_or_ge k 1 with h0 | h2
    · interval_cases k
      norm_num at hk
    · have hk2 : 2 ≤ k := by omega
      have h16 : (16 : ℝ) ≤ 4 ^ k := by
        calc (16 : ℝ) = 4 ^ 2 := by norm_num
          _ ≤ 4 ^ k := pow_le_pow_right₀ (by norm_num) hk2
      linarith
  · rintro rfl
    norm_num

/-- The `2`-primary tower is above the cap exactly from `k = 2` on. -/
theorem one_lt_Ipair_two_pow_iff (k : ℕ) : 1 < Ipair (2 ^ k) ↔ 2 ≤ k := by
  rw [Ipair_two_pow_eq]
  constructor
  · intro h
    by_contra hk
    push_neg at hk
    interval_cases k <;> norm_num at h
  · intro hk
    have h16 : (16 : ℝ) ≤ 4 ^ k := by
      calc (16 : ℝ) = 4 ^ 2 := by norm_num
        _ ≤ 4 ^ k := pow_le_pow_right₀ (by norm_num) hk
    have h4 : (0 : ℝ) < 4 ^ k := by positivity
    have hinv : 1 / (4 : ℝ) ^ k ≤ 1 / 16 := by
      rw [div_le_div_iff₀ h4 (by norm_num)]
      linarith
    linarith

/-- Every order in the `2`-primary tower beyond the trivial one is at the cap or
above it. -/
theorem one_le_Ipair_two_pow {k : ℕ} (hk : 1 ≤ k) : 1 ≤ Ipair (2 ^ k) := by
  rcases eq_or_lt_of_le hk with h | h
  · subst h
    rw [Ipair_two_pow_eq]
    norm_num
  · exact le_of_lt ((one_lt_Ipair_two_pow_iff k).2 (by omega))

/-- The catalogue value `Ipair 2 = 1`, recovered from the closed form. -/
theorem Ipair_two_val : Ipair 2 = 1 := by
  have h := Ipair_two_pow_eq 1
  rw [pow_one] at h
  rw [h]
  norm_num

/-! ## 3. The prime-power dichotomy -/

/-- The uniform sub-critical bound for odd primary components. -/
theorem Ipair_odd_prime_pow_le {q : ℕ} (hq : q.Prime) (hq2 : q ≠ 2) (k : ℕ) :
    Ipair (q ^ k) ≤ 39 / 40 := by
  have hq2R : (2 : ℝ) ≤ (q : ℝ) := by exact_mod_cast hq.two_le
  have hpk : (0 : ℝ) < (q : ℝ) ^ (2 * k) := by positivity
  have hfac : (0 : ℝ) ≤ 1 - 1 / (q : ℝ) ^ (2 * k) := by
    have h1 : 1 / (q : ℝ) ^ (2 * k) ≤ 1 := by
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

/-- **The prime-power form of C3 is true, and sharp.**  A primary cyclic order
breaks the one-bit cap precisely when it is the quadratic tower beyond its first
floor. -/
theorem one_lt_Ipair_prime_pow_iff {q k : ℕ} (hq : q.Prime) :
    1 < Ipair (q ^ k) ↔ (q = 2 ∧ 2 ≤ k) := by
  constructor
  · intro h
    by_cases hq2 : q = 2
    · subst hq2
      exact ⟨rfl, (one_lt_Ipair_two_pow_iff k).1 h⟩
    · exact absurd h (not_lt.2 (le_trans (Ipair_odd_prime_pow_le hq hq2 k) (by norm_num)))
  · rintro ⟨rfl, hk⟩
    exact (one_lt_Ipair_two_pow_iff k).2 hk

/-! ## 4. The even half of the dichotomy -/

/-- The two-adic decomposition of a positive integer. -/
theorem two_adic_split {n : ℕ} (hn : 0 < n) :
    ∃ a m : ℕ, 0 < m ∧ Odd m ∧ n = 2 ^ a * m ∧ Nat.Coprime (2 ^ a) m
      ∧ (2 ∣ n → 1 ≤ a) := by
  obtain ⟨a, m, hm, hnm⟩ := Nat.exists_eq_two_pow_mul_odd (n := n) (by omega)
  refine ⟨a, m, ?_, hm, hnm, coprime_two_pow_odd hm a, ?_⟩
  · rcases Nat.eq_zero_or_pos m with rfl | h
    · rw [Nat.mul_zero] at hnm
      omega
    · exact h
  · intro hd
    by_contra hc
    have ha : a = 0 := by omega
    rw [ha, pow_zero, one_mul] at hnm
    rw [Nat.odd_iff] at hm
    omega

/-- **Every even cyclic order is at least at the one-bit cap.** -/
theorem one_le_Ipair_of_even {n : ℕ} (hn : 0 < n) (he : 2 ∣ n) : 1 ≤ Ipair n := by
  obtain ⟨a, m, hm, -, hnm, hcop, hage⟩ := two_adic_split hn
  have ha : 1 ≤ a := hage he
  rw [hnm, Ipair_mul_of_coprime (pow_pos (by norm_num) a) hm hcop]
  linarith [one_le_Ipair_two_pow ha, Ipair_nonneg m]

/-- **The even half of C3.**  Every even cyclic order other than `2` carries
strictly more than one bit. -/
theorem one_lt_Ipair_of_even {n : ℕ} (hn : 0 < n) (he : 2 ∣ n) (hne : n ≠ 2) :
    1 < Ipair n := by
  obtain ⟨a, m, hm, -, hnm, hcop, hage⟩ := two_adic_split hn
  have ha : 1 ≤ a := hage he
  rw [hnm, Ipair_mul_of_coprime (pow_pos (by norm_num) a) hm hcop]
  rcases eq_or_lt_of_le ha with ha1 | ha2
  · -- `a = 1`, so the odd part is a proper factor `≥ 3`
    have hm1 : m ≠ 1 := by
      intro hc
      apply hne
      rw [hnm, hc, ← ha1]
      norm_num
    have hm2 : 2 ≤ m := by omega
    have h2 : Ipair (2 ^ a) = 1 := by
      rw [← ha1, pow_one]
      exact Ipair_two_val
    rw [h2]
    linarith [Ipair_pos hm2]
  · have := (one_lt_Ipair_two_pow_iff a).2 ha2
    linarith [Ipair_nonneg m]

/-- **The full even characterisation.** -/
theorem one_lt_Ipair_iff_of_even {n : ℕ} (hn : 0 < n) (he : 2 ∣ n) :
    1 < Ipair n ↔ n ≠ 2 := by
  constructor
  · intro h hc
    subst hc
    linarith [Ipair_two_val]
  · exact one_lt_Ipair_of_even hn he

/-! ## 5. The odd half of C3 is false, and its correct replacement -/

/-- **C3 as literally stated is false.**  There is no bound `Ipair n < 1` for odd
`n`: the catalogue witness `n = 300840735195` (a product of ten odd primes) is
strictly above the cap. -/
theorem C3_odd_half_refuted : ¬ (∀ n : ℕ, Odd n → 3 ≤ n → Ipair n < 1) := by
  intro h
  have hlt := h 300840735195 (Nat.odd_iff.2 (by norm_num)) (by norm_num)
  linarith [one_lt_Ipair_odd_order]

/-- **The correct odd bound.**  Every odd cyclic order satisfies
`Ipair n ≤ (39/40) ω(n)`, where `ω` counts the distinct prime factors: an odd
order can exceed the cap only by accumulating at least two primary components,
each of which is individually strictly sub-critical. -/
theorem Ipair_odd_le_omega {n : ℕ} (hodd : ¬ (2 ∣ n)) :
    Ipair n ≤ 39 / 40 * (n.primeFactors.card : ℝ) := by
  rw [Ipair_eq_sum_prime_powers (by omega)]
  have hbound : ∀ p ∈ n.primeFactors, Ipair (p ^ n.factorization p) ≤ 39 / 40 := by
    intro p hp
    have hpp : p.Prime := Nat.prime_of_mem_primeFactors hp
    have hp2 : p ≠ 2 := by
      rintro rfl
      exact hodd (Nat.dvd_of_mem_primeFactors hp)
    exact Ipair_odd_prime_pow_le hpp hp2 _
  calc ∑ p ∈ n.primeFactors, Ipair (p ^ n.factorization p)
      ≤ ∑ _p ∈ n.primeFactors, (39 / 40 : ℝ) := Finset.sum_le_sum hbound
    _ = 39 / 40 * (n.primeFactors.card : ℝ) := by
        rw [Finset.sum_const, nsmul_eq_mul]; ring

/-- An odd primary order is strictly below the cap — the primary-component form of
the odd half of C3. -/
theorem Ipair_lt_one_of_odd_prime_pow {n : ℕ} (hodd : ¬ (2 ∣ n))
    (h1 : n.primeFactors.card ≤ 1) : Ipair n < 1 := by
  have := Ipair_odd_le_omega hodd
  have hc : (n.primeFactors.card : ℝ) ≤ 1 := by exact_mod_cast h1
  nlinarith

/-! ## 6. Cross-validation against the catalogue -/

theorem Ipair_two_pow_check_4 : Ipair 4 = 5 / 4 := by
  have h := Ipair_two_pow_eq 2
  norm_num at h
  exact h

theorem Ipair_two_pow_check_16 : Ipair 16 = 85 / 64 := by
  have h := Ipair_two_pow_eq 4
  norm_num at h
  exact h

theorem Ipair_two_pow_check_32 : Ipair 32 = 341 / 256 := by
  have h := Ipair_two_pow_eq 5
  norm_num at h
  exact h

/-! ## 7. The shape of the two-primary tower -/

/-- The `2`-primary tower is strictly increasing. -/
theorem Ipair_two_pow_strictMono {k l : ℕ} (h : k < l) : Ipair (2 ^ k) < Ipair (2 ^ l) := by
  rw [Ipair_two_pow_eq, Ipair_two_pow_eq]
  have hk : (0 : ℝ) < 4 ^ k := by positivity
  have hl : (0 : ℝ) < 4 ^ l := by positivity
  have hlt : (4 : ℝ) ^ k < 4 ^ l := pow_lt_pow_right₀ (by norm_num) h
  have hinv : 1 / (4 : ℝ) ^ l < 1 / 4 ^ k := by
    rw [div_lt_div_iff₀ hl hk]
    linarith
  linarith

/-- `4/3` is a strict upper bound for the whole `2`-primary tower. -/
theorem Ipair_two_pow_lt_four_thirds (k : ℕ) : Ipair (2 ^ k) < 4 / 3 := by
  rw [Ipair_two_pow_eq]
  have hk : (0 : ℝ) < 4 ^ k := by positivity
  have hinv : (0 : ℝ) < 1 / 4 ^ k := by positivity
  linarith

/-- **`4/3` is exactly the supremum of the `2`-primary tower.**  The quadratic
tower saturates at four thirds of a bit — never more, and asymptotically no
less. -/
theorem Ipair_two_pow_tendsto :
    Filter.Tendsto (fun k : ℕ => Ipair (2 ^ k)) Filter.atTop (nhds (4 / 3)) := by
  have hfun : (fun k : ℕ => Ipair (2 ^ k))
      = fun k : ℕ => 4 / 3 * (1 - ((1 : ℝ) / 4) ^ k) := by
    funext k
    rw [Ipair_two_pow_eq, div_pow, one_pow]
  rw [hfun]
  have hz : Filter.Tendsto (fun k : ℕ => ((1 : ℝ) / 4) ^ k) Filter.atTop (nhds 0) :=
    tendsto_pow_atTop_nhds_zero_of_lt_one (by norm_num) (by norm_num)
  have := ((tendsto_const_nhds (x := (1 : ℝ)) (f := Filter.atTop (α := ℕ))).sub hz).const_mul
    (4 / 3 : ℝ)
  simpa using this

end CyclicTypeChannel

/-
## Lab notes — experimental data behind this file

Brute-force evaluation of `Ipair n` over the full box `range n ×ˢ range n`
(exact rational counting, double-precision logarithms; see
`ComputationalEvidence.md`):

  n :  2        3        4        5        6        7        8
  I : 1.0000   0.4739   1.2500   0.2027   1.4739   0.1141   1.3125

  n :  9       10       11       12       16       18       20
  I : 0.5265   1.2027   0.0519   1.7239   1.3281   1.5265   1.4527

Two-primary tower against the proved closed form `(4/3)(1 - 4^{-k})`:

  k :   1        2        3         4          5
  I :  1      5/4      21/16     85/64     341/256
  =  1.0000  1.2500   1.3125    1.328125  1.33203125          -> 4/3

Odd primary suprema `G(q) = sup_k Ipair (q^k)` and their partial sums over the
odd primes in increasing order:

  q  :   3        5        7       11       13       17       19       23
  G  : 0.5331   0.2112   0.1165   0.0523   0.0389   0.0241   0.0197   0.0140
  Σ  : 0.5331   0.7442   0.8607   0.9131   0.9519   0.9760   0.9957   1.0097

The partial sum first crosses `1` at the eighth odd prime, which is why odd cap
breakers exist (the catalogue witness `300840735195` has ten primary parts) yet
are extremely constrained.  The uniform bound proved here, `39/40`, is the
worst case `q = 3, k -> ∞` of the envelope `E(q)`, whose true value is `0.7820`;
the slack is the price of a single clean inequality valid for all odd `q`.
-/
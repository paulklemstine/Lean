/-
# The totient entropy is additive over coprime degrees

By `ForkPinning.ladder_entropy`, the splitting-type entropy of a cyclic field of degree `m`
(realised as `ℚ(ζ_ℓ)⁺`, `m = (ℓ-1)/2`) is the **totient entropy**

  `Hφ(m) = ∑_{d ∣ m} η(φ(d)/m)`,  `η(x) = -x log x`.

The ladder table shows a striking regularity: `Hφ(6) = Hφ(2) + Hφ(3)`, `Hφ(15) = Hφ(3) + Hφ(5)`,
`Hφ(18) = Hφ(2) + Hφ(9)` (the rung `ℓ = 37` is one bit above the degree-nine rung).  This file
proves the law behind it:

* `ForkPinning.totientEntropy_mul` : `Hφ(m n) = Hφ(m) + Hφ(n)` whenever `gcd(m, n) = 1` —
  multiplicativity of `φ` (number theory) becomes additivity of entropy (information theory):
  the splitting type of a cyclic field of degree `m n` is an independent pair of the types in
  its two coprime-degree subfields.
* `ForkPinning.totientEntropy_prime` : `Hφ(p) = η(1/p) + η((p-1)/p)` (the binary entropy of
  "splits / is inert").
* `ForkPinning.degreeNine_totientEntropy` : `Hφ(9) = (4/3) log 3 - (8/9) log 2`.
* `ForkPinning.degreeEighteen_entropy` : the rung `ℓ = 37` (`ℚ(ζ₃₇)⁺`, degree 18) has
  splitting-type entropy exactly `log 2 + Hφ(9)`: **one bit above the degree-nine rung**.
-/

import Probability.ForkPinningDegreeNine

namespace ForkPinning

open Finset Real

/-- The totient entropy `Hφ(m) = ∑_{d ∣ m} η(φ(d)/m)`. -/
noncomputable def totientEntropy (m : ℕ) : ℝ :=
  ∑ d ∈ m.divisors, negMulLog (Nat.totient d / m)

/-- The ladder entropy law, restated: the splitting type has entropy `Hφ(m)`. -/
theorem ladder_entropy_eq_totientEntropy {G : Type*} [CommGroup G] [Fintype G] [DecidableEq G]
    [IsCyclic G] {m : ℕ} (hG : Fintype.card G = 2 * m) :
    H (ladderType : G → (Fintype.card G).divisors) = totientEntropy m :=
  ladder_entropy hG

/-- The totient weights `φ(d)/m` form a probability distribution on the divisors of `m`. -/
lemma sum_totient_div {m : ℕ} (hm : m ≠ 0) :
    ∑ d ∈ m.divisors, (Nat.totient d : ℝ) / m = 1 := by
  rw [← Finset.sum_div]
  have : ∑ d ∈ m.divisors, (Nat.totient d : ℝ) = m := by exact_mod_cast Nat.sum_totient m
  rw [this, div_self (by exact_mod_cast hm)]

/-- Multiplication is injective on pairs of divisors of coprime numbers. -/
lemma mul_injOn_divisors {m n : ℕ} (hmn : m.Coprime n) :
    Set.InjOn (fun p : ℕ × ℕ => p.1 * p.2) (m.divisors ×ˢ n.divisors : Finset (ℕ × ℕ)) := by
  rintro ⟨a, b⟩ hab ⟨a', b'⟩ hab' h
  simp only [coe_product, Set.mem_prod, mem_coe, Nat.mem_divisors] at hab hab'
  simp only at h
  have hcop : ∀ {x y : ℕ}, x ∣ m → y ∣ n → x.Coprime y := fun hx hy =>
    (hmn.coprime_dvd_left hx).coprime_dvd_right hy
  have h1 : a ∣ a' := (hcop hab.1.1 hab'.2.1).dvd_of_dvd_mul_right (h ▸ dvd_mul_right a b)
  have h2 : a' ∣ a := (hcop hab'.1.1 hab.2.1).dvd_of_dvd_mul_right (h ▸ dvd_mul_right a' b')
  have ha : a = a' := Nat.dvd_antisymm h1 h2
  subst ha
  have hapos : 0 < a := Nat.pos_of_dvd_of_pos hab.1.1 (Nat.pos_of_ne_zero hab.1.2)
  exact Prod.ext rfl (Nat.eq_of_mul_eq_mul_left hapos h)

/-- **Additivity of the totient entropy over coprime degrees.** -/
theorem totientEntropy_mul {m n : ℕ} (hm : m ≠ 0) (hn : n ≠ 0) (hmn : m.Coprime n) :
    totientEntropy (m * n) = totientEntropy m + totientEntropy n := by
  unfold totientEntropy
  rw [Nat.divisors_mul, Finset.mul_def, Finset.sum_image (mul_injOn_divisors hmn),
    Finset.sum_product]
  have hterm : ∀ a ∈ m.divisors, ∀ b ∈ n.divisors,
      negMulLog (Nat.totient (a * b) / ((m * n : ℕ) : ℝ))
        = (Nat.totient b / n : ℝ) * negMulLog (Nat.totient a / m)
          + (Nat.totient a / m : ℝ) * negMulLog (Nat.totient b / n) := by
    intro a ha b hb
    have hab : a.Coprime b :=
      (hmn.coprime_dvd_left (Nat.dvd_of_mem_divisors ha)).coprime_dvd_right
        (Nat.dvd_of_mem_divisors hb)
    rw [Nat.totient_mul hab, ← negMulLog_mul]
    congr 1
    push_cast
    field_simp
  rw [Finset.sum_congr rfl (fun a ha => Finset.sum_congr rfl (fun b hb => hterm a ha b hb))]
  simp only [Finset.sum_add_distrib, ← Finset.sum_mul, ← Finset.mul_sum]
  rw [sum_totient_div hn, sum_totient_div hm]
  ring

/-- The totient entropy of a prime degree is the binary entropy of `1/p`. -/
theorem totientEntropy_prime {p : ℕ} (hp : p.Prime) :
    totientEntropy p = negMulLog (1 / p) + negMulLog ((p - 1) / p) := by
  unfold totientEntropy
  rw [Nat.Prime.divisors hp, sum_pair hp.one_lt.ne, Nat.totient_one, Nat.totient_prime hp]
  rw [Nat.cast_sub hp.one_le]
  push_cast
  rfl

/-- `Hφ(9) = (4/3) log 3 - (8/9) log 2`. -/
theorem degreeNine_totientEntropy :
    totientEntropy 9 = 4 / 3 * Real.log 3 - 8 / 9 * Real.log 2 := by
  have h := ladder_entropy_eq_totientEntropy card_units_zmod19
  rw [← h]
  exact degreeNine_entropy

/-- `Hφ(2) = log 2`. -/
lemma totientEntropy_two : totientEntropy 2 = Real.log 2 := by
  rw [totientEntropy_prime Nat.prime_two]
  simp only [negMulLog, Nat.cast_ofNat]
  rw [show ((2 : ℝ) - 1) / 2 = 1 / 2 by norm_num, one_div, Real.log_inv]
  ring

instance fact_prime_thirtySeven : Fact (Nat.Prime 37) := ⟨by norm_num⟩

/-- **The rung `ℓ = 37` is one bit above the degree-nine rung**: the splitting type of
`ℚ(ζ₃₇)⁺` (degree 18) has entropy `log 2 + (4/3) log 3 - (8/9) log 2`. -/
theorem degreeEighteen_entropy :
    H (ladderType : (ZMod 37)ˣ → _) = Real.log 2 + (4 / 3 * Real.log 3 - 8 / 9 * Real.log 2) := by
  rw [ladder_entropy_eq_totientEntropy (card_units_zmod_prime 37 (by norm_num))]
  rw [show (37 - 1) / 2 = 2 * 9 by norm_num, totientEntropy_mul (by norm_num) (by norm_num)
    (by norm_num), totientEntropy_two, degreeNine_totientEntropy]

end ForkPinning
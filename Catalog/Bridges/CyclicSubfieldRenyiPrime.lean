/-
# Effective Rényi gaps at prime degree

The previous cycle computed the whole Rényi spectrum of the conductor-13 cyclic
cubic channel and separated the collision entropy from the Shannon entropy by the
integer inequality `108 < 125`.  Direction 4 of `FUTURE_DIRECTIONS.md` conjectured
that this is the degree-3 shadow of a *uniform* phenomenon: at every prime degree
`q` the splitting-type distribution is the two-point vector `(1/q, (q-1)/q)`, so
every Rényi order has a closed form, the Shannon–collision gap is strictly
positive, and — being a `ℚ`-combination of logarithms of `q`, `q - 1` and
`q² - 2q + 2` — irrational.

This file proves all of that.

* `prime_pushProb`, `typeRenyi_prime_formula` — the two-point push-forward and the
  closed form `H_a(T_q) = (1-a)⁻¹ log₂((1/q)^a + ((q-1)/q)^a)` at every order.
* `typeRenyi_prime_zero`, `typeRenyi_prime_two` — the Hartley entropy is exactly
  one bit and the collision entropy is `2 log₂ q - log₂ (q² - 2q + 2)`.
* `collision_gap_nat`, `collision_gap_real` — the integer inequality
  `(m+1)^(m+1) · m^m < (m²+1)^(m+1)` for `m ≥ 2`, i.e.
  `q^q (q-1)^(q-1) < (q² - 2q + 2)^q`, proved for `m ≥ 3` from
  `1 + x ≤ exp x` and `exp 1 < 3`, and by direct computation at `m = 2`.
* `typeRenyi_two_lt_typeEntropy` — hence `H_2(T_q) < H_1(T_q)` for every prime
  `q ≥ 3` (at `q = 2` the channel is uniform and all orders agree, so the
  hypothesis is sharp: `typeRenyi_two_eq_typeEntropy_two`).
* `collision_gap_irrational` — the gap is irrational at every prime `q ≥ 3`,
  through the unique-factorisation bridge of `CyclicSubfieldDefectIrrationality`
  applied to the relation `(q²-2q+2)^{qb} = 2^A (q^q (q-1)^{q-1})^b`, which is
  impossible because `q ∤ q² - 2q + 2`.
* `conductor13_collision_entropy_value`, `conductor13_collision_gap_irrational` —
  the conductor-13 instances: `H_2 = log₂(9/5)` and the gap
  `log₂ 3 - 2/3 - log₂(9/5)` is irrational.

## Lab notes

| degree `q` | `H_1 = log₂ q - ((q-1)/q) log₂(q-1)` | `H_2 = log₂(q²/(q²-2q+2))` | gap |
|---|---|---|---|
| 2 | 1 | 1 | 0 |
| 3 | 0.918296 | 0.847997 | 0.070299 |
| 5 | 0.721928 | 0.556393 | 0.165535 |
| 7 | 0.591673 | 0.405263 | 0.186410 |
| 13 | 0.391279 | 0.220838 | 0.170441 |

(The floating-point column is exploratory; the theorems below prove only the
exact statements.)  The integer certificates behind the strict gap are
`3³·2² = 108 < 125 = 5³` at `q = 3` and `5⁵·4⁴ = 800000 < 1419857 = 17⁵` at
`q = 5`.
-/
import Bridges.CyclicSubfieldRenyi
import Bridges.CyclicSubfieldDefectIrrationality

namespace CyclicSubfield

open Finset Real CyclicTypeChannel

/-! ## 1. The two-point push-forward at prime degree -/

/-- **The splitting-type distribution at prime degree is the two-point vector
`(1/q, (q-1)/q)`**: exactly one exponent out of `q` splits completely. -/
theorem prime_pushProb {q : ℕ} (hq : q.Prime) :
    pushProb (range q) (ordType q) 1 = 1 / (q : ℝ) ∧
      pushProb (range q) (ordType q) q = ((q : ℝ) - 1) / (q : ℝ) := by
  have h1 : #{a ∈ range q | ordType q a = 1} = Nat.totient 1 :=
    card_ordType_eq_totient hq.pos (one_dvd _)
  have h2 : #{a ∈ range q | ordType q a = q} = Nat.totient q :=
    card_ordType_eq_totient hq.pos dvd_rfl
  refine ⟨?_, ?_⟩
  · unfold pushProb
    rw [card_range, h1]
    simp
  · unfold pushProb
    rw [card_range, h2, Nat.totient_prime hq, Nat.cast_sub hq.one_lt.le, Nat.cast_one]

/-- **The Rényi spectrum at prime degree.**  For every prime `q` and every order
`a`, `H_a(T_q) = (1-a)⁻¹ log₂((1/q)^a + ((q-1)/q)^a)`. -/
theorem typeRenyi_prime_formula {q : ℕ} (hq : q.Prime) (a : ℝ) :
    typeRenyi a q
      = (1 - a)⁻¹ * Real.logb 2 ((1 / (q : ℝ)) ^ a + (((q : ℝ) - 1) / (q : ℝ)) ^ a) := by
  have himg : (range q).image (ordType q) = ({1, q} : Finset ℕ) := by
    rw [image_ordType q hq.pos, hq.divisors]
  have hp := prime_pushProb hq
  unfold typeRenyi uRenyi
  rw [himg, Finset.sum_pair hq.one_lt.ne, hp.1, hp.2]

/-- Order `0`: the Hartley entropy of a prime-degree channel is exactly one
bit — there are precisely two splitting types. -/
theorem typeRenyi_prime_zero {q : ℕ} (hq : q.Prime) : typeRenyi 0 q = 1 := by
  have hq0 : (0 : ℝ) < (q : ℝ) := by exact_mod_cast hq.pos
  have hq1 : (0 : ℝ) < (q : ℝ) - 1 := by
    have : (2 : ℝ) ≤ (q : ℝ) := by exact_mod_cast hq.two_le
    linarith
  rw [typeRenyi_prime_formula hq 0, Real.rpow_zero, Real.rpow_zero]
  norm_num

/-- Order `2`: the collision entropy at prime degree is
`H_2(T_q) = 2 log₂ q - log₂ (q² - 2q + 2)`. -/
theorem typeRenyi_prime_two {q : ℕ} (hq : q.Prime) :
    typeRenyi 2 q = 2 * Real.logb 2 q - Real.logb 2 ((q : ℝ) ^ 2 - 2 * q + 2) := by
  have hq0 : (0 : ℝ) < (q : ℝ) := by exact_mod_cast hq.pos
  have hq2 : (2 : ℝ) ≤ (q : ℝ) := by exact_mod_cast hq.two_le
  have hX : (0 : ℝ) < (q : ℝ) ^ 2 - 2 * q + 2 := by nlinarith
  have hsq : ∀ x : ℝ, 0 ≤ x → x ^ (2 : ℝ) = x ^ (2 : ℕ) := by
    intro x hx
    rw [show (2 : ℝ) = ((2 : ℕ) : ℝ) by norm_num, Real.rpow_natCast]
  rw [typeRenyi_prime_formula hq 2, hsq _ (by positivity),
    hsq _ (div_nonneg (by linarith) hq0.le)]
  have hval : (1 / (q : ℝ)) ^ (2 : ℕ) + (((q : ℝ) - 1) / (q : ℝ)) ^ (2 : ℕ)
      = ((q : ℝ) ^ 2 - 2 * q + 2) / (q : ℝ) ^ 2 := by
    field_simp
    ring
  rw [hval, Real.logb_div (ne_of_gt hX) (by positivity),
    show ((q : ℝ) ^ 2) = ((q : ℝ)) ^ (2 : ℕ) by norm_num, Real.logb_pow]
  push_cast
  ring

/-! ## 2. The integer inequality behind the gap -/

/-- The real form of the collision-gap inequality for `m ≥ 3`:
`(m+1)^(m+1) · m^m < (m²+1)^(m+1)`.  The proof compares
`((m²+m)/(m²+1))^(m+1)` with `exp 1 < 3 ≤ m`. -/
theorem collision_gap_real {m : ℕ} (hm : 3 ≤ m) :
    ((m : ℝ) + 1) ^ (m + 1) * (m : ℝ) ^ m < ((m : ℝ) ^ 2 + 1) ^ (m + 1) := by
  set M : ℝ := (m : ℝ) with hM
  have hM3 : (3 : ℝ) ≤ M := by rw [hM]; exact_mod_cast hm
  have hM0 : (0 : ℝ) < M := by linarith
  have hden : (0 : ℝ) < M ^ 2 + 1 := by positivity
  set x : ℝ := (M - 1) / (M ^ 2 + 1) with hx
  have hx0 : (0 : ℝ) ≤ x := by
    apply div_nonneg <;> linarith
  have hratio : (M ^ 2 + M) / (M ^ 2 + 1) = 1 + x := by
    rw [hx]
    field_simp
    ring
  have hexp : 1 + x ≤ Real.exp x := by
    have := Real.add_one_le_exp x
    linarith
  have hpow : (1 + x) ^ (m + 1) ≤ (Real.exp x) ^ (m + 1) :=
    pow_le_pow_left₀ (by linarith) hexp _
  have hcast : (((m : ℕ) + 1 : ℕ) : ℝ) = M + 1 := by push_cast [hM]; ring
  have hmul : ((m : ℕ) + 1 : ℕ) * x ≤ 1 := by
    have hprod : ((M + 1) * x) = (M ^ 2 - 1) / (M ^ 2 + 1) := by
      rw [hx]
      field_simp
      ring
    rw [hcast, hprod, div_le_one hden]
    nlinarith
  have hexppow : (Real.exp x) ^ (m + 1) = Real.exp (((m + 1 : ℕ) : ℝ) * x) := by
    rw [Real.exp_nat_mul]
  have hle : Real.exp (((m + 1 : ℕ) : ℝ) * x) ≤ Real.exp 1 := Real.exp_le_exp.2 hmul
  have he3 : Real.exp 1 < 3 := by
    have := Real.exp_one_lt_d9
    linarith
  have hkey : ((M ^ 2 + M) / (M ^ 2 + 1)) ^ (m + 1) < M := by
    rw [hratio]
    calc (1 + x) ^ (m + 1) ≤ (Real.exp x) ^ (m + 1) := hpow
      _ = Real.exp (((m + 1 : ℕ) : ℝ) * x) := hexppow
      _ ≤ Real.exp 1 := hle
      _ < 3 := he3
      _ ≤ M := hM3
  have hpos : (0 : ℝ) < (M ^ 2 + 1) ^ (m + 1) := by positivity
  have hmul2 : (M ^ 2 + M) ^ (m + 1) < M * (M ^ 2 + 1) ^ (m + 1) := by
    have := (mul_lt_mul_of_pos_right hkey hpos)
    rwa [div_pow, div_mul_cancel₀ _ (ne_of_gt (by positivity : (0:ℝ) < (M ^ 2 + 1) ^ (m + 1)))]
      at this
  have hfac : (M ^ 2 + M) ^ (m + 1) = M * ((M + 1) ^ (m + 1) * M ^ m) := by
    have : M ^ 2 + M = (M + 1) * M := by ring
    rw [this, mul_pow, pow_succ M m]
    ring
  rw [hfac] at hmul2
  exact lt_of_mul_lt_mul_left (by linarith [hmul2]) hM0.le

/-- **The collision-gap inequality.**  For every `m ≥ 2`,
`(m+1)^(m+1) · m^m < (m²+1)^(m+1)`; equivalently, with `q = m + 1`,
`q^q (q-1)^(q-1) < (q² - 2q + 2)^q`. -/
theorem collision_gap_nat {m : ℕ} (hm : 2 ≤ m) :
    (m + 1) ^ (m + 1) * m ^ m < (m ^ 2 + 1) ^ (m + 1) := by
  rcases eq_or_lt_of_le hm with h | h
  · subst_vars
    norm_num
  · have h3 : 3 ≤ m := h
    have := collision_gap_real h3
    exact_mod_cast this

/-! ## 3. The strict Shannon–collision separation -/

/-- **The collision entropy is strictly below the Shannon entropy at every prime
degree `q ≥ 3`.**  The separation is certified by the integer inequality
`q^q (q-1)^(q-1) < (q² - 2q + 2)^q`. -/
theorem typeRenyi_two_lt_typeEntropy {q : ℕ} (hq : q.Prime) (hq3 : 3 ≤ q) :
    typeRenyi 2 q < typeEntropy q := by
  obtain ⟨m, rfl⟩ : ∃ m, q = m + 1 := ⟨q - 1, by omega⟩
  have hm2 : 2 ≤ m := by omega
  set M : ℝ := (m : ℝ) with hM
  have hM2 : (2 : ℝ) ≤ M := by rw [hM]; exact_mod_cast hm2
  have hM0 : (0 : ℝ) < M := by linarith
  have hnat := collision_gap_nat hm2
  have hreal : (M + 1) ^ (m + 1) * M ^ m < (M ^ 2 + 1) ^ (m + 1) := by
    rw [hM]; exact_mod_cast hnat
  -- take base-2 logarithms of the integer inequality
  have hL : (0 : ℝ) < (M + 1) ^ (m + 1) * M ^ m := by positivity
  have hlog := Real.logb_lt_logb (b := 2) (by norm_num) hL hreal
  rw [Real.logb_mul (by positivity) (by positivity), Real.logb_pow, Real.logb_pow,
    Real.logb_pow] at hlog
  -- rewrite both entropies
  have hcast : ((m + 1 : ℕ) : ℝ) = M + 1 := by push_cast [hM]; ring
  have hent : typeEntropy (m + 1)
      = Real.logb 2 (M + 1) - (M / (M + 1)) * Real.logb 2 M := by
    rw [typeEntropy_prime_formula hq, hcast]
    congr 2 <;> ring_nf
  have hcol : typeRenyi 2 (m + 1)
      = 2 * Real.logb 2 (M + 1) - Real.logb 2 (M ^ 2 + 1) := by
    rw [typeRenyi_prime_two hq, hcast]
    congr 2
    ring
  rw [hent, hcol]
  have hMpos : (0 : ℝ) < M + 1 := by linarith
  rw [div_mul_eq_mul_div, sub_lt_sub_iff, ← sub_pos]
  push_cast at hlog
  have hstep : 0 < ((M + 1) * Real.logb 2 (M ^ 2 + 1)
      - ((M + 1) * Real.logb 2 (M + 1) + M * Real.logb 2 M)) := by linarith
  have hfinal := div_pos hstep hMpos
  have hrw : ((M + 1) * Real.logb 2 (M ^ 2 + 1)
      - ((M + 1) * Real.logb 2 (M + 1) + M * Real.logb 2 M)) / (M + 1)
      = Real.logb 2 (M ^ 2 + 1) - Real.logb 2 (M + 1)
        - M * Real.logb 2 M / (M + 1) := by
    field_simp
    ring
  rw [hrw] at hfinal
  linarith

/-- At the degree `q = 2` the channel is uniform, so the Rényi orders coincide and
the gap vanishes: the hypothesis `3 ≤ q` above is sharp. -/
theorem typeRenyi_two_eq_typeEntropy_two : typeRenyi 2 2 = typeEntropy 2 := by
  have hcol := typeRenyi_prime_two (q := 2) (by norm_num)
  have hent := typeEntropy_prime_formula (q := 2) (by norm_num)
  norm_num at hcol hent
  rw [hcol, hent]

/-! ## 4. Irrationality of the gap -/

/-- `q = m + 1` does not divide `m² + 1` when `q` is an odd prime: otherwise it
would divide `(m+1)² - (m²+1) = 2m` and hence `2`. -/
theorem succ_not_dvd_sq_add_one {m : ℕ} (hm : 2 ≤ m) : ¬ (m + 1 ∣ m ^ 2 + 1) := by
  intro h
  have hsq : (m + 1) ∣ (m + 1) ^ 2 := dvd_pow_self _ (by norm_num)
  have hdiff : (m + 1) ∣ ((m + 1) ^ 2 - (m ^ 2 + 1)) := Nat.dvd_sub hsq h
  have hval : (m + 1) ^ 2 - (m ^ 2 + 1) = 2 * m := by
    have : (m + 1) ^ 2 = m ^ 2 + 2 * m + 1 := by ring
    omega
  rw [hval] at hdiff
  have h2m2 : (m + 1) ∣ 2 * m + 2 := ⟨2, by ring⟩
  have h2 : (m + 1) ∣ 2 := by
    have hd := Nat.dvd_sub h2m2 hdiff
    rwa [show 2 * m + 2 - 2 * m = 2 by omega] at hd
  have := Nat.le_of_dvd (by norm_num) h2
  omega

/-- **The Shannon–collision gap is irrational at every prime degree `q ≥ 3`.**
Clearing denominators turns a rational value into the integer identity
`(q²-2q+2)^{qb} = 2^A · (q^q (q-1)^{q-1})^b`, which is impossible because the odd
prime `q` divides the right-hand side but not `q² - 2q + 2`. -/
theorem collision_gap_irrational {q : ℕ} (hq : q.Prime) (hq3 : 3 ≤ q) :
    Irrational (typeEntropy q - typeRenyi 2 q) := by
  obtain ⟨m, rfl⟩ : ∃ m, q = m + 1 := ⟨q - 1, by omega⟩
  have hm2 : 2 ≤ m := by omega
  set M : ℝ := (m : ℝ) with hM
  have hM2 : (2 : ℝ) ≤ M := by rw [hM]; exact_mod_cast hm2
  have hM0 : (0 : ℝ) < M := by linarith
  have hnat := collision_gap_nat hm2
  -- the arithmetic obstruction
  have hkey : ∀ A b : ℕ, 0 < b →
      (m ^ 2 + 1) ^ ((m + 1) * b) ≠ 2 ^ A * ((m + 1) ^ (m + 1) * m ^ m) ^ b := by
    intro A b hb h
    have hdvdR : (m + 1) ∣ 2 ^ A * ((m + 1) ^ (m + 1) * m ^ m) ^ b := by
      refine Dvd.dvd.mul_left (dvd_pow ?_ (by omega)) _
      exact Dvd.dvd.mul_right (dvd_pow_self _ (by omega)) _
    rw [← h] at hdvdR
    have hdvd : (m + 1) ∣ m ^ 2 + 1 := hq.dvd_of_dvd_pow hdvdR
    exact succ_not_dvd_sq_add_one hm2 hdvd
  have hgt : (((m + 1) ^ (m + 1) * m ^ m : ℕ) : ℝ) ^ (1 : ℕ)
      < (((m ^ 2 + 1 : ℕ)) : ℝ) ^ (m + 1) := by
    push_cast
    have : ((m : ℝ) + 1) ^ (m + 1) * (m : ℝ) ^ m < ((m : ℝ) ^ 2 + 1) ^ (m + 1) := by
      exact_mod_cast hnat
    simpa using this
  have hirr := irrational_log_combination (u := m ^ 2 + 1)
    (v := (m + 1) ^ (m + 1) * m ^ m) (s := m + 1) (t := 1)
    (by nlinarith [hm2]) (Nat.one_le_iff_ne_zero.2 (by positivity)) hgt
    (fun A b hb => by simpa using hkey A b hb)
  -- expand the logarithm of the composite integer
  have hlogv : Real.logb 2 (((m + 1) ^ (m + 1) * m ^ m : ℕ) : ℝ)
      = (M + 1) * Real.logb 2 (M + 1) + M * Real.logb 2 M := by
    push_cast
    rw [Real.logb_mul (by positivity) (by positivity), Real.logb_pow, Real.logb_pow]
    push_cast [hM]
    ring
  have hlogu : Real.logb 2 ((m ^ 2 + 1 : ℕ) : ℝ) = Real.logb 2 (M ^ 2 + 1) := by
    push_cast [hM]
    ring_nf
  have hcast : ((m + 1 : ℕ) : ℝ) = M + 1 := by push_cast [hM]; ring
  rw [hlogv, hlogu, hcast, Nat.cast_one, one_mul] at hirr
  -- divide by `q = m + 1`
  have hdiv := hirr.div_natCast (m := m + 1) (by omega)
  rw [hcast] at hdiv
  have hent : typeEntropy (m + 1)
      = Real.logb 2 (M + 1) - (M / (M + 1)) * Real.logb 2 M := by
    rw [typeEntropy_prime_formula hq, hcast]
    congr 2 <;> ring_nf
  have hcol : typeRenyi 2 (m + 1)
      = 2 * Real.logb 2 (M + 1) - Real.logb 2 (M ^ 2 + 1) := by
    rw [typeRenyi_prime_two hq, hcast]
    congr 2
    ring
  have hMpos : (0 : ℝ) < M + 1 := by linarith
  have heq : ((M + 1) * Real.logb 2 (M ^ 2 + 1)
      - ((M + 1) * Real.logb 2 (M + 1) + M * Real.logb 2 M)) / (M + 1)
      = typeEntropy (m + 1) - typeRenyi 2 (m + 1) := by
    rw [hent, hcol]
    field_simp
    ring
  rwa [heq] at hdiv

/-! ## 5. The conductor-13 instances -/

/-- The collision entropy of the conductor-13 cyclic cubic channel is `log₂(9/5)`,
recovered here from the general prime-degree formula. -/
theorem conductor13_collision_entropy_value : typeRenyi 2 3 = Real.logb 2 (9 / 5) := by
  rw [typeRenyi_prime_two (q := 3) (by norm_num)]
  have h5 : ((3 : ℕ) : ℝ) ^ 2 - 2 * ((3 : ℕ) : ℝ) + 2 = 5 := by norm_num
  rw [h5]
  have h9 : Real.logb 2 (9 : ℝ) = 2 * Real.logb 2 3 := by
    rw [show (9 : ℝ) = (3 : ℝ) ^ (2 : ℕ) by norm_num, Real.logb_pow]
    push_cast
    ring
  rw [Real.logb_div (by norm_num) (by norm_num), h9]
  norm_num

/-- **The conductor-13 Shannon–collision gap is irrational.**  The exact value is
`log₂ 3 - 2/3 - log₂(9/5) = log₂(5/3) - 2/3`, which is positive by the integer
inequality `108 < 125` and irrational by the unique-factorisation bridge. -/
theorem conductor13_collision_gap_irrational :
    Irrational (Real.logb 2 3 - 2 / 3 - Real.logb 2 (9 / 5)) := by
  have h := collision_gap_irrational (q := 3) (by norm_num) (by norm_num)
  rwa [typeEntropy_three, conductor13_collision_entropy_value] at h

end CyclicSubfield
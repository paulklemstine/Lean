/-
# The divisor spectrum of the staircase family: abundance, perfection, and the NET-47 boundary

Companion to `Catalog/NumberTheory/KneeStaircaseArithmetic.lean`, where the NET-47 knee triple
`{96, 112, 128}` at `(d = 4, ctx = 1024)` was identified with the top of the binary staircase
ladder `stair b j = 2 ^ b (2 ^ j - 1)` together with its top point `2 ^ 7`.

Here we compute the divisor sum of the whole family and classify its members.  The outcome is a
sharp arithmetic dichotomy running straight through the measured data:

* `KneeStaircase.sum_divisors_stair` — `σ(stair b j) = (2^(b+1) - 1) · σ(2^j - 1)`, from the
  2-adic splitting of the staircase normal form.
* `KneeStaircase.stair_abundant` — every staircase number with `2 ≤ j ≤ b` is **abundant**.  Both
  *jittered* knees `96 = stair 5 2` and `112 = stair 4 3` qualify.
* `KneeStaircase.stair_deficient_of_one` — the `j = 1` rungs are the powers of two, which are
  **deficient**.  The *product point* `128 = 2 ^ 7` is one of them
  (`KneeStaircase.net47_product_point_deficient`).
* `KneeStaircase.stair_perfect_of_mersenne_prime` (Euclid direction) and
  `KneeStaircase.stair_perfect_iff` (Euler direction, proved here from scratch for the family):
  for `1 ≤ b`, `stair b j` is **perfect** iff `j = b + 1` and `2 ^ j - 1` is prime.  In
  particular no rung of the weight-7 ladder is perfect (`KneeStaircase.net47_no_knee_perfect`):
  the only candidate `120 = stair 3 4` fails precisely because `15` is composite.
* `KneeStaircase.abundancy_strict_mono_shift` — the abundancy index increases strictly along the
  shift `b ↦ b + 1`, and
* `KneeStaircase.abundancy_tendsto` — a bridge to analysis: along the shift direction the
  abundancy index converges to `2 σ(2^j - 1) / (2^j - 1)`.  The staircase family therefore has a
  *finite* abundancy ceiling for each fixed number of ones; abundance in this family is a
  statement about the ratio of `b` to `j`, not about size.
* `KneeStaircase.net47_jitter_crosses_perfect_boundary` — the reading of the round: the two
  jittered knees are abundant, the product point is deficient.  The ±16 seed jitter observed at
  `(d = 4, ctx = 1024)` moves the knee across the perfect-number boundary.
-/

import Mathlib
import NumberTheory.KneeStaircaseArithmetic

namespace KneeStaircase

open Finset

/-! ## 1.  The divisor sum of a staircase number -/

theorem sum_divisors_two_pow (b : ℕ) : ∑ d ∈ (2 ^ b).divisors, d = 2 ^ (b + 1) - 1 := by
  simp [Nat.sum_divisors_prime_pow (p := 2) Nat.prime_two, Nat.geomSum_eq]

theorem coprime_two_pow_mersenne {b j : ℕ} (hj : 1 ≤ j) : Nat.Coprime (2 ^ b) (2 ^ j - 1) :=
  Nat.Coprime.pow_left _
    ((Nat.Prime.coprime_iff_not_dvd Nat.prime_two).mpr (odd_two_pow_sub_one hj))

/-- **The divisor sum of the staircase family** splits along the binary normal form. -/
theorem sum_divisors_stair {b j : ℕ} (hj : 1 ≤ j) :
    ∑ d ∈ (stair b j).divisors, d
      = (2 ^ (b + 1) - 1) * ∑ d ∈ (2 ^ j - 1).divisors, d := by
  rw [stair, (coprime_two_pow_mersenne (b := b) hj).sum_divisors_mul, sum_divisors_two_pow]

theorem one_le_mersenne {j : ℕ} (hj : 1 ≤ j) : 1 ≤ 2 ^ j - 1 := by
  have h : (2:ℕ) ^ 1 ≤ 2 ^ j := Nat.pow_le_pow_right (by norm_num) hj
  simp only [pow_one] at h
  omega

theorem three_le_mersenne {j : ℕ} (hj : 2 ≤ j) : 3 ≤ 2 ^ j - 1 := by
  have h : (2:ℕ) ^ 2 ≤ 2 ^ j := Nat.pow_le_pow_right (by norm_num) hj
  norm_num at h
  omega

/-- The divisor sum of a positive number is positive (the divisor `1`). -/
theorem one_le_sum_divisors {n : ℕ} (hn : n ≠ 0) : 1 ≤ ∑ d ∈ n.divisors, d :=
  Finset.single_le_sum (f := fun d => d) (fun _ _ => Nat.zero_le _) (Nat.one_mem_divisors.mpr hn)

/-- For `n ≥ 2` the divisor sum exceeds `n` by at least one (the divisor `1`). -/
theorem succ_le_sum_divisors {n : ℕ} (hn : 2 ≤ n) : n + 1 ≤ ∑ d ∈ n.divisors, d := by
  have h1 : (1 : ℕ) ∈ n.properDivisors := Nat.one_mem_properDivisors_iff_one_lt.mpr (by omega)
  have hsum : 1 ≤ ∑ d ∈ n.properDivisors, d :=
    Finset.single_le_sum (f := fun d => d) (fun _ _ => Nat.zero_le _) h1
  have := Nat.sum_divisors_eq_sum_properDivisors_add_self (n := n)
  omega

/-! ## 2.  Abundance -/

/-- **Abundance of the jittered rungs.**  If the staircase has at least two ones and at least as
many trailing zeros as ones, it is abundant.  `96 = stair 5 2` and `112 = stair 4 3` qualify.

The proof is the exact inequality `A·σ(m) ≥ A·(m+1) > (A+1)·m`, valid as soon as the
"zero block" `A = 2^(b+1) - 1` dominates the "one block" `m = 2^j - 1`. -/
theorem stair_abundant {b j : ℕ} (hj : 2 ≤ j) (hbj : j ≤ b) : Nat.Abundant (stair b j) := by
  have hj1 : 1 ≤ j := by omega
  have hm3 : 3 ≤ 2 ^ j - 1 := three_le_mersenne hj
  have hS : (2 ^ j - 1) + 1 ≤ ∑ d ∈ (2 ^ j - 1).divisors, d := succ_le_sum_divisors (by omega)
  rw [Nat.abundant_iff_sum_divisors, sum_divisors_stair hj1, stair]
  set S := ∑ d ∈ (2 ^ j - 1).divisors, d with hSdef
  set M := 2 ^ j - 1 with hMdef
  set P := (2:ℕ) ^ b with hPdef
  set A := (2:ℕ) ^ (b + 1) - 1 with hAdef
  have hP1 : 1 ≤ P := one_le_two_pow b
  have hA : A + 1 = 2 * P := by
    have h1 : (1:ℕ) ≤ 2 ^ (b + 1) := one_le_two_pow _
    have h2 : (2:ℕ) ^ (b + 1) = 2 * P := by rw [hPdef]; ring
    omega
  -- the one block is dominated by the zero block
  have hMP : M + 1 ≤ P := by
    have h1 : (2:ℕ) ^ j ≤ 2 ^ b := Nat.pow_le_pow_right (by norm_num) hbj
    have h2 : (1:ℕ) ≤ 2 ^ j := one_le_two_pow j
    rw [hMdef, hPdef]; omega
  have hMA : M < A := by omega
  calc 2 * (P * M) = (A + 1) * M := by rw [hA]; ring
    _ = A * M + M := by ring
    _ < A * M + A := by omega
    _ = A * (M + 1) := by ring
    _ ≤ A * S := Nat.mul_le_mul_left A hS

/-- The `j = 1` rungs are exactly the powers of two, which are deficient. -/
theorem stair_deficient_of_one (b : ℕ) : Nat.Deficient (stair b 1) := by
  rw [stair_one]
  exact Nat.Prime.deficient_pow Nat.prime_two

/-! ## 3.  Perfection: Euclid and Euler for the staircase family -/

theorem sum_divisors_prime {p : ℕ} (hp : p.Prime) : ∑ d ∈ p.divisors, d = p + 1 := by
  rw [hp.divisors, Finset.sum_pair hp.one_lt.ne]
  omega

/-- **Euclid direction.**  If `2 ^ (b+1) - 1` is prime then the staircase rung with one more one
than trailing zeros is perfect. -/
theorem stair_perfect_of_mersenne_prime {b : ℕ} (hp : Nat.Prime (2 ^ (b + 1) - 1)) :
    Nat.Perfect (stair b (b + 1)) := by
  have hj : 1 ≤ b + 1 := by omega
  have hpos : 0 < stair b (b + 1) := stair_pos hj
  rw [Nat.perfect_iff_sum_divisors_eq_two_mul hpos, sum_divisors_stair hj, sum_divisors_prime hp,
    stair]
  set P := (2:ℕ) ^ b with hPdef
  set A := (2:ℕ) ^ (b + 1) - 1 with hAdef
  have hP1 : 1 ≤ P := one_le_two_pow b
  have hA : A + 1 = 2 * P := by
    have h1 : (1:ℕ) ≤ 2 ^ (b + 1) := one_le_two_pow _
    have h2 : (2:ℕ) ^ (b + 1) = 2 * P := by rw [hPdef]; ring
    omega
  calc A * (A + 1) = A * (2 * P) := by rw [hA]
    _ = 2 * (P * A) := by ring

/-- **Euler direction, proved here for the family.**  For `b ≥ 1` (an even staircase number)
perfection forces the Euclid shape: one more one than trailing zeros, with a *prime* Mersenne
block.  The hypothesis `1 ≤ b` is essential: `b = 0` would be an odd perfect number, whose
existence is open. -/
theorem stair_perfect_iff {b j : ℕ} (hb : 1 ≤ b) (hj : 1 ≤ j) :
    Nat.Perfect (stair b j) ↔ j = b + 1 ∧ Nat.Prime (2 ^ j - 1) := by
  constructor
  · intro hper
    have hpos : 0 < stair b j := stair_pos hj
    have hMpos : 1 ≤ 2 ^ j - 1 := one_le_mersenne hj
    set S := ∑ d ∈ (2 ^ j - 1).divisors, d with hSdef
    set m := 2 ^ j - 1 with hmdef
    set P := (2:ℕ) ^ b with hPdef
    set A := (2:ℕ) ^ (b + 1) - 1 with hAdef
    have hP2 : 2 ≤ P := by
      have : (2:ℕ) ^ 1 ≤ 2 ^ b := Nat.pow_le_pow_right (by norm_num) hb
      simpa [hPdef] using this
    have hA : A + 1 = 2 * P := by
      have h1 : (1:ℕ) ≤ 2 ^ (b + 1) := one_le_two_pow _
      have h2 : (2:ℕ) ^ (b + 1) = 2 * P := by rw [hPdef]; ring
      omega
    have hA3 : 3 ≤ A := by omega
    -- perfection, in the split form
    have hkey : A * S = (A + 1) * m := by
      have h := (Nat.perfect_iff_sum_divisors_eq_two_mul hpos).mp hper
      rw [sum_divisors_stair hj, stair] at h
      rw [hA]
      calc A * S = 2 * (P * m) := h
        _ = 2 * P * m := by ring
    -- `A` is coprime to `A + 1`, hence divides `m`
    have hcop : Nat.Coprime A (A + 1) := by simp [Nat.Coprime]
    obtain ⟨t, ht⟩ : A ∣ m := hcop.dvd_of_dvd_mul_left ⟨S, hkey.symm⟩
    have htpos : 1 ≤ t := by
      rcases Nat.eq_zero_or_pos t with h | h
      · rw [h, mul_zero] at ht; omega
      · exact h
    have hSt : S = (A + 1) * t := by
      refine Nat.eq_of_mul_eq_mul_left (by omega : 0 < A) ?_
      rw [hkey, ht]; ring
    have hprop : ∑ d ∈ m.properDivisors, d = t := by
      have h := Nat.sum_divisors_eq_sum_properDivisors_add_self (n := m)
      rw [← hSdef, hSt] at h
      have hexp : (A + 1) * t = A * t + t := by ring
      omega
    have htlt : t < m := by
      have h3 : 3 * t ≤ A * t := Nat.mul_le_mul_right _ hA3
      omega
    have htmem : t ∈ m.properDivisors :=
      Nat.mem_properDivisors.mpr ⟨⟨A, by rw [ht]; ring⟩, htlt⟩
    have hm2 : 2 ≤ m := by omega
    have ht1 : t = 1 := by
      by_contra hne
      have h1mem : (1:ℕ) ∈ m.properDivisors :=
        Nat.one_mem_properDivisors_iff_one_lt.mpr (by omega)
      have hsub : ({1, t} : Finset ℕ) ⊆ m.properDivisors := by
        intro x hx
        simp only [Finset.mem_insert, Finset.mem_singleton] at hx
        rcases hx with rfl | rfl <;> assumption
      have hpair : ∑ d ∈ ({1, t} : Finset ℕ), d = 1 + t := Finset.sum_pair (Ne.symm hne)
      have hle : ∑ d ∈ ({1, t} : Finset ℕ), d ≤ ∑ d ∈ m.properDivisors, d :=
        Finset.sum_le_sum_of_subset hsub
      omega
    have hprime : Nat.Prime m := by
      rw [← Nat.sum_properDivisors_eq_one_iff_prime, hprop, ht1]
    refine ⟨?_, hprime⟩
    have hmA : m = A := by rw [ht, ht1, mul_one]
    have hpow : (2:ℕ) ^ j = 2 ^ (b + 1) := by
      have h1 : (1:ℕ) ≤ 2 ^ j := one_le_two_pow j
      have h2 : (1:ℕ) ≤ 2 ^ (b + 1) := one_le_two_pow _
      rw [hmdef, hAdef] at hmA
      omega
    exact Nat.pow_right_injective (le_refl 2) hpow
  · rintro ⟨rfl, hp⟩
    exact stair_perfect_of_mersenne_prime hp

/-! ## 4.  The abundancy index along the shift direction -/

/-- **Strict monotonicity of abundancy under doubling.**  Written multiplicatively to stay in `ℕ`:
`σ(k)/k < σ(2k)/(2k)` for `k = stair b j`.  Doubling the zero block always makes the rung more
abundant — the seed jitter `96 → 112 → 128` moves *down* the ladder in this order. -/
theorem abundancy_strict_mono_shift {b j : ℕ} (hj : 1 ≤ j) :
    (∑ d ∈ (stair b j).divisors, d) * stair (b + 1) j
      < (∑ d ∈ (stair (b + 1) j).divisors, d) * stair b j := by
  have hMpos : 1 ≤ 2 ^ j - 1 := one_le_mersenne hj
  have hSpos : 1 ≤ ∑ d ∈ (2 ^ j - 1).divisors, d := one_le_sum_divisors (by omega)
  rw [sum_divisors_stair (b := b) hj, sum_divisors_stair (b := b + 1) hj, stair, stair]
  set S := ∑ d ∈ (2 ^ j - 1).divisors, d with hSdef
  set m := 2 ^ j - 1 with hmdef
  set P := (2:ℕ) ^ b with hPdef
  set A := (2:ℕ) ^ (b + 1) - 1 with hAdef
  set A' := (2:ℕ) ^ (b + 1 + 1) - 1 with hA'def
  have hP1 : 1 ≤ P := one_le_two_pow b
  have hA : A + 1 = 2 * P := by
    have h1 : (1:ℕ) ≤ 2 ^ (b + 1) := one_le_two_pow _
    have h2 : (2:ℕ) ^ (b + 1) = 2 * P := by rw [hPdef]; ring
    omega
  have hA' : A' + 1 = 4 * P := by
    have h1 : (1:ℕ) ≤ 2 ^ (b + 1 + 1) := one_le_two_pow _
    have h2 : (2:ℕ) ^ (b + 1 + 1) = 4 * P := by rw [hPdef]; ring
    omega
  have hAA : A' = 2 * A + 1 := by omega
  have hPA : (2:ℕ) ^ (b + 1) = A + 1 := by
    have h2 : (2:ℕ) ^ (b + 1) = 2 * P := by rw [hPdef]; ring
    omega
  rw [hPA, hAA]
  have hSm : 1 ≤ S * m := Nat.one_le_iff_ne_zero.mpr (by positivity)
  calc A * S * ((A + 1) * m) = (2 * A * P) * (S * m) := by rw [hA]; ring
    _ < (2 * A * P + P) * (S * m) := by
        have : 0 < P * (S * m) := Nat.mul_pos (by omega) (by omega)
        nlinarith
    _ = (2 * A + 1) * S * (P * m) := by ring

/-- **Bridge to analysis.**  For a fixed number of ones `j`, the abundancy index of the staircase
family converges, along the shift `b → ∞`, to `2 σ(2^j - 1)/(2^j - 1)`.  Abundance in the family
is thus capped: the ceiling depends only on `j`, never on the size of the number. -/
theorem abundancy_tendsto {j : ℕ} (hj : 1 ≤ j) :
    Filter.Tendsto
      (fun b : ℕ => (((∑ d ∈ (stair b j).divisors, d : ℕ) : ℝ) / ((stair b j : ℕ) : ℝ)))
      Filter.atTop
      (nhds (2 * ((∑ d ∈ (2 ^ j - 1).divisors, d : ℕ) : ℝ) / (((2:ℕ) ^ j - 1 : ℕ) : ℝ))) := by
  have hmpos : 1 ≤ 2 ^ j - 1 := one_le_mersenne hj
  set S : ℝ := ((∑ d ∈ (2 ^ j - 1).divisors, d : ℕ) : ℝ) with hS
  set M : ℝ := (((2:ℕ) ^ j - 1 : ℕ) : ℝ) with hM
  have hMpos : 0 < M := by rw [hM]; exact_mod_cast hmpos
  have hfun : ∀ b : ℕ,
      (((∑ d ∈ (stair b j).divisors, d : ℕ) : ℝ) / ((stair b j : ℕ) : ℝ))
        = (2 - (1/2 : ℝ) ^ b) * (S / M) := by
    intro b
    have hcast : ((stair b j : ℕ) : ℝ) = (2:ℝ) ^ b * M := by
      rw [stair, hM]; push_cast; ring
    have hnum : ((∑ d ∈ (stair b j).divisors, d : ℕ) : ℝ) = ((2:ℝ) ^ (b + 1) - 1) * S := by
      rw [sum_divisors_stair (b := b) hj, hS]
      push_cast [Nat.cast_sub (one_le_two_pow (b + 1))]
      ring
    rw [hnum, hcast, div_pow, one_pow]
    have h2b : ((2:ℝ) ^ b) ≠ 0 := by positivity
    have hMne : M ≠ 0 := ne_of_gt hMpos
    field_simp
    ring
  have hlim : Filter.Tendsto (fun b : ℕ => (2 - (1/2 : ℝ) ^ b) * (S / M)) Filter.atTop
      (nhds ((2 - 0) * (S / M))) :=
    Filter.Tendsto.mul_const _
      (Filter.Tendsto.const_sub _
        (tendsto_pow_atTop_nhds_zero_of_lt_one (by norm_num) (by norm_num)))
  have hgoal := hlim.congr (fun b => (hfun b).symm)
  have hval : (2 - 0 : ℝ) * (S / M) = 2 * S / M := by ring
  rwa [hval] at hgoal

/-! ## 5.  The NET-47 reading -/

theorem net47_ninetysix_abundant : Nat.Abundant 96 := by
  rw [← net47_ninetysix]; exact stair_abundant (by norm_num) (by norm_num)

theorem net47_onetwelve_abundant : Nat.Abundant 112 := by
  rw [← net47_onetwelve]; exact stair_abundant (by norm_num) (by norm_num)

theorem net47_product_point_deficient : Nat.Deficient 128 := by
  have h := stair_deficient_of_one 7
  rwa [stair_one, show (2:ℕ) ^ 7 = 128 by norm_num] at h

/-- **The jitter crosses the perfect-number boundary.**  The two jittered knees `96, 112` are
abundant; the product point `128` is deficient.  A ±16 shift of the measured knee therefore
changes the arithmetic type of the number. -/
theorem net47_jitter_crosses_perfect_boundary :
    Nat.Abundant 96 ∧ Nat.Abundant 112 ∧ Nat.Deficient 128 :=
  ⟨net47_ninetysix_abundant, net47_onetwelve_abundant, net47_product_point_deficient⟩

/-- No even rung of the weight-7 ladder — in particular no measured knee — is perfect: perfection
in the family forces `j = b + 1`, hence weight `b + j = 2b + 1`, and `7 = 2·3 + 1` leaves only
`b = 3, j = 4`, where the Mersenne block `2^4 - 1 = 15` is composite. -/
theorem net47_no_knee_perfect {b j : ℕ} (hb : 1 ≤ b) (hj : 1 ≤ j) (hw : b + j = 7) :
    ¬ Nat.Perfect (stair b j) := by
  intro hper
  obtain ⟨hjb, hp⟩ := (stair_perfect_iff hb hj).mp hper
  have hb3 : b = 3 := by omega
  have hj4 : j = 4 := by omega
  subst hb3; subst hj4
  norm_num at hp

end KneeStaircase
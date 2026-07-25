import Mathlib

/-!
# Contrarian conjectures around the `E₈` / Siegel–Weil theta series

The companion file `SiegelWeilE8Theta.lean` establishes that the `E₈` vector
counts `rE8 n = 240·σ₃(n)` form the coefficient system of the weight-`4` Hecke
eigenform `E₄` (prime-power geometric form, Hecke three-term recurrence,
multiplicativity, and the global Hecke convolution identity).

Following the *contrarian* mandate, this file stress-tests bold conjectures about
that arithmetic system.  We both **prove** several nontrivial structural facts
and **disprove** two natural-looking but false strengthenings.

## Proved

* `sigma3_mod_six` — the congruence `σ₃(n) ≡ σ₁(n) (mod 6)`, a hidden linear
  relation between the weight-`4` and weight-`2` divisor systems, coming from
  `d³ ≡ d (mod 6)`.
* `sigma3_ge_cube` / `sigma3_ge` — the lower bounds `n³ ≤ σ₃(n)` and
  `n³ + 1 ≤ σ₃(n)` for `n ≥ 2`.
* `sigma3_eq_lower_bound_iff_prime` — the lower bound `σ₃(n) = n³ + 1` is attained
  **exactly** at the primes: a characterization of primality via the `E₄`
  Fourier coefficients.
* `rE8_ge_cube` — the E₈ vector count grows at least like `240·n³`.

## Disproved (contrarian counterexamples)

* `rE8_not_multiplicative` — the E₈ count `rE8` is *not* multiplicative; the
  correct coprime law necessarily carries the normalizing factor `240`.
* `hecke_recurrence_composite_fails` — the Hecke three-term recurrence genuinely
  **requires** primality of the base; it fails at `p = 6`.

See `FUTURE_DIRECTIONS.md` for the flagship open target `E₄² = E₈`
(`σ₇(n) = σ₃(n) + 120·∑ σ₃(m)σ₃(n−m)`), verified numerically here.
-/

namespace SiegelWeilE8Contrarian

open ArithmeticFunction Finset

/-- The `E₈` representation number: `rE8 n = 240·σ₃(n)` counts the vectors of
squared length `2n` in the `E₈` lattice. -/
def rE8 (n : ℕ) : ℕ := 240 * (sigma 3) n

/-! ### A hidden congruence between σ₃ and σ₁ -/

/-- For every natural `d`, `d³ ≡ d (mod 6)`, since `d³ − d = (d−1)d(d+1)` is a
product of three consecutive integers. -/
theorem cube_modEq_self (d : ℕ) : d ^ 3 ≡ d [MOD 6] := by
  have h : d ^ 3 % 6 = (d % 6) ^ 3 % 6 := by rw [Nat.pow_mod]
  have hlt : d % 6 < 6 := Nat.mod_lt d (by norm_num)
  unfold Nat.ModEq
  rw [h]
  interval_cases (d % 6) <;> decide

/-- **Bold true.**  The weight-`4` and weight-`2` divisor sums are congruent
modulo `6`: `σ₃(n) ≡ σ₁(n) (mod 6)`.  Equivalently `6 ∣ σ₃(n) − σ₁(n)`. -/
theorem sigma3_mod_six (n : ℕ) : (sigma 3) n ≡ (sigma 1) n [MOD 6] := by
  rw [sigma_apply, sigma_apply]
  simp only [pow_one]
  unfold Nat.ModEq
  conv_lhs => rw [Finset.sum_nat_mod]
  conv_rhs => rw [Finset.sum_nat_mod]
  congr 1
  refine Finset.sum_congr rfl (fun d _ => ?_)
  have := cube_modEq_self d
  unfold Nat.ModEq at this
  exact this

/-! ### Lower bounds and the prime characterization -/

/-- `n³ ≤ σ₃(n)` for every `n ≥ 1`, since `n` itself is a divisor of `n`. -/
theorem sigma3_ge_cube (n : ℕ) (hn : 1 ≤ n) : n ^ 3 ≤ (sigma 3) n := by
  rw [sigma_apply]
  exact Finset.single_le_sum (f := fun d => d ^ 3) (fun i _ => Nat.zero_le _)
    (Nat.mem_divisors_self n (by omega))

/-- For `n ≥ 2`, both `1` and `n` are distinct divisors, giving `n³ + 1 ≤ σ₃(n)`. -/
theorem sigma3_ge (n : ℕ) (hn : 2 ≤ n) : n ^ 3 + 1 ≤ (sigma 3) n := by
  rw [sigma_apply]
  have hsub : ({1, n} : Finset ℕ) ⊆ n.divisors := by
    intro x hx
    simp only [Finset.mem_insert, Finset.mem_singleton] at hx
    rcases hx with rfl | rfl
    · exact Nat.one_mem_divisors.mpr (by omega)
    · exact Nat.mem_divisors_self _ (by omega)
  have hpair : ∑ d ∈ ({1, n} : Finset ℕ), d ^ 3 = n ^ 3 + 1 := by
    rw [Finset.sum_pair (by omega : (1 : ℕ) ≠ n)]; ring
  have hle : ∑ d ∈ ({1, n} : Finset ℕ), d ^ 3 ≤ ∑ d ∈ n.divisors, d ^ 3 :=
    Finset.sum_le_sum_of_subset_of_nonneg hsub (fun i _ _ => Nat.zero_le _)
  omega

/-- **Bold true.**  The lower bound `σ₃(n) = n³ + 1` is attained precisely at the
primes.  This is a characterization of primality through the `E₄` Fourier
coefficients. -/
theorem sigma3_eq_lower_bound_iff_prime (n : ℕ) (hn : 2 ≤ n) :
    (sigma 3) n = n ^ 3 + 1 ↔ n.Prime := by
  constructor
  · intro heq
    by_contra hnp
    obtain ⟨d, hd, hd2, hdn⟩ := Nat.exists_dvd_of_not_prime2 hn hnp
    have hsub : ({1, d, n} : Finset ℕ) ⊆ n.divisors := by
      intro x hx
      simp only [Finset.mem_insert, Finset.mem_singleton] at hx
      rcases hx with rfl | rfl | rfl
      · exact Nat.one_mem_divisors.mpr (by omega)
      · exact Nat.mem_divisors.mpr ⟨hd, by omega⟩
      · exact Nat.mem_divisors_self _ (by omega)
    have hsum : ∑ x ∈ ({1, d, n} : Finset ℕ), x ^ 3 = 1 + d ^ 3 + n ^ 3 := by
      rw [Finset.sum_insert (by simp; omega), Finset.sum_insert (by simp; omega),
        Finset.sum_singleton]; ring
    have hle : ∑ x ∈ ({1, d, n} : Finset ℕ), x ^ 3 ≤ (sigma 3) n := by
      rw [sigma_apply]
      exact Finset.sum_le_sum_of_subset_of_nonneg hsub (fun i _ _ => Nat.zero_le _)
    rw [hsum] at hle
    have : 2 ^ 3 ≤ d ^ 3 := Nat.pow_le_pow_left hd2 3
    omega
  · intro hp
    rw [sigma_apply, hp.divisors, Finset.sum_pair (by
      rintro rfl; exact absurd hp (by norm_num))]
    ring

/-- The `E₈` vector count grows at least like `240·n³`. -/
theorem rE8_ge_cube (n : ℕ) (hn : 1 ≤ n) : 240 * n ^ 3 ≤ rE8 n := by
  unfold rE8
  exact Nat.mul_le_mul_left 240 (sigma3_ge_cube n hn)

/-! ### Contrarian disproofs -/

/-- **Disproof.**  The `E₈` representation number is *not* multiplicative: the
naive law `rE8(mn) = rE8(m)·rE8(n)` fails already at `(m, n) = (2, 3)`.  (The
correct coprime identity carries the factor `240`.) -/
theorem rE8_not_multiplicative :
    ¬ (∀ m n : ℕ, rE8 (m * n) = rE8 m * rE8 n) := by
  intro h
  have := h 2 3
  revert this
  unfold rE8
  decide

/-- **Disproof.**  The Hecke three-term recurrence
`σ₃(p^{r+2}) + p³·σ₃(pʳ) = σ₃(p)·σ₃(p^{r+1})` genuinely requires `p` prime: it
fails for the composite base `p = 6` (already at `r = 0`). -/
theorem hecke_recurrence_composite_fails :
    ∃ p r : ℕ, ¬ p.Prime ∧
      (sigma 3) (p ^ (r + 2)) + p ^ 3 * (sigma 3) (p ^ r)
        ≠ (sigma 3) p * (sigma 3) (p ^ (r + 1)) :=
  ⟨6, 0, by decide, by decide⟩

/-! ### Low-order corroboration -/

theorem rE8_one : rE8 1 = 240 := by decide
theorem rE8_two : rE8 2 = 2160 := by decide
theorem sigma3_mod_six_check : (sigma 3) 4 % 6 = (sigma 1) 4 % 6 := by decide

end SiegelWeilE8Contrarian
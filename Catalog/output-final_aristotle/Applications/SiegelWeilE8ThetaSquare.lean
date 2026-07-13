import Mathlib

/-!
# The `E₄² = E₈` shadow of the Siegel–Weil identity: a weight-`8` congruence

The Siegel–Weil identity in rank `8` states that the theta series of the even
unimodular lattice `E₈` equals the weight-`4` Eisenstein series `E₄`; at the
level of Fourier coefficients this reads

```
r(n) = 240 · σ₃(n),      σ₃(n) = ∑_{d ∣ n} d³,
```

where `r(n)` counts the lattice vectors of squared length `2n`.  Squaring this
identity gives the rank-`16` genus statement `E₄² = E₈` (the weight-`8`
Eisenstein series), whose coefficient form is the classical convolution law

```
σ₇(n) = σ₃(n) + 120 · ∑_{i=1}^{n-1} σ₃(i)·σ₃(n-i).
```

This file isolates and *proves* the arithmetic shadow of that convolution law:
the congruence

```
σ₇(n) ≡ σ₃(n)   (mod 120)      for every n,
```

which is exactly the statement that the correction term `120·(convolution)`
above is invisible modulo `120`.  In other words, the weight-`8` divisor system
and the weight-`4` divisor system — the coefficient systems of `E₈` and `E₄`
respectively — are indistinguishable modulo `120`.

The proof is genuinely arithmetic and modular:

* the pointwise congruence `d⁷ ≡ d³ (mod 120)` is established locally at the
  prime powers `8, 3, 5` dividing `120` (`pow7_pow3_mod8/3/5`) and glued by the
  Chinese Remainder Theorem (`pow7_pow3_mod120`);
* summing over divisors lifts this to `σ₇ ≡ σ₃ (mod 120)`
  (`sigma7_modEq_sigma3`);
* we record the integral divisibility corollary
  (`sigma7_sub_sigma3_dvd`) and show `120` is the **optimal** modulus:
  the congruence *fails* modulo `240` (`sigma7_not_modEq_sigma3_mod240`),
  pinpointing `120` as the exact arithmetic weight of the `E₄² = E₈` correction.

-- !-- Lab Notes -- !--
Hypothesis: Squaring `θ_{E₈} = E₄` yields `E₄² = E₈`, whose coefficient identity
  `σ₇ = σ₃ + 120·(σ₃ ⋆ σ₃)` should leave a clean, fully-elementary residue:
  `σ₇ ≡ σ₃ (mod 120)`.  We conjecture `120` is exactly optimal.
Experiment: Prove the pointwise power congruence `d⁷ ≡ d³` locally modulo the
  prime-power factors `8, 3, 5` of `120` by finite case analysis on residues,
  glue with CRT, then sum over divisors.  Test optimality at `n = 2`.
Analysis: The gluing works because `8, 3, 5` are pairwise coprime with product
  `120`.  The correction term of `E₄² = E₈` carries the literal factor `120`, so
  its residue vanishes mod `120` but not mod `240` — confirmed at `n = 2`, where
  `σ₇(2) - σ₃(2) = 129 - 9 = 120`.
Critique: The main congruence is not definitional — it rests on a genuine
  CRT gluing of three residue computations and a divisor-sum congruence, and the
  optimality direction is a real counterexample, not a vacuous statement.
Synthesis: Modulo `120`, the weight-`8` and weight-`4` Eisenstein coefficient
  systems coincide; `120` is the precise arithmetic size of the `E₄² = E₈`
  self-convolution correction, and the value is sharp.
-/

namespace SiegelWeilE8ThetaSquare

open ArithmeticFunction Finset

/-! ### Local power congruences at the prime powers dividing `120`

The heart of the argument is the pointwise identity `d⁷ ≡ d³` modulo each of the
pairwise-coprime factors `8, 3, 5` of `120`.  Each is a finite check on residue
classes, powered by `d^k % m = (d % m)^k % m`. -/

/-- `d⁷ ≡ d³ (mod 8)`: at the `2`-part, either `8 ∣ d³` (when `d` is even) or
`d⁴ ≡ 1 (mod 8)` (when `d` is odd). -/
theorem pow7_pow3_mod8 (d : ℕ) : d ^ 7 ≡ d ^ 3 [MOD 8] := by
  have h7 : d ^ 7 % 8 = (d % 8) ^ 7 % 8 := by rw [Nat.pow_mod]
  have h3 : d ^ 3 % 8 = (d % 8) ^ 3 % 8 := by rw [Nat.pow_mod]
  unfold Nat.ModEq; rw [h7, h3]
  have : d % 8 < 8 := Nat.mod_lt _ (by norm_num)
  interval_cases (d % 8) <;> decide

/-- `d⁷ ≡ d³ (mod 3)`: Fermat's little theorem gives `d² ≡ 1`, hence `d⁴ ≡ 1`,
for `d` coprime to `3`. -/
theorem pow7_pow3_mod3 (d : ℕ) : d ^ 7 ≡ d ^ 3 [MOD 3] := by
  have h7 : d ^ 7 % 3 = (d % 3) ^ 7 % 3 := by rw [Nat.pow_mod]
  have h3 : d ^ 3 % 3 = (d % 3) ^ 3 % 3 := by rw [Nat.pow_mod]
  unfold Nat.ModEq; rw [h7, h3]
  have : d % 3 < 3 := Nat.mod_lt _ (by norm_num)
  interval_cases (d % 3) <;> decide

/-- `d⁷ ≡ d³ (mod 5)`: Fermat's little theorem gives `d⁴ ≡ 1` for `d` coprime
to `5`. -/
theorem pow7_pow3_mod5 (d : ℕ) : d ^ 7 ≡ d ^ 3 [MOD 5] := by
  have h7 : d ^ 7 % 5 = (d % 5) ^ 7 % 5 := by rw [Nat.pow_mod]
  have h3 : d ^ 3 % 5 = (d % 5) ^ 3 % 5 := by rw [Nat.pow_mod]
  unfold Nat.ModEq; rw [h7, h3]
  have : d % 5 < 5 := Nat.mod_lt _ (by norm_num)
  interval_cases (d % 5) <;> decide

/-- **Global power congruence.**  `d⁷ ≡ d³ (mod 120)` for every `d`, obtained by
gluing the local congruences modulo `8`, `3`, `5` via the Chinese Remainder
Theorem (`120 = 8 · 3 · 5` with pairwise-coprime factors). -/
theorem pow7_pow3_mod120 (d : ℕ) : d ^ 7 ≡ d ^ 3 [MOD 120] := by
  have h15 : d ^ 7 ≡ d ^ 3 [MOD 15] :=
    (Nat.modEq_and_modEq_iff_modEq_mul (by decide)).mp ⟨pow7_pow3_mod3 d, pow7_pow3_mod5 d⟩
  have h120 : d ^ 7 ≡ d ^ 3 [MOD 8 * 15] :=
    (Nat.modEq_and_modEq_iff_modEq_mul (by decide)).mp ⟨pow7_pow3_mod8 d, h15⟩
  simpa using h120

/-! ### The weight-`8` / weight-`4` congruence -/

/-- **The `E₄² = E₈` congruence shadow.**  For every `n`,
`σ₇(n) ≡ σ₃(n) (mod 120)`.  This is the arithmetic residue of the weight-`8`
convolution identity `σ₇ = σ₃ + 120·(σ₃ ⋆ σ₃)` coming from `E₄² = E₈`: the
self-convolution correction is invisible modulo `120`, so the weight-`8` and
weight-`4` Eisenstein coefficient systems coincide there. -/
theorem sigma7_modEq_sigma3 (n : ℕ) : (sigma 7) n ≡ (sigma 3) n [MOD 120] := by
  rw [sigma_apply, sigma_apply]
  unfold Nat.ModEq
  conv_lhs => rw [Finset.sum_nat_mod]
  conv_rhs => rw [Finset.sum_nat_mod]
  congr 1
  refine Finset.sum_congr rfl (fun d _ => ?_)
  have := pow7_pow3_mod120 d
  unfold Nat.ModEq at this
  exact this

/-- The weight-`8` divisor sum dominates the weight-`4` one termwise. -/
theorem sigma3_le_sigma7 (n : ℕ) : (sigma 3) n ≤ (sigma 7) n := by
  rw [sigma_apply, sigma_apply]
  refine Finset.sum_le_sum (fun d hd => ?_)
  exact Nat.pow_le_pow_right (Nat.pos_of_mem_divisors hd) (by norm_num)

/-- **Integral divisibility form.**  `120 ∣ σ₇(n) − σ₃(n)` in `ℤ`; the difference
is `120` times the self-convolution `∑_{i} σ₃(i)·σ₃(n-i)`. -/
theorem sigma7_sub_sigma3_dvd (n : ℕ) :
    (120 : ℤ) ∣ ((sigma 7) n : ℤ) - (sigma 3) n := by
  have h := (sigma7_modEq_sigma3 n).symm
  simpa using (Nat.modEq_iff_dvd (n := 120)).mp h

/-- **Optimality / contrarian boundary.**  The congruence is sharp: it does *not*
hold modulo `240`.  At `n = 2` we have `σ₇(2) − σ₃(2) = 129 − 9 = 120`, which is
divisible by `120` but not by `240`.  Thus `120` is exactly the arithmetic weight
of the `E₄² = E₈` correction term. -/
theorem sigma7_not_modEq_sigma3_mod240 :
    ¬ ∀ n, (sigma 7) n ≡ (sigma 3) n [MOD 240] := by
  intro h
  have := h 2
  revert this
  decide

/-! ### Transport to the `E₈` / `E₈ ⊕ E₈` representation numbers -/

/-- The `E₈` representation number: `rE8 n = 240·σ₃(n)` counts the vectors of
squared length `2n` in the `E₈` lattice. -/
def rE8 (n : ℕ) : ℕ := 240 * (sigma 3) n

/-- The weight-`8` companion count `sE n = 240·σ₇(n)` is the coefficient system
of the Eisenstein series `E₈`. -/
def sE (n : ℕ) : ℕ := 240 * (sigma 7) n

/-- The two Eisenstein coefficient systems differ by a multiple of `240·120 =
28800`: scaling the weight-`8` congruence by the normalizing factor `240`. -/
theorem sE_sub_rE8_dvd (n : ℕ) : (28800 : ℤ) ∣ (sE n : ℤ) - rE8 n := by
  have h := sigma7_sub_sigma3_dvd n
  have hmul : (240 * 120 : ℤ) ∣ 240 * (((sigma 7) n : ℤ) - (sigma 3) n) :=
    mul_dvd_mul_left (240 : ℤ) h
  have heq : (sE n : ℤ) - rE8 n = 240 * (((sigma 7) n : ℤ) - (sigma 3) n) := by
    simp only [sE, rE8, Nat.cast_mul, Nat.cast_ofNat]; ring
  rw [heq]
  norm_num at hmul ⊢
  exact hmul

end SiegelWeilE8ThetaSquare
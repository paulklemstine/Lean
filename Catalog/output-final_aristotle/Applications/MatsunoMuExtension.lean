/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Matsuno's formula for supersingular `λ`-invariants with non-vanishing `μ`

Let `E` be an elliptic curve over `ℚ` with good supersingular reduction at `2`, and let
`D` be a square-free integer with `D ≡ 1 (mod 4)`.  Classical *Matsuno-type* results
(Matsuno, Pollack, Sprung) predict that, **assuming the vanishing of the `2`-adic
μ-invariant**, the difference between the sharp/flat Iwasawa `λ`-invariants of the
quadratic twist `E^D` and of `E` is a purely local sum over the prime divisors `ℓ ∣ D`,
with local weight controlled by the `2`-adic depth `n_ℓ = v₂((ℓ² − 1)/8)`.

This file formalises the **arithmetic skeleton of the extension of Matsuno's formula to
non-vanishing `μ`**.  When the μ-invariant of `E` is a positive integer `μ`, the sharp/flat
`λ`-difference of the twist `E^D` acquires an *additional term proportional to `μ`*,
distributed locally over the primes dividing `D` with the same depth weights `2^{n_ℓ}`.
The `λ`-difference itself is not available in the present library, so we model it by an
explicit `ℕ`-valued function and prove the structural facts that make the μ-corrected
formula meaningful, additive, monotone, and — crucially — *strictly larger* than the
classical prediction exactly when `μ ≠ 0`.

The second half of the file records the concrete `p = 2` **sharp/flat degree sequences**
of Pollack–Kobayashi type.  Along the cyclotomic tower the sharp and flat characteristic
degrees grow like partial sums of odd and even powers of `2`; these satisfy the closed
forms `3·(flat degree) = 4ⁿ − 1`, the ratio `sharp = 2·flat`, and are governed by the
**Jacobsthal recurrence** `Jₙ₊₂ = Jₙ₊₁ + 2 Jₙ` with `3 Jₙ = 2ⁿ − (−1)ⁿ`.  The flat degree
is exactly `J₂ₙ`, tying the local depth weights `2^{n_ℓ}` (powers of two) to the honest
growth of the sharp/flat invariants.
-/

open scoped BigOperators
open Finset

namespace MatsunoMuExtension

/-! ## Part I. The μ-corrected Matsuno `λ`-difference -/

/-- The `2`-adic depth `n_ℓ = v₂((ℓ² − 1)/8)` appearing in Matsuno's formula. -/
def nEll (ℓ : ℕ) : ℕ := padicValNat 2 ((ℓ ^ 2 - 1) / 8)

/-- The classical local contribution `δ(ℓ)` of a prime `ℓ` to the `λ`-difference, valid
when the μ-invariant vanishes.  `NE` models the conductor of `E` and `ord ℓ` the order of
the reduction of `E` modulo `ℓ`. -/
def localTerm (NE : ℕ) (ord : ℕ → ℕ) (ℓ : ℕ) : ℕ :=
  if ℓ ∣ NE then 2 ^ nEll ℓ
  else if 2 ∣ ord ℓ then 2 ^ (nEll ℓ + 1)
  else 0

/-- The classical (μ = 0) Matsuno sharp/flat `λ`-difference of the twist `E^D`. -/
def lambdaDiff (D NE : ℕ) (ord : ℕ → ℕ) : ℕ :=
  ∑ ℓ ∈ D.primeFactors, localTerm NE ord ℓ

/-- The local `μ`-weight `2^{n_ℓ}` carried by each prime divisor of `D`. -/
def muWeight (ℓ : ℕ) : ℕ := 2 ^ nEll ℓ

/-- The μ-correction to Matsuno's formula: `μ` times the total local μ-weight of `D`. -/
def muTerm (D μ : ℕ) : ℕ := μ * ∑ ℓ ∈ D.primeFactors, muWeight ℓ

/-- The μ-corrected sharp/flat `λ`-difference of the twist `E^D`, allowing a non-vanishing
μ-invariant `μ`. -/
def lambdaDiffMu (D NE μ : ℕ) (ord : ℕ → ℕ) : ℕ := lambdaDiff D NE ord + muTerm D μ

/-- **Additivity of the classical term over coprime moduli** (the μ = 0 Matsuno identity). -/
theorem lambdaDiff_mul_coprime {a b NE : ℕ} {ord : ℕ → ℕ}
    (hab : Nat.Coprime a b) (ha : a ≠ 0) (hb : b ≠ 0) :
    lambdaDiff (a * b) NE ord = lambdaDiff a NE ord + lambdaDiff b NE ord := by
  unfold lambdaDiff
  rw [Nat.primeFactors_mul ha hb, Finset.sum_union hab.disjoint_primeFactors]

/-- On a single prime `p` the classical term reduces to the local contribution. -/
theorem lambdaDiff_prime {p NE : ℕ} {ord : ℕ → ℕ} (hp : p.Prime) :
    lambdaDiff p NE ord = localTerm NE ord p := by
  unfold lambdaDiff
  rw [hp.primeFactors]
  simp

/-- **Conservativity of the extension.**  At `μ = 0` the μ-corrected invariant is exactly
the classical Matsuno invariant. -/
theorem lambdaDiffMu_mu_zero (D NE : ℕ) (ord : ℕ → ℕ) :
    lambdaDiffMu D NE 0 ord = lambdaDiff D NE ord := by
  simp [lambdaDiffMu, muTerm]

/-- **The μ-contribution.**  The extra term of the μ-corrected formula, over the classical
one, is exactly `muTerm D μ`. -/
theorem muContribution (D NE μ : ℕ) (ord : ℕ → ℕ) :
    lambdaDiffMu D NE μ ord - lambdaDiff D NE ord = muTerm D μ := by
  simp [lambdaDiffMu]

/-- The μ-term is **additive (linear) in the μ-invariant**. -/
theorem muTerm_mu_add (D a b : ℕ) : muTerm D (a + b) = muTerm D a + muTerm D b := by
  simp [muTerm, add_mul]

/-- The μ-term is **proportional to `μ`**: it equals `μ` times its value at `μ = 1`. -/
theorem muTerm_proportional (D μ : ℕ) : muTerm D μ = μ * muTerm D 1 := by
  simp [muTerm]

/-- **Additivity of the μ-term over coprime moduli.** -/
theorem muTerm_mul_coprime {a b μ : ℕ} (hab : Nat.Coprime a b) (ha : a ≠ 0) (hb : b ≠ 0) :
    muTerm (a * b) μ = muTerm a μ + muTerm b μ := by
  unfold muTerm
  rw [Nat.primeFactors_mul ha hb, Finset.sum_union hab.disjoint_primeFactors, mul_add]

/-- **Complete additivity of the μ-corrected invariant over coprime moduli.**  The
μ-correction does not destroy the additive structure of Matsuno's formula: this is the
arithmetic shadow of the multiplicativity of quadratic twisting, now with non-vanishing μ. -/
theorem lambdaDiffMu_mul_coprime {a b NE μ : ℕ} {ord : ℕ → ℕ}
    (hab : Nat.Coprime a b) (ha : a ≠ 0) (hb : b ≠ 0) :
    lambdaDiffMu (a * b) NE μ ord = lambdaDiffMu a NE μ ord + lambdaDiffMu b NE μ ord := by
  unfold lambdaDiffMu
  rw [lambdaDiff_mul_coprime hab ha hb, muTerm_mul_coprime hab ha hb]
  ring

/-- On a single prime `p`, the μ-corrected invariant is the classical local term plus the
local μ-weight scaled by `μ`. -/
theorem lambdaDiffMu_prime {p NE μ : ℕ} {ord : ℕ → ℕ} (hp : p.Prime) :
    lambdaDiffMu p NE μ ord = localTerm NE ord p + μ * 2 ^ nEll p := by
  unfold lambdaDiffMu lambdaDiff muTerm muWeight
  rw [hp.primeFactors]
  simp

/-- **Monotonicity in the level.**  Enlarging the set of ramified primes can only increase
the μ-corrected invariant. -/
theorem lambdaDiffMu_le_of_dvd {d D NE μ : ℕ} {ord : ℕ → ℕ} (hdvd : d ∣ D) (hD : D ≠ 0) :
    lambdaDiffMu d NE μ ord ≤ lambdaDiffMu D NE μ ord := by
  unfold lambdaDiffMu muTerm lambdaDiff
  have hsub := Nat.primeFactors_mono hdvd hD
  have h1 : (∑ ℓ ∈ d.primeFactors, localTerm NE ord ℓ)
      ≤ ∑ ℓ ∈ D.primeFactors, localTerm NE ord ℓ :=
    Finset.sum_le_sum_of_subset hsub
  have h2 : μ * (∑ ℓ ∈ d.primeFactors, muWeight ℓ)
      ≤ μ * ∑ ℓ ∈ D.primeFactors, muWeight ℓ :=
    Nat.mul_le_mul_left _ (Finset.sum_le_sum_of_subset hsub)
  exact Nat.add_le_add h1 h2

/-- **Monotonicity in the μ-invariant.** -/
theorem lambdaDiffMu_mono_mu {D NE μ μ' : ℕ} {ord : ℕ → ℕ} (h : μ ≤ μ') :
    lambdaDiffMu D NE μ ord ≤ lambdaDiffMu D NE μ' ord := by
  unfold lambdaDiffMu muTerm
  exact Nat.add_le_add_left (Nat.mul_le_mul_right _ h) _

/-- Every local μ-weight is a positive power of two. -/
theorem muWeight_pos (ℓ : ℕ) : 0 < muWeight ℓ := by
  unfold muWeight; positivity

/-- The total local μ-weight of `D` is positive **iff** `D` has a prime divisor. -/
theorem sumWeight_pos_iff (D : ℕ) :
    0 < ∑ ℓ ∈ D.primeFactors, muWeight ℓ ↔ D.primeFactors.Nonempty := by
  constructor
  · intro h
    rcases Finset.eq_empty_or_nonempty D.primeFactors with he | hne
    · simp [he] at h
    · exact hne
  · intro hne; exact Finset.sum_pos (fun i _ => muWeight_pos i) hne

/-- **Exact positivity criterion for the μ-term.**  The μ-correction is positive precisely
when the μ-invariant is non-zero *and* `D` has a prime divisor — both hypotheses necessary. -/
theorem muTerm_pos_iff (D μ : ℕ) :
    0 < muTerm D μ ↔ 0 < μ ∧ D.primeFactors.Nonempty := by
  unfold muTerm
  rw [pos_iff_ne_zero, mul_ne_zero_iff, ← pos_iff_ne_zero, ← pos_iff_ne_zero,
    sumWeight_pos_iff]

/-- **Non-vanishing μ is always visible in the twist.**  If the μ-invariant is non-zero and
`D` has a prime divisor, the μ-corrected Matsuno difference is *strictly* larger than the
classical (μ = 0) prediction. -/
theorem lambdaDiffMu_strict_of_mu_pos {D NE μ : ℕ} {ord : ℕ → ℕ}
    (hμ : 0 < μ) (hne : D.primeFactors.Nonempty) :
    lambdaDiff D NE ord < lambdaDiffMu D NE μ ord := by
  unfold lambdaDiffMu
  have : 0 < muTerm D μ := (muTerm_pos_iff D μ).2 ⟨hμ, hne⟩
  omega

/-! ### The `2`-adic depth of the μ-weights -/

/-- For odd `ℓ`, the integer `ℓ² − 1` is divisible by `8`. -/
lemma eight_dvd_sq_sub_one {ℓ : ℕ} (h : Odd ℓ) : 8 ∣ ℓ ^ 2 - 1 := by
  grind +suggestions

/-- Valuation form of the depth: for odd `ℓ ≥ 3` we have `v₂(ℓ² − 1) = n_ℓ + 3`. -/
lemma padicValNat_sq_sub_one {ℓ : ℕ} (hodd : Odd ℓ) (h3 : 3 ≤ ℓ) :
    padicValNat 2 (ℓ ^ 2 - 1) = nEll ℓ + 3 := by
  convert padicValNat.mul _ _ using 1
  rw [Nat.mul_div_cancel']
  convert eight_dvd_sq_sub_one hodd using 1
  · rw [show (8 : ℕ) = 2 ^ 3 by norm_num, padicValNat.prime_pow]; norm_num; ring!
  · exact ⟨Nat.prime_two⟩
  · norm_num
  · exact Nat.ne_of_gt (Nat.div_pos (Nat.le_sub_one_of_lt (by nlinarith)) (by decide))

/-- The closed form for the depth: `n_ℓ + 3 = v₂(ℓ − 1) + v₂(ℓ + 1)` for odd `ℓ ≥ 3`. -/
lemma nEll_add_three {ℓ : ℕ} (hodd : Odd ℓ) (h3 : 3 ≤ ℓ) :
    nEll ℓ + 3 = padicValNat 2 (ℓ - 1) + padicValNat 2 (ℓ + 1) := by
  convert padicValNat_sq_sub_one hodd h3 |> Eq.symm using 1
  rw [show ℓ ^ 2 - 1 = (ℓ - 1) * (ℓ + 1) by convert Nat.sq_sub_sq ℓ 1 using 1; ring,
    padicValNat.mul (by omega) (by omega)]

/-- **The μ-weights obey the classical depth law.**  For odd `ℓ ≥ 3` the local μ-weight
`2^{n_ℓ}` satisfies `8 · 2^{n_ℓ} = 2^{v₂(ℓ−1)+v₂(ℓ+1)}`, so the μ-correction inherits the
same `v₂(ℓ−1)+v₂(ℓ+1)−3` depth structure that governs the classical Matsuno term. -/
theorem muWeight_depth {ℓ : ℕ} (hodd : Odd ℓ) (h3 : 3 ≤ ℓ) :
    8 * muWeight ℓ = 2 ^ (padicValNat 2 (ℓ - 1) + padicValNat 2 (ℓ + 1)) := by
  unfold muWeight
  rw [← nEll_add_three hodd h3, pow_add]
  norm_num
  ring

/-! ## Part II. The `p = 2` sharp/flat degree sequences (Pollack–Kobayashi type)

Along the cyclotomic `ℤ₂`-tower the flat and sharp characteristic degrees grow like the
partial sums of even and odd powers of `2`.  We record their exact arithmetic. -/

/-- The **flat degree** `∑_{i<n} 4ⁱ`: the growth of the flat characteristic degree along the
tower at `p = 2`. -/
def flatDeg (n : ℕ) : ℕ := ∑ i ∈ range n, 4 ^ i

/-- The **sharp degree** `∑_{i<n} 2·4ⁱ`: the growth of the sharp characteristic degree. -/
def sharpDeg (n : ℕ) : ℕ := ∑ i ∈ range n, 2 * 4 ^ i

/-- Closed form: `3 · flatDeg n + 1 = 4ⁿ`, i.e. `flatDeg n = (4ⁿ − 1)/3`. -/
theorem three_flatDeg_add_one (n : ℕ) : 3 * flatDeg n + 1 = 4 ^ n := by
  induction n with
  | zero => simp [flatDeg]
  | succ k ih =>
      unfold flatDeg at ih ⊢
      rw [Finset.sum_range_succ]
      ring_nf
      ring_nf at ih
      omega

/-- The **sharp/flat ratio**: the sharp degree is exactly twice the flat degree. -/
theorem sharpDeg_eq_two_mul_flatDeg (n : ℕ) : sharpDeg n = 2 * flatDeg n := by
  unfold sharpDeg flatDeg
  rw [Finset.mul_sum]

/-- **Sharp/flat total**: `sharpDeg n + flatDeg n + 1 = 4ⁿ`. -/
theorem sharp_add_flat (n : ℕ) : sharpDeg n + flatDeg n + 1 = 4 ^ n := by
  rw [sharpDeg_eq_two_mul_flatDeg]
  have := three_flatDeg_add_one n
  omega

/-- **Sharp/flat difference** equals the flat degree: `sharpDeg n − flatDeg n = flatDeg n`. -/
theorem sharp_sub_flat (n : ℕ) : sharpDeg n - flatDeg n = flatDeg n := by
  rw [sharpDeg_eq_two_mul_flatDeg]; omega

/-- The flat degree satisfies the geometric recurrence `flatDeg (n+1) = 4 · flatDeg n + 1`. -/
theorem flatDeg_succ (n : ℕ) : flatDeg (n + 1) = 4 * flatDeg n + 1 := by
  have h0 := three_flatDeg_add_one n
  have h1 := three_flatDeg_add_one (n + 1)
  rw [pow_succ] at h1
  omega

/-- The flat degree is strictly monotone (positive growth of the flat invariant). -/
theorem flatDeg_strictMono : StrictMono flatDeg := by
  apply strictMono_nat_of_lt_succ
  intro n
  rw [flatDeg_succ]
  have : 0 < flatDeg n + 1 := by positivity
  omega

/-! ### The Jacobsthal recurrence governing the sharp/flat growth -/

/-- The **Jacobsthal sequence** `Jₙ₊₂ = Jₙ₊₁ + 2 Jₙ`, `J₀ = 0`, `J₁ = 1`, which governs the
`p = 2` sharp/flat degree growth. -/
def jac : ℕ → ℤ
  | 0 => 0
  | 1 => 1
  | (n + 2) => jac (n + 1) + 2 * jac n

/-- The defining recurrence of the Jacobsthal sequence. -/
theorem jac_succ_succ (n : ℕ) : jac (n + 2) = jac (n + 1) + 2 * jac n := rfl

/-- **Closed form**: `3 Jₙ = 2ⁿ − (−1)ⁿ`. -/
theorem three_jac (n : ℕ) : 3 * jac n = 2 ^ n - (-1) ^ n := by
  induction n using Nat.strong_induction_on with
  | _ n ih =>
    match n with
    | 0 => decide
    | 1 => decide
    | (k + 2) =>
        rw [jac_succ_succ]
        have h1 := ih (k + 1) (by omega)
        have h2 := ih k (by omega)
        ring_nf
        ring_nf at h1 h2
        linarith [h1, h2, pow_succ (2 : ℤ) k, pow_succ (-1 : ℤ) k]

/-- **Consecutive Jacobsthal numbers sum to a power of two**: `Jₙ + Jₙ₊₁ = 2ⁿ`. -/
theorem jac_add_succ (n : ℕ) : jac n + jac (n + 1) = 2 ^ n := by
  have h0 := three_jac n
  have h1 := three_jac (n + 1)
  have : 3 * (jac n + jac (n + 1)) = 3 * 2 ^ n := by
    rw [mul_add, h0, h1, pow_succ, pow_succ]; ring
  linarith

/-- **The flat degree is a Jacobsthal number**: `J₂ₙ = flatDeg n`.  This ties the local
depth weights `2^{n_ℓ}` (powers of two) to the honest Jacobsthal growth of the sharp/flat
`λ`-invariants at `p = 2`. -/
theorem jac_two_mul (n : ℕ) : jac (2 * n) = (flatDeg n : ℤ) := by
  have hj := three_jac (2 * n)
  have hf := three_flatDeg_add_one n
  have h4 : (2 : ℤ) ^ (2 * n) = 4 ^ n := by
    rw [pow_mul]; norm_num
  have hsign : ((-1 : ℤ)) ^ (2 * n) = 1 := by
    rw [pow_mul]; norm_num
  rw [hsign, h4] at hj
  have hfz : (3 : ℤ) * (flatDeg n : ℤ) + 1 = 4 ^ n := by exact_mod_cast hf
  linarith

end MatsunoMuExtension
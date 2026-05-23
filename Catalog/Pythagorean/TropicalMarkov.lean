/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib
import Pythagorean.CohenLenstra.Theorems

/-!
# Tropical Valuation Markov Property

This file formalizes the connection between p-adic valuation, tropical geometry,
and stochastic processes. The central insight is:

> **The valuation stratification of a p-adic random variable defines a tropical
> Markov process on the min-plus semiring, and this process is the arithmetic
> shadow of Haar self-similarity.**

## Main Definitions

* `TropicalMarkov.IsTropicalMemoryless` — A function `f : ℕ → ℝ` satisfying the
  multiplicative Cauchy equation `f(k+j) = f(k) · f(j)`.
* `TropicalMarkov.padicValTail` — The p-adic valuation tail probability: `T_p(k) = p⁻ᵏ`.
* `TropicalMarkov.condTailProb` — Conditional tail probability: `T(a) / T(b)` for `b ≤ a`.
* `TropicalMarkov.valuationEnergy` — Information-theoretic energy: `E_p(k) = k · log(p)`.
* `TropicalMarkov.condPointProb` — Conditional point probability for the Markov property.

## Main Results

1. **`memoryless_tail_classification`**: Any multiplicative function on ℕ with `f(0) = 1`
   satisfies `f(n) = f(1)^n`. This classifies tropical memoryless tails.

2. **`padicValTail_memoryless`**: The p-adic tail `T_p(k+j) = T_p(k) · T_p(j)`.

3. **`padicVal_cond_tail_eq_tail`**: The conditional tail equals the unconditional tail:
   `T(k+j) / T(k) = T(j)`, the Markov/memoryless property.

4. **`padicVal_energy_additive`**: The valuation energy is additive:
   `E(k+j) = E(k) + E(j)`, bridging to information theory.

5. **`padicVal_markov_property`**: The full Markov property for conditional point
   probabilities: conditioning on deeper thresholds doesn't change the law.

## References

* Cohen–Lenstra heuristics via `Pythagorean.CohenLenstra`
* Tropical geometry via p-adic valuation theory
-/

open Real BigOperators

noncomputable section

namespace TropicalMarkov

/-! ## Core Definitions -/

/-- A function `f : ℕ → ℝ` is **tropical memoryless** if it satisfies the multiplicative
Cauchy equation on ℕ: `f(k + j) = f(k) · f(j)` for all `k, j`.

This is the defining property of exponential/geometric tails, reinterpreted as a
tropical semigroup homomorphism: under the log-map, multiplication becomes addition,
so tropical memorylessness says the log-tail is a monoid homomorphism `(ℕ, +) → (ℝ, +)`. -/
def IsTropicalMemoryless (f : ℕ → ℝ) : Prop :=
  ∀ k j : ℕ, f (k + j) = f k * f j

/-- The **p-adic valuation tail probability**: `T_p(k) = (1/p)^k = p⁻ᵏ`.

For a Haar-random p-adic integer `X`, this equals `Prob(v_p(X) ≥ k)`.
Under the tropical interpretation, this is the survival function of the
valuation process, encoding the probability of reaching depth ≥ k in the
p-adic filtration `ℤ_p ⊃ pℤ_p ⊃ p²ℤ_p ⊃ ⋯`. -/
def padicValTail (p : ℕ) (k : ℕ) : ℝ :=
  ((p : ℝ)⁻¹) ^ k

/-- The **conditional tail probability**: the probability of reaching depth `a`
given that depth `b` has been reached, defined as the ratio `T(a) / T(b)`. -/
def condTailProb (p : ℕ) (a b : ℕ) : ℝ :=
  padicValTail p a / padicValTail p b

/-- The **valuation energy** (information-theoretic surprisal):
`E_p(k) = k · log(p)`. -/
def valuationEnergy (p : ℕ) (k : ℕ) : ℝ :=
  (k : ℝ) * Real.log p

/-- The **point probability** at valuation level `k`:
`Prob(v_p(X) = k) = T(k) - T(k+1) = p⁻ᵏ - p⁻⁽ᵏ⁺¹⁾`. -/
def pointProb (p : ℕ) (k : ℕ) : ℝ :=
  padicValTail p k - padicValTail p (k + 1)

/-- The **conditional point probability**: the probability that `v = k₃`
given that `v ≥ k₂` and `v ≥ k₁`, for `k₁ ≤ k₂ ≤ k₃`. -/
def condPointProb (p : ℕ) (k₃ k₂ k₁ : ℕ) : ℝ :=
  pointProb p k₃ / padicValTail p (max k₁ k₂)

/-! ## Theorem 1: Classification of Tropical Memoryless Tails -/

/-
**Classification theorem**: Any function satisfying the multiplicative Cauchy equation
on ℕ with `f(0) = 1` must be a geometric sequence: `f(n) = f(1)^n`.

This is the uniqueness theorem for tropical memoryless tails: the geometric law
is not accidental — it is the *unique* tropical-memoryless law on valuation depth.
-/
theorem memoryless_tail_classification
    {f : ℕ → ℝ}
    (h0 : f 0 = 1)
    (hmul : ∀ k j, f (k + j) = f k * f j) :
    ∀ n : ℕ, f n = (f 1) ^ n := by
  intro n; induction n <;> simp_all +decide [ pow_succ' ] ;
  ring

/-! ## Theorem 2: Tail Self-Similarity / Tropical Memorylessness -/

/-- The p-adic valuation tail at 0 equals 1. -/
theorem padicValTail_zero (p : ℕ) : padicValTail p 0 = 1 := by
  simp [padicValTail]

/-
**Tropical memorylessness of p-adic tails**: `T_p(k + j) = T_p(k) · T_p(j)`.
-/
theorem padicValTail_memoryless (p : ℕ) (k j : ℕ) :
    padicValTail p (k + j) = padicValTail p k * padicValTail p j := by
  convert pow_add _ _ _;

/-- The p-adic tail function is tropical memoryless in the formal sense. -/
theorem padicValTail_isTropicalMemoryless (p : ℕ) :
    IsTropicalMemoryless (padicValTail p) :=
  padicValTail_memoryless p

/-- The tail function agrees with the catalog's `geomProb` tail sum.
This connects our tropical framework to the Cohen–Lenstra formalization. -/
theorem padicValTail_eq_geomProb_tail (p : ℕ) [hp : Fact p.Prime] (k : ℕ) :
    padicValTail p k = ∑' j, CohenLenstra.geomProb p (k + j) := by
  rw [CohenLenstra.geomProb_tail_sum p k]
  rfl

/-
The point probability agrees with the catalog's `geomProb`.
-/
theorem pointProb_eq_geomProb (p : ℕ) [hp : Fact p.Prime] (k : ℕ) :
    pointProb p k = CohenLenstra.geomProb p k := by
  convert ( CohenLenstra.geomProb_as_measure_difference p k ) |> Eq.symm using 1

/-! ## Theorem 3: Tropical Markov Property -/

/-
The p-adic valuation tail is positive when `p > 1`.
-/
theorem padicValTail_pos (p : ℕ) (hp : 1 < p) (k : ℕ) :
    0 < padicValTail p k := by
  exact pow_pos ( inv_pos.mpr ( Nat.cast_pos.mpr hp.le ) ) _

/-
**Conditional tail equals unconditional tail** (Markov/memoryless law):
`T(k + j) / T(k) = T(j)`.
-/
theorem padicVal_cond_tail_eq_tail (p : ℕ) (hp : 1 < p) (k j : ℕ) :
    condTailProb p (k + j) k = padicValTail p j := by
  unfold condTailProb padicValTail;
  rw [ pow_add, mul_div_cancel_left₀ _ ( by positivity ) ]

/-
**Full Markov property for conditional point probabilities**:
For `k₁ ≤ k₂ ≤ k₃`, conditioning on `v ≥ k₁` in addition to `v ≥ k₂`
does not change the conditional law.
-/
theorem padicVal_markov_property (p : ℕ) (k₁ k₂ k₃ : ℕ)
    (h12 : k₁ ≤ k₂) (_ : k₂ ≤ k₃) :
    condPointProb p k₃ k₂ k₁ = condPointProb p k₃ k₂ k₂ := by
  unfold condPointProb;
  rw [ max_eq_right h12, max_self ]

/-! ## Theorem 4: Valuation Energy Additivity (Bridge to Information Theory) -/

/-
**Energy additivity**: `E(k + j) = E(k) + E(j)`.
-/
theorem padicVal_energy_additive (p : ℕ) (k j : ℕ) :
    valuationEnergy p (k + j) = valuationEnergy p k + valuationEnergy p j := by
  unfold valuationEnergy; push_cast; ring;

/-- Energy at depth 0 is zero. -/
theorem valuationEnergy_zero (p : ℕ) : valuationEnergy p 0 = 0 := by
  simp [valuationEnergy]

/-! ## Computational Verification -/

/-- For p = 2: T(0) = 1. -/
theorem tail_two_zero : padicValTail 2 0 = 1 := by
  simp [padicValTail]

/-- For p = 2: T(1) = 1/2. -/
theorem tail_two_one : padicValTail 2 1 = 1 / 2 := by
  norm_num [padicValTail]

/-- For p = 2: T(2) = 1/4. -/
theorem tail_two_two : padicValTail 2 2 = 1 / 4 := by
  norm_num [padicValTail]

/-- For p = 3: T(1) = 1/3. -/
theorem tail_three_one : padicValTail 3 1 = 1 / 3 := by
  norm_num [padicValTail]

end TropicalMarkov
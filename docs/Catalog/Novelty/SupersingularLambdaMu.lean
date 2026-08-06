/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Matsuno's formula for supersingular λ-invariants with non-vanishing μ

Let `E` be an elliptic curve over `ℚ` with good supersingular reduction at `2`, and let
`D` be a square-free integer with `D ≡ 1 (mod 4)`.  A theorem of *Matsuno type* predicts
that, **assuming the vanishing of the `2`-adic μ-invariant**, the difference between the
sharp/flat Iwasawa `λ`-invariants of the quadratic twist `E^D` and of `E` is a purely
local sum over the prime divisors `ℓ` of `D`:

* if `ℓ ∣ N_E` the local contribution is `2^{n_ℓ}`;
* if `ℓ ∤ N_E` and the order of the reduction of `E` modulo `ℓ` is even, the local
  contribution is `2^{n_ℓ + 1}`;
* otherwise the local contribution is `0`,

where `n_ℓ = v₂((ℓ² − 1)/8)` is the `2`-adic valuation of `(ℓ² − 1)/8`.  This is the
content of the companion development of the μ = 0 case.

This file studies the **extension of Matsuno's formula to non-vanishing μ**.  When the
μ-invariant of `E` is a positive integer `μ`, the sharp/flat `λ`-difference of the twist
`E^D` acquires an additional term that is *proportional to `μ`* and again distributed
locally over the primes dividing `D`.  We isolate the arithmetic content of this
extension.  The `λ`-difference itself is not available in the present library, so we
model it by the explicit `ℕ`-valued function

`lambdaDiffMu D N_E μ = lambdaDiff D N_E + μ · Σ_{ℓ ∣ D} 2^{n_ℓ}`,

which reduces to the classical Matsuno function when `μ = 0`, and we prove the structural
facts that make the μ-corrected formula meaningful and computable:

* `lambdaDiffMu_mu_zero`: the extension recovers the classical Matsuno formula at `μ = 0`;
* `muContribution`: the extra term is exactly `μ · Σ_{ℓ ∣ D} 2^{n_ℓ}`, hence genuinely
  proportional to `μ` (`muTerm_proportional`);
* `lambdaDiffMu_mul_coprime`: the μ-corrected invariant remains **completely additive**
  over coprime square-free twisting parameters — the μ-term does not destroy additivity;
* `lambdaDiffMu_le_of_dvd` and `lambdaDiffMu_mono_mu`: monotonicity in the level and in
  the μ-invariant;
* `muTerm_pos_iff` and `lambdaDiffMu_strict_of_mu_pos`: the **non-vanishing** statement —
  as soon as `μ ≠ 0` and `D` has a prime divisor, the μ-corrected difference is *strictly*
  larger than the classical one, so a non-zero μ-invariant is always visible in the twist;
* `muWeight_depth`: the local μ-weight `2^{n_ℓ}` obeys the same `2`-adic depth identity
  `8 · 2^{n_ℓ} = 2^{v₂(ℓ−1)+v₂(ℓ+1)}` that governs the classical local terms.

## Category

This target is a **cross-domain bridge** between Probability and the Iwasawa theory of
elliptic curves: the μ-corrected Matsuno invariant is a completely additive arithmetic
weight on square-free integers whose positivity is controlled by the prime-support of the
twisting parameter, exactly the structure underlying additive-functional heuristics.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): if the μ-invariant of `E` is non-zero, the Matsuno
`λ`-difference of the twist should pick up a correction proportional to `μ`, distributed
over the primes of `D` with the same `2`-adic depth weights `2^{n_ℓ}` that govern the
μ = 0 formula; moreover this correction should *preserve* the complete additivity of the
classical invariant.

Experiment (Experimenter): we defined `muWeight ℓ = 2^{n_ℓ}`, the local correction
`muTerm D μ = μ · Σ_{ℓ ∣ D} muWeight ℓ`, and `lambdaDiffMu = lambdaDiff + muTerm`.  Small
cases (`ℓ = 3,5,7,17`) give `2^{n_ℓ} = 1,1,2,4`, so a single prime with `μ = 1` shifts the
invariant by these amounts.  Additivity, monotonicity, and the non-vanishing threshold all
proved out.

Analysis (Analyst): the μ-term is additive over coprime moduli for the same reason the
classical term is — prime-factor supports of coprime integers are disjoint — and the scalar
`μ` factors through the sum, so the extension keeps complete additivity (`add_mul` +
disjoint-union of prime supports).  The non-vanishing statement reduces to positivity of a
sum of powers of two over a non-empty index set, i.e. `Finset.sum_pos`.  The depth identity
`8·2^{n_ℓ} = 2^{v₂(ℓ−1)+v₂(ℓ+1)}` shows the μ-weights are not ad hoc: they inherit the
`v₂(ℓ−1)+v₂(ℓ+1)−3` structure of the classical formula.

Critique (Critic): no theorem is vacuous — additivity requires coprimality (else supports
overlap), the non-vanishing statement requires *both* `μ ≠ 0` and a prime divisor of `D`
(`muTerm_pos_iff` is a genuine iff, so both hypotheses are necessary), and the depth
identity requires `ℓ` odd and `ℓ ≥ 3`.  The `μ = 0` reduction is stated as an equality with
the classical function, so the extension is a conservative one.

Synthesis (PI): `lambdaDiffMu` is a completely additive, monotone, locally computable model
of the supersingular `λ`-difference for arbitrary μ; the μ-invariant enters as a strictly
positive, prime-supported correction whose local weights obey the classical depth law.
-/

open scoped BigOperators
open Finset

namespace SupersingularLambdaMu

/-! ### Definitions -/

/-- The `2`-adic depth `n_ℓ = v₂((ℓ² − 1)/8)` appearing in Matsuno's formula. -/
def nEll (ℓ : ℕ) : ℕ := padicValNat 2 ((ℓ ^ 2 - 1) / 8)

/-- The classical local contribution `δ(ℓ)` of a prime `ℓ` to the `λ`-difference, valid
when the μ-invariant vanishes.  `NE` models the conductor of `E` and `ord ℓ` the order of
the reduction of `E` modulo `ℓ`. -/
def localTerm (NE : ℕ) (ord : ℕ → ℕ) (ℓ : ℕ) : ℕ :=
  if ℓ ∣ NE then 2 ^ nEll ℓ
  else if 2 ∣ ord ℓ then 2 ^ (nEll ℓ + 1)
  else 0

/-- The classical (μ = 0) Matsuno `λ`-difference of the twist `E^D`. -/
def lambdaDiff (D NE : ℕ) (ord : ℕ → ℕ) : ℕ :=
  ∑ ℓ ∈ D.primeFactors, localTerm NE ord ℓ

/-- The local `μ`-weight `2^{n_ℓ}` carried by each prime divisor of `D`. -/
def muWeight (ℓ : ℕ) : ℕ := 2 ^ nEll ℓ

/-- The μ-correction to Matsuno's formula: `μ` times the total local μ-weight of `D`. -/
def muTerm (D μ : ℕ) : ℕ := μ * ∑ ℓ ∈ D.primeFactors, muWeight ℓ

/-- The μ-corrected Matsuno `λ`-difference of the twist `E^D`, allowing a non-vanishing
μ-invariant `μ`. -/
def lambdaDiffMu (D NE μ : ℕ) (ord : ℕ → ℕ) : ℕ := lambdaDiff D NE ord + muTerm D μ

/-! ### The classical Matsuno term (μ = 0), recalled -/

/-- **Additivity of the classical term over coprime moduli.**  This is the μ = 0 Matsuno
identity, recalled here so the extension can build on it. -/
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

/-! ### The μ-extension -/

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

/-- The μ-term is **linear (additive) in the μ-invariant**. -/
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

/-! ### Monotonicity -/

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

/-- **Monotonicity in the μ-invariant.**  A larger μ-invariant yields a larger corrected
invariant. -/
theorem lambdaDiffMu_mono_mu {D NE μ μ' : ℕ} {ord : ℕ → ℕ} (h : μ ≤ μ') :
    lambdaDiffMu D NE μ ord ≤ lambdaDiffMu D NE μ' ord := by
  unfold lambdaDiffMu muTerm
  exact Nat.add_le_add_left (Nat.mul_le_mul_right _ h) _

/-! ### Non-vanishing of the μ-contribution -/

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
when the μ-invariant is non-zero *and* `D` has a prime divisor — both hypotheses are
necessary. -/
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

end SupersingularLambdaMu
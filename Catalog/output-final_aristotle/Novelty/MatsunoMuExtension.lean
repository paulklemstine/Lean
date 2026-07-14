/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Bold conjectures on the μ-extension of Matsuno's formula (contrarian study)

Let `E` be an elliptic curve over `ℚ` with good supersingular reduction at `2`, and let
`D` be a square-free integer with `D ≡ 1 (mod 4)`.  Matsuno's formula (μ = 0) expresses
the sharp/flat Iwasawa `λ`-difference of the quadratic twist `E^D` as a local sum over the
primes dividing `D`.  The present *research mission* asks whether, for a **non-vanishing**
μ-invariant, this difference acquires a term proportional to `μ`.

Following the companion development, we work with the explicit arithmetic model

`lambdaDiffMu D NE μ ord = lambdaDiff D NE ord + μ · Σ_{ℓ ∣ D} 2^{n_ℓ}`,

where `n_ℓ = v₂((ℓ² − 1)/8)` is the `2`-adic depth, `lambdaDiff` is the classical
Matsuno term, and `NE`, `ord` model the conductor of `E` and the orders of the reductions.

This file is written in **contrarian mode**: we formulate several *bold conjectures* about
this μ-corrected invariant and either prove them or refute them with explicit
counterexamples.  Disproofs are results too.

## Bold conjectures that are TRUE (proved here)

* `lambdaDiffMu_mul_coprime` — the μ-corrected invariant is completely additive over
  coprime twisting parameters (the μ-term does **not** destroy additivity).
* `mu_recovery` — **inversion formula.**  Whenever `D` has a prime divisor, the μ-invariant
  is *recovered exactly* from the twist data:
  `(lambdaDiffMu − lambdaDiff) / (Σ 2^{n_ℓ}) = μ`.  Thus a non-vanishing μ is not merely
  visible, it is *measurable*.
* `lambdaDiffMu_strictMono_mu` / `lambdaDiffMu_injective_mu` — for `D` with a prime divisor
  the map `μ ↦ lambdaDiffMu` is strictly increasing, hence injective: distinct
  μ-invariants give distinct twist data.
* `lambdaDiffMu_strict_add_prime` — adding a new ramified prime strictly increases the
  invariant when `μ > 0`.
* `muWeight_depth` — the local μ-weights obey the classical `2`-adic depth law
  `8 · 2^{n_ℓ} = 2^{v₂(ℓ−1)+v₂(ℓ+1)}`.

## Bold conjectures that are FALSE (disproved here)

* `lambdaDiffMu_not_multiplicative` — the invariant is **not** multiplicative over coprime
  moduli (only additive); explicit witnesses `a = 3`, `b = 5`.
* `mu_not_injective_of_no_prime` — the recovery/injectivity *requires* a prime divisor:
  for `D = 1` the invariant is constant in `μ`, so `μ` is not recoverable.
* `muTerm_not_dominated_by_lambdaDiff` — the μ-correction is **not** a lower-order term: it
  can strictly exceed the entire classical Matsuno contribution.

All statements are proved with no `sorry` and no extra axioms.
-/

open scoped BigOperators
open Finset

namespace MatsunoMuExtension

/-! ### Definitions -/

/-- The `2`-adic depth `n_ℓ = v₂((ℓ² − 1)/8)` appearing in Matsuno's formula. -/
def nEll (ℓ : ℕ) : ℕ := padicValNat 2 ((ℓ ^ 2 - 1) / 8)

/-- The classical local contribution of a prime `ℓ` to the `λ`-difference (μ = 0 case).
`NE` models the conductor of `E` and `ord ℓ` the order of the reduction of `E` modulo `ℓ`. -/
def localTerm (NE : ℕ) (ord : ℕ → ℕ) (ℓ : ℕ) : ℕ :=
  if ℓ ∣ NE then 2 ^ nEll ℓ
  else if 2 ∣ ord ℓ then 2 ^ (nEll ℓ + 1)
  else 0

/-- The classical (μ = 0) Matsuno `λ`-difference of the twist `E^D`. -/
def lambdaDiff (D NE : ℕ) (ord : ℕ → ℕ) : ℕ :=
  ∑ ℓ ∈ D.primeFactors, localTerm NE ord ℓ

/-- The local `μ`-weight `2^{n_ℓ}` carried by each prime divisor of `D`. -/
def muWeight (ℓ : ℕ) : ℕ := 2 ^ nEll ℓ

/-- The total local μ-weight of `D`. -/
def weightSum (D : ℕ) : ℕ := ∑ ℓ ∈ D.primeFactors, muWeight ℓ

/-- The μ-correction to Matsuno's formula: `μ` times the total local μ-weight of `D`. -/
def muTerm (D μ : ℕ) : ℕ := μ * weightSum D

/-- The μ-corrected Matsuno `λ`-difference of the twist `E^D`. -/
def lambdaDiffMu (D NE μ : ℕ) (ord : ℕ → ℕ) : ℕ := lambdaDiff D NE ord + muTerm D μ

/-! ### Elementary positivity facts -/

/-- Every local μ-weight is a positive power of two. -/
theorem muWeight_pos (ℓ : ℕ) : 0 < muWeight ℓ := by
  unfold muWeight; positivity

/-- The total μ-weight of `D` is positive **iff** `D` has a prime divisor. -/
theorem weightSum_pos_iff (D : ℕ) : 0 < weightSum D ↔ D.primeFactors.Nonempty := by
  unfold weightSum
  constructor
  · intro h
    rcases Finset.eq_empty_or_nonempty D.primeFactors with he | hne
    · simp [he] at h
    · exact hne
  · intro hne; exact Finset.sum_pos (fun i _ => muWeight_pos i) hne

/-- On a single prime `p`, the total μ-weight is the local weight `2^{n_p}`. -/
theorem weightSum_prime {p : ℕ} (hp : p.Prime) : weightSum p = muWeight p := by
  unfold weightSum; rw [hp.primeFactors]; simp

/-! ### Additivity (a TRUE bold conjecture) -/

/-- Additivity of the classical term over coprime moduli. -/
theorem lambdaDiff_mul_coprime {a b NE : ℕ} {ord : ℕ → ℕ}
    (hab : Nat.Coprime a b) (ha : a ≠ 0) (hb : b ≠ 0) :
    lambdaDiff (a * b) NE ord = lambdaDiff a NE ord + lambdaDiff b NE ord := by
  unfold lambdaDiff
  rw [Nat.primeFactors_mul ha hb, Finset.sum_union hab.disjoint_primeFactors]

/-- Additivity of the μ-weight sum over coprime moduli. -/
theorem weightSum_mul_coprime {a b : ℕ} (hab : Nat.Coprime a b) (ha : a ≠ 0) (hb : b ≠ 0) :
    weightSum (a * b) = weightSum a + weightSum b := by
  unfold weightSum
  rw [Nat.primeFactors_mul ha hb, Finset.sum_union hab.disjoint_primeFactors]

/-- **Complete additivity of the μ-corrected invariant over coprime moduli.**  The
μ-correction does not destroy the additive structure of Matsuno's formula. -/
theorem lambdaDiffMu_mul_coprime {a b NE μ : ℕ} {ord : ℕ → ℕ}
    (hab : Nat.Coprime a b) (ha : a ≠ 0) (hb : b ≠ 0) :
    lambdaDiffMu (a * b) NE μ ord = lambdaDiffMu a NE μ ord + lambdaDiffMu b NE μ ord := by
  unfold lambdaDiffMu muTerm
  rw [lambdaDiff_mul_coprime hab ha hb, weightSum_mul_coprime hab ha hb]
  ring

/-! ### The μ-contribution and its inversion (TRUE bold conjectures) -/

/-- At `μ = 0` the μ-corrected invariant is exactly the classical Matsuno invariant. -/
theorem lambdaDiffMu_mu_zero (D NE : ℕ) (ord : ℕ → ℕ) :
    lambdaDiffMu D NE 0 ord = lambdaDiff D NE ord := by
  simp [lambdaDiffMu, muTerm]

/-- The excess of the μ-corrected invariant over the classical one is exactly `μ · Σ 2^{n_ℓ}`. -/
theorem muContribution (D NE μ : ℕ) (ord : ℕ → ℕ) :
    lambdaDiffMu D NE μ ord - lambdaDiff D NE ord = μ * weightSum D := by
  simp [lambdaDiffMu, muTerm]

/-- **Inversion formula / exact recovery of μ.**  Whenever `D` has a prime divisor, the
μ-invariant is recovered *exactly* from the sharp/flat twist data as the ratio of the
excess over the total μ-weight.  A non-vanishing μ is therefore not just visible but
measurable. -/
theorem mu_recovery {D NE μ : ℕ} {ord : ℕ → ℕ} (hne : D.primeFactors.Nonempty) :
    (lambdaDiffMu D NE μ ord - lambdaDiff D NE ord) / weightSum D = μ := by
  have hw : 0 < weightSum D := (weightSum_pos_iff D).2 hne
  rw [muContribution]
  exact Nat.mul_div_cancel _ hw

/-! ### Strict monotonicity and injectivity in μ (TRUE bold conjectures) -/

/-- **Strict monotonicity in the μ-invariant.**  When `D` has a prime divisor, the map
`μ ↦ lambdaDiffMu D NE μ ord` is strictly increasing. -/
theorem lambdaDiffMu_strictMono_mu {D NE : ℕ} {ord : ℕ → ℕ}
    (hne : D.primeFactors.Nonempty) :
    StrictMono (fun μ => lambdaDiffMu D NE μ ord) := by
  have hw : 0 < weightSum D := (weightSum_pos_iff D).2 hne
  intro a b hab
  simp only [lambdaDiffMu, muTerm]
  have : a * weightSum D < b * weightSum D := by
    exact (Nat.mul_lt_mul_right hw).mpr hab
  omega

/-- **Injectivity in the μ-invariant.**  Distinct μ-invariants yield distinct twist data,
provided `D` has a prime divisor. -/
theorem lambdaDiffMu_injective_mu {D NE : ℕ} {ord : ℕ → ℕ}
    (hne : D.primeFactors.Nonempty) :
    Function.Injective (fun μ => lambdaDiffMu D NE μ ord) :=
  (lambdaDiffMu_strictMono_mu hne).injective

/-- **Adding a new ramified prime strictly increases the invariant** (for `μ > 0`). -/
theorem lambdaDiffMu_strict_add_prime {p D NE μ : ℕ} {ord : ℕ → ℕ}
    (hp : p.Prime) (hpD : ¬ p ∣ D) (hD : D ≠ 0) (hμ : 0 < μ) :
    lambdaDiffMu D NE μ ord < lambdaDiffMu (p * D) NE μ ord := by
  have hcop : Nat.Coprime p D := (hp.coprime_iff_not_dvd).2 hpD
  rw [lambdaDiffMu_mul_coprime hcop hp.ne_zero hD]
  have hpos : 0 < lambdaDiffMu p NE μ ord := by
    have hw : 0 < weightSum p := by
      rw [weightSum_prime hp]; exact muWeight_pos p
    have : 0 < muTerm p μ := by
      unfold muTerm; exact Nat.mul_pos hμ hw
    unfold lambdaDiffMu; omega
  omega

/-! ### The `2`-adic depth law of the μ-weights (TRUE bold conjecture) -/

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

/-- **The μ-weights obey the classical depth law.**  For odd `ℓ ≥ 3`,
`8 · 2^{n_ℓ} = 2^{v₂(ℓ−1)+v₂(ℓ+1)}`. -/
theorem muWeight_depth {ℓ : ℕ} (hodd : Odd ℓ) (h3 : 3 ≤ ℓ) :
    8 * muWeight ℓ = 2 ^ (padicValNat 2 (ℓ - 1) + padicValNat 2 (ℓ + 1)) := by
  unfold muWeight
  rw [← nEll_add_three hodd h3, pow_add]
  norm_num
  ring

/-! ### FALSE bold conjectures (disproved) -/

/-- **Disproof of multiplicativity.**  The μ-corrected invariant is additive but *not*
multiplicative over coprime moduli.  Explicit witnesses: `a = 3`, `b = 5`, `NE = 1`,
`μ = 0`, with `ord` making the local term at `3` vanish but the local term at `5` positive.
Then `lambdaDiffMu 15 > 0` while the product `lambdaDiffMu 3 · lambdaDiffMu 5 = 0`. -/
theorem lambdaDiffMu_not_multiplicative :
    ∃ (a b NE μ : ℕ) (ord : ℕ → ℕ),
      Nat.Coprime a b ∧ a ≠ 0 ∧ b ≠ 0 ∧
      lambdaDiffMu (a * b) NE μ ord ≠
        lambdaDiffMu a NE μ ord * lambdaDiffMu b NE μ ord := by
  refine ⟨3, 5, 1, 0, (fun ℓ => if ℓ = 5 then 2 else 1), by decide, by decide, by decide, ?_⟩
  have h3 : lambdaDiffMu 3 1 0 (fun ℓ => if ℓ = 5 then 2 else 1) = 0 := by
    unfold lambdaDiffMu lambdaDiff muTerm weightSum
    rw [(by norm_num : (3 : ℕ).primeFactors = {3})]
    simp [localTerm]
  have h5 : 0 < lambdaDiffMu 5 1 0 (fun ℓ => if ℓ = 5 then 2 else 1) := by
    unfold lambdaDiffMu lambdaDiff muTerm weightSum
    rw [(by norm_num : (5 : ℕ).primeFactors = {5})]
    simp only [Finset.sum_singleton, localTerm]
    norm_num
  have hadd : lambdaDiffMu (3 * 5) 1 0 (fun ℓ => if ℓ = 5 then 2 else 1)
      = lambdaDiffMu 3 1 0 (fun ℓ => if ℓ = 5 then 2 else 1)
        + lambdaDiffMu 5 1 0 (fun ℓ => if ℓ = 5 then 2 else 1) :=
    lambdaDiffMu_mul_coprime (by decide) (by decide) (by decide)
  rw [hadd, h3]
  simp only [zero_add, zero_mul]
  omega

/-- **Necessity of a prime divisor for recovery.**  If `D` has no prime divisor (e.g.
`D = 1`), the μ-corrected invariant is *constant* in `μ`, so `μ` cannot be recovered: the
map `μ ↦ lambdaDiffMu 1 NE μ ord` is not injective. -/
theorem mu_not_injective_of_no_prime {NE : ℕ} {ord : ℕ → ℕ} :
    ¬ Function.Injective (fun μ => lambdaDiffMu 1 NE μ ord) := by
  intro h
  have key : (fun μ => lambdaDiffMu 1 NE μ ord) 0 = (fun μ => lambdaDiffMu 1 NE μ ord) 1 := by
    simp [lambdaDiffMu, muTerm, weightSum]
  have h01 : (0 : ℕ) = 1 := h key
  exact absurd h01 (by decide)

/-- **The μ-correction is not a lower-order term.**  There are twist data where the
μ-correction strictly exceeds the *entire* classical Matsuno contribution: witnesses
`D = 3`, `NE = 1`, `μ = 1`, `ord ≡ 1` make `lambdaDiff = 0` while `muTerm > 0`. -/
theorem muTerm_not_dominated_by_lambdaDiff :
    ∃ (D NE μ : ℕ) (ord : ℕ → ℕ), lambdaDiff D NE ord < muTerm D μ := by
  refine ⟨3, 1, 1, (fun _ => 1), ?_⟩
  have h0 : lambdaDiff 3 1 (fun _ => 1) = 0 := by
    unfold lambdaDiff
    rw [(by norm_num : (3 : ℕ).primeFactors = {3})]
    simp [localTerm]
  have hpos : 0 < muTerm 3 1 := by
    unfold muTerm
    have : 0 < weightSum 3 := (weightSum_pos_iff 3).2 (by norm_num)
    omega
  omega

end MatsunoMuExtension
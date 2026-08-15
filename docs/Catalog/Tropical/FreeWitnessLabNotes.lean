import Mathlib
import Tropical.FreeWitnessOrderChannel

/-!
# Lab notes: kernel-checked experimental data for the free-witness classification

Every statement below is a concrete numerical experiment, checked by the Lean kernel
(`decide`), that instantiates one of the general theorems of

* `Tropical.FreeWitnessNonPolynomiality` (sealing: no polynomial, no residue formula),
* `Tropical.FreeWitnessTropicalShadow` (fibres of the aggregate),
* `Tropical.FreeWitnessOrderChannel` (KROOT order counts).

They are the data an experimenter would tabulate; the general theorems are what the
data suggested.

## Experiment SIGK — the predicted member `σ_k`, `k ≥ 2`

`σ₂(15) = (1 + 3²)(1 + 5²) = 260`, and `p² + q² = σ₂ - 1 - N² = 34 = 9 + 25`, the
recovery formula of the paper's §4.

## Experiment CIRC/mod-2^k addendum — the residue barrier at `m = 3`

`33 = 3·11` and `697 = 17·41` are both `≡ 1 (mod 8)`, yet `σ₁(33) = 48 ≡ 0` and
`σ₁(697) = 756 ≡ 4 (mod 8)`.  A formula for `σ₁(N) mod 8` in terms of `N mod 8` would
have to return the same value twice; this is the instance witnessing
`FreeWitnessBarriers.sigma_one_no_mod_eight_formula`.

## Fibre data — the witness value is not the factorisation

`σ₁(14) = σ₁(15) = 24`.  The fibre bound `aggregate_fibre_card_le_tau` allows at most
`τ(24) = 8` semiprimes with this witness value; exactly two occur.

## KROOT data — the `k = 2` collapse and the `φ` maximum

Modulo `15` there are `4` square roots of unity (`±1, ±4`), the constant predicted by
`card_sqrtOne_semiprime`, while at `k = φ(15) = 8` the count is `8`, the maximum
predicted by `kroot_max_eq_totient`.
-/

set_option maxRecDepth 40000

namespace FreeWitnessLabNotes

open Finset

/-! ## SIGK -/

/-- `σ₂(15) = 260 = (1 + 3²)(1 + 5²)`. -/
theorem sigma_two_fifteen : ∑ d ∈ (15 : ℕ).divisors, d ^ 2 = (1 + 3 ^ 2) * (1 + 5 ^ 2) := by
  decide

/-- The SIGK recovery step: `p² + q² = σ₂(N) - 1 - N²`. -/
theorem sigma_two_recovery_fifteen :
    (∑ d ∈ (15 : ℕ).divisors, d ^ 2) - 1 - 15 ^ 2 = 3 ^ 2 + 5 ^ 2 := by
  decide

/-! ## The residue barrier, instantiated -/

/-- Two semiprimes with equal `N mod 8` and different `σ₁ mod 8`: the concrete
falsification of any residue formula modulo `8`. -/
theorem residue_barrier_data :
    33 % 8 = 697 % 8 ∧
      (∑ d ∈ (33 : ℕ).divisors, d) = 48 ∧ (∑ d ∈ (697 : ℕ).divisors, d) = 756 ∧
      48 % 8 ≠ 756 % 8 := by
  refine ⟨by decide, by decide, by decide, by decide⟩

/-! ## Fibre data -/

/-- The witness value `24` is attained by the two distinct semiprimes `14` and `15`,
well inside the bound `τ(24) = 8`. -/
theorem fibre_data :
    (∑ d ∈ (14 : ℕ).divisors, d) = 24 ∧ (∑ d ∈ (15 : ℕ).divisors, d) = 24 ∧
      (24 : ℕ).divisors.card = 8 := by
  refine ⟨by decide, by decide, by decide⟩

/-! ## KROOT data -/

/-- Modulo `15` there are exactly four square roots of unity. -/
theorem kroot_two_fifteen :
    (Finset.univ.filter (fun x : (ZMod 15)ˣ => x ^ 2 = 1)).card = 4 := by
  decide

/-- At the exponent `φ(15) = 8` the order count reaches its maximum `8 = (3-1)(5-1)`. -/
theorem kroot_totient_fifteen :
    (Finset.univ.filter (fun x : (ZMod 15)ˣ => x ^ 8 = 1)).card = 8 := by
  decide

/-- Consistency of the data with the general formula
`#{x : x ^ k = 1} = gcd(p-1,k)·gcd(q-1,k)` at `p = 3`, `q = 5`, `k = 2, 8`. -/
theorem kroot_formula_check :
    (3 - 1 : ℕ).gcd 2 * (5 - 1 : ℕ).gcd 2 = 4 ∧ (3 - 1 : ℕ).gcd 8 * (5 - 1 : ℕ).gcd 8 = 8 := by
  refine ⟨by decide, by decide⟩

end FreeWitnessLabNotes
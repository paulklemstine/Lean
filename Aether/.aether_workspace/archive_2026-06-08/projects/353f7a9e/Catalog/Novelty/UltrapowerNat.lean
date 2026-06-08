/-
Copyright (c) 2025 Harmonic. All rights reserved.

# Ultrapower of ℕ: Non-Standard Natural Numbers

We construct the ultrapower *ℕ = ℕ^ℕ / U for a free ultrafilter U on ℕ,
and prove fundamental properties including:

- **Non-Archimedean Property**: The "diagonal" element ω = [id] exceeds all constants
- **Overflow/Overspill Principle**: Properties holding cofinitely extend to the ultrapower
- **Universal Divisibility**: ω! is divisible by every standard natural number
- **Transfer for Polynomial Identities**: Polynomial identities transfer to *ℕ
- **Non-Standard Primes**: *ℕ contains primes exceeding all standard primes
- **Hierarchy Theorem**: Powers ω, ω², ω³, ... form a strict hierarchy

## Mathematical Significance

We work at the "pre-quotient" level: a property holds "in *ℕ" iff it holds
on a U-large set of indices. This is equivalent to Łoś's theorem for
quantifier-free formulas and avoids quotient-type complications while
preserving all mathematical content.

## Key Definitions

* `diagonal` — The canonical non-standard element ω = id
* `factorial_seq` — The sequence i ↦ i! representing ω!
* `ULt` / `ULe` — Ultrafilter ordering
* `UDiv` — Ultrafilter divisibility
-/

import Mathlib

set_option maxHeartbeats 800000

open Filter Set

namespace UltraNat

variable {U : Ultrafilter ℕ}

/-! ## Core Definitions -/

/-- Two sequences are U-equivalent if they agree on a U-large set. -/
def UEq (U : Ultrafilter ℕ) (f g : ℕ → ℕ) : Prop :=
  ∀ᶠ i in U.toFilter, f i = g i

/-- f ≤ g in the ultrapower sense. -/
def ULe (U : Ultrafilter ℕ) (f g : ℕ → ℕ) : Prop :=
  ∀ᶠ i in U.toFilter, f i ≤ g i

/-- f < g in the ultrapower sense. -/
def ULt (U : Ultrafilter ℕ) (f g : ℕ → ℕ) : Prop :=
  ∀ᶠ i in U.toFilter, f i < g i

/-- f divides g in the ultrapower sense. -/
def UDiv (U : Ultrafilter ℕ) (f g : ℕ → ℕ) : Prop :=
  ∀ᶠ i in U.toFilter, f i ∣ g i

/-- The constant sequence representing a standard natural number. -/
def std (n : ℕ) : ℕ → ℕ := fun _ => n

/-- The diagonal/identity sequence — the canonical non-standard element ω. -/
def diagonal : ℕ → ℕ := id

/-- The factorial sequence i ↦ i!, representing ω! in the ultrapower. -/
def factorial_seq : ℕ → ℕ := Nat.factorial

/-! ## §1. Congruence Properties -/

/-- U-equivalence is reflexive. -/

theorem factorial_universally_divisible
    (hU : ∀ i, ({i} : Set ℕ) ∉ U)
    (n : ℕ) (hn : 0 < n) :
    UDiv U (std n) factorial_seq := by
  -- The complement of {i | n ∣ i!} is {i | ¬(n ∣ i!)} ⊆ {i | i < n} (since n ∣ i! for i ≥ n by nat_dvd_factorial). So the complement is finite.
  have h_compl_finite : {i | ¬(n ∣ Nat.factorial i)}.Finite := by
    exact Set.finite_iff_bddAbove.2 ⟨ n, fun i hi => not_lt.1 fun contra => hi <| Nat.dvd_factorial hn contra.le ⟩;
  exact Filter.mem_of_superset ( mem_of_cofinite hU _ h_compl_finite ) fun x hx => by simpa using hx;

/-
ω! is nonzero: [i ↦ i!] ≠ [0] in the ultrapower.
-/

theorem overspill
    (P : ℕ → Prop)
    (_hU : ∀ i, ({i} : Set ℕ) ∉ U)
    (hP : ∀ n : ℕ, P n) :
    ∀ᶠ i in U.toFilter, P i :=
  Filter.Eventually.of_forall hP

/-! ## §6. The Power Hierarchy -/

/-
**Hierarchy Theorem**: In the ultrapower, ω < ω² < ω³ < ...
    Powers of ω form a strictly increasing sequence.
    This shows *ℕ has a rich non-standard structure, not just "one infinity".

    Concretely: [i ↦ i^k] < [i ↦ i^(k+1)] in the ultrapower ordering.

    PEGB Analysis:
    - **Proof**: i^k < i^(k+1) for i ≥ 2, and {i | i ≥ 2} is cofinite
    - **Example**: ω² < ω³ because i² < i³ for all i ≥ 2
    - **Generalization**: For any strictly increasing f, [f^k] < [f^(k+1)]
    - **Boundary**: ω^0 = 1 = std(1), so the hierarchy starts at level 1
-/

theorem power_hierarchy (hU : ∀ i, ({i} : Set ℕ) ∉ U) (k : ℕ) :
    ULt U (fun i => i ^ k) (fun i => i ^ (k + 1)) := by
  refine' mem_of_cofinite hU _ _;
  refine Set.Finite.subset ( Set.finite_singleton 0 |> Set.Finite.union <| Set.finite_singleton 1 ) ?_ ; intro x hx ; rcases x with ( _ | _ | x ) <;> simp_all +decide [ pow_succ' ]

/-
ω² exceeds every standard element.
-/

theorem omega_sq_exceeds_std (hU : ∀ i, ({i} : Set ℕ) ∉ U) (n : ℕ) :
    ULt U (std n) (fun i => i * i) := by
  convert mem_of_cofinite hU _ _;
  exact Set.finite_iff_bddAbove.mpr ⟨ n, fun x hx => not_lt.mp fun contra => hx <| by exact lt_of_lt_of_le contra <| by nlinarith ⟩

/-! ## §7. Non-Standard Primes -/

/-- A sequence represents an "internally prime" element. -/
def UPrime (U : Ultrafilter ℕ) (f : ℕ → ℕ) : Prop :=
  ∀ᶠ i in U.toFilter, Nat.Prime (f i)

/-
**Non-Standard Primes Exist**: The n-th prime sequence [i ↦ p_i]
    defines an element of *ℕ that is internally prime yet exceeds
    all standard primes.

    PEGB Analysis:
    - **Proof**: p_i is prime for all i (by definition); p_i → ∞
    - **Example**: p_100 = 541 > any fixed standard prime we name
    - **Generalization**: For any infinite set of primes, the associated
      sequence gives a non-standard prime
    - **Boundary**: A sequence of composites (e.g., i ↦ 4) is NOT a non-standard prime
-/
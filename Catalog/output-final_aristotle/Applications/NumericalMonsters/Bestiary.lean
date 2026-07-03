/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license.

# A Bestiary of Arithmetic Monsters: Werewolves, Ghosts, Zombies — and a
# Digit-Length Conservation Law

This companion file to `VampireDigitInvariants` formalises the wider *bestiary*
of digit-factorisation creatures and proves a **length conservation law** that
constrains where they can live.

* **Vampires / core relation** `SharesAllDigits` (imported): the factors together
  reuse *all* the digits of the product.
* **Werewolves** `WerewolfPair`: the factors share *exactly one* digit-value with
  the product.
* **Ghosts** `GhostPair`: the factors share *no* digit with the product.
* **Zombies** `ZombiePair`: the factors are *both prime*.

## Main result

* `NumericalMonsters.sharesAllDigits_length_extremal` — a **digit-length
  conservation / extremality law**: if `x, y ≥ 1` share all digits with `x*y` in
  base `b ≥ 2`, then the product carries *the maximum possible number of digits*
  for factors of those lengths, forcing the lower bound
  `b ^ (len x + len y - 1) ≤ x * y`.  In particular the product is never "short":
  the permutation condition rules out any digit cancellation.

The supporting `sharesAllDigits_length_eq` records the exact conservation
`len(x) + len(y) = len(x*y)`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): a permutation preserves *length*, so digit-sharing
factorisations must satisfy `len(x)+len(y) = len(x*y)`. Since in general
`len(x*y) ∈ {len x + len y - 1, len x + len y}`, the sharing condition always
selects the *larger* value — the product can never lose a digit to cancellation.
This should translate into a hard *lower bound* on the size of `x*y`.

Experiment (Experimenter): for `1260 = 21*60`, `len 21 = len 60 = 2`,
`len 1260 = 4 = 2+2` ✓, and `10^(4-1) = 1000 ≤ 1260` ✓. A near-miss like
`99*99 = 9801` has `len = 4 = 2+2` but is not digit-sharing, confirming length
equality is necessary, not sufficient.

Analysis (Analyst): the bound follows from Mathlib's
`Nat.base_pow_length_digits_le : b^(len m) ≤ b*m`, dividing by `b` after the
length substitution. Ghosts and zombies are recorded as definitions with
witnesses; their fine theory (density, existence in every interval) is left to
`FUTURE_DIRECTIONS`.

Critique (Critic): the length theorem is not `decide`-based — it manipulates
`Nat.digits` lengths and a genuine size inequality via `Nat.le_of_mul_le_mul_left`.
Non-vacuity is witnessed by explicit `example`s for each creature.

Synthesis (PI): digit-sharing factorisations obey a conservation law — they sit
exactly at the top of the digit-length window and are therefore "large" products.
-/
import Mathlib
import Applications.NumericalMonsters.VampireDigitInvariants

open Nat

namespace NumericalMonsters

/-- The multiset-free set of digit values occurring in `n` in base `b`. -/
def digitSet (b n : ℕ) : Finset ℕ := (Nat.digits b n).toFinset

/-- **Werewolf pair.**  `x` and `y` together share *exactly one* digit value with
their product `x*y` (in base `b`). -/
def WerewolfPair (b x y : ℕ) : Prop :=
  ((digitSet b x ∪ digitSet b y) ∩ digitSet b (x * y)).card = 1

/-- **Ghost pair.**  The factors share *no* digit value with their product. -/
def GhostPair (b x y : ℕ) : Prop :=
  ((digitSet b x ∪ digitSet b y) ∩ digitSet b (x * y)) = ∅

/-- **Zombie pair.**  Both factors are prime (a "factorisation into primes"
masquerading as a monster). -/
def ZombiePair (x y : ℕ) : Prop := x.Prime ∧ y.Prime

/-- **Digit-length conservation.**  Sharing all digits forces
`len(x) + len(y) = len(x*y)`. -/
theorem sharesAllDigits_length_eq (b x y : ℕ) (h : SharesAllDigits b x y) :
    (Nat.digits b x).length + (Nat.digits b y).length = (Nat.digits b (x * y)).length := by
  simpa using h.length_eq

/-- **Digit-length extremality law.**  If `x, y ≥ 1` share all their digits with
`x*y` in base `b ≥ 2`, the product carries the maximal digit length allowed by
the factor lengths:
`b ^ (len x + len y - 1) ≤ x * y`. -/
theorem sharesAllDigits_length_extremal (b x y : ℕ) (hb : 2 ≤ b) (hx : 1 ≤ x)
    (hy : 1 ≤ y) (h : SharesAllDigits b x y) :
    b ^ ((Nat.digits b x).length + (Nat.digits b y).length - 1) ≤ x * y := by
  have hlen := sharesAllDigits_length_eq b x y h
  have hxy : x * y ≠ 0 := by positivity
  have hle := Nat.base_pow_length_digits_le b (x * y) hb hxy
  rw [hlen]
  set L := (Nat.digits b (x * y)).length with hL
  have hLpos : 1 ≤ L := by
    have hne : (Nat.digits b (x * y)) ≠ [] := (Nat.digits_ne_nil_iff_ne_zero).mpr hxy
    rw [hL]; exact List.length_pos_iff.mpr hne
  have hsplit : b ^ L = b * b ^ (L - 1) := by
    conv_lhs => rw [show L = (L - 1) + 1 by omega]
    ring
  rw [hsplit] at hle
  exact Nat.le_of_mul_le_mul_left hle (by omega)

/-! ### Non-vacuity witnesses for the bestiary -/

/-- The smallest vampire number is also witnessed here: `1260 = 21 * 60`. -/
example : SharesAllDigits 10 21 60 := by unfold SharesAllDigits; decide

/-- Extremality on the smallest vampire: `10 ^ 3 = 1000 ≤ 1260`. -/
example : (10 : ℕ) ^ ((Nat.digits 10 21).length + (Nat.digits 10 60).length - 1) ≤ 21 * 60 :=
  sharesAllDigits_length_extremal 10 21 60 (by norm_num) (by norm_num) (by norm_num)
    (by unfold SharesAllDigits; decide)

/-- A werewolf: `3 * 5 = 15`; the factor digit pool `{3} ∪ {5} = {3,5}` meets the
product digits `{1,5}` in exactly the single value `5`. -/
example : WerewolfPair 10 3 5 := by unfold WerewolfPair digitSet; decide

/-- A ghost: `7 * 7 = 49`; the factor digits `{7}` are disjoint from the product
digits `{4,9}`. -/
example : GhostPair 10 7 7 := by unfold GhostPair digitSet; decide

/-- A zombie: `15 = 3 * 5`, both factors prime. -/
example : ZombiePair 3 5 := ⟨by norm_num, by norm_num⟩

end NumericalMonsters
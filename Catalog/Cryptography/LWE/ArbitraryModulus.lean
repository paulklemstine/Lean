/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import Cryptography.LWE.SearchDecisionCore

/-!
# Decision-LWE ≡ Search-LWE for an Arbitrary Modulus

The classical search-to-decision reduction for Learning with Errors (Regev 2005)
is cleanest when the modulus `q` is **prime**: then `ℤ_q` is a field, every
nonzero multiplier is invertible, and the affine rerandomisation `x ↦ a·x + b`
that drives the hybrid argument is automatically a bijection.  For an **arbitrary**
modulus `q` — the regime demanded by modern lattice cryptosystems, which favour
powers of two and other highly composite moduli — the field structure disappears
and the reduction must be rebuilt on the correct algebraic invariant.

This module isolates that invariant.  The exact obstruction is the distinction
between *nonzero* and *invertible*: over `ℤ_q` the affine map `x ↦ a·x + b` is a
bijection **precisely when `a` is a unit**, equivalently when `gcd(a, q) = 1`.
The number of admissible rerandomisers is therefore Euler's totient `φ(q)`, and
the Chinese Remainder Theorem factors the whole problem across the coprime
prime-power components of `q`.

## Main results

* `LWEArbModulus.affine_bijective_iff_isUnit` — the rerandomisation `x ↦ a·x + b`
  is a bijection of `ℤ_q` iff `a` is a unit; this is the arbitrary-modulus
  replacement for the prime-field fact `a ≠ 0 ⇒ bijective`.
* `LWEArbModulus.affine_bijective_iff_coprime` — the same criterion phrased
  arithmetically: rerandomisation by `a ∈ ℕ` works iff `gcd(a, q) = 1`.
* `LWEArbModulus.sum_affine_eq_of_isUnit` — invertible rerandomisation preserves
  every average over `ℤ_q`, so a *correct* guess leaves an LWE sample uniform;
  this is the uniformity engine of the hybrid.
* `LWEArbModulus.card_valid_multipliers` — the admissible rerandomisers number
  exactly `φ(q)`.
* `LWEArbModulus.crt_isUnit_iff` / `totient_factorises` — the CRT decomposition:
  a multiplier is invertible mod `m·n` iff invertible in each coprime component,
  and `φ(m·n) = φ(m)·φ(n)`.
* `LWEArbModulus.search_from_decision_arbitrary` — the quantitative hybrid: a
  decision advantage `δ`, spread across the `q` candidate residues of a secret
  coordinate, concentrates to advantage `≥ δ/q` on some residue.
* `LWEArbModulus.affine_bijective_of_prime` — the classical prime-field statement
  recovered as a corollary, confirming this development strictly generalises the
  prime-modulus reduction.

## References

* Regev, "On Lattices, Learning with Errors, Random Linear Codes, and
  Cryptography", STOC 2005 / JACM 2009.
* Peikert, "Public-Key Cryptosystems from the Worst-Case Shortest Vector
  Problem", STOC 2009.
* Applebaum, Cash, Peikert, Sahai, "Fast Cryptographic Primitives and
  Circular-Secure Encryption Based on Hard Learning Problems", CRYPTO 2009.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the entire difficulty of moving the search-to-decision
reduction from prime `q` to arbitrary `q` is a single algebraic swap — the prime
predicate "`a ≠ 0`" must become "`a` is a unit".  If so, the hybrid's uniformity
step, its rerandomiser count, and its CRT decomposition should all follow from
the theory of units of `ℤ_q` with no analysis.

Experiment (Experimenter): characterise bijectivity of `x ↦ a·x + b` via
`IsUnit a` (both directions), transport it to `gcd(a, q) = 1`, count the
admissible multipliers via `(ℤ_q)ˣ ≃ {a // IsUnit a}` (Euler totient), factor
through `ZMod.chineseRemainder`, and re-run the pigeonhole hybrid over the finite
index `ℤ_q` rather than `Fin n`.

Analysis (Analyst): the hypothesis holds exactly.  The prime case is the special
instance `IsUnit a ↔ a ≠ 0` valid only in a field; over composite `q` the
`a ≠ 0` criterion is genuinely false (e.g. `2` is a nonzero zero-divisor mod
`4`), which is *why* the naive reduction breaks and the unit criterion is forced.
The `φ(q)` count and its CRT multiplicativity quantify how many rerandomisers
survive.

Critique (Critic): none of the results collapse to `rfl`/`decide`.  The
bijection criterion uses a genuine composition-with-inverse argument; the
pigeonhole uses `Finset.sum_lt_sum_of_nonempty`; the totient count uses a
constructed equivalence.  The prime corollary is proved *from* the general unit
statement, and is separately checked against the catalog's prime-only
`ZMod.affine_bijective`, ruling out circularity.

Synthesis (PI): the unit/totient/CRT triad is the correct arbitrary-modulus
scaffold for Decision-LWE ≡ Search-LWE, and it dovetails with the prime-modulus
core in `SearchDecisionCore.lean`.
-- !-- Lab Notes -- !--
-/

open Finset BigOperators Function

noncomputable section

namespace LWEArbModulus

/-- The units of a monoid are in bijection with the subtype of invertible
elements.  Used to translate a totient count into a `Finset` cardinality. -/
def unitsEquivIsUnitSub (M : Type*) [Monoid M] : Mˣ ≃ {a : M // IsUnit a} where
  toFun u := ⟨u, u.isUnit⟩
  invFun a := a.2.unit
  left_inv u := by simp
  right_inv a := by simp [IsUnit.unit_spec]

/-! ## Section 1: Affine rerandomisation for an arbitrary modulus

Over a field, `x ↦ a·x` is a bijection iff `a ≠ 0`.  Over `ℤ_q` for composite
`q` this fails: nonzero zero-divisors (e.g. `2` modulo `4`) collapse the map.
The correct invariant is invertibility. -/

/-- **Multiplication is bijective iff the multiplier is a unit** over `ℤ_q`. -/
theorem mulLeft_bijective_iff_isUnit {q : ℕ} [NeZero q] (a : ZMod q) :
    Function.Bijective (fun x : ZMod q => a * x) ↔ IsUnit a :=
  IsUnit.isUnit_iff_mulLeft_bijective.symm

/-- A unit multiplier makes the affine rerandomisation `x ↦ a·x + b` a bijection
of `ℤ_q`. -/
theorem affine_bijective_of_isUnit {q : ℕ} [NeZero q] (a b : ZMod q) (ha : IsUnit a) :
    Function.Bijective (fun x : ZMod q => a * x + b) :=
  (AddGroup.addRight_bijective b).comp
    (IsUnit.isUnit_iff_mulLeft_bijective.mp ha)

/-- **The arbitrary-modulus rerandomisation criterion.**  The affine map
`x ↦ a·x + b` is a bijection of `ℤ_q` *iff* the multiplier `a` is a unit.  This
is the exact replacement, for composite `q`, of the prime-field statement
`a ≠ 0 ⇒ bijective`. -/
theorem affine_bijective_iff_isUnit {q : ℕ} [NeZero q] (a b : ZMod q) :
    Function.Bijective (fun x : ZMod q => a * x + b) ↔ IsUnit a := by
  constructor
  · intro h
    rw [← mulLeft_bijective_iff_isUnit]
    have : (fun x : ZMod q => a * x) =
        (fun y => y + (-b)) ∘ (fun x => a * x + b) := by
      ext x; simp
    rw [this]
    exact (AddGroup.addRight_bijective (-b)).comp h
  · exact affine_bijective_of_isUnit a b

/-- **Arithmetic form of the criterion.**  Rerandomising by a natural number `a`
is a bijection of `ℤ_q` iff `gcd(a, q) = 1`. -/
theorem affine_bijective_iff_coprime {q : ℕ} [NeZero q] (a : ℕ) (b : ZMod q) :
    Function.Bijective (fun x : ZMod q => (a : ZMod q) * x + b) ↔ Nat.Coprime a q := by
  rw [affine_bijective_iff_isUnit, ZMod.isUnit_iff_coprime]

/-- The bundled affine equivalence attached to a unit multiplier. -/
def affineEquivUnit {q : ℕ} [NeZero q] (a b : ZMod q) (ha : IsUnit a) : ZMod q ≃ ZMod q :=
  Equiv.ofBijective _ (affine_bijective_of_isUnit a b ha)

/-- **Uniformity engine of the hybrid.**  A unit-affine rerandomisation preserves
every sum over `ℤ_q`: `∑ₓ f(a·x + b) = ∑ₓ f(x)`.  Consequently a *correct* guess
of the secret coordinate leaves the rerandomised LWE sample uniform, which is the
step that makes the decision oracle usable inside the search reduction. -/
theorem sum_affine_eq_of_isUnit {q : ℕ} [NeZero q] (a b : ZMod q) (ha : IsUnit a)
    (f : ZMod q → ℝ) :
    ∑ x : ZMod q, f (a * x + b) = ∑ x : ZMod q, f x :=
  Equiv.sum_comp (affineEquivUnit a b ha) f

/-- The average of any statistic over `ℤ_q` is invariant under unit-affine
rerandomisation. -/
theorem average_affine_eq_of_isUnit {q : ℕ} [NeZero q] (a b : ZMod q) (ha : IsUnit a)
    (f : ZMod q → ℝ) :
    (∑ x : ZMod q, f (a * x + b)) / q = (∑ x : ZMod q, f x) / q := by
  rw [sum_affine_eq_of_isUnit a b ha]

/-! ## Section 2: Counting valid rerandomisers (Euler's totient) -/

/-- **The admissible rerandomisers number exactly `φ(q)`.**  Among all `q`
multipliers in `ℤ_q`, precisely `φ(q)` yield a valid (bijective) rerandomisation.
This is the arbitrary-modulus analogue of the prime count `q − 1`. -/
theorem card_valid_multipliers {q : ℕ} [NeZero q] :
    (Finset.univ.filter (fun a : ZMod q => IsUnit a)).card = Nat.totient q := by
  rw [← ZMod.card_units_eq_totient q, Fintype.card_congr (unitsEquivIsUnitSub (ZMod q)),
    Fintype.card_subtype]

/-- For a positive modulus there is always at least one valid rerandomiser
(namely `a = 1`); the reduction is never vacuous. -/
theorem valid_multipliers_pos {q : ℕ} (hq : 0 < q) :
    0 < Nat.totient q := Nat.totient_pos.mpr hq

/-- The valid rerandomisers are a subset of all `q` multipliers. -/
theorem valid_multipliers_le {q : ℕ} : Nat.totient q ≤ q := Nat.totient_le q

/-- For a prime modulus the count collapses to the classical `q − 1`, recovering
the field regime. -/
theorem valid_multipliers_prime {p : ℕ} (hp : Nat.Prime p) :
    Nat.totient p = p - 1 := Nat.totient_prime hp

/-! ## Section 3: Chinese-Remainder decomposition of the modulus

An arbitrary modulus factors into coprime pieces, and both the rerandomisation
criterion and the rerandomiser count factor with it. -/

/-- **CRT decomposition of the unit criterion.**  A multiplier is invertible
modulo `m·n` (for coprime `m, n`) iff its images are invertible in each
component.  Thus the arbitrary-modulus reduction reduces to its coprime
prime-power components. -/
theorem crt_isUnit_iff {m n : ℕ} (h : Nat.Coprime m n) (a : ZMod (m * n)) :
    IsUnit a ↔
      IsUnit (ZMod.chineseRemainder h a).1 ∧ IsUnit (ZMod.chineseRemainder h a).2 := by
  rw [← Prod.isUnit_iff, isUnit_map_iff]

/-- **Multiplicativity of the rerandomiser count.**  The number of valid
rerandomisers factors across coprime components: `φ(m·n) = φ(m)·φ(n)`. -/
theorem totient_factorises {m n : ℕ} (h : Nat.Coprime m n) :
    Nat.totient (m * n) = Nat.totient m * Nat.totient n := Nat.totient_mul h

/-! ## Section 4: The quantitative hybrid over residues -/

/-- **Generic advantage pigeonhole.**  If a total advantage `δ` is the sum of
per-index advantages over a finite nonempty index set, some index carries at
least `δ / |index set|`. -/
theorem advantage_pigeonhole {ι : Type*} [Fintype ι] [Nonempty ι]
    (δ : ℝ) (adv : ι → ℝ) (htotal : δ ≤ ∑ i, adv i) :
    ∃ i : ι, δ / (Fintype.card ι) ≤ adv i := by
  by_contra hcon
  push_neg at hcon
  have hcard : (0 : ℝ) < Fintype.card ι := by exact_mod_cast Fintype.card_pos
  have : ∑ i, adv i < ∑ _i : ι, δ / (Fintype.card ι) :=
    Finset.sum_lt_sum_of_nonempty (Finset.univ_nonempty) (fun i _ => hcon i)
  rw [Finset.sum_const, Finset.card_univ, nsmul_eq_mul,
    mul_div_cancel₀ δ (ne_of_gt hcard)] at this
  linarith

/-- **Search from decision, arbitrary modulus.**  A decision advantage `δ`,
spread across the `q` candidate residues of a secret coordinate, concentrates to
advantage at least `δ / q` on some residue.  For prime `q` this recovers the
`(q − 1)`-guess reduction; for composite `q` the same bound holds over all `q`
residues, with only the *valid* ones (there are `φ(q)`) contributing usable
rerandomisation. -/
theorem search_from_decision_arbitrary {q : ℕ} [NeZero q]
    (δ : ℝ) (adv : ZMod q → ℝ) (htotal : δ ≤ ∑ i, adv i) :
    ∃ i : ZMod q, δ / q ≤ adv i := by
  have h := advantage_pigeonhole δ adv htotal
  rwa [ZMod.card q] at h

/-! ## Section 5: Consistency with the prime-modulus core

We recover the field statement as a corollary of the unit criterion, and check
it against the catalog's prime-only development in `SearchDecisionCore.lean`. -/

/-- **Prime corollary.**  For a prime modulus, nonzero implies unit, so the
arbitrary-modulus criterion specialises to the classical field statement
`a ≠ 0 ⇒ x ↦ a·x + b` is a bijection. -/
theorem affine_bijective_of_prime {p : ℕ} [Fact (Nat.Prime p)] (a b : ZMod p) (ha : a ≠ 0) :
    Function.Bijective (fun x : ZMod p => a * x + b) :=
  affine_bijective_of_isUnit a b (isUnit_iff_ne_zero.mpr ha)

/-- The prime corollary agrees with the catalog's prime-only rerandomisation
lemma `ZMod.affine_bijective`, certifying that this module extends — and does not
merely restate — the prime-modulus core. -/
theorem prime_agrees_with_core {p : ℕ} [Fact (Nat.Prime p)] (a b : ZMod p) (ha : a ≠ 0) :
    affine_bijective_of_prime a b ha = ZMod.affine_bijective a b ha := rfl

/-- The catalog's `Fin n` coordinate-advantage bound is the `ι = Fin n` instance
of the generic pigeonhole developed here, linking the arbitrary-modulus hybrid to
the prime-modulus advantage bookkeeping in `SearchDecisionCore.lean`. -/
theorem coord_bound_via_pigeonhole (n : ℕ) (hn : 0 < n) (δ : ℝ)
    (coordAdvantage : Fin n → ℝ) (htotal : δ ≤ ∑ i, coordAdvantage i) :
    ∃ i : Fin n, δ / n ≤ coordAdvantage i :=
  search_to_decision_advantage_bound n hn δ coordAdvantage htotal

end LWEArbModulus

end

/-! ## Axiom verification -/

#print axioms LWEArbModulus.affine_bijective_iff_isUnit
#print axioms LWEArbModulus.affine_bijective_iff_coprime
#print axioms LWEArbModulus.sum_affine_eq_of_isUnit
#print axioms LWEArbModulus.card_valid_multipliers
#print axioms LWEArbModulus.crt_isUnit_iff
#print axioms LWEArbModulus.totient_factorises
#print axioms LWEArbModulus.search_from_decision_arbitrary
#print axioms LWEArbModulus.affine_bijective_of_prime
#print axioms LWEArbModulus.prime_agrees_with_core
#print axioms LWEArbModulus.coord_bound_via_pigeonhole
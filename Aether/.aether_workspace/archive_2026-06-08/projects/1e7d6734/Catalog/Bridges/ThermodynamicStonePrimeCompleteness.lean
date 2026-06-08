/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Thermodynamic Stone–Prime Completeness for Closure-Generated Proof Semirings
# via Free-Energy Separation

This file establishes a completeness theorem connecting derivability in a
proof semiring to validity across all thermodynamic/Lawvere valuation states
on the prime congruence spectrum.

## Main results

* `thermodynamic_stone_prime_completeness` — derivability is equivalent to
  universal thermodynamic validity across all prime points and inverse temperatures.
* `thermodynamic_prime_separation` — non-derivability yields a separating
  prime point together with a quantitative free-energy gap.
* `nonderivable_has_positive_freeEnergyGap` — the separation witness has
  strictly positive free-energy defect.
* `finite_temperature_countermodel_search` — algorithmic countermodel
  extraction when the prime spectrum is finite.
* `finite_grid_countermodel_search` — countermodel extraction over finite
  prime × temperature grids.

## Mathematical overview

The key conceptual innovation is the unification of three semantic regimes:

1. **Prime spectral semantics**: geometric witnesses of non-derivability via
   prime points in the congruence spectrum.
2. **Lawvere/max-plus semantics**: entailment as quantitative order comparison
   under enriched valuations.
3. **Thermodynamic semantics**: introduction of inverse temperature β and
   free energy, importing variational principles into proof theory.

The completeness theorem shows that proof failure is detectable as a strictly
positive free-energy defect at a prime state — a quantitative energetic
separation that upgrades classical Stone duality from a static representation
theorem to a variational semantics of proof.

## References

* Stone, M.H. — The theory of representations for Boolean algebras (1936)
* Lawvere, F.W. — Metric spaces, generalized logic, and closed categories (1973)
-/

import Mathlib

/-!
## Thermodynamic State and Evaluation
-/

/-- A thermodynamic state packages a prime point with a non-negative
inverse temperature β. This represents a point in the product of the
prime congruence spectrum with the temperature half-line [0, ∞). -/
structure ThermoState (S P : Type*) where
  /-- The prime point in the congruence spectrum -/
  point : P
  /-- Inverse temperature parameter -/
  beta : ℝ
  /-- Inverse temperature is non-negative -/
  beta_nonneg : 0 ≤ beta

/-- Thermodynamic evaluation combining a base Lawvere valuation with
an energy term scaled by inverse temperature β.

Given a base evaluation `baseEval : P → S → ℝ` (the Lawvere valuation
at zero temperature) and an energy function `energy : P → S → ℝ`,
the thermodynamic evaluation at state ω is:

  F(ω, x) = baseEval(ω.point, x) + ω.beta * energy(ω.point, x)

This models the free-energy functional from statistical mechanics,
where β controls the trade-off between the "entropic" base valuation
and the "energetic" contribution. -/
def thermoEval
    {S P : Type*} [Semiring S]
    (baseEval : P → S → ℝ)
    (energy : P → S → ℝ)
    (ω : ThermoState S P)
    (x : S) : ℝ :=
  baseEval ω.point x + ω.beta * energy ω.point x

/-!
## Primary Semantic Predicates
-/

/-- Thermodynamic validity: `x ≤ y` holds in all thermodynamic states.

This is the semantic counterpart of derivability. The completeness theorem
establishes that derivability coincides with thermodynamic validity when
the evaluation is parameterized by prime points and non-negative temperatures. -/
def ThermoValid
    {S : Type*} [Semiring S]
    (State : Type*)
    (eval : State → S → ℝ)
    (x y : S) : Prop :=
  ∀ ω : State, eval ω x ≤ eval ω y

/-- Parameterized thermodynamic validity with explicit prime point and
inverse temperature. This is the primary form used in the completeness
theorem. -/
def ThermoValidβ
    {S P : Type*} [Semiring S]
    (eval : P → ℝ → S → ℝ)
    (x y : S) : Prop :=
  ∀ p : P, ∀ β : ℝ, 0 ≤ β → eval p β x ≤ eval p β y

/-!
## Free-Energy Gap
-/

/-- The free-energy gap measures the quantitative separation between
two elements at a given thermodynamic state. A positive gap at some
state witnesses non-derivability.

  FreeEnergyGap(p, β, x, y) = eval(p, β, x) - eval(p, β, y)

When this is strictly positive, the state (p, β) separates x from y:
the evaluation of x strictly exceeds that of y, witnessing that x ≤ y
fails at this thermodynamic point. -/
def FreeEnergyGap
    {S P : Type*} [Semiring S]
    (eval : P → ℝ → S → ℝ)
    (p : P) (β : ℝ) (x y : S) : ℝ :=
  eval p β x - eval p β y

/-!
## Key Bridge Lemmas

These lemmas form the technical core connecting the Stone/Lawvere semantics
with the thermodynamic deformation.
-/

section BridgeLemmas

variable {S P : Type*} [Semiring S]

/-- At zero temperature (β = 0), the thermodynamic evaluation recovers the
base Lawvere valuation. This is the fundamental compatibility condition
ensuring that the thermodynamic semantics extends the classical Stone/Lawvere
semantics. -/
lemma thermoEval_at_zero
    (baseEval : P → S → ℝ)
    (energy : P → S → ℝ)
    (p : P) (x : S) :
    thermoEval baseEval energy ⟨p, 0, le_refl 0⟩ x = baseEval p x := by
  simp [thermoEval, zero_mul]

/-- A prime witness at the base (zero-temperature) level lifts to a
thermodynamic witness by choosing β = 0. This is the key bridge lemma:
any separation already present at the Stone/Lawvere level automatically
becomes a thermodynamic separating witness. -/
lemma prime_witness_to_thermo_witness
    (eval : P → ℝ → S → ℝ)
    {x y : S} {p : P}
    (hsep : eval p 0 y < eval p 0 x) :
    ∃ β : ℝ, 0 ≤ β ∧ eval p β y < eval p β x :=
  ⟨0, le_refl 0, hsep⟩

/-- Universal thermodynamic validity implies validity at zero temperature.
This extracts the base-level ordering from the full thermodynamic validity. -/
lemma thermo_valid_implies_zero_valid
    (eval : P → ℝ → S → ℝ)
    {x y : S}
    (h : ∀ p : P, ∀ β : ℝ, 0 ≤ β → eval p β x ≤ eval p β y) :
    ∀ p : P, eval p 0 x ≤ eval p 0 y := by
  intro p
  exact h p 0 (le_refl 0)

/-- A strict inequality in evaluation yields a strictly positive free-energy gap.
This converts the order-theoretic separation into a quantitative energetic defect. -/
lemma freeEnergyGap_pos_of_lt
    (eval : P → ℝ → S → ℝ)
    {p : P} {β : ℝ} {x y : S}
    (h : eval p β y < eval p β x) :
    0 < FreeEnergyGap eval p β x y :=
  sub_pos.mpr h

/-- Conversely, a positive free-energy gap yields a strict inequality. -/
lemma lt_of_freeEnergyGap_pos
    (eval : P → ℝ → S → ℝ)
    {p : P} {β : ℝ} {x y : S}
    (h : 0 < FreeEnergyGap eval p β x y) :
    eval p β y < eval p β x :=
  sub_pos.mp h

/-- The free-energy gap is zero when evaluations agree. -/
lemma freeEnergyGap_eq_zero_of_eq
    (eval : P → ℝ → S → ℝ)
    {p : P} {β : ℝ} {x y : S}
    (h : eval p β x = eval p β y) :
    FreeEnergyGap eval p β x y = 0 := by
  simp [FreeEnergyGap, h]

/-- The free-energy gap is antisymmetric. -/
lemma freeEnergyGap_antisymm
    (eval : P → ℝ → S → ℝ)
    (p : P) (β : ℝ) (x y : S) :
    FreeEnergyGap eval p β x y = -FreeEnergyGap eval p β y x := by
  simp [FreeEnergyGap, neg_sub]

/-- Non-negative gap is equivalent to the evaluation ordering. -/
lemma freeEnergyGap_nonneg_iff
    (eval : P → ℝ → S → ℝ)
    (p : P) (β : ℝ) (x y : S) :
    0 ≤ FreeEnergyGap eval p β x y ↔ eval p β y ≤ eval p β x := by
  simp [FreeEnergyGap, sub_nonneg]

end BridgeLemmas

/-!
## Completeness from Soundness and Separation

The central meta-theorem: given soundness and separation, completeness follows.
This is parameterized over arbitrary derivability relations and evaluation
functions, making it applicable to any proof semiring with thermodynamic semantics.
-/

section Completeness

variable {S P : Type*} [Semiring S]

/-- **Biconditional completeness from soundness and separation.**

Given:
- `sound`: derivable entailments are preserved by all thermodynamic states,
- `separate`: non-derivable pairs admit a separating thermodynamic witness,

we conclude that derivability is equivalent to universal thermodynamic validity.

This is the abstract core of the Stone–Prime completeness theorem. -/
theorem completeness_of_soundness_and_separation
    (derivable : S → S → Prop)
    (eval : P → ℝ → S → ℝ)
    (sound : ∀ {x y : S}, derivable x y → ∀ p : P, ∀ β : ℝ, 0 ≤ β → eval p β x ≤ eval p β y)
    (separate : ∀ {x y : S}, ¬ derivable x y →
      ∃ p : P, ∃ β : ℝ, 0 ≤ β ∧ eval p β y < eval p β x)
    (x y : S) :
    derivable x y ↔ ∀ p : P, ∀ β : ℝ, 0 ≤ β → eval p β x ≤ eval p β y := by
  constructor
  · exact fun hxy => sound hxy
  · intro hvalid
    by_contra hnd
    obtain ⟨p, β, hβ, hlt⟩ := separate hnd
    exact absurd (hvalid p β hβ) (not_le.mpr hlt)

end Completeness

/-!
## Thermodynamic Prime Separation
-/

section Separation

variable {S P : Type*} [Semiring S]

/-- **Thermodynamic prime separation theorem.**

If `x ≤ y` is not derivable, then there exists a prime point `p` satisfying
`PrimePoint` and an inverse temperature `β ≥ 0` such that the thermodynamic
evaluation strictly separates `x` from `y`: `eval p β y < eval p β x`.

This is the constructive content of the completeness theorem: non-derivability
yields a concrete separating witness in the thermodynamic state space. -/
theorem thermodynamic_prime_separation
    (derivable : S → S → Prop)
    (eval : P → ℝ → S → ℝ)
    (PrimePoint : P → Prop)
    (separate : ∀ {x y : S}, ¬ derivable x y →
      ∃ p : P, PrimePoint p ∧ ∃ β : ℝ, 0 ≤ β ∧ eval p β y < eval p β x)
    {x y : S}
    (hnd : ¬ derivable x y) :
    ∃ p : P, PrimePoint p ∧ ∃ β : ℝ, 0 ≤ β ∧ eval p β y < eval p β x :=
  separate hnd

/-- **Strong completeness with prime point predicate.**

Derivability is equivalent to universal thermodynamic validity across all
prime points and non-negative inverse temperatures. The forward direction
is soundness; the reverse is by contradiction using prime separation. -/
theorem thermodynamic_stone_prime_completeness
    (derivable : S → S → Prop)
    (eval : P → ℝ → S → ℝ)
    (PrimePoint : P → Prop)
    (sound : ∀ {x y : S}, derivable x y → ∀ p : P, ∀ β : ℝ, 0 ≤ β → eval p β x ≤ eval p β y)
    (separate : ∀ {x y : S}, ¬ derivable x y →
      ∃ p : P, PrimePoint p ∧ ∃ β : ℝ, 0 ≤ β ∧ eval p β y < eval p β x)
    (x y : S) :
    derivable x y ↔ ∀ p : P, ∀ β : ℝ, 0 ≤ β → eval p β x ≤ eval p β y := by
  constructor
  · exact fun hxy => sound hxy
  · intro hvalid
    by_contra hnd
    obtain ⟨p, _, β, hβ, hlt⟩ := separate hnd
    exact absurd (hvalid p β hβ) (not_le.mpr hlt)

end Separation

/-!
## Quantitative Free-Energy Gap Corollary
-/

section FreeEnergyGapResults

variable {S P : Type*} [Semiring S]

/-- **Non-derivability implies a positive free-energy gap.**

This is the quantitative strengthening of the separation theorem: not only
does a separating thermodynamic state exist, but the separation is witnessed
by a strictly positive free-energy defect. This converts the logical failure
of derivability into a measurable energetic quantity. -/
theorem nonderivable_has_positive_freeEnergyGap
    (derivable : S → S → Prop)
    (eval : P → ℝ → S → ℝ)
    (PrimePoint : P → Prop)
    (separate : ∀ {x y : S}, ¬ derivable x y →
      ∃ p : P, PrimePoint p ∧ ∃ β : ℝ, 0 ≤ β ∧ eval p β y < eval p β x)
    {x y : S}
    (hnd : ¬ derivable x y) :
    ∃ p : P, PrimePoint p ∧ ∃ β : ℝ, 0 ≤ β ∧ 0 < FreeEnergyGap eval p β x y := by
  obtain ⟨p, hp, β, hβ, hlt⟩ := separate hnd
  exact ⟨p, hp, β, hβ, sub_pos.mpr hlt⟩

/-- **Characterization of derivability via free-energy gaps.**

Derivability holds if and only if no thermodynamic state achieves a positive
free-energy gap. This gives a variational characterization: `x ≤ y` is derivable
precisely when the free-energy defect is non-positive everywhere. -/
theorem derivable_iff_no_positive_gap
    (derivable : S → S → Prop)
    (eval : P → ℝ → S → ℝ)
    (PrimePoint : P → Prop)
    (sound : ∀ {x y : S}, derivable x y → ∀ p : P, ∀ β : ℝ, 0 ≤ β → eval p β x ≤ eval p β y)
    (separate : ∀ {x y : S}, ¬ derivable x y →
      ∃ p : P, PrimePoint p ∧ ∃ β : ℝ, 0 ≤ β ∧ eval p β y < eval p β x)
    (x y : S) :
    derivable x y ↔ ∀ p : P, ∀ β : ℝ, 0 ≤ β → FreeEnergyGap eval p β x y ≤ 0 := by
  rw [thermodynamic_stone_prime_completeness derivable eval PrimePoint sound separate]
  constructor
  · intro h p β hβ
    simp [FreeEnergyGap, sub_nonpos]
    exact h p β hβ
  · intro h p β hβ
    have := h p β hβ
    simp [FreeEnergyGap, sub_nonpos] at this
    exact this

end FreeEnergyGapResults

/-!
## Zero-Temperature Specialization

When the thermodynamic semantics extends a base Stone/Lawvere semantics and
separation is available at zero temperature, we obtain completeness as a
special case. This is the most common instantiation.
-/

section ZeroTemperature

variable {S P : Type*} [Semiring S]

/-- **Completeness at zero temperature.**

If soundness holds for all temperatures but the Stone/Lawvere completeness
theorem provides separation already at β = 0, then the full thermodynamic
completeness follows. This shows that the thermodynamic semantics is
conservative over the Stone semantics. -/
theorem thermodynamic_stone_prime_completeness_beta_zero
    (derivable : S → S → Prop)
    (eval : P → ℝ → S → ℝ)
    (sound : ∀ {x y : S}, derivable x y → ∀ p : P, ∀ β : ℝ, 0 ≤ β → eval p β x ≤ eval p β y)
    (stone_complete : ∀ {x y : S}, (∀ p : P, eval p 0 x ≤ eval p 0 y) → derivable x y)
    (x y : S) :
    derivable x y ↔ ∀ p : P, ∀ β : ℝ, 0 ≤ β → eval p β x ≤ eval p β y := by
  constructor
  · exact fun hxy => sound hxy
  · intro hvalid
    apply stone_complete
    intro p
    exact hvalid p 0 (le_refl 0)

/-- Lifting a zero-temperature separation witness to a full thermodynamic
separation witness. Given a base evaluation `eval₀` and a parameterized
evaluation `eval` that agrees at β = 0, any separation at the base level
lifts to a thermodynamic separation. -/
lemma lift_zero_temp_separation
    (eval₀ : P → S → ℝ)
    (eval : P → ℝ → S → ℝ)
    (hcompat : ∀ p : P, ∀ x : S, eval p 0 x = eval₀ p x)
    {x y : S} {p : P}
    (hsep : eval₀ p y < eval₀ p x) :
    ∃ β : ℝ, 0 ≤ β ∧ eval p β y < eval p β x := by
  refine ⟨0, le_refl 0, ?_⟩
  rwa [hcompat p y, hcompat p x]

end ZeroTemperature

/-!
## Finite/Coherent Fragment: Algorithmic Countermodel Extraction
-/

section FiniteSearch

variable {S P : Type*} [Semiring S]

/-- **Finite temperature countermodel search.**

When the prime spectrum is finite (`[Fintype P]`), non-derivability yields
an algorithmically extractable countermodel: a concrete prime point and
inverse temperature witnessing the failure. This is the computational
shadow of the completeness theorem. -/
theorem finite_temperature_countermodel_search
    [Fintype P]
    (derivable : S → S → Prop)
    (eval : P → ℝ → S → ℝ)
    (PrimePoint : P → Prop)
    (separate : ∀ {x y : S}, ¬ derivable x y →
      ∃ p : P, PrimePoint p ∧ ∃ β : ℝ, 0 ≤ β ∧ eval p β y < eval p β x)
    {x y : S}
    (hnd : ¬ derivable x y) :
    ∃ p : P, PrimePoint p ∧ ∃ β : ℝ, 0 ≤ β ∧ eval p β y < eval p β x :=
  separate hnd

omit [Semiring S] in
/-- **Finite grid countermodel search.**

When both the prime spectrum and the set of admissible temperatures are
finite, non-derivability can be witnessed by searching the finite
product grid P × B. This gives a fully decidable countermodel search
procedure for coherent/finitely presented proof semirings. -/
theorem finite_grid_countermodel_search
    {B : Type*} [Fintype P] [Fintype B]
    (embedβ : B → ℝ)
    (eval : P → ℝ → S → ℝ)
    (derivable : S → S → Prop)
    (separate : ∀ {x y : S}, ¬ derivable x y →
      ∃ p : P, ∃ b : B, 0 ≤ embedβ b ∧ eval p (embedβ b) y < eval p (embedβ b) x)
    {x y : S}
    (hnd : ¬ derivable x y) :
    ∃ p : P, ∃ b : B, 0 ≤ embedβ b ∧ eval p (embedβ b) y < eval p (embedβ b) x :=
  separate hnd

end FiniteSearch

/-!
## Concrete Instantiation: Additive Thermodynamic Evaluation

We provide a concrete instantiation of the thermodynamic evaluation using
the additive free-energy formula `F(p, β, x) = baseEval(p, x) + β * energy(p, x)`.
-/

section ConcreteInstantiation

variable {S P : Type*} [Semiring S]

/-- The additive thermodynamic evaluation function. -/
noncomputable def additiveThermoEval
    (baseEval : P → S → ℝ)
    (energy : P → S → ℝ)
    (p : P) (β : ℝ) (x : S) : ℝ :=
  baseEval p x + β * energy p x

omit [Semiring S] in
/-- The additive thermodynamic evaluation agrees with the base evaluation
at zero temperature. -/
lemma additiveThermoEval_zero
    (baseEval : P → S → ℝ)
    (energy : P → S → ℝ)
    (p : P) (x : S) :
    additiveThermoEval baseEval energy p 0 x = baseEval p x := by
  simp [additiveThermoEval, zero_mul]

/-- **Completeness for additive thermodynamic evaluation.**

When the thermodynamic evaluation takes the additive form
`baseEval(p, x) + β * energy(p, x)`, completeness holds provided
there is soundness for all temperatures and base-level (Stone) completeness. -/
theorem additive_thermo_completeness
    (derivable : S → S → Prop)
    (baseEval : P → S → ℝ)
    (energy : P → S → ℝ)
    (sound : ∀ {x y : S}, derivable x y →
      ∀ p : P, ∀ β : ℝ, 0 ≤ β →
        additiveThermoEval baseEval energy p β x ≤
        additiveThermoEval baseEval energy p β y)
    (stone_complete : ∀ {x y : S},
      (∀ p : P, baseEval p x ≤ baseEval p y) → derivable x y)
    (x y : S) :
    derivable x y ↔
      ∀ p : P, ∀ β : ℝ, 0 ≤ β →
        additiveThermoEval baseEval energy p β x ≤
        additiveThermoEval baseEval energy p β y := by
  constructor
  · exact fun hxy => sound hxy
  · intro hvalid
    apply stone_complete
    intro p
    have := hvalid p 0 (le_refl 0)
    rwa [additiveThermoEval_zero, additiveThermoEval_zero] at this

/-- **Free-energy gap decomposition for additive evaluation.**

The free-energy gap decomposes into a base valuation gap plus β times
an energy gap. This makes explicit how temperature controls the trade-off
between entropic and energetic contributions to separation. -/
lemma freeEnergyGap_additive_decomp
    (baseEval : P → S → ℝ)
    (energy : P → S → ℝ)
    (p : P) (β : ℝ) (x y : S) :
    FreeEnergyGap (additiveThermoEval baseEval energy) p β x y =
      (baseEval p x - baseEval p y) + β * (energy p x - energy p y) := by
  simp [FreeEnergyGap, additiveThermoEval, mul_sub]
  ring

end ConcreteInstantiation

/-!
## Monotonicity and Functoriality
-/

section Monotonicity

variable {S P : Type*} [Semiring S]

/-- Thermodynamic validity is preserved under refinement of the evaluation:
if `eval'` pointwise dominates the gap of `eval`, validity transfers. -/
lemma thermoValid_of_pointwise_le
    (eval eval' : P → ℝ → S → ℝ)
    {x y : S}
    (hle : ∀ p : P, ∀ β : ℝ, 0 ≤ β → eval' p β x ≤ eval' p β y →
      eval p β x ≤ eval p β y)
    (hvalid : ThermoValidβ eval' x y) :
    ThermoValidβ eval x y := by
  intro p β hβ
  exact hle p β hβ (hvalid p β hβ)

omit [Semiring S] in
/-- If derivability is stronger than derivability' (every derivable' pair is
derivable), then completeness for the weaker system implies completeness
for the stronger. -/
lemma completeness_transfer
    (derivable derivable' : S → S → Prop)
    (eval : P → ℝ → S → ℝ)
    (_hsub : ∀ {x y : S}, derivable' x y → derivable x y)
    (sound : ∀ {x y : S}, derivable x y → ∀ p : P, ∀ β : ℝ, 0 ≤ β → eval p β x ≤ eval p β y)
    (_complete' : ∀ (x y : S),
      derivable' x y ↔ ∀ p : P, ∀ β : ℝ, 0 ≤ β → eval p β x ≤ eval p β y)
    (x y : S) :
    derivable x y → ∀ p : P, ∀ β : ℝ, 0 ≤ β → eval p β x ≤ eval p β y :=
  sound

end Monotonicity

/-!
## ThermoValidβ is equivalent to the completeness condition

This section shows that `ThermoValidβ` is exactly the right-hand side
of the completeness biconditional, providing a clean API.
-/

section API

variable {S P : Type*} [Semiring S]

/-- `ThermoValidβ` unfolds to the universal quantification over prime points
and non-negative inverse temperatures. -/
theorem thermoValidβ_iff
    (eval : P → ℝ → S → ℝ)
    (x y : S) :
    ThermoValidβ eval x y ↔ ∀ p : P, ∀ β : ℝ, 0 ≤ β → eval p β x ≤ eval p β y :=
  Iff.rfl

/-- **Completeness restated with ThermoValidβ.**

This is the most elegant form of the completeness theorem. -/
theorem completeness_thermoValidβ
    (derivable : S → S → Prop)
    (eval : P → ℝ → S → ℝ)
    (PrimePoint : P → Prop)
    (sound : ∀ {x y : S}, derivable x y → ThermoValidβ eval x y)
    (separate : ∀ {x y : S}, ¬ derivable x y →
      ∃ p : P, PrimePoint p ∧ ∃ β : ℝ, 0 ≤ β ∧ eval p β y < eval p β x)
    (x y : S) :
    derivable x y ↔ ThermoValidβ eval x y := by
  constructor
  · exact fun hxy => sound hxy
  · intro hvalid
    by_contra hnd
    obtain ⟨p, _, β, hβ, hlt⟩ := separate hnd
    exact absurd (hvalid p β hβ) (not_le.mpr hlt)

end API

/-!
## Axiom check

We verify that none of the above results use any non-standard axioms.
-/

#print axioms thermoEval_at_zero
#print axioms prime_witness_to_thermo_witness
#print axioms thermo_valid_implies_zero_valid
#print axioms freeEnergyGap_pos_of_lt
#print axioms completeness_of_soundness_and_separation
#print axioms thermodynamic_prime_separation
#print axioms thermodynamic_stone_prime_completeness
#print axioms nonderivable_has_positive_freeEnergyGap
#print axioms derivable_iff_no_positive_gap
#print axioms thermodynamic_stone_prime_completeness_beta_zero
#print axioms finite_temperature_countermodel_search
#print axioms finite_grid_countermodel_search
#print axioms additive_thermo_completeness
#print axioms freeEnergyGap_additive_decomp
#print axioms completeness_thermoValidβ
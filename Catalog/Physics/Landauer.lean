/-
# Tropical Thermodynamics: Landauer's Principle

This file establishes a tropical (min-plus) formulation of Landauer's principle,
the foundational result linking irreversible computation to entropy loss.

## Main Results

* `entropyDefect` — the tropical entropy defect of a map, measuring information loss
* `card_range_eq_one_of_constant` — a constant map has range of cardinality 1
* `tropical_landauer_finite` — erasure of ≥2 states costs ≥ log 2 in entropy defect
* `tropical_landauer_noninjective` — any non-injective map has non-negative entropy defect

## Mathematical Context

Landauer's principle (1961) states that erasing one bit of information requires
dissipating at least kT ln 2 of energy. Our tropical formulation captures the
information-theoretic core: the entropy defect log|α| - log|range(f)| measures
how many distinguishable states are collapsed by f. For an erasure map (constant
function) on ≥2 states, this defect is at least log 2.

This is the zero-temperature limit of classical Landauer: when thermal fluctuations
vanish, entropy loss reduces to a purely combinatorial quantity — the logarithm of
the cardinality collapse ratio.
-/

import Mathlib

open Real Set Fintype

/-- The **tropical entropy defect** of a map `f : α → β` between finite types.
Measures the information lost by applying `f`, in natural-log units.
Equal to `log |α| - log |range f|`. -/
noncomputable def entropyDefect
    {α β : Type*} [Fintype α] [Fintype β] [DecidableEq β]
    (f : α → β) : ℝ :=
  Real.log (Fintype.card α) - Real.log (Fintype.card (Set.range f))

/-
The range of a constant function on a nonempty type has cardinality 1.
-/
theorem card_range_eq_one_of_constant
    {α β : Type*} [Fintype α] [Fintype β] [DecidableEq β]
    [Nonempty α]
    (f : α → β)
    (hconst : ∀ a a', f a = f a') :
    Fintype.card (Set.range f) = 1 := by
  simp +decide [ show range f = { f ( Classical.arbitrary α ) } from Set.eq_singleton_iff_unique_mem.2 ⟨ Set.mem_range.2 ⟨ Classical.arbitrary α, rfl ⟩, fun b hb => by obtain ⟨ a, rfl ⟩ := Set.mem_range.1 hb; exact hconst _ _ ⟩ ]

/-
**Tropical Landauer's Principle (Erasure Bound).**
For a constant map on a finite type with at least 2 elements,
the entropy defect is at least log 2. This is the tropical
analogue of Landauer's principle: erasing one bit of information
incurs an irreducible entropy cost.

Mathematically: if `f` is constant and `|α| ≥ 2`, then
`log |α| - log |range f| ≥ log 2`, which simplifies to
`log |α| ≥ log 2` since `|range f| = 1`.
-/
theorem tropical_landauer_finite
    {α β : Type*} [Fintype α] [Fintype β]
    [DecidableEq α] [DecidableEq β]
    (f : α → β)
    (hconst : ∀ a a', f a = f a')
    (hcard : 2 ≤ Fintype.card α) :
    Real.log 2 ≤ entropyDefect f := by
  have h_range : Fintype.card ( Set.range f ) = 1 := by
    rcases isEmpty_or_nonempty α with h | h;
    · simp +decide [ card ] at hcard;
    · convert card_range_eq_one_of_constant f hconst;
  unfold entropyDefect;
  rw [ h_range, Nat.cast_one, Real.log_one, sub_zero ] ; gcongr ; norm_cast

/-
**Tropical Irreversibility Bound.**
Any non-injective map between finite types has non-negative entropy defect.
This captures the fundamental asymmetry of irreversible computation:
collapsing states can only increase entropy (decrease information).

The proof uses the fact that a non-injective map on a finite type
must have strictly smaller range than domain.
-/
theorem tropical_landauer_noninjective
    {α β : Type*} [Fintype α] [Fintype β]
    [DecidableEq α] [DecidableEq β]
    (f : α → β)
    (hninj : ¬ Function.Injective f) :
    0 ≤ entropyDefect f := by
  refine' sub_nonneg_of_le ( Real.log_le_log _ _ );
  · rcases isEmpty_or_nonempty α with ( h | h ) <;> simp_all +decide;
    exact hninj fun x y => h.elim x;
  · exact_mod_cast Fintype.card_range_le f
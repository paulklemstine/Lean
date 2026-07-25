import Mathlib

/-!
# Guarded Fixed-Point Index Theory

## Overview

This file develops a quantitative obstruction theory for guarded self-reference in
reversible temporal computation. The central idea is to attach a numerical index —
the **guarded fixed-point index** — to any guarded endomorphism, measuring the
irreducible feedback cost required to realize a fixed point.

Classical Lawvere-style diagonal arguments tell us *whether* a fixed point exists.
The guarded fixed-point index tells us *how much* guarded delay / closure weight
is irreducibly required, turning self-reference from a yes/no phenomenon into a
quantitative certificate.

## Main definitions

* `GuardedEnd α` — a guarded endomorphism on type `α`, carrying a morphism `f : α → α`,
  an oracle level, and a guard cost in `WithTop ℕ`.
* `RealizesAt g k` — the realizability predicate: budget `k` admits a guarded feedback
  witness for `g`.
* `fixedPointIndex g` — the least admissible closure/feedback weight (infimum of
  realizable budgets).
* `GuardedEnd.Le g h` — semantic domination preorder.
* `TraceConj g h` — trace-conjugacy under reversible equivalence.
* `GuardedEnd.comp g h` — stratified composition under oracle extension.
* `Eliminable g` — existence of a zero-cost representative in the same conjugacy class.
* `entropyBound` — an order-preserving entropy/complexity observable.
* `temporalFeedbackComplexity g` — the entropy bound applied to the fixed-point index.

## Main results

* `fixedPointIndex_eq_guardCost` — the infimum-based index equals the guard cost.
* `fixedPointIndex_least` — the index is the least realizable budget.
* `fixedPointIndex_mono` — monotonicity under enrichment order.
* `fixedPointIndex_traceConj_invariant` — invariance under trace-conjugacy.
* `fixedPointIndex_comp_eq` — exact additivity under stratified composition.
* `fixedPointIndex_zero_of_eliminable` — index zero for eliminable endomorphisms.
* `not_eliminable_of_pos_index` — nonzero index obstructs elimination.
* `entropy_monotone_of_monotone_map` — entropy monotonicity under monotone maps.
* `entropy_lower_bound_of_pos_index` — positive index forces positive entropy.
* `temporalFeedbackComplexity_lower_bound` — the central result: nonzero guarded
  fixed-point index forces nontrivial temporal feedback complexity.

## References

The conceptual framework connects:
- Lawvere's fixed-point theorem (categorical self-reference),
- traced monoidal categories (feedback semantics with quantitative weights),
- tropical/idempotent semiring methods (dequantization of complexity measures).

-/

open scoped ENNReal BigOperators

namespace GuardedFixedPointIndex

/-! ## Core Definitions -/

/-- A concrete guarded endomorphism carrying a morphism, an oracle level,
and a quantitative guard bound. The interpretation is that one application
of `f` must cross at least `guardCost` units of guarded delay / closure weight. -/
structure GuardedEnd (α : Type*) where
  /-- The underlying endofunction -/
  f : α → α
  /-- The oracle stratum at which this endomorphism operates -/
  oracleLevel : ℕ
  /-- The minimum guarded delay cost for one application -/
  guardCost : WithTop ℕ

/-- The realizability predicate: budget `k` admits a guarded feedback witness for `g`
when the guard cost is at most `k`. -/
def RealizesAt {α : Type*} (g : GuardedEnd α) (k : WithTop ℕ) : Prop :=
  g.guardCost ≤ k

/-- The guarded fixed-point index: the least admissible closure/feedback weight.
Defined as the infimum of all budgets that realize the guarded endomorphism. -/
noncomputable def fixedPointIndex {α : Type*} (g : GuardedEnd α) : WithTop ℕ :=
  sInf {k : WithTop ℕ | RealizesAt g k}

/-- Semantic domination preorder on guarded endomorphisms: `g` is dominated by `h`
when `h` operates at a higher or equal oracle level with higher or equal guard cost. -/
def GuardedEnd.Le {α : Type*} (g h : GuardedEnd α) : Prop :=
  g.oracleLevel ≤ h.oracleLevel ∧ g.guardCost ≤ h.guardCost

/-- Trace-conjugacy under reversible equivalence: two guarded endomorphisms are
trace-conjugate when they are related by a permutation conjugation that preserves
oracle level and guard cost. This captures the idea that the index depends only on
guarded feedback semantics, not on presentation. -/
def TraceConj {α : Type*} (g h : GuardedEnd α) : Prop :=
  ∃ e : Equiv.Perm α, h.f = e ∘ g.f ∘ e.symm ∧
    g.oracleLevel = h.oracleLevel ∧
    g.guardCost = h.guardCost

/-- Stratified composition of guarded endomorphisms under oracle extension.
The oracle level is the maximum of the two levels (both oracles are needed),
and the guard cost is additive (both guards must be crossed). -/
def GuardedEnd.comp {α : Type*} (g h : GuardedEnd α) : GuardedEnd α :=
  { f := g.f ∘ h.f
    oracleLevel := max g.oracleLevel h.oracleLevel
    guardCost := g.guardCost + h.guardCost }

/-- A guarded endomorphism is eliminable if there exists a zero-cost representative
in the same trace-conjugacy class. This means the guarded self-reference can be
removed without changing the semantic content. -/
def Eliminable {α : Type*} (g : GuardedEnd α) : Prop :=
  ∃ h : GuardedEnd α, TraceConj g h ∧ fixedPointIndex h = 0

/-- The entropy bound observable. In the concrete first version, this is the identity,
representing that entropy cost is at least the feedback weight. This can be replaced
by a more refined dequantization map when connecting to density-theoretic semantics. -/
def entropyBound : WithTop ℕ → WithTop ℕ := id

/-- The temporal feedback complexity of a guarded endomorphism: the entropy bound
applied to the fixed-point index. This is the central observable connecting
self-reference to computational cost. -/
noncomputable def temporalFeedbackComplexity {α : Type*} (g : GuardedEnd α) : WithTop ℕ :=
  entropyBound (fixedPointIndex g)

/-! ## Foundational Lemmas -/

/-- The guard cost itself is a realizable budget. -/
theorem realizesAt_guardCost {α : Type*} (g : GuardedEnd α) :
    RealizesAt g g.guardCost := by
  exact le_refl _

/-- Minimality: any realizable budget is at least the guard cost. -/
theorem guardCost_le_of_realizesAt {α : Type*} (g : GuardedEnd α) (k : WithTop ℕ)
    (hk : RealizesAt g k) : g.guardCost ≤ k :=
  hk

/-- The set of realizable budgets is nonempty. -/
theorem realizesAt_nonempty {α : Type*} (g : GuardedEnd α) :
    {k : WithTop ℕ | RealizesAt g k}.Nonempty :=
  ⟨g.guardCost, realizesAt_guardCost g⟩

/-! ## Index Characterization -/

/-
**Infimum characterization**: the fixed-point index equals the guard cost.
This is the fundamental identity connecting the infimum-based definition to
the concrete guard cost parameter.
-/
theorem fixedPointIndex_eq_guardCost {α : Type*} (g : GuardedEnd α) :
    fixedPointIndex g = g.guardCost := by
  refine' le_antisymm _ _;
  · exact csInf_le ⟨ 0, fun k hk => by aesop ⟩ ( realizesAt_guardCost g );
  · exact le_csInf ( realizesAt_nonempty g ) fun k hk => hk

/-
**Least budget theorem**: the fixed-point index is realizable and is the
least realizable budget. This is the formal seed of the obstruction theory.
-/
theorem fixedPointIndex_least {α : Type*} (g : GuardedEnd α) :
    RealizesAt g (fixedPointIndex g) ∧
    ∀ k, RealizesAt g k → fixedPointIndex g ≤ k := by
  rw [ fixedPointIndex_eq_guardCost ];
  exact ⟨ le_rfl, fun k hk => hk ⟩

/-
The fixed-point index is positive iff the guard cost is positive.
-/
theorem fixedPointIndex_pos_iff {α : Type*} (g : GuardedEnd α) :
    0 < fixedPointIndex g ↔ 0 < g.guardCost := by
  rw [ fixedPointIndex_eq_guardCost ]

/-! ## Monotonicity -/

/-
**Monotonicity under enrichment order**: if `g` is semantically dominated
by `h`, then the fixed-point index of `g` is at most that of `h`.
-/
theorem fixedPointIndex_mono {α : Type*} {g h : GuardedEnd α}
    (hle : GuardedEnd.Le g h) :
    fixedPointIndex g ≤ fixedPointIndex h := by
  -- By definition of fixed-point index, we know that `fixedPointIndex g = g.guardCost` and `fixedPointIndex h = h.guardCost`.
  have h_index_eq_guardCost : fixedPointIndex g = g.guardCost ∧ fixedPointIndex h = h.guardCost := by
    exact ⟨ fixedPointIndex_eq_guardCost g, fixedPointIndex_eq_guardCost h ⟩;
  exact h_index_eq_guardCost.1.symm ▸ h_index_eq_guardCost.2.symm ▸ hle.2

/-
Monotonicity from oracle level and guard cost bounds.
-/
theorem fixedPointIndex_oracle_monotone {α : Type*} {g h : GuardedEnd α}
    (hlev : g.oracleLevel ≤ h.oracleLevel)
    (hcost : g.guardCost ≤ h.guardCost) :
    fixedPointIndex g ≤ fixedPointIndex h := by
  -- Apply the fixedPointIndex_mono theorem with the given hypotheses.
  apply fixedPointIndex_mono; exact ⟨hlev, hcost⟩

/-! ## Trace-Conjugacy Invariance -/

/-
Trace-conjugacy is reflexive.
-/
theorem TraceConj.refl {α : Type*} (g : GuardedEnd α) : TraceConj g g := by
  exact ⟨ Equiv.refl α, rfl, rfl, rfl ⟩

/-
Trace-conjugacy is symmetric.
-/
theorem TraceConj.symm {α : Type*} {g h : GuardedEnd α} (hconj : TraceConj g h) :
    TraceConj h g := by
  obtain ⟨ e, he ⟩ := hconj;
  exact ⟨ e.symm, by aesop ⟩

/-
**Invariance under trace-conjugacy**: the fixed-point index depends only on
the guarded feedback semantics, not on the presentation of the endomorphism.
-/
theorem fixedPointIndex_traceConj_invariant {α : Type*} {g h : GuardedEnd α}
    (hconj : TraceConj g h) :
    fixedPointIndex g = fixedPointIndex h := by
  obtain ⟨ e, he ⟩ := hconj;
  rw [ fixedPointIndex_eq_guardCost, fixedPointIndex_eq_guardCost, he.2.2 ]

/-! ## Composition and Additivity -/

/-
The oracle level of a composition is the maximum of the component levels.
-/
theorem oracleLevel_comp {α : Type*} (g h : GuardedEnd α) :
    (g.comp h).oracleLevel = max g.oracleLevel h.oracleLevel := by
  rfl

/-
The guard cost of a composition is the sum of the component costs.
-/
theorem guardCost_comp {α : Type*} (g h : GuardedEnd α) :
    (g.comp h).guardCost = g.guardCost + h.guardCost := by
  rfl

/-
**Exact additivity**: the fixed-point index of a composition equals the sum
of the component indices. This reflects that stratified oracle extension requires
crossing both guards.
-/
theorem fixedPointIndex_comp_eq {α : Type*} (g h : GuardedEnd α) :
    fixedPointIndex (g.comp h) = fixedPointIndex g + fixedPointIndex h := by
  -- By Lemma 2, the guard cost of a composition is the sum of the component costs.
  rw [fixedPointIndex_eq_guardCost, fixedPointIndex_eq_guardCost, fixedPointIndex_eq_guardCost];
  rfl

/-
**Subadditivity** (follows from exact additivity).
-/
theorem fixedPointIndex_comp_le {α : Type*} (g h : GuardedEnd α) :
    fixedPointIndex (g.comp h) ≤ fixedPointIndex g + fixedPointIndex h := by
  rw [ fixedPointIndex_comp_eq ]

/-! ## Elimination Obstruction -/

/-
**Index zero for eliminable endomorphisms**: if a guarded endomorphism
is eliminable (has a zero-cost conjugate), then its own index is zero.
This follows from trace-conjugacy invariance.
-/
theorem fixedPointIndex_zero_of_eliminable {α : Type*} {g : GuardedEnd α}
    (helim : Eliminable g) :
    fixedPointIndex g = 0 := by
  obtain ⟨ h, hconj, hindex ⟩ := helim;
  rw [ ← hindex, fixedPointIndex_traceConj_invariant hconj ]

/-
**Obstruction theorem**: nonzero fixed-point index obstructs elimination.
This is the contrapositive of `fixedPointIndex_zero_of_eliminable` and is
the theorem that upgrades fixed-point semantics into a certificate of
irreducible feedback.
-/
theorem not_eliminable_of_pos_index {α : Type*} {g : GuardedEnd α}
    (hpos : 0 < fixedPointIndex g) :
    ¬ Eliminable g := by
  exact fun h => hpos.ne' ( fixedPointIndex_zero_of_eliminable h )

/-
Nonzero guard cost implies non-eliminability.
-/
theorem not_eliminable_of_guardCost_pos {α : Type*} {g : GuardedEnd α}
    (hpos : 0 < g.guardCost) :
    ¬ Eliminable g := by
  exact not_eliminable_of_pos_index ( fixedPointIndex_pos_iff g |>.2 hpos )

/-! ## Entropy Monotonicity -/

/-
**Entropy monotonicity under monotone maps**: any monotone observable
preserves the ordering of fixed-point indices.
-/
theorem entropy_monotone_of_monotone_map {α : Type*}
    (φ : WithTop ℕ → WithTop ℕ) (hφ : Monotone φ) {g h : GuardedEnd α}
    (hle : GuardedEnd.Le g h) :
    φ (fixedPointIndex g) ≤ φ (fixedPointIndex h) := by
  exact hφ ( fixedPointIndex_mono hle )

/-
**Entropy lower bound**: any monotone observable that is positive on
positive inputs gives a positive lower bound for positive-index endomorphisms.
-/
theorem entropy_lower_bound_of_pos_index {α : Type*}
    (φ : WithTop ℕ → WithTop ℕ) (_hφ : Monotone φ)
    (hφpos : ∀ n : WithTop ℕ, 0 < n → 0 < φ n)
    {g : GuardedEnd α} (hpos : 0 < fixedPointIndex g) :
    0 < φ (fixedPointIndex g) := by
  exact hφpos _ hpos

/-
The entropy bound is monotone.
-/
theorem entropyBound_monotone : Monotone entropyBound := by
  exact monotone_id

/-
The entropy bound preserves positivity.
-/
theorem entropyBound_pos {n : WithTop ℕ} (hn : 0 < n) : 0 < entropyBound n := by
  exact hn

/-
**Central theorem**: nonzero guarded fixed-point index forces nontrivial
temporal feedback complexity. This is the main result connecting categorical
self-reference to computational lower bounds.
-/
theorem temporalFeedbackComplexity_lower_bound {α : Type*}
    {g : GuardedEnd α} (hpos : 0 < fixedPointIndex g) :
    0 < temporalFeedbackComplexity g := by
  exact entropyBound_pos hpos

end GuardedFixedPointIndex
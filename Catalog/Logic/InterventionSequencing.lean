import Mathlib

/-!
# Certified Intervention Sequencing for Multi-Objective Systems

This module formalizes a structural theory connecting multi-objective bottleneck analysis
with Pareto optimization and hypergraph transversal theory. The central insight is that
**Pareto-optimal interventions in the binary bottleneck model correspond exactly to
minimal hitting sets (transversals) of the family of bottleneck sets**.

## Main Results

- `gain`: Binary gain function — objective `i` improves iff plan `S` intersects bottleneck `B i`.
- `improvesAll_iff_hits_all`: A plan improves all objectives iff it is a hitting set.
- `exists_universal_singleton_of_inter_nonempty`: Common bottleneck element gives universal improvement.
- `pareto_minimal_iff_minimal_hittingSet`: Pareto-minimal feasible plans = minimal hitting sets.
- `card_lower_bound_of_pairwise_disjoint_bottlenecks`: Disjoint bottlenecks force large plans.
- `no_universal_singleton_of_pairwise_disjoint`: Disjoint bottlenecks preclude universal singletons.
- `strict_pareto_of_common_critical`: Weighted/monotone generalization via critical sets.

## Mathematical Context

This establishes a formal bridge between:
- **Hypergraph theory**: bottleneck families as hypergraphs; interventions as transversals
- **Multi-criteria optimization**: Pareto frontiers characterized combinatorially
- **Operations research**: certified upgrade planning with provable non-dominance
-/

open Finset

variable {α ι : Type*}

/-! ## Definitions -/

/-- Binary gain function: objective `i` gains value 1 from plan `S` iff `S` intersects
the bottleneck set `B i`. This models the simplest bottleneck scenario where any
single component upgrade in the bottleneck set suffices to improve the objective. -/
def gain [DecidableEq α] (B : ι → Finset α) (i : ι) (S : Finset α) : ℕ :=
  if (∃ a, a ∈ S ∧ a ∈ B i) then 1 else 0

/-- A plan `S` improves all objectives: every objective's gain is 1. -/
def ImprovesAll [DecidableEq α] (B : ι → Finset α) (S : Finset α) : Prop :=
  ∀ i, gain B i S = 1

/-- A plan `S` is a hitting set for the bottleneck family: it intersects every `B i`. -/
def IsHittingSet [DecidableEq α] (B : ι → Finset α) (S : Finset α) : Prop :=
  ∀ i, ∃ a, a ∈ S ∧ a ∈ B i

/-- A plan `S` is a minimal hitting set: it hits all bottleneck sets, but no proper
subset does. This is the combinatorial characterization of Pareto minimality. -/
def IsMinimalHittingSet [DecidableEq α] (B : ι → Finset α) (S : Finset α) : Prop :=
  IsHittingSet B S ∧ ∀ T, T ⊂ S → ¬IsHittingSet B T

/-- Pareto dominance in the binary bottleneck model: `S` Pareto-dominates `T` if
`S` achieves at least as much gain as `T` on every objective, and strictly more on some. -/
def ParetoDominates [DecidableEq α] (B : ι → Finset α) (S T : Finset α) : Prop :=
  (∀ i, gain B i T ≤ gain B i S) ∧ ∃ i, gain B i T < gain B i S

/-- A feasible plan (improving all objectives) is Pareto-minimal if no proper subset
also improves all objectives. In the binary bottleneck model, this captures the notion
that every component in `S` is essential for covering some bottleneck. -/
def ParetoMinimal [DecidableEq α] (B : ι → Finset α) (S : Finset α) : Prop :=
  ImprovesAll B S ∧ ∀ T, T ⊂ S → ¬ImprovesAll B T

/-! ## Core Theorems -/

/-
**Improvement–Hitting Set Equivalence**: A plan improves all objectives if and only if
it is a hitting set for the bottleneck family. This is the fundamental bridge between
optimization language and combinatorial set theory.
-/
theorem improvesAll_iff_hits_all [DecidableEq α]
    (B : ι → Finset α) (S : Finset α) :
    (∀ i : ι, gain B i S = 1) ↔ (∀ i : ι, ∃ a, a ∈ S ∧ a ∈ B i) := by
  unfold gain; aesop;

/-
**Universal Singleton from Common Intersection**: If all bottleneck sets share a
common element, then the singleton plan at that element achieves gain 1 for every
objective. This formalizes the "keystone component" phenomenon.
-/
theorem exists_universal_singleton_of_inter_nonempty
    [DecidableEq α] [Fintype ι]
    (B : ι → Finset α)
    (h : ∃ a, ∀ i : ι, a ∈ B i) :
    ∃ a, ∀ i : ι, gain B i ({a} : Finset α) = 1 := by
  unfold gain; aesop;

/-
**Pareto Minimality = Minimal Hitting Set**: Among plans that improve all objectives,
the Pareto-minimal ones are exactly the inclusion-minimal hitting sets.
This is the central structural theorem: **multi-objective intervention planning is
hypergraph transversal theory in disguise**.
-/
theorem pareto_minimal_iff_minimal_hittingSet
    [DecidableEq α] [Fintype ι]
    (B : ι → Finset α) (S : Finset α) :
    ParetoMinimal B S ↔ IsMinimalHittingSet B S := by
  constructor <;> rintro ⟨h₁, h₂⟩;
  · exact ⟨ fun i => by simpa [ gain ] using h₁ i, fun T hT hT' => h₂ T hT fun i => by simpa [ gain ] using hT' i ⟩;
  · exact ⟨ fun i => by simpa [ gain ] using h₁ i, fun T hT hT' => h₂ T hT ( fun i => by simpa [ gain ] using hT' i ) ⟩

/-
**Disjoint Bottleneck Lower Bound**: If bottleneck sets are pairwise disjoint,
then any hitting set must have cardinality at least the number of objectives.
This is a sharp tradeoff certificate: structurally separated objectives require
proportionally many interventions.
-/
theorem card_lower_bound_of_pairwise_disjoint_bottlenecks
    [DecidableEq α] [Fintype ι] [DecidableEq ι]
    (B : ι → Finset α)
    (hpair : Pairwise (fun i j => Disjoint (B i) (B j)))
    (S : Finset α)
    (hS : ∀ i : ι, ∃ a, a ∈ S ∧ a ∈ B i) :
    Fintype.card ι ≤ S.card := by
  -- By definition of $f$, we know that for each $i$, $f i$ is an element of $S$ that is also in $B i$.
  have h_f_image : Finset.card (Finset.image (fun i => Classical.choose (hS i)) (Finset.univ : Finset ι)) ≤ Finset.card S := by
    exact Finset.card_le_card ( Finset.image_subset_iff.mpr fun i _ => Classical.choose_spec ( hS i ) |>.1 );
  rwa [ Finset.card_image_of_injective _ fun i j hij => Classical.not_not.1 fun hi => Finset.disjoint_left.1 ( hpair hi ) ( Classical.choose_spec ( hS i ) |>.2 ) ( hij.symm ▸ Classical.choose_spec ( hS j ) |>.2 ), Finset.card_univ ] at h_f_image

/-
**No Universal Singleton Under Disjointness**: When there are at least two objectives
with pairwise disjoint bottleneck sets, no single intervention can improve all objectives.
This is a certified impossibility theorem for universal low-cost interventions.
-/
theorem no_universal_singleton_of_pairwise_disjoint
    [DecidableEq α] [Fintype ι] [DecidableEq ι]
    (hι : 1 < Fintype.card ι)
    (B : ι → Finset α)
    (hpair : Pairwise (fun i j => Disjoint (B i) (B j))) :
    ¬∃ a, ∀ i : ι, gain B i ({a} : Finset α) = 1 := by
  exact fun ⟨ a, ha ⟩ ↦ absurd ( card_lower_bound_of_pairwise_disjoint_bottlenecks B hpair { a } fun i ↦ by simpa [ gain ] using ha i ) ( by simp +decide ; linarith )

/-! ## Weighted / Monotone Generalization -/

/-
**Strict Pareto Improvement from Common Critical Element**: In the weighted/monotone
model, if there exists an element that is critical for every objective at baseline `S₀`
(inserting it strictly increases the capacity for each objective), then that element
yields a strict Pareto improvement. This generalizes the binary bottleneck theorem
to actual system metrics.
-/
theorem strict_pareto_of_common_critical
    [DecidableEq α]
    (c : ι → Finset α → ℕ)
    (S₀ : Finset α)
    (B : ι → Finset α)
    (hcrit : ∀ i a, a ∈ B i → c i (insert a S₀) > c i S₀)
    (hcommon : ∃ a, ∀ i, a ∈ B i) :
    ∃ a, ∀ i, c i (insert a S₀) > c i S₀ := by
  exact ⟨ hcommon.choose, fun i => hcrit i _ ( hcommon.choose_spec i ) ⟩
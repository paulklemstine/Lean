/-
Copyright (c) 2025. All rights reserved.

# Idempotent Large Deviations: the Contraction Principle

This file develops the **idempotent contraction principle**, the max-plus analogue
of the classical large-deviation contraction principle:

> If a family satisfies an LDP with rate `I_X` and `T : X → Y` is continuous, then
> the push-forward satisfies an LDP with rate `I_Y(y) = inf_{x : T x = y} I_X(x)`.

In the idempotent world the statement is **exact** (no `log`/`exp` smoothing): the
push-forward of a tropical probability `P` along a surjection `T` is again a
tropical probability, its rate function is the fibre-wise infimum of `I_X`, and the
deviation cost of an event `B ⊆ Y` equals the cost of its preimage `T⁻¹(B) ⊆ X`.

This builds directly on `Catalog/Tropical/MeasureTheory/Basic.lean` and
`Catalog/Tropical/MeasureTheory/LargeDeviations.lean` (it reuses the sharp idempotent
LDP `idempotent_ldp_sharp` to identify the push-forward rate).

## Main results

* `pushforwardMeasure_isProb` — the push-forward of a tropical probability is one.
* `pushforward_rate` — the push-forward rate is the fibre-wise infimum of `I_X`.
* `inf'_fiber_eq` — fibration identity for finite infima (core combinatorial lemma).
* `idempotent_contraction` — **contraction principle**: the rate of an event under
  the push-forward equals the rate of its preimage under the original law.
* `idempotent_contraction_measure` — the same statement at the level of the
  max-plus measure (cost form).

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The classical LDP contraction principle should hold in
  the idempotent world, and — like the sharp idempotent LDP — should be *exact* for
  every law rather than only asymptotically.  Bold sub-claim: the push-forward rate
  `I_Y(y) = inf_{x∈T⁻¹y} I_X(x)` is recovered *with no convexity assumption*, in
  contrast to the Legendre–Fenchel duality which genuinely needs convexity
  (`DualityGap.lean`).
Experiment (Experimenter): Defined `pushforwardMeasure` via the fibre supremum of
  the weight, proved it is a tropical probability (the fibres of a surjection
  partition `univ`, so the global sup of `w` is recovered), and identified its rate
  function with the fibre infimum of `I_X` by feeding the fibre `Finset` to the
  catalog's `idempotent_ldp_sharp`.  The contraction principle then reduces to the
  finite fibration identity `inf'_fiber_eq`, an instance of `Finset.inf'_biUnion`.
Analysis (Analyst): The conjecture SURVIVES and is exact.  The contraction principle
  is purely order-theoretic (commutes a min over a fibred index set), which is why
  no convexity is needed — convexity only entered through the Legendre transform,
  and the contraction principle never uses it.  This cleanly separates the two
  "halves" of Cramér's program in the idempotent setting.
Critique (Critic): The push-forward is a genuine `IsTropicalProbability` (not a
  rename), surjectivity is load-bearing (it guarantees non-empty fibres so `inf'`
  is well-defined), and the main theorem uses `le_antisymm`/`Finset.inf'_biUnion`
  rather than `decide`.  The measure-level corollary is non-vacuous because it is
  stated for an arbitrary non-empty event `B`.
-- !-- end Lab Notes -- !--
-/

import Mathlib
import Catalog.Tropical.MeasureTheory.Basic
import Catalog.Tropical.MeasureTheory.LargeDeviations

namespace TropicalLDP.Contraction

open TropicalMeasureTheory TropicalLDP Finset Function

variable {X Y : Type*} [Fintype X] [Nonempty X] [Fintype Y] [Nonempty Y]

/-! ## Fibres of a map -/

/-- The **fibre** of `T : X → Y` over `y`: the finite set of points mapping to `y`. -/
def fiber [DecidableEq Y] (T : X → Y) (y : Y) : Finset X :=
  Finset.univ.filter (fun x => T x = y)

/-- The **preimage event** `T⁻¹(B)` of a set of outcomes `B ⊆ Y`. -/
def preimageEvent [DecidableEq Y] (T : X → Y) (B : Finset Y) : Finset X :=
  Finset.univ.filter (fun x => T x ∈ B)

omit [Nonempty X] [Fintype Y] [Nonempty Y] in
theorem fiber_nonempty [DecidableEq Y] {T : X → Y} (hT : Surjective T) (y : Y) :
    (fiber T y).Nonempty := by
  obtain ⟨x, hx⟩ := hT y
  exact ⟨x, by simp [fiber, hx]⟩

omit [Nonempty X] [Fintype Y] [Nonempty Y] in
theorem mem_fiber [DecidableEq Y] {T : X → Y} {y : Y} {x : X} :
    x ∈ fiber T y ↔ T x = y := by simp [fiber]

omit [Nonempty X] [Fintype Y] [Nonempty Y] in
theorem preimageEvent_nonempty [DecidableEq Y] {T : X → Y} (hT : Surjective T)
    {B : Finset Y} (hB : B.Nonempty) : (preimageEvent T B).Nonempty := by
  obtain ⟨y, hy⟩ := hB
  obtain ⟨x, hx⟩ := hT y
  exact ⟨x, by simp [preimageEvent, hx, hy]⟩

omit [Nonempty X] [Fintype Y] [Nonempty Y] in
/-- The preimage event is the (disjoint) union of the fibres over `B`. -/
theorem preimageEvent_eq_biUnion [DecidableEq X] [DecidableEq Y]
    (T : X → Y) (B : Finset Y) :
    preimageEvent T B = B.biUnion (fun y => fiber T y) := by
  ext x; simp [preimageEvent, fiber]

/-! ## Core combinatorial lemma: fibration of a finite infimum -/

/-
**Fibration identity for finite infima**: the infimum of `f` over a preimage
event equals the infimum over the base of the fibre-wise infima.  This is the
order-theoretic heart of the contraction principle.
-/
omit [Nonempty X] [Fintype Y] [Nonempty Y] in
theorem inf'_fiber_eq [DecidableEq X] [DecidableEq Y] {T : X → Y}
    (hT : Surjective T) {B : Finset Y} (hB : B.Nonempty) (f : X → ℝ) :
    (preimageEvent T B).inf' (preimageEvent_nonempty hT hB) f
      = B.inf' hB (fun y => (fiber T y).inf' (fiber_nonempty hT y) f) := by
  convert Finset.inf'_biUnion f hB (fun y => fiber_nonempty hT y) using 2
  exact preimageEvent_eq_biUnion T B

/-! ## The push-forward measure -/

/-- The **push-forward** of a max-plus measure `P` along a surjection `T`: the
weight of `y` is the maximal weight over its fibre, `w_Y(y) = sup_{T x = y} w(x)`. -/
noncomputable def pushforwardMeasure [DecidableEq Y] {T : X → Y} (hT : Surjective T)
    (P : MaxPlusMeasure X) : MaxPlusMeasure Y :=
  ⟨fun y => (fiber T y).sup' (fiber_nonempty hT y) P.weight⟩

/-- Every point of `X` lies in the fibre over its image, so its weight is
dominated by the push-forward weight of that image. -/
theorem le_pushforward_weight [DecidableEq Y] {T : X → Y} (hT : Surjective T)
    (P : MaxPlusMeasure X) (x : X) :
    P.weight x ≤ (pushforwardMeasure hT P).weight (T x) := by
  exact Finset.le_sup' P.weight (mem_fiber.mpr rfl)

/-
The push-forward of a tropical probability is a tropical probability.
-/
instance pushforwardMeasure_isProb [DecidableEq X] [DecidableEq Y] {T : X → Y}
    (hT : Surjective T) (P : MaxPlusMeasure X) [hP : IsTropicalProbability X P] :
    IsTropicalProbability Y (pushforwardMeasure hT P) := by
  constructor;
  · refine' le_antisymm _ _;
    · simp +decide [ pushforwardMeasure ];
      exact fun y x hx => hP.weight_nonpos x;
    · obtain ⟨ x₀, hx₀ ⟩ := Finset.exists_mem_eq_sup' Finset.univ_nonempty P.weight;
      refine' le_trans _ ( Finset.le_sup' _ ( Finset.mem_univ ( T x₀ ) ) );
      exact le_trans ( by linarith [ hP.total_mass ▸ hx₀.2 ] ) ( le_pushforward_weight hT P x₀ );
  · intro y
    have h_fiber : ∀ x ∈ fiber T y, P.weight x ≤ 0 := by
      exact fun x hx => hP.weight_nonpos x;
    convert Finset.sup'_le _ _ h_fiber;
    exact fiber_nonempty hT y

/-
**Push-forward rate** is the fibre-wise infimum of the original rate function:
`I_Y(y) = inf_{T x = y} I_X(x)`.  Proved via the catalog's sharp idempotent LDP.
-/
theorem pushforward_rate [DecidableEq Y] {T : X → Y} (hT : Surjective T)
    (P : MaxPlusMeasure X) (y : Y) :
    idempotentRate (pushforwardMeasure hT P) y
      = (fiber T y).inf' (fiber_nonempty hT y) (idempotentRate P) := by
  convert TropicalLDP.idempotent_ldp_sharp P (fiber_nonempty hT y) using 1

/-! ## The idempotent contraction principle -/

/-
**Idempotent contraction principle (rate form).**  For any non-empty event
`B ⊆ Y`, the deviation cost of `B` under the push-forward law equals the deviation
cost of its preimage `T⁻¹(B)` under the original law:
`inf_{y∈B} I_Y(y) = inf_{x∈T⁻¹B} I_X(x)`.
-/
theorem idempotent_contraction [DecidableEq X] [DecidableEq Y] {T : X → Y}
    (hT : Surjective T) (P : MaxPlusMeasure X) {B : Finset Y} (hB : B.Nonempty) :
    B.inf' hB (idempotentRate (pushforwardMeasure hT P))
      = (preimageEvent T B).inf' (preimageEvent_nonempty hT hB) (idempotentRate P) := by
  convert (inf'_fiber_eq hT hB (idempotentRate P)).symm using 2 with y
  exact pushforward_rate hT P y

/-
**Idempotent contraction principle (measure form).**  The max-plus measure of an
event `B` under the push-forward equals the measure of its preimage `T⁻¹(B)` under
the original law.
-/
theorem idempotent_contraction_measure [DecidableEq X] [DecidableEq Y] {T : X → Y}
    (hT : Surjective T) (P : MaxPlusMeasure X) {B : Finset Y} (hB : B.Nonempty) :
    B.sup' hB (pushforwardMeasure hT P).weight
      = (preimageEvent T B).sup' (preimageEvent_nonempty hT hB) P.weight := by
  refine' le_antisymm _ _ <;> simp_all +decide [ Finset.sup'_le_iff ];
  · -- By definition of supremum, there exists some $x \in \text{preimageEvent } T B$ such that $P.weight x = \sup_{x \in \text{preimageEvent } T B} P.weight x$.
    obtain ⟨x, hx⟩ : ∃ x ∈ preimageEvent T B, ∀ y ∈ preimageEvent T B, P.weight y ≤ P.weight x := by
      exact Finset.exists_max_image _ _ ( preimageEvent_nonempty hT hB );
    refine' ⟨ x, hx.1, fun y hy => _ ⟩ ; simp_all +decide [ pushforwardMeasure ];
    exact fun z hz => hx.2 z ( Finset.mem_filter.mpr ⟨ Finset.mem_univ _, by simpa using Finset.mem_filter.mp hz |>.2 |> fun h => h.symm ▸ hy ⟩ );
  · obtain ⟨ x, hx ⟩ := Finset.exists_mem_eq_sup' ( preimageEvent_nonempty hT hB ) P.weight; use T x; simp_all +decide [ preimageEvent ] ;
    exact fun y hy => le_trans ( hx.2 ▸ Finset.le_sup' _ ( by aesop ) ) ( le_pushforward_weight hT P x )

end TropicalLDP.Contraction
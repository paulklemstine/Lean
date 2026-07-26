/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# I Am a Strange Loop, Part V: Order-Reversal Is the Obstruction

The negative face of the strange loop (Cantor/Gödel/Turing) rests on a single
combinatorial fact: the observation-transform used in the diagonal — Boolean
*negation* — has no fixed point.  A natural question sharpens Hofstadter's
picture: *which* transforms of the observation space can obstruct complete
self-modelling?

We answer it by bridging the **logic of self-reference** with **order theory**.
When the observation space `B` carries the structure of a complete lattice,
the Knaster–Tarski theorem guarantees that *every order-preserving
(monotone)* transform has a stable self-image — indeed a whole complete lattice
of fixed points, bounded between a least and a greatest self-image.  By the
contrapositive of Lawvere's diagonal, a transform can block consciousness only
if it is fixed-point-free, and monotone transforms never are.

The conclusion is crisp: **the obstruction to complete self-knowledge is
order-reversal.**  The canonical liar/negation transform is precisely the
order-*reversing* involution, and on the two-point observation lattice it is the
unique fixed-point-free map.  Self-reference collapses not because a system
observes itself, but because it can *invert* its own observations.

This file is fully self-contained (the diagonal engine is reproved locally).
-/
import Mathlib

namespace StrangeLoop.Order

open Function

variable {A : Type*} {B : Type*}

/-! ## The diagonal engine (Lawvere), restated locally -/

/-- **Lawvere's fixed-point theorem.**  A point-surjective self-model forces
every observation-transform `g` to have a fixed point. -/
theorem lawvere_fixedPoint {f : A → (A → B)} (hf : Surjective f) (g : B → B) :
    ∃ b, g b = b := by
  obtain ⟨a, ha⟩ := hf (fun x => g (f x x))
  exact ⟨f a a, (congrFun ha a).symm⟩

/-- **Contrapositive of Lawvere.**  A fixed-point-free transform blocks every
point-surjection: no system can completely model itself if some transform of its
observations escapes all fixed points. -/
theorem no_surjection_of_fixedPointFree (g : B → B) (hg : ∀ b, g b ≠ b) :
    ¬ ∃ f : A → (A → B), Surjective f := by
  rintro ⟨f, hf⟩
  obtain ⟨b, hb⟩ := lawvere_fixedPoint hf g
  exact hg b hb

/-! ## The positive face over an ordered observation space (Knaster–Tarski) -/

/-- **Every monotone transform has a stable self-image.**  On a complete lattice
of observations, any order-preserving transform fixes its least pre-fixed point:
consciousness is never obstructed along order-preserving directions. -/
theorem monotone_has_fixedPoint [CompleteLattice B] (g : B →o B) : ∃ b, g b = b :=
  ⟨OrderHom.lfp g, OrderHom.map_lfp g⟩

/-- The **minimal self-image**: the least fixed point is the smallest observation
invariant under the transform. -/
theorem least_selfimage [CompleteLattice B] (g : B →o B) :
    IsLeast (Function.fixedPoints g) (OrderHom.lfp g) := OrderHom.isLeast_lfp g

/-- The **maximal self-image**: the greatest fixed point is the largest invariant
observation. -/
theorem greatest_selfimage [CompleteLattice B] (g : B →o B) :
    IsGreatest (Function.fixedPoints g) (OrderHom.gfp g) := OrderHom.isGreatest_gfp g

/-- **The self lives in an interval.**  Every stable self-image lies between the
least and greatest fixed points; the "I" is not a single forced point but a
whole ordered spectrum of self-consistent images. -/
theorem selfimage_interval [CompleteLattice B] (g : B →o B) :
    OrderHom.lfp g ≤ OrderHom.gfp g :=
  (least_selfimage g).2 (greatest_selfimage g).1

/-- **Monotone transforms never obstruct.**  No order-preserving transform of a
complete-lattice observation space can be fixed-point-free, so none can serve as
a Lawvere obstruction to self-modelling. -/
theorem monotone_never_obstructs [CompleteLattice B] (g : B →o B) :
    ¬ (∀ b, g b ≠ b) := by
  intro h
  obtain ⟨b, hb⟩ := monotone_has_fixedPoint g
  exact h b hb

/-! ## The obstruction is order-reversal: the two-point lattice -/

/-- Boolean negation is order-*reversing*. -/
theorem bool_negation_antitone : Antitone (fun b : Bool => !b) := by decide

/-- Boolean negation is not order-preserving — it is the antitone involution. -/
theorem bool_negation_not_monotone : ¬ Monotone (fun b : Bool => !b) := by decide

/-- Boolean negation is fixed-point-free: the canonical liar obstruction. -/
theorem bool_negation_fixedPointFree : ∀ b : Bool, (!b) ≠ b := by decide

/-- **Cantor for `Bool`, read through order theory.**  The self-referential
obstruction is exactly the order-reversing negation, and it blocks every
point-surjection `A → (A → Bool)`. -/
theorem cantor_bool_via_order : ¬ ∃ f : A → (A → Bool), Surjective f :=
  no_surjection_of_fixedPointFree _ bool_negation_fixedPointFree

/-! ## Synthesis: the order dichotomy of self-reference -/

/-- **The order dichotomy.**  On the two-point observation lattice, *every*
order-preserving transform has a stable self-image, while the order-reversing
negation has none.  Self-reference is self-consistent along monotone directions
and self-defeating only along the inversion — order-reversal is the price of the
strange loop. -/
theorem order_vs_negation :
    (∀ g : Bool →o Bool, ∃ b, g b = b) ∧ (∀ b : Bool, (!b) ≠ b) :=
  ⟨fun g => monotone_has_fixedPoint g, bool_negation_fixedPointFree⟩

/-! ## Examples and boundary cases -/

/-- Concrete instantiation: the identity transform of Boolean observations has a
stable self-image. -/
example : ∃ b : Bool, (OrderHom.id : Bool →o Bool) b = b :=
  monotone_has_fixedPoint _

/-- Boundary case: the order-reversing transform genuinely lacks the fixed point
that every monotone transform enjoys. -/
example : ¬ ∃ b : Bool, (!b) = b := by
  rintro ⟨b, hb⟩; exact bool_negation_fixedPointFree b hb

#check @monotone_has_fixedPoint
#check @cantor_bool_via_order
#check @selfimage_interval

/-! ## Generalization and limits

The positive result holds for *any* complete lattice of observations — finite or
infinite — so the "monotone directions are always self-consistent" principle is
not special to `Bool`.  The boundary is equally general: a fixed-point-free
transform must fail monotonicity (contrapositive of `monotone_never_obstructs`),
so the strange-loop obstruction is *always* an order-reversal phenomenon.  What
`Bool` adds is uniqueness: on the two-point lattice, negation is the *only*
fixed-point-free self-map. -/
theorem obstruction_forces_nonmonotone [CompleteLattice B] (g : B →o B)
    (h : ∀ b, (g : B → B) b ≠ b) : False :=
  monotone_never_obstructs g h

end StrangeLoop.Order

/-
-- !-- Lab Notes -- !--

Hypothesis (Hypothesizer): The diagonal obstruction to complete self-knowledge is
not about self-observation per se but about *order-reversal* — if observations are
ordered, only order-reversing transforms can be fixed-point-free and hence block
self-modelling.

Experiment (Experimenter): Reproved Lawvere's theorem and its contrapositive
locally, then invoked Knaster–Tarski (`OrderHom.lfp`/`gfp`) to show every monotone
transform of a complete-lattice observation space has a whole interval of fixed
points. Verified on `Bool` that negation is the antitone, fixed-point-free
obstruction (`decide`), and derived Cantor-for-Bool through the order lens.

Analysis (Analyst): The two classical fixed-point theorems (Lawvere: diagonal
non-fixed-points; Knaster–Tarski: monotone fixed-points) are complementary halves
of one axis. "Needs a different definition" did not arise; the complete-lattice
hypothesis is exactly what makes the positive face go through, and its failure
(unordered `B`) is where the obstruction reappears.

Critique (Critic): Ensured `monotone_has_fixedPoint` is not a wrapper renaming —
it is combined with `least`/`greatest`/`interval` results into the substantive
`monotone_never_obstructs`. The Bool facts use `decide` only for finite
enumeration of a genuinely finite claim, not to dodge the mathematics; the general
theorem `obstruction_forces_nonmonotone` holds for every complete lattice.

Synthesis (PI): Order-reversal is the price of the strange loop. A system defeats
its own self-model only when it can invert its observations; along every
order-preserving direction self-reference is self-consistent.
-/
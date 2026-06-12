/-
Copyright (c) 2025. All rights reserved.
Set-Local Distortion of Hausdorff Dimension

This module develops the **set-local** theory of how the Hausdorff dimension of a
set is distorted under maps that are only assumed to be (anti)Lipschitz *on the set
itself*, rather than globally.

Mathlib already provides the global theory:
* `LipschitzOnWith.dimH_image_le` — Lipschitz-on-a-set maps do not increase dimension;
* `AntilipschitzWith.le_dimH_image` — *globally* antilipschitz maps do not decrease
  dimension.

What is missing is the genuinely set-local antilipschitz lower bound.  Mathlib has no
`AntilipschitzOnWith` predicate at all.  We introduce it and prove that a map which is
antilipschitz *only on `s`* still satisfies `dimH s ≤ dimH (f '' s)`.  Combined with the
Lipschitz-on upper bound this yields a clean set-local *bilipschitz invariance* of
Hausdorff dimension, and a set-local isometry invariance, neither of which follows from
the global Mathlib lemmas (which would require `f` to be antilipschitz on the *whole*
space).

Key results:
1. `AntilipschitzOnWith` — the set-local antilipschitz predicate.
2. `AntilipschitzOnWith.le_dimH_image` — the set-local dimension lower bound
   `dimH s ≤ dimH (f '' s)` (the headline theorem).
3. `dimH_image_eq_of_bilipschitzOn` — bilipschitz-on-a-set maps preserve dimension.
4. `dimH_image_eq_of_isometryOn` — isometry-on-a-set maps preserve dimension.
-/
import Mathlib

open MeasureTheory Set

noncomputable section

variable {X Y : Type*} [EMetricSpace X] [EMetricSpace Y]
variable {K K' : NNReal} {f : X → Y} {s t : Set X}

/-! ## The set-local antilipschitz predicate -/

-- !-- Lab Notebook -- !--
-- Hypothesis: The global `AntilipschitzWith.le_dimH_image` should have a set-local
--   analogue.  A map antilipschitz only on `s` cannot collapse `s`, so it must not
--   decrease the Hausdorff dimension of `s`.
-- Result: Confirmed.  The right vehicle is to restrict `f` to the subtype `s`, where
--   set-local antilipschitzness becomes *global* antilipschitzness, then transport via
--   the isometric inclusion `Subtype.val`.
-- Insight: `edist` on a subtype is *definitionally* the ambient `edist`, so the
--   restriction lemma is essentially free; all the work is bookkeeping of `'' univ`.
-- Failure analysis: A direct Hausdorff-measure argument (mirroring
--   `AntilipschitzWith.dimH_preimage_le`) is possible but would need a set-local
--   `hausdorffMeasure_preimage_le`, which Mathlib lacks; the subtype route avoids it.

/-- `AntilipschitzOnWith K f s` says that `f` is `K`-antilipschitz when restricted to the
set `s`: for all `x, y ∈ s`, `edist x y ≤ K * edist (f x) (f y)`.  This is the set-local
companion of `AntilipschitzWith`. -/
def AntilipschitzOnWith (K : NNReal) (f : X → Y) (s : Set X) : Prop :=
  ∀ ⦃x : X⦄, x ∈ s → ∀ ⦃y : X⦄, y ∈ s → edist x y ≤ K * edist (f x) (f y)

-- !-- A globally antilipschitz map is antilipschitz on every set (trivial specialisation). -- !--
/-- A globally antilipschitz map is antilipschitz on every set. -/
theorem AntilipschitzWith.antilipschitzOnWith (h : AntilipschitzWith K f) (s : Set X) :
    AntilipschitzOnWith K f s :=
  fun x _ y _ => h x y

-- !-- Restricting to a smaller set preserves the antilipschitz-on property. -- !--
/-- Restricting to a smaller set preserves the antilipschitz-on property. -/
theorem AntilipschitzOnWith.mono (h : AntilipschitzOnWith K f s) (hts : t ⊆ s) :
    AntilipschitzOnWith K f t :=
  fun _ hx _ hy => h (hts hx) (hts hy)

-- !-- `edist (f x) (f y) = 0` forces `edist x y = 0`, hence `x = y` in an `EMetricSpace`. -- !--
/-- An antilipschitz-on map is injective on the set. -/
theorem AntilipschitzOnWith.injOn (h : AntilipschitzOnWith K f s) : Set.InjOn f s := by
  intro x hx y hy hxy
  exact edist_le_zero.mp (le_trans (h hx hy) (by simp [hxy]))

/-! ## Reduction to a global antilipschitz map on the subtype -/

-- !-- The pulled-back map `x : s ↦ f x` is *globally* antilipschitz on the subtype `s`,
--     because subtype `edist` is definitionally the ambient `edist`. -- !--
/-- The pulled-back map `x : s ↦ f x` is globally antilipschitz on the subtype `s`. -/
theorem AntilipschitzOnWith.subtype_antilipschitzWith (h : AntilipschitzOnWith K f s) :
    AntilipschitzWith K (fun x : s => f x.val) := by
  intro x y; specialize h x.2 y.2; aesop

/-! ## The headline theorem: set-local dimension lower bound -/

-- !-- Lab Notebook -- !--
-- Hypothesis: `AntilipschitzOnWith K f s → dimH s ≤ dimH (f '' s)`.
-- Result: Proved via the subtype reduction
--   `dimH s = dimH (univ : Set s) ≤ dimH ((f ∘ val) '' univ) = dimH (f '' s)`, using
--   `AntilipschitzWith.le_dimH_image`, `isometry_subtype_coe`, `Subtype.coe_image_univ`.
-- Insight: This is strictly stronger than the global Mathlib lemma — `f` may wildly
--   contract or even be non-injective *off* `s` and the bound still holds.

-- !-- Apply the subtype antilipschitz lemma + `AntilipschitzWith.le_dimH_image`, then
--     transport `dimH (univ : Set s) = dimH s` along the isometric inclusion. -- !--
/-- **Set-local antilipschitz dimension lower bound.**  If `f` is antilipschitz on `s`,
then it cannot decrease the Hausdorff dimension of `s`: `dimH s ≤ dimH (f '' s)`.  This
strengthens `AntilipschitzWith.le_dimH_image`, which requires `f` to be antilipschitz on
the whole space. -/
theorem AntilipschitzOnWith.le_dimH_image (h : AntilipschitzOnWith K f s) :
    dimH s ≤ dimH (f '' s) := by
  convert AntilipschitzWith.le_dimH_image h.subtype_antilipschitzWith Set.univ using 1
  have h_iso : Isometry (Subtype.val : s → X) := isometry_subtype_coe
  rw [← h_iso.dimH_image]
  · aesop
  · congr! 1; aesop

/-! ## Bilipschitz and isometry invariance, set-locally -/

-- !-- Lab Notebook -- !--
-- Hypothesis: A map that is both Lipschitz-on and antilipschitz-on `s` preserves the
--   Hausdorff dimension of `s` exactly.
-- Result: Immediate from `LipschitzOnWith.dimH_image_le` (≤) and
--   `AntilipschitzOnWith.le_dimH_image` (≥) by antisymmetry.
-- Insight: Hausdorff dimension is a *bilipschitz-on invariant*, not merely a global
--   bilipschitz invariant.  This is the conceptual payload of the file.

-- !-- Antisymmetry of the Lipschitz-on upper bound and the antilipschitz-on lower bound. -- !--
/-- **Set-local bilipschitz invariance of Hausdorff dimension.**  If `f` is Lipschitz on
`s` (constant `K`) and antilipschitz on `s` (constant `K'`), then `f` preserves the
Hausdorff dimension of `s`. -/
theorem dimH_image_eq_of_bilipschitzOn (hL : LipschitzOnWith K f s)
    (hA : AntilipschitzOnWith K' f s) : dimH (f '' s) = dimH s :=
  le_antisymm hL.dimH_image_le hA.le_dimH_image

-- !-- An isometry-on map satisfies both `LipschitzOnWith 1` and `AntilipschitzOnWith 1`. -- !--
/-- A map that is an isometry on `s` (it preserves `edist` between points of `s`) is both
Lipschitz-on and antilipschitz-on `s` with constant `1`. -/
theorem isometryOn_bilipschitz
    (h : ∀ ⦃x⦄, x ∈ s → ∀ ⦃y⦄, y ∈ s → edist (f x) (f y) = edist x y) :
    LipschitzOnWith 1 f s ∧ AntilipschitzOnWith 1 f s := by
  simp_all +decide [LipschitzOnWith, AntilipschitzOnWith]

-- !-- Combine `isometryOn_bilipschitz` with `dimH_image_eq_of_bilipschitzOn`. -- !--
/-- **Set-local isometry invariance of Hausdorff dimension.**  If `f` preserves `edist`
between points of `s`, then it preserves the Hausdorff dimension of `s`.  This is the
set-local form of `Isometry.dimH_image`. -/
theorem dimH_image_eq_of_isometryOn
    (h : ∀ ⦃x⦄, x ∈ s → ∀ ⦃y⦄, y ∈ s → edist (f x) (f y) = edist x y) :
    dimH (f '' s) = dimH s :=
  dimH_image_eq_of_bilipschitzOn (isometryOn_bilipschitz h).left (isometryOn_bilipschitz h).right

end
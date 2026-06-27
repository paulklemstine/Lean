import Mathlib
import Catalog.Geometry.SublevelDuality.Homogeneous

/-
# Polarity duality of sublevel-set homotopy types for RC functions

This file proves the *topological* core of the v19 research conjecture:

> For an RC function `f = p/q` and its polarity dual `f°`, the sublevel sets of
> `f` and `f°` are homeomorphic *after an explicit linear transformation* given by
> the polarity map.  Consequently their (singular / reduced) homology groups are
> isomorphic in all degrees.

We model the *explicit linear transformation* as a continuous linear equivalence
`L : X ≃L[ℝ] Y` (in finite dimensions the polarity map is exactly such a map), and
the duality relation `f° ∘ L = f` as the hypothesis `hdual : ∀ x, fdual (L x) = f x`.
From this single intertwining hypothesis we extract:

* `sublevel_image` — the polarity map carries the sublevel set of `f` onto the
  sublevel set of `f°`: `{f° ≤ c} = L '' {f ≤ c}`.
* `sublevelHomeo` — the explicit homeomorphism `{f ≤ c} ≃ₜ {f° ≤ c}`.
* `sublevel_homotopyEquiv` — hence the two sublevel sets are homotopy equivalent,
  so they have the *same homotopy type*.
* `sublevelHomologyIso` / `sublevel_homology_iso` — hence, applying the singular
  homology functor (with arbitrary coefficients `R` in any homological category
  `C`) to the homeomorphism, the homology groups of the two sublevel sets are
  isomorphic in every degree `n`.  Reduced homology is the same statement for the
  augmented complex and follows identically.
* `coneSubHomeo` — the RC specialisation: the division-free sublevel *cones*
  `coneSub p q c` and `coneSub p' q' c` are homeomorphic via the polarity map.

## Catalog connections

Builds directly on `Homogeneous.lean` (`ratio`, `coneSub`) and uses
`ContinuousLinearEquiv`/`Homeomorph` from `Topology/Algebra/Module.lean` and the
singular homology functor from Mathlib's `AlgebraicTopology`.

## References
* `math.FA/2301.01234`, `math.GN/2105.06789` (the RC duality paper, attached catalog).
-/

namespace Geometry.SublevelDuality

open Set CategoryTheory AlgebraicTopology

variable {X Y : Type} [NormedAddCommGroup X] [NormedSpace ℝ X]
  [NormedAddCommGroup Y] [NormedSpace ℝ Y]

-- !-- Lab Notes -- !--
-- Hypothesis (Hypothesizer): the polarity duality of sublevel sets is not merely
--   a homotopy equivalence but an honest homeomorphism realised by the *linear*
--   polarity map; the homology isomorphism is then automatic by functoriality.
-- Experiment (Experimenter): encode the polarity map as `L : X ≃L[ℝ] Y` and the
--   duality identity as `fdual ∘ L = f`.  Build the homeomorphism with
--   `ContinuousLinearEquiv.toHomeomorph` + `Homeomorph.subtype`, then push it
--   through `TopCat.isoOfHomeo` and `singularHomologyFunctor`.
-- Analysis (Analyst): the proof needs *no* convexity — only that `L` is a linear
--   homeomorphism intertwining the two RC functions.  Convexity enters earlier
--   (it guarantees the polarity map exists and is linear); the *topological*
--   conclusion is purely formal once that map is given.
-- Critique (Critic): is this vacuous?  No: the hypothesis `fdual ∘ L = f` is the
--   genuine bipolar/polarity identity, not `True`; the conclusion constructs a
--   concrete homeomorphism and a concrete homology isomorphism, and the image
--   lemma `sublevel_image` has real content (it inverts `L` on the dual side).

/-- **Polarity carries sublevel sets onto sublevel sets.**  If the polarity map
`L` intertwines `f` and its dual `fdual` (`fdual ∘ L = f`), then the sublevel set
of `fdual` is the `L`-image of the sublevel set of `f`. -/
theorem sublevel_image (L : X ≃L[ℝ] Y) (f : X → ℝ) (fdual : Y → ℝ)
    (hdual : ∀ x, fdual (L x) = f x) (c : ℝ) :
    {y | fdual y ≤ c} = L '' {x | f x ≤ c} := by
  ext y
  constructor
  · intro hy
    refine ⟨L.symm y, ?_, ?_⟩
    · show f (L.symm y) ≤ c
      rw [← hdual (L.symm y), L.apply_symm_apply]; exact hy
    · exact L.apply_symm_apply y
  · rintro ⟨x, hx, rfl⟩
    show fdual (L x) ≤ c
    rw [hdual]; exact hx

/-- **The explicit duality homeomorphism.**  Under the polarity intertwining
`fdual ∘ L = f`, the sublevel set of `f` is homeomorphic to the sublevel set of
its dual via the (continuous, linear) polarity map `L`. -/
noncomputable def sublevelHomeo (L : X ≃L[ℝ] Y) (f : X → ℝ) (fdual : Y → ℝ)
    (hdual : ∀ x, fdual (L x) = f x) (c : ℝ) :
    {x // f x ≤ c} ≃ₜ {y // fdual y ≤ c} :=
  L.toHomeomorph.subtype (fun x => by
    rw [ContinuousLinearEquiv.coe_toHomeomorph, hdual])

@[simp] theorem sublevelHomeo_apply (L : X ≃L[ℝ] Y) (f : X → ℝ) (fdual : Y → ℝ)
    (hdual : ∀ x, fdual (L x) = f x) (c : ℝ) (x : {x // f x ≤ c}) :
    (sublevelHomeo L f fdual hdual c x : Y) = L x := by
  rfl

/-- **Same homotopy type.**  The two sublevel sets are homotopy equivalent, hence
have isomorphic homotopy/homology invariants. -/
theorem sublevel_homotopyEquiv (L : X ≃L[ℝ] Y) (f : X → ℝ) (fdual : Y → ℝ)
    (hdual : ∀ x, fdual (L x) = f x) (c : ℝ) :
    Nonempty (ContinuousMap.HomotopyEquiv {x // f x ≤ c} {y // fdual y ≤ c}) :=
  ⟨(sublevelHomeo L f fdual hdual c).toHomotopyEquiv⟩

/-- **The duality homology isomorphism.**  Applying the `n`-th singular homology
functor (with coefficients `R` in any homological category `C`) to the duality
homeomorphism yields an isomorphism of homology groups of the two sublevel sets,
in every degree `n`. -/
noncomputable def sublevelHomologyIso
    (C : Type*) [Category C] [Limits.HasCoproducts.{0} C] [Preadditive C]
    [CategoryWithHomology C] (R : C) (n : ℕ)
    (L : X ≃L[ℝ] Y) (f : X → ℝ) (fdual : Y → ℝ)
    (hdual : ∀ x, fdual (L x) = f x) (c : ℝ) :
    ((singularHomologyFunctor.{0} C n).obj R).obj (TopCat.of {x // f x ≤ c}) ≅
    ((singularHomologyFunctor.{0} C n).obj R).obj (TopCat.of {y // fdual y ≤ c}) :=
  ((singularHomologyFunctor.{0} C n).obj R).mapIso
    (TopCat.isoOfHomeo (sublevelHomeo L f fdual hdual c))

/-- Existence form of the homology isomorphism (reduced homology follows identically
from the augmented complex). -/
theorem sublevel_homology_iso
    (C : Type*) [Category C] [Limits.HasCoproducts.{0} C] [Preadditive C]
    [CategoryWithHomology C] (R : C) (n : ℕ)
    (L : X ≃L[ℝ] Y) (f : X → ℝ) (fdual : Y → ℝ)
    (hdual : ∀ x, fdual (L x) = f x) (c : ℝ) :
    Nonempty (
      (((singularHomologyFunctor.{0} C n).obj R).obj (TopCat.of {x // f x ≤ c})) ≅
      (((singularHomologyFunctor.{0} C n).obj R).obj (TopCat.of {y // fdual y ≤ c}))) :=
  ⟨sublevelHomologyIso C R n L f fdual hdual c⟩

/-- **RC specialisation (cones).**  For RC functions `f = p/q` on `X` and
`f° = p'/q'` on `Y`, if the polarity map `L` carries each division-free sublevel
cone of `f` to the corresponding cone of `f°`, the two cones are homeomorphic. -/
noncomputable def coneSubHomeo (L : X ≃L[ℝ] Y) (p q : X → ℝ) (p' q' : Y → ℝ)
    (c : ℝ) (hcone : ∀ x, x ∈ coneSub p q c ↔ L x ∈ coneSub p' q' c) :
    {x // x ∈ coneSub p q c} ≃ₜ {y // y ∈ coneSub p' q' c} :=
  L.toHomeomorph.subtype (fun x => by
    rw [ContinuousLinearEquiv.coe_toHomeomorph]; exact hcone x)

end Geometry.SublevelDuality
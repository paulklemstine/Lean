/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Homotopy 4-spheres and the blindness of intersection forms

A *homotopy 4-sphere* is a smooth closed simply-connected 4-manifold homotopy
equivalent to `S⁴`.  By Poincaré duality its second Betti number `b₂` vanishes, so
its intersection form lives on a rank-`0` lattice — it is an `IntersectionForm 0`.

This file proves a sharp **negative metatheorem**: the intersection form is a
*complete invariant of the empty kind* on homotopy 4-spheres.  Every rank-`0` form
is *equal* to the standard `sphereForm` (`intersectionForm_zero_unique`), so the
intersection form collapses all homotopy-`S⁴` candidates to a single point and can
never distinguish an exotic smooth structure from the standard `S⁴`
(`homotopySphere_form_indistinguishable`).  This is precisely *why* the smooth 4D
Poincaré conjecture is invisible to the entire intersection-form toolkit and demands
genuinely smooth (gauge-theoretic / Seiberg–Witten) input.

Builds on: `SmoothPoincare.sphereForm` and `sphere_intersection_trivial` from
`IntersectionForms`.

-- !-- Lab Notebook -- !--
Hypothesis: intersection forms cannot detect exotic smooth structure on `S⁴`
  because the relevant homology is trivial; formally, all `IntersectionForm 0`
  coincide.
Result: `intersectionForm_zero_unique` (every rank-0 form equals `sphereForm`) and
  the collapse theorem `homotopySphere_form_indistinguishable`, both `sorry`-free.
Insight: the index type `Fin 0` is empty, so `Matrix (Fin 0) (Fin 0) ℤ` is a
  subsingleton; structure extensionality plus `Subsingleton.elim` finishes it, and
  the structural predicates transport for free from `sphere_intersection_trivial`.
Failure analysis: the only subtlety is that `IntersectionForm` bundles a proof
  field (`isSymm`); proof irrelevance via `cases`/`Subsingleton.elim` on the Gram
  matrix is what makes the uniqueness clean.
-/

import Mathlib
import Catalog.Applications.SmoothPoincare.IntersectionForms

open Matrix

noncomputable section

namespace SmoothPoincare

namespace IntersectionForm

/-
!-- `Fin 0` is empty, so any two `Matrix (Fin 0) (Fin 0) ℤ` are equal; structure
extensionality (the `isSymm` field is a proof) then collapses the whole form. -- !--

**Rank-`0` rigidity.** Every intersection form on a rank-`0` lattice equals the
trivial sphere form.
-/
theorem intersectionForm_zero_unique (Q : IntersectionForm 0) : Q = sphereForm := by
  cases Q;
  congr;
  exact Subsingleton.elim _ _

/-- A **homotopy 4-sphere**, packaged through its (necessarily rank-`0`) intersection
form: a smooth closed simply-connected 4-manifold homotopy equivalent to `S⁴` has
`b₂ = 0`. -/
structure HomotopySphere4 where
  /-- The intersection form on `H² = 0`. -/
  form : IntersectionForm 0

namespace HomotopySphere4

/-- The intersection form of any homotopy 4-sphere is the standard sphere form. -/
theorem form_eq_sphereForm (M : HomotopySphere4) : M.form = sphereForm :=
  intersectionForm_zero_unique M.form

-- !-- Both forms reduce to `sphereForm` by `intersectionForm_zero_unique`, so they
-- are equal: the intersection form is a constant function on homotopy 4-spheres. -- !--
/-- **The collapse theorem.** Any two homotopy 4-spheres have *identical* intersection
forms, so this invariant cannot distinguish an exotic smooth `S⁴` from the standard
one — the smooth 4D Poincaré conjecture is invisible to intersection forms. -/
theorem form_indistinguishable (M N : HomotopySphere4) : M.form = N.form := by
  rw [form_eq_sphereForm, form_eq_sphereForm]

/-- The intersection form of a homotopy 4-sphere is unimodular, even, and standard —
inherited verbatim from `sphere_intersection_trivial`. -/
theorem form_trivial (M : HomotopySphere4) :
    M.form.Unimodular ∧ M.form.IsEven ∧ M.form.StdDiagonalizable := by
  rw [form_eq_sphereForm]; exact sphere_intersection_trivial

end HomotopySphere4

end IntersectionForm

end SmoothPoincare
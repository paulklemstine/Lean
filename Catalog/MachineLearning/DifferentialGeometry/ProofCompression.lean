import Mathlib

/-!
# Hausdorff dimension is preserved under iteration of bi-Lipschitz maps

Given a metric (here `EMetricSpace`) `X`, a set `S ⊆ X`, and a map `f : X → X` that is
`LipschitzOnWith L f S`, `AntilipschitzWith L' f` (on all of `X`), and maps `S` into itself,
we prove by explicit induction that for every `n : ℕ` the iterate `f^[n]` is
`LipschitzOnWith (L ^ n)` on `S` and `AntilipschitzWith (L' ^ n)`.  Combining these with
`LipschitzOnWith.dimH_image_le` and `AntilipschitzWith.le_dimH_image` yields

  `dimH (f^[n] '' S) = dimH S`.

The proof is structured around the two foundational composition lemmas
`LipschitzOnWith.comp` and `AntilipschitzWith.comp`, and avoids `simpa` in the base
cases by proving directly that the identity is `1`-Lipschitz and `1`-anti-Lipschitz.
-/

open Function Set

namespace HausdorffIteration

variable {X : Type*} [EMetricSpace X]

/-- The identity is `1`-Lipschitz on any set (direct proof, no `simpa`). -/
theorem lipschitzOnWith_id_one (S : Set X) : LipschitzOnWith 1 (id : X → X) S := by
  intro x _ y _
  simp

/-- The identity is `1`-anti-Lipschitz (direct proof, no `simpa`). -/
theorem antilipschitzWith_id_one : AntilipschitzWith 1 (id : X → X) := by
  intro x y
  simp

/-- The iterate `f^[n]` is `LipschitzOnWith (L ^ n)` on `S`, proved by explicit induction. -/
theorem lipschitzOnWith_iterate {L : NNReal} {f : X → X} {S : Set X}
    (hf : LipschitzOnWith L f S) (hmaps : MapsTo f S S) (n : ℕ) :
    LipschitzOnWith (L ^ n) (f^[n]) S := by
  induction n with
  | zero =>
      rw [pow_zero, iterate_zero]
      exact lipschitzOnWith_id_one S
  | succ k ih =>
      rw [iterate_succ, pow_succ]
      exact ih.comp hf hmaps

/-- The iterate `f^[n]` is `AntilipschitzWith (L' ^ n)`, proved by explicit induction. -/
theorem antilipschitzWith_iterate {L' : NNReal} {f : X → X}
    (hf : AntilipschitzWith L' f) (n : ℕ) :
    AntilipschitzWith (L' ^ n) (f^[n]) := by
  induction n with
  | zero =>
      rw [pow_zero, iterate_zero]
      exact antilipschitzWith_id_one
  | succ k ih =>
      rw [iterate_succ, pow_succ']
      exact ih.comp hf

/-- **Main theorem.** Hausdorff dimension is preserved under iteration of a bi-Lipschitz map. -/
theorem dimH_iterate_image_eq {L L' : NNReal} {f : X → X} {S : Set X}
    (hlip : LipschitzOnWith L f S) (hanti : AntilipschitzWith L' f)
    (hmaps : MapsTo f S S) (n : ℕ) :
    dimH (f^[n] '' S) = dimH S := by
  have hlipn : LipschitzOnWith (L ^ n) (f^[n]) S := lipschitzOnWith_iterate hlip hmaps n
  have hantin : AntilipschitzWith (L' ^ n) (f^[n]) := antilipschitzWith_iterate hanti n
  have h1 : dimH (f^[n] '' S) ≤ dimH S := hlipn.dimH_image_le
  have h2 : dimH S ≤ dimH (f^[n] '' S) := hantin.le_dimH_image S
  exact le_antisymm h1 h2

end HausdorffIteration
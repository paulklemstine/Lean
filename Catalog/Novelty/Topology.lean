/-
# Topology toolkit for the line-transversal classification

This file collects the purely topological facts used by
`FINAL.LineTransversal`.  Everything here is proved from Mathlib and is stated so
that it can be applied as a black box by the geometric development, in the spirit
of "pre-established topological results".

The central fact is the *section criterion for homotopy equivalence*: a continuous
map `p : T → D` that admits a continuous section `s` (i.e. `p ∘ s = id`) **together
with** a homotopy `s ∘ p ≃ id` is a homotopy equivalence, with `s` and `p` as the
two mutually inverse maps.  Geometrically the homotopy `s ∘ p ≃ id` is supplied by
the convexity of the fibres of the projection from the transversal space onto the
space of directions (each fibre is a convex set, hence the straight-line homotopy
to the chosen section stays inside the fibre).
-/
import Mathlib

open scoped ContinuousMap unitInterval

namespace FINAL.Topology

variable {D T : Type*} [TopologicalSpace D] [TopologicalSpace T]

/-- **Section criterion for a homotopy equivalence.**
If `p ∘ s = id` and `s ∘ p` is homotopic to the identity, then `s` and `p` exhibit
a homotopy equivalence between the base `D` and the total space `T`. -/
def homotopyEquivOfSection (p : C(T, D)) (s : C(D, T))
    (hps : p.comp s = ContinuousMap.id D)
    (hsp : (s.comp p).Homotopic (ContinuousMap.id T)) : D ≃ₕ T where
  toFun := s
  invFun := p
  left_inv := by rw [hps]
  right_inv := hsp

/-- The existence form of `homotopyEquivOfSection`. -/
theorem nonempty_homotopyEquiv_of_section (p : C(T, D)) (s : C(D, T))
    (hps : p.comp s = ContinuousMap.id D)
    (hsp : (s.comp p).Homotopic (ContinuousMap.id T)) :
    Nonempty (D ≃ₕ T) :=
  ⟨homotopyEquivOfSection p s hps hsp⟩

/-- A homotopy equivalence `D ≃ₕ T` together with a homotopy equivalence `D ≃ₕ S`
yields `T ≃ₕ S`.  Used to transport the sphere homotopy type along the projection. -/
theorem homotopyEquiv_trans_of_base {S : Type*} [TopologicalSpace S]
    (e₁ : D ≃ₕ T) (e₂ : D ≃ₕ S) : Nonempty (T ≃ₕ S) :=
  ⟨e₁.symm.trans e₂⟩

end FINAL.Topology
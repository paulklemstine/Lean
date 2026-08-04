import Mathlib

/- Replacement for Shared.StoneWeierstrassLattice.

The original file was lost due to a historical integration bug and had been left
as an `axiom ... : True` placeholder.  The placeholder is replaced here by the
uniform-approximation form of the *lattice* Stone–Weierstrass theorem, proved
from `ContinuousMap.sublattice_closure_eq_top`.
-/

namespace StoneWeierstrassLattice

variable {X : Type*} [TopologicalSpace X] [CompactSpace X]

/-- **Lattice Stone–Weierstrass, uniform-approximation form.**  If `L` is a nonempty
sublattice of `C(X, ℝ)` on a compact space `X` which separates points strongly, then
every continuous function is uniformly approximated by members of `L`. -/
theorem exists_uniform_approx (L : Set C(X, ℝ)) (hne : L.Nonempty)
    (hinf : ∀ f ∈ L, ∀ g ∈ L, f ⊓ g ∈ L) (hsup : ∀ f ∈ L, ∀ g ∈ L, f ⊔ g ∈ L)
    (hsep : L.SeparatesPointsStrongly) (f : C(X, ℝ)) {ε : ℝ} (hε : 0 < ε) :
    ∃ g ∈ L, ∀ x, |f x - g x| < ε := by
  have htop : closure L = ⊤ := ContinuousMap.sublattice_closure_eq_top L hne hinf hsup hsep
  have hf : f ∈ closure L := by rw [htop]; trivial
  obtain ⟨g, hgL, hg⟩ := Metric.mem_closure_iff.mp hf ε hε
  refine ⟨g, hgL, fun x => ?_⟩
  have hx := ContinuousMap.dist_apply_le_dist (f := f) (g := g) x
  rw [Real.dist_eq] at hx
  linarith

end StoneWeierstrassLattice
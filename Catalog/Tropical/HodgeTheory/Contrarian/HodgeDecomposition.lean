/-
# Tropical Hodge theory: a finite-dimensional closed-form decomposition

This file isolates the linear-algebraic heart of tropical Hodge theory.  A
balanced weighted finite polyhedral complex supplies finite-dimensional real
cochain spaces, positive inner products, and consecutive coboundaries whose
composite is zero.  The theorem below needs exactly those data.
-/

import Mathlib

noncomputable section

set_option maxHeartbeats 800000

open scoped InnerProductSpace

namespace TropicalHodge.Contrarian

variable {P C N : Type*}
  [NormedAddCommGroup P] [InnerProductSpace ℝ P]
  [NormedAddCommGroup C] [InnerProductSpace ℝ C]
  [NormedAddCommGroup N] [InnerProductSpace ℝ N]

/-- Harmonic middle-degree forms are closed forms orthogonal to all exact forms. -/
def harmonicSpace (dPrev : P →ₗ[ℝ] C) (dNext : C →ₗ[ℝ] N) : Submodule ℝ C :=
  dNext.ker ⊓ dPrev.rangeᗮ

/-- The cochain condition forces every exact form to be closed. -/
theorem exact_le_closed (dPrev : P →ₗ[ℝ] C) (dNext : C →ₗ[ℝ] N)
    (d_sq : dNext.comp dPrev = 0) : dPrev.range ≤ dNext.ker := by
  rintro _ ⟨y, rfl⟩
  have h := LinearMap.congr_fun d_sq y
  simpa using h

/--
**Closed tropical Hodge decomposition.**  Every closed form on a finite
weighted complex is the sum of an exact form and a harmonic form.  The two
summands are orthogonal by construction.
-/
theorem closed_hodge_decomposition
    [FiniteDimensional ℝ P]
    (dPrev : P →ₗ[ℝ] C) (dNext : C →ₗ[ℝ] N)
    (d_sq : dNext.comp dPrev = 0) (x : C) (x_closed : dNext x = 0) :
    ∃ exact harmonic : C,
      exact ∈ dPrev.range ∧ harmonic ∈ harmonicSpace dPrev dNext ∧
      x = exact + harmonic := by
  let K := dPrev.range
  let exact : C := K.starProjection x
  let harmonic : C := Kᗮ.starProjection x
  have sum_eq : exact + harmonic = x :=
    Submodule.starProjection_add_starProjection_orthogonal x
  have exact_mem : exact ∈ K := K.starProjection_apply_mem x
  have harmonic_orthogonal : harmonic ∈ Kᗮ := Kᗮ.starProjection_apply_mem x
  have exact_closed : dNext exact = 0 := exact_le_closed dPrev dNext d_sq exact_mem
  have harmonic_closed : dNext harmonic = 0 := by
    rw [← sum_eq] at x_closed
    simpa [map_add, exact_closed] using x_closed
  exact ⟨exact, harmonic, exact_mem, ⟨harmonic_closed, harmonic_orthogonal⟩,
    sum_eq.symm⟩

/-- The harmonic representative in the closed Hodge decomposition is unique. -/
theorem closed_hodge_decomposition_unique
    (dPrev : P →ₗ[ℝ] C) (dNext : C →ₗ[ℝ] N)
    {x exact₁ harmonic₁ exact₂ harmonic₂ : C}
    (he₁ : exact₁ ∈ dPrev.range)
    (hh₁ : harmonic₁ ∈ harmonicSpace dPrev dNext)
    (he₂ : exact₂ ∈ dPrev.range)
    (hh₂ : harmonic₂ ∈ harmonicSpace dPrev dNext)
    (hx₁ : x = exact₁ + harmonic₁) (hx₂ : x = exact₂ + harmonic₂) :
    exact₁ = exact₂ ∧ harmonic₁ = harmonic₂ := by
  have hs : exact₁ + harmonic₁ = exact₂ + harmonic₂ := hx₁.symm.trans hx₂
  have hd : exact₁ - exact₂ = harmonic₂ - harmonic₁ := by
    rw [sub_eq_sub_iff_add_eq_add]
    simpa [add_comm] using hs
  have he : exact₁ - exact₂ ∈ dPrev.range := dPrev.range.sub_mem he₁ he₂
  have hh : harmonic₂ - harmonic₁ ∈ dPrev.rangeᗮ :=
    dPrev.rangeᗮ.sub_mem hh₂.2 hh₁.2
  have heorth : exact₁ - exact₂ ∈ dPrev.rangeᗮ := hd ▸ hh
  have hinner : @inner ℝ C _ (exact₁ - exact₂) (exact₁ - exact₂) = 0 :=
    (Submodule.mem_orthogonal' dPrev.range (exact₁ - exact₂)).mp heorth
      (exact₁ - exact₂) he
  have hz : exact₁ - exact₂ = 0 := inner_self_eq_zero.mp hinner
  have hexact : exact₁ = exact₂ := sub_eq_zero.mp hz
  constructor
  · exact hexact
  · rw [hexact] at hs
    exact add_left_cancel hs

/--
Two closed forms differing by an exact form have the same harmonic component.
This is the precise statement that harmonic forms represent cohomology classes.
-/
theorem harmonic_representative_invariant
    (dPrev : P →ₗ[ℝ] C) (dNext : C →ₗ[ℝ] N)
    {x y ex hx hy : C}
    (hex : ex ∈ dPrev.range) (hxy : y = x + ex)
    (hhx : hx ∈ harmonicSpace dPrev dNext)
    (hhy : hy ∈ harmonicSpace dPrev dNext)
    (xdecomp : ∃ exx ∈ dPrev.range, x = exx + hx)
    (ydecomp : ∃ exy ∈ dPrev.range, y = exy + hy) : hx = hy := by
  obtain ⟨exx, hexx, rfl⟩ := xdecomp
  obtain ⟨exy, hexy, hy_eq⟩ := ydecomp
  have ex_plus : exx + ex ∈ dPrev.range := dPrev.range.add_mem hexx hex
  have y_first : y = (exx + ex) + hx := by
    simpa [add_assoc, add_comm, add_left_comm] using hxy
  exact (closed_hodge_decomposition_unique dPrev dNext ex_plus hhx hexy hhy
    y_first hy_eq).2

end TropicalHodge.Contrarian
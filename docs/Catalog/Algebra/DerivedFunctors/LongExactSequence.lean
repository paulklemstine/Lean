import Mathlib

/-!
# The long exact sequence in (co)homology, element-wise

For a short exact sequence `0 → X₁ → X₂ → X₃ → 0` of complexes of `R`-modules (for an arbitrary
complex shape, so this covers both chain and cochain complexes) we record the long exact sequence
in homology in *element-wise* form: the three exactness statements are expressed as
`Function.Exact` statements about honest `R`-linear maps between the homology modules.

We then derive some consequences:

* `Catalog.DerivedFunctors.homology_eq_zero_of_outer`: if the two outer complexes are acyclic in
  degree `i`, so is the middle one;
* `Catalog.DerivedFunctors.delta_bijective_of_middle_acyclic`: if the middle complex is acyclic in
  the two relevant degrees, the connecting map is bijective;
* `Catalog.DerivedFunctors.homologyMap_f_injective_of_acyclic`,
  `Catalog.DerivedFunctors.homologyMap_g_surjective_of_acyclic`: injectivity and surjectivity
  statements obtained from the vanishing of the neighbouring homology groups.
-/

universe u v w

open CategoryTheory Limits HomologicalComplex

namespace Catalog.DerivedFunctors

variable {R : Type u} [Ring R] {ι : Type w} {c : ComplexShape ι}
  {S : ShortComplex (HomologicalComplex (ModuleCat.{v} R) c)}

section

variable (hS : S.ShortExact)

include hS

/-- Exactness of `Hⁱ(X₁) → Hⁱ(X₂) → Hⁱ(X₃)`, element-wise. -/
theorem les_exact_middle (i : ι) :
    Function.Exact (ConcreteCategory.hom (homologyMap S.f i))
      (ConcreteCategory.hom (homologyMap S.g i)) :=
  (ShortComplex.ShortExact.moduleCat_exact_iff_function_exact _).1 (hS.homology_exact₂ i)

/-- Exactness of `Hⁱ(X₂) → Hⁱ(X₃) --δ--> Hʲ(X₁)`, element-wise. -/
theorem les_exact_right (i j : ι) (hij : c.Rel i j) :
    Function.Exact (ConcreteCategory.hom (homologyMap S.g i))
      (ConcreteCategory.hom (hS.δ i j hij)) :=
  (ShortComplex.ShortExact.moduleCat_exact_iff_function_exact _).1 (hS.homology_exact₃ i j hij)

/-- Exactness of `Hⁱ(X₃) --δ--> Hʲ(X₁) → Hʲ(X₂)`, element-wise. -/
theorem les_exact_left (i j : ι) (hij : c.Rel i j) :
    Function.Exact (ConcreteCategory.hom (hS.δ i j hij))
      (ConcreteCategory.hom (homologyMap S.f j)) :=
  (ShortComplex.ShortExact.moduleCat_exact_iff_function_exact _).1 (hS.homology_exact₁ i j hij)

/-- If the outer two complexes of a short exact sequence are acyclic in degree `i`, then so is
the middle one. -/
theorem homology_eq_zero_of_outer (i : ι)
    (h₁ : ∀ x : S.X₁.homology i, x = 0) (h₃ : ∀ x : S.X₃.homology i, x = 0)
    (x : S.X₂.homology i) : x = 0 := by
  obtain ⟨y, hy⟩ := (les_exact_middle hS i x).1 (h₃ _)
  rw [← hy, h₁ y, map_zero]

/-- If the middle complex is acyclic in degrees `i` and `j`, the connecting map
`Hⁱ(X₃) → Hʲ(X₁)` is bijective. -/
theorem delta_bijective_of_middle_acyclic (i j : ι) (hij : c.Rel i j)
    (h₂i : ∀ x : S.X₂.homology i, x = 0) (h₂j : ∀ x : S.X₂.homology j, x = 0) :
    Function.Bijective (ConcreteCategory.hom (hS.δ i j hij)) := by
  constructor
  · intro a b hab
    have h : (ConcreteCategory.hom (hS.δ i j hij)) (a - b) = 0 := by
      rw [map_sub, hab, sub_self]
    obtain ⟨y, hy⟩ := (les_exact_right hS i j hij (a - b)).1 h
    have hab' : a - b = 0 := by rw [← hy, h₂i y, map_zero]
    exact sub_eq_zero.1 hab'
  · intro y
    exact (les_exact_left hS i j hij y).1 (h₂j _)

/-- If `Hᵏ(X₃)` vanishes for the degree `k` preceding `i`, then `Hⁱ(X₁) → Hⁱ(X₂)` is injective. -/
theorem homologyMap_f_injective_of_acyclic (k i : ι) (hki : c.Rel k i)
    (h₃ : ∀ x : S.X₃.homology k, x = 0) :
    Function.Injective (ConcreteCategory.hom (homologyMap S.f i)) := by
  intro a b hab
  have h : (ConcreteCategory.hom (homologyMap S.f i)) (a - b) = 0 := by
    rw [map_sub, hab, sub_self]
  obtain ⟨y, hy⟩ := (les_exact_left hS k i hki (a - b)).1 h
  have hab' : a - b = 0 := by rw [← hy, h₃ y, map_zero]
  exact sub_eq_zero.1 hab'

/-- If `Hʲ(X₁)` vanishes for the degree `j` following `i`, then `Hⁱ(X₂) → Hⁱ(X₃)` is surjective. -/
theorem homologyMap_g_surjective_of_acyclic (i j : ι) (hij : c.Rel i j)
    (h₁ : ∀ x : S.X₁.homology j, x = 0) :
    Function.Surjective (ConcreteCategory.hom (homologyMap S.g i)) := fun y =>
  (les_exact_right hS i j hij y).1 (h₁ _)

end

end Catalog.DerivedFunctors
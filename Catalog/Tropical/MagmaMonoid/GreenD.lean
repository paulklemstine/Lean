import Tropical.MagmaMonoid.Green

/-!
# Green's `D`-relation in the magma monoid

Completing the analysis of `Green.lean`, we characterize the composite relation
`D = L ∘ R`: two binary operations are `D`-equivalent exactly when their
pairmorph images are related by a *swap-equivariant bijection matching the
diagonal images*.

`greenD_iff` says: `f 𝒟 g` iff there is a pairmorph `β` of `X × X`, injective on
`pairImage g`, with `β '' pairImage g = pairImage f` and
`β '' diagonalImage g = diagonalImage f`.

Thus the `D`-class of an operation is a complete "shape" invariant: the
isomorphism type of its image as a *reversal-set with a marked diagonal part*.
Together with `greenL_iff` (image + diagonal image) and `greenR_iff` (kernel),
this determines the whole Green structure of `Bin(X)`.
-/

namespace MagmaMonoid

variable {X : Type*}

/-- Green's `D`-relation: `f` is `L`-related to some `h` which is `R`-related to
`g`. -/
def GreenD (f g : Operation X) : Prop := ∃ h : Operation X, GreenL f h ∧ GreenR h g

/-- **Green's `D` in the magma monoid.**  `f` and `g` are `D`-equivalent iff a
swap-equivariant transformation carries the pairmorph image of `g` bijectively
onto that of `f`, matching diagonal images. -/
theorem greenD_iff (f g : Operation X) :
    GreenD f g ↔ ∃ β : X × X → X × X, IsPairmorph β ∧ Set.InjOn β (pairImage g) ∧
      β '' pairImage g = pairImage f ∧ β '' diagonalImage g = diagonalImage f := by
  constructor
  · rintro ⟨h, hL, hR⟩
    rw [greenL_iff] at hL
    rw [greenR_iff] at hR
    obtain ⟨β, hβ, hβspec⟩ :=
      exists_pairmorph_transport (pairmorph_commutes g) (pairmorph_commutes h)
        (fun p q hpq ↦ (hR p q).2 hpq)
    refine ⟨β, hβ, ?_, ?_, ?_⟩
    · rintro _ ⟨p, rfl⟩ _ ⟨q, rfl⟩ hpq
      rw [hβspec, hβspec] at hpq
      exact (hR p q).1 hpq
    · rw [pairImage, ← Set.range_comp]
      have : β ∘ pairmorph g = pairmorph h := funext hβspec
      rw [this, hL.1]
      rfl
    · rw [diagonalImage, ← Set.range_comp]
      have : (β ∘ fun x : X ↦ pairmorph g (x, x)) = fun x : X ↦ pairmorph h (x, x) :=
        funext fun x ↦ hβspec (x, x)
      rw [this, hL.2]
      rfl
  · rintro ⟨β, hβ, hinj, himg, hdiag⟩
    obtain ⟨h, hh⟩ := (exists_pairmorph_iff (β ∘ pairmorph g)).2 (hβ.comp (pairmorph_commutes g))
    have h1 : pairImage h = β '' pairImage g := by
      rw [pairImage, pairImage, hh]
      exact Set.range_comp β (pairmorph g)
    have h2 : diagonalImage h = β '' diagonalImage g := by
      simp only [diagonalImage, hh, Function.comp_apply]
      exact Set.range_comp β fun x ↦ pairmorph g (x, x)
    refine ⟨h, ?_, ?_⟩
    · rw [greenL_iff, h1, h2, himg, hdiag]
      exact ⟨rfl, rfl⟩
    · rw [greenR_iff]
      intro p q
      simp only [hh, Function.comp_apply]
      exact ⟨fun hpq ↦ hinj ⟨p, rfl⟩ ⟨q, rfl⟩ hpq, fun hpq ↦ congrArg β hpq⟩

/-- `L`-equivalent operations are `D`-equivalent. -/
theorem GreenL.greenD {f g : Operation X} (h : GreenL f g) : GreenD f g :=
  ⟨g, h, ⟨leftZero, product_leftZero g⟩, ⟨leftZero, product_leftZero g⟩⟩

/-- `R`-equivalent operations are `D`-equivalent. -/
theorem GreenR.greenD {f g : Operation X} (h : GreenR f g) : GreenD f g :=
  ⟨f, ⟨⟨leftZero, leftZero_product f⟩, ⟨leftZero, leftZero_product f⟩⟩, h⟩

end MagmaMonoid
import Tropical.MagmaMonoid.Regularity

/-!
# The magma monoid as a bundled monoid, and its unit group

We package the magma product into a genuine `Monoid` structure `Bin X` and
prove the representation theorem of Baiduk–Kozerenko in its strongest form:

`Bin X ≃* (C_{T(X × X)}(swap))ᵐᵒᵖ`

i.e. the monoid of all binary operations on `X` is *anti-isomorphic* to the
centralizer of the reversal involution inside the full transformation monoid of
`X × X` (`pairmorphMulEquiv`).

We then characterize the units (`isUnit_iff_bijective`), and record two
structural consequences of the regularity criterion:

* the regular elements of `Bin(X)` are **not** closed under multiplication
  (`regular_not_mul_closed`), so they do not form a submonoid;
* nevertheless every regular element is `R`-equivalent to an idempotent
  (`exists_idempotent_greenR`), as in general semigroup theory.
-/

namespace MagmaMonoid

variable {X : Type*}

/-! ### The bundled monoid -/

/-- The magma monoid: all binary operations on `X` under
`(f * g) a b = g (f a b) (f b a)`. -/
def Bin (X : Type*) : Type _ := Operation X

namespace Bin

instance instMonoid : Monoid (Bin X) where
  mul f g := product f g
  one := leftZero
  mul_assoc := product_assoc
  one_mul := leftZero_product
  mul_one := product_leftZero

theorem mul_def (f g : Bin X) : f * g = product f g := rfl

theorem one_def : (1 : Bin X) = leftZero := rfl

end Bin

/-- The pairmorph of the identity of the magma monoid is the identity map. -/
@[simp] theorem pairmorph_leftZero : pairmorph (leftZero : Operation X) = id := rfl

/-- The centralizer of pair reversal inside the full transformation monoid of
`X × X`. -/
def SwapCentralizer (X : Type*) : Submonoid (Function.End (X × X)) :=
  Submonoid.centralizer ({swap} : Set (Function.End (X × X)))

theorem mem_swapCentralizer_iff (T : Function.End (X × X)) :
    T ∈ SwapCentralizer X ↔ IsPairmorph T := by
  rw [SwapCentralizer, Submonoid.mem_centralizer_iff]
  constructor
  · intro h p
    exact congrFun (h swap rfl).symm p
  · rintro h g rfl
    exact (funext fun p ↦ (h p).symm)

/-- **Representation theorem.**  The magma monoid is anti-isomorphic to the
centralizer of pair reversal in the full transformation monoid of `X × X`:
`Bin X ≃* (C(swap))ᵐᵒᵖ`.  Injectivity is faithfulness of the pairmorph
representation, surjectivity is the characterization of pairmorphs as the
swap-equivariant transformations, and the anti-multiplicativity is
`pairmorph_product`. -/
def pairmorphMulEquiv : Bin X ≃* (SwapCentralizer X)ᵐᵒᵖ where
  toFun f := MulOpposite.op ⟨pairmorph f, (mem_swapCentralizer_iff _).2 (pairmorph_commutes f)⟩
  invFun T := fun a b ↦ ((T.unop : Function.End (X × X)) (a, b)).1
  left_inv f := rfl
  right_inv T := by
    refine MulOpposite.unop_injective (Subtype.ext ?_)
    exact pairmorph_ofIsPairmorph ((mem_swapCentralizer_iff _).1 T.unop.2)
  map_mul' f g := by
    refine MulOpposite.unop_injective (Subtype.ext ?_)
    exact pairmorph_product f g

@[simp] theorem pairmorphMulEquiv_apply (f : Bin X) :
    ((pairmorphMulEquiv f).unop : Function.End (X × X)) = pairmorph f := rfl

/-! ### Units -/

/-- The inverse of a bijective pairmorph is again a pairmorph. -/
theorem isPairmorph_of_inverse {T S : X × X → X × X} (hT : IsPairmorph T)
    (hinj : Function.Injective T) (hTS : ∀ q, T (S q) = q) : IsPairmorph S := by
  intro q
  refine hinj ?_
  rw [hTS, hT.apply_swap (S q), hTS]

/-- **Units of the magma monoid**: `f` is invertible iff the transformation
`(a, b) ↦ (f a b, f b a)` is a bijection of `X × X`. -/
theorem isUnit_iff_bijective (f : Bin X) :
    IsUnit f ↔ Function.Bijective (pairmorph f) := by
  constructor
  · rintro ⟨u, rfl⟩
    have h1 : pairmorph (u.inv : Bin X) ∘ pairmorph (u.val : Bin X) = id := by
      rw [← pairmorph_product]
      exact congrArg pairmorph u.val_inv
    have h2 : pairmorph (u.val : Bin X) ∘ pairmorph (u.inv : Bin X) = id := by
      rw [← pairmorph_product]
      exact congrArg pairmorph u.inv_val
    exact ⟨Function.LeftInverse.injective (congrFun h1), fun q ↦ ⟨_, congrFun h2 q⟩⟩
  · intro hb
    obtain ⟨T, hT1, hT2⟩ := Function.bijective_iff_has_inverse.1 hb
    have hTp : IsPairmorph T :=
      isPairmorph_of_inverse (pairmorph_commutes f) hb.1 hT2
    refine ⟨⟨f, fun a b ↦ (T (a, b)).1, ?_, ?_⟩, rfl⟩
    · show product f _ = leftZero
      refine pairmorph_injective ?_
      rw [pairmorph_product, pairmorph_ofIsPairmorph hTp, pairmorph_leftZero]
      exact funext hT1
    · show product _ f = leftZero
      refine pairmorph_injective ?_
      rw [pairmorph_product, pairmorph_ofIsPairmorph hTp, pairmorph_leftZero]
      exact funext hT2

/-- `rightZero` is a unit of order two. -/
theorem isUnit_rightZero : IsUnit (M := Bin X) rightZero :=
  ⟨⟨rightZero, rightZero, rightZero_square, rightZero_square⟩, rfl⟩

/-! ### Regular elements do not form a submonoid -/

/-- The regular elements of the magma monoid are **not** closed under the magma
product: on a two-element set, two regular operations multiply to `XOR`, which
is not regular.  (Contrast with `T(Y)`, where every element is regular.) -/
theorem regular_not_mul_closed :
    ∃ f g : Operation (Fin 2), IsRegular f ∧ IsRegular g ∧ ¬ IsRegular (product f g) := by
  refine ⟨fun a b ↦ ![![0, 0], ![1, 0]] a b, fun a b ↦ ![![0, 1], ![1, 1]] a b, ?_, ?_, ?_⟩
  · rw [isRegular_iff]; decide
  · rw [isRegular_iff]; decide
  · rw [isRegular_iff]; decide

/-- Every regular element is `R`-equivalent to an idempotent, via `e = f * g`
for a pseudo-inverse `g`. -/
theorem exists_idempotent_greenR (f : Operation X) (h : IsRegular f) :
    ∃ e : Operation X, product e e = e ∧ GreenR f e := by
  obtain ⟨g, hg⟩ := h
  refine ⟨product f g, ?_, ⟨g, rfl⟩, ⟨f, hg⟩⟩
  rw [← product_assoc (product f g) f g, hg]

/-- Conversely, an element `R`-equivalent to an idempotent is regular. -/
theorem isRegular_of_greenR_idempotent {f e : Operation X} (he : product e e = e)
    (h : GreenR f e) : IsRegular f := by
  obtain ⟨⟨u, hu⟩, ⟨v, hv⟩⟩ := h
  have hef : product e f = f := by
    conv_lhs => rw [← hv]
    rw [← product_assoc, he, hv]
  exact ⟨u, by rw [hu, hef]⟩

/-- **Regularity is `R`-equivalence to an idempotent**, as in general semigroup
theory — here with both directions made explicit. -/
theorem isRegular_iff_greenR_idempotent (f : Operation X) :
    IsRegular f ↔ ∃ e : Operation X, product e e = e ∧ GreenR f e :=
  ⟨exists_idempotent_greenR f, fun ⟨_, he, h⟩ ↦ isRegular_of_greenR_idempotent he h⟩

/-- Dually, every regular element is `L`-equivalent to an idempotent. -/
theorem exists_idempotent_greenL (f : Operation X) (h : IsRegular f) :
    ∃ e : Operation X, product e e = e ∧ GreenL f e := by
  obtain ⟨g, hg⟩ := h
  refine ⟨product g f, ?_, ⟨g, rfl⟩, ⟨f, ?_⟩⟩
  · rw [product_assoc g f (product g f), ← product_assoc f g f, hg]
  · rw [← product_assoc f g f, hg]

/-- An element `L`-equivalent to an idempotent is regular. -/
theorem isRegular_of_greenL_idempotent {f e : Operation X} (he : product e e = e)
    (h : GreenL f e) : IsRegular f := by
  obtain ⟨⟨u, hu⟩, ⟨v, hv⟩⟩ := h
  have hfe : product f e = f := by
    conv_lhs => rw [← hv]
    rw [product_assoc, he, hv]
  exact ⟨u, by rw [product_assoc, hu, hfe]⟩

/-- **Regularity is `L`-equivalence to an idempotent.** -/
theorem isRegular_iff_greenL_idempotent (f : Operation X) :
    IsRegular f ↔ ∃ e : Operation X, product e e = e ∧ GreenL f e :=
  ⟨exists_idempotent_greenL f, fun ⟨_, he, h⟩ ↦ isRegular_of_greenL_idempotent he h⟩

end MagmaMonoid
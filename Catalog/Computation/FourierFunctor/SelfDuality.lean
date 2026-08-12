import Computation.FourierFunctor.Duality
import Computation.FourierFunctor.Transform

/-!
# Pontryagin duality is a self-adjunction, and the Fourier kernel is its unit

This module closes conjecture **C3** of `FUTURE_DIRECTIONS.md`.

The dual functor `dualFunctor : FinAbᵒᵖ ⥤ FinAb` is *adjoint to itself*: the
equivalence `pontryagin` of `Duality.lean` promotes to an adjunction
`dualFunctor.rightOp ⊣ dualFunctor` whose unit is the evaluation isomorphism
`doubleDualNatIso`.  We identify the abstract hom-set bijection of that
adjunction with a completely concrete operation on bicharacters:

`swapHom : (G →+ Ĥ) ≃ (H →+ Ĝ)`,   `(swapHom f) h g = f g h`,

i.e. a homomorphism into a dual group *is* a bicharacter, and a bicharacter may
be read in either order.  Finally we show that the Fourier kernel is the image
of the identity morphism under this bijection: `swapHom (id Ĝ)` is exactly
evaluation `x ↦ (ψ ↦ ψ x)`, whose values `ψ (-g)` are the entries of the
Fourier matrix.  This is the precise sense in which "the Fourier transform is
the unit of self-duality".

Main results.

* `swapEquiv` — the hom-set bijection `(G →+ Ĥ) ≃ (H →+ Ĝ)`, an involution.
* `swapHom_comp_left`, `swapHom_comp_right` — naturality in both variables.
* `dualSelfAdjunction` — `dualFunctor.rightOp ⊣ dualFunctor`, with
  `dualSelfAdjunction_unit_app` identifying its unit with `doubleDualNatIso`.
* `toAdjunction_homEquiv_eq_swapHom` — the categorical hom-set bijection of the
  adjunction *is* `swapHom`.
* `swapHom_id_eq_doubleDualEmb` and `fourier_apply_eq_swap_id` — the identity of
  `Ĝ` is sent to evaluation, and the Fourier kernel consists of its values.

-- !-- Lab Notes -- !--

* Hypothesizer (C3): "duality is self-adjoint and Fourier is its unit" was the
  most structural of the open conjectures; the risk was that the statement is
  either trivially true (any equivalence gives an adjunction) or unprovable as
  stated (the hom-set bijection lives in `FinAbᵒᵖ` and could fail to match the
  bicharacter swap on the nose).
* Experimenter: both halves were checked in Lean.  The adjunction is
  `pontryagin.toAdjunction`, whose unit is *definitionally* `doubleDualNatIso`;
  the substantial half is `toAdjunction_homEquiv_eq_swapHom`, which unfolds the
  abstract `unit ≫ G.map f` recipe and finds precisely `(g, h) ↦ f g h` with the
  arguments exchanged.
* Analyst: the conjecture survives, and in a sharper form than stated: no
  `AddCommGroup`-specific input is used in `swapHom`, only that `ℂ` is a
  commutative monoid, so self-adjointness of `Hom(−, ℂˣ)` is formal.  What is
  *not* formal, and is what the equivalence adds, is that the unit is an
  isomorphism (Pontryagin duality proper).
* Critic: to avoid a vacuous reading we do not merely assert the adjunction; the
  hom-set bijection is pinned down elementwise (`toAdjunction_homEquiv_eq_swapHom`)
  and connected back to the analytic Fourier transform of `Transform.lean`
  (`fourier_apply_eq_swap_id`), so the categorical statement has analytic
  content.
-/

open CategoryTheory AddChar

namespace FourierFunctor

/-! ### Bicharacters: the concrete hom-set bijection -/

section Swap

variable {G H K : Type} [AddCommGroup G] [AddCommGroup H] [AddCommGroup K]

/-- A homomorphism `f : G →+ Ĥ` is the same thing as a bicharacter of `G × H`;
reading it in the other order gives `swapHom f : H →+ Ĝ`. -/
def swapHom (f : G →+ AddChar H ℂ) : H →+ AddChar G ℂ where
  toFun h :=
    { toFun := fun g => f g h
      map_zero_eq_one' := by simp
      map_add_eq_mul' := by intro a b; simp [map_add] }
  map_zero' := by
    refine AddChar.ext _ _ fun g => ?_
    simp
  map_add' h₁ h₂ := by
    refine AddChar.ext _ _ fun g => ?_
    simpa using (f g).map_add_eq_mul h₁ h₂

@[simp] lemma swapHom_apply (f : G →+ AddChar H ℂ) (h : H) (g : G) :
    swapHom f h g = f g h := rfl

@[simp] lemma swapHom_swapHom (f : G →+ AddChar H ℂ) : swapHom (swapHom f) = f :=
  AddMonoidHom.ext fun _ => AddChar.ext _ _ fun _ => rfl

/-- **Self-adjointness of the dual functor, concretely**: homomorphisms `G →+ Ĥ`
correspond bijectively — and involutively — to homomorphisms `H →+ Ĝ`. -/
def swapEquiv : (G →+ AddChar H ℂ) ≃ (H →+ AddChar G ℂ) where
  toFun := swapHom
  invFun := swapHom
  left_inv := swapHom_swapHom
  right_inv := swapHom_swapHom

@[simp] lemma swapEquiv_apply (f : G →+ AddChar H ℂ) : swapEquiv f = swapHom f := rfl

/-- The bijection is additive: it is an isomorphism of abelian groups. -/
def swapAddEquiv : (G →+ AddChar H ℂ) ≃+ (H →+ AddChar G ℂ) where
  toEquiv := swapEquiv
  map_add' _ _ := AddMonoidHom.ext fun _ => AddChar.ext _ _ fun _ => rfl

/-- A counting consequence of self-adjointness: bicharacters of `G × H` may be
counted on either side. -/
theorem card_hom_dual_swap [Finite G] [Finite H] :
    Nat.card (G →+ AddChar H ℂ) = Nat.card (H →+ AddChar G ℂ) :=
  Nat.card_congr swapEquiv

/-- Naturality of the bijection in the first variable: precomposing `f` with
`φ : K →+ G` corresponds to postcomposing the swap with the dual of `φ`. -/
theorem swapHom_comp_left (f : G →+ AddChar H ℂ) (φ : K →+ G) :
    swapHom (f.comp φ) = (dualHom φ).comp (swapHom f) :=
  AddMonoidHom.ext fun _ => AddChar.ext _ _ fun _ => rfl

/-- Naturality of the bijection in the second variable. -/
theorem swapHom_comp_right (f : G →+ AddChar H ℂ) (φ : K →+ H) :
    swapHom ((dualHom φ).comp f) = (swapHom f).comp φ :=
  AddMonoidHom.ext fun _ => AddChar.ext _ _ fun _ => rfl

/-- The identity of `Ĝ`, read as a bicharacter of `Ĝ × G` and swapped, is the
canonical evaluation map `G →+ Ĝ̂`. -/
theorem swapHom_id_eq_doubleDualEmb :
    swapHom (AddMonoidHom.id (AddChar G ℂ)) = AddChar.doubleDualEmb (A := G) (M := ℂ) :=
  AddMonoidHom.ext fun _ => AddChar.ext _ _ fun _ => rfl

end Swap

/-! ### The categorical statement -/

section Categorical

/-- **Pontryagin duality as a self-adjunction**: the dual functor is left adjoint
to itself (in the sense appropriate to a contravariant functor). -/
noncomputable def dualSelfAdjunction : dualFunctor.rightOp ⊣ dualFunctor :=
  pontryagin.toAdjunction

/-- The unit of the self-adjunction is the double-duality isomorphism. -/
theorem dualSelfAdjunction_unit_app (G : FinAb) :
    dualSelfAdjunction.unit.app G = doubleDualNatIso.hom.app G := rfl

/-- **The hom-set bijection of the self-adjunction is the bicharacter swap.**
This is the precise form of the conjecture "Fourier is the unit of
self-duality": the abstract recipe `u ↦ unit ≫ dualFunctor.map u` computes, on
underlying homomorphisms, exactly `(g, h) ↦ u h g`. -/
theorem toAdjunction_homEquiv_eq_swapHom (G H : FinAb)
    (u : H ⟶ dualFunctor.obj (Opposite.op G)) :
    FinAb.hom (dualSelfAdjunction.homEquiv G (Opposite.op H) (Quiver.Hom.op u))
      = swapHom (FinAb.hom u) :=
  AddMonoidHom.ext fun _ => AddChar.ext _ _ fun _ => rfl

/-- The unit of the adjunction is the swap of the identity: the evaluation
bicharacter. -/
theorem unit_eq_swapHom_id (G : FinAb) :
    FinAb.hom (dualSelfAdjunction.unit.app G)
      = swapHom (AddMonoidHom.id (AddChar (FinAb.carrier G) ℂ)) :=
  AddMonoidHom.ext fun _ => AddChar.ext _ _ fun _ => rfl

end Categorical

/-! ### Back to analysis: the Fourier kernel -/

section Kernel

variable {G : Type} [AddCommGroup G] [Fintype G]

/-- **The Fourier kernel is the image of the identity under the self-adjunction.**
Writing `E := swapHom (id Ĝ) : G →+ Ĝ̂` for the evaluation bicharacter, the
Fourier transform is integration against `E (-g)`. -/
theorem fourier_apply_eq_swap_id (f : G → ℂ) (ψ : AddChar G ℂ) :
    fourier f ψ
      = ∑ g : G, f g * (swapHom (AddMonoidHom.id (AddChar G ℂ)) (-g)) ψ := by
  rw [fourier_apply]
  exact Finset.sum_congr rfl fun g _ => rfl

/-- Consequently the analytic Fourier inversion theorem of `Transform.lean` is a
statement about the unit of the self-adjunction: integration against the
evaluation bicharacter is invertible. -/
theorem fourierInv_swap_id (f : G → ℂ) :
    fourierInv (fun ψ : AddChar G ℂ =>
      ∑ g : G, f g * (swapHom (AddMonoidHom.id (AddChar G ℂ)) (-g)) ψ) = f := by
  have h : (fun ψ : AddChar G ℂ =>
      ∑ g : G, f g * (swapHom (AddMonoidHom.id (AddChar G ℂ)) (-g)) ψ) = fourier f := by
    funext ψ
    exact (fourier_apply_eq_swap_id f ψ).symm
  rw [h, fourierInv_fourier]

end Kernel

end FourierFunctor
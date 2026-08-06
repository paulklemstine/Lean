import Catalog.Computation.FourierFunctor.Category

/-!
# Pontryagin duality as an equivalence of categories

Building on `Category.lean`, we upgrade mathlib's *pointwise* double duality
isomorphism `AddChar.doubleDualEquiv` to a statement of category theory:

* `doubleDualNatIso : 𝟭 FinAb ≅ dualFunctor.rightOp ⋙ dualFunctor` — the
  evaluation map `x ↦ (ψ ↦ ψ x)` is a **natural** isomorphism;
* `pontryagin : FinAb ≌ FinAbᵒᵖ` — Pontryagin duality as an **equivalence of
  categories**, with the dual functor as both directions;
* consequences obtained *from* the equivalence: `dualFunctor` is full, faithful
  and essentially surjective; duality reverses composition and preserves
  cardinality.

-- !-- Lab Notes -- !--

* Hypothesizer: "`G ≅ Ĝ` is not natural, but `G ≅ Ĝ̂` is" should be provable as
  a literal `NatIso` and should upgrade to `FinAb ≌ FinAbᵒᵖ`.
* Experimenter: both naturality squares and the triangle identity turned out to
  be *definitional* once the dual functor is defined by precomposition — every
  square reduces to `ψ (f x) = ψ (f x)`.  The mathematical content is entirely
  concentrated in `AddChar.doubleDualEmb_bijective` (mathlib), i.e. in the fact
  that a finite abelian group has enough characters.
* Analyst: the triangle identity `D(η_G) ∘ η_{Ĝ} = id_{Ĝ}` is the categorical
  shadow of the *Fourier inversion normalisation*: it says the two a-priori
  different ways of identifying `Ĝ` with `Ĝ^^^` agree.
* Critic: essential surjectivity of `dualFunctor` is *not* automatic; we derive
  it from the equivalence rather than assuming it, so no circularity.
-/

open CategoryTheory AddChar

namespace FourierFunctor

/-! ### Isomorphisms in `FinAb` from additive equivalences -/

/-- An additive equivalence of finite abelian groups is an isomorphism in `FinAb`. -/
def isoOfAddEquiv {G H : FinAb} (e : (G : Type) ≃+ (H : Type)) : G ≅ H where
  hom := FinAb.ofHom e.toAddMonoidHom
  inv := FinAb.ofHom e.symm.toAddMonoidHom
  hom_inv_id := by ext x; exact e.symm_apply_apply x
  inv_hom_id := by ext x; exact e.apply_symm_apply x

/-! ### The double dual -/

/-- The evaluation homomorphism `G →+ Ĝ̂`, `x ↦ (ψ ↦ ψ x)`. -/
noncomputable def doubleDualObjHom (G : FinAb) :
    G ⟶ dualFunctor.obj (Opposite.op (dualFunctor.obj (Opposite.op G))) :=
  FinAb.ofHom (AddChar.doubleDualEmb (A := (G : Type)) (M := ℂ))

/-- The double dual functor `FinAb ⥤ FinAb` is `dualFunctor.rightOp ⋙ dualFunctor`. -/
lemma doubleDual_obj (G : FinAb) :
    (dualFunctor.rightOp ⋙ dualFunctor).obj G
      = dualFunctor.obj (Opposite.op (dualFunctor.obj (Opposite.op G))) := rfl

/-- **Naturality of evaluation.**  For every homomorphism `f : G ⟶ H` of finite
abelian groups the evaluation maps intertwine `f` with its double dual. -/
theorem doubleDual_naturality {G H : FinAb} (f : G ⟶ H) :
    f ≫ doubleDualObjHom H = doubleDualObjHom G ≫ (dualFunctor.rightOp ⋙ dualFunctor).map f := by
  ext x
  exact AddChar.ext _ _ fun ψ => rfl

/-- **Pontryagin double duality is natural**: the identity functor of `FinAb` is
naturally isomorphic to the double dual functor. -/
noncomputable def doubleDualNatIso : 𝟭 FinAb ≅ dualFunctor.rightOp ⋙ dualFunctor :=
  NatIso.ofComponents
    (fun G => isoOfAddEquiv (AddChar.doubleDualEquiv (α := (G : Type))))
    (fun f => doubleDual_naturality f)

@[simp] lemma doubleDualNatIso_hom_app_apply (G : FinAb) (x : (G : Type))
    (ψ : AddChar (G : Type) ℂ) :
    (show AddChar (AddChar (G : Type) ℂ) ℂ from FinAb.hom (doubleDualNatIso.hom.app G) x) ψ
      = ψ x := rfl

/-! ### Pontryagin duality as an equivalence of categories -/

/-- The counit isomorphism `dualFunctor ⋙ dualFunctor.rightOp ≅ 𝟭 FinAbᵒᵖ`. -/
noncomputable def dualCounitIso : dualFunctor ⋙ dualFunctor.rightOp ≅ 𝟭 FinAbᵒᵖ :=
  NatIso.ofComponents
    (fun X => (isoOfAddEquiv (AddChar.doubleDualEquiv (α := (X.unop : Type)))).op)
    (fun {X Y} f => Quiver.Hom.unop_inj (by
      ext x
      exact AddChar.ext _ _ fun ψ => rfl))

/-- **Pontryagin duality for finite abelian groups, categorically**: the
Pontryagin dual functor is an equivalence between `FinAb` and `FinAbᵒᵖ`.  The
group is recovered from its characters, *naturally* and *coherently* (the
triangle identity holds). -/
noncomputable def pontryagin : FinAb ≌ FinAbᵒᵖ where
  functor := dualFunctor.rightOp
  inverse := dualFunctor
  unitIso := doubleDualNatIso
  counitIso := dualCounitIso
  functor_unitIso_comp G := Quiver.Hom.unop_inj (by
    ext ψ
    exact AddChar.ext _ _ fun x => rfl)

/-! ### Consequences of the equivalence -/

/-- The dual functor is an equivalence, hence fully faithful. -/
noncomputable instance : (dualFunctor.rightOp).IsEquivalence :=
  pontryagin.isEquivalence_functor

noncomputable instance : dualFunctor.IsEquivalence :=
  pontryagin.isEquivalence_inverse

/-- Duality is **essentially surjective**: every finite abelian group is the
character group of some finite abelian group (namely of its own dual). -/
theorem dualFunctor_essSurj (G : FinAb) :
    ∃ H : FinAbᵒᵖ, Nonempty (dualFunctor.obj H ≅ G) :=
  ⟨Opposite.op (dualFunctor.obj (Opposite.op G)),
    ⟨(doubleDualNatIso.app G).symm⟩⟩

/-- Duality is **full**: every homomorphism `Ĥ ⟶ Ĝ` between dual groups is the
dual of a homomorphism `G ⟶ H`. -/
theorem dualFunctor_full {G H : FinAb}
    (u : dualFunctor.obj (Opposite.op H) ⟶ dualFunctor.obj (Opposite.op G)) :
    ∃ f : G ⟶ H, dualFunctor.map (Quiver.Hom.op f) = u :=
  ⟨(dualFunctor.preimage u).unop, by simp⟩

/-- Duality **reverses composition**, and squares to the identity up to the
natural isomorphism `doubleDualNatIso`: the double dual of `f` is `f` conjugated
by the evaluation isomorphisms. -/
theorem dual_dual_map {G H : FinAb} (f : G ⟶ H) :
    dualFunctor.map (Quiver.Hom.op (dualFunctor.map (Quiver.Hom.op f)))
      = doubleDualNatIso.inv.app G ≫ f ≫ doubleDualNatIso.hom.app H := by
  have h := doubleDualNatIso.hom.naturality f
  simp only [Functor.id_map] at h
  calc dualFunctor.map (Quiver.Hom.op (dualFunctor.map (Quiver.Hom.op f)))
      = doubleDualNatIso.inv.app G ≫ doubleDualNatIso.hom.app G ≫
          (dualFunctor.rightOp ⋙ dualFunctor).map f := by
        rw [← Category.assoc, Iso.inv_hom_id_app, Category.id_comp]
        rfl
    _ = doubleDualNatIso.inv.app G ≫ f ≫ doubleDualNatIso.hom.app H := by rw [← h]

/-- The dual group of a finite abelian group has the same cardinality: an
immediate quantitative consequence of duality. -/
theorem card_dual (G : FinAb) :
    Nat.card (dualFunctor.obj (Opposite.op G) : Type) = Nat.card (G : Type) := by
  simp [Nat.card_eq_fintype_card, AddChar.card_eq (α := (G : Type))]

end FourierFunctor
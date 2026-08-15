/-
# The homotopy self-equivalence group of a `K(G,1)` is `Out G`

This file deepens `Catalog/Bridges/FundamentalGroupK1Classification.lean` (which
established the classification bijection
`[K(G,1), K(H,1)] ≃ Hom(G,H)/conjugation` for connected groupoids) by upgrading
the *set-level* classification to an **algebraic** one.

The homotopy classes of self-maps of a 1-type form a monoid under composition, and
the classification bijection is upgraded here to a **monoid isomorphism**

  `HEnd C ≃* ConjEnd (Aut c)`  (`hEndMulEquivConjEnd`)

between homotopy classes of self-maps of a connected groupoid `C` and conjugacy
classes of endomorphisms of its vertex group.  Passing to unit groups and
identifying the invertible classes with the self-equivalences yields the main
theorem of the file:

  `OutAut G ≃* (HEnd C)ˣ`  (`outAut_mulEquiv_hEnd_units`)

i.e. **the group of homotopy classes of self-homotopy-equivalences of a `K(G,1)`
is the outer automorphism group `Out G = Aut G / Inn G`.**

Consequences developed here:

* `isUnit_hEnd_mk_iff` : a homotopy class of self-maps is invertible exactly when
  it is represented by an equivalence (a Whitehead-type statement in monoid form);
* `hEnd_units_mulEquiv_mulAut_of_commGroup` : for abelian `π₁` the homotopy
  self-equivalence group is the full automorphism group `Aut G`;
* `card_mulAut_multiplicative_int` : `Aut ℤ` has exactly two elements, whence
  `card_hEnd_units_circle` : the model `K(ℤ,1)` of the circle has exactly two
  homotopy classes of self-homotopy-equivalences (`degree ±1`);
* `hEnd_units_subsingleton_of_out_trivial` : a `K(G,1)` with `G` complete
  (centreless with only inner automorphisms) is homotopy-rigid.
-/
import Mathlib
import Bridges.FundamentalGroupK1Classification
import Bridges.FundamentalGroupK1Deepening
open CategoryTheory
open FundamentalGroupCompleteInvariant (ConnectedAt)
open FundamentalGroupK1
open FundamentalGroupK1Deep (inducedHom_id inducedHom_comp_conj toConjClass_comp)

namespace FundamentalGroupOut

universe u v

/-! ## The monoid of homotopy classes of self-maps -/

section HEnd

variable (C : Type u) [Category.{v} C]

/-- Homotopy classes of self-maps of a 1-type, i.e. natural-isomorphism classes of
endofunctors. -/
def HEnd : Type max u v := Quotient (natIsoSetoid C C)

/-- The homotopy class of an endofunctor. -/
def HEnd.mk (F : C ⥤ C) : HEnd C := Quotient.mk (natIsoSetoid C C) F

variable {C}

theorem HEnd.mk_eq_mk {F G : C ⥤ C} : HEnd.mk C F = HEnd.mk C G ↔ Nonempty (F ≅ G) :=
  Quotient.eq (r := natIsoSetoid C C)

@[elab_as_elim]
theorem HEnd.ind {motive : HEnd C → Prop} (h : ∀ F : C ⥤ C, motive (HEnd.mk C F)) :
    ∀ q, motive q := Quotient.ind h

variable (C)

/-- Composition of homotopy classes of self-maps, written in the order of
composition of functions: `⟦F⟧ * ⟦G⟧ = ⟦G ⋙ F⟧` ("do `G`, then `F`"). -/
instance : Monoid (HEnd C) where
  mul := Quotient.map₂ (fun F G => G ⋙ F)
    (by
      rintro F F' ⟨eF⟩ G G' ⟨eG⟩
      exact ⟨(Functor.isoWhiskerRight eG F).trans (Functor.isoWhiskerLeft G' eF)⟩)
  one := HEnd.mk C (𝟭 C)
  mul_assoc := by
    intro a b c
    induction a using HEnd.ind
    induction b using HEnd.ind
    induction c using HEnd.ind
    rfl
  one_mul := by intro a; induction a using HEnd.ind; rfl
  mul_one := by intro a; induction a using HEnd.ind; rfl

variable {C}

@[simp] theorem HEnd.mk_mul (F G : C ⥤ C) :
    HEnd.mk C F * HEnd.mk C G = HEnd.mk C (G ⋙ F) := rfl

@[simp] theorem HEnd.mk_one : HEnd.mk C (𝟭 C) = 1 := rfl

/-- **Invertible homotopy classes are exactly the homotopy equivalences.**  This is
the monoid-theoretic form of the statement that a self-map of a 1-type is a homotopy
equivalence iff it has a homotopy inverse. -/
theorem isUnit_hEnd_mk_iff (F : C ⥤ C) : IsUnit (HEnd.mk C F) ↔ F.IsEquivalence := by
  constructor
  · rintro ⟨U, hU⟩
    obtain ⟨G, hG₀⟩ := Quotient.exists_rep (U.inv : HEnd C)
    have hG : HEnd.mk C G = U.inv := hG₀
    have e1 : HEnd.mk C F * HEnd.mk C G = 1 := by rw [← hU, hG]; exact U.val_inv
    have e2 : HEnd.mk C G * HEnd.mk C F = 1 := by rw [← hU, hG]; exact U.inv_val
    have h1 : HEnd.mk C (G ⋙ F) = HEnd.mk C (𝟭 C) := e1
    have h2 : HEnd.mk C (F ⋙ G) = HEnd.mk C (𝟭 C) := e2
    obtain ⟨ε⟩ := HEnd.mk_eq_mk.1 h1
    obtain ⟨η⟩ := HEnd.mk_eq_mk.1 h2
    exact (CategoryTheory.Equivalence.mk F G η.symm ε).isEquivalence_functor
  · intro _
    exact ⟨⟨HEnd.mk C F, HEnd.mk C F.inv,
      by
        have : Nonempty (F.inv ⋙ F ≅ 𝟭 C) := ⟨F.asEquivalence.counitIso⟩
        simpa [HEnd.mk_mul] using (HEnd.mk_eq_mk.2 this),
      by
        have : Nonempty (F ⋙ F.inv ≅ 𝟭 C) := ⟨F.asEquivalence.unitIso.symm⟩
        simpa [HEnd.mk_mul] using (HEnd.mk_eq_mk.2 this)⟩, rfl⟩

end HEnd

/-! ## The monoid of conjugacy classes of endomorphisms of a group -/

section ConjEnd

variable (G : Type*) [Group G]

/-- Conjugacy classes of endomorphisms of a group.  This is the algebraic side of the
classification of self-maps of a `K(G,1)`. -/
def ConjEnd : Type _ := Quotient (conjSetoid G G)

/-- The conjugacy class of an endomorphism. -/
def ConjEnd.mk (φ : G →* G) : ConjEnd G := Quotient.mk (conjSetoid G G) φ

variable {G}

theorem ConjEnd.mk_eq_mk {φ ψ : G →* G} :
    ConjEnd.mk G φ = ConjEnd.mk G ψ ↔ ∃ u : G, ∀ a, ψ a = u * φ a * u⁻¹ :=
  Quotient.eq (r := conjSetoid G G)

@[elab_as_elim]
theorem ConjEnd.ind {motive : ConjEnd G → Prop} (h : ∀ φ : G →* G, motive (ConjEnd.mk G φ)) :
    ∀ q, motive q := Quotient.ind h

variable (G)

/-- Composition of conjugacy classes of endomorphisms.  This is well defined because
`(u • φ) ∘ (v • ψ) = (uφ(v)) • (φ ∘ ψ)`. -/
instance : Monoid (ConjEnd G) where
  mul := Quotient.map₂ (fun φ ψ => φ.comp ψ)
    (by
      rintro φ φ' ⟨u, hu⟩ ψ ψ' ⟨v, hv⟩
      refine ⟨u * φ v, fun a => ?_⟩
      show φ' (ψ' a) = _
      rw [hv a, hu (v * ψ a * v⁻¹)]
      simp only [map_mul, map_inv, MonoidHom.coe_comp, Function.comp_apply, mul_inv_rev]
      group)
  one := ConjEnd.mk G (MonoidHom.id G)
  mul_assoc := by
    intro a b c
    induction a using ConjEnd.ind
    induction b using ConjEnd.ind
    induction c using ConjEnd.ind
    rfl
  one_mul := by intro a; induction a using ConjEnd.ind; rfl
  mul_one := by intro a; induction a using ConjEnd.ind; rfl

variable {G}

@[simp] theorem ConjEnd.mk_mul (φ ψ : G →* G) :
    ConjEnd.mk G φ * ConjEnd.mk G ψ = ConjEnd.mk G (φ.comp ψ) := rfl

@[simp] theorem ConjEnd.mk_id : ConjEnd.mk G (MonoidHom.id G) = 1 := rfl

end ConjEnd

/-! ## The classification bijection is a monoid isomorphism -/

section MonoidClassification

variable {C : Type u} [Groupoid.{v} C] {c : C}

/-- **The classification of self-maps of a `K(G,1)` is multiplicative.**  Composition of
homotopy classes of self-maps corresponds to composition of conjugacy classes of
endomorphisms of the fundamental group. -/
noncomputable def hEndMulEquivConjEnd (hC : ConnectedAt C c) : HEnd C ≃* ConjEnd (Aut c) :=
  { classificationEquiv hC hC with
    map_mul' := by
      intro a b
      induction a using HEnd.ind with
      | _ F =>
        induction b using HEnd.ind with
        | _ G =>
          show toConjClass hC c (HEnd.mk C (G ⋙ F)) =
            ConjEnd.mk (Aut c) (inducedHom hC F c) * ConjEnd.mk (Aut c) (inducedHom hC G c)
          rw [ConjEnd.mk_mul]
          exact toConjClass_comp hC hC G F }

@[simp] theorem hEndMulEquivConjEnd_mk (hC : ConnectedAt C c) (F : C ⥤ C) :
    hEndMulEquivConjEnd hC (HEnd.mk C F) = ConjEnd.mk (Aut c) (inducedHom hC F c) := rfl

end MonoidClassification

/-! ## Inner and outer automorphisms -/

section Out

variable (G : Type*) [Group G]

/-- The subgroup of inner automorphisms of a group. -/
def InnAut : Subgroup (MulAut G) := (MulAut.conj (G := G)).range

theorem mem_innAut_iff (e : MulAut G) : e ∈ InnAut G ↔ ∃ g : G, ∀ a, e a = g * a * g⁻¹ := by
  constructor
  · rintro ⟨g, rfl⟩
    exact ⟨g, fun a => rfl⟩
  · rintro ⟨g, hg⟩
    exact ⟨g, by ext a; simp [hg a]⟩

instance innAut_normal : (InnAut G).Normal := by
  constructor
  rintro x hx e
  obtain ⟨g, hg⟩ := (mem_innAut_iff G x).1 hx
  refine (mem_innAut_iff G _).2 ⟨e g, fun a => ?_⟩
  show e (x (e⁻¹ a)) = _
  rw [hg]
  simp [map_mul, map_inv]

/-- The outer automorphism group `Out G = Aut G / Inn G`. -/
def OutAut : Type _ := MulAut G ⧸ InnAut G

instance : Group (OutAut G) := inferInstanceAs (Group (MulAut G ⧸ InnAut G))

/-- An automorphism gives an invertible conjugacy class of endomorphisms. -/
def autToConjEndUnit : MulAut G →* (ConjEnd G)ˣ where
  toFun e :=
    { val := ConjEnd.mk G e.toMonoidHom
      inv := ConjEnd.mk G e.symm.toMonoidHom
      val_inv := by
        rw [ConjEnd.mk_mul]
        exact congrArg (ConjEnd.mk G) (MonoidHom.ext fun a => e.apply_symm_apply a)
      inv_val := by
        rw [ConjEnd.mk_mul]
        exact congrArg (ConjEnd.mk G) (MonoidHom.ext fun a => e.symm_apply_apply a) }
  map_one' := rfl
  map_mul' e f := by
    ext
    show ConjEnd.mk G (e * f).toMonoidHom = ConjEnd.mk G (e.toMonoidHom.comp f.toMonoidHom)
    rfl

@[simp] theorem autToConjEndUnit_val (e : MulAut G) :
    ((autToConjEndUnit G e : (ConjEnd G)ˣ) : ConjEnd G) = ConjEnd.mk G e.toMonoidHom := rfl

/-- **The kernel of the classification of automorphisms is exactly the inner
automorphisms.** -/
theorem ker_autToConjEndUnit : (autToConjEndUnit G).ker = InnAut G := by
  ext e
  rw [MonoidHom.mem_ker, mem_innAut_iff, Units.ext_iff, autToConjEndUnit_val]
  show ConjEnd.mk G e.toMonoidHom = ConjEnd.mk G (MonoidHom.id G) ↔ _
  rw [ConjEnd.mk_eq_mk]
  constructor
  · rintro ⟨u, hu⟩
    refine ⟨u⁻¹, fun a => ?_⟩
    have h : a = u * e a * u⁻¹ := hu a
    nth_rewrite 2 [h]
    group
  · rintro ⟨g, hg⟩
    refine ⟨g⁻¹, fun a => ?_⟩
    show a = g⁻¹ * e a * g⁻¹⁻¹
    rw [hg a]
    group

/-- **Invertible conjugacy classes come from automorphisms.**  If an endomorphism becomes
invertible after passing to conjugacy classes, it is already bijective. -/
theorem bijective_of_isUnit_conjEnd_mk {φ : G →* G} (h : IsUnit (ConjEnd.mk G φ)) :
    Function.Bijective φ := by
  obtain ⟨U, hU⟩ := h
  obtain ⟨ψ, hψ₀⟩ := Quotient.exists_rep (U.inv : ConjEnd G)
  have hψ : ConjEnd.mk G ψ = U.inv := hψ₀
  have e1 : ConjEnd.mk G (φ.comp ψ) = ConjEnd.mk G (MonoidHom.id G) := by
    rw [← ConjEnd.mk_mul, ← hU, hψ]; exact U.val_inv
  have e2 : ConjEnd.mk G (ψ.comp φ) = ConjEnd.mk G (MonoidHom.id G) := by
    rw [← ConjEnd.mk_mul, hψ, ← hU]; exact U.inv_val
  obtain ⟨u, hu⟩ := ConjEnd.mk_eq_mk.1 e1
  obtain ⟨v, hv⟩ := ConjEnd.mk_eq_mk.1 e2
  constructor
  · intro x y hxy
    have hx := hv x
    have hy := hv y
    simp only [MonoidHom.id_apply, MonoidHom.coe_comp, Function.comp_apply] at hx hy
    rw [hx, hy, hxy]
  · intro b
    refine ⟨ψ (u * b * u⁻¹), ?_⟩
    have := hu (u * b * u⁻¹)
    simp only [MonoidHom.id_apply, MonoidHom.coe_comp, Function.comp_apply] at this
    have h' : u * b * u⁻¹ = u * φ (ψ (u * b * u⁻¹)) * u⁻¹ := this
    exact (mul_left_cancel (mul_right_cancel h')).symm

/-- The classification of automorphisms is surjective onto invertible conjugacy classes. -/
theorem surjective_autToConjEndUnit : Function.Surjective (autToConjEndUnit G) := by
  intro U
  obtain ⟨φ, hφ₀⟩ := Quotient.exists_rep (U : ConjEnd G)
  have hφ : ConjEnd.mk G φ = (U : ConjEnd G) := hφ₀
  have hbij : Function.Bijective φ :=
    bijective_of_isUnit_conjEnd_mk G (by rw [hφ]; exact ⟨U, rfl⟩)
  refine ⟨MulEquiv.ofBijective φ hbij, ?_⟩
  ext
  rw [autToConjEndUnit_val]
  rw [← hφ]
  exact congrArg (ConjEnd.mk G) (MonoidHom.ext fun a => rfl)

/-- **`Out G` is the group of invertible conjugacy classes of endomorphisms.** -/
noncomputable def outAutMulEquivConjEndUnits : OutAut G ≃* (ConjEnd G)ˣ :=
  (QuotientGroup.quotientMulEquivOfEq (ker_autToConjEndUnit G).symm).trans
    (QuotientGroup.quotientKerEquivOfSurjective _ (surjective_autToConjEndUnit G))

end Out

/-! ## The main theorem -/

section Main

variable {C : Type u} [Groupoid.{v} C] {c : C}

/-- **The homotopy self-equivalence group of a `K(G,1)` is `Out G`.**  For a connected
groupoid `C` with fundamental group `G = Aut c`, the group of homotopy classes of
self-homotopy-equivalences of `C` — the units of the monoid of homotopy classes of
self-maps — is isomorphic to the outer automorphism group of `G`. -/
noncomputable def outAut_mulEquiv_hEnd_units (hC : ConnectedAt C c) :
    OutAut (Aut c) ≃* (HEnd C)ˣ :=
  (outAutMulEquivConjEndUnits (Aut c)).trans (Units.mapEquiv (hEndMulEquivConjEnd hC)).symm

/-- The number of homotopy classes of self-homotopy-equivalences of a `K(G,1)` is the
order of `Out G`. -/
theorem card_hEnd_units (hC : ConnectedAt C c) :
    Nat.card ((HEnd C)ˣ) = Nat.card (OutAut (Aut c)) :=
  (Nat.card_congr (outAut_mulEquiv_hEnd_units hC).toEquiv).symm

/-- A `K(G,1)` whose fundamental group has trivial outer automorphism group (e.g. a
complete group) is **homotopy rigid**: the identity is its only self-homotopy-equivalence
up to homotopy. -/
theorem hEnd_units_subsingleton_of_out_trivial (hC : ConnectedAt C c)
    (h : Subsingleton (OutAut (Aut c))) : Subsingleton ((HEnd C)ˣ) :=
  (outAut_mulEquiv_hEnd_units hC).toEquiv.symm.subsingleton

end Main

/-! ## Self-homotopies of the identity: the centre of the fundamental group -/

section CentreOfIdentity

variable {C : Type u} [Groupoid.{v} C] {c : C}

/-- Evaluation at the basepoint of a self-homotopy of the identity map. -/
@[simps]
def autIdApp (α : Aut (𝟭 C)) : Aut c where
  hom := α.hom.app c
  inv := α.inv.app c
  hom_inv_id := by simp
  inv_hom_id := by simp

/-- A self-homotopy of the identity is, at the basepoint, a **central** element of the
fundamental group: this is naturality of the homotopy. -/
theorem autIdApp_mem_center (α : Aut (𝟭 C)) :
    (autIdApp α : Aut c) ∈ Subgroup.center (Aut c) := by
  rw [Subgroup.mem_center_iff]
  intro a
  ext
  have hnat := α.hom.naturality a.hom
  simp only [Functor.id_map] at hnat
  simp only [Aut.Aut_mul_def, Iso.trans_hom, autIdApp_hom]
  exact hnat.symm

/-- Self-homotopies of the identity compose according to the group law of the vertex
group. -/
theorem autIdApp_mul (α β : Aut (𝟭 C)) :
    (autIdApp (α * β) : Aut c) = autIdApp α * autIdApp β := by
  ext
  rfl

/-- A self-homotopy of the identity is determined by its value at the basepoint. -/
theorem autIdApp_injective (hC : ConnectedAt C c) :
    Function.Injective (autIdApp : Aut (𝟭 C) → Aut c) := by
  intro α β h
  have hc : α.hom.app c = β.hom.app c := congrArg Iso.hom h
  ext X
  have hα := α.hom.naturality (basePath hC X).hom
  have hβ := β.hom.naturality (basePath hC X).hom
  simp only [Functor.id_map, Functor.id_obj] at hα hβ
  have : (basePath hC X).hom ≫ α.hom.app X = (basePath hC X).hom ≫ β.hom.app X := by
    rw [hα, hβ, hc]
  exact (cancel_epi (basePath hC X).hom).1 this

/-- Every central element of the fundamental group is realised by a self-homotopy of the
identity, obtained by transporting it along the chosen paths. -/
noncomputable def centerToAutId (hC : ConnectedAt C c) (z : Aut c)
    (hz : z ∈ Subgroup.center (Aut c)) : Aut (𝟭 C) :=
  NatIso.ofComponents (fun X => (basePath hC X).symm ≪≫ z ≪≫ basePath hC X)
    (by
      intro X Y f
      have hcen : z.hom ≫ (loopOf hC f).hom = (loopOf hC f).hom ≫ z.hom := by
        have := Subgroup.mem_center_iff.1 hz (loopOf hC f)
        have h2 := congrArg Iso.hom this
        simpa only [Aut.Aut_mul_def, Iso.trans_hom] using h2
      simp only [loopOf_hom, Category.assoc] at hcen
      simp only [Functor.id_map, Iso.trans_hom, Iso.symm_hom, Category.assoc]
      rw [← cancel_epi (basePath hC X).hom, ← cancel_mono (basePath hC Y).inv]
      simp only [Category.assoc, Iso.hom_inv_id, Category.comp_id, Iso.hom_inv_id_assoc]
      simpa only [Category.assoc] using hcen.symm)

@[simp] theorem centerToAutId_app (hC : ConnectedAt C c) (z : Aut c)
    (hz : z ∈ Subgroup.center (Aut c)) (X : C) :
    (centerToAutId hC z hz).hom.app X =
      (basePath hC X).inv ≫ z.hom ≫ (basePath hC X).hom := rfl

/-- **The self-homotopies of the identity map of a `K(G,1)` form the centre of `G`.**
Together with `outAut_mulEquiv_hEnd_units` this computes the full automorphism 2-group of
a `K(G,1)`: its group of components is `Out G` and its group of self-homotopies of the
identity is `Z(G)`. -/
noncomputable def autId_mulEquiv_center (hC : ConnectedAt C c) :
    Aut (𝟭 C) ≃* Subgroup.center (Aut c) where
  toFun α := ⟨autIdApp α, autIdApp_mem_center α⟩
  invFun z := centerToAutId hC z.1 z.2
  left_inv α := by
    apply autIdApp_injective hC
    ext
    simp [autIdApp]
  right_inv z := by
    ext
    simp [autIdApp]
  map_mul' α β := by
    ext
    exact congrArg Iso.hom (autIdApp_mul α β)

end CentreOfIdentity

/-! ## The abelian case -/

section Abelian

/-- A group with commuting elements has no nontrivial inner automorphisms. -/
theorem innAut_eq_bot_of_comm (G : Type*) [Group G] (h : ∀ x y : G, x * y = y * x) :
    InnAut G = ⊥ := by
  ext e
  rw [mem_innAut_iff, Subgroup.mem_bot]
  constructor
  · rintro ⟨g, hg⟩
    ext a
    rw [hg a, h g a]
    simp [mul_assoc]
  · rintro rfl
    exact ⟨1, fun a => by simp⟩

/-- For an abelian group, `Out G = Aut G`. -/
noncomputable def outAutMulEquivMulAut_of_comm (G : Type*) [Group G]
    (h : ∀ x y : G, x * y = y * x) : OutAut G ≃* MulAut G :=
  (QuotientGroup.quotientMulEquivOfEq (innAut_eq_bot_of_comm G h)).trans
    QuotientGroup.quotientBot

variable {C : Type u} [Groupoid.{v} C] {c : C}

/-- **A `K(A,1)` with abelian fundamental group has homotopy self-equivalence group
`Aut A`.** -/
noncomputable def hEnd_units_mulEquiv_mulAut_of_comm (hC : ConnectedAt C c)
    (h : ∀ x y : Aut c, x * y = y * x) : (HEnd C)ˣ ≃* MulAut (Aut c) :=
  (outAut_mulEquiv_hEnd_units hC).symm.trans (outAutMulEquivMulAut_of_comm _ h)

end Abelian

/-- Transport of endomorphism monoids along an isomorphism of groups. -/
def monoidEndCongr {G : Type*} [Group G] {H : Type*} [Group H] (e : G ≃* H) :
    Monoid.End G ≃* Monoid.End H where
  toFun φ := (e.toMonoidHom.comp φ).comp e.symm.toMonoidHom
  invFun ψ := (e.symm.toMonoidHom.comp ψ).comp e.toMonoidHom
  left_inv φ := MonoidHom.ext fun a => by simp
  right_inv ψ := MonoidHom.ext fun a => by simp
  map_mul' φ ψ := MonoidHom.ext fun a => by
    show e (φ (ψ (e.symm a))) = e (φ (e.symm (e (ψ (e.symm a)))))
    simp

/-- For an abelian group, conjugacy classes of endomorphisms are just endomorphisms:
the monoid `ConjEnd A` is the endomorphism monoid `End A`. -/
def conjEndMulEquivEnd_of_comm (G : Type*) [Group G] (h : ∀ x y : G, x * y = y * x) :
    ConjEnd G ≃* Monoid.End G where
  toFun := Quotient.lift (fun φ : G →* G => (φ : Monoid.End G))
    (by
      rintro φ ψ ⟨u, hu⟩
      refine MonoidHom.ext fun a => ?_
      rw [hu a, h u (φ a)]
      simp [mul_assoc])
  invFun φ := ConjEnd.mk G φ
  left_inv q := by induction q using ConjEnd.ind with | _ φ => rfl
  right_inv φ := rfl
  map_mul' a b := by
    induction a using ConjEnd.ind with
    | _ φ => induction b using ConjEnd.ind with
      | _ ψ => rfl

/-! ## One-object models `K(G,1) = SingleObj G` -/

section SingleObjModel

variable (M : Type u) [Group M]

/-- The one-object groupoid of a group is connected. -/
theorem singleObj_connected : ConnectedAt (SingleObj M) (SingleObj.star M) := by
  intro d
  exact ⟨eqToIso (Subsingleton.elim _ _)⟩

/-- The fundamental group of the one-object model `K(G,1)` is `G` itself. -/
noncomputable def singleObjAut : Aut (SingleObj.star M) ≃* M :=
  (autMulEquivEnd (SingleObj.star M)).trans (SingleObj.toEnd M).symm

theorem singleObjAut_comm (h : ∀ x y : M, x * y = y * x)
    (x y : Aut (SingleObj.star M)) : x * y = y * x := by
  apply (singleObjAut M).injective
  rw [map_mul, map_mul, h]

/-- **`Aut(A)` is the homotopy self-equivalence group of `K(A,1)` for abelian `A`.** -/
noncomputable def hEndUnitsSingleObjMulEquivMulAut (h : ∀ x y : M, x * y = y * x) :
    (HEnd (SingleObj M))ˣ ≃* MulAut M :=
  (hEnd_units_mulEquiv_mulAut_of_comm (singleObj_connected M) (singleObjAut_comm M h)).trans
    (MulAut.congr (singleObjAut M))

end SingleObjModel

/-! ## The circle: `K(ℤ,1)` has exactly two self-homotopy-equivalences -/

section Circle

open Multiplicative

/-- The algebraic model of the circle: the one-object groupoid of the group `ℤ`. -/
abbrev CircleModel : Type := SingleObj (Multiplicative ℤ)

theorem circleModel_connected :
    ConnectedAt CircleModel (SingleObj.star (Multiplicative ℤ)) :=
  singleObj_connected _

/-- The fundamental group of the circle model is `ℤ`. -/
noncomputable def circleAut : Aut (SingleObj.star (Multiplicative ℤ)) ≃* Multiplicative ℤ :=
  singleObjAut _

/-- **Every endomorphism of `ℤ` is multiplication by an integer**, namely by the image of
the generator. -/
theorem monoidHom_multiplicative_int_apply (φ : Multiplicative ℤ →* Multiplicative ℤ) (k : ℤ) :
    φ (ofAdd k) = ofAdd (k * toAdd (φ (ofAdd 1))) := by
  have h1 : φ (ofAdd k) = (φ (ofAdd 1)) ^ k := by
    rw [← map_zpow]; congr 1; rw [← ofAdd_zsmul]; simp
  have h2 : φ (ofAdd 1) = ofAdd (toAdd (φ (ofAdd 1))) := rfl
  rw [h1, h2, ← ofAdd_zsmul]
  simp

/-- **The degree map.**  The endomorphism monoid of the group `ℤ` is the multiplicative
monoid of integers: an endomorphism is multiplication by its degree, and composition is
multiplication of degrees. -/
def endMultiplicativeIntMulEquivInt : Monoid.End (Multiplicative ℤ) ≃* ℤ where
  toFun φ := toAdd (φ (ofAdd 1))
  invFun n :=
    { toFun := fun x => ofAdd (toAdd x * n)
      map_one' := by simp
      map_mul' := by intro x y; simp [add_mul, ofAdd_add] }
  left_inv φ := MonoidHom.ext fun x => by
    simpa using (monoidHom_multiplicative_int_apply φ (toAdd x)).symm
  right_inv n := by
    show toAdd (ofAdd (toAdd (ofAdd (1 : ℤ)) * n)) = n
    simp
  map_mul' φ ψ := by
    show toAdd (φ (ψ (ofAdd 1))) = toAdd (φ (ofAdd 1)) * toAdd (ψ (ofAdd 1))
    rw [show ψ (ofAdd 1) = ofAdd (toAdd (ψ (ofAdd 1))) from rfl,
      monoidHom_multiplicative_int_apply φ (toAdd (ψ (ofAdd 1)))]
    simp [mul_comm]

/-- **The automorphism group of `ℤ` has exactly two elements.**  Every automorphism of `ℤ`
is the identity or the inversion. -/
theorem mulAut_multiplicative_int_eq_one_or_inv (e : MulAut (Multiplicative ℤ)) :
    e = 1 ∨ e = MulEquiv.inv (Multiplicative ℤ) := by
  set n : ℤ := toAdd (e (ofAdd 1)) with hn
  have hval : ∀ k : ℤ, e (ofAdd k) = ofAdd (k * n) := fun k =>
    monoidHom_multiplicative_int_apply e.toMonoidHom k
  obtain ⟨x, hx⟩ := e.surjective (ofAdd 1)
  have hxk : e (ofAdd (toAdd x)) = ofAdd 1 := by simpa using hx
  rw [hval] at hxk
  have hone : n * toAdd x = 1 := by simpa using congrArg toAdd hxk
  have hu : n = 1 ∨ n = -1 := Int.eq_one_or_neg_one_of_mul_eq_one hone
  have hy : ∀ y : Multiplicative ℤ, e y = ofAdd (toAdd y * n) := fun y => hval (toAdd y)
  rcases hu with h | h
  · exact Or.inl (by ext y; simp [hy y, h])
  · exact Or.inr (by ext y; simp [hy y, h, MulEquiv.inv])

theorem card_mulAut_multiplicative_int : Nat.card (MulAut (Multiplicative ℤ)) = 2 := by
  rw [Nat.card_eq_two_iff]
  refine ⟨1, MulEquiv.inv (Multiplicative ℤ), ?_, ?_⟩
  · intro hcon
    have h2 := congrArg (fun f : MulAut (Multiplicative ℤ) => f (ofAdd 1)) hcon
    simp [MulEquiv.inv] at h2
    exact absurd (congrArg toAdd h2) (by decide)
  · ext e
    simpa using mulAut_multiplicative_int_eq_one_or_inv e

theorem circleAut_comm (x y : Aut (SingleObj.star (Multiplicative ℤ))) : x * y = y * x :=
  singleObjAut_comm _ (fun x y => mul_comm x y) x y

/-- **The circle has exactly two homotopy classes of self-homotopy-equivalences.**
Concretely: `hAut(S¹) ≅ Out(ℤ) = Aut(ℤ) = ±1`, the degree `±1` maps. -/
theorem card_hEnd_units_circleModel : Nat.card ((HEnd CircleModel)ˣ) = 2 := by
  rw [Nat.card_congr
      (hEndUnitsSingleObjMulEquivMulAut (Multiplicative ℤ) (fun x y => mul_comm x y)).toEquiv,
    card_mulAut_multiplicative_int]

/-- **Degree classifies self-maps of the circle.**  Homotopy classes of self-maps of
`K(ℤ,1)` form the multiplicative monoid `(ℤ, ·)`: the degree.  Composition of maps
corresponds to multiplication of degrees. -/
noncomputable def hEndCircleMulEquivInt : HEnd CircleModel ≃* ℤ :=
  ((hEndMulEquivConjEnd circleModel_connected).trans
      (conjEndMulEquivEnd_of_comm _ circleAut_comm)).trans
    ((monoidEndCongr circleAut).trans endMultiplicativeIntMulEquivInt)

/-- The degree of a self-map of the circle model. -/
noncomputable def degree (F : CircleModel ⥤ CircleModel) : ℤ :=
  hEndCircleMulEquivInt (HEnd.mk CircleModel F)

/-- The degree is multiplicative under composition. -/
theorem degree_comp (F G : CircleModel ⥤ CircleModel) :
    degree (F ⋙ G) = degree G * degree F := by
  show hEndCircleMulEquivInt (HEnd.mk CircleModel G * HEnd.mk CircleModel F) = _
  rw [map_mul]
  rfl

@[simp] theorem degree_id : degree (𝟭 CircleModel) = 1 := by
  show hEndCircleMulEquivInt 1 = 1
  simp

/-- **Every integer is the degree of a self-map of the circle.** -/
theorem degree_surjective : Function.Surjective degree := by
  intro n
  obtain ⟨q, hq⟩ := hEndCircleMulEquivInt.surjective n
  obtain ⟨F, hF⟩ := Quotient.exists_rep q
  refine ⟨F, ?_⟩
  have : HEnd.mk CircleModel F = q := hF
  rw [degree, this, hq]

/-- **Degree is a complete invariant of self-maps of the circle up to homotopy.** -/
theorem degree_eq_iff_natIso (F G : CircleModel ⥤ CircleModel) :
    degree F = degree G ↔ Nonempty (F ≅ G) := by
  rw [degree, degree, EmbeddingLike.apply_eq_iff_eq]
  exact HEnd.mk_eq_mk

/-- **A self-map of the circle is a homotopy equivalence exactly when its degree is
`±1`.** -/
theorem isEquivalence_circle_iff_degree (F : CircleModel ⥤ CircleModel) :
    F.IsEquivalence ↔ degree F = 1 ∨ degree F = -1 := by
  rw [← isUnit_hEnd_mk_iff, ← Int.isUnit_iff]
  constructor
  · intro h
    exact h.map hEndCircleMulEquivInt
  · intro h
    have := h.map hEndCircleMulEquivInt.symm
    simpa [degree] using this

end Circle

end FundamentalGroupOut
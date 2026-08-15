/-
# Deepening the `K(G,1)` classification: fibres, functoriality, and `π₀`

This file continues `Catalog/Bridges/FundamentalGroupK1Classification.lean`, which
established the bijection `[K(G,1), K(H,1)] ≃ Hom(G,H)/conjugation` for connected
groupoids (algebraic models of Eilenberg–MacLane 1-types).  We settle three of the
conjectures recorded in `FUTURE_DIRECTIONS.md`:

* **Fibres of the classification (C3).**  The conjugation action of `H` on `Hom(G,H)`
  has stabiliser the centraliser of the image, hence the set of homomorphisms
  realising a *fixed* homotopy class of maps is in bijection with
  `H ⧸ C_H(φ(G))`, and has cardinality the index of that centraliser
  (`card_homs_natIso_realize`).

* **Functoriality of the classification (C1).**  The induced homomorphism of an
  identity functor is the identity, and the homomorphism induced by a composite is
  conjugate to the composite of the induced homomorphisms; at the level of the
  classification bijection this is an exact equality of conjugacy classes
  (`toConjClass_comp`).

* **`π₀` as the remaining invariant (C2).**  Isomorphism classes of objects form the
  `π₀` of a 1-type; it is invariant under equivalence (`componentsEquivOfEquivalence`),
  and for totally disconnected 1-types (discrete groupoids, all of whose vertex groups
  are trivial) it is a *complete* invariant:
  `Nonempty (Discrete α ≌ Discrete β) ↔ Nonempty (α ≃ β)`
  (`discrete_equivalence_iff_nonempty_equiv`).  This explains precisely the failure
  of the fundamental group to classify recorded in the previous cycle.
-/
import Mathlib
import Bridges.FundamentalGroupK1Classification
open CategoryTheory
open FundamentalGroupCompleteInvariant (ConnectedAt)
open FundamentalGroupK1

namespace FundamentalGroupK1Deep

universe u v u' v' u'' v''

/-! ## The conjugation action on `Hom(G,H)` -/

section ConjAction

variable {G : Type*} [Group G] {H : Type*} [Group H]

/-- Conjugation action of the target group on homomorphisms. -/
instance conjSMul : SMul H (G →* H) :=
  ⟨fun u φ => ((MulAut.conj u).toMonoidHom).comp φ⟩

@[simp] theorem conj_smul_apply (u : H) (φ : G →* H) (a : G) :
    (u • φ) a = u * φ a * u⁻¹ := rfl

instance conjMulAction : MulAction H (G →* H) where
  one_smul φ := by ext a; simp
  mul_smul u v φ := by ext a; simp [mul_assoc]

/-- Two homomorphisms lie in the same orbit of the conjugation action exactly when
they are conjugate, i.e. exactly when they are identified in `conjSetoid`. -/
theorem mem_orbit_iff_conj (φ ψ : G →* H) :
    ψ ∈ MulAction.orbit H φ ↔ ∃ u : H, ∀ a, ψ a = u * φ a * u⁻¹ := by
  rw [MulAction.mem_orbit_iff]
  exact ⟨fun ⟨u, hu⟩ => ⟨u, fun a => by rw [← hu, conj_smul_apply]⟩,
         fun ⟨u, hu⟩ => ⟨u, MonoidHom.ext fun a => (hu a).symm⟩⟩

/-- **The stabiliser of a homomorphism is the centraliser of its image.** -/
theorem stabilizer_eq_centralizer (φ : G →* H) :
    MulAction.stabilizer H φ = Subgroup.centralizer (Set.range φ) := by
  ext u
  simp only [Subgroup.mem_centralizer_iff, MulAction.mem_stabilizer_iff]
  constructor
  · intro h' x hx
    obtain ⟨g, rfl⟩ := hx
    have := congr_arg (· g) h'
    simp [conj_smul_apply] at this
    have h := congr_arg (· * u) this
    simp at h
    exact h.symm
  · intro h'
    ext g
    simp [conj_smul_apply]
    have := h' (φ g) (Set.mem_range_self g)
    rw [mul_inv_eq_iff_eq_mul]
    exact this.symm

/-- The orbit of `φ` under conjugation is in bijection with the coset space of the
centraliser of its image. -/
noncomputable def orbitEquivQuotientCentralizer (φ : G →* H) :
    MulAction.orbit H φ ≃ H ⧸ Subgroup.centralizer (Set.range φ) :=
  (MulAction.orbitEquivQuotientStabilizer H φ).trans
    (Quotient.congrRight (by rw [stabilizer_eq_centralizer φ]; exact fun _ _ => Iff.rfl))

/-- The number of homomorphisms conjugate to `φ` is the index of the centraliser of
the image of `φ`. -/
theorem card_orbit_eq_index_centralizer (φ : G →* H) :
    Nat.card (MulAction.orbit H φ) = (Subgroup.centralizer (Set.range φ)).index := by
  have h1 := Nat.card_congr (orbitEquivQuotientCentralizer φ)
  rw [h1, Subgroup.index]

end ConjAction

/-! ## Fibres of the classification `[K(G,1), K(H,1)] → Hom(G,H)/conj` -/

section Fibres

variable {C : Type u} [Groupoid.{v} C] {c : C} {D : Type u'} [Groupoid.{v'} D] {d₀ : D}

/-- Two homomorphisms are realised by homotopic maps exactly when they lie in the
same conjugation orbit. -/
theorem natIso_realize_iff_mem_orbit (hC : ConnectedAt C c) (d₀ : D) (φ ψ : Aut c →* Aut d₀) :
    Nonempty (realize hC d₀ φ ≅ realize hC d₀ ψ) ↔ ψ ∈ MulAction.orbit (Aut d₀) φ := by
  rw [realize_natIso_iff_conj]
  rw [MulAction.mem_orbit_iff]
  exact ⟨fun ⟨u, hu⟩ => ⟨u, MonoidHom.ext fun a => by rw [hu, conj_smul_apply]⟩,
         fun ⟨u, hu⟩ => ⟨u, fun a => by rw [← hu, conj_smul_apply]⟩⟩

/-- **Fibres of the classification.**  The homomorphisms inducing a fixed homotopy
class of maps of 1-types are exactly a coset space of the centraliser of the image;
in particular their number is the index of that centraliser. -/
theorem card_homs_natIso_realize (hC : ConnectedAt C c) (φ : Aut c →* Aut d₀) :
    Nat.card {ψ : Aut c →* Aut d₀ // Nonempty (realize hC d₀ φ ≅ realize hC d₀ ψ)}
      = (Subgroup.centralizer (Set.range φ)).index := by
  have : {ψ : Aut c →* Aut d₀ // Nonempty (realize hC d₀ φ ≅ realize hC d₀ ψ)} =
      {ψ : Aut c →* Aut d₀ // ψ ∈ MulAction.orbit (Aut d₀) φ} := by
    congr 1 with ψ
    exact natIso_realize_iff_mem_orbit hC d₀ φ ψ
  rw [this]
  exact card_orbit_eq_index_centralizer φ

end Fibres

/-! ## Functoriality of the classification -/

section Functoriality

variable {C : Type u} [Groupoid.{v} C] {c : C}
  {D : Type u'} [Groupoid.{v'} D] {d₀ : D}
  {E : Type u''} [Groupoid.{v''} E] {e₀ : E}

/-- The identity functor induces the identity homomorphism of vertex groups. -/
theorem inducedHom_id (hC : ConnectedAt C c) :
    inducedHom hC (𝟭 C) c = MonoidHom.id (Aut c) := by
  ext a
  simp [inducedHom, Functor.mapAut]
  simp [Aut.autMulEquivOfIso]

/-- The underlying morphism of an induced automorphism: conjugation of the image of
`a` by the chosen path from the basepoint. -/
theorem inducedHom_hom (hD : ConnectedAt D d₀) (F : C ⥤ D) (a : Aut c) :
    (inducedHom hD F c a).hom
      = (basePath hD (F.obj c)).hom ≫ F.map a.hom ≫ (basePath hD (F.obj c)).inv := rfl

/-- **The classification is functorial.**  The homomorphism induced by a composite of
functors is conjugate to the composite of the induced homomorphisms. -/
theorem inducedHom_comp_conj (hD : ConnectedAt D d₀) (hE : ConnectedAt E e₀)
    (F : C ⥤ D) (G : D ⥤ E) :
    ∃ u : Aut e₀, ∀ a : Aut c,
      inducedHom hE (F ⋙ G) c a
        = u * ((inducedHom hE G d₀).comp (inducedHom hD F c)) a * u⁻¹ := by
  refine ⟨basePath hE (G.obj d₀) ≪≫ G.mapIso (basePath hD (F.obj c))
      ≪≫ (basePath hE (G.obj (F.obj c))).symm, fun a => ?_⟩
  ext
  simp only [Aut.Aut_mul_def, Aut.Aut_inv_def, Iso.trans_hom, Iso.symm_hom, Iso.symm_inv,
    Iso.trans_inv, Functor.mapIso_hom, Functor.mapIso_inv, Category.assoc,
    MonoidHom.coe_comp, Function.comp_apply]
  rw [inducedHom_hom hE G ((inducedHom hD F c) a), inducedHom_hom hD F a]
  simp
  exact inducedHom_hom hE (F ⋙ G) a

/-- Functoriality at the level of the classification bijection: the conjugacy class
assigned to a composite is the class of the composite of the assigned homomorphisms. -/
theorem toConjClass_comp (hD : ConnectedAt D d₀) (hE : ConnectedAt E e₀)
    (F : C ⥤ D) (G : D ⥤ E) :
    toConjClass hE c (Quotient.mk (natIsoSetoid C E) (F ⋙ G))
      = Quotient.mk (conjSetoid (Aut c) (Aut e₀))
          ((inducedHom hE G d₀).comp (inducedHom hD F c)) := by
  unfold toConjClass
  simp only [Quotient.map'_mk]
  obtain ⟨u, hu⟩ := inducedHom_comp_conj hD hE F G
  apply Quotient.sound
  use u⁻¹
  intro a
  rw [hu a]
  group

end Functoriality

/-! ## `π₀` of a 1-type -/

section Components

/-- Isomorphism of objects, as a setoid: its quotient is `π₀` of the 1-type. -/
def isoSetoid (C : Type u) [Category.{v} C] : Setoid C where
  r X Y := Nonempty (X ≅ Y)
  iseqv := ⟨fun _ => ⟨Iso.refl _⟩, fun ⟨e⟩ => ⟨e.symm⟩, fun ⟨e⟩ ⟨f⟩ => ⟨e.trans f⟩⟩

/-- The set of connected components (`π₀`) of a 1-type. -/
def Components (C : Type u) [Category.{v} C] : Type u := Quotient (isoSetoid C)

variable {C : Type u} [Category.{v} C] {D : Type u'} [Category.{v'} D]

/-- The map on components induced by a functor. -/
def mapComponents (F : C ⥤ D) : Components C → Components D :=
  Quotient.map F.obj (fun _ _ ⟨e⟩ => ⟨F.mapIso e⟩)

@[simp] theorem mapComponents_mk (F : C ⥤ D) (X : C) :
    mapComponents F (Quotient.mk (isoSetoid C) X) = Quotient.mk (isoSetoid D) (F.obj X) := rfl

/-- **`π₀` is a homotopy invariant.**  An equivalence of 1-types induces a bijection
of their sets of connected components. -/
def componentsEquivOfEquivalence (e : C ≌ D) : Components C ≃ Components D where
  toFun := mapComponents e.functor
  invFun := mapComponents e.inverse
  left_inv := by
    intro q
    induction q using Quotient.ind with
    | _ X => exact Quotient.sound ⟨(e.unitIso.app X).symm⟩
  right_inv := by
    intro q
    induction q using Quotient.ind with
    | _ Y => exact Quotient.sound ⟨e.counitIso.app Y⟩

/-- A 1-type is connected exactly when it has (at most) one component. -/
theorem subsingleton_components_of_connectedAt {c : C} (hC : ConnectedAt C c) :
    Subsingleton (Components C) := by
  refine ⟨fun x y => ?_⟩
  induction x using Quotient.ind
  induction y using Quotient.ind
  exact Quotient.sound ⟨(hC _).some.symm.trans (hC _).some⟩

end Components

/-! ## `π₀` is a complete invariant for totally disconnected 1-types -/

section Discrete

/-- The components of a discrete 1-type are its objects. -/
def componentsDiscreteEquiv (α : Type u) : Components (Discrete α) ≃ α where
  toFun := Quotient.lift (fun X => X.as) (by
    rintro ⟨x⟩ ⟨y⟩ ⟨e⟩
    exact Discrete.eq_of_hom e.hom)
  invFun a := Quotient.mk _ ⟨a⟩
  left_inv := by
    intro q
    induction q using Quotient.ind with
    | _ X => cases X; rfl
  right_inv _ := rfl

/-- **Discrete 1-types are classified by `π₀`.**  Two discrete groupoids (models of
totally disconnected homotopy 1-types, all of whose fundamental groups are trivial)
are equivalent exactly when their sets of components are in bijection.  Together with
`FundamentalGroupK1.connectedness_necessary` this pins down `π₀` as exactly the
information the fundamental group misses in this setting. -/
theorem discrete_equivalence_iff_nonempty_equiv (α : Type u) (β : Type u) :
    Nonempty (Discrete α ≌ Discrete β) ↔ Nonempty (α ≃ β) := by
  constructor
  · intro ⟨e⟩
    exact ⟨((componentsDiscreteEquiv α).symm.trans
      (componentsEquivOfEquivalence e)).trans (componentsDiscreteEquiv β)⟩
  · intro ⟨f⟩
    exact ⟨Discrete.equivalence f⟩

end Discrete

end FundamentalGroupK1Deep
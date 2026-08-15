/-
# Self-maps of a disjoint union of *pairwise different* `K(G,1)`s

`Catalog/Bridges/FundamentalGroupWreathProduct.lean` computes the monoid of homotopy
classes of self-maps, and the group of homotopy self-equivalences, of a disjoint union of
`ι` copies of **one** `K(G,1)`:

  `hAut (⊔_{i ∈ ι} K(G,1)) ≅ Out(G) ≀ Sym(ι)`.

This file removes the hypothesis that the components are all the same — item 1 of
`FUTURE_DIRECTIONS.md`.  For an arbitrary family `C : ι → Groupoid` of connected 1-types
(a general 1-type is the disjoint union of its components, see
`FundamentalGroupPi0Decomposition.lean`), the answer is a *matrix monoid*: a self-map of
`⊔ᵢ Cᵢ` is a self-map `σ` of the index set together with, for every `i`, a homotopy class
of maps `Cᵢ → C_{σ i}`.

* `HMap A B` : the set of homotopy classes of maps `A → B`, with composition `HMap.comp`;
* `WreathHom C` : the monoid of pairs `⟨σ, P⟩` with `σ : ι → ι` and
  `P i : HMap (C i) (C (σ i))`, multiplied by `⟨σ,P⟩ * ⟨τ,Q⟩ = ⟨σ ∘ τ, i ↦ Q i ; P (τ i)⟩`;
* `exists_factor` : a map out of a connected 1-type factors, up to homotopy, through a
  single component of the target — the technical heart;
* `hEndSigmaMulEquivWreath` : **`[⊔ᵢ Cᵢ, ⊔ᵢ Cᵢ] ≅ WreathHom C`** (all self-maps, not only
  the equivalences), and `wreathMulEquivHEndSigma` for the inverse isomorphism;
* `hAutSigmaToPerm` : the induced group homomorphism `hAut(⊔ᵢ Cᵢ) → Sym(ι)`, computed on
  representatives by `hAutSigmaToPerm_apply`;
* `exists_hAut_perm_iff` : its **image** consists exactly of the permutations `σ` with
  `Cᵢ ≌ C_{σ i}` for every `i`;
* `kerHAutSigmaToPermMulEquivPiOut` : its **kernel** is `∏ᵢ Out(π₁ Cᵢ)` (via
  `diagUnitsMulEquivKer`, `kerMulEquivPiOut`).  So

    `1 → ∏ᵢ Out(π₁ Cᵢ) → hAut(⊔ᵢ Cᵢ) → Sym'(π₀) → 1`

  is exact, where `Sym'` denotes the permutations of `π₀` preserving the homotopy type of
  each component;
* `hAutMulEquivPiOut_of_pairwise` : when no two components are homotopy equivalent, the
  answer is simply `∏ᵢ Out(π₁ Cᵢ)`; `card_hAut_of_pairwise` counts it;
* `autIdSigmaMulEquivPiCenter` : the self-homotopies of the identity form `∏ᵢ Z(π₁ Cᵢ)`,
  so the whole automorphism 2-group of an arbitrary 1-type is determined.

Both extreme cases are recovered: for a constant family every permutation of the
components is realised (see `FundamentalGroupHeterogeneousExamples.perm_surjective_of_constant`
and, for the full wreath-product description, `FundamentalGroupWreathProduct.lean`), while
for pairwise inequivalent components none is.
-/
import Mathlib
import Bridges.FundamentalGroupOuterAutomorphisms
import Bridges.FundamentalGroupPi0Gluing
import Bridges.FundamentalGroupMapsClassification
open CategoryTheory
open FundamentalGroupCompleteInvariant (ConnectedAt)
open FundamentalGroupK1
open FundamentalGroupOut

namespace FundamentalGroupHetero

universe w v u

/-! ## Homotopy classes of maps -/

section HMap

variable (A : Type u) [Category.{v} A] (B : Type u) [Category.{v} B]

/-- Homotopy classes of maps of 1-types: natural-isomorphism classes of functors. -/
def HMap : Type max u v := Quotient (natIsoSetoid A B)

variable {A B}

/-- The homotopy class of a functor. -/
def HMap.mk (F : A ⥤ B) : HMap A B := Quotient.mk (natIsoSetoid A B) F

theorem HMap.mk_eq_mk {F G : A ⥤ B} : HMap.mk F = HMap.mk G ↔ Nonempty (F ≅ G) :=
  Quotient.eq (r := natIsoSetoid A B)

@[elab_as_elim]
theorem HMap.ind {motive : HMap A B → Prop} (h : ∀ F : A ⥤ B, motive (HMap.mk F)) :
    ∀ q, motive q := Quotient.ind h

theorem HMap.mk_out (q : HMap A B) : HMap.mk (Quotient.out q) = q := Quotient.out_eq q

variable {E : Type u} [Category.{v} E]

/-- Composition of homotopy classes, in diagrammatic order. -/
def HMap.comp : HMap A B → HMap B E → HMap A E :=
  Quotient.map₂ (fun F G => F ⋙ G)
    (by
      rintro F F' ⟨eF⟩ G G' ⟨eG⟩
      exact ⟨(Functor.isoWhiskerRight eF G).trans (Functor.isoWhiskerLeft F' eG)⟩)

@[simp] theorem HMap.comp_mk (F : A ⥤ B) (G : B ⥤ E) :
    HMap.comp (HMap.mk F) (HMap.mk G) = HMap.mk (F ⋙ G) := rfl

theorem HMap.comp_assoc {A' : Type u} [Category.{v} A'] (f : HMap A B) (g : HMap B E)
    (h : HMap E A') : HMap.comp (HMap.comp f g) h = HMap.comp f (HMap.comp g h) := by
  induction f using HMap.ind
  induction g using HMap.ind
  induction h using HMap.ind
  rfl

@[simp] theorem HMap.comp_id (f : HMap A B) : HMap.comp f (HMap.mk (𝟭 B)) = f := by
  induction f using HMap.ind; rfl

@[simp] theorem HMap.id_comp (f : HMap A B) : HMap.comp (HMap.mk (𝟭 A)) f = f := by
  induction f using HMap.ind; rfl

end HMap

/-! ## The matrix (wreath) monoid of a family of 1-types -/

section Wreath

variable {ι : Type w} (C : ι → Type u) [∀ i, Groupoid.{v} (C i)]

/-- A homotopy class of self-maps of `⊔ᵢ Cᵢ`, in matrix form: a self-map `idx` of the
index set together with a homotopy class of maps `Cᵢ → C_{idx i}` for every `i`. -/
structure WreathHom where
  /-- The induced self-map of the index set. -/
  idx : ι → ι
  /-- The homotopy class of the `i`-th piece. -/
  cls : ∀ i, HMap (C i) (C (idx i))

variable {C}

theorem WreathHom.ext' {σ : ι → ι} {P Q : ∀ i, HMap (C i) (C (σ i))} (h : ∀ i, P i = Q i) :
    (⟨σ, P⟩ : WreathHom C) = ⟨σ, Q⟩ := by
  simpa using congrArg (WreathHom.mk σ) (funext h)

variable (C)

instance : Monoid (WreathHom C) where
  mul x y := ⟨fun i => x.idx (y.idx i), fun i => HMap.comp (y.cls i) (x.cls (y.idx i))⟩
  one := ⟨fun i => i, fun i => HMap.mk (𝟭 (C i))⟩
  mul_assoc x y z := WreathHom.ext' fun i =>
    (HMap.comp_assoc (z.cls i) (y.cls (z.idx i)) (x.cls (y.idx (z.idx i)))).symm
  one_mul x := WreathHom.ext' fun i => HMap.comp_id (x.cls i)
  mul_one x := WreathHom.ext' fun i => HMap.id_comp (x.cls i)

variable {C}

@[simp] theorem WreathHom.mul_idx (x y : WreathHom C) :
    (x * y).idx = fun i => x.idx (y.idx i) := rfl

@[simp] theorem WreathHom.mul_cls (x y : WreathHom C) (i : ι) :
    (x * y).cls i = HMap.comp (y.cls i) (x.cls (y.idx i)) := rfl

@[simp] theorem WreathHom.one_idx : (1 : WreathHom C).idx = fun i => i := rfl

@[simp] theorem WreathHom.one_cls (i : ι) : (1 : WreathHom C).cls i = HMap.mk (𝟭 (C i)) := rfl

/-- Every element of the matrix monoid is given by an honest family of functors. -/
@[elab_as_elim]
theorem WreathHom.ind {motive : WreathHom C → Prop}
    (h : ∀ (σ : ι → ι) (P : ∀ i, C i ⥤ C (σ i)), motive ⟨σ, fun i => HMap.mk (P i)⟩) :
    ∀ x, motive x := by
  rintro ⟨σ, P⟩
  have : (fun i => HMap.mk (Quotient.out (P i))) = P := funext fun i => HMap.mk_out (P i)
  simpa [this] using h σ fun i => Quotient.out (P i)

end Wreath

/-! ## Factoring a map out of a connected 1-type through a single component -/

section Factor

open FundamentalGroupPi0 (sigmaGroupoid autSigmaMulEquiv fst_eq_of_iso sigmaDesc)

variable {ι : Type w} {C : ι → Type u} [∀ i, Groupoid.{v} (C i)]
  {A : Type u} [Groupoid.{v} A] {a : A}

/-- Applying the inclusion of a summand to a vertex-group element. -/
theorem autSigmaMulEquiv_hom (i : ι) (X : C i) (y : Aut X) :
    ((autSigmaMulEquiv i X) y).hom = (Sigma.incl i).map y.hom := rfl

/-- **A map out of a connected 1-type factors through a single component of the target.**
Up to homotopy, a functor from a connected groupoid to a disjoint union is the inclusion of
one summand precomposed with a functor into that summand. -/
theorem exists_factor (hA : ConnectedAt A a) (F : A ⥤ Σ i, C i) :
    ∃ (j : ι) (P : A ⥤ C j), Nonempty (F ≅ P ⋙ Sigma.incl j) := by
  refine ⟨(F.obj a).1, realize hA (F.obj a).2
    (((autSigmaMulEquiv (F.obj a).1 (F.obj a).2).symm).toMonoidHom.comp (F.mapAut a)), ?_⟩
  set j := (F.obj a).1 with hj
  set d := (F.obj a).2 with hd
  set ψ := ((autSigmaMulEquiv j d).symm).toMonoidHom.comp (F.mapAut a) with hψ
  rw [natIso_iff_conjugating_iso hA]
  refine ⟨Iso.refl _, fun x => ?_⟩
  have key : (Sigma.incl j).map ((ψ x).hom) = F.map x.hom := by
    have h1 : (autSigmaMulEquiv j d) (ψ x) = F.mapAut a x :=
      (autSigmaMulEquiv j d).apply_symm_apply _
    calc (Sigma.incl j).map ((ψ x).hom) = ((autSigmaMulEquiv j d) (ψ x)).hom :=
          (autSigmaMulEquiv_hom j d (ψ x)).symm
      _ = (F.mapAut a x).hom := by rw [h1]
      _ = F.map x.hom := rfl
  simp only [Iso.refl_hom, Category.comp_id, Category.id_comp, Functor.comp_map]
  rw [realize_map_aut, key]

/-- Two factorisations through summands use the same summand. -/
theorem index_eq_of_natIso_incl (a : A) {j k : ι} {P : A ⥤ C j} {Q : A ⥤ C k}
    (e : P ⋙ Sigma.incl j ≅ Q ⋙ Sigma.incl k) : j = k :=
  fst_eq_of_iso (e.app a)

/-- Two factorisations through the same summand are homotopic there. -/
theorem natIso_of_natIso_incl {j : ι} {P Q : A ⥤ C j}
    (e : P ⋙ Sigma.incl j ≅ Q ⋙ Sigma.incl j) : Nonempty (P ≅ Q) :=
  ⟨Functor.fullyFaithfulCancelRight (Sigma.incl j) e⟩

end Factor

/-! ## The matrix monoid computes all self-maps of a disjoint union -/

section Main

open FundamentalGroupPi0 (sigmaGroupoid fst_eq_of_iso sigmaDesc sigmaDesc_obj)

variable {ι : Type w} {C : ι → Type u} [∀ i, Groupoid.{v} (C i)] {c : ∀ i, C i}

/-- The self-map of `⊔ᵢ Cᵢ` determined by a matrix of homotopy classes. -/
noncomputable def toHEnd (x : WreathHom C) : HEnd (Σ i, C i) :=
  HEnd.mk _ (sigmaDesc x.idx fun i => Quotient.out (x.cls i))

theorem toHEnd_mk (σ : ι → ι) (P : ∀ i, C i ⥤ C (σ i)) :
    toHEnd (⟨σ, fun i => HMap.mk (P i)⟩ : WreathHom C) = HEnd.mk _ (sigmaDesc σ P) := by
  refine HEnd.mk_eq_mk.2 ⟨Sigma.natIso fun i => ?_⟩
  have α : Quotient.out (HMap.mk (P i)) ≅ P i :=
    (HMap.mk_eq_mk.1 (HMap.mk_out (HMap.mk (P i)))).some
  exact (Sigma.inclDesc (fun i => Quotient.out (HMap.mk (P i)) ⋙ Sigma.incl (σ i)) i).trans
    ((Functor.isoWhiskerRight α (Sigma.incl (σ i))).trans
      (Sigma.inclDesc (fun i => P i ⋙ Sigma.incl (σ i)) i).symm)

/-- The composite of two assembled self-maps is the assembly of the matrix product. -/
theorem sigmaDesc_comp (σ τ : ι → ι) (P : ∀ i, C i ⥤ C (σ i)) (Q : ∀ i, C i ⥤ C (τ i)) :
    sigmaDesc τ Q ⋙ sigmaDesc σ P
      = sigmaDesc (fun i => σ (τ i)) fun i => Q i ⋙ P (τ i) := by
  refine CategoryTheory.Functor.ext (fun X => rfl) ?_
  rintro ⟨i, X⟩ ⟨_, Y⟩ ⟨f⟩
  simp [FundamentalGroupPi0.sigmaDesc_map]

theorem toHEnd_one : toHEnd (1 : WreathHom C) = 1 := by
  have h := toHEnd_mk (C := C) (fun i => i) fun i => 𝟭 (C i)
  rw [show (1 : WreathHom C) = ⟨fun i => i, fun i => HMap.mk (𝟭 (C i))⟩ from rfl, h]
  refine HEnd.mk_eq_mk.2 ⟨Sigma.natIso fun i => ?_⟩
  exact (Sigma.inclDesc _ i).trans (Functor.leftUnitor _)

theorem toHEnd_mul (x y : WreathHom C) : toHEnd (x * y) = toHEnd x * toHEnd y := by
  induction x using WreathHom.ind with
  | _ σ P =>
    induction y using WreathHom.ind with
    | _ τ Q =>
      have hprod : (⟨σ, fun i => HMap.mk (P i)⟩ : WreathHom C)
            * ⟨τ, fun i => HMap.mk (Q i)⟩
            = ⟨fun i => σ (τ i), fun i => HMap.mk (Q i ⋙ P (τ i))⟩ := rfl
      rw [hprod, toHEnd_mk, toHEnd_mk, toHEnd_mk, HEnd.mk_mul, sigmaDesc_comp]

/-- The matrix monoid maps to homotopy classes of self-maps of the disjoint union. -/
noncomputable def toHEndHom : WreathHom C →* HEnd (Σ i, C i) where
  toFun := toHEnd
  map_one' := toHEnd_one
  map_mul' := toHEnd_mul

@[simp] theorem toHEndHom_apply (x : WreathHom C) : toHEndHom x = toHEnd x := rfl

theorem toHEnd_injective (c : ∀ i, C i) :
    Function.Injective (toHEnd (C := C)) := by
  intro x y hxy
  induction x using WreathHom.ind with
  | _ σ P =>
    induction y using WreathHom.ind with
    | _ τ Q =>
      rw [toHEnd_mk, toHEnd_mk] at hxy
      obtain ⟨e⟩ := HEnd.mk_eq_mk.1 hxy
      have epieces : ∀ i, P i ⋙ Sigma.incl (σ i) ≅ Q i ⋙ Sigma.incl (τ i) := fun i =>
        ((Sigma.inclDesc _ i).symm.trans (Functor.isoWhiskerLeft (Sigma.incl i) e)).trans
          (Sigma.inclDesc _ i)
      have hst : σ = τ := funext fun i => index_eq_of_natIso_incl (c i) (epieces i)
      subst hst
      exact WreathHom.ext' fun i =>
        HMap.mk_eq_mk.2 (natIso_of_natIso_incl (epieces i))

theorem toHEnd_surjective (hC : ∀ i, ConnectedAt (C i) (c i)) :
    Function.Surjective (toHEnd (C := C)) := by
  intro q
  induction q using HEnd.ind with
  | _ F =>
    choose σ P hP using fun i => exists_factor (hC i) (Sigma.incl i ⋙ F)
    refine ⟨⟨σ, fun i => HMap.mk (P i)⟩, ?_⟩
    rw [toHEnd_mk]
    exact HEnd.mk_eq_mk.2 ⟨(Sigma.descUniq _ F fun i => (hP i).some).symm⟩

/-- **All self-maps of a disjoint union of connected 1-types.**  The monoid of homotopy
classes of self-maps of `⊔ᵢ Cᵢ` is the matrix monoid: a self-map `σ` of the set of
components together with, for each `i`, a homotopy class of maps `Cᵢ → C_{σ i}`. -/
noncomputable def wreathMulEquivHEndSigma (hC : ∀ i, ConnectedAt (C i) (c i)) :
    WreathHom C ≃* HEnd (Σ i, C i) :=
  MulEquiv.ofBijective toHEndHom ⟨toHEnd_injective c, toHEnd_surjective hC⟩

@[simp] theorem wreathMulEquivHEndSigma_apply (hC : ∀ i, ConnectedAt (C i) (c i))
    (x : WreathHom C) : wreathMulEquivHEndSigma hC x = toHEnd x := rfl

/-- **The matrix description of homotopy classes of self-maps**, stated as an isomorphism
out of the monoid of self-maps of the disjoint union. -/
noncomputable def hEndSigmaMulEquivWreath (hC : ∀ i, ConnectedAt (C i) (c i)) :
    HEnd (Σ i, C i) ≃* WreathHom C := (wreathMulEquivHEndSigma hC).symm

end Main

/-! ## The permutation of the components induced by a self-equivalence -/

section Units

open FundamentalGroupPi0 (sigmaGroupoid fst_eq_of_iso sigmaDesc)

variable {ι : Type w} {C : ι → Type u} [∀ i, Groupoid.{v} (C i)] {c : ∀ i, C i}

theorem WreathHom.cls_inj {σ : ι → ι} {P Q : ∀ i, HMap (C i) (C (σ i))}
    (h : (⟨σ, P⟩ : WreathHom C) = ⟨σ, Q⟩) : P = Q := by simpa using h

/-- Composition of homotopy classes of self-maps is the monoid product of `HEnd`,
with the arguments in the other order. -/
theorem HMap.comp_eq_hEnd_mul {A : Type u} [Category.{v} A] (p q : HEnd A) :
    HMap.comp q p = p * q := by
  induction p using HEnd.ind
  induction q using HEnd.ind
  rfl

/-- The permutation of the set of components induced by an invertible matrix. -/
def unitsPerm (u : (WreathHom C)ˣ) : Equiv.Perm ι where
  toFun := u.val.idx
  invFun := u.inv.idx
  left_inv i := congrFun (congrArg WreathHom.idx u.inv_val) i
  right_inv i := congrFun (congrArg WreathHom.idx u.val_inv) i

@[simp] theorem unitsPerm_apply (u : (WreathHom C)ˣ) (i : ι) : unitsPerm u i = u.val.idx i :=
  rfl

/-- **The action on the set of components.**  A homotopy self-equivalence of a disjoint
union permutes the components. -/
def wreathHomUnitsToPerm : (WreathHom C)ˣ →* Equiv.Perm ι where
  toFun := unitsPerm
  map_one' := Equiv.ext fun _ => rfl
  map_mul' _ _ := Equiv.ext fun _ => rfl

@[simp] theorem wreathHomUnitsToPerm_apply (u : (WreathHom C)ˣ) (i : ι) :
    wreathHomUnitsToPerm u i = u.val.idx i := rfl

/-- The diagonal embedding of the self-maps of the individual components. -/
def piHEndToWreath : (∀ i, HEnd (C i)) →* WreathHom C where
  toFun f := ⟨fun i => i, fun i => f i⟩
  map_one' := rfl
  map_mul' f g := WreathHom.ext' fun i => (HMap.comp_eq_hEnd_mul (f i) (g i)).symm

@[simp] theorem piHEndToWreath_idx (f : ∀ i, HEnd (C i)) :
    (piHEndToWreath f).idx = fun i => i := rfl

@[simp] theorem piHEndToWreath_cls (f : ∀ i, HEnd (C i)) (i : ι) :
    (piHEndToWreath f).cls i = f i := rfl

theorem piHEndToWreath_injective : Function.Injective (piHEndToWreath (C := C)) :=
  fun _ _ h => WreathHom.cls_inj h

/-- Diagonal matrices are exactly those whose permutation of the components is trivial. -/
theorem unitsPerm_eq_one_iff (u : (WreathHom C)ˣ) :
    unitsPerm u = 1 ↔ u.val.idx = fun i => i :=
  ⟨fun h => funext fun i => congrFun (congrArg (fun e : Equiv.Perm ι => (e : ι → ι)) h) i,
    fun h => Equiv.ext fun i => congrFun h i⟩

/-- A family of homotopy self-equivalences of the components, viewed as a homotopy
self-equivalence of the disjoint union fixing each component. -/
def diagUnitsHom (f : ∀ i, (HEnd (C i))ˣ) : (WreathHom C)ˣ where
  val := ⟨fun i => i, fun i => (f i).val⟩
  inv := ⟨fun i => i, fun i => (f i).inv⟩
  val_inv := WreathHom.ext' fun i =>
    (HMap.comp_eq_hEnd_mul (f i).val (f i).inv).trans (f i).val_inv
  inv_val := WreathHom.ext' fun i =>
    (HMap.comp_eq_hEnd_mul (f i).inv (f i).val).trans (f i).inv_val

@[simp] theorem diagUnitsHom_val_cls (f : ∀ i, (HEnd (C i))ˣ) (i : ι) :
    ((diagUnitsHom f : (WreathHom C)ˣ) : WreathHom C).cls i = (f i : HEnd (C i)) := rfl

@[simp] theorem diagUnitsHom_val_idx (f : ∀ i, (HEnd (C i))ˣ) :
    ((diagUnitsHom f : (WreathHom C)ˣ) : WreathHom C).idx = fun i => i := rfl

/-- The diagonal embedding is a group homomorphism. -/
def diagUnitsMonoidHom : (∀ i, (HEnd (C i))ˣ) →* (WreathHom C)ˣ where
  toFun := diagUnitsHom
  map_one' := Units.ext (WreathHom.ext' fun _ => rfl)
  map_mul' f g := Units.ext (WreathHom.ext' fun i =>
    (HMap.comp_eq_hEnd_mul (f i : HEnd (C i)) (g i : HEnd (C i))).symm)

/-- The diagonal embedding lands in the kernel of the action on the components. -/
def diagUnits : (∀ i, (HEnd (C i))ˣ) →* (wreathHomUnitsToPerm (C := C)).ker :=
  MonoidHom.codRestrict diagUnitsMonoidHom _ fun _ =>
    MonoidHom.mem_ker.2 ((unitsPerm_eq_one_iff _).2 rfl)

theorem diagUnits_injective : Function.Injective (diagUnits (C := C)) := by
  intro f g h
  have h1 : ((diagUnitsHom f : (WreathHom C)ˣ) : WreathHom C)
      = ((diagUnitsHom g : (WreathHom C)ˣ) : WreathHom C) :=
    congrArg (fun u : (wreathHomUnitsToPerm (C := C)).ker => ((u : (WreathHom C)ˣ) : WreathHom C)) h
  have h2 := WreathHom.cls_inj h1
  exact funext fun i => Units.ext (congrFun h2 i)

theorem diagUnits_surjective : Function.Surjective (diagUnits (C := C)) := by
  rintro ⟨u, hu⟩
  have hidx : u.val.idx = fun i => i := (unitsPerm_eq_one_iff u).1 (MonoidHom.mem_ker.1 hu)
  have hidx' : u.inv.idx = fun i => i := by
    have h := congrArg WreathHom.idx u.val_inv
    simp only [WreathHom.mul_idx, WreathHom.one_idx, hidx] at h
    exact h
  obtain ⟨x, y, hxy, hyx⟩ := u
  simp only at hidx hidx'
  obtain ⟨σ, P⟩ := x
  obtain ⟨τ, Q⟩ := y
  simp only at hidx hidx'
  subst hidx
  subst hidx'
  have key : (⟨fun i => i, fun i => HMap.comp (Q i) (P i)⟩ : WreathHom C)
      = ⟨fun i => i, fun i => HMap.mk (𝟭 (C i))⟩ := hxy
  have key' : (⟨fun i => i, fun i => HMap.comp (P i) (Q i)⟩ : WreathHom C)
      = ⟨fun i => i, fun i => HMap.mk (𝟭 (C i))⟩ := hyx
  let P' : ∀ i, HEnd (C i) := fun i => P i
  let Q' : ∀ i, HEnd (C i) := fun i => Q i
  have hPQ : ∀ i, P' i * Q' i = 1 := fun i =>
    (HMap.comp_eq_hEnd_mul (P' i) (Q' i)).symm.trans (congrFun (WreathHom.cls_inj key) i)
  have hQP : ∀ i, Q' i * P' i = 1 := fun i =>
    (HMap.comp_eq_hEnd_mul (Q' i) (P' i)).symm.trans (congrFun (WreathHom.cls_inj key') i)
  exact ⟨fun i => ⟨P' i, Q' i, hPQ i, hQP i⟩, rfl⟩

/-- **The kernel of the action on components.**  A homotopy self-equivalence of `⊔ᵢ Cᵢ`
fixing every component is exactly a family of homotopy self-equivalences of the
components. -/
noncomputable def diagUnitsMulEquivKer :
    (∀ i, (HEnd (C i))ˣ) ≃* (wreathHomUnitsToPerm (C := C)).ker :=
  MulEquiv.ofBijective diagUnits ⟨diagUnits_injective, diagUnits_surjective⟩

/-- **The kernel of the action on components is `∏ᵢ Out(π₁ Cᵢ)`.** -/
noncomputable def kerMulEquivPiOut (hC : ∀ i, ConnectedAt (C i) (c i)) :
    (wreathHomUnitsToPerm (C := C)).ker ≃* ∀ i, OutAut (Aut (c i)) :=
  diagUnitsMulEquivKer.symm.trans
    (MulEquiv.piCongrRight fun i => (outAut_mulEquiv_hEnd_units (hC i)).symm)

end Units

/-! ## The homotopy self-equivalence group of a disjoint union -/

section HAut

open FundamentalGroupPi0 (sigmaGroupoid fst_eq_of_iso sigmaDesc sigmaDesc_full
  sigmaDesc_faithful sigmaDesc_essSurj indexEquivOfEquivalence aut_mulEquiv_of_equivalence)

variable {ι : Type w} {C : ι → Type u} [∀ i, Groupoid.{v} (C i)] {c : ∀ i, C i}

/-- The index map of a matrix is read off from any representative of the corresponding
homotopy class of self-maps of the disjoint union. -/
theorem idx_eq_of_toHEnd (c : ∀ i, C i) (x : WreathHom C) (F : (Σ i, C i) ⥤ Σ i, C i)
    (h : toHEnd x = HEnd.mk _ F) (i : ι) : x.idx i = (F.obj ⟨i, c i⟩).1 := by
  induction x using WreathHom.ind with
  | _ σ P =>
    rw [toHEnd_mk] at h
    obtain ⟨e⟩ := HEnd.mk_eq_mk.1 h
    exact fst_eq_of_iso (e.app ⟨i, c i⟩)

/-- The matrix description of the homotopy self-equivalence group. -/
noncomputable def unitsWreathEquiv (hC : ∀ i, ConnectedAt (C i) (c i)) :
    (HEnd (Σ i, C i))ˣ ≃* (WreathHom C)ˣ :=
  Units.mapEquiv (hEndSigmaMulEquivWreath hC)

/-- **The action of the homotopy self-equivalence group of `⊔ᵢ Cᵢ` on its set of
components.** -/
noncomputable def hAutSigmaToPerm (hC : ∀ i, ConnectedAt (C i) (c i)) :
    (HEnd (Σ i, C i))ˣ →* Equiv.Perm ι :=
  wreathHomUnitsToPerm.comp (unitsWreathEquiv hC).toMonoidHom

/-- The permutation induced by a self-equivalence sends the component `i` to the component
containing the image of the basepoint of `Cᵢ`. -/
theorem hAutSigmaToPerm_apply (hC : ∀ i, ConnectedAt (C i) (c i))
    (u : (HEnd (Σ i, C i))ˣ) (F : (Σ i, C i) ⥤ Σ i, C i)
    (hF : (u : HEnd (Σ i, C i)) = HEnd.mk _ F) (i : ι) :
    hAutSigmaToPerm hC u i = (F.obj ⟨i, c i⟩).1 := by
  refine idx_eq_of_toHEnd c _ F ?_ i
  show (wreathMulEquivHEndSigma hC) ((hEndSigmaMulEquivWreath hC) (u : HEnd (Σ i, C i)))
      = HEnd.mk _ F
  rw [← hF]
  exact (wreathMulEquivHEndSigma hC).apply_symm_apply _

/-- Every homotopy class of self-maps has a representative functor. -/
theorem exists_rep_hEnd {D : Type u} [Category.{v} D] (q : HEnd D) :
    ∃ F : D ⥤ D, q = HEnd.mk D F :=
  (Quotient.exists_rep q).imp fun _ hF => hF.symm

/-- **The image of the action on components.**  A permutation of the set of components is
induced by a homotopy self-equivalence exactly when it preserves the homotopy type of every
component. -/
theorem exists_hAut_perm_iff (hC : ∀ i, ConnectedAt (C i) (c i)) (σ : Equiv.Perm ι) :
    (∃ u : (HEnd (Σ i, C i))ˣ, hAutSigmaToPerm hC u = σ) ↔ ∀ i, Nonempty (C i ≌ C (σ i)) := by
  constructor
  · rintro ⟨u, rfl⟩ i
    obtain ⟨F, hF⟩ := exists_rep_hEnd (u : HEnd (Σ i, C i))
    haveI hFe : F.IsEquivalence := by
      rw [← isUnit_hEnd_mk_iff, ← hF]
      exact u.isUnit
    have hidx : (F.obj ⟨i, c i⟩).1 = hAutSigmaToPerm hC u i :=
      (hAutSigmaToPerm_apply hC u F hF i).symm
    obtain ⟨w⟩ := aut_mulEquiv_of_equivalence c c hC hC F.asEquivalence i
    have w' : Aut (c i) ≃* Aut (c (hAutSigmaToPerm hC u i)) := hidx ▸ w
    exact FundamentalGroupCompleteInvariant.connectedGroupoids_equivalent_of_aut_mulEquiv
      (c i) (c (hAutSigmaToPerm hC u i)) (hC i) (hC _) w'
  · intro h
    have E : ∀ i, C i ≌ C (σ i) := fun i => (h i).some
    haveI : ∀ i, (E i).functor.Full := fun i => inferInstance
    haveI : ∀ i, (E i).functor.Faithful := fun i => inferInstance
    haveI : ∀ i, (E i).functor.EssSurj := fun i => inferInstance
    haveI := sigmaDesc_full σ.injective (fun i => (E i).functor) fun i => inferInstance
    haveI := sigmaDesc_faithful (fun i => (E i).functor) fun i => inferInstance
    haveI := sigmaDesc_essSurj σ.surjective (fun i => (E i).functor) fun i => inferInstance
    have hFe : (sigmaDesc (σ : ι → ι) fun i => (E i).functor).IsEquivalence :=
      ⟨inferInstance, inferInstance, inferInstance⟩
    have hunit : IsUnit (HEnd.mk (Σ i, C i) (sigmaDesc (σ : ι → ι) fun i => (E i).functor)) :=
      (isUnit_hEnd_mk_iff _).2 hFe
    refine ⟨hunit.unit, Equiv.ext fun i => ?_⟩
    rw [hAutSigmaToPerm_apply hC hunit.unit _ hunit.unit_spec.symm i]
    rfl

theorem map_ker_hAutSigmaToPerm (hC : ∀ i, ConnectedAt (C i) (c i)) :
    Subgroup.map (unitsWreathEquiv hC).toMonoidHom (hAutSigmaToPerm hC).ker
      = (wreathHomUnitsToPerm (C := C)).ker := by
  ext u
  constructor
  · rintro ⟨v, hv, rfl⟩
    exact MonoidHom.mem_ker.1 hv
  · intro hu
    refine ⟨(unitsWreathEquiv hC).symm u, MonoidHom.mem_ker.2 ?_,
      (unitsWreathEquiv hC).apply_symm_apply u⟩
    show wreathHomUnitsToPerm ((unitsWreathEquiv hC) ((unitsWreathEquiv hC).symm u)) = 1
    rw [(unitsWreathEquiv hC).apply_symm_apply u]
    exact MonoidHom.mem_ker.1 hu

/-- **Exactness at `hAut`.**  The homotopy self-equivalences of `⊔ᵢ Cᵢ` inducing the
identity permutation of the components are exactly `∏ᵢ Out(π₁ Cᵢ)`. -/
noncomputable def kerHAutSigmaToPermMulEquivPiOut (hC : ∀ i, ConnectedAt (C i) (c i)) :
    (hAutSigmaToPerm hC).ker ≃* ∀ i, OutAut (Aut (c i)) :=
  (((unitsWreathEquiv hC).subgroupMap (hAutSigmaToPerm hC).ker).trans
    (MulEquiv.subgroupCongr (map_ker_hAutSigmaToPerm hC))).trans (kerMulEquivPiOut hC)

/-! ## Rigid families: no two components of the same homotopy type -/

/-- **A disjoint union of pairwise inequivalent connected 1-types.**  If no two distinct
components are homotopy equivalent, no self-equivalence can move a component, so the whole
action on `π₀` is trivial. -/
theorem hAutSigmaToPerm_eq_one_of_pairwise (hC : ∀ i, ConnectedAt (C i) (c i))
    (hne : ∀ i j : ι, Nonempty (C i ≌ C j) → i = j) (u : (HEnd (Σ i, C i))ˣ) :
    hAutSigmaToPerm hC u = 1 := by
  have h := (exists_hAut_perm_iff hC (hAutSigmaToPerm hC u)).1 ⟨u, rfl⟩
  exact Equiv.ext fun i => (hne i _ (h i)).symm

/-- **The homotopy self-equivalence group of a disjoint union of pairwise inequivalent
`K(Gᵢ,1)`s is `∏ᵢ Out(Gᵢ)`** — no relabelling of components is possible. -/
noncomputable def hAutMulEquivPiOut_of_pairwise (hC : ∀ i, ConnectedAt (C i) (c i))
    (hne : ∀ i j : ι, Nonempty (C i ≌ C j) → i = j) :
    (HEnd (Σ i, C i))ˣ ≃* ∀ i, OutAut (Aut (c i)) :=
  Subgroup.topEquiv.symm.trans
    ((MulEquiv.subgroupCongr (show (⊤ : Subgroup ((HEnd (Σ i, C i))ˣ)) = (hAutSigmaToPerm hC).ker by
        ext u
        simpa [MonoidHom.mem_ker] using hAutSigmaToPerm_eq_one_of_pairwise hC hne u)).trans
      (kerHAutSigmaToPermMulEquivPiOut hC))

/-- The number of homotopy classes of self-homotopy-equivalences of a disjoint union of
finitely many pairwise inequivalent `K(Gᵢ,1)`s is `∏ᵢ |Out(Gᵢ)|`. -/
theorem card_hAut_of_pairwise [Fintype ι] (hC : ∀ i, ConnectedAt (C i) (c i))
    (hne : ∀ i j : ι, Nonempty (C i ≌ C j) → i = j) :
    Nat.card ((HEnd (Σ i, C i))ˣ) = ∏ i, Nat.card (OutAut (Aut (c i))) := by
  rw [Nat.card_congr (hAutMulEquivPiOut_of_pairwise hC hne).toEquiv, Nat.card_pi]

end HAut

/-! ## The self-homotopies of the identity -/

section AutId

open FundamentalGroupPi0 (sigmaGroupoid)

variable {ι : Type w} {C : ι → Type u} [∀ i, Groupoid.{v} (C i)] {c : ∀ i, C i}

/-- The self-homotopy of the identity of the `i`-th component induced by a self-homotopy of
the identity of the disjoint union. -/
noncomputable def restrictAutIdSigma (α : Aut (𝟭 (Σ i, C i))) (i : ι) : Aut (𝟭 (C i)) :=
  Functor.fullyFaithfulCancelRight (Sigma.incl i) (Functor.isoWhiskerLeft (Sigma.incl i) α)

@[simp] theorem restrictAutIdSigma_hom_app (α : Aut (𝟭 (Σ i, C i))) (i : ι) (X : C i) :
    (restrictAutIdSigma α i).hom.app X = (Sigma.incl i).preimage (α.hom.app ⟨i, X⟩) := rfl

/-- A family of self-homotopies of the identities of the components assembles into a
self-homotopy of the identity of the disjoint union. -/
def assembleAutIdSigma (β : ∀ i, Aut (𝟭 (C i))) : Aut (𝟭 (Σ i, C i)) :=
  Sigma.natIso fun i => Functor.isoWhiskerRight (β i) (Sigma.incl i)

@[simp] theorem assembleAutIdSigma_hom_app (β : ∀ i, Aut (𝟭 (C i))) (i : ι) (X : C i) :
    (assembleAutIdSigma β).hom.app ⟨i, X⟩ = (Sigma.incl i).map ((β i).hom.app X) := rfl

/-- **The self-homotopies of the identity of `⊔ᵢ Cᵢ` are families of self-homotopies of the
identities of the components.** -/
noncomputable def autIdSigmaMulEquivPi : Aut (𝟭 (Σ i, C i)) ≃* ∀ i, Aut (𝟭 (C i)) where
  toFun := restrictAutIdSigma
  invFun := assembleAutIdSigma
  left_inv α := by
    apply Iso.ext
    ext ⟨i, X⟩
    exact (Sigma.incl i).map_preimage (α.hom.app ⟨i, X⟩)
  right_inv β := by
    funext i
    apply Iso.ext
    ext X
    exact (Sigma.incl i).preimage_map ((β i).hom.app X)
  map_mul' α γ := by
    funext i
    apply Iso.ext
    ext X
    apply (Sigma.incl i).map_injective
    simp [Aut.Aut_mul_def]

/-- **The `π₁` of the automorphism 2-group of an arbitrary 1-type is `∏ᵢ Z(π₁ Cᵢ)`.**
Together with `kerHAutSigmaToPermMulEquivPiOut` and `exists_hAut_perm_iff` (which compute
`π₀`) this determines the whole automorphism 2-group of a disjoint union of arbitrary
connected 1-types. -/
noncomputable def autIdSigmaMulEquivPiCenter (hC : ∀ i, ConnectedAt (C i) (c i)) :
    Aut (𝟭 (Σ i, C i)) ≃* ∀ i, Subgroup.center (Aut (c i)) :=
  autIdSigmaMulEquivPi.trans (MulEquiv.piCongrRight fun i => autId_mulEquiv_center (hC i))

end AutId

end FundamentalGroupHetero
/-
# The monoid of pointed self-maps of a `K(G,1)` is `End G`

`Catalog/Bridges/FundamentalGroupOuterAutomorphisms.lean` upgrades the *unpointed*
classification of self-maps of a connected 1-type to a monoid isomorphism
`HEnd C ≃* ConjEnd (Aut c)` (conjugacy classes of endomorphisms), whose unit group is
`Out G`.  This file does the same for the *pointed* theory of
`Catalog/Geometry/FundamentalGroupPointedMaps.lean`, where no conjugacy classes are needed:

* `PtdMap.comp_assoc`, `PtdMap.id_comp`, `PtdMap.comp_id` — composition of pointed maps is
  associative and unital up to pointed homotopy, so pointed homotopy classes of pointed
  self-maps form a monoid (`ptdEndMonoid`);
* `ptdEndMulEquiv` — **the monoid of pointed self-map classes of `K(G,1)` is `End G`**, the
  full endomorphism monoid of the fundamental group;
* `unitsEndMulEquivMulAut` — the units of `End G` are `Aut G`;
* `ptdAutMulEquiv` — **the pointed self-homotopy-equivalence group of `K(G,1)` is `Aut G`**
  (as a group, upgrading the bijection `ptdAutEquiv`), to be compared with the unpointed
  answer `Out G = Aut G / Inn G`;
* `isUnit_iff_isEquivalence` — a pointed class is invertible in this monoid exactly when it
  is represented by a homotopy equivalence (the monoid form of the pointed Whitehead
  theorem).
-/
import Mathlib
import Geometry.FundamentalGroupPointedFibres

open CategoryTheory
open FundamentalGroupCompleteInvariant (ConnectedAt)
open FundamentalGroupK1

namespace FundamentalGroupPointed

open PtdMap

universe v u v' u' v'' u''

/-! ## Associativity and unitality of composition of pointed maps -/

namespace PtdMap

variable {C : Type u} [Groupoid.{v} C] {c : C} {D : Type u'} [Groupoid.{v'} D] {d : D}
  {E : Type u''} [Groupoid.{v''} E] {e : E}

theorem comp_assoc {F : Type u''} [Groupoid.{v''} F] {f : F}
    (P : PtdMap C c D d) (Q : PtdMap D d E e) (R : PtdMap E e F f) :
    PtdHomotopic ((P.comp Q).comp R) (P.comp (Q.comp R)) := by
  refine ⟨Iso.refl _, ?_⟩
  show 𝟙 _ ≫ ((Q.functor ⋙ R.functor).mapIso P.path ≪≫ R.functor.mapIso Q.path ≪≫ R.path).hom
    = (R.functor.mapIso (Q.functor.mapIso P.path ≪≫ Q.path) ≪≫ R.path).hom
  simp

theorem id_comp (P : PtdMap C c D d) : PtdHomotopic ((PtdMap.id C c).comp P) P := by
  refine ⟨Iso.refl _, ?_⟩
  show 𝟙 _ ≫ P.path.hom = (P.functor.mapIso (Iso.refl c) ≪≫ P.path).hom
  simp

theorem comp_id (P : PtdMap C c D d) : PtdHomotopic (P.comp (PtdMap.id D d)) P := by
  refine ⟨Iso.refl _, ?_⟩
  show 𝟙 _ ≫ P.path.hom = ((𝟭 D).mapIso P.path ≪≫ Iso.refl d).hom
  simp

@[simp] theorem compClasses_mk (P : PtdMap C c D d) (Q : PtdMap D d E e) :
    compClasses (Quotient.mk _ P) (Quotient.mk _ Q) = Quotient.mk _ (P.comp Q) := rfl

end PtdMap

/-! ## The monoid of pointed self-map classes -/

section Monoid

variable {C : Type u} [Groupoid.{v} C] {c : C}

/-- Pointed homotopy classes of pointed self-maps of a 1-type form a monoid under
composition (`x * y` is "first `y`, then `x`"). -/
instance ptdEndMonoid : Monoid (Quotient (ptdSetoid C c C c)) where
  mul x y := compClasses y x
  one := Quotient.mk _ (PtdMap.id C c)
  mul_assoc x y z := by
    induction x using Quotient.ind with
    | _ P =>
      induction y using Quotient.ind with
      | _ Q =>
        induction z using Quotient.ind with
        | _ R => exact Quotient.sound (PtdMap.comp_assoc R Q P).symm
  one_mul x := by
    induction x using Quotient.ind with
    | _ P => exact Quotient.sound (PtdMap.comp_id P)
  mul_one x := by
    induction x using Quotient.ind with
    | _ P => exact Quotient.sound (PtdMap.id_comp P)

theorem ptdEnd_mul_def (x y : Quotient (ptdSetoid C c C c)) : x * y = compClasses y x := rfl

theorem ptdEnd_one_def : (1 : Quotient (ptdSetoid C c C c))
    = Quotient.mk _ (PtdMap.id C c) := rfl

/-- **The monoid of pointed self-maps of a `K(G,1)` is the endomorphism monoid of `G`.**
Compare the unpointed statement `hEndMulEquivConjEnd`, where the answer is the monoid of
*conjugacy classes* of endomorphisms. -/
noncomputable def ptdEndMulEquiv (hC : ConnectedAt C c) :
    Quotient (ptdSetoid C c C c) ≃* Monoid.End (Aut c) where
  toEquiv := ptdClassificationEquiv hC c
  map_mul' x y := by
    induction x using Quotient.ind with
    | _ P =>
      induction y using Quotient.ind with
      | _ Q =>
        show (Q.comp P).ptdHom = _
        exact PtdMap.ptdHom_comp Q P

/-- The units of the endomorphism monoid of a group are its automorphisms. -/
def unitsEndMulEquivMulAut (G : Type*) [Group G] : (Monoid.End G)ˣ ≃* MulAut G where
  toFun u :=
    { toFun := u.val
      invFun := u.inv
      left_inv := fun x => congrArg (fun f : Monoid.End G => f x) u.inv_val
      right_inv := fun x => congrArg (fun f : Monoid.End G => f x) u.val_inv
      map_mul' := fun x y => map_mul u.val x y }
  invFun e :=
    { val := e.toMonoidHom
      inv := e.symm.toMonoidHom
      val_inv := MonoidHom.ext fun x => e.apply_symm_apply x
      inv_val := MonoidHom.ext fun x => e.symm_apply_apply x }
  left_inv _ := Units.ext (MonoidHom.ext fun _ => rfl)
  right_inv _ := MulEquiv.ext fun _ => rfl
  map_mul' _ _ := MulEquiv.ext fun _ => rfl

/-- **The pointed self-homotopy-equivalence group of a `K(G,1)` is `Aut G`.**  This is the
group-level form of `ptdAutEquiv`, and the pointed counterpart of the unpointed theorem
`outAut_mulEquiv_hEnd_units` (`hAut(K(G,1)) ≅ Out G`). -/
noncomputable def ptdAutMulEquiv (hC : ConnectedAt C c) :
    (Quotient (ptdSetoid C c C c))ˣ ≃* MulAut (Aut c) :=
  (Units.mapEquiv (ptdEndMulEquiv hC)).trans (unitsEndMulEquivMulAut (Aut c))

/-- An endomorphism of a group is invertible in the endomorphism monoid exactly when it is
bijective. -/
theorem isUnit_end_iff_bijective {G : Type*} [Group G] (φ : Monoid.End G) :
    IsUnit φ ↔ Function.Bijective φ := by
  constructor
  · rintro ⟨u, rfl⟩
    exact (unitsEndMulEquivMulAut G u).bijective
  · intro h
    let e := MulEquiv.ofBijective (φ : G →* G) h
    exact ⟨(unitsEndMulEquivMulAut G).symm e, MonoidHom.ext fun _ => rfl⟩

/-- **Pointed Whitehead theorem, monoid form.**  A pointed homotopy class of pointed
self-maps of a connected 1-type is invertible in the monoid of pointed classes exactly when
it is represented by a homotopy equivalence. -/
theorem isUnit_iff_isEquivalence (hC : ConnectedAt C c) (P : PtdMap C c C c) :
    IsUnit (Quotient.mk (ptdSetoid C c C c) P) ↔ P.functor.IsEquivalence := by
  rw [isEquivalence_iff_bijective_ptdHom hC P]
  constructor
  · intro h
    have h2 : IsUnit ((ptdEndMulEquiv hC) (Quotient.mk (ptdSetoid C c C c) P)) := h.map _
    exact (isUnit_end_iff_bijective _).1 h2
  · intro h
    have h2 : IsUnit ((ptdEndMulEquiv hC) (Quotient.mk (ptdSetoid C c C c) P)) :=
      (isUnit_end_iff_bijective _).2 h
    simpa using h2.map (ptdEndMulEquiv hC).symm

end Monoid

end FundamentalGroupPointed
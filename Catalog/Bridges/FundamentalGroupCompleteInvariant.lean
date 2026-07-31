/-
# Fundamental groups classify connected homotopy 1-types

A connected groupoid is the algebraic model of a connected homotopy 1-type
(an Eilenberg--MacLane type `K(G,1)`).  This file proves that such a groupoid is
completely classified, up to equivalence, by the automorphism group of one
basepoint.  It also proves a topological counterexample showing why no analogous
classification holds for arbitrary spaces.
-/
import Mathlib
import Mathlib.AlgebraicTopology.FundamentalGroupoid.FundamentalGroup
import Mathlib.AlgebraicTopology.FundamentalGroupoid.InducedMaps

open CategoryTheory
open scoped ContinuousMap

namespace FundamentalGroupCompleteInvariant

universe u v u' v'

/-- A pointed category is connected when every object is isomorphic to the basepoint.
For a fundamental groupoid this is the categorical form of path-connectedness. -/
def ConnectedAt (C : Type u) [Category.{v} C] (c : C) : Prop :=
  ∀ d : C, Nonempty (c ≅ d)

section ConnectedGroupoid

variable {C : Type u} [Groupoid.{v} C] (c : C)

/-- The canonical functor from the one-object category of the basepoint's
fundamental group into a connected groupoid. -/
noncomputable def vertexFunctor : SingleObj (Aut c) ⥤ C :=
  SingleObj.functor (Aut.toEnd c)

/-- The vertex functor is faithful. -/
theorem vertexFunctor_faithful : (vertexFunctor c).Faithful := by
  unfold vertexFunctor
  refine { map_injective := ?_ }
  intro _ _ f g hfg
  -- f g : Aut c, hfg : Aut.toEnd c f = Aut.toEnd c g
  simp only [SingleObj.functor_obj, SingleObj.functor_map] at hfg
  -- Aut c is Iso c c, and we need to show iso equality from hom equality
  exact Iso.ext hfg

/-- The vertex functor is full because every endomorphism in a groupoid is an
isomorphism. -/
theorem vertexFunctor_full : (vertexFunctor c).Full := by
  refine ⟨fun f => ⟨Iso.mk f (inv f) ?_ ?_, ?_⟩⟩
  · simp
  · simp
  · rfl

/-- Connectedness makes the vertex functor essentially surjective. -/
theorem vertexFunctor_essSurj (hC : ConnectedAt C c) :
    (vertexFunctor c).EssSurj := by
  refine ⟨ fun d => ?_ ⟩
  obtain ⟨iso⟩ := hC d
  exact ⟨ (), ⟨iso⟩ ⟩

/-- **Classification of connected groupoids by a vertex group.**
Every connected groupoid is equivalent to the one-object groupoid formed from
the automorphism group of any chosen object. -/
noncomputable def connectedGroupoidEquivSingleObj (hC : ConnectedAt C c) :
    C ≌ SingleObj (Aut c) := by
  letI : (vertexFunctor c).IsEquivalence :=
    { faithful := vertexFunctor_faithful c
      full := vertexFunctor_full c
      essSurj := vertexFunctor_essSurj c hC }
  exact (vertexFunctor c).asEquivalence.symm

end ConnectedGroupoid

/-- **Complete-invariant theorem for connected homotopy 1-types.**
Two connected groupoids whose fundamental groups at chosen basepoints are
isomorphic are equivalent categories.  Under the groupoid model of homotopy
1-types, this is precisely the statement that `K(G,1)` spaces are classified by
`G` up to isomorphism. -/
theorem connectedGroupoids_equivalent_of_aut_mulEquiv
    {C : Type u} [Groupoid.{v} C] {D : Type u'} [Groupoid.{v'} D]
    (c : C) (d : D) (hC : ConnectedAt C c) (hD : ConnectedAt D d)
    (e : Aut c ≃* Aut d) : Nonempty (C ≌ D) := by
  have eq1 : C ≌ SingleObj (Aut c) := connectedGroupoidEquivSingleObj c hC
  have eq2 : D ≌ SingleObj (Aut d) := connectedGroupoidEquivSingleObj d hD
  have eq3 : SingleObj (Aut c) ≌ SingleObj (Aut d) := by
    -- We need to convert the monoid isomorphism to a functor
    -- End of the single object in SingleObj (Aut d) is Aut d
    let X : SingleObj (Aut d) := ()
    have hEnd : End X = Aut d := rfl
    let f : Aut c →* End X := e.toMonoidHom
    let F := SingleObj.functor f
    let Y : SingleObj (Aut c) := ()
    have hEnd' : End Y = Aut c := rfl
    let f' : Aut d →* End Y := e.symm.toMonoidHom
    let G := SingleObj.functor f'
    have hF_faitful : F.Faithful := by
      refine { map_injective := ?_ }
      intro X Y α β hfg
      rw [SingleObj.functor_map] at hfg
      exact e.injective hfg
    have hF_full : F.Full := by
      refine ⟨fun g => ?_⟩
      obtain ⟨a, ha⟩ := e.surjective g
      use a
      simp only [F, SingleObj.functor_map]
      rw [show f a = e a by rfl]
      exact ha
    have hF_essSurj : F.EssSurj := by
      refine ⟨fun X' => ?_⟩
      exact ⟨(), ⟨Iso.refl _⟩⟩
    haveI : F.IsEquivalence := { faithful := hF_faitful, full := hF_full, essSurj := hF_essSurj }
    exact F.asEquivalence
  exact ⟨(eq1.trans eq3).trans eq2.symm⟩

/-- The converse: an equivalence of groupoids identifies automorphism groups at
corresponding basepoints. -/
theorem aut_mulEquiv_of_groupoid_equivalence
    {C : Type u} [Groupoid.{v} C] {D : Type u'} [Groupoid.{v'} D]
    (E : C ≌ D) (c : C) : Nonempty (Aut c ≃* Aut (E.functor.obj c)) := by
  -- Construct bijection via End using asIso
  -- autEquiv : End X ≃* Aut X given by f ↦ asIso f
  let autEquiv (X : C) : End X ≃* Aut X := {
    toFun := fun f => asIso f
    invFun := fun iso => iso.hom
    map_mul' := fun x y => by ext; rfl
    left_inv := by intro f; rfl
    right_inv := by intro iso; ext; rfl
  }
  let autEquiv' (Y : D) : End Y ≃* Aut Y := {
    toFun := fun f => asIso f
    invFun := fun iso => iso.hom
    map_mul' := fun x y => by ext; rfl
    left_inv := by intro f; rfl
    right_inv := by intro iso; ext; rfl
  }
  let f : Aut c →* Aut (E.functor.obj c) := MulEquiv.toMonoidHom (autEquiv' (E.functor.obj c)) |>.comp 
    (MonoidHom.comp (E.functor.mapEnd c) (MulEquiv.toMonoidHom (autEquiv c).symm))
  -- mapEnd c for an equivalence is bijective
  have hmapEnd_bij : Function.Bijective (E.functor.mapEnd c) := by
    haveI : E.functor.FullyFaithful := E.fullyFaithfulFunctor
    refine ⟨fun f g hfg => this.map_injective (by simpa using hfg),
            fun h => this.map_surjective h⟩
  have hf_inj : Function.Injective f := by
    intro x y hxy
    have hxy' : (autEquiv' (E.functor.obj c)) ((E.functor.mapEnd c) ((autEquiv c).symm x)) = 
                (autEquiv' (E.functor.obj c)) ((E.functor.mapEnd c) ((autEquiv c).symm y)) := hxy
    have h1 := (autEquiv' (E.functor.obj c)).injective hxy'
    have h2 := hmapEnd_bij.1 h1
    exact (autEquiv c).symm.injective h2
  have hf_surj : Function.Surjective f := by
    intro b
    obtain ⟨e', he'⟩ := (autEquiv' (E.functor.obj c)).surjective b
    obtain ⟨e, he⟩ := hmapEnd_bij.2 e'
    obtain ⟨a, ha⟩ := (autEquiv c).symm.surjective e
    refine ⟨a, ?_⟩
    simp [f, ha, he, he']
  exact ⟨(MulEquiv.ofBijective f ⟨hf_inj, hf_surj⟩)⟩

section TopologicalConsequences

variable {X Y : Type*} [TopologicalSpace X] [TopologicalSpace Y]

/-- Homotopy equivalence always preserves the fundamental group.  Thus the
fundamental group is an invariant, though not generally a complete invariant. -/
theorem fundamentalGroup_invariant (e : X ≃ₕ Y) (x : X) :
    Nonempty (FundamentalGroup X x ≃* FundamentalGroup Y (e x)) := by
  let eq : FundamentalGroupoid.fundamentalGroupoidFunctor.obj ⟨X⟩ ≌
            FundamentalGroupoid.fundamentalGroupoidFunctor.obj ⟨Y⟩ :=
    FundamentalGroupoidFunctor.equivOfHomotopyEquiv e
  -- Use the fully faithful functor approach like in DiscreteCubicalHomotopy.Bridge
  have iso := (eq.fullyFaithfulFunctor).autMulEquivOfFullyFaithful ⟨x⟩
  simp only [FundamentalGroup] at *
  -- End and Aut should be the same for groupoids
  unfold FundamentalGroup at *
  -- FundamentalGroup is defined as End, not Aut
  -- For groupoids, there should be a MulEquiv between Aut and End
  -- Let's check if it exists in Mathlib
  let p : FundamentalGroupoid.fundamentalGroupoidFunctor.obj ⟨X⟩ := ⟨x⟩
  -- Construct MulEquiv between Aut p and End p for groupoids
  have ae : Aut p ≃* End p := {
    toFun := fun f => f.hom
    invFun := fun g => ⟨g, inv g, by simp, by simp⟩
    left_inv := by intros a; exact Iso.ext (by simp)
    right_inv := fun g => rfl
    map_mul' := fun f g => rfl
  }
  -- Convert iso from Aut to End using ae
  have key2 : eq.functor.obj p = ⟨e x⟩ := rfl
  -- Compose: End p ≃ Aut p ≃ Aut (eq.functor.obj p) ≃ End (eq.functor.obj p) ≃ End ⟨e x⟩
  refine ⟨ae.symm.trans (iso.trans ?_)⟩
  -- Need: Aut (eq.functor.obj p) ≃* End ⟨e x⟩
  -- Get ae at the target object
  let ae' : Aut (eq.functor.obj p) ≃* End (eq.functor.obj p) := {
    toFun := fun f => f.hom
    invFun := fun g => ⟨g, inv g, by simp, by simp⟩
    left_inv := by intros a; exact Iso.ext (by simp)
    right_inv := fun g => rfl
    map_mul' := fun f g => rfl
  }
  exact ae'.trans (by rw [key2]; rfl)

/-- A homotopy between maps into a totally disconnected space forces the maps
to be equal. -/
theorem homotopic_eq_of_totallyDisconnected [TotallyDisconnectedSpace Y]
    {f g : C(X, Y)} (h : f.Homotopic g) : f = g := by
  obtain ⟨H⟩ := h
  ext x
  have hx : H (0, x) = H (1, x) :=
    TotallyDisconnectedSpace.eq_of_continuous (fun t : Set.Icc (0 : ℝ) 1 => H (t, x))
      (by fun_prop) 0 1
  simpa using hx

/-- A homotopy equivalence between totally disconnected spaces is an actual
bijection on their underlying point sets. -/
theorem homotopyEquiv_bijective_of_totallyDisconnected
    [TotallyDisconnectedSpace X] [TotallyDisconnectedSpace Y]
    (e : X ≃ₕ Y) : Function.Bijective e := by
  -- left_inv and right_inv are homotopies
  have h1 : ⇑e.toFun ∘ ⇑e.invFun = ⇑(ContinuousMap.id Y) := by
    have := homotopic_eq_of_totallyDisconnected e.right_inv
    ext y
    exact ContinuousMap.ext_iff.mp this y
  have h2 : ⇑e.invFun ∘ ⇑e.toFun = ⇑(ContinuousMap.id X) := by
    have := homotopic_eq_of_totallyDisconnected e.left_inv
    ext x
    exact ContinuousMap.ext_iff.mp this x
  -- e.toFun is bijective since it has a two-sided inverse
  refine ⟨?_, ?_⟩
  · -- injective
    intro a b hab
    have ha : a = e.invFun (e.toFun a) := (congrFun h2 a).symm
    have hb : b = e.invFun (e.toFun b) := (congrFun h2 b).symm
    rw [ha, hb, hab]
  · -- surjective
    intro y
    use e.invFun y
    specialize h1
    replace h1 : e.toFun (e.invFun y) = y := by
      simpa using congrFun h1 y
    exact h1

/-- The fundamental group at the unique point of `Unit` is trivial. -/
theorem unit_fundamentalGroup_subsingleton :
    Subsingleton (FundamentalGroup Unit ()) := by
  change Subsingleton (Path.Homotopic.Quotient () ())
  exact (simply_connected_iff_paths_homotopic.mp
    (inferInstance : SimplyConnectedSpace Unit)).2 () ()

/-- Every based fundamental group of the discrete two-point space is trivial. -/
theorem bool_fundamentalGroup_subsingleton (b : Bool) :
    Subsingleton (FundamentalGroup Bool b) := by
  rw [FundamentalGroup]
  rw [End]
  -- Let X be the object in the fundamental groupoid with X.as = b
  set X : FundamentalGroupoid Bool := ⟨b⟩ with hX
  -- Hom type is a quotient of Path X.as X.as
  -- All paths in Bool are constant, so the quotient is trivial
  have heq : (X ⟶ X) = _root_.Quotient (Path.Homotopic.setoid X.as X.as) := rfl
  rw [heq]
  rw [Quotient.subsingleton_iff]
  -- Need to show that Path.Homotopic.setoid is trivial
  -- i.e., any two paths from b to b are homotopic
  ext p q
  -- Need to show Path.Homotopic p q (since ⊤ p q is always true)
  constructor
  · intro _; trivial
  · intro _
    -- Show that p = q (since any continuous map [0,1] → Bool is constant)
    have hpq : p = q := by
      -- Any continuous map [0,1] → Bool is constant
      -- So p and q are both constant at b
      ext t
      -- p t = p 0 since p is continuous and Bool is totally disconnected
      have hp_const : ∀ t, p t = p 0 := by
        intro t
        exact TotallyDisconnectedSpace.eq_of_continuous (fun s : Set.Icc (0:ℝ) 1 => p s) (by fun_prop) t 0
      have hq_const : ∀ t, q t = q 0 := by
        intro t
        exact TotallyDisconnectedSpace.eq_of_continuous (fun s : Set.Icc (0:ℝ) 1 => q s) (by fun_prop) t 0
      rw [hp_const, hq_const]
      -- p 0 = source of p = b and q 0 = source of q = b
      simp
    rw [hpq]

/-- Unit and the discrete two-point space have isomorphic fundamental groups at
chosen basepoints, since both groups are trivial. -/
theorem unit_bool_fundamentalGroups_equiv :
    Nonempty (FundamentalGroup Unit () ≃* FundamentalGroup Bool false) := by
  letI := unit_fundamentalGroup_subsingleton
  letI := bool_fundamentalGroup_subsingleton false
  let f : FundamentalGroup Unit () →* FundamentalGroup Bool false := 1
  refine ⟨MulEquiv.ofBijective f ⟨?_, ?_⟩⟩
  · intro a b _
    exact Subsingleton.elim a b
  · intro b
    exact ⟨1, Subsingleton.elim _ b⟩

/-- **Counterexample to classification by the fundamental group.**
`Unit` and discrete `Bool` have the same (trivial) fundamental group but are not
homotopy equivalent: on totally disconnected spaces a homotopy equivalence must
already be a bijection, and no bijection exists between one and two points. -/
theorem same_fundamentalGroup_not_homotopyEquivalent :
    Nonempty (FundamentalGroup Unit () ≃* FundamentalGroup Bool false) ∧
      ¬ Nonempty (Unit ≃ₕ Bool) := by
  refine ⟨unit_bool_fundamentalGroups_equiv, ?_⟩
  rintro ⟨e⟩
  have hb := homotopyEquiv_bijective_of_totallyDisconnected e
  rcases Bool.eq_false_or_eq_true (e ()) with htrue | hfalse
  · obtain ⟨u, hu⟩ := hb.2 false
    simp [htrue] at hu
  · obtain ⟨u, hu⟩ := hb.2 true
    simp [hfalse] at hu

end TopologicalConsequences

end FundamentalGroupCompleteInvariant
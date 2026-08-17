/-
# Coverings of a `K(G,1)` and the Galois correspondence

The catalog already contains a complete classification of connected homotopy
`1`-types (models of `K(G,1)` spaces) by their fundamental group:
`Bridges/FundamentalGroupCompleteInvariant.lean` and
`Bridges/FundamentalGroupK1Classification.lean`.

This file develops the *covering space theory* of these objects, entirely inside
the groupoid model.  A covering of the `1`-type `K(G,1)` is an action groupoid
`ActionCategory G X` of a `G`-set `X` (Mathlib's `CategoryTheory.ActionCategory`);
the covering projection is the canonical functor to `SingleObj G`.  The results
proved here are:

* `connectedAt_actionCategory` / `isPretransitive_of_connectedAt`: the covering is
  connected exactly when the monodromy action on the fibre is transitive;
* `autMulEquivStabilizer`: the fundamental group of the covering at a point of the
  fibre is the stabiliser subgroup — so a connected covering of a `K(G,1)` is a
  `K(H,1)` for a subgroup `H ≤ G` (`actionCategory_equivalent_singleObj_stabilizer`);
* `card_eq_index_stabilizer`: the number of sheets is the index of that subgroup;
* `nonempty_gEquiv_iff_isConj`: **the Galois correspondence** — two connected
  coverings are isomorphic exactly when the associated subgroups are conjugate;
* `nonempty_gHom_iff_le_conj`: covering morphisms correspond to subconjugacy;
* `pi_injective`: the fundamental group of a covering injects into that of the base
  with image the associated subgroup.
-/
import Mathlib
import Bridges.FundamentalGroupCompleteInvariant
import Bridges.FundamentalGroupK1Classification
import Bridges.FundamentalGroupOuterAutomorphisms

open CategoryTheory MulAction
open FundamentalGroupCompleteInvariant (ConnectedAt)
open FundamentalGroupK1 (autMulEquivEnd)

namespace FundamentalGroupCovering

universe u

variable {G : Type u} [Group G] {X Y Z : Type u} [MulAction G X] [MulAction G Y] [MulAction G Z]

/-! ## Connectivity of the covering versus transitivity of the monodromy -/

section Connected

/-- The morphism of the action groupoid attached to a group element moving one point
of the fibre to another. -/
def homOfSmul {x y : X} (g : G) (h : g • x = y) :
    (ActionCategory.objEquiv G X x) ⟶ (ActionCategory.objEquiv G X y) :=
  ⟨g, h⟩

/-- Points of the fibre in the same orbit become isomorphic objects of the covering. -/
def isoOfSmul {x y : X} (g : G) (h : g • x = y) :
    (ActionCategory.objEquiv G X x) ≅ (ActionCategory.objEquiv G X y) :=
  Groupoid.isoEquivHom _ _ |>.symm (homOfSmul g h)

/-- **A covering is connected iff its monodromy action is transitive.** (First half.) -/
theorem connectedAt_actionCategory [IsPretransitive G X] (x : X) :
    ConnectedAt (ActionCategory G X) (ActionCategory.objEquiv G X x) := by
  intro d
  obtain ⟨g, hg⟩ := IsPretransitive.exists_smul_eq (M := G) x d.back
  exact ⟨(Groupoid.isoEquivHom _ _).symm ⟨g, by simpa using hg⟩⟩

/-- **A covering is connected iff its monodromy action is transitive.** (Second half.) -/
theorem isPretransitive_of_connectedAt (x : X)
    (h : ConnectedAt (ActionCategory G X) (ActionCategory.objEquiv G X x)) :
    IsPretransitive G X := by
  refine ⟨fun a b => ?_⟩
  obtain ⟨e⟩ := h (ActionCategory.objEquiv G X a)
  obtain ⟨f⟩ := h (ActionCategory.objEquiv G X b)
  exact ⟨f.hom.val * e.inv.val, by
    have h1 : e.inv.val • a = x := e.inv.property
    have h2 : f.hom.val • x = b := f.hom.property
    rw [mul_smul, h1, h2]⟩

end Connected

/-! ## The fundamental group of a covering is a stabiliser subgroup -/

section VertexGroup

/-- The stabiliser subgroup and the stabiliser submonoid of a point agree. -/
def stabilizerMulEquivSubmonoid (x : X) :
    stabilizer G x ≃* stabilizerSubmonoid G x where
  toFun a := ⟨a.1, a.2⟩
  invFun a := ⟨a.1, a.2⟩
  left_inv _ := rfl
  right_inv _ := rfl
  map_mul' _ _ := rfl

/-- **The fundamental group of a covering at a point of the fibre is the stabiliser.** -/
def autMulEquivStabilizer (x : X) :
    Aut (ActionCategory.objEquiv G X x) ≃* stabilizer G x :=
  (autMulEquivEnd _).trans
    ((ActionCategory.stabilizerIsoEnd G x).symm.trans (stabilizerMulEquivSubmonoid x).symm)

/-- **A connected covering of a `K(G,1)` is a `K(H,1)`.** -/
theorem actionCategory_equivalent_singleObj_stabilizer [IsPretransitive G X] (x : X) :
    Nonempty (ActionCategory G X ≌ SingleObj (stabilizer G x)) :=
  FundamentalGroupCompleteInvariant.connectedGroupoids_equivalent_of_aut_mulEquiv
    (ActionCategory.objEquiv G X x) (SingleObj.star (stabilizer G x))
    (connectedAt_actionCategory x) (FundamentalGroupOut.singleObj_connected _)
    ((autMulEquivStabilizer x).trans (FundamentalGroupOut.singleObjAut _).symm)

end VertexGroup

/-! ## The number of sheets -/

section Degree

/-- **The number of sheets of a connected covering is the index of its subgroup.** -/
theorem card_eq_index_stabilizer [IsPretransitive G X] (x : X) :
    Nat.card X = (stabilizer G x).index :=
  (index_stabilizer_of_transitive G x).symm

end Degree

/-! ## Equivariant maps between coverings -/

section Maps

/-- An equivariant map of `G`-sets: a morphism of coverings. -/
structure GHom (G : Type u) [Group G] (X Y : Type u) [MulAction G X] [MulAction G Y] where
  toFun : X → Y
  map_smul' : ∀ (g : G) (x : X), toFun (g • x) = g • toFun x

/-- An equivariant bijection of `G`-sets: an isomorphism of coverings. -/
structure GEquiv (G : Type u) [Group G] (X Y : Type u) [MulAction G X] [MulAction G Y] where
  toEquiv : X ≃ Y
  map_smul' : ∀ (g : G) (x : X), toEquiv (g • x) = g • toEquiv x

/-- The underlying morphism of coverings of an isomorphism of coverings. -/
def GEquiv.toGHom (e : GEquiv G X Y) : GHom G X Y :=
  ⟨e.toEquiv, e.map_smul'⟩

/-- The identity isomorphism of coverings. -/
def GEquiv.refl (G : Type u) [Group G] (X : Type u) [MulAction G X] : GEquiv G X X :=
  ⟨Equiv.refl X, fun _ _ => rfl⟩

/-- The inverse of an isomorphism of coverings. -/
def GEquiv.symm (e : GEquiv G X Y) : GEquiv G Y X :=
  ⟨e.toEquiv.symm, by
    intro g y
    apply e.toEquiv.injective
    rw [Equiv.apply_symm_apply, e.map_smul', Equiv.apply_symm_apply]⟩

/-- An equivariant bijection assembled from two mutually inverse equivariant maps. -/
def gEquivOfInverse (f : GHom G X Y) (f' : GHom G Y X)
    (h₁ : ∀ u, f'.toFun (f.toFun u) = u) (h₂ : ∀ v, f.toFun (f'.toFun v) = v) :
    GEquiv G X Y :=
  ⟨⟨f.toFun, f'.toFun, h₁, h₂⟩, f.map_smul'⟩

/-- Composition of isomorphisms of coverings. -/
def GEquiv.trans (e : GEquiv G X Y) (f : GEquiv G Y Z) : GEquiv G X Z :=
  ⟨e.toEquiv.trans f.toEquiv, by
    intro g x
    simp [e.map_smul', f.map_smul']⟩

/-- Equivariant maps do not decrease stabilisers. -/
theorem stabilizer_le_of_gHom (f : GHom G X Y) (x : X) :
    stabilizer G x ≤ stabilizer G (f.toFun x) := by
  intro a ha
  rw [mem_stabilizer_iff] at ha ⊢
  rw [← f.map_smul', ha]

/-- Isomorphisms of coverings preserve stabilisers exactly. -/
theorem stabilizer_eq_of_gEquiv (e : GEquiv G X Y) (x : X) :
    stabilizer G (e.toEquiv x) = stabilizer G x := by
  refine le_antisymm ?_ (stabilizer_le_of_gHom e.toGHom x)
  have := stabilizer_le_of_gHom e.symm.toGHom (e.toEquiv x)
  simpa [GEquiv.symm, GEquiv.toGHom] using this

/-- If the stabiliser of `x₀` is contained in that of `y₀`, then group elements agreeing
on `x₀` also agree on `y₀`. -/
theorem smul_eq_of_smul_eq {x₀ : X} {y₀ : Y} (h : stabilizer G x₀ ≤ stabilizer G y₀)
    {a b : G} (hab : a • x₀ = b • x₀) : a • y₀ = b • y₀ := by
  have hmem : b⁻¹ * a ∈ stabilizer G x₀ := by
    rw [mem_stabilizer_iff, mul_smul, hab, ← mul_smul, inv_mul_cancel, one_smul]
  have := h hmem
  rw [mem_stabilizer_iff, mul_smul] at this
  calc a • y₀ = b • (b⁻¹ • (a • y₀)) := by rw [smul_inv_smul]
    _ = b • y₀ := by rw [this]

/-- The canonical equivariant map determined by a choice of points in the two fibres,
defined when the stabiliser of the source basepoint is contained in that of the target. -/
noncomputable def transitiveMap [IsPretransitive G X] (x₀ : X) (y₀ : Y)
    (h : stabilizer G x₀ ≤ stabilizer G y₀) : GHom G X Y where
  toFun u := (IsPretransitive.exists_smul_eq (M := G) x₀ u).choose • y₀
  map_smul' g u := by
    set a := (IsPretransitive.exists_smul_eq (M := G) x₀ u).choose with ha
    have hau : a • x₀ = u := (IsPretransitive.exists_smul_eq (M := G) x₀ u).choose_spec
    set c := (IsPretransitive.exists_smul_eq (M := G) x₀ (g • u)).choose with hc
    have hcu : c • x₀ = g • u := (IsPretransitive.exists_smul_eq (M := G) x₀ (g • u)).choose_spec
    have : c • x₀ = (g * a) • x₀ := by rw [hcu, mul_smul, hau]
    have := smul_eq_of_smul_eq h this
    rw [this, mul_smul]

theorem transitiveMap_base [IsPretransitive G X] (x₀ : X) (y₀ : Y)
    (h : stabilizer G x₀ ≤ stabilizer G y₀) (g : G) :
    (transitiveMap x₀ y₀ h).toFun (g • x₀) = g • y₀ := by
  show (IsPretransitive.exists_smul_eq (M := G) x₀ (g • x₀)).choose • y₀ = g • y₀
  exact smul_eq_of_smul_eq h
    (IsPretransitive.exists_smul_eq (M := G) x₀ (g • x₀)).choose_spec

end Maps

/-! ## The Galois correspondence -/

section Galois

/-- **Covering morphisms exist exactly in the presence of a subconjugacy relation.** -/
theorem nonempty_gHom_iff_le_conj [IsPretransitive G X] [IsPretransitive G Y]
    (x : X) (y : Y) :
    Nonempty (GHom G X Y) ↔
      ∃ g : G, stabilizer G x ≤ (stabilizer G y).map (MulAut.conj g).toMonoidHom := by
  constructor
  · rintro ⟨f⟩
    obtain ⟨g, hg⟩ := IsPretransitive.exists_smul_eq (M := G) y (f.toFun x)
    refine ⟨g, ?_⟩
    rw [← stabilizer_smul_eq_stabilizer_map_conj, hg]
    exact stabilizer_le_of_gHom f x
  · rintro ⟨g, hg⟩
    rw [← stabilizer_smul_eq_stabilizer_map_conj] at hg
    exact ⟨transitiveMap x (g • y) hg⟩

/-- **The Galois correspondence for coverings of a `K(G,1)`.**  Two connected coverings
are isomorphic exactly when their subgroups are conjugate in `G`. -/
theorem nonempty_gEquiv_iff_isConj [IsPretransitive G X] [IsPretransitive G Y]
    (x : X) (y : Y) :
    Nonempty (GEquiv G X Y) ↔
      ∃ g : G, stabilizer G y = (stabilizer G x).map (MulAut.conj g).toMonoidHom := by
  constructor
  · rintro ⟨e⟩
    obtain ⟨g, hg⟩ := IsPretransitive.exists_smul_eq (M := G) (e.toEquiv x) y
    refine ⟨g, ?_⟩
    rw [← stabilizer_eq_of_gEquiv e x, ← stabilizer_smul_eq_stabilizer_map_conj, hg]
  · rintro ⟨g, hg⟩
    rw [← stabilizer_smul_eq_stabilizer_map_conj] at hg
    have hle : stabilizer G (g • x) ≤ stabilizer G y := hg.ge
    have hle' : stabilizer G y ≤ stabilizer G (g • x) := hg.le
    refine ⟨gEquivOfInverse (transitiveMap (g • x) y hle) (transitiveMap y (g • x) hle') ?_ ?_⟩
    · intro u
      obtain ⟨a, ha⟩ := IsPretransitive.exists_smul_eq (M := G) (g • x) u
      rw [← ha, transitiveMap_base, transitiveMap_base]
    · intro v
      obtain ⟨a, ha⟩ := IsPretransitive.exists_smul_eq (M := G) y v
      rw [← ha, transitiveMap_base, transitiveMap_base]

/-- **The pointed classification: conjugacy enters exactly through the basepoint.**
Two connected coverings are isomorphic by an isomorphism matching chosen points of the
fibres exactly when the two subgroups are *equal* (not merely conjugate). -/
theorem exists_pointed_gEquiv_iff_stabilizer_eq [IsPretransitive G X] [IsPretransitive G Y]
    (x : X) (y : Y) :
    (∃ e : GEquiv G X Y, e.toEquiv x = y) ↔ stabilizer G x = stabilizer G y := by
  constructor
  · rintro ⟨e, he⟩
    rw [← stabilizer_eq_of_gEquiv e x, he]
  · intro hst
    have hle : stabilizer G x ≤ stabilizer G y := hst.le
    have hle' : stabilizer G y ≤ stabilizer G x := hst.ge
    have hinv₁ : ∀ u, (transitiveMap y x hle').toFun ((transitiveMap x y hle).toFun u) = u := by
      intro u
      obtain ⟨a, ha⟩ := IsPretransitive.exists_smul_eq (M := G) x u
      rw [← ha, transitiveMap_base, transitiveMap_base]
    have hinv₂ : ∀ v, (transitiveMap x y hle).toFun ((transitiveMap y x hle').toFun v) = v := by
      intro v
      obtain ⟨a, ha⟩ := IsPretransitive.exists_smul_eq (M := G) y v
      rw [← ha, transitiveMap_base, transitiveMap_base]
    refine ⟨gEquivOfInverse (transitiveMap x y hle) (transitiveMap y x hle') hinv₁ hinv₂, ?_⟩
    show (transitiveMap x y hle).toFun x = y
    have h1 : (transitiveMap x y hle).toFun ((1 : G) • x) = (1 : G) • y :=
      transitiveMap_base x y hle 1
    rwa [one_smul, one_smul] at h1

end Galois

/-! ## The covering projection on fundamental groups -/

section Projection

/-- The homomorphism of fundamental groups induced by the covering projection,
under the identifications of both sides with concrete groups. -/
theorem pi_injective (x : X) :
    Function.Injective
      (fun a : Aut (ActionCategory.objEquiv G X x) => ((autMulEquivStabilizer x) a : G)) :=
  fun _ _ h => (autMulEquivStabilizer x).injective (Subtype.ext h)

/-- The image of the fundamental group of the covering is exactly the stabiliser. -/
theorem pi_range (x : X) :
    Set.range (fun a : Aut (ActionCategory.objEquiv G X x) =>
      ((autMulEquivStabilizer x) a : G)) = (stabilizer G x : Set G) := by
  ext g
  constructor
  · rintro ⟨a, rfl⟩
    exact ((autMulEquivStabilizer x) a).2
  · intro hg
    obtain ⟨a, ha⟩ := (autMulEquivStabilizer x).surjective ⟨g, hg⟩
    exact ⟨a, by simp only [ha]⟩

end Projection

end FundamentalGroupCovering
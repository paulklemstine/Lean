/-
# The homotopy self-equivalence group of a disjoint union of copies of a `K(G,1)`

`Catalog/Bridges/FundamentalGroupOuterAutomorphisms.lean` computes the group of homotopy
classes of self-homotopy-equivalences of a **connected** 1-type: it is `Out G`.
`Catalog/Bridges/FundamentalGroupSelfEquivalencesPi0.lean` computes it for a **totally
disconnected** 1-type: it is `Sym(π₀)`.  This file settles the conjectured common
generalisation (item 1 of `FUTURE_DIRECTIONS.md`) for a disjoint union of `ι` copies of a
fixed `K(G,1)`:

  `hAut (⊔_{i ∈ ι} K(G,1)) ≅ Out(G) ≀ Sym(ι) = (ι → Out G) ⋊ Sym(ι)`.

The disjoint union of `ι` copies of a groupoid `D` is modelled as the product category
`Discrete ι × D`; `sigmaEquivProd` identifies this with the coproduct `Σ _ : ι, D` used in
`FundamentalGroupPi0Gluing.lean`, and `componentsProdEquiv` identifies its `π₀` with `ι`.

The proof proceeds through a *monoid* statement, which is of independent interest since it
classifies **all** self-maps, not just the equivalences:

* `WreathEnd ι M` : the wreath monoid `(ι → M) × Function.End ι` with multiplication
  `(P, σ) * (Q, τ) = (fun i => P (τ i) * Q i, σ ∘ τ)`;
* `hEndMulEquivWreathEnd` : `[⊔_ι D, ⊔_ι D] ≅ WreathEnd ι [D,D]` — a homotopy class of
  self-maps of the disjoint union is exactly a self-map `σ` of the index set together with,
  for each `i`, a homotopy class of maps `D → D` (the piece landing in the component `σ i`);
* `wreathEndUnitsMulEquivSemidirect` : the units of `WreathEnd ι M` form the semidirect
  product `(ι → Mˣ) ⋊ Sym(ι)`;
* `hAutMulEquivWreathOut` : **the main theorem**,
  `hAut(⊔_ι K(G,1)) ≅ (ι → Out G) ⋊ Sym ι`.

Complementing the main theorem:

* `componentsProdEquiv` : `π₀(⊔_ι D) = ι`, and `hAutToPermCopies_eq_pi0Action` : the
  projection of the wreath product onto `Sym(ι)` is exactly the action of `hAut` on `π₀`
  constructed in `FundamentalGroupPi0Action.lean`;
* `hAutToPermCopies_surjective`, `ker_hAutToPermCopies`, `hAutToPermCopies_split` : the
  extension `1 → ∏_ι Out G → hAut(⊔_ι K(G,1)) → Sym(ι) → 1` is exact and split;
* `hEndCongr` : the monoid of homotopy classes of self-maps is invariant under equivalence
  of 1-types, and `sigmaEquivProdModel` identifies the product model with the coproduct;
* `autIdProdMulEquivPiCenter` : the self-homotopies of the identity of `⊔_ι K(G,1)` form
  `∏_ι Z(G)`, so the whole automorphism 2-group is computed
  (`π₀ = Out(G) ≀ Sym(ι)`, `π₁ = ∏_ι Z(G)`).

Corollaries: the two extreme cases (`ι` a point, `G` trivial) are recovered, and the
order of `hAut(⊔_{Fin n} K(G,1))` is `|Out G| ^ n * n !`.
-/
import Mathlib
import Bridges.FundamentalGroupOuterAutomorphisms
import Bridges.FundamentalGroupPi0Gluing
import Bridges.FundamentalGroupPi0Action
open CategoryTheory
open FundamentalGroupCompleteInvariant (ConnectedAt)
open FundamentalGroupOut

namespace FundamentalGroupWreath

universe w v v' u u'

/-! ## The model of a disjoint union of copies of a groupoid -/

section Model

variable {ι : Type w} {D : Type u} [Category.{v} D]

/-- The inclusion of the `i`-th copy of `D` into the disjoint union `Discrete ι × D`. -/
def incl (i : ι) : D ⥤ Discrete ι × D := Functor.prod' ((Functor.const D).obj ⟨i⟩) (𝟭 D)

@[simp] theorem incl_obj (i : ι) (X : D) : (incl i).obj X = (⟨i⟩, X) := rfl

@[simp] theorem incl_map (i : ι) {X Y : D} (f : X ⟶ Y) :
    (incl (D := D) i).map f = (𝟙 _, f) := rfl

theorem incl_comp_snd (i : ι) : incl i ⋙ CategoryTheory.Prod.snd (Discrete ι) D = 𝟭 D := rfl

/-- Two functors out of a disjoint union agree if they agree on each copy. -/
def natIsoOfIncl {E : Type u'} [Category.{v'} E] {F G : Discrete ι × D ⥤ E}
    (h : ∀ i, incl i ⋙ F ≅ incl i ⋙ G) : F ≅ G :=
  NatIso.ofComponents (fun p => (h p.1.as).app p.2) (by
    rintro ⟨⟨a⟩, X⟩ ⟨⟨b⟩, Y⟩ ⟨u, f⟩
    obtain rfl : a = b := Discrete.eq_of_hom u
    obtain rfl : u = 𝟙 _ := Subsingleton.elim _ _
    exact (h a).hom.naturality f)

/-- The self-map of the disjoint union assembled from a self-map `σ` of the index set and a
family `P` of functors, the `i`-th one being viewed as a map from the `i`-th copy to the
`σ i`-th copy. -/
def wreathFunctor (σ : ι → ι) (P : ι → (D ⥤ D)) : Discrete ι × D ⥤ Discrete ι × D :=
  Functor.uncurry.obj (Discrete.functor fun i => P i ⋙ incl (σ i))

@[simp] theorem wreathFunctor_obj (σ : ι → ι) (P : ι → (D ⥤ D)) (i : ι) (X : D) :
    (wreathFunctor σ P).obj (⟨i⟩, X) = (⟨σ i⟩, (P i).obj X) := rfl

/-- The `i`-th copy is sent by `wreathFunctor σ P` into the `σ i`-th copy via `P i`. -/
def inclCompWreathFunctor (σ : ι → ι) (P : ι → (D ⥤ D)) (i : ι) :
    incl i ⋙ wreathFunctor σ P ≅ P i ⋙ incl (σ i) :=
  NatIso.ofComponents (fun _ => Iso.refl _)
    (by intros; simp [wreathFunctor, incl, Functor.uncurry])

end Model

/-! ## The index map and the pieces of a self-map -/

section Pieces

variable {ι : Type w} {D : Type u} [Category.{v} D] {d : D}

/-- The self-map of `π₀ = ι` induced by a self-map of the disjoint union. -/
def slice (d : D) (F : Discrete ι × D ⥤ Discrete ι × D) (i : ι) : ι :=
  (F.obj (⟨i⟩, d)).1.as

/-- The `i`-th piece of a self-map of the disjoint union: the composite
`D → i-th copy → ⊔ᵢ D → D`. -/
def piece (F : Discrete ι × D ⥤ Discrete ι × D) (i : ι) : D ⥤ D :=
  incl i ⋙ F ⋙ CategoryTheory.Prod.snd (Discrete ι) D

/-- On a connected `D`, the copy in which the image of the `i`-th copy lands does not
depend on the chosen object. -/
theorem fst_obj_eq_slice (hD : ConnectedAt D d) (F : Discrete ι × D ⥤ Discrete ι × D)
    (i : ι) (X : D) : (F.obj (⟨i⟩, X)).1.as = slice d F i := by
  obtain ⟨e⟩ := hD X
  exact (Discrete.eq_of_hom (F.mapIso (Iso.prod (Iso.refl (⟨i⟩ : Discrete ι)) e)).hom.1).symm

/-- **Reconstruction of a self-map from its index map and its pieces.** -/
def inclCompSelf (hD : ConnectedAt D d) (F : Discrete ι × D ⥤ Discrete ι × D) (i : ι) :
    incl i ⋙ F ≅ piece F i ⋙ incl (slice d F i) :=
  NatIso.ofComponents
    (fun X => Iso.prod (Discrete.eqToIso (fst_obj_eq_slice hD F i X)) (Iso.refl _))
    (by
      intro X Y f
      apply Prod.ext
      · apply Subsingleton.elim
      · simp [piece, incl])

/-- Every self-map of the disjoint union is homotopic to the one assembled from its index
map and its pieces. -/
def selfNatIsoWreathFunctor (hD : ConnectedAt D d) (F : Discrete ι × D ⥤ Discrete ι × D) :
    F ≅ wreathFunctor (slice d F) (piece F) :=
  natIsoOfIncl fun i =>
    (inclCompSelf hD F i).trans (inclCompWreathFunctor (slice d F) (piece F) i).symm

@[simp] theorem slice_wreathFunctor (σ : ι → ι) (P : ι → (D ⥤ D)) (i : ι) :
    slice d (wreathFunctor σ P) i = σ i := rfl

/-- The pieces of an assembled self-map are the given functors. -/
def pieceWreathFunctor (σ : ι → ι) (P : ι → (D ⥤ D)) (i : ι) :
    piece (wreathFunctor σ P) i ≅ P i :=
  (Functor.isoWhiskerRight (inclCompWreathFunctor σ P i)
    (CategoryTheory.Prod.snd (Discrete ι) D)).trans (Iso.refl _)

/-- Homotopic self-maps have the same index map. -/
theorem slice_eq_of_natIso {F G : Discrete ι × D ⥤ Discrete ι × D} (e : F ≅ G) :
    slice d F = slice d G := by
  funext i
  exact Discrete.eq_of_hom (e.hom.app (⟨i⟩, d)).1

/-- Homotopic self-maps have homotopic pieces. -/
def pieceIsoOfNatIso {F G : Discrete ι × D ⥤ Discrete ι × D} (e : F ≅ G) (i : ι) :
    piece F i ≅ piece G i :=
  Functor.isoWhiskerRight (Functor.isoWhiskerLeft (incl i) e)
    (CategoryTheory.Prod.snd (Discrete ι) D)

/-- Assembled self-maps are homotopic if the assembling data agree up to homotopy. -/
def wreathFunctorCongr {σ : ι → ι} {P Q : ι → (D ⥤ D)} (h : ∀ i, P i ≅ Q i) :
    wreathFunctor σ P ≅ wreathFunctor σ Q :=
  natIsoOfIncl fun i =>
    ((inclCompWreathFunctor σ P i).trans
      (Functor.isoWhiskerRight (h i) (incl (σ i)))).trans
      (inclCompWreathFunctor σ Q i).symm

/-- The index map of a composite is the composite of the index maps. -/
theorem slice_comp (hD : ConnectedAt D d) (F G : Discrete ι × D ⥤ Discrete ι × D) (i : ι) :
    slice d (G ⋙ F) i = slice d F (slice d G i) := by
  have hG : G.obj ((⟨i⟩ : Discrete ι), d) = ((⟨slice d G i⟩ : Discrete ι), (G.obj (⟨i⟩, d)).2) :=
    Prod.ext (Discrete.ext (fst_obj_eq_slice hD G i d)) rfl
  show (F.obj (G.obj ((⟨i⟩ : Discrete ι), d))).1.as = _
  rw [hG]
  exact fst_obj_eq_slice hD F (slice d G i) _

/-- The pieces of a composite: the `i`-th piece of `G ⋙ F` is the `i`-th piece of `G`
followed by the `slice G i`-th piece of `F`. -/
def pieceCompIso (hD : ConnectedAt D d) (F G : Discrete ι × D ⥤ Discrete ι × D) (i : ι) :
    piece (G ⋙ F) i ≅ piece G i ⋙ piece F (slice d G i) :=
  Functor.isoWhiskerRight (inclCompSelf hD G i) (F ⋙ CategoryTheory.Prod.snd (Discrete ι) D)

end Pieces

/-! ## The wreath monoid -/

section WreathEnd

variable (ι : Type w) (M : Type u)

/-- The **wreath monoid** `M ≀ End(ι)`: pairs consisting of a family `P : ι → M` and a
self-map `σ` of `ι`, multiplied by `(P, σ) * (Q, τ) = (fun i => P (τ i) * Q i, σ ∘ τ)`. -/
def WreathEnd : Type max w u := (ι → M) × Function.End ι

variable {ι M}

/-- Build an element of the wreath monoid. -/
def WreathEnd.mk (P : ι → M) (σ : Function.End ι) : WreathEnd ι M := (P, σ)

/-- The family of components of an element of the wreath monoid. -/
def WreathEnd.fam (x : WreathEnd ι M) : ι → M := x.1

/-- The index map of an element of the wreath monoid. -/
def WreathEnd.idx (x : WreathEnd ι M) : Function.End ι := x.2

@[simp] theorem WreathEnd.fam_mk (P : ι → M) (σ : Function.End ι) :
    (WreathEnd.mk P σ).fam = P := rfl

@[simp] theorem WreathEnd.idx_mk (P : ι → M) (σ : Function.End ι) :
    (WreathEnd.mk P σ).idx = σ := rfl

theorem WreathEnd.ext {x y : WreathEnd ι M} (hf : x.fam = y.fam) (hi : x.idx = y.idx) :
    x = y := Prod.ext hf hi

variable [Monoid M]

instance : Monoid (WreathEnd ι M) where
  mul x y := WreathEnd.mk (fun i => x.fam (y.idx i) * y.fam i) (x.idx * y.idx)
  one := WreathEnd.mk (fun _ => 1) 1
  mul_assoc x y z := WreathEnd.ext (funext fun _ => mul_assoc _ _ _) rfl
  one_mul x := WreathEnd.ext (funext fun _ => one_mul _) rfl
  mul_one x := WreathEnd.ext (funext fun _ => mul_one _) rfl

@[simp] theorem WreathEnd.fam_mul (x y : WreathEnd ι M) :
    (x * y).fam = fun i => x.fam (y.idx i) * y.fam i := rfl

@[simp] theorem WreathEnd.idx_mul (x y : WreathEnd ι M) : (x * y).idx = x.idx * y.idx := rfl

@[simp] theorem WreathEnd.fam_one : (1 : WreathEnd ι M).fam = fun _ => 1 := rfl

@[simp] theorem WreathEnd.idx_one : (1 : WreathEnd ι M).idx = 1 := rfl

end WreathEnd

/-! ## The classification of self-maps of a disjoint union -/

section Classification

variable {ι : Type w} {D : Type u} [Groupoid.{v} D] {d : D}

/-- **Homotopy classes of self-maps of `⊔_ι D` form the wreath monoid of `[D,D]`.**
A homotopy class of self-maps of a disjoint union of copies of a connected 1-type is
exactly a self-map of the index set together with a homotopy class of self-maps of `D` for
each index. -/
noncomputable def hEndMulEquivWreathEnd (hD : ConnectedAt D d) :
    HEnd (Discrete ι × D) ≃* WreathEnd ι (HEnd D) where
  toFun := Quotient.lift
    (fun F => WreathEnd.mk (fun i => HEnd.mk D (piece F i)) (slice d F))
    (by
      rintro F G ⟨e⟩
      refine WreathEnd.ext ?_ (slice_eq_of_natIso e)
      funext i
      exact HEnd.mk_eq_mk.2 ⟨pieceIsoOfNatIso e i⟩)
  invFun x := HEnd.mk _ (wreathFunctor x.idx fun i => Quotient.out (x.fam i))
  left_inv q := by
    induction q using HEnd.ind with
    | _ F =>
      refine HEnd.mk_eq_mk.2 ⟨Iso.trans ?_ (selfNatIsoWreathFunctor hD F).symm⟩
      exact wreathFunctorCongr fun i =>
        (HEnd.mk_eq_mk.1 (Quotient.out_eq (HEnd.mk D (piece F i)))).some
  right_inv x := by
    refine WreathEnd.ext ?_ rfl
    funext i
    exact (HEnd.mk_eq_mk.2 ⟨pieceWreathFunctor _ _ i⟩).trans (Quotient.out_eq _)
  map_mul' a b := by
    induction a using HEnd.ind with
    | _ F =>
      induction b using HEnd.ind with
      | _ G =>
        refine WreathEnd.ext (funext fun i => ?_) (funext fun i => slice_comp hD F G i)
        exact HEnd.mk_eq_mk.2 ⟨pieceCompIso hD F G i⟩

end Classification

/-! ## The units of the wreath monoid: the wreath product -/

section Units

variable (ι : Type w) (N : Type u) [Group N]

/-- Permuting the coordinates of a family of group elements. -/
def permAutEquiv (σ : Equiv.Perm ι) : MulAut (ι → N) where
  toFun n := n ∘ σ.symm
  invFun n := n ∘ σ
  left_inv n := funext fun i => by simp
  right_inv n := funext fun i => by simp
  map_mul' _ _ := rfl

/-- The action of `Sym ι` on `ι → N` by permuting coordinates: the structure map of the
wreath product `N ≀ Sym ι`. -/
def permAut : Equiv.Perm ι →* MulAut (ι → N) where
  toFun := permAutEquiv ι N
  map_one' := by ext n i; rfl
  map_mul' σ τ := by ext n i; rfl

@[simp] theorem permAut_apply (σ : Equiv.Perm ι) (n : ι → N) (i : ι) :
    permAut ι N σ n i = n (σ.symm i) := rfl

variable {ι N}

/-- Transporting a semidirect product along an isomorphism of the normal factor. -/
def semidirectCongrLeft {N' : Type u'} [Group N'] {Q : Type*} [Group Q]
    {φ : Q →* MulAut N} {φ' : Q →* MulAut N'} (e : N ≃* N')
    (h : ∀ (q : Q) (n : N), e (φ q n) = φ' q (e n)) :
    (N ⋊[φ] Q) ≃* (N' ⋊[φ'] Q) where
  toFun x := ⟨e x.left, x.right⟩
  invFun x := ⟨e.symm x.left, x.right⟩
  left_inv x := by simp
  right_inv x := by simp
  map_mul' x y := by
    refine SemidirectProduct.ext ?_ rfl
    simp [h]

variable (ι) (M : Type u) [Monoid M]

/-- The wreath product maps into the units of the wreath monoid. -/
def wreathUnitsHom :
    ((ι → Mˣ) ⋊[permAut ι Mˣ] Equiv.Perm ι) →* (WreathEnd ι M)ˣ where
  toFun x :=
    { val := WreathEnd.mk (fun i => ((x.left (x.right i) : Mˣ) : M)) (x.right : ι → ι)
      inv := WreathEnd.mk (fun i => (((x.left i)⁻¹ : Mˣ) : M)) (x.right.symm : ι → ι)
      val_inv := WreathEnd.ext (funext fun i => by simp)
        (funext fun i => x.right.apply_symm_apply i)
      inv_val := WreathEnd.ext (funext fun i => by simp)
        (funext fun i => x.right.symm_apply_apply i) }
  map_one' := Units.ext (WreathEnd.ext (funext fun i => rfl) rfl)
  map_mul' x y := Units.ext (WreathEnd.ext (funext fun i => by simp) (funext fun i => rfl))

@[simp] theorem wreathUnitsHom_val_fam
    (x : (ι → Mˣ) ⋊[permAut ι Mˣ] Equiv.Perm ι) (i : ι) :
    ((wreathUnitsHom ι M x : WreathEnd ι M)).fam i = ((x.left (x.right i) : Mˣ) : M) := rfl

@[simp] theorem wreathUnitsHom_val_idx (x : (ι → Mˣ) ⋊[permAut ι Mˣ] Equiv.Perm ι) :
    ((wreathUnitsHom ι M x : WreathEnd ι M)).idx = (x.right : ι → ι) := rfl

theorem wreathUnitsHom_injective : Function.Injective (wreathUnitsHom ι M) := by
  intro x y hxy
  have hval : (wreathUnitsHom ι M x : WreathEnd ι M) = (wreathUnitsHom ι M y : WreathEnd ι M) :=
    congrArg Units.val hxy
  have hidx : (x.right : ι → ι) = (y.right : ι → ι) := congrArg WreathEnd.idx hval
  have hright : x.right = y.right := Equiv.coe_fn_injective hidx
  refine SemidirectProduct.ext ?_ hright
  funext j
  have hfam := congrArg WreathEnd.fam hval
  have := congrFun hfam (x.right.symm j)
  simp only [wreathUnitsHom_val_fam, Equiv.apply_symm_apply, hright] at this
  exact Units.ext (by simpa [hright] using this)

theorem wreathUnitsHom_surjective : Function.Surjective (wreathUnitsHom ι M) := by
  intro u
  have h1 : (u : WreathEnd ι M) * ((u⁻¹ : (WreathEnd ι M)ˣ) : WreathEnd ι M) = 1 := u.val_inv
  have h2 : ((u⁻¹ : (WreathEnd ι M)ˣ) : WreathEnd ι M) * (u : WreathEnd ι M) = 1 := u.inv_val
  have hst : (u : WreathEnd ι M).idx * ((u⁻¹ : (WreathEnd ι M)ˣ) : WreathEnd ι M).idx = 1 :=
    congrArg WreathEnd.idx h1
  have hts : ((u⁻¹ : (WreathEnd ι M)ˣ) : WreathEnd ι M).idx * (u : WreathEnd ι M).idx = 1 :=
    congrArg WreathEnd.idx h2
  -- the index map is a permutation
  set s : ι → ι := (u : WreathEnd ι M).idx with hs
  set t : ι → ι := ((u⁻¹ : (WreathEnd ι M)ˣ) : WreathEnd ι M).idx with ht
  have hst' : ∀ i, s (t i) = i := fun i => congrFun hst i
  have hts' : ∀ i, t (s i) = i := fun i => congrFun hts i
  let σ : Equiv.Perm ι := ⟨s, t, hts', hst'⟩
  -- each component is a unit
  have hPQ : ∀ i, (u : WreathEnd ι M).fam (t i) *
      ((u⁻¹ : (WreathEnd ι M)ˣ) : WreathEnd ι M).fam i = 1 := fun i =>
    congrFun (congrArg WreathEnd.fam h1) i
  have hQP : ∀ i, ((u⁻¹ : (WreathEnd ι M)ˣ) : WreathEnd ι M).fam (s i) *
      (u : WreathEnd ι M).fam i = 1 := fun i =>
    congrFun (congrArg WreathEnd.fam h2) i
  have hunit : ∀ i, IsUnit ((u : WreathEnd ι M).fam i) := by
    intro i
    refine ⟨⟨(u : WreathEnd ι M).fam i,
      ((u⁻¹ : (WreathEnd ι M)ˣ) : WreathEnd ι M).fam (s i), ?_, hQP i⟩, rfl⟩
    have := hPQ (s i)
    rwa [hts' i] at this
  refine ⟨ ?_, ?_⟩
  · exact { left := fun i => (hunit (σ.symm i)).unit, right := σ }
  · refine Units.ext (WreathEnd.ext (funext fun i => ?_) rfl)
    show ((hunit (σ.symm (σ i))).unit : M) = _
    simp

/-- **The units of the wreath monoid form the wreath product** `Mˣ ≀ Sym ι`. -/
noncomputable def wreathEndUnitsMulEquivSemidirect :
    ((ι → Mˣ) ⋊[permAut ι Mˣ] Equiv.Perm ι) ≃* (WreathEnd ι M)ˣ :=
  MulEquiv.ofBijective (wreathUnitsHom ι M)
    ⟨wreathUnitsHom_injective ι M, wreathUnitsHom_surjective ι M⟩

end Units

/-! ## Homotopy invariance of the monoid of self-maps -/

section Transport

variable {C : Type u} [Category.{v} C] {E : Type u'} [Category.{v'} E]

/-- Conjugating a self-map by an equivalence returns the original self-map up to
homotopy. -/
def roundTripIso (W : C ≌ E) (F : C ⥤ C) :
    W.functor ⋙ (W.inverse ⋙ F ⋙ W.functor) ⋙ W.inverse ≅ F :=
  NatIso.ofComponents
    (fun X => (W.unitIso.app (F.obj (W.inverse.obj (W.functor.obj X)))).symm.trans
      (F.mapIso (W.unitIso.app X).symm))
    (by intros; simp)

/-- Conjugation by an equivalence turns a composite into the composite of the
conjugates. -/
def conjCompIso (W : C ≌ E) (F G : C ⥤ C) :
    (W.inverse ⋙ (G ⋙ F) ⋙ W.functor) ≅
      (W.inverse ⋙ G ⋙ W.functor) ⋙ (W.inverse ⋙ F ⋙ W.functor) :=
  NatIso.ofComponents
    (fun X => W.functor.mapIso (F.mapIso (W.unitIso.app (G.obj (W.inverse.obj X)))))
    (by intros; simp)

/-- **Equivalent 1-types have isomorphic monoids of homotopy classes of self-maps.** -/
def hEndCongr (W : C ≌ E) : HEnd C ≃* HEnd E where
  toFun := Quotient.lift (fun F => HEnd.mk E (W.inverse ⋙ F ⋙ W.functor))
    (by
      rintro F G ⟨e⟩
      exact HEnd.mk_eq_mk.2
        ⟨Functor.isoWhiskerLeft _ (Functor.isoWhiskerRight e W.functor)⟩)
  invFun := Quotient.lift (fun F => HEnd.mk C (W.functor ⋙ F ⋙ W.inverse))
    (by
      rintro F G ⟨e⟩
      exact HEnd.mk_eq_mk.2
        ⟨Functor.isoWhiskerLeft _ (Functor.isoWhiskerRight e W.inverse)⟩)
  left_inv q := by
    induction q using HEnd.ind with
    | _ F => exact HEnd.mk_eq_mk.2 ⟨roundTripIso W F⟩
  right_inv q := by
    induction q using HEnd.ind with
    | _ F => exact HEnd.mk_eq_mk.2 ⟨roundTripIso W.symm F⟩
  map_mul' a b := by
    induction a using HEnd.ind with
    | _ F =>
      induction b using HEnd.ind with
      | _ G => exact HEnd.mk_eq_mk.2 ⟨conjCompIso W F G⟩

end Transport

/-! ## The product model is the coproduct of `ι` copies -/

section SigmaModel

variable {ι : Type w} {D : Type u} [Groupoid.{v} D]

open FundamentalGroupPi0 (sigmaGroupoid)

/-- The comparison functor from the coproduct of `ι` copies of `D` to the product model
`Discrete ι × D`. -/
def sigmaToProd : (Σ _ : ι, D) ⥤ Discrete ι × D := Sigma.desc fun i => incl i

instance : (sigmaToProd (ι := ι) (D := D)).Faithful := by
  refine { map_injective := ?_ }
  rintro ⟨i, X⟩ ⟨j, Y⟩ f g hfg
  have hij : i = j := match f with | Sigma.SigmaHom.mk _ => rfl
  subst hij
  rcases f with ⟨f'⟩; rcases g with ⟨g'⟩
  exact congrArg Sigma.SigmaHom.mk (congrArg Prod.snd hfg)

instance : (sigmaToProd (ι := ι) (D := D)).Full := by
  refine { map_surjective := ?_ }
  rintro ⟨i, X⟩ ⟨j, Y⟩ ⟨u, g⟩
  obtain rfl : i = j := Discrete.eq_of_hom u
  exact ⟨Sigma.SigmaHom.mk g, Prod.ext (Subsingleton.elim _ _) rfl⟩

instance : (sigmaToProd (ι := ι) (D := D)).EssSurj :=
  ⟨fun p => ⟨⟨p.1.as, p.2⟩, ⟨Iso.refl _⟩⟩⟩

instance : (sigmaToProd (ι := ι) (D := D)).IsEquivalence := ⟨inferInstance, inferInstance, inferInstance⟩

/-- **The product model `Discrete ι × D` is the disjoint union of `ι` copies of `D`.** -/
noncomputable def sigmaEquivProdModel : (Σ _ : ι, D) ≌ Discrete ι × D :=
  sigmaToProd.asEquivalence

end SigmaModel

/-! ## The main theorem -/

section Main

variable {ι : Type w} {D : Type u} [Groupoid.{v} D] {d : D}

/-- **The homotopy self-equivalence group of a disjoint union of `ι` copies of a `K(G,1)`
is the wreath product `Out(G) ≀ Sym(ι) = (ι → Out G) ⋊ Sym(ι)`.**

This interpolates between the two previously known extreme cases: `ι` a singleton gives
`Out G`, and `G` trivial gives `Sym(ι)`. -/
noncomputable def hAutMulEquivWreathOut (hD : ConnectedAt D d) :
    (HEnd (Discrete ι × D))ˣ ≃*
      ((ι → OutAut (Aut d)) ⋊[permAut ι (OutAut (Aut d))] Equiv.Perm ι) :=
  (((semidirectCongrLeft
        (MulEquiv.piCongrRight fun _ : ι => outAut_mulEquiv_hEnd_units hD)
        (fun _ _ => rfl)).trans
      (wreathEndUnitsMulEquivSemidirect ι (HEnd D))).trans
    (Units.mapEquiv (hEndMulEquivWreathEnd (ι := ι) hD)).symm).symm

/-- A semidirect product is in bijection with the product of its factors. -/
def semidirectEquivProd {N : Type*} [Group N] {Q : Type*} [Group Q] {φ : Q →* MulAut N} :
    (N ⋊[φ] Q) ≃ N × Q where
  toFun x := (x.left, x.right)
  invFun p := ⟨p.1, p.2⟩
  left_inv _ := rfl
  right_inv _ := rfl

/-- **Counting.**  For a finite index set the number of homotopy classes of
self-homotopy-equivalences of `⊔_{i ∈ ι} K(G,1)` is `|Out G| ^ |ι| · |ι|!`. -/
theorem card_hAut_sigma (hD : ConnectedAt D d) [Fintype ι] :
    Nat.card ((HEnd (Discrete ι × D))ˣ) =
      Nat.card (OutAut (Aut d)) ^ Fintype.card ι * Nat.factorial (Fintype.card ι) := by
  classical
  rw [Nat.card_congr ((hAutMulEquivWreathOut (ι := ι) hD).toEquiv.trans semidirectEquivProd),
    Nat.card_prod, Nat.card_pi, Finset.prod_const,
    Nat.card_eq_fintype_card (α := Equiv.Perm ι), Fintype.card_perm, Finset.card_univ]

/-- **The main theorem for the coproduct model** `⊔_{i ∈ ι} K(G,1) = Σ _ : ι, D`. -/
noncomputable def hAutSigmaMulEquivWreathOut (hD : ConnectedAt D d) :
    (HEnd (Σ _ : ι, D))ˣ ≃*
      ((ι → OutAut (Aut d)) ⋊[permAut ι (OutAut (Aut d))] Equiv.Perm ι) :=
  (Units.mapEquiv (hEndCongr (sigmaEquivProdModel (ι := ι) (D := D)))).trans
    (hAutMulEquivWreathOut hD)

/-- The number of homotopy classes of self-homotopy-equivalences of `⊔_{i ∈ ι} K(G,1)`,
expressed through the self-equivalences of a single copy. -/
theorem card_hAut_sigma_of_card_hAut (hD : ConnectedAt D d) [Fintype ι] :
    Nat.card ((HEnd (Discrete ι × D))ˣ) =
      Nat.card ((HEnd D)ˣ) ^ Fintype.card ι * Nat.factorial (Fintype.card ι) := by
  rw [card_hAut_sigma hD, Nat.card_congr (outAut_mulEquiv_hEnd_units hD).toEquiv]

/-! ### The extension `1 → ∏ Out G → hAut → Sym ι → 1` -/

/-- The action of the homotopy self-equivalence group of `⊔_ι K(G,1)` on the set of
copies. -/
noncomputable def hAutToPermCopies (hD : ConnectedAt D d) :
    (HEnd (Discrete ι × D))ˣ →* Equiv.Perm ι :=
  SemidirectProduct.rightHom.comp (hAutMulEquivWreathOut hD).toMonoidHom

/-- The homotopy self-equivalences of the individual copies, viewed inside those of the
disjoint union. -/
noncomputable def outCopiesToHAut (hD : ConnectedAt D d) :
    (ι → OutAut (Aut d)) →* (HEnd (Discrete ι × D))ˣ :=
  (hAutMulEquivWreathOut hD).symm.toMonoidHom.comp SemidirectProduct.inl

/-- The permutation of the copies induced by a self-homotopy-equivalence is its index
map. -/
theorem coe_hAutToPermCopies (hD : ConnectedAt D d) (u : (HEnd (Discrete ι × D))ˣ) :
    ⇑(hAutToPermCopies (ι := ι) hD u) =
      ((hEndMulEquivWreathEnd hD) (u : HEnd (Discrete ι × D))).idx := by
  set x := hAutMulEquivWreathOut (ι := ι) hD u with hx
  have hu : ((wreathEndUnitsMulEquivSemidirect ι (HEnd D))
      (semidirectCongrLeft (MulEquiv.piCongrRight fun _ : ι => outAut_mulEquiv_hEnd_units hD)
        (fun _ _ => rfl) x) : (WreathEnd ι (HEnd D))ˣ) =
      Units.mapEquiv (hEndMulEquivWreathEnd (ι := ι) hD) u := by
    have h0 : (hAutMulEquivWreathOut (ι := ι) hD).symm x = u :=
      (hAutMulEquivWreathOut hD).symm_apply_apply u
    conv_rhs => rw [← h0]
    exact ((Units.mapEquiv (hEndMulEquivWreathEnd (ι := ι) hD)).apply_symm_apply _).symm
  have := congrArg (fun y : (WreathEnd ι (HEnd D))ˣ => (y : WreathEnd ι (HEnd D)).idx) hu
  simpa [hAutToPermCopies, wreathEndUnitsMulEquivSemidirect, semidirectCongrLeft] using this

/-- The permutation of the copies induced by a self-homotopy-equivalence represented by an
endofunctor `F` is the index map of `F`. -/
theorem hAutToPermCopies_apply_of_mk (hD : ConnectedAt D d) (u : (HEnd (Discrete ι × D))ˣ)
    (F : Discrete ι × D ⥤ Discrete ι × D) (hF : HEnd.mk _ F = (u : HEnd (Discrete ι × D)))
    (i : ι) : hAutToPermCopies (ι := ι) hD u i = slice d F i := by
  have := congrFun (coe_hAutToPermCopies hD u) i
  rw [this, ← hF]
  rfl

/-- **`π₀` of a disjoint union of `ι` copies of a connected 1-type is `ι`.** -/
def componentsProdEquiv (hD : ConnectedAt D d) :
    FundamentalGroupK1Deep.Components (Discrete ι × D) ≃ ι where
  toFun := Quotient.lift (fun p => p.1.as) (fun _ _ ⟨e⟩ => Discrete.eq_of_hom e.hom.1)
  invFun i := Quotient.mk _ ((⟨i⟩ : Discrete ι), d)
  left_inv q := by
    induction q using Quotient.ind with
    | _ p => exact Quotient.sound ⟨Iso.prod (Iso.refl _) (hD p.2).some⟩
  right_inv _ := rfl

/-- **The projection of the wreath product onto `Sym ι` is the action on `π₀`.** -/
theorem hAutToPermCopies_eq_pi0Action (hD : ConnectedAt D d)
    (u : (HEnd (Discrete ι × D))ˣ) (i : ι) :
    componentsProdEquiv hD (FundamentalGroupPi0Action.hAutToPermComponents (Discrete ι × D) u
        ((componentsProdEquiv hD).symm i)) =
      hAutToPermCopies (ι := ι) hD u i := by
  have hF : HEnd.mk (Discrete ι × D) (Quotient.out (u : HEnd (Discrete ι × D))) =
      (u : HEnd (Discrete ι × D)) := Quotient.out_eq _
  rw [hAutToPermCopies_apply_of_mk hD u _ hF]
  conv_lhs => rw [FundamentalGroupPi0Action.hAutToPermComponents_apply, ← hF]
  rfl

/-- **Every permutation of the copies is realised by a self-homotopy-equivalence.** -/
theorem hAutToPermCopies_surjective (hD : ConnectedAt D d) :
    Function.Surjective (hAutToPermCopies (ι := ι) hD) :=
  SemidirectProduct.rightHom_surjective.comp (hAutMulEquivWreathOut hD).surjective

/-- **Exactness**: a self-homotopy-equivalence of `⊔_ι K(G,1)` fixes every copy exactly
when it is a family of self-homotopy-equivalences of the copies. -/
theorem ker_hAutToPermCopies (hD : ConnectedAt D d) :
    (hAutToPermCopies (ι := ι) hD).ker = (outCopiesToHAut (ι := ι) hD).range := by
  ext u
  constructor
  · intro hu
    obtain ⟨n, hn⟩ := (SemidirectProduct.range_inl_eq_ker_rightHom (φ :=
      permAut ι (OutAut (Aut d)))).symm.le (MonoidHom.mem_ker.2 hu)
    exact ⟨n, by
      show (hAutMulEquivWreathOut hD).symm (SemidirectProduct.inl n) = u
      rw [hn]
      exact (hAutMulEquivWreathOut hD).symm_apply_apply u⟩
  · rintro ⟨n, rfl⟩
    refine MonoidHom.mem_ker.2 ?_
    show SemidirectProduct.rightHom
      ((hAutMulEquivWreathOut hD) ((hAutMulEquivWreathOut hD).symm
        (SemidirectProduct.inl n))) = 1
    rw [MulEquiv.apply_symm_apply]
    exact SemidirectProduct.rightHom_inl n

/-- **The extension splits**: the permutations of the copies act by rigid relabelling. -/
theorem hAutToPermCopies_split (hD : ConnectedAt D d) :
    ∃ s : Equiv.Perm ι →* (HEnd (Discrete ι × D))ˣ,
      ∀ σ, hAutToPermCopies (ι := ι) hD (s σ) = σ := by
  refine ⟨(hAutMulEquivWreathOut hD).symm.toMonoidHom.comp SemidirectProduct.inr, fun σ => ?_⟩
  show SemidirectProduct.rightHom
    ((hAutMulEquivWreathOut hD) ((hAutMulEquivWreathOut hD).symm
      (SemidirectProduct.inr σ))) = σ
  rw [MulEquiv.apply_symm_apply]
  rfl

end Main

/-! ## The two extreme cases -/

section Degenerate

/-- A semidirect product with trivial acting group is the normal factor. -/
def semidirectOfSubsingletonRight {N : Type*} [Group N] {Q : Type*} [Group Q] [Subsingleton Q]
    {φ : Q →* MulAut N} : (N ⋊[φ] Q) ≃* N where
  toFun x := x.left
  invFun n := ⟨n, 1⟩
  left_inv x := SemidirectProduct.ext rfl (Subsingleton.elim _ _)
  right_inv _ := rfl
  map_mul' x y := by
    have : x.right = 1 := Subsingleton.elim _ _
    simp [this]

/-- A semidirect product with trivial normal factor is the acting group. -/
def semidirectOfSubsingletonLeft {N : Type*} [Group N] [Subsingleton N] {Q : Type*} [Group Q]
    {φ : Q →* MulAut N} : (N ⋊[φ] Q) ≃* Q where
  toFun x := x.right
  invFun q := ⟨1, q⟩
  left_inv _ := SemidirectProduct.ext (Subsingleton.elim _ _) rfl
  right_inv _ := rfl
  map_mul' _ _ := rfl

variable {D : Type u} [Groupoid.{v} D] {d : D}

/-- With one copy the wreath product degenerates: the connected case `hAut = Out G` is
recovered. -/
noncomputable def hAutSingleCopyMulEquivOut (hD : ConnectedAt D d) :
    (HEnd (Discrete PUnit.{w + 1} × D))ˣ ≃* OutAut (Aut d) :=
  (hAutMulEquivWreathOut (ι := PUnit.{w + 1}) hD).trans
    (semidirectOfSubsingletonRight.trans (MulEquiv.piUnique _))

/-- A group with a single element has trivial outer automorphism group. -/
theorem outAut_subsingleton_of_subsingleton (G : Type*) [Group G] [Subsingleton G] :
    Subsingleton (OutAut G) := by
  haveI : Subsingleton (MulAut G) := ⟨fun a b => by ext x; exact Subsingleton.elim _ _⟩
  refine ⟨fun a b => ?_⟩
  induction a using QuotientGroup.induction_on with
  | H a =>
    induction b using QuotientGroup.induction_on with
    | H b => exact congrArg _ (Subsingleton.elim a b)

/-- With trivial fundamental group the wreath product degenerates to `Sym(π₀)`,
recovering the totally disconnected case. -/
noncomputable def hAutTrivialPiOneMulEquivPerm {ι : Type w} (hD : ConnectedAt D d)
    (hd : Subsingleton (Aut d)) :
    (HEnd (Discrete ι × D))ˣ ≃* Equiv.Perm ι := by
  haveI := hd
  haveI : Subsingleton (OutAut (Aut d)) := outAut_subsingleton_of_subsingleton _
  haveI : Subsingleton (ι → OutAut (Aut d)) := Pi.instSubsingleton
  exact (hAutMulEquivWreathOut (ι := ι) hD).trans semidirectOfSubsingletonLeft

end Degenerate

/-! ## Self-homotopies of the identity of a disjoint union -/

section AutId

variable {ι : Type w} {D : Type u}

section

variable [Category.{v} D]

/-- The self-homotopy of the identity of the `i`-th copy induced by a self-homotopy of the
identity of the disjoint union. -/
def restrictAutId (α : Aut (𝟭 (Discrete ι × D))) (i : ι) : Aut (𝟭 D) :=
  Functor.isoWhiskerRight (Functor.isoWhiskerLeft (incl i) α)
    (CategoryTheory.Prod.snd (Discrete ι) D)

/-- A family of self-homotopies of the identities of the copies assembles into one for the
disjoint union. -/
def assembleAutId (β : ι → Aut (𝟭 D)) : Aut (𝟭 (Discrete ι × D)) :=
  natIsoOfIncl fun i => Functor.isoWhiskerRight (β i) (incl i)

/-- **The self-homotopies of the identity of `⊔_ι D` are families of self-homotopies of the
identity of `D`.** -/
def autIdProdMulEquivPi : Aut (𝟭 (Discrete ι × D)) ≃* (ι → Aut (𝟭 D)) where
  toFun := restrictAutId
  invFun := assembleAutId
  left_inv α := by
    apply Iso.ext
    ext p
    · apply Subsingleton.elim
    · rfl
  right_inv β := by
    funext i
    apply Iso.ext
    ext X
    rfl
  map_mul' α γ := by
    funext i
    apply Iso.ext
    ext X
    rfl

end

variable [Groupoid.{v} D] {d : D}

/-- **The `π₁` of the automorphism 2-group of `⊔_ι K(G,1)` is `∏_ι Z(G)`.**  Together
with `hAutMulEquivWreathOut` (`π₀ = Out(G) ≀ Sym(ι)`) this computes the whole automorphism
2-group of a disjoint union of copies of a `K(G,1)`. -/
noncomputable def autIdProdMulEquivPiCenter (hD : ConnectedAt D d) :
    Aut (𝟭 (Discrete ι × D)) ≃* (ι → Subgroup.center (Aut d)) :=
  autIdProdMulEquivPi.trans (MulEquiv.piCongrRight fun _ => autId_mulEquiv_center hD)

end AutId

end FundamentalGroupWreath
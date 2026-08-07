import Mathlib

/-!
# Bridge: homology as maps out of a single complex in the homotopy / derived category

This file proves the chain-level heart of the bridge

  `singular homology of X  =  Ext^{-n}(ℤ, C_*(X))  in the derived category`

in the following precise form.  For an abelian category `V`, a complex shape `c`,
a degree `j`, a **projective** object `A` and a homological complex `K`:

* `Catalog.Bridges.singleHomologyClass f : A ⟶ K.homology j` is the homology class
  of a chain map `f : (single V c j).obj A ⟶ K`;
* two such chain maps are chain homotopic iff they have the same class
  (`Catalog.Bridges.nonempty_homotopy_iff_singleHomologyClass_eq`);
* every class arises this way (`Catalog.Bridges.singleHomologyClass_surjective`).

This is the statement "chain complexes modulo homotopy compute homology": the
hom-group in the homotopy category out of the single complex `A[j]` *is*
`Hom(A, H_j K)`.
-/

universe v u

namespace Catalog.Bridges

open CategoryTheory Category Limits HomologicalComplex

variable {V : Type u} [Category.{v} V] [Abelian V] {ι : Type*} [DecidableEq ι]
  {c : ComplexShape ι} {j : ι} {A : V} {K : HomologicalComplex V c}

/-- A chain map out of a single complex lands in the cycles. -/
lemma fromSingle_comp_d_eq_zero (f : (single V c j).obj A ⟶ K) :
    ((singleObjXSelf c j A).inv ≫ f.f j) ≫ K.d j (c.next j) = 0 := by
  rw [assoc, f.comm j (c.next j), single_obj_d]
  simp

/-- The cycle in degree `j` determined by a chain map out of the single complex `A[j]`. -/
noncomputable def fromSingleCycles (f : (single V c j).obj A ⟶ K) : A ⟶ K.cycles j :=
  K.liftCycles ((singleObjXSelf c j A).inv ≫ f.f j) (c.next j) rfl
    (fromSingle_comp_d_eq_zero f)

@[simp]
lemma fromSingleCycles_i (f : (single V c j).obj A ⟶ K) :
    fromSingleCycles f ≫ K.iCycles j = (singleObjXSelf c j A).inv ≫ f.f j :=
  K.liftCycles_i _ _ _ _

/-- The homology class of a chain map `A[j] ⟶ K` out of a single complex. -/
noncomputable def singleHomologyClass (f : (single V c j).obj A ⟶ K) : A ⟶ K.homology j :=
  fromSingleCycles f ≫ K.homologyπ j

lemma fromSingleCycles_add (f g : (single V c j).obj A ⟶ K) :
    fromSingleCycles (f + g) = fromSingleCycles f + fromSingleCycles g := by
  apply (cancel_mono (K.iCycles j)).1
  simp [Preadditive.add_comp, Preadditive.comp_add]

lemma singleHomologyClass_add (f g : (single V c j).obj A ⟶ K) :
    singleHomologyClass (f + g) = singleHomologyClass f + singleHomologyClass g := by
  simp [singleHomologyClass, fromSingleCycles_add, Preadditive.add_comp]

lemma singleHomologyClass_zero :
    singleHomologyClass (0 : (single V c j).obj A ⟶ K) = 0 := by
  simp only [singleHomologyClass]
  have : fromSingleCycles (0 : (single V c j).obj A ⟶ K) = 0 := by
    apply (cancel_mono (K.iCycles j)).1
    simp
  rw [this, zero_comp]

lemma singleHomologyClass_neg (f : (single V c j).obj A ⟶ K) :
    singleHomologyClass (-f) = - singleHomologyClass f := by
  have h0 := singleHomologyClass_add f (-f)
  rw [show f + -f = (0 : (single V c j).obj A ⟶ K) by abel, singleHomologyClass_zero] at h0
  linear_combination (norm := abel) -h0

lemma singleHomologyClass_sub (f g : (single V c j).obj A ⟶ K) :
    singleHomologyClass (f - g) = singleHomologyClass f - singleHomologyClass g := by
  rw [show f - g = f + -g by abel, singleHomologyClass_add, singleHomologyClass_neg]
  abel

/-- Chain homotopic maps out of a single complex have the same homology class. -/
lemma singleHomologyClass_eq_of_homotopy {f g : (single V c j).obj A ⟶ K}
    (ho : Homotopy f g) : singleHomologyClass f = singleHomologyClass g := by
  have key : singleHomologyClass (f - g) = 0 := by
    have hcomm : (f - g).f j = (ho.hom j (c.prev j)) ≫ K.d (c.prev j) j := by
      have hc := ho.comm j
      have hd : (dNext j) ho.hom = 0 := by simp [dNext, single_obj_d]
      have hp : (prevD j) ho.hom = ho.hom j (c.prev j) ≫ K.d (c.prev j) j := by simp [prevD]
      rw [HomologicalComplex.sub_f_apply, hc, hd, hp]
      abel
    refine K.liftCycles_homologyπ_eq_zero_of_boundary _ (c.next j) rfl
      ((singleObjXSelf c j A).inv ≫ ho.hom j (c.prev j)) ?_
    rw [assoc, ← hcomm]
  rw [singleHomologyClass_sub] at key
  linear_combination (norm := abel) key

/-- If the homology class of a map out of a single complex on a projective object vanishes,
the map is a boundary. -/
lemma exists_boundary_of_singleHomologyClass_eq_zero [Projective A]
    (f : (single V c j).obj A ⟶ K) (hf : singleHomologyClass f = 0) :
    ∃ β : A ⟶ K.X (c.prev j), (singleObjXSelf c j A).inv ≫ f.f j = β ≫ K.d (c.prev j) j := by
  have hexact : (ShortComplex.mk (K.toCycles (c.prev j) j) (K.homologyπ j) (by simp)).Exact :=
    ShortComplex.exact_of_g_is_cokernel _ (K.homologyIsCokernel (c.prev j) j rfl)
  refine ⟨hexact.liftFromProjective (fromSingleCycles f) hf, ?_⟩
  have hlift := hexact.liftFromProjective_comp (fromSingleCycles f) hf
  dsimp at hlift
  calc (singleObjXSelf c j A).inv ≫ f.f j
      = fromSingleCycles f ≫ K.iCycles j := (fromSingleCycles_i f).symm
    _ = (hexact.liftFromProjective (fromSingleCycles f) hf ≫ K.toCycles (c.prev j) j)
          ≫ K.iCycles j := by rw [hlift]
    _ = _ := by rw [assoc, K.toCycles_i]

/-- A map out of a single complex which is a boundary is null homotopic. -/
lemma nonempty_homotopy_zero_of_boundary (f : (single V c j).obj A ⟶ K)
    (β : A ⟶ K.X (c.prev j))
    (hβ : (singleObjXSelf c j A).inv ≫ f.f j = β ≫ K.d (c.prev j) j) :
    Nonempty (Homotopy f 0) := by
  classical
  by_cases hrel : c.Rel (c.prev j) j
  · set hom : ∀ (i k : ι), ((single V c j).obj A).X i ⟶ K.X k := fun i k =>
      if hi : i = j then
        (if hk : c.prev j = k then
          (singleObjXIsoOfEq c j A i hi).hom ≫ β ≫ (K.XIsoOfEq hk).hom else 0)
      else 0 with hom_def
    have hzero : ∀ (i k : ι), ¬ c.Rel k i → hom i k = 0 := by
      intro i k hik
      by_cases hi : i = j
      · subst hi
        by_cases hk : c.prev i = k
        · exact absurd (hk ▸ hrel) hik
        · simp [hom_def, hk]
      · simp [hom_def, hi]
    refine ⟨(Homotopy.ofEq ?_).trans (Homotopy.nullHomotopy hom hzero)⟩
    apply from_single_hom_ext
    have hd : (dNext j) hom = 0 := by simp [dNext, single_obj_d]
    have hp : (prevD j) hom = hom j (c.prev j) ≫ K.d (c.prev j) j := by simp [prevD]
    have hval : hom j (c.prev j) = (singleObjXSelf c j A).hom ≫ β := by
      simp [hom_def, singleObjXSelf]
    show f.f j = (Homotopy.nullHomotopicMap hom).f j
    show f.f j = (dNext j) hom + (prevD j) hom
    rw [hd, hp, hval, zero_add, assoc, ← hβ, Iso.hom_inv_id_assoc]
  · have hd : K.d (c.prev j) j = 0 := K.shape _ _ hrel
    have hf0 : f = 0 := by
      apply from_single_hom_ext
      have h1 : (singleObjXSelf c j A).inv ≫ f.f j = 0 := by rw [hβ, hd, comp_zero]
      have h2 := congrArg (fun x => (singleObjXSelf c j A).hom ≫ x) h1
      simpa using h2
    exact ⟨Homotopy.ofEq hf0⟩

/-- **Homotopy classification.** For a projective object `A`, two chain maps
`A[j] ⟶ K` are chain homotopic if and only if they define the same homology class. -/
theorem nonempty_homotopy_iff_singleHomologyClass_eq [Projective A]
    (f g : (single V c j).obj A ⟶ K) :
    Nonempty (Homotopy f g) ↔ singleHomologyClass f = singleHomologyClass g := by
  constructor
  · rintro ⟨ho⟩
    exact singleHomologyClass_eq_of_homotopy ho
  · intro h
    have h0 : singleHomologyClass (f - g) = 0 := by
      rw [singleHomologyClass_sub, h, sub_self]
    obtain ⟨β, hβ⟩ := exists_boundary_of_singleHomologyClass_eq_zero (f - g) h0
    obtain ⟨ho⟩ := nonempty_homotopy_zero_of_boundary (f - g) β hβ
    exact ⟨Homotopy.equivSubZero.symm ho⟩

/-- **Surjectivity.** For a projective object `A`, every homology class
`A ⟶ K.homology j` is realized by a chain map `A[j] ⟶ K`. -/
theorem singleHomologyClass_surjective [Projective A] (γ : A ⟶ K.homology j) :
    ∃ f : (single V c j).obj A ⟶ K, singleHomologyClass f = γ := by
  set α : A ⟶ K.cycles j := Projective.factorThru γ (K.homologyπ j) with hα
  have hαπ : α ≫ K.homologyπ j = γ := Projective.factorThru_comp _ _
  have hcond : ∀ k, c.Rel j k → (α ≫ K.iCycles j) ≫ K.d j k = 0 := by
    intro k hk
    obtain rfl : c.next j = k := c.next_eq' hk
    simp
  refine ⟨mkHomFromSingle (α ≫ K.iCycles j) hcond, ?_⟩
  have hfc : fromSingleCycles (mkHomFromSingle (α ≫ K.iCycles j) hcond) = α := by
    apply (cancel_mono (K.iCycles j)).1
    rw [fromSingleCycles_i, mkHomFromSingle_f]
    simp
  rw [singleHomologyClass, hfc, hαπ]



section HomotopyCategory

variable (j A K)

/-- The homology class of a morphism in the homotopy category out of a single complex,
computed on any representative. -/
lemma singleHomologyClass_out_eq
    (u : (HomotopyCategory.quotient V c).obj ((single V c j).obj A) ⟶
      (HomotopyCategory.quotient V c).obj K)
    (f : (single V c j).obj A ⟶ K) (hf : (HomotopyCategory.quotient V c).map f = u) :
    singleHomologyClass u.out = singleHomologyClass f :=
  (singleHomologyClass_eq_of_homotopy
    (HomotopyCategory.homotopyOfEq f u.out (by rw [hf, HomotopyCategory.quotient_map_out]))).symm

/-- The additive map sending a morphism `A[j] ⟶ K` in the homotopy category to the
corresponding homology class. -/
noncomputable def homotopyCategoryClassHom :
    ((HomotopyCategory.quotient V c).obj ((single V c j).obj A) ⟶
      (HomotopyCategory.quotient V c).obj K) →+ (A ⟶ K.homology j) where
  toFun u := singleHomologyClass u.out
  map_zero' := by
    rw [singleHomologyClass_out_eq j A K 0 0 (by simp), singleHomologyClass_zero]
  map_add' u v := by
    rw [singleHomologyClass_out_eq j A K (u + v) (u.out + v.out) (by
        rw [Functor.map_add, HomotopyCategory.quotient_map_out,
          HomotopyCategory.quotient_map_out]),
      singleHomologyClass_add]

@[simp]
lemma homotopyCategoryClassHom_quotient_map (f : (single V c j).obj A ⟶ K) :
    homotopyCategoryClassHom j A K ((HomotopyCategory.quotient V c).map f) =
      singleHomologyClass f :=
  singleHomologyClass_out_eq j A K _ f rfl

/-- **Chain complexes modulo homotopy compute homology.**  For a projective object `A`,
the group of morphisms `A[j] ⟶ K` in the homotopy category of chain complexes is
canonically isomorphic to `Hom(A, H_j K)`. -/
noncomputable def homotopyCategoryHomAddEquiv [Projective A] :
    ((HomotopyCategory.quotient V c).obj ((single V c j).obj A) ⟶
      (HomotopyCategory.quotient V c).obj K) ≃+ (A ⟶ K.homology j) := by
  refine AddEquiv.ofBijective (homotopyCategoryClassHom j A K) ⟨?_, ?_⟩
  · rw [injective_iff_map_eq_zero]
    intro u hu
    have h1 : singleHomologyClass u.out = singleHomologyClass (0 : _ ⟶ K) := by
      rw [singleHomologyClass_zero]; exact hu
    obtain ⟨ho⟩ := (nonempty_homotopy_iff_singleHomologyClass_eq u.out 0).2 h1
    rw [← HomotopyCategory.quotient_map_out u, HomotopyCategory.eq_of_homotopy _ _ ho,
      Functor.map_zero]
  · intro γ
    obtain ⟨f, hf⟩ := singleHomologyClass_surjective (K := K) γ
    exact ⟨(HomotopyCategory.quotient V c).map f, by
      rw [homotopyCategoryClassHom_quotient_map, hf]⟩

@[simp]
lemma homotopyCategoryHomAddEquiv_apply [Projective A]
    (f : (single V c j).obj A ⟶ K) :
    homotopyCategoryHomAddEquiv j A K ((HomotopyCategory.quotient V c).map f) =
      singleHomologyClass f :=
  homotopyCategoryClassHom_quotient_map j A K f

end HomotopyCategory


section DerivedCategory

open scoped ZeroObject

variable {C : Type u} [Category.{v} C] [Abelian C]

instance projective_single_obj_X (p n : ℤ) (A : C) [Projective A] :
    Projective (((single C (ComplexShape.up ℤ) p).obj A).X n) := by
  by_cases h : n = p
  · subst h
    exact Projective.of_iso (singleObjXSelf (ComplexShape.up ℤ) n A).symm inferInstance
  · exact Projective.of_iso
      (isZero_single_obj_X (ComplexShape.up ℤ) p A n h).isoZero.symm inferInstance

/-- A single complex on a projective object is K-projective. -/
instance isKProjective_single_obj (p : ℤ) (A : C) [Projective A] :
    CochainComplex.IsKProjective ((single C (ComplexShape.up ℤ) p).obj A) :=
  CochainComplex.isKProjective_of_projective _ p

variable [HasDerivedCategory C]

/-- **The bridge, derived-category form.**  For a projective object `A` of an abelian
category with a derived category, morphisms `A[p] ⟶ K` in the derived category form a
group canonically isomorphic to `Hom(A, H^p K)`.  Combined with
`homotopyCategoryHomAddEquiv`, this says that the passage from the homotopy category
to the derived category loses no information on `A[p]`. -/
noncomputable def derivedCategoryHomAddEquiv (p : ℤ) (A : C) [Projective A]
    (K : CochainComplex C ℤ) :
    (DerivedCategory.Qh.obj
        ((HomotopyCategory.quotient C (ComplexShape.up ℤ)).obj
          ((single C (ComplexShape.up ℤ) p).obj A)) ⟶
      DerivedCategory.Qh.obj ((HomotopyCategory.quotient C (ComplexShape.up ℤ)).obj K)) ≃+
      (A ⟶ K.homology p) :=
  (AddEquiv.ofBijective (DerivedCategory.Qh.mapAddHom)
    (CochainComplex.IsKProjective.Qh_map_bijective
      ((single C (ComplexShape.up ℤ) p).obj A) _)).symm.trans
    (homotopyCategoryHomAddEquiv p A K)

end DerivedCategory


section SingularHomology

open AlgebraicTopology

variable (R : Type u) [Ring R] (n : ℕ) (X : TopCat.{u})

/-- The singular chain complex of a space `X` with coefficients in the ring `R`,
as a chain complex of `R`-modules. -/
noncomputable abbrev singularChains : ChainComplex (ModuleCat.{u} R) ℕ :=
  ((singularChainComplexFunctor (ModuleCat.{u} R)).obj (ModuleCat.of R R)).obj X

lemma singularHomology_eq_homology :
    ((singularHomologyFunctor (ModuleCat.{u} R) n).obj (ModuleCat.of R R)).obj X =
      (singularChains R X).homology n := rfl

/-- **Topological bridge.**  The `n`-th singular homology of a topological space `X`
with coefficients in `R` is the group of morphisms `R[n] ⟶ C_*(X; R)` in the homotopy
category of chain complexes of `R`-modules; i.e. singular homology is computed by
maps out of a single complex modulo chain homotopy. -/
noncomputable def singularHomologyHomotopyCategoryAddEquiv :
    ((HomotopyCategory.quotient (ModuleCat.{u} R) (ComplexShape.down ℕ)).obj
        ((single (ModuleCat.{u} R) (ComplexShape.down ℕ) n).obj (ModuleCat.of R R)) ⟶
      (HomotopyCategory.quotient (ModuleCat.{u} R) (ComplexShape.down ℕ)).obj
        (singularChains R X)) ≃+
      (ModuleCat.of R R ⟶
        ((singularHomologyFunctor (ModuleCat.{u} R) n).obj (ModuleCat.of R R)).obj X) :=
  homotopyCategoryHomAddEquiv n (ModuleCat.of R R) (singularChains R X)

/-- `Hom_R(R, M) ≃+ M`. -/
noncomputable def moduleCatHomSelfAddEquiv (M : ModuleCat.{u} R) :
    (ModuleCat.of R R ⟶ M) ≃+ M where
  toFun f := f.hom 1
  invFun m := ModuleCat.ofHom (LinearMap.toSpanSingleton R M m)
  left_inv f := by ext; simp [LinearMap.toSpanSingleton]
  right_inv m := by simp [LinearMap.toSpanSingleton]
  map_add' f g := rfl

/-- **Topological bridge, explicit form.**  The `n`-th singular homology module of `X`
with coefficients in `R` is isomorphic, as an abelian group, to the group of homotopy
classes of chain maps `R[n] ⟶ C_*(X; R)`. -/
noncomputable def singularHomologyAddEquiv :
    ((HomotopyCategory.quotient (ModuleCat.{u} R) (ComplexShape.down ℕ)).obj
        ((single (ModuleCat.{u} R) (ComplexShape.down ℕ) n).obj (ModuleCat.of R R)) ⟶
      (HomotopyCategory.quotient (ModuleCat.{u} R) (ComplexShape.down ℕ)).obj
        (singularChains R X)) ≃+
      ((singularHomologyFunctor (ModuleCat.{u} R) n).obj (ModuleCat.of R R)).obj X :=
  (singularHomologyHomotopyCategoryAddEquiv R n X).trans
    (moduleCatHomSelfAddEquiv R _)

end SingularHomology

end Catalog.Bridges
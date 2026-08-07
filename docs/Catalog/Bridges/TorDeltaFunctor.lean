import Mathlib
import Bridges.UniversalCoefficients

/-!
# Tor as a universal (coeffaceable) homological δ-functor

This file is the homological counterpart of `Catalog/Bridges/ExtDeltaFunctor.lean`.

Main contents:

* `Catalog.Bridges.HomologicalDeltaFunctor` : a homological δ-functor between abelian
  categories, i.e. a family of additive functors `F n` together with connecting
  morphisms `F (n+1) X₃ ⟶ F n X₁` for short exact sequences and the long exact
  sequence axioms;
* `Catalog.Bridges.HomologicalDeltaFunctor.Hom.ext_of_app_zero` : **universality
  (uniqueness)** — if the *target* δ-functor is coeffaceable (vanishes in positive
  degrees on projective objects) then two morphisms of δ-functors into it which agree
  in degree `0` agree in every degree.
-/

universe v u v' u'

namespace Catalog.Bridges

open CategoryTheory Category Limits

variable (C : Type u) [Category.{v} C] [Abelian C] (D : Type u') [Category.{v'} D] [Abelian D]

/-- A homological δ-functor from an abelian category `C` to an abelian category `D`:
a family of additive functors `F n` together with connecting maps `δ` associated with
short exact sequences, satisfying the long exact sequence axioms. -/
structure HomologicalDeltaFunctor where
  /-- the underlying family of functors -/
  F : ℕ → C ⥤ D
  /-- each functor is additive -/
  additive : ∀ n, (F n).Additive
  /-- the connecting morphism -/
  δ : ∀ {S : ShortComplex C}, S.ShortExact → ∀ n : ℕ, (F (n + 1)).obj S.X₃ ⟶ (F n).obj S.X₁
  /-- `F (n+1) (g) ≫ δ = 0` -/
  zero₃ : ∀ {S : ShortComplex C} (hS : S.ShortExact) (n : ℕ),
    (F (n + 1)).map S.g ≫ δ hS n = 0
  /-- `δ ≫ F n (f) = 0` -/
  zero₁ : ∀ {S : ShortComplex C} (hS : S.ShortExact) (n : ℕ),
    δ hS n ≫ (F n).map S.f = 0
  /-- exactness at `F (n+1) (X₃)` -/
  exact₃ : ∀ {S : ShortComplex C} (hS : S.ShortExact) (n : ℕ),
    (ShortComplex.mk ((F (n + 1)).map S.g) (δ hS n) (zero₃ hS n)).Exact
  /-- exactness at `F n (X₁)` -/
  exact₁ : ∀ {S : ShortComplex C} (hS : S.ShortExact) (n : ℕ),
    (ShortComplex.mk (δ hS n) ((F n).map S.f) (zero₁ hS n)).Exact
  /-- exactness at `F n (X₂)` -/
  exact₂ : ∀ {S : ShortComplex C} (_ : S.ShortExact) (n : ℕ),
    (ShortComplex.mk ((F n).map S.f) ((F n).map S.g) (by
      rw [← Functor.map_comp, S.zero]
      have := additive n
      exact Functor.map_zero _ _ _)).Exact

namespace HomologicalDeltaFunctor

variable {C D}

/-- A morphism of homological δ-functors: natural transformations in each degree
commuting with the connecting maps. -/
structure Hom (S T : HomologicalDeltaFunctor C D) where
  /-- the natural transformation in degree `n` -/
  app : ∀ n : ℕ, S.F n ⟶ T.F n
  /-- compatibility with the connecting morphisms -/
  comm : ∀ {W : ShortComplex C} (hW : W.ShortExact) (n : ℕ),
    (app (n + 1)).app W.X₃ ≫ T.δ hW n = S.δ hW n ≫ (app n).app W.X₁

/-- The identity morphism of δ-functors. -/
@[simps]
def Hom.id (T : HomologicalDeltaFunctor C D) : T.Hom T where
  app _ := 𝟙 _
  comm _ _ := by simp

/-- A homological δ-functor is *coeffaceable* if it vanishes in positive degrees on
projective objects. -/
def Coeffaceable (T : HomologicalDeltaFunctor C D) : Prop :=
  ∀ (P : C) (_ : Projective P) (n : ℕ), IsZero ((T.F (n + 1)).obj P)

section

variable [EnoughProjectives C]

/-- The canonical short exact sequence `0 → ker π → P → Y → 0` covering `Y` by a
projective object. -/
noncomputable def projectiveCover (Y : C) : ShortComplex C :=
  ShortComplex.mk (kernel.ι (Projective.π Y)) (Projective.π Y) (kernel.condition _)

lemma projectiveCover_shortExact (Y : C) : (projectiveCover Y).ShortExact where
  exact := ShortComplex.exact_of_f_is_kernel _ (kernelIsKernel _)
  mono_f := by dsimp [projectiveCover]; infer_instance
  epi_g := by dsimp [projectiveCover]; infer_instance

/-- For a coeffaceable δ-functor, the connecting map out of a projective cover is a
monomorphism. -/
lemma mono_delta_projectiveCover {T : HomologicalDeltaFunctor C D} (hT : T.Coeffaceable)
    (Y : C) (n : ℕ) : Mono (T.δ (projectiveCover_shortExact Y) n) := by
  refine (ShortComplex.exact_iff_mono _ ?_).1 (T.exact₃ (projectiveCover_shortExact Y) n)
  exact (hT (Projective.over Y) inferInstance n).eq_of_src _ 0

/-- **Universality of coeffaceable homological δ-functors (uniqueness).**  Two morphisms
of δ-functors *into* a coeffaceable δ-functor which agree in degree `0` agree in all
degrees. -/
theorem Hom.ext_of_app_zero {S T : HomologicalDeltaFunctor C D} (hT : T.Coeffaceable)
    (φ ψ : S.Hom T) (h0 : φ.app 0 = ψ.app 0) : ∀ n, φ.app n = ψ.app n := by
  intro n
  induction n with
  | zero => exact h0
  | succ n ih =>
    ext Y
    haveI := mono_delta_projectiveCover hT Y n
    rw [← cancel_mono (T.δ (projectiveCover_shortExact Y) n)]
    rw [show Y = (projectiveCover Y).X₃ from rfl]
    rw [φ.comm (projectiveCover_shortExact Y) n, ψ.comm (projectiveCover_shortExact Y) n, ih]

end

end HomologicalDeltaFunctor

/-!
### `Tor` as a coeffaceable homological δ-functor

Fix a module `N` over a commutative ring `R` and a projective resolution `P_•` of `N`.
The functors `M ↦ H_n(M ⊗ P_•)` compute `Tor_n(M, N)`; we show that they assemble into a
homological δ-functor in the variable `M` which is coeffaceable, hence universal.
-/

section Tor

open MonoidalCategory BraidedCategory

variable {R : Type u} [CommRing R]

/-- The functor `M ↦ M ⊗ P_•` from modules to chain complexes, for a fixed complex `P_•`. -/
noncomputable def tensorRes (P : ChainComplex (ModuleCat.{u} R) ℕ) :
    ModuleCat.{u} R ⥤ ChainComplex (ModuleCat.{u} R) ℕ where
  obj M := ((tensorLeft M).mapHomologicalComplex _).obj P
  map f := (NatTrans.mapHomologicalComplex ((tensoringLeft (ModuleCat.{u} R)).map f) _).app P
  map_id := by intro M; simp
  map_comp := by intros; simp

instance additive_tensorRes (P : ChainComplex (ModuleCat.{u} R) ℕ) : (tensorRes P).Additive where
  map_add := by
    intros
    ext i
    simp [tensorRes, MonoidalPreadditive.add_whiskerRight]

/-- Tensoring on the right with a flat module preserves finite limits. -/
noncomputable instance preservesFiniteLimits_tensorRight_of_flat (Q : ModuleCat.{u} R)
    [Module.Flat R Q] : Limits.PreservesFiniteLimits (tensorRight Q) := by
  haveI := (Module.Flat.iff_preservesFiniteLimits_tensorLeft Q).1 inferInstance
  exact Limits.preservesFiniteLimits_of_natIso (tensorLeftIsoTensorRight Q)

noncomputable instance preservesFiniteColimits_tensorRight (Q : ModuleCat.{u} R) :
    Limits.PreservesFiniteColimits (tensorRight Q) :=
  Limits.preservesFiniteColimits_of_natIso (tensorLeftIsoTensorRight Q)

/-- Tensoring a short exact sequence of modules with a degreewise flat complex gives a short
exact sequence of complexes. -/
lemma shortExact_map_tensorRes (P : ChainComplex (ModuleCat.{u} R) ℕ)
    (hP : ∀ i, Module.Flat R (P.X i)) {S : ShortComplex (ModuleCat.{u} R)} (hS : S.ShortExact) :
    (S.map (tensorRes P)).ShortExact := by
  apply HomologicalComplex.shortExact_of_degreewise_shortExact
  intro i
  haveI := hP i
  exact hS.map_of_exact (tensorRight (P.X i))

variable {N : ModuleCat.{u} R}

/-- The homological δ-functor `M ↦ H_n(M ⊗ P_•)` associated with a projective resolution
`P_•` of `N`.  Its degree-`n` part computes `Tor_n(-, N)`
(see `Catalog.Bridges.torDeltaFunctor_iso_Tor`). -/
noncomputable def torDeltaFunctor (P : ProjectiveResolution N) :
    HomologicalDeltaFunctor (ModuleCat.{u} R) (ModuleCat.{u} R) where
  F n := tensorRes P.complex ⋙ HomologicalComplex.homologyFunctor _ _ n
  additive n := inferInstance
  δ hS n := (shortExact_map_tensorRes P.complex (fun i => inferInstance) hS).δ (n + 1) n (by simp)
  zero₃ hS n := (shortExact_map_tensorRes P.complex (fun i => inferInstance) hS).comp_δ
    (n + 1) n (by simp)
  zero₁ hS n := (shortExact_map_tensorRes P.complex (fun i => inferInstance) hS).δ_comp
    (n + 1) n (by simp)
  exact₃ hS n := (shortExact_map_tensorRes P.complex (fun i => inferInstance) hS).homology_exact₃
    (n + 1) n (by simp)
  exact₁ hS n := (shortExact_map_tensorRes P.complex (fun i => inferInstance) hS).homology_exact₁
    (n + 1) n (by simp)
  exact₂ hS n := ShortComplex.ShortExact.homology_exact₂
    (shortExact_map_tensorRes P.complex (fun i => inferInstance) hS) n

/-- **Flat modules are acyclic for the `Tor` δ-functor.**  If `Q` is flat then
`H_{n+1}(Q ⊗ P_•) = 0`: tensoring with a flat module commutes with homology, and the
resolution `P_•` is exact in positive degrees. -/
lemma isZero_torDeltaFunctor_succ_of_flat (P : ProjectiveResolution N) (Q : ModuleCat.{u} R)
    [Module.Flat R Q] (n : ℕ) : IsZero (((torDeltaFunctor P).F (n + 1)).obj Q) := by
  show IsZero ((((tensorLeft Q).mapHomologicalComplex (ComplexShape.down ℕ)).obj
    P.complex).homology (n + 1))
  refine IsZero.of_iso ?_ (mapHomologicalComplexHomologyIso (tensorLeft Q) P.complex (n + 1))
  exact Functor.map_isZero _
    ((HomologicalComplex.exactAt_iff_isZero_homology _ _).1 (P.complex_exactAt_succ n))

/-- **`Tor` vanishes in positive degrees on projectives in the *underived* variable.**
This is one half of the balancing of `Tor`: the δ-functor `M ↦ H_*(M ⊗ P_•)`, which is
derived in the second variable, nevertheless vanishes on projective `M` in positive
degrees, because a projective module is flat. -/
lemma torDeltaFunctor_coeffaceable (P : ProjectiveResolution N) :
    (torDeltaFunctor P).Coeffaceable := fun Q hQ n =>
  have : Projective Q := hQ
  have : Module.Flat R Q := inferInstance
  isZero_torDeltaFunctor_succ_of_flat P Q n

/-- **`Tor` is a universal δ-functor.**  Two morphisms of homological δ-functors into
`Tor_*(-, N)` which agree in degree `0` agree in every degree. -/
theorem torDeltaFunctor_universal (P : ProjectiveResolution N)
    {S : HomologicalDeltaFunctor (ModuleCat.{u} R) (ModuleCat.{u} R)}
    (φ ψ : S.Hom (torDeltaFunctor P)) (h0 : φ.app 0 = ψ.app 0) : ∀ n, φ.app n = ψ.app n :=
  HomologicalDeltaFunctor.Hom.ext_of_app_zero (torDeltaFunctor_coeffaceable P) φ ψ h0

/-- **Rigidity of `Tor`.**  An endomorphism of the δ-functor `Tor_*(-, N)` which is the
identity in degree `0` is the identity in every degree. -/
theorem torDeltaFunctor_endo_eq_id (P : ProjectiveResolution N)
    (φ : (torDeltaFunctor P).Hom (torDeltaFunctor P)) (h0 : φ.app 0 = 𝟙 _) (n : ℕ) :
    φ.app n = 𝟙 _ :=
  torDeltaFunctor_universal P φ (HomologicalDeltaFunctor.Hom.id _) h0 n

/-- The degree-`n` part of `torDeltaFunctor P` is Mathlib's `Tor _ n (-) N`, naturally in
the first variable. -/
noncomputable def torDeltaFunctor_iso_Tor (P : ProjectiveResolution N) (n : ℕ) :
    (Tor (ModuleCat.{u} R) n).flip.obj N ≅ (torDeltaFunctor P).F n :=
  NatIso.ofComponents (fun M => (show ((Tor (ModuleCat.{u} R) n).flip.obj N).obj M ≅
      ((torDeltaFunctor P).F n).obj M from P.isoLeftDerivedObj (tensorLeft M) n)) (by
    intro M M' f
    dsimp [torDeltaFunctor]
    rw [ProjectiveResolution.leftDerived_app_eq _ P n]
    simp [tensorRes])

/-- Naturality of `ProjectiveResolution.fromLeftDerivedZero'` in the *functor* variable:
a natural transformation `α : F ⟶ G` is compatible with the canonical maps from the
degree-`0` opcycles of the resolved complexes. -/
lemma fromLeftDerivedZero'_natTrans_naturality {C₁ : Type u} [Category.{v} C₁] [Abelian C₁]
    [EnoughProjectives C₁] {D₁ : Type u'} [Category.{v'} D₁] [Abelian D₁]
    {F G : C₁ ⥤ D₁} [F.Additive] [G.Additive] (α : F ⟶ G) {X : C₁}
    (P : ProjectiveResolution X) :
    HomologicalComplex.opcyclesMap
          ((NatTrans.mapHomologicalComplex α (ComplexShape.down ℕ)).app P.complex) 0 ≫
        P.fromLeftDerivedZero' G = P.fromLeftDerivedZero' F ≫ α.app X := by
  rw [← cancel_epi (HomologicalComplex.pOpcycles _ 0)]
  rw [HomologicalComplex.p_opcyclesMap_assoc,
    ProjectiveResolution.pOpcycles_comp_fromLeftDerivedZero',
    ProjectiveResolution.pOpcycles_comp_fromLeftDerivedZero'_assoc]
  dsimp
  exact (α.naturality (P.π.f 0)).symm

/-- The specialisation of `fromLeftDerivedZero'_natTrans_naturality` to tensoring. -/
lemma opcyclesMap_tensorRes_fromLeftDerivedZero' (P : ProjectiveResolution N)
    {M M' : ModuleCat.{u} R} (f : M ⟶ M') :
    HomologicalComplex.opcyclesMap ((tensorRes P.complex).map f) 0 ≫
        P.fromLeftDerivedZero' (tensorLeft M') =
      P.fromLeftDerivedZero' (tensorLeft M) ≫ f ▷ N :=
  fromLeftDerivedZero'_natTrans_naturality ((tensoringLeft (ModuleCat.{u} R)).map f) P

/-- **Degree zero of the `Tor` δ-functor is the tensor product.**  `Tor_0(-, N) ≅ - ⊗ N`,
naturally in the first variable; together with `torDeltaFunctor_universal` this says that
`Tor_*(-, N)` is the universal δ-functor extending `- ⊗ N`. -/
noncomputable def torDeltaFunctor_zero_iso (P : ProjectiveResolution N) :
    (torDeltaFunctor P).F 0 ≅ tensorRight N :=
  NatIso.ofComponents
    (fun M => (show ((torDeltaFunctor P).F 0).obj M ≅ (tensorRight N).obj M from
      ChainComplex.isoHomologyι₀ _ ≪≫ asIso (P.fromLeftDerivedZero' (tensorLeft M))))
    (by
      intro M M' f
      dsimp
      rw [show ((torDeltaFunctor P).F 0).map f =
          HomologicalComplex.homologyMap ((tensorRes P.complex).map f) 0 from rfl,
        HomologicalComplex.homologyι_naturality_assoc,
        opcyclesMap_tensorRes_fromLeftDerivedZero' P f, assoc])

/-- **Balancing of `Tor` on projectives.**  For a projective module `Q` and any module `N`,
`Tor_{n+1}(Q, N) = 0`, even though `Tor` is defined by deriving the *second* variable. -/
theorem isZero_Tor_succ_of_projective_left (Q N : ModuleCat.{u} R) [Projective Q] (n : ℕ) :
    IsZero (((Tor (ModuleCat.{u} R) (n + 1)).obj Q).obj N) := by
  obtain ⟨⟨P⟩⟩ := (inferInstance : HasProjectiveResolution N)
  exact IsZero.of_iso (torDeltaFunctor_coeffaceable P Q inferInstance n)
    ((torDeltaFunctor_iso_Tor P (n + 1)).app Q)

/-- **Flat modules are `Tor`-acyclic in the underived variable.**  For a flat module `M`
and any module `N`, `Tor_{n+1}(M, N) = 0`.  Mathlib's `Tor` is defined by deriving the
*second* variable, so this is not a formal consequence of the definition; it is proved
here by exactness of `M ⊗ -` on a projective resolution of `N`. -/
theorem isZero_Tor_succ_of_flat_left (M N : ModuleCat.{u} R) [Module.Flat R M] (n : ℕ) :
    IsZero (((Tor (ModuleCat.{u} R) (n + 1)).obj M).obj N) := by
  obtain ⟨⟨P⟩⟩ := (inferInstance : HasProjectiveResolution N)
  exact IsZero.of_iso (isZero_torDeltaFunctor_succ_of_flat P M n)
    ((torDeltaFunctor_iso_Tor P (n + 1)).app M)

/-!
### A `Tor` criterion for flatness

Mathlib defines `Tor` by deriving the second variable and (at the time of writing) does
not relate it to flatness.  Using the δ-functor structure in the *first* variable we
prove both directions of the classical criterion: `N` is flat if and only if
`Tor_1(M, N) = 0` for every `M`.
-/

/-- Right-tensoring is described on underlying linear maps by `LinearMap.rTensor`. -/
lemma tensorRight_map_eq (Q : ModuleCat.{u} R) {A B : ModuleCat.{u} R} (f : A ⟶ B) :
    (tensorRight Q).map f = ModuleCat.ofHom (LinearMap.rTensor Q f.hom) := rfl

instance preservesEpimorphisms_tensorRight (Q : ModuleCat.{u} R) :
    (tensorRight Q).PreservesEpimorphisms where
  preserves {A B} f hf := by
    rw [tensorRight_map_eq, ModuleCat.epi_iff_surjective]
    exact LinearMap.rTensor_surjective _ ((ModuleCat.epi_iff_surjective f).1 hf)

/-- Tensoring on the right with a flat module preserves monomorphisms. -/
lemma mono_tensorRight_map_of_flat (Q : ModuleCat.{u} R) [Module.Flat R Q]
    {A B : ModuleCat.{u} R} (f : A ⟶ B) [Mono f] : Mono ((tensorRight Q).map f) := by
  rw [tensorRight_map_eq, ModuleCat.mono_iff_injective]
  exact Module.Flat.rTensor_preserves_injective_linearMap _
    ((ModuleCat.mono_iff_injective f).1 ‹_›)

/-- Transport of monomorphisms through the degree-zero identification of the `Tor`
δ-functor. -/
lemma mono_torDeltaFunctor_zero_map (P : ProjectiveResolution N) [Module.Flat R N]
    {A B : ModuleCat.{u} R} (f : A ⟶ B) [Mono f] :
    Mono (((torDeltaFunctor P).F 0).map f) := by
  have hnat := (torDeltaFunctor_zero_iso P).hom.naturality f
  haveI hmf : Mono ((tensorRight N).map f) := mono_tensorRight_map_of_flat N f
  haveI : Mono (((torDeltaFunctor P).F 0).map f ≫ (torDeltaFunctor_zero_iso P).hom.app B) := by
    rw [hnat]
    exact @mono_comp _ _ _ _ _ _ (IsIso.mono_of_iso _) _ hmf
  exact mono_of_mono _ ((torDeltaFunctor_zero_iso P).hom.app B)

/-- **Flatness in the derived variable kills `Tor₁`.**  If `N` is flat then
`Tor_1(M, N) = 0` for every `M`.  The proof runs the long exact sequence of the δ-functor
in the *first* variable on a projective presentation of `M`. -/
theorem isZero_Tor_one_of_flat_right (M N : ModuleCat.{u} R) [Module.Flat R N] :
    IsZero (((Tor (ModuleCat.{u} R) 1).obj M).obj N) := by
  obtain ⟨⟨P⟩⟩ := (inferInstance : HasProjectiveResolution N)
  refine IsZero.of_iso ?_ ((torDeltaFunctor_iso_Tor P 1).app M)
  set T := torDeltaFunctor P with hT
  have hS := HomologicalDeltaFunctor.projectiveCover_shortExact (C := ModuleCat.{u} R) M
  -- the connecting map out of `T.F 1 M` is a monomorphism
  haveI hmono : Mono (T.δ hS 0) := by
    refine (ShortComplex.exact_iff_mono _ ?_).1 (T.exact₃ hS 0)
    exact (isZero_torDeltaFunctor_succ_of_flat P (Projective.over M) 0).eq_of_src _ 0
  -- but it is zero, because tensoring the monomorphism `ker π ⟶ P` with the flat module
  -- `N` stays a monomorphism
  have hf : Mono ((T.F 0).map (HomologicalDeltaFunctor.projectiveCover M).f) := by
    haveI : Mono (HomologicalDeltaFunctor.projectiveCover M).f := hS.mono_f
    exact mono_torDeltaFunctor_zero_map P _
  have hzero : T.δ hS 0 = 0 := by
    haveI := hf
    exact (cancel_mono ((T.F 0).map (HomologicalDeltaFunctor.projectiveCover M).f)).1
      (by simpa using T.zero₁ hS 0)
  rw [IsZero.iff_id_eq_zero]
  exact (cancel_mono (T.δ hS 0)).1 (by rw [hzero, comp_zero, zero_comp])

/-- Tensoring a short exact sequence with `N` stays short exact as soon as `Tor_1(-, N)`
vanishes identically. -/
lemma shortExact_map_tensorRight_of_isZero_tor_one (P : ProjectiveResolution N)
    (h : ∀ M : ModuleCat.{u} R, IsZero (((torDeltaFunctor P).F 1).obj M))
    {S : ShortComplex (ModuleCat.{u} R)} (hS : S.ShortExact) :
    (S.map (tensorRight N)).ShortExact := by
  haveI := (torDeltaFunctor P).additive 0
  have hmono : Mono (((torDeltaFunctor P).F 0).map S.f) := by
    refine (ShortComplex.exact_iff_mono _ ?_).1 ((torDeltaFunctor P).exact₁ hS 0)
    exact (h S.X₃).eq_of_src _ 0
  have hmf : Mono (S.map (tensorRight N)).f := by
    have hnat := (torDeltaFunctor_zero_iso P).hom.naturality S.f
    have heq : (tensorRight N).map S.f =
        inv ((torDeltaFunctor_zero_iso P).hom.app S.X₁) ≫
          ((torDeltaFunctor P).F 0).map S.f ≫ (torDeltaFunctor_zero_iso P).hom.app S.X₂ := by
      rw [hnat, IsIso.inv_hom_id_assoc]
    haveI := hmono
    rw [show (S.map (tensorRight N)).f = (tensorRight N).map S.f from rfl, heq]
    exact @mono_comp _ _ _ _ _ _ (IsIso.mono_of_iso _) _
      (@mono_comp _ _ _ _ _ _ hmono _ (IsIso.mono_of_iso _))
  have heg : Epi (S.map (tensorRight N)).g := by
    haveI := hS.epi_g
    exact inferInstanceAs (Epi ((tensorRight N).map S.g))
  have hex : (S.map (tensorRight N)).Exact :=
    ShortComplex.exact_of_iso (S.mapNatIso (torDeltaFunctor_zero_iso P))
      ((torDeltaFunctor P).exact₂ hS 0)
  exact { mono_f := hmf, epi_g := heg, exact := hex }

/-- **Vanishing of `Tor₁` forces flatness.** -/
theorem flat_of_isZero_Tor_one (N : ModuleCat.{u} R)
    (h : ∀ M : ModuleCat.{u} R, IsZero (((Tor (ModuleCat.{u} R) 1).obj M).obj N)) :
    Module.Flat R N := by
  obtain ⟨⟨P⟩⟩ := (inferInstance : HasProjectiveResolution N)
  have h' : ∀ M : ModuleCat.{u} R, IsZero (((torDeltaFunctor P).F 1).obj M) := fun M =>
    IsZero.of_iso (h M) ((torDeltaFunctor_iso_Tor P 1).app M).symm
  have hF : ∀ (S : ShortComplex (ModuleCat.{u} R)), S.ShortExact →
      (S.map (tensorRight N)).ShortExact := fun S hS =>
    shortExact_map_tensorRight_of_isZero_tor_one P h' hS
  have h4 : Limits.PreservesFiniteLimits (tensorRight N) ∧
      Limits.PreservesFiniteColimits (tensorRight N) :=
    ((Functor.exact_tfae (tensorRight N)).out 0 3).1 hF
  haveI := h4.1
  exact (Module.Flat.iff_preservesFiniteLimits_tensorLeft N).2
    (Limits.preservesFiniteLimits_of_natIso (tensorLeftIsoTensorRight N).symm)

/-- **`Tor` criterion for flatness.**  A module `N` is flat if and only if `Tor_1(M, N)`
vanishes for every module `M`. -/
theorem flat_iff_isZero_Tor_one (N : ModuleCat.{u} R) :
    Module.Flat R N ↔ ∀ M : ModuleCat.{u} R, IsZero (((Tor (ModuleCat.{u} R) 1).obj M).obj N) :=
  ⟨fun _ M => isZero_Tor_one_of_flat_right M N, flat_of_isZero_Tor_one N⟩

end Tor

end Catalog.Bridges
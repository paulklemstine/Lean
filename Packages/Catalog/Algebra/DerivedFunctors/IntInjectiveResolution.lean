import Algebra.DerivedFunctors.ZModResolution

/-!
# An explicit injective resolution of `ℤ`

Dually to the projective resolution of `ZMod k` constructed in
`Algebra.DerivedFunctors.ZModResolution`, we upgrade the short exact sequence
`0 → ℤ → ℚ → ℚ⧸ℤ → 0` of `Algebra.DerivedFunctors.Resolutions` to a bundled
`CategoryTheory.InjectiveResolution (ModuleCat.of ℤ ℤ)`: the cochain complex

`ℚ → ℚ⧸ℤ → 0 → 0 → ⋯`

of divisible (hence injective) `ℤ`-modules, together with the quasi-isomorphism from `ℤ`
concentrated in degree `0`.

The main results are:

* `Catalog.DerivedFunctors.intInjectiveResolution`: the bundled injective resolution;
* `Catalog.DerivedFunctors.isZero_rightDerived_of_two_le`: consequently, for *every* additive
  functor `F` out of `ℤ`-modules, the right derived functors `Rⁿ⁺²F` vanish on `ℤ`.
-/

open CategoryTheory Limits ZeroObject HomologicalComplex

namespace Catalog.DerivedFunctors

/-- The underlying objects of the injective resolution of `ℤ`: `ℚ` in degree `0`, `ℚ⧸ℤ` in
degree `1`, and `0` afterwards. -/
noncomputable def injX : ℕ → ModuleCat.{0} ℤ
  | 0 => ModuleCat.of ℤ ℚ
  | 1 => ModuleCat.of ℤ QmodZ
  | (_ + 2) => 0

/-- The differentials of the injective resolution: the projection `ℚ → ℚ⧸ℤ` in degree zero,
zero afterwards. -/
noncomputable def injd : ∀ n, injX n ⟶ injX (n + 1)
  | 0 => projQ
  | (_ + 1) => 0

/-- The two-term complex of injective `ℤ`-modules `ℚ → ℚ⧸ℤ → 0 → ⋯`. -/
noncomputable def injComplex : CochainComplex (ModuleCat.{0} ℤ) ℕ :=
  CochainComplex.of injX injd (by
    intro n
    cases n with
    | zero => simp [injd]
    | succ m => simp [injd])

lemma injComplex_d_zero_one : injComplex.d 0 1 = projQ :=
  CochainComplex.of_d _ _ _ 0

lemma isZero_injComplex_X (n : ℕ) : IsZero (injComplex.X (n + 2)) :=
  isZero_zero _

lemma injective_injComplex_X (n : ℕ) : Injective (injComplex.X n) := by
  match n with
  | 0 => exact inferInstanceAs (Injective (ModuleCat.of ℤ ℚ))
  | 1 => exact inferInstanceAs (Injective (ModuleCat.of ℤ QmodZ))
  | (_ + 2) => exact inferInstanceAs (Injective (0 : ModuleCat.{0} ℤ))

/-- The augmentation from `ℤ` placed in degree `0` to the complex `ℚ → ℚ⧸ℤ → 0 → ⋯`. -/
noncomputable def injIota :
    (CochainComplex.single₀ (ModuleCat.{0} ℤ)).obj (ModuleCat.of ℤ ℤ) ⟶ injComplex :=
  (CochainComplex.fromSingle₀Equiv _ _).symm ⟨iotaQ, by
    rw [injComplex_d_zero_one]; exact iotaQ_comp_projQ⟩

lemma injIota_f_zero : injIota.f 0 = iotaQ := by
  simp [injIota]

/-- The augmentation is an isomorphism on cycles in degree zero: both `injComplex.cycles 0`
and `ℤ` are kernels of the projection `ℚ → ℚ⧸ℤ`. -/
theorem isIso_cyclesMap_injIota : IsIso (cyclesMap injIota 0) := by
  haveI : Mono qShortComplex.f := qShortComplex_shortExact.mono_f
  have hd : injComplex.d 0 1 = projQ := injComplex_d_zero_one
  have hker := injComplex.cyclesIsKernel 0 1 (by simp)
  have hker2 := qShortComplex_shortExact.exact.fIsKernel
  have hz : iotaQ ≫ injComplex.d 0 1 = 0 := by rw [hd]; exact iotaQ_comp_projQ
  have hz2 : injComplex.iCycles 0 ≫ projQ = 0 := by rw [← hd]; simp
  set γ := hker.lift (KernelFork.ofι iotaQ hz) with hγ
  set δ := hker2.lift (KernelFork.ofι (injComplex.iCycles 0) hz2) with hδ
  have h1 : γ ≫ injComplex.iCycles 0 = iotaQ := Fork.IsLimit.lift_ι hker
  have h2 : δ ≫ iotaQ = injComplex.iCycles 0 := Fork.IsLimit.lift_ι hker2
  have hγδ : γ ≫ δ = 𝟙 _ := by
    apply Fork.IsLimit.hom_ext hker2
    show (γ ≫ δ) ≫ iotaQ = 𝟙 _ ≫ iotaQ
    rw [Category.assoc, h2, h1, Category.id_comp]
  have hδγ : δ ≫ γ = 𝟙 _ := by
    apply Fork.IsLimit.hom_ext hker
    show (δ ≫ γ) ≫ injComplex.iCycles 0 = 𝟙 _ ≫ injComplex.iCycles 0
    rw [Category.assoc, h1, h2, Category.id_comp]
  haveI : IsIso γ := ⟨δ, hγδ, hδγ⟩
  have hLd : ((CochainComplex.single₀ (ModuleCat.{0} ℤ)).obj (ModuleCat.of ℤ ℤ)).d 0 1 = 0 := by
    simp
  set eL := ((CochainComplex.single₀ (ModuleCat.{0} ℤ)).obj
    (ModuleCat.of ℤ ℤ)).iCyclesIso 0 1 (by simp) hLd with heL
  have key : cyclesMap injIota 0 = eL.hom ≫ γ := by
    apply Fork.IsLimit.hom_ext hker
    show cyclesMap injIota 0 ≫ injComplex.iCycles 0 = (eL.hom ≫ γ) ≫ injComplex.iCycles 0
    rw [cyclesMap_i, Category.assoc, h1, injIota_f_zero]
    simp [heL]
  rw [key]
  infer_instance

theorem quasiIsoAt_injIota_zero : QuasiIsoAt injIota 0 := by
  haveI := isIso_cyclesMap_injIota
  rw [quasiIsoAt_iff_isIso_homologyMap]
  have hnat := CochainComplex.isoHomologyπ₀_inv_naturality injIota
  have key : homologyMap injIota 0 =
      ((CochainComplex.single₀ (ModuleCat.{0} ℤ)).obj (ModuleCat.of ℤ ℤ)).isoHomologyπ₀.inv ≫
        cyclesMap injIota 0 ≫ injComplex.isoHomologyπ₀.hom := by
    rw [← Category.assoc, ← hnat, Category.assoc, Iso.inv_hom_id, Category.comp_id]
  rw [key]
  infer_instance

theorem quasiIsoAt_injIota_succ (n : ℕ) : QuasiIsoAt injIota (n + 1) := by
  rw [quasiIsoAt_iff_exactAt injIota (n + 1) (CochainComplex.exactAt_succ_single_obj _ n)]
  match n with
  | 0 =>
    rw [HomologicalComplex.exactAt_iff' _ 0 1 2 (by simp) (by simp),
      ShortComplex.moduleCat_exact_iff]
    intro x _
    obtain ⟨y, hy⟩ := QuotientAddGroup.mk_surjective (show QmodZ from x)
    refine ⟨y, ?_⟩
    show (ModuleCat.Hom.hom (injComplex.d 0 1)) y = x
    rw [injComplex_d_zero_one]
    exact hy
  | (m + 1) =>
    rw [HomologicalComplex.exactAt_iff]
    exact ShortComplex.exact_of_isZero_X₂ _ (isZero_injComplex_X m)

instance quasiIso_injIota : QuasiIso injIota where
  quasiIsoAt n := by
    match n with
    | 0 => exact quasiIsoAt_injIota_zero
    | (m + 1) => exact quasiIsoAt_injIota_succ m

/-- **The standard injective resolution `0 → ℤ → ℚ → ℚ⧸ℤ → 0` of `ℤ`** as a bundled injective
resolution. -/
noncomputable def intInjectiveResolution : InjectiveResolution (ModuleCat.of ℤ ℤ) where
  cocomplex := injComplex
  injective := injective_injComplex_X
  ι := injIota
  quasiIso := quasiIso_injIota

/-- Since the resolution has length one, all right derived functors of an additive functor `F`
vanish on `ℤ` in degrees `≥ 2`. -/
theorem isZero_rightDerived_of_two_le {D : Type*} [Category D] [Abelian D]
    (F : ModuleCat.{0} ℤ ⥤ D) [F.Additive] (n : ℕ) :
    IsZero ((F.rightDerived (n + 2)).obj (ModuleCat.of ℤ ℤ)) := by
  refine IsZero.of_iso ?_ (intInjectiveResolution.isoRightDerivedObj F (n + 2))
  have hzero : IsZero (F.obj (injComplex.X (n + 2))) :=
    Functor.map_isZero F (isZero_injComplex_X n)
  have h2 : IsZero (((F.mapHomologicalComplex (ComplexShape.up ℕ)).obj
      injComplex).X (n + 2)) := hzero
  exact (HomologicalComplex.exactAt_iff_isZero_homology _ _).1
    (ShortComplex.exact_of_isZero_X₂ _ h2)

end Catalog.DerivedFunctors